unit UnitDBKernel;

interface

uses
  Winapi.Windows,
  Winapi.ShellApi,
  Winapi.CommCtrl,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  System.Win.ComObj,
  Data.DB,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ImgList,

  UnitDBDeclare,
  GraphicCrypt,
  CommonDBSupport,
  UnitINI,

  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,

  uMemory,
  uShellIntegration,
  uLogger,
  uCDMappingTypes,
  uConstants,
  uTime,
  uAppUtils,
  uTranslate,
  uDBForm,
  uRuntime,
  uDBBaseTypes,
  uStringUtils,
  uSettings,
  uImageListUtils,
  uProgramStatInfo,
  uVCLHelpers;

type
  DBChangesIDEvent = procedure(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues) of object;

type
  DBEventsIDArray = record
    Sender: TObject;
    IDs: Integer;
    DBChangeIDArrayesEvents: DBChangesIDEvent;
  end;

type
  TDBEventsIDArray = array of DBEventsIDArray;

const
  IconsCount = 129;
const
  IconsVersion = '1_1';

type
  TDbKernelArrayIcons = array [1 .. IconsCount] of THandle;

type
  TDBKernel = class(TObject)
  private
    { Private declarations }
    FINIPasswods: TStrings;
    FPasswodsInSession: TStrings;
    FEvents: TDBEventsIDArray;
    FImageList: TCustomImageList;
    FDisabledImageList: TCustomImageList;
    FForms: TList;
    FApplicationKey: string;
    ThreadOpenResultBool: Boolean;
    ThreadOpenResultWork: Boolean;
    FDBs: TPhotoDBFiles;
    FImageOptions: TImageDBOptions;
    FSych: TCriticalSection;
    procedure LoadDBs;
    function GetSortGroupsByName: Boolean;
    procedure HandleError(E: Exception);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    property DBs: TPhotoDBFiles read FDBs;
    property ImageList: TCustomImageList read FImageList;
    property DisabledImageList: TCustomImageList read FDisabledImageList;
    procedure UnRegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure UnRegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure RegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure UnRegisterChangesIDBySender(Sender: TObject);
    procedure RegisterChangesIDbyID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure DoIDEvent(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
    function TestDB(DBName_: string; OpenInThread: Boolean = False): Boolean;
    procedure BackUpTable;
    procedure DBInit;
    function CreateDBbyName(FileName: string): Integer;
    function GetDataBaseName: string;
    procedure SetDataBase(DatabaseFileName: string);
    procedure AddTemporaryPasswordInSession(Pass: string);
    function FindPasswordForCryptImageFile(FileName: string): string;
    procedure ClearTemporaryPasswordsInSession;
    function FindPasswordForCryptBlobStream(DF: TField): string;
    procedure SavePassToINIDirectory(Pass: string);
    procedure LoadINIPasswords;
    procedure SaveINIPasswords;
    procedure ClearINIPasswords;
    procedure ThreadOpenResult(Result: Boolean);
    procedure AddDB(DBName, DBFile, DBIco: string; Force: Boolean = False);
    function RenameDB(OldDBName, NewDBName: string): Boolean;
    function DeleteDB(DBName: string): Boolean;
    function TestDBEx(DBName_: string; OpenInThread: Boolean = False): Integer;
    function StringDBVersion(DBVersion: Integer): string;
    procedure MoveDB(OldDBFile, NewDBFile: string);
    function DBExists(DBName: string): Boolean;
    function NewDBName(DBNamePattern: string): string;
    function ValidDBVersion(DBFile: string; DBVersion: Integer): Boolean;
    procedure ReadDBOptions;
    procedure DoSelectDB;
    procedure GetPasswordsFromParams;
    procedure LoadIcons;
    property ImageOptions: TImageDBOptions read FImageOptions;
    property SortGroupsByName : Boolean read GetSortGroupsByName;
  end;

  TDBIcons = class(TObject)
  private
    FIcons: TDbKernelArrayIcons;
    function GetIconByIndex(Index: Integer): HIcon;
  public
    constructor Create;
    destructor Destroy; override;
    property Icons[Index: Integer]: HIcon read GetIconByIndex; default;
  end;

var
  DBKernel: TDBKernel = nil;   
                 
function Icons: TDBIcons;

implementation

uses
  UnitCrypting,
  UnitActiveTableThread, 
  UnitFileCheckerDB,
  UnitBackUpTableInCMD;

var
  FIcons: TDBIcons = nil;

function Icons: TDBIcons;
begin
  if FIcons = nil then
    FIcons := TDBIcons.Create;

  Result := FIcons;
end;

{ TDBKernel }

constructor TDBKernel.Create;
begin
  inherited;
  FDBs := nil;
  FImageOptions := nil;
  FImageList := nil;
  FDisabledImageList := nil;
  FSych := TCriticalSection.Create;
  FForms := TList.Create;
  LoadDBs;
  FPasswodsInSession := TStringList.create;
  FINIPasswods := nil;
  FApplicationKey := '';
end;

function TDBKernel.CreateDBbyName(FileName: string): Integer;
begin
  Result := 0;
  CreateDirA(ExtractFileDir(FileName));
  try
    if FileExistsSafe(FileName) then
      DeleteFile(FileName);

    if FileExistsSafe(FileName) then
    begin
      Result := 1;
      Exit;
    end;
    Result := 1;

    if GetDBType(FileName) = DB_TYPE_MDB then
    begin
      if ADOCreateImageTable(FileName) then
        Result := 0;
      ADOCreateSettingsTable(FileName);
    end;

  except
    on E: Exception do
    begin
      HandleError(E);
      EventLog(':TDBKernel::CreateDBbyName() throw exception: ' + E.message);
      Exit;
    end;
  end;

  ProgramStatistics.DBUsed;
end;

destructor TDBKernel.Destroy;
begin
  F(FImageList);
  F(FDisabledImageList);
  F(FINIPasswods);
  F(FPasswodsInSession);
  F(FSych);
  F(FForms);
  F(FDBs);
  F(FImageOptions);
  inherited;
end;

procedure TDBKernel.DoIDEvent(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
var
  I: Integer;
  FXevents: TDBEventsIDArray;
begin
  if Sender = nil then
    raise Exception.Create('Sender is null!');

  if GetCurrentThreadId <> MainThreadID then
    raise Exception.Create('DoIDEvent call not from main thread! Sender: ' + Sender.ClassName);

  if Length(Fevents) = 0 then
    Exit;

  SetLength(FXevents, Length(Fevents));
  for I := 0 to Length(Fevents) - 1 do
    FXevents[I] := Fevents[I];
  for I := 0 to Length(FXevents) - 1 do
  begin
    if FXevents[I].Ids = -1 then
    begin
      if Assigned(FXevents[I].DBChangeIDArrayesEvents) then
        FXevents[I].DBChangeIDArrayesEvents(Sender, ID, Params, Value)
    end else
    begin
      if FXevents[I].Ids = ID then
      begin
        if Assigned(FXevents[I].DBChangeIDArrayesEvents) then
          FXevents[I].DBChangeIDArrayesEvents(Sender, ID, Params, Value)
      end;
    end;
  end;
end;

procedure TDBKernel.DBInit;
begin
  DoSelectDB;
  LoadINIPasswords;
end;

procedure TDBKernel.RegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
var
  I: Integer;
  Is_: Boolean;
begin
  Is_ := False;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = -1) and (Sender = Fevents[I].Sender) then
    begin
      Is_ := True;
      Break;
    end;
  if not Is_ then
  begin
    Setlength(Fevents, Length(Fevents) + 1);
    Fevents[Length(Fevents) - 1].Ids := -1;
    Fevents[Length(Fevents) - 1].Sender := Sender;
    Fevents[Length(Fevents) - 1].DBChangeIDArrayesEvents := Event_;
  end;
end;

procedure TDBKernel.RegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
var
  I: Integer;
  Is_: Boolean;
begin
  Is_ := False;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = Id) and (Sender = Fevents[I].Sender) then
    begin
      Is_ := True;
      Break;
    end;
  if not Is_ then
  begin
    Setlength(Fevents, Length(Fevents) + 1);
    Fevents[Length(Fevents) - 1].Ids := Id;
    Fevents[Length(Fevents) - 1].Sender := Sender;
    Fevents[Length(Fevents) - 1].DBChangeIDArrayesEvents := Event_;
  end;
