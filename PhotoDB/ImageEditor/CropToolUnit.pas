unit CropToolUnit;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, language,
  EffectsLanguage, GraphicsBaseTypes, UnitDBKernel, Menus;

type
  TCropToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SaveSettingsLink: TWebLink;
    EditWidth: TEdit;
    EditHeight: TEdit;
    EditWidthLabel: TLabel;
    EditHeightLabel: TLabel;
    FFirstPoint: TPoint;
    FSecondPoint: TPoint;
    FMakingRect: Boolean;
    FResizingRect: Boolean;
    FxTop: Boolean;
    FxLeft: Boolean;
    FxRight: Boolean;
    FxBottom: Boolean;
    FxCenter: Boolean;
    FBeginDragPoint: TPoint;
    FBeginFirstPoint: TPoint;
    FBeginSecondPoint: TPoint;
    EditLock: Boolean;
    FProcRecteateImage: TNotifyEvent;
    CheckProportions: TCheckBox;
    EditPrWidth: TEdit;
    EditPrHeight: TEdit;
    EditPrWidthLabel: TLabel;
    EditPrHeightLabel: TLabel;
    FKeepProportions: Boolean;
    FProportionsWidth: Integer;
    FProportionsHeight: Integer;
    ComboBoxProp: TComboBox;
    ComboBoxPropLabel : TLabel;
    procedure SetFirstPoint(const Value: TPoint);
    procedure SetSecondPoint(const Value: TPoint);
    procedure SetMakingRect(const Value: Boolean);
    procedure SetResizingRect(const Value: Boolean);
    procedure SetxBottom(const Value: Boolean);
    procedure SetxLeft(const Value: Boolean);
    procedure SetxRight(const Value: Boolean);
    procedure SetxTop(const Value: Boolean);
    procedure SetxCenter(const Value: boolean);
    procedure SetBeginDragPoint(const Value: TPoint);
    procedure SetBeginFirstPoint(const Value: TPoint);
    procedure SetBeginSecondPoint(const Value: TPoint);
    procedure EditWidthChanged(Sender : TObject);
    procedure EditheightChanged(Sender : TObject);
    procedure SetProcRecteateImage(const Value: TNotifyEvent);
    procedure SetKeepProportions(const Value: boolean);
    procedure SetProportionsHeight(const Value: Integer);
    procedure SetProportionsWidth(const Value: Integer);
  public
   class function ID: string; override;
   function GetProperties : string; override;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   procedure ClosePanel; override;
   procedure ClosePanelEvent(Sender : TObject);
   procedure CheckProportionsClick(Sender : TObject);
   procedure EditPrWidthChange(Sender : TObject);
   procedure EditPrHeightChange(Sender : TObject);
   procedure DoSaveSettings(Sender : TObject);
   Property FirstPoint : TPoint read FFirstPoint write SetFirstPoint;
   Property SecondPoint : TPoint read FSecondPoint write SetSecondPoint;
   Property MakingRect : Boolean read FMakingRect write SetMakingRect;
   Property ResizingRect : Boolean read FResizingRect write SetResizingRect;
   Procedure DoCropToolToImage(Image : TBitmap; Rect : TRect);
   Procedure ChangeSize(Sender : TObject);
   Property xTop : Boolean read FxTop write SetxTop;
   Property xLeft : Boolean read FxLeft write SetxLeft;
   Property xBottom : Boolean read FxBottom write SetxBottom;
   Property xRight : Boolean read FxRight write SetxRight;
   Property xCenter : Boolean read FxCenter write SetxCenter;
   Property BeginDragPoint : TPoint read FBeginDragPoint write SetBeginDragPoint;
   Property BeginFirstPoint : TPoint read FBeginFirstPoint write SetBeginFirstPoint;
   Property BeginSecondPoint : TPoint read FBeginSecondPoint write SetBeginSecondPoint;

   Property ProcRecteateImage : TNotifyEvent read FProcRecteateImage write SetProcRecteateImage;
   Procedure MakeTransform; override;
   Procedure DoMakeImage(Sender : TObject);
   Property KeepProportions : boolean read FKeepProportions write SetKeepProportions;
   Property ProportionsWidth : Integer read FProportionsWidth write SetProportionsWidth;
   Property ProportionsHeight : Integer read FProportionsHeight write SetProportionsHeight;

   Procedure SetProperties(Properties : String); override;
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
    { Public declarations }
  end;

