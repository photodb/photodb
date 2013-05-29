unit uExifUtils;

interface

uses
  System.Classes,
  System.DateUtils,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,

  Dmitry.Utils.System,

  CCR.Exif,
  CCR.Exif.TiffUtils,
  CCR.Exif.XMPUtils,

  GraphicEx,
  GraphicCrypt,
  UnitDBDeclare,

  uMemory,
  uErrors,
  uConstants,
  uTiffImage,
  uRAWImage,
  uAnimatedJPEG,
  uSettings,
  uAssociations,
  uDBContext,
  uLogger,
  uPortableDeviceUtils,
  uTranslate,
  uDBEntities,
  uSessionPasswords;

const
  TAG_IMAGE_WIDTH					        = $0100;
  TAG_IMAGE_HEIGHT				        = $0101;
  TAG_BITS_PER_SAMPLE				      = $0102;
  TAG_COMPRESSION						      = $0103;
  TAG_PHOTOMETRIC_INTERPRETATION	= $0106;
  TAG_ORIENTATION						      = $0112;
  TAG_SAMPLES_PER_PIXEL			      = $0115;
  TAG_PLANAR_CONFIGURATION		    = $011C;
  TAG_YCBCR_SUBSAMPLING				    = $0212;
  TAG_YCBCR_POSITIONING				    = $0213;
  TAG_X_RESOLUTION						    = $011A;
  TAG_Y_RESOLUTION						    = $011B;
  TAG_RESOLUTION_UNIT					    = $0128;

// Tag relating to image data characteristics

  TAG_COLOR_SPACE                 =	$A001;

// Tags relating to image configuration

  TAG_COMPONENTS_CONFIGURATION	=	$9101;
  TAG_COMPRESSED_BITS_PER_PIXEL	=	$9102;
  TAG_PIXEL_X_DIMENSION			    =	$A002;
  TAG_PIXEL_Y_DIMENSION		    	=	$A003;


// Tags relating to picture-taking conditions

  TAG_EXPOSURE_TIME						    = $829A;
  TAG_FNUMBER									    = $829D;
  TAG_EXPOSURE_PROGRAM				    = $8822;
  TAG_SPECTRAL_SENSITIVITY		    = $8824;
  TAG_ISO_SPEED_RATINGS 			    = $8827;
  TAG_OECF										    = $8828;
  TAG_SHUTTER_SPEED_VALUE 		    = $9201;
  TAG_APERTURE_VALUE 					    = $9202;
  TAG_BRIGHTNESS_VALUE				    = $9203;
  TAG_EXPOSURE_BIAS_VALUE 		    = $9204;
  TAG_MAX_APERTURE_VALUE 			    = $9205;
  TAG_SUBJECT_DISTANCE				    = $9206;
  TAG_METERING_MODE						    = $9207;
  TAG_LIGHT_SOURCE						    = $9208;
  TAG_FLASH										    = $9209;
  TAG_FOCAL_LENGTH						    = $920A;
  TAG_SUBJECT_AREA						    = $9214;
  TAG_FLASH_ENERGY						    = $A20B;
  TAG_SPATIAL_FREQ_RESPONSE 		  = $A20C;
  TAG_FOCAL_PLANE_X_RES				    = $A20E;
  TAG_FOCAL_PLANE_Y_RES				    = $A20F;
  TAG_FOCAL_PLANE_UNIT				    = $A210;
  TAG_SUBJECT_LOCATION 				    = $A214;
  TAG_EXPOSURE_INDEX					    = $A215;
  TAG_SENSING_METHOD					    = $A217;
  TAG_FILE_SOURCE							    = $A300;
  TAG_SCENE_TYPE							    = $A301;
  TAG_CFA_PATTERN							    = $A302;
  TAG_CUSTOM_RENDERED					    = $A401;
  TAG_EXPOSURE_MODE						    = $A402;
  TAG_WHITE_BALANCE						    = $A403;
  TAG_DIGITAL_ZOOM_RATIO			    = $A404;
  TAG_FOCAL_LENGTH_IN_35MM_FILM	  = $A405;
  TAG_SCENE_CAPTURE_TYPE			    = $A406;
  TAG_GAIN_CONTROL			          = $A407;
  TAG_CONTRAST					          = $A408;
  TAG_SATURATION				          = $A409;
  TAG_SHARPNESS					          = $A40A;
  TAG_DEVICE_SETTING_DESCRIPTION	= $A40B;
  TAG_SUBJECT_DISTANCE_RANGE		  = $A40C;

