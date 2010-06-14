
(*

       Scanlines.pas, Sep 2003    (Delphi 7)

       Copyright Chris Willig 2003, All Rights Reserved.
       May be used freely for non-commercial purposes.

       chris@5thElephant.com

       ******   RotateBmp() uses code copyrighted by Earl F. Glynn   ******

                SmoothResize() and GrayScale() use code adapted from a
                newsgroup example posted by Charles Hacker


           Uses pointers to access TBitmap.Scanline[], roughly 3 times faster
           than accessing Scanline[] directly in a typical looping routine.


*)

unit Scanlines;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics;

type
  TRGBArray = ARRAY[0..32767] OF TRGBTriple; //pf24bit
  pRGBArray = ^TRGBArray;

  //  TScanlines is a wrapper for accessing scanlines with pointers.
  //    see BitmapsEqual() and RotateBmp() for examples.
  TScanlines = class
  private
    FScanLine0 : PByte;
    FScanLineIncrement : integer;
    FMaxRow : integer;
    function GetRowPtr(Index: integer): PByte;
  public
    constructor Create(Bitmap: TBitmap);
    destructor Destroy; override;

    property RowPtr[Index: Integer]: PByte read GetRowPtr; default;
  end;

  TrgbaProc = procedure(pRGBA: pRGBArray; const Width: integer; var Dun: boolean) stdcall;
  TpbaProc = procedure(pB: PByteArray; const Width: integer; var Dun: boolean) stdcall;

  procedure ScanLinesRGBA(Bitmap: TBitmap; rgbaProc: TrgbaProc);
  procedure ScanLinesPBA(Bitmap: TBitmap; pbaProc: TpbaProc);

  procedure SmoothResize(Bitmap: TBitmap; NuWidth, NuHeight: integer);
  procedure GrayScale(Bitmap: TBitmap; const TVGrayScale: boolean = false);
  procedure ReplaceColor(Bitmap: TBitmap; OldColor, NewColor: TColorref);
  procedure GetMask(Bitmap, Mask: TBitmap; const InvertedMask: boolean = false);
  function BitmapsEqual(Bitmap1, Bitmap2: TBitmap): boolean;
  procedure RotateBmp(Bitmap: TBitmap; Angle: integer; const Clockwise: boolean = true);
  function CropRect(Bitmap: TBitmap): TRect; overload;
  function CropRect(Bitmap: TBitmap; CropColor: TColor): TRect; overload;

  function ColorToRGBTriple(Color: TColor): TRGBTriple;
  function RGBTripleToColor(RGBT: TRGBTriple): TColor;

implementation

// TScanlines...

constructor TScanlines.Create(Bitmap: TBitmap);
begin
  inherited Create;

  FScanLine0 := nil;
  FScanLineIncrement := 0;
  FMaxRow := 0;

  if Bitmap <> nil then begin
    FScanLine0 := Bitmap.ScanLine[0];
    FScanLineIncrement := integer(Bitmap.Scanline[1]) -integer(FScanLine0);
    FMaxRow := Bitmap.Height;
  end;
end;

destructor TScanlines.Destroy;
begin
  inherited;
end;

function TScanlines.GetRowPtr(Index: integer): PByte;
begin
  if (Index >= 0) and (Index < FMaxRow) then begin
    result := FScanLine0;
    Inc(result, FScanLineIncrement *Index);
  end else
    result := nil;
end;

// ...TScanlines


procedure ScanLinesRGBA(Bitmap: TBitmap; rgbaProc: TrgbaProc);
var
  ScanlinePtr : PByte;
  ScanlineIncrement : integer;
  LastScanline : PByte;
  Dun : boolean;
  X : integer;

  Line: pRGBArray;
begin
  Assert(Bitmap.PixelFormat = pf24bit);

  if Assigned(rgbaProc) then begin
    Dun := false;
    X := Bitmap.Width;

    ScanlinePtr := Bitmap.Scanline[0];
    ScanlineIncrement := integer(Bitmap.Scanline[1]) - integer(ScanlinePtr);
    LastScanline := ScanlinePtr;
    Inc(LastScanLine, ScanlineIncrement  * Bitmap.Height);

    repeat
      Line := pRGBArray(ScanLinePtr);

      rgbaProc( Line, X, Dun );

      Inc(ScanlinePtr, ScanlineIncrement);  // move to the next scanline
    until (ScanlinePtr = LastScanline) or Dun;

  end;
