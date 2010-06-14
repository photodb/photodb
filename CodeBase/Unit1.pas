unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBTables, DB, Grids, DBGrids, StrUtils, ActivationFunctions,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    DBGrid1: TDBGrid;
    Table1: TTable;
    DataSource1: TDataSource;
    Query1: TQuery;
    Button1: TButton;
    Panel1: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  Form1: TForm1;

const
 abs_alldb=['0'..'9','à'..'ÿ','À'..'ß','¸','¨','a'..'z','A'..'Z','/','|','\','<','>','''','?','*',':','.','-','_','@',' ','$','"','(',')'];

 implementation

{$R *.dfm}

procedure DelSpacesA(var S : string);
var
  i : integer;
begin
 for i:=length(s) downto 1 do
 if not (s[i] in abs_alldb) then delete(s,i,1);
end;

procedure DelSpaces(var S : Tstrings);
var
  i : integer;
  st : string;
begin
 for i:=0 to S.Count-1 do
 begin
  st:=s[i];
  DelSpacesA(st);
  s[i]:=st;
 end;
end;

procedure SpilitWords(S : string; var Words_ : TStrings);
var
  i, j : integer;
  pi_ : PInteger;
begin
 if Words_=nil then Words_:=tstringlist.Create;
 Words_.Clear;
 s:=' '+s+' ';
 pi_:=@i;
 for i:=1 to length(s)-1 do
 begin
  if i+1>length(s)-1 then break;
  if (not (s[i] in abs_alldb)) and (s[i+1] in abs_alldb) then
  for j:=i+1 to length(s) do
  if not (s[j] in abs_alldb) or (j=length(s)) then
  begin
   Words_.Add(copy(s,i+1,j-i-1));
   pi_^:=j-1;
   break;
  end;
 end;
 DelSpaces(Words_);
end;

procedure VerifyCodeID(FileName : String);
var
  fQuery : TQuery;
  sql : string;
begin
 DeleteFile(FileName);
// if FileExists(FileName) then exit;
 fQuery:=TQuery.Create(nil);
 sql:= 'CREATE TABLE "'+FileName+'" ( '+
       'ID  AUTOINC , '+
       'Name CHAR(255) , '+
       'EMail CHAR(255) , ' +
       'Code CHAR(16) , ' +
       'ACode CHAR(16)  , ' +
       'ComputerID CHAR(16) , ' +
       'Attr INTEGER , ' +
       'Version CHAR(5) , ' +
       'ADate Date )';
  fQuery.sql.text:=sql;
  try
  fQuery.ExecSQL;
  except
  end;
 fQuery.free;
end;

procedure AddField(Field : String; Table : TTable);
var
  i, n : integer;
  Name, EMail, Code, ACode, ComputerID, Date, Version : string;
  Fields : TStrings;
begin
 if Field='' then exit;
 if Field[1]='-' then exit;
 Fields := TStringList.Create;
 SpilitWords(Field,Fields);
 if Fields.Count<5 then exit;
 Name:=Fields[0];
 EMail:=Fields[1];
 Code:=Fields[2];
 ACode:=Fields[3];

 Table.Edit;
 Table.Append;
 Table.FieldByName('Name').AsString:=Name;
 Table.FieldByName('EMail').AsString:=EMail;
 Table.FieldByName('Code').AsString:=Code;
 Table.FieldByName('ACode').AsString:=ACode;
 Table.FieldByName('ComputerID').AsString:=GetComputerID(Code);
 Table.FieldByName('Version').AsString:=Fields[4];//GetCodeVersionStr(Code);

 Table.Post;
 Table.FlushBuffers;
 Fields.free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Records : TStrings;
  i : integer;
begin
 VerifyCodeID('c:\1.db');
 Table1.TableName:='c:\1.db';
 Table1.Active:=true;
 for i:=0 to Table1.RecordCount-1 do
 begin
  Table1.Edit;
  Table1.Delete;
  Table1.FlushBuffers;
 end;
 Records := TStringList.Create;
 Records.LoadFromFile('C:\Documents and Settings\Dolphin\Desktop\base.txt');
 for i:=0 to Records.Count-1 do
 AddField(#9+Records[i],Table1);
 Records.free;
{ Table1.Edit;
 Table1.ClearFields;
 Table1.Post;   }
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, n : integer;
  s1,s2, sql, v1,v2 : string;
  x : array of integer;
begin                                       {where (not (ComputerID="00000000"))}
  Query1.SQL.Text:='Select * from "c:\1.db"  order by EMail';
  Query1.open;
  Query1.First;
  SetLength(x,0);
  for i:=1 to Query1.RecordCount do
  begin
   s1:=Query1.FieldByName('EMail').AsString;
   v1:=Query1.FieldByName('Version').AsString;
   n:=Query1.FieldByName('ID').AsInteger;
   Query1.Next;
   s2:=Query1.FieldByName('EMail').AsString;
   v2:=Query1.FieldByName('Version').AsString;
   if (AnsiLowerCase(s1)=AnsiLowerCase(s2)) and (AnsiLowerCase(v1)<>AnsiLowerCase(v2)) then
   begin
    SetLength(x,Length(x)+1);
    x[Length(x)-1]:=n;
    SetLength(x,Length(x)+1);
    x[Length(x)-1]:=Query1.FieldByName('ID').AsInteger;
   end;
  end;
  sql:='Select * from "c:\1.db" where ID in (';
  for i:=0 to Length(x)-1 do
  begin
   if i<>0 then sql:=sql+','+inttostr(x[i]) else sql:=sql+inttostr(x[i])
  end;
  sql:=sql+')  order by EMail';
  Query1.Active:=false;
  Query1.SQL.Text:=sql;
  Query1.open;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db" where Version="1.7"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db" where Version="1.8"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db" where Version="1.9"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db" where Version="2.0"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select Count(*) from "c:\1.db" where Version="1.6"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select Count(*) from "c:\1.db" where Version="1.7"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select Count(*) from "c:\1.db" where Version="1.8"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select Count(*) from "c:\1.db" where Version="1.9"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select Count(*) from "c:\1.db" where Version="2.0"';
  Query1.open;
  Query1.First;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Query1.SQL.Text:='Select * from "c:\1.db" where Version="1.6"';
  Query1.open;
  Query1.First;
end;

end.
