unit uUninstallCurrentUser;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.SysUtils,
  Winapi.Windows,
  uActions,
  uAssociations,
  uInstallScope,
  uConstants,
  uUserUtils;

const
  UnInstallPoints_StartProgram = 1024 * 1024;

type
  TUninstallUserSettingsAction = class(TInstallAction)
  public
    function CalculateTotalPoints: Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

implementation

{ TUninstallUserSettingsAction }

function TUninstallUserSettingsAction.CalculateTotalPoints: Int64;
begin
  Result := UnInstallPoints_StartProgram;
end;

procedure TUninstallUserSettingsAction.Execute(Callback: TActionCallback);
var
  PhotoDBExeFile: string;
  UninstallParameters: string;
  Terminate: Boolean;
begin
  inherited;
  PhotoDBExeFile := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + PhotoDBFileName;

  if CurrentInstall.UninstallOptions.DeleteUserSettings then
    UninstallParameters := UninstallParameters + ' /uninstall_settings';
  if CurrentInstall.UninstallOptions.DeleteAllCollections then
    UninstallParameters := UninstallParameters + ' /uninstall_collections';

  RunAsUser(PhotoDBExeFile, '/uninstall /NoLogo' + UninstallParameters, CurrentInstall.DestinationPath, True);

  Callback(Self, UnInstallPoints_StartProgram, CalculateTotalPoints, Terminate);
end;


end.
