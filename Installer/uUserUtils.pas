unit uUserUtils;

interface

uses
  Windows,
  SysUtils,
  Classes,
  uMemory,
  uFileUtils,
  uAppUtils,
  uSysUtils,
  ShellApi;

function RunAsAdmin(hWnd: HWND; FileName: string; Parameters: string; IsCurrentUserAdmin: Boolean): THandle;
function RunAsUser(ExeName, ParameterString, WorkDirectory: string): THandle;
procedure ProcessCommands(FileName: string);

implementation

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
  if IsCurrentUserAdmin and not IsWindowsVista then
    sei.lpVerb := PChar('open')
  else
    sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(FileName); // PAnsiChar;
  if parameters <> '' then
      sei.lpParameters := PChar(parameters); // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; //Integer;

  Result := 0;
  if ShellExecuteEx(@sei) then
    Result := sei.hProcess;
end;

function RunAsUser(ExeName, ParameterString, WorkDirectory: string): THandle;
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
    Sleep(100);
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

  if FileExistsSafe(ExeFileName) and (ExeParams <> '') and (ExeDirectory <> '') then
  begin
    { fill with known state }
    FillChar(StartInfo, SizeOf(TStartupInfo), #0);
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
    StartInfo.Cb := SizeOf(TStartupInfo);

    CreateProcess(PChar(ExeFileName), PChar(ExeParams), nil, nil, False,
                CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,
                nil, PChar(ExeDirectory), StartInfo, ProcInfo);

    WritePID(ProcInfo.hProcess);
  end;
end;

end.
