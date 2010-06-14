unit SystemUnit;

{ TStream abstract class }
interface

type
  POSVersionInfoA = ^TOSVersionInfoA;
  POSVersionInfoW = ^TOSVersionInfoW;
  POSVersionInfo = POSVersionInfoA;
  _OSVERSIONINFOA = record
    dwOSVersionInfoSize: LongWord;
    dwMajorVersion: LongWord;
    dwMinorVersion: LongWord;
    dwBuildNumber: LongWord;
    dwPlatformId: LongWord;
    szCSDVersion: array[0..127] of AnsiChar; { Maintenance string for PSS usage }
  end;
  {$EXTERNALSYM _OSVERSIONINFOA}
  _OSVERSIONINFOW = record
    dwOSVersionInfoSize: LongWord;
    dwMajorVersion: LongWord;
    dwMinorVersion: LongWord;
    dwBuildNumber: LongWord;
    dwPlatformId: LongWord;
    szCSDVersion: array[0..127] of WideChar; { Maintenance string for PSS usage }
  end;
  {$EXTERNALSYM _OSVERSIONINFOW}
  _OSVERSIONINFO = _OSVERSIONINFOA;
  TOSVersionInfoA = _OSVERSIONINFOA;
  TOSVersionInfoW = _OSVERSIONINFOW;
  TOSVersionInfo = TOSVersionInfoA;
  OSVERSIONINFOA = _OSVERSIONINFOA;
  {$EXTERNALSYM OSVERSIONINFOA}
  {$EXTERNALSYM OSVERSIONINFO}
  OSVERSIONINFOW = _OSVERSIONINFOW;
  {$EXTERNALSYM OSVERSIONINFOW}
  {$EXTERNALSYM OSVERSIONINFO}
  OSVERSIONINFO = OSVERSIONINFOA;

type

  DWORD = LongWord;

{ dwPlatformId defines }
var

    Win32Platform: Integer = 0;

  Win32MajorVersion: Integer = 0;
  Win32MinorVersion: Integer = 0;
  Win32BuildNumber: Integer = 0;
  Win32CSDVersion: string = '';
const
  VER_PLATFORM_WIN32s = 0;
  {$EXTERNALSYM VER_PLATFORM_WIN32s}
  VER_PLATFORM_WIN32_WINDOWS = 1;
  {$EXTERNALSYM VER_PLATFORM_WIN32_WINDOWS}
  VER_PLATFORM_WIN32_NT = 2;
  {$EXTERNALSYM VER_PLATFORM_WIN32_NT}


  {$EXTERNALSYM HKEY_CLASSES_ROOT}
  HKEY_CLASSES_ROOT     = DWORD($80000000);
  {$EXTERNALSYM HKEY_CURRENT_USER}
  HKEY_CURRENT_USER     = DWORD($80000001);
  {$EXTERNALSYM HKEY_LOCAL_MACHINE}
  HKEY_LOCAL_MACHINE    = DWORD($80000002);

const
  MAX_PATH = 260;

type

  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

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

  const         MB_OK = $00000000;
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
  _DELETE                  = $00010000; { Renamed from DELETE }
  READ_CONTROL             = $00020000;
  STANDARD_RIGHTS_READ     = READ_CONTROL;

   SYNCHRONIZE = $00100000;

   //READING ONLY!!!
{  KEY_ALL_ACCESS     = (STANDARD_RIGHTS_ALL or
                        KEY_QUERY_VALUE or
                        KEY_SET_VALUE or
                        KEY_CREATE_SUB_KEY or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY or
                        KEY_CREATE_LINK) and not
                        SYNCHRONIZE;    }

  KEY_READ           = (STANDARD_RIGHTS_READ or
                        KEY_QUERY_VALUE or
                        KEY_ENUMERATE_SUB_KEYS or
                        KEY_NOTIFY) and not
                        SYNCHRONIZE;

  const

