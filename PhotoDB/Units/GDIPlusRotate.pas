unit GDIPlusRotate;
{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses Windows, Classes, SysUtils, UTime, ActiveX, uFileUtils, uTranslate, ExplorerTypes;

type
{$EXTERNALSYM EncoderValue}
  EncoderValue = (EncoderValueColorTypeCMYK, EncoderValueColorTypeYCCK, EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3, EncoderValueCompressionCCITT4, EncoderValueCompressionRle,
    EncoderValueCompressionNone, EncoderValueScanMethodInterlaced, EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87, EncoderValueVersionGif89, EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive, EncoderValueTransformRotate90, EncoderValueTransformRotate180,
    EncoderValueTransformRotate270, EncoderValueTransformFlipHorizontal, EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame, EncoderValueLastFrame, EncoderValueFlush, EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution, EncoderValueFrameDimensionPage);
  TEncoderValue = EncoderValue;

const
  WINGDIPDLL = 'gdiplus.dll';

type
{$EXTERNALSYM Status}
  Status = (Ok, GenericError, InvalidParameter, OutOfMemory, ObjectBusy, InsufficientBuffer, NotImplemented,
    Win32Error, WrongState, Aborted, FileNotFound, ValueOverflow, AccessDenied, UnknownImageFormat,
    FontFamilyNotFound, FontStyleNotFound, NotTrueTypeFont, UnsupportedGdiplusVersion, GdiplusNotInitialized,
    PropertyNotFound, PropertyNotSupported);
  TStatus = Status;

  GpStatus = TStatus;

  GpImage = Pointer;

  // ---------------------------------------------------------------------------
  // Encoder Parameter structure
  // ---------------------------------------------------------------------------
{$EXTERNALSYM EncoderParameter}

  EncoderParameter = packed record
    Guid: TGUID; // GUID of the parameter
    NumberOfValues: ULONG; // Number of the parameter values
    Type_: ULONG; // Value type, like ValueTypeLONG  etc.
    Value: Pointer; // A pointer to the parameter values
  end;

  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

  // ---------------------------------------------------------------------------
  // Encoder Parameters structure
  // ---------------------------------------------------------------------------
{$EXTERNALSYM EncoderParameters}

  EncoderParameters = packed record
    Count: UINT; // Number of parameters in this structure
    Parameter: array [0 .. 0] of TEncoderParameter; // Parameter values
  end;

  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;

  // --------------------------------------------------------------------------
  // ImageCodecInfo structure
  // --------------------------------------------------------------------------
{$EXTERNALSYM ImageCodecInfo}

  ImageCodecInfo = packed record
    Clsid: TGUID;
    FormatID: TGUID;
    CodecName: PWCHAR;
    DllName: PWCHAR;
    FormatDescription: PWCHAR;
    FilenameExtension: PWCHAR;
    MimeType: PWCHAR;
    Flags: DWORD;
    Version: DWORD;
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PBYTE;
    SigMask: PBYTE;
  end;

  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;

const
  EncoderTransformation: TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  EncoderParameterValueTypeLong: Integer = 4; // 32-bit unsigned int

type
{$EXTERNALSYM NotificationHookProc}
  NotificationHookProc = function(out Token: ULONG): Status; stdcall;
{$EXTERNALSYM NotificationUnhookProc}
  NotificationUnhookProc = procedure(Token: ULONG); stdcall;
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

    NotificationHook: NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;

  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

type
{$EXTERNALSYM DebugEventLevel}
  DebugEventLevel = (DebugEventLevelFatal, DebugEventLevelWarning);
  TDebugEventLevel = DebugEventLevel;
{$EXTERNALSYM DebugEventProc}
  DebugEventProc = procedure(Level: DebugEventLevel; message: PChar); stdcall;
{$EXTERNALSYM GdiplusStartupInput}

  GdiplusStartupInput = packed record
    GdiplusVersion: Cardinal; // Must be 1
    DebugEventCallback: DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL; // FALSE unless you're prepared to call
    // the hook/unhook functions properly
    SuppressExternalCodecs: BOOL; // FALSE unless you want GDI+ only to use
  end;
  // its internal image codecs.
  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

var

  StartupInput: TGDIPlusStartupInput;
  GdiplusToken: ULONG;
  GDIPlusLib: THandle = 0;
  GDIPlusPresent: Boolean = False;

type
  TGdipLoadImageFromStream = function(Stream: ISTREAM; out image: GPIMAGE): GPSTATUS; stdcall;

  TGdipLoadImageFromFile = function(Filename: PWCHAR; out Image: GPIMAGE): GPSTATUS; stdcall;
  // external WINGDIPDLL name 'GdipLoadImageFromFile';

  TGdipGetImageEncodersSize = function(out NumEncoders: UINT; out Size: UINT): GPSTATUS; stdcall;
  // external WINGDIPDLL name 'GdipGetImageEncodersSize';

  TGdipGetImageEncoders = function(NumEncoders: UINT; Size: UINT; Encoders: PIMAGECODECINFO): GPSTATUS; stdcall;
  // external WINGDIPDLL name 'GdipGetImageEncoders';

  TGdipSaveImageToFile = function(Image: GPIMAGE; Filename: PWCHAR; ClsidEncoder: PGUID;
    EncoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall; // external WINGDIPDLL name 'GdipSaveImageToFile';

  TGdipSaveImageToStream = function (image: GPIMAGE; stream: ISTREAM;
    clsidEncoder: PGUID; encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;

  TGdipDisposeImage = function(Image: GPIMAGE): GPSTATUS; stdcall; // external WINGDIPDLL name 'GdipDisposeImage';

  TGdiplusStartup = function(out Token: ULONG; Input: PGdiplusStartupInput; Output: PGdiplusStartupOutput): Status;
    stdcall; // external WINGDIPDLL name 'GdiplusStartup';

  TGdiplusShutdown = procedure(Token: ULONG); stdcall; // external WINGDIPDLL name 'GdiplusShutdown';

var
  GdipLoadImageFromFile: TGdipLoadImageFromFile;
  GdipLoadImageFromStream: TGdipLoadImageFromStream;
  GdipGetImageEncodersSize: TGdipGetImageEncodersSize;
  GdipGetImageEncoders: TGdipGetImageEncoders;
  GdipSaveImageToFile: TGdipSaveImageToFile;
  GdipSaveImageToStream: TGdipSaveImageToStream;
  GdipDisposeImage: TGdipDisposeImage;
  GdiplusStartup: TGdiplusStartup;
  GdiplusShutdown: TGdiplusShutdown;

procedure InitGDIPlus;
procedure RotateGDIPlusJPEGFile(AFileName: string; Encode: TEncoderValue; OtherFile: string = '');
function AGetTempFileName(FileName: string): string;
procedure RotateGDIPlusJPEGStream(Src : TStream; Dst: TStream; Encode: TEncoderValue);

implementation

function AGetTempFileName(FileName: string): string;
begin
  Result := FileName + '$temp$.$$$';
end;

function GetImageEncodersSize(out NumEncoders, Size: UINT): TStatus;
begin
  Result := GdipGetImageEncodersSize(NumEncoders, Size);
end;

function GetImageEncoders(NumEncoders, Size: UINT; Encoders: PImageCodecInfo): TStatus;
begin
  Result := GdipGetImageEncoders(NumEncoders, Size, Encoders);
end;

function GetEncoderClsid(Format: string; out PClsid: TGUID): Integer;
var
  Num, Size, J: UINT;
  ImageCodecInfo: PImageCodecInfo;
type
  ArrIMgInf = array of TImageCodecInfo;
begin
  Num := 0; // number of image encoders
  Size := 0; // size of the image encoder array in bytes
  Result := -1;
  GetImageEncodersSize(Num, Size);
  if (Size = 0) then
    Exit;
  GetMem(ImageCodecInfo, Size);
  if (ImageCodecInfo = nil) then
    Exit;
  GetImageEncoders(Num, Size, ImageCodecInfo);
  for J := 0 to Num - 1 do
  begin
    if (ArrIMgInf(ImageCodecInfo)[J].MimeType = Format) then
    begin
      PClsid := ArrIMgInf(ImageCodecInfo)[J].Clsid;
      Result := J; // Success
    end;
  end;
  FreeMem(ImageCodecInfo, Size);
end;

{
procedure SavetoFile(aFile: string;Bitmap: tbitmap);
var
 imgFile          : GPIMAGE;
 mem              : TMemoryStream;
 aptr             : IStream;
 encoderClsid     : TGUID;
 input: TGdiplusStartupInput;
 token: dword;
begin
 mem     := TMemoryStream.Create;
 Bitmap.SaveToStream(mem);
 mem.Seek(0, soFromBeginning);
 aptr    := TStreamAdapter.Create(mem, soReference) as IStream;
 imgFile := nil;
 FillChar(input, SizeOf(input), 0);
 input.GdiplusVersion := 1;
 GdiplusStartup(token, @input, nil);
 GdipLoadImageFromStream(aptr, imgFile);
 GetEncoderClsid('image/jpeg', encoderClsid);
 GdipSaveImageToFile(imgFile, pwchar(aFile), @encoderClsid, nil);
 GdiplusShutdown(token);
 aptr := nil;
 mem.Free;
end;
}

procedure RotateGDIPlusJPEGStream(Src : TStream; Dst: TStream; Encode: TEncoderValue);
var
  AdapterS, AdapterD : IStream;
  NativeImage: GpImage;
  CLSID: TGUID;
  EV: TEncoderValue;
  PIP: PEncoderParameters;
  EncoderParameters: TEncoderParameters;
begin;
  Src.Seek(0, soFromBeginning);
  AdapterS := TStreamAdapter.Create(Src, soReference) as IStream;
  try
    GdipLoadImageFromStream(AdapterS, NativeImage);
    try
      AdapterD := TStreamAdapter.Create(Dst, soReference) as IStream;
      try

        GetEncoderClsid('image/jpeg', Clsid);
        EncoderParameters.Count := 1;
        EncoderParameters.Parameter[0].Guid := EncoderTransformation;
        EncoderParameters.Parameter[0].Type_ := EncoderParameterValueTypeLong;
        EncoderParameters.Parameter[0].NumberOfValues := 1;
        EV := Encode;
        EncoderParameters.Parameter[0].Value := @EV;
        PIP := @EncoderParameters;

        GdipSaveImageToStream(NativeImage, AdapterD, @Clsid, PIP);
      finally
        AdapterD := nil;
      end;
    finally
      GdipDisposeImage(NativeImage);
    end;
  finally
    AdapterS := nil;
  end;

end;

procedure RotateGDIPlusJPEGFile(AFileName: string; Encode: TEncoderValue; OtherFile: string = '');
var
  CLSID: TGUID;
  EncoderParameters: TEncoderParameters;
  EV: TEncoderValue;
  PIP: PEncoderParameters;
  NativeImage: GpImage;
  FileName, FileNameTemp: WideString;
  UseOtherFile: Boolean;
begin
  Filename := AFileName;
  NativeImage := nil;
  GdipLoadImageFromFile(PWideChar(FileName), NativeImage);

  GetEncoderClsid('image/jpeg', Clsid);
  EncoderParameters.Count := 1;
  EncoderParameters.Parameter[0].Guid := EncoderTransformation;
  EncoderParameters.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  EncoderParameters.Parameter[0].NumberOfValues := 1;
  EV := Encode;
  EncoderParameters.Parameter[0].Value := @EV;
  PIP := @EncoderParameters;

  UseOtherFile := AnsiLowerCase(FileName) <> AnsiLowerCase(AFileName);
  if not UseOtherFile then
  begin
    FileNameTemp := AGetTempFileName(FileName);
    TLockFiles.Instance.AddLockedFile(FileNameTemp, 5000);
    try
      if Ok <> GdipSaveImageToFile(NativeImage, PWideChar(FileNameTemp), @Clsid, PIP) then
        raise Exception.Create(Format(TA('Can''t write to file %s!'), [FileNameTemp]));
    finally
      GdipDisposeImage(NativeImage);
      DeleteFile(PWideChar(AFileName));
      RenameFile(FileNameTemp, AFileName);
    end;
  end else
  begin
    if FileExists(OtherFile) then
      uFileUtils.SilentDeleteFile(0, PWideChar(OtherFile), True, True);
    FileNameTemp := OtherFile;
    try
      if Ok <> GdipSaveImageToFile(NativeImage, PWideChar(FileNameTemp), @Clsid, PIP) then
        raise Exception.Create(Format(TA('Can''t write to file %s!'), [FileNameTemp]));
    finally
      GdipDisposeImage(NativeImage);
    end;
  end;
end;

procedure InitGDIPlus;
begin
  TW.I.Start('WINGDIPDLL');
  if GDIPlusLib = 0 then
  begin
    if AnsiUpperCase(ParamStr(1)) <> '/SAFEMODE' then
      if AnsiUpperCase(ParamStr(1)) <> '/UNINSTALL' then
        GDIPlusLib := LoadLibrary(WINGDIPDLL);
    if GDIPlusLib <> 0 then
    begin
      GDIPlusPresent := True;
      GdipLoadImageFromFile := GetProcAddress(GDIPlusLib, 'GdipLoadImageFromFile');
      GdipLoadImageFromStream := GetProcAddress(GDIPlusLib, 'GdipLoadImageFromStream');
      GdipGetImageEncodersSize := GetProcAddress(GDIPlusLib, 'GdipGetImageEncodersSize');
      GdipGetImageEncoders := GetProcAddress(GDIPlusLib, 'GdipGetImageEncoders');
      GdipSaveImageToFile := GetProcAddress(GDIPlusLib, 'GdipSaveImageToFile');
      GdipSaveImageToStream := GetProcAddress(GDIPlusLib, 'GdipSaveImageToStream');
      GdipDisposeImage := GetProcAddress(GDIPlusLib, 'GdipDisposeImage');
      GdiplusStartup := GetProcAddress(GDIPlusLib, 'GdiplusStartup');
      GdiplusShutdown := GetProcAddress(GDIPlusLib, 'GdiplusShutdown');
      // Initialize StartupInput structure
      StartupInput.DebugEventCallback := nil;
      StartupInput.SuppressBackgroundThread := False;
      StartupInput.SuppressExternalCodecs := False;
      StartupInput.GdiplusVersion := 1;
      // Initialize GDI+
      GdiplusStartup(GdiplusToken, @StartupInput, nil);
    end else
    begin
      GDIPlusPresent := False;
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
    GdiplusShutdown(GdiplusToken);
    FreeLibrary(GDIPlusLib);
  end;
end;

end.
