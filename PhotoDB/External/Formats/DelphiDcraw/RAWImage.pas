unit RAWImage;

interface

uses  Windows, Messages, SysUtils, Graphics, Classes, FileCtrl, GraphicEX, Forms,
      UnitScripts, UnitDBCommonGraphics;

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
  public
    constructor Create; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromFile(const Filename: string); override;
    function LoadThumbnailFromFile(const FileName : string) : boolean;
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

var
  IsRAWSupport : boolean = false;

implementation

Uses
  Global_FastIO
  {$IFDEF USEPHOTODB}
  ,Dolphin_DB
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
 if DecodingCount=1 then
 Repeat
  sleep(10);
//  Application.ProcessMessages;
 until DecodingCount<1;
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
  fLoadHalfSize:=true;
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
Var
  ScanLines:ALines;
  X:Integer;
  IWidth:LongInt;
  IHeight:LongInt;
  PMake:Array[0..1000] Of Char;
  PModel:Array[0..1000] Of Char;
  PTimeStamp:Array[0..1000] Of Char;
  IFileName:PChar;
  ThumbFileName:PChar;
  Status:Integer;
  IShrink:Integer;
  FilePtrs:TRawFilePointers;
  MyStream:TRawFileStream;
  StreamIn:TFastFile;
  ExifRecord:TExifRecord;
  ExifEssentials:TExifEssentials;
  ProgressInfo:TProgress;
  RAWSettings:TRAWSettings;
  ErrorVal:Integer;
  
{  _RAWInfo : TRAWInfo;
  _FromRawToPSD : TFromRawToPSD;
  RAWDllNewHandle : THandle; }
begin
if DecodingCount=1 then
 Repeat
  sleep(10);
//  Application.ProcessMessages;
 until DecodingCount<1;
 inc(DecodingCount);

{  RAWDllNewHandle:=LoadLibrary(PHOTOJOCKEYdll);
  _FromRawToPSD := GetProcAddress(RAWDllNewHandle,'FromRawToPSD');
  _RAWInfo := GetProcAddress(RAWDllNewHandle,'RawInfo');
   }
GetMem(ThumbFileName,255);
IFileName:=PChar(FileName);
raw_settings_init(RAWSettings);
RAWSettings.iGamma_Val:=0.6;
RAWSettings.iBright:=1;
RAWSettings.iScale1:=0;
RAWSettings.iScale2:=0;
RAWSettings.iScale3:=0;
RAWSettings.iScale4:=0;
RAWSettings.iBlack_Level:=-1;

RAWSettings.IFour_Color_RGB:=0;
RAWSettings.IQuality:=1;
if fLoadHalfSize then
RAWSettings.IShrink:=1 else RAWSettings.IShrink:=0;
RAWSettings.IUse_Auto_WB:=0;
RAWSettings.IUse_Camera_WB:=1;
RAWSettings.IRAWColors:=0;

RAWSettings.IHighLight:=0;
RAWSettings.IRGB_Colors:=1;
IShrink:=RAWSettings.IShrink;

raw_fileio_init_Pointers(FilePtrs);
raw_fileio_init_stream(MyStream);
StreamIn:=TFastFile.Create(IFileName,fmOpenRead,ErrorVal);
StreamIn.Position:=0;
MyStream.FFile:=StreamIn;
FilePtrs.IFile:=@MyStream;
raw_exif_init(ExifRecord);
try
Status:=RAWInfo(@FilePtrs,
                @ExifRecord,
                @ExifEssentials,
                IFileName,
                IShrink,
                IWidth,IHeight,
                @PMake,
                @PModel,
                @PTimeStamp);
except
 Status:=-1;
end;
If Status=0 Then
   Begin

   Width:=IWidth;
   fWidth:=IWidth;
   PixelFormat:=pf24bit;
   Height:=IHeight;
   fHeight:=IHeight;
   For X:=0 To fHeight-1 Do
       ScanLines[X]:=Scanline[X];
   MyStream.FFile.Position:=0;
   raw_exif_init(ExifRecord);

   raw_progress_init(ProgressInfo,nil);
   ProgressInfo.Progress:=nil;//@RawProgress;
   ProgressInfo.Context:=nil;//Self;                          @ProgressInfo
   try
   Status:=FromRawToPSD(@FilePtrs,@ExifRecord,@ExifEssentials,nil,IFileName,ThumbFileName,RAWSettings,ScanLines,IWidth,IHeight,PMake,PModel,PTimeStamp);
   except
    Status:=-1;
   end;
   If Status=0 Then
      Begin
        //All OK
      End
   Else
      Begin
       
       StreamIn.Free;
       FreeMem(ThumbFileName);
       dec(DecodingCount); 
//       FreeLibrary(RAWDllNewHandle);

       If Status=7 Then
        raise Exception.Create('LOADING WAS ABORTED!') else
        raise Exception.Create('Error in decoding RAW image');
       exit;
      End;
   End
Else
  Begin   
   StreamIn.Free;
   FreeMem(ThumbFileName);
   dec(DecodingCount);
//   FreeLibrary(RAWDllNewHandle);
   raise Exception.Create('Error in decoding RAW image');
   exit;
  End;

  StreamIn.Free;
  FreeMem(ThumbFileName);
//  FreeLibrary(RAWDllNewHandle);
  dec(DecodingCount);
end;

procedure TRAWImage.LoadFromStream(Stream: TStream);
var
  TempName : String;
  FS : TFileStream;
