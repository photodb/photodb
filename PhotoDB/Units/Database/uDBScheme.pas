unit uDBScheme;

interface

uses
  Winapi.ActiveX,
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  uConstants,
  uMemory,
  uLogger,
  uTranslate,
  uThreadTask,
  uDBConnection,
  uDBClasses,
  uDBBaseTypes,
  uSplashThread,
  uFormInterfaces;

const
  CURRENT_DB_SCHEME_VERSION = 3;

type
  TCollectionUpdateTask = class
  private
    FFileName: string;
  public
    function Estimate: Integer; virtual;
    function Text: string; virtual;
    function Execute(Progress: TSimpleCallBackProgressRef; CurrentVersion: Integer): Integer; virtual;
    constructor Create(FileName: string); virtual;
    property FileName: string read FFileName;
  end;

  TPackCollectionTask = class(TCollectionUpdateTask)
  private
    FSaveBackup: Boolean;
  public
    constructor Create(FileName: string); override;
    function Estimate: Integer; override;
    function Text: string; override;
    function Execute(Progress: TSimpleCallBackProgressRef; CurrentVersion: Integer): Integer; override;
    property SaveBackup: Boolean read FSaveBackup write FSaveBackup;
  end;

  TMigrateToV_003_Task = class(TCollectionUpdateTask)
  public
    function Estimate: Integer; override;
    function Text: string; override;
    function Execute(Progress: TSimpleCallBackProgressRef; CurrentVersion: Integer): Integer; override;
  end;

type
  TDBScheme = class
  private
    class procedure CreateDatabaseFile(CollectionFile: string);

    class function CreateSettingsTable(CollectionFile: string): Boolean; static;
    class function CreateImageTable(CollectionFile: string): Boolean; static;
    class function CreateGroupsTable(CollectionFile: string): Boolean; static;
    class function CreateObjectMappingTable(CollectionFile: string): Boolean; static;
    class function CreateObjectsTable(CollectionFile: string): Boolean; static;

    class procedure UpdateCollectionVersion(CollectionFile: string; Version: Integer);

    //v2 is base version
    class procedure MigrateToVersion003(CollectionFile: string; Progress: TSimpleCallBackProgressRef);
  public
    class function GetCollectionVersion(CollectionFile: string): Integer;
    class function CreateCollection(CollectionFile: string): Boolean;
    class function UpdateCollection(CollectionFile: string; CurrentVersion: Integer; CreateBackUp: Boolean): Boolean;
    class function IsValidCollectionFile(CollectionFile: string): Boolean;
    class function IsOldColectionFile(CollectionFile: string): Boolean;
    class function IsNewColectionFile(CollectionFile: string): Boolean;
  end;

implementation

class function TDBScheme.CreateCollection(CollectionFile: string): Boolean;
begin
  Result := True;
  CreateDatabaseFile(CollectionFile);

  CreateSettingsTable(CollectionFile);
  CreateImageTable(CollectionFile);
  CreateGroupsTable(CollectionFile);
  CreateObjectsTable(CollectionFile);
  CreateObjectMappingTable(CollectionFile);

  TThread.Synchronize(nil,
    procedure
    begin
      UpdateCollection(CollectionFile, 0, False);
    end
  );
end;

type
  TUpdateTaskList = TList<TCollectionUpdateTask>;

class function TDBScheme.UpdateCollection(CollectionFile: string; CurrentVersion: Integer; CreateBackUp: Boolean): Boolean;
var
  ProgressForm: IBackgroundTaskStatusForm;
  TotalAmount: Int64;
  ReadyAmount: Int64;
  I: Integer;

  Tasks: TList<TCollectionUpdateTask>;
  WorkThread: TThread;
  Task: TCollectionUpdateTask;
