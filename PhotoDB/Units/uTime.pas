unit uTime;

interface

uses Classes, Windows, SysUtils, SyncObjs;

type
  TW = class(TObject)
  private
    FS : TFileStream;
    FStart : TDateTime;
    FStartUp : TDateTime;
    IsRuning : Boolean;
    FName : string;
    FThreadID : THandle;
  public
    constructor Create(ThreadID : THandle);
    destructor Destroy; override;
    procedure Start(Name : string);
    procedure Stop;
    class function I : TW;
    property ThreadID : THandle read FThreadID;
  end;

implementation

var
  W : TList = nil;
  Sync : TCriticalSection = nil;

{ TW }

constructor TW.Create(ThreadID : THandle);
begin
  FThreadID := ThreadID;
  IsRuning := False;
  FStartUp := Now;
  if MainThreadID = ThreadID then
    ThreadID := 0;

  FS := TFileStream.Create(Format('c:\tw%d.txt', [ThreadID]), fmCreate);
end;

destructor TW.Destroy;
begin
  FS.Free;
  inherited;
end;

class function TW.I: TW;
var
  I : Integer;
  CurrentThreadID : THandle;
begin
  Result := nil;
  if Sync = nil then
    Sync := TCriticalSection.Create;

  Sync.Enter;
  try
    if W = nil then
      W := TList.Create;

    CurrentThreadID := GetCurrentThreadID;
    for I := 0 to W.Count - 1 do
      if TW(W[I]).ThreadID = CurrentThreadID then
         Result := W[I];

    if Result = nil then
    begin
      Result := TW.Create(CurrentThreadID);
      W.Add(Result);
    end;
  finally
    Sync.Leave;
  end;
end;

procedure TW.Start(Name: string);
begin
  if IsRuning then
    Stop;

  FName := Name;
  FStart := Now;
  IsRuning := True;
end;

procedure TW.Stop;
var
  Info : string;
  Delta : Integer;
begin
  IsRuning := False;
  Delta := Round((Now - FStart)*24*60*60*1000);
  if Delta >= 10 then
  begin
    Info := Format('%s = %d ms. (%d ms.)%s', [FName, Delta , Round((Now - FStartUp)*24*60*60*1000), #13#10]);
    FS.Write(Info[1], Length(Info))
  end;
end;

initialization
  TW.I.Start('initialization');

end.
