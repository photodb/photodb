unit uPlayEncryptedMedia;

interface

uses
  SysUtils,
  Windows;

procedure StartMedia(HookDll, Player, Media: string);
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
//just markef of ExternalThreadProcedure end
end;

function InjectDll(TargetId: Cardinal; DllName: string): Cardinal;
var
  BytesWrite    : NativeUInt;
  ParamAddr     : Pointer;
 // pThreadStart  : Pointer;
  Hdl           : NativeUInt;
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
    Result := VirtualAllocEx(Hdl, nil, Length(Text) * 2 + 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    WriteProcessMemory(Hdl, Result, PChar(Text), Length(Text) * 2 + 2, BytesWrite);
  end;

  function CreateExternalPAnsiChar(Text: AnsiString): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(Hdl, nil, Length(Text) + 1, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    WriteProcessMemory(Hdl, Result, PAnsiChar(Text), Length(Text) + 1, BytesWrite);
  end;

begin
  Hdl := OpenProcess(PROCESS_ALL_ACCESS or PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION, False, TargetId);

{  ParamAddr := VirtualAllocEx(Hdl, nil, Length(DllName) * 2 + 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(Hdl, ParamAddr, PWideChar(DllName), Length(DllName) * 2 + 2, BytesWrite);
  pThreadStart := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('LoadLibraryW'));
  hThread  := CreateRemoteThread(Hdl, nil, 0, pThreadStart, ParamAddr, 0, hRemoteThread);   }

  ZeroMemory(@InjectParams, SizeOf(InjectParams));
  InjectParams.ErrorLibraryText := CreateExternalPChar('Invalid hook library!'); //TODO: localize
  InjectParams.ErrorProcedureText := CreateExternalPChar('Invalid hook procedure!'); //TODO: localize

  InjectParams.LibraryName := CreateExternalPChar(DllName);
  InjectParams.StartProcName := CreateExternalPAnsiChar('LoadHook');

  InjectParams.LoadLibraryWAddr := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('LoadLibraryW'));
  InjectParams.GetProcAddressAddr := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('GetProcAddress'));
  InjectParams.ExitThreadProc := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('ExitThread'));
  InjectParams.MessageBoxProc := GetProcAddress(GetModuleHandle('USER32.DLL'), PAnsiChar('MessageBoxW'));

  ParamAddr := VirtualAllocEx(Hdl, nil, SizeOf(TInjectLibParameters), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(Hdl, ParamAddr, @InjectParams, SizeOf(TInjectLibParameters), BytesWrite);

  InjectCodeStart := NativeUInt(Addr(ExternalThreadProcedure));
  InjectCodeLength := NativeUInt(Addr(ExternalThreadProcedureEnd)) - InjectCodeStart;
  InjectCode := VirtualAllocEx(Hdl, nil, InjectCodeLength, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(Hdl, InjectCode, Pointer(InjectCodeStart), InjectCodeLength, BytesWrite);

  hThread  := CreateRemoteThread(Hdl, nil, 0, InjectCode, ParamAddr, 0, hRemoteThread);

  Result := hThread;
end;

procedure StartMedia(HookDll, Player, Media: string);
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  hThread: Cardinal;
begin
  // Устанавливаем отладочные привилегии для выбранного процесса, т.к. без данных
  // привилегий код внедрения работать не будет???
  //TODO: check in dicumentation and in user-mode processes
  //ChangePrivilege('SeDebugPrivilege', True);

  ZeroMemory(@si, SizeOf(si));
  SI.cb := SizeOf(si);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_SHOW;

  CreateProcess(PChar(Player), PChar('"' + Player + '" "' + Media + '"'), nil, nil, False, CREATE_SUSPENDED, nil, nil, SI, PI);

  if pi.dwProcessId > 0 then
  begin
    hThread := InjectDll(pi.dwProcessId, HookDll);

    ResumeThread(hThread);
    WaitForSingleObject(hThread, INFINITE);
    Closehandle(hThread);

    ResumeThread(pi.hThread);
    {$IFDEF DEBUG}
    WaitForSingleObject(pi.hProcess, INFINITE);
    {$ENDIF}

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
  end;
end;

end.
