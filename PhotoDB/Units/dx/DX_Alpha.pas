unit DX_Alpha;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.Math,
  System.Win.ComObj,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,

  Dmitry.Utils.System,

  DDraw,

  uWinApi,
  uGUIDUtils,
  uDBForm,
  uDXUtils,
  uMemory,
  uSettings,
  uBitmapUtils,
  uVCLHelpers,
  uFormInterfaces;

type
  TForwardDirection = (fdNext, fdPrevious, fdCurrent);

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
    procedure StartLoadingThread(FileIndex: Integer; ID: TGUID);
    procedure Pause;
    procedure Play;
    procedure Next;
    procedure Previous;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FManager: TDirectXSlideShowCreatorManager;

    AlphaCount: Byte;
    XAlphaCount: Extended;
    FIsFadeEffect: Boolean;

    FID, FNextID: TGUID;
    FForwardDirection: TForwardDirection;
    FIsPaused: Boolean;

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
    procedure UpdateSurface(ParentControl: TControl);
    procedure PrepareTransform(Buffer1, Buffer2: IDirectDrawSurface4);
    procedure UnPrepareTransform;
    procedure ReplaseTransform(Buffer: IDirectDrawSurface4);
    procedure TransformAlpha(Buffer: IDirectDrawSurface4; Alpha: Integer);
    function GetAlphaSteps: Integer;
    procedure PrepaireImage(Directon: TForwardDirection);
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure LoadDirectX;
    procedure NextID;
    procedure NewID;
    property AlphaSteps: Integer read GetAlphaSteps;
  public
    { Public declarations }
    function IsValidThread(ID: TGUID): Boolean;
    function IsActualThread(ID: TGUID): Boolean;
    property IsPaused: Boolean read FIsPaused write FIsPaused;
  end;

var
  DirectShowForm: TDirectShowForm;

implementation

{$R *.DFM}

uses
  FloatPanelFullScreen,
  SlideShow,
  UnitDirectXSlideShowCreator;

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
  M, N, A, Msa, X1: Integer;
  C, C1: NativeInt;
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
        C := NativeInt((@(TransSrc1^[M]))^); // Пиксель первого источника.
        C1 := NativeInt((@(TransSrc2^[M]))^); // Пиксель второго источника.
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
        C := NativeInt((@(TransSrc1^[M]))^); // Пиксель первого источника.
        C1 := NativeInt((@(TransSrc2^[M]))^); // Пиксель второго источника.
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

procedure TDirectShowForm.FormCreate(Sender: TObject);
begin
  NewID;
  FForwardDirection := fdNext;
  FIsPaused := False;
  FIsFadeEffect := False;

  AlphaCount := 0;
  XAlphaCount := PI / 2;
  DelayTimer.Interval := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideDelay', 40), 1), 100) * 50;

  // show before creating surface because of DDSCL_SETFOCUSWINDOW flsg
  Show;
  LoadDirectX;

  if FloatPanel = nil then
    Application.CreateForm(TFloatPanel, FloatPanel);
  FormResize(Sender);

  DisableSleep;
end;

procedure TDirectShowForm.LoadDirectX;
var
  PP: Integer;
  DirectDraw2: IDirectDraw;
  Fx: TDDBltFx;
  R: TRect;
  PixelFormat: TDDPixelFormat;
  HR: HRESULT;
