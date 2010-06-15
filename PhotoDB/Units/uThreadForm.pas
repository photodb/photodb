unit uThreadForm;

interface

uses Classes, Forms, SyncObjs;

type
  TThreadForm = class(TForm)
  private
    FThreadList : TList;
    FSync : TCriticalSection;
    procedure ThreadTerminated(Sender : TObject);  
  protected
    procedure RegisterThreadAndStart(Thread : TThread);
    procedure TerminateAllThreads;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TThreadForm.Create(AOwner: TComponent);
begin
  inherited;
  FSync := TCriticalSection.Create;
  FThreadList := TList.Create;
end;

destructor TThreadForm.Destroy;
begin
  TerminateAllThreads;
  FThreadList.Free;
  FSync.Free;
  inherited;
end;

procedure TThreadForm.RegisterThreadAndStart(Thread: TThread);
begin
  FSync.Enter;
  try
    Thread.OnTerminate := ThreadTerminated;
    FThreadList.Add(Thread);
    Thread.Resume;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadForm.TerminateAllThreads;
var
  I : Integer;
begin    
  FSync.Enter;
  try
    for I := 0 to FThreadList.Count - 1 do
    begin
      TThread(FThreadList[i]).OnTerminate := nil;
      TThread(FThreadList[i]).Terminate;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadForm.ThreadTerminated(Sender: TObject);
begin     
  FSync.Enter;
  try
    FThreadList.Remove(Sender);     
  finally
    FSync.Leave;
  end;
end;

end.
