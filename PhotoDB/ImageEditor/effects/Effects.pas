unit Effects;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Vcl.Graphics,
  Dmitry.Graphics.Types,
  Scanlines,
  uEditorTypes,
  uDBGraphicTypes,
  uMemory,
  uBitmapUtils;

procedure Inverse(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);

procedure ReplaceColorInImage(S,D : TBitmap; BaseColor, NewColor : TColor; Size, Level : Integer; CallBack : TProgressCallBackProc = nil); overload;

procedure GrayScaleImage(S,D : TBitmap; n : integer; CallBack : TProgressCallBackProc = nil); overload;
procedure GrayScaleImage(S,D : TBitmap; CallBack : TProgressCallBackProc = nil); overload;

procedure Sepia(S,D : TBitmap; Depth: Integer; CallBack : TProgressCallBackProc = nil); overload;
procedure Sepia(S,D : TBitmap; CallBack : TProgressCallBackProc = nil); overload;

procedure Dither(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);

procedure ChangeBrightness(S,D : TBitmap; Brightness: Integer); overload;
procedure ChangeBrightness(Image : TBitmap; Brightness: Integer); overload;
procedure ChangeBrightness(Image : TArPARGB; Width, Height : integer; Brightness: Integer); overload;

procedure WaveSin(S, D: TBitmap; Frequency, Length:  Integer; Hor: Boolean; BackColor: TColor; CallBack : TProgressCallBackProc = nil);
procedure PixelsEffect(S, D: TBitmap; Hor, Ver: Word; CallBack : TProgressCallBackProc = nil);
procedure Sharpen(S, D: TBitmap; alpha: Single; CallBack : TProgressCallBackProc = nil);
procedure Blocks(S, D: TBitmap; Hor, Ver, MaxOffset: Integer; BackColor: TColor);

procedure Gamma(S, D: TBitmap; L: Double); overload;
procedure Gamma(Image: TBitmap; L: Double); overload;

procedure SetRGBChannelValue(S, D: TBitmap; Red, Green, Blue: Integer); overload;
procedure SetRGBChannelValue(Image: TBitmap; Red, Green, Blue: Integer); overload;
procedure SetRGBChannelValue(Image: TArPARGB; Width, Height : integer; Red, Green, Blue: Integer); overload;

procedure Disorder(S, D: TBitmap; Hor, Ver: Integer; BackColor: TColor; CallBack : TProgressCallBackProc = nil); overload;
procedure Disorder(S, D: TBitmap; CallBack : TProgressCallBackProc = nil); overload;

procedure Contrast(S, D: TBitmap; Value: Extended; Local: Boolean); overload;
procedure Contrast(Image: TBitmap; Value: Extended; Local: Boolean); overload;
procedure Contrast(Image: TArPARGB; Width, Height : integer; Value: Extended; Local: Boolean); overload;
procedure SetContractBrightnessRGBChannelValue(ImageS, ImageD: TArPARGB; Width, Height: Integer; Contrast : Extended; var OverageBrightnss : Integer; Brightness, Red, Green, Blue: Integer); overload;

Procedure Colorize(S,D : TBitmap; Luma: Integer);

Procedure AutoLevels(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);
Procedure AutoColors(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);

function GistogrammRW(S: TBitmap; Rect: TRect; var CountR: int64): T255IntArray;

procedure Rotate90(S,D : tbitmap; CallBack : TProgressCallBackProc = nil);
procedure Rotate270(S,D : Tbitmap; CallBack : TProgressCallBackProc = nil);
procedure Rotate180(S,D : Tbitmap; CallBack : TProgressCallBackProc = nil);

procedure FlipHorizontal(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);
procedure FlipVertical(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);

procedure RotateBitmap(Bmp, Bitmap: TBitmap; Angle: Double; BackColor: TColor; CallBack : TProgressCallBackProc = nil);
//procedure SmoothResizeA(Width, Height : integer; S,D : TBitmap; CallBack : TProgressCallBackProc = nil);

procedure StrRotated(X, Y: Integer; arect: TRect; DC: HDC; Font: HFont; Str: string; Ang: Extended; Options: Cardinal);
procedure CoolDrawTextEx(bitmap:Tbitmap; text:string; Font: HFont; coolcount:integer; coolcolor:Tcolor; aRect : TRect; aType : integer; Options : Cardinal);

