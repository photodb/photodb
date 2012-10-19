unit uImageViewerControl;

interface

uses
  System.Types,
  System.Math,
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.Dwmapi,
  Winapi.CommCtrl,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.Utils.System,
  Dmitry.Graphics.Utils,
  Dmitry.Controls.Base,

  UnitDBDeclare,
  GIFImage,
  Effects,
  UnitDBKernel,

  uMemory,
  uConstants,
  u2DUtils,
  uFaceDetection,
  uFaceDetectionThread,
  uPeopleSupport,
  uGraphicUtils,
  uBitmapUtils,
  uVCLHelpers,
  uAnimatedJPEG,
  uAnimationHelper,
  uImageZoomHelper,
  uThemesUtils,
  uTranslate;

type
  TRequireImageHandler = procedure(Sender: TObject; Item: TDBPopupMenuInfoRecord; Width, Height: Integer) of object;

type
  TImageViewerControl = class(TBaseWinControl)
  private
    FHorizontalScrollBar: TScrollBar;
    FVerticalScrollBar: TScrollBar;
    FApplicationEvents: TApplicationEvents;
    FItem: TDBPopupMenuInfoRecord;
    FOnImageRequest: TRequireImageHandler;
    FImageFrameTimer: TTimer;
    FFrameNumber: Integer;

    FCanvas: TCanvas;
    FDrawImage: TBitmap;
    FOverlayBuffer: TBitmap;
    FFullImage: TBitmap;
    FAnimatedImage: TGraphic;
    FAnimatedBuffer: TBitmap;

    FIsWaiting: Boolean;
    FLoading: Boolean;
    FImageExists: Boolean;
    FIsStaticImage: Boolean;
    FTransparentImage: Boolean;
    FDBCanDrag: Boolean;

    FRealImageWidth: Integer;
    FRealImageHeight: Integer;

    FZoomerOn: Boolean;
    FZoom: Real;
    FImageScale: Double;
    FLoadImageSize: TSize;

    FText: string;

    FDrawFace: TFaceDetectionResultItem;
    FFaces: TFaceDetectionResult;
    FFaceDetectionComplete: Boolean;
    FHoverFace: TFaceDetectionResultItem;
    FDrawingFace: Boolean;
    FPersonMouseMoveLock: Boolean;
    FDrawFaceStartPoint: TPoint;
    FIsSelectingFace: Boolean;
    FFaceMenu: TPopupActionBar;
    FImFacePopup: TImageList;
    {$REGION Face menu}
    MiClearFaceZone: TMenuItem;
    MiClearFaceZoneSeparator: TMenuItem;
    MiCurrentPerson: TMenuItem;
    MiCurrentPersonSeparator: TMenuItem;
    MiPreviousSelections: TMenuItem;
    MiPreviousSelectionsSeparator: TMenuItem;
    MiCreatePerson: TMenuItem;
    MiOtherPersons: TMenuItem;
    MiFindPhotosSeparator: TMenuItem;
    MiFindPhotos: TMenuItem;
    {$ENDREGION}

    function Buffer: TBitmap;
    procedure RecreateImage;
    function GetIsFastDrawing: Boolean;
    procedure ReAlignScrolls(IsCenter: Boolean);
    function GetItem: TDBPopupMenuInfoRecord;
    function GetImageRectA: TRect;
    function HeightW: Integer;
    procedure UpdateCursor;

    procedure RefreshFaces;
    function GetFaceMenu: TPopupActionBar;

    procedure OnScrollChanged(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure FImageFrameTimerOnTimer(Sender: TObject);
    procedure OnApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure PmFacesPopup(Sender: TObject);
    procedure PmFacePopup(Sender: TObject);
  protected

    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
    procedure Resize; override;

    function DrawElement(DC: HDC): Boolean; override;
    procedure NextFrame;

    function L(StringToTranslate: string): string;

    function BufferPointToImagePoint(P: TPoint): TPoint;
    function ImagePointToBufferPoint(P: TPoint): TPoint;
    function GetVisibleImageWidth: Integer;
    function GetVisibleImageHeight: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadStaticImage(Item: TDBPopupMenuInfoRecord; Image: TBitmap; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
    procedure LoadAnimatedImage(Item: TDBPopupMenuInfoRecord; Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
    procedure ZoomOut;
    procedure ZoomIn;
    procedure SetText(Text: string);

    procedure FinishDetectingFaces;
    procedure UpdateFaces(FileName: string; Faces: TFaceDetectionResult);

    property IsFastDrawing: Boolean read GetIsFastDrawing;
    property Item: TDBPopupMenuInfoRecord read GetItem;
    property FullImage: TBitmap read FFullImage;
    property OnImageRequest: TRequireImageHandler read FOnImageRequest write FOnImageRequest;
    property PmFace: TPopupActionBar read GetFaceMenu;
  end;

implementation

{ TImageViewerControl }

function TImageViewerControl.Buffer: TBitmap;
begin
  if (FOverlayBuffer = nil) or FOverlayBuffer.Empty then
    Result := FDrawImage
  else
    Result := FOverlayBuffer;
end;

procedure TImageViewerControl.Click;
var
  P, ScreenRect, ImagePoint: TPoint;
  ImRect: TRect;
  I: Integer;
  Dy, Dx, X, Y, Z: Extended;
begin
  inherited;
  GetCursorPos(ScreenRect);
  P := ScreenToClient(ScreenRect);

  ImagePoint := BufferPointToImagePoint(P);
  for I := 0 to FFaces.Count - 1 do
    if PtInRect(FFaces[I].Rect, PxMultiply(ImagePoint, FFullImage, FFaces[I].ImageSize)) then
    begin
      FHoverFace := FFaces[I];
      RefreshFaces;
      PmFace.Tag := NativeInt(FFaces[I]);
      PmFace.DoPopupEx(ScreenRect.X, ScreenRect.Y);
      Exit;
    end;

{  if Cursor = CursorZoomInNo then
  begin
    Z := Zoom;
    Zoom := Min(Z * (1 / 0.8), 16);
    ImRect := GetImageRectA;
    X := P.X;
    Y := P.Y;
    Dx := (X - (ImRect.Right - ImRect.Left) div 2) / (ImRect.Right - ImRect.Left);
    SbHorisontal.Position := SbHorisontal.Position + Round(SbHorisontal.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    SbVertical.Position := SbVertical.Position + Round(SbVertical.PageSize * Dy);
  end;
  if Cursor = CursorZoomOutNo then
  begin
    Z := Zoom;
    Zoom := Max(Z * 0.8, 0.05);
    ImRect := GetImageRectA;
    X := P.X;
    Y := P.Y;
    Dx := (X - (ImRect.Right - ImRect.Left) div 2) / (ImRect.Right - ImRect.Left);
    SbHorisontal.Position := SbHorisontal.Position + Round(SbHorisontal.PageSize * Dx);
    Dy := (Y - (ImRect.Bottom - ImRect.Top) div 2) / (ImRect.Bottom - ImRect.Top);
    SbVertical.Position := SbVertical.Position + Round(SbVertical.PageSize * Dy);
  end;
  FormResize(Sender);   }
end;

constructor TImageViewerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  ControlStyle := ControlStyle + [csOpaque, csPaintBlackOpaqueOnGlass];

  FHorizontalScrollBar := TScrollBar.Create(Self);
  FHorizontalScrollBar.Visible := False;
  FHorizontalScrollBar.Parent := Self;
  FHorizontalScrollBar.Kind := sbHorizontal;
  FHorizontalScrollBar.OnScroll := OnScrollChanged;

  FVerticalScrollBar := TScrollBar.Create(Self);
  FVerticalScrollBar.Visible := False;
  FVerticalScrollBar.Parent := Self;
  FVerticalScrollBar.Kind := sbVertical;
  FVerticalScrollBar.OnScroll := OnScrollChanged;

  FDrawImage := TBitmap.Create;
  FDrawImage.PixelFormat := pf24bit;

  FOverlayBuffer := TBitmap.Create;
  FOverlayBuffer.PixelFormat := pf24bit;

  FFullImage := TBitmap.Create;
  FFullImage.PixelFormat := pf24bit;

  FAnimatedBuffer := TBitmap.Create;
  FAnimatedBuffer.PixelFormat := pf24bit;

  FImageFrameTimer := TTimer.Create(Self);
  FImageFrameTimer.Enabled := False;
  FImageFrameTimer.OnTimer := FImageFrameTimerOnTimer;

  FApplicationEvents := TApplicationEvents.Create(Self);
  FApplicationEvents.OnMessage := OnApplicationMessage;

  FFaceMenu := nil;
  FImFacePopup := TImageList.Create(Self);

  FDBCanDrag := False;

  FIsWaiting := False;
  FZoomerOn := False;
  FZoom := 1;
  FTransparentImage := False;
  FLoading := False;
  FImageExists := False;
  FRealImageWidth := 0;
  FRealImageHeight := 0;
  FImageScale := 1;
  FAnimatedImage := nil;
  FFrameNumber := -1;
  FLoadImageSize.cx := 0;
  FLoadImageSize.cy := 0;
  FText := '';

  FDrawFace := nil;
  FDrawingFace := False;
  FFaces := TFaceDetectionResult.Create;
  FPersonMouseMoveLock := False;
  FIsSelectingFace := False;

  FItem := TDBPopupMenuInfoRecord.Create;
end;

destructor TImageViewerControl.Destroy;
begin
  F(FAnimatedImage);
  F(FAnimatedBuffer);
  F(FDrawImage);
  F(FOverlayBuffer);
  F(FFullImage);
  F(FCanvas);
  F(FItem);
  F(FDrawFace);
  inherited;
end;

function TImageViewerControl.DrawElement(DC: HDC): Boolean;
begin
  Result := BitBlt(DC, 0, 0, Buffer.Width, Buffer.Height, Buffer.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TImageViewerControl.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TImageViewerControl.FImageFrameTimerOnTimer(Sender: TObject);
begin
  NextFrame;
end;

procedure TImageViewerControl.FinishDetectingFaces;
begin
  FFaceDetectionComplete := True;
  //UpdateFaceDetectionState;
end;

function TImageViewerControl.L(StringToTranslate: string): string;
begin
  Result := TA(StringToTranslate, 'Viewer');
end;

procedure TImageViewerControl.LoadAnimatedImage(Item: TDBPopupMenuInfoRecord;
  Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
begin
  FText := '';
  F(FItem);
  FItem := Item.Copy;

  F(FAnimatedImage);
  FAnimatedImage := Image;
  FLoadImageSize.cx := FAnimatedImage.Width;
  FLoadImageSize.cy := FAnimatedImage.Height;

  FRealImageWidth := RealWidth;
  FRealImageHeight := RealHeight;
  if Item.ID = 0 then
    Item.Rotation := Rotation;

  {FCurrentlyLoadedFile := Item.FileName;
  ForwardThreadExists := False;
  FForwardThreadReady := False; }
  FIsStaticImage := False;
  FImageExists := True;
  FLoading := False;


  if not FZoomerOn then
    Cursor := crDefault;

  {TbFitToWindow.Enabled := True;
  TbRealSize.Enabled := True;
  TbSlideShow.Enabled := True;
  TbZoomOut.Enabled := True;
  TbZoomIn.Enabled := True;    }

  //TbRotateCCW.Enabled := not IsDevicePath(Item.FileName);
  //TbRotateCW.Enabled := not IsDevicePath(Item.FileName);

  {TbRealSize.Down := False;
  TbFitToWindow.Down := False;
  TbZoomOut.Down := False;
  TbZoomIn.Down := False;}

  //EndWaitToImage(Self);

  ReAlignScrolls(False);
  FFrameNumber := -1;
  FZoomerOn := False;
  FTransparentImage := FAnimatedImage.IsTransparentAnimation;

  FAnimatedBuffer.Width := FAnimatedImage.Width;
  FAnimatedBuffer.Height := FAnimatedImage.Height;

  FAnimatedBuffer.Canvas.Brush.Color := Theme.WindowColor;
  FAnimatedBuffer.Canvas.Pen.Color := Theme.WindowColor;

  FAnimatedBuffer.Canvas.Rectangle(0, 0, FAnimatedBuffer.Width, FAnimatedBuffer.Height);
  FImageFrameTimer.Interval := 1;
  FImageFrameTimer.Enabled := True;

  {FFaces.Clear;
  FFaceDetectionComplete := True;
  UpdateFaceDetectionState;   }
end;

procedure TImageViewerControl.LoadStaticImage(Item: TDBPopupMenuInfoRecord; Image: TBitmap; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
begin
  FText := '';
  F(FItem);
  FItem := Item.Copy;

  FImageScale := ImageScale;

  //FTransparentImage := Transparent;
  F(FFullImage);
  FFullImage := Image;
  FLoadImageSize.cx := FFullImage.Width;
  FLoadImageSize.cy := FFullImage.Height;

  FRealImageWidth := RealWidth;
  FRealImageHeight := RealHeight;
  if FItem.ID = 0 then
    FItem.Rotation := Rotation;

  FIsStaticImage := True;
  FImageExists := True;
  FLoading := False;
  if not FZoomerOn then
    Cursor := CrDefault;

  //EndWaitToImage(Self);

  ReAlignScrolls(False);
  FOverlayBuffer.FreeImage;
  FFaces.Clear;
  FFaceDetectionComplete := False;
  //UpdateFaceDetectionState;
  RecreateImage;
end;

procedure TImageViewerControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  PA: TPersonArea;
begin
  inherited;
  if FIsStaticImage and (FHoverFace = nil) and (ShiftKeyDown or (Button = mbMiddle) or FIsSelectingFace) and not FDBCanDrag then
  begin
    FIsSelectingFace := False;
    FDrawingFace := True;
    P := Point(X, Y);
    F(FDrawFace);
    FDrawFace := TFaceDetectionResultItem.Create;
    FDrawFace.ImageWidth := FFullImage.Width;
    FDrawFace.ImageHeight := FFullImage.Height;

    FDrawFaceStartPoint := BufferPointToImagePoint(P);
    FDrawFace.Rect := Rect(FDrawFaceStartPoint, FDrawFaceStartPoint);

    PA := TPersonArea.Create(0, -1, nil);
    FDrawFace.Data := PA;
    UpdateCursor;
    Exit;
  end;

  {WindowsMenuTickCount := GetTickCount;
  if CurrentInfo.Count = 0 then
    Exit;

  if Button = MbLeft then
    if FileExistsSafe(Item.FileName) then
    begin
      DBCanDrag := True;
      GetCursorPos(DBDragPoint);
    end; }
end;

procedure TImageViewerControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  StartPoint, P, DrawFaceEndPoint: TPoint;
  DragImage: TBitmap;
  W, H: Integer;
  FileName: string;
  I: Integer;
  OldHoverFace: TFaceDetectionResultItem;
  FaceRect: TRect;
begin
  inherited;
  StartPoint := Point(X, Y);

  if not FPersonMouseMoveLock and not IsPopupMenuActive then
  begin
    P := BufferPointToImagePoint(StartPoint);
    OldHoverFace := FHoverFace;
    FHoverFace := nil;

    for I := 0 to FFaces.Count - 1 do
      if PtInRect(NormalizeRect(FFaces[I].Rect), PxMultiply(P, FFullImage, FFaces[I].ImageSize)) then
      begin
        FHoverFace := FFaces[I];
        Break;
      end;

    if OldHoverFace <> FHoverFace then
      RefreshFaces;

    if FDrawingFace then
    begin
      DrawFaceEndPoint := Point(P.X, P.Y);
      FaceRect := Rect(FDrawFaceStartPoint, DrawFaceEndPoint);
      FDrawFace.Rect := NormalizeRect(FaceRect);

      RefreshFaces;
      Exit;
    end;
  end;
  FPersonMouseMoveLock := False;

{  if DBCanDrag then
  begin
    GetCursorPos(P);
    if (Abs(DBDragPoint.X - P.X) > 5) or (Abs(DBDragPoint.Y - P.Y) > 5) then
    begin
      DropFileSource1.Files.Clear;
      if CurrentInfo.Count > 0 then
      begin
        FileName := Item.FileName;
        DropFileSource1.Files.Add(FileName);
        DropFileSource1.ShowImage := FImageExists;
        W := FFullImage.Width;
        H := FFullImage.Height;
        ProportionalSize(ThImageSize, ThImageSize, W, H);

        DragImage := TBitmap.Create;
        try
          DoResize(W, H, FFullImage, DragImage);
          CreateDragImage(DragImage, DragImageList, Font, ExtractFileName(FileName));
        finally
          F(DragImage);
        end;

        DropFileSource1.ImageIndex := 0;
        DropFileSource1.Execute;
        Invalidate;
      end;
      DBCanDrag := False;
    end;
  end;

  if (Abs(FOldPoint.X - X) < 5) and (Abs(FOldPoint.Y - Y) < 5) then
    Exit;

  FOldPoint := Point(X, Y); }
end;

procedure TImageViewerControl.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  FDrawingFace := False;
  if FDrawFace <> nil then
  begin
    FFaces.Add(FDrawFace);
    PmFace.Tag := NativeInt(FDrawFace);
    FHoverFace := FDrawFace;
    FDrawFace := nil;
    FFaces.SaveToFile(FFaces.PersistanceFileName);
    //UpdateFaceDetectionState;
    Invalidate;
    RefreshFaces;

    P := Point(X, Y);
    P := ClientToScreen(P);
    PmFace.DoPopupEx(P.X, P.Y);
    UpdateCursor;
  end;
  F(FDrawFace);
  FDBCanDrag := False;
end;


procedure TImageViewerControl.NextFrame;
begin
  if not (FImageExists and not FIsStaticImage) then
    Exit;

  FAnimatedImage.ProcessNextFrame(FAnimatedBuffer, FFrameNumber, Theme.WindowColor, FImageFrameTimer,
    procedure
    begin
      case Item.Rotation and DB_IMAGE_ROTATE_MASK of
        DB_IMAGE_ROTATE_0:
          FFullImage.Assign(FAnimatedBuffer);
        DB_IMAGE_ROTATE_90:
          Rotate90(FAnimatedBuffer, FFullImage);
        DB_IMAGE_ROTATE_180:
          Rotate180(FAnimatedBuffer, FFullImage);
        DB_IMAGE_ROTATE_270:
          Rotate270(FAnimatedBuffer, FFullImage)
      end;

      RecreateImage;
    end
  );

end;

function TImageViewerControl.GetFaceMenu: TPopupActionBar;
begin
  if FFaceMenu <> nil then
    Exit(FFaceMenu);

  FFaceMenu := TPopupActionBar.Create(Self);
  FFaceMenu.OnPopup := PmFacePopup;
  FFaceMenu.Images := FImFacePopup;

  MiClearFaceZone := TMenuItem.Create(FFaceMenu);
  MiClearFaceZone.ImageIndex := 0;
  MiClearFaceZone.Caption := L('Clear face zone');
  //MiClearFaceZone.OnClick := MiClearFaceZoneClick;

  MiClearFaceZoneSeparator := TMenuItem.Create(FFaceMenu);
  MiClearFaceZoneSeparator.Caption := '-';

  MiCurrentPerson := TMenuItem.Create(FFaceMenu);
  MiCurrentPerson.Visible := False;

  MiCurrentPersonSeparator := TMenuItem.Create(FFaceMenu);
  MiCurrentPersonSeparator.Caption := '-';

  MiPreviousSelections := TMenuItem.Create(FFaceMenu);
  MiPreviousSelections.Caption := L('Previous selections') + ':';
  MiPreviousSelections.Enabled := False;

  MiPreviousSelectionsSeparator := TMenuItem.Create(FFaceMenu);
  MiPreviousSelectionsSeparator.Caption := '-';

  MiCreatePerson := TMenuItem.Create(FFaceMenu);
  MiCreatePerson.Caption := L('Create person');
  MiCreatePerson.ImageIndex := 1;
//  MiCreatePerson.OnClick := MiCreatePersonClick;

  MiOtherPersons := TMenuItem.Create(FFaceMenu);
  MiOtherPersons.Caption := L('Other person');
  MiOtherPersons.ImageIndex := 1;
//  MiOtherPersons.OnClick := MiOtherPersonsClick;

  MiFindPhotosSeparator := TMenuItem.Create(FFaceMenu);
  MiFindPhotosSeparator.Caption := '-';

  MiFindPhotos := TMenuItem.Create(FFaceMenu);
  MiFindPhotos.Caption := L('Find photos');
  MiFindPhotos.ImageIndex := 2;
//  MiFindPhotos.OnClick := MiFindPhotosClick;

  FFaceMenu.Items.Add(MiClearFaceZone);
  FFaceMenu.Items.Add(MiClearFaceZoneSeparator);
  FFaceMenu.Items.Add(MiCurrentPerson);
  FFaceMenu.Items.Add(MiCurrentPersonSeparator);
  FFaceMenu.Items.Add(MiPreviousSelections);
  FFaceMenu.Items.Add(MiPreviousSelectionsSeparator);
  FFaceMenu.Items.Add(MiCreatePerson);
  FFaceMenu.Items.Add(MiOtherPersons);
  FFaceMenu.Items.Add(MiFindPhotosSeparator);
  FFaceMenu.Items.Add(MiFindPhotos);

  Exit(FFaceMenu);
end;

function TImageViewerControl.GetImageRectA: TRect;
begin
  Result := TImageZoomHelper.GetImageVisibleRect(FHorizontalScrollBar, FVerticalScrollBar,
      TSize.Create(FFullImage.Width, FFullImage.Height),
      TSize.Create(ClientWidth, HeightW),
      FZoom);
end;

function TImageViewerControl.GetIsFastDrawing: Boolean;
begin
  Result := False;
end;

function TImageViewerControl.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := FItem;
end;

function TImageViewerControl.GetVisibleImageHeight: Integer;
begin
  Result := ClientHeight{ - BottomImage.Height};
end;

function TImageViewerControl.GetVisibleImageWidth: Integer;
begin
  Result := ClientWidth;
end;

function TImageViewerControl.HeightW: Integer;
begin
  Result := ClientHeight;
end;

function TImageViewerControl.BufferPointToImagePoint(P: TPoint): TPoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if FZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if FHorizontalScrollBar.Visible then
      Result.X := Round((FHorizontalScrollBar.Position + P.X) / FZoom)
    else
      Result.X := Round((P.X - X1) / FZoom);
    if FVerticalScrollBar.Visible then
      Result.Y := Round((FVerticalScrollBar.Position + P.Y) / FZoom)
    else
      Result.Y := Round((P.Y - Y1) / FZoom);
  end else
  begin
    if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
      Exit;
    if (FFullImage.Width > GetVisibleImageWidth) or (FFullImage.Height > GetVisibleImageHeight) then
    begin
      if FFullImage.Width / FFullImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FFullImage.Width / FFullImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FFullImage.Height / FFullImage.Width));
      end;
    end else
    begin
      Fh := FFullImage.Height;
      Fw := FFullImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if Fw <> 0 then
      Result.X := Round((P.X - X1) * (FFullImage.Width / Fw));
    if Fh <> 0 then
      Result.Y := Round((P.Y - Y1) * (FFullImage.Height / Fh));
  end;
end;

function TImageViewerControl.ImagePointToBufferPoint(P: TPoint): TPoint;
var
  X1, Y1: Integer;
  ImRect: TRect;
  Fh, Fw: Integer;
begin
  if FZoomerOn then
  begin
    ImRect := GetImageRectA;
    X1 := ImRect.Left;
    Y1 := ImRect.Top;
    if FHorizontalScrollBar.Visible then
      Result.X := Round(P.X * FZoom - FHorizontalScrollBar.Position)
    else
      Result.X := Round((P.X * FZoom + X1));
    if FVerticalScrollBar.Visible then
      Result.Y := Round(P.Y * FZoom - FVerticalScrollBar.Position)
    else
      Result.Y := Round((P.Y * FZoom + Y1));
  end else
  begin
    if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
      Exit;
    if (FFullImage.Width > GetVisibleImageWidth) or (FFullImage.Height > GetVisibleImageHeight) then
    begin
      if FFullImage.Width / FFullImage.Height < Buffer.Width / Buffer.Height then
      begin
        Fh := Buffer.Height;
        Fw := Round(Buffer.Height * (FFullImage.Width / FFullImage.Height));
      end else
      begin
        Fw := Buffer.Width;
        Fh := Round(Buffer.Width * (FFullImage.Height / FFullImage.Width));
      end;
    end else
    begin
      Fh := FFullImage.Height;
      Fw := FFullImage.Width;
    end;
    X1 := GetVisibleImageWidth div 2 - Fw div 2;
    Y1 := GetVisibleImageHeight div 2 - Fh div 2;
    Result := Point(0, 0);
    if FFullImage.Width <> 0 then
      Result.X := Round(X1 + P.X * (Fw / FFullImage.Width));
    if FFullImage.Height <> 0 then
      Result.Y := Round(Y1 + P.Y * (Fh / FFullImage.Height));
  end;
end;

procedure TImageViewerControl.OnApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
//var
//  R: TRect;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    {R.TopLeft := ClientToScreen(BoundsRect.TopLeft);
    R.BottomRight := ClientToScreen(BoundsRect.BottomRight);

    if PtInRect(R, Msg.pt) then
    begin
      Handled := True;
      if NativeInt(Msg.wParam) > 0 then
        ZoomOut
      else
        ZoomIn;
    end; }
  end;
end;

procedure TImageViewerControl.OnScrollChanged(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if ScrollPos > (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize then
    ScrollPos := (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize;
  RecreateImage;
end;

procedure TImageViewerControl.PmFacePopup(Sender: TObject);
var
  I, LatestPersonsIndex: Integer;
  RI: TFaceDetectionResultItem;
  PA: TPersonArea;
  P: TPerson;
  SelectedPersons: TPersonCollection;
  LatestPersons: Boolean;
  MI: TMenuItem;
begin
  RI := TFaceDetectionResultItem(PmFace.Tag);
  PA := TPersonArea(RI.Data);

  FImFacePopup.Clear;
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_DELETE_INFO + 1]);
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_PEOPLE + 1]);
  ImageList_AddIcon(FImFacePopup.Handle, Icons[DB_IC_SEARCH + 1]);

  MiCurrentPerson.Visible := (RI.Data <> nil) and (PA.PersonID > 0);
  MiCurrentPersonSeparator.Visible := (RI.Data <> nil) and (PA.PersonID > 0);
  P := TPerson.Create;
  try
    if (PA <> nil) and (PA.PersonID > 0) then
    begin
      PersonManager.FindPerson(PA.PersonID, P);
      MiCreatePerson.Visible := P.Empty;
      if not P.Empty then
      begin
        MiFindPhotosSeparator.Visible := True;
        MiFindPhotos.Visible := True;
        MiCurrentPerson.ImageIndex := FImFacePopup.Add(P.CreatePreview(16, 16), nil);
        MiCurrentPerson.Caption := P.Name
      end else
        MiCurrentPerson.Caption := L('Unknown Person');
    end else
    begin
      MiCreatePerson.Visible := True;
      MiFindPhotosSeparator.Visible := False;
      MiFindPhotos.Visible := False;
    end;

    SelectedPersons := TPersonCollection.Create;
    try
      //remove last persons
      LatestPersons := False;
      LatestPersonsIndex := 0;
      for I := PmFace.Items.Count - 1 downto 0 do
      begin
        if PmFace.Items[I] = MiPreviousSelections then
        begin
          LatestPersons := False;
          LatestPersonsIndex := I;
        end;

        if LatestPersons then
          PmFace.Items.Remove(PmFace.Items[I]);

        if PmFace.Items[I] = MiPreviousSelectionsSeparator then
          LatestPersons := True;
      end;

      //add current persons
      PersonManager.FillLatestSelections(SelectedPersons);

      if not P.Empty then
        for I := 0 to SelectedPersons.Count - 1 do
        begin
          if SelectedPersons[I].ID = P.ID then
          begin
            SelectedPersons.DeleteAt(I);
            Break;
          end;
        end;

      for I := 0 to SelectedPersons.Count - 1 do
      begin
        MI := TMenuItem.Create(PmFace);
        MI.Tag := SelectedPersons[I].ID;
        MI.Caption := SelectedPersons[I].Name;
        //TODO: MI.OnClick := SelectPreviousPerson;
        MI.ImageIndex := FImFacePopup.Add(SelectedPersons[I].CreatePreview(16, 16), nil);
        PmFace.Items.Insert(LatestPersonsIndex + 1, MI);
        Inc(LatestPersonsIndex);
      end;

      if SelectedPersons.Count = 0 then
      begin
        MiPreviousSelections.Visible := False;
        MiPreviousSelectionsSeparator.Visible := False;
      end else
      begin
        MiPreviousSelections.Visible := True;
        MiPreviousSelectionsSeparator.Visible := True;
      end;
      FPersonMouseMoveLock := True;
    finally
      F(SelectedPersons);
    end;
  finally
    F(P);
  end;
end;

procedure TImageViewerControl.PmFacesPopup(Sender: TObject);
var
  FileList: TStrings;
  I, Found: Integer;
  SearchRec: TSearchRec;
  Directory, DetectionMethod: string;
  MI: TMenuItem;
begin
  //RefreshFaceDetestionState;

{  MiDetectionMethod.Caption := L('Detection method');
  MiRefreshFaces.Caption := L('Refresh faces');

  DetectionMethod := Settings.ReadString('Face', 'DetectionMethod', DefaultCascadeFileName);
  FileList := TStringList.Create;
  try
    Directory := IncludeTrailingBackslash(ProgramDir) + CascadesDirectory;
    Found := FindFirst(Directory + '\*.xml', FaAnyFile, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          FileList.Add(Directory + '\' + SearchRec.Name);
        Found := FindNext(SearchRec);
      end;
    finally
      System.SysUtils.FindClose(SearchRec);
    end;

    MiDetectionMethod.Clear;
    for I := 0 to FileList.Count - 1 do
    begin
      MI := TMenuItem.Create(PmFaces);
      MI.Caption := ExtractFileName(FileList[I]);
      MI.OnClick := SelectCascade;
      MI.ExSetDefault(MI.Caption = DetectionMethod);
      MiDetectionMethod.Add(MI);
    end;
  finally
    F(FileList);
  end;  }
end;

procedure TImageViewerControl.ZoomIn;
var
  Z: Real;
begin
  //TbRealSize.Down := False;
  //TbFitToWindow.Down := False;
 // Cursor := CursorZoomInNo;
  if not FZoomerOn and (FImageScale > 1) then
  begin
    FZoomerOn := True;
    if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Min(Z * (1 / 0.8), 16);
    {
    TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False;  }

    //LoadImage_(Sender, True, Z, True);
    FLoadImageSize.cx := FRealImageWidth;
    FLoadImageSize.cy := FRealImageHeight;
    FOnImageRequest(Self, Item, FLoadImageSize.cx, FLoadImageSize.cy);

    {TbrActions.Refresh;
    TbrActions.Realign;    }
  end else
  begin
    if FZoomerOn then
    begin
      Z := FZoom;
    end else
    begin
      if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
      Z := 1 / Z;
    end;

    FZoomerOn := True;
    FZoom := Min(Z * (1 / 0.8), 16);
    ReAlignScrolls(False);
    RecreateImage;
  end;
end;

procedure TImageViewerControl.ZoomOut;
var
  Z: Real;
begin
  //TbRealSize.Down := False;
  //TbFitToWindow.Down := False;
  //Cursor := CursorZoomOutNo;
  if not FZoomerOn and (FImageScale > 1) then
  begin
    FZoomerOn := True;
    if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
      Z := 1
    else
      Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
    Z := 1 / Z;
    Z := Max(Z * 0.8, 0.01);
    {TbFitToWindow.Enabled := False;
    TbRealSize.Enabled := False;
    TbSlideShow.Enabled := False;
    TbZoomOut.Enabled := False;
    TbZoomIn.Enabled := False;
    TbRotateCCW.Enabled := False;
    TbRotateCW.Enabled := False; }

    //TODO: LoadImage_(Sender, True, Z, True);

    FLoadImageSize.cx := FRealImageWidth;
    FLoadImageSize.cy := FRealImageHeight;
    FOnImageRequest(Self, Item, FLoadImageSize.cx, FLoadImageSize.cy);

    //TbrActions.Refresh;
    //TbrActions.Realign;
  end else
  begin
    if FZoomerOn then
    begin
      Z := FZoom;
    end else
    begin
      if (FRealImageWidth < ClientWidth) and (FRealImageHeight < HeightW) then
        Z := 1
      else
        Z := Max(FRealImageWidth / ClientWidth, FRealImageHeight / (HeightW));
      Z := 1 / Z;
    end;
    FZoomerOn := True;
    FZoom := Max(Z * 0.8, 0.05);
    ReAlignScrolls(False);
    RecreateImage;
  end;
end;

procedure TImageViewerControl.RecreateImage;
var
  Fh, Fw: Integer;
  ZX, ZY, ZW, ZH, X1, X2, Y1, Y2: Integer;
  ImRect, BeginRect: TRect;
  FileName: string;
  Z, Zoom: Double;
  TempImage, B: TBitmap;
  ACopyRect: TRect;
  ImageEffectiveWidth,
  ImageEffectiveHeight: Integer;

  procedure DrawRect(X1, Y1, X2, Y2: Integer);
  begin
    if FTransparentImage then
    begin
      FDrawimage.Canvas.Brush.Color := Theme.WindowColor;
      FDrawimage.Canvas.Pen.Color := 0;
      FDrawimage.Canvas.Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
    end;
  end;

  procedure ShowInfoText(InfoText, InfoTextLine2: string);
  begin
    FDrawImage.Canvas.Font.Color := Theme.WindowTextColor;

    FDrawImage.Canvas.TextOut(FDrawImage.Width div 2 - FDrawImage.Canvas.TextWidth(InfoText) div 2,
      FDrawImage.Height div 2 - FDrawImage.Canvas.Textheight(InfoText) div 2, InfoText);

    FDrawImage.Canvas.TextOut(FDrawImage.Width div 2 - FDrawImage.Canvas.TextWidth(InfoTextLine2) div 2,
      FDrawImage.Height div 2 - FDrawImage.Canvas.TextHeight(InfoTextLine2) div 2 + FDrawImage.Canvas.TextHeight(InfoTextLine2) + 4, InfoTextLine2);
  end;

  procedure ShowErrorText(FileName: string);
  var
    MessageText: string;
  begin
    if FileName <> '' then
    begin
      MessageText := TA('Can''t display file') + ':';
      ShowInfoText(MessageText, FileName);
    end;
  end;

begin
  FDrawImage.SetSize(Clientwidth, HeightW);

  DrawBackground(FDrawImage.Canvas);

  if FText <> '' then
  begin
    ShowInfoText(FText, '');
    Refresh;
    Exit;
  end;

  if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
  begin
    ShowErrorText(FileName);
    Refresh;
    Exit;
  end;

  if IsRotatedImageProportions(Item.Rotation) then
  begin
    ImageEffectiveWidth := FRealImageHeight;
    ImageEffectiveHeight := FRealImageWidth;
  end else
  begin
    ImageEffectiveWidth := FRealImageWidth;
    ImageEffectiveHeight := FRealImageHeight;
  end;

  if (ImageEffectiveWidth > ClientWidth) or (ImageEffectiveHeight > HeightW) then
  begin
    if ImageEffectiveWidth / ImageEffectiveHeight < FDrawImage.Width / FDrawImage.Height then
    begin
      FH := FDrawImage.Height;
      FW := Round(FDrawImage.Height * (ImageEffectiveWidth / ImageEffectiveHeight));
    end else
    begin
      FW := FDrawImage.Width;
      FH := Round(FDrawImage.Width * (ImageEffectiveHeight / ImageEffectiveWidth));
    end;
  end else
  begin
    FH := ImageEffectiveHeight;
    FW := ImageEffectiveWidth;
  end;

  X1 := ClientWidth div 2 - FW div 2;
  Y1 := (HeightW) div 2 - FH div 2;
  X2 := X1 + FW;
  Y2 := Y1 + FH;
  ImRect := GetImageRectA;
  ZX := ImRect.Left;
  ZY := ImRect.Top;
  ZW := ImRect.Right - ImRect.Left;
  ZH := ImRect.Bottom - ImRect.Top;

  Zoom := FZoom;
  if FFullImage.Width < FRealImageWidth then
    Zoom := FZoom * ImageEffectiveWidth / FFullImage.Width;

  if FImageExists or FLoading then
  begin
    if not IsFastDrawing then
    begin
      if FZoomerOn and not FIsWaiting then
      begin
        DrawRect(ImRect.Left, ImRect.Top, ImRect.Right, ImRect.Bottom);
        if Zoom <= 1 then
        begin
          if (Zoom < ZoomSmoothMin) then
            StretchCoolW(ZX, ZY, ZW, ZH, Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
                Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom)), FFullImage, FDrawImage)
          else
          begin
            ACopyRect := Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
              Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom));
            TempImage := TBitmap.Create;
            try
              TempImage.PixelFormat := pf24bit;
              TempImage.SetSize(ZW, ZH);
              B := TBitmap.Create;
              try
                B.PixelFormat := Pf24bit;
                B.Width := (ACopyRect.Right - ACopyRect.Left);
                B.Height := (ACopyRect.Bottom - ACopyRect.Top);
                B.Canvas.CopyRect(Rect(0, 0, B.Width, B.Height), FFullImage.Canvas, ACopyRect);
                SmoothResize(ZW, ZH, B, TempImage);
              finally
                F(B);
              end;
              FDrawImage.Canvas.Draw(ZX, ZY, TempImage);
            finally
              F(TempImage);
            end;
          end;
        end else
          Interpolate(ZX, ZY, ZW, ZH, Rect(Round(FHorizontalScrollBar.Position / Zoom), Round(FVerticalScrollBar.Position / Zoom),
              Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom)), FFullImage, FDrawImage);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        if FZoomerOn then
          Z := FImageScale * Zoom
        else
        begin
          if FRealImageWidth * FRealImageHeight <> 0 then
          begin
            if IsRotatedImageProportions(Item.Rotation) then
              Z := Zoom * Min(FW / FRealImageHeight, FH / FRealImageWidth)
            else
              Z := Zoom * Min(FW / FRealImageWidth, FH / FRealImageHeight);
          end else
            Z := Zoom;
        end;
        if (Z < ZoomSmoothMin) then
          StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FFullImage, FDrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := Pf24bit;
            TempImage.SetSize(X2 - X1, Y2 - Y1);
            SmoothResize(X2 - X1, Y2 - Y1, FFullImage, TempImage);
            FDrawImage.Canvas.Draw(X1, Y1, TempImage);
          finally
            F(TempImage);
          end;
        end;
      end;
    end else
    begin
      if FZoomerOn and not FIsWaiting then
      begin
        BeginRect := GetImageRectA;
        DrawRect(BeginRect.Left, BeginRect.Top, BeginRect.Right, BeginRect.Bottom);
        SetStretchBltMode(FDrawImage.Canvas.Handle, STRETCH_HALFTONE);
        FDrawImage.Canvas.CopyMode := SRCCOPY;
        FDrawImage.Canvas.CopyRect(BeginRect, FFullImage.Canvas, ImRect);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        SetStretchBltMode(FDrawImage.Canvas.Handle, STRETCH_HALFTONE);
        FDrawImage.Canvas.StretchDraw(Rect(X1, Y1, X2, Y2), FFullImage);
      end;
    end;
  end else
    ShowErrorText(FileName);

  BeginScreenUpdate(Handle);
  try
    RefreshFaces;
  finally
    EndScreenUpdate(Handle, True);
  end;
