unit unitimhint;

interface

uses
  DBCMenu, UnitDBKernel, menus,dolphin_db, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, GIFImage, Math,
  Dialogs, StdCtrls, ExtCtrls, ImButton, ComCtrls, ActiveX,
  AppEvnts, ImgList, DropSource, DropTarget, GraphicsCool, DragDropFile,
  DragDrop, UnitDBCommon, UnitDBCommonGraphics;

type
  TImHint = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    Timer3: TTimer;
    ApplicationEvents1: TApplicationEvents;
    DropFileSource1: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget1: TDropFileTarget;
    PaintBox1: TPaintBox;
    ImageFrameTimer: TTimer;
    DestroyTimer: TTimer;
    procedure execute(Sender : TObject; Bitmaped,Transparent : Boolean; bit : tbitmap; G : TGraphic; c,w,h:integer; rect : trect; Info : TOneRecordInfo; item : TObject; funchintreal : THintRealFucntion);
    procedure FormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure FormHide(Sender: TObject);
    procedure hideshadow;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Timer3Timer(Sender: TObject);
    procedure Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
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
    procedure PaintBox1Paint(Sender: TObject);
    procedure ImageFrameTimerTimer(Sender: TObject);
    function GetFirstImageNO: integer;
    procedure DestroyTimerTimer(Sender: TObject);
  private
  AnimatedImage : TGraphic;
  SlideNO : Integer;
  ValidImages : integer;
  AnimatedBuffer : TBitmap;
  FBitmaped : Boolean;
  FTransparent : Boolean;
  DoubleBuffer : TBitmap;
  CanClosed : Boolean;
    { Private declarations }
  public
    protected
    procedure CreateParams(var Params: TCreateParams); override;

    { Public declarations }
  end;

var
  ImHint: TImHint;
  Closed : boolean = false;
  citem : TObject;
  currentfilename : string;
  goin : boolean;
  drag_ : boolean;
  fhintreal : THintRealFucntion;
  FOwner : TForm;
  CurrentInfo : TOneRecordInfo;

  const
    CS_DROPSHADOW = $00020000;

implementation

uses searching, Language;

{$R *.dfm}

{ TImHint }

function IsWinXP: Boolean;
begin 
 Result := (Win32Platform = VER_PLATFORM_WIN32_NT) and 
   (Win32MajorVersion >= 5) and (Win32MinorVersion >= 1); 
end; 

procedure DrawHintInfo(Handle : THandle; Width,Height  : Integer; fInfo : TOneRecordInfo);
var
  sm, y : Integer;
begin
 y:=Height-18;
 sm:=Width-2;
 if (Width<80) or (Height<60) then exit;
 If fInfo.ItemAccess=db_access_private then
 begin
  Dec(sm,20);
  DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_PRIVATE+1],16,16,0,0,DI_NORMAL);
 end;
 Dec(sm,20);
 Case fInfo.ItemRotate of
  DB_IMAGE_ROTATED_90: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_90+1],16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_180: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_180+1],16,16,0,0,DI_NORMAL);
  DB_IMAGE_ROTATED_270: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_ROTETED_270+1],16,16,0,0,DI_NORMAL);
 else Inc(sm,20);
 end;
 Dec(sm,20);
 Case fInfo.ItemRating of
  1: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_1+1],16,16,0,0,DI_NORMAL);
  2: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_2+1],16,16,0,0,DI_NORMAL);
  3: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_3+1],16,16,0,0,DI_NORMAL);
  4: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_4+1],16,16,0,0,DI_NORMAL);
  5: DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_RATING_5+1],16,16,0,0,DI_NORMAL);
 else Inc(sm,20);
 end;
 If FInfo.ItemCrypted then
 begin
  Dec(sm,20);
  DrawIconEx(Handle,sm,y,UnitDBKernel.icons[DB_IC_KEY+1],16,16,0,0,DI_NORMAL);
 end;
