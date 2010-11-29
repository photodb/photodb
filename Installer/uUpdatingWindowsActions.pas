unit uUpdatingWindowsActions;

interface

uses
  ShellApi, ShlObj, uActions;

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
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSHNOWAIT or SHCNF_FLUSH or SHCNF_PATH, nil, nil);
  SHChangeNotify(SHCNE_UPDATEIMAGE, SHCNF_FLUSHNOWAIT or SHCNF_FLUSH or SHCNF_PATH, nil, nil);
  Callback(Self, InstallPoints_SystemInfo, InstallPoints_SystemInfo, Terminate);
end;

initialization

  TInstallManager.Instance.RegisterScope(TInstallUpdatingWindows);

end.
