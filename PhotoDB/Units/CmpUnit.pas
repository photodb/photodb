unit CmpUnit;

interface

uses
  uDBBaseTypes,
  SysUtils,
  Classes,
  uMemory;

type
  TSpilitOptions = record
    UpDown: Boolean;
  end;

procedure SpilitWords(S: string; var Words: TStrings);
procedure SpilitWordsA(S: string; var Words: TStrings; Options: TSpilitOptions);
procedure AddWords(var S, D: Tstrings);
procedure AddWordsB(var S, D: TStrings);
procedure DeleteWords(S: TStrings; var D: TStrings); overload;
function AddWordsA(S: string; var D: string): Boolean;
function AddWordsW(S, Ig: string; var D: string): Boolean;
procedure DelSpaces(S: TStrings);
procedure DelSpacesA(var S: string);
procedure DelSpacesW(var S: string);

function WordExists(Words: TStrings; S: string): Boolean;

procedure GetCommonWords(A, B: Tstrings; var D: TStrings);
function WordsToString(Words: TStrings): string;
{$IFNDEF EXT}
function GetCommonWordsA(Words: TStringList): string;
procedure DeleteWords(var Words: string; WordsToDelete: string); overload;
procedure ReplaceWords(A, B: string; var D: string);
function VariousKeyWords(S1, S2: string): Boolean;
function SimilarTexts(A, B: string): Boolean;
function MaxStatBool(Bools: TArBoolean): Boolean;
function IsVariousBool(Bools: TArBoolean): Boolean;
function MaxStatStr(Strs: TArStrings): string;
function MaxStatInt(Ints: TArInteger): Integer;
function MaxStatDate(Dates: TArDateTime): TDateTime;
function MaxStatTime(Times: TArTime): TDateTime;

function IsVariousArStrings(Ar: TStrings): Boolean;
function IsVariousArInteger(Ar: TArInteger): Boolean;
function IsVariousDate(Dates: TArDateTime): Boolean;
function IsVariousArBoolean(Ar: TArBoolean): Boolean;
{$ENDIF}

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

procedure SpilitWordsA(S: string; var Words: TStrings; Options: TSpilitOptions);
var
  I, J, N: Integer;
  Pi_: PInteger;
begin
  if Words = nil then
    Words := TStringlist.Create;
  Words.Clear;
  S := ' ' + S + ' ';
  Pi_ := @I;
  N := 0;
  if Options.UpDown then
    repeat
      Inc(N);
      if (ValidChar(S[I])) then
        Insert(' ', S, I);
    until N + 1 > Length(S);
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

procedure AddWordsB(var S, D: TStrings);
var
  I: Integer;
begin
  for I := 0 to S.Count - 1 do
    D.Add(S[I])
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

function AddWordsW(S, Ig: string; var D: string): Boolean;
var
  I: Integer;
  S_, D_, Ig_: TStrings;
begin
  Result := False;
  S_ := TStringList.Create;
  D_ := TStringList.Create;
  Ig_ := TStringList.Create;
  try
    SpilitWords(S, S_);
    SpilitWords(D, D_);
    SpilitWords(Ig, Ig_);
    if Length(D) > 1 then
      if D[Length(D)] = ' ' then
        Delete(D, Length(D), 1);
    for I := 0 to S_.Count - 1 do
      if not WordExists(D_, S_[I]) and not WordExists(Ig_, S_[I]) then
      begin
        Result := True;
        D := D + ' ' + S_[I];
      end;
  finally
    F(S_);
    F(D_);
    F(Ig_);
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

{$IFNDEF EXT}

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

function SimilarTexts(A { Big text } , B { TextIn } : string): Boolean;
var
  I, B1, C1: Integer;
  S_, D_, C_: Tstrings;
begin
  S_ := TStringList.Create;
  D_ := TStringList.Create;
  C_ := TStringList.Create;
  try
    SpilitWords(A, S_);
    SpilitWords(B, D_);
    B1 := D_.Count;
    for I := 0 to D_.Count - 1 do
      if WordExists(S_, D_[I]) then
      begin
        C_.Add(D_[I]);
      end;
    C1 := C_.Count;
    if (B1 = 0) and (C1 <> 0) then
    begin
      Result := False;
      Exit;
    end;
    if (B1 = 0) and (C1 = 0) then
    begin
      Result := True;
      Exit;
    end;
    if ((C1) / (B1)) > 0.9 then
      Result := True
    else
      Result := False;
  finally
    F(S_);
    F(D_);
    F(C_);
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

