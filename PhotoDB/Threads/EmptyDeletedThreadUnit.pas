unit EmptyDeletedThreadUnit;

interface

uses
 dolphin_db, windows, Messages, CommCtrl, Dialogs, Classes, DBGrids, DB,
 DBTables, SysUtils,ComCtrls, Graphics, jpeg, registry;

type
  EmptyDeletedThread = class(TThread)
  private
  fQuery : TQuery;
  fReqQuery : TQuery;
  fUpdateQuery : TQuery;
  FMaxPosition : integer;
  FPosition : integer;
  procedure UpdateProgress;
  procedure UpdateMaxProgress;
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses CleaningForm;

{ EmptyDeletedThread }

procedure EmptyDeletedThread.Execute;
var i,j:integer;
SetFields:string;
UpdatedComment, UpdatedKeyWords  : string;  UpdatedRating: integer;
begin
 Priority:=tpIdle;
 fQuery:=TQuery.Create(nil);
 fReqQuery:=TQuery.Create(nil);
 fUpdateQuery:=TQuery.Create(nil);
 fQuery.Active:=false;
 fQuery.sql.text:='SELECT * FROM "'+dbname+'"'+'WHERE Attr = '+inttostr(db_attr_not_exists);
 fQuery.active:=true;
 fQuery.First;
 FMaxPosition := fQuery.RecordCount;
 Synchronize(UpdateMaxProgress);
 for i:=1 to fQuery.RecordCount do
 begin
  FPosition:=i;
  Synchronize(UpdateProgress);
  fReqQuery.Active:=false;
  fReqQuery.sql.text:='SELECT * FROM "'+dbname+'"'+' WHERE (StrTh = :str)';// AND (Attr <> '+inttostr(db_attr_not_exists)+')';
  fReqQuery.params[0].asstring:=fQuery.FieldByName('StrTh').AsString;
  fReqQuery.Active:=true;
  if fReqQuery.RecordCount>1 then
  begin
   For j:=1 to fReqQuery.RecordCount do
   begin
    if fReqQuery.FieldByName('ID').AsInteger<>fQuery.FieldByName('ID').AsInteger then
    begin
     if not (FileExists(fQuery.FieldByName('FFileName').AsString)) and (FileExists(fReqQuery.FieldByName('FFileName').AsString)) then
     begin
      If fReqQuery.FieldByName('Comment').AsString<>'' then
      UpdatedComment:=fReqQuery.FieldByName('Comment').AsString+#10#13+'P.S. '+fQuery.FieldByName('Comment').AsString else
      UpdatedComment:=fQuery.FieldByName('Comment').AsString;
      If fReqQuery.FieldByName('KeyWords').AsString<>'' then
      UpdatedKeyWords:=fReqQuery.FieldByName('KeyWords').AsString+' '+fQuery.FieldByName('KeyWords').AsString else
      UpdatedKeyWords:=fQuery.FieldByName('KeyWords').AsString;
      If fQuery.FieldByName('Rating').AsInteger=0 then
      UpdatedRating:=fReqQuery.FieldByName('Rating').AsInteger else
      UpdatedRating:=fQuery.FieldByName('Rating').AsInteger;
      SetFields:=' Comment = "'+UpdatedComment+'", KeyWords = "'+UpdatedKeyWords+'", Rating = '+inttostr(UpdatedRating);
      fUpdateQuery.Active:=false;
      fUpdateQuery.SQL.Text:='Update "'+dbname+'"'+' Set '+ SetFields + ' WHERE ID='+inttostr(fReqQuery.FieldByName('ID').AsInteger);
      fUpdateQuery.ExecSQL;
      fUpdateQuery.Active:=false;
      fUpdateQuery.SQL.Text:='Delete from "'+dbname+'"'+' Where ID='+inttostr(fQuery.FieldByName('ID').AsInteger);
      fUpdateQuery.ExecSQL;
     end;
     if fQuery.FieldByName('FFileName').AsString=fReqQuery.FieldByName('FFileName').AsString then
     begin
      fUpdateQuery.Active:=false;
      fUpdateQuery.SQL.Text:='Delete from "'+dbname+'"'+' Where ID='+inttostr(fQuery.FieldByName('ID').AsInteger);
      fUpdateQuery.ExecSQL;
     end
    end;
    fReqQuery.Next;
   end;
  end;
  fQuery.Next;
 end;
 fQuery.Free;
 fReqQuery.Free;
 fUpdateQuery.Free;
end;

procedure EmptyDeletedThread.UpdateMaxProgress;
begin
CleaningForm1.DmProgress2.MinValue:=1;
CleaningForm1.DmProgress2.MaxValue:=FMaxPosition;
end;

procedure EmptyDeletedThread.UpdateProgress;
begin
CleaningForm1.DmProgress2.Position:=Fposition;
end;

end.
