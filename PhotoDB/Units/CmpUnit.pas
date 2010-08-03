unit CmpUnit;

interface
//{$DEFINE EXT}
uses
{$IFNDEF EXT}
Dolphin_DB,  UnitDBDeclare,
{$ENDIF}

{$IFDEF EXT}
//dm,
{$ENDIF}
Classes;

type
  TCompOptions = record
  AddNewRecords : Boolean;
  AddRecordsWithoutFiles : Boolean;
  AddRating : Boolean;
  AddRotate : Boolean;
  AddPrivate : Boolean;
  AddKeyWords : Boolean;
  AddGroups : Boolean;
  AddNilComment : Boolean;
  AddComment : Boolean;
  AddNamedComment : Boolean;
  AddDate : Boolean;
  AddLinks : Boolean;
  IgnoreWords : Boolean;
  IgWords : string;
  Autor : string;
  WordsToReplace : array[1..4] of String;
  WordsReplace : array[1..4] of String;
  UseScanningByFileName : boolean;
 end;

type
  TSpilitOptions = record
  UpDown : boolean;
 end;

procedure SpilitWords(S : string; var Words_ : TStrings);
procedure SpilitWordsA(S : string; var Words_ : TStrings; options : TSpilitOptions);
procedure AddWords(var S,D : Tstrings);
procedure AddWordsB(var S,D : TStrings);
procedure DeleteWords(S:Tstrings; var D : Tstrings); overload;
function AddWordsA(S:string; var D : string): boolean;
function AddWordsW(S,Ig:string; var D : string): boolean;
procedure DelSpaces(var S : Tstrings);
procedure DelSpacesA(var S : string);
procedure DelSpacesW(var S : string);

function WordExists(Words_ : TStrings; s: string) : boolean;

procedure GetCommonWords(A,B : Tstrings; var D : Tstrings);
Function WordsToString(Words : TStrings) : String;
{$IFNDEF EXT}
Function GetCommonWordsA(Words : TStringList): String;
procedure DeleteWords(var Words : String; WordsToDelete : String); overload;
Procedure ReplaceWords(A,B : String; var D : string);
function VariousKeyWords(S1, S2 : String) : Boolean;
Function SimilarTexts(A,B : string) : boolean;
function MaxStatBool(Bools : TArBoolean):Boolean;
function IsVariousBool(Bools : TArBoolean):Boolean;
function MaxStatStr(Strs : TArStrings):String;
function MaxStatInt(Ints : TArInteger):Integer;
function MaxStatDate(Dates : TArDateTime) : TDateTime;
function MaxStatTime(Times : TArTime) : TDateTime;

Function IsVariousArStrings(Ar : TArStrings) : Boolean;
Function IsVariousArInteger(Ar : TArInteger) : Boolean;
function IsVariousDate(Dates : TArDateTime) : Boolean;
function IsVariousArBoolean(Ar : TArBoolean) : Boolean;
{$ENDIF}
implementation

function WordExists(Words_ : TStrings; s: string) : boolean;
var
  i : integer;
begin
 result:=false;
 for i:=0 to Words_.Count-1 do
 if Words_[i]=s then
 begin
  result:=true;
  break;
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

procedure SpilitWordsA(S : string; var Words_ : TStrings; options : TSpilitOptions);
var
  i, j, n : integer;
  pi_ : PInteger;
begin
 if Words_=nil then Words_:=tstringlist.Create;
 Words_.Clear;
 s:=' '+s+' ';
 pi_:=@i;
 n:=0;
 if options.UpDown then
 Repeat
 inc(n);
 if ((s[i] in abs_englUp) or (s[i] in abs_rusUp)) and ((s[i] in abs_englDown) or (s[i] in abs_rusDown)) then
 insert(' ',s,i);
 until n+1>length(s);
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

procedure AddWords(var S,D : Tstrings);
var
  i : integer;
begin
 for i:=0 to S.Count-1 do
 if not WordExists(d,s[i]) then d.Text:=d.Text+' '+s[i];
end;

procedure AddWordsB(var S,D : TStrings);
var
  i : integer;
begin
 for i:=0 to S.Count-1 do
 D.Add(S[i])
end;

procedure DeleteWords(S:Tstrings; var D : Tstrings);
var
  i:Integer;
  Temp : TStrings;
begin
 Temp:=TStringList.Create;
 Temp.Clear;
 for i:=0 to D.Count-1 do
 if not WordExists(S,D[i]) then
 Temp.Add(D[i]);
 D.Assign(Temp);
 Temp.Free;
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

