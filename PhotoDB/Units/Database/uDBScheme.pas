unit uDBScheme;

interface

uses
  System.SysUtils,
  Data.DB,

  uConstants,
  uMemory,
  uLogger,
  uDBConnection,
  uDBClasses;

const
  CURRENT_DB_SCHEME_VERSION = 3;

type
  TDBScheme = class
  private
    class procedure CreateDatabaseFile(CollectionFile: string);

    class function CreateSettingsTable(CollectionFile: string): Boolean;
    class function CreateImageTable(CollectionFile: string): Boolean;
    class function CreateGroupsTable(CollectionFile: string): Boolean;
    class function CreateObjectMappingTable(CollectionFile: string): Boolean;
    class function CreateObjectsTable(CollectionFile: string): Boolean;

    class function GetCollectionVersion(CollectionFile: string): Integer;
    class procedure UpdateCollectionVersion(CollectionFile: string; Version: Integer);

    //v2 is base version
    class procedure MigrateToVersion003(CollectionFile: string);
  public
    class function CreateCollection(CollectionFile: string): Boolean;
    class function UpdateCollection(CollectionFile: string): Boolean;
    class function IsValidCollectionFile(CollectionFile: string): Boolean;
    class function IsOldColectionFile(CollectionFile: string): Boolean;
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

  UpdateCollection(CollectionFile);
end;

class function TDBScheme.UpdateCollection(CollectionFile: string): Boolean;
begin
  MigrateToVersion003(CollectionFile);

  Result := True;
end;

class function TDBScheme.IsOldColectionFile(CollectionFile: string): Boolean;
var
  Version: Integer;
begin
  Version := GetCollectionVersion(CollectionFile);
  Result := (1 > Version) and (Version < CURRENT_DB_SCHEME_VERSION);
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

  FQuery := GetQuery(CollectionFile);
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
      'Groupfaces Memo , ' +
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

class procedure TDBScheme.MigrateToVersion003(CollectionFile: string);
var
  FQuery: TDataSet;

  procedure Exec(SQL: string);
  begin
    try
      SetSQL(FQuery, SQL);
      ExecSQL(FQuery);
    except
      on e: Exception do
        EventLog(e);
      //TODO: raise
    end;
  end;

  procedure AlterColumn(ColumnDefinition: string);
  begin
    Exec('ALTER TABLE ImageTable ALTER COLUMN ' + ColumnDefinition);
  end;

  procedure DropColumn(ColumnName: string);
  begin
    Exec('ALTER TABLE ImageTable DROP COLUMN ' + ColumnName);
  end;

begin
  FQuery := GetQuery(CollectionFile, True, dbilExclusive);
  try
    Exec('DROP INDEX aID ON ImageTable');
    Exec('DROP INDEX aFolderCRC ON ImageTable');
    Exec('DROP INDEX aStrThCrc ON ImageTable');

    AlterColumn('ID Autoincrement NOT NULL');
    AlterColumn('Name Character(255) NOT NULL');
    AlterColumn('FFileName Memo NOT NULL');
    AlterColumn('Comment Memo NOT NULL');
    AlterColumn('IsDate Logical NOT NULL');
    AlterColumn('DateToAdd Date NOT NULL');
    AlterColumn('Rating INTEGER NOT NULL');
    AlterColumn('Thum LONGBINARY NOT NULL');
    AlterColumn('FileSize INTEGER NOT NULL');
    AlterColumn('KeyWords Memo NOT NULL');
    AlterColumn('Groups Memo NOT NULL');
    AlterColumn('StrTh Character(100) NOT NULL');
    AlterColumn('StrThCrc INTEGER NOT NULL');
    AlterColumn('Attr INTEGER NOT NULL');
    AlterColumn('Access INTEGER NOT NULL');
    AlterColumn('Width INTEGER NOT NULL');
    AlterColumn('Height INTEGER NOT NULL');
    AlterColumn('Include Logical NOT NULL');
    AlterColumn('Links Memo NOT NULL');
    AlterColumn('aTime TIME NOT NULL');
    AlterColumn('IsTime Logical NOT NULL');
    AlterColumn('FolderCRC INTEGER NOT NULL');
    AlterColumn('Rotated INTEGER NOT NULL');

    DropColumn('Owner');
    DropColumn('Collection');
    DropColumn('Colors');

    Exec('CREATE UNIQUE INDEX I_ID ON ImageTable(ID) WITH PRIMARY DISALLOW NULL');
    Exec('CREATE INDEX I_FolderCRC ON ImageTable(FolderCRC) WITH DISALLOW NULL');
    Exec('CREATE INDEX I_StrThCrc ON ImageTable(StrThCrc) WITH DISALLOW NULL');

  finally
    FreeDS(FQuery);
  end;

  UpdateCollectionVersion(CollectionFile, 003);
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

  SC := TSelectCommand.Create(ImageTable, CollectionFile, True);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TCustomConditionParameter.Create('1 = 1'));

    //low-level checking
    if (SC.Execute > 0) and (SC.DS <> nil) then
    begin
      Field := SC.DS.FindField('Version');
      if (Field <> nil) and (Field.DataType = ftInteger) then
        Result := Field.AsInteger;
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


end.
