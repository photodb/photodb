unit Fast256;

interface          //  TFast256 v1.1 (4-14-99)
                   //    Gordon Alex Cowie <gfody@jps.net>
uses Windows,      //    www.jps.net/gfody
     FastRGB,      //
     FastBMP;      //    This is a class just like TFastBMP
                   //    for handling 8bit DIBs. The Pixels
const              //    property isn't compatible with the
{$IFDEF VER90}     //    Pixels property in TFastRGB sorry.
  hSection=nil;    //    use TFast256(TFastRGB).Pixels[y,x]:=Byte
{$ELSE}
  hSection=0;
{$ENDIF}

type
TConversionMode=(cmGray,cmCut,cmDither);

TFColorEntry      = record b,g,r,a:Byte; end;
PFColorEntry      =^TFColorEntry;
TFColorEntryArray = array[0..255]of TFColorEntry;
PFColorEntryArray =^TFColorEntryArray;

TBitmapInfo256 = record
  bmiHeader: TBitmapInfoHeader;
  bmiColors: TFColorEntryArray;
end;

TBytes  = array[0..0]of Byte;
PBytes  =^TBytes;
TPBytes = array[0..0]of PBytes;
PPBytes =^TPBytes;

TFast256=class(TFastRGB)
  hDC,
  Handle:     Integer;
  bmInfo:     TBitmapInfo256;
  Colors:     PFColorEntryArray;
  Pixels:     PPBytes;
  constructor Create;
  destructor  Destroy; override;
  // initializers
  procedure   SetSize(fWidth,fHeight:Integer); override;
  procedure   LoadFromFile(FileName:string;cm:TConversionMode);
  procedure   SaveToFile(FileName:string);
  procedure   LoadFromhBmp(hBmp:Integer;cm:TConversionMode);
  procedure   LoadFromRes(hInst:Integer;sName:string;cm:TConversionMode);
  procedure   LoadFromRGBExact(FB:TFastRGB);
  procedure   MakeGrayscale(FB:TFastRGB);
  procedure   LoadFromRGB(FB:TFastRGB;cm:TConversionMode);
  procedure   SetInterface(fWidth,fHeight:Integer;pBits:Pointer);
  procedure   Copy(FB:TFast256);
  // color table tools
  procedure   RGB(ra,ga,ba:Integer);
  procedure   Contrast(Amount:Integer);
  procedure   Saturation(Amount:Integer);
  procedure   Lightness(Amount:Integer);
  procedure   FillColors(c1,c255:TFColor);
  procedure   ShiftColors(Amount:Integer);
  function    MakePalette: HPALETTE;
  // GDI drawing methods
  procedure   Draw(fdc,x,y:Integer); override;
  procedure   Stretch(fdc,x,y,w,h:Integer); override;
  procedure   DrawRect(fdc,x,y,w,h,sx,sy:Integer); override;
  procedure   StretchRect(fdc,x,y,w,h,sx,sy,sw,sh:Integer); override;
  procedure   TileDraw(fdc,x,y,w,h:Integer); override;
  // native conversions
  procedure   CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer); override;
  procedure   Tile(Dst:TFastRGB); override;
  procedure   Resize(Dst:TFastRGB); override;
  procedure   SmoothResize(Dst:TFastRGB); override;
end;

function Check256(FB:TFastRGB):Boolean;
function FRGBA(r,g,b,a:Byte):TFColorEntry;
function ColorToEntry(tf:TFColor):TFColorEntry;
function EntryToColor(tf:TFColorEntry):TFColor;

implementation

constructor TFast256.Create;
begin
  // only initializes some static properties:
  hDC:=CreateCompatibleDC(0);
  Width:=0; Height:=0; Pixels:=nil;
  bmInfo.bmiHeader.biSize:=SizeOf(TBitmapInfoHeader);
  bmInfo.bmiHeader.biPlanes:=1;
  bmInfo.bmiHeader.biBitCount:=8;
  bmInfo.bmiHeader.biCompression:=BI_RGB;
  Colors:=@bmInfo.bmiColors;
