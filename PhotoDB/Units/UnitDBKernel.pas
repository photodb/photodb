unit UnitDBKernel;

interface

uses
  Win32crc, Forms, Windows, Classes,
  Controls, Graphics, DB, SysUtils, JPEG, UnitDBDeclare, IniFiles,
  GraphicCrypt, ADODB, uLogger, uActivationUtils, uCDMappingTypes,
  uConstants, CommCtrl, uTime, UnitINI, SyncObjs, uMemory, uFileUtils,
  uAppUtils, uTranslate, uDBForm, uVistaFuncs, uShellIntegration,
  uRuntime, uDBBaseTypes, uStringUtils, uSettings, uSysUtils;

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
  IconsCount = 122;

type
 TDbKernelArrayIcons = array [1..IconsCount] of THandle;

type
  TDBKernel = class(TObject)
  private
    { Private declarations }
    FINIPasswods: TStrings;
    FPasswodsInSession: TStrings;
    FEvents: TDBEventsIDArray;
    FImageList: TImageList;
    FForms: TList;
    FApplicationKey: string;
    ThreadOpenResultBool: Boolean;
    ThreadOpenResultWork: Boolean;
    FDBs: TPhotoDBFiles;
    FImageOptions: TImageDBOptions;
    FSych: TCriticalSection;
    procedure LoadDBs;
    function GetSortGroupsByName: Boolean;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    property DBs: TPhotoDBFiles read FDBs;
    property ImageList: TImageList read FImageList;
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

var
  Icons: TDbKernelArrayIcons;
  DBKernel: TDBKernel = nil;

implementation

uses
  UnitCrypting, CommonDBSupport,
  UnitActiveTableThread, UnitFileCheckerDB, UnitGroupsWork,
  UnitBackUpTableInCMD;

{ TDBKernel }

constructor TDBKernel.Create;
var
  I: Integer;
begin
  for I := 0 to 10 do
    if ParamStr(I) <> '' then
      TW.I.Start('Parameter: ' + ParamStr(I));

  inherited;
  FDBs := nil;
  FImageOptions := nil;
  FImageList := nil;
  FSych := TCriticalSection.Create;
  FForms := TList.Create;
  LoadDBs;
  FPasswodsInSession := TStringList.create;
  FINIPasswods := nil;
  FApplicationKey := '';
end;

function TDBKernel.CreateDBbyName(FileName: string): integer;
begin
  Result := 0;
  CreateDirA(ExtractFileDir(FileName));
  try
    if FileExistsSafe(FileName) then
      DeleteFile(FileName);
  except
    on E: Exception do
    begin
      EventLog(':TDBKernel::CreateDBbyName() throw exception: ' + E.message);
      Exit;
    end;
  end;
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
end;

destructor TDBKernel.Destroy;
begin
  F(FImageList);
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
  if not FileExistsSafe(DBName_) then
  begin
    Result := -1;
    Exit;
  end;
  FTestTable := nil;
  try
    if (GetDBType(DBName_) = DB_TYPE_MDB) and (GetFileSizeByName(DBName_) > 500 * 1025) then
    begin
      FTestTable := GetQuery(DBName_, True);
      ForwardOnlyQuery(FTestTable);

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

    if FTestTable <> nil then
      if FTestTable.Active then
        if FTestTable.RecordCount = 0 then
        begin
          FreeDS(FTestTable);
          FTestTable := GetTable(DBName_, DB_TABLE_IMAGES);
        end;

    if FTestTable = nil then
      FTestTable := GetTable(DBName_, DB_TABLE_IMAGES);

    if FTestTable = nil then
      Exit;
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
    on E: Exception do
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
      Result := 'PhotoDB v2.3';
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
  ParamDBFile : string;
  i : integer;
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
    DBName := SysUtils.AnsiDequotedStr(ParamDBFile, '"');
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
    PassParam := SysUtils.AnsiDequotedStr(PassParam, '"');
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

procedure TDBKernel.LoadIcons;
var
  I : Integer;

  function LoadIcon(Instance : HINST; ResName : string) : HIcon;
  begin
    Result := LoadImage(Instance, PWideChar(ResName), IMAGE_ICON, 16, 16, 0);
  end;

