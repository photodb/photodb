
// TODO: Неправильно работает ScrollButton при значении <> mbLeft
// TODO: Обработка клавиш с клавиатуры. Есть проблемы с обработкой клавиш со стрелками (из-за скроллбаров?).
{*******************************************************}
{                                                       }
{       Image Controls                                  }
{       Библиотека для работы с изображениями           }
{                                                       }
{       Компоненты для скроллинга                       }
{       графических изображений                         }
{                                                       }
{       Copyright (c) 2004-2005, Михаил Мостовой        }
{                               (s-mike)                }
{       http://forum.sources.ru                         }
{       http://mikesoft.front.ru                        }
{                                                       }
{       Выражаю благодарность                           }
{       Александру Багелю (Rouse_) за ценную идею,      }
{       воплотившуюся в компонент TScrollingImage       }
{       http://forum.sources.ru                         }
{       http://rouse.front.ru                           }
{                                                       }
{*******************************************************}

{
@abstract(Определение класса @link(TCustomScrollingImage) и его основных наследников.)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(1 декабря, 2004)
@lastmod(10 апреля, 2005)
<p>Эти компоненты осуществляют хранение и скроллинг (при необходимости)
загруженного графического изображения.<p>

<p><b>Возможности:</b></p>
<ul>
<li>поддерживает курсоры, определяющие возможность скроллинга (рука отпущенная и хватающая);</li>
<li>автоматически центрирует изображение, если оно меньше, чем клиентская область;</li>
<li>масштабирование;</li>
<li>прозрачность;</li>
<li>возможность нестандартной отрисовки изображения в компоненте благодаря
наличию соответствующих событий;</li>
<li>масштабирование изображения по размеру компонента;</li>
<li>возможность изменения курсоров для скроллинга.</li>
</ul>
}

unit ScrollingImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, Types, Forms,
  BitmapContainers;

const
  { Определяет курсор, отображаемый при перемещении мыши над
    компонентом-наследником @link(TCustomScrollingImage),
    если скроллинг возможен. }
  crImageHand = 111;
  { Определяет курсор, отображаемый при скроллинге изображения мышью. }  
  crImageDrag = 222;

type
  { Событие, которое вызывается при необходимости смасштабировать изображение.
    Предназначение параметров следующее:
    <b>DestCanvas</b> определяет канву, на которую будет выводиться
    отмасштабированное изображение;
    <b>X, Y, Width, Height</b> - координаты и размеры выходного изображения;
    <b>XSrc, YSrc, SrcWidth, SrcHeight</b> - координаты и размеры части
      исходного изображения, которую нужно отмасштабировать;
    <b>SrcBitmap</b> - указатель на исходное изображение. }
  TScaleImageEvent = procedure(DestCanvas: TCanvas;
    const X, Y, Width, Height,
          XSrc, YSrc, SrcWidth, SrcHeight: Integer;
          SrcBitmap: TBitmap) of object;

  { Тип, определяющий качество масштабирования изображения в компоненте. }
  TStretchMode = Integer;

  { @abstract(Виртуальный класс, от которого наследуются все остальные компоненты
    для скроллинга графических изображений.
    В нем определены общие процедуры и свойства для всех этих компонентов.) }
  TCustomScrollingImage = class(TCustomControl)
  private
    FAutoCenter: Boolean;
    FPicture: TBitmap;
    FDragging: Boolean;
    FCanScroll: Boolean;

    { Разрешение скроллинга }
    FScrollEnabled, FHCanScroll, FVCanScroll: Boolean;
    { Высота изображения }
    FPictureWidth, FPictureHeight: Integer;
    { Позиция изображения, если его размеры меньше клиентской области }
    FPicCenterLeft, FPicCenterTop: Integer;
    FPicCenterRight, FPicCenterBottom: Integer;

    { В этих переменных хранится позиция курсора мыши на экране при скроллинге }
    FX, FY: Integer;
    { Левая (горизонтальная) и верхняя (вертикальная) позиция изображения }
    FLeft, FTop: Integer;

    FOnChangePos: TNotifyEvent;
    FOnChangeImage: TNotifyEvent;
    FOnChangeSize: TNotifyEvent;
    FZoom: Extended;
    { Вспомогательные переменные для хранения предварительно вычисленных значений
      процента увеличения изображения и его обратного значения для преобразования
      координат и размеров изображения. }
    FZoomPercent, FInvZoom: Extended;
    { Вспомогательные переменные для хранения предварительно вычисленных значений
      координат и размеров оригинального изображения, отображаемого в данный момент. }    
    FOriginalLeft, FOriginalTop,
    FSrcWidth, FSrcHeight: Integer;
    FOnScaleImage: TScaleImageEvent;

    { Запрщает обработку кликов мыши во время фокусировки компонента. }
    FClicksDisabled: Boolean;
    FOnPaint: TPaintImageEvent;
    FDragCursor: TCursor;
    FCanScrollCursor: TCursor;
    FScrollDisabledCursor: TCursor;
    FCanScrollWithMouse: Boolean;
    FTransparent: Boolean;
    FOnZoomChanged: TNotifyEvent;
    FAutoShrinkImage: Boolean;
    FAutoZoomImage: Boolean;

    FScrollButton: TMouseButton;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FStretchMode: TStretchMode;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;         

    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;

    procedure SetAutoCenter(const Value: Boolean);
    procedure SetImageLeft(const Value: Integer);
    procedure SetImageTop(const Value: Integer);
    procedure SetPicture(const Value: TBitmap);
    function GetImagePos: TPoint;
    procedure SetImagePos(const Value: TPoint);
    procedure SetCanScroll(const Value: Boolean);
    function GetRealLeft: Integer;
    function GetRealTop: Integer;
    function GetRealImagePos: TPoint;
    procedure SetZoom(const Value: Extended);
    procedure SetAutoShrinkImage(const Value: Boolean);
    procedure SetAutoZoomImage(const Value: Boolean);
    procedure SetCanScrollWithMouse(const Value: Boolean);
    procedure SetStretchMode(const Value: TStretchMode);
  protected
    // Проверяет и при надобнасти исправляет позицию изображения
    {@exclude}
    procedure CheckBounds; virtual;
    // Вызывает событие OnChangeImage
    {@exclude}
    procedure ChangeImage; virtual;
    {@exclude}
    procedure DoFitImage; virtual;
    {@exclude}
    procedure FitImageChanged; virtual;
    {@exclude}
    procedure ImageSizeChanged; virtual;
    // Изменяет позицию изображения на начальную (0, 0)
    {@exclude}
    procedure ResetImagePos; virtual;
    // Вызывается при изменении размера компонента
    {@exclude}
    procedure SizeChanged; virtual;
    // Вызывается при изменении масштаба изображения
    {@exclude}
    procedure ZoomChanged; virtual;
    {@exclude}
    procedure SetOnPaint(const Value: TPaintImageEvent); virtual;
    {@exclude}
    procedure SetTransparent(const Value: Boolean); virtual;

                                                      {@exclude}
    procedure CreateWnd; override;                    {@exclude}
    procedure PictureChanged(Sender: TObject);        {@exclude}
    procedure PictureNew(Sender: TObject);
                                                      {@exclude}
    procedure WndProc(var Message: TMessage); override;
  public                                              {@exclude}
    constructor Create(AOwner: TComponent); override; {@exclude}
    destructor Destroy; override;

    procedure Resize; override;                       {@exclude}
    { Ширина загруженного в компонент изображения. }
    property PictureWidth: Integer read FPictureWidth;
    { Высота загруженного в компонент изображения. }
    property PictureHeight: Integer read FPictureHeight;

    { Позволяет узнать, является ли изображение, хранящееся в свойстве
      @link(Picture) компонента, пустым. }
    function Empty: Boolean;
    { Возвращает масштаб изображения, для того чтобы оно полностью влезало в окно. }
    function GetFitImageScale: Extended;

    { Центрирует загруженное изображение. Работает только для изображений,
      которые больше, чем клиентская область компонента. }
    procedure CenterImage;
    { Осуществляет скроллинг изображения в начало. }
    procedure ScrollHome;
    { Осуществляет скроллинг изображения в конец. }
    procedure ScrollEnd;
    { Осуществляет скроллинг изображения на одну страницу вниз. }
    procedure ScrollPageDown;
    { Осуществляет скроллинг изображения на одну страницу вверх. }
    procedure ScrollPageUp;
    { Осуществляет скроллинг изображения на одну страницу влево. }
    procedure ScrollPageLeft;
    { Осуществляет скроллинг изображения на одну страницу вправо. }
    procedure ScrollPageRight;
    { Осуществляет скроллинг изображения на <b>DX</b> единиц по горизонтали
      и <b>DY</b> единиц по вертикали. }
    procedure ScrollImage(const DX, DY: Integer);

    { Запрет обновления компонента. Может быть использована при необходимости
      выполнить ряд действий с объектом @link(Picture) для избежания неприятного
      мерцания. Количество вызовов этой процедуры должно соответствовать
      количеству вызовов процедуры @link(EndUpdate),
      чтобы компонент нормально работал. }
    procedure BeginUpdate;
    { Разрешение обновления компонента. Каждый вызов процедуры
      @link(BeginUpdate) должен сопровождаться вызовом этой процедуры.
      Обновление компонента станет возможен после такого же количества
      вызовов EndUpdate, сколько было вызвано BeginUpdate. }
    procedure EndUpdate;

    { Загружает в свойство @link(Picture) компонента изображение,
      не являющееся TBitmap. }
    procedure LoadGraphic(AGraphic: TGraphic);

    { Позиция изображения. }
    property ImagePos: TPoint read GetImagePos write SetImagePos;
    { Реальная позиция изображения в компоненте, полезно, например, для отслеживания мыши. }
    property ImageOffset: TPoint read GetRealImagePos;
    { Реальная горизонтальная координата изображения в компоненте. }
    property ImageOffsetLeft: Integer read GetRealLeft;
    { Реальная вертикальная координата изображения в компоненте. }
    property ImageOffsetTop: Integer read GetRealTop;
    { Позволяет узнать, осуществляется ли в данный момент
      скроллинг изображения мышью. }
    property IsDragging: Boolean read FDragging;
  published
    { Автоматически центрирует изображение после его загрузки. }
    property AutoCenter: Boolean read FAutoCenter write SetAutoCenter default False;
    { Указывает, нужно ли увеличивать изображение до размеров компонента.
      При этом масштаб изображения можно по прежнему изменять программно.
      Изображение подгоняется только при изменении этого свойства или
      изменении размеров компонента. }
    property AutoZoomImage: Boolean read FAutoZoomImage write SetAutoZoomImage default False;
    { Указывает, нужно ли уменьшать изображение до размеров компонента.
      При этом масштаб изображения можно по прежнему изменять программно.
      Изображение подгоняется только при изменении этого свойства или
      изменении размеров компонента. }
    property AutoShrinkImage: Boolean read FAutoShrinkImage write SetAutoShrinkImage default False;    
    { Позволяет запретить или разрешить скроллинг изображения.
      Если изображение не больше, чем клиентская область компонента, то
      значение свойства не играет роли. }
    property CanScroll: Boolean read FCanScroll write SetCanScroll default True;
    { Разрешение/запрет скроллинга с помощью мыши. }
    property CanScrollWithMouse: Boolean read FCanScrollWithMouse write SetCanScrollWithMouse default True;
    { Определяет курсор когда изображение можно скроллить. }
    property CanScrollCursor: TCursor read FCanScrollCursor write FCanScrollCursor default crImageHand;
    { Определяет курсор, если изображение скроллится в данный момент
      мышью. }
    property DragImageCursor: TCursor read FDragCursor write FDragCursor default crImageDrag;
    { Курсор при запрещенном скроллинге или когда он невозможен. }
    property ScrollDisabledCursor: TCursor read FScrollDisabledCursor write FScrollDisabledCursor default crDefault;
    { Левая (горизонтальная) позиция изображения. }
    property ImageLeft: Integer read FLeft write SetImageLeft default 0;
    { Верхняя (вертикальная) позиция изображения. }
    property ImageTop: Integer read FTop write SetImageTop default 0;
    { Хранит изображение, которое отображается компонентом. }
    property Picture: TBitmap read FPicture write SetPicture;
    { Определяет кнопку мыши, которой будет перемещаться изображение. }    
    property ScrollButton: TMouseButton read FScrollButton write FScrollButton default mbLeft;

    property StretchMode: TStretchMode read FStretchMode write SetStretchMode default COLORONCOLOR;    
    { Определяет, будет ли закрашиваться часть компонента, не занятая рисунком
      или вместо неё будет копироваться часть фона. }
    property Transparent: Boolean read FTransparent write SetTransparent default False;
    { Процент увеличения/уменьшения изображения по сравнению с реальным размером. }
    property Zoom: Extended read FZoom write SetZoom;

    { Свойство определяет процедуру, которая вызывается при изменении
      позиции изображения. }
    property OnChangePos: TNotifyEvent read FOnChangePos write FOnChangePos;
    { Свойство определяет процедуру, которая вызывается при любом изменении
      изображения, в том числе при (пере)загрузке (вставке) другого. }
    property OnChangeImage: TNotifyEvent read FOnChangeImage write FOnChangeImage;
    { Свойство определяет процедуру, которая вызывается при изменении
      размера компонента. }
    property OnChangeSize: TNotifyEvent read FOnChangeSize write FOnChangeSize;
    { Событие на появление мыши в пределах компонента. }
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    { Событие на выход мыши за пределы компонента. }
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;    
    { Вызывается вместо стандартной процедуры отрисовки изображения в компоненте,
      может быть использовано для нестандартной отрисовки. }
    property OnPaint: TPaintImageEvent read FOnPaint write SetOnPaint;
    { Событие, которое вызывается при необходимости смасштабировать изображение
      до нужных размеров. }
    property OnScaleImage: TScaleImageEvent read FOnScaleImage write FOnScaleImage;
    { Происходит при изменении масштаба изображения }
    property OnZoomChanged: TNotifyEvent read FOnZoomChanged write FOnZoomChanged;

                                   {@exclude}
    property Align;                {@exclude}
    property Anchors;              {@exclude}
    property Color;                {@exclude}
    property Constraints;          {@exclude}
    property DragCursor;           {@exclude}
    property DragKind;             {@exclude}
    property DragMode;             {@exclude}
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
    property OnKeyDown;            {@exclude}
    property OnKeyUp;              {@exclude}
    property OnMouseDown;          {@exclude}
    property OnMouseMove;          {@exclude}
    property OnMouseUp;            {@exclude}
    property OnResize;             {@exclude}
    property OnStartDock;          {@exclude}
    property OnStartDrag;
  end;

  { @abstract(Полноценный компонент для скроллинга графических изображений,
    в котором визуально реализовано все функции класса @link(TCustomScrollingImage).) }
  TScrollingImage = class(TCustomScrollingImage)
  private
    { Обработка сообщений Windows }
    procedure WMLButtonDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TMessage); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TMessage); message WM_LBUTTONDBLCLK;    
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE;
  protected                                {@exclude}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;            {@exclude}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
                                           {@exclude}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure ChangeImage; override;       {@exclude}
    procedure ImageSizeChanged; override;  {@exclude}
    procedure ResetImagePos; override;     {@exclude}
    procedure SizeChanged; override; 
                                           {@exclude}
    procedure Paint; override;
  end;

  { @abstract(Компонент, реализующий наиболее быстрый скроллинг графических изображений.
    Имеет некоторые дополнительные свойства.)
    При изменении позиции изображения не вызывается
    его перерисовка, а метод ScrollBy компонента, что приводит к скроллингу
    дочернего компонента-контейнера изображения,
    имеющего тип @link(TBitmapContainer). }
  TFastScrollingImage = class(TScrollingImage)
  private
    FBitmapContainer: TBitmapContainer;
    FSelfLeft, FSelfTop: Integer;
    FOnClick: TNotifyEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
  protected                              {@exclude}
    procedure CheckBounds; override;     {@exclude}
    procedure FitImageChanged; override; {@exclude}
    procedure ResetImagePos; override;   {@exclude}
    procedure SizeChanged; override;     {@exclude}
    procedure ZoomChanged; override;     {@exclude}
    procedure SetOnPaint(const Value: TPaintImageEvent); override;
                                         {@exclude}
    procedure SetTransparent(const Value: Boolean); override;        

                                                                   {@exclude}
    procedure BitmapMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);    {@exclude}
    procedure BitmapMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);                                              {@exclude}
    procedure BitmapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
                                                                      {@exclude}
    procedure Click; override;                                        {@exclude}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;                                       {@exclude}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override; {@exclude}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;                                       {@exclude}
    procedure Paint; override;
  public                                 {@exclude}
    constructor Create(AOwner: TComponent); override;
                                         {@exclude}
    procedure Invalidate; override;
  published
    property OnClick: TNotifyEvent read FOnClick write FOnClick;      {@exclude}
    property OnDblClick;                                              {@exclude}
                                                                      {@exclude}
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
                                                                      {@exclude}
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
                                                                      {@exclude}
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

  { @abstract(Наследник @link(TFastScrollingImage).
    От своего родителя отличается тем, что может иметь полосы прокрутки.) }
  TSBScrollingImage = class(TFastScrollingImage)
  private
    FScrollBarsVisible: Boolean;
    FScrollBarIncrement: Integer;
    procedure SetScrollBarsVisible(const Value: Boolean);

    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL; 
  protected                                                       {@exclude}
    procedure CheckBounds; override;                              {@exclude}
    procedure SizeChanged; override;
                                                                  {@exclude}
    procedure UpdateScrollBars;                                   {@exclude}
    procedure UpdateScrollRange;
  public                                                          {@exclude}
    constructor Create(AOwner: TComponent); override; 
  published
    { Определяет количество единиц, на которые будет прокручиваться
      изображение при нажатии на стрелки полосы прокрутки. }
    property ScrollBarIncrement: Integer read FScrollBarIncrement write FScrollBarIncrement default 25;
    { Определяет, нужно ли при необходимости отображать полосы прокрутки. }    
    property ScrollBarsVisible: Boolean read FScrollBarsVisible write SetScrollBarsVisible default True;
  end;