end;

procedure ScanLinesPBA(Bitmap: TBitmap; pbaProc: TpbaProc);
var
  ScanlinePtr : PByte;
  ScanlineIncrement : integer;
  LastScanline : PByte;
  Dun : boolean;
  X : integer;

  Line: PByteArray;
begin
  Assert(Bitmap.PixelFormat = pf24bit);

  if Assigned(pbaProc) then begin
    Dun := false;
    X := Bitmap.Width;

    ScanlinePtr := Bitmap.Scanline[0];
    ScanlineIncrement := integer(Bitmap.Scanline[1]) - integer(ScanlinePtr);
    LastScanline := ScanlinePtr;
    Inc(LastScanLine, ScanlineIncrement  * Bitmap.Height);

    repeat
      Line := PByteArray(ScanLinePtr);

      pbaProc( Line, X, Dun );

      Inc(ScanlinePtr, ScanlineIncrement);  // move to the next scanline
    until (ScanlinePtr = LastScanline) or Dun;

  end;
end;

//
//   SmoothResize() uses code adapted from a newsgroup example posted
//   by Charles Hacker
//
procedure SmoothResize(Bitmap: TBitmap; NuWidth, NuHeight: integer);
var
  xscale, yscale         : Single;
  sfrom_y, sfrom_x       : Single;
  ifrom_y, ifrom_x       : Integer;
  to_y, to_x             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue               : Integer;
  total_red, total_green : Single;
  total_blue             : Single;
  ix, iy                 : Integer;
  bTmp : TBitmap;
  sli, slo : pRGBArray;

  //pointers for scanline access
  liPByte,
  loPByte,
  p : PByte;
  //offset increment
  liSize,
  loSize : integer;
begin
  Assert(Bitmap.PixelFormat = pf24bit);

  Bitmap.PixelFormat := pf24bit;
  bTmp := TBitmap.Create;
  bTmp.PixelFormat := pf24bit;
  bTmp.Width := NuWidth;
  bTmp.Height := NuHeight;
  xscale := bTmp.Width / (Bitmap.Width-1);
  yscale := bTmp.Height / (Bitmap.Height-1);

  liPByte := Bitmap.Scanline[0];
  liSize := integer(Bitmap.Scanline[1]) -integer(liPByte);

  loPByte := bTmp.Scanline[0];
  loSize := integer(bTmp.Scanline[1]) -integer(loPByte);

  for to_y := 0 to bTmp.Height-1 do begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];

    for to_x := 0 to bTmp.Width-1 do begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];
      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;

      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          p := liPByte;
          Inc(p, liSize *(ifrom_y + iy));

          sli := pRGBArray(p);

          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;

          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
        end;
      end;

      p := loPByte;
      Inc(p, loSize *to_y);

      slo := pRGBArray(p);

      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);

    end;

  end;
  Bitmap.Width := bTmp.Width;
  Bitmap.Height := bTmp.Height;
  Bitmap.Canvas.Draw(0,0,bTmp);
  bTmp.Free;
end;


       //
       //   _GrayScale() and _TVGrayScale() uses code adapted from a newsgroup example posted
       //   by Charles Hacker
       //

       procedure _GrayScale(pB: PByteArray; const Width: integer; var Dun: boolean); stdcall;
       var
         X : integer;
       begin
         for X := 0 to Width -1 do begin
           // Linear Greyscale
           pB[X*3] := (pB[X*3] + pB[X*3+1] + pB[X*3+2]) div 3;
           // TV Greyscale
           //    pB[X*3]:= ROUND(0.299*pB[X*3] + 0.587*pB[X*3+1] +0.114*pB[X*3+2]);
           pB[X*3+1] := pB[X*3];
           pB[X*3+2] := pB[X*3];
         end;
       end;

       procedure _TVGrayScale(pB: PByteArray; const Width: integer; var Dun: boolean); stdcall;
       var
         X : integer;
       begin
         for X := 0 to Width -1 do begin
           // Linear Greyscale
           //pB[X*3] := (pB[X*3] + pB[X*3+1] + pB[X*3+2]) div 3;
           // TV Greyscale
           pB[X*3]:= ROUND(0.299*pB[X*3] + 0.587*pB[X*3+1] +0.114*pB[X*3+2]);
           pB[X*3+1] := pB[X*3];
           pB[X*3+2] := pB[X*3];
         end;
       end;

