unit UnitStringPromtForm;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  Dmitry.Controls.WatermarkedEdit,

  uDBForm,
  uFormInterfaces;

type
  TFormStringPromt = class(TDBForm, IStringPromtForm)
    EdString: TWatermarkedEdit;
    LbInfo: TLabel;
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EdStringKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FOldString: string;
    FIsOk: Boolean;
    { Private declarations }
  protected
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    function Query(Caption, Text: String; var UserString: string): Boolean;
  end;

implementation

{$R *.dfm}

function TFormStringPromt.Query(Caption, Text: String;
  var UserString: string): Boolean;
begin
  Caption := Caption;
  LbInfo.Caption := Text;
  FOldString := UserString;
  EdString.Text := UserString;
  ShowModal;
  UserString := EdString.Text;
  Result := FIsOk;
end;

procedure TFormStringPromt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormStringPromt.FormCreate(Sender: TObject);
begin
  FIsOk := False;
  BtnCancel.Caption := L('Cancel');
  BtnOK.Caption := L('Ok');
  EdString.Text := L('Enter your text here');
  BtnOK.Top := EdString.Top + EdString.Height + 3;
  BtnCancel.Top := EdString.Top + EdString.Height + 3;

  ClientHeight := BtnOK.Top + BtnOK.Height + 3;
end;

function TFormStringPromt.GetFormID: string;
begin
  Result := 'TextPromt';
end;

procedure TFormStringPromt.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormStringPromt.BtnCancelClick(Sender: TObject);
begin
  FIsOk := False;
  Close;
end;

procedure TFormStringPromt.BtnOKClick(Sender: TObject);
begin
  FIsOk := True;
  Close;
end;

procedure TFormStringPromt.CustomFormAfterDisplay;
begin
  inherited;
  if EdString <> nil then
    EdString.Refresh;
end;

procedure TFormStringPromt.EdStringKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    BtnOKClick(Sender);
  end;
end;

initialization
  FormInterfaces.RegisterFormInterface(IStringPromtForm, TFormStringPromt);

end.
