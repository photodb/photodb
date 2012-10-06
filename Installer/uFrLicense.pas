unit uFrLicense;

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
  uInstallFrame,
  uInstallUtils,
  uTranslate,
  uInstallZip,
  uMemory,
  uConstants;

type
  TFrLicense = class(TInstallFrame)
    MemLicense: TMemo;
    CbAcceptLicenseAgreement: TCheckBox;
    procedure CbAcceptLicenseAgreementClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Init; override;
    procedure LoadLanguage; override;
    function ValidateFrame : Boolean; override;
  end;

implementation

{$R *.dfm}

{ TFrLicense }

procedure TFrLicense.CbAcceptLicenseAgreementClick(Sender: TObject);
begin
  FrameChanged;
end;

procedure TFrLicense.Init;
var
  MS : TMemoryStream;
  LicenceFileName : string;
begin
  inherited;
  MS := TMemoryStream.Create;
  try
    LicenceFileName := Format('%s%s.txt', ['License', TTranslatemanager.Instance.Language]);
    GetRCDATAResourceStream(SetupDataName, MS);
    MemLicense.Text := ReadFileContent(MS, LicenceFileName);
  finally
    F(MS);
  end;
end;

procedure TFrLicense.LoadLanguage;
begin
  inherited;
  CbAcceptLicenseAgreement.Caption := L('I accept license agreement');
end;

function TFrLicense.ValidateFrame: Boolean;
begin
  Result := CbAcceptLicenseAgreement.Checked;
end;

end.