implementation

uses ImgCtrlUtils, Math;

{ Определяет, нужно ли использовать курсоры для скроллинга мышью,
  как в Программе просмотра изображений Windows XP.
  Если это определение закомментировать, будет использоваться
  набор курсоров по умолчанию (взяты из Adobe Acrobat Reader). }
(* {$DEFINE XP_CURSORS}

{$IFDEF XP_CURSORS}
  {$R 'CursorsXP.RES'}
{$ELSE}
  {$R 'CursorsDef.RES'}
{$ENDIF}
 *)
type
{ Переопределение стандартного класса TBitmap для того, чтобы иметь возможность
  получить уведомление о загрузке другого изображения, так как стандартное событие
  OnChange вызывается при любом измененении изображении, в том числе при рисовании
  на нем.

  В этом есть необходимость, потому что при загрузке (вставке) другого изображения
  нужно переместить изображение в начальную позицию. }
  TCustomBitmap = class(TBitmap)
  private
    FOnNewImage: TNotifyEvent;
    FUpdateCount: Integer;
  protected
    procedure Changed(Sender: TObject); override;
    procedure NewImage;
  public
    constructor Create; override;
    procedure LoadFromFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    property OnNewImage: TNotifyEvent read FOnNewImage write FOnNewImage;

    procedure BeginUpdate;
    procedure EndUpdate;    
  end;

