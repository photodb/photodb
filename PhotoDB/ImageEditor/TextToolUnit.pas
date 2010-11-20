unit TextToolUnit;

interface

{$DEFINE PHOTODB}

uses CustomSelectTool, Windows, Classes, Graphics, Effects, GraphicsBaseTypes, Math,
     StdCtrls, Controls, Language, Forms, SysUtils, ExtCtrls, Buttons, Spin,
     {$IFDEF PHOTODB}
     Dolphin_DB,
     {$ENDIF}
     Dialogs;

type TextToolClass = Class(TCustomSelectToolClass)
  private
  TextMemoLabel : TStaticText;
  TextMemo : TMemo;
  FontNameLabel : TStaticText;
  FontNameEdit : TComboBox;

  FontSizeLabel : TStaticText;
  FontSizeEdit : TComboBox;

  FontColorEdit : TShape;
  FontColorEditDialog : TColorDialog;
  FontColorLabel : TStaticText;

  RotateTextChooser : TRadioGroup;

  LeftOrientationButton : TSpeedButton;
  CenterOrientationButton : TSpeedButton;
  RightOrientationButton : TSpeedButton;
  OrientationLabel : TStaticText;

  EnableOutline : TCheckBox;
  OutLineSizeLabel : TStaticText;
  OutLineSizeEdit : TSpinEdit;
  OutLineColorLabel : TStaticText;
  OutLineColorEdit : TShape;
  Loading : boolean;
    { Private declarations }
  public
   class function ID: string; override;
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   procedure DoEffect(Bitmap : TBitmap; aRect : TRect; FullImage : Boolean); override;
   procedure DoBorder(Bitmap : TBitmap; aRect : TRect); override;
   procedure OnTextChanged(Sender : TObject);
   procedure ColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   procedure OutLineColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

   procedure DoSaveSettings(Sender : TObject); override;
   procedure EnableOutlineClick(Sender : TObject);
   
   Procedure SetProperties(Properties : String); override;
   Procedure ExecuteProperties(Properties : String; OnDone : TNotifyEvent); override;
    { Public declarations }
  end;

implementation

{ TextToolClass }

{$R TextToolRes.res}

procedure TextToolClass.ColorClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 FontColorEditDialog.Color:=FontColorEdit.Brush.Color;
 if FontColorEditDialog.Execute then
 begin
  FontColorEdit.Brush.Color:=FontColorEditDialog.Color;
  OnTextChanged(Sender);
 end;
end;

constructor TextToolClass.Create(AOwner: TComponent);
const
  MaxSizes = 19;
  Sizes : array [1..MaxSizes] of integer = (8,10,12,14,16,18,20,24,28,32,45,50,60,70,80,100,120,150,200);
var
  i : integer;

