unit InsertImageToolUnit;

interface

{$DEFINE PHOTODB}

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
     GraphicsCool, SysUtils, ImageHistoryUnit, Effects, ComCtrls, Math,
     GraphicsBaseTypes, Language, CustomSelectTool, Dialogs, ExtDlgs,
     ScanlinesFX, clipbrd, UnitDBFileDialogs, UnitDBCommonGraphics,
     UnitDBKernel, UnitDBCommon, EffectsLanguage, Dolphin_DB, uDBGraphicTypes;

type
  InsertImageToolPanelClass = Class(TCustomSelectToolClass)
  private
  Image : TBitmap;
  LoadImageButton : TButton;
  OpenFileDialog : DBOpenPictureDialog;
  MethodDrawChooser : TComboBox;
  LabelMethod : TLabel;
//  LabelTransparent : TLabel;
  TransparentEdit : TTrackBar;
  FLoading : Boolean;
    { Private declarations }
  public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
  procedure DoEffect(Bitmap : TBitmap; aRect : TRect; FullImage : Boolean); override;
  Procedure DoBorder(Bitmap : TBitmap; aRect : TRect); override;
  procedure DoSaveSettings(Sender : TObject); override;
  procedure DoLoadFileFromFile(Sender : TObject);
  procedure RecreateImage(Sender : TObject);
  class function ID: string; override;

  Procedure SetProperties(Properties : String); override;
  Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
    { Public declarations }
  published
  end;

implementation

{ TRedEyeToolPanelClass }

constructor InsertImageToolPanelClass.Create(AOwner: TComponent);
begin
  inherited;
  AnyRect:=true;
  FLoading:=true;
  Image := TBitmap.Create;
  Image.PixelFormat:=pf32bit;
  if ClipBoard.HasFormat(CF_BITMAP) then
  Image.Assign(ClipBoard);
  OpenFileDialog := DBOpenPictureDialog.Create();
  OpenFileDialog.Filter:= GetGraphicFilter;
  LoadImageButton := TButton.Create(AOwner);
  LoadImageButton.Parent:=Self;
  LoadImageButton.Top:=EditWidth.Top+EditWidth.Height+5;
  LoadImageButton.Left:=8;
  LoadImageButton.Width:=150;
  LoadImageButton.Height:=21;
  LoadImageButton.Caption:=TEXT_MES_LOAD_IMAGE;
  LoadImageButton.OnClick:=DoLoadFileFromFile;
  LoadImageButton.Show;

  LabelMethod := TLabel.Create(AOwner);
  LabelMethod.Left:=8;
  LabelMethod.Top:=LoadImageButton.Top+LoadImageButton.Height+5;
  LabelMethod.Parent:=Self;
  LabelMethod.Caption:=TEXT_MES_METHOD+':';

  MethodDrawChooser := TComboBox.Create(AOwner);
  MethodDrawChooser.Top:=LabelMethod.Top+LabelMethod.Height+5;
  MethodDrawChooser.Left:=8;
  MethodDrawChooser.Width:=150;
  MethodDrawChooser.Height:=20;
  MethodDrawChooser.Parent:=Self;
  MethodDrawChooser.Style:=csDropDownList;
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_NORMAL);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_SUM);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_DARK);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_WHITE);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_COLOR);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_INV_COLOR);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_CHANGE_COLOR);
  MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_DIFFERENCE);

  MethodDrawChooser.ItemIndex:=0;
  MethodDrawChooser.OnChange:=RecreateImage;

  LabelMethod := TLabel.Create(AOwner);
  LabelMethod.Left:=8;
  LabelMethod.Top:=MethodDrawChooser.Top+MethodDrawChooser.Height+5;
  LabelMethod.Parent:=Self;
  LabelMethod.Caption:=TEXT_MES_TRANSPARENCY+':';

  TransparentEdit := TTrackBar.Create(AOwner);
  TransparentEdit.Top:=LabelMethod.Top+LabelMethod.Height+5;
  TransparentEdit.Left:=8;
  TransparentEdit.Width:=160;
  TransparentEdit.OnChange:=RecreateImage;
  TransparentEdit.Min:=1;
  TransparentEdit.Max:=100;
  TransparentEdit.Position:=DBKernel.ReadInteger('Editor','InsertImageTransparency',100);
  TransparentEdit.Parent:=Self;
  LabelMethod.Caption:=Format(TEXT_MES_TRANSPARENCY_F,[IntToStr(TransparentEdit.Position)]);
  SaveSettingsLink.Top:=TransparentEdit.Top+TransparentEdit.Height+5;
  MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
  CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
  FLoading:=false;