function GistogrammB(S : TBitmap; var Terminated : boolean; CallBack : TProgressCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function GistogrammG(S : TBitmap; var Terminated : boolean; CallBack : TProgressCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function GistogrammR(S : TBitmap; var Terminated : boolean; CallBack : TProgressCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;
function Gistogramma(S : TBitmap; var Terminated : boolean; CallBack : TProgressCallBackProc = nil; X : Extended =1; Y : Extended =0) : T255IntArray;

function GetGistogrammBitmap(Height: Integer; SBitmap: TBitmap; Options: Byte; var MinC, MaxC: Integer): TBitmap;
procedure GetGistogrammBitmapW(Height: Integer; Source: T255IntArray; var MinC, MaxC: Integer; Bitmap: TBitmap; Color: TColor);
procedure GetGistogrammBitmapWRGB(Height: Integer; SGray, SR, SG, SB: T255IntArray; var MinC, MaxC: Integer; Bitmap: TBitmap; BackColor: TColor);
function GetGistogrammBitmapX(Height,d : integer; G : T255IntArray; var MinC, MaxC : Integer) : TBitmap;

//new effects from ScineLineFX
procedure Emboss(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);
procedure AntiAlias(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);
procedure AddColorNoise(S, D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
procedure AddMonoNoise(S, D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
procedure FishEye(Bmp, Dst: TBitmap; xAmount: Integer; CallBack : TProgressCallBackProc = nil);
procedure Twist(Bmp, Dst: TBitmap; Amount: integer; CallBack : TProgressCallBackProc = nil);

procedure SplitBlur(S, D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
procedure SplitBlurW(D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);

procedure GaussianBlur(D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
procedure ProportionalSizeX(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);

implementation

procedure ProportionalSizeX(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
begin
  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

procedure ProportionalSize(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
begin
  if (AWidthToSize < AWidth) and (AHeightToSize < AHeight) then
    Exit;

  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

procedure Inverse(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
var
  I, J: Integer;
  PS, PD: PARGB;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      PD[J].R := 255 - PS[J].R;
      PD[J].G := 255 - PS[J].G;
      PD[J].B := 255 - PS[J].B;
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * I / S.Height), Terminating);
    if Terminating then
      Break;
  end;
end;

procedure GrayScaleImage(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
begin
  GrayScaleImage(S, D, 100, CallBack);
end;

procedure GrayScaleImage(S,D : TBitmap; N : integer; CallBack : TProgressCallBackProc = nil);
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

procedure Sepia(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);
begin
  Sepia(S, D, 20, CallBack);
end;

procedure Sepia(S, D: TBitmap; Depth: Integer; CallBack: TProgressCallBackProc = nil);
var
  Color2: Longint;
  R, G, B, Rr, Gg: Byte;
  I, J: Integer;
  Ps, Pd: PARGB;
  Terminating: Boolean;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      R := Ps[J].R;
      G := Ps[J].G;
      B := Ps[J].B;
      Color2 := (R + G + B) div 3;
      R := Color2;
      G := Color2;
      B := Color2;
      Rr := Min(255, R + (Depth * 2));
      Gg := Min(255, G + Depth);
      if Rr <= ((Depth * 2) - 1) then
        Rr := 255;
      if Gg <= (Depth - 1) then
        Gg := 255;
      Pd[J].R := Rr;
      Pd[J].G := Gg;
      Pd[J].B := B;
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * I / S.Height), Terminating);
    if Terminating then
      Break;
  end;
end;

procedure Dither(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);
var
  ScanlS, ScanlD: PColor3Array;
  Error1R, Error1G, Error1B, Error2R, Error2G, Error2B: PIntegerArray;
  X, Y: Integer;
  Dx: Integer;
  C, CD: TColor3;
  SR, SG, SB: Integer;
  DR, DG, DB: Integer;
  ER, EG, EB: Integer;
  Terminating: Boolean;

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
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  Error1R := AllocMem((S.Width + 2) * Sizeof(Integer));
  Error1G := AllocMem((S.Width + 2) * Sizeof(Integer));
  Error1B := AllocMem((S.Width + 2) * Sizeof(Integer));
  Error2R := AllocMem((S.Width + 2) * Sizeof(Integer));
  Error2G := AllocMem((S.Width + 2) * Sizeof(Integer));
  Error2B := AllocMem((S.Width + 2) * Sizeof(Integer));
  Dx := 1;
  Terminating := False;
  for Y := 0 to S.Height - 1 do
  begin
    ScanlS := S.ScanLine[Y];
    ScanlD := D.ScanLine[Y];
    if Dx > 0 then
      X := 0
    else
      X := S.Width - 1;
    while (X >= 0) and (X < S.Width) do
    begin
      C := ScanlS[X];
      SR := C.R;
      SG := C.G;
      SB := C.B;
      ER := Error1R[X + 1];
      // eG := error1G[x + 1];
      // eB := error1B[x + 1];
      DR := (SR * 16 + ER) div 16;
      // dG := (sR * 16 + eR) div 16;
      // dB := (sR * 16 + eR) div 16;
      DR := Clamp(DR, 0, 255) and (255 shl 4);
      DG := Clamp(DR, 0, 255) and (255 shl 4);
      DB := Clamp(DR, 0, 255) and (255 shl 4);
      CD.R := DR;
      CD.G := DG;
      CD.B := DB;
      ScanlD[X] := CD;
      ER := SR - DR;
      EG := SG - DG;
      EB := SB - DB;
      Inc(Error1R[X + 1 + Dx], (ER * 7)); { next }
      Inc(Error1G[X + 1 + Dx], (EG * 7));
      Inc(Error1B[X + 1 + Dx], (EB * 7));
      Inc(Error2R[X + 1], (ER * 5)); { top }
      Inc(Error2G[X + 1], (EG * 5));
      Inc(Error2B[X + 1], (EB * 5));
      Inc(Error2R[X + 1 + Dx], (ER * 1)); { diag forward }
      Inc(Error2G[X + 1 + Dx], (EG * 1));
      Inc(Error2B[X + 1 + Dx], (EB * 1));
      Inc(Error2R[X + 1 - Dx], (ER * 3)); { diag backward }
      Inc(Error2G[X + 1 - Dx], (EG * 3));
      Inc(Error2B[X + 1 - Dx], (EB * 3));
      Inc(X, Dx);
    end;
    Dx := Dx * -1;
    Swap(Error1R, Error2R);
    Swap(Error1G, Error2G);
    Swap(Error1B, Error2B);
    FillChar(Error2R^, Sizeof(Integer) * (S.Width + 2), 0);
    FillChar(Error2G^, Sizeof(Integer) * (S.Width + 2), 0);
    FillChar(Error2B^, Sizeof(Integer) * (S.Width + 2), 0);
    if Y mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * Y / S.Height), Terminating);
    if Terminating then
      Break;
  end;
  FreeMem(Error1R);
  FreeMem(Error1G);
  FreeMem(Error1B);
  FreeMem(Error2R);
  FreeMem(Error2G);
  FreeMem(Error2B);
end;

procedure ChangeBrightness(S, D: TBitmap; Brightness: Integer);
var
  LUT: array [Byte] of Byte;
  V, I: Integer;
  W, H, X, Y: Integer;
  LineSize: LongInt;
  PLineStartS, PLineStartD: PByte;
  Ps, Pd: PByte;
begin
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  for I := 0 to 255 do
  begin
    V := I + Brightness;
    if V < 0 then
      V := 0
    else if V > 255 then
      V := 255;
    LUT[I] := V;
  end;
  W := S.Width;
  H := S.Height - 1;
  PLineStartS := PByte(S.ScanLine[H]);
  PLineStartD := PByte(D.ScanLine[H]);
  LineSize := ((W * 3 + 3) div 4) * 4;
  W := W * 3 - 1;
  for Y := 0 to H do
  begin
    Ps := PLineStartS;
    Pd := PLineStartD;
    for X := 0 to W do
    begin
      Pd^ := LUT[Ps^];
      Inc(Ps);
      Inc(Pd);
    end;
    Inc(PLineStartS, LineSize);
    Inc(PLineStartD, LineSize);
  end;
end;

procedure ChangeBrightness(Image: TBitmap; Brightness: Integer);
var
  LUT: array [Byte] of Byte;
  V, I: Integer;
  W, H, X, Y: Integer;
  LineSize: LongInt;
  PLineStartD: PByte;
  Pd: PByte;
begin
  Image.PixelFormat := Pf24bit;
  for I := 0 to 255 do
  begin
    V := I + Brightness;
    if V < 0 then
      V := 0
    else if V > 255 then
      V := 255;
    LUT[I] := V;
  end;
  W := Image.Width;
  H := Image.Height - 1;
  PLineStartD := PByte(Image.ScanLine[H]);
  LineSize := ((W * 3 + 3) div 4) * 4;
  W := W * 3 - 1;
  for Y := 0 to H do
  begin
    Pd := PLineStartD;
    for X := 0 to W do
    begin
      Pd^ := LUT[Pd^];
      Inc(Pd);
    end;
    Inc(PLineStartD, LineSize);
  end;
end;

procedure ChangeBrightness(Image : TArPARGB; Width, Height : integer; Brightness: Integer);
var
  LUT: array [Byte] of Byte;
  V, I: Integer;
  X, Y: Integer;
begin
  for I := 0 to 255 do
  begin
    V := I + Brightness;
    if V < 0 then
      V := 0
    else if V > 255 then
      V := 255;
    LUT[I] := V;
  end;
  for Y := 0 to Height - 1 do
  begin
    for X := 0 to Width - 1 do
    begin
      Image[Y, X].R := LUT[Image[Y, X].R];
      Image[Y, X].G := LUT[Image[Y, X].G];
      Image[Y, X].B := LUT[Image[Y, X].B];
    end;
  end;
end;

procedure WaveSin(S, D: TBitmap; Frequency, Length:
  Integer; Hor: Boolean; BackColor: TColor; CallBack : TProgressCallBackProc = nil);

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

  PRGB = ^TRGB;

var
  C, X, Y, F: Integer;
  Dest, Src: PRGB;
  P: PARGB;
  R, G, B: Byte;
  Terminating: Boolean;
  DPArr, SPArr : array of PRGB;
  XA, YA : array of Integer;
begin
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  Terminating := False;

  R := GetRValue(BackColor);
  G := GetGValue(BackColor);
  B := GetBValue(BackColor);

  SetLength(DPArr, D.Height);
  for Y := 0 to D.Height - 1 do
    DPArr[Y] := D.ScanLine[Y];
  SetLength(SPArr, S.Height);
  for Y := 0 to S.Height - 1 do
    SPArr[Y] := S.ScanLine[Y];

  SetLength(YA, S.Height);
  SetLength(XA, S.Width);
  for Y := 0 to D.Height - 1 do
    YA[Y] := Round(Sin(Y * Rad * Length) * Frequency);

  for X := 0 to D.Width - 1 do
    XA[X] := Round(Sin(X * Rad * Length) * Frequency);

  for Y := 0 to D.Height - 1 do
  begin
    P := PARGB(DPArr[Y]);
    for X := 0 to D.Width - 1 do
    begin
      P[X].R := R;
      P[X].G := G;
      P[X].B := B;
    end;
  end;

  for Y := 0 to S.Height - 1 do
  begin
    Src := SPArr[Y];
    if Hor then
    begin
      for X := 0 to S.Width - 1 do
      begin
        C := XA[X] + Y;
        F :=  Min(Max(C, 0), D.Height - 1);
        Dest := DPArr[F];
        Inc(Dest, X);

        Dest^ := Src^;
        Inc(Src);
      end;
    end else
    begin
      for X := 0 to S.Width - 1 do
      begin
        C := YA[Y] + X;
        F := Min(Max(C, 0), D.Width - 1);
        Dest := DPArr[Y];
        Inc(Dest, F);
        Dest^ := Src^;
        Inc(Src);
      end;
    end;

    if Y mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (Y / S.Height)), Terminating);
    if Terminating then
      Break;

  end;
end;

procedure PixelsEffect(S, D: TBitmap; Hor, Ver: Word; CallBack : TProgressCallBackProc = nil);
type
  TRGB = record
    B, G, R: Byte;
  end;

  PRGB = ^TRGB;
  TpRGB = array of PARGB;
var
  I, J, X, Y, Xd, Yd, K, L, Rr, Gg, Bb, H, Hx, Hy, Dw1, Dh1: Integer;
  Sour: PRGB;
  Dp, Sp: TpRGB;
  Terminating: Boolean;
begin
  Terminating := False;
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  if (Hor = 1) and (Ver = 1) then
  begin
    AssignBitmap(D, S);
    Exit;
  end;

  Dw1 := D.Width - 1;
  Dh1 := D.Height - 1;
  SetLength(Dp, D.Height);
  for I := 0 to D.Height - 1 do
    Dp[I] := D.ScanLine[I];
  SetLength(Sp, S.Height);
  for I := 0 to S.Height - 1 do
    Sp[I] := S.ScanLine[I];

  Xd := (S.Width - 1) div Hor;
  Yd := (S.Height - 1) div Ver;
  for I := 0 to Xd do
  begin
    Hx := Min(Hor * (I + 1), S.Width - 1);
    for J := 0 to Yd do
    begin
      H := 0;
      Rr := 0;
      Gg := 0;
      Bb := 0;
      Hy := Min(Ver * (J + 1), S.Height - 1);
      for Y := J * Ver to Hy do
      begin
        Sour := PRGB(Sp[Y]);
        Inc(Sour, I * Hor);
        for X := I * Hor to Hx do
        begin
          Inc(Rr, Sour^.R);
          Inc(Gg, Sour^.G);
          Inc(Bb, Sour^.B);
          Inc(H);
          Inc(Sour);
        end;
      end;
      Rr := Rr div H;
      Gg := Gg div H;
      Bb := Bb div H;
      for K := I * Hor to Min(Hx + 1, Dw1) do
        for L := J * Ver to Min(Hy + 1, Dh1) do
        begin
          Dp[L, K].R := Rr;
          Dp[L, K].G := Gg;
          Dp[L, K].B := Bb;
        end;

      if I mod 25 = 0 then
        if Assigned(CallBack) then
          CallBack(Round(100 * (I / Xd)), Terminating);
      if Terminating then
        Break;
    end;
  end;
end;

procedure Sharpen(S, D: TBitmap; alpha: Single; CallBack : TProgressCallBackProc = nil);
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
  sr[1] := PByte(NativeInt(sr[0]) - BytesPerScanline);
  sr[2] := PByte(NativeInt(sr[1]) - BytesPerScanline);
  for i := 1 to bmh do
  begin
    if i mod 50=0 then
    If Assigned(CallBack) then CallBack(Round(100*i/bmh),Terminating);
    if Terminating then Break;
    Dec(tr, BytesPerScanline);
    tt := pRGBTriple(tr);
    st[0] := pRGBTriple(NativeInt(sr[0]) + 3); //top
    st[1] := pRGBTriple(sr[1]); //left
    st[2] := pRGBTriple(NativeInt(sr[1]) + 3); //center
    st[3] := pRGBTriple(NativeInt(sr[1]) + 6); //right
    st[4] := pRGBTriple(NativeInt(sr[2]) + 3); //bottom
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

procedure Blocks(S, D: TBitmap; Hor, Ver, MaxOffset: Integer; BackColor: TColor);

  function RandomInRadius(Num, Radius: Integer): Integer;
  begin
    if Random(2) = 0 then
      Result := Num + Random(Radius)
    else
      Result := Num - Random(Radius);
  end;

var
  X, Y, Xd, Yd: Integer;
begin
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;

  AssignBitmap(D, S);
  D.Canvas.Brush.Color := BackColor;
  D.Canvas.FillRect(Rect(0, 0, D.Width, D.Height));
  Xd := (D.Width - 1) div Hor;
  Yd := (D.Height - 1) div Ver;
  Randomize;
  for X := 0 to Xd do
    for Y := 0 to Yd do
      BitBlt(D.Canvas.Handle, RandomInRadius(Hor * X, MaxOffset), RandomInRadius(Ver * Y, MaxOffset), Hor, Ver,
        S.Canvas.Handle, Hor * X, Ver * Y, SRCCOPY);

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
    AssignBitmap(D, S);
    Exit;
  end;
  for I := 0 to 255 do
  begin
    RuleArrayR[I] := Round(Min(255, Max(0, I * (1 + (Red / 100)))));
    RuleArrayG[I] := Round(Min(255, Max(0, I * (1 + (Green / 100)))));
    RuleArrayB[I] := Round(Min(255, Max(0, I * (1 + (Blue / 100)))));
  end;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      PD[J].R := RuleArrayR[PS[J].R];
      PD[J].G := RuleArrayR[PS[J].G];
      PD[J].B := RuleArrayR[PS[J].B];
    end;
  end;
end;

procedure SetRGBChannelValue(Image: TBitmap; Red, Green, Blue: Integer);
var
  I, J: Integer;
  PD: PARGB;
  RuleArrayR, RuleArrayG, RuleArrayB: array [0 .. 255] of Byte;
begin
  Image.PixelFormat := Pf24bit;
  if (Red = 0) and (Green = 0) and (Blue = 0) then
    Exit;

  for I := 0 to 255 do
  begin
    RuleArrayR[I] := Round(Min(255, Max(0, I * (1 + (Red / 100)))));
    RuleArrayG[I] := Round(Min(255, Max(0, I * (1 + (Green / 100)))));
    RuleArrayB[I] := Round(Min(255, Max(0, I * (1 + (Blue / 100)))));
  end;
  for I := 0 to Image.Height - 1 do
  begin
    PD := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
    begin
      PD[J].R := RuleArrayR[PD[J].R];
      PD[J].G := RuleArrayR[PD[J].G];
      PD[J].B := RuleArrayR[PD[J].B];
    end;
  end;
end;

procedure SetRGBChannelValue(Image: TArPARGB; Width, Height: Integer; Red, Green, Blue: Integer); overload;
var
  I, J: Integer;
  Rx, Gx, Bx: Extended;
  RArray, GArray, BArray: T255ByteArray;
begin
  if (Red = 0) and (Green = 0) and (Blue = 0) then
  begin
    Exit;
  end;
  Rx := 1 + (Red / 100);
  Gx := 1 + (Green / 100);
  Bx := 1 + (Blue / 100);
  for I := 0 to 255 do
  begin
    RArray[I] := Round(Min(255, Max(0, I * (Rx))));
    GArray[I] := Round(Min(255, Max(0, I * (Gx))));
    BArray[I] := Round(Min(255, Max(0, I * (Bx))));
  end;
  for I := 0 to Height - 1 do
  begin
    for J := 0 to Width - 1 do
    begin
      Image[I, J].R := RArray[Image[I, J].R];
      Image[I, J].G := GArray[Image[I, J].G];
      Image[I, J].B := BArray[Image[I, J].B];
    end;
  end;
end;

procedure Disorder(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
begin
  Disorder(S, D, 10, 10, $0, CallBack);
end;

procedure Disorder(S, D: TBitmap; Hor, Ver: Integer; BackColor: TColor; CallBack : TProgressCallBackProc = nil);

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
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  Setlength(XS, S.Height);
  for I := 0 to S.Height - 1 do
    XS[I] := S.ScanLine[I];
  Setlength(XD, D.Height);
  for I := 0 to D.Height - 1 do
    XD[I] := D.ScanLine[I];
  Randomize;
  Terminate := False;
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

  function BLimit(B: Integer): Byte; inline;
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
    AssignBitmap(D, S);
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

  function BLimit(B: Integer): Byte; inline;
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
  end else
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
  end else
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

procedure Colorize(S, D: TBitmap; Luma: Integer);
var
  Ps, Pd: PARGB;
  I, J: Integer;
  LumMatrix: array [0 .. 255] of Byte;

begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  for I := 0 to 255 do
    LumMatrix[I] := Round(Min(255, I * Luma / 255));

  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    Pd := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Pd[J].R := LumMatrix[Ps[J].R];
      Pd[J].G := LumMatrix[Ps[J].G];
      Pd[J].B := LumMatrix[Ps[J].B];
    end;
  end;
end;

function Gistogramma(S: TBitmap; var Terminated: Boolean; CallBack: TProgressCallBackProc = nil; X: Extended = 1;
  Y: Extended = 0): T255IntArray;
var
  I, J: Integer;
  Ps: PARGB;
  L: Byte;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  for I := 0 to 255 do
    Result[I] := 0;
  Terminating := False;
  Terminated := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      L := (Ps[J].R * 77 + Ps[J].G * 151 + Ps[J].B * 28) shr 8;
      Inc(Result[L]);
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * X / S.Height + Y)), Terminating);
    if Terminating then
    begin
      Terminated := True;
      Break;
    end;
  end;
end;

function GistogrammR(S: TBitmap; var Terminated: Boolean; CallBack: TProgressCallBackProc = nil; X: Extended = 1;
  Y: Extended = 0): T255IntArray;
var
  I, J: Integer;
  Ps: PARGB;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  for I := 0 to 255 do
    Result[I] := 0;
  Terminating := False;
  Terminated := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Inc(Result[Ps[J].R]);
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * X / S.Height + Y)), Terminating);
    if Terminating then
    begin
      Terminated := True;
      Break;
    end;
  end;