end;

procedure TImHint.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000; 
begin 
  inherited;
  if DBKernel.Readinteger('Options','PreviewSwohOptions',0)=1 then
  if IsWinXP then
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

procedure TImHint.Execute(Sender : TObject; Bitmaped,Transparent : Boolean; bit : tbitmap; G : TGraphic; c,w,h:integer; rect : trect; Info : TOneRecordInfo; item : TObject; funchintreal : THintRealFucntion);
var
  ww,hh,{ lfname, n, }fh, fw, fl, ft, lw:integer;
  fname : string;
  B : TBitmap;
begin
 FTransparent:=Transparent;
 FBitmaped:=Bitmaped;
 ImageFrameTimer.Enabled:=false;
 ValidImages:=c;
 AnimatedBuffer:=nil;
 CanClosed:=true;
 if Sender is TForm then fOwner:=Sender as TForm else fOwner:=nil;
 Closed:=true;
 Timer2.Enabled:=false;
 Timer1.Enabled:=false;
 CItem:=item;
 GoIn:=false;
 Timer3.Enabled:=true;
 Drag_:=true;
 CurrentInfo:=Info;
 CurrentFileName:=Info.ItemFileName;
 if not Assigned(FuncHintReal) then exit;
 if not FuncHintReal(item) then exit;
 if Info.ItemComment<>'' then
 fname:=Info.ItemComment else fname:=ExtractFileName(Info.ItemFileName);
 if Bitmaped then
 begin
{} if Image1.Picture.Bitmap=nil then
{} Image1.Picture.Bitmap:=Tbitmap.create;
   if Transparent then
   begin
    B := TBitmap.Create;
    B.Width:=bit.width+2;
    B.Height:=bit.height+2;
    B.PixelFormat:=pf24bit;
    b.Canvas.Brush.Color:=0;
    b.Canvas.Pen.Color:=0;
    b.Canvas.Rectangle(0,0,B.Width,B.Height);
    B.Canvas.Draw(1,1,bit);
    Image1.Picture.Bitmap.Assign(b);
    b.Free;
   end else
   begin
{}  Image1.Picture.Bitmap.Assign(bit);
   end;
   Image1.Visible:=true;
   PaintBox1.Visible:=false;
   ww:=bit.width;
   hh:=bit.height;
   if Transparent then
   begin
    Image1.Width:=ww+2;
    Image1.Height:=hh+2;
   end else
   begin
    Image1.Width:=ww;
    Image1.Height:=hh;
   end;
 end else
 begin
  if (Info.ItemRotate=DB_IMAGE_ROTATED_0) or (Info.ItemRotate=DB_IMAGE_ROTATED_180) then
  begin
   ww:=G.width;
   hh:=G.height;
  end else
  begin
   hh:=G.width;
   ww:=G.height;
  end;
  ProportionalSize(ThHintSize,ThHintSize,ww,hh);
  if Transparent then
  begin
   PaintBox1.Width:=ww+2;
   PaintBox1.Height:=hh+2;
  end else
  begin
   PaintBox1.Width:=ww;
   PaintBox1.Height:=hh;
  end;
  DoubleBuffer := TBitmap.Create;
  DoubleBuffer.PixelFormat:=pf24bit;
  DoubleBuffer.Width:=PaintBox1.Width;
  DoubleBuffer.Height:=PaintBox1.Height;
  AnimatedBuffer:=TBitmap.create;
  AnimatedBuffer.PixelFormat:=pf24bit;
  AnimatedBuffer.Width:=G.width;
  AnimatedBuffer.Height:=G.Height;
  AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Rectangle(0,0,AnimatedBuffer.Width,AnimatedBuffer.Height);
  AnimatedImage:=G;
  Image1.Visible:=false;
  PaintBox1.Visible:=true;
 end;
 fw:=ww+6;
 fh:=hh+6;
 if ww=0 then ww:=1;
