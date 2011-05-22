unit uAppUtils;

interface

uses
  Windows
  {$IFNDEF ONECPU}
  , SyncObjs
  {$ENDIF}
  ;

function GetParamStrDBValue(ParamName : string) : string;
function GetParamStrDBBool(ParamName : string) : Boolean;

implementation

var
  ProgramParams : array of string = nil;
  {$IFNDEF ONECPU}
  FSync: TCriticalSection;
  {$ENDIF}

function UpperCase(S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    S[I] := UpCase(S[I]);
  Result := S;
end;

procedure CheckParams;
var
  L,
  I: Integer;
  S: string;
begin
  if ProgramParams = nil then
  begin
    SetLength(ProgramParams, 0);
    S := '';
    I := 1;
    repeat
      S := UpperCase(ParamStr(I));
      L := Length(ProgramParams);
      SetLength(ProgramParams, L + 1);
      ProgramParams[L] := S;
      Inc(I);
    until S = '';

  end;
end;

function GetParamStrDBBool(ParamName : string) : Boolean;
var
  I: Integer;
begin
  {$IFNDEF ONECPU}
  FSync.Enter;
  {$ENDIF}
  try
    CheckParams;
    Result := False;
    ParamName := UpperCase(ParamName);
    for I := 0 to Length(ProgramParams) - 1 do
      if ProgramParams[I] = ParamName then
      begin
        Result := True;
        Break;
      end;
  finally
    {$IFNDEF ONECPU}
    FSync.Leave;
    {$ENDIF}
  end;
end;

function GetParamStrDBValue(ParamName : string) : string;
var
  I: Integer;
begin
  {$IFNDEF ONECPU}
  FSync.Enter;
  {$ENDIF}
  try
    Result := '';
    if ParamName = '' then
      Exit;
    CheckParams;
    ParamName := UpperCase(ParamName);
    for I := 0 to Length(ProgramParams) - 2 do
      if ProgramParams[I] = ParamName then
      begin
        Result := ProgramParams[I + 1];
        Break;
      end;

  finally
    {$IFNDEF ONECPU}
    FSync.Leave;
    {$ENDIF}
  end;
end;

initialization

  {$IFNDEF ONECPU}
  FSync := TCriticalSection.Create;
  {$ENDIF}

finalization

  {$IFNDEF ONECPU}
  FSync.Free;
  {$ENDIF}
  SetLength(ProgramParams, 0);

end.
