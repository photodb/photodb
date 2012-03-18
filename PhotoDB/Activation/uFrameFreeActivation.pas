unit uFrameFreeActivation;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  uFrameWizardBase,
  LoadingSign,
  uShellIntegration,
  uConstants,
  uActivationUtils,
  uLogger,
  Dolphin_DB, uBaseWinControl;

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
    procedure ActivateControls(IsActive: Boolean);
  public
    { Public declarations }
    function IsFinal: Boolean; override;
    procedure Execute; override;
    function InitNextStep: Boolean; override;
  end;

implementation

uses
  uInternetFreeActivationThread,
  uFrameFreeManualActivation;

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
  IsBusy := True;
  LbInternetQuery.Show;
  LsQuery.Show;
  ActivateControls(False);
  Info.Owner := Manager.Owner;
  Info.FirstName := EdFirstName.Text;
  Info.LastName := EdLastName.Text;
  Info.Email := EdEmail.Text;
  Info.Phone := EdPhone.Text;
  Info.Country := EdCountry.Text;
  Info.City := EdCity.Text;
  Info.Address := EdAddress.Text;
  Info.CallBack := RegistrationCallBack;
  TInternetFreeActivationThread.Create(Info);
  Changed;
end;

function TFrameFreeActivation.InitNextStep: Boolean;
begin
  Result := inherited;
  Manager.AddStep(TFrameFreeManualActivation);
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
  LbInternetQuery.Caption := L('Please wait until program completes the activation process...');
end;

procedure TFrameFreeActivation.RegistrationCallBack(Reply: string);
var
  IsDemo, FullMode: Boolean;
  Name: string;
  I: Integer;
begin
  LbInternetQuery.Hide;
  LsQuery.Hide;
  try

    for I := Length(Reply) downto 1 do
      if not CharInSet(Reply[I], ['0'..'9', 'A'..'Z', 'a'..'z'])  then
        Delete(Reply, I, 1);

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

    TActivationManager.Instance.CheckActivationCode(TActivationManager.Instance.ApplicationCode, Reply, IsDemo, FullMode);
    if not IsDemo then
    begin
      Name := Format('%s %s', [EdFirstName.Text, EdLastName.Text]);
      if TActivationManager.Instance.SaveActivateKey(Name, Reply, True) or TActivationManager.Instance.SaveActivateKey(Name, Reply, False) then
      begin
        MessageBoxDB(Handle, L('Thank you for activation the program!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
        DoDonate;
        IsStepComplete := True;
        Exit;
      end;
    end;

    EventLog('Invalid reply from server: ' + Reply);
    MessageBoxDB(Handle, L('Activation via internet failed! Please, check your internet connection settings in IE. Only manual activation is possible at this moment!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);

    IsBusy := False;
    Manager.NextStep;
  finally
    IsBusy := False;
    ActivateControls(True);
    Changed;
  end;
end;

end.