begin
  inherited;
 AnyRect:=true;
 Loading:=true;
 CloseLink.Hide;
 MakeItLink.Hide;
 SaveSettingsLink.Hide;
 TextMemoLabel := TStaticText.Create(AOwner);
 TextMemoLabel.Top:=EditWidth.Top+EditWidth.Height+5;
 TextMemoLabel.Left:=8;
 TextMemoLabel.Caption:=TEXT_MES_NEW_TEXT_LABEL_CAPTION;
 TextMemoLabel.Parent:=AOwner as TWinControl;

 TextMemo := TMemo.Create(AOwner);
 TextMemo.Top:=TextMemoLabel.Top+TextMemoLabel.Height+2;
 TextMemo.Left:=8;
 TextMemo.Width:=160;
 TextMemo.Height:=40;
 TextMemo.ScrollBars:=ssVertical;
 TextMemo.OnChange:=OnTextChanged;
 TextMemo.Parent:=AOwner as TWinControl;
 {$IFDEF PHOTODB}
 if DBKernel.ReadString('Editor','TextToolText')<>'' then
 TextMemo.Text:=DBKernel.ReadString('Editor','TextToolText') else
 TextMemo.Text:=TEXT_MES_NEW_TEXT_LABEL;
 {$ELSE}
 TextMemo.Text:=TEXT_MES_NEW_TEXT_LABEL;
 {$ENDIF}

 FontNameLabel := TStaticText.Create(AOwner);
 FontNameLabel.Top:=TextMemo.Top+TextMemo.Height+5;
 FontNameLabel.Left:=8;
 FontNameLabel.Caption:=TEXT_MES_FONT_NAME_LABEL_CAPTION;
 FontNameLabel.Parent:=AOwner as TWinControl;

 FontNameEdit := TComboBox.Create(AOwner);
 FontNameEdit.Top:=FontNameLabel.Top+FontNameLabel.Height+2;
 FontNameEdit.Left:=8;
 FontNameEdit.OnChange:=OnTextChanged;
 FontNameEdit.Parent:=AOwner as TWinControl;
 FontNameEdit.Items:=Screen.Fonts;
 {$IFDEF PHOTODB}
 if DBKernel.ReadString('Editor','TextToolFontName')<>'' then
 FontNameEdit.Text:=DBKernel.ReadString('Editor','TextToolFontName') else
 FontNameEdit.Text:='Times New Roman';
 {$ELSE}
 FontNameEdit.Text:='Times New Roman';
 {$ENDIF}

 FontSizeLabel := TStaticText.Create(AOwner);
 FontSizeLabel.Top:=FontNameEdit.Top+FontNameEdit.Height+3;
 FontSizeLabel.Left:=8;
 FontSizeLabel.Caption:=TEXT_MES_FONT_SIZE_LABEL_CAPTION;
 FontSizeLabel.Parent:=AOwner as TWinControl;

 FontSizeEdit := TComboBox.Create(AOwner);
 FontSizeEdit.Top:=FontSizeLabel.Top+FontSizeLabel.Height+2;
 FontSizeEdit.Left:=8;
 FontSizeEdit.OnChange:=OnTextChanged;
 FontSizeEdit.Parent:=AOwner as TWinControl;
 FontSizeEdit.Items.Clear;
 FontSizeEdit.Width:=45;
 for i:=1 to MaxSizes do
 FontSizeEdit.Items.Add(IntToStr(Sizes[i]));


 {$IFDEF PHOTODB}
  if DBKernel.ReadInteger('Editor','TextToolFontSize',0)<>0 then
  FontSizeEdit.Text:=IntToStr(DBKernel.ReadInteger('Editor','TextToolFontSize',0)) else
  FontSizeEdit.Text:='12';
 {$ELSE}
  FontSizeEdit.Text:='12';
 {$ENDIF}


 FontColorEdit := TShape.Create(Self);
 FontColorEdit.Parent:=Self as TWinControl;
 FontColorEdit.Top:=FontSizeLabel.Top+FontSizeLabel.Height+2;
 FontColorEdit.Left:=FontSizeEdit.Left+FontSizeEdit.Width+10;
 FontColorEdit.Width:=16;
 FontColorEdit.Height:=16;
 FontColorEdit.OnMouseDown:=ColorClick;
 FontColorEdit.Pen.Color:=0;
 
 {$IFDEF PHOTODB}
 if DBKernel.ReadInteger('Editor','TextToolFontColor',-1)<>-1 then
 FontColorEdit.Brush.Color:=DBKernel.ReadInteger('Editor','TextToolFontColor',0) else
 FontColorEdit.Brush.Color:=0;
 {$ELSE}
 FontColorEdit.Brush.Color:=0;
 {$ENDIF}


 FontColorEditDialog := TColorDialog.Create(AOwner);

 FontColorLabel := TStaticText.Create(AOwner);
 FontColorLabel.Top:=FontSizeLabel.Top+FontSizeLabel.Height+3;
 FontColorLabel.Left:=FontColorEdit.Left+FontColorEdit.Width+5;
 FontColorLabel.Caption:=TEXT_MES_FONT_COLOR;
 FontColorLabel.Parent:=AOwner as TWinControl;

 RotateTextChooser := TRadioGroup.Create(AOwner);
 RotateTextChooser.Caption:=TEXT_MES_TEXT_ROTATION;
 RotateTextChooser.Left:=8;
 RotateTextChooser.Width:=160;
 RotateTextChooser.Height:=80;
 RotateTextChooser.Top:=FontColorLabel.Top+FontColorLabel.Height+5;
 RotateTextChooser.Parent:=AOwner as TWinControl;
 RotateTextChooser.OnClick:=OnTextChanged;
 RotateTextChooser.Items.Clear;
 RotateTextChooser.Items.Add(TEXT_MES_TEXT_ROTATION_0);
 RotateTextChooser.Items.Add(TEXT_MES_TEXT_ROTATION_90);
 RotateTextChooser.Items.Add(TEXT_MES_TEXT_ROTATION_180);
 RotateTextChooser.Items.Add(TEXT_MES_TEXT_ROTATION_270);
 {$IFDEF PHOTODB}
 RotateTextChooser.ItemIndex:=DBKernel.ReadInteger('Editor','TextToolFontRotation',0);
 {$ELSE}
 RotateTextChooser.ItemIndex:=0;
 {$ENDIF}

 OrientationLabel := TStaticText.Create(AOwner);
 OrientationLabel.Top:=RotateTextChooser.Top+RotateTextChooser.Height+3;
 OrientationLabel.Left:=8;
 OrientationLabel.Caption:=TEXT_MES_ORIENTATION_LABEL;
 OrientationLabel.Parent:=AOwner as TWinControl;

 LeftOrientationButton := TSpeedButton.Create(AOwner);
 LeftOrientationButton.Width:=20;
 LeftOrientationButton.Height:=20;
 LeftOrientationButton.Left:=8;
 LeftOrientationButton.GroupIndex:=1;
 LeftOrientationButton.Top:=OrientationLabel.Top+OrientationLabel.Height+2;
 LeftOrientationButton.OnClick:=OnTextChanged;
 LeftOrientationButton.Parent:=self;
 LeftOrientationButton.Glyph:=TBitmap.Create;
 LeftOrientationButton.Glyph.Handle:=LoadBitmap(HInstance,'LEFTTEXT');


 CenterOrientationButton := TSpeedButton.Create(AOwner);
 CenterOrientationButton.Width:=20;
 CenterOrientationButton.Height:=20;
 CenterOrientationButton.Left:=LeftOrientationButton.Left+LeftOrientationButton.Width+2;
 CenterOrientationButton.GroupIndex:=1;
 CenterOrientationButton.Top:=OrientationLabel.Top+OrientationLabel.Height+2;
 CenterOrientationButton.OnClick:=OnTextChanged;
 CenterOrientationButton.Parent:=self;
 CenterOrientationButton.Glyph:=TBitmap.Create;
 CenterOrientationButton.Glyph.Handle:=LoadBitmap(HInstance,'CENTERTEXT');

 RightOrientationButton :=  TSpeedButton.Create(AOwner);
 RightOrientationButton.Width:=20;
 RightOrientationButton.Height:=20;
 RightOrientationButton.Left:=CenterOrientationButton.Left+CenterOrientationButton.Width+2;
 RightOrientationButton.GroupIndex:=1;
 RightOrientationButton.Top:=OrientationLabel.Top+OrientationLabel.Height+2;
 RightOrientationButton.OnClick:=OnTextChanged;
 RightOrientationButton.Parent:=self;
 RightOrientationButton.Glyph:=TBitmap.Create;
 RightOrientationButton.Glyph.Handle:=LoadBitmap(HInstance,'RIGHTTEXT');

 {$IFDEF PHOTODB}
 Case DBKernel.ReadInteger('Editor','TextToolFontOrientation',1) of
  1: LeftOrientationButton.Down:=True;
  2: CenterOrientationButton.Down:=True;
  3: RightOrientationButton.Down:=True;
  else LeftOrientationButton.Down:=True;
 end;
 {$ELSE}
 LeftOrientationButton.Down:=True;
 {$ENDIF}


 EnableOutline := TCheckBox.Create(AOwner);
 EnableOutline.Top:=RightOrientationButton.Top+RightOrientationButton.Height+3;
 EnableOutline.Left:=8;
 EnableOutline.Width:=160;
 EnableOutline.Caption:=TEXT_MES_EDITOR_ENABLE_OUTLINE_TEXT;
 EnableOutline.OnClick:=EnableOutlineClick;
 {$IFDEF PHOTODB}
 EnableOutline.Checked:=DBKernel.ReadBool('Editor','TextToolEnableOutLine',false);
 {$ELSE}
 EnableOutline.Checked:=false;
 {$ENDIF}
 EnableOutline.Parent:=self;

 OutLineSizeLabel := TStaticText.Create(AOwner);
 OutLineSizeLabel.Top:=EnableOutline.Top+EnableOutline.Height+3;
 OutLineSizeLabel.Left:=8;
 OutLineSizeLabel.Caption:=TEXT_MES_EDITOR_OUTLINE_TEXT_SIZE;
 OutLineSizeLabel.Parent:=self;

 OutLineSizeEdit := TSpinEdit.Create(AOwner);
 OutLineSizeEdit.Top:=OutLineSizeLabel.Top+OutLineSizeLabel.Height+3;
 OutLineSizeEdit.Left:=8;
 OutLineSizeEdit.Width:=50;
 OutLineSizeEdit.MinValue:=1;
 OutLineSizeEdit.MaxValue:=100;
 {$IFDEF PHOTODB}
 OutLineSizeEdit.Value:=DBKernel.ReadInteger('Editor','TextToolOutLineSize',5);
 {$ELSE}
 OutLineSizeEdit.Value:=5;
 {$ENDIF}
 OutLineSizeEdit.OnChange:=OnTextChanged;
 OutLineSizeEdit.Parent:=self;
 OutLineSizeEdit.Enabled:=EnableOutline.Checked;
 
 OutLineColorLabel := TStaticText.Create(AOwner);
 OutLineColorLabel.Left:=OutLineSizeEdit.Left+OutLineSizeEdit.Width+15;
 OutLineColorLabel.Top:=EnableOutline.Top+EnableOutline.Height+3;
 OutLineColorLabel.Caption:=TEXT_MES_OUTLINE_TEXT_COLOR;
 OutLineColorLabel.Parent:=self;


 OutLineColorEdit := TShape.Create(AOwner);
 OutLineColorEdit.Top:=OutLineSizeLabel.Top+OutLineSizeLabel.Height+5;
 OutLineColorEdit.Left:=OutLineSizeEdit.Left+OutLineSizeEdit.Width+15;
 OutLineColorEdit.Width:=15;
 OutLineColorEdit.Height:=15;
 {$IFDEF PHOTODB}
 OutLineColorEdit.Brush.Color:=DBKernel.ReadInteger('Editor','TextToolOutLineColor',OutLineColorEdit.Brush.Color);
 {$ELSE}
 OutLineColorEdit.Brush.Color:=$FFFFFF;
 {$ENDIF}

 OutLineColorEdit.OnMouseDown:=OutLineColorClick;
 OutLineColorEdit.Parent:=self;

 SaveSettingsLink.Top:=OutLineSizeEdit.Top+OutLineSizeEdit.Height+10;
 MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 CloseLink.Show;
 MakeItLink.Show;
 SaveSettingsLink.Show;
 Loading:=false;
