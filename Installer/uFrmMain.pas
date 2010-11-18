unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ZLib, pngimage, ExtCtrls, uDBForm, StdCtrls, WatermarkedEdit,
  uFrmProgress;

type
  TFrmMain = class(TDBForm)
    Image1: TImage;
    BtnNext: TButton;
    BtnCancel: TButton;
    Label1: TLabel;
    Bevel1: TBevel;
    BtnInstall: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CbAcceptLicenseAgreementClick(Sender: TObject);
    procedure BtnInstallClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  uFrmLanguage;

{ TFrmMain }

procedure TFrmMain.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.BtnInstallClick(Sender: TObject);
var
  FrmProgress: TFrmProgress;
begin
  Application.CreateForm(TFrmProgress, FrmProgress);
  Hide;
  FrmProgress.Show;
 //TODO:
end;

procedure TFrmMain.CbAcceptLicenseAgreementClick(Sender: TObject);
begin
//  BtnNext.Enabled := CbAcceptLicenseAgreement.Checked;
//  BtnInstall.Enabled := CbAcceptLicenseAgreement.Checked;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  LoadLanguage;
end;

function TFrmMain.GetFormID: string;
begin
  Result := 'Setup';
end;

procedure TFrmMain.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('PhotoDB 2.3 Setup');
    BtnCancel.Caption := L('Cancel');
    BtnNext.Caption := L('Next');
    BtnInstall.Caption := L('Install');
  finally
    EndTranslate;
  end;
end;

end.
