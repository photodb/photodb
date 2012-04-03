unit uSteps;

interface

uses
  Classes,
  uMemory,
  Controls,
  uInstallFrame;

type

  TInstallStep = class(TObject)

  end;

  TInstallSteps = class(TObject)
  private
    FStepTypes: TList;
    FX, FY: Integer;
    FOwner: TWinControl;
    FSteps: TList;
    FOnChange: TNotifyEvent;
    FCurrentStep: Integer;
    function GetStepByIndex(Index: Integer): TInstallFrame;
    function GetCount: Integer;
    function GetCanInstall: Boolean;
    function GetCanNext: Boolean;
    function GetCanPrevious: Boolean;
    function GetCurrentStep: Integer;
    procedure UpdateCurrentStep;
    procedure Changed;
    procedure OnStepChanged(Sender : TObject);
  protected
    procedure AddStep(Step : TInstallFrameClass);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Start(Owner: TWinControl; X, Y: Integer);
    procedure NextStep;
    procedure PreviousStep;
    procedure PrepaireInstall;
    property Steps[Index: Integer]: TInstallFrame read GetStepByIndex; default;
    property Count: Integer read GetCount;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property CanInstall: Boolean read GetCanInstall;
    property CurrentStep: Integer read GetCurrentStep;
    property CanNext: Boolean read GetCanNext;
    property CanPrevious: Boolean read GetCanPrevious;
  end;

implementation

{ TInstallSteps }

procedure TInstallSteps.AddStep(Step: TInstallFrameClass);
begin
  FStepTypes.Add(Step);
end;

procedure TInstallSteps.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TInstallSteps.Create;
begin
  FOnChange := nil;
  FStepTypes := TList.Create;
  FSteps := TList.Create;
  FCurrentStep := 0;
end;

destructor TInstallSteps.Destroy;
begin
  F(FStepTypes);
  FreeList(FSteps);
  inherited;
end;

function TInstallSteps.GetCanInstall: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if not Steps[I].ValidateFrame then
      Exit;

  Result := True;
end;

function TInstallSteps.GetCanNext: Boolean;
begin
  Result := (CurrentStep < Count - 1) and Steps[CurrentStep].ValidateFrame;
end;

function TInstallSteps.GetCanPrevious: Boolean;
begin
  Result := CurrentStep  > 0;
end;

function TInstallSteps.GetCount: Integer;
begin
  Result := FSteps.Count;
end;

function TInstallSteps.GetCurrentStep: Integer;
begin
  Result := FCurrentStep;
end;

function TInstallSteps.GetStepByIndex(Index: Integer): TInstallFrame;
begin
  Result := FSteps[Index];
end;

procedure TInstallSteps.NextStep;
begin
  if CanNext then
  begin
    Inc(FCurrentStep);
    UpdateCurrentStep;
    Changed;
  end;
end;

procedure TInstallSteps.OnStepChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

procedure TInstallSteps.PrepaireInstall;
var
  I : Integer;
begin
  for I := 0 to Count - 1 do
    Steps[I].InitInstall;
end;

procedure TInstallSteps.PreviousStep;
begin
  if CanPrevious then
  begin
    Dec(FCurrentStep);
    UpdateCurrentStep;
    Changed;
  end;
end;

procedure TInstallSteps.Start(Owner: TWinControl; X, Y: Integer);
var
  I: Integer;
  Frame: TInstallFrame;
begin
  FOwner := Owner;
  FX := X;
  FY := Y;
  for I := 0 to FStepTypes.Count - 1 do
  begin
    Frame := TInstallFrameClass(FStepTypes[I]).Create(Owner);
    Frame.Parent := Owner;
    Frame.Left := X;
    Frame.Top := Y;
    Frame.Visible := False;
    Frame.Init;
    Frame.OnChange := OnStepChanged;
    FSteps.Add(Frame);
  end;
  Changed;
  UpdateCurrentStep;
end;

procedure TInstallSteps.UpdateCurrentStep;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (I <> FCurrentStep) and Steps[I].Visible then
      Steps[I].Hide;

    Steps[CurrentStep].Show;
  end;
end;

end.
