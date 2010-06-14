program Project2;

{uses
  Windows;  }

type
  HWND = type LongWord;
  HDC = type LongWord;
  BOOL = LongBool;
  HICON = type LongWord;
  HCURSOR = HICON;
  HBRUSH = type LongWord;
  DWORD = LongWord;
  HMENU = type LongWord;

  PPoint = ^TPoint;
  TPoint = packed record
    X: Longint;
    Y: Longint;
  end;
  {$NODEFINE TPoint}
  tagPOINT = TPoint;
  {$NODEFINE tagPOINT}

  PRect = ^TRect;
  TRect = packed record
    case Integer of
      0: (Left, Top, Right, Bottom: Longint);
      1: (TopLeft, BottomRight: TPoint);
  end;
  {$NODEFINE TRect}

  {$EXTERNALSYM BOOL}

{$R *.res}
{$R WindowsXP.res}

var
  HWndButton1,HWndButton2,HWndButton3,HWndButton4,HWndButton5, Box : HWnd;
  RegRoot : string = 'Software\Photo DataBase\';

Const
  WinName = 'WinName';
  Width = 300;
  Height = 220;


const
  STARTF_USESHOWWINDOW = 1;
  {$EXTERNALSYM STARTF_USESHOWWINDOW}


type
  TBooleanFunction = function : Boolean;

  ATOM = Word;

const
  MAX_PATH = 260;
  WM_DESTROY          = $0002;
  WM_COMMAND          = $0111;

type


  PPaintStruct = ^TPaintStruct;
  {$EXTERNALSYM tagPAINTSTRUCT}
  tagPAINTSTRUCT = packed record
    hdc: HDC;
    fErase: BOOL;
    rcPaint: TRect;
    fRestore: BOOL;
    fIncUpdate: BOOL;
    rgbReserved: array[0..31] of Byte;
  end;
  TPaintStruct = tagPAINTSTRUCT;
  {$EXTERNALSYM PAINTSTRUCT}
  PAINTSTRUCT = tagPAINTSTRUCT;


  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);

//  DWORD = LongWord;

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
  UINT = LongWord;
  TProcessInformation = _PROCESS_INFORMATION;


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
  TFarProc = Pointer;
  TFNWndProc = TFarProc;