procedure GrayScale(Bitmap: TBitmap; const TVGrayScale: boolean = false);
begin
  Assert(Bitmap.PixelFormat = pf24bit);

  if TVGrayScale then
    ScanLinesPBA(Bitmap, @_TVGrayScale)
  else
    ScanLinesPBA(Bitmap, @_GrayScale);
end;

var
  rgbt_1, rgbt_2 : TRGBTriple;

       procedure _RepColor(pRGBA: pRGBArray; const Width: integer; var Dun: boolean); stdcall;
       var
         X : integer;
       begin
         for X := 0 to Width -1 do begin
           with pRGBA[X] do begin
             if (rgbtRed = rgbt_1.rgbtRed) and (rgbtGreen = rgbt_1.rgbtGreen) and (rgbtBlue = rgbt_1.rgbtBlue) then begin
               rgbtRed   := rgbt_2.rgbtRed;
               rgbtGreen := rgbt_2.rgbtGreen;
               rgbtBlue  := rgbt_2.rgbtBlue;
             end;
           end;
         end;
       end;

procedure ReplaceColor(Bitmap: TBitmap; OldColor, NewColor: TColorref);
begin
  if OldColor = NewColor then
    exit;

  Assert(Bitmap.PixelFormat = pf24bit);

  rgbt_1 := ColorToRGBTriple(OldColor);
  rgbt_2 := ColorToRGBTriple(NewColor);

  ScanLinesRGBA(Bitmap, @_RepColor);
end;

       procedure _GetMask(pRGBA: pRGBArray; const Width: integer; var Dun: boolean); stdcall;
       var
         X : integer;
       begin
         for X := 0 to Width -1 do begin
           with pRGBA[X] do begin
             if (rgbtRed = rgbt_1.rgbtRed) and (rgbtGreen = rgbt_1.rgbtGreen) and (rgbtBlue = rgbt_1.rgbtBlue) then begin
               //bitmap's transparent color
               rgbtRed   := 255;
               rgbtGreen := 255;
               rgbtBlue  := 255;
             end else begin
               rgbtRed   := 0;
               rgbtGreen := 0;
               rgbtBlue  := 0;
             end;
           end;
         end;
       end;

       procedure _GetInvertedMask(pRGBA: pRGBArray; const Width: integer; var Dun: boolean); stdcall;
       var
         X : integer;
       begin
         for X := 0 to Width -1 do begin
           with pRGBA[X] do begin
             if (rgbtRed = rgbt_1.rgbtRed) and (rgbtGreen = rgbt_1.rgbtGreen) and (rgbtBlue = rgbt_1.rgbtBlue) then begin
               //bitmap's transparent color
               rgbtRed   := 0;
               rgbtGreen := 0;
               rgbtBlue  := 0;
             end else begin
               rgbtRed   := 255;
               rgbtGreen := 255;
               rgbtBlue  := 255;
             end;
           end;
         end;
       end;

procedure GetMask(Bitmap, Mask: TBitmap; const InvertedMask: boolean = false);
var
  cl : TColorref;
begin
  Mask.Assign(Bitmap);
  Mask.PixelFormat := pf24bit;

  cl := Bitmap.Canvas.Pixels[0, Bitmap.Height -1];
  rgbt_1 := ColorToRGBTriple(cl);

  if InvertedMask then
    ScanLinesRGBA(Mask, @_GetInvertedMask)
  else
    ScanLinesRGBA(Mask, @_GetMask);
end;

function BitmapsEqual(Bitmap1, Bitmap2: TBitmap): boolean;
var
  SL1, SL2 : TScanLines;
  Line1: pRGBArray;
  Line2: pRGBArray;
  X, Y : integer;
begin
  Assert((Bitmap1.PixelFormat = pf24bit) and (Bitmap2.PixelFormat = pf24bit));

  result := (Bitmap1.Width = Bitmap2.Width) and (Bitmap1.Height = Bitmap2.Height);

  if result then begin

    SL1 := TScanLines.Create(Bitmap1);
    SL2 := TScanLines.Create(Bitmap2);
    try
      Y := 0;
      while (Y < Bitmap1.Height) and result do begin
        Line1 := pRGBArray(SL1[Y]);
        Line2 := pRGBArray(SL2[Y]);

        for X := 0 to Bitmap1.Width -1 do begin
          result := (Line1[X].rgbtRed   = Line2[X].rgbtRed) and
                    (Line1[X].rgbtBlue  = Line2[X].rgbtBlue) and
                    (Line1[X].rgbtGreen = Line2[X].rgbtGreen);

          if not result then
            break;
        end;

        Inc(Y);
      end;
    finally
      SL2.Free;
      SL1.Free;
    end;

  end;
