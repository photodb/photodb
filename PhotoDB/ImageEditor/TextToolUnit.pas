unit TextToolUnit;

interface

uses CustomSelectTool, Windows, Classes, Graphics, Effects, GraphicsBaseTypes, Math,
     StdCtrls, Controls, Language, Forms, SysUtils, ExtCtrls, Buttons, Spin,
     UnitDBKernel, Dialogs, uDBGraphicTypes, uMemory;

type
  TextToolClass = Class(TCustomSelectToolClass)
  private
    { Private declarations }
    TextMemoLabel: TStaticText;
    TextMemo: TMemo;
    FontNameLabel: TStaticText;
    FontNameEdit: TComboBox;
    FontSizeLabel: TStaticText;
    FontSizeEdit: TComboBox;
    FontColorEdit: TShape;
    FontColorEditDialog: TColorDialog;
    FontColorLabel: TStaticText;
    RotateTextChooser: TRadioGroup;
    LeftOrientationButton: TSpeedButton;
    CenterOrientationButton: TSpeedButton;
    RightOrientationButton: TSpeedButton;
    OrientationLabel: TStaticText;
    EnableOutline: TCheckBox;
    OutLineSizeLabel: TStaticText;
    OutLineSizeEdit: TSpinEdit;
    OutLineColorLabel: TStaticText;
    OutLineColorEdit: TShape;
    Loading: Boolean;
  protected
    function LangID: string; override;
  public
    { Public declarations }
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
  end;

implementation

{ TextToolClass }

{$R TextToolRes.res}

procedure TextToolClass.ColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FontColorEditDialog.Color := FontColorEdit.Brush.Color;
  if FontColorEditDialog.Execute then
  begin
    FontColorEdit.Brush.Color := FontColorEditDialog.Color;
    OnTextChanged(Sender);
  end;
end;

constructor TextToolClass.Create(AOwner: TComponent);
const
  MaxSizes = 21;
  Sizes: array [1 .. MaxSizes] of Integer = (8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 45, 50, 60, 70, 80, 100, 120, 150,
    200, 400, 600);
var
  I: Integer;
  Bit : TBitmap;

