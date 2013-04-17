unit uActions;

interface

uses
  System.Classes,
  uMemory;

type
  TInstallAction = class;

  TActionCallback = procedure(Sender: TInstallAction; CurrentPoints, Total: Int64; var Terminate: Boolean) of object;

  TInstallAction = class(TObject)
  private
    FIsTerminated: Boolean;
  public
    constructor Create; virtual;
    function CalculateTotalPoints : Int64; virtual; abstract;
    procedure Execute(Callback: TActionCallback); virtual; abstract;
    procedure Terminate;
    property IsTerminated: Boolean read FIsTerminated;
  end;

  TInstallActionClass = class of TInstallAction;

  TInstallManager = class(TObject)
  private
    FInstallScopeList: TList;
    FTotal: Int64;
    FCurrentlyDone : Int64;
    FCalBack: TActionCallback;
    procedure InternalCallback(Sender : TInstallAction; CurrentPoints, Total : int64; var Terminate : Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TInstallManager;
    procedure RegisterScope(Scope : TInstallActionClass);
    function ExecuteInstallActions(Callback : TActionCallback): Boolean;
  end;

implementation

var
  InstallManagerInstance: TInstallManager = nil;

{ TInstallAction }

constructor TInstallAction.Create;
begin
  FIsTerminated := False;
end;

procedure TInstallAction.Terminate;
begin
  FIsTerminated := True;
end;

{ TInstallManager }

constructor TInstallManager.Create;
begin
  FInstallScopeList := TList.Create;
end;

destructor TInstallManager.Destroy;
begin
  FreeList(FInstallScopeList);
  inherited;
end;

function TInstallManager.ExecuteInstallActions(Callback: TActionCallback): Boolean;
var
  I: Integer;
  Action: TInstallAction;
begin
  Result := True;
  FCalBack := Callback;
  FTotal := 0;
  FCurrentlyDone := 0;
  //calculating...
  for I := 0 to FInstallScopeList.Count - 1 do
  begin
    Action := TInstallAction(FInstallScopeList[I]);
    Inc(FTotal, Action.CalculateTotalPoints);
  end;

  //executing...
  for I := 0 to FInstallScopeList.Count - 1 do
  begin
    Action := TInstallAction(FInstallScopeList[I]);
    Action.Execute(InternalCallback);

    if Action.IsTerminated then
      Exit(False);

    Inc(FCurrentlyDone, Action.CalculateTotalPoints);
  end;
end;

procedure TInstallManager.InternalCallback(Sender: TInstallAction; CurrentPoints,
  Total: Int64; var Terminate: Boolean);
begin
  FCalBack(Sender, FCurrentlyDone + CurrentPoints, FTotal, Terminate);
end;

class function TInstallManager.Instance: TInstallManager;
begin
  if InstallManagerInstance = nil then
    InstallManagerInstance := TInstallManager.Create;

  Result := InstallManagerInstance;
end;

procedure TInstallManager.RegisterScope(Scope: TInstallActionClass);
begin
  FInstallScopeList.Add(Scope.Create);
end;

initialization

finalization;

  F(InstallManagerInstance);

end.
