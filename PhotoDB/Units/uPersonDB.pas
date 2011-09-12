unit uPersonDB;

interface

uses
  SysUtils, Classes, DB, CommonDBSupport, uLogger, uMemory, ADODB;

function CheckPersonTables(TableName: string): Boolean;
function ADOCreatePersonMappingTable(TableName: string): Boolean;
function ADOCreatePersonsTable(TableName: string): Boolean;

implementation

function CheckPersonTables(TableName: string): Boolean;
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
        if AnsiLowerCase(TL[I]) = 'persons' then
          PE := True;
        if AnsiLowerCase(TL[I]) = 'personmapping' then
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

function ADOCreatePersonsTable(TableName: string): Boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE TABLE Persons ( '
      + '[PersonID] AutoIncrement PRIMARY KEY, '
      + '[PersonName] Memo NOT NULL, '
      + '[RelatedGroups] Memo NOT NULL, '
      + '[BirthDate] Date NOT NULL, '
      + '[PersonPhone] Memo NOT NULL, '
      + '[PersonAddress] Memo NOT NULL, '
      + '[Company] Memo NOT NULL, '
      + '[JobTitle] Memo NOT NULL, '
      + '[IMNumber] Memo NOT NULL, '
      + '[PersonEmail] Memo NOT NULL, '
      + '[PersonSex] INTEGER NOT NULL, '
      + '[PersonComment] Memo NOT NULL, '
      + '[CreateDate] Date NOT NULL, '
      + '[PersonImage] LONGBINARY)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreatePersonsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE INDEX aPersonID ON Persons(PersonID)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreatePersonsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function ADOCreatePersonMappingTable(TableName: string): Boolean;
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
        EventLog(':ADOCreateGroupsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE TABLE PersonMapping ( '
      + '[PersonMappingID] AutoIncrement PRIMARY KEY, '
      + '[PersonID] INTEGER NOT NULL CONSTRAINT FK_PersonID REFERENCES Persons (PersonID), '
      + '[Left] INTEGER NOT NULL, '
      + '[Right] INTEGER NOT NULL, '
      + '[Top] INTEGER NOT NULL, '
      + '[Bottom] INTEGER NOT NULL, '
      + '[ImageWidth] INTEGER NOT NULL, '
      + '[ImageHeight] INTEGER NOT NULL, '
      + '[ImageID] INTEGER NOT NULL CONSTRAINT FK_ImageID REFERENCES ImageTable (ID))';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;

  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE INDEX aPersonMappingID ON PersonMapping(PersonMappingID)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throws exception: ' + E.message);
        Result := False;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

end.
