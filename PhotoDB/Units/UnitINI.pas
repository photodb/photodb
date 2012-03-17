unit UnitINI;

interface

uses
  Windows,
  Registry,
  IniFiles,
  Classes,
  SysUtils,
  uLogger,
  uConstants,
  uMemory,
  uRuntime,
  SyncObjs;

type
  TMyRegistryINIFile = class(TIniFile)
  public
    Key: string;
  end;

type
  TBDRegistry = class(TObject)
  private
    Registry: TObject;
    FReadOnly: Boolean;
    FKey: string;
    FSection: Integer;
  public
    constructor Create(ASection: Integer; readonly: Boolean = False);
    destructor Destroy; override;
    function OpenKey(Key: string; CreateInNotExists: Boolean): Boolean;
    function ReadString(name: string; Default: string = ''): string;
    function ReadInteger(name: string; Default: Integer = 0): Integer;
    function ReadDateTime(name: string; Default: TDateTime = 0): TDateTime;
    function ReadBool(name: string; Default: Boolean = False): Boolean;
    procedure CloseKey;
    procedure GetKeyNames(Strings: TStrings);
    procedure GetValueNames(Strings: TStrings);
    function ValueExists(name: string): Boolean;
    function KeyExists(Key: string): Boolean;
    function DeleteKey(Key: string): Boolean;
    function DeleteValue(name: string): Boolean;
    procedure WriteString(name: string; Value: string);
    procedure WriteBool(name: string; Value: Boolean);
    procedure WriteDateTime(name: string; Value: TDateTime);
    procedure WriteInteger(name: string; Value: Integer);
    property Key: string read FKey;
    property Section: Integer read FSection;
  end;

  TDBRegistryCache = class(TObject)
  private
    FList : TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    procedure Clear;
    destructor Destroy; override;
    function GetSection(ASection : Integer; AKey : string) : TBDRegistry;
  end;

const
  REGISTRY_ALL_USERS    = 0;
  REGISTRY_CURRENT_USER = 1;
  REGISTRY_CLASSES      = 2;

  function GetRegRootKey: string;

implementation

function GetRegRootKey: string;
begin
  Result := RegRoot + cUserData;
end;

function GetRegIniFileName: string;
begin
  Result := ExtractFileDir(ParamStr(0)) + 'Registry.ini';
end;

{ TBDRegistry }

procedure TBDRegistry.CloseKey;
begin
 if Registry is TRegistry then (Registry as TRegistry).CloseKey;
end;

constructor TBDRegistry.Create(ASection: integer; ReadOnly : Boolean = False);
begin
  inherited Create;
  FSection := ASection;
  FKey := '';
  FReadOnly := readonly;
  if PortableWork then
  begin
    Registry := TMyRegistryINIFile.Create(GetRegIniFileName);
  end else
  begin
    if Readonly then
      Registry := TRegistry.Create(KEY_READ)
    else
      Registry := TRegistry.Create(KEY_ALL_ACCESS);
    if ASection = REGISTRY_ALL_USERS then
      (Registry as TRegistry).RootKey := HKEY_INSTALL;
    if ASection = REGISTRY_CLASSES then
      (Registry as TRegistry).RootKey := Windows.HKEY_CLASSES_ROOT;
    if ASection = REGISTRY_CURRENT_USER then
      (Registry as TRegistry).RootKey := HKEY_USER_WORK;
  end;
end;

function TBDRegistry.DeleteKey(Key: String): boolean;
begin
  Result := False;
  if Registry is TRegistry then
    Result := (Registry as TRegistry).DeleteKey(Key);
  if Registry is TMyRegistryINIFile then
  begin
    (Registry as TMyRegistryINIFile).EraseSection(Key);
    Result := True;
  end;
end;

function TBDRegistry.DeleteValue(Name: string): Boolean;
var
  Key: string;
begin
  Result := False;
  if Registry is TRegistry then
    Result := (Registry as TRegistry).DeleteKey(name);
  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    (Registry as TMyRegistryINIFile).DeleteKey(Key, name);
    Result := True;
  end;
end;

destructor TBDRegistry.Destroy;
begin
  F(Registry);
  inherited Destroy;
end;

procedure TBDRegistry.GetKeyNames(Strings: TStrings);
var
  Key, S: string;
  TempStrings: TStrings;
  I: Integer;
begin
  try
    if Registry is TRegistry then
      (Registry as TRegistry).GetKeyNames(Strings);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      TempStrings := TStringList.Create;
      try
        (Registry as TMyRegistryINIFile).ReadSections(TempStrings);
        for I := 0 to TempStrings.Count - 1 do
        begin
          if AnsiLowerCase(Copy(TempStrings[I], 1, Length(Key))) = AnsiLowerCase(Key) then
          begin
            S := TempStrings[I];
            Delete(S, 1, Length(Key) + 1);
            Strings.Add(S)
          end;
        end;
      finally
        F(TempStrings);
      end;
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::GetKeyNames() throw exception: ' + E.message);
  end;
end;

procedure TBDRegistry.GetValueNames(Strings: TStrings);
var
  Key: string;
begin
  try
    if Registry is TRegistry then
      (Registry as TRegistry).GetValueNames(Strings);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      (Registry as TMyRegistryINIFile).ReadSectionValues(Key, Strings);
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::GetValueNames() throw exception: ' + E.message);
  end;
