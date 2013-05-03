unit uThreadTask;

interface

uses
  SysUtils,
  Classes,

  uRuntime,
  uLogger,
  uGOM,
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
    FCheckStateID: Boolean;
  protected
    procedure Execute; override;
  public
    type
      TTaskThreadProcedureEx = reference to procedure(Thread: TThreadTask<T>; Data: T);
  private
    FProc: TTaskThreadProcedureEx;
  public
    constructor Create(AOwnerForm: TThreadForm; Data: T; CheckStateID: Boolean; Proc: TTaskThreadProcedureEx); overload;
    function SynchronizeTask(Proc: TThreadProcedure): Boolean;
    function CheckForm: Boolean; override;
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
  inherited;
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

function TThreadTask<T>.CheckForm: Boolean;
begin
  if FCheckStateID then
    Result := inherited CheckForm
  else
    Result := GOM.IsObj(ThreadForm) and not IsTerminated {$IFNDEF EXTERNAL}and not DBTerminating{$ENDIF};
end;

constructor TThreadTask<T>.Create(AOwnerForm: TThreadForm; Data: T; CheckStateID: Boolean;
  Proc: TTaskThreadProcedureEx);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FProc := Proc;
  FData := Data;
  FCheckStateID := CheckStateID;
end;

procedure TThreadTask<T>.Execute;
begin
  inherited;
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
