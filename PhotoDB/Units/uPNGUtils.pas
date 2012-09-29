unit uPNGUtils;

interface

uses
  Windows,
  GraphicsBaseTypes,
  Graphics,
  pngimage,
  Classes,
  uMemory,
  uBitmapUtils,
  uICCProfile,
  ZLib;

procedure LoadPNGImageTransparent(PNG: TPNGImage; Bitmap: TBitmap);
procedure LoadPNGImageWOTransparent(PNG: TPNGImage; Bitmap: TBitmap);
procedure LoadPNGImage32bit(PNG: TPNGImage; Bitmap: TBitmap; BackGroundColor: TColor);

procedure LoadPNGImage8BitWOTransparent(PNG: TPNGImage; Bitmap: TBitmap);
procedure LoadPNGImage8bitTransparent(PNG: TPNGImage; Bitmap: TBitmap);
procedure LoadPNGImagePalette(PNG: TPNGImage; Bitmap: TBitmap);

procedure SavePNGImageTransparent(PNG: TPNGImage; Bitmap: TBitmap);
procedure AssignPNG(Dest: TBitmap; Src: TPngImage);
procedure ApplyPNGIccProfile(PngImage: TPngImage; DisplayProfileName: string);

implementation

procedure ApplyPNGIccProfile(PngImage: TPngImage; DisplayProfileName: string);
var
  I, J :Integer;
  MSICC, D: TMemoryStream;
  DS: TDecompressionStream;
  PngChunk: TChunk;
  P: PAnsiChar;
