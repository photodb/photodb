program DBShell;

const
  MAX_PATH = 260;

type   

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

  DWORD = LongWord;
  TBooleanFunction = function : Boolean;

  _STARTUPINFOA = record
    cb: DWORD;
    lpReserved: Pointer;
    lpDesktop: Pointer;
    lpTitle: Pointer;
    dwX: DWORD;
    dwY: DWORD;
    dwXSize: DWORD;
    dwYSize: DWORD;
    dwXCountChars: DWORD;
    dwYCountChars: DWORD;
    dwFillAttribute: DWORD;
    dwFlags: DWORD;
    wShowWindow: Word;
    cbReserved2: Word;
    lpReserved2: PByte;
    hStdInput: THandle;
    hStdOutput: THandle;
    hStdError: THandle;
  end;
  LPCSTR = PAnsiChar;
  TStartupInfo = _STARTUPINFOA;
  FARPROC = Pointer;
  _PROCESS_INFORMATION = record
    hProcess: THandle;
    hThread: THandle;
    dwProcessId: DWORD;
    dwThreadId: DWORD;
  end;
  BOOL = LongBool;
  UINT = LongWord;
  TProcessInformation = _PROCESS_INFORMATION;
  HWND = type LongWord;

  _SECURITY_ATTRIBUTES = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;

  TSecurityAttributes = _SECURITY_ATTRIBUTES;

  PSecurityAttributes = ^TSecurityAttributes;

   _FILETIME = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
  {$EXTERNALSYM _FILETIME}
  TFileTime = _FILETIME;

  type
  _FINDEX_INFO_LEVELS = (FindExInfoStandard, FindExInfoMaxInfoLevel);
  {$EXTERNALSYM _FINDEX_INFO_LEVELS}
  TFindexInfoLevels = _FINDEX_INFO_LEVELS;

  _FINDEX_SEARCH_OPS = (FindExSearchNameMatch, FindExSearchLimitToDirectories,
  {$EXTERNALSYM _FINDEX_SEARCH_OPS}
  FindExSearchLimitToDevices, FindExSearchMaxSearchOp);
  TFindexSearchOps = _FINDEX_SEARCH_OPS;

   _WIN32_FIND_DATAA = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..MAX_PATH - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
  end;

  TWin32FindDataA = _WIN32_FIND_DATAA;

  TWin32FindData = TWin32FindDataA;

  LongRec = packed record
    case Integer of
      0: (Lo, Hi: Word);
      1: (Words: array [0..1] of Word);
      2: (Bytes: array [0..3] of Byte);
  end;

  HKEY = type LongWord;

  PDWORD = ^DWORD;

  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;

  ACCESS_MASK = DWORD;
  type
  {$EXTERNALSYM REGSAM}
  REGSAM = ACCESS_MASK;

  const HKEY_CURRENT_USER     = DWORD($80000001);  
        HKEY_LOCAL_MACHINE    = DWORD($80000002);
        MB_OK = $00000000;
        MB_ICONHAND = $00000010;
        MB_ICONERROR                   = MB_ICONHAND;
        SW_SHOWNORMAL = 1;
        CREATE_DEFAULT_ERROR_MODE       = $04000000;
        INVALID_HANDLE_VALUE = DWORD(-1);
        kernel32 = 'kernel32.dll';
        FILE_ATTRIBUTE_DIRECTORY            = $00000010;
        REG_SZ                      = 1;
        advapi32  = 'advapi32.dll';
        ERROR_SUCCESS = 0;
        REG_NONE                    = 0;
        STANDARD_RIGHTS_ALL      = $001F0000;

   KEY_QUERY_VALUE    = $0001;
  {$EXTERNALSYM KEY_QUERY_VALUE}
  KEY_SET_VALUE      = $0002;
  {$EXTERNALSYM KEY_SET_VALUE}
  KEY_CREATE_SUB_KEY = $0004;
  {$EXTERNALSYM KEY_CREATE_SUB_KEY}
  KEY_ENUMERATE_SUB_KEYS = $0008;
  {$EXTERNALSYM KEY_ENUMERATE_SUB_KEYS}
  KEY_NOTIFY         = $0010;
  {$EXTERNALSYM KEY_NOTIFY}
  KEY_CREATE_LINK    = $0020;
  {$EXTERNALSYM KEY_CREATE_LINK}

   SYNCHRONIZE = $00100000;

  _DELETE                  = $00010000; { Renamed from DELETE }
  READ_CONTROL             = $00020000;
  STANDARD_RIGHTS_READ     = READ_CONTROL;
  {$EXTERNALSYM STANDARD_RIGHTS_READ}

  //READING ONLY!!!
{  KEY_ALL_ACCESS     = (STANDARD_RIGHTS_ALL or
                        KEY_QUERY_VALUE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY or
                        KEY_CREATE_LINK) and not
                        SYNCHRONIZE; }

  KEY_READ           = (STANDARD_RIGHTS_READ or
                        KEY_QUERY_VALUE or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY) and not
                        SYNCHRONIZE;
var
//  freg : TRegistry;
  s : String;
  si : Tstartupinfo;
  p  : Tprocessinformation;

