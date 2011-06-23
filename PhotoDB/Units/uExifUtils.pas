unit uExifUtils;

interface

uses
  uConstants, CCR.Exif, uMemory;

function ExifOrientationToRatation(Orientation: Integer): Integer;
function GetExifRating(FileName: string): Integer; overload;
function GetExifRating(ExifData: TExifData): Integer; overload;

implementation

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
begin
  ExifData := TExifData.Create;
  try
    ExifData.LoadFromGraphic(FileName);
    Result := GetExifRating(ExifData);
  finally
    F(ExifData);
  end;
end;

end.
