unit uThreadEx;

interface

uses Classes, uThreadForm;

type
  TThreadEx = class(TThread)
  private
    FThreadForm : TThreadForm;
    FState : TGUID;
    FMethod : TThreadMethod;
    FIsTerminated : Boolean;
    function GetIsTerminated: Boolean;
  protected
    procedure SynchronizeEx(Method: TThreadMethod);
    procedure CallMethod;
    procedure Start;
    function CheckForm : Boolean;
    function IsVirtualTerminate : Boolean; virtual;
  public
    constructor Create(AOwnerForm : TThreadForm; AState : TGUID);
    property ThreadForm : TThreadForm read FThreadForm;
    property StateID : TGUID read FState write FState;
    property IsTerminated : Boolean read GetIsTerminated write FIsTerminated;
  end;

implementation

{ TFormThread }

procedure TThreadEx.CallMethod;
begin   
  if CheckForm then
    FMethod
  else
  begin
    if IsVirtualTerminate then
      FIsTerminated := True
    else
      Terminate;
  end;
end;

function TThreadEx.CheckForm: Boolean;
begin
  Result := False;
  if not IsTerminated then
    if FThreadForm.IsActualState(FState) then
      Result := True;
end;

constructor TThreadEx.Create(AOwnerForm: TThreadForm; AState : TGUID);
begin                 
  FThreadForm := AOwnerForm;
  FState := AState;
  inherited Create(False);
end;

function TThreadEx.GetIsTerminated: Boolean;
begin
  if IsVirtualTerminate then
    Result := FIsTerminated
  else
    Result := Terminated;
end;

function TThreadEx.IsVirtualTerminate: Boolean;
begin
  Result := False;
end;

procedure TThreadEx.Start;
begin
  FThreadForm.RegisterThreadAndStart(Self);
end;

procedure TThreadEx.SynchronizeEx(Method: TThreadMethod);
begin
  if not IsTerminated then
  begin
    FMethod := Method;
    Synchronize(CallMethod);
  end;
end;

end.
