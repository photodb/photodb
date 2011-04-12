unit UnitActiveTableThread;

interface

uses
  ActiveX, Classes, DB, uDBThread;

type
  TNotifyBoolEvent = procedure(Result: boolean) of object;

  TActiveTableThread = class(TDBThread)
  private
    { Private declarations }
    FTable: TDataSet;
    FActive: Boolean;
    FOnEnd: TNotifyBoolEvent;
    ActiveOk: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(Table: TDataSet; Active: Boolean; OnEnd: TNotifyBoolEvent);
    procedure DoOnEnd;
  end;

implementation

uses CommonDBSupport;

{ TActiveTableThread }

constructor TActiveTableThread.Create(
  Table: TDataSet; Active: boolean; OnEnd: TNotifyBoolEvent);
begin
  inherited Create(False);
  FTable := Table;
  FActive := Active;
  FOnEnd := OnEnd;
end;

procedure TActiveTableThread.DoOnEnd;
begin
  if Assigned(FOnEnd) then
    FOnEnd(ActiveOk);
end;

procedure TActiveTableThread.Execute;
begin
  ActiveOk := False;
  CoInitialize(nil);
  try
    try
      ActiveOk := ActiveTable(FTable, FActive);
    except
      ActiveOk := False;
      Exit;
    end;
    ActiveOk := True;
  finally
    Synchronize(DoOnEnd);
    CoUninitialize;
  end;
end;

end.