procedure TCustomBitmap.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomBitmap.Changed(Sender: TObject);
begin
  if FUpdateCount = 0 then
    inherited Changed(Sender);
end;

constructor TCustomBitmap.Create;
begin
  inherited Create;

  FUpdateCount := 0;
end;

procedure TCustomBitmap.EndUpdate;
begin
  Dec(FUpdateCount);

  if FUpdateCount = 0 then
    Changed(Self);
end;

procedure TCustomBitmap.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
var
  OldOnChange: TNotifyEvent;  
begin
  OldOnChange := OnChange;
  try
    OnChange := nil;
    inherited LoadFromClipboardFormat(AFormat, AData, APalette);
  finally
    OnChange := OldOnChange;
  end;    

  NewImage;
end;

procedure TCustomBitmap.LoadFromFile(const Filename: string);
var
  OldOnChange: TNotifyEvent;
begin
  OldOnChange := OnChange;
  try
    OnChange := nil;
    inherited LoadFromFile(FileName);
  finally
    OnChange := OldOnChange;
  end;

  NewImage;
end;

procedure TCustomBitmap.LoadFromStream(Stream: TStream);
var
  OldOnChange: TNotifyEvent;
begin
  OldOnChange := OnChange;
  try
    OnChange := nil;
    inherited LoadFromStream(Stream);
  finally
    OnChange := OldOnChange;
  end;  

  NewImage;
