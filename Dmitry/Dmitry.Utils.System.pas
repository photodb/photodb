unit Dmitry.Utils.System;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Winapi.Windows,
  Winapi.PsAPI,
  Dmitry.Memory;

type
  TRelease = record
    Version: Byte;
    Major: Byte;
    Minor: Byte;
    Build: Cardinal;
  end;

type
  TEXEVersionData = record
    CompanyName,
    FileDescription,
    FileVersion,
    InternalName,
    LegalCopyright,
    LegalTrademarks,
    OriginalFileName,
    ProductName,
    ProductVersion,
    Comments,
    PrivateBuild,
    SpecialBuild: string;
  end;

type
  ELoadLibrary = class(Exception);
  EGetProcAddress = class(Exception);

function FractionToUnicodeString(N, D: Integer): string;
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
function GetSystemLanguage: string;
function GetExeVersion(sFileName: string): TRelease;
function StringToRelease(const S: string): TRelease;
function ReleaseToString(Release: TRelease): string;
function ProductVersion: string;
function GetEXEVersionData(const FileName: string): TEXEVersionData;
function IsWindowsVista: Boolean;
function IsWindows8: Boolean;
function IsWindowsXPOnly: Boolean;
function IsNewRelease(CurrentRelease, NewRelease : TRelease) : Boolean;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Integer): Integer; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Int64): Int64; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: string): string; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: AnsiString): AnsiString; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: TDateTime): TDateTime; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Double): Double; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: THandle): THandle; overload;
function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Boolean): Boolean; overload;
function SafeCreateGUID: TGUID;
function GetEmptyGUID: TGUID;
function SafeIsEqualGUID(GUID1, GUID2: TGUID): Boolean;
function FormatEx(FormatString: string; Args: array of const): string;
procedure FindModuleUsages(Modules: TStrings; ApplicationList: TStrings);

function StringToDoublePoint(S: string): Double;
function DoubleToStringPoint(Value: Double): string;
function ExpandEnvironment(const strValue: string): string;

implementation

function FormatEx(FormatString: string; Args: array of const): string;
var
  Index, P, PEnd, Diff, ParametersPos: Integer;
  S, SIndex, Parameters: string;
begin
  Result := FormatString;

  P := 1;
  while P > 0 do
  begin
    P := PosEx('{', Result, P);
    if P > 0 then
    begin
      PEnd := PosEx('}', Result, P);
      if PEnd = 0 then
        Break;

      ParametersPos := PosEx(':', Result, P);
      if (ParametersPos > 0) and (ParametersPos < PEnd) then
        SIndex := Copy(Result, P + 1, ParametersPos - P - 1)
      else
        SIndex := Copy(Result, P + 1, PEnd - P - 1);

      Index := StrToIntDef(SIndex, -1);
      if Index = -1 then
      begin
        P := P + 1;
        Continue;
      end;

      Parameters := Copy(Result, P + 2, PEnd - P - 2);
      if (Parameters <> '') and (Parameters[1] = ':') then
        Parameters := Copy(Parameters, 2, Length(Parameters) - 1)
      else if Parameters <> '' then
        raise Exception.Create('Invalid format arguments at index ' + IntToStr(Index) + '!');

      S := '';
      case Args[Index].VType of
        vtInteger: S := IntToStr(Args[Index].VInteger);
        vtPChar: S := string(Args[Index].VPChar);
        vtExtended:
        begin
          if Parameters <> '' then
            S := FormatFloat(Parameters, Args[Index].VExtended^)
          else
            S := FloatToStr(Args[Index].VExtended^);
        end;
        vtChar: S := string(AnsiString(Args[Index].VChar));
        vtWideChar: S := string(Args[Index].VChar);
        vtAnsiString: S := string(PAnsiChar(Args[Index].VAnsiString));
        vtWideString: S := string(PWideChar(Args[Index].VWideString));
        vtUnicodeString: S := string(PWideChar(Args[Index].VUnicodeString));
        vtBoolean: S := IntToStr(IIF(Args[Index].VBoolean, 1, 0));
        vtInt64: S := IntToStr(Args[Index].VInteger);
      else
        raise Exception.Create('Unknown type');
      end;

      Result := Copy(Result, 1, P - 1) + S + Copy(Result, PEnd + 1, Length(Result) - PEnd);
      Diff := Length(S) - (PEnd - P) - 1;
      P := PEnd + Diff - 1;
      if P <= 0 then
        P := 1;
    end;
  end;