implementation

uses ImEditor;

{ TCropToolPanelClass }

procedure TCropToolPanelClass.CheckProportionsClick(Sender: TObject);
begin
 KeepProportions:=CheckProportions.Checked;
 EditPrWidth.Enabled:=CheckProportions.Checked;
 EditPrHeight.Enabled:=CheckProportions.Checked;
end;

procedure TCropToolPanelClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(self);
 inherited;
end;

procedure TCropToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
 ClosePanel;
end;

constructor TCropToolPanelClass.Create(AOwner: TComponent);
var
 IcoOK, IcoCancel, IcoSave : TIcon;
begin
 inherited;
 Align:=AlClient;
 FMakingRect:=false;
 FResizingRect:=false;
 EditLock:=false;
 FProcRecteateImage:=nil;
 KeepProportions:=false;
 FProportionsWidth:=15;
 FProportionsHeight:=10;

 EditWidth := TEdit.Create(AOwner);
 EditWidth.OnChange:=EditWidthChanged;
 EditWidth.Top:=25;
 EditWidth.Width:=60;
 EditWidth.Left:=10;
 EditWidth.Text:='0';
 EditWidth.Parent:=Self;

 EditHeight := TEdit.Create(AOwner);
 EditHeight.OnChange:=EditHeightChanged;
 EditHeight.Top:=25;
 EditHeight.Width:=60;
 EditHeight.Left:=EditWidth.Left+EditWidth.Width+10;
 EditHeight.Parent:=Self;
 EditHeight.Text:='0';

 EditWidthLabel := TLabel.Create(AOwner);
 EditWidthLabel.Caption:=TEXT_MES_WIDTH;
 EditWidthLabel.Top:=10;
 EditWidthLabel.Left:= 10;
 EditWidthLabel.Parent:=Self;

 EditHeightLabel := TLabel.Create(AOwner);
 EditHeightLabel.Caption:=TEXT_MES_HEIGHT;
 EditHeightLabel.Top:=10;
 EditHeightLabel.Left:=EditWidth.Left+EditWidth.Width+10;
 EditHeightLabel.Parent:=Self;

 CheckProportions := TCheckBox.Create(AOwner);
 CheckProportions.Top:=EditWidth.Top+EditWidth.Height+5;
 CheckProportions.Left:=10;
 CheckProportions.Width:=150;
 CheckProportions.Caption:=TEXT_MES_IM_KEEP_PROPORTIONS;
 CheckProportions.Enabled:=true;
 CheckProportions.Parent:=Self;
 CheckProportions.OnClick:=CheckProportionsClick;

 EditPrWidthLabel := TLabel.Create(AOwner);
 EditPrWidthLabel.Caption:=TEXT_MES_WIDTH;
 EditPrWidthLabel.Left:= 10;
 EditPrWidthLabel.Top:=CheckProportions.Top+CheckProportions.Height+5;
 EditPrWidthLabel.Parent:=Self;

 EditPrWidth := TEdit.Create(AOwner);
 EditPrWidth.OnChange:=EditWidthChanged;
 EditPrWidth.Top:=EditPrWidthLabel.Top+EditPrWidthLabel.Height+5;
 EditPrWidth.Width:=60;
 EditPrWidth.Left:=10;
 EditPrWidth.Text:=IntToStr(FProportionsWidth);
 EditPrWidth.Enabled:=false;
 EditPrWidth.OnChange:=EditPrWidthChange;
 EditPrWidth.Parent:=Self;

 EditPrHeight := TEdit.Create(AOwner);
 EditPrHeight.OnChange:=EditHeightChanged;
 EditPrHeight.Top:=EditPrWidthLabel.Top+EditPrWidthLabel.Height+5;
 EditPrHeight.Width:=60;
 EditPrHeight.Left:=EditPrWidth.Left+EditPrWidth.Width+10;
 EditPrHeight.Text:=IntToStr(FProportionsHeight);
 EditPrHeight.Enabled:=false;
 EditPrHeight.OnChange:=EditPrHeightChange;
 EditPrHeight.Parent:=Self;

 EditPrHeightLabel := TLabel.Create(AOwner);
 EditPrHeightLabel.Caption:=TEXT_MES_HEIGHT;
 EditPrHeightLabel.Top:=CheckProportions.Top+CheckProportions.Height+5;
 EditPrHeightLabel.Left:=EditPrWidth.Left+EditPrWidth.Width+10;
 EditPrHeightLabel.Parent:=Self;

 ComboBoxPropLabel := TLabel.Create(AOwner);
 ComboBoxPropLabel.Caption:=TEXT_MES_PROPORTIONS;
 ComboBoxPropLabel.Top:=EditPrHeight.Top+EditPrHeight.Height+5;
 ComboBoxPropLabel.Left:=8;
 ComboBoxPropLabel.Parent:=Self;

 ComboBoxProp := TComboBox.Create(nil);
 ComboBoxProp.Top:=ComboBoxPropLabel.Top+ComboBoxPropLabel.Height+5;
 ComboBoxProp.Left:=8;
 ComboBoxProp.Width:=170;
 ComboBoxProp.Parent:=AOwner as TWinControl;
 ComboBoxProp.OnChange:=ChangeSize;
 ComboBoxProp.Style:=csDropDownList;
 ComboBoxProp.Items.Add('1/1');
 ComboBoxProp.Items.Add('1/2');
 ComboBoxProp.Items.Add('2/3');
 ComboBoxProp.Items.Add('3/4');
 ComboBoxProp.Items.Add('8/12');
 ComboBoxProp.Items.Add('9/13');
 ComboBoxProp.Items.Add('10/15');
 ComboBoxProp.Items.Add('13/18');
 ComboBoxProp.Items.Add('20/25');
 ComboBoxProp.Items.Add('2/1');
 ComboBoxProp.Items.Add('3/2');
 ComboBoxProp.Items.Add('4/3');
 ComboBoxProp.Items.Add('12/8');
 ComboBoxProp.Items.Add('13/9');
 ComboBoxProp.Items.Add('15/10');
 ComboBoxProp.Items.Add('18/13');
 ComboBoxProp.Items.Add('25/20');
 ComboBoxProp.ItemIndex:=0;

 IcoSave:=TIcon.Create;
 IcoSave.Handle:=LoadIcon(DBKernel.IconDllInstance,'SAVETOFILE');

 SaveSettingsLink := TWebLink.Create(nil);
 SaveSettingsLink.Parent:=AOwner as TWinControl;
 SaveSettingsLink.Text:=TEXT_MES_SAVE_SETTINGS;
 SaveSettingsLink.Top:=ComboBoxProp.Top+ComboBoxProp.Height+10;
 SaveSettingsLink.Left:=10;
 SaveSettingsLink.Visible:=true;
 SaveSettingsLink.Color:=ClBtnface;
 SaveSettingsLink.OnClick:=DoSaveSettings;
 SaveSettingsLink.Icon:=IcoSave;
 IcoSave.free;

 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 MakeItLink:= TWebLink.Create(Self);
 MakeItLink.Parent:=Self;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
 MakeItLink.Left:=10;
 MakeItLink.Visible:=true;
 MakeItLink.Color:=ClBtnface;
 MakeItLink.OnClick:=DoMakeImage;
 MakeItLink.Icon:=IcoOK;
 MakeItLink.ImageCanRegenerate:=True;
 IcoOK.Free;

 CloseLink := TWebLink.Create(Self);
 CloseLink.Parent:=Self;
 CloseLink.Text:=TEXT_MES_IM_CLOSE_TOOL_PANEL;
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 CloseLink.Left:=10;
 CloseLink.Visible:=true;
 CloseLink.Color:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;
 IcoCancel.Free;

 CloseLink.ImageCanRegenerate:=True;

 ComboBoxProp.ItemIndex:=DBKernel.ReadInteger('Editor','Crop_Tool_PropSelect',0);
 EditPrWidth.Text:=IntToStr(DBKernel.ReadInteger('Editor','Crop_Tool_Prop_W',15));
 EditPrHeight.Text:=IntToStr(DBKernel.ReadInteger('Editor','Crop_Tool_Prop_H',10));
 CheckProportions.Checked:=DBKernel.ReadBool('Editor','Crop_Tool_Save_Prop',false);
