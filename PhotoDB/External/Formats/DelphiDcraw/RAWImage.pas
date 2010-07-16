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
    Property LoadHalfSize : boolean read fLoadHalfSize write SetLoadHalfSize;
  end;

type
TExifEssentials=Packed Record
         ISO_Speed:Integer;
         Shutter_Speed:Single;
         Aperture:Single;
         Focal_Length:Single;
         IsFoveon:Byte;
         Rotation:Integer;
         End;
PExifEssentials=^TExifEssentials;

  TExifRAWRecord = record
         ISO_Speed:Integer;
         Shutter_Speed:Single;
         Aperture:Single;
         Focal_Length:Single;
         IsFoveon:Byte;
         Rotation:Integer;
         Width :Integer;
         Height :Integer;
         CameraModel :String;
         TimeStamp :String;
         isEXIF : boolean;
         end;

Function IsRAWImageFile(FileName : String) : boolean;
Function ReadRAWExif(FileName : String) : TExifRAWRecord;    
procedure InitRAW;

var
  IsRAWSupport : boolean = true;

implementation

Uses
  Global_FastIO
  {$IFDEF USEPHOTODB}
  ,Dolphin_DB, UnitDBCommon
  {$ENDIF}
  ;

Type
  PPChar=^PChar;
  PLine=Pointer;
  ALines=Array[0..20000] Of PLine;
  PLongInt=^LongInt;

var
  DecodingCount : integer = 0;  
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

{$I CSTDIO.PAS}

{ TRAWImage }

Function ReadRAWExif(FileName : String) : TExifRAWRecord;
var
  PMake:Array[0..1000] Of Char;
  PModel:Array[0..1000] Of Char;
  IFileName:PChar;
  FilePtrs:TRawFilePointers;
  MyStream:TRawFileStream;
  StreamIn:TFastFile;
  Dummy:Integer;
  ExifRecord:TExifRecord;   
  IShrink:Integer;   
  ExifEssentials:TExifEssentials;
  IWidth:LongInt;
  IHeight:LongInt;   
  PTimeStamp:Array[0..1000] Of Char;
  i : integer;
begin


 InitRAW;
 while DecodingCount > 0 do
  sleep(10);
 inc(DecodingCount);

  FillChar(PMake,1000,1);
  FillChar(PModel,1000,2);

  IFileName:=PChar(FileName);

  raw_fileio_init_Pointers(FilePtrs);
  raw_fileio_init_stream(MyStream);
  Try
   StreamIn:=TFastFile.Create(IFileName,0,Dummy);
  Except
  End;
  MyStream.FFile:=StreamIn;
  FilePtrs.IFile:=@MyStream;
  raw_exif_init(ExifRecord);

  IShrink:=0;

  try
   Result.isEXIF:=0=RawInfo(@FilePtrs,@ExifRecord,@ExifEssentials,IFileName,IShrink,IWidth,IHeight,@PMake,@PModel,@PTimeStamp);
  except
   StreamIn.Free;
   dec(DecodingCount);
   Result.isEXIF:=false;
   exit;
  end;
  Result.ISO_Speed:=ExifEssentials.ISO_Speed;
  if ExifEssentials.Shutter_Speed=0 then Result.Shutter_Speed:=-1;
  Result.Shutter_Speed:=Round(1/ExifEssentials.Shutter_Speed);
  Result.Aperture:=ExifEssentials.Aperture;
  Result.Focal_Length:=ExifEssentials.Focal_Length;
  Result.IsFoveon:=ExifEssentials.IsFoveon;
  Result.Rotation:=ExifEssentials.Rotation;
  Result.Width:=IWidth;
  Result.Height:=IHeight;


  Result.CameraModel:='';
  for i:=0 to 999 do
  if PModel[i]<>#0 then Result.CameraModel:=Result.CameraModel+PModel[i] else break;

  Result.TimeStamp:='';
  for i:=0 to 999 do
  if PTimeStamp[i]<>#0 then Result.TimeStamp:=Result.TimeStamp+PTimeStamp[i] else break;

   dec(DecodingCount);
end;

Function IsRAWImageFile(FileName : String) : boolean;
begin
 Result := ExtInMask('|'+RAWImages,GetExt(FileName));
end;

Function RValue(Text:String):Single;
Var
  Code:Integer;
  Y:Single;
Begin
Val(Text,Y,Code);
Result:=Y;
End;

