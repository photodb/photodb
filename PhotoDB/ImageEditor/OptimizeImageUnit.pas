unit OptimizeImageUnit;

interface

uses
  Windows, Graphics, GBlur2, GraphicsBaseTypes, ScanlinesFX, uEditorTypes;

type
  TConvolutionMatrix = record
    Matrix: array [0 .. 24] of Integer;
    Devider: Integer;
  end;

type
  TRGBArray = ARRAY[0..32677] OF Windows.TRGBTriple;   // bitmap element (API windows)
  pRGBArray = ^TRGBArray;     // type pointer to 3 bytes array

  TArPRGBArray = array of PRGBArray;

procedure OptimizeImage(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);

Procedure MatrixEffectsW(fa,fb : integer; Tscan3,Tscan2 : TArPRGBArray; w1,h1 : integer; M : TConvolutionMatrix; CallBack : TBaseEffectCallBackProc = nil);
Function Filterchoice(Numero : integer): TConvolutionMatrix;


implementation

Procedure MatrixEffectsW(fa,fb : integer; Tscan3,Tscan2 : TArPRGBArray; w1,h1 : integer; M : TConvolutionMatrix; CallBack : TBaseEffectCallBackProc = nil);

const
  M3 : array[0..24] of integer = (1,1,1,1,1,   // to detect if matrix is 3x3
                                  1,0,0,0,1,   // or 5x5
                                  1,0,0,0,1,
                                  1,0,0,0,1,
                                  1,1,1,1,1);
var
  x, y : integer;
  R, G, B : integer;
  RR, GG , BB : integer;
  i : integer;                    // index  of matrix coefficients
  ix, iy, dx, dy, d : integer;    // positions of sliding matrix
  Terminating : Boolean;
begin
  Terminating:=false;
  if M.Devider = 0 then M.Devider := 1;
  dx := 0;
  For i := 0 to 24 do if (M.Matrix[i] AND M3[i]) <> 0 then inc(dx);
  if dx = 0 then d := 1 else d := 2 ;  // offset from center

 For y := 0 to h1 do
  begin
    for x := 0 to w1 do
    begin
      RR := 0; GG := 0; BB := 0;
      for dy := -d to d do
      for dx := -d to d do
      begin
        // current pixel location
        iy := y+dy;
        ix := x+dx;
        if (iy >= 1) and (iy <= h1) and  // check limits
           (ix >= 1) and (ix <= w1) then

        begin
          R := Tscan3[iy, ix].RgbtRed;
          G := Tscan3[iy, ix].Rgbtgreen;
          B := Tscan3[iy, ix].Rgbtblue;
        end
        else
        begin
          R := Tscan3[y, x].RgbtRed;  // outside : original pixel
          G := Tscan3[y, x].Rgbtgreen;
          B := Tscan3[y, x].Rgbtblue;
        end;
        i := 12+dy*5+dx;        // matrix factor position
        RR := RR + R * M.Matrix[i];   // multiply color values bu matrix factor
        GG := GG + G * M.Matrix[i];
        BB := BB + B * M.Matrix[i];
      end;
      RR := RR div M.Devider;    // divide results to preserve luminance
      GG := GG div M.Devider;
      BB := BB div M.Devider;
      if RR > 255 then RR := 255 else if RR < 0 then RR := 0; // check color bounds
      if GG > 255 then GG := 255 else if GG < 0 then GG := 0;
      if BB > 255 then BB := 255 else if BB < 0 then BB := 0;
      Tscan2[y,x].rgbtred   := RR;  // resulting pixel
      Tscan2[y,x].rgbtgreen := GG;
      Tscan2[y,x].rgbtblue  := BB;
    end;

   if y mod 50=0 then
   If Assigned(CallBack) then CallBack(fa+Round(fb*y/(h1+1)),Terminating);
   if Terminating then Break;

  end;
end;

Function Filterchoice(Numero : integer): TConvolutionMatrix;
const
 // Constants for convolution (filter) matrix 3x3 ou 5x5
 // used to apply some effect on a picture. The current pixel (matrix center)
 // is modified by the next pixels. The color values of each pixel are
 // multiplied by the corresponding matrix value and added to a counter.
 // This sum is then divided by the divisor to give the new "center" pixel
 // color value. This allows integer computing.
 // Last parameter is the divisor to obtain : Sum of elements / divisor = 1
 // to preserve the pixel luminance.
 // ** marked fonctions are used in this program, others are samples
F0 : array[0..9] of integer = ( 0, 0, 0,  0, 1, 0,  0, 0, 0,  1); // neutral
F1 : array[0..9] of integer = ( 0, 0, 0,  0, 1, 1,  0, 1, 1,  4); // anti Alias
F2 : array[0..9] of integer = ( 1, 2, 1,  2,20, 2,  1, 2, 1, 32); // ** blur
F3 : array[0..25] of integer =
    (1,2,4,2,1, 2,4,6,4,2, 4,6,8,6,4, 2,4,6,4,2, 1,2,4,2,1, 84);  // blur more
