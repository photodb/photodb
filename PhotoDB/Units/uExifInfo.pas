unit uExifInfo;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.ValEdit,

  CCR.Exif,
  CCR.Exif.BaseUtils,
  CCR.Exif.XMPUtils,

  UnitDBDeclare,
  UnitLinksSupport,

  uConstants,
  uMemory,
  uStringUtils,
  uRawExif,
  uExifUtils,
  uImageLoader,
  uGroupTypes,
  uAssociations,
  uICCProfile,
  uTranslate,
  uEXIFDisplayControl,
  uLogger;

type
  IExifInfoLine = interface
    ['{83B2D82D-B8AC-4F75-80AC-C221EB06E903}']
    function GetID: string;
    function GetName: string;
    function GetValue: string;
    function GetIsExtended: Boolean;
    property ID: string read GetID;
    property Name: string read GetName;
    property Value: string read GetValue;
    property IsExtended: Boolean read GetIsExtended;
  end;

  IExifInfo = interface
    ['{D7927F65-F84E-4ED5-A711-95DB23271182}']
    function AddLine(Line: IExifInfoLine): IExifInfoLine;
    function GetEnumerator: TEnumerator<IExifInfoLine>;
    function GetValueByKey(Key: string): string;
    function GetDescriptionByKey(Key: string): string;
  end;

  TExifInfo = class(TInterfacedObject, IExifInfo)
  private
    FItems: TList<IExifInfoLine>;
  public
    constructor Create;
    destructor Destroy; override;
    function AddLine(Line: IExifInfoLine): IExifInfoLine;
    function GetEnumerator: TEnumerator<IExifInfoLine>;
    function GetValueByKey(Key: string): string;
    function GetDescriptionByKey(Key: string): string;
  end;

  TExifInfoLine = class(TInterfacedObject, IExifInfoLine)
  private
    FID, FName, FValue: string;
    FIsExtended: Boolean;
  public
    constructor Create(ID, AName, AValue: string; AIsExtended: Boolean);
    function GetID: string;
    function GetName: string;
    function GetValue: string;
    function GetIsExtended: Boolean;
  end;

procedure LoadExifInfo(VleEXIF: TValueListEditor; FileName: string);
function FillExifInfo(ExifData: TExifData; RawExif: TRawExif; out Info: IExifInfo): Boolean;

implementation

procedure LoadExifInfo(VleEXIF: TValueListEditor; FileName: string);
var
  OldMode: Cardinal;
  ExifInfo: IExifInfo;
  Line: IExifInfoLine;
  Info: TDBPopupMenuInfoRecord;
  ImageInfo: ILoadImageInfo;

  function L(S: string): string;
  begin
    Result := TA(S, 'PropertiesForm');
  end;

begin
  VleEXIF.Strings.BeginUpdate;
  try
    VleEXIF.Strings.Clear;

    OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
      try
        Info := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
        try
          if LoadImageFromPath(Info, -1, '', [ilfICCProfile, ilfEXIF, ilfPassword, ilfDontUpdateInfo], ImageInfo) then
          begin
            if FillExifInfo(ImageInfo.ExifData, ImageInfo.RawExif, ExifInfo) then
            begin
              for Line in ExifInfo do
                VleEXIF.InsertRow(Line.Name + ': ', Line.Value, True);
            end;
          end;
        finally
          F(Info);
        end;
      except
        on e: Exception do
        begin
          VleEXIF.InsertRow(L('Info:'), L('Exif header not found.'), True);
          Eventlog(e.Message);
        end;
      end;
    finally
      SetErrorMode(OldMode);
    end;
  finally
    VleEXIF.Strings.EndUpdate;
  end;
end;

function FillExifInfo(ExifData: TExifData; RawExif: TRAWExif; out Info: IExifInfo): Boolean;
var
  Orientation: Integer;
  Groups: TGroups;
  Links: TLinksInfo;
  SL: TStringList;
  I: Integer;
  ICCProfileMem: TMemoryStream;
  ICCProfile: string;

