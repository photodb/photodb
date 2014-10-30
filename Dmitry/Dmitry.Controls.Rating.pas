unit Dmitry.Controls.Rating;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Themes,
  Dmitry.Memory,
  Dmitry.Graphics.Types,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.Base;

type
  TOnRatingMessage = procedure(Sender : TObject; Rating : Integer) of Object;

type
  TRating = class(TBaseWinControl)
  private
    { Private declarations }
    FIsImageCreated: Boolean;
    FRating: Integer;
    FRatingRange: Integer;
    FCanvas: TCanvas;
    FIcons: array[0..5] of HIcon;
    FDisabledImages: array[0..5] of TLayeredBitmap;
    FNormalImages: array[0..5] of TLayeredBitmap;
    FOnRating: TOnRatingMessage;
    FOnRatingRange: TOnRatingMessage;
    FBufferBitmap: TBitmap;
    FOnChange: TNotifyEvent;
    FIslayered: boolean;
    FLayered: integer;
    FOnMouseDown: TNotifyEvent;
    FImageCanRegenerate: Boolean;
    FIsMouseDown: Boolean;
    FCanSelectRange: Boolean;
    procedure SetRating(const Value: Integer);
    procedure SetOnRating(const Value: TOnRatingMessage);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetIslayered(const Value: boolean);
    procedure Setlayered(const Value: integer);
    procedure SetOnMouseDown(const Value: TNotifyEvent);
    procedure SetImageCanRegenerate(const Value: boolean);
    procedure SetRatingRange(const Value: Integer);
    procedure SetOnRatingRange(const Value: TOnRatingMessage);
  public
    { Protected declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Paint(var Message : Tmessage); message WM_PAINT;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseDown(var Message: TMessage); message WM_LBUTTONDOWN;  
    procedure WMMouseUp(var Message: TMessage); message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TMessage); message WM_MOUSEMOVE; 
    procedure CMMouseLeave(var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure WMSize(var Message : TMessage); message WM_SIZE;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure DoDrawImageByrating(HDC : THandle; X, Y, Rating : integer);
    procedure RecreateBuffer; 
    procedure Refresh;
  protected     
    { Protected declarations }
    procedure CreateLBMP;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Cursor;     
    property OnDblClick;
    property OnClick;
    property PopupMenu;
    property ParentColor;
    property Color;
    property Hint;
    property ShowHint;
    property ParentShowHint;
    property Visible;
    property Rating: Integer read FRating write SetRating;
    property RatingRange: Integer read FRatingRange write SetRatingRange;
    property OnRating: TOnRatingMessage read FOnRating write SetOnRating;
    property OnRatingRange: TOnRatingMessage read FOnRatingRange write SetOnRatingRange;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property Islayered: Boolean Read FIslayered write SetIslayered;
    property Layered: Integer Read FLayered write Setlayered;
    property OnMouseDown: TNotifyEvent read FOnMouseDown write SetOnMouseDown;
    property ImageCanRegenerate: boolean read FImageCanRegenerate write SetImageCanRegenerate;
    property CanSelectRange: Boolean read FCanSelectRange write FCanSelectRange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TRating]);
end;

{ TRating }

{$R Ratingres.res}

procedure TRating.Refresh;
begin
  RecreateBuffer;
  Repaint;
end;

procedure TRating.WMMouseDown(var Message: TMessage);
begin
  if not Enabled then
    Exit;

  FIsMouseDown := True;  
  Rating := Message.LParamLo div 16;
  RatingRange := Rating;

  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self);
end;

constructor TRating.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  Height := 16;
  Width := 6 * 16;
  FRating := 0;
  FRatingRange := 0;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  ControlStyle := ControlStyle - [csDoubleClicks];
  DoubleBuffered := True;
  FImageCanRegenerate := False;
  FLayered := 100;
  FIsLayered := False;
  FBufferBitmap := TBitmap.Create;
  FBufferBitmap.PixelFormat := pf24bit;
  FBufferBitmap.SetSize(Width, Height);
  for I := 0 to 5 do
  begin
    FNormalImages[I] := TLayeredBitmap.Create;
    FNormalImages[I].IsLayered := True;
    FDisabledImages[I] := TLayeredBitmap.Create;
    FDisabledImages[I].IsLayered := True;
  end;
  FIcons[0] := LoadImage(Hinstance, 'TRATING_DEL', IMAGE_ICON, 16, 16, 0);
  for I := 1 to 5 do
    FIcons[I] := LoadImage(Hinstance, PChar('TRATING_' + IntToStr(I)), IMAGE_ICON, 16, 16, 0);
  CreateLBMP;
  FIsImageCreated := False;
  FIsMouseDown := False;
end;

destructor TRating.Destroy;
var
  I: Integer;
begin
  F(FBufferBitmap);
  F(FCanvas);
  for I := 0 to 5 do
  begin
    FNormalImages[I].Free;
    FDisabledImages[I].Free;
    DestroyIcon(FIcons[I]);
  end;
  inherited;
end;

