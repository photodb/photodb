unit uInstallSteps;

interface

uses
  Classes,
  uMemory,
  Controls,
  uSteps;

type

  TFreshInstall = class(TInstallSteps)
  public
    constructor Create; override;
  end;

  TUpdatePreviousVersion = class(TInstallSteps)
  public
    constructor Create; override;
  end;

implementation

uses
  uFrLicense, uFrAdvancedOptions;

{ TFreshInstall }

constructor TFreshInstall.Create;
begin
  inherited;
  AddStep(TFrLicense);
  AddStep(TFrAdvancedOptions);
end;

{ TUpdatePreviousVersion }

constructor TUpdatePreviousVersion.Create;
begin
  inherited;
  AddStep(TFrLicense);
  AddStep(TFrAdvancedOptions);
end;

end.
