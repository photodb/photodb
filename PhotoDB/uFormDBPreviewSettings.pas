unit uFormDBPreviewSettings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Imaging.jpeg,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,

  uMemory,
  uDBForm,
  uDBManager,
  uDBContext,
  uDBEntities,
  uJpegUtils,
  uBitmapUtils,
  uResources,
  uInterfaces,
  uFormInterfaces,
  uCollectionEvents,
  uTranslateUtils;

type
  TFormDBPreviewSize = class(TDBForm, IFormCollectionPreviewSettings)
    LbDatabaseSize: TLabel;
    LbSingleImageSize: TLabel;
    LbDBImageSize: TLabel;
    LbDBImageQuality: TLabel;
    WlPreviewDBSize: TWebLink;
    CbDBImageSize: TComboBox;
    CbDBJpegquality: TComboBox;
    WlPreviewDBJpegQuality: TWebLink;
    BtnOk: TButton;
    BtnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure WlPreviewDBSizeClick(Sender: TObject);
    procedure CbDBImageSizeChange(Sender: TObject);
    procedure CbDBJpegqualityChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FContext: IDBContext;
    FMediaRepository: IMediaRepository;
    FSettingsRepository: ISettingsRepository;
    FSampleImage: TJpegImage;
    FMediaCount: Integer;
    FCollectionSettings: TSettings;
    procedure FillImageSize(Combo: TComboBox);
    procedure FillImageQuality(Combo: TComboBox);
    procedure ShowPreview(Graphic: TGraphic; Size: Int64);
    function HintCheck(Info: TMediaItem): Boolean;
    procedure UpdateDBSize;
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure LoadLanguage;
  public
    { Public declarations }
    function Execute(CollectionFileName: string): Boolean;
  end;

implementation

uses
  UnitHintCeator;

{$R *.dfm}

procedure TFormDBPreviewSize.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormDBPreviewSize.BtnOkClick(Sender: TObject);
var
  Settings: TSettings;
  Info: TEventValues;
begin
  Settings := FSettingsRepository.Get;
  try
    if Settings.ThSize <> FCollectionSettings.ThSize then
      FMediaRepository.RefreshImagesCache;

    FSettingsRepository.Update(FCollectionSettings);

    CollectionEvents.DoIDEvent(Self, 0, [EventID_Param_DB_Changed], Info);
  finally
    F(Settings);
  end;
  Close;
end;

procedure TFormDBPreviewSize.CbDBImageSizeChange(Sender: TObject);
begin
  FCollectionSettings.ThSize := Max(50, Min(500, StrToIntDef(CbDBImageSize.Text, 200)));
  UpdateDBSize;
end;

procedure TFormDBPreviewSize.CbDBJpegqualityChange(Sender: TObject);
begin
  FCollectionSettings.DBJpegCompressionQuality := Max(1, Min(100, StrToIntDef(CbDBJpegquality.Text, 75)));
  UpdateDBSize;
end;

procedure TFormDBPreviewSize.FillImageQuality(Combo: TComboBox);
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

procedure TFormDBPreviewSize.FillImageSize(Combo: TComboBox);
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
  Combo.Items.Add('500');
end;

procedure TFormDBPreviewSize.FormCreate(Sender: TObject);

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
  FSampleImage := GetBigPatternImage;
  FillImageSize(CbDBImageSize);
  FillImageQuality(CbDBJpegquality);
  LoadLanguage;

  LoadLinkIcon(WlPreviewDBSize, 'PICTURE');
  LoadLinkIcon(WlPreviewDBJpegQuality, 'PICTURE');
end;

procedure TFormDBPreviewSize.FormDestroy(Sender: TObject);
begin
  FSettingsRepository := nil;
  FMediaRepository := nil;
  FContext := nil;
  F(FSampleImage);
  F(FCollectionSettings);
end;

procedure TFormDBPreviewSize.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

function TFormDBPreviewSize.Execute(CollectionFileName: string): Boolean;
begin
  Result := False;

  FContext := TDBContext.Create(CollectionFileName);
  if FContext = nil then
    Exit;

  FMediaRepository := FContext.Media;
  FSettingsRepository := FContext.Settings;
  FCollectionSettings := FSettingsRepository.Get;

  Result := True;

  FMediaCount := FMediaRepository.GetCount;

  CbDBImageSize.Text := IntToStr(FCollectionSettings.ThSize);
  CbDBJpegquality.Text := IntToStr(FCollectionSettings.DBJpegCompressionQuality);
  CbDBImageSizeChange(Self);
  ShowModal;
end;

function TFormDBPreviewSize.GetFormID: string;
begin
  Result := 'DBPreviewSettings';
end;

function TFormDBPreviewSize.HintCheck(Info: TMediaItem): Boolean;
begin
  Result := True;
end;

procedure TFormDBPreviewSize.LoadLanguage;
begin
  Caption := L('Preview settings');
  LbDBImageSize.Caption := L('Default thumbnail size in collection');
  LbDBImageQuality.Caption := L('Compression quality of images stored in the collection');
  WlPreviewDBSize.Text := L('Preview');
  WlPreviewDBJpegQuality.Text := L('Preview');
  BtnOk.Caption := L('OK');
  BtnCancel.Caption := L('Cancel');
end;

procedure TFormDBPreviewSize.ShowPreview(Graphic: TGraphic; Size: Int64);
var
  Info: TMediaItem;
  P: TPoint;
begin
  GetCursorPos(P);
  Info := TMediaItem.Create;
  Info.Image := TJpegImage.Create;
  Info.Image.Assign(Graphic);
  Info.Image.CompressionQuality := 100;
  if Graphic is TBitmap then
    Info.Image.Compress;

  Info.FileName := '?.JPEG';
  Info.Name := L('Preview');
  Info.FileSize := Size;
  THintManager.Instance.CreateHintWindow(Self, Info, P, HintCheck);
end;

procedure TFormDBPreviewSize.UpdateDBSize;
var
  JPEG: TJpegImage;
  ImageSize: Int64;
begin
  ImageSize := CalcJpegResampledSize(FSampleImage, FCollectionSettings.ThSize,
    FCollectionSettings.DBJpegCompressionQuality, JPEG);
  F(JPEG);

  LbSingleImageSize.Caption := Format(L('Image size: %s'), [SizeInText(ImageSize)]);
  LbDatabaseSize.Caption := Format(L('The size of new collection (approximately): %s'),
    [SizeInText(FMediaCount * ImageSize)]);
end;

procedure TFormDBPreviewSize.WlPreviewDBSizeClick(Sender: TObject);
var
  JPEG: TJpegImage;
  ImageSize: Int64;
begin
  ImageSize := CalcJpegResampledSize(FSampleImage, FCollectionSettings.ThSize,  FCollectionSettings.DBJpegCompressionQuality, JPEG);
  ShowPreview(JPEG, ImageSize);
  F(JPEG)
end;

initialization
  FormInterfaces.RegisterFormInterface(IFormCollectionPreviewSettings, TFormDBPreviewSize);

end.