const
  RegRoot : string = 'Software\Photo DataBase\';
  RegRootW : string = 'Software\Photo DataBase';

  function LoadLibrary(lpLibFileName: PChar): HMODULE; stdcall;   external kernel32 name 'LoadLibraryA'; //stdcall;
  function GetProcAddress(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;   external 'kernel32.dll' name 'GetProcAddress';
  function FreeLibrary(hLibModule: HMODULE): BOOL; stdcall; external kernel32 name 'FreeLibrary';
  function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall; external 'user32.dll' name 'MessageBoxA';

function CreateProcess(lpApplicationName: PChar; lpCommandLine: PChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;  external kernel32 name 'CreateProcessA';

function FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle; stdcall; external kernel32 name 'FindFirstFileA';
function FindClose(hFindFile: THandle): BOOL; stdcall; external kernel32 name 'FindClose';

function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL; stdcall; external kernel32 name 'FileTimeToLocalFileTime';
function FileTimeToDosDateTime(const lpFileTime: TFileTime;
  var lpFatDate, lpFatTime: Word): BOOL; stdcall; external kernel32 name 'FileTimeToDosDateTime';


function RegQueryValueEx(hKey: HKEY; lpValueName: PChar;
  lpReserved: Pointer; lpType: PDWORD; lpData: PByte; lpcbData: PDWORD): Longint; stdcall; external advapi32 name 'RegQueryValueExA';

function RegOpenKeyEx(hKey: HKEY; lpSubKey: PChar;
  ulOptions: DWORD; samDesired: REGSAM; var phkResult: HKEY): Longint; stdcall; external advapi32 name 'RegOpenKeyExA';

function RegCloseKey(hKey: HKEY): Longint; stdcall; external advapi32 name 'RegCloseKey';

{$R *.res}

function FileAge(const FileName: string): Integer;
var
  Handle: THandle;
  FindData: TWin32FindData;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
        LongRec(Result).Lo) then Exit;
    end;
  end;
  Result := -1;
end;

function FileExists(const FileName: string): Boolean;
begin
  Result := FileAge(FileName) <> -1;
end;

function getdirectory(filename:string):string;
var
  i, n : integer;
begin
 n:=0;
 for i:=length(filename) downto 1 do
 If filename[i]='\' then
 begin
  n:=i;
  break;
 end;
 delete(filename,n,length(filename)-n+1);
 result:=filename;
end;

function StrLen(const Str: PChar): Cardinal; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        MOV     EAX,0FFFFFFFEH
        SUB     EAX,ECX
        MOV     EDI,EDX
end;


function OpenKey(Key: HKEY; S: string; Cancreate: boolean): HKEY;
var
FAccess: LongWord;
begin

 FAccess:=KEY_READ;

    RegOpenKeyEx(Key, PChar(S), 0,
      FAccess, Result);
end;


function DataTypeToRegData(Value: Integer): TRegDataType;
begin
  if Value = REG_SZ then Result := rdString  else
  Result := rdUnknown;
end;

function GetDataInfo(CurrentKey : HKEY; const ValueName: string; var Value: TRegDataInfo): Boolean;
var
  DataType: Integer;
begin
  FillChar(Value, SizeOf(TRegDataInfo), 0);
  Result := RegQueryValueEx(CurrentKey, PChar(ValueName), nil, @DataType, nil,
    @Value.DataSize) = ERROR_SUCCESS;
  Value.RegData := DataTypeToRegData(DataType);
end;

function GetDataSize(key : HKEY; const ValueName: string): Integer;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(key, ValueName, Info) then
    Result := Info.DataSize else
    Result := -1;
end;

function GetData(key : HKEY; const Name: string; Buffer: Pointer;
  BufSize: Integer; var RegData: TRegDataType): Integer;
var
  DataType: Integer;
begin
  DataType := REG_NONE;
  if RegQueryValueEx(key, PChar(Name), nil, @DataType, PByte(Buffer),
    @BufSize) <> ERROR_SUCCESS then ;

  Result := BufSize;
  RegData := DataTypeToRegData(DataType);
end;

function ReadString(key : HKEY; const Name: string): string;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetDataSize(key, Name);
  if Len > 0 then
  begin
    SetString(Result, nil, Len);
    GetData(key, Name, PChar(Result), Len, RegData);
    if (RegData = rdString) or (RegData = rdExpandString) then
      SetLength(Result, StrLen(PChar(Result)));
  end
  else Result := '';
end;

function ReadStringW(key : HKEY; Path : String; const Name: string): string;
var k : HKEY;
begin
 k:=OpenKey(key,Path,false);
 result:=ReadString(k,Name);
 RegCloseKey(k)
end;

Function IsInstalledApplication : Boolean;
var
  f : TBooleanFunction;
  h: Thandle;
  ProcH : pointer;
begin
 Result:=false;
 try
  If FileExists(ReadStringW(HKEY_LOCAL_MACHINE,RegRootW,'DataBase')) then
  begin
   h:=LoadLibrary(PChar(ReadStringW(HKEY_LOCAL_MACHINE,RegRootW,'DataBase')));
   If h<>0 then
   begin
    ProcH:=GetProcAddress(h,'IsFalidDBFile');
    If ProcH<>nil then
    begin
     @f:=ProcH;
     If f then
     if FileExists(GetDirectory(ReadStringW(HKEY_LOCAL_MACHINE,RegRootW,'DataBase'))+'\kernel.dll') then
     result:=true;
    end;
   FreeLibrary(h);
   end;
  end;
  except
 end;
end;

begin
 If not IsInstalledApplication then
 MessageBox(0,'Application is not installed!','Warning',mb_ok+mb_iconerror) else
 begin
   try
    s:=ReadStringW(HKEY_LOCAL_MACHINE,RegRootW,'DataBase');
    If fileexists(s) then
    begin
     FillChar( Si, SizeOf( Si ) , 0 );
     with Si do
     begin
      cb := SizeOf( Si);
      dwFlags := 1;
      wShowWindow := SW_SHOWNORMAL;
     end;
     Createprocess(nil,pchar('"'+s+'" "'+ParamStr(1)+'" "'+ParamStr(2)+'"'),nil,nil,false,Create_default_error_mode,nil,pchar(getdirectory(s)),si,p);
    end;
   except
   end;
 end;

end.
