unit SlideShowFullScreen;

interface

uses
  System.Types,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.ComCtrls,

  Dmitry.Utils.System,

  uWinApi,
  uFormInterfaces;

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
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseTimerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HideMouse;
    procedure ShowMouse;
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DestroyTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FOldPoint: TPoint;
  protected
    { Protected declarations }
  public
    { Public declarations }
  end;

var
  FullScreenView: TFullScreenView;

implementation

uses
  FloatPanelFullScreen;

{$R *.dfm}

procedure TFullScreenView.FormPaint(Sender: TObject);
begin
  Viewer.DrawTo(Canvas, 0, 0);
end;

procedure TFullScreenView.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
    Viewer.CloseActiveView;
end;

procedure TFullScreenView.Execute(Sender: TObject);
begin
  Show;
  FloatPanel.Show;
  MouseTimer.Enabled := False;
  MouseTimer.Enabled := True;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, nil, 0);
end;

procedure TFullScreenView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ShowMouse;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);
  DestroyTimer.Enabled := True;
end;

procedure TFullScreenView.FormDeactivate(Sender: TObject);
begin
  ShowMouse;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);
end;

procedure TFullScreenView.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Enabled := False;
  MouseTimer.Enabled := True;
end;

procedure TFullScreenView.MouseTimerTimer(Sender: TObject);
var
  P: TPoint;
begin
  if Visible then
  begin
    GetCursorPos(P);
    if FloatPanel = nil then
      Exit;
    P := FloatPanel.ScreenToClient(P);
    if PtInRect(FloatPanel.ClientRect, P) then
      Exit;
    HideMouse;
  end;
end;

procedure TFullScreenView.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseTimer.Enabled := True;
  if (Abs(FOldPoint.X - X) > 5) or (Abs(FOldPoint.X - X) > 5) then
  begin
    ShowMouse;
    FOldPoint := Point(X, Y);
    MouseTimer.Enabled := False;
    MouseTimer.Enabled := True;
  end;
end;

procedure TFullScreenView.FormContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  ShowMouse;
  MouseTimer.Enabled := False;
  Viewer.ShowPopup(ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y);
end;

procedure TFullScreenView.FormClick(Sender: TObject);
begin
  Viewer.NextImage;
end;

procedure TFullScreenView.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Enabled := False;
  MouseTimer.Enabled := True;
end;

procedure TFullScreenView.HideMouse;
var
  CState: Integer;
begin
  CState := ShowCursor(True);
  while Cstate >= 0 do
    Cstate := ShowCursor(False);
  if FloatPanel <> nil then
    FloatPanel.Hide;
end;

procedure TFullScreenView.ShowMouse;
var
  Cstate: Integer;
begin
  Cstate := ShowCursor(True);
  while CState < 0 do
    CState := ShowCursor(True);
  if Viewer.IsFullScreenNow then
    if FloatPanel <> nil then
      FloatPanel.Show;
end;

procedure TFullScreenView.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);

  function CanProcessMessage: Boolean;
  var
    P: TPoint;
  begin
    GetCursorPos(P);
    Result := Active or PtInRect(BoundsRect, P);
  end;

begin
  if not Visible then
    Exit;

  if Viewer.IsFullScreenNow and CanProcessMessage then
    if Msg.message = WM_SYSKEYDOWN then
      Msg.message := 0;

  if Viewer.IsFullScreenNow and CanProcessMessage then
    if Msg.message = WM_KEYDOWN then
    begin
      if Msg.WParam = VK_LEFT then
        Viewer.PreviousImage;

      if Msg.WParam = VK_RIGHT then
        Viewer.NextImage;

      if Msg.WParam = VK_SPACE then
        Viewer.NextImage;

      if Msg.WParam = VK_ESCAPE then
        Viewer.CloseActiveView;

      if (Msg.WParam = VK_F4) then
        if AltKeyDown then
          Msg.WParam := 29;

      if (Msg.WParam = VK_RETURN) then
        Viewer.CloseActiveView;

      Msg.message := 0;
    end;

  if (Msg.message = WM_MOUSEWHEEL) and CanProcessMessage then
  begin
    if Viewer.IsFullScreenNow then
      if NativeInt(Msg.WParam) > 0 then
        Viewer.PreviousImage
      else
        Viewer.NextImage;

    Handled := True;
  end;
end;

procedure TFullScreenView.FormResize(Sender: TObject);
begin
  if FloatPanel <> nil then
  begin
    FloatPanel.Top := 0;
    FloatPanel.Left := Left + ClientWidth - FloatPanel.Width;
  end;
end;

procedure TFullScreenView.FormCreate(Sender: TObject);
begin
  if FloatPanel = nil then
    Application.CreateForm(TFloatPanel, FloatPanel);
  FloatPanel.Show;

  DisableSleep;
end;

procedure TFullScreenView.FormDestroy(Sender: TObject);
begin
  EnableSleep;
end;

procedure TFullScreenView.DestroyTimerTimer(Sender: TObject);
begin
  DestroyTimer.Enabled := False;
  Release;
  FullScreenView := nil;
end;

initialization

  FullScreenView := nil;
  FloatPanel := nil;

end.
