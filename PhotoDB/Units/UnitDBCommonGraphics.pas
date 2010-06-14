unit UnitDBCommonGraphics;

interface

 uses Windows, Classes, Messages, Controls, Forms, StdCtrls, Graphics, GraphicEx,
      DmProgress, UnitDBDeclare, Language, JPEG, BitmapDB, CommCtrl, UnitDBCommon,
      GraphicsBaseTypes, GIFImage, Effects, Math;

 const
    PSDTransparent = false;
    //Image processiong options
    ZoomSmoothMin = 0.4;

  procedure DoInfoListBoxDrawItem(ListBox: TListBox; Index: Integer; aRect: TRect; State: TOwnerDrawState;
    ItemsData : TList; Icons : array of TIcon; FProgressEnabled : boolean; TempProgress : TDmProgress;
    Infos : TArStrings);
  procedure BeginScreenUpdate(hwnd: THandle);
  procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);


  function CalcJpegResampledSize(Jpeg : TJpegImage; Size : integer; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
  function CalcBitmapToJPEGCompressSize(Bitmap : TBitmap; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
  procedure ConvertTo32BitImageList(const ImageList: TImageList);
  procedure LoadImageX(Image : TGraphic; Bitmap : TBitmap; BackGround : TColor);
  procedure LoadPNGImage32bit(PNG : TPNGGraphic; Bitmap : TBitmap; BackGroundColor : TColor);
  procedure LoadBMPImage32bit(BMP : TBitmap; Bitmap : TBitmap; BackGroundColor : TColor);
  procedure QuickReduce(NewWidth, NewHeight : integer; BmpIn, BmpOut : TBitmap);
  procedure StretchCool(x, y, Width, Height : Integer; var S, D : TBitmap); overload;
  procedure StretchCool(Width, Height : integer; var S,D : TBitmap); overload;
  Procedure QuickReduceWide(Width, Height : integer; Var S,D : TBitmap);
  procedure DoResize(Width,Height : integer; S,D : TBitmap);
  procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap);
  procedure Rotate180A(var im : tbitmap);
  procedure Rotate270A(var im : tbitmap);
  procedure Rotate90A(var im : tbitmap);
  procedure FillColorEx(Bitmap : TBitmap; Color : TColor);  
//TODO! PRIORITY: HIGH  procedure DrawImageEx(Bitmap, Image : TBitmap; X, Y : Integer);


implementation

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(hwnd, nil, 0, {DW_FRAME + }RDW_INVALIDATE +
    RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (erase) then
    Windows.InvalidateRect(hwnd, nil, True);
end;


procedure DoInfoListBoxDrawItem(ListBox: TListBox; Index: Integer; aRect: TRect; State: TOwnerDrawState;
ItemsData : TList; Icons : array of TIcon; FProgressEnabled : boolean; TempProgress : TDmProgress;
Infos : TArStrings);
var
  InfoText, Text : string;
  r : TRect;
  ItemData : integer;
const
  IndexAdminToolsRecord = 6;
  IndexProgressRecord = 4;
  IndexProcessedRecord = 0;
  IndexPlusRecord = 3;
  IndexWarningRecord = 2;
  IndexErrorRecord = 1;
  IndexDBRecord = 5;
begin
 //
 ItemData:=PInteger(ItemsData[Index])^;
 if odSelected in State then
 ListBox.Canvas.Brush.Color:=$A0A0A0 else
 ListBox.Canvas.Brush.Color:=ClWhite;
 //clearing rect
 ListBox.Canvas.Pen.Color:=ListBox.Canvas.Brush.Color;
 ListBox.Canvas.Rectangle(aRect);

 ListBox.Canvas.Pen.Color:=ClBlack;
 ListBox.Canvas.Font.Color:=ClBlack;
 Text:=ListBox.Items[index];

 //first Record
 if Index=0 then
 begin
  if TempProgress<>nil then
  begin
   DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexProgressRecord].Handle,16,16,0,0,DI_NORMAL);
   aRect.Left:=aRect.Left+20;
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=TEXT_MES_PROSESSING_;
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
   if FProgressEnabled then
   begin
    TempProgress.Text:='';
    TempProgress.Width:=aRect.Right-aRect.Left- ListBox.Canvas.TextWidth(InfoText)-10-ListBox.ScrollWidth;
    TempProgress.Height:=ListBox.Canvas.TextHeight('Iy');
    TempProgress.DoPaintOnXY(ListBox.Canvas,r.Left+ListBox.Canvas.TextWidth(InfoText)+10,r.Top);
   end;
  end;
  ListBox.Canvas.Font.Style:=[];
 end;

 if ItemData=LINE_INFO_OK then
 begin
  if Infos[index]<>'' then
  begin
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexProcessedRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
 end;

 if ItemData=LINE_INFO_DB then
 begin
  if Infos[index]<>'' then
  begin
   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexDBRecord].Handle,16,16,0,0,DI_NORMAL);
  aRect.Left:=aRect.Left+20;
 end;


 if ItemData=LINE_INFO_GREETING then
 begin

   r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexAdminToolsRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  Text:='';
 end;


 if ItemData=LINE_INFO_PLUS then
 begin
  if Infos[index]<>'' then
  begin
   aRect.Left:=aRect.Left+10;
   r:=Rect(aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
   aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
   InfoText:=Infos[index];
   ListBox.Canvas.Font.Style:=[fsBold];
   DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
   ListBox.Canvas.Font.Style:=[];
  end;

  DrawIconEx(ListBox.Canvas.Handle,aRect.Left+10,aRect.Top,Icons[IndexPlusRecord].Handle,16,16,0,0,DI_NORMAL);
  aRect.Left:=aRect.Left+30;
 end;

 if ItemData=LINE_INFO_WARNING then
 begin
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexWarningRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
  aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
  InfoText:=TEXT_MES_WARNING+':';
  ListBox.Canvas.Font.Style:=[fsBold];
  DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
  ListBox.Canvas.Font.Style:=[];
 end;

 if ItemData=LINE_INFO_ERROR then
 begin
  DrawIconEx(ListBox.Canvas.Handle,aRect.Left,aRect.Top,Icons[IndexErrorRecord].Handle,16,16,0,0,DI_NORMAL);

  aRect.Left:=aRect.Left+20;
  r:=Rect( aRect.Left,aRect.Top,aRect.Right,aRect.Top+ListBox.Canvas.TextHeight('Iy'));
  aRect.Top:=aRect.Top+ListBox.Canvas.TextHeight('Iy');
  InfoText:=TEXT_MES_ERROR+':';
  ListBox.Canvas.Font.Style:=[fsBold];
  DrawText(ListBox.Canvas.Handle,PChar(InfoText),Length(InfoText), r ,0);
  ListBox.Canvas.Font.Style:=[];
 end;

 DrawText(ListBox.Canvas.Handle,PChar(Text),Length(Text), aRect,DT_NOPREFIX+DT_LEFT+DT_WORDBREAK);
end;

function CalcBitmapToJPEGCompressSize(Bitmap : TBitmap; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
var
  Jpeg : TJpegImage;
  ms:TMemoryStream;
begin
 Jpeg := TJpegImage.Create;
 Jpeg.Assign(Bitmap);
 if CompressionRate<1 then CompressionRate:=1;
 if CompressionRate>100 then CompressionRate:=100;
 Jpeg.CompressionQuality:=CompressionRate;
 Jpeg.Compress;

 ms:=TMemoryStream.Create;
 Jpeg.SaveToStream(ms);
 Jpeg.Free;
 JpegImageResampled:=TJpegImage.Create;
 ms.Seek(0,soFromBeginning);
 JpegImageResampled.LoadFromStream(ms);
 Result:=ms.Size;
 ms.Free;
end;

function CalcJpegResampledSize(Jpeg : TJpegImage; Size : integer; CompressionRate : byte; out JpegImageResampled : TJpegImage) : int64;
var
  Bitmap, OutBitmap : TBitmap;
  w, h : integer;
begin
 Bitmap:=TBitmap24.Create('CalcJpegResampledSize.Bitmap');
 Bitmap.Assign(Jpeg);
 OutBitmap:=TBitmap24.Create('CalcJpegResampledSize.OutBitmap');
 w:=Jpeg.Width;
 h:=Jpeg.Height;
 ProportionalSize(Size,Size,w,h);
 DoResize(w,h,Bitmap,OutBitmap);
 Bitmap.Free;
 Result:=CalcBitmapToJPEGCompressSize(OutBitmap,CompressionRate,JpegImageResampled);
 OutBitmap.Free;
end;

procedure ConvertTo32BitImageList(const ImageList: TImageList);
const
  Mask: array[Boolean] of Longint = (0, ILC_MASK);
var
  TemporyImageList: TImageList;
begin
  // add to uses: commctrl, consts;
  if Assigned(ImageList) then
  begin
    TemporyImageList := TImageList.Create(nil);
    try
      TemporyImageList.Assign(ImageList);
      with ImageList do
      begin
        Masked:=false;
        ImageList.Handle := ImageList_Create(Width, Height, ILC_COLOR32 or Mask[Masked], 0, AllocBy);
        if not ImageList.HandleAllocated then
        begin
          raise EInvalidOperation.Create('');
        end;
      end;
      ImageList.AddImages(TemporyImageList);
    finally
      TemporyImageList.Free;
    end;
  end;
end;

procedure LoadPNGImage32bit(PNG : TPNGGraphic; Bitmap : TBitmap; BackGroundColor : TColor);
var
  i, j : integer;
  p : PARGB;
  pl : PARGB32;
  r,g,b : byte;
begin
 r:=GetRValue(BackGroundColor);
 g:=GetGValue(BackGroundColor);
 b:=GetBValue(BackGroundColor);
 Bitmap.Width:=PNG.Width;
 Bitmap.Height:=PNG.Height;
 Bitmap.PixelFormat:=pf24bit;
 for i:=0 to PNG.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  pl:=PNG.ScanLine[i];
  for j:=0 to PNG.Width-1 do
  begin
   p[j].r:=Round(pl[j].r*(pl[j].l/255)+r*(1-pl[j].l/255));
   p[j].g:=Round(pl[j].g*(pl[j].l/255)+g*(1-pl[j].l/255));
   p[j].b:=Round(pl[j].b*(pl[j].l/255)+b*(1-pl[j].l/255));
  end;
 end;
end;

procedure FillColorEx(Bitmap : TBitmap; Color : TColor);
var
  i, j : integer;
  p : PARGB;
  r, g, b : byte;
begin
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  for i:=0 to Bitmap.Height-1 do
  begin
    p:=Bitmap.ScanLine[i];
    for j:=0 to Bitmap.Width-1 do
    begin
      p[j].r := r;
      p[j].g := g;
      p[j].b := b;
    end;
  end;
end;

procedure LoadBMPImage32bit(BMP : TBitmap; Bitmap : TBitmap; BackGroundColor : TColor);
var
  i, j : integer;
  p : PARGB;
  pl : PARGB32;
  r,g,b : byte;
begin
 r:=GetRValue(BackGroundColor);
 g:=GetGValue(BackGroundColor);
 b:=GetBValue(BackGroundColor);
 Bitmap.Width:=BMP.Width;
 Bitmap.Height:=BMP.Height;
 Bitmap.PixelFormat:=pf24bit;
 for i:=0 to BMP.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  pl:=BMP.ScanLine[i];
  for j:=0 to BMP.Width-1 do
  begin
   p[j].r:=Round(pl[j].r*(pl[j].l/255)+r*(1-pl[j].l/255));
   p[j].g:=Round(pl[j].g*(pl[j].l/255)+g*(1-pl[j].l/255));
   p[j].b:=Round(pl[j].b*(pl[j].l/255)+b*(1-pl[j].l/255));
  end;
 end;
end;

procedure LoadGIFImage32bit(GIF : TGIFSubImage; Bitmap : TBitmap; BackGroundColorIndex : integer; BackGroundColor : TColor);
var
  i, j : integer;
  p : PARGB;
  r,g,b : byte;
begin
 r:=GetRValue(BackGroundColor);
 g:=GetGValue(BackGroundColor);
 b:=GetBValue(BackGroundColor);
 Bitmap.PixelFormat:=pf24bit;
 for i:=0 to GIF.Top-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to Bitmap.Width-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top+GIF.Height to Bitmap.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to Bitmap.Width-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top to GIF.Top+GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=0 to GIF.Left-1 do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=GIF.Top to GIF.Top+GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i];
  for j:=GIF.Left+GIF.Width-1 to Bitmap.Width-2  do
  begin
   p[j].r:=r;
   p[j].g:=g;
   p[j].b:=b;
  end;
 end;
 for i:=0 to GIF.Height-1 do
 begin
  p:=Bitmap.ScanLine[i+GIF.Top];
  for j:=0 to GIF.Width-1 do
  begin
   if GIF.Pixels[j,i]=BackGroundColorIndex then
   begin
    p[j+GIF.Left].r:=r;
    p[j+GIF.Left].g:=g;
    p[j+GIF.Left].b:=b;
   end;
  end;
 end;
end;

procedure LoadImageX(Image: TGraphic; Bitmap: TBitmap; BackGround : TColor);
var
  PNG : TPNGGraphic;
  BMP : TBitmap;
begin
 if Image is TPNGGraphic then
 begin
  PNG:=(Image as TPNGGraphic);
  if PNG.PixelFormat=pf32bit then
  begin
   if (Bitmap.Width<>Image.Width) or (Image.Height<>Bitmap.Height) then
   begin
    Bitmap.Width:=Image.Width;
    Bitmap.Height:=Image.Height;
   end;
   LoadPNGImage32bit(Image as TPNGGraphic,Bitmap,BackGround);
   exit;
  end;
 end;
 if Image is TBitmap then
 if not (Image is TPSDGraphic) or PSDTransparent then
 if (Image as TBitmap).PixelFormat=pf32bit then
 begin
  BMP:=(Image as TBitmap);
  if (Bitmap.Width<>Image.Width) or (Image.Height<>Bitmap.Height) then
  begin
   Bitmap.Width:=Image.Width;
   Bitmap.Height:=Image.Height;
  end;
  LoadBMPImage32bit(BMP,Bitmap,BackGround);
  exit;
 end;

 if Image is TGIFImage then
 begin
  if not (Image as TGIFImage).Images[0].Empty then
  if (Image as TGIFImage).Images[0].Transparent then
  begin
   Bitmap.Assign(Image);
   if (Image as TGIFImage).Images[0].GraphicControlExtension<>nil then
   LoadGIFImage32bit((Image as TGIFImage).Images[0],Bitmap,(Image as TGIFImage).Images[0].GraphicControlExtension.TransparentColorIndex,BackGround);
   exit;
  end;
 end;
 Bitmap.Assign(Image);
end;

procedure DoResize(Width,Height : integer; S,D : TBitmap);
begin
 if (Width=0) or (Height=0) then exit;
 if (S.Width=0) or (S.Height=0) then exit;
 if (Width/S.Width>1) or (Height/S.Height>1) then
 begin
  Interpolate(0,0,Width,Height,Rect(0,0,S.Width,S.Height),S,D);
 end else
 begin
  if ((S.Width div Width>=8) or (S.Height div Height>=8)) and (S.Width>2) and (S.Height>2) then
  begin
   QuickReduce(Width,Height,S,D)
  end else
  begin
   if Width/S.Width>ZoomSmoothMin then
   begin
    SmoothResize(Width,Height,S,D);
   end else
   begin
    StretchCool(Width,Height,S,D);
   end;
  end;
 end;
end;

procedure StretchCool(x, y, Width, Height : Integer; var S, D : TBitmap);
var
  i,j,k,p,Sheight1:integer;
  p1: pargb;
  col,r,g,b : integer;
  Sh, Sw : Extended;
  Xp : array of PARGB;
  s_h, s_w : integer;
begin
 s.PixelFormat:=pf24bit;
 d.PixelFormat:=pf24bit;
 if width+x>d.Width then
 d.Width:=width+x;
 if Height+y>d.Height then
 d.Height:=height+y; 
 Sh:=S.height/height;
 Sw:=S.width/width;
 Sheight1:=S.height-1;
 SetLength(Xp,S.height);
 for i:=0 to Sheight1 do
 Xp[i]:=s.ScanLine[i];
 s_w := S.Width-1;
 s_h := S.Height-1;
 for i:=Max(0,y) to height+y-1 do
 begin
  p1:=d.ScanLine[i];
  for j:=0 to  width-1 do
  begin
   col:=0;
   r:=0;
   g:=0;
   b:=0;
   for k:=Round(Sh*(i-y)) to Round(Sh*(i+1-y))-1 do
   begin
    if k > s_h then break;
    if k < 0 then continue;
    for p:=Round(Sw*j) to Round(Sw*(j+1))-1 do
    begin
     if p > s_w then break;
     inc(col);
     inc(r,Xp[k,p].r);
     inc(g,Xp[k,p].g);
     inc(b,Xp[k,p].b);
    end;
   end;
   if (col<>0) and (j+x>0) then
   begin
    p1[j+x].r:=r div col;
    p1[j+x].g:=g div col;
    p1[j+x].b:=b div col;
   end;
  end;
 end;
end;

procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap);
var
  z1, z2: single;
  k: single;
  i, j: integer;
  dw,dh, xo, yo: integer;
  x1r,y1r : extended;
  Xs, Xd : array of PARGB;
  dx, dy : Extended;
