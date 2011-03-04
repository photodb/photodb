unit uWizards;

interface

uses
  Classes, Controls, uMemory, uFrameWizardBase, uDBForm;

type
  TWizardManager = class(TWizardManagerBase)
  private
    FStepTypes: TList;
    FSteps: TList;
    FOwner: TWinControl;
    FX, FY: Integer;
    FCurrentStep : Integer;
    FOnChange : TNotifyEvent;
    function GetStepByIndex(Index: Integer): TFrameWizardBase;
    procedure Changed;
    procedure OnStepChanged(Sender : TObject);
    function GetCount: Integer;
  public
    constructor Create(Owner: TDBForm); override;
    destructor Destroy; override;
    procedure UpdateCurrentStep;
    procedure AddStep(Step: TFrameWizardBaseClass);
    procedure Execute;
    procedure Start(Owner: TWinControl; X, Y: Integer);
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
    property Steps[Index : Integer] : TFrameWizardBase read GetStepByIndex; default;
    property Count: Integer read GetCount;
    property CurrentStep: Integer read FCurrentStep;
  end;

implementation

{ TWizardManager }

procedure TWizardManager.AddStep(Step: TFrameWizardBaseClass);
begin
  FStepTypes.Add(Step);
end;

procedure TWizardManager.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TWizardManager.Create(Owner: TDBForm);
begin
  inherited Create(Owner);
  FStepTypes := TList.Create;
  FSteps := TList.Create;
  FOwner := nil;
  FOnChange := nil;
  FCurrentStep := -1;
  FX := 0;
  FY := 0;
end;

destructor TWizardManager.Destroy;
begin
  FreeList(FSteps);
  F(FStepTypes);
  inherited;
end;

procedure TWizardManager.Execute;
begin
  Steps[CurrentStep].Execute;
end;

function TWizardManager.GetCount: Integer;
begin
  Result := FSteps.Count;
end;

function TWizardManager.GetStepByIndex(Index: Integer): TFrameWizardBase;
begin
  Result := FSteps[Index];
end;

procedure TWizardManager.OnStepChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

procedure TWizardManager.Start(Owner: TWinControl; X, Y: Integer);
var
  I : Integer;
  Frame : TFrameWizardBase;
begin
  FOwner := Owner;
  FX := X;
  FY := Y;
  for I := 0 to FStepTypes.Count - 1 do
  begin
    Frame := TFrameWizardBaseClass(FStepTypes[I]).Create(Owner);
    Frame.Parent := Owner;
    Frame.Left := X;
    Frame.Top := Y;
    Frame.Visible := False;
    Frame.Init(Self);
    Frame.OnChange := OnStepChanged;
    FSteps.Add(Frame);
  end;
  FCurrentStep := 0;
  Changed;
  UpdateCurrentStep;
end;

procedure TWizardManager.UpdateCurrentStep;
var
  I : Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (I <> FCurrentStep) and Steps[I].Visible then
      Steps[I].Hide;

    Steps[CurrentStep].Show;
  end;
end;

end.
