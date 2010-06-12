unit UnitCryptImageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, FormManegerUnit, GraphicCrypt, Language,
  uVistaFuncs;

type
  TCryptImageForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox6: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
  FFileName : String;
  Password : String;
  SaveFileCRC : Boolean;
  CryptFileName : Boolean;
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
 CryptImageForm.FFileName:=FileName;
 CryptImageForm.ShowModal;
 Result.Password:=CryptImageForm.Password;
 Result.CryptFileName:=CryptImageForm.CryptFileName;
 Result.SaveFileCRC:=CryptImageForm.SaveFileCRC; 
 CryptImageForm.Release;
 if UseFreeAfterRelease then CryptImageForm.Free;
end;

procedure TCryptImageForm.FormCreate(Sender: TObject);
begin
 DBkernel.RecreateThemeToForm(Self);
 CheckBox3.Checked:=DBKernel.Readbool('Options','AutoSaveSessionPasswords',true);
 CheckBox4.Checked:=DBKernel.Readbool('Options','AutoSaveINIPasswords',false);
 SaveFileCRC := false;
 CryptFileName := false;
 Password:='';
 LoadLanguage;
end;

procedure TCryptImageForm.Button2Click(Sender: TObject);
begin
 if Edit1.Text='' then Exit;
 if CheckBox6.Checked then
 begin
  Password:=Edit1.text;
  SaveFileCRC := CheckBox2.Checked;
  if CheckBox3.Checked then DBKernel.AddTemporaryPasswordInSession(Password);
  if CheckBox4.Checked then DBKernel.SavePassToINIDirectory(Password);
  Close;
 end else
 begin
  if Edit1.text=Edit2.text  then
  begin
   Password:=Edit1.text;
   SaveFileCRC := CheckBox2.Checked;
   if CheckBox3.Checked then DBKernel.AddTemporaryPasswordInSession(Password);
   if CheckBox4.Checked then DBKernel.SavePassToINIDirectory(Password);
   Close;
  end else
  begin
   MessageBoxDB(Handle,TEXT_MES_PASSWORDS_DIFFERENT,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
 end;
end;

procedure TCryptImageForm.CheckBox6Click(Sender: TObject);
begin
 if CheckBox6.Checked then
 begin
  Edit1.PasswordChar:=#0;
  Edit2.Hide;
  Label2.Hide;
 end else
 begin
  Edit1.PasswordChar:='*';
  Edit2.Show;
  Label2.Show;
 end;
end;

procedure TCryptImageForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if key=#13 then
 begin
  Key:=#0;
  Button2Click(Sender);
 end;
end;

procedure TCryptImageForm.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TCryptImageForm.LoadLanguage;
begin
 Label1.Caption:=TEXT_MES_ENTER_IM_PASSWORD;
 Label2.Caption:=TEXT_MES_REENTER_IM_PASSWORD;
 Caption:=TEXT_MES_CRYPT_IMAGE;
 Button1.Caption:=TEXT_MES_CANCEL;
 Button2.Caption:=TEXT_MES_OK;
 CheckBox2.Caption:=TEXT_MES_SAVE_CRC;
 CheckBox3.Caption:=TEXT_MES_SAVE_PASS_SESSION;
 CheckBox4.Caption:=TEXT_MES_SAVE_PASS_IN_INI_DIRECTORY;
 CheckBox6.Caption:=TEXT_MES_SHOW_PASSWORD;
end;

procedure TCryptImageForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#27 then
 begin
  Close;
 end;
end;

end.
