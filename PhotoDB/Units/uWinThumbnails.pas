unit uWinThumbnails;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Jpeg, StdCtrls, ExtCtrls, ComCtrls, ShellApi, Math, CommCtrl,
  ShlObj, ActiveX, ComObj;

const
  IEIFLAG_ASYNC = $001; // ask the extractor if it supports ASYNC extract
  // (free threaded)
  IEIFLAG_CACHE = $002; // returned from the extractor if it does NOT cache
  // the thumbnail
  IEIFLAG_ASPECT = $004; // passed to the extractor to beg it to render to
  // the aspect ratio of the supplied rect
  IEIFLAG_OFFLINE = $008; // if the extractor shouldn't hit the net to get
  // any content needs for the rendering
  IEIFLAG_GLEAM = $010; // does the image have a gleam? this will be
  // returned if it does
  IEIFLAG_SCREEN = $020; // render as if for the screen  (this is exlusive
  // with IEIFLAG_ASPECT )
  IEIFLAG_ORIGSIZE = $040; // render to the approx size passed, but crop if
  // neccessary
  IEIFLAG_NOSTAMP = $080; // returned from the extractor if it does NOT want
  // an icon stamp on the thumbnail
  IEIFLAG_NOBORDER = $100; // returned from the extractor if it does NOT want
  // an a border around the thumbnail
  IEIFLAG_QUALITY = $200; // passed to the Extract method to indicate that
  // a slower, higher quality image is desired,
  // re-compute the thumbnail

  SHIL_LARGE = $00; // The image size is normally 32x32 pixels. However, if the Use large icons option is selected from the Effects section of the Appearance tab in Display Properties, the image is 48x48 pixels.
  SHIL_SMALL = $01; // These images are the Shell standard small icon size of 16x16, but the size can be customized by the user.
  SHIL_EXTRALARGE = $02; // These images are the Shell standard extra-large icon size. This is typically 48x48, but the size can be customized by the user.
  SHIL_SYSSMALL = $03; // These images are the size specified by GetSystemMetrics called with SM_CXSMICON and GetSystemMetrics called with SM_CYSMICON.
  SHIL_JUMBO = $04; // Windows Vista and later. The image is normally 256x256 pixels.
  IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';

  SIIGBF_RESIZETOFIT = $00000000;
  SIIGBF_BIGGERSIZEOK = $00000001;
  SIIGBF_MEMORYONLY = $00000002;
  SIIGBF_ICONONLY = $00000004;
  SIIGBF_THUMBNAILONLY = $00000008;
  SIIGBF_INCACHEONLY = $00000010;

type

  IRunnableTask = interface
    ['{85788D00-6807-11D0-B810-00C04FD706EC}']
    function Run: HResult; stdcall;
    function Kill(fWait: BOOL): HResult; stdcall;
    function Suspend: HResult; stdcall;
    function Resume: HResult; stdcall;
    function IsRunning: Longint; stdcall;
  end;

  IExtractImage = interface
    ['{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}']
    function GetLocation(pszwPathBuffer: PWideChar; cch: DWord;
      var dwPriority: DWord; var rgSize: TSize; dwRecClrDepth: DWord;
      var dwFlags: DWord): HResult; stdcall;
    function Extract(var hBmpThumb: HBITMAP): HResult; stdcall;
  end;

  {$EXTERNALSYM SIIGBF}
  SIIGBF = Integer;

  {$EXTERNALSYM IShellItemImageFactory}
  IShellItemImageFactory = interface(IUnknown)
    ['{BCC18B79-BA16-442F-80C4-8A59C30C463B}']
    function GetImage(size: TSize; flags: SIIGBF; out phbm: HBITMAP):
      HRESULT; stdcall;
  end;

  PCacheItem = ^TCacheItem;
  TCacheItem = record
    Idx: Integer;
    Size: Integer;
    Age: TDateTime;
    Scale: Integer;
    Bmp: TBitmap;
  end;

function ExtractThumbnail(Path: string; SizeX, SizeY: Integer; InitOle: Boolean = False): HBitmap;

