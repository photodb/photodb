unit uPlayEncryptedMedia;

interface

uses
  System.SysUtils,
  Winapi.Windows;

function StartMedia(HookDll, Player, Media: string): Boolean;
procedure PlayMediaFromCommanLine;

implementation

const
  E_OK                    = 0;
  E_UNKNOWN_ERROR         = 1;
  E_OPEN_FILE_ERROR       = 2;
  E_MAPPING_FILE_ERROR    = 3;
  E_MZ_SIGNATURE_INVALID  = 4;
  E_PE_SIGNATURE_INVALID  = 5;
  E_EXE_INVALID           = 6;
  E_EXE_IS_DLL            = 7;
  E_ENTRY_POINT_ZERRO     = 8;
  E_CREATE_PROCESS_FAILED = 9;

//------------------------------------------------------------------------------
//Entry point injection START
//------------------------------------------------------------------------------
{procedure load;
asm
  mov ebp,esp
  push $11111110  // virtualprotect ebp-4
  push $11111111  // loadlibrary    ebp-8
  push $11111112  // dll name       ebp-12
  push $11111113  // old cod        ebp-16
  push $11111114  // start adr      ebp-20
  sub esp,4       // место под memflag
  mov eax,ebp
  sub eax,24
  push eax      // oldflag
  push $40      // PAGE_READWRITE
  push 5        // size
  push [ebp-20] // adr
  call [ebp-4]  // virtualprotect
  xor ecx,ecx
  mov cl,5    // 5 байт копировать
  mov esi,[ebp-16] // сохраненный код
  mov edi,[ebp-20] // точка входа
  cld
  rep movsb
  mov eax,ebp
  sub eax,24
  push eax     // oldflag   //адрес для сохранения флага
  push [eax]   // oldflag
  push 5       // size
  push [ebp-20]// adr
  call [ebp-4] // virtualprotect
  push [ebp-12] // dll name
  call [ebp-8]// loadlibrary
  mov esp,ebp
  jmp  [ebp-20]// goto start   @b//
end; }