end;

destructor TFast256.Destroy;
begin
  DeleteDC(hDC);
  DeleteObject(Handle);
  ReallocMem(Pixels,0);
  inherited Destroy;
end;

procedure TFast256.SetSize(fWidth,fHeight:Integer);
var
x: Longint;
i: Integer;
begin
  if(fWidth=Width)and(fHeight=Height)then Exit;
  Width:=fWidth; Height:=fHeight;
  bmInfo.bmiHeader.biWidth:=Width;
  bmInfo.bmiHeader.biHeight:=Height;
  Handle:=CreateDIBSection(0,PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS,Bits,hSection,0);
  DeleteObject(SelectObject(hDC,Handle));
  RowInc:=((Width*8+31)shr 5)shl 2;
  Gap:=RowInc-Width;
  Size:=RowInc*Height;
  ReallocMem(Pixels,Height*4);
  x:=Longint(Bits);
  for i:=0 to fHeight-1 do
  begin
    Pixels[i]:=Pointer(x);
    Inc(x,RowInc);
  end;
end;

procedure TFast256.LoadFromFile(FileName:string;cm:TConversionMode);
var
hFile: Integer;
iRead: Cardinal;

tmp:   TFastBMP;
fData: TofStruct;
fHead: TBitmapFileHeader;
fInfo: TBitmapInfo256;
fBits: PBytes;
begin
  hFile:=OpenFile(PChar(FileName),fData,OF_READ);
  ReadFile(hFile,fHead,SizeOf(fHead),iRead,nil);
  ReadFile(hFile,fInfo,SizeOf(fInfo),iRead,nil);
  if fInfo.bmiheader.biBitCount<9 then
  begin
    SetSize(fInfo.bmiHeader.biWidth,Abs(fInfo.bmiHeader.biHeight));
    SetDIBColorTable(hDC,0,256,fInfo.bmiColors);
    bmInfo.bmiColors:=fInfo.bmiColors;
    SetFilePointer(hFile,fHead.bfOffBits,nil,FILE_BEGIN);
    GetMem(fBits,Size);
    ReadFile(hFile,fBits^,Size,iRead,nil);
    StretchDIBits(hDC,0,0,Width,Height,0,0,Width,Height,fBits,PBitmapInfo(@fInfo)^,DIB_RGB_COLORS,SRCCOPY);
    FreeMem(fBits);
    CloseHandle(hFile);
  end else
  begin
    CloseHandle(hFile);
    tmp:=TFastBMP.Create;
    tmp.LoadFromFile(FileName);
    LoadFromRGB(tmp,cm);
    tmp.free;
  end;
end;

procedure TFast256.SaveToFile(FileName:string);
var
hFile:  Integer;
iWrote: Cardinal;

fData:  TofStruct;
fHead:  TBitmapFileHeader;
begin
  // saves upside down.. just Flop from FastFX if you want
  hFile:=OpenFile(PChar(FileName),fData,OF_CREATE or OF_WRITE);
  fHead.bfType:=19778; // "BM"
  fHead.bfSize:=Size+SizeOf(fHead)+SizeOf(bmInfo);
  fHead.bfOffBits:=SizeOf(fHead)+SizeOf(bmInfo);
  WriteFile(hFile,fHead,SizeOf(fHead),iWrote,nil);
  bmInfo.bmiHeader.biHeight:=Abs(bmInfo.bmiHeader.biHeight);
  WriteFile(hFile,bmInfo,SizeOf(bmInfo),iWrote,nil);
  bmInfo.bmiHeader.biHeight:=-bmInfo.bmiHeader.biHeight;
  WriteFile(hFile,PBytes(Bits)^,Size,iWrote,nil);
  CloseHandle(hFile);
end;

