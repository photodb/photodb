unit UnitSizeResizerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ExtCtrls, Math, UVistaFuncs,
  JPEG, GIFImage, GraphicEx, UnitDBkernel, GraphicCrypt, uAssociations,
  AcDlgSelect, TiffImageUnit, UnitDBDeclare, UnitDBFileDialogs, uFileUtils,
  UnitDBCommon, UnitDBCommonGraphics, ComCtrls, ImgList, uDBForm, LoadingSign,
  DmProgress, uW7TaskBar, PngImage, uWatermarkOptions, uImageSource,
  UnitPropeccedFilesSupport, uThreadForm, uMemory, uFormListView, uSettings,
  uDBPopupMenuInfo, uConstants, uShellIntegration, uRuntime, ImButton, uLogger,
  WebLink, SaveWindowPos;

const
  Settings_ConvertForm = 'Convert settings';

type
  TFormSizeResizer = class(TThreadForm)
    BtOk: TButton;
    BtCancel: TButton;
    BtSaveAsDefault: TButton;
    LbInfo: TLabel;
    EdImageName: TEdit;
    ImlWatermarkPatterns: TImageList;
    LsMain: TLoadingSign;
    PrbMain: TDmProgress;
    PnOptions: TPanel;
    CbWatermark: TCheckBox;
    CbConvert: TCheckBox;
    DdConvert: TComboBox;
    BtJPEGOptions: TButton;
    DdRotate: TComboBox;
    CbRotate: TCheckBox;
    CbResize: TCheckBox;
    DdResizeAction: TComboBox;
    EdWidth: TEdit;
    LbSizeSeparator: TLabel;
    EdHeight: TEdit;
    CbAspectRatio: TCheckBox;
    CbAddSuffix: TCheckBox;
    EdSavePath: TEdit;
    BtChangeDirectory: TButton;
    BtWatermarkOptions: TButton;
    TmrPreview: TTimer;
    WlBack: TWebLink;
    WlNext: TWebLink;
    PbImage: TPaintBox;
    SwpMain: TSaveWindowPos;
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtJPEGOptionsClick(Sender: TObject);
    procedure BtOkClick(Sender: TObject);
    procedure BtSaveAsDefaultClick(Sender: TObject);
    procedure EdWidthExit(Sender: TObject);
    procedure EdHeightKeyPress(Sender: TObject; var Key: Char);
    procedure BtChangeDirectoryClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CbConvertClick(Sender: TObject);
    procedure CbRotateClick(Sender: TObject);
    procedure CbResizeClick(Sender: TObject);
    procedure DdResizeActionChange(Sender: TObject);
    procedure DdConvertChange(Sender: TObject);
    procedure CbWatermarkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtWatermarkOptionsClick(Sender: TObject);
    procedure DdRotateClick(Sender: TObject);
    procedure DdRotateChange(Sender: TObject);
    procedure CbAspectRatioClick(Sender: TObject);
    procedure TmrPreviewTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure EdImageNameEnter(Sender: TObject);
    procedure WlBackClick(Sender: TObject);
    procedure WlNextClick(Sender: TObject);
    procedure PbImagePaint(Sender: TObject);
    procedure PbImageContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    FData: TDBPopupMenuInfo;
    FW7TaskBar: ITaskbarList3;
    FDataCount: Integer;
    FProcessingParams: TProcessingParams;
    FPreviewImage: TBitmap;
    Fowner: TDBForm;
    FIgnoreInput: Boolean;
    FCreatingResize: Boolean;
    FCurrentPreviewPosition: Integer;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FProcessingList: TStrings;
    procedure LoadLanguage;
    procedure CheckValidForm;
  protected
    function GetFormID: string; override;
    procedure FillProcessingParams;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReadSettings;
    procedure UpdateNavigation;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure SetInfo(Owner: TDBForm; List: TDBPopupMenuInfo);
    procedure ThreadEnd(Data: TDBPopupMenuInfoRecord; EndProcessing: Boolean);
    procedure GeneratePreview;
    procedure UpdatePreview(PreviewImage: TBitmap; FileName: string; RealWidth, RealHeight: Integer);
    procedure DefaultResize;
    procedure DefaultConvert;
    procedure DefaultExport;
    procedure DefaultRotate(RotateValue : Integer; StartImmediately : Boolean);
  end;

