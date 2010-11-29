unit uFrUninstall;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uInstallFrame, uInstallUtils, uTranslate,
  uMemory, uConstants, uInstallScope, uAssociations;

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
    procedure InitInstall; override;
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
  CurrentInstall.IsUninstall := True;
end;

procedure TFrUninstall.InitInstall;
var
  I: Integer;
begin
  inherited;
  for I := 0 to TFileAssociations.Instance.Count - 1 do
    TFileAssociations.Instance[I].State := TAS_IGNORE;

  CurrentInstall.DestinationPath := IncludeTrailingBackslash(ExtractFileDir(GetInstalledFileName));
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
