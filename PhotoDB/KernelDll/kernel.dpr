library Kernel;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Math,
  SysUtils,
  win32crc in 'win32crc.pas',
  SystemUnit in 'SystemUnit.pas',
  FileCRC in 'FileCRC.pas';

//{$DEFINE ENGL}
{$DEFINE RUS}

var
  A: Boolean = False;

const
  DEBUG_BUILD = False;

var
  s : String;

const
  RegRoot : string = 'Software\Photo DataBase\';
  RegRootW : string = 'Software\Photo DataBase';

{$R *.res}

function CharToInt(Ch: Char): Integer;
begin
  Result := HexToIntDef(Ch, 0);
end;

function IntToChar(Int: Integer): Char;
begin
  Result := IntToHex(Int, 1)[1];
end;

function NormalizeFileName(s : Pchar) : Pchar;
var
  i : integer;
  outs : string;
begin
 if a then
 begin
  result:='';
  exit;
 end;
 outs:=s;
 for i:= length(outs) downto 1 do
 if outs[i]=#0 then delete(outs,i,1);
 GetMem(Result,Length(outs)+1);
 Result[Length(outs)]:=#0;

 for i:=0 to length(outs)-1 do
 result[i]:=outs[i];
end;

function Initialize(s : PChar) : integer;
var
  tb : TInteger8;
  er  :Word;
  crc : cardinal;
  str : string;
begin
 str:=Copy(s,1,Length(s));
 CalcFileCRC32(s, crc, tb, er);
 if (crc<>ProgramCRC) and not DEBUG_BUILD then
 begin
  a:=true;
 end;
 result:=crc;
end;

function InitializeA(s : PChar) : boolean;
var
  tb:TInteger8;
  er  :Word;
  crc : cardinal;
begin
 Result:=True;
 CalcFileCRC32(s, crc,tb,er);
 if (crc<>ProgramCRC) and not DEBUG_BUILD then
 begin
  a:=true;
  result:=False;
 end;
end;

procedure GetCIDA(Buffer : PAnsiChar; Size : Integer);
var
  S: AnsiString;
  I, MinSize: Integer;
begin
  S := '{A047B261-5FFC-48D7-A450-6FDE374308E4}';
  if A then
    S := IntToStr(Random(MaxInt));

  MinSize := Min(Length(S), Size) - 1;
  for I := 0 to MinSize - 1 do
    Buffer[I] := S[I + 1];

  Buffer[MinSize] := #0;
end;

function ApplicationCode: string;
var
  s, Code : String;
  n : Cardinal;
begin
 s:=GetIdeDiskSerialNumber;
 CalcStringCRC32(s,n);
// n:=n xor $FA45B671;  //v1.75
// n:=n xor $8C54AF5B; //v1.8
// n:=n xor $AC68DF35; //v1.9
// n:=n xor $B1534A4F; //v2.0
// n:=n xor $29E0FA13; //v2.1
 n:=n xor $6357A302; //v2.2
 s:=inttohex(n,8);
 CalcStringCRC32(s,n);
 {$IFDEF ENGL}
  n:=n xor $1459EF12;
 {$ENDIF}
 {$IFDEF RUS}
//  n:=n xor $4D69F789; //v1.9
//  n:=n xor $E445CF12; //v2.0
//  n:=n xor $56C987F3; //v2.1
 n:=n xor $762C90CA; //v2.2
 {$ENDIF}
 Code:=s+inttohex(n,8);
 Result:=Code;
end;

function GetCID : string;
var
  Buffer : PAnsiChar;

const
  MaxBufferSize = 255;

begin
  GetMem(Buffer, MaxBufferSize);
  GetCIDA(Buffer, MaxBufferSize);
  Result := Trim(Buffer);
  FreeMem(Buffer);
end;

function GetWindowsName : boolean;
var
  i, Sum : integer;
  Str, ActCode, s : string;
begin
 ActCode:=ReadStringW(HKEY_CLASSES_ROOT,'\CLSID\'+GetCID,'DefaultHandle');
 if Length(ActCode)<16 then actcode:='0000000000000000';
 S:=ApplicationCode;

 Result:=false;

 if DEBUG_BUILD then
 begin
  exit;
 end;

 for i:=1 to 8 do
 begin
  Str:=IntToHex(abs(Round(cos(ord(s[i])+100*i+0.34)*16)),8);
  If ActCode[(i-1)*2+1]<>Str[8] then
  begin
   Result:=True;
   exit;
  end;
 end;
 Sum:=0;
 for i:=1 to 15 do
 Sum:=Sum+chartoint(ActCode[i]);
 if inttochar(Sum mod 15)<>ActCode[16] then
 begin
  Result:=True;
  exit;
 end;
end;

exports
  Initialize name 'Initialize',
  InitializeA name 'InitializeA',
  GetCIDA name 'GetCIDA',
  GetWindowsName name 'GetWindowsName',
  NormalizeFileName name 'NormalizeFileName';

begin
  InitPlatformId;
  Randomize;

end.
