unit ResizeToolUnit;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, ExtCtrls,
  Language, EffectsLanguage, UnitResampleFilters, uDBBaseTypes,
  UnitDBKernel, Effects, uConstants, uEditorTypes, uMemory;

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

uses ImEditor, ResizeToolThreadUnit;

{ TResizeToolPanelClass }

procedure ProportionalSize(AWidth, AHeight: Integer; var AWidthToSize, AHeightToSize: Integer);
begin
  if (AWidthToSize = 0) or (AHeightToSize = 0) then
  begin
    AHeightToSize := 0;
    AWidthToSize := 0;
  end else
  begin
    if (AHeightToSize / AWidthToSize) < (AHeight / AWidth) then
    begin
      AHeightToSize := Round((AWidth / AWidthToSize) * AHeightToSize);
      AWidthToSize := AWidth;
    end else
    begin
      AWidthToSize := Round((AHeight / AHeightToSize) * AWidthToSize);
      AHeightToSize := AHeight;
    end;
  end;
end;

procedure TResizeToolPanelClass.ChangeSize(Sender: TObject);
var
  ImageSizeW, ImageSizeH, w,h : integer;
  Method : TResizeProcedure;

 function GetZoom : real;
 var
   s : string;
   i : integer;
 begin
  s:=ComboBoxPercent.Text;
  if s='' then s:='100';
  for i:=Length(s) downto 1 do
  if not CharInSet(s[i], abs_cifr) then Delete(s,i,1);
  Result:=StrToFloatDef(s,50)/100;
 end;

begin
 if Loading then exit;
 ImageSizeW:=1;
 ImageSizeH:=1;
 if RadioButton100x100.Checked then
 begin
  ImageSizeW:=100;
  ImageSizeH:=100;
 end;
 if RadioButton200x200.Checked then
 begin
  ImageSizeW:=200;
  ImageSizeH:=200;
 end;
 if RadioButton600x800.Checked then
 begin
  ImageSizeW:=800;
  ImageSizeH:=600;
 end;
 if RadioButton_Custom.Checked then
 begin
  ImageSizeW:=StrToIntDef(WidthEdit.Text,100);
  ImageSizeH:=StrToIntDef(HeightEdit.Text,100);
 end;
 w:=Image.Width;
 h:=Image.Height;
 if RadioButtonPercent.Checked then
 begin
  ImageSizeW:=Round(w*GetZoom);
  ImageSizeH:=Round(h*GetZoom);
 end;
 if CheckBoxSaveProportions.Checked then
 begin
  ProportionalSize(ImageSizeW,ImageSizeH,w,h);
 end else
 begin
  w:=ImageSizeW;
  h:=ImageSizeH;
 end;
 if Image=nil then exit;
 NewImage:=TBitmap.Create;
 NewImage.Assign(Image);
 FSID:=IntToStr(Random(10000000));
 Case ComboBoxMethod.ItemIndex of
 0 : Method:=SmoothResize;
 1 : Method:=StretchCool;
 2 : Method:=ThumbnailResize;
 else Method:=nil;
 end;
 TResizeToolThread.Create(Self,Method,ComboBoxMethod.ItemIndex-StFilters-1,False,NewImage,FSID,SetThreadImage,w,h,Editor);
end;

procedure TResizeToolPanelClass.ClosePanel;
begin
 if Assigned(OnClosePanel) then OnClosePanel(self);
 if not ApplyOnDone then
 inherited;
end;

procedure TResizeToolPanelClass.ClosePanelEvent(Sender: TObject);
begin
 CancelTempImage(true);
 ClosePanel;
end;

procedure TResizeToolPanelClass.ComboBoxPercentSelect(Sender: TObject);
begin
 RadioButtonPercent.Checked:=true;
 ChangeSize(Sender);
end;

constructor TResizeToolPanelClass.Create(AOwner: TComponent);
var
 Left, i : integer;
 IcoOK, IcoCancel, IcoSave : TIcon;