end;

destructor TCropToolPanelClass.Destroy;
begin
 ComboBoxProp.Free;
 ComboBoxPropLabel.Free;
 CheckProportions.Free;
 EditPrWidth.Free;
 EditPrHeight.Free;
 EditPrWidthLabel.Free;
 EditPrHeightLabel.Free;

 EditWidthLabel.Free;
 EditHeightLabel.Free;
 EditWidth.Free;
 EditHeight.Free;
 CloseLink.Free;
 SaveSettingsLink.Free;

 inherited;
end;

procedure TCropToolPanelClass.DoCropToolToImage(Image: TBitmap;
  Rect: TRect);
var
  w,h,i,j:integer;
  Xdp : array of PARGB;
  rc, gc, bc : byte;
  Rct : TRect;

  Procedure Darkness(var RGB : TRGB);
  begin
   RGB.r:=RGB.r div 3;
   RGB.g:=RGB.g div 3;
   RGB.b:=RGB.b div 3;
  end;

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

  Procedure Center(var RGB : TRGB);
  begin
   RGB.r:=not RGB.r;
   RGB.g:=not RGB.g;
   RGB.b:=not RGB.b;
  end;

begin
 Rct.Top:=Min(Rect.Top,Rect.Bottom);
 Rct.Bottom:=Max(Rect.Top,Rect.Bottom);
 Rct.Left:=Min(Rect.Left,Rect.Right);
 Rct.Right:=Max(Rect.Left,Rect.Right);
 Rect:=Rct;
 rc:=GetRValue(ColorToRGB(Color));
 gc:=GetGValue(ColorToRGB(Color));
 bc:=GetBValue(ColorToRGB(Color));
 Image.PixelFormat:=pf24bit;

 SetLength(Xdp,Image.height);
 for i:=0 to Image.Height-1 do
 Xdp[i]:=Image.ScanLine[i];
 for i:=0 to Min(Rect.Top-1,Image.Height-1) do
 begin
  for j:=0 to Image.Width-1 do
  begin
   if (i=Rect.Top-1) and (j>Rect.Left) and (j<Rect.Right) then
   begin
    Border(i,j,Xdp[i,j]);
   end else
   begin
    Darkness(Xdp[i,j]);
   end;
  end;
 end;
 for i:=Max(0,Rect.Bottom) to Image.Height-1 do
 for j:=0 to Image.Width-1 do
 begin
  if (i=Rect.Bottom) and (j>Rect.Left) and (j<Rect.Right) then
  begin
   Border(i,j,Xdp[i,j]);
  end else
  begin
   Darkness(Xdp[i,j]);
  end;
 end;
 for i:=Max(0,Rect.Top) to Min(Rect.Bottom-1,Image.Height-1) do
 begin
  for j:=0 to Min(Rect.Left-1,Image.Width-1) do
  begin
   Darkness(Xdp[i,j]);
  end;
  j:=Max(0,Min(Rect.Left-1,Image.Width-1));
  Border(i,j,Xdp[i,j]);
 end;
 for i:=Max(0,Rect.Top) to Min(Rect.Bottom-1,Image.Height-1) do
 begin
  for j:=Max(0,Rect.Right) to Image.Width-1 do
  begin
   Darkness(Xdp[i,j]);
  end;
  j:=Min(Image.Width-1,Max(0,Rect.Right));
  Border(i,j,Xdp[i,j]);
 end;

 h:=abs(Rect.Top-Rect.Bottom) div 8;
 w:=abs(Rect.Left-Rect.Right) div 8;

 if ((Rect.Top+Rect.Bottom) div 2<Image.Height-1) and ((Rect.Top+Rect.Bottom) div 2>0) then
 for i:=(Rect.Left+Rect.Right) div 2-w to (Rect.Left+Rect.Right) div 2+w do
 if (i>0) and (i<Image.Width-1) then
 Center(Xdp[(Rect.Top+Rect.Bottom) div 2,i]);

 if ((Rect.Left+Rect.Right) div 2<Image.Width-1) and ((Rect.Left+Rect.Right) div 2>0) then
 for i:=(Rect.Top+Rect.Bottom) div 2-h to (Rect.Top+Rect.Bottom) div 2+h do
 if (i>0) and (i<Image.Height-1) then
 Center(Xdp[i,(Rect.Left+Rect.Right) div 2]);