// Tags relating to user information

  TAG_MARKER_NOTE	    = $927C;
  TAG_USER_COMMENT  	= $9286;

// LibTIF compression modes

  TAG_COMPRESSION_NONE            = 1;	{ dump mode }
  TAG_COMPRESSION_CCITTRLE        = 2;	{ CCITT modified Huffman RLE }
  TAG_COMPRESSION_CCITTFAX3	      = 3;	{ CCITT Group 3 fax encoding }
  TAG_COMPRESSION_CCITT_T4        = 3;       { CCITT T.4 (TIFF 6 name) }
  TAG_COMPRESSION_CCITTFAX4	      = 4;	{ CCITT Group 4 fax encoding }
  TAG_COMPRESSION_CCITT_T6        = 4;       { CCITT T.6 (TIFF 6 name) }
  TAG_COMPRESSION_LZW             = 5;       { Lempel-Ziv  & Welch }
  TAG_COMPRESSION_OJPEG           = 6;	{ !6.0 JPEG }
  TAG_COMPRESSION_JPEG            = 7;	{ %JPEG DCT compression }
  TAG_COMPRESSION_NEXT            = 32766;	{ NeXT 2-bit RLE }
  TAG_COMPRESSION_CCITTRLEW       = 32771;	{ #1 w/ word alignment }
  TAG_COMPRESSION_PACKBITS        = 32773;	{ Macintosh RLE }
  TAG_COMPRESSION_THUNDERSCAN     = 32809;	{ ThunderScan RLE }
{ codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@apago.com) }
  TAG_COMPRESSION_IT8CTPAD        = 32895;   { IT8 CT w/padding }
  TAG_COMPRESSION_IT8LW           = 32896;   { IT8 Linework RLE }
  TAG_COMPRESSION_IT8MP           = 32897;   { IT8 Monochrome picture }
  TAG_COMPRESSION_IT8BL           = 32898;   { IT8 Binary line art }
{ compression codes 32908-32911 are reserved for Pixar }
  TAG_COMPRESSION_PIXARFILM       = 32908;   { Pixar companded 10bit LZW }
  TAG_COMPRESSION_PIXARLOG        = 32909;   { Pixar companded 11bit ZIP }
  TAG_COMPRESSION_DEFLATE         = 32946;	{ Deflate compression }
  TAG_COMPRESSION_ADOBE_DEFLATE   = 8;       { Deflate compression,
						   as recognized by Adobe }
{ compression code 32947 is reserved for Oceana Matrix <dev@oceana.com> }
  TAG_COMPRESSION_DCS             = 32947;   { Kodak DCS encoding }
  TAG_COMPRESSION_JBIG          	= 34661;	{ ISO JBIG }
  TAG_COMPRESSION_SGILOG          = 34676;	{ SGI Log Luminance RLE }
  TAG_COMPRESSION_SGILOG24        = 34677;	{ SGI Log 24-bit packed }
  TAG_COMPRESSION_JP2000          = 34712;   { Leadtools JPEG2000 }
  TAG_COMPRESSION_LZMA            = 34925;	{ LZMA2 }

// ----------------------------------------------------------
// GPS Attribute Information
// ----------------------------------------------------------

  TAG_GPS_VERSION_ID         = $0000;
  TAG_GPS_LATITUDE_REF       = $0001;
  TAG_GPS_LATITUDE           = $0002;
  TAG_GPS_LONGITUDE_REF		   = $0003;
  TAG_GPS_LONGITUDE          = $0004;
  TAG_GPS_ALTITUDE_REF		   = $0005;
  TAG_GPS_ALTITUDE           = $0006;
  TAG_GPS_TIME_STAMP         = $0007;
  TAG_GPS_SATELLITES         = $0008;
  TAG_GPS_STATUS             = $0009;
  TAG_GPS_MEASURE_MODE		   = $000A;
  TAG_GPS_DOP                = $000B;
  TAG_GPS_SPEED_REF          = $000C;
  TAG_GPS_SPEED              = $000D;
  TAG_GPS_TRACK_REF          = $000E;
  TAG_GPS_TRACK              = $000F;
  TAG_GPS_IMG_DIRECTION_REF  = $0010;
  TAG_GPS_IMG_DIRECTION      = $0011;
  TAG_GPS_MAP_DATUM          = $0012;
  TAG_GPS_DEST_LATITUDE_REF  = $0013;
  TAG_GPS_DEST_LATITUDE		   = $0014;
  TAG_GPS_DEST_LONGITUDE_REF = $0015;
  TAG_GPS_DEST_LONGITUDE     = $0016;
  TAG_GPS_DEST_BEARING_REF   = $0017;
  TAG_GPS_DEST_BEARING       = $0018;
  TAG_GPS_DEST_DISTANCE_REF	 = $0019;
  TAG_GPS_DEST_DISTANCE		   = $001A;
  TAG_GPS_PROCESSING_METHOD	 = $001B;
  TAG_GPS_AREA_INFORMATION   = $001C;
  TAG_GPS_DATE_STAMP         = $001D;
  TAG_GPS_DIFFERENTIAL       = $001E;