begin
  inherited;
  AnyRect := True;
  Loading := True;
  CloseLink.Hide;
  MakeItLink.Hide;
  SaveSettingsLink.Hide;
  TextMemoLabel := TStaticText.Create(AOwner);
  TextMemoLabel.Top := EditWidth.Top + EditWidth.Height + 5;
  TextMemoLabel.Left := 8;
  TextMemoLabel.Caption := L('Text') + ':';
  TextMemoLabel.Parent := AOwner as TWinControl;

  TextMemo := TMemo.Create(AOwner);
  TextMemo.Top := TextMemoLabel.Top + TextMemoLabel.Height + 2;
  TextMemo.Left := 8;
  TextMemo.Width := 160;
  TextMemo.Height := 40;
  TextMemo.ScrollBars := SsVertical;
  TextMemo.OnChange := OnTextChanged;
  TextMemo.Parent := AOwner as TWinControl;
  if DBKernel.ReadString('Editor', 'TextToolText') <> '' then
    TextMemo.Text := DBKernel.ReadString('Editor', 'TextToolText')
  else
    TextMemo.Text := L('My text');

  FontNameLabel := TStaticText.Create(AOwner);
  FontNameLabel.Top := TextMemo.Top + TextMemo.Height + 5;
  FontNameLabel.Left := 8;
  FontNameLabel.Caption := L('Font name') + ':';
  FontNameLabel.Parent := AOwner as TWinControl;

  FontNameEdit := TComboBox.Create(AOwner);
  FontNameEdit.Top := FontNameLabel.Top + FontNameLabel.Height + 2;
  FontNameEdit.Left := 8;
  FontNameEdit.OnChange := OnTextChanged;
  FontNameEdit.Parent := AOwner as TWinControl;
  FontNameEdit.Items := Screen.Fonts;
  if DBKernel.ReadString('Editor', 'TextToolFontName') <> '' then
    FontNameEdit.Text := DBKernel.ReadString('Editor', 'TextToolFontName')
  else
    FontNameEdit.Text := 'Times New Roman';

  FontSizeLabel := TStaticText.Create(AOwner);
  FontSizeLabel.Top := FontNameEdit.Top + FontNameEdit.Height + 3;
  FontSizeLabel.Left := 8;
  FontSizeLabel.Caption := L('Font size');
  FontSizeLabel.Parent := AOwner as TWinControl;

  FontSizeEdit := TComboBox.Create(AOwner);
  FontSizeEdit.Top := FontSizeLabel.Top + FontSizeLabel.Height + 2;
  FontSizeEdit.Left := 8;
  FontSizeEdit.OnChange := OnTextChanged;
  FontSizeEdit.Parent := AOwner as TWinControl;
  FontSizeEdit.Items.Clear;
  FontSizeEdit.Width := 45;
  for I := 1 to MaxSizes do
    FontSizeEdit.Items.Add(IntToStr(Sizes[I]));

  if DBKernel.ReadInteger('Editor', 'TextToolFontSize', 0) <> 0 then
    FontSizeEdit.Text := IntToStr(DBKernel.ReadInteger('Editor', 'TextToolFontSize', 0))
  else
    FontSizeEdit.Text := '12';

  FontColorEdit := TShape.Create(Self);
  FontColorEdit.Parent := Self as TWinControl;
  FontColorEdit.Top := FontSizeLabel.Top + FontSizeLabel.Height + 2;
  FontColorEdit.Left := FontSizeEdit.Left + FontSizeEdit.Width + 10;
  FontColorEdit.Width := 16;
  FontColorEdit.Height := 16;
  FontColorEdit.OnMouseDown := ColorClick;
  FontColorEdit.Pen.Color := 0;

  if DBKernel.ReadInteger('Editor', 'TextToolFontColor', -1) <> -1 then
    FontColorEdit.Brush.Color := DBKernel.ReadInteger('Editor', 'TextToolFontColor', 0)
  else
    FontColorEdit.Brush.Color := 0;

  FontColorEditDialog := TColorDialog.Create(AOwner);

  FontColorLabel := TStaticText.Create(AOwner);
  FontColorLabel.Top := FontSizeLabel.Top + FontSizeLabel.Height + 3;
  FontColorLabel.Left := FontColorEdit.Left + FontColorEdit.Width + 5;
  FontColorLabel.Caption := L('Font color');
  FontColorLabel.Parent := AOwner as TWinControl;

  RotateTextChooser := TRadioGroup.Create(AOwner);
  RotateTextChooser.Caption := L('Text rotation');
  RotateTextChooser.Left := 8;
  RotateTextChooser.Width := 160;
  RotateTextChooser.Height := 80;
  RotateTextChooser.Top := FontColorLabel.Top + FontColorLabel.Height + 5;
  RotateTextChooser.Parent := AOwner as TWinControl;
  RotateTextChooser.OnClick := OnTextChanged;
  RotateTextChooser.Items.Clear;
  RotateTextChooser.Items.Add(L('Normal'));
  RotateTextChooser.Items.Add(L('90°'));
  RotateTextChooser.Items.Add(L('180°'));
  RotateTextChooser.Items.Add(L('270°'));
  RotateTextChooser.ItemIndex := DBKernel.ReadInteger('Editor', 'TextToolFontRotation', 0);

  OrientationLabel := TStaticText.Create(AOwner);
  OrientationLabel.Top := RotateTextChooser.Top + RotateTextChooser.Height + 3;
  OrientationLabel.Left := 8;
  OrientationLabel.Caption := L('Text orientation');
  OrientationLabel.Parent := AOwner as TWinControl;

  LeftOrientationButton := TSpeedButton.Create(AOwner);
  LeftOrientationButton.Width := 20;
  LeftOrientationButton.Height := 20;
  LeftOrientationButton.Left := 8;
  LeftOrientationButton.GroupIndex := 1;
  LeftOrientationButton.Top := OrientationLabel.Top + OrientationLabel.Height + 2;
  LeftOrientationButton.OnClick := OnTextChanged;
  LeftOrientationButton.Parent := Self;
  Bit := TBitmap.Create;
  try
    LeftOrientationButton.Glyph.Handle := LoadBitmap(HInstance, 'LEFTTEXT');
    LeftOrientationButton.Glyph := Bit;
  finally
    F(Bit);
  end;

  CenterOrientationButton := TSpeedButton.Create(AOwner);
  CenterOrientationButton.Width := 20;
  CenterOrientationButton.Height := 20;
  CenterOrientationButton.Left := LeftOrientationButton.Left + LeftOrientationButton.Width + 2;
  CenterOrientationButton.GroupIndex := 1;
  CenterOrientationButton.Top := OrientationLabel.Top + OrientationLabel.Height + 2;
  CenterOrientationButton.OnClick := OnTextChanged;
  CenterOrientationButton.Parent := Self;

  Bit := TBitmap.Create;
  try
    CenterOrientationButton.Glyph.Handle := LoadBitmap(HInstance, 'CENTERTEXT');
    CenterOrientationButton.Glyph := Bit;
  finally
    F(Bit);
  end;

  RightOrientationButton := TSpeedButton.Create(AOwner);
  RightOrientationButton.Width := 20;
  RightOrientationButton.Height := 20;
  RightOrientationButton.Left := CenterOrientationButton.Left + CenterOrientationButton.Width + 2;
  RightOrientationButton.GroupIndex := 1;
  RightOrientationButton.Top := OrientationLabel.Top + OrientationLabel.Height + 2;
  RightOrientationButton.OnClick := OnTextChanged;
  RightOrientationButton.Parent := Self;
  Bit := TBitmap.Create;
  try
    RightOrientationButton.Glyph.Handle := LoadBitmap(HInstance, 'RIGHTTEXT');
    RightOrientationButton.Glyph := Bit;
  finally
    F(Bit);
  end;

  case DBKernel.ReadInteger('Editor', 'TextToolFontOrientation', 1) of
    1:
      LeftOrientationButton.Down := True;
    2:
      CenterOrientationButton.Down := True;
    3:
      RightOrientationButton.Down := True;
  else
    LeftOrientationButton.Down := True;
  end;

  EnableOutline := TCheckBox.Create(AOwner);
  EnableOutline.Top := RightOrientationButton.Top + RightOrientationButton.Height + 3;
  EnableOutline.Left := 8;
  EnableOutline.Width := 160;
  EnableOutline.Caption := L('Use outline color');
  EnableOutline.OnClick := EnableOutlineClick;
  EnableOutline.Checked := DBKernel.ReadBool('Editor', 'TextToolEnableOutLine', False);
  EnableOutline.Parent := Self;

  OutLineSizeLabel := TStaticText.Create(AOwner);
  OutLineSizeLabel.Top := EnableOutline.Top + EnableOutline.Height + 3;
  OutLineSizeLabel.Left := 8;
  OutLineSizeLabel.Caption := L('Size') + ':';
  OutLineSizeLabel.Parent := Self;

  OutLineSizeEdit := TSpinEdit.Create(AOwner);
  OutLineSizeEdit.Top := OutLineSizeLabel.Top + OutLineSizeLabel.Height + 3;
  OutLineSizeEdit.Left := 8;
  OutLineSizeEdit.Width := 50;
  OutLineSizeEdit.MinValue := 1;
  OutLineSizeEdit.MaxValue := 100;
  OutLineSizeEdit.Value := DBKernel.ReadInteger('Editor', 'TextToolOutLineSize', 5);
  OutLineSizeEdit.OnChange := OnTextChanged;
  OutLineSizeEdit.Parent := Self;
  OutLineSizeEdit.Enabled := EnableOutline.Checked;

  OutLineColorLabel := TStaticText.Create(AOwner);
  OutLineColorLabel.Left := OutLineSizeEdit.Left + OutLineSizeEdit.Width + 15;
  OutLineColorLabel.Top := EnableOutline.Top + EnableOutline.Height + 3;
  OutLineColorLabel.Caption := L('Color') + ':';
  OutLineColorLabel.Parent := Self;

  OutLineColorEdit := TShape.Create(AOwner);
  OutLineColorEdit.Top := OutLineSizeLabel.Top + OutLineSizeLabel.Height + 5;
  OutLineColorEdit.Left := OutLineSizeEdit.Left + OutLineSizeEdit.Width + 15;
  OutLineColorEdit.Width := 15;
  OutLineColorEdit.Height := 15;
  OutLineColorEdit.Brush.Color := DBKernel.ReadInteger('Editor', 'TextToolOutLineColor', OutLineColorEdit.Brush.Color);

  OutLineColorEdit.OnMouseDown := OutLineColorClick;
  OutLineColorEdit.Parent := Self;

  SaveSettingsLink.Top := OutLineSizeEdit.Top + OutLineSizeEdit.Height + 10;
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Show;
  MakeItLink.Show;
  SaveSettingsLink.Show;
  Loading := False;
