unit UnitJPEGOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Dolphin_DB,
  Language;

type
 TDBJPEGOptions = record
 ProgressiveMode : boolean;
 Compression : integer;
 end;

type
  TFormJpegOptions = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Image1: TImage;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    TrackBar1: TTrackBar;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
  FSection : String;
    { Private declarations }
  public
  procedure LoadLanguage;
  procedure SetSection(Section : String);
  procedure Execute(Section : String);
    { Public declarations }
  end;

procedure SetJPEGOptions; overload;
procedure SetJPEGOptions(Section : String); overload;

implementation

{$R *.dfm}

procedure SetJPEGOptions;
var
  FormJpegOptions: TFormJpegOptions;
begin
  Application.CreateForm(TFormJpegOptions, FormJpegOptions);
  FormJpegOptions.Execute('');
  FormJpegOptions.Release;
end;

procedure SetJPEGOptions(Section: string);
var
  FormJpegOptions: TFormJpegOptions;
begin
  Application.CreateForm(TFormJpegOptions, FormJpegOptions);
  FormJpegOptions.Execute(Section);
  FormJpegOptions.Release;
end;

procedure TFormJpegOptions.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  DBKernel.RecreateThemeToForm(Self);
end;

procedure TFormJpegOptions.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

procedure TFormJpegOptions.CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormJpegOptions.TrackBar1Change(Sender: TObject);
begin
  Label1.Caption := Format(TEXT_MES_JPEG_COMPRESS, [TrackBar1.Position * 5]);
end;

procedure TFormJpegOptions.OKClick(Sender: TObject);
begin
  DBKernel.WriteInteger(FSection, 'JPEGCompression', TrackBar1.Position * 5);
  DBKernel.WriteBool(FSection, 'JPEGProgressiveMode', CheckBox1.Checked);
  DBKernel.WriteInteger(FSection, 'JPEGOptimizeSize', StrToIntDef(Edit1.Text, 100));
  DBKernel.WriteBool(FSection, 'JPEGOptimizeMode', CheckBox2.Checked);
  Close;
end;

procedure TFormJpegOptions.LoadLanguage;
begin
  Caption := TEXT_MES_JPEG_CAPTION;
  Label2.Caption := TEXT_MES_JPEG_INFO;
  GroupBox1.Caption := TEXT_MES_JPEG;
  TrackBar1Change(Self);
  CheckBox1.Caption := TEXT_MES_JPEG_PROGRESSIVE_MODE;
  Cancel.Caption := TEXT_MES_CANCEL;
  Ok.Caption := TEXT_MES_OK;
  CheckBox2.Caption := TEXT_MES_OPTIMIZE_TO_FILE_SIZE;
  Label3.Caption := TEXT_MES_KB;
end;

procedure TFormJpegOptions.SetSection(Section: String);
begin
  FSection := Section;
end;

procedure TFormJpegOptions.Execute(Section: String);
begin
  SetSection(Section);
  TrackBar1.Position := DBKernel.ReadInteger(FSection, 'JPEGCompression', 75) div 5;
  CheckBox1.Checked := DBKernel.ReadBool(FSection, 'JPEGProgressiveMode', False);
  Edit1.Text := IntToStr(DBKernel.ReadInteger(FSection, 'JPEGOptimizeSize', 100));
  CheckBox2.Checked := DBKernel.ReadBool(FSection, 'JPEGOptimizeMode', False);
  CheckBox2Click(nil);
  ShowModal;
end;

procedure TFormJpegOptions.CheckBox2Click(Sender: TObject);
begin
  Edit1.Enabled := CheckBox2.Checked;
  TrackBar1.Enabled := not CheckBox2.Checked;
end;

procedure TFormJpegOptions.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    OKClick(Sender);
end;

end.
