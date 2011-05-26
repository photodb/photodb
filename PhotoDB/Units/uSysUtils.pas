unit uSysUtils;

interface

uses
  Windows, Forms, SysUtils, ActiveX, uDBBaseTypes;

function StringToHexString(Text: string): string;
function HexStringToString(Text: string): string;
function HexCharToInt(Ch: Char): Integer;
function IntToHexChar(Int: Integer): Char;
function HexToIntDef(const HexStr: string; const Default: Integer): Integer;

function FloatToStrEx(Value: Extended; Round: Integer): string;

function GetWindowsUserName: string;
function AltKeyDown: Boolean;
function CtrlKeyDown: Boolean;
function ShiftKeyDown: Boolean;
function GetGUID: TGUID;
function GetProgramPath: string;
function GetSystemLanguage: string;
function GetExeVersion(sFileName: string): TRelease;

implementation

function GetExeVersion(sFileName: string): TRelease;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(sFileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(sFileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result.Version := dwFileVersionMS shr 16;
    Result.Major := dwFileVersionMS and $FFFF;
    Result.Minor := dwFileVersionLS shr 16;
    Result.Build := dwFileVersionLS and $FFFF;
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

function StripHexPrefix(const HexStr: string): string;
begin
  if Pos('$', HexStr) = 1 then
    Result := Copy(HexStr, 2, Length(HexStr) - 1)
  else if Pos('0x', SysUtils.LowerCase(HexStr)) = 1 then
    Result := Copy(HexStr, 3, Length(HexStr) - 2)
  else
    Result := HexStr;
end;

function AddHexPrefix(const HexStr: string): string;
begin
  Result := SysUtils.HexDisplayPrefix + StripHexPrefix(HexStr);
end;

function TryHexToInt(const HexStr: string; out Value: Integer): Boolean;
var
  E: Integer; // error code
begin
  Val(AddHexPrefix(HexStr), Value, E);
  Result := E = 0;
end;

function HexToInt(const HexStr: string): Integer;
{$IFDEF FPC}
const
{$ELSE}
resourcestring
{$ENDIF}
  sHexConvertError = '''%s'' is not a valid hexadecimal value';
begin
  if not TryHexToInt(HexStr, Result) then
    raise SysUtils.EConvertError.CreateFmt(sHexConvertError, [HexStr]);
end;

function HexToIntDef(const HexStr: string; const Default: Integer): Integer;
begin
  if not TryHexToInt(HexStr, Result) then
    Result := Default;
end;

function StringToHexString(Text: string): string;
var
  I: Integer;
  Str: string;
begin
  Result := '';
  for I := 1 to Length(Text) do
  begin
    Str := IntToHex(Ord(Text[I]), 2);
    Result := Result + Str;
  end;
end;

function HexStringToString(Text : String) : string;
var
  I: Integer;
  C: Byte;
  Str: string;
begin
  Result := '';
  for I := 1 to Length(Text) div 2 do
  begin
    Str := Copy(Text, (I - 1) * 2 + 1, 2);
    C := HexToIntDef(Str, 0);
    Result := Result + Chr(C);
  end;
end;

function HexCharToInt(Ch: Char): Integer;
begin
  Result := HexToIntDef(Ch, 0);
end;

function IntToHexChar(Int: Integer): Char;
begin
  Result := IntToHex(Int, 1)[1];
end;

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
  Result := Trim(SUserName);
end;

function GetSystemLanguage: string;
var
  ID: LangID;
  Language: array [0..255] of Char;
begin
  ID := GetSystemDefaultLangID;
  VerLanguageName(ID, Language, SizeOf(Language) - 1);
  Result := string(Language);
end;

function GetGUID: TGUID;
begin
  CoCreateGuid(Result);
end;

end.
