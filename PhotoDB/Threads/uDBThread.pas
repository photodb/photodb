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
  DBThreadManager.RegisterThread(Self);
  inherited Create(CreateSuspended);
end;

destructor TDBThread.Destroy;
begin
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

procedure TDBThreadManager.RegisterThread(Thread: TDBThread);
begin
  FSync.Enter;
  try
    FThreads.Add(Thread);
  finally
    FSync.Leave;
  end;
end;

procedure TDBThreadManager.UnRegisterThread(Thread: TDBThread);
begin
  FSync.Enter;
  try
    FThreads.Remove(Thread);
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