end;

procedure TCustomBitmap.NewImage;
begin
  if FUpdateCount = 0 then
    if Assigned(FOnNewImage) then FOnNewImage(Self);
end;

// *****************************************************************************
//   TCustomScrollingImage
// *****************************************************************************

procedure TCustomScrollingImage.BeginUpdate;
begin
  TCustomBitmap(FPicture).BeginUpdate;
end;

procedure TCustomScrollingImage.CenterImage;
begin
  if FScrollEnabled then
  begin
    if FHCanScroll then
      FLeft := (FPictureWidth - ClientWidth) div 2;
    if FVCanScroll then
      FTop := (FPictureHeight - ClientHeight) div 2;
  end;
  CheckBounds;
  Invalidate;
end;

procedure TCustomScrollingImage.ChangeImage;
begin
  if Assigned(FOnChangeImage) then FOnChangeImage(Self);
end;

procedure TCustomScrollingImage.CheckBounds;
var
  H, V: Integer;
begin     
  if FHCanScroll or FVCanScroll then
  begin
    if FHCanScroll then
    begin
      H := FPictureWidth - ClientWidth;
      if FLeft > H then FLeft := H else
        if FLeft < 0 then FLeft := 0;
    end else FLeft := 0;
    if FVCanScroll then
    begin
      V := FPictureHeight - ClientHeight;
      if FTop < 0 then FTop := 0 else
        if FTop > V then FTop := V;
    end else FTop := 0;
  end else begin
    FLeft := 0;
    FTop := 0;
  end;
  // Высчитываем координаты, соответствующие координатам на оригинальном
  //   изображении в данном масштабе
  FOriginalLeft := Trunc(FLeft * FInvZoom);
  FOriginalTop := Trunc(FTop * FInvZoom);

  if Assigned(FOnChangePos) then FOnChangePos(Self);  
end;

procedure TCustomScrollingImage.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TCustomScrollingImage.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if FScrollButton in [mbMiddle, mbRight] then
    MouseUp(FScrollButton, [], 0, 0);

  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

constructor TCustomScrollingImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csOpaque];

  Height := 105;
  Width := 105;

  FPicture := TCustomBitmap.Create;
  with TCustomBitmap(FPicture) do
  begin
    OnNewImage := PictureNew;
    OnChange := PictureChanged;
  end;

  FLeft := 0;
  FTop := 0;

  FCanScroll := True;
  FCanScrollWithMouse := True;

  FZoom := 100;
  FZoomPercent := 1;
  FInvZoom := 1;

  FCanScrollCursor := crImageHand;
  FDragCursor := crImageDrag;
  FScrollDisabledCursor := crDefault;

  FStretchMode := COLORONCOLOR;
end;

procedure TCustomScrollingImage.CreateWnd;
begin
  inherited CreateWnd;

  ResetImagePos;
  SizeChanged;
end;

destructor TCustomScrollingImage.Destroy;
begin
  FPicture.Free;

  inherited Destroy;
end;

procedure TCustomScrollingImage.DoFitImage;
var
  NewZoom: Extended;
begin
  NewZoom := GetFitImageScale;

  case Ord(FAutoShrinkImage) shl 2 + Ord(FAutoZoomImage) shl 3 of
     4: Zoom := Min(100, NewZoom * 100); 
     8: Zoom := Max(100, NewZoom * 100);
    12: Zoom := NewZoom * 100;
  end;
end;

function TCustomScrollingImage.Empty: Boolean;
begin
  Result := Assigned(FPicture) and IsEmptyPicture(FPicture);
end;

procedure TCustomScrollingImage.EndUpdate;
begin
  TCustomBitmap(FPicture).EndUpdate;
end;

procedure TCustomScrollingImage.FitImageChanged;
begin
// процедуру не удалять и не делать абстрактной!
end;

function TCustomScrollingImage.GetFitImageScale: Extended;
begin
  if not Empty then
    Result := Min(ClientWidth / FPicture.Width, ClientHeight / FPicture.Height)
  else
    Result := 1;
end;

function TCustomScrollingImage.GetImagePos: TPoint;
begin
  Result.X := FLeft;
  Result.Y := FTop;
end;

function TCustomScrollingImage.GetRealImagePos: TPoint;
begin
  Result.X := GetRealLeft;
  Result.Y := GetRealTop;
end;

function TCustomScrollingImage.GetRealLeft: Integer;
begin
  if FHCanScroll then
    Result := FLeft
  else
    Result := -FPicCenterLeft;
end;

function TCustomScrollingImage.GetRealTop: Integer;
begin
  if FVCanScroll then
    Result := FTop
  else
    Result := -FPicCenterTop;
end;

