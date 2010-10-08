unit uStringUtils;

interface

uses Windows, SysUtils;

function ConvertUniversalFloatToLocal(s: string): string;
function PosExS(SubStr: string; const Str: string; index: integer = 1): Integer;

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
  I, N, NS, LS: integer;
  Q: boolean;
  C, FS : Char;
  S : string;
  OneChar : Boolean;
  PS : PChar;
begin
  n := 0;
  ns := 0;
  q := False;
  Result := 0;
  ls := Length(SubStr);
  OneChar := LS = 1;
  if OneChar then
    FS := SubStr[1];
  if index < 1 then
    index := 1;

  PS := PChar(Addr(Str[1]));
  Inc(PS, Index - 2);
  for I := Index to Length(Str) do
  begin
    Inc(PS, 1);

    if OneChar then
    begin
      C := PS[0];
      if (C = FS) and (n = 0) and (ns = 0) and (not q) then
      begin
        Result := I;
        exit;
      end;
    end else
    begin
      S := Copy(Str, I, ls);
      if (S = SubStr) and (n = 0) and (ns = 0) and (not q) then
      begin
        Result := I;
        exit;
      end;
      C := PS[0];
    end;

    if (C = '"')  then
    begin
      q := not q;
      Continue;
    end;
    if I = index then
      continue;

    if (not q) then
    begin
      if (C = '{') then
      begin
        Inc(n);
      end else if (C = '}') and (n > 0)  then
      begin
        Dec(n);
        if n = 0 then
          continue;
      end else if (C = '(') then
      begin
        Inc(ns);
      end else if (C = ')') and (ns > 0) then
      begin
        Dec(ns);
        if ns = 0 then
          continue;
      end;

      if (n = 0) and (ns = 0) then
      begin
        if OneChar then
        begin
          if (C = FS) then
          begin
            Result := I;
            exit;
          end;
        end else
        begin
          if (S = SubStr) then
          begin
            Result := I;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

end.
