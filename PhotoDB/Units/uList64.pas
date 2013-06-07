unit uList64;

interface

uses
  Generics.Collections,
  SysUtils;

type
  TList64 = class(TList<Int64>)
  private
    function GetMaxStatDateTime: TDateTime;
    function GetMaxStatInt64: Int64;
    function GetMaxStatInteger: Integer;
    function GetMaxStatBoolean: Boolean;
    function GetHasVarValues: Boolean;
  public
    function Add(Item: TDateTime): Integer; overload;
    function Add(Item: Integer): Integer; overload;
    function Add(Item: Boolean): Integer; overload;
    property MaxStatInt64: Int64 read GetMaxStatInt64;
    property MaxStatInteger: Integer read GetMaxStatInteger;
    property MaxStatDateTime: TDateTime read GetMaxStatDateTime;
    property MaxStatBoolean: Boolean read GetMaxStatBoolean;
    property HasVarValues: Boolean read GetHasVarValues;
  end;

implementation

{ TList64 }

function TList64.Add(Item: TDateTime): Integer;
var
  Value: Int64;
begin
  System.Move(Item, Value, SizeOf(TDateTime));
  Result := Add(Value);
end;

function TList64.Add(Item: Integer): Integer;
var
  Value: Int64;
begin
  Value := Item;
  Result := Add(Value);
end;

function TList64.Add(Item: Boolean): Integer;
var
  Value: Int64;
begin
  if Item then
    Value := 1
  else
    Value := 0;
  Result := Add(Value);
end;

function TList64.GetHasVarValues: Boolean;
var
  FirstValue: Int64;
  I: Integer;
begin
  Result := False;
  if Count = 0 then
    Exit;
  FirstValue := Self[0];
  for I := 1 to Count - 1 do
    if FirstValue <> Self[I] then
    begin
      Result := True;
      Break;
    end;
end;

function TList64.GetMaxStatInt64: Int64;

type
  TDateStat = record
    Value: Int64;
    Count: Integer;
  end;

  TCompareArray = array of TDateStat;

var
  I: Integer;
  Stat: TCompareArray;
  MaxC, MaxN: Integer;

  procedure AddStat(Value: Int64);
  var
    J: Integer;
    C: Integer;
  begin
    for J := 0 to Length(Stat) - 1 do
      if Stat[J].Value = Value then
      begin
        Stat[J].Count := Stat[J].Count + 1;
        Exit;
      end;
    C := Length(Stat);
    SetLength(Stat, C + 1);
    Stat[C].Value := Value;
    Stat[C].Count := 1;
  end;

begin
  Result := 0;
  if Count = 0 then
    Exit;

  SetLength(Stat, 0);
  for I := 0 to Count - 1 do
    AddStat(Self[I]);

  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Value;
end;

function TList64.GetMaxStatDateTime: TDateTime;
var
  MaxValue: Int64;
begin
  MaxValue := MaxStatInt64;
  System.Move(MaxValue, Result, SizeOf(TDateTime));
  if Result < 1900 then
    Result := 1900;
end;

function TList64.GetMaxStatInteger: Integer;
begin
  Result := Integer(MaxStatInt64);
end;

function TList64.GetMaxStatBoolean: Boolean;
begin
  Result := MaxStatInt64 <> 0;
end;

end.
