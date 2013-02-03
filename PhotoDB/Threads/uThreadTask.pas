unit uThreadTask;

interface

uses
  SysUtils,
  Classes,
  uLogger,
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

  TThreadTask<T> = class(TThreadEx)
  private
    FData: T;
  protected
    procedure Execute; override;
  public
    type
      TTaskThreadProcedureEx = reference to procedure(Thread: TThreadTask<T>; Data: T);
  private
    FProc: TTaskThreadProcedureEx;
  public
    constructor Create(AOwnerForm: TThreadForm; Data: T; Proc: TTaskThreadProcedureEx); overload;
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
  try
    if FDataObj <> nil then
      FProc(Self, FDataObj)
    else
      FProc(Self, Pointer(FDataInterface));
  except
    on e: Exception do
      EventLog(e);
  end;
end;

function TThreadTask.SynchronizeTask(Proc: TThreadProcedure): Boolean;
begin
  Result := SynchronizeEx(Proc);
end;

{ TThreadTask<T> }

constructor TThreadTask<T>.Create(AOwnerForm: TThreadForm; Data: T;
  Proc: TTaskThreadProcedureEx);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FProc := Proc;
  FData := Data;
end;

procedure TThreadTask<T>.Execute;
begin
  FreeOnTerminate := True;
  try
    FProc(Self, FData);
  except
    on e: Exception do
      EventLog(e);
  end;
end;

function TThreadTask<T>.SynchronizeTask(Proc: TThreadProcedure): Boolean;
begin
  Result := SynchronizeEx(Proc);
end;

end.
