unit uTime;

interface

uses Classes, Windows, SysUtils, SyncObjs;

{$DEFINE MULTITHREAD}

type
  TW = class(TObject)
  private
    FS : TFileStream;
    FStart : TDateTime;
    FMessageThreadID : THandle;
    FStartUp : TDateTime;
    IsRuning : Boolean;
    FName : string;
    FThreadID : THandle;  
{$IFDEF MULTITHREAD}
    FSync : TCriticalSection;
{$ENDIF}
  private
    procedure Stop;
  public
    constructor Create(ThreadID : THandle);
    destructor Destroy; override;
    procedure Start(Name : string);
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
{$IFDEF MULTITHREAD}
    FSync := TCriticalSection.Create;
{$ENDIF}
  FThreadID := ThreadID;
  IsRuning := False;
  FStartUp := Now;
  if MainThreadID = ThreadID then
    ThreadID := 0;
{$IFDEF MULTITHREAD}
  ThreadID := 0;
{$ENDIF}

  FS := TFileStream.Create(Format('c:\tw%d.txt', [ThreadID]), fmCreate);
end;

destructor TW.Destroy;
begin
  FS.Free;
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

    CurrentThreadID := GetCurrentThreadID;
{$IFDEF MULTITHREAD}
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
  Delta := Round((Now - FStart)*24*60*60*1000);
  //if Delta > 10 then
  begin
    Info := Format('%s = %d ms. (%d ms.)%s', [FName, Delta , Round((Now - FStartUp)*24*60*60*1000), #13#10]);
{$IFDEF MULTITHREAD}
    Info := IntToStr(FMessageThreadID) + ':' + Info;
{$ENDIF}
    FS.Write(Info[1], Length(Info))
  end;
end;

initialization
  TW.I.Start('initialization');

end.