implementation

function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
type
  _SHGetImageList = function(iImageList: Integer; const riid: TGUID;
    var ppv: Pointer): HResult; stdcall;
var
  Handle: THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result := 0;
  Handle := LoadLibrary('Shell32.dll');
  if Handle <> S_OK then
    try
      SHGetImageList := GetProcAddress(Handle, PChar(727));
      if Assigned(SHGetImageList) and (Win32Platform = VER_PLATFORM_WIN32_NT)
        then
        SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
    finally
      FreeLibrary(Handle);
    end;
end;

procedure GetIconFromFile(aFile: string; var aIcon: TIcon; SHIL_FLAG: Cardinal);
var
  aImgList: HIMAGELIST;
  SFI: TSHFileInfo;
  aIndex: Integer;
begin // Get the index of the imagelist
  SHGetFileInfo(PChar(aFile), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(TSHFileInfo),
    {SHGFI_ICON or  SHGFI_LARGEICON or } SHGFI_SHELLICONSIZE or
      SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_DISPLAYNAME);
  if not Assigned(aIcon) then
    aIcon := TIcon.Create;
  aImgList := GetImageListSH(SHIL_FLAG); // get the imagelist
  aIndex := SFI.iIcon; // get index
  // OBS! Use ILD_IMAGE since ILD_NORMAL gives bad result in Windows 7
  aIcon.Handle := ImageList_GetIcon(aImgList, aIndex, ILD_IMAGE);
end;

function ExtractThumbnail(Path: string; SizeX, SizeY: Integer; InitOle: Boolean = False): HBitmap;
var
  ShellFolder, DesktopShellFolder: IShellFolder;
  XtractImage: IExtractImage;
  Eaten: DWord;
  PIDL: PItemIDList;
  RunnableTask: IRunnableTask;
  Flags: DWord;
  Buf: array [0 .. MAX_PATH] of Char;
  BmpHandle: HBITMAP;
  Atribute, Priority: DWord;
  GetLocationRes: HResult;
  ASize: TSize;
begin
  Result := 0;
  try
    if InitOle then
      CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE);
    try

      OleCheck(SHGetDesktopFolder(DesktopShellFolder));
      OleCheck(DesktopShellFolder.ParseDisplayName(0, nil, StringToOleStr(ExtractFilePath(Path)),
          Eaten, PIDL, Atribute));
      OleCheck(DesktopShellFolder.BindToObject(PIDL, nil, IID_IShellFolder, Pointer(ShellFolder)));
      CoTaskMemFree(PIDL);

      OleCheck(ShellFolder.ParseDisplayName(0, nil, StringToOleStr(ExtractFileName(Path)), Eaten, PIDL, Atribute));
      ShellFolder.GetUIObjectOf(0, 1, PIDL, IExtractImage, nil, XtractImage);
      CoTaskMemFree(PIDL);

      if Assigned(XtractImage) then  // Try getting a thumbnail..
      begin
        RunnableTask := nil;
        ASize.cx := SizeX;
        ASize.cy := SizeY;
        Priority := 0;
        Flags:= IEIFLAG_ASPECT or IEIFLAG_OFFLINE or IEIFLAG_CACHE or IEIFLAG_QUALITY;
        GetLocationRes := XtractImage.GetLocation(Buf, SizeOf(Buf), Priority, ASize, 32, Flags);
        if (GetLocationRes = NOERROR) or (GetLocationRes = E_PENDING) then
        begin
          if GetLocationRes = E_PENDING then
            if XtractImage.QueryInterface(IRunnableTask, RunnableTask) <> S_OK then
              RunnableTask := nil;
          try
            //do not call OleCheck for debug
            XtractImage.Extract(BmpHandle);
            // This could consume a long time.
            Result := BmpHandle;
          except
            on E: EOleSysError do
              OutputDebugString(PChar(string(E.ClassName) + ': ' + E.message))
          end; // try/except
        end;
      end;

    finally
      if InitOle then
        CoUninitialize;
    end;
  except
    Result := 0;
  end;
end;

end.
