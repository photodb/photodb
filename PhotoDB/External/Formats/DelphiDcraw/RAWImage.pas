unit RAWImage;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,

  CCR.Exif,

  Dmitry.Utils.Files,
  Dmitry.Graphics.Types,

  FreeBitmap,
  FreeImage,

  uMemory,
  uConstants,
  uTime,
  uFreeImageIO,
  uBitmapUtils;

type
  TRAWImage = class(TBitmap)
  private
    FDisplayDibSize: Boolean;
    FHalfSizeLoad: Boolean;
    procedure SetIsPreview(const Value: boolean);
    procedure LoadFromFreeImage(Image: TFreeBitmap);
    function Flags: Integer;
  protected
    FWidth: Integer;
    FHeight: Integer;
    FIsPreview: Boolean;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FPreviewSize: Integer;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromFile(const Filename: string); override;
    function LoadThumbnailFromFile(const FileName: string; Width, Height: Integer) : boolean;
    procedure Assign(Source: TPersistent); override;
    property IsPreview: Boolean read FIsPreview write SetIsPreview;
    property GraphicWidth: Integer read FWidth;
    property GraphicHeight: Integer read FHeight;
    property DisplayDibSize: Boolean read FDisplayDibSize write FDisplayDibSize;
    property HalfSizeLoad: Boolean read FHalfSizeLoad write FHalfSizeLoad;
    property PreviewSize: Integer read FPreviewSize write FPreviewSize;
  end;

var
  IsRAWSupport: Boolean = True;

implementation

{ TRAWImage }

function GetExifOrientation(RawBitmap: TFreeWinBitmap; Model: Integer): Integer;
const
  TAG_ORIENTATION = $0112;
var
  FindMetaData : PFIMETADATA;
  TagData : PFITAG;

  procedure ProcessTag;
  begin
    if FreeImage_GetTagID(TagData) = TAG_ORIENTATION then
    begin
      Result := PWord(FreeImage_GetTagValue(TagData))^;
      if Result > 8 then
        Result := 0;
    end;
  end;

begin
  Result := DB_IC_ROTETED_0;

  FindMetaData := FreeImage_FindFirstMetadata(Model, RawBitmap.Dib, TagData);
  try
    if FindMetaData <> nil then
    begin
      ProcessTag;

      while FreeImage_FindNextMetadata(FindMetaData, TagData) do
        ProcessTag;
    end;
  finally
    RawBitmap.FindCloseMetadata(FindMetaData);
  end;
end;

procedure TRAWImage.Assign(Source: TPersistent);
begin
  if Source is TRAWImage then
  begin
    //for crypting - loading private variables width and height
    FWidth := (Source as TRAWImage).FWidth;
    FHeight := (Source as TRAWImage).FHeight;
    FRealWidth := (Source as TRAWImage).FRealWidth;
    FRealHeight := (Source as TRAWImage).FRealHeight;
    FIsPreview := (Source as TRAWImage).FIsPreview;
  end;
  inherited Assign(Source);
end;

constructor TRAWImage.Create;
begin
  inherited;
  FreeImageInit;
  FIsPreview := False;
  FRealWidth := 0;
  FRealHeight := 0;
  FPreviewSize := 0;
  FDisplayDibSize := False;
  HalfSizeLoad := False;
end;

function TRAWImage.Flags: Integer;
begin
  if IsPreview then
    Result := RAW_PREVIEW
  else
    Result := RAW_DISPLAY;

  if IsPreview then
    Result := Result or FPreviewSize shl 16;

  if FHalfSizeLoad then
    Result := Result or RAW_HALFSIZE;
end;

function TRAWImage.GetHeight: Integer;
begin
  if FIsPreview and not FDisplayDibSize and (FRealHeight > 0) then
    Result := FRealHeight
  else
    Result := FHeight;
end;

function TRAWImage.GetWidth: Integer;
begin
  if FIsPreview and not FDisplayDibSize and (FRealWidth > 0) then
    Result := FRealWidth
  else
    Result := FWidth;
end;

function IIF(Condition: Boolean; A1, A2: Integer): Integer;
begin
  if Condition then
    Result := A1
  else
    Result := A2;
end;

procedure TRAWImage.LoadFromFile(const FileName: string);
var
  RawBitmap: TFreeWinBitmap;
  IsValidImage: Boolean;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    IsValidImage := RawBitmap.LoadU(FileName, Flags);

    if not IsValidImage then
      raise Exception.Create('Invalid RAW File format!');

    FWidth := RawBitmap.GetWidth;
    FHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);
    if FIsPreview then
    begin
      RawBitmap.Clear;
      RawBitmap.LoadU(FileName, FIF_LOAD_NOPIXELS);
      FRealWidth := FreeImage_GetWidth(RawBitmap.Dib);
      FRealHeight := FreeImage_GetHeight(RawBitmap.Dib);
    end;
  finally
    F(RawBitmap);
  end;
end;

procedure TRAWImage.LoadFromStream(Stream: TStream);
var
  RawBitmap: TFreeWinBitmap;
  IO: FreeImageIO;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    SetStreamFreeImageIO(IO);
    RawBitmap.LoadFromHandle(@IO, Stream, Flags);

    FWidth := RawBitmap.GetWidth;
    FHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);

    if FIsPreview then
    begin
      RawBitmap.Clear;
      Stream.Seek(0, soFromBeginning);
      RawBitmap.LoadFromHandle(@IO, Stream, FIF_LOAD_NOPIXELS);

      FRealWidth := FreeImage_GetWidth(RawBitmap.Dib);
      FRealHeight := FreeImage_GetHeight(RawBitmap.Dib);
    end;
  finally
    F(RawBitmap);
  end;
