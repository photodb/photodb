unit UnitCryptImageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, FormManegerUnit, GraphicCrypt, Language,
  uVistaFuncs;

type
  TCryptImageForm = class(TForm)
    BtCancel: TButton;
    BtOk: TButton;
    CbSaveCRC: TCheckBox;
    CbSavePasswordForSession: TCheckBox;
    CbSavePasswordPermanent: TCheckBox;
    LbPassword: TLabel;
    LbPasswordConfirm: TLabel;
    EdPassword: TEdit;
    EdPasswordConfirm: TEdit;
    CbShowPassword: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure CbShowPasswordClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    FFileName: string;
    Password: string;
    SaveFileCRC: Boolean;
    CryptFileName: Boolean;
    procedure LoadLanguage;
    { Public declarations }
  end;

function GetPassForCryptImageFile(FileName : String) : TCryptImageOptions;

implementation

{$R *.dfm}

function GetPassForCryptImageFile(FileName : String) : TCryptImageOptions;
var
  CryptImageForm: TCryptImageForm;
begin
  Application.CreateForm(TCryptImageForm, CryptImageForm);
  try
    CryptImageForm.FFileName := FileName;
    CryptImageForm.ShowModal;
    Result.Password := CryptImageForm.Password;
    Result.CryptFileName := CryptImageForm.CryptFileName;
    Result.SaveFileCRC := CryptImageForm.SaveFileCRC;
  finally
    CryptImageForm.Release;
  end;
end;

procedure TCryptImageForm.FormCreate(Sender: TObject);
begin
  DBkernel.RecreateThemeToForm(Self);
  CbSavePasswordForSession.Checked := DBKernel.Readbool('Options', 'AutoSaveSessionPasswords', True);
  CbSavePasswordPermanent.Checked := DBKernel.Readbool('Options', 'AutoSaveINIPasswords', False);
  SaveFileCRC := False;
  CryptFileName := False;
  Password := '';
  LoadLanguage;
end;

procedure TCryptImageForm.BtOkClick(Sender: TObject);
begin
  if EdPassword.Text = '' then
    Exit;

  if not CbShowPassword.Checked and (EdPassword.Text <> EdPasswordConfirm.Text) then
  begin
    MessageBoxDB(Handle, TEXT_MES_PASSWORDS_DIFFERENT, TEXT_MES_ERROR, TD_BUTTON_OK, TD_ICON_ERROR);
    Exit;
  end;

  Password:= EdPassword.Text;
  SaveFileCRC := CbSaveCRC.Checked;
  if CbSavePasswordForSession.Checked then
    DBKernel.AddTemporaryPasswordInSession(Password);
  if CbSavePasswordPermanent.Checked then
    DBKernel.SavePassToINIDirectory(Password);
  Close;
end;

procedure TCryptImageForm.CbShowPasswordClick(Sender: TObject);
begin
  if CbShowPassword.Checked then
  begin
    EdPassword.PasswordChar := #0;
    EdPasswordConfirm.Hide;
    LbPasswordConfirm.Hide;
  end
  else
  begin
    EdPassword.PasswordChar := '*';
    EdPasswordConfirm.Show;
    LbPasswordConfirm.Show;
  end;
end;

procedure TCryptImageForm.EdPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    BtCancelClick(Sender);
  end;
end;

procedure TCryptImageForm.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCryptImageForm.LoadLanguage;
begin
  LbPassword.Caption := TEXT_MES_ENTER_IM_PASSWORD;
  LbPasswordConfirm.Caption := TEXT_MES_REENTER_IM_PASSWORD;
  Caption := TEXT_MES_CRYPT_IMAGE;
  BtCancel.Caption := TEXT_MES_CANCEL;
  BtOk.Caption := TEXT_MES_OK;
  CbSaveCRC.Caption := TEXT_MES_SAVE_CRC;
  CbSavePasswordForSession.Caption := TEXT_MES_SAVE_PASS_SESSION;
  CbSavePasswordPermanent.Caption := TEXT_MES_SAVE_PASS_IN_INI_DIRECTORY;
  CbShowPassword.Caption := TEXT_MES_SHOW_PASSWORD;
end;

procedure TCryptImageForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

end.
