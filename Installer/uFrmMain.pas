unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ZLib;

type
  TFrmMain = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  uFrmLanguage;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  FormLanguage : TFormLanguage;
begin
  Application.CreateForm(TFormLanguage, FormLanguage);
  FormLanguage.ShowModal;
end;

end.
