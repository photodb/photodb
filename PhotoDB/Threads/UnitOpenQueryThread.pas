unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj, CommCtrl,
  SysUtils, uLogger, uDBThread, uGOM, uDBForm;

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
    constructor Create(Owner: TDBForm; Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
  end;

implementation

{ TOpenQueryThread }

constructor TOpenQueryThread.Create(Owner: TDBForm; Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
begin
  inherited Create(Owner, False);
  FQuery := Query;
  FOnEnd := OnEnd;
  FOwner := Owner;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
  if Assigned(FOnEnd) then
    FOnEnd(Self, FQuery);
end;

procedure TOpenQueryThread.Execute;
begin
  inherited;
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
    SynchronizeEx(DoOnEnd);
    CoUninitialize;
  end;
end;

end.