{line 2250}
  FILE_SHARE_READ                     = $00000001;
  {$EXTERNALSYM FILE_SHARE_READ}
  FILE_SHARE_WRITE                    = $00000002;
  {$EXTERNALSYM FILE_SHARE_WRITE}
  FILE_SHARE_DELETE                   = $00000004;
  {$EXTERNALSYM FILE_SHARE_DELETE}
  FILE_ATTRIBUTE_READONLY             = $00000001;
  {$EXTERNALSYM FILE_ATTRIBUTE_READONLY}
  FILE_ATTRIBUTE_HIDDEN               = $00000002;
  {$EXTERNALSYM FILE_ATTRIBUTE_HIDDEN}
  FILE_ATTRIBUTE_SYSTEM               = $00000004;
  {$EXTERNALSYM FILE_ATTRIBUTE_SYSTEM}
  {$EXTERNALSYM FILE_ATTRIBUTE_DIRECTORY}
  FILE_ATTRIBUTE_ARCHIVE              = $00000020;
  {$EXTERNALSYM FILE_ATTRIBUTE_ARCHIVE}
  FILE_ATTRIBUTE_NORMAL               = $00000080;
  {$EXTERNALSYM FILE_ATTRIBUTE_NORMAL}
  FILE_ATTRIBUTE_TEMPORARY            = $00000100;
  {$EXTERNALSYM FILE_ATTRIBUTE_TEMPORARY}
  FILE_ATTRIBUTE_COMPRESSED           = $00000800;
  {$EXTERNALSYM FILE_ATTRIBUTE_COMPRESSED}
  FILE_ATTRIBUTE_OFFLINE              = $00001000;
  {$EXTERNALSYM FILE_ATTRIBUTE_OFFLINE}
  FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_FILE_NAME}
  FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_DIR_NAME}
  FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_ATTRIBUTES}
  FILE_NOTIFY_CHANGE_SIZE             = $00000008;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_SIZE}
  FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_LAST_WRITE}
  FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_LAST_ACCESS}
  FILE_NOTIFY_CHANGE_CREATION         = $00000040;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_CREATION}
  FILE_NOTIFY_CHANGE_SECURITY         = $00000100;
  {$EXTERNALSYM FILE_NOTIFY_CHANGE_SECURITY}
  FILE_ACTION_ADDED                   = $00000001;
  {$EXTERNALSYM FILE_ACTION_ADDED}
  FILE_ACTION_REMOVED                 = $00000002;
  {$EXTERNALSYM FILE_ACTION_REMOVED}
  FILE_ACTION_MODIFIED                = $00000003;
  {$EXTERNALSYM FILE_ACTION_MODIFIED}
  FILE_ACTION_RENAMED_OLD_NAME        = $00000004;
  {$EXTERNALSYM FILE_ACTION_RENAMED_OLD_NAME}
  FILE_ACTION_RENAMED_NEW_NAME        = $00000005;
  {$EXTERNALSYM FILE_ACTION_RENAMED_NEW_NAME}
  MAILSLOT_NO_MESSAGE                 = LongWord(-1);
  {$EXTERNALSYM MAILSLOT_NO_MESSAGE}
  MAILSLOT_WAIT_FOREVER               = LongWord(-1);
  {$EXTERNALSYM MAILSLOT_WAIT_FOREVER}
  FILE_CASE_SENSITIVE_SEARCH          = $00000001;
  {$EXTERNALSYM FILE_CASE_SENSITIVE_SEARCH}
  FILE_CASE_PRESERVED_NAMES           = $00000002;
  {$EXTERNALSYM FILE_CASE_PRESERVED_NAMES}
  FILE_UNICODE_ON_DISK                = $00000004;
  {$EXTERNALSYM FILE_UNICODE_ON_DISK}
  FILE_PERSISTENT_ACLS                = $00000008;
  {$EXTERNALSYM FILE_PERSISTENT_ACLS}
  FILE_FILE_COMPRESSION               = $00000010;
  {$EXTERNALSYM FILE_FILE_COMPRESSION}
  FILE_VOLUME_IS_COMPRESSED           = $00008000;
  {$EXTERNALSYM FILE_VOLUME_IS_COMPRESSED}


  CREATE_NEW = 1;
  {$EXTERNALSYM CREATE_NEW}
  CREATE_ALWAYS = 2;
  {$EXTERNALSYM CREATE_ALWAYS}
  OPEN_EXISTING = 3;
  {$EXTERNALSYM OPEN_EXISTING}
  OPEN_ALWAYS = 4;
  {$EXTERNALSYM OPEN_ALWAYS}
  TRUNCATE_EXISTING = 5;
  {$EXTERNALSYM TRUNCATE_EXISTING}

  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;

  fmShareCompat    = $0000 platform; // DOS compatibility mode is not portable
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030 platform; // write-only not supported on all platforms
  fmShareDenyNone  = $0040;

  GENERIC_READ             = LongWord($80000000);
  {$EXTERNALSYM GENERIC_READ}
  GENERIC_WRITE            = $40000000;
  {$EXTERNALSYM GENERIC_WRITE}
  GENERIC_EXECUTE          = $20000000;
  {$EXTERNALSYM GENERIC_EXECUTE}
  GENERIC_ALL              = $10000000;
  {$EXTERNALSYM GENERIC_ALL}

{ TFileStream create mode }

  fmCreate = $FFFF;

