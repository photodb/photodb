unit UnitImHint;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.Themes,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.ImgList,

  DBCMenu,

  Dmitry.Utils.System,
  Dmitry.Graphics.Utils,
  Dmitry.Controls.ImButton,

  DropSource,
  DropTarget,
  GIFImage,
  DragDropFile,
  DragDrop,
  UnitHintCeator,
  UnitDBDeclare,
  UnitDBKernel,

  uConstants,
  uMemory,
  uBitmapUtils,
  uDBForm,
  uListViewUtils,
  uGOM,
  uDBDrawing,
  uGraphicUtils,
  uFormUtils,
  uDBIcons,
  uDBContext,
  uDBEntities,
  uAnimationHelper,
  uThemesUtils,
  uTranslateUtils,
  uRuntime;

const
  ThHintSize = 400;

type
  TImHint = class(TDBForm)
    TimerShow: TTimer;
    TimerHide: TTimer;
    TimerHintCheck: TTimer;
    ApplicationEvents1: TApplicationEvents;
    DropFileSourceMain: TDropFileSource;
    DragImageList: TImageList;
    DropFileTargetMain: TDropFileTarget;
    ImageFrameTimer: TTimer;
    function Execute(Sender: TForm; G: TGraphic; W, H: Integer; Info: TMediaItem; Pos: TPoint;
      CheckFunction: THintCheckFunction): Boolean;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure WMActivateApp(var Msg: TMessage); message WM_ACTIVATEAPP;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TimerShowTimer(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure TimerHintCheckTimer(Sender: TObject);
    procedure LbSizeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure ImageFrameTimerTimer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
    AnimatedImage: TGraphic;
    SlideNO: Integer;
    AnimatedBuffer: TBitmap;
    ImageBuffer: TBitmap;
    CanClosed: Boolean;
    FFormBuffer: TBitmap;
    CurrentInfo: TMediaItem;
    FDragDrop: Boolean;
    FOwner: TForm;
    GoIn: Boolean;
    FCheckFunction: THintCheckFunction;
    FClosed: Boolean;
    FWidth: Integer;
    FHeight: Integer;
    FAlphaBlend: Byte;
    FInternalClose: Boolean;
    procedure CreateFormImage;
    function GetImageName: string;
  protected
    function GetFormID: string; override;
    property ImageName: string read GetImageName;
  public
    { Public declarations }
  end;

implementation

uses
  FormManegerUnit;

{$R *.dfm}

{ TImHint }

procedure DrawHintInfo(Bitmap: TBitmap; Width, Height: Integer; FInfo: TMediaItem);
var
  Sm, Y: Integer;
  RotationNotInDB: Boolean;

  procedure DoDrawIcon(X, Y: Integer; ImageIndex: Integer; Grayscale: Boolean = False);
  begin
    if not Grayscale then
      DrawIconEx(Bitmap.Canvas.Handle, X, Y, Icons[ImageIndex], 16, 16, 0, 0, DI_NORMAL)
    else
      Icons.IconsEx[ImageIndex].GrayIcon.DoDraw(X, Y, Bitmap);
  end;

begin
  Y := Height - 18;
  Sm := Width - 2;
  if (Width < 80) or (Height < 60) then
    Exit;
  if FInfo.Access = Db_access_private then
  begin
    Dec(Sm, 20);
    DoDrawIcon(Sm, Y, DB_IC_PRIVATE);
  end;
  Dec(Sm, 20);

  RotationNotInDB := (FInfo.ID = 0) and (FInfo.Rotation and DB_IMAGE_ROTATE_NO_DB > 0);
  case FInfo.Rotation and DB_IMAGE_ROTATE_MASK of
    DB_IMAGE_ROTATE_90:
      DoDrawIcon(Sm, Y, DB_IC_ROTATED_90, RotationNotInDB);
    DB_IMAGE_ROTATE_180:
      DoDrawIcon(Sm, Y, DB_IC_ROTATED_180, RotationNotInDB);
    DB_IMAGE_ROTATE_270:
      DoDrawIcon(Sm, Y, DB_IC_ROTATED_270, RotationNotInDB);
    else
      Inc(Sm, 20);
  end;
  Dec(Sm, 20);
  case FInfo.Rating of
    1: DoDrawIcon(Sm, Y, DB_IC_RATING_1);
    2: DoDrawIcon(Sm, Y, DB_IC_RATING_2);
    3: DoDrawIcon(Sm, Y, DB_IC_RATING_3);
    4: DoDrawIcon(Sm, Y, DB_IC_RATING_4);
    5: DoDrawIcon(Sm, Y, DB_IC_RATING_5);
    -10: DoDrawIcon(Sm, Y, DB_IC_RATING_1, True);
    -20: DoDrawIcon(Sm, Y, DB_IC_RATING_2, True);
    -30: DoDrawIcon(Sm, Y, DB_IC_RATING_3, True);
    -40: DoDrawIcon(Sm, Y, DB_IC_RATING_4, True);
    -50: DoDrawIcon(Sm, Y, DB_IC_RATING_5, True);
  else
    Inc(Sm, 20);
  end;
  if FInfo.Encrypted then
  begin
    Dec(Sm, 20);
    DoDrawIcon(Sm, Y, DB_IC_KEY);
  end;
end;

procedure TImHint.CreateFormImage;
var
  Bitmap: TBitmap;
  SFileSize,
  SImageSize: string;
  TextHeight, ImageNameHeight: Integer;
  R: TRect;
begin

  SImageSize := Format(L('Image size: %d x %d'), [FWidth, FHeight]);
  SFileSize := Format(L('File size: %s'), [SizeInText(CurrentInfo.FileSize)]);

  FFormBuffer.Width := Width;
  FFormBuffer.Height := Height;
  FillTransparentColor(FFormBuffer, clBlack, 0);
  DrawRoundGradientVert(FFormBuffer, Rect(0, 0, Width, Height),
    Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, 8, 220);
  TextHeight := Canvas.TextHeight('Iy');

  Bitmap := TBitmap.Create;
  try
    if StyleServices.Enabled then
      Font.Color := Theme.GradientText;

    DrawShadowToImage(Bitmap, ImageBuffer);
    DrawImageEx32(FFormBuffer, Bitmap, 5, 5);
    R.Left := 5;
    R.Right := FFormBuffer.Width - 5;
    R.Top := 5 + Bitmap.Height + 5;
    R.Bottom := 5 + Bitmap.Height + TextHeight + 5;

    R := Rect(R.Left, R.Top, R.Right, R.Top + 200); //heihgt of text up to 200 pixels
    DrawText(Canvas.Handle, PChar(ImageName), Length(ImageName), R, DT_CALCRECT or DT_WORDBREAK);
    ImageNameHeight := R.Bottom - R.Top;
    //restore right
    R.Right := FFormBuffer.Width - 5;
    DrawText32Bit(FFormBuffer, ImageName, Font, R, DT_WORDBREAK);
    R.Bottom := R.Bottom + ImageNameHeight + 5;
    R.Top := R.Top + ImageNameHeight + 5;
    DrawText32Bit(FFormBuffer, SFileSize, Font, R, 0);
    R.Bottom := R.Bottom + TextHeight + 5;
    R.Top := R.Top + TextHeight + 5;
    DrawText32Bit(FFormBuffer, SImageSize, Font, R, 0);
    RenderForm(Self.Handle, FFormBuffer, FAlphaBlend);
  finally
    F(Bitmap);
  end;

end;

function TImHint.Execute(Sender: TForm; G: TGraphic; W, H: Integer;
  Info: TMediaItem; Pos: TPoint; CheckFunction: THintCheckFunction): Boolean;
var
  DisplayWidth, DisplayHeight, WindowHeight,
  WindowWidth, WindowLeft, WindowTop, TextHeight: Integer;
  Rect: TRect;
  R: TRect;
  InverseHW, IsAnimated: Boolean;
begin
  Result := False;
  try
    FCheckFunction := CheckFunction;
    FOwner := Sender;
    FWidth := W;
    FHeight := H;
    if not GOM.IsObj(FOwner) then
      Exit;
    if not FCheckFunction(Info) then
      Exit;

    Result := True;

    ImageFrameTimer.Enabled := False;
    AnimatedBuffer := nil;
    CanClosed := True;

    TimerHide.Enabled := False;
    TimerShow.Enabled := False;
    GoIn := False;
    TimerHintCheck.Enabled := True;
    FDragDrop := True;
    CurrentInfo := Info.Copy;

    IsAnimated := IsAnimatedGraphic(G);
    InverseHW := not (Info.Rotation and DB_IMAGE_ROTATE_MASK in [DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_180]);
    if not (InverseHW and IsAnimated) then
    begin
      DisplayWidth := G.Width;
      DisplayHeight := G.Height;
    end else
    begin
      DisplayHeight := G.Width;
      DisplayWidth := G.Height;
    end;
    if not IsAnimated then
      ProportionalSize(ThHintSize, ThHintSize, DisplayWidth, DisplayHeight);

    ImageBuffer := TBitmap.Create;
    AnimatedBuffer := TBitmap.Create;
    AnimatedBuffer.PixelFormat := pf24bit;
    AnimatedBuffer.Width := G.Width;
    AnimatedBuffer.Height := G.Height;
    AnimatedBuffer.Canvas.Brush.Color := Theme.PanelColor;
    AnimatedBuffer.Canvas.Pen.Color := Theme.PanelColor;
    AnimatedBuffer.Canvas.Rectangle(0, 0, AnimatedBuffer.Width, AnimatedBuffer.Height);
    AnimatedImage := G;

    if IsAnimated then
    begin
      SlideNO := -1;
      ImageFrameTimer.Interval := 1;
      ImageFrameTimer.Enabled := True;
      ImageBuffer.Width := DisplayWidth;
      ImageBuffer.Height := DisplayHeight;
      //Draw first slide
      ImageFrameTimerTimer(Self);
    end else
      ImageBuffer.Assign(G);

    WindowWidth := Max(100, DisplayWidth + 10 + 2);
    WindowHeight := DisplayHeight + 10;

    TextHeight := Canvas.TextHeight('Iy');
    R.Left := 5;
    R.Right := WindowWidth - 5;
    R.Top := WindowHeight + 10;

    R.Bottom := 5 + 200;
    DrawText(Canvas.Handle, PChar(ImageName), Length(ImageName), R, DT_WORDBREAK or DT_CALCRECT);
    Inc(WindowHeight, 2 * (5 + TextHeight) + (5 + R.Bottom - R.Top) + 5);

    //fix window position
    Rect := System.Classes.Rect(Pos.X, Pos.Y, Pos.X + 100, Pos.Y + 100);
    if Rect.Top + WindowHeight + 10 > Screen.Height then
      WindowTop := Rect.Top - 20 - WindowHeight
    else
      WindowTop := Rect.Top + 10;

    if Rect.Left + WindowWidth + 10 > Screen.Width then
      WindowLeft := Rect.Left - 20 - WindowWidth
    else
      WindowLeft := Rect.Left + 10;

    if GOM.IsObj(Sender) then
    begin
      if WindowTop < Sender.Monitor.Top then
        WindowTop := Sender.Monitor.Top + 100;
      if WindowLeft < Sender.Monitor.Left then
        WindowLeft := Sender.Monitor.Left + 100;
    end;

    Top := WindowTop;
    Left := WindowLeft;

    FAlphaBlend := 0;
    TimerShow.Enabled := True;

    if GOM.IsObj(FOwner) then
      if FOwner.FormStyle = FsStayOnTop then
        SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
    FClosed := False;

    ClientWidth := WindowWidth;
    ClientHeight := WindowHeight;

    DrawHintInfo(ImageBuffer, ImageBuffer.Width, ImageBuffer.Height, CurrentInfo);
    CreateFormImage;
    if Info.InnerImage then
      ShowWindow(Handle, SW_SHOW)
    else
      ShowWindow(Handle, SW_SHOWNOACTIVATE);
  finally
    F(Info);
  end;
end;

procedure TImHint.FormClick(Sender: TObject);
begin
  TimerHide.Enabled := True;
  Close;
end;

procedure TImHint.FormCreate(Sender: TObject);
begin
  FInternalClose := False;
  CanClosed := True;
  AnimatedBuffer := nil;
  CurrentInfo := nil;
  DropFileTargetMain.Register(Self);
  FClosed := True;

  BorderStyle := bsNone;
  FFormBuffer := TBitmap.Create;
  FFormBuffer.PixelFormat := pf32Bit;
  THintManager.Instance.RegisterHint(Self);
end;

procedure TImHint.CMMOUSELEAVE(var Message: TWMNoParams);
var
  P: TPoint;
  R: TRect;
begin
  R := Rect(Self.Left, Self.Top, Self.Left + Self.Width, Self.Top + Self.Height);
  Getcursorpos(P);
  if not PtInRect(R, P) then
    TimerHide.Enabled := True;
end;

procedure TImHint.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage: TBitmap;
  W, H: Integer;
  Context: IDBContext;
  SettingsRepository: ISettingsRepository;
  Settings: TSettings;
begin
  if not FDragDrop then
    Exit;

  if (Button = mbLeft) then
  begin
    CanClosed := False;
    DragImageList.Clear;
    DropFileSourceMain.Files.Clear;
    DropFileSourceMain.Files.Add(CurrentInfo.FileName);

    W := ImageBuffer.Width;
    H := ImageBuffer.Height;

    Context := DBKernel.DBContext;
    SettingsRepository := Context.Settings;
    Settings := SettingsRepository.Get;
    try
      ProportionalSize(Settings.ThSize, Settings.ThSize, W, H);
    finally
      F(Settings);
    end;

    DragImage := TBitmap.Create;
    try
      DragImage.PixelFormat := ImageBuffer.PixelFormat;
      DoResize(W, H, ImageBuffer, DragImage);

      CreateDragImage(DragImage, DragImageList, Font, ExtractFileName(CurrentInfo.FileName));
    finally
      F(DragImage);
    end;

    DropFileSourceMain.ImageIndex := 0;
    DropFileSourceMain.Execute;
    CanClosed := True;
  end;
  TimerHintCheck.Enabled := True;
end;

procedure TImHint.TimerShowTimer(Sender: TObject);
begin
  FAlphaBlend := Min(FAlphaBlend + 40, 255);
  if FAlphaBlend >= 255 then
    TimerShow.Enabled := False;
  CreateFormImage;
end;

procedure TImHint.WMActivateApp(var Msg: TMessage);
begin
  if Msg.wParam = 0 then
    TimerHide.Enabled := True;
end;

procedure TImHint.TimerHideTimer(Sender: TObject);
begin
  TimerShow.Enabled := False;
  FAlphaBlend := Max(FAlphaBlend - 40, 0);
  if FAlphaBlend = 0 then
  begin
    if not BlockClosingOfWindows then
    begin
      TimerHide.Enabled := False;
      FInternalClose := True;
      Close;
    end else
    begin
      CreateFormImage;
      Hide;
    end;
  end else
    CreateFormImage;
end;

procedure TImHint.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FInternalClose then
    Exit;

  if FClosed then
  begin
    CanClose := False;
    Exit;
  end;

  if (FAlphaBlend > 0) then
  begin
    TimerHide.Enabled := True;
    CanClose := False;
  end;

  TimerHintCheck.Enabled := False;
  FClosed := True;
end;

procedure TImHint.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  THintManager.Instance.UnRegisterHint(Self);
  if GOM.IsObj(FOwner) then
    if FOwner.FormStyle = FsStayOnTop then
      FOwner.SetFocus;
  F(AnimatedBuffer);
  F(ImageBuffer);
  ImageFrameTimer.Enabled := False;
  Release;
end;

procedure TImHint.Image1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  MenuInfo: TMediaItemCollection;
begin
  TimerHintCheck.Enabled := False;
  FDragDrop := True;
  MenuInfo := TMediaItemCollection.Create;
  try
    MenuInfo.Add(CurrentInfo.Copy);
    MenuInfo[0].Selected := True;
    MenuInfo.ListItem := nil;
    MenuInfo.IsListItem := False;
    TDBPopupMenu.Instance.Execute(Self, ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y, MenuInfo);
    if not FClosed then
      TimerHide.Enabled := True;
    FDragDrop := False;
  finally
    F(MenuInfo);
  end;
end;

procedure TImHint.TimerHintCheckTimer(Sender: TObject);
var
  P: Tpoint;
  R: Trect;
begin
  if FClosed then
  begin
    TimerHintCheck.Enabled := False;
    Exit;
  end;
  if not Goin then
    Exit;
  R := Rect(Left, Top, Left + Width, Top + Height);
  Getcursorpos(P);
  if not PtInRect(R, P) then
    TimerHide.Enabled := True;

  GoIn := False;
end;

procedure TImHint.LbSizeMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  GoIn := True;
end;

procedure TImHint.FormDeactivate(Sender: TObject);
begin
  Close;
end;

procedure TImHint.FormDestroy(Sender: TObject);
begin
  F(AnimatedBuffer);
  F(ImageBuffer);
  F(AnimatedImage);
  F(CurrentInfo);
  F(FFormBuffer);
  DropFileTargetMain.Unregister;
end;

procedure TImHint.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

procedure TImHint.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if FClosed then
    Exit;

  if Msg.message = WM_KEYDOWN then
  begin
    if Msg.WParam = VK_ESCAPE then
      Close;
  end;
end;

procedure TImHint.ImageFrameTimerTimer(Sender: TObject);
begin
  if FClosed then
    Exit;

  AnimatedImage.ProcessNextFrame(AnimatedBuffer, SlideNo, Theme.PanelColor, ImageFrameTimer,
    procedure
    begin
      ImageBuffer.Canvas.Pen.Color := Theme.PanelColor;
      ImageBuffer.Canvas.Brush.Color := Theme.PanelColor;
      ImageBuffer.Canvas.Rectangle(0, 0, ImageBuffer.Width, ImageBuffer.Height);

      case CurrentInfo.Rotation and DB_IMAGE_ROTATE_MASK of
        DB_IMAGE_ROTATE_0:
          StretchCoolEx0(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, Theme.PanelColor);
        DB_IMAGE_ROTATE_90:
          StretchCoolEx90(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, Theme.PanelColor);
        DB_IMAGE_ROTATE_180:
          StretchCoolEx180(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, Theme.PanelColor);
        DB_IMAGE_ROTATE_270:
          StretchCoolEx270(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, Theme.PanelColor);
      end;

      DrawHintInfo(ImageBuffer, ImageBuffer.Width, ImageBuffer.Height, CurrentInfo);
      CreateFormImage;
    end
  );
end;

function TImHint.GetFormID: string;
begin
  Result := 'Hint';
end;

function TImHint.GetImageName: string;
begin
  if CurrentInfo.Comment <> '' then
    Result := CurrentInfo.Comment
  else if CurrentInfo.InnerImage then
    Result := CurrentInfo.Name
  else
    Result := ExtractFileName(IIF(CurrentInfo.Name <> '', CurrentInfo.Name, ExtractFileName(CurrentInfo.FileName)));
end;

end.
