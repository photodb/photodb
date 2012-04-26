
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

{
@abstract(Компоненты для статичного отображения TBitmap.)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(1 декабря, 2004)
@lastmod(10 апреля, 2005)
}

unit BitmapContainers;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Messages;

type
  { Тип обработчика события @link(OnPaint).
    <b>DestCanvas</b> определяет канву, на которую будет выводиться
    изображение;
    <b>X, Y, Width, Height</b> - координаты и размеры изображения, которое
      должно быть выведено на экран;
    <b>XSrc, YSrc</b> - координаты части исходного изображения, которую нужно
      отрисовывать;
    <b>SrcBitmap</b> - указатель на исходное изображение. }
  TPaintImageEvent = procedure(DestCanvas: TCanvas;
    const X, Y, Width, Height,
          XSrc, YSrc: Integer;
          SrcBitmap: TBitmap) of object;

  { @abstract(Компонент для отображения TBitmap.
    Используется в качестве контейнера изображения в классе
    @link(TFastScrollingImage), а также может использоваться
    в некоторых случаях вместо TImage.
    Не поддерживает прозрачность, чтобы обойтись без мерцания.) }
  TBitmapContainer = class(TGraphicControl)
  private
    FPicture: TBitmap;
    FOnPaint: TPaintImageEvent;
    FTransparent: Boolean;
    procedure SetPicture(const Value: TBitmap);

    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    function GetPicture: TBitmap;
    procedure SetTransparent(const Value: Boolean);
  protected                                                    {@exclude}
    procedure Paint; override;
  public                                                       {@exclude}
    constructor Create(AOwner: TComponent); override;          {@exclude}
    destructor Destroy; override;
  published
    { Отображаемое компонентом изображение. }
    property Picture: TBitmap read GetPicture write SetPicture;
    { Определяет, будет ли закрашиваться часть компонента, не занятая рисунком
      или вместо неё будет копироваться часть фона. }
    property Transparent: Boolean read FTransparent write SetTransparent default False;

    { Вызывается вместо стандартной процедуры отрисовки изображения в компоненте,
      может быть использовано для нестандартной отрисовки. }
    property OnPaint: TPaintImageEvent read FOnPaint write FOnPaint;

                                                               {@exclude}
    property Align;                                            {@exclude}
    property Anchors;                                          {@exclude}
    property Color;                                            {@exclude}
    property Constraints;                                      {@exclude}
    property Cursor;                                           {@exclude}
    property DragCursor;                                       {@exclude}
    property DragKind;                                         {@exclude}
    property DragMode;                                         {@exclude}
    property Enabled;                                          {@exclude}
    property ParentColor;                                      {@exclude}
    property Visible;
                                                               {@exclude}
    property OnClick;                                          {@exclude}
    property OnContextPopup;                                   {@exclude}
    property OnDblClick;                                       {@exclude}
    property OnDragDrop;                                       {@exclude}
    property OnDragOver;                                       {@exclude}
    property OnEndDock;                                        {@exclude}
    property OnEndDrag;                                        {@exclude}
    property OnMouseDown;                                      {@exclude}
    property OnMouseMove;                                      {@exclude}
    property OnMouseUp;                                        {@exclude}
    property OnStartDock;                                      {@exclude}
    property OnStartDrag;
  end;

  { @abstract(Аналог компонента TPanel, созданный специально для отображения
    TBitmap без мерцания, как это бывает, например при изменении размеров
    формы с использованием TImage. Не поддерживает рельефной рамки.) }
  TBitmapPanel = class(TCustomControl)
  private
    FBitmapContainer: TBitmapContainer;
    function GetPicture: TBitmap;
    procedure SetPicture(const Value: TBitmap);

    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure SetTransparent(const Value: Boolean);
    function GetTransparent: Boolean;
  protected
    procedure Paint; override;
  public                                                       {@exclude}
    constructor Create(AOwner: TComponent); override;
  published
    { Отображаемое компонентом изображение. }
    property Picture: TBitmap read GetPicture write SetPicture;
    { Определяет, будет ли закрашиваться часть компонента, не занятая рисунком
      или вместо неё будет копироваться часть фона. }
    property Transparent: Boolean read GetTransparent write SetTransparent default False;    

                                   {@exclude}
    property Align;                {@exclude}
    property Anchors;              {@exclude}
    property Color;                {@exclude}
    property Constraints;          {@exclude}
    property Cursor;               {@exclude}
    property Enabled;              {@exclude}
    property ParentColor;          {@exclude}
    property PopupMenu;            {@exclude}
    property Height default 105;   {@exclude}
    property Width default 105;    {@exclude}
    property ShowHint;             {@exclude}
    property ParentShowHint;       {@exclude}
    property Visible;              
                                   {@exclude}
    property OnClick;              {@exclude}
    property OnContextPopup;       {@exclude}    
    property OnDblClick;           {@exclude}
    property OnDragDrop;           {@exclude}
    property OnDragOver;           {@exclude}
    property OnEndDock;            {@exclude}
    property OnEndDrag;            {@exclude}
    property OnMouseDown;          {@exclude}
    property OnMouseMove;          {@exclude}
    property OnMouseUp;            {@exclude}
    property OnResize;             {@exclude}
    property OnStartDock;          {@exclude}
    property OnStartDrag;
  end;