// if hBmp.bpp>8 then LoadFromRGB is used
procedure TFast256.LoadFromhBmp(hBmp:Integer;cm:TConversionMode);
var
Bmp:   TBitmap;
memDC: Integer;
Tmp:   TFastBMP;
begin
  GetObject(hBmp,SizeOf(Bmp),@Bmp);
  if Bmp.bmBitsPixel<9 then
  begin
    SetSize(Bmp.bmWidth,Bmp.bmHeight);
    memDC:=CreateCompatibleDC(0);
    SelectObject(memDC,hBmp);
    GetDIBits(memDC,hBmp,0,Height,Bits,PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS);
    DeleteDC(memDC);
  end else
  begin
    Tmp:=TFastBMP.Create;
    Tmp.LoadFromhBmp(hBmp);
    LoadFromRGB(Tmp,cm);
    Tmp.Free;
  end;
end;

procedure TFast256.LoadFromRes(hInst:Integer;sName:string;cm:TConversionMode);
var
hBmp: Integer;
begin
  hBmp:=LoadImage(hInst,PChar(sName),IMAGE_BITMAP,0,0,LR_CREATEDIBSECTION);
  LoadFromhBmp(hBmp,cm);
  DeleteObject(hBmp);
end;

procedure TFast256.LoadFromRGBExact(FB:TFastRGB);
type
TSpace = array[0..255,0..255,0..255]of Word;
PSpace =^TSpace;
var
x,y,i: Integer;
pc:    PFColor;
pb:    PByte;
a:     PWord;
Space: PSpace;
begin
  New(Space);
  FillChar(Space^,SizeOf(TSpace),255);
  SetSize(FB.Width,FB.Height);
  pb:=Bits; pc:=FB.Bits;
  i:=0;
  for y:=0 to FB.Height-1 do
  begin
    for x:=0 to FB.Width-1 do
    begin
      a:=@Space^[pc.b,pc.g,pc.r];
      if a^=$FFFF then
      begin
        a^:=i;
        Colors[i].b:=pc.b;
        Colors[i].g:=pc.g;
        Colors[i].r:=pc.r;
        Inc(i);
      end;
      pb^:=a^;
      Inc(pb);
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+FB.Gap);
    pb:=Ptr(Integer(pb)+Gap);
  end;
  Dispose(Space);
end;

procedure TFast256.MakeGrayscale(FB:TFastRGB);
var
x,y,i: Integer;
p:     PByte;
Tmp:   PFColor;
Div3:  array[0..765]of Byte;
begin
  SetSize(FB.Width,FB.Height);
  x:=0; y:=0;
  for i:=0 to 255 do
  begin
    Div3[x]:=y; Inc(x);
    Div3[x]:=y; Inc(x);
    Div3[x]:=y; Inc(x);
    Inc(y);
  end;
  Tmp:=FB.Bits;
  p:=Bits;
  for y:=0 to FB.Height-1 do
  begin
    for x:=0 to FB.Width-1 do
    begin
      p^:=Div3[Tmp.b+Tmp.g+Tmp.r];
      Inc(Tmp);
      Inc(p);
    end;
    Tmp:=Ptr(Integer(Tmp)+FB.Gap);
    p:=Ptr(Integer(p)+Gap);
  end;
  for i:=0 to 255 do
  begin
    bmInfo.bmiColors[i].r:=i;
    bmInfo.bmiColors[i].g:=i;
    bmInfo.bmiColors[i].b:=i;
  end;
end;

// median-cut color quantization implemented by Vit - THANK YOU! ;-)
// FS dither now available!
procedure TFast256.LoadFromRGB(FB:TFastRGB;cm:TConversionMode);
type
TThreeInt   = record r,g,b:Integer;end;
PThreeInt   =^TThreeInt;
TLineErrors = array [-1..-1] of TThreeInt;
PLineErrors =^TLineErrors;
PCube       =^TCube;
TCube       = record
  X1,Y1,Z1,
  X2,Y2,Z2:   Byte;