end;

function GistogrammG(S: TBitmap; var Terminated: Boolean; CallBack: TProgressCallBackProc = nil; X: Extended = 1;
  Y: Extended = 0): T255IntArray;
var
  I, J: Integer;
  Ps: PARGB;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  for I := 0 to 255 do
    Result[I] := 0;
  Terminating := False;
  Terminated := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Inc(Result[Ps[J].G]);
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * X / S.Height + Y)), Terminating);
    if Terminating then
    begin
      Terminated := True;
      Break;
    end;
  end;
end;

function GistogrammB(S: TBitmap; var Terminated: Boolean; CallBack: TProgressCallBackProc = nil; X: Extended = 1;
  Y: Extended = 0): T255IntArray;
var
  I, J: Integer;
  Ps: PARGB;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  for I := 0 to 255 do
    Result[I] := 0;
  Terminating := False;
  Terminated := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Inc(Result[Ps[J].B]);
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * X / S.Height + Y)), Terminating);
    if Terminating then
    begin
      Terminated := True;
      Break;
    end;
  end;
end;

procedure AutoLevels(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
var
  Ps, Pd: PARGB;
  I, J, MinCount: Integer;
  L: Byte;
  Count: Int64;
  RL: T255ByteArray;
  Gistogramm: T255IntArray;
  Terminated: Boolean;
  Terminating: Boolean;
begin
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  Gistogramm := Gistogramma(S, Terminated, CallBack, 0.5);
  if Terminated then
    Exit;
  MinCount := (S.Height div 50) * (S.Width div 50);
  Count := 0;
  L := 0;
  for I := 255 downto 0 do
  begin
    Inc(Count, Gistogramm[I]);
    if Count > MinCount then
    begin
      L := I;
      Break;
    end;
  end;
  if L = 0 then
    L := 1;
  for I := 0 to 255 do
  begin
    RL[I] := Min(255, Round((255 / L) * I));
  end;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    Pd := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Pd[J].R := Rl[Ps[J].R];
      Pd[J].G := Rl[Ps[J].G];
      Pd[J].B := Rl[Ps[J].B];
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * 0.5 / S.Height + 0.5)), Terminating);
    if Terminating then
      Break;

  end;
