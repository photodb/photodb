unit UnitDirectXSlideShowCreator;

interface

uses
  Windows, Classes, Graphics, GraphicCrypt, Dolphin_DB, Forms, DDraw,
  GraphicsCool, Language, Effects, UnitDBCommonGraphics, uMemory,
  ImageConverting;

type
  TDirectXSlideShowCreator = class(TThread)
  private
    FInfo: TDirectXSlideShowCreatorInfo;
    Graphic: TGraphic;
    Image: TBitmap;
    ScreenImage: TBitmap;
    FilePassword: string;
    FCallBackAction: Byte;
    FSynchBitmap: TBitmap;
    R: TRect;
    Fx: TDDBltFx;
    FXForward: Boolean;
    FNext: Boolean;
    BooleanParam: Boolean;
    Paused: Boolean;
    { Private declarations }
  protected
    procedure DoCallBack(Action: Byte);
    procedure DoCallBackSynch;
    procedure Execute; override;
    function PackColor(Color: TColor): TColor;
    function CenterBmp(Buffer: IDirectDrawSurface4; Bitmap: TBitmap; Rect: TRect): TRect;
    procedure ReplaceTransform;
    procedure DoExit;
    procedure DoExitSynch;
    procedure CenterBmpSynch;
    procedure Btl;
    function Ready: Boolean;
    function ExitReady: Boolean;
    procedure IFPause;
  public
    constructor Create(Info: TDirectXSlideShowCreatorInfo; XForward, Next: Boolean);
    destructor Destroy; override;
  end;

  TArThreads = array of TDirectXSlideShowCreator;

  TThreadDestroyDXObjects = record
    DirectDraw4: IDirectDraw4;
    PrimarySurface: IDirectDrawSurface4;
    Offscreen: IDirectDrawSurface4;
    Buffer: IDirectDrawSurface4;
    Clpr: IDirectDrawClipper;
    TransSrc1, TransSrc2: PByteArr;
    Form: TForm;
  end;

  //TODO: Synchronisation!!!
  TDirectXSlideShowCreatorManager = class(TObject)
  private
    FThreads: TList;
    FObjects: TThreadDestroyDXObjects;
    FFreeOnExit: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddThread(Thread: TDirectXSlideShowCreator);
    procedure RemoveThread(Thread: TDirectXSlideShowCreator);
    function IsThread(Thread: TDirectXSlideShowCreator): Boolean;
    function ThreadCount: Integer;
    procedure SetDXObjects(Objects: TThreadDestroyDXObjects);
    procedure FreeOnExit;
  end;

const
  CallBack_Failture = 0;
  CallBack_SetImage = 1;
  CallBack_Next = 2;

implementation

uses DX_Alpha, SlideShow, SysUtils;

{ TDirectXSlideShowCreator }

function TDirectXSlideShowCreator.CenterBmp(Buffer: IDirectDrawSurface4;
  Bitmap: TBitmap; Rect: TRect): TRect;
begin
  FSynchBitmap := Bitmap;
  Synchronize(CenterBmpSynch);
end;

procedure TDirectXSlideShowCreator.CenterBmpSynch;
var
  Dc: HDC;
