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
  uAssociations,
  uVistaFuncs;

type
  TFrUninstall = class(TInstallFrame)
    cbYesUninstall: TCheckBox;
    GbUninstallOptions: TGroupBox;
    CbDeleteAllRegisteredCollection: TCheckBox;
    CbUnInstallAllUserSettings: TCheckBox;
    procedure YesUninstallClick(Sender: TObject);
    procedure CbDeleteAllRegisteredCollectionClick(Sender: TObject);
  private
    FDeletingColectionBlockWarning: Boolean;
    { Private declarations }
  public
    { Public declarations }
    procedure Init; override;
    procedure LoadLanguage; override;
    function ValidateFrame: Boolean; override;
    procedure InitInstall; override;
  end;

implementation

{$R *.dfm}

{ TFrLicense }

procedure TFrUninstall.YesUninstallClick(Sender: TObject);
begin
  CbUnInstallAllUserSettings.Enabled := cbYesUninstall.Checked;
  CbDeleteAllRegisteredCollection.Enabled := cbYesUninstall.Checked;
  FrameChanged;
end;

procedure TFrUninstall.CbDeleteAllRegisteredCollectionClick(Sender: TObject);
begin
  if FDeletingColectionBlockWarning then
    Exit;

  FDeletingColectionBlockWarning := True;
  try
    if ID_YES <> TaskDialogEx(0, L('Do you really want to delete all collection files (*.photodb)?'), TA('Warning'), '', TD_BUTTON_YESNO,
      TD_ICON_WARNING, False) then
      CbDeleteAllRegisteredCollection.Checked := False;
  finally
    FDeletingColectionBlockWarning := False;
  end;
end;

procedure TFrUninstall.Init;
begin
  inherited;
  FDeletingColectionBlockWarning := False;
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
  CurrentInstall.UninstallOptions.DeleteAllCollections := CbDeleteAllRegisteredCollection.Checked;
end;

procedure TFrUninstall.LoadLanguage;
begin
  inherited;
  cbYesUninstall.Caption := L('Yes, I want to uninstall this program');
  CbUnInstallAllUserSettings.Caption := L('Delete all user settings');
  CbDeleteAllRegisteredCollection.Caption := L('Delete all registered collections');
  GbUninstallOptions.Caption := L('Uninstall options');
end;

function TFrUninstall.ValidateFrame: Boolean;
begin
  Result := cbYesUninstall.Checked;
end;

end.
