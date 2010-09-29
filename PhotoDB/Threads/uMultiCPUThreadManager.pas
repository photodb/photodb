unit UMultiCPUThreadManager;

interface

uses
  Windows, Math, SysUtils, UTime, UGOM, ULogger,
  UThreadEx, UThreadForm, Classes, SyncObjs, UMemory;

type
  TMultiCPUThread = class(TThreadEx)
  private
    FMode: Integer;
    FSyncEvent: Integer;
    FWorkingInProgress: Boolean;
    procedure DoMultiProcessorWork;
  protected
    procedure DoMultiProcessorTask; virtual; abstract;
  public
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID);
    procedure StartMultiThreadWork;
    property Mode: Integer read FMode write FMode;
    property SyncEvent: Integer read FSyncEvent write FSyncEvent;
    property WorkingInProgress: Boolean read FWorkingInProgress write FWorkingInProgress;
  end;

type
  TThreadPoolCustom = class(TObject)
  protected
    FAvaliableThreadList: TList;
    FBusyThreadList: TList;
    FSync: TCriticalSection;
    procedure ThreadsCheck(Thread: TMultiCPUThread); virtual;
  protected
    procedure AddNewThread(Thread: TMultiCPUThread); virtual; abstract;
    function GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
    procedure StartThread(Sender, Thread: TMultiCPUThread);
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  MAX_THREADS_USE = 4;

implementation

uses
  Dolphin_db;

{ TThreadPoolCustom }

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
    SetEvent(TMultiCPUThread(FAvaliableThreadList[I]).FSyncEvent);
  end;

  F(FSync);
  F(FAvaliableThreadList);
  F(FBusyThreadList);
  inherited;
end;

function TThreadPoolCustom.GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
begin
  Result := nil;

  ThreadsCheck(Sender);

  if FAvaliableThreadList.Count > 0 then
  begin
    Result := FAvaliableThreadList[0];
    FAvaliableThreadList.Remove(Result);
    FBusyThreadList.Add(Result);
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
  I: Integer;
  S: string;
begin
  AddNewThread(Thread);

  while FAvaliableThreadList.Count = 0 do
  begin
    for I := FBusyThreadList.Count - 1 downto 0 do
    begin
      if not TMultiCPUThread(FBusyThreadList[I]).FWorkingInProgress then
      begin
        FAvaliableThreadList.Add(FBusyThreadList[I]);
        FBusyThreadList.Delete(I);
      end;
    end;

    if FAvaliableThreadList.Count > 0 then
      Break;

    for I := 0 to FBusyThreadList.Count - 1 do
      ThreadHandles[I] := TMultiCPUThread(FBusyThreadList[I]).FEvent;

    S := 'WaitForMultipleObjects: ' + IntToStr(FBusyThreadList.Count) + ' - ';
    for I := 0 to FBusyThreadList.Count - 1 do
      S := S + ',' + IntToStr(TMultiCPUThread(FBusyThreadList[I]).FSyncEvent);
    TW.I.Start(S);
    WaitForMultipleObjects(FBusyThreadList.Count, @ThreadHandles[0], False, INFINITE);

    TW.I.Start('WaitForMultipleObjects END');
  end;
end;

{ TMultiCPUThread }

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

          Mode := 0;

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
        SetEvent(FEvent);
      end;
    finally
      TW.I.Start('Suspended: ' + IntToStr(FEvent));
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
  end;
end;

end.