{ TParser special tokens }

  toEOF     = Char(0);
  toSymbol  = Char(1);
  toString  = Char(2);
  toInteger = Char(3);
  toFloat   = Char(4);
  toWString = Char(5);

  {!! Moved here from menus.pas !!}
  { TShortCut special values }

  scShift = $2000;
  scCtrl = $4000;
  scAlt = $8000;
  scNone = 0;

const
  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;

type
{ TStream seek origins }
  TSeekOrigin = (soBeginning, soCurrent, soEnd);

type
  POverlapped = ^TOverlapped;
  _OVERLAPPED = record
    Internal: LongWord;
    InternalHigh: LongWord;
    Offset: LongWord;
    OffsetHigh: LongWord;
    hEvent: THandle;
  end;
  {$EXTERNALSYM _OVERLAPPED}
  TOverlapped = _OVERLAPPED;
  OVERLAPPED = _OVERLAPPED;
  {$EXTERNALSYM OVERLAPPED}

type

  TStream = class(TObject)
  private
    function GetPosition: Int64;
    procedure SetPosition(const Pos: Int64);
    procedure SetSize64(const NewSize: Int64);
  protected
    function GetSize: Int64; virtual;
    procedure SetSize(NewSize: Longint); overload; virtual;
    procedure SetSize(const NewSize: Int64); overload; virtual;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
    function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
    function Seek(Offset: Longint; Origin: Word): Longint; overload; virtual;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; virtual;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: TStream; Count: Int64): Int64;
    procedure WriteResourceHeader(const ResName: string; out FixupInfo: Integer);
    procedure FixupResourceHeader(FixupInfo: Integer);
    procedure ReadResHeader;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize64;
  end;

{ TCustomMemoryStream abstract class }

  TCustomMemoryStream = class(TStream)
  private
    FMemory: Pointer;
    FSize, FPosition: Longint;
  protected
    procedure SetPointer(Ptr: Pointer; Size: Longint);
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
  end;


{ TMemoryStream }

  TMemoryStream = class(TCustomMemoryStream)
  private
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    function Realloc(var NewCapacity: Longint): Pointer; virtual;
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

{ THandleStream class }

  THandleStream = class(TStream)
  protected
    FHandle: Integer;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(AHandle: Integer);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Handle: Integer read FHandle;
  end;

{ TFileStream class }

  TFileStream = class(THandleStream)
  public
    constructor Create(const FileName: string; Mode: Word); overload;
    constructor Create(const FileName: string; Mode: Word; Rights: Cardinal); overload;
    destructor Destroy; override;
  end;

function FileCreate(const FileName: string): Integer; overload;
function FileCreate(const FileName: string; Rights: Integer): Integer; overload;

function GlobalHandle(Mem: Pointer): HGLOBAL; stdcall;  external kernel32 name 'GlobalHandle';
function GlobalUnlock(hMem: HGLOBAL): LongBool; stdcall; external kernel32 name 'GlobalUnlock';
function GlobalFree(hMem: HGLOBAL): HGLOBAL; stdcall; external kernel32 name 'GlobalFree';
function GlobalAlloc(uFlags: LongWord; dwBytes: LongWord): HGLOBAL; stdcall;  external kernel32 name 'GlobalAlloc';
function GlobalLock(hMem: HGLOBAL): Pointer; stdcall;  external kernel32 name 'GlobalLock';
function GlobalReAlloc(hMem: HGLOBAL; dwBytes: LongWord; uFlags: LongWord): HGLOBAL; stdcall; external kernel32 name 'GlobalReAlloc';
function ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: LongWord;
  var lpNumberOfBytesRead: LongWord; lpOverlapped: POverlapped): LongBool; stdcall; external kernel32 name 'ReadFile';
function WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: LongWord;
  var lpNumberOfBytesWritten: LongWord; lpOverlapped: POverlapped): LongBool; stdcall; external kernel32 name 'WriteFile';
function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: LongWord): LongWord; stdcall; external kernel32 name 'SetFilePointer';
function CreateFile(lpFileName: PChar; dwDesiredAccess, dwShareMode: LongWord;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: LongWord;
  hTemplateFile: THandle): THandle; stdcall; external kernel32 name 'CreateFileA';
function CloseHandle(hObject: THandle): LongBool; stdcall; external kernel32 name 'CloseHandle';
function GetVersionEx(var lpVersionInformation: TOSVersionInfo): LongBool; stdcall;  external kernel32 name 'GetVersionExA';

function DeviceIoControl(hDevice: THandle; dwIoControlCode: DWORD; lpInBuffer: Pointer;
  nInBufferSize: DWORD; lpOutBuffer: Pointer; nOutBufferSize: DWORD;
  var lpBytesReturned: DWORD; lpOverlapped: POverlapped): LongBool; stdcall; external kernel32 name 'DeviceIoControl';

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
function ReadStringW(key : HKEY; Path : String; const Name: string): string;
Function hextointdef(hex : string; default : integer) : integer;
function IntToHex(Value: Integer; Digits: Integer): string;
procedure InitPlatformId;
function IntToStr(Value: Integer): string;
function GetIdeDiskSerialNumber : String;

