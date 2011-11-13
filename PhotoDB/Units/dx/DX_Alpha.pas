unit DX_Alpha;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtDlgs, ComCtrls, StdCtrls, ExtCtrls, AppEvnts, Dolphin_DB, DDraw, uGUIDUtils,
  Math, uSysUtils, uDBForm, uDXUtils, uMemory, uSettings, uBitmapUtils, uMemoryEx,
  uVCLHelpers;

type
  TDirectShowForm = class(TDBForm)
    MouseTimer: TTimer;
    ApplicationEvents1: TApplicationEvents;
    DelayTimer: TTimer;
    FadeTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Execute(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseTimerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowMouse;
    procedure HideMouse;
    procedure ApplicationEvents1Message(var Msg: TagMSG; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure SetFirstImage(Image: TBitmap);
    procedure NewImage(Image: TBitmap);
    procedure DelayTimerTimer(Sender: TObject);
    procedure BeginFade;
    procedure FadeTimerTimer(Sender: TObject);
    procedure SetThreadImage(var Image: PByteArr);
    procedure LoadCurrentImage(XForward, Next: Boolean);
    procedure Pause;
    procedure Play;
    procedure Next(Force: Boolean);
    procedure Previous;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function CallBack(CallbackInfo: TCallbackInfo): TDirectXSlideShowCreatorCallBackResult;
  private
    { Private declarations }
    FOldPoint: TPoint;
    // Main structure DirectDraw
    DirectDraw4: IDirectDraw4;
    // Main (visible) surface
    PrimarySurface: IDirectDrawSurface4;
    // Surface for processing WM_PAINT
    OffScreen: IDirectDrawSurface4;
    // Screen-off (invisible) surface
    Buffer: IDirectDrawSurface4;
    // Information about colors
    BPP, RBM, GBM, BBM: Integer;
    // Arrays with surface data
    TransSrc1, TransSrc2: PByteArr;
    // Transformation settings
    TransHeight, TransPitch, TransSize: Integer;
    SurfaceDesc: TDDSurfaceDesc2;
    Clpr: IDirectDrawClipper;

    FReady: Boolean;
    FForwardThreadExists: Boolean;
    FForwardFileName: string;
    AlphaCount: Byte;
    XAlphaCount: Extended;
    FileLoaded: Boolean;
    procedure SetReady(const Value: Boolean);
    procedure SetForwardThreadExists(const Value: Boolean);
    procedure SetForwardFileName(const Value: string);
    function GetAlphaSteeps: Integer;
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure LoadDirectX;
  public
    { Public declarations }
    SID: TGUID;
    ForwardSID: TGUID;
    FManager: TDirectXSlideShowCreatorManager;
    FNowPaused: Boolean;
    FReadyAfterPause: Boolean;
    procedure UpdateSurface(ParentControl: TControl);
    procedure PrepareTransform(Buffer1, Buffer2: IDirectDrawSurface4);
    procedure UnPrepareTransform;
    procedure ReplaseTransform(Buffer: IDirectDrawSurface4);
    procedure TransformAlpha(Buffer: IDirectDrawSurface4; Alpha: Integer);
    property Ready: Boolean read FReady write SetReady;
    property ForwardThreadExists: Boolean read FForwardThreadExists write SetForwardThreadExists;
    property ForwardFileName: string read FForwardFileName write SetForwardFileName;
    property AlphaSteeps: Integer read GetAlphaSteeps;
  end;

var
  DirectShowForm: TDirectShowForm;

implementation

{$R *.DFM}

uses
  FloatPanelFullScreen, SlideShow, UnitDirectXSlideShowCreator;

// Copy Offscreen on screen (WM_PAINT, for example)
procedure TDirectShowForm.UpdateSurface(ParentControl: TControl);
var
  R1, R2: TRect;
  P: TPoint;
  Fx: TDDBltFx;
begin
  R1 := ParentControl.ClientRect;
  R2 := R1;
  // Coordinates of visible surface - screen, Coordinates of Offscreen - client.
  // Transformation...
  P := ParentControl.ClientToScreen(Point(0, 0));
  OffsetRect(R2, P.X, P.Y);
  // ...and copy.
  FillChar(Fx, Sizeof(Fx), 0);
  Fx.DwSize := Sizeof(Fx);
  PrimarySurface.Blt(@R2, Offscreen, @R1, DDBLT_WAIT, @Fx);
end;

// Free resources
procedure TDirectShowForm.UnPrepareTransform;
begin
  if TransSrc1 <> nil then
  begin
    FreeMem(TransSrc1);
    TransSrc1 := nil;
  end;
  if TransSrc2 <> nil then
  begin
    FreeMem(TransSrc2);
    TransSrc2 := nil;
  end;
end;

// Preparing transformation: lock surfaces, allocate memory for arrays,
// Copy surface data.
procedure TDirectShowForm.PrepareTransform(Buffer1, Buffer2: IDirectDrawSurface4);
var
  Dd: TDDSurfaceDesc2;
begin
  if (Buffer1 = nil) or (Buffer2 = nil) then
    Exit;
  // Clear memory.
  UnPrepareTransform;
  // Lock first source.
  LockRead(Buffer1, Dd);
  try
    // НЕ ЗАХОДИТЕ СЮДА ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ!
    // Запоминаем размеры.
    TransPitch := Dd.LPitch;
    TransHeight := Dd.DwHeight;
    TransSize := TransHeight * TransPitch;
    // Отводим память.
    GetMem(TransSrc1, TransSize);
    GetMem(TransSrc2, TransSize);
    // Копируем первый источник...
    CopyMemory(TransSrc1, Dd.LpSurface, TransSize - 1);
  finally
    // ...и разблокируем его.
    UnLock(Buffer1);
  end;
  // Блокируем второй источник.
  LockRead(Buffer2, Dd);
  try
    // НЕ ЗАХОДИТЕ СЮДА ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ!
    // Копируем его...
    CopyMemory(TransSrc2, Dd.LpSurface, TransSize - 1);
    // ...и разблокируем его.
  finally
    UnLock(Buffer2);
  end;
end;

procedure TDirectShowForm.ReplaseTransform(Buffer: IDirectDrawSurface4);
var
  Dd: TDDSurfaceDesc2;
  T: PByteArr;
begin
  T := TransSrc1;
  TransSrc1 := TransSrc2;
  TransSrc2 := T;
  LockRead(Buffer, Dd);
  try
    TransPitch := Dd.LPitch;
    TransHeight := Dd.DwHeight;
    TransSize := TransHeight * TransPitch;
    CopyMemory(TransSrc2, Dd.LpSurface, TransSize - 1);
  finally
    UnLock(Buffer);
  end;
end;

// O.K. Вот оно - самое главное. Эмуляция альфа-канала делается ЗДЕСЬ, побайтным
// преобразованием данных поверхностей. Результат заносится в Buffer. Alpha -
// коэффициент прозрачности, от 0 до 255.
//
//Вообще, это очень критичный участок. Надо бы переписать это на ассемблере,
//но я ASM'а не знаю. Может, кто-нибудь перепишет и мне пришлет, а?
//
procedure TDirectShowForm.TransformAlpha(Buffer: IDirectDrawSurface4; Alpha: Integer);
var
  Dd: TDDSurfaceDesc2;
  C, C1, M, N, A, Msa, X1: Integer;
  bb: ^TByteArray;
begin
  {$R-}
  if (TransSrc1 = nil) or (Buffer = nil) then
    Exit;
  //Блокируем буфер назначения.
  // НЕ ЗАХОДИТЕ СЮДА ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ!
  LockWrite(Buffer, Dd);
  if Dd.LpSurface = nil then
    Exit;

  try
    Bb := Dd.LpSurface;
    M := 0;
    X1 := BPP shr 3;
    N := TransSize - X1;

    if Bpp = 16 then
    begin
      A := Alpha shr 3; // Множитель прозрачности первого источника.
      Msa := $1F - A; // Множитель прозрачности второго источника.
      repeat
        C := Integer((@(TransSrc1^[M]))^); // Пиксель первого источника.
        C1 := Integer((@(TransSrc2^[M]))^); // Пиксель второго источника.
        // Результирующий пиксель
        C := (((Msa * ((C shr Rbm) and $1F) + A * ((C1 shr Rbm) and $1F)) shr 5) shl Rbm) or
          (((Msa * ((C shr Gbm) and $1F) + A * ((C1 shr Gbm) and $1F)) shr 5) shl Gbm) or
          (((Msa * ((C shr Bbm) and $1F) + A * ((C1 shr Bbm) and $1F)) shr 5) shl Bbm);
        // Записываем в выходной массив
        Bb^[M] := C;
        Bb^[M + 1] := C shr 8;
        // Следующая точка:
        Inc(M, X1);
      until M > N
    end else
    begin A := Alpha; // Множитель прозрачности первого источника.
      Msa := $FF - A; // Множитель прозрачности второго источника.
      repeat
        C := Integer((@(TransSrc1^[M]))^); // Пиксель первого источника.
        C1 := Integer((@(TransSrc2^[M]))^); // Пиксель второго источника.
        // Результирующий пиксель
        C := (((Msa * ((C shr Rbm) and $FF) + A * ((C1 shr Rbm) and $FF)) shr 8) shl Rbm) or
          (((Msa * ((C shr Gbm) and $FF) + A * ((C1 shr Gbm) and $FF)) shr 8) shl Gbm) or
          (((Msa * ((C shr Bbm) and $FF) + A * ((C1 shr Bbm) and $FF)) shr 8) shl Bbm);
        // Записываем в выходной массив
        Bb^[M] := C;
        Bb^[M + 1] := C shr 8;
        Bb^[M + 2] := C shr 16;
        // Следующая точка:
        Inc(M, X1);
      until M > N
    end;
  // Разблокируем буфер.
  finally
    UnLock(Buffer);
  end;
  {$R+}
end;

// По Create создаем DirectDraw и все провехности. Надо бы это делать по Resize
// и после каждого IDirectDrawSurface4.IsLost, но я забил болт.
procedure TDirectShowForm.FormCreate(Sender: TObject);
begin
  AlphaCount := 0;
  XAlphaCount := PI / 2;
  DelayTimer.Interval := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideDelay', 40), 1), 100) * 50;
  FNowPaused := False;
  FReadyAfterPause := False;
  Ready := False;
  FForwardThreadExists := False;
  if FloatPanel = nil then
    Application.CreateForm(TFloatPanel, FloatPanel);
  SID := GetGUID;

  // show before creating surface because of DDSCL_SETFOCUSWINDOW flsg
  Show;
  LoadDirectX;
end;

procedure TDirectShowForm.LoadDirectX;
var
  PP: Integer;
  DirectDraw2: IDirectDraw;
  Fx: TDDBltFx;
  R: TRect;
  PixelFormat: TDDPixelFormat;
  Objects: TThreadDestroyDXObjects;
begin
  DDrawInit;
  try
    // Создаем DirectDraw.
    DirectDrawCreate(nil, DirectDraw2, nil);
    // Запрашиваем интерфейс IDirectDraw4.
    DirectDraw2.QueryInterface(IID_IDirectDraw4, DirectDraw4);
    DirectDraw2.Release;
    DirectDraw2 := nil;

    DirectDraw4.SetCooperativeLevel(Handle, DDSCL_SETFOCUSWINDOW or DDSCL_EXCLUSIVE or DDSCL_FULLSCREEN or DDSCL_MULTITHREADED);
    // Основная (видимая) поверхность...
    FillChar(SurfaceDesc, Sizeof(SurfaceDesc), 0);

    DirectDraw4.SetCooperativeLevel (Handle, DDSCL_NORMAL);
    //Основная (видимая) поверхность...
    FillChar (SurfaceDesc, SizeOf (SurfaceDesc), 0);
    SurfaceDesc.dwSize := SizeOf (SurfaceDesc);
    SurfaceDesc.dwFlags := DDSD_CAPS;
    SurfaceDesc.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;

    DirectDraw4.CreateSurface(SurfaceDesc, PrimarySurface, nil);
    // ...привязывается к главному окну через IDirectDrawClipper.
    // Поэтому создаем IDirectDrawClipper...
    DirectDraw4.CreateClipper(0, Clpr, nil);
    // ...связываем его с главным окном...
    Clpr.SetHWND(0, Handle);

    // ...а потОм - с видимой поверхностью.
    PrimarySurface.SetClipper(Clpr);

    // Определяем цветовой формат экрана...
    PixelFormat.DwSize := SizeOf(TDDPIXELFORMAT);
    PrimarySurface.GetPixelFormat(PixelFormat);
    BPP := PixelFormat.DwRGBBitCount;
    BPP := 32;
    // ...и маски красного, синего и зеленого каналов.
    // Они потОм используются при паковке цвета.
    Pp := Round(Exp(BPP / 3.0 * Ln(2.0)));
    if Pp > $FF then
      Pp := $FF;
    RBM := Round(Ln(1.0 * PixelFormat.DwRBitMask / Pp) / Ln(2.0));
    GBM := Round(Ln(1.0 * PixelFormat.DwGBitMask / Pp) / Ln(2.0));
    BBM := Round(Ln(1.0 * PixelFormat.DwBBitMask / Pp) / Ln(2.0));
    // Теперь создаем внеэкранные (невидимые) поверхности. Они все имеют
    // одинаковые размеры.
    SurfaceDesc.DwFlags := DDSD_HEIGHT or DDSD_WIDTH;
    SurfaceDesc.DdsCaps.DwCaps := DDSCAPS_OFFSCREENPLAIN;
    SurfaceDesc.DwWidth := Width;
    SurfaceDesc.DwHeight := Height;
    // Эта используется для обработки WM_PAINT.
    DirectDraw4.CreateSurface(SurfaceDesc, Offscreen, nil);
    //Закрасим ее цветом фона (иначе на ней будет "снег").
    FillChar(fx, SizeOf(fx), 0);
    fx.dwSize := SizeOf(fx);
    fx.dwFillColor := PackColor(Color, BPP, RBM, GBM, BBM);
    R := ClientRect;
    Offscreen.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @fx);
    //Это - первый источник для преобразования.
    DirectDraw4.CreateSurface (SurfaceDesc, Buffer, nil);
  except
    on e: Exception do
      ShowMessage(L('Error initializing graphics mode: %s', e.Message));
  end;

  FileLoaded := False;

  FManager := TDirectXSlideShowCreatorManager.Create;
  Objects.DirectDraw4 := DirectDraw4;
  Objects.PrimarySurface := PrimarySurface;
  Objects.Offscreen := OffScreen;
  Objects.Buffer := Buffer;
  Objects.Clpr := Clpr;
  Objects.TransSrc1 := TransSrc1;
  Objects.TransSrc2 := TransSrc2;
  Objects.Form := Self;
  FManager.SetDXObjects(Objects);
end;

procedure TDirectShowForm.FormDestroy(Sender: TObject);
begin
  ShowMouse;
  DelayTimer.Enabled := False;
  FadeTimer.Enabled:= False;
  UnPrepareTransform;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);

  DirectXSlideShowCreatorManagers.DestroyManager(FManager);