end;

destructor TextToolClass.Destroy;
begin
  TextMemo.Free;
  TextMemoLabel.Free;
  FontNameLabel.Free;
  FontNameEdit.Free;
  FontSizeLabel.Free;
  FontSizeEdit.Free;
  FontColorEdit.Free;
  FontColorEditDialog.Free;
  FontColorLabel.Free;
  RotateTextChooser.Free;
  OrientationLabel.Free;
  LeftOrientationButton.Free;
  CenterOrientationButton.Free;
  RightOrientationButton.Free;

  EnableOutline.Free;
  OutLineSizeLabel.Free;
  OutLineSizeEdit.Free;
  OutLineColorLabel.Free;
  OutLineColorEdit.Free;
  inherited;
end;

procedure TextToolClass.DoBorder(Bitmap: TBitmap; aRect: TRect);
var
  Xdp : TArPARGB;
  Rct: TRect;
  i,j : integer;

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

procedure TextToolClass.DoEffect(Bitmap: TBitmap; aRect: TRect; FullImage : Boolean);
var
  FontSize : Extended;
  text:string;
  Rct: TRect;
  IntSize, OutLineSize : Integer;
  Options : Cardinal;
begin
 Rct.Top:=Min(aRect.Top,aRect.Bottom);
 Rct.Bottom:=Max(aRect.Top,aRect.Bottom);
 Rct.Left:=Min(aRect.Left,aRect.Right);
 Rct.Right:=Max(aRect.Left,aRect.Right);
 aRect:=Rct;
 text:=TextMemo.Text;
 Bitmap.Canvas.Brush.Style:=bsClear;
 Bitmap.Canvas.Font.Name:=FontNameEdit.Text;
 Bitmap.Canvas.Font.Color:=FontColorEdit.Brush.Color;
 IntSize:=StrToIntDef(FontSizeEdit.Text,12);
 if not FullImage then
 FontSize:=(IntSize*GetZoom) else  FontSize:=IntSize;
 Bitmap.Canvas.Font.Size:=Round(FontSize);
 Options:=DT_WORDBREAK;
 if LeftOrientationButton.Down then
 Options:=Options+DT_LEFT;
 if CenterOrientationButton.Down then
 Options:=Options+DT_CENTER;
 if RightOrientationButton.Down then
 Options:=Options+DT_RIGHT;
 if not EnableOutline.Checked then
 begin
  case RotateTextChooser.ItemIndex of
   0 : DrawText(Bitmap.Canvas.Handle, PChar(text), Length(text), aRect, Options);
   1 : StrRotated(arect.Right,arect.Top,Rect(0,0,arect.Bottom-arect.Top,arect.Right-arect.Left),Bitmap.Canvas.Handle, Bitmap.Canvas.Font.handle, text, 90,Options);
   2 : StrRotated(arect.Right,arect.Bottom,Rect(0,0,arect.Right-arect.Left,arect.Bottom-arect.Top),Bitmap.Canvas.Handle, Bitmap.Canvas.Font.handle, text, 180,Options);
   3 : StrRotated(arect.Left,arect.Bottom,Rect(0,0,arect.Bottom-arect.Top,arect.Right-arect.Left),Bitmap.Canvas.Handle, Bitmap.Canvas.Font.handle, text, 270,Options);
  end;
 end else
 begin
  if not FullImage then
  OutLineSize:=Min(100,Max(1,Round(OutLineSizeEdit.Value*GetZoom))) else OutLineSize:=OutLineSizeEdit.Value;
  case RotateTextChooser.ItemIndex of
   0 : CoolDrawTextEx(Bitmap, PChar(text),Bitmap.Canvas.Font.handle,OutLineSize,OutLineColorEdit.Brush.Color,aRect,0,Options);
   1 : CoolDrawTextEx(Bitmap, PChar(text),Bitmap.Canvas.Font.handle,OutLineSize,OutLineColorEdit.Brush.Color,aRect,1,Options);
   2 : CoolDrawTextEx(Bitmap, PChar(text),Bitmap.Canvas.Font.handle,OutLineSize,OutLineColorEdit.Brush.Color,aRect,2,Options);
   3 : CoolDrawTextEx(Bitmap, PChar(text),Bitmap.Canvas.Font.handle,OutLineSize,OutLineColorEdit.Brush.Color,aRect,3,Options);
  end;
 end;

