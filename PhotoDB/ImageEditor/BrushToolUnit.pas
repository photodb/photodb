unit BrushToolUnit;

interface

{$DEFINE PHOTODB}

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics,
     Language, Math, Forms, ComCtrls, StdCtrls, SysUtils,
     Dialogs, GraphicsCool, GraphicsBaseTypes, EffectsLanguage,
     {$IFDEF PHOTODB}
      Dolphin_DB,
     {$ENDIF}
     ExtCtrls;

type
 TBrushToolClass = Class(TToolsPanelClass)
  private
    BrushSizeCaption : TStaticText;
    BrushSizeTrackBar : TTrackBar;

    BrusTransparencyCaption : TStaticText;
    BrusTransparencyTrackBar : TTrackBar;

    BrushColorCaption : TStaticText;
    BrushColorChooser : TShape;
    BrushColorChooserDialog : TColorDialog;

    FButtonCustomColor : TButton;

    LabelMethod : TLabel;

    CloseLink : TWebLink;
    MakeItLink : TWebLink;
    SaveSettingsLink : TWebLink;
    Drawing : Boolean;
    BeginPoint, EndPoint : TPoint;
    FProcRecteateImage: TNotifyEvent;
    FOwner : TObject;
    NewImage : TBitmap;
    Cur : HIcon;
    Initialized : Boolean;
    FButtonPressed : Boolean;
    procedure SetProcRecteateImage(const Value: TNotifyEvent);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    { Private declarations }
  public
   MethodDrawChooser : TComboBox;
   FDrawlayer : PARGB32Array;
   LastRect : TRect;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   procedure ClosePanelEvent(Sender : TObject);
   procedure ClosePanel; override;
   procedure MakeTransform; override;
   procedure DoMakeImage(Sender : TObject);
   procedure SetBeginPoint(P : TPoint);
   procedure SetNextPoint(P : TPoint);
   procedure SetEndPoint(P : TPoint);
   procedure DrawBrush;
   Property ProcRecteateImage : TNotifyEvent read FProcRecteateImage write SetProcRecteateImage;
   procedure SetOwner(AOwner : TObject);
   procedure Initialize;
   procedure NewCursor;
   procedure BrushSizeChanged(Sender : TObject);
   procedure BrushTransparencyChanged(Sender : TObject);
   Function GetCur : HIcon;
   procedure ColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   procedure DoSaveSettings(Sender : TObject);
   class function ID: ShortString; override;
   function GetProperties : string; override;

   Procedure SetProperties(Properties : String); override;
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
    { Public declarations }
  end;

implementation

{ TBrushToolClass }

uses ImEditor;

procedure TBrushToolClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(self);
 inherited;
end;

procedure TBrushToolClass.ClosePanelEvent(Sender: TObject);
begin
 CancelTempImage(true);
 ClosePanel;
end;

constructor TBrushToolClass.Create(AOwner: TComponent);
var
 IcoOK, IcoCancel, IcoSave : TIcon;
