unit UnitViewerThread;

interface

uses
  uLogger,
  Windows,
  Classes,
  Graphics,
  GraphicCrypt,
  SysUtils,
  Forms,
  GIFImage,
  DB,
  GraphicsBaseTypes,
  CommonDBSupport,
  uTiffImage,
  ActiveX,
  UnitDBCommonGraphics,
  UnitDBCommon,
  uFileUtils,
  JPEG,
  uMemory,
  UnitDBDeclare,
  pngimage,
  uPNGUtils,
  UnitDBkernel,
  uDBThread,
  uGraphicUtils,
  uDBUtils,
  uViewerTypes,
  RAWImage,
  uJpegUtils,
  uBitmapUtils,
  uSettings,
  uFaceDetection,
  uConstants,
  uImageLoader,
  uPortableDeviceUtils,
  uAnimatedJPEG,
  uFormInterfaces;

type
  TViewerThread = class(TDBThread)
  private
    { Private declarations }
    FViewer: TViewerForm;
    FFullImage: Boolean;
    FBeginZoom: Extended;
    FSID: TGUID;
    Graphic: TGraphic;
    PassWord: string;
    FIsEncrypted: Boolean;
    FRealWidth, FRealHeight: Integer;
    FRealZoomScale: Extended;
    Bitmap: TBitmap;
    FIsForward: Boolean;
    FTransparent: Boolean;
    FInfo: TDBPopupMenuInfoRecord;
    FIsNewDBInfo: Boolean;
    FPage: Word;
    FPages: Word;
    TransparentColor: TColor;
    procedure OnLoadImageProgress(ProgressState: TLoadImageProgressState; BytesTotal, BytesComplete: Int64; var Break: Boolean);
  protected
    procedure Execute; override;
    procedure GetPassword;
    procedure GetPasswordSynch;
    procedure SetNOImage;
    procedure SetAnimatedImage;
    procedure SetStaticImage;
    procedure SetNOImageAsynch;
    procedure SetStaticImageAsynch;
    procedure SetAnimatedImageAsynch;
    procedure UpdateRecord;
    procedure ShowLoadingSign;
    procedure FinishDetectionFaces;
  public
    constructor Create(Viewer: TViewerForm; Info: TDBPopupMenuInfoRecord; FullImage: Boolean; BeginZoom: Extended;
      SID: TGUID; IsForward: Boolean; Page: Word);
    destructor Destroy; override;
  end;

implementation

uses
  SlideShow,
  uFaceDetectionThread;

{ TViewerThread }

constructor TViewerThread.Create(Viewer: TViewerForm; Info: TDBPopupMenuInfoRecord; FullImage: Boolean; BeginZoom: Extended; SID : TGUID; IsForward: Boolean; Page: Word);
begin
  inherited Create(Viewer, False);
  Priority := tpHigher;
  FPage := Page;
  FTransparent := False;
  FIsNewDBInfo := False;
  FFullImage := FullImage;
  FBeginZoom := BeginZoom;
  FSID := SID;
  FIsForward := IsForward;
  FViewer := Viewer;
  FInfo := Info.Copy;
  FIsEncrypted := False;
  FPages := 0;
  if Viewer.FullScreenNow then
    TransparentColor := 0
  else
    TransparentColor := Theme.PanelColor;
end;

destructor TViewerThread.Destroy;
begin
  inherited;
end;

procedure TViewerThread.Execute;
var
  PNG: TPNGImage;
  LoadFlags: TImageLoadFlags;
  ImageInfo: ILoadImageInfo;
  CanDetectFaces: Boolean;
