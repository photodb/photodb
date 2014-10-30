unit Dmitry.Utils.ShellIcons;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  Winapi.CommCtrl,
  Winapi.ShellAPI,
  Vcl.Graphics,
  Vcl.ImgList,
  Dmitry.Utils.SystemImageLists,
  Dmitry.Memory;

procedure FindIcon(hLib: Cardinal; NameRes: string; Size, ColorDepth: Byte; var Icon: TIcon);
function ExtractShellIcon(Path: string; Size: Integer): HIcon;
function ExtractDefaultAssociatedIcon(Extension: string; Size: Integer): HIcon;

implementation

var
  FVirtualSysImages: VirtualSysImages = nil;
  FSyncGlobalImages: TCriticalSection = nil;
  FSyncSH: TCriticalSection = nil;

procedure FindIcon(hLib: cardinal; NameRes: string; Size, ColorDepth: Byte;
  var Icon: TIcon);
type
  GRPICONDIRENTRY = packed record
    bWidth: Byte; // Width, in pixels, of the image
    bHeight: Byte; // Height, in pixels, of the image
    bColorCount: Byte; // Number of colors in image (0 if >=8bpp)
    bReserved: Byte; // Reserved
    wPlanes: WORD; // Color Planes
    wBitCount: WORD; // Bits per pixel
    dwBytesInRes: DWORD; // how many bytes in this resource?
    nID: WORD; // the ID
  end;

  GRPICONDIR = packed record
    idReserved: WORD; // Reserved (must be 0)
    idType: WORD; // Resource type (1 for icons)
    idCount: WORD; // How many images?
    idEntries: array [1 .. 16] of GRPICONDIRENTRY; // The entries for each image
  end;

  ICONIMAGE = record
    icHeader: BITMAPINFOHEADER; // DIB header
    icColors: array of RGBQUAD; // Color table
    icXOR: array of Byte; // DIB bits for XOR mask
    icAND: array of Byte; // DIB bits for AND mask
  end;

var
  hRsrc, hGlobal: cardinal;

  GRP: GRPICONDIR;

  lpGrpIconDir: ^GRPICONDIR;
  lpIconImage: ^ICONIMAGE;

  Stream: TMemoryStream;
  i, i0, nID: Integer;
begin
  Icon := nil;
  lpIconImage:=nil;
  // Find the group resource which lists its images
  hRsrc := FindResource(hLib, PWideChar(NameRes), RT_GROUP_ICON);
  // Load and Lock to get a pointer to a GRPICONDIR
  hGlobal := LoadResource(hLib, hRsrc);
  lpGrpIconDir := LockResource(hGlobal);

  // Using an ID from the group, Find, Load and Lock the RT_ICON
  i0 := Low(lpGrpIconDir.idEntries);
  for i := i0 to lpGrpIconDir.idCount do begin
    hRsrc := FindResource(hLib, MAKEINTRESOURCE(lpGrpIconDir.idEntries[i].nID), RT_ICON);
    hGlobal := LoadResource(hLib, hRsrc);
    lpIconImage := LockResource(hGlobal);
    if (lpIconImage.icHeader.biWidth = Size) and ((lpIconImage.icHeader.biBitCount = ColorDepth) or (ColorDepth = 0)) then
      Break;
  end;

  if Assigned(lpIconImage) and (lpIconImage.icHeader.biWidth = Size)
  and (lpIconImage.icHeader.biBitCount = ColorDepth) then begin
    Stream := TMemoryStream.Create;
    try
      Stream.Clear;

      ZeroMemory(@GRP, SizeOf(GRP));
      GRP.idCount := 1;
      GRP.idType := 1;
      GRP.idReserved := 0;
      GRP.idEntries[i0] := lpGrpIconDir.idEntries[i];
      nID := SizeOf(WORD) * 3 + SizeOf(GRPICONDIRENTRY) + 2;  //$16
      GRP.idEntries[i0].nID := nID;
      Stream.WriteBuffer(GRP, nID);
      Stream.WriteBuffer(lpIconImage^, GRP.idEntries[i0].dwBytesInRes);

      Stream.Position := 0;
      Icon := TIcon.Create;
      Icon.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

function GetShellFlagdBySize(Size: Integer): Cardinal;
begin
  Result := SHGFI_ADDOVERLAYS;
  if (Size < 48) then Result := Result or SHGFI_SYSICONINDEX or SHGFI_ICON;
  if (Size = 48) then Result := Result or SHGFI_SYSICONINDEX;
  if (Size = 32) then Result := Result or SHGFI_LARGEICON;
  if (Size = 16) then Result := Result or SHGFI_SMALLICON;
end;

function GetShellInternalIcon(FileInfo: TSHFileInfo; Size: Integer): HIcon;
const
  DrawingStyles: array[TDrawingStyle] of Longint = (ILD_FOCUS, ILD_SELECTED,
    ILD_NORMAL, ILD_TRANSPARENT);
  Images: array[TImageType] of Longint = (0, ILD_MASK);
begin
  if (Size < 48) then
  begin
    Result := FileInfo.hIcon;
  end else
  begin
    //create this object when it needed!
    FSyncGlobalImages.Enter;
    try
      if FVirtualSysImages = nil then
        FVirtualSysImages := ExtraLargeSysImages;
      Result := ImageList_GetIcon(FVirtualSysImages.Handle, FileInfo.iIcon, DrawingStyles[FVirtualSysImages.DrawingStyle] or Images[FVirtualSysImages.ImageType]);
    finally
      FSyncGlobalImages.Leave;
    end;
  end;
end;

function ExtractDefaultAssociatedIcon(Extension: string; Size: Integer): HIcon;
var
  FileInfo: SHFILEINFO;
  Flags: Integer;
begin
  Extension := '*' + Extension;

  FillChar(FileInfo, SizeOf(FileInfo), #0);
  Flags := GetShellFlagdBySize(Size);

  FSyncSH.Enter;
  try
    SHGetFileInfo(PChar(Extension),
                  FILE_ATTRIBUTE_NORMAL,
                  FileInfo,
                  SizeOf(FileInfo),
                  SHGFI_SYSICONINDEX or Flags or SHGFI_USEFILEATTRIBUTES
                  );
  finally
    FSyncSH.Leave;
  end;

  Result := GetShellInternalIcon(FileInfo, Size);
end;

function ExtractShellIcon(Path: string; Size: Integer): HIcon;
var
  FileInfo: TSHFileInfo;
  Flags: UINT;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0);
  Flags := GetShellFlagdBySize(Size);

  FSyncSH.Enter;
  try
    SHGetFileInfo(PWideChar(Path), FILE_ATTRIBUTE_NORMAL, FileInfo, SizeOf(FileInfo), Flags);
  finally
    FSyncSH.Leave;
  end;

  Result := GetShellInternalIcon(FileInfo, Size);
end;

initialization
  FSyncGlobalImages := TCriticalSection.Create;
  FSyncSH := TCriticalSection.Create;

finalization
  F(FSyncGlobalImages);
  F(FSyncSH);

end.