begin
  CloseSplashWindow;

  if CurrentVersion = 0 then
    CurrentVersion := GetCollectionVersion(CollectionFile);

  ProgressForm := BackgroundTaskStatusForm;

  Tasks := TUpdateTaskList.Create;
  try

    Task := TPackCollectionTask.Create(CollectionFile);
    TPackCollectionTask(Task).SaveBackup := CreateBackUp;
    Tasks.Add(Task);

    Tasks.Add(TMigrateToV_003_Task.Create(CollectionFile));
    Tasks.Add(TPackCollectionTask.Create(CollectionFile));

    TotalAmount := 0;
    ReadyAmount := 0;
    for I := 0 to Tasks.Count - 1 do
      Inc(TotalAmount, Tasks[I].Estimate);

    WorkThread := TThread.CreateAnonymousThread(
      procedure
      var
        I: Integer;
        CurrentAmount: Int64;
        Task: TCollectionUpdateTask;
      begin
        //to call show modal before end of all update process
        Sleep(100);

        CoInitializeEx(nil, COM_MODE);
        try
          for I := 0 to Tasks.Count - 1 do
          begin
            Task := Tasks[I];
            TThread.Synchronize(nil,
              procedure
              begin
                ProgressForm.SetText(Task.Text);
              end
            );
            CurrentVersion := Task.Execute(
              procedure(Sender: TObject; Total, Value: Int64)
              begin
                CurrentAmount := ReadyAmount + Round((Task.Estimate * Value) / Total);

                TThread.Synchronize(nil,
                  procedure
                  begin
                    ProgressForm.SetProgress(TotalAmount, CurrentAmount);
                  end
                );

              end
            , CurrentVersion);

            ReadyAmount := ReadyAmount + Task.Estimate;

            TThread.Synchronize(nil,
              procedure
              begin
                ProgressForm.SetProgress(TotalAmount, ReadyAmount);
              end
            );
          end;

        finally
          TThread.Synchronize(nil,
            procedure
            begin
              ProgressForm.CloseForm;
            end
          );
          CoUninitialize;
        end;
      end
    );
    WorkThread.FreeOnTerminate := True;
    WorkThread.Start;

    ProgressForm.ShowModal;
  finally
    FreeList(Tasks);
  end;

  Result := True;
end;

class function TDBScheme.IsNewColectionFile(CollectionFile: string): Boolean;
begin
  Result := GetCollectionVersion(CollectionFile) > CURRENT_DB_SCHEME_VERSION;
end;

class function TDBScheme.IsOldColectionFile(CollectionFile: string): Boolean;
var
  Version: Integer;
begin
  Version := GetCollectionVersion(CollectionFile);
  Result := (1 < Version) and (Version < CURRENT_DB_SCHEME_VERSION);
end;

class function TDBScheme.IsValidCollectionFile(CollectionFile: string): Boolean;
begin
  Result := GetCollectionVersion(CollectionFile) = CURRENT_DB_SCHEME_VERSION;
end;

class procedure TDBScheme.CreateDatabaseFile(CollectionFile: string);
begin
  try
    CreateMSAccessDatabase(CollectionFile);
  except
    on E: Exception do
    begin
      EventLog(':CreateDatabaseFile() throw exception: ' + E.message);
      raise;
    end;
  end;
end;