end;

function FractionToUnicodeString(N, D: Integer): string;

const
  SuperScript: array[0..9] of string = ('⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹');
  SubScript: array[0..9] of string =   ('₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉');
var
  Munus: Boolean;
  Num, Dev: Integer;
  DevEx: Extended;
  Frac: string;

  function NOD(a, b: Longint): Longint;
  begin
    while (a <> 0) and ( b<> 0) do
    if (a > b) then
      a := a mod b
    else
      b := b mod a;
    if (a = 0) then
      result := b
    else
      result := a;
  end;

begin
  if D = 0 then
    Exit('');
  Munus := N * D < 0;
  N := Abs(N);
  D := Abs(D);

  Num := N div D;
  if Num > 0 then
    N := N - Num * D;

  if N > 0 then
  begin
    DevEx := ((D / N) - D div N);
    if System.Frac(DevEx) < 0.0001 then
    begin
      Dev := NOD(D, N);
      if Dev > 0 then
      begin
        N := N div Dev;
        D := D div Dev;
      end;
    end;
  end;

  Result := '+';
  if Munus then
    Result := '-';

  if Num > 0 then
    Result := Result + IntToStr(Num);

  if N > 0 then
  begin
    Frac := IntToStr(N) + '/' + IntToStr(D);
    if Num > 0 then
      Frac := '(' + Frac + ')';

    if (N < 10) and (D < 10) then
      Frac := SuperScript[N] + '⁄' + SubScript[D];

    Result := Result + Frac;
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

function IsWindows8: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  Result := (VerInfo.dwMajorVersion = 6) and (VerInfo.dwMinorVersion = 2);
end;

function IsWindowsXPOnly: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  Result := (VerInfo.dwMajorVersion = 5) and (VerInfo.dwMinorVersion = 1);
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

function IsNewRelease(CurrentRelease, NewRelease: TRelease): Boolean;
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

function GetEXEVersionData(const FileName: string): TEXEVersionData;
type
  PLandCodepage = ^TLandCodepage;
  TLandCodepage = record
    wLanguage,
    wCodePage: word;
  end;
var
  dummy,
  len: cardinal;
  buf, pntr: pointer;
  lang: string;
begin
  Result := Default(TEXEVersionData);
  len := GetFileVersionInfoSize(PChar(FileName), dummy);
  if len = 0 then
    Exit;

  GetMem(buf, len);
  try
    if not GetFileVersionInfo(PChar(FileName), 0, len, buf) then
      RaiseLastOSError;

    if not VerQueryValue(buf, '\VarFileInfo\Translation\', pntr, len) then
      RaiseLastOSError;

    lang := Format('%.4x%.4x', [PLandCodepage(pntr)^.wLanguage, PLandCodepage(pntr)^.wCodePage]);

    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\CompanyName'), pntr, len){ and (@len <> nil)} then
      result.CompanyName := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\FileDescription'), pntr, len){ and (@len <> nil)} then
      result.FileDescription := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\FileVersion'), pntr, len){ and (@len <> nil)} then
      result.FileVersion := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\InternalName'), pntr, len){ and (@len <> nil)} then
      result.InternalName := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\LegalCopyright'), pntr, len){ and (@len <> nil)} then
      result.LegalCopyright := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\LegalTrademarks'), pntr, len){ and (@len <> nil)} then
      result.LegalTrademarks := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\OriginalFileName'), pntr, len){ and (@len <> nil)} then
      result.OriginalFileName := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\ProductName'), pntr, len){ and (@len <> nil)} then
      result.ProductName := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\ProductVersion'), pntr, len){ and (@len <> nil)} then
      result.ProductVersion := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\Comments'), pntr, len){ and (@len <> nil)} then
      result.Comments := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\PrivateBuild'), pntr, len){ and (@len <> nil)} then
      result.PrivateBuild := PChar(pntr);
    if VerQueryValue(buf, PChar('\StringFileInfo\' + lang + '\SpecialBuild'), pntr, len){ and (@len <> nil)} then
      result.SpecialBuild := PChar(pntr);
  finally
    FreeMem(buf);
  end;
end;

function StripHexPrefix(const HexStr: string): string;
begin
  if Pos('$', HexStr) = 1 then
    Result := Copy(HexStr, 2, Length(HexStr) - 1)
  else if Pos('0x', LowerCase(HexStr)) = 1 then
    Result := Copy(HexStr, 3, Length(HexStr) - 2)
  else
    Result := HexStr;
end;

function AddHexPrefix(const HexStr: string): string;
begin
  Result := HexDisplayPrefix + StripHexPrefix(HexStr);
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
    raise EConvertError.CreateFmt(sHexConvertError, [HexStr]);
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

function HexStringToString(Text: string): string;
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

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Int64): Int64;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Integer): Integer;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Boolean): Boolean;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: THandle): THandle;
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

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: AnsiString): AnsiString; overload;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: TDateTime): TDateTime;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function IIF(Condition: Boolean; ValueIfTrue, ValueIfFalse: Double): Double;
begin
  if Condition then
    Result := ValueIfTrue
  else
    Result := ValueIfFalse;
