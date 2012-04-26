
(*  ================================================================

       Adapted to use Scanlines.pas (pointers to Scanline[]).

       Chris Willig  Sep 2003
       chris@5thelephant.com

       All routines are unchanged from original, other than cleaning
       up the formatting and adapting to use pointers of course.

    ================================================================     *)

unit ScanlinesFX;

interface

uses
  Windows, SysUtils, Classes, Graphics, Math;

{ **************************************************************************

        Procedures taken/adapted from component:
            TProEffectImage Version 1.0 (FREEWARE)

            Written By Babak Sateli
            babak_sateli@yahoo.com
            http://raveland.netfirms.com
            Special thanks to Jan Verhoeven.


   ************************************************************************   }

  Procedure Effect_Invert          (SrcBmp: TBitmap);
  Procedure Effect_AddColorNoise   (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_AddMonoNoise    (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_AntiAlias       (SrcBmp: TBitmap);
  Procedure Effect_Contrast        (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_FishEye         (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_GrayScale       (SrcBmp: TBitmap);
  Procedure Effect_Lightness       (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_Darkness        (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_Saturation      (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_SplitBlur       (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_GaussianBlur    (SrcBmp: TBitmap; Amount:Integer);
  Procedure Effect_Mosaic          (SrcBmp: TBitmap; Size:Integer);
  Procedure Effect_Twist           (SrcBmp: TBitmap; Amount:Integer);
  procedure Effect_Splitlight      (SrcBmp: TBitmap; Amount:integer);
  Procedure Effect_Tile            (SrcBmp: TBitmap; Amount: integer);
  Procedure Effect_SpotLight       (SrcBmp: TBitmap; Amount: integer; Spot: TRect);
  Procedure Effect_Trace           (SrcBmp: TBitmap; Amount: integer);
  Procedure Effect_Emboss          (SrcBmp: TBitmap);
  Procedure Effect_Solorize        (SrcBmp: TBitmap; Amount: integer);
  Procedure Effect_Posterize       (SrcBmp: TBitmap; Amount: integer);

  procedure Effect_SmoothResize    (SrcBmp: TBitmap; NuWidth, NuHeight: integer);
  procedure Effect_SmoothRotate    (SrcBmp: TBitmap; cx, cy: Integer; Angle: Extended);

  //**************************************************************************
  procedure FishEye(var Bmp, Dst: TBitmap; Amount: Extended);
  procedure Twist(var Bmp, Dst: TBitmap; Amount: integer);
  procedure Emboss(var Bmp:TBitmap);
  procedure AntiAlias(clip: tbitmap);
  procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer; Angle: Extended);

implementation
uses
  Scanlines;

{$R-}

function Max(Int1, Int2: integer): integer;
begin
  if Int1 > Int2 then result := Int1
    else result := Int2;
end;

function Min(Int1, Int2: integer): integer;
begin
  if Int1 < Int2 then result := Int1
    else result := Int2;
end;

procedure PicInvert(src: tbitmap);
var
  w, h, x, y : integer;
  p : pbytearray;

  SL : TScanlines;
begin
  w := src.width;
  h := src.height;
  src.PixelFormat := pf24bit;

  SL := TScanlines.Create(Src);
  try
  
    for y := 0 to h-1 do begin
      //p:=src.scanline[y];
      p := PByteArray(SL[y]);

      for x:=0 to w-1 do begin
        p[x*3]   := not p[x*3];
        p[x*3+1] := not p[x*3+1];
        p[x*3+2] := not p[x*3+2];
      end;
    end;

  finally
    SL.Free;
  end;
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

procedure AddColorNoise(var clip: tbitmap; Amount: Integer);
var
  p0 : pbytearray;
  x, y, r, g, b : Integer;
  SL : TScanLines;
begin
  SL := TScanLines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
      //p0 := clip.ScanLine [y];
      p0 := PByteArray(SL[y]);
      for x := 0 to clip.Width-1 do
      begin
        r := p0[x*3]+(Random(Amount)-(Amount shr 1));
        g := p0[x*3+1]+(Random(Amount)-(Amount shr 1));
        b := p0[x*3+2]+(Random(Amount)-(Amount shr 1));
        p0[x*3]   := IntToByte(r);
        p0[x*3+1] := IntToByte(g);
        p0[x*3+2] := IntToByte(b);
      end;
    end;

  finally
    SL.Free;
  end;
end;

procedure AddMonoNoise(var clip: tbitmap; Amount: Integer);
var
  p0 : pbytearray;
  x, y, a, r, g, b : Integer;

  SL : TScanLines;
begin
  SL := TScanlines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);
      for x := 0 to clip.Width-1 do begin
        a := Random(Amount)-(Amount shr 1);
        r := p0[x*3]+a;
        g := p0[x*3+1]+a;
        b := p0[x*3+2]+a;
        p0[x*3] := IntToByte(r);
        p0[x*3+1] := IntToByte(g);
        p0[x*3+2] := IntToByte(b);
      end;
    end;

  finally
    SL.Free;
  end;
end;

procedure AntiAliasRect(clip: tbitmap; XOrigin, YOrigin, XFinal, YFinal: Integer);
var
  Memo, x, y : Integer; (* Composantes primaires des points environnants *)
  p0, p1, p2 : pbytearray;
  SL : TScanlines;
begin
   if XFinal<XOrigin then begin Memo := XOrigin; XOrigin := XFinal; XFinal := Memo; end;  (* Inversion des valeurs   *)
   if YFinal<YOrigin then begin Memo := YOrigin; YOrigin := YFinal; YFinal := Memo; end;  (* si diff,rence n,gative*)

   XOrigin := max(1,XOrigin);
   YOrigin := max(1,YOrigin);
   XFinal := min(clip.width-2,XFinal);
   YFinal := min(clip.height-2,YFinal);
   clip.PixelFormat := pf24bit;

   SL := TScanlines.Create(clip);
   try

     for y := YOrigin to YFinal do begin
      //p0 := clip.ScanLine [y-1];
      //p1 := clip.scanline [y];
      //p2 := clip.ScanLine [y+1];

      p0 := PByteArray(SL[y-1]);
      p1 := PByteArray(SL[y]);
      p2 := PByteArray(SL[y+1]);

      for x := XOrigin to XFinal do begin
        p1[x*3]   := (p0[x*3]+p2[x*3]+p1[(x-1)*3]+p1[(x+1)*3])div 4;
        p1[x*3+1] := (p0[x*3+1]+p2[x*3+1]+p1[(x-1)*3+1]+p1[(x+1)*3+1])div 4;
        p1[x*3+2] := (p0[x*3+2]+p2[x*3+2]+p1[(x-1)*3+2]+p1[(x+1)*3+2])div 4;
        end;
     end;

   finally
     SL.Free;
   end;
end;

procedure AntiAlias(clip: tbitmap);
begin
  AntiAliasRect(clip, 0, 0, clip.width, clip.height);
end;

procedure Contrast(var clip: tbitmap; Amount: Integer);
var
  p0 : pbytearray;
  rg, gg, bg, r, g, b, x, y :  Integer;

  SL : TScanLines;
begin
  SL := TScanlines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);

      for x := 0 to clip.Width-1 do begin
        r := p0[x*3];
        g := p0[x*3+1];
        b := p0[x*3+2];
        rg := (Abs(127-r)*Amount)div 255;
        gg := (Abs(127-g)*Amount)div 255;
        bg := (Abs(127-b)*Amount)div 255;
        if r>127 then r := r+rg else r := r-rg;
        if g>127 then g := g+gg else g := g-gg;
        if b>127 then b := b+bg else b := b-bg;
        p0[x*3]   := IntToByte(r);
        p0[x*3+1] := IntToByte(g);
        p0[x*3+2] := IntToByte(b);
      end;
    end;

  finally
    SL.Free;
  end;
end;

procedure FishEye(var Bmp, Dst: TBitmap; Amount: Extended);
var
  xmid, ymid             : Single;
  fx, fy                 : Single;
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

  SL1, SL2 : TScanlines;
begin
  xmid := Bmp.Width/2;
  ymid := Bmp.Height/2;
  rmax := Dst.Width * Amount;

  SL1 := TScanlines.Create(Bmp);
  SL2 := TScanlines.Create(Dst);
  try

    for ty := 0 to Dst.Height - 1 do begin
      for tx := 0 to Dst.Width - 1 do begin
        dx := tx - xmid;
        dy := ty - ymid;
        r1 := Sqrt(dx * dx + dy * dy);

        if r1 = 0 then begin
          fx := xmid;
          fy := ymid;
        end else begin
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
          end;
        end;
        //slo := Dst.scanline[ty];
        slo := PByteArray(SL2[ty]);
        slo[tx*3]   := Round(total_red);
        slo[tx*3+1] := Round(total_green);
        slo[tx*3+2] := Round(total_blue);

      end;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

procedure GrayScale(var clip: tbitmap);
var
  p0 : pbytearray;
  Gray, x, y : Integer;

  SL : TScanlines;
begin
  SL := TScanlines.Create(clip);
  try

    for y:=0 to clip.Height-1 do begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);

      for x := 0 to clip.Width-1 do begin
        Gray := Round(p0[x*3]*0.3+p0[x*3+1]*0.59+p0[x*3+2]*0.11);
        p0[x*3] := Gray;
        p0[x*3+1] := Gray;
        p0[x*3+2] := Gray;
      end;
    end;

  finally
    SL.Free;
  end;
end;


procedure Lightness(var clip: tbitmap; Amount: Integer);
var
  p0 : pbytearray;
  r, g, b, x, y : Integer;

  SL : TScanlines;
begin
  SL := TScanlines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);

      for x := 0 to clip.Width-1 do begin
        r := p0[x*3];
        g := p0[x*3+1];
        b := p0[x*3+2];
        p0[x*3]   := IntToByte(r+((255-r)*Amount)div 255);
        p0[x*3+1] := IntToByte(g+((255-g)*Amount)div 255);
        p0[x*3+2] := IntToByte(b+((255-b)*Amount)div 255);
      end;
    end;

  finally
    SL.Free;
  end;
end;

procedure Darkness(var src: tbitmap; Amount: integer);
var
  p0 : pbytearray;
  r, g, b, x, y : Integer;

  SL : TScanlines;
begin
  src.pixelformat := pf24bit;

  SL := TScanlines.Create(src);
  try

    for y := 0 to src.Height-1 do begin
      //p0 := src.scanline[y];
      p0 := PByteArray(SL[y]);

      for x := 0 to src.Width-1 do begin
        r := p0[x*3];
        g := p0[x*3+1];
        b := p0[x*3+2];
        p0[x*3]   := IntToByte(r-((r)*Amount)div 255);
        p0[x*3+1] := IntToByte(g-((g)*Amount)div 255);
        p0[x*3+2] := IntToByte(b-((b)*Amount)div 255);
      end;
    end;

  finally
    SL.Free;
  end;
end;


procedure Saturation(var clip: tbitmap; Amount: Integer);
var
  p0 : pbytearray;
  Gray, r, g, b, x, y : Integer;
  SL : TScanlines;
begin
  SL := TScanlines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
      //p0 := clip.scanline[y];
      p0 := PByteArray(SL[y]);

      for x := 0 to clip.Width-1 do begin
        r := p0[x*3];
        g := p0[x*3+1];
        b := p0[x*3+2];
        Gray := (r+g+b)div 3;
        p0[x*3]   := IntToByte(Gray+(((r-Gray)*Amount)div 255));
        p0[x*3+1] := IntToByte(Gray+(((g-Gray)*Amount)div 255));
        p0[x*3+2] := IntToByte(Gray+(((b-Gray)*Amount)div 255));
      end;
    end;

  finally
    SL.Free;
  end;
end;

procedure SmoothResize(var Src, Dst: TBitmap);
var
  x, y, xP, yP, yP2, xP2 : Integer;
  Read, Read2 : PByteArray;
  t, z, z2, iz2 : Integer;
  pc : PBytearray;
  w1, w2, w3, w4 : Integer;
  Col1r, col1g, col1b, Col2r, col2g, col2b :   byte;

  SL1, SL2 : TScanlines;
begin
  SL1 := TScanlines.Create(Src);
  SL2 := TScanlines.Create(Dst);
  try

    xP2 := ((src.Width-1)shl 15)div Dst.Width;
    yP2 := ((src.Height-1)shl 15)div Dst.Height;
    yP := 0;
    for y := 0 to Dst.Height-1 do begin
      xP := 0;

      //Read := src.ScanLine[yP shr 15];
      Read := PByteArray(SL1[yP shr 15]);
      if yP shr 16<src.Height-1 then
        //Read2 := src.ScanLine [yP shr 15+1]
        Read2 := PByteArray(SL1[yP shr 15+1])
      else
        //Read2 := src.ScanLine [yP shr 15];
        Read2 := PByteArray(SL1[yP shr 15]);

      //pc := Dst.scanline[y];
      pc := PByteArray(SL2[y]);
      z2 := yP and $7FFF;
      iz2 := $8000-z2;
      for x := 0 to Dst.Width-1 do begin
        t := xP shr 15;
        Col1r := Read[t*3];
        Col1g := Read[t*3+1];
        Col1b := Read[t*3+2];
        Col2r := Read2[t*3];
        Col2g := Read2[t*3+1];
        Col2b := Read2[t*3+2];
        z := xP and $7FFF;
        w2 := (z*iz2)shr 15;
        w1 := iz2-w2;
        w4 := (z*z2)shr 15;
        w3 := z2-w4;
        pc[x*3+2] := 
          (Col1b*w1+Read[(t+1)*3+2]*w2+
           Col2b*w3+Read2[(t+1)*3+2]*w4)shr 15;
        pc[x*3+1] := 
          (Col1g*w1+Read[(t+1)*3+1]*w2+
           Col2g*w3+Read2[(t+1)*3+1]*w4)shr 15;
        pc[x*3] := 
          (Col1r*w1+Read2[(t+1)*3]*w2+
           Col2r*w3+Read2[(t+1)*3]*w4)shr 15;
        Inc(xP,xP2);
      end;
      Inc(yP,yP2);
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

function TrimInt(i, Min, Max: Integer): Integer;
begin
  if i > Max then
    Result := Max
  else
    if i < Min then
      Result := Min
    else
      Result := i;
end;


procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer; Angle: Extended);
type
  TFColor  = record b, g, r : Byte end;
var
  Top,
  Bottom,
  Left,
  Right,
  eww, nsw,
  fx, fy,
  wx, wy:    Extended;
  cAngle,
  sAngle:   Double;
  xDiff,
  yDiff,
  ifx, ify,
  px, py,
  ix, iy,
  x, y:      Integer;
  nw, ne,
  sw, se:    TFColor;
  P1, P2, P3 : Pbytearray;

  SL1, SL2 : TScanlines;
begin
  SL1 := TScanlines.Create(Src);
  SL2 := TScanlines.Create(Dst);
  try

    Angle := angle;
    Angle := -Angle*Pi/180;
    sAngle := Sin(Angle);
    cAngle := Cos(Angle);
    xDiff := (Dst.Width-Src.Width)div 2;
    yDiff := (Dst.Height-Src.Height)div 2;

    for y := 0 to Dst.Height-1 do begin
      //P3 := Dst.scanline[y];
      P3 := PByteArray(SL2[y]);
      py := 2*(y-cy)+1;

      for x := 0 to Dst.Width-1 do begin
        px := 2*(x-cx)+1;
        fx := (((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
        fy := (((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
        ifx := Round(fx);
        ify := Round(fy);

        if (ifx>-1) and (ifx<Src.Width) and (ify>-1) and (ify<Src.Height) then
        begin
          eww := fx-ifx;
          nsw := fy-ify;
          iy := TrimInt(ify+1,0,Src.Height-1);
          ix := TrimInt(ifx+1,0,Src.Width-1);
          //P1 := Src.scanline[ify];
          P1 := PByteArray(SL1[ify]);
          //P2 := Src.scanline[iy];
          P2 := PByteArray(SL1[iy]);
          nw.r := P1[ifx*3];
          nw.g := P1[ifx*3+1];
          nw.b := P1[ifx*3+2];
          ne.r := P1[ix*3];
          ne.g := P1[ix*3+1];
          ne.b := P1[ix*3+2];
          sw.r := P2[ifx*3];
          sw.g := P2[ifx*3+1];
          sw.b := P2[ifx*3+2];
          se.r := P2[ix*3];
          se.g := P2[ix*3+1];
          se.b := P2[ix*3+2];

          Top    := nw.b+eww*(ne.b-nw.b);
          Bottom := sw.b+eww*(se.b-sw.b);
          P3[x*3+2] := IntToByte(Round(Top+nsw*(Bottom-Top)));

          Top    := nw.g+eww*(ne.g-nw.g);
          Bottom := sw.g+eww*(se.g-sw.g);
          P3[x*3+1] := IntToByte(Round(Top+nsw*(Bottom-Top)));

          Top    := nw.r+eww*(ne.r-nw.r);
          Bottom := sw.r+eww*(se.r-sw.r);
          P3[x*3] := IntToByte(Round(Top+nsw*(Bottom-Top)));
        end;
      end;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;


procedure SplitBlur(var clip: tbitmap; Amount: integer);
var
  p0, p1, p2 : pbytearray;
  cx, x, y : Integer;
  Buf : array[0..3,0..2]of byte;

  SL : TScanlines;
begin
  if Amount = 0 then Exit;

  SL := TScanlines.Create(clip);
  try

    for y := 0 to clip.Height-1 do begin
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

      if y+Amount<clip.Height then
        p2 := PByteArray(SL[y+Amount])
      else {y+Amount>=Height}
        p2 := PByteArray(SL[clip.Height-y]);

      for x := 0 to clip.Width-1 do begin
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

        if x+Amount<clip.Width  then
          cx := x+Amount
        else {x+Amount>=Width}
          cx := clip.Width-x;

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
    end;

  finally
    SL.Free;
  end;
end;

procedure GaussianBlur(var clip: tbitmap; Amount: integer);
var
  i : Integer;
begin
  for i := Amount downto 0 do
    SplitBlur(clip,3);
end;

procedure Mosaic(var Bm:TBitmap;size:Integer);
var
   x, y, i, j : integer;
   p1, p2 : pbytearray;
   r, g, b : byte;

  SL : TScanlines;
begin
  SL := TScanlines.Create(Bm);
  try

    y := 0;
    repeat
      //p1 := bm.scanline[y];
      p1 := PByteArray(SL[y]);

      repeat
        j := 1;
        repeat
        //p2 := bm.scanline[y];
        p2 := PByteArray(SL[y]);
        x := 0;
        repeat
          r := p1[x*3];
          g := p1[x*3+1];
          b := p1[x*3+2];
          i := 1;
         repeat
           p2[x*3] := r;
           p2[x*3+1] := g;
           p2[x*3+2] := b;
           inc(x);
           inc(i);
         until (x>=bm.width) or (i>size);
        until x>=bm.width;
        inc(j);
        inc(y);
        until (y>=bm.height) or (j>size);
      until (y>=bm.height) or (x>=bm.width);
    until y>=bm.height;

  finally
    SL.Free;
  end;
end;


procedure Twist(var Bmp, Dst: TBitmap; Amount: integer);
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
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

Procedure Splitlight (var clip:tbitmap;amount:integer);
var
  x, y, i : integer;
  p1 : pbytearray;

  SL : TScanlines;

    function sinpixs(a:integer):integer;
    begin
      result := variant(sin(a/255*pi/2)*255);
    end;

begin
  SL := TScanlines.Create(clip);
  try

    for i := 1 to amount do
      for y := 0 to clip.height-1 do begin
        //p1 := clip.scanline[y];
        p1 := PByteArray(SL[y]);
        for x := 0 to clip.width-1 do begin
          p1[x*3]   := sinpixs(p1[x*3]);
          p1[x*3+1] := sinpixs(p1[x*3+1]);
          p1[x*3+2] := sinpixs(p1[x*3+2]);
        end;
      end;

  finally
    SL.Free;
  end;
end;


procedure Tile(src, dst: TBitmap; amount: integer);
var
  w, h, w2, h2, i, j : integer;
  bm : tbitmap;
begin
  w := src.width;
  h := src.height;
  dst.width := w;
  dst.height := h;
  dst.Canvas.draw(0,0,src);

  if (amount<=0) or ((w div amount)<5)or ((h div amount)<5) then
    exit;

  h2 := h div amount;
  w2 := w div amount;
  bm := tbitmap.create;
  bm.width := w2;
  bm.height := h2;
  bm.PixelFormat := pf24bit;
  smoothresize(src,bm);

  for j := 0 to amount-1 do
   for i := 0 to amount-1 do
     dst.canvas.Draw (i*w2,j*h2,bm);

  bm.free;
end;

procedure SpotLight (var src: Tbitmap; Amount: integer; Spot: TRect);
var
  bm : tbitmap;
  w, h : integer;
begin
  Darkness(src,amount);
  w := src.Width;
  h := src.Height ;
  bm := tbitmap.create;
  bm.width := w;
  bm.height := h;
  bm.canvas.Brush.color := clblack;
  bm.canvas.FillRect (rect(0,0,w,h));
  bm.canvas.brush.Color := clwhite;
  bm.canvas.Ellipse (Spot.left,spot.top,spot.right,spot.bottom);
  bm.transparent := true;
  bm.TransparentColor := clwhite;
  src.Canvas.Draw (0,0,bm);
  bm.free;
end;


procedure Trace (src:Tbitmap;intensity:integer);
var
  x, y, i : integer;
  P1, P2, P3, P4 : PByteArray;
  tb, TraceB : byte;
  hasb : boolean;
  bitmap : tbitmap;

  SL1, SL2 : TScanlines;
begin
  bitmap := tbitmap.create;
  bitmap.width := src.width;
  bitmap.height := src.height;
  bitmap.canvas.draw(0,0,src);
  bitmap.PixelFormat := pf8bit;  // pf8bit
  src.PixelFormat := pf24bit;
  hasb := false;
  TraceB := $00;

  SL1 := TScanlines.Create(src);
  SL2 := TScanlines.Create(bitmap);
  try

    tb := 0; //make compiler smile

    for i := 1 to Intensity do begin
      for y := 0 to BitMap.height -2 do begin
        //P1 := BitMap.ScanLine[y];
        //P2 := BitMap.scanline[y+1];
        P1 := PByteArray(SL2[y]);
        P2 := PByteArray(SL2[y +1]);
        //P3 := src.scanline[y];
        //P4 := src.scanline[y+1];
        P3 := PByteArray(SL1[y]);
        P4 := PByteArray(SL1[y+1]);
        x := 0;
        repeat
          if p1[x]<>p1[x+1] then begin
             if not hasb then begin
               tb := p1[x+1];
               hasb := true;
               p3[x*3] := TraceB;
               p3[x*3+1] := TraceB;
               p3[x*3+2] := TraceB;
             end else begin
               if p1[x]<>tb then begin
                 p3[x*3] := TraceB;
                 p3[x*3+1] := TraceB;
                 p3[x*3+2] := TraceB;
               end else begin
                 p3[(x+1)*3] := TraceB;
                 p3[(x+1)*3+1] := TraceB;
                 p3[(x+1)*3+1] := TraceB;
               end;
             end;
          end;

          if p1[x]<>p2[x] then begin
             if not hasb then begin
               tb := p2[x];
               hasb := true;
               p3[x*3] := TraceB;
               p3[x*3+1] := TraceB;
               p3[x*3+2] := TraceB;
             end else begin
               if p1[x]<>tb then begin
                 p3[x*3] := TraceB;
                 p3[x*3+1] := TraceB;
                 p3[x*3+2] := TraceB;
               end else begin
                 p4[x*3] := TraceB;
                 p4[x*3+1] := TraceB;
                 p4[x*3+2] := TraceB;
               end;
             end;
          end;

          inc(x);
        until x>=(BitMap.width -2);
      end;
      if i>1 then
      for y := BitMap.height -1 downto 1 do begin
        //P1 := BitMap.ScanLine[y];
        //P2 := BitMap.scanline[y-1];
        P1 := PByteArray(SL2[y]);
        P2 := PByteArray(SL2[y -1]);
        //P3 := src.scanline[y];
        //P4 := src.scanline [y-1];
        P3 := PByteArray(SL1[y]);
        P4 := PByteArray(SL1[y-1]);
        x := Bitmap.width-1;
        repeat
          if p1[x]<>p1[x-1] then begin
             if not hasb then begin
               tb := p1[x-1];
               hasb := true;
               p3[x*3] := TraceB;
               p3[x*3+1] := TraceB;
               p3[x*3+2] := TraceB;
             end else begin
               if p1[x]<>tb then begin
                 p3[x*3] := TraceB;
                 p3[x*3+1] := TraceB;
                 p3[x*3+2] := TraceB;
               end else begin
                 p3[(x-1)*3] := TraceB;
                 p3[(x-1)*3+1] := TraceB;
                 p3[(x-1)*3+2] := TraceB;
               end;
             end;
          end;

          if p1[x]<>p2[x] then begin
             if not hasb then begin
               tb := p2[x];
               hasb := true;
               p3[x*3] := TraceB;
               p3[x*3+1] := TraceB;
               p3[x*3+2] := TraceB;
             end else begin
               if p1[x]<>tb then begin
                 p3[x*3] := TraceB;
                 p3[x*3+1] := TraceB;
                 p3[x*3+2] := TraceB;
               end else begin
                 p4[x*3] := TraceB;
                 p4[x*3+1] := TraceB;
                 p4[x*3+2] := TraceB;
               end;
             end;
          end;
          
          dec(x);
        until x<=1;
      end;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
bitmap.free;
end;


procedure Emboss(var Bmp:TBitmap);
var
  x, y :   Integer;
  p1, p2 : Pbytearray;

  SL : TScanlines;
begin
  SL := TScanlines.Create(Bmp);
  try

    for y := 0 to Bmp.Height-2 do begin
      //p1 := bmp.scanline[y];
      //p2 := bmp.scanline[y+1];
      p1 := PByteArray(SL[y]);
      p2 := PByteArray(SL[y+1]);

      for x := 0 to Bmp.Width-4 do begin
        p1[x*3] := (p1[x*3]+(p2[(x+3)*3] xor $FF))shr 1;
        p1[x*3+1] := (p1[x*3+1]+(p2[(x+3)*3+1] xor $FF))shr 1;
        p1[x*3+2] := (p1[x*3+2]+(p2[(x+3)*3+2] xor $FF))shr 1;
      end;

    end;

  finally
    SL.Free;
  end;
end;


procedure Solorize(src, dst: tbitmap; amount: integer);
var
  w, h, x, y : integer;
  ps, pd : pbytearray;
  c : integer;

  SL1, SL2 : TScanlines;
begin
  w := src.width;
  h := src.height;
  src.PixelFormat := pf24bit;
  dst.PixelFormat := pf24bit;

  SL1 := TScanlines.Create(src);
  SL2 := TScanlines.Create(dst);
  try

    for y := 0 to h-1 do begin
      //ps := src.scanline[y];
      //pd := dst.scanline[y];
      ps := PByteArray(SL1[y]);
      pd := PByteArray(SL2[y]);

      for x := 0 to w-1 do begin
        c := (ps[x*3]+ps[x*3+1]+ps[x*3+2]) div 3;

        if c>amount then begin
          pd[x*3] :=  255-ps[x*3];
          pd[x*3+1] := 255-ps[x*3+1];
          pd[x*3+2] := 255-ps[x*3+2];
        end else begin
          pd[x*3] := ps[x*3];
          pd[x*3+1] := ps[x*3+1];
          pd[x*3+2] := ps[x*3+2];
        end;
      end;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

procedure Posterize(src, dst: tbitmap; amount: integer);
var
  w, h, x, y : integer;
  ps, pd : pbytearray;

  SL1, SL2 : TScanlines;
begin
  w := src.width;
  h := src.height;
  src.PixelFormat := pf24bit;
  dst.PixelFormat := pf24bit;

  SL1 := TScanlines.Create(src);
  SL2 := TScanlines.Create(dst);
  try

    for y := 0 to h-1 do begin
      //ps := src.scanline[y];
      //pd := dst.scanline[y];
      ps := PByteArray(SL1[y]);
      pd := PByteArray(SL2[y]);
      for x := 0 to w-1 do begin
        pd[x*3]   :=  round(ps[x*3]/amount)*amount;
        pd[x*3+1] := round(ps[x*3+1]/amount)*amount;
        pd[x*3+2] := round(ps[x*3+2]/amount)*amount;
      end;
    end;

  finally
    SL2.Free;
    SL1.Free;
  end;
end;

// *********************************
// ******************
// ******

      function GetAs24bit(Src: TBitmap): TBitmap;
      begin
        result := TBitmap.Create;
        result.Assign(Src);
        result.PixelFormat := pf24bit;
      end;


procedure Effect_Invert(SrcBmp: TBitmap);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    PicInvert ( BB );
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_AddColorNoise (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    AddColorNoise (bb,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_AddMonoNoise (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    AddMonoNoise (bb,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

procedure Effect_AntiAlias(SrcBmp: TBitmap);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    AntiAlias ( BB );
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Contrast (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Contrast (bb,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_FishEye (SrcBmp: TBitmap; Amount:Integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := GetAs24bit(BB1);
  try
    FishEye (BB1, BB2, Amount);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

Procedure Effect_GrayScale(SrcBmp: TBitmap);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    GrayScale (BB);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Lightness (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Lightness (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Darkness (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Darkness (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Saturation (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Saturation (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_SplitBlur (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    SplitBlur (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_GaussianBlur (SrcBmp: TBitmap; Amount:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    GaussianBlur (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Mosaic (SrcBmp: TBitmap; Size:Integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Mosaic (BB,Size);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Twist (SrcBmp: TBitmap; Amount:Integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := GetAs24bit(BB1);
  try
    Twist (BB1, BB2, Amount);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

Procedure Effect_Trace (SrcBmp: TBitmap; Amount: integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Trace (BB,Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

procedure Effect_Splitlight (SrcBmp: TBitmap; Amount:integer);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Splitlight (BB, Amount);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Tile (SrcBmp: TBitmap; Amount: integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := GetAs24bit(BB1);
  try
    Tile (BB1, BB2, Amount);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

Procedure Effect_SpotLight (SrcBmp: TBitmap; Amount: integer; Spot: TRect);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    SpotLight (BB, Amount, Spot);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Emboss(SrcBmp: TBitmap);
Var
  BB : TBitmap;
Begin
  BB := GetAs24bit(SrcBmp);
  try
    Emboss (BB);
    SrcBmp .Assign (BB);
  finally
    BB.Free;
  end;
end;

Procedure Effect_Solorize (SrcBmp: TBitmap; Amount: integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := GetAs24bit(BB1);
  try
    Solorize (BB1, BB2, Amount);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;


Procedure Effect_Posterize (SrcBmp: TBitmap; Amount: integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := GetAs24bit(BB1);
  try
    Posterize (BB1, BB2, Amount);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

procedure Effect_SmoothResize(SrcBmp: TBitmap; NuWidth, NuHeight: integer);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := TBitmap.Create;
  try
    BB2.Width := NuWidth;
    BB2.Height := NuHeight;
    BB2.PixelFormat := pf24bit;

    SmoothResize( BB1, BB2 );
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

procedure Effect_SmoothRotate(SrcBmp: TBitmap; cx, cy: Integer; Angle: Extended);
Var
  BB1, BB2 : TBitmap;
Begin
  BB1 := GetAs24bit(SrcBmp);
  BB2 := TBitmap.Create;
  try
    BB2.Width := BB1.Width;
    BB2.Height := BB1.Height;
    BB2.PixelFormat := pf24bit;

    SmoothRotate(BB1, BB2, cx, cy, Angle);
    SrcBmp .Assign (BB2);
  finally
    BB1.Free;
    BB2.Free;
  end;
end;

end.
