unit UnitDirectXSlideShowCreator;

interface

uses
  Windows, Classes, Graphics, GraphicCrypt, Dolphin_DB, Forms, DDraw,
  GraphicsCool, Effects, UnitDBCommonGraphics, uMemory, uDXUtils, SysUtils,
  SyncObjs, uConstants, UnitDBKernel, uGraphicUtils, uDBThread, uMemoryEx,
  uAssociations, uJpegUtils, uBitmapUtils, RAWImage;

type
  TDirectXSlideShowCreator = class(TDBThread)
  private
    { Private declarations }
    FInfo: TDirectXSlideShowCreatorInfo;
    Graphic: TGraphic;
    Image: TBitmap;
    ScreenImage: TBitmap;
    FilePassword: string;
    FCallBackAction: Byte;
    FSynchBitmap: TBitmap;
    Rct: TRect;
    Fx: TDDBltFx;
    FXForward: Boolean;
    FNext: Boolean;
    BooleanParam: Boolean;
    Paused: Boolean;
    FMonWidth, FMonHeight: Integer;
  protected
    function GetThreadID: string; override;
    procedure DoCallBack(Action: Byte);
    procedure DoCallBackSynch;
    procedure Execute; override;
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

implementation

uses
  DX_Alpha;

{ TDirectXSlideShowCreator }

function TDirectXSlideShowCreator.CenterBmp(Buffer: IDirectDrawSurface4;
  Bitmap: TBitmap; Rect: TRect): TRect;
begin
  FSynchBitmap := Bitmap;
  SynchronizeEx(CenterBmpSynch);
end;

procedure TDirectXSlideShowCreator.CenterBmpSynch;
var
  DC: HDC;
begin
  if (FSynchBitmap = nil) or (FInfo.Buffer = nil) then
    Exit;

  FInfo.Buffer.GetDC(DC);
  BitBlt(Dc, 0, 0, FInfo.Form.Monitor.Width, FInfo.Form.Monitor.Height, FSynchBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  FInfo.Buffer.ReleaseDC(DC);
end;

constructor TDirectXSlideShowCreator.Create(Info: TDirectXSlideShowCreatorInfo; XForward, Next: Boolean);
begin
  inherited Create(Info.Form, False);
  FMonWidth := Info.Form.Monitor.Width;
  FMonHeight := Info.Form.Monitor.Height;
  FInfo := Info;
  FXForward := XForward;
  FNext := Next;
  FreeOnTerminate := True;
  FInfo.Manager.AddThread(Self);
end;

procedure TDirectXSlideShowCreator.DoCallBack(Action: Byte);
begin
  FCallBackAction := Action;
  SynchronizeEx(DoCallBackSynch)
end;

procedure TDirectXSlideShowCreator.DoCallBackSynch;
var
  CallbackInfo: TCallbackInfo;
begin
  CallbackInfo.Action := FCallBackAction;
  CallbackInfo.ForwardThread := False;
  if FXForward then
  begin
    DirectShowForm.ForwardThreadExists := False;
    CallbackInfo.ForwardThread := True;
  end;
  CallbackInfo.Direction := FNext;
  FInfo.CallBack(CallbackInfo);
end;

procedure TDirectXSlideShowCreator.DoExit;
begin
  SynchronizeEx(IFPause);
  Paused := BooleanParam;
  if FXForward or Paused then
  begin
    repeat
      if ExitReady or Ready then
        Break;

      Sleep(10);
    until False;
  end;
  SynchronizeEx(DoExitSynch);
  R(FInfo.Buffer);
  FreeMem(FInfo.TempSrc)
end;

procedure TDirectXSlideShowCreator.DoExitSynch;
begin
  if DirectShowForm <> nil then
    if IsEqualGUID(DirectShowForm.SID, FInfo.SID) or (Ready and FXForward) or (Paused and Ready) then
    begin
      DirectShowForm.SetThreadImage(FInfo.TempSrc);
      DirectShowForm.BeginFade;
      DirectShowForm.ForwardThreadExists := False;
    end;
end;

procedure TDirectXSlideShowCreator.Execute;
var
  W, H: Integer;
  Zoom: Extended;
  TempImage: TBitmap;
  GraphicClass: TGraphicClass;
  Text_error_out: string;
begin
  inherited;

  Text_error_out := L('Unable to show file:');
  try
    if ValidCryptGraphicFile(FInfo.FileName) then
    begin
      FilePassword := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
      if FilePassword = '' then
        Exit;
    end;

    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FInfo.FileName));
    if GraphicClass = nil then
      Exit;

    Graphic := GraphicClass.Create;
    try
      if ValidCryptGraphicFile(FInfo.FileName) then
      begin
        F(Graphic);
        Graphic := DeCryptGraphicFile(FInfo.FileName, FilePassword, False);
      end else
      begin
        if Graphic is TRAWImage then
          TRAWImage(Graphic).IsPreview := True;

        Graphic.LoadFromFile(FInfo.FileName);
      end;
      JPEGScale(Graphic, FMonWidth, FMonHeight);

      Image := TBitmap.Create;
      try
        AssignGraphic(Image, Graphic);
        F(Graphic);

        ScreenImage := TBitmap.Create;
        try
          ScreenImage.Canvas.Pen.Color := 0;
          ScreenImage.Canvas.Brush.Color := 0;
          ScreenImage.SetSize(FMonWidth, FMonHeight);

          W := Image.Width;
          H := Image.Height;
          case FInfo.Rotate of
            DB_IMAGE_ROTATE_0 :
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              if Image.Width <> 0 then
                Zoom := W / Image.Width
              else
                Zoom := 1;

              if (Zoom<ZoomSmoothMin) then
                StretchCoolEx0(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, Image, ScreenImage, $000000)
              else
              begin
                XFillRect(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, ScreenImage, $000000);
                TempImage := TBitmap.Create;
                try
                  TempImage.PixelFormat := pf24bit;
                  TempImage.SetSize(W, H);
                  SmoothResize(W, H, Image, TempImage);
                  ThreadDraw(TempImage, ScreenImage, FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2);
                finally
                  F(TempImage);
                end;
              end;
            end;
            DB_IMAGE_ROTATE_270 :
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              StretchCoolEx270(FMonWidth div 2 - H div 2, FMonHeight div 2 - W div 2, W, H, Image, ScreenImage, $000000)
            end;
            DB_IMAGE_ROTATE_90 :
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              StretchCoolEx90(FMonWidth div 2 - H div 2, FMonHeight div 2 - W div 2, W, H, Image, ScreenImage, $000000)
            end;
            DB_IMAGE_ROTATE_180 :
            begin
              ProportionalSize(FMonWidth, FMonHeight, W, H);
              StretchCoolEx180(FMonWidth div 2 - W div 2, FMonHeight div 2 - H div 2, W, H, Image, ScreenImage,$000000)
            end;
          end;
          F(Image);

          FillChar(fx, SizeOf (fx), 0);
          fx.dwSize := SizeOf(fx);
          fx.dwFillColor := PackColor (0, FInfo.BPP, FInfo.RBM, FInfo.GBM, FInfo.BBM);
          Rct := Rect(0, 0, ScreenImage.Width, ScreenImage.Height);
          SynchronizeEx(Btl);
          CenterBmp (FInfo.Buffer, ScreenImage, Rect(0, 0, ScreenImage.Width, ScreenImage.Height));
          F(ScreenImage);
          ReplaceTransform;

        finally
          F(ScreenImage);
        end;

      finally
        F(Image);
      end;

    finally
      F(Graphic);
    end;

  finally
    DoExit;
  end;
