unit UnitCryptImageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, FormManegerUnit, GraphicCrypt,
  uVistaFuncs, WebLink, Menus, uMemory, uStrongCrypt, DECUtil, DECCipher,
  WatermarkedEdit, uDBForm;

type
  TCryptImageForm = class(TDBForm)
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
    PmCryptMethod: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure CbShowPasswordClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure WblMethodClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure FillChiperList;
    procedure SelectChipperClick(Sender: TObject);
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
    FFileName: string;
    Password: string;
    SaveFileCRC: Boolean;
    CryptFileName: Boolean;
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
    Result := ChipperName + ' - ' + IntToStr(Chiper.Context.KeySize * Chiper.Context.BlockSize );
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
        if Chiper.Context.KeySize * Chiper.Context.BlockSize > 16 then
        begin
          MenuItem.Caption := GetChipperName(Chiper);
          MenuItem.Tag := Integer(Chiper.Identity);
          MenuItem.OnClick := TCryptImageForm(Data).SelectChipperClick;
          TCryptImageForm(Data).PmCryptMethod.Items.Add(MenuItem);
        end;
        if (TCryptImageForm(Data).PmCryptMethod.Items.Count = 0)
           or (Integer(ClassType.Identity) = DBKernel.ReadInteger('Options', 'DefaultCryptClass', Integer(TCipher_Blowfish.Identity))) then
          MenuItem.Click;
      finally
        Chiper.Free;
      end;
    end;
  end;

begin
  StrongCryptInit;

  DECEnumClasses(@DoEnumClasses, Self);
end;

procedure TCryptImageForm.FormCreate(Sender: TObject);
var
  FPassIcon : HIcon;
begin
  CbSavePasswordForSession.Checked := DBKernel.Readbool('Options', 'AutoSaveSessionPasswords', True);
  CbSavePasswordPermanent.Checked := DBKernel.Readbool('Options', 'AutoSaveINIPasswords', False);
  SaveFileCRC := False;
  CryptFileName := False;
  Password := '';
  LoadLanguage;
  FillChiperList;

  FPassIcon := LoadIcon(DBKernel.IconDllInstance, PChar('PASSWORD'));
  WblMethod.LoadFromHIcon(FPassIcon);
  DestroyIcon(FPassIcon);
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
    LbPasswordConfirm.Caption := L('Confirm password');
    EdPasswordConfirm.WatermarkText := L('Confirm password');
    Caption := L('Crypt objects');
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

function TCryptImageForm.GetFormID: string;
begin
  Result := 'Password';
end;

end.
