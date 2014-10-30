//
//TScrollPanel v1.0 - combines TPanel and TScrollBox capabilities
//Written by Andrew Anoshkin '1998
//
unit Dmitry.Controls.ScrollPanel;

interface

{$DEFINE A_D3} { Delphi 3.0 or higher }

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  Themes,
  Math;

type
  TCustomScrollPanel = class(TScrollingWinControl)
  private
    //TCustomControl
    FCanvas: TCanvas;

    //TCustomPanel
    FBevelInner: TPanelBevel;
    FBevelOuter: TPanelBevel;
    FBevelWidth: TBevelWidth;
    FBorderWidth: TBorderWidth;
    FBorderStyle: TBorderStyle;
    FFullRepaint: Boolean;
    FLocked: Boolean;
    FOnResize: TNotifyEvent;
    FAlignment: TAlignment;
    FOnPaint: TNotifyEvent;
    FDefaultDraw: boolean;
    FBackGround: TBitmap;
    FBackGroundTransparent: integer;
    FOnReallign: TNotifyEvent;
    FBackgroundLeft: integer;
    FBackgroundTop: integer;
    FUpdating: boolean;

    procedure Erased(var Mes: TWMEraseBkgnd);message WM_ERASEBKGND;
    //TCustomControl
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;


    //TCustomPanel
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMIsToolControl(var Message: TMessage); message CM_ISTOOLCONTROL;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure SetAlignment(Value: TAlignment);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetOnPaint(const Value: TNotifyEvent);
    procedure SetDefaultDraw(const Value: boolean);
    procedure SetBackGround(const Value: TBitmap);
    procedure SetBackGroundTransparent(const Value: integer);
    procedure SetOnReallign(const Value: TNotifyEvent);
    procedure SetBackgroundLeft(const Value: integer);
    procedure SetBackgroundTop(const Value: integer);
    procedure SetUpdating(const Value: boolean);
  protected
    //TCustomControl
    procedure Paint; virtual;
    procedure PaintWindow(DC: HDC); override;
    property  Canvas: TCanvas read FCanvas;
    //TCustomPanel
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure ResizePanel; dynamic;
    //TCustomPanel
    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default bvNone;
    property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelWidth: TBevelWidth read FBevelWidth write SetBevelWidth default 1;
    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth default 0;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property Color default clBtnFace;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default True;
    property Locked: Boolean read FLocked write FLocked default False;
    property ParentColor default False;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    procedure GetBackGround(x,y,w,h : integer; var Bitmap : TBitmap);
    //TScrollingWinControl
    property AutoScroll;
    property OnPaint : TNotifyEvent read FOnPaint write SetOnPaint;
    property DefaultDraw : boolean read FDefaultDraw write SetDefaultDraw;
    property BackGround : TBitmap read FBackGround Write SetBackGround;
    property BackGroundTransparent : integer read FBackGroundTransparent Write SetBackGroundTransparent;
    property OnReallign : TNotifyEvent read FOnReallign write SetOnReallign;
    property BackgroundLeft : integer read FBackgroundLeft Write SetBackgroundLeft;
    property BackgroundTop : integer read FBackgroundTop Write SetBackgroundTop;
    property UpdatingPanel : boolean read FUpdating write SetUpdating;
  end;


  TScrollPanel = class(TCustomScrollPanel)
  published
    property Align;
    property Alignment;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BorderWidth;
    property BorderStyle;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Caption;
    property Canvas;
    property Color;
    property Ctl3D;
    property Font;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDrag;
  end;


procedure Register;

implementation


constructor TCustomScrollPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBackgroundLeft:=0;
  FBackgroundTop:=0;
  FUpdating:=false;
  FBackGround:=TBitmap.create;
  FBackGround.PixelFormat:=pf24bit;
  FDefaultDraw:=true;
  //TCustomControl
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;

  //TCustomPanel
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  Width := 185;
  Height := 41;
  FAlignment := taCenter;
  BevelOuter := bvRaised;
  BevelWidth := 1;
  FBorderStyle := bsNone;
  Color := clBtnFace;
  FFullRepaint := True;
end;


destructor TCustomScrollPanel.Destroy;
begin
  FBackGround.free;
  //TCustomControl
  FCanvas.Free;
  inherited Destroy;
end;


procedure TCustomScrollPanel.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of Longint = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or cardinal(BorderStyles[FBorderStyle]);
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;


//
//From TCustomControl
//
procedure TCustomScrollPanel.WMPaint(var Message: TWMPaint);
begin
  PaintHandler(Message);
end;


//
//From TCustomControl
//
procedure TCustomScrollPanel.PaintWindow(DC: HDC);
begin
{$IFDEF A_D3}
  FCanvas.Lock;
{$ENDIF}
  try
    FCanvas.Handle := DC;
    try
      Paint;
    finally
      FCanvas.Handle := 0;
    end;
  finally
{$IFDEF A_D3}
    FCanvas.Unlock;
{$ENDIF}
  end;
end;


procedure TCustomScrollPanel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;


procedure TCustomScrollPanel.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;


procedure TCustomScrollPanel.CMIsToolControl(var Message: TMessage);
begin
  if not FLocked then Message.Result := 1;
end;


procedure TCustomScrollPanel.ResizePanel;
begin
  if Assigned(FOnResize) then FOnResize(Self);