end;

procedure AutoColors(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
var
  Ps, Pd: PARGB;
  I, J, MinCount: Integer;
  Count: Int64;
  R, G, B: Byte;
  Rx, Bx, Gx: T255ByteArray;
  GistogrammaR, GistogrammaG, GistogrammaB: T255IntArray;
  Terminated, Terminating: Boolean;
begin
  D.Width := S.Width;
  D.Height := S.Height;
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  GistogrammaR := GistogrammR(S, Terminated, CallBack, 0.25, 0);
  if Terminated then
    Exit;
  GistogrammaG := GistogrammG(S, Terminated, CallBack, 0.25, 0.25);
  if Terminated then
    Exit;
  GistogrammaB := GistogrammB(S, Terminated, CallBack, 0.25, 0.5);
  if Terminated then
    Exit;
  Count := 0;
  R := 0;
  G := 0;
  B := 0;
  MinCount := (S.Height div 10) * (S.Width div 10);
  for I := 255 downto 0 do
  begin
    Inc(Count, GistogrammaR[I]);
    if Count > MinCount then
    begin
      R := I;
      Break;
    end;
  end;
  Count := 0;
  for I := 255 downto 0 do
  begin
    Inc(Count, GistogrammaG[I]);
    if Count > MinCount then
    begin
      G := I;
      Break;
    end;
  end;
  Count := 0;
  for I := 255 downto 0 do
  begin
    Inc(Count, GistogrammaB[I]);
    if Count > MinCount then
    begin
      B := I;
      Break;
    end;
  end;
  if R = 0 then
    R := 1;
  if G = 0 then
    G := 1;
  if B = 0 then
    B := 1;
  for I := 0 to 255 do
  begin
    Rx[I] := Min(255, Round((255 / R) * I));
    Gx[I] := Min(255, Round((255 / G) * I));
    Bx[I] := Min(255, Round((255 / B) * I));
  end;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    Pd := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      Pd[J].R := Rx[Ps[J].R];
      Pd[J].G := Gx[Ps[J].G];
      Pd[J].B := Bx[Ps[J].B];
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * 0.25 / S.Height + 0.75)), Terminating);
    if Terminating then
      Break;

  end;
end;

function GistogrammRW(S: TBitmap; Rect: TRect; var CountR: Int64): T255IntArray;
var
  I, J: Integer;
  Ps: PARGB;
begin
  S.PixelFormat := Pf24bit;
  for I := 0 to 255 do
    Result[I] := 0;
  CountR := 0;
  for I := Max(0, Rect.Top) to Min(Rect.Bottom - 1, S.Height - 1) do
  begin
    Ps := S.ScanLine[I];
    for J := Max(0, Rect.Left) to Min(Rect.Right - 1, S.Width - 1) do
      if Ps[J].R > Max(Ps[J].G, Ps[J].B) then
      begin
        Inc(CountR, 1);
        Inc(Result[Ps[J].R - Max(Ps[J].G, Ps[J].B)], 1);
      end;
  end;
