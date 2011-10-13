unit uTime;

interface

uses
  Classes, Windows, SysUtils, SyncObjs, uMemory;

{$DEFINE _STARTUP}
{$DEFINE _PROFILER}
{$DEFINE _MULTIFILES}
{$DEFINE _MULTITHREAD}

type
  TW = class(TObject)
  private
{$IFDEF PROFILER}
    FS: TFileStream;
    SW: TStreamWriter;
{$ENDIF}
    FStart: TDateTime;
    FMessageThreadID: THandle;
    FStartUp: TDateTime;
    IsRuning: Boolean;
    FName: string;
    FThreadID: THandle;
{$IFDEF MULTITHREAD}
    FSync: TCriticalSection;
{$ENDIF}
  private
    procedure Stop;
  public
    constructor Create(ThreadID: THandle);
    destructor Destroy; override;
    procedure Start(Name: string);
    procedure Check(Name: string);
    class function I: TW;
    property ThreadID: THandle read FThreadID;
  end;

implementation

var
  W : TList = nil;
  Sync : TCriticalSection = nil;

{ TW }

procedure TW.Check(Name: string);
begin
  Start(Name);
  Stop;
end;

constructor TW.Create(ThreadID : THandle);
begin
{$IFDEF MULTITHREAD}
  FSync := TCriticalSection.Create;
{$ENDIF}
  FThreadID := ThreadID;
  IsRuning := False;
  FStartUp := Now;
  if MainThreadID = ThreadID then
    FThreadID := 0;
{$IFNDEF MULTIFILES}
  FThreadID := 0;
{$ENDIF}

{$IFDEF PROFILER}
  FS := TFileStream.Create(Format('tw%d.txt', [ThreadID]), fmCreate or fmShareDenyWrite);
  SW := TStreamWriter.Create(FS, TEncoding.UTF8);
{$ENDIF}
end;

destructor TW.Destroy;
begin
{$IFDEF PROFILER}
  SW.Free;
  FS.Free;
{$ENDIF}
{$IFDEF MULTITHREAD}
  FSync.Free;
{$ENDIF}
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

{$IFDEF MULTIFILES}
    CurrentThreadID := GetCurrentThreadID;
    if MainThreadID = CurrentThreadID then
      CurrentThreadID := 0;
{$ENDIF}
{$IFNDEF MULTIFILES}
    CurrentThreadID := 0;
{$ENDIF}
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
{$IFNDEF PROFILER}
  Exit;
{$ENDIF}
{$IFDEF MULTITHREAD}
  FSync.Enter;
  try
{$ENDIF}
  if IsRuning then
    Stop;

  FName := Name;
  FStart := Now;
  FMessageThreadID := GetCurrentThreadID;
  IsRuning := True;
{$IFDEF MULTITHREAD}
  finally
    FSync.leave;
  end
{$ENDIF}
end;

procedure TW.Stop;
var
  Info : string;
  Delta : Integer;
begin
  IsRuning := False;
  Delta := Round((Now - FStart) * 24 * 60 * 60 * 1000);
{$IFDEF STARTUP}
  if Delta > 0 then
{$ENDIF}
  begin
    Info := Format('%s = %d ms. (%d ms.)', [FName, Delta , Round((Now - FStartUp) * 24 * 60 * 60 * 1000)]);
{$IFDEF MULTITHREAD}
    Info := IntToStr(FMessageThreadID) + ': ' + Info;
{$ENDIF}
{$IFDEF PROFILER}
    SW.Write(Info);
    SW.WriteLine;
{$ENDIF}
  end;
end;

initialization

  TW.I.Start('initialization');

finalization

  FreeList(W);
  F(Sync);

end.
