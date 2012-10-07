unit uActivation;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,

  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,

  UnitINI,
  dolphin_db,

  uVistaFuncs,
  uActivationUtils,
  uShellIntegration,
  uRuntime,
  uDBForm,
  uMemory,
  uConstants,
  uWizards,
  uResources,
  uPNGUtils,
  uSettings,
  uMemoryEx,
  uThemesUtils,
  uVCLHelpers,
  uFormInterfaces;

type
  TActivateForm = class(TDBForm, IActivationForm)
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnFinish: TButton;
    BtnPrevious: TButton;
    ImActivationImage: TImage;
    LbInfo: TLabel;
    LsLoading: TLoadingSign;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Execute;
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FWizard: TWizardManager;
    procedure LoadLanguage;
    procedure UpdateLayout;
    procedure StepChanged(Sender: TObject);
    procedure WMMouseDown(var Message: TMessage); message WM_LBUTTONDOWN;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure HelpActivationNextClick(Sender: TObject);
    procedure HelpActivationCloseClick(Sender: TObject; var CanClose : Boolean);
  end;
                             
implementation

uses
  UnitHelp,
  FormManegerUnit,
  uFrameActivationLanding;

var
  IsActivationActive: Boolean = False;

{$R *.dfm}

procedure TActivateForm.FormCreate(Sender: TObject);
var
  Activation: TPngImage;
begin
  LoadLanguage;

  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  FWizard.AddStep(TFrameActivationLanding);
  FWizard.Start(Self, 190, 8);

  LsLoading.Color := Theme.WizardColor;
  Activation := GetActivationImage;
  try
    ImActivationImage.Picture.Graphic := Activation;
  finally
    F(Activation);
  end;

  UpdateLayout;
end;

procedure TActivateForm.FormDestroy(Sender: TObject);
begin
  F(FWizard);
end;

procedure TActivateForm.Execute;
begin
  if IsActivationActive then
    Exit;

  IsActivationActive := True;
  try
    ShowModal;
  finally
    IsActivationActive := False;
  end;
end;

procedure TActivateForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TActivateForm.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
end;

procedure TActivateForm.BtnNextClick(Sender: TObject);
begin
  if FWizard.CanGoNext then
    FWizard.NextStep;
end;

procedure TActivateForm.BtnPreviousClick(Sender: TObject);
begin
  if FWizard.CanGoBack then
    FWizard.PrevStep;
end;

procedure TActivateForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TActivateForm.WMMouseDown(var Message: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, Message.lparam);
end;

procedure TActivateForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Activation');
    LbInfo.Caption := L('This wizard helps you to activate this copy of application. Please fill all required fields and follow the instructions.');
    BtnCancel.Caption := L('Close');
    BtnPrevious.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    BtnFinish.Caption := L('Finish');
  finally
    EndTranslate;
  end;
end;

procedure TActivateForm.StepChanged(Sender: TObject);
begin
  LsLoading.Visible := FWizard.IsBusy;
  BtnCancel.SetEnabledEx(not FWizard.IsBusy);
  BtnNext.SetEnabledEx(FWizard.CanGoNext and not FWizard.IsBusy);
  BtnPrevious.SetEnabledEx(FWizard.CanGoBack);
  BtnFinish.SetEnabledEx(FWizard.IsFinalStep and not FWizard.IsBusy);

  BtnFinish.Visible := FWizard.IsFinalStep;
  BtnNext.Visible := not FWizard.IsFinalStep;

  if FWizard.WizardDone then
    Close;
end;

procedure TActivateForm.UpdateLayout;
var
  CW: Integer;
begin
  CW := ClientWidth;
  BtnFinish.Left := CW - BtnFinish.Width - 5;
  BtnNext.Left := CW - BtnFinish.Width - 5;
  BtnPrevious.Left := BtnFinish.Left - BtnPrevious.Width - 5;
  BtnCancel.Left := BtnPrevious.Left - BtnCancel.Width - 5;
  Bevel1.Width := ClientWidth - 10;
end;

procedure TActivateForm.HelpActivationCloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(GetActiveFormHandle, L('Do you really want to refuse help?', 'Help'), L('Confirm'), TD_BUTTON_OKCANCEL,
    TD_ICON_INFORMATION);
  if CanClose then
  begin
    HelpActivationNO := 0;
    Settings.WriteBool('HelpSystem', 'ActivationHelp', False);
  end;
end;

procedure TActivateForm.HelpActivationNextClick(Sender: TObject);
begin
  Inc(HelpActivationNO);
end;

procedure TActivateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UnRegisterMainForm(Self);
  Action := caFree;
end;

procedure TActivateForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not FWizard.IsBusy;
end;

procedure TActivateForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TActivateForm.GetFormID: string;
begin
  Result := 'Activation';
end;

initialization
  FormInterfaces.RegisterFormInterface(IActivationForm, TActivateForm);

end.
