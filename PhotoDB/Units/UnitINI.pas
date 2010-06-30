unit UnitINI;

interface

uses Windows, Registry, IniFiles, Classes, SysUtils, uLogger, uConstants,
     UnitDBCommon;

type
  TMyRegistryINIFile = class(TIniFile)
   public Key : string;
  end;

type
  TBDRegistry = class(TObject)
  private
    Registry : TObject;
    FReadOnly : Boolean;
    FKey : string;
    FSection : Integer;
  public
    constructor Create(ASection : integer; ReadOnly : Boolean = false);
    destructor Destroy; override;
    function OpenKey(Key : String; CreateInNotExists : Boolean) : boolean;
    function ReadString(Name : String; Default : string = '') : string;
    function ReadInteger(Name : String; Default : Integer = 0) : Integer;
    function ReadDateTime(Name : String; Default : TDateTime = 0) : TDateTime;
    procedure CloseKey;
    procedure GetKeyNames(Strings : TStrings);
    procedure GetValueNames(Strings : TStrings);
    function ValueExists(Name : String) : boolean;
    function KeyExists(Key : String) : boolean;
    function ReadBool(Name : String; Default : boolean = false) : boolean;
    function DeleteKey(Key : String) : boolean;
    function DeleteValue(Name : String) : boolean;
    procedure WriteString(Name : String; Value : String);
    procedure WriteBool(Name : String; Value : boolean);
    procedure WriteDateTime(Name : String; Value : TDateTime);  
    procedure WriteInteger(Name : String; Value : Integer);
    property Key : string read FKey;
    property Section : Integer read FSection;
  end;

  TDBRegistryCache = class(TObject)
  private
    FList : TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetSection(ASection : Integer; AKey : string) : TBDRegistry;
  end;

function StringToHexString(text : String) : string;
function HexStringToString(text : String) : string;

const
  REGISTRY_ALL_USERS    = 0;
  REGISTRY_CURRENT_USER = 1;
  REGISTRY_CLASSES      = 2;

var
  PortableWork : boolean = false;

  function GetRegRootKey: string;

implementation

function StringToHexString(text : String) : string;
var
  i : integer;
  str : string;
begin
 Result:='';
 for i:=1 to Length(text) do
 begin
  str:=IntToHex(Ord(text[i]),2);
  Result:=Result+str;
 end;
end;

function HexStringToString(text : String) : string;
var
  i : integer;
  c : byte;
  str : string;
begin
 Result:='';
 for i:=1 to Length(text) div 2 do
 begin
  str:=Copy(text,(i-1)*2+1,2);
  c:=HexToIntDef(str,0);
  Result:=Result+Chr(c);
 end;
end;

function GetRegRootKey: string;
begin
 Result:=RegRoot+'UserData\';
end;

function GetRegIniFileName : string;
begin
  Result := ExtractFileDir(ParamStr(0))+'Registry.ini';
end;

{ TBDRegistry }

procedure TBDRegistry.CloseKey;
begin
 if Registry is TRegistry then (Registry as TRegistry).CloseKey;
end;

constructor TBDRegistry.Create(ASection: integer; ReadOnly : Boolean = false);
begin
 inherited Create;
 FSection := ASection;
 FKey := '';
 FReadOnly:=ReadOnly;
 If PortableWork then
 begin
  Registry:=TMyRegistryINIFile.Create(GetRegIniFileName);
 end else
 begin
  if ReadOnly then
  Registry:=TRegistry.Create(KEY_READ) else
  Registry:=TRegistry.Create(KEY_ALL_ACCESS);
  if ASection = REGISTRY_ALL_USERS then (Registry as TRegistry).RootKey := HKEY_INSTALL;
  if ASection = REGISTRY_CLASSES then (Registry as TRegistry).RootKey := windows.HKEY_CLASSES_ROOT;
  if ASection = REGISTRY_CURRENT_USER then (Registry as TRegistry).RootKey := HKEY_USER_WORK;
 end;
end;

function TBDRegistry.DeleteKey(Key: String): boolean;
begin
 Result:=false;
 if Registry is TRegistry then Result:=(Registry as TRegistry).DeleteKey(Key);
 if Registry is TMyRegistryINIFile then
 begin
  (Registry as TMyRegistryINIFile).EraseSection(Key);
  Result:=true;
 end;
end;

function TBDRegistry.DeleteValue(Name: String): boolean;
var
  Key : string;
begin   
 Result:=false;
 if Registry is TRegistry then Result:=(Registry as TRegistry).DeleteKey(Name);
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  (Registry as TMyRegistryINIFile).DeleteKey(Key,Name);   
  Result:=true;
 end;
end;

destructor TBDRegistry.Destroy;
begin
 Registry.Free;
 inherited Destroy;
end;

procedure TBDRegistry.GetKeyNames(Strings: TStrings);
var
  Key, s : string;
  TempStrings : TStrings;
  i : integer;
begin
 try
  if Registry is TRegistry then (Registry as TRegistry).GetKeyNames(Strings);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   TempStrings:=TStringList.Create;
   (Registry as TMyRegistryINIFile).ReadSections(TempStrings);
   for i:=0 to TempStrings.Count-1 do
   begin
    if AnsiLowerCase(Copy(TempStrings[i],1,Length(Key))) = AnsiLowerCase(Key) then
    begin
     s:=TempStrings[i];
     Delete(s,1,Length(Key)+1);
     Strings.Add(s)
    end;
   end;
   TempStrings.Free;
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::GetKeyNames() throw exception: '+e.Message);
 end;