end;

destructor InsertImageToolPanelClass.Destroy;
begin
  Image.Free;
  OpenFileDialog.Free;
  inherited;
end;

procedure InsertImageToolPanelClass.DoBorder(Bitmap: TBitmap; aRect: TRect);
var
  i,j:integer;
  Rct : TRect;
  Xdp : TArPARGB;

  Procedure Border(i,j : integer; var RGB : TRGB);
  begin
   if odd((i+j) div 3) then
   begin
    RGB.r:=RGB.r div 5;
    RGB.g:=RGB.g div 5;
    RGB.b:=RGB.b div 5;
   end else
   begin
    RGB.r:=RGB.r xor $FF;
    RGB.g:=RGB.g xor $FF;
    RGB.b:=RGB.b xor $FF;
   end;
  end;
begin
 Rct.Top:=Min(aRect.Top,aRect.Bottom);
 Rct.Bottom:=Max(aRect.Top,aRect.Bottom);
 Rct.Left:=Min(aRect.Left,aRect.Right);
 Rct.Right:=Max(aRect.Left,aRect.Right);
 aRect:=Rct;

 SetLength(Xdp,Bitmap.height);
 for i:=0 to Bitmap.Height-1 do
 Xdp[i]:=Bitmap.ScanLine[i];

 i:=Min(Bitmap.Height-1,Max(0,aRect.Top));
 if i=aRect.Top then
 for j:=0 to Bitmap.Width-1 do
 begin
  if (j>aRect.Left) and (j<aRect.Right) then
  begin
   Border(i,j,Xdp[i,j]);
  end;
 end;

 i:=Min(Bitmap.Height-1,Max(0,aRect.Bottom));
 if i=aRect.Bottom then
 for j:=0 to Bitmap.Width-1 do
 begin
  if (j>aRect.Left) and (j<aRect.Right) then
  begin
   Border(i,j,Xdp[i,j]);
  end;
 end;

 for i:=Max(0,aRect.Top) to Min(aRect.Bottom-1,Bitmap.Height-1) do
 begin
  j:=Max(0,Min(Bitmap.Width-1,aRect.Left));
  if j=aRect.Left then
  Border(i,j,Xdp[i,j]);
 end;
 for i:=Max(0,aRect.Top) to Min(aRect.Bottom-1,Bitmap.Height-1) do
 begin
  j:=Min(Bitmap.Width-1,Max(0,aRect.Right));
  if j=aRect.Right then
  Border(i,j,Xdp[i,j]);
 end;

end;

