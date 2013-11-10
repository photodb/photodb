unit ResizeToolUnit;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,


  Dmitry.Controls.WebLink,

  ToolsUnit,
  ImageHistoryUnit,
  UnitResampleFilters,


  uSettings,
  uBitmapUtils,
  uConstants,
  uEditorTypes,
  uMemory;

type
  TResizeToolPanelClass = class(TToolsPanelClass)
  private
    { Private declarations }
    NewImage: TBitmap;
    CloseLink: TWebLink;
    MakeItLink: TWebLink;
    SaveSettingsLink: TWebLink;
    SelectChooseBox: TRadioGroup;
    RadioButton100x100: TRadioButton;
    RadioButton200x200: TRadioButton;
    RadioButton600x800: TRadioButton;
    RadioButton_Custom: TRadioButton;
    CheckBoxSaveProportions: TCheckBox;
    RadioButtonPercent: TRadioButton;
    ComboBoxPercent: TComboBox;
    MethodLabel: Tlabel;
    ComboBoxMethod: TComboBox;
    WidthEdit, HeightEdit: TEdit;
    WidthEditLabel, HeightEditLabel: Tlabel;
    Loading: Boolean;
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
    procedure DoMakeImage(Sender: TObject);
    procedure ChangeSize(Sender: TObject);
    procedure ComboBoxPercentSelect(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure SetThreadImage(Image: TBitmap; SID: string);
    procedure SetProgress(Progress: Integer; SID: string);
    procedure DoSaveSettings(Sender: TObject);
    function GetProperties: string; override;
    function GetZoom: Real;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    procedure SetProperties(Properties: string); override;
  end;

const
  StFilters = 2;

implementation

uses
  ImEditor,
  ResizeToolThreadUnit;

{ TResizeToolPanelClass }

procedure TResizeToolPanelClass.ChangeSize(Sender: TObject);
var
  ImageSizeW, ImageSizeH, W, H: Integer;
  Method: TResizeProcedure;

  function GetZoom: Real;
  var
    S: string;
    I: Integer;
  begin
    S := ComboBoxPercent.Text;
    if S = '' then
      S := '100';
    for I := Length(S) downto 1 do
      if not CharInSet(S[I], Abs_cifr) then
        Delete(S, I, 1);
    Result := StrToFloatDef(S, 50) / 100;
  end;

begin
  if Loading then
    Exit;
  ImageSizeW := 1;
  ImageSizeH := 1;
  if RadioButton100x100.Checked then
  begin
    ImageSizeW := 100;
    ImageSizeH := 100;
  end;
  if RadioButton200x200.Checked then
  begin
    ImageSizeW := 200;
    ImageSizeH := 200;
  end;
  if RadioButton600x800.Checked then
  begin
    ImageSizeW := 800;
    ImageSizeH := 600;
  end;
  if RadioButton_Custom.Checked then
  begin
    ImageSizeW := StrToIntDef(WidthEdit.Text, 100);
    ImageSizeH := StrToIntDef(HeightEdit.Text, 100);
  end;
  W := Image.Width;
  H := Image.Height;
  if RadioButtonPercent.Checked then
  begin
    ImageSizeW := Round(W * GetZoom);
    ImageSizeH := Round(H * GetZoom);
  end;
  if CheckBoxSaveProportions.Checked then
  begin
    ProportionalSizeA(ImageSizeW, ImageSizeH, W, H);
  end else
  begin
    W := ImageSizeW;
    H := ImageSizeH;
  end;
  if Image = nil then
    Exit;
  NewImage := TBitmap.Create;
  NewImage.Assign(Image);
  FSID := IntToStr(Random(MaxInt));
  case ComboBoxMethod.ItemIndex of
    0:
      Method := SmoothResize;
    1:
      Method := StretchCool;
    2:
      Method := ThumbnailResize;
  else
    Method := nil;
  end;
  TResizeToolThread.Create(Self, Method, ComboBoxMethod.ItemIndex - StFilters - 1, False, NewImage, FSID,
    SetThreadImage, W, H, Editor);
end;

procedure TResizeToolPanelClass.ClosePanel;
begin
  if Assigned(OnClosePanel) then
    OnClosePanel(Self);
  if not ApplyOnDone then
    inherited;
end;

procedure TResizeToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
  CancelTempImage(True);
  ClosePanel;
end;

procedure TResizeToolPanelClass.ComboBoxPercentSelect(Sender: TObject);
begin
  RadioButtonPercent.Checked := True;
  ChangeSize(Sender);
end;

constructor TResizeToolPanelClass.Create(AOwner: TComponent);
var
  Left, I: Integer;
const
  PercentCount = 11;
  Percents: array [1 .. PercentCount] of Integer = (500, 200, 95, 75, 66, 50, 33, 25, 15, 10, 5);
begin
  inherited;
  ApplyOnDone := False;
  Loading := True;
  NewImage := nil;
  ApplyOnDone := False;
  Align := AlClient;
  Left := 8;

  SelectChooseBox := TRadioGroup.Create(nil);
  SelectChooseBox.Top := 3;
  SelectChooseBox.Left := 3;
  SelectChooseBox.Caption := L('Change size');
  SelectChooseBox.Parent := AOwner as TWinControl;
  SelectChooseBox.Width := 180;
  SelectChooseBox.Height := 270;

  RadioButton100x100 := TRadioButton.Create(nil);
  RadioButton100x100.Top := 20;
  RadioButton100x100.Left := Left;
  RadioButton100x100.Width := 170;
  RadioButton100x100.Caption := L('Convert to 100x100');
  RadioButton100x100.Parent := AOwner as TWinControl;
  RadioButton100x100.OnClick := ChangeSize;

  RadioButton200x200 := TRadioButton.Create(nil);
  RadioButton200x200.Top := RadioButton100x100.Top + RadioButton100x100.Height + 5;
  RadioButton200x200.Left := Left;
  RadioButton200x200.Width := 170;
  RadioButton200x200.Caption := L('Convert to 200x200');
  RadioButton200x200.Parent := AOwner as TWinControl;
  RadioButton200x200.OnClick := ChangeSize;

  RadioButton600x800 := TRadioButton.Create(nil);
  RadioButton600x800.Top := RadioButton200x200.Top + RadioButton200x200.Height + 5;
  RadioButton600x800.Left := Left;
  RadioButton600x800.Width := 170;
  RadioButton600x800.Caption := L('Convert to 600x800');
  RadioButton600x800.Parent := AOwner as TWinControl;
  RadioButton600x800.OnClick := ChangeSize;

  RadioButton_Custom := TRadioButton.Create(nil);
  RadioButton_Custom.Top := RadioButton600x800.Top + RadioButton600x800.Height + 5;
  RadioButton_Custom.Left := Left;
  RadioButton_Custom.Width := 170;
  RadioButton_Custom.Caption := L('Custom size') + ':';
  RadioButton_Custom.Parent := AOwner as TWinControl;
  RadioButton_Custom.Checked := True;
  RadioButton_Custom.OnClick := ChangeSize;

  WidthEditLabel := Tlabel.Create(nil);
  WidthEditLabel.Top := RadioButton_Custom.Top + RadioButton_Custom.Height + 5;
  WidthEditLabel.Left := Left;
  WidthEditLabel.Width := 50;
  WidthEditLabel.Parent := SelectChooseBox;
  WidthEditLabel.Caption := L('Width') + ':';

  HeightEditLabel := Tlabel.Create(nil);
  HeightEditLabel.Top := RadioButton_Custom.Top + RadioButton_Custom.Height + 5; ;
  HeightEditLabel.Left := 85;
  HeightEditLabel.Width := 50;
  HeightEditLabel.Parent := SelectChooseBox;
  HeightEditLabel.Caption := L('Height') + ':';

  WidthEdit := TEdit.Create(nil);
  WidthEdit.Top := WidthEditLabel.Top + WidthEditLabel.Height + 5;
  WidthEdit.Left := Left;
  WidthEdit.Width := 50;
  WidthEdit.Text := '1024';
  WidthEdit.Parent := AOwner as TWinControl;
  WidthEdit.OnChange := EditChange;

  HeightEdit := TEdit.Create(nil);
  HeightEdit.Top := HeightEditLabel.Top + HeightEditLabel.Height + 5;
  HeightEdit.Left := 85;
  HeightEdit.Width := 50;
  HeightEdit.Text := '768';
  HeightEdit.Parent := AOwner as TWinControl;
  HeightEdit.OnChange := EditChange;

  CheckBoxSaveProportions := TCheckBox.Create(nil);
  CheckBoxSaveProportions.Top := WidthEdit.Top + WidthEdit.Height + 5;
  CheckBoxSaveProportions.Left := Left;
  CheckBoxSaveProportions.Width := 150;
  CheckBoxSaveProportions.Caption := L('Save aspect ratio');
  CheckBoxSaveProportions.Parent := AOwner as TWinControl;
  CheckBoxSaveProportions.OnClick := ChangeSize;
  CheckBoxSaveProportions.Checked := True;

  RadioButtonPercent := TRadioButton.Create(nil);
  RadioButtonPercent.Top := CheckBoxSaveProportions.Top + CheckBoxSaveProportions.Height + 5;
  RadioButtonPercent.Left := Left;
  RadioButtonPercent.Width := 170;
  RadioButtonPercent.Caption := L('Scale');
  RadioButtonPercent.Parent := AOwner as TWinControl;
  RadioButtonPercent.OnClick := ChangeSize;

  ComboBoxPercent := TComboBox.Create(nil);
  ComboBoxPercent.Top := RadioButtonPercent.Top + RadioButtonPercent.Height + 5;
  ComboBoxPercent.Left := Left;
  ComboBoxPercent.Width := 170;
  ComboBoxPercent.Parent := AOwner as TWinControl;
  ComboBoxPercent.OnChange := ChangeSize;
  ComboBoxPercent.OnSelect := ComboBoxPercentSelect;
  for I := 1 to PercentCount do
    ComboBoxPercent.Items.Add(IntToStr(Percents[I]) + '%');

  MethodLabel := Tlabel.Create(nil);
  MethodLabel.Top := ComboBoxPercent.Top + ComboBoxPercent.Height + 5; ;
  MethodLabel.Left := 8;
  MethodLabel.Width := 50;
  MethodLabel.Parent := SelectChooseBox;
  MethodLabel.Caption := L('Method') + ':';

  ComboBoxMethod := TComboBox.Create(nil);
  ComboBoxMethod.Top := MethodLabel.Top + MethodLabel.Height + 5;
  ComboBoxMethod.Left := 8;
  ComboBoxMethod.Width := 170;
  ComboBoxMethod.Parent := AOwner as TWinControl;
  ComboBoxMethod.OnChange := ChangeSize;
  ComboBoxMethod.Style := CsDropDownList;
  ComboBoxMethod.Items.Add(L('Smooth resizing'));
  ComboBoxMethod.Items.Add(L('Base resizing'));
  ComboBoxMethod.Items.Add(L('Resizing with sharpness'));
  for I := 0 to 6 do
    ComboBoxMethod.Items.Add(ResampleFilters[I].Name);

  ComboBoxMethod.ItemIndex := 0;

  SaveSettingsLink := TWebLink.Create(nil);
  SaveSettingsLink.Parent := AOwner as TWinControl;
  SaveSettingsLink.Text := L('Save settings');
  SaveSettingsLink.Top := SelectChooseBox.Top + SelectChooseBox.Height + 10;
  SaveSettingsLink.Left := 10;
  SaveSettingsLink.Visible := True;
  SaveSettingsLink.Color := ClBtnface;
  SaveSettingsLink.OnClick := DoSaveSettings;
  SaveSettingsLink.LoadFromResource('SAVETOFILE');
  SaveSettingsLink.RefreshBuffer(True);

  MakeItLink := TWebLink.Create(nil);
  MakeItLink.Parent := AOwner as TWinControl;
  MakeItLink.Text := L('Apply');
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  MakeItLink.Left := 10;
  MakeItLink.Visible := True;
  MakeItLink.Color := ClBtnface;
  MakeItLink.OnClick := DoMakeImage;
  MakeItLink.LoadFromResource('DOIT');
  MakeItLink.RefreshBuffer(True);

  CloseLink := TWebLink.Create(nil);
  CloseLink.Parent := AOwner as TWinControl;
  CloseLink.Text := L('Close tool');
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  CloseLink.Left := 10;
  CloseLink.Visible := True;
  CloseLink.Color := ClBtnface;
  CloseLink.OnClick := ClosePanelEvent;
  CloseLink.LoadFromResource('CANCELACTION');
  CloseLink.RefreshBuffer(True);

  ComboBoxPercent.Text := IntToStr(AppSettings.ReadInteger('Editor', 'PercentValue', 100)) + '%';
  WidthEdit.Text := IntToStr(AppSettings.ReadInteger('Editor', 'CustomWidth', 100));
  HeightEdit.Text := IntToStr(AppSettings.ReadInteger('Editor', 'CustomHeight', 100));
  RadioButton100x100.Checked := AppSettings.ReadBool('Editor', 'ResizeTo100x100', False);
  RadioButton200x200.Checked := AppSettings.ReadBool('Editor', 'ResizeTo200x200', False);
  RadioButton600x800.Checked := AppSettings.ReadBool('Editor', 'ResizeTo600x800', True);
  RadioButton_Custom.Checked := AppSettings.ReadBool('Editor', 'ResizeToCustom', False);
  CheckBoxSaveProportions.Checked := AppSettings.ReadBool('Editor', 'SaveProportions', True);
  RadioButtonPercent.Checked := AppSettings.ReadBool('Editor', 'ResizeToPercent', False);
  ComboBoxMethod.ItemIndex := AppSettings.ReadInteger('Editor', 'ResizeMethod', 0);
  Loading := False;
end;

destructor TResizeToolPanelClass.Destroy;
begin
  F(CloseLink);
  F(MakeItLink);
  F(SaveSettingsLink);
  F(ComboBoxMethod);
  F(RadioButton100x100);
  F(RadioButton200x200);
  F(RadioButton600x800);
  F(RadioButton_Custom);
  F(CheckBoxSaveProportions);
  F(RadioButtonPercent);
  F(ComboBoxPercent);
  F(MethodLabel);
  F(WidthEdit);
  F(HeightEdit);
  F(WidthEditLabel);
  F(HeightEditLabel);
  F(SelectChooseBox);
  inherited;
end;

procedure TResizeToolPanelClass.DoMakeImage(Sender: TObject);
begin
  MakeTransform;
end;

function TResizeToolPanelClass.GetZoom: Real;
var
  S: string;
  I: Integer;
begin
  S := ComboBoxPercent.Text;
  if S = '' then
    S := '100';
  for I := Length(S) downto 1 do
    if not CharInSet(S[I], Abs_cifr) then
      Delete(S, I, 1);
  Result := StrToFloatDef(S, 50) / 100;
end;

procedure TResizeToolPanelClass.DoSaveSettings(Sender: TObject);
begin
  AppSettings.WriteBool('Editor', 'ResizeTo100x100', RadioButton100x100.Checked);
  AppSettings.WriteBool('Editor', 'ResizeTo200x200', RadioButton200x200.Checked);
  AppSettings.WriteBool('Editor', 'ResizeTo600x800', RadioButton600x800.Checked);
  AppSettings.WriteBool('Editor', 'ResizeToCustom', RadioButton_Custom.Checked);
  AppSettings.WriteBool('Editor', 'SaveProportions', CheckBoxSaveProportions.Checked);
  AppSettings.WriteBool('Editor', 'ResizeToPercent', RadioButtonPercent.Checked);
  AppSettings.WriteInteger('Editor', 'ResizeMethod', ComboBoxMethod.ItemIndex);
  AppSettings.WriteInteger('Editor', 'CustomWidth', StrToIntDef(WidthEdit.Text, 100));
  AppSettings.WriteInteger('Editor', 'CustomHeight', StrToIntDef(HeightEdit.Text, 100));
  AppSettings.WriteInteger('Editor','PercentValue',Round(GetZoom*100));
end;

procedure TResizeToolPanelClass.EditChange(Sender: TObject);
begin
  RadioButton_Custom.Checked := True;
  ChangeSize(Sender);
end;

function TResizeToolPanelClass.GetProperties: string;

  function B2S(B: Boolean): string;
  begin
    if B then
      Result := 'true'
    else
      Result := 'false';
  end;
  function I2S(I: Integer): string;
  begin
    Result := IntToStr(I);
  end;

begin
  Result := '';
  Result := Result + 'ResizeTo100x100=' + B2S(RadioButton100x100.Checked) + ';';
  Result := Result + 'ResizeTo200x200=' + B2S(RadioButton200x200.Checked) + ';';
  Result := Result + 'ResizeTo600x800=' + B2S(RadioButton600x800.Checked) + ';';
  Result := Result + 'ResizeToCustom=' + B2S(RadioButton_Custom.Checked) + ';';
  Result := Result + 'SaveProportions=' + B2S(CheckBoxSaveProportions.Checked) + ';';
  Result := Result + 'ResizeToPercent=' + B2S(RadioButtonPercent.Checked) + ';';
  Result := Result + 'ResizeMethod=' + I2S(ComboBoxMethod.ItemIndex) + ';';
  Result := Result + 'CustomWidth=' + I2S(StrToIntDef(WidthEdit.Text, 100)) + ';';
  Result := Result + 'CustomHeight=' + I2S(StrToIntDef(HeightEdit.Text, 100)) + ';';
  Result := Result + 'PercentValue=' + I2S(Round(GetZoom * 100)) + ';';
end;

class function TResizeToolPanelClass.ID: string;
begin
  Result := '{29C59707-04DA-4194-9B53-6E39185CC71E}';
end;

function TResizeToolPanelClass.LangID: string;
begin
  Result := 'ResizeTool';
end;

procedure TResizeToolPanelClass.MakeTransform;
begin
  if NewImage <> nil then
  begin
    ImageHistory.Add(NewImage, '{' + ID + '}[' + GetProperties + ']');
    SetImagePointer(NewImage);
  end;
  ClosePanel;
end;

procedure TResizeToolPanelClass.SetProgress(Progress: Integer; SID: string);
begin
  if SID = FSID then
    (Editor as TImageEditor).FStatusProgress.Position := Progress;
end;

procedure TResizeToolPanelClass.SetThreadImage(Image: TBitmap; SID: string);
begin
  if SID = FSID then
  begin
    Pointer(NewImage) := Pointer(Image);
    SetTempImage(Image);
  end
  else
    F(Image);
  if ApplyOnDone then
  begin
    MakeTransform;
    if Assigned(FOnDone) then
      FOnDone(Self);
  end;
end;

procedure TResizeToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin
  ApplyOnDone := True;
  FOnDone := OnDone;
  Loading := True;
  RadioButton100x100.Checked := GetBoolValueByName(Properties, 'ResizeTo100x100');
  RadioButton200x200.Checked := GetBoolValueByName(Properties, 'ResizeTo200x200');
  RadioButton600x800.Checked := GetBoolValueByName(Properties, 'ResizeTo600x800');
  RadioButton_Custom.Checked := GetBoolValueByName(Properties, 'ResizeToCustom');
  CheckBoxSaveProportions.Checked := GetBoolValueByName(Properties, 'SaveProportions');
  RadioButtonPercent.Checked := GetBoolValueByName(Properties, 'ResizeToPercent');

  ComboBoxMethod.ItemIndex := GetIntValueByName(Properties, 'ResizeMethod');
  WidthEdit.Text := IntToStr(GetIntValueByName(Properties, 'CustomWidth', 100));
  HeightEdit.Text := IntToStr(GetIntValueByName(Properties, 'CustomHeight', 100));
  ComboBoxPercent.Text := GetValueByName(Properties, 'PercentValue');
  Loading := False;
  ApplyOnDone := True;
  ChangeSize(Self);
end;

procedure TResizeToolPanelClass.SetProperties(Properties: String);
begin

end;

end.
