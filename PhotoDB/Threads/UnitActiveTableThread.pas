unit UnitActiveTableThread;

interface

uses
  ActiveX, Classes, DB;

type

  TNotifyBoolEvent = procedure(Result: boolean) of object;

type
  TActiveTableThread = class(TThread)
  private
  FTable : TDataSet;
  FActive : boolean;
  FOnEnd : TNotifyBoolEvent;
  ActiveOk : boolean;
    { Private declarations }
  protected
    procedure Execute; override;
  public
   constructor Create(CreateSuspennded: Boolean; Table : TDataSet; Active : boolean; OnEnd : TNotifyBoolEvent);
   procedure DoOnEnd;
  end;

implementation

uses CommonDBSupport;

{ TActiveTableThread }

constructor TActiveTableThread.Create(CreateSuspennded: Boolean;
  Table: TDataSet; Active: boolean; OnEnd: TNotifyBoolEvent);
begin
 inherited Create(True);
 FTable:=Table;
 FActive:=Active;
 FOnEnd:=OnEnd;
 if not CreateSuspennded then Resume;
end;

procedure TActiveTableThread.DoOnEnd;
begin
 if Assigned(FOnEnd) then FOnEnd(ActiveOk);
end;

procedure TActiveTableThread.Execute;
begin
 ActiveOk:=false;
 try
  CoInitialize(nil);
  
  ActiveOk:=ActiveTable(FTable,FActive);

 except
  ActiveOk:=false;
  Synchronize(DoOnEnd);
  exit;
 end;
 ActiveOk:=true;
 Synchronize(DoOnEnd);
end;

end.
