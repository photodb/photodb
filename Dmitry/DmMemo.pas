unit DmMemo;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  TDmMemo = class(TMemo)
  private
    { Private declarations }
    FTransparentMouse: Boolean;
    procedure Wm_mousedown(var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure Wm__mousedown(var Msg: TMessage); message WM_RBUTTONDOWN;
    procedure Wm_mouseUp(var Msg: TMessage); message WM_RBUTTONUP;
    procedure Wm__mouseUp(var Msg: TMessage); message WM_LBUTTONUP;
    procedure Wm_butondblclick(var Msg: TMessage); message WM_LBUTTONDBLCLK;
    procedure SetTransparentMouse(const Value: Boolean);
  public
    { Protected declarations }
    constructor Create(AOwner: TComponent); override;
  public
    { Public declarations }
  published
    { Published declarations }
    property TransparentMouse: Boolean read FTransparentMouse write SetTransparentMouse;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Dm', [TDmMemo]);
end;

{ TDmMemo }

constructor TDmMemo.Create(AOwner: TComponent);
begin
  inherited;
  TransparentMouse := False;
end;

procedure TDmMemo.SetTransparentMouse(const Value: Boolean);
begin
  FTransparentMouse := Value;
end;

procedure TDmMemo.Wm_butondblclick(var Msg: Tmessage);
begin
  if TransparentMouse then
    (Owner as TWincontrol).Perform(WM_LBUTTONDBLCLK, Msg.Wparam, Msg.Lparam);
end;

procedure TDmMemo.Wm_mousedown(var Msg: Tmessage);
begin
  if TransparentMouse then
    (Owner as TWincontrol).Perform(Wm_lbuttondown, Msg.Wparam, Msg.Lparam);
end;

procedure TDmMemo.Wm_mouseUp(var Msg: Tmessage);
begin
  Screen.Cursor := crDefault;
  if TransparentMouse then
    (Owner as TWincontrol).Perform(Wm_lbuttonUp, Msg.Wparam, Msg.Lparam);
end;

procedure TDmMemo.Wm__mousedown(var Msg: Tmessage);
begin
  if TransparentMouse then
    (Owner as TWincontrol).Perform(Wm_rbuttondown, Msg.Wparam, Msg.Lparam);
end;

procedure TDmMemo.Wm__mouseUp(var Msg: Tmessage);
begin
  Screen.Cursor := crDefault;
  if TransparentMouse then
    (Owner as TWincontrol).Perform(Wm_RbuttonUp, Msg.Wparam, Msg.Lparam);
end;

end.


