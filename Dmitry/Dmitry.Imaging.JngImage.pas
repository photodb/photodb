unit Dmitry.Imaging.JngImage;

interface

uses
  System.Classes,
  Vcl.Graphics,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,

  Dmitry.Memory,
  Dmitry.Graphics.Types;

type
  TJNGImage = class(TBitmap)
  private
    FJpegConpresionQuality: TJPEGQualityRange;
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    property JpegConpresionQuality: TJPEGQualityRange read FJpegConpresionQuality write FJpegConpresionQuality;
  end;

implementation

{ TJNGImage }

constructor TJNGImage.Create;
begin
  inherited Create;
  FJpegConpresionQuality := 85;
  PixelFormat := pf32Bit;
end;

procedure TJNGImage.LoadFromStream(Stream: TStream);
var
  B: TBitmap;
  Png: TPngImage;
  JpegImage: TJpegImage;
  I, J: Integer;
  P: PARGB;
  P32: PARGB32;
  AP: PByteArray;
begin
  Png := TPngImage.Create;
  JpegImage := TJpegImage.Create;
  B := TBitmap.Create;
  try
    Png.LoadFromStream(Stream);
    JpegImage.LoadFromStream(Stream);

    JpegImage.DIBNeeded;
    B.Assign(JpegImage);
    B.PixelFormat := pf24Bit;

    AlphaFormat := afDefined;
    SetSize(B.Width, B.Height);

    for I := 0 to Height - 1 do
    begin
      P32 := Self.ScanLine[I];
      P := B.ScanLine[I];
      AP := Png.Scanline[I];
      for J := 0 to Width - 1 do
      begin
        P32[J].R := P[J].R;
        P32[J].G := P[J].G;
        P32[J].B := P[J].B;
        P32[J].L := AP[J];
      end;
    end;

  finally
    F(B);
    F(JpegImage);
    F(Png);
  end;
end;

procedure TJNGImage.SaveToStream(Stream: TStream);
var
  B: TBitmap;
  Png: TPngImage;
  JpegImage: TJpegImage;
  I, J: Integer;
  P: PARGB;
  P32: PARGB32;
  AP: PByteArray;
begin
  Png := TPngImage.CreateBlank(COLOR_GRAYSCALE, 8, Width, Height);
  JpegImage := TJpegImage.Create;
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24Bit;
    B.SetSize(Width, Height);
    for I := 0 to Height - 1 do
    begin
      P32 := Self.ScanLine[I];
      P := B.ScanLine[I];
      AP := Png.Scanline[I];
      for J := 0 to Width - 1 do
      begin
        P[J].R := P32[J].R;
        P[J].G := P32[J].G;
        P[J].B := P32[J].B;
        AP[J] := P32[J].L;
      end;
    end;

    JpegImage.Assign(B);
    JpegImage.CompressionQuality := FJpegConpresionQuality;
    JpegImage.ProgressiveEncoding := False;
    JpegImage.Performance := jpBestQuality;
    JpegImage.Compress;

    Png.SaveToStream(Stream);
    JpegImage.SaveToStream(Stream);
  finally
    F(B);
    F(JpegImage);
    F(Png);
  end;
end;

end.
