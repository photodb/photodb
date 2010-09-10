unit uAssociatedIcons;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  ComObj,
  ActiveX,
  ShlObj,
  VirtualSystemImageLists,
  CommCtrl,
  ShellAPI,
  Forms,
  Dolphin_DB,
  SyncObjs,
  Registry;

type
  TAssociatedIcons = record
    Icon : TIcon;
    Ext : String;
    SelfIcon : Boolean;
    Size : integer;
  end;

  TAIcons = class(TObject)
  private
    FAssociatedIcons : array of TAssociatedIcons;
    FIDesktopFolder: IShellFolder;
    UnLoadingListEXT : TStringList;
    FVirtualSysImages : VirtualSysImages;
    FSync : TCriticalSection;
    procedure Initialize;
    function SetPath(const Value: string) : PItemIDList;
  public
    class function Instance : TAIcons;
    constructor Create;
    destructor Destroy; override;
    function IsExt(Ext : string; Size : integer): boolean;
    function AddIconByExt(FileName, EXT : string; Size : integer) : integer;
    function GetIconByExt(FileName : String; IsFolder : boolean; Size : integer; Default : boolean) : TIcon;
    function GetShellImage(Path : String; Size : integer): TIcon;
    function IsVarIcon(FileName : String; Size : integer): boolean;
    procedure Clear;
  end;

procedure FindIcon(hLib :cardinal; NameRes :string; Size, ColorDepth :Byte; var Icon :TIcon);
function VarIco(Ext : string) : boolean;

implementation

uses ExplorerTypes;

var
  AIcons : TAIcons = nil;

{ TAIcons }

function VarIco(Ext : string) : boolean;
var
  reg : TRegistry;
  s : string;
  i : integer;
