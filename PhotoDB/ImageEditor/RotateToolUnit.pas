unit RotateToolUnit;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
  Effects, Angle, Spin, Dialogs, GraphicsBaseTypes,
  uEditorTypes, UnitDBKernel, uMemory;

type
  TRotateToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    NewImage: TBitmap;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SelectChooseBox: TRadioGroup;
    CustomAngle: TAngle;
    AngleEdit: TSpinEdit;
    ColorEdit: TShape;
    ColorChooser: TColorDialog;
    ColorLabel: TLabel;
    ApplyOnDone: Boolean;
    FOnDone: TNotifyEvent;
  protected
    function LangID: string; override;
  public
    { Public declarations }
    FSID: string;
    class function ID: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClosePanel; override;
    procedure MakeTransform; override;
    procedure ClosePanelEvent(Sender: TObject);
    procedure SelectChooseBoxClick(Sender: TObject);
    procedure DoMakeImage(Sender: TObject);
    procedure SetThreadImage(Image: TBitmap; SID: string);
    procedure SetProgress(Progress: Integer; SID: string);
    procedure AngleChanged(Sender: TObject);
    procedure AngleEditChanged(Sender: TObject);
    procedure ColorLabelClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function GetProperties: string; override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    procedure SetProperties(Properties: string); override;
  end;

implementation

{ TCropToolPanelClass }

uses RotateToolThreadUnit, ImEditor;

procedure TRotateToolPanelClass.AngleChanged(Sender: TObject);
begin
  AngleEdit.Tag := 1;
  if Round(CustomAngle.Angle) < 0 then
    AngleEdit.Value := 360 + Round(CustomAngle.Angle)
  else
    AngleEdit.Value := Round(CustomAngle.Angle);
  AngleEdit.Tag := 0;
  if SelectChooseBox.ItemIndex <> 6 then
    SelectChooseBox.ItemIndex := 6
  else
    SelectChooseBoxClick(Sender);
end;

procedure TRotateToolPanelClass.AngleEditChanged(Sender: TObject);
begin
  if AngleEdit.Tag = 0 then
    CustomAngle.Angle := AngleEdit.Value;
end;

procedure TRotateToolPanelClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  if not ApplyOnDone then
    inherited;
end;

procedure TRotateToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
  CancelTempImage(True);
  ClosePanel;
end;

procedure TRotateToolPanelClass.ColorLabelClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  ColorChooser.Color := ColorEdit.Brush.Color;
  if ColorChooser.Execute then
  begin
    ColorEdit.Brush.Color := ColorChooser.Color;
    SelectChooseBoxClick(Sender);
  end;
end;

constructor TRotateToolPanelClass.Create(AOwner: TComponent);
var
  IcoOK, IcoCancel: TIcon;
begin
  inherited;
  ApplyOnDone := False;
  NewImage := nil;
  Align := AlClient;
  ApplyOnDone := False;
  IcoOK := TIcon.Create;
  IcoCancel := TIcon.Create;
  IcoOK.Handle := LoadIcon(HInstance, 'DOIT');
  IcoCancel.Handle := LoadIcon(HInstance, 'CANCELACTION');

  SelectChooseBox := TRadioGroup.Create(AOwner);
  SelectChooseBox.Top := 5;
  SelectChooseBox.Left := 5;
  SelectChooseBox.Width := 180;
  SelectChooseBox.Height := 150;
  SelectChooseBox.Parent := Self;
  SelectChooseBox.Items.Add(L('Ñhoose action'));
  SelectChooseBox.Items.Add(L('Rotate left'));
  SelectChooseBox.Items.Add(L('Rotate right'));
  SelectChooseBox.Items.Add(L('Rotate on 180 degree'));
  SelectChooseBox.Items.Add(L('Flip horizontal'));
  SelectChooseBox.Items.Add(L('Flip vertical'));
  SelectChooseBox.Items.Add(L('Custom angle'));
  SelectChooseBox.Caption := L('Actions');
  SelectChooseBox.ItemIndex := 0;
  SelectChooseBox.OnClick := SelectChooseBoxClick;

  CustomAngle := TAngle.Create(AOwner);
  CustomAngle.Parent := Self;
  CustomAngle.Top := SelectChooseBox.Top + SelectChooseBox.Height + 5;
  CustomAngle.Left := 5;
  CustomAngle.Width := 50;
  CustomAngle.Height := 50;
  CustomAngle.OnChange := AngleChanged;

  AngleEdit := TSpinEdit.Create(AOwner);
  AngleEdit.Top := SelectChooseBox.Top + SelectChooseBox.Height + 5;
  AngleEdit.Left := CustomAngle.Left + CustomAngle.Width + 20;
  AngleEdit.Width := 50;
  AngleEdit.OnChange := AngleEditChanged;
  AngleEdit.MaxValue := 360;
  AngleEdit.MinValue := 0;
  AngleEdit.Parent := Self;

  ColorEdit := TShape.Create(AOwner);
  ColorEdit.Top := SelectChooseBox.Top + SelectChooseBox.Height + 35;
  ColorEdit.Left := CustomAngle.Left + CustomAngle.Width + 20;
  ColorEdit.Width := 20;
  ColorEdit.Height := 20;
  ColorEdit.Brush.Color := $0;
  ColorEdit.Parent := Self;
  ColorEdit.OnMouseDown := ColorLabelClick;

  ColorLabel := TLabel.Create(AOwner);
  ColorLabel.Top := SelectChooseBox.Top + SelectChooseBox.Height + 40;
  ColorLabel.Left := CustomAngle.Left + CustomAngle.Width + 20 + ColorEdit.Width + 5;
  ColorLabel.Caption := L('Background color');
  ColorLabel.Parent := Self;

  ColorChooser := TColorDialog.Create(AOwner);

  MakeItLink := TWebLink.Create(Self);
  MakeItLink.Top := 230;
  MakeItLink.Left := 10;
  MakeItLink.Parent := Self;
  MakeItLink.Text := L('Apply');
  MakeItLink.Visible := True;
  MakeItLink.Color := clBtnface;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.Icon := IcoOK;
  MakeItLink.ImageCanRegenerate := True;
  IcoOK.Free;

  CloseLink := TWebLink.Create(Self);
  CloseLink.Top := 250;
  CloseLink.Left := 10;
  CloseLink.Parent := Self;
  CloseLink.Text := L('Close tool');
  CloseLink.Visible := True;
  CloseLink.Color := clBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.Icon := IcoCancel;
  CloseLink.ImageCanRegenerate := True;
  IcoCancel.Free;