end;

procedure TBDRegistry.GetValueNames(Strings: TStrings);
var
  Key : string;
begin
 try
  if Registry is TRegistry then (Registry as TRegistry).GetValueNames(Strings);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   (Registry as TMyRegistryINIFile).ReadSectionValues(Key,Strings);
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::GetValueNames() throw exception: '+e.Message);
 end;
end;

function TBDRegistry.KeyExists(Key: String): boolean;
begin
 Result:=false;
 if Registry is TRegistry then Result:=(Registry as TRegistry).KeyExists(Key);
 if Registry is TMyRegistryINIFile then
 begin
  Result:=(Registry as TMyRegistryINIFile).SectionExists(Key);
 end;
end;

function TBDRegistry.OpenKey(Key: String; CreateInNotExists: Boolean) : boolean;
begin
  FKey := Key;
  Result:=false;
  if Registry is TRegistry then Result:=(Registry as TRegistry).OpenKey(Key, not FReadOnly);
  if Registry is TMyRegistryINIFile then
  begin
   (Registry as TMyRegistryINIFile).Key:=Key;
    Result:=true;
  end;
end;

function TBDRegistry.ReadBool(Name: String; Default: boolean): boolean;
var
  Key : string;
begin
 try
  Result:=Default;
  if Registry is TRegistry then Result:=(Registry as TRegistry).ReadBool(Name);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   Result:=(Registry as TMyRegistryINIFile).ReadBool(Key,Name,Default);
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::ReadBool() throw exception: '+e.Message);
 end;
end;

function TBDRegistry.ReadDateTime(Name: String;
  Default: TDateTime): TDateTime;
var
  Key : string;
begin      
 try
  Result:=Default;
  if Registry is TRegistry then Result:=(Registry as TRegistry).ReadDateTime(Name);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   Result:=(Registry as TMyRegistryINIFile).ReadDateTime(Key,Name,Default);
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::ReadDateTime() throw exception: '+e.Message);
 end;
end;

function TBDRegistry.ReadInteger(Name: String; Default: Integer): Integer;
var
  Key : string;
begin
 Result:=Default;
 try
  if Registry is TRegistry then Result:=(Registry as TRegistry).ReadInteger(Name);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   Result:=(Registry as TMyRegistryINIFile).ReadInteger(Key,Name,Default);
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::ReadInteger() throw exception: '+e.Message);
 end;
end;

function TBDRegistry.ReadString(Name, Default: string): string;
var
  Key : string;
begin
 Result:=Default;
 try
  if Registry is TRegistry then Result:=(Registry as TRegistry).ReadString(Name);
  if Registry is TMyRegistryINIFile then
  begin
   Key:=(Registry as TMyRegistryINIFile).Key;
   Result:=(Registry as TMyRegistryINIFile).ReadString(Key,Name,Default);
  end;
 except
  on e : Exception do EventLog(':TBDRegistry::ReadString() throw exception: '+e.Message);
 end;
end;

function TBDRegistry.ValueExists(Name: String): boolean;
var
  Key : string;
begin        
 Result:=false;
 if Registry is TRegistry then Result:=(Registry as TRegistry).ValueExists(Name);
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  Result:=(Registry as TMyRegistryINIFile).ValueExists(Key,Name);
 end;
end;

procedure TBDRegistry.WriteBool(Name: String; Value: boolean);
var
  Key : string;
begin
 if Registry is TRegistry then (Registry as TRegistry).WriteBool(Name,Value);
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  (Registry as TMyRegistryINIFile).WriteBool(Key,Name,Value);
 end;
end;

procedure TBDRegistry.WriteDateTime(Name: String; Value: TDateTime);
var
  Key : string;
begin
 if Registry is TRegistry then (Registry as TRegistry).WriteDateTime(Name,Value);
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  (Registry as TMyRegistryINIFile).WriteDateTime(Key,Name,Value);
 end;
end;

procedure TBDRegistry.WriteInteger(Name: String; Value: Integer);
var
  Key : string;
begin
 if Registry is TRegistry then (Registry as TRegistry).WriteInteger(Name,Value);
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  (Registry as TMyRegistryINIFile).WriteInteger(Key,Name,Value);
 end;
end;

procedure TBDRegistry.WriteString(Name, Value: String);
var
  Key : string;
begin
 if Registry is TRegistry then
 begin
  (Registry as TRegistry).WriteString(Name,Value);
 end;
 if Registry is TMyRegistryINIFile then
 begin
  Key:=(Registry as TMyRegistryINIFile).Key;
  (Registry as TMyRegistryINIFile).WriteString(Key,Name,Value);
 end;
end;

{ TDBRegistryCache }

constructor TDBRegistryCache.Create;
begin
  FList := TList.Create;
end;

destructor TDBRegistryCache.Destroy;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TBDRegistry(FList[I]).Free;
  FList.Free;
  inherited;
end;

function TDBRegistryCache.GetSection(ASection : Integer; AKey : string): TBDRegistry;
var
  I : Integer;
  Reg : TBDRegistry;
begin
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
end;

end.
