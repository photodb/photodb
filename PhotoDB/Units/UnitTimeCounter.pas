unit UnitTimeCounter;

interface

uses
  Windows, ExtCtrls, DateUtils, Math;

type
  TTimeCounter = class(TObject)
  private
    FBeginTime: Cardinal;
    FLastTIme: Cardinal;
    FTimer: TTimer;
    FTimerInterval: Integer;
    FMaxActions: Int64;
    FLastActions: Int64;
    ActionsLeft: Int64;
    FPrevIntervalActions: Int64;
    FCheckTime: Cardinal;
    { Private declarations }
    procedure OnTimer(Sender: TObject);
    procedure SetTimerInterval(const Value: Integer);
    procedure SetMaxActions(const Value: Int64);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure DoBegin;
    procedure NextAction(Actions: Int64 = 1);
    procedure Suspend;
    procedure Resume;
    function GetTimeRemaining: TDateTime;
    procedure AddActions(Actions: Int64);
    property TimerInterval: Integer read FTimerInterval write SetTimerInterval;
    property MaxActions: Int64 read FMaxActions write SetMaxActions;
  end;

implementation

{ TTimeCounter }

procedure TTimeCounter.AddActions(Actions: Int64);
begin
  FMaxActions := FMaxActions + Actions;
end;

constructor TTimeCounter.Create;
begin
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;
  FTimerInterval := 1000;
  FTimer.Interval := FTimerInterval;
  FMaxActions := 0;
  FBeginTime := 0;
  FLastTIme := 0;
  FLastActions := 0;
  FPrevIntervalActions := 0;
  ActionsLeft := 0;
end;

destructor TTimeCounter.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TTimeCounter.DoBegin;
begin
  FTimer.Enabled := True;
  FBeginTime := Windows.GetTickCount;
  FLastTIme := 0;
end;

function TTimeCounter.GetTimeRemaining: TDateTime;
var
  H, M, S, Ss: Byte;
  TimeRem: Cardinal;
  E, A: Extended;
begin
  Result := 0;
  if FPrevIntervalActions = 0 then
  begin
    if GetTickCount - FBeginTime = 0 then
      Exit;

    E := FLastActions / (GetTickCount - FBeginTime);
    E := FMaxActions / E; // all time to operation
    E := E - (GetTickCount - FBeginTime); // remaining
  end else
  begin
    A := FPrevIntervalActions / FTimerInterval; // last production
    // actions remaining
    E := (GetTickCount - FCheckTime) + (FMaxActions - ActionsLeft) / A;
  end;

  TimeRem := Round(E);

  SS := Byte(Round(TimeRem / 1000)); // seconds

  S := Ss mod 60;
  Ss := Ss - S;
  Ss := Ss div 60;

 m:=ss;
  Ss := Ss - M;
  Ss := Ss div 60;

  H := Ss;

  Result := EncodeDateTime(2000, 1, 1, H, M, S, 1);
end;

procedure TTimeCounter.NextAction(Actions: Int64 = 1);
begin
  FLastActions := FLastActions + Actions;
  ActionsLeft := ActionsLeft + Actions;
end;

procedure TTimeCounter.OnTimer(Sender: TObject);
begin
  FPrevIntervalActions := FLastActions;
  FLastActions := 0;
  FCheckTime := GetTickCount;
end;

procedure TTimeCounter.Resume;
begin
//
end;

procedure TTimeCounter.SetMaxActions(const Value: int64);
begin
  FMaxActions := Value;
end;

procedure TTimeCounter.SetTimerInterval(const Value: integer);
begin
  FTimerInterval := Value;
  FTimer.Interval := Value;
end;

procedure TTimeCounter.Suspend;
begin
//
end;

end.
