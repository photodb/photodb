unit uSysUtils;

interface

uses
  Windows, Forms, Classes, SysUtils, ActiveX, uDBBaseTypes, uMemory;

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
function StringToRelease(const s: string) : TRelease;
function ReleaseToString(Release : TRelease) : string;
function ProductVersion: string;
function IsWindowsVista: Boolean;
function IsNewRelease(CurrentRelease, NewRelease : TRelease) : Boolean;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Integer): Integer; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: string): string; overload;
function SafeCreateGUID: TGUID;
function GetEmptyGUID: TGUID;
function SafeIsEqualGUID(GUID1, GUID2: TGUID): Boolean;
function FormatEx(FormatString: string; Args: array of const): string;

implementation

function FormatEx(FormatString: string; Args: array of const): string;
var
  I: Integer;
  S: string;
begin
  Result := FormatString;
  for I := Low(Args) to High(Args) do
  begin
    S := '';
    case Args[I].VType of
      vtInteger: S := IntToStr(Args[i].VInteger);
      vtPChar: S := string(Args[i].VPChar);
      vtExtended: S := FloatToStr(Args[i].VExtended^);
      vtAnsiString: S := string(PAnsiChar(Args[i].VAnsiString));
      vtWideString: S := string(PWideChar(Args[i].VWideString));
      vtUnicodeString: S := string(PWideChar(Args[i].VUnicodeString));
      vtBoolean: S := IntToStr(IIF(Args[i].VBoolean, 1, 0));
      vtInt64: S := IntToStr(Args[i].VInteger);
    else
      raise Exception.Create('Unknown type');
    end;
    Result := StringReplace(Result, '{' + IntToStr(I) + '}', S, [rfReplaceAll])
  end;
end;

function IsWindowsVista: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  Result := VerInfo.dwMajorVersion >= 6;
end;

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
  if VerInfo <> nil then
  begin
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
end;

function ReleaseToString(Release : TRelease) : string;
begin
  Result := IntToStr(Release.Version) + '.' +
            IntToStr(Release.Major) + '.' +
            IntToStr(Release.Minor) + '.' +
            IntToStr(Release.Build);
end;

function StringToRelease(const s : string) : TRelease;
var
  Items: TStrings;
begin
  Result.Version := 0;
  Result.Major   := 0;
  Result.Minor   := 0;
  Result.Build   := 0;

  Items := TStringList.Create;
  try
    Items.Delimiter := '.';
    Items.DelimitedText  := s;
    if Items.Count = 4 then
    begin
      Result.Version := StrToIntDef(Items[0], 0);
      Result.Major   := StrToIntDef(Items[1], 0);
      Result.Minor   := StrToIntDef(Items[2], 0);
      Result.Build   := StrToIntDef(Items[3], 0);
    end;
  finally
    F(Items);
  end;
end;

function ProductVersion: string;
begin
  Result := ReleaseToString(GetExeVersion(ParamStr(0)));
end;

function IsNewRelease(CurrentRelease, NewRelease : TRelease) : Boolean;
begin
  Result := False;
  if CurrentRelease.Version < NewRelease.Version then
    Result := True
  else if CurrentRelease.Version = NewRelease.Version then
  begin
    if CurrentRelease.Major < NewRelease.Major then
      Result := True
    else if CurrentRelease.Major = NewRelease.Major then
    begin
      if CurrentRelease.Minor < NewRelease.Minor then
        Result := True
      else if CurrentRelease.Minor = NewRelease.Minor then
      begin
        if CurrentRelease.Build < NewRelease.Build then
          Result := True;
      end;
    end;
  end;
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

function SafeCreateGUID: TGUID;
begin
  Result.D1 := Cardinal(Random(High(Integer)));
  Result.D2 := Random(High(Word));
  Result.D3 := Random(High(Word));

  Result.D4[0] := Random(High(Byte));
  Result.D4[1] := Random(High(Byte));
  Result.D4[2] := Random(High(Byte));
  Result.D4[3] := Random(High(Byte));
  Result.D4[4] := Random(High(Byte));
  Result.D4[5] := Random(High(Byte));
  Result.D4[6] := Random(High(Byte));
  Result.D4[7] := Random(High(Byte));
end;

function GetEmptyGUID: TGUID;
begin
  FillChar(Result, SizeOf(Result), #0);
end;

function SafeIsEqualGUID(GUID1, GUID2: TGUID): Boolean;
begin
  Result := (GUID1.D1 = GUID2.D1) and (GUID1.D2 = GUID2.D2) and (GUID1.D3 = GUID2.D3)
    and (GUID1.D4[0] = GUID2.D4[0]) and (GUID1.D4[1] = GUID2.D4[1])
    and (GUID1.D4[2] = GUID2.D4[2]) and (GUID1.D4[3] = GUID2.D4[3])
    and (GUID1.D4[4] = GUID2.D4[4]) and (GUID1.D4[5] = GUID2.D4[5])
    and (GUID1.D4[6] = GUID2.D4[6]) and (GUID1.D4[7] = GUID2.D4[7]);
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Integer): Integer;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: string): string;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

end.
