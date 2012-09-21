unit uImageViewerControl;

interface

uses
  System.Math,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  GraphicsCool,
  UnitDBDeclare,
  uMemory,
  uConstants,
  uGraphicUtils,
  uBitmapUtils,
  uThemesUtils,
  uTranslate,
  uBaseWinControl;

type
  TImageViewerControl = class(TBaseWinControl)
  private
    FZoomerOn: Boolean;
    FZoom: Real;
    FCanvas: TCanvas;
    FDrawImage: TBitmap;
    FOverlayBuffer: TBitmap;
    FFullImage: TBitmap;
    FTransparentImage: Boolean;
    FIsWaiting: Boolean;
    FLoading: Boolean;
    FImageExists: Boolean;
    FIsStaticImage: Boolean;
    FRealImageWidth: Integer;
    FRealImageHeight: Integer;
    FHorizontalScrollBar: TScrollBar;
    FVerticalScrollBar: TScrollBar;
    function Buffer: TBitmap;
    procedure RecreateImage;
    function GetIsFastDrawing: Boolean;
    procedure RefreshFaces;
    procedure ReAlignScrolls(IsCenter: Boolean);
    function GetItem: TDBPopupMenuInfoRecord;
    function GetImageRectA: TRect;
    function HeightW: Integer;
    procedure OnScrollChanged(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
  protected
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer);
    property IsFastDrawing: Boolean read GetIsFastDrawing;
    property Item: TDBPopupMenuInfoRecord read GetItem;
  end;

implementation

const
  RealZoomInc = 1;

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
  //DoubleBuffered := True;

  FHorizontalScrollBar := TScrollBar.Create(Self);
  FHorizontalScrollBar.Visible := False;
  FHorizontalScrollBar.Parent := nil;
  FHorizontalScrollBar.Kind := sbHorizontal;
  FHorizontalScrollBar.OnScroll := OnScrollChanged;

  FVerticalScrollBar := TScrollBar.Create(Self);
  FVerticalScrollBar.Visible := False;
  FVerticalScrollBar.Parent := nil;
  FVerticalScrollBar.Kind := sbVertical;
  FVerticalScrollBar.OnScroll := OnScrollChanged;

  FDrawImage := TBitmap.Create;
  FDrawImage.PixelFormat := pf24bit;

  FOverlayBuffer := TBitmap.Create;
  FOverlayBuffer.PixelFormat := pf24bit;

  FFullImage := TBitmap.Create;
  FFullImage.PixelFormat := pf24bit;

  FIsWaiting := False;
  FZoomerOn := False;
  FZoom := 1;
  FTransparentImage := False;
  FLoading := False;
  FImageExists := False;
  FRealImageWidth := 0;
  FRealImageHeight := 0;
end;

destructor TImageViewerControl.Destroy;
begin
  F(FDrawImage);
  F(FOverlayBuffer);
  F(FFullImage);
  F(FCanvas);
  inherited;
end;

procedure TImageViewerControl.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TImageViewerControl.LoadStaticImage(Image: TBitmap; RealWidth, RealHeight: Integer);
begin
  //FTransparentImage := Transparent;
  F(FFullImage);
  FFullImage := Image;

  FRealImageWidth := RealWidth;
  FRealImageHeight := RealHeight;

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

function TImageViewerControl.GetImageRectA: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if FHorizontalScrollBar.Visible then
  begin
    FX := 0;
  end else
  begin
    if FVerticalScrollBar.Visible then
      Increment := FVerticalScrollBar.width
    else
      Increment := 0;
    FX := Max(0, Round(ClientWidth / 2 - Increment - FFullImage.Width * FZoom / 2));
  end;
  if FVerticalScrollBar.Visible then
  begin
    FY := 0;
  end else
  begin
    if FHorizontalScrollBar.Visible then
      Increment := FHorizontalScrollBar.Height
    else
      Increment := 0;
    FY := Max(0,
      Round(HeightW / 2 - Increment - FFullImage.Height * FZoom / 2));
  end;
  if FVerticalScrollBar.Visible then
    Increment := FVerticalScrollBar.width
  else
    Increment := 0;
  FW := Round(Min(ClientWidth - Increment, FFullImage.Width * FZoom));
  if FHorizontalScrollBar.Visible then
    Increment := FHorizontalScrollBar.Height
  else
    Increment := 0;
  FH := Round(Min(HeightW - Increment, FFullImage.Height * FZoom));
  FH := FH;

  Result := Rect(FX, FY, FW + FX, FH + FY);
