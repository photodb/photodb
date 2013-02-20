unit uWatermarkOptions;

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
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,

  Dmitry.Controls.WatermarkedEdit,

  uDBForm,
  uSettings, Vcl.ComCtrls;

const
  Settings_Watermark = 'Watermark settings';

type
  TFrmWatermarkOptions = class(TDBForm)
    BtnOk: TButton;
    BtnCancel: TButton;
    PcWatermarkType: TPageControl;
    TsText: TTabSheet;
    TsImage: TTabSheet;
    LbBlocksX: TLabel;
    LbTextColor: TLabel;
    LbBlocksY: TLabel;
    LbTransparency: TLabel;
    LbWatermarkText: TLabel;
    LbFontName: TLabel;
    CbColor: TColorBox;
    SeBlocksX: TSpinEdit;
    SeBlocksY: TSpinEdit;
    SeTransparency: TSpinEdit;
    EdWatermarkText: TWatermarkedEdit;
    CbFonts: TComboBox;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PcWatermarkTypeChange(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
    procedure SaveSettings;
    procedure LoadSettings;
  protected
    { Protected declarations }
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

procedure ShowWatermarkOptions;

implementation

procedure ShowWatermarkOptions;
var
  FrmWatermarkOptions: TFrmWatermarkOptions;
begin
  Application.CreateForm(TFrmWatermarkOptions, FrmWatermarkOptions);
  try
    FrmWatermarkOptions.ShowModal;
  finally
    FrmWatermarkOptions.Release;
  end;
end;

{$R *.dfm}

procedure TFrmWatermarkOptions.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmWatermarkOptions.BtnOkClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

procedure TFrmWatermarkOptions.FormCreate(Sender: TObject);
begin
  LoadLanguage;

  CbFonts.Items := Screen.Fonts;
  if CbFonts.Items.Count > 0 then
    CbFonts.ItemIndex := 0;
  LoadSettings;
end;

procedure TFrmWatermarkOptions.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BtnOkClick(Sender);
  if Key = VK_ESCAPE then
    Close;
end;

function TFrmWatermarkOptions.GetFormID: string;
begin
  Result := 'WatermarkOptions';
end;

procedure TFrmWatermarkOptions.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Watermark options');
    LbWatermarkText.Caption := L('Watermark text') + ':';
    EdWatermarkText.WatermarkText := L('Sample text');
    LbBlocksX.Caption := L('Blocks horizontally') + ':';
    LbBlocksY.Caption := L('Blocks vertically') + ':';
    LbTextColor.Caption := L('Text color') + ':';
    LbTransparency.Caption := L('Transparency') + ':';
    LbFontName.Caption := L('Font Name') + ':';
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
  finally
    EndTranslate;
  end;
end;

procedure TFrmWatermarkOptions.LoadSettings;
var
  I: Integer;
  FontName: string;
begin
  EdWatermarkText.Text := Settings.ReadString(Settings_Watermark, 'Text', L('Sample text'));
  SeBlocksX.Value := Settings.ReadInteger(Settings_Watermark, 'BlocksX', 3);
  SeBlocksY.Value := Settings.ReadInteger(Settings_Watermark, 'BlocksY', 3);
  CbColor.Selected := Settings.ReadInteger(Settings_Watermark, 'Color', clWhite);
  SeTransparency.Value := Settings.ReadInteger(Settings_Watermark, 'Transparency', 25);
  FontName := AnsiLowerCase(Settings.ReadString(Settings_Watermark, 'Font', 'Arial'));
  for I := 0 to CbFonts.Items.Count - 1 do
    if AnsiLowerCase(CbFonts.Items[I]) = FontName then
      CbFonts.ItemIndex := I;
end;

procedure TFrmWatermarkOptions.PcWatermarkTypeChange(Sender: TObject);
begin
  if PcWatermarkType.ActivePageIndex = 1 then
  begin

  end;
end;

procedure TFrmWatermarkOptions.SaveSettings;
begin
  Settings.WriteString(Settings_Watermark, 'Text', EdWatermarkText.Text);
  Settings.WriteInteger(Settings_Watermark, 'BlocksX', SeBlocksX.Value);
  Settings.WriteInteger(Settings_Watermark, 'BlocksY', SeBlocksY.Value);
  Settings.WriteInteger(Settings_Watermark, 'Color', CbColor.Selected);
  Settings.WriteInteger(Settings_Watermark, 'Transparency', SeTransparency.Value);
  Settings.WriteString(Settings_Watermark, 'Font', CbFonts.Items[CbFonts.ItemIndex]);
end;

end.
