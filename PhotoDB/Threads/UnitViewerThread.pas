unit UnitViewerThread;

interface

uses
  Windows, Classes, Graphics, GraphicCrypt, SysUtils, Forms,
  GIFImage, DB, GraphicsBaseTypes, CommonDBSupport, uTiffImage,
  ActiveX, UnitDBCommonGraphics, UnitDBCommon, uFileUtils, JPEG,
  uMemory, UnitDBDeclare, pngimage, uPNGUtils, UnitDBkernel, uDBThread,
  uGraphicUtils, uDBUtils, uViewerTypes, uAssociations, RAWImage,
  uExifUtils, uJpegUtils, uBitmapUtils, uSettings;

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
    FBooleanResult: Boolean;
    FInfo: TDBPopupMenuInfoRecord;
    FIsNewDBInfo: Boolean;
    FPage: Word;
    FPages: Word;
    TransparentColor : TColor;
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
    function TestThread : Boolean;
    procedure TestThreadSynch;
    procedure UpdateRecord;
  public
    constructor Create(Viewer: TViewerForm; Info: TDBPopupMenuInfoRecord; FullImage: Boolean; BeginZoom: Extended;
      SID: TGUID; IsForward: Boolean; Page: Word);
    destructor Destroy; override;
  end;

implementation

uses
  UnitPasswordForm, SlideShow, uFaceDetectionThread;

{ TViewerThread }

constructor TViewerThread.Create(Viewer: TViewerForm; Info: TDBPopupMenuInfoRecord; FullImage: Boolean; BeginZoom: Extended; SID : TGUID; IsForward: Boolean; Page: Word);
begin
  inherited Create(Viewer, False);
  FPage := Page;
  FIsNewDBInfo := False;
  FFullImage := FullImage;
  FBeginZoom := BeginZoom;
  FSID := SID;
  FIsForward := IsForward;
  FViewer := Viewer;
  FInfo := Info.Copy;
  FIsEncrypted := False;
  if Viewer.FullScreenNow then
    TransparentColor := 0
  else
    TransparentColor := ClBtnFace;
end;

destructor TViewerThread.Destroy;
begin

  inherited;
end;

procedure TViewerThread.Execute;
var
  PNG: TPNGImage;
  GraphicClass: TGraphicClass;
begin
  inherited;
  FreeOnTerminate := True;
  FPages := 0;
  Priority := TpHigher;
  try
    FTransparent := False;
    if not FileExistsEx(FInfo.FileName) then
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
    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FInfo.FileName));
    if GraphicClass = nil then
    begin
      SetNOImageAsynch;
      Exit;
    end;

    Graphic := GraphicClass.Create;
    try

      if Graphic is TRAWImage then
        TRAWImage(Graphic).IsPreview := not FFullImage;

      try
        if PassWord <> '' then
        begin
          F(Graphic);
          Graphic := DeCryptGraphicFileEx(FInfo.FileName, PassWord, FPages, FFullImage, FPage);
        end else
        begin
          if FIsEncrypted and (PassWord = '') then
          begin
            SetNOImageAsynch;
            Exit;
          end else
          begin
            if Graphic is TTiffImage then
            begin
              (Graphic as TTiffImage).Page := FPage;
              (Graphic as TTiffImage).LoadFromFile(FInfo.FileName);
            end
            else
              Graphic.LoadFromFile(FInfo.FileName);
          end;
        end;
      except
        SetNOImageAsynch;
        Exit;
      end;

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

      if Graphic is TGIFImage then
      begin
        SetAnimatedImageAsynch;
      end else
      begin
        Bitmap := TBitmap.Create;
        try
          try
            if PassWord = '' then
              if Graphic is TTiffImage then
                FPages := (Graphic as TTiffImage).Pages;

            if Graphic is TPNGImage then
            begin
              FTransparent := True;
              PNG := (Graphic as TPNGImage);
              if PNG.TransparencyMode <> PtmNone then
              begin
                LoadPNGImage32bit(PNG, Bitmap, TransparentColor);
              end else
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

          if FInfo.ID = 0 then
          begin
            if FInfo.Rotation = 0 then
              FInfo.Rotation := GetExifRotate(FInfo.FileName);

            if (Graphic is TRAWImage) then
              FInfo.Rotation := ExifDisplayButNotRotate(FInfo.Rotation);
          end;

          ApplyRotate(Bitmap, FInfo.Rotation);
          SetStaticImageAsynch;
        finally
          F(Bitmap);
        end;
      end;
    finally
      if Settings.Readbool('FaceDetection', 'Enabled', True) then
        FaceDetectionDataManager.RequestFaceDetection(FViewer, Graphic, FInfo.FileName, FInfo.ID);
      F(Graphic);
    end;

  finally
    F(FInfo);
  end;