end;

procedure TRAWImage.LoadFromFreeImage(Image: TFreeBitmap);
var
  I, J: Integer;
  PS, PD: PARGB;
  W, H: Integer;
  FreeImage: PFIBITMAP;
begin
  PixelFormat := pf24Bit;
  W := Image.GetWidth;
  H := Image.GetHeight;
  Width := W;
  Height := H;

  FreeImage := Image.Dib;
  for I := 0 to H - 1 do
  begin
    PS := PARGB(FreeImage_GetScanLine(FreeImage, H - I - 1));
    PD := ScanLine[I];
    for J := 0 to W - 1 do
      PD[J] := PS[J];
  end;
end;

function TRAWImage.LoadThumbnailFromFile(const FileName: string; Width, Height: Integer): Boolean;
var
  RawBitmap: TFreeWinBitmap;
  RawThumb: TFreeWinBitmap;
  W, H: Integer;
begin
  Result := True;
  FIsPreview := True;

  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadU(FileName, RAW_PREVIEW);
    RawThumb := TFreeWinBitmap.Create;
    try
      FWidth := RawBitmap.GetWidth;
      FHeight := RawBitmap.GetHeight;
      W := FWidth;
      H := FHeight;
      ProportionalSize(Width, Height, W, H);
      RawBitmap.MakeThumbnail(W, H, RawThumb);
      LoadFromFreeImage(RawThumb);
    finally
      F(RawThumb);
    end;
    RawBitmap.Clear;
    RawBitmap.LoadU(FileName, FIF_LOAD_NOPIXELS);
    FRealWidth := FreeImage_GetWidth(RawBitmap.Dib);
    FRealHeight := FreeImage_GetHeight(RawBitmap.Dib);
  finally
    F(RawBitmap);
  end;
end;

procedure TRAWImage.SetIsPreview(const Value: boolean);
begin
  FIsPreview := Value;
end;

initialization

  TPicture.RegisterFileFormat('3fr', 'Hasselblad Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('arw', 'Sony Digital Camera Raw Image Format for Alpha devices', TRAWImage);
  TPicture.RegisterFileFormat('bay', 'Casio Digital Camera Raw File Format', TRAWImage);
  TPicture.RegisterFileFormat('cap', 'Phase One Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('cine', 'Phantom Software Raw Image File', TRAWImage);
  TPicture.RegisterFileFormat('cr2', 'Canon Digital Camera RAW Image Format version 2.0', TRAWImage);
  TPicture.RegisterFileFormat('crw', 'Canon Digital Camera RAW Image Format version 1.0', TRAWImage);
  TPicture.RegisterFileFormat('cs1', 'Sinar Capture Shop Raw Image File', TRAWImage);
  TPicture.RegisterFileFormat('dc2', 'Kodak DC25 Digital Camera File', TRAWImage);
  TPicture.RegisterFileFormat('dcr', 'Kodak Digital Camera Raw Image Format for these models: Kodak DSC Pro SLR/c, Kodak DSC Pro SLR/n, Kodak DSC Pro 14N, Kodak DSC PRO 14nx.', TRAWImage);
  TPicture.RegisterFileFormat('drf', 'Kodak Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('dsc', 'Kodak Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('dng', 'Adobe Digital Negative: DNG is publicly available archival format for the raw files generated by digital cameras. ' + 'By addressing the lack of an open standard for the raw files created by individual camera models, DNG helps ensure that photographers will be able to access their files in the future.', TRAWImage);
  TPicture.RegisterFileFormat('erf', 'Epson Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('fff', 'Imacon Digital Camera Raw Image Format', TRAWImage);

  TPicture.RegisterFileFormat('ia', 'Sinar Raw Image File', TRAWImage);
  TPicture.RegisterFileFormat('iiq', 'Phase One Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('k25', 'Kodak DC25 Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('kc2', 'Kodak DCS200 Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('kdc', 'Kodak Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('mdc', 'Minolta RD175 Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('mef', 'Mamiya Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('mos', 'Leaf Raw Image File', TRAWImage);

  TPicture.RegisterFileFormat('mrw', 'Minolta Dimage Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('nef', 'Nikon Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('nrw', 'Nikon Digital Camera Raw Image Format', TRAWImage);

  TPicture.RegisterFileFormat('orf', 'Olympus Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('pef', 'Pentax Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('ptx', 'Pentax Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('pxn', 'Logitech Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('qtk', 'Apple Quicktake 100/150 Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('raf', 'Fuji Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('raw', 'Panasonic Digital Camera Image Format', TRAWImage);

  TPicture.RegisterFileFormat('rdc', 'Digital Foto Maker Raw Image File', TRAWImage);
  TPicture.RegisterFileFormat('rw2', 'Panasonic LX3 Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('rwl', 'Leica Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('rwz', 'Rawzor Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('sr2', 'Sony Digital Camera Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('srf', 'Sony Digital Camera Raw Image Format for DSC-F828 8 megapixel digital camera or Sony DSC-R1', TRAWImage);
  TPicture.RegisterFileFormat('srw', 'Samsung Raw Image Format', TRAWImage);
  TPicture.RegisterFileFormat('sti', 'Sinar Capture Shop Raw Image File', TRAWImage);

finalization

  TPicture.UnregisterGraphicClass(TRAWImage);

end.
