unit Dmitry.Controls.WebLinkList;

interface

uses
  Generics.Collections,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Themes,
  Dmitry.Memory,
  Dmitry.Controls.WebLink;

type
  TWebLinkList = class(TScrollBox)
  strict private
    class constructor Create;
  private
    { Private declarations }
    FLinks: TList;
    FBreakLines: TList;
    FVerticalIncrement: Integer;
    FHorizontalIncrement: Integer;
    FLineHeight: Integer;
    FPaddingTop: Integer;
    FPaddingLeft: Integer;
    FIsRealligning: Boolean;
    FTagEx: string;
    FHorCenter: Boolean;
    procedure SetVerticalIncrement(const Value: Integer);
    procedure SetHorizontalIncrement(const Value: Integer);
    procedure SetLineHeight(const Value: Integer);
    procedure SetPaddingTop(const Value: Integer);
    procedure SetPaddingLeft(const Value: Integer);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    { Protected declarations }
    procedure WndProc(var Message: TMessage); override;
    procedure Erased(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function AddLink(BreakLine: Boolean = False): TWebLink;
    procedure AddControl(Control: TWinControl; BreakLine: Boolean = False);
    procedure ReallignList;
    procedure AutoHeight(MaxHeight: Integer);
    procedure PerformMouseWheel(WheelDelta: NativeUInt; var Handled: Boolean);
    function HasHandle(WHandle: THandle): Boolean;
  published
    { Published declarations }
    property VerticalIncrement: Integer read FVerticalIncrement write SetVerticalIncrement;
    property HorizontalIncrement: Integer read FHorizontalIncrement write SetHorizontalIncrement;
    property LineHeight: Integer read FLineHeight write SetLineHeight;
    property PaddingTop: Integer read FPaddingTop write SetPaddingTop;
    property PaddingLeft: Integer read FPaddingLeft write SetPaddingLeft;
    property HorCenter: Boolean read FHorCenter write FHorCenter default False;
    property TagEx: string read FTagEx write FTagEx;
  end;

  TTWebLinkListStyleHook = class(TScrollingStyleHook)
  protected
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure PaintBackground(Canvas: TCanvas); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TWebLinkList]);
end;

{ TWebLinkList }

procedure TWebLinkList.AddControl(Control: TWinControl; BreakLine: Boolean = False);
begin
  FLinks.Add(Control);

  if BreakLine then
    FBreakLines.Add(Control);
end;

function TWebLinkList.AddLink(BreakLine: Boolean = False): TWebLink;
begin
  Result := TWebLink.Create(Self);
  Result.Parent := Self;
  Result.ParentColor := True;
  FLinks.Add(Result);
  if BreakLine then
    FBreakLines.Add(Result);
end;

procedure TWebLinkList.AutoHeight(MaxHeight: Integer);
begin
  DisableAutoRange;
  try
    Height := Min(MaxHeight, VertScrollBar.Range);
  finally
    EnableAutoRange;
  end;
end;

procedure TWebLinkList.Clear;
var
  I: Integer;
  TempList: TList;
begin
  TempList := TList.Create;
  try
    TempList.Assign(FLinks);
    FLinks.Clear;
    for I := 0 to TempList.Count - 1 do
      TObject(TempList[I]).Free;

    FBreakLines.Clear;
  finally
    F(TempList);
  end;
end;

procedure TWebLinkList.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
  WL: TWinControl;
begin
  for I := 0 to FLinks.Count - 1 do
  begin
    WL := TWinControl(FLinks[I]);
    WL.Enabled := Enabled;
  end;
end;

class constructor TWebLinkList.Create;
begin
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(TWebLinkList, TTWebLinkListStyleHook);
end;

procedure TWebLinkList.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_MOUSEWHEEL) then
  begin
    if Message.wParam > 0 then
      Self.ScrollBy(0, -2)
    else
      Self.ScrollBy(0, 2);
    Message.Msg := 0;
  end;

  inherited;
end;

constructor TWebLinkList.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csDoubleClicks] + [csParentBackground];
  FIsRealligning := False;
  ParentBackground := False;
  FLinks := TList.Create;
  FBreakLines := TList.Create;
  FHorCenter := False;
end;

destructor TWebLinkList.Destroy;
begin
  Clear;
  F(FLinks);
  F(FBreakLines);
  inherited;
end;

procedure TWebLinkList.Erased(var Message: TWMEraseBkgnd);
begin
  if StyleServices.IsSystemStyle then
    inherited
  else
    Message.Result := 1;
end;

function TWebLinkList.HasHandle(WHandle: THandle): Boolean;
var
  I: Integer;
begin
  Result := WHandle = Handle;
  if not Result then
    for I := 0 to FLinks.Count - 1 do
      Result := Result or (TWinControl(FLinks[I]).Handle = WHandle);
