unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ExtDlgs, PanelCanvas, jpeg, math, GIFImage,
  StdCtrls;

  type
  TRGB32=record
  b,g,r,l : byte;
  end;
  Type
    ARGB32=array [0..1] of TRGB32;
    PARGB32=^ARGB32;

Type
  TRGB=record
  b,g,r : byte;
  end;

    ARGB=array [0..1] of TRGB;
    PARGB=^ARGB;
    PRGB = ^TRGB;

Type TTool=(ToolNone,ToolPen);

type
  TEditor = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    ToolsPanel: TPanel;
    OpenPictureDialog1: TOpenPictureDialog;
    Shape1: TShape;
    ColorDialog1: TColorDialog;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    procedure Open1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure MakeImage;
    procedure FormPaint(Sender: TObject);
    procedure LoadProgramImageFormat(Pic : TPicture);
    procedure LoadJPEGImage(JPEG : TJPEGImage);
    procedure LoadBMPImage(Bitmap : TBitmap);
    procedure LoadGIFImage(GIF : TGIFImage);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBar2Change(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Editor: TEditor;
{  CurrentImage, Buffer : TBitmap;
  Tool : TTool;
  BeginPoint : TPoint;    }

implementation

{$R *.dfm}

procedure Line(image : TBitmap; x_begin,y_begin,x_end,y_end : integer; Color: Tcolor);
var
  fx,fy,i : integer;
  x,y,tg : real;
  p : Pargb32;
  r,g,b : byte;

 Procedure Replace(var x1,x2 : integer);
 var
   temp : integer;
 begin
  temp:=x1;
  x1:=x2;
  x2:=temp;
 end;

begin
 image.PixelFormat:=pf32bit;
 r:=GetRValue(Color);
 g:=GetGValue(Color);
 b:=GetBValue(Color);
 if ((y_end - y_begin)=0)  and ((x_end - x_begin)=0) then
 begin
  if (y_begin<image.Height-1) and (y_begin>=0) then
  begin
  p:=image.ScanLine[y_begin];
   if (x_begin<image.Width-1) and (x_begin>=0) then
   begin
    p[x_begin].r:=r;
    p[x_begin].g:=g;
    p[x_begin].b:=b;
    p[x_begin].l:=255;
   end;
  end;
  exit;
 end;
 if (abs(x_end-x_begin) < abs(y_end-y_begin)) and ((y_end - y_begin)<>0)  then
 begin
  if y_begin>y_end then
  begin
   replace(x_begin,x_end);
   replace(y_begin,y_end);
  end;
  tg:=((x_begin-x_end)/(y_begin-y_end));
  for i:=y_begin to y_end do
  begin
   x:=x_begin+(i-y_begin)*tg;
   fx:=round(x);
   fy:=round(i);
   if (fy<image.Height-1) and (fy>=0) then
   begin
    p:=image.ScanLine[fy];
    if (fx<image.Width-1) and (fx>=0) then
    begin
     p[fx].r:=r;
     p[fx].g:=g;
     p[fx].b:=b;
     p[fx].l:=255;
    end;
   end;
  end;
 end;
 if  (abs(x_end-x_begin) >= abs(y_end-y_begin)) and ((x_end - x_begin)<>0) then
 begin
  if x_begin>x_end then
  begin
   replace(x_begin,x_end);
   replace(y_begin,y_end);
  end;
  tg:=((y_end-y_begin)/(x_end-x_begin));
  for i:=x_begin to x_end do
  begin
   y:=y_begin+(i-x_begin)*tg;
   fx:=round(i);
   fy:=round(y);
   if (fy<image.Height-1) and (fy>=0) then
   begin
    p:=image.ScanLine[fy];
    if (fx<image.Width-1) and (fx>=0) then
    begin
     p[fx].r:=r;
     p[fx].g:=g;
     p[fx].b:=b;
     p[fx].l:=255;
    end;
   end;
  end;
 end;
end;

procedure TEditor.Open1Click(Sender: TObject);
var
  pic : TPicture;
begin
 if OpenPictureDialog1.Execute then
 begin
  pic := TPicture.Create;
  try
   pic.LoadFromFile(OpenPictureDialog1.FileName);
  except
   pic.free;
   exit;
  end;
  LoadProgramImageFormat(pic);
  pic.free;
  MakeImage;
  FormPaint(self);
  Panel2Resize(self)
 end;
end;

procedure TEditor.FormCreate(Sender: TObject);
begin
{ CurrentImage:=TBitmap.Create;
 CurrentImage.PixelFormat:=pf32bit; //!!!!
 CurrentImage.Width:=0;
 CurrentImage.Height:=0;
 Buffer:=TBitmap.Create;
 Buffer.PixelFormat:=pf24bit;
 Tool:=ToolNone;     }
end;

procedure TEditor.Panel2Resize(Sender: TObject);
begin
{ Buffer.Width:=Max(1,ClientWidth-ToolsPanel.Width-ScrollBar2.Width);
 Buffer.Height:=Max(1,ToolsPanel.Height-ScrollBar1.Height);
 ScrollBar1.Width:=ClientWidth-ToolsPanel.Width-ScrollBar2.Width;
 ScrollBar1.Top:=ClientHeight-ScrollBar1.Height;
 ScrollBar2.left:=ClientWidth-ScrollBar2.Width;
 ScrollBar2.Height:=ToolsPanel.Height-ScrollBar1.Height;
 ScrollBar1.Max:=Max(0,CurrentImage.Width-Buffer.Width);
 ScrollBar2.Max:=Max(0,CurrentImage.Height-Buffer.Height);
 if CurrentImage.Height<>0 then
 ScrollBar2.PageSize:=Max(0,Min(ScrollBar2.Max,Round(ScrollBar2.Max*(Buffer.Height/CurrentImage.Height))));//Round(ScrollBar2.Max*((CurrentImage.Height-Buffer.Height)/CurrentImage.Height));
 MakeImage;
 FormPaint(nil); }
end;

procedure TEditor.MakeImage;
var
  i, j : integer;
  p : PARGB;
  p32 : PARGB32;
  Color1, Color2 : TColor;
  r1,r2,g1,g2,b1,b2 : byte;
begin
{ Color1:=$FFFFFF;
 Color2:=$A1A1A1;
 r1:=GetRValue(Color1);
 g1:=GetGValue(Color1);
 b1:=GetBValue(Color1);
 r2:=GetRValue(Color2);
 g2:=GetGValue(Color2);
 b2:=GetBValue(Color2);
 for i:=0 to Buffer.Height-1 do
 begin
  p:=Buffer.ScanLine[i];
  for j:=0 to Buffer.Width-1 do
  begin
   if odd((i*j) div 5) then //фоновый рисунок :)
   begin
    p[j].r:=r1;
    p[j].g:=g1;
    p[j].b:=b1;
   end else
   begin
    p[j].r:=r2;
    p[j].g:=g2;
    p[j].b:=b2;
   end;
  end;
 end;
 for i:=0 to Math.Min(Buffer.Height-2,CurrentImage.Height-1) do
 begin
  p:=Buffer.ScanLine[i+1];
  if i+ScrollBar2.Position>CurrentImage.Height-1 then Break;
  p32:=CurrentImage.ScanLine[i+ScrollBar2.Position];
  for j:=0 to Math.Min(Buffer.Width-2,CurrentImage.Width-1) do
  begin
   if j>CurrentImage.Width-1 then Break;
   p[j+1].r:=Round((p32[j+ScrollBar1.Position].r)*(p32[j+ScrollBar1.Position].l/255)+p[j+1].r*(1-p32[j+ScrollBar1.Position].l/255));
   p[j+1].g:=Round((p32[j+ScrollBar1.Position].g)*(p32[j+ScrollBar1.Position].l/255)+p[j+1].g*(1-p32[j+ScrollBar1.Position].l/255));
   p[j+1].b:=Round((p32[j+ScrollBar1.Position].b)*(p32[j+ScrollBar1.Position].l/255)+p[j+1].b*(1-p32[j+ScrollBar1.Position].l/255));
  end;
 end;
 for i:=0 to Math.Min(Buffer.Height-1,CurrentImage.Height-1) do
 begin
  p:=Buffer.ScanLine[i];
  p[0].r:=0;
  p[0].g:=0;
  p[0].b:=0;
 end;
 p:=Buffer.ScanLine[0];
 for j:=0 to Math.Min(Buffer.Width-2,CurrentImage.Width-1) do
 begin
  p[j].r:=0;
  p[j].g:=0;
  p[j].b:=0;
 end;
 if Buffer.Width-1>CurrentImage.Width-1 then
 for i:=0 to Math.Min(Buffer.Height-1,CurrentImage.Height-1) do
 begin
  p:=Buffer.ScanLine[i];
  p[CurrentImage.Width].r:=0;
  p[CurrentImage.Width].g:=0;
  p[CurrentImage.Width].b:=0;
 end;
 if Buffer.Height-1>CurrentImage.Height-1 then
 begin
  p:=Buffer.ScanLine[CurrentImage.Height];
  for j:=0 to Math.Min(Buffer.Width-2,CurrentImage.Width-1) do
  begin
   p[j].r:=0;
   p[j].g:=0;
   p[j].b:=0;
  end;
 end; }
end;

procedure TEditor.FormPaint(Sender: TObject);
begin
// Canvas.Draw(ToolsPanel.Width,0,Buffer);
end;

procedure TEditor.LoadProgramImageFormat(Pic: TPicture);
var
  Bitmap : TBitmap;
begin
 if Pic.Graphic is TJPEGImage then
 begin
  LoadJPEGImage(Pic.Graphic as TJPEGImage);
 end;
 if Pic.Graphic is TBitmap then
 begin
  LoadBMPImage(Pic.Graphic as TBitmap);
 end;
 if Pic.Graphic is TGIFImage then
 begin
  LoadGIFImage(Pic.Graphic as TGIFImage);
 end;
end;

procedure TEditor.LoadJPEGImage(JPEG : TJPEGImage);
var
  Temp : TBitmap;
  i, j : integer;
  p : PARGB;
  p32 : PARGB32;
begin
{ Temp := TBitmap.Create;
 Temp.Assign(JPEG);
 Temp.PixelFormat:=pf24bit;
 CurrentImage.Width:=Temp.Width;
 CurrentImage.Height:=Temp.Height;
 CurrentImage.PixelFormat:=pf32bit;
 for i:=0 to Temp.Height-1 do
 begin
  p:=Temp.ScanLine[i];
  p32:=CurrentImage.ScanLine[i];
  for j:=0 to Temp.Width-1 do
  begin
   p32[j].r:=p[j].r;
   p32[j].g:=p[j].g;
   p32[j].b:=p[j].b;
   p32[j].l:=255;
  end;
 end;
 Temp.Free;}
end;

procedure TEditor.LoadBMPImage(Bitmap: TBitmap);
var
  i, j : integer;
  p : PARGB;
  p32 : PARGB32;
begin
{ CurrentImage.Width:=Bitmap.Width;
 CurrentImage.Height:=Bitmap.Height;
 CurrentImage.PixelFormat:=pf32bit;
 if Bitmap.PixelFormat<>pf32bit then
 begin
  Bitmap.PixelFormat:=pf24bit;
  for i:=0 to Bitmap.Height-1 do
  begin
   p:=Bitmap.ScanLine[i];
   p32:=CurrentImage.ScanLine[i];
   for j:=0 to Bitmap.Width-1 do
   begin
    p32[j].r:=p[j].r;
    p32[j].g:=p[j].g;
    p32[j].b:=p[j].b;
    p32[j].l:=255;
   end;
 end;
 end else
 begin
  CurrentImage.Assign(Bitmap);
 end;  }
end;

procedure TEditor.LoadGIFImage(GIF: TGIFImage);
var
  i, j : integer;
  p32 : PARGB32;
begin
{ CurrentImage.Width:=GIF.Width;
 CurrentImage.Height:=GIF.Height;
 CurrentImage.Assign(GIF);
 CurrentImage.PixelFormat:=pf32bit;
 for i:=0 to GIF.Height-1 do
 begin
  p32:=CurrentImage.ScanLine[i];
  for j:=0 to GIF.Width-1 do
  begin
   if GIF.Images[0].Pixels[j,i]=GIF.Images[0].GraphicControlExtension.TransparentColorIndex then
   p32[j].l:=0 else p32[j].l:=255;
  end;
 end; }
end;

procedure TEditor.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 ColorDialog1.Color:=Shape1.Brush.Color;
 if ColorDialog1.Execute then
 Shape1.Brush.Color:=ColorDialog1.Color;
end;

procedure TEditor.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{ Tool:=ToolPen;
 BeginPoint:=Point(x-ToolsPanel.Width,y);
 Line(CurrentImage,BeginPoint.X+ScrollBar1.Position,BeginPoint.Y+ScrollBar2.Position,x-ToolsPanel.Width+ScrollBar1.Position,y+ScrollBar2.Position,Shape1.Brush.Color);
}end;

procedure TEditor.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
// Tool:=ToolNone;
end;

procedure TEditor.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
{ if Tool=ToolPen then
 begin
  Line(CurrentImage,BeginPoint.X+ScrollBar1.Position,BeginPoint.Y+ScrollBar2.Position,x-ToolsPanel.Width+ScrollBar1.Position,y+ScrollBar2.Position,Shape1.Brush.Color);
  BeginPoint:=Point(x-ToolsPanel.Width,y);
 end;
 MakeImage;
 FormPaint(nil);  }
end;

procedure TEditor.ScrollBar2Change(Sender: TObject);
begin
 MakeImage;
 FormPaint(nil);
end;

end.