const
  XMPBasicValues: array[TWindowsStarRating] of UnicodeString = ('', '1', '2', '3', '4', '5');

  function L(S: string): string;
  begin
    Result := TA(S, 'PropertiesForm');
    Result := TA(Result, 'EXIF');
  end;

  procedure XInsert(ID, Key, Value: string; IsExtended: Boolean = False; Appendix: string = '');
  var
    Line: IExifInfoLine;
  begin
    Value := Trim(Value);
    if Value <> '' then
    begin
      Line := TExifInfoLine.Create(ID, Key, Value + Appendix, IsExtended);
      Info.AddLine(Line);
    end;
  end;

  function FractionToString(Fraction: TExifFraction): string;
  begin
    if Fraction.Denominator <> 0 then
      Result := FormatFloat('0.0' , Fraction.Numerator / Fraction.Denominator)
    else
      Result := Fraction.AsString;
  end;

  function ExposureFractionToString(Fraction: TExifFraction): string;
  begin
    if Fraction.Numerator <> 0 then
      Result := '1/' + FormatFloat('0' , Fraction.Denominator / Fraction.Numerator)
    else
      Result := Fraction.AsString;
  end;

begin
  Result := ExifData <> nil;
  if not Result then
    Exit;

  TTranslateManager.Instance.BeginTranslate;
  try

    Info := TExifInfo.Create;

    if not ExifData.Empty or not ExifData.XMPPacket.Empty then
    begin
      if not ExifData.Empty then
      begin
        XInsert('CameraMake', L('Make'), ExifData.CameraMake);
        XInsert('CameraModel', L('Model'), ExifData.CameraModel);
        XInsert('Copyright', L('Copyright'), ExifData.Copyright);
        if ExifData.DateTimeOriginal > 0 then
          XInsert('DateTimeOriginal', L('Date and time'), FormatDateTime('yyyy/mm/dd HH:MM:SS', ExifData.DateTimeOriginal));
        XInsert('ImageDescription', L('Description'), ExifData.ImageDescription);
        XInsert('Software', L('Software'), ExifData.Software);
        Orientation := ExifOrientationToRatation(Ord(ExifData.Orientation));
        case Orientation and DB_IMAGE_ROTATE_MASK of
          DB_IMAGE_ROTATE_0:
            XInsert('Orientation', L('Orientation'), L('Normal'));
          DB_IMAGE_ROTATE_90:
            XInsert('Orientation', L('Orientation'), L('Right'));
          DB_IMAGE_ROTATE_270:
            XInsert('Orientation', L('Orientation'), L('Left'));
          DB_IMAGE_ROTATE_180:
            XInsert('Orientation', L('Orientation'), L('180 grad.'));
        end;

        XInsert('ExposureTime', L('Exposure'), ExposureFractionToString(ExifData.ExposureTime), False, L('s'));
        if not ExifData.ExposureBiasValue.MissingOrInvalid and (ExifData.ExposureBiasValue.Numerator <> 0) then
          XInsert('ExposureBiasValue', L('Exposure bias'), ExifData.ExposureBiasValue.AsString);

        XInsert('ISOSpeedRatings', L('ISO'), ExifData.ISOSpeedRatings.AsString);
        XInsert('FocalLength', L('Focal length'), FractionToString(ExifData.FocalLength), False, L('mm'));
        XInsert('FNumber', L('F number'), FractionToString(ExifData.FNumber));

        //TODO: ?
        {ExifData.ApertureValue
        ExifData.BrightnessValue
        ExifData.Contrast
        ExifData.Saturation
        ExifData.Sharpness
        ExifData.MeteringMode
        ExifData.SubjectDistance }
      end;

      if ExifData.XMPPacket.Lens <> '' then
        XInsert('Lens', L('Lens'), ExifData.XMPPacket.Lens)
      else if not ExifData.Empty and (ExifData.LensModel <> '') then
        XInsert('Lens', L('Lens'), ExifData.LensModel);

      if not ExifData.Empty then
      begin
        if ExifData.Flash.Fired then
          XInsert('Flash', L('Flash'), L('On'))
        else
          XInsert('Flash', L('Flash'), L('Off'));

        if (ExifData.ExifImageWidth.Value > 0) and (ExifData.ExifImageHeight.Value > 0) then
        begin
          XInsert('Width', L('Width'), Format('%dpx.', [ExifData.ExifImageWidth.Value]));
          XInsert('Height', L('Height'), Format('%dpx.', [ExifData.ExifImageHeight.Value]));
        end;

        XInsert('Author', L('Author'), ExifData.Author);
        XInsert('Comments', L('Comments'), ExifData.Comments);
        XInsert('Keywords', L('Keywords'), ExifData.Keywords);
        XInsert('Subject', L('Subject'), ExifData.Subject);
        XInsert('Title', ('Title'), ExifData.Title);
        if ExifData.UserRating <> urUndefined then
          XInsert('UserRating', L('User Rating'), XMPBasicValues[ExifData.UserRating]);

        if (ExifData.GPSLatitude <> nil) and (ExifData.GPSLongitude <> nil) and not ExifData.GPSLatitude.MissingOrInvalid and not ExifData.GPSLongitude.MissingOrInvalid then
        begin
          XInsert('GPSLatitude', L('Latitude'), ExifData.GPSLatitude.AsString);
          XInsert('GPSLongitude', L('Longitude'), ExifData.GPSLongitude.AsString);
        end;

        if ExifData.HasICCProfile then
        begin
          ICCProfileMem := TMemoryStream.Create;
          try
            if ExifData.ExtractICCProfile(ICCProfileMem) then
            begin
              ICCProfile := GetICCProfileName(ExifData, ICCProfileMem.Memory, ICCProfileMem.Size);
              if ICCProfile <> '' then
                XInsert('ICCProfile', L('ICC profile'), ICCProfile);
            end;
          finally
            F(ICCProfileMem);
          end;
        end;
      end;

      if not ExifData.XMPPacket.Include then
        XInsert('Base search', L('Base search'), L('No'));

      if ExifData.XMPPacket.Groups <> '' then
      begin
        Groups := EncodeGroups(ExifData.XMPPacket.Groups);
        SL := TStringList.Create;
        try
          for I := 0 to Length(Groups) - 1 do
            if Groups[I].GroupName <> '' then
              SL.Add(Groups[I].GroupName);

          XInsert('Groups', L('Groups'), SL.Join(', '));
        finally
          F(SL);
        end;
      end;

      if ExifData.XMPPacket.Links <> '' then
      begin
        Links := ParseLinksInfo(ExifData.XMPPacket.Links);
        SL := TStringList.Create;
        try
          for I := 0 to Length(Links) - 1 do
            if Links[I].LinkName <> '' then
              SL.Add(Links[I].LinkName);

          XInsert('Links', L('Links'), SL.Join(', '));
        finally
          F(SL);
        end;
      end;

      if ExifData.XMPPacket.Access = Db_access_private then
        XInsert('Private', L('Private'), L('Yes'));

    end else
    begin
      if (RawExif <> nil) and (RawExif.Count > 0) then
      begin
        for I := 0 to RawExif.Count - 1 do
          XInsert(RawExif[I].Key, L(RawExif[I].Description), RawExif[I].Value);
      end else
        XInsert('Info', L('Info'), L('Exif header not found.'));
    end;

  finally
    TTranslateManager.Instance.EndTranslate;
  end;