//function MaxStat32Bit(

function MaxStatInt(Ints: TArInteger): Integer;
type
  TIntStat = record
    Int: Integer;
    Count: Integer;
  end;

  TArIntStat = array of TIntStat;
var
  I: Integer;
  Stat: TArIntStat;
  MaxC, MaxN: Integer;
  procedure AddStat(var IntStat: TArIntStat; Int: Integer);
  var
    J: Integer;
  begin
    for J := 0 to Length(IntStat) - 1 do
      if IntStat[J].Int = Int then
      begin
        IntStat[J].Count := IntStat[J].Count + 1;
        Exit;
      end;
    SetLength(IntStat, Length(IntStat) + 1);
    IntStat[Length(IntStat) - 1].Int := Int;
    IntStat[Length(IntStat) - 1].Count := 0;
  end;

begin
  Result := 0;
  if Length(Ints) = 0 then
    Exit;
  SetLength(Stat, 0);
  for I := 0 to Length(Ints) - 1 do
    AddStat(Stat, Ints[I]);
  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Int;
end;

function MaxStatStr(Strs: TArStrings): string;
type
  TStrStat = record
    Str: string;
    Count: Integer;
  end;

  TArStrStat = array of TStrStat;
var
  I: Integer;
  Stat: TArStrStat;
  MaxC, MaxN: Integer;
  procedure AddStat(var StrStat: TArStrStat; Str: string);
  var
    J: Integer;
  begin
    for J := 0 to Length(StrStat) - 1 do
      if StrStat[J].Str = Str then
      begin
        StrStat[J].Count := StrStat[J].Count + 1;
        Exit;
      end;
    SetLength(StrStat, Length(StrStat) + 1);
    StrStat[Length(StrStat) - 1].Str := Str;
    StrStat[Length(StrStat) - 1].Count := 0;
  end;

begin
  if Length(Strs) = 0 then
    Exit;
  SetLength(Stat, 0);
  for I := 0 to Length(Strs) - 1 do
    AddStat(Stat, Strs[I]);
  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
    if MaxC < Stat[I].Count then
    begin
      MaxC := Stat[I].Count;
      MaxN := I;
    end;
  Result := Stat[MaxN].Str;
end;

function IsVariousBool(Bools: TArBoolean): Boolean;
var
  I: Integer;
  B: Boolean;
begin
  Result := False;
  if Length(Bools) = 0 then
    Exit;
  B := Bools[0];
  for I := 0 to Length(Bools) - 1 do
    if B <> Bools[I] then
    begin
      Result := True;
      Break;
    end;
end;

function IsVariousDate(Dates: TArDateTime): Boolean;
var
  I: Integer;
  D: TDateTime;
begin
  Result := False;
  if Length(Dates) = 0 then
    Exit;
  D := Dates[0];
  for I := 0 to Length(Dates) - 1 do
    if D <> Dates[I] then
    begin
      Result := True;
      Break;
    end;
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

function IsVariousArInteger(Ar: TArInteger): Boolean;
var
  I, N: Integer;
begin
  Result := False;
  if Length(Ar) = 0 then
    Exit;
  N := Ar[0];
  for I := 1 to Length(Ar) - 1 do
    if N <> Ar[I] then
    begin
      Result := True;
      Break;
    end;
end;

function IsVariousArStrings(Ar: TStrings): Boolean;
var
  I: Integer;
  S: string;
begin
  Result := False;
  if Ar.Count = 0 then
    Exit;
  S := Ar[0];
  for I := 1 to Ar.Count - 1 do
    if S <> Ar[I] then
    begin
      Result := True;
      Break;
    end;
end;

function IsVariousArBoolean(Ar: TArBoolean): Boolean;
var
  I: Integer;
  B: Boolean;
begin
  Result := False;
  if Length(Ar) = 0 then
    Exit;
  B := Ar[0];
  for I := 1 to Length(Ar) - 1 do
    if B <> Ar[I] then
    begin
      Result := True;
      Break;
    end;
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
{$ENDIF}

end.