end;

var
A,B,C,
D,E,F:   Integer;
Space:   array[0..31,0..31,0..31]of Byte;
Cubes:   array[0..255]of TCube;
Cl:      PFColor;
IC:      PFColorEntry;
CNum:    Byte;
PB:      PByte;
Cub:     PCube;
Lines:   array[0..1]of PLineErrors;
Ln,Nxt:  Integer;
PTI:     PThreeInt;
Dir:     ShortInt;

procedure OptimizeCube(Cb:PCube);
var
F,G,H,I: ShortInt;
begin
  A:=32; B:=32; C:=32;
  D:=-1; E:=-1; F:=-1;
  for G:=Cb.X1 to Cb.X2 do
  for H:=Cb.Y1 to Cb.Y2 do
  for I:=Cb.Z1 to Cb.Z2 do
  begin
    if Space[G,H,I] > 0 then
    begin
      if G<A then A:=G;
      if G>D then D:=G;
      if H<B then B:=H;
      if H>E then E:=H;
      if I<C then C:=I;
      if I>F then F:=I;
    end;
  end;
  Cb.X1:=A; Cb.Y1:=B; Cb.Z1:=C;
  Cb.X2:=D; Cb.Y2:=E; Cb.Z2:=F;
end;

begin

  if cm=cmGray then
  begin
    MakeGrayscale(FB);
    Exit;
  end;
  if Check256(FB) then
  begin
    LoadFromRGBExact(FB);
    Exit;
  end;

  SetSize(FB.Width,FB.Height);
  ZeroMemory(@Space,SizeOf(Space));

  Cl:=FB.Bits;
  for A:=0 to FB.Height-1 do
  begin
    for B:=0 to FB.Width-1 do
    begin
      Space[Cl.r shr 3,Cl.g shr 3,Cl.b shr 3]:=1;
      Inc(Cl);
    end;
    Cl:=Pointer(Integer(Cl)+FB.Gap);
  end;

  Cubes[0].X1:=0;
  Cubes[0].Y1:=0;
  Cubes[0].Z1:=0;
  Cubes[0].X2:=31;
  Cubes[0].Y2:=31;
  Cubes[0].Z2:=31;
  OptimizeCube(@Cubes[0]);
  CNum:=0;
  // search for biggest cube, divide that cube by largest side
  // until there are 255 cubes
  repeat
    A:=1;
    for B:=0 to CNum do
    begin
      Cub:=@Cubes[B];
      if Cub^.X2-Cub^.X1>A then
      begin
        A:=Cub^.X2-Cub^.X1;
        D:=0;
        F:=B;
      end;
      if Cub^.Y2-Cub^.Y1>A then
      begin
        A:=Cub^.Y2-Cub^.Y1;
        D:=1;
        F:=B;
      end;
      if Cub^.Z2-Cub^.Z1>A then
      begin
        A:=Cub^.Z2-Cub^.Z1;
        D:=2;
        F:=B;
      end;
    end;

    if A=1 then Break;

    Inc(CNum);
    Cubes[CNum]:=Cubes[F];
    Cub:=@Cubes[F];

    case D of
    0: begin
       Cub^.X2:=(Cub^.X1+Cub^.X2)shr 1;
       Cubes[CNum].X1:=Cub^.X2+1;
       end;
    1: begin
       Cub^.Y2:=(Cub^.Y1+Cub^.Y2)shr 1;
       Cubes[CNum].Y1:=Cub^.Y2+1;
       end;
    2: begin
       Cub^.Z2:=(Cub^.Z1+Cub^.Z2)shr 1;
       Cubes[CNum].Z1:=Cub^.Z2+1;
       end;
    end;

    OptimizeCube(@Cubes[CNum]);
    OptimizeCube(Cub);
  until CNum=255;

  if cm=cmDither then
  begin
    FillMemory(@Space,SizeOf(Space),255);

    for D:=0 to CNum do
    begin
      for A:=Cubes[D].X1 to Cubes[D].X2 do
      for B:=Cubes[D].Y1 to Cubes[D].Y2 do
      for C:=Cubes[D].Z1 to Cubes[D].Z2 do
        Space[A,B,C]:=D;

      Colors[D].r:=(Cubes[D].X1+Cubes[D].X2)shl 2;
      Colors[D].g:=(Cubes[D].Y1+Cubes[D].Y2)shl 2;
      Colors[D].b:=(Cubes[D].Z1+Cubes[D].Z2)shl 2;
    end;

    GetMem(Lines[0],24*(FB.Width+2));
    GetMem(Lines[1],24*(FB.Width+2));

    PB:=Bits;
    Cl:=FB.Bits;
    for B:=0 to FB.Width-1 do
    begin
      Lines[0,B].r:=Cl.r*16;
      Lines[0,B].g:=Cl.g*16;
      Lines[0,B].b:=Cl.b*16;
      Inc(Cl);
    end;
    Cl:=Pointer(Integer(Cl)+FB.Gap);

    Dir:=1;
    for A:=1 to FB.Height do
    begin
      Nxt:=A mod 2;
      Ln:=1-Nxt;
      if A<FB.Height then
      begin
        for B:=0 to FB.Width-1 do
        begin
          Lines[Nxt,B].r:=Cl.r*16;
          Lines[Nxt,B].g:=Cl.g*16;
          Lines[Nxt,B].b:=Cl.b*16;
          Inc(Cl);
        end;
        Cl:=Pointer(Integer(Cl)+FB.Gap);
      end;

      B:=0;
      if Dir=-1 then B:=FB.Width-1;
      PTI:=@Lines[Ln,B];
      PB:=@Pixels[A-1,B];
      while((B>-1)and(B<FB.Width))do
      begin
        PTI.r:=PTI.r div 16;
        if      PTI.r>255 then PTI.r:=255
        else if PTI.r<0   then PTI.r:=0;
        PTI.g:=PTI.g div 16;
        if      PTI.g>255 then PTI.g:=255
        else if PTI.g<0   then PTI.g:=0;
        PTI.b:=PTI.b div 16;
        if      PTI.b>255 then PTI.b:=255
        else if PTI.b<0   then PTI.b:=0;

        F:=Space[PTI.r div 8,PTI.g div 8,PTI.b div 8];
        if F=255 then
        begin
          D:=$0FFFFFFF;
          IC:=@Colors[CNum];
          for C:=CNum downto 0 do
          begin
            E:=Sqr(PTI.r-IC.r)+Sqr(PTI.g-IC.g)+Sqr(PTI.b-IC.b);
            if E<D then
            begin
              D:=E;
              F:=C;
            end;
            Dec(IC);
          end;
          Space[PTI.r div 8,PTI.g div 8,PTI.b div 8]:=F;
        end;
        PB^:=F;
        C:=PTI.r-Colors[F].r;
        if C<>0 then
        begin
          Inc(Lines[Ln,B+Dir].r,C*7);
          Inc(Lines[Nxt,B-Dir].r,C*3);
          Inc(Lines[Nxt,B].r,C*5);
          Inc(Lines[Nxt,B+Dir].r,C);
        end;
        C:=PTI.g-Colors[F].g;
        if C<>0 then
        begin
          Inc(Lines[Ln,B+Dir].g,C*7);
          Inc(Lines[Nxt,B-Dir].g,C*3);
          Inc(Lines[Nxt,B].g,C*5);
          Inc(Lines[Nxt,B+Dir].g,C);
        end;
        C:=PTI.b-Colors[F].b;
        if C<>0 then
        begin
          Inc(Lines[Ln,B+Dir].b,C*7);
          Inc(Lines[Nxt,B-Dir].b,C*3);
          Inc(Lines[Nxt,B].b,C*5);
          Inc(Lines[Nxt,B+Dir].b,C);
        end;
        Inc(PB,Dir);
        Inc(PTI,Dir);
        Inc(B,Dir);
      end;
      PB:=Pointer(Integer(PB)+Gap);
      Dir:=-Dir;
    end;
    Dispose(Lines[0]);
    Dispose(Lines[1]);
  end else // no dither
  begin
    for D:=0 to CNum do
    begin
      for A:=Cubes[D].X1 to Cubes[D].X2 do
      for B:=Cubes[D].Y1 to Cubes[D].Y2 do
      for C:=Cubes[D].Z1 to Cubes[D].Z2 do
        Space[A,B,C]:=D;

      Colors[D].r:=(Cubes[D].X1+Cubes[D].X2)shl 2;
      Colors[D].g:=(Cubes[D].Y1+Cubes[D].Y2)shl 2;
      Colors[D].b:=(Cubes[D].Z1+Cubes[D].Z2)shl 2;
    end;

    PB:=Bits;
    Cl:=FB.Bits;
    for A:=0 to FB.Height-1 do
    begin
      for B:=0 to FB.Width-1 do
      begin
        PB^:=Space[Cl^.r shr 3,Cl^.g shr 3,Cl^.b shr 3];
        Inc(PB);
        Inc(Cl);
      end;
      PB:=Pointer(Integer(PB)+Gap);
      Cl:=Pointer(Integer(Cl)+FB.Gap);
    end;
  end;
