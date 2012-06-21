unit uExifUtils;

interface

uses
  uErrors,
  Windows,
  uConstants,
  CCR.Exif,
  uMemory,
  Classes,
  UnitDBDeclare,
  uSettings,
  uAssociations,
  Jpeg,
  GraphicEx,
  Graphics,
  SysUtils,
  CCR.Exif.XMPUtils,
  uTiffImage,
  RAWImage,
  uAnimatedJPEG,
  uLogger,
  uPortableDeviceUtils,
  GraphicCrypt,
  UnitDBKernel,
  uSysUtils,
  uTranslate;

type
  TExifPatchInfo = class
  public
    ID: Integer;
    Params: TEventFields;
    Value: TEventValues;
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
function ExifDisplayButNotRotate(Orientation: Integer): Integer;
function GetExifRating(FileName: string): Integer; overload;
function GetExifRating(ExifData: TExifData): Integer; overload;
function GetExifRotate(FileName: string): Integer;
function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
function UpdateImageRecordFromExifData(Info: TDBPopupMenuInfoRecord; ExifData: TExifData; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
function UpdateFileExif(FileName: string; Info: TExifPatchInfo): Boolean; overload;
function UpdateFileExif(Info: TDBPopupMenuInfoRecord): Boolean; overload;
function CreateRating(Rating: Integer): TWindowsStarRating;
function CreateOrientation(Rotation: Integer): TExifOrientation;
function CanSaveEXIF(FileName: string): Boolean;
function UpdateFileGeoInfo(FileName: string; GeoInfo: TGeoLocation; RaiseException: Boolean = False): Boolean;
function DeleteFileGeoInfo(FileName: string; RaiseException: Boolean = False): Boolean;
function UpdateImageGeoInfoFromExif(Info: TDBPopupMenuInfoRecord; ExifData: TExifData): Boolean;
function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
procedure FixJpegStreamEXIF(Stream: TStream; Width, Height: Integer);
procedure FixEXIFForJpegStream(Exif: TExifData; Stream: TStream; Width, Height: Integer);

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
  if (GraphicClass = Jpeg.TJPEGImage)
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

function UpdateImageGeoInfoFromExif(Info: TDBPopupMenuInfoRecord; ExifData: TExifData): Boolean;
begin
  Result := False;

  if not Settings.Exif.ReadInfoFromExif then
    Exit;

  if not ExifData.Empty then
  begin
    if (ExifData.GPSLatitude <> nil) and (ExifData.GPSLongitude <> nil) and not ExifData.GPSLatitude.MissingOrInvalid and not ExifData.GPSLongitude.MissingOrInvalid then
      Info.LoadGeoInfo(GeoLocationToDouble(ExifData.GPSLatitude), GeoLocationToDouble(ExifData.GPSLongitude));
    Result := True;
  end;
end;

function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
var
  ExifData: TExifData;
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := False;

    if not Settings.Exif.ReadInfoFromExif then
      Exit;

    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromFileEx(Info.FileName);
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

function CanReadExifInfo(Info: TDBPopupMenuInfoRecord): Boolean;
begin
  Result := False;

  if IsDevicePath(Info.FileName) then
    Exit;

  if (Info.Rating > 0) and (Info.Rotation <> DB_IMAGE_ROTATE_0) then
    Exit; //nothing to update

  if not Settings.Exif.ReadInfoFromExif then
    Exit;

  Result := True;
end;

function UpdateImageRecordFromExifData(Info: TDBPopupMenuInfoRecord; ExifData: TExifData; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
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

function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
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

function UpdateFileExif(Info: TDBPopupMenuInfoRecord): Boolean;
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
          if ExifData.Orientation <> CreateOrientation(Info.Value.Rotate) then
          begin
            ExifData.Orientation := CreateOrientation(Info.Value.Rotate);
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

        if [EventID_Param_Private, SetNewIDFileData] * Info.Params <> [] then
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

function ExifDisplayButNotRotate(Orientation: Integer): Integer;
begin
  Result := Orientation;
  if Result < 0 then
  begin
    if Result > -100 then
      Result := Result * 10;
  end else
    Result := Result * 10;
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
      if RAWImage.IsRAWSupport and IsRAWImageFile(FileName) then
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

        if not ExifData.Empty then
        begin
          DoubleToCoordinates(GeoInfo.Latitude, D, M, S);
          ExifData.GPSLatitude.Assign(D, M, S, GetLatDirection(GeoInfo.Latitude));

          DoubleToCoordinates(GeoInfo.Longitude, D, M, S);
          ExifData.GPSLongitude.Assign(D, M, S, GetLngDirection(GeoInfo.Longitude));

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
    Password := DBKernel.FindPasswordForCryptImageFile(FileName);
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
    Password := DBKernel.FindPasswordForCryptImageFile(FileName);
    MS := TMemoryStream.Create;
    try
      if DecryptGraphicFileToStream(FileName, Password, MS) then
      begin
        GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));

        OS := TMemoryStream.Create;
        try
          if (GraphicClass = Jpeg.TJPEGImage) or (GraphicClass = TAnimatedJPEG) then
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

end.
