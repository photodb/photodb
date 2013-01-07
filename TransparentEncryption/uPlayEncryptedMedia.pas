unit uPlayEncryptedMedia;

interface

uses
  SysUtils,
  Windows;

function StartMedia(HookDll, Player, Media: string): Boolean;
procedure PlayMediaFromCommanLine;

implementation

procedure PlayMediaFromCommanLine;
var
  LibPath: string;
  PlayerPath: string;
  Media: string;
begin
  LibPath := ExtractFilePath(ParamStr(0)) + 'TransparentEncryption' {$IFDEF cpux64} + '64' {$ENDIF} + '.dll';
  PlayerPath := ParamStr(1);
  Media := ParamStr(2);
  StartMedia(LibPath, PlayerPath, Media);
end;

type
  TLoadLibrary = function(lpLibFileName: PWideChar): HMODULE; stdcall;
  TGetProcAddress = function (hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
  TStartProcAddr = procedure; stdcall;
  TExitThread = procedure (dwExitCode: DWORD); stdcall;
  TMessageBox = function(hWnd: HWND; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;

  TInjectLibParameters = record
    LibraryName: PChar;
    StartProcName: LPCSTR;
    StartProcAddr: TStartProcAddr;
    LoadLibraryWAddr: TLoadLibrary;
    LibraryModule: HModule;
    GetProcAddressAddr: TGetProcAddress;
    ExitThreadProc: TExitThread;
    ErrorProcedureText: PChar;
    ErrorLibraryText: PChar;
    MessageBoxProc: TMessageBox;
  end;
  PInjectLibParameters = ^TInjectLibParameters;

  TCallProcedure = procedure(InjectParameters: PInjectLibParameters); stdcall;

procedure ExternalThreadProcedure(InjectParameters: PInjectLibParameters); stdcall;
begin
  InjectParameters.LibraryModule := InjectParameters.LoadLibraryWAddr(InjectParameters.LibraryName);
  if InjectParameters.LibraryModule = 0 then
    InjectParameters.MessageBoxProc(0, InjectParameters.ErrorLibraryText, nil, MB_OK or MB_ICONWARNING);

  InjectParameters.StartProcAddr := InjectParameters.GetProcAddressAddr(InjectParameters.LibraryModule, InjectParameters.StartProcName);

  if @InjectParameters.StartProcAddr <> nil then
    InjectParameters.StartProcAddr()
  else
    InjectParameters.MessageBoxProc(0, InjectParameters.ErrorProcedureText, nil, MB_OK or MB_ICONERROR);

  InjectParameters.ExitThreadProc(0);
end;
procedure ExternalThreadProcedureEnd;
begin
//just marker of ExternalThreadProcedure end
end;

function InjectDll(hProcess: NativeInt; DllName: string): Cardinal;
var
  BytesWrite    : NativeUInt;
  ParamAddr     : Pointer;
  hThread       : Cardinal;
  hRemoteThread : Cardinal;
  InjectParams  : TInjectLibParameters;

  InjectCodeStart  : NativeUInt;
  InjectCodeLength : Integer;
  InjectCode       : PByteArray;

  function CreateExternalPChar(Text: string): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(hProcess, nil, Length(Text) * 2 + 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if not WriteProcessMemory(hProcess, Result, PChar(Text), Length(Text) * 2 + 2, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), 0);
  end;

  function CreateExternalPAnsiChar(Text: AnsiString): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(hProcess, nil, Length(Text) + 1, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if not WriteProcessMemory(hProcess, Result, PAnsiChar(Text), Length(Text) + 1, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), 0);
  end;

begin
  if (hProcess = 0)  then
    MessageBox(0, PChar('Can''t open remote process!'), PChar('Can''t open remote process!'), 0);

  ZeroMemory(@InjectParams, SizeOf(InjectParams));
  InjectParams.ErrorLibraryText := CreateExternalPChar('Invalid hook library!'); //TODO: localize
  InjectParams.ErrorProcedureText := CreateExternalPChar('Invalid hook procedure!'); //TODO: localize

  InjectParams.LibraryName := CreateExternalPChar(DllName);
  InjectParams.StartProcName := CreateExternalPAnsiChar('LoadHook');

  InjectParams.LoadLibraryWAddr := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('LoadLibraryW'));
  InjectParams.GetProcAddressAddr := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('GetProcAddress'));
  InjectParams.ExitThreadProc := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('ExitThread'));
  InjectParams.MessageBoxProc := GetProcAddress(GetModuleHandle('USER32.DLL'), PAnsiChar('MessageBoxW'));

  ParamAddr := VirtualAllocEx(hProcess, nil, SizeOf(TInjectLibParameters), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(hProcess, ParamAddr, @InjectParams, SizeOf(TInjectLibParameters), BytesWrite);

  InjectCodeStart := NativeUInt(Addr(ExternalThreadProcedure));
  InjectCodeLength := NativeUInt(Addr(ExternalThreadProcedureEnd)) - InjectCodeStart;
  InjectCode := VirtualAllocEx(hProcess, nil, InjectCodeLength, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(hProcess, InjectCode, Pointer(InjectCodeStart), InjectCodeLength, BytesWrite);

  if InjectCode = nil then
    MessageBox(0, PChar('InjectCode is null'), PChar('InjectCode is null'), 0);
  if ParamAddr = nil then
    MessageBox(0, PChar('ParamAddr is null'), PChar('ParamAddr is null'), 0);

  hThread  := CreateRemoteThread(hProcess, nil, 0,
    InjectCode,
    ParamAddr,
    CREATE_SUSPENDED,
    hRemoteThread);

  if hThread = 0 then
    MessageBox(0, PChar('Can''t create remote thread!'), PChar('Can''t create remote thread!'), 0);

  Result := hThread;
end;

function StartMedia(HookDll, Player, Media: string): Boolean;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  hThread: Cardinal;
  StartupFlags: Cardinal;
  IsXP: Boolean;
begin
  Result := False;

  if not FileExists(HookDll) then
    Exit(False);

  ZeroMemory(@si, SizeOf(si));
  SI.cb := SizeOf(si);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_SHOW;

  StartupFlags := 0;

  IsXP := TOSVersion.Major < 6;

  if not IsXP then
    //fails on XP
    //Small delay between CreateProcess and CreateRemoteThread is required - actual for XP
    //hope it will work on XP!
    StartupFlags := CREATE_SUSPENDED;

  CreateProcess(PChar(Player), PChar('"' + Player + '" "' + Media + '"'), nil, nil, True, StartupFlags, nil, PChar(ExtractFileDir(Player)), SI, PI);

  if pi.dwProcessId > 0 then
  begin
    hThread := InjectDll(PI.hProcess, HookDll);

    ResumeThread(hThread);

    WaitForSingleObject(hThread, INFINITE);
    CloseHandle(hThread);

    ResumeThread(PI.hThread);
    {$IFDEF DEBUG}
    WaitForSingleObject(PI.hProcess, INFINITE);
    {$ENDIF}

    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
    Result := True;
  end;
end;

end.