begin
 inherited;
 Cur:=0;
 Align:=AlClient;
 FButtonPressed:=false;
 Drawing:=false;
 Initialized:=false;
 BrushSizeCaption := TStaticText.Create(AOwner);
 BrushSizeCaption.Top:=5;
 BrushSizeCaption.Left:=8;
 BrushSizeCaption.Caption:=TEXT_MES_EDITOR_BRUSH_SIZE_LABEL;
 BrushSizeCaption.Parent:=Self;


 BrushSizeTrackBar := TTrackBar.Create(AOwner);
 BrushSizeTrackBar.Top:=BrushSizeCaption.Top+BrushSizeCaption.Height+5;
 BrushSizeTrackBar.Left:=8;
 BrushSizeTrackBar.Width:=160;
 BrushSizeTrackBar.OnChange:=BrushSizeChanged;
 BrushSizeTrackBar.Min:=1;
 BrushSizeTrackBar.Max:=300;
 {$IFDEF PHOTODB}
 BrushSizeTrackBar.Position:=DBKernel.ReadInteger('Editor','BrushToolSize',30);
 {$ENDIF}
 {$IFNDEF PHOTODB}
 BrushSizeTrackBar.Position:=30;
 {$ENDIF}
 BrushSizeTrackBar.Parent:=Self;




 BrusTransparencyCaption := TStaticText.Create(AOwner);
 BrusTransparencyCaption.Top:=BrushSizeTrackBar.Top+BrushSizeTrackBar.Height+3;
 BrusTransparencyCaption.Left:=8;
 BrusTransparencyCaption.Caption:=TEXT_MES_TRANSPARENCY;
 BrusTransparencyCaption.Parent:=Self;


 BrusTransparencyTrackBar := TTrackBar.Create(AOwner);
 BrusTransparencyTrackBar.Top:=BrusTransparencyCaption.Top+BrusTransparencyCaption.Height+5;
 BrusTransparencyTrackBar.Left:=8;
 BrusTransparencyTrackBar.Width:=160;
 BrusTransparencyTrackBar.OnChange:=BrushTransparencyChanged;
 BrusTransparencyTrackBar.Min:=1;
 BrusTransparencyTrackBar.Max:=100;
 {$IFDEF PHOTODB}
 BrusTransparencyTrackBar.Position:=DBKernel.ReadInteger('Editor','BrushTransparency',100);
 {$ENDIF}
 {$IFNDEF PHOTODB}
 BrusTransparencyTrackBar.Position:=5;
 {$ENDIF}
 BrusTransparencyTrackBar.Parent:=Self;

 BrusTransparencyCaption.Caption:=Format(TEXT_MES_TRANSPARENCY_F,[IntToStr(BrusTransparencyTrackBar.Position)]);


 LabelMethod := TLabel.Create(AOwner);
 LabelMethod.Left:=8;
 LabelMethod.Top:=BrusTransparencyTrackBar.Top+BrusTransparencyTrackBar.Height+5;
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
 MethodDrawChooser.Items.Add(TEXT_MES_DRAW_STYLE_CHANGE_COLOR);
 {$IFDEF PHOTODB}
 MethodDrawChooser.ItemIndex:=DBKernel.ReadInteger('Editor','BrushToolStyle',0);
 {$ENDIF}
 {$IFNDEF PHOTODB}
 MethodDrawChooser.ItemIndex:=0;
 {$ENDIF}
 MethodDrawChooser.OnChange:=BrushTransparencyChanged;

 BrushColorChooser := TShape.Create(AOwner);
 BrushColorChooser.Top:=MethodDrawChooser.Top+MethodDrawChooser.Height+12;
 BrushColorChooser.Left:=10;
 BrushColorChooser.Width:=20;
 BrushColorChooser.Height:=20;
 {$IFDEF PHOTODB}
 BrushColorChooser.Brush.Color:=DBKernel.ReadInteger('Editor','BrushToolColor',0);
 {$ENDIF}
 {$IFNDEF PHOTODB}
 BrushColorChooser.Brush.Color:=$0;
 {$ENDIF}
 BrushColorChooser.OnMouseDown:=ColorClick;
 BrushColorChooser.Parent:=Self;

 BrushColorCaption := TStaticText.Create(AOwner);
 BrushColorCaption.Top:=MethodDrawChooser.Top+MethodDrawChooser.Height+15;
 BrushColorCaption.Left:=BrushColorChooser.Left+BrushColorChooser.Width+5;
 BrushColorCaption.Caption:=TEXT_MES_EDITOR_BRUSH_COLOR_LABEL;
 BrushColorCaption.Parent:=Self;

 FButtonCustomColor := TButton.Create(self);
 FButtonCustomColor.Parent:=self;
 FButtonCustomColor.Top:=BrushColorCaption.Top+BrushColorCaption.Height+5;
 FButtonCustomColor.Width:=80;
 FButtonCustomColor.Height:=21;
 FButtonCustomColor.Left:=8;
 FButtonCustomColor.Caption:=TEXT_MES_SELECT_COLOR;
 FButtonCustomColor.OnMouseDown:=ButtonMouseDown;
 FButtonCustomColor.OnMouseMove:=ButtonMouseMove;
 FButtonCustomColor.OnMouseUp:=ButtonMouseUp;

 BrushColorChooserDialog := TColorDialog.Create(AOwner);

 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoSave:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 IcoSave.Handle:=LoadIcon(DBKernel.IconDllInstance,'SAVETOFILE');

 SaveSettingsLink := TWebLink.Create(Self);
 SaveSettingsLink.Parent:=AOwner as TWinControl;
 SaveSettingsLink.Text:=TEXT_MES_SAVE_SETTINGS;
 SaveSettingsLink.Top:=FButtonCustomColor.Top+FButtonCustomColor.Height+15;
 SaveSettingsLink.Left:=10;
 SaveSettingsLink.Visible:=true;
 SaveSettingsLink.BkColor:=ClBtnface;
 SaveSettingsLink.OnClick:=DoSaveSettings;
 SaveSettingsLink.Icon:=IcoSave;
 IcoSave.free;

 MakeItLink:= TWebLink.Create(Self);
 MakeItLink.Parent:=AOwner as TWinControl;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
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
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 CloseLink.Left:=10;
 CloseLink.Visible:=true;
 CloseLink.BkColor:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;
 IcoCancel.Free;

 CloseLink.ImageCanRegenerate:=True;