end;

procedure TCropToolPanelClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TCropToolPanelClass.EditheightChanged(Sender: TObject);
var
  Point1,Point2,P : TPoint;
  w,h : integer;
  prop : Extended;

  function Znak(x : Extended) : Extended;
  begin
   if x>=0 then Result:=1 else Result:=-1;
  end;

begin
 if not EditLock then
 begin
  if Image=nil then exit;
  h:=StrToIntDef(EditHeight.Text,15);
  Point1.X:=Max(0,Min(FirstPoint.X,SecondPoint.X));
  Point1.Y:=Max(0,Min(FirstPoint.Y,SecondPoint.Y));
  Point2.X:=Min(Max(FirstPoint.X,SecondPoint.X),Image.Width);
  Point2.Y:=Min(Max(FirstPoint.Y,SecondPoint.Y),Image.Height);
  FFirstPoint:=Point1;
  FSecondPoint:=Point2;

  P.X:=math.Min(Image.Width,math.max(0,SecondPoint.X));
  P.Y:=math.Min(Image.Height,math.max(0,FirstPoint.Y+h));


    if KeepProportions then
    begin
     w:=1;
     h:=-(FirstPoint.Y-p.Y);
     if w*h=0 then exit;
     if ProportionsHeight<>0 then
     Prop:=ProportionsWidth/ProportionsHeight else
     Prop:=1;
     if abs(w/h)<abs(Prop) then
     begin
      if w<0 then w:=-Round(abs(h)*(Prop)) else
      w:=Round(abs(h)*(Prop));
      if FirstPoint.X+w>Image.Width then
      begin
       w:=Image.Width-FirstPoint.X;
       h:=Round(Znak(h)*w/prop);
      end;
      if FirstPoint.X+w<0 then
      begin
       w:=-FirstPoint.X;
       h:=-Round(Znak(h)*w/prop);
      end;
      EditLock:=true;
      SecondPoint:=Point(FirstPoint.X+w,FirstPoint.Y+h);
      EditLock:=false;
     end else
     begin
      if h<0 then h:=-Round(abs(w)*(1/Prop)) else
      h:=Round(abs(w)*(1/Prop));
      if FirstPoint.Y+h>Image.height then
      begin
       h:=Image.height-FirstPoint.Y;
       w:=Round(Znak(w)*(h*Prop));
      end;
      if FirstPoint.Y+h<0 then
      begin
       h:=-FirstPoint.Y;
       w:=-Round(Znak(w)*(h*Prop));
      end;
      EditLock:=true;
      SecondPoint:=Point(FirstPoint.X+w,FirstPoint.Y+h);
      EditLock:=false;
     end;
    end else
    begin
     EditLock:=true;
     SecondPoint:=p;
     EditLock:=false;
    end;


  if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
 end;