end;

procedure TViewerThread.GetPassword;
begin
  PassWord := '';
  if ValidCryptGraphicFile(FInfo.FileName) then
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
          if Viewer = nil then
            Break;
          if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then
            Break;
          if not Viewer.ForwardThreadExists then
            Break;
          if Viewer.ForwardThreadNeeds then
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
    PassWord := GetImagePasswordFromUser(FInfo.FileName);
end;

procedure TViewerThread.SetAnimatedImage;
begin
  if Viewer <> nil then
    if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then
    begin
      Viewer.RealImageHeight := FRealHeight;
      Viewer.RealImageWidth := FRealWidth;
      Viewer.RealZoomInc := FRealZoomScale;
      if FIsNewDBInfo then
        Viewer.UpdateInfo(FSID, FInfo);
      Viewer.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
      Viewer.SetAnimatedImage(Graphic);
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
      if Viewer = nil then
        Break;
      if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then
        Break;
      if not Viewer.ForwardThreadExists then
        Break;
      if Viewer.ForwardThreadNeeds then
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
  if Viewer <> nil then
    if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then
    begin
      Viewer.RealImageHeight := FRealHeight;
      Viewer.RealImageWidth := FRealWidth;
      Viewer.RealZoomInc := FRealZoomScale;
      Viewer.Item.Crypted := FIsEncrypted;
      if FIsNewDBInfo then
        Viewer.UpdateInfo(FSID, FInfo);
      Viewer.ImageExists := False;
      Viewer.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
      Viewer.LoadingFailed(FInfo.FileName);
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
      if Viewer = nil then
        Break;
      if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then
        Break;
      if not Viewer.ForwardThreadExists then
        Break;
      if Viewer.ForwardThreadNeeds then
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
  if Viewer <> nil then
    if (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or
      (IsEqualGUID(Viewer.ForwardThreadSID, FSID) and FIsForward) then
    begin
      Viewer.RealImageHeight := FRealHeight;
      Viewer.RealImageWidth := FRealWidth;
      Viewer.RealZoomInc := FRealZoomScale;
      Viewer.Item.Crypted := FIsEncrypted;
      if FIsNewDBInfo then
        Viewer.UpdateInfo(FSID, FInfo);
      Viewer.Item.Width := FRealWidth;
      Viewer.Item.Height := FRealHeight;
      Viewer.SetFullImageState(FFullImage, FBeginZoom, FPages, FPage);
      Viewer.SetStaticImage(Bitmap, FTransparent);
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
      if Viewer = nil then
        Break;
      if not IsEqualGUID(Viewer.ForwardThreadSID, FSID) then
        Break;
      if not Viewer.ForwardThreadExists then
        Break;
      if Viewer.ForwardThreadNeeds then
      begin
        SetImage;
        Exit;
      end;
      Sleep(10);
    until False;
    F(Bitmap);
  end;
end;

function TViewerThread.TestThread: Boolean;
begin
  FBooleanResult := False;
  SynchronizeEx(TestThreadSynch);
  Result := FBooleanResult;
end;

procedure TViewerThread.TestThreadSynch;
begin
  if Viewer = nil then
  begin
    FBooleanResult := False;
    Exit;
  end;
  FBooleanResult := (IsEqualGUID(Viewer.GetSID, FSID) and not FIsForward) or (IsEqualGUID(Viewer.ForwardThreadSID,
      FSID) and FIsForward) and (Viewer <> nil);
end;

procedure TViewerThread.UpdateRecord;
var
  Query: TDataSet;
  FileName: string;
begin
  CoInitialize(nil);
  try
    FileName := FInfo.FileName;
    F(FInfo);
    FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    Query := GetQuery;
    ReadOnlyQuery(Query);
    try
      Query.Active := False;
      SetSQL(Query, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FInfo.FileName, True))
          + ' AND FFileName LIKE :FFileName');
      SetStrParam(Query, 0, AnsiLowerCase(FInfo.FileName));
      Query.Active := True;
      if Query.RecordCount <> 0 then
      begin
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