implementation

procedure InitPlatformId;
var
  OSVersionInfo: TOSVersionInfo;
begin
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
    with OSVersionInfo do
    begin
      Win32Platform := dwPlatformId;
      Win32MajorVersion := dwMajorVersion;
      Win32MinorVersion := dwMinorVersion;
      if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
        Win32BuildNumber := dwBuildNumber and $FFFF
      else
        Win32BuildNumber := dwBuildNumber;
      Win32CSDVersion := szCSDVersion;
    end;
end;

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

function GetDirectory(FileName:string):string;
var
  i, n : integer;
begin
 n:=1;
 for i:=length(FileName) downto 1 do
 If FileName[i]='\' then
 begin
  n:=i;
  break;
 end;
 Delete(FileName,n,length(FileName)-n+1);
 result:=FileName;
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

{ TStream }

function TStream.GetPosition: Int64;
begin
  Result := Seek(0, soCurrent);
end;

procedure TStream.SetPosition(const Pos: Int64);
begin
  Seek(Pos, soBeginning);
end;

function TStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

procedure TStream.SetSize(NewSize: Longint);
begin
  // default = do nothing  (read-only streams, etc)
  // descendents should implement this method to call the Int64 sibling
end;

procedure TStream.SetSize64(const NewSize: Int64);
begin
  SetSize(NewSize);
end;

procedure TStream.SetSize(const NewSize: Int64);
begin
{ For compatibility with old stream implementations, this new 64 bit SetSize
  calls the old 32 bit SetSize.  Descendent classes that override this
  64 bit SetSize MUST NOT call inherited. Descendent classes that implement
  64 bit SetSize should reimplement their 32 bit SetSize to call their 64 bit
  version.}
//  if (NewSize < Low(Longint)) or (NewSize > High(Longint)) then

  SetSize(Longint(NewSize));
end;

function TStream.Seek(Offset: Longint; Origin: Word): Longint;

  procedure RaiseException;
  begin
//    raise EStreamError.CreateResFmt(@sSeekNotImplemented, [Classname]);
  end;

type
  TSeek64 = function (const Offset: Int64; Origin: TSeekOrigin): Int64 of object;
var
  Impl: TSeek64;
  Base: TSeek64;
  ClassTStream: TClass;
begin
{ Deflect 32 seek requests to the 64 bit seek, if 64 bit is implemented.
  No existing TStream classes should call this method, since it was originally
  abstract.  Descendent classes MUST implement at least one of either
  the 32 bit or the 64 bit version, and must not call the inherited
  default implementation. }
  Impl := Seek;
  ClassTStream := Self.ClassType;
  while (ClassTStream <> nil) and (ClassTStream <> TStream) do
    ClassTStream := ClassTStream.ClassParent;
  if ClassTStream = nil then RaiseException;
  Base := TStream(@ClassTStream).Seek;
  if TMethod(Impl).Code = TMethod(Base).Code then
    RaiseException;
  Result := Seek(Int64(Offset), TSeekOrigin(Origin));
end;

function TStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
{ Default implementation of 64 bit seek is to deflect to existing 32 bit seek.
  Descendents that override 64 bit seek must not call this default implementation. }
 // if (Offset < Low(Longint)) or (Offset > High(Longint)) then
 //   raise ERangeError.CreateRes(@SRangeError);
  Result := Seek(Longint(Offset), Ord(Origin));
end;

procedure TStream.ReadBuffer(var Buffer; Count: Longint);
begin
  if (Count <> 0) and (Read(Buffer, Count) <> Count) then
//    raise EReadError.CreateRes(@SReadError);
end;

procedure TStream.WriteBuffer(const Buffer; Count: Longint);
begin
  if (Count <> 0) and (Write(Buffer, Count) <> Count) then
//    raise EWriteError.CreateRes(@SWriteError);
end;

function TStream.CopyFrom(Source: TStream; Count: Int64): Int64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PChar;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

function StrUpper(Str: PChar): PChar; assembler;
asm
        PUSH    ESI
        MOV     ESI,Str
        MOV     EDX,Str
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'a'
        JB      @@1
        CMP     AL,'z'
        JA      @@1
        SUB     AL,20H
        MOV     [ESI-1],AL
        JMP     @@1
@@2:    XCHG    EAX,EDX
        POP     ESI
end;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrPLCopy(Dest: PChar; const Source: string;
  MaxLen: Cardinal): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), MaxLen);
end;