begin
  // По Create создаем DirectDraw и все провехности. Надо бы это делать по Resize
  // и после каждого IDirectDrawSurface4.IsLost, но я забил болт.
  DDrawInit;
  try
    // Создаем DirectDraw.
    HR := DirectDrawCreate(nil, DirectDraw2, nil);
    if Succeeded(HR) then
    begin
      // Запрашиваем интерфейс IDirectDraw4.
      DirectDraw2.QueryInterface(IID_IDirectDraw4, DirectDraw4);
      DirectDraw2.Release;
      DirectDraw2 := nil;

      DirectDraw4.SetCooperativeLevel(Handle, DDSCL_SETFOCUSWINDOW or DDSCL_EXCLUSIVE);
      // Основная (видимая) поверхность...
      FillChar(SurfaceDesc, Sizeof(SurfaceDesc), 0);

      DirectDraw4.SetCooperativeLevel (Handle, DDSCL_NORMAL);
      //Основная (видимая) поверхность...
      FillChar (SurfaceDesc, SizeOf (SurfaceDesc), 0);
      SurfaceDesc.dwSize := SizeOf (SurfaceDesc);
      SurfaceDesc.dwFlags := DDSD_CAPS;
      SurfaceDesc.ddsCaps.dwCaps := DDSCAPS_PRIMARYSURFACE;

      HR := DirectDraw4.CreateSurface(SurfaceDesc, PrimarySurface, nil);
      if Succeeded(HR) then
      begin
        // ...привязывается к главному окну через IDirectDrawClipper.
        // Поэтому создаем IDirectDrawClipper...
        DirectDraw4.CreateClipper(0, Clpr, nil);
        // ...связываем его с главным окном...
        Clpr.SetHWND(0, Handle);

        // ...а потОм - с видимой поверхностью.
        PrimarySurface.SetClipper(Clpr);

        // Определяем цветовой формат экрана...
        PixelFormat.DwSize := SizeOf(TDDPIXELFORMAT);
        HR := PrimarySurface.GetPixelFormat(PixelFormat);
        if Succeeded(HR) then
        begin
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
          HR := DirectDraw4.CreateSurface(SurfaceDesc, Offscreen, nil);
          if Succeeded(HR) then
          begin
            //Закрасим ее цветом фона (иначе на ней будет "снег").
            FillChar(fx, SizeOf(fx), 0);
            fx.dwSize := SizeOf(fx);
            fx.dwFillColor := PackColor(Color, BPP, RBM, GBM, BBM);
            R := ClientRect;
            Offscreen.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @fx);
            //Это - первый источник для преобразования.
            HR := DirectDraw4.CreateSurface (SurfaceDesc, Buffer, nil);
          end;
        end;
      end;
    end;
    OleCheck(HR);
  except
    on e: Exception do
      ShowMessage(Format(L('Error initializing graphics mode: %s'), [e.Message]));
  end;

  FManager := TDirectXSlideShowCreatorManager.Create;
end;

procedure TDirectShowForm.FormDestroy(Sender: TObject);
begin
  ShowMouse;
  DelayTimer.Enabled := False;
  FadeTimer.Enabled:= False;
  UnPrepareTransform;
  SystemParametersInfo(SPI_SCREENSAVERRUNNING, 0, nil, 0);

  DirectXSlideShowCreatorManagers.DestroyManager(FManager);

  EnableSleep;
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
  FbImage := Viewer.CurrentFullImage;

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
  PrepaireImage(FForwardDirection);

  DelayTimer.Enabled := True;
  DelayTimer.Tag := 1;
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

procedure TDirectShowForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseTimer.Enabled := True;
  if (Abs(FOldPoint.X - X) > 5) or (Abs(FOldPoint.Y - Y) > 5) then
  begin
    ShowMouse;
    FOldPoint := Point(X, Y);
    MouseTimer.Restart
  end;
end;

procedure TDirectShowForm.FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  ShowMouse;
  MouseTimer.Enabled := False;
  Viewer.ShowPopup(ClientToScreen(MousePos).X, ClientToScreen(MousePos).Y);
end;

procedure TDirectShowForm.FormClick(Sender: TObject);
begin
  if Viewer = nil then
    Exit;
  Viewer.Pause;
  Viewer.NextImage;
end;

procedure TDirectShowForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowMouse;
  MouseTimer.Restart;
end;

procedure TDirectShowForm.HideMouse;
var
  CState: Integer;
  P: TPoint;
begin      
  GetCursorPos(P);
  if not PtInRect(BoundsRect, P) then
    Exit;
  CState := ShowCursor(True);
  while Cstate >= 0 do
    Cstate := ShowCursor(False);
  if FloatPanel <> nil then
    FloatPanel.Hide;
  SetFocus;
end;

procedure TDirectShowForm.ShowMouse;
var
  Cstate: Integer;
begin
  Cstate := ShowCursor(True);
  while CState < 0 do
    CState := ShowCursor(True);
  if Viewer.IsSlideShowNow then
    if FloatPanel <> nil then
      FloatPanel.Show;
end;

procedure TDirectShowForm.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);

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

  if CanProcessMessage and (Msg.message = WM_SYSKEYDOWN) then
    Msg.Message := 0;

  if (CurrentViewer <> nil) and CanProcessMessage then
  begin
    if Msg.message = WM_KEYDOWN then
    begin
      if Msg.wParam = VK_LEFT then
      begin
        Viewer.Pause;
        Viewer.PreviousImage;
      end;
      if (Msg.wParam = VK_RIGHT) or (Msg.wParam = VK_SPACE) then
      begin
        Viewer.Pause;
        Viewer.NextImage;
      end;
      if Msg.wParam = VK_ESCAPE then
      begin
        Viewer.CloseActiveView;
        Msg.message := 0;
      end;
    end;

    if Msg.message = WM_MOUSEWHEEL then
    begin
      Viewer.Pause;
      if NativeInt(Msg.wParam) > 0 then
        Viewer.PreviousImage
      else
        Viewer.NextImage;
    end;
  end;
