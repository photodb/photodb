unit Dmitry.Controls.DmGradient;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs;

type
  TDmGradient = class(TGraphicControl)
  private
    Fonmousedown: TNotifyEvent;
    Fcolorfrom: TColor;
    Fcolorto: TColor;
    FOrientarionHorizontal: Boolean;
    procedure Setcolorfrom(const Value: TColor);
    procedure Setcolorto(const Value: TColor);
    procedure Cmonmousedown(var message: TWMMouse); message WM_LBUTTONdown;
    procedure SetOrientarionHorizontal(const Value: Boolean);
  protected
    Procedure Paint; override;
    { Protected declarations }
  public
    Constructor Create(AOwner: TComponent); override; { Public declarations }
  published
    Property onmousedown: TNotifyEvent read Fonmousedown write Fonmousedown;
    Property Align;
    property ColorFrom: TColor read Fcolorfrom Write Setcolorfrom;
    property ColorTo: TColor read Fcolorto Write Setcolorto;
    property OrientarionHorizontal: Boolean read FOrientarionHorizontal
      write SetOrientarionHorizontal;
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TDmGradient]);
end;

{ TGradient }

constructor TDmGradient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alNone;
  FOrientarionHorizontal := False;
  ColorFrom := $FF0000;
  ColorTo := $0;
  width := 100;
  height := 100;
end;

procedure TDmGradient.Paint;
var
  R, G, B, R1, G1, B1, R2, G2, B2, i, RR1, GG1, BB1: Integer;
  RR, GG, BB: Boolean;
  Rect: TRect;
begin
  if not FOrientarionHorizontal then
  begin
    with inherited Canvas do
    begin
      R1 := GetRvalue(ColorFrom);
      G1 := GetGvalue(ColorFrom);
      B1 := GetBvalue(ColorFrom);
      R2 := GetRvalue(ColorTo);
      G2 := GetGvalue(ColorTo);
      B2 := GetBvalue(ColorTo);
      If R1 - R2 >= 0 then
        RR := True
      else
        RR := False;
      If B1 - B2 >= 0 then
        BB := True
      else
        BB := False;
      If G1 - G2 >= 0 then
        GG := True
      else
        GG := False;
      RR1 := abs(R1 - R2);
      GG1 := abs(G1 - G2);
      BB1 := abs(B1 - B2);
      Rect.Left := 0;
      Rect.Right := width;
      For i := 0 to height do
      begin
        Rect.Top := i - 2;
        Rect.Bottom := i - 1;
        If not RR then
          R := R1 + Round((RR1 / height) * i)
        else
          R := R1 - Round((RR1 / height) * i);
        If not GG then
          G := G1 + Round((GG1 / height) * i)
        else
          G := G1 - Round((GG1 / height) * i);
        If not BB then
          B := B1 + Round((BB1 / height) * i)
        else
          B := B1 - Round((BB1 / height) * i);
        Brush.color := rgb(R, G, B);
        fillrect(Rect);
      end;
    end;
  end
  else
  begin

    with inherited Canvas do
    begin
      R1 := GetRvalue(ColorFrom);
      G1 := GetGvalue(ColorFrom);
      B1 := GetBvalue(ColorFrom);
      R2 := GetRvalue(ColorTo);
      G2 := GetGvalue(ColorTo);
      B2 := GetBvalue(ColorTo);
      if R1 - R2 >= 0 then
        RR := True
      else
        RR := False;
      if B1 - B2 >= 0 then
        BB := True
      else
        BB := False;
      if G1 - G2 >= 0 then
        GG := True
      else
        GG := False;
      RR1 := abs(R1 - R2);
      GG1 := abs(G1 - G2);
      BB1 := abs(B1 - B2);
      Rect.Top := 0;
      Rect.Bottom := height;
      // Rect.Left:=0;
      // Rect.Right:=width;
      for i := 0 to width do
      begin
        // Rect.Top:=i-2;
        // Rect.Bottom:=i-1;
        Rect.Left := i - 2;
        Rect.Right := i - 1;
        If not RR then
          R := R1 + Round((RR1 / width) * i)
        else
          R := R1 - Round((RR1 / width) * i);
        if not GG then
          G := G1 + Round((GG1 / width) * i)
        else
          G := G1 - Round((GG1 / width) * i);
        If not BB then
          B := B1 + Round((BB1 / width) * i)
        else
          B := B1 - Round((BB1 / width) * i);
        Brush.color := rgb(R, G, B);
        fillrect(Rect);
      end;
    end;

  end;
end;

procedure TDmGradient.Setcolorfrom(const Value: TColor);
begin
  Fcolorfrom := Value;
  Invalidate;
end;

procedure TDmGradient.Setcolorto(const Value: TColor);
begin
  Fcolorto := Value;
  Invalidate;
end;

procedure TDmGradient.Cmonmousedown(var message: TWMMouse);
begin
  inherited;
  if Assigned(Fonmousedown) then
    Fonmousedown(Self);
end;

procedure TDmGradient.SetOrientarionHorizontal(const Value: Boolean);
begin
  FOrientarionHorizontal := Value;
end;

end.
