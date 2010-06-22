unit GDIPlusRotate;

{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses Windows, SysUtils, uTime;

type

  {$EXTERNALSYM EncoderValue}
  EncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3,
    EncoderValueCompressionCCITT4,
    EncoderValueCompressionRle,
    EncoderValueCompressionNone,
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,
    EncoderValueTransformRotate180,
    EncoderValueTransformRotate270,
    EncoderValueTransformFlipHorizontal,
    EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame,
    EncoderValueLastFrame,
    EncoderValueFlush,
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage
  );
  TEncoderValue = EncoderValue;

const WINGDIPDLL = 'gdiplus.dll';

type
  {$EXTERNALSYM Status}
  Status = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );
  TStatus = Status;

  GpStatus          = TStatus;

  GpImage = Pointer;

//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------

  {$EXTERNALSYM EncoderParameter}
  EncoderParameter = packed record
    Guid           : TGUID;   // GUID of the parameter
    NumberOfValues : ULONG;   // Number of the parameter values
    Type_          : ULONG;   // Value type, like ValueTypeLONG  etc.
    Value          : Pointer; // A pointer to the parameter values
  end;
  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------

  {$EXTERNALSYM EncoderParameters}
  EncoderParameters = packed record
    Count     : UINT;               // Number of parameters in this structure
    Parameter : array[0..0] of TEncoderParameter;  // Parameter values
  end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;

//--------------------------------------------------------------------------
// ImageCodecInfo structure
//--------------------------------------------------------------------------

  {$EXTERNALSYM ImageCodecInfo}
  ImageCodecInfo = packed record
    Clsid             : TGUID;
    FormatID          : TGUID;
    CodecName         : PWCHAR;
    DllName           : PWCHAR;
    FormatDescription : PWCHAR;
    FilenameExtension : PWCHAR;
    MimeType          : PWCHAR;
    Flags             : DWORD;
    Version           : DWORD;
    SigCount          : DWORD;
    SigSize           : DWORD;
    SigPattern        : PBYTE;
    SigMask           : PBYTE;
  end;
  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;

  const EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  EncoderParameterValueTypeLong          : Integer = 4;    // 32-bit unsigned int

type

  {$EXTERNALSYM NotificationHookProc}
  NotificationHookProc = function(out token: ULONG): Status; stdcall;
  {$EXTERNALSYM NotificationUnhookProc}
  NotificationUnhookProc = procedure(token: ULONG); stdcall;

  {$EXTERNALSYM GdiplusStartupOutput}
  GdiplusStartupOutput = packed record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.

    NotificationHook  : NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;
  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;



type
  {$EXTERNALSYM DebugEventLevel}
  DebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );
  TDebugEventLevel = DebugEventLevel;
  {$EXTERNALSYM DebugEventProc}
  DebugEventProc = procedure(level: DebugEventLevel; message: PChar); stdcall;
  {$EXTERNALSYM GdiplusStartupInput}
  GdiplusStartupInput = packed record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;                                        // its internal image codecs.
  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

  var

   StartupInput: TGDIPlusStartupInput;
   gdiplusToken: ULONG;
   GDIPlusLib : THandle = 0;
   GDIPlusPresent : Boolean = False;


