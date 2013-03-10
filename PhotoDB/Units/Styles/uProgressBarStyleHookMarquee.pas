unit uProgressBarStyleHookMarquee;

interface

uses
  Windows,
  uMemory,
  Themes,
  Graphics,
  Classes,
  Controls,
  Vcl.Styles,
  Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TProgressBarStyleHookMarquee = class(TProgressBarStyleHook)
  private
    Timer: TTimer;
    FStep: Integer;
    procedure TimerAction(Sender: TObject);
  protected
    procedure PaintBar(Canvas: TCanvas); override;
  public
    constructor Create(AControl: TWinControl); override;
    destructor Destroy; override;
  end;

implementation

{ TProgressBarStyleHookMarquee }

constructor TProgressBarStyleHookMarquee.Create(AControl: TWinControl);
begin
  inherited;
  FStep := 0;
  Timer := TTimer.Create(nil);
  Timer.Interval := TProgressBar(Control).MarqueeInterval;
  Timer.OnTimer := TimerAction;
  Timer.Enabled := True
end;

destructor TProgressBarStyleHookMarquee.Destroy;
begin
  F(Timer);
  inherited;
end;

procedure TProgressBarStyleHookMarquee.PaintBar(Canvas: TCanvas);
var
  FillR, R: TRect;
  W, Pos: Integer;
  Details: TThemedElementDetails;
begin
  if (TProgressBar(Control).Style = pbstMarquee) and StyleServices.Enabled then
  begin
    R := BarRect;
    InflateRect(R, -1, -1);
    if Orientation = pbHorizontal then
      W := R.Width
    else
      W := R.Height;

    Pos := Round(W * 0.1);
    FillR := R;
    if Orientation = pbHorizontal then
    begin
      FillR.Right := FillR.Left + Pos;
      Details := StyleServices.GetElementDetails(tpChunk);
    end else
    begin
      FillR.Top := FillR.Bottom - Pos;
      Details := StyleServices.GetElementDetails(tpChunkVert);
    end;

    FillR.SetLocation(Round((FStep / 10) * FillR.Width), FillR.Top);
    StyleServices.DrawElement(Canvas.Handle, Details, FillR);
  end else
    inherited;
end;

procedure TProgressBarStyleHookMarquee.TimerAction(Sender: TObject);
var
  Canvas: TCanvas;
begin
  if StyleServices.Available and (TProgressBar(Control).Style = pbstMarquee) and Control.Visible  then
  begin
    Inc(FStep, 1);
    if FStep mod 100 = 0 then
     FStep := 0;

    Canvas := TCanvas.Create;
    try
      Canvas.Handle := GetWindowDC(Control.Handle);
      PaintFrame(Canvas);
      PaintBar(Canvas);
    finally
      ReleaseDC(Handle, Canvas.Handle);
      Canvas.Handle := 0;
      F(Canvas);
    end;
  end;
end;

initialization
  TStyleManager.Engine.RegisterStyleHook(TProgressBar, TProgressBarStyleHookMarquee);

end.
