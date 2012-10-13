unit uMonthCalendar;

interface

uses
  Winapi.Windows,
  Winapi.CommCtrl,
  Winapi.uxTheme,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Styles,
  Vcl.Themes;

type
  TMonthCalendarEx = class(Vcl.ComCtrls.TMonthCalendar)
  private
    FDateSelectTime: Cardinal;
    procedure CNNotify(var Message: TWMNotifyMC); message CN_NOTIFY;
  protected
    procedure DblClick; override;
  public
    procedure DisableStyles;
  end;

implementation

procedure SetVclStylesColorsCalendar(MonthCalendar: TMonthCalendar);
var
  LTextColor, LBackColor: TColor;

  function MixColors(Color1, Color2: TColor): TColor;
  begin
    Color1 := ColorToRGB(Color1);
    Color2 := ColorToRGB(Color2);
    Result := RGB(GetRValue(Color1) div 2 + GetRValue(Color2) div 2,
                  GetGValue(Color1) div 2 + GetGValue(Color2) div 2,
                  GetBValue(Color1) div 2 + GetBValue(Color2) div 2);
  end;

begin
  SetWindowTheme(MonthCalendar.Handle, '', ''); //disable themes in the calendar
  MonthCalendar.AutoSize := True;//remove border

  //get the vcl styles colors
  LTextColor := StyleServices.GetSystemColor(clWindowText);
  LBackColor := StyleServices.GetSystemColor(clWindow);

  //set the colors of the calendar
  MonthCalendar.CalColors.BackColor:= LBackColor;
  MonthCalendar.CalColors.MonthBackColor:=LBackColor;
  MonthCalendar.CalColors.TextColor:=LTextColor;
  MonthCalendar.CalColors.TitleBackColor:=StyleServices.GetSystemColor(clHighlight);
  MonthCalendar.CalColors.TitleTextColor:=LTextColor;
  MonthCalendar.CalColors.TrailingTextColor:= MixColors(LTextColor, LBackColor);
end;

{ TMyCalendar }

procedure TMonthCalendarEx.CNNotify(var Message: TWMNotifyMC);
begin
  if PNMHdr(message.NMHdr)^.code = MCN_SELECT then
    if PNMSelChange(message.NMHdr)^.nmhdr.hwndFrom = Handle then
      FDateSelectTime := GetTickCount;

  inherited;
end;

procedure TMonthCalendarEx.DblClick;
var
  Key: WORD;
begin
  inherited;

  Key := VK_RETURN;
  if GetTickCount - FDateSelectTime <= GetDoubleClickTime then
    KeyDown(Key, []);
end;

procedure TMonthCalendarEx.DisableStyles;
begin
  SetVclStylesColorsCalendar(Self);
end;

end.