end;

function TImageViewerControl.GetIsFastDrawing: Boolean;
begin
  Result := False;
end;

function TImageViewerControl.GetItem: TDBPopupMenuInfoRecord;
begin
  //TODO:
  Result := nil;
end;

function TImageViewerControl.HeightW: Integer;
begin
  Result := ClientHeight;
end;

procedure TImageViewerControl.OnScrollChanged(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if ScrollPos > (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize then
    ScrollPos := (Sender as TScrollBar).Max - (Sender as TScrollBar).PageSize;
  RecreateImage;
end;


procedure TImageViewerControl.WMPrintClient(var Message: TWMPrintClient);
begin
  inherited;
  BitBlt(Message.DC, 0, 0, Buffer.Width, Buffer.Height, Buffer.Canvas.Handle, 0, 0, SRCCOPY);
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

  if (FRealImageWidth > ClientWidth) or (FRealImageHeight > HeightW) then
  begin
    if FRealImageWidth / FRealImageHeight < FDrawImage.Width / FDrawImage.Height then
    begin
      FH := FDrawImage.Height;
      FW := Round(FDrawImage.Height * (FRealImageWidth / FRealImageHeight));
    end else
    begin
      FW := FDrawImage.Width;
      FH := Round(FDrawImage.Width * (FRealImageHeight / FRealImageWidth));
    end;
  end else
  begin
    FH := FRealImageHeight;
    FW := FRealImageWidth;
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
    Zoom := FZoom * FRealImageWidth / FFullImage.Width;

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
              TempImage.PixelFormat := Pf24bit;
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
          Z := RealZoomInc * Zoom
        else
        begin
          if FRealImageWidth * FRealImageHeight <> 0 then
          begin
            if {(Item.Rotation = DB_IMAGE_ROTATE_90) or
              (Item.Rotation = DB_IMAGE_ROTATE_270)}False then
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
        ImRect := Rect(Round(FHorizontalScrollBar.Position / Zoom), Round((FVerticalScrollBar.Position) / Zoom),
          Round((FHorizontalScrollBar.Position + ZW) / Zoom), Round((FVerticalScrollBar.Position + ZH) / Zoom));
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
var
  Inc_: Integer;
  Pos, M, Ps: Integer;
  V1, V2: Boolean;
begin
  //Panel1.Visible := False;
  if not FZoomerOn then
  begin
    FHorizontalScrollBar.Position := 0;
    FHorizontalScrollBar.Visible := False;
    FVerticalScrollBar.Position := 0;
    FVerticalScrollBar.Visible := False;
    Exit;
  end;
  V1 := FHorizontalScrollBar.Visible;
  V2 := FVerticalScrollBar.Visible;
  if not FHorizontalScrollBar.Visible and not FVerticalScrollBar.Visible then
  begin
    FHorizontalScrollBar.Visible := FFullImage.Width * FZoom > ClientWidth;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FVerticalScrollBar.Visible := FFullImage.Height * FZoom > HeightW - Inc_;
  end;
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FHorizontalScrollBar.Visible := FFullImage.Width * FZoom > ClientWidth - Inc_;
    FHorizontalScrollBar.Width := ClientWidth - Inc_;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FHorizontalScrollBar.Top := HeightW - Inc_;
  end;
  begin
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FVerticalScrollBar.Visible := FFullImage.Height * FZoom > HeightW - Inc_;
    FVerticalScrollBar.Height := HeightW - Inc_;
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FVerticalScrollBar.Left := ClientWidth - Inc_;
  end;
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    FHorizontalScrollBar.Visible := FFullImage.Width * FZoom > ClientWidth - Inc_;
    FHorizontalScrollBar.Width := ClientWidth - Inc_;
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    FHorizontalScrollBar.Top := HeightW - Inc_;
  end;
  if not FHorizontalScrollBar.Visible then
    FHorizontalScrollBar.Position := 0;
  if not FVerticalScrollBar.Visible then
    FVerticalScrollBar.Position := 0;
  if FHorizontalScrollBar.Visible and not V1 then
  begin
    FHorizontalScrollBar.PageSize := 0;
    FHorizontalScrollBar.Position := 0;
    FHorizontalScrollBar.Max := 100;
    FHorizontalScrollBar.Position := 50;
  end;
  if FVerticalScrollBar.Visible and not V2 then
  begin
    FVerticalScrollBar.PageSize := 0;
    FVerticalScrollBar.Position := 0;
    FVerticalScrollBar.Max := 100;
    FVerticalScrollBar.Position := 50;
  end;

  {Panel1.Width := FVerticalScrollBar.Width;
  Panel1.Height := FHorizontalScrollBar.Height;
  Panel1.Left := ClientWidth - Panel1.Width;
  Panel1.Top := HeightW - Panel1.Height;
  Panel1.Visible := FHorizontalScrollBar.Visible and FVerticalScrollBar.Visible;}

  if FHorizontalScrollBar.Visible then
  begin
    if FVerticalScrollBar.Visible then
      Inc_ := FVerticalScrollBar.Width
    else
      Inc_ := 0;
    M := Round(FFullImage.Width * FZoom);
    Ps := ClientWidth - Inc_;
    if Ps > M then
      Ps := 0;
    if (FHorizontalScrollBar.Max <> FHorizontalScrollBar.PageSize) then
      Pos := Round(FHorizontalScrollBar.Position * ((M - Ps) / (FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize)))
    else
      Pos := FHorizontalScrollBar.Position;
    if M < FHorizontalScrollBar.PageSize then
      FHorizontalScrollBar.PageSize := Ps;
    FHorizontalScrollBar.Max := M;
    FHorizontalScrollBar.PageSize := Ps;
    FHorizontalScrollBar.LargeChange := Ps div 10;
    FHorizontalScrollBar.Position := Min(FHorizontalScrollBar.Max, Pos);
  end;
  if FVerticalScrollBar.Visible then
  begin
    if FHorizontalScrollBar.Visible then
      Inc_ := FHorizontalScrollBar.Height
    else
      Inc_ := 0;
    M := Round(FFullImage.Height * FZoom);
    Ps := HeightW - Inc_;
    if Ps > M then
      Ps := 0;
    if FVerticalScrollBar.Max <> FVerticalScrollBar.PageSize then
      Pos := Round(FVerticalScrollBar.Position * ((M - Ps) / (FVerticalScrollBar.Max - FVerticalScrollBar.PageSize)))
    else
      Pos := FVerticalScrollBar.Position;
    if M < FVerticalScrollBar.PageSize then
      FVerticalScrollBar.PageSize := Ps;
    FVerticalScrollBar.Max := M;
    FVerticalScrollBar.PageSize := Ps;
    FVerticalScrollBar.LargeChange := Ps div 10;
    FVerticalScrollBar.Position := Min(FVerticalScrollBar.Max, Pos);
  end;
  if FHorizontalScrollBar.Position > FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize then
    FHorizontalScrollBar.Position := FHorizontalScrollBar.Max - FHorizontalScrollBar.PageSize;
  if FVerticalScrollBar.Position > FVerticalScrollBar.Max - FVerticalScrollBar.PageSize then
    FVerticalScrollBar.Position := FVerticalScrollBar.Max - FVerticalScrollBar.PageSize;
end;

procedure TImageViewerControl.RefreshFaces;
begin
  //TODO:
end;

procedure TImageViewerControl.Resize;
begin
  inherited;

  FDrawImage.SetSize(ClientWidth, HeightW);

  if not FIsWaiting then
    ReAlignScrolls(False);

  //LsLoading.Left := ClientWidth div 2 - LsLoading.Width div 2;
  //LsLoading.Top := ClientHeight div 2 - LsLoading.Height div 2;

  RecreateImage;
  //CheckFaceIndicatorVisibility;
  Repaint;
end;

end.