{function StartExeWithInjectedDll(DllFileName, ExeFileName, CommandLine: string): Integer;
type
  MZ_MARKER = array [0 .. 1] of AnsiChar;
  PE_MARKER = array [0 .. 3] of AnsiChar;

  tjmprec = packed record
    jmpbyte: Byte; // $E9
    jmpsize: Integer;
  end;

var
  hFile, fm, hdll: Cardinal;
  SI: TStartupInfo;
  PI: TProcessInformation;
  P, P1, mb, procmem: Pointer;
  EntPoint: Cardinal;
  load_size: Cardinal;
  WB, RB: NativeUInt;
  jmp_code: tjmprec;

  function CreateExternalPChar(Text: string): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(PI.hProcess, nil, Length(Text) * 2 + 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if not WriteProcessMemory(PI.hProcess, Result, PChar(Text), Length(Text) * 2 + 2, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory failed: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory failed: ' + IntToStr(GetLastError)), 0);
  end;

  function CreateExternalPAnsiChar(Text: AnsiString): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(PI.hProcess, nil, Length(Text) + 1, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if not WriteProcessMemory(PI.hProcess, Result, PAnsiChar(Text), Length(Text) + 1, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory failed: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory failed: ' + IntToStr(GetLastError)), 0);
  end;

begin
  Result := E_UNKNOWN_ERROR;

  hFile := CreateFile(PChar(ExeFileName), GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then
    Exit(E_OPEN_FILE_ERROR);

  try
    fm := CreateFileMapping(hFile, nil, PAGE_READONLY, 0, GetFileSize(hFile, nil), nil);
    if hFile = INVALID_HANDLE_VALUE then
      Exit(E_MAPPING_FILE_ERROR);

    try
      P := MapViewOfFile(fm, FILE_MAP_READ, 0, 0, 0);
      if P = nil then
        Exit(E_MAPPING_FILE_ERROR);

      try
        if MZ_MARKER(PImageDosHeader(P)^.e_magic) <> 'MZ' then
          Exit(E_MZ_SIGNATURE_INVALID);

        P1 := Pointer(NativeUInt(P) + NativeUInt(PImageDosHeader(P)^._lfanew));
        if PE_MARKER(PIMAGENTHEADERS(P1).Signature) = 'PE'#0#0 then
          Exit(E_PE_SIGNATURE_INVALID);

        if (IMAGE_FILE_EXECUTABLE_IMAGE <> (IMAGE_FILE_EXECUTABLE_IMAGE and PIMAGENTHEADERS(P1).FileHeader.Characteristics)) then
          Exit(E_EXE_INVALID);

        if (IMAGE_FILE_DLL = (IMAGE_FILE_DLL and PIMAGENTHEADERS(P1).FileHeader.Characteristics)) then
          Exit(E_EXE_IS_DLL);

        EntPoint := PIMAGENTHEADERS(P1).OptionalHeader.ImageBase +  PIMAGENTHEADERS(P1).OptionalHeader.AddressOfEntryPoint;
        if EntPoint = 0 then
          Exit(E_ENTRY_POINT_ZERRO);

      finally
        UnMapViewOfFile(P);
      end;
    finally
      CloseHandle(fm);
    end;
  finally
    CloseHandle(hFile);
  end;

  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  if not CreateProcess(nil, PChar('"' + ExeFileName + '" ' + CommandLine), nil, nil, True, CREATE_SUSPENDED, nil, nil, SI, PI) then
    Exit(E_CREATE_PROCESS_FAILED);

  try
    load_size := 86;
    WB := load_size + Length(DllFileName) + SizeOf(jmp_code) + 1;

    GetMem(mb, WB);
    try
      procmem := VirtualAllocEx(PI.hProcess, nil, WB, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if procmem = nil then
        Exit;

      Move((@load)^, mb^, load_size);
      hdll := LoadLibrary('kernel32.dll');
      pcardinal(Cardinal(mb) + 3)^ :=  Cardinal(GetProcAddress(hdll, 'VirtualProtect')); // ebp
      pcardinal(Cardinal(mb) + 8)^ :=  Cardinal(GetProcAddress(hdll, 'LoadLibraryA')); // ebp-4
      pcardinal(Cardinal(mb) + 13)^ := Cardinal(procmem) + load_size +  SizeOf(jmp_code); // ebp-8
      pcardinal(Cardinal(mb) + 18)^ := Cardinal(procmem) + load_size; // ebp-12
      pcardinal(Cardinal(mb) + 23)^ := EntPoint; // ebp-16
      RB := SizeOf(jmp_code);
      if not ReadProcessMemory(PI.hProcess, Pointer(EntPoint), Pointer(NativeUInt(mb) + load_size), RB, RB) then
        Exit;

      Move((@(DllFileName[1]))^, (Pointer(Cardinal(mb) + load_size + SizeOf(jmp_code)))^, Length(DllFileName) + 1);
      pbyte(Cardinal(mb) + WB - 1)^ := 0;

      if not WriteProcessMemory(PI.hProcess, procmem, mb, WB, WB) then
        Exit;

      jmp_code.jmpbyte := $E9;
      jmp_code.jmpsize := Cardinal(procmem) - EntPoint - SizeOf(jmp_code);
      WB := SizeOf(jmp_code);
      if not WriteProcessMemory(PI.hProcess, Pointer(EntPoint), @jmp_code, WB, WB) then
        Exit;

    finally
      FreeMem(mb);
    end;
  finally
    ResumeThread(PI.hThread);
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end;
  Result := E_OK;
end;}

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

function InjectDll(TargetId: Cardinal; DllName: string): Cardinal;
var
  BytesWrite    : NativeUInt;
  ParamAddr     : Pointer;
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
    if not WriteProcessMemory(Hdl, Result, PChar(Text), Length(Text) * 2 + 2, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), 0);
  end;

  function CreateExternalPAnsiChar(Text: AnsiString): Pointer;
  var
    BytesWrite: NativeUInt;
  begin
    Result := VirtualAllocEx(Hdl, nil, Length(Text) + 1, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if not WriteProcessMemory(Hdl, Result, PAnsiChar(Text), Length(Text) + 1, BytesWrite) then
      MessageBox(0, PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), PChar('WriteProcessMemory fails: ' + IntToStr(GetLastError)), 0);
  end;

begin
  //A handle to the process in which the thread is to be created. The handle must have the PROCESS_CREATE_THREAD, PROCESS_QUERY_INFORMATION, PROCESS_VM_OPERATION, PROCESS_VM_WRITE, and PROCESS_VM_READ access rights, and may fail without these rights on certain platforms.
  Hdl := OpenProcess(PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or PROCESS_VM_WRITE or PROCESS_VM_READ or PROCESS_QUERY_INFORMATION, False, TargetId);

  if (Hdl = 0)  then
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

  ParamAddr := VirtualAllocEx(Hdl, nil, SizeOf(TInjectLibParameters), MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(Hdl, ParamAddr, @InjectParams, SizeOf(TInjectLibParameters), BytesWrite);

  InjectCodeStart := NativeUInt(Addr(ExternalThreadProcedure));
  InjectCodeLength := NativeUInt(Addr(ExternalThreadProcedureEnd)) - InjectCodeStart;
  InjectCode := VirtualAllocEx(Hdl, nil, InjectCodeLength, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  WriteProcessMemory(Hdl, InjectCode, Pointer(InjectCodeStart), InjectCodeLength, BytesWrite);

  if InjectCode = nil then
    MessageBox(0, PChar('InjectCode is null'), PChar('InjectCode is null'), 0);
  if ParamAddr = nil then
    MessageBox(0, PChar('ParamAddr is null'), PChar('ParamAddr is null'), 0);

  hThread  := CreateRemoteThread(Hdl, nil, 0,
    InjectCode,
    ParamAddr,
    CREATE_SUSPENDED,
    hRemoteThread);

  if hThread = 0 then
    MessageBox(0, PChar('Can''t create remote thread!'), PChar('Can''t create remote thread!'), 0);

  CloseHandle(Hdl);

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
    hThread := InjectDll(PI.dwProcessId, HookDll);

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
