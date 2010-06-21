unit UnitDBNullQueryThread;

interface

uses
  Classes, Dolphin_DB, CommonDBSupport, DB, UnitCrypting, ActiveX;

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
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    SQL := 'Select * from '+ GetTableNameByFileName(DBName) + ' where (Rating>=6) or FFileName like "%:::%"';
    Query:=GetQuery(True);
    try
      SetSQL(Query, SQL);
      Query.Active := true;
    finally
      FreeDS(Query);
    end;
  finally
    CoUninitialize;
  end;
end;

end.