end;

//По Paint копируем внеэкранный буфер (Offscreen) на экран.
procedure TDirectShowForm.FormPaint(Sender: TObject);
begin
  UpdateSurface(Self);
end;

//По изменению слайдера выполняем преобразование и обновляем экран.
procedure TDirectShowForm.Execute(Sender: TObject);
var
  TempImage, FirstImage: TBitmap;
  FH, FW: Integer;
  FbImage: TBitmap;
begin
  FbImage := Viewer.FbImage;

  if FloatPanel <> nil then
    FloatPanel.Show;

  MouseTimer.Restart;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 1, nil, 0);

  FirstImage := TBitmap.Create;
  try
    FirstImage.Width := Width;
    FirstImage.Height := Height;
    FirstImage.Canvas.Brush.Color := clBlack;
    FirstImage.Canvas.Pen.Color := clBlack;
    FirstImage.PixelFormat := pf24bit;
    FirstImage.Canvas.Rectangle(0, 0, Width, Height);

    if (FbImage.Width > Width) or (FbImage.Height > Height) then
    begin
      TempImage := TBitmap.Create;
      try
        TempImage.PixelFormat := pf24bit;

        FH := FbImage.Height;
        FW := FbImage.Width;
        ProportionalSize(Width, Height, FW, FH);
        DoResize(FW, FH, FbImage, TempImage);
        FirstImage.Canvas.Draw((FirstImage.Width - TempImage.Width) div 2,
                               (FirstImage.Height - TempImage.Height) div 2, TempImage);
      finally
        F(TempImage);
      end;
    end else
      FirstImage.Canvas.Draw((FirstImage.Width - FbImage.Width) div 2,
                             (FirstImage.Height - FbImage.Height) div 2, FbImage);

    SetFirstImage(FirstImage);
  finally
    F(FirstImage);
  end;
  DelayTimer.Enabled := True;
