unit FastRGB;

  //  TFastRGB
  //    Gordon Alex Cowie <gfody@jps.net>
  //    www.jps.net/gfody
  //    shared properties for TFastBMP,TFastDDB,TFast256

interface

type
  TFColor  = record b,g,r:Byte end;
  PFColor  =^TFColor;
  TLine    = array[0..0]of TFColor;
  PLine    =^TLine;
  TPLines  = array[0..0]of PLine;
  PPLines  =^TPLines;

TFastRGB=class
  Gap,     // RowInc - Width
  RowInc,  // width in bytes
  Size,    // size of Bits
  Width,   // width in pixels
  Height:     Integer;
  Pixels:     PPLines;
  Bits:       Pointer;
  procedure   SetSize(fWidth,fHeight:Integer); virtual; abstract;
  procedure   Draw(fdc,x,y:Integer); virtual; abstract;
  procedure   Stretch(fdc,x,y,w,h:Integer); virtual; abstract;
  procedure   DrawRect(fdc,x,y,w,h,sx,sy:Integer); virtual; abstract;
  procedure   StretchRect(fdc,x,y,w,h,sx,sy,sw,sh:Integer); virtual; abstract;
  procedure   TileDraw(fdc,x,y,w,h:Integer); virtual; abstract;
  procedure   Resize(Dst:TFastRGB); virtual; abstract;
  procedure   SmoothResize(Dst:TFastRGB); virtual; abstract;
  procedure   CopyRect(Dst:TFastRGB;x,y,w,h,sx,sy:Integer); virtual; abstract;
  procedure   Tile(Dst:TFastRGB); virtual; abstract;
end;

const //colors dur
  tfBlack   : TFColor=(b:0;g:0;r:0);
  tfMaroon  : TFColor=(b:0;g:0;r:128);
  tfGreen   : TFColor=(b:0;g:128;r:0);
  tfOlive   : TFColor=(b:0;g:128;r:128);
  tfNavy    : TFColor=(b:128;g:0;r:0);
  tfPurple  : TFColor=(b:128;g:0;r:128);
  tfTeal    : TFColor=(b:128;g:128;r:0);
  tfGray    : TFColor=(b:128;g:128;r:128);
  tfSilver  : TFColor=(b:192;g:192;r:192);
  tfRed     : TFColor=(b:0;g:0;r:255);
  tfLime    : TFColor=(b:0;g:255;r:0);
  tfYellow  : TFColor=(b:0;g:255;r:255);
  tfBlue    : TFColor=(b:255;g:0;r:0);
  tfFuchsia : TFColor=(b:255;g:0;r:255);
  tfAqua    : TFColor=(b:255;g:255;r:0);
  tfLtGray  : TFColor=(b:192;g:192;r:192);
  tfDkGray  : TFColor=(b:128;g:128;r:128);
  tfWhite   : TFColor=(b:255;g:255;r:255);

function FRGB(r,g,b:Byte):TFColor;
function IntToColor(i:Integer):TFColor;
function IntToByte(i:Integer):Byte;
function TrimInt(i,Min,Max:Integer):Integer;

implementation

function FRGB(r,g,b:Byte):TFColor;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
end;

function IntToColor(i:Integer):TFColor;
begin
  Result.b:=i shr 16;
  Result.g:=i shr 8;
  Result.r:=i;
end;

function IntToByte(i:Integer):Byte;
begin
  if      i>255 then Result:=255
  else if i<0   then Result:=0
  else               Result:=i;
end;

function TrimInt(i,Min,Max:Integer):Integer;
begin
  if      i>Max then Result:=Max
  else if i<Min then Result:=Min
  else               Result:=i;
end;

end.