end;

destructor TextToolClass.Destroy;
begin
  F(TextMemo);
  F(TextMemoLabel);
  F(FontNameLabel);
  F(FontNameEdit);
  F(FontSizeLabel);
  F(FontSizeEdit);
  F(FontColorEdit);
  F(FontColorEditDialog);
  F(FontColorLabel);
  F(RotateTextChooser);
  F(OrientationLabel);
  F(LeftOrientationButton);
  F(CenterOrientationButton);
  F(RightOrientationButton);
  F(EnableOutline);
  F(OutLineSizeLabel);
  F(OutLineSizeEdit);
  F(OutLineColorLabel);
  F(OutLineColorEdit);
  inherited;
end;

procedure TextToolClass.DoBorder(Bitmap: TBitmap; aRect: TRect);
var
  Xdp: TArPARGB;
  Rct: TRect;
  I, J: Integer;

  procedure Border(I, J: Integer; var RGB: TRGB);
  begin
    if Odd((I + J) div 3) then
    begin
      RGB.R := RGB.R div 5;
      RGB.G := RGB.G div 5;
      RGB.B := RGB.B div 5;
    end else
    begin
      RGB.R := RGB.R xor $FF;
      RGB.G := RGB.G xor $FF;
      RGB.B := RGB.B xor $FF;
    end;
  end;

