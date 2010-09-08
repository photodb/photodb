unit UnitSizeResizerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ExtCtrls, ImageConverting, Math, uVistaFuncs,
  JPEG, GIFImage, GraphicEx, Language, UnitDBkernel, GraphicCrypt,
  acDlgSelect, TiffImageUnit, UnitDBDeclare, UnitDBFileDialogs, uFileUtils,
  UnitDBCommon, UnitDBCommonGraphics, ComCtrls, ImgList, uDBForm, LoadingSign,
  DmProgress, uW7TaskBar, PngImage, uGOM, uWatermarkOptions;

type
  TFormSizeResizer = class(TDBForm)
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
  private
    FData : TDBPopupMenuInfo;
    FW7TaskBar : ITaskbarList3;
    FDataCount : Integer;
    FProcessingParams : TProcessingParams;
    //My descrioption
    procedure LoadLanguage;
    procedure CheckValidForm;
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    procedure SetInfo(List : TDBPopupMenuInfo);
    procedure ThreadEnd(EndProcessing : Boolean);
    { Public declarations }
  end;

  const
    ConvertImageID = 'ConvertImage';

procedure ResizeImages(List : TDBPopupMenuInfo);

implementation

uses UnitJPEGOptions, uImageConvertThread;

{$R *.dfm}

