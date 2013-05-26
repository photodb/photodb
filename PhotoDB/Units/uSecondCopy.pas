unit uSecondCopy;

interface

uses
  Winapi.Windows,
  System.SysUtils,

  UnitSendMessageWithTimeoutThread,

  uConstants,
  uRuntime,
  uSplashThread,
  uShellIntegration,
  uTranslate;

procedure FindRunningVersion;
procedure AllowRunSecondCopy;

implementation

var
  HSemaphore: THandle = 0;

procedure FindRunningVersion;
var
  MessageToSent: string;
  CD: TCopyDataStruct;
  Buf: Pointer;
  P: PByte;
  WinHandle: HWND;
begin
  SetLastError(0);
  HSemaphore := CreateSemaphore( nil, 0, 1, PChar(DB_ID));
  if ((HSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
  begin
    CloseHandle(HSemaphore);
    HSemaphore := 0;

    WinHandle := FindWindow(nil, PChar(DBID));
    if WinHandle <> 0 then
    begin
      MessageToSent := GetCommandLine;

      cd.dwData := WM_COPYDATA_ID;
      cd.cbData := ((Length(MessageToSent) + 1) * SizeOf(Char));
      GetMem(Buf, cd.cbData);
      try
        P := PByte(Buf);

        StrPLCopy(PChar(P), MessageToSent, Length(MessageToSent));
        cd.lpData := Buf;

        if SendMessageEx(WinHandle, WM_COPYDATA, 0, NativeInt(@cd)) then
        begin
          CloseSplashWindow;
          DBTerminating := True;
        end else
        begin
          CloseSplashWindow;
          if ID_YES <> MessageBoxDB(0, TA('This program is running, but isn''t responding! Run new instance?', 'System'), TA('Error'), TD_BUTTON_YESNO, TD_ICON_ERROR) then
            DBTerminating := True;
        end;

      finally
        FreeMem(Buf);
      end;
    end;
  end;
end;

procedure AllowRunSecondCopy;
begin
  if HSemaphore <> 0 then
    CloseHandle(HSemaphore);
end;

end.
