unit UnitDBCommon;

interface

uses Windows, Classes, Forms, Math, SysUtils, uScript, UnitScripts, Messages,
     ReplaseIconsInScript, uTime, uMemory, uFileUtils;

function Hash_Cos_C(s:string):integer;
function ActivateApplication(const Handle1: THandle): Boolean;
procedure ExecuteScriptFile(FileName : String; UseDBFunctions : boolean = false);

procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
procedure ProportionalSizeA(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
function HexToIntDef(const HexStr: string; const Default: Integer): Integer;
function ProgramDir : string;
procedure ActivateBackgroundApplication(hWnd : THandle);
function StringToHexString(text : String) : string;
function HexStringToString(text : String) : string;

var
  ProcessorCount: Integer = 0;
  RAWImages: string = 'CR2|';
  TempRAWMask: string = '|THUMB|JPG|TIFF|PBB|';
  SupportedExt : String = '|BMP|JFIF|JPG|JPE|JPEG|RLE|DIB|WIN|VST|VDA|TGA|ICB|TIFF|TIF|FAX|EPS|PCC|PCX|RPF|RLA|SGI|RGBA|RGB|BW|PSD|PDD|PPM|PGM|PBM|CEL|PIC|PCD|GIF|CUT|PSP|PNG|THM|';

implementation

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

function ActivateApplication(const Handle1: THandle): Boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegndThreadID: DWORD;
  TheThreadID      : DWORD;
  timeout           : DWORD;
  OSVersionInfo: TOSVersionInfo;
  hParent: THandle;
  AniInfo: TAnimationInfo;
  Animate: Boolean;
begin
  if IsIconic(Handle1) then ShowWindow(Handle1, SW_RESTORE);
    hParent := GetWindowLong(Handle1, GWL_HWNDPARENT);
  if hParent > 0 then
    if IsIconic(hParent) then ShowWindow(hParent, SW_RESTORE);

  if (GetForegroundWindow = Handle1) then
    Result := true
  else
  begin
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
    GetVersionEx(OSVersionInfo);

    if ((OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT) and (OSVersionInfo.dwMajorVersion > 4))
       or
       ((OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) and ((OSVersionInfo.dwMajorVersion > 4)
       or
       ((OSVersionInfo.dwMajorVersion = 4) and (OSVersionInfo.dwMinorVersion > 0))))
      then
    begin // OS is above win 95
      Result := false;
      ForegndThreadID := GetWindowThreadProcessID(GetForegroundWindow,nil);
      TheThreadID := GetWindowThreadProcessId(Handle1,nil);
      if AttachThreadInput(TheThreadID, ForegndThreadID, true) then
      begin
        SetForegroundWindow(Handle1);
        AttachThreadInput(TheThreadID, ForegndThreadID, false);
        Result := (GetForegroundWindow = Handle1);
      end;
      if not Result then
      begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, nil, SPIF_SENDCHANGE);
        SetForegroundWindow(Handle1);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @timeout, SPIF_SENDCHANGE);
      end;
    end else // OS is above win 95
      SetForegroundWindow(Handle1);
    Result := (GetForegroundWindow = Handle1);
    if Result then Exit;

    AniInfo.cbSize := SizeOf(TAnimationInfo);
    if SystemParametersInfo(SPI_GETANIMATION, SizeOf(AniInfo), @AniInfo, 0) then
      Animate := AniInfo.iMinAnimate <> 0
    else
      Animate := False;
    if Animate then
    begin
      AniInfo.iMinAnimate := 0;
      SystemParametersInfo(SPI_SETANIMATION, SizeOf(AniInfo), @AniInfo, 0);
    end;
    SendMessage(Handle1,WM_SYSCOMMAND,SC_MINIMIZE,0);
    Sleep(40);
    if hParent > 0 then
      SendMessage(hParent,WM_SYSCOMMAND,SC_RESTORE,0)
    else
      SendMessage(Handle1,WM_SYSCOMMAND,SC_RESTORE,0);
    if Animate then
    begin
      AniInfo.iMinAnimate := 1;
      SystemParametersInfo(SPI_SETANIMATION, SizeOf(AniInfo), @AniInfo, 0);
    end;

    Result := (GetForegroundWindow = Handle1);
  end;
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure AllowToSetForegroundWindow(HWND : THandle);
var
  PID: DWORD;
  AllowSetForegroundWindowFunc: function(dwProcessId: DWORD): BOOL; stdcall;
begin
  if GetWindowThreadProcessId(HWND, @PID) <> 0 then begin
    AllowSetForegroundWindowFunc := GetProcAddress(GetModuleHandle(user32),
      'AllowSetForegroundWindow');
    if Assigned(AllowSetForegroundWindowFunc) then
      AllowSetForegroundWindowFunc(PID);
  end;
end;

procedure ActivateBackgroundApplication(hWnd : THandle);
var
  hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: Boolean;
begin
  Application.Restore;
  ShowWindow(hWnd, SW_RESTORE);
  hWnd := Application.Handle;
  SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
  SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);

  hCurWnd := GetForegroundWindow;
  AResult := False;
  while not AResult do
  begin
    dwThreadID := GetCurrentThreadId;
    dwCurThreadID := GetWindowThreadProcessId(hCurWnd);
    AttachThreadInput(dwThreadID, dwCurThreadID, True);
    AResult := SetForegroundWindow(hWnd);
    AttachThreadInput(dwThreadID, dwCurThreadID, False);
  end;

  ShowWindow(Application.MainForm.Handle, SW_HIDE);
  ShowWindow(Application.Handle, SW_HIDE);
end;

function Hash_Cos_C(S: string): Integer;
var
  C, I: Integer;
begin
  C := 0;
{$R-}
  for I := 1 to Length(S) do
    C := C + Round($FFFFFFFF * Cos(I) * Ord(S[I]));
{$R+}
  Result := C;
end;

procedure ExecuteScriptFile(FileName : String; UseDBFunctions : boolean = false);
var
  AScript: TScript;
  I: Integer;
  LoadScript: string;
  AFS: TFileStream;
begin
  AScript := TScript.Create('');
  try
    LoadScript := '';
    try
      AFS := TFileStream.Create(FileName, FmOpenRead);
      SetLength(LoadScript, AFS.Size);
      AFS.read(LoadScript[1], AFS.Size);
      for I := Length(LoadScript) downto 1 do
      begin
        if LoadScript[I] = #10 then
          LoadScript[I] := ' ';
        if LoadScript[I] = #13 then
          LoadScript[I] := ' ';
      end;
      LoadScript := AddIcons(LoadScript);
      AFS.Free;
    except
    end;
    try
      ExecuteScript(nil, AScript, LoadScript, I, nil);
    except
      // on e : Exception do EventLog(':ExecuteScriptFile() throw exception: '+e.Message);
    end;
  finally
    AScript.Free;
  end;
end;

procedure ProportionalSizeA(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
begin
  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

procedure ProportionalSize(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
begin
  if (AWidthToSize < AWidth) and (AHeightToSize < AHeight) then
  begin
    Exit;
  end;
  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

function ProgramDir : string;
begin
  Result := ExtractFileDir(ParamStr(0)) + '\';
end;

function GettingProcNum: Integer; // Win95 or later and NT3.1 or later
var
  Struc: _SYSTEM_INFO;
begin
  GetSystemInfo(Struc);
  Result := Struc.DwNumberOfProcessors;
end;

initialization

  ProcessorCount := GettingProcNum;

end.
