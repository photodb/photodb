unit Dmitry.Controls.DBLoading;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Dmitry.Graphics.Types;

type
  TDBLoadingDrawBackground = procedure(Sender: TObject; Buffer : TBitmap) of object;

  TDBLoading = class(TWinControl)
  private
    FCanvas: TCanvas;
    FTimer: TTimer;
    FBuffer: TBitmap;
    FLineColor: TColor;
    FActive: Boolean;
    FAngle: Integer;
    FLoadingStaticImage: TBitmap;
    FOnDrawBackground: TDBLoadingDrawBackground;
    procedure SetActive(const Value: Boolean);
    { Private declarations }
  protected
    procedure Paint(var msg: TMessage); message WM_PAINT;
    procedure OnChangeSize(var msg: TMessage); message WM_SIZE;
    procedure RecteateImage;
    procedure OnTimer(Sender : TObject);
    { Protected declarations }
  public
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
    { Public declarations }
  published
    { Published declarations }
    property Align;
    property Anchors;
    property LineColor: TColor read FLineColor write FLineColor;
    property Active: Boolean read FActive write SetActive;
    property OnDrawBackground: TDBLoadingDrawBackground read FOnDrawBackground  write FOnDrawBackground;
    property Visible;
  end;

procedure Register;

{$R Dmitry.Controls.DBLOADING.RES}

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TDBLoading]);
end;

procedure AALine(X1, Y1, X2, Y2: Single; Color: Tcolor; Canvas: Tcanvas);

  function CrossFadeColor(FromColor, ToColor: TColor; Rate: Single): TColor;
  var
    R, G, B: Byte;
  begin
    R := Round(GetRValue(FromColor) * Rate + GetRValue(ToColor) * (1 - Rate));
    G := Round(GetGValue(FromColor) * Rate + GetGValue(ToColor) * (1 - Rate));
    B := Round(GetBValue(FromColor) * Rate + GetBValue(ToColor) * (1 - Rate));
    Result := RGB(R, G, B);
  end;

  procedure Hpixel(X: Single; Y: Integer);
  var
    FadeRate: Single;
  begin
    FadeRate := Sqrt(X - Trunc(X));
    with Canvas do
    begin
      Pixels[Trunc(X), Y] := CrossFadeColor(Color, Pixels[Trunc(X), Y], 1 - FadeRate);
      Pixels[Trunc(X) + 1, Y] := CrossFadeColor(Color, Pixels[Trunc(X) + 1, Y], FadeRate);
    end;
  end;

  procedure Vpixel(X: Integer; Y: Single);
  var
    FadeRate: Single;
  begin
    FadeRate := Sqrt(Y - Trunc(Y));
    with Canvas do
    begin
      Pixels[X, Trunc(Y)] := CrossFadeColor(Color, Pixels[X, Trunc(Y)], 1 - FadeRate);
      Pixels[X, Trunc(Y) + 1] := CrossFadeColor(Color, Pixels[X, Trunc(Y) + 1], FadeRate);
    end;
  end;

var
  I: Integer;
  Ly, Lx, Currentx, Currenty, Deltax, Deltay, L, Skipl: Single;
begin
  if (X1 <> X2) or (Y1 <> Y2) then
  begin
    Currentx := X1;
    Currenty := Y1;
    Lx := Abs(X2 - X1);
    Ly := Abs(Y2 - Y1);

    if Lx > Ly then
    begin
      L := Trunc(Lx);
      Deltay := (Y2 - Y1) / L;
      if X1 > X2 then
      begin
        Deltax := -1;
        Skipl := (Currentx - Trunc(Currentx));
      end
      else
      begin
        Deltax := 1;
        Skipl := 1 - (Currentx - Trunc(Currentx));
      end;
    end
    else
    begin
      L := Trunc(Ly);
      Deltax := (X2 - X1) / L;
      if Y1 > Y2 then
      begin
        Deltay := -1;
        Skipl := (Currenty - Trunc(Currenty));
      end
      else
      begin
        Deltay := 1;
        Skipl := 1 - (Currenty - Trunc(Currenty));
      end;
    end;

    Currentx := Currentx + Deltax * Skipl;
    Currenty := Currenty + Deltay * Skipl; { }

    for I := 1 to Trunc(L) do
    begin
      if Lx > Ly then
        Vpixel(Trunc(Currentx), Currenty)
      else
        Hpixel(Currentx, Trunc(Currenty));
      Currentx := Currentx + Deltax;
      Currenty := Currenty + Deltay;
    end;
  end;
