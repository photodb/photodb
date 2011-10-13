unit uUninstallActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, uActions, uInstallScope, SysUtils, uInstallUtils,
  uFileUtils, StrUtils, uConstants, uTranslate, ShellAPI, Registry,
  uActivationUtils, uUserUtils;

const
  DeleteFilePoints = 128 * 1024;
  UnInstallPoints_ShortCut = 128 * 1024;
  UninstallNotifyPoints_ShortCut = 1024 * 1024;
  DeleteRegistryPoints = 128 * 1024;

type
  TUninstallFiles = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallShortCuts = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallNotify = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallRegistry = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TUninstallFiles }

function TUninstallFiles.CalculateTotalPoints: Int64;
begin
  Result := CurrentInstall.Files.Count * DeleteFilePoints;
end;

procedure TUninstallFiles.Execute(Callback: TActionCallback);
var
  I : Integer;
  DiskObject : TDiskObject;
  Destination : string;
  Terminate : Boolean;
begin
  Terminate := False;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Destination := IncludeTrailingBackslash(ResolveInstallPath(DiskObject.FinalDestination)) + DiskObject.Name;
    if DiskObject is TFileObject then
      DeleteFile(Destination);
    if DiskObject is TDirectoryObject then
      DeleteDirectoryWithFiles(Destination);

    Callback(Self, I * DeleteFilePoints, CurrentInstall.Files.Count, Terminate);

    if Terminate then
      Break;
  end;
end;

{ TUninstallShortCuts }

function TUninstallShortCuts.CalculateTotalPoints: Int64;
var
  I : Integer;
  DiskObject : TDiskObject;
begin
  Result := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Inc(Result, DiskObject.ShortCuts.Count * UnInstallPoints_ShortCut);
  end;
end;

procedure TUninstallShortCuts.Execute(Callback: TActionCallback);
var
  I, J : Integer;
  DiskObject : TDiskObject;
  CurentPosition : Int64;
  ShortcutPath : string;
begin
  CurentPosition := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.ShortCuts.Count - 1 do
    begin
      Inc(CurentPosition, UnInstallPoints_ShortCut);
      ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Location);
      if StartsText('http', ShortcutPath) then
      begin
        DeleteFile(ShortcutPath);
        ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Name);
        DeleteFile(ShortcutPath);
        Continue;
      end;
      DeleteFile(ShortcutPath);
    end;
  end;
end;

{ TUninstallNotify }

function TUninstallNotify.CalculateTotalPoints: Int64;
begin
  Result := UninstallNotifyPoints_ShortCut;
end;

procedure TUninstallNotify.Execute(Callback: TActionCallback);
var
  NotifyUrl: string;
begin
  NotifyUrl := ResolveLanguageString(UnInstallNotifyURL) + '?v=' + ProductMajorVersionVersion + '&ac=' + TActivationManager.Instance.ApplicationCode;
  RunAsUser(NotifyUrl, NotifyUrl, NotifyUrl, False);
end;

{ TUninstallRegistry }

function TUninstallRegistry.CalculateTotalPoints: Int64;
begin
  Result := 5 * DeleteRegistryPoints;
end;

procedure TUninstallRegistry.Execute(Callback: TActionCallback);
var
  FReg: TRegistry;
  Terminated: Boolean;
begin
  Terminated := False;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_CLASSES_ROOT;
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
  end;
  FReg.Free;
  Callback(Self, 1 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_INSTALL;
    FReg.DeleteKey(RegRoot);
  except
  end;
  FReg.Free;
  Callback(Self, 2 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_USER_WORK;
    FReg.DeleteKey(RegRoot);
  except
  end;
  FReg.Free;
  Callback(Self, 3 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
  except
  end;
  FReg.Free;
  Callback(Self, 4 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
    FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.DeleteValue('PhotoDBgetPhotosHandler');
  except
  end;
  FReg.Free;
  Callback(Self, 5 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
end;

end.
