unit CustomSelectTool;

interface

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
     GraphicsCool, Math, SysUtils, ImageHistoryUnit, Effects, ComCtrls,
     GraphicsBaseTypes, Language;

type TCustomSelectToolClass = Class(TToolsPanelClass)
  private

  EditWidthLabel : TStaticText;
  EditHeightLabel : TStaticText;
    FFirstPoint: TPoint;
    FSecondPoint: TPoint;
    FMakingRect: Boolean;
    FResizingRect: Boolean;
    FxTop: Boolean;
    FxLeft: Boolean;
    FxRight: Boolean;
    FxBottom: Boolean;
    FxCenter: boolean;
    FBeginDragPoint: TPoint;
    FBeginFirstPoint: TPoint;
    FBeginSecondPoint: TPoint;
    EditLock : Boolean;
    FTerminating : Boolean;
    FAnyRect: boolean;
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
    procedure SetAnyRect(const Value: boolean);
    { Private declarations }
  public
   FProcRecteateImage: TNotifyEvent;
  EditWidth : TEdit;
  EditHeight : TEdit;
  CloseLink : TWebLink;
  MakeItLink : TWebLink;
  SaveSettingsLink : TWebLink;
   function GetProperties : string; override;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   procedure ClosePanel; override;
   procedure ClosePanelEvent(Sender : TObject);
   Property FirstPoint : TPoint read FFirstPoint write SetFirstPoint;
   Property SecondPoint : TPoint read FSecondPoint write SetSecondPoint;
   Property MakingRect : Boolean read FMakingRect write SetMakingRect;
   Property ResizingRect : Boolean read FResizingRect write SetResizingRect;
   procedure DoEffect(Image : TBitmap; Rect : TRect; FullImage : Boolean); virtual; abstract;
   procedure DoSaveSettings(Sender : TObject); virtual; abstract;
   Property xTop : Boolean read FxTop write SetxTop;
   Property xLeft : Boolean read FxLeft write SetxLeft;
   Property xBottom : Boolean read FxBottom write SetxBottom;
   Property xRight : Boolean read FxRight write SetxRight;
   Property xCenter : Boolean read FxCenter write SetxCenter;
   Property BeginDragPoint : TPoint read FBeginDragPoint write SetBeginDragPoint;
   Property BeginFirstPoint : TPoint read FBeginFirstPoint write SetBeginFirstPoint;
   Property BeginSecondPoint : TPoint read FBeginSecondPoint write SetBeginSecondPoint;
   Property ProcRecteateImage : TNotifyEvent read FProcRecteateImage write SetProcRecteateImage;
   procedure MakeTransform; override;
   procedure DoMakeImage(Sender : TObject);
   procedure DoBorder(Bitmap : TBitmap; Rect : TRect); virtual; abstract;
   Function GetZoom : Extended;
   Function Termnating : boolean;
   Property AnyRect : boolean read FAnyRect write SetAnyRect;
    { Public declarations }
  end;

implementation

{ TRedEyeToolPanelClass }

uses ImEditor, Dolphin_DB;

procedure TCustomSelectToolClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(self);
 inherited;
end;

procedure TCustomSelectToolClass.ClosePanelEvent(Sender: TObject);
begin
 ClosePanel;
end;

constructor TCustomSelectToolClass.Create(AOwner: TComponent);
var
 IcoOK, IcoCancel, IcoSave : TIcon;