const
  {$EXTERNALSYM CS_VREDRAW}
  CS_VREDRAW = DWORD(1);
  {$EXTERNALSYM CS_HREDRAW}
  CS_HREDRAW = DWORD(2);

  type
  PWndClassExA = ^TWndClassExA;
  PWndClassExW = ^TWndClassExW;
  PWndClassEx = PWndClassExA;
  {$EXTERNALSYM tagWNDCLASSEXA}
  tagWNDCLASSEXA = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
    hIconSm: HICON;
  end;
  {$EXTERNALSYM tagWNDCLASSEXW}
  tagWNDCLASSEXW = packed record
    cbSize: UINT;
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
    hIconSm: HICON;
  end;
  {$EXTERNALSYM tagWNDCLASSEX}
  tagWNDCLASSEX = tagWNDCLASSEXA;
  TWndClassExA = tagWNDCLASSEXA;
  TWndClassExW = tagWNDCLASSEXW;
  TWndClassEx = TWndClassExA;
  {$EXTERNALSYM WNDCLASSEXA}
  WNDCLASSEXA = tagWNDCLASSEXA;
  {$EXTERNALSYM WNDCLASSEXW}
  WNDCLASSEXW = tagWNDCLASSEXW;
  {$EXTERNALSYM WNDCLASSEX}
  WNDCLASSEX = WNDCLASSEXA;

  PWndClassA = ^TWndClassA;
  PWndClassW = ^TWndClassW;
  PWndClass = PWndClassA;
  {$EXTERNALSYM tagWNDCLASSA}
  tagWNDCLASSA = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PAnsiChar;
    lpszClassName: PAnsiChar;
  end;
  {$EXTERNALSYM tagWNDCLASSW}
  tagWNDCLASSW = packed record
    style: UINT;
    lpfnWndProc: TFNWndProc;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINST;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: PWideChar;
    lpszClassName: PWideChar;
  end;
  {$EXTERNALSYM tagWNDCLASS}
  tagWNDCLASS = tagWNDCLASSA;
  TWndClassA = tagWNDCLASSA;
  TWndClassW = tagWNDCLASSW;
  TWndClass = TWndClassA;
  {$EXTERNALSYM WNDCLASSA}
  WNDCLASSA = tagWNDCLASSA;
  {$EXTERNALSYM WNDCLASSW}
  WNDCLASSW = tagWNDCLASSW;
  {$EXTERNALSYM WNDCLASS}
  WNDCLASS = WNDCLASSA;

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

  MakeIntResourceA = PAnsiChar;
  MakeIntResourceW = PWideChar;
  MakeIntResource = MakeIntResourceA;

  const HKEY_CURRENT_USER     = DWORD($80000001);
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

  WS_MINIMIZEBOX = $20000;
  {$EXTERNALSYM WS_MAXIMIZEBOX}
  WS_MAXIMIZEBOX = $10000;

  WS_THICKFRAME = $40000;

  WS_SYSMENU = $80000;
  WS_CAPTION = $C00000;
  {$EXTERNALSYM WS_OVERLAPPED}
  WS_OVERLAPPED = 0;
  {$EXTERNALSYM WS_OVERLAPPEDWINDOW}
  WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or
    WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
  {$EXTERNALSYM COLOR_BTNFACE}
  COLOR_BTNFACE = 15;
  {$EXTERNALSYM COLOR_WINDOW}
  COLOR_WINDOW = 5;
  {$EXTERNALSYM IDC_ARROW}
  IDC_ARROW = MakeIntResource(32512);
  {$EXTERNALSYM IDI_APPLICATION}
  IDI_APPLICATION = MakeIntResource(32512);

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
  READ_CONTROL             = $00020000;
  {$EXTERNALSYM READ_CONTROL}
  STANDARD_RIGHTS_READ     = READ_CONTROL;
  {$EXTERNALSYM STANDARD_RIGHTS_READ}
  GENERIC_READ             = DWORD($80000000);
  {$EXTERNALSYM GENERIC_READ}

type
  WPARAM = Longint;
  {$EXTERNALSYM WPARAM}
  LPARAM = Longint;
  {$EXTERNALSYM LPARAM}
  LRESULT = Longint;
  {$EXTERNALSYM LRESULT}

type

{ Message structure }
  PMsg = ^TMsg;
  tagMSG = packed record
    hwnd: LongWord;
    message: UINT;
    wParam: Longint;
    lParam: Longint;
    time: DWORD;
    pt: TPoint;
  end;
  {$EXTERNALSYM tagMSG}
  TMsg = tagMSG;
  MSG = tagMSG;
  {$EXTERNALSYM MSG}

const
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
  RegRootW : string = 'Software\Photo DataBase';
  user32    = 'user32.dll';

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

function CharLowerBuff(lpsz: PChar; cchLength: DWORD): DWORD; stdcall; external user32 name 'CharLowerBuffA';

procedure PostQuitMessage(nExitCode: Integer); stdcall;  external user32 name 'PostQuitMessage';

function DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external user32 name 'DefWindowProcA';

function LoadIcon(hInstance: HINST; lpIconName: PChar): HICON; stdcall;  external user32 name 'LoadIconA';

function LoadCursor(hInstance: HINST; lpCursorName: PAnsiChar): HCURSOR; stdcall;  external user32 name 'LoadCursorA';

function RegisterClass(const lpWndClass: TWndClass): ATOM; stdcall; external user32 name 'RegisterClassA';

