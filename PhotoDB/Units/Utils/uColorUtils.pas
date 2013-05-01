unit uColorUtils;

interface

uses
  Generics.Collections,
  System.Math,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Graphics,

  Dmitry.Graphics.Types,

  uMemory,
  uStringUtils;

type
  THLS = record
    H: Byte;
    L: Byte;
    S: byte;
  end;

  TColorRange = record
    HMin, HMax: Byte;
    LMin, LMax: Byte;
    SMin, SMax: Byte;
  end;

const
  ColorCount = 15;
  cBlackWhiteIndex = 13;
  cColoredIndex = 14;

  clBlackWhite = $01000000;
  clColored    = $02000000;

type
  TPaletteArray = array[0..ColorCount - 1] of TColor;
  TPaletteHLSArray = array[0..ColorCount - 1] of TColorRange;

const
  PaletteColorNames: array[0..ColorCount - 1] of string = ('Red', 'Red', 'Orange', 'Yellow', 'Green', 'Teal', 'Blue', 'Purple', 'Pink', 'White', 'Gray', 'Black', 'Brown', 'Black and white', 'Colored');

procedure FindPaletteColorsOnImage(B: TBitmap; Colors: TList<TColor>; MaxColors: Integer);
function ColorPaletteToString(Color: TColor): string;
function ColorsToString(Colors: TArray<TColor>): string;
procedure FillColors(var Palette: TPaletteArray; var PaletteHLS: TPaletteHLSArray);

implementation

{$R-}

procedure _RGBtoHSL(RGB: TRGB; var HSL: THLS); inline;
var
  HueValue, D, Cmax, Cmin: Integer;
begin
  Cmax := Max(RGB.R, Max(RGB.G, RGB.B));
  Cmin := Min(RGB.R, Min(RGB.G, RGB.B));

  HSL.L := (Cmax + Cmin) div 2;

  HueValue := 0;
  HSL.S := 0;
  if Cmax <> Cmin then
  begin
    D := (Cmax - Cmin);

    if HSL.L < 127 then
      HSL.S := (D * 240) div (Cmax + Cmin)
    else
      HSL.S := (D * 240) div (512 - Cmax - Cmin);

    if RGB.R = Cmax then
      HueValue := ((RGB.G - RGB.B) * 255) div D
    else
    if RGB.G = Cmax then
      HueValue := 512 + ((RGB.B - RGB.R) * 255) div D
    else
      HueValue := 1024 + ((RGB.R - RGB.G) * 255) div D;

    HueValue := HueValue div 6;

    if HueValue < 0 then
      HueValue := HueValue + 255;
  end;

  HSL.L := (HSL.L * 240) div 255;
  HSL.H := (HueValue * 239) div 255;
end;

  {
procedure _RGBtoHSL(RGB: TRGB; var HSL: THLS); inline;
var
  R, G, B, LightValue, SaturationValue, HueValue, D, Cmax, Cmin: double;
begin
  R := RGB.R / 255;
  G := RGB.G / 255;
  B := RGB.B / 255;
  Cmax := Max(R, Max(G, B));
  Cmin := Min(R, Min(G, B));

  LightValue := (Cmax + Cmin) / 2;

  HueValue := 0;
  SaturationValue := 0;
  if Cmax <> Cmin then
  begin
    D := Cmax - Cmin;

    if LightValue < 0.5 then
      SaturationValue := D / (Cmax + Cmin)
    else
      SaturationValue := D / (2 - Cmax - Cmin);

    if R = Cmax then
      HueValue := (G - B) / D
    else
    if G = Cmax then
      HueValue := 2 + (B - R) / D
    else
      HueValue := 4 + (R - G) / D;

    HueValue := HueValue / 6;
    if HueValue < 0 then
      HueValue := HueValue + 1;
  end;

  HSL.H := Round(239 * HueValue);
  HSL.S := Round(240 * SaturationValue);
  HSL.L := Round(240 * LightValue);
end;}
{$R+}

