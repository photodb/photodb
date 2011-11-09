unit uVCLHelpers;

interface

uses
  ExtCtrls, Windows, Graphics, StdCtrls;

type
  TTimerHelper = class helper for TTimer
  public
    procedure Restart;
  end;

type
  TButtonHelper = class helper for TButton
  public
    procedure AdjustButtonWidth;
  end;

implementation

procedure TButtonHelper.AdjustButtonWidth;
var
  TextSize: TSize;
  ADC: HDC;
begin
  with TextSize do
    begin
      aDC := GetDC(Handle);
      try
        SelectObject(ADC, Font.Handle);
        GetTextExtentPoint32(ADC, PChar(Caption), Length(Caption), TextSize);
        Width := Cx + 10;
      finally
        ReleaseDc(Handle, ADC);
      end;
    end;
end;

{ TTimerHelper }

procedure TTimerHelper.Restart;
begin
  Enabled := False;
  Enabled := True;
end;

end.
