unit uMultiCPUThreadManager;

interface

uses
  Windows, Math, SysUtils, uTime, uGOM, uLogger,
  uThreadEx, uThreadForm, Classes, SyncObjs, uMemory;

type
  TMultiCPUThread = class(TThreadEx)
  private
    FMode: Integer;
    FSyncEvent: Integer;
    FWorkingInProgress: Boolean;
    FThreadNumber: Integer;
    procedure DoMultiProcessorWork;
  protected
    procedure DoMultiProcessorTask; virtual; abstract;
    procedure CheckThreadPriority; override;
  public
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID);
    procedure StartMultiThreadWork;
    property Mode: Integer read FMode write FMode;
    property SyncEvent: Integer read FSyncEvent write FSyncEvent;
    property WorkingInProgress: Boolean read FWorkingInProgress write FWorkingInProgress;
  end;

type
  TThreadPoolCustom = class(TObject)
  private
    FAvaliableThreadList: TList;
    FBusyThreadList: TList;
    function GetAvaliableThreadsCount: Integer;
    function GetBusyThreadsCount: Integer;
  protected
    FSync: TCriticalSection;
    procedure ThreadsCheck(Thread: TMultiCPUThread); virtual;
    procedure AddAvaliableThread(Thread: TMultiCPUThread);
  protected
    procedure AddNewThread(Thread: TMultiCPUThread); virtual; abstract;
    function GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
    procedure StartThread(Sender, Thread: TMultiCPUThread);
  public
    constructor Create;
    destructor Destroy; override;
    property AvaliableThreadsCount : Integer read GetAvaliableThreadsCount;
    property BusyThreadsCount : Integer read GetBusyThreadsCount;
  end;

const
  MAX_THREADS_USE = 4;

implementation

uses
  Dolphin_db;

{ TThreadPoolCustom }

procedure TThreadPoolCustom.AddAvaliableThread(Thread: TMultiCPUThread);
begin
  FSync.Enter;
  try
    FAvaliableThreadList.Add(Thread);
    Thread.FThreadNumber := FAvaliableThreadList.Count + FBusyThreadList.Count;
  finally
    FSync.Leave;
  end;
end;

constructor TThreadPoolCustom.Create;
begin
  FAvaliableThreadList := TList.Create;
  FBusyThreadList := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TThreadPoolCustom.Destroy;
var
  I: Integer;
begin
  ThreadsCheck(nil);
  for I := 0 to FAvaliableThreadList.Count - 1 do
  begin
    TMultiCPUThread(FAvaliableThreadList[I]).FMode := 0;
    TMultiCPUThread(FAvaliableThreadList[I]).Priority := tpTimeCritical;
    SetEvent(TMultiCPUThread(FAvaliableThreadList[I]).FSyncEvent);
  end;

  //wait for all threads
  while FAvaliableThreadList.Count > 0 do
  begin
    Sleep(10);
    for I := 0 to FAvaliableThreadList.Count - 1 do
    begin
      if not GOM.IsObj(FAvaliableThreadList[I]) then
      begin
        FAvaliableThreadList.Delete(I);
        Break;
      end;
    end;
  end;

{$IFDEF DBDEBUG}
  //wait for threads - for debug only - memory leaks check
  Sleep(1000);
{$ENDIF}
  F(FSync);
  F(FAvaliableThreadList);
  F(FBusyThreadList);
  inherited;
end;

function TThreadPoolCustom.GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
begin
  Result := nil;

  ThreadsCheck(Sender);

  FSync.Enter;
  try
    if FAvaliableThreadList.Count > 0 then
    begin
      Result := FAvaliableThreadList[0];
      FAvaliableThreadList.Remove(Result);
      FBusyThreadList.Add(Result);
    end;
  finally
    FSync.Leave;
  end;
end;

function TThreadPoolCustom.GetAvaliableThreadsCount: Integer;
begin
  FSync.Enter;
  try
    Result := FAvaliableThreadList.Count;
  finally
    FSync.Leave;
  end;
end;

