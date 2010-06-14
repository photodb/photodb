unit VRSIShortCuts;
 //==============================================================================
 //                     FractalizeR's Delphi Library
 //               <- ShortCut Operations Class v1.0 ->
 //             Автор: Раструсный Владислав
 //                          http://www.vrsi.ru
 //                           info@vrsi.ru
 //==============================================================================
{-------------------------------------------------------------------------------
Usage example on existing shortcut file:
var MyShortCut: TVRSIShortCut;
MyShortCut:=TVRSIShortCut.Create('C:\MyShortcut.lnk');
MyShortCut.IconLocation:='E:\Program Files\FlashGet\flashget.exe,0';
MyShortCut.Save('C:\MyShortcut.lnk');
MyShortCut.Free;
-------------------------------------------------------------------------------}
{-------------------------------------------------------------------------------
Shortcut creation example:
var MyShortCut: TVRSIShortCut;
MyShortCut:=TVRSIShortCut.Create;
MyShortCut.Path:='E:\Program Files\FlashGet\flashget.exe';
MyShortCut.IconLocation:='E:\Program Files\FlashGet\flashget.exe,0';
MyShortCut.ShowCMD:=SW_MAXIMIZE;
MyShortCut.Save('C:\MyShortcut.lnk');
MyShortCut.Free;
-------------------------------------------------------------------------------}
interface
uses ActiveX, Classes, ComObj, ShlObj, SysUtils, Windows;
type
  TVRSIShortCut = class
  private
    FShellLink:   IShellLink;
    FPersistFile: IPersistFile;
    function GetArguments: string;
    function GetDescription: string;
    function GetHotKey: TShortCut;
    function GetIconLocation: string;
    function GetIDList: PItemIDList;
    function GetPath: string;
    function GetShowCMD: Integer;
    function GetWorkingDirectory: string;
    procedure SetArguments(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetHotKey(const Value: TShortCut);
    procedure SetIconLocation(const Value: string);
    procedure SetIDList(const Value: PItemIDList);
    procedure SetPath(const Value: string);
    procedure SetRelativePath(const Value: string);
    procedure SetShowCMD(const Value: Integer);
    procedure SetWorkingDirectory(const Value: string);
  public
    // Creates empty unlinked shortcut
    constructor Create; overload;
    //Creates shortcut object loading parameters from specified *.lnk file
    constructor Create(LinkPath: string); overload;
    //Destroys shortcut without saving
    destructor Destroy; override;
    //Saves shortcut info to a specified file
    procedure Save(Filename: string);
    //Loads shortcut object from specified *.lnk file
    procedure Load(Filename: string);
    //Resolves shortcut (validates path and if object shortcut points to does not exists,
    //opens window and searchs for lost object. Under Windows NT and NTFS if Distributed Link
    //Tracking system is enabled method finds shortcut object and sets correct path
    function Resolve(Window: HWND; Options: DWORD): HResult;
    //Returns last error text
    function GetLastErrorText(ErrorCode: Cardinal): string;
    //Property to access command line parameters for shortcut object
    property Arguments: string Read GetArguments Write SetArguments;
    //Property to access shortcut object description
    property Description: string Read GetDescription Write SetDescription;
    //Hot key for shortcut object
    property HotKey: TShortCut Read GetHotKey Write SetHotKey;
    //Icon location property
    property IconLocation: string Read GetIconLocation Write SetIconLocation;
    //IDList property for special shell icon objects
    property IDList: PItemIDList Read GetIDList Write SetIDList;
    //Path to shortcut abject
    property Path: string Read GetPath Write SetPath;
    //Relative path set property
    property RelativePath: string Write SetRelativePath;
    //Property to find out how to show the running shortcut object
    property ShowCMD: Integer Read GetShowCMD Write SetShowCMD;
    //Property to access working directory for shortcut object
    property WorkingDirectory: string Read GetWorkingDirectory
      Write SetWorkingDirectory;
  end;
type
  EVRSIShortCutError = class (Exception)
  end;
function VRSIGetSpecialDirectoryName(ID: integer; PlusSlash: Boolean): string;
 //Autostart : CSIDL_Startup
 //Startmenu : CSIDL_Startmenu
 //Programs  : CSIDL_Programs
 //Favorites : CSIDL_Favorites
 //Desktop   : CSIDL_Desktopdirectory
 //"Send to"-dir : CSIDL_Sendto
implementation
const
  IID_IPersistFile: TGUID = (D1: $0000010B; D2: $0000; D3: $0000;
    D4: ($C0, $00, $00, $00, $00,
    $00, $00, $46));
function VRSIGetSpecialDirectoryName(ID: integer; PlusSlash: Boolean): string;
var
  pidl: PItemIDList;
  Path: PChar;
begin
  if SUCCEEDED(SHGetSpecialFolderLocation(0, ID, pidl)) then
  begin
    Path := StrAlloc(MAX_PATH);
    SHGetPathFromIDList(pidl, Path);
    Result := string(Path);
    if PlusSlash then
      Result := IncludeTrailingBackSlash(Result);
  end;
end;
constructor TVRSIShortCut.Create;
var
  Err: Integer;
begin
  inherited;
  Err:=CoInitialize(nil);
  if Err <> S_OK then
    raise EVRSIShortCutError.Create(
      'Невозможно выполнить CoInitialize!' +
      #10#13 + GetLastErrorText(Err));
  Err := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
    IID_IShellLinkA, FShellLink);
  if Err <> S_OK then
    raise EVRSIShortCutError.Create(
      'Невозможно получить интерфейс IShellLink!' +
      #10#13 + GetLastErrorText(Err));
  Err := FShellLink.QueryInterface(IID_IPersistFile, FPersistFile);
  if (Err <> S_OK) then
    raise EVRSIShortCutError.Create(
      'Невозможно получить интерфейс IPersistFile!' +
      #10#13 + GetLastErrorText(Err));
end;
constructor TVRSIShortCut.Create(LinkPath: string);
begin
  Self.Create;
  Self.Load(LinkPath);
end;
destructor TVRSIShortCut.Destroy;
begin
//  Self.FPersistFile._Release;
//  Self.FShellLink._Release;
  CoUninitialize;
  inherited;
end;
function TVRSIShortCut.GetArguments: string;
var
  Arguments: string;
begin
  SetLength(Arguments, MAX_PATH);
  Self.FShellLink.GetArguments(PChar(Arguments), MAX_PATH);
  SetString(Result, PChar(Arguments), Length(PChar(Arguments)));
end;
function TVRSIShortCut.GetDescription: string;
var
  Description: string;
begin
  SetLength(Description, MAX_PATH);
  Self.FShellLink.GetDescription(PChar(Description), MAX_PATH);
  SetString(Result, PChar(Description), Length(PChar(Description)));
end;
function TVRSIShortCut.GetHotKey: TShortCut;
var
  HotKey: TShortCut;
begin
  Self.FShellLink.GetHotkey(Word(HotKey));
  Result := HotKey;
end;
function TVRSIShortCut.GetIconLocation: string;
var
  IconLocation: string;
  Icon: Integer;
begin
  SetLength(IconLocation, MAX_PATH);
  Self.FShellLink.GetIconLocation(PChar(IconLocation), MAX_PATH, Icon);
  Result := PChar(IconLocation) + ',' + IntToStr(Icon);
end;
function TVRSIShortCut.GetIDList: PItemIDList;
var
  List: PItemIDList;
begin
  Self.FShellLink.GetIDList(List);
  Result := List;
end;
function TVRSIShortCut.GetLastErrorText(ErrorCode: Cardinal): string;
var
  WinErrMsg: PChar;
begin
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
    nil, ErrorCode, (((WORD((SUBLANG_DEFAULT)) shl 10)) or Word((LANG_NEUTRAL))),
    @WinErrMsg, 0, nil);
  Result := WinErrMsg;
end;
function TVRSIShortCut.GetPath: string;
var
  Path: string;
  FindData: WIN32_FIND_DATA;
begin
  SetLength(Path, MAX_PATH);
  Self.FShellLink.GetPath(PChar(Path), MAX_PATH, FindData, 0);
  SetString(Result, PChar(Path), Length(PChar(Path)));
end;
function TVRSIShortCut.GetShowCMD: Integer;
var
  ShowCMD: Integer;
begin
  Self.FShellLink.GetShowCmd(ShowCMD);
  Result := ShowCMD;
end;
function TVRSIShortCut.GetWorkingDirectory: string;
var
  WorkDir: string;
begin
  SetLength(WorkDir, MAX_PATH);
  Self.FShellLink.GetWorkingDirectory(PChar(WorkDir), MAX_PATH);
  SetString(Result, PChar(WorkDir), Length(PChar(WorkDir)));
end;
procedure TVRSIShortCut.Load(Filename: string);
begin
  FPersistFile.Load(StringToOLEStr(Filename), 0);
end;
function TVRSIShortCut.Resolve(Window: HWND; Options: DWORD): HResult;
begin
  Result := Self.FShellLink.Resolve(Window, Options);
end;
procedure TVRSIShortCut.Save(Filename: string);
begin
  FPersistFile.Save(StringToOLEStr(Filename), True);
end;
procedure TVRSIShortCut.SetArguments(const Value: string);
begin
  Self.FShellLink.SetArguments(PChar(Value));
end;
procedure TVRSIShortCut.SetDescription(const Value: string);
begin
  Self.FShellLink.SetDescription(PChar(Value));
end;
procedure TVRSIShortCut.SetHotKey(const Value: TShortCut);
begin
  Self.FShellLink.SetHotkey(Value);
end;
procedure TVRSIShortCut.SetIconLocation(const Value: string);
begin
  Self.FShellLink.SetIconLocation(PChar(Copy(Value, 0, Pos(',', Value) - 1)),
    StrToInt(Copy(Value, Pos(',', Value) + 1, MAX_PATH)));
end;
procedure TVRSIShortCut.SetIDList(const Value: PItemIDList);
begin
  Self.FShellLink.SetIDList(Value);
end;
procedure TVRSIShortCut.SetPath(const Value: string);
begin
  Self.FShellLink.SetPath(PChar(Value));
end;
procedure TVRSIShortCut.SetRelativePath(const Value: string);
begin
  Self.FShellLink.SetRelativePath(PChar(Value), 0);
end;
procedure TVRSIShortCut.SetShowCMD(const Value: Integer);
begin
  Self.FShellLink.SetShowCmd(Value);
end;
procedure TVRSIShortCut.SetWorkingDirectory(const Value: string);
begin
  Self.FShellLink.SetWorkingDirectory(PChar(Value));
end;
end.