end;

{ TDBLoading }

constructor TDBLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;
  FLoadingStaticImage := TBitmap.Create;
  FLoadingStaticImage.Handle := LoadImage(HInstance, 'DBLOADING', IMAGE_BITMAP,  0, 0, LR_CREATEDIBSECTION);
  FLoadingStaticImage.PixelFormat := pf32bit;
  Width := FLoadingStaticImage.Width;
  Height := FLoadingStaticImage.Height;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 55;
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;

  RecteateImage;
end;

destructor TDBLoading.Destroy;
begin
  FCanvas.Free;
  FBuffer.Free;
  FTimer.Free;
  FLoadingStaticImage.Free;
  inherited;
end;

procedure TDBLoading.OnChangeSize(var msg: Tmessage);
begin
  Width := FLoadingStaticImage.Width;
  Height := FLoadingStaticImage.Height;
  RecteateImage;
end;

procedure TDBLoading.OnTimer(Sender: TObject);
begin
  if not Visible then
    Exit;

  RecteateImage;

  if HandleAllocated then
    SendMessage(Handle, WM_PAINT, 0, 0);
end;

procedure TDBLoading.Paint(var msg: TMessage);
begin
  inherited;
  FCanvas.Draw(0, 0, FBuffer);
end;

procedure TDBLoading.RecteateImage;
var
  X1, Y1, X2, Y2: Integer;
  H, W, W1, W2: Integer;
  G: Integer;
  PS: PARGB32;
  PD: PARGB;
  I, J: Integer;

  procedure DrawAngle(Angle1, Angle2 : Extended; Color : TColor; Size : Integer);
  var
    DAngle1, DAngle2 : Extended;
  begin
    DAngle1 := Angle1 * pi / 180;
    DAngle2 := Angle2 * pi / 180;
    H := FBuffer.Height div 2;
    W := FBuffer.Width div 2;
    X1:=Round(w + Size * Sin(DAngle1));
    Y1:=Round(h - Size * Cos(DAngle1));
    X2:=Round(w + 2.5 * Sin(DAngle2));
    Y2:=Round(h - 2.5 * Cos(DAngle2));
    AALine(X1, Y1, X2, Y2, Color, FBuffer.Canvas);
  end;

begin
  FBuffer.Width := Width;
  FBuffer.Height := Height;

  if Assigned(FOnDrawBackground) then
    FOnDrawBackground(Self, FBuffer);
  for I := 0 to Height - 1 do
  begin
    PS := FLoadingStaticImage.ScanLine[I];
    PD := FBuffer.ScanLine[I];
    for J := 0 to Width - 1 do
    begin
      W1 := PS[J].L;
      W2 := 255 - W1;
      PD[J].R := (PD[J].R * W2 + PS[J].R * W1 + 127) div 255;
      PD[J].G := (PD[J].G * W2 + PS[J].G * W1 + 127) div 255;
      PD[J].B := (PD[J].B * W2 + PS[J].B * W1 + 127) div 255;
    end;
  end;

  G := FAngle * 20;
  DrawAngle(G, G + 10, $8080BD, 15);
  DrawAngle(G, G - 10, $8080BD, 15);
  DrawAngle(G, G,    $0101BD, 15);

  G := G div 10;
  DrawAngle(G, G + 25, $8080BD, 10);
  DrawAngle(G, G - 25, $8080BD, 10);
  DrawAngle(G, G,    $0101BD, 10);
  Inc(FAngle);
  if FAngle > 360 then
    FAngle := 0;
end;

procedure TDBLoading.SetActive(const Value: Boolean);
begin
  FActive := Value;
  FTimer.Enabled := Value;
  RecteateImage;
end;

end.