end;

procedure Rotate180(S, D: Tbitmap; CallBack: TProgressCallBackProc = nil);
var
  I, J: Integer;
  P1, P2: Pargb;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    P1 := S.ScanLine[I];
    P2 := D.ScanLine[S.Height - I - 1];
    for J := 0 to S.Width - 1 do
      P2[J] := P1[S.Width - 1 - J];

    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * 0.25 / S.Height + 0.75)), Terminating);
    if Terminating then
    begin
      Break;
    end;
  end;
end;

procedure Rotate270(S, D: Tbitmap; CallBack: TProgressCallBackProc = nil);
var
  I, J: Integer;
  P1: Pargb;
  P: array of Pargb;
  Terminating: Boolean;
begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Height;
  D.Height := S.Width;
  Setlength(P, S.Width);
  for I := 0 to S.Width - 1 do
    P[I] := D.ScanLine[S.Width - 1 - I];
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    P1 := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
      P[J, I] := P1[J];

    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * (I * 0.25 / S.Height + 0.75)), Terminating);
    if Terminating then
    begin
      Break;
    end;
  end;
end;

procedure Rotate90(S,D : tbitmap; CallBack : TProgressCallBackProc = nil);
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
   p[j,i]:=p1[j];
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure FlipHorizontal(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);
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
   pd[j]:=ps[S.Width-1-j];
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure FlipVertical(S,D : TBitmap; CallBack : TProgressCallBackProc = nil);
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
   pd[j]:=ps[j];
  end;
  if i mod 50=0 then
  If Assigned(CallBack) then CallBack(Round(100*(i*0.25/S.Height+0.75)),Terminating);
  if Terminating then
  begin
   Break;
  end;
 end;
end;

procedure RotateBitmap(Bmp, Bitmap: TBitmap; Angle: Double; BackColor: TColor; CallBack : TProgressCallBackProc = nil);
type TRGB = record
       B, G, R: Byte;
     end;
     pRGB = ^TRGB;
     pByteArray = ^TByteArray;
     TByteArray = array[0..32767] of Byte;
     TRectList = array [1..4] of TPoint;

var
  x, y, W, H, v1, v2: Integer;
  Dest, Src: pRGB;
  VertArray: array of pByteArray;
//  Bmp: TBitmap;
  Terminating: boolean;
  p: PARGB;
  rgb: TRGB;

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
  var
    I, X, Y, Xr, Yr, Yp: Integer;
    ACos, ASin: Double;
    Lim: TRect;
    YPSin, YPCos : Integer;

    XWAC, XWAS : array of Integer;
    SrcAr: array of pRGB;
  begin
    W := Bmp.Width;
    H := Bmp.Height;
    SinCos(-Angle * Pi / 180, ASin, ACos);
    Lim := GetRLLimit(RotateRect(Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Angle));
    Bitmap.Width := Lim.Right - Lim.Left;
    Bitmap.Height := Lim.Bottom - Lim.Top;

    Rgb.R := GetRValue(BackColor);
    Rgb.G := GetGValue(BackColor);
    Rgb.B := GetBValue(BackColor);
    SetLength(XWAS, Bitmap.Width);
    SetLength(XWAC, Bitmap.Width);
    for I := 0 to Bitmap.Width - 1 do
    begin
      XWAC[I] := Round((I + Lim.Left) * ACos);
      XWAS[I] := Round((I + Lim.Left) * ASin);
    end;

    SetLength(SrcAr, Bmp.Height);
    for I := 0 to Bmp.Height - 1 do
      SrcAr[I] := Bmp.ScanLine[I];

    for Y := 0 to Bitmap.Height - 1 do
    begin
      Dest := Bitmap.ScanLine[Y];
      P := PARGB(Dest);
      for X := 0 to Bitmap.Width - 1 do
      begin
        P[X].R := Rgb.R;
        P[X].G := Rgb.G;
        P[X].B := Rgb.B;
      end;
      Yp := Y + Lim.Top;
      YPSin := Round(Yp * ASin);
      YPCos := Round(Yp * ACos);
      for X := 0 to Bitmap.Width - 1 do
      begin
        Xr := XWAC[X] - YPSin;
        Yr := XWAS[X] + YPCos;
        if (Xr > -1) and (Xr < W) and (Yr > -1) and (Yr < H) then
        begin
          Src := SrcAr[Yr];
          Inc(Src, Xr);
          Dest^ := Src^;
        end;
        Inc(Dest);
      end;
      if Y mod 50 = 0 then
        if Assigned(CallBack) then
          CallBack(Round(100 * Y / Bitmap.Height), Terminating);
      if Terminating then
        Break;
    end;
  end;


{function TrimInt(i,Min,Max:Integer):Integer;
begin
  if      i>Max then Result:=Max
  else if i<Min then Result:=Min
  else               Result:=i;
end;

function IntToByte(i:Integer):Byte;
begin
  if      i>255 then Result:=255
  else if i<0   then Result:=0
  else               Result:=i;
end;

procedure SmoothRotate;
var
Top,
Bottom,
Left,
Right,
eww,nsw,
fx,fy,
wx,wy, Theta:    Extended;
cAngle,
sAngle:   Double;
xDiff,
yDiff,
ifx,ify,
px,py,
ix,iy,
x,y, gap:      Integer;
nw,ne,
sw,se:    TRGB;
Tmp:      PRGB;
Line: Pointer;
begin
  Theta:=Abs(Angle)*(Pi/180);
  x:=Round(Abs(Bmp.Width*Cos(Theta))+Abs(Bmp.Height*Sin(Theta))+0.4);
  y:=Round(Abs(Bmp.Width*Sin(Theta))+Abs(Bmp.Height*Cos(Theta))+0.4);
  Bitmap.SetSize(x, y);
  Bitmap.PixelFormat := pf24bit;

  Angle:=-Angle*Pi/180;
  sAngle:=Sin(Angle);
  cAngle:=Cos(Angle);
  xDiff:=(Bitmap.Width-Bmp.Width)div 2;
  yDiff:=(Bitmap.Height-Bmp.Height)div 2;
  Line:=Bitmap.ScanLine[0];
  gap := NativeInt(Bitmap.ScanLine[1]) - NativeInt(Line);

  for y:=0 to Bitmap.Height-1 do
  begin
    Tmp := Line;
    py:=2*(y)+1;
    for x:=0 to Bitmap.Width-1 do
    begin
      px:=2*(x)+1;
      fx:=(((px*cAngle-py*sAngle)-1)/ 2)-xDiff;
      fy:=(((px*sAngle+py*cAngle)-1)/ 2)-yDiff;
      ifx:=Round(fx);
      ify:=Round(fy);

      if(ifx>-1)and(ifx<Bmp.Width)and(ify>-1)and(ify<Bmp.Height)then
      begin
        eww:=fx-ifx;
        nsw:=fy-ify;
        iy:=TrimInt(ify+1,0,Bmp.Height-1);
        ix:=TrimInt(ifx+1,0,Bmp.Width-1);
        nw:=PARGB(Bmp.ScanLine[ify])[ifx];
        ne:=PARGB(Bmp.ScanLine[ify])[ix];
        sw:=PARGB(Bmp.ScanLine[iy])[ifx];
        se:=PARGB(Bmp.ScanLine[iy])[ix];

        Top:=nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        Tmp.b:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        Tmp.g:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top:=nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        Tmp.r:=IntToByte(Round(Top+nsw*(Bottom-Top)));
      end;
      Inc(Tmp);
    end;
    Line:=Pointer(NativeInt(Line)+gap);
  end;
end;   }

