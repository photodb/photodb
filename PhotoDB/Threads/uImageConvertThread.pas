unit uImageConvertThread;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, UnitDBKernel, GraphicCrypt,
  uLogger, GraphicEx, UnitDBCommon, uMemory, uFileUtils, GIFImage,
  PngImage, uGOM, uDBForm, Dialogs, UnitDBDeclare, JPEG, UnitJPEGOptions,
  uJpegUtils, GDIPlusRotate, UnitPropeccedFilesSupport, uThreadEx,
  uThreadForm, uTranslate, uDBPopupMenuInfo, uConstants, ExplorerTypes,
  ActiveX, CCR.Exif, CCR.Exif.IPTC, uDBUtils, uGraphicUtils, Dolphin_DB,
  uAssociations, uExifUtils, uBitmapUtils, UnitDBCommonGraphics, RAWImage;

type
  TJpegX = class(TJPEGImage);

type
  TImageConvertThread = class(TThreadEx)
  private
    { Private declarations }
    FData: TDBPopupMenuInfoRecord;
    FProcessingParams: TProcessingParams;
    FDialogResult: Integer;
    FEndProcessing: Boolean;
    FErrorMessage: string;
    BitmapParam: TBitmap;
    FStringParam: string;
    FFontParam: HFont;
    OriginalWidth, OriginalHeight : Integer;
    FRect: TRect;
    FIntParam: Integer;
    FLongFont: TLogFont;
    FDataParam: TDBPopupMenuInfoRecord;
    procedure ShowWriteError;
    procedure OnEnd;
    procedure NotifyDB;
    procedure UpdatePreview;
    procedure UpdateDBRotation;
    procedure AddInfoToCollection;
    procedure RefreshItem;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; AState : TGUID; AData : TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
    procedure AsyncDrawCallBack(Bitmap: TBitmap; Rct: TRect; Text: string);
    procedure SyncDrawCallBack;
    function AsyncPrepareBitmapCallBack(Bitmap: TBitmap; Font: HFont; Text: string): Integer;
    procedure SyncPrepareBitmap;
    function AsyncGetFontCallBack(Bitmap: TBitmap): TLogFont;
    procedure SyncGetFont;
  end;

implementation

uses
  UnitSizeResizerForm,
  UnitUpdateDB;

{ TImageConvertThread }

procedure TImageConvertThread.AddInfoToCollection;
begin
  UpdaterDB.AddFileEx(FDataParam, True, True);
end;

procedure TImageConvertThread.AsyncDrawCallBack(Bitmap: TBitmap; Rct: TRect;
  Text: string);
begin
  BitmapParam := Bitmap;
  FRect := Rct;
  FStringParam := Text;
  Synchronize(SyncDrawCallBack);
end;

function TImageConvertThread.AsyncGetFontCallBack(Bitmap: TBitmap): TLogFont;
begin
  BitmapParam := Bitmap;
  SynchronizeEx(SyncGetFont);
  Result := FLongFont;
end;

function TImageConvertThread.AsyncPrepareBitmapCallBack(Bitmap: TBitmap;
  Font: HFont; Text: string): Integer;
begin
  BitmapParam := Bitmap;
  FStringParam := Text;
  FFontParam := Font;
  Synchronize(SyncPrepareBitmap);
  Result := FIntParam;
end;

