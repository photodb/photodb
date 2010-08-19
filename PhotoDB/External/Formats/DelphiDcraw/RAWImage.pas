unit RAWImage;

interface

uses  Windows, Messages, SysUtils, Graphics, Classes, FileCtrl, GraphicEX, Forms,
      uScript, UnitScripts, UnitDBCommonGraphics, uConstants, uFileUtils, uTime,
      FreeBitmap, FreeImage, GraphicsBaseTypes;

  {$DEFINE USEPHOTODB}

type

  TRAWImage = class(TBitmap)
  protected
    fWidth : integer;
    fHeight : integer;
    fLoadHalfSize: boolean;
    function GetWidth : integer; override;
    function GetHeight : integer; override;
  private
    procedure SetLoadHalfSize(const Value: boolean);
    procedure LoadFromFreeImage(Image : TFreeBitmap);
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromFile(const Filename: string); override;
    function LoadThumbnailFromFile(const FileName : string; Width, Height : Integer) : boolean;
    procedure Assign(Source : TPersistent); override;
    property LoadHalfSize : boolean read FLoadHalfSize write SetLoadHalfSize;
  end;
       
  TRAWExifRecord = class(TObject)
  private        
    FDescription : string;
    FKey : string;
    FValue : string;
  public
    property Key : string read FKey write FKey;
    property Value : string read FValue write FValue;  
    property Description : string read FDescription write FDescription;
  end;

  TRAWExif = class(TObject)
  private
    FExifList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TRAWExifRecord;
    function GetTimeStamp: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Description, Key, Value : string) : TRAWExifRecord;
    function IsEXIF : Boolean;
    property TimeStamp : TDateTime read GetTimeStamp;
    property Count : Integer read GetCount;
    property Items[Index: Integer]: TRAWExifRecord read GetValueByIndex; default;
  end;

  function IsRAWImageFile(FileName : String) : Boolean;
  function ReadRAWExif(FileName : String) : TRAWExif;

var
  IsRAWSupport : Boolean = True;

implementation

uses
  {$IFDEF USEPHOTODB}
  Dolphin_DB, UnitDBCommon
  {$ENDIF}
  ;

var
  aScript : TScript;  
  LoadScript : string;    
  LoadInteger : integer;
  aFS : TFileStream;
  _i : integer;
  _s : string;
  _p : integer;
    
const
  RAW_DISPLAY = 2;
  RAW_PREVIEW = 1;

{ TRAWImage }

function ReadRAWExif(FileName : String) : TRAWExif;
var
  RawBitmap : TFreeWinBitmap;
  TagNext: TFreeTag;
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
        Result.Add(Description, Key, Value)
      else
        Result.Add(Key, Key, Value);
    end;
  end;
begin
  Result := TRAWExif.Create;

  TagData := nil;
  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadU(Filename, RAW_PREVIEW);
    for I := FIMD_NODATA to FIMD_CUSTOM do
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
    RawBitmap.Free;
  end;
end;

function IsRAWImageFile(FileName : String) : boolean;
begin
 Result := ExtInMask('|'+RAWImages,GetExt(FileName));
end;

procedure TRAWImage.Assign(Source: TPersistent);
begin
  if Source is TRAWImage then
  begin
    //for crypting - loading private variables width and height
    FWidth := (Source as TRAWImage).FWidth;
    FHeight := (Source as TRAWImage).FHeight;
    fLoadHalfSize:=(Source as TRAWImage).FLoadHalfSize;
  end;
  inherited Assign(Source);
end;

constructor TRAWImage.Create;
begin
  inherited;
  fLoadHalfSize := False;
end;

function TRAWImage.GetHeight: integer;
begin
  if fLoadHalfSize then
    Result := fHeight * 2
  else
    Result := fHeight;
end;

function TRAWImage.GetWidth: integer;
begin             
  if fLoadHalfSize then
    Result := fWidth * 2
  else
    Result := fWidth;
end;

procedure TRAWImage.LoadFromFile(const Filename: string);
var
  RawBitmap : TFreeWinBitmap;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadU(Filename, RAW_PREVIEW);
    RawBitmap.ConvertTo24Bits;
    fWidth := RawBitmap.GetWidth;
    fHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);
  finally
    RawBitmap.Free;
  end;
