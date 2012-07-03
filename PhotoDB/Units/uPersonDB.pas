unit uPersonDB;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  Data.Win.ADODB,
  uMemory,
  uLogger,
  CommonDBSupport;

function CheckObjectTables(TableName: string): Boolean;
function ADOCreateObjectMappingTable(TableName: string): Boolean;
function ADOCreateObjectsTable(TableName: string): Boolean;

implementation

function CheckObjectTables(TableName: string): Boolean;
var
  FQuery: TDataSet;
  TL: TStringList;
  PE, PME: Boolean;
  I: Integer;
begin
  FQuery := GetQuery(TableName);
  try
    TL := TStringList.Create;
    try
      TADOQuery(FQuery).Connection.GetTableNames(TL, False);

      PE := False;
      PME := False;
      for I := 0 to TL.Count - 1 do
      begin
        if AnsiLowerCase(TL[I]) = 'objects' then
          PE := True;
        if AnsiLowerCase(TL[I]) = 'objectmapping' then
          PME := True;

      end;

      Result := PME and PE;
    finally
      F(TL);
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function ADOCreateObjectsTable(TableName: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
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

  FQuery := GetQuery(TableName);
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

function ADOCreateObjectMappingTable(TableName: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;

  FQuery := GetQuery(TableName);
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

  FQuery := GetQuery(TableName);
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

  FQuery := GetQuery(TableName);
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

end.