end;

{ TExifInfoLine }

constructor TExifInfoLine.Create(ID, AName, AValue: string; AIsExtended: Boolean);
begin
  FID := ID;
  FName := AName;
  FValue := AValue;
  FIsExtended := AIsExtended;
end;

function TExifInfoLine.GetID: string;
begin
  Result := FID;
end;

function TExifInfoLine.GetIsExtended: Boolean;
begin
  Result := FIsExtended;
end;

function TExifInfoLine.GetName: string;
begin
  Result := FName;
end;

function TExifInfoLine.GetValue: string;
begin
  Result := FValue;
end;

{ TExifInfo }

function TExifInfo.AddLine(Line: IExifInfoLine): IExifInfoLine;
begin
  FItems.Add(Line);
end;

constructor TExifInfo.Create;
begin
  FItems := TList<IExifInfoLine>.Create;
end;

destructor TExifInfo.Destroy;
begin
  F(FItems);
  inherited;
end;

function TExifInfo.GetDescriptionByKey(Key: string): string;
var
  I: Integer;
  Line: IExifInfoLine;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Line := FItems[I];
    if Line.ID = Key then
      Exit(Line.Name);
  end;
  Exit('');
end;

function TExifInfo.GetEnumerator: TEnumerator<IExifInfoLine>;
begin
  Result := FItems.GetEnumerator;
end;

function TExifInfo.GetValueByKey(Key: string): string;
var
  I: Integer;
  Line: IExifInfoLine;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Line := FItems[I];
    if Line.ID = Key then
      Exit(Line.Value);
  end;
  Exit('');
end;

end.