begin
  inherited;
  FreeOnTerminate := True;
  CanDetectFaces := False;
  try
    if not IsDevicePath(FInfo.FileName) and not FileExistsEx(FInfo.FileName) then
    begin
      SetNOImageAsynch;
      Exit;
    end;

    GetPassword;
    if FIsEncrypted and (PassWord = '') then
    begin
      SetNOImageAsynch;
      Exit;
    end;

    Graphic := nil;
    ImageInfo := nil;
    try

      LoadFlags := [ilfGraphic, ilfICCProfile, ilfEXIF, ilfUseCache];
      if FFullImage then
        LoadFlags := LoadFlags + [ilfFullRAW];

      try
        if not LoadImageFromPath(FInfo, FPage, Password, LoadFlags, ImageInfo, Screen.Width, Screen.Height, OnLoadImageProgress) then
        begin
          SetNOImageAsynch;
          Exit;
        end;

        FPages := ImageInfo.ImageTotalPages;

        Graphic := ImageInfo.ExtractGraphic;
      except
        on e: Exception do
        begin
          EventLog(e);
          SetNOImageAsynch;
          Exit;
        end;
      end;

      if not ViewerManager.ValidateState(FSID) then Exit;

      if not FInfo.InfoLoaded then
        UpdateRecord;

      FRealWidth := Graphic.Width;
      FRealHeight := Graphic.Height;
      if not FFullImage then
        JPEGScale(Graphic, Screen.Width, Screen.Height);

      FRealZoomScale := 1;
      if Graphic.Width <> 0 then
        FRealZoomScale := FRealWidth / Graphic.Width;
      if Graphic is TRAWImage then
        FRealZoomScale := TRAWImage(Graphic).Width / TRAWImage(Graphic).GraphicWidth;

      if not ViewerManager.ValidateState(FSID) then Exit;

      if IsAnimatedGraphic(Graphic) then
      begin
        SetAnimatedImageAsynch;
      end else
      begin
        Bitmap := TBitmap.Create;
        try
          try
            if Graphic is TPNGImage then
            begin
              FTransparent := True;
              PNG := (Graphic as TPNGImage);
              if PNG.TransparencyMode <> ptmNone then
                LoadPNGImage32bit(PNG, Bitmap, TransparentColor)
              else
                AssignGraphic(Bitmap, Graphic);
            end else
            begin
              if (Graphic is TBitmap) then
              begin
                if PSDTransparent then
                begin
                  if (Graphic as TBitmap).PixelFormat = pf32bit then
                  begin
                    FTransparent := True;
                    LoadBMPImage32bit(Graphic as TBitmap, Bitmap, TransparentColor);
                  end else
                    AssignGraphic(Bitmap, Graphic);
                end else
                  AssignGraphic(Bitmap, Graphic);
              end else
                AssignGraphic(Bitmap, Graphic);
            end;
            Bitmap.PixelFormat := pf24bit;
          except
            SetNOImageAsynch;
            Exit;
          end;

          if not ViewerManager.ValidateState(FSID) then Exit;

          ImageInfo.AppllyICCProfile(Bitmap);

          if not ViewerManager.ValidateState(FSID) then Exit;

          if not ((ilfFullRAW in LoadFlags) and (Graphic is TRAWImage)) then
            ApplyRotate(Bitmap, FInfo.Rotation);

          CanDetectFaces := ViewerManager.ValidateState(FSID);
          if not CanDetectFaces then Exit;

          SetStaticImageAsynch;
        finally
          F(Bitmap);
        end;
      end;
    finally
      if CanDetectFaces and Settings.Readbool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive then
      begin
        if CanDetectFacesOnImage(FInfo.FileName, Graphic) then
        begin
          SynchronizeEx(ShowLoadingSign);
          FaceDetectionDataManager.RequestFaceDetection(FViewer, Graphic, FInfo);
        end else
          FinishDetectionFaces;
      end else
        FinishDetectionFaces;

      F(Graphic);
    end;

  finally
    F(FInfo);
  end;
end;

procedure TViewerThread.FinishDetectionFaces;
begin
  SynchronizeEx(procedure
    begin
      if ViewerForm <> nil then
        ViewerForm.FinishDetectionFaces;
    end
  );
end;

procedure TViewerThread.GetPassword;
begin
  PassWord := '';
  if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
  begin

    FIsEncrypted := True;
    PassWord := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
    if PassWord = '' then
    begin
      if not FIsForward then
        SynchronizeEx(GetPasswordSynch)
      else
      begin
        repeat
          if ViewerForm = nil then
            Break;
          if not IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) then
            Break;
          if not ViewerForm.ForwardThreadExists then
            Break;
          if ViewerForm.ForwardThreadNeeds then
          begin
            SynchronizeEx(GetPasswordSynch);
            Exit;
          end;
          Sleep(10);
        until False;
      end;
    end;
  end else
    FIsEncrypted := False;
end;

procedure TViewerThread.GetPasswordSynch;
begin
  if not FViewer.FullScreenNow then
    PassWord := RequestPasswordForm.ForImage(FInfo.FileName);
end;

procedure TViewerThread.OnLoadImageProgress(
  ProgressState: TLoadImageProgressState; BytesTotal, BytesComplete: Int64;
  var Break: Boolean);
begin
  if not ViewerManager.ValidateState(FSID) then
    Break := True;
end;

procedure TViewerThread.SetAnimatedImage;
begin
  if ViewerForm <> nil then
    if (IsEqualGUID(ViewerForm.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) and FIsForward) then
    begin
      ViewerForm.RealImageHeight := FRealHeight;
      ViewerForm.RealImageWidth := FRealWidth;
      ViewerForm.RealZoomInc := FRealZoomScale;
      if FIsNewDBInfo then
        ViewerForm.UpdateInfo(FSID, FInfo)
      else if ViewerForm.Item.ID = 0 then
        ViewerForm.Item.Rotation := FInfo.Rotation;
      ViewerForm.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
      ViewerForm.SetAnimatedImage(Graphic);
      Pointer(Graphic) := nil;
    end;
