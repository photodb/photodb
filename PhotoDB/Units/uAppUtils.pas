unit uAppUtils;

interface

uses
  Classes, SysUtils, uMemory, SyncObjs;

function GetParamStrDBValue(ParamName : string) : string;
function GetParamStrDBBool(ParamName : string) : Boolean;

implementation

var
  ProgramParams : TStringList = nil;
  FSync: TCriticalSection;

procedure CheckParams;
var
  I : Integer;
  S: string;
begin
  if ProgramParams = nil then
  begin
    ProgramParams := TStringList.Create;
    S := '';
    I := 1;
    repeat
      S := AnsiUpperCase(ParamStr(I));
      ProgramParams.Add(S);
      Inc(I);
    until S = '';

  end;
end;

function GetParamStrDBBool(ParamName : string) : Boolean;
begin
  FSync.Enter;
  try
    CheckParams;
    Result := ProgramParams.IndexOf(AnsiUpperCase(ParamName)) > -1;
  finally
    FSync.Leave;
  end;
end;

function GetParamStrDBValue(ParamName : string) : string;
var
  Index : Integer;
begin
  FSync.Enter;
  try
    Result := '';
    if ParamName = '' then
      Exit;
    CheckParams;
    Index := ProgramParams.IndexOf(AnsiUpperCase(ParamName));
    if Index > -1 then
      Result := ProgramParams[Index + 1];
  finally
    FSync.Leave;
  end;
end;

initialization

  FSync := TCriticalSection.Create;

finalization

  F(FSync);
  F(ProgramParams);

end.
