
{*******************************************************}
{                                                       }
{       Image Controls                                  }
{       Библиотека для работы с изображениями           }
{                                                       }
{       Copyright (c) 2004-2005, Михаил Мостовой        }
{                               (s-mike)                }
{       http://mikesoft.front.ru                        }
{       http://forum.sources.ru                         }
{                                                       }
{*******************************************************}

// !!!
// TODO: NavigatorForm component?

{
@abstract(Дополнительные компоненты, расширяющие возможности работы с
  @link(TCustomScrollingImage).)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(1 декабря, 2004)
@lastmod(10 апреля, 2005)
}

unit ScrollingImageAddons;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Messages, Graphics, ScrollingImage;

type
  {@exclude}
  TOwnShape = class;

  { Тип события отрисовки рамки навигатора. }
  TNavShapePaintEvent = procedure(Sender: TOwnShape) of object;

  //{ @abstract(Компонент, использующийся в качестве рамки
  //  навигатора @link(TScrollingImageNavigator).) }
  {@exclude}
  TOwnShape = class(TGraphicControl)
  private
    FPen: TPen;
    FBrush: TBrush;
    FOnPaint: TNavShapePaintEvent;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
  protected                                             {@exclude}
    procedure Paint; override;
  public                                                {@exclude}
    constructor Create(AOwner: TComponent); override;   {@exclude}
    destructor Destroy; override;

    {@exclude}
    property Canvas;    
  published                                             {@exclude}
    procedure StyleChanged(Sender: TObject);
                                                        {@exclude}
    property Brush: TBrush read FBrush write SetBrush;  {@exclude}
    property Cursor default crSizeAll;                  {@exclude}
    property Enabled;                                   {@exclude}
    property ParentShowHint;                            {@exclude}
    property Pen: TPen read FPen write SetPen;          {@exclude}
    property ShowHint;                                  {@exclude}
    property Visible;
                                                        {@exclude}
    property OnClick;                                   {@exclude}
    property OnContextPopup;                            {@exclude}
    property OnPaint: TNavShapePaintEvent read FOnPaint write FOnPaint;
                                                        {@exclude}
    property OnResize;
  end;

  { Событие, которое вызывается при необходимости изменения навигатора.
    Параметр <b>ABitmap</b> указывает переменную для загрузки нового
    изображения навигатора. }
  TCustomNavigatorEvent = procedure(const ABitmap: TBitmap) of object;
  { Событие для вызова альтернативных методов масштабирования навигатора.
    Параметры <b>ASource</b>, <b>ADest</b> указывают на соответственно
    оригинальное и смасштабированое изображение, а параметры
    <b>AWidth</b>, <b>AHeight</b> указывают размеры,
    к которым должно быть смасштабировано изображение. }
  TCustomScalingEvent = procedure(const ASource, ADest: TBitmap;
    const AWidth, AHeight: Integer) of object;

  { Тип изменения навигатора при установленном в True
    свойстве @link(CustomNavigator). От значения свойства зависит,
    когда будет изменяться изображение навигатора. }
  TNavigatorChange = (
    { Изображение навигатора изменяется при вызове события
      @link(OnCustomNavigator). }
    ncAuto,
    { Изображение навигатора изменяется только
      при вызове процедуры @link(SetNavigator), которая непосредственно
      задает новое изображение навигатора. }
    ncManual
  );

  {@exclude}
  TScrollingImageNavigator = class;

  { Тип события отрисовки навигатора. }
  TNavigatorPaintEvent = procedure(Sender: TScrollingImageNavigator; Bitmap: TBitmap) of object;

  { @abstract(Компонент, реализующий навигатор для @link(TCustomScrollingImage).) }  
  TScrollingImageNavigator = class(TCustomControl)
  private
    FShape: TOwnShape;
    FScrollingImage: TCustomScrollingImage;
    FBitmap: TBitmap;
    FOldOnChangePos: TNotifyEvent;
    FOldOnChangeImage: TNotifyEvent;
    FOldOnResize: TNotifyEvent;
    FScaleFactor, FHScaleFactor, FVScaleFactor: Extended;
    FBitmapLeft, FBitmapTop: Integer;
    FDraggingShape: Boolean;
    FCustomNavigator: Boolean;
    FOnCustomNavigator: TCustomNavigatorEvent;
    FOnCustomScaling: TCustomScalingEvent;
    FNavigatorChange: TNavigatorChange;
    FOnPaint: TNavigatorPaintEvent;
    function PointInBitmap(const X, Y: Integer): Boolean;
    procedure SetScrollingImage(const Value: TCustomScrollingImage);
    procedure OnImageChanged(Sender: TObject);
    procedure OnPosChanged(Sender: TObject);
    procedure OnSizeChanged(Sender: TObject);
    procedure ShapeMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure SetCustomNavigator(const Value: Boolean);
  protected                                                           {@exclude}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;                                       {@exclude}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override; {@exclude}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;                                       {@exclude}
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;                               {@exclude}
    procedure Paint; override;                                        {@exclude}
    procedure Resize; override;

    // Вызывается для задания позиции рамки навигатора
    {@exclude}
    procedure ChangeShapePosition(const X, Y: Integer); virtual;
    // Вызывается при изменении изображения компонента TCustomScrollingImage
    {@exclude}
    procedure ImageChanged; virtual;
    // Вызывается при изменении позиции изображения в компоненте TCustomScrollingImage
    {@exclude}
    procedure PosChanged; virtual;
    // Вызывается при изменении размеров компонента
    {@exclude}
    procedure SizeChanged; virtual;
  public                                               {@exclude}
    constructor Create(AOwner: TComponent); override;  {@exclude}
    destructor Destroy; override;

    { Изменяет изображение навигатора при значении свойства
      @link(NavigatorChange) = ncManual. }
    procedure SetNavigator(const ABitmap: TBitmap);

    {@exclude}
    property Canvas;
  published
    { Определяет, нужно ли компоненту использовать событие
      @link(OnCustomNavigator) для получения нового изображения навигатора
      при необходимости его обновления. }
    property CustomNavigator: Boolean read FCustomNavigator write SetCustomNavigator default False;
    { Определяет, автоматически или вручную будет изменяться
      изображение навигатора при @link(CustomNavigator)=True. }
    property NavigatorChange: TNavigatorChange read FNavigatorChange write FNavigatorChange default ncAuto;
    { Определяет связанный компонент-наследник TCustomScrollingImage. }
    property ScrollingImage: TCustomScrollingImage read FScrollingImage write SetScrollingImage;
    { Позволяет изменить параметры рамки навигатора. }
    property Shape: TOwnShape read FShape;

    { Событие, вызываемое при необходимости замены изображения навигатора,
      если @link(CustomNavigator)=True и @link(NavigatorChange)=ncAuto. }
    property OnCustomNavigator: TCustomNavigatorEvent read FOnCustomNavigator write FOnCustomNavigator;
    { Позволяет использовать другой метод масштабирования
      изображения навигатора. }
    property OnCustomScaling: TCustomScalingEvent read FOnCustomScaling write FOnCustomScaling;
    { Событие вызыватся при необходимости перерисовки компонента. }
    property OnPaint: TNavigatorPaintEvent read FOnPaint write FOnPaint;
                                     {@exclude}
    property Align;                  {@exclude}
    property Anchors;                {@exclude}
    property Color;                  {@exclude}
    property Constraints;            {@exclude}
    property Cursor default crCross; {@exclude}
    property DragCursor;             {@exclude}
    property DragKind;               {@exclude}
    property DragMode;               {@exclude}
    property Enabled;                {@exclude}    
    property ParentColor;            {@exclude}
    property PopupMenu;              {@exclude}
    property ShowHint;               {@exclude}
    property ParentShowHint;         {@exclude}
    property Visible;
                                     {@exclude}
    property OnClick;                {@exclude}
    property OnContextPopup;         {@exclude}
    property OnDblClick;             {@exclude}
    property OnDragDrop;             {@exclude}
    property OnDragOver;             {@exclude}
    property OnEndDock;              {@exclude}
    property OnEndDrag;              {@exclude}
    property OnMouseDown;            {@exclude}
    property OnMouseMove;            {@exclude}
    property OnMouseUp;              {@exclude}
    property OnResize;               {@exclude}
    property OnStartDock;            {@exclude}
    property OnStartDrag;
  end;

implementation

uses Types, Math;

// *****************************************************************************
//   TOwnShape
// *****************************************************************************

constructor TOwnShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  SetSubComponent(True);

  ControlStyle := ControlStyle + [csReplicatable];
  Width := 65;
  Height := 65;
  FPen := TPen.Create;
  FPen.Color := clRed;
  FPen.Width := 2;
  FPen.OnChange := StyleChanged;

  FBrush := TBrush.Create;
  FBrush.Style := bsClear;
  FBrush.OnChange := StyleChanged;

  Cursor := crSizeAll;
end;

destructor TOwnShape.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

procedure TOwnShape.Paint;
var
  X, Y, W, H: Integer;
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self)
  else
  with Canvas do
  begin
    Pen := FPen;
    Brush := FBrush;
    X := Pen.Width div 2;
    Y := X;
    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    Rectangle(X, Y, X + W, Y + H);
  end;
end;

procedure TOwnShape.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TOwnShape.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TOwnShape.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

// *****************************************************************************
//   TScrollingImageNavigator
// *****************************************************************************і

procedure TScrollingImageNavigator.ChangeShapePosition(const X,
  Y: Integer);
begin
  if Assigned(FScrollingImage) and (FScaleFactor > 0) then
    FScrollingImage.ImagePos :=
      Point(Trunc((X - FBitmapLeft - FShape.Width div 2) / FHScaleFactor),
            Trunc((Y - FBitmapTop - FShape.Height div 2) / FVScaleFactor));
end;

procedure TScrollingImageNavigator.CMColorChanged(var Message: TMessage);
begin
  Invalidate;
end;

constructor TScrollingImageNavigator.Create(AOwner: TComponent);
begin
  inherited;

  FScaleFactor := 0;
  FHScaleFactor := 0;
  FVScaleFactor := 0;

  FOldOnChangePos := nil;
  FOldOnChangeImage := nil;
  FOldOnResize := nil;

  ScrollingImage := nil;
  // Именно так, а не FScrollingImage := nil, потому что таким образом
  // автоматически вызывается обработчик ScrollingImageChanged
  FShape := TOwnShape.Create(Self);
  FShape.Name := 'NavShape';
  FShape.Parent := Self;
  FShape.OnMouseDown := ShapeMouseDown;
  FShape.OnMouseMove := ShapeMouseMove;
  FShape.OnMouseUp := ShapeMouseUp;

  FBitmap := TBitmap.Create;

  Cursor := crCross;
  FCustomNavigator := False;
  FNavigatorChange := ncAuto;
end;

destructor TScrollingImageNavigator.Destroy;
begin
  FBitmap.Free;

  inherited;
end;

procedure TScrollingImageNavigator.ImageChanged;
begin
  if (not Assigned(FScrollingImage)) or (FScrollingImage.Empty) then Exit;

  if FCustomNavigator then
  begin
    if (FNavigatorChange = ncAuto) and Assigned(FOnCustomNavigator) then FOnCustomNavigator(FBitmap);
    FScaleFactor := FBitmap.Width / FScrollingImage.PictureWidth;
    FHScaleFactor := FBitmap.Width / FScrollingImage.PictureWidth;
    FVScaleFactor := FBitmap.Height / FScrollingImage.PictureHeight;
  end else begin
    if ClientWidth < ClientHeight then
      FScaleFactor := ClientWidth / FScrollingImage.PictureWidth
    else
      FScaleFactor := ClientHeight / FScrollingImage.PictureHeight;
    FHScaleFactor := FScaleFactor;
    FVScaleFactor := FScaleFactor;
    FBitmap.Width := Round(FScrollingImage.PictureWidth * FScaleFactor);
    FBitmap.Height := Round(FScrollingImage.PictureHeight * FScaleFactor);
    if Assigned(FOnCustomScaling) then
      FOnCustomScaling(FScrollingImage.Picture, FBitmap, FBitmap.Width, FBitmap.Height)
    else
      FBitmap.Canvas.StretchDraw(FBitmap.Canvas.ClipRect, FScrollingImage.Picture);
  end;

  FBitmapLeft := (ClientWidth - FBitmap.Width) div 2;
  FBitmapTop := (ClientHeight - FBitmap.Height) div 2;

  SizeChanged;
  PosChanged;
end;

procedure TScrollingImageNavigator.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if not PointInBitmap(X, Y) then Exit;

  if Button = mbLeft then
  begin
    FDraggingShape := True;
    ChangeShapePosition(X, Y);
  end;
end;

procedure TScrollingImageNavigator.MouseMove(Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if FDraggingShape then
    ChangeShapePosition(X, Y)
  else
    if PointInBitmap(X, Y) then
      Screen.Cursor := crDefault
    else
      Screen.Cursor := crArrow;
end;

procedure TScrollingImageNavigator.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  FDraggingShape := False;
end;

procedure TScrollingImageNavigator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FScrollingImage) then
      ScrollingImage := nil;
  end;
end;

procedure TScrollingImageNavigator.OnImageChanged(Sender: TObject);
begin
  ImageChanged;
  Invalidate;

  if Assigned(FOldOnChangeImage) then FOldOnChangeImage(Sender);
end;

procedure TScrollingImageNavigator.OnPosChanged(Sender: TObject);
begin
  PosChanged;

  if Assigned(FOldOnChangePos) then FOldOnChangePos(Sender);
end;

procedure TScrollingImageNavigator.OnSizeChanged(Sender: TObject);
begin
  SizeChanged;

  if Assigned(FOldOnResize) then FOldOnResize(Sender);
end;

procedure TScrollingImageNavigator.Paint;
begin
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Pen.Color := clBlack;
      Brush.Color := Color;
      Brush.Style := bsSolid;
      Rectangle(0, 0, ClientWidth, ClientHeight);
    end;

  if Assigned(FOnPaint) then
    FOnPaint(Self, FBitmap)
  else
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect(0, 0, ClientWidth, FBitmapTop));
    FillRect(Rect(0, FBitmapTop + FBitmap.Height, ClientWidth, ClientHeight));
    FillRect(Rect(0, 0, FBitmapLeft, ClientHeight));
    FillRect(Rect(FBitmapLeft + FBitmap.Width, 0, ClientWidth, ClientHeight));
    Draw(FBitmapLeft, FBitmapTop, FBitmap);
  end;