end;

procedure TFast256.SetInterface(fWidth,fHeight:Integer;pBits:Pointer);
var
x: Longint;
i: Integer;
begin
  Width:=fWidth;
  Height:=Abs(fHeight);
  bmInfo.bmiHeader.biWidth:=fWidth;
  bmInfo.bmiHeader.biHeight:=fHeight;
  RowInc:=((Width*8+31)shr 5)shl 2;
  Gap:=RowInc-Width;
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

procedure TFast256.Copy(FB:TFast256);
begin
  SetSize(FB.Width,FB.Height);
  CopyMemory(Bits,FB.Bits,Size);
  bmInfo.bmiColors:=FB.bmInfo.bmiColors;
end;

procedure TFast256.ShiftColors(Amount:Integer);
var
Buf: Pointer;
begin
  if Amount<0 then Amount:=256-(Abs(Amount) mod 256);
  if Amount>256 then Amount:=Amount mod 256;
  if Amount=0 then Exit;
  GetMem(Buf,Amount*4);
  CopyMemory(Buf,Ptr(Integer(@bmInfo.bmiColors)+((256-Amount)*4)),Amount*4);
  MoveMemory(Ptr(Integer(@bmInfo.bmiColors)+(Amount*4)),@bmInfo.bmiColors,(256-Amount)*4);
  CopyMemory(@bmInfo.bmiColors,Buf,Amount*4);
  FreeMem(Buf);
