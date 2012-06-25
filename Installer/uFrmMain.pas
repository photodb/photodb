unit uFrmMain;

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
  ZLib,
  pngimage,
  ExtCtrls,
  uDBForm,
  StdCtrls,
  WatermarkedEdit,
  uInstallTypes,
  uInstallUtils,
  uMemory,
  uConstants,
  uRuntime,
  uVistaFuncs,
  uInstallScope,
  Registry,
  uShellUtils,
  uSteps,
  uSysUtils,
  uDBBaseTypes,
{$IFDEF INSTALL}
  uInstallSteps,
  uInstallRuntime,
{$ENDIF}
{$IFDEF UNINSTALL}
  uUninstallSteps,
{$ENDIF}
  uFrmProgress;

type
  TFrmMain = class(TDBForm)
    ImMain: TImage;
    BtnNext: TButton;
    BtnCancel: TButton;
    LbWelcome: TLabel;
    Bevel1: TBevel;
    BtnInstall: TButton;
    BtnPrevious: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnInstallClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPreviousClick(Sender: TObject);
  private
    { Private declarations }
    FrmProgress: TFrmProgress;
    FInstallType : TInstallSteps;
    procedure LoadLanguage;
    procedure LoadMainImage;
    procedure StepsChanged(Sender: TObject);
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    function UpdateProgress(Position, Total: Int64): Boolean;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  uInstallThread;

{ TFrmMain }

procedure TFrmMain.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.BtnInstallClick(Sender: TObject);
{$IFDEF INSTALL}
var
  InstalledVersion: TRelease;
{$ENDIF}
begin
{$IFDEF INSTALL}
  if IsApplicationInstalled then
  begin
    InstalledVersion := GetExeVersion(GetInstalledFileName);
    if IsNewRelease(InstallVersion, InstalledVersion) then
      if ID_Yes <> TaskDialogEx(Handle, Format(L('Newer version (%s) is already installed! Do you want to install old version (%s)?'), [ReleaseToString(InstalledVersion), ReleaseToString(InstallVersion)]), L('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING, False) then
        Exit;
  end;
{$ENDIF}

  FInstallType.PrepaireInstall;
  Application.CreateForm(TFrmProgress, FrmProgress);
  Hide;
  FrmProgress.Show;
  FrmProgress.Progress := 0;
  TInstallThread.Create(Self);
end;

procedure TFrmMain.BtnNextClick(Sender: TObject);
begin
  FInstallType.NextStep;
end;

procedure TFrmMain.BtnPreviousClick(Sender: TObject);
begin
  FInstallType.PreviousStep;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  hSemaphore: THandle;
begin
  FrmProgress := nil;
  hSemaphore := CreateSemaphore( nil, 0, 1, PWideChar(DBID));
  if ((hSemaphore <> 0) and (GetLastError = ERROR_ALREADY_EXISTS)) then
    TaskDialogEx(Handle, L('Program is started! Install will close the program during installation process!'), L('Warning'), '', TD_BUTTON_OK, TD_ICON_WARNING, False);

  LoadMainImage;
  LoadLanguage;
{$IFDEF INSTALL}
  if IsApplicationInstalled then
    FInstallType := TUpdatePreviousVersion.Create
  else
    FInstallType := TFreshInstall.Create;
{$ENDIF}

{$IFDEF UNINSTALL}
  FInstallType := TUninstall_V3_X.Create;
{$ENDIF}

  FInstallType.OnChange := StepsChanged;
  FInstallType.Start(Self, 190, 5);
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  F(FInstallType);
end;

function TFrmMain.GetFormID: string;
begin
  Result := 'Setup';
end;

procedure TFrmMain.LoadLanguage;
{$IFDEF INSTALL}
var
  S: string;
{$ENDIF}
begin
  BeginTranslate;
  try
{$IFDEF INSTALL}
    S := L('PhotoDB 3.1 Setup');
    if IsApplicationInstalled then
      S := S + ' (' + L('Update') + ' ' + ReleaseToString(InstallVersion) + ')';
    Caption := S;
{$ENDIF}
{$IFDEF UNINSTALL}
    Caption := L('PhotoDB 3.1 Uninstall');
{$ENDIF}
    BtnCancel.Caption := L('Cancel');
    BtnNext.Caption := L('Next');
    BtnPrevious.Caption := L('Previous');

{$IFDEF INSTALL}
    BtnInstall.Caption := L('Install');
{$ENDIF}
{$IFDEF UNINSTALL}
    BtnInstall.Caption := L('Uninstall');
{$ENDIF}
    LbWelcome.Caption := L('Welcome to the Photo Database 3.1');
  finally
    EndTranslate;
  end;
end;

procedure TFrmMain.LoadMainImage;
var
  MS: TMemoryStream;
  Png: TPngImage;
begin
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream('Image', MS);
    Png := TPngImage.Create;
    try
      MS.Seek(0, soFromBeginning);
      Png.LoadFromStream(MS);
      ImMain.Picture.Graphic := Png;
    finally
      F(Png);
    end;
  finally
    F(MS);
  end;
end;

procedure TFrmMain.StepsChanged(Sender: TObject);
begin
  BtnNext.Visible := not FInstallType.CanPrevious;
  BtnNext.Enabled := FInstallType.CanNext;
  BtnPrevious.Visible := FInstallType.CanPrevious;
  BtnInstall.Enabled := FInstallType.CanInstall;
end;

function TFrmMain.UpdateProgress(Position, Total: Int64): Boolean;
begin
  FrmProgress.Progress := Round((Position * 255) / Total);
  Result := True;
end;

end.
