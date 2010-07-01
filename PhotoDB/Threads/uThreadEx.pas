unit uThreadEx;

interface

uses Classes, uThreadForm, Windows, SyncObjs, GraphicsBaseTypes;

type
  TThreadEx = class(TThread)
  private
    FThreadForm : TThreadForm;
    FState : TGUID;
    FMethod : TThreadMethod;
    FSubThreads : TList;
    FIsTerminated : Boolean;
    FParentThread : TThreadEx;
    FSync : TCriticalSection;
    function GetIsTerminated: Boolean;
    procedure SetTerminated(const Value: Boolean);
  protected
    procedure SynchronizeEx(Method: TThreadMethod);
    procedure CallMethod;
    procedure Start;
    function CheckForm : Boolean;
    function IsVirtualTerminate : Boolean; virtual;
    procedure WaitForSubThreads;
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
  if CheckForm then
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
    if FThreadForm.IsActualState(FState) then
      Result := True;
end;

constructor TThreadEx.Create(AOwnerForm: TThreadForm; AState : TGUID);
begin
  FSync := TCriticalSection.Create;
  FThreadForm := AOwnerForm;
  FState := AState;
  FSubThreads := TList.Create;
  FParentThread := nil;
  GOM.AddObj(Self);
  inherited Create(False);
end;

destructor TThreadEx.Destroy;
begin
  GOM.RemoveObj(Self);
  Terminate;
  WaitForSubThreads;
  FSubThreads.Free;
  FSync.Free;
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
  FThreadForm.RegisterThreadAndStart(Self);
end;

procedure TThreadEx.SynchronizeEx(Method: TThreadMethod);
begin
  if not IsTerminated then
  begin
    FMethod := Method;
    Synchronize(CallMethod);
  end;
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