end;

procedure TRAWImage.LoadFromStream(Stream: TStream);
var
  RawBitmap : TFreeWinBitmap;
begin
  RawBitmap := TFreeWinBitmap.Create;
  try
    //TODO: FLoadHalfSize param
    RawBitmap.LoadFromStream(Stream, RAW_PREVIEW);
    RawBitmap.ConvertTo24Bits;
    fWidth := RawBitmap.GetWidth;
    fHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);
  finally
    RawBitmap.Free;
  end;
end;

procedure TRAWImage.LoadFromFreeImage(Image: TFreeBitmap);
var
  I, J : Integer;
  PS, PD : PARGB;
  W, H : integer;
begin
  PixelFormat := pf24Bit;
  W := Image.GetWidth;
  H := Image.GetHeight;
  Width := W;
  Height := H;

  for I := 0 to H - 1 do
  begin
    PS := PARGB(Image.GetScanLine(H - I - 1));
    PD := ScanLine[I];
    for J := 0 to W - 1 do
      PD[J] := PS[J];
  end;
end;

function TRAWImage.LoadThumbnailFromFile(const FileName: string; Width, Height : Integer): boolean;
var
  RawBitmap : TFreeWinBitmap;
  RawThumb : TFreeWinBitmap;
  W, H : Integer;
begin
  Result := True;
  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadU(Filename, RAW_PREVIEW);
    RawThumb := TFreeWinBitmap.Create;
    try           
      fWidth := RawBitmap.GetWidth;
      fHeight := RawBitmap.GetHeight;
      W := fWidth;
      H := fHeight;
      ProportionalSize(Width, Height, W, H);
      RawBitmap.MakeThumbnail(W, H, RawThumb);
      LoadFromFreeImage(RawThumb);
    finally
      RawThumb.Free;
    end;
  finally
    RawBitmap.Free;
  end;
end;

procedure TRAWImage.SetLoadHalfSize(const Value: boolean);
begin
  fLoadHalfSize := Value;
end;

function aSetString(S : String) : String;
begin
 Result := S;
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
var
  I : Integer;
begin
  for I := 0 to FExifList.Count - 1 do
    TRAWExifRecord(FExifList[I]).Free;
  FExifList.Free;
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

  TW.I.Start('InitRAW');
  RAWImages := '';
  if (AnsiUpperCase(paramStr(1))<>'/SAFEMODE') and (AnsiUpperCase(paramStr(1))<>'/UNINSTALL') then
  begin
    //Loading Extensions from ini-file
    aScript := TScript.Create('InitRAW');
    try
      AddScriptFunction(aScript.Enviroment, 'String', F_TYPE_FUNCTION_STRING_IS_STRING, @aSetString);
      LoadScript := '';
      aFS := TFileStream.Create(ProgramDir+'scripts\LoadRAW.dbini',fmOpenRead);
      try
        SetLength(LoadScript, aFS.Size);
        aFS.Read(LoadScript[1], aFS.Size);
        LoadScript := StringReplace(LoadScript, #13#10, '  ', [rfReplaceAll]);
      finally
        aFS.Free;
      end;
    ExecuteScript(nil, aScript, LoadScript, LoadInteger, nil);
    RAWImages := GetNamedValueString(aScript, '$RAWImages');
  finally
    aScript.Free;
  end;
  if RAWImages = '' then
    RAWImages := 'CR2|';
  TempRAWMask := TempRAWMask + RAWImages;
  SupportedExt := SupportedExt + RAWImages;

  TW.I.Start('RAW - RegisterFileFormat');
  _p := 1; //first -  NOT "|"
  for _i := 1 to Length(RAWImages) do
  begin
    if RAWImages[_i]= '|' then
    begin
      _s := Copy(RAWImages, _p, _i - _p);
      TPicture.RegisterFileFormat(AnsiLowerCase(_s), 'Camera RAW format', TRAWImage);
      _p := _i + 1;
    end;
  end;
  end else
    IsRAWSupport := False;

finalization

  if IsRAWSupport then
    TPicture.UnregisterGraphicClass(TRAWImage);

end.
