unit Dmitry.Graphics.Utils;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Vcl.Graphics,
  Dmitry.Graphics.Types;

const
  CHalf64: Double = 0.5;
  MaxBrushRadius = 250;

type
  TBrushToDraw = record
    Mask: array [-MaxBrushRadius .. MaxBrushRadius, -MaxBrushRadius .. MaxBrushRadius] of Boolean;
    TransMask: array [-MaxBrushRadius .. MaxBrushRadius, -MaxBrushRadius .. MaxBrushRadius] of Byte;
  end;

procedure StretchCoolEx0(X, Y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
procedure StretchCoolEx90(X, Y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
procedure StretchCoolEx180(X, Y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
procedure StretchCoolEx270(X, Y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
procedure FlipHorizontal(S, D: TBitmap);
procedure FlipVertical(S, D: TBitmap);
procedure XFillRect(X, Y, Width, Height: Integer; D: TBitmap; Color: TColor);
procedure StretchCoolW(X, Y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap);
procedure StretchCoolW32(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap; Mode: Integer = 0);
procedure StretchCoolW24To32(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap; Transparencity: Byte = 255);
procedure StretchCoolWTransparent(X, Y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap; T: Integer;
  UseFirstColor: Boolean = False);
procedure StretchFast(X, Y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap); overload;
procedure StretchFast(X, Y, Width, Height: Integer; Rect: TRect; var S, D: PARGBArray); overload;
procedure StretchFastA(X, Y, SWidth, SHeight, DWidth, DHeight: Integer; var S, D: PARGBArray);
procedure StretchFastATrans(X, Y, SWidth, SHeight, DWidth, DHeight: Integer; var S: PARGB32Array; var D: PARGBArray;
  Transparency: Extended; Effect: Integer = 0);
procedure StretchFastATransW(X, Y, Width, Height: Integer; Rect: TRect; var S: PARGB32Array; var D: PARGBArray;
  Transparency: Extended; Effect: Integer = 0);

procedure CreateBrush(var Brush: TBrushToDraw; Radius: Integer);
procedure DoBrush(Image: PARGB32Array; Brush: TBrushToDraw; W, H: Integer; X_begin, Y_begin, X_end, Y_end: Integer;
  R, G, B: Byte; Radius: Integer; Effect: Integer = 0);

procedure DrawCopyRightA(B: TBitmap; BkColor: TColor; Text: string);
procedure CoolDrawText(Bitmap: Tbitmap; X, Y: Integer; Text: string; Coolcount: Integer; Coolcolor: Tcolor);

procedure FillRectNoCanvas(B: TBitmap; Color: TColor);
function FastTrunc(const Value: Double): Integer; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
procedure HightliteBitmap(B: TBitmap);

implementation

procedure FillRectNoCanvas(B: TBitmap; Color: TColor);
var
  I, J: Integer;
  Xdp: array of PARGB;
  Rc, Gc, Bc: Byte;
begin
  Color := ColorToRGB(Color);
  rc := GetRValue(Color);
  gc := GetGValue(Color);
  bc := GetBValue(Color);
  SetLength(Xdp, B.height);
  for I := 0 to B.Height - 1 do
    Xdp[I] := B.ScanLine[I];
  for I := 0 to B.Height - 1 do
    for J := 0 to B.Width - 1 do
    begin
      Xdp[I, J].R := rc;
      Xdp[I, J].G := gc;
      Xdp[I, J].B := bc;
    end;
end;

procedure XFillRect(X, Y, Width, Height: Integer; D: TBitmap; Color: TColor);
var
  I, J: Integer;
  Xdp: array of PARGB;
  Rc, Gc, Bc: Byte;
begin
  Color := ColorToRGB(Color);
  Rc := GetRValue(Color);
  Gc := GetGValue(Color);
  Bc := GetBValue(Color);
  D.PixelFormat := pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  SetLength(Xdp, D.Height);
  for I := 0 to D.Height - 1 do
    Xdp[I] := D.ScanLine[I];
  for I := 0 to Y do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y + Height to D.Height - 1 do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := 0 to X do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := X + Width to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
end;

procedure StretchCoolEx0(X, Y, Width, Height : Integer; var S, D : TBitmap; Color : TColor);
var
  I, J, K, P, Sheight1, Dheight: Integer;
  Col, R, G, B, SWidth1: Integer;
  Sh, Sw: Extended;
  Xdp, Xsp: array of PARGB;
  Rc, Gc, Bc: Byte;
  YMin, YMax : Integer;
  XAW : array of Integer;
begin
  Color := ColorToRGB(Color);
  Rc := GetRValue(Color);
  Gc := GetGValue(Color);
  Bc := GetBValue(Color);
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  SWidth1 := S.Width - 1;
  Dheight := D.Height;
  Sheight1 := S.Height - 1;
  SetLength(Xsp, S.Height);
  for I := 0 to Sheight1 do
    Xsp[I] := S.ScanLine[I];
  SetLength(Xdp, D.Height);
  for I := 0 to D.Height - 1 do
    Xdp[I] := D.ScanLine[I];

  for I := 0 to Y do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Y + Height to D.Height - 1 do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := 0 to X do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := X + Width to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;

  for I := Y to Height + Y - 1 do
  begin
    YMin := Round(Sh * (I - Y));
    YMax := Min(S.Height - 1, Round(Sh * (I + 1 - Y)) - 1);
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to Min(XAW[J + 1] - 1, SWidth1) do
        begin
          Inc(Col);
          Inc(R, Xsp[K, P].R);
          Inc(G, Xsp[K, P].G);
          Inc(B, Xsp[K, P].B);
        end;
      end;
      if Col <> 0 then
      begin
        Xdp[I, J + X].R := R div Col;
        Xdp[I, J + X].G := G div Col;
        Xdp[I, J + X].B := B div Col;
      end;
    end;
  end;
end;

procedure StretchCoolEx180(x, y, Width, Height : Integer; var S, D : TBitmap; Color : TColor);
var
  I, J, K, P, Sheight1, Dheight: Integer;
  Col, R, G, B, SWidth1: Integer;
  Sh, Sw: Extended;
  Xdp, Xsp: array of PARGB;
  Rc, Gc, Bc: Byte;
  YMin, YMax, _2YHeight1 : Integer;
  XAW : array of Integer;
begin
  Color := ColorToRGB(Color);
  Rc := GetRValue(Color);
  Gc := GetGValue(Color);
  Bc := GetBValue(Color);
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Dheight := D.Height;
  Sheight1 := S.Height - 1;
  SWidth1 := S.Width - 1;
  SetLength(Xsp, S.Height);
  for I := 0 to Sheight1 do
    Xsp[I] := S.ScanLine[I];
  SetLength(Xdp, D.Height);
  for I := 0 to D.Height - 1 do
    Xdp[I] := D.ScanLine[I];
  for I := 0 to Y do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y + Height to D.Height - 1 do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := 0 to X do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y to Min(Y + Height, D.Height - 1) do
    for J := X + Width to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Y to Height + Y - 1 do
  begin
    YMin := Round(Sh*(i-y));
    YMax := Min(S.Height-1,Round(Sh*(i+1-y))-1);
    _2YHeight1 := 2 * Y + Height - I - 1;
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to Min(XAW[J + 1] - 1, SWidth1) do
        begin
          Inc(Col);
          Inc(R, Xsp[K, P].R);
          Inc(G, Xsp[K, P].G);
          Inc(B, Xsp[K, P].B);
        end;
      end;
      if Col <> 0 then
      begin
        Xdp[_2YHeight1, J + X].R := R div Col;
        Xdp[_2YHeight1, J + X].G := G div Col;
        Xdp[_2YHeight1, J + X].B := B div Col;
      end;
    end;
  end;
end;

procedure StretchCoolEx270(X, Y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
var
  I, J, K, P, Sheight1, Dheight: Integer;
  Col, R, G, B, SWidth1: Integer;
  Sh, Sw: Extended;
  Xdp, Xsp: array of PARGB;
  Rc, Gc, Bc: Byte;
  YMin, YMax: Integer;
  XAW: array of Integer;
begin
  Color := ColorToRGB(Color);
  Rc := GetRValue(Color);
  Gc := GetGValue(Color);
  Bc := GetBValue(Color);
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if Height + X > D.Width then
    D.Width := Height + X;
  if Width + Y > D.Height then
    D.Height := Width + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Dheight := D.Height;
  Sheight1 := S.Height - 1;
  SWidth1 := S.Width - 1;
  SetLength(Xsp, S.Height);
  for I := 0 to Sheight1 do
    Xsp[I] := S.ScanLine[I];
  SetLength(Xdp, D.Height);

  for I := 0 to D.Height - 1 do
    Xdp[I] := D.ScanLine[I];

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(SW * I);

  for I := 0 to Y do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y + Width to D.Height - 1 do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Max(0, Y) to Min(Y + Width, D.Height - 1) do
    for J := 0 to X do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Max(0, Y) to Min(Y + Width, D.Height - 1) do
    for J := X + Height to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;

  for I := Max(0, Y) to Height + Y - 1 do
  begin
    YMin := Round(Sh * (I - Y));
    YMax := Min(S.Height - 1, Round(Sh * (I + 1 - Y)) - 1);
    for J := 0 to Width - 1 - Max(0, -Y) do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to Min(XAW[J + 1] - 1, SWidth1) do
        begin
          Inc(Col);
          Inc(R, Xsp[K, P].R);
          Inc(G, Xsp[K, P].G);
          Inc(B, Xsp[K, P].B);
        end;
      end;
      if Col <> 0 then
      begin
        Xdp[Width - (-Y + J) - 1, X + I - Y].R := R div Col;
        Xdp[Width - (-Y + J) - 1, X + I - Y].G := G div Col;
        Xdp[Width - (-Y + J) - 1, X + I - Y].B := B div Col;
      end;
    end;
  end;
end;

procedure StretchCoolEx90(x, y, Width, Height: Integer; var S, D: TBitmap; Color: TColor);
var
  I, J, K, P, Sheight1, Dheight: Integer;
  Col, R, G, B, YC, SWidth1: Integer;
  Sh, Sw: Extended;
  Xdp, Xsp: array of PARGB;
  Rc, Gc, Bc: Byte;
  XAW: array of Integer;
  YMin, YMax: Integer;
begin
  Rc := GetRValue(Color);
  Gc := GetGValue(Color);
  Bc := GetBValue(Color);
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  if Height + X > D.Width then
    D.Width := Height + X;
  if Width + Y > D.Height then
    D.Height := Width + Y;
  Sh := S.Height / Height;
  Sw := S.Width / Width;
  Dheight := D.Height;
  Sheight1 := S.Height - 1;
  SWidth1 := S.Width - 1;
  SetLength(Xsp, S.Height);
  for I := 0 to Sheight1 do
    Xsp[I] := S.ScanLine[I];
  SetLength(Xdp, D.Height);
  for I := 0 to D.Height - 1 do
    Xdp[I] := D.ScanLine[I];
  for I := 0 to Y do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Y + Width to D.Height - 1 do
    for J := 0 to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Max(0, Y) to Min(Y + Width, D.Height - 1) do
    for J := 0 to X do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;
  for I := Max(0, Y) to Min(Y + Width, D.Height - 1) do
    for J := X + Height to D.Width - 1 do
    begin
      Xdp[I, J].R := Rc;
      Xdp[I, J].G := Gc;
      Xdp[I, J].B := Bc;
    end;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Max(0, Y) to Height + Y - 1 do
  begin
    YMin := Round(Sh * (I - Y));
    YMax := Min(S.Height - 1, Round(Sh * (I + 1 - Y)) - 1);
    YC := Height - I + X + Y - 1;
    for J := Max(-Y, 0) to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to Min(XAW[J + 1] - 1, SWidth1) do
        begin
          Inc(Col);
          Inc(R, Xsp[K, P].R);
          Inc(G, Xsp[K, P].G);
          Inc(B, Xsp[K, P].B);
        end;
      end;
      if Col <> 0 then
      begin
        Xdp[Y + J, YC].R := R div Col;
        Xdp[Y + J, YC].G := G div Col;
        Xdp[Y + J, YC].B := B div Col;
      end;
    end;
  end;
end;

procedure FlipHorizontal(S, D: TBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  SW: Integer;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  SW := S.Width;
  D.Width := S.Width;
  D.Height := S.Height;
  for I := 0 to S.Height - 1 do
  begin
    PS := S.ScanLine[I];
    PD := D.ScanLine[I];
    for J := 0 to SW - 1 do
      PD[J] := PS[SW - 1 - J];
  end;
end;

procedure FlipVertical(S,D : TBitmap);
var
  I, J: Integer;
  Ps, Pd: PARGB;
begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  D.Width := S.Width;
  D.Height := S.Height;
  for I := 0 to S.Height - 1 do
  begin
    Ps := S.ScanLine[I];
    Pd := D.ScanLine[S.Height - 1 - I];
    for J := 0 to S.Width - 1 do
      Pd[J] := Ps[J];
  end;
end;

procedure StretchCoolW24To32(X, Y, Width, Height : Integer; Rect : TRect; S, D : TBitmap; Transparencity: Byte = 255);
var
  I, J, K, P: Integer;
  P1: PARGB32;
  Col, R, G, B, SWidth1Left: Integer;
  Sh, Sw: Extended;
  XP: array of PARGB;
  YMin, YMax: Integer;
  XAW: array of Integer;
  XAWJ, XAWJ1: Integer;
  PS: PARGB;
  RGBS: PRGB;
begin
  S.PixelFormat := pf24Bit;
  D.PixelFormat := pf32Bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  if (Width = 0) or (Height = 0) then
    Exit;
  Sw := (Rect.Right - Rect.Left) / Width;
  Sh := (Rect.Bottom - Rect.Top) / Height;
  SWidth1Left := S.Width - 1 - Rect.Left;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    XP[I] := S.ScanLine[I];

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Y to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    YMin := Round(Sh * (I - Y)) + Rect.Top;
    YMax := Min(S.Height - 1 - Rect.Top, Round(Sh * (I + 1 - Y)) - 1) + Rect.Top;
    for J := 0 to Width - 1 do
    begin
      R := 0;
      G := 0;
      B := 0;
      XAWJ := XAW[J];
      XAWJ1 := Min(XAW[J + 1] - 1, SWidth1Left) + Rect.Left;
      Col := (YMax - YMin + 1) * (XAWJ1 - XAWJ + 1) + Rect.Left;
      for K := YMin to YMax do
      begin
        PS := XP[K];
        RGBS := @PS[XAWJ];
        for P := XAWJ to XAWJ1 do
        begin
          Inc(R, RGBS^.R);
          Inc(G, RGBS^.G);
          Inc(B, RGBS^.B);
          Inc(RGBS);
        end;
      end;
      if Col <> 0 then
      begin
        P1[J + X].R := R div Col;
        P1[J + X].G := G div Col;
        P1[J + X].B := B div Col;
        P1[J + X].L := Transparencity;
      end;
    end;
  end;
end;

procedure StretchCoolW32(X, Y, Width, Height: Integer; Rect: TRect; S, D: TBitmap; Mode: Integer = 0);
var
  I, J, K, P: Integer;
  P1: PARGB32;
  Col, R, G, B, L, SWidth1Left: Integer;
  Sh, Sw: Extended;
  XP: array of PARGB32;
  W, W1: Byte;
  YMin, YMax: Integer;
  XAW: array of Integer;
  XAWJ, XAWJ1: Integer;
  PS: PARGB32;
  RGBAS: PRGB32;
begin
  InitSumLMatrix;
  S.PixelFormat := pf32Bit;
  D.PixelFormat := pf32Bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  if (Width = 0) or (Height = 0) then
    Exit;
  Sw := (Rect.Right - Rect.Left) / Width;
  Sh := (Rect.Bottom - Rect.Top) / Height;

  SWidth1Left := S.Width - 1 - Rect.Left;
  SetLength(Xp, S.Height);

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  if MODE = 0 then
  begin
    for I := 0 to S.Height - 1 do
      XP[I] := S.ScanLine[I];
    for I := Y to Height + Y - 1 do
    begin
      P1 := D.ScanLine[I];
      YMin := Round(Sh * (I - Y));
      YMax := Min(S.Height - 1 - Rect.Top, Round(Sh * (I + 1 - Y)) - 1);
      for J := 0 to Width - 1 do
      begin
        R := 0;
        G := 0;
        B := 0;
        L := 0;
        XAWJ := XAW[J] + Rect.Left;
        XAWJ1 := Min(XAW[J + 1] - 1, SWidth1Left) + Rect.Left;
        Col := (YMax - YMin + 1) * (XAWJ1 - XAWJ + 1);
        for K := YMin to YMax do
        begin
          PS := XP[K];
          RGBAS := @PS[XAWJ];
          for P := XAWJ to XAWJ1 do
          begin
            Inc(R, RGBAS^.R);
            Inc(G, RGBAS^.G);
            Inc(B, RGBAS^.B);
            Inc(L, RGBAS^.L);

            Inc(RGBAS);
          end;
        end;
        if Col <> 0 then
        begin
          W := L div Col;
          W1 := 255 - W;
          P1[J + X].R := (P1[J + X].R * W1 + (R div Col) * W + $7F) div 255;
          P1[J + X].G := (P1[J + X].G * W1 + (G div Col) * W + $7F) div 255;
          P1[J + X].B := (P1[J + X].B * W1 + (B div Col) * W + $7F) div 255;
          P1[J + X].L := SumLMatrix[P1[J + X].L, W];
        end;
      end;
    end;
  end else
  begin
    for I := 0 to S.Height - 1 do
      XP[I] := S.ScanLine[I];
    for I := Y to Height + Y - 1 do
    begin
      P1 := D.ScanLine[I];
      YMin := Round(Sh * (I - Y)) + Rect.Top;
      YMax := Min(S.Height - 1 - Rect.Top, Round(Sh * (I + 1 - Y)) - 1) + Rect.Top;
      for J := 0 to Width - 1 do
      begin
        R := 0;
        G := 0;
        B := 0;
        L := 0;
        XAWJ := XAW[J] + Rect.Left;
        XAWJ1 := Min(XAW[J + 1] - 1, SWidth1Left) + Rect.Left;
        Col := (YMax - YMin + 1) * (XAWJ1 - XAWJ + 1);

        for K := YMin to YMax do
        begin
          PS := XP[K];
          RGBAS := @PS[XAWJ];
          for P := XAWJ to XAWJ1 do
          begin
            Inc(R, RGBAS^.R);
            Inc(G, RGBAS^.G);
            Inc(B, RGBAS^.B);
            Inc(L, RGBAS^.L);

            Inc(RGBAS);
          end;
        end;
        if Col <> 0 then
        begin
          P1[J + X].R := R div Col;
          P1[J + X].G := G div Col;
          P1[J + X].B := B div Col;
          P1[J + X].L := L div Col;
        end;
      end;
    end;
  end;
end;

procedure StretchCoolW(X, Y, Width, Height: Integer; Rect: TRect; var S, D: TBitmap);
var
  I, J, K, P: Integer;
  P1: Pargb;
  Col, R, G, B, SWidth1Left: Integer;
  Sh, SW: Extended;
  Xp: array of PARGB;
  YMin, YMax: Integer;
  XAW: array of Integer;
  XAWJ, XAWJ1: Integer;
  RGBS, RGBD: PRGB;
  PS: PARGB;
begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  if (Width = 0) or (Height = 0) then
    Exit;
  Sw := (Rect.Right - Rect.Left) / Width;
  Sh := (Rect.Bottom - Rect.Top) / Height;
  SWidth1Left := S.Width - 1 - Rect.Left;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Y to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    RGBD := @P1[X];

    YMin := Round(Sh * (I - Y)) + Rect.Top;
    YMax := Min(S.Height - 1 - Rect.Top, Round(Sh * (I + 1 - Y)) - 1) + Rect.Top;
    for J := 0 to Width - 1 do
    begin
      R := 0;
      G := 0;
      B := 0;
      XAWJ := XAW[J] + Rect.Left;
      XAWJ1 := Min(XAW[J + 1] - 1, SWidth1Left) + Rect.Left;
      Col := (YMax - YMin + 1) * (XAWJ1 - XAWJ + 1);

      for K := YMin to YMax do
      begin
        PS := XP[K];
        RGBS := @PS[XAWJ];

        for P := XAWJ to XAWJ1 do
        begin
          Inc(R, RGBS^.R);
          Inc(G, RGBS^.G);
          Inc(B, RGBS^.B);

          Inc(RGBS);
        end;
      end;

      if Col <> 0 then
      begin
        RGBD^.R := R div Col;
        RGBD^.G := G div Col;
        RGBD^.B := B div Col;
      end;

      Inc(RGBD);
    end;
  end;
end;

procedure StretchCoolWTransparent(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap; T : integer; UseFirstColor : Boolean = false);
var
  I, J, K, P, Sheight1: Integer;
  P1: Pargb;
  TC: TRGB;
  Col, R, G, B, SWidth1Left: Integer;
  Sh, Sw, L: Extended;
  Xp: array of PARGB;
  W1, W: Byte;
  YMin, YMax : Integer;
  XAW : array of Integer;

  function TrColor(TC: TRGB; R, G, B: Byte): Boolean; inline;
  begin
    Result := (R = TC.R) and (G = TC.G) and (B = TC.B);
  end;

begin
  S.PixelFormat := pf24bit;
  D.PixelFormat := pf24bit;
  W := T;
  W1 := 255 - T;

  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  if (Width = 0) or (Height = 0) then
    Exit;
  Sw := (Rect.Right - Rect.Left) / Width;
  Sh := (Rect.Bottom - Rect.Top) / Height;
  Sheight1 := (Rect.Bottom - Rect.Top) - 1;
  SWidth1Left := S.Width - 1 - Rect.Left;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I);

  for I := Y to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    YMin := Round(Sh * (I - Y));
    YMax := Min(S.Height - 1 - Rect.Top, Round(Sh * (I + 1 - Y)) - 1);
    if I = Y then
      TC := P1[0];
    for J := 0 to Width - 1 do
    begin
      Col := 0;
      R := 0;
      G := 0;
      B := 0;
      for K := YMin to YMax do
      begin
        for P := XAW[J] to Min(XAW[J + 1] - 1, SWidth1Left) do
        begin
          Inc(Col);
          Inc(R, Xp[K + Rect.Top, P + Rect.Left].R);
          Inc(G, Xp[K + Rect.Top, P + Rect.Left].G);
          Inc(B, Xp[K + Rect.Top, P + Rect.Left].B);
        end;
      end;
      if Col <> 0 then
      begin
        if not UseFirstColor or not TrColor(TC, R, G, B) then
        begin
          P1[J + X].R := (P1[J + X].R * W1 + (R div Col) * W) shr 8;
          P1[J + X].G := (P1[J + X].G * W1 + (G div Col) * W) shr 8;
          P1[J + X].B := (P1[J + X].B * W1 + (B div Col) * W) shr 8;
        end;
      end;
    end;
  end;
end;

procedure StretchFast(x, y, Width, Height : Integer; Rect : TRect; var S, D : TBitmap);
var
  I, J, CX, CY: Integer;
  P1: pargb;
  SH, Sw: Extended;
  Xp: array of PARGB;
  XAW : array of Integer;
begin
  S.PixelFormat := Pf24bit;
  D.PixelFormat := Pf24bit;
  if Width + X > D.Width then
    D.Width := Width + X;
  if Height + Y > D.Height then
    D.Height := Height + Y;
  SW := (Rect.Right - Rect.Left) / Width;
  SH := (Rect.Bottom - Rect.Top) / Height;
  SetLength(Xp, S.Height);
  for I := 0 to S.Height - 1 do
    Xp[I] := S.ScanLine[I];

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I) + Rect.Left;

  for I := Y to Height + Y - 1 do
  begin
    P1 := D.ScanLine[I];
    CY := Round(SH * (I - Y)) + Rect.Top;
    for J := 0 to Width - 1 do
    begin
      CX := XAW[J];
      P1[J + X] := Xp[CY, CX];
    end;
  end;
end;

procedure StretchFast(X, Y, Width, Height: Integer; Rect: TRect; var S, D: PARGBArray);
var
  I, J: Integer;
  Sh, Sw: Extended;
  Ay, Ax: Integer;
  Jx: Integer;
  XAW : array of Integer;
begin
  Sw := (Rect.Right - Rect.Left) / Width;
  Sh := (Rect.Bottom - Rect.Top) / Height;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(Sw * I) + Rect.Left;

  for I := Y to Height + Y - 1 do
  begin
    Ay := Round(Sh * (I - Y)) + Rect.Top;
    for J := 0 to Width - 1 do
    begin
      Ax := XAW[J];
      Jx := J + X;
      D[I, Jx] := S[Ay, Ax];
    end;
  end;
end;

procedure StretchFastA(X, Y, SWidth, SHeight, DWidth, DHeight: Integer; var S, D: PARGBArray);
var
  I, J, YC, XC: Integer;
  Sh, Sw: Extended;
  XAW : array of Integer;
begin
  Sw := SWidth / DWidth;
  Sh := SHeight / DHeight;

  SetLength(XAW, DWidth + 1);
  for I := 0 to DWidth do
    XAW[I] := Round(Sw * I);

  for I := Y to DHeight + Y - 1 do
  begin
    YC := Round(Sh * (I - Y));
    for J := 0 to DWidth - 1 do
    begin
      XC := XAW[J];
      D[I, J + X].R := S[YC, XC].R;
      D[I, J + X].G := S[YC, XC].G;
      D[I, J + X].B := S[YC, XC].B;
    end;
  end;
end;

procedure StretchFastATrans(X, Y, SWidth, SHeight, DWidth, DHeight: Integer; var S : PARGB32Array; var  D : PARGBArray; Transparency : extended; Effect : integer = 0);
var
  I, J: Integer;
  Sh, Sw : Extended;
  XT : array[0..255] of Byte;
  AX, AY, JX : Integer;
  LL, L, LL1, ld, R, G, B : Byte;
  W, W1 : Byte;
  WX : Integer;
  XAW : array of Integer;
begin

  W := Round(Transparency * 255);
  W1 := 255 - W;

  Sw := SWidth / DWidth;
  Sh := SHeight / DHeight;
  for I := 0 to 255 do
   XT[I] := Round((255 - (255 - I) * Transparency));

  SetLength(XAW, DWidth + 1);
  for I := 0 to DWidth do
    XAW[I] := Round(Sw * I);

  if Effect = 0 then
  begin
    for I := Y to DHeight + Y - 1 do
    begin
      AY := Round(Sh * (I - Y));
      for J := 0 to DWidth - 1 do
      begin
        AX := XAW[J];

        LL := XT[S[AY, AX].L];

        JX := J + X;
        LL1 := 255 - LL;
        D[I, JX].R := (S[AY, AX].R * LL1 + D[I, JX].R * LL) shr 8;
        D[I, JX].G := (S[AY, AX].G * LL1 + D[I, JX].G * LL) shr 8;
        D[I, JX].B := (S[AY, AX].B * LL1 + D[I, JX].B * LL) shr 8;
      end;
    end;
  end else
  begin
    for I := Y to DHeight + Y - 1 do
    begin
      AY := Round(Sh * (I - Y));
      for J := 0 to DWidth - 1 do
      begin
        AX := XAW[J];
        JX := J + X;
        LD := (D[I, JX].R * 77 + D[I, JX].G * 151 + D[I, JX].B * 28) shr 8;
        L := (S[AY, AX].R * 77 + S[AY, AX].G * 151 + S[AY, AX].B * 28) shr 8;

        if L >= 2 then
        begin
          LL := XT[S[AY, AX].L];
          if LL = 255 then
            Continue;
          LL1 := 255 - LL;

          WX := (W * LD);
          R := Min(255, ((S[AY, AX].R * WX) div L + D[I, JX].R * W1) shr 8);
          G := Min(255, ((S[AY, AX].G * WX) div L + D[I, JX].G * W1) shr 8);
          B := Min(255, ((S[AY, AX].B * WX) div L + D[I, JX].B * W1) shr 8);

          D[I, JX].R := (R * LL1 + D[I, JX].R * LL + $7F) shr 8;
          D[I, JX].G := (G * LL1 + D[I, JX].G * LL + $7F) shr 8;
          D[I, JX].B := (B * LL1 + D[I, JX].B * LL + $7F) shr 8;
        end;
      end;
    end;
  end;
end;

procedure StretchFastATransW(x, y, Width, Height : Integer; Rect : TRect; var S : PARGB32Array; var  D : PARGBArray; Transparency : extended; Effect : integer = 0);
var
  I, J: Integer;
  Sh, Sw: Extended;
  XT: array [0 .. 255] of Byte;
  Ay, Ax, Jx: Integer;
  L, LD, W, W1, LL, LL1, R, G, B: Byte;
  WX: Integer;
  XAW : array of Integer;
begin

  W := Round(Transparency * 255);
  W1 := 255 - W;

  if (Width = 0) or (Height = 0) then
    Exit;

  for I := 0 to 255 do
    XT[I]:= Round(255 - (255 - I) * Transparency);

  SW := (Rect.Right - Rect.Left) / Width;
  SH := (Rect.Bottom - Rect.Top) / Height;

  SetLength(XAW, Width + 1);
  for I := 0 to Width do
    XAW[I] := Round(SW * I);

  if Effect = 0 then
  begin
    for I := Y to Height + Y - 1 do
    begin
      AY := FastTrunc(SH * (I - Y)) + Rect.Top;
      for J := 0 to Width - 1 do
      begin
        AX := XAW[J] + Rect.Left;
        LL := XT[S[AY, AX].L];

        JX := J + X;
        LL1 := 255 - LL;
        D[I, JX].R := (S[AY, AX].R * LL1 + D[I, JX].R * LL) shr 8;
        D[I, JX].G := (S[AY, AX].G * LL1 + D[I, JX].G * LL) shr 8;
        D[I, JX].B := (S[AY, AX].B * LL1 + D[I, JX].B * LL) shr 8;
      end;
    end;
  end else
  begin
    for I := Y to Height + Y - 1 do
    begin
      AY := FastTrunc(SH * (I - Y)) + Rect.Top;
      for J := 0 to Width - 1 do
      begin
        AX := XAW[J] + Rect.Left;
        JX := J + X;
        LD := (D[I, JX].R * 77 + D[I, JX].G * 151 + D[I, JX].B * 28) shr 8;
        L := (S[AY, AX].R * 77 + S[AY, AX].G * 151 + S[AY, AX].B * 28) shr 8;

        if L >= 2 then
        begin
          LL := XT[S[AY, AX].L];
          if LL = 255 then
            Continue;
          LL1 := 255 - LL;

          WX := (W * LD);
          R := Min(255, ((S[AY, AX].R * WX) div L + D[I, JX].R * W1) shr 8);
          G := Min(255, ((S[AY, AX].G * WX) div L + D[I, JX].G * W1) shr 8);
          B := Min(255, ((S[AY, AX].B * WX) div L + D[I, JX].B * W1) shr 8);

          D[I, JX].R := (R * LL1 + D[I, JX].R * LL) div $FF;
          D[I, JX].G := (G * LL1 + D[I, JX].G * LL) div $FF;
          D[I, JX].B := (B * LL1 + D[I, JX].B * LL) div $FF;
        end;
      end;
    end;
  end;
end;

procedure CreateBrush(var Brush : TBrushToDraw; Radius : Integer);
var
  I, J: Integer;
  X1, X2, Rd2: Integer;
  X3: Extended;
begin
  Rd2 := Radius div 2;
  X2 := Max(1, Sqr(Rd2));
  X3 := X2 / Sqrt(255);

  for I := -Rd2 to Rd2 do
  begin
    for J := -Rd2 to Rd2 do
    begin
      X1 := Sqr(I) + Sqr(J);
      Brush.Mask[J, I] := False;
      if X1 <= X2 then
      begin
        Brush.Mask[J, I] := True;
        Brush.TransMask[J, I] := Round(Sqr(X1 / X3));
      end;
    end;
  end;
end;

procedure DoPoint(const Brush : TBrushToDraw; S : PARGB32Array; w,h : integer; x, y : integer; r,g,b: byte; Radius : Integer; Effect : integer = 0);
var
  I, J, L, Rd2: Integer;
begin
  Rd2 := Radius div 2;

  //every effect
  if Effect <> 2 then
  begin
    for I := Max(0, Y - Rd2) to Min(H - 1, Y + Radius - Rd2) do
    begin
      for J := Max(0, X - Rd2) to Min(W - 1, X + Radius - Rd2) do
      begin
        if Brush.Mask[J - X, I - Y] then
        begin
          S[I, J].R := R;
          S[I, J].G := G;
          S[I, J].B := B;
          L := Brush.TransMask[J - X, I - Y];
          if L < S[I, J].L then
            S[I, J].L := L;
        end;
      end;
    end;
  end else
  begin
    //TODO: implement fast drawing here
  end;
end;

procedure DoBrush(Image: PARGB32Array; Brush : TBrushToDraw; W, H: Integer; X_begin, Y_begin, X_end, Y_end: Integer; R, G, B: Byte;
  Radius: Integer; Effect: Integer = 0);
var

  Rd2, L : Integer;
  L1, L2 : Extended;

  procedure DrawBrush;
  var
    I, J: Integer;
    XB, XE, YB, YE : Integer;
    K, KK,
    P1, P2,
    AAI, AA, BB, CC, DD : Extended;
  begin
    XB := Min(X_begin, x_end);
    XE := Max(X_begin, x_end);
    YB := Min(Y_begin, Y_end);
    YE := Max(Y_begin, Y_end);

    AA := Y_begin - Y_end;
    BB := X_end - X_begin;
    DD := Hypot(AA, BB);
    CC := X_begin * Y_end - X_end * Y_begin;
    AAI := -AA;

    for I := Max(0, YB - Rd2) to Min(H - 1, YE + Rd2) do
    begin
      for J := Max(0, XB - Rd2) to Min(W - 1, XE + Rd2) do
      begin

        P1 := (I - y_begin) * AAI + (J - X_begin) * BB;
        P2 := (I - y_end) *  AAI + (J - X_end) * BB;

        if P1 * P2 < 0 then
        begin
          L := Abs(Round((AA * J + BB * I + CC) / DD));
        end else
        begin
          L1 := Sqrt((I - Y_begin) * (I - Y_begin) + (J - X_begin) * (J - X_begin));
          L2 := Sqrt((I - Y_end) * (I - Y_end) + (J - x_end) * (J - x_end));
          L := Round(Min(L1, L2));
        end;

        if L < Rd2  then
        begin
          Image[I, J].R := R;
          Image[I, J].G := G;
          Image[I, J].B := B;
          L := Brush.TransMask[0, L];
          if L < Image[I, J].L then
            Image[I, J].L := L;
        end;
      end;
    end;
  end;

begin
  InitSumLMatrix;
  if ((Y_end - Y_begin) = 0) and ((X_end - X_begin) = 0) then
  begin
    DoPoint(Brush, Image, W, H, X_begin, Y_begin, R, G, B, Radius, Effect);
    Exit;
  end;

  Rd2 := Radius div 2;
  DrawBrush;
end;

procedure CoolDrawText(bitmap:Tbitmap; x,y:integer; text:string; coolcount:integer; coolcolor:Tcolor);
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
 tempb.canvas.brush.Color:=$ffffff;
 tempb.Width:=tempb.Canvas.TextWidth(text)+2*coolcount;
 tempb.height:=tempb.Canvas.Textheight(text)+2*coolcount;
 tempb.Canvas.Brush.style:=bsClear;
 tempb.canvas.font.Color:=$0;
 DrawRect:=Rect(point(coolcount,0),point(tempb.Width+coolcount,tempb.Height+coolcount));
 DrawText(tempb.Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_NOCLIP);
 temp:=tbitmap.create;
 temp.PixelFormat:=pf24bit;
 temp.canvas.brush.Color:=$0;
 temp.Width:=tempb.Canvas.TextWidth(text)+coolcount;
 temp.height:=tempb.Canvas.Textheight(text)+coolcount;
 tempb.Canvas.Font.Assign(bitmap.Canvas.Font);
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
 for i:=Max(0,y) to min(tempb.Height-1+y,bitmap.height-1) do
 begin
 p:=bitmap.ScanLine[i];
 p1:=tempb.ScanLine[i-y];
 for j:=Max(0,x) to min(tempb.Width+x-1,bitmap.width-1) do
 begin
 p[j].r:=min(Round(p[j].r*(1-p1[j-x].r/255))+Round(getrvalue(coolcolor)*p1[j-x].r/255),255);
 p[j].g:=min(Round(p[j].g*(1-p1[j-x].g/255))+Round(getgvalue(coolcolor)*p1[j-x].g/255),255);
 p[j].b:=min(Round(p[j].b*(1-p1[j-x].b/255))+Round(getbvalue(coolcolor)*p1[j-x].b/255),255);
 end;
 end;
 DrawRect:=Rect(point(x+coolcount,y),point(x+temp.Width+coolcount,temp.Height+y+coolcount));
 bitmap.Canvas.Brush.style:=bsClear;
 DrawText(bitmap.Canvas.Handle, PChar(text), Length(text), DrawRect, DT_NOCLIP);
 temp.free;
 tempb.free;
end;

procedure DrawCopyRightA(B: TBitmap; BkColor: TColor; Text: string);
var
  CoolSize, FontSize, X, Y: Integer;
begin
  FontSize := Min(B.Width div (Length(Text)), 16);
  B.Canvas.Font.Size := FontSize;
  CoolSize := Min(5, Round(B.Canvas.Font.Size / 2.5));
  X := B.Width - B.Canvas.TextWidth(Text) - CoolSize * 3;
  Y := B.Height - B.Canvas.TextHeight(Text) - CoolSize * 2;
  CoolDrawText(B, X, Y, Text, CoolSize, BkColor);
end;

function FastTrunc(const Value: Double): Integer;
asm
 fld Value.Double
 fsub CHalf64
 fistp Result.Integer
end;

procedure HightliteBitmap(B: TBitmap);
var
  I, J: Integer;
  P: PARGB;

  function HightLite(B: Byte) : Byte; inline;
  begin
    Result := Round(255 * Sqrt(B / 255));
  end;

begin
  for I := 0 to B.Height - 1 do
  begin
    P := B.ScanLine[I];
    for J := 0 to B.Width - 1 do
    begin
      P[J].R := HightLite(P[J].R);
      P[J].G := HightLite(P[J].G);
      P[J].B := HightLite(P[J].B);
    end;
  end;
end;

end.





















