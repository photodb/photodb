unit uDateTimePickerStyleHookXP;

interface

uses
  Classes,
  UITypes,
  SysUtils,
  Windows,
  StdCtrls,
  Controls,
  Themes,
  Graphics,
  ComCtrls,
  Messages;

type
  TDateTimePickerStyleHookXP = class(TEditStyleHook)
  private
    procedure UpdateColors;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

function Blend(Color1, Color2: TColor): TColor;
var
  r, g, b: byte;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);

  R := (GetRValue(Color1) + GetRValue(Color2)) div 2;
  G := (GetGValue(Color1) + GetGValue(Color2)) div 2;
  B := (GetBValue(Color1) + GetBValue(Color2)) div 2;

  Result := RGB(R, G, B);
end;

{ TDateTimePickerStyleHook }

constructor TDateTimePickerStyleHookXP.Create(AControl: TWinControl);
begin
  inherited;
  //call the UpdateColors method to use the custom colors
  UpdateColors;
end;

//Here you set the colors of the style hook
procedure TDateTimePickerStyleHookXP.UpdateColors;
var
  LStyle: TCustomStyleServices;
begin
  LStyle := StyleServices;
  if Control.Enabled then
  begin
    Brush.Color := Blend(LStyle.GetStyleColor(scEdit), clWindow);
    FontColor := TDateTimePicker(Control).Font.Color; // use the Control font color
  end else
  begin
    // if the control is disabled use the colors of the style
    Brush.Color := LStyle.GetStyleColor(scEditDisabled);
    FontColor := LStyle.GetStyleFontColor(sfEditBoxTextDisabled);
  end;
end;

//Handle the messages of the control
procedure TDateTimePickerStyleHookXP.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_CTLCOLORMSGBOX..CN_CTLCOLORSTATIC:
      begin
        //Get the colors
        UpdateColors;
        SetTextColor(Message.WParam, ColorToRGB(FontColor));
        SetBkColor(Message.WParam, ColorToRGB(Brush.Color));
        Message.Result := LRESULT(Brush.Handle);
        Handled := True;
      end;
    CM_ENABLEDCHANGED:
      begin
        //Get the colors
        UpdateColors;
        Handled := False;
      end
  else
    inherited WndProc(Message);
  end;
end;

end.
