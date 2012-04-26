unit FastBMP;

interface          //  TFastBMP v1.5
                   //    Gordon Alex Cowie <gfody@jps.net>
uses Windows,      //    www.jps.net/gfody
     FastRGB;      //
                   //    This unit is Freeware. Comments, Ideas,
const              //    Optimizations, Corrections, and Effects
{$IFDEF VER90}     //    are welcome. See FastLIB.hlp for a brief
  hSection=nil;    //    documentation. (4/14/99)
{$ELSE}
  hSection=0;
{$ENDIF}

type

TFastBMP=class(TFastRGB)
  hDC,
  Handle:     Integer;
  bmInfo:     TBitmapInfo;
  constructor Create;
  destructor  Destroy; override;
  // initializers
  procedure   SetSize(fWidth,fHeight:Integer); override;
  procedure   LoadFromFile(FileName:string);
  procedure   SaveToFile(FileName:string);
  procedure   LoadFromhBmp(hBmp:Integer);
  procedure   LoadFromRes(hInst:Integer;sName:string);
  procedure   SetInterface(fWidth,fHeight:Integer;pBits:Pointer);
  procedure   Copy(FB:TFastBMP);
  // GDI drawing methods
  procedure   Draw(fdc,x,y:Integer); override;
  procedure   Stretch(fdc,x,y,w,h:Integer); override;
  procedure   DrawRect(fdc,x,y,w,h,sx,sy:Integer); override;
  procedure   StretchRect(fdc,x,y,w,h,sx,sy,sw,sh:Integer); override;
  procedure   TileDraw(fdc,x,y,w,h:Integer); override;
  // native conversions
  procedure   Resize(Dst:TFastRGB); override;
  procedure   SmoothResize(Dst:TFastRGB); override;
  procedure   CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer); override;
  procedure   Tile(Dst:TFastRGB); override;
  function    CountColors:Longint;
end;

implementation

constructor TFastBMP.Create;
begin
  hDC:=CreateCompatibleDC(0);
  Width:=0; Height:=0; Bits:=nil; Pixels:=nil;
  bmInfo.bmiHeader.biSize:=SizeOf(TBitmapInfoHeader);
  bmInfo.bmiHeader.biPlanes:=1;
  bmInfo.bmiHeader.biBitCount:=24;
  bmInfo.bmiHeader.biCompression:=BI_RGB;
end;

destructor TFastBMP.Destroy;
begin
  DeleteDC(hDC);
  DeleteObject(Handle);
  FreeMem(Pixels);
  inherited Destroy;
end;

procedure TFastBMP.SetSize(fWidth,fHeight:Integer);
var
x: Longint;
i: Integer;
begin
  if(fWidth=Width)and(fHeight=Height)then Exit;
  Width:=fWidth; Height:=fHeight;
  bmInfo.bmiHeader.biWidth:=Width;
  bmInfo.bmiHeader.biHeight:=Height;
  Handle:=CreateDIBSection(0,bmInfo,DIB_RGB_COLORS,Bits,hSection,0);
  DeleteObject(SelectObject(hDC,Handle));
  RowInc:=((Width*24+31)shr 5)shl 2;
  Gap:=Width mod 4;
  Size:=RowInc*Height;
  GetMem(Pixels,Height*4);
  x:=Longint(Bits);
  for i:=0 to Height-1 do
  begin
    Pixels[i]:=Pointer(x);
    Inc(x,RowInc);
  end;
end;

procedure TFastBMP.LoadFromFile(FileName:string);
type
TByteArray = array[0..0]of Byte;
PByteArray =^TByteArray;
TBMInfo256 = record
  bmiHeader: TBitmapInfoHeader;
  bmiColors: array[0..255]of TRGBQuad;
end;
var
hFile,
bSize: Integer;
iRead: Cardinal;

