unit uViewerTypes;

interface

uses
  SyncObjs,
  ActiveX,
  uMemory,
  uThreadForm,

  UnitDBDeclare,
  uDBPopupMenuInfo;

type
  TViewerForm = class(TThreadForm)
  private
    FFullScreenNow: Boolean;
    FSlideShowNow: Boolean;
  protected
    function GetItem: TMediaItem; virtual;
  public
    CurrentFileNumber: Integer;
    property FullScreenNow: Boolean read FFullScreenNow write FFullScreenNow;
    property SlideShowNow: Boolean read FSlideShowNow write FSlideShowNow;
  end;

  TViewerManager = class(TObject)
  private
    FSync: TCriticalSection;
    FSID: TGUID;
    FForwardThreadSID: TGUID;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdateViewerState(SID, ForwardThreadSID: TGUID);
    function ValidateState(State: TGUID): Boolean;
  end;

function ViewerManager: TViewerManager;

implementation

var
  FViewerManager: TViewerManager = nil;

function ViewerManager: TViewerManager;
begin
  if FViewerManager = nil then
    FViewerManager := TViewerManager.Create;

  Result := FViewerManager;
end;

{ TViewerForm }

function TViewerForm.GetItem: TMediaItem;
begin
  Result := nil;
end;

{ TViewerManager }

constructor TViewerManager.Create;
begin
  FSync := TCriticalSection.Create;
end;

destructor TViewerManager.Destroy;
begin
  F(FSync);
  inherited;
end;

procedure TViewerManager.UpdateViewerState(SID, ForwardThreadSID: TGUID);
begin
  FSync.Enter;
  try
    FSID := SID;
    FForwardThreadSID := ForwardThreadSID;
  finally
    FSync.Leave;
  end;
end;

function TViewerManager.ValidateState(State: TGUID): Boolean;
begin
  FSync.Enter;
  try
    Result := IsEqualGUID(FSID, State) or IsEqualGUID(State, FForwardThreadSID);
  finally
    FSync.Leave;
  end;
end;

initialization
finalization
  F(FViewerManager);

end.
