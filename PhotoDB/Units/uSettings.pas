unit uSettings;

interface

uses
  Windows,
  Classes,
  SysUtils,
  uMemory,
  uConstants,
  uConfiguration,
  UnitINI;

type
  TExifSettings = class;

  TAppSettings = class(TObject)
  private
    FRegistryCache: TDBRegistryCache;
    FExifSettings: TExifSettings;
    function GetDataBase: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearCache;
    function ReadProperty(Key, Name: string): string;
    procedure DeleteKey(Key: string);
    procedure WriteProperty(Key, Name, Value: string);
    procedure WriteBool(Key, Name: string; Value: Boolean);
    procedure WriteBoolW(Key, Name: string; Value: Boolean);
    procedure WriteInteger(Key, Name: string; Value: Integer);
    procedure WriteStringW(Key, Name, Value: string);
    procedure WriteString(Key, Name: string; Value: string);
    procedure WriteDateTime(Key, Name: string; Value: TDateTime);
    function ReadKeys(Key: string): TStrings;
    function ReadValues(Key: string): TStrings;
    function ReadBool(Key, Name: string; Default: Boolean): Boolean;
    function ReadRealBool(Key, Name: string; Default: Boolean): Boolean;
    function ReadBoolW(Key, Name: string; Default: Boolean): Boolean;
    function ReadInteger(Key, Name: string; Default: Integer): Integer;
    function ReadString(Key, Name: string; Default: string = ''): string;
    function ReadStringW(Key, Name: string; Default: string = ''): string;
    function ReadDateTime(Key, Name: string; Default: TDateTime): TDateTime;
    procedure IncrementInteger(Key, Name: string);
    function GetSection(Key: string; ReadOnly: Boolean): TBDRegistry;
    procedure DeleteValues(Key: string);
    property DataBase: string read GetDataBase;
    property Exif: TExifSettings read FExifSettings;
  end;

  TSettingsNode = class(TObject)
  private
    FInfoAvailable: Boolean;
    procedure Init(Force: Boolean = False);
  protected
    procedure ReadSettings; virtual; abstract;
  public
    constructor Create;
  end;

  TExifSettings = class(TSettingsNode)
  private
    FReadInfoFromExif: Boolean;
    FSaveInfoToExif: Boolean;
    FUpdateExifInfoInBackground: Boolean;
    function GetReadInfoFromExif: Boolean;
    procedure SetReadInfoFromExif(const Value: Boolean);
    function GetSaveInfoToExif: Boolean;
    procedure SetSaveInfoToExif(const Value: Boolean);
    function GetUpdateExifInfoInBackground: Boolean;
    procedure SetUpdateExifInfoInBackground(const Value: Boolean);
  protected
    procedure ReadSettings; override;
  public
    property ReadInfoFromExif: Boolean read GetReadInfoFromExif write SetReadInfoFromExif;
    property SaveInfoToExif: Boolean read GetSaveInfoToExif write SetSaveInfoToExif;
    property UpdateExifInfoInBackground: Boolean read GetUpdateExifInfoInBackground write SetUpdateExifInfoInBackground;
  end;

function AppSettings: TAppSettings;
function GetAppDataDirectoryFromSettings: string;

implementation

var
  FSettings: TAppSettings = nil;

function AppSettings: TAppSettings;
begin
  if FSettings = nil then
    FSettings := TAppSettings.Create;

  Result := FSettings;
end;

function GetAppDataDirectoryFromSettings: string;
begin
  Result := AppSettings.ReadString('Settings', 'AppData');
  if Result = '' then
  begin
    Result :=GetAppDataDirectory;
    AppSettings.WriteString('Settings', 'AppData', Result);
  end;
end;

function TAppSettings.Readbool(Key, Name: string; Default: Boolean): Boolean;
var
  Reg: TBDRegistry;
  Value: string;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Value := AnsiLowerCase(Reg.ReadString(Name));
  if Value = 'true' then
    Result := True;
  if Value = 'false' then
    Result := False;
end;

function TAppSettings.ReadRealBool(Key, Name: string; Default: Boolean): Boolean;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Result := Reg.ReadBool(Name);
end;

function TAppSettings.ReadboolW(Key, Name: string; Default: Boolean): Boolean;
var
  Reg: TBDRegistry;
  Value : string;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, True);
  Value := AnsiLowerCase(Reg.ReadString(Name));
  if Value = 'true' then
    Result := True;
  if Value = 'false' then
    Result := False;
end;

function TAppSettings.ReadInteger(Key, Name: string; Default: Integer): Integer;
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Result := StrToIntDef(Reg.ReadString(Name), Default);
end;

function TAppSettings.ReadDateTime(Key, Name : string; Default: TDateTime): TDateTime;
var
  Reg: TBDRegistry;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  if Reg.ValueExists(Name) then
    Result:=Reg.ReadDateTime(Name);
end;

function TAppSettings.ReadProperty(Key, Name: string): string;
var
  Reg: TBDRegistry;
begin
  Result := '';
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, True);
  Result := Reg.ReadString(Name);
end;

function TAppSettings.ReadKeys(Key: string): TStrings;
var
  Reg: TBDRegistry;
begin
  Result := TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Reg.GetKeyNames(Result);
end;