procedure TRAWImage.Assign(Source: TPersistent);
begin
 if Source = nil then
 begin
  inherited Assign(Source);
  exit;
 end;
 if Source is TRAWImage then
 begin
  //for crypting - loading private variables width and height 
  fWidth:=(Source as TRAWImage).fWidth;
  fHeight:=(Source as TRAWImage).fHeight;
  fLoadHalfSize:=(Source as TRAWImage).fLoadHalfSize;
  inherited Assign(Source);
 end else
 begin
  inherited Assign(Source);
 end;
end;

constructor TRAWImage.Create;
begin
  inherited;
  fLoadHalfSize:=False;
end;

function TRAWImage.GetHeight: integer;
begin
 if fLoadHalfSize then
 Result:=fHeight*2 else Result:=fHeight;
end;

function TRAWImage.GetWidth: integer;
begin             
 if fLoadHalfSize then
 Result:=fWidth*2 else Result:=fWidth;
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
  FS : TFileStream;
  RawBitmap : TFreeWinBitmap;
begin
  {$IFDEF USEPHOTODB}
  RawBitmap := TFreeWinBitmap.Create;
  try
    RawBitmap.LoadFromStream(Stream, RAW_PREVIEW);
    RawBitmap.ConvertTo24Bits;
    fWidth := RawBitmap.GetWidth;
    fHeight := RawBitmap.GetHeight;
    LoadFromFreeImage(RawBitmap);
  finally
    RawBitmap.Free;
  end;
  {$ENDIF}
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
    begin
      PD[J].R := PS[J].R;
      PD[J].G := PS[J].G;
      PD[J].B := PS[J].B;
    end;
  end;
end;

function TRAWImage.LoadThumbnailFromFile(const FileName: string; Width, Height : Integer): boolean;
var
  RawBitmap : TFreeWinBitmap;
  RawThumb : TFreeWinBitmap;
  W, H : Integer;
begin
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

procedure InitRAW;
begin
  if aRAWModuleHandle = 0 then
  begin
    aRAWModuleHandle:=LoadLibrary(PHOTOJOCKEYdll);
    if aRAWModuleHandle<>0 then
    begin
      aFromRawToPSD := GetProcAddress(aRAWModuleHandle,'FromRawToPSD');
      aRAWInfo := GetProcAddress(aRAWModuleHandle,'RawInfo');
      aExtract_Thumbnail := GetProcAddress(aRAWModuleHandle,'ExtractThumbnail');
    end;
  end;
end;

function aSetString(S : String) : String;
begin
 Result := S;
end;

initialization

 TW.I.Start('InitRAW');
 RAWImages:='';
 aRAWModuleHandle:=0;
 If AnsiUpperCase(paramStr(1))<>'/SAFEMODE' then
 If AnsiUpperCase(paramStr(1))<>'/UNINSTALL' then
 begin
  //Loading Extensions from ini-file
  aScript := TScript.Create('InitRAW');
  try
    AddScriptFunction(aScript.Enviroment,'String',F_TYPE_FUNCTION_STRING_IS_STRING,@aSetString);
    LoadScript:='';
    try
     aFS := TFileStream.Create(ProgramDir+'scripts\LoadRAW.dbini',fmOpenRead);
     SetLength(LoadScript,aFS.Size);
     aFS.Read(LoadScript[1],aFS.Size);
     for LoadInteger:=Length(LoadScript) downto 1 do
     begin
      if LoadScript[LoadInteger]=#10 then LoadScript[LoadInteger]:=' ';
      if LoadScript[LoadInteger]=#13 then LoadScript[LoadInteger]:=' ';
     end;
     aFS.Free;
    except
    end;
    try
     ExecuteScript(nil,aScript,LoadScript,LoadInteger,nil);
    except
    end;
    RAWImages:=GetNamedValueString(aScript,'$RAWImages');
  finally
    aScript.Free;
  end;
  if RAWImages='' then
  RAWImages:='CR2|';
  TempRAWMask:=TempRAWMask+RAWImages;
  SupportedExt:=SupportedExt+RAWImages;

 TW.I.Start('RAW - RegisterFileFormat');
  _p:=1; //first -  NOT "|"
  for _i:=1 to Length(RAWImages) do
  begin
   if RAWImages[_i]='|' then
   begin
    _s:=Copy(RAWImages,_p,_i-_p);
    TPicture.RegisterFileFormat(AnsiLowerCase(_s),'Camera RAW format',TRAWImage);
    _p:=_i+1;
   end;

  end;

 end else
 begin
  IsRAWSupport:=false;
 end;

finalization

if IsRAWSupport then
TPicture.UnregisterGraphicClass(TRAWImage);

end.
