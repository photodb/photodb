unit UnitImHint;

interface

uses
  DBCMenu, UnitDBKernel, menus,dolphin_db, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, GIFImage, Math,
  Dialogs, StdCtrls, ExtCtrls, ImButton, ComCtrls, ActiveX,
  AppEvnts, ImgList, DropSource, DropTarget, GraphicsCool, DragDropFile,
  DragDrop, UnitDBCommon, UnitDBCommonGraphics, uMemory, uDBForm,
  UnitBitmapImageList, uListViewUtils, uGOM, UnitHintCeator;

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
    procedure Execute(Sender : TForm; G : TGraphic; W, H : Integer; Info : TDBPopupMenuInfoRecord; Pos : TPoint; CheckFunction : THintCheckFunction);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
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
    procedure UpdateTheme(Sender: TObject);
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
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

implementation

uses Searching, Language;

{$R *.dfm}

{ TImHint }

procedure RenderForm(Form : TForm; Bitmap32 : TBitmap; Transparenty : Byte);
var
  zSize: TSize;
  zPoint: TPoint;
  zBf: TBlendFunction;
  TopLeft: TPoint;
begin
  SetWindowLong(Form.Handle, GWL_EXSTYLE,
    GetWindowLong(Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);

  Form.Width := Bitmap32.Width;
  Form.Height := Bitmap32.Height;

  zSize.cx := Bitmap32.Width;
  zSize.cy := Bitmap32.Height;
  zPoint := Point(0, 0);

  with zBf do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := AC_SRC_ALPHA;
    SourceConstantAlpha := Transparenty;
  end;
  TopLeft := Form.BoundsRect.TopLeft;

  UpdateLayeredWindow(Form.Handle, GetDC(0), @TopLeft, @zSize,
    Bitmap32.Canvas.Handle, @zPoint, 0, @zBf, ULW_ALPHA);
end;

procedure DrawHintInfo(Handle : THandle; Width,Height  : Integer; fInfo : TDBPopupMenuInfoRecord);
var
  Sm, Y: Integer;
begin
  Y := Height - 18;
  Sm := Width - 2;
  if (Width < 80) or (Height < 60) then
    Exit;
  if FInfo.Access = Db_access_private then
  begin
    Dec(Sm, 20);
    DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_PRIVATE + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
  Dec(Sm, 20);
  case FInfo.Rotation of
    DB_IMAGE_ROTATE_90:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_ROTETED_90 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATE_180:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_ROTETED_180 + 1], 16, 16, 0, 0, DI_NORMAL);
    DB_IMAGE_ROTATE_270:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_ROTETED_270 + 1], 16, 16, 0, 0, DI_NORMAL);
    else
      Inc(Sm, 20);
  end;
  Dec(Sm, 20);
  case FInfo.Rating of
    1:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_RATING_1 + 1], 16, 16, 0, 0, DI_NORMAL);
    2:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_RATING_2 + 1], 16, 16, 0, 0, DI_NORMAL);
    3:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_RATING_3 + 1], 16, 16, 0, 0, DI_NORMAL);
    4:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_RATING_4 + 1], 16, 16, 0, 0, DI_NORMAL);
    5:
      DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_RATING_5 + 1], 16, 16, 0, 0, DI_NORMAL);
  else
    Inc(Sm, 20);
  end;
  if FInfo.Crypted then
  begin
    Dec(Sm, 20);
    DrawIconEx(Handle, Sm, Y, UnitDBKernel.Icons[DB_IC_KEY + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
end;

procedure TImHint.CreateFormImage;
var
  Bitmap : TBitmap;
  SFileSize,
  SImageSize,
  SImageName : string;
  TextHeight : Integer;
  R : TRect;
begin

  if CurrentInfo.Comment <> '' then
    SImageName := CurrentInfo.Comment
  else
    SImageName := ExtractFileName(CurrentInfo.FileName);
  SImageSize := Format(L('Image size: %d x %d'), [FWidth, FHeight]);
  SFileSize := Format(L('File size: %s'), [SizeintextA(CurrentInfo.FileSize)]);

  FFormBuffer.Width := Width;
  FFormBuffer.Height := Height;
  FillTransparentColor(FFormBuffer, clBlack, 0);
  DrawRoundGradientVert(FFormBuffer, Rect(0, 0, Width, Height),
    clGradientActiveCaption, clGradientInactiveCaption, clHighlight, 8, 220);
  Bitmap := TBitmap.Create;

  TextHeight := Canvas.TextHeight('Iy');
  try
    DrawShadowToImage(Bitmap, ImageBuffer);
    DrawImageEx32(FFormBuffer, Bitmap, 5, 5);
    R.Left := 5;
    R.Right := FFormBuffer.Width - 5;
    R.Top := 5 + Bitmap.Height + 5;
    R.Bottom := 5 + Bitmap.Height + TextHeight + 5;
    DrawText32Bit(FFormBuffer, SImageName, Font, R, 0);
    R.Bottom := R.Bottom + TextHeight + 5;
    R.Top := R.Top + TextHeight + 5;
    DrawText32Bit(FFormBuffer, SFileSize, Font, R, 0);
    R.Bottom := R.Bottom + TextHeight + 5;
    R.Top := R.Top + TextHeight + 5;
    DrawText32Bit(FFormBuffer, SImageSize, Font, R, 0);
    RenderForm(Self, FFormBuffer, FAlphaBlend);
  finally
    Bitmap.Free;
  end;

end;

procedure TImHint.Execute(Sender : TForm; G : TGraphic; W, H : Integer; Info : TDBPopupMenuInfoRecord; Pos : TPoint; CheckFunction : THintCheckFunction);
var
  WW, HH, FH, FW, FL, FT, LW: Integer;
  B: TBitmap;
  Rect : TRect;
begin
  FCheckFunction := CheckFunction;
  FOwner := Sender;
  FWidth := W;
  FHeight := H;
  if not GOM.IsObj(FOwner) then
    Exit;
  if not FCheckFunction(Info) then
    Exit;

  ImageFrameTimer.Enabled := False;
  AnimatedBuffer := nil;
  CanClosed := True;

  TimerHide.Enabled := False;
  TimerShow.Enabled := False;
  GoIn := False;
  TimerHintCheck.Enabled := True;
  FDragDrop := True;
  CurrentInfo := Info;

  if (Info.Rotation = DB_IMAGE_ROTATE_0) or (Info.Rotation = DB_IMAGE_ROTATE_180) then
  begin
    WW := G.Width;
    HH := G.Height;
  end else
  begin
    HH := G.Width;
    WW := G.Height;
  end;
  ProportionalSize(ThHintSize, ThHintSize, Ww, Hh);

  ImageBuffer := TBitmap.Create;
  AnimatedBuffer := TBitmap.Create;
  AnimatedBuffer.PixelFormat := Pf24bit;
  AnimatedBuffer.Width := G.Width;
  AnimatedBuffer.Height := G.Height;
  AnimatedBuffer.Canvas.Brush.Color := Theme_MainColor;
  AnimatedBuffer.Canvas.Pen.Color := Theme_MainColor;
  AnimatedBuffer.Canvas.Rectangle(0, 0, AnimatedBuffer.Width, AnimatedBuffer.Height);
  AnimatedImage := G;

  FW := Max(100, WW + 10 + 2);
  FH := HH + 10;
  Inc(FH, 3 * (5 + Canvas.TextHeight('Iy')) + 5);

  ClientWidth := FW;
  ClientHeight := FH;

  //fix window position
  Rect := Classes.Rect(Pos.X, Pos.Y, Pos.X + 100, Pos.Y + 100);
  if Rect.Top + Fh + 10 > Screen.Height then
    Ft := Rect.Top - 20 - Fh
  else
    Ft := Rect.Top + 10;
  if Rect.Left + Fw + 10 > Screen.Width then
    Fl := Rect.Left - 20 - Fw
  else
    Fl := Rect.Left + 10;
  if Ft < 0 then
    Ft := 200;
  if Fl < 0 then
    Fl := 200;
  Top := Ft;
  Left := Fl;

  FAlphaBlend := 0;
  if DBKernel.ReadInteger('Options', 'PreviewSwohOptions', 0) = 0 then
    TimerShow.Enabled := True
  else
    FAlphaBlend := 255;

  if Fowner <> nil then
    if Fowner.FormStyle = Fsstayontop then
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
  FClosed := False;

  if (G is TGIFImage) and ((G as TGIFImage).Images.Count > 1) then
  begin
    SlideNO := -1;
    ImageFrameTimer.Interval := 1;
    ImageFrameTimer.Enabled := True;
    ImageBuffer.Width := G.Width;
    ImageBuffer.Height := G.Height;
    //Draw first slide
    ImageFrameTimerTimer(Self);
  end else
  begin
    ImageBuffer.Assign(G);
  end;

  CreateFormImage;
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
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
  DropFileTargetMain.Register(Self);
  DBkernel.RegisterForm(Self);
  DBkernel.RegisterProcUpdateTheme(UpdateTheme, Self);
  FClosed := True;

  BorderStyle := bsNone;
  FFormBuffer := TBitmap.Create;
  FFormBuffer.PixelFormat := pf32Bit;
  THintManager.Instance.RegisterHint(Self);
end;

procedure TImHint.CMMOUSELEAVE(var Message: TWMNoParams);
var
  P : tpoint;
  R : trect;
begin
  R := Rect(Self.Left, Self.Top, Self.Left + Self.Width, Self.Top + Self.Height);
  Getcursorpos(P);
  if not PtInRect(R, P) then
    TimerHide.Enabled := True;
end;

procedure TImHint.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage : TBitmap;
  FImageList : TBitmapImageList;
  W, H : Integer;
begin
  if not FDragDrop then
    Exit;

  if (Button = mbLeft) then
  begin
    CanClosed := False;
    DragImageList.Clear;
    DropFileSourceMain.Files.Clear;
    DropFileSourceMain.Files.Add(CurrentInfo.FileName);

    FImageList := TBitmapImageList.Create;
    try
      W := ImageBuffer.Width;
      H := ImageBuffer.Height;
      ProportionalSize(ThSize, ThSize, W, H);
      DragImage:=TBitmap.Create;
      try
        DragImage.PixelFormat := pf24bit;
        DoResize(W, H, ImageBuffer, DragImage);

        FImageList.AddBitmap(DragImage, False);
        CreateDragImageEx(nil, DragImageList, FImageList, clGradientActiveCaption,
          clGradientInactiveCaption, clHighlight, Font, ExtractFileName(CurrentInfo.FileName));

      finally
        DragImage.Free;
      end;
    finally
      FImageList.Free;
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

  if (FAlphaBlend > 0) and (DBKernel.Readinteger('Options', 'PreviewSwohOptions', 0) = 0) then
  begin
    TimerHide.Enabled := True;
    CanClose := False;
  end else
    if DBKernel.Readinteger('Options', 'PreviewSwohOptions', 0) = 1 then
      RecreateWnd; //WFT?

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
  MenuInfo.Add(CurrentInfo);
  MenuInfo.AttrExists := False;
  MenuInfo.ListItem := nil;
  MenuInfo.IsListItem := False;
  TDBPopupMenu.Instance.Execute(ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y, MenuInfo);
  if not FClosed then
    TimerHide.Enabled := True;
  FDragDrop := False;
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

procedure TImHint.UpdateTheme(Sender: TObject);
begin
  DBKernel.RecreateThemeToForm(Self);
end;

procedure TImHint.FormDestroy(Sender: TObject);
begin
  DropFileTargetMain.Unregister;
  DBkernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
  DBkernel.UnRegisterForm(Self);
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
  Del: Integer;
  TimerEnabled: Boolean;
  Gsi: TGIFSubImage;
  TickCountStart: Cardinal;
begin
  TickCountStart := GetTickCount;
  Del := 100;
  if FClosed then
    Exit;
  DisposalMethod := DmNone;

  if SlideNO = -1 then
    SlideNO := GetFirstImageNO
  else
    SlideNO := GetNextImageNO;

  R := (AnimatedImage as TGIFImage).Images[SlideNO].BoundsRect;
  AnimatedBuffer.Canvas.Brush.Color := Theme_MainColor;
  AnimatedBuffer.Canvas.Pen.Color := Theme_MainColor;
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
  end
  else
    DisposalMethod := DmNone;
  if SlideNO = 0 then
    DisposalMethod := DmBackground
  else if (DisposalMethod = DmBackground) then
  begin
    Bounds_ := Im.Images[PreviousNumber].BoundsRect;
    AnimatedBuffer.Canvas.Pen.Color := Theme_MainColor;
    AnimatedBuffer.Canvas.Brush.Color := Theme_MainColor;
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

  ImageBuffer.Canvas.Pen.Color := Theme_MainColor;
  ImageBuffer.Canvas.Brush.Color := Theme_MainColor;
  ImageBuffer.Canvas.Rectangle(0, 0, ImageBuffer.Width, ImageBuffer.Height);

  case CurrentInfo.Rotation of
    DB_IMAGE_ROTATE_0:
      StretchCoolEx0(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, Theme_MainColor);
    DB_IMAGE_ROTATE_90:
      StretchCoolEx90(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, Theme_MainColor);
    DB_IMAGE_ROTATE_180:
      StretchCoolEx180(0, 0, ImageBuffer.Width, ImageBuffer.Height, AnimatedBuffer, ImageBuffer, Theme_MainColor);
    DB_IMAGE_ROTATE_270:
      StretchCoolEx270(0, 0, ImageBuffer.Height, ImageBuffer.Width, AnimatedBuffer, ImageBuffer, Theme_MainColor);
  end;

  DrawHintInfo(ImageBuffer.Canvas.Handle, ImageBuffer.Width, ImageBuffer.Height, CurrentInfo);
  CreateFormImage;
  ImageFrameTimer.Enabled := False;
  ImageFrameTimer.Interval := Max(Del div 2, Del - GetTickCount - TickCountStart);
  if not TimerEnabled then
    ImageFrameTimer.Enabled := False
  else
    ImageFrameTimer.Enabled := True;
end;

function TImHint.GetFormID: string;
begin
  Result := 'Hint';
end;

initialization

end.