function TAppSettings.ReadValues(Key: string): TStrings;
var
  Reg: TBDRegistry;
begin
  Result := TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Reg.GetValueNames(Result);
end;

procedure TAppSettings.DeleteValues(Key: string);
var
  Reg: TBDRegistry;
  I: Integer;
  Result: TStrings;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Result := TStringList.Create;
    try
      Reg.OpenKey(GetRegRootKey + Key, True);
      Reg.GetValueNames(Result);
      for I := 0 to Result.Count - 1 do
        Reg.DeleteValue(Result[I]);
    finally
      F(Result);
    end;
  finally
    F(Reg);
  end;
end;

procedure TAppSettings.ClearCache;
begin
  FRegistryCache.Clear;
  FExifSettings.Init(True);
end;

constructor TAppSettings.Create;
begin
  FRegistryCache := TDBRegistryCache.Create;
  FExifSettings := TExifSettings.Create;
end;

destructor TAppSettings.Destroy;
begin
  F(FRegistryCache);
  F(FExifSettings);
  inherited;
end;

procedure TAppSettings.DeleteKey(Key: string);
var
  Reg: TBDRegistry;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.DeleteKey(GetRegRootKey + Key);
  finally;
    F(Reg);
  end;
end;

function TAppSettings.ReadString(Key, Name: string; Default: string = ''): string;
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, True);
  Result := Reg.ReadString(name);
  if Result = '' then
    Result := Default;
end;

function TAppSettings.ReadStringW(Key, Name: string; Default: string = ''): string;
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, True);
  Result := Reg.ReadString(Name);
  if Result = '' then
    Result := Default;
end;

procedure TAppSettings.WriteBool(Key, name: string; Value: Boolean);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, False);
  if Value then
    Reg.WriteString(name, 'True')
  else
    Reg.WriteString(name, 'False');
end;

procedure TAppSettings.WriteBoolW(Key, Name: string; Value: Boolean);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, False);
  if Value then
    Reg.WriteString(Name, 'True')
  else
    Reg.WriteString(Name, 'False');
end;

procedure TAppSettings.WriteInteger(Key, Name: string; Value: Integer);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, False);
  Reg.WriteString(Name, IntToStr(Value));
end;

procedure TAppSettings.WriteProperty(Key, Name, Value: string);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, False);
  Reg.WriteString(Name, Value);
end;

procedure TAppSettings.WriteString(Key, Name, Value: string);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, False);
  Reg.WriteString(Name, Value);
end;

procedure TAppSettings.WriteStringW(Key, Name, value: string);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key, False);
  Reg.WriteString(Name, Value);
end;

procedure TAppSettings.WriteDateTime(Key, Name : String; Value: TDateTime);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, False);
  Reg.WriteDateTime(Name, Value);
end;

function TAppSettings.GetDataBase: string;
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot, True);
  Result := Reg.ReadString('DBDefaultName');
end;

function TAppSettings.GetSection(Key: string; ReadOnly: Boolean): TBDRegistry;
begin
  Result := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot, ReadOnly);
end;

procedure TAppSettings.IncrementInteger(Key, Name: string);
var
  Reg: TBDRegistry;
  SValue: string;
  Value: Integer;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key, False);
  SValue := Reg.ReadString(Name);
  Value := StrToIntDef(SValue, 0);
  Inc(Value);
  Reg.WriteString(Name, IntToStr(Value));
end;

{ TExifSettings }

function TExifSettings.GetReadInfoFromExif: Boolean;
begin
  Init;
  Result := FReadInfoFromExif;
end;

procedure TExifSettings.SetReadInfoFromExif(const Value: Boolean);
begin
  FReadInfoFromExif := Value;
  AppSettings.WriteBool('EXIF', 'ReadInfoFromExif', Value);
end;

function TExifSettings.GetSaveInfoToExif: Boolean;
begin
  Init;
  Result := FSaveInfoToExif;
end;

procedure TExifSettings.SetSaveInfoToExif(const Value: Boolean);
begin
  FSaveInfoToExif := Value;
  AppSettings.WriteBool('EXIF', 'SaveInfoToExif', Value);
end;

function TExifSettings.GetUpdateExifInfoInBackground: Boolean;
begin
  Init;
  Result := FUpdateExifInfoInBackground;
end;

procedure TExifSettings.SetUpdateExifInfoInBackground(const Value: Boolean);
begin
  FUpdateExifInfoInBackground := Value;
  AppSettings.WriteBool('EXIF', 'UpdateExifInfoInBackground', Value);
end;

procedure TExifSettings.ReadSettings;
begin
  FReadInfoFromExif := AppSettings.ReadBool('EXIF', 'ReadInfoFromExif', True);
  FSaveInfoToExif := AppSettings.ReadBool('EXIF', 'SaveInfoToExif', True);
  FUpdateExifInfoInBackground := AppSettings.ReadBool('EXIF', 'UpdateExifInfoInBackground', True);
end;

{ TSettingsNode }

constructor TSettingsNode.Create;
begin
  FInfoAvailable := False;
end;

procedure TSettingsNode.Init(Force: Boolean = False);
begin
  if not FInfoAvailable or Force then
    ReadSettings;
end;

initialization

finalization

  F(FSettings);

end.
