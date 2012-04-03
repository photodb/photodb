unit uFrUninstall;

interface

{$WARN SYMBOL_PLATFORM OFF}

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
  uInstallFrame,
  uInstallUtils,
  uTranslate,
  uMemory,
  uConstants,
  uInstallScope,
  uAssociations;

type
  TFrUninstall = class(TInstallFrame)
    cbYesUninstall: TCheckBox;
    CbUnInstallAllUserSettings: TCheckBox;
    CbDeleAllRegisteredCollection: TCheckBox;
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
    TFileAssociations.Instance[I].State := TAS_UNINSTALL;

  CurrentInstall.DestinationPath := IncludeTrailingBackslash(ExtractFileDir(GetInstalledFileName));
  CurrentInstall.UninstallOptions.DeleteUserSettings := CbUnInstallAllUserSettings.Checked;
  CurrentInstall.UninstallOptions.DeleteAllCollections := CbDeleAllRegisteredCollection.Checked;
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
