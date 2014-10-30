unit Dmitry.Controls.DmProgress;

interface

uses
  Dmitry.Memory,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.ExtCtrls,
  Vcl.Graphics;

type
  ARGB = array [0..32677] of TRGBTriple;
  PARGB = ^ARGB;
  TDmPforress_view = (dm_pr_normal, dm_pr_cool);

type
  TDmProgress = class(TWinControl)
  private
    FCanvas: TCanvas;
    FPosition: Int64;
    FMinValue: Int64;
    FMaxValue: Int64;
    FNPicture: TBitmap;
    fText: string;
    fBorderColor: TColor;
    FCoolColor: TColor;
    fBackGroundColor: TColor;
    FColor: TColor;
    FView: TDmPforress_view;
    FFont: TFont;
    FInverse: Boolean;
    FCurrentProgressPercent: Byte;
    Timer: TTimer;
    FStep: Integer;
    procedure SetMaxValue(const Value: Int64);
    procedure SetMinValue(const Value: Int64);
    procedure SetPosition(const Value: Int64);
    procedure settext(const Value: string);
    procedure setBorderColor(const Value: TColor);
    procedure setCoolColor(const Value: TColor);
    procedure fonrchanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure Paint(var msg : Tmessage); message WM_PAINT;
    procedure WMSize(var Msg : TMessage); message WM_SIZE;
    procedure Setcolor(const Value: TColor);
    procedure SetView(const Value: TDmPforress_view);
    procedure SetFont(const Value: TFont);
    procedure SetInverse(const Value: boolean);
    { Private declarations }
  protected
    { Protected declarations }
    procedure TimerAction(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoPaint;
    procedure Redraw;
    procedure DoPaintOnXY(Canvas: TCanvas; x, y: Integer);
    procedure DoDraw(Canvas: THandle; x, y: Integer);
    { Public declarations }
  published
    property Visible;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property Align;
    property Anchors;
    property Enabled;
    property Cursor;
    property Hint;
    property ShowHint;
    property Position: Int64 read FPosition write SetPosition;
    property MinValue: Int64 Read FMinValue write SetMinValue;
    property MaxValue: Int64 Read FMaxValue write SetMaxValue;
    property Font: TFont read FFont write SetFont;
    property Text: string read fText write settext;
    property BorderColor: TColor read fBorderColor write setBorderColor;
    Property CoolColor: TColor read FCoolColor write setCoolColor;
    Property Color: TColor read FColor write Setcolor;
    property View: TDmPforress_view read FView write SetView;
    property Inverse: Boolean read FInverse write SetInverse;
    { Published declarations }
  end;

procedure Register;

implementation

uses Types;

procedure Register;
begin
  RegisterComponents('Dm', [TDmProgress]);
end;

{ TDmProgress }

constructor TDmProgress.Create(AOwner : TComponent);
begin
  inherited;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  FInverse := False;
  FnPicture := TBitmap.create;
  FNPicture.PixelFormat := pf24bit;
  FFont := TFont.create;
  FMinvalue := 0;
  FMaxValue := 100;
  FPosition := 0;
  Ftext := 'Progress... (&%%)';
  FBorderColor := RGB(0,150,0);
  FcoolColor := RGB(0,150,0);
  FbackGroundColor := RGB(0,0,0);
  FColor := RGB(0,0,0);
  FView := dm_pr_cool;
  FFont.Color := $00FF0080;
  Width := 100;
  Height := 18;
  FCurrentProgressPercent := 255;
  FStep := 0;
  Timer := TTimer.Create(nil);
  Timer.Interval := 10;
  Timer.OnTimer := TimerAction;
  Timer.Enabled := True;

  if AOwner is TWinCOntrol then
    Parent:= AOwner as TWinCOntrol;
end;

destructor TDmProgress.destroy;
begin
  F(FNPicture);
  F(FCanvas);
  F(FFont);
  F(Timer);
  inherited;
end;

procedure TDmProgress.Paint(var msg: Tmessage);
begin
  inherited;
  DoPaint;
end;

procedure TDmProgress.setBorderColor(const Value: Tcolor);
begin
  FBorderColor := Value;
  Redraw;
end;

procedure TDmProgress.setCoolColor(const Value: Tcolor);
begin
  FCoolColor := Value;
  Redraw;
end;

procedure TDmProgress.SetMaxValue(const Value: Int64);
begin
  FMaxValue := Value;
  If FMaxvalue < FMinvalue then
    FMaxvalue := FMinvalue + 1;
  if FMaxValue = 0 then
    FMaxValue := 1;
  SetPosition(fposition);
end;

procedure TDmProgress.SetMinValue(const Value: Int64);
begin
  FMinValue := Value;
  If FMaxvalue < FMinvalue then
    FMinvalue := FMaxvalue - 1;
  SetPosition(FPosition);
end;

procedure TDmProgress.SetText(const Value: string);
begin
  FText := Value;
  Redraw;
end;

procedure TDmProgress.WMSize(var Msg: TMessage);
begin
  Fnpicture.Width := Width;
  Fnpicture.Height := Height;
  Redraw;
end;

procedure TDmProgress.fonrchanged(var Message: TMessage);
begin
 SetPosition(fposition);
end;

procedure TDmProgress.SetView(const Value: TDmPforress_view);
begin
  FView := Value;
  SetPosition(fposition);
end;

procedure TDmProgress.TimerAction(Sender: TObject);
var
  Canvas: TCanvas;
begin
  if StyleServices.Available and (Inverse) and Visible then
  begin
    Inc(FStep, 1);
    if FStep mod 100 = 0 then
     FStep := 0;

    Canvas := TCanvas.Create;
    try
      Canvas.Handle := GetWindowDC(Handle);
      DoDraw(Canvas.Handle, 0, 0);
    finally
      ReleaseDC(Handle, Canvas.Handle);
      Canvas.Handle := 0;
      F(Canvas);
    end;
  end else
    Timer.Enabled := False;
end;

procedure TDmProgress.Setcolor(const Value: TColor);
begin
  FColor := Value;
  SetPosition(fposition);
end;

procedure TDmProgress.SetFont(const Value: TFont);
begin
  FFont.assign(Value);
  SetPosition(fposition);
end;

procedure TDmProgress.SetInverse(const Value: boolean);
begin
  FInverse := Value;
end;

procedure TDmProgress.DoPaint;
begin
  Redraw;
end;

procedure TDmProgress.DoPaintOnXY(Canvas : TCanvas; X, Y : integer);
begin
  DoDraw(Canvas.Handle, X ,Y);
end;

procedure TDmProgress.SetPosition(const Value: Int64);
var
  FNewProgressPercent : Byte;
begin
  if (Value > FMaxValue) or (Value < FMinValue) then
    FPosition := FMaxValue
  else
    FPosition := Value;

  FNewProgressPercent := Round(100 * ((FPosition - FMinValue)/(FMaxValue - FMinValue)));
  if (FNewProgressPercent <> FCurrentProgressPercent) then
  begin
    FCurrentProgressPercent := FNewProgressPercent;
    Redraw;
  end;
end;

procedure TDmProgress.Redraw;
begin
  if Visible or (csDesigning in ComponentState) then
    DoDraw(FCanvas.Handle, 0, 0);
end;

procedure TDmProgress.DoDraw(Canvas: THandle; X, Y: Integer);
var
  P: PARGB;
  I, J, W, C: Integer;
  DrawRect: TRect;
  Text: string;
  R, G, B: Byte;
  RB, GB, BB: Byte;
  RC, GC, BC: Byte;

  function TextHeight(DC: HDC; const Text: string): Integer;
  var
    Size: TSize;
  begin
    Size.cx := 0;
    Size.cy := 0;
    GetTextExtentPoint32(Canvas, PChar(Text), Length(Text), Size);
    Result := Size.cy;
  end;

  function GetPercent: Single;
  var
    LMin, LMax, LPos: Int64;
  begin
    LMin := MinValue;
    LMax := MaxValue;
    LPos := Position;
    if (LMin >= 0) and (LPos >= LMin) and (LMax >= LPos) and (LMax - LMin <> 0) then
      Result := (LPos - LMin) / (LMax - LMin)
    else
      Result := 0;
  end;

  function BarRect: TRect;
  begin
    Result := TRect.Create(0, 0, Width, Height);
    InflateRect(Result, -BorderWidth, -BorderWidth);
  end;

  procedure PaintFrame(Canvas: TCanvas);
  var
    R: TRect;
    Details: TThemedElementDetails;
  begin
    if not StyleServices.Available then Exit;
    R := BarRect;
    //if Orientation = pbHorizontal then
      Details := StyleServices.GetElementDetails(tpBar);
    //else
    //  Details := StyleServices.GetElementDetails(tpBarVert);
    StyleServices.DrawElement(Canvas.Handle, Details, R);
  end;

  procedure DrawInverseBar(Canvas: TCanvas);
  var
    FillR, R: TRect;
    W, Pos: Integer;
    Details: TThemedElementDetails;
  begin
    if StyleServices.Enabled then
    begin
      R := BarRect;
      InflateRect(R, -1, -1);
      //if Orientation = pbHorizontal then
        W := R.Width;
      //else
      //  W := R.Height;

      Pos := Round(W * 0.1);
      FillR := R;
      //if Orientation = pbHorizontal then
      begin
        FillR.Right := FillR.Left + Pos;
        Details := StyleServices.GetElementDetails(tpChunk);
      end;// else
      //begin
      //  FillR.Top := FillR.Bottom - Pos;
      //  Details := StyleServices.GetElementDetails(tpChunkVert);
      // end;

      FillR.SetLocation(Round((FStep / 10) * FillR.Width), FillR.Top);
      StyleServices.DrawElement(Canvas.Handle, Details, FillR);
    end;
  end;

  procedure PaintBar(Canvas: TCanvas);
  var
    FillR, R: TRect;
    W, Pos: Integer;
    Details: TThemedElementDetails;
  begin
    if not StyleServices.Available then
      Exit;

    if Inverse then
    begin
      DrawInverseBar(Canvas);
      Exit;
    end;

    R := BarRect;
    InflateRect(R, -1, -1);
    //if Orientation = pbHorizontal then
      W := R.Width;
    //else
    //  W := R.Height;
    Pos := Round(W * GetPercent);
    FillR := R;
    //if Orientation = pbHorizontal then
    begin
      FillR.Right := FillR.Left + Pos;
      Details := StyleServices.GetElementDetails(tpChunk);
    end;
    //else
    //begin
    //  FillR.Top := FillR.Bottom - Pos;
    //  Details := StyleServices.GetElementDetails(tpChunkVert);
    //end;
    StyleServices.DrawElement(Canvas.Handle, Details, FillR);
  end;

  procedure DrawStyledProgress(Canvas: TCanvas);
  var
    Details: TThemedElementDetails;
  begin
    if StyleServices.Available then
    begin
      Details.Element := teProgress;
      if StyleServices.HasTransparentParts(Details) then
      begin
        if Parent is TForm then
        begin
          Canvas.Brush.Color := StyleServices.GetSystemColor(clBtnFace);
          Canvas.Pen.Color := StyleServices.GetSystemColor(clBtnFace);
          Canvas.Rectangle(0, 0, Width, Height);
        end else
          StyleServices.DrawParentBackground(Handle, Canvas.Handle, Details, False);
      end;
    end;
    PaintFrame(Canvas);
    PaintBar(Canvas);
  end;

  procedure DtawProgressText(Canvas: TCanvas);
  begin
    Text := StringReplace(FText, '&%', IntToStr(FCurrentProgressPercent), [rfReplaceAll]);

    SetBkMode(Canvas.Handle, TRANSPARENT);
    SetBkColor(Canvas.Handle, Color);

    if StyleServices.Enabled then
      SetTextColor(Canvas.Handle, StyleServices.GetStyleFontColor(sfPopupMenuItemTextNormal))
    else
      SetTextColor(Canvas.Handle, FFont.Color);
    SelectObject(Canvas.Handle, FFont.Handle);

    DrawRect := Rect(0, 0,  Width - 1, Height - 1);
    Drawrect.Top := Drawrect.Bottom div 2 - TextHeight(FNPicture.Canvas.Handle, Text) div 2;
    DrawText(Canvas.Handle, PChar(Text), Length(Text), DrawRect, DT_CENTER or DT_VCENTER);
  end;

begin

  FNPicture.Width := Width;
  FNPicture.Height := Height;
  try
    if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
    begin
      DrawStyledProgress(FNPicture.Canvas);
      DtawProgressText(FNPicture.Canvas);
      Exit;
    end;

    R := GetRValue(ColorToRGB(Color));
    G := GetGValue(ColorToRGB(Color));
    B := GetBValue(ColorToRGB(Color));
    rb := GetRValue(ColorToRGB(FBorderColor));
    gb := GetGValue(ColorToRGB(FBorderColor));
    bb := GetBValue(ColorToRGB(FBorderColor));
    rc := GetRValue(ColorToRGB(FCoolColor));
    gc := GetGValue(ColorToRGB(FCoolColor));
    bc := GetBValue(ColorToRGB(FCoolColor));

    for I := 0 to Height - 1 do
    begin
      P := FNPicture.ScanLine[i];
      for J := 0 to Width-1 do
      begin
        P[J].rgbtRed := R;
        P[J].rgbtGreen := G;
        P[J].rgbtBlue := B;
      end;
      P[0].rgbtRed := RB;
      P[0].rgbtGreen := GB;
      P[0].rgbtBlue := BB;
      P[Width - 1].rgbtRed := RB;
      P[Width - 1].rgbtGreen := GB;
      P[Width - 1].rgbtBlue := BB;
    end;

    P := FNPicture.ScanLine[Height - 1];
    for J := 0 to Width - 1 do
    begin
      P[J].rgbtRed := RB;
      P[J].rgbtGreen := GB;
      P[J].rgbtBlue := BB;
    end;

    P := FNPicture.ScanLine[0];
    for J := 0 to Width - 1 do
    begin
      P[J].rgbtRed := RB;
      P[J].rgbtGreen := GB;
      P[J].rgbtBlue := BB;
    end;

    if fview = dm_pr_cool then
    begin
      for I := 2 to Height - 3 do
      begin
        P := FNPicture.ScanLine[I];

        W := Round((Width - 1) * ((FPosition - FMinValue) / (FMaxValue - FMinValue)));
        for J := 2 to W - 2 do
        begin
          if FInverse then
            C := W - 2 - J
          else
            C := J;

          P[C].rgbtRed := RC * J div W;
          P[C].rgbtGreen := GC * J div W;
          P[C].rgbtBlue := BC * J div W;
        end;
      end;
    end else
    begin
      for I := 2 to Height - 3 do
      begin
        P := FNPicture.ScanLine[I];
        W := Round((Width - 1) * ((FPosition - FMinValue) / (FMaxValue - FMinValue)));
        for J := 2 to W - 2 do
        begin
          P[J].rgbtRed := RC;
          P[J].rgbtGreen := GC;
          P[J].rgbtBlue := BC
        end;
      end;
    end;
    DtawProgressText(FNPicture.Canvas);
  finally
    BitBlt(Canvas, X, Y, FNPicture.Width, FNPicture.Height, FNPicture.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

end.
