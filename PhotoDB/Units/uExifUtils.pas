unit uExifUtils;

interface

uses
  Windows, uConstants, CCR.Exif, uMemory, UnitDBDeclare, uSettings;

type
  TExifPatchInfo = class
  public
    ID: Integer;
    Params: TEventFields;
    Value: TEventValues;
  end;

function ExifOrientationToRatation(Orientation: Integer): Integer;
function GetExifRating(FileName: string): Integer; overload;
function GetExifRating(ExifData: TExifData): Integer; overload;
function GetExifRotate(FileName: string): Integer;
function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True): Boolean;
function UpdateFileExif(FileName: string; Info: TExifPatchInfo): Boolean; overload;
function UpdateFileExif(Info: TDBPopupMenuInfoRecord): Boolean; overload;
function CreateRating(Rating: Integer): TWindowsStarRating;
function CreateOrientation(Rotation: Integer): TExifOrientation;

implementation

function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True): Boolean;
var
  ExifData: TExifData;
  Rating, Rotation: Integer;
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := False;
    if (Info.Rating > 0) and (Info.Rotation > DB_IMAGE_ROTATE_UNKNOWN) then
      Exit; //nothing to update

    if not Settings.Exif.ReadInfoFromExif then
      Exit;

    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(Info.FileName);
        if not ExifData.Empty then
        begin
          if Info.Rating <= 0 then
          begin
            Rating := GetExifRating(ExifData);
            if IsDBValues then
              Info.Rating := Rating
            else
              Info.Rating := - 10 * Rating;
          end;

          if Info.Rotation <= DB_IMAGE_ROTATE_0 then
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
        end;
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

function UpdateFileExif(Info: TDBPopupMenuInfoRecord): Boolean;
var
  ExifData: TExifData;
  Changed: Boolean;
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
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

        if Info.KeyWords <> '' then
        begin
          if ExifData.Keywords <> Info.KeyWords then
          begin
            ExifData.Keywords := Info.KeyWords;
            Changed := True;
          end;
        end;

        if Info.Comment <> '' then
        begin
          if ExifData.Comments <> Info.Comment then
          begin
            ExifData.Comments := Info.Comment;
            Changed := True;
          end;
        end;

        if Changed then
          ExifData.SaveToGraphic(Info.FileName);
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
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Changed := False;
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
        if EventID_Param_Rating in Info.Params then
        begin
          if ExifData.UserRating <> CreateRating(Info.Value.Rating) then
          begin
            ExifData.UserRating := CreateRating(Info.Value.Rating);
            Changed := True;
          end;
        end;
        if EventID_Param_Rotate in Info.Params then
        begin
          if ExifData.Orientation <> CreateOrientation(Info.Value.Rotate) then
          begin
            ExifData.Orientation := CreateOrientation(Info.Value.Rotate);
            Changed := True;
          end;
        end;

        if EventID_Param_KeyWords in Info.Params then
        begin
          if ExifData.Keywords <> Info.Value.KeyWords then
          begin
            ExifData.Keywords := Info.Value.KeyWords;
            Changed := True;
          end;
        end;

        if EventID_Param_Comment in Info.Params then
        begin
          if ExifData.Comments <> Info.Value.Comment then
          begin
            ExifData.Comments := Info.Value.Comment;
            Changed := True;
          end;
        end;

        if Changed then
          ExifData.SaveToGraphic(FileName);
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
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DB_IMAGE_ROTATE_0;
    try
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(FileName);
        if not ExifData.Empty then
          Result := ExifOrientationToRatation(Ord(ExifData.Orientation));
      finally
        F(ExifData);
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

end.
