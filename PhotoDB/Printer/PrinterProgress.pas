unit PrinterProgress;

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

  Dmitry.Controls.DmProgress,

  uDBForm,
  uShellIntegration;

type
  TFormPrinterProgress = class(TDBForm)
    PbPrinterProgress: TDmProgress;
    ImPrinter: TImage;
    BtnAbort: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnAbortClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    PValue: PBoolean;
    FCanClose: Boolean;
    procedure SetMaxValue(Value: Integer);
    procedure SetValue(Value: Integer);
    procedure SetText(Text: string);
    procedure SetLanguage;
  end;

function GetFormPrinterProgress : TFormPrinterProgress;

implementation

{$R *.dfm}

function GetFormPrinterProgress : TFormPrinterProgress;
begin
  Application.CreateForm(TFormPrinterProgress, Result);
end;

procedure TFormPrinterProgress.FormCreate(Sender: TObject);
begin
  Icon := ImPrinter.Picture.Icon;
  SetLanguage;
  DisableWindowCloseButton(Handle);
  FCanClose := False;
end;

function TFormPrinterProgress.GetFormID: string;
begin
  Result := 'PrinterProgress';
end;

procedure TFormPrinterProgress.SetMaxValue(Value: Integer);
begin
  PbPrinterProgress.MaxValue := Value;
end;

procedure TFormPrinterProgress.SetText(Text: string);
begin
  PbPrinterProgress.Text := Text;
end;

procedure TFormPrinterProgress.SetValue(Value: Integer);
begin
  PbPrinterProgress.Position := Value;
end;

procedure TFormPrinterProgress.BtnAbortClick(Sender: TObject);
begin
  BtnAbort.Enabled := False;
  PValue^ := True;
end;

procedure TFormPrinterProgress.SetLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Printing ...');
    BtnAbort.Caption := L('Abort');
    Label1.Caption := L('Please wait until done printing...');
  finally
    EndTranslate;
  end;
end;

procedure TFormPrinterProgress.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TFormPrinterProgress.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FCanClose;
end;

end.
