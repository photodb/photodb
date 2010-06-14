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
 FreeOnTerminate:=true;                                                                                                                                                            //impossible
 SQL:='Select * from '+GetTableNameByFileName(DBName)+' where ((FFileName like "%%%") or (Comment like "%%%") or (KeyWords like "%%%")) AND (Groups like "%%") AND (Attr<> 1) AND (Rating>=6) AND (Access=0) AND (Access=0) AND (Attr<>1) order by DateToAdd DESC, aTime DESC';
 Query:=GetQuery;
 try
  SetSQL(Query,SQL);
  Query.Active:=true;
 except
 end;
 FreeDS(Query);
end;

end.