begin
  Rct.Top := Min(ARect.Top, ARect.Bottom);
  Rct.Bottom := Max(ARect.Top, ARect.Bottom);
  Rct.Left := Min(ARect.Left, ARect.Right);
  Rct.Right := Max(ARect.Left, ARect.Right);
  ARect := Rct;
  SetLength(Xdp, Bitmap.Height);
  for I := 0 to Bitmap.Height - 1 do
    Xdp[I] := Bitmap.ScanLine[I];

  I := Min(Bitmap.Height - 1, Max(0, ARect.Top));
  if I = ARect.Top then
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (J > ARect.Left) and (J < ARect.Right) then
        Border(I, J, Xdp[I, J]);
    end;

  I := Min(Bitmap.Height - 1, Max(0, ARect.Bottom));
  if I = ARect.Bottom then
    for J := 0 to Bitmap.Width - 1 do
    begin
      if (J > ARect.Left) and (J < ARect.Right) then
        Border(I, J, Xdp[I, J]);
    end;

  for I := Max(0, ARect.Top) to Min(ARect.Bottom - 1, Bitmap.Height - 1) do
  begin
    J := Max(0, Min(Bitmap.Width - 1, ARect.Left));
    if J = ARect.Left then
      Border(I, J, Xdp[I, J]);
  end;
  for I := Max(0, ARect.Top) to Min(ARect.Bottom - 1, Bitmap.Height - 1) do
  begin
    J := Min(Bitmap.Width - 1, Max(0, ARect.Right));
    if J = ARect.Right then
      Border(I, J, Xdp[I, J]);
  end;
end;

procedure TextToolClass.DoEffect(Bitmap: TBitmap; aRect: TRect; FullImage : Boolean);
var
  FontSize: Extended;
  Text: string;
  Rct: TRect;
  IntSize, OutLineSize: Integer;
  Options: Cardinal;