// n:=(lfname div ww)+1;
 label1.top:=hh+6;

 if ww<100 then
 begin
  if label1.Canvas.TextWidth(fname)<ThHintSize then lw:=Max(ww,50) else
  lw:=100;
 end else
 begin
  lw:=ww;
 end;
 label1.constraints.maxwidth:=lw;
 label1.constraints.minwidth:=lw;

 label1.Caption:=fname;
 fh:=fh+label1.Height+3;
 label2.Top:=fh;
 label2.caption:=format(TEXT_MES_DIMENSIONS,[inttostr(w),inttostr(h)]);
 fh:=fh-label2.Font.Height+3;
 label3.Top:=fh;
 label3.caption:=format(TEXT_MES_SIZE_FORMAT,[sizeintextA(Info.ItemSize)]);
 fh:=fh-label3.Font.Height+3;

 if FTransparent then
 ClientWidth:=Min(Max(Max(Max(fw+2,label1.Width+6),Label2.Width+6),Label3.Width+6),ThHintSize+8)
 else
 ClientWidth:=Min(Max(Max(Max(fw,label1.Width+6),Label2.Width+6),Label3.Width+6),ThHintSize+6);

 Clientheight:=fh;
 if rect.Top+fh+10>screen.height then ft:=rect.Top-20-fh else ft:=rect.Top+10;
 if rect.left+fw+10>screen.Width then fl:=rect.left-20-fw else fl:=rect.left+10;
 if ft<0 then ft:=200;
 if fl<0 then fl:=200;
 Top:=ft;
 left:=fl;
 if FuncHintReal(item) then
 begin
 if DBKernel.readinteger('Options','PreviewSwohOptions',0)=0 then
 begin
  AlphaBlend:=true;
  AlphaBlendValue:=0;
  Timer1.Enabled:=true;
 end else AlphaBlend:=false;
 ShowWindow(Self.Handle,SW_SHOWNOACTIVATE);
 if fowner<>nil then
 if fowner.FormStyle=fsstayontop then
 SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE);
 Closed:=false;
 end;
 if not Bitmaped then
 begin
  SlideNO:=-1;
  ImageFrameTimer.Interval:=1;
  ImageFrameTimer.Enabled:=true;
 end;
end;

procedure TImHint.FormClick(Sender: TObject);
begin
 Timer2.Enabled:=true;
 close;
end;

procedure TImHint.FormCreate(Sender: TObject);
begin
 CanClosed:=true;
 AnimatedBuffer:=nil;
 DropFileTarget1.Register(self);
 DBkernel.RecreateThemeToForm(ImHint);
 DBkernel.RegisterForm(ImHint);
 DBkernel.RegisterProcUpdateTheme(UpdateTheme,self);
 Closed:=true;
end;

procedure TImHint.CMMOUSELEAVE(var Message: TWMNoParams);
var
  p : tpoint;
  r : trect;
begin
 r:=rect(self.left,self.top,self.left+self.width, self.top+self.height);
 getcursorpos(p);
 if not PtInRect(r,p) then
 begin
  Timer2.Enabled:=true;
//  close;
 end;
end;

procedure TImHint.FormHide(Sender: TObject);
begin
 hideshadow;
end;

procedure TImHint.hideshadow;
begin
 if DBKernel.ReadInteger('Options','PreviewSwohOptions',0)=1 then
 SetClassLong(Handle,GCL_STYLE, GetClassLong(Handle, GCL_STYLE) or CS_DROPSHADOW) ;
end;

procedure TImHint.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DragImage, S, TempImage : TBitmap;
  w,h : Integer;
