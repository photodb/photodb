unit uDialogUtils;

interface

uses
  Vcl.Graphics,
  Vcl.Imaging.JPEG,

  UnitDBDeclare,
  UnitDBFileDialogs,

  uConstants,
  uMemory,
  uRuntime,
  uAssociations,
  uImageLoader;

procedure LoadNickJpegImage(Image: TPicture);
function GetImageFromUser(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;

implementation

function DBLoadImage(FileName: string; var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;
var
  Info: TDBPopupMenuInfoRecord;
  ImageInfo: ILoadImageInfo;
begin
  Result := False;
  Info := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
  try
    if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword, ilfAskUserPassword], ImageInfo, MaxWidth, MaxHeight) then
    begin
      Bitmap := ImageInfo.GenerateBitmap(Info, MaxWidth, MaxHeight, pf24Bit, clBlack, [ilboFreeGraphic, ilboRotate, ilboApplyICCProfile, ilboQualityResize]);
      Result := Bitmap <> nil;
    end;
  finally
    F(Info);
  end;
end;

function GetImageFromUser(var Bitmap: TBitmap; MaxWidth, MaxHeight: Integer): Boolean;
var
  OpenPictureDialog: DBOpenPictureDialog;
  FileName: string;
begin
  Result := False;
  OpenPictureDialog := DBOpenPictureDialog.Create;
  try
    OpenPictureDialog.Filter := TFileAssociations.Instance.FullFilter;
    if OpenPictureDialog.Execute then
    begin
      FileName := OpenPictureDialog.FileName;
      Result := DBLoadImage(FileName, Bitmap, MaxWidth, MaxHeight);
    end;
  finally
    F(OpenPictureDialog);
  end;
end;

procedure LoadNickJpegImage(Image: TPicture);
var
  Bitmap: TBitmap;
  FJPG: TJpegImage;
begin
  Bitmap := TBitmap.Create;
  try
    if GetImageFromUser(Bitmap, 48, 48) then
    begin
      FJPG := TJPegImage.Create;
      try
        FJPG.CompressionQuality := DBJpegCompressionQuality;
        FJPG.Assign(Bitmap);
        FJPG.JPEGNeeded;
        Image.Graphic := FJPG;
      finally
        F(FJPG);
      end;
    end;
  finally
    F(Bitmap);
  end;
end;

end.