implementation

uses ScrollingImage, ImgCtrlUtils;

// *****************************************************************************
//   TBitmapContainer
// *****************************************************************************

constructor TBitmapContainer.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle := ControlStyle + [csOpaque];
  if AOwner is TFastScrollingImage then
  begin
//    FPicture := TFastScrollingImage(AOwner).Picture;
    ParentColor := True;
  end else
    FPicture := TBitmap.Create;
end;

destructor TBitmapContainer.Destroy;
begin
  if not (Owner is TFastScrollingImage) then
    FPicture.Free;

  inherited;
end;

function TBitmapContainer.GetPicture: TBitmap;
begin
  if Owner is TFastScrollingImage then
    Result := TFastScrollingImage(Owner).Picture
  else
    Result := FPicture;
end;

procedure TBitmapContainer.Paint;
var
  WidthIsGreater, HeightIsGreater: Boolean;
  L, T: Integer;
  TempParentImage: TBitmap;
begin
  if (csDesigning in ComponentState) and IsEmptyPicture(FPicture) then
  begin
    with Canvas do
    begin
      Brush.Color := Color;
      Brush.Style := bsSolid;
      Pen.Style := psDash;
      Pen.Color := clBlack;
      Rectangle(0, 0, ClientWidth, ClientHeight);
    end;
  end else begin
    L := 0;
    T := 0;
    WidthIsGreater := ClientWidth > Picture.Width;
    HeightIsGreater := ClientHeight > Picture.Height;
    if WidthIsGreater or HeightIsGreater then
    begin
      with Canvas do
      begin
        if FTransparent then
        begin
          TempParentImage := TBitmap.Create;
          try
            TempParentImage.Width := ClientWidth;
            TempParentImage.Height := ClientHeight;
            CopyParentImage(Self, TempParentImage.Canvas);

            if WidthIsGreater then
            begin
              L := (ClientWidth - Picture.Width) div 2;
              BitBlt(Canvas.Handle, 0, 0, L, ClientHeight, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
              BitBlt(Canvas.Handle, L + Picture.Width, 0, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, L + Picture.Width, 0, SRCCOPY);
            end;
            if HeightIsGreater then
            begin
              T := (ClientHeight - Picture.Height) div 2;
              BitBlt(Canvas.Handle, 0, 0, ClientWidth, T, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
              BitBlt(Canvas.Handle, 0, T + Picture.Height, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, 0, T + Picture.Height, SRCCOPY);
            end;
          finally
            TempParentImage.Free;
          end;
        end else begin
          Brush.Color := Color;
          Brush.Style := bsSolid;
          if WidthIsGreater then
          begin
            L := (ClientWidth - Picture.Width) div 2;
            FillRect(Rect(0, 0, L, ClientHeight));
            FillRect(Rect(L + Picture.Width, 0, ClientWidth, ClientHeight));
          end;
          if HeightIsGreater then
          begin
            T := (ClientHeight - Picture.Height) div 2;
            FillRect(Rect(0, 0, ClientWidth, T));
            FillRect(Rect(0, T + Picture.Height, ClientWidth, ClientHeight));
          end;
        end;
      end;
    end;

    if Assigned(FOnPaint) then
      FOnPaint(Canvas, L, T, ClientWidth, ClientHeight, 0, 0, FPicture)
    else
      BitBlt(Canvas.Handle, L, T, ClientWidth, ClientHeight, Picture.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

procedure TBitmapContainer.SetPicture(const Value: TBitmap);
begin
  FPicture.Assign(Value);
  Invalidate;
end;

procedure TBitmapContainer.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TBitmapContainer.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

// *****************************************************************************
//   TBitmapPanel
// *****************************************************************************

constructor TBitmapPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csAcceptsControls];
  FBitmapContainer := TBitmapContainer.Create(Self);
  with FBitmapContainer do
  begin
    Align := alClient;
    Parent := Self;
  end;
end;

function TBitmapPanel.GetPicture: TBitmap;
begin
  if Assigned(FBitmapContainer) then
    Result := FBitmapContainer.FPicture
  else
    Result := nil;
end;

function TBitmapPanel.GetTransparent: Boolean;
begin
  Result := FBitmapContainer.Transparent;
end;

procedure TBitmapPanel.Paint;
begin
//  inherited;                 
  CopyParentImage(Self, Canvas);
end;

procedure TBitmapPanel.SetPicture(const Value: TBitmap);
begin
  if Assigned(FBitmapContainer) then
    FBitmapContainer.SetPicture(Value);
end;

procedure TBitmapPanel.SetTransparent(const Value: Boolean);
begin
  FBitmapContainer.Transparent := Value;
end;

procedure TBitmapPanel.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

end.
