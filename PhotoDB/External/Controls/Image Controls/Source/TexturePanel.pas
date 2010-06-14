
{*******************************************************}
{                                                       }
{       Image Controls                                  }
{       Библиотека для работы с изображениями           }
{                                                       }
{       Текстурная панель                               }
{                                                       }
{       Copyright (c) 2004-2005, Михаил Мостовой        }
{                               (s-mike)                }
{       http://forum.sources.ru                         }
{       http://mikesoft.front.ru                        }
{                                                       }
{*******************************************************}

{
@abstract(Модуль компонента текстурной панели @link(TTexturePanel).)
@author(Михаил Мостовой <mikesoft@front.ru>)
@created(февраль 2005)
@lastmod(19 марта, 2005)
<p>Компонент предназначен для улучшения интерфейса программы, создания скинов.
Представляет собой панель, которая заполняется текстурой.<p>
}

unit TexturePanel;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, Messages;

type
  { @abstract(Компонент текстурная панель)
    Основным отличием данного компонента является два метода заполнения
    текстурой:
    <li>обычный, когда компонент последовательно заполняется текстурой;</li>
    <li>при заполнении другим методом текстура увеличивается за счет размножения
    ее центральной крайних частей.</li> }
  TTexturePanel = class(TCustomControl)
  private
    FPattern: Boolean;
    FBitmap: TBitmap;
    FCacheBitmap: Boolean;
    FBitmapCache: TBitmap;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure SetPattern(const Value: Boolean);
    procedure SetBitmap(const Value: TBitmap);
    procedure SetCacheBitmap(const Value: Boolean);
  protected                            {@exclude}
    procedure DoCacheBitmap; virtual;  {@exclude}
                                       {@exclude}
    procedure Paint; override;         {@exclude}
    procedure Resize; override;
  public                               {@exclude}
    constructor Create(AOwner: TComponent); override;
                                       {@exclude}
    destructor Destroy; override;

    { Предварительно подготовленное изображения для вывода в компонент
      при перерисовке, может использоваться для копирования "изображения"
      компонента }
    property BitmapCache: TBitmap read FBitmapCache;
  published
    { Определяет нужно ли хранить изображение для вывода в компонент при
      перерисовке. Получить доступ к хранимому изображению можно через
      свойство @link(BitmapCache). }
    property CacheBitmap: Boolean read FCacheBitmap write SetCacheBitmap default False;
    { Хранит текстуру. }
    property Picture: TBitmap read FBitmap write SetBitmap;
    { Определяет тип заполнения компонента текстурой. См. описание. }
    property Pattern: Boolean read FPattern write SetPattern default False;

                                                               {@exclude}
    property Align;                                            {@exclude}
    property Anchors;                                          {@exclude}
    property BorderWidth;                                      {@exclude}
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

implementation

uses ImgCtrlsSkins, ImgCtrlUtils;

{ TTexturePanel }

constructor TTexturePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBitmap := TBitmap.Create;

  ControlStyle := ControlStyle + [csAcceptsControls];  
end;

destructor TTexturePanel.Destroy;
begin
  FBitmap.Free;
  CacheBitmap := False;

  inherited Destroy;
end;

procedure TTexturePanel.DoCacheBitmap;
begin
  if not HandleAllocated then Exit;

  if not Assigned(FBitmapCache) then
    FBitmapCache := TBitmap.Create;

  FBitmapCache.Width := ClientWidth;
  FBitmapCache.Height := ClientHeight;

  if FPattern then
    FillRectWithBitmap(FBitmap, FBitmapCache.Canvas, ClientRect)
  else
    FillRectWithSkin(FBitmap, FBitmapCache.Canvas, ClientRect);
end;

procedure TTexturePanel.Paint;
begin
  if (csDesigning in ComponentState) and IsEmptyPicture(FBitmap) then
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
    if FCacheBitmap then
      Canvas.Draw(0, 0, FBitmapCache)
    else
      if FPattern then
        FillRectWithBitmap(FBitmap, Canvas, ClientRect)
      else
        FillRectWithSkin(FBitmap, Canvas, ClientRect);
  end;
end;

procedure TTexturePanel.Resize;
begin
  inherited Resize;

  DoCacheBitmap;
end;

procedure TTexturePanel.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
  if FCacheBitmap then DoCacheBitmap;  
  Invalidate;
end;

procedure TTexturePanel.SetCacheBitmap(const Value: Boolean);
begin
  if FCacheBitmap <> Value then
  begin
    FCacheBitmap := Value;
    if Value then
      DoCacheBitmap
    else
      FreeAndNil(FBitmapCache);
  end;
end;

procedure TTexturePanel.SetPattern(const Value: Boolean);
begin
  if FPattern <> Value then
  begin
    FPattern := Value;
    if FCacheBitmap then DoCacheBitmap;    
    Invalidate;
  end;
end;

procedure TTexturePanel.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

end.
 