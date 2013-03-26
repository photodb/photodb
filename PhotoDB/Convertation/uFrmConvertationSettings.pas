unit uFrmConvertationSettings;

interface

uses
  WInapi.Windows,
  System.SysUtils,
  System.Math,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Imaging.jpeg,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  CommonDBSupport,
  UnitDBDeclare,

  uFrameWizardBase,
  uMemory,
  uJpegUtils,
  uBItmapUtils,
  uResources,
  uInterfaces,
  uTranslateUtils;

type
  TFrmConvertationSettings = class(TFrameWizardBase)
    LbInfo: TLabel;
    LbDatabaseSize: TLabel;
    LbSingleImageSize: TLabel;
    WlPreviewDBSize: TWebLink;
    CbDBImageSize: TComboBox;
    CbDBJpegquality: TComboBox;
    WlPreviewDBJpegQuality: TWebLink;
    CbPreviewSize: TComboBox;
    WlPreviewSize: TWebLink;
    LbDBImageSize: TLabel;
    LbDBImageQuality: TLabel;
    LbPreviewImageSize: TLabel;
    procedure CbDBImageSizeChange(Sender: TObject);
    procedure CbDBJpegqualityChange(Sender: TObject);
    procedure CbPreviewSizeChange(Sender: TObject);
    procedure WlPreviewDBSizeClick(Sender: TObject);
    procedure WlPreviewSizeClick(Sender: TObject);
  private
    { Private declarations }
    Image: TJpegImage;
    function GetImageOptions: TImageDBOptions;
    function HintCheck(Info: TDBPopupMenuInfoRecord): Boolean;
    procedure FillImageSize(Combo: TcomboBox);
    procedure FillImageQuality(Combo: TcomboBox);
    procedure ShowPreview(Graphic: TGraphic; Size: Int64);
    procedure UpdateDBSize;
    procedure UpdateBitmapSize(Size: Integer; Bitmap: TBitmap);
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
    function LocalScope: string; override;
  public
    { Public declarations }
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    procedure Unload; override;
    function InitNextStep: Boolean; override;
    property ImageOptions: TImageDBOptions read GetImageOptions;
  end;

implementation

uses
  UnitConvertDBForm,
  UnitHintCeator;

{$R *.dfm}

{ TFrmConvertationSettings }

procedure TFrmConvertationSettings.CbDBImageSizeChange(Sender: TObject);
begin
  ImageOptions.ThSize := Max(50, Min(1000, StrToIntDef(CbDBImageSize.Text, 150)));
  UpdateDBSize;
end;

procedure TFrmConvertationSettings.CbDBJpegqualityChange(Sender: TObject);
begin
  ImageOptions.DBJpegCompressionQuality := Max(1, Min(100, StrToIntDef(CbDBJpegquality.Text, 75)));
  UpdateDBSize;
end;

procedure TFrmConvertationSettings.CbPreviewSizeChange(Sender: TObject);
begin
  ImageOptions.ThHintSize := Max(50, Min(1000, StrToIntDef(CbPreviewSize.Text, 150)));
end;

procedure TFrmConvertationSettings.FillImageQuality(Combo: TcomboBox);
begin
  Combo.Items.Clear;
  Combo.Items.Add('25');
  Combo.Items.Add('30');
  Combo.Items.Add('40');
  Combo.Items.Add('50');
  Combo.Items.Add('60');
  Combo.Items.Add('75');
  Combo.Items.Add('80');
  Combo.Items.Add('85');
  Combo.Items.Add('90');
  Combo.Items.Add('95');
  Combo.Items.Add('100');
end;

procedure TFrmConvertationSettings.FillImageSize(Combo: TcomboBox);
begin
  Combo.Items.Clear;
  Combo.Items.Add('85');
  Combo.Items.Add('90');
  Combo.Items.Add('100');
  Combo.Items.Add('125');
  Combo.Items.Add('150');
  Combo.Items.Add('175');
  Combo.Items.Add('200');
  Combo.Items.Add('250');
  Combo.Items.Add('300');
  Combo.Items.Add('350');
  Combo.Items.Add('400');
  Combo.Items.Add('450');
end;

function TFrmConvertationSettings.GetImageOptions: TImageDBOptions;
begin
  Result := (Manager.Owner as IDBImageSettings).GetImageOptions;
end;

function TFrmConvertationSettings.HintCheck(
  Info: TDBPopupMenuInfoRecord): Boolean;
begin
  Result := True;
end;

