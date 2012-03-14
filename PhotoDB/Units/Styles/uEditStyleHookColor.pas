unit uEditStyleHookColor;

interface

uses
  UITypes,
  Windows,
  VCL.StdCtrls,
  Vcl.ExtCtrls,
  SysUtils,
  Graphics,
  Controls,
  Themes,
  WatermarkedEdit,
  Messages;

type
  TEditStyleHookColor = class(TEditStyleHook)
  private
    procedure UpdateColors;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

type
  TWinControlForHook = class(TWinControl);

implementation

constructor TEditStyleHookColor.Create(AControl: TWinControl);
begin
  inherited;
  // call the UpdateColors method to use the custom colors
  UpdateColors;
end;

// Here you set the colors of the style hook
procedure TEditStyleHookColor.UpdateColors;
var
  LStyle: TCustomStyleServices;
begin
  if Control.Enabled then
  begin
    if (TWinControlForHook(Control).Color <> clWindow)
     and (TWinControlForHook(Control).Color <> clWhite)
     and (TWinControlForHook(Control).Color <> clBtnFace) then
    begin
      Brush.Color := TWinControlForHook(Control).Color;
      FontColor := TWinControlForHook(Control).Font.Color; // use the Control font color
    end;
  end else
  begin
    // if the control is disabled use the colors of the style
    LStyle := StyleServices;
    Brush.Color := LStyle.GetStyleColor(scEditDisabled);
    FontColor := LStyle.GetStyleFontColor(sfEditBoxTextDisabled);
  end;
end;

// Handle the messages of the control
procedure TEditStyleHookColor.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_CTLCOLORMSGBOX .. CN_CTLCOLORSTATIC:
      begin
        // Get the colors
        UpdateColors;
        SetTextColor(Message.WParam, ColorToRGB(FontColor));
        SetBkColor(Message.WParam, ColorToRGB(Brush.Color));
        Message.Result := LRESULT(Brush.Handle);
        Handled := True;
      end;
    CM_ENABLEDCHANGED:
      begin
        // Get the colors
        UpdateColors;
        Handled := False;
      end
  else
    inherited WndProc(Message);
  end;
end;

procedure ApplyVCLColorsStyleHook(ControlClass: TClass);
begin
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(ControlClass, TEditStyleHookColor);
end;

initialization
  ApplyVCLColorsStyleHook(TEdit);
  ApplyVCLColorsStyleHook(TWatermarkedEdit);
  ApplyVCLColorsStyleHook(TLabeledEdit);

end.
