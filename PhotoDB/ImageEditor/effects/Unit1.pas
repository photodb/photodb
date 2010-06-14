unit Unit1;

interface

uses
 dm, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, ComCtrls, StdCtrls, GBlur2, Spin, Effects,
  ScanlinesFX,OptimizeImageUnit, janFX, ScrollingImage, FastFX, FastRGB, fastbmp;

type
  Item=integer;   {This defines the objects being sorted.}
  List=array[0..6561] of Item; {This is an array of objects to be sorted.}

  type
  TForm1 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    Button2: TButton;
    TrackBar4: TTrackBar;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    Label2: TLabel;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    Label3: TLabel;
    Button6: TButton;
    Button7: TButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    TrackBar7: TTrackBar;
    TrackBar10: TTrackBar;
    Label9: TLabel;
    Label11: TLabel;
    TrackBar13: TTrackBar;
    Label12: TLabel;
    TrackBar14: TTrackBar;
    Label13: TLabel;
    TrackBar15: TTrackBar;
    Label15: TLabel;
    TrackBar16: TTrackBar;
    Label14: TLabel;
    Button12: TButton;
    Edit1: TEdit;
    Label7: TLabel;
    ComboBox1: TComboBox;
    Button13: TButton;
    SBScrollingImage1: TSBScrollingImage;
    ComboBox2: TComboBox;
    Button14: TButton;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar9Change(Sender: TObject);
    procedure TrackBar10Change(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar12Change(Sender: TObject);
    procedure TrackBar13Change(Sender: TObject);
    procedure TrackBar14Change(Sender: TObject);
    procedure TrackBar15Change(Sender: TObject);
    procedure TrackBar16Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure SBScrollingImage1ChangePos(Sender: TObject);
    procedure Button14Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  e : array [1..5,1..5] of TEdit;
  lock : boolean;

implementation

{$R *.dfm}


procedure TForm1.TrackBar1Change(Sender: TObject);
var
 s,d : TBitmap;
 ps,pd : PARGB;
 i,j : integer;
 Col : TColor;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 Colorize(s,d,TrackBar1.Position);
 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;



procedure TForm1.TrackBar2Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
 ChangeBrightness(d,TrackBar2.Position);
 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.assign(s);
 Effect_GaussianBlur(d,trackbar3.Position);
 //GBlur(d,trackbar3.Position);
 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;


procedure TForm1.Button2Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 Dither(s,d);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;








procedure TForm1.TrackBar4Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
// Sharpen(s,d,TrackBar4.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;



procedure TForm1.Button3Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
// d.assign(s);
 WaveSin(s,d, s.Width div   70, s.Width div 10, True, clWhite);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;



procedure TForm1.Button4Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);

 PixelsEffect(s, d, 8, 8);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
Blocks(s, d, s.Width div 10, s.Height div 10, 4, clWhite);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;




procedure TForm1.TrackBar5Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
// Contrast(d,TrackBar5.Position,false);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;




procedure TForm1.TrackBar6Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);

 Gamma(s, d,TrackBar6.Position/100);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;



procedure TForm1.Button6Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);


  Disorder(s,d, 5, 5, clWhite);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;


procedure TForm1.Button7Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);

 Sepia(S,D,30);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;




procedure TForm1.SpinEdit1Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
SetRGBChannelValue(d, Spinedit1.Value, Spinedit2.Value, Spinedit3.Value);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 
 GrayScaleImage(S,D,255);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);

 inverse(s,d);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 AutoLevels(s,d);
 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 AutoColors(s,d);
 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button12Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

Effect_Emboss(d);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
 end;