procedure TCustomScrollingImage.ImageSizeChanged;
begin
  FPictureWidth := Trunc(FPicture.Width * FZoomPercent);
  FPictureHeight := Trunc(FPicture.Height * FZoomPercent);
end;

procedure TCustomScrollingImage.LoadGraphic(AGraphic: TGraphic);
var
  OldOnChange: TNotifyEvent;
begin
  if AGraphic = nil then Exit;

  OldOnChange := FPicture.OnChange;
  try
    FPicture.OnChange := nil;
    FPicture.Width := AGraphic.Width;
    FPicture.Height := AGraphic.Height;
    FPicture.Canvas.Draw(0, 0, AGraphic);
    TCustomBitmap(FPicture).NewImage;
  finally
    FPicture.OnChange := OldOnChange;
  end;  
end;

procedure TCustomScrollingImage.PictureChanged(Sender: TObject);
begin
  if (FPicture.Width <> FPictureWidth) or
     (FPicture.Height <> FPictureHeight) then
    ResetImagePos;
  ChangeImage;
  SizeChanged;

  CheckBounds;
  Invalidate;
end;

procedure TCustomScrollingImage.PictureNew(Sender: TObject);
begin
  ResetImagePos;

  ChangeImage;

  if FAutoZoomImage or FAutoShrinkImage then
    DoFitImage
  else begin
    SizeChanged;

    if FAutoCenter then
      CenterImage
    else
      CheckBounds;

    Invalidate;      
  end;
end;

procedure TCustomScrollingImage.ResetImagePos;
begin
  FLeft := 0;
  FTop := 0;
  ImageSizeChanged;
end;

procedure TCustomScrollingImage.Resize;
begin
  inherited Resize;

  if FAutoZoomImage or FAutoShrinkImage then
    DoFitImage
  else;
    SizeChanged;

  CheckBounds;
end;

procedure TCustomScrollingImage.ScrollEnd;
begin
  if FScrollEnabled then
    ImagePos := Point(FPictureWidth - ClientWidth, FPictureHeight - ClientHeight);
end;

procedure TCustomScrollingImage.ScrollHome;
begin
  if FScrollEnabled then
    ImagePos := Point(0, 0);
end;

procedure TCustomScrollingImage.ScrollImage(const DX, DY: Integer);
begin
  if FHCanScroll then
    Dec(FLeft, DX);
  if FVCanScroll then
    Dec(FTop, DY);

  CheckBounds;
  Invalidate;
end;

procedure TCustomScrollingImage.ScrollPageDown;
begin
  ScrollImage(0, -ClientHeight);
end;

procedure TCustomScrollingImage.ScrollPageLeft;
begin
  ScrollImage(ClientWidth, 0);
end;

procedure TCustomScrollingImage.ScrollPageRight;
begin
  ScrollImage(-ClientWidth, 0);
end;

procedure TCustomScrollingImage.ScrollPageUp;
begin
  ScrollImage(0, ClientHeight);
end;

procedure TCustomScrollingImage.SetAutoCenter(const Value: Boolean);
begin
  if FAutoCenter <> Value then
  begin
    FAutoCenter := Value;
    if FAutoCenter then CenterImage;
  end;
end;

procedure TCustomScrollingImage.SetAutoShrinkImage(const Value: Boolean);
begin
  if FAutoShrinkImage <> Value then
  begin
    FAutoShrinkImage := Value;
    FitImageChanged;
    if Value then DoFitImage;    
  end;
end;

procedure TCustomScrollingImage.SetAutoZoomImage(const Value: Boolean);
begin
  if FAutoZoomImage  <> Value then
  begin
    FAutoZoomImage := Value;
    FitImageChanged;
    if Value then DoFitImage;
  end;
end;

procedure TCustomScrollingImage.SetCanScroll(const Value: Boolean);
begin
  if FCanScroll <> Value then
  begin
    FCanScroll := Value;
    SizeChanged;
  end;
end;

procedure TCustomScrollingImage.SetCanScrollWithMouse(
  const Value: Boolean);
begin
  if FCanScrollWithMouse <> Value then
  begin
    FCanScrollWithMouse := Value;
    SizeChanged;
  end;
end;

procedure TCustomScrollingImage.SetImageLeft(const Value: Integer);
begin
  if FLeft <> Value then
  begin
    FLeft := Value;

    CheckBounds;
    Invalidate;
  end;
end;

procedure TCustomScrollingImage.SetImagePos(const Value: TPoint);
begin
  if (FLeft <> Value.X) or (FTop <> Value.Y) then
  begin
    FLeft := Value.X;
    FTop := Value.Y;

    CheckBounds;
    Invalidate;
  end;
end;

procedure TCustomScrollingImage.SetImageTop(const Value: Integer);
begin
  if FTop <> Value then
  begin
    FTop := Value;

    CheckBounds;
    Invalidate;
  end;
end;

procedure TCustomScrollingImage.SetOnPaint(const Value: TPaintImageEvent);
begin
  FOnPaint := Value;
end;

procedure TCustomScrollingImage.SetPicture(const Value: TBitmap);
begin
  FPicture.Assign(Value);
  ResetImagePos;
  ChangeImage;
  SizeChanged;
  if FAutoCenter then
    CenterImage
  else
    CheckBounds;
  Invalidate;
end;

procedure TCustomScrollingImage.SetStretchMode(const Value: TStretchMode);
begin
  if FStretchMode <> Value then
  begin
    FStretchMode := Value;
    Invalidate;
  end;
end;

procedure TCustomScrollingImage.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TCustomScrollingImage.SetZoom(const Value: Extended);
var
  CX, CY, NewLeft, NewTop, ZoomFactor: Extended;
begin
  if Value < 1 then Exit;

  if FZoom <> Value then
  begin
    ZoomFactor := Value / FZoom;
    CX := (ClientWidth - FPicCenterLeft * 2) / 2;
    CY := (ClientHeight - FPicCenterTop * 2) / 2;
    NewLeft := (FLeft + CX) * ZoomFactor;
    NewTop := (FTop + CY) * ZoomFactor;
    FLeft := Trunc(NewLeft - CX);
    FTop := Trunc(NewTop - CY);

    FZoom := Value;
    FZoomPercent := FZoom / 100;
    FInvZoom := 100 / FZoom;

    ZoomChanged;
  end;
end;

