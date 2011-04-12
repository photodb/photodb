unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj, CommCtrl,
  SysUtils, uLogger, uDBThread, uGOM;

type
  TNotifyDBOpenedEvent = procedure(Sender : TObject; DS : TDataSet) of object;

  TOpenQueryThread = class(TDBThread)
  private
    { Private declarations }
    FOnEnd: TNotifyDBOpenedEvent;
    FQuery: TDataSet;
    FOwner: TObject;
  protected
    procedure Execute; override;
  public
    procedure DoOnEnd;
    constructor Create(Owner: TObject; Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
  end;

implementation

{ TOpenQueryThread }

constructor TOpenQueryThread.Create(Owner: TObject; Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
begin
  inherited Create(False);
  FQuery := Query;
  FOnEnd := OnEnd;
  FOwner := Owner;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
  if GOM.IsObj(FOwner) and Assigned(FOnEnd) then
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