const
 PercentCount = 11;
 Percents : array[1..PercentCount] of integer = (500,200,95,75,66,50,33,25,15,10,5);
begin
 inherited;
 ApplyOnDone:=false;
 Loading:=true;
 NewImage:=nil;
 ApplyOnDone:=false;
 Align:=AlClient;
 Left:=8;

 SelectChooseBox := TRadioGroup.Create(nil);
 SelectChooseBox.Top:=3;
 SelectChooseBox.Left:=3;
 SelectChooseBox.Caption:=TEXT_MES_CHANGE_SIZE;
 SelectChooseBox.Parent:=AOwner as TWinControl;
 SelectChooseBox.Width:=180;
 SelectChooseBox.Height:=270;

 RadioButton100x100 := TRadioButton.Create(nil);
 RadioButton100x100.Top:=20;
 RadioButton100x100.Left:=Left;
 RadioButton100x100.Width:=170;
 //TODO:RadioButton100x100.Caption:=TEXT_MES_CHANGE_SIZE_100x100;
 RadioButton100x100.Parent:=AOwner as TWinControl;
 RadioButton100x100.OnClick:=ChangeSize;

 RadioButton200x200 := TRadioButton.Create(nil);
 RadioButton200x200.Top:=RadioButton100x100.Top+RadioButton100x100.Height+5;
 RadioButton200x200.Left:=Left;
 RadioButton200x200.Width:=170;
 //TODO:RadioButton200x200.Caption:=TEXT_MES_CHANGE_SIZE_200x200;
 RadioButton200x200.Parent:=AOwner as TWinControl;
 RadioButton200x200.OnClick:=ChangeSize;

 RadioButton600x800 := TRadioButton.Create(nil);
 RadioButton600x800.Top:=RadioButton200x200.Top+RadioButton200x200.Height+5;
 RadioButton600x800.Left:=Left;
 RadioButton600x800.Width:=170;
 //TODO:RadioButton600x800.Caption:=TEXT_MES_CHANGE_SIZE_600x800;
 RadioButton600x800.Parent:=AOwner as TWinControl;
 RadioButton600x800.OnClick:=ChangeSize;

 RadioButton_Custom := TRadioButton.Create(nil);
 RadioButton_Custom.Top:=RadioButton600x800.Top+RadioButton600x800.Height+5;
 RadioButton_Custom.Left:=Left;
 RadioButton_Custom.Width:=170;
 RadioButton_Custom.Caption:=TEXT_MES_CHANGE_SIZE_CUSTOM;
 RadioButton_Custom.Parent:=AOwner as TWinControl;
 RadioButton_Custom.Checked:=true;
 RadioButton_Custom.OnClick:=ChangeSize;

 WidthEditLabel:=Tlabel.Create(nil);
 WidthEditLabel.Top:=RadioButton_Custom.Top+RadioButton_Custom.Height+5;
 WidthEditLabel.Left:=Left;
 WidthEditLabel.Width:=50;
 WidthEditLabel.Parent:=SelectChooseBox;
 WidthEditLabel.Caption:=TEXT_MES_WIDTH+':';

 HeightEditLabel:=Tlabel.Create(nil);
 HeightEditLabel.Top:=RadioButton_Custom.Top+RadioButton_Custom.Height+5;;
 HeightEditLabel.Left:=85;
 HeightEditLabel.Width:=50;
 HeightEditLabel.Parent:=SelectChooseBox;
 HeightEditLabel.Caption:=TEXT_MES_HEIGHT+':';

 WidthEdit:=TEdit.Create(nil);
 WidthEdit.Top:=WidthEditLabel.Top+WidthEditLabel.Height+5;
 WidthEdit.Left:=Left;
 WidthEdit.Width:=50;
 WidthEdit.Text:='1024';
 WidthEdit.Parent:=AOwner as TWinControl;
 WidthEdit.OnChange:=EditChange;

 HeightEdit:=TEdit.Create(nil);
 HeightEdit.Top:=HeightEditLabel.Top+HeightEditLabel.Height+5;
 HeightEdit.Left:=85;
 HeightEdit.Width:=50;
 HeightEdit.Text:='768';
 HeightEdit.Parent:=AOwner as TWinControl;
 HeightEdit.OnChange:=EditChange;

 CheckBoxSaveProportions := TCheckBox.Create(nil);
 CheckBoxSaveProportions.Top:=WidthEdit.Top+WidthEdit.Height+5;
 CheckBoxSaveProportions.Left:=Left;
 CheckBoxSaveProportions.Width:=150;
 CheckBoxSaveProportions.Caption:=TEXT_MES_SAVE_ASPECT_RATIO;
 CheckBoxSaveProportions.Parent:=AOwner as TWinControl;
 CheckBoxSaveProportions.OnClick:=ChangeSize;
 CheckBoxSaveProportions.Checked:=true;

 RadioButtonPercent := TRadioButton.Create(nil);
 RadioButtonPercent.Top:=CheckBoxSaveProportions.Top+CheckBoxSaveProportions.Height+5;
 RadioButtonPercent.Left:=Left;
 RadioButtonPercent.Width:=170;
 RadioButtonPercent.Caption:=TEXT_MES_IM_USE_ZOOM;
 RadioButtonPercent.Parent:=AOwner as TWinControl;
 RadioButtonPercent.OnClick:=ChangeSize;

 ComboBoxPercent := TComboBox.Create(nil);
 ComboBoxPercent.Top:=RadioButtonPercent.Top+RadioButtonPercent.Height+5;
 ComboBoxPercent.Left:=Left;
 ComboBoxPercent.Width:=170;
 ComboBoxPercent.Parent:=AOwner as TWinControl;
 ComboBoxPercent.OnChange:=ChangeSize;
 ComboBoxPercent.OnSelect:=ComboBoxPercentSelect;
 for i:=1 to PercentCount do
 ComboBoxPercent.Items.Add(IntToStr(Percents[i])+'%');

 MethodLabel:=Tlabel.Create(nil);
 MethodLabel.Top:=ComboBoxPercent.Top+ComboBoxPercent.Height+5;;
 MethodLabel.Left:=8;
 MethodLabel.Width:=50;
 MethodLabel.Parent:=SelectChooseBox;
 MethodLabel.Caption:=TEXT_MES_METHOD+':';

 ComboBoxMethod := TComboBox.Create(nil);
 ComboBoxMethod.Top:=MethodLabel.Top+MethodLabel.Height+5;
 ComboBoxMethod.Left:=8;
 ComboBoxMethod.Width:=170;
 ComboBoxMethod.Parent:=AOwner as TWinControl;
 ComboBoxMethod.OnChange:=ChangeSize;
 ComboBoxMethod.Style:=csDropDownList;
 ComboBoxMethod.Items.Add(TEXT_MES_SMOOTH_METHOD);
 ComboBoxMethod.Items.Add(TEXT_MES_BASE_METHOD);
 ComboBoxMethod.Items.Add(TEXT_MES_SHARPNESS_SMOOTH_METHOD);
 for i:=0 to 6 do
 ComboBoxMethod.Items.Add(ResampleFilters[i].Name);

 ComboBoxMethod.ItemIndex:=0;

 IcoOK:=TIcon.Create;
 IcoCancel:=TIcon.Create;
 IcoOK.Handle:=LoadIcon(DBKernel.IconDllInstance,'DOIT');
 IcoCancel.Handle:=LoadIcon(DBKernel.IconDllInstance,'CANCELACTION');

 IcoSave:=TIcon.Create;
 IcoSave.Handle:=LoadIcon(DBKernel.IconDllInstance,'SAVETOFILE');

 SaveSettingsLink := TWebLink.Create(nil);
 SaveSettingsLink.Parent:=AOwner as TWinControl;
 SaveSettingsLink.Text:=TEXT_MES_SAVE_SETTINGS;
 SaveSettingsLink.Top:=SelectChooseBox.Top+SelectChooseBox.Height+10;
 SaveSettingsLink.Left:=10;
 SaveSettingsLink.Visible:=true;
 SaveSettingsLink.Color:=ClBtnface;
 SaveSettingsLink.OnClick:=DoSaveSettings;
 SaveSettingsLink.Icon:=IcoSave;
 SaveSettingsLink.ImageCanRegenerate:=True;
 IcoSave.free;

 MakeItLink := TWebLink.Create(nil);
 MakeItLink.Parent:=AOwner as TWinControl;
 MakeItLink.Text:=TEXT_MES_IM_APPLY;
 MakeItLink.Top:=SaveSettingsLink.Top+SaveSettingsLink.Height+5;
 MakeItLink.Left:=10;
 MakeItLink.Visible:=true;
 MakeItLink.Color:=ClBtnface;
 MakeItLink.OnClick:=DoMakeImage;
 MakeItLink.Icon:=IcoOK;
 MakeItLink.ImageCanRegenerate:=True;
 IcoOK.Free;

 CloseLink := TWebLink.Create(nil);
 CloseLink.Parent:=AOwner as TWinControl;
 CloseLink.Text:=TEXT_MES_IM_CLOSE_TOOL_PANEL;
 CloseLink.Top:=MakeItLink.Top+MakeItLink.Height+5;
 CloseLink.Left:=10;
 CloseLink.Visible:=true;
 CloseLink.Color:=ClBtnface;
 CloseLink.OnClick:=ClosePanelEvent;
 CloseLink.Icon:=IcoCancel;
 CloseLink.ImageCanRegenerate:=True;
 IcoCancel.Free;


 ComboBoxPercent.Text:=IntToStr(DBKernel.ReadInteger('Editor','PercentValue',100))+'%';
 WidthEdit.Text:=IntToStr(DBKernel.ReadInteger('Editor','CustomWidth',100));
 HeightEdit.Text:=IntToStr(DBKernel.ReadInteger('Editor','CustomHeight',100));
 RadioButton100x100.Checked:=DBKernel.ReadBool('Editor','ResizeTo100x100',false);
 RadioButton200x200.Checked:=DBKernel.ReadBool('Editor','ResizeTo200x200',false);
 RadioButton600x800.Checked:=DBKernel.ReadBool('Editor','ResizeTo600x800',true);
 RadioButton_Custom.Checked:=DBKernel.ReadBool('Editor','ResizeToCustom',false);
 CheckBoxSaveProportions.Checked:=DBKernel.ReadBool('Editor','SaveProportions',true);
 RadioButtonPercent.Checked:=DBKernel.ReadBool('Editor','ResizeToPercent',false);
 ComboBoxMethod.ItemIndex:=DBKernel.ReadInteger('Editor','ResizeMethod',0);
 Loading:=false;
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
  DBKernel.WriteBool('Editor', 'ResizeTo100x100', RadioButton100x100.Checked);
  DBKernel.WriteBool('Editor', 'ResizeTo200x200', RadioButton200x200.Checked);
  DBKernel.WriteBool('Editor', 'ResizeTo600x800', RadioButton600x800.Checked);
  DBKernel.WriteBool('Editor', 'ResizeToCustom', RadioButton_Custom.Checked);
  DBKernel.WriteBool('Editor', 'SaveProportions', CheckBoxSaveProportions.Checked);
  DBKernel.WriteBool('Editor', 'ResizeToPercent', RadioButtonPercent.Checked);
  DBKernel.WriteInteger('Editor', 'ResizeMethod', ComboBoxMethod.ItemIndex);
  DBKernel.WriteInteger('Editor', 'CustomWidth', StrToIntDef(WidthEdit.Text, 100));
  DBKernel.WriteInteger('Editor', 'CustomHeight', StrToIntDef(HeightEdit.Text, 100));
  DBKernel.WriteInteger('Editor','PercentValue',Round(GetZoom*100));
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
  //
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