begin
  FImageList := TImageList.Create(nil);
  FImageList.Width := 16;
  FImageList.Height := 16;
  FImageList.BkColor := ClMenu;

  icons[1] := LoadIcon(HInstance,'SHELL');
  icons[2] := LoadIcon(HInstance,'SLIDE_SHOW');
  icons[3] := LoadIcon(HInstance,'REFRESH_THUM');
  icons[4] := LoadIcon(HInstance,'RATING_STAR');
  icons[5] := LoadIcon(HInstance,'DELETE_INFO');
  icons[6] := LoadIcon(HInstance,'DELETE_FILE');
  icons[7] := LoadIcon(HInstance,'COPY_ITEM');
  icons[8] := LoadIcon(HInstance,'PROPERTIES');
  icons[9] := LoadIcon(HInstance,'PRIVATE');
  icons[10] := LoadIcon(HInstance,'COMMON');
  icons[11] := LoadIcon(HInstance,'SEARCH');
  icons[12] := LoadIcon(HInstance,'EXIT');
  icons[13] := LoadIcon(HInstance,'FAVORITE');
  icons[14] := LoadIcon(HInstance,'DESKTOP');
  icons[15] := LoadIcon(HInstance,'RELOAD');
  icons[16] := LoadIcon(HInstance,'NOTES');
  icons[17] := LoadIcon(HInstance,'NOTEPAD');
  icons[18] := LoadIcon(HInstance,'TRATING_1');
  icons[19] := LoadIcon(HInstance,'TRATING_2');
  icons[20] := LoadIcon(HInstance,'TRATING_3');
  icons[21] := LoadIcon(HInstance,'TRATING_4');
  icons[22] := LoadIcon(HInstance,'TRATING_5');
  icons[23] := LoadIcon(HInstance,'NEXT');
  icons[24] := LoadIcon(HInstance,'PREVIOUS');
  icons[25] := LoadIcon(HInstance,'TH_NEW');
  icons[26] := LoadIcon(HInstance,'ROTATE_0');
  icons[27] := LoadIcon(HInstance,'ROTATE_90');
  icons[28] := LoadIcon(HInstance,'ROTATE_180');
  icons[29] := LoadIcon(HInstance,'ROTATE_270');
  icons[30] := LoadIcon(HInstance,'PLAY');
  icons[31] := LoadIcon(HInstance,'PAUSE');
  icons[32] := LoadIcon(HInstance,'COPY');
  icons[33] := LoadIcon(HInstance,'PASTE');
  icons[34] := LoadIcon(HInstance,'LOADFROMFILE');
  icons[35] := LoadIcon(HInstance,'SAVETOFILE');
  icons[36] := LoadIcon(HInstance,'PANEL');
  icons[37] := LoadIcon(HInstance,'SELECTALL');
  icons[38] := LoadIcon(HInstance,'OPTIONS');
  icons[39] := LoadIcon(HInstance,'ADMINTOOLS');
  icons[40] := LoadIcon(HInstance,'ADDTODB');
  icons[41] := LoadIcon(HInstance,'HELP');
  icons[42] := LoadIcon(HInstance,'RENAME');
  icons[43] := LoadIcon(HInstance,'EXPLORER');
  icons[44] := LoadIcon(HInstance,'SEND');
  icons[45] := LoadIcon(HInstance,'SENDTO');
  icons[46] := LoadIcon(HInstance,'NEW');
  icons[47] := LoadIcon(HInstance,'NEWDIRECTORY');
  icons[48] := LoadIcon(HInstance,'SHELLPREVIOUS');
  icons[49] := LoadIcon(HInstance,'SHELLNEXT');
  icons[50] := LoadIcon(HInstance,'SHELLUP');
  icons[51] := LoadIcon(HInstance,'KEY');
  icons[52] := LoadIcon(HInstance,'FOLDER');
  icons[53] := LoadIcon(HInstance,'ADDFOLDER');
  icons[54] := LoadIcon(HInstance,'BOX');
  icons[55] := LoadIcon(HInstance,'DIRECTORY');
  icons[56] := LoadIcon(HInstance,'THFOLDER');
  icons[57] := LoadIcon(HInstance,'CUT');
  icons[58] := LoadIcon(HInstance,'NEWWINDOW');
  icons[59] := LoadIcon(HInstance,'ADDSINGLEFILE');
  icons[60] := LoadIcon(HInstance,'MANYFILES');
  icons[61] := LoadIcon(HInstance,'MYCOMPUTER');
  icons[62] := LoadIcon(HInstance,'EXPLORERPANEL');
  icons[63] := LoadIcon(HInstance,'INFOPANEL');
  icons[64] := LoadIcon(HInstance,'SAVEASTABLE');
  icons[65] := LoadIcon(HInstance,'EDITDATE');
  icons[66] := LoadIcon(HInstance,'GROUPS');
  icons[67] := LoadIcon(HInstance,'WALLPAPER');
  icons[68] := LoadIcon(HInstance,'NETWORK');
  icons[69] := LoadIcon(HInstance,'WORKGROUP');
  icons[70] := LoadIcon(HInstance,'COMPUTER');
  icons[71] := LoadIcon(HInstance,'SHARE');
  icons[72] := LoadIcon(HInstance,'Z_ZOOMIN_NORM');
  icons[73] := LoadIcon(HInstance,'Z_ZOOMOUT_NORM');
  icons[74] := LoadIcon(HInstance,'Z_FULLSIZE_NORM');
  icons[75] := LoadIcon(HInstance,'Z_BESTSIZE_NORM');
  icons[76] := LoadIcon(HInstance,'E_MAIL');
  icons[77] := LoadIcon(HInstance,'CRYPTFILE');
  icons[78] := LoadIcon(HInstance,'DECRYPTFILE');
  icons[79] := LoadIcon(HInstance,'PASSWORD');
  icons[80] := LoadIcon(HInstance,'EXEFILE');
  icons[81] := LoadIcon(HInstance,'SIMPLEFILE');
  icons[82] := LoadIcon(HInstance,'CONVERT');
  icons[83] := LoadIcon(HInstance,'RESIZE');
  icons[84] := LoadIcon(HInstance,'REFRESHID');
  icons[85] := LoadIcon(HInstance,'DUBLICAT');
  icons[86] := LoadIcon(HInstance,'DELDUBLICAT');
  icons[87] := LoadIcon(HInstance,'UPDATING');
  icons[88] := LoadIcon(HInstance,'Z_FULLSCREEN_NORM');
  icons[89] := LoadIcon(HInstance,'MYDOCUMENTS');
  icons[90] := LoadIcon(HInstance,'MYPICTURES');
  icons[91] := LoadIcon(HInstance,'DESKTOPLINK');
  icons[92] := LoadIcon(HInstance,'IMEDITOR');
  icons[93] := LoadIcon(HInstance,'OTHER_TOOLS');
  icons[94] := LoadIcon(HInstance,'EXPORT_IMAGES');
  icons[95] := LoadIcon(HInstance,'PRINTER');
  icons[96] := LoadIcon(HInstance,'EXIF');
  icons[97] := LoadIcon(HInstance,'GET_USB');
  icons[98] := LoadIcon(HInstance,'USB');
  icons[99] := LoadIcon(HInstance,'TXTFILE');
  icons[100] := LoadIcon(HInstance,'DOWN');
  icons[101] := LoadIcon(HInstance,'UP');
  icons[102] := LoadIcon(HInstance,'CDROM');
  icons[103] := LoadIcon(HInstance,'TREE');
  icons[104] := LoadIcon(HInstance,'CANCELACTION');
  icons[105] := LoadIcon(HInstance,'XDB');
  icons[106] := LoadIcon(HInstance,'XMDB');
  icons[107] := LoadIcon(HInstance,'SORT');
  icons[108] := LoadIcon(HInstance,'FILTER');
  icons[109] := LoadIcon(HInstance,'CLOCK');
  icons[110] := LoadIcon(HInstance,'ATYPE');
  icons[111] := LoadIcon(HInstance,'MAINICON');
  icons[112] := LoadIcon(HInstance,'APPLY_ACTION');
  icons[113] := LoadIcon(HInstance,'RELOADING');
  icons[114] := LoadIcon(HInstance,'STENO');
  icons[115] := LoadIcon(HInstance,'DESTENO');
  icons[116] := LoadIcon(HInstance,'SPLIT');
  icons[117] := LoadIcon(HInstance,'CD_EXPORT');
  icons[118] := LoadIcon(HInstance,'CD_MAPPING');
  icons[119] := LoadIcon(HInstance,'CD_IMAGE');
  icons[120] := LoadIcon(HInstance,'MAGIC_ROTATE');
  icons[121] := LoadIcon(HInstance,'PERSONS');
  icons[122] := LoadIcon(HInstance,'CAMERA');

  //disabled items are bad
  for I := 1 to IconsCount do
    ImageList_ReplaceIcon(FImageList.Handle, -1, Icons[I]);
end;

initialization

finalization

  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(Dbname));
  F(DBKernel);

end.
