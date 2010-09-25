unit RedEyeToolUnit;

interface

{$DEFINE PHOTODB}

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
     GraphicsCool, Math, SysUtils, ImageHistoryUnit, Effects, ComCtrls,
     GraphicsBaseTypes, Language, CustomSelectTool, Dialogs,

     {$IFDEF PHOTODB}
     Dolphin_DB,
     {$ENDIF}

     EffectsLanguage;

type TRedEyeToolPanelClass = Class(TCustomSelectToolClass)
  private
    EffectSizeScroll : TTrackBar;
    EffectSizelabel : TLabel;
    FRedEyeEffectSize: integer;
    FEyeColorLabel : TLabel;
    FEyeColor : TComboBox;
    FCustomColor : TColor;
    FCustomColorDialog : TColorDialog;
    FLoading : Boolean;
    procedure SetRedEyeEffectSize(const Value: integer);

    { Private declarations }
  public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
  procedure DoEffect(Bitmap : TBitmap; Rect : TRect; FullImage : Boolean); override;
  procedure EffectSizeScrollChange(Sender : TObject);
  Procedure DoBorder(Bitmap : TBitmap; aRect : TRect); override;
  procedure EyeColorChange(Sender : TObject);
  procedure DoSaveSettings(Sender : TObject); override;
  class function ID: string; override;

   Procedure SetProperties(Properties : String); override;
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
    { Public declarations }
  published
    Property RedEyeEffectSize : integer read FRedEyeEffectSize write SetRedEyeEffectSize;
  end;

implementation

{ TRedEyeToolPanelClass }


procedure FixRedEyes(Image: TBitmap; Rect: TRect; RedEyeEffectSize : Integer; EyeColorIntex : integer; CustomColor : TColor);
var
  ih,iw,h,w,ix,iy, i,j : integer;
  x,lay, R : extended;
  Histogramm : T255IntArray;
  c,cc,nc : integer;
  Count : int64;
  Rx : T255ByteArray;
  Rct : TRect;
  Xdp : TArPARGB;
  Xc,Yc,Mx,My, xMx, xMy, t, rb, re : integer;
  gray : Byte;
  rn,cn : integer;
  xx : array [0..255] of integer;
  EyeR,EyeG,EyeB : byte;
  Procedure ReplaceRedA(var RGB : TRGB; rx,gx,bx : byte; l: extended);
  begin
    RGB.r:=Round(rx*RGB.r*l/255+RGB.r*(1-l));
    RGB.g:=Round(gx*RGB.g*l/255+RGB.g*(1-l));
    RGB.b:=Round(bx*RGB.b*l/255+RGB.b*(1-l));
  end;

