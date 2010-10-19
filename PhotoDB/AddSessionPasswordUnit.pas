unit AddSessionPasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Dolphin_DB, FormManegerUnit, StdCtrls, Language;

type
  TAddSessionPasswordForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox6: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox6Click(Sender: TObject);
  private
    { Private declarations }
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

procedure TAddSessionPasswordForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TAddSessionPasswordForm.Button2Click(Sender: TObject);
begin
  if Edit1.Text = '' then
    Exit;
  if CheckBox6.Checked then
  begin
    Password := Edit1.Text;
    DBKernel.AddTemporaryPasswordInSession(Password);
    Close;
  end else
  begin
    if Edit1.Text = Edit2.Text then
    begin
      Password := Edit1.Text;
      DBKernel.AddTemporaryPasswordInSession(Password);
      Close;
    end else
    begin
      Application.MessageBox(TEXT_MES_PASSWORDS_DIFFERENT, TEXT_MES_WARNING, MB_ICONWARNING + MB_OK);
    end;
  end;
end;

procedure TAddSessionPasswordForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Button2Click(Sender);
  end;
end;

procedure TAddSessionPasswordForm.CheckBox6Click(Sender: TObject);
begin
  if CheckBox6.Checked then
  begin
    Edit1.PasswordChar := #0;
    Edit2.Hide;
    Label2.Hide;
  end else
  begin
    Edit1.PasswordChar := '*';
    Edit2.Show;
    Label2.Show;
  end;
end;

end.
