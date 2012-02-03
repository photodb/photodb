unit uCounters;

interface

uses
  Windows,
  Generics.Collections,
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
  CurrentTime :=GetTickCount;
  FList.Add(TSpeedSctimatePeriod.Create(CurrentTime - FStartTime, BytesDone));
  FStartTime := CurrentTime;

  //perform cleanup
  CurrentSavedTime := 0;
  for I := FList.Count - 1 downto 0 do
  begin
    CurrentSavedTime := CurrentSavedTime + FList[I].TimeInterval;
    if (I > 0) and (CurrentSavedTime > FEstimateInterval) then
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

  Result := Round(Result / (Time / 1000));
end;

procedure TSpeedEstimateCounter.Reset;
begin
  FreeList(FList);
  FStartTime := GetTickCount;
end;

end.
