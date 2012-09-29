unit uThreadForm;

interface

uses
  System.Types,
  System.Classes,
  System.SyncObjs,
  Vcl.Forms,
  Vcl.Graphics,
  uDBForm,
  uSysUtils,
  uMemory,
  uGUIDUtils;

type
  TThreadForm = class(TDBForm)
  private
    FThreadList: TList;
    FSync: TCriticalSection;
    FStateID: TGUID;
    FSubStateID: TGUID;
    procedure ThreadTerminated(Sender : TObject);
  protected
    procedure TerminateAllThreads;
    procedure NewFormState;
    procedure StateChanged(OldState: TGUID); virtual;
  public
    procedure NewFormSubState;
    procedure RegisterThreadAndStart(Thread: TThread);
    function IsActualState(State: TGUID): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property StateID: TGUID read FStateID;
    property SubStateID: TGUID read FSubStateID;
    function GetImage(FileName: string; Bitmap: TBitmap): Boolean;
  end;

implementation

uses SysUtils, uThreadEx;

constructor TThreadForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSync := TCriticalSection.Create;
  FThreadList := TList.Create;
end;

destructor TThreadForm.Destroy;
begin
  TerminateAllThreads;
  F(FThreadList);
  F(FSync);
  inherited;
end;

function TThreadForm.GetImage(FileName: string; Bitmap: TBitmap): Boolean;
begin
  Result := False;
end;

function TThreadForm.IsActualState(State: TGUID): Boolean;
begin
  //if FStateID equals - good, if not - check substate
  Result := IsEqualGUID(State, FStateID) or IsEqualGUID(State, FSubStateID);
end;

procedure TThreadForm.NewFormState;
var
  OldState: TGUID;
begin
  OldState := FStateID;
  FStateID := GetGUID;
  NewFormSubState;
  StateChanged(OldState);
end;

procedure TThreadForm.NewFormSubState;
begin
  FSubStateID := GetGUID;
end;

procedure TThreadForm.RegisterThreadAndStart(Thread: TThread);
begin
  FSync.Enter;
  try
    Thread.OnTerminate := ThreadTerminated;
    FThreadList.Add(Thread);
  finally
    FSync.Leave;
  end;
end;

procedure TThreadForm.StateChanged(OldState: TGUID);
begin
end;

procedure TThreadForm.TerminateAllThreads;
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := 0 to FThreadList.Count - 1 do
    begin
      TThread(FThreadList[I]).OnTerminate := nil;
      TThreadEx(FThreadList[I]).DoTerminateThread;
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
