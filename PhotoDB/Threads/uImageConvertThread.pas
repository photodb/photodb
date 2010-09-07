unit uImageConvertThread;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, Dolphin_db, GraphicCrypt,
  ImageConverting, Exif, uLogger, GraphicEx;

type
  TImageConvertThread = class(TThread)
  private
    FOwner : TForm;
    FData: TDBPopupMenuInfoRecord;
    FProcessingParams : TProcessingParams;
    { Private declarations }
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
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
  Password : string;
  Original : TBitmap;
  Exif : TExif;
begin
  FreeOnTerminate := True;
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

        //resample image
        Stretch(100, 100, sfLanczos3, 0, Original);

        //apply rotation to image - quick process
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

        //add watermark
        //TODO:

        //save

      finally
        Original.Free;
      end;
    finally
      Graphic.Free;
    end;
  finally
    FData.Free;
    Synchronize(
      procedure
      begin
        TFormSizeResizer(FOwner).ThreadEnd;
      end
      );
  end;
end;

end.
