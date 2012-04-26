unit janFX;


{ original release 2-july-2000

  janFX is written by Jan Verhoeven
  most routines are written by myself,
  some are extracted from freeware sources on the internet

  to use this library add it to your library path
  with Tools - Environment Options - Library path

  in your application you just call the routines
  for clarity and convenience you might preceed them with janFX like:

  janFX.Buttonize(src,depth,weight);


  this library is the updated succesor of my TjanPaintFX component
  }


interface
{$DEFINE USE_SCANLINE}

uses
  Windows, SysUtils,  Classes, Graphics,   math;

type




  // Type of a filter for use with Stretch()
  TFilterProc = function(Value: Single): Single;
  TLightBrush=(lbBrightness,lbContrast,lbSaturation,
    lbfisheye,lbrotate,lbtwist,lbrimple,
    mbHor,mbTop,mbBottom,mbDiamond,mbWaste,mbRound,
    mbround2,mbsplitround,mbsplitwaste);
  // For scanline simplification
  TRGBArray = ARRAY[0..32767] OF TRGBTriple;
  pRGBArray = ^TRGBArray;

    function ConvertColor(Value: Integer): TColor;
    function Set255(Clr: integer): integer;
    procedure CopyMe(tobmp: TBitmap; frbmp: TGraphic);
    procedure MaskOval(src: TBitmap;acolor:TColor);
    procedure Buttonize(src: TBitmap;depth:byte;weight:integer);
    procedure ButtonizeOval(src: TBitmap;depth:byte;weight:integer;rim:string);
    procedure Seamless(src: TBitmap;depth:byte);
    procedure ConvolveM(ray : array of integer; z : word; aBmp : TBitmap);
    procedure ConvolveE(ray : array of integer; z : word; aBmp : TBitmap);
    procedure ConvolveI(ray : array of integer; z : word; aBmp : TBitmap);
    procedure ConvolveFilter(filternr,edgenr: integer; src: TBitmap);
    // filternr=0..8 edgenr=0..2 (0 for seamless)
    procedure Solorize(src,dst:tbitmap;amount:integer);
    procedure Posterize(src,dst:tbitmap;amount:integer);
    procedure Blend(src1,src2,dst:tbitmap;amount:extended);
    procedure ExtractColor(src:TBitmap;Acolor:tcolor);
    procedure ExcludeColor(src:TBitmap;Acolor:tcolor);
    procedure turn(src,dst:tbitmap);
    procedure turnRight(src,dst:Tbitmap);
    procedure HeightMap(src:Tbitmap;amount:integer);
    procedure TexturizeTile(src:TBitmap;amount:integer);
    procedure TexturizeOverlap(src:TBitmap;amount:integer);
    procedure RippleRandom(src:TBitmap;amount:integer);
    procedure RippleTooth(src:TBitmap;amount:integer);
    procedure RippleTriangle(src:TBitmap;amount:integer);
    procedure Triangles(src:TBitmap;amount:integer);
    procedure DrawMandelJulia(src: Tbitmap; x0, y0, x1, y1: extended;
      Niter: integer; Mandel: Boolean);
    procedure filterxblue(src: tbitmap; min, max: integer);
    procedure filterxgreen(src: tbitmap; min, max: integer);
    procedure filterxred(src: tbitmap; min, max: integer);
    procedure filterblue(src: tbitmap; min, max: integer);
    procedure filtergreen(src: tbitmap; min, max: integer);
    procedure filterred(src: tbitmap; min, max: integer);
    procedure Emboss(var Bmp: TBitmap);
    procedure Plasma(src1,src2,dst:Tbitmap;scale,turbulence:extended);
    procedure Shake(src,dst:Tbitmap;factor:extended);
    procedure ShakeDown(src,dst:Tbitmap;factor:extended);
    procedure KeepBlue(src:Tbitmap;factor:extended);
    procedure KeepGreen(src:Tbitmap;factor:extended);
    procedure KeepRed(src:Tbitmap;factor:extended);
    procedure MandelBrot(src:Tbitmap;factor:integer);
    procedure MaskMandelBrot(src:Tbitmap;factor:integer);
    procedure FoldRight(src1,src2,dst:Tbitmap;amount:extended);
    procedure QuartoOpaque(src, dst: tbitmap);
    procedure semiOpaque(src, dst: Tbitmap);
    procedure ShadowDownLeft(src: tbitmap);
    procedure ShadowDownRight(src: tbitmap);
    procedure shadowupleft(src: Tbitmap);
    procedure shadowupright(src: tbitmap);
    procedure Darkness(var src: tbitmap; Amount: integer);
    procedure Trace(src:Tbitmap;intensity:integer);
    procedure FlipRight(src:Tbitmap);
    procedure FlipDown(src:Tbitmap);
    procedure SpotLight(var src:Tbitmap; Amount:integer;Spot:TRect);
    procedure splitlight(var clip: tbitmap; amount: integer);
    procedure MakeSeamlessClip(var clip: tbitmap; seam: integer);
    procedure Wave(var clip: tbitmap; amount, inference, style: integer);
    procedure Mosaic(var Bm: TBitmap; size: Integer);
    function TrimInt(i, Min, Max: Integer): Integer;
    procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer;
      Angle: Extended);
    procedure SmoothResize(var Src, Dst: TBitmap);
    procedure Twist(Bmp, Dst: TBitmap; Amount: integer);
    procedure SplitBlur(var clip:tbitmap;Amount:integer);
    procedure GaussianBlur(var clip:tbitmap;Amount: integer);
    procedure Smooth(var clip:tbitmap;Weight: Integer);
    procedure GrayScale(var clip:tbitmap);
    procedure AddColorNoise(var clip:tbitmap;Amount: Integer);
    procedure AddMonoNoise(var clip:tbitmap;Amount: Integer);
    procedure Contrast(var clip:tbitmap;Amount: Integer);
    procedure Lightness(var clip:tbitmap;Amount: Integer);
    procedure Saturation(var clip:tbitmap;Amount: Integer);
    procedure Spray(var clip:tbitmap;Amount: Integer);
    procedure AntiAlias(clip:tbitmap);
    procedure AntiAliasRect(clip:tbitmap;XOrigin, YOrigin, XFinal, YFinal: Integer);
    procedure SmoothPoint(var clip:tbitmap;xk, yk: integer);
    procedure FishEye(Bmp, Dst: TBitmap; Amount: Extended);
    procedure marble(var src, dst: tbitmap; scale: extended;turbulence:integer);
    procedure marble2(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble3(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble4(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble5(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble6(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble7(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure marble8(var src, dst: tbitmap; scale: extended;
      turbulence: integer);
    procedure squeezehor(src,dst:tbitmap;amount:integer;style:TLightBrush);
    procedure splitround(src,dst:tbitmap;amount:integer;style:TLightBrush);

    procedure tile(src,dst:TBitmap;amount:integer);
    // Interpolator
    // Src:	Source bitmap
    // Dst:	Destination bitmap
    // filter:	Weight calculation filter
    // fwidth:	Relative sample radius
    procedure Strecth(Src, Dst: TBitmap; filter: TFilterProc; fwidth: single);
    procedure Grow(Src1,Src2,Dst: TBitmap; amount:extended;x,y:integer);
    procedure Invert(src:tbitmap);
    procedure MirrorRight(src:Tbitmap);
    procedure MirrorDown(src:Tbitmap);

  // Sample filters for use with Stretch()
  function SplineFilter(Value: Single): Single;
  function BellFilter(Value: Single): Single;
  function TriangleFilter(Value: Single): Single;
  function BoxFilter(Value: Single): Single;
  function HermiteFilter(Value: Single): Single;
  function Lanczos3Filter(Value: Single): Single;
  function MitchellFilter(Value: Single): Single;

const
  MaxPixelCount = 32768;

// -----------------------------------------------------------------------------
//
//			List of Filters
//
// -----------------------------------------------------------------------------

  ResampleFilters: array[0..6] of record
    Name: string;	// Filter name
    Filter: TFilterProc;// Filter implementation
    Width: Single;	// Suggested sampling width/radius
  end = (
    (Name: 'Box';	Filter: BoxFilter;	Width: 0.5),
    (Name: 'Triangle';	Filter: TriangleFilter;	Width: 1.0),
    (Name: 'Hermite';	Filter: HermiteFilter;	Width: 1.0),
    (Name: 'Bell';	Filter: BellFilter;	Width: 1.5),
    (Name: 'B-Spline';	Filter: SplineFilter;	Width: 2.0),
    (Name: 'Lanczos3';	Filter: Lanczos3Filter;	Width: 3.0),
    (Name: 'Mitchell';	Filter: MitchellFilter;	Width: 2.0)
    );



implementation




type
TRGBTripleArray = ARRAY[0..MaxPixelCount-1] OF
TRGBTriple;
pRGBTripleArray = ^TRGBTripleArray;
TFColor=record
  b,g,r: Byte;
end;


// Bell filter
function BellFilter(Value: Single): Single;
begin
 if (Value < 0.0) then
    Value := -Value;
  if (Value < 0.5) then
    Result := 0.75 - Sqr(Value)
  else if (Value < 1.5) then
  begin
    Value := Value - 1.5;
    Result := 0.5 * Sqr(Value);
  end else
    Result := 0.0;
end;

// Box filter
// a.k.a. "Nearest Neighbour" filter
// anme: I have not been able to get acceptable
//       results with this filter for subsampling.
function BoxFilter(Value: Single): Single;
begin
  if (Value > -0.5) and (Value <= 0.5) then
    Result := 1.0
  else
    Result := 0.0;
end;

// Hermite filter
function HermiteFilter(Value: Single): Single;
begin
  // f(t) = 2|t|^3 - 3|t|^2 + 1, -1 <= t <= 1
  if (Value < 0.0) then
    Value := -Value;
  if (Value < 1.0) then
    Result := (2.0 * Value - 3.0) * Sqr(Value) + 1.0
  else
    Result := 0.0;
end;

// Lanczos3 filter
function Lanczos3Filter(Value: Single): Single;
 function SinC(Value: Single): Single;
  begin
    if (Value <> 0.0) then
    begin
      Value := Value * Pi;
      Result := sin(Value) / Value
    end else
      Result := 1.0;
  end;
begin
  if (Value < 0.0) then
    Value := -Value;
  if (Value < 3.0) then
    Result := SinC(Value) * SinC(Value / 3.0)
  else
    Result := 0.0;
end;

function MitchellFilter(Value: Single): Single;
const
  B		= (1.0 / 3.0);
  C		= (1.0 / 3.0);
var
  tt			: single;
begin
  if (Value < 0.0) then
    Value := -Value;
  tt := Sqr(Value);
  if (Value < 1.0) then
  begin
    Value := (((12.0 - 9.0 * B - 6.0 * C) * (Value * tt))
      + ((-18.0 + 12.0 * B + 6.0 * C) * tt)
      + (6.0 - 2 * B));
    Result := Value / 6.0;
  end else
  if (Value < 2.0) then
  begin
    Value := (((-1.0 * B - 6.0 * C) * (Value * tt))
      + ((6.0 * B + 30.0 * C) * tt)
      + ((-12.0 * B - 48.0 * C) * Value)
      + (8.0 * B + 24 * C));
    Result := Value / 6.0;
  end else
    Result := 0.0;
end;

// B-spline filter
function SplineFilter(Value: Single): Single;
var
  tt			: single;
begin
  if (Value < 0.0) then
    Value := -Value;
  if (Value < 1.0) then
  begin
    tt := Sqr(Value);
    Result := 0.5*tt*Value - tt + 2.0 / 3.0;
  end else if (Value < 2.0) then
  begin
    Value := 2.0 - Value;
    Result := 1.0/6.0 * Sqr(Value) * Value;
  end else
    Result := 0.0;
end;

// Triangle filter
// a.k.a. "Linear" or "Bilinear" filter
function TriangleFilter(Value: Single): Single;
begin
 if (Value < 0.0) then
    Value := -Value;
  if (Value < 1.0) then
    Result := 1.0 - Value
  else
    Result := 0.0;
end;


function IntToByte(i:Integer):Byte;
begin
  if      i>255 then Result:=255
  else if i<0   then Result:=0
  else               Result:=i;
end;

procedure AddColorNoise(var clip: tbitmap; Amount: Integer);
var
p0:pbytearray;
x,y,r,g,b: Integer;

begin
  for y:=0 to clip.Height-1 do
  begin
    p0:=clip.ScanLine [y];
    for x:=0 to clip.Width-1 do
    begin
      r:=p0[x*3]+(Random(Amount)-(Amount shr 1));
      g:=p0[x*3+1]+(Random(Amount)-(Amount shr 1));
      b:=p0[x*3+2]+(Random(Amount)-(Amount shr 1));
      p0[x*3]:=IntToByte(r);
      p0[x*3+1]:=IntToByte(g);
      p0[x*3+2]:=IntToByte(b);
    end;
  end;
end;

procedure AddMonoNoise(var clip: tbitmap; Amount: Integer);
var
p0:pbytearray;
x,y,a,r,g,b: Integer;
begin
  for y:=0 to clip.Height-1 do
  begin
    p0:=clip.scanline[y];
    for x:=0 to clip.Width-1 do
    begin
      a:=Random(Amount)-(Amount shr 1);
      r:=p0[x*3]+a;
      g:=p0[x*3+1]+a;
      b:=p0[x*3+2]+a;
      p0[x*3]:=IntToByte(r);
      p0[x*3+1]:=IntToByte(g);
      p0[x*3+2]:=IntToByte(b);
    end;
  end;
end;

procedure AntiAlias(clip: tbitmap);
begin
AntiAliasRect(clip,0,0,clip.width,clip.height);
end;

procedure AntiAliasRect(clip: tbitmap; XOrigin, YOrigin,
  XFinal, YFinal: Integer);
var Memo,x,y: Integer; (* Composantes primaires des points environnants *)
    p0,p1,p2:pbytearray;

begin
   if XFinal<XOrigin then begin Memo:=XOrigin; XOrigin:=XFinal; XFinal:=Memo; end;  (* Inversion des valeurs   *)
   if YFinal<YOrigin then begin Memo:=YOrigin; YOrigin:=YFinal; YFinal:=Memo; end;  (* si diff‚rence n‚gative*)
   XOrigin:=max(1,XOrigin);
   YOrigin:=max(1,YOrigin);
   XFinal:=min(clip.width-2,XFinal);
   YFinal:=min(clip.height-2,YFinal);
   clip.PixelFormat :=pf24bit;
   for y:=YOrigin to YFinal do begin
    p0:=clip.ScanLine [y-1];
    p1:=clip.scanline [y];
    p2:=clip.ScanLine [y+1];
    for x:=XOrigin to XFinal do begin
      p1[x*3]:=(p0[x*3]+p2[x*3]+p1[(x-1)*3]+p1[(x+1)*3])div 4;
      p1[x*3+1]:=(p0[x*3+1]+p2[x*3+1]+p1[(x-1)*3+1]+p1[(x+1)*3+1])div 4;
      p1[x*3+2]:=(p0[x*3+2]+p2[x*3+2]+p1[(x-1)*3+2]+p1[(x+1)*3+2])div 4;
      end;
   end;
end;

procedure Contrast(var clip: tbitmap; Amount: Integer);
var
p0:pbytearray;
rg,gg,bg,r,g,b,x,y:  Integer;
begin
  for y:=0 to clip.Height-1 do
  begin
    p0:=clip.scanline[y];
    for x:=0 to clip.Width-1 do
    begin
      r:=p0[x*3];
      g:=p0[x*3+1];
      b:=p0[x*3+2];
      rg:=(Abs(127-r)*Amount)div 255;
      gg:=(Abs(127-g)*Amount)div 255;
      bg:=(Abs(127-b)*Amount)div 255;
      if r>127 then r:=r+rg else r:=r-rg;
      if g>127 then g:=g+gg else g:=g-gg;
      if b>127 then b:=b+bg else b:=b-bg;
      p0[x*3]:=IntToByte(r);
      p0[x*3+1]:=IntToByte(g);
      p0[x*3+2]:=IntToByte(b);
    end;
  end;
end;

procedure FishEye( Bmp, Dst: TBitmap; Amount: Extended);
var
xmid,ymid              : Single;
fx,fy                  : Single;
r1, r2                 : Single;
ifx, ify               : integer;
dx, dy                 : Single;
rmax                   : Single;
ty, tx                 : Integer;
weight_x, weight_y     : array[0..1] of Single;
weight                 : Single;
new_red, new_green     : Integer;
new_blue               : Integer;
total_red, total_green : Single;
total_blue             : Single;
ix, iy                 : Integer;
sli, slo : PByteArray;
begin
  xmid := Bmp.Width/2;
  ymid := Bmp.Height/2;
  rmax := Dst.Width * Amount;

  for ty := 0 to Dst.Height - 1 do begin
    for tx := 0 to Dst.Width - 1 do begin
      dx := tx - xmid;
      dy := ty - ymid;
      r1 := Sqrt(dx * dx + dy * dy);
      if r1 = 0 then begin
        fx := xmid;
        fy := ymid;
      end
      else begin
        r2 := rmax / 2 * (1 / (1 - r1/rmax) - 1);
        fx := dx * r2 / r1 + xmid;
        fy := dy * r2 / r1 + ymid;
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
      else if ifx > Bmp.Width-1  then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height-1-(-ify mod Bmp.Height)
      else if ify > Bmp.Height-1 then
        ify := ify mod Bmp.Height;

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          if ify + iy < Bmp.Height then
            sli := Bmp.scanline[ify + iy]
          else
            sli := Bmp.scanline[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then begin
            new_red := sli[(ifx + ix)*3];
            new_green := sli[(ifx + ix)*3+1];
            new_blue := sli[(ifx + ix)*3+2];
          end
          else begin
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
      slo := Dst.scanline[ty];
      slo[tx*3] := Round(total_red);
      slo[tx*3+1] := Round(total_green);
      slo[tx*3+2] := Round(total_blue);

    end;
  end;
end;

procedure GaussianBlur(var clip: tbitmap; Amount: integer);
var
i: Integer;
begin
  for i:=Amount downto 0 do
  SplitBlur(clip,3);
end;

procedure GrayScale(var clip: tbitmap);
var
p0:pbytearray;
Gray,x,y: Integer;
begin
  for y:=0 to clip.Height-1 do
  begin
    p0:=clip.scanline[y];
    for x:=0 to clip.Width-1 do
    begin
      Gray:=Round(p0[x*3]*0.3+p0[x*3+1]*0.59+p0[x*3+2]*0.11);
      p0[x*3]:=Gray;
      p0[x*3+1]:=Gray;
      p0[x*3+2]:=Gray;
    end;
  end;
end;

procedure Lightness(var clip: tbitmap; Amount: Integer);
var
p0:pbytearray;
r,g,b,p,x,y: Integer;
begin
  for y:=0 to clip.Height-1 do begin
    p0:=clip.scanline[y];
    for x:=0 to clip.Width-1 do
    begin
      r:=p0[x*3];
      g:=p0[x*3+1];
      b:=p0[x*3+2];
      p0[x*3]:=IntToByte(r+((255-r)*Amount)div 255);
      p0[x*3+1]:=IntToByte(g+((255-g)*Amount)div 255);
      p0[x*3+2]:=IntToByte(b+((255-b)*Amount)div 255);
    end;
  end;
end;

procedure Darkness(var src: tbitmap; Amount: integer);
var
p0:pbytearray;
r,g,b,x,y: Integer;
begin
  src.pixelformat:=pf24bit;
  for y:=0 to src.Height-1 do begin
    p0:=src.scanline[y];
    for x:=0 to src.Width-1 do
    begin
      r:=p0[x*3];
      g:=p0[x*3+1];
      b:=p0[x*3+2];
      p0[x*3]:=IntToByte(r-((r)*Amount)div 255);
      p0[x*3+1]:=IntToByte(g-((g)*Amount)div 255);
      p0[x*3+2]:=IntToByte(b-((b)*Amount)div 255);
   end;
  end;
end;


procedure marble(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.width:=w;
dst.height:=h;
dst.canvas.Draw (0,0,src);
for y:=0 to h-1 do begin
    yy:=scale*cos((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-scale*sin((x mod turbulence)/ scale);
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;



procedure marble2(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    yy:=scale*cos((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-scale*sin((x mod turbulence)/ scale);
      xm:=round(abs(x+xx-yy));
      ym:=round(abs(y+yy-xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure marble3(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    yy:=scale*cos((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-scale*sin((x mod turbulence)/ scale);
      xm:=round(abs(x-xx+yy));
      ym:=round(abs(y-yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure marble4(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    yy:=scale*sin((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-scale*cos((x mod turbulence)/ scale);
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure marble5(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=h-1 downto 0 do begin
    yy:=scale*cos((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=w-1 downto 0 do begin
      xx:=-scale*sin((x mod turbulence)/ scale);
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;

procedure marble6(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    yy:=scale*cos((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-tan((x mod turbulence)/ scale)/scale;
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure marble7(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    yy:=scale*sin((y mod turbulence)/scale);

    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      xx:=-tan((x mod turbulence)/ scale)/(scale*scale);
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure marble8(var src, dst: tbitmap; scale: extended;
  turbulence: integer);
var x,xm,y,ym:integer;
    xx,yy:extended;
    p1,p2:pbytearray;
    w,h:integer;
    xs,xc,ax:extended;
begin
h:=src.height;
w:=src.width;
dst.assign(src);
for y:=0 to h-1 do begin
    ax:=(y mod turbulence)/ scale;
    yy:=scale*sin(ax)*cos(1.5*ax);
    p1:=src.scanline[y];
      for x:=0 to w-1 do begin
      ax:=(x mod turbulence)/ scale;
      xx:=-scale*sin(2*ax)*cos(ax);
      xm:=round(abs(x+xx+yy));
      ym:=round(abs(y+yy+xx));
      if ym<h then begin
       p2:=dst.scanline[ym];
       if xm<w then begin
          p2[xm*3]:=p1[x*3];
          p2[xm*3+1]:=p1[x*3+1];
          p2[xm*3+2]:=p1[x*3+2];
          end;
       end;
      end;
    end;
  end;


procedure Saturation(var clip: tbitmap; Amount: Integer);
var
p0:pbytearray;
Gray,r,g,b,x,y: Integer;
begin
  for y:=0 to clip.Height-1 do begin
    p0:=clip.scanline[y];
    for x:=0 to clip.Width-1 do
    begin
      r:=p0[x*3];
      g:=p0[x*3+1];
      b:=p0[x*3+2];
      Gray:=(r+g+b)div 3;
      p0[x*3]:=IntToByte(Gray+(((r-Gray)*Amount)div 255));
      p0[x*3+1]:=IntToByte(Gray+(((g-Gray)*Amount)div 255));
      p0[x*3+2]:=IntToByte(Gray+(((b-Gray)*Amount)div 255));
    end;
  end;
end;


procedure Smooth(var clip: tbitmap; Weight: Integer);
begin
//
end;

procedure SmoothPoint(var clip: tbitmap; xk, yk: integer);
var Bleu, Vert, Rouge,w,h: Integer;
   color:TFColor;
   Acolor:tcolor;
   BB,GG,RR: array[1..5] of Integer;
begin
     w:=clip.width;
     h:=clip.height;
if (xk>0) and (yk>0) and (xk<w-1) and (yk<h-1) then
     with clip.canvas do begin
     Acolor:=colortorgb(pixels[xk,yk-1]);
     color.r:=getrvalue(Acolor);
     color.g:=getgvalue(Acolor);
     color.b:=getbvalue(Acolor);
     RR[1]:=color.r;
     GG[1]:=color.g;
     BB[1]:=color.b;
     Acolor:=colortorgb(pixels[xk+1,yk]);
     color.r:=getrvalue(Acolor);
     color.g:=getgvalue(Acolor);
     color.b:=getbvalue(Acolor);
     RR[2]:=color.r;
     GG[2]:=color.g;
     BB[2]:=color.b;
     acolor:=colortorgb(pixels[xk,yk+1]);
     color.r:=getrvalue(Acolor);
     color.g:=getgvalue(Acolor);
     color.b:=getbvalue(Acolor);
     RR[3]:=color.r;
     GG[3]:=color.g;
     BB[3]:=color.b;
     acolor:=colortorgb(pixels[xk-1,yk]);
     color.r:=getrvalue(Acolor);
     color.g:=getgvalue(Acolor);
     color.b:=getbvalue(Acolor);
     RR[4]:=color.r;
     GG[4]:=color.g;
     BB[4]:=color.b;
     Bleu :=(BB[1]+(BB[2]+BB[3]+BB[4]))div 4;           (* Valeur moyenne *)
     Vert:=(GG[1]+(GG[2]+GG[3]+GG[4]))div 4;           (* en cours d'‚valuation        *)
     Rouge  :=(RR[1]+(RR[2]+RR[3]+RR[4]))div 4;
     color.r:=rouge;
     color.g:=vert;
     color.b:=bleu;
     pixels[xk,yk]:=rgb(color.r,color.g,color.b);
     end;
end;

procedure SmoothResize(var Src, Dst: TBitmap);
var
x,y,xP,yP,
yP2,xP2:     Integer;
Read,Read2:  PByteArray;
t,t3,t13,z,z2,iz2:  Integer;
pc:PBytearray;
w1,w2,w3,w4: Integer;
Col1r,col1g,col1b,Col2r,col2g,col2b:   byte;
begin
  xP2:=((src.Width-1)shl 15)div Dst.Width;
  yP2:=((src.Height-1)shl 15)div Dst.Height;
  yP:=0;
  for y:=0 to Dst.Height-1 do
  begin
    xP:=0;
    Read:=src.ScanLine[yP shr 15];
    if yP shr 16<src.Height-1 then
      Read2:=src.ScanLine [yP shr 15+1]
    else
      Read2:=src.ScanLine [yP shr 15];
    pc:=Dst.scanline[y];
    z2:=yP and $7FFF;
    iz2:=$8000-z2;
    for x:=0 to Dst.Width-1 do
    begin
      t:=xP shr 15;
      t3:=t*3;
      t13:=t3+3;
      Col1r:=Read[t3];
      Col1g:=Read[t3+1];
      Col1b:=Read[t3+2];
      Col2r:=Read2[t3];
      Col2g:=Read2[t3+1];
      Col2b:=Read2[t3+2];
      z:=xP and $7FFF;
      w2:=(z*iz2)shr 15;
      w1:=iz2-w2;
      w4:=(z*z2)shr 15;
      w3:=z2-w4;
      pc[x*3+2]:=
        (Col1b*w1+Read[t13+2]*w2+
         Col2b*w3+Read2[t13+2]*w4)shr 15;
      pc[x*3+1]:=
        (Col1g*w1+Read[t13+1]*w2+
         Col2g*w3+Read2[t13+1]*w4)shr 15;
      // (t+1)*3  is now t13
      pc[x*3]:=
        (Col1r*w1+Read2[t13]*w2+
         Col2r*w3+Read2[t13]*w4)shr 15;
      Inc(xP,xP2);
    end;
    Inc(yP,yP2);
  end;
end;

procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer;
  Angle: Extended);
type
 TFColor  = record b,g,r:Byte end;
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
sw,se:    TFColor;
P1,P2,P3:Pbytearray;
begin
  Angle:=angle;
  Angle:=-Angle*Pi/180;
  sAngle:=Sin(Angle);
  cAngle:=Cos(Angle);
  xDiff:=(Dst.Width-Src.Width)div 2;
  yDiff:=(Dst.Height-Src.Height)div 2;
  for y:=0 to Dst.Height-1 do
  begin
    P3:=Dst.scanline[y];
    py:=2*(y-cy)+1;
    for x:=0 to Dst.Width-1 do
    begin
      px:=2*(x-cx)+1;
      fx:=(((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
      fy:=(((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
      ifx:=Round(fx);
      ify:=Round(fy);

      if(ifx>-1)and(ifx<Src.Width)and(ify>-1)and(ify<Src.Height)then
      begin
        eww:=fx-ifx;
        nsw:=fy-ify;
        iy:=TrimInt(ify+1,0,Src.Height-1);
        ix:=TrimInt(ifx+1,0,Src.Width-1);
        P1:=Src.scanline[ify];
        P2:=Src.scanline[iy];
        nw.r:=P1[ifx*3];
        nw.g:=P1[ifx*3+1];
        nw.b:=P1[ifx*3+2];
        ne.r:=P1[ix*3];
        ne.g:=P1[ix*3+1];
        ne.b:=P1[ix*3+2];
        sw.r:=P2[ifx*3];
        sw.g:=P2[ifx*3+1];
        sw.b:=P2[ifx*3+2];
        se.r:=P2[ix*3];
        se.g:=P2[ix*3+1];
        se.b:=P2[ix*3+2];

        Top:=nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        P3[x*3+2]:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        P3[x*3+1]:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        P3[x*3]:=IntToByte(Round(Top+nsw*(Bottom-Top)));
      end;
    end;
  end;
end;

procedure SplitBlur(var clip: tbitmap; Amount: integer);
var
p0,p1,p2:pbytearray;
cx,i,x,y: Integer;
Buf:   array[0..3,0..2]of byte;
begin
  if Amount=0 then Exit;
  for y:=0 to clip.Height-1 do
  begin
    p0:=clip.scanline[y];
    if y-Amount<0         then p1:=clip.scanline[y]
    else {y-Amount>0}          p1:=clip.ScanLine[y-Amount];
    if y+Amount<clip.Height    then p2:=clip.ScanLine[y+Amount]
    else {y+Amount>=Height}    p2:=clip.ScanLine[clip.Height-y];

    for x:=0 to clip.Width-1 do
    begin
      if x-Amount<0     then cx:=x
      else {x-Amount>0}      cx:=x-Amount;
      Buf[0,0]:=p1[cx*3];
      Buf[0,1]:=p1[cx*3+1];
      Buf[0,2]:=p1[cx*3+2];
      Buf[1,0]:=p2[cx*3];
      Buf[1,1]:=p2[cx*3+1];
      Buf[1,2]:=p2[cx*3+2];
      if x+Amount<clip.Width     then cx:=x+Amount
      else {x+Amount>=Width}     cx:=clip.Width-x;
      Buf[2,0]:=p1[cx*3];
      Buf[2,1]:=p1[cx*3+1];
      Buf[2,2]:=p1[cx*3+2];
      Buf[3,0]:=p2[cx*3];
      Buf[3,1]:=p2[cx*3+1];
      Buf[3,2]:=p2[cx*3+2];
      p0[x*3]:=(Buf[0,0]+Buf[1,0]+Buf[2,0]+Buf[3,0])shr 2;
      p0[x*3+1]:=(Buf[0,1]+Buf[1,1]+Buf[2,1]+Buf[3,1])shr 2;
      p0[x*3+2]:=(Buf[0,2]+Buf[1,2]+Buf[2,2]+Buf[3,2])shr 2;
    end;
  end;
end;

procedure Spray(var clip: tbitmap; Amount: Integer);
var
i,j,x,y,w,h,Val:     Integer;
begin
  h:=clip.height;
  w:=clip.Width;
  for i:=0 to w-1 do
  for j:=0 to h-1 do
  begin
    Val:=Random(Amount);
    x:=i+Val-Random(Val*2);
    y:=j+Val-Random(Val*2);
    if(x>-1)and(x<w)and(y>-1)and(y<h)then
    clip.canvas.Pixels[i,j]:=clip.canvas.Pixels[x,y];
  end;
end;

procedure Mosaic(var Bm:TBitmap;size:Integer);
var
   x,y,i,j:integer;
   p1,p2:pbytearray;
   r,g,b:byte;
begin
  y:=0;
  repeat
    p1:=bm.scanline[y];
    x:=0;
    repeat
      j:=1;
      repeat
      p2:=bm.scanline[y];
      x:=0;
      repeat
        r:=p1[x*3];
        g:=p1[x*3+1];
        b:=p1[x*3+2];
        i:=1;
       repeat
       p2[x*3]:=r;
       p2[x*3+1]:=g;
       p2[x*3+2]:=b;
       inc(x);
       inc(i);
       until (x>=bm.width) or (i>size);
      until x>=bm.width;
      inc(j);
      inc(y);
      until (y>=bm.height) or (j>size);
    until (y>=bm.height) or (x>=bm.width);
  until y>=bm.height;
end;


function TrimInt(i, Min, Max: Integer): Integer;
begin
  if      i>Max then Result:=Max
  else if i<Min then Result:=Min
  else               Result:=i;
end;

procedure Twist(Bmp, Dst: TBitmap; Amount: integer);
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
      else if ifx > Bmp.Width-1  then
        ifx := ifx mod Bmp.Width;
      if ify < 0 then
        ify := Bmp.Height-1-(-ify mod Bmp.Height)
      else if ify > Bmp.Height-1 then
        ify := ify mod Bmp.Height;

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          if ify + iy < Bmp.Height then
            sli := Bmp.scanline[ify + iy]
          else
            sli := Bmp.scanline[Bmp.Height - ify - iy];
          if ifx + ix < Bmp.Width then begin
            new_red := sli[(ifx + ix)*3];
            new_green := sli[(ifx + ix)*3+1];
            new_blue := sli[(ifx + ix)*3+2];
          end
          else begin
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
      slo := Dst.scanline[ty];
      slo[tx*3] := Round(total_red);
      slo[tx*3+1] := Round(total_green);
      slo[tx*3+2] := Round(total_blue);
    end;
  end;
end;

procedure Wave(var clip:tbitmap;amount,inference,style:integer);
var
  c,c2,x,y : integer;
  BitMap : TBitMap;
  P1,P2 : PByteArray;
  b:integer;
  fangle:real;
  wavex:integer;
begin
  BitMap := TBitMap.create;
  Bitmap.assign(clip);
  wavex:=style;
  fangle:=pi / 2 / amount;
    for y := BitMap.height -1-(2*amount) downto amount do begin
      P1 := BitMap.ScanLine[y];
      b:=0;
      for x:=0 to Bitmap.width-1 do begin
        P2 := clip.scanline[y+amount+b];
        P2[x*3]:=P1[x*3];
        P2[x*3+1]:=P1[x*3+1];
        P2[x*3+2]:=P1[x*3+2];
        case wavex of
        0: b:=amount*variant(sin(fangle*x));
        1: b:=amount*variant(sin(fangle*x)*cos(fangle*x));
        2: b:=amount*variant(sin(fangle*x)*sin(inference*fangle*x));
        end;
      end;
    end;
  BitMap.free;
end;

procedure MakeSeamlessClip(var clip:tbitmap;seam:integer);
var
  p0,p1,p2:pbytearray;
  h,w,i,j,sv,sh:integer;
  f0,f1,f2:real;
begin
h:=clip.height;
w:=clip.width;
sv:=h div seam;
sh:=w div seam;
p1:=clip.scanline[0];
p2:=clip.ScanLine [h-1];
for i:=0 to w-1 do begin
  p1[i*3]:=p2[i*3];
  p1[i*3+1]:=p2[i*3+1];
  p1[i*3+2]:=p2[i*3+2];
  end;
p0:=clip.scanline[0];
p2:=clip.scanline[sv];
for j:=1 to sv-1 do begin
  p1:=clip.scanline[j];
  for i:=0 to w-1 do begin
    f0:=(p2[i*3]-p0[i*3])/sv*j+p0[i*3];
    p1[i*3]:=  round (f0);
    f1:=(p2[i*3+1]-p0[i*3+1])/sv*j+p0[i*3+1];
    p1[i*3+1]:=round (f1);
    f2:=(p2[i*3+2]-p0[i*3+2])/sv*j+p0[i*3+2];
    p1[i*3+2]:=round (f2);
    end;
  end;
for j:=0 to h-1 do begin
  p1:=clip.scanline[j];
  p1[(w-1)*3]:=p1[0];
  p1[(w-1)*3+1]:=p1[1];
  p1[(w-1)*3+2]:=p1[2];
  for i:=1 to sh-1 do begin
    f0:=(p1[(w-sh)*3]-p1[(w-1)*3])/sh*i+p1[(w-1)*3];
    p1[(w-1-i)*3]:=round(f0);
    f1:=(p1[(w-sh)*3+1]-p1[(w-1)*3+1])/sh*i+p1[(w-1)*3+1];
    p1[(w-1-i)*3+1]:=round(f1);
    f2:=(p1[(w-sh)*3+2]-p1[(w-1)*3+2])/sh*i+p1[(w-1)*3+2];
    p1[(w-1-i)*3+2]:=round(f2);
    end;
  end;
end;

procedure splitlight(var clip:tbitmap;amount:integer);
var x,y,i:integer;
    p1:pbytearray;

    function sinpixs(a:integer):integer;
    begin
    result:=variant(sin(a/255*pi/2)*255);
    end;
begin
for i:=1 to amount do
  for y:=0 to clip.height-1 do begin
    p1:=clip.scanline[y];
    for x:=0 to clip.width-1 do begin
      p1[x*3]:=sinpixs(p1[x*3]);
      p1[x*3+1]:=sinpixs(p1[x*3+1]);
      p1[x*3+2]:=sinpixs(p1[x*3+2]);
      end;
    end;
end;

procedure squeezehor(src,dst:tbitmap;amount:integer;style:TLightBrush);
var dx,x,y,h,w,c,cx:integer;
    R:trect;
    bm:tbitmap;
    p0,p1:pbytearray;
begin
if amount>(src.width div 2) then
  amount:=src.width div 2;
bm:=tbitmap.create;
bm.PixelFormat :=pf24bit;
bm.height:=1;
bm.width:=src.width;
cx:=src.width div 2;
p0:=bm.scanline[0];
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      p0[c]:=p1[c];
      p0[c+1]:=p1[c+1];
      p0[c+2]:=p1[c+2];
      end;
    case style of
    mbhor:
      begin
      dx:=amount;
      R:=rect(dx,y,src.width-dx,y+1);
      end;
    mbtop:
      begin
      dx:= round((src.height-1-y)/src.height*amount);
      R:=rect(dx,y,src.width-dx,y+1);
      end;
    mbBottom:
      begin
      dx:= round(y/src.height*amount);
      R:=rect(dx,y,src.width-dx,y+1);
      end;
    mbDiamond:
      begin
      dx:=round(amount*abs(cos(y/(src.height-1)*pi)));
      R:=rect(dx,y,src.width-dx,y+1);
      end;
    mbWaste:
      begin
      dx:=round(amount*abs(sin(y/(src.height-1)*pi)));
      R:=rect(dx,y,src.width-dx,y+1);
      end;
    mbRound:
      begin
      dx:=round(amount*abs(sin(y/(src.height-1)*pi)));
      R:=rect(cx-dx,y,cx+dx,y+1);
      end;
    mbRound2:
      begin
      dx:=round(amount*abs(sin(y/(src.height-1)*pi*2)));
      R:=rect(cx-dx,y,cx+dx,y+1);
      end;
    end;
    dst.Canvas.StretchDraw (R,bm);
    end;
bm.free;
end;




procedure tile(src, dst: TBitmap; amount: integer);
var w,h,w2,h2,i,j:integer;
    bm:tbitmap;
begin
  w:=src.width;
  h:=src.height;
  dst.width:=w;
  dst.height:=h;
  dst.Canvas.draw(0,0,src);
  if (amount<=0) or ((w div amount)<5)or ((h div amount)<5) then exit;
  h2:=h div amount;
  w2:=w div amount;
  bm:=tbitmap.create;
  bm.width:=w2;
  bm.height:=h2;
  bm.PixelFormat :=pf24bit;
  smoothresize(src,bm);
  for j:=0 to amount-1 do
   for i:=0 to amount-1 do
     dst.canvas.Draw (i*w2,j*h2,bm);
  bm.free;
end;



// -----------------------------------------------------------------------------
//
//			Interpolator
//
// -----------------------------------------------------------------------------
type
  // Contributor for a pixel
  TContributor = record
    pixel: integer;		// Source pixel
    weight: single;		// Pixel weight
  end;

  TContributorList = array[0..0] of TContributor;
  PContributorList = ^TContributorList;

  // List of source pixels contributing to a destination pixel
  TCList = record
    n		: integer;
    p		: PContributorList;
  end;

  TCListList = array[0..0] of TCList;
  PCListList = ^TCListList;

  TRGB = packed record
    r, g, b	: single;
  end;

  // Physical bitmap pixel
  TColorRGB = packed record
    r, g, b	: BYTE;
  end;
  PColorRGB = ^TColorRGB;

  // Physical bitmap scanline (row)
  TRGBList = packed array[0..0] of TColorRGB;
  PRGBList = ^TRGBList;


procedure Strecth(Src, Dst: TBitmap; filter: TFilterProc;
  fwidth: single);
var
  xscale, yscale	: single;		// Zoom scale factors
  i, j, k		: integer;		// Loop variables
  center		: single;		// Filter calculation variables
  width, fscale, weight	: single;		// Filter calculation variables
  left, right		: integer;		// Filter calculation variables
  n			: integer;		// Pixel number
  Work			: TBitmap;
  contrib		: PCListList;
  rgb			: TRGB;
  color			: TColorRGB;
{$IFDEF USE_SCANLINE}
  SourceLine		,
  DestLine		: PRGBList;
  SourcePixel		,
  DestPixel		: PColorRGB;
  Delta			,
  DestDelta		: integer;
{$ENDIF}
  SrcWidth		,
  SrcHeight		,
  DstWidth		,
  DstHeight		: integer;

  function Color2RGB(Color: TColor): TColorRGB;
  begin
    Result.r := Color AND $000000FF;
    Result.g := (Color AND $0000FF00) SHR 8;
    Result.b := (Color AND $00FF0000) SHR 16;
  end;

  function RGB2Color(Color: TColorRGB): TColor;
  begin
    Result := Color.r OR (Color.g SHL 8) OR (Color.b SHL 16);
  end;


begin
 DstWidth := Dst.Width;
  DstHeight := Dst.Height;
  SrcWidth := Src.Width;
  SrcHeight := Src.Height;
  if (SrcWidth < 1) or (SrcHeight < 1) then
    raise Exception.Create('Source bitmap too small');

  // Create intermediate image to hold horizontal zoom
  Work := TBitmap.Create;
  try
    Work.Height := SrcHeight;
    Work.Width := DstWidth;
    // xscale := DstWidth / SrcWidth;
    // yscale := DstHeight / SrcHeight;
    // Improvement suggested by David Ullrich:
    if (SrcWidth = 1) then
      xscale:= DstWidth / SrcWidth
    else
      xscale:= (DstWidth - 1) / (SrcWidth - 1);
    if (SrcHeight = 1) then
      yscale:= DstHeight / SrcHeight
    else
      yscale:= (DstHeight - 1) / (SrcHeight - 1);
    // This implementation only works on 24-bit images because it uses
    // TBitmap.Scanline
{$IFDEF USE_SCANLINE}
    Src.PixelFormat := pf24bit;
    Dst.PixelFormat := Src.PixelFormat;
    Work.PixelFormat := Src.PixelFormat;
{$ENDIF}

    // --------------------------------------------
    // Pre-calculate filter contributions for a row
    // -----------------------------------------------
    GetMem(contrib, DstWidth* sizeof(TCList));
    // Horizontal sub-sampling
    // Scales from bigger to smaller width
    if (xscale < 1.0) then
    begin
      width := fwidth / xscale;
      fscale := 1.0 / xscale;
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / xscale;
        // Original code:
        // left := ceil(center - width);
        // right := floor(center + width);
        left := floor(center - width);
        right := ceil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end else
    // Horizontal super-sampling
    // Scales from smaller to bigger width
    begin
      for i := 0 to DstWidth-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(fwidth * 2.0 + 1) * sizeof(TContributor));
        center := i / xscale;
        // Original code:
        // left := ceil(center - fwidth);
        // right := floor(center + fwidth);
        left := floor(center - fwidth);
        right := ceil(center + fwidth);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcWidth) then
            n := SrcWidth - j + SrcWidth - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end;

    // ----------------------------------------------------
    // Apply filter to sample horizontally from Src to Work
    // ----------------------------------------------------
    for k := 0 to SrcHeight-1 do
    begin
{$IFDEF USE_SCANLINE}
      SourceLine := Src.ScanLine[k];
      DestPixel := Work.ScanLine[k];
{$ENDIF}
      for i := 0 to DstWidth-1 do
      begin
        rgb.r := 0.0;
        rgb.g := 0.0;
        rgb.b := 0.0;
        for j := 0 to contrib^[i].n-1 do
        begin
{$IFDEF USE_SCANLINE}
          color := SourceLine^[contrib^[i].p^[j].pixel];
{$ELSE}
          color := Color2RGB(Src.Canvas.Pixels[contrib^[i].p^[j].pixel, k]);
{$ENDIF}
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := round(rgb.b);
{$IFDEF USE_SCANLINE}
        // Set new pixel value
        DestPixel^ := color;
        // Move on to next column
        inc(DestPixel);
{$ELSE}
        Work.Canvas.Pixels[i, k] := RGB2Color(color);
{$ENDIF}
      end;
    end;

    // Free the memory allocated for horizontal filter weights
    for i := 0 to DstWidth-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

    // -----------------------------------------------
    // Pre-calculate filter contributions for a column
    // -----------------------------------------------
    GetMem(contrib, DstHeight* sizeof(TCList));
    // Vertical sub-sampling
    // Scales from bigger to smaller height
    if (yscale < 1.0) then
    begin
      width := fwidth / yscale;
      fscale := 1.0 / yscale;
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(width * 2.0 + 1) * sizeof(TContributor));
        center := i / yscale;
        // Original code:
        // left := ceil(center - width);
        // right := floor(center + width);
        left := floor(center - width);
        right := ceil(center + width);
        for j := left to right do
        begin
          weight := filter((center - j) / fscale) / fscale;
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end
    end else
    // Vertical super-sampling
    // Scales from smaller to bigger height
    begin
      for i := 0 to DstHeight-1 do
      begin
        contrib^[i].n := 0;
        GetMem(contrib^[i].p, trunc(fwidth * 2.0 + 1) * sizeof(TContributor));
        center := i / yscale;
        // Original code:
        // left := ceil(center - fwidth);
        // right := floor(center + fwidth);
        left := floor(center - fwidth);
        right := ceil(center + fwidth);
        for j := left to right do
        begin
          weight := filter(center - j);
          if (weight = 0.0) then
            continue;
          if (j < 0) then
            n := -j
          else if (j >= SrcHeight) then
            n := SrcHeight - j + SrcHeight - 1
          else
            n := j;
          k := contrib^[i].n;
          contrib^[i].n := contrib^[i].n + 1;
          contrib^[i].p^[k].pixel := n;
          contrib^[i].p^[k].weight := weight;
        end;
      end;
    end;

    // --------------------------------------------------
    // Apply filter to sample vertically from Work to Dst
    // --------------------------------------------------
{$IFDEF USE_SCANLINE}
    SourceLine := Work.ScanLine[0];
    Delta := integer(Work.ScanLine[1]) - integer(SourceLine);
    DestLine := Dst.ScanLine[0];
    DestDelta := integer(Dst.ScanLine[1]) - integer(DestLine);
{$ENDIF}
    for k := 0 to DstWidth-1 do
    begin
{$IFDEF USE_SCANLINE}
      DestPixel := pointer(DestLine);
{$ENDIF}
      for i := 0 to DstHeight-1 do
      begin
        rgb.r := 0;
        rgb.g := 0;
        rgb.b := 0;
        // weight := 0.0;
        for j := 0 to contrib^[i].n-1 do
        begin
{$IFDEF USE_SCANLINE}
          color := PColorRGB(integer(SourceLine)+contrib^[i].p^[j].pixel*Delta)^;
{$ELSE}
          color := Color2RGB(Work.Canvas.Pixels[k, contrib^[i].p^[j].pixel]);
{$ENDIF}
          weight := contrib^[i].p^[j].weight;
          if (weight = 0.0) then
            continue;
          rgb.r := rgb.r + color.r * weight;
          rgb.g := rgb.g + color.g * weight;
          rgb.b := rgb.b + color.b * weight;
        end;
        if (rgb.r > 255.0) then
          color.r := 255
        else if (rgb.r < 0.0) then
          color.r := 0
        else
          color.r := round(rgb.r);
        if (rgb.g > 255.0) then
          color.g := 255
        else if (rgb.g < 0.0) then
          color.g := 0
        else
          color.g := round(rgb.g);
        if (rgb.b > 255.0) then
          color.b := 255
        else if (rgb.b < 0.0) then
          color.b := 0
        else
          color.b := round(rgb.b);
{$IFDEF USE_SCANLINE}
        DestPixel^ := color;
        inc(integer(DestPixel), DestDelta);
{$ELSE}
        Dst.Canvas.Pixels[k, i] := RGB2Color(color);
{$ENDIF}
      end;
{$IFDEF USE_SCANLINE}
      Inc(SourceLine, 1);
      Inc(DestLine, 1);
{$ENDIF}
    end;

    // Free the memory allocated for vertical filter weights
    for i := 0 to DstHeight-1 do
      FreeMem(contrib^[i].p);

    FreeMem(contrib);

  finally
    Work.Free;
  end;
end;


procedure Grow(Src1, Src2, Dst: TBitmap; amount: extended;x,y:integer);
var
   bm:tbitmap;
   h,w,hr,wr:integer;
begin
w:=src1.Width ;
h:=src1.Height;
Dst.Width :=w;
Dst.Height:=h;
Dst.Canvas.Draw (0,0,Src1);
wr:= round(amount*w);
hr:= round(amount*h);
bm:=tbitmap.create;
bm.width:=wr;
bm.height:=hr;
Strecth(Src2,bm,resamplefilters[4].filter,resamplefilters[4].width);
Dst.Canvas.Draw (x,y,bm);
bm.free;
end;

procedure SpotLight(var src: Tbitmap; Amount: integer;
  Spot: TRect);
var bm:tbitmap;
    w,h:integer;
begin
Darkness(src,amount);
w:=src.Width;
h:=src.Height ;
bm:=tbitmap.create;
bm.width:=w;
bm.height:=h;
bm.canvas.Brush.color:=clblack;
bm.canvas.FillRect (rect(0,0,w,h));
bm.canvas.brush.Color :=clwhite;
bm.canvas.Ellipse (Spot.left,spot.top,spot.right,spot.bottom);
bm.transparent:=true;
bm.TransparentColor :=clwhite;
src.Canvas.Draw (0,0,bm);
bm.free;
end;


procedure FlipDown(src: Tbitmap);
var
   dest:tbitmap;
   w,h,x,y:integer;
   pd,ps:pbytearray;
begin
  w:=src.width;
  h:=src.height;
  dest:=tbitmap.create;
  dest.width:=w;
  dest.height:=h;
  dest.pixelformat:=pf24bit;
  src.pixelformat:=pf24bit;
  for y:=0 to h-1 do begin
   pd:=dest.scanline[y];
   ps:=src.scanline[h-1-y];
   for x:=0 to w-1 do begin
     pd[x*3]:=ps[x*3];
     pd[x*3+1]:=ps[x*3+1];
     pd[x*3+2]:=ps[x*3+2];
     end;
   end;
  src.assign(dest);
  dest.free;
end;

procedure FlipRight(src: Tbitmap);
var
   dest:tbitmap;
   w,h,x,y:integer;
   pd,ps:pbytearray;
begin
  w:=src.width;
  h:=src.height;
  dest:=tbitmap.create;
  dest.width:=w;
  dest.height:=h;
  dest.pixelformat:=pf24bit;
  src.pixelformat:=pf24bit;
  for y:=0 to h-1 do begin
   pd:=dest.scanline[y];
   ps:=src.scanline[y];
   for x:=0 to w-1 do begin
     pd[x*3]:=ps[(w-1-x)*3];
     pd[x*3+1]:=ps[(w-1-x)*3+1];
     pd[x*3+2]:=ps[(w-1-x)*3+2];
     end;
   end;
  src.assign(dest);
  dest.free;
end;

procedure Trace(src:Tbitmap;intensity:integer);
var
  x,y,i : integer;
  P1,P2,P3,P4 : PByteArray;
  tb,TraceB:byte;
  hasb:boolean;
  bitmap:tbitmap;
begin
  bitmap:=tbitmap.create;
  bitmap.width:=src.width;
  bitmap.height:=src.height;
  bitmap.canvas.draw(0,0,src);
  bitmap.PixelFormat :=pf8bit;
  src.PixelFormat :=pf24bit;
  hasb:=false;
  TraceB:=$00;
  for i:=1 to Intensity do begin
    for y := 0 to BitMap.height -2 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y+1];
      P3 := src.scanline[y];
      P4 := src.scanline[y+1];
      x:=0;
      repeat
        if p1[x]<>p1[x+1] then begin
           if not hasb then begin
             tb:=p1[x+1];
             hasb:=true;
             p3[x*3]:=TraceB;
             p3[x*3+1]:=TraceB;
             p3[x*3+2]:=TraceB;
             end
             else begin
             if p1[x]<>tb then
                 begin
                 p3[x*3]:=TraceB;
                 p3[x*3+1]:=TraceB;
                 p3[x*3+2]:=TraceB;
                 end
               else
                 begin
                 p3[(x+1)*3]:=TraceB;
                 p3[(x+1)*3+1]:=TraceB;
                 p3[(x+1)*3+1]:=TraceB;
                 end;
             end;
           end;
        if p1[x]<>p2[x] then begin
           if not hasb then begin
             tb:=p2[x];
             hasb:=true;
             p3[x*3]:=TraceB;
             p3[x*3+1]:=TraceB;
             p3[x*3+2]:=TraceB;
             end
             else begin
             if p1[x]<>tb then
                 begin
                 p3[x*3]:=TraceB;
                 p3[x*3+1]:=TraceB;
                 p3[x*3+2]:=TraceB;
                 end
               else
                 begin
                 p4[x*3]:=TraceB;
                 p4[x*3+1]:=TraceB;
                 p4[x*3+2]:=TraceB;
                 end;
             end;
           end;
      inc(x);
      until x>=(BitMap.width -2);
    end;
// do the same in the opposite direction
// only when intensity>1
    if i>1 then
    for y := BitMap.height -1 downto 1 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y-1];
      P3 := src.scanline[y];
      P4 := src.scanline [y-1];
      x:=Bitmap.width-1;
      repeat
        if p1[x]<>p1[x-1] then begin
           if not hasb then begin
             tb:=p1[x-1];
             hasb:=true;
             p3[x*3]:=TraceB;
             p3[x*3+1]:=TraceB;
             p3[x*3+2]:=TraceB;
             end
             else begin
             if p1[x]<>tb then
                 begin
                 p3[x*3]:=TraceB;
                 p3[x*3+1]:=TraceB;
                 p3[x*3+2]:=TraceB;
                 end
               else
                 begin
                 p3[(x-1)*3]:=TraceB;
                 p3[(x-1)*3+1]:=TraceB;
                 p3[(x-1)*3+2]:=TraceB;
                 end;
             end;
           end;
        if p1[x]<>p2[x] then begin
           if not hasb then begin
             tb:=p2[x];
             hasb:=true;
             p3[x*3]:=TraceB;
             p3[x*3+1]:=TraceB;
             p3[x*3+2]:=TraceB;
             end
             else begin
             if p1[x]<>tb then
                 begin
                 p3[x*3]:=TraceB;
                 p3[x*3+1]:=TraceB;
                 p3[x*3+2]:=TraceB;
                 end
               else
                 begin
                 p4[x*3]:=TraceB;
                 p4[x*3+1]:=TraceB;
                 p4[x*3+2]:=TraceB;
                 end;
             end;
           end;
      dec(x);
      until x<=1;
    end;
  end;
bitmap.free;
end;

procedure shadowupleft(src:Tbitmap);
var
  c,c2,x,y : integer;
  BitMap : TBitMap;
  P1,P2 : PByteArray;
begin
  BitMap := TBitMap.create;
  bitmap.width:=src.width;
  bitmap.height:=src.height;
  Bitmap.pixelformat:=pf24bit;
  Bitmap.canvas.draw(0,0,src);
    for y := 0 to BitMap.height -5 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y+4];
      for x:=0 to Bitmap.width-5 do
        if P1[x*3]>P2[(x+4)*3] then begin
        P1[x*3]:=P2[(x+4)*3]+1;
        P1[x*3+1]:=P2[(x+4)*3+1]+1;
        P1[x*3+2]:=P2[(x+4)*3+2]+1;
        end;
    end;
  src.Assign (bitmap);
  BitMap.free;
end;

procedure shadowupright(src:tbitmap);
var
  x,y : integer;
  BitMap : TBitMap;
  P1,P2 : PByteArray;
begin
  BitMap := TBitMap.create;
  bitmap.width:=src.width;
  bitmap.height:=src.height;
  Bitmap.pixelformat:=pf24bit;
  Bitmap.canvas.draw(0,0,src);
    for y := 0 to bitmap.height -5 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y+4];
      for x:=Bitmap.width-1 downto 4 do
        if P1[x*3]>P2[(x-4)*3] then begin
        P1[x*3]:=P2[(x-4)*3]+1;
        P1[x*3+1]:=P2[(x-4)*3+1]+1;
        P1[x*3+2]:=P2[(x-4)*3+2]+1;
        end;
    end;
  src.Assign (bitmap);
  BitMap.free;
end;

procedure ShadowDownLeft(src:tbitmap);
var
  x,y : integer;
  BitMap : TBitMap;
  P1,P2 : PByteArray;
begin
  BitMap := TBitMap.create;
  bitmap.width:=src.width;
  bitmap.height:=src.height;
  Bitmap.pixelformat:=pf24bit;
  Bitmap.canvas.draw(0,0,src);
    for y := bitmap.height -1 downto 4 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y-4];
      for x:=0 to Bitmap.width-5 do
        if P1[x*3]>P2[(x+4)*3] then begin
        P1[x*3]:=P2[(x+4)*3]+1;
        P1[x*3+1]:=P2[(x+4)*3+1]+1;
        P1[x*3+2]:=P2[(x+4)*3+2]+1;
        end;
    end;
  src.Assign (bitmap);
  BitMap.free;
end;

procedure ShadowDownRight(src:tbitmap);
var
  x,y : integer;
  BitMap : TBitMap;
  P1,P2 : PByteArray;
begin
  BitMap := TBitMap.create;
  bitmap.width:=src.width;
  bitmap.height:=src.height;
  Bitmap.pixelformat:=pf24bit;
  Bitmap.canvas.draw(0,0,src);
    for y := bitmap.height -1 downto 4 do begin
      P1 := BitMap.ScanLine[y];
      P2 := BitMap.scanline[y-4];
      for x:=Bitmap.width-1 downto 4 do
        if P1[x*3]>P2[(x-4)*3] then begin
         P1[x*3]:=P2[(x-4)*3]+1;
         P1[x*3+1]:=P2[(x-4)*3+1]+1;
         P1[x*3+2]:=P2[(x-4)*3+2]+1;
        end;
    end;
  src.Assign (bitmap);
  BitMap.free;
end;


procedure semiOpaque(src,dst:Tbitmap);
var b:tbitmap;
    P:Pbytearray;
    x,y:integer;
begin
  b:=tbitmap.create;
  b.width:=src.width;
  b.height:=src.height;
  b.PixelFormat :=pf24bit;
  b.canvas.draw(0,0,src);
  for y:=0 to b.height-1 do begin
    p:=b.scanline[y];
    if (y mod 2)=0 then begin
    for x:=0 to b.width-1 do
      if (x mod 2)=0 then begin
        p[x*3]:=$FF;
        p[x*3+1]:=$FF;
        p[x*3+2]:=$FF;
        end;
      end
    else begin
    for x:=0 to b.width-1 do
      if ((x+1) mod 2)=0 then begin
        p[x*3]:=$FF;
        p[x*3+1]:=$FF;
        p[x*3+2]:=$FF;
        end;
      end;
     end;
b.transparent:=true;
b.transparentcolor:=clwhite;
dst.canvas.draw(0,0,b);
b.free;

end;

procedure QuartoOpaque(src,dst:tbitmap);
var b:tbitmap;
    P:Pbytearray;
    x,y:integer;
begin
  b:=tbitmap.create;
  b.width:=src.width;
  b.height:=src.height;
  b.PixelFormat :=pf24bit;
  b.canvas.draw(0,0,src);
  for y:=0 to b.height-1 do begin
    p:=b.scanline[y];
    if (y mod 2)=0 then begin
    for x:=0 to b.width-1 do
      if (x mod 2)=0 then begin
        p[x*3]:=$FF;
        p[x*3+1]:=$FF;
        p[x*3+2]:=$FF;
        end;
      end
    else begin
    for x:=0 to b.width-1 do begin
        p[x*3]:=$FF;
        p[x*3+1]:=$FF;
        p[x*3+2]:=$FF;
        end;

      end;
     end;
b.transparent:=true;
b.transparentcolor:=clwhite;
dst.canvas.draw(0,0,b);
b.free;
end;



procedure FoldRight(src1,src2,dst: Tbitmap; amount: extended);
var
   w,h,x,y,xf,xf0:integer;
   ps1,ps2,pd:pbytearray;
begin
 src1.PixelFormat :=pf24bit;
 src2.PixelFormat :=pf24bit; 
 w:=src1.width;
 h:=src2.height;
 dst.width:=w;
 dst.height:=h;
 dst.PixelFormat :=pf24bit;
 xf:=round(amount*w);
 for y:=0 to h-1 do begin
  ps1:=src1.ScanLine [y];
  ps2:=src2.scanline[y];
  pd:=dst.scanline[y];
  for x:=0 to xf do begin
    xf0:=xf+(xf-x);
    if xf0<w then begin
      pd[xf0*3]:=ps1[x*3];
      pd[xf0*3+1]:=ps1[x*3+1];
      pd[xf0*3+2]:=ps1[x*3+2];
      pd[x*3]:=ps2[x*3];
      pd[x*3+1]:=ps2[x*3+1];
      pd[x*3+2]:=ps2[x*3+2];
      end;
    end;
  if (2*xf)<w-1 then
   for x:=2*xf+1 to w-1 do begin
      pd[x*3]:=ps1[x*3];
      pd[x*3+1]:=ps1[x*3+1];
      pd[x*3+2]:=ps1[x*3+2];
    end;
  end;
end;

procedure MandelBrot(src: Tbitmap; factor: integer);
const maxX=1.25;
      minX=-2;
      maxY=1.25;
      minY=-1.25;
var
   w,h,x,y,facx,facy:integer;
   Sa,Sbi,dx,dy:extended;
   p0:pbytearray;
   color:integer;
   xlo,xhi,ylo,yhi:extended;

FUNCTION IsMandel(CA,CBi:extended):integer;
const MAX_ITERATION=64;

VAR
  OLD_A		:extended;	  {just a variable to keep 'a' from being destroyed}
  A,B		:extended;	  {function Z divided in real and imaginary parts}
  LENGTH_Z	:extended;	  {length of Z, sqrt(length_z)>2 => Z->infinity}
  iteration     :integer;
BEGIN
  A:=0;			  {initialize Z(0) = 0}
  B:=0;

  ITERATION:=0;		  {initialize iteration}

  REPEAT
    OLD_A:=A;		  {saves the 'a'  (Will be destroyed in next line}

    A:= A*A - B*B + CA;
    B:= 2*OLD_A*B + CBi;
    ITERATION := ITERATION + 1;
    LENGTH_Z:= A*A + B*B;
  UNTIL (LENGTH_Z >= 4) OR (ITERATION > MAX_ITERATION);
 result:=iteration;
END;


begin
 w:=src.width;
 h:=src.height;
 src.pixelformat:=pf24bit;
 dx := (MaxX-MinX)/w;
 dy := (Maxy-MinY)/h;
 for y:=0 to h-1 do begin
   p0:=src.ScanLine [y];
   for x:=0 to w-1 do begin
     color:= IsMandel(MinX+x*dx, MinY+y*dy);
     if color>factor then color:=$FF
     else color:=$00;
     p0[x*3]:=color;
     p0[x*3+1]:=color;
     p0[x*3+2]:=color;
     end;
   end;
end;

procedure MaskMandelBrot(src: Tbitmap; factor: integer);
var
   bm:Tbitmap;
begin
   bm:=tbitmap.create;
   bm.width:=src.width;
   bm.height:=src.height;
   MandelBrot(bm,factor);
   bm.transparent:=true;
   bm.transparentcolor:=clwhite;
   src.canvas.draw(0,0,bm);
   bm.free;
end;


procedure KeepBlue(src: Tbitmap; factor: extended);
var x,y,w,h:integer;
    p0:pbytearray;
begin
  src.PixelFormat :=pf24bit;
  w:=src.width;
  h:=src.height;
  for y:=0 to h-1 do begin
    p0:=src.scanline[y];
   for x:=0 to w-1 do begin
    p0[x*3]:=round(factor*p0[x*3]);
    p0[x*3+1]:=0;
    p0[x*3+2]:=0;
    end;
   end;
end;

procedure KeepGreen(src: Tbitmap; factor: extended);
var x,y,w,h:integer;
    p0:pbytearray;
begin
  src.PixelFormat :=pf24bit;
  w:=src.width;
  h:=src.height;
  for y:=0 to h-1 do begin
    p0:=src.scanline[y];
   for x:=0 to w-1 do begin
    p0[x*3+1]:=round(factor*p0[x*3+1]);
    p0[x*3]:=0;
    p0[x*3+2]:=0;
    end;
   end;
end;

procedure KeepRed(src: Tbitmap; factor: extended);
var x,y,w,h:integer;
    p0:pbytearray;
begin
  src.PixelFormat :=pf24bit;
  w:=src.width;
  h:=src.height;
  for y:=0 to h-1 do begin
    p0:=src.scanline[y];
   for x:=0 to w-1 do begin
    p0[x*3+2]:=round(factor*p0[x*3+2]);
    p0[x*3+1]:=0;
    p0[x*3]:=0;
    end;
   end;
end;

procedure Shake(src,dst: Tbitmap;factor:extended);
var x,y,h,w,dx:integer;
    p:pbytearray;
begin
 dst.canvas.draw(0,0,src);
 dst.pixelformat:=pf24bit;
 w:=dst.Width ;
 h:=dst.height;
 dx:=round(factor*w);
 if dx=0 then exit;
 if dx>(w div 2) then exit;

 for y:=0 to h-1 do begin
   p:=dst.scanline[y];
   if (y mod 2)=0 then
   for x:=dx to w-1 do begin
     p[(x-dx)*3]:=p[x*3];
     p[(x-dx)*3+1]:=p[x*3+1];
     p[(x-dx)*3+2]:=p[x*3+2];
     end
   else
   for x:=w-1 downto dx do begin
     p[x*3]:=p[(x-dx)*3];
     p[x*3+1]:=p[(x-dx)*3+1];
     p[x*3+2]:=p[(x-dx)*3+2];
     end;
   end;

end;


procedure ShakeDown(src, dst: Tbitmap; factor: extended);
var x,y,h,w,dy:integer;
    p,p2,p3:pbytearray;
begin
 dst.canvas.draw(0,0,src);
 dst.pixelformat:=pf24bit;
 w:=dst.Width ;
 h:=dst.height;
 dy:=round(factor*h);
 if dy=0 then exit;
 if dy>(h div 2) then exit;

 for y:=dy to h-1 do begin
   p:=dst.scanline[y];
   p2:=dst.scanline[y-dy];
   for x:=0 to w-1 do
     if (x mod 2)=0 then
     begin
     p2[x*3]:=p[x*3];
     p2[x*3+1]:=p[x*3+1];
     p2[x*3+2]:=p[x*3+2];
     end;
   end;
 for y:=h-1-dy downto 0 do begin
   p:=dst.scanline[y];
   p3:=dst.scanline[y+dy];
   for x:=0 to w-1 do
     if (x mod 2)<>0 then
     begin
     p3[x*3]:=p[x*3];
     p3[x*3+1]:=p[x*3+1];
     p3[x*3+2]:=p[x*3+2];
     end;
   end;
end;

procedure Plasma(src1, src2, dst: Tbitmap; scale,turbulence: extended);
var
   cval,sval:array[0..255] of integer;
   i,x,y,w,h,xx,yy:integer;
   Asin,Acos:extended;
   ps1,ps2,pd:pbytearray;
begin
   w:=src1.width;
   h:=src1.height;
   if turbulence<10 then turbulence:=10;
   if scale<5 then scale:=5;
   for i:=0 to 255 do begin
     sincos(i/turbulence,Asin,Acos);
     sval[i]:=round(-scale*Asin);
     cval[i]:=round(scale*Acos);
     end;
   for y:=0 to h-1 do begin
      pd:=dst.scanline[y];
      ps2:=src2.scanline[y];
     for x:=0 to w-1 do begin
      xx:=x+sval[ps2[x*3]];
      yy:=y+cval[ps2[x*3]];
      if (xx>=0)and(xx<w)and (yy>=0)and(yy<h) then begin
        ps1:=src1.scanline[yy];
        pd[x*3]:=ps1[xx*3];
        pd[x*3+1]:=ps1[xx*3+1];
        pd[x*3+2]:=ps1[xx*3+2];
        end;
      end;
     end;;
end;

procedure splitround(src,dst:tbitmap;amount:integer;style:TLightBrush);
var x,y,h,w,c,c00,dx,cx:integer;
    R,R00:trect;
    bm,bm2:tbitmap;
    p0,p00,p1:pbytearray;
begin
if amount=0 then begin
  dst.canvas.Draw (0,0,src);
  exit;
  end;
cx:=src.width div 2;
if amount>cx then
  amount:=cx;
w:=src.width;
bm:=tbitmap.create;
bm.PixelFormat :=pf24bit;
bm.height:=1;
bm.width:=cx;
bm2:=tbitmap.create;
bm2.PixelFormat :=pf24bit;
bm2.height:=1;
bm2.width:=cx;
p0:=bm.scanline[0];
p00:=bm2.scanline[0];
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to cx-1 do begin
      c:=x*3;
      c00:=(cx+x)*3;
      p0[c]:=p1[c];
      p0[c+1]:=p1[c+1];
      p0[c+2]:=p1[c+2];
      p00[c]:=p1[c00];
      p00[c+1]:=p1[c00+1];
      p00[c+2]:=p1[c00+2];
      end;
    case style of
    mbsplitround: dx:=round(amount*abs(sin(y/(src.height-1)*pi)));
    mbsplitwaste: dx:=round(amount*abs(cos(y/(src.height-1)*pi)));
    end;
    R:=rect(0,y,dx,y+1);
    dst.Canvas.StretchDraw (R,bm);
    R00:=rect(w-1-dx,y,w-1,y+1);
    dst.Canvas.StretchDraw (R00,bm2);
    end;
bm.free;
bm2.free;
end;

procedure Emboss(var Bmp:TBitmap);
var
x,y:   Integer;
p1,p2: Pbytearray;
begin
  for y:=0 to Bmp.Height-2 do
  begin
    p1:=bmp.scanline[y];
    p2:=bmp.scanline[y+1];
    for x:=0 to Bmp.Width-4 do
    begin
      p1[x*3]:=(p1[x*3]+(p2[(x+3)*3] xor $FF))shr 1;
      p1[x*3+1]:=(p1[x*3+1]+(p2[(x+3)*3+1] xor $FF))shr 1;
      p1[x*3+2]:=(p1[x*3+2]+(p2[(x+3)*3+2] xor $FF))shr 1;
    end;
  end;

end;

procedure filterred(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c+2]>min) and (p1[c+2]<max) then p1[c+2]:=$FF
        else p1[c+2]:=0;
      p1[c]:=0;
      p1[c+1]:=0;
      end;
    end;
end;

procedure filtergreen(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c+1]>min) and (p1[c+1]<max) then p1[c+1]:=$FF
        else p1[c+1]:=0;
      p1[c]:=0;
      p1[c+2]:=0;
      end;
    end;
end;

procedure filterblue(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c]>min) and (p1[c]<max) then p1[c]:=$FF
        else p1[c]:=0;
      p1[c+1]:=0;
      p1[c+2]:=0;
      end;
    end;
end;

procedure filterxred(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c+2]>min) and (p1[c+2]<max) then p1[c+2]:=$FF
        else p1[c+2]:=0;
      end;
    end;
end;

procedure filterxgreen(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c+1]>min) and (p1[c+1]<max) then p1[c+1]:=$FF
        else p1[c+1]:=0;
      end;
    end;
end;

procedure filterxblue(src:tbitmap;min,max:integer);
var c,x,y:integer;
    p1:pbytearray;

begin
  for y:=0 to src.height-1 do begin
    p1:=src.scanline[y];
    for x:=0 to src.width-1 do begin
      c:=x*3;
      if (p1[c]>min) and (p1[c]<max) then p1[c]:=$FF
        else p1[c]:=0;
      end;
    end;
end;


//Just a small function to map the numbers to colors
function ConvertColor(Value:Integer):TColor;
begin
  case Value of
    0:Result := clBlack;
    1:Result := clNavy;
    2:Result := clGreen;
    3:Result := clAqua;
    4:Result := clRed;
    5:Result := clPurple;
    6:Result := clMaroon;
    7:Result := clSilver;
    8:Result := clGray;
    9:Result := clBlue;
    10:Result := clLime;
    11:Result := clOlive;
    12:Result := clFuchsia;
    13:Result := clTeal;
    14:Result := clYellow;
    15:Result := clWhite;
    else Result := clWhite;
  end;
end;


procedure DrawMandelJulia(src:Tbitmap;x0,y0,x1,y1:extended;Niter:integer;Mandel:Boolean);
const
  //Number if colors. If this is changed, the number of mapped colors must also be changed
  nc=16;
type
  TjvRGBTriplet= record
    r,g,b:byte
    end;
var
  X,XX,Y,YY,Cx,Cy,Dx,Dy,XSquared,YSquared:Double;
  Nx,Ny,Py,Px,I:Integer;
  p0:pbytearray;
  cc: array[0..15] of TjvRGBTriplet;
  Acolor:Tcolor;
begin
  src.PixelFormat :=pf24bit;
  for i:=0 to 15 do begin
    Acolor:=convertcolor(i);
    cc[i].b:=GetBValue(colortoRGB(Acolor));
    cc[i].g:=GetGValue(colortoRGB(Acolor));
    cc[i].r:=GetRValue(colortoRGB(Acolor));
    end;
  if Niter<nc then Niter:=nc;
  try
    Nx := src.Width;
    Ny := src.Height;
    Cx := 0;
    Cy := 1;
    Dx := (x1 - x0) / nx;
    Dy := (y1 - y0) / ny;
    Py := 0;
    while (PY < Ny) do begin
      p0:=src.scanline[py];
      PX := 0;
      while (Px < Nx)do begin
        x := x0 + px * dx;
        y := y0 + py * dy;
        if (mandel) then begin
          cx := x;cy := y;
          x := 0; y := 0;
        end;
        xsquared := 0;ysquared := 0;
        I := 0;
        while (I <= niter) and (xsquared + ysquared < (4)) do begin
          xsquared := x*x;
          ysquared := y*y;
          xx := xsquared - ysquared + cx;
          yy := (2*x*y) + cy;
          x := xx ; y := yy;
          I := I + 1;
        end;
        I := I - 1;
        if (i = niter) then i := 0
        else i := round(i / (niter / nc));
//        Canvas.Pixels[PX,PY] := ConvertColor(I);
        p0[px*3]:=cc[i].b;
        p0[px*3+1]:=cc[i].g;
        p0[px*3+2]:=cc[i].r;
        Px := Px + 1;
      end;
      Py := Py + 1;
    end;
  finally
  end;
end;


procedure Invert(src: tbitmap);
var w,h,x,y:integer;
    p:pbytearray;
begin
w:=src.width;
h:=src.height;
src.PixelFormat :=pf24bit;
 for y:=0 to h-1 do begin
  p:=src.scanline[y];
  for x:=0 to w-1 do begin
   p[x*3]:= not p[x*3];
   p[x*3+1]:= not p[x*3+1];
   p[x*3+2]:= not p[x*3+2];
   end;
  end;
end;

procedure MirrorRight(src: Tbitmap);
var w,h,x,y:integer;
    p:pbytearray;
begin
w:=src.width;
h:=src.height;
src.PixelFormat :=pf24bit;
 for y:=0 to h-1 do begin
  p:=src.scanline[y];
  for x:=0 to w div 2 do begin
   p[(w-1-x)*3]:= p[x*3];
   p[(w-1-x)*3+1]:= p[x*3+1];
   p[(w-1-x)*3+2]:= p[x*3+2];
   end;
  end;
end;

procedure MirrorDown(src: Tbitmap);
var w,h,x,y:integer;
    p1,p2:pbytearray;
begin
w:=src.width;
h:=src.height;
src.PixelFormat :=pf24bit;
 for y:=0 to h div 2 do begin
  p1:=src.scanline[y];
  p2:=src.scanline[h-1-y];
  for x:=0 to w-1  do begin
   p2[x*3]:= p1[x*3];
   p2[x*3+1]:= p1[x*3+1];
   p2[x*3+2]:= p1[x*3+2];
   end;
  end;
end;

// resample image as triangles
procedure Triangles(src: TBitmap; amount: integer);
type
  Ttriplet=record
    r,g,b:byte;
    end;

var w,h,x,y,tb,tm,te:integer;
    ps:pbytearray;
    T:ttriplet;
begin
 w:=src.width;
 h:=src.height;
 src.PixelFormat :=pf24bit;
 if amount<5 then amount:=5;
 amount:= (amount div 2)*2+1;
 tm:=amount div 2;
 for y:=0 to h-1 do begin
  ps:=src.scanline[y];
  t.r:=ps[0];
  t.g:=ps[1];
  t.b:=ps[2];
  tb:=y mod (amount-1);
  if tb>tm then tb:=2*tm-tb;
  if tb=0 then tb:=amount;
  te:=tm+abs(tm-(y mod amount));
  for x:=0 to w-1 do begin
    if (x mod tb)=0 then begin
     t.r :=ps[x*3];
     t.g:=ps[x*3+1];
     t.b:=ps[x*3+2];
     end;
    if ((x mod te)=1)and(tb<>0) then begin
     t.r :=ps[x*3];
     t.g:=ps[x*3+1];
     t.b:=ps[x*3+2];
     end;
    ps[x*3]:=t.r;
    ps[x*3+1]:=t.g;
    ps[x*3+2]:=t.b;
    end;
  end;
end;

procedure RippleTooth(src: TBitmap; amount: integer);
var
  c,c2,x,y : integer;
  P1,P2 : PByteArray;
  b:byte;

begin
  src.PixelFormat :=pf24bit;
  amount:=min(src.height div 2, amount);
    for y := src.height -1-amount downto 0 do begin
      P1 := src.ScanLine[y];
      b:=0;
      for x:=0 to src.width-1 do begin
        P2 := src.scanline[y+b];
        P2[x*3]:=P1[x*3];
        P2[x*3+1]:=P1[x*3+1];
        P2[x*3+2]:=P1[x*3+2];
        inc(b);
        if b>amount then b:=0;
        end;
    end;
end;

procedure RippleTriangle(src: TBitmap; amount: integer);
var
  c,c2,x,y : integer;
  P1,P2 : PByteArray;
  b:byte;
  doinc:boolean;

begin
  amount:=min(src.height div 2,amount);
    for y := src.height -1-amount downto 0 do begin
      P1 := src.ScanLine[y];
      b:=0;
      doinc:=true;
      for x:=0 to src.width-1 do begin
        P2 := src.scanline[y+b];
        P2[x*3]:=P1[x*3];
        P2[x*3+1]:=P1[x*3+1];
        P2[x*3+2]:=P1[x*3+2];
        if doinc then begin
          inc(b);
          if b>amount then begin
             doinc:=false;
             b:=amount-1;
             end;
          end
          else begin
           if b=0 then begin
             doinc:=true;
             b:=2;
             end;
           dec(b);
           end;
        end;
    end;
end;

procedure RippleRandom(src: TBitmap; amount: integer);
var
  c,c2,x,y : integer;
  P1,P2 : PByteArray;
  b:byte;

begin
  amount:=min(src.height div 2,amount);
  src.PixelFormat :=pf24bit;
  randomize;
    for y := src.height -1-amount downto 0 do begin
      P1 := src.ScanLine[y];
      b:=0;
      for x:=0 to src.width-1 do begin
        P2 := src.scanline[y+b];
        P2[x*3]:=P1[x*3];
        P2[x*3+1]:=P1[x*3+1];
        P2[x*3+2]:=P1[x*3+2];
        b:=random(amount);
        end;
    end;
end;

procedure TexturizeOverlap(src: TBitmap; amount: integer);
var w,h,x,y,xo:integer;
    bm:tbitmap;
    arect:trect;
begin
bm:=tbitmap.create;
amount:=min(src.width div 2,amount);
amount:=min(src.height div 2,amount);
xo:=round(amount * 2 / 3);
bm.width:=amount;
bm.height:=amount;
w:=src.width;
h:=src.height;
arect:=rect(0,0,amount,amount);
bm.Canvas.StretchDraw (arect,src);
y:=0;
repeat
  x:=0;
  repeat
  src.canvas.Draw (x,y,bm);
  x:=x+xo;
  until x>=w;
  y:=y+xo;
until y>=h;
bm.free;
end;

procedure TexturizeTile(src: TBitmap; amount: integer);
var w,h,x,y:integer;
    bm:tbitmap;
    arect:trect;
begin
bm:=tbitmap.create;
amount:=min(src.width div 2,amount);
amount:=min(src.height div 2,amount);
bm.width:=amount;
bm.height:=amount;
w:=src.width;
h:=src.height;
arect:=rect(0,0,amount,amount);
bm.Canvas.StretchDraw (arect,src);
y:=0;
repeat
  x:=0;
  repeat
  src.canvas.Draw (x,y,bm);
  x:=x+bm.width;
  until x>=w;
  y:=y+bm.height;
until y>=h;
bm.free;
end;

procedure HeightMap(src: Tbitmap; amount: integer);
var bm:tbitmap;
    w,h,x,y:integer;
    pb,ps:pbytearray;
    c:integer;
begin
 h:=src.height;
 w:=src.width;
 bm:=tbitmap.create;
 bm.width:=w;
 bm.height:=h;
 bm.PixelFormat:=pf24bit;
 src.PixelFormat :=pf24bit;
 bm.Canvas.Draw (0,0,src);
 for y:=0 to h-1 do begin
   pb:=bm.ScanLine [y];
  for x:=0 to w-1 do begin
   c:=round((pb[x*3]+pb[x*3+1]+pb[x*3+2])/3/255*amount);
   if (y-c)>=0 then begin
     ps:=src.ScanLine [y-c];
     ps[x*3]:=pb[x*3];
     ps[x*3+1]:=pb[x*3+1];
     ps[x*3+2]:=pb[x*3+2];
     end;
   end;
  end;
bm.free;  
end;

procedure turn(src, dst: tbitmap);
var w,h,x,y:integer;
    ps,pd:pbytearray;
begin
 h:=src.Height;
 w:=src.width;
 src.PixelFormat :=pf24bit;
 dst.PixelFormat :=pf24bit;
 dst.Height :=w;
 dst.Width :=h;
 for y:=0 to h-1 do begin
  ps:=src.ScanLine [y];
  for x:=0 to w-1 do begin
   pd:=dst.ScanLine [w-1-x];
   pd[y*3]:=ps[x*3];
   pd[y*3+1]:=ps[x*3+1];
   pd[y*3+2]:=ps[x*3+2];
   end;
  end;
end;

procedure turnRight(src, dst: Tbitmap);
var w,h,x,y:integer;
    ps,pd:pbytearray;
begin
 h:=src.Height;
 w:=src.width;
 src.PixelFormat :=pf24bit;
 dst.PixelFormat :=pf24bit;
 dst.Height :=w;
 dst.Width :=h;
 for y:=0 to h-1 do begin
  ps:=src.ScanLine [y];
  for x:=0 to w-1 do begin
   pd:=dst.ScanLine [x];
   pd[(h-1-y)*3]:=ps[x*3];
   pd[(h-1-y)*3+1]:=ps[x*3+1];
   pd[(h-1-y)*3+2]:=ps[x*3+2];
   end;
  end;
end;

procedure ExtractColor(src: TBitmap; Acolor: tcolor);
var w,h,x,y:integer;
    p:pbytearray;
    Ecolor:TColor;
    r,g,b:byte;
begin
 w:=src.width;
 h:=src.height;
 Ecolor:=colortorgb(Acolor);
 r:=getRValue(Ecolor);
 g:=getGValue(Ecolor);
 b:=getBValue(Ecolor);
 src.PixelFormat :=pf24bit;
 for y:=0 to h-1 do begin
  p:=src.ScanLine [y];
  for x:=0 to w-1 do begin
   if ((p[x*3]<>b) or (p[x*3+1]<>g) or (p[x*3+2]<>r)) then begin
    p[x*3]:=$00;
    p[x*3+1]:=$00;
    p[x*3+2]:=$00;
    end;
   end
  end;
 src.transparent:=true;
 src.TransparentColor :=clblack;
end;

procedure ExcludeColor(src: TBitmap; Acolor: tcolor);
var w,h,x,y:integer;
    p:pbytearray;
    Ecolor:TColor;
    r,g,b:byte;
begin
 w:=src.width;
 h:=src.height;
 Ecolor:=colortorgb(Acolor);
 r:=getRValue(Ecolor);
 g:=getGValue(Ecolor);
 b:=getBValue(Ecolor);
 src.PixelFormat :=pf24bit;
 for y:=0 to h-1 do begin
  p:=src.ScanLine [y];
  for x:=0 to w-1 do begin
   if ((p[x*3]=b) and (p[x*3+1]=g) and (p[x*3+2]=r)) then begin
    p[x*3]:=$00;
    p[x*3+1]:=$00;
    p[x*3+2]:=$00;
    end;
   end
  end;
 src.transparent:=true;
 src.TransparentColor :=clblack;
end;

procedure Blend(src1, src2, dst: tbitmap; amount: extended);
var w,h,x,y:integer;
    ps1,ps2,pd:pbytearray;
begin
w:=src1.Width ;
h:=src1.Height;
dst.Width :=w;
dst.Height :=h;
src1.PixelFormat :=pf24bit;
src2.PixelFormat:=pf24bit;
dst.PixelFormat :=pf24bit;
for y:=0 to h-1 do begin
 ps1:=src1.ScanLine [y];
 ps2:=src2.ScanLine [y];
 pd:=dst.ScanLine [y];
 for x:=0 to w-1 do begin
  pd[x*3]:=round((1-amount)*ps1[x*3]+amount*ps2[x*3]);
  pd[x*3+1]:=round((1-amount)*ps1[x*3+1]+amount*ps2[x*3+1]);
  pd[x*3+2]:=round((1-amount)*ps1[x*3+2]+amount*ps2[x*3+2]);
  end;
 end;
end;

procedure Solorize(src, dst: tbitmap; amount: integer);
var w,h,x,y:integer;
    ps,pd:pbytearray;
    c:integer;
begin
  w:=src.width;
  h:=src.height;
  src.PixelFormat :=pf24bit;
  dst.PixelFormat :=pf24bit;
  for y:=0 to h-1 do begin
   ps:=src.scanline[y];
   pd:=dst.scanline[y];
   for x:=0 to w-1 do begin
    c:=(ps[x*3]+ps[x*3+1]+ps[x*3+2]) div 3;
    if c>amount then begin
     pd[x*3]:= 255-ps[x*3];
     pd[x*3+1]:=255-ps[x*3+1];
     pd[x*3+2]:=255-ps[x*3+2];
     end
     else begin
     pd[x*3]:=ps[x*3];
     pd[x*3+1]:=ps[x*3+1];
     pd[x*3+2]:=ps[x*3+2];
     end;
    end;
   end;
end;

procedure Posterize(src, dst: tbitmap; amount: integer);
var w,h,x,y:integer;
    ps,pd:pbytearray;
    c:integer;
begin
  w:=src.width;
  h:=src.height;
  src.PixelFormat :=pf24bit;
  dst.PixelFormat :=pf24bit;
  for y:=0 to h-1 do begin
   ps:=src.scanline[y];
   pd:=dst.scanline[y];
   for x:=0 to w-1 do begin
     pd[x*3]:= round(ps[x*3]/amount)*amount;
     pd[x*3+1]:=round(ps[x*3+1]/amount)*amount;
     pd[x*3+2]:=round(ps[x*3+2]/amount)*amount;
    end;
   end;
end;

{This just forces a value to be 0 - 255 for rgb purposes.  I used asm in an
 attempt at speed, but I don't think it helps much.}
function Set255(Clr : integer) : integer;
asm
  MOV  EAX,Clr  // store value in EAX register (32-bit register)
  CMP  EAX,254  // compare it to 254
  JG   @SETHI   // if greater than 254 then go set to 255 (max value)
  CMP  EAX,1    // if less than 255, compare to 1
  JL   @SETLO   // if less than 1 go set to 0 (min value)
  RET           // otherwise it doesn't change, just exit
@SETHI:         // Set value to 255
  MOV  EAX,255  // Move 255 into the EAX register
  RET           // Exit (result value is the EAX register value)
@SETLO:         // Set value to 0
  MOV  EAX,0    // Move 0 into EAX register
end;            // Result is in EAX

{The Expand version of a 3 x 3 convolution.

 This approach is similar to the mirror version, except that it copies
 or duplicates the pixels from the edges to the same edge.  This is
 probably the best version if you're interested in quality, but don't need
 a tiled (seamless) image. }
procedure ConvolveE(ray: array of integer; z: word;
  aBmp: TBitmap);
var
  O, T, C, B : pRGBArray;  // Scanlines
  x, y : integer;
  tBufr : TBitmap; // temp bitmap for 'enlarged' image
begin
  tBufr := TBitmap.Create;
  tBufr.Width:=aBmp.Width+2;  // Add a box around the outside...
  tBufr.Height:=aBmp.Height+2;
  tBufr.PixelFormat := pf24bit;
  O := tBufr.ScanLine[0];   // Copy top corner pixels
  T := aBmp.ScanLine[0];
  O[0] := T[0];  // Left
  O[tBufr.Width - 1] := T[aBmp.Width - 1];  // Right
  // Copy top lines
  tBufr.Canvas.CopyRect(RECT(1,0,tBufr.Width - 1,1),aBmp.Canvas,
          RECT(0,0,aBmp.Width,1));

  O := tBufr.ScanLine[tBufr.Height - 1]; // Copy bottom corner pixels
  T := aBmp.ScanLine[aBmp.Height - 1];
  O[0] := T[0];
  O[tBufr.Width - 1] := T[aBmp.Width - 1];
  // Copy bottoms
  tBufr.Canvas.CopyRect(RECT(1,tBufr.Height-1,tBufr.Width - 1,tBufr.Height),
         aBmp.Canvas,RECT(0,aBmp.Height-1,aBmp.Width,aBmp.Height));
  // Copy rights
  tBufr.Canvas.CopyRect(RECT(tBufr.Width-1,1,tBufr.Width,tBufr.Height-1),
         aBmp.Canvas,RECT(aBmp.Width-1,0,aBmp.Width,aBmp.Height));
  // Copy lefts
  tBufr.Canvas.CopyRect(RECT(0,1,1,tBufr.Height-1),
         aBmp.Canvas,RECT(0,0,1,aBmp.Height));
  // Now copy main rectangle
  tBufr.Canvas.CopyRect(RECT(1,1,tBufr.Width - 1,tBufr.Height - 1),
    aBmp.Canvas,RECT(0,0,aBmp.Width,aBmp.Height));
  // bmp now enlarged and copied, apply convolve
  for x := 0 to aBmp.Height - 1 do begin  // Walk scanlines
    O := aBmp.ScanLine[x];      // New Target (Original)
    T := tBufr.ScanLine[x];     //old x-1  (Top)
    C := tBufr.ScanLine[x+1];   //old x    (Center)
    B := tBufr.ScanLine[x+2];   //old x+1  (Bottom)
  // Now do the main piece
    for y := 1 to (tBufr.Width - 2) do begin  // Walk pixels
      O[y-1].rgbtRed := Set255(
          ((T[y-1].rgbtRed*ray[0]) +
          (T[y].rgbtRed*ray[1]) + (T[y+1].rgbtRed*ray[2]) +
          (C[y-1].rgbtRed*ray[3]) +
          (C[y].rgbtRed*ray[4]) + (C[y+1].rgbtRed*ray[5])+
          (B[y-1].rgbtRed*ray[6]) +
          (B[y].rgbtRed*ray[7]) + (B[y+1].rgbtRed*ray[8])) div z
          );
      O[y-1].rgbtBlue := Set255(
          ((T[y-1].rgbtBlue*ray[0]) +
          (T[y].rgbtBlue*ray[1]) + (T[y+1].rgbtBlue*ray[2]) +
          (C[y-1].rgbtBlue*ray[3]) +
          (C[y].rgbtBlue*ray[4]) + (C[y+1].rgbtBlue*ray[5])+
          (B[y-1].rgbtBlue*ray[6]) +
          (B[y].rgbtBlue*ray[7]) + (B[y+1].rgbtBlue*ray[8])) div z
          );
      O[y-1].rgbtGreen := Set255(
          ((T[y-1].rgbtGreen*ray[0]) +
          (T[y].rgbtGreen*ray[1]) + (T[y+1].rgbtGreen*ray[2]) +
          (C[y-1].rgbtGreen*ray[3]) +
          (C[y].rgbtGreen*ray[4]) + (C[y+1].rgbtGreen*ray[5])+
          (B[y-1].rgbtGreen*ray[6]) +
          (B[y].rgbtGreen*ray[7]) + (B[y+1].rgbtGreen*ray[8])) div z
          );
    end;
  end;
  tBufr.Free;
end;

{The Ignore (basic) version of a 3 x 3 convolution.

 The 3 x 3 convolve uses the eight surrounding pixels as part of the
 calculation.  But, for the pixels on the edges, there is nothing to use
 for the top row values.  In other words, the leftmost pixel in the 3rd
 row, or scanline, has no pixels on its left to use in the calculations.
 This version just ignores the outermost edge of the image, and doesn't
 alter those pixels at all.  Repeated applications of filters will
 eventually cause a pronounced 'border' effect, as those pixels never
 change but all others do. However, this version is simpler, and the
 logic is easier to follow.  It's the fastest of the three in this
 application, and works great if the 'borders' are not an issue. }
procedure ConvolveI(ray: array of integer; z: word;
  aBmp: TBitmap);
var
  O, T, C, B : pRGBArray;  // Scanlines
  x, y : integer;
  tBufr : TBitmap; // temp bitmap
begin
  tBufr := TBitmap.Create;
  CopyMe(tBufr,aBmp);
  for x := 1 to aBmp.Height - 2 do begin  // Walk scanlines
    O := aBmp.ScanLine[x];      // New Target (Original)
    T := tBufr.ScanLine[x-1];     //old x-1  (Top)
    C := tBufr.ScanLine[x];   //old x    (Center)
    B := tBufr.ScanLine[x+1];   //old x+1  (Bottom)
  // Now do the main piece
    for y := 1 to (tBufr.Width - 2) do begin  // Walk pixels
      O[y].rgbtRed := Set255(
          ((T[y-1].rgbtRed*ray[0]) +
          (T[y].rgbtRed*ray[1]) + (T[y+1].rgbtRed*ray[2]) +
          (C[y-1].rgbtRed*ray[3]) +
          (C[y].rgbtRed*ray[4]) + (C[y+1].rgbtRed*ray[5])+
          (B[y-1].rgbtRed*ray[6]) +
          (B[y].rgbtRed*ray[7]) + (B[y+1].rgbtRed*ray[8])) div z
          );
      O[y].rgbtBlue := Set255(
          ((T[y-1].rgbtBlue*ray[0]) +
          (T[y].rgbtBlue*ray[1]) + (T[y+1].rgbtBlue*ray[2]) +
          (C[y-1].rgbtBlue*ray[3]) +
          (C[y].rgbtBlue*ray[4]) + (C[y+1].rgbtBlue*ray[5])+
          (B[y-1].rgbtBlue*ray[6]) +
          (B[y].rgbtBlue*ray[7]) + (B[y+1].rgbtBlue*ray[8])) div z
          );
      O[y].rgbtGreen := Set255(
          ((T[y-1].rgbtGreen*ray[0]) +
          (T[y].rgbtGreen*ray[1]) + (T[y+1].rgbtGreen*ray[2]) +
          (C[y-1].rgbtGreen*ray[3]) +
          (C[y].rgbtGreen*ray[4]) + (C[y+1].rgbtGreen*ray[5])+
          (B[y-1].rgbtGreen*ray[6]) +
          (B[y].rgbtGreen*ray[7]) + (B[y+1].rgbtGreen*ray[8])) div z
          );
    end;
  end;
  tBufr.Free;
end;

{The mirror version of a 3 x 3 convolution.

 The 3 x 3 convolve uses the eight surrounding pixels as part of the
 calculation.  But, for the pixels on the edges, there is nothing to use
 for the top row values.  In other words, the leftmost pixel in the 3rd
 row, or scanline, has no pixels on its left to use in the calculations.
 I compensate for this by increasing the size of the bitmap by one pixel
 on top, left, bottom, and right.  The mirror version is used in an
 application that creates seamless tiles, so I copy the opposite sides to
 maintain the seamless integrity.  }
procedure ConvolveM(ray: array of integer; z: word;
  aBmp: TBitmap);
var
  O, T, C, B : pRGBArray;  // Scanlines
  x, y : integer;
  tBufr : TBitmap; // temp bitmap for 'enlarged' image
begin
  tBufr := TBitmap.Create;
  tBufr.Width:=aBmp.Width+2;  // Add a box around the outside...
  tBufr.Height:=aBmp.Height+2;
  tBufr.PixelFormat := pf24bit;
  O := tBufr.ScanLine[0];   // Copy top corner pixels
  T := aBmp.ScanLine[0];
  O[0] := T[0];  // Left
  O[tBufr.Width - 1] := T[aBmp.Width - 1];  // Right
  // Copy bottom line to our top - trying to remain seamless...
  tBufr.Canvas.CopyRect(RECT(1,0,tBufr.Width - 1,1),aBmp.Canvas,
          RECT(0,aBmp.Height - 1,aBmp.Width,aBmp.Height-2));

  O := tBufr.ScanLine[tBufr.Height - 1]; // Copy bottom corner pixels
  T := aBmp.ScanLine[aBmp.Height - 1];
  O[0] := T[0];
  O[tBufr.Width - 1] := T[aBmp.Width - 1];
  // Copy top line to our bottom
  tBufr.Canvas.CopyRect(RECT(1,tBufr.Height-1,tBufr.Width - 1,tBufr.Height),
         aBmp.Canvas,RECT(0,0,aBmp.Width,1));
  // Copy left to our right
  tBufr.Canvas.CopyRect(RECT(tBufr.Width-1,1,tBufr.Width,tBufr.Height-1),
         aBmp.Canvas,RECT(0,0,1,aBmp.Height));
  // Copy right to our left
  tBufr.Canvas.CopyRect(RECT(0,1,1,tBufr.Height-1),
         aBmp.Canvas,RECT(aBmp.Width - 1,0,aBmp.Width,aBmp.Height));
  // Now copy main rectangle
  tBufr.Canvas.CopyRect(RECT(1,1,tBufr.Width - 1,tBufr.Height - 1),
    aBmp.Canvas,RECT(0,0,aBmp.Width,aBmp.Height));
  // bmp now enlarged and copied, apply convolve
  for x := 0 to aBmp.Height - 1 do begin  // Walk scanlines
    O := aBmp.ScanLine[x];      // New Target (Original)
    T := tBufr.ScanLine[x];     //old x-1  (Top)
    C := tBufr.ScanLine[x+1];   //old x    (Center)
    B := tBufr.ScanLine[x+2];   //old x+1  (Bottom)
  // Now do the main piece
    for y := 1 to (tBufr.Width - 2) do begin  // Walk pixels
      O[y-1].rgbtRed := Set255(
          ((T[y-1].rgbtRed*ray[0]) +
          (T[y].rgbtRed*ray[1]) + (T[y+1].rgbtRed*ray[2]) +
          (C[y-1].rgbtRed*ray[3]) +
          (C[y].rgbtRed*ray[4]) + (C[y+1].rgbtRed*ray[5])+
          (B[y-1].rgbtRed*ray[6]) +
          (B[y].rgbtRed*ray[7]) + (B[y+1].rgbtRed*ray[8])) div z
          );
      O[y-1].rgbtBlue := Set255(
          ((T[y-1].rgbtBlue*ray[0]) +
          (T[y].rgbtBlue*ray[1]) + (T[y+1].rgbtBlue*ray[2]) +
          (C[y-1].rgbtBlue*ray[3]) +
          (C[y].rgbtBlue*ray[4]) + (C[y+1].rgbtBlue*ray[5])+
          (B[y-1].rgbtBlue*ray[6]) +
          (B[y].rgbtBlue*ray[7]) + (B[y+1].rgbtBlue*ray[8])) div z
          );
      O[y-1].rgbtGreen := Set255(
          ((T[y-1].rgbtGreen*ray[0]) +
          (T[y].rgbtGreen*ray[1]) + (T[y+1].rgbtGreen*ray[2]) +
          (C[y-1].rgbtGreen*ray[3]) +
          (C[y].rgbtGreen*ray[4]) + (C[y+1].rgbtGreen*ray[5])+
          (B[y-1].rgbtGreen*ray[6]) +
          (B[y].rgbtGreen*ray[7]) + (B[y+1].rgbtGreen*ray[8])) div z
          );
    end;
  end;
  tBufr.Free;
end;

procedure Seamless(src: TBitmap;depth:byte);
var
  p1,p2:pbytearray;
  w,w3,h,i,x,x3,y:integer;
  am,amount:extended;
begin
  w:=src.width;
  h:=src.height;
  src.PixelFormat:=pf24bit;
  if depth=0 then exit;
  am:=1/depth;
  for y:=0 to depth do
  begin
    p1:=src.ScanLine[y];
    p2:=src.ScanLine[h-y-1];
    amount:=1-y*am;
    for x:=y to w-1-y do
    begin
      x3:=x*3;
      p2[x3]:=round((1-amount)*p2[x3]+amount*p1[x3]);
      p2[x3+1]:=round((1-amount)*p2[x3+1]+amount*p1[x3+1]);
      p2[x3+2]:=round((1-amount)*p2[x3+2]+amount*p1[x3+2]);
    end;
    for x:=0 to y do
    begin
      amount:=1-x*am;
      x3:=x*3;
      w3:=(w-1-x)*3;
      p1[w3]:=round((1-amount)*p1[w3]+amount*p1[x3]);
      p1[w3+1]:=round((1-amount)*p1[w3+1]+amount*p1[x3+1]);
      p1[w3+2]:=round((1-amount)*p1[w3+2]+amount*p1[x3+2]);
      p2[w3]:=round((1-amount)*p2[w3]+amount*p2[x3]);
      p2[w3+1]:=round((1-amount)*p2[w3+1]+amount*p2[x3+1]);
      p2[w3+2]:=round((1-amount)*p2[w3+2]+amount*p2[x3+2]);
    end;
  end;
  for y:=depth to h-1-depth do
  begin
    p1:=src.ScanLine[y];
    for x:=0 to depth do
    begin
      x3:=x*3;
      w3:=(w-1-x)*3;
      amount:=1-x*am;
      p1[w3]:=round((1-amount)*p1[w3]+amount*p1[x3]);
      p1[w3+1]:=round((1-amount)*p1[w3+1]+amount*p1[x3+1]);
      p1[w3+2]:=round((1-amount)*p1[w3+2]+amount*p1[x3+2]);
    end;
  end;
end;

procedure Buttonize(src: TBitmap;depth:byte;weight:integer);
var
  p1,p2:pbytearray;
  w,w3,h,i,x,x3,y:integer;
  am,amount:extended;
  a,r,g,b: Integer;
begin
  a:=weight;
//
  w:=src.width;
  h:=src.height;
  src.PixelFormat:=pf24bit;
  if depth=0 then exit;
  for y:=0 to depth do
  begin
    p1:=src.ScanLine[y];
    p2:=src.ScanLine[h-y-1];
//    amount:=1-y*am;
    for x:=y to w-1-y do
    begin
      x3:=x*3;
// lighter
      r:=p1[x3];
      g:=p1[x3+1];
      b:=p1[x3+2];
      p1[x3]:=IntToByte(r+((255-r)*a)div 255);
      p1[x3+1]:=IntToByte(g+((255-g)*a)div 255);
      p1[x3+2]:=IntToByte(b+((255-b)*a)div 255);
// darker
      r:=p2[x3];
      g:=p2[x3+1];
      b:=p2[x3+2];
      p2[x3]:=IntToByte(r-((r)*a)div 255);
      p2[x3+1]:=IntToByte(g-((g)*a)div 255);
      p2[x3+2]:=IntToByte(b-((b)*a)div 255);
    end;
    for x:=0 to y do
    begin
      x3:=x*3;
      w3:=(w-1-x)*3;
// lighter left
      r:=p1[x3];
      g:=p1[x3+1];
      b:=p1[x3+2];
      p1[x3]:=IntToByte(r+((255-r)*a)div 255);
      p1[x3+1]:=IntToByte(g+((255-g)*a)div 255);
      p1[x3+2]:=IntToByte(b+((255-b)*a)div 255);
// darker right
      r:=p1[w3];
      g:=p1[w3+1];
      b:=p1[w3+2];
      p1[w3]:=IntToByte(r-((r)*a)div 255);
      p1[w3+1]:=IntToByte(g-((g)*a)div 255);
      p1[w3+2]:=IntToByte(b-((b)*a)div 255);
// lighter bottom left
      r:=p2[x3];
      g:=p2[x3+1];
      b:=p2[x3+2];
      p2[x3]:=IntToByte(r+((255-r)*a)div 255);
      p2[x3+1]:=IntToByte(g+((255-g)*a)div 255);
      p2[x3+2]:=IntToByte(b+((255-b)*a)div 255);
// darker bottom right
      r:=p2[w3];
      g:=p2[w3+1];
      b:=p2[w3+2];
      p2[w3]:=IntToByte(r-((r)*a)div 255);
      p2[w3+1]:=IntToByte(g-((g)*a)div 255);
      p2[w3+2]:=IntToByte(b-((b)*a)div 255);
    end;
  end;
  for y:=depth+1 to h-2-depth do
  begin
    p1:=src.ScanLine[y];
    for x:=0 to depth do
    begin
      x3:=x*3;
      w3:=(w-1-x)*3;
// lighter left
      r:=p1[x3];
      g:=p1[x3+1];
      b:=p1[x3+2];
      p1[x3]:=IntToByte(r+((255-r)*a)div 255);
      p1[x3+1]:=IntToByte(g+((255-g)*a)div 255);
      p1[x3+2]:=IntToByte(b+((255-b)*a)div 255);
// darker right
      r:=p1[w3];
      g:=p1[w3+1];
      b:=p1[w3+2];
      p1[w3]:=IntToByte(r-((r)*a)div 255);
      p1[w3+1]:=IntToByte(g-((g)*a)div 255);
      p1[w3+2]:=IntToByte(b-((b)*a)div 255);
    end;
  end;
end;



procedure ConvolveFilter(filternr,edgenr:integer;src:TBitmap);
var
  z : integer;
  ray : array [0..8] of integer;
  OrigBMP : TBitmap;              // Bitmap for temporary use
begin
  z := 1;  // just to avoid compiler warnings!
  case filternr of
    0 : begin // Laplace
      ray[0] := -1; ray[1] := -1; ray[2] := -1;
      ray[3] := -1; ray[4] :=  8; ray[5] := -1;
      ray[6] := -1; ray[7] := -1; ray[8] := -1;
      z := 1;
      end;
    1 : begin  // Hipass
      ray[0] := -1; ray[1] := -1; ray[2] := -1;
      ray[3] := -1; ray[4] :=  9; ray[5] := -1;
      ray[6] := -1; ray[7] := -1; ray[8] := -1;
      z := 1;
      end;
    2 : begin  // Find Edges (top down)
      ray[0] :=  1; ray[1] :=  1; ray[2] :=  1;
      ray[3] :=  1; ray[4] := -2; ray[5] :=  1;
      ray[6] := -1; ray[7] := -1; ray[8] := -1;
      z := 1;
      end;
    3 : begin  // Sharpen
      ray[0] := -1; ray[1] := -1; ray[2] := -1;
      ray[3] := -1; ray[4] := 16; ray[5] := -1;
      ray[6] := -1; ray[7] := -1; ray[8] := -1;
      z := 8;
      end;
    4 : begin  // Edge Enhance
      ray[0] :=  0; ray[1] := -1; ray[2] :=  0;
      ray[3] := -1; ray[4] :=  5; ray[5] := -1;
      ray[6] :=  0; ray[7] := -1; ray[8] :=  0;
      z := 1;
      end;
    5 : begin  // Color Emboss (Sorta)
      ray[0] :=  1; ray[1] :=  0; ray[2] :=  1;
      ray[3] :=  0; ray[4] :=  0; ray[5] :=  0;
      ray[6] :=  1; ray[7] :=  0; ray[8] := -2;
      z := 1;
      end;
    6 : begin  // Soften
      ray[0] :=  2; ray[1] :=  2; ray[2] :=  2;
      ray[3] :=  2; ray[4] :=  0; ray[5] :=  2;
      ray[6] :=  2; ray[7] :=  2; ray[8] :=  2;
      z := 16;
      end;
    7 : begin  // Blur
      ray[0] :=  3; ray[1] :=  3; ray[2] :=  3;
      ray[3] :=  3; ray[4] :=  8; ray[5] :=  3;
      ray[6] :=  3; ray[7] :=  3; ray[8] :=  3;
      z := 32;
      end;
    8 : begin  // Soften less
      ray[0] :=  0; ray[1] :=  1; ray[2] :=  0;
      ray[3] :=  1; ray[4] :=  2; ray[5] :=  1;
      ray[6] :=  0; ray[7] :=  1; ray[8] :=  0;
      z := 6;
      end;
    else exit;
  end;
  OrigBMP := TBitmap.Create;  // Copy image to 24-bit bitmap
  CopyMe(OrigBMP,src);
  case Edgenr of
    0 : ConvolveM(ray,z,OrigBMP);
    1 : ConvolveE(ray,z,OrigBMP);
    2 : ConvolveI(ray,z,OrigBMP);
  end;
  src.Assign(OrigBMP);  //  Assign filtered image to Image1
  OrigBMP.Free;
end;

procedure CopyMe(tobmp: TBitmap; frbmp : TGraphic);
begin
  tobmp.Width := frbmp.Width;
  tobmp.Height := frbmp.Height;
  tobmp.PixelFormat := pf24bit;
  tobmp.Canvas.Draw(0,0,frbmp);
end;




procedure ButtonizeOval(src: TBitmap; depth: byte;
  weight: integer;rim:string);
var
  p0,p1,p2,p3:pbytearray;
  w,w3,h,i,x,x3,y,w2,h2:integer;
  am,amount:extended;
  fac,a,r,g,b,r2,g2,b2: Integer;
  contour:Tbitmap;
  biclight,bicdark,bicnone:byte;
  act:boolean;

begin
  a:=weight;
  w:=src.width;
  h:=src.height;
  contour:=Tbitmap.create;
  contour.width:=w;
  contour.height:=h;
  contour.PixelFormat:=pf24bit;
  contour.Canvas.brush.color:=clwhite;
  contour.canvas.FillRect(Rect(0,0,w,h));
  with contour.canvas do begin
    pen.Width:=1;
    pen.style:=pssolid;
    for i:=0 to depth-1 do begin
      if rim='rimmed' then begin
      //  (bottom-right)
        pen.color:=rgb($00,$02,i);
        Arc (i, i, w-i, h-i, // ellipse
        0, h, // start
        w, 0); // end
      //  (top-left)
        Pen.Color :=  rgb($00,$01,i);
        Arc (i, i, w-i, h-i, // ellipse
        w, 0, // start
        0, h); // end
      end
      else if (rim='round') or (rim='doubleround') then begin
      //  (bottom-right)
        pen.color:=rgb($00,$01,depth-1-i);
        Arc (i, i, w-i, h-i, // ellipse
        0, h, // start
        w, 0); // end
      //  (top-left)
        Pen.Color :=  rgb($00,$02,depth-1-i);
        Arc (i, i, w-i, h-i, // ellipse
        w, 0, // start
        0, h); // end
      end;
    end;
    if rim='doubleround' then
      for i:=depth to depth-1+depth do begin
      //  (bottom-right)
        pen.color:=rgb($00,$02,i);
        Arc (i, i, w-i, h-i, // ellipse
        0, h, // start
        w, 0); // end
      //  (top-left)
        Pen.Color :=  rgb($00,$01,i);
        Arc (i, i, w-i, h-i, // ellipse
        w, 0, // start
        0, h); // end
      end;
  end;
  src.PixelFormat:=pf24bit;
  for y:=0 to h-1 do
  begin
    p1:=src.ScanLine[y];
    p2:=contour.scanline[y];
    for x:=0 to w-1 do begin
      x3:=x*3;
      r:=p1[x3];
      g:=p1[x3+1];
      b:=p1[x3+2];
      r2:=p2[x3];
      g2:=p2[x3+1];
      b2:=p2[x3+2];
      fac:=trunc(r2/depth*a);
      if g2=$02 then begin // lighter
        p1[x3]:=IntToByte(r+((255-r)*fac)div 255);
        p1[x3+1]:=IntToByte(g+((255-g)*fac)div 255);
        p1[x3+2]:=IntToByte(b+((255-b)*fac)div 255);
      end
      else if g2=$01 then begin // darker
        p1[x3]:=IntToByte(r-((r)*fac)div 255);
        p1[x3+1]:=IntToByte(g-((g)*fac)div 255);
        p1[x3+2]:=IntToByte(b-((b)*fac)div 255);
      end;
    end;
  end;
  // anti alias
  for y:=1 to h-2 do begin
    p0:=src.ScanLine [y-1];
    p1:=src.scanline [y];
    p2:=src.ScanLine [y+1];
    p3:=contour.scanline[y];
    for x:=1 to w-2 do begin
      g2:=p3[x*3+1];
      if g2<>$00 then begin
        p1[x*3]:=(p0[x*3]+p2[x*3]+p1[(x-1)*3]+p1[(x+1)*3])div 4;
        p1[x3+1]:=(p0[x*3+1]+p2[x*3+1]+p1[(x-1)*3+1]+p1[(x+1)*3+1])div 4;
        p1[x*3+2]:=(p0[x*3+2]+p2[x*3+2]+p1[(x-1)*3+2]+p1[(x+1)*3+2])div 4;
      end;
    end;
  end;
  contour.free;
end;




procedure MaskOval(src: TBitmap;acolor:TColor);
var
  p0,p1,p2,p3:pbytearray;
  w,w3,h,i,x,x3,y,w2,h2:integer;
  fac,a,r,g,b,r2,g2,b2: Integer;
  mr,mg,mb:byte;
  contour:Tbitmap;

begin
  acolor:= colortorgb(acolor);
  mr:=getRvalue(acolor);
  mg:=getGvalue(acolor);
  mb:=getBvalue(acolor);
  w:=src.width;
  h:=src.height;
  contour:=Tbitmap.create;
  contour.width:=w;
  contour.height:=h;
  contour.PixelFormat:=pf24bit;
  contour.Canvas.brush.color:=clblack;
  contour.canvas.FillRect(Rect(0,0,w,h));
  contour.canvas.pen.color:=clred;
  contour.canvas.brush.color:=clred;
  contour.canvas.Ellipse(0,0,w,h);
  src.PixelFormat:=pf24bit;
  for y:=0 to h-1 do
  begin
    p1:=src.ScanLine[y];
    p2:=contour.scanline[y];
    for x:=0 to w-1 do begin
      x3:=x*3;
      r:=p1[x3];
      g:=p1[x3+1];
      b:=p1[x3+2];
      r2:=p2[x3];
      g2:=p2[x3+1];
      b2:=p2[x3+2];
      if b2=$00 then begin // mask
        p1[x3]:=mb;
        p1[x3+1]:=mg;
        p1[x3+2]:=mr;
      end;
    end;
  end;
  contour.free;
end;



end.
