unit UnitDirectXSlideShowCreator;

interface

uses
  Windows, Classes, Graphics, GraphicCrypt, Dolphin_DB, Forms, DDraw,
  GraphicsCool, Language, Effects, UnitDBCommonGraphics;

type
  TDirectXSlideShowCreator = class(TThread)
  private
  FInfo : TDirectXSlideShowCreatorInfo;
  Picture : TPicture;
  Image : TBitmap;
  ScreenImage : TBitmap;
  FilePassword : String;
  FCallBackAction : Byte;
  FSynchBitmap : TBitmap;
  r: TRect;
  fx: TDDBltFx;
  FXForward : Boolean;
  FNext : boolean;
  BooleanParam : Boolean;
  Paused : Boolean;
    { Private declarations }
  protected
   procedure DoCallBack(Action : Byte);
   procedure DoCallBackSynch;
   procedure Execute; override;
   function PackColor(Color: TColor): TColor;
   function CenterBmp (Buffer: IDirectDrawSurface4; Bitmap: TBitmap; Rect: TRect): TRect;
   procedure ReplaceTransform;
   procedure DoExit;
   procedure DoExitSynch;
   procedure CenterBmpSynch;
   procedure Btl;
   function Ready : boolean;
   function ExitReady : boolean;
   procedure IFPause;
  public
   constructor Create(CreateSuspennded: Boolean; Info : TDirectXSlideShowCreatorInfo; XForward, Next : Boolean);
   destructor Destroy; override;
  end;

  TArThreads = array of TDirectXSlideShowCreator;

  TThreadDestroyDXObjects = record
   DirectDraw4: IDirectDraw4;
   PrimarySurface: IDirectDrawSurface4;
   Offscreen: IDirectDrawSurface4;
   Buffer : IDirectDrawSurface4;
   Clpr: IDirectDrawClipper;
   TransSrc1, TransSrc2 : PByteArr;
   Form : TForm;
  end;

  TDirectXSlideShowCreatorManager = class(TObject)
   Private
    FThreads : TArThreads;
    FObjects : TThreadDestroyDXObjects;
    FFreeOnExit : Boolean;
   Public
    Constructor Create;
    Destructor Destroy; override;
    Procedure AddThread(Thread : TDirectXSlideShowCreator);
    Procedure RemoveThread(Thread : TDirectXSlideShowCreator);
    Function IsThread(Thread : TDirectXSlideShowCreator) : Boolean;
    Function ThreadCount : Integer;
    Procedure SetDXObjects(Objects : TThreadDestroyDXObjects);
    Procedure FreeOnExit;
   published
  end;

  const
    CallBack_Failture = 0;
    CallBack_SetImage = 1;
    CallBack_Next     = 2;

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
  dc: HDC;
begin
 if  (FSynchBitmap = nil) then exit;
 if FInfo.Buffer=nil then exit;
 FInfo.Buffer.GetDC (DC);
 BitBlt(dc,0,0,Screen.Width,Screen.Height, FSynchBitmap.Canvas.Handle,0,0,SRCCOPY);
 FInfo.Buffer.ReleaseDC (DC);
end;

constructor TDirectXSlideShowCreator.Create(CreateSuspennded: Boolean;
  Info: TDirectXSlideShowCreatorInfo; XForward, Next : Boolean);
begin
 inherited Create(True);
 FInfo:=Info;
 FXForward := XForward;
 FNext:=Next;
 FreeOnTerminate:=true;
 (FInfo.Manager as TDirectXSlideShowCreatorManager).AddThread(self);
 if not CreateSuspennded then Resume;
end;

procedure TDirectXSlideShowCreator.DoCallBack(Action : Byte);
begin
 FCallBackAction:=Action;
 if Action=CallBack_Next then sleep(500);
 Synchronize(DoCallBackSynch)
end;

procedure TDirectXSlideShowCreator.DoCallBackSynch;
var
  CallbackInfo : TCallbackInfo;
begin
 CallbackInfo.Action:=FCallBackAction;
 CallbackInfo.ForwardThread:=false;
 if (CallBack_Next=CallbackInfo.Action) and FXForward then
 begin
  DirectShowForm.ForwardThreadExists:=false;
  CallbackInfo.ForwardThread:=true;
 end;
 CallbackInfo.Direction:=FNext;
 FInfo.CallBack(CallbackInfo);
end;

procedure TDirectXSlideShowCreator.DoExit;
begin
 Synchronize(IFPause);
 Paused:=BooleanParam;
 if FXForward or Paused then
 begin
  Repeat
   If ExitReady then break;
   if Ready then break;
   Sleep(50);
  until false;
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
  w, h : integer;
  LoadingPicture : Boolean;
  Zoom : Extended;
  TempImage : TBitmap;

const
  text_out = TEXT_MES_CREATING+'...';
  text_error_out = TEXT_MES_UNABLE_SHOW_FILE;

