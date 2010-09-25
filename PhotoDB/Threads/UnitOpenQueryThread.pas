unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj, CommCtrl,
  SysUtils, uLogger;

type
  TNotifyDBOpenedEvent = procedure(Sender : TObject; DS : TDataSet) of object;

  TOpenQueryThread = class(TThread)
  private
    { Private declarations }
    FOnEnd: TNotifyDBOpenedEvent;
    FQuery: TDataSet;
  protected
    procedure Execute; override;
  public
    procedure DoOnEnd;
    constructor Create(Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
  end;

implementation

{ TOpenQueryThread }

constructor TOpenQueryThread.Create(Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
begin
  inherited Create(False);
  FQuery := Query;
  FOnEnd := OnEnd;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
  if Assigned(FOnEnd) then
    FOnEnd(Self, FQuery);
end;

procedure TOpenQueryThread.Execute;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try
      FQuery.Open;
    except
      on e : Exception do
        Eventlog('Error opening query: ' + e.Message);
    end;
  finally
    Synchronize(DoOnEnd);
    CoUninitialize;
  end;
end;

end.
