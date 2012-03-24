unit uThreadTask;

interface

uses
  Classes,
  uThreadEx,
  uThreadForm;

type
  TThreadTask = class;

  TTaskThreadProcedure = reference to procedure(Thread: TThreadTask);

  TThreadTask = class(TThreadEx)
  private
    FProc: TTaskThreadProcedure;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; Proc: TTaskThreadProcedure);
    function SynchronizeTask(Proc: TThreadProcedure): Boolean;
  end;

implementation

{ TThreadTask }

constructor TThreadTask.Create(AOwnerForm: TThreadForm; Proc: TTaskThreadProcedure);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FProc := Proc;
end;

procedure TThreadTask.Execute;
begin
  FreeOnTerminate := True;
  FProc(Self);
end;

function TThreadTask.SynchronizeTask(Proc: TThreadProcedure): Boolean;
begin
  Result := SynchronizeEx(Proc);
end;

end.
