unit uFrameActicationSetCode;

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
  uFrameWizardBase,
  ExtCtrls,
  StdCtrls,
  uActivationUtils,
  uRuntime,
  uShellIntegration,
  uConstants;

type
  TFrameActicationSetCode = class(TFrameWizardBase)
    EdActivationName: TLabeledEdit;
    EdActivationCode: TLabeledEdit;
    EdApplicationCode: TLabeledEdit;
  private
    { Private declarations }
  protected
    procedure LoadLanguage; override;
    function GetCanGoNext: Boolean; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    function IsFinal: Boolean; override;
    procedure Execute; override;
  end;

implementation

{$R *.dfm}

{ TFrameActicationSetCode }

procedure TFrameActicationSetCode.Execute;
begin
  inherited;
  if TActivationManager.Instance.SaveActivateKey(EdActivationName.Text, EdActivationCode.Text, False) then
    MessageBoxDB(Handle, L('Activation key saved! Please restart the application!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);

  IsStepComplete := True;
  Changed;
end;

function TFrameActicationSetCode.GetCanGoNext: Boolean;
begin
  Result := False;
end;

procedure TFrameActicationSetCode.Init(Manager: TWizardManagerBase; FirstInitialization: Boolean);
begin
  inherited;
  if not FolderView and FirstInitialization then
  begin
    EdApplicationCode.Text := TActivationManager.Instance.ApplicationCode;

    if not TActivationManager.Instance.IsDemoMode then
    begin
      EdActivationCode.Text := TActivationManager.Instance.ActivationKey;
      EdActivationName.Text := TActivationManager.Instance.ActivationUserName;
    end;
  end;
end;

function TFrameActicationSetCode.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrameActicationSetCode.LoadLanguage;
begin
  inherited;
  EdApplicationCode.EditLabel.Caption := L('Program code') + ':';
  EdActivationCode.EditLabel.Caption := L('Enter here activation key') + ':';
  EdActivationName.EditLabel.Caption := L('User name') + ':';
end;

end.
