unit UnitImHint;

interface

uses
  DBCMenu, UnitDBKernel, Menus, dolphin_db, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, GIFImage, Math,
  Dialogs, StdCtrls, ExtCtrls, ImButton, ComCtrls, ActiveX,
  AppEvnts, ImgList, DropSource, DropTarget, GraphicsCool, DragDropFile,
  DragDrop, UnitDBCommon, uBitmapUtils, uMemory, uDBForm,
  UnitBitmapImageList, uListViewUtils, uGOM, UnitHintCeator, uDBDrawing,
  UnitDBDeclare, uConstants, uDBPopupMenuInfo, uFormUtils,
  uRuntime;

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
    function Execute(Sender: TForm; G: TGraphic; W, H: Integer;
      Info: TDBPopupMenuInfoRecord; Pos: TPoint;
      CheckFunction: THintCheckFunction): Boolean;
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure WMActivateApp(var Msg: TMessage); message WM_ACTIVATEAPP;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerShowTimer(Sender: TObject);
    procedure TimerHideTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TimerHintCheckTimer(Sender: TObject);
    procedure LbSizeMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    function GetNextImageNO : integer;
    function GetNextImageNOX(NO: Integer): integer;
    function GetPreviousImageNO: integer;
    function GetPreviousImageNOX(NO: Integer): integer;
    procedure ImageFrameTimerTimer(Sender: TObject);
    function GetFirstImageNO: integer;
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
    AnimatedImage : TGraphic;
    SlideNO : Integer;
    AnimatedBuffer : TBitmap;
    ImageBuffer : TBitmap;
    CanClosed : Boolean;
    FFormBuffer : TBitmap;
    CurrentInfo : TDBPopupMenuInfoRecord;
    FDragDrop : Boolean;
    FOwner : TForm;
    GoIn : Boolean;
    FCheckFunction : THintCheckFunction;
    FClosed : Boolean;
    FWidth : Integer;
    FHeight : Integer;
    FAlphaBlend : Byte;
    FInternalClose: Boolean;
    procedure CreateFormImage;
    function GetImageName: string;
  protected
    function GetFormID : string; override;
    property ImageName : string read GetImageName;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TImHint }

procedure DrawHintInfo(Bitmap: TBitmap; Width, Height: Integer; FInfo: TDBPopupMenuInfoRecord);
var
  Sm, Y: Integer;

  procedure DoDrawIcon(X, Y: Integer; ImageIndex: Integer; Grayscale: Boolean = False);
  begin
    if not Grayscale then
      DrawIconEx(Bitmap.Canvas.Handle, X, Y, UnitDBKernel.Icons[ImageIndex + 1], 16, 16, 0, 0, DI_NORMAL)
    else
      Icons.Items[ImageIndex].GrayIcon.DoDraw(X, Y, Bitmap);
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
  case FInfo.Rotation of
    10 * DB_IMAGE_ROTATE_90,
    DB_IMAGE_ROTATE_90:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_90);
    10 * DB_IMAGE_ROTATE_180,
    DB_IMAGE_ROTATE_180:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_180);
    10 * DB_IMAGE_ROTATE_270,
    DB_IMAGE_ROTATE_270:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_270);
    -10 * DB_IMAGE_ROTATE_90,
    -100 * DB_IMAGE_ROTATE_90:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_90, True);
    -10 * DB_IMAGE_ROTATE_180,
    -100 * DB_IMAGE_ROTATE_180:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_180, True);
    -10 * DB_IMAGE_ROTATE_270,
    -100 * DB_IMAGE_ROTATE_270:
      DoDrawIcon(Sm, Y, DB_IC_ROTETED_270, True);
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
  if FInfo.Crypted then
  begin
    Dec(Sm, 20);
    DoDrawIcon(Sm, Y, DB_IC_KEY);
  end;
end;

