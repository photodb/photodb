unit uThreadEx;

interface

uses Classes, uThreadForm;

type
  TThreadEx = class(TThread)
  private
    FThreadForm : TThreadForm;
    FState : TGUID;
    FMethod : TThreadMethod;
  protected
    procedure SynchronizeEx(Method: TThreadMethod);
    procedure CallMethod;
    procedure Start;
    function CheckForm : Boolean;
  public
    constructor Create(AOwnerForm : TThreadForm; AState : TGUID); 
  end;

implementation

{ TFormThread }

procedure TThreadEx.CallMethod;
begin   
  if CheckForm then
    FMethod
  else
    Terminate;
end;

function TThreadEx.CheckForm: Boolean;
begin
  Result := False;
  if not Terminated then
    if FThreadForm.IsActualState(FState) then
      Result := True;
end;

constructor TThreadEx.Create(AOwnerForm: TThreadForm; AState : TGUID);
begin                 
  FThreadForm := AOwnerForm;
  FState := AState;
  inherited Create(False);
end;

procedure TThreadEx.Start;
begin
  FThreadForm.RegisterThreadAndStart(Self);
end;

procedure TThreadEx.SynchronizeEx(Method: TThreadMethod);
begin
  if not Terminated then
  begin
    FMethod := Method;
    Synchronize(CallMethod);
  end;
end;

end.