end;

function TDBKernel.TestDB(DBName_: string; OpenInThread: Boolean = False): Boolean;
begin
  Result := ValidDBVersion(DBName_, TestDBEx(DBName_, OpenInThread));
end;

function TDBKernel.TestDBEx(DBName_: string; OpenInThread: Boolean = False): Integer;
var
  FTestTable: TDataSet;
  ActiveOk: Boolean;
begin
  // Fast test -> in thread load db query
  Result := 0;
  TW.I.Start('TestDBEx -> FileExistsSafe');
  if not FileExistsSafe(DBName_) then
  begin
    Result := -1;
    Exit;
  end;
  FTestTable := nil;
  try
    TW.I.Start('TestDBEx -> GetDBType');
    if (GetDBType(DBName_) = DB_TYPE_MDB) and (GetFileSizeByName(DBName_) > 500 * 1025) then
    begin
      TW.I.Start('TestDBEx -> GetQuery');
      FTestTable := GetQuery(DBName_, True);
      ForwardOnlyQuery(FTestTable);

      TW.I.Start('TestDBEx -> SetSQL');
      SetSQL(FTestTable, 'Select TOP 1 * From ImageTable');
      try
        FTestTable.Open;
      except
        on E: Exception do
        begin
          EventLog(':TDBKernel::TestDBEx()/Open throw exception: ' + E.message);
          Result := -2;
          Exit;
        end;
      end;
    end;
    TW.I.Start('TestDBEx -> FTestTable.Active');
    if FTestTable <> nil then
      if FTestTable.Active then
        if FTestTable.RecordCount = 0 then
        begin
          FreeDS(FTestTable);
          TW.I.Start('TestDBEx -> FTestTable.GetTable');
          FTestTable := GetTable(DBName_, DB_TABLE_IMAGES);
        end;

    TW.I.Start('TestDBEx -> FTestTable = nil');
    if FTestTable = nil then
      FTestTable := GetTable(DBName_, DB_TABLE_IMAGES);

    if FTestTable = nil then
      Exit;

    TW.I.Start('TestDBEx -> !FTestTable.Active');
    if not(FTestTable.Active) then
    begin
      if OpenInThread then
      begin
        ThreadOpenResultWork := False;
        TActiveTableThread.Create(FTestTable, True, ThreadOpenResult);
        repeat
          Application.ProcessMessages;
          CheckSynchronize;
          Sleep(10);
        until ThreadOpenResultBool;
        ActiveOk := ThreadOpenResultBool;
      end else
        ActiveOk := ActiveTable(FTestTable, True);
      if not ActiveOk then
      begin
        Result := -3;
        Exit;
      end;
    end;

    try
      FTestTable.First;
      FTestTable.FieldByName('ID').AsInteger;
      if FTestTable.FindField('Name') = nil then
      begin
        Result := -4;
        Exit;
      end;
      FTestTable.FieldByName('Name').AsString;
      if FTestTable.FindField('FFilename') = nil then
      begin
        Result := -5;
        Exit;
      end;
      FTestTable.FieldByName('FFilename').AsString;
      FTestTable.FieldByName('StrTh').AsString;
      FTestTable.FieldByName('Comment').AsString;
      FTestTable.FieldByName('KeyWords').AsString;
      FTestTable.FieldByName('Rating').AsInteger;
      FTestTable.FieldByName('Attr').AsInteger;
      FTestTable.FieldByName('Access').AsInteger;
      FTestTable.FieldByName('Owner').AsString;
      FTestTable.FieldByName('Collection').AsString;
      FTestTable.FieldByName('FileSize').AsInteger;
      FTestTable.FieldByName('Width').AsInteger;
      FTestTable.FieldByName('Height').AsInteger;
      FTestTable.FieldByName('Rotated').AsInteger;
      Result := DB_VER_1_8;
      // Added in PhotoDB v1.9
      if FTestTable.FindField('Include') = nil then
        Exit;

      FTestTable.FindField('Include').AsBoolean;
      if FTestTable.FindField('Links') = nil then
        Exit;

      FTestTable.FindField('Links').AsString;
      Result := DB_VER_1_9;
      if FTestTable.FindField('aTime') = nil then
        Exit;

      FTestTable.FindField('aTime').AsDateTime;
      if FTestTable.FindField('IsTime') = nil then
        Exit;


      Result := DB_VER_2_0;
      if (GetDBType(DBName_) = DB_TYPE_MDB) then
        if FTestTable.FindField('FolderCRC') = nil then
        Exit;

      if (GetDBType(DBName_) = DB_TYPE_MDB) then
        if FTestTable.FindField('StrThCRC') = nil then
        Exit;

    except
      on E: Exception do
      begin
        EventLog(':TDBKernel::TestDBEx() throw exception: ' + E.message);
        Result := -6;
        Exit;
      end;
    end;
  finally
    FreeDS(FTestTable);
  end;
  if (GetDBType(DBName_) = DB_TYPE_MDB) then
  begin
    Result := DB_VER_2_1;
    FTestTable := nil;
    try
      try
        FTestTable := GetTable(DBName_, DB_TABLE_SETTINGS);
        FTestTable.Open;
      except
        on E: Exception do
        begin
          EventLog(':TDBKernel::TestDBEx()/DB_TABLE_SETTINGS throw exception: ' + E.message);
          Exit;
        end;
      end;
      if FTestTable <> nil then
      begin
        if FTestTable.RecordCount > 0 then
        begin
          FTestTable.First;
          if FTestTable.FindField('Version') = nil then
            Exit;
          if FTestTable.FindField('DBJpegCompressionQuality') = nil then
            Exit;
          if FTestTable.FindField('ThSizePanelPreview') = nil then
            Exit;
          if FTestTable.FindField('ThImageSize') = nil then
            Exit;
          if FTestTable.FindField('ThHintSize') = nil then
            Exit;

          try
            FTestTable.FieldByName('Version').AsInteger;
            FTestTable.FieldByName('DBJpegCompressionQuality').AsString;
            FTestTable.FieldByName('ThSizePanelPreview').AsInteger;
            FTestTable.FieldByName('ThImageSize').AsInteger;
            FTestTable.FieldByName('ThHintSize').AsInteger;
          except
            on E: Exception do
            begin
              EventLog(':TDBKernel::TestDBEx()/DB_TABLE_SETTINGS throw exception: ' + E.message);
              Exit;
            end;
          end;
          Result := DB_VER_2_2;
          if FTestTable.FieldByName('Version').AsInteger = 2 then
            Result := DB_VER_2_3;
        end;
      end;
    finally
      FreeDS(FTestTable);
    end;
  end;

  FreeDS(FTestTable);