procedure TImHint.CreateFormImage;
var
  Bitmap : TBitmap;
  SFileSize,
  SImageSize : string;
  TextHeight, ImageNameHeight : Integer;
  R : TRect;
begin

  SImageSize := Format(L('Image size: %d x %d'), [FWidth, FHeight]);
  SFileSize := Format(L('File size: %s'), [SizeInText(CurrentInfo.FileSize)]);

  FFormBuffer.Width := Width;
  FFormBuffer.Height := Height;
  FillTransparentColor(FFormBuffer, clBlack, 0);
  DrawRoundGradientVert(FFormBuffer, Rect(0, 0, Width, Height),
    clGradientActiveCaption, clGradientInactiveCaption, clHighlight, 8, 220);
  TextHeight := Canvas.TextHeight('Iy');

  Bitmap := TBitmap.Create;
  try
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
  Info: TDBPopupMenuInfoRecord; Pos: TPoint; CheckFunction: THintCheckFunction): Boolean;
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

    IsAnimated := (G is TGIFImage) and ((G as TGIFImage).Images.Count > 1);
    InverseHW := not (Info.Rotation = DB_IMAGE_ROTATE_0) or (Info.Rotation = DB_IMAGE_ROTATE_180);
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
    AnimatedBuffer.PixelFormat := Pf24bit;
    AnimatedBuffer.Width := G.Width;
    AnimatedBuffer.Height := G.Height;
    AnimatedBuffer.Canvas.Brush.Color := clBtnFace;
    AnimatedBuffer.Canvas.Pen.Color := clBtnFace;
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
    Rect := Classes.Rect(Pos.X, Pos.Y, Pos.X + 100, Pos.Y + 100);
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
    ProportionalSize(ThSize, ThSize, W, H);
    DragImage:=TBitmap.Create;
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
    TimerHide.Enabled:=false;
    FInternalClose := True;
    Close;
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
  MenuInfo: TDBPopupMenuInfo;
begin
  TimerHintCheck.Enabled := False;
  FDragDrop := True;
  MenuInfo := TDBPopupMenuInfo.Create;
  try
    MenuInfo.Add(CurrentInfo.Copy);
    MenuInfo[0].Selected := True;
    MenuInfo.AttrExists := False;
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

function TImHint.GetNextImageNO: integer;
var
  Im: TGIFImage;
begin
  Im := (AnimatedImage as TGIFImage);
  Result := SlideNO;
  Inc(Result);
  if Result >= Im.Images.Count then
    Result := 0;

  if Im.Images[Result].Empty then
    Result := GetNextImageNOX(Result);

end;

function TImHint.GetNextImageNOX(NO: Integer): integer;
var
  Im: TGIFImage;
begin
  Im := (AnimatedImage as TGIFImage);
  Result := NO;
  Inc(Result);
  if Result >= Im.Images.Count then
    Result := 0;

  if Im.Images[Result].Empty then
    Result := GetNextImageNOX(Result);
end;

function TImHint.GetPreviousImageNO: integer;
var
  Im: TGIFImage;
begin
  Im := (AnimatedImage as TGIFImage);
  Result := SlideNO;
  Dec(Result);
  if Result < 0 then
    Result := Im.Images.Count - 1;

  if Im.Images[Result].Empty then
    Result := GetPreviousImageNOX(Result);
end;

function TImHint.GetPreviousImageNOX(NO: Integer): integer;
var
  Im: TGIFImage;
begin
  Im := (AnimatedImage as TGIFImage);
  Result := NO;
  Dec(Result);
  if Result < 0 then
    Result := Im.Images.Count - 1;

  if Im.Images[Result].Empty then
    Result := GetPreviousImageNOX(Result);
end;

function TImHint.GetFirstImageNO: integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to (AnimatedImage as TGIFImage).Images.Count - 1 do
    if not(AnimatedImage as TGIFImage).Images[I].Empty then
    begin
      Result := I;
      Break;
    end;
end;

