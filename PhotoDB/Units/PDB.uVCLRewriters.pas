unit PDB.uVCLRewriters;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TPageControlNoBorder = class(Vcl.ComCtrls.TPageControl)
  private
    FCanUpdateActivePage: Boolean;
    FIsUpdatingPage: Boolean;
    procedure TCMAdjustRect(var Msg: TMessage); message TCM_ADJUSTRECT;
  protected
    procedure ShowControl(AControl: TControl); override;
    procedure UpdateActivePage; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ShowTab(TabIndex: Integer);
    procedure HideTab(TabIndex: Integer);
    procedure DisableTabChanging;
    procedure EnableTabChanging;
    property IsUpdatingPage: Boolean read FIsUpdatingPage;
  end;

  TShapeWithTransparentBorder = class(Vcl.ExtCtrls.TShape)
  protected
    procedure Paint; override;
  end;

implementation

{ TPageControlNoBorder }

constructor TPageControlNoBorder.Create(AOwner: TComponent);
begin
  FCanUpdateActivePage := True;
  FIsUpdatingPage := False;
  inherited;
end;

procedure TPageControlNoBorder.DisableTabChanging;
begin
  FCanUpdateActivePage := False;
end;

procedure TPageControlNoBorder.EnableTabChanging;
begin
  FCanUpdateActivePage := True;
end;

procedure TPageControlNoBorder.HideTab(TabIndex: Integer);
begin
  Pages[TabIndex].TabVisible := False;
end;

procedure TPageControlNoBorder.ShowControl(AControl: TControl);
begin
 //do nothing - it preventing from flicking
end;

procedure TPageControlNoBorder.ShowTab(TabIndex: Integer);
begin
  Pages[TabIndex].TabVisible := True;
end;

procedure TPageControlNoBorder.TCMAdjustRect(var Msg: TMessage);
begin
  inherited;
  if Msg.WParam = 0 then
    InflateRect(PRect(Msg.LParam)^, 4, 4)
  else
    InflateRect(PRect(Msg.LParam)^, -4, -4);
end;

procedure TPageControlNoBorder.UpdateActivePage;
begin
  FIsUpdatingPage := True;
  try
    if FCanUpdateActivePage then
      inherited;
  finally
    FIsUpdatingPage := False;
  end;
end;

{ TShapeWithTransparentBorder }

procedure TShapeWithTransparentBorder.Paint;
var
  X, Y, W, H, S: Integer;

  procedure RectangleEx(X1, Y1, X2, Y2: Integer);
  var
    Rect: TRect;
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := Pen.Color;
    Canvas.Pen.Width := Pen.Width;
    Canvas.Rectangle(X1, Y1, X2, Y2);

    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Color := Brush.Color;
    Canvas.Brush.Color := Brush.Color;
    Inc(X1, 1 + Pen.Width);
    Inc(Y1, 1 + Pen.Width);
    Dec(X2, 1 + Pen.Width);
    Dec(Y2, 1 + Pen.Width);
    Canvas.Rectangle(X1, Y1, X2, Y2);
  end;

begin
  Canvas.Pen := Pen;
  Canvas.Brush := Brush;
  X := Pen.Width div 2;
  Y := X;
  W := Width - Pen.Width + 1;
  H := Height - Pen.Width + 1;
  if Pen.Width = 0 then
  begin
    Dec(W);
    Dec(H);
  end;
  if W < H then S := W else S := H;
  if Shape in [stSquare, stRoundSquare, stCircle] then
  begin
    Inc(X, (W - S) div 2);
    Inc(Y, (H - S) div 2);
    W := S;
    H := S;
  end;
  case Shape of
    stRectangle, stSquare:
      RectangleEx(X, Y, X + W, Y + H);
    stRoundRect, stRoundSquare:
      Canvas.RoundRect(X, Y, X + W, Y + H, S div 4, S div 4);
    stCircle, stEllipse:
      Canvas.Ellipse(X, Y, X + W, Y + H);
  end;
end;


end.