fData: TofStruct;
fHead: TBitmapFileHeader;
fInfo: TBMInfo256;
fBits: PByteArray;
begin
  hFile:=OpenFile(PChar(FileName),fData,OF_READ);
  ReadFile(hFile,fHead,SizeOf(fHead),iRead,nil);
  ReadFile(hFile,fInfo,SizeOf(fInfo),iRead,nil);
  SetFilePointer(hFile,fHead.bfOffBits,nil,FILE_BEGIN);
  SetSize(fInfo.bmiHeader.biWidth,Abs(fInfo.bmiHeader.biHeight));
  bSize:=(((fInfo.bmiHeader.biWidth*fInfo.bmiHeader.biBitCount+31)shr 5)shl 2)*fInfo.bmiHeader.biHeight;
  GetMem(fBits,bSize);
  ReadFile(hFile,fBits^,bSize,iRead,nil);
  StretchDIBits(hDC,0,0,Width,Height,0,0,Width,Height,fBits,PBitmapInfo(@fInfo)^,DIB_RGB_COLORS,SRCCOPY);
  FreeMem(fBits);
  CloseHandle(hFile);
end;

procedure TFastBMP.SaveToFile(FileName:string);
type
TByteArray = array[0..0]of Byte;
PByteArray =^TByteArray;
var
hFile:  Integer;
iWrote: Cardinal;

fData:  TofStruct;
fHead:  TBitmapFileHeader;
begin
  // saves upside down.. just Flop from FastFX if you want
  hFile:=OpenFile(PChar(FileName),fData,OF_CREATE or OF_WRITE);
  fHead.bfType:=19778; // "BM"
  fHead.bfSize:=SizeOf(fHead)+SizeOf(bmInfo)+Size;
  fHead.bfOffBits:=SizeOf(fHead)+SizeOf(bmInfo);
  WriteFile(hFile,fHead,SizeOf(fHead),iWrote,nil);
  bmInfo.bmiHeader.biHeight:=Abs(bmInfo.bmiHeader.biHeight);
  WriteFile(hFile,bmInfo,SizeOf(bmInfo),iWrote,nil);
  bmInfo.bmiHeader.biHeight:=-bmInfo.bmiHeader.biHeight;
  WriteFile(hFile,PByteArray(Bits)^,Size,iWrote,nil);
  CloseHandle(hFile);
end;

procedure TFastBMP.LoadFromhBmp(hBmp:Integer);
var
Bmp:   TBitmap;
memDC: Integer;
begin
  GetObject(hBmp,SizeOf(Bmp),@Bmp);
  SetSize(Bmp.bmWidth,Bmp.bmHeight);
  memDC:=CreateCompatibleDC(0);
  SelectObject(memDC,hBmp);
  GetDIBits(memDC,hBmp,0,Height,Bits,bmInfo,DIB_RGB_COLORS);
  DeleteDC(memDC);
end;

procedure TFastBMP.LoadFromRes(hInst:Integer;sName:string);
var
hBmp: Integer;
begin
  hBmp:=LoadImage(hInst,PChar(sName),IMAGE_BITMAP,0,0,0);
  LoadFromhBmp(hBmp);
  DeleteObject(hBmp);
end;

procedure TFastBMP.SetInterface(fWidth,fHeight:Integer;pBits:Pointer);
var
x: Longint;
i: Integer;
begin
  Width:=fWidth;
  Height:=Abs(fHeight);
  bmInfo.bmiHeader.biWidth:=fWidth;
  bmInfo.bmiHeader.biHeight:=fHeight;
  RowInc:=((Width*24+31)shr 5)shl 2;
  Gap:=Width mod 4;
  Size:=RowInc*Height;
  ReallocMem(Pixels,Height*4);
  Bits:=pBits;
  x:=Longint(Bits);
  for i:=0 to fHeight-1 do
  begin
    Pixels[i]:=Pointer(x);
    Inc(x,RowInc);
  end;
end;

procedure TFastBMP.Copy(FB:TFastBMP);
begin
  SetSize(FB.Width,FB.Height);
  CopyMemory(Bits,FB.Bits,Size);
end;