end;


procedure TCustomScrollPanel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  BevelPixels: Integer;
  Rect, NewRect: TRect;
begin
  if FullRepaint or (Caption <> '') then
    Invalidate
  else
  begin
    BevelPixels := BorderWidth;
    if BevelInner <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelOuter <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelPixels > 0 then
    begin
      Rect.Right := Width;
      Rect.Bottom := Height;
      NewRect.Right  := Message.WindowPos^.cx;
      NewRect.Bottom := Message.WindowPos^.cy;
      if Message.WindowPos^.cx <> Rect.Right then
      begin
        Rect.Top := 0;
        Rect.Left := Rect.Right - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
        NewRect.Top := 0;
        NewRect.Left  := NewRect.Right - BevelPixels - 1;
        InvalidateRect(Handle, @NewRect, True);
      end;
      if Message.WindowPos^.cy <> Rect.Bottom then
      begin
        Rect.Left := 0;
        Rect.Top := Rect.Bottom - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
        NewRect.Left := 0;
        NewRect.Top := NewRect.Bottom - BevelPixels - 1;
        InvalidateRect(Handle, @NewRect, True);
      end;
    end;
  end;
  inherited;
  if not (csLoading in ComponentState) then ResizePanel;
end;


procedure TCustomScrollPanel.AlignControls(AControl: TControl; var Rect: TRect);
var
  BevelSize: Integer;
begin
  if FUpdating then exit;
  BevelSize := BorderWidth;
  if BevelOuter <> bvNone then Inc(BevelSize, BevelWidth);
  if BevelInner <> bvNone then Inc(BevelSize, BevelWidth);
  InflateRect(Rect, -BevelSize, -BevelSize);
  inherited AlignControls(AControl, Rect);
  Invalidate;
  if Assigned(FOnReallign) then FOnReallign(self);
end;


procedure TCustomScrollPanel.Paint;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
 if Assigned(FOnPaint) then FOnPaint(self);

 if not DefaultDraw then exit;


  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;

  if StyleServices.Enabled then
    Color := StyleServices.GetStyleColor(Themes.scPanel);

  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with Rect do
    begin
      Top := ((Bottom + Top) - FontHeight) div 2;
      Bottom := Top + FontHeight;
    end;
    Draw(FBackgroundLeft, FBackgroundTop, BackGround);
//    Draw(Max(0,Width-BackGround.Width-5),Max(0,Height-BackGround.Height-2),BackGround);
    //DrawText(Handle, PChar(Caption), -1, Rect, (DT_EXPANDTABS or
      //DT_VCENTER) or Alignments[FAlignment]);
  end;
end;


procedure TCustomScrollPanel.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;


procedure TCustomScrollPanel.SetBevelInner(Value: TPanelBevel);
begin
  FBevelInner := Value;
  Realign;
  Invalidate;
end;


procedure TCustomScrollPanel.SetBevelOuter(Value: TPanelBevel);
begin
  FBevelOuter := Value;
  Realign;
  Invalidate;
end;


procedure TCustomScrollPanel.SetBevelWidth(Value: TBevelWidth);
begin
  FBevelWidth := Value;
  Realign;
  Invalidate;
end;


procedure TCustomScrollPanel.SetBorderWidth(Value: TBorderWidth);
begin
  FBorderWidth := Value;
  Realign;
  Invalidate;
end;


procedure TCustomScrollPanel.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TCustomScrollPanel.SetOnPaint(const Value: TNotifyEvent);
begin
  FOnPaint := Value;
end;

procedure TCustomScrollPanel.SetDefaultDraw(const Value: boolean);
begin
  FDefaultDraw := Value;
end;

procedure Register;
begin
  RegisterComponents('AA', [TScrollPanel]);
end;

procedure TCustomScrollPanel.SetBackGround(const Value: TBitmap);
begin
  FBackGround.Assign(Value);
  Refresh;
end;

procedure TCustomScrollPanel.SetBackGroundTransparent(
  const Value: integer);
begin
  FBackGroundTransparent := Value;
  Refresh;
end;

procedure TCustomScrollPanel.GetBackGround(X, Y, W, H: Integer; var Bitmap: TBitmap);
begin
  Bitmap.Width := W;
  Bitmap.Height := H;
  if StyleServices.Enabled then
    Color := StyleServices.GetStyleColor(Themes.scPanel);
  Bitmap.Canvas.Brush.Color := Color;
  Bitmap.Canvas.Pen.Color := Color;
  Bitmap.Canvas.Rectangle(0, 0, W, H);
  Bitmap.Canvas.Draw(-X + FBackgroundLeft, -Y + FBackgroundTop, FBackGround);
end;

procedure TCustomScrollPanel.SetOnReallign(const Value: TNotifyEvent);
begin
  FOnReallign := Value;
end;

procedure TCustomScrollPanel.SetBackgroundLeft(const Value: integer);
begin
  FBackgroundLeft := Value;
end;

procedure TCustomScrollPanel.SetBackgroundTop(const Value: integer);
begin
  FBackgroundTop := Value;
end;

procedure TCustomScrollPanel.SetUpdating(const Value: boolean);
begin
  FUpdating := Value;
end;



procedure TCustomScrollPanel.Erased(var Mes: TWMEraseBkgnd);
begin
  Mes.Result := 1;
end;

end.


