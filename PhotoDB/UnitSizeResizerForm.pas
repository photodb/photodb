unit UnitSizeResizerForm;

interface

uses
  Windows,
  Messages,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.Themes,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Imaging.JPEG,

  UnitDBDeclare,
  UnitDBFileDialogs,
  UnitPropeccedFilesSupport,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.DmProgress,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.SaveWindowPos,
  Dmitry.Controls.PathEditor,
  Dmitry.Controls.ImButton,

  uBitmapUtils,
  uDBForm,
  uW7TaskBar,
  uWatermarkOptions,
  uAssociations,
  uThreadForm,
  uMemory,
  uSettings,
  uConstants,
  uShellIntegration,
  uRuntime,
  uResources,
  uLogger,
  uDBThread,
  uDBContext,
  uDBEntities,
  uDBManager,
  uPortableDeviceUtils,
  uThemesUtils,
  uProgramStatInfo,
  uFormInterfaces,
  uCollectionEvents;

const
  Settings_ConvertForm = 'Convert settings';

type
  TFormSizeResizer = class(TThreadForm, IBatchProcessingForm)
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
    BtChangeDirectory: TButton;
    BtWatermarkOptions: TButton;
    TmrPreview: TTimer;
    WlBack: TWebLink;
    WlNext: TWebLink;
    PbImage: TPaintBox;
    SwpMain: TSaveWindowPos;
    AeMain: TApplicationEvents;
    PeSavePath: TPathEditor;
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
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
    FContext: IDBContext;
    FData: TMediaItemCollection;
    FW7TaskBar: ITaskbarList3;
    FDataCount: Integer;
    FProcessingParams: TProcessingParams;
    FPreviewImage: TBitmap;
    FOwner: TDBForm;
    FIgnoreInput: Boolean;
    FCreatingResize: Boolean;
    FCurrentPreviewPosition: Integer;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FProcessingList: TStrings;
    FPreviewAvalable: Boolean;
    FThreadCount: Integer;
    procedure LoadLanguage;
    procedure CheckValidForm;
    procedure GeneratePreview;
    procedure DefaultResize;
    procedure DefaultConvert;
    procedure DefaultExport;
    procedure DoDefaultRotate(RotateValue: Integer; StartImmediately: Boolean);
    procedure SetInfo(Owner: TDBForm; List: TMediaItemCollection);
  protected
    function GetFormID: string; override;
    procedure FillProcessingParams;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ReadSettings;
    procedure UpdateNavigation;
    procedure WndProc(var Message: TMessage); override;
    procedure CustomFormAfterDisplay; override;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure ThreadEnd(Data: TMediaItem; EndProcessing: Boolean);
    procedure UpdatePreview(PreviewImage: TBitmap; FileName: string; RealWidth, RealHeight: Integer);

    //IBatchProcessingForm
    procedure ExportImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure ResizeImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure ConvertImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure RotateImages(Owner: TDBForm; List: TMediaItemCollection; DefaultRotate: Integer; StartImmediately: Boolean);
  end;

const
  ConvertImageID = 'ConvertImage';

implementation

uses
  uImageConvertThread,
  FormManegerUnit,
  DBCMenu;

{$R *.dfm}

procedure TFormSizeResizer.ConvertImages(Owner: TDBForm; List: TMediaItemCollection);
begin
  SetInfo(Owner, List);
  DefaultConvert;
  Show;
end;

procedure TFormSizeResizer.ExportImages(Owner: TDBForm; List: TMediaItemCollection);
begin
  SetInfo(Owner, List);
  DefaultExport;
  Show;
end;

procedure TFormSizeResizer.ResizeImages(Owner: TDBForm; List: TMediaItemCollection);
begin
  SetInfo(Owner, List);
  DefaultResize;
  Show;
end;

procedure TFormSizeResizer.RotateImages(Owner: TDBForm; List: TMediaItemCollection;
  DefaultRotate: Integer; StartImmediately: Boolean);
begin
  SetInfo(Owner, List);
  DoDefaultRotate(DefaultRotate, StartImmediately);
  if not StartImmediately then
    Show;
