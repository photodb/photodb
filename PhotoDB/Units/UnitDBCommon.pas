unit UnitDBCommon;

interface

uses
  Windows, Classes, Forms, Math, SysUtils, Messages, uMemory;

function ActivateApplication(const hWND: THandle): Boolean;
function ProgramDir: string;
procedure ActivateBackgroundApplication(hWnd: THandle);

implementation

function ActivateApplication(const hWND: THandle): Boolean;
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
  if IsIconic(hWND) then ShowWindow(hWND, SW_RESTORE);
    hParent := GetWindowLong(hWND, GWL_HWNDPARENT);
  if hParent > 0 then
    if IsIconic(hParent) then ShowWindow(hParent, SW_RESTORE);

  if (GetForegroundWindow = hWND) then
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
      TheThreadID := GetWindowThreadProcessId(hWND,nil);
      if AttachThreadInput(TheThreadID, ForegndThreadID, true) then
      begin
        SetForegroundWindow(hWND);
        AttachThreadInput(TheThreadID, ForegndThreadID, false);
        Result := (GetForegroundWindow = hWND);
      end;
      if not Result then
      begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, nil, SPIF_SENDCHANGE);
        SetForegroundWindow(hWND);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @timeout, SPIF_SENDCHANGE);
      end;
    end else // OS is above win 95
      SetForegroundWindow(hWND);
    Result := (GetForegroundWindow = hWND);
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
    SendMessage(hWND,WM_SYSCOMMAND,SC_MINIMIZE,0);
    Sleep(40);
    if hParent > 0 then
      SendMessage(hParent,WM_SYSCOMMAND,SC_RESTORE,0)
    else
      SendMessage(hWND,WM_SYSCOMMAND,SC_RESTORE,0);
    if Animate then
    begin
      AniInfo.iMinAnimate := 1;
      SystemParametersInfo(SPI_SETANIMATION, SizeOf(AniInfo), @AniInfo, 0);
    end;

    Result := (GetForegroundWindow = hWND);
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

procedure ActivateBackgroundApplication(hWnd: THandle);
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

function ProgramDir : string;
begin
  Result := ExtractFileDir(ParamStr(0)) + '\';
end;

end.