begin
  Terminating := False;
  Bitmap.PixelFormat := pf24Bit;
  W := Bitmap.Width - 1;
  H := Bitmap.Height - 1;
  if Frac(Angle) <> 0.0
    then Rotate
    else
  case Trunc(Angle) of
    -360, 0, 360, 720: AssignBitmap(Bitmap, Bmp);
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

       end;
        if x mod 50=0 then
        If Assigned(CallBack) then CallBack(Round(100*x/W),Terminating);
        if Terminating then Break;
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
end;

procedure StrRotated(X, Y: Integer; Arect: TRect; DC: HDC; Font: HFont; Str: string; Ang: Extended; Options: Cardinal);
var
  NXF, OXF: TXForm;
  S: TStrings;
  FNew, FOld: HFont;
begin
  FNew := Font;
  FOld := SelectObject(DC, FNew);
  S := TStringList.Create;
  S.Text := Str;
  SetGraphicsMode(DC, GM_Advanced);
  GetWorldTransform(DC, OXF);
  NXF.EM11 := Cos(Ang * Pi / 180);
  NXF.EM22 := Cos(Ang * Pi / 180);
  NXF.EM12 := Sin(Ang * Pi / 180);
  NXF.EM21 := -Sin(Ang * Pi / 180);
  NXF.EDX := X;
  NXF.EDY := Y;
  ModifyWorldTransform(DC, NXF, MWT_RIGHTMULTIPLY);
  SetBkMode(DC, Transparent);
  DrawText(DC, PChar(S.Text), Length(S.Text), Arect, Options);
  SetWorldTransform(DC, OXF);
  S.Free;
  SelectObject(DC, FOld);
end;

procedure CoolDrawTextEx(bitmap:Tbitmap; text:string; Font: HFont; coolcount:integer; coolcolor:Tcolor; aRect : TRect; aType : integer; Options : Cardinal);
var
  Drawrect: Trect;
  C: Integer;
  Tempb, Temp: TBitmap;
  I, J, K: Integer;
  P, P1, Pv, Pn, Pc: PARGB;
begin
  Tempb := TBitmap.Create;
  try
    Tempb.PixelFormat := Pf24bit;
    Tempb.Canvas.Font.Assign(Bitmap.Canvas.Font);
    Tempb.Canvas.Font.Color := 0;
    Tempb.Canvas.Brush.Color := $FFFFFF;
    Tempb.Width := ARect.Right - ARect.Left;
    Tempb.Height := ARect.Bottom - ARect.Top;

    case AType of
      0:
        begin
          DrawRect := Rect(Point(Coolcount, Coolcount), Point(Tempb.Width - Coolcount, Tempb.Height - Coolcount));
          StrRotated(0, 0, DrawRect, Tempb.Canvas.Handle, Font, Text, 0, Options);
        end;
      1:
        begin
          DrawRect := Rect(Point(Coolcount, Coolcount), Point(Tempb.Height - Coolcount, Tempb.Width - Coolcount));
          StrRotated(ARect.Right - ARect.Left, 0, DrawRect, Tempb.Canvas.Handle, Font, Text, 90, Options);
        end;
      2:
        begin
          DrawRect := Rect(Point(Coolcount, Coolcount), Point(Tempb.Width - Coolcount, Tempb.Height - Coolcount));
          StrRotated(ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, DrawRect, Tempb.Canvas.Handle, Font, Text, 180,
            Options);
        end;
      3:
        begin
          DrawRect := Rect(Point(Coolcount, Coolcount), Point(Tempb.Height - Coolcount, Tempb.Width - Coolcount));
          StrRotated(0, ARect.Bottom - ARect.Top, DrawRect, Tempb.Canvas.Handle, Font, Text, 270, Options);
        end;
    end;

    Temp := TBitmap.Create;
    try
      Temp.PixelFormat := pf24bit;
      Temp.Canvas.Brush.Color := $0;
      Temp.Width := ARect.Right - ARect.Left;
      Temp.Height := ARect.Bottom - ARect.Top;
      Temp.Canvas.Font.Assign(Bitmap.Canvas.Font);
      Temp.Canvas.Font.Color := 0;
      for I := 0 to Temp.Height - 1 do
      begin
        P1 := Temp.ScanLine[I];
        P := Tempb.ScanLine[I];
        for J := 0 to Temp.Width - 1 do
        begin
          if P[J].R <> $FF then
          begin
            P1[J].R := $FF;
            P1[J].G := $FF;
            P1[J].B := $FF;
          end;
        end;
      end;
      Tempb.Canvas.Brush.Color := $0;
      Tempb.Canvas.Pen.Color := $0;
      Tempb.Canvas.Rectangle(0, 0, Tempb.Width, Tempb.Height);
      for K := 1 to Coolcount do
      begin
        for I := 1 to Temp.Height - 2 do
        begin
          P := Tempb.ScanLine[I];
          Pv := Temp.ScanLine[I - 1];
          Pc := Temp.ScanLine[I];
          Pn := Temp.ScanLine[I + 1];
          for J := 1 to Temp.Width - 2 do
          begin
            C := 9;
            if (Pv[J - 1].R <> 0) then
              Dec(C);
            if (Pv[J + 1].R <> 0) then
              Dec(C);
            if (Pn[J - 1].R <> 0) then
              Dec(C);
            if (Pn[J + 1].R <> 0) then
              Dec(C);
            if (Pc[J - 1].R <> 0) then
              Dec(C);
            if (Pc[J + 1].R <> 0) then
              Dec(C);
            if (Pn[J].R <> 0) then
              Dec(C);
            if (Pv[J].R <> 0) then
              Dec(C);
            if C <> 9 then
            begin
              P[J].R := Min($FF, P[J].R + (Pv[J - 1].R + Pv[J + 1].R + Pn[J - 1].R + Pn[J + 1].R + Pc[J - 1].R + Pc[J + 1]
                    .R + Pn[J].R + Pv[J].R) div (C + 1));
              P[J].G := Min($FF, P[J].G + (Pv[J - 1].G + Pv[J + 1].G + Pn[J - 1].G + Pn[J + 1].G + Pc[J - 1].G + Pc[J + 1]
                    .G + Pn[J].G + Pv[J].G) div (C + 1));
              P[J].B := Min($FF, P[J].B + (Pv[J - 1].B + Pv[J + 1].B + Pn[J - 1].B + Pn[J + 1].B + Pc[J - 1].B + Pc[J + 1]
                    .B + Pn[J].B + Pv[J].B) div (C + 1));
            end;
          end;
        end;
        AssignBitmap(Temp, Tempb);
      end;
      Bitmap.PixelFormat := Pf24bit;
      if Bitmap.Width = 0 then
        Exit;
      for I := Max(0, ARect.Top) to Min(Tempb.Height - 1 + ARect.Top, Bitmap.Height - 1) do
      begin
        P := Bitmap.ScanLine[I];
        P1 := Tempb.ScanLine[I - ARect.Top];
        for J := Max(0, ARect.Left) to Min(Tempb.Width + ARect.Left - 1, Bitmap.Width - 1) do
        begin
          P[J].R := Min(Round(P[J].R * (1 - P1[J - ARect.Left].R / 255)) + Round
              (Getrvalue(Coolcolor) * P1[J - ARect.Left].R / 255), 255);
          P[J].G := Min(Round(P[J].G * (1 - P1[J - ARect.Left].G / 255)) + Round
              (Getgvalue(Coolcolor) * P1[J - ARect.Left].G / 255), 255);
          P[J].B := Min(Round(P[J].B * (1 - P1[J - ARect.Left].B / 255)) + Round
              (Getbvalue(Coolcolor) * P1[J - ARect.Left].B / 255), 255);
        end;
      end;
      DrawRect := Rect(Point(ARect.Left + Coolcount, ARect.Top + Coolcount), Point(ARect.Left + Temp.Width - Coolcount,
          Temp.Height + ARect.Top - Coolcount));

      case AType of
        0:
          begin
            DrawRect := Rect(Point(ARect.Left + Coolcount, ARect.Top + Coolcount),
              Point(ARect.Left + Temp.Width - Coolcount, Temp.Height + ARect.Top - Coolcount));
            StrRotated(0, 0, DrawRect, Bitmap.Canvas.Handle, Font, Text, 0, Options);
          end;
        1:
          begin
            DrawRect := Rect(Point(Coolcount, Coolcount), Point(Temp.Height - Coolcount, Temp.Width - Coolcount));
            StrRotated(ARect.Right, ARect.Top, DrawRect, Bitmap.Canvas.Handle, Font, Text, 90, Options);
          end;
        2:
          begin
            DrawRect := Rect(Point(Coolcount, Coolcount), Point(Temp.Width - Coolcount, Temp.Height - Coolcount));
            StrRotated(ARect.Right, ARect.Bottom, DrawRect, Bitmap.Canvas.Handle, Font, Text, 180, Options);
          end;
        3:
          begin
            DrawRect := Rect(Point(Coolcount, Coolcount), Point(Temp.Height - Coolcount, Temp.Width - Coolcount));
            StrRotated(ARect.Left, ARect.Bottom, DrawRect, Bitmap.Canvas.Handle, Font, Text, 270, Options);
          end;
      end;

    finally
      F(Temp);
    end;
  finally
    F(Tempb);
  end;
