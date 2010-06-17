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
  FSync := TCriticalSection.Create;
  FFile := TFileStream.Create(GetAppDataDirectory+'\EventLog.txt', fmCreate);
end;

destructor TLogger.Destroy;
begin
  FFile.Free;
  FSync.Free;
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
  FSync.Enter;
  try
    Value := Value + #13#10;
    FFile.Write(Value[1], Length(Value));
  finally
    FSync.Leave;
  end;
end;

end.