end;

function DoubleToStringPoint(Value: Double): string;
var
  LocalFormatSettings: TFormatSettings;
begin
  // Initialize special format settings record
  LocalFormatSettings := TFormatSettings.Create(0);

  LocalFormatSettings.DecimalSeparator := '.';

  Result := FloatToStrF(Value, ffFixed, 12,
    // Precision: "should be 18 or less for values of type Extended"
    9, // Scale 0..18.   Sure...9 digits before decimal mark, 9 digits after. Why not
    LocalFormatSettings);
end;

function StringToDoublePoint(S: string): Double;
var
  LocalFormatSettings: TFormatSettings;
begin
  // Initialize special format settings record
  LocalFormatSettings := TFormatSettings.Create(0);

  LocalFormatSettings.DecimalSeparator := '.';

  Result := StrToFloatDef(S, 0, LocalFormatSettings);
end;

function ExpandEnvironment(const strValue: string): string;
var
  chrResult: array[0..1023] of Char;
  wrdReturn: DWORD;
begin
  wrdReturn := ExpandEnvironmentStrings(PChar(strValue), chrResult, 1024);
  if wrdReturn = 0 then
    Result := strValue
  else
  begin
    Result := Trim(chrResult);
  end;
end;

procedure FindModuleUsages(Modules: TStrings; ApplicationList: TStrings);
var
  PIDArray: array [0..1023] of DWORD;
  cb: DWORD;
  I, J, K: Integer;
  ProcCount: Integer;
  hMod: array[0..1023] of HMODULE;
  hProcess: THandle;
  ModuleName: array [0..1023] of Char;
  ApplicationPath: string;
  ModulePath: string;
begin
  ApplicationList.Clear;

  EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
  ProcCount := cb div SizeOf(DWORD);
  for I := 0 to ProcCount - 1 do
  begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or
      PROCESS_VM_READ,
      False,
      PIDArray[I]);

    if (hProcess <> 0) then
    begin
      FillChar(hMod, SizeOf(hMod), 0);
      EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);

      for J := 0 to Length(hMod) - 1 do
      begin
        if hMod[J] = 0 then
          Break;

        GetModuleFileNameEx(hProcess, hMod[J], ModuleName, SizeOf(ModuleName));
        ModulePath := AnsiLowerCase(ModuleName);
        if J = 0 then
        begin
          ApplicationPath := ModulePath;
          Continue;
        end;
        for K := 0 to Modules.Count - 1 do
        begin
          if ModulePath = AnsiLowerCase(Modules[K]) then
          begin
            if ApplicationList.IndexOf(ApplicationPath) = -1 then
              ApplicationList.Add(ApplicationPath);
          end;
        end;
      end;

      CloseHandle(hProcess);
    end;
  end;
end;

//XE2 hook
function DelayedHandlerHook(dliNotify: dliNotification; pdli: PDelayLoadInfo): Pointer; stdcall;
begin
  Result := nil;
  if dliNotify = dliFailLoadLibrary then
    raise ELoadLibrary.Create('Could not load ' + pdli.szDll)
  else if dliNotify = dliFailGetProcAddress then
    if pdli.dlp.fImportByName then
      raise EGetProcAddress.Create('Could not load ' + string(pdli.dlp.szProcName) + ' from ' + string(pdli.szDll))
    else
      raise EGetProcAddress.Create('Could not load index ' + IntToStr(pdli.dlp.dwOrdinal) + ' from ' + string(pdli.szDll))
end;

initialization
  SetDliNotifyHook2(DelayedHandlerHook);

finalization
  SetDliNotifyHook2(nil);

end.