procedure DrawImageWithEffect(S,D : TBitmap; CodeEffect : Integer; Transparency : Extended);
var
  i,j : integer;
  p1,p2 : PARGB;
  w,h : integer;
  l,ld,t,t1 : extended;
  function CopyTRGB(RGBS, RGBD : TRGB) : TRGB;
  begin
   Case CodeEffect of
   0:
   begin
    Result.r:=Round(RGBS.r*t+RGBD.r*t1);
    Result.g:=Round(RGBS.g*t+RGBD.g*t1);
    Result.b:=Round(RGBS.b*t+RGBD.b*t1);
   end;
   1: 
   begin
    Result.r:=Round(sqrt(RGBD.r*RGBS.r)*t+RGBD.r*t1);
    Result.g:=Round(sqrt(RGBD.g*RGBS.g)*t+RGBD.g*t1);
    Result.b:=Round(sqrt(RGBD.b*RGBS.b)*t+RGBD.b*t1);
   end;
   2:
   begin
    Result.r:=Round(RGBD.r*(RGBS.r/255)*t+RGBD.r*t1);
    Result.g:=Round(RGBD.g*(RGBS.g/255)*t+RGBD.g*t1);
    Result.b:=Round(RGBD.b*(RGBS.b/255)*t+RGBD.b*t1);
   end;
   3:
   begin
    l:=(RGBS.r*0.3+RGBS.g*0.59+RGBS.b*0.11)/255;
    Result.r:=Round((RGBD.r*(1-l)+RGBS.r*(l))*t+RGBD.r*t1);
    Result.g:=Round((RGBD.g*(1-l)+RGBS.g*(l))*t+RGBD.g*t1);
    Result.b:=Round((RGBD.b*(1-l)+RGBS.b*(l))*t+RGBD.b*t1);
   end;

   4:
   begin
    l:=(RGBS.r*0.3+RGBS.g*0.59+RGBS.b*0.11)/255;
    ld:=(RGBD.r*0.3+RGBD.g*0.59+RGBD.b*0.11);
    Result.r:=Round((RGBD.r*(1-l)+ld*(l))*t+RGBD.r*t1);
    Result.g:=Round((RGBD.g*(1-l)+ld*(l))*t+RGBD.g*t1);
    Result.b:=Round((RGBD.b*(1-l)+ld*(l))*t+RGBD.b*t1);
   end;

   5:
   begin
    l:=1-(RGBS.r*0.3+RGBS.g*0.59+RGBS.b*0.11)/255;
    ld:=(RGBD.r*0.3+RGBD.g*0.59+RGBD.b*0.11);
    Result.r:=Round((RGBD.r*(1-l)+ld*(l))*t+RGBD.r*t1);
    Result.g:=Round((RGBD.g*(1-l)+ld*(l))*t+RGBD.g*t1);
    Result.b:=Round((RGBD.b*(1-l)+ld*(l))*t+RGBD.b*t1);
   end;

   6:
   begin
    ld:=(RGBD.r*0.3+RGBD.g*0.59+RGBD.b*0.11)/255;
    l:=(RGBS.r*0.3+RGBS.g*0.59+RGBS.b*0.11)/255;
    if l<0.03 then
    begin
     Result.r:=RGBD.r;
     Result.g:=RGBD.g;
     Result.b:=RGBD.b;
    end else
    begin
     Result.r:=Min(255,Round((RGBS.r*ld/l)*t+RGBD.r*t1));
     Result.g:=Min(255,Round((RGBS.g*ld/l)*t+RGBD.g*t1));
     Result.b:=Min(255,Round((RGBS.b*ld/l)*t+RGBD.b*t1));
    end;
   end;

   7:
   begin
    Result.r:=Round(abs((RGBD.r-RGBS.r)*t+RGBD.r*t1));
    Result.g:=Round(abs((RGBD.g-RGBS.g)*t+RGBD.g*t1));
    Result.b:=Round(abs((RGBD.b-RGBS.b)*t+RGBD.b*t1));
   end;

   end;
  end;

begin
 t:=Transparency/100;
 t1:=1-Transparency/100;
 h:=Min(S.Height,D.Height);
 w:=Min(S.Width,D.Width);
 for i:=0 to h-1 do
 begin
  p1:=S.ScanLine[i];
  p2:=D.ScanLine[i];
  for j:=0 to w-1 do
  begin
   p2[j]:=CopyTRGB(p1[j],p2[j]);
  end;
 end;
end;

procedure InsertImageToolPanelClass.DoEffect(Bitmap: TBitmap; aRect: TRect;
  FullImage: Boolean);
var
  w,h, aWidth, aHeight : integer;
  Rct, DrawRect : TRect;
  TempBitmap, RectBitmap : TBitmap;
