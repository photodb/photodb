unit uDBThread;

interface

uses
  Windows, Classes, uTranslate, uAssociations, uMemory, uGOM, SyncObjs, Forms;

type
  TDBThread = class(TThread)
  private
    FSupportedExt: string;
    function GetSupportedExt: string;
  protected
    function L(TextToTranslate : string) : string; overload;
    function L(TextToTranslate, Scope : string) : string; overload;
    function GetThreadID: string; virtual;
    property SupportedExt: string read GetSupportedExt;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
  end;

  TThreadInfo = class
  public
    Thread: TDBThread;
    Handle: THandle;
  end;

  TDBThreadManager = class
  private
    FThreads: TList;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterThread(Thread: TDBThread);
    procedure UnRegisterThread(Thread: TDBThread);
    procedure WaitForAllThreads(MaxTime: Cardinal);
    function IsThread(Thread: TDBThread): Boolean;
    function GetThreadHandle(Thread: TDBThread): THandle;
  end;

function DBThreadManager: TDBThreadManager;

implementation

var
  FDBThreadManager: TDBThreadManager = nil;

function DBThreadManager: TDBThreadManager;
begin
  if FDBThreadManager = nil then
    FDBThreadManager := TDBThreadManager.Create;

  Result := FDBThreadManager;
end;

{ TThreadEx }

function TDBThread.L(TextToTranslate: string): string;
begin
  Result := TA(TextToTranslate, GetThreadID);
end;

constructor TDBThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  DBThreadManager.RegisterThread(Self);
  GOM.AddObj(Self);
end;

destructor TDBThread.Destroy;
begin
  GOM.RemoveObj(Self);
  DBThreadManager.UnRegisterThread(Self);
  inherited;
end;

function TDBThread.GetSupportedExt: string;
begin
  if FSupportedExt = '' then
    FSupportedExt := TFileAssociations.Instance.ExtensionList;

  Result := FSupportedExt;
end;

function TDBThread.GetThreadID: string;
begin
  Result := ClassName;
end;

function TDBThread.L(TextToTranslate, Scope: string): string;
begin
  Result := TA(TextToTranslate, Scope);
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

function TDBThreadManager.GetThreadHandle(Thread: TDBThread): THandle;
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

function TDBThreadManager.IsThread(Thread: TDBThread): Boolean;
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

procedure TDBThreadManager.RegisterThread(Thread: TDBThread);
var
  Info: TThreadInfo;
begin
  FSync.Enter;
  try
    Info := TThreadInfo.Create;
    Info.Thread := Thread;
    Info.Handle := Thread.Handle;
    FThreads.Add(Info);
  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.UnRegisterThread(Thread: TDBThread);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      if TThreadInfo(FThreads[I]).Thread = Thread then
      begin
        TThreadInfo(FThreads[I]).Free;
        FThreads.Delete(I);
        Break;
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
    Application.ProcessMessages;

  until (Count = 0) or (GetTickCount - StartTime > MaxTime);

end;

initialization

finalization
  F(FDBThreadManager);

end.
