unit uThreadEx;

interface

uses Classes, uThreadForm, Windows, SyncObjs, uDBThread, uGOM;

type
  TThreadExNotify = procedure(Sender: TObject; StateID: TGUID) of object;

  TThreadEx = class(TDBThread)
  private
    FThreadForm : TThreadForm;
    FState : TGUID;
    FMethod : TThreadMethod;
    FSubThreads : TList;
    FIsTerminated : Boolean;
    FParentThread : TThreadEx;
    FSync : TCriticalSection;
    FSyncSuccessful : Boolean;
    function GetIsTerminated: Boolean;
    procedure SetTerminated(const Value: Boolean);
    procedure TestMethod;
  protected
    function SynchronizeEx(Method: TThreadMethod) : Boolean;
    procedure CallMethod;
    procedure Start;
    function CheckForm : Boolean; virtual;
    function IsVirtualTerminate : Boolean; virtual;
    procedure WaitForSubThreads;
    procedure CheckThreadPriority; virtual;
    function CheckThread : Boolean;
  public
    FEvent : THandle;
    constructor Create(AOwnerForm : TThreadForm; AState : TGUID);
    destructor Destroy; override;
    procedure RegisterSubThread(SubThread : TThreadEx);  
    procedure UnRegisterSubThread(SubThread : TThreadEx);
    procedure DoTerminate;
    property ThreadForm : TThreadForm read FThreadForm write FThreadForm;
    property StateID : TGUID read FState write FState;
    property IsTerminated : Boolean read GetIsTerminated write SetTerminated;
    property ParentThread : TThreadEx read FParentThread;
  end;

implementation

{ TFormThread }

procedure TThreadEx.CallMethod;
begin
  FSyncSuccessful := CheckForm;
  if FSyncSuccessful then
    FMethod
  else
  begin
    if IsVirtualTerminate then
      FIsTerminated := True
    else
      Terminate;
  end;
end;

function TThreadEx.CheckForm: Boolean;
begin
  Result := False;
  if not IsTerminated then
  begin
    if FThreadForm.IsActualState(FState) then
      Result := True;

    CheckThreadPriority;
  end;
end;

function TThreadEx.CheckThread : Boolean;
begin
  Result := SynchronizeEx(TestMethod);
end;

procedure TThreadEx.CheckThreadPriority;
begin
  if FThreadForm.Active then
    Priority := tpLowest
  else
    Priority := tpIdle;
end;

constructor TThreadEx.Create(AOwnerForm: TThreadForm; AState : TGUID);
begin
  inherited Create(False);
  FSync := TCriticalSection.Create;
  FThreadForm := AOwnerForm;
  FState := AState;
  FSubThreads := TList.Create;
  FParentThread := nil;
  GOM.AddObj(Self);
end;

destructor TThreadEx.Destroy;
begin
  Terminate;
  WaitForSubThreads;
  FSubThreads.Free;
  FSync.Free;
  GOM.RemoveObj(Self);
  inherited;
end;

procedure TThreadEx.DoTerminate;
var
  I : Integer;
begin
  for I := 0 to FSubThreads.Count - 1 do
    TThreadEx(FSubThreads[I]).IsTerminated := True;
  IsTerminated := True;
end;

function TThreadEx.GetIsTerminated: Boolean;
begin
  if IsVirtualTerminate then
    Result := FIsTerminated
  else
    Result := Terminated;
end;

function TThreadEx.IsVirtualTerminate: Boolean;
begin
  Result := False;
end;

procedure TThreadEx.RegisterSubThread(SubThread: TThreadEx);
begin       
  FSync.Enter;
  try
    SubThread.FParentThread := Self;
    if FSubThreads.IndexOf(SubThread) = -1 then
      FSubThreads.Add(SubThread);
  finally
    FSync.Leave;
  end;
end;

procedure TThreadEx.SetTerminated(const Value: Boolean);
begin
  if IsVirtualTerminate then
    FIsTerminated := Value
  else if Value then
    Terminate;
end;

procedure TThreadEx.Start;
begin
  if GOM.IsObj(FThreadForm) then
    FThreadForm.RegisterThreadAndStart(Self)
  else
    inherited Start;
end;

function TThreadEx.SynchronizeEx(Method: TThreadMethod) : Boolean;
begin
  Result := False;
  if not IsTerminated then
  begin
    FMethod := Method;
    Synchronize(CallMethod);
    Result := FSyncSuccessful;
  end;
end;

procedure TThreadEx.TestMethod;
begin
  //do nothing
end;

procedure TThreadEx.UnRegisterSubThread(SubThread: TThreadEx);
begin
  if Terminated then
    Exit;
  FSync.Enter;
  try
    SubThread.FParentThread := nil;
    FSubThreads.Remove(SubThread);
  finally
    FSync.Leave;
  end;
end;

procedure TThreadEx.WaitForSubThreads;
const
  MAX = 64;
var        
  I : Integer;
  Count : Integer;
  ThreadHandles : array[0 .. MAX - 1] of THandle;
begin  
  FSync.Enter;
  try
    Count := FSubThreads.Count;
    for I := 0 to Count - 1 do
      ThreadHandles[I] := TThreadEx(FSubThreads[I]).FEvent;
  finally
    FSync.Leave;
  end;
  if Count > 0 then
    WaitForMultipleObjects(Count, @ThreadHandles[0], True, INFINITE);
end;

end.
