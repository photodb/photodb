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
  CommCtrl,
  ShellAPI,
  Forms,
  UnitDBKernel,
  SyncObjs,
  Registry,
  uMemory,
  uShellIcons;

type
  TAssociatedIcons = record
    Icon: TIcon;
    Ext: String;
    SelfIcon: Boolean;
    Size: Integer;
  end;

  TAIcons = class(TObject)
  private
    FAssociatedIcons: array of TAssociatedIcons;
    FIDesktopFolder: IShellFolder;
    UnLoadingListEXT : TStringList;
    FSync: TCriticalSection;
    procedure Initialize;
  public
    class function Instance: TAIcons;
    constructor Create;
    destructor Destroy; override;
    function IsExt(Ext: string; Size: Integer): Boolean;
    function AddIconByExt(FileName, Ext: string; Size: Integer): Integer;
    function GetIconByExt(FileName: String; IsFolder: Boolean; Size: Integer; Default: Boolean): TIcon;
    function GetShellImage(Path: String; Size: Integer): TIcon;
    function IsVarIcon(FileName: String; Size: Integer): Boolean;
    procedure Clear;
    function SetPath(const Value: string): PItemIDList;
  end;

function VarIco(Ext: string): Boolean;
function IsVideoFile(FileName: string): Boolean;

implementation

uses ExplorerTypes;

var
  AIcons: TAIcons = nil;

function IsVideoFile(FileName: string): Boolean;
begin
  Result := Pos(AnsiLowerCase(ExtractFileExt(FileName)), '.mov,.avi,.mkv,.mp4,.mpg,.mpe,.mpeg,.m2v,.wmv') > 0;
end;

{ TAIcons }

function VarIco(Ext: string): Boolean;
var
  Reg: TRegistry;
  S: string;
  I: integer;
begin
  Result := False;
  if  (Ext = '') or (Ext = '.scr') or (Ext = '.exe') then
  begin
    Result := True;
    Exit;
  end;

  Reg := TRegistry.Create(KEY_READ);
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
    F(Reg);
  end;
end;

function TAIcons.SetPath(const Value: string): PItemIDList;
var
  P: PWideChar;
  Flags,
  NumChars: LongWord;
begin
  Result := nil;
  NumChars := Length(Value);
  Flags := 0;
  P := StringToOleStr(Value);
  if not Succeeded(FIDesktopFolder.ParseDisplayName(Application.Handle,nil,P,NumChars,Result,Flags)) then
    result := nil;
end;

function TAIcons.GetShellImage(Path: String; Size: integer): TIcon;
begin
  Result := TIcon.Create;
  Result.Handle := ExtractShellIcon(Path, Size);
end;

function TAIcons.AddIconByExt(FileName, EXT: string; Size : integer) : integer;
begin
  FSync.Enter;
  try
    Result := Length(FAssociatedIcons) - 1;
    SetLength(FAssociatedIcons, Length(FAssociatedIcons) + 1);
    FAssociatedIcons[Length(FAssociatedIcons) - 1].Ext := Ext;
    FAssociatedIcons[Length(FAssociatedIcons) - 1].SelfIcon := VarIco(Ext);
    FAssociatedIcons[Length(FAssociatedIcons) - 1].Icon := GetShellImage(FileName, Size);
    FAssociatedIcons[Length(FAssociatedIcons) - 1].Size := Size;
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
  Initialize;
end;

destructor TAIcons.Destroy;
var
  I: Integer;
begin
  AIcons := nil;
  for I := 0 to Length(FAssociatedIcons) - 1 do
    FAssociatedIcons[I].Icon.Free;
  SetLength(FAssociatedIcons, 0);
  UnLoadingListEXT.Free;
  FSync.Free;
  inherited;
end;

function TAIcons.GetIconByExt(FileName: string; IsFolder: Boolean; Size: Integer; Default: Boolean): TIcon;
var
  N, I: Integer;
  Ext: string;
