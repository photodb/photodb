unit UnitTimeCounter;

interface

uses WIndows, ExtCtrls, DateUtils, Math;

type
  TTimeCounter = class(TObject)
  private
   FBeginTime : Cardinal;
   FLastTIme : Cardinal;
   FTimer : TTimer;
   FTimerInterval: integer;
   FMaxActions: int64;
   FLastActions : int64;
   ActionsLeft : int64;
   FPrevIntervalActions : int64;
   FCheckTime : Cardinal;
    { Private declarations }
   procedure OnTimer(Sender : TObject);
    procedure SetTimerInterval(const Value: integer);
    procedure SetMaxActions(const Value: int64);
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure DoBegin;
    procedure NextAction(Actions : int64 = 1);
    procedure Suspend;
    procedure Resume;
    function GetTimeRemaining : TDateTime;
    procedure AddActions(Actions: int64);
    property TimerInterval : integer read FTimerInterval write SetTimerInterval;
    property MaxActions : int64 read FMaxActions write SetMaxActions;
  end;

implementation

{ TTimeCounter }

procedure TTimeCounter.AddActions(Actions: int64);
begin
 FMaxActions:=FMaxActions+Actions;
end;

constructor TTimeCounter.Create;
begin
 FTimer := TTimer.Create(nil);
 FTimer.Enabled:=false;
 FTimer.OnTimer:=OnTimer;
 FTimerInterval:=1000;
 FTimer.Interval:=FTimerInterval;
 FMaxActions:=0;
 FBeginTime:=0;
 FLastTIme:=0;
 FLastActions:=0;
 FPrevIntervalActions:=0;
 ActionsLeft:=0;
end;

destructor TTimeCounter.Destroy;
begin
 FTimer.Free; 
 inherited;
end;

procedure TTimeCounter.DoBegin;
begin
 FTimer.Enabled:=true;
 FBeginTime:=Windows.GetTickCount;
 FLastTIme:=0;
end;

function TTimeCounter.GetTimeRemaining: TDateTime;
var
  h,m,s,ss : byte;
  TimeRem : Cardinal;
  e,a : extended;
begin
 Result:=0;
 if FPrevIntervalActions=0 then
 begin
  if GetTickCount-FBeginTime=0 then exit;
  
  e:=FLastActions/(GetTickCount-FBeginTime);
  e:=FMaxActions/e;   //all time to operation
  e:=e-(GetTickCount-FBeginTime); //remaining
 end else
 begin
  a:=FPrevIntervalActions/FTimerInterval; //last production
                                     //actions remaining
  e:=(GetTickCount-FCheckTime)+(FMaxActions-ActionsLeft)/a;
 end;

 TimeRem:=Round(e);
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
//Range check erro
 ss:=Round(TimeRem/1000);   //seconds
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
 s:=ss mod 60;
 ss:=ss-s;
 ss:=ss div 60;

 m:=ss;
 ss:=ss-m;
 ss:=ss div 60;

 h:=ss;

 Result:=EncodeDateTime(2000,1,1,h,m,s,1);
end;

procedure TTimeCounter.NextAction(Actions : int64 = 1);
begin
 FLastActions:=FLastActions+Actions;
 ActionsLeft:=ActionsLeft+Actions;
end;

procedure TTimeCounter.OnTimer(Sender: TObject);
begin
 FPrevIntervalActions:=FLastActions;
 FLastActions:=0;
 FCheckTime:=GetTickCount;
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