end;

destructor TBrushToolClass.Destroy;
begin
  BrushSizeCaption.Free;
  BrushSizeTrackBar.Free;
  BrusTransparencyCaption.Free;
  BrusTransparencyTrackBar.Free;
  BrushColorCaption.Free;
  BrushColorChooser.Free;
  BrushColorChooserDialog.Free;
  if Cur<>0 then DestroyIcon(Cur);
  MakeItLink.Free;
  CloseLink.Free;
  inherited;
end;

procedure TBrushToolClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TBrushToolClass.DrawBrush;
var
  r,g,b : Byte;
  rad : integer;
begin
 r:=GetRValue(BrushColorChooser.Brush.Color);
 g:=GetGValue(BrushColorChooser.Brush.Color);
 b:=GetBValue(BrushColorChooser.Brush.Color);
 rad:=Max(1,round(BrushSizeTrackBar.Position));
 DoBrush(FDrawlayer,Image.Width,Image.Height,BeginPoint.X,BeginPoint.Y,EndPoint.X,EndPoint.Y,r,g,b,rad);
 LastRect:=Rect(BeginPoint.X,BeginPoint.Y,EndPoint.X,EndPoint.Y);
 LastRect:=NormalizeRect(LastRect);

 LastRect.Top:=Max(0,LastRect.Top-rad div 2);
 LastRect.Left:=Max(0,LastRect.Left-rad div 2);
 LastRect.Bottom:=Min(Image.Height-1,LastRect.Bottom+rad div 2);
 LastRect.Right:=Min(Image.Width-1,LastRect.Right+rad div 2);
 (Editor as TImageEditor).Transparency:=BrusTransparencyTrackBar.Position/100;
 if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
end;

procedure TBrushToolClass.Initialize;
begin
  NewImage := TBitmap.Create;
  NewImage.Assign(Image);
  SetTempImage(NewImage);
  Initialized:=true;
end;

procedure TBrushToolClass.MakeTransform;
var
  i : integer;
  P : PARGBArray;
begin
 inherited;
 SetLength(p,Image.Height);
 for i:=0 to Image.Height-1 do
 p[i]:=NewImage.ScanLine[i];
 StretchFastATrans(0,0,Image.Width,Image.Height,Image.Width,Image.Height,FDrawlayer,p,BrusTransparencyTrackBar.Position/100,MethodDrawChooser.ItemIndex);
 ImageHistory.Add(NewImage,'{'+ID+'}['+GetProperties+']');
 SetImagePointer(NewImage);
 ClosePanel;
end;

procedure TBrushToolClass.SetBeginPoint(P: TPoint);
begin
 Drawing:=true;
 BeginPoint:=P;
 EndPoint:=P;
 DrawBrush;
end;

procedure TBrushToolClass.SetEndPoint(P: TPoint);
begin
 Drawing:=false;
end;

procedure TBrushToolClass.SetNextPoint(P: TPoint);
begin
 if Drawing then
 begin
  BeginPoint:=EndPoint;
  EndPoint:=P;
  DrawBrush;
 end;
end;

procedure TBrushToolClass.SetOwner(AOwner: TObject);
begin
 FOwner:=AOwner;
end;

procedure TBrushToolClass.SetProcRecteateImage(const Value: TNotifyEvent);
begin
  FProcRecteateImage := Value;
end;

procedure TBrushToolClass.NewCursor;
var
  CurSize : integer;
  AndMask : TBitmap;
  IconInfo : TIconInfo;
  bit : TBitmap;
