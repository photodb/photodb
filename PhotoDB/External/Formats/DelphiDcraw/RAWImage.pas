unit RAWImage;

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
  TRAWImage = class(TBitmap)
  protected
    FWidth: Integer;
    FHeight: Integer;
    FIsPreview: Boolean;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FPreviewSize: Integer;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
  private
    FDisplayDibSize: Boolean;
    FHalfSizeLoad: Boolean;
    procedure SetIsPreview(const Value: boolean);
    procedure LoadFromFreeImage(Image: TFreeBitmap);
    function Flags: Integer;
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

  TRAWExifRecord = class(TObject)
  private
    FDescription : string;
    FKey: string;
    FValue: string;
  public
    property Key: string read FKey write FKey;
    property Value: string read FValue write FValue;
    property Description: string read FDescription write FDescription;
  end;

  TRAWExif = class(TObject)
  private
    FExifList: TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TRAWExifRecord;
    function GetTimeStamp: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Description, Key, Value: string): TRAWExifRecord;
    function IsEXIF: Boolean;
    property TimeStamp: TDateTime read GetTimeStamp;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TRAWExifRecord read GetValueByIndex; default;
  end;

  function ReadRAWExif(FileName: String): TRAWExif;

var
  IsRAWSupport: Boolean = True;

implementation

uses
  Dolphin_DB, UnitDBCommon;

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

function ReadRAWExif(FileName: String): TRAWExif;
var
  RawBitmap: TFreeWinBitmap;
  FindMetaData: PFIMETADATA;
  I: Integer;
  TagData: PFITAG;

  procedure AddTag;
  var
    Description, Value, Key: PAnsiChar;
  begin
    Description := FreeImage_GetTagDescription(TagData);
    Key := FreeImage_GetTagKey(TagData);
    if (Key <> 'Artist') and (Description <> 'Image title') then
    begin
      Value := FreeImage_TagToString(I, TagData);
      if Description <> nil then
        Result.Add(string(Description), string(Key), string(Value))
      else
        Result.Add(string(Key), string(Key), string(Value));
    end;
  end;
begin
  Result := TRAWExif.Create;

  TagData := nil;
  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadU(FileName, FIF_LOAD_NOPIXELS);
    for I := FIMD_NODATA to FIMD_EXIF_RAW do
    begin
      FindMetaData := FreeImage_FindFirstMetadata(I, RawBitmap.Dib, TagData);
      try
        if FindMetaData <> nil then
        begin
          AddTag;

          while FreeImage_FindNextMetadata(FindMetaData, TagData) do
            AddTag;
        end;
      finally
        RawBitmap.FindCloseMetadata(FindMetaData);
      end;
    end;
  finally
    F(RawBitmap);
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

{ TRAWExif }

function TRAWExif.Add(Description, Key, Value: string) : TRAWExifRecord;
begin
  Result := TRAWExifRecord.Create;
  Result.Description := Description;
  Result.Key := Key;
  Result.Value := Value;
  FExifList.Add(Result);
end;

constructor TRAWExif.Create;
begin
  FreeImageInit;
  FExifList := TList.Create;
end;

destructor TRAWExif.Destroy;
begin
  FreeList(FExifList);
  inherited;
end;

function TRAWExif.GetCount: Integer;
begin
  Result := FExifList.Count;
end;

function TRAWExif.GetTimeStamp: TDateTime;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Self[I].Key = 'DateTime' then
        Result := EXIFDateToDate(Self[I].Value) + EXIFDateToTime(Self[I].Value);
end;

function TRAWExif.GetValueByIndex(Index: Integer): TRAWExifRecord;
begin
  Result := FExifList[Index];
end;

function TRAWExif.IsEXIF: Boolean;
begin
  Result := Count > 0;
end;

initialization

{
		"3fr,"   // Hasselblad Digital Camera Raw Image Format.
		"arw,"   // Sony Digital Camera Raw Image Format for Alpha devices.
		"bay,"   // Casio Digital Camera Raw File Format.
		"bmq,"   // NuCore Raw Image File.
		"cap,"   // Phase One Digital Camera Raw Image Format.
		"cine,"  // Phantom Software Raw Image File.
		"cr2,"   // Canon Digital Camera RAW Image Format version 2.0. These images are based on the TIFF image standard.
		"crw,"   // Canon Digital Camera RAW Image Format version 1.0.
		"cs1,"   // Sinar Capture Shop Raw Image File.
		"dc2,"   // Kodak DC25 Digital Camera File.
		"dcr,"   // Kodak Digital Camera Raw Image Format for these models: Kodak DSC Pro SLR/c, Kodak DSC Pro SLR/n, Kodak DSC Pro 14N, Kodak DSC PRO 14nx.
		"drf,"   // Kodak Digital Camera Raw Image Format.
		"dsc,"   // Kodak Digital Camera Raw Image Format.
		"dng,"   // Adobe Digital Negative: DNG is publicly available archival format for the raw files generated by digital cameras. By addressing the lack of an open standard for the raw files created by individual camera models, DNG helps ensure that photographers will be able to access their files in the future.
		"erf,"   // Epson Digital Camera Raw Image Format.
		"fff,"   // Imacon Digital Camera Raw Image Format.
		"ia,"    // Sinar Raw Image File.
		"iiq,"   // Phase One Digital Camera Raw Image Format.
		"k25,"   // Kodak DC25 Digital Camera Raw Image Format.
		"kc2,"   // Kodak DCS200 Digital Camera Raw Image Format.
		"kdc,"   // Kodak Digital Camera Raw Image Format.
		"mdc,"   // Minolta RD175 Digital Camera Raw Image Format.
		"mef,"   // Mamiya Digital Camera Raw Image Format.
		"mos,"   // Leaf Raw Image File.
		"mrw,"   // Minolta Dimage Digital Camera Raw Image Format.
		"nef,"   // Nikon Digital Camera Raw Image Format.
		"nrw,"   // Nikon Digital Camera Raw Image Format.
		"orf,"   // Olympus Digital Camera Raw Image Format.
		"pef,"   // Pentax Digital Camera Raw Image Format.
		"ptx,"   // Pentax Digital Camera Raw Image Format.
		"pxn,"   // Logitech Digital Camera Raw Image Format.
		"qtk,"   // Apple Quicktake 100/150 Digital Camera Raw Image Format.
		"raf,"   // Fuji Digital Camera Raw Image Format.
		"raw,"   // Panasonic Digital Camera Image Format.
		"rdc,"   // Digital Foto Maker Raw Image File.
		"rw2,"   // Panasonic LX3 Digital Camera Raw Image Format.
		"rwl,"	 // Leica Camera Raw Image Format.
		"rwz,"   // Rawzor Digital Camera Raw Image Format.
		"sr2,"   // Sony Digital Camera Raw Image Format.
		"srf,"   // Sony Digital Camera Raw Image Format for DSC-F828 8 megapixel digital camera or Sony DSC-R1.
		"srw,"   // Samsung Raw Image Format.
		"sti";   // Sinar Capture Shop Raw Image File.
}

  TPicture.RegisterFileFormat('crw', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('cr2', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('nef', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('raf', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('dng', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('mos', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('kdc', 'Camera RAW Images', TRAWImage);
  TPicture.RegisterFileFormat('dcr', 'Camera RAW Images', TRAWImage);

finalization

  TPicture.UnregisterGraphicClass(TRAWImage);

end.
