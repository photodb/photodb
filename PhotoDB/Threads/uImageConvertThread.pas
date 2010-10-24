unit uImageConvertThread;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, Dolphin_db, GraphicCrypt,
  ImageConverting, Exif, uLogger, GraphicEx, UnitDBCommon, uMemory, uFileUtils,
  PngImage, uGOM, uDBForm, Dialogs, UnitDBDeclare, JPEG, UnitJPEGOptions,
  UnitDBCommonGraphics, GDIPlusRotate, UnitPropeccedFilesSupport, uThreadEx,
  uThreadForm, uTranslate;

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
  Exif : TExif;
  W, H, Width, Height : Integer;
  Crypted : Boolean;
  MS, MD : TMemoryStream;
  FS : TFileStream;

  procedure FixEXIFRotate;
  begin
    if FProcessingParams.Rotation = DB_IMAGE_ROTATE_EXIF then
    begin
      Exif := TExif.Create;
      try
        Exif.ReadFromFile(FData.FileName);
        FProcessingParams.Rotation := ExifOrientationToRatation(Exif.Orientation);
      except
        on e : Exception do
          EventLog(e.Message);
      end;
      Exif.Free;
    end;
  end;

const
  MODE_GDI_PLUS_CRYPT = 0;
  MODE_GDI_PLUS       = 1;
  MODE_CUSTOM         = 2;
  MODE_PREVIEW        = 3;

  procedure SaveFile(Mode : Integer);
  var
    Bitmap,
    TmpImage : TBitmap;
    W, H : Integer;
  begin

    repeat
      try
        SetLastError(0);

        case mode of
          MODE_GDI_PLUS_CRYPT:
            begin
              FS := TFileStream.Create(FileName, fmCreate);
              try
                MD.Seek(0, soFromBeginning);
                CryptStream(MD, FS, Password, CRYPT_OPTIONS_SAVE_CRC, FileName);
              finally
                FS.Free;
              end;
            end;

          MODE_GDI_PLUS:
            begin
              case FProcessingParams.Rotation of
                DB_IMAGE_ROTATE_270:
                  RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate270, True, FileName);
                DB_IMAGE_ROTATE_90:
                  RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate90, True, FileName);
                DB_IMAGE_ROTATE_180:
                  RotateGDIPlusJPEGFile(FData.FileName, EncoderValueTransformRotate180, True, FileName);
              end;
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
                if NewGraphic is PngImage.TPngGraphic then
                  PngImage.TPngGraphic(NewGraphic).Image.CopyToBmp(Bitmap)
                else
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

    if (AnsiLowerCase(FileName) = AnsiLowerCase(FData.FileName)) then
      Synchronize(NotifyDB);
  end;

begin
  FreeOnTerminate := True;
  FEndProcessing := False;
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

    FileName := FProcessingParams.WorkDirectory;
    FileName := FileName + '\' + GetFileNameWithoutExt(FData.FileName) + FProcessingParams.Preffix;
    FileName := FileName + GetGraphicExtForSave(NewGraphicClass);

    if FProcessingParams.Rotate then
      InitGDIPlus;

    //if only rotate and JPEG image -> rotate only with GDI+
    if FProcessingParams.Rotate
      and DBKernel.Readbool('Options', 'UseGDIPlus', GDIPlusPresent)
      and not FProcessingParams.ResizeToSize
      and not FProcessingParams.AddWatermark
      and not FProcessingParams.PreviewOptions.GeneratePreview
      and (NewGraphicClass = GraphicClass)
      and (GraphicClass = TJPEGImage) then
    begin
      FixEXIFRotate;

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
            MD.Free;
          end;
        end else
          SaveFile(MODE_GDI_PLUS);

      finally
        MS.Free;
      end;

      if (AnsiLowerCase(FileName) = AnsiLowerCase(FData.FileName)) then
        Synchronize(NotifyDB);

      Exit;
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
  end;
end;

procedure TImageConvertThread.NotifyDB;
var
  EventInfo: TEventValues;
begin
  UpdateImageRecord(FData.FileName, FData.ID);
  EventInfo.Name := FData.FileName;
  EventInfo.NewName := FData.FileName;
  DBKernel.DoIDEvent(Self, FData.ID, [EventID_Param_Image], EventInfo);
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
