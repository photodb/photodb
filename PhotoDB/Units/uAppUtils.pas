unit uAppUtils;

interface

uses
  Classes, SysUtils, uMemory;

function GetParamStrDBValue(ParamName : string) : string;
function GetParamStrDBBool(ParamName : string) : Boolean;

implementation

var
  ProgramParams : TStringList = nil;

procedure CheckParams;
var
  I : Integer;
begin
  if ProgramParams = nil then
  begin
    ProgramParams := TStringList.Create;
    for i := 1 to ParamCount do
      ProgramParams.Add(AnsiUpperCase(ParamStr(i)));
    ProgramParams.Add('');
  end;
end;

function GetParamStrDBBool(ParamName : string) : Boolean;
begin
  CheckParams;
  Result := ProgramParams.IndexOf(AnsiUpperCase(ParamName)) > -1;
end;

function GetParamStrDBValue(ParamName : string) : string;
var
  Index : Integer;
begin
  Result := '';
  if ParamName = '' then
    Exit;
  CheckParams;
  Index := ProgramParams.IndexOf(AnsiUpperCase(ParamName));
  if Index > -1 then
    Result := ProgramParams[Index + 1];
end;

initialization

finalization

  F(ProgramParams);

end.