procedure TCustomScrollingImage.SizeChanged;
begin                                             // Проверяем, можно ли скроллить...
  FHCanScroll := (ClientWidth < FPictureWidth);   // ...по горизонтали
  FVCanScroll := (ClientHeight < FPictureHeight); // ...по вертикали
  if FCanScroll then
    FScrollEnabled := FHCanScroll or FVCanScroll  // И проверяем, можно ли скроллить вообще
  else
    FScrollEnabled := False;

  if FScrollEnabled and FCanScrollWithMouse then
    Cursor := FCanScrollCursor
  else
    Cursor := FScrollDisabledCursor;
  if FHCanScroll = False then
  begin
    FPicCenterLeft := (ClientWidth - FPictureWidth) div 2;
    FLeft := 0;
  end else FPicCenterLeft := 0;
  if FVCanScroll = False then
  begin
    FPicCenterTop := (ClientHeight - FPictureHeight) div 2;
    FTop := 0;
  end else FPicCenterTop := 0;

  if FPicCenterLeft > 0 then
    FPicCenterRight := FPicCenterLeft + FPictureWidth
  else
    FPicCenterRight := ClientWidth;
  if FPicCenterTop > 0 then
    FPicCenterBottom := FPicCenterTop + FPictureHeight
  else
    FPicCenterBottom := ClientHeight;

  FSrcWidth := Trunc((ClientWidth - FPicCenterLeft * 2) * FInvZoom);
  FSrcHeight := Trunc((ClientHeight - FPicCenterTop * 2) * FInvZoom);

  if Assigned(FOnChangeSize) then FOnChangeSize(Self);
end;

procedure TCustomScrollingImage.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TCustomScrollingImage.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      if not (csDesigning in ComponentState) and not Focused then
      begin
        FClicksDisabled := True;
        Windows.SetFocus(Handle);
        FClicksDisabled := False;
        if not Focused then Exit;
      end;
    CN_COMMAND:
      if FClicksDisabled then Exit;
  end;
  inherited WndProc(Message);
end;

procedure TCustomScrollingImage.ZoomChanged;
begin
  ImageSizeChanged;

  ChangeImage;
  SizeChanged;

  CheckBounds;
  Invalidate;

  if Assigned(FOnZoomChanged) then FOnZoomChanged(Self);
end;

// *****************************************************************************
//   TScrollingImage
// *****************************************************************************

procedure TScrollingImage.ChangeImage;
begin
  inherited ChangeImage;

  Invalidate;
end;

procedure TScrollingImage.ImageSizeChanged;
begin
  inherited ImageSizeChanged;

  Invalidate;  
end;

procedure TScrollingImage.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = FScrollButton then
    if FScrollEnabled and FCanScrollWithMouse then
    begin
      FX := Mouse.CursorPos.X;
      FY := Mouse.CursorPos.Y;

      FDragging := True;
      Screen.Cursor := FDragCursor;
    end;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TScrollingImage.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  L, H, OldLeft, OldTop: Integer;
begin
  if FScrollEnabled and FCanScrollWithMouse then
  begin
    if FDragging then
    begin
      OldLeft := FLeft;
      OldTop := FTop;

      if FHCanScroll then
      begin
        L := Mouse.CursorPos.X;
        FLeft := FX + FLeft - L;
        FX := L;
      end;
      if FVCanScroll then
      begin
        H := Mouse.CursorPos.Y;
        FTop := FY + FTop - H;
        FY := H;
      end;

      CheckBounds;

      if (OldLeft <> FLeft) or (OldTop <> FTop) then
        Invalidate;
    end;
  end;

  inherited MouseMove(Shift, X, Y);  
end;

procedure TScrollingImage.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging then
    FDragging := Button <> FScrollButton;
  if FScrollEnabled and FCanScrollWithMouse then Screen.Cursor := crDefault;

  inherited MouseUp(Button, Shift, X, Y);  
end;

procedure TScrollingImage.Paint;
var
  TempParentImage: TBitmap;