class function TDBScheme.CreateSettingsTable(CollectionFile: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE TABLE DBSettings ( ' +
      'Version INTEGER , ' +
      'DBName Character(255) , ' +
      'DBDescription Character(255) , ' +
      'DBJpegCompressionQuality INTEGER , ' +
      'ThSizePanelPreview INTEGER , ' +
      'ThImageSize INTEGER , ' +
      'ThHintSize INTEGER)';

    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateSettingsTable() throw exception: ' + E.message);
        raise;
      end;
    end;

  finally
    FreeDS(FQuery);
  end;
end;

class function TDBScheme.CreateImageTable(CollectionFile: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := False;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE TABLE ImageTable (' +
      'ID Autoincrement,' +
      'Name Character(255),' +
      'FFileName Memo,' +
      'Comment Memo,' +
      'IsDate Logical,' +
      'DateToAdd Date ,' +
      'Owner  Character(255),' +
      'Rating INTEGER ,' +
      'Thum  LONGBINARY,' +
      'FileSize INTEGER ,' +
      'KeyWords Memo,' +
      'Groups Memo,' +
      'StrTh Character(100),' +
      'StrThCrc INTEGER , ' +
      'Attr INTEGER,' +
      'Collection  Character(255),' +
      'Access INTEGER ,' +
      'Width INTEGER ,' +
      'Height INTEGER ,' +
      'Colors INTEGER ,' +
      'Include Logical,' +
      'Links Memo,' +
      'aTime TIME,' +
      'IsTime Logical,' +
      'FolderCRC INTEGER,' +
      'Rotated INTEGER )';

    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateImageTable() throw exception: ' + E.message);
        raise;
      end;
    end;
    Result := True;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE INDEX aID ON ImageTable(ID)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);

    SQL := 'CREATE INDEX aFolderCRC ON ImageTable(FolderCRC)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);

    SQL := 'CREATE INDEX aStrThCrc ON ImageTable(StrThCrc)';
    SetSQL(FQuery, SQL);
    ExecSQL(FQuery);

  finally
    FreeDS(FQuery);
  end;
end;

class function TDBScheme.CreateGroupsTable(CollectionFile: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try

    SQL := 'CREATE TABLE Groups ( ' +
      'ID Autoincrement , ' +
      'GroupCode Memo , ' +
      'GroupName Memo , ' +
      'GroupComment Memo , ' +
      'GroupDate Date , ' +
      'GroupFaces Memo , ' +
      'GroupAccess INTEGER , ' +
      'GroupImage LONGBINARY, ' +
      'GroupKW Memo , ' +
      'RelatedGroups Memo , ' +
      'IncludeInQuickList Logical , ' +
      'GroupAddKW Logical)';

    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throw exception: ' + E.message);
        Result := False;
        raise;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

class procedure TDBScheme.MigrateToVersion003(CollectionFile: string; Progress: TSimpleCallBackProgressRef);
const
  TotalActions = 44;
var
  FQuery: TDataSet;
  Counter: Integer;
  Errors: TStrings;

  procedure Exec(SQL: string; CurrentAction: Integer);
  begin
    try
      SetSQL(FQuery, SQL);
      ExecSQL(FQuery);
    except
      on e: Exception do
      begin
        EventLog(e);
        Errors.Add(E.Message);
      end;
    end;
    Progress(nil, TotalActions, CurrentAction);
  end;

  procedure AlterColumn(ColumnDefinition: string; CurrentAction: Integer);
  begin
    Exec('ALTER TABLE ImageTable ALTER COLUMN ' + ColumnDefinition, CurrentAction);
  end;

  procedure DropColumn(ColumnName: string; CurrentAction: Integer);
  begin
    Exec('ALTER TABLE ImageTable DROP COLUMN ' + ColumnName, CurrentAction);
  end;

  procedure RemoveNull(ColumnName, Value: string; CurrentAction: Integer);
  begin
    Exec(FormatEx('UPDATE ImageTable SET {0} = {1} WHERE {0} IS NULL', [ColumnName, Value]), CurrentAction);
  end;

  procedure AddColumn(ColumnDefinition: string; CurrentAction: Integer);
  begin
    Exec('ALTER TABLE ImageTable ADD COLUMN ' + ColumnDefinition, CurrentAction);
  end;

  function TableExists(TableName: string): Boolean;
  var
    List: TStrings;
    I: Integer;
  begin
    Result := False;

    List := TStringList.Create;
    try
      GetTableNames(FQuery, List);
      for I := 0 to List.Count - 1 do
      begin
        if AnsiLowerCase(List[I]) = AnsiLowerCase(TableName) then
          Exit(True);
      end;
    finally
      F(List);
    end;
  end;

type
  TCreateTableProc = procedure(CollectionFileName: string);

  procedure CreateTable(CreateTableProc: TCreateTableProc; CurrentAction: Integer);
  begin
    try
      CreateTableProc(CollectionFile);
    except
      on e: Exception do
      begin
        EventLog(e);
        Errors.Add(E.Message);
      end;
    end;
    Progress(nil, TotalActions, CurrentAction);
  end;

  function NextID: Integer;
  begin
    Inc(Counter);
    Result := Counter;
  end;

begin
  Counter := 0;

  Errors := TStringList.Create;
  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    if not TableExists('Groups') then
      CreateTable(@CreateGroupsTable, NextID);

    if not TableExists('Objects') then
      CreateTable(@CreateObjectsTable, NextID);

    if not TableExists('ObjectMapping') then
      CreateTable(@CreateObjectMappingTable, NextID);

    Exec('DROP INDEX aID ON ImageTable', NextID);
    Exec('DROP INDEX aFolderCRC ON ImageTable', NextID);
    Exec('DROP INDEX aStrThCrc ON ImageTable', NextID);

    AlterColumn('Name TEXT(255) NOT NULL', NextID);
    AlterColumn('FFileName Memo NOT NULL', NextID);
    AlterColumn('Comment Memo NOT NULL', NextID);
    AlterColumn('IsDate Logical NOT NULL', NextID);
    AlterColumn('DateToAdd Date NOT NULL', NextID);
    AlterColumn('Rating INTEGER NOT NULL', NextID);
    AlterColumn('Thum LONGBINARY NOT NULL', NextID);
    AlterColumn('FileSize INTEGER NOT NULL', NextID);
    AlterColumn('KeyWords Memo NOT NULL', NextID);
    AlterColumn('Groups Memo NOT NULL', NextID);
    AlterColumn('StrTh Character(100) NOT NULL', NextID);

    RemoveNull('StrThCrc', '0', NextID);
    AlterColumn('StrThCrc INTEGER NOT NULL', NextID);
    AlterColumn('Attr INTEGER NOT NULL', NextID);
    AlterColumn('Access INTEGER NOT NULL', NextID);
    AlterColumn('Width INTEGER NOT NULL', NextID);
    AlterColumn('Height INTEGER NOT NULL', NextID);
    AlterColumn('Include Logical NOT NULL', NextID);
    AlterColumn('Links Memo NOT NULL', NextID);
    AlterColumn('aTime TIME NOT NULL', NextID);
    AlterColumn('IsTime Logical NOT NULL', NextID);
    AlterColumn('FolderCRC INTEGER NOT NULL', NextID);
    AlterColumn('Rotated INTEGER NOT NULL', NextID);

    DropColumn('Owner', NextID);
    DropColumn('Collection', NextID);
    DropColumn('Colors', NextID);

    Exec('CREATE UNIQUE INDEX I_ID ON ImageTable(ID)', NextID);
    Exec('CREATE INDEX I_FolderCRC ON ImageTable(FolderCRC) WITH DISALLOW NULL', NextID);
    Exec('CREATE INDEX I_StrThCrc ON ImageTable(StrThCrc) WITH DISALLOW NULL', NextID);

    AddColumn('[Colors] TEXT(50) NOT NULL', NextID);
    AddColumn('PreviewSize INTEGER NOT NULL DEFAULT 0', NextID);
    AddColumn('ViewCount INTEGER NOT NULL DEFAULT 0', NextID);
    AddColumn('Histogram LONGBINARY NULL', NextID);
    AddColumn('DateUpdated Date NOT NULL', NextID);

    RemoveNull('Colors', '""', NextID);
    RemoveNull('PreviewSize', '0', NextID);
    RemoveNull('ViewCount', '0', NextID);
    RemoveNull('DateUpdated', '"01-01-2000"', NextID);

    try
      if Errors.Count > 0 then
        Errors.SaveToFile(CollectionFile + '.errors.log');
    except
      //ignore exceptions
    end;
  finally
    FreeDS(FQuery);
    F(Errors);
  end;

  UpdateCollectionVersion(CollectionFile, 3);
end;

class function TDBScheme.CreateObjectsTable(CollectionFile: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE TABLE Objects ( '
      + '[ObjectID] AutoIncrement PRIMARY KEY, '
      + '[ObjectType] INTEGER NOT NULL, '
      + '[ObjectUniqID] Character(40) NOT NULL, '
      + '[ObjectName] Character(255) NOT NULL, '
      + '[RelatedGroups] Memo NOT NULL, '
      + '[BirthDate] Date NOT NULL, '
      + '[Phone] Character(40) NOT NULL, '
      + '[Address] Character(255) NOT NULL, '
      + '[Company] Character(100) NOT NULL, '
      + '[JobTitle] Character(100) NOT NULL, '
      + '[IMNumber] Character(255) NOT NULL, '
      + '[Email] Character(255) NOT NULL, '
      + '[Sex] INTEGER NOT NULL, '
      + '[ObjectComment] Memo NOT NULL, '
      + '[CreateDate] Date NOT NULL, '
      + '[Image] LONGBINARY)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateObjectsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE INDEX aObjectID ON Objects(ObjectID)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateObjectsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

class function TDBScheme.CreateObjectMappingTable(CollectionFile: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'ALTER TABLE ImageTable ADD PRIMARY KEY (ID)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateObjectMappingTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE TABLE ObjectMapping ( '
      + '[ObjectMappingID] AutoIncrement PRIMARY KEY, '
      + '[ObjectID] INTEGER NOT NULL CONSTRAINT FK_ObjectID REFERENCES Objects (ObjectID) ON DELETE CASCADE, '
      + '[Left] INTEGER NOT NULL, '
      + '[Right] INTEGER NOT NULL, '
      + '[Top] INTEGER NOT NULL, '
      + '[Bottom] INTEGER NOT NULL, '
      + '[ImageWidth] INTEGER NOT NULL, '
      + '[ImageHeight] INTEGER NOT NULL, '
      + '[PageNumber] INTEGER NOT NULL, '
      + '[ImageID] INTEGER NOT NULL CONSTRAINT FK_ImageID REFERENCES ImageTable (ID) ON DELETE CASCADE)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateObjectMappingTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    SQL := 'CREATE INDEX aObjectMappingID ON ObjectMapping(ObjectMappingID)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateObjectMappingTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

class function TDBScheme.GetCollectionVersion(CollectionFile: string): Integer;
var
  SC: TSelectCommand;
  Field: TField;
begin
  Result := 0;

  SC := TSelectCommand.Create(TableSettings, CollectionFile, True);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

    try
      //low-level checking
      if (SC.Execute > 0) and (SC.DS <> nil) then
      begin
        Field := SC.DS.FindField('Version');
        if (Field <> nil) and (Field.DataType = ftInteger) then
          Result := Field.AsInteger;
      end;
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    F(SC);
  end;
end;

class procedure TDBScheme.UpdateCollectionVersion(CollectionFile: string; Version: Integer);
var
  UC: TUpdateCommand;
  SC: TSelectCommand;
  IC: TInsertCommand;
begin
  SC := TSelectCommand.Create(TableSettings, CollectionFile, True);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

    if SC.Execute < 1 then
    begin
      IC := TInsertCommand.Create(TableSettings, CollectionFile);
      try
        IC.AddParameter(TIntegerParameter.Create('Version', Version));
        IC.AddParameter(TIntegerParameter.Create('DBJpegCompressionQuality', 75));
        IC.AddParameter(TIntegerParameter.Create('ThSizePanelPreview', 100));
        IC.AddParameter(TIntegerParameter.Create('ThImageSize', 200));
        IC.AddParameter(TIntegerParameter.Create('ThHintSize', 400));

        IC.Execute;
      finally
        F(IC);
      end;
    end else
    begin
      UC := TUpdateCommand.Create(TableSettings, CollectionFile);
      try
        UC.AddParameter(TIntegerParameter.Create('Version', Version));
        UC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

        UC.Execute;
      finally
        F(UC);
      end;
    end;
  finally
    F(SC);
  end;
end;

{ TCollectionUpdateTask }

constructor TCollectionUpdateTask.Create(FileName: string);
begin
  FFileName := FileName;
end;

function TCollectionUpdateTask.Estimate: Integer;
begin
  Result := 1;
end;

function TCollectionUpdateTask.Execute(Progress: TSimpleCallBackProgressRef; CurrentVersion: Integer): Integer;
begin
  Result := 0;
end;

function TCollectionUpdateTask.Text: string;
begin
  Result := 'Task name';
end;

{ TPackCollectionTask }

constructor TPackCollectionTask.Create(FileName: string);
begin
  inherited;
  FSaveBackup := False;
end;

function TPackCollectionTask.Estimate: Integer;
begin
  Result := 100;
end;

function TPackCollectionTask.Execute(Progress: TSimpleCallBackProgressRef;
  CurrentVersion: Integer): Integer;
var
  BackupFileName: string;
begin
  Result := CurrentVersion;
  if SaveBackup then
  begin
    BackupFileName := ExtractFilePath(FileName) + GetFileNameWithoutExt(FileName) + '_' + FormatDateTime('yyyy-mm-dd HH-MM-SS', Now) + '.photodb';
    PackTable(FileName, Progress, BackupFileName);
  end else
    PackTable(FileName, Progress);
end;

function TPackCollectionTask.Text: string;
begin
  Result := TA('Check file, %', 'CollectionUpgrade');
end;

{ TMigrateToV_003_Task }

function TMigrateToV_003_Task.Estimate: Integer;
begin
  Result := 100;
end;

function TMigrateToV_003_Task.Execute(Progress: TSimpleCallBackProgressRef;
  CurrentVersion: Integer): Integer;
begin
  Result := CurrentVersion;

  if CurrentVersion < 3 then
  begin
    TDBScheme.MigrateToVersion003(FileName, Progress);
    Result := 3;
  end;
end;

function TMigrateToV_003_Task.Text: string;
begin
  Result := TA('Upgdate file, %', 'CollectionUpgrade');
end;

end.
