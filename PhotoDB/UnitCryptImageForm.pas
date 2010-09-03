unit UnitCryptImageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, FormManegerUnit, GraphicCrypt, Language,
  uVistaFuncs, WebLink, Menus, uMemory,
  TypInfo,
  CPU,
  CRC,
  DECUtil,
  DECFmt,
  DECHash,
  DECCipher,
  DECRandom;

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
    WblMethod: TWebLink;
    PmCryptMethod: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure CbShowPasswordClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure WblMethodClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FPassIcon : TIcon;
    procedure LoadLanguage;
    procedure FillChiperList;
    procedure SelectChipperClick(Sender: TObject);
  public
    FFileName: string;
    Password: string;
    SaveFileCRC: Boolean;
    CryptFileName: Boolean;
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

procedure TCryptImageForm.FillChiperList;

  function GetChipperName(Chiper : TDECCipher) : string;
  var
    ChipperName : string;
  begin
    ChipperName := StringReplace(Chiper.ClassType.ClassName, 'TCipher_', '', [rfReplaceAll]);
    Result := ChipperName + ' - ' + IntToStr(Chiper.Context.KeySize);
  end;

  function DoEnumClasses(Data: Pointer; ClassType: TDECClass): Boolean;
  var
    MenuItem: TMenuItem;
    Chiper: TDECCipher;
  begin
    Result := False;
    MenuItem := TMenuItem.Create(TCryptImageForm(Data).PmCryptMethod);
    if ClassType.InheritsFrom(TDECCipher) then
    begin
      Chiper := CipherByIdentity(ClassType.Identity).Create;
      try
        if Chiper.Context.KeySize > 16 then
        begin
          MenuItem.Caption := GetChipperName(Chiper);
          MenuItem.Tag := Integer(Chiper.Identity);
          MenuItem.OnClick := TCryptImageForm(Data).SelectChipperClick;
          TCryptImageForm(Data).PmCryptMethod.Items.Add(MenuItem);
        end;
        if ClassType.Identity = DBKernel.ReadInteger('Options', 'DefaultCryptClass', Integer(TCipher_Blowfish.Identity)) then
          MenuItem.Click;
      finally
        Chiper.Free;
      end;
    end;
  end;

begin
  TCipher_Blowfish.Register;
  TCipher_Twofish.Register;
  TCipher_IDEA.Register;
  TCipher_CAST256.Register;
  TCipher_Mars.Register;
  TCipher_RC4.Register;
  TCipher_RC6.Register;
  TCipher_Rijndael.Register;
  TCipher_Square.Register;
  TCipher_SCOP.Register;
  TCipher_Sapphire.Register;
  TCipher_1DES.Register;
  TCipher_2DES.Register;
  TCipher_3DES.Register;
  TCipher_2DDES.Register;
  TCipher_3DDES.Register;
  TCipher_3TDES.Register;
  TCipher_3Way.Register;
  TCipher_Cast128.Register;
  TCipher_Gost.Register;
  TCipher_Misty.Register;
  TCipher_NewDES.Register;
  TCipher_Q128.Register;
  TCipher_RC2.Register;
  TCipher_RC5.Register;
  TCipher_SAFER.Register;
  TCipher_Shark.Register;
  TCipher_Skipjack.Register;
  TCipher_TEA.Register;
  TCipher_TEAN.Register;

  DECEnumClasses(@DoEnumClasses, Self);
  //Set default chipper class
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
  FillChiperList;

  FPassIcon := TIcon.Create;
  FPassIcon.Handle := LoadIcon(DBKernel.IconDllInstance, PWideChar('PASSWORD'));
  WblMethod.LoadFromHIcon(FPassIcon.Handle);
end;

procedure TCryptImageForm.FormDestroy(Sender: TObject);
begin
  F(FPassIcon);
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

procedure TCryptImageForm.SelectChipperClick(Sender: TObject);
begin
  TMenuItem(Sender).Default := True;
  WblMethod.Text := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]);
  WblMethod.Tag := TMenuItem(Sender).Tag;

  DBKernel.WriteInteger('Options', 'DefaultCryptClass', TMenuItem(Sender).Tag);
  SetDefaultCipherClass(CipherByIdentity(TMenuItem(Sender).Tag));
end;

procedure TCryptImageForm.WblMethodClick(Sender: TObject);
var
  P : TPoint;
begin
  GetCursorPos(P);
  PmCryptMethod.Popup(P.X, P.Y);
end;

procedure TCryptImageForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

end.