procedure DelSpacesA(var S : string);
var
  i : integer;
begin
 for i:=length(s) downto 1 do
 if s[i]=' ' then delete(s,i,1);
end;

procedure DelSpacesW(var S : string);
var
  i : integer;
begin
 for i:=length(s) downto 2 do
 if (s[i]=' ') and (s[i-1]=' ') then delete(s,i,1);
end;

function AddWordsA(S:string; var D : string) : boolean;
var
  i : integer;
  s_ ,d_ :tstrings;
begin
 result:=false;
 s_:=tstringlist.Create;
 d_:=tstringlist.Create;
 SpilitWords(s,s_);
 SpilitWords(d,d_);
 if length(d)>1 then
 if d[length(d)]=' ' then delete(d,length(d),1);
 for i:=0 to S_.Count-1 do
 if not WordExists(d_,s_[i]) then
 begin
 result:=true;
 d:=d+' '+s_[i];
 end;
end;

function AddWordsW(S,Ig:string; var D : string) : boolean;
var
  i : integer;
  s_,d_,ig_ : tstrings;
begin
 result:=false;
 s_:=tstringlist.Create;
 d_:=tstringlist.Create;
 ig_:=tstringlist.Create;
 SpilitWords(s,s_);
 SpilitWords(d,d_);
 SpilitWords(ig,ig_);
 if length(d)>1 then
 if d[length(d)]=' ' then delete(d,length(d),1);
 for i:=0 to S_.Count-1 do
 if not WordExists(d_,s_[i]) and not WordExists(ig_,s_[i]) then
 begin
 result:=true;
 d:=d+' '+s_[i];
 end;
end;

Procedure ReplaceWords(A,B : String; var D : string);
var
  a_, b_, d_ : TStrings;
begin
 a_:=tstringlist.Create;
 b_:=tstringlist.Create;
 d_:=tstringlist.Create;
 SpilitWords(a,a_);
 SpilitWords(b,b_);
 SpilitWords(d,d_);
 DeleteWords(a_,d_);
 AddWords(b_,d_);
 D:=WordsToString(d_);
 a_.Free;
 b_.Free;
 d_.Free;
end;

procedure GetCommonWords(A,B : Tstrings; var D : Tstrings);
var
  i : integer;
begin
 If D=nil then D:=TStringList.Create;
 D.Clear;
 For i:=0 to A.Count-1 do
 if WordExists(B,A[i]) then
 D.Add(A[i])
end;

Function WordsToString(Words : TStrings) : String;
var
  i : Integer;
begin
  Result:='';
  For i:=0 to Words.Count-1 do
  If Result='' then Result:=Words[0] else
  Result:=Result+' '+Words[i];
  DelSpacesW(Result);
end;

{$IFNDEF EXT}

Function GetCommonWordsA(Words : TStringList): String;
var
  Common, Temp, Str : TStrings;
  i : Integer;
begin
  if Words.Count = 0 then
    Exit;
    
  Common:=TStringList.create;
  Temp:=TStringList.create;
  Str:=TStringList.create;
  SpilitWords(Words[0],Common);
  for i:=1 to Words.Count - 1 do
  begin
   SpilitWords(Words[i],Temp);
   GetCommonWords(Common,Temp,Str);
   Common.Assign(Str);
   If Common.Count=0 then break;
  end;
  Result:=WordsToString(Common);
  Common.free;
end;

Function SimilarTexts(A{Big text},B{TextIn} : string) : boolean;
var
  i, a1, b1, c1 : integer;
  s_, d_, c_ : tstrings;
begin
 result:=false;
 s_:=tstringlist.Create;
 d_:=tstringlist.Create;
 c_:=tstringlist.Create;
 SpilitWords(A,s_);
 SpilitWords(B,d_);
 a1:= s_.count;
 b1:= d_.count;
 for i:=0 to d_.Count-1 do
 if WordExists(s_,d_[i]) then
 begin
  c_.add(d_[i]);
 end;
 c1:=c_.Count;
 if (b1=0) and (c1<>0) then begin result:=false; exit; end;
 if (b1=0) and (c1=0) then begin result:=true; exit; end;
 if ((c1)/(b1))>0.9 then Result:=True else result:=false;
end;

function VariousKeyWords(S1, S2 : String) : Boolean;
var
  i : integer;
  A1, A2 : TStrings;
