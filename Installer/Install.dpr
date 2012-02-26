program Install;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$SetPEFlags 1}// 1 = Windows.IMAGE_FILE_RELOCS_STRIPPED

uses
  Forms,
  Windows,
  SysUtils,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uInstallUtils in 'uInstallUtils.pas',
  uFrmLanguage in 'uFrmLanguage.pas' {FormLanguage},
  uInstallTypes in 'uInstallTypes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uDBForm in '..\PhotoDB\Units\uDBForm.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uFrmProgress in 'uFrmProgress.pas' {FrmProgress},
  uInstallFrame in 'uInstallFrame.pas' {InstallFrame: TFrame},
  uFrLicense in 'uFrLicense.pas' {FrmLicence: TFrame},
  uFrAdvancedOptions in 'uFrAdvancedOptions.pas' {FrmAdvancedOptions: TFrame},
  uFormUtils in '..\PhotoDB\Units\uFormUtils.pas',
  uInstallThread in 'uInstallThread.pas',
  uGOM in '..\PhotoDB\Units\uGOM.pas',
  uInstallActions in 'uInstallActions.pas',
  uVistaFuncs in '..\PhotoDB\Units\uVistaFuncs.pas',
  UnitDBFileDialogs in '..\PhotoDB\Units\UnitDBFileDialogs.pas',
  uInstallScope in 'uInstallScope.pas',
  uUninstallTypes in 'uUninstallTypes.pas',
  uUninstall in 'uUninstall.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  UnitINI in '..\PhotoDB\Units\UnitINI.pas',
  uShellUtils in 'uShellUtils.pas',
  uInstallZip in 'uInstallZip.pas',
  uDBBaseTypes in '..\PhotoDB\Units\uDBBaseTypes.pas',
  uAssociations in 'uAssociations.pas',
  uInstallSteps in 'uInstallSteps.pas',
  uSteps in 'uSteps.pas',
  uActions in 'uActions.pas',
  uAssociationActions in 'uAssociationActions.pas',
  uUpdatingWindowsActions in 'uUpdatingWindowsActions.pas',
  uRuntime in '..\PhotoDB\Units\uRuntime.pas',
  uInstallProcess in 'uInstallProcess.pas',
  uSetupDatabaseActions in 'uSetupDatabaseActions.pas',
  uStringUtils in '..\PhotoDB\Units\uStringUtils.pas',
  uLangUtils in 'uLangUtils.pas',
  uImageSource in '..\PhotoDB\Units\uImageSource.pas',
  uUserUtils in 'uUserUtils.pas',
  uAppUtils in '..\PhotoDB\Units\uAppUtils.pas',
  uIME in '..\PhotoDB\Units\uIME.pas',
  uIsAdmin in 'uIsAdmin.pas',
  uInstallRuntime in 'uInstallRuntime.pas',
  uConfiguration in '..\PhotoDB\Units\uConfiguration.pas',
  uTime in '..\PhotoDB\Units\uTime.pas',
  MSXML2_TLB in '..\PhotoDB\Units\MSXML2_TLB.pas',
  uStillImage in 'uStillImage.pas';

{$R SETUP_ZIP.res}
{$R *.res}
{$R ..\PhotoDB\Resources\Install.res}
{$R InstallMain.res}

begin
  Application.Initialize;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormLanguage, FormLanguage);
  try
    FormLanguage.ShowModal;
    if idOk <> FormLanguage.ModalResult then
      Exit;
  finally
    F(FormLanguage);
  end;

  if not (IsUserAnAdmin or IsWindowsAdmin) then
  begin
    MessageBox(0, PChar(TA('Please start this program using account with administrator rights!', 'Setup')), 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