end;

procedure TImageViewerControl.ReAlignScrolls(IsCenter: Boolean);
begin
  TImageZoomHelper.ReAlignScrolls(IsCenter,
    FHorizontalScrollBar, FVerticalScrollBar, nil,
    TSize.Create(FFullImage.Width, FFullImage.Height),
    TSize.Create(ClientWidth, HeightW),
    FZoom, FZoomerOn);
end;

procedure TImageViewerControl.RefreshFaces;
const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK + DT_CENTER;

var
  I: Integer;
  P1, P2: TPoint;
  Rct, R, FaceTextRect: TRect;
  PA: TPersonArea;
  P: TPerson;

  procedure DrawFaceText(Text: string);
  begin
    R := Rect(R.Left, R.Bottom + 8, Max(R.Left + 20, R.Right), R.Bottom + 500);
    Rct := R;
    FOverlayBuffer.Canvas.Font := Font;
    FOverlayBuffer.Canvas.Font.Color := Theme.GradientText;
    DrawText(FOverlayBuffer.Canvas.Handle, PChar(Text), Length(Text), R, DrawTextOpt or DT_CALCRECT);
    R.Right := Max(R.Right, Rct.Right);
    FaceTextRect := R;
    InflateRect(R, 4, 4);
    DrawRoundGradientVert(FOverlayBuffer, R, Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, 8, 220);
    DrawText(FOverlayBuffer.Canvas.Handle, PChar(Text), Length(Text), FaceTextRect, DrawTextOpt);
  end;

  procedure DrawFace(Face: TFaceDetectionResultItem);
  var
    S: string;
  begin
    FOverlayBuffer.Canvas.Brush.Style := bsClear;
    FOverlayBuffer.Canvas.Pen.Style := psDash;
    FOverlayBuffer.Canvas.Pen.Width := 1;

    P1 := Face.Rect.TopLeft;
    P2 := Face.Rect.BottomRight;

    P1 := PxMultiply(P1, Face.ImageSize, FFullImage);
    P2 := PxMultiply(P2, Face.ImageSize, FFullImage);

    P1 := ImagePointToBufferPoint(P1);
    P2 := ImagePointToBufferPoint(P2);
    R := Rect(P1, P2);
    FOverlayBuffer.Canvas.Pen.Color := Theme.WindowColor;
    FOverlayBuffer.Canvas.Rectangle(R);
    InflateRect(R, -1, -1);
    FOverlayBuffer.Canvas.Pen.Color := clGray;
    FOverlayBuffer.Canvas.Rectangle(R);
    if Face.Data <> nil then
    begin
      PA := TPersonArea(Face.Data);

      P := TPerson.Create;
      try
        PersonManager.FindPerson(PA.PersonID, P);
        if not P.Empty or (PA.PersonID = -1) then
        begin
          if not P.Empty then
            S := P.Name
          else
            S := L('New person');

          DrawFaceText(S);
        end;
      finally
        F(P);
      end;
    end else
      DrawFaceText(L('Click to select person'));
  end;