procedure TFrmConvertationSettings.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);

  procedure LoadLinkIcon(Link: TWebLink; Name: string);
  var
    Ico: HIcon;
  begin
    Ico := LoadIcon(HInstance, PChar(Name));
    try
      Link.LoadFromHIcon(Ico);
    finally
      DestroyIcon(Ico);
    end;
  end;

begin
  inherited;
  if FirstInitialization then
  begin
    Image := GetBigPatternImage;
    FillImageSize(CbDBImageSize);
    FillImageQuality(CbDBJpegquality);
    FillImageSize(CbPreviewSize);

    LoadLinkIcon(WlPreviewDBSize, 'PICTURE');
    LoadLinkIcon(WlPreviewDBJpegQuality, 'PICTURE');
    LoadLinkIcon(WlPreviewSize, 'PICTURE');

    CbDBImageSize.Text := IntToStr(ImageOptions.ThSize);
    CbDBJpegquality.Text := IntToStr(ImageOptions.DBJpegCompressionQuality);
    CbPreviewSize.Text := IntToStr(ImageOptions.ThHintSize);
    CbDBImageSizeChange(Self);
  end;
end;

function TFrmConvertationSettings.InitNextStep: Boolean;
begin
  Result := inherited;
end;

procedure TFrmConvertationSettings.LoadLanguage;
begin
  inherited;
  LbInfo.Caption := L('You can adjust the size and compression quality of images in the database and other sizes of images');
  LbDBImageSize.Caption := L('Default thumbnail size in database');
  LbDBImageQuality.Caption := L('Compression quality of images stored in the database');
  LbPreviewImageSize.Caption := L('Image preview size');
  WlPreviewDBSize.Text := L('Preview');
  WlPreviewDBJpegQuality.Text := L('Preview');
  WlPreviewSize.Text := L('Preview');
end;

function TFrmConvertationSettings.LocalScope: string;
begin
  Result := 'ConvertDB';
end;

procedure TFrmConvertationSettings.ShowPreview(Graphic: TGraphic; Size: Int64);
var
  Info: TDBPopupMenuInfoRecord;
  P: TPoint;
begin
  GetCursorPos(P);
  Info := TDBPopupMenuInfoRecord.Create;
  Info.Image := TJpegImage.Create;
  Info.Image.Assign(Graphic);
  Info.Image.CompressionQuality := 100;
  if Graphic is TBitmap then
    Info.Image.Compress;

  Info.FileName := '?.JPEG';
  Info.Name := L('Preview');
  Info.FileSize := Size;
  THintManager.Instance.CreateHintWindow(Manager.Owner, Info, P, HintCheck);
end;

procedure TFrmConvertationSettings.Unload;
begin
  inherited;
  F(Image);
end;

procedure TFrmConvertationSettings.UpdateBitmapSize(Size: Integer;
  Bitmap: TBitmap);
var
  Temp: TBitmap;
  W, H: Integer;
begin
  Temp := TBitmap.Create;
  try
    Temp.Assign(Image);
    W := Temp.Width;
    H := Temp.Height;

    ProportionalSizeA(Size, Size, W, H);
    DoResize(W, H, Temp, Bitmap);
  finally
    F(Temp);
  end;
end;

procedure TFrmConvertationSettings.UpdateDBSize;
var
  JPEG: TJpegImage;
  ImageSize: Int64;
  RecordCount: Integer;
begin
  ImageSize := CalcJpegResampledSize(Image, ImageOptions.ThSize,
    ImageOptions.DBJpegCompressionQuality, JPEG);
  F(JPEG);

  RecordCount := 1000;
  if Manager.Owner is TFormConvertingDB then
    RecordCount := TFormConvertingDB(Manager.Owner).RecordsCount;

  LbSingleImageSize.Caption := Format(L('Image size: %s'), [SizeInText(ImageSize)]);
  LbDatabaseSize.Caption := Format(L('The size of new database (approximately): %s'),
    [SizeInText(RecordCount * ImageSize)]);
end;

procedure TFrmConvertationSettings.WlPreviewDBSizeClick(Sender: TObject);
var
   JPEG: TJpegImage;
   ImageSize: Int64;
begin
  ImageSize := CalcJpegResampledSize(Image, ImageOptions.ThSize,
    ImageOptions.DBJpegCompressionQuality, JPEG);
  ShowPreview(JPEG, ImageSize);
  F(JPEG)
end;

procedure TFrmConvertationSettings.WlPreviewSizeClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    UpdateBitmapSize(ImageOptions.ThHintSize, Bitmap);
    ShowPreview(Bitmap, Bitmap.Width * Bitmap.Height * 3);
  finally
    F(Bitmap);
  end;
end;

end.
