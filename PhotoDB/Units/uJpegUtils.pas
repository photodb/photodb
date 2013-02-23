unit uJpegUtils;

interface

uses
  System.Math,
  System.Classes,

  Vcl.Imaging.jpeg,
  Vcl.Graphics,

  uMemory,
  uSettings,
  uBitmapUtils;

type
  TJPEGX = class(TJpegImage)
  public
    function InnerBitmap: TBitmap;
  end;

type
  TCompresJPEGToSizeCallback = procedure(CurrentSize, CompressionRate: Integer; var Break: Boolean) of object;

procedure AssignJpeg(Bitmap: TBitmap; Jpeg: TJPEGImage);
procedure JPEGScale(Graphic: TGraphic; Width, Height: Integer);
function CalcJpegResampledSize(Jpeg: TJpegImage; Size: Integer; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
function CalcBitmapToJPEGCompressSize(Bitmap: TBitmap; CompressionRate: Byte;
  out JpegImageResampled: TJpegImage): Int64;
procedure FreeJpegBitmap(J: TJpegImage);
function CompresJPEGToSize(JS: TGraphic; var ToSize: Integer; Progressive: Boolean; var CompressionRate: Integer;
  CallBack: TCompresJPEGToSizeCallback = nil): Boolean;
procedure SetJPEGGraphicSaveOptions(Section: string; Graphic: TGraphic);

implementation

procedure SetJPEGGraphicSaveOptions(Section: string; Graphic: TGraphic);
var
  OptimizeToSize: Integer;
  Progressive: Boolean;
  Compression: Integer;
begin
  if Graphic is TJPEGImage then
  begin
    OptimizeToSize := Settings.ReadInteger(Section, 'JPEGOptimizeSize', 250) * 1024;
    Progressive := Settings.ReadBool(Section, 'JPEGProgressiveMode', False);

    if Settings.ReadBool(Section, 'JPEGOptimizeMode', False) then
      CompresJPEGToSize(Graphic, OptimizeToSize, Progressive, Compression)
    else
      Compression := Settings.ReadInteger(Section, 'JPEGCompression', 85);

   (Graphic as TJPEGImage).CompressionQuality := Compression;
   (Graphic as TJPEGImage).ProgressiveEncoding := Progressive;
   (Graphic as TJPEGImage).Compress;
  end;
end;

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

function CompresJPEGToSize(JS: TGraphic; var ToSize: Integer; Progressive: Boolean; var CompressionRate: Integer;
  CallBack: TCompresJPEGToSizeCallback = nil): Boolean;
var
  Ms: TMemoryStream;
  Jd: TJPEGImage;
  Max_size, Cur_size, Cur_cr, Cur_cr_inc: Integer;
  IsBreak: Boolean;
begin
  Result := False;
  Max_size := ToSize;
  Cur_cr := 50;
  Cur_cr_inc := 50;
  IsBreak := False;
  Jd := TJpegImage.Create;
  try
    repeat
      Jd.Assign(Js);
      Jd.CompressionQuality := Cur_cr;
      Jd.ProgressiveEncoding := Progressive;
      Jd.Compress;
      Ms := TMemoryStream.Create;
      try
        Jd.SaveToStream(Ms);
        Cur_size := Ms.Size;

        if Assigned(CallBack) then
          CallBack(Cur_size, Cur_cr, IsBreak);

        if IsBreak then
        begin
          CompressionRate := -1;
          ToSize := -1;
          Exit;
        end;

        if ((Cur_size < Max_size) and (Cur_cr_inc = 1)) or (Cur_cr = 1) then
          Break;

        Cur_cr_inc := Round(Cur_cr_inc / 2);
        if Cur_cr_inc < 1 then
          Cur_cr_inc := 1;
        if Cur_size < Max_size then
        begin
          Cur_cr := Cur_cr + Cur_cr_inc;
        end
        else
          Cur_cr := Cur_cr - Cur_cr_inc;
        if (Cur_size < Max_size) and (Cur_cr = 99) then
          Cur_cr_inc := 2;

      finally
        F(MS);
      end;
    until False;
  finally
    F(JD);
  end;

  CompressionRate := Cur_cr;
  ToSize := Cur_size;
  Result := True;
end;

end.
