unit uThreadForm;

interface

uses Classes, Forms;

type
  TThreadForm = class(TForm)
  private
    FThreadList : TList;
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
  FThreadList := TList.Create;
end;

destructor TThreadForm.Destroy;
begin
  TerminateAllThreads;
  FThreadList.Free;
  inherited;
end;

procedure TThreadForm.RegisterThreadAndStart(Thread: TThread);
begin
  Thread.OnTerminate := ThreadTerminated;
  FThreadList.Add(Thread);
  Thread.Resume;
end;

procedure TThreadForm.TerminateAllThreads;
var
  I : Integer;
begin
  for I := 0 to FThreadList.Count - 1 do
  begin
    TThread(FThreadList[i]).OnTerminate := nil;
    TThread(FThreadList[i]).Terminate;
  end;
end;

procedure TThreadForm.ThreadTerminated(Sender: TObject);
begin
  FThreadList.Remove(Sender);
end;

end.