begin
 Result:=False;
 A1:=tstringlist.Create;
 A2:=tstringlist.Create;
 SpilitWords(S1,A1);
 SpilitWords(S2,A2);
 For i:=1 to A1.Count do
 if not WordExists(A2,A1[i-1]) then
 begin
  Result:=True;
  A1.Free;
  A2.Free;
  Exit;
 end;
 For i:=1 to A2.Count do
 if not WordExists(A1,A2[i-1]) then
 begin
  Result:=True;
  A1.Free;
  A2.Free;
  Exit;
 end;
 A1.Free;
 A2.Free;
end;

function MaxStatDate(Dates : TArDateTime) : TDateTime;
type TDateStat = record
  Date : TDateTime;
  Count : Integer;
 end;
 TArDateStat = Array of TDateStat;
Var
  i:integer;
  Stat : TArDateStat;
  MaxC, MaxN : Integer;
 Procedure AddStat(var DatesStat : TArDateStat; Date : TDateTime);
 var
   j : Integer;
 begin
  For j:=0 to length(DatesStat)-1 do
  if DatesStat[j].Date=Date then
  begin
   DatesStat[j].Count:=DatesStat[j].Count+1;
   Exit;
  end;
  SetLength(DatesStat,Length(DatesStat)+1);
  DatesStat[Length(DatesStat)-1].Date:=Date;
  DatesStat[Length(DatesStat)-1].Count:=0;
 end;
begin
 Result:=0;
 If length(Dates)=0 then exit;
 SetLength(Stat,0);
 For i:=0 to length(Dates)-1 do
 AddStat(Stat,Dates[i]);
 MaxC:=Stat[0].Count;
 MaxN:=0;
 For i:=0 to length(Stat)-1 do
 If MaxC<Stat[i].Count then
 begin
  MaxC:=Stat[i].Count;
  MaxN:=i;
 end;
 Result:=Stat[MaxN].Date;
end;

function MaxStatTime(Times : TArTime) : TDateTime;
type TDateStat = record
  Time : TDateTime;
  Count : Integer;
 end;
 TArDateStat = Array of TDateStat;
Var
  i:integer;
  Stat : TArDateStat;
  MaxC, MaxN : Integer;
 Procedure AddStat(var DatesStat : TArDateStat; Time : TDateTime);
 var
   j : Integer;
 begin
  For j:=0 to length(DatesStat)-1 do
  if DatesStat[j].Time=Time then
  begin
   DatesStat[j].Count:=DatesStat[j].Count+1;
   Exit;
  end;
  SetLength(DatesStat,Length(DatesStat)+1);
  DatesStat[Length(DatesStat)-1].Time:=Time;
  DatesStat[Length(DatesStat)-1].Count:=0;
 end;
begin    
 Result:=0;
 If length(Times)=0 then exit;
 SetLength(Stat,0);
 For i:=0 to length(Times)-1 do
 AddStat(Stat,Times[i]);
 MaxC:=Stat[0].Count;
 MaxN:=0;
 For i:=0 to length(Stat)-1 do
 If MaxC<Stat[i].Count then
 begin
  MaxC:=Stat[i].Count;
  MaxN:=i;
 end;
 Result:=Stat[MaxN].Time;
end;

//function MaxStat32Bit(

function MaxStatInt(Ints : TArInteger) : Integer;
type TIntStat = record
  Int : integer;
  Count : Integer;
 end;
 TArIntStat = Array of TIntStat;
Var
  i:integer;
  Stat : TArIntStat;
  MaxC, MaxN : Integer;
 Procedure AddStat(var IntStat : TArIntStat; Int : integer);
 var
   j : Integer;
 begin
  For j:=0 to length(IntStat)-1 do
  if IntStat[j].Int=Int then
  begin
   IntStat[j].Count:=IntStat[j].Count+1;
   Exit;
  end;
  SetLength(IntStat,Length(IntStat)+1);
  IntStat[Length(IntStat)-1].Int:=Int;
  IntStat[Length(IntStat)-1].Count:=0;
 end;
begin     
 Result:=0;
 If length(Ints)=0 then exit;
 SetLength(Stat,0);
 For i:=0 to length(Ints)-1 do
 AddStat(Stat,Ints[i]);
 MaxC:=Stat[0].Count;
 MaxN:=0;
 For i:=0 to length(Stat)-1 do
 If MaxC<Stat[i].Count then
 begin
  MaxC:=Stat[i].Count;
  MaxN:=i;
 end;
 Result:=Stat[MaxN].int;
end;

function MaxStatStr(Strs : TArStrings) : String;
type TStrStat = record
  Str : String;
  Count : Integer;
 end;
 TArStrStat = Array of TStrStat;