end;

procedure TDBKernel.UnRegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
var
  I, J: Integer;
begin
  if Length(Fevents) = 0 then
    Exit;
  for I := 0 to Length(Fevents) - 1 do
  begin
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = -1) and (Sender = Fevents[I].Sender) then
    begin
      for J := I to Length(Fevents) - 2 do
        Fevents[J] := Fevents[J + 1];
      SetLength(Fevents, Length(Fevents) - 1);
      Break;
    end;
  end;
end;

procedure TDBKernel.UnRegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
var
  I, J: Integer;
begin
  if Length(Fevents) = 0 then
    Exit;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = Id) and (Sender = Fevents[I].Sender) then
    begin
      for J := I to Length(Fevents) - 2 do
        Fevents[J] := Fevents[J + 1];
      SetLength(Fevents, Length(Fevents) - 1);
      Break;
    end;
end;

procedure TDBKernel.UnRegisterChangesIDBySender(Sender: TObject);
var
  I, J, K: Integer;
begin
  if Length(Fevents) = 0 then
    Exit;
  for K := 0 to Length(Fevents) - 1 do
    for I := 0 to Length(Fevents) - 1 do
      if (Sender = Fevents[I].Sender) then
      begin
        for J := I to Length(Fevents) - 2 do
          Fevents[J] := Fevents[J + 1];
        SetLength(Fevents, Length(Fevents) - 1);
        Break;
      end;