end;

procedure TDirectShowForm.FormDeactivate(Sender: TObject);
begin
  ShowMouse;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);
end;

procedure TDirectShowForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Restart;
end;

procedure TDirectShowForm.MouseTimerTimer(Sender: TObject);
var
  P: TPoint;
begin
  if Visible then
  begin
    GetCursorPos(p);
    if FloatPanel = nil then
      Exit;

    P := FloatPanel.ScreenToClient(P);
    if PtInRect(FloatPanel.ClientRect, P) then
      Exit;

    HideMouse;
  end;
end;

procedure TDirectShowForm.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseTimer.Enabled := True;
  if (Abs(FOldPoint.X - X) > 5) or (Abs(FOldPoint.Y - Y) > 5) then
  begin
    ShowMouse;
    FOldPoint := Point(X, Y);
    MouseTimer.Restart
  end;
end;

procedure TDirectShowForm.FormContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  ShowMouse;
  MouseTimer.Enabled := False;
  if Viewer <> nil then
    Viewer.PmMain.Popup(ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y);
end;

procedure TDirectShowForm.FormClick(Sender: TObject);
begin
  if Viewer = nil then
    Exit;
  Viewer.Pause;
  Viewer.NextImageClick(nil);
end;

procedure TDirectShowForm.FormMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Restart;
end;