begin
  Result := False;
  if  (Ext = '') or (Ext = '.scr') or (Ext = '.exe') then
  begin
    Result := True;
    Exit;
  end;

 Reg := TRegistry.Create;
  try
    Reg.RootKey := Windows.HKEY_CLASSES_ROOT;
    if not Reg.OpenKey('\' + Ext, False) then
      Exit;
    S := Reg.ReadString('');
    Reg.CloseKey;
    if not Reg.OpenKey('\' + S + '\DefaultIcon', False) then
      Exit;
    S := Reg.ReadString('');
    for I := Length(S) downto 1 do
      if (S[I] = '''') or (S[I] = '"') or (S[I] = ' ') then
        Delete(S, I, 1);
    if S = '%1' then
      Result := True;
  finally
    Reg.Free;
  end;
end;

function TAIcons.SetPath(const Value: string) : PItemIDList;
var
  P: PWideChar;
  Flags,
  NumChars: LongWord;
begin
  Result:=nil;
  NumChars := Length(Value);
  Flags := 0;
  P := StringToOleStr(Value);
  if not Succeeded(FIDesktopFolder.ParseDisplayName(Application.Handle,nil,P,NumChars,Result,Flags)) then
    result:=nil;
end;

procedure FindIcon(hLib :cardinal; NameRes :string; Size, ColorDepth :Byte; var Icon :TIcon);
type
  GRPICONDIRENTRY =  packed record
    bWidth :BYTE;              // Width, in pixels, of the image
    bHeight :BYTE;              // Height, in pixels, of the image
    bColorCount :BYTE;          // Number of colors in image (0 if >=8bpp)
    bReserved :BYTE;            // Reserved
    wPlanes :WORD;              // Color Planes
    wBitCount :WORD;            // Bits per pixel
    dwBytesInRes :DWORD;        // how many bytes in this resource?
    nID :WORD;                  // the ID
  end;

  GRPICONDIR =  packed record
    idReserved :WORD;  // Reserved (must be 0)
    idType :WORD;      // Resource type (1 for icons)
    idCount :WORD;      // How many images?
    idEntries :array [1..16] of GRPICONDIRENTRY ; // The entries for each image
  end;

  ICONIMAGE = record
    icHeader :BITMAPINFOHEADER;      // DIB header
    icColors :array of RGBQUAD;  // Color table
    icXOR :array of BYTE;      // DIB bits for XOR mask
    icAND :array of BYTE;      // DIB bits for AND mask
  end;

var
  hRsrc, hGlobal :cardinal;

  GRP :GRPICONDIR;

  lpGrpIconDir :^GRPICONDIR;
  lpIconImage :^ICONIMAGE;

  Stream :TMemoryStream;
  i, i0, nID :integer;
begin
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
    if (lpIconImage.icHeader.biWidth = Size) and (lpIconImage.icHeader.biBitCount = ColorDepth) then
      Break;
  end;

  if Assigned(lpIconImage) and (lpIconImage.icHeader.biWidth = Size)
  and (lpIconImage.icHeader.biBitCount = ColorDepth) then begin
    Stream := TMemoryStream.Create;
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
    Icon:=TIcon.Create;
    Icon.LoadFromStream(Stream);
    Stream.Free;
  end;
end;

function TAIcons.GetShellImage(Path : String; Size : integer): TIcon;
var
  FileInfo: TSHFileInfo;
  Flags: Integer;
  PathPidl: PItemIDList;
begin
  FSync.Enter;
  try
    Result := nil;
    FillChar(FileInfo, SizeOf(FileInfo), #0);
    Flags := 0;
    if (Size < 48) then Flags := SHGFI_SYSICONINDEX or SHGFI_ICON;
    if (Size = 48) then Flags := SHGFI_SYSICONINDEX;
    if (Size = 32) then Flags := Flags or SHGFI_LARGEICON;
    if (Size = 16) then Flags := Flags or SHGFI_SMALLICON;

    SHGetFileInfo(PWideChar(Path), 0, FileInfo, SizeOf(FileInfo), Flags or SHGFI_TYPENAME);
    Result := TIcon.Create;
    if (Size < 48) then
    begin
      Result.Handle:=FileInfo.hIcon;
    end else
    begin
     //create this object when it needed!
     if FVirtualSysImages=nil then
       FVirtualSysImages:=ExtraLargeSysImages;

     FVirtualSysImages.GetIcon(FileInfo.iIcon, Result);
    end;
  finally
    FSync.Leave;
  end;
end;

function TAIcons.AddIconByExt(FileName, EXT: string; Size : integer) : integer;
begin
  FSync.Enter;
  try
    Result:=Length(FAssociatedIcons)-1;
    SetLength(FAssociatedIcons,Length(FAssociatedIcons)+1);
    FAssociatedIcons[Length(FAssociatedIcons)-1].Ext:=EXT;
    FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon:=VarIco(EXT);
    FAssociatedIcons[Length(FAssociatedIcons)-1].Icon:=GetShellImage(FileName,Size);
    FAssociatedIcons[Length(FAssociatedIcons)-1].Size:=Size;
  finally
    FSync.Leave;
  end;
end;

constructor TAIcons.Create;
begin
  if SHGetDesktopFolder(FIDesktopFolder) <> NOERROR then
     raise Exception.Create('Error in call SHGetDesktopFolder!');
  inherited;
  FSync := TCriticalSection.Create;
  UnLoadingListEXT := TStringList.Create;
  FVirtualSysImages:=nil;
  Initialize;
end;

destructor TAIcons.Destroy;
var
  i : integer;
begin
  for i:=0 to length(FAssociatedIcons)-1 do
  FAssociatedIcons[i].Icon.free;
  SetLength(FAssociatedIcons,0);
  UnLoadingListEXT.Free;
  FSync.Free;
  inherited;
end;

function TAIcons.GetIconByExt(FileName: String; IsFolder : boolean; Size : integer; Default : boolean): TIcon;
var
  n, i : integer;
  Ext : String;
begin
  FSync.Enter;
  try
    Result:=nil;
    n:=0;
    if IsFolder then
    if Copy(FileName,1,2)='\\' then Default:=true;
    if IsFolder then Ext:='' else Ext:=AnsiLowerCase(ExtractFileExt(FileName));
    if not IsExt(EXT,Size) and not Default then
    n:=AddIconByExt(FileName, Ext, Size);
    for i:=n to length(FAssociatedIcons)-1 do
      if (FAssociatedIcons[i].Ext = Ext) and (FAssociatedIcons[i].Size = Size) then
      begin
      if (not FAssociatedIcons[i].SelfIcon) or Default then
      begin
        if Size = 48 then
          Result := TIcon48.Create
        else
         Result:=TIcon.Create;
       Result.Assign(FAssociatedIcons[i].Icon);
      end else
      begin
       Result:=GetShellImage(FileName,Size);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TAIcons.IsExt(Ext: string; Size : integer): boolean;
var
  i : Integer;
begin
  Result:=False;
  FSync.Enter;
  try
    for i:=0 to length(FAssociatedIcons)-1 do
    if (FAssociatedIcons[i].Ext = Ext) and (FAssociatedIcons[i].Size = Size) then
    begin
      Result:=True;
      Break;
    end;
  finally
    FSync.Leave;
  end;
end;

function TAIcons.IsVarIcon(FileName: string; Size : integer): boolean;
var
  i : Integer;
  Ext : String;
begin
  Result:=false;
  FSync.Enter;
  try
    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    for i:=0 to length(FAssociatedIcons)-1 do
    if (FAssociatedIcons[i].Ext = Ext) and (FAssociatedIcons[i].Size = Size) then
    begin
      Result := FAssociatedIcons[i].SelfIcon;
      Exit;
    end;
    SetLength(FAssociatedIcons,Length(FAssociatedIcons)+1);
    FAssociatedIcons[Length(FAssociatedIcons)-1].Ext:=EXT;
    FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon:=VarIco(EXT);
    if FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon then
    begin
      Result:=true;
      Exit;
    end;
    FAssociatedIcons[Length(FAssociatedIcons)-1].Icon := GetShellImage(FileName,Size);
    FAssociatedIcons[Length(FAssociatedIcons)-1].Size := Size;
  finally
    FSync.Leave;
  end;
end;

procedure TAIcons.Clear;
var
  i : Integer;
begin
  FSync.Enter;
  try
    for i:=0 to length(FAssociatedIcons)-1 do
    begin
      if not FAssociatedIcons[i].SelfIcon then
        FAssociatedIcons[i].Icon.Free;
    end;
    SetLength(FAssociatedIcons,0);
    Initialize;
  finally
    FSync.Leave;
  end;
end;

procedure TAIcons.Initialize;
begin
  SetLength(FAssociatedIcons,3*4);

  FAssociatedIcons[0].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'Directory',16,32,FAssociatedIcons[0].Icon);//GetShellImage(ProgramDir,16);
  FAssociatedIcons[0].SelfIcon:=true;
  FAssociatedIcons[0].Size:=16;

  FAssociatedIcons[1].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'DIRECTORY',32,32,FAssociatedIcons[1].Icon);
  FAssociatedIcons[1].SelfIcon:=true;
  FAssociatedIcons[1].Size:=32;

  FAssociatedIcons[2].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'DIRECTORY',48,32,FAssociatedIcons[2].Icon);
  FAssociatedIcons[2].SelfIcon:=true;
  FAssociatedIcons[2].Size:=48;

  FAssociatedIcons[3].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',16,4,FAssociatedIcons[3].Icon);
  FAssociatedIcons[3].SelfIcon:=true;
  FAssociatedIcons[3].Size:=16;

  FAssociatedIcons[4].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',32,4,FAssociatedIcons[4].Icon);
  FAssociatedIcons[4].SelfIcon:=true;
  FAssociatedIcons[4].Size:=32;

  FAssociatedIcons[5].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',48,4,FAssociatedIcons[5].Icon);
  FAssociatedIcons[5].SelfIcon:=true;
  FAssociatedIcons[5].Size:=48;

  FAssociatedIcons[6].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',16,4,FAssociatedIcons[6].Icon);
  FAssociatedIcons[6].SelfIcon:=true;
  FAssociatedIcons[6].Size:=16;

  FAssociatedIcons[7].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',32,4,FAssociatedIcons[7].Icon);
  FAssociatedIcons[7].SelfIcon:=true;
  FAssociatedIcons[7].Size:=32;

  FAssociatedIcons[8].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',48,4,FAssociatedIcons[8].Icon);
  FAssociatedIcons[8].SelfIcon:=true;
  FAssociatedIcons[8].Size:=48;

  FAssociatedIcons[9].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',16,4,FAssociatedIcons[9].Icon);
  FAssociatedIcons[9].SelfIcon:=true;
  FAssociatedIcons[9].Size:=48;

  FAssociatedIcons[10].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',32,4,FAssociatedIcons[10].Icon);
  FAssociatedIcons[10].SelfIcon:=true;
  FAssociatedIcons[10].Size:=32;

  FAssociatedIcons[11].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',48,4,FAssociatedIcons[11].Icon);;
  FAssociatedIcons[11].SelfIcon:=true;
  FAssociatedIcons[11].Size:=16;
end;

class function TAIcons.Instance: TAIcons;
begin
  if AIcons = nil then
    AIcons := TAIcons.Create;

  Result := AIcons;
end;

end.