type
  TExifPatchInfo = class
  public
    ID: Integer;
    Params: TEventFields;
    Value: TEventValues;
    Context: IDBContext;
  end;

type
  DBXMPPacket = class helper for TXMPPacket
  private
    function GetGroups: string;
    procedure SetGroups(const Value: string);
    function GetLinks: string;
    procedure SetLinks(const Value: string);
    function GetAccess: Integer;
    procedure SetAccess(const Value: Integer);
    function GetInclude: Boolean;
    procedure SetInclude(const Value: Boolean);
    function GetLens: string;
  published
    function ReadString(Name: string; NS: TXMPKnownNamespace = xsXMPBasic): string;
    procedure WriteString(Name, Value: string);
    function ReadInteger(Name: string): Integer;
    procedure WriteInteger(Name: string; Value: Integer);
    function ReadBool(Name: string; DefaultValue: Boolean): Boolean;
    procedure WriteBool(Name: string; Value: Boolean);
    procedure UpdateXML;
  published
    property Groups: string read GetGroups write SetGroups;
    property Links: string read GetLinks write SetLinks;
    property Access: Integer read GetAccess write SetAccess;
    property Include: Boolean read GetInclude write SetInclude;
    property Lens: string read GetLens;
  end;

  TExifDataHelper = class helper for TExifData
  public
    function LoadFromFileEx(FileName: string; ThrowOnError: Boolean = True): Boolean;
    procedure SaveToFileEx(FileName: string);
  end;

  TExifDataEx = class(TExifData);