procedure TDirectShowForm.HideMouse;
var
  CState: Integer;
begin
  CState := ShowCursor(True);
  while Cstate >= 0 do
    Cstate := ShowCursor(False);
  if FloatPanel<>nil then
  FloatPanel.Hide;
end;

procedure TDirectShowForm.ShowMouse;
var
  Cstate: Integer;
begin
  Cstate := ShowCursor(True);
  while CState < 0 do
    CState := ShowCursor(True);
  if Viewer.SlideShowNow then
    if FloatPanel <> nil then
      FloatPanel.Show;
end;

procedure TDirectShowForm.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
begin
  if Active and (Msg.message = WM_SYSKEYDOWN) then
    Msg.Message := 0;

  if Viewer <> nil then
  begin
    if Msg.message = WM_KEYDOWN then
    begin
      if Msg.wParam = VK_LEFT then
      begin
        Viewer.Pause;
        Viewer.PreviousImageClick(nil);
      end;
      if (Msg.wParam = VK_RIGHT) or (Msg.wParam = VK_SPACE) then
      begin
        Viewer.Pause;
        Viewer.NextImageClick(nil);
      end;
      if Msg.wParam = VK_ESCAPE then
      begin
        Viewer.Exit1Click(nil);
        Msg.message := 0;
      end;
    end;

    if Msg.message = WM_MOUSEWHEEL then
    begin
      Viewer.Pause;
      if Msg.wParam > 0 then
        Viewer.PreviousImageClick(nil)
      else
        Viewer.NextImageClick(nil);
    end;
  end;