procedure FillColors(var Palette: TPaletteArray; var PaletteHLS: TPaletteHLSArray);
const
  clOrange = $0066FF;
  clPink   = $BF98FF;
  clBrown  = $185488;
begin
  Palette[0] := clRed;
  PaletteHLS[0].HMin := 0;
  PaletteHLS[0].HMax := 10;
  PaletteHLS[0].LMin := 50;
  PaletteHLS[0].LMax := 195;
  PaletteHLS[0].SMin := 50;
  PaletteHLS[0].SMax := 255;
  Palette[1] := clRed;
  PaletteHLS[1].HMin := 228;
  PaletteHLS[1].HMax := 240;
  PaletteHLS[1].LMin := 50;
  PaletteHLS[1].LMax := 195;
  PaletteHLS[1].SMin := 50;
  PaletteHLS[1].SMax := 255;

  Palette[2] := clOrange;
  PaletteHLS[2].HMin := 11;
  PaletteHLS[2].HMax := 24;
  PaletteHLS[2].LMin := 110;
  PaletteHLS[2].LMax := 210;
  PaletteHLS[2].SMin := 151;
  PaletteHLS[2].SMax := 255;

  Palette[3] := clYellow;
  PaletteHLS[3].HMin := 25;
  PaletteHLS[3].HMax := 39;
  PaletteHLS[3].LMin := 110;
  PaletteHLS[3].LMax := 200;
  PaletteHLS[3].SMin := 60;
  PaletteHLS[3].SMax := 255;

  Palette[4] := clGreen;
  PaletteHLS[4].HMin := 40;
  PaletteHLS[4].HMax := 95;
  PaletteHLS[4].LMin := 50;
  PaletteHLS[4].LMax := 220;
  PaletteHLS[4].SMin := 40;
  PaletteHLS[4].SMax := 255;

  Palette[5] := clTeal;
  PaletteHLS[5].HMin := 96;
  PaletteHLS[5].HMax := 106;
  PaletteHLS[5].LMin := 40;
  PaletteHLS[5].LMax := 210;
  PaletteHLS[5].SMin := 100;
  PaletteHLS[5].SMax := 255;

  Palette[6] := clBlue;
  PaletteHLS[6].HMin := 107;
  PaletteHLS[6].HMax := 170;
  PaletteHLS[6].LMin := 30;
  PaletteHLS[6].LMax := 210;
  PaletteHLS[6].SMin := 90;
  PaletteHLS[6].SMax := 255;

  Palette[7] := clPurple;
  PaletteHLS[7].HMin := 171;
  PaletteHLS[7].HMax := 189;
  PaletteHLS[7].LMin := 40;
  PaletteHLS[7].LMax := 190;
  PaletteHLS[7].SMin := 50;
  PaletteHLS[7].SMax := 255;

  Palette[8] := clPink;
  PaletteHLS[8].HMin := 190;
  PaletteHLS[8].HMax := 230;
  PaletteHLS[8].LMin := 50;
  PaletteHLS[8].LMax := 220;
  PaletteHLS[8].SMin := 50;
  PaletteHLS[8].SMax := 255;

  Palette[9] := clWhite;
  PaletteHLS[9].HMin := 0;
  PaletteHLS[9].HMax := 255;
  PaletteHLS[9].LMin := 230;
  PaletteHLS[9].LMax := 255;
  PaletteHLS[9].SMin := 0;
  PaletteHLS[9].SMax := 255;

  Palette[10] := clGray;
  PaletteHLS[10].HMin := 0;
  PaletteHLS[10].HMax := 255;
  PaletteHLS[10].LMin := 150;
  PaletteHLS[10].LMax := 200;
  PaletteHLS[10].SMin := 0;
  PaletteHLS[10].SMax := 40;

  Palette[11] := clBlack;
  PaletteHLS[11].HMin := 0;
  PaletteHLS[11].HMax := 255;
  PaletteHLS[11].LMin := 0;
  PaletteHLS[11].LMax := 30;
  PaletteHLS[11].SMin := 0;
  PaletteHLS[11].SMax := 150;

  Palette[12] := clBrown;
  PaletteHLS[12].HMin := 15;
  PaletteHLS[12].HMax := 30;
  PaletteHLS[12].LMin := 30;
  PaletteHLS[12].LMax := 100;
  PaletteHLS[12].SMin := 30;
  PaletteHLS[12].SMax := 150;

  Palette[13] := clBlackWhite;
  PaletteHLS[13].HMin := 0;
  PaletteHLS[13].HMax := 255;
  PaletteHLS[13].LMin := 0;
  PaletteHLS[13].LMax := 255;
  PaletteHLS[13].SMin := 0;
  PaletteHLS[13].SMax := 40;

  Palette[14] := clColored;
  PaletteHLS[14].HMin := 0;
  PaletteHLS[14].HMax := 255;
  PaletteHLS[14].LMin := 0;
  PaletteHLS[14].LMax := 255;
  PaletteHLS[14].SMin := 41;
  PaletteHLS[14].SMax := 255;
