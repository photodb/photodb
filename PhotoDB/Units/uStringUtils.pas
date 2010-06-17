unit uStringUtils;

interface

uses Windows, SysUtils;
  
function ConvertUniversalFloatToLocal(s : string) : string;
function PosExS(SubStr : string; var Str : string; index : integer = 1) : integer;

implementation

function ConvertUniversalFloatToLocal(s : string) : string;
var
   I : integer;
begin
  Result := s;
  for I:=1 to Length(Result) do
  if Result[I]='.' then Result[I] := DecimalSeparator;
end;

function PosExS(SubStr : string; var Str : string; index : integer = 1) : integer;
var
  i, n, ns, ls : integer;
  q : boolean;
begin
 n:=0;
 ns:=0;
 q:=false;
 Result:=0;
 ls:=Length(SubStr);
 if index<1 then index:=1;
 for i:=index to Length(Str) do
 begin
  if (Copy(Str,i,Ls)=SubStr) and (n=0) and (ns=0) and (not q) then
  begin
   Result:=i;
   exit;
  end;

  if (Str[i]='"') and not q then
  begin
   q:=true;
   continue;
  end;
  if (Str[i]='"') and q then
  begin
   q:=false;
   continue;
  end;
  if i=index then continue;
  if (Str[i]='{') and (not q) then
  begin
   inc(n);
  end;
  if (Str[i]='}') and (n>0) and (not q) then
  begin
   dec(n);
   if n=0 then continue;
  end;

  if (Str[i]='(') and (not q) then
  begin
   inc(ns);
  end;
  if (Str[i]=')') and (ns>0) and (not q) then
  begin
   dec(ns);
   if ns=0 then continue;
  end;
  if (Copy(Str,i,Ls)=SubStr) and (n=0) and (not q) and (ns=0) then
  begin
   Result:=i;
   exit;
  end;
 end;
end;


end.