procedure TFastBMP.Draw(fdc,x,y:Integer);
begin
  StretchDIBits(fdc,x,y,Width,Height,0,0,Width,
    Height,Bits,bmInfo,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFastBMP.Stretch(fdc,x,y,w,h:Integer);
begin
  SetStretchBltMode(fdc,STRETCH_DELETESCANS);
  StretchDIBits(fdc,x,y,w,h,0,0,Width,Height,
    Bits,bmInfo,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFastBMP.DrawRect(fdc,x,y,w,h,sx,sy:Integer);
begin
  StretchDIBits(fdc,x,y,w,h,sx,sy,w,h,
    Bits,bmInfo,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFastBMP.StretchRect(fdc,x,y,w,h,sx,sy,sw,sh:Integer);
begin
  SetStretchBltMode(fdc,STRETCH_DELETESCANS);
  StretchDIBits(fdc,x,y,w,h,sx,sy,sw,sh,
    Bits,bmInfo,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFastBMP.TileDraw(fdc,x,y,w,h:Integer);
var
wd,hd,
hBmp,
memDC: Integer;
begin
  if(Width=0)or(Height=0)then Exit;
  memDC:=CreateCompatibleDC(fdc);
  hBmp:=CreateCompatibleBitmap(fdc,w,h);
  SelectObject(memDC,hBmp);
  Draw(memDC,0,0);
  wd:=Width;
  hd:=Height;
  while wd<w do
  begin
    BitBlt(memDC,wd,0,wd*2,h,memDC,0,0,SRCCOPY);
    Inc(wd,wd);
  end;
  while hd<h do
  begin
    BitBlt(memDC,0,hd,w,hd*2,memDC,0,0,SRCCOPY);
    Inc(hd,hd);
  end;
  BitBlt(fdc,x,y,w,h,memDC,0,0,SRCCOPY);
  DeleteDC(memDC);
  DeleteObject(hBmp);
end;

procedure TFastBMP.Resize(Dst:TFastRGB);
var
xCount,
yCount,
x,y,xP,yP,
xD,yD,
yiScale,
xiScale:  Integer;
xScale,
yScale:   Single;
Read,
Line:     PLine;
Tmp:      TFColor;
pc:       PFColor;
begin
  if(Dst.Width=0)or(Dst.Height=0)then Exit;
  if(Dst.Width=Width)and(Dst.Height=Height)then
  begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;

  xScale:=Dst.Width/Width;
  yScale:=Dst.Height/Height;
  if(xScale<1)or(yScale<1)then
  begin  // shrinking
    xiScale:=(Width shl 16) div Dst.Width;
    yiScale:=(Height shl 16) div Dst.Height;
    yP:=0;
    for y:=0 to Dst.Height-1 do
    begin
      xP:=0;
      read:=Pixels[yP shr 16];
      pc:=@Dst.Pixels[y,0];
      for x:=0 to Dst.Width-1 do
      begin
        pc^:=Read[xP shr 16];
        Inc(pc);
        Inc(xP,xiScale);
      end;
      Inc(yP,yiScale);
    end;
  end
  else   // zooming
  begin
    yiScale:=Round(yScale+0.5);
    xiScale:=Round(xScale+0.5);
    GetMem(Line,Dst.Width*3);
    for y:=0 to Height-1 do
    begin
      yP:=Trunc(yScale*y);
      Read:=Pixels[y];
      for x:=0 to Width-1 do
      begin
        xP:=Trunc(xScale*x);
        Tmp:=Read[x];
        for xCount:=0 to xiScale-1 do
        begin
          xD:=xCount+xP;
          if xD>=Dst.Width then Break;
          Line[xD]:=Tmp;
        end;
      end;
      for yCount:=0 to yiScale-1 do
      begin
        yD:=yCount+yP;
        if yD>=Dst.Height then Break;
        CopyMemory(Dst.Pixels[yD],Line,Dst.Width*3);
      end;
    end;
    FreeMem(Line);
  end;
end;

// huge thanks to Vit Kovalcik for this awesome function!
// performs a fast bilinear interpolation <vkovalcik@iname.com>
procedure TFastBMP.SmoothResize(Dst:TFastRGB);
var
x,y,xP,yP,
yP2,xP2:     Integer;
Read,Read2:  PLine;
t,z,z2,iz2:  Integer;
pc:PFColor;
w1,w2,w3,w4: Integer;
Col1,Col2:   PFColor;
begin
  if(Dst.Width<1)or(Dst.Height<1)then Exit;
  if Width=1 then
  begin
    Resize(Dst);
    Exit;
  end;
  if(Dst.Width=Width)and(Dst.Height=Height)then
  begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;
  xP2:=((Width-1)shl 15)div Dst.Width;
  yP2:=((Height-1)shl 15)div Dst.Height;
  yP:=0;
  for y:=0 to Dst.Height-1 do
  begin
    xP:=0;
    Read:=Pixels[yP shr 15];
    if yP shr 16<Height-1 then
      Read2:=Pixels[yP shr 15+1]
    else
      Read2:=Pixels[yP shr 15];
    pc:=@Dst.Pixels[y,0];
    z2:=yP and $7FFF;
    iz2:=$8000-z2;
    for x:=0 to Dst.Width-1 do
    begin
      t:=xP shr 15;
      Col1:=@Read[t];
      Col2:=@Read2[t];
      z:=xP and $7FFF;
      w2:=(z*iz2)shr 15;
      w1:=iz2-w2;
      w4:=(z*z2)shr 15;
      w3:=z2-w4;
      pc.b:=
        (Col1.b*w1+PFColor(Integer(Col1)+3).b*w2+
         Col2.b*w3+PFColor(Integer(Col2)+3).b*w4)shr 15;
      pc.g:=
        (Col1.g*w1+PFColor(Integer(Col1)+3).g*w2+
         Col2.g*w3+PFColor(Integer(Col2)+3).g*w4)shr 15;
      pc.r:=
        (Col1.r*w1+PFColor(Integer(Col1)+3).r*w2+
         Col2.r*w3+PFColor(Integer(Col2)+3).r*w4)shr 15;
      Inc(pc);
      Inc(xP,xP2);
    end;
    Inc(yP,yP2);
  end;
end;

procedure TFastBMP.CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer);
var
n1,n2: Pointer;
i:     Integer;
begin
  if x<0 then
  begin
    Dec(sx,x);
    Inc(w,x);
    x:=0;
  end;
  if y<0 then
  begin
    Dec(sy,y);
    Inc(h,y);
    y:=0;
  end;
  if sx<0 then
  begin
    Dec(x,sx);
    Inc(w,sx);
    sx:=0;
  end;
  if sy<0 then
  begin
    Dec(y,sy);
    Inc(h,sy);
    sy:=0;
  end;
  if(sx>Width-1)or(sy>Height-1)then Exit;

  if sx+w>Width     then Dec(w,(sx+w)-(Width));
  if sy+h>Height    then Dec(h,(sy+h)-(Height));
  if x+w>Dst.Width  then Dec(w,(x+w)-(Dst.Width));
  if y+h>Dst.Height then Dec(h,(y+h)-(Dst.Height));

  n1:=@Dst.Pixels[y,x];
  n2:=@Pixels[sy,sx];
  for i:=0 to h-1 do
  begin
    CopyMemory(n1,n2,w*3);
    n1:=Ptr(Integer(n1)+Dst.RowInc);
    n2:=Ptr(Integer(n2)+RowInc);
  end;
end;

procedure TFastBMP.Tile(Dst:TFastRGB);
var
w,h,cy,cx: Integer;
begin
  if(Dst.Width=0)or(Dst.Height=0)or
    (Width=0)or(Height=0)then Exit;
  CopyRect(Dst,0,0,Width,Height,0,0);
  w:=Width;
  h:=Height;
  cx:=Dst.Width;
  cy:=Dst.Height;
  while w<cx do
  begin
    Dst.CopyRect(Dst,w,0,w*2,h,0,0);
    Inc(w,w);
  end;
  while h<cy do
  begin
    Dst.CopyRect(Dst,0,h,w,h*2,0,0);
    Inc(h,h);
  end;
end;

// Vit's function, accurate to 256^3!
function TFastBMP.CountColors:Longint;
type
TSpace = array[0..255,0..255,0..31]of Byte;
PSpace =^TSpace;
var
x,y:   Integer;
Tmp:   PFColor;
Count: Longint;
Buff:  PByte;
Test:  Byte;
Space: PSpace;
begin
  New(Space);
  FillChar(Space^,SizeOf(TSpace),0);
  Tmp:=Bits;
  Count:=0;
  for y:=0 to Height-1 do
  begin
    for x:=0 to Width-1 do
    begin
      Buff:=@Space^[Tmp.r,Tmp.g,Tmp.b shr 3];
      Test:=(1 shl(Tmp.b and 7));
      if(Buff^ and Test)=0 then
      begin
        Inc(Count);
        Buff^:=Buff^ or Test;
      end;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+Gap);
  end;
  Result:=Count;
  Dispose(Space);
end;

end.
