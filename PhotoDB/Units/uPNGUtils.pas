unit uPNGUtils;

interface

uses
  Windows, GraphicsBaseTypes, Graphics, pngimage;

  procedure LoadPNGImageTransparent(PNG : TPNGImage; Bitmap : TBitmap);
  procedure LoadPNGImageWOTransparent(PNG : TPNGImage; Bitmap : TBitmap);
  procedure LoadPNGImage32bit(PNG : TPNGImage; Bitmap : TBitmap; BackGroundColor : TColor);

  procedure LoadPNGImage8BitWOTransparent(PNG : TPNGImage; Bitmap : TBitmap);
  procedure LoadPNGImage8bitTransparent(PNG : TPNGImage; Bitmap : TBitmap);
  procedure LoadPNGImagePalette(PNG : TPNGImage; Bitmap : TBitmap);

implementation

procedure LoadPNGImageTransparent(PNG : TPNGImage; Bitmap : TBitmap);
var
  I, J : Integer;
  DeltaS, DeltaSA, DeltaD : Integer;
  AddrLineS, AddrLineSA, AddrLineD : Integer;
  AddrS, AddrSA, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf32bit then
    Bitmap.PixelFormat := pf32bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineSA := Integer(PNG.AlphaScanline[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := Integer(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrSA := AddrLineSA;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PRGB(AddrD)^ := PRGB(AddrS)^;
      Inc(AddrS, 3);
      Inc(AddrD, 3);
      PByte(AddrD)^ := PByte(AddrSA)^;
      Inc(AddrD, 1);
      Inc(AddrSA, 1);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineSA, DeltaSA);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImagePalette(PNG : TPNGImage; Bitmap : TBitmap);
var
  I, J, P : Integer;
  DeltaS, DeltaD : Integer;
  AddrLineS, AddrLineD : Integer;
  AddrS, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      P := PByte(AddrS)^;
      with TChunkPLTE(PNG.Chunks.ItemFromClass(TChunkPLTE)).Item[P] do
      begin
        PRGB(AddrD)^.R := PNG.GammaTable[rgbRed];
        PRGB(AddrD)^.G := PNG.GammaTable[rgbGreen];
        PRGB(AddrD)^.B := PNG.GammaTable[rgbBlue];
      end;

      Inc(AddrS, 1);
      Inc(AddrD, 3);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImage8bitTransparent(PNG : TPNGImage; Bitmap : TBitmap);
var
  I, J : Integer;
  DeltaS, DeltaSA, DeltaD : Integer;
  AddrLineS, AddrLineSA, AddrLineD : Integer;
  AddrS, AddrSA, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf32bit then
    Bitmap.PixelFormat := pf32bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineSA := Integer(PNG.AlphaScanline[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := Integer(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrSA := AddrLineSA;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PRGB(AddrD)^.R := PByte(AddrS)^;
      PRGB(AddrD)^.G := PByte(AddrS)^;
      PRGB(AddrD)^.B := PByte(AddrS)^;
      Inc(AddrS, 1);
      Inc(AddrD, 3);
      PByte(AddrD)^ := PByte(AddrSA)^;
      Inc(AddrD, 1);
      Inc(AddrSA, 1);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineSA, DeltaSA);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImage8BitWOTransparent(PNG : TPNGImage; Bitmap : TBitmap);
var
  I, J : Integer;
  DeltaS, DeltaD : Integer;
  AddrLineS, AddrLineD : Integer;
  AddrS, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PRGB(AddrD)^.R := PByte(AddrS)^;
      PRGB(AddrD)^.G := PByte(AddrS)^;
      PRGB(AddrD)^.B := PByte(AddrS)^;
      Inc(AddrS, 1);
      Inc(AddrD, 3);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImageWOTransparent(PNG : TPNGImage; Bitmap : TBitmap);
var
  I, J : Integer;
  DeltaS, DeltaD : Integer;
  AddrLineS, AddrLineD : Integer;
  AddrS, AddrD : Integer;
begin
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PRGB(AddrD)^ := PRGB(AddrS)^;
      Inc(AddrS, 3);
      Inc(AddrD, 3);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImage32bit(PNG : TPNGImage; Bitmap : TBitmap; BackGroundColor : TColor);
var
  I, J : Integer;
  DeltaS, DeltaSA, DeltaD : Integer;
  AddrLineS, AddrLineD, AddrLineSA : Integer;
  AddrS, AddrD, AddrSA : Integer;
  R, G, B : Integer;
  W1, W2 : Integer;
  S, D : PRGB;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := Integer(PNG.ScanLine[0]);
  AddrLineSA := Integer(PNG.AlphaScanline[0]);
  AddrLineD := Integer(Bitmap.ScanLine[0]);

  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := Integer(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := Integer(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := Integer(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrSA := AddrLineSA;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      S := PRGB(AddrS);
      D := PRGB(AddrD);
      W1 := PByte(AddrSA)^;
      W2 := 255 - W1;
      D.R := (R * W2 + S.R * W1 + $7F) div $FF;
      D.G := (G * W2 + S.G * W1 + $7F) div $FF;
      D.B := (B * W2 + S.B * W1 + $7F) div $FF;

      Inc(AddrS, 3);
      Inc(AddrSA, 1);
      Inc(AddrD, 3);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineSA, DeltaSA);
    Inc(AddrLineD, DeltaD);
  end;
end;

end.