begin
  {
     4.2.2.4. iCCP Embedded ICC profile
     If the iCCP chunk is present, the image samples conform to the color space represented by the embedded ICC profile
     as defined by the International Color Consortium [ICC]. The color space of the ICC profile must be an RGB color space
     for color images (PNG color types 2, 3, and 6), or a monochrome grayscale color space for grayscale images (PNG color types 0 and 4).

     The iCCP chunk contains:

     Profile name:       1-79 bytes (character string)
     Null separator:     1 byte
     Compression method: 1 byte
     Compressed profile: n bytes

     The format is like the zTXt chunk. (see the zTXt chunk specification).
     The profile name can be any convenient name for referring to the profile.
     It is case-sensitive and subject to the same restrictions as the keyword in a text chunk:
     it must contain only printable Latin-1 [ISO/IEC-8859-1] characters (33-126 and 161-255) and spaces (32),
     but no leading, trailing, or consecutive spaces. The only value presently defined for the compression method byte is 0,
     meaning zlib datastream with deflate compression (see Deflate/Inflate Compression). Decompression of the remainder of the chunk yields the ICC profile.
  }
  if not (PngImage.Header.ColorType in [COLOR_RGB, COLOR_RGBALPHA]) then
    //other types are not supported by little CMS
    Exit;

  for I := 0 to PngImage.Chunks.Count - 1 do
  begin
    PngChunk := PngImage.Chunks.Item[I];
    if (PngChunk.Name = 'iCCP') then
    begin
      P := PngChunk.Data;
      for J := 0 to PngChunk.DataSize - 2 do
      begin
        if (P[J] = #0) and (P[J + 1] = #0) then
        begin
          D := TMemoryStream.Create;
          try
            D.Write(Pointer(NativeInt(PngChunk.Data) + J + 2)^, Integer(PngChunk.DataSize) - J - 3);
            D.Seek(0, soFromBeginning);
            DS := TDecompressionStream.Create(D);
            try
              MSICC := TMemoryStream.Create;
              try
                try
                  MSICC.CopyFrom(DS, DS.Size);

                  ConvertPngToDisplayICCProfile(PngImage, PngImage, MSICC.Memory, MSICC.Size, DisplayProfileName);
                except
                  //ignore errors -> invalid or unsupported ICC profile
                  Exit;
                end;
              finally
                F(MSICC);
              end;
            finally
              F(DS);
            end;
          finally
            F(D);
          end;
          Break;
        end;
      end;
      Break;
    end;
  end;
end;

procedure AssignPNG(Dest: TBitmap; Src: TPngImage);
begin
  case TPngImage(Src).Header.ColorType of
    COLOR_GRAYSCALE:
      LoadPNGImage8BitWOTransparent(TPngImage(Src), Dest);
    COLOR_GRAYSCALEALPHA:
      LoadPNGImage8BitTransparent(TPngImage(Src), Dest);
    COLOR_PALETTE:
      LoadPNGImagePalette(TPngImage(Src), Dest);
    COLOR_RGB:
      LoadPNGImageWOTransparent(TPngImage(Src), Dest);
    COLOR_RGBALPHA:
      LoadPNGImageTransparent(TPngImage(Src), Dest);
    else
      Dest.Assign(Src);
  end;
end;

procedure SavePNGImageTransparent(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  DeltaS, DeltaSA, DeltaD: Integer;
  AddrLineS, AddrLineSA, AddrLineD: NativeInt;
  AddrS, AddrSA, AddrD: NativeInt;
begin
  PNG.Chunks.Free;
  PNG.Canvas.Free;
  PNG.CreateBlank(COLOR_RGBALPHA, 8, Bitmap.Width, Bitmap.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineSA := NativeInt(PNG.AlphaScanline[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := NativeInt(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrSA := AddrLineSA;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      PRGB(AddrS)^ := PRGB(AddrD)^;
      Inc(AddrS, 3);
      Inc(AddrD, 3);
      PByte(AddrSA)^ := PByte(AddrD)^;
      Inc(AddrD, 1);
      Inc(AddrSA, 1);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineSA, DeltaSA);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImageTransparent(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  DeltaS, DeltaSA, DeltaD: Integer;
  AddrLineS, AddrLineSA, AddrLineD: NativeInt;
  AddrS, AddrSA, AddrD: NativeInt;
begin
  if Bitmap.PixelFormat <> pf32bit then
    Bitmap.PixelFormat := pf32bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineSA := NativeInt(PNG.AlphaScanline[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := NativeInt(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
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
      if PByte(AddrD)^ = 0 then
        //integer is 4 bytes, but 4th byte is transparencity and it't = 0
        PInteger(AddrD - 3)^ := 0;
      Inc(AddrD, 1);
      Inc(AddrSA, 1);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineSA, DeltaSA);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImagePalette(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  P: Byte;
  DeltaS, DeltaD: Integer;
  AddrLineS, AddrLineD: NativeInt;
  AddrS, AddrD: NativeInt;
  Chunk: TChunkPLTE;
  TRNS: TChunktRNS;
  BitDepth, BitDepthD8,
  Rotater, ColorMask: Byte;
begin
  if PNG.Transparent then
    Bitmap.PixelFormat := pf32bit
  else
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
  end;

  BitDepth := PNG.Header.BitDepth; //1,2,4,8 only, 16 not supported by PNG specification

  //{2,16 bits for each pixel is not supported by windows bitmap} -> see PNG implementation
  if BitDepth = 2 then
    BitDepth := 4;
  if BitDepth = 16 then
    BitDepth := 8;


  BitDepthD8 := 8 - BitDepth;
  ColorMask := (255 shl BitDepthD8) and 255;

  Chunk := TChunkPLTE(PNG.Chunks.ItemFromClass(TChunkPLTE));
  if not PNG.Transparent then
  begin
    for I := 0 to PNG.Height - 1 do
    begin
      AddrS := AddrLineS;
      AddrD := AddrLineD;
      for J := 0 to PNG.Width - 1 do
      begin
        Rotater := J * BitDepth mod 8;

        P := ((PByte(AddrS + (J * BitDepth) div 8)^ shl Rotater) and ColorMask) shr BitDepthD8;

        with Chunk.Item[P] do
        begin
          PRGB(AddrD)^.R := PNG.GammaTable[rgbRed];
          PRGB(AddrD)^.G := PNG.GammaTable[rgbGreen];
          PRGB(AddrD)^.B := PNG.GammaTable[rgbBlue];
        end;

        Inc(AddrD, 3);
      end;
      Inc(AddrLineS, DeltaS);
      Inc(AddrLineD, DeltaD);
    end;
  end else
  begin
    TRNS := PNG.Chunks.ItemFromClass(TChunktRNS) as TChunktRNS;
    for I := 0 to PNG.Height - 1 do
    begin
      AddrS := AddrLineS;
      AddrD := AddrLineD;
      for J := 0 to PNG.Width - 1 do
      begin
        Rotater := J * BitDepth mod 8;

        P := ((PByte(AddrS + (J * BitDepth) div 8)^ shl Rotater) and ColorMask) shr BitDepthD8;

        with Chunk.Item[P] do
        begin
          PRGB32(AddrD)^.R := PNG.GammaTable[rgbRed];
          PRGB32(AddrD)^.G := PNG.GammaTable[rgbGreen];
          PRGB32(AddrD)^.B := PNG.GammaTable[rgbBlue];
          PRGB32(AddrD)^.L := TRNS.PaletteValues[P];
        end;

        Inc(AddrD, 4);
      end;
      Inc(AddrLineS, DeltaS);
      Inc(AddrLineD, DeltaD);
    end;
  end;
end;

procedure LoadPNGImage8bitTransparent(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  DeltaS, DeltaSA, DeltaD: Integer;
  AddrLineS, AddrLineSA, AddrLineD: NativeInt;
  AddrS, AddrSA, AddrD: NativeInt;
begin
  if Bitmap.PixelFormat <> pf32bit then
    Bitmap.PixelFormat := pf32bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineSA := NativeInt(PNG.AlphaScanline[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := NativeInt(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
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

procedure LoadPNGImage8BitWOTransparent(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  DeltaS, DeltaD: Integer;
  AddrLineS, AddrLineD: NativeInt;
  AddrS, AddrD: NativeInt;
  BitDepth, BitDepthD8, ColorMask, P, Rotater, Multilpyer: Byte;

begin
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
  end;

  BitDepth := PNG.Header.BitDepth; //1,2,4,8 only, 16 not supported by PNG specification

  //{2,16 bits for each pixel is not supported by windows bitmap} -> see PNG implementation
  if BitDepth = 2 then
    BitDepth := 4;
  if BitDepth = 16 then
    BitDepth := 8;

  BitDepthD8 := 8 - BitDepth;
  ColorMask := (255 shl BitDepthD8) and 255;

  Multilpyer := 1;
  case BitDepth of
    1: Multilpyer := 255;
    2: Multilpyer := 85;
    4: Multilpyer := 17;
    8: Multilpyer := 1;
  end;

  for I := 0 to PNG.Height - 1 do
  begin
    AddrS := AddrLineS;
    AddrD := AddrLineD;
    for J := 0 to PNG.Width - 1 do
    begin
      Rotater := J * BitDepth mod 8;

      P := ((PByte(AddrS + (J * BitDepth) div 8)^ shl Rotater) and ColorMask) shr BitDepthD8;

      PRGB(AddrD)^.R := P * Multilpyer;
      PRGB(AddrD)^.G := P * Multilpyer;
      PRGB(AddrD)^.B := P * Multilpyer;

      Inc(AddrD, 3);
    end;
    Inc(AddrLineS, DeltaS);
    Inc(AddrLineD, DeltaD);
  end;
end;

procedure LoadPNGImageWOTransparent(PNG: TPNGImage; Bitmap: TBitmap);
var
  I, J: Integer;
  DeltaS, DeltaD: Integer;
  AddrLineS, AddrLineD: NativeInt;
  AddrS, AddrD: NativeInt;
begin
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);
  DeltaS := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
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

procedure LoadPNGImage32bit(PNG: TPNGImage; Bitmap: TBitmap; BackGroundColor: TColor);
var
  I, J: Integer;
  DeltaS, DeltaSA, DeltaD: Integer;
  AddrLineS, AddrLineD, AddrLineSA: NativeInt;
  AddrS, AddrD, AddrSA: NativeInt;
  R, G, B: Integer;
  W1, W2: Integer;
  S, D: PRGB;
  BPNG: TBitmap;
begin
  //only ARBG is supported
  //for other formats -> use transform: PNG -> BMP -> Extract BMP24
  case TPngImage(PNG).Header.ColorType of
    COLOR_GRAYSCALE,
    COLOR_GRAYSCALEALPHA,
    COLOR_PALETTE,
    COLOR_RGB:
      begin
        BPNG := TBitmap.Create;
        try
          AssignPNG(BPNG, PNG);
          LoadBMPImage32bit(BPNG, Bitmap, BackGroundColor);
        finally
          F(BPNG);
        end;
        Exit;
      end;
  end;

  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  Bitmap.SetSize(PNG.Width, PNG.Height);

  AddrLineS := NativeInt(PNG.ScanLine[0]);
  AddrLineSA := NativeInt(PNG.AlphaScanline[0]);
  AddrLineD := NativeInt(Bitmap.ScanLine[0]);

  DeltaS := 0;
  DeltaSA := 0;
  DeltaD := 0;
  if PNG.Height > 1 then
  begin
    DeltaS := NativeInt(PNG.ScanLine[1]) - AddrLineS;
    DeltaSA := NativeInt(PNG.AlphaScanline[1]) - AddrLineSA;
    DeltaD := NativeInt(Bitmap.ScanLine[1])- AddrLineD;
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
