unit uSysUtils;

interface

uses
  Windows, Forms, Tlhelp32, SysUtils, ActiveX;

function GetWindowsUserName: string;
function AltKeyDown: Boolean;
function CtrlKeyDown: Boolean;
function ShiftKeyDown: Boolean;
function KillTask(ExeFileName: string): Integer;
function GetGUID: TGUID;
function GetProgramPath: string;
function FloatToStrEx(Value: Extended; Round: Integer): string;

implementation

function FloatToStrEx(Value: Extended; Round: Integer): string;
var
  Buffer: array [0 .. 63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, FvExtended, FfGeneral, Round, 0));
end;

function GetProgramPath: string;
begin
  Result := Application.ExeName;
end;

function AltKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_MENU)) and 128) <> 0;
end;

function CtrlKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_CONTROL)) and 128) <> 0;
end;

function ShiftKeyDown: Boolean;
begin
  Result := (Word(GetKeyState(VK_SHIFT)) and 128) <> 0;
end;

function GetWindowsUserName: string;
const
  CnMaxUserNameLen = 254;
var
  SUserName: string;
  DwUserNameLen: DWORD;
begin
  DwUserNameLen := CnMaxUserNameLen - 1;
  SetLength(SUserName, CnMaxUserNameLen);
  GetUserName(PWideChar(SUserName), DwUserNameLen);
  SetLength(SUserName, DwUserNameLen);
  Result := SUserName;
end;

function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.DwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.SzExeFile)) = UpperCase(ExeFileName)) or
        (UpperCase(FProcessEntry32.SzExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.Th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

end.