const
  ConvertImageID = 'ConvertImage';

procedure ExportImages(Owner: TDBForm; List: TDBPopupMenuInfo);
procedure ResizeImages(Owner: TDBForm; List: TDBPopupMenuInfo);
procedure ConvertImages(Owner: TDBForm; List: TDBPopupMenuInfo);
procedure RotateImages(Owner: TDBForm; List: TDBPopupMenuInfo; BeginRotate : Integer; StartImmediately : Boolean);

implementation

uses UnitJPEGOptions, UImageConvertThread, FormManegerUnit, DBCMenu;

{$R *.dfm}

procedure ResizeImages(Owner: TDBForm; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultResize;
  FormSizeResizer.Show;
end;

procedure ConvertImages(Owner: TDBForm; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultConvert;
  FormSizeResizer.Show;
end;

procedure ExportImages(Owner: TDBForm; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultExport;
  FormSizeResizer.Show;
end;

procedure RotateImages(Owner: TDBForm; List: TDBPopupMenuInfo; BeginRotate : Integer; StartImmediately : Boolean);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultRotate(BeginRotate, StartImmediately);
  if not StartImmediately then
    FormSizeResizer.Show
end;

procedure TFormSizeResizer.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSizeResizer.FillProcessingParams;
const
  Rotations: array [-1 .. 3] of Integer = (DB_IMAGE_ROTATE_UNKNOWN, DB_IMAGE_ROTATE_EXIF, DB_IMAGE_ROTATE_270,
    DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_180);

  function GeneratePreffix: string;
  begin
    Result := '_' + L('processed');
    if CbResize.Checked then
      Result := '_' + AnsiLowerCase(StringReplace(DdResizeAction.Text, ' ', '_', [rfReplaceAll]));
  end;

begin

  FProcessingParams.Rotate := CbRotate.Checked;
  FProcessingParams.Rotation := Rotations[DdRotate.ItemIndex];
  if DdConvert.ItemIndex = -1 then
    FProcessingParams.GraphicClass := nil
  else
    FProcessingParams.GraphicClass := TGraphicClass(DdConvert.Items.Objects[DdConvert.ItemIndex]);

  FProcessingParams.Resize := CbResize.Checked;
  FProcessingParams.ResizeToSize := (DdResizeAction.ItemIndex in [0 .. 4]) or
    (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  if (FProcessingParams.ResizeToSize) then
  begin
    case DdResizeAction.ItemIndex of
      0:
        begin
          FProcessingParams.Width := 1024;
          FProcessingParams.Height := 768;
        end;
      1:
        begin
          FProcessingParams.Width := 800;
          FProcessingParams.Height := 600;
        end;
      2:
        begin
          FProcessingParams.Width := 640;
          FProcessingParams.Height := 480;
        end;
      3:
        begin
          FProcessingParams.Width := 320;
          FProcessingParams.Height := 240;
        end;
      4:
        begin
          FProcessingParams.Width := 128;
          FProcessingParams.Height := 124;
        end;
    else
      FProcessingParams.Width := Min(Max(StrToIntDef(EdWidth.Text, 100), 5), 5000);
      FProcessingParams.Height := Min(Max(StrToIntDef(EdHeight.Text, 100), 5), 5000);
    end;
  end else
  begin
    FProcessingParams.PercentResize := 100;
    case DdResizeAction.ItemIndex - 5 of
      0:
        FProcessingParams.PercentResize := 25;
      1:
        FProcessingParams.PercentResize := 50;
      2:
        FProcessingParams.PercentResize := 75;
      3:
        FProcessingParams.PercentResize := 150;
      4:
        FProcessingParams.PercentResize := 200;
      5:
        FProcessingParams.PercentResize := 400;
    end;
  end;

  FProcessingParams.AddWatermark := CbWatermark.Checked;
  if CbWatermark.Checked then
  begin
    FProcessingParams.WatermarkOptions.Text := Settings.ReadString(Settings_Watermark, 'Text', L('Sample text'));
    FProcessingParams.WatermarkOptions.Color := Settings.ReadInteger(Settings_Watermark, 'Color', clWhite);
    FProcessingParams.WatermarkOptions.Transparenty := Settings.ReadInteger(Settings_Watermark, 'Transparency', 25);
    FProcessingParams.WatermarkOptions.BlockCountX := Settings.ReadInteger(Settings_Watermark, 'BlocksX', 3);
    FProcessingParams.WatermarkOptions.BlockCountY := Settings.ReadInteger(Settings_Watermark, 'BlocksY', 3);
    FProcessingParams.WatermarkOptions.FontName := Settings.ReadString(Settings_Watermark, 'Font', 'Arial');
  end;

  FProcessingParams.SaveAspectRation := CbAspectRatio.Checked;
  if CbAddSuffix.Checked then
    FProcessingParams.Preffix := GeneratePreffix
  else
    FProcessingParams.Preffix := '';

  FProcessingParams.WorkDirectory := EdSavePath.Text;
end;

procedure TFormSizeResizer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TFormSizeResizer.FormCreate(Sender: TObject);
var
  I: Integer;
  Description, Mask: string;
  Ext : TFileAssociation;
begin
  FCreatingResize := True;
  FIgnoreInput := False;
  FPreviewImage := nil;
  DoubleBuffered := True;
  FormManager.RegisterMainForm(Self);
  LoadLanguage;
  FData := TDBPopupMenuInfo.Create;
  FProcessingList := TStringList.Create;
  FCurrentPreviewPosition := 0;

  for I := 0 to TFileAssociations.Instance.Count - 1 do
  begin
    Ext := TFileAssociations.Instance[I];
    if Ext.CanSave then
    begin
      Description := Ext.Description;
      Mask := '*' + Ext.Extension;

      DdConvert.Items.AddObject(Description + '  (' + Mask + ')', TObject(Ext.GraphicClass));
    end;
  end;
  DdConvert.ItemIndex := 0;
  DdRotate.ItemIndex := 0;
  DdResizeAction.ItemIndex := 0;
  ReadSettings;
  SetStretchBltMode(PbImage.Canvas.Handle, STRETCH_HALFTONE);
  FRealWidth := 0;
  FRealHeight := 0;

  FW7TaskBar := CreateTaskBarInstance;

  SwpMain.Key := RegRoot + 'ConvertForm';
  SwpMain.SetPosition;
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
begin
  if FProcessingList.Count > 0 then
  begin
    for I := 0 to FProcessingList.Count - 1 do
      ProcessedFilesCollection.RemoveFile(FProcessingList[I]);
    DBKernel.DoIDEvent(Self, 0, [EventID_Repaint_ImageList], EventInfo);
  end;
  F(FData);
  F(FPreviewImage);
  FormManager.UnRegisterMainForm(Self);
  SwpMain.SavePosition;
end;

procedure TFormSizeResizer.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
  if Key = VK_RETURN then
    BtOkClick(Sender);
end;

procedure TFormSizeResizer.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if PrbMain.Visible then
    Exit;
  if PtInRect(PbImage.BoundsRect, Self.ScreenToClient(Mouse.Cursorpos)) then
  begin
    if WheelDelta < 0 then
      WlNextClick(Self)
    else
      WlBackClick(Self);
    Handled := True;
  end;
end;

procedure TFormSizeResizer.FormResize(Sender: TObject);
begin
  if FCreatingResize then
  begin
    FCreatingResize := False;
    Exit;
  end;
  GeneratePreview;
end;

procedure TFormSizeResizer.GeneratePreview;
begin
  if not FIgnoreInput then
  begin
    TmrPreview.Enabled := False;
    TmrPreview.Interval := 200;
    TmrPreview.Enabled := True;
  end;
end;

function TFormSizeResizer.GetFormID: string;
begin
  Result := ConvertImageID;
end;

procedure TFormSizeResizer.BtJPEGOptionsClick(Sender: TObject);
begin
  SetJPEGOptions(ConvertImageID);
end;

procedure TFormSizeResizer.BtOkClick(Sender: TObject);
var
  I: Integer;

  function CheckFileTypes: Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to FData.Count - 1 do
      Result := Result and TFileAssociations.Instance.IsConvertableExt(ExtractFileExt(FData[I].FileName));

  end;

begin

  if not CheckFileTypes and (DdConvert.ItemIndex < 0) then
  begin
    MessageBoxDB(Handle, L('Please, choose format!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  CreateDirA(EdSavePath.Text);
  if not DirectoryExistsSafe(EdSavePath.Text) then
  begin
    MessageBoxDB(Handle, L('Please, choose a valid directory!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  for I := 0 to FData.Count - 1 do
  begin
    ProcessedFilesCollection.AddFile(FData[I].FileName);
    FProcessingList.Add(AnsiLOwerCase(FData[I].FileName));
  end;

  // change form state
  PnOptions.Hide;
  BtSaveAsDefault.Hide;
  BtOk.Hide;
  PrbMain.Top := BtCancel.Top - BtCancel.Height - 5;
  PrbMain.Show;
  EdImageName.Top := PrbMain.Top - EdImageName.Height - 5;
  WlNext.Enabled := False;
  WlBack.Enabled := False;
  WlNext.Top := EdImageName.Top - 2;
  WlBack.Top := EdImageName.Top - 2;
  PbImage.Height := EdImageName.Top - 5 - PbImage.Top;

  BtCancel.Left := PrbMain.Left + PrbMain.Width - BtCancel.Width;
  ClientHeight := ClientHeight - PnOptions.Height - 5;

  // init progress
  LsMain.Show;
  FDataCount := FData.Count;
  if FW7TaskBar <> nil then
  begin
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);
  end;
  PrbMain.MaxValue := FDataCount;

  // fill params of processing
  FillProcessingParams;

  NewFormState;
  FProcessingParams.PreviewOptions.GeneratePreview := False;
  for I := 1 to Min(FData.Count, ProcessorCount) do
    TImageConvertThread.Create(Self, StateID, FData.Extract(0), FProcessingParams);
end;

procedure TFormSizeResizer.SetInfo(Owner: TDBForm; List: TDBPopupMenuInfo);
var
  I: Integer;
  FWidth, FHeight: Integer;
begin
  FOwner := Owner;

  for I := 0 to List.Count - 1 do
    if List[I].Selected then
    begin
      FData.Add(List[I].Copy);
      if List[I].IsCurrent then
        FData.Position := FData.Count - 1;
    end;

  FCurrentPreviewPosition := FData.Position;
  if FData.Count > 0 then
  begin
    EdSavePath.Text := ExtractFileDir(FData[FCurrentPreviewPosition].FileName);
    EdImageName.Text := ExtractFileName(FData[FCurrentPreviewPosition].FileName);
  end;

  UpdateNavigation;
  if (FPreviewImage = nil) then
  begin
    FPreviewImage := TBitmap.Create;
    if TFormCollection.Instance.GetImage(FOwner, FData[FCurrentPreviewPosition].FileName, FPreviewImage, FWidth, FHeight) then
    begin
      FRealWidth := FWidth;
      FRealHeight := FHeight;
      PbImage.Repaint;
    end else
      F(FPreviewImage);

  end;
  GeneratePreview;
end;

procedure TFormSizeResizer.ThreadEnd(Data: TDBPopupMenuInfoRecord; EndProcessing: Boolean);
var
  I: Integer;
begin
  PrbMain.Position := FDataCount - FData.Count;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);

  I := FProcessingList.IndexOf(AnsiLowerCase(Data.FileName));
  if I > -1 then
    FProcessingList.Delete(I);
  FillProcessingParams;
  if (FData.Count > 0) and not EndProcessing then
    TImageConvertThread.Create(Self, StateID, FData.Extract(0), FProcessingParams)
  else
    Close;
end;

procedure TFormSizeResizer.TmrPreviewTimer(Sender: TObject);
var
  R: TRect;
  FWidth, FHeight: Integer;
begin
  TmrPreview.Enabled := False;
  if PrbMain.Visible then
    Exit;

  FillProcessingParams;
  NewFormState;

  R := Rect(5, LbInfo.Top + LbInfo.Height + 5, ClientWidth - 5, PrbMain.Top - 5);

  FProcessingParams.PreviewOptions.GeneratePreview := True;
  FProcessingParams.PreviewOptions.PreviewWidth := R.Right - R.Left;
  FProcessingParams.PreviewOptions.PreviewHeight := R.Bottom - R.Top;
  TImageConvertThread.Create(Self, StateID, FData[FCurrentPreviewPosition].Copy, FProcessingParams);
  LsMain.Show;

  if (FPreviewImage = nil) then
  begin
    FPreviewImage := TBitmap.Create;
    if TFormCollection.Instance.GetImage(FOwner, FData[FCurrentPreviewPosition].FileName, FPreviewImage, FWidth, FHeight) then
    begin
      FRealWidth := FWidth;
      FRealHeight := FHeight;
      PbImage.Repaint;
    end else
      F(FPreviewImage);

  end;
end;

procedure TFormSizeResizer.UpdateNavigation;
begin
  WlBack.Enabled := FCurrentPreviewPosition > 0;
  WlNext.Enabled := FCurrentPreviewPosition < FData.Count - 1;
end;

procedure TFormSizeResizer.UpdatePreview(PreviewImage: TBitmap; FileName: string; RealWidth, RealHeight: Integer);
begin
  LsMain.Hide;
  FRealWidth := RealWidth;
  FRealHeight := RealHeight;
  EdImageName.Text := ExtractFileName(FileName);
  F(FPreviewImage);
  FPreviewImage := PreviewImage;
  PbImage.Refresh;
end;

procedure TFormSizeResizer.WlBackClick(Sender: TObject);
begin
  if not WlBack.Enabled then
    Exit;
  Dec(FCurrentPreviewPosition);
  UpdateNavigation;
  if Sender = WlBack then
    TmrPreviewTimer(Sender)
  else
  begin
    TmrPreview.Enabled := False;
    TmrPreview.Interval := 100;
    TmrPreview.Enabled := True;
    LsMain.Show;
  end;
end;

procedure TFormSizeResizer.WlNextClick(Sender: TObject);
begin
  if not WlNext.Enabled then
    Exit;
  Inc(FCurrentPreviewPosition);
  UpdateNavigation;
  if Sender = WlNext then
    TmrPreviewTimer(Sender)
  else
  begin
    TmrPreview.Enabled := False;
    TmrPreview.Interval := 100;
    TmrPreview.Enabled := True;
    LsMain.Show;
  end;
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  Settings.WriteInteger(Settings_ConvertForm, 'Convert', DdConvert.ItemIndex);
  Settings.WriteInteger(Settings_ConvertForm, 'Rotate', DdRotate.ItemIndex);
  Settings.WriteInteger(Settings_ConvertForm, 'Resize', DdResizeAction.ItemIndex);
  Settings.WriteString(Settings_ConvertForm, 'ResizeW', EdWidth.Text);
  Settings.WriteString(Settings_ConvertForm, 'ResizeH', Edheight.Text);
  Settings.WriteBool(Settings_ConvertForm, 'SaveAspectRatio', CbAspectRatio.Checked);
  Settings.WriteBool(Settings_ConvertForm, 'AddSuffix', CbAddSuffix.Checked);
end;

procedure TFormSizeResizer.BtWatermarkOptionsClick(Sender: TObject);
begin
  ShowWatermarkOptions;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbAspectRatioClick(Sender: TObject);
begin
  CheckValidForm;
end;

procedure TFormSizeResizer.CbConvertClick(Sender: TObject);
begin
  DdConvert.Enabled := CbConvert.Checked;
  DdConvertChange(Sender);
  CheckValidForm;
end;

procedure TFormSizeResizer.CbResizeClick(Sender: TObject);
begin
  DdResizeAction.Enabled := CbResize.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbRotateClick(Sender: TObject);
begin
  DdRotate.Enabled := CbRotate.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CbWatermarkClick(Sender: TObject);
begin
  BtWatermarkOptions.Enabled := CbWatermark.Checked;
  CheckValidForm;
end;

procedure TFormSizeResizer.CheckValidForm;
var
  Valid: Boolean;
begin
  Valid := CbConvert.Checked or CbResize.Checked or CbRotate.Checked or CbWatermark.Checked;
  GeneratePreview;
  BtOk.Enabled := Valid;
  BtSaveAsDefault.Enabled := Valid;
end;

procedure TFormSizeResizer.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormSizeResizer.DdConvertChange(Sender: TObject);
begin
  BtJPEGOptions.Enabled := DdConvert.Enabled and (DdConvert.ItemIndex = 0);
  CheckValidForm;
end;

procedure TFormSizeResizer.DdResizeActionChange(Sender: TObject);
begin
  EdWidth.Enabled := DdResizeAction.Enabled and (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  EdHeight.Enabled := EdWidth.Enabled;
  LbSizeSeparator.Enabled := EdWidth.Enabled;
  CheckValidForm;
end;

procedure TFormSizeResizer.DdRotateChange(Sender: TObject);
begin
  CheckValidForm;
end;

procedure TFormSizeResizer.DdRotateClick(Sender: TObject);
begin
  CheckValidForm;
end;

procedure TFormSizeResizer.DefaultConvert;
begin
  FIgnoreInput := True;
  CbConvert.Checked := True;
  FIgnoreInput := False;
  TmrPreviewTimer(Self);
end;

procedure TFormSizeResizer.DefaultExport;
begin
  FIgnoreInput := True;
  CbWatermark.Checked := True;
  CbResize.Checked := True;
  DdResizeAction.ItemIndex := 1;
  CbRotate.Checked := True;
  DdRotate.ItemIndex := 0;
  FIgnoreInput := False;
  TmrPreviewTimer(Self);
end;

procedure TFormSizeResizer.DefaultResize;
begin
  FIgnoreInput := True;
  CbResize.Checked := True;
  FIgnoreInput := False;
  TmrPreviewTimer(Self);
end;

procedure TFormSizeResizer.DefaultRotate(RotateValue : Integer; StartImmediately : Boolean);
var
  I : Integer;
begin
  FIgnoreInput := True;
  CbRotate.Checked := True;
  CbAddSuffix.Checked := not StartImmediately;
  for I := 0 to DdRotate.Items.Count - 1 do
    if DdRotate.Items.Objects[I] = Pointer(RotateValue) then
    begin
      DdRotate.ItemIndex := I;
      Break;
    end;
  FIgnoreInput := False;
  if StartImmediately then
    BtOkClick(Self)
  else
    TmrPreviewTimer(Self);
end;

destructor TFormSizeResizer.Destroy;
begin
  F(FData);
  F(FProcessingList);
  inherited;
end;

procedure TFormSizeResizer.EdWidthExit(Sender: TObject);
begin
  (Sender as TEdit).Text := IntToStr(Min(Max(StrToIntDef((Sender as TEdit).Text, 100), 5), 5000));
  CheckValidForm;
end;

/// <summary>
/// LoadLanguage
/// </summary>
procedure TFormSizeResizer.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Change Image');
    LbInfo.Caption := L(
      'You can change image size, convert image to another format, rotate image and add custom watermark.');

    CbWatermark.Caption := L('Add Watermark');
    BtWatermarkOptions.Caption := L('Watermark Options');
    CbConvert.Caption := L('Convert');

    CbResize.Caption := L('Resize');
    DdResizeAction.Items.Add(L('Big (1024x768)'));
    DdResizeAction.Items.Add(L('Medium (800x600)'));
    DdResizeAction.Items.Add(L('Small (640x480)'));
    DdResizeAction.Items.Add(L('Pocket PC (240õ320)'));
    DdResizeAction.Items.Add(L('Thumbnails (128x124)'));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [25]));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [50]));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [75]));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [150]));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [200]));
    DdResizeAction.Items.Add(Format(L('Size: %d%%'), [400]));
    DdResizeAction.Items.Add(L('Custom size:'));

    CbRotate.Caption := L('Rotate');
    DdRotate.Items.AddObject(L('By EXIF'), Pointer(DB_IMAGE_ROTATE_EXIF));
    DdRotate.Items.AddObject(L('Left'), Pointer(DB_IMAGE_ROTATE_270));
    DdRotate.Items.AddObject(L('Right'), Pointer(DB_IMAGE_ROTATE_90));
    DdRotate.Items.AddObject(L('180 grad'), Pointer(DB_IMAGE_ROTATE_180));

    CbAspectRatio.Caption := L('Save aspect ratio');
    CbAddSuffix.Caption := L('Add filename suffix');
    BtJPEGOptions.Caption := L('JPEG Options');
    BtSaveAsDefault.Caption := L('Save settings by default');

    PrbMain.Text := L('Processing... (&%%)');

    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

