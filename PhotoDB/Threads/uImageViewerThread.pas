unit uImageViewerThread;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,

  UnitDBDeclare,
  UnitDBKernel,
  RAWImage,
  GraphicCrypt,

  uTime,
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
  uExifInfo,
  uSettings,
  uAnimatedJPEG,
  uProgramStatInfo,
  uSessionPasswords,
  uFaceDetection,
  uFaceDetectionThread;

type
  TImageViewerThread = class(TDBThread)
  private
    FOwnerControl: IImageViewer;
    FThreadId: TGUID;
    FInfo: TMediaItem;
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

    FGraphic: TGraphic;
    FBitmap: TBitmap;
    FExifInfo: IExifInfo;
    procedure SetStaticImage;
    procedure SetAnimatedImageAsynch;
    procedure SetNOImageAsynch(ErrorMessage: string);
    procedure FinishDetectionFaces;
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; OwnerControl: IImageViewer; ThreadId: TGUID;
     Info: TMediaItem; DisplaySize: TSize; IsPreview: Boolean; PageNumber: Integer);
    destructor Destroy; override;
  end;

implementation

{ TImageViewerThread }

constructor TImageViewerThread.Create(OwnerForm: TThreadForm;
  OwnerControl: IImageViewer; ThreadId: TGUID; Info: TMediaItem;
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
  PNG: TPNGImage;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try

      Password := '';
      FTotalPages := 1;
      FRealZoomScale := 0;
      FIsTransparent := False;

      if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
      begin
        Password := SessionPasswords.FindForFile(FInfo.FileName);
        if Password = '' then
        begin
          SetNOImageAsynch('');
          Exit;
        end;
      end;

      FGraphic := nil;
      ImageInfo := nil;
      FExifInfo := nil;
      try

        LoadFlags := [ilfGraphic, ilfICCProfile, ilfPassword, ilfEXIF, ilfUseCache];

        try
          if not LoadImageFromPath(FInfo, FPageNumber, Password, LoadFlags, ImageInfo, FDisplaySize.cx, FDisplaySize.cy) then
          begin
            SetNOImageAsynch('');
            Exit;
          end;

          FTotalPages := ImageInfo.ImageTotalPages;

          FGraphic := ImageInfo.ExtractGraphic;

          TW.I.Start('Start EXIF reading');
          FillExifInfo(ImageInfo.ExifData, ImageInfo.RawExif, FExifInfo);
          TW.I.Start('End EXIF reading');
        except
          on e: Exception do
          begin
            EventLog(e);
            SetNOImageAsynch(e.Message);
            Exit;
          end;
        end;

        FRealWidth := FGraphic.Width;
        FRealHeight := FGraphic.Height;
        if FIsPreview then
          JPEGScale(FGraphic, FDisplaySize.cx, FDisplaySize.cy);

        //statistics
        if FGraphic is TAnimatedJPEG then
          ProgramStatistics.Image3dUsed;

        FRealZoomScale := 1;
        if FGraphic.Width <> 0 then
          FRealZoomScale := FRealWidth / FGraphic.Width;
        if FGraphic is TRAWImage then
          FRealZoomScale := TRAWImage(FGraphic).Width / TRAWImage(FGraphic).GraphicWidth;

        if IsAnimatedGraphic(FGraphic) then
        begin
          SynchronizeEx(SetAnimatedImageAsynch);
        end else
        begin
          FBitmap := TBitmap.Create;
          try
            try
              if FGraphic is TPNGImage then
              begin
                FIsTransparent := True;
                PNG := (FGraphic as TPNGImage);
                if PNG.TransparencyMode <> ptmNone then
                  LoadPNGImage32bit(PNG, FBitmap, FTransparentColor)
                else
                  AssignGraphic(FBitmap, FGraphic);
              end else
              begin
                if (FGraphic is TBitmap) then
                begin
                  if PSDTransparent then
                  begin
                    if (FGraphic as TBitmap).PixelFormat = pf32bit then
                    begin
                      FIsTransparent := True;
                      LoadBMPImage32bit(FGraphic as TBitmap, FBitmap, FTransparentColor);
                    end else
                      AssignGraphic(FBitmap, FGraphic);
                  end else
                    AssignGraphic(FBitmap, FGraphic);
                end else
                  AssignGraphic(FBitmap, FGraphic);
              end;
              FBitmap.PixelFormat := pf24bit;
            except
              on e: Exception do
              begin
                SetNOImageAsynch(e.Message);
                Exit;
              end;
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
        if AppSettings.Readbool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive then
        begin
          if CanDetectFacesOnImage(FInfo.FileName, FGraphic) then
            FaceDetectionDataManager.RequestFaceDetection(FOwnerControl.GetObject, DBKernel.DBContext, FGraphic, FInfo)
          else
            FinishDetectionFaces;
        end else
          FinishDetectionFaces;
        F(FGraphic);
      end;
    except
      on Ex: Exception do
      begin
        EventLog(Ex);
        SetNOImageAsynch(Ex.Message);
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TImageViewerThread.FinishDetectionFaces;
begin
  SynchronizeEx(procedure
    begin
      if FOwnerControl <> nil then
        FOwnerControl.FinishDetectionFaces;
    end
  );
end;

procedure TImageViewerThread.SetAnimatedImageAsynch;
begin
  if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
  begin
    {if FIsNewDBInfo then
      ViewerForm.UpdateInfo(FSID, FInfo);
    ViewerForm.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
    ViewerForm.SetAnimatedImage(Graphic);   }
    FOwnerControl.SetAnimatedImage(FGraphic, FRealWidth, FRealHeight, FInfo.Rotation, FRealZoomScale, FExifInfo);
    Pointer(FGraphic) := nil;
  end;
end;

procedure TImageViewerThread.SetNOImageAsynch(ErrorMessage: string);
begin
  SynchronizeEx(
    procedure
    begin
      if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
        FOwnerControl.FailedToLoadImage(ErrorMessage);
    end
  );
end;

procedure TImageViewerThread.SetStaticImage;
begin
  if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
  begin
    {ViewerForm.Item.Encrypted := FIsEncrypted;
    if FIsNewDBInfo then
      ViewerForm.UpdateInfo(FSID, FInfo);
    ViewerForm.SetFullImageState(FFullImage, FBeginZoom, FPages, FPage);
    ViewerForm.SetStaticImage(Bitmap, FTransparent);}
    FOwnerControl.SetStaticImage(FBitmap, FRealWidth, FRealHeight, FInfo.Rotation, FRealZoomScale, FExifInfo);
    FBitmap := nil;
  end else
    F(FBitmap);
end;

end.
