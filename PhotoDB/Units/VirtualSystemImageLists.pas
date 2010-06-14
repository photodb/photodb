unit VirtualSystemImageLists;

// Version 1.1.17
//   The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the
// License at
//
// http://www.mozilla.org/MPL/
//
//   Software distributed under the License is distributed on an
// " AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either expressed or
// implied. See the License for the specific language governing rights
// and limitations under the License.
//
//
//   Alternatively, the contents of this file may be used under
// the terms of the GNU General Public License Version 2 or later
// (the "GPL"), in which case the provisions of the GPL are applicable
// instead of those above. If you wish to allow use of your version of
// this file only under the terms of the GPL and not to allow others to
// use your version of this file under the MPL, indicate your decision
// by deleting the provisions above and replace them with the notice and
// other provisions required by the GPL. If you do not delete the provisions
// above, a recipient may use your version of this file under either the
// MPL or the GPL.
//
// The initial developer of this code is Jim Kueneman <jimdk@mindspring.com>
//
//----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Menus, Registry, ShlObj, ShellAPI, ActiveX, ImgList, CommCtrl;

const
  SID_IImageList = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';
  IID_IImageList: TGUID = SID_IImageList;

type
  IImageList = interface(IUnknown)
  [SID_IImageList]
    function Add(Image, Mask: HBITMAP; var Index: Integer): HRESULT; stdcall;
    function ReplaceIcon(IndexToReplace: Integer; Icon: HICON; var Index: Integer): HRESULT; stdcall;
    function SetOverlayImage(iImage: Integer; iOverlay: Integer): HRESULT; stdcall;
    function Replace(Index: Integer; Image, Mask: HBITMAP): HRESULT; stdcall;
    function AddMasked(Image: HBITMAP; MaskColor: COLORREF; var Index: Integer): HRESULT; stdcall;
    function Draw(var DrawParams: TImageListDrawParams): HRESULT; stdcall;
    function Remove(Index: Integer): HRESULT; stdcall;
    function GetIcon(Index: Integer; Flags: UINT; var Icon: HICON): HRESULT; stdcall;
    function GetImageInfo(Index: Integer; var ImageInfo: TImageInfo): HRESULT; stdcall;
    function Copy(iDest: Integer; SourceList: IUnknown; iSource: Integer; Flags: UINT): HRESULT; stdcall;
    function Merge(i1: Integer; List2: IUnknown; i2, dx, dy: Integer; ID: TGUID; out ppvOut): HRESULT; stdcall;
    function Clone(ID: TGUID; out ppvOut): HRESULT; stdcall;
    function GetImageRect(Index: Integer; var rc: TRect): HRESULT; stdcall;
    function GetIconSize(var cx, cy: Integer): HRESULT; stdcall;
    function SetIconSize(cx, cy: Integer): HRESULT; stdcall;
    function GetImageCount(var Count: Integer): HRESULT; stdcall;
    function SetImageCount(NewCount: UINT): HRESULT; stdcall;
    function SetBkColor(BkColor: COLORREF; var OldColor: COLORREF): HRESULT; stdcall;
    function GetBkColor(var BkColor: COLORREF): HRESULT; stdcall;
    function BeginDrag(iTrack, dxHotSpot, dyHotSpot: Integer): HRESULT; stdcall;
    function EndDrag: HRESULT; stdcall;
    function DragEnter(hWndLock: HWND; x, y: Integer): HRESULT; stdcall;
    function DragLieave(hWndLock: HWND): HRESULT; stdcall;
    function DragMove(x, y: Integer): HRESULT; stdcall;
    function SetDragCursorImage(Image: IUnknown; iDrag, dxHotSpot, dyHotSpot: Integer): HRESULT; stdcall;
    function DragShowNoLock(fShow: BOOL): HRESULT; stdcall;
    function GetDragImage(var CurrentPos, HotSpot: TPoint; ID: TGUID; out ppvOut): HRESULT; stdcall;
    function GetImageFlags(i: Integer; dwFlags: DWORD): HRESULT; stdcall;
    function GetOverlayImage(iOverlay: Integer; var iIndex: Integer): HRESULT; stdcall;
  end;


const
  {$EXTERNALSYM SHIL_LARGE}
  SHIL_LARGE         = 0;   // normally 32x32
  {$EXTERNALSYM SHIL_SMALL}
  SHIL_SMALL         = 1;   // normally 16x16
  {$EXTERNALSYM SHIL_EXTRALARGE}
  SHIL_EXTRALARGE    = 2;   // normall 48x48
  {$EXTERNALSYM SHIL_SYSSMALL}
  SHIL_SYSSMALL      = 3;   // like SHIL_SMALL, but tracks system small icon metric correctly
  {$EXTERNALSYM SHIL_LAST}
  SHIL_LAST          = SHIL_SYSSMALL;

