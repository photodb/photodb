unit UnitCryptImageForm;

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
  Dolphin_DB,
  FormManegerUnit,
  GraphicCrypt,
  uConstants,
  WebLink,
  Menus,
  uMemory,
  uStrongCrypt,
  DECUtil,
  DECCipher,
  WatermarkedEdit,
  uDBForm, UnitDBKernel,
  uShellIntegration,
  uSettings,
  uActivationUtils,
  uCryptUtils,
  uDBPopupMenuInfo,
  UnitDBDeclare,
  uTranslate,
  uDBBaseTypes,
  Vcl.ActnPopup,
  uFileUtils,
  Vcl.PlatformDefaultStyleActnCtrls, uBaseWinControl;

type
  TCryptImageForm = class(TPasswordSettingsDBForm)
    BtCancel: TButton;
    BtOk: TButton;
    CbSaveCRC: TCheckBox;
    CbSavePasswordForSession: TCheckBox;
    CbSavePasswordPermanent: TCheckBox;
    LbPassword: TLabel;
    LbPasswordConfirm: TLabel;
    EdPassword: TWatermarkedEdit;
    EdPasswordConfirm: TWatermarkedEdit;
    CbShowPassword: TCheckBox;
    WblMethod: TWebLink;
    PmCryptMethod: TPopupActionBar;
    procedure FormCreate(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure CbShowPasswordClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    FFileName: string;
    Password: string;
    SaveFileCRC: Boolean;
    CryptFileName: Boolean;
    function GetPasswordSettingsPopupMenu: TPopupMenu; override;
    function GetPaswordLink: TWebLink; override;
  end;

function GetPassForCryptImageFile(FileName : String) : TCryptImageOptions;
procedure EncryptPhohos(Owner: TDBForm; Text: string; Info: TDBPopupMenuInfo);
procedure DecryptPhotos(Owner: TDBForm; Info: TDBPopupMenuInfo);

implementation

uses
  UnitCryptingImagesThread,
  UnitPasswordForm;

{$R *.dfm}

procedure DecryptPhotos(Owner: TDBForm; Info: TDBPopupMenuInfo);
var
  I: Integer;
  Options: TCryptImageThreadOptions;
  ItemFileNames: TArStrings;
  ItemIDs: TArInteger;
  ItemSelected: TArBoolean;
  Password: string;
begin

  Password := DBKernel.FindPasswordForCryptImageFile(Info[Info.Position].FileName);
  if Password = '' then
    if FileExistsSafe(Info[Info.Position].FileName) then
      Password := GetImagePasswordFromUser(Info[Info.Position].FileName);

  if Password = '' then
    Exit;

  Setlength(ItemFileNames, Info.Count);
  Setlength(ItemIDs, Info.Count);
  Setlength(ItemSelected, Info.Count);

  for I := 0 to Info.Count - 1 do
  begin
    ItemFileNames[I] := Info[I].FileName;
    ItemIDs[I] := Info[I].ID;
    ItemSelected[I] := Info[I].Selected;
  end;

  Options.Files := Copy(ItemFileNames);
  Options.IDs := Copy(ItemIDs);
  Options.Selected := Copy(ItemSelected);
  Options.Action := ACTION_DECRYPT_IMAGES;
  Options.Password := Password;
  Options.CryptOptions := 0;
  TCryptingImagesThread.Create(Owner, Options);
end;

procedure EncryptPhohos(Owner: TDBForm; Text: string; Info: TDBPopupMenuInfo);
var
  Options: TCryptImageThreadOptions;
  Opt: TCryptImageOptions;
  I, CryptOptions: Integer;
begin
  Opt := GetPassForCryptImageFile(Text);
  if Opt.SaveFileCRC then
    CryptOptions := CRYPT_OPTIONS_SAVE_CRC
  else
    CryptOptions := CRYPT_OPTIONS_NORMAL;
  if Opt.Password = '' then
    Exit;

  SetLength(Options.Files, Info.Count);
  SetLength(Options.IDs, Info.Count);
  SetLength(Options.Selected, Info.Count);
  for I := 0 to Info.Count - 1 do
  begin
    Options.Files[I] := Info[I].FileName;
    Options.IDs[I] := Info[I].ID;
    Options.Selected[I] := Info[I].Selected;
  end;

  Options.Password := Opt.Password;
  Options.CryptOptions := CryptOptions;
  Options.Action := ACTION_CRYPT_IMAGES;
  TCryptingImagesThread.Create(Owner, Options);
end;

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
var
  FPassIcon : HIcon;
begin
  if TActivationManager.Instance.IsDemoMode then
    SetDefaultCipherClass(TCipher_2DES);

  CbSavePasswordForSession.Checked := Settings.Readbool('Options', 'AutoSaveSessionPasswords', True);
  CbSavePasswordPermanent.Checked := Settings.Readbool('Options', 'AutoSaveINIPasswords', False);
  SaveFileCRC := False;
  CryptFileName := False;
  Password := '';
  LoadLanguage;

  FPassIcon := LoadImage(HInstance, PChar('PASSWORD'),IMAGE_ICON, 16, 16, 0);
  try
    WblMethod.LoadFromHIcon(FPassIcon);
  finally
    DestroyIcon(FPassIcon);
  end;
end;

procedure TCryptImageForm.BtOkClick(Sender: TObject);
begin
  if EdPassword.Text = '' then
    Exit;

  if not CbShowPassword.Checked and (EdPassword.Text <> EdPasswordConfirm.Text) then
  begin
    MessageBoxDB(Handle, L('Passwords do not match!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
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
  end else
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
    BtOKClick(Sender);
  end;
end;

procedure TCryptImageForm.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCryptImageForm.LoadLanguage;
begin
  BeginTranslate;
  try
    LbPassword.Caption := L('Enter password for selected objects') + ':';
    EdPassword.WatermarkText := L('Password');
    LbPasswordConfirm.Caption := L('Confirm password') + ':';
    EdPasswordConfirm.WatermarkText := L('Confirm password');
    Caption := L('Encrypt objects');
    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('Ok');
    CbSaveCRC.Caption := L('Save CRC');
    CbSavePasswordForSession.Caption := L('Save password for session');
    CbSavePasswordPermanent.Caption := L('Save password in settings');
    CbShowPassword.Caption := L('Show password');
  finally
    EndTranslate;
  end;
end;

procedure TCryptImageForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

function TCryptImageForm.GetFormID: string;
begin
  Result := 'Password';
end;

function TCryptImageForm.GetPaswordLink: TWebLink;
begin
  Result := WblMethod;
end;

function TCryptImageForm.GetPasswordSettingsPopupMenu: TPopupMenu;
begin
  Result := PmCryptMethod;
end;

end.