end;

function GetGistogrammBitmap(Height : integer; SBitmap : TBitmap; Options : byte; var MinC, MaxC : Integer) : TBitmap;
var
  T: Boolean;
  I, J, Xc: Integer;
  X, MaxCount: Integer;
  G: T255IntArray;
  GE: array [0 .. 255] of Extended;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := Pf24bit;
  case Options of
    0:
      G := Gistogramma(SBitmap, T);
    1:
      G := GistogrammR(SBitmap, T);
    2:
      G := GistogrammG(SBitmap, T);
    3:
      G := GistogrammB(SBitmap, T);
  end;
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
    Result.Canvas.MoveTo(I + 1, Height);
    Result.Canvas.LineTo(I + 1, Height - Round(Height * GE[I]));
  end;
  Result.Canvas.Pen.Color := $888888;
  Result.Canvas.MoveTo(MinC, 0);
  Result.Canvas.LineTo(MinC, Height);
  Result.Canvas.Pen.Color := $888888;
  Result.Canvas.MoveTo(MaxC, 0);
  Result.Canvas.LineTo(MaxC, Height);
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

procedure GetGistogrammBitmapW(Height: Integer; Source: T255IntArray; var MinC, MaxC: Integer; Bitmap: TBitmap; Color: TColor);
var
  I, J, Xc: Integer;
  X, MaxCount: Integer;
  GE: array [0 .. 255] of Extended;
begin
  Bitmap.PixelFormat := pf24bit;

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

  Bitmap.Canvas.Pen.Color := clGray;
  Bitmap.Canvas.Brush.Color := clGray;
  Bitmap.Canvas.Rectangle(0, 0, 256, Height);

  Bitmap.Canvas.Pen.Color := Color;
  for I := 0 to 255 do
  begin
    Bitmap.Canvas.MoveTo(I, Height - 1);
    Bitmap.Canvas.LineTo(I, Height - Round(Height * GE[I]) - 1);
  end;
  Bitmap.Canvas.Pen.Color := $888888;
  Bitmap.Canvas.MoveTo(MinC, 0);
  Bitmap.Canvas.LineTo(MinC, Height);
  Bitmap.Canvas.Pen.Color := $888888;
  Bitmap.Canvas.MoveTo(MaxC, 0);
  Bitmap.Canvas.LineTo(MaxC, Height);
end;

procedure GetGistogrammBitmapWRGB(Height: Integer; SGray, SR, SG, SB: T255IntArray; var MinC, MaxC: Integer; Bitmap: TBitmap; BackColor: TColor);
type
  ExtendedArray255 = array[0 .. 255] of Extended;
var
  I, J: Integer;
  GGray, GR, GG, GB: ExtendedArray255;
  P: PARGB;
  PArray: array of PARGB;
  R, B, G: Byte;
  RGB: TRGB;

  function NormalizeGistogramm(Gisto: T255IntArray): ExtendedArray255;
  var
    I, J: Integer;
    MaxCount, Xc: Integer;
    X: Integer;
  begin
    MaxCount := 1;

    for I := 0 to 255 do
      if Gisto[I] > MaxCount then
      begin
        X := Gisto[I] div 2;
        Xc := 0;
        for J := 0 to 255 do
          if I <> J then
            if Gisto[J] > X then
              Inc(Xc);
        if Xc > 5 then
          MaxCount := Gisto[I];
      end;

    if MaxCount = 1 then
    begin
      for I := 0 to 255 do
        if Gisto[I] > MaxCount then
          MaxCount := Gisto[I];
    end;

    for I := 0 to 255 do
      Result[I] := Gisto[I] / MaxCount;
  end;

begin
  Bitmap.PixelFormat := pf24bit;

  GGray := NormalizeGistogramm(SGray);
  GR := NormalizeGistogramm(SR);
  GG := NormalizeGistogramm(SG);
  GB := NormalizeGistogramm(SB);

  BackColor := ColorToRGB(BackColor);
  R := GetRValue(BackColor);
  G := GetGValue(BackColor);
  B := GetBValue(BackColor);

  MinC := 0;
  for I := 0 to 255 do
  begin
    if GGray[I] > 0.05 then
    begin
      MinC := I;
      Break;
    end;
  end;
  MaxC := 0;
  for I := 255 downto 0 do
  begin
    if GGray[I] > 0.05 then
    begin
      MaxC := I;
      Break;
    end;
  end;

  Bitmap.SetSize(256, Height);

  SetLength(PArray, Bitmap.Height);
  for I := 0 to Bitmap.Height - 1 do
    PArray[I] := Bitmap.ScanLine[I];

  RGB.R := 0;
  RGB.G := 0;
  RGB.B := 0;
  for I := 0 to Bitmap.Height - 1 do
    for J := 0 to Bitmap.Width - 1 do
      PArray[I][J] := RGB;

  for I := 0 to 255 do
  begin
    for J := Max(0, Height - Round(Height * GR[I])) to Bitmap.Height - 1 do
      PArray[J][I].R := 255;

    for J := Max(0, Height - Round(Height * GG[I])) to Bitmap.Height - 1 do
      PArray[J][I].G := 255;

    for J := Max(0, Height - Round(Height * GB[I])) to Bitmap.Height - 1 do
      PArray[J][I].B := 255;

  end;

  for I := 0 to Bitmap.Height - 1 do
  begin
    P := PArray[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (P^[J].R = 0) and (P^[J].G = 0) and (P^[J].B = 0) then
      begin
        P^[J].R := R;
        P^[J].G := G;
        P^[J].B := B;
      end;
    end;
  end;

  RGB.R := $88;
  RGB.G := $88;
  RGB.B := $88;

  for I := 0 to Bitmap.Height - 1 do
    PArray[I][MinC] := RGB;

  for I := 0 to Bitmap.Height - 1 do
    PArray[I][MaxC] := RGB;

end;

procedure ReplaceColorInImage(S,D : TBitmap; BaseColor, NewColor : TColor; Size, Level : Integer; CallBack : TProgressCallBackProc = nil); overload;
var
  I, J: Integer;
  Ps, Pd: PARGB;
  Terminating: Boolean;
  R1, R2, G1, G2, B1, B2: Byte;
  C: Extended;

  function CompareColor(R1, R2, G1, G2, B1, B2: Byte): Extended;
  var
    R, G, B: Extended;
  begin
    R := Power(1 - Abs(R1 - R2) / 255, Level);
    G := Power(1 - Abs(G1 - G2) / 255, Level);
    B := Power(1 - Abs(B1 - B2) / 255, Level);
    Result := R * G * B;
    Result := Min(1, Result * Size / 100);
  end;

begin
  R1 := GetRValue(ColorToRGB(BaseColor));
  G1 := GetGValue(ColorToRGB(BaseColor));
  B1 := GetBValue(ColorToRGB(BaseColor));
  R2 := GetRValue(ColorToRGB(NewColor));
  G2 := GetGValue(ColorToRGB(NewColor));
  B2 := GetBValue(ColorToRGB(NewColor));
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  Terminating := False;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      C := CompareColor(PS[J].R, R1, PS[J].G, G1, PS[J].B, B1);
      PD[J].R := Round(PS[J].R * (1 - C) + R2 * C);
      PD[J].G := Round(PS[J].G * (1 - C) + G2 * C);
      PD[J].B := Round(PS[J].B * (1 - C) + B2 * C);
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * I / S.Height), Terminating);
    if Terminating then
      Break;
  end;
