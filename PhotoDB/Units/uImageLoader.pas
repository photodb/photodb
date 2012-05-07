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
  uPortableDeviceUtils;

type
  TImageLoadFlag = (ilfICCProfile, ilfEXIFRotate, ilfFullRAW);
  TImageLoadFlags = set of TImageLoadFlag;

  ILoadImageInfo = interface
    ['{8FA3C77A-70D6-4873-9F50-DA1F450A5FF9}']
    function ExtractGraphic: TGraphic;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
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
  public
    constructor Create(AGraphic: TGraphic; AImageTotalPages: Integer; ARotation: Integer;
      AICCProfileName: string; MSICC: TMemoryStream);
    destructor Destroy; override;
    function ExtractGraphic: TGraphic;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
  end;

function LoadImageFromPath(ImageFileName: string; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
  out ImageInfo: ILoadImageInfo): Boolean;

implementation

function LoadImageFromPath(ImageFileName: string; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
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
begin
  Result := False;
  ImageInfo := nil;
  ImageTotalPages := 0;
  EXIFRotation := DB_IMAGE_ROTATE_0;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(ImageFileName));
  if GraphicClass = nil then
    Exit(False);

  MSICC := nil;
  MS := TMemoryStream.Create;
  try
    if not IsDevicePath(ImageFileName) then
    begin
      FS := TFileStream.Create(ImageFileName, fmOpenRead or fmShareDenyNone);
      try
        if ValidCryptGraphicStream(FS) then
        begin
          DecryptStreamToStream(FS, MS, Password);
        end else
          MS.CopyFrom(FS, FS.Size);
      finally
        F(FS);
      end;
    end else
      ReadStreamFromDevice(ImageFileName, MS);

    if MS.Size > 0 then
    begin
      if Flags * [ilfICCProfile, ilfEXIFRotate] <> [] then
      begin
        MS.Seek(0, soFromBeginning);
        ExifData := TExifData.Create(nil);
        try
          if ExifData.LoadFromGraphic(MS) and not ExifData.Empty then
          begin
            if (ilfEXIFRotate in Flags) and RAWImage.IsRAWSupport and IsRAWImageFile(ImageFileName) then
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
        finally
          F(ExifData);
        end;
      end;

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
            MSICC);
          MSICC := nil;
          Graphic := nil;
          Result := True;
        end;
      finally
        F(Graphic);
      end;
    end;
  finally
    F(MS);
    F(MSICC);
  end;
end;

{ TLoadImageInfo }

function TLoadImageInfo.AppllyICCProfile(Bitmap: TBitmap): Boolean;
begin
  Result := False;
  if (Bitmap <> nil) and not Bitmap.Empty and (Bitmap.PixelFormat = pf24Bit) then
  begin
    if (FMSICC <> nil) and (FMSICC.Size > 0) then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, FMSICC.Memory, FMSICC.Size, '');

    if not Result and (FICCProfileName <> '') then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, nil, 0, FICCProfileName);
  end;
end;

constructor TLoadImageInfo.Create(AGraphic: TGraphic; AImageTotalPages,
  ARotation: Integer; AICCProfileName: string; MSICC: TMemoryStream);
begin
  FGraphic := AGraphic;
  FImageTotalPages := AImageTotalPages;
  FRotation := ARotation;
  FICCProfileName := AICCProfileName;
  FMSICC := MSICC;
end;

destructor TLoadImageInfo.Destroy;
begin
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

end.