procedure TFormSizeResizer.PbImageContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TDBPopupMenuInfo;
  I: Integer;
begin
  if PrbMain.Visible then
    Exit;
  Info := TDBPopupMenuInfo.Create;
  try
    Info.Assign(FData);
    Info.Position := FCurrentPreviewPosition;
    for I := 0 to Info.Count - 1 do
      Info[I].Selected := I = FCurrentPreviewPosition;

    Info.AttrExists := False;
    TDBPopupMenu.Instance.Execute(Self, PbImage.ClientToScreen(MousePos).X, PbImage.ClientToScreen(MousePos).Y, Info);
  finally
    F(Info);
  end;
end;

procedure TFormSizeResizer.PbImagePaint(Sender: TObject);
var
  R: TRect;
  DisplayImage, ShadowImage: TBitmap;
  W, H, X, Y, Width, Height : Integer;
begin
  if (FPreviewImage <> nil) and (FRealWidth + FRealHeight > 0) then
  begin
    R := Rect(0, 0, PbImage.Width, PbImage.Height);
    W := R.Right - R.Left - 3;
    H := R.Bottom - R.Top - 3;
    Width := FPreviewImage.Width;
    Height := FPreviewImage.Height;
    ProportionalSizeA(W, H, Width, Height);
    ProportionalSize(FRealWidth, FRealHeight, Width, Height);
    X := R.Left + W div 2 - Width div 2;
    Y := R.Top + H div 2 - Height div 2;
    R := Rect(X, Y, X + Width, Y + Height);

    DisplayImage := TBitmap.Create;
    ShadowImage := TBitmap.Create;
    try
      ShadowImage.PixelFormat := pf32Bit;
      DisplayImage.PixelFormat := pf24Bit;
      DrawShadowToImage(ShadowImage, FPreviewImage);
      DisplayImage.SetSize(ShadowImage.Width, ShadowImage.Height);
      LoadBMPImage32bit(ShadowImage, DisplayImage, clBtnFace);
      PbImage.Canvas.StretchDraw(R, DisplayImage);
    finally
      F(DisplayImage);
      F(ShadowImage);
    end;
  end;
