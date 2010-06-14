library Kernel;

uses   
  win32crc in 'win32crc.pas', 
  SystemUnit in 'SystemUnit.pas';

//{$DEFINE ENGL}
{$DEFINE RUS}

var a : boolean = false;

const ProgramCRC = $04CC696C;
      DEBUG_BUILD = false;

var
  s : String;
  si : Tstartupinfo;
  p  : Tprocessinformation;

const
  RegRoot : string = 'Software\Photo DataBase\';
  RegRootW : string = 'Software\Photo DataBase';

{$R *.res}

function CharToInt(ch : char):Integer;
begin
 Result:=HexToIntDef(ch,0);
end;

function IntToChar(int : Integer):char;
begin
 result:=IntToHex(int,1)[1];
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

function GetCIDA : Pchar;
begin
// result:='{C644082F-1009-49B9-8C71-4AFDC3C477F0}'; v1.9
 result:='{A047B261-5FFC-48D7-A450-6FDE374308E4}';
 If a then Result:=PChar(IntToStr(Random(100000)));
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

function GetWindowsName : boolean;
var
  i, Sum : integer;
  ar : array[1..16] of integer;
  Str, ActCode, s, key, hs, cs : string;
  n : Cardinal;
begin
 ActCode:=ReadStringW(HKEY_CLASSES_ROOT,'\CLSID\'+GetCIDA,'DefaultHandle');
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

end.


