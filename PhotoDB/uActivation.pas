unit uActivation;

interface

uses
  UnitINI, Searching, dolphin_db, UnitDBKernel, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, uVistaFuncs, uActivationUtils,
  Dialogs, StdCtrls, jpeg, ExtCtrls, uShellIntegration, uRuntime, uDBForm,
  uMemory, uConstants, uWizards;

type
  TActivateForm = class(TDBForm)
    EdProgramCode: TEdit;
    Label1: TLabel;
    EdActicationCode: TEdit;
    Label2: TLabel;
    Button2: TButton;
    EdUserName: TEdit;
    Label3: TLabel;
    Button3: TButton;
    HelpTimer: TTimer;
    HelpTimer2: TTimer;
    Bevel1: TBevel;
    BtnNext: TButton;
    BtnCancel: TButton;
    BtnFinish: TButton;
    BtnPrevious: TButton;
    Image1: TImage;
    LbInfo: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure execute;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure HelpTimerTimer(Sender: TObject);
    procedure HelpTimer2Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnFinishClick(Sender: TObject);
  private
    { Private declarations }
    FWizard: TWizardManager;
    procedure LoadLanguage;
    procedure StepChanged(Sender: TObject);
    procedure WMMouseDown(var Message : TMessage); message WM_LBUTTONDOWN;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure HelpActivationNextClick(Sender: TObject);
    procedure HelpActivationCloseClick(Sender : TObject; var CanClose : Boolean);
  end;

procedure ShowActivationDialog;

implementation

uses
  UnitHelp, FormManegerUnit, uFrameFreeActivation;

procedure ShowActivationDialog;
var
  ActivateForm: TActivateForm;
begin
  if not FolderView then
  begin
    Application.CreateForm(TActivateForm, ActivateForm);
    try
      ActivateForm.Execute;
    finally
      R(ActivateForm);
    end;
  end;
end;

{$R *.dfm}

procedure TActivateForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;

  FWizard := TWizardManager.Create(Self);
  FWizard.OnChange := StepChanged;
  if TActivationManager.Instance.CanUseFreeActivation then
  begin
    FWizard.AddStep(TFrameFreeActivation);
  end;

  FWizard.Start(Self, 183, 8);
 { if not FolderView then
  begin
    EdProgramCode.Text := TActivationManager.Instance.ApplicationCode;

    if not TActivationManager.Instance.IsDemoMode then
    begin
      EdActicationCode.Text := TActivationManager.Instance.ActivationKey;
      EdUserName.Text := TActivationManager.Instance.ActivationUserName;
    end;
  end; }
end;

procedure TActivateForm.FormDestroy(Sender: TObject);
begin
  F(FWizard);
end;

procedure TActivateForm.Button2Click(Sender: TObject);
begin
  if TActivationManager.Instance.SaveActivateKey(EdUserName.Text, EdActicationCode.Text, False) then
    MessageBoxDB(Handle, L('Activation key saved! Please restart the application!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);

  Close;
end;

procedure TActivateForm.Execute;
begin
  ShowModal;
end;

procedure TActivateForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TActivateForm.BtnFinishClick(Sender: TObject);
begin
  FWizard.Execute;
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
    BtnCancel.Caption := L('Cancel');
    BtnPrevious.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    BtnFinish.Caption := L('Finish');
{     Label1.Caption := L('Program code') + ':';
   Label2.Caption := L('Enter here activation key') + ':';
    Label3.Caption := L('User name');
    Button1.Caption := L('Cancel');
    Button2.Caption := L('Install code');
    Button3.Caption := L('Get personal code'); }
  finally
    EndTranslate;
  end;
end;

procedure TActivateForm.StepChanged(Sender: TObject);
begin
  //
end;

procedure TActivateForm.Button3Click(Sender: TObject);
begin
  DoGetCode(EdProgramCode.Text);
  if HelpActivationNO = 4 then
  begin
    HelpTimer2.Enabled := True;
  end;
end;

procedure TActivateForm.HelpTimerTimer(Sender: TObject);
var
  HelpMessage: string;
begin
  HelpMessage := '     ' + L('Click the "Get code" and then start mail program with a new letter in the title of which is given all the necessary information to activate. $nl$You need send this letter or (if the mailer does not run) ' + 'Send by email to %email%, in which you want to specify the code of the program and its version.' + '$nl$     Press "Next ..." for further assistance.' + '$nl$    Or click on the cross at the top to help is no longer displayed. $nl$$nl$$nl$$nl$', 'Help');
  HelpMessage := StringReplace(HelpMessage, '%email%', ProgramMail, []);
  HelpTimer.Enabled := False;
  if TActivationManager.Instance.IsDemoMode then
    if HelpActivationNO = 3 then
      DoHelpHintCallBackOnCanClose(L('Help', 'Help'), HelpMessage, Point(0, 0), Button3,
        HelpActivationNextClick, L('Next...'), HelpActivationCloseClick);
end;

procedure TActivateForm.HelpActivationCloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(GetActiveFormHandle, L('Do you really want to refuse help?', 'Help'), L('Confirm'), TD_BUTTON_OKCANCEL,
    TD_ICON_INFORMATION);
  if CanClose then
  begin
    HelpActivationNO := 0;
    DBKernel.WriteBool('HelpSystem', 'ActivationHelp', False);
  end;
end;

procedure TActivateForm.HelpActivationNextClick(Sender: TObject);
begin
  Inc(HelpActivationNO);
end;

procedure TActivateForm.HelpTimer2Timer(Sender: TObject);
var
  HelpMessage: string;
begin
  if not Active then
    Exit;
  HelpTimer2.Enabled := False;
  HelpMessage := '     ' + L('During the day we will send you an activation code that you shoulf enter into this box and click on "Install code...". After that the program will be activated.$nl$$nl$', 'Help');
  DoHelpHint(L('Help', 'Help'), HelpMessage, Point(0, 0), EdActicationCode);
  HelpActivationNO := 0;
  DBKernel.WriteBool('HelpSystem', 'ActivationHelp', False);
end;

procedure TActivateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormManager.UnRegisterMainForm(Self);
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

end.
