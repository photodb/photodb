unit uFrameWizardBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uTranslate, uDBForm, uGOM;

type
  TFrameWizardBase = class;

  TWizardManagerBase = class(TObject)
  private
    FOwner: TDBForm;
  public
    constructor Create(Owner: TDBForm);  virtual;
  end;

  TFrameWizardBase = class(TFrame)
  private
    { Private declarations }
    FOnChange: TNotifyEvent;
    FManager: TWizardManagerBase;
  protected
    function L(StringToTranslate: string): string; overload;
    function L(StringToTranslate, Scope: string): string; overload;
    procedure LoadLanguage; virtual;
    function IsFinal: Boolean; virtual;
    procedure Changeed;
  public
    { Public declarations }
    procedure Execute; virtual;
    procedure Init(Manager: TWizardManagerBase); virtual;
    procedure Unload; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Manager: TWizardManagerBase read FManager;
  end;

  TFrameWizardBaseClass = class of TFrameWizardBase;

implementation

{$R *.dfm}

{ TFrameWizardBase }

procedure TFrameWizardBase.Changeed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TFrameWizardBase.Execute;
begin
  //cwrite here logic to execute
end;

procedure TFrameWizardBase.Init(Manager: TWizardManagerBase);
begin
  //some init logic of step
  GOM.AddObj(Self);
  FOnChange := nil;
  FManager := Manager;
  TTranslateManager.Instance.BeginTranslate;
  try
    LoadLanguage;
  finally
    TTranslateManager.Instance.EndTranslate;
  end;
end;

function TFrameWizardBase.L(StringToTranslate: string): string;
begin
  Result := FManager.FOwner.L(StringToTranslate);
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

procedure TFrameWizardBase.Unload;
begin
   GOM.RemoveObj(Self);
end;

{ TWizardManagerBase }

constructor TWizardManagerBase.Create(Owner: TDBForm);
begin
  FOwner := Owner;
end;

end.
