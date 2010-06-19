unit UnitDBNullQueryThread;

interface

uses
  Classes, Dolphin_DB, CommonDBSupport, DB, UnitCrypting;

type
  TDBNullQueryThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ TDBNullQueryThread }

procedure TDBNullQueryThread.Execute;
var
  Query : TDataSet;
  SQL : string;
begin
  SQL := 'Select * from '+ GetTableNameByFileName(DBName) + ' where (Rating>=6)';
  Query:=GetQuery;
  try
    SetSQL(Query, SQL);
    Query.Active := true;
  finally
    FreeDS(Query);
  end;
end;

end.
