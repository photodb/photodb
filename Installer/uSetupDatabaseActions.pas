unit uSetupDatabaseActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows,
  uActions,
  SysUtils,
  uAssociations,
  uInstallScope,
  uConstants,
  uUserUtils;

const
  InstallPoints_StartProgram = 1024 * 1024;
  InstallPoints_SetUpDatabaseProgram = 1024 * 1024;

type
  TSetupDatabaseActions = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TSetupDatabaseActions }

function TSetupDatabaseActions.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_StartProgram + InstallPoints_SetUpDatabaseProgram;
end;

procedure TSetupDatabaseActions.Execute(Callback: TActionCallback);
var
  PhotoDBExeFile: string;
  Terminate: Boolean;
begin
  inherited;
  PhotoDBExeFile := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + PhotoDBFileName;

  RunAsUser(PhotoDBExeFile, '/install /NoLogo', CurrentInstall.DestinationPath, True);

  Callback(Self, InstallPoints_StartProgram + InstallPoints_SetUpDatabaseProgram, CalculateTotalPoints, Terminate);
end;


end.
