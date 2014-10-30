unit Dmitry.Controls.TwButton;

interface

uses
  System.SysUtils,
  System.Math,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes,
  Dmitry.Memory,
  Dmitry.Controls.Base,
  Dmitry.Graphics.LayeredBitmap;

type
  TTwButton = class(TBaseWinControl)
  private
    { Private declarations }
    FCanvas: TCanvas;
    FBufferBitmap: TBitmap;
    FIcon: TIcon;
    FPushIcon: TIcon;
    FPushed: Boolean;
    Image, PushImage: TLayeredBitmap;
    FOnlyMainImage: Boolean;
    FOnChange: TNotifyEvent;
    FIsLayered: Boolean;
    FLayered: Integer;
    FPainted: Boolean;
    procedure SetIcon(const Value: TIcon);
    procedure SetPushIcon(const Value: TIcon);
    procedure setPushed(const Value: Boolean);
    procedure setOnlyMainImage(const Value: Boolean);
    procedure SetIsLayered(const Value: Boolean);
    procedure SetLayered(const Value: integer);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure RefreshBuffer;
    procedure Paint(var Message: TMessage); message WM_PAINT;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Cursor;
    property Enabled;
    property Icon : TIcon read FIcon write SetIcon;
    property PushIcon : TIcon read fPushIcon write SetPushIcon;
    property Pushed : boolean read fPushed write setPushed default False;
    property Color;
    property ParentColor;
    property Height;
    property Width;
    property Visible;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property OnlyMainImage: Boolean read FOnlyMainImage write setOnlyMainImage;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property IsLayered: Boolean read FIsLayered write SetIsLayered;
    property Layered: Integer read FLayered write SetLayered;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TTwButton]);
end;

{ TTwButton }

procedure TTwButton.CMColorChanged(var Message: TMessage);
begin
  RefreshBuffer;
end;

constructor TTwButton.Create(AOwner: TComponent);
begin
  inherited;
  FPainted := False;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  ControlStyle:=ControlStyle - [csDoubleClicks];
  FIsLayered := False;
  FLayered := 100;
  FIcon := TIcon.Create;
  FPushIcon := TIcon.Create;
  Image := TLayeredBitmap.Create;
  Image.IsLayered := True;
  PushImage := TLayeredBitmap.Create;
  PushImage.IsLayered := True;
  FBufferBitmap := TBitmap.Create;
  FBufferBitmap.PixelFormat := pf24bit;
  if AOwner is TWinControl then
    Parent := AOwner as TWinControl;
end;

destructor TTwButton.Destroy;
begin
  F(FCanvas);
  F(FIcon);
  F(FPushIcon);
  F(FBufferBitmap);
  F(Image);
  F(PushImage);
  inherited;
end;

procedure TTwButton.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TTwButton.Paint(var Message: Tmessage);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  FPainted := True;
  RefreshBuffer;
  DC := BeginPaint(Handle, PS);
  BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, FBufferBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  EndPaint(Handle, PS);
end;

procedure TTwButton.RefreshBuffer;
begin
  if (csReading in ComponentState) then
    Exit;

  if not FPainted then
    Exit;

  Image.LoadFromHIcon(FIcon.Handle);
  FBufferBitmap.Height := Image.Height;
  FBufferBitmap.Width := Image.Width;

  DrawBackground(FBufferBitmap.Canvas);

  if OnlyMainImage and not Pushed then
    Image.GrayScale;

  PushImage.LoadFromHIcon(fPushIcon.Handle, Width, Height);

  if FIsLayered then
  begin

    if not OnlyMainImage then
    begin
      if FPushed then
        PushImage.DolayeredDraw(0, 0, FLayered, FBufferBitmap)
      else
        Image.DolayeredDraw(0, 0, FLayered, FBufferBitmap);
    end else
      Image.DolayeredDraw(0, 0, FLayered, FBufferBitmap);

  end else
  begin

    if not OnlyMainImage then
    begin
      if fPushed then
        PushImage.DoDraw(0, 0, FBufferBitmap)
      else
        Image.DoDraw(0, 0, FBufferBitmap);
    end else
      Image.DoDraw(0, 0, FBufferBitmap);

  end;
  Invalidate;
end;

procedure TTwButton.SetIcon(const Value: TIcon);
begin
  if Value <> nil then
    FIcon.Assign(Value);

  Image.LoadFromHIcon(Value.Handle);
  RefreshBuffer;
end;

procedure TTwButton.SetIsLayered(const Value: Boolean);
begin
  FIsLayered := Value;
  RefreshBuffer;
end;

procedure TTwButton.SetLayered(const Value: integer);
begin
  FLayered := Min(255, Max(0, Value));
  RefreshBuffer;
end;

procedure TTwButton.SetOnlyMainImage(const Value: boolean);
begin
  fOnlyMainImage := Value;
  RefreshBuffer;
end;

procedure TTwButton.SetPushed(const Value: Boolean);
begin
  FPushed := Value;
  RefreshBuffer;
end;

procedure TTwButton.SetPushIcon(const Value: TIcon);
begin
  if Value <> nil then
    FPushIcon.Assign(Value);

  PushImage.LoadFromHIcon(fPushIcon.Handle);
  RefreshBuffer;
end;

procedure TTwButton.WMMouseDown(var Message: TMessage);
begin
  Pushed := Pushed xor True;
  RefreshBuffer;
  if Assigned(FOnChange) then
    FOnChange(self);
end;

procedure TTwButton.WMSize(var Message: TMessage);
begin
  if (FIcon.Width = 0) or (FIcon.Height = 0) then
  begin
    Width := 16;
    Height := 16;
  end else
  begin
    Width := FIcon.Width;
    Height := FIcon.Height;
  end;
end;

end.
