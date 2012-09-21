unit uFreeImageImage;

interface

uses
  Windows,
  SysUtils,
  Graphics,
  Classes,
  uMemory,
  uConstants,
  uFileUtils,
  uTime,
  FreeBitmap,
  FreeImage,
  uFreeImageIO,
  GraphicsBaseTypes,
  CCR.Exif,
  uBitmapUtils;

type
  TFreeImageImage = class(TBitmap)
  private
    procedure LoadFromFreeImage(Image: TFreeBitmap);
  protected
    function Flags: Integer;
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromFile(const Filename: string); override;
  end;

implementation

{ TFreeImageImage }

constructor TFreeImageImage.Create;
begin
  inherited;
  FreeImageInit;
end;

function TFreeImageImage.Flags: Integer;
begin
  Result := 0;
end;

procedure TFreeImageImage.LoadFromFile(const FileName: string);
var
  RawBitmap: TFreeWinBitmap;
  IsValidImage: Boolean;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    IsValidImage := RawBitmap.LoadU(FileName, Flags);

    if not IsValidImage then
      raise Exception.Create('Invalid Free Image File format!');

    LoadFromFreeImage(RawBitmap);
  finally
    F(RawBitmap);
  end;
end;

procedure TFreeImageImage.LoadFromStream(Stream: TStream);
var
  RawBitmap: TFreeWinBitmap;
  IO: FreeImageIO;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    SetStreamFreeImageIO(IO);
    if RawBitmap.LoadFromHandle(@IO, Stream, Flags) then
      LoadFromFreeImage(RawBitmap);
  finally
    F(RawBitmap);
  end;
end;

procedure TFreeImageImage.LoadFromFreeImage(Image: TFreeBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  PS32, PD32: PARGB32;
  W, H: Integer;
  FreeImage: PFIBITMAP;
begin
  if not (Image.GetBitsPerPixel in [24, 32, 96, 128]) then
    Image.ConvertTo24Bits;

  if Image.GetBitsPerPixel = 96 then
    Image.ToneMapping(FITMO_DRAGO03, 0, 0);

  if Image.GetBitsPerPixel = 128 then
    Image.ToneMapping(FITMO_DRAGO03, 0, 0);

  if Image.GetBitsPerPixel = 32 then
    PixelFormat := pf32Bit;

  if Image.GetBitsPerPixel = 24 then
    PixelFormat := pf24Bit;

  W := Image.GetWidth;
  H := Image.GetHeight;
  SetSize(W, H);

  FreeImage := Image.Dib;

  if Image.GetBitsPerPixel = 24 then
    for I := 0 to H - 1 do
    begin
      PS := PARGB(FreeImage_GetScanLine(FreeImage, H - I - 1));
      PD := ScanLine[I];
      for J := 0 to W - 1 do
        PD[J] := PS[J];
    end;

  if Image.GetBitsPerPixel = 32 then
    for I := 0 to H - 1 do
    begin
      PS32 := PARGB32(FreeImage_GetScanLine(FreeImage, H - I - 1));
      PD32 := ScanLine[I];
      for J := 0 to W - 1 do
        PD32[J] := PS32[J];
    end;
end;

initialization

  TPicture.RegisterFileFormat('jp2', 'JPEG 2000 Images', TFreeImageImage);
  TPicture.RegisterFileFormat('j2k', 'JPEG 2000 Images', TFreeImageImage);
  TPicture.RegisterFileFormat('jpf', 'JPEG 2000 Images', TFreeImageImage);
  TPicture.RegisterFileFormat('jpx', 'JPEG 2000 Images', TFreeImageImage);
  TPicture.RegisterFileFormat('jpm', 'JPEG 2000 Images', TFreeImageImage);
  TPicture.RegisterFileFormat('mj2', 'JPEG 2000 Images', TFreeImageImage);

  TPicture.RegisterFileFormat('dds', 'DirectDraw Surface graphics', TFreeImageImage);

  TPicture.RegisterFileFormat('hdr', 'DirectDraw Surface graphics', TFreeImageImage);
  TPicture.RegisterFileFormat('exr', 'DirectDraw Surface graphics', TFreeImageImage);

  TPicture.RegisterFileFormat('iff', 'Amiga IFF Graphic', TFreeImageImage);

  TPicture.RegisterFileFormat('jng', 'JPEG Network Graphic', TFreeImageImage);

  //TPicture.RegisterFileFormat('xbm', 'X11 Bitmap Graphic', TFreeImageImage);
  //TPicture.RegisterFileFormat('xpm', 'X11 Bitmap Graphic', TFreeImageImage);

  //TPicture.RegisterFileFormat('mng', 'Multiple Network Graphic', TFreeImageImage);


finalization

  TPicture.UnregisterGraphicClass(TFreeImageImage);

end.
