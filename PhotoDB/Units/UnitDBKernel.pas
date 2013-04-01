unit UnitDBKernel;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  Winapi.Windows,
  Winapi.CommCtrl,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Data.DB,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.ImgList,
  Vcl.Imaging.Jpeg,

  UnitDBDeclare,
  GraphicCrypt,
  CommonDBSupport,
  UnitINI,

  Dmitry.CRC32,
  Dmitry.Utils.Files,
  Dmitry.Utils.System,

  uMemory,
  uShellIntegration,
  uLogger,
  uCDMappingTypes,
  uConstants,
  uTime,
  uCollectionEvents,
  uSplashThread,
  uShellUtils,
  uAppUtils,
  uTranslate,
  uDBForm,
  uGroupTypes,
  UnitGroupsWork,
  uRuntime,
  uStringUtils,
  uSettings,
  uImageListUtils,
  uProgramStatInfo,
  uVCLHelpers;


type
  TDBKernel = class(TObject)
  private
    { Private declarations }
    ThreadOpenResultBool: Boolean;
    ThreadOpenResultWork: Boolean;
    FDBs: TList<TDatabaseInfo>;
    FImageOptions: TImageDBOptions;
    FSych: TCriticalSection;
    function GetSortGroupsByName: Boolean;
    procedure HandleError(E: Exception);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure LoadDBs;
    procedure SaveDBs;
    property DBs: TList<TDatabaseInfo> read FDBs;

    function TestDB(DBName_: string; OpenInThread: Boolean = False): Boolean;
    procedure BackUpTable;
    function CreateDBbyName(FileName: string): Integer;
    procedure SetDataBase(DatabaseFileName: string);

    procedure ThreadOpenResult(Result: Boolean);
    procedure AddDB(DBName, DBFile, DBIco: string; Force: Boolean = False);
    function TestDBEx(DBName_: string; OpenInThread: Boolean = False): Integer;
    procedure MoveDB(OldDBFile, NewDBFile: string);

    function ValidDBVersion(DBFile: string; DBVersion: Integer): Boolean;
    procedure ReadDBOptions;
    procedure DoSelectDB;
    procedure CheckDatabase;
    procedure CheckSampleDB;
    function SelectDB(Caller: TDBForm; DB: string): Boolean;
    procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);

    property ImageOptions: TImageDBOptions read FImageOptions;
    property SortGroupsByName: Boolean read GetSortGroupsByName;
  end;

var
  DBKernel: TDBKernel = nil;

implementation

uses
  UnitCrypting,
  UnitActiveTableThread, 
  UnitFileCheckerDB,
  UnitBackUpTableInCMD;

{ TDBKernel }

constructor TDBKernel.Create;
begin
  inherited;
  FImageOptions := nil;
  FSych := TCriticalSection.Create;
  FDBs := TList<TDatabaseInfo>.Create;
  LoadDBs;
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

procedure TDBKernel.CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
var
  NewGroup: TGroup;
  ImagesDir: string;
begin
  if not DBKernel.TestDB(FileName) then
    DBKernel.CreateDBbyName(FileName);

  if not IsValidGroupsTableW(FileName) then
  begin
    ImagesDir := IncludeTrailingBackslash(CurrentImagesDirectory) + 'Images\';
    if FileExists(ImagesDir + 'Me.jpg') then
    begin
      try
        NewGroup.GroupName := GetWindowsUserName;
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Me.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := NewGroup.GroupName;
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  if FileExists(ImagesDir + 'Friends.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Friends', 'Setup');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Friends.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Friends', 'Setup');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
    if FileExists(ImagesDir + 'Family.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Family', 'Setup');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(ImagesDir + 'Family.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Family', 'Setup');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  end;
end;

destructor TDBKernel.Destroy;
begin
  F(FSych);
  FreeList(FDBs);
  F(FImageOptions);
  inherited;
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

function TDBKernel.SelectDB(Caller: TDBForm; DB: string): Boolean;
var
  EventInfo: TEventValues;
  DBVersion: Integer;

begin
  Result := False;
  if FileExists(DB) then
  begin
    DBVersion := DBKernel.TestDBEx(DB);
    if DBkernel.ValidDBVersion(DB, DBVersion) then
    begin
      DBname := DB;
      DBKernel.SetDataBase(DB);
      EventInfo.FileName := Dbname;
      CollectionEvents.DoIDEvent(Caller, 0, [EventID_Param_DB_Changed], EventInfo);
      Result := True;
      Exit;
    end
  end;
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

procedure TDBKernel.CheckDatabase;
var
  DBVersion: Integer;
  StringDBCheckKey: string;
