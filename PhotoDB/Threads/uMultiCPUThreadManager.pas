unit uMultiCPUThreadManager;

interface

uses
  Windows, Math, SysUtils, Forms, uTime, uGOM, uLogger,
  uThreadEx, uThreadForm, Classes, SyncObjs, uMemory, uSysUtils;

type
  TMultiCPUThread = class(TThreadEx)
  private
    FMode: Integer;
    FSyncEvent: Integer;
    FWorkingInProgress: Boolean;
    FThreadNumber: Integer;
    FOwner: TMultiCPUThread;
    procedure DoMultiProcessorWork;
  protected
    procedure DoMultiProcessorTask; virtual; abstract;
    procedure CheckThreadPriority; override;
  public
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID);
    destructor Destroy; override;
    procedure StartMultiThreadWork;
    property Mode: Integer read FMode write FMode;
    property SyncEvent: Integer read FSyncEvent write FSyncEvent;
    property WorkingInProgress: Boolean read FWorkingInProgress write FWorkingInProgress;
    property Owner: TMultiCPUThread read FOwner write FOwner;
  end;

type
  TThreadPoolCustom = class(TObject)
  private
    FAvaliableThreadList: TList;
    FBusyThreadList: TList;
    FTerminating : Boolean;
    function GetAvaliableThreadsCount: Integer;
    function GetBusyThreadsCount: Integer;
  protected
    FSync: TCriticalSection;
    procedure ThreadsCheck(Thread: TMultiCPUThread); virtual;
    procedure AddAvaliableThread(Thread: TMultiCPUThread);
    procedure CheckBusyThreads;
  protected
    procedure AddNewThread(Thread: TMultiCPUThread); virtual; abstract;
    function GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
    procedure StartThread(Sender, Thread: TMultiCPUThread);
  public
    constructor Create;
    destructor Destroy; override;
    procedure CloseAndWaitForAllThreads;
    function GetBusyThreadsCountForThread(Thread: TMultiCPUThread): Integer;
    property AvaliableThreadsCount : Integer read GetAvaliableThreadsCount;
    property BusyThreadsCount : Integer read GetBusyThreadsCount;
  end;

const
  MAX_THREADS_USE = 4;

var
  MultiThreadManagers : TList = nil;

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
  FTerminating := False;
  MultiThreadManagers.Add(Self);
end;

procedure TThreadPoolCustom.CloseAndWaitForAllThreads;
var
  I: Integer;
  FThreads, FWaitThreads : TList;
begin;
  FTerminating := True;
  FThreads := TList.Create;
  FWaitThreads := TList.Create;
  try
    //wait for all threads
    while FAvaliableThreadList.Count + FBusyThreadList.Count + FWaitThreads.Count > 0 do
    begin
      Sleep(10);
      Application.ProcessMessages;
      FSync.Enter;
      try
        CheckBusyThreads;
        //remove all avaliable thread from pool
        FThreads.Assign(FAvaliableThreadList);
        FAvaliableThreadList.Clear;

        for I := 0 to FThreads.Count - 1 do
        begin
          TMultiCPUThread(FThreads[I]).FMode := 0;
          TMultiCPUThread(FThreads[I]).Priority := tpTimeCritical;
        end;
      finally
        FSync.Leave;
      end;

      //call thread to terminate
      for I := 0 to FThreads.Count - 1 do
        SetEvent(TMultiCPUThread(FThreads[I]).FSyncEvent);

      //add thread to wait list
      for I := 0 to FThreads.Count - 1 do
        FWaitThreads.Add(FThreads[I]);
      FThreads.Clear;

      //wait for all threads using GOM
      for I := 0 to FWaitThreads.Count - 1 do
      begin
        if not GOM.IsObj(FWaitThreads[I]) then
        begin
          FWaitThreads.Delete(I);
          Break;
        end;
      end;
    end;
  finally
    F(FThreads);
    F(FWaitThreads);
  end;
end;

destructor TThreadPoolCustom.Destroy;
begin
  F(FSync);
  F(FAvaliableThreadList);
  F(FBusyThreadList);
  MultiThreadManagers.Remove(Self);
  inherited;
end;

function TThreadPoolCustom.GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
begin
  Result := nil;

  while Result = nil do
  begin
    if FTerminating then
      Exit;

    ThreadsCheck(Sender);

    FSync.Enter;
    try
      if FAvaliableThreadList.Count > 0 then
      begin
        Result := FAvaliableThreadList[0];
        Result.WorkingInProgress := True;
        FAvaliableThreadList.Remove(Result);
        FBusyThreadList.Add(Result);
      end;
    finally
      FSync.Leave;
    end;
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

function TThreadPoolCustom.GetBusyThreadsCountForThread(
  Thread: TMultiCPUThread): Integer;
var
  I : Integer;
begin
  FSync.Enter;
  try
    CheckBusyThreads;
    Result := 0;
    for I := 0 to FBusyThreadList.Count - 1 do
      if TMultiCPUThread(FBusyThreadList[I]).Owner = Thread then
        Inc(Result);
  finally
    FSync.Leave;
  end;
end;

procedure TThreadPoolCustom.StartThread(Sender, Thread: TMultiCPUThread);
begin
  Thread.WorkingInProgress := True;
  Thread.FOwner := Sender;
  Sender.RegisterSubThread(Thread);
  TW.I.Start('Resume thread:' + IntToStr(Thread.ThreadID));
  SetEvent(TMultiCPUThread(Thread).SyncEvent);
end;

procedure TThreadPoolCustom.CheckBusyThreads;
var
  I: Integer;
begin
  for I := FBusyThreadList.Count - 1 downto 0 do
  begin
    if not GOM.IsObj(FBusyThreadList[I]) then
    begin
      FBusyThreadList.Delete(I);
      Continue;
    end;
    if not TMultiCPUThread(FBusyThreadList[I]).FWorkingInProgress then
    begin
      FAvaliableThreadList.Add(FBusyThreadList[I]);
      FBusyThreadList.Delete(I);
    end;
  end;
end;

procedure TThreadPoolCustom.ThreadsCheck(Thread: TMultiCPUThread);
var
  ThreadHandles: array [0 .. MAX_THREADS_USE - 1] of THandle;
  I, ThreadsCount: Integer;
  S: string;
begin
  FSync.Enter;
  try
    AddNewThread(Thread);
  finally
    FSync.Leave;
  end;
  ThreadsCount := 0;
  while FAvaliableThreadList.Count = 0 do
  begin
    FSync.Enter;
    try
      CheckBusyThreads;

      if FAvaliableThreadList.Count > 0 then
        Break;

      ThreadsCount := FBusyThreadList.Count;
      for I := 0 to ThreadsCount - 1 do
        ThreadHandles[I] := TMultiCPUThread(FBusyThreadList[I]).FEvent;

      S := 'WaitForMultipleObjects: ' + IntToStr(FBusyThreadList.Count) + ' - ';
      for I := 0 to ThreadsCount - 1 do
        S := S + ',' + IntToStr(TMultiCPUThread(FBusyThreadList[I]).FSyncEvent);
      TW.I.Start(S);

    finally
      FSync.Leave;
    end;
    if ThreadsCount > 0 then
      WaitForMultipleObjects(ThreadsCount, @ThreadHandles[0], False, 1000);

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
  FSyncEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
  FWorkingInProgress := False;
  FMode := 0;
end;

destructor TMultiCPUThread.Destroy;
begin
  inherited;
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
          if GOM.IsObj(ParentThread) then
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

initialization

 MultiThreadManagers := TList.Create;

finalization

 F(MultiThreadManagers);

end.