begin
 if not drag_ then exit;
 if (Button = mbLeft) then
 begin
  CanClosed:=false;
  DragImageList.Clear;
  DropFileSource1.Files.Clear;
  DropFileSource1.Files.Add(CurrentFileName);
  DragImage:=TBitmap.Create;
  DragImage.PixelFormat:=pf24bit;
  if FBitmaped then
  s:=Image1.Picture.Bitmap else
  s:=DoubleBuffer;
  w:=s.Width;
  h:=s.Height;
  ProportionalSize(100,100,w,h);
  DoResize(w,h,S,DragImage);
  DragImageList.Masked:=false;
  DragImageList.Width:=DragImage.Width;
  DragImageList.Height:=DragImage.Height;

  TempImage:=RemoveBlackColor(DragImage);
  DragImageList.Add(TempImage,nil);
  TempImage.Free;

  DragImage.free;
  DropFileSource1.Execute;
  CanClosed:=true;
 end;
 Timer3.Enabled:=true;
end;

procedure TImHint.Timer1Timer(Sender: TObject);
begin
 if DBKernel.readinteger('Options','PreviewSwohOptions',0)=0 then
 begin
  self.AlphaBlendValue:=min(self.AlphaBlendValue+40,255);
  if self.AlphaBlendValue>=255 then
  Timer1.Enabled:=false;
 end;
end;

procedure TImHint.Timer2Timer(Sender: TObject);
begin
 if DBKernel.readinteger('Options','PreviewSwohOptions',0)=0{ and self.visible} then
 begin
  Timer1.Enabled:=false;
  hideshadow;
  self.AlphaBlendValue:=max(self.AlphaBlendValue-40,0);
  if self.AlphaBlendValue<=0 then
  begin
   Timer2.Enabled:=false;
   close;
  end;
 end;
end;

procedure TImHint.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 if Closed then exit;
 if (self.AlphaBlendValue>0) and (DBKernel.readinteger('Options','PreviewSwohOptions',0)=0) {and self.visible} then
 begin
  Timer2.Enabled:=true;
  CanClose:=false;
 end else if DBKernel.readinteger('Options','PreviewSwohOptions',0)=1 then RecreateWnd;
 Timer3.Enabled:=false;
 closed:=true;
end;

procedure TImHint.Image1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Info : TDBPopupMenuInfo;
begin
 if citem <>nil then
 begin
  Timer3.Enabled:=false;
  drag_:=true;
  RecordInfoOneToDBPopupMenuInfo(CurrentInfo,Info);
  Info.IsDateGroup:=True;
  Info.IsAttrExists:=false;
  TDBPopupMenu.Instance.Execute(self.image1.ClientToScreen(MousePos).x,self.image1.ClientToScreen(MousePos).y,Info);
  Self.HideShadow;
  if not closed then Timer2.Enabled:=true;
  drag_:=false;
 end
end;

procedure TImHint.Timer3Timer(Sender: TObject);
var
  p : tpoint;
  r : trect;
begin
 if Closed then
 begin
  Timer3.enabled:=false;
  Exit;
 end;
 if not goin then exit;
 r:=rect(self.left,self.top,self.left+self.width, self.top+self.height);
 getcursorpos(p);
 if not PtInRect(r,p) then
 begin
  Timer2.Enabled:=true;
//  Close;
 end;
 GoIn:=false;
end;

procedure TImHint.Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 GoIn:=true;
end;

procedure TImHint.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if FOwner<>nil then
 if FOwner.FormStyle=fsStayOnTop then
 FOwner.SetFocus;
 FOwner:=nil;
 if AnimatedBuffer<>nil then
 AnimatedBuffer.free;
 AnimatedBuffer:=nil;
 ImageFrameTimer.Enabled:=false;
 if DoubleBuffer<>nil then
 DoubleBuffer.free;
 DoubleBuffer:=nil;
 DestroyTimer.Enabled:=true;
end;

procedure TImHint.UpdateTheme(Sender: TObject);
begin
 DBKernel.RecreateThemeToForm(ImHint);
end;

