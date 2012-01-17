unit uShellIntegration;

interface

uses
  uMemory,
  Windows,
  SysUtils,
  Classes,
  Forms,
  uVistaFuncs,
  Clipbrd,
  uAppUtils,
  ShlObj,
  ComObj,
  ActiveX,
  Variants,
  uShellNamespaceUtils,
  ShellApi;

function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons, Icon: Integer): Integer;
  overload;
function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: Integer): Integer; overload;
procedure TextToClipboard(const S: string);
function IsWinXP: Boolean;
procedure SetDesktopWallpaper(FileName: string; WOptions: Byte);
procedure HideFromTaskBar(Handle: Thandle);
procedure DisableWindowCloseButton(Handle: Thandle);
procedure ShowPropertiesDialog(FName: string);
procedure ShowMyComputerProperties(Hwnd: THandle);
function ChangeIconDialog(HOwner: THandle; var FileName: string; var IconIndex: Integer): Boolean; overload;
function ChangeIconDialog(HOwner: THandle; var IcoName: string): Boolean; overload;
procedure LoadFilesFromClipBoard(var Effects: Integer; Files: TStrings);
function ExtractAssociatedIconSafe(FileName: string; IconIndex: Word): HICON; overload;
function ExtractAssociatedIconSafe(FileName: string): HICON;  overload;
function CanCopyFromClipboard: Boolean;

implementation

function IsWinXP: Boolean;
begin
  Result := (Win32Platform = VER_PLATFORM_WIN32_NT) and
    (Win32MajorVersion >= 5) and (Win32MinorVersion >= 1);
end;

function MessageBoxDB(Handle: THandle; AContent, Title, ADescription: string; Buttons, Icon: Integer): Integer;
  overload;
begin
  Result := TaskDialogEx(Handle, AContent, Title, ADescription, Buttons, Icon, GetParamStrDBBool('NoVistaMsg'));
end;

function MessageBoxDB(Handle: THandle; AContent, Title: string; Buttons, Icon: Integer): Integer; overload;
begin
  Result := MessageBoxDB(Handle, AContent, Title, '', Buttons, Icon);
end;

function CanCopyFromClipboard: Boolean;
var
  Files: TStrings;
  Effects: Integer;
begin
  Files := TStringList.Create;
  try
    LoadFilesFromClipBoard(Effects, Files);
    Result := Files.Count > 0;
  finally
    F(Files);
  end;

  if not Result then
    Result := ClipboardHasPIDList;
end;

procedure TextToClipboard(const S: string);
var
  N: Integer;
  Mem: Cardinal;
  Ptr: Pointer;
begin
  try
    with Clipboard do
      try
        Open;
        if IsClipboardFormatAvailable(CF_UNICODETEXT) then
        begin
          N := (Length(S) + 1) * 2;
          Mem := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, N);
          Ptr := GlobalLock(Mem);
          Move(PWideChar(Widestring(S))^, Ptr^, N);
          GlobalUnlock(Mem);
          SetAsHandle(CF_UNICODETEXT, Mem);
        end;
        AsText := S;
        Mem := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, SizeOf(Dword));
        Ptr := GlobalLock(Mem);
        Dword(Ptr^) := (SUBLANG_NEUTRAL shl 10) or LANG_RUSSIAN;
        GlobalUnLock(Mem);
        SetAsHandle(CF_LOCALE, Mem);
      finally
        Close;
      end;
  except
  end;
end;

procedure SetDesktopWallpaper(FileName: string; WOptions: Byte);
const
  CLSID_ActiveDesktop: TGUID = '{75048700-EF1F-11D0-9888-006097DEACF9}';
var
  ActiveDesktop: IActiveDesktop;
  Options: TWallPaperOpt;
begin
  ActiveDesktop := CreateComObject(CLSID_ActiveDesktop) as IActiveDesktop;
  ActiveDesktop.SetWallpaper(PChar(FileName), 0);
  Options.DwSize := SizeOf(_tagWALLPAPEROPT);
  Options.DwStyle := WOptions;
  ActiveDesktop.SetWallpaperOptions(Options, 0);
  ActiveDesktop.ApplyChanges(AD_APPLY_ALL or AD_APPLY_FORCE);
end;

procedure HideFromTaskBar(Handle: Thandle);
var
  ExtendedStyle: Integer;
begin
  ExtendedStyle := GetWindowLong(Application.Handle, GWL_EXSTYLE);
  SetWindowLong(Application.Handle, SW_SHOWMINNOACTIVE,
    WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_LTRREADING or WS_EX_LEFT or ExtendedStyle);
end;

procedure DisableWindowCloseButton(Handle: Thandle);
var
  HMenuHandle: HMENU;
begin
  if (Handle <> 0) then
  begin
    HMenuHandle := GetSystemMenu(Handle, FALSE);
    if (HMenuHandle <> 0) then
      DeleteMenu(HMenuHandle, SC_CLOSE, MF_BYCOMMAND);
  end;
end;

procedure LoadFilesFromClipBoard(var Effects: Integer; Files: TStrings);
var
  Hand: THandle;
  Count: Integer;
  Pfname: array [0 .. 10023] of Char;
  CD: Cardinal;
  S: string;
  DwEffect: ^Word;
