unit uDXUtils;

interface

uses
  Windows, Graphics, Classes, Forms, SyncObjs, DDraw, uDBForm, uDBThread,
  uMemory, uMemoryEx;

type
  TByteArr = array [0 .. 0] of Byte;
  PByteArr = ^TByteArr;

type
  TCallbackInfo = record
    Action: Byte;
    ForwardThread: Boolean;
    Direction: Boolean;
  end;

type
  TDirectXSlideShowCreatorCallBackResult = record
    Action: Byte;
    FileName: string;
    Result: Integer;
  end;

type
  TDirectXSlideShowCreatorCallBack = function(CallbackInfo: TCallbackInfo)
    : TDirectXSlideShowCreatorCallBackResult of object;

type
  TDirectXSlideShowCreatorManager = class;

  TDirectXSlideShowCreatorInfo = record
    FileName: string;
    Rotate: Integer;
    CallBack: TDirectXSlideShowCreatorCallBack;
    DirectDraw4: IDirectDraw4;
    PrimarySurface: IDirectDrawSurface4;
    Offscreen: IDirectDrawSurface4;
    Buffer: IDirectDrawSurface4;
    Clpr: IDirectDrawClipper;
    BPP, RBM, GBM, BBM: Integer;
    TransSrc1, TransSrc2, TempSrc: PByteArr;
    SID: TGUID;
    Manager: TDirectXSlideShowCreatorManager;
    Form: TDBForm;
  end;

  TThreadDestroyDXObjects = record
    DirectDraw4: IDirectDraw4;
    PrimarySurface: IDirectDrawSurface4;
    Offscreen: IDirectDrawSurface4;
    Buffer: IDirectDrawSurface4;
    Clpr: IDirectDrawClipper;
    TransSrc1, TransSrc2: PByteArr;
    Form: TDBForm;
  end;

  TDirectXSlideShowCreatorManager = class(TObject)
  private
    FThreads: TList;
    FObjects: TThreadDestroyDXObjects;
    FFreeOnExit: Boolean;
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddThread(Thread: TDBThread);
    procedure RemoveThread(Thread: TDBThread);
    function IsThread(Thread: TDBThread): Boolean;
    function ThreadCount: Integer;
    procedure SetDXObjects(Objects: TThreadDestroyDXObjects);
    procedure FreeOnExit;
  end;

  TDirectXSlideShowCreatorManagers = class(TObject)
  private
    FManagers: TList;
    FSync: TCriticalSection;
    procedure RegisterManager(Manager: TDirectXSlideShowCreatorManager);
    procedure UnregisterManager(Manager: TDirectXSlideShowCreatorManager);
  public
    constructor Create;
    destructor Destroy; override;
    procedure DestroyManager(Manager: TDirectXSlideShowCreatorManager);
    procedure RemoveThread(Manager: TDirectXSlideShowCreatorManager; Thread: TDBThread);
    procedure Lock;
    procedure Unlock;
  end;