end;

procedure FindPaletteColorsOnImage(B: TBitmap; Colors: TList<TColor>; MaxColors: Integer);
var
  P: PARGB;
  I, J, K: Integer;
  MinWeight: Integer;

  CR: TColorRange;
  Palette: TPaletteArray;
  PaletteHLS: TPaletteHLSArray;
  Weights: array[0..ColorCount - 1] of Double;

  MaxWeight, MaxWeightLimit: Double;
  HLS: THLS;
  MaxIndex: Integer;
begin
  if B.Empty then
    Exit;

  FillChar(Weights, SizeOf(Weights), 0);
  MinWeight := B.Width * B.Height div 50;

  FillColors(Palette, PaletteHLS);

  for I := 0 to B.Height - 1 do
  begin
    P := B.ScanLine[I];
    for J := 0 to B.Width - 1 do
    begin
      _RGBtoHSL(P[J], HLS);

      for K := 0 to ColorCount - 1 do
      begin
        CR := PaletteHLS[K];
        if (CR.HMin <= HLS.H) and (HLS.H <= CR.HMax) then
          if (CR.LMin <= HLS.L) and (HLS.L <= CR.LMax) then
            if (CR.SMin <= HLS.S) and (HLS.S <= CR.SMax) then
              Weights[K] := Weights[K] + 1;
      end;
    end;
  end;

  Weights[1] := Weights[1] + Weights[0];
  Weights[0] := 0;

  MaxWeight := 0.0;
  MaxIndex := -1;
  for K := 0 to ColorCount - 3 do
  begin
    if (MaxWeight < Weights[K]) and (Weights[K] > MinWeight) then
    begin
      MaxWeight := Weights[K];
      MaxIndex := K;
    end;
  end;
  if (MaxIndex > -1) then
  begin
    Colors.Add(Palette[MaxIndex]);

    MaxWeightLimit := MaxWeight / 100;

    for I := 0 to MaxColors - 2 do
    begin
      Weights[MaxIndex] := 0.0;
      MaxWeight := 0.0;
      MaxIndex := 0;
      for K := 0 to ColorCount - 3 do
      begin
        if (MaxWeight < Weights[K]) and (Weights[K] > MinWeight) then
        begin
          MaxWeight := Weights[K];
          MaxIndex := K;
        end;
      end;
      if MaxWeight > MaxWeightLimit then
        Colors.Add(Palette[MaxIndex]);
    end;
  end;

  if (Weights[cColoredIndex] = 0) and (Weights[cBlackWhiteIndex] > MinWeight) then
    Colors.Add(clBlackWhite)
  else
    if Weights[cBlackWhiteIndex] / Weights[cColoredIndex] > 100 then
       Colors.Add(clBlackWhite);
end;

function ColorPaletteToString(Color: TColor): string;
begin
  if Color = clBlackWhite then
    Result := 'BW'
  else
    Result := IntToHex(Color, 6);
end;

function ColorsToString(Colors: TArray<TColor>): string;
var
  Color: TColor;
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    for Color in Colors do
      SL.Add(ColorPaletteToString(Color));

    Result := SL.Join('#');
  finally
    F(SL);
  end;
end;

end.
