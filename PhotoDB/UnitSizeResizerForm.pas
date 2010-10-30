unit UnitSizeResizerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Dolphin_DB, ExtCtrls, ImageConverting, Math, UVistaFuncs,
  JPEG, GIFImage, GraphicEx, UnitDBkernel, GraphicCrypt,
  AcDlgSelect, TiffImageUnit, UnitDBDeclare, UnitDBFileDialogs, uFileUtils,
  UnitDBCommon, UnitDBCommonGraphics, ComCtrls, ImgList, uDBForm, LoadingSign,
  DmProgress, uW7TaskBar, PngImage, uGOM, uWatermarkOptions, uImageSource,
  UnitPropeccedFilesSupport, uThreadForm, uMemory, uFormListView,
  uDBPopupMenuInfo, uConstants;

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
    procedure FormPaint(Sender: TObject);
    procedure DdRotateClick(Sender: TObject);
    procedure DdRotateChange(Sender: TObject);
    procedure CbAspectRatioClick(Sender: TObject);
    procedure TmrPreviewTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FData: TDBPopupMenuInfo;
    FW7TaskBar: ITaskbarList3;
    FDataCount: Integer;
    FProcessingParams: TProcessingParams;
    FPreviewImage: TBitmap;
    FOwner: IImageSource;
    FIgnoreInput: Boolean;
    FCreatingResize: Boolean;
    procedure LoadLanguage;
    procedure CheckValidForm;
  protected
    function GetFormID: string; override;
    procedure FillProcessingParams;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CheckPreviewSize;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure SetInfo(Owner: IImageSource; List: TDBPopupMenuInfo);
    procedure ThreadEnd(Data: TDBPopupMenuInfoRecord; EndProcessing: Boolean);
    procedure GeneratePreview;
    procedure UpdatePreview(PreviewImage: TBitmap);
    procedure DefaultResize;
    procedure DefaultConvert;
    procedure DefaultExport;
    procedure DefaultRotate(RotateValue : Integer; StartImmediately : Boolean);
  end;

const
  ConvertImageID = 'ConvertImage';

procedure ExportImages(Owner: IImageSource; List: TDBPopupMenuInfo);
procedure ResizeImages(Owner: IImageSource; List: TDBPopupMenuInfo);
procedure ConvertImages(Owner: IImageSource; List: TDBPopupMenuInfo);
procedure RotateImages(Owner: IImageSource; List: TDBPopupMenuInfo; BeginRotate : Integer; StartImmediately : Boolean);

implementation

uses UnitJPEGOptions, UImageConvertThread;
{$R *.dfm}