begin
  S.PixelFormat:=Pf24bit;
  D.PixelFormat:=Pf24bit;
  D.Width:=Math.Max(D.Width,x+Width);
  D.height:=Math.Max(D.height,y+Height);
  dw:=Math.Min(D.Width-x,x+Width);
  dh:=Math.Min(D.height-y,y+Height);
  dx:=(Width)/(Rect.Right-Rect.Left-1);
  dy:=(Height)/(Rect.Bottom-Rect.Top-1);
  if (dx<1) and (dy<1) then exit;
  SetLength(Xs,S.Height);
  for i:=0 to S.Height - 1 do
  Xs[i]:=S.scanline[i];
  SetLength(Xd,D.Height);
  for i:=0 to D.Height - 1 do
  Xd[i]:=D.scanline[i];
  try

  for i := 0 to min(Round((Rect.Bottom-Rect.Top-1)*dy)-1,dh-1) do begin
      yo := Trunc(i / dy)+Rect.Top;
      y1r:= Trunc(i / dy) * dy;
      if yo>S.height then Break;
    for j := 0 to min(Round((Rect.Right-Rect.Left-1)*dx)-1,dw-1) do begin
      xo := Trunc(j / dx)+Rect.Left;
      x1r:= Trunc(j / dx) * dx;
      if xo>S.Width then Continue;
      begin
       if i+y<0 then continue; 
       if j+x<0 then continue;
       z1 := ((Xs[yo ,xo+ 1].r - Xs[yo,xo].r)/ dx)*(j - x1r) + Xs[yo,xo].r;
       z2 := ((Xs[yo+1,xo+1].r - Xs[yo+1,xo].r) / dx)*(j - x1r) + Xs[yo+1,xo].r;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].r := Round(i * k + z1 - y1r * k);
       z1 := ((Xs[yo ,xo+ 1].g - Xs[yo,xo].g)/ dx)*(j - x1r) + Xs[yo,xo].g;
       z2 := ((Xs[yo+1,xo+1].g - Xs[yo+1,xo].g) / dx)*(j - x1r) + Xs[yo+1,xo].g;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].g := Round(i * k + z1 - y1r * k);
       z1 := ((Xs[yo ,xo+ 1].b - Xs[yo,xo].b)/ dx)*(j - x1r) + Xs[yo,xo].b;
       z2 := ((Xs[yo+1,xo+1].b - Xs[yo+1,xo].b) / dx)*(j - x1r) + Xs[yo+1,xo].b;
       k := (z2 - z1) / dy;
       Xd[i+y,j+x].b := Round(i * k + z1 - y1r * k);
      end;
    end;
  end;
 except
  end;
