unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, AniLabel, StdCtrls, DmMemo, DmProgress, WebLink,
  tlayered_bitmap;

type
  TFormUpdaterWindow = class(TForm)
    DmMemo1: TDmMemo;
    FilesLabel: TDmMemo;
    ProgressBar: TDmProgress;
    WebLink1: TWebLink;
    WebLink2: TWebLink;
    Button1: TWebLink;
    Button3: TWebLink;
    Button2: TWebLink;
    WebLink6: TWebLink;
    WebLink7: TWebLink;
    Timer1: TTimer;
    ImageGo: TImage;
    ImageHourGlass: TImage;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private   
  procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
    { Private declarations }
  public
   FImage : TLayeredBitmap;   
   FImageHourGlass : TLayeredBitmap;
   FImagePos : integer;
   FImagePosStep : integer;
    { Public declarations }
  end;

var
  FormUpdaterWindow: TFormUpdaterWindow;

implementation

{$R *.dfm}

{ TForm1 }

procedure TFormUpdaterWindow.WMMouseDown(var s: Tmessage);
begin
 Perform(WM_NCLBUTTONDOWN,HTCaption,s.lparam);
end;

procedure TFormUpdaterWindow.FormPaint(Sender: TObject);
begin
 Canvas.Pen.Color:=0;
 Canvas.Brush.Color:=0;
 Canvas.MoveTo(0,0);
 Canvas.LineTo(Width-1,0);
 Canvas.LineTo(Width-1,Height-1);
 Canvas.LineTo(0,Height-1);
 Canvas.LineTo(0,0);

 Canvas.Pen.Color:=ClGray;
 Canvas.Brush.Color:=ClGray;     
 Canvas.MoveTo(FilesLabel.Left-1,FilesLabel.Top-1);
 Canvas.LineTo(FilesLabel.Left+FilesLabel.Width,FilesLabel.Top-1);
 Canvas.LineTo(FilesLabel.Left+FilesLabel.Width,FilesLabel.Top+FilesLabel.Height);
 Canvas.LineTo(FilesLabel.Left-1,FilesLabel.Top+FilesLabel.Height);
 Canvas.LineTo(FilesLabel.Left-1,FilesLabel.Top-1);
 
 ProgressBar.DoPaintOnXY(Canvas,ProgressBar.Left,ProgressBar.Top);
end;

procedure TFormUpdaterWindow.FormCreate(Sender: TObject);
type
 TLayeredByteArray = array of array of array[0..3] of byte;
 PLayeredByteArray = ^TLayeredByteArray;
var
  i, j : integer;
  Bytes : PLayeredByteArray;
  b : byte;
begin
 DoubleBuffered:=true;
 WebLink1.ImageCanRegenerate:=true;
 WebLink2.ImageCanRegenerate:=true;
 Button1.ImageCanRegenerate:=true;
 Button3.ImageCanRegenerate:=true;
 Button2.ImageCanRegenerate:=true;
 WebLink6.ImageCanRegenerate:=true;
 WebLink7.ImageCanRegenerate:=true;

 FImagePos:=1;
 FImagePosStep:=1; 
 FImage := TLayeredBitmap.Create();
 FImage.LoadFromIconA(ImageGo.Picture.Icon);
                  
 Bytes:=FImage.GetArray;
 for i:=0 to FImage.Height-1 do
 for j:=0 to FImage.Width-1 do
 begin
  b:=Bytes^[i][j][0];
  Bytes^[i][j][0]:=Bytes^[i][j][2];
  Bytes^[i][j][2]:=b;
 end;

 FImageHourGlass:= TLayeredBitmap.Create();
 FImageHourGlass.LoadFromIconA(ImageHourGlass.Picture.Icon,48,48);
end;

procedure TFormUpdaterWindow.Image1Click(Sender: TObject);
begin
 ShowMessage('Open image');
end;

procedure TFormUpdaterWindow.Button1Click(Sender: TObject);
begin
 Close;
end;

procedure TFormUpdaterWindow.Timer1Timer(Sender: TObject);
var
  Bitmap : TBitmap;
  TextTop, TextLeft, TextWidth, TextHeight : integer;
  Text : string;
begin

 Bitmap:=TBitmap.Create;
 Bitmap.Width:=100;
 Bitmap.Height:=85;
 Bitmap.Canvas.Brush.Color:=clWhite;
 Bitmap.Canvas.Pen.Color:=clWhite;
 Bitmap.Canvas.Rectangle(0,0,100,100);
 FImage.DolayeredDraw(16*FImagePos,0,255-FImagePosStep,Bitmap);

 if FImagePos>4 then
 FImage.DolayeredDraw(16,0,FImagePosStep,Bitmap) else
 FImage.DolayeredDraw(16*(FImagePos+1),0,FImagePosStep,Bitmap);

 FImageHourGlass.DolayeredDraw(Bitmap.Width div 2 - FImageHourGlass.Width div 2,16,150,Bitmap);

 Bitmap.Canvas.Font.Name:='Times new roman';
 Bitmap.Canvas.Font.Size:=8;
 Bitmap.Canvas.Font.Style:=[fsBold];
 Bitmap.Canvas.Brush.Color:=clWhite;
 Text:='Чтение [1235Mб]';
 TextWidth:=Canvas.TextWidth(Text);
 TextHeight:=Canvas.TextHeight(Text);
 TextLeft:=Bitmap.Width div 2 - TextWidth div 2;
 TextTop:=Bitmap.Height - TextHeight;
 Bitmap.Canvas.TextOut(TextLeft,TextTop,Text);
 Canvas.Draw(1,FilesLabel.Top,Bitmap);
 Bitmap.free;


 inc(FImagePosStep,10);
 if (FImagePosStep>=255) then
 begin
  FImagePosStep:=0;
  inc(FImagePos);
  if FImagePos>5 then FImagePos:=1;
 end;

end;

end.