end;

procedure TDirectShowForm.FormResize(Sender: TObject);
begin
  if FloatPanel = nil then
    Exit;
  FloatPanel.Top := 0;
  FloatPanel.Left := Left + ClientWidth - FloatPanel.Width;
end;

function TDirectShowForm.GetAlphaSteeps: Integer;
begin
  Result := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideSteps', 25), 1), 100);
end;

function TDirectShowForm.GetFormID: string;
begin
  Result := 'Viewer';
end;

procedure TDirectShowForm.SetFirstImage(Image: TBitmap);
var
  FX: TDDBltFx;
  R: TRect;
begin
  FillChar(Fx, SizeOf(FX), 0);
  FX.DwSize := SizeOf(FX);
  FX.DwFillColor := PackColor(0, BPP, RBM, GBM, BBM);
  R := ClientRect;
  FileLoaded := True;
  Buffer.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @Fx);
  CenterBmp(Buffer, Image, ClientRect);
  PrepareTransform(Buffer, Buffer);
  TransformAlpha(Offscreen, 0);
  UpdateSurface(Self);
  FForwardThreadExists := False;
end;

procedure TDirectShowForm.NewImage(Image: TBitmap);
var
  FX: TDDBltFx;
  R: TRect;
begin
  FillChar (FX, SizeOf(FX), 0);
  FX.dwSize := SizeOf(FX);
  FX.dwFillColor := PackColor(0, BPP, RBM, GBM, BBM);
  R := ClientRect;
  FileLoaded := True;
  Buffer.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @fx);
  CenterBmp(Buffer, Image, ClientRect);
  ReplaseTransform(Buffer);
  TransformAlpha(OffScreen, 0);
  UpdateSurface(self);