end;

function TBDRegistry.KeyExists(Key: string): Boolean;
begin
  Result := False;
  if Registry is TRegistry then
    Result := (Registry as TRegistry).KeyExists(Key);
  if Registry is TMyRegistryINIFile then
  begin
    Result := (Registry as TMyRegistryINIFile).SectionExists(Key);
  end;
end;

function TBDRegistry.OpenKey(Key: String; CreateInNotExists: Boolean) : boolean;
begin
  FKey := Key;
  Result:=false;
  if Registry is TRegistry then
    Result := (Registry as TRegistry).OpenKey(Key, not FReadOnly);
  if Registry is TMyRegistryINIFile then
  begin
   (Registry as TMyRegistryINIFile).Key := Key;
    Result:=true;
  end;
end;

function TBDRegistry.ReadBool(Name: string; Default: Boolean): Boolean;
var
  Key: string;
begin
  Result := default;
  try
    if Registry is TRegistry then
      Result := (Registry as TRegistry).ReadBool(name);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      Result := (Registry as TMyRegistryINIFile).ReadBool(Key, name, default);
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::ReadBool() throw exception: ' + E.message);
  end;
end;

function TBDRegistry.ReadDateTime(Name: string; Default: TDateTime): TDateTime;
var
  Key: string;
begin
  Result := Default;
  try
    if Registry is TRegistry then
      if (Registry as TRegistry).ValueExists(Name) then
        Result := (Registry as TRegistry).ReadDateTime(Name);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      Result := (Registry as TMyRegistryINIFile).ReadDateTime(Key, name, default);
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::ReadDateTime() throw exception: ' + E.message);
  end;
end;

function TBDRegistry.ReadInteger(Name: string; Default: Integer): Integer;
var
  Key: string;
begin
  Result := default;
  try
    if Registry is TRegistry then
      Result := (Registry as TRegistry).ReadInteger(name);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      Result := (Registry as TMyRegistryINIFile).ReadInteger(Key, name, default);
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::ReadInteger() throw exception: ' + E.message);
  end;
end;

function TBDRegistry.ReadString(Name, Default: string): string;
var
  Key: string;
begin
  Result := default;
  try
    if Registry is TRegistry then
      Result := (Registry as TRegistry).ReadString(name);
    if Registry is TMyRegistryINIFile then
    begin
      Key := (Registry as TMyRegistryINIFile).Key;
      Result := (Registry as TMyRegistryINIFile).ReadString(Key, name, default);
    end;
  except
    on E: Exception do
      EventLog(':TBDRegistry::ReadString() throw exception: ' + E.message);
  end;
end;

function TBDRegistry.ValueExists(Name: string): Boolean;
var
  Key: string;
begin
  Result := False;
  if Registry is TRegistry then
    Result := (Registry as TRegistry).ValueExists(name);
  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    Result := (Registry as TMyRegistryINIFile).ValueExists(Key, name);
  end;
end;

procedure TBDRegistry.WriteBool(Name: string; Value: Boolean);
var
  Key: string;
begin
  if Registry is TRegistry then
    (Registry as TRegistry).WriteBool(name, Value);
  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    (Registry as TMyRegistryINIFile).WriteBool(Key, name, Value);
  end;
end;

procedure TBDRegistry.WriteDateTime(Name: string; Value: TDateTime);
var
  Key: string;
begin
  if Registry is TRegistry then
    (Registry as TRegistry).WriteDateTime(name, Value);
  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    (Registry as TMyRegistryINIFile).WriteDateTime(Key, name, Value);
  end;
end;

procedure TBDRegistry.WriteInteger(Name: string; Value: Integer);
var
  Key: string;
begin
  if Registry is TRegistry then
    (Registry as TRegistry).WriteInteger(name, Value);
  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    (Registry as TMyRegistryINIFile).WriteInteger(Key, name, Value);
  end;
end;

procedure TBDRegistry.WriteString(Name, Value: string);
var
  Key: string;
begin
  if Registry is TRegistry then
    (Registry as TRegistry).WriteString(name, Value);

  if Registry is TMyRegistryINIFile then
  begin
    Key := (Registry as TMyRegistryINIFile).Key;
    (Registry as TMyRegistryINIFile).WriteString(Key, name, Value);
  end;
end;

{ TDBRegistryCache }

procedure TDBRegistryCache.Clear;
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := 0 to FList.Count - 1 do
      TObject(FList[I]).Free;
    FList.Clear;
  finally
    FSync.Leave;
  end;
end;

constructor TDBRegistryCache.Create;
begin
  FList := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TDBRegistryCache.Destroy;
begin
  F(FSync);
  FreeList(FList);
  inherited;
end;

function TDBRegistryCache.GetSection(ASection: Integer; AKey: string): TBDRegistry;
var
  I: Integer;
  Reg: TBDRegistry;
begin
  FSync.Enter;
  try
    for I := 0 to FList.Count - 1 do
    begin
      Reg := FList[I];
      if (Reg.Key = AKey) and (Reg.Section = ASection) then
      begin
        Result := FList[I];
        Exit;
      end;
    end;

    Result := TBDRegistry.Create(ASection);
    Result.OpenKey(AKey, True);
    FList.Add(Result);
  finally
    FSync.Leave;
  end;
end;

end.
