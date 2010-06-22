unit uLogger;

interface

uses Windows, Classes, SysUtils, uFileUtils, SyncObjs;

type
  TLogger = class(TObject)
  private
    FFile : TFileStream;
    FSync : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TLogger;
    procedure Message(Value : string);
  end;

procedure EventLog(Message : string);

implementation

var
  Logger : TLogger = nil;

procedure EventLog(Message : string);
begin
  TLogger.Instance.Message(Message);
end;

{ TLogger }

constructor TLogger.Create;
begin
{$IFDEF LOG}
  FSync := TCriticalSection.Create;
  FFile := TFileStream.Create(GetAppDataDirectory+'\EventLog'+ FormatDateTime('yyyy-mm-dd-HH-MM-SS', Now) +'.txt', fmCreate);
{$ENDIF LOG}
end;

destructor TLogger.Destroy;
begin        
{$IFDEF LOG}
  FFile.Free;
  FSync.Free;
{$ENDIF LOG}
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
{$IFDEF LOG}
  FSync.Enter;
  try
    Value := Value + #13#10;
    FFile.Write(Value[1], Length(Value));
  finally
    FSync.Leave;
  end;        
{$ENDIF LOG}
end;

end.