end;

procedure TDirectShowForm.DelayTimerTimer(Sender: TObject);
begin
  if FNowPaused then
    Exit;
  DelayTimer.Enabled := False;
  if Viewer <> nil then
    Viewer.Next_(Sender);
  LoadCurrentImage(False, True);
end;

procedure TDirectShowForm.BeginFade;
begin
  TransformAlpha(Offscreen, 0);
  UpdateSurface(Self);
  DelayTimer.Enabled := False;
  FadeTimer.Enabled := True;
  XAlphaCount := 0;
  AlphaCount := 0;
end;

procedure TDirectShowForm.FadeTimerTimer(Sender: TObject);
begin
  if not Visible then
    Exit;
  XAlphaCount := XAlphaCount + (PI / 2) / AlphaSteeps;
  AlphaCount := 255 - Round(255 * Sqr(Cos(XAlphaCount)));
  if XAlphaCount > PI / 2 then
  begin
    FNowPaused := False;
    FReadyAfterPause := False;
    DelayTimer.Enabled := True;
    FadeTimer.Enabled := False;
    FReady := False;
    if FNowPaused then
    begin
      FForwardThreadExists := True;
      Next(True);
    end;
    Exit;
  end else
  begin
    TransformAlpha(Offscreen, AlphaCount);
    UpdateSurface(Self);
  end;
end;

procedure TDirectShowForm.SetThreadImage(var Image: PByteArr);
var
  T: PByteArr;
begin
  T := TransSrc1;
  TransSrc1 := TransSrc2;
  TransSrc2 := Image;
  Image := T;
end;

procedure TDirectShowForm.Pause;
begin
  if FNowPaused then
    Exit;
  FNowPaused := True;
  SID := GetGUID;
  DelayTimer.Enabled := False;
  FReadyAfterPause := False;
end;

procedure TDirectShowForm.Play;
begin
  if FNowPaused then
  begin
    FReadyAfterPause := True;
    FNowPaused := False;
    Exit;
  end;
  DelayTimer.Enabled := True;
end;

