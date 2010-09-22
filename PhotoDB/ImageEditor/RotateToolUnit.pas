unit RotateToolUnit;

interface

uses Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
     GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
     Effects, Angle, Spin, Language, Dialogs, GraphicsBaseTypes;

type TRotateToolPanelClass = Class(TToolsPanelClass)
  private
  NewImage : TBitmap;
  CloseLink : TWebLink;
  MakeItLink : TWebLink;
  SelectChooseBox : TRadioGroup;
  CustomAngle : TAngle;
  AngleEdit: TSpinEdit;
  ColorEdit : TShape;
  ColorChooser : TColorDialog;
  ColorLabel : TLabel;
  ApplyOnDone : boolean;       
  fOnDone : TNotifyEvent;
    { Private declarations }
  public
   FSID : String;
   class function ID: ShortString; override;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   Procedure ClosePanel; override;
   Procedure MakeTransform; override;
   Procedure ClosePanelEvent(Sender : TObject);
   Procedure SelectChooseBoxClick(Sender : TObject);
   Procedure DoMakeImage(Sender : TObject);
   procedure SetThreadImage(Image : TBitmap; SID : string);
   procedure SetProgress(Progress : Integer; SID : string);
   procedure AngleChanged(Sender : TObject);
   procedure AngleEditChanged(Sender : TObject);
   procedure ColorLabelClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

   function GetProperties : string; override;
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
   
   Procedure SetProperties(Properties : String); override;
   { Public declarations }
  end;

implementation

{ TCropToolPanelClass }

uses RotateToolThreadUnit, ImEditor, Dolphin_DB;

procedure TRotateToolPanelClass.AngleChanged(Sender: TObject);
begin
 AngleEdit.Tag:=1;
 if Round(CustomAngle.Angle)<0 then
 AngleEdit.Value:=360+Round(CustomAngle.Angle) else
 AngleEdit.Value:=Round(CustomAngle.Angle);
 AngleEdit.Tag:=0;
 if SelectChooseBox.ItemIndex<>6 then
 SelectChooseBox.ItemIndex:=6 else
 SelectChooseBoxClick(Sender);
end;

procedure TRotateToolPanelClass.AngleEditChanged(Sender: TObject);
begin
 if AngleEdit.Tag=0 then
 CustomAngle.Angle:=AngleEdit.Value;
end;

procedure TRotateToolPanelClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(self);
 if not ApplyOnDone then
 inherited;
end;

procedure TRotateToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
 CancelTempImage(true);
 ClosePanel;
end;

procedure TRotateToolPanelClass.ColorLabelClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
begin
 ColorChooser.Color:=ColorEdit.Brush.Color;
 if ColorChooser.Execute then
 begin
  ColorEdit.Brush.Color:=ColorChooser.Color;
  SelectChooseBoxClick(Sender);
 end;
end;

constructor TRotateToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel : TIcon;
begin
 inherited;
 ApplyOnDone:=false;
 NewImage:=nil;
 Align:=AlClient;
 ApplyOnDone:=false;
 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 SelectChooseBox := TRadioGroup.Create(AOwner);
 SelectChooseBox.Top:=5;
 SelectChooseBox.Left:=5;
 SelectChooseBox.Width:=180;
 SelectChooseBox.Height:=150;
 SelectChooseBox.Parent:=Self;
 SelectChooseBox.Items.Add(TEXT_MES_IM_CHOOSE_ACTION);
 SelectChooseBox.Items.Add(TEXT_MES_IM_ROTATE_LEFT);
 SelectChooseBox.Items.Add(TEXT_MES_IM_ROTATE_RIGHT);
 SelectChooseBox.Items.Add(TEXT_MES_IM_ROTATE_180);
 SelectChooseBox.Items.Add(TEXT_MES_IM_FLIP_HORISONTAL);
 SelectChooseBox.Items.Add(TEXT_MES_IM_FLIP_VERTICAL);
 SelectChooseBox.Items.Add(TEXT_MES_IM_ROTATE_USTOM_ANGLE);
 SelectChooseBox.Caption:=TEXT_MES_IM_ACTION;
 SelectChooseBox.ItemIndex:=0;
 SelectChooseBox.OnClick:=SelectChooseBoxClick;


 CustomAngle := TAngle.Create(AOwner);
 CustomAngle.Top:=SelectChooseBox.Top+SelectChooseBox.Height+5;
 CustomAngle.Left:=5;
 CustomAngle.Width:=50;
 CustomAngle.Height:=50;
 CustomAngle.Parent:=Self;
 CustomAngle.OnChange:=AngleChanged;

 AngleEdit:= TSpinEdit.Create(AOwner);
 AngleEdit.Top:=SelectChooseBox.Top+SelectChooseBox.Height+5;
 AngleEdit.Left:=CustomAngle.Left+CustomAngle.Width+20;
 AngleEdit.Width:=50;
 AngleEdit.OnChange:=AngleEditChanged;
 AngleEdit.MaxValue:=360;
 AngleEdit.MinValue:=0;
 AngleEdit.Parent:=Self;

 ColorEdit := TShape.Create(AOwner);
 ColorEdit.Top:=SelectChooseBox.Top+SelectChooseBox.Height+35;
 ColorEdit.Left:=CustomAngle.Left+CustomAngle.Width+20;
 ColorEdit.Width:=20;
 ColorEdit.height:=20;
 ColorEdit.Brush.Color:=$0;
 ColorEdit.Parent:=Self;
 ColorEdit.OnMouseDown:=ColorLabelClick;

 ColorLabel := TLabel.Create(AOwner);
 ColorLabel.Top:=SelectChooseBox.Top+SelectChooseBox.Height+40;
 ColorLabel.Left:=CustomAngle.Left+CustomAngle.Width+20+ColorEdit.Width+5;
 ColorLabel.Caption:=TEXT_MES_BK_COLOR;
 ColorLabel.Parent:=Self;


 ColorChooser := TColorDialog.Create(AOwner);

 MakeItLink := TWebLink.Create(Self);
 MakeItLink.Top:=230;
 MakeItLink.Left:=10;
 MakeItLink.Parent:=Self;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Visible:=true;
 MakeItLink.Color:=ClBtnface;
 MakeItLink.OnClick:=DoMakeImage;
 MakeItLink.Icon:=IcoOK;     
 MakeItLink.ImageCanRegenerate:=True;
 IcoOK.Free;

 CloseLink := TWebLink.Create(Self);
 CloseLink.Top:=250;
 CloseLink.Left:=10;
 CloseLink.Parent:=Self;
 CloseLink.Text:=TEXT_MES_IM_CLOSE_TOOL_PANEL;
 CloseLink.Visible:=true;
 CloseLink.Color:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;      
 CloseLink.ImageCanRegenerate:=True;  
 IcoCancel.Free;

