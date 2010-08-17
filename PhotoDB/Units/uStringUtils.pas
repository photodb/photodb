unit uStringUtils;

interface

uses Windows, SysUtils;

function ConvertUniversalFloatToLocal(s: string): string;
function PosExS(SubStr: string; const Str: string; index: integer = 1): integer;

implementation

function ConvertUniversalFloatToLocal(s: string): string;
var
  I: integer;
begin
  Result := s;
  for I := 1 to Length(Result) do
    if Result[I] = '.' then
      Result[I] := DecimalSeparator;
end;

function PosExS(SubStr: string; const Str: string; index: integer = 1): integer;
var
  I, n, ns, ls: integer;
  q: boolean;
begin
  n := 0;
  ns := 0;
  q := false;
  Result := 0;
  ls := Length(SubStr);
  if index < 1 then
    index := 1;
  for I := index to Length(Str) do
  begin
    if (Copy(Str, I, ls) = SubStr) and (n = 0) and (ns = 0) and (not q) then
    begin
      Result := I;
      exit;
    end;

    if (Str[I] = '"') and not q then
    begin
      q := true;
      continue;
    end;
    if (Str[I] = '"') and q then
    begin
      q := false;
      continue;
    end;
    if I = index then
      continue;
    if (Str[I] = '{') and (not q) then
    begin
      inc(n);
    end;
    if (Str[I] = '}') and (n > 0) and (not q) then
    begin
      dec(n);
      if n = 0 then
        continue;
    end;

    if (Str[I] = '(') and (not q) then
    begin
      inc(ns);
    end;
    if (Str[I] = ')') and (ns > 0) and (not q) then
    begin
      dec(ns);
      if ns = 0 then
        continue;
    end;
    if (Copy(Str, I, ls) = SubStr) and (n = 0) and (not q) and (ns = 0) then
    begin
      Result := I;
      exit;
    end;
  end;
end;

end.