end;

procedure TFormSizeResizer.ReadSettings;
begin
  try
    DdConvert.ItemIndex := Settings.ReadInteger(Settings_ConvertForm, 'Convert', 0);
    DdRotate.ItemIndex := Settings.ReadInteger(Settings_ConvertForm, 'Rotate', 0);

    EdWidth.Text := IntToStr(Settings.ReadInteger(Settings_ConvertForm, 'ResizeW', 1024));
    EdHeight.Text := IntToStr(Settings.ReadInteger(Settings_ConvertForm, 'ResizeH', 768));
    DdResizeAction.ItemIndex := Settings.ReadInteger(Settings_ConvertForm, 'Resize', 0);

    CbAspectRatio.Checked := Settings.ReadBool(Settings_ConvertForm, 'SaveAspectRatio', True);
    CbAddSuffix.Checked := Settings.ReadBool(Settings_ConvertForm, 'AddSuffix', True);
  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TFormSizeResizer.EdHeightKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0' .. '9']) then
    Key := #0;
end;

procedure TFormSizeResizer.EdImageNameEnter(Sender: TObject);
begin
  DefocusControl(TWinControl(Sender), True);
end;

procedure TFormSizeResizer.BtChangeDirectoryClick(Sender: TObject);
var
  Directory: string;
begin
  Directory := UnitDBFileDialogs.DBSelectDir(Handle, L('Select folder for processed images'),
    UseSimpleSelectFolderDialog);
  if DirectoryExists(Directory) then
    EdSavePath.Text := Directory;
end;

end.
