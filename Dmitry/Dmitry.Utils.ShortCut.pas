unit Dmitry.Utils.ShortCut;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Win.ComObj,
  Winapi.ActiveX,
  Winapi.ShlObj,
  Winapi.Windows;

type
   TShortCut = class
   private
     FShellLink: IShellLink;
     FPersistFile: IPersistFile;
     function GetArguments: string;
     function GetDescription: string;
     function GetHotKey: System.Classes.TShortCut;
     function GetIconLocation: string;
     function GetIDList: PItemIDList;
     function GetPath: string;
     function GetShowCMD: Integer;
     function GetWorkingDirectory: string;
     procedure SetArguments(const Value: string);
     procedure SetDescription(const Value: string);
     procedure SetHotKey(const Value: System.Classes.TShortCut);
     procedure SetIDList(const Value: PItemIDList);
     procedure SetPath(const Value: string);
     procedure SetRelativePath(const Value: string);
     procedure SetShowCMD(const Value: Integer);
     procedure SetWorkingDirectory(const Value: string);
   public
     // Creates empty unlinked shortcut
     constructor Create; overload;
     // Creates shortcut object loading parameters from specified *.lnk file
     constructor Create(LinkPath: string); overload;
     // Destroys shortcut without saving
     destructor Destroy; override;
     // Saves shortcut info to a specified file
     procedure Save(Filename: string);
     // Loads shortcut object from specified *.lnk file
     procedure Load(Filename: string);
     procedure SetIcon(const ExeDllName: string; Index : Integer);
     // Resolves shortcut (validates path and if object shortcut points to does not exists,
     // opens window and searchs for lost object. Under Windows NT and NTFS if Distributed Link
     // Tracking system is enabled method finds shortcut object and sets correct path
     function Resolve(Window: HWND; Options: DWORD): HResult;
     // Returns last error text
     function GetLastErrorText(ErrorCode: Cardinal): string;
     // Property to access command line parameters for shortcut object
     property Arguments: string read GetArguments write SetArguments;
     // Property to access shortcut object description
     property Description: string read GetDescription write SetDescription;
     // Hot key for shortcut object
     property HotKey: System.Classes.TShortCut read GetHotKey write SetHotKey;
     // Icon location property
     property IconLocation: string read GetIconLocation;
     // IDList property for special shell icon objects
     property IDList: PItemIDList read GetIDList write SetIDList;
     // Path to shortcut abject
     property Path: string read GetPath write SetPath;
     // Relative path set property
     property RelativePath: string write SetRelativePath;
     // Property to find out how to show the running shortcut object
     property ShowCMD: Integer read GetShowCMD write SetShowCMD;
     // Property to access working directory for shortcut object
     property WorkingDirectory: string read GetWorkingDirectory write SetWorkingDirectory;
   end;

type
  EVRSIShortCutError = class(Exception)
  end;

const
  IID_IPersistFile: TGUID = (D1: $0000010B; D2: $0000; D3: $0000; D4: ($C0, $00, $00, $00, $00, $00, $00, $46));

// Autostart : CSIDL_Startup
// Startmenu : CSIDL_Startmenu
// Programs  : CSIDL_Programs
// Favorites : CSIDL_Favorites
// Desktop   : CSIDL_Desktopdirectory
// "Send to"-dir : CSIDL_Sendto
function VRSIGetSpecialDirectoryName(ID: Integer; PlusSlash: Boolean): string;

implementation

function VRSIGetSpecialDirectoryName(ID: Integer; PlusSlash: Boolean): string;
var
  Pidl: PItemIDList;
  Path: PChar;
begin
  if SUCCEEDED(SHGetSpecialFolderLocation(0, ID, Pidl)) then
  begin
    Path := StrAlloc(MAX_PATH);
    SHGetPathFromIDList(Pidl, Path);
    Result := string(Path);
    if PlusSlash then
      Result := IncludeTrailingBackSlash(Result);
  end;
end;

constructor TShortCut.Create;
var
  Err: Integer;
