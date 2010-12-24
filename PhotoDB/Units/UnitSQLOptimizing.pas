unit UnitSQLOptimizing;

interface

uses
  CmpUnit, UnitGroupsWork, UnitLinksSupport, uDBBaseTypes;

type
  TOneSQL = record
    Value: string;
    IDs: TArInteger;
    Tag: Integer;
  end;

  TSQLList = array of TOneSQL;

const
  VALUE_TYPE_ERROR    = 0;
  VALUE_TYPE_KEYWORDS = 1;
  VALUE_TYPE_GROUPS   = 2;
  VALUE_TYPE_LINKS    = 3;

procedure FreeSQLList(var SQLList : TSQLList);
procedure AddQuery(var SQLList : TSQLList; Value : string; ID : integer);
procedure PackSQLList(var SQLList : TSQLList; ValueType : integer);

implementation

procedure FreeSQLList(var SQLList: TSQLList);
begin
  SetLength(SQLList, 0);
end;

procedure AddQuery(var SQLList: TSQLList; Value: string; ID: Integer);
var
  L: Integer;
begin
  L := Length(SQLList);
  SetLength(SQLList, L + 1);
  SQLList[L].Value := Value;
  SetLength(SQLList[L].IDs, 1);
  SQLList[L].IDs[0] := ID;
end;

procedure PackSQLList(var SQLList: TSQLList; ValueType: Integer);
var
  I, J, N, L: Integer;

const
  limit = 50;

  function Compare(Value1, Value2: string): Boolean;
  begin
    Result := False;
    case ValueType of
      VALUE_TYPE_KEYWORDS:
        begin
          Result := not VariousKeyWords(Value1, Value2);
        end;
      VALUE_TYPE_GROUPS:
        begin
          Result := CompareGroups(Value1, Value2);
        end;
      VALUE_TYPE_LINKS:
        begin
          Result := CompareLinks(Value1, Value2);
        end;
    end;
  end;

  procedure Merge(var D: TOneSQL; S: TOneSQL);
  var
    I: Integer;
  begin
    for I := 0 to Length(S.IDs) - 1 do
    begin
      SetLength(D.IDs, Length(D.IDs) + 1);
      D.IDs[Length(D.IDs) - 1] := S.IDs[I];
    end;
  end;

begin
  // set tag
  for I := Length(SQLList) - 1 downto 0 do
    SQLList[I].Tag := 0;
  // merge queries
  for I := Length(SQLList) - 1 downto 0 do
  begin
    for J := I - 1 downto 0 do
    begin
      if (SQLList[I].Tag = 0) and (SQLList[J].Tag = 0) then
        if Compare(SQLList[I].Value, SQLList[J].Value) then
        begin
          Merge(SQLList[J], SQLList[I]);
          SQLList[I].Tag := 1;
          Break;
        end;
    end;
  end;
  // cleaning
  for I := Length(SQLList) - 1 downto 0 do
    if (SQLList[I].Tag = 1) then
    begin
      for J := I to Length(SQLList) - 2 do
        SQLList[J] := SQLList[J + 1];
      SetLength(SQLList, Length(SQLList) - 1);
    end;
  // alloc to LIMIT (limit = 16)

  L := Length(SQLList);

  for I := 0 to L - 1 do
  begin
    while Length(SQLList[I].IDs) > Limit do
    begin
      N := Length(SQLList);
      SetLength(SQLList, N + 1);
      SetLength(SQLList[N].IDs, 0);
      SQLList[N].Value := SQLList[I].Value;
      for J := 1 to 16 do
      begin
        SetLength(SQLList[N].IDs, Length(SQLList[N].IDs) + 1);
        SQLList[N].IDs[Length(SQLList[N].IDs) - 1] := SQLList[I].IDs[Length(SQLList[I].IDs) - J];
      end;
      SetLength(SQLList[I].IDs, Length(SQLList[I].IDs) - 16);
    end;
  end;
end;

end.