end;

destructor TRotateToolPanelClass.Destroy;
begin
 CloseLink.Free;
 MakeItLink.Free;
 CustomAngle.free;
 SelectChooseBox.Free;
 AngleEdit.Free;
 ColorEdit.Free;
 ColorChooser.Free;
 ColorLabel.Free;
 inherited;
end;

procedure TRotateToolPanelClass.DoMakeImage(Sender: TObject);
begin
 MakeTransform;
end;

procedure TRotateToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
 fOnDone:=OnDone;
 AngleEdit.Value:=StrToIntDef(GetValueByName(Properties,'Angle'),0);
 SelectChooseBox.ItemIndex:=StrToIntDef(GetValueByName(Properties,'Action'),0);
 ColorEdit.Brush.Color:=StrToIntDef(GetValueByName(Properties,'BkColor'),0);
 ApplyOnDone:=true;
 SelectChooseBoxClick(self);
end;

function TRotateToolPanelClass.GetProperties: string;
begin
 Result:='Angle='+IntToStr(AngleEdit.Value)+';';
 Result:=Result+'Action='+IntToStr(SelectChooseBox.ItemIndex)+';';
 Result:=Result+'BkColor='+IntToStr(ColorEdit.Brush.Color)+';';
end;

class function TRotateToolPanelClass.ID: ShortString;
begin
 Result:='{747B3EAF-6219-4A96-B974-ABEB1405914B}';
end;

procedure TRotateToolPanelClass.MakeTransform;
begin
 inherited;

 if NewImage<>nil then
 begin
  ImageHistory.Add(NewImage,'{'+ID+'}['+GetProperties+']');
  SetImagePointer(NewImage);
 end;

 ClosePanel;
end;

procedure TRotateToolPanelClass.SelectChooseBoxClick(Sender: TObject);
var
  proc : TBaseEffectProc;
begin
 proc:=nil;
 Case SelectChooseBox.ItemIndex of
  0:
   begin
    CancelTempImage(true);
    NewImage:=nil;
    exit;
   end;
  1:
   begin
    proc:=Effects.Rotate270;
   end;
  2:
   begin
    proc:=Effects.Rotate90;
   end;
  3:
   begin
    proc:=Effects.Rotate180;
   end;
  4:
   begin
    proc:=Effects.FlipHorizontal;
   end;
  5:
   begin
    proc:=Effects.FlipVertical;
   end;
  6:
   begin
    proc:=nil;
   end;
 end;
 FSID:=IntToStr(Random(100000));
 begin
  NewImage := TBitmap.Create;
  NewImage.Assign(Image);
  NewImage.PixelFormat:=pf24bit;
  Image.PixelFormat:=pf24bit;
  TRotateEffectThread.Create(Self,false,proc,NewImage,FSID,SetThreadImage,CustomAngle.Angle,ColorEdit.Brush.Color,Editor);
  NewImage:=nil;
 end;
end;

procedure TRotateToolPanelClass.SetProgress(Progress: Integer;
  SID: string);
begin
 if SID=FSID then
 begin
  (Editor as TImageEditor).FStatusProgress.Position:=Progress;
 end;
end;

procedure TRotateToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TRotateToolPanelClass.SetThreadImage(Image: TBitmap;
  SID: string);
begin
 if SID=FSID then
 begin
  Pointer(NewImage):=Pointer(Image);
  SetTempImage(Image);
 end else Image.Free;
 if ApplyOnDone then
 begin
  MakeTransform;
  if Assigned(fOnDone) then fOnDone(self);
 end;
end;

end.




