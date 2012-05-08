unit uImageLoader;

interface

uses
  uConstants,
  uMemory,
  Windows,
  SysUtils,
  Classes,
  Graphics,
  uTiffImage,
  RAWImage,
  CCR.Exif,
  uExifUtils,
  uICCProfile,
  GraphicCrypt,
  uAssociations,
  uGraphicUtils,
  CCR.Exif.XMPUtils,
  uPortableDeviceUtils,
  UnitDBDeclare,
  UnitDBKernel,
  uSettings;

type
  TImageLoadFlag = (ilfGraphic, ilfICCProfile, ilfEXIF, ilfFullRAW, ilfPassword);
  TImageLoadFlags = set of TImageLoadFlag;

  ILoadImageInfo = interface
    ['{8FA3C77A-70D6-4873-9F50-DA1F450A5FF9}']
    function ExtractGraphic: TGraphic;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
    function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
    function UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
    property ImageTotalPages: Integer read GetImageTotalPages;
    property Rotation: Integer read GetRotation;
  end;

  TLoadImageInfo = class(TInterfacedObject, ILoadImageInfo)
  private
    FGraphic: TGraphic;
    FImageTotalPages: Integer;
    FRotation: Integer;
    FICCProfileName: string;
    FMSICC: TMemoryStream;
    FExifData: TExifData;
  public
    constructor Create(AGraphic: TGraphic; AImageTotalPages: Integer; ARotation: Integer;
      AICCProfileName: string; MSICC: TMemoryStream; AFExifData: TExifData);
    destructor Destroy; override;
    function ExtractGraphic: TGraphic;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
    function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
    function UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
  end;

type
  TStreamHelper = class helper for TStream
  public
    function CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer): Int64;
  end;

function LoadImageFromPath(Info: TDBPopupMenuInfoRecord; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
  out ImageInfo: ILoadImageInfo): Boolean;

implementation

function LoadImageFromPath(Info: TDBPopupMenuInfoRecord; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
  out ImageInfo: ILoadImageInfo): Boolean;
var
  FS: TFileStream;
  MS: TMemoryStream;
  GraphicClass: TGraphicClass;
  TiffImage: TTiffImage;
  Graphic: TGraphic;
  EXIFRotation,
  ImageTotalPages: Integer;
  ExifData: TExifData;
  MSICC: TMemoryStream;
  XMPICCProperty: TXMPProperty;
  XMPICCPrifile: string;
  LoadOnlyExif: Boolean;
