unit uShareImagesThread;

interface

uses
  uMemory,
  Winapi.Windows,
  System.SysUtils,
  uThreadEx,
  uThreadForm,
  Vcl.Graphics,
  UnitDBDeclare,
  uAssociations,
  Winapi.ActiveX,
  uPortableDeviceUtils,
  GraphicCrypt,
  UnitDBKernel,
  RAWImage,
  uJpegUtils,
  uGraphicUtils,
  GraphicEx,
  uSettings,
  uBitmapUtils,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngImage;

type
  TShareImagesThread = class(TThreadEx)
  private
    FData: TDBPopupMenuInfoRecord;
    FIsPreview: Boolean;
    procedure ProcessItem(Data: TDBPopupMenuInfoRecord);
    procedure ProcessImage(Data: TDBPopupMenuInfoRecord);
    procedure ProcessVideo(Data: TDBPopupMenuInfoRecord);
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; IsPreview: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  uFormSharePhotos,
  UnitJPEGOptions;

{ TShareImagesThread }

constructor TShareImagesThread.Create(AOwnerForm: TThreadForm; IsPreview: Boolean);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FIsPreview := IsPreview;
  FData := nil;
end;

destructor TShareImagesThread.Destroy;
begin
  F(FData);
  inherited;
end;

procedure TShareImagesThread.Execute;
begin
  FreeOnTerminate := True;
  //for video previews
  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  try
    if FIsPreview then
    begin
      repeat
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).GetDataForPreview(FData)
          end
        );
        if FData <> nil then
          ProcessItem(FData);

      until FData = nil;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TShareImagesThread.ProcessItem(Data: TDBPopupMenuInfoRecord);
begin
  if CanShareVideo(Data.FileName) then
    ProcessVideo(Data)
  else
    ProcessImage(Data);
end;

procedure TShareImagesThread.ProcessImage(Data: TDBPopupMenuInfoRecord);
var
  Ext, Password: string;
  GraphicClass: TGraphicClass;
  Enrypted: Boolean;
  Graphic, NewGraphic: TGraphic;
  Original: TBitmap;
  Width, Height, W, H: Integer;
  IsJpegImageFormat,
  ResizeImage: Boolean;

begin
  Width := 0;
  Height := 0;
  ResizeImage := Settings.ReadBool('Share', 'ResizeImage', True);
  if ResizeImage then
  begin
    Width := Settings.ReadInteger('Share', 'ImageWidth', 1920);
    Height := Settings.ReadInteger('Share', 'ImageWidth', 1920);
  end;
  if FIsPreview then
  begin
    Width := 32;
    Height := 32;
  end;

  IsJpegImageFormat := Settings.ReadInteger('Share', 'ImageFormat', 0) = 0;

  Ext := ExtractFileExt(Data.FileName);
  GraphicClass := TFileAssociations.Instance.GetGraphicClass(Ext);

  if GraphicClass = nil then
    Exit;

  Enrypted := not IsDevicePath(Data.FileName) and ValidCryptGraphicFile(Data.FileName);
  if Enrypted then
  begin
    Password := DBKernel.FindPasswordForCryptImageFile(Data.FileName);
    if Password = '' then
      Exit;
  end;

  Graphic := GraphicClass.Create;
  try

    //RAW loads sd preview
    if Graphic is TRAWImage then
      TRAWImage(Graphic).IsPreview := True;

    if Enrypted then
    begin
      F(Graphic);

      Graphic := DeCryptGraphicFile(Data.FileName, Password);
    end else if not IsDevicePath(Data.FileName) then
      Graphic.LoadFromFile(Data.FileName)
    else
      Graphic.LoadFromDevice(Data.FileName);

    W := Graphic.Width;
    H := Graphic.Height;
    ProportionalSize(Width, Height, W, H);

    if (Width > 0) and (Height > 0) then
      JPEGScale(Graphic, W, H);

    Original := TBitmap.Create;
    try
      AssignGraphic(Original, Graphic);
      F(Graphic);

      if (Width > 0) and (Height > 0) then
        Stretch(W, H, sfLanczos3, 0, Original);

      if FIsPreview then
      begin
        SynchronizeEx(
          procedure
          begin
            TFormSharePhotos(OwnerForm).UpdatePreview(Data, Original);
          end
        );
      end else
      begin
        if IsJpegImageFormat then
          NewGraphic := TJpegImage.Create
        else
          NewGraphic := TPngImage.Create;
        try
          AssignToGraphic(NewGraphic, Original);
          F(Original);

          SetJPEGGraphicSaveOptions('ShareImages', NewGraphic);
          if NewGraphic is TJPEGImage then
            FreeJpegBitmap(TJPEGImage(NewGraphic));

          //TODO: save and update EXIF
          //TODO: post image
        finally
          F(NewGraphic);
        end;
      end;

    finally
      F(Original);
    end;
  finally
    F(Graphic);
  end;
end;

procedure TShareImagesThread.ProcessVideo(Data: TDBPopupMenuInfoRecord);
begin

end;

end.