begin
 inherited;
 FAnyRect:=false;
 FTerminating:=false;
 Align:=AlClient;
 FMakingRect:=false;
 FResizingRect:=false;
 EditLock:=false;
 FProcRecteateImage:=nil;

 EditWidthLabel := TStaticText.Create(AOwner);
 EditWidthLabel.Caption:=TEXT_MES_WIDTH;
 EditWidthLabel.Top:=8;
 EditWidthLabel.Left:=8;
 EditWidthLabel.Parent:=AOwner as TWinControl;

 EditWidth := TEdit.Create(AOwner);
 EditWidth.OnChange:=EditWidthChanged;
 EditWidth.Top:=EditWidthLabel.Top+EditWidthLabel.Height+5;
 EditWidth.Width:=60;
 EditWidth.Left:=8;
 EditWidth.Parent:=AOwner as TWinControl;

 EditHeight := TEdit.Create(AOwner);
 EditHeight.OnChange:=EditHeightChanged;
 EditHeight.Top:=EditWidthLabel.Top+EditWidthLabel.Height+5;
 EditHeight.Width:=60;
 EditHeight.Left:=EditWidth.Left+EditWidth.Width+5;
 EditHeight.Parent:=AOwner as TWinControl;

 EditHeightLabel := TStaticText.Create(AOwner);
 EditHeightLabel.Caption:=TEXT_MES_HEIGHT;
 EditHeightLabel.Top:=8;
 EditHeightLabel.Left:=EditHeight.Left;
 EditHeightLabel.Parent:=AOwner as TWinControl;


 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoSave:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 IcoSave.Handle:=LoadIcon(DBKernel.IconDllInstance,'SAVETOFILE');

 SaveSettingsLink := TWebLink.Create(Self);
 SaveSettingsLink.Parent:=AOwner as TWinControl;
 SaveSettingsLink.Text:=TEXT_MES_SAVE_SETTINGS;
 SaveSettingsLink.Top:=120;
 SaveSettingsLink.Left:=10;
 SaveSettingsLink.Visible:=true;
 SaveSettingsLink.BkColor:=ClBtnface;
 SaveSettingsLink.OnClick:=DoSaveSettings;
 SaveSettingsLink.Icon:=IcoSave;
 IcoSave.free;

 MakeItLink:= TWebLink.Create(Self);
 MakeItLink.Parent:=AOwner as TWinControl;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=140;
 MakeItLink.Left:=10;
 MakeItLink.Visible:=true;
 MakeItLink.BkColor:=ClBtnface;
 MakeItLink.OnClick:=DoMakeImage;
 MakeItLink.Icon:=IcoOK;     
 MakeItLink.ImageCanRegenerate:=True;
 IcoOK.Free;

 CloseLink := TWebLink.Create(Self);
 CloseLink.Parent:=AOwner as TWinControl;
 CloseLink.Text:=TEXT_MES_IM_CLOSE_TOOL_PANEL;
 CloseLink.Top:=160;
 CloseLink.Left:=10;
 CloseLink.Visible:=true;
 CloseLink.BkColor:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;
 IcoCancel.Free;

 CloseLink.ImageCanRegenerate:=True;
end;

destructor TCustomSelectToolClass.Destroy;
begin
 EditWidthLabel.Free;
 EditHeightLabel.Free;
 EditWidth.Free;
 EditHeight.Free;
 CloseLink.Free;
 SaveSettingsLink.free;
 inherited;
end;

procedure TCustomSelectToolClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TCustomSelectToolClass.EditheightChanged(Sender: TObject);
begin
 if not EditLock then
 begin
  if FFirstPoint.Y<FSecondPoint.Y then
  FSecondPoint.Y:=FFirstPoint.Y+StrToIntDef(EditHeight.Text,10) else
  FFirstPoint.Y:=FSecondPoint.Y+StrToIntDef(EditHeight.Text,10);
  if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
 end;
end;

procedure TCustomSelectToolClass.EditWidthChanged(Sender: TObject);
begin
 if not EditLock then
 begin
  if FFirstPoint.X<FSecondPoint.X then
  FSecondPoint.X:=FFirstPoint.X+StrToIntDef(EditWidth.Text,10) else
  FFirstPoint.X:=FSecondPoint.X+StrToIntDef(EditWidth.Text,10);
  if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
 end;
end;

function TCustomSelectToolClass.GetProperties: string;
begin
//
end;