procedure TImHint.FormDestroy(Sender: TObject);
begin
 DropFileTarget1.Unregister;
 DBkernel.UnRegisterProcUpdateTheme(UpdateTheme,self);
 DBkernel.UnRegisterForm(ImHint);
end;

procedure TImHint.FormKeyPress(Sender: TObject; var Key: Char);
begin
 If key=#27 then Close;
end;

procedure TImHint.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
 if Closed then Exit;
 if Msg.message=256 then
 begin
  if Msg.wParam=27 then Close;
 end;
end;

function TImHint.GetNextImageNO: integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage as TGIFImage);
  Result:=SlideNO;
  inc(Result);
  if Result>=im.Images.Count then
  begin
   Result:=0;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetNextImageNOX(Result);
  end;
 end;
end;

function TImHint.GetNextImageNOX(NO: Integer): integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage as TGIFImage);
  Result:=NO;
  inc(Result);
  if Result>=im.Images.Count then
  begin
   Result:=0;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetNextImageNOX(Result);
  end;
 end;
end;

function TImHint.GetPreviousImageNO: integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage as TGIFImage);
  Result:=SlideNO;
  dec(Result);
  if Result<0 then
  begin
   Result:=im.Images.Count-1;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetPreviousImageNOX(Result);
  end;
 end;
end;

function TImHint.GetPreviousImageNOX(NO: Integer): integer;
var
  im : TGIFImage;
begin
 if ValidImages=0 then Result:=0 else
 begin
  im:=(AnimatedImage as TGIFImage);
  Result:=NO;
  dec(Result);
  if Result<0 then
  begin
   Result:=im.Images.Count-1;
  end;
  if im.Images[Result].Empty then
  begin
   Result:=GetPreviousImageNOX(Result);
  end;
 end;
end;

procedure TImHint.PaintBox1Paint(Sender: TObject);
begin
 if DoubleBuffer<>nil then
 begin
  PaintBox1.Canvas.Draw(0,0,DoubleBuffer);
 end;
end;

procedure TImHint.ImageFrameTimerTimer(Sender: TObject);
var
  c, PreviousNumber : integer;
  r, bounds_  : TRect;
  im : TGifImage;
  DisposalMethod : TDisposalMethod;
  del : integer;
  TimerEnabled:Boolean;
  gsi : TGIFSubImage;
begin
 del:=100;
 if Closed or FBitmaped then exit;
 DisposalMethod:=dmNone;
 if SlideNO=-1 then
 begin
  SlideNO:=GetFirstImageNO;
 end else
 begin
  SlideNO:=GetNextImageNO;
 end;
 r:=(AnimatedImage as TGIFImage).Images[SlideNO].BoundsRect;
 AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
 AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
 im:=(AnimatedImage as TGIFImage);
 TimerEnabled:=false;
 PreviousNumber:=GetPreviousImageNO;
 if im.Animate then
 if im.Images.Count>1 then
 begin
 gsi:=im.Images[SlideNO];
 if gsi.Empty then exit;
 if im.Images[PreviousNumber].Empty then DisposalMethod:=dmNone else
 begin
  if im.Images[PreviousNumber].GraphicControlExtension<>nil then
  DisposalMethod:=im.Images[PreviousNumber].GraphicControlExtension.Disposal else
  DisposalMethod:=dmNone;
 end;