end;

procedure Rotate180A(var im : tbitmap);
var
  i, j : integer;
  p1, p2 : pargb;
  image : Tbitmap;
begin
 im.PixelFormat:=pf24bit;
 image:=Tbitmap.create;
 image.PixelFormat:=pf24bit;
 image.Assign(im);
 for i:=0 to image.Height-1 do
 begin
  p1:=image.ScanLine[i];
  p2:=im.ScanLine[image.Height-i-1];
  for j:=0 to image.Width-1 do
  begin
   p2[j].r:=p1[image.Width-1-j].r;
   p2[j].g:=p1[image.Width-1-j].g;
   p2[j].b:=p1[image.Width-1-j].b;
  end;
 end;
 image.free;
end;

procedure Rotate270A(var im : tbitmap);
var
 i, j : integer;
 p1 : pargb;
 p : array of pargb;
 image : tbitmap;
begin
 im.PixelFormat:=pf24bit;
 image:=tbitmap.create;
 image.PixelFormat:=pf24bit;
 image.Assign(im);
 im.Width:=image.Height;
 im.Height:=image.Width;
 setlength(p,image.Width);
 for i:=0 to image.Width-1 do
 p[i]:=im.ScanLine[image.Width-1-i];
 for i:=0 to image.Height-1 do
 begin
  p1:=image.ScanLine[i];
  for j:=0 to image.Width-1 do
  begin
   p[j,i].r:=p1[j].r;
   p[j,i].g:=p1[j].g;
   p[j,i].b:=p1[j].b;
  end;
 end;
 image.Free;
