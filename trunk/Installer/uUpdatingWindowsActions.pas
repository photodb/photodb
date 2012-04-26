unit uUpdatingWindowsActions;

interface

uses
  uActions,
  uShellUtils;

const
  InstallPoints_SystemInfo = 1024 * 1024;

type
  TInstallUpdatingWindows = class(TInstallAction)
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TInstallUpdatingWindows }

function TInstallUpdatingWindows.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_SystemInfo;
end;

procedure TInstallUpdatingWindows.Execute(Callback: TActionCallback);
var
  Terminate : Boolean;
begin
  RefreshSystemIconCache;
  Callback(Self, InstallPoints_SystemInfo, InstallPoints_SystemInfo, Terminate);
end;

end.