// DisposalMethod:=dmNone;
 if im.Images[SlideNO].GraphicControlExtension<>nil then
 del:=im.Images[SlideNO].GraphicControlExtension.Delay*10;
 if del=10 then del:=100;
 if del=0 then del:=100;
 TimerEnabled:=True;
 end else
 DisposalMethod:=dmNone;
 if SlideNO=0 then DisposalMethod:=dmBackground else
 if (DisposalMethod=dmBackground) then
 begin
  bounds_:=im.Images[PreviousNumber].BoundsRect;
  AnimatedBuffer.Canvas.Pen.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Brush.Color:=Theme_MainColor;
  AnimatedBuffer.Canvas.Rectangle(bounds_);
 end;
 if DisposalMethod=dmPrevious then
 begin
  c:=SlideNO;
  dec(c);
  if c<0 then
  c:=im.Images.Count-1;
  im.Images[c].StretchDraw(AnimatedBuffer.Canvas,r,im.Images[SlideNO].Transparent,false);
 end;
 im.Images[SlideNO].StretchDraw(AnimatedBuffer.Canvas,r,im.Images[SlideNO].Transparent,false);
 if FTransparent then
 DoubleBuffer.Canvas.Pen.Color:=0 else
 DoubleBuffer.Canvas.Pen.Color:=Theme_MainColor;
 DoubleBuffer.Canvas.Brush.Color:=Theme_MainColor;
 DoubleBuffer.Canvas.Rectangle(0,0,DoubleBuffer.Width,DoubleBuffer.Height);

 if FTransparent then
 begin
  case CurrentInfo.ItemRotate of
    DB_IMAGE_ROTATED_0: StretchCoolEx0(1,1,DoubleBuffer.Width-2,DoubleBuffer.Height-2,AnimatedBuffer,DoubleBuffer,0);
    DB_IMAGE_ROTATED_90: StretchCoolEx90(1,1,DoubleBuffer.Height-2,DoubleBuffer.Width-2,AnimatedBuffer,DoubleBuffer,0);
    DB_IMAGE_ROTATED_180: StretchCoolEx180(1,1,DoubleBuffer.Width-2,DoubleBuffer.Height-2,AnimatedBuffer,DoubleBuffer,0);
    DB_IMAGE_ROTATED_270: StretchCoolEx270(1,1,DoubleBuffer.Height-2,DoubleBuffer.Width-2,AnimatedBuffer,DoubleBuffer,0);
  end;
 end else
 begin
  case CurrentInfo.ItemRotate of
    DB_IMAGE_ROTATED_0: StretchCoolEx0(0,0,DoubleBuffer.Width,DoubleBuffer.Height,AnimatedBuffer,DoubleBuffer,Theme_MainColor);
    DB_IMAGE_ROTATED_90: StretchCoolEx90(0,0,DoubleBuffer.Height,DoubleBuffer.Width,AnimatedBuffer,DoubleBuffer,Theme_MainColor);
    DB_IMAGE_ROTATED_180: StretchCoolEx180(0,0,DoubleBuffer.Width,DoubleBuffer.Height,AnimatedBuffer,DoubleBuffer,Theme_MainColor);
    DB_IMAGE_ROTATED_270: StretchCoolEx270(0,0,DoubleBuffer.Height,DoubleBuffer.Width,AnimatedBuffer,DoubleBuffer,Theme_MainColor);
  end;
 end;

 DrawHintInfo(DoubleBuffer.Canvas.Handle,DoubleBuffer.Width,DoubleBuffer.Height,CurrentInfo);
 PaintBox1.Canvas.Draw(0,0,DoubleBuffer);
 ImageFrameTimer.Enabled:=false;
 ImageFrameTimer.Interval:=del;
 if not TimerEnabled then ImageFrameTimer.Enabled:=false else
 ImageFrameTimer.Enabled:=true;
end;

function TImHint.GetFirstImageNO: integer;
var
  i : Integer;
begin
 Result:=-1;
 if ValidImages=0 then Result:=0 else
 begin
  for i:=0 to (AnimatedImage as TGIFImage).Images.count-1 do
  if not (AnimatedImage as TGIFImage).Images[i].Empty then
  begin
   Result:=i;
   break;
  end;
 end;
end;

procedure TImHint.DestroyTimerTimer(Sender: TObject);
begin
 if not CanClosed then exit;
 DestroyTimer.Enabled:=false;
 Release;
 if UseFreeAfterRelease then Free;
 ImHint:=nil;
end;

initialization

ImHint:=nil;

end.