Var
  i:integer;
  Stat : TArStrStat;
  MaxC, MaxN : Integer;
 Procedure AddStat(var StrStat : TArStrStat; Str : String);
 var
   j : Integer;
 begin
  For j:=0 to length(StrStat)-1 do
  if StrStat[j].Str=Str then
  begin
   StrStat[j].Count:=StrStat[j].Count+1;
   Exit;
  end;
  SetLength(StrStat,Length(StrStat)+1);
  StrStat[Length(StrStat)-1].Str:=Str;
  StrStat[Length(StrStat)-1].Count:=0;
 end;
begin
 If length(Strs)=0 then exit;
 SetLength(Stat,0);
 For i:=0 to length(Strs)-1 do
 AddStat(Stat,Strs[i]);
 MaxC:=Stat[0].Count;
 MaxN:=0;
 For i:=0 to length(Stat)-1 do
 If MaxC<Stat[i].Count then
 begin
  MaxC:=Stat[i].Count;
  MaxN:=i;
 end;
 Result:=Stat[MaxN].Str;
end;

function IsVariousBool(Bools : TArBoolean) : Boolean;
var
  i : Integer;
  b : Boolean;
begin
 Result:=False;
 if Length(Bools)=0 then exit;
 b:=Bools[0];
 For i:=0 to Length(Bools)-1 do
 if b<>Bools[i] then
 begin
  Result:=True;
  Break;
 end;
end;

function IsVariousDate(Dates : TArDateTime) : Boolean;
var
  i : Integer;
  d : TDateTime;
begin
 Result:=False;
 if Length(Dates)=0 then exit;
 d:=Dates[0];
 For i:=0 to Length(Dates)-1 do
 if d<>Dates[i] then
 begin
  Result:=True;
  Break;
 end;
end;

function MaxStatBool(Bools : TArBoolean):Boolean;
type TBoolStat = record
  Bool : Boolean;
  Count : Integer;
 end;
 TArBoolStat = Array of TBoolStat;
Var
  i:integer;
  Stat : TArBoolStat;
  MaxC, MaxN : Integer;
 Procedure AddStat(var BoolStat : TArBoolStat; Bool : Boolean);
 var
   j : Integer;
 begin
  For j:=0 to length(BoolStat)-1 do
  if BoolStat[j].Bool=Bool then
  begin
   BoolStat[j].Count:=BoolStat[j].Count+1;
   Exit;
  end;
  SetLength(Boolstat,Length(BoolStat)+1);
  BoolStat[Length(BoolStat)-1].Bool:=Bool;
  BoolStat[Length(BoolStat)-1].Count:=0;
 end;
begin     
 Result:=false;
 If length(Bools)=0 then exit;
 SetLength(Stat,0);
 For i:=0 to length(Bools)-1 do
 AddStat(Stat,Bools[i]);
 MaxC:=Stat[0].Count;
 MaxN:=0;
 For i:=0 to length(Stat)-1 do
 If MaxC<Stat[i].Count then
 begin
  MaxC:=Stat[i].Count;
  MaxN:=i;
 end;
 Result:=Stat[MaxN].Bool;
end;

Function IsVariousArInteger(Ar : TArInteger) : Boolean;
var
  i, n : integer;
begin
 Result:=False;
 if length(Ar)=0 then exit;
 n:=Ar[0];
 for i:=1 to length(Ar)-1 do
 if n<>Ar[i] then
 begin
  Result:=True;
  Break;
 end;
end;

Function IsVariousArStrings(Ar : TArStrings) : Boolean;
var
  i : integer;
  s : string;
begin
 Result:=False;
 if length(Ar)=0 then exit;
 s:=Ar[0];
 for i:=1 to length(Ar)-1 do
 if s<>Ar[i] then
 begin
  Result:=True;
  Break;
 end;
end;

function IsVariousArBoolean(Ar : TArBoolean) : Boolean;
var
  i : integer;
  b : boolean;
begin
 Result:=False;
 if length(Ar)=0 then exit;
 b:=Ar[0];
 for i:=1 to length(Ar)-1 do
 if b<>Ar[i] then
 begin
  Result:=True;
  Break;
 end;
end;

procedure DeleteWords(var Words : String; WordsToDelete : String);
var
  S, D : TStrings;
begin
 S:=TStringList.Create;
 D:=TStringList.Create;
 SpilitWords(Words,D);
 SpilitWords(WordsToDelete,S);
 DeleteWords(S,D);
 Words:=WordsToString(D);
 S.Free;
 D.Free;
end;
{$ENDIF}
end.