end;

function TScrollingImageNavigator.PointInBitmap(const X,
  Y: Integer): Boolean;
begin
  Result := not
    ((X < FBitmapLeft) or (Y < FBitmapTop) or
     (X > FBitmapLeft + FBitmap.Width) or (Y > FBitmapTop + FBitmap.Height));
end;

procedure TScrollingImageNavigator.PosChanged;
var
  NewLeft, NewTop: Integer;
begin
  NewLeft := FBitmapLeft + Round(FHScaleFactor * FScrollingImage.ImageLeft);
  if NewLeft < 0 then NewLeft := 0 else
    if NewLeft + FShape.Width > ClientWidth then NewLeft := ClientWidth - FShape.Width;
  NewTop := FBitmapTop + Round(FVScaleFactor * FScrollingImage.ImageTop);
  if NewTop < 0 then NewTop := 0 else
    if NewTop + FShape.Height > ClientHeight then NewTop := ClientHeight - FShape.Height;

  FShape.SetBounds(NewLeft, NewTop, FShape.Width, FShape.Height);
end;

procedure TScrollingImageNavigator.Resize;
begin
  inherited Resize;

  ImageChanged;
end;

procedure TScrollingImageNavigator.SetCustomNavigator(
  const Value: Boolean);
begin
  if FCustomNavigator <> Value then
  begin
    FCustomNavigator := Value;
    ImageChanged;
  end;