begin
  Result := False;
  ImageInfo := nil;
  ImageTotalPages := 0;
  EXIFRotation := DB_IMAGE_ROTATE_0;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(Info.FileName));
  if GraphicClass = nil then
    Exit(False);

  MSICC := nil;
  MS := TMemoryStream.Create;
  try
    if (ilfGraphic in Flags) then
    begin
      if not IsDevicePath(Info.FileName) then
      begin
        FS := TFileStream.Create(Info.FileName, fmOpenRead or fmShareDenyNone);
        try
          Info.Encrypted := ValidCryptGraphicStream(FS);
          if Info.Encrypted then
          begin
            if ilfPassword in Flags then
              Password := DBKernel.FindPasswordForCryptImageFile(Info.FileName);

            DecryptStreamToStream(FS, MS, Password);
          end else
            MS.CopyFromEx(FS, FS.Size, 1024 * 1024);
        finally
          F(FS);
        end;
      end else
        ReadStreamFromDevice(Info.FileName, MS);
    end;

    LoadOnlyExif := (ilfEXIF in Flags) and not (ilfGraphic in Flags);

    if (MS.Size > 0) or LoadOnlyExif then
    begin
      if Flags * [ilfICCProfile, ilfEXIF] <> [] then
      begin
        MS.Seek(0, soFromBeginning);
        ExifData := TExifData.Create(nil);
        try
          if LoadOnlyExif then
            ExifData.LoadFromFileEx(Info.FileName)
          else
            ExifData.LoadFromGraphic(MS);

          if not ExifData.Empty then
          begin
            if (ilfEXIF in Flags) and RAWImage.IsRAWSupport and IsRAWImageFile(Info.FileName) then
              EXIFRotation := ExifOrientationToRatation(Ord(ExifData.Orientation));

            if (ilfICCProfile in Flags) then
            begin
              if ExifData.ColorSpace = csUncalibrated then
              begin
                if ExifData.HasICCProfile then
                begin
                  MSICC := TMemoryStream.Create;
                  ExifData.ExtractICCProfile(MSICC);
                end;
                if not Result then
                begin
                  XMPICCProperty := ExifData.XMPPacket.Schemas[xsPhotoshop].Properties['ICCProfile'];
                  if XMPICCProperty <> nil then
                    XMPICCPrifile := XMPICCProperty.ReadValue();
                end;
              end;
            end;
          end;

          if (ilfGraphic in Flags) then
          begin
            Graphic := GraphicClass.Create;
            try
              InitGraphic(Graphic);
              if (Graphic is TRAWImage) then
                 TRAWImage(Graphic).IsPreview := not (ilfFullRAW in Flags);

              MS.Seek(0, soFromBeginning);
              if (Graphic is TTiffImage) then
              begin
                TiffImage := TTiffImage(Graphic);
                TiffImage.LoadFromStreamEx(MS, LoadPage);
                ImageTotalPages := TiffImage.Pages;
              end else
                Graphic.LoadFromStream(MS);

              if not Graphic.Empty then
              begin
                ImageInfo := TLoadImageInfo.Create(
                  Graphic,
                  ImageTotalPages,
                  EXIFRotation,
                  XMPICCPrifile,
                  MSICC,
                  ExifData);
                ExifData := nil;
                MSICC := nil;
                Graphic := nil;
                Result := True;
              end;
            finally
              F(Graphic);
            end;
          end else
          begin
            ImageInfo := TLoadImageInfo.Create(
              nil,
              ImageTotalPages,
              EXIFRotation,
              XMPICCPrifile,
              MSICC,
              ExifData);
            ExifData := nil;
            MSICC := nil;
            Result := True;
          end;

        finally
          F(ExifData);
        end;
      end;
    end;
  finally
    F(MS);
    F(MSICC);
  end;
end;

{ TLoadImageInfo }

function TLoadImageInfo.AppllyICCProfile(Bitmap: TBitmap): Boolean;

  function DisplayProfileName: string;
  begin
    Result := Settings.ReadString('Options', 'DisplayICCProfileName', DEFAULT_ICC_DISPLAY_PROFILE);
    if Result = '-' then
      Result := '';
  end;

begin
  Result := False;
  if (Bitmap <> nil) and not Bitmap.Empty and (Bitmap.PixelFormat = pf24Bit) then
  begin
    if (FMSICC <> nil) and (FMSICC.Size > 0) then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, FMSICC.Memory, FMSICC.Size, '', DisplayProfileName);

    if not Result and (FICCProfileName <> '') then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, nil, 0, FICCProfileName, DisplayProfileName);
  end;
end;

constructor TLoadImageInfo.Create(AGraphic: TGraphic; AImageTotalPages,
  ARotation: Integer; AICCProfileName: string; MSICC: TMemoryStream;
  AFExifData: TExifData);
begin
  FGraphic := AGraphic;
  FImageTotalPages := AImageTotalPages;
  FRotation := ARotation;
  FICCProfileName := AICCProfileName;
  FMSICC := MSICC;
  FExifData := AFExifData;
end;

destructor TLoadImageInfo.Destroy;
begin
  F(FExifData);
  F(FMSICC);
  F(FGraphic);
  inherited;
end;

function TLoadImageInfo.ExtractGraphic: TGraphic;
begin
  Result := FGraphic;
  FGraphic := nil;
end;

function TLoadImageInfo.GetImageTotalPages: Integer;
begin
  Result := FImageTotalPages;
end;

function TLoadImageInfo.GetRotation: Integer;
begin
  Result := FRotation;
end;

function TLoadImageInfo.UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
begin
  Result := False;
  if FExifData <> nil then
    Result := UpdateImageGeoInfoFromExif(Info, FExifData);
end;

function TLoadImageInfo.UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
begin
  Result := False;
  if FExifData <> nil then
    Result := UpdateImageRecordFromExifData(Info, FExifData, IsDBValues, LoadGroups);
end;

{ TStreamHelper }

function TStreamHelper.CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer): Int64;
var
  BufSize, N: Integer;
  Buffer: PByte;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;


end.