procedure TDirectShowForm.Next(Force: Boolean);
begin
  if FNowPaused then
  begin
    FReadyAfterPause := True;
    FNowPaused := False;
    if not Force then
      Exit;
  end;

  FReadyAfterPause := False;
  if not Force then
    SID := GetGUID;

  AlphaCount := 255 - Round(255 * Sqr(Cos(XAlphaCount)));
  if AlphaCount < 30 then
    Exit;

  Inc(Viewer.CurrentFileNumber);
  if Viewer.CurrentFileNumber >= Viewer.CurrentInfo.Count then
    Viewer.CurrentFileNumber := 0;

  LoadCurrentImage(Force, True);
end;

procedure TDirectShowForm.Previous;
begin
  FNowPaused := False;
  FReadyAfterPause := False;
  SID := GetGUID;
  Dec(Viewer.CurrentFileNumber);
  if Viewer.CurrentFileNumber < 0 then
    Viewer.CurrentFileNumber := Viewer.CurrentInfo.Count - 1;
  LoadCurrentImage(False, False);
end;

procedure TDirectShowForm.LoadCurrentImage(XForward, Next: Boolean);
var
  Info: TDirectXSlideShowCreatorInfo;
  N: Integer;
begin
  if not XForward then
  begin
    if FForwardThreadExists and (ForwardFileName = Viewer.Item.FileName) then
    begin
      Ready := True;
      Exit;
    end else
    begin
      FForwardThreadExists := False;
    end;
  end;
  if XForward then
  begin
    N := Viewer.CurrentFileNumber;
    ForwardSID := GetGUID;
    if Next then
    begin
      Inc(N);
      if N >= Viewer.CurrentInfo.Count then
      N := 0;
    end else
    begin
      Dec(N);
      if N < 0 then
        N := Viewer.CurrentInfo.Count - 1;
    end;
    Info.FileName := Viewer.CurrentInfo[N].FileName;
    Info.Rotate := Viewer.CurrentInfo[N].Rotation;
    ForwardFileName := Info.FileName
  end else
  begin
    Info.FileName := Viewer.Item.FileName;
    Info.Rotate := Viewer.Item.Rotation;
  end;
  Info.CallBack := CallBack;
  Info.DirectDraw4 := DirectDraw4;
  Info.PrimarySurface := PrimarySurface;
  Info.Offscreen := Offscreen;
  Info.Clpr := Clpr;
  Info.BPP := BPP;
  Info.RBM := RBM;
  Info.GBM := GBM;
  Info.BBM := BBM;
  Info.TransSrc1 := TransSrc1;
  Info.TransSrc2 := TransSrc2;
  Info.TempSrc := nil;
  if XForward then
    Info.SID := ForwardSID
  else
    Info.SID := SID;

  Info.Manager := FManager;
  Info.Form := Self;
  DirectDraw4.CreateSurface (SurfaceDesc, Info.Buffer, nil);
  TDirectXSlideShowCreator.Create(Info, XForward, Next);
end;

procedure TDirectShowForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Release;
  DirectShowForm := nil;
end;

function TDirectShowForm.CallBack(CallbackInfo: TCallbackInfo): TDirectXSlideShowCreatorCallBackResult;
begin
  if Visible and Viewer.SlideShowNow then
  begin
    if not CallbackInfo.ForwardThread then
    begin
      if FNowPaused then
        Exit;
      DelayTimer.Enabled := False;
      if CallbackInfo.Direction then
      begin
        if Viewer <> nil then
          Viewer.Next_(nil)
      end else
      begin
        if Viewer <> nil then
          Viewer.Previous_(nil);
      end;
      LoadCurrentImage(false,CallbackInfo.Direction);
    end else
    begin
      if CallbackInfo.Direction then
      begin
        if Viewer <> nil then
          Viewer.Next_(nil)
      end else
      begin
        if Viewer <> nil then
          Viewer.Previous_(nil);
      end;
      LoadCurrentImage(true,CallbackInfo.Direction);
    end;
  end;
end;

procedure TDirectShowForm.SetReady(const Value: boolean);
begin
  FReady := Value;
end;

procedure TDirectShowForm.SetForwardThreadExists(const Value: boolean);
begin
  FForwardThreadExists := Value;
end;

procedure TDirectShowForm.SetForwardFileName(const Value: String);
begin
  FForwardFileName := Value;
end;

end.
