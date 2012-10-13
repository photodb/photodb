unit uImageViewerControl;

interface

uses
  System.Math,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.Dwmapi,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,

  Dmitry.Utils.System,
  Dmitry.Graphics.Utils,
  Dmitry.Controls.Base,

  UnitDBDeclare,
  GIFImage,
  Effects,

  uMemory,
  uConstants,
  uGraphicUtils,
  uBitmapUtils,
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

    FRealImageWidth: Integer;
    FRealImageHeight: Integer;

    FZoomerOn: Boolean;
    FZoom: Real;
    FImageScale: Double;
    FLoadImageSize: TSize;

    function Buffer: TBitmap;
    procedure RecreateImage;
    function GetIsFastDrawing: Boolean;
    procedure RefreshFaces;
    procedure ReAlignScrolls(IsCenter: Boolean);
    function GetItem: TDBPopupMenuInfoRecord;
    function GetImageRectA: TRect;
    function HeightW: Integer;
    procedure OnScrollChanged(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure FImageFrameTimerOnTimer(Sender: TObject);
    procedure OnApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  protected
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;  
    function DrawElement(DC: HDC): Boolean; override;
    procedure Resize; override;
    procedure NextFrame;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadStaticImage(Item: TDBPopupMenuInfoRecord; Image: TBitmap; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
    procedure LoadAnimatedImage(Item: TDBPopupMenuInfoRecord; Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
    procedure ZoomOut;
    procedure ZoomIn;
    property IsFastDrawing: Boolean read GetIsFastDrawing;
    property Item: TDBPopupMenuInfoRecord read GetItem;
    property FullImage: TBitmap read FFullImage;
    property OnImageRequest: TRequireImageHandler read FOnImageRequest write FOnImageRequest;
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

procedure TImageViewerControl.LoadAnimatedImage(Item: TDBPopupMenuInfoRecord;
  Image: TGraphic; RealWidth, RealHeight, Rotation: Integer; ImageScale: Double);
begin
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
  //ValidImages := 1;
  FOverlayBuffer.FreeImage;
  //FFaces.Clear;
  //FFaceDetectionComplete := False;
  //UpdateFaceDetectionState;
  RecreateImage;
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

function TImageViewerControl.HeightW: Integer;
begin
  Result := ClientHeight;
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

  procedure ShowErrorText(FileName: string);
  var
    MessageText: string;
  begin
    if FileName <> '' then
    begin
      MessageText := TA('Can''t display file') + ':';

      FDrawImage.Canvas.Font.Color := Theme.WindowTextColor;

      FDrawImage.Canvas.TextOut(FDrawImage.Width div 2 - FDrawImage.Canvas.TextWidth(MessageText) div 2,
        FDrawImage.Height div 2 - FDrawImage.Canvas.Textheight(MessageText) div 2, MessageText);

      FDrawImage.Canvas.TextOut(FDrawImage.Width div 2 - FDrawImage.Canvas.TextWidth(FileName) div 2,
        FDrawImage.Height div 2 - FDrawImage.Canvas.TextHeight(FileName) div 2 + FDrawImage.Canvas.TextHeight(FileName) + 4, FileName);
    end;
  end;

begin
  FDrawImage.SetSize(Clientwidth, HeightW);

  DrawBackground(FDrawImage.Canvas);

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
begin
  //TODO:
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

end.
