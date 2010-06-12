unit SlideShowFullScreen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AppEvnts, ImgList, ComCtrls, ToolWin, dolphin_db;

type
  TFullScreenView = class(TForm)
    MouseTimer: TTimer;
    ApplicationEvents1: TApplicationEvents;
    DestroyTimer: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Execute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseTimerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
   procedure HideMouse;
   procedure ShowMouse;
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
  private
  
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FullScreenView: TFullScreenView;
  OldPoint : TPoint;

implementation


uses SlideShow, FloatPanelFullScreen,DDraw;

{$R *.dfm}

procedure TFullScreenView.FormPaint(Sender: TObject);
begin
 Canvas.Draw(0,0,DrawImage);
end;

procedure TFullScreenView.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#27 then
  if Viewer<>nil then
  Viewer.Exit1Click(Sender);
end;

procedure TFullScreenView.Execute(Sender: TObject);
begin
  Show;
  FloatPanel.Show;
  MouseTimer.Enabled:=false;
  MouseTimer.Enabled:=true;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, nil, 0);
end;

procedure TFullScreenView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ShowMouse;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);
  DestroyTimer.Enabled:=true;
end;

procedure TFullScreenView.FormDeactivate(Sender: TObject);
begin
  ShowMouse;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);
end;

procedure TFullScreenView.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Showmouse;
  MouseTimer.Enabled:=false;
  MouseTimer.Enabled:=true;
end;

procedure TFullScreenView.MouseTimerTimer(Sender: TObject);
var
  p : TPoint;
begin
 if Visible then
 begin
  GetCursorPos(p);
  if FloatPanel=nil then exit;
  p:=FloatPanel.ScreenToClient(p);
  if PtInRect(FloatPanel.ClientRect,p) then exit;
  HideMouse;
 end;
end;

procedure TFullScreenView.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin          
  MouseTimer.Enabled:=true;
  if (abs(OldPoint.X-x)>5) or (abs(OldPoint.X-x)>5) then
  begin
   ShowMouse;
   OldPoint:=Point(x,y);
   MouseTimer.Enabled:=false;
   MouseTimer.Enabled:=true;
  end;
end;

procedure TFullScreenView.FormContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  ShowMouse;
  MouseTimer.Enabled:=false;
  if Viewer<>nil then
  begin
   Viewer.PopupMenu1.Popup(ClientToScreen(MousePos).X,ClientToScreen(MousePos).y);
  end;
end;

procedure TFullScreenView.FormClick(Sender: TObject);
begin
  if Viewer<>nil then
  Viewer.Next_(Sender);
end;

procedure TFullScreenView.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Enabled:=false;
  MouseTimer.Enabled:=true;
end;

procedure TFullScreenView.HideMouse;
var
  CState: Integer;
begin
  CState := ShowCursor(True);
  while Cstate >= 0 do
    Cstate := ShowCursor(False);
  if FloatPanel<>nil then
  FloatPanel.Hide;
end;

procedure TFullScreenView.ShowMouse;
var
  Cstate: Integer;
begin
  Cstate := ShowCursor(True);
  while CState < 0 do
    CState := ShowCursor(True);
  if FullScreenNow then
  if FloatPanel<>nil then
  FloatPanel.Show;
end;

procedure TFullScreenView.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if FullScreenNow then
 if Msg.message=260 then Msg.message:=0;
 if FullScreenNow then
 if Msg.message=256 then
 begin
  if Msg.wParam=37 then if Viewer<>nil then Viewer.Previous_(nil);
  if Msg.wParam=39 then if Viewer<>nil then Viewer.Next_(nil);     
  if Msg.wParam=32 then if Viewer<>nil then Viewer.Next_(nil);
  if Msg.wParam=27 then if Viewer<>nil then Viewer.Exit1Click(nil);
  if (Msg.wParam=VK_F4) then
  if AltKeyDown then Msg.wParam:=29;

  if (Msg.wParam=13) and CtrlKeyDown then
  if Viewer<>nil then
  Viewer.Exit1Click(nil);

  Msg.message:=0;
 end;
 if Msg.message<>522 then exit;
 if FullScreenNow then
 if Msg.wParam>0 then
 begin
  if Viewer<>nil then Viewer.Previous_(nil);
 end else
 begin
  if Viewer<>nil then Viewer.Next_(nil);
 end;
end;

procedure TFullScreenView.FormResize(Sender: TObject);
begin
 if FloatPanel<>nil then
 begin
  FloatPanel.Top:=0;
  FloatPanel.Left:=ClientWidth-FloatPanel.Width;
 end;
end;

procedure TFullScreenView.FormCreate(Sender: TObject);
begin
  if FloatPanel=nil then
  Application.CreateForm(TFloatPanel, FloatPanel);
  FloatPanel.Show;
end;

procedure TFullScreenView.FormDestroy(Sender: TObject);
begin
{ FloatPanel.Release;
 FloatPanel.Free;
 FloatPanel:=nil;  }
end;

procedure TFullScreenView.DestroyTimerTimer(Sender: TObject);
begin
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
 FullScreenView:=nil;
end;

initialization

FullScreenView:=nil;
FloatPanel:=nil;

end.
