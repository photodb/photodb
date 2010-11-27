unit uFrUninstall;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uInstallFrame, uInstallUtils, uTranslate,
  uMemory, uConstants;

type
  TFrUninstall = class(TInstallFrame)
    cbYesUninstall: TCheckBox;
    procedure YesUninstallClick(Sender: TObject);
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

procedure TFrUninstall.YesUninstallClick(Sender: TObject);
begin
  FrameChanged;
end;

procedure TFrUninstall.Init;
begin
  inherited;
  cbYesUninstall.OnClick := YesUninstallClick;
end;

procedure TFrUninstall.LoadLanguage;
begin
  inherited;
  cbYesUninstall.Caption := L('Yes, I want to uninstall this program');
end;

function TFrUninstall.ValidateFrame: Boolean;
begin
  Result := cbYesUninstall.Checked;
end;

end.
