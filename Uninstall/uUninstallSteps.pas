unit uUninstallSteps;

interface

uses
  uSteps;

type
  TUninstall_V2_3 = class(TInstallSteps)
  public
    constructor Create; override;
  end;

implementation

uses
  uFrUninstall;

{ TUninstall_V2_3 }

constructor TUninstall_V2_3.Create;
begin
  inherited;
  AddStep(TFrUninstall);
end;

end.