function TCustomSelectToolClass.GetZoom: Extended;
begin
 Result:=(Editor as TImageEditor).GetZoom;
end;

procedure TCustomSelectToolClass.MakeTransform;
var
  Bitmap : TBitmap;
  Point1, Point2 : TPoint;
begin
 inherited;
 FTerminating:=true;
 Bitmap := TBitmap.Create;
 Bitmap.PixelFormat:=pf24bit;
 Bitmap.Assign(Image);
 if FAnyRect then
 begin
  Point1.X:=Min(FirstPoint.X,SecondPoint.X);
  Point1.Y:=Min(FirstPoint.Y,SecondPoint.Y);
  Point2.X:=Max(FirstPoint.X,SecondPoint.X);
  Point2.Y:=Max(FirstPoint.Y,SecondPoint.Y);
 end else
 begin
  Point1.X:=Max(1,Min(FirstPoint.X,SecondPoint.X));
  Point1.Y:=Max(1,Min(FirstPoint.Y,SecondPoint.Y));
  Point2.X:=Min(Max(FirstPoint.X,SecondPoint.X),Image.Width);
  Point2.Y:=Min(Max(FirstPoint.Y,SecondPoint.Y),Image.Height);
 end;
 DoEffect(Bitmap,Rect(Point1,Point2),true);
 Image.Free;
 ImageHistory.Add(Bitmap,'{'+ID+'}['+GetProperties+']');
 SetImagePointer(Bitmap);
 ClosePanel;
end;

procedure TCustomSelectToolClass.SetAnyRect(const Value: boolean);
begin
  FAnyRect := Value;
end;

procedure TCustomSelectToolClass.SetBeginDragPoint(const Value: TPoint);
begin
  FBeginDragPoint := Value;
end;

procedure TCustomSelectToolClass.SetBeginFirstPoint(const Value: TPoint);
begin
  FBeginFirstPoint := Value;
end;

procedure TCustomSelectToolClass.SetBeginSecondPoint(const Value: TPoint);
begin
 FBeginSecondPoint := Value;
end;

procedure TCustomSelectToolClass.SetFirstPoint(const Value: TPoint);
begin
 FFirstPoint := Value;
 EditLock:=true;
 EditWidth.Text:=IntToStr(Abs(FFirstPoint.X-FSecondPoint.X));
 Editheight.Text:=IntToStr(Abs(FFirstPoint.Y-FSecondPoint.Y));
 EditLock:=false;
end;

procedure TCustomSelectToolClass.SetMakingRect(const Value: Boolean);
begin
  FMakingRect := Value;
end;

procedure TCustomSelectToolClass.SetProcRecteateImage(
  const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TCustomSelectToolClass.SetResizingRect(const Value: Boolean);
begin
  FResizingRect := Value;
end;

procedure TCustomSelectToolClass.SetSecondPoint(const Value: TPoint);
begin
 FSecondPoint := Value;
 EditLock:=true;
 EditWidth.Text:=IntToStr(Abs(FFirstPoint.X-FSecondPoint.X));
 Editheight.Text:=IntToStr(Abs(FFirstPoint.Y-FSecondPoint.Y));
 EditLock:=false;
end;

procedure TCustomSelectToolClass.SetxBottom(const Value: Boolean);
begin
  FxBottom := Value;
end;

procedure TCustomSelectToolClass.SetxCenter(const Value: boolean);
begin
  FxCenter := Value;
end;

procedure TCustomSelectToolClass.SetxLeft(const Value: Boolean);
begin
  FxLeft := Value;
end;

procedure TCustomSelectToolClass.SetxRight(const Value: Boolean);
begin
  FxRight := Value;
end;

procedure TCustomSelectToolClass.SetxTop(const Value: Boolean);
begin
  FxTop := Value;
end;

function TCustomSelectToolClass.Termnating: boolean;
begin
 Result:=FTerminating;
end;

end.
