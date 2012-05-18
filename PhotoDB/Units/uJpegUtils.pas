unit uJpegUtils;

interface

uses
  jpeg,
  Graphics,
  Math,
  Classes,
  uMemory,
  uBitmapUtils;

type
  TJPEGX = class(TJpegImage)
  public
    function InnerBitmap: TBitmap;
  end;

procedure AssignJpeg(Bitmap: TBitmap; Jpeg: TJPEGImage);
procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
function CalcJpegResampledSize(Jpeg: TJpegImage; Size: Integer; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
function CalcBitmapToJPEGCompressSize(Bitmap: TBitmap; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
procedure FreeJpegBitmap(J: TJpegImage);

implementation

{ TJPEGX }

procedure FreeJpegBitmap(J: TJpegImage);
begin
  TJpegX(J).FreeBitmap;
end;

function TJPEGX.InnerBitmap: TBitmap;
begin
  Result := Bitmap;
end;

procedure AssignJpeg(Bitmap: TBitmap; Jpeg: TJPEGImage);
begin
  JPEG.Performance := jpBestSpeed;
  try
    JPEG.DIBNeeded;
  except
    //incorrect file will throw an error, but bitmap will be available so we can display partically decompressed image
  end;
  if TJPEGX(JPEG).InnerBitmap <> nil then
    SetLastError(0);
  AssignBitmap(Bitmap, TJPEGX(JPEG).InnerBitmap);
end;

procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
var
  ScaleX, ScaleY, Scale: Extended;
begin
  if (Graphic is TJpegImage) then
  begin
    (Graphic as TJpegImage).Performance := jpBestSpeed;
    (Graphic as TJpegImage).ProgressiveDisplay := False;
    ScaleX:= Graphic.Width / Width;
    ScaleY := Graphic.Height / Height;
    Scale := Max(ScaleX, ScaleY);
    if Scale < 2 then
      (Graphic as TJpegImage).Scale := JsFullSize;
    if (Scale >= 2) and (Scale < 4) then
      (Graphic as TJpegImage).Scale := JsHalf;
    if (Scale >= 4) and (Scale < 8) then
      (Graphic as TJpegImage).Scale := JsQuarter;
    if Scale >= 8 then
      (Graphic as TJpegImage).Scale := JsEighth;
  end;
end;

function CalcBitmapToJPEGCompressSize(Bitmap: TBitmap; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
var
  Jpeg: TJpegImage;
  MS: TMemoryStream;
begin
  Jpeg := TJpegImage.Create;
  try
    Jpeg.Assign(Bitmap);
      if CompressionRate < 1 then
      CompressionRate := 1;
    if CompressionRate > 100 then
      CompressionRate := 100;
    Jpeg.CompressionQuality := CompressionRate;
    Jpeg.Compress;

    MS := TMemoryStream.Create;
    try
      Jpeg.SaveToStream(MS);
      JpegImageResampled := TJpegImage.Create;
      MS.Seek(0, soFromBeginning);
      JpegImageResampled.LoadFromStream(MS);
      Result := MS.Size;
    finally
      F(MS);
    end;
  finally
    F(Jpeg);
  end;
end;

function CalcJpegResampledSize(jpeg: TJpegImage; Size: Integer;
  CompressionRate: Byte; out JpegImageResampled: TJpegImage): Int64;
var
  Bitmap, OutBitmap: TBitmap;
  W, H: Integer;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Assign(Jpeg);
    OutBitmap := TBitmap.Create;
    try
      W := Jpeg.Width;
      H := Jpeg.Height;
      ProportionalSize(Size, Size, W, H);
      DoResize(W, H, Bitmap, OutBitmap);
      Result := CalcBitmapToJPEGCompressSize(OutBitmap, CompressionRate, JpegImageResampled);
    finally
      F(OutBitmap);
    end;
  finally
    F(Bitmap);
  end;
end;

end.
