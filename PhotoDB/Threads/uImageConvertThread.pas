unit uImageConvertThread;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, Dolphin_db, GraphicCrypt,
  ImageConverting, uLogger, GraphicEx, UnitDBCommon, uMemory, uFileUtils,
  PngImage, uGOM, uDBForm, Dialogs, UnitDBDeclare, JPEG, UnitJPEGOptions,
  UnitDBCommonGraphics, GDIPlusRotate, UnitPropeccedFilesSupport, uThreadEx,
  uThreadForm, uTranslate, uDBPopupMenuInfo, uConstants, ExplorerTypes,
  ActiveX, CCR.Exif, CCR.Exif.IPTC;

type
  TImageConvertThread = class(TThreadEx)
  private
    { Private declarations }
    FData: TDBPopupMenuInfoRecord;
    FProcessingParams : TProcessingParams;
    FDialogResult : Integer;
    FEndProcessing : Boolean;
    FErrorMessage : string;
    BitmapParam : TBitmap;
    procedure ShowWriteError;
    procedure OnEnd;
    procedure NotifyDB;
    procedure UpdatePreview;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; AState : TGUID; AData : TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
  end;

implementation

uses UnitSizeResizerForm;

{ TImageConvertThread }

constructor TImageConvertThread.Create(AOwnerForm: TThreadForm; AState : TGUID; AData: TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
begin
  inherited Create(AOwnerForm, AState);
  FData := AData;
  FProcessingParams := AProcessingParams;
end;

procedure TImageConvertThread.Execute;
var
  Graphic, NewGraphic : TGraphic;
  GraphicClass, NewGraphicClass : TGraphicClass;
  Password : string;
  FileName : string;
  Original : TBitmap;
  ExifData: TExifData;
  W, H, Width, Height : Integer;
  Crypted : Boolean;
  MS, MD : TMemoryStream;
  FS : TFileStream;

  procedure FixEXIFRotate;
  begin
    if FProcessingParams.Rotation = DB_IMAGE_ROTATE_EXIF then
    begin
      ExifData := TExifData.Create;
      try
        ExifData.LoadFromJPEG(FData.FileName);
        FProcessingParams.Rotation := ExifOrientationToRatation(Ord(ExifData.Orientation));
      except
        on e : Exception do
          EventLog(e.Message);
      end;
      F(ExifData);
    end;
  end;

  procedure FixJpegStreamEXIF(Stream : TStream; Width, Height : Integer);
  var
    Jpeg : TJpegImage;
  begin
    ExifData := TExifData.Create;
    try
      Stream.Seek(0, soFromBeginning);
      ExifData.LoadFromJPEG(Stream);
      ExifData.BeginUpdate;
      try
        ExifData.Orientation := toTopLeft;
        ExifData.ExifImageWidth := Width;
        ExifData.ExifImageHeight := Height;
        ExifData.Thumbnail := nil;
        Stream.Seek(0, soFromBeginning);
        Jpeg := TJpegImage.Create;
        try
          Jpeg.LoadFromStream(Stream);
          ExifData.SaveToJPEG(Jpeg);
          Stream.Size := 0;
          Jpeg.SaveToStream(Stream);
        finally
          F(Jpeg);
        end;
      finally
        ExifData.EndUpdate;
      end;
    except
      on e : Exception do
        EventLog(e.Message);
    end;
    F(ExifData);
  end;

  procedure FixJpegFileEXIF(FileName : string; Width, Height : Integer);
  var
    FS : TFileStream;
  begin
    FS := TFileStream.Create(FileName, fmOpenReadWrite);
    try
      FixJpegStreamEXIF(FS, Width, Height);
    finally
      F(FS);
    end;
  end;

const
  MODE_GDI_PLUS_CRYPT = 0;
  MODE_GDI_PLUS       = 1;
  MODE_CUSTOM         = 2;
  MODE_PREVIEW        = 3;

  procedure SaveFile(Mode : Integer);
  var
    Bitmap : TBitmap;
    W, H : Integer;
  begin
    if AnsiLowerCase(FData.FileName) = AnsiLowerCase(FileName) then
      TLockFiles.Instance.AddLockedFile(FileName, 10000);
    try

      repeat
        try
          SetLastError(0);

          case mode of
            MODE_GDI_PLUS_CRYPT:
              begin
                FS := TFileStream.Create(FileName, fmCreate);
                try
                  MD.Seek(0, soFromBeginning);
                  FixJpegStreamEXIF(MD, FData.Width, FData.Height);
                  MD.Seek(0, soFromBeginning);
                  CryptStream(MD, FS, Password, CRYPT_OPTIONS_SAVE_CRC, FileName);
                finally
                  FS.Free;
                end;
              end;

            MODE_GDI_PLUS:
              begin
                //todo: remove thumbnail and fix exif
                case FProcessingParams.Rotation of
                  DB_IMAGE_ROTATE_270:
                    RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate270, FileName);
                  DB_IMAGE_ROTATE_90:
                    RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate90, FileName);
                  DB_IMAGE_ROTATE_180:
                    RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate180, FileName);
                end;
                FixJpegFileEXIF(FileName, FData.Width, FData.Height);
              end;

            MODE_CUSTOM:
              begin
                NewGraphic.SaveToFile(FileName);

                if Password <> '' then
                  CryptGraphicFileV2(FileName, Password, CRYPT_OPTIONS_SAVE_CRC);
              end;

            MODE_PREVIEW:
              begin
                Bitmap := TBitmap.Create;
                try
                  Bitmap.Assign(NewGraphic);
                  BitmapParam := TBitmap.Create;
                  try
                    W := Bitmap.Width;
                    H := Bitmap.Height;
                    ProportionalSize(FProcessingParams.PreviewOptions.PreviewWidth,
                      FProcessingParams.PreviewOptions.PreviewHeight, W, H);
                    DoResize(W, H, Bitmap, BitmapParam);
                      if SynchronizeEx(UpdatePreview) then
                        BitmapParam := nil;
                  finally
                    F(BitmapParam);
                  end;
                finally
                  F(Bitmap);
                end;
              end;
          end;

          if (GetLastError <> 0) and (GetLastError <> 183) and (GetLastError <> 6) then
            raise Exception.Create('Error code = ' + IntToStr(GetLastError));
          Exit;
        except
          on e : Exception do
          begin

            if not GOM.IsObj(ThreadForm) then
               Exit;

            FErrorMessage := e.Message;
            Synchronize(ShowWriteError);

            if FDialogResult = IDABORT then
            begin
              FEndProcessing := True;
              Exit;
            end else if FDialogResult = IDRETRY then
              Continue
            else if FDialogResult = IDIGNORE then
              Exit;
          end;
        end;
      until False;

    finally
      if (AnsiLowerCase(FileName) = AnsiLowerCase(FData.FileName)) then
      begin
        UpdateImageRecord(FData.FileName, FData.ID);
        Synchronize(NotifyDB);
        TLockFiles.Instance.RemoveLockedFile(FileName);
        TLockFiles.Instance.AddLockedFile(FileName, 100);
      end;
    end;
  end;

