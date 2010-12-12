unit Effects;

interface

uses Windows, Classes, Graphics, Math, SysUtils, GraphicsBaseTypes, Scanlines;

type
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array [0 .. MaxInt div Sizeof(Integer) - 2] of Integer;

  TColor3 = packed record
    B, G, R: Byte;
  end;

  TColor3Array = array [0 .. MaxInt div Sizeof(TColor3) - 2] of TColor3;
  PColor3Array = ^TColor3Array;

  TResizeProcedure = procedure(Width, Height: Integer; S, D: TBitmap; CallBack: TBaseEffectCallBackProc = nil);

  TEffectOneIntParam = procedure(S, D: TBitmap; Int: Integer; CallBack: TBaseEffectCallBackProc = nil);

type
  T255ByteArray = array [0 .. 255] of Byte;
  T255IntArray = array [0 .. 255] of Integer;

type
  TArPARGB = array of PARGB;

procedure Inverse(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure ReplaceColorInImage(S,D : TBitmap; BaseColor, NewColor : TColor; Size, Level : Integer; CallBack : TBaseEffectCallBackProc = nil); overload;

procedure GrayScaleImage(S,D : TBitmap; n : integer; CallBack : TBaseEffectCallBackProc = nil); overload;
procedure GrayScaleImage(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil); overload;

procedure Sepia(S,D : TBitmap; Depth: Integer; CallBack : TBaseEffectCallBackProc = nil); overload;
procedure Sepia(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil); overload;

procedure Dither(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure ChangeBrightness(S,D : TBitmap; Brightness: Integer); overload;
procedure ChangeBrightness(Image : TBitmap; Brightness: Integer); overload;
procedure ChangeBrightness(Image : TArPARGB; Width, Height : integer; Brightness: Integer); overload;

procedure WaveSin(S, D: TBitmap; Frequency, Length:  Integer; Hor: Boolean; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil);
procedure PixelsEffect(S, D: TBitmap; Hor, Ver: Word; CallBack : TBaseEffectCallBackProc = nil);
procedure Sharpen(S, D: TBitmap; alpha: Single; CallBack : TBaseEffectCallBackProc = nil);
procedure Blocks(S, D: TBitmap; Hor, Ver, MaxOffset: Integer; BackColor: TColor);

procedure Gamma(S, D: TBitmap; L: Double); overload;
procedure Gamma(Image: TBitmap; L: Double); overload;

procedure SetRGBChannelValue(S, D: TBitmap; Red, Green, Blue: Integer); overload;
procedure SetRGBChannelValue(Image: TBitmap; Red, Green, Blue: Integer); overload;
procedure SetRGBChannelValue(Image: TArPARGB; Width, Height : integer; Red, Green, Blue: Integer); overload;

procedure Disorder(S, D: TBitmap; Hor, Ver: Integer; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil); overload;
procedure Disorder(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil); overload;

procedure Contrast(S, D: TBitmap; Value: Extended; Local: Boolean); overload;
procedure Contrast(Image: TBitmap; Value: Extended; Local: Boolean); overload;
procedure Contrast(Image: TArPARGB; Width, Height : integer; Value: Extended; Local: Boolean); overload;

Procedure Colorize(S,D : TBitmap; Luma: Integer);

Procedure AutoLevels(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
Procedure AutoColors(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);

function GistogrammRW(S : TBitmap; Rect : TRect; var CountR : int64) : T255IntArray;

procedure Rotate90(S,D : tbitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure Rotate270(S,D : Tbitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure Rotate180(S,D : Tbitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure FlipHorizontal(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure FlipVertical(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure RotateBitmap(Bitmap: TBitmap; Angle: Double; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil);
procedure SmoothResizeA(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
//-end temp resize functions
procedure StretchCool(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure SmoothResize(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure ThumbnailResize(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);

procedure StrRotated(x,y : integer; arect : TRect; DC:HDC; Font:HFont; Str:string; Ang:Extended; Options : Cardinal);
procedure CoolDrawTextEx(bitmap:Tbitmap; text:string; Font: HFont; coolcount:integer; coolcolor:Tcolor; aRect : TRect; aType : integer; Options : Cardinal);

function GistogrammB(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function GistogrammG(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function GistogrammR(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function Gistogramma(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;

function GetGistogrammBitmap(Height : integer; SBitmap : TBitmap; Options : byte; var MinC, MaxC : Integer) : TBitmap;
procedure GetGistogrammBitmapW(Height : integer; Source : T255IntArray; var MinC, MaxC : Integer; Bitmap : TBitmap);
function GetGistogrammBitmapX(Height,d : integer; G : T255IntArray; var MinC, MaxC : Integer) : TBitmap;

//new effects from ScineLineFX

procedure Emboss(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure AntiAlias(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
procedure AddColorNoise(S, D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
procedure AddMonoNoise(S, D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
procedure FishEye(Bmp, Dst: TBitmap; xAmount: Integer; CallBack : TBaseEffectCallBackProc = nil);
procedure Twist(Bmp, Dst: TBitmap; Amount: integer; CallBack : TBaseEffectCallBackProc = nil);

procedure SplitBlur(S, D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
procedure SplitBlurW(D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);

procedure GaussianBlur(D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
procedure ProportionalSizeX(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);

procedure ThreadDraw(S, D : TBitmap; x, y : integer);

implementation

procedure ProportionalSizeX(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
 if (aWidthToSize = 0) or (aHeightToSize = 0) then
 begin
  aHeightToSize := 0;
  aWidthToSize  := 0;
 end else begin
  if (aHeightToSize/aWidthToSize) < (aHeight/aWidth) then
  begin
   aHeightToSize := Round ( (aWidth/aWidthToSize) * aHeightToSize );
   aWidthToSize  := aWidth;
  end else begin
   aWidthToSize  := Round ( (aHeight/aHeightToSize) * aWidthToSize );
   aHeightToSize := aHeight;
  end;
 end;
end;

procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
// If Max(aWidthToSize,aHeightToSize)<Min(aWidth,aHeight) then
 If (aWidthToSize<aWidth) and (aHeightToSize<aHeight) then
 begin
  Exit;
 end;
 if (aWidthToSize = 0) or (aHeightToSize = 0) then
 begin
  aHeightToSize := 0;
  aWidthToSize  := 0;
 end else begin
  if (aHeightToSize/aWidthToSize) < (aHeight/aWidth) then
  begin
   aHeightToSize := Round ( (aWidth/aWidthToSize) * aHeightToSize );
   aWidthToSize  := aWidth;
  end else begin
   aWidthToSize  := Round ( (aHeight/aHeightToSize) * aWidthToSize );
   aHeightToSize := aHeight;
  end;
 end;
end;

procedure Inverse(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  i, j : integer;
  ps, pd : PARGB;
  Terminating : boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  ps:=S.ScanLine[i];
  pd:=D.ScanLine[i];
  for j:=0 to S.Width-1 do
  begin
   pd[j].r:=255-ps[j].r;
   pd[j].g:=255-ps[j].g;
   pd[j].b:=255-ps[j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*i/S.Height),Terminating);
  if Terminating then Break;
 end;
end;

procedure GrayScaleImage(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
begin
 GrayScaleImage(S,D,100,CallBack);
end;

procedure GrayScaleImage(S,D : TBitmap; N : integer; CallBack : TBaseEffectCallBackProc = nil);
var
  I, J : Integer;
  p1, p2 : PARGB;
  W1, W2, GR : Byte;
  Terminating : boolean;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  N := Min(100, Max(N, 0));

  W1 := Round((N / 100)*255);
  W2 := 255 - W1;

  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    p1 := S.ScanLine[I];
    p2 := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      GR := (p1[j].R * 77 + p1[j].G * 151 + p1[j].B * 28) shr 8;

      p2[j].R := (W2 * p1[j].R + W1 * GR) shr 8;
      p2[j].G := (W2 * p1[j].G + W1 * GR) shr 8;
      p2[j].B := (W2 * p1[j].B + W1 * GR) shr 8;
    end;
    if I mod 50 = 0 then
      If Assigned(CallBack) then CallBack(Round(100*I / S.Height),Terminating);
    if Terminating then Break;
  end;
end;

procedure Sepia(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
begin
 Sepia(S, D, 20, CallBack);
end;

procedure Sepia(S,D : TBitmap; Depth: Integer; CallBack : TBaseEffectCallBackProc = nil);
var
 color2:longint;
 r,g,b,rr,gg:byte;
 i,j:integer;
 ps, pd : PARGB;
 Terminating : boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i := 0 to S.height-1 do
 begin
  ps:=S.ScanLine[i];
  pD:=D.ScanLine[i];
  for j := 0 to S.width-1 do
  begin
   r:=ps[j].r;
   g:=ps[j].g;
   b:=ps[j].b;
   color2:=(r+g+b) div 3;
   r:=color2;
   g:=color2;
   b:=color2;
   rr:=Min(255,r+(depth*2));
   gg:=Min(255,g+depth);
   if rr <= ((depth*2)-1) then
   rr:=255;
   if gg <= (depth-1) then
   gg:=255;
   pd[j].r:=rr;
   pd[j].g:=gg;
   pd[j].b:=b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*i/S.Height),Terminating);
  if Terminating then Break;
 end;
end;

procedure Dither(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  scanlS, scanlD: PColor3Array;
  error1R, error1G, error1B,
  error2R, error2G, error2B: PIntegerArray;
  x, y: integer;
  dx: integer;
  c, cD: TColor3;
  sR, sG, sB: integer;
  dR, dG, dB: integer;
  eR, eG, eB: integer;
  Terminating : boolean;

  procedure Swap(var p1, p2: PIntegerArray);
  var
    t: PIntegerArray;
  begin
    t := p1;
    p1 := p2;
    p2 := t;
  end;

  function clamp(x, min, max: integer): integer;
  begin
    result := x;
    if result < min then
      result := min
    else
      if result > max then
        result := max;
  end;

begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 error1R := AllocMem((S.Width + 2) * sizeof(integer));
 error1G := AllocMem((S.Width + 2) * sizeof(integer));
 error1B := AllocMem((S.Width + 2) * sizeof(integer));
 error2R := AllocMem((S.Width + 2) * sizeof(integer));
 error2G := AllocMem((S.Width + 2) * sizeof(integer));
 error2B := AllocMem((S.Width + 2) * sizeof(integer));
 dx := 1;
 Terminating:=false;
 for y := 0 to S.Height - 1 do
 begin
  scanlS := S.ScanLine[y];
  scanlD := D.ScanLine[y];
  if dx > 0 then x := 0 else x := S.Width - 1;
  while (x >= 0) and (x < S.Width) do
  begin
   c := scanlS[x];
   sR := c.r;
   sG := c.g;
   sB := c.b;
   eR := error1R[x + 1];
   //eG := error1G[x + 1];
   //eB := error1B[x + 1];
   dR := (sR * 16 + eR) div 16;
   //dG := (sR * 16 + eR) div 16;
   //dB := (sR * 16 + eR) div 16;
   dR := clamp(dR, 0, 255) and (255 shl 4);
   dG := clamp(dR, 0, 255) and (255 shl 4);
   dB := clamp(dR, 0, 255) and (255 shl 4);
   cD.r := dR;
   cD.g := dG;
   cD.b := dB;
   scanlD[x] := cD;
   eR := sR - dR;
   eG := sG - dG;
   eB := sB - dB;
   inc(error1R[x + 1 + dx], (eR * 7)); {next}
   inc(error1G[x + 1 + dx], (eG * 7));
   inc(error1B[x + 1 + dx], (eB * 7));
   inc(error2R[x + 1], (eR * 5)); {top}
   inc(error2G[x + 1], (eG * 5));
   inc(error2B[x + 1], (eB * 5));
   inc(error2R[x + 1 + dx], (eR * 1)); {diag forward}
   inc(error2G[x + 1 + dx], (eG * 1));
   inc(error2B[x + 1 + dx], (eB * 1));
   inc(error2R[x + 1 - dx], (eR * 3)); {diag backward}
   inc(error2G[x + 1 - dx], (eG * 3));
   inc(error2B[x + 1 - dx], (eB * 3));
   inc(x, dx);
  end;
  dx := dx * -1;
  Swap(error1R, error2R);
  Swap(error1G, error2G);
  Swap(error1B, error2B);
  FillChar(error2R^, sizeof(integer) * (S.Width + 2), 0);
  FillChar(error2G^, sizeof(integer) * (S.Width + 2), 0);
  FillChar(error2B^, sizeof(integer) * (S.Width + 2), 0);
  if y mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*y/S.Height),Terminating);
  if Terminating then Break;
 end;
 FreeMem(error1R);
 FreeMem(error1G);
 FreeMem(error1B);
 FreeMem(error2R);
 FreeMem(error2G);
 FreeMem(error2B);
end;

procedure ChangeBrightness(S,D : TBitmap; Brightness: Integer);
var
  LUT: array[Byte] of Byte;
  v, i: Integer;
  w, h, x, y: Integer;
  LineSize: LongInt;
  pLineStartS,pLineStartD: PByte;
  ps, pd: PByte;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 for i := 0 to 255 do
 begin
  v := i + Brightness;
  if v < 0 then
    v := 0
  else if v > 255 then
    v := 255;
   LUT[i] := v;
 end;
 w := S.Width;
 h := S.Height - 1;
 pLineStartS := PByte(S.ScanLine[h]);
 pLineStartD := PByte(D.ScanLine[h]);
 LineSize := ((w * 3 + 3) div 4) * 4;
 w := w * 3 - 1;
 for y := 0 to h do
 begin
  ps := pLineStartS;
  pd := pLineStartD;
  for x := 0 to w do
  begin
   pd^ := LUT[ps^];
   Inc(ps);
   Inc(pd);
  end;
  Inc(pLineStartS, LineSize);
  Inc(pLineStartD, LineSize);
 end;
end;

procedure ChangeBrightness(Image : TBitmap; Brightness: Integer);
var
  LUT: array[Byte] of Byte;
  v, i: Integer;
  w, h, x, y: Integer;
  LineSize: LongInt;
  pLineStartD: PByte;
  pd: PByte;
begin
 Image.PixelFormat := pf24bit;
 for i := 0 to 255 do
 begin
  v := i + Brightness;
  if v < 0 then
    v := 0
  else if v > 255 then
    v := 255;
   LUT[i] := v;
 end;
 w := Image.Width;
 h := Image.Height - 1;
 pLineStartD := PByte(Image.ScanLine[h]);
 LineSize := ((w * 3 + 3) div 4) * 4;
 w := w * 3 - 1;
 for y := 0 to h do
 begin
  pd := pLineStartD;
  for x := 0 to w do
  begin
   pd^ := LUT[pd^];
   Inc(pd);
  end;
  Inc(pLineStartD, LineSize);
 end;
end;

procedure ChangeBrightness(Image : TArPARGB; Width, Height : integer; Brightness: Integer);
var
  LUT: array[Byte] of Byte;
  v, i: Integer;
  x, y: Integer;
begin
 for i := 0 to 255 do
 begin
  v := i + Brightness;
  if v < 0 then
    v := 0
  else if v > 255 then
    v := 255;
   LUT[i] := v;
 end;
 for y := 0 to Height-1 do
 begin
  for x := 0 to Width-1 do
  begin
   Image[y,x].r:=LUT[Image[y,x].r];
   Image[y,x].g:=LUT[Image[y,x].g];
   Image[y,x].b:=LUT[Image[y,x].b];
  end;
 end;
end;

procedure WaveSin(S, D: TBitmap; Frequency, Length:
  Integer; Hor: Boolean; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil);

  function Min(A, B: Integer): Integer;
  begin
    if A < B then
      Result := A
    else
      Result := B;
  end;

  function Max(A, B: Integer): Integer;
  begin
    if A > B then
      Result := A
    else
      Result := B;
  end;

const
  Rad = Pi / 180;

type
  TRGB = record
   B, G, R: Byte;
  end;
  pRGB = ^TRGB;

var
  c, x, y, f: Integer;
  Dest, Src: pRGB;
  p : PARGB;
  r,g,b : Byte;
  Terminating: Boolean;

begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 Terminating:=false;
 try
  r:=GetRValue(BackColor);
  g:=GetGValue(BackColor);
  b:=GetBValue(BackColor);
  for y := 0 to D.Height - 1 do
  begin
   p:=D.ScanLine[y];
   for x := 0 to D.Width - 1 do
   begin
    p[x].R:=r;
    p[x].G:=g;
    p[x].B:=b;
   end;
  end;
  for y := 0 to S.Height - 1 do
  begin
   Src := S.ScanLine[y];
   for x := 0 to S.Width - 1 do
   begin
    if Hor then
    begin
     c:=Round(Sin(x * Rad * Length) * Frequency) + y;
     f := Min(Max(c, 0),D.Height - 1);
     Dest := D.ScanLine[f];
     Inc(Dest, x);
    end else
    begin
     c:=Round(Sin(y * Rad * Length) * Frequency) + x;
     f := Min(Max(c, 0),D.Width - 1);
     Dest := D.ScanLine[y];
     Inc(Dest, f);
    end;
    Dest^ := Src^;
    Inc(Src);
   end;

   if y mod 50=0 then
   If Assigned(CallBack) then CallBack(Round(100*(y/S.Height)),Terminating);
   if Terminating then Break;

  end;
 finally
 end;
end;

procedure PixelsEffect(S, D: TBitmap; Hor, Ver: Word; CallBack : TBaseEffectCallBackProc = nil);

type
  TRGB = record
    B, G, R: Byte;
  end;
  pRGB = ^TRGB;
  TpRGB = array of pARGB;
var
  i, j, x, y, xd, yd, k, l,
  rr, gg, bb, h, hx, hy: Integer;
  Sour: pRGB;
  dp : TpRGB;
  Terminating : boolean;
begin
 Terminating:=false;
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 if (Hor = 1) and (Ver = 1) then
 begin
  D.Assign(S);
  Exit;
 end;

 SetLength(dp,d.Height);
 for i := 0 to D.Height-1 do
 dp[i]:=d.ScanLine[i];

 xd := (S.Width - 1) div Hor;
 yd := (S.Height - 1) div Ver;
 for i := 0 to xd do
 for j := 0 to yd do
 begin
  h := 0;
  rr := 0;
  gg := 0;
  bb := 0;
  hx := Min(Hor * (i + 1), S.Width - 1);
  hy := Min(Ver * (j + 1), S.Height - 1);
  for y := j * Ver to hy do
  begin
   Sour := S.ScanLine[y];
   Inc(Sour, i * Hor);
   for x := i * Hor to hx do
   begin
    Inc(rr, Sour^.R);
    Inc(gg, Sour^.G);
    Inc(bb, Sour^.B);
    Inc(h);
    Inc(Sour);
   end;
  end;
  rr:=rr div h;
  gg:=gg div h;
  bb:=bb div h;
  for k:=i * Hor to Min(hx + 1,D.Width-1) do
  for l:=j * Ver to Min(hy + 1,D.Height-1) do
  begin
   dp[l,k].r:=rr;
   dp[l,k].g:=gg;
   dp[l,k].b:=bb;
  end;

  if i mod 25=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i/xd)),Terminating);
  if Terminating then Break;
 end;
end;

procedure Sharpen(S, D: TBitmap; alpha: Single; CallBack : TBaseEffectCallBackProc = nil);
//to sharpen, alpha must be >1.
//pixelformat pf24bit
//sharpens sbm to tbm
var
  i, j, k: integer;
  sr: array[0..2] of PByte;
  st: array[0..4] of pRGBTriple;
  tr: PByte;
  tt, p: pRGBTriple;
  beta: Single;
  inta, intb: integer;
  bmh, bmw: integer;
  re, gr, bl: integer;
  BytesPerScanline: integer;
  Terminating : boolean;
begin
  Terminating:=false;
  //sharpening is blending of the current pixel
  //with the average of the surrounding ones,
  //but with a negative weight for the average
  Assert((S.Width > 2) and (S.Height > 2), 'Bitmap must be at least 3x3');
  Assert((alpha > 1) and (alpha < 6), 'Alpha must be >1 and <6');
  beta := (alpha - 1) / 5; //we assume alpha>1 and beta<1
  intb := round(beta * $10000);
  inta := round(alpha * $10000); //integer scaled alpha and beta
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  bmw := S.Width - 2;
  bmh := S.Height - 2;
  BytesPerScanline := (((bmw + 2) * 24 + 31) and not 31) div 8;
  tr := D.Scanline[0];
  tt := pRGBTriple(tr);
  sr[0] := S.Scanline[0];
  st[0] := pRGBTriple(sr[0]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[0]^;
    inc(tt); inc(st[0]); //first row unchanged
  end;
  sr[1] := PByte(integer(sr[0]) - BytesPerScanline);
  sr[2] := PByte(integer(sr[1]) - BytesPerScanline);
  for i := 1 to bmh do
  begin
    if i mod 50=0 then
    If Assigned(CallBack) then CallBack(Round(100*i/bmh),Terminating);
    if Terminating then Break;
    Dec(tr, BytesPerScanline);
    tt := pRGBTriple(tr);
    st[0] := pRGBTriple(integer(sr[0]) + 3); //top
    st[1] := pRGBTriple(sr[1]); //left
    st[2] := pRGBTriple(integer(sr[1]) + 3); //center
    st[3] := pRGBTriple(integer(sr[1]) + 6); //right
    st[4] := pRGBTriple(integer(sr[2]) + 3); //bottom
    tt^ := st[1]^; //1st col unchanged
    for j := 1 to bmw do
    begin
    //calcutate average weighted by -beta
      re := 0; gr := 0; bl := 0;
      for k := 0 to 4 do
      begin
        re := re + st[k]^.rgbtRed;
        gr := gr + st[k]^.rgbtGreen;
        bl := bl + st[k]^.rgbtBlue;
        inc(st[k]);
      end;
      re := (intb * re + $7FFF) shr 16;
      gr := (intb * gr + $7FFF) shr 16;
      bl := (intb * bl + $7FFF) shr 16;
    //add center pixel weighted by alpha
      p := pRGBTriple(st[1]); //after inc, st[1] is at center
      re := (inta * p^.rgbtRed + $7FFF) shr 16 - re;
      gr := (inta * p^.rgbtGreen + $7FFF) shr 16 - gr;
      bl := (inta * p^.rgbtBlue + $7FFF) shr 16 - bl;
    //clamp and move into target pixel
      inc(tt);
      if re < 0 then
        re := 0
      else
        if re > 255 then
          re := 255;
      if gr < 0 then
        gr := 0
      else
        if gr > 255 then
          gr := 255;
      if bl < 0 then
        bl := 0
      else
        if bl > 255 then
          bl := 255;
      //this looks stupid, but avoids function calls

      tt^.rgbtRed := re;
      tt^.rgbtGreen := gr;
      tt^.rgbtBlue := bl;
    end;
    inc(tt);
    inc(st[1]);
    tt^ := st[1]^; //Last col unchanged
    sr[0] := sr[1];
    sr[1] := sr[2];
    Dec(sr[2], BytesPerScanline);
  end;
  // copy last row
  Dec(tr, BytesPerScanline);
  tt := pRGBTriple(tr);
  st[1] := pRGBTriple(sr[1]);
  for j := 0 to bmw + 1 do
  begin
    tt^ := st[1]^;
    inc(tt); inc(st[1]);
  end;
end;

procedure Blocks(S, D: TBitmap; Hor, Ver, MaxOffset:
  Integer; BackColor: TColor);

  function RandomInRadius(Num, Radius: Integer): Integer;
  begin
    if Random(2) = 0 then
      Result := Num + Random(Radius)
    else
      Result := Num - Random(Radius);
  end;

var
  x, y, xd, yd: Integer;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 try
  D.Assign(S);
  D.Canvas.Brush.Color := BackColor;
  D.Canvas.FillRect(Rect(0, 0, D.Width, D.Height));
  xd := (D.Width - 1) div Hor;
  yd := (D.Height - 1) div Ver;
  Randomize;
  for x := 0 to xd do
  for y := 0 to yd do
  BitBlt(D.Canvas.Handle,RandomInRadius(Hor * x, MaxOffset),RandomInRadius(Ver * y, MaxOffset), Hor, Ver, S.Canvas.Handle, Hor * x, Ver * y, SRCCOPY);
 finally
 end;
end;

procedure Gamma(S, D: TBitmap; L: Double);
{0.0 < L < 7.0}
  function Power(Base, Exponent: Extended): Extended;
  begin
    Result := Exp(Exponent * Ln(Base));
  end;
type
  TRGB = record
    B, G, R: Byte;
  end;
  pRGB = ^TRGB;
var
  Sour, Dest: pRGB;
  X, Y: Word;
  GT: array[0..255] of Byte;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
  GT[0] := 0;
  if L = 0 then
    L := 0.01;
  for X := 1 to 255 do
    GT[X] := Round(255 * Power(X / 255, 1 / L));
  for Y := 0 to S.Height - 1 do
  begin
    Dest := D.ScanLine[y];
    Sour := S.ScanLine[y];
    for X := 0 to S.Width - 1 do
    begin
      with Dest^ do
      begin
        R := GT[Sour^.R];
        G := GT[Sour^.G];
        B := GT[Sour^.B];
      end;
      Inc(Dest);
      Inc(Sour);
    end;
  end;
end;

procedure Gamma(Image: TBitmap; L: Double);
{0.0 < L < 7.0}
  function Power(Base, Exponent: Extended): Extended;
  begin
    Result := Exp(Exponent * Ln(Base));
  end;
type
  TRGB = record
    B, G, R: Byte;
  end;
  pRGB = ^TRGB;
var
  Dest: pRGB;
  X, Y: Word;
  GT: array[0..255] of Byte;
begin
 Image.PixelFormat := pf24bit;
  GT[0] := 0;
  if L = 0 then
    L := 0.01;
  for X := 1 to 255 do
    GT[X] := Round(255 * Power(X / 255, 1 / L));
  for Y := 0 to Image.Height - 1 do
  begin
    Dest := Image.ScanLine[y];
    for X := 0 to Image.Width - 1 do
    begin
      with Dest^ do
      begin
        R := GT[R];
        G := GT[G];
        B := GT[B];
      end;
      Inc(Dest);
    end;
  end;
end;

procedure SetRGBChannelValue(S, D: TBitmap; Red, Green, Blue: Integer);
var
  I, J: Integer;
  PS, PD : PARGB;
  RuleArrayR, RuleArrayG, RuleArrayB : array[0..255] of byte;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  if (Red = 0) and (Green = 0) and (Blue = 0) then
  begin
    D.Assign(S);
    Exit;
  end;
  for I := 0 to 255 do
  begin
    RuleArrayR[I] := Round(Min(255, Max(0, I * (1+(Red/100)))));
    RuleArrayG[I] := Round(Min(255, Max(0, I * (1+(Green/100)))));
    RuleArrayB[I] := Round(Min(255, Max(0, I * (1+(Blue/100)))));
  end;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      PD[J].r:=RuleArrayR[PS[J].r];
      PD[J].g:=RuleArrayR[PS[J].G];
      PD[J].b:=RuleArrayR[PS[J].B];
    end;
  end;
end;

procedure SetRGBChannelValue(Image: TBitmap; Red, Green, Blue: Integer);
var
  I, J: Integer;
  PD : PARGB;
  RuleArrayR, RuleArrayG, RuleArrayB : array[0..255] of byte;
begin
 Image.PixelFormat := pf24bit;
  if (Red = 0) and (Green = 0) and (Blue = 0) then
    Exit;

  for I := 0 to 255 do
  begin
    RuleArrayR[I] := Round(Min(255, Max(0, I * (1 + (Red/100)))));
    RuleArrayG[I] := Round(Min(255, Max(0, I * (1 + (Green/100)))));
    RuleArrayB[I] := Round(Min(255, Max(0, I * (1 + (Blue/100)))));
  end;
  for I := 0 to Image.Height - 1 do
  begin
    PD := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
    begin
      PD[J].r:=RuleArrayR[PD[J].r];
      PD[J].g:=RuleArrayR[PD[J].G];
      PD[J].b:=RuleArrayR[PD[J].B];
    end;
  end;
end;

procedure SetRGBChannelValue(Image: TArPARGB; Width, Height : integer; Red, Green, Blue: Integer); overload;
var
  I, J: Integer;
  Rx,Gx,Bx : extended;
  RArray, GArray, BArray : T255ByteArray;
begin
  if (Red = 0) and (Green = 0) and (Blue = 0) then
  begin
    Exit;
  end;
  Rx := 1+(Red/100);
  Gx := 1+(Green/100);
  Bx := 1+(Blue/100);
  for I := 0 to 255 do
  begin
    RArray[I]:=Round(Min(255,Max(0, I*(Rx) )));
    GArray[I]:=Round(Min(255,Max(0, I*(Gx) )));
    BArray[I]:=Round(Min(255,Max(0, I*(Bx) )));
  end;
  for I := 0 to Height-1 do
  begin
    for j := 0 to Width-1 do
    begin
     Image[I, J].r:=RArray[Image[I,J].r];
     Image[I, J].g:=GArray[Image[I,J].g];
     Image[I, J].b:=BArray[Image[I,J].b];
    end;
  end;
end;

procedure Disorder(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
begin
 Disorder(S,D,10,10,$0,CallBack);
end;

procedure Disorder(S, D: TBitmap; Hor, Ver: Integer; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil);

  function RandomInRadius(Num, Radius: Integer): Integer;
  begin
    if Random(2) = 0 then
      Result := Num + Random(Radius)
    else
      Result := Num - Random(Radius);
  end;

type
  TRGB = record
    B, G, R: Byte;
  end;
  pRGB = ^TRGB;
var
  i, x, y, WW, HH, xr, yr: Integer;
  Terminate : Boolean;
  xS, xD : TArPARGB;
  r,g,b : Byte;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 Setlength(xS,S.Height);
 for i:=0 to S.Height-1 do
 xS[i]:=S.ScanLine[i];
 Setlength(xD,D.Height);
 for i:=0 to D.Height-1 do
 xD[i]:=D.ScanLine[i];
  Randomize;
  Terminate:=false;
  try
    WW := S.Width - 1;
    HH := S.Height - 1;
    r:=GetRValue(BackColor);
    g:=GetGValue(BackColor);
    b:=GetBValue(BackColor);

    for y := 0 to HH do
    begin
      for x := 0 to WW do
      begin
       xD[y,x].r:=r;
       xD[y,x].g:=g;
       xD[y,x].b:=b;
      end;
      if y mod 50=0 then
      if Assigned(CallBack) then CallBack(Round(y*100*(0.3/hh)+20),Terminate);
      if Terminate then break;
    end;

    if not Terminate then
    for y := 0 to HH do
    begin
      for x := 0 to WW do
      begin
        xr := RandomInRadius(x, Hor);
        yr := RandomInRadius(y, Ver);
        if (xr >= 0) and (xr < WW) and (yr >= 0) and (yr < HH) then
        begin
         xD[y,x]:=xS[yr,xr];
         xD[yr,xr]:=xS[y,x];
        end;
      end;
      if y mod 50=0 then
      if Assigned(CallBack) then CallBack(Round(y*100*(0.5/hh)+50),Terminate);
      if Terminate then break;
    end;
  finally
  end;
end;

procedure Contrast(S, D: TBitmap; Value: Extended; Local: Boolean);

  function BLimit(B: Integer): Byte;
  begin
    if B < 0 then
      Result := 0
    else if B > 255 then
      Result := 255
    else
      Result := B;
  end;

var
  Dest, Sour: pRGBTriple;
  x, y, mr, mg, mb,
    W, H, tr, tg, tb: Integer;
  vd: Double;

begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 if Value = 0 then
 begin
  D.Assign(S);
  Exit;
 end;
  W := S.Width - 1;
  H := S.Height - 1;
  if Local then
  begin
    mR := 128;
    mG := 128;
    mB := 128;
  end
  else
  begin
    tr := 0;
    tg := 0;
    tb := 0;
    for y := 0 to H do
    begin
      Dest := D.ScanLine[y];
      Sour := S.ScanLine[y];
      for x := 0 to W do
      begin
        with Dest^ do
        begin
          Inc(tb, Sour^.rgbtRed);
          Inc(tg, Sour^.rgbtGreen);
          Inc(tr, Sour^.rgbtBlue);
        end;
        Inc(Dest);
        Inc(Sour);
      end;
    end;
    mB := Trunc(tb / (W * H));
    mG := Trunc(tg / (W * H));
    mR := Trunc(tr / (W * H));
  end;
  if Value > 0 then
    vd := 1 + (Value / 10)
  else
    vd := 1 - (Sqrt(-Value) / 10);
  for y := 0 to H do
  begin
    Dest := D.ScanLine[y];
    Sour := S.ScanLine[y];
    for x := 0 to W do
    begin
      with Dest^ do
      begin
        rgbtRed := BLimit(mB + Trunc((Sour^.rgbtRed - mB) * vd));
        rgbtGreen := BLimit(mG + Trunc((Sour^.rgbtGreen - mG) * vd));
        rgbtBlue := BLimit(mR + Trunc((Sour^.rgbtBlue - mR) * vd));
      end;
      Inc(Dest);
      Inc(Sour);
    end;
  end;
end;

procedure Contrast(Image: TBitmap; Value: Extended; Local: Boolean);

  function BLimit(B: Integer): Byte;
  begin
    if B < 0 then
      Result := 0
    else if B > 255 then
      Result := 255
    else
      Result := B;
  end;

var
  Dest : pRGBTriple;
  x, y, mr, mg, mb,
    W, H, tr, tg, tb: Integer;
  vd: Double;

begin
 Image.PixelFormat := pf24bit;

 W := Image.Width - 1;
 H := Image.Height - 1;
  if Local then
  begin
    mR := 128;
    mG := 128;
    mB := 128;
  end
  else
  begin
    tr := 0;
    tg := 0;
    tb := 0;
    for y := 0 to H do
    begin
      Dest := Image.ScanLine[y];
      for x := 0 to W do
      begin
        with Dest^ do
        begin
          Inc(tb, Dest^.rgbtRed);
          Inc(tg, Dest^.rgbtGreen);
          Inc(tr, Dest^.rgbtBlue);
        end;
        Inc(Dest);
      end;
    end;
    mB := Trunc(tb / (W * H));
    mG := Trunc(tg / (W * H));
    mR := Trunc(tr / (W * H));
  end;
  if Value > 0 then
    vd := 1 + (Value / 10)
  else
    vd := 1 - (Sqrt(-Value) / 10);
  for y := 0 to H do
  begin
    Dest := Image.ScanLine[y];
    for x := 0 to W do
    begin
      with Dest^ do
      begin
        rgbtRed := BLimit(mB + Trunc((rgbtRed - mB) * vd));
        rgbtGreen := BLimit(mG + Trunc((rgbtGreen - mG) * vd));
        rgbtBlue := BLimit(mR + Trunc((rgbtBlue - mR) * vd));
      end;
      Inc(Dest);
    end;
  end;
end;

procedure Contrast(Image: TArPARGB; Width, Height : integer; Value: Extended; Local: Boolean);

  function BLimit(B: Integer): Byte;
  begin
    if B < 0 then
      Result := 0
    else if B > 255 then
      Result := 255
    else
      Result := B;
  end;

var
  x, y, {mr, mg,} mb,
  i, W, H, {tr, tg, }tb: Integer;
  vd: Double;
  ContrastArray : T255ByteArray;
begin
 W := Width - 1;
 H := Height - 1;
  if Local then
  begin
//    mR := 128;
//    mG := 128;
    mB := 128;
  end
  else
  begin
//     tr := 0;
//    tg := 0;
    tb := 0;
    for y := 0 to H do
    begin
      for x := 0 to W do
      begin
        Inc(tb,Image[y,x].b);
//        Inc(tg,Image[y,x].g);
//        Inc(tr,Image[y,x].r);
      end;
    end;    {Trunc}
    mB := Round(tb / (W * H));
//    mG := Round(tg / (W * H));
//    mR := Round(tr / (W * H));
  end;
  if Value > 0 then
    vd := 1 + (Value / 10)
  else
    vd := 1 - (Sqrt(-Value) / 10);
  for i:=0 to 255 do
  ContrastArray[i]:=BLimit(mB + Round((i - mB) * vd));
  for y := 0 to H do
  begin
    for x := 0 to W do
    begin
      Image[y,x].r:=ContrastArray[Image[y,x].r];
      Image[y,x].g:=ContrastArray[Image[y,x].g];
      Image[y,x].b:=ContrastArray[Image[y,x].b];
    end;
  end;
end;

Procedure Colorize(S,D : TBitmap; Luma: Integer);
var
  ps, pd : PARGB;
  i,j : integer;
  LumMatrix : array[0..255] of byte;

begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  for I := 0 to 255 do
    LumMatrix[I] := Round(Min(255, I * Luma / 255));

  for I := 0 to S.height - 1 do
  begin
    ps := S.ScanLine[i];
    pd := D.ScanLine[i];
    for J := 0 to s.Width - 1 do
    begin
      pd[J].R := LumMatrix[ps[J].r];
      pd[J].G := LumMatrix[ps[J].G];
      pd[J].B := LumMatrix[ps[J].B];
    end;
  end;
end;

function Gistogramma(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
var
  i,j : integer;
  ps : PARGB;
  L : byte;
  Terminating : Boolean;
begin
 S.PixelFormat := pf24bit;
 for i:=0 to 255 do
 Result[i]:=0;
 Terminating:=false;
 Terminated:=false;
 for i:=0 to S.Height-1 do
 begin
  ps:=S.ScanLine[i];
  for j:=0 to S.Width-1 do
  begin
   L := (ps[j].R * 77 + ps[j].G * 151 + ps[j].B * 28) shr 8;
   inc(Result[L]);
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*X/S.Height+Y)),Terminating);
  if Terminating then
  begin
   Terminated:=true;
   Break;
  end;
 end;
end;

function GistogrammR(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
var
  i,j : integer;
  ps : PARGB;
  Terminating : Boolean;
begin
 S.PixelFormat := pf24bit;
 for i:=0 to 255 do
 Result[i]:=0;
 Terminating:=false;
 Terminated:=false;
 for i:=0 to s.height-1 do
 begin
  ps:=S.ScanLine[i];
  for j:=0 to s.Width-1 do
  begin
   inc(Result[ps[j].r]);
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*X/S.Height+Y)),Terminating);
  if Terminating then
  begin
   Terminated:=true;
   Break;
  end;
 end;
end;

function GistogrammG(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
var
  i,j : integer;
  ps : PARGB;
  Terminating : Boolean;
begin
 S.PixelFormat := pf24bit;
 for i:=0 to 255 do
 Result[i]:=0;
 Terminating:=false;
 Terminated:=false;
 for i:=0 to s.height-1 do
 begin
  ps:=S.ScanLine[i];
  for j:=0 to s.Width-1 do
  begin
   inc(Result[ps[j].g]);
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*X/S.Height+Y)),Terminating);
  if Terminating then
  begin
   Terminated:=true;
   Break;
  end;
 end;
end;

function GistogrammB(S : TBitmap; var Terminated : boolean; CallBack : TBaseEffectCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
var
  i,j : integer;
  ps : PARGB;
  Terminating : boolean;
begin
 S.PixelFormat := pf24bit;
 for i:=0 to 255 do
 Result[i]:=0;
 Terminating:=false;
 Terminated:=false;
 for i:=0 to s.height-1 do
 begin
  ps:=S.ScanLine[i];
  for j:=0 to s.Width-1 do
  begin
   inc(Result[ps[j].b]);
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*X/S.Height+Y)),Terminating);
  if Terminating then
  begin
   Terminated:=true;
   Break;
  end;
 end;
end;

Procedure AutoLevels(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  ps, pd : PARGB;
  i,j, MinCount : integer;
  L: byte;
  Count : int64;
  RL : T255ByteArray;
  Gistogramm : T255IntArray;
  Terminated : Boolean;
  Terminating : Boolean;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 Gistogramm:=Gistogramma(S,Terminated,CallBack,0.5);
 if Terminated then exit;
 MinCount:=(S.height div 50)*(S.Width div 50);
 Count:=0;
 L:=0;
 for i:=255 downto 0 do
 begin
  inc(Count,Gistogramm[i]);
  if Count>MinCount then
  begin
   L:=i;
   break;
  end;
 end;
 if L=0 then L:=1;
 for i:=0 to 255 do
 begin
  RL[i]:=Min(255,Round((255/l)*i));
 end;
 Terminating:=false;
 for i:=0 to s.height-1 do
 begin
  ps:=s.ScanLine[i];
  pd:=d.ScanLine[i];
  for j:=0 to s.Width-1 do
  begin
   pd[j].r:=Rl[ps[j].r];
   pd[j].g:=Rl[ps[j].g];
   pd[j].b:=Rl[ps[j].b];
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.5/S.Height+0.5)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

Procedure AutoColors(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  ps, pd : PARGB;
  i,j, MinCount : integer;
  Count : int64;
  r,g,b: byte;
  Rx, Bx, Gx : T255ByteArray;
  GistogrammaR, GistogrammaG, GistogrammaB : T255IntArray;
  Terminated, Terminating : Boolean;
begin
 D.Width := S.Width;
 D.Height := S.Height;
 S.PixelFormat := pf24bit;
 D.PixelFormat := pf24bit;
 GistogrammaR:=GistogrammR(S,Terminated,CallBack,0.25,0);
 if Terminated then Exit;
 GistogrammaG:=GistogrammG(S,Terminated,CallBack,0.25,0.25);
 if Terminated then Exit;
 GistogrammaB:=GistogrammB(S,Terminated,CallBack,0.25,0.5);
 if Terminated then Exit;
 Count:=0;
 R:=0;
 G:=0;
 B:=0;
 MinCount:=(S.height div 10)*(S.Width div 10);
 for i:=255 downto 0 do
 begin
  inc(Count,GistogrammaR[i]);
  if Count>MinCount then
  begin
   r:=i;
   break;
  end;
 end;
 Count:=0;
 for i:=255 downto 0 do
 begin
  inc(Count,GistogrammaG[i]);
  if Count>MinCount then
  begin
   g:=i;
   break;
  end;
 end;
 Count:=0;
 for i:=255 downto 0 do
 begin
  inc(Count,GistogrammaB[i]);
  if Count>MinCount then
  begin
   b:=i;
   break;
  end;
 end;
 if r=0 then r:=1;
 if g=0 then g:=1;
 if b=0 then b:=1;
 for i:=0 to 255 do
 begin
  Rx[i]:=Min(255,Round((255/r)*i));
  Gx[i]:=Min(255,Round((255/g)*i));
  Bx[i]:=Min(255,Round((255/b)*i));
 end;
 Terminating:=false;
 for i:=0 to S.height-1 do
 begin
  ps:=s.ScanLine[i];
  pd:=d.ScanLine[i];
  for j:=0 to S.Width-1 do
  begin
   pd[j].r:=Rx[ps[j].r];
   pd[j].g:=Gx[ps[j].g];
   pd[j].b:=Bx[ps[j].b];
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

function GistogrammRW(S : TBitmap; Rect : TRect; var CountR : int64) : T255IntArray;
var
  i,j : integer;
  ps : PARGB;
begin
 S.PixelFormat := pf24bit;
 for i:=0 to 255 do
 Result[i]:=0;
 CountR:=0;
 for i:=Max(0,Rect.Top) to Min(Rect.Bottom-1,S.Height-1) do
 begin
 ps:=S.ScanLine[i];
 for j:=Max(0,Rect.Left) to Min(Rect.Right-1,S.Width-1) do
 if ps[j].r>max(ps[j].g,ps[j].b) then
  begin
   inc(CountR,1);
   inc(Result[ps[j].r-max(ps[j].g,ps[j].b)],1);
  end;
 end;
end;

procedure Rotate180(S,D : Tbitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  i, j : integer;
  p1, p2 : pargb;
  Terminating : Boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  p1:=s.ScanLine[i];
  p2:=d.ScanLine[S.Height-i-1];
  for j:=0 to S.Width-1 do
  begin
   p2[j].r:=p1[S.Width-1-j].r;
   p2[j].g:=p1[S.Width-1-j].g;
   p2[j].b:=p1[S.Width-1-j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure Rotate270(S,D : Tbitmap; CallBack : TBaseEffectCallBackProc = nil);
var
 i, j : integer;
 p1 : pargb;
 p : array of pargb;
 Terminating : Boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Height;
 D.Height:=S.Width;
 setlength(p,S.Width);
 for i:=0 to S.Width-1 do
 p[i]:=D.ScanLine[S.Width-1-i];
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  p1:=S.ScanLine[i];
  for j:=0 to S.Width-1 do
  begin
   p[j,i].r:=p1[j].r;
   p[j,i].g:=p1[j].g;
   p[j,i].b:=p1[j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure Rotate90(S,D : tbitmap; CallBack : TBaseEffectCallBackProc = nil);
var
 i, j : integer;
 p1 : pargb;
 p : array of pargb;
 Terminating : Boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Height;
 D.Height:=S.Width;
 setlength(p,S.Width);
 for i:=0 to S.Width-1 do
 p[i]:=D.ScanLine[i];
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  p1:=S.ScanLine[S.Height-i-1];
  for j:=0 to S.Width-1 do
  begin
   p[j,i].r:=p1[j].r;
   p[j,i].g:=p1[j].g;
   p[j,i].b:=p1[j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure FlipHorizontal(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  i,j : integer;
  ps, pd : PARGB;
  Terminating : Boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  ps:=S.ScanLine[i];
  pd:=D.ScanLine[i];
  for j:=0 to S.Width-1 do
  begin
   pd[j].r:=ps[S.Width-1-j].r;
   pd[j].g:=ps[S.Width-1-j].g;
   pd[j].b:=ps[S.Width-1-j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure FlipVertical(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  i,j : integer;
  ps, pd : PARGB;
  Terminating : Boolean;
begin
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i:=0 to S.Height-1 do
 begin
  ps:=S.ScanLine[i];
  pd:=D.ScanLine[S.Height-1-i];
  for j:=0 to S.Width-1 do
  begin
   pd[j].r:=ps[j].r;
   pd[j].g:=ps[j].g;
   pd[j].b:=ps[j].b;
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure RotateBitmap(Bitmap: TBitmap; Angle: Double; BackColor: TColor; CallBack : TBaseEffectCallBackProc = nil);
type TRGB = record
       B, G, R: Byte;
     end;
     pRGB = ^TRGB;
     pByteArray = ^TByteArray;
     TByteArray = array[0..32767] of Byte;
     TRectList = array [1..4] of TPoint;

var x, y, W, H, v1, v2: Integer;
    Dest, Src: pRGB;
    VertArray: array of pByteArray;
    Bmp: TBitmap;
    Terminating : boolean;
    p : PARGB;
    rgb : TRGB;
  procedure SinCos(AngleRad: Double; var ASin, ACos: Double);
  begin
    ASin := Sin(AngleRad);
    ACos := Cos(AngleRad);
  end;

  function RotateRect(const Rect: TRect; const Center: TPoint; Angle: Double): TRectList;
  var DX, DY: Integer;
      SinAng, CosAng: Double;
    function RotPoint(PX, PY: Integer): TPoint;
    begin
      DX := PX - Center.x;
      DY := PY - Center.y;
      Result.x := Center.x + Round(DX * CosAng - DY * SinAng);
      Result.y := Center.y + Round(DX * SinAng + DY * CosAng);
    end;
  begin
    SinCos(Angle * (Pi / 180), SinAng, CosAng);
    Result[1] := RotPoint(Rect.Left, Rect.Top);
    Result[2] := RotPoint(Rect.Right, Rect.Top);
    Result[3] := RotPoint(Rect.Right, Rect.Bottom);
    Result[4] := RotPoint(Rect.Left, Rect.Bottom);
  end;

  function Min(A, B: Integer): Integer;
  begin
    if A < B then Result := A
             else Result := B;
  end;

  function Max(A, B: Integer): Integer;
  begin
    if A > B then Result := A
             else Result := B;
  end;

  function GetRLLimit(const RL: TRectList): TRect;
  begin
    Result.Left := Min(Min(RL[1].x, RL[2].x), Min(RL[3].x, RL[4].x));
    Result.Top := Min(Min(RL[1].y, RL[2].y), Min(RL[3].y, RL[4].y));
    Result.Right := Max(Max(RL[1].x, RL[2].x), Max(RL[3].x, RL[4].x));
    Result.Bottom := Max(Max(RL[1].y, RL[2].y), Max(RL[3].y, RL[4].y));
  end;

  procedure Rotate;
  var x, y, xr, yr, yp: Integer;
      ACos, ASin: Double;
      Lim: TRect;
  begin
   W := Bmp.Width;
   H := Bmp.Height;
   SinCos(-Angle * Pi/180, ASin, ACos);
   Lim := GetRLLimit(RotateRect(Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Angle));
   Bitmap.Width := Lim.Right - Lim.Left;
   Bitmap.Height := Lim.Bottom - Lim.Top;

   rgb.r:=GetRValue(BackColor);
   rgb.g:=GetGValue(BackColor);
   rgb.b:=GetBValue(BackColor);
   for y := 0 to Bitmap.Height - 1 do
   begin
    Dest := Bitmap.ScanLine[y];
    p:=pargb(dest);
    for x := 0 to Bitmap.Width - 1 do
    begin
     p[x].r:=rgb.r;
     p[x].g:=rgb.g;
     p[x].b:=rgb.b;
    end;
    yp := y + Lim.Top;
    for x := 0 to Bitmap.Width - 1 do
    begin
     xr := Round(((x + Lim.Left) * ACos) - (yp * ASin));
     yr := Round(((x + Lim.Left) * ASin) + (yp * ACos));
     if (xr > -1) and (xr < W) and (yr > -1) and (yr < H) then
     begin
      Src := Bmp.ScanLine[yr];
      Inc(Src, xr);
      Dest^ := Src^;
     end;
     Inc(Dest);
    end;
    if y mod 50=0 then
    If Assigned(CallBack) then CallBack(Round(100*y/Bitmap.Height),Terminating);
    if Terminating then Break;
   end;
  end;

begin
  Terminating:=false;
  Bmp := TBitmap.Create;
  Bitmap.PixelFormat := pf24Bit;
  try
    Bmp.Assign(Bitmap);
    W := Bitmap.Width - 1;
    H := Bitmap.Height - 1;
    if Frac(Angle) <> 0.0
      then Rotate
      else
    case Trunc(Angle) of
      -360, 0, 360, 720: Exit;
      90, 270: begin
        Bitmap.Width := H + 1;
        Bitmap.Height := W + 1;
        SetLength(VertArray, H + 1);
        v1 := 0;
        v2 := 0;
        if Angle = 90.0 then v1 := H
                        else v2 := W;
        for y := 0 to H do VertArray[y] := Bmp.ScanLine[Abs(v1 - y)];
        for x := 0 to W do
        begin
         Dest := Bitmap.ScanLine[x];
         for y := 0 to H do
         begin
          v1 := Abs(v2 - x)*3;
          with Dest^ do
          begin
           B := VertArray[y, v1];
           G := VertArray[y, v1+1];
           R := VertArray[y, v1+2];
          end;
          Inc(Dest);

          if y mod 50=0 then
          If Assigned(CallBack) then CallBack(Round(100*y/Bitmap.Height),Terminating);
          if Terminating then Break;
         end;



        end
      end;
      180: begin
        for y := 0 to H do
        begin
         Dest := Bitmap.ScanLine[y];
         Src := Bmp.ScanLine[H - y];
         Inc(Src, W);
         for x := 0 to W do
         begin
          Dest^ := Src^;
          Dec(Src);
          Inc(Dest);
         end;
         if y mod 50=0 then
         If Assigned(CallBack) then CallBack(Round(100*y/Bitmap.Height),Terminating);
         if Terminating then Break;
        end;
      end;
      else Rotate;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure ThumbnailResize(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
var
  x, y, ix, iy: integer;
  x1, x2, x3: integer;

  xscale, yscale: single;
  iRed, iGrn, iBlu, iRatio: Longword;
  p, c1, c2, c3, c4, c5: tRGB24;
  pt, pt1: pRGB24;
  iSrc, iDst, s1: integer;
  i, j, r, g, b, tmpY: integer;

  RowDest, RowSource, RowSourceStart: integer;
  w, h: integer;
  dxmin, dymin: integer;
  ny1, ny2, ny3: integer;
  dx, dy: integer;
  lutX, lutY: array of integer;
  src,dest:TBitmap;
  Terminating : boolean;
begin
 w:=Width;
 h:=Height;
   pointer(src):=pointer(s);
   pointer(dest):=pointer(d);
   Terminating:=false;
  if src.PixelFormat <> pf24bit then src.PixelFormat := pf24bit;
  if dest.PixelFormat <> pf24bit then dest.PixelFormat := pf24bit;
  Dest.Width:=Width;
  Dest.Height:=Height;

  if (src.Width <= dest.Width) and (src.Height <= dest.Height) then
  begin
    dest.Assign(src);
    exit;
  end;

  iDst := (w * 24 + 31) and not 31;
  iDst := iDst div 8; //BytesPerScanline
  iSrc := (Src.Width * 24 + 31) and not 31;
  iSrc := iSrc div 8;

  xscale := 1 / (w / src.Width);
  yscale := 1 / (h / src.Height);

  // X lookup table
  SetLength(lutX, w);
  x1 := 0;
  x2 := trunc(xscale);
  for x := 0 to w - 1 do
  begin
    lutX[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * xscale);
  end;

  // Y lookup table
  SetLength(lutY, h);
  x1 := 0;
  x2 := trunc(yscale);
  for x := 0 to h - 1 do
  begin
    lutY[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * yscale);
  end;

  dec(w);
  dec(h);
  RowDest := integer(Dest.Scanline[0]);
  RowSourceStart := integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  for y := 0 to h do
  begin
    dy := lutY[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w do
    begin
      dx:= lutX[x];
      iRed:= 0;
      iGrn:= 0;
      iBlu:= 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        pt := PRGB24(RowSource + x1);
        for ix := 1 to dx do
        begin
          iRed := iRed + pt.R;
          iGrn := iGrn + pt.G;
          iBlu := iBlu + pt.B;
          inc(pt);
        end;
        RowSource := RowSource - iSrc;
      end;
      iRatio := 65535 div (dx * dy);
      pt1 := PRGB24(RowDest + x3);
      pt1.R := (iRed * iRatio) shr 16;
      pt1.G := (iGrn * iRatio) shr 16;
      pt1.B := (iBlu * iRatio) shr 16;
      x1 := x1 + 3 * dx;
      inc(x3,3);
    end;
    RowDest := RowDest - iDst;
    RowSourceStart := RowSource;
  end;

  if dest.Height < 3 then exit;

  // Sharpening...
  s1 := integer(dest.ScanLine[0]);
  iDst := integer(dest.ScanLine[1]) - s1;
  ny1 := Integer(s1);
  ny2 := ny1 + iDst;
  ny3 := ny2 + iDst;
  for y := 1 to dest.Height - 2 do
  begin
    for x := 0 to dest.Width - 3 do
    begin
      x1 := x * 3;
      x2 := x1 + 3;
      x3 := x1 + 6;

      c1 := pRGB24(ny1 + x1)^;
      c2 := pRGB24(ny1 + x3)^;
      c3 := pRGB24(ny2 + x2)^;
      c4 := pRGB24(ny3 + x1)^;
      c5 := pRGB24(ny3 + x3)^;

      r := (c1.R + c2.R + (c3.R * -12) + c4.R + c5.R) div -8;
      g := (c1.G + c2.G + (c3.G * -12) + c4.G + c5.G) div -8;
      b := (c1.B + c2.B + (c3.B * -12) + c4.B + c5.B) div -8;

      if r < 0 then r := 0 else if r > 255 then r := 255;
      if g < 0 then g := 0 else if g > 255 then g := 255;
      if b < 0 then b := 0 else if b > 255 then b := 255;

      pt1 := pRGB24(ny2 + x2);
      pt1.R := r;
      pt1.G := g;
      pt1.B := b;
    end;

    inc(ny1, iDst);
    inc(ny2, iDst);
    inc(ny3, iDst);

          if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;

  end;
end;

procedure SmoothResizeA(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
type
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

var
  x, y: Integer;
  xP, yP: Integer;
  xP2, yP2: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer;
  z, z2, iz2: Integer;
  DstLine: pRGBArray;
  DstGap: Integer;
  w1, w2, w3, w4: Integer;
  Terminating : Boolean;
begin
  S.PixelFormat := pf24Bit;
  D.PixelFormat := pf24Bit;
  if Width*Height=0 then
  begin
   D.Assign(S);
   exit;
  end;
  D.Width:=Width;
  D.Height:=Height;
  Terminating:=false;
  if (S.Width = D.Width) and (S.Height = D.Height) then
    D.Assign(S)
  else
  begin
    DstLine := D.ScanLine[0];
    DstGap  := Integer(D.ScanLine[1]) - Integer(DstLine);

    xP2 := MulDiv(pred(S.Width), $10000, D.Width);
    yP2 := MulDiv(pred(S.Height), $10000, D.Height);
    yP  := 0;

    for y := 0 to pred(D.Height) do
    begin
      xP := 0;

      SrcLine1 := S.ScanLine[yP shr 16];

      if (yP shr 16 < pred(S.Height)) then
        SrcLine2 := S.ScanLine[succ(yP shr 16)]
      else
        SrcLine2 := S.ScanLine[yP shr 16];

      z2  := succ(yP and $FFFF);
      iz2 := succ((not yp) and $FFFF);
      for x := 0 to pred(D.Width) do
      begin
        t3 := xP shr 16;
        z  := xP and $FFFF;
        w2 := MulDiv(z, iz2, $10000);
        w1 := iz2 - w2;
        w4 := MulDiv(z, z2, $10000);
        w3 := z2 - w4;
        DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 +
          SrcLine1[t3 + 1].rgbtRed * w2 + SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;

        DstLine[x].rgbtGreen := (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 +
          SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;

        DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 +
          SrcLine1[t3 + 1].rgbtBlue * w2 +SrcLine2[t3].rgbtBlue * w3 +  SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
        Inc(xP, xP2);
      end; {for}
      Inc(yP, yP2);
      DstLine := pRGBArray(Integer(DstLine) + DstGap);

      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;


    end; {for}
  end; {if}
end; {SmoothResize}

procedure SmoothResize(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
type
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

var
  x, y: Integer;
  xP, yP: Integer;
  Mx, My: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer;
  z, z2, iz2: Integer;
  DstLine: pRGBArray;
  DstGap: Integer;
  w1, w2, w3, w4: Integer;
  Terminating : boolean;
begin
  Terminating := false;
  S.PixelFormat := pf24Bit;
  D.PixelFormat := pf24Bit;
  if Width*Height=0 then
  begin
   D.Assign(S);
   exit;
  end;
  D.Width:=Width;
  D.Height:=Height;
  if (S.Width = D.Width) and (S.Height = D.Height) then
    D.Assign(S)
  else
  begin
    DstLine := D.ScanLine[0];
    DstGap  := Integer(D.ScanLine[1]) - Integer(DstLine);
    Mx := MulDiv(S.Width, $10000, D.Width);
    My := MulDiv(S.Height, $10000, D.Height);
    yP  := 0;

    for y := 0 to pred(D.Height) do
    begin
      xP := 0;

      SrcLine1 := S.ScanLine[yP shr 16];

      if (yP shr 16 < pred(S.Height))and(Y<>D.Height-1) then
        SrcLine2 := S.ScanLine[succ(yP shr 16)]
      else
      begin
        SrcLine1 := S.ScanLine[S.Height-2];
        SrcLine2 := S.ScanLine[S.Height-1];
      end;

      z2  := succ(yP and $FFFF);
      iz2 := succ((not yp) and $FFFF);
      for x := 0 to pred(D.Width) do
      begin
        t3 := xP shr 16;
        z  := xP and $FFFF;
        w2 := MulDiv(z, iz2, $10000);
        w1 := iz2 - w2;
        w4 := MulDiv(z, z2, $10000);
        w3 := z2 - w4;
        if (t3>=S.Width-1)or(x=D.Width-1) then
         t3:=S.Width-2;
        DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 +
          SrcLine1[t3 + 1].rgbtRed * w2 + SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;

        DstLine[x].rgbtGreen := (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 +
          SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;

        DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 +
          SrcLine1[t3 + 1].rgbtBlue * w2 +SrcLine2[t3].rgbtBlue * w3 +  SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
        Inc(xP, Mx);
      end; {for}
      Inc(yP, My);
      DstLine := pRGBArray(Integer(DstLine) + DstGap);
      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;
    end; {for}
  end; {if}
end; {SmoothResize}

procedure StretchCool(Width, Height : integer; S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  i, j, k, p : Integer;
  p1 : PARGB;
  col, r, g, b, Sheight1 : integer;
  Sh, Sw : Extended;
  Xp : array of PARGB;
  Terminating : boolean;
begin
 If Width=0 then exit;
 If Height=0 then exit;
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=Width;
 D.Height:=Height;
 Sh:=S.height/height;
 Sw:=S.width/width;
 Sheight1:=S.height-1;
 SetLength(Xp,S.height);
 for i:=0 to Sheight1 do
 Xp[i]:=s.ScanLine[i];
 Terminating:=false;
 for i:=0 to Height-1 do
 begin
  p1:=D.ScanLine[i];
  for j:=0 to Width-1 do
  begin
   col:=0;
   r:=0;
   g:=0;
   b:=0;
   for k:=Round(Sh*i) to Min(Round(Sh*(i+1))-1,Sheight1) do
   begin
    for p:=Round(Sw*j) to Min(Round(Sw*(j+1))-1,S.Width-1) do
    begin
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
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*i/Height),Terminating);
  if Terminating then Break;
 end;
end;

procedure StrRotated(x,y : integer; arect : TRect; DC:HDC; Font:HFont; Str:string; Ang:Extended; Options : Cardinal);
var nXF,oXF:TXForm;
    s:TStrings;
    fNew,fOld:HFont;
begin
 fNew:=Font;
 fOld:=SelectObject(DC,fNew);
 s:=TStringList.Create;
 s.Text:=Str;
 SetGraphicsMode(DC,GM_Advanced);
 GetWorldTransform(DC,oXF);
 nXF.eM11:=Cos(Ang*Pi/180);
 nXF.eM22:=Cos(Ang*Pi/180);
 nXF.eM12:=Sin(Ang*Pi/180);
 nXF.eM21:=-Sin(Ang*Pi/180);
 nXF.eDX:=x;
 nXF.eDY:=y;
 ModifyWorldTransform(DC,nXF,MWT_RIGHTMULTIPLY);
 SetBkMode(DC,Transparent);
 DrawText(DC,PChar(s.Text),Length(s.Text),arect,Options);
 SetWorldTransform(DC,oXF);
 s.Free;
 SelectObject(DC,fOld);
end;

procedure CoolDrawTextEx(bitmap:Tbitmap; text:string; Font: HFont; coolcount:integer; coolcolor:Tcolor; aRect : TRect; aType : integer; Options : Cardinal);
 var
 Drawrect:trect;
 c:integer;
 tempb,temp:Tbitmap;
 i,j,k:integer;
 p,p1,pv,pn,pc:pargb;
begin
 tempb:=tbitmap.create;
 tempb.PixelFormat:=pf24bit;
 tempb.Canvas.Font.Assign(bitmap.Canvas.Font);
 tempb.Canvas.Font.Color:=0;
 tempb.canvas.brush.Color:=$ffffff;
 tempb.Width:=aRect.Right-aRect.Left;
 tempb.height:=aRect.Bottom-aRect.Top;

 case aType of
 0 :
 begin
  DrawRect:=Rect(point(coolcount,coolcount),point(tempb.Width-coolcount,tempb.Height-coolcount));
  StrRotated(0,0,DrawRect,tempb.Canvas.Handle,Font,text,0,Options);
 end;
 1 :
 begin
  DrawRect:=Rect(point(coolcount,coolcount),point(tempb.Height-coolcount,tempb.Width-coolcount));
  StrRotated(aRect.Right-aRect.Left,0,DrawRect,tempb.Canvas.Handle,Font,text,90,Options);
 end;
 2 :
 begin
  DrawRect:=Rect(point(coolcount,coolcount),point(tempb.Width-coolcount,tempb.Height-coolcount));
  StrRotated(aRect.Right-aRect.Left,aRect.Bottom-aRect.Top,DrawRect,tempb.Canvas.Handle,Font,text,180,Options);
 end;
 3 :
 begin
  DrawRect:=Rect(point(coolcount,coolcount),point(tempb.Height-coolcount,tempb.Width-coolcount));
  StrRotated(0,aRect.Bottom-aRect.Top,DrawRect,tempb.Canvas.Handle,Font,text,270,Options);
 end;
 end;

 temp:=tbitmap.create;
 temp.PixelFormat:=pf24bit;
 temp.canvas.brush.Color:=$0;
 temp.Width:=aRect.Right-aRect.Left;
 temp.height:=aRect.Bottom-aRect.Top;
 temp.Canvas.Font.Assign(bitmap.Canvas.Font);
 temp.Canvas.Font.color:=0;
 for i:=0 to temp.height-1 do
 begin
 p1:=temp.ScanLine[i];
 p:=tempb.ScanLine[i];
 for j:=0 to temp.width-1 do
 begin
 if p[j].r<>$ff then
 begin
 p1[j].r:=$ff;
 p1[j].g:=$ff;
 p1[j].b:=$ff;
 end;
 end;
 end;
 tempb.Canvas.brush.color:=$0;
 tempb.Canvas.pen.color:=$0;
 tempb.Canvas.Rectangle(0,0,tempb.Width,tempb.Height);
 for k:=1 to coolcount do
 begin
 for i:=1 to temp.height-2 do
 begin
 p:=tempb.ScanLine[i];
 pv:=temp.ScanLine[i-1];
 pc:=temp.ScanLine[i];
 pn:=temp.ScanLine[i+1];
 for j:=1 to temp.width-2 do
 begin
 c:=9;
 if (pv[j-1].r<>0) then dec(c);
 if (pv[j+1].r<>0) then dec(c);
 if (pn[j-1].r<>0) then dec(c);
 if (pn[j+1].r<>0) then dec(c);
 if (pc[j-1].r<>0) then dec(c);
 if (pc[j+1].r<>0) then dec(c);
 if (pn[j].r<>0) then dec(c);
 if (pv[j].r<>0) then dec(c);
 if c<>9 then
 begin
 p[j].r:=min($ff,p[j].r+(pv[j-1].r+pv[j+1].r+pn[j-1].r+pn[j+1].r+pc[j-1].r+pc[j+1].r+pn[j].r+pv[j].r) div (c+1));
 p[j].g:=min($ff,p[j].g+(pv[j-1].g+pv[j+1].g+pn[j-1].g+pn[j+1].g+pc[j-1].g+pc[j+1].g+pn[j].g+pv[j].g) div (c+1));
 p[j].b:=min($ff,p[j].b+(pv[j-1].b+pv[j+1].b+pn[j-1].b+pn[j+1].b+pc[j-1].b+pc[j+1].b+pn[j].b+pv[j].b) div (c+1));
 end;
 end;
 end;
 temp.Assign(tempb);
 end;
 bitmap.PixelFormat:=pf24bit;
 if bitmap.Width=0 then exit;
 for i:=Max(0,aRect.Top) to min(tempb.Height-1+aRect.Top,bitmap.height-1) do
 begin
 p:=bitmap.ScanLine[i];
 p1:=tempb.ScanLine[i-aRect.Top];
 for j:=Max(0,aRect.Left) to min(tempb.Width+aRect.Left-1,bitmap.width-1) do
 begin
 p[j].r:=min(round(p[j].r*(1-p1[j-aRect.Left].r/255))+round(getrvalue(coolcolor)*p1[j-aRect.Left].r/255),255);
 p[j].g:=min(round(p[j].g*(1-p1[j-aRect.Left].g/255))+round(getgvalue(coolcolor)*p1[j-aRect.Left].g/255),255);
 p[j].b:=min(round(p[j].b*(1-p1[j-aRect.Left].b/255))+round(getbvalue(coolcolor)*p1[j-aRect.Left].b/255),255);
 end;
 end;
 DrawRect:=Rect(point(aRect.Left+coolcount,aRect.Top+coolcount),point(aRect.Left+temp.Width-coolcount,temp.Height+aRect.Top-coolcount));

 case aType of
 0 :  begin
       DrawRect:=Rect(point(aRect.Left+coolcount,aRect.Top+coolcount),point(aRect.Left+temp.Width-coolcount,temp.Height+aRect.Top-coolcount));
       StrRotated(0,0,DrawRect,bitmap.Canvas.Handle,Font,text,0,Options);
      end;
 1 :  begin
       DrawRect:=Rect(point(coolcount,coolcount),point(temp.Height-coolcount,temp.Width-coolcount));
       StrRotated(aRect.Right,aRect.Top,DrawRect,bitmap.Canvas.Handle,Font,text,90,Options);
      end;
 2 :  begin
       DrawRect:=Rect(point(coolcount,coolcount),point(temp.Width-coolcount,temp.Height-coolcount));
       StrRotated(aRect.Right,aRect.Bottom,DrawRect,bitmap.Canvas.Handle,Font,text,180,Options);
      end;
 3 :  begin
       DrawRect:=Rect(point(coolcount,coolcount),point(temp.Height-coolcount,temp.Width-coolcount));
       StrRotated(aRect.Left,aRect.Bottom,DrawRect,bitmap.Canvas.Handle,Font,text,270,Options);
      end;
 end;

 temp.free;
 tempb.free;
end;

function GetGistogrammBitmap(Height : integer; SBitmap : TBitmap; Options : byte; var MinC, MaxC : Integer) : TBitmap;
var
  t : boolean;
  i, j,  xc : integer;
  x, MaxCount : integer;
  G : T255IntArray;
  GE : array[0..255] of extended;
begin
 Result:=TBitmap.create;
 Result.PixelFormat:=pf24bit;
 case Options of
  0 : G:=Gistogramma(SBitmap,t);
  1 : G:=GistogrammR(SBitmap,t);
  2 : G:=GistogrammG(SBitmap,t);
  3 : G:=GistogrammB(SBitmap,t);
 end;
 MaxCount:=1;

 for i:=0 to 255 do
 if G[i]>MaxCount then
 begin
  x:=G[i] div 2;
  xc:=0;
  for j:=0 to 255 do
  if i<>j then
  if G[j]>x then inc(xc);
  if xc>5 then
  MaxCount:=G[i];
 end;

 if MaxCount=1 then
 begin
  for i:=0 to 255 do
  if G[i]>MaxCount then
  MaxCount:=G[i];
 end;

 for i:=0 to 255 do
 GE[i]:=G[i]/MaxCount;
 MinC:=0;
 for i:=0 to 255 do
 begin
  if GE[i]>0.05 then
  begin
   MinC:=i;
   break;
  end;
 end;
 MaxC:=0;
 for i:=255 downto 0 do
 begin
  if GE[i]>0.05 then
  begin
   MaxC:=i;
   break;
  end;
 end;
 Result.Width:=256;
 Result.Height:=Height;
 Result.Canvas.Rectangle(0,0,256,Height);
 for i:=0 to 255 do
 begin
  Result.Canvas.MoveTo(i+1,Height);
  Result.Canvas.LineTo(i+1,Height-Round(Height*GE[i]));
 end;
 Result.Canvas.Pen.Color:=$888888;
 Result.Canvas.MoveTo(MinC,0);
 Result.Canvas.LineTo(MinC,Height);
 Result.Canvas.Pen.Color:=$888888;
 Result.Canvas.MoveTo(MaxC,0);
 Result.Canvas.LineTo(MaxC,Height);
end;

function GetGistogrammBitmapX(Height,d : integer; G : T255IntArray; var MinC, MaxC : Integer) : TBitmap;
var
  I, J, Xc: Integer;
  X, MaxCount: Integer;
  GE: array [0 .. 255] of Extended;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := Pf24bit;

  MaxCount := 1;

  for I := 0 to 255 do
    if G[I] > MaxCount then
    begin
      X := G[I] div 2;
      Xc := 0;
      for J := 0 to 255 do
        if I <> J then
          if G[J] > X then
            Inc(Xc);
      if Xc > 5 then
        MaxCount := G[I];
    end;

  if MaxCount = 1 then
  begin
    for I := 0 to 255 do
      if G[I] > MaxCount then
        MaxCount := G[I];
  end;

  for I := 0 to 255 do
    GE[I] := G[I] / MaxCount;
  MinC := 0;
  for I := 0 to 255 do
  begin
    if GE[I] > 0.05 then
    begin
      MinC := I;
      Break;
    end;
  end;
  MaxC := 0;
  for I := 255 downto 0 do
  begin
    if GE[I] > 0.05 then
    begin
      MaxC := I;
      Break;
    end;
  end;
  Result.Width := 256;
  Result.Height := Height;
  Result.Canvas.Rectangle(0, 0, 256, Height);
  for I := 0 to 255 do
  begin
    Result.Canvas.MoveTo(I + 1, Height - D);
    Result.Canvas.LineTo(I + 1, Height - D - Round((Height - D) * GE[I]));
  end;
  Result.Canvas.Pen.Color := $888888;
  Result.Canvas.MoveTo(MinC, 0);
  Result.Canvas.LineTo(MinC, Height - D);
  Result.Canvas.Pen.Color := $888888;
  Result.Canvas.MoveTo(MaxC, 0);
  Result.Canvas.LineTo(MaxC, Height - D);
end;

procedure GetGistogrammBitmapW(Height : integer; Source : T255IntArray; var MinC, MaxC : Integer; Bitmap : TBitmap);
var
  I, J, Xc: Integer;
  X, MaxCount: Integer;
  GE: array [0 .. 255] of Extended;
begin
  Bitmap.PixelFormat := Pf24bit;

  MaxCount := 1;

  for I := 0 to 255 do
    if Source[I] > MaxCount then
    begin
      X := Source[I] div 2;
      Xc := 0;
      for J := 0 to 255 do
        if I <> J then
          if Source[J] > X then
            Inc(Xc);
      if Xc > 5 then
        MaxCount := Source[I];
    end;

  if MaxCount = 1 then
  begin
    for I := 0 to 255 do
      if Source[I] > MaxCount then
        MaxCount := Source[I];
  end;

  for I := 0 to 255 do
    GE[I] := Source[I] / MaxCount;

  MinC := 0;
  for I := 0 to 255 do
  begin
    if GE[I] > 0.05 then
    begin
      MinC := I;
      Break;
    end;
  end;
  MaxC := 0;
  for I := 255 downto 0 do
  begin
    if GE[I] > 0.05 then
    begin
      MaxC := I;
      Break;
    end;
  end;
  Bitmap.Width := 256;
  Bitmap.Height := Height;
  Bitmap.Canvas.Rectangle(0, 0, 256, Height);
  for I := 0 to 255 do
  begin
    Bitmap.Canvas.MoveTo(I + 1, Height);
    Bitmap.Canvas.LineTo(I + 1, Height - Round(Height * GE[I]));
  end;
  Bitmap.Canvas.Pen.Color := $888888;
  Bitmap.Canvas.MoveTo(MinC, 0);
  Bitmap.Canvas.LineTo(MinC, Height);
  Bitmap.Canvas.Pen.Color := $888888;
  Bitmap.Canvas.MoveTo(MaxC, 0);
  Bitmap.Canvas.LineTo(MaxC, Height);
end;

procedure Interpolate(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  z1, z2: single;
  k: single;
  i, j: integer;
  h, dw,dh, xo, yo: integer;
  x1r,y1r : extended;
  Xs, Xd : array of PARGB;
  dx, dy : Extended;
  Terminating : boolean;
begin
  Terminating:=false;
  S.PixelFormat:=Pf24bit;
  D.PixelFormat:=Pf24bit;
  D.Width:=Math.Max(D.Width,x+Width);
  D.height:=Math.Max(D.height,y+Height);
  dw:=Math.Min(D.Width-x,x+Width);
  dh:=Math.Min(D.height-y,y+Height);
  dx:=(Width)/(Rect.Right-Rect.Left-1);
  dy:=(Height)/(Rect.Bottom-Rect.Top-1);
  if (dx<1) or (dy<1) then exit;
  SetLength(Xs,S.Height);
  for i:=0 to S.Height - 1 do
  Xs[i]:=S.scanline[i];
  SetLength(Xd,D.Height);
  for i:=0 to D.Height - 1 do
  Xd[i]:=D.scanline[i];
  h:=min(Round((Rect.Bottom-Rect.Top-1)*dy)-1,dh-1);
  for i := 0 to h do
  begin
      yo := Trunc(i / dy)+Rect.Top;
      y1r:= Trunc(i / dy) * dy;
      if yo+1>=S.height then Break;
    for j := 0 to min(Round((Rect.Right-Rect.Left-1)*dx)-1,dw-1) do
    begin
      xo := Trunc(j / dx)+Rect.Left;
      x1r:= Trunc(j / dx) * dx;
      if xo+1>=S.Width then Continue;
      begin
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
   if i mod 50=0 then
   If Assigned(CallBack) then CallBack(Round(100*i/h),Terminating);
   if Terminating then Break;
  end;
end;

procedure ReplaceColorInImage(S,D : TBitmap; BaseColor, NewColor : TColor; Size, Level : Integer; CallBack : TBaseEffectCallBackProc = nil); overload;
var
 i,j:integer;
 ps, pd : PARGB;
 Terminating : boolean;
 r1,r2,g1,g2,b1,b2 : Byte;
 c : Extended;

 function CompareColor(r1,r2,g1,g2,b1,b2 : byte) : Extended;
 var
   r,g,b : Extended;
 begin
  r:=Power(1-Abs(r1-r2)/255,Level);
  g:=Power(1-Abs(g1-g2)/255,Level);
  b:=Power(1-Abs(b1-b2)/255,Level);
  Result:=r*g*b;
  Result:=Min(1,Result*Size/100);
 end;

begin
 r1:=GetRValue(ColorToRGB(BaseColor));
 g1:=GetGValue(ColorToRGB(BaseColor));
 b1:=GetBValue(ColorToRGB(BaseColor));
 r2:=GetRValue(ColorToRGB(NewColor));
 g2:=GetGValue(ColorToRGB(NewColor));
 b2:=GetBValue(ColorToRGB(NewColor));
 S.PixelFormat:=pf24bit;
 D.PixelFormat:=pf24bit;
 D.Width:=S.Width;
 D.Height:=S.Height;
 Terminating:=false;
 for i := 0 to S.height-1 do
 begin
  pS:=S.ScanLine[i];
  pD:=D.ScanLine[i];
  for j := 0 to S.width-1 do
  begin
   c:=CompareColor(pS[j].r,r1,pS[j].g,g1,pS[j].b,b1);
   pD[j].r:=Round(pS[j].r*(1-C)+r2*C);
   pD[j].g:=Round(pS[j].g*(1-C)+g2*C);
   pD[j].b:=Round(pS[j].b*(1-C)+b2*C);
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*i/S.Height),Terminating);
  if Terminating then Break;
 end;
end;

procedure Emboss(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  x, y :   Integer;
  p1, p2 : Pbytearray;

  SL : TScanlines;
  Terminating : Boolean;
begin
  D.Assign(S);
  D.PixelFormat:=pf24bit;
  SL := TScanlines.Create(D);
  Terminating:=false;
  try

    for y := 0 to D.Height-2 do
    begin
      //p1 := bmp.scanline[y];
      //p2 := bmp.scanline[y+1];
      p1 := PByteArray(SL[y]);
      p2 := PByteArray(SL[y+1]);

      for x := 0 to D.Width-4 do
      begin
        p1[x*3] := (p1[x*3]+(p2[(x+3)*3] xor $FF))shr 1;
        p1[x*3+1] := (p1[x*3+1]+(p2[(x+3)*3+1] xor $FF))shr 1;
        p1[x*3+2] := (p1[x*3+2]+(p2[(x+3)*3+2] xor $FF))shr 1;
      end;
     if y mod 50=0 then
     If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
     if Terminating then Break;
    end;

  finally
    SL.Free;
  end;
end;

procedure AntiAliasRect(clip: tbitmap; XOrigin, YOrigin, XFinal, YFinal: Integer; CallBack : TBaseEffectCallBackProc = nil);
var
  Memo, x, y : Integer; (* Composantes primaires des points environnants *)
  p0, p1, p2 : pbytearray;
  SL : TScanlines;
  Terminating : boolean;
begin
   if XFinal<XOrigin then begin Memo := XOrigin; XOrigin := XFinal; XFinal := Memo; end;  (* Inversion des valeurs   *)
   if YFinal<YOrigin then begin Memo := YOrigin; YOrigin := YFinal; YFinal := Memo; end;  (* si diff,rence n,gative*)
   Terminating:=false;
   XOrigin := max(1,XOrigin);
   YOrigin := max(1,YOrigin);
   XFinal := min(clip.width-2,XFinal);
   YFinal := min(clip.height-2,YFinal);
   clip.PixelFormat := pf24bit;

   SL := TScanlines.Create(clip);
   try

     for y := YOrigin to YFinal do
     begin
      //p0 := clip.ScanLine [y-1];
      //p1 := clip.scanline [y];
      //p2 := clip.ScanLine [y+1];

      p0 := PByteArray(SL[y-1]);
      p1 := PByteArray(SL[y]);
      p2 := PByteArray(SL[y+1]);

      for x := XOrigin to XFinal do
      begin
        p1[x*3]   := (p0[x*3]+p2[x*3]+p1[(x-1)*3]+p1[(x+1)*3])div 4;
        p1[x*3+1] := (p0[x*3+1]+p2[x*3+1]+p1[(x-1)*3+1]+p1[(x+1)*3+1])div 4;
        p1[x*3+2] := (p0[x*3+2]+p2[x*3+2]+p1[(x-1)*3+2]+p1[(x+1)*3+2])div 4;
      end;

      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/clip.Height),Terminating);
      if Terminating then Break;
     end;

   finally
     SL.Free;
   end;
end;

procedure AntiAlias(S, D: TBitmap; CallBack : TBaseEffectCallBackProc = nil);
begin
 D.Assign(S);
 D.PixelFormat:=pf24bit;
 AntiAliasRect(D, 0, 0, D.width, D.height, CallBack);
end;

function IntToByte(i:Integer):Byte;
begin
  if i > 255 then
    Result := 255
  else
    if i < 0 then
      Result := 0
    else
      Result := i;
end;

procedure AddColorNoise(S, D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
var
  p0 : pbytearray;
  x, y, r, g, b : Integer;
  SL : TScanLines;
  Terminating : Boolean;
begin
  D.Assign(S);
  D.PixelFormat:=pf24bit;
  Terminating:=false;
  SL := TScanLines.Create(D);
  try

    for y := 0 to D.Height-1 do
    begin
      //p0 := clip.ScanLine [y];
      p0 := PByteArray(SL[y]);
      for x := 0 to D.Width-1 do
      begin
        r := p0[x*3]+(Random(Amount)-(Amount shr 1));
        g := p0[x*3+1]+(Random(Amount)-(Amount shr 1));
        b := p0[x*3+2]+(Random(Amount)-(Amount shr 1));
        p0[x*3]   := IntToByte(r);
        p0[x*3+1] := IntToByte(g);
        p0[x*3+2] := IntToByte(b);
      end;
      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;
    end;

  finally
    SL.Free;
  end;
end;

procedure AddMonoNoise(S, D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
var
  p0 : pbytearray;
  x, y, a, r, g, b : Integer;
  Terminating : Boolean;
  SL : TScanLines;
begin
  D.Assign(S);
  D.PixelFormat:=pf24bit;
  Terminating:=false;
  SL := TScanlines.Create(D);
  try
    for y := 0 to D.Height-1 do
    begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);
      for x := 0 to D.Width-1 do
      begin
        a := Random(Amount)-(Amount shr 1);
        r := p0[x*3]+a;
        g := p0[x*3+1]+a;
        b := p0[x*3+2]+a;
        p0[x*3] := IntToByte(r);
        p0[x*3+1] := IntToByte(g);
        p0[x*3+2] := IntToByte(b);
      end;
      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;
    end;
  finally
    SL.Free;
  end;
end;

procedure FishEye(Bmp, Dst: TBitmap; xAmount: Integer; CallBack : TBaseEffectCallBackProc = nil);
var
  xmid, ymid             : Extended;
  fx, fy                 : Extended;
  r1, r2                 : Extended;
  ifx, ify               : integer;
  dx, dy                 : Extended;
  rmax                   : Extended;
  ty, tx                 : Integer;
  weight_x, weight_y     : array[0..1] of Extended;
  weight                 : Extended;
  new_red, new_green     : Integer;
  new_blue               : Integer;
  total_red, total_green : Extended;
  total_blue             : Extended;
  ix, iy                 : Integer;
  sli, slo : PByteArray;

  SL1, SL2 : TScanlines;
  Amount: Extended;
  Terminating : boolean;
begin
  Amount:=0.5+xAmount/100;
  xmid := Bmp.Width/2;
  ymid := Bmp.Height/2;
  Dst.Assign(Bmp);
  rmax := Dst.Width * Amount;
  Terminating:=false;
  SL1 := TScanlines.Create(Bmp);
  SL2 := TScanlines.Create(Dst);
  try

    for ty := 0 to Dst.Height - 1 do
    begin
      for tx := 0 to Dst.Width - 1 do begin
        dx := tx - xmid;
        dy := ty - ymid;
        r1 := Sqrt(dx * dx + dy * dy);

        if r1 = 0 then
        begin
         fx := xmid;
         fy := ymid;
        end else
        begin
         if (abs(1 - r1/rmax)>0.0001) and (abs(r1)>0.001) then
         begin

          r2 := rmax / 2 * (1 / (1 - r1/rmax) - 1);
          fx := dx * r2 / r1 + xmid;
          fy := dy * r2 / r1 + ymid;

         end else
         begin
          fx := xmid+r1/rmax;
          fy := ymid+r1/rmax;
         end;
        end;

        ify := Trunc(fy);
        ifx := Trunc(fx);

                  // Calculate the weights.
        if fy >= 0  then begin
          weight_y[1] := fy - ify;
          weight_y[0] := 1 - weight_y[1];
        end else begin
          weight_y[0] := -(fy - ify);
          weight_y[1] := 1 - weight_y[0];
        end;

        if fx >= 0 then begin
          weight_x[1] := fx - ifx;
          weight_x[0] := 1 - weight_x[1];
        end else begin
          weight_x[0] := -(fx - ifx);
          Weight_x[1] := 1 - weight_x[0];
        end;

        if ifx < 0 then
          ifx := Bmp.Width-1-(-ifx mod Bmp.Width)
        else
          if ifx > Bmp.Width-1  then
            ifx := ifx mod Bmp.Width;

        if ify < 0 then
          ify := Bmp.Height-1-(-ify mod Bmp.Height)
        else
          if ify > Bmp.Height-1 then
            ify := ify mod Bmp.Height;

        total_red   := 0.0;
        total_green := 0.0;
        total_blue  := 0.0;
        for ix := 0 to 1 do begin
          for iy := 0 to 1 do begin
          try
            if ify + iy < Bmp.Height then

              //sli := Bmp.scanline[ify + iy]
              sli := PByteArray(SL1[ify + iy])
            else
              //sli := Bmp.scanline[Bmp.Height - ify - iy];
              sli := PByteArray(SL1[Bmp.Height - ify - iy]);

            if ifx + ix < Bmp.Width then begin
              new_red   := sli[(ifx + ix)*3];
              new_green := sli[(ifx + ix)*3+1];
              new_blue  := sli[(ifx + ix)*3+2];
            end else begin
              new_red   := sli[(Bmp.Width - ifx - ix)*3];
              new_green := sli[(Bmp.Width - ifx - ix)*3+1];
              new_blue  := sli[(Bmp.Width - ifx - ix)*3+2];
            end;

            weight := weight_x[ix] * weight_y[iy];
            total_red   := total_red   + new_red   * weight;
            total_green := total_green + new_green * weight;
            total_blue  := total_blue  + new_blue  * weight;
            except
            end;
          end;
        end;
        //slo := Dst.scanline[ty];
        slo := PByteArray(SL2[ty]);
        slo[tx*3]   := Round(total_red);
        slo[tx*3+1] := Round(total_green);
        slo[tx*3+2] := Round(total_blue);

      end;

      if ty mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*ty/Dst.Height),Terminating);
      if Terminating then Break;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

procedure GaussianBlur(D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
var
  i : Integer;
begin
  for i := Amount downto 0 do
    SplitBlurW(D,3,CallBack);
end;


procedure SplitBlur(S, D : TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
begin
  D.Assign(S);
  D.PixelFormat:=pf24bit;
  SplitBlurW(D,Amount,CallBack);
end;

procedure SplitBlurW(D: TBitmap; Amount : Integer; CallBack : TBaseEffectCallBackProc = nil);
//procedure SplitBlur(var clip: tbitmap; Amount: integer);
var
  p0, p1, p2 : pbytearray;
  cx, x, y : Integer;
  Buf : array[0..3,0..2]of byte;
  Terminating : boolean;
  SL : TScanlines;
begin

  if Amount = 0 then Exit;
  Terminating:=false;
  SL := TScanlines.Create(D);
  try

    for y := 0 to D.Height-1 do
    begin
      //p0 := clip.scanline[y];
      //if y-Amount<0         then p1 := clip.scanline[y]
      //else {y-Amount>0}          p1 := clip.ScanLine[y-Amount];
      //if y+Amount<clip.Height    then p2 := clip.ScanLine[y+Amount]
      //else {y+Amount>=Height}    p2 := clip.ScanLine[clip.Height-y];

      p0 := PByteArray(SL[y]);
      if y-Amount<0
        then p1 := PByteArray(SL[y])
      else {y-Amount>0}
        p1 := PByteArray(SL[y-Amount]);

      if y+Amount<D.Height then
        p2 := PByteArray(SL[y+Amount])
      else {y+Amount>=Height}
        p2 := PByteArray(SL[D.Height-y]);

      for x := 0 to D.Width-1 do begin
        if x-Amount<0 then
          cx := x
        else {x-Amount>0}
          cx := x-Amount;

        Buf[0,0] := p1[cx*3];
        Buf[0,1] := p1[cx*3+1];
        Buf[0,2] := p1[cx*3+2];
        Buf[1,0] := p2[cx*3];
        Buf[1,1] := p2[cx*3+1];
        Buf[1,2] := p2[cx*3+2];

        if x+Amount<D.Width  then
          cx := x+Amount
        else {x+Amount>=Width}
          cx := D.Width-x;

        Buf[2,0] := p1[cx*3];
        Buf[2,1] := p1[cx*3+1];
        Buf[2,2] := p1[cx*3+2];
        Buf[3,0] := p2[cx*3];
        Buf[3,1] := p2[cx*3+1];
        Buf[3,2] := p2[cx*3+2];
        p0[x*3]   := (Buf[0,0]+Buf[1,0]+Buf[2,0]+Buf[3,0])shr 2;
        p0[x*3+1] := (Buf[0,1]+Buf[1,1]+Buf[2,1]+Buf[3,1])shr 2;
        p0[x*3+2] := (Buf[0,2]+Buf[1,2]+Buf[2,2]+Buf[3,2])shr 2;
      end;
      if y mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*y/D.Height),Terminating);
      if Terminating then Break;
    end;

  finally
    SL.Free;
  end;
end;

procedure Twist(Bmp, Dst: TBitmap; Amount: integer; CallBack : TBaseEffectCallBackProc = nil);
var
  fxmid, fymid : Single;
  txmid, tymid : Single;
  fx,fy : Single;
  tx2, ty2 : Single;
  r : Single;
  theta : Single;
  ifx, ify : integer;
  dx, dy : Single;
  OFFSET : Single;
  ty, tx             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue               : Integer;
  total_red, total_green : Single;
  total_blue             : Single;
  ix, iy                 : Integer;
  sli, slo : PBytearray;

  SL1, SL2 : TScanlines;
  Terminating : Boolean;

  function ArcTan2(xt,yt : Single): Single;
  begin
    if xt = 0 then
      if yt > 0 then
        Result := Pi/2
      else
        Result := -(Pi/2)
    else begin
      Result := ArcTan(yt/xt);
      if xt < 0 then
        Result := Pi + ArcTan(yt/xt);
    end;
  end;

begin
  Dst.Assign(Bmp);
  Terminating:=false;
  OFFSET := -(Pi/2);
  dx := Bmp.Width - 1;
  dy := Bmp.Height - 1;
  r := Sqrt(dx * dx + dy * dy);
  tx2 := r;
  ty2 := r;
  txmid := (Bmp.Width-1)/2;    //Adjust these to move center of rotation
  tymid := (Bmp.Height-1)/2;   //Adjust these to move ......
  fxmid := (Bmp.Width-1)/2;
  fymid := (Bmp.Height-1)/2;
  if tx2 >= Bmp.Width then tx2 := Bmp.Width-1;
  if ty2 >= Bmp.Height then ty2 := Bmp.Height-1;

  SL1 := TScanlines.Create(Bmp);
  SL2 := TScanlines.Create(Dst);
  try

    for ty := 0 to Round(ty2) do begin
      for tx := 0 to Round(tx2) do begin
        dx := tx - txmid;
        dy := ty - tymid;
        r := Sqrt(dx * dx + dy * dy);
        if r = 0 then begin
          fx := 0;
          fy := 0;
        end
        else begin
          theta := ArcTan2(dx,dy) - r/Amount - OFFSET;
          fx := r * Cos(theta);
          fy := r * Sin(theta);
        end;
        fx := fx + fxmid;
        fy := fy + fymid;

        ify := Trunc(fy);
        ifx := Trunc(fx);
                  // Calculate the weights.
        if fy >= 0  then begin
          weight_y[1] := fy - ify;
          weight_y[0] := 1 - weight_y[1];
        end else begin
          weight_y[0] := -(fy - ify);
          weight_y[1] := 1 - weight_y[0];
        end;

        if fx >= 0 then begin
          weight_x[1] := fx - ifx;
          weight_x[0] := 1 - weight_x[1];
        end else begin
          weight_x[0] := -(fx - ifx);
          Weight_x[1] := 1 - weight_x[0];
        end;

        if ifx < 0 then
          ifx := Bmp.Width-1-(-ifx mod Bmp.Width)
        else
          if ifx > Bmp.Width-1  then
            ifx := ifx mod Bmp.Width;

        if ify < 0 then
          ify := Bmp.Height-1-(-ify mod Bmp.Height)
        else
          if ify > Bmp.Height-1 then
            ify := ify mod Bmp.Height;

        total_red   := 0.0;
        total_green := 0.0;
        total_blue  := 0.0;
        for ix := 0 to 1 do begin
          for iy := 0 to 1 do begin
            if ify + iy < Bmp.Height then
              //sli := Bmp.scanline[ify + iy]
              sli := PByteArray(SL1[ify + iy])
            else
              //sli := Bmp.scanline[Bmp.Height - ify - iy];
              sli := PByteArray(SL1[Bmp.Height - ify - iy]);

            if ifx + ix < Bmp.Width then begin
              new_red := sli[(ifx + ix)*3];
              new_green := sli[(ifx + ix)*3+1];
              new_blue := sli[(ifx + ix)*3+2];
            end else begin
              new_red := sli[(Bmp.Width - ifx - ix)*3];
              new_green := sli[(Bmp.Width - ifx - ix)*3+1];
              new_blue := sli[(Bmp.Width - ifx - ix)*3+2];
            end;

            weight := weight_x[ix] * weight_y[iy];
            total_red   := total_red   + new_red   * weight;
            total_green := total_green + new_green * weight;
            total_blue  := total_blue  + new_blue  * weight;
          end;
        end;
        //slo := Dst.scanline[ty];
        slo := PByteArray(SL2[ty]);
        slo[tx*3]   := Round(total_red);
        slo[tx*3+1] := Round(total_green);
        slo[tx*3+2] := Round(total_blue);
      end;
      if ty mod 50=0 then
      If Assigned(CallBack) then CallBack(Round(100*ty/Dst.Height),Terminating);
      if Terminating then Break;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

procedure ThreadDraw(S, D : TBitmap; x, y : integer);
var
 SXp,DXp : array of PARGB;
 ymax,xmax : integer;
 i, j : integer;
begin
 if S.Width-1+x>D.Width-1 then
 xmax:=D.Width-x-1 else xmax:=S.Width-1;

 if S.Height-1+y>D.Height-1 then
 ymax:=D.Height-y-1 else ymax:=S.Height-1;

{ xmax:=min(D.Width-1,S.Width-1);
 ymax:=min(D.Height-1,S.Height-1);}
 s.PixelFormat:=pf24bit;
 d.PixelFormat:=pf24bit;
 SetLength(SXp,S.height);
 for i:=0 to S.height-1 do
 SXp[i]:=S.ScanLine[i];
 SetLength(DXp,D.height);
 for i:=0 to D.height-1 do
 DXp[i]:=D.ScanLine[i];

 for i:=0 to ymax do
 for j:=0 to xmax do
 try
 DXp[i+y,j+x]:=SXp[i,j];
 except
 end;
end;

end.
