unit uInstallUtils;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.SysUtils,
  System.Classes,
  System.Win.Registry,
  System.Win.ComObj,
  Winapi.Messages,
  Winapi.Windows,
  Winapi.ShlObj,
  Winapi.ActiveX,
  Vcl.Forms,

  Dmitry.Utils.ShortCut,

  UnitINI,

  uConstants,
  uMemory,
  uInstallTypes,
  uInstallScope,
  IniFiles,
  uTranslate,
  uLogger,
  uShellUtils,
  uUserUtils,
  uAppUtils;

type
  TBooleanFunction = function: Boolean;

function IsApplicationInstalled: Boolean;
function GetRCDATAResourceStream(ResName: string; MS: TMemoryStream): Boolean;
procedure CreateShortcut(SourceFileName, ShortcutPath: string; Description: string);
function ResolveInstallPath(Path: string): string;
procedure CreateInternetShortcut(const FileName, LocationURL: string);
function GetInstalledFileName: string;
procedure ActivateBackgroundApplication(HWnd: THandle);

implementation

procedure ActivateBackgroundApplication(hWnd: THandle);
var
  hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: Boolean;
begin
  Application.Restore;

  hWnd := Application.Handle;
  SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
  SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
  SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);

  hCurWnd := GetForegroundWindow;
  AResult := False;
  while not AResult do
  begin
    dwThreadID := GetCurrentThreadId;
    dwCurThreadID := GetWindowThreadProcessId(hCurWnd);
    AttachThreadInput(dwThreadID, dwCurThreadID, True);
    AResult := SetForegroundWindow(hWnd);
    AttachThreadInput(dwThreadID, dwCurThreadID, False);
  end;

end;

function GetInstalledFileName : string;
var
  FReg: TBDRegistry;
begin
  Result := '';
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    Result := AnsiLowerCase(FReg.ReadString('DataBase'));
  except
    on E: Exception do
      EventLog(':IsInstalledApplication() throw exception: ' + E.message);
  end;
  F(FReg);
end;

function IsApplicationInstalled: Boolean;
begin
  Result := FileExists(GetInstalledFileName);
end;

function GetRCDATAResourceStream(ResName : string; MS : TMemoryStream) : Boolean;
var
  MyResP: Pointer;
  MyRes,
  MyResS: Integer;
begin
  Result := False;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        with MS do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        Result := True;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

procedure CreateShortcut(SourceFileName, ShortcutPath: string; Description: string);
var
  VRSIShortCut: Dmitry.Utils.ShortCut.TShortCut;
begin
  VRSIShortCut := Dmitry.Utils.ShortCut.TShortCut.Create;
  try
    if not DirectoryExists(ExtractFileDir(ShortcutPath)) then
      CreateDir(ExtractFileDir(ShortcutPath));

    VRSIShortCut.WorkingDirectory := ExtractFileDir(SourceFileName);
    VRSIShortCut.SetIcon(SourceFileName, 0);
    VRSIShortCut.Path := SourceFileName;
    VRSIShortCut.Description := Description;

    if FileExists(ShortcutPath) then
      if not System.SysUtils.DeleteFile(ShortcutPath) then
        Exit;

    VRSIShortCut.Save(ShortcutPath);
  finally
    F(VRSIShortCut);
  end;
end;

function ResolveInstallPath(Path : string) : string;
var
  ProgramPath,
  DesktopPath,
  StartMenuPath: string;
  Reg: TRegIniFile;
begin
  Result := StringReplace(Path, '{V}', ProductMajorVersionVersion, [rfIgnoreCase]);
  Result := StringReplace(Result, '{LNG}', AnsiLowerCase(TTranslateManager.Instance.Language), [rfIgnoreCase]);
  try
    ProgramPath := ExcludeTrailingPathDelimiter(CurrentInstall.DestinationPath);
    StartMenuPath := GetStartMenuPath;
    DesktopPath := GetDesktopPath;

    Result := StringReplace(Result, '%PROGRAM%', ProgramPath, [rfIgnoreCase]);
    Result := StringReplace(Result, '%STARTMENU%', StartMenuPath, [rfIgnoreCase]);
    Result := StringReplace(Result, '%DESKTOP%', DesktopPath, [rfIgnoreCase]);
  finally
    F(Reg);
  end;
end;

procedure CreateInternetShortcut(const FileName, LocationURL : string);
begin
  with TIniFile.Create(FileName) do
  try
    WriteString(
       'InternetShortcut',
       'URL',
       LocationURL) ;
  finally
    Free;
  end;
end;

end.