begin
  FSync.Enter;
  try
    Result := nil;
    N := 0;
    if IsFolder then
      if Copy(FileName, 1, 2) = '\\' then
        Default := True;
    if IsFolder then
      Ext := ''
    else
      Ext := AnsiLowerCase(ExtractFileExt(FileName));
    if not IsExt(EXT, Size) and not default then
      N := AddIconByExt(FileName, Ext, Size);
    for I := N to Length(FAssociatedIcons) - 1 do
      if (FAssociatedIcons[I].Ext = Ext) and (FAssociatedIcons[I].Size = Size) then
      begin
        if (not FAssociatedIcons[I].SelfIcon) or default then
        begin
          if Size = 48 then
            Result := TIcon48.Create
          else
            Result := TIcon.Create;
          Result.Assign(FAssociatedIcons[I].Icon);
        end else
          Result := GetShellImage(FileName, Size);
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TAIcons.IsExt(Ext: string; Size: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
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

function TAIcons.IsVarIcon(FileName: string; Size: Integer): Boolean;
var
  I: Integer;
  Ext: string;
begin
  Result := False;

  if Result then
    Exit;

  FSync.Enter;
  try
    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    for I := 0 to length(FAssociatedIcons)-1 do
    if (FAssociatedIcons[i].Ext = Ext) and (FAssociatedIcons[i].Size = Size) then
    begin
      Result := FAssociatedIcons[i].SelfIcon;
      Exit;
    end;
    SetLength(FAssociatedIcons, Length(FAssociatedIcons) + 1);
    FAssociatedIcons[Length(FAssociatedIcons) - 1].Ext := Ext;
    FAssociatedIcons[Length(FAssociatedIcons) - 1].SelfIcon := VarIco(Ext);
    if FAssociatedIcons[Length(FAssociatedIcons) - 1].SelfIcon then
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
  I: Integer;
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
  SetLength(FAssociatedIcons, 3 * 4);

  FAssociatedIcons[0].Ext := '';
  FindIcon(HInstance, 'Directory', 16, 32, FAssociatedIcons[0].Icon); // GetShellImage(ProgramDir,16);
  FAssociatedIcons[0].SelfIcon := True;
  FAssociatedIcons[0].Size := 16;

  FAssociatedIcons[1].Ext := '';
  FindIcon(HInstance, 'DIRECTORY', 32, 32, FAssociatedIcons[1].Icon);
  FAssociatedIcons[1].SelfIcon := True;
  FAssociatedIcons[1].Size := 32;

  FAssociatedIcons[2].Ext := '';
  FindIcon(HInstance, 'DIRECTORY', 48, 32, FAssociatedIcons[2].Icon);
  FAssociatedIcons[2].SelfIcon := True;
  FAssociatedIcons[2].Size := 48;

  FAssociatedIcons[3].Ext := '.exe';
  FindIcon(HInstance, 'EXEFILE', 16, 4, FAssociatedIcons[3].Icon);
  FAssociatedIcons[3].SelfIcon := True;
  FAssociatedIcons[3].Size := 16;

  FAssociatedIcons[4].Ext := '.exe';
  FindIcon(HInstance, 'EXEFILE', 32, 4, FAssociatedIcons[4].Icon);
  FAssociatedIcons[4].SelfIcon := True;
  FAssociatedIcons[4].Size := 32;

  FAssociatedIcons[5].Ext := '.exe';
  FindIcon(HInstance, 'EXEFILE', 48, 4, FAssociatedIcons[5].Icon);
  FAssociatedIcons[5].SelfIcon := True;
  FAssociatedIcons[5].Size := 48;

  FAssociatedIcons[6].Ext := '.___';
  FindIcon(HInstance, 'SIMPLEFILE', 16, 32, FAssociatedIcons[6].Icon);
  FAssociatedIcons[6].SelfIcon := True;
  FAssociatedIcons[6].Size := 16;

  FAssociatedIcons[7].Ext := '.___';
  FindIcon(HInstance, 'SIMPLEFILE', 32, 32, FAssociatedIcons[7].Icon);
  FAssociatedIcons[7].SelfIcon := True;
  FAssociatedIcons[7].Size := 32;

  FAssociatedIcons[8].Ext := '.___';
  FindIcon(HInstance, 'SIMPLEFILE', 48, 32, FAssociatedIcons[8].Icon);
  FAssociatedIcons[8].SelfIcon := True;
  FAssociatedIcons[8].Size := 48;

  FAssociatedIcons[9].Ext := '.lnk';
  FindIcon(HInstance, 'SIMPLEFILE', 16, 32, FAssociatedIcons[9].Icon);
  FAssociatedIcons[9].SelfIcon := True;
  FAssociatedIcons[9].Size := 48;

  FAssociatedIcons[10].Ext := '.lnk';
  FindIcon(HInstance, 'SIMPLEFILE', 32, 32, FAssociatedIcons[10].Icon);
  FAssociatedIcons[10].SelfIcon := True;
  FAssociatedIcons[10].Size := 32;

  FAssociatedIcons[11].Ext := '.lnk';
  FindIcon(HInstance, 'SIMPLEFILE', 48, 32, FAssociatedIcons[11].Icon); ;
  FAssociatedIcons[11].SelfIcon := True;
  FAssociatedIcons[11].Size := 16;
end;

class function TAIcons.Instance: TAIcons;
begin
  if AIcons = nil then
    AIcons := TAIcons.Create;

  Result := AIcons;
end;

initialization

finalization
  F(AIcons);

end.