procedure TStream.WriteResourceHeader(const ResName: string; out FixupInfo: Integer);
var
  HeaderSize: Integer;
  Header: array[0..79] of Char;
begin
  Byte((@Header[0])^) := $FF;
  Word((@Header[1])^) := 10;
  HeaderSize := StrLen(StrUpper(StrPLCopy(@Header[3], ResName, 63))) + 10;
  Word((@Header[HeaderSize - 6])^) := $1030;
  Longint((@Header[HeaderSize - 4])^) := 0;
  WriteBuffer(Header, HeaderSize);
  FixupInfo := Position;
end;

procedure TStream.FixupResourceHeader(FixupInfo: Integer);
var
  ImageSize: Integer;
begin
  ImageSize := Position - FixupInfo;
  Position := FixupInfo - 4;
  WriteBuffer(ImageSize, SizeOf(Longint));
  Position := FixupInfo + ImageSize;
end;

procedure TStream.ReadResHeader;
var
  ReadCount: Cardinal;
  Header: array[0..79] of Char;
begin
  FillChar(Header, SizeOf(Header), 0);
  ReadCount := Read(Header, SizeOf(Header) - 1);
  if (Byte((@Header[0])^) = $FF) and (Word((@Header[1])^) = 10) then
    Seek(StrLen(Header + 3) + 10 - ReadCount, 1)
  else
end;

{ TCustomMemoryStream }

procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; Size: Longint);
begin
  FMemory := Ptr;
  FSize := Size;
end;

function TCustomMemoryStream.Read(var Buffer; Count: Longint): Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := FSize - FPosition;
    if Result > 0 then
    begin
      if Result > Count then Result := Count;
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

function TCustomMemoryStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TCustomMemoryStream.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;

procedure TCustomMemoryStream.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

{ TMemoryStream }

const
  MemoryDelta = $2000; { Must be a power of 2 }

destructor TMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure TMemoryStream.LoadFromStream(Stream: TStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

procedure TMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStream.SetCapacity(NewCapacity: Longint);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure TMemoryStream.SetSize(NewSize: Longint);
var
  OldPosition: Longint;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soFromEnd);
end;

function GlobalFreePtr(P: Pointer): THandle; assembler;
asm
        PUSH    EAX
        CALL    GlobalHandle
        PUSH    EAX
        PUSH    EAX
        CALL    GlobalUnlock
        CALL    GlobalFree
end;

function GlobalAllocPtr(Flags: Integer; Bytes: Longint): Pointer; assembler;
asm
        PUSH    EDX
        PUSH    EAX
        CALL    GlobalAlloc
        PUSH    EAX
        CALL    GlobalLock
end;

function GlobalReAllocPtr(P: Pointer; Bytes: Longint;
  Flags: Integer): Pointer; assembler;
asm
        PUSH    ECX
        PUSH    EDX
        PUSH    EAX
        CALL    GlobalHandle
        PUSH    EAX
        PUSH    EAX
        CALL    GlobalUnlock
        CALL    GlobalReAlloc
        PUSH    EAX
        CALL    GlobalLock
end;

function TMemoryStream.Realloc(var NewCapacity: Longint): Pointer;
begin
  if (NewCapacity > 0) and (NewCapacity <> FSize) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
{$IFDEF MSWINDOWS}
      GlobalFreePtr(Memory);
{$ELSE}
      FreeMem(Memory);
{$ENDIF}
      Result := nil;
    end else
    begin
{$IFDEF MSWINDOWS}
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
{$ELSE}
      if Capacity = 0 then
        GetMem(Result, NewCapacity)
      else
        ReallocMem(Result, NewCapacity);
{$ENDIF}
      if Result = nil then //raise EStreamError.CreateRes(@SMemoryStreamError);
    end;
  end;
end;

function TMemoryStream.Write(const Buffer; Count: Longint): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize := Pos;
      end;
      System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

{ THandleStream }

constructor THandleStream.Create(AHandle: Integer);
begin
  inherited Create;
  FHandle := AHandle;
end;

function FileRead(Handle: Integer; var Buffer; Count: LongWord): Integer;
begin
{$IFDEF MSWINDOWS}
  if not ReadFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
    Result := -1;
{$ENDIF}
{$IFDEF LINUX}
  Result := __read(Handle, Buffer, Count);
{$ENDIF}
end;


function THandleStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FileRead(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function FileWrite(Handle: Integer; const Buffer; Count: LongWord): Integer;
begin
{$IFDEF MSWINDOWS}
  if not WriteFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
    Result := -1;
{$ENDIF}
{$IFDEF LINUX}
  Result := __write(Handle, Buffer, Count);
{$ENDIF}
end;

function THandleStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FileWrite(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function FileSeek(Handle, Offset, Origin: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
{$ENDIF}
{$IFDEF LINUX}
  Result := __lseek(Handle, Offset, Origin);
{$ENDIF}
end;

function THandleStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := FileSeek(FHandle, Offset, Ord(Origin));
end;

procedure THandleStream.SetSize(NewSize: Longint);
begin
  SetSize(Int64(NewSize));
end;

procedure THandleStream.SetSize(const NewSize: Int64);
begin
  Seek(NewSize, soBeginning);
{$IFDEF MSWINDOWS}
 // Win32Check(SetEndOfFile(FHandle));
{$ELSE}
  if ftruncate(FHandle, Position) = -1 then
    raise EStreamError(sStreamSetSize);
{$ENDIF}
end;


{ TFileStream }

constructor TFileStream.Create(const FileName: string; Mode: Word);
begin
{$IFDEF MSWINDOWS}
  Create(Filename, Mode, 0);
{$ELSE}
  Create(Filename, Mode, FileAccessRights);
{$ENDIF}
end;

function FileCreate(const FileName: string): Integer;
{$IFDEF MSWINDOWS}
begin
  Result := Integer(CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result := FileCreate(FileName, FileAccessRights);
end;
{$ENDIF}

function FileCreate(const FileName: string; Rights: Integer): Integer;
{$IFDEF MSWINDOWS}
begin
  Result := FileCreate(FileName);
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result := Integer(open(PChar(FileName), O_RDWR or O_CREAT or O_TRUNC, Rights));
end;
{$ENDIF}

function FileOpen(const FileName: string; Mode: LongWord): Integer;
{$IFDEF MSWINDOWS}
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := -1;
  if ((Mode and 3) <= fmOpenReadWrite) and
    ((Mode and $F0) <= fmShareDenyNone) then
    Result := Integer(CreateFile(PChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
end;
{$ENDIF}
{$IFDEF LINUX}
const
  ShareMode: array[0..fmShareDenyNone shr 4] of Byte = (
    0,        //No share mode specified
    F_WRLCK,  //fmShareExclusive
    F_RDLCK,  //fmShareDenyWrite
    0);       //fmShareDenyNone
var
  FileHandle, Tvar: Integer;
  LockVar: TFlock;
  smode: Byte;
begin
  Result := -1;
  if FileExists(FileName) and
     ((Mode and 3) <= fmOpenReadWrite) and
     ((Mode and $F0) <= fmShareDenyNone) then
  begin
    FileHandle := open(PChar(FileName), (Mode and 3), FileAccessRights);

    if FileHandle = -1 then  Exit;

    smode := Mode and $F0 shr 4;
    if ShareMode[smode] <> 0 then
    begin
      with LockVar do
      begin
        l_whence := SEEK_SET;
        l_start := 0;
        l_len := 0;
        l_type := ShareMode[smode];
      end;
      Tvar :=  fcntl(FileHandle, F_SETLK, LockVar);
      if Tvar = -1 then
      begin
        __close(FileHandle);
        Exit;
      end;
    end;
    Result := FileHandle;
  end;
end;
{$ENDIF}

constructor TFileStream.Create(const FileName: string; Mode: Word; Rights: Cardinal);
begin
  if Mode = fmCreate then
  begin
    inherited Create(FileCreate(FileName, Rights));
    if FHandle < 0 then
  //    raise EFCreateError.CreateResFmt(@SFCreateErrorEx, [ExpandFileName(FileName), SysErrorMessage(GetLastError)]);
  end
  else
  begin
    inherited Create(FileOpen(FileName, Mode));
    if FHandle < 0 then
//      raise EFOpenError.CreateResFmt(@SFOpenErrorEx, [ExpandFileName(FileName), SysErrorMessage(GetLastError)]);
  end;
end;

procedure FileClose(Handle: Integer);
begin
{$IFDEF MSWINDOWS}
  CloseHandle(THandle(Handle));
{$ENDIF}
{$IFDEF LINUX}
  __close(Handle); // No need to unlock since all locks are released on close.
{$ENDIF}
end;

destructor TFileStream.Destroy;
begin
  if FHandle >= 0 then FileClose(FHandle);
  inherited Destroy;
end;


function GetIdeDiskSerialNumber : String;
type
  TSrbIoControl = packed record
    HeaderLength : Cardinal;
    Signature : Array[0..7] of Char;
    Timeout : Cardinal;
    ControlCode : Cardinal;
    ReturnCode : Cardinal;
    Length : Cardinal;
  end;
  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg : Byte; // Used for specifying SMART "commands".
    bSectorCountReg : Byte; // IDE sector count register
    bSectorNumberReg : Byte; // IDE sector number register
    bCylLowReg : Byte; // IDE low order cylinder value
    bCylHighReg : Byte; // IDE high order cylinder value
    bDriveHeadReg : Byte; // IDE drive/head register
    bCommandReg : Byte; // Actual IDE command.
    bReserved : Byte; // reserved for future use. Must be zero. 
  end;
  IDEREGS = TIDERegs; 
  PIDERegs = ^TIDERegs; 

  TSendCmdInParams = packed record 
    cBufferSize : DWORD; // Buffer size in bytes 
    irDriveRegs : TIDERegs; // Structure with drive register values. 
    bDriveNumber : Byte; // Physical drive number to send command to (0,1,2,3).
    bReserved : Array[0..2] of Byte; // Reserved for future expansion. 
    dwReserved : Array[0..3] of DWORD; // For future use. 
    bBuffer : Array[0..0] of Byte; // Input buffer. 
  end; 
  SENDCMDINPARAMS = TSendCmdInParams; 
  PSendCmdInParams = ^TSendCmdInParams; 

  TIdSector = packed record 
    wGenConfig : Word; 
    wNumCyls : Word; 
    wReserved : Word; 
    wNumHeads : Word; 
    wBytesPerTrack : Word; 
    wBytesPerSector : Word;
    wSectorsPerTrack : Word; 
    wVendorUnique : Array[0..2] of Word; 
    sSerialNumber : Array[0..19] of Char; 
    wBufferType : Word; 
    wBufferSize : Word; 
    wECCSize : Word; 
    sFirmwareRev : Array[0..7] of Char;
    sModelNumber : Array[0..39] of Char; 
    wMoreVendorUnique : Word; 
    wDoubleWordIO : Word; 
    wCapabilities : Word; 
    wReserved1 : Word; 
    wPIOTiming : Word; 
    wDMATiming : Word;
    wBS : Word; 
    wNumCurrentCyls : Word; 
    wNumCurrentHeads : Word; 
    wNumCurrentSectorsPerTrack : Word; 
    ulCurrentSectorCapacity : Cardinal;
    wMultSectorStuff : Word; 
    ulTotalAddressableSectors : Cardinal;
    wSingleWordDMA : Word; 
    wMultiWordDMA : Word; 
    bReserved : Array[0..127] of Byte; 
  end; 
  PIdSector = ^TIdSector; 

const
  IDE_ID_FUNCTION = $EC; 
  IDENTIFY_BUFFER_SIZE = 512; 
  DFP_RECEIVE_DRIVE_DATA = $0007c088; 
  IOCTL_SCSI_MINIPORT = $0004d008; 
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001b0501; 
  DataSize = sizeof(TSendCmdInParams)-1+IDENTIFY_BUFFER_SIZE; 
  BufferSize = SizeOf(SRB_IO_CONTROL)+DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE+16; 
var 
  hDevice : THandle; 
  cbBytesReturned : DWORD; 
  pInData : PSendCmdInParams; 
  pOutData : Pointer; // PSendCmdInParams; 
  Buffer : Array[0..BufferSize-1] of Byte;
  srbControl : TSrbIoControl absolute Buffer; 

  procedure ChangeByteOrder( var Data; Size : Integer ); 
  var ptr : PChar; 
      i : Integer; 
      c : Char; 
  begin
    ptr := @Data; 
    for i := 0 to (Size shr 1)-1 do 
    begin 
      c := ptr^; 
      ptr^ := (ptr+1)^; 
      (ptr+1)^ := c; 
      Inc(ptr,2);
    end; 
  end; 

begin 
  Result := ''; 
  FillChar(Buffer,BufferSize,#0); 
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    begin // Windows NT, Windows 2000 
      // Get SCSI port handle 
      hDevice := CreateFile( '\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE, 
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 ); 
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
        System.Move('SCSIDISK',srbControl.Signature,8); 
        srbControl.Timeout := 2; 
        srbControl.Length := DataSize; 
        srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY; 
        pInData := PSendCmdInParams(PChar(@Buffer)+SizeOf(SRB_IO_CONTROL));
        pOutData := pInData;
        with pInData^ do
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1;
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end;
        if not DeviceIoControl( hDevice, IOCTL_SCSI_MINIPORT, @Buffer,
          BufferSize, @Buffer, BufferSize, cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end 
  else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
      if hDevice=INVALID_HANDLE_VALUE then Exit; 
      try 
        pInData := PSendCmdInParams(@Buffer); 
        pOutData := PChar(@pInData^.bBuffer); 
        with pInData^ do
        begin 
          cBufferSize := IDENTIFY_BUFFER_SIZE; 
          bDriveNumber := 0; 
          with irDriveRegs do 
          begin 
            bFeaturesReg := 0; 
            bSectorCountReg := 1;
            bSectorNumberReg := 1; 
            bCylLowReg := 0; 
            bCylHighReg := 0; 
            bDriveHeadReg := $A0; 
            bCommandReg := IDE_ID_FUNCTION; 
          end; 
        end;
        if not DeviceIoControl( hDevice, DFP_RECEIVE_DRIVE_DATA, pInData,  
           SizeOf(TSendCmdInParams)-1, pOutData, W9xBufferSize, 
           cbBytesReturned, nil ) then Exit; 
      finally 
        CloseHandle(hDevice); 
      end; 
    end;
    with PIdSector(PChar(pOutData)+16)^ do 
    begin 
      ChangeByteOrder(sSerialNumber,SizeOf(sSerialNumber)); 
      SetString(Result,sSerialNumber,SizeOf(sSerialNumber)); 
    end; 
end;

function IntPower(const Base: Extended; const Exponent: Integer): Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
@@1:    fmul    ST, ST            { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
@@3:
        fwait
end;

Function hextointdef(hex : string; default : integer) : integer;
var
  s : string;
  int, i : integer;
begin
 int:=0;
 If length(hex)>0 then If hex[1]='$' then delete(hex,1,1);
 If length(hex)>0 then
 begin
  For i:=1 to length(hex) do
  begin
   s:=s+' ';
   s[i]:=hex[length(hex)+1-i];
  end;
  For i:=1 to length(hex) do
  Case Upcase(s[i]) of
   '0': int:=int;
   '1': int:=int+round(intpower(16,i-1));
   '2': int:=int+2*round(intpower(16,i-1));
   '3': int:=int+3*round(intpower(16,i-1));
   '4': int:=int+4*round(intpower(16,i-1));
   '5': int:=int+5*round(intpower(16,i-1));
   '6': int:=int+6*round(intpower(16,i-1));
   '7': int:=int+7*round(intpower(16,i-1));
   '8': int:=int+8*round(intpower(16,i-1));
   '9': int:=int+9*round(intpower(16,i-1));
   'A': int:=int+10*round(intpower(16,i-1));
   'B': int:=int+11*round(intpower(16,i-1));
   'C': int:=int+12*round(intpower(16,i-1));
   'D': int:=int+13*round(intpower(16,i-1));
   'E': int:=int+14*round(intpower(16,i-1));
   'F': int:=int+15*round(intpower(16,i-1));
   else
   begin
    int:=default;
    break;
   end;
  end;
 end else
 int:=default;
 result:=int;
end;

procedure CvtInt;
{ IN:
    EAX:  The integer value to be converted to text
    ESI:  Ptr to the right-hand side of the output buffer:  LEA ESI, StrBuf[16]
    ECX:  Base for conversion: 0 for signed decimal, 10 or 16 for unsigned
    EDX:  Precision: zero padded minimum field width
  OUT:
    ESI:  Ptr to start of converted text (not start of buffer)
    ECX:  Length of converted text
}
asm
        OR      CL,CL
        JNZ     @CvtLoop
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AL,'-'
        INC     ECX
        DEC     ESI
        MOV     [ESI],AL
        RET
@C2:    MOV     ECX,10

@CvtLoop:
        PUSH    EDX
        PUSH    ESI
@D1:    XOR     EDX,EDX
        DIV     ECX
        DEC     ESI
        ADD     DL,'0'
        CMP     DL,'0'+10
        JB      @D2
        ADD     DL,('A'-'0')-10
@D2:    MOV     [ESI],DL
        OR      EAX,EAX
        JNE     @D1
        POP     ECX
        POP     EDX
        SUB     ECX,ESI
        SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AL,'0'
        SUB     ESI,EDX
        JMP     @z
@zloop: MOV     [ESI+EDX],AL
@z:     DEC     EDX
        JNZ     @zloop
        MOV     [ESI],AL
@D5:
end;

function IntToHex(Value: Integer; Digits: Integer): string;
//  FmtStr(Result, '%.*x', [Digits, Value]);
asm
        CMP     EDX, 32        // Digits < buffer length?
        JBE     @A1
        XOR     EDX, EDX
@A1:    PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 32
        PUSH    ECX            // result ptr
        MOV     ECX, 16        // base 16     EDX = Digits = field width
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
        CALL    System.@LStrFromPCharLen
        ADD     ESP, 32
        POP     ESI
end;

function IntToStr(Value: Integer): string;
//  FmtStr(Result, '%d', [Value]);
asm
        PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 16
        XOR     ECX, ECX       // base: 0 for signed decimal
        PUSH    EDX            // result ptr
        XOR     EDX, EDX       // zero filled field width: 0 for no leading zeros
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
        CALL    System.@LStrFromPCharLen
        ADD     ESP, 16
        POP     ESI
end;


end.