begin

 Case EyeColorIntex of
 0: begin EyeR:=$00; EyeG:=$AA; EyeB:=$60; end;
 1: begin EyeR:=$00; EyeG:=$80; EyeB:=$FF; end;
 2: begin EyeR:=$80; EyeG:=$60; EyeB:=$00; end;
 3: begin EyeR:=$10; EyeG:=$10; EyeB:=$10; end;
 4: begin EyeR:=$80; EyeG:=$80; EyeB:=$80; end;
 5: begin EyeR:=GetRValue(CustomColor); EyeG:=GetGValue(CustomColor); EyeB:=GetBValue(CustomColor); end;
  else begin EyeR:=$00; EyeG:=$00; EyeB:=$00; end;
 end;

 Rct.Top:=Min(Rect.Top,Rect.Bottom);
 Rct.Bottom:=Max(Rect.Top,Rect.Bottom);
 Rct.Left:=Min(Rect.Left,Rect.Right);
 Rct.Right:=Max(Rect.Left,Rect.Right);
 Rect:=Rct;

 for i:=0 to 30 do
 xx[i]:=255;
 for i:=30 to 255 do
 begin
  xx[i]:=Round(800/(sqrt(sqrt(sqrt(i-29)))));
 end;

 SetLength(Xdp,Image.height);
 for i:=0 to Image.Height-1 do
 Xdp[i]:=Image.ScanLine[i];

 c:=0;
 cc:=1;
 Histogramm:=GistogrammRW(Image,Rect,Count);
 for i:=255 downto 1 do
 begin
  inc(c,Histogramm[i]);
  if (c>Count div 10) or (Histogramm[i]>10) then
  begin
   cc:=i;
   break;
  end;
 end;
 
 for i:=0 to 255 do
 begin
  Rx[i]:=Min(255,Round((255/cc)*i));
 end;
 c:=Round(cc*RedEyeEffectSize/100);


 Mx:=0;
 My:=0;
 xMx:=0;
 xMy:=0;

 for i:=Rect.left to Rect.Right do
 for j:=Rect.Top to Rect.Bottom do
 if (i>=0) and (j>=0) and (i<Image.Width-1) and (j<Image.Height-1) then
 begin
  t:=Xdp[j,i].r-max(Xdp[j,i].g,Xdp[j,i].b);
  if t>c then
  begin
   xMx:=xMx+t*i;
   Mx:=Mx+t;

   xMy:=xMy+t*j;
   My:=My+t;
  end;
 end;
 if (Mx=0) or (My=0) then exit;
 Xc:=Round(xMx/Mx);
 Yc:=Round(xMy/My);
 ih:=(Rect.Bottom-Rect.Top) div 2;
 h:=ih+Rect.Top;
 iw:=(Rect.Right-Rect.left) div 2;
 w:=iw+Rect.left;
 for i:=Rect.left to Rect.Right do
 begin
  ix:=i-w;
  iy:=0;
  if iw*iw=0 then exit;
  if (ih*ih)-((ih*ih)/(iw*iw))*(ix*ix)>0 then
  iy:=Round(sqrt((ih*ih)-((ih*ih)/(iw*iw))*(ix*ix))) else continue;
  for j:=h-iy to h+iy do
  begin
   if (i>=0) and (j>=0) and (i<Image.Width-1) and (j<Image.Height-1) then
   begin
   rn:=xx[round(Xdp[j,i].r*0.3+Xdp[j,i].g*0.59+Xdp[j,i].b*0.11)];
   cn:=math.max(Xdp[j,i].r-max(Xdp[j,i].g,Xdp[j,i].b),0);
   cn:=Min(255,round(cn*rn/255));
   if Xdp[j,i].r-max(Xdp[j,i].g,Xdp[j,i].b)>c then
   if Xdp[j,i].r/(Xdp[j,i].r+Xdp[j,i].g+Xdp[j,i].b)>0.40 then ReplaceRedA(Xdp[j,i],EyeR,EyeG,EyeB,cn/255);
   end;
  end;
 end;

end;

constructor TRedEyeToolPanelClass.Create(AOwner: TComponent);
begin
  inherited; 
  FLoading:=true;
 EffectSizelabel:=TLabel.Create(self);
 EffectSizelabel.Left:=8;
 EffectSizelabel.Top:=EditHeight.Top+EditHeight.Height+5;
 EffectSizelabel.Caption:=TEXT_MES_RED_EYE_EFFECT_SIZE_F;
 EffectSizelabel.Parent:=self;

 EffectSizeScroll := TTrackBar.Create(AOwner);
 EffectSizeScroll.Top:=EffectSizelabel.Top+EffectSizelabel.Height+5;
 EffectSizeScroll.Width:=150;
 EffectSizeScroll.Left:=8;
 EffectSizeScroll.Max:=100;
 EffectSizeScroll.Min:=5;
 EffectSizeScroll.OnChange:=EffectSizeScrollChange;
 EffectSizeScroll.Position:=50;
 EffectSizeScroll.Parent:=AOwner as TWinControl;

 FEyeColorLabel := TLabel.Create(AOwner);
 FEyeColorLabel.Left:=8;
 FEyeColorLabel.Top:=EffectSizeScroll.Top+EffectSizeScroll.Height+5;
 FEyeColorLabel.Parent:=self;
 FEyeColorLabel.Caption:=TEXT_MES_EYE_COLOR+':';

 FEyeColor := TComboBox.Create(AOwner);
 FEyeColor.Left:=8;
 FEyeColor.Top:=FEyeColorLabel.Top+FEyeColorLabel.Height+5;
 FEyeColor.Width:=150;
 FEyeColor.OnChange:=EyeColorChange;
 FEyeColor.Style:=csDropDownList;
 FEyeColor.Parent:=AOwner as TWinControl;
 FEyeColor.Items.Add(TEXT_MES_COLOR_GREEN);
 FEyeColor.Items.Add(TEXT_MES_COLOR_BLUE);
 FEyeColor.Items.Add(TEXT_MES_COLOR_BROWN);
 FEyeColor.Items.Add(TEXT_MES_COLOR_BLACK);
 FEyeColor.Items.Add(TEXT_MES_COLOR_GRAY);
 FEyeColor.Items.Add(TEXT_MES_COLOR_CUSTOM);

 FEyeColor.ItemIndex:=1;
 FCustomColor:=$0;
 FCustomColorDialog := TColorDialog.Create(AOwner);

 {$IFDEF PHOTODB}
 EffectSizeScroll.Position:=DBKernel.ReadInteger('Editor','RedEyeToolSize',50);
 FEyeColor.ItemIndex:=DBKernel.ReadInteger('Editor','RedEyeColor',0);
 FCustomColor:=DBKernel.ReadInteger('Editor','RedEyeColorCustom',0);
 {$ENDIF}



 SaveSettingsLink.Top:=FEyeColor.Top+FEyeColor.Height+15;
 MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 FLoading:=false;