begin
  if (FFaces.Count > 0) or FDrawingFace then
  begin
    FOverlayBuffer.Assign(FDrawImage);

    if not ShiftKeyDown {and not FDisplayAllFaces} then
    begin
      if FHoverFace <> nil then
        DrawFace(FHoverFace);
    end else
    begin
      for I := 0 to FFaces.Count - 1 do
        DrawFace(FFaces[I]);
    end;

    if FDrawingFace and (FDrawFace <> nil) then
      DrawFace(FDrawFace);
  end else
    FOverlayBuffer.SetSize(0, 0);

  Refresh;
end;

procedure TImageViewerControl.Resize;
var
  Size: TSize;
begin
  inherited;

  Size.cx := ClientWidth;
  Size.cy := HeightW;
  FDrawImage.SetSize(Size.cx, Size.cy);
  if (Size.cx > FLoadImageSize.cx) or (Size.cy > FLoadImageSize.cy) then
  begin
    FLoadImageSize.cx := Screen.DesktopWidth;
    FLoadImageSize.cy := Screen.DesktopHeight;
    FOnImageRequest(Self, Item, Screen.DesktopWidth, Screen.DesktopHeight);
  end;

  if not FIsWaiting then
    ReAlignScrolls(False);

  //LsLoading.Left := ClientWidth div 2 - LsLoading.Width div 2;
  //LsLoading.Top := ClientHeight div 2 - LsLoading.Height div 2;

  RecreateImage;
  //CheckFaceIndicatorVisibility;
end;

procedure TImageViewerControl.SetText(Text: string);
begin
  FText := Text;
  RecreateImage;
end;

procedure TImageViewerControl.UpdateCursor;
begin
  if FDrawingFace or ShiftKeyDown or FIsSelectingFace then
    Cursor := crCross
  else
    Cursor := crDefault;
end;

procedure TImageViewerControl.UpdateFaces(FileName: string;
  Faces: TFaceDetectionResult);
begin
  if Item.FileName = FileName then
  begin
    FFaces.Assign(Faces);
    FFaceDetectionComplete := True;
    //UpdateFaceDetectionState;
    RecreateImage;
  end;
end;

end.
