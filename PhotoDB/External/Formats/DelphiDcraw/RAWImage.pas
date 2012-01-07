unit RAWImage;

interface

uses
  Windows, SysUtils, Graphics, Classes, uMemory,
  uConstants, uFileUtils, uTime, FreeBitmap, FreeImage, GraphicsBaseTypes,
  CCR.Exif, uBitmapUtils;

type
  TRAWImage = class(TBitmap)
  protected
    FWidth: Integer;
    FHeight: Integer;
    FIsPreview: Boolean;
    FRealWidth: Integer;
    FRealHeight: Integer;
    function GetWidth: Integer; override;
    function GetHeight: Integer; override;
  private
    FDisplayDibSize: Boolean;
    FHalfSizeLoad: Boolean;
    procedure SetIsPreview(const Value: boolean);
    procedure LoadFromFreeImage(Image: TFreeBitmap);
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
    function Add(Description, Key, Value: string) : TRAWExifRecord;
    function IsEXIF: Boolean;
    property TimeStamp : TDateTime read GetTimeStamp;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TRAWExifRecord read GetValueByIndex; default;
  end;

  function ReadRAWExif(FileName: String) : TRAWExif;

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

function ReadRAWExif(FileName: String) : TRAWExif;
var
  RawBitmap : TFreeWinBitmap;
  FindMetaData : PFIMETADATA;
  I : Integer;
  TagData : PFITAG;

  procedure AddTag;
  var
    Description, Value, Key : PAnsiChar;
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
  FDisplayDibSize := False;
  HalfSizeLoad := False;
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
    if FIsPreview then
      IsValidImage := RawBitmap.LoadU(FileName, RAW_PREVIEW)
    else
      IsValidImage := RawBitmap.LoadU(FileName, IIF(FHalfSizeLoad, RAW_DISPLAY or RAW_HALFSIZE, RAW_DISPLAY));

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
  RawBitmap : TFreeWinBitmap;
  MemIO: TFreeMemoryIO;
  Data: PByte;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    if Stream is TMemoryStream then
    begin
      Data := TMemoryStream(Stream).Memory;
      MemIO := TFreeMemoryIO.Create(Data, Stream.Size);
      try
        if FIsPreview then
          RawBitmap.LoadFromMemory(MemIO, RAW_PREVIEW)
        else
          RawBitmap.LoadFromMemory(MemIO, IIF(FHalfSizeLoad, RAW_DISPLAY or RAW_HALFSIZE, RAW_DISPLAY));
      finally
        F(MemIO);
      end;
    end else
    begin
      if FIsPreview then
        RawBitmap.LoadFromStream(Stream, RAW_PREVIEW)
      else
        RawBitmap.LoadFromStream(Stream, IIF(FHalfSizeLoad, RAW_DISPLAY or RAW_HALFSIZE, RAW_DISPLAY));
    end;
    FWidth := RawBitmap.GetWidth;
    FHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);

    if FIsPreview then
    begin
      RawBitmap.Clear;
      Stream.Seek(0, soFromBeginning);
      if Stream is TMemoryStream then
        RawBitmap.LoadFromMemoryStream(TMemoryStream(Stream), FIF_LOAD_NOPIXELS)
      else
        RawBitmap.LoadFromStream(Stream, FIF_LOAD_NOPIXELS);

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
