unit uFrameFreeActivation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uFrameWizardBase, LoadingSign, uShellIntegration,
  uConstants, uActivationUtils, uLogger;

type
  TFrameFreeActivation = class(TFrameWizardBase)
    EdFirstName: TLabeledEdit;
    EdLastName: TLabeledEdit;
    EdEmail: TLabeledEdit;
    EdPhone: TLabeledEdit;
    EdCountry: TLabeledEdit;
    EdCity: TLabeledEdit;
    EdAddress: TLabeledEdit;
    LsQuery: TLoadingSign;
    LbInternetQuery: TLabel;
  private
    { Private declarations }
    procedure RegistrationCallBack(Reply: string);
  protected
    procedure LoadLanguage; override;
    function IsFinal: Boolean; override;
    procedure ActivateControls(IsActive: Boolean);
  public
    { Public declarations }
    procedure Execute; override;
  end;

implementation

uses
  uInternetFreeActivationThread;

{$R *.dfm}

{ TFrameFreeActivation }

procedure TFrameFreeActivation.ActivateControls(IsActive: Boolean);
begin
  EdFirstName.Enabled := IsActive;
  EdLastName.Enabled := IsActive;
  EdEmail.Enabled := IsActive;
  EdPhone.Enabled := IsActive;
  EdCountry.Enabled := IsActive;
  EdCity.Enabled := IsActive;
  EdAddress.Enabled := IsActive;
end;

procedure TFrameFreeActivation.Execute;
var
  Info: InternetActivationInfo;
begin
  inherited;
  LbInternetQuery.Show;
  LsQuery.Show;
  ActivateControls(False);
  Info.Owner := Self;
  Info.FirstName := EdFirstName.Text;
  Info.LastName := EdLastName.Text;
  Info.Email := EdEmail.Text;
  Info.Phone := EdPhone.Text;
  Info.Country := EdCountry.Text;
  Info.City := EdCity.Text;
  Info.Address := EdAddress.Text;
  Info.CallBack := RegistrationCallBack;
  TInternetFreeActivationThread.Create(Info);
  Changeed;
end;

function TFrameFreeActivation.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrameFreeActivation.LoadLanguage;
begin
  inherited;
  EdFirstName.EditLabel.Caption := L('First name') + ':';
  EdLastName.EditLabel.Caption := L('Last name') + ':';
  EdEmail.EditLabel.Caption := L('E-mail') + ':';
  EdPhone.EditLabel.Caption := L('Phone') + ':';
  EdCountry.EditLabel.Caption := L('Country') + ':';
  EdCity.EditLabel.Caption := L('City') + ':';
  EdAddress.EditLabel.Caption := L('Address') + ':';
end;

procedure TFrameFreeActivation.RegistrationCallBack(Reply: string);
var
  IsDemo, FullMode: Boolean;
  Name, Code: string;
  I: Integer;
begin
  LbInternetQuery.Hide;
  LsQuery.Hide;
  ActivateControls(True);

  if Reply = 'fn' then
  begin
    MessageBoxDB(Handle, Format(L('Field "%s" is required!'), [L('First name')]), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if Reply = 'ln' then
  begin
    MessageBoxDB(Handle, Format(L('Field "%s" is required!'), [L('Last name')]), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;
  if Reply = 'e' then
  begin
    MessageBoxDB(Handle, Format(L('Field "%s" is required and should be well-formatted!'), [L('E-mail')]), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  Code := Reply;
  for I := Length(Code) downto 1 do
    if not CharInSet(Code[I], ['0'..'9', 'A'..'F'])  then
      Delete(Code, I, 1);

  TActivationManager.Instance.CheckActivationCode(TActivationManager.Instance.ApplicationCode, Code, IsDemo, FullMode);
  if not IsDemo then
  begin
    Name := Format('%s %s', [EdFirstName.Text, EdLastName.Text]);
    if TActivationManager.Instance.SaveActivateKey(Name, Code, True) or TActivationManager.Instance.SaveActivateKey(Name, Code, False) then
    begin
      MessageBoxDB(Handle, L('Thank you for activation the program!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
      //TODO: close the dialog
    end;
  end;

  EventLog('Invalid reply from server: ' + Reply);
  //TODO: manual activation
end;

end.
