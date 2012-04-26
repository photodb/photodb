unit FastDraw;
                  //FastDraw 3/30/99
interface         //  Gordon Alex Cowie <gfody@jps.net>
                  //  www.jps.net/gfody
uses FastRGB,     //  Some functions for drawing antialiased
     Fast256,     //  lines.. overloaded for TFast256 (sort of)
     Windows;     //  if Bmp is TFast256, 0 is used!

// rectangles
procedure Rectangle(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
procedure FillRect(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
// lines
procedure Line(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
procedure SmoothLine(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
procedure PolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
procedure SmoothPolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
// ellipses
procedure Ellipse(Bmp:TFastRGB;cx,cy,Rx,Ry:Integer;clr:TFColor);

implementation

procedure Rectangle(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
var
Tmp: PFColor;
i:   Integer;
begin
  if x1>x1 then begin i:=x1; x1:=x2; x2:=i; end;
  if y1>y2 then begin i:=y1; y1:=y2; y2:=i; end;

  if Bmp is TFast256 then
  begin
    for i:=x1 to x2 do
    begin
      TFast256(Bmp).Pixels[y1,i]:=0;
      TFast256(Bmp).Pixels[y2,i]:=0;
    end;
    for i:=y1 to y2 do
    begin
      TFast256(Bmp).Pixels[i,x1]:=0;
      TFast256(Bmp).Pixels[i,x2]:=0;
    end;
  end else
  begin
    for i:=x1 to x2 do
    begin
      Bmp.Pixels[y1,i]:=clr;
      Bmp.Pixels[y2,i]:=clr;
    end;
    for i:=y1 to y2 do
    begin
      Bmp.Pixels[i,x1]:=clr;
      Bmp.Pixels[i,x2]:=clr;
    end;
  end;
end;

procedure FillRect(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
var
i,x,y: Integer;
begin
  x1:=TrimInt(x1,0,Bmp.Width-1);
  x2:=TrimInt(x2,0,Bmp.Width-1);
  y1:=TrimInt(y1,0,Bmp.Height-1);
  y2:=TrimInt(y2,0,Bmp.Height-1);

  if x1>x1 then begin i:=x1; x1:=x2; x2:=i; end;
  if y1>y2 then begin i:=y1; y1:=y2; y2:=i; end;

  if Bmp is TFast256 then
    for y:=y1 to y2 do
    for x:=x1 to x2 do
    TFast256(Bmp).Pixels[y,x]:=0
  else
    for y:=y1 to y2 do
    for x:=x1 to x2 do
    Bmp.Pixels[y,x]:=clr;
end;

//bressenham line algorithm
procedure Line(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
var
d,ax,ay,
sx,sy,
dx,dy:  Integer;
begin
  if not((x1<Bmp.Width)and(x2<Bmp.Width)and(x1>-1)and(x2>-1)and
     (y1<Bmp.Height)and(y2<Bmp.Height)and(y1>-1)and(y2>-1))then Exit;

  dx:=x2-x1; ax:=Abs(dx)shl 1; if dx<0 then sx:=-1 else sx:=1;
  dy:=y2-y1; ay:=Abs(dy)shl 1; if dy<0 then sy:=-1 else sy:=1;
  Bmp.Pixels[y1,x1]:=clr;
  if ax>ay then
  begin
    d:=ay-(ax shr 1);
    while x1<>x2 do
    begin
      if d>-1 then
      begin
        Inc(y1,sy);
        Dec(d,ax);
      end;
      Inc(x1,sx);
      Inc(d,ay);
      Bmp.Pixels[y1,x1]:=clr;
    end;
  end else
  begin
    d:=ax-(ay shr 1);
    while y1<>y2 do
    begin
      if d>=0 then
      begin
        Inc(x1,sx);
        Dec(d,ay);
      end;
      Inc(y1,sy);
      Inc(d,ax);
      Bmp.Pixels[y1,x1]:=clr;
    end;
  end;
end;

//modified bressenham's to alphablend the error (antialiased)
procedure SmoothLine(Bmp:TFastRGB;x1,y1,x2,y2:Integer;clr:TFColor);
var
ea,ec: Word;
ci:    Byte;
dx,dy,
d,s:   Integer;
Tmp:   PFColor;
begin
  if(y1=y2)or(x1=x2)then
  begin
    Line(Bmp,x1,y1,x2,y2,clr);
    Exit;
  end;
  if y1>y2 then
  begin
    d:=y1; y1:=y2; y2:=d;
    d:=x1; x1:=x2; x2:=d;
  end;
  dx:=x2-x1;
  dy:=y2-y1;
  if dx>-1 then s:=1 else
  begin
    s:=-1;
    dx:=-dx;
  end;
  ec:=0;
  Bmp.Pixels[y1,x1]:=clr;
  if dy>dx then
  begin
    ea:=(dx shl 16)div dy;
    while dy>1 do
    begin
      Dec(dy);
      d:=ec;
      Inc(ec,ea);
      if ec<=d then Inc(x1,s);
      Inc(y1);
      ci:=ec shr 8;
      Tmp:=@Bmp.Pixels[y1,x1];
      Tmp.b:=((clr.b*(255 xor ci))+(Tmp.b*ci))shr 8;
      Tmp.g:=((clr.g*(255 xor ci))+(Tmp.g*ci))shr 8;
      Tmp.r:=((clr.r*(255 xor ci))+(Tmp.r*ci))shr 8;
      Tmp:=@Bmp.Pixels[y1,x1+s];
      Tmp.b:=((clr.b*ci)+(Tmp.b*(255 xor ci)))shr 8;
      Tmp.g:=((clr.g*ci)+(Tmp.g*(255 xor ci)))shr 8;
      Tmp.r:=((clr.r*ci)+(Tmp.r*(255 xor ci)))shr 8;
    end;
  end else
  begin
    ea:=(dy shl 16)div dx;
    while dx>1 do
    begin
      Dec(dx);
      d:=ec;
      Inc(ec,ea);
      if ec<=d then Inc(y1);
      Inc(x1,s);
      ci:=ec shr 8;
      Tmp:=@Bmp.Pixels[y1,x1];
      Tmp.b:=((clr.b*(255 xor ci))+(Tmp.b*ci))shr 8;
      Tmp.g:=((clr.g*(255 xor ci))+(Tmp.g*ci))shr 8;
      Tmp.r:=((clr.r*(255 xor ci))+(Tmp.r*ci))shr 8;
      Tmp:=@Bmp.Pixels[y1+1,x1];
      Tmp.b:=((clr.b*ci)+(Tmp.b*(255 xor ci)))shr 8;
      Tmp.g:=((clr.g*ci)+(Tmp.g*(255 xor ci)))shr 8;
      Tmp.r:=((clr.r*ci)+(Tmp.r*(255 xor ci)))shr 8;
    end;
  end;
  Bmp.Pixels[y2,x2]:=clr;
end;

procedure PolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
var
n,i: Integer;
begin
  n:=High(pnts)+1;
  for i:=0 to n-1 do
  Line(Bmp,pnts[i].x,pnts[i].y,pnts[(i+1) mod n].x,pnts[(i+1) mod n].y,clr);
end;

procedure SmoothPolyLine(Bmp:TFastRGB;pnts:array of TPoint;clr:TFColor);
var
n,i: Integer;
begin
  n:=High(pnts)+1;
  for i:=0 to n-1 do
  SmoothLine(Bmp,pnts[i].x,pnts[i].y,pnts[(i+1) mod n].x,pnts[(i+1) mod n].y,clr);
end;

procedure Ellipse(Bmp:TFastRGB;cx,cy,Rx,Ry:Integer;clr:TFColor);
var
Rx2,Ry2,
twoRx2,
twoRy2,
p,x,y,
px,py:  Integer;
begin
  Rx2:=Rx*Rx;    Ry2:=Ry*Ry;
  twoRx2:=2*Rx2; twoRy2:=2*Ry2;
  x:=0;          y:=Ry;
  px:=0;         py:=twoRx2*y;

  Bmp.Pixels[cy+y,cx+x]:=clr;
  Bmp.Pixels[cy+y,cx-x]:=clr;
  Bmp.Pixels[cy-y,cx+x]:=clr;
  Bmp.Pixels[cy-y,cx-x]:=clr;

  p:=Ry2-(Rx2*Ry)+(Rx2 div 4);
  while px<py do
  begin
    Inc(x);
    Inc(px,twoRy2);
    if p<0 then Inc(p,Ry2+px)else
    begin
      Dec(y);
      Dec(py,twoRx2);
      Inc(p,Ry2+px-py);
    end;
    Bmp.Pixels[cy+y,cx+x]:=clr;
    Bmp.Pixels[cy+y,cx-x]:=clr;
    Bmp.Pixels[cy-y,cx+x]:=clr;
    Bmp.Pixels[cy-y,cx-x]:=clr;
  end;

  p:=Round(Ry2*(x+0.5)*(x+0.5)+Rx2*(y-1)*(y-1)-Rx2*Ry2);
  while y>0 do
  begin
    Dec(y);
    Dec(py,twoRx2);
    if p>0 then Inc(p,Rx2-py)else
    begin
      Inc(x);
      Inc(px,twoRy2);
      Inc(p,Rx2-py+px);
    end;
    Bmp.Pixels[cy+y,cx+x]:=clr;
    Bmp.Pixels[cy+y,cx-x]:=clr;
    Bmp.Pixels[cy-y,cx+x]:=clr;
    Bmp.Pixels[cy-y,cx-x]:=clr;
  end;
end;

end.