begin
  TW.I.Start('FM -> InitializeDolphinDB');
  if FolderView then
  begin
    dbname := ExtractFilePath(Application.ExeName) + 'FolderDB.photodb';

    if FileExistsSafe(ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb') then
      dbname := ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb';
  end;

  if not DBTerminating then
  begin

    if not FileExistsSafe(dbname) then
    begin
      CloseSplashWindow;
      CheckSampleDB;
    end;

    TW.I.Start('FM -> check valid db version');

    // check valid db version
    StringDBCheckKey := Format('%d-%d', [Integer(StringCRC(dbname)), DB_VER_CURRENT]);
    if not Settings.ReadBool('DBVersionCheck', StringDBCheckKey, False) or GetParamStrDBBool('/dbcheck') then
    begin
      TW.I.Start('FM -> TestDBEx');
      DBVersion := DBKernel.TestDBEx(dbname, False);
      if not DBKernel.ValidDBVersion(dbname, DBVersion) then
      begin
        CloseSplashWindow;
        //ConvertDB(dbname);
        DBVersion := DBKernel.TestDBEx(dbname, False);
        if not DBKernel.ValidDBVersion(dbname, DBVersion) then
        begin
          DBTerminating := True;
          Exit;
        end;
      end;
      Settings.WriteBool('DBVersionCheck', StringDBCheckKey, True);
    end;

  end;
end;

procedure TDBKernel.CheckSampleDB;
var
  FileName: string;
begin
  //if program was uninstalled with registered databases - restore database or create new database
  FileName := IncludeTrailingBackslash(GetMyDocumentsPath) + TA('My collection') + '.photodb';
  if not FileExistsSafe(FileName) then
    CreateExampleDB(FileName, Application.ExeName + ',0', ExtractFileDir(Application.ExeName));

  DBKernel.AddDB(TA('My collection'), FileName, Application.ExeName + ',0');
  DBKernel.SetDataBase(FileName);
end;

procedure TDBKernel.ThreadOpenResult(Result: Boolean);
begin
  ThreadOpenResultBool := Result;
  ThreadOpenResultWork := False;
end;

procedure TDBKernel.LoadDBs;
var
  Reg: TBDRegistry;
  List: TStrings;
  I: Integer;
  Icon, FileName, Description: string;
begin
  FreeList(FDBs, False);

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
        if Reg.ValueExists('Icon') and Reg.ValueExists('FileName') then
        begin
          Icon := Reg.ReadString('Icon');
          FileName := Reg.ReadString('FileName');
          Description := Reg.ReadString('Description');
          FDBs.Add(TDatabaseInfo.Create(List[I], FileName, Icon, Description, Reg.ReadInteger('Order')));
        end;
      end;
    finally
      F(Reg);
    end;
  finally
    F(List);
  end;

  FDBs.Sort(TComparer<TDatabaseInfo>.Construct(
     function (const L, R: TDatabaseInfo): Integer
     begin
       Result := L.Order - R.Order;
     end
  ));
end;

procedure TDBKernel.SaveDBs;
var
  Reg: TBDRegistry;
  List: TStrings;
  I: Integer;
  DB: TDatabaseInfo;
  Settings: TImageDBOptions;
begin
  List := TStringList.Create;
  try
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(RegRoot + 'dbs', True);
      Reg.GetKeyNames(List);
      for I := 0 to List.Count - 1 do
        Reg.DeleteKey(List[I]);

      for DB in FDBs do
      begin
        Reg.CloseKey;
        Reg.OpenKey(RegRoot + 'dbs\' + DB.Title, True);
        Reg.WriteString('FileName', DB.Path);
        Reg.WriteString('Icon', DB.Icon);
        Reg.WriteString('Description', DB.Description);
        Reg.WriteInteger('Order', FDBs.IndexOf(DB));

        Settings := CommonDBSupport.GetImageSettingsFromTable(DB.Path);
        try
          Settings.Name := DB.Title;
          Settings.Description := DB.Description;
          CommonDBSupport.UpdateImageSettings(DB.Path, Settings);
        finally
          F(Settings);
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

procedure TDBKernel.AddDB(DBName, DBFile, DBIco: string; Force: Boolean = False);
var
  Reg: TBDRegistry;
begin
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

function TDBKernel.ValidDBVersion(DBFile: string;
  DBVersion: Integer): Boolean;
begin
  Result := DBVersion = DB_VER_2_3;
end;

procedure TDBKernel.ReadDBOptions;
begin
  F(FImageOptions);
  FImageOptions := CommonDBSupport.GetImageSettingsFromTable(DBName);
  DBJpegCompressionQuality := FImageOptions.DBJpegCompressionQuality;
  ThSize := FImageOptions.ThSize + 2;
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
      if DBs[I].Title = ParamDBFile then
      begin
        DBName := DBs[I].Path;
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



initialization

finalization

  FileCheckedDB.SaveCheckFile(GroupsTableFileNameW(Dbname));
  F(DBKernel);

end.