end;

procedure UnLock (Buffer: IDirectDrawSurface4);
begin
  if Buffer = nil then
    Exit;
  Buffer.UnLock(nil);
end;

procedure LockRead (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then
    Exit;
  ZeroMemory (@SurfaceDesc, sizeof (TDDSurfaceDesc2));
  SurfaceDesc.dwSize := sizeof (TDDSurfaceDesc2);
  Buffer.Lock (nil, SurfaceDesc, DDLOCK_WAIT or DDLOCK_SURFACEMEMORYPTR or DDLOCK_READONLY or DDLOCK_NOSYSLOCK, 0);
  if SurfaceDesc.lpSurface = nil then
     UnLock (Buffer);
end;

procedure LockWrite (Buffer: IDirectDrawSurface4; var SurfaceDesc: TDDSurfaceDesc2);
begin
  if Buffer = nil then
    Exit;
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
  try
    TransPitch := Dd.LPitch;
    TransHeight := Dd.DwHeight;
    TransSize := TransHeight * TransPitch;
    if FInfo.TempSrc = nil then
      GetMem(FInfo.TempSrc, TransSize);
    CopyMemory(FInfo.TempSrc, Dd.LpSurface, TransSize - 1);
  finally
    UnLock(FInfo.Buffer);
  end;
end;

destructor TDirectXSlideShowCreator.Destroy;
begin
  DirectXSlideShowCreatorManagers.RemoveThread(FInfo.Manager, Self);
  inherited;
end;

procedure TDirectXSlideShowCreator.Btl;
begin
  if FInfo.Buffer <> nil then
    FInfo.Buffer.Blt(@Rct, nil, nil, DDBLT_WAIT + DDBLT_COLORFILL, @Fx);
end;

function TDirectXSlideShowCreator.Ready: boolean;
begin
  Result := False;
  if Paused then
  begin
    Result := DirectShowForm.FReadyAfterPause;
    Exit;
  end;
  if DirectShowForm <> nil then
    if IsEqualGUID(DirectShowForm.ForwardSID, FInfo.SID) then
      Result := DirectShowForm.Ready;
end;

function TDirectXSlideShowCreator.ExitReady: boolean;
begin
  if DirectShowForm = nil then
  begin
    Result := True;
    Exit;
  end;
  if Paused then
  begin
    Result := not DirectShowForm.FNowPaused;
    Exit;
  end;
  if (not IsEqualGUID(DirectShowForm.ForwardSID, FInfo.SID) and FXForward) or (DirectShowForm = nil) then
    Result := True
  else
    Result := False;
end;

function TDirectXSlideShowCreator.GetThreadID: string;
begin
  Result := 'Viewer';
end;

procedure TDirectXSlideShowCreator.IFPause;
begin
  if DirectShowForm = nil then
  begin
    BooleanParam := True;
    Exit;
  end;
  BooleanParam := DirectShowForm.FNowPaused;
end;

end.