end;

function TDBKernel.GetDataBaseName: string;
var
  I: Integer;
begin
  for I := 0 to FDBs.Count - 1 do
    if AnsiLowerCase(FDBs[I].FileName) = AnsiLowerCase(DBName) then
    begin
      Result := FDBs[I].Name;
    end;

  if Result = '' then
    Result := GetFileNameWithoutExt(DBName);

  if Result = '' then
    Result := TA('Unknown DB', 'System');
end;

procedure TDBKernel.SetDataBase(DatabaseFileName: string);
var
  Reg: TBDRegistry;
begin
  if not FileExistsSafe(DatabaseFileName) then
    Exit;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    try
      Reg.OpenKey(RegRoot, True);
      Reg.WriteString('DBDefaultName', DatabaseFileName);
    except
      on E: Exception do
        EventLog(':TDBKernel::SetDataBase() throw exception: ' + E.message);
    end;
    Dbname := DatabaseFileName;
  finally
    F(Reg);
  end;
  ReadDBOptions;
end;

procedure TDBKernel.BackUpTable;
var
   Options: TBackUpTableThreadOptions;
begin
  if FolderView then
    Exit;

  if Now - Settings.ReadDateTime('Options', 'BackUpDateTime', 0) > Settings.ReadInteger('Options', 'BackUpdays', 7) then
  begin
    Options.WriteLineProc := nil;
    Options.WriteLnLineProc := nil;
    Options.OnEnd := nil;
    Options.FileName := DBName;
    Options.OwnerForm := nil;
    BackUpTableInCMD.Create(Options);

    Settings.WriteBool('StartUp', 'BackUp', False);
  end;
end;

procedure TDBKernel.AddTemporaryPasswordInSession(Pass: String);
var
  I : integer;
begin
  FSych.Enter;
  try
    for I := 0 to FPasswodsInSession.Count - 1 do
      if FPasswodsInSession[I] = Pass then
        Exit;
    FPasswodsInSession.Add(Pass);
  finally
    FSych.Leave;
  end;
end;

procedure TDBKernel.ClearTemporaryPasswordsInSession;
begin
  FSych.Enter;
  try
    FPasswodsInSession.Clear;
  finally
    FSych.Leave;
  end;
end;

function TDBKernel.FindPasswordForCryptImageFile(FileName: String): String;
var
  I : Integer;
begin
  Result := '';
  FSych.Enter;
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
    FSych.Leave;
  end;
end;

function TDBKernel.FindPasswordForCryptBlobStream(DF : TField): String;
var
  I : Integer;
begin
  Result := '';
  FSych.Enter;
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
    FSych.Leave;
  end;
end;

procedure TDBKernel.SavePassToINIDirectory(Pass: String);
var
  I : integer;
begin
  FSych.Enter;
  try
    for I := 0 to FINIPasswods.Count - 1 do
      if FINIPasswods[I] = Pass then
        Exit;

     FINIPasswods.Add(Pass);
     SaveINIPasswords;

   finally
     FSych.Leave;
   end;
end;

procedure TDBKernel.LoadINIPasswords;
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

procedure TDBKernel.SaveINIPasswords;
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

procedure TDBKernel.ClearINIPasswords;
begin
  FINIPasswods.Clear;
  SaveINIPasswords;
end;

procedure TDBKernel.ThreadOpenResult(Result: Boolean);
begin
  ThreadOpenResultBool := Result;
  ThreadOpenResultWork := False;
end;

procedure TDBKernel.LoadDBs;
var
  Reg : TBDRegistry;
  List : TStrings;
  I, DBType : Integer;
  Icon, FileName : string;
