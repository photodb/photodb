unit uVCLHelpers;

interface

uses
  ExtCtrls;

type
  TTimerHelper = class helper for TTimer
  public
    procedure Restart;
  end;

implementation

{ TTimerHelper }

procedure TTimerHelper.Restart;
begin
  Enabled := False;
  Enabled := True;
end;

end.
