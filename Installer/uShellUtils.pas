unit uShellUtils;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows,
  Classes,
  Forms,
  UnitINI,
  uConstants,
  Registry,
  SysUtils,
  uLogger,
  uMemory,
  uInstallTypes,
  uTranslate,
  uDBBaseTypes,
  uAssociations,
  Controls,
  ShellApi,
  ShlObj,
  uFileUtils,
  uRuntime,
  win32crc,
  uSysUtils,
  Messages;

const
  BCM_FIRST = $1600; //Button control messages
  BCM_SETSHIELD = BCM_FIRST + $000C;

type
  TRegistryInstallCallBack = procedure(Current, Total: Integer; var Terminate : Boolean) of object;

function RegInstallApplication(FileName: string; CallBack : TRegistryInstallCallBack): Boolean;
function IsNewVersion: Boolean;
function DeleteRegistryEntries: Boolean;
function GetSystemPath(PathType: Integer): string;
function InstalledDirectory: string;
function InstalledFileName: string;
function GetProgramFilesPath: string;
function GetStartMenuPath: string;
function GetDesktopPath: string;
function GetMyDocumentsPath: string;
function GetMyPicturesPath: string;
function GetAppDataPath: string;
function GetTempDirectory: string;
function GetTempFileName: TFileName;
procedure RefreshSystemIconCache;

implementation

function InstalledDirectory: string;
begin
  Result := ExtractFileDir(InstalledFileName);
end;

function InstalledFileName: string;
var
  FReg: TBDRegistry;
begin
  Result := '';
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, False);
    Result := FReg.ReadString('DataBase');
    if PortableWork then
      if Result <> '' then
        Result[1] := Application.Exename[1];
  except
  end;
  FReg.Free;
end;

function IsNewVersion: Boolean;
var
  FReg: TBDRegistry;
  Func: TIntegerFunction;
  H: Thandle;
  ProcH: Pointer;
  FileName: string;
begin
  Result := False;
  Freg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    FileName := FReg.ReadString('DataBase');
    if FileExistsSafe(FileName) then
    begin
      H := LoadLibrary(PWideChar(FileName));
      if H <> 0 then
      begin
        ProcH := GetProcAddress(H, 'FileVersion');
        if ProcH <> nil then
        begin
          @Func := ProcH;
          if Func > ReleaseNumber then
            Result := True;
        end;
        FreeLibrary(H);
      end;
    end;
  except
    on e: Exception do
      EventLog(e.Message);
  end;
  F(FReg);
end;

function DeleteRegistryEntries: Boolean;
var
  Freg: TRegistry;
