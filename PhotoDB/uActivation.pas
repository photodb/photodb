unit uActivation;

interface

uses
  UnitINI, Searching, dolphin_db, UnitDBKernel, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, uVistaFuncs, uActivationUtils,
  Dialogs, StdCtrls, jpeg, ExtCtrls, uShellIntegration, uRuntime, uDBForm,
  uMemory, uConstants;

type
  TActivateForm = class(TDBForm)
    EdProgramCode: TEdit;
    Label1: TLabel;
    EdActicationCode: TEdit;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    EdUserName: TEdit;
    Label3: TLabel;
    Image1: TImage;
    Button3: TButton;
    HelpTimer: TTimer;
    HelpTimer2: TTimer;
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
  private
    { Private declarations }
    Hs, Nm : string;
    procedure LoadLanguage;
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
  UnitHelp, FormManegerUnit;

procedure ShowActivationDialog;
var
  ActivateForm: TActivateForm;
begin
  Application.CreateForm(TActivateForm, ActivateForm);
  try
    ActivateForm.Execute;
  finally
    R(ActivateForm);
  end;
end;

{$R *.dfm}

procedure TActivateForm.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  Hs := DBKernel.ReadActivateKey;
  if not FolderView then
    Nm := DBKernel.ReadRegName;
  EdProgramCode.Text := DBKernel.ApplicationCode;

  if not FolderView then
    if not DBKernel.ProgramInDemoMode then
    begin
      EdActicationCode.Text := DBKernel.ReadActivateKey;
      EdUserName.Text := DBKernel.ReadRegName;
    end;
end;

procedure TActivateForm.Button2Click(Sender: TObject);
var
  Reg : TBDRegistry;
begin
  if FolderView then
    Exit;
  Nm := EdUserName.Text;
  Hs := EdActicationCode.Text;
  Reg := TBDRegistry.Create(REGISTRY_CLASSES);
  try
    Reg.OpenKey('\CLSID\' + ActivationID, True);
    Reg.WriteString('UserName', Nm);
    Reg.WriteString('Code', Hs);
  finally
    F(Reg);
  end;
  MessageBoxDB(Handle, L('Activation key saved! Please restart the application!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
  Close;
end;

procedure TActivateForm.Execute;
begin
  ShowModal;
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
    Label1.Caption := L('Program code') + ':';
    Label2.Caption := L('Enter here activation key') + ':';
    Label3.Caption := L('User name');
    Button1.Caption := L('Cancel');
    Button2.Caption := L('Install code');
    Caption := L('Activation');
    Button3.Caption := L('Get personal code');
  finally
    EndTranslate;
  end;
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
  HelpMessage := '     Click the "Get code" and then start mail program with a new letter in the title of which is given all the necessary information to activate. $nl$You need send this letter or (if the mailer does not run)' + 'Send by email to %email%, in which you want to specify the code of the program and its version.' + '$nl$     Press "Next ..." for further assistance.' + '$nl$    Or click on the cross at the top to help is no longer displayed. $nl$$nl$$nl$$nl$';
  HelpMessage := StringReplace(HelpMessage, '%email%', ProgramMail, []);
  HelpTimer.Enabled := False;
  if DBkernel.GetDemoMode then
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
  HelpMessage := L('During the day we will send you an activation code that you shoulf enter into this box and click on "Install code...". After that the program will be activated.$nl$$nl$');
  DoHelpHint(L('Help', 'Help'), HelpMessage, Point(0, 0), EdActicationCode);
  HelpActivationNO := 0;
  DBKernel.WriteBool('HelpSystem', 'ActivationHelp', False);
end;

procedure TActivateForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if not FolderView then
    DBKernel.SetActivateKey(Nm, Hs);
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
