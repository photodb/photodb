unit uExifUtils;

interface

uses
  Windows, uConstants, CCR.Exif, uMemory, UnitDBDeclare, uSettings, uAssociations,
  Jpeg, GraphicEx, Graphics, SysUtils, CCR.Exif.XMPUtils, uTiffImage;

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
  published
    function ReadString(Name: string): string;
    procedure WriteString(Name, Value: string);
    function ReadInteger(Name: string): Integer;
    procedure WriteInteger(Name: string; Value: Integer);
    function ReadBool(Name: string; DefaultValue: Boolean): Boolean;
    procedure WriteBool(Name: string; Value: Boolean);
  published
    property Groups: string read GetGroups write SetGroups;
    property Links: string read GetLinks write SetLinks;
    property Access: Integer read GetAccess write SetAccess;
    property Include: Boolean read GetInclude write SetInclude;
  end;

function ExifOrientationToRatation(Orientation: Integer): Integer;
function GetExifRating(FileName: string): Integer; overload;
function GetExifRating(ExifData: TExifData): Integer; overload;
function GetExifRotate(FileName: string): Integer;
function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
function UpdateFileExif(FileName: string; Info: TExifPatchInfo): Boolean; overload;
function UpdateFileExif(Info: TDBPopupMenuInfoRecord): Boolean; overload;
function CreateRating(Rating: Integer): TWindowsStarRating;
function CreateOrientation(Rotation: Integer): TExifOrientation;
function CanSaveFileOrientation(FileName: string): Boolean;

implementation

function CanSaveFileOrientation(FileName: string): Boolean;
var
  GraphicClass: TGraphicClass;
begin
  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if (GraphicClass = Jpeg.TJPEGImage)
    or (GraphicClass = TTiffImage)
    or (GraphicClass = GraphicEx.TPSDGraphic)
    then
      Result := True
  else
    Result := False;
end;

function UpdateImageRecordFromExif(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
var
  ExifData: TExifData;
  Rating, Rotation: Integer;
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := False;

    if not CanSaveFileOrientation(Info.FileName) then
      Exit;

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
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if not CanSaveFileOrientation(Info.FileName) then
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
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Changed := False;
    if not CanSaveFileOrientation(FileName) then
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
          if ExifData.Keywords <> Trim(Info.Value.KeyWords) then
          begin
            ExifData.Keywords := Trim(Info.Value.KeyWords);
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

        if EventID_Param_Groups in Info.Params then
        begin
          if ExifData.XMPPacket.Groups <> Info.Value.Groups then
          begin
            ExifData.XMPPacket.Groups := Info.Value.Groups;
            Changed := True;
          end;
        end;

        if EventID_Param_Links in Info.Params then
        begin
          if ExifData.XMPPacket.Links <> Info.Value.Links then
          begin
            ExifData.XMPPacket.Links := Info.Value.Links;
            Changed := True;
          end;
        end;

        if EventID_Param_Private in Info.Params then
        begin
          if ExifData.XMPPacket.Access <> Info.Value.Access then
          begin
            ExifData.XMPPacket.Access := Info.Value.Access;
            Changed := True;
          end;
        end;

        if EventID_Param_Include in Info.Params then
        begin
          if ExifData.XMPPacket.Include <> Info.Value.Include then
          begin
            ExifData.XMPPacket.Include := Info.Value.Include;
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

function DBXMPPacket.GetLinks: string;
begin
  Result := ReadString(uConstants.EXIF_BASE_LINKS);
end;

function DBXMPPacket.ReadBool(Name: string; DefaultValue: Boolean): Boolean;
begin
  Result := Schemas[xsXMPBasic].Properties[Name].ReadValue(DefaultValue);
end;

function DBXMPPacket.ReadInteger(Name: string): Integer;
begin
  Result := Schemas[xsXMPBasic].Properties[Name].ReadValue(0);
end;

function DBXMPPacket.ReadString(Name: string): string;
begin
  Result := Schemas[xsXMPBasic].Properties[Name].ReadValue('');
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

end.