end;

procedure Emboss(S, D: TBitmap; CallBack : TProgressCallBackProc = nil);
var
  x, y :   Integer;
  p1, p2 : Pbytearray;

  SL : TScanlines;
  Terminating : Boolean;
begin
  AssignBitmap(D, S);
  D.PixelFormat := pf24bit;
  SL := TScanlines.Create(D);
  Terminating := False;
  try

    for y := 0 to D.Height-2 do
    begin
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

procedure AntiAliasRect(clip: tbitmap; XOrigin, YOrigin, XFinal, YFinal: Integer; CallBack : TProgressCallBackProc = nil);
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

procedure AntiAlias(S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
begin
  AssignBitmap(D, S);
  D.PixelFormat := Pf24bit;
  AntiAliasRect(D, 0, 0, D.Width, D.Height, CallBack);
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

procedure AddColorNoise(S, D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
var
  p0: pbytearray;
  x, y, r, g, b: Integer;
  SL : TScanLines;
  Terminating: Boolean;
begin
  AssignBitmap(D, S);
  D.PixelFormat := pf24bit;
  Terminating := False;
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

procedure AddMonoNoise(S, D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
var
  P0: Pbytearray;
  X, Y, A, R, G, B: Integer;
  Terminating: Boolean;
  SL: TScanLines;
begin
  AssignBitmap(D, S);
  D.PixelFormat := Pf24bit;
  Terminating := False;
  SL := TScanlines.Create(D);
  try
    for Y := 0 to D.Height - 1 do
    begin
      P0 := PByteArray(SL[Y]);
      for X := 0 to D.Width - 1 do
      begin
        A := Random(Amount) - (Amount shr 1);
        R := P0[X * 3] + A;
        G := P0[X * 3 + 1] + A;
        B := P0[X * 3 + 2] + A;
        P0[X * 3] := IntToByte(R);
        P0[X * 3 + 1] := IntToByte(G);
        P0[X * 3 + 2] := IntToByte(B);
      end;
      if Y mod 50 = 0 then
        if Assigned(CallBack) then
          CallBack(Round(100 * Y / D.Height), Terminating);
      if Terminating then
        Break;
    end;
  finally
    SL.Free;
  end;
end;

procedure FishEye(Bmp, Dst: TBitmap; xAmount: Integer; CallBack : TProgressCallBackProc = nil);
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
  AssignBitmap(Dst, Bmp);
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

procedure GaussianBlur(D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
var
  i : Integer;
begin
  for i := Amount downto 0 do
    SplitBlurW(D,3,CallBack);
end;


procedure SplitBlur(S, D : TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
begin
  AssignBitmap(D, S);
  D.PixelFormat := pf24Bit;
  SplitBlurW(D,Amount,CallBack);
end;

procedure SplitBlurW(D: TBitmap; Amount : Integer; CallBack : TProgressCallBackProc = nil);
//procedure SplitBlur(var clip: tbitmap; Amount: integer);
var
  P0, P1, P2: Pbytearray;
  Cx, X, Y: Integer;
  Buf: array [0 .. 3, 0 .. 2] of Byte;
  Terminating: Boolean;
  SL: TScanlines;
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

procedure Twist(Bmp, Dst: TBitmap; Amount: integer; CallBack : TProgressCallBackProc = nil);
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
  AssignBitmap(Dst, Bmp);
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

procedure SetContractBrightnessRGBChannelValue(ImageS, ImageD: TArPARGB; Width, Height: Integer;  Contrast : Extended; var OverageBrightnss : Integer; Brightness, Red, Green, Blue: Integer); overload;
var
  Mr, Mg, Mb, I, J, W, H: Integer;
  vd: Double;
  ContrastArrayR,
  ContrastArrayG,
  ContrastArrayB: T255ByteArray;

  LUT: array [Byte] of Byte;
  V: Integer;

  Rx, Gx, Bx: Extended;
  RArray, GArray, BArray: T255ByteArray;

  RFull, GFull, BFull: T255ByteArray;
  PARGBS, PARGBD : PRGB;

  function BLimit(B: Integer): Byte;
  begin
    if B < 0 then
      Result := 0
    else if B > 255 then
      Result := 255
    else
      Result := B;
  end;

begin

  W := Width - 1;
  H := Height - 1;

  //contrast
  if OverageBrightnss < 0 then
  begin
    OverageBrightnss := 0;
    for I := 0 to H do
      for J := 0 to W do
        Inc(OverageBrightnss, (ImageS[I, J].R * 77 + ImageS[I, J].G * 151 + ImageS[I, J].B * 28) shr 8);
  end;

  MR := Round(OverageBrightnss / (W * H));
  MG := Round(OverageBrightnss / (W * H));
  MB := Round(OverageBrightnss / (W * H));

  if Contrast > 0 then
    Vd := 1 + (Contrast / 10)
  else
    Vd := 1 - (Sqrt(-Contrast) / 10);

  for I := 0 to 255 do
  begin
    ContrastArrayR[I] := BLimit(MR + Round((I - MR) * Vd));
    ContrastArrayG[I] := BLimit(MG + Round((I - MG) * Vd));
    ContrastArrayB[I] := BLimit(MB + Round((I - MB) * Vd));
  end;

  //brightness
  for I := 0 to 255 do
  begin
    V := I + Brightness;
    if V < 0 then
      V := 0
    else if V > 255 then
      V := 255;
    LUT[I] := V;
  end;

  //RGB
  Rx := 1 + (Red / 100);
  Gx := 1 + (Green / 100);
  Bx := 1 + (Blue / 100);
  for I := 0 to 255 do
  begin
    RArray[I] := Round(Min(255, Max(0, I * (Rx))));
    GArray[I] := Round(Min(255, Max(0, I * (Gx))));
    BArray[I] := Round(Min(255, Max(0, I * (Bx))));
  end;

  for I := 0 to 255 do
  begin
    RFull[I] := RArray[LUT[ContrastArrayR[I]]];
    GFull[I] := GArray[LUT[ContrastArrayG[I]]];
    BFull[I] := BArray[LUT[ContrastArrayB[I]]];
  end;

  for I := 0 to Height - 1 do
  begin
    PARGBS := PRGB(ImageS[I]);
    PARGBD := PRGB(ImageD[I]);
    for J := 0 to Width - 1 do
    begin
      PARGBD.R := RFull[PARGBS.R];
      PARGBD.G := GFull[PARGBS.G];
      PARGBD.B := BFull[PARGBS.B];
      Inc(PARGBS, 1);
      Inc(PARGBD, 1);
    end;
  end;
end;

end.
