unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj, CommCtrl,
  SysUtils, uLogger, uDBThread, uGOM, uDBForm, uConstants;

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
    destructor Destroy; override;
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

destructor TOpenQueryThread.Destroy;
begin

  inherited;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
  if GOM.IsObj(FOwner) and Assigned(FOnEnd) then
    FOnEnd(Self, FQuery);
end;

procedure TOpenQueryThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  try
    CoInitializeEx(nil, COM_MODE);
    try
      try
        FQuery.Open;
      except
        on e : Exception do
          Eventlog('Error opening query: ' + e.Message);
      end;
    finally
      SynchronizeEx(DoOnEnd);
    end;
  finally
    CoUninitialize;
  end;
end;

end.