end;

destructor TRedEyeToolPanelClass.Destroy;
begin
 EffectSizeScroll.free;
 EffectSizelabel.Free;
 FCustomColorDialog.Free;
 FEyeColor.Free;
  inherited;
end;

procedure TRedEyeToolPanelClass.DoEffect(Bitmap: TBitmap; Rect: TRect; FullImage : Boolean);
begin
 FixRedEyes(Bitmap,Rect,FRedEyeEffectSize,FEyeColor.ItemIndex,FCustomColor);
end;

procedure TRedEyeToolPanelClass.DoBorder(Bitmap: TBitmap; aRect: TRect);
var
  nn,h2,w2,w,h,i,ii,j:integer;
  Rct : TRect;
  dd : extended;
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
 w:=Rct.Right-Rct.Left;
 h:=Rct.Bottom-Rct.Top;
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


 if w*h=0 then exit;
 w2:=w div 2;
 h2:=h div 2;
 if w2*h2=0 then exit;
 dd:=min(1/w2,1/h2);
 nn:=Round(2*pi/dd);
 for ii:=1 to nn do
 begin
  i:=aRect.Left+w2+Round((w/2)*cos(dd*ii));
  j:=aRect.Top+h2+Round((h/2)*sin(dd*ii));
  if (i>=0) and (j>=0) and (i<Bitmap.Width-1) and (j<Bitmap.Height-1) then
  Border(i,j,Xdp[j,i]);
 end;

end;

procedure TRedEyeToolPanelClass.EffectSizeScrollChange(Sender: TObject);
begin
 FRedEyeEffectSize:=EffectSizeScroll.Position;
 EffectSizelabel.Caption:=format(TEXT_MES_RED_EYE_EFFECT_SIZE_F,[EffectSizeScroll.Max- EffectSizeScroll.Position]);
 if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
end;

procedure TRedEyeToolPanelClass.SetRedEyeEffectSize(const Value: integer);
begin
  FRedEyeEffectSize := Value;
end;

procedure TRedEyeToolPanelClass.EyeColorChange(Sender: TObject);
begin
 FCustomColorDialog.Color:=FCustomColor;
 if FEyeColor.ItemIndex=5 then
 if not FLoading then
 if FCustomColorDialog.Execute then
 begin
  FCustomColor:=FCustomColorDialog.Color;
 end else FEyeColor.ItemIndex:=0;
 EffectSizeScrollChange(Sender);
end;

procedure TRedEyeToolPanelClass.DoSaveSettings(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 DBKernel.WriteInteger('Editor','RedEyeToolSize',EffectSizeScroll.Position);
 DBKernel.WriteInteger('Editor','RedEyeColor',FEyeColor.ItemIndex);
 DBKernel.WriteInteger('Editor','RedEyeColorCustom',FCustomColor);
 {$ENDIF}
end;

class function TRedEyeToolPanelClass.ID: string;
begin
 Result:='{3D2B384F-F4EB-457C-A11C-BDCE1C20FFFF}';
end;

procedure TRedEyeToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TRedEyeToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

end.