end;

destructor TRotateToolPanelClass.Destroy;
begin
  F(CloseLink);
  F(MakeItLink);
  F(CustomAngle);
  F(SelectChooseBox);
  F(AngleEdit);
  F(ColorEdit);
  F(ColorChooser);
  F(ColorLabel);
  inherited;
end;

procedure TRotateToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

procedure TRotateToolPanelClass.ExecuteProperties(Properties: string; OnDone: TNotifyEvent);
begin
  FOnDone := OnDone;
  AngleEdit.Value := StrToIntDef(GetValueByName(Properties, 'Angle'), 0);
  SelectChooseBox.ItemIndex := StrToIntDef(GetValueByName(Properties, 'Action'), 0);
  ColorEdit.Brush.Color := StrToIntDef(GetValueByName(Properties, 'BkColor'), 0);
  ApplyOnDone := True;
  SelectChooseBoxClick(Self);
end;

function TRotateToolPanelClass.GetProperties: string;
begin
  Result := 'Angle=' + IntToStr(AngleEdit.Value) + ';';
  Result := Result + 'Action=' + IntToStr(SelectChooseBox.ItemIndex) + ';';
  Result := Result + 'BkColor=' + IntToStr(ColorEdit.Brush.Color) + ';';
end;

class function TRotateToolPanelClass.ID: string;
begin
  Result := '{747B3EAF-6219-4A96-B974-ABEB1405914B}';
end;

function TRotateToolPanelClass.LangID: string;
begin
  Result := 'RotateTool';
end;

procedure TRotateToolPanelClass.MakeTransform;
begin
  inherited;

  if NewImage <> nil then
  begin
    ImageHistory.Add(NewImage, '{' + ID + '}[' + GetProperties + ']');
    SetImagePointer(NewImage);
  end;

  ClosePanel;
end;

procedure TRotateToolPanelClass.SelectChooseBoxClick(Sender: TObject);
var
  Proc: TBaseEffectProc;
begin
  Proc := nil;
  case SelectChooseBox.ItemIndex of
    0:
      begin
        CancelTempImage(True);
        NewImage := nil;
        Exit;
      end;
    1:
      begin
        Proc := Effects.Rotate270;
      end;
    2:
      begin
        Proc := Effects.Rotate90;
      end;
    3:
      begin
        Proc := Effects.Rotate180;
      end;
    4:
      begin
        Proc := Effects.FlipHorizontal;
      end;
    5:
      begin
        Proc := Effects.FlipVertical;
      end;
    6:
      begin
        Proc := nil;
      end;
  end;
  FSID := IntToStr(Random(100000));
  begin
    NewImage := TBitmap.Create;
    NewImage.Assign(Image);
    NewImage.PixelFormat := pf24bit;
    Image.PixelFormat := pf24bit;
    TRotateEffectThread.Create(Self, False, Proc, NewImage, FSID, SetThreadImage, CustomAngle.Angle,
      ColorEdit.Brush.Color, Editor);
    NewImage := nil;
  end;
end;

procedure TRotateToolPanelClass.SetProgress(Progress: Integer; SID: string);
begin
  if SID = FSID then
    (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TRotateToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TRotateToolPanelClass.SetThreadImage(Image: TBitmap; SID: string);
begin
  if SID = FSID then
  begin
    NewImage := Image;
    SetTempImage(Image);
  end else
    F(Image);
  if ApplyOnDone then
  begin
    MakeTransform;
    if Assigned(FOnDone) then
      FOnDone(Self);
  end;
end;

end.
