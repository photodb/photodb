unit UnitOpenQueryThread;

interface

uses
  Classes, DB, CommonDBSupport, ComObj, ActiveX, ShlObj,CommCtrl;

type
  TOpenQueryThread = class(TThread)
  private
  FOnEnd : TNotifyEvent;
  FQuery : TDataSet;
    { Private declarations }
  protected
    procedure Execute; override;
  public
   procedure DoOnEnd;
   constructor Create(CreateSuspennded: Boolean; Query: TDataSet; OnEnd: TNotifyEvent);
  end;

implementation

{ TOpenQueryThread }

constructor TOpenQueryThread.Create(CreateSuspennded: Boolean;
  Query: TDataSet; OnEnd: TNotifyEvent);
begin
 inherited Create(True);
 FQuery:=Query;
 FOnEnd:=OnEnd;
 if not CreateSuspennded then Resume;
end;

procedure TOpenQueryThread.DoOnEnd;
begin
 if Assigned(FOnEnd) then FOnEnd(nil);
end;

procedure TOpenQueryThread.Execute;
begin
  { Place thread code here }  
 CoInitialize(nil);
 FreeOnTerminate:=true;
 try
  FQuery.Open;
 except
 end;
 Synchronize(DoOnEnd);     
 CoUninitialize;
end;



end.