begin
  Result := False;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('\.photodb');
    FReg.DeleteKey('\PhotoDB.PhotodbFile\');
    FReg.DeleteKey('\.ids');
    FReg.DeleteKey('\PhotoDB.IdsFile\');
    FReg.DeleteKey('\.dbl');
    FReg.DeleteKey('\PhotoDB.DblFile\');
    FReg.DeleteKey('\.ith');
    FReg.DeleteKey('\PhotoDB.IthFile\');
    FReg.DeleteKey('\Directory\Shell\PhDBBrowse\');
    FReg.DeleteKey('\Drive\Shell\PhDBBrowse\');
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_INSTALL;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_INSTALL throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_USER_WORK;
    FReg.DeleteKey(RegRoot);
  except
    on E: Exception do
    begin
      EventLog(':DeleteRegistryEntries()/HKEY_USER_WORK throw exception: ' + E.message);
      FReg.Free;
    end;
  end;
  FReg.Free;
  FReg := Tregistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\WPD\Source');
    FReg.DeleteKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
    FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
    FReg.OpenKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.DeleteValue('PhotoDBgetPhotosHandler');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;

  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey(
      '\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\AutoplayHandlers\EventHandlers\WPD\Compat\WiaDeviceConnected');
    FReg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\AutoplayHandlers\Handlers\WIA_{6288D3A0-3E70-481A-8037-378532BED8C6}');
    Result := True;
  except
    on E: Exception do
      EventLog(':DeleteRegistryEntries() throw exception: ' + E.message);
  end;
  FReg.Free;

end;

function RegInstallApplication(FileName: string; CallBack : TRegistryInstallCallBack): Boolean;
const
  ActionCount = 14;
  WPD_CONTENT_TYPE_IMAGE = '{EF2107D5-A52A-4243-A26B-62D4176D7603}';
var
  FReg: TBDRegistry;
  Terminate : Boolean;
begin
  Terminate := False;
  Result := True;

  CallBack(1, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    FReg.OpenKey(RegRoot, True);
    FReg.WriteDateTime('InstallDate', FReg.ReadDateTime('InstallDate', Now));
    FReg.WriteString('ReleaseNumber', IntToStr(ReleaseNumber));
    FReg.WriteString('DataBase', Filename);
    FReg.WriteString('Language', TTranslateManager.Instance.Language);
    FReg.WriteString('Folder', ExtractFileDir(Filename));
  except
    on E: Exception do
    begin
      Result := False;
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      F(FReg);
      Exit;
    end;
  end;
  F(FReg);

  CallBack(2, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    FReg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase', True);
    FReg.WriteString('UninstallString', IncludeTrailingBackslash(ExtractFileDir(FileName)) + 'UnInstall.exe');
    FReg.WriteString('DisplayIcon', FileName);
    FReg.WriteString('DisplayName', 'Photo DataBase');
    FReg.WriteString('DisplayVersion', ReleaseToString(GetExeVersion(FileName)));
    FReg.WriteString('HelpLink', ResolveLanguageString(HomePageURL));
    FReg.WriteString('Publisher', CopyRightString);
    FReg.WriteString('URLInfoAbout', 'mailto:' + ProgramMail);
    FReg.WriteInteger('EstimatedSize', ProgramInstallSize);
    FReg.WriteBool('NoModify', True);
    FReg.WriteBool('NoRepair', True);
  except
    on E: Exception do
    begin
      Result := False;
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      F(FReg);
      Exit;
    end;
  end;
  F(FReg);

  CallBack(3, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\.photodb', True);
    FReg.WriteString('', 'PhotoDB.PhotodbFile');
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.PhotodbFile', True);
    FReg.OpenKey('\PhotoDB.PhotodbFile\DefaultIcon', True);
    FReg.WriteString('', FileName + ',0');
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(4, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\.ids', True);
    FReg.WriteString('', 'PhotoDB.IdsFile');
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.IdsFile', True);
    FReg.OpenKey('\PhotoDB.IdsFile\DefaultIcon', True);
    FReg.WriteString('', FileName + ',0');
    FReg.OpenKey('\PhotoDB.IdsFile\Shell\Open\Command', True);
    FReg.WriteString('', Format('"%s" "%%1"', [FileName]));
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(5, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\.dbl', True);
    FReg.WriteString('', 'PhotoDB.dblFile');
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.dblFile', True);
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.dblFile\DefaultIcon', True);
    FReg.WriteString('', FileName + ',0');
    FReg.OpenKey('\PhotoDB.dblFile\Shell\Open\Command', True);
    FReg.WriteString('', Format('"%s" "%%1"', [FileName]));
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(6, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\.ith', True);
    FReg.Writestring('', 'PhotoDB.IthFile');
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.IthFile', True);
    FReg.CloseKey;
    FReg.OpenKey('\PhotoDB.IthFile\DefaultIcon', True);
    FReg.Writestring('', FileName + ',0');
    FReg.OpenKey('\PhotoDB.IthFile\Shell\Open\Command', True);
    FReg.WriteString('', Format('"%s" "%%1"', [FileName]));
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  // Adding Handler for removable drives
  CallBack(7, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\WPD\Source\' + WPD_CONTENT_TYPE_IMAGE, True);
    FReg.WriteString('PhotoDBGetPhotosHandler', '');
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler', True);
    FReg.WriteString('Action', TA('Get photos', 'System'));
    FReg.WriteString('DefaultIcon', FileName + ',0');
    FReg.WriteString('ProgID', 'PhotoDBBridge.PhotoDBAutoplayHandler');
    FReg.WriteString('InitCmdLine', '/import');
    FReg.WriteString('Provider', 'Photo DataBase ' + IIF(ProgramVersionString = '', ProductVersion, ProgramVersionString));
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(8, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.WriteString('PhotoDBGetPhotosHandler', '');
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\MixedContentOnArrival', True);
    FReg.WriteString('PhotoDBGetPhotosHandler', '');
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(11, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS);
  try
    FReg.OpenKey('\SOFTWARE\Classes', True);
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler', True);
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell', True);
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open', True);
    FReg.CloseKey;
    FReg.OpenKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler\Shell\Open\Command', True);
    FReg.WriteString('', Format('"%s" "/GETPHOTOS" "%%1"', [FileName]));
    FReg.CloseKey;
  except
    on E: Exception do
    begin
      EventLog(':RegInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(12, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\Directory\Shell\PhDBBrowse', True);
    FReg.Writestring('', TA('Browse with PhotoDB', 'System'));
    FReg.CloseKey;
    FReg.OpenKey('\Directory\Shell\PhDBBrowse\Command', True);
    FReg.Writestring('', Format('"%s" "/EXPLORER" "%%1"', [Filename]));
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(13, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\Drive\Shell\PhDBBrowse', True);
    FReg.Writestring('', TA('Browse with PhotoDB', 'System'));
    FReg.CloseKey;
    FReg.OpenKey('\Drive\Shell\PhDBBrowse\Command', True);
    FReg.Writestring('', Format('"%s" "/EXPLORER" "%%1"', [Filename]));
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);

  CallBack(14, ActionCount, Terminate);
  FReg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    FReg.OpenKey('\Drive\Shell\PhDBGetPhotos', True);
    FReg.Writestring('', TA('Get photos', 'System'));
    FReg.CloseKey;
    FReg.OpenKey('\Drive\Shell\PhDBGetPhotos\Command', True);
    FReg.Writestring('', Format('"%s" "/GETPHOTOS" "%%1"', [Filename]));
  except
    on E: Exception do
    begin
      EventLog(':ExtInstallApplication() throw exception: ' + E.message);
      Result := False;
      Exit;
    end;
  end;
  F(FReg);
end;

function GetSystemPath(PathType: Integer): string;
var
  P: array[0..MAX_PATH] of char;
  SystemDir: string;
begin
  if SHGetFolderPath(0, PathType, 0,0, @P[0]) = S_OK then
    SystemDir:= P
  else
    SystemDir:= '';

  Result:= SystemDir;
end;

function GetStartMenuPath: string;
begin
  Result := GetSystemPath(CSIDL_COMMON_PROGRAMS);
end;

function GetProgramFilesPath: string;
begin
  Result := GetSystemPath(CSIDL_PROGRAM_FILES);
end;

function GetDesktopPath: string;
begin
  Result := GetSystemPath(CSIDL_COMMON_DESKTOPDIRECTORY);
end;

function GetAppDataPath: string;
begin
  Result := GetSystemPath(CSIDL_APPDATA);
end;

function GetMyPicturesPath: string;
begin
  Result := GetSystemPath(CSIDL_MYPICTURES);
end;

function GetMyDocumentsPath: string;
begin
  Result := GetSystemPath(CSIDL_MYDOCUMENTS);
end;

function GetTempDirectory: string;
var
  TempFolder: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  Result := StrPas(TempFolder);
end;

function GetTempFileName: TFileName;
var
  TempFileName: array [0..MAX_PATH-1] of char;
begin
  if Windows.GetTempFileName(PChar(GetTempDirectory), '~', 0, TempFileName) = 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
  Result := TempFileName;
end;

procedure RefreshSystemIconCache;
begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSH or SHCNF_PATH, nil, nil);
  SHChangeNotify(SHCNE_UPDATEIMAGE, SHCNF_FLUSH or SHCNF_PATH, nil, nil);
end;

end.

