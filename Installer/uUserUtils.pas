unit uUserUtils;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.ShellApi,
  uMemory,
  uAppUtils,
  uSysUtils;

function RunAsAdmin(hWnd: HWND; FileName: string; Parameters: string; IsCurrentUserAdmin: Boolean): THandle;
function RunAsUser(ExeName, ParameterString, WorkDirectory: string; Wait: Boolean): THandle;
procedure ProcessCommands(FileName: string);
procedure UserAccountService(FileName: string; IsCurrentUserAdmin : Boolean);

implementation

function GetTempDirectory: string;
var
  TempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  Result := StrPas(TempFolder);
end;

function GetTempFileName: TFileName;
var
  TempFileName: array [0..MAX_PATH-1] of char;
begin
  if Winapi.Windows.GetTempFileName(PChar(GetTempDirectory), '~', 0, TempFileName) = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
  Result := TempFileName;
end;

procedure UserAccountService(FileName: string; IsCurrentUserAdmin: Boolean);
var
  InstallHandle: THandle;
  CommandsFileName: string;
  ExitCode: Cardinal;
begin
  CommandsFileName := GetTempFileName;
  CloseHandle(CreateFile(PChar(CommandsFileName),
    GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL or
    FILE_ATTRIBUTE_NOT_CONTENT_INDEXED, 0));

  try
    InstallHandle := RunAsAdmin(0, FileName, '/admin /commands "' + CommandsFileName + '"', IsCurrentUserAdmin);
    if InstallHandle <> 0 then
    begin

      if InstallHandle > 0 then
      begin
        repeat
          Sleep(100);
          ProcessCommands(CommandsFileName);

          GetExitCodeProcess(InstallHandle, ExitCode);
        until ExitCode <> STILL_ACTIVE;
      end;
    end;

  finally
    DeleteFile(PChar(CommandsFileName));
  end;
end;

function RunAsAdmin(hWnd: HWND; FileName: string; Parameters: string; IsCurrentUserAdmin: Boolean): THandle;
{
    See Step 3: Redesign for UAC Compatibility (UAC)
    http://msdn.microsoft.com/en-us/library/bb756922.aspx
}
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hwnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  if not IsCurrentUserAdmin then
    sei.lpVerb := PChar('runas')
  else
    sei.lpVerb := PChar('open');
  sei.lpFile := PChar(FileName); // PAnsiChar;
  if parameters <> '' then
      sei.lpParameters := PChar(parameters); // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; //Integer;

  Result := 0;
  if ShellExecuteEx(@sei) then
    Result := sei.hProcess;
end;

function RunAsUser(ExeName, ParameterString, WorkDirectory: string; Wait: Boolean): THandle;
var
  FS: TFileStream;
  SW: TStreamWriter;
  SR: TStreamReader;
  StartTime: Cardinal;
  Res: Integer;
  CommandFileName: string;
begin
  CommandFileName := GetParamStrDBValue('/commands');
  Result := 0;
  try
    FS := TFileStream.Create(CommandFileName, fmOpenWrite);
    try
      FS.Size := 0;
      SW := TStreamWriter.Create(FS);
      try
        SW.Write(ExeName);
        SW.WriteLine;
        SW.Write(ParameterString);
        SW.WriteLine;
        SW.Write(WorkDirectory);
        SW.WriteLine;
        SW.Write(IIF(Wait, '1', '0'));
        SW.WriteLine;
      finally
        F(SW);
      end;
    finally
      F(FS);
    end;
  except
    Exit;
  end;
  StartTime := GetTickCount;
  while GetTickCount - StartTime < 1000 * 30 do
  begin
    Sleep(1000);
    try
      FS := TFileStream.Create(CommandFileName, fmOpenRead or fmShareDenyNone);
      try
        SR := TStreamReader.Create(FS);
        try
          Res := StrToIntDef(SR.ReadLine, -1);
          if Res >= 0 then
          begin
            Result := Res;
            Break;
          end;
        finally
          F(SR);
        end;
      finally
        F(FS);
      end;
    except
      Continue;
    end;
  end;
end;

procedure ProcessCommands(FileName: string);
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  FS: TFileStream;
  SR: TStreamReader;
  SW: TStreamWriter;
  ExeFileName, ExeParams, ExeDirectory: string;
  WaitProgram: Boolean;

  procedure WritePID(PID: Integer);
  begin
    try
      FS := TFileStream.Create(FileName, fmOpenWrite);
      try
        FS.Size := 0;
        SW := TStreamWriter.Create(FS);
        try
          SW.Write(IntToStr(PID));
        finally
          F(SW);
        end;
      finally
        F(FS);
      end;
    except
      Exit;
    end;
  end;
begin
  try
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      SR := TStreamReader.Create(FS);
      try
        ExeFileName := SR.ReadLine;
        ExeParams := SR.ReadLine;
        ExeDirectory := SR.ReadLine;
        WaitProgram := SR.ReadLine = '1';
      finally
        F(SR);
      end;
    finally
      F(FS);
    end;
  except
    Exit;
  end;

  if (ExeFileName <> '') and (ExeFileName = ExeParams) and (ExeFileName = ExeDirectory) then
  begin
    ShellExecute(0, 'open', PWideChar(ExeFileName), nil, nil, SW_NORMAL);
    WritePID(0);
  end;

  if FileExists(ExeFileName) and (ExeParams <> '') and (ExeDirectory <> '') then
  begin
    { fill with known state }
    FillChar(StartInfo, SizeOf(TStartupInfo), #0);
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
    try
      with StartInfo do begin
        cb := SizeOf(StartInfo);
        dwFlags := STARTF_USESHOWWINDOW;
        wShowWindow := SW_NORMAL;
      end;

      CreateProcess(nil, PChar('"' + ExeFileName + '"' + ' ' + ExeParams), nil, nil, False,
                  CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS,
                  nil, PChar(ExcludeTrailingPathDelimiter(ExeDirectory)), StartInfo, ProcInfo);

      if WaitProgram then
        WaitForSingleObject(ProcInfo.hProcess, 30000);

      WritePID(ProcInfo.hProcess);
    finally
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
    end;
  end;
end;

end.
