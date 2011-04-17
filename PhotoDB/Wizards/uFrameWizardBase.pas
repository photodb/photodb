unit uFrameWizardBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uTranslate, uDBForm, uGOM;

type
  TFrameWizardBase = class;

  TFrameWizardBaseClass = class of TFrameWizardBase;

  TWizardManagerBase = class(TObject)
  private
    FOwner: TDBForm;
  protected
    function GetWizardDone: Boolean; virtual; abstract;
    function GetOperationInProgress: Boolean; virtual; abstract;
  public
    constructor Create(Owner: TDBForm);  virtual;
    procedure NextStep;  virtual; abstract;
    procedure NotifyChange; virtual; abstract;
    function GetStepByType(StepType: TFrameWizardBaseClass) : TFrameWizardBase; virtual; abstract;
    procedure AddStep(Step: TFrameWizardBaseClass); virtual; abstract;
    property WizardDone: Boolean read GetWizardDone;
    property Owner: TDBForm read FOwner;
    property OperationInProgress: Boolean read GetOperationInProgress;
    procedure BreakOperation; virtual; abstract;
  end;

  TFrameWizardBase = class(TFrame)
  private
    { Private declarations }
    FOnChange: TNotifyEvent;
    FManager: TWizardManagerBase;
    FIsBusy: Boolean;
    FIsStepComplete: Boolean;
  protected
    { Protected declarations }
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate, Scope: string): string; overload;
    procedure LoadLanguage; virtual;
    procedure Changed;
    function GetCanGoNext: Boolean; virtual;
    function GetOperationInProgress: Boolean; virtual;
    function LocalScope: string; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Execute; virtual;
    procedure InitNextStep; virtual;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); virtual;
    procedure Unload; virtual;
    function IsFinal: Boolean; virtual;
    function ValidateStep(Silent: Boolean): Boolean; virtual;
    procedure BreakOperation; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property IsBusy: Boolean read FIsBusy write FIsBusy;
    property IsStepComplete: Boolean read FIsStepComplete write FIsStepComplete;
    property Manager: TWizardManagerBase read FManager;
    property CanGoNext: Boolean read GetCanGoNext;
    property OperationInProgress: Boolean read GetOperationInProgress;
  end;

implementation

{$R *.dfm}

{ TFrameWizardBase }

procedure TFrameWizardBase.BreakOperation;
begin
  //do nothing
end;

procedure TFrameWizardBase.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TFrameWizardBase.Create(AOwner: TComponent);
begin
  inherited;
  FOnChange := nil;
end;

procedure TFrameWizardBase.Execute;
begin
  //write here logic to execute
end;

function TFrameWizardBase.GetCanGoNext: Boolean;
begin
  Result := True;
end;

function TFrameWizardBase.GetOperationInProgress: Boolean;
begin
  Result := False;
end;

procedure TFrameWizardBase.Init(Manager: TWizardManagerBase; FirstInitialization: Boolean);
begin
  //some init logic of step
  if FirstInitialization then
  begin
    GOM.AddObj(Self);
    FIsBusy := False;
    FIsStepComplete := False;
    FManager := Manager;
    TTranslateManager.Instance.BeginTranslate;
    try
      LoadLanguage;
    finally
      TTranslateManager.Instance.EndTranslate;
    end;
  end;
end;

procedure TFrameWizardBase.InitNextStep;
begin
  //insert here next step initialization
end;

function TFrameWizardBase.L(StringToTranslate: string): string;
begin
  Result := FManager.FOwner.L(StringToTranslate, LocalScope);
end;

function TFrameWizardBase.L(StringToTranslate, Scope: string): string;
begin
  Result := FManager.FOwner.L(StringToTranslate, Scope);
end;

function TFrameWizardBase.IsFinal: Boolean;
begin
  Result := False;
end;

procedure TFrameWizardBase.LoadLanguage;
begin
  //create here logic to load language
end;

function TFrameWizardBase.LocalScope: string;
begin
  Result := Manager.Owner.FormID;
end;

procedure TFrameWizardBase.Unload;
begin
   GOM.RemoveObj(Self);
end;

function TFrameWizardBase.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := True;
end;

{ TWizardManagerBase }

constructor TWizardManagerBase.Create(Owner: TDBForm);
begin
  FOwner := Owner;
end;

end.