procedure Antialiasing(Image: TImage; Percent: Integer);
 type
   TRGBTripleArray = array[0..32767] of TRGBTriple;
   PRGBTripleArray = ^TRGBTripleArray;
 var
   SL, SL2: PRGBTripleArray;
   l, m, p: Integer;
   R, G, B: TColor;
   R1, R2, G1, G2, B1, B2: Byte;
 begin
   with Image.Canvas do
   begin
     Brush.Style  := bsClear;
     Pixels[1, 1] := Pixels[1, 1];
     for l := 0 to Image.Height - 1 do
     begin
       SL := Image.Picture.Bitmap.ScanLine[l];
       for p := 1 to Image.Width - 1 do
       begin
         R1 := SL[p].r;
         G1 := SL[p].g;
         B1 := SL[p].b;

         // Left 
        if (p < 1) then m := Image.Width
         else
           m := p - 1;
         R2 := SL[m].r;
         G2 := SL[m].g;
         B2 := SL[m].b;
         if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
         begin
           R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
           G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
           B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
           SL[m].r := R;
           SL[m].g := G;
           SL[m].b := B;
         end;

         //Right 
        if (p > Image.Width - 2) then m := 0
         else
           m := p + 1;
         R2 := SL[m].r;
         G2 := SL[m].g;
         B2 := SL[m].b;
         if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
         begin
           R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
           G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
           B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
           SL[m].r := R;
           SL[m].g := G;
           SL[m].b := B;
         end;

         if (l < 1) then m := Image.Height - 1
         else
           m := l - 1;
         //Over 
        SL2 := Image.Picture.Bitmap.ScanLine[m];
         R2  := SL2[p].r;
         G2  := SL2[p].g;
         B2  := SL2[p].b;
         if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
         begin
           R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
           G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
           B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
           SL2[p].r := R;
           SL2[p].g := G;
           SL2[p].b := B;
         end;

         if (l > Image.Height - 2) then m := 0
         else
           m := l + 1;
         //Under 
        SL2 := Image.Picture.Bitmap.ScanLine[m];
         R2  := SL2[p].r;
         G2  := SL2[p].g;
         B2  := SL2[p].b;
         if (R1 <> R2) or (G1 <> G2) or (B1 <> B2) then
         begin
           R := Round(R1 + (R2 - R1) * 50 / (Percent + 50));
           G := Round(G1 + (G2 - G1) * 50 / (Percent + 50));
           B := Round(B1 + (B2 - B1) * 50 / (Percent + 50));
           SL2[p].r := R;
           SL2[p].g := G;
           SL2[p].b := B;
         end;
       end;
     end;
   end;
 end;



