unit UnitJPEGOptions;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  uDBForm,
  JPEG,
  uSettings,
  pngimage,
  uFormInterfaces;

type
  TDBJPEGOptions = record
    ProgressiveMode: Boolean;
    Compression: Integer;
  end;

type
  TFormJpegOptions = class(TDBForm, IJpegOptionsForm)
    BtOK: TButton;
    BtCancel: TButton;
    Image1: TImage;
    LbInfo: TLabel;
    GbJPEGOption: TGroupBox;
    TbCompressionRate: TTrackBar;
    CbProgressiveMove: TCheckBox;
    lbCompressionRate: TLabel;
    CbOptimizeToSize: TCheckBox;
    Edit1: TEdit;
    LbKb: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure TbCompressionRateChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure CbOptimizeToSizeClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FSection: string;
    procedure SetSection(Section: string);
  protected
    { Protected declarations }
    function GetFormID: string; override;
    procedure LoadLanguage;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    procedure Execute(Section: string);
  end;

implementation

{$R *.dfm}

procedure TFormJpegOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TFormJpegOptions.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  TbCompressionRateChange(Self);
end;

procedure TFormJpegOptions.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

function TFormJpegOptions.GetFormID: string;
begin
  Result := 'JPEG';
end;

procedure TFormJpegOptions.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TFormJpegOptions.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormJpegOptions.TbCompressionRateChange(Sender: TObject);
begin
  lbCompressionRate.Caption := Format(L('JPEG compression (%d%%):'), [TbCompressionRate.Position * 5]);
end;

procedure TFormJpegOptions.BtOKClick(Sender: TObject);
begin
  AppSettings.WriteInteger(FSection, 'JPEGCompression', TbCompressionRate.Position * 5);
  AppSettings.WriteBool(FSection, 'JPEGProgressiveMode', CbProgressiveMove.Checked);
  AppSettings.WriteInteger(FSection, 'JPEGOptimizeSize', StrToIntDef(Edit1.Text, 100));
  AppSettings.WriteBool(FSection, 'JPEGOptimizeMode', CbOptimizeToSize.Checked);
  Close;
end;

procedure TFormJpegOptions.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('JPEG compression');
    LbInfo.Caption := L('Choose JPEG mode and compression rate') + ':';
    GbJPEGOption.Caption := L('JPEG');
    CbProgressiveMove.Caption := L('Progressive mode');
    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('Ok');
    CbOptimizeToSize.Caption := L('Optimize to size') + ':';
    LbKb.Caption := L('Kb');
  finally
    EndTranslate;
  end;
end;

procedure TFormJpegOptions.SetSection(Section: String);
begin
  FSection := Section;
end;

procedure TFormJpegOptions.Execute(Section: String);
begin
  SetSection(Section);
  TbCompressionRate.Position := AppSettings.ReadInteger(FSection, 'JPEGCompression', 75) div 5;
  CbProgressiveMove.Checked := AppSettings.ReadBool(FSection, 'JPEGProgressiveMode', False);
  Edit1.Text := IntToStr(AppSettings.ReadInteger(FSection, 'JPEGOptimizeSize', 100));
  CbOptimizeToSize.Checked := AppSettings.ReadBool(FSection, 'JPEGOptimizeMode', False);
  CbOptimizeToSizeClick(nil);
  ShowModal;
end;

procedure TFormJpegOptions.CbOptimizeToSizeClick(Sender: TObject);
begin
  Edit1.Enabled := CbOptimizeToSize.Checked;
  TbCompressionRate.Enabled := not CbOptimizeToSize.Checked;
end;

procedure TFormJpegOptions.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    BtOKClick(Sender);
end;

initialization
  FormInterfaces.RegisterFormInterface(IJpegOptionsForm, TFormJpegOptions);

end.