begin
  {$IFDEF USEPHOTODB}

 TempName:=GetAppDataDirectory+TempFolder+GetCID+'.raw';
 CreateDir(GetAppDataDirectory+TempFolder);
 try
  FS:=TFileStream.Create(TempName,fmOpenWrite or fmCreate);
 except
  exit;
 end;
 Stream.Seek(0,soFromBeginning);
 FS.CopyFrom(Stream,Stream.Size);
 FS.Free;
 LoadFromFile(TempName);
 try
  DeleteFile(TempName);
 except
 end;
  {$ENDIF}
end;

function TRAWImage.LoadThumbnailFromFile(const FileName: string): boolean;
var
  PMake:Array[0..1000] Of Char;
  PModel:Array[0..1000] Of Char;
  ThumbName:Array[0..1000] Of Char;
  IFileName:PChar;
  FilePtrs:TRawFilePointers;
  MyStream:TRawFileStream;
  StreamIn:TFastFile;
  Dummy:Integer;
  ExifRecord:TExifRecord;
  IShrink:Integer;
  Status:Integer;
  ExifEssentials:TExifEssentials;
  IWidth:LongInt;
  IHeight:LongInt;
  PTimeStamp:Array[0..1000] Of Char;
  ThumbNailType:Integer;  
  ImageTmp:TPicture;   
  OldThumbName:String;
  NewThumbName:String;
  TempBitmap : TBitmap;

begin

if DecodingCount=1 then
 Repeat
  sleep(10);
 until DecodingCount<1;
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

 if fLoadHalfSize then
  IShrink:=1 else IShrink:=0;

 Status:=RawInfo(@FilePtrs,@ExifRecord,@ExifEssentials,IFileName,IShrink,IWidth,IHeight,@PMake,@PModel,@PTimeStamp);
 StreamIn.Free;

 If Status=0 Then
 Begin
  try
   ThumbNailType:=100;

   StrCopy(ThumbName,PChar(GetAppDataDirectory+TempFolder+GetCID+'.thumb'));
   raw_fileio_init_Pointers(FilePtrs);
   
   Status:=Extract_Thumbnail(Self,@FilePtrs,IFileName,ThumbName,ThumbnailType);
   Width:=IWidth;
   fWidth:=IWidth;
   PixelFormat:=pf24bit;
   Height:=IHeight;
   fHeight:=IHeight;
  except
    on EZeroDivide do Begin
                    End;
    on EDivByZero do Begin
                    End;
  end;

  Case Status Of
    0:
    Begin
      DeleteFile(ThumbName);
    End;
   -1: //thumbnail is corrupted
    Begin
    End;
    1:
    Begin


      Case ThumbNailType Of
        RAW_THUMB_BAD:
        Begin
          DeleteFile(ThumbName);
        End;
       RAW_THUMB_NOTAVAIL:
       Begin
          DeleteFile(ThumbName);
       End;
       RAW_THUMB_JPG:
       Begin
         OldThumbName:=ThumbName;
         NewThumbName:=ThumbName+'.jpg';
         FileSetAttr(NewThumbName,0);
         DeleteFile(NewThumbName);
         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
       End;
       RAW_THUMB_PPM:
       Begin
         OldThumbName:=ThumbName;
         NewThumbName:=ThumbName+'.ppm';
         FileSetAttr(NewThumbName,0);
         DeleteFile(NewThumbName);
         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
       End;
       RAW_THUMB_TIFF:
       Begin
         OldThumbName:=ThumbName;
         NewThumbName:=ThumbName+'.tiff';
         FileSetAttr(NewThumbName,0);
         DeleteFile(NewThumbName);
         RenameFile(PChar(OldThumbName),PChar(NewThumbName));
       End;
     End;

     Case ThumbNailType Of
           RAW_THUMB_JPG,
           RAW_THUMB_PPM,
           RAW_THUMB_TIFF:
           Begin
             ImageTmp:=TPicture.Create;
             ImageTmp.LoadFromFile(NewThumbName);
             if ThumbNailType=RAW_THUMB_JPG then
             JPEGScale(ImageTmp.Graphic,550,550);
             inherited Assign(ImageTmp.Graphic);
             ImageTmp.Free;
             TempBitmap:=Self as TBitmap;
             case ExifEssentials.Rotation of
                90  :  Rotate90A(TempBitmap);
                180 :  Rotate180A(TempBitmap);
                270 :  Rotate270A(TempBitmap);
             end;
             DeleteFile(NewThumbName);
             Result:=True; 
             dec(DecodingCount);
             exit;
           End;
     end;
   end;
  end;
 end;       
 dec(DecodingCount);
 Result:=false;
end;

procedure TRAWImage.SetLoadHalfSize(const Value: boolean);
begin
  fLoadHalfSize := Value;
end;

initialization

 RAWImages:='';
 aRAWModuleHandle:=0;
 If AnsiUpperCase(paramStr(1))<>'/SAFEMODE' then
 If AnsiUpperCase(paramStr(1))<>'/UNINSTALL' then
 aRAWModuleHandle:=LoadLibrary(PHOTOJOCKEYdll);
 if aRAWModuleHandle<>0 then
 begin
  IsRAWSupport:=true;
  aFromRawToPSD := GetProcAddress(aRAWModuleHandle,'FromRawToPSD');
  aRAWInfo := GetProcAddress(aRAWModuleHandle,'RawInfo');
  aExtract_Thumbnail := GetProcAddress(aRAWModuleHandle,'ExtractThumbnail');

  //Loading Extensions from ini-file
  InitializeScript(aScript);
  LoadBaseFunctions(aScript);
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
  if RAWImages='' then
  RAWImages:='CR2|';
  TempRAWMask:=TempRAWMask+RAWImages;
  SupportedExt:=SupportedExt+RAWImages;

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