function TThreadPoolCustom.GetBusyThreadsCount: Integer;
begin
  FSync.Enter;
  try
    Result := FBusyThreadList.Count;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadPoolCustom.StartThread(Sender, Thread: TMultiCPUThread);
begin
  Thread.WorkingInProgress := True;
  Sender.RegisterSubThread(Thread);
  TW.I.Start('Resume thread:' + IntToStr(Thread.ThreadID));
  SetEvent(TMultiCPUThread(Thread).SyncEvent);
end;

procedure TThreadPoolCustom.ThreadsCheck(Thread: TMultiCPUThread);
var
  ThreadHandles: array [0 .. MAX_THREADS_USE - 1] of THandle;
  I, ThreadsCount: Integer;
  S: string;
begin
  AddNewThread(Thread);

  while FAvaliableThreadList.Count = 0 do
  begin
    FSync.Enter;
    try
      ThreadsCount := FBusyThreadList.Count;
      for I := ThreadsCount - 1 downto 0 do
      begin
        if not TMultiCPUThread(FBusyThreadList[I]).FWorkingInProgress then
        begin
          FAvaliableThreadList.Add(FBusyThreadList[I]);
          FBusyThreadList.Delete(I);
        end;
      end;

      if FAvaliableThreadList.Count > 0 then
        Break;

      for I := 0 to ThreadsCount - 1 do
        ThreadHandles[I] := TMultiCPUThread(FBusyThreadList[I]).FEvent;

      S := 'WaitForMultipleObjects: ' + IntToStr(FBusyThreadList.Count) + ' - ';
      for I := 0 to ThreadsCount - 1 do
        S := S + ',' + IntToStr(TMultiCPUThread(FBusyThreadList[I]).FSyncEvent);
      TW.I.Start(S);

    finally
      FSync.Leave;
    end;
    WaitForMultipleObjects(ThreadsCount, @ThreadHandles[0], False, INFINITE);

    TW.I.Start('WaitForMultipleObjects END');
  end;
end;

{ TMultiCPUThread }

procedure TMultiCPUThread.CheckThreadPriority;
begin
  if ThreadForm.Active then
  begin
    if FThreadNumber = 1 then
      Priority := tpNormal
    else
      Priority := tpLowest
  end else
    Priority := tpIdle;
end;

constructor TMultiCPUThread.Create(AOwnerForm: TThreadForm; AState: TGUID);
begin
  inherited Create(AOwnerForm, AState);
  FWorkingInProgress := False;
  FMode := 0;
end;

procedure TMultiCPUThread.DoMultiProcessorWork;
begin
  WorkingInProgress := True;
  while True do
  begin
    IsTerminated := False;
    try
      try
        try
          DoMultiProcessorTask;

          if Mode = 0 then
            Exit;

          TW.I.Start('UnRegisterSubThread: ' + IntToStr(FEvent));
          if (GOM <> nil) and GOM.IsObj(ParentThread) then
            ParentThread.UnRegisterSubThread(Self);
        except
          on E: Exception do
            EventLog('TExplorerThread.ProcessThreadImages' + E.message);
        end;
      finally
        TW.I.Start('SetEvent: ' + IntToStr(FEvent));
        WorkingInProgress := False;
        if Mode > 0 then
          SetEvent(FEvent);
      end;
    finally
      TW.I.Start('Suspended: ' + IntToStr(FEvent));
      if Mode > 0 then
        WaitForSingleObject(FSyncEvent, INFINITE);
      TW.I.Start('Resumed: ' + IntToStr(FEvent));
      WorkingInProgress := True;
    end;
  end;
end;

procedure TMultiCPUThread.StartMultiThreadWork;
begin
  Priority := tpIdle;
  FEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
  FSyncEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
  TW.I.Start('CreateEvent: ' + IntToStr(FEvent));
  try
    DoMultiProcessorWork;
  finally
    CloseHandle(FEvent);
    CloseHandle(FSyncEvent);
    FEvent := 0;
    FSyncEvent := 0;
  end;
end;

end.