F4 : array[0..9] of integer = (-1,-2,-1, -2,28,-2, -1,-2,-1, 16); // ** sharpen
F5 : array[0..9] of integer = ( 0,-1, 0, -1, 6,-1,  0,-1, 0,  2); // sharpen more
F6 : array[0..9] of integer = (-5,-5,-5, -5,42,-5, -5,-5,-5,  2); // Lithography
F7 : array[0..9] of integer = (-1,-1,-1, -1, 9,-1, -1,-1,-1,  1); // Hi pass
F8 : array[0..9] of integer = ( 0,-1, 0, -1, 1, 1,  0, 1, 0,  1); // emboss
F9 : array[0..9] of integer = ( 0, 0, 0,  0, 1, 0,  0, 0, 0,  1); // engrave
FA : array[0..9] of integer = ( 1, 1, 1,  1,-8, 1,  1, 1, 1,  1); // lines
FB : array[0..9] of integer = ( 4, 4, 4,  4,-33,4,  4, 4, 4,  1); // ** edges
FC : array[0..9] of integer = ( 0,-1,-1,  0, 2, 0,  0, 0, 0,  1); // sculpture

  // load 3x3 matrix
  Procedure F9Load(af : array of integer);
  var
    i, j : integer;
  begin
    for j := 0 to 24 do Result.Matrix[j] := 0;
    i := 0;
    for j :=  6 to  8 do begin Result.Matrix[j] := af[i]; inc(i); end;
    for j := 11 to 13 do begin Result.Matrix[j] := af[i]; inc(i); end;
    for j := 16 to 18 do begin Result.Matrix[j] := af[i]; inc(i); end;
    Result.Devider := af[9];
  end;
  // load 5x5 matrix
  Procedure F25load(af : array of integer);
  var
    i : integer;
  begin
    for i := 0 to 24 do Result.Matrix[i] := af[i];
    Result.Devider := af[25];
  end;

begin
  case numero of
  0 : F9Load(F0);  // Neutral
  1 : F9Load(F1);  // anti allias
  2 : F9Load(F2);  // blur
  3 : F25load(F3); // blur more
  4 : F9Load(F4);  // sharpen
  5 : F9Load(F5);  // sharpen more
  6 : F9Load(F6);  // Lithography
  7 : F9Load(F7);  // Hi pass
  8 : F9Load(F8);  // emboss
  9 : F9Load(F9);  // engrave
  10: F9Load(FA);  // lines
  11: F9Load(FB);  // edges
  12: F9Load(FC);  // sculpture
  end;
end;

procedure OptimizeImage(S,D : TBitmap; CallBack : TBaseEffectCallBackProc = nil);
var
  x, y : integer;
  R3,G3,B3, R2,G2,B2, R4: integer;
  Tscan2,Tscan3,Tscan4 : TArPRGBArray;
  Terminating : boolean;
  Temp1 : TBitmap;
begin
  Terminating:=false;
  Temp1 := TBitmap.Create;
  Temp1.PixelFormat:=pf24bit;
  S.PixelFormat:=pf24bit;
  D.Assign(S);
  if Assigned(CallBack) then CallBack(5,Terminating);
  D.PixelFormat:=pf24bit;
  SetLength(Tscan2,S.height);
  SetLength(Tscan3,S.height);
  SetLength(Tscan4,S.height);
  Temp1.Width:=S.Width;
  Temp1.Height:=S.Height;
  For y := 0 to S.height-1 do
  begin
    Tscan2[y] := D.ScanLine[y];
    Tscan3[y] := S.ScanLine[y];
    Tscan4[y] := Temp1.ScanLine[y];
  end;
  MatrixEffectsW(5,20,Tscan3,Tscan4,S.Width-1,S.Height-1,Filterchoice(11));
  GBlurWX(25,20,Temp1,GBlur2.TArPRGBArray(Tscan4),2,CallBack);
  GBlurWX(45,20,D,GBlur2.TArPRGBArray(Tscan2),3,CallBack);
  For y := 0 to S.height-1 do
  begin
    for x := 0 to S.width-1 do
    begin
      R3 :=  Tscan3[y,x].Rgbtred;    // current image
      G3 :=  Tscan3[y,x].Rgbtgreen;
      B3 :=  Tscan3[y,x].Rgbtblue;
      R2 :=  Tscan2[y,x].Rgbtred;    // blurred image
      G2 :=  Tscan2[y,x].Rgbtgreen;
      B2 :=  Tscan2[y,x].Rgbtblue;
      R4 :=  Tscan4[y,x].Rgbtred;    // mask
      if R4 > 0 then
      begin
        Tscan2[y,x].Rgbtred   := (R2+R3*3) div 4;   // edges
        Tscan2[y,x].Rgbtgreen := (G2+G3*3) div 4;
        Tscan2[y,x].Rgbtblue  := (B2+B3*3) div 4;
      end
      else
      begin
        Tscan2[y,x].Rgbtred   := (R2*7+R3) div 8;    // blur areas
        Tscan2[y,x].Rgbtgreen := (G2*7+G3) div 8;
        Tscan2[y,x].Rgbtblue  := (B2*7+B3) div 8;
      end;
    end;
     if y mod 50=0 then
     If Assigned(CallBack) then CallBack(65+Round(35*y/S.Height),Terminating);
     if Terminating then Break;
  end;
 Temp1.Free;
// Temp2.Free;
end;

end.
