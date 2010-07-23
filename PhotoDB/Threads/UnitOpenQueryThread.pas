unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj,CommCtrl;

type
  TNotifyDBOpenedEvent = procedure(Sender : TObject; DS : TDataSet) of object;

  TOpenQueryThread = class(TThread)
  private
  FOnEnd : TNotifyDBOpenedEvent;
  FQuery : TDataSet;
    { Private declarations }
  protected
    procedure Execute; override;
  public
   procedure DoOnEnd;
   constructor Create(CreateSuspennded: Boolean; Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
  end;

implementation

{ TOpenQueryThread }

constructor TOpenQueryThread.Create(CreateSuspennded: Boolean;
  Query: TDataSet; OnEnd: TNotifyDBOpenedEvent);
begin
 inherited Create(True);
 FQuery:=Query;
 FOnEnd:=OnEnd;
 if not CreateSuspennded then Resume;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
 if Assigned(FOnEnd) then FOnEnd(Self, FQuery);
end;

procedure TOpenQueryThread.Execute;
begin
 FreeOnTerminate := True;
 CoInitialize(nil);
 try
  FQuery.Open;
 except
 end;
 Synchronize(DoOnEnd);     
 CoUninitialize;
end;



end.
