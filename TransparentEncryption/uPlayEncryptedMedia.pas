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

function ChangePrivilege(szPrivilege: PChar; FEnable: Boolean): Boolean;
var
  NewState: TTokenPrivileges;
  luid: TLargeInteger;
  hToken: THandle;
  ReturnLength: DWord;
begin
  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken);
  LookupPrivilegeValue(nil, szPrivilege, luid);
  NewState.PrivilegeCount := 1;
  NewState.Privileges[0].Luid := luid;
  if (fEnable) then
    NewState.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
  else
    NewState.Privileges[0].Attributes := 0;

  Result := AdjustTokenPrivileges(hToken, False, NewState, SizeOf(NewState), nil, ReturnLength);
  CloseHandle(hToken);
end;

function InjectDll(TargetId: Cardinal; DllName: string): Cardinal;
var
  BytesWrite    : NativeUInt;
  ParamAddr     : Pointer;
  pThreadStart  : Pointer;
  Hdl           : NativeUInt;
  hThread       : Cardinal;
  hRemoteThread : Cardinal;
begin
  // Открываем существующий объект процесса
  Hdl := OpenProcess(PROCESS_ALL_ACCESS, False, TargetId);
  // Выделяем память под структуру, которая передается нашей функции, под параметры, которые передаются функции
  ParamAddr := VirtualAllocEx(Hdl, nil, Length(DllName) * 2 + 2, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  // Пишем саму структуру
  WriteProcessMemory(Hdl,  ParamAddr, PWideChar(DllName), Length(DllName) * 2 + 2, BytesWrite);
  pThreadStart := GetProcAddress(GetModuleHandle('KERNEL32.DLL'), PAnsiChar('LoadLibraryW'));
  // Запускаем удаленный поток
  hThread  := CreateRemoteThread(Hdl, nil, 0, pThreadStart, ParamAddr, 0, hRemoteThread);
  // Ждем пока удаленный поток отработает...
  Result := hThread;
end;

procedure StartMedia(HookDll, Player, Media: string);
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  hThread: Cardinal;
begin
  // Устанавливаем отладочные привилегии для выбранного процесса, т.к. без данных
  // привилегий код внедрения работать не будет
  ChangePrivilege('SeDebugPrivilege', True);

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
    //WaitForSingleObject(pi.hProcess, INFINITE);

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
  end;
end;

end.
