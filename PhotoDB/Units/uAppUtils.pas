unit uAppUtils;

interface

uses
  Windows
  {$IFNDEF ONECPU}
  , SyncObjs
  {$ENDIF}
  ;

//uses specification:
// /key /value
function GetParamStrDBValue(ParamName: string): string;
function GetParamStrDBValueEx(CommandLine, ParamName: string): string;
//uses specification:
// /key:value
function GetParamStrDBValueV2(CommandLine, ParamName: string): string;
function GetParamStrDBBool(ParamName: string): Boolean;
function GetParamStrDBBoolEx(CommandLine, ParamName: string): Boolean;
function ParamStrEx(Parameters: string; Index: Integer): string;

implementation

function GetParamStr(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S: PChar;
begin
  // U-OK
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      Inc(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Inc(Len);
        Inc(P);
      end;
      if P[0] <> #0 then
        Inc(P);
    end
    else
    begin
      Inc(Len);
      Inc(P);
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      Inc(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
      if P[0] <> #0 then Inc(P);
    end
    else
    begin
      S[i] := P^;
      Inc(P);
      Inc(i);
    end;
  end;

  Result := P;
end;

function ParamStrEx(Parameters: string; Index: Integer): string;
var
  P: PChar;
  Buffer: array[0..260] of Char;
begin
  Result := '';
  if Index = 0 then
    SetString(Result, Buffer, GetModuleFileName(0, Buffer, Length(Buffer)))
  else
  begin
    P := PChar(Parameters);
    while True do
    begin
      P := GetParamStr(P, Result);
      if (Index <= 0) or (Result = '') then Break;
      Dec(Index);
    end;
  end;
end;

function ParamCountEx(Parameters: PChar): Integer;
{$IFDEF MSWINDOWS}
var
  P: PChar;
  S: string;
begin
  // U-OK
  Result := 0;
  P := GetParamStr(Parameters, S);
  while True do
  begin
    P := GetParamStr(P, S);
    if S = '' then Break;
    Inc(Result);
  end;
{$ENDIF MSWINDOWS}
{$IF defined(LINUX) or defined(MACOS)}
begin
  if ArgCount > 1 then
    Result := ArgCount - 1
  else Result := 0;
{$IFEND LINUX or MACOS}
end;

function UpperCase(S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  Result := S;
end;

function GetParamStrDBBool(ParamName: string): Boolean;
begin
  Result := GetParamStrDBBoolEx(GetCommandLine, ParamName);
end;

function GetParamStrDBBoolEx(CommandLine, ParamName: string): Boolean;
var
  I: Integer;
  P: PChar;
begin
  Result := False;

  P := PChar(CommandLine);

  ParamName := UpperCase(ParamName);
  for I := 1 to ParamCountEx(P) do
    if UpperCase(ParamStrEx(P, I)) = ParamName then
    begin
      Result := True;
      Break;
    end;
end;

function GetParamStrDBValue(ParamName: string): string;
begin
  Result := GetParamStrDBValueEx(GetCommandLine, ParamName);
end;

function GetParamStrDBValueEx(CommandLine, ParamName: string): string;
var
  I: Integer;
  P: PChar;
begin
  Result := '';
  if ParamName = '' then
    Exit;

  P := PChar(CommandLine);
  ParamName := UpperCase(ParamName);
  for I := 1 to ParamCountEx(P) - 1 do
    if UpperCase(ParamStrEx(P, I)) = ParamName then
    begin
      Result := ParamStrEx(P, I + 1);
      Break;
    end;
end;

function GetParamStrDBValueV2(CommandLine, ParamName: string): string;
var
  I: Integer;
  S: string;
begin
  Result := '';
  if ParamName = '' then
    Exit;

  ParamName := UpperCase(ParamName);
  for I := 0 to ParamCountEx(PChar(CommandLine)) - 1 do
  begin
    S := UpperCase(ParamStrEx(PChar(CommandLine), I));
    if Length(S) > Length(ParamName) then
    begin
      if Copy(S, 1, Length(ParamName) + 1) = ParamName + ':' then
      begin
        Result := Copy(S, Length(ParamName) + 2, Length(S) - Length(ParamName) - 1);
        Break;
      end;
    end;
  end;
end;

end.