procedure TForm1.Button11Click(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
 Effect_AntiAlias(d);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar8Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
//Effect_AddColorNoise(d, TrackBar8.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar9Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
//Effect_AddMonoNoise(d, TrackBar9.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar10Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
// if TrackBar10.Position>1 then
//FishEye(s,d, 1+TrackBar10.Position/100);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar11Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

//Effect_Lightness(d,TrackBar11.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar12Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

//Effect_Darkness(d,TrackBar12.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar13Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

Effect_Saturation(d,TrackBar13.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar14Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

Effect_SplitBlur(d,TrackBar14.Position);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;


procedure TForm1.TrackBar15Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

//Twist(s,d,1+TrackBar15.Position*3);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.TrackBar16Change(Sender: TObject);
var
 s,d : TBitmap;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);

Effect_Posterize(d,1+ROund(TrackBar16.Position));

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
i,j : integer;
begin
 lock:=true;
 for i:=1 to 5 do
 for j:=1 to 5 do
 begin
  e[i,j]:=TEdit.create(self);
  e[i,j].Parent:=self;
  e[i,j].Top:=450+30*(i-1);
  e[i,j].Left:=10+30*(j-1);
  e[i,j].OnChange:=Edit1Change;
  e[i,j].Visible:=false;
  e[i,j].Text:='0';
  e[i,j].Width:=20;
 end;
 lock:=false;
end;

procedure TForm1.Edit1Change(Sender: TObject);
var
 x : TConvolutionMatrix;
 s,d : TBitmap;
 p1,p2 : TArPRGBArray;
 i,j : integer;
begin
 if lock then exit;
 lock:=true;
 if Sender=ComboBox1 then
 begin
  for i:=0 to 24 do x.matrix[i]:=0;
  x:=Filterchoice(ComboBox1.ItemIndex+1);
  for i:=-2 to 2 do
  for j:=-2 to 2 do
  begin
   e[3+i,3+j].text:=inttostr(x.matrix[(i+2)*5+j+2]);
  end;
  edit1.text:=inttostr(x.Devider);
 end else
 begin
  x.Devider:=strtointdef(Edit1.Text,1);
  for i:=0 to 24 do x.matrix[i]:=0;

  for i:=-2 to 2 do
  for j:=-2 to 2 do
  begin
   x.matrix[(i+2)*5+j+2]:=strtointdef(e[3+i,3+j].text,0);
  end;
 end;
lock:=false;
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 d.Assign(s);
 setlength(p1,s.Height);
 setlength(p2,s.Height);
 for i:=0 to s.Height-1 do
 begin
  p1[i]:=S.Scanline[i];
  p2[i]:=D.Scanline[i];

 end;

 MatrixEffectsW(0,0,p1,p2,S.Width-1,S.Height-1,x);

 image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.Button13Click(Sender: TObject);
var
 s,d : TBitmap;
 f : TFilterProc;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
// d.Assign(s);
 d.Width:=800;
 d.Height:=600;

 case  ComboBox2.ItemIndex of
0 : f:=SplineFilter;
1 : f:=BellFilter;
2 : f:=TriangleFilter;
3 : f:=BoxFilter ;
4 : f:=HermiteFilter;
5 : f:=Lanczos3Filter;
6 : f:=MitchellFilter;
end;
Strecth(s,d,f,200);
SBScrollingImage1.Picture:=d;
// image2.Picture.Bitmap:=d;
 d.free;
 s.free;
end;

procedure TForm1.SBScrollingImage1ChangePos(Sender: TObject);
begin
// SBScrollingImage2.ImagePos:=SBScrollingImage1.ImagePos;
end;

procedure SmoothRotate(Bmp,Dst:TBitmap;cx,cy:Integer;Angle:Extended);
var
Top,
Bottom,
Left,
Right,
eww,nsw,
fx,fy,
wx,wy:    Extended;
cAngle,
sAngle:   Double;
xDiff,
yDiff,
ifx,ify,
px,py,
ix,iy,
x,y:      Integer;
nw,ne,
sw,se:    TRGB;
Tmp:      PFColor;
ps, pd : array of pargb;
begin
  Angle:=-Angle*Pi/180;
  sAngle:=Sin(Angle);
  cAngle:=Cos(Angle);
  xDiff:=(Dst.Width-Bmp.Width)div 2;
  yDiff:=(Dst.Height-Bmp.Height)div 2;
//  Tmp:=Dst.Bits;

  SetLength(ps,Dst.Height);
  SetLength(pd,Bmp.Height);
  for y:=0 to Dst.Height-1 do
  pd[y]:=Dst.ScanLine[y];
  for y:=0 to Bmp.Height-1 do
  ps[y]:=Bmp.ScanLine[y];

  for y:=0 to Dst.Height-1 do
  begin
    py:=2*(y-cy)+1;
    for x:=0 to Dst.Width-1 do
    begin
      px:=2*(x-cx)+1;
      fx:=(((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
      fy:=(((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
      ifx:=Round(fx);
      ify:=Round(fy);

      if(ifx>-1)and(ifx<Bmp.Width)and(ify>-1)and(ify<Bmp.Height)then
      begin
        eww:=fx-ifx;
        nsw:=fy-ify;
        iy:=TrimInt(ify+1,0,Bmp.Height-1);
        ix:=TrimInt(ifx+1,0,Bmp.Width-1);
        nw:=ps[ify,ifx];
        ne:=ps[ify,ix];
        sw:=ps[iy,ifx];
        se:=ps[iy,ix];

        Top:=nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        pd[y,x].b:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        pd[y,x].g:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        pd[y,x].r:=IntToByte(Round(Top+nsw*(Bottom-Top)));
      end;
      Inc(Tmp);
    end;
//    Tmp:=Ptr(Integer(Tmp)+Dst.Gap);
  end;
end;

(*procedure RemoveNoise(S, D:TBitmap;d:Byte);
var
pc:       PFColor;
lst:      TFColor;
x,y:      Integer;
rd,gd,bd: Byte;
ps, pd : array of pargb;
begin
//  pc:=Bmp.Bits;
//  lst:=pc^;

  SetLength(ps,Dst.Height);
  SetLength(pd,Bmp.Height);
  for y:=0 to S.Height-1 do
  ps[y]:=S.ScanLine[y];
  for y:=0 to D.Height-1 do
  pd[y]:=D.ScanLine[y];

  for y:=0 to S.Height-1 do
  begin
    for x:=0 to S.Width-1 do
    begin
      bd:=lst.b-pc.b; if bd<0 then Inc(bd,bd+bd);
      gd:=lst.g-pc.g; if gd<0 then Inc(gd,gd+gd);
      rd:=lst.r-pc.r; if rd<0 then Inc(rd,rd+rd);
      if(bd>d)or(gd>d)or(rd>d)then
      begin
        lst.b:=((lst.b*(255 xor bd))+(pc.b*bd))shr 8;
        lst.g:=((lst.g*(255 xor gd))+(pc.g*gd))shr 8;
        lst.r:=((lst.r*(255 xor rd))+(pc.r*rd))shr 8;
      end;
      pc^:=lst;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
    lst:=pc^;
  end;
  pc:=Bmp.Bits;
  lst:=pc^;
  for x:=0 to Bmp.Width-1 do
  begin
    pc:=@Bmp.Pixels[0,x];
    lst:=pc^;
    for y:=0 to Bmp.Height-1 do
    begin
      bd:=lst.b-pc.b; if bd<0 then Inc(bd,bd+bd);
      gd:=lst.g-pc.g; if gd<0 then Inc(gd,gd+gd);
      rd:=lst.r-pc.r; if rd<0 then Inc(rd,rd+rd);
      if(bd>d)or(gd>d)or(rd>d)then
      begin
        lst.b:=((lst.b*(255 xor bd))+(pc.b*bd))shr 8;
        lst.g:=((lst.g*(255 xor gd))+(pc.g*gd))shr 8;
        lst.r:=((lst.r*(255 xor rd))+(pc.r*rd))shr 8;
      end;
{      pc^:=lst;
      pc:=Ptr(Integer(pc)+Bmp.RowInc);    }
    end;
  end;
end;    *)

function L_Less_Than_R(L,R:Item):boolean;
begin
 Result:=L<R;
end;

procedure Swap(var X:List;I,J:integer);
var
 Temp:Item;
begin
 Temp:=X[I];
 X[I]:=X[J];
 X[J]:=Temp;
end;

procedure Qsort(var X:List;Left,Right:integer);
label
   Again;
var
   Pivot:Item;
   P,Q:integer;

   begin
      P:=Left;
      Q:=Right;
      Pivot:=X [(Left+Right) div 2];

      while P<=Q do
      begin
         while L_Less_Than_R(X[P],Pivot) do inc(P);
         while L_Less_Than_R(Pivot,X[Q]) do dec(Q);
         if P>Q then goto Again;
         Swap(X,P,Q);
         inc(P);dec(Q);
      end;

      Again:
      if Left<Q  then Qsort(X,Left,Q);
      if P<Right then Qsort(X,P,Right);
   end;

procedure QuickSort(var X:List;N:integer);
begin
 Qsort(X,0,N-1);
end;

procedure MedFilter(s,d : TBitmap; radius:integer);
var x,y,i,k,l:integer;
    xs,ys,xe,ye:integer;
    med:integer;
    size,size2:integer;
    ltmdn:integer;
    hist:array[0..255] of integer;
    
    ar,sar:List;
    ps, pd : array of pargb;
    ImageHeight, ImageWidth  : integer;
begin

  size:=2*radius+1;
  size2:=size*size;

  SetLength(ps,S.Height);
  SetLength(pd,D.Height);
  for y:=0 to S.Height-1 do
  ps[y]:=S.ScanLine[y];
  for y:=0 to D.Height-1 do
  pd[y]:=D.ScanLine[y];
  ImageHeight:=S.Height;
  ImageWidth:=S.Width;

  for y:=0 to ImageHeight-1 do
   begin
    ltmdn:=0;
    for i:=0 to 255 do hist[i]:=0;
    for x:=0 to ImageWidth-1 do
     begin
      if x=0 then
       begin
        for k:=-radius to radius do
         for l:=-radius to radius do
          begin
           if (x+k>=0) and (x+k<=ImageWidth-1) and (y+l>=0) and
(y+l<=ImageHeight-1) then
            ar[size*(radius+k)+(radius+l)]:=ps[y+l,x+k].r//Windows.RGB(ps[y+l,x+k].r,ps[y+l,x+k].g,ps[y+l,x+k].b)//ps[y+l,x+k] //Image[t,x+k,y+l]
           else ar[size*(radius+k)+(radius+l)]:=0;
           Inc(hist[ar[size*(radius+k)+(radius+l)]]);
          end;
        for i:=0 to 6561 do
        sar[i]:=ar[i];
        QuickSort(sar,size2);

        med:=sar[size2 div 2];
        for i:=0 to med-1 do ltmdn:=ltmdn+hist[i];
       end
      else
       begin
        for l:=-radius to radius do
         begin
          Dec(hist[ar[size*((x-1) mod size)+radius+l]]);
          if ar[size*((x-1) mod size)+radius+l]<med then ltmdn:=ltmdn-1;

          if (x+radius<=ImageWidth-1) and (y+l>=0) and
(y+l<=ImageHeight-1) then
           ar[size*((x-1) mod size)+radius+l]:=ps[y+l,x+radius].r//Windows.RGB(ps[y+l,x+radius].r,ps[y+l,x+radius].g,ps[y+l,x+radius].b)//Image[t,x+radius,y+l]
          else ar[size*((x-1) mod size)+radius+l]:=0;
          Inc(hist[ar[size*((x-1) mod size)+radius+l]]);
          if ar[size*((x-1) mod size)+radius+l]<med then Inc(ltmdn);
         end;
        if (ltmdn<=size2 div 2) then
         begin
          repeat
           ltmdn:=ltmdn+hist[med];
           Inc(med);
          until (ltmdn>size2 div 2) or (med=255);
          ltmdn:=ltmdn-hist[med-1];
          Dec(med);
         end
        else
         repeat
          ltmdn:=ltmdn-hist[med-1];
          Dec(med);
         until (ltmdn<=size2 div 2) or (med=0);
       end;
       ps[y,x].r:=GetRValue(med);
       ps[y,x].g:=GetGValue(med);
       ps[y,x].b:=GetBValue(med);
//       NewImage[x,y]:=med;
     end;
   end;
end;

procedure TForm1.Button14Click(Sender: TObject);
var
 s,d : TBitmap;
 bb : TFastBMP;
begin
 s:=tbitmap.create;
 s.pixelformat:=pf24bit;
 d:=tbitmap.create;
 d.pixelformat:=pf24bit;
 s.assign(Image1.picture.graphic);
 //d.Assign(s);

 bb := TFastBMP.create;
 bb.LoadFromhBmp(d.Handle);
 bb.Bits:=d.ScanLine[0];
 FastFX.RemoveNoise(bb,3);
 bb.Draw(d.Handle,0,0);
 bb.free;
// MedFilter(s,D,4);

 SBScrollingImage1.Picture{image2.Picture.Bitmap}:=d;
 d.free;
 s.free;
end;

end.

