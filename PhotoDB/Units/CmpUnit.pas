unit CmpUnit;

interface

uses
  uDBBaseTypes,
  SysUtils,
  Classes,
  uMemory;

procedure SpilitWords(S: string; var Words: TStrings);
procedure AddWords(var S, D: Tstrings);
procedure DeleteWords(S: TStrings; var D: TStrings); overload;
function AddWordsA(S: string; var D: string): Boolean;
procedure DelSpaces(S: TStrings);
procedure DelSpacesA(var S: string);
procedure DelSpacesW(var S: string);

function WordExists(Words: TStrings; S: string): Boolean;

procedure GetCommonWords(A, B: Tstrings; var D: TStrings);
function WordsToString(Words: TStrings): string;
function GetCommonWordsA(Words: TStringList): string;
procedure DeleteWords(var Words: string; WordsToDelete: string); overload;
procedure ReplaceWords(A, B: string; var D: string);
function VariousKeyWords(S1, S2: string): Boolean;
function MaxStatBool(Bools: TArBoolean): Boolean;
function MaxStatDate(Dates: TArDateTime): TDateTime;
function MaxStatTime(Times: TArTime): TDateTime;

implementation

function WordExists(Words: TStrings; S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Words.Count - 1 do
    if Words[I] = S then
    begin
      Result := True;
      Break;
    end;
end;

function ValidChar(const C: Char): Boolean;
begin
  Result := (C <> ' ') and (C <> ',') and (C <> '.');
end;

procedure SpilitWords(S: string; var Words: TStrings);
var
  I, J: Integer;
  Pi_: PInteger;
begin
  if Words = nil then
    Words := TStringList.Create;
  Words.Clear;
  S := ' ' + S + ' ';
  Pi_ := @I;
  for I := 1 to Length(S) - 1 do
  begin
    if I + 1 > Length(S) - 1 then
      Break;
    if (not ValidChar(S[I])) and ValidChar(S[I + 1]) then
      for J := I + 1 to Length(S) do
        if not ValidChar(S[J]) or (J = Length(S)) then
        begin
          Words.Add(Copy(S, I + 1, J - I - 1));
          Pi_^ := J - 1;
          Break;
        end;
  end;
  DelSpaces(Words);
end;

procedure AddWords(var S, D: TStrings);
var
  I: Integer;
begin
  for I := 0 to S.Count - 1 do
    if not WordExists(D, S[I]) then
      D.Text := D.Text + ' ' + S[I];
end;

procedure DeleteWords(S: TStrings; var D: TStrings);
var
  I: Integer;
  Temp: TStrings;
begin
  Temp := TStringList.Create;
  try
    for I := 0 to D.Count - 1 do
      if not WordExists(S, D[I]) then
        Temp.Add(D[I]);
    D.Assign(Temp);
  finally
    F(Temp);
  end;
end;

procedure DelSpaces(S: TStrings);
var
  I: Integer;
  St: string;
begin
  for I := 0 to S.Count - 1 do
  begin
    St := S[I];
    DelSpacesA(St);
    S[I] := St;
  end;
end;

procedure DelSpacesA(var S: string);
var
  I: Integer;
begin
  for I := Length(S) downto 1 do
    if S[I] = ' ' then
      Delete(S, I, 1);
end;

procedure DelSpacesW(var S: string);
var
  I: Integer;
begin
  for I := Length(S) downto 2 do
    if (S[I] = ' ') and (S[I - 1] = ' ') then
      Delete(S, I, 1);
end;

function AddWordsA(S: string; var D: string): Boolean;
var
  I: Integer;
  S_, D_: Tstrings;
begin
  Result := False;
  S_ := TStringList.Create;
  D_ := TStringList.Create;
  try
    SpilitWords(S, S_);
    SpilitWords(D, D_);
    if Length(D) > 1 then
      if D[Length(D)] = ' ' then
        Delete(D, Length(D), 1);
    for I := 0 to S_.Count - 1 do
      if not WordExists(D_, S_[I]) then
      begin
        Result := True;
        D := D + ' ' + S_[I];
      end;
  finally
    F(S_);
    F(D_);
  end;
end;

procedure ReplaceWords(A, B: string; var D: string);
var
  A_, B_, D_: TStrings;
begin
  A_ := TStringList.Create;
  B_ := TStringList.Create;
  D_ := TStringList.Create;
  try
    SpilitWords(A, A_);
    SpilitWords(B, B_);
    SpilitWords(D, D_);
    DeleteWords(A_, D_);
    AddWords(B_, D_);
    D := WordsToString(D_);
  finally
    F(A_);
    F(B_);
    F(D_);
  end;
end;

procedure GetCommonWords(A, B: TStrings; var D: TStrings);
var
  I: Integer;
begin
  if D = nil then
    D := TStringList.Create;
  D.Clear;
  for I := 0 to A.Count - 1 do
    if WordExists(B, A[I]) then
      D.Add(A[I])
end;

function WordsToString(Words: TStrings): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Words.Count - 1 do
    if Result = '' then
      Result := Words[0]
    else
      Result := Result + ' ' + Words[I];
  DelSpacesW(Result);
end;

function GetCommonWordsA(Words: TStringList): string;
var
  Common, Temp, Str: TStrings;
  I: Integer;
begin
  if Words.Count = 0 then
    Exit;

  Common := TStringList.Create;
  Temp := TStringList.Create;
  Str := TStringList.Create;
  try
    SpilitWords(Words[0], Common);
    for I := 1 to Words.Count - 1 do
    begin
      SpilitWords(Words[I], Temp);
      GetCommonWords(Common, Temp, Str);
      Common.Assign(Str);
      if Common.Count = 0 then
        Break;
    end;
    Result := WordsToString(Common);
  finally
    F(Common);
    F(Temp);
    F(Str);
  end;
end;

function VariousKeyWords(S1, S2: string): Boolean;
var
  I: Integer;
  A1, A2: TStrings;
begin
  Result := False;
  A1 := Tstringlist.Create;
  A2 := Tstringlist.Create;
  try
    SpilitWords(S1, A1);
    SpilitWords(S2, A2);
    for I := 1 to A1.Count do
      if not WordExists(A2, A1[I - 1]) then
      begin
        Result := True;
        Exit;
      end;
    for I := 1 to A2.Count do
      if not WordExists(A1, A2[I - 1]) then
      begin
        Result := True;
        Exit;
    end;
  finally
    F(A1);
    F(A2);
  end;
end;

function MaxStatDate(Dates: TArDateTime): TDateTime;
type
  TDateStat = record
    Date: TDateTime;
    Count: Integer;
  end;

  TArDateStat = array of TDateStat;

var
  I: Integer;
  Stat: TArDateStat;
  MaxC, MaxN: Integer;

  procedure AddStat(var DatesStat: TArDateStat; Date: TDateTime);
  var
    J: Integer;
  begin
    for J := 0 to Length(DatesStat) - 1 do
      if DatesStat[J].Date = Date then
      begin
        DatesStat[J].Count := DatesStat[J].Count + 1;
        Exit;
      end;
    SetLength(DatesStat, Length(DatesStat) + 1);
    DatesStat[Length(DatesStat) - 1].Date := Date;
    DatesStat[Length(DatesStat) - 1].Count := 0;
  end;

begin
  Result := 0;
  if Length(Dates) = 0 then
    Exit;
  SetLength(Stat, 0);
  for I := 0 to Length(Dates) - 1 do
    AddStat(Stat, Dates[I]);
  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Date;
end;

function MaxStatTime(Times: TArTime): TDateTime;
type
  TDateStat = record
    Time: TDateTime;
    Count: Integer;
  end;

  TArDateStat = array of TDateStat;

var
  I: Integer;
  Stat: TArDateStat;
  MaxC, MaxN: Integer;

  procedure AddStat(var DatesStat: TArDateStat; Time: TDateTime);
  var
    J: Integer;
  begin
    for J := 0 to Length(DatesStat) - 1 do
      if DatesStat[J].Time = Time then
      begin
        DatesStat[J].Count := DatesStat[J].Count + 1;
        Exit;
      end;
    SetLength(DatesStat, Length(DatesStat) + 1);
    DatesStat[Length(DatesStat) - 1].Time := Time;
    DatesStat[Length(DatesStat) - 1].Count := 0;
  end;

begin
  Result := 0;
  if Length(Times) = 0 then
    Exit;
  SetLength(Stat, 0);
  for I := 0 to Length(Times) - 1 do
    AddStat(Stat, Times[I]);
  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Time;
end;

function MaxStatBool(Bools: TArBoolean): Boolean;
type
  TBoolStat = record
    Bool: Boolean;
    Count: Integer;
  end;

  TArBoolStat = array of TBoolStat;
var
  I: Integer;
  Stat: TArBoolStat;
  MaxC, MaxN: Integer;
  procedure AddStat(var BoolStat: TArBoolStat; Bool: Boolean);
  var
    J: Integer;
  begin
    for J := 0 to Length(BoolStat) - 1 do
      if BoolStat[J].Bool = Bool then
      begin
        BoolStat[J].Count := BoolStat[J].Count + 1;
        Exit;
      end;
    SetLength(Boolstat, Length(BoolStat) + 1);
    BoolStat[Length(BoolStat) - 1].Bool := Bool;
    BoolStat[Length(BoolStat) - 1].Count := 0;
  end;

begin
  Result := False;
  if Length(Bools) = 0 then
    Exit;
  SetLength(Stat, 0);
  for I := 0 to Length(Bools) - 1 do
    AddStat(Stat, Bools[I]);
  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Bool;
end;

procedure DeleteWords(var Words: string; WordsToDelete: string);
var
  S, D: TStrings;
begin
  S := TStringList.Create;
  D := TStringList.Create;
  try
    SpilitWords(Words, D);
    SpilitWords(WordsToDelete, S);
    DeleteWords(S, D);
    Words := WordsToString(D);
  finally
    F(S);
    F(D);
  end;
end;

end.