end;

procedure TCropToolPanelClass.EditPrWidthChange(Sender: TObject);
begin
 FProportionsWidth:=StrToIntDef(EditPrWidth.Text,1);
end;

procedure TCropToolPanelClass.EditPrHeightChange(Sender: TObject);
begin
 FProportionsHeight:=StrToIntDef(EditPrHeight.Text,1);
end;

procedure TCropToolPanelClass.EditWidthChanged(Sender: TObject);
var
  Point1,Point2,P : TPoint;
  w,h : integer;
  prop : Extended;

  function Znak(x : Extended) : Extended;
  begin
   if x>=0 then Result:=1 else Result:=-1;
  end;

begin
 if not EditLock then
 begin
  if Image=nil then exit;
  w:=StrToIntDef(EditWidth.Text,15);
  Point1.X:=Max(0,Min(FirstPoint.X,SecondPoint.X));
  Point1.Y:=Max(0,Min(FirstPoint.Y,SecondPoint.Y));
  Point2.X:=Min(Max(FirstPoint.X,SecondPoint.X),Image.Width);
  Point2.Y:=Min(Max(FirstPoint.Y,SecondPoint.Y),Image.Height);
  FFirstPoint:=Point1;
  FSecondPoint:=Point2;
  P.X:=math.Min(Image.Width,math.max(0,FirstPoint.X+W));
  P.Y:=math.Min(Image.Height,math.max(0,SecondPoint.Y));

    if KeepProportions then
    begin
     w:=-(FirstPoint.X-p.X);
     h:=1;
     if w*h=0 then exit;
     if ProportionsHeight<>0 then
     Prop:=ProportionsWidth/ProportionsHeight else
     Prop:=1;
     if abs(w/h)<abs(Prop) then
     begin
      if w<0 then w:=-Round(abs(h)*(Prop)) else
      w:=Round(abs(h)*(Prop));
      if FirstPoint.X+w>Image.Width then
      begin
       w:=Image.Width-FirstPoint.X;
       h:=Round(Znak(h)*w/prop);
      end;
      if FirstPoint.X+w<0 then
      begin
       w:=-FirstPoint.X;
       h:=-Round(Znak(h)*w/prop);
      end;
      EditLock:=true;
      SecondPoint:=Point(FirstPoint.X+w,FirstPoint.Y+h);
      EditLock:=false;
     end else
     begin
      if h<0 then h:=-Round(abs(w)*(1/Prop)) else
      h:=Round(abs(w)*(1/Prop));
      if FirstPoint.Y+h>Image.height then
      begin
       h:=Image.height-FirstPoint.Y;
       w:=Round(Znak(w)*(h*Prop));
      end;
      if FirstPoint.Y+h<0 then
      begin
       h:=-FirstPoint.Y;
       w:=-Round(Znak(w)*(h*Prop));
      end;
      EditLock:=true;
      SecondPoint:=Point(FirstPoint.X+w,FirstPoint.Y+h);
      EditLock:=false;
     end;
    end else
    begin
     EditLock:=true;
     SecondPoint:=p;
     EditLock:=false;
    end;

  if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
 end;
