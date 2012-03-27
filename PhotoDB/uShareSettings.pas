unit uShareSettings;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  uMemoryEx,
  uDBForm,
  Vcl.StdCtrls,
  uBaseWinControl,
  WebLink,
  uAssociations,
  uTranslate,
  uSettings,
  Vcl.Samples.Spin;

type
  TFormShareSettings = class(TDBForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    CbOutputFormat: TComboBox;
    LbOutputFormat: TLabel;
    WlJpegSettings: TWebLink;
    CbPreviewForRAW: TCheckBox;
    CbImageSize: TComboBox;
    SeWidth: TSpinEdit;
    LbWidth: TLabel;
    LbHeight: TLabel;
    SeHeight: TSpinEdit;
    CbResizeToSize: TCheckBox;
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WlJpegSettingsClick(Sender: TObject);
    procedure CbImageSizeChange(Sender: TObject);
    procedure CbResizeToSizeClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure LoadSettings;
    procedure SaveSettings;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
  end;

function ShowShareSettings: Boolean;

implementation

uses
  UnitJPEGOptions;

{$R *.dfm}

function ShowShareSettings: Boolean;
var
  FormShareSettings: TFormShareSettings;
begin
  FormShareSettings := TFormShareSettings.Create(Screen.ActiveForm);
  try
    FormShareSettings.ShowModal;
    Result := FormShareSettings.ModalResult = mrOk;
  finally
    R(FormShareSettings);
  end;
end;

procedure TFormShareSettings.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormShareSettings.BtnOkClick(Sender: TObject);
begin
  SaveSettings;
  Close;
  ModalResult := mrOk;
end;

procedure TFormShareSettings.CbImageSizeChange(Sender: TObject);
begin
  SeWidth.Enabled := CbImageSize.Enabled and (CbImageSize.ItemIndex = CbImageSize.Items.Count - 1);
  SeHeight.Enabled := SeWidth.Enabled;

  case CbImageSize.ItemIndex of
    0:
      begin
        SeWidth.Value := 1920;
        SeHeight.Value := 1080;
      end;
    1:
      begin
        SeWidth.Value := 1280;
        SeHeight.Value := 720;
      end;
    2:
      begin
        SeWidth.Value := 1024;
        SeHeight.Value := 768;
      end;
    3:
      begin
        SeWidth.Value := 800;
        SeHeight.Value := 600;
      end;
    4:
      begin
        SeWidth.Value := 640;
        SeHeight.Value := 480;
      end;
  end;
end;

procedure TFormShareSettings.CbResizeToSizeClick(Sender: TObject);
begin
  CbImageSize.Enabled := CbResizeToSize.Checked;
  CbImageSizeChange(Sender);
end;

procedure TFormShareSettings.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  LoadSettings;
end;

function TFormShareSettings.GetFormID: string;
begin
  Result := 'PhotoShare';
end;

procedure TFormShareSettings.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Share settings');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    LbOutputFormat.Caption := L('Output format') + ':';
    WlJpegSettings.Text := L('JPEG settings');
    CbResizeToSize.Caption := L('Resize images') + ':';
    LbWidth.Caption := L('Width');
    LbHeight.Caption := L('Height');
    CbPreviewForRAW.Caption := L('Try to use preview image for RAW images');
    SeWidth.Left := LbWidth.Left + LbWidth.Width + 5;
    LbHeight.Left := SeWidth.Left + SeWidth.Width + 5;
    SeHeight.Left := LbHeight.Left + LbHeight.Width + 5;
  finally
    EndTranslate;
  end;
end;

procedure TFormShareSettings.LoadSettings;
var
  FormatIndex, SizeIndex: Integer;
begin
  CbOutputFormat.Items.Add(TA(TFileAssociations.Instance.Exts['.jpg'].Description, 'Associations'));
  CbOutputFormat.Items.Add(TA(TFileAssociations.Instance.Exts['.png'].Description, 'Associations'));
  CbOutputFormat.ItemIndex := 0;

  FormatIndex := Settings.ReadInteger('Share', 'ImageFormat', 0);
  if FormatIndex = 1 then
    CbOutputFormat.ItemIndex := 1;

  CbResizeToSize.Checked := Settings.ReadBool('Share', 'ResizeImage', True);
  CbResizeToSizeClick(Self);

  CbImageSize.Items.Add(L('Full HD (1920x1080)'));
  CbImageSize.Items.Add(L('HD (1280x720)'));
  CbImageSize.Items.Add(L('Big (1024x768)'));
  CbImageSize.Items.Add(L('Medium (800x600)'));
  CbImageSize.Items.Add(L('Small (640x480)'));
  CbImageSize.Items.Add(L('Custom size:'));
  CbImageSize.ItemIndex := 0;

  SizeIndex := Settings.ReadInteger('Share', 'ImageSize', 0);
  if (SizeIndex > -1) and (SizeIndex < CbImageSize.Items.Count)  then
    CbImageSize.ItemIndex := SizeIndex;

  CbPreviewForRAW.Checked := Settings.ReadBool('Share', 'RAWPreview', True);

  SeWidth.Value := Settings.ReadInteger('Share', 'ImageWidth', 1920);
  SeHeight.Value := Settings.ReadInteger('Share', 'ImageHeight', 1080);
end;

procedure TFormShareSettings.SaveSettings;
begin
  Settings.WriteInteger('Share', 'ImageFormat', CbOutputFormat.ItemIndex);
  Settings.WriteBool('Share', 'ResizeImage', CbResizeToSize.Checked);
  Settings.WriteInteger('Share', 'ImageSize', CbImageSize.ItemIndex);

  Settings.WriteBool('Share', 'RAWPreview', CbPreviewForRAW.Checked);

  Settings.WriteInteger('Share', 'ImageWidth', SeWidth.Value);
  Settings.WriteInteger('Share', 'ImageHeight', SeHeight.Value);
end;

procedure TFormShareSettings.WlJpegSettingsClick(Sender: TObject);
begin
  SetJPEGOptions('ShareImages');
end;

end.