type
  TSHGetImageList = function(iImageList: Integer; const RefID: TGUID; out ImageList): HRESULT; stdcall;


type
  TSysImageListSize =  (
    sisSmall,    // Large System Images
    sisLarge,    // Small System Images
    sisExtraLarge  // Extra Large Images (48x48)
  );

type
  VirtualSysImages = class(TImageList)
  private
    FImageSize: TSysImageListSize;
    FJumboImages: IImageList;
    procedure SetImageSize(const Value: TSysImageListSize);
  protected
    procedure RecreateHandle;
    procedure Flush;
    property JumboImages: IImageList read FJumboImages;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ImageSize: TSysImageListSize read FImageSize write SetImageSize;
  end;

  function ExtraLargeSysImages: VirtualSysImages;
  function LargeSysImages: VirtualSysImages;
  function SmallSysImages: VirtualSysImages;

  procedure FlushImageLists;

implementation

var
  FExtraLargeSysImages: VirtualSysImages = nil;
  FLargeSysImages: VirtualSysImages = nil;
  FSmallSysImages: VirtualSysImages = nil;
  ShellDLL: HMODULE = 0;

procedure FlushImageLists;
begin
  if Assigned(FSmallSysImages) then
    FSmallSysImages.Flush;
  if Assigned(FLargeSysImages) then
    FLargeSysImages.Flush;
  if Assigned(FExtraLargeSysImages) then
    FExtraLargeSysImages.Flush
end;

function ExtraLargeSysImages: VirtualSysImages;
begin
  if not Assigned(FExtraLargeSysImages) then
  begin
    FExtraLargeSysImages := VirtualSysImages.Create(nil);
    FExtraLargeSysImages.ImageSize := sisExtraLarge;
  end;
  Result := FExtraLargeSysImages
end;

function LargeSysImages: VirtualSysImages;
begin
  if not Assigned(FLargeSysImages) then
  begin
    FLargeSysImages := VirtualSysImages.Create(nil);
    FLargeSysImages.ImageSize := sisLarge;
  end;
  Result := FLargeSysImages
end;

function SmallSysImages: VirtualSysImages;
begin
  if not Assigned(FSmallSysImages) then
  begin
    FSmallSysImages := VirtualSysImages.Create(nil);
    FSmallSysImages.ImageSize := sisSmall;
  end;
  Result := FSmallSysImages
end;

function SHGetImageList(iImageList: Integer; const RefID: TGUID; out ppvOut): HRESULT;
// Retrieves the system ImageList interface
var
  ImageList: TSHGetImageList;
begin
  Result := E_NOTIMPL;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    ShellDLL := LoadLibrary(Shell32);
    if ShellDLL <> 0 then
    begin
      ImageList := GetProcAddress(ShellDLL, PChar(727));
      if (Assigned(ImageList)) then
        Result := ImageList(iImageList, RefID, ppvOut);
    end
  end;
end;

{ VirtualSysImages }

constructor VirtualSysImages.Create(AOwner: TComponent);
begin
  inherited;
  ShareImages := True;
  ImageSize := sisSmall;
  DrawingStyle := dsTransparent
end;

destructor VirtualSysImages.Destroy;
begin
  inherited;
end;

procedure VirtualSysImages.Flush;
begin
  RecreateHandle
end;

procedure VirtualSysImages.RecreateHandle;
var
  PIDL: PItemIDList;
  Malloc: IMalloc;
  FileInfo: TSHFileInfo;
  Flags: Longword;
begin
  Handle := 0;
  if FImageSize = sisExtraLarge then
  begin
    if Succeeded(SHGetImageList(SHIL_EXTRALARGE, IImageList, FJumboImages)) then
      Handle := THandle(FJumboImages)
    else begin
      Flags := SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_LARGEICON;
      SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, PIDL);
      SHGetMalloc(Malloc);
      Handle := SHGetFileInfo(PChar(PIDL), 0, FileInfo, SizeOf(FileInfo), Flags);
      Malloc.Free(PIDL);
    end
  end else
  begin
    SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, PIDL);
    SHGetMalloc(Malloc);
    if FImageSize = sisSmall then
      Flags := SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_SMALLICON
    else
      Flags := SHGFI_PIDL or SHGFI_SYSICONINDEX or SHGFI_LARGEICON;
    Handle := SHGetFileInfo(PChar(PIDL), 0, FileInfo, SizeOf(FileInfo), Flags);
    Malloc.Free(PIDL);
  end;
end;

procedure VirtualSysImages.SetImageSize(const Value: TSysImageListSize);
begin
  FImageSize := Value;
  RecreateHandle;
end;

initialization

finalization
  FLargeSysImages.Free;
  FSmallSysImages.Free;
  FExtraLargeSysImages.Free;
  if ShellDLL <> 0 then
    FreeLibrary(ShellDLL)

end.