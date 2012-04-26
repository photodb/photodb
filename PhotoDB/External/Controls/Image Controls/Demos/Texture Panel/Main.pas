unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TexturePanel, StdCtrls, Buttons, ExtDlgs;

type
  TForm1 = class(TForm)
    TexturePanel1: TTexturePanel;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    SpeedButton5: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  TexturePanel1.Pattern := True;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  TexturePanel1.Pattern := False;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  BorderStyle := bsNone;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  BorderStyle := bsSizeable;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  with OpenPictureDialog1 do
    if Execute then
    begin
      TexturePanel1.Picture.LoadFromFile(FileName);
      // Без следующей строки не перерисовывается, фиг знает почему
      TexturePanel1.Invalidate;
    end;
end;

end.
