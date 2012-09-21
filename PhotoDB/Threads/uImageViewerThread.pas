unit uImageViewerThread;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,
  UnitDBDeclare,
  UnitDBKernel,
  RAWImage,
  uMemory,
  uConstants,
  uThreadForm,
  uLogger,
  uIImageViewer,
  uDBThread,
  uImageLoader,
  uPortableDeviceUtils,
  uBitmapUtils,
  uGraphicUtils,
  uPNGUtils,
  uJpegUtils,
  GraphicCrypt,
  uSettings,
  uFaceDetection,
  uFaceDetectionThread;

type
  TImageViewerThread = class(TDBThread)
  private
    FOwnerControl: IImageViewer;
    FThreadId: TGUID;
    FInfo: TDBPopupMenuInfoRecord;
    FDisplaySize: TSize;
    FIsPreview: Boolean;
    FPageNumber: Integer;
    FTotalPages: Integer;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FRealZoomScale: Double;
    FIsTransparent: Boolean;

    //TODO; remove
    FTransparentColor: TColor;

    FBitmap: TBitmap;
    procedure SetStaticImage;
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; OwnerControl: IImageViewer; ThreadId: TGUID;
     Info: TDBPopupMenuInfoRecord; DisplaySize: TSize; IsPreview: Boolean; PageNumber: Integer);
    destructor Destroy; override;
  end;

implementation

{ TImageViewerThread }

constructor TImageViewerThread.Create(OwnerForm: TThreadForm;
  OwnerControl: IImageViewer; ThreadId: TGUID; Info: TDBPopupMenuInfoRecord;
  DisplaySize: TSize; IsPreview: Boolean; PageNumber: Integer);
begin
  if Info = nil then
    raise EArgumentNilException.Create('Info is nil!');

  inherited Create(OwnerForm, False);

  FOwnerControl := OwnerControl;
  FThreadId := ThreadId;
  FInfo := Info.Copy;
  FDisplaySize := DisplaySize;
  FIsPreview := IsPreview;
  FPageNumber := PageNumber;

  //TODO: remove
  FTransparentColor := Theme.PanelColor;
end;

destructor TImageViewerThread.Destroy;
begin
  F(FInfo);
  inherited;
end;

procedure TImageViewerThread.Execute;
var
  Password: string;
  LoadFlags: TImageLoadFlags;
  ImageInfo: ILoadImageInfo;
  Graphic: TGraphic;
  PNG: TPNGImage;
begin
  FreeOnTerminate := True;

  Password := '';
  FTotalPages := 1;
  FRealZoomScale := 0;
  FIsTransparent := False;

  if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
  begin
    Password := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
    if Password = '' then
    begin
      //TODO:
      Exit;
    end;
  end;


  Graphic := nil;
  ImageInfo := nil;
  try

    LoadFlags := [ilfGraphic, ilfICCProfile, ilfPassword, ilfEXIF, ilfUseCache];

    try
      if not LoadImageFromPath(FInfo, FPageNumber, Password, LoadFlags, ImageInfo, FDisplaySize.cx, FDisplaySize.cy) then
      begin
        //TODO: SetNOImageAsynch;
        Exit;
      end;

      FTotalPages := ImageInfo.ImageTotalPages;

      Graphic := ImageInfo.ExtractGraphic;
    except
      on e: Exception do
      begin
        EventLog(e);
        //TODO: SetNOImageAsynch;
        Exit;
      end;
    end;

    FRealWidth := Graphic.Width;
    FRealHeight := Graphic.Height;
    if FIsPreview then
      JPEGScale(Graphic, FDisplaySize.cx, FDisplaySize.cy);


    FRealZoomScale := 1;
    if Graphic.Width <> 0 then
      FRealZoomScale := FRealWidth / Graphic.Width;
    if Graphic is TRAWImage then
      FRealZoomScale := TRAWImage(Graphic).Width / TRAWImage(Graphic).GraphicWidth;

    if IsAnimatedGraphic(Graphic) then
    begin
      //TODO: SetAnimatedImageAsynch;
    end else
    begin
      FBitmap := TBitmap.Create;
      try
        try
          if Graphic is TPNGImage then
          begin
            FIsTransparent := True;
            PNG := (Graphic as TPNGImage);
            if PNG.TransparencyMode <> ptmNone then
              LoadPNGImage32bit(PNG, FBitmap, FTransparentColor)
            else
              AssignGraphic(FBitmap, Graphic);
          end else
          begin
            if (Graphic is TBitmap) then
            begin
              if PSDTransparent then
              begin
                if (Graphic as TBitmap).PixelFormat = pf32bit then
                begin
                  FIsTransparent := True;
                  LoadBMPImage32bit(Graphic as TBitmap, FBitmap, FTransparentColor);
                end else
                  AssignGraphic(FBitmap, Graphic);
              end else
                AssignGraphic(FBitmap, Graphic);
            end else
              AssignGraphic(FBitmap, Graphic);
          end;
          FBitmap.PixelFormat := pf24bit;
        except
          //TODO: SetNOImageAsynch;
          Exit;
        end;

        ImageInfo.AppllyICCProfile(FBitmap);

        ApplyRotate(FBitmap, FInfo.Rotation);

        if not SynchronizeEx(SetStaticImage) then
          F(FBitmap);

      finally
        F(FBitmap);
      end;
    end;
  finally
    //TODO:
    {if Settings.Readbool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive then
    begin
      if CanDetectFacesOnImage(FInfo.FileName, Graphic) then
      begin
        SynchronizeEx(ShowLoadingSign);
        FaceDetectionDataManager.RequestFaceDetection(FOwnerControl, Graphic, FInfo);
      end else
        FinishDetectionFaces;
    end else
      FinishDetectionFaces;}
    F(Graphic);
  end;
end;

procedure TImageViewerThread.SetStaticImage;
begin
  if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
    begin
      {ViewerForm.RealImageHeight := FRealHeight;
      ViewerForm.RealImageWidth := FRealWidth;
      ViewerForm.RealZoomInc := FRealZoomScale;
      ViewerForm.Item.Encrypted := FIsEncrypted;
      if FIsNewDBInfo then
        ViewerForm.UpdateInfo(FSID, FInfo);
      ViewerForm.Item.Width := FRealWidth;
      ViewerForm.Item.Height := FRealHeight;
      ViewerForm.SetFullImageState(FFullImage, FBeginZoom, FPages, FPage);
      ViewerForm.SetStaticImage(Bitmap, FTransparent);}

      FOwnerControl.SetStaticImage(FBitmap, FRealWidth, FRealHeight);

      FBitmap := nil;
    end else
      F(FBitmap);
end;

end.