function ShowWindow(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall; external user32 name 'ShowWindow';

function UpdateWindow(hWnd: HWND): BOOL; stdcall; external user32 name 'UpdateWindow';

function GetDC(hWnd: HWND): HDC; stdcall;  external user32 name 'GetDC';

function GetMessage(var lpMsg: TMsg; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;  external user32 name 'GetMessageA';

function TranslateMessage(const lpMsg: TMsg): BOOL; stdcall; external user32 name 'TranslateMessage';

function DispatchMessage(const lpMsg: TMsg): Longint; stdcall; external user32 name 'DispatchMessageA';

function _CreateWindowEx(dwExStyle: DWORD; lpClassName: PChar;
  lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
  stdcall; external user32 name 'CreateWindowExA';


function CreateWindow(lpClassName: PChar; lpWindowName: PChar;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINST; lpParam: Pointer): HWND;
var
  FPUCW: Word;
begin
  FPUCW := Get8087CW;
  Result := _CreateWindowEx(0, lpClassName, lpWindowName, dwStyle, X, Y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
  Set8087CW(FPUCW);
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
  If fileexists(ReadStringW(HKEY_CURRENT_USER,RegRootW,'DataBase')) then
  begin
   h:=loadlibrary(Pchar(ReadStringW(HKEY_CURRENT_USER,RegRootW,'DataBase')));
   If h<>0 then
   begin
    ProcH:=GetProcAddress(h,'IsFalidDBFile');
    If ProcH<>nil then
    begin
     @f:=ProcH;
     If f then
     if fileexists(getdirectory(ReadStringW(HKEY_CURRENT_USER,RegRootW,'DataBase'))+'\kernel.dll') then
     result:=true;
    end;
   FreeLibrary(h);
   end;
  end;
  except
 end;
end;

function AnsiLowerCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharLowerBuff(Pointer(Result), Len);
end;

Function InstalledFileName : string;
begin
  Result:=AnsiLowerCase(ReadStringW(HKEY_CURRENT_USER,RegRootW,'DataBase'));
end;

procedure UnFormatDir(var s:string);
begin
 if s='' then exit;
 if s[length(s)]='\' then Delete(s,length(s),1);
end;

procedure PackTable;
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/PACKTABLE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
end;

procedure RECREATETHTABLE;
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/RECREATETHTABLE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
end;

procedure SAFEMODE;
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/SAFEMODE"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
end;

procedure UNINSTALL;
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 S:=GetDirectory(InstalledFileName);
 UnformatDir(S);
 CreateProcess(nil,PChar('"'+InstalledFileName+'" "/UNINSTALL"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
end;

function MainWndProc(Window: HWND; AMessage, WParam,
                    LParam: Longint): Longint; stdcall; export;
var
  handledevice : HDC;
   ps : TPaintStruct;
   rect : TRect;
begin
  //подпрограмма обработки сообщений
  case AMessage of
    WM_DESTROY: begin
      PostQuitMessage(0);
      Exit;
    end;

  WM_COMMAND: begin

     if lParam = Integer(HWndButton5) then
     begin
       PostQuitMessage(0);
       Exit;
     end;

     if lParam = Integer(HWndButton1) then
     begin
       PackTable;
       PostQuitMessage(0);
       Exit;
     end;

     if lParam = Integer(HWndButton2) then
     begin
       RECREATETHTABLE;
       PostQuitMessage(0);
       Exit;
     end;

     if lParam = Integer(HWndButton3) then
     begin
       SAFEMODE;
       PostQuitMessage(0);
       Exit;
     end;

     if lParam = Integer(HWndButton4) then
     begin
       UNINSTALL;
       PostQuitMessage(0);
       Exit;
     end;

    end;

    else
       Result := DefWindowProc(Window, AMessage, WParam, LParam);
  end;
end;


function InitApplication: Boolean;
var
  wcx: TWndClass;
begin
    wcx.style := CS_HREDRAW or CS_VREDRAW;
    wcx.lpfnWndProc := @MainWndProc;
    wcx.cbClsExtra := 0;
    wcx.cbWndExtra := 0;
    wcx.hInstance := hInstance;
    wcx.hIcon := LoadIcon(0, IDI_APPLICATION);
    wcx.hCursor := LoadCursor(0, IDC_ARROW);
    wcx.hbrBackground := COLOR_WINDOW;
    wcx.lpszMenuName :=  nil;
    wcx.lpszClassName := PChar(WinName);
    wcx.hbrbackground:=HBRUSH(COLOR_BTNFACE+1);
    Result := RegisterClass(wcx) <> 0;
end;

function InitInstance: LongWord;
begin
  Result := CreateWindow( PChar(WinName),'Tools', WS_OVERLAPPEDWINDOW-WS_MAXIMIZEBOX-WS_THICKFRAME, 300,  200,  width,  height, 0,  0, hInstance,  nil);
end;

const
  {$EXTERNALSYM BS_GROUPBOX}
  BS_GROUPBOX = 7;
  {$EXTERNALSYM WS_CHILD}
  WS_CHILD = $40000000;
  {$EXTERNALSYM WS_VISIBLE}
  WS_VISIBLE = $10000000;
  {$EXTERNALSYM BS_PUSHBUTTON}
  BS_PUSHBUTTON = 0;
  {$EXTERNALSYM BS_DEFPUSHBUTTON}
  BS_DEFPUSHBUTTON = 1;

var
  hwndMain: LongWord;
  AMessage: MSG;
  DC: HDC;
  h : integer;
begin
    if (not InitApplication) then
    begin
      MessageBox(0, 'Ошибка регистрации окна', nil, mb_Ok);
      Exit;
    end;
    hwndMain := InitInstance;
    if (hwndMain = 0) then
    begin
      MessageBox(0, 'Ошибка создания окна', nil, mb_Ok);
      Exit;
    end
    else
    begin
      // Показываем окно и посылаем сообщение WM_PAINT оконной процедуре

      Box:=CreateWindow('BUTTON', 'Startup options',BS_GROUPBOX or WS_CHILD or WS_VISIBLE , 3, 3, width-10, height-40, hwndMain, 0, hInstance, nil);
      h:=0;
      inc(h,30);
      HWndButton1:=CreateWindow('BUTTON', 'Pack table',BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_CHILD or WS_VISIBLE , 20, h, width-40, 20, hwndMain, 0, hInstance, nil);
      inc(h,30);
      HWndButton2:=CreateWindow('BUTTON', 'Recreate Image Thumbs in table',BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_CHILD or WS_VISIBLE , 20, h, width-40, 20, hwndMain, 0, hInstance, nil);
      inc(h,30);
      HWndButton3:=CreateWindow('BUTTON', 'Safe mode',BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_CHILD or WS_VISIBLE , 20, h, width-40, 20, hwndMain, 0, hInstance, nil);
      inc(h,30);
      HWndButton4:=CreateWindow('BUTTON', 'Uninstall',BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_CHILD or WS_VISIBLE , 20, h, width-40, 20, hwndMain, 0, hInstance, nil);
      inc(h,30);
      HWndButton5:=CreateWindow('BUTTON', 'Close',BS_PUSHBUTTON or BS_DEFPUSHBUTTON or WS_CHILD or WS_VISIBLE , 20, h, width-40, 20, hwndMain, 0, hInstance, nil);

      ShowWindow(hwndMain, CmdShow);
      UpdateWindow(HwndMain);
    end;
    DC:=GetDC(hwndMain);

    while (GetMessage(AMessage, 0, 0, 0)) do
    begin
      //Запускаем цикл обработки сообщений
      TranslateMessage(AMessage);
      DispatchMessage(AMessage);
    end;
    Halt(AMessage.wParam);

end.