procedure TImHint.ImageFrameTimerTimer(Sender: TObject);
var
  C, PreviousNumber: Integer;
  R, Bounds_: TRect;
  Im: TGifImage;
  DisposalMethod: TDisposalMethod;
  Del, Delta: Integer;
  TimerEnabled: Boolean;
  Gsi: TGIFSubImage;
  TickCountStart: Cardinal;
begin
  TickCountStart := GetTickCount;
  Del := 100;
  if FClosed then
    Exit;

  if SlideNO = -1 then
    SlideNO := GetFirstImageNO
  else
    SlideNO := GetNextImageNO;

  R := (AnimatedImage as TGIFImage).Images[SlideNO].BoundsRect;
  AnimatedBuffer.Canvas.Brush.Color := clBtnFace;
  AnimatedBuffer.Canvas.Pen.Color := clBtnFace;
  Im := (AnimatedImage as TGIFImage);
  TimerEnabled := False;
  PreviousNumber := GetPreviousImageNO;
  if (Im.Animate) and (Im.Images.Count > 1) then
  begin
    Gsi := Im.Images[SlideNO];
    if Gsi.Empty then
      Exit;
    if Im.Images[PreviousNumber].Empty then
      DisposalMethod := DmNone
    else begin
      if Im.Images[PreviousNumber].GraphicControlExtension <> nil then
        DisposalMethod := Im.Images[PreviousNumber].GraphicControlExtension.Disposal
      else
        DisposalMethod := DmNone;
    end;

    if Im.Images[SlideNO].GraphicControlExtension <> nil then
      Del := Im.Images[SlideNO].GraphicControlExtension.Delay * 10;
    if Del = 10 then
      Del := 100;
    if Del = 0 then
      Del := 100;
    TimerEnabled := True;
  end else
    DisposalMethod := DmNone;
  if SlideNO = 0 then
    DisposalMethod := DmBackground
  else if (DisposalMethod = DmBackground) then
  begin
    Bounds_ := Im.Images[PreviousNumber].BoundsRect;
    AnimatedBuffer.Canvas.Pen.Color := ClBtnFace;
    AnimatedBuffer.Canvas.Brush.Color := ClBtnFace;
    AnimatedBuffer.Canvas.Rectangle(Bounds_);
  end;
  if DisposalMethod = DmPrevious then
  begin
    C := SlideNO;
    Dec(C);
    if C < 0 then
      C := Im.Images.Count - 1;
    Im.Images[C].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[SlideNO].Transparent, False);
  end;
  Im.Images[SlideNO].StretchDraw(AnimatedBuffer.Canvas, R, Im.Images[SlideNO].Transparent, False);

  ImageBuffer.Canvas.Pen.Color := ClBtnFace;
  ImageBuffer.Canvas.Brush.Color := ClBtnFace;
  ImageBuffer.Canvas.Rectangle(0, 0, ImageBuffer.Width, ImageBuffer.Height);

  case CurrentInfo.Rotation of
    DB_IMAGE_ROTATE_0:
      StretchCoolEx0(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, ClBtnFace);
    DB_IMAGE_ROTATE_90:
      StretchCoolEx90(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, ClBtnFace);
    DB_IMAGE_ROTATE_180:
      StretchCoolEx180(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, ClBtnFace);
    DB_IMAGE_ROTATE_270:
      StretchCoolEx270(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, ClBtnFace);
  end;

  DrawHintInfo(ImageBuffer, ImageBuffer.Width, ImageBuffer.Height, CurrentInfo);
  CreateFormImage;
  ImageFrameTimer.Enabled := False;
  Delta := Integer(GetTickCount - TickCountStart);
  ImageFrameTimer.Interval := Max(Del div 2, Del - Delta);
  if not TimerEnabled then
    ImageFrameTimer.Enabled := False
  else
    ImageFrameTimer.Enabled := True;
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
    Result := ExtractFileName(CurrentInfo.Name);
end;

end.
