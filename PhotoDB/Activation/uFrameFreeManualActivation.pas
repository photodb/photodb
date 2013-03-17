unit uFrameFreeManualActivation;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Clipbrd,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  uInternetUtils,
  uFrameWizardBase,
  uConstants,
  uActivationUtils,
  uMemory;

type
  TFrameFreeManualActivation = class(TFrameWizardBase)
    LbManualActivationInfo: TLabel;
    MemInfo: TMemo;
    WlMail: TWebLink;
    procedure WlMailClick(Sender: TObject);
  private
    { Private declarations }
    FProgramStarted: Boolean;
  protected
    function GetCanGoNext: Boolean; override;
    procedure LoadLanguage; override;
  public
    { Public declarations }
    procedure Execute; override;
    procedure SendRegistrationEmail;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    function IsFinal: Boolean; override;
  end;

implementation

uses
  uFrameFreeActivation;

{$R *.dfm}

{ TFrameFreeManualActivation }

procedure TFrameFreeManualActivation.Execute;
begin
  inherited;
  if not FProgramStarted then
    SendRegistrationEmail;

  IsStepComplete := True;
  Changed;
end;

function TFrameFreeManualActivation.GetCanGoNext: Boolean;
begin
  Result := False;
end;

procedure TFrameFreeManualActivation.Init(Manager: TWizardManagerBase; FirstInitialization: Boolean);
var
  Step: TFrameFreeActivation;
begin
  inherited;
  MemInfo.Clear;

  Step := TFrameFreeActivation(Manager.GetStepByType(TFrameFreeActivation));
  MemInfo.Lines.Add(L('Program code') + ': ' + TActivationManager.Instance.ApplicationCode);
  MemInfo.Lines.Add(L('First name') + '(*): ' + Step.EdFirstName.Text);
  MemInfo.Lines.Add(L('Last name') + '(*): ' + Step.EdLastName.Text);
  MemInfo.Lines.Add(L('Phone') + ': ' + Step.EdPhone.Text);
  MemInfo.Lines.Add(L('Country') + ': ' + Step.EdCountry.Text);
  MemInfo.Lines.Add(L('City') + ': ' + Step.EdCity.Text);
  MemInfo.Lines.Add(L('Address') + ': ' + Step.EdAddress.Text);
  MemInfo.Lines.Add(L('(*) - required fields'));
end;

function TFrameFreeManualActivation.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrameFreeManualActivation.LoadLanguage;
begin
  inherited;
  WlMail.Text := ProgramMail;
  LbManualActivationInfo.Caption := L('To manually activate the program you need to send a letter with the following information to') + ':';
end;

procedure TFrameFreeManualActivation.SendRegistrationEmail;
var
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    SendEMail(Handle, ProgramMail, '', ProductName + ': REGISTRATION CODE = ' + TActivationManager.Instance.ApplicationCode, MemInfo.Text, Files);
  finally
    F(Files);
  end;
end;

procedure TFrameFreeManualActivation.WlMailClick(Sender: TObject);
begin
  inherited;
  FProgramStarted := True;
  SendRegistrationEmail;
end;

end.


