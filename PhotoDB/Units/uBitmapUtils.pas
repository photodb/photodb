unit uBitmapUtils;

interface

uses
  Windows, Graphics, uConstants, GraphicsBaseTypes, uMemory, Math, uMath,
  Classes;

const
  // Image processiong options
  ZoomSmoothMin = 0.4;

type
  TBitmapHelper = class helper for TBitmap
  public
    function ClientRect: TRect;
  end;

procedure ThreadDraw(S, D: TBitmap; X, Y: Integer);
procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
procedure Rotate180A(Bitmap: TBitmap);
procedure Rotate270A(Bitmap: TBitmap);
procedure Rotate90A(Bitmap: TBitmap);
procedure AssignBitmap(Dest: TBitmap; Src: TBitmap);

procedure StretchA(Width, Height: Integer; S, D: TBitmap);
procedure QuickReduce(NewWidth, NewHeight: Integer; D, S: TBitmap);
procedure StretchCool(X, Y, Width, Height: Integer; S, D: TBitmap); overload;
procedure StretchCool(Width, Height: Integer; S, D: TBitmap); overload;
procedure QuickReduceWide(Width, Height: Integer; S, D: TBitmap);
procedure DoResize(Width, Height: Integer; S, D: TBitmap);
procedure Interpolate(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap); overload;

procedure LoadBMPImage32bit(S: TBitmap; D: TBitmap; BackGroundColor: TColor);
procedure SelectedColor(Image: TBitmap; Color: TColor);
procedure FillColorEx(Bitmap: TBitmap; Color: TColor);
procedure DrawImageEx(Dest, Src: TBitmap; X, Y: Integer);
procedure DrawImageExRect(Dest, Src: TBitmap; SX, SY, SW, SH: Integer; DX, DY: Integer);
procedure DrawImageEx32(Dest32, Src32: TBitmap; X, Y: Integer);
procedure DrawImageEx32To24(Dest24, Src32: TBitmap; X, Y: Integer);
procedure DrawImageEx24To32(Dest32, Src24: TBitmap; X, Y: Integer; NewTransparent: Byte = 0);
procedure FillTransparentColor(Bitmap: TBitmap; Color: TColor; TransparentValue: Byte = 0);
procedure DrawImageEx32To32(Dest32, Src32: TBitmap; X, Y: Integer);
procedure DrawTransparent(S, D: TBitmap; Transparent: Byte);
procedure GrayScale(Image: TBitmap);

procedure DrawText32Bit(Bitmap32: TBitmap; Text: string; Font: TFont; ARect: TRect; DrawTextOptions: Cardinal);
procedure DrawColorMaskTo32Bit(Dest, Mask: TBitmap; Color: TColor; X, Y: Integer);
procedure DrawShadowToImage(Dest32, Src: TBitmap; Transparenty: Byte = 0);
procedure DrawRoundGradientVert(Dest: TBitmap; Rect: TRect; ColorFrom, ColorTo, BorderColor: TColor;
  RoundRect: Integer; TransparentValue: Byte = 220);