end;

procedure TFormSizeResizer.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
var
  P: TPoint;
begin
  if not Active then
    Exit;

  if Msg.message = WM_MOUSEWHEEL then
  begin
    if PrbMain.Visible then
      Exit;

    GetCursorPos(P);
    if PtInRect(PbImage.BoundsRect, Self.ScreenToClient(P)) then
    begin
      if NativeInt(Msg.WParam) < 0 then
        WlNextClick(Self)
      else
        WlBackClick(Self);

      Msg.message := 0;
      Handled := True;
    end;
  end;
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
  FProcessingParams.Convert := CbConvert.Checked;
  if DdConvert.ItemIndex = -1 then
    FProcessingParams.GraphicClass := nil
  else
    FProcessingParams.GraphicClass := TGraphicClass(DdConvert.Items.Objects[DdConvert.ItemIndex]);

  FProcessingParams.Resize := CbResize.Checked;
  FProcessingParams.ResizeToSize := (DdResizeAction.ItemIndex in [0 .. 6]) or
    (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  if (FProcessingParams.ResizeToSize) then
  begin
    case DdResizeAction.ItemIndex of
      0:
        begin
          FProcessingParams.Width := 1920;
          FProcessingParams.Height := 1080;
        end;
      1:
        begin
          FProcessingParams.Width := 1280;
          FProcessingParams.Height := 720;
        end;
      2:
        begin
          FProcessingParams.Width := 1024;
          FProcessingParams.Height := 768;
        end;
      3:
        begin
          FProcessingParams.Width := 800;
          FProcessingParams.Height := 600;
        end;
      4:
        begin
          FProcessingParams.Width := 640;
          FProcessingParams.Height := 480;
        end;
      5:
        begin
          FProcessingParams.Width := 320;
          FProcessingParams.Height := 240;
        end;
      6:
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
    FProcessingParams.WatermarkOptions.Text := AppSettings.ReadString(Settings_Watermark, 'Text', L('Sample text'));
    FProcessingParams.WatermarkOptions.Color := AppSettings.ReadInteger(Settings_Watermark, 'Color', clWhite);
    FProcessingParams.WatermarkOptions.Transparenty := AppSettings.ReadInteger(Settings_Watermark, 'Transparency', 25);
    FProcessingParams.WatermarkOptions.BlockCountX := AppSettings.ReadInteger(Settings_Watermark, 'BlocksX', 3);
    FProcessingParams.WatermarkOptions.BlockCountY := AppSettings.ReadInteger(Settings_Watermark, 'BlocksY', 3);
    FProcessingParams.WatermarkOptions.FontName := AppSettings.ReadString(Settings_Watermark, 'Font', 'Arial');

    if AppSettings.ReadInteger(Settings_Watermark, 'Mode', 0) = 0 then
      FProcessingParams.WatermarkOptions.DrawMode := WModeImage
    else
      FProcessingParams.WatermarkOptions.DrawMode := WModeText;

    FProcessingParams.WatermarkOptions.KeepProportions := AppSettings.ReadBool(Settings_Watermark, 'KeepProportions', True);
    FProcessingParams.WatermarkOptions.StartPoint.X := AppSettings.ReadInteger(Settings_Watermark, 'ImageStartX', 25);
    FProcessingParams.WatermarkOptions.StartPoint.Y := AppSettings.ReadInteger(Settings_Watermark, 'ImageStartY', 25);
    FProcessingParams.WatermarkOptions.EndPoint.X := AppSettings.ReadInteger(Settings_Watermark, 'ImageEndX', 75);
    FProcessingParams.WatermarkOptions.EndPoint.Y := AppSettings.ReadInteger(Settings_Watermark, 'ImageEndY', 75);
    FProcessingParams.WatermarkOptions.ImageFile := AppSettings.ReadString(Settings_Watermark, 'WatermarkImage');
    FProcessingParams.WatermarkOptions.ImageTransparency := Round(AppSettings.ReadInteger(Settings_Watermark, 'ImageTransparency', 50) * 255 / 100);
  end;

  FProcessingParams.SaveAspectRation := CbAspectRatio.Checked;
  if CbAddSuffix.Checked then
    FProcessingParams.Preffix := GeneratePreffix
  else
    FProcessingParams.Preffix := '';

  FProcessingParams.WorkDirectory := PeSavePath.Path;
end;

procedure TFormSizeResizer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TFormSizeResizer.FormCreate(Sender: TObject);
var
  I: Integer;
  Description, Mask: string;
  Ext: TFileAssociation;
  PathImage: TBitmap;
begin
  FContext := DBManager.DBContext;

  FCreatingResize := True;
  FIgnoreInput := False;
  FPreviewImage := nil;
  DoubleBuffered := True;
  RegisterMainForm(Self);
  LoadLanguage;
  FData := TMediaItemCollection.Create;
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
  LsMain.Color := Theme.WindowColor;

  PathImage := GetPathSeparatorImage;
  try
    PeSavePath.SeparatorImage := PathImage;
  finally
    F(PathImage);
  end;
end;

destructor TFormSizeResizer.Destroy;
begin
  F(FData);
  F(FProcessingList);
  inherited;
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
begin
  TmrPreview.Enabled := False;
  if FProcessingList.Count > 0 then
  begin
    for I := 0 to FProcessingList.Count - 1 do
      ProcessedFilesCollection.RemoveFile(FProcessingList[I]);
    CollectionEvents.DoIDEvent(Self, 0, [EventID_Repaint_ImageList], EventInfo);
  end;
  F(FPreviewImage);
  UnRegisterMainForm(Self);
  SwpMain.SavePosition;

  FContext := nil;
end;

procedure TFormSizeResizer.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Screen.ActiveControl <> nil then
    if Screen.ActiveControl.Parent <> nil then
      if Screen.ActiveControl.Parent.Parent = PeSavePath then
        Exit;

  if Key = VK_ESCAPE then
    Close;
  if Key = VK_RETURN then
    BtOkClick(Sender);
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
  JpegOptionsForm.Execute(ConvertImageID);
  CheckValidForm;
end;

procedure TFormSizeResizer.BtOkClick(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;

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

  if IsDevicePath(PeSavePath.Path) then
  begin
    MessageBoxDB(Handle, L('Please, choose a valid directory!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    BtChangeDirectoryClick(Self);
    Exit;
  end;

  CreateDirA(PeSavePath.Path);
  if not DirectoryExistsSafe(PeSavePath.Path) then
  begin
    MessageBoxDB(Handle, L('Please, choose a valid directory!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    BtChangeDirectoryClick(Self);
    Exit;
  end;

  FThreadCount := 0;
  for I := 0 to FData.Count - 1 do
  begin
    ProcessedFilesCollection.AddFile(FData[I].FileName);
    FProcessingList.Add(AnsiLOwerCase(FData[I].FileName));
  end;
  CollectionEvents.DoIDEvent(Self, 0, [EventID_Repaint_ImageList], EventInfo);

  //statistics
  ProgramStatistics.ConverterUsed;

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

  if CbWatermark.Checked then
  begin
    if FProcessingParams.WatermarkOptions.DrawMode = WModeImage then
      ProgramStatistics.WatermarkImageUsed
    else
      ProgramStatistics.WatermarkTextUsed;
  end;

  NewFormState;
  FProcessingParams.PreviewOptions.GeneratePreview := False;
  for I := 1 to Min(FData.Count, ProcessorCount) do
  begin
    Inc(FThreadCount);
    TImageConvertThread.Create(Self, StateID, FContext, FData.Extract(0), FProcessingParams);
  end;
end;

procedure TFormSizeResizer.SetInfo(Owner: TDBForm; List: TMediaItemCollection);
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
    PeSavePath.Path := ExtractFileDir(FData[FCurrentPreviewPosition].FileName);
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

procedure TFormSizeResizer.ThreadEnd(Data: TMediaItem; EndProcessing: Boolean);
var
  I: Integer;
begin
  Dec(FThreadCount);
  PrbMain.Position := FDataCount - FData.Count;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);

  I := FProcessingList.IndexOf(AnsiLowerCase(Data.FileName));
  if I > -1 then
    FProcessingList.Delete(I);
  FillProcessingParams;
  if (FData.Count > 0) and not EndProcessing then
  begin
    TImageConvertThread.Create(Self, StateID, FContext, FData.Extract(0), FProcessingParams);
    Inc(FThreadCount);
  end else if (FThreadCount = 0) or EndProcessing then
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

  R := PbImage.ClientRect;

  FProcessingParams.PreviewOptions.GeneratePreview := True;
  FProcessingParams.PreviewOptions.PreviewWidth := R.Right - R.Left + 1;
  FProcessingParams.PreviewOptions.PreviewHeight := R.Bottom - R.Top + 1;
  TImageConvertThread.Create(Self, StateID, FContext, FData[FCurrentPreviewPosition].Copy, FProcessingParams);
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
  FPreviewAvalable := PreviewImage <> nil;
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

procedure TFormSizeResizer.WndProc(var Message: TMessage);
var
  C: TColor;
  DC: HDC;
  BrushInfo: TagLOGBRUSH;
  Brush: HBrush;
begin
  if (Message.Msg = WM_ERASEBKGND) and StyleServices.Enabled then
  begin
    Message.Result := 1;

    DC := TWMEraseBkgnd(Message).DC;
    if DC = 0 then
      Exit;

    C := Theme.WindowColor;
    brushInfo.lbStyle := BS_SOLID;
    brushInfo.lbColor := ColorToRGB(C);
    Brush := CreateBrushIndirect(brushInfo);

    FillRect(DC, Rect(0, 0, Width, PbImage.Top), Brush);
    FillRect(DC, Rect(0, PbImage.Top + PbImage.Height, Width, Height), Brush);

    FillRect(DC, Rect(0, PbImage.Top, PbImage.Left, PbImage.Top + PbImage.Height), Brush);
    FillRect(DC, Rect(PbImage.Left + PbImage.Width, PbImage.Top, Width, PbImage.Top + PbImage.Height), Brush);

    if(Brush > 0) then
      DeleteObject(Brush);

    Exit;
  end;

  inherited;
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  AppSettings.WriteInteger(Settings_ConvertForm, 'Convert', DdConvert.ItemIndex);
  AppSettings.WriteInteger(Settings_ConvertForm, 'Rotate', DdRotate.ItemIndex);
  AppSettings.WriteInteger(Settings_ConvertForm, 'Resize', DdResizeAction.ItemIndex);
  AppSettings.WriteString(Settings_ConvertForm, 'ResizeW', EdWidth.Text);
  AppSettings.WriteString(Settings_ConvertForm, 'ResizeH', Edheight.Text);
  AppSettings.WriteBool(Settings_ConvertForm, 'SaveAspectRatio', CbAspectRatio.Checked);
  AppSettings.WriteBool(Settings_ConvertForm, 'AddSuffix', CbAddSuffix.Checked);
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

procedure TFormSizeResizer.CustomFormAfterDisplay;
begin
  inherited;
  if EdImageName = nil then
   Exit;
  if DdConvert = nil then
   Exit;
  if DdRotate = nil then
   Exit;
  if DdResizeAction = nil then
   Exit;

  EdImageName.Refresh;
  DdConvert.Refresh;
  DdRotate.Refresh;
  DdResizeAction.Refresh;
end;

procedure TFormSizeResizer.DdConvertChange(Sender: TObject);
begin
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
  CbRotate.Checked := True;
  DdRotate.ItemIndex := 0; //rotate by EXIF by default
  FIgnoreInput := False;
  TmrPreviewTimer(Self);
end;

procedure TFormSizeResizer.DoDefaultRotate(RotateValue: Integer; StartImmediately : Boolean);
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
    DdResizeAction.Items.Add(L('Full HD (1920x1080)'));
    DdResizeAction.Items.Add(L('HD (1280x720)'));
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

    PeSavePath.LoadingText := L('Loading...');

    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('Ok');
  finally
    EndTranslate;
  end;
end;

procedure TFormSizeResizer.PbImageContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Info: TMediaItemCollection;
  I: Integer;
begin
  if PrbMain.Visible then
    Exit;
  Info := TMediaItemCollection.Create;
  try
    Info.Assign(FData);
    Info.Position := FCurrentPreviewPosition;
    for I := 0 to Info.Count - 1 do
      Info[I].Selected := I = FCurrentPreviewPosition;

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
  Text: string;
begin
  if (FPreviewImage <> nil) and (FRealWidth + FRealHeight > 0) then
  begin
    R := Rect(0, 0, PbImage.Width, PbImage.Height);
    W := R.Right - R.Left + 1 - 4; //4px for shadow
    H := R.Bottom - R.Top + 1 - 4; //4px for shadow
    Width := FPreviewImage.Width;
    Height := FPreviewImage.Height;
    ProportionalSizeA(W, H, Width, Height);
    ProportionalSize(FRealWidth, FRealHeight, Width, Height);

    X := R.Left + W div 2 - Width div 2;
    Y := R.Top + H div 2 - Height div 2;
    R := Rect(X, Y, X + Width + 4, Y + Height + 4);

    DisplayImage := TBitmap.Create;
    ShadowImage := TBitmap.Create;
    try
      ShadowImage.PixelFormat := pf32Bit;
      DisplayImage.PixelFormat := pf24Bit;
      DrawShadowToImage(ShadowImage, FPreviewImage);
      DisplayImage.SetSize(ShadowImage.Width, ShadowImage.Height);
      LoadBMPImage32bit(ShadowImage, DisplayImage, Theme.WindowColor);

      PbImage.Canvas.Pen.Color := Theme.WindowColor;
      PbImage.Canvas.Brush.Color := Theme.WindowColor;
      PbImage.Canvas.Rectangle(PbImage.ClientRect);
      PbImage.Canvas.StretchDraw(R, DisplayImage);
    finally
      F(DisplayImage);
      F(ShadowImage);
    end;
  end else
  begin
    PbImage.Canvas.Pen.Color := Theme.WindowColor;
    PbImage.Canvas.Brush.Color := Theme.WindowColor;
    PbImage.Canvas.Rectangle(PbImage.ClientRect);

    Text := L('Preview isn''t available. Image can be corrupted or encrypted.');
    H := PbImage.Canvas.TextHeight(Text);
    R := Rect(0, PbImage.Height div 2 - H div 2, PbImage.Width, PbImage.Height);
    PbImage.Canvas.Font.Color := Theme.WindowTextColor;
    PbImage.Canvas.TextRect(R, Text, [tfCenter, tfWordBreak]);
  end;
end;

procedure TFormSizeResizer.ReadSettings;
begin
  try
    DdConvert.ItemIndex := AppSettings.ReadInteger(Settings_ConvertForm, 'Convert', 0);
    DdRotate.ItemIndex := AppSettings.ReadInteger(Settings_ConvertForm, 'Rotate', 0);

    EdWidth.Text := IntToStr(AppSettings.ReadInteger(Settings_ConvertForm, 'ResizeW', 1024));
    EdHeight.Text := IntToStr(AppSettings.ReadInteger(Settings_ConvertForm, 'ResizeH', 768));
    DdResizeAction.ItemIndex := AppSettings.ReadInteger(Settings_ConvertForm, 'Resize', 0);

    CbAspectRatio.Checked := AppSettings.ReadBool(Settings_ConvertForm, 'SaveAspectRatio', True);
    CbAddSuffix.Checked := AppSettings.ReadBool(Settings_ConvertForm, 'AddSuffix', True);
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
  Directory := UnitDBFileDialogs.DBSelectDir(Handle, L('Select folder for processed images'), PeSavePath.Path);
  if DirectoryExists(Directory) then
    PeSavePath.Path := Directory;
end;

initialization
  FormInterfaces.RegisterFormInterface(IBatchProcessingForm, TFormSizeResizer);

end.