end;

procedure TFast256.RGB(ra,ga,ba:Integer);
var
Tmp: PFColorEntry;
i:   Byte;
begin
  Tmp:=@bmInfo.bmiColors[0];
  for i:=0 to 255 do
  begin
    Tmp.r:=IntToByte(Tmp.r+ra);
    Tmp.g:=IntToByte(Tmp.g+ga);
    Tmp.b:=IntToByte(Tmp.b+ba);
    Inc(Tmp);
  end;
end;

procedure TFast256.Contrast(Amount:Integer);
var
Table: array[0..255]of Byte;
Tmp:   PFColorEntry;
x:     Integer;
i:     Byte;
begin
  for i:=0 to 126 do
  begin
    x:=(Abs(128-i)*Amount)div 256;
    Table[i]:=IntToByte(i-x);
  end;
  for i:=127 to 255 do
  begin
    x:=(Abs(128-i)*Amount)div 256;
    Table[i]:=IntToByte(i+x);
  end;
  Tmp:=@bmInfo.bmiColors[0];
  for i:=0 to 255 do
  begin
    Tmp.r:=Table[Tmp.r];
    Tmp.g:=Table[Tmp.g];
    Tmp.b:=Table[Tmp.b];
    Inc(Tmp);
  end;
end;

procedure TFast256.Saturation(Amount:Integer);
var
Grays:  array[0..767]of Integer;
Alpha:  array[0..255]of Word;
Tmp:    PFColorEntry;
a,b:    Integer;
i:      Byte;
begin
  for i:=0 to 255 do
    Alpha[i]:=(i*Amount)shr 8;
  a:=0;
  for i:=0 to 255 do
  begin
    b:=i-Alpha[i];
    Grays[a]:=b; Inc(a);
    Grays[a]:=b; Inc(a);
    Grays[a]:=b; Inc(a);
  end;
  Tmp:=@bmInfo.bmiColors[0];
  for i:=0 to 255 do
  begin
    a:=Grays[Tmp.r+Tmp.g+Tmp.b];
    Tmp.r:=IntToByte(a+Alpha[Tmp.r]);
    Tmp.g:=IntToByte(a+Alpha[Tmp.g]);
    Tmp.b:=IntToByte(a+Alpha[Tmp.b]);
    Inc(Tmp);
  end;