begin
  if (csDesigning in ComponentState) and Empty then
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
    if (FHCanScroll = False) or (FVCanScroll = False) then
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

            if FHCanScroll or FVCanScroll then
            begin
              if FHCanScroll then
              begin
                BitBlt(Canvas.Handle, 0, 0, ClientWidth, FPicCenterTop, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
                BitBlt(Canvas.Handle, 0, FPicCenterBottom, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, 0, FPicCenterTop + FPictureHeight, SRCCOPY);
              end;
              if FVCanScroll then
              begin
                BitBlt(Canvas.Handle, 0, 0, FPicCenterLeft, ClientHeight, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
                BitBlt(Canvas.Handle, FPicCenterRight, 0, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, FPicCenterLeft + FPictureWidth, 0, SRCCOPY);
              end;
            end else begin
              BitBlt(Canvas.Handle, 0, 0, ClientWidth, FPicCenterTop, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
              BitBlt(Canvas.Handle, 0, FPicCenterBottom, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, 0, FPicCenterTop + FPictureHeight, SRCCOPY);
              BitBlt(Canvas.Handle, 0, 0, FPicCenterLeft, ClientHeight, TempParentImage.Canvas.Handle, 0, 0, SRCCOPY);
              BitBlt(Canvas.Handle, FPicCenterRight, 0, ClientWidth, ClientHeight, TempParentImage.Canvas.Handle, FPicCenterLeft + FPictureWidth, 0, SRCCOPY);
            end;
          finally
            TempParentImage.Free;
          end;
        end else begin
          Brush.Color := Color;
          Brush.Style := bsSolid;
          if FHCanScroll or FVCanScroll then
          begin
            if FHCanScroll then
            begin
              FillRect(Rect(0, 0, ClientWidth, FPicCenterTop));
              FillRect(Rect(0, FPicCenterBottom, ClientWidth, ClientHeight));
            end;
            if FVCanScroll then
            begin
              FillRect(Rect(0, 0, FPicCenterLeft, ClientHeight));
              FillRect(Rect(FPicCenterRight, 0, ClientWidth, ClientHeight));
            end;
          end else begin
            FillRect(Rect(0, 0, ClientWidth, FPicCenterTop));
            FillRect(Rect(0, FPicCenterBottom, ClientWidth, ClientHeight));
            FillRect(Rect(0, 0, FPicCenterLeft, ClientHeight));
            FillRect(Rect(FPicCenterRight, 0, ClientWidth, ClientHeight));
          end;
        end;
      end;
    end;

    if Zoom = 100 then
    begin
      if Assigned(FOnPaint) then
        FOnPaint(Canvas, FPicCenterLeft, FPicCenterTop, ClientWidth, ClientHeight, FLeft, FTop, FPicture)
      else
        BitBlt(Canvas.Handle, FPicCenterLeft, FPicCenterTop, ClientWidth, ClientHeight, FPicture.Canvas.Handle, FLeft, FTop, SRCCOPY);
    end else begin
      if Assigned(FOnScaleImage) then
        FOnScaleImage(Canvas, FPicCenterLeft, FPicCenterTop, FPicCenterRight - FPicCenterLeft, FPicCenterBottom - FPicCenterTop,
          FOriginalLeft, FOriginalTop, FSrcWidth, FSrcHeight, FPicture)
      else begin
        SetStretchBltMode(Canvas.Handle, {STRETCH_DELETESCANS}FStretchMode);
        StretchBlt(Canvas.Handle, FPicCenterLeft, FPicCenterTop, FPicCenterRight - FPicCenterLeft, FPicCenterBottom - FPicCenterTop, FPicture.Canvas.Handle,
          FOriginalLeft, FOriginalTop, FSrcWidth, FSrcHeight, SRCCOPY);
      end;
    end;
  end;
end;

procedure TScrollingImage.ResetImagePos;
begin
  inherited ResetImagePos;

  Invalidate;
end;

procedure TScrollingImage.SizeChanged;
begin
  inherited SizeChanged;

  Invalidate; 
end;

procedure TScrollingImage.WMLButtonDblClk(var Message: TMessage);
begin
{
  if FScrollEnabled and FCanScrollWithMouse then
  begin
    FDragging := True;
    Screen.Cursor := FDragCursor;
  end;
}
  inherited;
end;

procedure TScrollingImage.WMLButtonDown(var Message: TMessage);
begin
{
  if FScrollEnabled and FCanScrollWithMouse then
  begin
    FX := Mouse.CursorPos.X;
    FY := Mouse.CursorPos.Y;

    FDragging := True;
    Screen.Cursor := FDragCursor;
  end;
}
  inherited;
end;

procedure TScrollingImage.WMLButtonUp(var Message: TMessage);
begin
{
  FDragging := False;
  if FScrollEnabled and FCanScrollWithMouse then Screen.Cursor := crDefault;
}
  inherited;
end;

procedure TScrollingImage.WMMouseMove(var Message: TMessage);
{var
  L, H, OldLeft, OldTop: Integer;}
begin
{
  if FScrollEnabled and FCanScrollWithMouse then
  begin
    if FDragging then
    begin
      OldLeft := FLeft;
      OldTop := FTop;

      if FHCanScroll then
      begin
        L := Mouse.CursorPos.X;
        FLeft := FX + FLeft - L;
        FX := L;
      end;
      if FVCanScroll then
      begin
        H := Mouse.CursorPos.Y;
        FTop := FY + FTop - H;
        FY := H;
      end;

      CheckBounds;

      if (OldLeft <> FLeft) or (OldTop <> FTop) then
        Invalidate;
    end;
  end;
}
  inherited;
end;

// *****************************************************************************
//   TFastScrollingImage
// *****************************************************************************

procedure TFastScrollingImage.BitmapMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = FScrollButton then
    if FScrollEnabled and FCanScrollWithMouse then
    begin
      FX := Mouse.CursorPos.X;
      FY := Mouse.CursorPos.Y;

      FDragging := True;
      Screen.Cursor := FDragCursor;
      //SetCapture(Handle);
    end;

  if Assigned(FOnMouseDown) then FOnMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TFastScrollingImage.BitmapMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  L, H: Integer;
begin
  if FScrollEnabled and FCanScrollWithMouse then
  begin
    if FDragging then
    begin
      if FHCanScroll then
      begin
        L := Mouse.CursorPos.X;
        FLeft := FX + FLeft - L;
        FX := L;
      end;
      if FVCanScroll then
      begin
        H := Mouse.CursorPos.Y;
        FTop := FY + FTop - H;
        FY := H;
      end;

      CheckBounds;
    end;
  end;

  if Assigned(FOnMouseMove) then FOnMouseMove(Sender, Shift, X, Y);
end;

procedure TFastScrollingImage.BitmapMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
  begin
    FDragging := Button <> FScrollButton;
    //if not FDragging then ReleaseCapture;
  end;
  if FScrollEnabled and FCanScrollWithMouse then Screen.Cursor := crDefault;

  if Assigned(FOnMouseUp) then FOnMouseUp(Sender, Button, Shift, X, Y);
  with TControl(Sender) do
    if (X >= 0) and (Y >= 0) and
       (X <= ClientWidth) and (Y <= ClientHeight) and
      Assigned(FOnClick) then FOnClick(Self);
end;

procedure TFastScrollingImage.CheckBounds;
begin
  inherited CheckBounds;

  if FBitmapContainer.Visible then
    ScrollBy(FSelfLeft - FLeft, FSelfTop - FTop)
  else
    FBitmapContainer.SetBounds(FBitmapContainer.Left + FSelfLeft - FLeft, FBitmapContainer.Top + FSelfTop - FTop, FBitmapContainer.Width, FBitmapContainer.Height);
  FSelfLeft := FLeft;
  FSelfTop := FTop;
end;

procedure TFastScrollingImage.Click;
begin
  inherited Click;

  if Assigned(FOnClick) then FOnClick(Self);
end;

constructor TFastScrollingImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSelfLeft := 0;
  FSelfTop := 0;

  FScrollButton := mbLeft;

  FBitmapContainer := TBitmapContainer.Create(Self);
  with FBitmapContainer do
  begin
    Parent := Self;

    OnMouseDown := BitmapMouseDown;
    OnMouseMove := BitmapMouseMove;
    OnMouseUp := BitmapMouseUp;
    OnPaint := FOnPaint;
  end;
end;

procedure TFastScrollingImage.FitImageChanged;
begin
  ShowScrollBar(Handle, SB_BOTH, False);
end;

procedure TFastScrollingImage.Invalidate;
begin
  if not FBitmapContainer.Visible then
    inherited Invalidate;
end;

procedure TFastScrollingImage.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TFastScrollingImage.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);

  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

procedure TFastScrollingImage.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);

  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TFastScrollingImage.Paint;
begin
  if not FBitmapContainer.Visible then
    inherited Paint;
end;

procedure TFastScrollingImage.ResetImagePos;
begin
  inherited ResetImagePos;

  FSelfLeft := 0;
  FSelfTop := 0;
  FBitmapContainer.SetBounds(0, 0, Max(FPictureWidth, ClientWidth), Max(FPictureHeight, ClientHeight));
end;

procedure TFastScrollingImage.SetOnPaint(const Value: TPaintImageEvent);
begin
  inherited SetOnPaint(Value);

  FBitmapContainer.OnPaint := Value;
end;

procedure TFastScrollingImage.SetTransparent(const Value: Boolean);
begin
  inherited SetTransparent(Value);

  FBitmapContainer.Visible := (FZoom = 100) and not Value;
end;

procedure TFastScrollingImage.SizeChanged;
var
  L, T, W, H: Integer;
begin
  inherited SizeChanged;

  if (FHCanScroll = False) and (FVCanScroll = False) then
  begin
    FSelfLeft := 0;
    FSelfTop := 0;
    FBitmapContainer.SetBounds(0, 0, ClientWidth, ClientHeight);
  end else begin
    if FHCanScroll = False then
    begin
      FSelfLeft := 0;
      L := 0;
      W := ClientWidth;
    end else begin
      L := FBitmapContainer.Left;
      W := FPictureWidth;
    end;
    if FVCanScroll = False then
    begin
      FSelfTop := 0;
      T := 0;
      H := ClientHeight;
    end else begin
      T := FBitmapContainer.Top;
      H := FPictureHeight;
    end;
    FBitmapContainer.SetBounds(L, T, W, H);
  end;
end;

procedure TFastScrollingImage.ZoomChanged;
begin
  FBitmapContainer.Visible := not FTransparent and (FZoom = 100);

  inherited ZoomChanged;
end;

// *****************************************************************************
//   TSBScrollingImage
// *****************************************************************************

procedure TSBScrollingImage.CheckBounds;
begin
  inherited CheckBounds;

  if FScrollBarsVisible then
  begin
    if FHCanScroll then SetScrollPos(Handle, SB_HORZ, FLeft, True);
    if FVCanScroll then SetScrollPos(Handle, SB_VERT, FTop, True);
  end;
end;

constructor TSBScrollingImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FScrollBarIncrement := 25;
  FScrollBarsVisible := True;
end;

procedure TSBScrollingImage.SetScrollBarsVisible(const Value: Boolean);
begin
  if FScrollBarsVisible <> Value then
  begin
    FScrollBarsVisible := Value;

    if FScrollBarsVisible then
    begin
      UpdateScrollRange;
      SizeChanged;
      CheckBounds;
    end else UpdateScrollBars;
  end;
end;

procedure TSBScrollingImage.SizeChanged;
var
  ScrollInfo: TScrollInfo;
begin
  inherited SizeChanged;

  UpdateScrollBars;

  if FScrollBarsVisible and FCanScroll then
  begin
    // Устанавливаем размер бегунка для каждого скроллбара
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_PAGE;

    if FHCanScroll then
    begin
      ScrollInfo.nPage := ClientWidth;
      SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
    end;

    if FVCanScroll then
    begin
      ScrollInfo.nPage := ClientHeight;
      SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    end;
  end;

  UpdateScrollRange;
end;

procedure TSBScrollingImage.UpdateScrollBars;
var
  OldAutoShrinkImage: Boolean;
  OldAutoZoomImage: Boolean;
begin
  if FCanScroll then
    EnableScrollBar(Handle, SB_BOTH, ESB_ENABLE_BOTH)
  else
    EnableScrollBar(Handle, SB_BOTH, ESB_DISABLE_BOTH);

  OldAutoShrinkImage := FAutoShrinkImage;
  OldAutoZoomImage := FAutoZoomImage;
  FAutoShrinkImage := False;
  FAutoZoomImage := False;
  try
    if FScrollBarsVisible then
    begin
      ShowScrollBar(Handle, SB_HORZ, FHCanScroll);
      ShowScrollBar(Handle, SB_VERT, FVCanScroll);
    end else
      ShowScrollBar(Handle, SB_BOTH, False);
  finally
    FAutoShrinkImage := OldAutoShrinkImage;
    FAutoZoomImage := OldAutoZoomImage;
  end;
end;

procedure TSBScrollingImage.UpdateScrollRange;
begin
  if FScrollBarsVisible and FCanScroll then
  begin
    // Устанавливаем размер области, прокручиваемой скроллбаром
    if FHCanScroll then SetScrollRange(Handle, SB_HORZ, 0, FPictureWidth, True);
    if FVCanScroll then SetScrollRange(Handle, SB_VERT, 0, FPictureHeight, True);
  end;
end;

procedure TSBScrollingImage.WMHScroll(var Message: TWMHScroll);
begin
  if (Message.ScrollBar = 0) and FHCanScroll then
  begin
    case Message.ScrollCode of
      SB_LINEUP: ScrollImage(FScrollBarIncrement, 0);
      SB_LINEDOWN: ScrollImage(-FScrollBarIncrement, 0);
      SB_PAGEUP: ScrollImage(ClientWidth, 0);
      SB_PAGEDOWN: ScrollImage(-ClientWidth, 0);
      SB_THUMBPOSITION: ImageLeft := Message.Pos;
      SB_THUMBTRACK: ImageLeft := Message.Pos;
      SB_TOP: ImageLeft := 0;
      SB_BOTTOM: ImageLeft := FPictureWidth - ClientWidth;
      //SB_ENDSCROLL: begin end; 
    end;
  end else
    inherited;
end;

procedure TSBScrollingImage.WMVScroll(var Message: TWMVScroll);
begin
  if (Message.ScrollBar = 0) and FVCanScroll then
  begin
    case Message.ScrollCode of
      SB_LINEUP: ScrollImage(0, FScrollBarIncrement);
      SB_LINEDOWN: ScrollImage(0, -FScrollBarIncrement);
      SB_PAGEUP: ScrollImage(0, ClientWidth);
      SB_PAGEDOWN: ScrollImage(0, -ClientWidth);
      SB_THUMBPOSITION: ImageTop := Message.Pos;
      SB_THUMBTRACK: ImageTop := Message.Pos;
      SB_TOP: ImageTop := 0;
      SB_BOTTOM: ImageTop := FPictureHeight - ClientHeight;
      //SB_ENDSCROLL: begin end;
    end;
  end else
    inherited;
end;

initialization
  // Загрузка курсоров по умолчанию
  Screen.Cursors[crImageHand] := LoadCursor(HInstance, 'HAND');
  Screen.Cursors[crImageDrag] := LoadCursor(HInstance, 'DRAG');

end.