begin
  FreeOnTerminate := True;
  FEndProcessing := False;
  CoInitialize(nil);
  try

    GraphicClass := GetGraphicClass(ExtractFileExt(FData.FileName), False);
    if GraphicClass = nil then
      Exit;

    Crypted := ValidCryptGraphicFile(FData.FileName);
    if Crypted then
    begin
      Password := DBKernel.FindPasswordForCryptImageFile(FData.FileName);
      if Password = '' then
        Exit;
    end;

    if FProcessingParams.GraphicClass = nil then
      NewGraphicClass := GraphicClass
    else
      NewGraphicClass := FProcessingParams.GraphicClass;

    FileName := IncludeTrailingPathDelimiter(FProcessingParams.WorkDirectory);
    FileName := FileName + GetFileNameWithoutExt(FData.FileName) + FProcessingParams.Preffix;
    FileName := FileName + GetGraphicExtForSave(NewGraphicClass);

    //if only rotate and JPEG image -> rotate only with GDI+
    if FProcessingParams.Rotate
      and DBKernel.Readbool('Options', 'UseGDIPlus', GDIPlusPresent)
      and not FProcessingParams.Resize
      and not FProcessingParams.AddWatermark
      and not FProcessingParams.PreviewOptions.GeneratePreview
      and (NewGraphicClass = GraphicClass)
      and (GraphicClass = TJPEGImage) then
    begin
      InitGDIPlus;
      if GDIPlusPresent then
      begin
        FixEXIFRotate;
        if FProcessingParams.Rotation = DB_IMAGE_ROTATE_0 then
          Exit;

        MS := TMemoryStream.Create;
        try
          if Crypted then
          begin
            if not DecryptFileToStream(FData.FileName, Password, MS) then
              Exit;

            MD := TMemoryStream.Create;
            try
              case FProcessingParams.Rotation of
                DB_IMAGE_ROTATE_270:
                  RotateGDIPlusJPEGStream(MS, MD, EncoderValueTransformRotate270);
                DB_IMAGE_ROTATE_90:
                  RotateGDIPlusJPEGStream(MS, MD, EncoderValueTransformRotate90);
                DB_IMAGE_ROTATE_180:
                  RotateGDIPlusJPEGStream(MS, MD, EncoderValueTransformRotate180);
              end;

              SaveFile(MODE_GDI_PLUS_CRYPT);

            finally
              F(MD);
            end;
          end else
            SaveFile(MODE_GDI_PLUS);

        finally
          F(MS);
        end;

        Exit;
      end;
    end;

    Graphic := GraphicClass.Create;
    try
      if Crypted then
      begin
        F(Graphic);

        Graphic := DeCryptGraphicFile(FData.FileName, Password);
      end else
        Graphic.LoadFromFile(FData.FileName);

      if not CheckThread then
        Exit;

      Original := TBitmap.Create;
      try
        if FProcessingParams.PreviewOptions.GeneratePreview then
          JPEGScale(Graphic, FProcessingParams.PreviewOptions.PreviewWidth,
            FProcessingParams.PreviewOptions.PreviewHeight);

        Original.Assign(Graphic);
        F(Graphic);

        if FProcessingParams.Resize then
        begin
          if FProcessingParams.ResizeToSize then
          begin
            Width := FProcessingParams.Width;
            Height := FProcessingParams.Height;
          end else
          begin
            Width := Round(FProcessingParams.PercentResize * Original.Width / 100);
            Height := Round(FProcessingParams.PercentResize * Original.Height / 100);
          end;

          if FProcessingParams.SaveAspectRation then
          begin
            W := Width;
            H := Height;
            Width := Original.Width;
            Height := Original.Height;
            ProportionalSizeA(W, H, Width, Height);
          end;

          //resample image
          if FProcessingParams.PreviewOptions.GeneratePreview then
            Stretch(Width, Height, sfBox, 0, Original)
          else
            Stretch(Width, Height, sfLanczos3, 0, Original);
        end;

        if not CheckThread then
          Exit;

        //apply rotation to image - quick process
        if FProcessingParams.Rotate then
        begin
          FixEXIFRotate;

          if FProcessingParams.Rotation <> DB_IMAGE_ROTATE_UNKNOWN then
            ApplyRotate(Original, FProcessingParams.Rotation);
        end;

        if not CheckThread then
          Exit;

        //add watermark
        if FProcessingParams.AddWatermark then
          DrawWatermark(Original, FProcessingParams.WatermarkOptions.BlockCountX,
            FProcessingParams.WatermarkOptions.BlockCountY,
            FProcessingParams.WatermarkOptions.Text, -1,
            FProcessingParams.WatermarkOptions.Color,
            FProcessingParams.WatermarkOptions.Transparenty);

        if not CheckThread then
          Exit;

        //save
        NewGraphic := NewGraphicClass.Create;
        try
          NewGraphic.Assign(Original);
          F(Graphic);

          SetJPEGGraphicSaveOptions(ConvertImageID, NewGraphic);

          if FProcessingParams.PreviewOptions.GeneratePreview then
            SaveFile(MODE_PREVIEW)
          else
            SaveFile(MODE_CUSTOM);

        finally
          F(NewGraphic);
        end;

      finally
        F(Original);
      end;
    finally
      F(Graphic);
    end;
  finally
    ProcessedFilesCollection.RemoveFile(FData.FileName);
    if not FProcessingParams.PreviewOptions.GeneratePreview then
      SynchronizeEx(OnEnd);
    F(FData);
    CoUnInitialize;
  end;
end;

procedure TImageConvertThread.NotifyDB;
var
  EventInfo: TEventValues;
begin
  EventInfo.Name := FData.FileName;
  EventInfo.NewName := FData.FileName;
  DBKernel.DoIDEvent(Self, FData.ID, [EventID_Param_Refresh, EventID_Param_Image], EventInfo);
end;

procedure TImageConvertThread.OnEnd;
begin
  TFormSizeResizer(ThreadForm).ThreadEnd(FData, FEndProcessing);
end;

procedure TImageConvertThread.ShowWriteError;
begin
  FDialogResult := Application.MessageBox(PWideChar(Format(TA('Error writing data on disk: %s.'), [FErrorMessage])), PWideChar(PWideChar(TA('Error'))), MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

procedure TImageConvertThread.UpdatePreview;
begin
  TFormSizeResizer(ThreadForm).UpdatePreview(BitmapParam);
end;

end.
