unit uThreadEx;

interface

uses
  System.Types,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Winapi.Windows,
  uMemory,
  uDBThread,
  uGOM,
  {$IFNDEF EXTERNAL}
  uRuntime,
  {$ENDIF}
  uThreadForm;

type
  TThreadExNotify = procedure(Sender: TObject; StateID: TGUID) of object;

  TThreadEx = class(TDBThread)
  private
    FThreadForm: TThreadForm;
    FState: TGUID;
    FMethod: TThreadMethod;
    FProcedure: TThreadProcedure;
    FSubThreads: TList;
    FIsTerminated: Boolean;
    FParentThread: TThreadEx;
    FSync: TCriticalSection;
    FSyncSuccessful: Boolean;
    FPriority: TThreadPriority;
    function GetIsTerminated: Boolean;
    procedure SetTerminated(const Value: Boolean);
    procedure TestMethod;
  protected
    function SynchronizeEx(Method: TThreadMethod): Boolean; override;
    function SynchronizeEx(Proc: TThreadProcedure): Boolean; override;
    procedure CallMethod;
    procedure CallProcedure;
    procedure Start;
    function IsVirtualTerminate: Boolean; virtual;
    procedure WaitForSubThreads;
    procedure CheckThreadPriority; virtual;
    function CheckThread: Boolean;
  public
    FEvent: THandle;
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID);
    destructor Destroy; override;
    function CheckForm: Boolean; virtual;
    procedure RegisterSubThread(SubThread: TThreadEx);
    procedure UnRegisterSubThread(SubThread: TThreadEx);
    procedure DoTerminateThread;
    property ThreadForm: TThreadForm read FThreadForm write FThreadForm;
    property StateID: TGUID read FState write FState;
    property IsTerminated: Boolean read GetIsTerminated write SetTerminated;
    property ParentThread: TThreadEx read FParentThread;
    property Terminated;
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

procedure TThreadEx.CallProcedure;
begin
  FSyncSuccessful := CheckForm;
  if FSyncSuccessful then
    FProcedure
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
  if GOM.IsObj(FThreadForm) and not IsTerminated {$IFNDEF EXTERNAL}and not DBTerminating{$ENDIF} then
  begin
    if FThreadForm.IsActualState(FState) then
      Result := True;

    CheckThreadPriority;
  end;
end;

function TThreadEx.CheckThread: Boolean;
begin
  Result := SynchronizeEx(TestMethod);
end;

procedure TThreadEx.CheckThreadPriority;
var
  NewPriority: TThreadPriority;
begin
  if FThreadForm.Active then
    NewPriority := tpLowest
  else
    NewPriority := tpIdle;

  if FPriority <> NewPriority then
  begin
    FPriority := NewPriority;
    Priority := NewPriority;
  end;
end;

constructor TThreadEx.Create(AOwnerForm: TThreadForm; AState: TGUID);
begin
  inherited Create(AOwnerForm, False);
  FIsTerminated := False;
  FSync := TCriticalSection.Create;
  FThreadForm := AOwnerForm;
  FState := AState;
  FSubThreads := TList.Create;
  FParentThread := nil;
  FPriority := tpNormal;
end;

destructor TThreadEx.Destroy;
begin
  Terminate;
  WaitForSubThreads;
  F(FSubThreads);
  F(FSync);
  inherited;
end;

procedure TThreadEx.DoTerminateThread;
var
  I: Integer;
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
    if SubThread = Self then
      raise Exception.Create('SubThread and Self are equal');
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
end;

function TThreadEx.SynchronizeEx(Proc: TThreadProcedure): Boolean;
begin
  Result := False;
  if not IsTerminated then
  begin
    FProcedure := Proc;
    Synchronize(CallProcedure);
    Result := FSyncSuccessful;
  end;
end;

function TThreadEx.SynchronizeEx(Method: TThreadMethod): Boolean;
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
  I: Integer;
  Count: Integer;
  ThreadHandles: array [0 .. MAX - 1] of THandle;
begin
  while True do
  begin
    FSync.Enter;
    try
      for I := FSubThreads.Count - 1 downto 0 do
        if not GOM.IsObj(FSubThreads[I]) then
          FSubThreads.Delete(I);

      Count := FSubThreads.Count;
      for I := 0 to Count - 1 do
        ThreadHandles[I] := TThreadEx(FSubThreads[I]).FEvent;
    finally
      FSync.Leave;
    end;
    if Count > 0 then
      WaitForMultipleObjects(Count, @ThreadHandles[0], True, 1000)
    else
      Break;
  end;
end;

end.