procedure ResizeImages(Owner: IImageSource; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultResize;
  FormSizeResizer.Show;
end;

procedure ConvertImages(Owner: IImageSource; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultConvert;
  FormSizeResizer.Show;
end;

procedure ExportImages(Owner: IImageSource; List: TDBPopupMenuInfo);
var
  FormSizeResizer: TFormSizeResizer;
begin
  Application.CreateForm(TFormSizeResizer, FormSizeResizer);
  FormSizeResizer.SetInfo(Owner, List);
  FormSizeResizer.DefaultExport;
  FormSizeResizer.Show;
end;

procedure RotateImages(Owner: IImageSource; List: TDBPopupMenuInfo; BeginRotate : Integer; StartImmediately : Boolean);
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
  var
    S: string;
  begin
    Result := '_';
    if CbResize.Checked then
      S := DdResizeAction.Text;
  end;

begin

  FProcessingParams.Rotate := CbRotate.Checked;
  FProcessingParams.Rotation := Rotations[DdRotate.ItemIndex];
  if DdConvert.ItemIndex = -1 then
    FProcessingParams.GraphicClass := nil
  else
    FProcessingParams.GraphicClass := GetConvertableImageClasses[DdConvert.ItemIndex];

  FProcessingParams.Resize := CbResize.Checked;
  FProcessingParams.ResizeToSize := (DdResizeAction.ItemIndex in [0 .. 4]) or
    (DdResizeAction.ItemIndex = DdResizeAction.Items.Count - 1);
  if (FProcessingParams.ResizeToSize) then
  begin
    case DdResizeAction.ItemIndex of
      0:
        begin
          FProcessingParams.Width := 640;
          FProcessingParams.Height := 480;
        end;
      1:
        begin
          FProcessingParams.Width := 800;
          FProcessingParams.Height := 600;
        end;
      2:
        begin
          FProcessingParams.Width := 1024;
          FProcessingParams.Height := 768;
        end;
      3:
        begin
          FProcessingParams.Width := 128;
          FProcessingParams.Height := 124;
        end;
      4:
        begin
          FProcessingParams.Width := 320;
          FProcessingParams.Height := 240;
        end;
    else
      FProcessingParams.Width := Min(Max(StrToIntDef(EdWidth.Text, 100), 5), 5000);
      FProcessingParams.Height := Min(Max(StrToIntDef(EdHeight.Text, 100), 5), 5000);
    end;
  end
  else
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
  // TODO:
  if CbWatermark.Checked then
  begin
    FProcessingParams.WatermarkOptions.Text := L('Test copyright');
    FProcessingParams.WatermarkOptions.Color := ClWhite;
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
  FCreatingResize := True;
  FIgnoreInput := False;
  FPreviewImage := nil;
  LoadLanguage;
  FData := TDBPopupMenuInfo.Create;

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
  DdConvert.ItemIndex := 0;
  DdRotate.ItemIndex := 0;
  DdResizeAction.ItemIndex := 0;

  FW7TaskBar := CreateTaskBarInstance;
  GOM.AddObj(Self);
end;

procedure TFormSizeResizer.FormDestroy(Sender: TObject);
begin
  F(FData);
end;

procedure TFormSizeResizer.FormPaint(Sender: TObject);
var
  R: TRect;
  W, H : Integer;
begin
  if FPreviewImage <> nil then
  begin
    R := Rect(5, LbInfo.Top + LbInfo.Height + 5, ClientWidth - 5, PrbMain.Top - 5);
    W := R.Right - R.Left;
    H := R.Bottom - R.Top;
    Canvas.Draw(R.Left + W div 2 - FPreviewImage.Width div 2, R.Top + H div 2 - FPreviewImage.Height div 2, FPreviewImage);
  end;
end;

procedure TFormSizeResizer.CheckPreviewSize;
var
  R: TRect;
  W, H, NewW, NewH: Integer;
  Bitmap: TBitmap;
begin
  R := Rect(5, LbInfo.Top + LbInfo.Height + 5, ClientWidth - 5, PrbMain.Top - 5);
  if FPreviewImage <> nil then
  begin
    W := R.Right - R.Left;
    H := R.Bottom - R.Top;

    if (W < FPreviewImage.Width) or (H < FPreviewImage.Height) then
    begin
      Bitmap := TBitmap.Create;
      try
        NewW := FPreviewImage.Width;
        NewH := FPreviewImage.Height;
        ProportionalSizeA(W, H, NewW, NewH);
        DoResize(NewW, NewH, FPreviewImage, Bitmap);
        F(FPreviewImage);
        FPreviewImage := Bitmap;
        Bitmap := nil;
        Exit;
      finally
        F(Bitmap);
      end;
    end;
  end;
end;

procedure TFormSizeResizer.FormResize(Sender: TObject);
begin
  if FCreatingResize then
  begin
    FCreatingResize := False;
    Exit;
  end;
  CheckPreviewSize;
  Repaint;
  GeneratePreview;
end;

procedure TFormSizeResizer.GeneratePreview;
begin
  if not FIgnoreInput then
  begin
    TmrPreview.Enabled := False;
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
    GraphicClass: TGraphicClass;
    I: Integer;
  begin
    Result := True;
    for I := 0 to FData.Count - 1 do
    begin
      GraphicClass := GetGraphicClass(ExtractFileExt(FData[I].FileName), True);
      Result := Result and ConvertableImageClass(GraphicClass);
    end;
  end;

begin

  if not CheckFileTypes and (DdConvert.ItemIndex < 0) then
  begin
    MessageBoxDB(Handle, L('Please, choose format!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  for I := 0 to FData.Count - 1 do
    ProcessedFilesCollection.AddFile(FData[I].FileName);

  // change form state
  PnOptions.Hide;
  BtSaveAsDefault.Hide;
  BtOk.Hide;
  PrbMain.Top := BtCancel.Top - BtCancel.Height - 5;
  PrbMain.Show;
  EdImageName.Top := PrbMain.Top - EdImageName.Height - 5;
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

procedure TFormSizeResizer.SetInfo(Owner: IImageSource; List: TDBPopupMenuInfo);
var
  I: Integer;
begin
  FOwner := Owner;

  for I := 0 to List.Count - 1 do
    if List[I].Selected then
      FData.Add(List[I].Copy);

  if FData.Count > 0 then
    EdSavePath.Text := ExtractFileDir(FData[0].FileName);
end;

procedure TFormSizeResizer.ThreadEnd(Data: TDBPopupMenuInfoRecord; EndProcessing: Boolean);
begin
  PrbMain.Position := FDataCount - FData.Count;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, FDataCount - FData.Count, FDataCount);

  if (FData.Count > 0) and not EndProcessing then
    TImageConvertThread.Create(Self, StateID, FData.Extract(0), FProcessingParams)
  else
    Close;
end;

procedure TFormSizeResizer.TmrPreviewTimer(Sender: TObject);
var
  R: TRect;
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
  TImageConvertThread.Create(Self, StateID, FData[0].Copy, FProcessingParams);
  LsMain.Show;

  if FPreviewImage = nil then
  begin
    FPreviewImage := TBitmap.Create;
    if not FOwner.GetImage(FData[0].FileName, FPreviewImage) then
      F(FPreviewImage);

    CheckPreviewSize;
  end;
end;

procedure TFormSizeResizer.UpdatePreview(PreviewImage: TBitmap);
begin
  LsMain.Hide;
  F(FPreviewImage);
  FPreviewImage := PreviewImage;
  Refresh;
end;

procedure TFormSizeResizer.BtSaveAsDefaultClick(Sender: TObject);
begin
  // TODO: DBKernel.WriteInteger('Convert options','Width',StrToIntDef(Edit1.text,1024));
end;

procedure TFormSizeResizer.BtWatermarkOptionsClick(Sender: TObject);
begin
  CheckValidForm;
end;

procedure TFormSizeResizer.CbAspectRatioClick(Sender: TObject);
begin
  CheckValidForm;
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

procedure TFormSizeResizer.EdHeightKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0' .. '9']) then
    Key := #0;
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
