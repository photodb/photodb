unit PDB.uVCLRewriters;

interface

uses
  Windows,
  Classes,
  Controls,
  Messages,
  CommCtrl,
  ComCtrls;

type
  TPageControlNoBorder = class(ComCtrls.TPageControl)
  private
    FCanUpdateActivePage: Boolean;
    procedure TCMAdjustRect(var Msg: TMessage); message TCM_ADJUSTRECT;
  protected
    procedure ShowControl(AControl: TControl); override;
    procedure UpdateActivePage; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ShowTab(TabIndex: Integer);
    procedure HideTab(TabIndex: Integer);
    procedure DisableTabChanging;
    procedure EnableTabChanging;
  end;

implementation

{ TPageControlNoBorder }

constructor TPageControlNoBorder.Create(AOwner: TComponent);
begin
  FCanUpdateActivePage := True;
  inherited;
end;

procedure TPageControlNoBorder.DisableTabChanging;
begin
  FCanUpdateActivePage := False;
end;

procedure TPageControlNoBorder.EnableTabChanging;
begin
  FCanUpdateActivePage := True;
end;

procedure TPageControlNoBorder.HideTab(TabIndex: Integer);
begin
  Pages[TabIndex].TabVisible := False;
end;

procedure TPageControlNoBorder.ShowControl(AControl: TControl);
begin
 //do nothing - it preventing from flicking
end;

procedure TPageControlNoBorder.ShowTab(TabIndex: Integer);
begin
  Pages[TabIndex].TabVisible := True;
end;

procedure TPageControlNoBorder.TCMAdjustRect(var Msg: TMessage);
begin
  inherited;
  if Msg.WParam = 0 then
    InflateRect(PRect(Msg.LParam)^, 4, 4)
  else
    InflateRect(PRect(Msg.LParam)^, -4, -4);
end;

procedure TPageControlNoBorder.UpdateActivePage;
begin
  if FCanUpdateActivePage then
    inherited;
end;

end.
