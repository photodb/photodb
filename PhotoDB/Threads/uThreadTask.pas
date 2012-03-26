unit uThreadTask;

interface

uses
  Classes,
  uThreadEx,
  uThreadForm;

type
  TThreadTask = class;

  TTaskThreadProcedure = reference to procedure(Thread: TThreadTask; Data: Pointer);

  TThreadTask = class(TThreadEx)
  private
    FProc: TTaskThreadProcedure;
    FDataObj: TObject;
    FDataInterface: IUnknown;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; Data: Pointer; Proc: TTaskThreadProcedure); overload;
    constructor Create(AOwnerForm: TThreadForm; Data: IUnknown; Proc: TTaskThreadProcedure); overload;
    function SynchronizeTask(Proc: TThreadProcedure): Boolean;
  end;

implementation

{ TThreadTask }

constructor TThreadTask.Create(AOwnerForm: TThreadForm; Data: Pointer; Proc: TTaskThreadProcedure);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FProc := Proc;
  FDataObj := Data;
  FDataInterface := nil;
end;

constructor TThreadTask.Create(AOwnerForm: TThreadForm; Data: IInterface;
  Proc: TTaskThreadProcedure);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FProc := Proc;
  FDataObj := nil;
  FDataInterface := Data;
end;

procedure TThreadTask.Execute;
begin
  FreeOnTerminate := True;
  if FDataObj <> nil then
    FProc(Self, FDataObj)
  else
    FProc(Self, Pointer(FDataInterface));
end;

function TThreadTask.SynchronizeTask(Proc: TThreadProcedure): Boolean;
begin
  Result := SynchronizeEx(Proc);
end;

end.
