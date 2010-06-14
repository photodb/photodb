unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Effects;

type
  TForm1 = class(TForm)
    Image1: TImage;
    RadioGroup1: TRadioGroup;
    Image2: TImage;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
 b : TBitmap;
begin
 b:=TBitmap.create;
 b.PixelFormat:=pf24bit;
 b.Assign(image1.Picture.Graphic);
 Image2.Picture.Bitmap:=GetGistogrammBitmap(150,b,RadioGroup1.ItemIndex);
 b.Free;
end;

end.
