unit uCounters;

interface

uses
  Generics.Collections,
  System.DateUtils,
  System.SysUtils,
  System.Math,
  Winapi.Windows,
  uMemory;

type
  TSpeedSctimatePeriod = class(TObject)
  private
    FTimeInterval: Cardinal;
    FBytesDone: Int64;
  public
    constructor Create(Interval: Cardinal; BytesDone: Int64);
    property TimeInterval: Cardinal read FTimeInterval;
    property BytesDone: Int64 read FBytesDone;
  end;

  TSpeedEstimateCounter = class(TObject)
  private
    FEstimateInterval: Cardinal;
    FStartTime: Cardinal;
    FList: TList<TSpeedSctimatePeriod>;
    function GetSpeed: Int64;
  public
    constructor Create(EstimateInterval: Cardinal);
    destructor Destroy; override;
    procedure Reset;
    function GetTimeRemaining(BytesRemaining: Int64): TTime;
    procedure AddSpeedInterval(BytesDone: Int64);
    property CurrentSpeed: Int64 read GetSpeed;
  end;

implementation

{ TSpeedSctimatePeriod }

constructor TSpeedSctimatePeriod.Create(Interval: Cardinal; BytesDone: Int64);
begin
  FTimeInterval := Interval;
  FBytesDone := BytesDone;
end;

{ TEstimateCounter }

procedure TSpeedEstimateCounter.AddSpeedInterval(BytesDone: Int64);
var
  CurrentTime: Cardinal;
  CurrentSavedTime: Cardinal;
  I: Integer;
begin
  CurrentTime := GetTickCount;
  FList.Add(TSpeedSctimatePeriod.Create(CurrentTime - FStartTime, BytesDone));
  FStartTime := CurrentTime;

  //perform cleanup
  CurrentSavedTime := 0;
  for I := FList.Count - 1 downto 0 do
  begin
    CurrentSavedTime := CurrentSavedTime + FList[I].TimeInterval;
    if (FList.Count > 0) and (CurrentSavedTime > FEstimateInterval) then
    begin
      FList[I].Free;
      FList.Delete(I);
    end;
  end;
end;

constructor TSpeedEstimateCounter.Create(EstimateInterval: Cardinal);
begin
  FEstimateInterval := EstimateInterval;
  FStartTime := GetTickCount;
  FList := TList<TSpeedSctimatePeriod>.Create;
end;

destructor TSpeedEstimateCounter.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TSpeedEstimateCounter.GetSpeed: Int64;
var
  S: TSpeedSctimatePeriod;
  Time: Cardinal;
begin
  Result := 0;
  Time := 0;
  for S in FList do
  begin
    Result := Result + S.BytesDone;
    Time := Time + S.TimeInterval;
  end;

  if Time = 0 then
    Exit(0);

  Result := Round(Min(MaxInt, Result / (Time / 1000)));
end;

function TSpeedEstimateCounter.GetTimeRemaining(BytesRemaining: Int64): TTime;
var
  H, M, S, SS, D: Integer;
  TimeRem: Extended;

  Speed: Int64;
begin
  Speed := CurrentSpeed;

  if Speed = 0 then
    Exit(0);

  TimeRem := BytesRemaining / Speed;

  if TimeRem < 0 then
    Exit(0);

  SS := Round(Min(MaxInt, TimeRem)); // seconds

  D := SS div SecsPerDay;
  SS := SS - D * SecsPerDay;

  H := SS div SecsPerHour;
  SS := SS - H * SecsPerHour;

  M := SS div SecsPerMin;
  SS := SS - M * SecsPerMin;

  S := SS;

  //max 30 days!
  if D > 30 then
    D := 30;
  Result := EncodeDateTime(1, 1, 1 + D, H, M, S, 1);
end;

procedure TSpeedEstimateCounter.Reset;
begin
  FreeList(FList, False);
  FStartTime := GetTickCount;
end;

end.
