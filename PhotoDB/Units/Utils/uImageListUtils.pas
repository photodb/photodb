unit uImageListUtils;

interface

uses
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ImgList;

type
  // Descendant of regular TImageList
  TSIImageList = class(TImageList)
  protected
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
      Style: Cardinal; Enabled: Boolean = True); override;
  end;

procedure CreateSpecialImageList(ASource, ADest: TCustomImageList;
  ABrightness, AContrast, AGrayscale, AAlpha: Single);

implementation

procedure CreateSpecialImageList(ASource, ADest: TCustomImageList;
  ABrightness, AContrast, AGrayscale, AAlpha: Single);
type
  PBGRA = ^TBGRA;
  TBGRA = packed record
    B, G, R, A: Byte;
  end;
  TByteLUT = array [Byte] of Byte;

  function ByteRound(const Value: Single): Byte; inline;
  begin
    if Value < 0 then
      Result := 0
    else if Value > 255 then
      Result := 255
    else
      Result := Round(Value);
  end;

  procedure GetLinearLUT(var LUT: TByteLUT; X1, Y1, X2, Y2: Integer);
  var
    X, DX, DY: Integer;
  begin
    DX := X2 - X1;
    DY := Y2 - Y1;
    for X := 0 to 255 do
      LUT[X] := ByteRound((X - X1) * DY / DX + Y1);
  end;

  function GetBrightnessContrastLUT(var LUT: TByteLUT; const Brightness, Contrast: Single): Boolean;
  var
    B, C: Integer;
    X1, Y1, X2, Y2: Integer;
  begin
    X1 := 0;
    Y1 := 0;
    X2 := 255;
    Y2 := 255;
    B := Round(Brightness * 255);
    C := Round(Contrast * 127);
    if C >= 0 then
    begin
      Inc(X1, C);
      Dec(X2, C);
      Dec(X1, B);
      Dec(X2, B);
    end
    else
    begin
      Dec(Y1, C);
      Inc(Y2, C);
      Inc(Y1, B);
      Inc(Y2, B);
    end;
    GetLinearLUT(LUT, X1, Y1, X2, Y2);
    Result := (B <> 0) or (C <> 0);
  end;

var
  LImageInfo: TImageInfo;
  LDibInfo: TDibSection;
  I, L: Integer;
  P: PBGRA;
  R, G, B, A: Byte;
  LUT: TByteLUT;
  LHasLUT: Boolean;
begin
  if (ASource = nil) or (ASource.ColorDepth <> cd32bit) then
    Exit;

  ADest.ColorDepth := cd32bit;
  ADest.Assign(ASource);
  ADest.Masked := False;
  FillChar(LImageInfo, SizeOf(LImageInfo), 0);
  ImageList_GetImageInfo(ADest.Handle, 0, LImageInfo);
  FillChar(LDibInfo, SizeOf(LDibInfo), 0);
  GetObject(LImageInfo.hbmImage, SizeOf(LDibInfo), @LDibInfo);
  P := LDibInfo.dsBm.bmBits;
  LHasLUT := GetBrightnessContrastLUT(LUT, ABrightness, AContrast);
  for I := 0 to LDibInfo.dsBm.bmHeight * LDibInfo.dsBm.bmWidth - 1 do
  begin
    A := P.A;
    R := MulDiv(P.R, $FF, A);
    G := MulDiv(P.G, $FF, A);
    B := MulDiv(P.B, $FF, A);
    if LHasLUT then
    begin
      R := LUT[R];
      G := LUT[G];
      B := LUT[B];
    end;
    if AGrayscale > 0 then
    begin
      L := (R * 61 + G * 174 + B * 21) shr 8;
      if AGrayscale >= 1 then
      begin
        R := L;
        G := L;
        B := L;
      end
      else
      begin
        R := ByteRound(R + (L - R) * AGrayscale);
        G := ByteRound(G + (L - G) * AGrayscale);
        B := ByteRound(B + (L - B) * AGrayscale);
      end;
    end;
    if AAlpha <> 1 then
    begin
      A := ByteRound(A * AAlpha);
      P.A := A;
    end;
    P.R := MulDiv(R, A, $FF);
    P.G := MulDiv(G, A, $FF);
    P.B := MulDiv(B, A, $FF);
    Inc(P);
  end;
end;

procedure TSIImageList.DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
  Style: Cardinal; Enabled: Boolean);
var
  Options: TImageListDrawParams;

  function GetRGBColor(Value: TColor): Cardinal;
  begin
    Result := ColorToRGB(Value);
    case Result of
      clNone: Result := CLR_NONE;
      clDefault: Result := CLR_DEFAULT;
    end;
  end;

begin
  if Enabled or (ColorDepth <> cd32Bit) then
    inherited
  else if HandleAllocated then
  begin
    FillChar(Options, SizeOf(Options), 0);
    Options.cbSize := SizeOf(Options);
    Options.himl := Self.Handle;
    Options.i := Index;
    Options.hdcDst := Canvas.Handle;
    Options.x := X;
    Options.y := Y;
    Options.cx := 0;
    Options.cy := 0;
    Options.xBitmap := 0;
    Options.yBitmap := 0;
    Options.rgbBk := GetRGBColor(BkColor);
    Options.rgbFg := GetRGBColor(BlendColor);
    Options.fStyle := Style;
    Options.fState := ILS_SATURATE; // Grayscale for 32bit images

    ImageList_DrawIndirect(@Options);
  end;
end;

end.
