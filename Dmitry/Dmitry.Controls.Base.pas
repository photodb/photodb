unit Dmitry.Controls.Base;

interface

uses
  System.Types,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.Dwmapi,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Themes;

type
  TBaseWinControl = class(TWinControl)
  private
    FDisableStyles: Boolean;
    function GetIsStyleEnabled: Boolean;
  protected
    function DrawElement(DC: HDC): Boolean; virtual;
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    property IsStyleEnabled: Boolean read GetIsStyleEnabled;
  public
     { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure DrawBackground(Canvas: TCanvas);
  published
    property DisableStyles: Boolean read FDisableStyles write FDisableStyles default False;
  end;

implementation

uses
  Dmitry.Controls.WebLinkList;

type
  TParentControl = class(TWinControl);

{ This procedure is copied from RxLibrary VCLUtils }
procedure CopyParentImage(Control: TControl; Dest: TCanvas);
var
  I, Count, X, Y, SaveIndex: Integer;
  DC: HDC;
  R, SelfR, CtlR: TRect;
begin
  if (Control = nil) OR (Control.Parent = nil)
  then Exit;

  Count := Control.Parent.ControlCount;
  DC    := Dest.Handle;
  with Control.Parent
   DO ControlState := ControlState + [csPaintCopy];

  TRY
    with Control do
     begin
      SelfR := Bounds(Left, Top, Width, Height);
      X := -Left; Y := -Top;
     end;

    { Copy parent control image }
    SaveIndex := SaveDC(DC);
    TRY
      SetViewportOrgEx(DC, X, Y, nil);
      IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth, Control.Parent.ClientHeight);
      with TParentControl(Control.Parent) do
       begin
        Perform(WM_ERASEBKGND, WParam(DC), 0);
        PaintWindow(DC);
       end;
    FINALLY
      RestoreDC(DC, SaveIndex);
    END;

    { Copy images of graphic controls }
    for I := 0 to Count - 1 do begin
      if Control.Parent.Controls[I] = Control then Break
      else if (Control.Parent.Controls[I] <> nil) and
        (Control.Parent.Controls[I] is TGraphicControl) then
      begin
        with TGraphicControl(Control.Parent.Controls[I]) do begin
          CtlR := Bounds(Left, Top, Width, Height);
          if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then
          begin
            ControlState := ControlState + [csPaintCopy];
            SaveIndex := SaveDC(DC);
            try
              SetViewportOrgEx(DC, Left + X, Top + Y, nil);
              IntersectClipRect(DC, 0, 0, Width, Height);
              {$R-}
              Perform(WM_PAINT, WParam(DC), 0);
              {$R+}
            finally
              RestoreDC(DC, SaveIndex);
              ControlState := ControlState - [csPaintCopy];
            end;
          end;
        end;
      end;
    end;
  FINALLY
    with Control.Parent DO
     ControlState := ControlState - [csPaintCopy];
  end;
end;

{ TBaseWinControl }

constructor TBaseWinControl.Create(AOwner: TComponent);
begin
  FDisableStyles := False;
  inherited;
end;

procedure TBaseWinControl.DrawBackground(Canvas: TCanvas);
begin
  if IsStyleEnabled then
  begin
    //for forms don't use draw parent background
    //when form is starting - it causing filling it with white color on short time
    if Parent is TForm then
    begin
      Canvas.Brush.Color := StyleServices.GetSystemColor(clBtnFace);
      Canvas.Pen.Color := StyleServices.GetSystemColor(clBtnFace);
      Canvas.Rectangle(0, 0, Width, Height);
    end else if (Parent <> nil) and Parent.HandleAllocated then
    begin
      if Parent is TWebLinkList then
      begin
        StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
      end else
      begin
        SetBkMode(Canvas.Handle, TRANSPARENT);
        StyleServices.DrawParentBackground(Handle, Canvas.Handle, nil, False);
      end;
    end;
  end else
  begin
    if (csParentBackground in ControlStyle) and
      ((Parent is TTabSheet) or (Parent is TWebLinkList) or (Parent is TGroupBox)) then
      CopyParentImage(Self, Canvas)
    else
    begin
      Canvas.Brush.Color := Color;
      Canvas.Pen.Color := Color;
      Canvas.Rectangle(0, 0, Width, Height);
    end;
  end;
end;

function TBaseWinControl.DrawElement(DC: HDC): Boolean;
begin
  Result := False;
end;

function TBaseWinControl.GetIsStyleEnabled: Boolean;
begin
  Result := StyleServices.Enabled and TStyleManager.IsCustomStyleActive and not FDisableStyles;
end;

procedure TBaseWinControl.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  if DwmCompositionEnabled and Parent.DoubleBuffered then
    inherited
  else
  begin
    DC := BeginPaint(Handle, PS);
    try
      if not DrawElement(DC) then
        inherited
    finally
      EndPaint(Handle, PS);
    end;
  end;
end;

procedure TBaseWinControl.WMPrintClient(var Message: TWMPrintClient);
begin
  inherited;
  DrawElement(Message.DC);
end;

end.
