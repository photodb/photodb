unit uDBThread;

interface

uses
  Windows, Classes, uTranslate, uAssociations, uMemory, uGOM, SyncObjs, Forms,
  uDBForm, uIME, uTime, SysUtils;

type
  TDBThread = class(TThread)
  private
    FSupportedExt: string;
    FMethod: TThreadMethod;
    FCallResult: Boolean;
    FOwnerForm: TDBForm;
    function GetSupportedExt: string;
    procedure CallMethod;
  protected
    function L(TextToTranslate : string) : string; overload;
    function L(TextToTranslate, Scope : string) : string; overload;
    function GetThreadID: string; virtual;
    function SynchronizeEx(Method: TThreadMethod) : Boolean; virtual;
    property SupportedExt: string read GetSupportedExt;
    property OwnerForm: TDBForm read FOwnerForm;
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TDBForm; CreateSuspended: Boolean);
    destructor Destroy; override;
  end;

  TTDBThreadClass = class of TDBThread;

  TThreadInfo = class
  public
    Thread: TThread;
    Handle: THandle;
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
    function IsThread(Thread: TThread): Boolean;
    function GetThreadHandle(Thread: TThread): THandle;
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

procedure TDBThread.CallMethod;
begin
  FCallResult := GOM.IsObj(FOwnerForm);
  if FCallResult or (FOwnerForm = nil) then
    FMethod
  else
    Terminate;
end;

constructor TDBThread.Create(OwnerForm: TDBForm; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  DBThreadManager.RegisterThread(Self);
  FOwnerForm := OwnerForm;
  GOM.AddObj(Self);
end;

destructor TDBThread.Destroy;
begin
  GOM.RemoveObj(Self);
  DBThreadManager.UnRegisterThread(Self);
  inherited;
end;

procedure TDBThread.Execute;
begin
  DisableIME;
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

function TDBThread.SynchronizeEx(Method: TThreadMethod): Boolean;
begin
  FMethod := Method;
  FCallResult := False;
  Synchronize(CallMethod);
  Result := FCallResult;
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
  I: Integer;
begin
  FSync.Enter;
  try
    Info := TThreadInfo.Create;
    Info.Thread := Thread;
    Info.Handle := Thread.Handle;
    FThreads.Add(Info);

    for I := 0 to FThreads.Count - 1 do
      TW.I.Start('UnRegisterThread: Thread - ' + IntToStr(TThreadInfo(FThreads[I]).Thread.ThreadID) + ' @ = ' + IntToStr(Integer(TThreadInfo(FThreads[I]).Thread)));

  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.UnRegisterThread(Thread: TThread);
var
  I: Integer;
begin
  TW.I.Start('UnRegisterThread: Start - ' + IntToStr(Thread.ThreadID) + ' @ = ' + IntToStr(Integer(Thread)));
  FSync.Enter;
  try
    for I := 0 to FThreads.Count - 1 do
      TW.I.Start('UnRegisterThread: Thread - ' + IntToStr(TThreadInfo(FThreads[I]).Thread.ThreadID) + ' @ = ' + IntToStr(Integer(TThreadInfo(FThreads[I]).Thread)));

    for I := 0 to FThreads.Count - 1 do
    begin
      if TThreadInfo(FThreads[I]).Thread = Thread then
      begin
        TThreadInfo(FThreads[I]).Free;
        FThreads.Delete(I);
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
  TW.I.Start('UnRegisterThread: End - ' + IntToStr(Thread.ThreadID));
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
    CheckSynchronize;

  until (Count = 0) or (GetTickCount - StartTime > MaxTime);

end;

initialization

finalization
  F(FDBThreadManager);

end.