begin
  Effects := 0;
  Files.Clear;
  if IsClipboardFormatAvailable(CF_HDROP) then
  begin
    if OpenClipboard(Application.Handle) = False then
      Exit;
    CD := 0;
    repeat
      CD := EnumClipboardFormats(CD);
      if (CD <> 0) and (GetClipboardFormatName(CD, Pfname, 1024) <> 0) then
      begin
        S := UpperCase(string(Pfname));
        if Pos('DROPEFFECT', S) <> 0 then
        begin
          Hand := GetClipboardData(CD);
          if (Hand <> NULL) then
          begin
            DwEffect := GlobalLock(Hand);
            Effects := DwEffect^;
            GlobalUnlock(Hand);
          end;
          CD := 0;
        end;
      end;
    until (CD = 0);
    Hand := GetClipboardData(CF_HDROP);
    if (Hand <> NULL) then
    begin
      Count := DragQueryFile(Hand, $FFFFFFFF, nil, 0);
      if Count > 0 then
        repeat
          Dec(Count);
          DragQueryFile(Hand, Count, Pfname, 1024);
          Files.Add(string(Pfname));
        until (Count = 0);
    end;
    CloseClipboard;
  end;
end;

function ChangeIconDialog(HOwner: THandle; var IcoName: string): Boolean; overload;
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: Integer;
begin
  Result := False;
  S := IcoName;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  if ChangeIconDialog(HOwner, FileName, IconIndex) then
  begin
    if FileName <> '' then
      Icon := FileName + ',' + IntToStr(IconIndex);
    IcoName := Icon;
    Result := True;
  end;
end;

function ChangeIconDialog(HOwner: THandle; var FileName: string; var IconIndex: Integer): Boolean;
type
  SHChangeIconProc = function(Wnd: HWND; SzFileName: PChar; Reserved: Integer; var LpIconIndex: Integer): DWORD;
    stdcall;
  SHChangeIconProcW = function(Wnd: HWND; SzFileName: PWideChar; Reserved: Integer; var LpIconIndex: Integer): DWORD;
    stdcall;

const
  Shell32 = 'shell32.dll';

resourcestring
  SNotSupported = 'This function is not supported by your version of Windows';

var
  ShellHandle: THandle;
  SHChangeIcon: SHChangeIconProc;
  SHChangeIconW: SHChangeIconProcW;
  Buf: array [0 .. MAX_PATH] of Char;
  BufW: array [0 .. MAX_PATH] of WideChar;
begin
  Result := False;
  SHChangeIcon := nil;
  SHChangeIconW := nil;
  ShellHandle := Windows.LoadLibrary(PChar(Shell32));
  try
    if ShellHandle <> 0 then
    begin
      if Win32Platform = VER_PLATFORM_WIN32_NT then
        SHChangeIconW := GetProcAddress(ShellHandle, PChar(62))
      else
        SHChangeIcon := GetProcAddress(ShellHandle, PChar(62));
    end;
    if Assigned(SHChangeIconW) then
    begin
      StringToWideChar(FileName, BufW, SizeOf(BufW));
      Result := SHChangeIconW(HOwner, BufW, SizeOf(BufW), IconIndex) = 1;
      if Result then
        FileName := BufW;
    end else if Assigned(SHChangeIcon) then
    begin
      StrPCopy(Buf, FileName);
      Result := SHChangeIcon(HOwner, Buf, SizeOf(Buf), IconIndex) = 1;
      if Result then
        FileName := Buf;
    end else
      raise Exception.Create(SNotSupported);
  finally
    if ShellHandle <> 0 then
      FreeLibrary(ShellHandle);
  end;
end;

procedure ShowPropertiesDialog(FName: string);
var
  SExInfo: TSHELLEXECUTEINFO;
begin
  ZeroMemory(Addr(SExInfo), SizeOf(SExInfo));
  SExInfo.CbSize := SizeOf(SExInfo);
  SExInfo.LpFile := PWideChar(FName);
  SExInfo.LpVerb := 'Properties';
  SExInfo.FMask := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(Addr(SExInfo));
end;

procedure ShowMyComputerProperties(Hwnd: THandle);
var
  PMalloc: IMalloc;
  Desktop: IShellFolder;
  Mnu: IContextMenu;
  Hr: HRESULT;
  PidlDrives: PItemIDList;
  Cmd: TCMInvokeCommandInfo;
begin
  Hr := SHGetMalloc(PMalloc);
  if SUCCEEDED(Hr) then
    try
      Hr := SHGetDesktopFolder(Desktop);
      if SUCCEEDED(Hr) then
        try
          Hr := SHGetSpecialFolderLocation(Hwnd, CSIDL_DRIVES, PidlDrives);
          if SUCCEEDED(Hr) then
            try
              Hr := Desktop.GetUIObjectOf(Hwnd, 1, PidlDrives, IContextMenu, nil, Pointer(Mnu));
              if SUCCEEDED(Hr) then
                try
                  FillMemory(@Cmd, Sizeof(Cmd), 0);
                  with Cmd do
                  begin
                    CbSize := Sizeof(Cmd);
                    FMask := 0;
                    Hwnd := 0;
                    LpVerb := PAnsiChar('Properties');
                    NShow := SW_SHOWNORMAL;
                  end;
                  {Hr := }Mnu.InvokeCommand(Cmd);
                finally
                  Mnu := nil;
                end;
            finally
              PMalloc.Free(PidlDrives);
            end;
        finally
          Desktop := nil;
        end;
    finally
      PMalloc := nil;
    end;
end;

function ExtractAssociatedIconSafe(FileName: string): HICON;
var
  I: Word;
begin
  I := 1;
  Result := ExtractAssociatedIcon(Application.Handle, PChar(FileName), I);
end;

function ExtractAssociatedIconSafe(FileName: string; IconIndex: Word): HICON;
begin
  Result := ExtractAssociatedIcon(Application.Handle, PChar(FileName), IconIndex);
end;

end.