begin
  inherited;
  Err := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IID_IShellLink, FShellLink);
  if Err <> S_OK then
    raise EVRSIShortCutError.Create('Unable to get interface IShellLink!' + #10#13 + GetLastErrorText(Err));
  Err := FShellLink.QueryInterface(IID_IPersistFile, FPersistFile);
  if (Err <> S_OK) then
    raise EVRSIShortCutError.Create('Unable to get interface IPersistFile!' + #10#13 + GetLastErrorText(Err));
end;

constructor TShortCut.Create(LinkPath: string);
begin
  Self.Create;
  Self.Load(LinkPath);
end;

destructor TShortCut.Destroy;
begin
  inherited;
end;

function TShortCut.GetArguments: string;
var
  Arguments: string;
begin
  SetLength(Arguments, MAX_PATH);
  Self.FShellLink.GetArguments(PChar(Arguments), MAX_PATH);
  SetString(Result, PChar(Arguments), Length(PChar(Arguments)));
end;

function TShortCut.GetDescription: string;
var
  Description: string;
begin
  SetLength(Description, MAX_PATH);
  Self.FShellLink.GetDescription(PChar(Description), MAX_PATH);
  SetString(Result, PChar(Description), Length(PChar(Description)));
end;

function TShortCut.GetHotKey: System.Classes.TShortCut;
var
  HotKey: System.Classes.TShortCut;
begin
  Self.FShellLink.GetHotkey(Word(HotKey));
  Result := HotKey;
end;

function TShortCut.GetIconLocation: string;
var
  IconLocation: string;
  Icon: Integer;
begin
  SetLength(IconLocation, MAX_PATH);
  Self.FShellLink.GetIconLocation(PChar(IconLocation), MAX_PATH, Icon);
  Result := PChar(IconLocation) + ',' + IntToStr(Icon);
end;

function TShortCut.GetIDList: PItemIDList;
var
  List: PItemIDList;
begin
  Self.FShellLink.GetIDList(List);
  Result := List;
end;

function TShortCut.GetLastErrorText(ErrorCode: Cardinal): string;
var
  WinErrMsg: PChar;
begin
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrorCode,
    (((WORD((SUBLANG_DEFAULT)) shl 10)) or Word((LANG_NEUTRAL))), @WinErrMsg, 0, nil);
  Result := WinErrMsg;
end;

function TShortCut.GetPath: string;
var
  Path: string;
  FindData: WIN32_FIND_DATA;
begin
  SetLength(Path, MAX_PATH);
  Self.FShellLink.GetPath(PChar(Path), MAX_PATH, FindData, SLGP_UNCPRIORITY);
  SetString(Result, PChar(Path), Length(PChar(Path)));
end;

function TShortCut.GetShowCMD: Integer;
var
  ShowCMD: Integer;
begin
  Self.FShellLink.GetShowCmd(ShowCMD);
  Result := ShowCMD;
end;

function TShortCut.GetWorkingDirectory: string;
var
  WorkDir: string;
begin
  SetLength(WorkDir, MAX_PATH);
  Self.FShellLink.GetWorkingDirectory(PChar(WorkDir), MAX_PATH);
  SetString(Result, PChar(WorkDir), Length(PChar(WorkDir)));
end;

procedure TShortCut.Load(Filename: string);
begin
  FPersistFile.Load(StringToOLEStr(Filename), 0);
end;

function TShortCut.Resolve(Window: HWND; Options: DWORD): HResult;
begin
  Result := Self.FShellLink.Resolve(Window, Options);
end;

procedure TShortCut.Save(Filename: string);
begin
  FPersistFile.Save(PChar(Filename), True);
end;

procedure TShortCut.SetArguments(const Value: string);
begin
  Self.FShellLink.SetArguments(PChar(Value));
end;

procedure TShortCut.SetDescription(const Value: string);
begin
  Self.FShellLink.SetDescription(PChar(Value));
end;

procedure TShortCut.SetHotKey(const Value: System.Classes.TShortCut);
begin
  Self.FShellLink.SetHotkey(Value);
end;

procedure TShortCut.SetIcon(const ExeDllName: string; Index: Integer);
begin
  Self.FShellLink.SetIconLocation(PChar(ExeDllName), Index);
end;

procedure TShortCut.SetIDList(const Value: PItemIDList);
begin
  Self.FShellLink.SetIDList(Value);
end;

procedure TShortCut.SetPath(const Value: string);
begin
  Self.FShellLink.SetPath(PChar(Value));
end;

procedure TShortCut.SetRelativePath(const Value: string);
begin
  Self.FShellLink.SetRelativePath(PChar(Value), 0);
end;

procedure TShortCut.SetShowCMD(const Value: Integer);
begin
  Self.FShellLink.SetShowCmd(Value);
end;

procedure TShortCut.SetWorkingDirectory(const Value: string);
begin
  Self.FShellLink.SetWorkingDirectory(PChar(Value));
end;

end.
