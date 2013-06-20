unit uLogger;

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Winapi.Windows,
  uConfiguration,
  uMemory;

{$DEFINE _EVENTLOG}

type
  TLogger = class(TObject)
  private
{$IFDEF EVENTLOG}
    FFile: TFileStream;
    SW: TStreamWriter;
    FSync: TCriticalSection;
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TLogger;
    procedure Message(Value: string);
  end;

procedure EventLog(Message: string); overload;
procedure EventLog(Ex: Exception); overload;

implementation

var
  Logger: TLogger = nil;

procedure EventLog(Ex: Exception);
var
  Msg, Stack: String;
  Inner: Exception;
begin
  Inner := Ex;
  Msg := '';
  while Inner <> nil do
  begin
    if Msg <> '' then
      Msg := Msg + sLineBreak;
    Msg := Msg + Inner.Message;
    if (Msg <> '') and (Msg[Length(Msg)] > '.') then
      Msg := Msg + '.';

    Stack := Inner.StackTrace;
    if Stack <> '' then
    begin
      if Msg <> '' then
        Msg := Msg + sLineBreak + sLineBreak;
      Msg := Msg + Stack + sLineBreak;
    end;

    Inner := Inner.InnerException;
  end;
  EventLog(Msg);
end;

procedure EventLog(Message: string);
begin
{$IFDEF EVENTLOG}
  TLogger.Instance.Message(Message);
{$ENDIF}
end;

{ TLogger }

constructor TLogger.Create;
begin
{$IFDEF EVENTLOG}
  FSync := TCriticalSection.Create;
  SW := nil;
  try
    FFile := TFileStream.Create(GetAppDataDirectory + '\EventLog' + FormatDateTime('yyyy-mm-dd-HH-MM-SS', Now) + '.txt', fmCreate);
    SW := TStreamWriter.Create(FFile);
  except
    on e: Exception do
      MessageBox(0, PChar(e.Message), PChar('ERROR!'), MB_OK + MB_ICONERROR);
  end;
{$ENDIF EVENTLOG}
end;

destructor TLogger.Destroy;
begin        
{$IFDEF EVENTLOG}
  F(SW);
  F(FFile);
  F(FSync);
{$ENDIF EVENTLOG}
  inherited;
end;

class function TLogger.Instance: TLogger;
begin
  if Logger = nil then
    Logger := TLogger.Create;

  Result := Logger;
end;

procedure TLogger.Message(Value: string);
begin    
{$IFDEF EVENTLOG}
  FSync.Enter;
  try
    Value := Value + #13#10;
    SW.Write(Value);
  finally
    FSync.Leave;
  end;        
{$ENDIF EVENTLOG}
end;

initialization
finalization
  F(Logger);

end.
