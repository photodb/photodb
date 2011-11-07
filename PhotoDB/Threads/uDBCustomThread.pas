unit uDBCustomThread;

interface

uses
  Windows, Classes, SyncObjs, uSysUtils, uMemory;

type
  TDBCustomThread = class(TThread)
  private
    FID: TGUID;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    property UniqID: TGuid read FID;
  end;

  TTDBThreadClass = class of TDBCustomThread;

  TThreadInfo = class
  public
    Thread: TThread;
    Handle: THandle;
    ID: TGUID;
  end;

  TDBThreadManager = class
  private
    FThreads: TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterThread(Thread: TThread);
    procedure UnRegisterThread(Thread: TThread);
    procedure WaitForAllThreads(MaxTime: Cardinal);
    function IsThread(Thread: TThread): Boolean; overload;
    function IsThread(Thread: TGUID): Boolean; overload;
    function GetThreadHandle(Thread: TThread): THandle; overload;
    function GetThreadHandle(Thread: TGUID): THandle; overload;
  end;

  TCustomWaitProc = procedure;

function DBThreadManager: TDBThreadManager;

var
  CustomWaitProc: TCustomWaitProc = nil;

implementation

var
  FDBThreadManager: TDBThreadManager = nil;

function DBThreadManager: TDBThreadManager;
begin
  if FDBThreadManager = nil then
    FDBThreadManager := TDBThreadManager.Create;

  Result := FDBThreadManager;
end;

{ TDBThreadManager }

constructor TDBThreadManager.Create;
begin
  FThreads := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TDBThreadManager.Destroy;
begin
  F(FThreads);
  F(FSync);
  inherited;
end;

function TDBThreadManager.GetThreadHandle(Thread: TGUID): THandle;
var
  I: Integer;
begin
  Result := 0;
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      if SafeIsEqualGUID(TThreadInfo(FThreads[I]).ID, Thread) then
      begin
        Result := TThreadInfo(FThreads[I]).Handle;
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TDBThreadManager.GetThreadHandle(Thread: TThread): THandle;
var
  I: Integer;
begin
  Result := 0;
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      if TThreadInfo(FThreads[I]).Thread = Thread then
      begin
        Result := TThreadInfo(FThreads[I]).Handle;
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TDBThreadManager.IsThread(Thread: TGUID): Boolean;
var
  I: Integer;
begin
  Result := False;
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      if SafeIsEqualGUID(TThreadInfo(FThreads[I]).ID, Thread) then
      begin
        Result := True;
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TDBThreadManager.IsThread(Thread: TThread): Boolean;
var
  I: Integer;
begin
  Result := False;
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      if TThreadInfo(FThreads[I]).Thread = Thread then
      begin
        Result := True;
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.RegisterThread(Thread: TThread);
var
  Info: TThreadInfo;
begin
  FSync.Enter;
  try
    Info := TThreadInfo.Create;
    Info.Thread := Thread;
    Info.Handle := Thread.Handle;
    if Thread is TDBCustomThread then
      Info.ID := TDBCustomThread(Thread).FID
    else
      Info.ID := GetEmptyGUID;

    FThreads.Add(Info);

  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.UnRegisterThread(Thread: TThread);
var
  I: Integer;
begin
  FSync.Enter;
  try
    if Thread is TDBCustomThread then
    begin
      for I := 0 to FThreads.Count - 1 do
      begin
        if SafeIsEqualGUID(TThreadInfo(FThreads[I]).ID, TDBCustomThread(Thread).FID) then
        begin
          TThreadInfo(FThreads[I]).Free;
          FThreads.Delete(I);
          Exit;
        end;
      end;
    end else
    begin
      for I := 0 to FThreads.Count - 1 do
      begin
        if TThreadInfo(FThreads[I]).Thread = Thread then
        begin
          TThreadInfo(FThreads[I]).Free;
          FThreads.Delete(I);
          Exit;
        end;
      end;
    end;

  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.WaitForAllThreads(MaxTime: Cardinal);
var
  Count: Integer;
  StartTime: Cardinal;
begin
  StartTime := GetTickCount;
  repeat
    FSync.Enter;
    try
      Count := FThreads.Count;
    finally
      FSync.Leave;
    end;
    Sleep(1);
    if Assigned(CustomWaitProc) then
      CustomWaitProc;
    CheckSynchronize;

  until (Count = 0) or (GetTickCount - StartTime > MaxTime);

end;

{ TDBCustomThread }

constructor TDBCustomThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FID := SafeCreateGUID;
  DBThreadManager.RegisterThread(Self);
end;

destructor TDBCustomThread.Destroy;
begin
  DBThreadManager.UnRegisterThread(Self);
  inherited;
end;

initialization

finalization
  F(FDBThreadManager);

end.