procedure ResizeImages(List : TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(List);
  FormSizeResizer.Show;
end;

procedure TFormSizeResizer.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormSizeResizer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GOM.RemoveObj(Self);
  Release;
end;

procedure TFormSizeResizer.FormCreate(Sender: TObject);
var
  Formats: TArGraphicClass;
  I: Integer;
  Description, Mask: string;
begin
  LoadLanguage;
  FData := TDBPopupMenuInfo.Create;
  DBkernel.RecreateThemeToForm(Self);

  Formats := GetConvertableImageClasses;
  for I := 0 to Length(Formats) - 1 do
  begin
    if Formats[I] = TiffImageUnit.TTiffGraphic then
      Description := 'Tiff Image'
    else if Formats[I] = TGIFImage then
      Description := 'GIF Image'
    else if Formats[I] = PngImage.TPNGGraphic then
      Description := 'PNG Image'
    else
      Description := GraphicEx.FileFormatList.GetDescription(Formats[I]);

    if Formats[I] = TiffImageUnit.TTiffGraphic then
      Mask := '*.tiff'
    else if Formats[I] = TBitmap then
      Mask := '*.bmp'
    else if Formats[I] = PngImage.TPNGGraphic then
      Mask := '*.png'
    else
      Mask := GraphicFileMask(Formats[I]);

    DdConvert.Items.AddObject(Description + '  (' + Mask + ')', TObject(I));
  end;

  FW7TaskBar := CreateTaskBarInstance;
  GOM.AddObj(Self);
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
begin
  FData.Free;
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
  I : Integer;

const
  Rotations : array[-1..3] of Integer = (DB_IMAGE_ROTATE_UNKNOWN, DB_IMAGE_ROTATE_EXIF, DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_180);

  function CheckFileTypes : Boolean;
  var
    GraphicClass : TGraphicClass;
    I : Integer;
  begin
    Result := True;
    for I := 0 to FData.Count - 1 do
    begin
      GraphicClass := GetGraphicClass(ExtractFileExt(FData[I].FileName), True);
      Result := Result and ConvertableImageClass(GraphicClass);
    end;
  end;

  function GeneratePreffix : string;
  var
    S : string;
  begin
    Result := '_';
    if CbResize.Checked then
    begin
      S := DdResizeAction.Text;
    end;
  end;

begin

  if not CheckFileTypes and (DdConvert.ItemIndex < 0) then
  begin
    MessageBoxDB(Handle, TEXT_MES_CHOOSE_FORMAT, TEXT_MES_WARNING, TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  //change form state
  PnOptions.Hide;
  BtSaveAsDefault.Hide;
  BtOk.Hide;
  PrbMain.Top := BtCancel.Top - BtCancel.Height - 5;
  PrbMain.Show;
  EdImageName.Top := PrbMain.Top - EdImageName.Height - 5;
  BtCancel.Left := PrbMain.Left + PrbMain.Width - BtCancel.Width;
  ClientHeight := ClientHeight - PnOptions.Height - 5;

  //init progress
  LsMain.Show;
  FDataCount := FData.Count;
  if FW7TaskBar <> nil then
  begin
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);
  end;
  PrbMain.MaxValue := FDataCount;

  //fill params of processing
  FProcessingParams.Rotate := CbRotate.Checked;
  FProcessingParams.Rotation := Rotations[DdRotate.ItemIndex];
  if DdConvert.ItemIndex = -1 then
    FProcessingParams.GraphicClass := nil
  else
    FProcessingParams.GraphicClass := GetConvertableImageClasses[DdConvert.ItemIndex];

  FProcessingParams.Resize := CbResize.Checked;
  FProcessingParams.ResizeToSize := (DdResizeAction.ItemIndex in [0..4]) or (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  if (FProcessingParams.ResizeToSize) then
  begin
    case DdResizeAction.ItemIndex of
      0:
      begin
        FProcessingParams.Width := 640;
        FProcessingParams.height := 480;
      end;
      1:
      begin
        FProcessingParams.Width := 800;
        FProcessingParams.height := 600;
      end;
      2:
      begin
        FProcessingParams.Width := 1024;
        FProcessingParams.height := 768;
      end;
      3:
      begin
        FProcessingParams.Width := 128;
        FProcessingParams.height := 124;
      end;
      4:
      begin
        FProcessingParams.Width := 320;
        FProcessingParams.height := 240;
      end;
      else
        FProcessingParams.Width := Min(Max(StrToIntDef(EdWidth.Text, 100), 5), 5000);
        FProcessingParams.height := Min(Max(StrToIntDef(EdHeight.Text, 100), 5), 5000);
    end;
  end else
  begin
    case DdResizeAction.ItemIndex - 4 of
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
  //TODO:
  if CbWatermark.Checked then
  begin
    FProcessingParams.WatermarkOptions.Text := 'Test copyright';
    FProcessingParams.WatermarkOptions.Color := clWhite;
    FProcessingParams.WatermarkOptions.Transparenty := 25;
    FProcessingParams.WatermarkOptions.BlockCountX := 3;
    FProcessingParams.WatermarkOptions.BlockCountY := 3;
  end;

  FProcessingParams.SaveAspectRation := CbAspectRatio.Checked;
  if CbAddSuffix.Checked then
    FProcessingParams.Preffix := GeneratePreffix
  else
    FProcessingParams.Preffix := '';

  FProcessingParams.WorkDirectory := EdSavePath.Text;

  for I := 1 to Min(FData.Count, ProcessorCount) do
    TImageConvertThread.Create(Self, FData.Extract(0), FProcessingParams);

end;

procedure TFormSizeResizer.SetInfo(List : TDBPopupMenuInfo);
var
  I : Integer;
begin
  for I := 0 to List.Count - 1 do
    FData.Add(List[I].Copy);

  if FData.Count > 0 then
    EdSavePath.Text := ExtractFileDir(FData[0].FileName);
end;

procedure TFormSizeResizer.ThreadEnd(EndProcessing : Boolean);
begin
  PrbMain.Position := FDataCount - FData.Count;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);

  if (FData.Count > 0) and not EndProcessing then
    TImageConvertThread.Create(Self, FData.Extract(0), FProcessingParams)
  else
    Close;
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  //TODO: DBKernel.WriteInteger('Convert options','Width',StrToIntDef(Edit1.text,1024));
end;

procedure TFormSizeResizer.BtWatermarkOptionsClick(Sender: TObject);
begin
  ShowWatermarkOptions;
end;

procedure TFormSizeResizer.CbConvertClick(Sender: TObject);
begin
  DdConvert.Enabled := CbConvert.Checked;
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
  Valid : Boolean;
begin
  Valid := CbConvert.Checked or CbResize.Checked or CbRotate.Checked or CbWatermark.Checked;
  BtOk.Enabled := Valid;
  BtSaveAsDefault.Enabled := Valid;
end;

procedure TFormSizeResizer.DdConvertChange(Sender: TObject);
begin
  BtJPEGOptions.Enabled := DdConvert.Enabled and (DdConvert.ItemIndex = 0);
end;

procedure TFormSizeResizer.DdResizeActionChange(Sender: TObject);
begin
  EdWidth.Enabled := DdResizeAction.Enabled and (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  EdHeight.Enabled := EdWidth.Enabled;
  LbSizeSeparator.Enabled := EdWidth.Enabled;
end;

procedure TFormSizeResizer.EdWidthExit(Sender: TObject);
begin
  (Sender as TEdit).Text := IntToStr(Min(Max(StrToIntDef((Sender as TEdit).Text, 100), 5), 5000));
end;

/// <summary>
/// LoadLanguage
/// </summary>
procedure TFormSizeResizer.LoadLanguage;
begin
  Caption := L('Change Image');
  LbInfo.Caption := L('You can change image size, convert image to another format, rotate image and add custom watermark.');

  CbWatermark.Caption := L('Add Watermark');
  BtWatermarkOptions.Caption := L('Watermark Options');
  CbConvert.Caption := L('Convert');

  CbResize.Caption := L('Resize');
  DdResizeAction.Items.Add(L('Small (640x480)'));
  DdResizeAction.Items.Add(L('Medium (800x600)'));
  DdResizeAction.Items.Add(L('Big (1024x768)'));
  DdResizeAction.Items.Add(L('Thumbnails (128x124)'));
  DdResizeAction.Items.Add(L('Pocket PC (240õ320)'));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [25]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [50]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [75]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [150]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [200]));
  DdResizeAction.Items.Add(Format(L('Size: %d%%'), [400]));
  DdResizeAction.Items.Add(L('Custom size:'));

  CbRotate.Caption := L('Rotate');
  DdRotate.Items.Add(L('By EXIF'));
  DdRotate.Items.Add(L('Left'));
  DdRotate.Items.Add(L('Right'));
  DdRotate.Items.Add(L('180 grad'));

  CbAspectRatio.Caption := L('Save aspect ratio');
  CbAddSuffix.Caption := L('Add filename suffix');
  BtJPEGOptions.Caption := L('JPEG Options');
  BtSaveAsDefault.Caption := L('Save settings by default');

  PrbMain.Text := L('Processing... (&%%)');

  BtCancel.Caption := L('Cancel');
  BtOk.Caption := L('Ok');
end;

procedure TFormSizeResizer.EdHeightKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9']) then
    Key := #0;
end;

procedure TFormSizeResizer.BtChangeDirectoryClick(Sender: TObject);
var
  Directory: string;
begin
  Directory := UnitDBFileDialogs.DBSelectDir(Handle, TEXT_MES_SEL_FOLDER_FOR_IMAGES, UseSimpleSelectFolderDialog);
  if DirectoryExists(Directory) then
    EdSavePath.Text := Directory;
end;

end.