end;

procedure TCropToolPanelClass.MakeTransform;
var
  Bitmap : TBitmap;
  Point1, Point2 : TPoint;
  i,j : integer;
  ps, pd : PARGB;
begin
 inherited;
 Bitmap := TBitmap.Create;
 Bitmap.PixelFormat:=pf24bit;
 Point1.X:=Max(0,Min(FirstPoint.X,SecondPoint.X));
 Point1.Y:=Max(0,Min(FirstPoint.Y,SecondPoint.Y));
 Point2.X:=Min(Max(FirstPoint.X,SecondPoint.X),Image.Width);
 Point2.Y:=Min(Max(FirstPoint.Y,SecondPoint.Y),Image.Height);
 Bitmap.Width:=Point2.X-Point1.X;
 Bitmap.Height:=Point2.Y-Point1.Y;

 for i:=Point1.Y to Point2.Y-1 do
 begin
  ps:=Image.ScanLine[i];
  pd:=Bitmap.ScanLine[i-(Point1.Y)];
  for j:=Point1.X to Point2.X-1 do
  begin
   pd[j-(Point1.X)].r:=ps[j].r;
   pd[j-(Point1.X)].g:=ps[j].g;
   pd[j-(Point1.X)].b:=ps[j].b;
  end;

 end;
 Image.Free;
 ImageHistory.Add(Bitmap,'{'+ID+'}['+GetProperties+']');
 SetImagePointer(Bitmap);
 ClosePanel;