end;

procedure TFast256.Lightness(Amount:Integer);
var
Table: array[0..255]of Byte;
Tmp:   PFColorEntry;
i:     Byte;
begin
  if Amount<0 then
  begin
    Amount:=-Amount;
    for i:=0 to 255 do Table[i]:=IntToByte(i-((Amount*i)shr 8));
  end else
    for i:=0 to 255 do Table[i]:=IntToByte(i+((Amount*(i xor 255))shr 8));
  Tmp:=@bmInfo.bmiColors[0];
  for i:=0 to 255 do
  begin
    Tmp.r:=Table[Tmp.r];
    Tmp.g:=Table[Tmp.g];
    Tmp.b:=Table[Tmp.b];
    Inc(Tmp);
  end;
end;

procedure TFast256.FillColors(c1,c255:TFColor);
var
ir,ig,ib,
r,g,b:    Single;
Tmp:      PFColorEntry;
i:        Byte;
begin
  ir:=(c255.r-c1.r)/256; r:=c1.r;
  ig:=(c255.g-c1.g)/256; g:=c1.g;
  ib:=(c255.b-c1.b)/256; b:=c1.b;
  Tmp:=@bmInfo.bmiColors[1];
  for i:=0 to 253 do
  begin
    r:=r+ir; Tmp.r:=Round(r);
    g:=g+ig; Tmp.g:=Round(g);
    b:=b+ib; Tmp.b:=Round(b);
    Inc(Tmp);
  end;
  bmInfo.bmiColors[0]:=ColorToEntry(c1);
  bmInfo.bmiColors[255]:=ColorToEntry(c255);
end;

function TFast256.MakePalette: HPALETTE;
type TPalette256=record
  Ver,
  Entries: Word;
  Colors:  array[0..255]of TPaletteEntry;
end;
var
Pal:  TPalette256;
i:    Byte;
begin
  Pal.Ver:=$300;
  Pal.Entries:=256;
  for i:=0 to 255 do
  begin
    Pal.Colors[i].peRed:=Colors[i].r;
    Pal.Colors[i].peGreen:=Colors[i].g;
    Pal.Colors[i].peBlue:=Colors[i].b;
  end;
  Result:=CreatePalette(PLogPalette(@pal)^);
end;