begin
 Rct.Top:=Min(aRect.Top,aRect.Bottom);
 Rct.Bottom:=Max(aRect.Top,aRect.Bottom);
 Rct.Left:=Min(aRect.Left,aRect.Right);
 Rct.Right:=Max(aRect.Left,aRect.Right);
 aRect:=Rct;
 w:=abs(aRect.Right-aRect.Left);
 h:=abs(aRect.Bottom-aRect.Top);
 if w*h=0 then exit;
 aWidth:=Image.Width;
 aHeight:=Image.Height;
 if aWidth*aHeight=0 then exit;
 ProportionalSizeX(w,h,aWidth,aHeight);
 DrawRect:=Rect(aRect.Left+w div 2-aWidth div 2,aRect.Top+h div 2-aHeight div 2, aRect.Left+w div 2+aWidth div 2,aRect.Top+h div 2+aHeight div 2);
 if not FullImage then
 begin
  RectBitmap := TBitmap.Create;
  RectBitmap.PixelFormat:=pf24bit;
  RectBitmap.Width:=aWidth;
  RectBitmap.Height:=aHeight;
  RectBitmap.Canvas.CopyRect(Rect(0,0,aWidth,aHeight),Bitmap.Canvas,DrawRect);
  TempBitmap := TBitmap.Create;
  TempBitmap.PixelFormat:=pf24bit;
  TempBitmap.Width:=aWidth;
  TempBitmap.Height:=aHeight;
  TempBitmap.Canvas.StretchDraw(Rect(0,0,aWidth,aHeight),Image);
  if RectBitmap.Width*RectBitmap.Height=0 then exit;
  DrawImageWithEffect(TempBitmap,RectBitmap,MethodDrawChooser.ItemIndex,TransparentEdit.Position);
  TempBitmap.Free;
  Bitmap.Canvas.StretchDraw(DrawRect,RectBitmap);
  RectBitmap.Free;
 end else
 begin
  RectBitmap := TBitmap.Create;
  RectBitmap.PixelFormat:=pf24bit;
  RectBitmap.Width:=aWidth;
  RectBitmap.Height:=aHeight;
  RectBitmap.Canvas.CopyRect(Rect(0,0,aWidth,aHeight),Bitmap.Canvas,DrawRect);
  TempBitmap := TBitmap.Create;
  TempBitmap.PixelFormat:=pf24bit;
  if (Image.Width/aWidth)>1 then
  DoResize(aWidth,aHeight,Image,TempBitmap) else
  Effects.Interpolate(0,0,aWidth,aHeight,Rect(0,0,Image.Width,Image.Height),Image,TempBitmap);
  if RectBitmap.Width*RectBitmap.Height=0 then exit;
  DrawImageWithEffect(TempBitmap,RectBitmap,MethodDrawChooser.ItemIndex,TransparentEdit.Position);
  TempBitmap.Free;
  Bitmap.Canvas.StretchDraw(DrawRect,RectBitmap);
  RectBitmap.Free;


 end;
end;

procedure InsertImageToolPanelClass.DoLoadFileFromFile(Sender: TObject);
var
  pic : TPicture;
begin
 if OpenFileDialog.Execute then
 begin
  pic := TPicture.Create;
  pic.LoadFromFile(OpenFileDialog.FileName);
  Image.Assign(pic.Graphic);
  pic.Free;
  ProcRecteateImage(Sender);
 end;
end;

procedure InsertImageToolPanelClass.DoSaveSettings(Sender: TObject);
begin
 {$IFDEF PHOTODB}
  DBKernel.WriteInteger('Editor','InsertImageTransparency',TransparentEdit.Position);
 {$ENDIF}
end;

procedure InsertImageToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

class function InsertImageToolPanelClass.ID: string;
begin         
Result:='{CA9E5AFD-E92D-4105-8F7B-978A6EBA9D74}';
end;

procedure InsertImageToolPanelClass.RecreateImage(Sender: TObject);
begin
 if FLoading then Exit;
 LabelMethod.Caption:=Format(TEXT_MES_TRANSPARENCY_F,[IntToStr(TransparentEdit.Position)]);
 ProcRecteateImage(Sender);
end;

procedure InsertImageToolPanelClass.SetProperties(Properties: String);
begin

end;

end.
