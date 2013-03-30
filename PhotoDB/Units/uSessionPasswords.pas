unit uSessionPasswords;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Data.DB,

  Dmitry.Utils.System,

  UnitINI,
  UnitCrypting,

  uMemory,
  uAppUtils,
  uLogger,
  uCDMappingTypes,
  GraphicCrypt;

type
  TSessionPasswords = class
  private
    FSync: TCriticalSection;
    FINIPasswods: TStrings;
    FPasswodsInSession: TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddForSession(Pass: string);
    procedure ClearSession;

    function FindForFile(FileName: string): string;

    function FindForBlobStream(DF: TField): string;
    procedure SaveInSettings(Pass: string);

    procedure LoadINIPasswords;
    procedure SaveINIPasswords;
    procedure ClearINIPasswords;
    procedure GetPasswordsFromParams;
  end;

function SessionPasswords: TSessionPasswords;

implementation

var
  FSessionPasswords: TSessionPasswords = nil;

function SessionPasswords: TSessionPasswords;
begin
  if FSessionPasswords = nil then
    FSessionPasswords := TSessionPasswords.Create;

  Result := FSessionPasswords;
end;

constructor TSessionPasswords.Create;
begin
  FSync := TCriticalSection.Create;
  FPasswodsInSession := TStringList.Create;
  FINIPasswods := TStringList.Create;

  LoadINIPasswords;
end;

destructor TSessionPasswords.Destroy;
begin
  F(FINIPasswods);
  F(FPasswodsInSession);
  F(FSync);
  inherited;
end;

procedure TSessionPasswords.GetPasswordsFromParams;
var
  PassParam, Pass: string;
begin
  PassParam := GetParamStrDBValue('/AddPass');
  PassParam := AnsiDequotedStr(PassParam, '"');
  for Pass in PassParam.Split(['!']) do
    AddForSession(Pass);
end;

procedure TSessionPasswords.ClearINIPasswords;
begin
  FINIPasswods.Clear;
  SaveINIPasswords;
end;

procedure TSessionPasswords.AddForSession(Pass: String);
var
  I : integer;
begin
  FSync.Enter;
  try
    for I := 0 to FPasswodsInSession.Count - 1 do
      if FPasswodsInSession[I] = Pass then
        Exit;
    FPasswodsInSession.Add(Pass);
  finally
    FSync.Leave;
  end;
end;

procedure TSessionPasswords.ClearSession;
begin
  FSync.Enter;
  try
    FPasswodsInSession.Clear;
  finally
    FSync.Leave;
  end;
end;

function TSessionPasswords.FindForFile(FileName: String): String;
var
  I : Integer;
begin
  Result := '';
  FSync.Enter;
  try
    FileName := ProcessPath(FileName);
    for I := 0 to FPasswodsInSession.Count - 1 do
      if ValidPassInCryptGraphicFile(FileName, FPasswodsInSession[I]) then
      begin
        Result := FPasswodsInSession[I];
        Exit;
      end;
    for I := 0 to FINIPasswods.Count - 1 do
      if ValidPassInCryptGraphicFile(FileName, FINIPasswods[I]) then
      begin
        Result := FINIPasswods[I];
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

function TSessionPasswords.FindForBlobStream(DF : TField): String;
var
  I : Integer;
begin
  Result := '';
  FSync.Enter;
  try
    for I := 0 to FPasswodsInSession.Count - 1 do
      if ValidPassInCryptBlobStreamJPG(DF, FPasswodsInSession[I]) then
      begin
        Result := FPasswodsInSession[I];
        Exit;
      end;
    for I := 0 to FINIPasswods.Count - 1 do
      if ValidPassInCryptBlobStreamJPG(DF, FINIPasswods[I]) then
      begin
        Result := FINIPasswods[I];
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

procedure TSessionPasswords.SaveInSettings(Pass: String);
var
  I: integer;
begin
  FSync.Enter;
  try
    for I := 0 to FINIPasswods.Count - 1 do
      if FINIPasswods[I] = Pass then
        Exit;

     FINIPasswods.Add(Pass);
     SaveINIPasswords;

   finally
     FSync.Leave;
   end;
end;

procedure TSessionPasswords.LoadINIPasswords;
var
  Reg: TBDRegistry;
  S: string;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    try
      F(FINIPasswods);
      Reg.OpenKey(GetRegRootKey, True);
      S := '';
      if Reg.ValueExists('INI') then
          S := Reg.ReadString('INI');

      S := HexStringToString(S);
      if Length(S) > 0 then
        FINIPasswods := DeCryptTStrings(S, 'dbpass')
      else
        FINIPasswods := TStringList.Create;
    except
      on E: Exception do
        EventLog(':TDBKernel::ReadActivateKey() throw exception: ' + E.message);
    end;
  finally
    F(Reg);
  end;
end;

procedure TSessionPasswords.SaveINIPasswords;
var
  Reg: TBDRegistry;
  S: string;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey, True); // todo!
    S := CryptTStrings(FINIPasswods, 'dbpass');
    S := StringToHexString(S);
    Reg.WriteString('INI', S);
  except
    on E: Exception do
      EventLog(':TDBKernel::ReadActivateKey() throw exception: ' + E.message);
  end;
  Reg.Free;
end;

initialization
finalization
  F(FSessionPasswords);

end.