end;

procedure TextToolClass.DoSaveSettings(Sender: TObject);
begin
 {$IFDEF PHOTODB}
 DBKernel.WriteString('Editor','TextToolText',TextMemo.Text);
 DBKernel.WriteString('Editor','TextToolFontName',FontNameEdit.Text);
 DBKernel.WriteInteger('Editor','TextToolFontSize',StrToIntDef(FontSizeEdit.Text,12));
 DBKernel.WriteInteger('Editor','TextToolFontColor',FontColorEdit.Brush.Color);
 DBKernel.WriteInteger('Editor','TextToolFontRotation',RotateTextChooser.ItemIndex);
 if LeftOrientationButton.Down then
 DBKernel.WriteInteger('Editor','TextToolFontOrientation',1);
 if CenterOrientationButton.Down then
 DBKernel.WriteInteger('Editor','TextToolFontOrientation',2);
 if RightOrientationButton.Down then
 DBKernel.WriteInteger('Editor','TextToolFontOrientation',3);
 DBKernel.WriteBool('Editor','TextToolEnableOutLine',EnableOutline.Checked);
 DBKernel.WriteInteger('Editor','TextToolOutLineColor',OutLineColorEdit.Brush.Color);
 DBKernel.WriteInteger('Editor','TextToolOutLineSize',OutLineSizeEdit.value);

 {$ENDIF}
end;

procedure TextToolClass.EnableOutlineClick(Sender: TObject);
begin
 if Loading then exit;
 OutLineSizeEdit.Enabled:=EnableOutline.Checked;
 OnTextChanged(Sender);
end;

procedure TextToolClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

class function TextToolClass.ID: string;
begin
 Result:='{E52516CC-8235-4A1D-A135-6D84A2E298E9}';
end;

procedure TextToolClass.OnTextChanged(Sender: TObject);
begin
 if Assigned(FProcRecteateImage) then FProcRecteateImage(Self);
end;

procedure TextToolClass.OutLineColorClick(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if not EnableOutline.Checked then exit;
 FontColorEditDialog.Color:=OutLineColorEdit.Brush.Color;
 if FontColorEditDialog.Execute then
 begin
  OutLineColorEdit.Brush.Color:=FontColorEditDialog.Color;
  OnTextChanged(Sender);
 end;
end;

procedure TextToolClass.SetProperties(Properties: String);
begin

end;

end.
