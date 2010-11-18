unit uPNGUtils;

interface

uses
  Windows, GraphicsBaseTypes, Graphics, GraphicEx;

  procedure LoadPNGImageTransparent(PNG : TPNGGraphic; Bitmap : TBitmap);
  procedure LoadPNGImage32bit(PNG : TPNGGraphic; Bitmap : TBitmap; BackGroundColor : TColor);

implementation

procedure LoadPNGImageTransparent(PNG : TPNGGraphic; Bitmap : TBitmap);
var
  I, J : Integer;
  DeltaS, DeltaD : Integer;
  AddrLineS, AddrLineD : Integer;
  AddrS, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf32bit then
    Bitmap.PixelFormat := pf32bit;
  Bitmap.Width := PNG.Width;
  Bitmap.Height := PNG.Height;

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
  DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;

  try
  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PInteger(AddrD)^ := PInteger(AddrS)^;

      AddrS := AddrS + 4;
      AddrD := AddrD + 4;
    end;
    AddrLineS := AddrLineS + DeltaS;
    AddrLineD := AddrLineD + DeltaD;
  end;
  except
    PNG.PixelFormat := pf24bit;
  end;
end;

procedure LoadPNGImage32bit(PNG : TPNGGraphic; Bitmap : TBitmap; BackGroundColor : TColor);
var
  I, J : Integer;
  DeltaS, DeltaD : Integer;
  AddrLineS, AddrLineD : Integer;
  AddrS, AddrD : Integer;
  R, G, B : Integer;
  W1, W2 : Integer;
  S : PRGB32;
  D : PRGB;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;
  Bitmap.Width := PNG.Width;
  Bitmap.Height := PNG.Height;

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
  DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      S := PRGB32(AddrS);
      D := PRGB(AddrD);
      W1 := S.L;
      W2 := 255 - W1;
      D.R := (R * W2 + S.R * W1 + $7F) div $FF;
      D.G := (G * W2 + S.G * W1 + $7F) div $FF;
      D.B := (B * W2 + S.B * W1 + $7F) div $FF;

      AddrS := AddrS + 4;
      AddrD := AddrD + 3;
    end;
    AddrLineS := AddrLineS + DeltaS;
    AddrLineD := AddrLineD + DeltaD;
  end;
end;


end.