begin
  Rct.Top := Min(ARect.Top, ARect.Bottom);
  Rct.Bottom := Max(ARect.Top, ARect.Bottom);
  Rct.Left := Min(ARect.Left, ARect.Right);
  Rct.Right := Max(ARect.Left, ARect.Right);
  ARect := Rct;
  Text := TextMemo.Text;
  Bitmap.Canvas.Brush.Style := BsClear;
  Bitmap.Canvas.Font.name := FontNameEdit.Text;
  Bitmap.Canvas.Font.Color := FontColorEdit.Brush.Color;
  IntSize := StrToIntDef(FontSizeEdit.Text, 12);
  if not FullImage then
    FontSize := (IntSize * GetZoom)
  else
    FontSize := IntSize;
  Bitmap.Canvas.Font.Size := Round(FontSize);
  Options := DT_WORDBREAK;
  if LeftOrientationButton.Down then
    Options := Options + DT_LEFT;
  if CenterOrientationButton.Down then
    Options := Options + DT_CENTER;
  if RightOrientationButton.Down then
    Options := Options + DT_RIGHT;

  if not EnableOutline.Checked then
  begin
    case RotateTextChooser.ItemIndex of
      0:
        DrawText(Bitmap.Canvas.Handle, PChar(Text), Length(Text), ARect, Options);
      1:
        StrRotated(Arect.Right, Arect.Top, Rect(0, 0, Arect.Bottom - Arect.Top, Arect.Right - Arect.Left),
          Bitmap.Canvas.Handle, Bitmap.Canvas.Font.Handle, Text, 90, Options);
      2:
        StrRotated(Arect.Right, Arect.Bottom, Rect(0, 0, Arect.Right - Arect.Left, Arect.Bottom - Arect.Top),
          Bitmap.Canvas.Handle, Bitmap.Canvas.Font.Handle, Text, 180, Options);
      3:
        StrRotated(Arect.Left, Arect.Bottom, Rect(0, 0, Arect.Bottom - Arect.Top, Arect.Right - Arect.Left),
          Bitmap.Canvas.Handle, Bitmap.Canvas.Font.Handle, Text, 270, Options);
    end;
  end else
  begin
    if not FullImage then
      OutLineSize := Min(100, Max(1, Round(OutLineSizeEdit.Value * GetZoom)))
    else
      OutLineSize := OutLineSizeEdit.Value;
    case RotateTextChooser.ItemIndex of
      0:
        CoolDrawTextEx(Bitmap, PChar(Text), Bitmap.Canvas.Font.Handle, OutLineSize, OutLineColorEdit.Brush.Color,
          ARect, 0, Options);
      1:
        CoolDrawTextEx(Bitmap, PChar(Text), Bitmap.Canvas.Font.Handle, OutLineSize, OutLineColorEdit.Brush.Color,
          ARect, 1, Options);
      2:
        CoolDrawTextEx(Bitmap, PChar(Text), Bitmap.Canvas.Font.Handle, OutLineSize, OutLineColorEdit.Brush.Color,
          ARect, 2, Options);
      3:
        CoolDrawTextEx(Bitmap, PChar(Text), Bitmap.Canvas.Font.Handle, OutLineSize, OutLineColorEdit.Brush.Color,
          ARect, 3, Options);
    end;
  end;
end;

procedure TextToolClass.DoSaveSettings(Sender: TObject);
begin
  DBKernel.WriteString('Editor', 'TextToolText', TextMemo.Text);
  DBKernel.WriteString('Editor', 'TextToolFontName', FontNameEdit.Text);
  DBKernel.WriteInteger('Editor', 'TextToolFontSize', StrToIntDef(FontSizeEdit.Text, 12));
  DBKernel.WriteInteger('Editor', 'TextToolFontColor', FontColorEdit.Brush.Color);
  DBKernel.WriteInteger('Editor', 'TextToolFontRotation', RotateTextChooser.ItemIndex);
  if LeftOrientationButton.Down then
    DBKernel.WriteInteger('Editor', 'TextToolFontOrientation', 1);
  if CenterOrientationButton.Down then
    DBKernel.WriteInteger('Editor', 'TextToolFontOrientation', 2);
  if RightOrientationButton.Down then
    DBKernel.WriteInteger('Editor', 'TextToolFontOrientation', 3);
  DBKernel.WriteBool('Editor', 'TextToolEnableOutLine', EnableOutline.Checked);
  DBKernel.WriteInteger('Editor', 'TextToolOutLineColor', OutLineColorEdit.Brush.Color);
  DBKernel.WriteInteger('Editor', 'TextToolOutLineSize', OutLineSizeEdit.Value);
end;

procedure TextToolClass.EnableOutlineClick(Sender: TObject);
begin
  if Loading then
    Exit;
  OutLineSizeEdit.Enabled := EnableOutline.Checked;
  OnTextChanged(Sender);
end;

procedure TextToolClass.ExecuteProperties(Properties: string; OnDone: TNotifyEvent);
begin

end;

class function TextToolClass.ID: string;
begin
  Result := '{E52516CC-8235-4A1D-A135-6D84A2E298E9}';
end;

function TextToolClass.LangID: string;
begin
  Result := 'TextTool';
end;

procedure TextToolClass.OnTextChanged(Sender: TObject);
begin
  if Assigned(FProcRecteateImage) then
    FProcRecteateImage(Self);
end;

procedure TextToolClass.OutLineColorClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not EnableOutline.Checked then
    Exit;
  FontColorEditDialog.Color := OutLineColorEdit.Brush.Color;
  if FontColorEditDialog.Execute then
  begin
    OutLineColorEdit.Brush.Color := FontColorEditDialog.Color;
    OnTextChanged(Sender);
  end;
end;

procedure TextToolClass.SetProperties(Properties: string);
begin

end;

end.
