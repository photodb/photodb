unit uWinAPIRedirections;

interface

uses
  Windows,
  SysUtils,
  uAPIHook,
  uStrongCrypt,
  uTransparentEncryption,
  uTransparentEncryptor;

procedure HookPEModule(Module: HModule; Recursive: Boolean = True);
function CreateFileWHookProc(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
function OpenFileAHookProc(const lpFileName: LPCSTR; var lpReOpenBuff: TOFStruct; uStyle: UINT): HFILE; stdcall;
function CreateFileAHookProc(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
function SetFilePointerExHookProc(hFile: THandle; liDistanceToMove: TLargeInteger;
                                         const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL; stdcall;

function SetFilePointerHookProc(hFile: THandle; lDistanceToMove: Longint;
                                         lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
function ReadFileHookProc(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
function ReadFileExHookProc(hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;

function CloseHandleHookProc(hObject: THandle): BOOL; stdcall;
function LoadLibraryAHookProc(lpLibFileName: PAnsiChar): HMODULE; stdcall;
function LoadLibraryWHookProc(lpLibFileName: PWideChar): HMODULE; stdcall;
function GetProcAddressHookProc(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;

var
  CreateProcessANextHook     : function (appName, cmdLine: pchar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pchar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;
  CreateProcessWNextHook     : function (appName, cmdLine: pwidechar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pwidechar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;

  SetFilePointerNextHook     : TSetFilePointerNextHook;

  SetFilePointerExNextHook   : TSetFilePointerExNextHook;

  OpenFileNextHook           : function (const lpFileName: LPCSTR; var lpReOpenBuff: TOFStruct; uStyle: UINT): HFILE; stdcall;

  CreateFileANextHook        : function (lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
  CreateFileWNextHook        : function (lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
  CloseHandleNextHook        : function (hObject: THandle): BOOL; stdcall;

  LoadLibraryANextHook       : function (lpLibFileName: PAnsiChar): HMODULE; stdcall;
  LoadLibraryWNextHook       : function (lpLibFileName: PWideChar): HMODULE; stdcall;

  LoadLibraryExANextHook     : function (lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
  LoadLibraryExWNextHook     : function (lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;

  GetProcAddressNextHook     : function (hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;


  ReadFileNextHook           : function (hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
  ReadFileExNextHook         : function (hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;

  _lreadNextHook             : function(hFile: HFILE; lpBuffer: Pointer; uBytes: UINT): UINT; stdcall;
  _lopenNextHook             : function (const lpPathName: LPCSTR; iReadWrite: Integer): HFILE; stdcall;
  _lcreatNextHook            : function (const lpPathName: LPCSTR; iAttribute: Integer): HFILE; stdcall;

  CreateFileMappingANextHook : function(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PAnsiChar): THandle; stdcall;
  CreateFileMappingWNextHook : function(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PWideChar): THandle; stdcall;

  MapViewOfFileNextHook      : function (hFileMappingObject: THandle; dwDesiredAccess: DWORD;
                                         dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer; stdcall;

  MapViewOfFileExNextHook    : function (hFileMappingObject: THandle; dwDesiredAccess,
                                         dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T; lpBaseAddress: Pointer): Pointer; stdcall;

  UnmapViewOfFileNextHook    : function (lpBaseAddress: Pointer): BOOL; stdcall;

  GetFileSizeNextHook        : function (hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall;
  GetFileSizeExNextHook      : function (hFile: THandle; var lpFileSize: Int64): BOOL; stdcall;

  FindFirstFileANextHook     : function (lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
  FindFirstFileWNextHook     : function (lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle; stdcall;


  GetFileAttributesExANextHook: function (lpFileName: PAnsiChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
  GetFileAttributesExWNextHook: function (lpFileName: PWideChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;


  DuplicateHandleNextHook    :  function (hSourceProcessHandle, hSourceHandle, hTargetProcessHandle: THandle;
                                          lpTargetHandle: PHandle; dwDesiredAccess: DWORD;
                                          bInheritHandle: BOOL; dwOptions: DWORD): BOOL; stdcall;


function GetFileSizeEx(hFile: THandle; var lpFileSize: Int64): BOOL; stdcall; external 'kernel32.dll';

var
  DefaultDll: string;

implementation


//hooks file opening
function CreateProcessACallbackProc(appName, cmdLine: pchar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pchar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;
begin
  Result := CreateProcessANextHook(appName, cmdLine, processAttr, threadAttr, inheritHandles, creationFlags, environment, currentDir, startupInfo, processInfo);
    //If explorer opens files like regedit or netstat - we can now auto inject our DLL into them hooking their API ;)!!!!
  //this will now keep injecting and recurring in every process which is ran through the created ones :)
  InjectDllToTarget(DefaultDll, processInfo.dwProcessId, @InjectedProc, 1000);
end;

//hooks file opening
function CreateProcessWCallbackProc(appName, cmdLine: pwidechar; processAttr, threadAttr: PSecurityAttributes; inheritHandles: bool; creationFlags: dword; environment: pointer; currentDir: pwidechar; const startupInfo: TStartupInfo; var processInfo: TProcessInformation) : bool; stdcall;
begin
  Result := CreateProcessWNextHook(appName, cmdLine, processAttr, threadAttr, inheritHandles, creationFlags, environment, currentDir, startupInfo, processInfo);
  //If explorer opens files like regedit or netstat - we can now auto inject our DLL into them hooking their API ;)!!!!
  //this will now keep injecting and recurring in every process which is ran through the created ones :)
  InjectDllToTarget(DefaultDll, processInfo.dwProcessId, @InjectedProc, 1000);
end;

function DuplicateHandleHookProc (hSourceProcessHandle, hSourceHandle, hTargetProcessHandle: THandle;
                                          lpTargetHandle: PHandle; dwDesiredAccess: DWORD;
                                          bInheritHandle: BOOL; dwOptions: DWORD): BOOL; stdcall;
begin
  if IsEncryptedHandle(hSourceHandle) then
     MessageBox(0, 'Функция: DuplicateHandleHookProc', '!!!', MB_OK or MB_ICONWARNING);

  Result := DuplicateHandleNextHook(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle, lpTargetHandle, dwDesiredAccess,
                                    bInheritHandle, dwOptions);
end;

function GetFileAttributesExAHookProc(lpFileName: PAnsiChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
var
  Attributes: ^WIN32_FILE_ATTRIBUTE_DATA;
  FileSize: Int64;
begin
  Result := GetFileAttributesExANextHook(lpFileName, fInfoLevelId, lpFileInformation);

  if fInfoLevelId = GetFileExInfoStandard then
  begin
    if ValidEnryptFileEx(string(AnsiString(lpFileName))) then
    begin
      Attributes := lpFileInformation;
      Int64Rec(FileSize).Lo := Attributes.nFileSizeLow;
      Int64Rec(FileSize).Hi := Attributes.nFileSizeHigh;
      FileSize := FileSize - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
      Attributes.nFileSizeLow := Int64Rec(FileSize).Lo;
      Attributes.nFileSizeHigh := Int64Rec(FileSize).Hi;
    end;
  end else
     MessageBox(0, 'Функция: GetFileAttributesExW', 'not GetFileExInfoStandard', MB_OK or MB_ICONWARNING);
end;

function GetFileAttributesExWHookProc(lpFileName: PWideChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
var
  Attributes: ^WIN32_FILE_ATTRIBUTE_DATA;
  FileSize: Int64;
begin
  Result := GetFileAttributesExWNextHook(lpFileName, fInfoLevelId, lpFileInformation);
  if fInfoLevelId = GetFileExInfoStandard then
  begin
    if ValidEnryptFileEx(lpFileName) then
    begin
      Attributes := lpFileInformation;
      Int64Rec(FileSize).Lo := Attributes.nFileSizeLow;
      Int64Rec(FileSize).Hi := Attributes.nFileSizeHigh;
      FileSize := FileSize - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
      Attributes.nFileSizeLow := Int64Rec(FileSize).Lo;
      Attributes.nFileSizeHigh := Int64Rec(FileSize).Hi;
    end;
  end else
     MessageBox(0, 'Функция: GetFileAttributesExW', 'not GetFileExInfoStandard', MB_OK or MB_ICONWARNING);
end;

function FindFirstFileAHookProc(lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
var
  FileSize: Int64;
begin
  Result := FindFirstFileANextHook(lpFileName, lpFindFileData);

  if ValidEnryptFileEx(string(AnsiString(lpFileName))) then
  begin
    Int64Rec(FileSize).Lo := lpFindFileData.nFileSizeLow;
    Int64Rec(FileSize).Hi := lpFindFileData.nFileSizeHigh;
    FileSize := FileSize - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
    lpFindFileData.nFileSizeLow := Int64Rec(FileSize).Lo;
    lpFindFileData.nFileSizeHigh := Int64Rec(FileSize).Hi;
  end;
end;

function FindFirstFileWHookProc(lpFileName: PWideChar; var lpFindFileData: TWIN32FindDataW): THandle; stdcall;
var
  FileSize: Int64;
begin
  Result := FindFirstFileWNextHook(lpFileName, lpFindFileData);

  if ValidEnryptFileEx(lpFileName) then
  begin
    Int64Rec(FileSize).Lo := lpFindFileData.nFileSizeLow;
    Int64Rec(FileSize).Hi := lpFindFileData.nFileSizeHigh;
    FileSize := FileSize - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
    lpFindFileData.nFileSizeLow := Int64Rec(FileSize).Lo;
    lpFindFileData.nFileSizeHigh := Int64Rec(FileSize).Hi;
  end;
end;

function GetFileSizeHookProc(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; stdcall;
begin
  Result := GetFileSizeNextHook(hFile, lpFileSizeHigh);
  if IsEncryptedHandle(hFile) then
    Result := Result - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
end;

function GetFileSizeExHookProc(hFile: THandle; var lpFileSize: Int64): BOOL; stdcall;
begin
  Result := GetFileSizeExNextHook(hFile, lpFileSize);
  if IsEncryptedHandle(hFile) then
    lpFileSize := lpFileSize - SizeOf(TEncryptedFileHeader) - SizeOf(TEncryptFileHeaderExV1);
end;

function CreateFileMappingAHookProc(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PAnsiChar): THandle; stdcall;
begin
  Result := CreateFileMappingANextHook(hFile, lpFileMappingAttributes, flProtect, dwMaximumSizeHigh, dwMaximumSizeLow, lpName);
  if IsEncryptedHandle(hFile) then
    AddFileMapping(hFile, Result);
end;

function CreateFileMappingWHookProc(hFile: THandle; lpFileMappingAttributes: PSecurityAttributes;
                                        flProtect, dwMaximumSizeHigh, dwMaximumSizeLow: DWORD; lpName: PWideChar): THandle; stdcall;
begin
  Result := CreateFileMappingWNextHook(hFile, lpFileMappingAttributes, flProtect, dwMaximumSizeHigh, dwMaximumSizeLow, lpName);
  if IsEncryptedHandle(hFile) then
    AddFileMapping(hFile, Result);
end;

function MapViewOfFileHookProc(hFileMappingObject: THandle; dwDesiredAccess: DWORD;
                                dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T): Pointer; stdcall;
begin
  if IsInternalFileMapping(hFileMappingObject) then
  begin
    Result := GetInternalFileMapping(hFileMappingObject, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap);
    Exit;
  end;

  Result := MapViewOfFileNextHook(hFileMappingObject, dwDesiredAccess, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap);
end;

function UnmapViewOfFileHookProc(lpBaseAddress: Pointer): BOOL; stdcall;
begin
  //TODO: free block
  Result := UnmapViewOfFileNextHook(lpBaseAddress);
end;

function MapViewOfFileExHookProc(hFileMappingObject: THandle; dwDesiredAccess: DWORD;
                                dwFileOffsetHigh, dwFileOffsetLow: DWORD; dwNumberOfBytesToMap: SIZE_T; lpBaseAddress: Pointer): Pointer; stdcall;
begin
  if lpBaseAddress = nil then
    Exit(MapViewOfFileHookProc(hFileMappingObject, dwDesiredAccess, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap));

  MessageBox(0, 'Функция: MapViewOfFileExHookProc', 'Позволить ?', MB_OK or MB_ICONWARNING);

  Result := MapViewOfFileNextHook(hFileMappingObject, dwDesiredAccess, dwFileOffsetHigh, dwFileOffsetLow, dwNumberOfBytesToMap);
end;

function  _lopenHookProc(const lpPathName: LPCSTR; iReadWrite: Integer): HFILE; stdcall;
begin
 if MessageBox(0, 'Функция: _lopen', 'Позволить ?', MB_YESNO or MB_ICONQUESTION) = IDYES then
    result := _lopenNextHook( lpPathName,iReadWrite)
  else
    result := 0;
end;

function _lreadHookProc(hFile: HFILE; lpBuffer: Pointer; uBytes: UINT): HFILE; stdcall;
begin
 if MessageBox(0, 'Функция: _lread', 'Позволить ?', MB_YESNO or MB_ICONQUESTION) = IDYES then
    result := _lreadNextHook( hFile,lpBuffer,uBytes)
  else
    result := 0;
end;

function _lcreatHookProc(const lpPathName: LPCSTR; iAttribute: Integer): HFILE; stdcall;
begin
 if MessageBox(0, 'Функция: _lread', 'Позволить ?', MB_YESNO or MB_ICONQUESTION) = IDYES then
    result := _lcreatNextHook(lpPathName, iAttribute)
  else
    result := 0;
end;

function GetModuleName(hModule: HMODULE): string;
var
  szFileName: array[0..MAX_PATH] of Char;
begin
  FillChar(szFileName, SizeOf(szFileName), #0);
  GetModuleFileName(hModule, szFileName, MAX_PATH);
  Result := szFileName;
end;

function IsSystemDll(dllName: string): Boolean;
begin
   Result := True;

{ dllName := AnsiLowerCase(ExtractFileName(dllName));

  if dllName = 'kernel32.dll' then Exit(True);
  if dllName = 'comctl32.dll' then Exit(True);
  if dllName = 'shell32.dll' then Exit(True);
  if dllName = 'winmm.dll' then Exit(True);
  if dllName = 'psapi.dll' then Exit(True);
  if dllName = 'uxtheme.dll' then Exit(True);
  if dllName = 'user32.dll' then Exit(True);
  if dllName = 'dwmapi.dll' then Exit(True);
  if dllName = 'ntdll.dll' then Exit(True);
  if dllName = 'comctl32.dll' then Exit(True);
  if dllName = 'ole32.dll' then Exit(True);

  Result := False;        }
end;

var
  WasHook: Boolean = false;

procedure ProcessDllLoad(Module: HModule; lpLibFileName: string);
begin
  if (Module > 0) and not IsSystemDll(lpLibFileName) then
    HookPEModule(Module, True);
end;

function LoadLibraryExAHookProc(lpLibFileName: PAnsiChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
begin
  Result := LoadLibraryExANextHook(lpLibFileName, hFile, dwFlags);
  ProcessDllLoad(Result, string(AnsiString(lpLibFileName)));
end;

function LoadLibraryExWHookProc(lpLibFileName: PWideChar; hFile: THandle; dwFlags: DWORD): HMODULE; stdcall;
begin
  Result := LoadLibraryExWNextHook(lpLibFileName, hFile, dwFlags);
  ProcessDllLoad(Result, lpLibFileName);
end;

function LoadLibraryWHookProc(lpLibFileName: PWideChar): HMODULE; stdcall;
begin
  Result := LoadLibraryWNextHook(lpLibFileName);
  ProcessDllLoad(Result, lpLibFileName);
end;

function LoadLibraryAHookProc(lpLibFileName: PAnsiChar): HMODULE; stdcall;
begin
  Result := LoadLibraryANextHook(lpLibFileName);
  ProcessDllLoad(Result, string(AnsiString(lpLibFileName)));
end;

procedure HookPEModule(Module: HModule; Recursive: Boolean = True);
begin
  HookCode(Module, Recursive,   @CreateProcessA,     @CreateProcessACallbackProc, @CreateProcessANextHook);
  HookCode(Module, Recursive,   @CreateProcessW,     @CreateProcessWCallbackProc, @CreateProcessWNextHook);

  hookCode(Module, Recursive,   @LoadLibraryA,       @LoadLibraryAHookProc, @LoadLibraryANextHook);
  hookCode(Module, Recursive,   @LoadLibraryW,       @LoadLibraryWHookProc, @LoadLibraryWNextHook);

  hookCode(Module, Recursive,   @LoadLibraryExA,     @LoadLibraryExAHookProc, @LoadLibraryExANextHook);
  hookCode(Module, Recursive,   @LoadLibraryExW,     @LoadLibraryExWHookProc, @LoadLibraryExWNextHook);

  hookCode(Module, Recursive,   @GetProcAddress,     @GetProcAddressHookProc, @GetProcAddressNextHook);

  hookCode(Module, Recursive,   @GetFileSize,        @GetFileSizeHookProc, @GetFileSizeNextHook);
  hookCode(Module, Recursive,   @GetFileSizeEx,      @GetFileSizeExHookProc, @GetFileSizeExNextHook);

  hookCode(Module, Recursive,   @FindFirstFileA,     @FindFirstFileAHookProc, @FindFirstFileANextHook);
  hookCode(Module, Recursive,   @FindFirstFileW,     @FindFirstFileWHookProc, @FindFirstFileWNextHook);

  hookCode(Module, Recursive,   @GetFileAttributesExA, @GetFileAttributesExAHookProc, @GetFileAttributesExANextHook);
  hookCode(Module, Recursive,   @GetFileAttributesExW, @GetFileAttributesExWHookProc, @GetFileAttributesExWNextHook);

  hookCode(Module, Recursive,   @DuplicateHandle,    @DuplicateHandleHookProc, @DuplicateHandleNextHook);

  hookCode(Module, Recursive,   @OpenFile,           @OpenFileAHookProc, @OpenFileNextHook);

  hookCode(Module, Recursive,   @CreateFileA,        @CreateFileAHookProc, @CreateFileANextHook);
  hookCode(Module, Recursive,   @CreateFileW,        @CreateFileWHookProc, @CreateFileWNextHook);

  hookCode(Module, Recursive,   @SetFilePointerEx,   @SetFilePointerExHookProc, @SetFilePointerExNextHook);
  hookCode(Module, Recursive,   @SetFilePointer,     @SetFilePointerHookProc, @SetFilePointerNextHook);

  hookCode(Module, Recursive,   @_lopen,             @_lopenHookProc, @_lopenNextHook);
  hookCode(Module, Recursive,   @_lread,             @_lreadHookProc, @_lreadNextHook);
  hookCode(Module, Recursive,   @_lcreat,            @_lcreatHookProc, @_lcreatNextHook);

  hookCode(Module, Recursive,   @ReadFile,           @ReadFileHookProc, @ReadFileNextHook);
  hookCode(Module, Recursive,   @ReadFileEx,         @ReadFileExHookProc, @ReadFileExNextHook);

  hookCode(Module, Recursive,   @CloseHandle,        @CloseHandleHookProc, @CloseHandleNextHook);

  hookCode(Module, Recursive,   @CreateFileMappingA, @CreateFileMappingAHookProc, @CreateFileMappingANextHook);
  hookCode(Module, Recursive,   @CreateFileMappingW, @CreateFileMappingWHookProc, @CreateFileMappingWNextHook);

  hookCode(Module, Recursive,   @MapViewOfFile,      @MapViewOfFileHookProc, @MapViewOfFileNextHook);
  hookCode(Module, Recursive,   @MapViewOfFileEx,    @MapViewOfFileExHookProc, @MapViewOfFileExNextHook);

  hookCode(Module, Recursive,   @UnmapViewOfFile,    @UnmapViewOfFileHookProc, @UnmapViewOfFileNextHook);
end;

procedure FixProcAddress(hModule: HMODULE; lpProcName: LPCSTR; var proc: FARPROC);
var
  Module, ProcName: string;
begin
  if ULONG_PTR(lpProcName) shr 16 = 0 then
    Exit;
  Module := AnsiLowerCase(ExtractFileName(GetModuleName(hModule)));
  ProcName := AnsiLowerCase(string(AnsiString(lpProcName)));

  if (Module = 'kernel32.dll') then
  begin
    if ProcName = AnsiLowerCase('_lopen') then
      proc :=  @_lopenHookProc;
    if ProcName = AnsiLowerCase('_lread') then
      proc :=  @_lreadHookProc;
    if ProcName = AnsiLowerCase('_lcreat') then
      proc :=  @_lcreatHookProc;

    if ProcName = AnsiLowerCase('LoadLibraryA') then
      proc :=  @LoadLibraryAHookProc;
    if ProcName = AnsiLowerCase('LoadLibraryW') then
      proc :=  @LoadLibraryWHookProc;
    if ProcName = AnsiLowerCase('LoadLibraryExA') then
      proc :=  @LoadLibraryExAHookProc;
    if ProcName = AnsiLowerCase('LoadLibraryExW') then
      proc :=  @LoadLibraryExWHookProc;

    if ProcName = AnsiLowerCase('GetProcAddress') then
      proc :=  @GetProcAddressHookProc;

    if ProcName = AnsiLowerCase('FindFirstFileA') then
      proc :=  @FindFirstFileAHookProc;
    if ProcName = AnsiLowerCase('FindFirstFileW') then
      proc :=  @FindFirstFileWHookProc;

    if ProcName = AnsiLowerCase('GetFileAttributesExA') then
      proc :=  @GetFileAttributesExAHookProc;
    if ProcName = AnsiLowerCase('GetFileAttributesExW') then
      proc :=  @GetFileAttributesExWHookProc;

    if ProcName = AnsiLowerCase('GetFileSize') then
      proc := @GetFileSizeHookProc;
    if ProcName = AnsiLowerCase('GetFileSizeEx') then
      proc := @GetFileSizeExHookProc;

    if ProcName = AnsiLowerCase('DuplicateHandle') then
      proc :=  @DuplicateHandleHookProc;

    if ProcName = AnsiLowerCase('CreateFileMappingA') then
      proc := @CreateFileMappingAHookProc;
    if ProcName = AnsiLowerCase('CreateFileMappingW') then
      proc := @CreateFileMappingWHookProc;
    if ProcName = AnsiLowerCase('MapViewOfFile') then
      proc := @MapViewOfFileHookProc;
    if ProcName = AnsiLowerCase('MapViewOfFileEx') then
      proc := @MapViewOfFileExHookProc;
    if ProcName = AnsiLowerCase('UnmapViewOfFile') then
      proc := @UnmapViewOfFileHookProc;

    if ProcName = AnsiLowerCase('OpenFile') then
      proc := @OpenFileAHookProc;
    if ProcName = AnsiLowerCase('CreateFileA') then
      proc := @CreateFileAHookProc;
    if ProcName = AnsiLowerCase('CreateFileW') then
      proc := @CreateFileWHookProc;

    if ProcName = AnsiLowerCase('SetFilePointer') then
      proc := @SetFilePointerHookProc;
    if ProcName = AnsiLowerCase('SetFilePointerEx') then
      proc := @SetFilePointerExHookProc;

    if ProcName = AnsiLowerCase('ReadFile') then
      proc := @ReadFileHookProc;
    if ProcName = AnsiLowerCase('ReadFileEx') then
      proc := @ReadFileExHookProc;

    if ProcName = AnsiLowerCase('CloseHandle') then
      proc := @CloseHandleHookProc;
  end;
end;

function GetProcAddressHookProc(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
begin
  Result := GetProcAddressNextHook(hModule, lpProcName);
  FixProcAddress(hModule, lpProcName, Result);
end;

function OpenFileAHookProc(const lpFileName: LPCSTR; var lpReOpenBuff: TOFStruct; uStyle: UINT): HFILE; stdcall;
begin
  Result := OpenFileNextHook(lpFileName, lpReOpenBuff, uStyle);

  if ValidEnryptFileEx(string(AnsiString(lpFileName))) then
    InitEncryptedFile(string(AnsiString(lpFileName)), Result);
end;

function CreateFileAHookProc(lpFileName: PAnsiChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
begin
  Result := CreateFileANextHook( lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile );

  if ValidEnryptFileEx(string(AnsiString(lpFileName))) then
    InitEncryptedFile(string(AnsiString(lpFileName)), Result);
end;

function CreateFileWHookProc(lpFileName: PWideChar; dwDesiredAccess, dwShareMode: DWORD;
                                         lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
                                         hTemplateFile: THandle): THandle; stdcall;
begin
  Result := CreateFileWNextHook( lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile );

  if ValidEnryptFileEx(lpFileName) then
    InitEncryptedFile(lpFileName, Result);
end;

function SetFilePointerHookProc(hFile: THandle; lDistanceToMove: Longint; lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
begin
  Result := FixFileSize(hFile, lDistanceToMove, lpDistanceToMoveHigh, dwMoveMethod, SetFilePointerNextHook);
end;

function SetFilePointerExHookProc(hFile: THandle; liDistanceToMove: TLargeInteger; const lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL; stdcall;
begin
  Result := FixFileSizeEx(hFile, liDistanceToMove, lpNewFilePointer, dwMoveMethod, SetFilePointerExNextHook);
end;

function ReadFileHookProc(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD; var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
var
  dwCurrentFilePosition: Int64;
begin
  dwCurrentFilePosition := FileSeek(hFile, 0, FILE_CURRENT);

  Result := ReadFileNextHook( hFile, Buffer, nNumberOfBytesToRead, lpNumberOfBytesRead, lpOverlapped );

  ReplaceBufferContent(hFile, Buffer, dwCurrentFilePosition, nNumberOfBytesToRead, lpNumberOfBytesRead);
end;

function ReadFileExHookProc(hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;
begin
 if MessageBox(0, 'Функция: ReadFileEx', 'Позволить ?', MB_YESNO or MB_ICONQUESTION) = IDYES then
    result := ReadFileExNextHook(hFile, lpBuffer, nNumberOfBytesToRead, lpOverlapped, lpCompletionRoutine)
  else
    result := FALSE;
end;

function CloseHandleHookProc(hObject: THandle): BOOL; stdcall;
begin
  Result := CloseHandleNextHook(hObject);
  CloseFileHandle(hObject);
end;

end.