constructor TImageConvertThread.Create(AOwnerForm: TThreadForm; AState : TGUID; AData: TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
begin
  inherited Create(AOwnerForm, AState);
  FData := AData;
  FProcessingParams := AProcessingParams;
end;

procedure TImageConvertThread.Execute;
var
  Graphic, NewGraphic: TGraphic;
  GraphicClass, NewGraphicClass: TGraphicClass;
  Password, Ext: string;
  FileName: string;
  Original,
  TmpBitmap: TBitmap;
  ExifData: TExifData;
  W, H, Width, Height, Rotation: Integer;
  Crypted: Boolean;
  MS, MD: TMemoryStream;
  FS: TFileStream;
  IsPreviewAvailalbe: Boolean;
  FileInfo: TDBPopupMenuInfoRecord;

  procedure Exchange(var A, B: TBitmap);
  var
    C: TBitmap;
  begin
    C := A;
    A := B;
    B := C;
  end;

  procedure FixEXIFRotate;
  begin
    if FProcessingParams.Rotation = DB_IMAGE_ROTATE_EXIF then
    begin
      if (FData.ID > 0) and (FData.Rotation > 0) then
      begin
        FProcessingParams.Rotation := FData.Rotation;
      end else
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromGraphic(FData.FileName);
          FProcessingParams.Rotation := ExifOrientationToRatation(Ord(ExifData.Orientation));

          if GraphicClass = TRAWImage then
            FProcessingParams.Rotation := DB_IMAGE_ROTATE_0;
        except
          on e : Exception do
            EventLog(e.Message);
        end;
        F(ExifData);
      end;
    end;
  end;

  procedure FixJpegStreamEXIF(Stream : TStream; Width, Height : Integer);
  var
    Jpeg: TJpegImage;
  begin
    ExifData := TExifData.Create;
    try
      Stream.Seek(0, soFromBeginning);
      ExifData.LoadFromGraphic(Stream);
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
          ExifData.SaveToGraphic(Jpeg);
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
    FS: TFileStream;
  begin
    FS := TFileStream.Create(FileName, fmOpenReadWrite);
    try
      FixJpegStreamEXIF(FS, Width, Height);
    finally
      F(FS);
    end;
  end;

  function TrimLeftString(S : string; Count: Integer) : string;
  begin
    Result := S;
    if Length(S) > Count then
      Result := Copy(S, 1, Count);
  end;

const
  MODE_GDI_PLUS_CRYPT = 0;
  MODE_GDI_PLUS       = 1;
  MODE_CUSTOM         = 2;
  MODE_PREVIEW        = 3;

  procedure SaveFile(Mode : Integer);
  var
    W, H: Integer;
    RetryCounter: Integer;

    procedure UpdatePreviewWindow;
    var
      Bitmap : TBitmap;
    begin
      if NewGraphic = nil then
        Exit;
      if FProcessingParams.PreviewOptions.PreviewWidth = 0 then
        Exit;
      if FProcessingParams.PreviewOptions.PreviewHeight = 0 then
        Exit;

      Bitmap := TBitmap.Create;
      try
        AssignGraphic(Bitmap, NewGraphic);
        BitmapParam := TBitmap.Create;
        try
          BitmapParam.PixelFormat := Bitmap.PixelFormat;
          W := Bitmap.Width;
          H := Bitmap.Height;
          ProportionalSize(FProcessingParams.PreviewOptions.PreviewWidth,
            FProcessingParams.PreviewOptions.PreviewHeight, W, H);
          DoResize(W, H, Bitmap, BitmapParam);
          FStringParam := FData.FileName;
          if SynchronizeEx(UpdatePreview) then
          begin
            BitmapParam := nil;
            IsPreviewAvailalbe := True;
          end;

        finally
          F(BitmapParam);
        end;
      finally
        F(Bitmap);
      end;
    end;

  begin
    if AnsiLowerCase(FData.FileName) = AnsiLowerCase(FileName) then
      TLockFiles.Instance.AddLockedFile(FileName, 10000);
    try

      RetryCounter := 0;
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
                  F(FS);
                end;
              end;

            MODE_GDI_PLUS:
              begin
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
                ExifData := TExifData.Create;
                try
                  ExifData.LoadFromGraphic(FData.FileName);
                  NewGraphic.SaveToFile(FileName);
                  if not ExifData.Empty then
                    ExifData.SaveToGraphic(FileName);

                finally
                  F(ExifData);
                end;
                if Password <> '' then
                  CryptGraphicFileV2(FileName, Password, CRYPT_OPTIONS_SAVE_CRC);

              end;

            MODE_PREVIEW:
              //do nothing - preview is updated automatically
          end;

          UpdatePreviewWindow;

          if (GetLastError <> 0) and (GetLastError <> 183) and (GetLastError <> 6) and (GetLastError <> 87) then
            raise Exception.Create('Error code = ' + IntToStr(GetLastError));
          Exit;
        except
          on e : Exception do
          begin
            if not GOM.IsObj(ThreadForm) then
               Exit;

            Inc(RetryCounter);
            if RetryCounter < 5 then
            begin
              Sleep(100);
              Continue;
            end;

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
        if not FProcessingParams.PreviewOptions.GeneratePreview then
        begin
          if FProcessingParams.Rotate then
          begin
            SetRotate(FData.ID, DB_IMAGE_ROTATE_0);
            FData.Rotation := DB_IMAGE_ROTATE_0;
          end;
          UpdateImageRecord(ThreadForm, FData.FileName, FData.ID);
          Synchronize(NotifyDB);
          TLockFiles.Instance.RemoveLockedFile(FileName);
          TLockFiles.Instance.AddLockedFile(FileName, 100);
        end;
      end;
    end;
  end;

  function ClearString(S: string): string;
  var
    I: Integer;
  begin
    for I := 1 to Length(S) do
      if CharInSet(S[I], ['%', ':', '"', '/', '\', '?', '*', '|']) then
        S[I] := '_';
    Result := S;
  end;

begin
  inherited;
  FreeOnTerminate := True;
  FEndProcessing := False;
  NewGraphic := nil;
  IsPreviewAvailalbe := False;
  CoInitialize(nil);
  try
    Ext := ExtractFileExt(FData.FileName);
    GraphicClass := TFileAssociations.Instance.GetGraphicClass(Ext);

    Crypted := ValidCryptGraphicFile(FData.FileName);
    if Crypted then
    begin
      Password := DBKernel.FindPasswordForCryptImageFile(FData.FileName);
      if Password = '' then
        Exit;
    end;

    if FProcessingParams.Convert or not TFileAssociations.Instance.IsConvertableExt(Ext) then
      NewGraphicClass := FProcessingParams.GraphicClass
    else
      NewGraphicClass := GraphicClass;

    if (NewGraphicClass = GraphicClass) then
      Ext := ExtractFileExt(FData.FileName)
    else
      Ext := TFileAssociations.Instance.GetGraphicClassExt(NewGraphicClass);

    FileName := IncludeTrailingPathDelimiter(FProcessingParams.WorkDirectory);
    FileName := FileName + TrimLeftString(GetFileNameWithoutExt(FData.FileName) + ClearString(FProcessingParams.Preffix), 255 - Length(Ext));

    FileName := FileName + Ext;

    //if only rotate and JPEG image -> rotate only with GDI+
    InitGDIPlus;
    if FProcessingParams.Rotate
      and not FProcessingParams.Resize
      and not FProcessingParams.AddWatermark
      and not FProcessingParams.PreviewOptions.GeneratePreview then
    begin
      if not TFileAssociations.Instance.IsConvertableExt(ExtractFileExt(FData.FileName))
        and not FProcessingParams.Convert then
      begin
        if FData.ID > 0 then
        begin
          //file in collection - update rotation attribute
          if (FProcessingParams.Rotation = DB_IMAGE_ROTATE_EXIF) then
          begin
            FixEXIFRotate;
            Rotation := FProcessingParams.Rotation;
          end else
            Rotation := GetNeededRotation(FData.Rotation, FProcessingParams.Rotation);

          if Rotation <> FData.Rotation then
          begin
            SetRotate(FData.ID, Rotation);
            FIntParam := ROtation;
            Synchronize(UpdateDBRotation);
          end;
        end else
        begin
          FixEXIFRotate;
          //add file to collection and set rotation attribute

          FileInfo := FData.Copy;
          try
            FileInfo.Rotation := FProcessingParams.Rotation;
            FileInfo.Include := True;
            FDataParam := FileInfo;
            Synchronize(AddInfoToCollection);
          finally
            F(FileInfo);
          end;
        end;
        Exit;
      end;

      if (NewGraphicClass = GraphicClass)
        and (GraphicClass = TJPEGImage)
        and GDIPlusPresent then
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

    //RAW loads in hasf size for preview
    if (Graphic is TRAWImage) and FProcessingParams.PreviewOptions.GeneratePreview then
      TRAWImage(Graphic).HalfSizeLoad := True;

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
        OriginalWidth := Graphic.Width;
        OriginalHeight := Graphic.Height;

        if FProcessingParams.PreviewOptions.GeneratePreview then
          JPEGScale(Graphic, FProcessingParams.PreviewOptions.PreviewWidth,
            FProcessingParams.PreviewOptions.PreviewHeight);

        AssignGraphic(Original, Graphic);
        F(Graphic);

        if FProcessingParams.Resize then
        begin
          if FProcessingParams.ResizeToSize then
          begin
            Width := FProcessingParams.Width;
            Height := FProcessingParams.Height;
          end else
          begin
            Width := Round(FProcessingParams.PercentResize * OriginalWidth / 100);
            Height := Round(FProcessingParams.PercentResize * OriginalHeight / 100);
          end;

          if FProcessingParams.SaveAspectRation then
          begin
            W := Width;
            H := Height;
            Width := Original.Width;
            Height := Original.Height;
            ProportionalSizeA(W, H, Width, Height);
          end;

          //generate small image
          if FProcessingParams.PreviewOptions.GeneratePreview then
            ProportionalSize(FProcessingParams.PreviewOptions.PreviewWidth,
              FProcessingParams.PreviewOptions.PreviewHeight, Width, Height);

          //resample image
          if Original.PixelFormat = pf32Bit then
          begin
            TmpBitmap := TBitmap.Create;
            try
              TmpBitmap.PixelFormat := pf32Bit;
              DoResize(Width, Height, Original, TmpBitmap);
              Exchange(Original, TmpBitmap);
            finally
              F(TmpBitmap);
            end;
          end else
          begin
            if FProcessingParams.PreviewOptions.GeneratePreview then
              Stretch(Width, Height, {sfBox}sfLanczos3, 0, Original)
            else
              Stretch(Width, Height, sfLanczos3, 0, Original);
          end;
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
            FProcessingParams.WatermarkOptions.Transparenty,
            FProcessingParams.WatermarkOptions.FontName,
            AsyncDrawCallBack, AsyncPrepareBitmapCallBack, AsyncGetFontCallBack);

        if not CheckThread then
          Exit;

        OriginalWidth := Original.Width;
        OriginalHeight := Original.Height;

        //save
        NewGraphic := NewGraphicClass.Create;
        try
          if NewGraphic is TGifImage then
          begin
            TGifImage(NewGraphic).DitherMode := dmFloydSteinberg;
            TGifImage(NewGraphic).ColorReduction := rmQuantize;
          end;
          if (NewGraphicClass <> TPngImage) and (NewGraphicClass <> TBitmap) then
            Original.PixelFormat := pf24Bit;

          AssignToGraphic(NewGraphic, Original);
          F(Graphic);

          SetJPEGGraphicSaveOptions(ConvertImageID, NewGraphic);
          if NewGraphic is TJPEGImage then
            TJpegX(NewGraphic).FreeBitmap;

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
    Synchronize(RefreshItem);
    if FProcessingParams.PreviewOptions.GeneratePreview then
    begin
      if not IsPreviewAvailalbe then
      begin
        BitmapParam := nil;
        OriginalWidth := 0;
        OriginalHeight := 0;
        FStringParam := FData.FileName;
        SynchronizeEx(UpdatePreview);
      end;
    end else
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
  DBKernel.DoIDEvent(ThreadForm, FData.ID, [EventID_Param_Refresh, EventID_Param_Image, EventID_Param_Rotate], EventInfo);
end;

procedure TImageConvertThread.OnEnd;
begin
  TFormSizeResizer(ThreadForm).ThreadEnd(FData, FEndProcessing);
end;

procedure TImageConvertThread.RefreshItem;
var
  EventInfo: TEventValues;
begin
  DBKernel.DoIDEvent(ThreadForm, FData.ID, [EventID_Param_Refresh], EventInfo);
end;

procedure TImageConvertThread.ShowWriteError;
begin
  FDialogResult := Application.MessageBox(PChar(Format(TA('Error writing data on disk: %s.', 'ConvertImage'), [FErrorMessage])), PWideChar(PWideChar(TA('Error'))), MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

procedure TImageConvertThread.SyncDrawCallBack;
begin
  BitmapParam.Canvas.TextRect(FRect, FStringParam, [tfBottom, tfSingleLine]);
end;

procedure TImageConvertThread.SyncGetFont;
begin
  GetObject(BitmapParam.Canvas.Font.Handle, SizeOf(TLogFont), @FLongFont)
end;

procedure TImageConvertThread.SyncPrepareBitmap;
begin
  BitmapParam.Canvas.Font.Handle := FFontParam;
  BitmapParam.Canvas.Font.Color := clBlack;
  FIntParam := BitmapParam.Canvas.TextHeight(FStringParam);
end;

procedure TImageConvertThread.UpdateDBRotation;
var
  EventInfo: TEventValues;
begin
  EventInfo.Name := FData.FileName;
  EventInfo.Rotate := FIntParam;
  DBKernel.DoIDEvent(ThreadForm, FData.ID, [EventID_Param_Rotate], EventInfo);
end;

procedure TImageConvertThread.UpdatePreview;
begin
  TFormSizeResizer(ThreadForm).UpdatePreview(BitmapParam, FStringParam, OriginalWidth, OriginalHeight);
end;

end.