begin
  if (FSynchBitmap = nil) or (FInfo.Buffer = nil) then
    Exit;

  FInfo.Buffer.GetDC(DC);
  BitBlt(Dc, 0, 0, Screen.Width, Screen.Height, FSynchBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  FInfo.Buffer.ReleaseDC(DC);
end;

constructor TDirectXSlideShowCreator.Create(Info: TDirectXSlideShowCreatorInfo; XForward, Next : Boolean);
begin
  inherited Create(False);
  FInfo := Info;
  FXForward := XForward;
  FNext := Next;
  FreeOnTerminate := True;
  (FInfo.Manager as TDirectXSlideShowCreatorManager).AddThread(Self);
end;

procedure TDirectXSlideShowCreator.DoCallBack(Action : Byte);
begin
  FCallBackAction := Action;
  if Action = CallBack_Next then
    Sleep(100);
  Synchronize(DoCallBackSynch)
end;

procedure TDirectXSlideShowCreator.DoCallBackSynch;
var
  CallbackInfo: TCallbackInfo;
begin
  CallbackInfo.Action := FCallBackAction;
  CallbackInfo.ForwardThread := False;
  if (CallBack_Next = CallbackInfo.Action) and FXForward then
  begin
    DirectShowForm.ForwardThreadExists := False;
    CallbackInfo.ForwardThread := True;
  end;
  CallbackInfo.Direction := FNext;
  FInfo.CallBack(CallbackInfo);
end;

procedure TDirectXSlideShowCreator.DoExit;
begin
  Synchronize(IFPause);
  Paused := BooleanParam;
  if FXForward or Paused then
  begin
    repeat
      if ExitReady or Ready then
        Break;

      Sleep(50);
    until False;
  end;
  Synchronize(DoExitSynch);
  FInfo.Buffer.Release;
  FreeMem(FInfo.TempSrc)
end;

procedure TDirectXSlideShowCreator.DoExitSynch;
begin
 if DirectShowForm<>nil then
 if IsEqualGUID(DirectShowForm.SID, FInfo.SID) or (Ready and FXForward) or (Paused and Ready) then
 begin
  DirectShowForm.SetThreadImage(FInfo.TempSrc);
  DirectShowForm.BeginFade;
  DirectShowForm.ForwardThreadExists:=false;
 end;
end;

procedure TDirectXSlideShowCreator.Execute;
var
  W, H: Integer;
  LoadingPicture: Boolean;
  Zoom: Extended;
  TempImage: TBitmap;
  GraphicClass : TGraphicClass;

const
  Text_out = TEXT_MES_CREATING + '...';
  Text_error_out = TEXT_MES_UNABLE_SHOW_FILE;

begin
  LoadingPicture := True;
  try
    if ValidCryptGraphicFile(FInfo.FileName) then
    begin
      FilePassword := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
      if FilePassword = '' then
      begin
        LoadingPicture := False;
        Exit;
      end;
    end;

    if LoadingPicture then
    begin
      GraphicClass := GetGraphicClass(ExtractFileExt(FInfo.FileName), False);

      if GraphicClass = nil then
      begin
        LoadingPicture := False;
        Exit;
      end;

      Graphic := GraphicClass.Create;
      try
        if ValidCryptGraphicFile(FInfo.FileName) then
        begin
          F(Graphic);
          Graphic := DeCryptGraphicFile(FInfo.FileName, FilePassword);
        end else
          Graphic.LoadFromFile(FInfo.FileName);
        JPEGScale(Graphic, Screen.Width, Screen.Height);

        Image := TBitmap.Create;
        try
          AssignGraphic(Image, Graphic);
          F(Graphic);




 ScreenImage := TBitmap.Create;
 ScreenImage.Canvas.Pen.Color:=0;
 ScreenImage.Canvas.Brush.Color:=0;
 ScreenImage.Width:=Screen.Width;
 ScreenImage.Height:=Screen.Height;
 if LoadingPicture then
 begin
  w:=Image.Width;
  h:=Image.Height;
  Case FInfo.Rotate of
   DB_IMAGE_ROTATE_0 :
    begin
     ProportionalSize(Screen.Width,Screen.Height,w,h);
     if Image.Width<>0 then
     Zoom:=w/Image.Width else Zoom:=1;

     if (Zoom<ZoomSmoothMin) or UseOnlyDefaultDraw then
     StretchCoolEx0(Screen.Width div 2-w div 2, Screen.Height div 2-h div 2,w,h,Image,ScreenImage,$000000)
     else begin
      XFillRect(Screen.Width div 2-w div 2, Screen.Height div 2-h div 2,w,h,ScreenImage,$000000);
      TempImage := TBitmap.Create;
      TempImage.PixelFormat:=pf24bit;
      TempImage.Width:=w;
      TempImage.Height:=h;
      SmoothResize(w,h,Image,TempImage);
      ThreadDraw(tempImage,ScreenImage,Screen.Width div 2-w div 2, Screen.Height div 2-h div 2);
      TempImage.Free;
     end;

    end;
   DB_IMAGE_ROTATE_270 :
    begin
     ProportionalSize(Screen.Width,Screen.Height,h,w);
     StretchCoolEx270(Screen.Width div 2-h div 2, Screen.Height div 2-w div 2,w,h,Image,ScreenImage,$000000)
    end;
   DB_IMAGE_ROTATE_90 :
    begin
     ProportionalSize(Screen.Width,Screen.Height,h,w);
     StretchCoolEx90(Screen.Width div 2-h div 2, Screen.Height div 2-w div 2,w,h,Image,ScreenImage,$000000)
    end;
   DB_IMAGE_ROTATE_180 :
    begin
     ProportionalSize(Screen.Width,Screen.Height,w,h);
     StretchCoolEx180(Screen.Width div 2-w div 2, Screen.Height div 2-h div 2,w,h,Image,ScreenImage,$000000)
    end;
   end;
 end else
 begin
  ScreenImage.Canvas.Font.Color:=$FFFFFF;
  ScreenImage.Canvas.TextOut(ScreenImage.Width div 2-ScreenImage.Canvas.TextWidth(text_error_out) div 2,ScreenImage.Height div 2-ScreenImage.Canvas.Textheight(text_error_out) div 2,text_error_out);
  ScreenImage.Canvas.TextOut(ScreenImage.Width div 2-ScreenImage.Canvas.TextWidth(FInfo.FileName) div 2,ScreenImage.Height div 2-ScreenImage.Canvas.Textheight(text_error_out) div 2+ScreenImage.Canvas.Textheight(FInfo.FileName)+4,FInfo.FileName);
 end;
 Image.Free;
 try
  FillChar (fx, sizeof (fx), 0);
  fx.dwSize := sizeof (fx);
  fx.dwFillColor := PackColor (0);
  r := Rect(0,0,ScreenImage.Width,ScreenImage.Height);
  Synchronize(Btl);
  CenterBmp (FInfo.Buffer, ScreenImage, Rect(0,0,ScreenImage.Width,ScreenImage.Height));
  ScreenImage.free;
  ReplaceTransform;
 except
 end;



        finally
          Image.Free;
        end;

      finally
        F(Graphic);
        LoadingPicture := False;
      end;
    end;

  finally
    DoExit;
  end;
end;

function TDirectXSlideShowCreator.PackColor(Color: TColor): TColor;
var
  R, G, B: Integer;
begin
  Color := ColorToRGB(Color);
  B := (Color shr 16) and $FF;
  G := (Color shr 8) and $FF;
  R := Color and $FF;
  if FInfo.BPP = 16 then
  begin
    R := R shr 3;
    G := G shr 3;
    B := B shr 3;
  end;
  Result := (R shl FInfo.RBM) or (G shl FInfo.GBM) or (B shl FInfo.BBM);
end;

procedure UnLock (Buffer: IDirectDrawSurface4);
begin
  if Buffer = nil then
    Exit;
  Buffer.UnLock(nil);
end;

procedure LockRead (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then exit;
  ZeroMemory (@SurfaceDesc, sizeof (TDDSurfaceDesc2));
  SurfaceDesc.dwSize := sizeof (TDDSurfaceDesc2);
  Buffer.Lock (nil, SurfaceDesc, DDLOCK_WAIT or DDLOCK_SURFACEMEMORYPTR or DDLOCK_READONLY or DDLOCK_NOSYSLOCK, 0);
  if SurfaceDesc.lpSurface = nil then
     UnLock (Buffer);
end;

procedure LockWrite (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then exit;
  ZeroMemory (@SurfaceDesc, sizeof (TDDSurfaceDesc2));
  SurfaceDesc.dwSize := sizeof (TDDSurfaceDesc2);
  Buffer.Lock (nil, SurfaceDesc, DDLOCK_WAIT or DDLOCK_SURFACEMEMORYPTR or DDLOCK_WRITEONLY, 0);
  if SurfaceDesc.lpSurface = nil then
     UnLock (Buffer);
end;

procedure TDirectXSlideShowCreator.ReplaceTransform;
 var
   Dd: TDDSurfaceDesc2;
   TransSize, TransPitch, TransHeight: Integer;
 begin
   if FInfo.Buffer = nil then
     Exit;
   LockRead(FInfo.Buffer, Dd);
   TransPitch := Dd.LPitch;
   TransHeight := Dd.DwHeight;
   TransSize := TransHeight * TransPitch;
   if FInfo.TempSrc = nil then
     GetMem(FInfo.TempSrc, TransSize);
   CopyMemory(FInfo.TempSrc, Dd.LpSurface, TransSize - 1);
   UnLock(FInfo.Buffer);
 end;

destructor TDirectXSlideShowCreator.Destroy;
begin
   (FInfo.Manager as TDirectXSlideShowCreatorManager).RemoveThread(Self);
   inherited;
end;

procedure TDirectXSlideShowCreator.Btl;
begin
  if FInfo.Buffer <> nil then
    FInfo.Buffer.Blt(@R, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @Fx);
end;

function TDirectXSlideShowCreator.Ready: boolean;
begin
  Result:=false;
  if Paused then
  begin
    Result:=DirectShowForm.FReadyAfterPause;
    exit;
  end;
  if DirectShowForm<>nil then
    if IsEqualGUID(DirectShowForm.ForwardSID, FInfo.SID) then
      Result:=DirectShowForm.Ready;
end;

function TDirectXSlideShowCreator.ExitReady: boolean;
begin
 if DirectShowForm=nil then
 begin
  Result:=true;
  exit;
 end;
 if Paused then
 begin
  Result:=not DirectShowForm.FNowPaused;
  exit;
 end;
 if (not IsEqualGUID(DirectShowForm.ForwardSID, FInfo.SID) and FXForward) or (DirectShowForm=nil) then
 Result:=true else Result:=false;
end;

procedure TDirectXSlideShowCreator.IFPause;
begin
 if DirectShowForm=nil then
 begin
  BooleanParam:=true;
  exit;
 end;
 BooleanParam:=DirectShowForm.FNowPaused;
end;

{ TDirectXSlideShowCreatorManager }

procedure TDirectXSlideShowCreatorManager.AddThread(
Thread: TDirectXSlideShowCreator);
begin
  if FThreads.IndexOf(Thread) < 0 then
    FThreads.Add(Thread);

end;

constructor TDirectXSlideShowCreatorManager.Create;
begin
  FThreads := TList.Create;
  FFreeOnExit := False;
end;

destructor TDirectXSlideShowCreatorManager.Destroy;
begin
  F(FThreads);
  if FFreeOnExit then
  begin
    R(FObjects.Buffer);
    R(FObjects.Offscreen);
    R(FObjects.PrimarySurface);
    R(FObjects.Clpr);
    R(FObjects.DirectDraw4);
    FObjects.Form.Close;
  end;
  inherited;
end;

procedure TDirectXSlideShowCreatorManager.FreeOnExit;
begin
  FFreeOnExit := True;
end;

function TDirectXSlideShowCreatorManager.IsThread(
  Thread: TDirectXSlideShowCreator): Boolean;
begin
  Result := FThreads.IndexOf(Thread) > -1;
end;

procedure TDirectXSlideShowCreatorManager.RemoveThread(
  Thread: TDirectXSlideShowCreator);
begin
  FThreads.Remove(Thread);
  if (FThreads.Count = 0) and FFreeOnExit then
    Free;
end;

procedure TDirectXSlideShowCreatorManager.SetDXObjects(Objects : TThreadDestroyDXObjects);
begin
  FObjects:=Objects;
end;

function TDirectXSlideShowCreatorManager.ThreadCount: Integer;
begin
  Result := FThreads.Count;
end;

end.