procedure TFast256.Draw(fdc,x,y:Integer);
begin
  StretchDIBits(fdc,x,y,Width,Height,0,0,Width,Height,
    Bits,PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFast256.Stretch(fdc,x,y,w,h:Integer);
begin
  SetStretchBltMode(fdc,STRETCH_DELETESCANS);
  StretchDIBits(fdc,x,y,w,h,0,0,Width,Height,Bits,
    PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFast256.DrawRect(fdc,x,y,w,h,sx,sy:Integer);
begin
  StretchDIBits(fdc,x,y,w,h,sx,sy,w,h,Bits,
    PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFast256.StretchRect(fdc,x,y,w,h,sx,sy,sw,sh:Integer);
begin
  SetStretchBltMode(fdc,STRETCH_DELETESCANS);
  StretchDIBits(fdc,x,y,w,h,sx,sy,sw,sh,Bits,
    PBitmapInfo(@bmInfo)^,DIB_RGB_COLORS,SRCCOPY);
end;

procedure TFast256.TileDraw(fdc,x,y,w,h:Integer);
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

procedure TFast256.CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer);
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

  n1:=@TFast256(Dst).Pixels[y,x];
  n2:=@Pixels[sy,sx];
  for i:=0 to h-1 do
  begin
    CopyMemory(n1,n2,w);
    n1:=Ptr(Integer(n1)+Dst.RowInc);
    n2:=Ptr(Integer(n2)+RowInc);
  end;
end;

procedure TFast256.Tile(Dst:TFastRGB);
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

procedure TFast256.Resize(Dst:TFastRGB);
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
Line:     PBytes;
Tmp:      Byte;
pc:       PByte;
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
      pc:=@TFast256(Dst).Pixels[y,0];
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
    GetMem(Line,Dst.Width);
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
        CopyMemory(TFast256(Dst).Pixels[yD],Line,Dst.Width);
      end;
    end;
    FreeMem(Line);
  end;
end;

// this will only look good if the color table is evenly spaced
procedure TFast256.SmoothResize(Dst:TFastRGB);
var
x,y,xP,yP,
yP2,xP2,
t,z,z2,iz2,
w1,w2,w3,w4:  Integer;
Read,Read2:   PBytes;
pc,Col1,Col2: PByte;
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
    pc:=@TFast256(Dst).Pixels[y,0];
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
      pc^:=
        (Col1^*w1+PByte(Integer(Col1)+1)^*w2+
         Col2^*w3+PByte(Integer(Col2)+1)^*w4)shr 15;
      Inc(pc);
      Inc(xP,xP2);
    end;
    Inc(yP,yP2);
  end;
end;

// checks if a TFastRGB has < 256 colors
function Check256(FB:TFastRGB):Boolean;
var
xr,xg,xb,
r,g,b,c:  Byte;
x,y:      Integer;
Tmp:      PFColor;
Count:    Longint;
Buff:     PByte;
Space:    array[0..31,0..31,0..31]of Byte;
begin
  FillChar(Space,SizeOf(Space),0);
  Tmp:=FB.Bits;
  Count:=0;
  for y:=0 to FB.Height-1 do
  begin
    for x:=0 to FB.Width-1 do
    begin
      r:=Tmp.r shr 3;
      g:=Tmp.g shr 3;
      b:=Tmp.b shr 3;
      Buff:=@Space[r,g,b];
      xr:=1 shl(Tmp.r-(r shl 3));
      xg:=1 shl(Tmp.g-(g shl 3));
      xb:=1 shl(Tmp.b-(b shl 3));
      c:=Buff^ or xr or xg or xb;
      if c>Buff^ then
      begin
        Inc(Count);
        if Count=257 then
        begin
          Result:=False;
          Exit;
        end;
        Buff^:=c;
      end;
      Inc(Tmp);
    end;
    Tmp:=Ptr(Integer(Tmp)+FB.Gap);
  end;
  Result:=True;
end;

function FRGBA(r,g,b,a:Byte):TFColorEntry;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
  Result.a:=a;
end;

function EntryToColor(tf:TFColorEntry):TFColor;
begin
  Result.b:=tf.b;
  Result.g:=tf.g;
  Result.r:=tf.r;
end;

function ColorToEntry(tf:TFColor):TFColorEntry;
begin
  Result.b:=tf.b;
  Result.g:=tf.g;
  Result.r:=tf.r;
end;

end.