begin
  F(FDBs);
  FDBs := TPhotoDBFiles.Create;

  List := TStringList.Create;
  try
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      Reg.GetKeyNames(List);
      for I := 0 to List.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(RegRoot + 'dbs\' + List[I], True);
        if Reg.ValueExists('Icon') and Reg.ValueExists('FileName') and Reg.ValueExists('Type') then
        begin
          Icon := Reg.ReadString('Icon');
          FileName := Reg.ReadString('FileName');
          DBType := Reg.ReadInteger('Type');
          FDBs.Add(List[I], Icon, FileName, DBType);
        end;
      end;
    finally
      F(Reg);
    end;
  finally
    F(List);
  end;
end;

procedure TDBKernel.MoveDB(OldDBFile, NewDBFile: string);
var
  Reg: TBDRegistry;
  DBS: TStrings;
  I: Integer;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot + 'dbs', True);
    DBS := TStringList.Create;
    try
      Reg.GetKeyNames(DBS);
      Reg.CloseKey;
      for I := 0 to DBS.Count - 1 do
      begin
        Reg.OpenKey(RegRoot + 'dbs\' + DBS[I], True);
        if AnsiLowerCase(Reg.ReadString('FileName')) = AnsiLowerCase(OldDBFile) then
        begin
          Reg.WriteString('FileName', NewDBFile);
          Reg.CloseKey;
          Break;
        end;
        Reg.CloseKey;
      end;
    finally
      F(DBS);
    end;
  except
    on e: Exception do
      EventLog(':TDBKernel::MoveDB() throw exception: ' + E.message);
  end;
  F(Reg);
  LoadDBs;
end;

function TDBKernel.DBExists(DBName: string): Boolean;
var
  Reg: TBDRegistry;
  DBS: TStrings;
  I: Integer;
begin
  Result := False;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot + 'dbs', True);
    DBS := TStringList.Create;
    try
      Reg.GetKeyNames(DBS);
      Reg.CloseKey;
      for I := 0 to DBS.Count - 1 do
      begin
        Reg.OpenKey(RegRoot + 'dbs\' + DBS[I], True);
        if AnsiLowerCase(Reg.ReadString('FileName')) = AnsiLowerCase(DBName) then
        begin
          Result := True;
          Reg.CloseKey;
          Break;
        end;
        Reg.CloseKey;
      end;
    finally
      F(DBS);
    end;
  except
    on E: Exception do
      EventLog(':TDBKernel::DBExists() throw exception: ' + E.message);
  end;
  Reg.Free;
end;

function TDBKernel.NewDBName(DBNamePattern: string): string;
var
  Reg: TBDRegistry;
  DBS: TStrings;
  I, J: Integer;
  DBNameCurrent: string;
  B: Boolean;
begin
  Result := DBNamePattern;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      DBS := TStringList.Create;
      try
        Reg.GetKeyNames(DBS);
        Reg.CloseKey;
        DBNameCurrent := DBNamePattern;
        for J := 1 to 1000 do
        begin
          B := False;
          for I := 0 to DBS.Count - 1 do
          begin
            if AnsiLowerCase(DBS[I]) = AnsiLowerCase(DBNameCurrent) then
            begin
              B := True;
            end;
          end;
          if B then
            DBNameCurrent := DBNamePattern + '_' + IntToStr(J)
          else begin
            Result := DBNameCurrent;
            Exit;
          end;
        end;
      finally
        F(DBS);
      end;
    except
      on E: Exception do
        EventLog(':TDBKernel::NewDBName() throw exception: ' + E.message);
    end;
  finally
    F(Reg);
  end;
end;

procedure TDBKernel.AddDB(DBName, DBFile, DBIco: string; Force: Boolean = False);
var
  Reg: TBDRegistry;
begin
  if not Force then
    if DBExists(DBFile) then
      Exit;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot + 'dbs\' + DBName, True);
    Reg.WriteString('FileName', DBFile);
    Reg.WriteString('icon', DBIco);
    Reg.WriteInteger('type', CommonDBSupport.GetDBType(DBFile));
  except
    on E: Exception do
      EventLog(':TDBKernel::AddDB() throw exception: ' + E.message);
  end;
  F(Reg);
  LoadDBs;
end;

function TDBKernel.RenameDB(OldDBName, NewDBName: string): Boolean;
var
  Reg: TBDRegistry;
  DB: TPhotoDBFile;
begin
  Result := False;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(RegRoot + 'dbs\' + OldDBName, True);
    DB := TPhotoDBFile.Create;
    DB.name := OldDBName;
    DB.Icon := Reg.ReadString('icon');
    DB.FileName := Reg.ReadString('FileName');
    DB.FileType := Reg.ReadInteger('type');
    Reg.CloseKey;
    Reg.OpenKey(RegRoot + 'dbs\' + NewDBName, True);
    Reg.WriteString('FileName', DB.FileName);
    Reg.WriteString('icon', DB.Icon);
    Reg.WriteInteger('type', CommonDBSupport.GetDBType(DB.FileName));
    Reg.CloseKey;
  except
    on E: Exception do
      EventLog(':TDBKernel::RenameDB() throw exception: ' + E.message);
  end;
  F(Reg);
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.DeleteKey(RegRoot + 'dbs\' + OldDBName);
  except
    on E: Exception do
      EventLog(':TDBKernel::RenameDB() throw exception: ' + E.message);
  end;
  F(Reg);
  LoadDBs;
end;

function TDBKernel.DeleteDB(DBName: string): boolean;
var
  Reg: TBDRegistry;
begin
  Result := False;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.DeleteKey(RegRoot + 'dbs\' + DBName);
  except
    on E: Exception do
      EventLog(':TDBKernel::DeleteDB() throw exception: ' + E.message);
  end;
  Reg.Free;
  LoadDBs;
end;

function TDBKernel.StringDBVersion(DBVersion: integer): string;
begin
  Result := TA('Unknown DB', 'System');
  case DBVersion of
    DB_VER_1_8:
      Result := 'Paradox DB v1.8';
    DB_VER_1_9:
      Result := 'Paradox DB v1.9';
    DB_VER_2_0:
      Result := 'Paradox DB v2.0';
    DB_VER_2_1:
      Result := 'PhotoDB v2.1';
    DB_VER_2_2:
      Result := 'PhotoDB v2.2';
    DB_VER_2_3:
      Result := 'PhotoDB v4.0'; //the same for 2.3-4.0
  end;
end;

function TDBKernel.ValidDBVersion(DBFile: string;
  DBVersion: Integer): boolean;
begin
  Result := DBVersion = DB_VER_2_3;
end;

procedure TDBKernel.ReadDBOptions;
begin
  F(FImageOptions);
  FImageOptions := CommonDBSupport.GetImageSettingsFromTable(DBName);
  DBJpegCompressionQuality := FImageOptions.DBJpegCompressionQuality;
  ThSize := FImageOptions.ThSize + 2;
  ThSizePanelPreview := FImageOptions.ThSizePanelPreview;
  ThImageSize := FImageOptions.ThSize;
  ThHintSize := FImageOptions.ThHintSize;
end;

procedure TDBKernel.DoSelectDB;
var
  ParamDBFile: string;
  I: Integer;
begin
  ParamDBFile := GetParamStrDBValue('/SelectDB');
  if ParamDBFile = '' then
  begin
    Dbname := Settings.DataBase;
  end else
  begin
    for I := 0 to DBs.Count - 1 do
    begin
      if DBs[I].name = ParamDBFile then
      begin
        DBName := DBs[I].FileName;
        if GetParamStrDBBool('/SelectDBPermanent') then
          DBKernel.SetDataBase(DBName);
        Exit;
      end
    end;
    DBName := AnsiDequotedStr(ParamDBFile, '"');
    if GetParamStrDBBool('/SelectDBPermanent') then
      DBKernel.SetDataBase(DBName);
  end;
end;

procedure TDBKernel.GetPasswordsFromParams;
var
  PassParam: string;
  PassArray: TStrings;
  I: Integer;
begin
  PassArray:= TStringList.Create;
  try
    PassParam := GetParamStrDBValue('/AddPass');
    PassParam := AnsiDequotedStr(PassParam, '"');
    SplitString(PassParam, '!', PassArray);
    for I := 0 to PassArray.Count - 1 do
      AddTemporaryPasswordInSession(PassArray[I]);
  finally
    F(PassArray);
  end;
end;

function TDBKernel.GetSortGroupsByName: Boolean;
begin
  Result := Settings.Readbool('Options', 'SortGroupsByName', True);
end;

procedure TDBKernel.HandleError(E: Exception);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      MessageBoxDB(0, E.Message, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      NotifyOleException(E);
    end
  );
  EventLog(E);
end;

procedure TDBKernel.LoadIcons;
var
  I: Integer; 
  Icons: TDbKernelArrayIcons;
  LB: TLayeredBitmap;

  function LoadIcon(Instance: HINST; ResName: string): HIcon;
  begin
    Result := LoadImage(Instance, PWideChar(ResName), IMAGE_ICON, 16, 16, 0);
  end;

begin
  FImageList := TSIImageList.Create(nil);
  FImageList.Width := 16;
  FImageList.Height := 16;
  FImageList.ColorDepth := cd32Bit;

  FDisabledImageList := TSIImageList.Create(nil);
  FDisabledImageList.Width := 16;
  FDisabledImageList.Height := 16;
  FDisabledImageList.ColorDepth := cd32Bit;

  if not FImageList.LoadFromCache('Images' + IconsVersion) or not FDisabledImageList.LoadFromCache('ImGray' + IconsVersion) then
  begin
    Icons[1] := LoadIcon(HInstance,'SHELL');
    Icons[2] := LoadIcon(HInstance,'SLIDE_SHOW');
    Icons[3] := LoadIcon(HInstance,'REFRESH_THUM');
    Icons[4] := LoadIcon(HInstance,'RATING_STAR');
    Icons[5] := LoadIcon(HInstance,'DELETE_INFO');
    Icons[6] := LoadIcon(HInstance,'DELETE_FILE');
    Icons[7] := LoadIcon(HInstance,'COPY_ITEM');
    Icons[8] := LoadIcon(HInstance,'PROPERTIES');
    Icons[9] := LoadIcon(HInstance,'PRIVATE');
    Icons[10] := LoadIcon(HInstance,'COMMON');
    Icons[11] := LoadIcon(HInstance,'SEARCH');
    Icons[12] := LoadIcon(HInstance,'EXIT');
    Icons[13] := LoadIcon(HInstance,'FAVORITE');
    Icons[14] := LoadIcon(HInstance,'DESKTOP');
    Icons[15] := LoadIcon(HInstance,'RELOAD');
    Icons[16] := LoadIcon(HInstance,'NOTES');
    Icons[17] := LoadIcon(HInstance,'NOTEPAD');
    Icons[18] := LoadIcon(HInstance,'TRATING_1');
    Icons[19] := LoadIcon(HInstance,'TRATING_2');
    Icons[20] := LoadIcon(HInstance,'TRATING_3');
    Icons[21] := LoadIcon(HInstance,'TRATING_4');
    Icons[22] := LoadIcon(HInstance,'TRATING_5');
    Icons[23] := LoadIcon(HInstance,'Z_NEXT_NORM'); //NEXT //TODO: delete icon 'NEXT'
    Icons[24] := LoadIcon(HInstance,'Z_PREVIOUS_NORM'); //PREVIOUS //TODO: delete icon 'PREVIOUS'
    Icons[25] := LoadIcon(HInstance,'TH_NEW');
    Icons[26] := LoadIcon(HInstance,'ROTATE_0');
    Icons[27] := LoadIcon(HInstance,'ROTATE_90');
    Icons[28] := LoadIcon(HInstance,'ROTATE_180');
    Icons[29] := LoadIcon(HInstance,'ROTATE_270');
    Icons[30] := LoadIcon(HInstance,'PLAY');
    Icons[31] := LoadIcon(HInstance,'PAUSE');
    Icons[32] := LoadIcon(HInstance,'COPY');
    Icons[33] := LoadIcon(HInstance,'PASTE');
    Icons[34] := LoadIcon(HInstance,'LOADFROMFILE');
    Icons[35] := LoadIcon(HInstance,'SAVETOFILE');
    Icons[36] := LoadIcon(HInstance,'PANEL');
    Icons[37] := LoadIcon(HInstance,'SELECTALL');
    Icons[38] := LoadIcon(HInstance,'OPTIONS');
    Icons[39] := LoadIcon(HInstance,'ADMINTOOLS');
    Icons[40] := LoadIcon(HInstance,'ADDTODB');
    Icons[41] := LoadIcon(HInstance,'HELP');
    Icons[42] := LoadIcon(HInstance,'RENAME');
    Icons[43] := LoadIcon(HInstance,'EXPLORER');
    Icons[44] := LoadIcon(HInstance,'SEND');
    Icons[45] := LoadIcon(HInstance,'SENDTO');
    Icons[46] := LoadIcon(HInstance,'NEW');
    Icons[47] := LoadIcon(HInstance,'NEWDIRECTORY');
    Icons[48] := LoadIcon(HInstance,'SHELLPREVIOUS');
    Icons[49] := LoadIcon(HInstance,'SHELLNEXT');
    Icons[50] := LoadIcon(HInstance,'SHELLUP');
    Icons[51] := LoadIcon(HInstance,'KEY');
    Icons[52] := LoadIcon(HInstance,'FOLDER');
    Icons[53] := LoadIcon(HInstance,'ADDFOLDER');
    Icons[54] := LoadIcon(HInstance,'BOX');
    Icons[55] := LoadIcon(HInstance,'DIRECTORY');
    Icons[56] := LoadIcon(HInstance,'THFOLDER');
    Icons[57] := LoadIcon(HInstance,'CUT');
    Icons[58] := LoadIcon(HInstance,'NEWWINDOW');
    Icons[59] := LoadIcon(HInstance,'ADDSINGLEFILE');
    Icons[60] := LoadIcon(HInstance,'MANYFILES');
    Icons[61] := LoadIcon(HInstance,'MYCOMPUTER');
    Icons[62] := LoadIcon(HInstance,'EXPLORERPANEL');
    Icons[63] := LoadIcon(HInstance,'INFOPANEL');
    Icons[64] := LoadIcon(HInstance,'SAVEASTABLE');
    Icons[65] := LoadIcon(HInstance,'EDITDATE');
    Icons[66] := LoadIcon(HInstance,'GROUPS');
    Icons[67] := LoadIcon(HInstance,'WALLPAPER');
    Icons[68] := LoadIcon(HInstance,'NETWORK');
    Icons[69] := LoadIcon(HInstance,'WORKGROUP');
    Icons[70] := LoadIcon(HInstance,'COMPUTER');
    Icons[71] := LoadIcon(HInstance,'SHARE');
    Icons[72] := LoadIcon(HInstance,'Z_ZOOMIN_NORM');
    Icons[73] := LoadIcon(HInstance,'Z_ZOOMOUT_NORM');
    Icons[74] := LoadIcon(HInstance,'Z_FULLSIZE_NORM');
    Icons[75] := LoadIcon(HInstance,'Z_BESTSIZE_NORM');
    Icons[76] := LoadIcon(HInstance,'E_MAIL');
    Icons[77] := LoadIcon(HInstance,'CRYPTFILE');
    Icons[78] := LoadIcon(HInstance,'DECRYPTFILE');
    Icons[79] := LoadIcon(HInstance,'PASSWORD');
    Icons[80] := LoadIcon(HInstance,'EXEFILE');
    Icons[81] := LoadIcon(HInstance,'SIMPLEFILE');
    Icons[82] := LoadIcon(HInstance,'CONVERT');
    Icons[83] := LoadIcon(HInstance,'RESIZE');
    Icons[84] := LoadIcon(HInstance,'REFRESHID');
    Icons[85] := LoadIcon(HInstance,'DUPLICAT');
    Icons[86] := LoadIcon(HInstance,'DELDUPLICAT');
    Icons[87] := LoadIcon(HInstance,'UPDATING');
    Icons[88] := LoadIcon(HInstance,'Z_FULLSCREEN_NORM');
    Icons[89] := LoadIcon(HInstance,'MYDOCUMENTS');
    Icons[90] := LoadIcon(HInstance,'MYPICTURES');
    Icons[91] := LoadIcon(HInstance,'DESKTOPLINK');
    Icons[92] := LoadIcon(HInstance,'IMEDITOR');
    Icons[93] := LoadIcon(HInstance,'OTHER_TOOLS');
    Icons[94] := LoadIcon(HInstance,'EXPORT_IMAGES');
    Icons[95] := LoadIcon(HInstance,'PRINTER');
    Icons[96] := LoadIcon(HInstance,'EXIF');
    Icons[97] := LoadIcon(HInstance,'GET_USB');
    Icons[98] := LoadIcon(HInstance,'USB');
    Icons[99] := LoadIcon(HInstance,'TXTFILE');
    Icons[100] := LoadIcon(HInstance,'DOWN');
    Icons[101] := LoadIcon(HInstance,'UP');
    Icons[102] := LoadIcon(HInstance,'CDROM');
    Icons[103] := LoadIcon(HInstance,'TREE');
    Icons[104] := LoadIcon(HInstance,'CANCELACTION');
    Icons[105] := LoadIcon(HInstance,'XDB');
    Icons[106] := LoadIcon(HInstance,'XMDB');
    Icons[107] := LoadIcon(HInstance,'SORT');
    Icons[108] := LoadIcon(HInstance,'FILTER');
    Icons[109] := LoadIcon(HInstance,'CLOCK');
    Icons[110] := LoadIcon(HInstance,'ATYPE');
    Icons[111] := LoadIcon(HInstance,'MAINICON');
    Icons[112] := LoadIcon(HInstance,'APPLY_ACTION');
    Icons[113] := LoadIcon(HInstance,'RELOADING');
    Icons[114] := LoadIcon(HInstance,'STENO');
    Icons[115] := LoadIcon(HInstance,'DESTENO');
    Icons[116] := LoadIcon(HInstance,'SPLIT');
    Icons[117] := LoadIcon(HInstance,'CD_EXPORT');
    Icons[118] := LoadIcon(HInstance,'CD_MAPPING');
    Icons[119] := LoadIcon(HInstance,'CD_IMAGE');
    Icons[120] := LoadIcon(HInstance,'MAGIC_ROTATE');
    Icons[121] := LoadIcon(HInstance,'PERSONS');
    Icons[122] := LoadIcon(HInstance,'CAMERA');
    Icons[123] := LoadIcon(HInstance,'CROP');
    Icons[124] := LoadIcon(HInstance,'PIC_IMPORT');
    Icons[125] := LoadIcon(HInstance,'BACKUP');
    Icons[126] := LoadIcon(HInstance,'MAP_MARKER');
    Icons[127] := LoadIcon(HInstance,'SHELF');
    Icons[128] := LoadIcon(HInstance,'PHOTO_SHARE');
    Icons[129] := LoadIcon(HInstance,'EDIT_PROFILE');

    //disabled items are bad
    for I := 1 to IconsCount do
      ImageList_ReplaceIcon(FImageList.Handle, -1, Icons[I]);

    for I := 1 to IconsCount do
    begin
      LB := TLayeredBitmap.Create;
      try
        LB.LoadFromHIcon(Icons[I]);
        LB.GrayScale;
        FDisabledImageList.Add(LB, nil);
      finally
        F(LB);
      end;
    end;

    FImageList.SaveToCache('Images' + IconsVersion);
    FDisabledImageList.SaveToCache('ImGray' + IconsVersion);
  end;
end;

{ TDBIcons }

constructor TDBIcons.Create;  
var
  I: Integer; 
begin
  for I := 1 to IconsCount do
    FIcons[I] := 0;
end;

destructor TDBIcons.Destroy;
var
  I: Integer; 
begin
  for I := 1 to IconsCount do
    DestroyIcon(FIcons[I]);
end;

function TDBIcons.GetIconByIndex(Index: Integer): HIcon;
begin
  if FIcons[Index] <> 0 then
    Exit(FIcons[Index]);
    
  FIcons[Index] := ImageList_GetIcon(DBKernel.ImageList.Handle, Index - 1, 0);
  Result := FIcons[Index];
end;

initialization

finalization

  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(Dbname));
  F(DBKernel);
  F(FIcons);

end.
