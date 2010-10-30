unit AddSessionPasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, FormManegerUnit, StdCtrls, Language, WatermarkedEdit,
  uVistaFuncs, uDBForm;

type
  TAddSessionPasswordForm = class(TDBForm)
    BtnCancel: TButton;
    BtnOk: TButton;
    LbInfoPassword: TLabel;
    LbPasswordConfirm: TLabel;
    EdPassword: TWatermarkedEdit;
    EdPasswordConfirm: TWatermarkedEdit;
    CbShowPassword: TCheckBox;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure CbShowPasswordClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLnguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    Password : String;
  end;

procedure AddSessionPassword;

implementation

{$R *.dfm}

procedure AddSessionPassword;
var
  AddSessionPasswordForm: TAddSessionPasswordForm;
begin
  Application.CreateForm(TAddSessionPasswordForm, AddSessionPasswordForm);
  try
    AddSessionPasswordForm.ShowModal;
  finally
    AddSessionPasswordForm.Release;
  end;
end;

procedure TAddSessionPasswordForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TAddSessionPasswordForm.BtnOkClick(Sender: TObject);
begin
  if EdPassword.Text = '' then
    Exit;
  if CbShowPassword.Checked then
  begin
    Password := EdPassword.Text;
    DBKernel.AddTemporaryPasswordInSession(Password);
    Close;
  end else
  begin
    if EdPassword.Text = EdPasswordConfirm.Text then
    begin
      Password := EdPassword.Text;
      DBKernel.AddTemporaryPasswordInSession(Password);
      Close;
    end else
      MessageBoxDB(Handle, L('Password and password confirm don''t match'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);

  end;
end;

procedure TAddSessionPasswordForm.EdPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    BtnOkClick(Sender);
  end;
end;

function TAddSessionPasswordForm.GetFormID: string;
begin
  Result := 'Password';
end;

procedure TAddSessionPasswordForm.LoadLnguage;
begin
  BeginTranslate;
  try
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    CbShowPassword.Caption := L('Show password');
    LbInfoPassword.Caption := L('Enter password form image here') + ':';
    EdPassword.WatermarkText := L('Enter password here');
    LbPasswordConfirm.Caption := L('Enter password confirm here') + ':';
    EdPasswordConfirm.WatermarkText := L('Password confirm');
  finally
    EndTranslate;
  end;
end;

procedure TAddSessionPasswordForm.CbShowPasswordClick(Sender: TObject);
begin
  if CbShowPassword.Checked then
  begin
    EdPassword.PasswordChar := #0;
    EdPasswordConfirm.Hide;
    LbPasswordConfirm.Hide;
  end else
  begin
    EdPassword.PasswordChar := '*';
    EdPasswordConfirm.Show;
    LbPasswordConfirm.Show;
  end;
end;

end.