type
TGdipLoadImageFromFile = function (filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;// external WINGDIPDLL name 'GdipLoadImageFromFile';

TGdipGetImageEncodersSize = function(out numEncoders: UINT;
    out size: UINT): GPSTATUS; stdcall; //external WINGDIPDLL name 'GdipGetImageEncodersSize';

TGdipGetImageEncoders = function(numEncoders: UINT; size: UINT;
    encoders: PIMAGECODECINFO): GPSTATUS; stdcall; //external WINGDIPDLL name 'GdipGetImageEncoders';

TGdipSaveImageToFile =function(image: GPIMAGE;
  filename: PWCHAR;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;// external WINGDIPDLL name 'GdipSaveImageToFile';

TGdipDisposeImage = function(image: GPIMAGE): GPSTATUS; stdcall; //external WINGDIPDLL name 'GdipDisposeImage';

TGdiplusStartup = function(out token: ULONG; input: PGdiplusStartupInput;
   output: PGdiplusStartupOutput): Status; stdcall; //external WINGDIPDLL name 'GdiplusStartup';

TGdiplusShutdown = procedure(token: ULONG); stdcall; //external WINGDIPDLL name 'GdiplusShutdown';

var
  GdipLoadImageFromFile : TGdipLoadImageFromFile;
  GdipGetImageEncodersSize : TGdipGetImageEncodersSize;
  GdipGetImageEncoders : TGdipGetImageEncoders;
  GdipSaveImageToFile : TGdipSaveImageToFile;
  GdipDisposeImage : TGdipDisposeImage;
  GdiplusStartup : TGdiplusStartup;
  GdiplusShutdown  : TGdiplusShutdown;

procedure RotateGDIPlusJPEGFile(aFileName : String; Encode : TEncoderValue; UseOtherFile : Boolean = false; OtherFile : String = '');
function aGetTempFileName(FileName : String) : String; 
procedure InitGDIPlus;

implementation

  function aGetTempFileName(FileName : String) : String;
  begin
   Result:=FileName+'$temp$.$$$';
  end;

  function GetImageEncodersSize(out numEncoders, size: UINT): TStatus;
  begin
    result := GdipGetImageEncodersSize(numEncoders, size);
  end;

    function GetImageEncoders(numEncoders, size: UINT;
     encoders: PImageCodecInfo): TStatus;
  begin
    result := GdipGetImageEncoders(numEncoders, size, encoders);
  end;

function GetEncoderClsid(format: String; out pClsid: TGUID): integer;
var
  num, size, j: UINT;
  ImageCodecInfo: PImageCodecInfo;
Type
  ArrIMgInf = array of TImageCodecInfo;
begin
  num  := 0; // number of image encoders
  size := 0; // size of the image encoder array in bytes
  result := -1;
  GetImageEncodersSize(num, size);
  if (size = 0) then exit;
  GetMem(ImageCodecInfo, size);
  if(ImageCodecInfo = nil) then exit;
  GetImageEncoders(num, size, ImageCodecInfo);
  for j := 0 to num - 1 do
  begin
    if( ArrIMgInf(ImageCodecInfo)[j].MimeType = format) then
    begin
      pClsid := ArrIMgInf(ImageCodecInfo)[j].Clsid;
      result := j;  // Success
    end;
  end;
  FreeMem(ImageCodecInfo, size);
end;

Procedure RotateGDIPlusJPEGFile(aFileName : String; Encode : TEncoderValue; UseOtherFile : Boolean = false; OtherFile : String = '');
var
  CLSID : TGUID;
  EncoderParameters : TEncoderParameters;
  EV : TEncoderValue;
  PIP : PEncoderParameters;
  nativeImage: GpImage;
  FileName, FileNameTemp: WideString;
begin
 filename:=aFileName;
 nativeImage:=nil;
 GdipLoadImageFromFile(PWideChar(FileName),nativeImage);
 GetEncoderClsid('image/jpeg', clsid);
 EncoderParameters.Count:=1;
 EncoderParameters.Parameter[0].Guid := EncoderTransformation;
 EncoderParameters.Parameter[0].Type_ := EncoderParameterValueTypeLong;
 EncoderParameters.Parameter[0].NumberOfValues := 1;
 EV:= Encode;
 EncoderParameters.Parameter[0].Value:=@EV;
 PIP:=@EncoderParameters;
 if not UseOtherFile then
 begin
  FileNameTemp:=aGetTempFileName(FileName);
  GdipSaveImageToFile(nativeImage,PWideChar(FileNameTemp),@clsid,PIP);
  GdipDisposeImage(nativeImage);
  DeleteFile(PChar(aFileName));
  RenameFile(FileNameTemp,aFileName);
 end else
 begin
  If FileExists(OtherFile) then
  DeleteFile(PChar(OtherFile));
  FileNameTemp:=OtherFile;
  GdipSaveImageToFile(nativeImage,PWideChar(FileNameTemp),@clsid,PIP);
  GdipDisposeImage(nativeImage);
 end;
end;

procedure InitGDIPlus;
begin         
 TW.I.Start('WINGDIPDLL');
  if GDIPlusLib = 0 then
  begin
 If AnsiUpperCase(paramStr(1))<>'/SAFEMODE' then
   If AnsiUpperCase(paramStr(1))<>'/UNINSTALL' then
   GDIPlusLib:=LoadLibrary(WINGDIPDLL);
   if GDIPlusLib<>0 then
   begin
    GDIPlusPresent:=true;
    GdipLoadImageFromFile := GetProcAddress(GDIPlusLib,'GdipLoadImageFromFile');
    GdipGetImageEncodersSize := GetProcAddress(GDIPlusLib,'GdipGetImageEncodersSize');
    GdipGetImageEncoders := GetProcAddress(GDIPlusLib,'GdipGetImageEncoders');
    GdipSaveImageToFile := GetProcAddress(GDIPlusLib,'GdipSaveImageToFile');
    GdipDisposeImage := GetProcAddress(GDIPlusLib,'GdipDisposeImage');
    GdiplusStartup := GetProcAddress(GDIPlusLib,'GdiplusStartup');
    GdiplusShutdown  := GetProcAddress(GDIPlusLib,'GdiplusShutdown');
    // Initialize StartupInput structure
    StartupInput.DebugEventCallback := nil;
    StartupInput.SuppressBackgroundThread := False;
    StartupInput.SuppressExternalCodecs   := False;
    StartupInput.GdiplusVersion := 1;
    // Initialize GDI+
    GdiplusStartup(gdiplusToken, @StartupInput, nil);
   end else
   begin
    GDIPlusPresent:=false;
   end;    
   TW.I.Start('WINGDIPDLL - END');
  end;
end;

initialization

finalization
begin
  // Close GDI +
  if GDIPlusPresent then
  begin
   GdiplusShutdown(gdiplusToken);
   FreeLibrary(GDIPlusLib);
  end;
end;


end.