end;

procedure TDirectShowForm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled := False;
  if DelayTimer.Tag = 1 then
  begin
    DelayTimer.Tag := 0;
    Viewer.ImageIndex := Viewer.ImageIndex + 1;
    if Viewer.ImageIndex >= Viewer.ImagesCount then
      Viewer.ImageIndex := 0;

    NextID;
    Exit;
  end;

  Viewer.NextImage;
end;

procedure TDirectShowForm.FormResize(Sender: TObject);
begin
  if FloatPanel = nil then
    Exit;
  FloatPanel.Top := 0;
  FloatPanel.Left := Left + ClientWidth - FloatPanel.Width;
end;

function TDirectShowForm.GetAlphaSteps: Integer;
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
  Buffer.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @Fx);
  CenterBmp(Buffer, Image, ClientRect);
  PrepareTransform(Buffer, Buffer);
  TransformAlpha(Offscreen, 0);
  UpdateSurface(Self);
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
  Buffer.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @fx);
  CenterBmp(Buffer, Image, ClientRect);
  ReplaseTransform(Buffer);
  BeginFade;
end;

procedure TDirectShowForm.BeginFade;
begin
  TransformAlpha(OffScreen, 0);
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
  XAlphaCount := XAlphaCount + (PI / 2) / AlphaSteps;
  AlphaCount := 255 - Round(255 * Sqr(Cos(XAlphaCount)));

  if XAlphaCount > PI / 2 then
  begin
    FadeTimer.Enabled := False;

    PrepaireImage(FForwardDirection);
    if not FIsPaused then
      DelayTimer.Enabled := True;

    Exit;
  end else
  begin
    TransformAlpha(OffScreen, AlphaCount);
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

procedure TDirectShowForm.NewID;
begin
  FID := GetGUID;
  FNextID := GetGUID;
end;

procedure TDirectShowForm.NextID;
begin
  FID := FNextID;
  FNextID := GetGUID;
end;

procedure TDirectShowForm.Pause;
begin
  DelayTimer.Enabled := False;
  FIsPaused := True;
end;

procedure TDirectShowForm.Play;
begin
  Next;
  FIsPaused := False;
end;

procedure TDirectShowForm.Next;
begin
  Viewer.ImageIndex := Viewer.ImageIndex + 1;
  if Viewer.ImageIndex >= Viewer.ImagesCount then
    Viewer.ImageIndex := 0;

  if FForwardDirection <> fdNext then
  begin
    NewID;
    FForwardDirection := fdNext;
    PrepaireImage(fdCurrent);
  end else
  begin
    NextId;
    PrepaireImage(FForwardDirection);
  end;

end;

procedure TDirectShowForm.Previous;
begin
  Viewer.ImageIndex := Viewer.ImageIndex - 1;
  if Viewer.ImageIndex < 0 then
    Viewer.ImageIndex := Viewer.ImagesCount - 1;

  if FForwardDirection <> fdPrevious then
  begin
    NewID;
    FForwardDirection := fdPrevious;
    PrepaireImage(fdCurrent);
  end else
  begin
    NextId;
    PrepaireImage(FForwardDirection);
  end;

end;

procedure TDirectShowForm.PrepaireImage(Directon: TForwardDirection);
var
  N: Integer;
begin
  N := Viewer.ImageIndex;
  if Directon = fdNext then
  begin
    Inc(N);
    if N >= Viewer.ImagesCount then
      N := 0;
  end;
  if Directon = fdPrevious then
  begin
    Dec(N);
    if N < 0 then
      N := Viewer.ImagesCount - 1;
  end;
  if Directon = fdCurrent then
    StartLoadingThread(N, FID)
  else
    StartLoadingThread(N, FNextID);
end;

procedure TDirectShowForm.StartLoadingThread(FileIndex: Integer; ID: TGUID);
var
  Info: TDirectXSlideShowCreatorInfo;
begin
  Info.FileName := Viewer.Images[FileIndex].FileName;
  Info.Rotate := Viewer.Images[FileIndex].Rotation;

  if not FManager.ThreadExists(ID) then
  begin
    Info.SID := ID;
    Info.Manager := FManager;
    Info.Form := Self;
    TDirectXSlideShowCreator.Create(Info);
  end;
end;

procedure TDirectShowForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DirectShowForm := nil;
  Release;
end;

function TDirectShowForm.IsActualThread(ID: TGUID): Boolean;
begin
  Result := IsEqualGUID(FID, ID);
end;

function TDirectShowForm.IsValidThread(ID: TGUID): Boolean;
begin
  Result := IsActualThread(ID) or IsEqualGUID(FNextID, ID);
end;

end.