end;

procedure TScrollingImageNavigator.SetNavigator(const ABitmap: TBitmap);
begin
  if FNavigatorChange = ncAuto then Exit;

  FBitmap.Assign(ABitmap);
  ImageChanged;
end;

procedure TScrollingImageNavigator.SetScrollingImage(
  const Value: TCustomScrollingImage);
begin
  if FScrollingImage <> Value then
  begin
    if not (csDesigning in ComponentState) then
      if Assigned(FScrollingImage) then
        with FScrollingImage do
        begin
          OnChangePos := FOldOnChangePos;
          OnChangeImage := FOldOnChangeImage;
          OnChangeSize := FOldOnResize;
        end;

    FScrollingImage := Value;

    if not (csDesigning in ComponentState) then
      if Assigned(FScrollingImage) then
        with FScrollingImage do
        begin
          FOldOnChangePos := OnChangePos;
          FOldOnChangeImage := OnChangeImage;
          FOldOnResize := OnResize;

          OnChangePos := OnPosChanged;
          OnChangeImage := OnImageChanged;
          OnChangeSize := OnSizeChanged;
        end;
        
    ImageChanged;
  end;
end;

procedure TScrollingImageNavigator.ShapeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDraggingShape := True;
    ChangeShapePosition(FShape.Left + X, FShape.Top + Y);
  end;
end;

procedure TScrollingImageNavigator.ShapeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDraggingShape then
    ChangeShapePosition(FShape.Left + X, FShape.Top + Y)
  else
    Screen.Cursor := crDefault;
end;

procedure TScrollingImageNavigator.ShapeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDraggingShape := False;
end;

procedure TScrollingImageNavigator.SizeChanged;
var
  NewWidth, NewHeight: Integer;
begin
  NewWidth := Round(FHScaleFactor * Min(ScrollingImage.PictureWidth, ScrollingImage.ClientWidth));
  if NewWidth > ClientWidth then NewWidth := ClientWidth;
  NewHeight := Round(FVScaleFactor * Min(ScrollingImage.PictureHeight, ScrollingImage.ClientHeight));
  if NewHeight > ClientHeight then NewHeight := ClientHeight;

  FShape.SetBounds(FShape.Left, FShape.Top, NewWidth, NewHeight);
end;

procedure TScrollingImageNavigator.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

end.
