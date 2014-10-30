unit Dmitry.Controls.Angle;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Dmitry.Memory,
  Dmitry.Controls.Base;

type
  TAngle = class(TBaseWinControl)
  private
    { Private declarations }
    FCanvas: TCanvas;
    FBuffer: TBitmap;
    FAngle: Extended;
    FMouseDown: Boolean;
    FOnChange: TNotifyEvent;
    FLoading: Boolean;
    procedure SetAngle(const Value: Extended);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetLoading(const Value: Boolean);
    procedure UpdateAngle(var Mes: TWMMouse);
  protected
    { Protected declarations }
    procedure Paint(var Msg: TMessage); message WM_PAINT;
    procedure OnChangeSize(var Msg: Tmessage); message WM_SIZE;
    procedure OnMouseDownMSG(var Mes: TWMMouse); message WM_LBUTTONDOWN;
    procedure OnMouseMOVEMSG(var Mes: TWMMouse); message WM_MOUSEMOVE;
    procedure OnMouseUpMSG(var Mes: TWMMouse); message WM_LBUTTONUP;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure RecteateImage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Angle: Extended read FAngle write SetAngle;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property Loading: Boolean read FLoading write SetLoading default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TAngle]);
end;

{ TAngle }

constructor TAngle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLoading := True;
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;
  FAngle := 0;
  FOnChange := nil;
  FMouseDown := False;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FLoading := False;
  RecteateImage;
end;

destructor TAngle.Destroy;
begin
  F(FCanvas);
  F(FBuffer);
  inherited;
end;

procedure TAngle.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TAngle.OnChangeSize(var Msg: Tmessage);
begin
  if FLoading then
    Exit;
  if FBuffer = nil then
    Exit;
  FBuffer.Height := Height;
  FBuffer.Width := Width;
  RecteateImage;
end;

procedure TAngle.UpdateAngle(var Mes: TWMMouse);
var
  X, Y, W, H: Integer;
begin
  X := Mes.XPos;
  Y := Mes.YPos;
  H := Height div 2;
  W := Width div 2;
  if (Y - H) <> 0 then
  begin
    if (Y - H) > 0 then
      Angle := 180 - Round(180 * Arctan((X - W) / (Y - H)) / Pi)
    else
      Angle := -Round(180 * Arctan((X - W) / (Y - H)) / Pi);
  end else
  begin
    if (X - W) > 0 then
      Angle := 90
    else
      Angle := 270;
  end;
end;

procedure TAngle.OnMouseDownMSG(var Mes: TWMMouse);
begin
  FMouseDown := True;
  UpdateAngle(Mes);
end;

procedure TAngle.OnMouseMOVEMSG(var Mes: TWMMouse);
begin
 if not FMouseDown then
    Exit;
  UpdateAngle(Mes);
end;

procedure TAngle.OnMouseUpMSG(var Mes: TWMMouse);
begin
  FMouseDown := False;
end;

procedure TAngle.Paint(var Msg: TMessage);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  DC := BeginPaint(Handle, PS);
  BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  EndPaint(Handle, PS);
end;

procedure TAngle.RecteateImage;
var
  X, Y, H, W, X1, Y1: Integer;
  DAngle: Extended;
  C, CW: TColor;
begin
  if StyleServices.Enabled then
  begin
    CW := StyleServices.GetStyleFontColor(sfPanelTextNormal);
    C := StyleServices.GetStyleColor(scWindow);
  end else
  begin
    CW := clWindowText;
    C := clWindow;
  end;
  DrawBackground(FBuffer.Canvas);

  FBuffer.Canvas.Pen.Color := CW;
  FBuffer.Canvas.Brush.Color := C;
  FBuffer.Canvas.Ellipse(0, 0, Width, Height);
  FBuffer.Canvas.MoveTo(Width div 2, Height div 2);
  DAngle := Angle * Pi / 180;
  H := Height div 2;
  W := Width div 2;
  X := Round(W + W * Sin(DAngle));
  Y := Round(H - H * Cos(DAngle));
  FBuffer.Canvas.LineTo(X, Y);
  FBuffer.Canvas.MoveTo(X, Y);
  X1 := Round(W + 0.8 * W * Sin(DAngle + Pi / 20));
  Y1 := Round(H - 0.8 * H * Cos(DAngle + Pi / 20));
  FBuffer.Canvas.LineTo(X1, Y1);
  FBuffer.Canvas.MoveTo(X, Y);
  X1 := Round(W + 0.8 * W * Sin(DAngle - Pi / 20));
  Y1 := Round(H - 0.8 * H * Cos(DAngle - Pi / 20));
  FBuffer.Canvas.LineTo(X1, Y1);
  if Parent <> nil then
  begin
    Invalidate;
    PostMessage(Handle, WM_PAINT, 0, 0);
  end;
end;

procedure TAngle.SetAngle(const Value: Extended);
begin
  FAngle := Value;
  if Assigned(FOnChange) then
    FOnChange(Self);
  RecteateImage;
end;

procedure TAngle.SetLoading(const Value: boolean);
begin
  FLoading := Value;
end;

procedure TAngle.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

end.