procedure TRating.Paint(var Message: Tmessage);
begin
  inherited;
  if not FIsImageCreated then
  begin
    FIsImageCreated := True;
    RecreateBuffer;
  end;
  FCanvas.Draw(0, 0, FBufferBitmap);
end;

procedure TRating.SetRating(const Value: Integer);
begin
  if FRating = Value then
    Exit;

  FRating := Value;
  if not CanSelectRange then
    FRatingRange := Value;

  if Assigned(FOnRating) then
    FOnRating(Self, FRating);

  if Assigned(FOnChange) then
    FOnChange(Self);

  RecreateBuffer;
  Repaint;
end;  

procedure TRating.SetRatingRange(const Value: Integer);
begin
  FRatingRange := Value; 

  if Assigned(FOnRatingRange) then
    FOnRatingRange(Self, FRatingRange);

  if Assigned(FOnChange) then
    FOnChange(Self);

  RecreateBuffer;
  Repaint;
end;

procedure TRating.SetOnRating(const Value: TOnRatingMessage);
begin
  FOnRating := Value;
end;
 
procedure TRating.SetOnRatingRange(const Value: TOnRatingMessage);
begin
  FOnRatingRange := Value;
end;

procedure TRating.WMSize(var Message: Tmessage);
begin
  Height := 16;
  Width := 6 * 16;
end;

procedure LGrayScale(Image : TLayeredBitmap);
var
  I, J, C : Integer;
  P : PARGB32;
begin
  for I := 0 to Image.Height - 1 do
  begin
    P := Image.ScanLine[I];
    for J := 0 to Image.Width - 1 do
    begin
      C := (P[J].R * 77 + P[J].G * 151 + P[J].B * 28) shr 8;
      P[J].R := C;
      P[J].G := C;
      P[J].B := C;
    end;
  end;
end;

procedure TRating.CreateLBMP;
var
  I: Integer;
begin
  for I := 0 to 5 do
  begin
    FNormalImages[I].LoadFromHIcon(FIcons[I]);
    FDisabledImages[i].Load(FNormalImages[I]);
    LGrayScale(FDisabledImages[I]);
  end;
end;

procedure TRating.RecreateBuffer;
var
  I: Integer;

  function RatingBetween(RatingFrom, RatingTo, Rating : Integer) : Boolean;
  var
    Tmp: Integer;
  begin
    if RatingFrom > RatingTo then
    begin
      Tmp := RatingFrom;
      RatingFrom := RatingTo;
      RatingTo := Tmp;
    end;

    Result := (RatingFrom <= Rating) and (Rating <= RatingTo);
  end;

begin
  if (csReading in ComponentState) then
    Exit;

  if not FImageCanRegenerate and not (csDesigning in ComponentState) then
    Exit;

  DrawBackground(FBufferBitmap.Canvas);
  
  for I := 0 to 5 do
    if not FIsLayered then
    begin
      if RatingBetween(FRating, FRatingRange, I) then
        FNormalImages[I].DoDraw(16 * I, 0, FBufferBitmap)
      else
        FDisabledImages[I].DoDraw(16 * I, 0, FBufferBitmap);
    end else
    begin
      if RatingBetween(FRating, FRatingRange, I) then
        FNormalImages[I].DolayeredDraw(16 * I, 0, FLayered, FBufferBitmap)
      else
        FDisabledImages[I].DolayeredDraw(16 * I, 0, FLayered, FBufferBitmap);
    end;
end;

procedure TRating.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TRating.SetIsLayered(const Value: boolean);
begin
  if FIslayered <> Value then
  begin
    FIslayered := Value;
    Refresh;
  end;
end;

procedure TRating.SetLayered(const Value: integer);
begin
  if FLayered <> Value then
  begin
    FLayered := Value;
    Refresh;
  end;
end;

procedure TRating.SetOnMouseDown(const Value: TNotifyEvent);
begin
  FOnMouseDown := Value;
end;

procedure TRating.DoDrawImageByrating(HDC : THandle; X, Y, Rating: integer);
begin
  DrawIconEx(HDC, X, Y, FIcons[Rating], 16, 16, 0, 0, DI_NORMAL);
end;

procedure TRating.Erased(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRating.SetImageCanRegenerate(const Value: boolean);
begin
  FImageCanRegenerate := Value; 
  if Value then
    RecreateBuffer;
end;

procedure TRating.WMMouseMove(var Message: TMessage);
var
  NewRating : Integer;
begin
  if FIsMouseDown and FCanSelectRange then
  begin
    NewRating := Message.LParamLo div 8;
    if Rating * 2 <> NewRating then
      RatingRange := NewRating div 2;
  end;
end;

procedure TRating.WMMouseUp(var Message: TMessage);
begin
  FIsMouseDown := False;
end;

procedure TRating.CMColorChanged(var Message: TMessage);
begin
  RecreateBuffer;
end;

procedure TRating.CMMouseLeave(var Message: TWMNoParams);
begin
  FIsMouseDown := False;
end;

end.