end;

procedure TCropToolPanelClass.SetBeginDragPoint(const Value: TPoint);
begin
  FBeginDragPoint := Value;
end;

procedure TCropToolPanelClass.SetBeginFirstPoint(const Value: TPoint);
begin
  FBeginFirstPoint := Value;
end;

procedure TCropToolPanelClass.SetBeginSecondPoint(const Value: TPoint);
begin
  FBeginSecondPoint := Value;
end;

procedure TCropToolPanelClass.SetFirstPoint(const Value: TPoint);
begin
 FFirstPoint := Value;
 EditLock:=true;
 EditWidth.Text:=IntToStr(Abs(FFirstPoint.X-FSecondPoint.X));
 Editheight.Text:=IntToStr(Abs(FFirstPoint.Y-FSecondPoint.Y));
 EditLock:=false;
end;

procedure TCropToolPanelClass.SetKeepProportions(const Value: boolean);
begin
 FKeepProportions := Value;
end;

procedure TCropToolPanelClass.SetMakingRect(const Value: Boolean);
begin
  FMakingRect := Value;
end;

procedure TCropToolPanelClass.SetProcRecteateImage(
  const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TCropToolPanelClass.SetProportionsHeight(const Value: Integer);
begin
  FProportionsHeight := Value;
end;

procedure TCropToolPanelClass.SetProportionsWidth(const Value: Integer);
begin
  FProportionsWidth := Value;
end;

procedure TCropToolPanelClass.SetResizingRect(const Value: Boolean);
begin
  FResizingRect := Value;
end;

procedure TCropToolPanelClass.SetSecondPoint(const Value: TPoint);
begin
 FSecondPoint := Value;
 EditLock:=true;
 EditWidth.Text:=IntToStr(Abs(FFirstPoint.X-FSecondPoint.X));
 Editheight.Text:=IntToStr(Abs(FFirstPoint.Y-FSecondPoint.Y));
 EditLock:=false;
end;

procedure TCropToolPanelClass.SetxBottom(const Value: Boolean);
begin
  FxBottom := Value;
end;

procedure TCropToolPanelClass.SetxCenter(const Value: boolean);
begin
  FxCenter := Value;
end;

procedure TCropToolPanelClass.SetxLeft(const Value: Boolean);
begin
  FxLeft := Value;
end;

procedure TCropToolPanelClass.SetxRight(const Value: Boolean);
begin
  FxRight := Value;
end;

procedure TCropToolPanelClass.SetxTop(const Value: Boolean);
begin
  FxTop := Value;
end;

procedure TCropToolPanelClass.DoSaveSettings(Sender: TObject);
begin
  DBKernel.WriteInteger('Editor', 'Crop_Tool_PropSelect', ComboBoxProp.ItemIndex);
  DBKernel.WriteInteger('Editor', 'Crop_Tool_Prop_W', StrToIntDef(EditPrWidth.Text, 15));
  DBKernel.WriteInteger('Editor', 'Crop_Tool_Prop_H', StrToIntDef(EditPrHeight.Text, 10));
  DBKernel.WriteBool('Editor', 'Crop_Tool_Save_Prop', CheckProportions.Checked);
end;

procedure TCropToolPanelClass.ChangeSize(Sender: TObject);
var
  i : integer;
  S : String;
begin
 S:=ComboBoxProp.Text;
 for i:=1 to Length(S) do
 if S[i]='/' then
 begin
  EditPrHeight.Text:=Copy(S,1,i-1);
  EditPrWidth.Text:=Copy(S,i+1,length(S)-i);
  CheckProportions.Checked:=True;
  break;
 end;
end;

class function TCropToolPanelClass.ID: string;
begin
 Result:='{5AA5CA33-220E-4D1D-82C2-9195CE6DF8E4}';
end;

function TCropToolPanelClass.GetProperties: string;
begin
//
end;

procedure TCropToolPanelClass.SetProperties(Properties: String);
begin
//
end;

procedure TCropToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
//
end;

end.