begin
 if not Initialized then exit;
 CurSize:=Min(500, Max(2,round(BrushSizeTrackBar.Position*(FOwner as TImageEditor).GetZoom)));
 if not (Editor as TImageEditor).VirtualBrushCursor then
 begin
  bit:=TBitmap.Create;
  bit.PixelFormat:=pf1bit;
  bit.Width:=CurSize;
  bit.Height:=CurSize;
  bit.PixelFormat:=pf4bit;
  AndMask := TBitmap.Create;
  AndMask.Monochrome := true;
  AndMask.width:=CurSize;
  AndMask.height:=CurSize;
  AndMask.Canvas.Brush.Color := $ffffff;
  AndMask.Canvas.pen.Color:=$ffffff;
  AndMask.Canvas.FillRect(Rect(0, 0, bit.width, bit.height));
  bit.Canvas.pen.color:=$0;
  bit.Canvas.Brush.Color:=$0;
  bit.Canvas.FillRect(Rect(0, 0, bit.width, bit.height));
  bit.Canvas.pen.color:=$ffffff;
  bit.Canvas.ellipse(Rect(0, 0, bit.width, bit.height));
  IconInfo.fIcon := true;
  IconInfo.xHotspot := 1;
  IconInfo.yHotspot := 1;
  IconInfo.hbmMask := AndMask.Handle;
  IconInfo.hbmColor := bit.Handle;
  if Cur<>0 then DestroyIcon(Cur);
  Cur:=0;
  Cur:=CreateIconIndirect(IconInfo);
  AndMask.free;
  bit.Free;
  Screen.Cursors[67]:=Cur;
 end else
 begin
  ClearBrush((Editor as TImageEditor).VBrush);
  MakeRadialBrush((Editor as TImageEditor).VBrush,CurSize div 2);
 end;
end;

procedure TBrushToolClass.BrushSizeChanged(Sender: TObject);
begin
 BrushSizeCaption.Caption:=Format(TEXT_MES_EDITOR_BRUSH_SIZE_LABEL,[BrushSizeTrackBar.Position]);
 NewCursor;
end;

function TBrushToolClass.GetCur: HIcon;
begin
 Result:=Cur;
end;

procedure TBrushToolClass.ColorClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 BrushColorChooserDialog.Color:=BrushColorChooser.Brush.Color;
 if BrushColorChooserDialog.Execute then
 begin
  BrushColorChooser.Brush.Color:=BrushColorChooserDialog.Color;
 end;
end;

procedure TBrushToolClass.DoSaveSettings(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 DBKernel.WriteInteger('Editor','BrushToolStyle',MethodDrawChooser.ItemIndex);
 DBKernel.WriteInteger('Editor','BrushToolColor',BrushColorChooser.Brush.Color);
 DBKernel.WriteInteger('Editor','BrushToolSize',BrushSizeTrackBar.Position);
 DBKernel.WriteInteger('Editor','BrushTransparency',BrusTransparencyTrackBar.Position);
 {$ENDIF}
end;

procedure TBrushToolClass.BrushTransparencyChanged(Sender: TObject);
begin
 if not Initialized then exit;
 BrusTransparencyCaption.Caption:=Format(TEXT_MES_TRANSPARENCY_F,[IntToStr(BrusTransparencyTrackBar.Position)]);
 (Editor as TImageEditor).Transparency:=BrusTransparencyTrackBar.Position/100;
 if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
end;

procedure TBrushToolClass.ButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Screen.Cursor:=CrCross;
 FButtonPressed:=true;
end;

procedure TBrushToolClass.ButtonMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  c : TCanvas;
  p : TPoint;
begin
 if FButtonPressed then
 begin
  C := TCanvas.Create;
  GetCursorPos(p);
  C.Handle := GetDC(GetWindow(GetDesktopWindow, GW_OWNER));
  BrushColorChooser.Brush.Color:=C.Pixels[p.x,p.y];
  C.Free;
 end;
end;

procedure TBrushToolClass.ButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Screen.Cursor:=CrDefault;
 FButtonPressed:=false;
end;

function TBrushToolClass.GetProperties: string;
begin
 Result:='';
 //
end;

class function TBrushToolClass.ID: ShortString;
begin 
 Result:='{542FC0AD-A013-4973-90D4-E6D6E9F65D2C}';
end;

procedure TBrushToolClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

procedure TBrushToolClass.SetProperties(Properties: String);
begin

end;

end.