end;

//  Following procedure for rotation has been adapted from
//
//      FlipReverseRotate Library
//
//      Copyright (C) 1998, Earl F. Glynn.  All Rights Reserved.
//      May be used freely for non-comercial use.
//

// Rotate 24-bits/pixel Bitmap any multiple of 90 degrees.
procedure RotateBmp(Bitmap: TBitmap; Angle: integer; const Clockwise: boolean = true);
var
  bmp : TBitmap;
  SL1, SL2 : TScanlines;

    FUNCTION Rotate90DegreesCounterClockwise:  TBitmap;
      VAR
        i     :  INTEGER;
        j     :  INTEGER;
        rowIn :  pRGBArray;
    BEGIN
      RESULT := TBitmap.Create;
      RESULT.Width  := Bitmap.Height;
      RESULT.Height := Bitmap.Width;
      RESULT.PixelFormat := Bitmap.PixelFormat;    // only pf24bit for now

      SL1 := TScanlines.Create(Bitmap);
      SL2 := TScanlines.Create(RESULT);
      try
        // Out[j, Right - i - 1] = In[i, j]
        FOR  j := 0 TO Bitmap.Height - 1 DO
        BEGIN
          rowIn := pRGBArray(SL1[j]);

          FOR i := 0 TO Bitmap.Width - 1 DO
            pRGBArray(SL2[Bitmap.Width - i - 1])[j] := rowIn[i];
        END
      finally
        SL2.Free;
        SL1.Free;
      end;
    END {Rotate90DegreesCounterClockwise};


    // Could use Rotate90DegreesCounterClockwise twice to get a
    // Rotate180DegreesCounterClockwise.  Rotating 180 degrees is the same
    // as a Flip and Reverse
    FUNCTION Rotate180DegreesCounterClockwise:  TBitmap;
      VAR
        i     :  INTEGER;
        j     :  INTEGER;
        rowIn :  pRGBArray;
        rowOut:  pRGBArray;
    BEGIN
      RESULT := TBitmap.Create;
      RESULT.Width  := Bitmap.Width;
      RESULT.Height := Bitmap.Height;
      RESULT.PixelFormat := Bitmap.PixelFormat;    // only pf24bit for now

      SL1 := TScanlines.Create(Bitmap);
      SL2 := TScanlines.Create(RESULT);
      try

        // Out[Right - i - 1, Bottom - j - 1] = In[i, j]
        FOR  j := 0 TO Bitmap.Height - 1 DO
        BEGIN
          rowIn := pRGBArray(SL1[j]);

          rowOut := pRGBArray(SL2[Bitmap.Height - j - 1]);

          FOR i := 0 TO Bitmap.Width - 1 DO
            rowOut[Bitmap.Width - i - 1] := rowIn[i]
        END

      finally
        SL2.Free;
        SL1.Free;
      end;

    END {Rotate180DegreesCounterClockwise};


    // Could use Rotate90DegreesCounterClockwise three times to get a
    // Rotate270DegreesCounterClockwise
    FUNCTION Rotate270DegreesCounterClockwise:  TBitmap;
      VAR
        i    :  INTEGER;
        j    :  INTEGER;
        rowIn:  pRGBArray;
    BEGIN
      RESULT := TBitmap.Create;
      RESULT.Width  := Bitmap.Height;
      RESULT.Height := Bitmap.Width;
      RESULT.PixelFormat := Bitmap.PixelFormat;    // only pf24bit for now

      SL1 := TScanlines.Create(Bitmap);
      SL2 := TScanlines.Create(RESULT);
      try

        // Out[Bottom - j - 1, i] = In[i, j]
        FOR  j := 0 TO Bitmap.Height - 1 DO
        BEGIN
          rowIn := pRGBArray(SL1[j]);

          FOR i := 0 TO Bitmap.Width - 1 DO
            pRGBArray(SL2[i])[Bitmap.Height - j - 1] := rowIn[i];
        END

      finally
        SL2.Free;
        SL1.Free;
      end;
    END {Rotate270DegreesCounterClockwise};


