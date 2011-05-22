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
    FCurrentStep: Integer;
    FOnChange: TNotifyEvent;
    FStepCreation: Boolean;
    function GetStepByIndex(Index: Integer): TFrameWizardBase;
    procedure Changed;
    procedure OnStepChanged(Sender : TObject);
    function GetCount: Integer;
    function GetCanGoBack: Boolean;
    function GetCanGoNext: Boolean;
    function GetIsFinalStep: Boolean;
    function GetIsBusy: Boolean;
    procedure AddStepInstance(StepType: TFrameWizardBaseClass);
    function GetIsPaused: Boolean;
  protected
    function GetWizardDone: Boolean; override;
    function GetOperationInProgress: Boolean; override;
  public
    constructor Create(Owner: TDBForm); override;
    destructor Destroy; override;
    procedure NextStep; override;
    procedure PrevStep; override;
    procedure UpdateCurrentStep;
    procedure AddStep(Step: TFrameWizardBaseClass); override;
    function GetStepByType(StepType: TFrameWizardBaseClass) : TFrameWizardBase; override;
    procedure Execute;
    procedure Start(Owner: TWinControl; X, Y: Integer);
    procedure Pause(Value: Boolean); override;
    procedure BreakOperation; override;
    procedure NotifyChange; override;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
    property Steps[Index : Integer] : TFrameWizardBase read GetStepByIndex; default;
    property Count: Integer read GetCount;
    property CurrentStep: Integer read FCurrentStep;
    property IsBusy: Boolean read GetIsBusy;
    property CanGoBack: Boolean read GetCanGoBack;
    property CanGoNext: Boolean read GetCanGoNext;
    property IsFinalStep: Boolean read GetIsFinalStep;
    property IsPaused: Boolean read GetIsPaused;
  end;

implementation

{ TWizardManager }

procedure TWizardManager.NextStep;
begin
  if CanGoNext and Steps[CurrentStep].ValidateStep(False) then
  begin
    if Steps[CurrentStep].InitNextStep then
    begin
      Inc(FCurrentStep);
      UpdateCurrentStep;
      Changed;
    end;
  end;
end;

procedure TWizardManager.NotifyChange;
begin
  Changed;
end;

procedure TWizardManager.AddStep(Step: TFrameWizardBaseClass);
var
  I: Integer;
begin
  if FCurrentStep = Count - 1 then
  begin
    FStepTypes.Add(Step);

    //if wizard is working then activate new step
    if FOwner <> nil then
      AddStepInstance(Step);
  end else
  begin
    if FStepTypes[FCurrentStep + 1] = Step then
      Exit
    else begin
      for I := FCurrentStep + 1 to Count - 1 do
      begin
        FStepTypes.Delete(I);
        TFrameWizardBase(FSteps[I]).Unload;
        TFrameWizardBase(FSteps[I]).Free;
        FSteps.Delete(I);
      end;
      FStepTypes.Add(Step);
      AddStepInstance(Step);
    end;
  end;
end;

procedure TWizardManager.AddStepInstance(StepType: TFrameWizardBaseClass);
var
  Frame : TFrameWizardBase;
begin
  FStepCreation := True;
  Changed;
  try
    Frame := StepType.Create(FOwner);
    Frame.Parent := FOwner;
    Frame.Left := FX;
    Frame.Top := FY;
    Frame.Visible := False;
    Frame.Init(Self, True);
    Frame.OnChange := OnStepChanged;
    FSteps.Add(Frame);
  finally
    FStepCreation := False;
    Changed;
  end;
end;

procedure TWizardManager.BreakOperation;
begin
  inherited;
  Steps[CurrentStep].BreakOperation;
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
  FStepCreation := False;
end;

destructor TWizardManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to FSteps.Count - 1 do
  begin
    Steps[I].Unload;
    Steps[I].Free;
  end;
  F(FSteps);
  F(FStepTypes);
  inherited;
end;

procedure TWizardManager.Execute;
begin
  Steps[CurrentStep].Execute;
end;

function TWizardManager.GetCanGoBack: Boolean;
begin
  Result := (CurrentStep > 0) and not IsBusy and not OperationInProgress;
end;

function TWizardManager.GetCanGoNext: Boolean;
begin
  if CurrentStep = -1 then
  begin
    Result := False;
    Exit;
  end;

  Result := Steps[CurrentStep].CanGoNext and Steps[CurrentStep].ValidateStep(True) and not IsBusy and not OperationInProgress;
end;

function TWizardManager.GetCount: Integer;
begin
  Result := FSteps.Count;
end;

function TWizardManager.GetIsBusy: Boolean;
begin
  if CurrentStep = -1 then
  begin
    Result := True;
    Exit;
  end;
  Result := FStepCreation or Steps[CurrentStep].IsBusy;
end;

function TWizardManager.GetIsFinalStep: Boolean;
begin
  if CurrentStep = -1 then
  begin
    Result := False;
    Exit;
  end;

  Result := Steps[CurrentStep].IsFinal;
end;

function TWizardManager.GetIsPaused: Boolean;
begin
  Result := Steps[CurrentStep].IsPaused;
end;

function TWizardManager.GetOperationInProgress: Boolean;
begin
  Result := Steps[CurrentStep].OperationInProgress;
end;

function TWizardManager.GetStepByIndex(Index: Integer): TFrameWizardBase;
begin
  Result := FSteps[Index];
end;

function TWizardManager.GetStepByType(
  StepType: TFrameWizardBaseClass): TFrameWizardBase;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Steps[I] is StepType then
    begin
      Result := Steps[I];
      Exit;
    end;
end;

function TWizardManager.GetWizardDone: Boolean;
begin
  if CurrentStep = -1 then
  begin
    Result := False;
    Exit;
  end;

  Result := Steps[CurrentStep].IsFinal and Steps[CurrentStep].IsStepComplete;
end;

procedure TWizardManager.OnStepChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

procedure TWizardManager.Pause(Value: Boolean);
begin
  Steps[CurrentStep].Pause(Value);
end;

procedure TWizardManager.PrevStep;
begin
  if CanGoBack then
  begin
    Dec(FCurrentStep);
    UpdateCurrentStep;
    Changed;
  end;
end;

procedure TWizardManager.Start(Owner: TWinControl; X, Y: Integer);
var
  I : Integer;
begin
  FOwner := Owner;
  FX := X;
  FY := Y;
  for I := 0 to FStepTypes.Count - 1 do
    AddStepInstance(TFrameWizardBaseClass(FStepTypes[I]));

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

    Steps[CurrentStep].IsBusy := False;
    Steps[CurrentStep].Init(Self, False);
    Steps[CurrentStep].Show;
  end;
end;

end.