end;

procedure TViewerThread.SetAnimatedImageAsynch;
begin
  if not FIsForward then
  begin
    SynchronizeEx(SetAnimatedImage);
    Exit;
  end else
  begin
    repeat
      if ViewerForm = nil then
        Break;
      if not IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) then
        Break;
      if not ViewerForm.ForwardThreadExists then
        Break;
      if ViewerForm.ForwardThreadNeeds then
      begin
        SynchronizeEx(SetAnimatedImage);
        Exit;
      end;
      Sleep(10);
    until False;
  end;
end;

procedure TViewerThread.SetNOImage;
begin
  if ViewerForm <> nil then
    if (IsEqualGUID(ViewerForm.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) and FIsForward) then
    begin
      ViewerForm.RealImageHeight := FRealHeight;
      ViewerForm.RealImageWidth := FRealWidth;
      ViewerForm.RealZoomInc := FRealZoomScale;
      ViewerForm.Item.Encrypted := FIsEncrypted;
      if FIsNewDBInfo then
        ViewerForm.UpdateInfo(FSID, FInfo);
      ViewerForm.Item.Rotation := DB_IMAGE_ROTATE_0;
      ViewerForm.ImageExists := False;
      ViewerForm.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
      ViewerForm.LoadingFailed(FInfo.FileName);
    end;
end;

procedure TViewerThread.SetNOImageAsynch;
begin
  if not FIsForward then
  begin
    SynchronizeEx(SetNOImage);
    Exit;
  end else
  begin
    repeat
      if ViewerForm = nil then
        Break;
      if not IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) then
        Break;
      if not ViewerForm.ForwardThreadExists then
        Break;
      if ViewerForm.ForwardThreadNeeds then
      begin
        SynchronizeEx(SetNOImage);
        Exit;
      end;
      Sleep(10);
    until False;
  end;
end;

procedure TViewerThread.SetStaticImage;
begin
  if ViewerForm <> nil then
    if (IsEqualGUID(ViewerForm.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) and FIsForward) then
    begin
      ViewerForm.RealImageHeight := FRealHeight;
      ViewerForm.RealImageWidth := FRealWidth;
      ViewerForm.RealZoomInc := FRealZoomScale;
      ViewerForm.Item.Encrypted := FIsEncrypted;
      if FIsNewDBInfo then
        ViewerForm.UpdateInfo(FSID, FInfo)
      else if ViewerForm.Item.ID = 0 then
        ViewerForm.Item.Rotation := FInfo.Rotation;
           
      ViewerForm.Item.Width := FRealWidth;
      ViewerForm.Item.Height := FRealHeight;
      ViewerForm.SetFullImageState(FFullImage, FBeginZoom, FPages, FPage);
      ViewerForm.SetStaticImage(Bitmap, FTransparent);
      Bitmap := nil;
    end else
      F(Bitmap);
end;

procedure TViewerThread.SetStaticImageAsynch;

  procedure SetImage;
  begin
    if not SynchronizeEx(SetStaticImage) then
      F(Bitmap);
  end;

begin
  if not FIsForward then
  begin
    SetImage;
    Exit;
  end else
  begin
    repeat
      if ViewerForm = nil then
        Break;

      ViewerForm.ForwardThreadReady := True;

      if not IsEqualGUID(ViewerForm.ForwardThreadSID, FSID) then
        Break;
      if not ViewerForm.ForwardThreadExists then
        Break;
      if ViewerForm.ForwardThreadNeeds then
      begin
        SetImage;
        Exit;
      end;
      Sleep(10);
    until False;
    F(Bitmap);
  end;
end;

procedure TViewerThread.ShowLoadingSign;
begin
  if ViewerForm <> nil then
    ViewerForm.UpdateFaceDetectionState;
end;

procedure TViewerThread.UpdateRecord;
var
  Query: TDataSet;
  FileName: string;
begin
  CoInitializeEx(nil, COM_MODE);
  try
    FileName := FInfo.FileName;
    Query := GetQuery;
    try
      ReadOnlyQuery(Query);
      Query.Active := False;
      SetSQL(Query, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FInfo.FileName, True))
          + ' AND FFileName LIKE :FFileName');
      SetStrParam(Query, 0, AnsiLowerCase(FInfo.FileName));
      Query.Active := True;
      if Query.RecordCount <> 0 then
      begin      
        F(FInfo);
        FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
        FInfo.ReadFromDS(Query);
        FIsNewDBInfo := True;
      end;
      Query.Close;
    finally
      FreeDS(Query);
    end;
  finally
    CoUnInitialize;
  end;
end;

end.
