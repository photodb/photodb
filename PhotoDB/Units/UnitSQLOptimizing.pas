unit UnitSQLOptimizing;

interface

uses Dolphin_DB, CmpUnit, UnitGroupsWork, UnitLinksSupport, UnitDBDeclare;

type
  TOneSQL = record
   Value : String;
   IDs : TArInteger;
   Tag : integer;
  end;

  TSQLList = array of TOneSQL;

  Const

   VALUE_TYPE_ERROR    = 0;
   VALUE_TYPE_KEYWORDS = 1;
   VALUE_TYPE_GROUPS   = 2;
   VALUE_TYPE_LINKS    = 3;

procedure FreeSQLList(var SQLList : TSQLList);
procedure AddQuery(var SQLList : TSQLList; Value : string; ID : integer);
procedure PackSQLList(var SQLList : TSQLList; ValueType : integer);

implementation

procedure FreeSQLList(var SQLList : TSQLList);
begin
 SetLength(SQLList,0);
end;

procedure AddQuery(var SQLList : TSQLList; Value : string; ID : integer);
var
  l : integer;
begin
 l:=Length(SQLList);
 SetLength(SQLList,l+1);
 SQLList[l].Value:=Value;
 SetLength(SQLList[l].IDs,1);
 SQLList[l].IDs[0]:=ID;
end;

procedure PackSQLList(var SQLList : TSQLList; ValueType : integer);
var
  i, j, n, l : integer;

const
  limit = 50;

  function Compare(Value1, Value2 : string) : boolean;
  begin
   result:=false;
   Case ValueType of
   VALUE_TYPE_KEYWORDS:
    begin
     Result:=not VariousKeyWords(Value1,Value2);
    end;
   VALUE_TYPE_GROUPS:
    begin
     Result:=CompareGroups(Value1,Value2);
    end;
   VALUE_TYPE_LINKS:
    begin
     Result:=CompareLinks(Value1,Value2);
    end;
   end;
  end;

  procedure Merge(var D : TOneSQL; S : TOneSQL);
  var
    i : integer;
  begin
   for i:=0 to Length(S.IDs)-1 do
   begin
    SetLength(D.IDs,Length(D.IDs)+1);
    D.IDs[Length(D.IDs)-1]:=S.IDs[i];
   end;
  end;

begin
 //set tag
 for i:=Length(SQLList)-1 downto 0 do
 SQLList[i].Tag:=0;
 //merge queries
 for i:=Length(SQLList)-1 downto 0 do
 begin
  for j:=i-1 downto 0 do
  begin
   if (SQLList[i].Tag=0) and (SQLList[j].Tag=0) then
   if Compare(SQLList[i].Value,SQLList[j].Value) then
   begin
    Merge(SQLList[j],SQLList[i]);
    SQLList[i].Tag:=1;
    break;
   end;
  end;
 end;
 //cleaning
 for i:=Length(SQLList)-1 downto 0 do
 if (SQLList[i].Tag=1) then
 begin
  for j:=i to Length(SQLList)-2 do
  SQLList[j]:=SQLList[j+1];
  SetLength(SQLList,Length(SQLList)-1);
 end;
 //alloc to LIMIT (limit = 16)

 l:=Length(SQLList);

 for i:=0 to l-1 do
 begin
  While Length(SQLList[i].IDs)>limit do
  begin
   n:=Length(SQLList);
   SetLength(SQLList,n+1);
   SetLength(SQLList[n].IDs,0);
   SQLList[n].Value:=SQLList[i].Value;
   for j:=1 to 16 do
   begin
    SetLength(SQLList[n].IDs,length(SQLList[n].IDs)+1);
    SQLList[n].IDs[length(SQLList[n].IDs)-1]:=SQLList[i].IDs[Length(SQLList[i].IDs)-j];
   end;
   SetLength(SQLList[i].IDs,length(SQLList[i].IDs)-16);
  end;
 end;

end;

end.
