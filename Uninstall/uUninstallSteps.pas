unit uUninstallSteps;

interface

uses
  uSteps;

type
  TUninstall_V3_X = class(TInstallSteps)
  public
    constructor Create; override;
  end;

implementation

uses
  uFrUninstall;

{ TUninstall_V3_X }

constructor TUninstall_V3_X.Create;
begin
  inherited;
  AddStep(TFrUninstall);
end;

end.
