unit UnitExplorerLoadSingleImageThread;

interface

uses
  Classes, uThreadEx, uThreadForm;

type
  TExplorerLoadSingleImageThread = class(TThreadEx)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm : TThreadForm; AState : TGUID);
  end;

implementation

{ TExplorerLoadSIngieImageThread }

constructor TExplorerLoadSingleImageThread.Create(AOwnerForm: TThreadForm;
  AState: TGUID);
begin
  inherited Create(AOwnerForm, AState);

end;

procedure TExplorerLoadSingleImageThread.Execute;
begin
  { Place thread code here }
end;

end.
 