function ExifOrientationToRatation(Orientation: Integer): Integer;
function GetExifRating(FileName: string): Integer; overload;
function GetExifRating(ExifData: TExifData): Integer; overload;
function GetExifRotate(FileName: string): Integer;
function UpdateImageRecordFromExif(Info: TMediaItem; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
function UpdateImageRecordFromExifData(Info: TMediaItem; ExifData: TExifData; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
function UpdateFileExif(FileName: string; Info: TExifPatchInfo): Boolean; overload;
function UpdateFileExif(Info: TMediaItem): Boolean; overload;
function CreateRating(Rating: Integer): TWindowsStarRating;
function CreateOrientation(Rotation: Integer): TExifOrientation;
function IsTheSameOrientation(Or1, Or2: TExifOrientation): Boolean;
function CanSaveEXIF(FileName: string): Boolean;
function UpdateFileGeoInfo(FileName: string; GeoInfo: TGeoLocation; RaiseException: Boolean = False): Boolean;
function DeleteFileGeoInfo(FileName: string; RaiseException: Boolean = False): Boolean;
function UpdateImageGeoInfoFromExif(Info: TMediaItem; ExifData: TExifData): Boolean;
function UpdateImageGeoInfo(Info: TMediaItem): Boolean;
procedure FixJpegStreamEXIF(Stream: TStream; Width, Height: Integer);
procedure FixEXIFForJpegStream(Exif: TExifData; Stream: TStream; Width, Height: Integer);
function EXIFDateToDate(DateTime: string): TDateTime;
function EXIFDateToTime(DateTime: string): TDateTime;

implementation

procedure FixEXIFForJpegStream(Exif: TExifData; Stream: TStream; Width, Height: Integer);
var
  Jpeg: TJpegImage;
begin
  Exif.BeginUpdate;
  try
    Exif.Orientation := toTopLeft;
    Exif.ExifImageWidth := Width;
    Exif.ExifImageHeight := Height;
    Exif.Thumbnail := nil;
    Stream.Seek(0, soFromBeginning);
    Jpeg := TJpegImage.Create;
    try
      Jpeg.LoadFromStream(Stream);
      Exif.SaveToGraphic(Jpeg);
      Stream.Size := 0;
      Jpeg.SaveToStream(Stream);
    finally
      F(Jpeg);
    end;
  finally
    Exif.EndUpdate;
  end;
end;

procedure FixJpegStreamEXIF(Stream: TStream; Width, Height: Integer);
var
  ExifData: TExifData;
begin
  ExifData := TExifData.Create;
  try
    Stream.Seek(0, soFromBeginning);
    ExifData.LoadFromGraphic(Stream);
    FixEXIFForJpegStream(ExifData, Stream, Width, Height);
  except
    on e: Exception do
      EventLog(e.Message);
  end;
  F(ExifData);
end;

function CanSaveEXIF(FileName: string): Boolean;
var
  GraphicClass: TGraphicClass;
begin
  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if (GraphicClass = Vcl.Imaging.Jpeg.TJPEGImage)
    or (GraphicClass = TAnimatedJPEG)
    or (GraphicClass = TTiffImage)
    or (GraphicClass = GraphicEx.TPSDGraphic)
    then
      Result := True
  else
    Result := False;
end;

function GeoLocationToDouble(Location: TGPSCoordinate): Double;
begin
  Result := (Location.Degrees.Quotient) + (Location.Minutes.Quotient) / 60 + (Location.Seconds.Quotient) / 3600;
  if (Location.Direction = 'S') or (Location.Direction = 'W') then
    Result := -Result;
end;

function UpdateImageGeoInfoFromExif(Info: TMediaItem; ExifData: TExifData): Boolean;
begin
  Result := False;

  if not AppSettings.Exif.ReadInfoFromExif then
    Exit;

  if not ExifData.Empty then
  begin
    if (ExifData.GPSLatitude <> nil) and (ExifData.GPSLongitude <> nil) and not ExifData.GPSLatitude.MissingOrInvalid and not ExifData.GPSLongitude.MissingOrInvalid then
      Info.LoadGeoInfo(GeoLocationToDouble(ExifData.GPSLatitude), GeoLocationToDouble(ExifData.GPSLongitude));
    Result := True;
  end;
end;

function UpdateImageGeoInfo(Info: TMediaItem): Boolean;
var
  ExifData: TExifData;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := False;

    if not AppSettings.Exif.ReadInfoFromExif then
      Exit;

    try
      ExifData := TExifData.Create;
      try
        if ExifData.LoadFromFileEx(Info.FileName, False) then
          Result := UpdateImageGeoInfoFromExif(Info, ExifData);
      finally
        F(ExifData);
      end;

    except
      on e: Exception do
      begin
        EventLog(e);
        Result := False;
      end;
    end;

  finally
    SetErrorMode(OldMode);
  end;
end;

function CanReadExifInfo(Info: TMediaItem): Boolean;
begin
  Result := False;

  if IsDevicePath(Info.FileName) then
    Exit;

  if (Info.Rating > 0) and (Info.Rotation <> DB_IMAGE_ROTATE_0) then
    Exit; //nothing to update

  if not AppSettings.Exif.ReadInfoFromExif then
    Exit;

  Result := True;
end;

function UpdateImageRecordFromExifData(Info: TMediaItem; ExifData: TExifData; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
var
  Rating, Rotation: Integer;
begin
  Result := False;

  if not CanReadExifInfo(Info) then
    Exit;

  if not ExifData.Empty then
  begin
    Result := True;

    if Info.Rating <= 0 then
    begin
      Rating := GetExifRating(ExifData);
      if IsDBValues then
        Info.Rating := Rating
      else
        Info.Rating := - 10 * Rating;
    end;

    if (Info.Rotation = DB_IMAGE_ROTATE_0) or (Info.Rotation = -1) then
    begin
      Rotation := ExifOrientationToRatation(Integer(ExifData.Orientation));
      if IsDBValues then
        Info.Rotation := Rotation
      else
        Info.Rotation := - 10 * Rotation;
    end;

    if Info.KeyWords = '' then
      Info.KeyWords := ExifData.Keywords;

    if Info.Comment = '' then
      Info.Comment := ExifData.Comments;

    if LoadGroups then
      Info.Groups := ExifData.XMPPacket.Groups;

    if Info.Links = '' then
      Info.Links := ExifData.XMPPacket.Links;

    if Info.Access = 0 then
    begin
      if IsDBValues then
        Info.Access := ExifData.XMPPacket.Access
      else
        Info.Access := -10 * ExifData.XMPPacket.Access;
    end;

    if Info.Include then
      Info.Include := ExifData.XMPPacket.Include;

    if (ExifData.GPSLatitude <> nil) and (ExifData.GPSLongitude <> nil) and not ExifData.GPSLatitude.MissingOrInvalid and not ExifData.GPSLongitude.MissingOrInvalid then
      Info.LoadGeoInfo(GeoLocationToDouble(ExifData.GPSLatitude), GeoLocationToDouble(ExifData.GPSLongitude));
  end;
end;

function UpdateImageRecordFromExif(Info: TMediaItem; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
var
  ExifData: TExifData;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := False;

    if not CanReadExifInfo(Info) then
      Exit;

    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromFileEx(Info.FileName);

        UpdateImageRecordFromExifData(Info, ExifData);
      finally
        F(ExifData);
      end;
    except
      Result := False;
    end;
    Result := True;
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetFileDate(FileName: string): Integer;
var
  FH: THandle;
begin
  Result := 0;
  FH := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
  try
    if FH > 0 then
      Result := FileGetDate(FH);
  finally
    FileClose(FH);
  end;
end;

function UpdateFileExif(Info: TMediaItem): Boolean;
var
  ExifData: TExifData;
  Changed: Boolean;
  OldMode: Cardinal;
  FD: Integer;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if not CanSaveEXIF(Info.FileName) then
      Exit;
    Changed := False;
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(Info.FileName);
        try
          ExifData.XMPPacket.SchemaCount;
        except
          ExifData.XMPPacket.Clear;
        end;

        ExifData.XMPWritePolicy := xwAlwaysUpdate;
        if (Info.Rating > 0) then
        begin
          if ExifData.UserRating <> CreateRating(Info.Rating) then
          begin
            ExifData.UserRating := CreateRating(Info.Rating);
            Changed := True;
          end;
        end;
        if Info.Rotation <> DB_IMAGE_ROTATE_0 then
        begin
          if ExifData.Orientation <> CreateOrientation(Info.Rotation) then
          begin
            ExifData.Orientation := CreateOrientation(Info.Rotation);
            Changed := True;
          end;
        end;

        if ExifData.Keywords <> Trim(Info.KeyWords) then
        begin
          ExifData.Keywords := Trim(Info.KeyWords);
          Changed := True;
        end;

        if Info.Comment <> '' then
        begin
          if ExifData.Comments <> Info.Comment then
          begin
            ExifData.Comments := Info.Comment;
            Changed := True;
          end;
        end;

        if ExifData.XMPPacket.Groups <> Info.Groups then
        begin
          ExifData.XMPPacket.Groups := Info.Groups;
          Changed := True;
        end;

        if ExifData.XMPPacket.Links <> Info.Links then
        begin
          ExifData.XMPPacket.Links := Info.Links;
          Changed := True;
        end;

        if ExifData.XMPPacket.Links <> Info.Links then
        begin
          ExifData.XMPPacket.Links := Info.Links;
          Changed := True;
        end;

        if ExifData.XMPPacket.Access <> Info.Access then
        begin
          ExifData.XMPPacket.Access := Info.Access;
          Changed := True;
        end;

        if ExifData.XMPPacket.Include <> Info.Include then
        begin
          ExifData.XMPPacket.Include := Info.Include;
          Changed := True;
        end;

        if Changed then
        begin
          ExifData.XMPPacket.UpdateXML;

          FD := GetFileDate(Info.FileName);
          ExifData.SaveToGraphic(Info.FileName);
          if FD > 0 then
            FileSetDate(Info.FileName, FD);
        end;
      finally
        F(ExifData);
      end;
      Result := True;
    except
      Result := False;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function UpdateFileExif(FileName: string; Info: TExifPatchInfo): Boolean;
var
  ExifData: TExifData;
  Changed: Boolean;
  OldMode: Cardinal;
  FD: Integer;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Changed := False;
    if not CanSaveEXIF(FileName) then
      Exit;
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(FileName);
        try
          ExifData.XMPPacket.SchemaCount;
        except
          ExifData.XMPPacket.Clear;
        end;

        ExifData.XMPWritePolicy := xwAlwaysUpdate;

        if [EventID_Param_Rating, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.UserRating <> CreateRating(Info.Value.Rating) then
          begin
            ExifData.UserRating := CreateRating(Info.Value.Rating);
            Changed := True;
          end;
        end;

        if [EventID_Param_Rotate, SetNewIDFileData] * Info.Params <> [] then
        begin
          if not IsTheSameOrientation(ExifData.Orientation, CreateOrientation(Info.Value.Rotation)) then
          begin
            ExifData.Orientation := CreateOrientation(Info.Value.Rotation);
            Changed := True;
          end;
        end;

        if [EventID_Param_KeyWords, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.Keywords <> Trim(Info.Value.KeyWords) then
          begin
            ExifData.Keywords := Trim(Info.Value.KeyWords);
            Changed := True;
          end;
        end;

        if [EventID_Param_Comment, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.Comments <> Info.Value.Comment then
          begin
            ExifData.Comments := Info.Value.Comment;
            Changed := True;
          end;
        end;

        if [EventID_Param_Groups, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.XMPPacket.Groups <> Info.Value.Groups then
          begin
            ExifData.XMPPacket.Groups := Info.Value.Groups;
            Changed := True;
          end;
        end;

        if [EventID_Param_Links, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.XMPPacket.Links <> Info.Value.Links then
          begin
            ExifData.XMPPacket.Links := Info.Value.Links;
            Changed := True;
          end;
        end;

        if [EventID_Param_Access, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.XMPPacket.Access <> Info.Value.Access then
          begin
            ExifData.XMPPacket.Access := Info.Value.Access;
            Changed := True;
          end;
        end;

        if [EventID_Param_Include, SetNewIDFileData] * Info.Params <> [] then
        begin
          if ExifData.XMPPacket.Include <> Info.Value.Include then
          begin
            ExifData.XMPPacket.Include := Info.Value.Include;
            Changed := True;
          end;
        end;

        if Changed then
        begin
          ExifData.XMPPacket.UpdateXML;

          FD := GetFileDate(FileName);
          ExifData.SaveToGraphic(FileName);
          if FD > 0 then
            FileSetDate(FileName, FD);
        end;
      finally
        F(ExifData);
      end;
      Result := True;
    except
      Result := False;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function IsTheSameOrientation(Or1, Or2: TExifOrientation): Boolean;
begin
  if Or1 = toUndefined then
   Or1 := toTopLeft;
  if Or2 = toUndefined then
   Or2 := toTopLeft;

   Result := Or1 = Or2;
end;

function CreateOrientation(Rotation: Integer): TExifOrientation;
begin
  Result := toTopLeft;
  case Rotation of
    DB_IMAGE_ROTATE_180:
      Result := toBottomRight;
    DB_IMAGE_ROTATE_90:
      Result := toLeftTop;
    DB_IMAGE_ROTATE_270:
      Result := toRightBottom;
  end;
end;

function ExifOrientationToRatation(Orientation: Integer): Integer;
const
  Orientations : array[1..9] of Integer = (
  DB_IMAGE_ROTATE_0,
  DB_IMAGE_ROTATE_0,
  DB_IMAGE_ROTATE_180,
  DB_IMAGE_ROTATE_180,
  DB_IMAGE_ROTATE_90,
  DB_IMAGE_ROTATE_90,
  DB_IMAGE_ROTATE_270,
  DB_IMAGE_ROTATE_270,
  DB_IMAGE_ROTATE_0);

begin
  if Orientation in [1..9] then
    Result := Orientations[Orientation]
  else
    Result := 0;
end;

function GetExifRotate(FileName: string): Integer;
var
  ExifData: TExifData;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DB_IMAGE_ROTATE_0;
    try
      if IsRAWSupport and IsRAWImageFile(FileName) then
      begin
        //image will be rotated at load;
        Exit;
      end else
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromGraphic(FileName);
          if not ExifData.Empty then
            Result := ExifOrientationToRatation(Ord(ExifData.Orientation));
        finally
          F(ExifData);
        end;
      end;

    except
      Exit;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function CreateRating(Rating: Integer): TWindowsStarRating;
begin
  Result := urUndefined;
  case Rating of
    1:
      Result := urOneStar;
    2:
      Result := urTwoStars;
    3:
      Result := urThreeStars;
    4:
      Result := urFourStars;
    5:
      Result := urFiveStars;
  end;
end;

function GetExifRating(ExifData: TExifData): Integer;
begin
  Result := 0;
  if not ExifData.Empty then
    case ExifData.UserRating of
      urOneStar:
        Result := 1;
      urTwoStars:
        Result := 2;
      urThreeStars:
        Result := 3;
      urFourStars:
        Result := 4;
      urFiveStars:
        Result := 5;
    end;
end;

function GetExifRating(FileName: string): Integer;
var
  ExifData: TExifData;
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(FileName);
        Result := GetExifRating(ExifData);
      finally
        F(ExifData);
      end;
    except
      Result := 0;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function DeleteFileGeoInfo(FileName: string; RaiseException: Boolean = False): Boolean;
var
  ExifData: TExifData;
  OldMode: Cardinal;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromFileEx(FileName);

        if not ExifData.Empty then
        begin
          ExifData.GPSLongitude.Assign(0, 0, 0, lnMissingOrInvalid);

          ExifData.SaveToFileEx(FileName);
          Result := True;
        end;
      finally
        F(ExifData);
      end;
    except
      on e: Exception do
      begin
        EventLog(e);
        if RaiseException then
          raise;
        Result := False;
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function UpdateFileGeoInfo(FileName: string; GeoInfo: TGeoLocation; RaiseException: Boolean = False): Boolean;
var
  ExifData: TExifData;
  OldMode: Cardinal;
  D, M, S: TExifFraction;

  procedure DoubleToCoordinates(Value: Double; out D, M, S: TExifFraction);
  var
    Vd, Md, Sd: Double;
  begin
    Vd := Abs(Value);

    D := TExifFraction.Create(Trunc(Vd), 1);

    Md := (Vd - Trunc(Vd)) * 60;

    M := TExifFraction.Create(Trunc(Md), 1);

    Sd := (Md - Trunc(Md)) * 60;

    S := TExifFraction.Create(Round(Sd * 1000), 1000);;
  end;

  function GetLatDirection(V: Double): TGPSLatitudeRef;
  begin
    if V < 0 then
      Result := ltSouth
    else
      Result := ltNorth;
  end;

  function GetLngDirection(V: Double): TGPSLongitudeRef;
  begin
    if V < 0 then
      Result := lnWest
    else
      Result := lnEast;
  end;

begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromFileEx(FileName);

        DoubleToCoordinates(GeoInfo.Latitude, D, M, S);
        ExifData.GPSLatitude.Assign(D, M, S, GetLatDirection(GeoInfo.Latitude));

        DoubleToCoordinates(GeoInfo.Longitude, D, M, S);
        ExifData.GPSLongitude.Assign(D, M, S, GetLngDirection(GeoInfo.Longitude));

        ExifData.SaveToFileEx(FileName);
        Result := True;
      finally
        F(ExifData);
      end;
    except
      on e: Exception do
      begin
        EventLog(e);
        if RaiseException then
          raise;
        Result := False;
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

{ DBXMPPacket }

function DBXMPPacket.GetAccess: Integer;
begin
  Result := ReadInteger(uConstants.EXIF_BASE_ACCESS);
end;

function DBXMPPacket.GetGroups: string;
begin
  Result := ReadString(uConstants.EXIF_BASE_GROUPS);
end;

function DBXMPPacket.GetInclude: Boolean;
begin
  Result := ReadBool(uConstants.EXIF_BASE_INCLUDE, True);
end;

function DBXMPPacket.GetLens: string;
begin
  Result := ReadString('Lens', xsExifAux);
end;

function DBXMPPacket.GetLinks: string;
begin
  Result := ReadString(uConstants.EXIF_BASE_LINKS);
end;

function DBXMPPacket.ReadBool(Name: string; DefaultValue: Boolean): Boolean;
begin
  try
    Result := Schemas[xsXMPBasic].Properties[Name].ReadValue(DefaultValue);
  except
    Result := False;
  end;
end;

function DBXMPPacket.ReadInteger(Name: string): Integer;
begin
  try
    Result := Schemas[xsXMPBasic].Properties[Name].ReadValue(0);
  except
    Result := 0;
  end;
end;

function DBXMPPacket.ReadString(Name: string; NS: TXMPKnownNamespace = xsXMPBasic): string;
begin
  try
    Result := Schemas[NS].Properties[Name].ReadValue('');
  except
    Result := '';
  end;
end;

procedure DBXMPPacket.SetAccess(const Value: Integer);
begin
  WriteInteger(uConstants.EXIF_BASE_ACCESS, Value);
end;

procedure DBXMPPacket.SetGroups(const Value: string);
begin
  WriteString(uConstants.EXIF_BASE_GROUPS, Value);
end;

procedure DBXMPPacket.SetInclude(const Value: Boolean);
begin
  WriteBool(uConstants.EXIF_BASE_Include, Value);
end;

procedure DBXMPPacket.SetLinks(const Value: string);
begin
  WriteString(uConstants.EXIF_BASE_LINKS, Value);
end;

type
  TXMPPacketEx = class(TXMPPacket);

procedure DBXMPPacket.UpdateXML;
begin
  TXMPPacketEx(Self).Changed(True);
end;

procedure DBXMPPacket.WriteBool(Name: string; Value: Boolean);
begin
  Schemas[xsXMPBasic].Properties[Name].WriteValue(Value);
end;

procedure DBXMPPacket.WriteInteger(Name: string; Value: Integer);
begin
  Schemas[xsXMPBasic].Properties[Name].WriteValue(Value);
end;

procedure DBXMPPacket.WriteString(Name, Value: string);
begin
  Schemas[xsXMPBasic].Properties[Name].WriteValue(Value);
end;

{ TExifDataHelper }

function TExifDataHelper.LoadFromFileEx(FileName: string; ThrowOnError: Boolean = True): Boolean;
var
  MS: TMemoryStream;
  Password: string;
begin
  Result := False;
  if IsDevicePath(FileName) then
    Exit;

  if ValidCryptGraphicFile(FileName) then
  begin
    Password := SessionPasswords.FindForFile(FileName);
    MS := TMemoryStream.Create;
    try
      if DecryptGraphicFileToStream(FileName, Password, MS) then
        Result := LoadFromGraphic(MS)
      else if ThrowOnError then
        raise Exception.Create(FormatEx(TA('Can''t decrypt file {0}!', 'Exif'), [FileName]));
    finally
      F(MS);
    end;
    Exit;
  end;

  Result := LoadFromGraphic(FileName);
end;

procedure TExifDataHelper.SaveToFileEx(FileName: string);
var
  MS, OS: TMemoryStream;
  Password: string;
  GraphicClass: TGraphicClass;
  FD: Integer;
begin
  if IsDevicePath(FileName) then
    Exit;

  FD := GetFileDate(FileName);
  if ValidCryptGraphicFile(FileName) then
  begin
    Password := SessionPasswords.FindForFile(FileName);
    MS := TMemoryStream.Create;
    try
      if DecryptGraphicFileToStream(FileName, Password, MS) then
      begin
        GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));

        OS := TMemoryStream.Create;
        try
          if (GraphicClass = Vcl.Imaging.Jpeg.TJPEGImage) or (GraphicClass = TAnimatedJPEG) then
            TExifDataEx(Self).DoSaveToJPEG(MS, OS);

          if (GraphicClass = TTiffImage) then
            TExifDataEx(Self).DoSaveToTIFF(MS, OS);

          if (GraphicClass = TPSDGraphic) then
            TExifDataEx(Self).DoSaveToPSD(MS, OS);

          if OS.Size > 0 then
          begin
            OS.Seek(0, soFromBeginning);
            if SaveNewStreamForEncryptedFile(FileName, Password, OS) = CRYPT_RESULT_ERROR_WRITING_FILE then
              raise Exception.Create(FormatEx(TA('Can''t write info to file {0}!', 'Exif'), [FileName]));
          end;

          if FD > 0 then
            FileSetDate(FileName, FD);
        finally
          F(OS);
        end;
      end else
        raise Exception.Create(FormatEx(TA('Can''t decrypt file {0}!', 'Exif'), [FileName]));
    finally
      F(MS);
    end;
    Exit;
  end;

  SaveToGraphic(FileName);
  if FD > 0 then
    FileSetDate(FileName, FD);
end;

function EXIFDateToDate(DateTime: string): TDateTime;
var
  Yyyy, Mm, Dd: Word;
  D: string;
  DT: TDateTime;
begin
  Result := 0;
  if TryStrToDate(DateTime, DT) then
  begin
    Result := DateOf(DT);
  end else
  begin
    D := Copy(DateTime, 1, 10);
    TryStrToDate(D, Result);
    if Result = 0 then
    begin
      Yyyy := StrToIntDef(Copy(DateTime, 1, 4), 0);
      Mm := StrToIntDef(Copy(DateTime, 6, 2), 0);
      Dd := StrToIntDef(Copy(DateTime, 9, 2), 0);
      if (Yyyy > 1990) and (Yyyy < 2050) then
        if (Mm >= 1) and (Mm <= 12) then
          if (Dd >= 1) and (Dd <= 31) then
            Result := EncodeDate(Yyyy, Mm, Dd);
    end;
  end;
end;

function EXIFDateToTime(DateTime: string): TDateTime;
var
  T: string;
  DT: TDateTime;
begin
  Result := 0;
  if TryStrToTime(DateTime, DT) then
  begin
    Result := TimeOf(DT);
  end else
  begin
    T := Copy(DateTime, 12, 8);
    TryStrToTime(T, Result);
    Result := TimeOf(Result);
  end;
end;

end.