procedure StretchCool(Width, Height: Integer; S, D: TBitmap; CallBack: TProgressCallBackProc); overload;
procedure SmoothResize(Width, Height: Integer; S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
procedure ThumbnailResize(Width, Height: Integer; S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
procedure Interpolate(X, Y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap; CallBack: TProgressCallBackProc); overload;

procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
procedure ProportionalSizeA(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);

procedure KeepProportions(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer);
procedure CenterBitmap24To32ImageList(var Bitmap: TBitmap; ImageSize: Integer);

implementation

procedure ThreadDraw(S, D: TBitmap; X, Y: Integer);
var
  SXp, DXp: array of PARGB;
  Ymax, Xmax: Integer;
  I, J: Integer;
begin
  if S.Width - 1 + X > D.Width - 1 then
    Xmax := D.Width - X - 1
  else
    Xmax := S.Width - 1;

  if S.Height - 1 + Y > D.Height - 1 then
    Ymax := D.Height - Y - 1
  else
    Ymax := S.Height - 1;

  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  SetLength(SXp, S.Height);
  for I := 0 to S.Height - 1 do
    SXp[I] := S.ScanLine[I];
  SetLength(DXp, D.Height);
  for I := 0 to D.Height - 1 do
    DXp[I] := D.ScanLine[I];

  for I := 0 to Ymax do
    for J := 0 to Xmax do
      DXp[I + Y, J + X] := SXp[I, J];
end;

procedure ProportionalSizeA(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
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
  begin
    Exit;
  end;
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

procedure SelectedColor(Image: TBitmap; Color: TColor);
var
  I, J, R, G, B: Integer;
  P: PARGB;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  if Image.PixelFormat <> Pf24bit then
    Image.PixelFormat := Pf24bit;

  for I := 0 to Image.Height - 1 do
  begin
    P := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
      if Odd(I + J) then
      begin
        P[J].R := R;
        P[J].G := G;
        P[J].B := B;
      end;
  end;
end;

function MixBytes(FG, BG, TRANS: Byte): Byte;
 asm
  push bx  // push some regs
  push cx
  push dx
  mov DH,TRANS // remembering Transparency value (or Opacity - as you like)
  mov BL,FG    // filling registers with our values
  mov AL,DH    // BL = ForeGround (FG)
  mov CL,BG    // CL = BackGround (BG)
  xor AH,AH    // Clear High-order parts of regs
  xor BH,BH
  xor CH,CH
  mul BL       // AL=AL*BL
  mov BX,AX    // BX=AX
  xor AH,AH
  mov AL,DH
  xor AL,$FF   // AX=(255-TRANS)
  mul CL       // AL=AL*CL
  add AX,BX    // AX=AX+BX
  shr AX,8     // Fine! Here we have mixed value in AL
  pop dx       // Hm... No rubbish after us, ok?
  pop cx
  pop bx       // Bye, dear Assembler - we go home to Delphi!
end;

function MaxI8(A, B : Byte) : Byte; inline; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function MinI8(A, B : Byte) : Byte; inline; overload;
begin
  if A > B then
    Result := B
  else
    Result := A;
end;

function MaxI32(A, B : Integer) : Integer; inline; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function MinI32(A, B : Integer) : Integer; inline; overload;
begin
  if A > B then
    Result := B
  else
    Result := A;
end;

procedure AssignBitmap(Dest: TBitmap; Src: TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
begin
  if Src.PixelFormat <> pf32bit then
  begin
    Src.PixelFormat := pf24bit;
    Dest.PixelFormat := pf24bit;
    Dest.SetSize(Src.Width, Src.Height);

    for I := 0 to Src.Height - 1 do
    begin
      PD := Dest.ScanLine[I];
      PS := Src.ScanLine[I];
      for J := 0 to Src.Width - 1 do
        PD[J] := PS[J];
    end;
  end else
  begin
    Src.PixelFormat := pf32bit;
    Dest.PixelFormat := pf32bit;
    Dest.SetSize(Src.Width, Src.Height);

    for I := 0 to Src.Height - 1 do
    begin
      PD32 := Dest.ScanLine[I];
      PS32 := Src.ScanLine[I];
      for J := 0 to Src.Width - 1 do
        PD32[J] := PS32[J];
    end;
  end;
end;

procedure Rotate180A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[I];
        PD := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD[J] := PS[Image.Width - 1 - J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[I];
        PD32 := Bitmap.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PD32[J] := PS32[Image.Width - 1 - J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure Rotate270A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB;
  PS32: PARGB32;
  PA: array of PARGB;
  PA32: array of PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA[I] := Bitmap.ScanLine[Bitmap.Height - 1 - I];
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[I];
        for J := 0 to Image.Width - 1 do
          PA[J, I] := PS[J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA32, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA32[I] := Bitmap.ScanLine[Bitmap.Height - 1 - I];
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[I];
        for J := 0 to Image.Width - 1 do
          PA32[J, I] := PS32[J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure Rotate90A(Bitmap: TBitmap);
var
  I, J: Integer;
  PS: PARGB;
  PS32: PARGB32;
  PA: array of PARGB;
  PA32: array of PARGB32;
  Image: TBitmap;
begin
  Image := TBitmap.Create;
  try
    if Bitmap.PixelFormat <> pf32bit then
    begin
      Bitmap.PixelFormat := pf24bit;
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA[J, I] := PS[J];
      end;
    end else
    begin
      AssignBitmap(Image, Bitmap);
      Bitmap.SetSize(Image.Height, Image.Width);
      SetLength(PA32, Bitmap.Height);
      for I := 0 to Bitmap.Height - 1 do
        PA32[I] := Bitmap.ScanLine[I];
      for I := 0 to Image.Height - 1 do
      begin
        PS32 := Image.ScanLine[Image.Height - I - 1];
        for J := 0 to Image.Width - 1 do
          PA32[J, I] := PS32[J];
      end;
    end;
  finally
    F(Image);
  end;
end;

procedure ApplyRotate(Bitmap: TBitmap; RotateValue: Integer);
begin
  case RotateValue of
    DB_IMAGE_ROTATE_270,
    - 10 * DB_IMAGE_ROTATE_270:
      Rotate270A(Bitmap);
    DB_IMAGE_ROTATE_90,
    - 10 * DB_IMAGE_ROTATE_90:
      Rotate90A(Bitmap);
    DB_IMAGE_ROTATE_180,
    - 10 * DB_IMAGE_ROTATE_180:
      Rotate180A(Bitmap);
  end;
end;

procedure StretchA(Width, Height: Integer; S, D: TBitmap);
var
  I, J: Integer;
  P1: PARGB;
  Sh, Sw: Extended;
  Xp: array of PARGB;
  Y : Integer;
  XAr: array of Integer;
begin
  D.SetSize(100, 100);
  Sw := S.Width / Width;
  Sh := S.Height / Height;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];

  SetLength(XAr, Width);
  for J := 0 to Width - 1 do
    XAr[J] := Round(Sw * J);

  for I := 0 to Height - 1 do
  begin
    P1 := D.ScanLine[I];
    Y := Round(Sh * I);
    for J := 0 to Width - 1 do
      P1[J] := Xp[Y, XAr[J]];
  end;
end;

procedure DoResize(Width, Height: Integer; S, D: TBitmap);
begin
  if (Width = 0) or (Height = 0) then
    Exit;
  if (S.Width = 0) or (S.Height = 0) then
    Exit;

  if ((Width / S.Width > 1) or (Height / S.Height > 1)) then
  begin
    if (S.Width > 2) and (S.Height > 2) then
      Interpolate(0, 0, Width, Height, Rect(0, 0, S.Width, S.Height), S, D)
    else
      StretchCool(Width, Height, S, D);
  end else
  begin
    if ((S.Width div Width >= 8) or (S.Height div Height >= 8)) and
      (S.Width > 2) and (S.Height > 2) then
      QuickReduce(Width, Height, S, D)
    else
    begin
      if (Width / S.Width > ZoomSmoothMin) and (S.Width > 1) then
        SmoothResize(Width, Height, S, D)
      else
        StretchCool(Width, Height, S, D);
    end;
  end;
end;


procedure StretchCool(X, Y, Width, Height: Integer; S, D: TBitmap);
var
  i,j,k,p,Sheight1:integer;
  P1: Pargb;
  Col, R, G, B: Integer;
  Sh, Sw: Extended;
  Xp: array of PARGB;
  S_h, S_w: Integer;
  XAW : array of Integer;
  YMin, YMax : Integer;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Sheight1 := S.Height - 1;
  SetLength(Xp, S.Height);
  for I := 0 to Sheight1 do
    Xp[I] := S.ScanLine[I];
  S_w := S.Width - 1;
  S_h := S.Height - 1;
  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Max(0, Y) to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    YMin := Max(0, Round(Sh * (I - Y)));
    YMax := Min(S_h, Round(Sh * (I - Y + 1 )) - 1);
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to XAW[J + 1] - 1 do
        begin
          if P > S_w then
            Break;
          Inc(Col);
          Inc(R, Xp[K, P].R);
          Inc(G, Xp[K, P].G);
          Inc(B, Xp[K, P].B);
        end;
      end;
      if (Col <> 0) and (J + X > 0) then
      begin
        P1[J + X].R := R div Col;
        P1[J + X].G := G div Col;
        P1[J + X].B := B div Col;
      end;
    end;
  end;
end;

procedure Interpolate(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap);
var
  Z1, Z2: single;
  K: Single;
  I, J, SW: Integer;
  Dw, Dh, Xo, Yo: Integer;
  Y1r: Extended;
  XS, XD: array of PARGB;
  XS32, XD32: array of PARGB32;
  Dx, Dy, Dxjx1r: Extended;
  XAW : array of Integer;
  XAWD : array of Extended;
begin
  if not ((S.PixelFormat = pf32bit) and (D.PixelFormat = pf32bit)) then
  begin
    S.PixelFormat := pf24bit;
    D.PixelFormat := pf24bit;
  end;
  D.SetSize(Math.Max(D.Width, X + Width), Math.Max(D.Height, Y + Height));
  SW := S.Width;
  DW := Math.Min(D.Width - X, X + Width);
  DH := Math.Min(D.Height - y, Y + Height);
  DX := Width / (Rect.Right - Rect.Left - 1);
  DY := Height / (Rect.Bottom - Rect.Top - 1);
  if (Dx < 1) and (Dy < 1) then
    Exit;

  if (S.PixelFormat = pf24Bit) then
  begin
    SetLength(Xs, S.Height);
    for I := 0 to S.Height - 1 do
      XS[I] := S.Scanline[I];
    SetLength(Xd, D.Height);
    for I := 0 to D.Height - 1 do
      XD[I] := D.Scanline[I];
  end else
  begin
    SetLength(XS32, S.Height);
    for I := 0 to S.Height - 1 do
      XS32[I] := S.Scanline[I];
    SetLength(XD32, D.Height);
    for I := 0 to D.Height - 1 do
      XD32[I] := D.Scanline[I];
  end;

  SetLength(XAW, Width + 1);
  SetLength(XAWD, Width + 1);
  for I := 0 to Width do
  begin
    XAW[I] := FastTrunc(I / Dx);
    XAWD[I] := I / Dx - XAW[I];
  end;

  if (S.PixelFormat = pf24Bit) then
  begin
    for I := 0 to Min(Round((Rect.Bottom - Rect.Top - 1) * DY) - 1, DH - 1) do
    begin
      Yo := FastTrunc(I / Dy) + Rect.Top;
      Y1r := FastTrunc(I / Dy) * Dy;
      if Yo > S.Height then
        Break;
      if I + Y < 0 then
        Continue;

      for J := 0 to Min(Round((Rect.Right - Rect.Left - 1) * DX) - 1, DW - 1) do
      begin
        Xo := XAW[J] + Rect.Left;
        if Xo > SW then
          Continue;
        if J + X < 0 then
          Continue;

        Dxjx1r := XAWD[J];

        Z1 := (Xs[Yo, Xo + 1].R - Xs[Yo, Xo].R) * Dxjx1r + Xs[Yo, Xo].R;
        Z2 := (Xs[Yo + 1, Xo + 1].R - Xs[Yo + 1, Xo].R) * Dxjx1r + Xs[Yo + 1, Xo].R;
        k := (z2 - Z1) / Dy;
        Xd[I + Y, J + X].R := Round(I * K + Z1 - Y1r * K);

        Z1 := (Xs[Yo, Xo + 1].G - Xs[Yo, Xo].G)* Dxjx1r + Xs[Yo, Xo].G;
        Z2 := (Xs[Yo + 1, Xo + 1].G - Xs[Yo + 1, Xo].G) * Dxjx1r + Xs[Yo + 1, Xo].G;
        K := (Z2 - Z1) / Dy;
        Xd[I + Y, J + X].G := Round(I * K + Z1 - Y1r * K);

        Z1 := (Xs[Yo, Xo + 1].B - Xs[Yo, Xo].B) * Dxjx1r + Xs[Yo, Xo].B;
        Z2 := (Xs[Yo + 1, Xo + 1].B - Xs[Yo + 1, Xo].B)  * Dxjx1r + Xs[Yo + 1, Xo].B;
        K := (Z2 - Z1) / Dy;
        Xd[I + Y, J + X].B := Round(I * K + Z1 - Y1r * K);
      end;
    end;
  end else
  begin
    for I := 0 to Min(Round((Rect.Bottom - Rect.Top - 1) * DY) - 1, DH - 1) do
    begin
      Yo := FastTrunc(I / Dy) + Rect.Top;
      Y1r := FastTrunc(I / Dy) * Dy;
      if Yo > S.Height then
        Break;
      if I + Y < 0 then
        Continue;

      for J := 0 to Min(Round((Rect.Right - Rect.Left - 1) * DX) - 1, DW - 1) do
      begin
        Xo := XAW[J] + Rect.Left;
        if Xo > SW then
          Continue;
        if J + X < 0 then
          Continue;

        Dxjx1r := XAWD[J];

        Z1 := (XS32[Yo, Xo + 1].R - XS32[Yo, Xo].R) * Dxjx1r + XS32[Yo, Xo].R;
        Z2 := (XS32[Yo + 1, Xo + 1].R - XS32[Yo + 1, Xo].R) * Dxjx1r + XS32[Yo + 1, Xo].R;
        k := (z2 - Z1) / Dy;
        XD32[I + Y, J + X].R := Round(I * K + Z1 - Y1r * K);

        Z1 := (XS32[Yo, Xo + 1].G - XS32[Yo, Xo].G)* Dxjx1r + XS32[Yo, Xo].G;
        Z2 := (XS32[Yo + 1, Xo + 1].G - XS32[Yo + 1, Xo].G) * Dxjx1r + XS32[Yo + 1, Xo].G;
        K := (Z2 - Z1) / Dy;
        XD32[I + Y, J + X].G := Round(I * K + Z1 - Y1r * K);

        Z1 := (XS32[Yo, Xo + 1].B - XS32[Yo, Xo].B) * Dxjx1r + XS32[Yo, Xo].B;
        Z2 := (XS32[Yo + 1, Xo + 1].B - XS32[Yo + 1, Xo].B)  * Dxjx1r + XS32[Yo + 1, Xo].B;
        K := (Z2 - Z1) / Dy;
        XD32[I + Y, J + X].B := Round(I * K + Z1 - Y1r * K);

        Z1 := (XS32[Yo, Xo + 1].L - XS32[Yo, Xo].L) * Dxjx1r + XS32[Yo, Xo].L;
        Z2 := (XS32[Yo + 1, Xo + 1].L - XS32[Yo + 1, Xo].L)  * Dxjx1r + XS32[Yo + 1, Xo].L;
        K := (Z2 - Z1) / Dy;
        XD32[I + Y, J + X].L := Round(I * K + Z1 - Y1r * K);
      end;
    end;
  end;
end;

procedure QuickReduce(NewWidth, NewHeight: Integer; D, S: TBitmap);
var
  X, Y, Xi1, Yi1, Xi2, Yi2, Xx, Yy, Lw1: Integer;
  Bufw, Bufh, Outw, Outh: Integer;
  Sumr, Sumb, Sumg, Suml, Pixcnt: Dword;
  AdrIn, AdrOut, AdrLine0, DeltaLine, DeltaLine2: Integer;
begin
{$R-}
  if not ((S.PixelFormat = pf32Bit) and (D.PixelFormat = pf32Bit)) then
  begin
    S.PixelFormat := pf24Bit;
    D.PixelFormat := pf24Bit;
  end;
  S.SetSize(NewWidth, NewHeight);
  bufw := D.Width;
  bufh := D.Height;
  outw := S.Width;
  outh := S.Height;
  adrLine0 := Integer(D.ScanLine[0]);
  deltaLine := 0;
  if D.Height > 1 then
    deltaLine := Integer(D.ScanLine[1]) - adrLine0;
  yi2 := 0;

  if S.PixelFormat = pf32Bit then
  begin

    for y := 0 to outh-1 do
    begin
      adrOut := DWORD(S.ScanLine[y]);
      yi1 := yi2 {+ 1};
      yi2 := ((y+1) * bufh) div outh - 1;
      if yi2 > bufh-1 then yi2 := bufh;
      xi2 := 0;
      for x := 0 to outw-1 do
      begin
        xi1 := xi2 {+ 1};
        xi2 := ((x+1) * bufw) div outw - 1;
        if xi2 > bufw-1 then xi2 := bufw-1; //
        lw1 := xi2-xi1+1;
        deltaLine2 := deltaLine - lw1*4;
        sumb := 0;
        sumg := 0;
        sumr := 0;
        suml := 0;
        adrIn := adrLine0 + yi1*deltaLine + xi1*4;
        for yy := yi1 to yi2 do
        begin
          for xx := 1 to lw1 do
          begin
            Inc(sumb, PByte(adrIn+0)^);
            Inc(sumg, PByte(adrIn+1)^);
            Inc(sumr, PByte(adrIn+2)^);
            Inc(suml, PByte(adrIn+3)^);
            Inc(adrIn, 4);
          end;
          Inc (adrIn, deltaLine2);
        end;
        pixcnt := (yi2-yi1+1)*lw1;
        if pixcnt<>0 then
        begin
         PByte(adrOut+0)^ := sumb div pixcnt;
         PByte(adrOut+1)^ := sumg div pixcnt;
         PByte(adrOut+2)^ := sumr div pixcnt;
         PByte(adrOut+3)^ := suml div pixcnt;
        end;
        Inc(adrOut, 4);
      end;
    end;
  end else
  begin
    for y := 0 to outh-1 do
    begin
      adrOut := DWORD(S.ScanLine[y]);
      yi1 := yi2 {+ 1};
      yi2 := ((y+1) * bufh) div outh - 1;
      if yi2 > bufh-1 then yi2 := bufh;
      xi2 := 0;
      for x := 0 to outw-1 do
      begin
        xi1 := xi2 {+ 1};
        xi2 := ((x+1) * bufw) div outw - 1;
        if xi2 > bufw-1 then xi2 := bufw-1; //
        lw1 := xi2-xi1+1;
        deltaLine2 := deltaLine - lw1*3;
        sumb := 0;
        sumg := 0;
        sumr := 0;
        adrIn := adrLine0 + yi1*deltaLine + xi1*3;
        for yy := yi1 to yi2 do
        begin
          for xx := 1 to lw1 do
          begin
            Inc(sumb, PByte(adrIn+0)^);
            Inc(sumg, PByte(adrIn+1)^);
            Inc(sumr, PByte(adrIn+2)^);
            Inc(adrIn, 3);
          end;
          Inc (adrIn, deltaLine2);
        end;
        pixcnt := (yi2-yi1+1)*lw1;
        if pixcnt<>0 then
        begin
         PByte(adrOut+0)^ := sumb div pixcnt;
         PByte(adrOut+1)^ := sumg div pixcnt;
         PByte(adrOut+2)^ := sumr div pixcnt;
        end;
        Inc(adrOut, 3);
      end;
    end;
  end;
end;

procedure StretchCool(Width, Height: Integer; S, D: TBitmap);
var
  I, J, K, F: Integer;
  P: PARGB;
  XP: array of PARGB;
  P32: PARGB32;
  XP32: array of PARGB32;
  Count, R, G, B, L, Sheight1, SHI, SWI: Integer;
  SH, SW: Extended;
  YMin, YMax: Integer;
  XAW: array of Integer;
begin
  if Width + Height = 0 then
    Exit;

  if S.PixelFormat = Pf32bit then
    D.PixelFormat := pf32bit
  else
  begin
    S.PixelFormat := pf24bit;
    D.PixelFormat := pf24bit;
  end;
  D.Width := Width;
  D.Height := Height;
  SH := S.Height / Height;
  SW := S.Width / Width;
  Sheight1 := S.height - 1;
  SHI := S.Height;
  SWI := S.Width;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Ceil(SW * I);

  if S.PixelFormat = pf24bit then
  begin
    SetLength(XP, S.height);
    for I := 0 to Sheight1 do
      XP[I] := S.ScanLine[I];

    for I := 0 to Height - 1 do
    begin
      P := D.ScanLine[I];
      YMin := Round(SH * I);
      YMax := MinI32(SHI - 1, Ceil(SH * (I + 1)) - 1);
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        for K := YMin to YMax do
        begin
          for F := XAW[J] to MinI32(SWI - 1, XAW[J + 1] - 1) do
          begin
            Inc(Count);
            Inc(R, XP[K, F].R);
            Inc(G, XP[K, F].G);
            Inc(B, XP[K, F].B);
          end;
        end;
        if Count <> 0 then
        begin
          P[J].R := R div Count;
          P[J].G := G div Count;
          P[J].B := B div Count;
        end;
      end;
    end;
  end else
  begin
    SetLength(XP32, S.height);
    for I := 0 to Sheight1 do
      XP32[I] := S.ScanLine[I];

    for I := 0 to Height - 1 do
    begin
      P32 := D.ScanLine[I];
      YMin := Round(SH * I);
      YMax := MinI32(SHI - 1, Ceil(SH * (I + 1)) - 1);
      for J := 0 to Width - 1 do
      begin
        Count := 0;
        R := 0;
        G := 0;
        B := 0;
        L := 0;
        for K := YMin to YMax do
        begin
          for F := XAW[J] to MinI32(SWI - 1, XAW[J + 1] - 1) do
          begin
            Inc(Count);
            Inc(R, XP32[K, F].R);
            Inc(G, XP32[K, F].G);
            Inc(B, XP32[K, F].B);
            Inc(L, XP32[K, F].L);
          end;
        end;
        if Count <> 0 then
        begin
          P32[J].R := R div Count;
          P32[J].G := G div Count;
          P32[J].B := B div Count;
          P32[J].L := L div Count;
        end;
      end;
    end;
  end;
end;

procedure QuickReduceWide(Width, Height : integer; S,D : TBitmap);
begin
  if (Width=0) or (Height=0) then
    Exit;
  if ((S.Width div Width >= 8) or (S.Height div Height >= 8)) and (S.Width > 2) and (S.Height > 2) then
    QuickReduce(Width,Height,S,D)
  else
    StretchCool(Width,Height,S,D)
end;

procedure DrawColorMaskTo32Bit(Dest, Mask: TBitmap; Color: TColor; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW: Integer;
  pS: PARGB;
  pD: PARGB32;
  R, G, B, W, W1: Byte;
begin
  Dest.PixelFormat := pf32bit;
  Mask.PixelFormat := pf24bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  DH := Dest.Height;
  DW := Dest.Width;
  SH := Mask.Height;
  SW := Mask.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Mask.ScanLine[I];
    pD := Dest.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W1 := pS[J].R;
      W := 255 - W1;
      pD[XD].R := (R * W + pD[XD].R * W1 + $7F) div $FF;
      pD[XD].G := (G * W + pD[XD].G * W1 + $7F) div $FF;
      pD[XD].B := (B * W + pD[XD].B * W1 + $7F) div $FF;
      pD[XD].L := ($FF * W + pD[XD].L * W1 + $7F) div $FF;
    end;
  end;
end;

procedure DrawImageEx24To32(Dest32, Src24 : TBitmap; X, Y : Integer; NewTransparent : Byte = 0);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW: Integer;
  pS: PARGB;
  pD: PARGB32;
begin
  DH := Dest32.Height;
  DW := Dest32.Width;
  SH := Src24.Height;
  SW := Src24.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src24.ScanLine[I];
    pD := Dest32.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;
      pD[XD].R := pS[J].R;
      pD[XD].G := pS[J].G;
      pD[XD].B := pS[J].B;
      pD[XD].L := NewTransparent;
    end;
  end;
end;

procedure DrawImageEx32To32(Dest32, Src32: TBitmap; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW: Integer;
  pS,
  pD: PARGB32;
begin
  DH := Dest32.Height;
  DW := Dest32.Width;
  SH := Src32.Height;
  SW := Src32.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src32.ScanLine[I];
    pD := Dest32.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;
      pD[XD].R := pS[J].R;
      pD[XD].G := pS[J].G;
      pD[XD].B := pS[J].B;
      pD[XD].L := pS[J].L;
    end;
  end;
end;

procedure DrawImageEx32To24(Dest24, Src32: TBitmap; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW : Integer;
  W1, W: Byte;
  pD: PARGB;
  pS: PARGB32;
begin
  DH := Dest24.Height;
  DW := Dest24.Width;
  SH := Src32.Height;
  SW := Src32.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src32.ScanLine[I];
    pD := Dest24.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W := pS[J].L;
      W1 := 255 - W;
      pD[XD].R := (pD[XD].R * W1 + pS[J].R * W + $7F) div $FF;
      pD[XD].G := (pD[XD].G * W1 + pS[J].G * W + $7F) div $FF;
      pD[XD].B := (pD[XD].B * W1 + pS[J].B * W + $7F) div $FF;
    end;
  end;
end;

procedure DrawImageEx32(Dest32, Src32: TBitmap; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW : Integer;
  W1, W: Byte;
  pD, pS: PARGB32;
begin
  DH := Dest32.Height;
  DW := Dest32.Width;
  SH := Src32.Height;
  SW := Src32.Width;
  InitSumLMatrix;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src32.ScanLine[I];
    pD := Dest32.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;

      W := pS[J].L;
      W1 := 255 - W;
      pD[XD].R := (pD[XD].R * W1 + pS[J].R * W + $7F) div $FF;
      pD[XD].G := (pD[XD].G * W1 + pS[J].G * W + $7F) div $FF;
      pD[XD].B := (pD[XD].B * W1 + pS[J].B * W + $7F) div $FF;
      pD[XD].L := SumLMatrix[pD[XD].L, W];
    end;
  end;
end;

procedure DrawImageEx(Dest, Src: TBitmap; X, Y: Integer);
var
  I, J,
  XD, YD,
  DH, DW,
  SH, SW: Integer;
  pS: PARGB;
  pD: PARGB;
begin
  DH := Dest.Height;
  DW := Dest.Width;
  SH := Src.Height;
  SW := Src.Width;
  for I := 0 to SH - 1 do
  begin
    YD := I + Y;
    if (YD >= DH) then
      Break;
    pS := Src.ScanLine[I];
    pD := Dest.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin
      XD := J + X;
      if (XD >= DW) then
        Break;
      pD[XD] := pS[J];
    end;
  end;
end;

procedure DrawImageExRect(Dest, Src: TBitmap; SX, SY, SW, SH: Integer; DX, DY: Integer);
var
  I, J,
  XD, YD, YS, XS,
  DHeight, DWidth, SHeight, SWidth : integer;
  pS: PARGB;
  pD: PARGB;
begin
  DHeight := Dest.Height;
  DWidth := Dest.Width;
  SHeight := Src.Height;
  SWidth := Src.Width;
  for I := 0 to SW - 1 do
  begin

    YD := I + DY;
    if (YD >= DHeight) then
      Break;
    YS := I + SY;
    if (YD >= SHeight) then
      Break;

    pS := Src.ScanLine[YS];
    pD := Dest.ScanLine[YD];
    for J := 0 to SW - 1 do
    begin

      XD := J + DX;
      if (XD >= DWidth) then
        Break;
      XS := J + DY;
      if (XS >= SWidth) then
        Break;

      pD[XD] := pS[XS];
    end;
  end;
end;

procedure FillTransparentColor(Bitmap: TBitmap; Color: TColor; TransparentValue: Byte = 0);
var
  I, J: Integer;
  p: PARGB32;
  R, G, B: Byte;
begin
  Bitmap.PixelFormat := pf32Bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  for I := 0 to Bitmap.Height - 1 do
  begin
    p := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      p[j].R := R;
      p[j].G := G;
      p[j].B := B;
      p[j].L := TransparentValue;
    end;
  end;
end;

procedure FillColorEx(Bitmap: TBitmap; Color: TColor);
var
  I, J : Integer;
  p : PARGB;
  R, G, B : Byte;
begin
  Bitmap.PixelFormat := Pf24Bit;
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  if Bitmap.PixelFormat = pf24bit then
  begin
    for I := 0 to Bitmap.Height - 1 do
    begin
      P := Bitmap.ScanLine[I];
      for J := 0 to Bitmap.Width - 1 do
      begin
        P[J].R := R;
        P[J].G := G;
        P[J].B := B;
      end;
    end;
  end;
end;

procedure LoadBMPImage32bit(S: TBitmap; D: TBitmap; BackGroundColor: TColor);
var
  I, J, W1, W2: integer;
  PD : PARGB;
  PS : PARGB32;
  R, G, B : byte;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  if D.PixelFormat <> pf24bit then
    D.PixelFormat := pf24bit;
  D.SetSize(S.Width, S.Height);

  for I := 0 to S.Height - 1 do
  begin
    PD := D.ScanLine[I];
    PS := S.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      W1 := PS[J].L;
      W2 := 255 - W1;
      PD[J].R := (R * W2 + PS[J].R * W1 + $7F) div $FF;
      PD[J].G := (G * W2 + PS[J].G * W1 + $7F) div $FF;
      PD[J].B := (B * W2 + PS[J].B * W1 + $7F) div $FF;
    end;
  end;
end;


procedure GrayScale(Image: TBitmap);
var
  I, J, C: Integer;
  P: PARGB;
begin
  Image.PixelFormat := pf24bit;

  for I := 0 to Image.Height - 1 do
  begin
    p := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
    begin
      C := (p[J].R * 77 + p[J].G * 151 + p[J].B * 28) shr 8;
      p[J].R := C;
      p[J].G := C;
      p[J].B := C;
    end;
  end;
end;

procedure GrayScaleImage(S, D: TBitmap; N: Integer);
var
  I, J: Integer;
  P1, P2: Pargb;
  G: Byte;
  W1, W2: Byte;
begin
  W1 := Round((N / 100) * 255);
  W2 := 255 - W1;
  for I := 0 to S.Height - 1 do
  begin
    P1 := S.ScanLine[I];
    P2 := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      G := (P1[J].R * 77 + P1[J].G * 151 + P1[J].B * 28) shr 8;
      P2[J].R := (W2 * P2[J].R + W1 * G) shr 8;
      P2[J].G := (W2 * P2[J].G + W1 * G) shr 8;
      P2[J].B := (W2 * P2[J].B + W1 * G) shr 8;
    end;
  end;
end;

procedure DrawTransparent(S, D: TBitmap; Transparent: Byte);
var
  W1, W2, I, J: Integer;
  PS, PD : PARGB;
begin
  W1 := Transparent;
  W2 := 255 - W1;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    pd := D.ScanLine[I];
    for J := 0 to S.Width - 1 do
    begin
      PD[J].R := (PD[J].R * W2 + PS[J].R * W1 + $7F) div $FF;
      PD[J].G := (PD[J].G * W2 + PS[J].G * W1 + $7F) div $FF;
      PD[J].B := (PD[J].B * W2 + PS[J].B * W1 + $7F) div $FF;
    end;
  end;
end;

procedure DrawRoundGradientVert(Dest: TBitmap; Rect: TRect; ColorFrom, ColorTo, BorderColor: TColor;
  RoundRect: Integer; TransparentValue: Byte = 220);
var
  BitRound: TBitmap;
  PR, PD24: PARGB;
  PD32: PARGB32;
  I, J: Integer;
  RF, GF, BF, RT, GT, BT, R, G, B, W, W1: Byte;
  RB, GB, BB: Byte;
  S: Integer;
begin
  ColorFrom := ColorToRGB(ColorFrom);
  ColorTo := ColorToRGB(ColorTo);
  BorderColor := ColorToRGB(BorderColor);
  RF := GetRValue(ColorFrom);
  GF := GetGValue(ColorFrom);
  BF := GetBValue(ColorFrom);
  RT := GetRValue(ColorTo);
  GT := GetGValue(ColorTo);
  BT := GetBValue(ColorTo);
  RB := GetRValue(BorderColor);
  GB := GetGValue(BorderColor);
  BB := GetBValue(BorderColor);
  if BB = 255 then
    BB := 254;
  BorderColor := RGB(RB, GB, BB);
  BitRound := TBitmap.Create;
  try
    BitRound.PixelFormat := pf24Bit;
    BitRound.SetSize(Dest.Width, Dest.Height);
    BitRound.Canvas.Brush.Color := clWhite;
    BitRound.Canvas.Pen.Color := clWhite;
    BitRound.Canvas.Rectangle(0, 0, Dest.Width, Dest.Height);
    BitRound.Canvas.Brush.Color := clBlack;
    BitRound.Canvas.Pen.Color := BorderColor;
    Windows.RoundRect(BitRound.Canvas.Handle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, RoundRect, RoundRect);

    if Dest.PixelFormat = pf32Bit then
    begin
      for I := 0 to Dest.Height - 1 do
      begin
        PR := BitRound.ScanLine[I];
        PD32 := Dest.ScanLine[I];
        if (Rect.Top > I) or (I > Rect.Bottom) then
           Continue;

        W := Round(255 * (I + 1 - Rect.Top) / (Rect.Bottom - Rect.Top));
        W1 := 255 - W;
        R := (RF * W + RT * W1 + $7F) div 255;
        G := (GF * W + GT * W1 + $7F) div 255;
        B := (BF * W + BT * W1 + $7F) div 255;
        for J := 0 to Dest.Width - 1 do
        begin
          S := (PR[J].R + PR[J].G + PR[J].B);
          if S <> 765 then //White
          begin
            PD32[J].L := TransparentValue;
            //black - gradient
            if S = 0 then
            begin
              PD32[J].R := R;
              PD32[J].G := G;
              PD32[J].B := B;
            end else //border
            begin
              PD32[J].R := RB;
              PD32[J].G := GB;
              PD32[J].B := BB;
            end;
          end;
        end;
      end;
    end else
    begin
      Dest.PixelFormat := pf24Bit;
      for I := 0 to Dest.Height - 1 do
      begin
        PR := BitRound.ScanLine[I];
        PD24 := Dest.ScanLine[I];
        if (Rect.Top > I) or (I > Rect.Bottom) then
           Continue;

        W := Round(255 * (I + 1 - Rect.Top) / (Rect.Bottom - Rect.Top));
        W1 := 255 - W;
        R := (RF * W + RT * W1 + $7F) div 255;
        G := (GF * W + GT * W1 + $7F) div 255;
        B := (BF * W + BT * W1 + $7F) div 255;
        for J := 0 to Dest.Width - 1 do
        begin
          S := (PR[J].R + PR[J].G + PR[J].B);
          if S <> 765 then //White
          begin
            W1 := TransparentValue;
            W := 255 - W1;
            //black - gradient
            if S = 0 then
            begin
              PD24[J].R := (PD24[J].R * W + R * W1 + $7F) div $FF;
              PD24[J].G := (PD24[J].G * W + G * W1 + $7F) div $FF;
              PD24[J].B := (PD24[J].B * W + B * W1 + $7F) div $FF;
            end else //border
            begin
              PD24[J].R := (PD24[J].R * W + RB * W1 + $7F) div $FF;
              PD24[J].G := (PD24[J].G * W + GB * W1 + $7F) div $FF;
              PD24[J].B := (PD24[J].B * W + BB * W1 + $7F) div $FF;
            end;
          end;
        end;
      end;
    end;

  finally
    F(BitRound);
  end;
end;

procedure DrawShadowToImage(Dest32, Src: TBitmap; Transparenty: Byte = 0);
var
  I, J: Integer;
  PS: PARGB;
  PS32: PARGB32;
  PDA: array of PARGB32;
  SH, SW: Integer;
  AddrLineD, DeltaD, AddrD: Integer;
  PD: PRGB32;
  W, W1: Byte;

const
  SHADOW: array[0..6, 0..6] of byte =
  ((8,14,22,26,22,14,8),
  (14,0,0,0,52,28,14),
  (22,0,0,0,94,52,22),
  (26,0,0,0,124,66,26),
  (22,52,94,{124}94,94,52,22),
  (14,28,52,66,52,28,14),
  (8,14,22,26,22,14,8));

begin
  //set new image size
  Dest32.PixelFormat := pf32Bit;
  SW := Src.Width;
  SH := Src.Height;
  Dest32.SetSize(SW + 4, SH + 4);
  SetLength(PDA, Dest32.Height);

  AddrLineD := Integer(Dest32.ScanLine[0]);
  DeltaD := 0;
  if Dest32.Height > 1 then
    DeltaD := Integer(Dest32.ScanLine[1])- AddrLineD;

  //buffer scanlines
  for I := 0 to Dest32.Height - 1 do
    PDA[I] := Dest32.ScanLine[I];

  //min size of shadow - 5x5 px
  //top-left
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I][J].R := 0;
      PDA[I][J].G := 0;
      PDA[I][J].B := 0;
      PDA[I][J].L := SHADOW[I, J];
    end;

  //top-bottom
  for I := 3 to Src.Height do
  begin
    PDA[I][0].R := 0;
    PDA[I][0].G := 0;
    PDA[I][0].B := 0;
    PDA[I][0].L := SHADOW[3, 0];
    for J := 0 to 2 do
    begin
      PDA[I][J + SW + 1].R := 0;
      PDA[I][J + SW + 1].G := 0;
      PDA[I][J + SW + 1].B := 0;
      PDA[I][J + SW + 1].L := SHADOW[4, 2 - J];
    end;
  end;

  //left-right
  for I := 3 to Src.Width do
  begin
    PDA[0][I].R := 0;
    PDA[0][I].G := 0;
    PDA[0][I].B := 0;
    PDA[0][I].L := SHADOW[0, 3];
    for J := 0 to 2 do
    begin
      PDA[J + SH + 1][I].R := 0;
      PDA[J + SH + 1][I].G := 0;
      PDA[J + SH + 1][I].B := 0;
      PDA[J + SH + 1][I].L := SHADOW[4, 2 - J];
    end;
  end;

  //left-bottom
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I + SH + 1][J].R := 0;
      PDA[I + SH + 1][J].G := 0;
      PDA[I + SH + 1][J].B := 0;
      PDA[I + SH + 1][J].L := SHADOW[I + 4, J];
    end;

  //top-right
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I][J + SW + 1].R := 0;
      PDA[I][J + SW + 1].G := 0;
      PDA[I][J + SW + 1].B := 0;
      PDA[I][J + SW + 1].L := SHADOW[I, J + 4];
    end;

  //bottom-right
  for I := 0 to 2 do
    for J := 0 to 2 do
    begin
      PDA[I + SH + 1][J + SW + 1].R := 0;
      PDA[I + SH + 1][J + SW + 1].G := 0;
      PDA[I + SH + 1][J + SW + 1].B := 0;
      PDA[I + SH + 1][J + SW + 1].L := SHADOW[I + 4, J + 4];
    end;

  //and draw image
  if Src.PixelFormat <> pf32bit then
  begin
    Src.PixelFormat := pf24bit;
    AddrLineD := AddrLineD + DeltaD;
    for I := 0 to Src.Height - 1 do
    begin
      PS := Src.ScanLine[I];
      AddrD := AddrLineD + 4; //from second fixel
      for J := 0 to Src.Width - 1 do
      begin
        PD := PRGB32(AddrD);
        PD.R := PS[J].R;
        PD.G := PS[J].G;
        PD.B := PS[J].B;
        PD.L := 255;
        AddrD := AddrD + 4;
      end;
      AddrLineD := AddrLineD + DeltaD;
    end;
  end else
  begin
    AddrLineD := AddrLineD + DeltaD;
    for I := 0 to Src.Height - 1 do
    begin
      PS32 := Src.ScanLine[I];
      AddrD := AddrLineD + 4; //from second fixel
      for J := 0 to Src.Width - 1 do
      begin
        PD := PRGB32(AddrD);
        W := PS32[J].L;
        W1 := 255 - W;
        PD.R := (PD.R * W1 + PS32[J].R * W + $7F) div $FF;
        PD.G := (PD.G * W1 + PS32[J].G * W + $7F) div $FF;
        PD.B := (PD.B * W1 + PS32[J].B * W + $7F) div $FF;
        PD.L := W;
        AddrD := AddrD + 4;
      end;
      AddrLineD := AddrLineD + DeltaD;
    end;
  end;
end;

procedure DrawText32Bit(Bitmap32: TBitmap; Text: string; Font: TFont; ARect: TRect; DrawTextOptions: Cardinal);
var
  Bitmap: TBitmap;
  R: TRect;
begin
  Bitmap32.PixelFormat := pf32bit;
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24Bit;
    Bitmap.Canvas.Font.Assign(Font);
    Bitmap.Canvas.Font.Color := ClBlack;
    Bitmap.Canvas.Brush.Color := ClWhite;
    Bitmap.Canvas.Pen.Color := ClWhite;
    Bitmap.Width := ARect.Right - ARect.Left;
    Bitmap.Height := ARect.Bottom - ARect.Top;
    R := Rect(0, 0, Bitmap.Width, Bitmap.Height);
    DrawText(Bitmap.Canvas.Handle, PWideChar(Text), Length(Text), R, DrawTextOptions);
    DrawColorMaskTo32Bit(Bitmap32, Bitmap, Font.Color, ARect.Left, ARect.Top);
  finally
    F(Bitmap);
  end;
end;

procedure SmoothResize(Width, Height: integer; S, D: TBitmap; CallBack: TProgressCallBackProc = nil);
type
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

var
  X, Y: Integer;
  XP, YP: Integer;
  Mx, My: Integer;
  SrcLine1, SrcLine2: PRGBArray;
  SrcLine132, SrcLine232: PARGB32;
  T3: Integer;
  Z, Z2, Iz2: Integer;
  DstLine: PRGBArray;
  DstLine32: PARGB32;
  DstGap: Integer;
  W1, W2, W3, W4, DW1, SW1: Integer;
  Terminating: Boolean;
begin
  Terminating := false;
  if not ((S.PixelFormat = pf32Bit) and (D.PixelFormat = pf32Bit)) then
  begin
    S.PixelFormat := pf24Bit;
    D.PixelFormat := pf24Bit;
  end;

  if Width * Height=0 then
  begin
    AssignBitmap(D, S);
    Exit;
  end;
  D.SetSize(Width, Height);
  if (S.Width = D.Width) and (S.Height = D.Height) then
    AssignBitmap(D, S)
  else
  begin
    DstLine := D.ScanLine[0];
    DstLine32 := PARGB32(DstLine);
    DstGap := 0;
    if D.Height > 1 then
      DstGap  := Integer(D.ScanLine[1]) - Integer(DstLine);
    Mx := MulDiv(S.Width, $10000, D.Width);
    My := MulDiv(S.Height, $10000, D.Height);
    yP  := 0;

    DW1 := D.Width - 1;
    SW1 := S.Width - 1;

    if S.PixelFormat = pf32Bit then
    begin

      for y := 0 to pred(D.Height) do
      begin
        xP := 0;

        SrcLine132 := S.ScanLine[yP shr 16];

        if (yP shr 16 < pred(S.Height))and(Y <> D.Height-1) then
          SrcLine232 := S.ScanLine[succ(yP shr 16)]
        else
        begin
          SrcLine132 := S.ScanLine[S.Height - 2];
          SrcLine232 := S.ScanLine[S.Height - 1];
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
          if (t3 >= SW1) or (x = DW1) then
           t3 := S.Width - 2;

          DstLine32[x].R := (SrcLine132[t3].R * w1 +
            SrcLine132[t3 + 1].R * w2 + SrcLine232[t3].R * w3 + SrcLine232[t3 + 1].R * w4) shr 16;

          DstLine32[x].G := (SrcLine132[t3].G * w1 + SrcLine132[t3 + 1].G * w2 +
            SrcLine232[t3].G * w3 + SrcLine232[t3 + 1].G * w4) shr 16;

          DstLine32[x].B := (SrcLine132[t3].B * w1 +  SrcLine132[t3 + 1].B * w2 +
            SrcLine232[t3].B * w3 +  SrcLine232[t3 + 1].B * w4) shr 16;

          DstLine32[x].L := (SrcLine132[t3].L * w1 + SrcLine132[t3 + 1].L * w2 +
            SrcLine232[t3].L * w3 +  SrcLine232[t3 + 1].L * w4) shr 16;

          Inc(xP, Mx);
        end; {for}
        Inc(yP, My);
        DstLine32 := PARGB32(Integer(DstLine32) + DstGap);
        if y mod 50 = 0 then
        if Assigned(CallBack) then CallBack(Round(100* Y / D.Height), Terminating);
        if Terminating then Break;
      end; {for}

    end else
    begin

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
          if (t3 >= SW1) or (x = DW1) then
           t3 := S.Width - 2;

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
    end;
  end; {if}
end; {SmoothResize}

procedure StretchCool(Width, Height: integer; S,D: TBitmap; CallBack: TProgressCallBackProc);
var
  I, J, K, P: Integer;
  P1: PARGB;
  Col, R, G, B, Sheight1, SWidth1: Integer;
  Sh, Sw: Extended;
  Xp: array of PARGB;
  Terminating: Boolean;
  YMin, YMax : Integer;
  XWA : array of Integer;
begin
  if Width = 0 then
    Exit;
  if Height = 0 then
    Exit;
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := Width;
  D.Height := Height;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Sheight1 := S.Height - 1;
  SWidth1 := S.Width - 1;
  SetLength(Xp, S.Height);
  for I := 0 to Sheight1 do
    Xp[I] := S.ScanLine[I];
  Terminating := False;
  SetLength(XWA, Width + 1);
  for I := 0 to Width do
    XWA[I] := Round(Sw * I);
  for I := 0 to Height - 1 do
  begin
    P1 := D.ScanLine[I];
    YMin := Round(Sh * I);
    YMax := Min(Round(Sh * (I + 1)) - 1, Sheight1);
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XWA[J] to Min(XWA[J + 1] - 1, SWidth1) do
        begin
          Inc(Col);
          Inc(R, Xp[K, P].R);
          Inc(G, Xp[K, P].G);
          Inc(B, Xp[K, P].B);
        end;
      end;
      if Col <> 0 then
      begin
        P1[J].R := R div Col;
        P1[J].G := G div Col;
        P1[J].B := B div Col;
      end;
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * I / Height), Terminating);
    if Terminating then
      Break;
  end;
end;

procedure Interpolate(x, y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap; CallBack: TProgressCallBackProc);
var
  Z1, Z2: Single;
  K: Single;
  I, J: Integer;
  H, Dw, Dh, Xo, Yo: Integer;
  X1r, Y1r: Extended;
  Xs, Xd: array of PARGB;
  Dx, Dy: Extended;
  Terminating: Boolean;
begin
  Terminating := False;
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  D.Width := Math.Max(D.Width, X + Width);
  D.Height := Math.Max(D.Height, Y + Height);
  Dw := Math.Min(D.Width - X, X + Width);
  Dh := Math.Min(D.Height - Y, Y + Height);
  Dx := (Width) / (Rect.Right - Rect.Left - 1);
  Dy := (Height) / (Rect.Bottom - Rect.Top - 1);
  if (Dx < 1) or (Dy < 1) then
    Exit;
  SetLength(Xs, S.Height);
  for I := 0 to S.Height - 1 do
    Xs[I] := S.Scanline[I];
  SetLength(Xd, D.Height);
  for I := 0 to D.Height - 1 do
    Xd[I] := D.Scanline[I];
  H := Min(Round((Rect.Bottom - Rect.Top - 1) * Dy) - 1, Dh - 1);
  for I := 0 to H do
  begin
    Yo := Trunc(I / Dy) + Rect.Top;
    Y1r := Trunc(I / Dy) * Dy;
    if Yo + 1 >= S.Height then
      Break;
    for J := 0 to Min(Round((Rect.Right - Rect.Left - 1) * Dx) - 1, Dw - 1) do
    begin
      Xo := Trunc(J / Dx) + Rect.Left;
      X1r := Trunc(J / Dx) * Dx;
      if Xo + 1 >= S.Width then
        Continue;
      begin
        Z1 := ((Xs[Yo, Xo + 1].R - Xs[Yo, Xo].R) / Dx) * (J - X1r) + Xs[Yo, Xo].R;
        Z2 := ((Xs[Yo + 1, Xo + 1].R - Xs[Yo + 1, Xo].R) / Dx) * (J - X1r) + Xs[Yo + 1, Xo].R;
        K := (Z2 - Z1) / Dy;
        Xd[I + Y, J + X].R := Round(I * K + Z1 - Y1r * K);
        Z1 := ((Xs[Yo, Xo + 1].G - Xs[Yo, Xo].G) / Dx) * (J - X1r) + Xs[Yo, Xo].G;
        Z2 := ((Xs[Yo + 1, Xo + 1].G - Xs[Yo + 1, Xo].G) / Dx) * (J - X1r) + Xs[Yo + 1, Xo].G;
        K := (Z2 - Z1) / Dy;
        Xd[I + Y, J + X].G := Round(I * K + Z1 - Y1r * K);
        Z1 := ((Xs[Yo, Xo + 1].B - Xs[Yo, Xo].B) / Dx) * (J - X1r) + Xs[Yo, Xo].B;
        Z2 := ((Xs[Yo + 1, Xo + 1].B - Xs[Yo + 1, Xo].B) / Dx) * (J - X1r) + Xs[Yo + 1, Xo].B;
        K := (Z2 - Z1) / Dy;
        Xd[I + Y, J + X].B := Round(I * K + Z1 - Y1r * K);
      end;
    end;
    if I mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * I / H), Terminating);
     if Terminating then
       Break;
  end;
end;

procedure ThumbnailResize(Width, Height: integer; S,D: TBitmap; CallBack: TProgressCallBackProc = nil);
type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
var
  X, Y, Ix, Iy: Integer;
  X1, X2, X3: Integer;

  Xscale, Yscale: Single;
  IRed, IGrn, IBlu, IRatio: Longword;
  P, C1, C2, C3, C4, C5: TRGB24;
  Pt, Pt1: PRGB24;
  ISrc, IDst, S1: Integer;
  I, J, R, G, B, TmpY: Integer;

  RowDest, RowSource, RowSourceStart: Integer;
  W, H: Integer;
  Dxmin, Dymin: Integer;
  Ny1, Ny2, Ny3: Integer;
  Dx, Dy: Integer;
  LutX, LutY: array of Integer;
  Src, Dest: TBitmap;
  Terminating: Boolean;
begin
  W := Width;
  H := Height;
  Pointer(Src) := Pointer(S);
  Pointer(Dest) := Pointer(D);
  Terminating := False;
  if Src.PixelFormat <> Pf24bit then
    Src.PixelFormat := Pf24bit;
  if Dest.PixelFormat <> Pf24bit then
    Dest.PixelFormat := Pf24bit;
  Dest.Width := Width;
  Dest.Height := Height;

  if (Src.Width <= Dest.Width) and (Src.Height <= Dest.Height) then
  begin
    AssignBitmap(Dest, Src);
    Exit;
  end;

  IDst := (W * 24 + 31) and not 31;
  IDst := IDst div 8; // BytesPerScanline
  ISrc := (Src.Width * 24 + 31) and not 31;
  ISrc := ISrc div 8;

  Xscale := 1 / (W / Src.Width);
  Yscale := 1 / (H / Src.Height);

  // X lookup table
  SetLength(LutX, W);
  X1 := 0;
  X2 := Trunc(Xscale);
  for X := 0 to W - 1 do
  begin
    LutX[X] := X2 - X1;
    X1 := X2;
    X2 := Trunc((X + 2) * Xscale);
  end;

  // Y lookup table
  SetLength(LutY, H);
  X1 := 0;
  X2 := Trunc(Yscale);
  for X := 0 to H - 1 do
  begin
    LutY[X] := X2 - X1;
    X1 := X2;
    X2 := Trunc((X + 2) * Yscale);
  end;

  Dec(W);
  Dec(H);
  RowDest := Integer(Dest.Scanline[0]);
  RowSourceStart := Integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  for Y := 0 to H do
  begin
    Dy := LutY[Y];
    X1 := 0;
    X3 := 0;
    for X := 0 to W do
    begin
      Dx := LutX[X];
      IRed := 0;
      IGrn := 0;
      IBlu := 0;
      RowSource := RowSourceStart;
      for Iy := 1 to Dy do
      begin
        Pt := PRGB24(RowSource + X1);
        for Ix := 1 to Dx do
        begin
          IRed := IRed + Pt.R;
          IGrn := IGrn + Pt.G;
          IBlu := IBlu + Pt.B;
          Inc(Pt);
        end;
        RowSource := RowSource - ISrc;
      end;
      IRatio := 65535 div (Dx * Dy);
      Pt1 := PRGB24(RowDest + X3);
      Pt1.R := (IRed * IRatio) shr 16;
      Pt1.G := (IGrn * IRatio) shr 16;
      Pt1.B := (IBlu * IRatio) shr 16;
      X1 := X1 + 3 * Dx;
      Inc(X3, 3);
    end;
    RowDest := RowDest - IDst;
    RowSourceStart := RowSource;
  end;

  if Dest.Height < 3 then
    Exit;

  // Sharpening...
  S1 := Integer(Dest.ScanLine[0]);
  IDst := 0;
  if Dest.Height > 1 then
    IDst := Integer(Dest.ScanLine[1]) - S1;
  Ny1 := Integer(S1);
  Ny2 := Ny1 + IDst;
  Ny3 := Ny2 + IDst;
  for Y := 1 to Dest.Height - 2 do
  begin
    for X := 0 to Dest.Width - 3 do
    begin
      X1 := X * 3;
      X2 := X1 + 3;
      X3 := X1 + 6;

      C1 := PRGB24(Ny1 + X1)^;
      C2 := PRGB24(Ny1 + X3)^;
      C3 := PRGB24(Ny2 + X2)^;
      C4 := PRGB24(Ny3 + X1)^;
      C5 := PRGB24(Ny3 + X3)^;

      R := (C1.R + C2.R + (C3.R * -12) + C4.R + C5.R) div -8;
      G := (C1.G + C2.G + (C3.G * -12) + C4.G + C5.G) div -8;
      B := (C1.B + C2.B + (C3.B * -12) + C4.B + C5.B) div -8;

      if R < 0 then
        R := 0
      else if R > 255 then
        R := 255;
      if G < 0 then
        G := 0
      else if G > 255 then
        G := 255;
      if B < 0 then
        B := 0
      else if B > 255 then
        B := 255;

      Pt1 := PRGB24(Ny2 + X2);
      Pt1.R := R;
      Pt1.G := G;
      Pt1.B := B;
    end;

    Inc(Ny1, IDst);
    Inc(Ny2, IDst);
    Inc(Ny3, IDst);

    if Y mod 50 = 0 then
      if Assigned(CallBack) then
        CallBack(Round(100 * Y / D.Height), Terminating);
    if Terminating then
      Break;

  end;
end;

procedure KeepProportions(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer);
var
  B: TBitmap;
  W, H: Integer;
begin
  W := Bitmap.Width;
  H := Bitmap.Height;
  if (W > MaxWidth) or (H > MaxHeight) then
  begin
    B := TBitmap.Create;
    try
      ProportionalSize(MaxWidth, MaxHeight, W, H);
      DoResize(W, H, Bitmap, B);
      Exchange(Bitmap, B);
    finally
      F(B);
    end;
  end;
end;

procedure CenterBitmap24To32ImageList(var Bitmap: TBitmap; ImageSize: Integer);
var
  B: TBitmap;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf32Bit;
    B.SetSize(ImageSize, ImageSize);
    FillTransparentColor(B, clWhite);
    if (Bitmap.Width > ImageSize) or (Bitmap.Height > ImageSize) then
      KeepProportions(Bitmap, ImageSize, ImageSize);
    DrawImageEx24To32(B, Bitmap, B.Width div 2 - Bitmap.Width div 2, B.Height div 2 - Bitmap.Height div 2);
    Exchange(B, Bitmap);
  finally
    F(B);
  end;
end;

{ TBitmapHelper }

function TBitmapHelper.ClientRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
end;

end.
