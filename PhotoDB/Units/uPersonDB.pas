unit uPersonDB;

interface

uses
  SysUtils, Classes, DB, CommonDBSupport, uLogger;

implementation

function ADOCreatePersonsTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE TABLE Persons ( '
      + 'PersonID AutoIncrement, '
      + 'PersonName Memo NOT NULL, '
      + 'RelatedGroups Memo NOT NULL, '
      + 'BirthDate Date NOT NULL, '
      + 'PersonPhone Memo NOT NULL, '
      + 'PersonAddress Memo NOT NULL, '
      + 'Company Memo NOT NULL, '
      + 'JobTitle Memo NOT NULL, '
      + 'IMNumber Memo NOT NULL, '
      + 'PersonEmail Memo NOT NULL, '
      + 'PersonSex INTEGER NOT NULL, '
      + 'PersonComment Memo NOT NULL, '
      + 'PersonImage LONGBINARY)';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throw exception: ' + E.message);
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
    ExecSQL(FQuery);
  finally
    FreeDS(FQuery);
  end;
end;

function ADOCreatePersonMappingTable(TableName : string) : boolean;
var
  SQL: string;
  FQuery: TDataSet;
begin
  Result := True;
  FQuery := GetQuery(TableName);
  try
    SQL := 'CREATE TABLE PersonMapping ( '
      + 'PersonMappingID AutoIncrement, '
      + 'PersonID INTEGER NOT NULL CONSTRAINT FK_PersonID REFERENCES Persons (PersonID), '
      + 'Left INTEGER NOT NULL, '
      + 'Right INTEGER NOT NULL, '
      + 'Top INTEGER NOT NULL, '
      + 'Bottom INTEGER NOT NULL, '
      + 'ImageWidth INTEGER NOT NULL, '
      + 'ImageHeight INTEGER NOT NULL, '
      + 'ImageID INTEGER NOT NULL CONSTRAINT FK_ImageID REFERENCES ImageTable (ID))';
    SetSQL(FQuery, SQL);
    try
      ExecSQL(FQuery);
    except
      on E: Exception do
      begin
        EventLog(':ADOCreateGroupsTable() throw exception: ' + E.message);
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
    ExecSQL(FQuery);
  finally
    FreeDS(FQuery);
  end;
end;

end.