begin
  Assert(Bitmap.PixelFormat = pf24bit);

  bmp := TBitmap.Create;
  try
    if Clockwise then begin
      CASE (angle DIV 90) MOD 4 OF
        //0:  bmp := SimpleCopy;
        1:  bmp := Rotate270DegreesCounterClockwise;
        2:  bmp := Rotate180DegreesCounterClockwise;
        3:  bmp := Rotate90DegreesCounterClockwise
        ELSE
          exit;
      END;
    end else begin
      CASE (angle DIV 90) MOD 4 OF
        //0:  bmp := SimpleCopy;
        1:  bmp := Rotate90DegreesCounterClockwise;
        2:  bmp := Rotate180DegreesCounterClockwise;
        3:  bmp := Rotate270DegreesCounterClockwise
        ELSE
          exit;
      END;
    end;

    Bitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

           function _CropRect(Bitmap: TBitmap; C: TColor): TRect;
           var
             ScanlinePtr : PByte;
             ScanlineIncrement : integer;
             LastScanline : PByte;
             X : integer;

             Line: pRGBArray;
             AColor : TColor;
             r, g, b : integer;
             x1, x2, y1, y2, x3, x4, y3, n : integer;
           begin
             AColor := ColorToRGB(C);

             r := GetRValue(AColor);
             g := GetGValue(AColor);
             b := GetBValue(AColor);

             X := Bitmap.Width;

             ScanlinePtr := Bitmap.Scanline[0];
             ScanlineIncrement := integer(Bitmap.Scanline[1]) - integer(ScanlinePtr);
             LastScanline := ScanlinePtr;
             Inc(LastScanLine, ScanlineIncrement  * Bitmap.Height);

             x1 := Bitmap.Width;
             x2 := 0;
             y1 := 0;
             y2 := Bitmap.Height;
             y3 := 0;
             repeat
               Line := pRGBArray(ScanLinePtr);

               x3 := -1;
               x4 := -1;
               n := 0;
               while (n < X) and (x3 < 0) do begin
                 if (Line[n].rgbtRed <> r) or
                    (Line[n].rgbtGreen <> g) or
                    (Line[n].rgbtBlue <> b) then
                      x3 := n;

                 Inc(n);
               end;

               if x3 > -1 then begin
                 n := X -1;
                 while (n > -1) and (x4 < 0) do begin
                   if (Line[n].rgbtRed <> r) or
                      (Line[n].rgbtGreen <> g) or
                      (Line[n].rgbtBlue <> b) then
                        x4 := n;

                   Dec(n);
                 end;
               end;

               if (x3 > -1) and (x3 < x1) then x1 := x3;
               if (x4 > -1) and (x4 > x2) then x2 := x4;

               if (x3 > -1) or (x4 > -1) then begin
                 if y1 = 0 then
                   y1 := y3;
                 y2 := y3;
               end;


               Inc(ScanlinePtr, ScanlineIncrement);  // move to the next scanline
               Inc(y3);
             until (ScanlinePtr = LastScanline);


             result := Rect(x1, y1, x2 +1, y2);
             if IsRectEmpty(result) then
               result := Rect(0, 0, Bitmap.Width, Bitmap.Height);
           end;

function CropRect(Bitmap: TBitmap): TRect; //overload;
begin
  Assert(Bitmap.PixelFormat = pf24bit); // ! must be pf24bit
  result := _CropRect( Bitmap, Bitmap.Canvas.Pixels[0, Bitmap.Height -1] );
end;

function CropRect(Bitmap: TBitmap; CropColor: TColor): TRect; //overload;
begin
  Assert(Bitmap.PixelFormat = pf24bit); // ! must be pf24bit
  result := _CropRect( Bitmap, CropColor );
end;

function ColorToRGBTriple(Color: TColor): TRGBTriple;
begin
  result.rgbtRed   := Color AND $000000FF;
  result.rgbtGreen := (Color AND $0000FF00) SHR 8;
  result.rgbtBlue  := (Color AND $00FF0000) SHR 16;
end;

function RGBTripleToColor(RGBT: TRGBTriple): TColor;
begin
  result := RGBT.rgbtRed OR (RGBT.rgbtGreen SHL 8) OR (RGBT.rgbtBlue SHL 16);
end;

end.