end;

procedure TWebLinkList.PerformMouseWheel(WheelDelta: NativeUInt; var Handled: Boolean);
var
  Msg: Cardinal;
  Code: Cardinal;
  I, N: Integer;
  WHandle: THandle;
begin
  WHandle := WindowFromPoint(Mouse.Cursorpos);

  if HasHandle(WHandle) then
  begin
    Handled := True;

    Msg := WM_VSCROLL;

    if NativeInt(WheelDelta) < 0 then
      Code := SB_LINEDOWN
    else
      Code := SB_LINEUP;

    N := Mouse.WheelScrollLines;
    for I := 1 to N do
      Self.Perform(Msg, Code, 0);
    Self.Perform(Msg, SB_ENDSCROLL, 0);
  end;
end;

procedure TWebLinkList.ReallignList;
var
  ClientW: Integer;
  LineHeights, LineWidths: TList<Integer>;

  procedure ReallignControls(CalculateSize: Boolean);
  var
    I, LineIndex, LineHeight, LineStart: Integer;
    OldWL, WL: TWinControl;
    X, Y: Integer;
  begin
    Y := PaddingTop;
    X := PaddingLeft;
    OldWL := nil;
    LineIndex := 0;
    LineHeight := 0;
    for I := 0 to FLinks.Count - 1 do
    begin
      WL := TWinControl(FLinks[I]);
      if CalculateSize and (WL is TWebLink) then
        TWebLink(WL).LoadImage;
      if (I <> 0) and ((X + WL.Width + HorizontalIncrement > ClientW) or (FBreakLines.IndexOf(OldWL) > -1)) then
      begin
        //calculations
        LineHeights.Add(LineHeight);
        LineWidths.Add(X);

        X := PaddingLeft;

        LineHeight := 0;
        if not (OldWL is TStaticText) then
          LineHeight := LineHeight + VerticalIncrement;
        if OldWL <> nil then
          LineHeight := LineHeight + OldWL.Height;

        Y := Y + LineHeight;
        Inc(LineIndex);
      end;

      LineStart := 0;
      if FHorCenter and not CalculateSize and (LineIndex < LineWidths.Count) then
        LineStart := ClientW div 2 - LineWidths[LineIndex] div 2;

      if not CalculateSize then
        WL.SetBounds(X + LineStart, Y, WL.Width, WL.Height);

      OldWL := WL;

      X := X + WL.Width + HorizontalIncrement;
    end;
    LineHeights.Add(LineHeight);
    LineWidths.Add(X);
  end;

begin
  if FIsRealligning then
    Exit;
  if (csReading in ComponentState) then
    Exit;
  if (csLoading in ComponentState) then
    Exit;

  FIsRealligning := True;
  DisableAlign;
  try
    VertScrollBar.Position := 0;

    ClientW := ClientWidth;
    if GetWindowLong(Handle, GWL_STYLE) and WS_VSCROLL <> 0 then
      ClientW := ClientW - GetSystemMetrics(SM_CXVSCROLL);

    LineHeights := TList<Integer>.Create;
    LineWidths := TList<Integer>.Create;
    try
      ReallignControls(True);
      ReallignControls(False);
    finally
      F(LineHeights);
      F(LineWidths);
    end;

  finally
    FIsRealligning := False;
    EnableAlign;
  end;
end;

procedure TWebLinkList.SetHorizontalIncrement(const Value: Integer);
begin
  FHorizontalIncrement := Value;
  ReallignList;
end;

procedure TWebLinkList.SetLineHeight(const Value: Integer);
begin
  FLineHeight := Value;
  ReallignList;
end;

procedure TWebLinkList.SetPaddingLeft(const Value: Integer);
begin
  FPaddingLeft := Value;
  ReallignList;
end;

procedure TWebLinkList.SetPaddingTop(const Value: Integer);
begin
  FPaddingTop := Value;
  ReallignList;
end;

procedure TWebLinkList.SetVerticalIncrement(const Value: Integer);
begin
  FVerticalIncrement := Value;
  ReallignList;
end;

procedure TWebLinkList.WMSize(var Message: TWMSize);
begin
  ReallignList;
end;

{ TTWebLinkListStyleHook }

constructor TTWebLinkListStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  DoubleBuffered := True;
  OverridePaint := True;
  OverrideEraseBkgnd := True;
end;

procedure TTWebLinkListStyleHook.PaintBackground(Canvas: TCanvas);
begin
  if StyleServices.Available then
    StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
end;

procedure TTWebLinkListStyleHook.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if StyleServices.Available then
  begin
    StyleServices.DrawParentBackground(Handle, Message.DC, nil, False);
    Message.Result := 1;
    Handled := True;
  end else
    inherited;
end;

end.