begin
 LoadingPicture:=true;
 if ValidCryptGraphicFile(FInfo.FileName) then
 begin
  FilePassword:=DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
  if FilePassword='' then
  begin
   LoadingPicture:=false;
  end;
 end;
 if LoadingPicture then
 begin
  Picture := TPicture.Create;
  try
   if ValidCryptGraphicFile(FInfo.FileName) then
   begin
    Picture.Graphic:=DeCryptGraphicFile(FInfo.FileName,FilePassword);
   end else
   Picture.LoadFromFile(FInfo.FileName);
   JPEGScale(Picture.Graphic,Screen.Width,Screen.Height);
  except
   Picture.Free;
   LoadingPicture:=false;
  end;
 end;
 if LoadingPicture then
  begin
  Image:=TBitmap.Create;
  try
    AssignGraphic(Image, Picture.Graphic);
  except
   Image.Free;
   Picture.Free;
   LoadingPicture:=false;
  end;
 end;
 if LoadingPicture then
 Picture.Free;
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
 DoExit;
end;

function TDirectXSlideShowCreator.PackColor(Color: TColor): TColor;
var r, g, b: integer;
begin
  Color := ColorToRGB (Color);
  b := (Color shr 16) and $FF;
  g := (Color shr 8) and $FF;
  r := Color and $FF;
  if FInfo.BPP = 16 then begin
     r := r shr 3;
     g := g shr 3;
     b := b shr 3;
  end;
  Result := (r shl FInfo.RBM) or (g shl FInfo.GBM) or (b shl FInfo.BBM);
end;

procedure UnLock (Buffer: IDirectDrawSurface4);
begin
  if Buffer = nil then exit;
  Buffer.UnLock (nil);
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
  dd: TDDSurfaceDesc2;
  TransSize, TransPitch, TransHeight : integer;
begin
 if FInfo.Buffer=nil then exit;
 LockRead(FInfo.Buffer, dd);
 TransPitch := dd.lPitch;
 TransHeight := dd.dwHeight;
 TransSize := TransHeight * TransPitch;
 if FInfo.TempSrc=nil then
 GetMem (FInfo.TempSrc, TransSize);
 CopyMemory (FInfo.TempSrc, dd.lpSurface, TransSize - 1);
 UnLock (FInfo.Buffer);
end;

destructor TDirectXSlideShowCreator.Destroy;
begin
 (FInfo.Manager as TDirectXSlideShowCreatorManager).RemoveThread(self);
 inherited;
end;

procedure TDirectXSlideShowCreator.Btl;
begin
 if FInfo.Buffer<>nil then
 FInfo.Buffer.Blt (@r, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @fx);
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
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i]=Thread then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FThreads,Length(FThreads)+1);
  FThreads[Length(FThreads)-1]:=Thread;
 end;
end;

constructor TDirectXSlideShowCreatorManager.Create;
begin
 SetLength(FThreads,0);
 FFreeOnExit:=false;
end;

destructor TDirectXSlideShowCreatorManager.Destroy;
begin
 SetLength(FThreads,0);
 if FFreeOnExit then
 begin
  FObjects.Buffer.Release;
  FObjects.Buffer := nil;
  FObjects.Offscreen.Release;
  FObjects.Offscreen := nil;
  FObjects.PrimarySurface.Release;
  FObjects.PrimarySurface := nil;
  FObjects.Clpr.Release;
  FObjects.Clpr:=nil;
  FObjects.DirectDraw4.Release;
  FObjects.DirectDraw4 := nil;
  FObjects.Form.Close;
 end;
 inherited;
end;

procedure TDirectXSlideShowCreatorManager.FreeOnExit;
begin
 FFreeOnExit:=true;
end;

function TDirectXSlideShowCreatorManager.IsThread(
  Thread: TDirectXSlideShowCreator): Boolean;
var
  i : Integer;
begin
 Result:=False;
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i]=Thread then
 begin
  Result:=True;
  Break;
 end;
end;

procedure TDirectXSlideShowCreatorManager.RemoveThread(
  Thread: TDirectXSlideShowCreator);
var
  i, j : integer;
begin
 For i:=0 to Length(FThreads)-1 do
 if FThreads[i]=Thread then
 begin
  For j:=i to Length(FThreads)-2 do
  FThreads[j]:=FThreads[j+1];
  SetLength(FThreads,Length(FThreads)-1);
  break;
 end;
 if (Length(FThreads)=0) and FFreeOnExit then Free;
end;

procedure TDirectXSlideShowCreatorManager.SetDXObjects(Objects : TThreadDestroyDXObjects);
begin
 FObjects:=Objects;
end;

function TDirectXSlideShowCreatorManager.ThreadCount: Integer;
begin
 Result:=Length(FThreads);
end;

end.






