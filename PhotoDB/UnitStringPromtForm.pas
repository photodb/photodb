unit UnitStringPromtForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Language, Dolphin_DB, StdCtrls;

type
  TFormStringPromt = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
  OldStr : String;
  Ok : boolean;
    { Public declarations }
  end;

function PromtString(Caption, Text : String; var StartString : String) : boolean;

implementation

{$R *.dfm}

function PromtString(Caption, Text : String; var StartString : String) : boolean;
var
  FormStringPromt: TFormStringPromt;
begin
 Application.CreateForm(TFormStringPromt, FormStringPromt);
 FormStringPromt.Caption:=Caption;
 FormStringPromt.Label1.Caption:=Text;
 FormStringPromt.OldStr:=StartString;
 FormStringPromt.Edit1.Text:=StartString;
 FormStringPromt.ShowModal;
 StartString:=FormStringPromt.Edit1.Text;
 Result:=FormStringPromt.Ok;
 FormStringPromt.Release;
 if UseFreeAfterRelease then FormStringPromt.Free;
end;

procedure TFormStringPromt.FormCreate(Sender: TObject);
begin
 Ok:=false;
 DBkernel.RecreateThemeToForm(self);
 Button2.Caption:=TEXT_MES_CANCEL;
 Button1.Caption:=TEXT_MES_OK;

 Button1.Top:=Edit1.Top+Edit1.Height+3;
 Button2.Top:=Edit1.Top+Edit1.Height+3;

 ClientHeight:=Button1.Top+Button1.Height+3;
end;

procedure TFormStringPromt.Button2Click(Sender: TObject);
begin
 Ok := false;
 Close;
end;

procedure TFormStringPromt.Button1Click(Sender: TObject);
begin
// if OldStr<>Edit1.Text then
 Ok := true;
 Close;
end;

procedure TFormStringPromt.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then
 begin
  Key:=#0;
  Button1Click(Sender);
 end;
end;

end.
