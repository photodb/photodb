unit UnitStringPromtForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uDBForm, WatermarkedEdit;

type
  TFormStringPromt = class(TDBForm)
    EdString: TWatermarkedEdit;
    LbInfo: TLabel;
    BtnOK: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure EdStringKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    OldStr: string;
    Ok: Boolean;
  end;

function PromtString(Caption, Text : String; var StartString : String) : Boolean;

implementation

{$R *.dfm}

function PromtString(Caption, Text : String; var StartString : String) : Boolean;
var
  FormStringPromt: TFormStringPromt;
begin
  Application.CreateForm(TFormStringPromt, FormStringPromt);
  try
    FormStringPromt.Caption := Caption;
    FormStringPromt.LbInfo.Caption := Text;
    FormStringPromt.OldStr := StartString;
    FormStringPromt.EdString.Text := StartString;
    FormStringPromt.ShowModal;
    StartString := FormStringPromt.EdString.Text;
    Result := FormStringPromt.Ok;
  finally
    FormStringPromt.Release;
  end;
end;

procedure TFormStringPromt.FormCreate(Sender: TObject);
begin
  Ok := False;
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

procedure TFormStringPromt.BtnCancelClick(Sender: TObject);
begin
  Ok := False;
  Close;
end;

procedure TFormStringPromt.BtnOKClick(Sender: TObject);
begin
  Ok := True;
  Close;
end;

procedure TFormStringPromt.EdStringKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    BtnOKClick(Sender);
  end;
end;

end.