end;

procedure Rotate90A(var im : tbitmap);
var
 i, j : integer;
 p1 : pargb;
 p : array of pargb;
 image : tbitmap;
begin
 im.PixelFormat:=pf24bit;
 image:=tbitmap.create;
 image.PixelFormat:=pf24bit;
 image.Assign(im);
 im.Width:=image.Height;
 im.Height:=image.Width;
 setlength(p,image.Width);
 for i:=0 to image.Width-1 do
 p[i]:=im.ScanLine[i];
 for i:=0 to image.Height-1 do
 begin
  p1:=image.ScanLine[image.Height-i-1];
  for j:=0 to image.Width-1 do
  begin
   p[j,i].r:=p1[j].r;
   p[j,i].g:=p1[j].g;
   p[j,i].b:=p1[j].b;
  end;
 end;
 image.Free;
end;

procedure QuickReduce(NewWidth, NewHeight : integer; BmpIn, BmpOut : TBitmap);
var
 x, y, xi1, yi1, xi2, yi2, xx, yy, lw1 : integer;
 bufw, bufh, outw, outh : integer;
 sumr, sumb, sumg, pixcnt : dword;
 adrIn, adrOut, adrLine0, deltaLine, deltaLine2 : Integer;
begin    
 {$R-}
 BmpOut.Width := NewWidth;
 BmpOut.Height := NewHeight;
 BmpIn.PixelFormat := pf24bit;
 BmpOut.PixelFormat := pf24bit;
 bufw := BmpIn.Width;
 bufh := BmpIn.Height;
 outw := BmpOut.Width;
 outh := BmpOut.Height;
 adrLine0 := Integer(bmpIn.ScanLine[0]);
 deltaLine := Integer(BmpIn.ScanLine[1]) - adrLine0;
 yi2 := 0;
 for y := 0 to outh-1 do
 begin
   adrOut := DWORD(BmpOut.ScanLine[y]);
   yi1 := yi2 {+ 1};
   yi2 := ((y+1) * bufh) div outh - 1;
   if yi2 > bufh-1 then yi2 := bufh;
   xi2 := 0;
   for x := 0 to outw-1 do
   begin
     xi1 := xi2 {+ 1};
     xi2 := ((x+1) * bufw) div outw - 1;
     if xi2 > bufw-1 then xi2 := bufw-1; //
     lw1 := xi2-xi1+1;
     deltaLine2 := deltaLine - lw1*3;
     sumb := 0;
     sumg := 0;
     sumr := 0;
     adrIn := adrLine0 + yi1*deltaLine + xi1*3;
     for yy := yi1 to yi2 do
     begin
       for xx := 1 to lw1 do
       begin
         Inc(sumb, PByte(adrIn+0)^);
         Inc(sumg, PByte(adrIn+1)^);
         Inc(sumr, PByte(adrIn+2)^);
         Inc(adrIn, 3);
       end;
       Inc (adrIn, deltaLine2);
     end;
     pixcnt := (yi2-yi1+1)*lw1;
     if pixcnt<>0 then
     begin
      PByte(adrOut+0)^ := sumb div pixcnt;
      PByte(adrOut+1)^ := sumg div pixcnt;
      PByte(adrOut+2)^ := sumr div pixcnt;
     end;
     Inc(adrOut, 3);
   end;
 end;