procedure LockRead (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
procedure LockWrite (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
function PackColor (Color: TColor; BPP, RBM, GBM, BBM: Byte): TColor; inline;
function CenterBmp(Buffer: IDirectDrawSurface4; Bitmap: TBitmap; Rect: TRect): TRect;
procedure UnLock (Buffer: IDirectDrawSurface4);

function DirectXSlideShowCreatorManagers: TDirectXSlideShowCreatorManagers;

implementation

var
  FDirectXSlideShowCreatorManagers: TDirectXSlideShowCreatorManagers = nil;

function DirectXSlideShowCreatorManagers: TDirectXSlideShowCreatorManagers;
begin
  if FDirectXSlideShowCreatorManagers = nil then
    FDirectXSlideShowCreatorManagers := TDirectXSlideShowCreatorManagers.Create;

  Result := FDirectXSlideShowCreatorManagers;
end;

//Разблокировка поверхности.
//НЕ ЗАХОДИТЕ ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ МЕЖДУ Lock и UnLock! ВСЕ ПОВИСНЕТ!
procedure UnLock (Buffer: IDirectDrawSurface4);
begin
  if Buffer = nil then exit;
  Buffer.UnLock (nil);
end;

//Упаковка цвета с учетом цветового разрешения видеоадаптера
//(параметы RBM, GBM и BBM запомнили при создании DirectDraw)
function PackColor (Color: TColor; BPP, RBM, GBM, BBM: Byte): TColor; inline;
var
  r, g, b: integer;
begin
  Color := ColorToRGB (Color);
  b := (Color shr 16) and $FF;
  G := (Color shr 8) and $FF;
  R := Color and $FF;
  if BPP = 16 then
  begin
    R := R shr 3;
    G := G shr 3;
    B := B shr 3;
  end;
  Result := (R shl RBM) or (G shl GBM) or (B shl BBM);
end;

// Блокировка поверхности НА ЧТЕНИЕ. Можно, конечно, блокировать ВООБЩЕ, но это
// длительная операция, а указание флагов DDLOCK_READONLY или DDLOCK_WRITEONLY
//вроде бы позволяет системе что-то там оптимизировать...
//НЕ ЗАХОДИТЕ ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ МЕЖДУ Lock и UnLock! ВСЕ ПОВИСНЕТ!
procedure LockRead (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then exit;
  ZeroMemory (@SurfaceDesc, sizeof (TDDSurfaceDesc2));
  SurfaceDesc.dwSize := sizeof (TDDSurfaceDesc2);
  Buffer.Lock (nil, SurfaceDesc, DDLOCK_WAIT or DDLOCK_SURFACEMEMORYPTR or DDLOCK_READONLY, 0);
  // В SurfaceDesc.lpSurface должны выгрузиться байты поверхности.
  if SurfaceDesc.lpSurface = nil then
     UnLock (Buffer);
end;

//Блокировка поверхности НА ЗАПИСЬ.
//НЕ ЗАХОДИТЕ ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ МЕЖДУ Lock и UnLock! ВСЕ ПОВИСНЕТ!
procedure LockWrite (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then exit;
  ZeroMemory (@SurfaceDesc, sizeof (TDDSurfaceDesc2));
  SurfaceDesc.dwSize := sizeof (TDDSurfaceDesc2);
  Buffer.Lock (nil, SurfaceDesc, DDLOCK_WAIT or DDLOCK_SURFACEMEMORYPTR or DDLOCK_WRITEONLY, 0);
  if SurfaceDesc.LpSurface = nil then
    UnLock(Buffer);
end;

// А это - копирование картинки из объекта Delphi TBitmap на поверхность DirectDraw.
// Картинка масштабируется так, чтобы заполнить наибОльшую часть прямоугольника Rect,
// после чего размещается по центру. Возвращает прямоугольник, РЕАЛЬНО занятый картинкой.
function CenterBmp(Buffer: IDirectDrawSurface4; Bitmap: TBitmap; Rect: TRect): TRect;
var
  Dc: HDC;
  W0, H0: Integer;
  W, H: Double;
begin
  if (Buffer = nil) or (Bitmap = nil) then
     Exit;

  // Масштабируем и центрируем.
  w0 := Bitmap.Width;
  h0 := Bitmap.Height;
  w := Rect.Right - Rect.Left;
  h := 1.0 * h0 * w / w0;
  if h > Rect.Bottom - Rect.Top then
  begin
    h := Rect.Bottom - Rect.Top;
    w := 1.0 * w0 * h / h0;
  end;
  Rect.Top := trunc ((Rect.Bottom + Rect.Top - h) / 2.0);
  Rect.Left := trunc ((Rect.Right + Rect.Left - w) / 2.0);
  Rect.Right := trunc (Rect.Left + w);
  Rect.Bottom := trunc (Rect.Top + h);
  //Получаем device context поверхности. Device context картинки - TBitmap.Canvas.Handle.
  //НЕ ЗАХОДИТЕ СЮДА ОТЛАДЧИКОМ В ПОШАГОВОМ РЕЖИМЕ! ВСЕ ПОВИСНЕТ!
  Buffer.GetDC (DC);
  try
    //Копируем.
    BitBlt(DC, 0, 0, Bitmap.Width, Bitmap.Height, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    //ДОЛЖНЫ освободить device context поверхности!
    Buffer.ReleaseDC (DC);
  end;
  Result := Classes.Rect(0,0,Bitmap.Width,Bitmap.Height);
end;

{ TDirectXSlideShowCreatorManager }

procedure TDirectXSlideShowCreatorManager.AddThread(Thread: TDBThread);
begin
  FSync.Enter;
  try
    if FThreads.IndexOf(Thread) < 0 then
      FThreads.Add(Thread);
  finally
    FSync.Leave;
  end;
end;

constructor TDirectXSlideShowCreatorManager.Create;
begin
  FSync := TCriticalSection.Create;
  FThreads := TList.Create;
  FFreeOnExit := False;
  DirectXSlideShowCreatorManagers.RegisterManager(Self);
end;

destructor TDirectXSlideShowCreatorManager.Destroy;
begin
  DirectXSlideShowCreatorManagers.UnregisterManager(Self);
  F(FThreads);
  F(FSync);
  inherited;
end;

procedure TDirectXSlideShowCreatorManager.FreeOnExit;
begin
  FFreeOnExit := True;
end;

function TDirectXSlideShowCreatorManager.IsThread(Thread: TDBThread): Boolean;
begin
  FSync.Enter;
  try
    Result := FThreads.IndexOf(Thread) > -1;
  finally
    FSync.Leave;
  end;
end;

procedure TDirectXSlideShowCreatorManager.RemoveThread(Thread: TDBThread);
begin
  FSync.Enter;
  try
    FThreads.Remove(Thread);
    if (FThreads.Count = 0) and FFreeOnExit then
      Free;
  finally
    if FSync <> nil then
      FSync.Leave;
  end;
end;

procedure TDirectXSlideShowCreatorManager.SetDXObjects(Objects: TThreadDestroyDXObjects);
begin
  FObjects := Objects;
end;

function TDirectXSlideShowCreatorManager.ThreadCount: Integer;
begin
  FSync.Enter;
  try
    Result := FThreads.Count;
  finally
    FSync.Leave;
  end;
end;

{ TDirectXSlideShowCreatorManagers }

constructor TDirectXSlideShowCreatorManagers.Create;
begin
  FManagers := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TDirectXSlideShowCreatorManagers.Destroy;
begin
  FreeList(FManagers);
  F(FSync);
  inherited;
end;

procedure TDirectXSlideShowCreatorManagers.DestroyManager(
  Manager: TDirectXSlideShowCreatorManager);
begin
  FSync.Enter;
  try
    if FManagers.IndexOf(Manager) > 0 then
    begin
      if Manager.ThreadCount <> 0 then
      begin
        Manager.FreeOnExit;
        Exit;
      end;
    end;

    FManagers.Remove(Manager);
    Manager.Free;
  finally
    FSync.Leave;
  end;
end;

procedure TDirectXSlideShowCreatorManagers.Lock;
begin
  FSync.Enter;
end;

procedure TDirectXSlideShowCreatorManagers.RegisterManager(
  Manager: TDirectXSlideShowCreatorManager);
begin
  FSync.Enter;
  try
    FManagers.Add(Manager);
  finally
    FSync.Leave;
  end;
end;

procedure TDirectXSlideShowCreatorManagers.RemoveThread(
  Manager: TDirectXSlideShowCreatorManager; Thread: TDBThread);
begin
  FSync.Enter;
  try
    if FManagers.IndexOf(Manager) > -1 then
      Manager.RemoveThread(Thread);
  finally
    FSync.Leave;
  end;
end;

procedure TDirectXSlideShowCreatorManagers.Unlock;
begin
  FSync.Leave;
end;

procedure TDirectXSlideShowCreatorManagers.UnregisterManager(
  Manager: TDirectXSlideShowCreatorManager);
begin
  FSync.Enter;
  try
    FManagers.Remove(Manager);
  finally
    FSync.Leave;
  end;
end;

initialization

finalization

  F(FDirectXSlideShowCreatorManagers);

end.
