unit uImageConvertThread;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, Dolphin_db, GraphicCrypt,
  ImageConverting, Exif, uLogger, GraphicEx, UnitDBCommon, uMemory, uFileUtils,
  PngImage, uGOM, uDBForm, Dialogs, UnitDBDeclare, JPEG, UnitJPEGOptions,
  UnitDBCommonGraphics;

type
  TImageConvertThread = class(TThread)
  private
    { Private declarations }
    FOwner : TForm;
    FData: TDBPopupMenuInfoRecord;
    FProcessingParams : TProcessingParams;
    FDialogResult : Integer;
    FEndProcessing : Boolean;
    FErrorMessage : string;
    procedure ShowWriteError;
    procedure OnEnd;
    procedure NotifyDB;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TForm; AData : TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
  end;

implementation

uses UnitSizeResizerForm;

{ TImageConvertThread }

constructor TImageConvertThread.Create(AOwner : TForm; AData: TDBPopupMenuInfoRecord; AProcessingParams : TProcessingParams);
begin
  inherited Create(False);
  FOwner := AOwner;
  FData := AData;
  FProcessingParams := AProcessingParams;
end;

procedure TImageConvertThread.Execute;
var
  Graphic, NewGraphic : TGraphic;
  GraphicClass, NewGraphicClass : TGraphicClass;
  Password : string;
  Extension : string;
  FileName : string;
  Original : TBitmap;
  Exif : TExif;
  W, H, Width, Height : Integer;
begin
  FreeOnTerminate := True;
  FEndProcessing := False;
  try
    GraphicClass := GetGraphicClass(ExtractFileExt(FData.FileName), False);
    if GraphicClass = nil then
      Exit;

    Graphic := GraphicClass.Create;
    try
      if ValidCryptGraphicFile(FData.FileName) then
      begin
        Password := DBKernel.FindPasswordForCryptImageFile(FData.FileName);
        if Password = '' then
          Exit;

        //TODO: refactor
        Graphic.Free;
        Graphic := nil;

        Graphic := DeCryptGraphicFile(FData.FileName, Password);
      end else
        Graphic.LoadFromFile(FData.FileName);

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

        //apply rotation to image - quick process
        if FProcessingParams.Rotate then
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

          if FProcessingParams.Rotation <> DB_IMAGE_ROTATE_UNKNOWN then
            ApplyRotate(Original, FProcessingParams.Rotation);
        end;

        //add watermark
        if FProcessingParams.AddWatermark then
          DrawWatermark(Original, FProcessingParams.WatermarkOptions.BlockCountX,
            FProcessingParams.WatermarkOptions.BlockCountY,
            FProcessingParams.WatermarkOptions.Text, -1,
            FProcessingParams.WatermarkOptions.Color,
            FProcessingParams.WatermarkOptions.Transparenty);

        //save
        if FProcessingParams.GraphicClass = nil then
          NewGraphicClass := GraphicClass
        else
          NewGraphicClass := FProcessingParams.GraphicClass;

        NewGraphic := NewGraphicClass.Create;
        try
          NewGraphic.Assign(Original);
          F(Graphic);

          SetJPEGGraphicSaveOptions(ConvertImageID, NewGraphic);

          FileName := FProcessingParams.WorkDirectory;
          FileName := FileName + '\' + GetFileNameWithoutExt(FData.FileName) + FProcessingParams.Preffix;
          FileName := FileName + GetGraphicExtForSave(NewGraphicClass);

          Repeat
            try
              SetLastError(0);

              NewGraphic.SaveToFile(FileName);

              if Password <> '' then
                CryptGraphicFileV2(FileName, Password, CRYPT_OPTIONS_SAVE_CRC);

              if (GetLastError <> 0) and (GetLastError <> 183) and (GetLastError <> 6) then
                raise Exception.Create('Error code = ' + IntToStr(GetLastError));
              Exit;
            except
              on e : Exception do
              begin

                if not GOM.IsObj(FOwner) then
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
    F(FData);
    Synchronize(OnEnd);
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
  if not GOM.IsObj(FOwner) then
     Exit;
  TFormSizeResizer(FOwner).ThreadEnd(FEndProcessing);
end;

procedure TImageConvertThread.ShowWriteError;
begin
  if not GOM.IsObj(FOwner) then
    Exit;

  FDialogResult := Application.MessageBox(PWideChar(Format(TDBForm(FOwner).L('Error writing data on disk: %s.'), [FErrorMessage])), PWideChar(PWideChar(TDBForm(FOwner).L('Error'))), MB_ICONERROR or MB_ABORTRETRYIGNORE);
end;

end.