end;

procedure StretchCool(Width, Height : integer; var S,D : TBitmap);
var
  i, j, k, p : Integer;
  p1 : PARGB;
  col, r, g, b, Sheight1, s_h, s_w : integer;
  Sh, Sw : Extended;
  Xp : array of PARGB;
begin
 If Width=0 then exit;
 If Height=0 then exit;
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=Width;
 D.Height:=Height;
 Sh:=S.Height/Height;
 Sw:=S.Width/Width;
 Sheight1:=S.height-1;
 SetLength(Xp,S.height);
 s_h:=S.Height;
 s_w:=S.Width;
 for i:=0 to Sheight1 do
 Xp[i]:=S.ScanLine[i];
 for i:=0 to Height-1 do
 begin
  p1:=D.ScanLine[i];
  for j:=0 to Width-1 do
  begin
   col:=0;
   r:=0;
   g:=0;
   b:=0;
   for k:=Round(Sh*i) to Round(Sh*(i+1))-1 do
   begin
    if k>s_h-1 then continue;
    for p:=Round(Sw*j) to Round(Sw*(j+1))-1 do
    begin
     if p>s_w-1 then continue;
     inc(col);
     inc(r,Xp[k,p].r);
     inc(g,Xp[k,p].g);
     inc(b,Xp[k,p].b);
    end;
   end;
   if col<>0 then
   begin
    p1[j].r:=r div col;
    p1[j].g:=g div col;
    p1[j].b:=b div col;
   end;
  end;
 end;
end;

Procedure QuickReduceWide(Width, Height : integer; Var S,D : TBitmap);
begin
 if (Width=0) or (Height=0) then exit;
 if ((S.Width div Width>=8) or (S.Height div Height>=8)) and (S.Width>2) and (S.Height>2) then
 QuickReduce(Width,Height,S,D) else
 StretchCool(Width,Height,S,D)
end;

end.
