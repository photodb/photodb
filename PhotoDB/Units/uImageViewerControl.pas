unit uImageViewerControl;

interface

uses
  Windows,
  Graphics,
  Messages,
  uMemory,
  Controls,
  Classes,
  StdCtrls,
  Math,
  GraphicsCool,
  UnitDBDeclare,
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
    FRealImageWidth: Integer;
    FRealImageHeight: Integer;
    function Buffer: TBitmap;
    procedure RecreateImage;
    function GetIsFastDrawing: Boolean;
    function GetSbHorisontal: TScrollBar;
    function GetSbVertical: TScrollBar;
    procedure RefreshFaces;
    function GetItem: TDBPopupMenuInfoRecord;
    function GetImageRectA: TRect;
    function HeightW: Integer;
  protected
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Paint(var Message: TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FastLoadImage(Image: TBitmap);
    property IsFastDrawing: Boolean read GetIsFastDrawing;
    property SbVertical: TScrollBar read GetSbVertical;
    property SbHorisontal: TScrollBar read GetSbHorisontal;
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

  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;

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

procedure TImageViewerControl.FastLoadImage(Image: TBitmap);
begin
  Buffer.Assign(Image);
  Repaint;
end;

function TImageViewerControl.GetImageRectA: TRect;
var
  Increment: Integer;
  FX, FY, FH, FW: Integer;
begin
  if SbHorisontal.Visible then
  begin
    FX := 0;
  end else
  begin
    if SbVertical.Visible then
      Increment := SbVertical.width
    else
      Increment := 0;
    FX := Max(0, Round(ClientWidth / 2 - Increment - FFullImage.Width * FZoom / 2));
  end;
  if SbVertical.Visible then
  begin
    FY := 0;
  end else
  begin
    if SbHorisontal.Visible then
      Increment := SbHorisontal.Height
    else
      Increment := 0;
    FY := Max(0,
      Round(HeightW / 2 - Increment - FFullImage.Height * FZoom / 2));
  end;
  if SbVertical.Visible then
    Increment := SbVertical.width
  else
    Increment := 0;
  FW := round(Min(ClientWidth - Increment, FFullImage.Width * FZoom));
  if SbHorisontal.Visible then
    Increment := SbHorisontal.Height
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

end;

function TImageViewerControl.GetSbHorisontal: TScrollBar;
begin

end;

function TImageViewerControl.GetSbVertical: TScrollBar;
begin

end;

function TImageViewerControl.HeightW: Integer;
begin
  Result := ClientHeight;
end;

procedure TImageViewerControl.Paint(var Message: TWMPaint);
begin
  inherited;
  DrawBackground(FCanvas);
  FCanvas.Draw(0, 0, Buffer);
end;

procedure TImageViewerControl.RecreateImage;
var
  Fh, Fw: Integer;
  Zx, Zy, Zw, Zh, X1, X2, Y1, Y2: Integer;
  ImRect, BeginRect: TRect;
  FileName: string;
  Z: Double;
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
  FDrawImage.Width := Clientwidth;
  FDrawImage.Height := HeightW;
  FDrawImage.Canvas.Brush.Color := Theme.WindowColor;
  FDrawImage.Canvas.Pen.Color := Theme.WindowColor;
  FDrawImage.Canvas.Rectangle(0, 0, FDrawImage.Width, FDrawImage.Height);
  if (FFullImage.Height = 0) or (FFullImage.Width = 0) then
    begin
      ShowErrorText(FileName);
      Refresh;
      Exit;
    end;
  if (FFullImage.Width > ClientWidth) or (FFullImage.Height > HeightW) then
  begin
    if FFullImage.Width / FFullImage.Height < FDrawImage.Width / FDrawImage.Height then
    begin
      FH := FDrawImage.Height;
      FW := Round(FDrawImage.Height * (FFullImage.Width / FFullImage.Height));
    end else
    begin
      FW := FDrawImage.Width;
      FH := Round(FDrawImage.Width * (FFullImage.Height / FFullImage.Width));
    end;
  end else
  begin
    FH := FFullImage.Height;
    FW := FFullImage.Width;
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
  if FImageExists or FLoading then
  begin
    if not IsFastDrawing then
    begin
      if FZoomerOn and not FIsWaiting then
      begin
        DrawRect(ImRect.Left, ImRect.Top, ImRect.Right, ImRect.Bottom);
        if FZoom <= 1 then
        begin
          if (FZoom < ZoomSmoothMin) then
            StretchCoolW(ZX, ZY, ZW, ZH, Rect(Round(SbHorisontal.Position / FZoom), Round(SbVertical.Position / FZoom),
                Round((SbHorisontal.Position + ZW) / FZoom), Round((SbVertical.Position + ZH) / FZoom)), FFullImage, FDrawImage)
          else
          begin
            ACopyRect := Rect(Round(SbHorisontal.Position / FZoom), Round(SbVertical.Position / FZoom),
              Round((SbHorisontal.Position + ZW) / FZoom), Round((SbVertical.Position + ZH) / FZoom));
            TempImage := TBitmap.Create;
            try
              TempImage.PixelFormat := Pf24bit;
              TempImage.Width := ZW;
              TempImage.Height := ZH;
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
          Interpolate(ZX, ZY, ZW, ZH, Rect(Round(SbHorisontal.Position / FZoom), Round(SbVertical.Position / FZoom),
              Round((SbHorisontal.Position + ZW) / FZoom), Round((SbVertical.Position + ZH) / FZoom)), FFullImage, FDrawImage);
      end else
      begin
        DrawRect(X1, Y1, X2, Y2);
        if FZoomerOn then
          Z := RealZoomInc * FZoom
        else
        begin
          if FRealImageWidth * FRealImageHeight <> 0 then
          begin
            if (Item.Rotation = DB_IMAGE_ROTATE_90) or
              (Item.Rotation = DB_IMAGE_ROTATE_270) then
              Z := Min(FW / FRealImageHeight, FH / FRealImageWidth)
            else
              Z := Min(FW / FRealImageWidth, FH / FRealImageHeight);
          end else
            Z := 1;
        end;
        if (Z < ZoomSmoothMin) then
          StretchCool(X1, Y1, X2 - X1, Y2 - Y1, FFullImage, FDrawImage)
        else
        begin
          TempImage := TBitmap.Create;
          try
            TempImage.PixelFormat := Pf24bit;
            TempImage.Width := X2 - X1;
            TempImage.Height := Y2 - Y1;
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
        ImRect := Rect(Round(SbHorisontal.Position / FZoom), Round((SbVertical.Position) / FZoom),
          Round((SbHorisontal.Position + ZW) / FZoom), Round((SbVertical.Position + ZH) / FZoom));
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

procedure TImageViewerControl.RefreshFaces;
begin
  //TODO:
end;

end.
