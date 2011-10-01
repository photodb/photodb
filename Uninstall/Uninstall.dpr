program Uninstall;

{ Reduce EXE size by disabling as much of RTTI as possible (delphi 2009/2010) }
{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$SetPEFlags 1}// 1 = Windows.IMAGE_FILE_RELOCS_STRIPPED

uses
  Forms,
  Windows,
  uFrmMain in '..\Installer\uFrmMain.pas' {FrmMain},
  uFrmProgress in '..\Installer\uFrmProgress.pas' {FrmProgress},
  uDBForm in '..\PhotoDB\Units\uDBForm.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  VRSIShortCuts in '..\PhotoDB\Units\VRSIShortCuts.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uFormUtils in '..\PhotoDB\Units\uFormUtils.pas',
  uInstallTypes in '..\Installer\uInstallTypes.pas',
  uInstallScope in '..\Installer\uInstallScope.pas',
  UnitINI in '..\PhotoDB\Units\UnitINI.pas',
  uShellUtils in '..\Installer\uShellUtils.pas',
  uDBBaseTypes in '..\PhotoDB\Units\uDBBaseTypes.pas',
  uAssociations in '..\Installer\uAssociations.pas',
  uVistaFuncs in '..\PhotoDB\Units\uVistaFuncs.pas',
  uInstallFrame in '..\Installer\uInstallFrame.pas' {InstallFrame: TFrame},
  uSteps in '..\Installer\uSteps.pas',
  uInstallThread in '..\Installer\uInstallThread.pas',
  uActions in '..\Installer\uActions.pas',
  uUninstallSteps in 'uUninstallSteps.pas',
  uFrUninstall in 'uFrUninstall.pas' {FrUninstall: TFrame},
  uUninstallActions in 'uUninstallActions.pas',
  uAssociationActions in '..\Installer\uAssociationActions.pas',
  uUpdatingWindowsActions in '..\Installer\uUpdatingWindowsActions.pas',
  uSelfDeleteAction in 'uSelfDeleteAction.pas',
  uRuntime in '..\PhotoDB\Units\uRuntime.pas',
  uGOM in '..\PhotoDB\Units\uGOM.pas',
  uUninstallProcess in 'uUninstallProcess.pas',
  uStringUtils in '..\PhotoDB\Units\uStringUtils.pas',
  uActivationUtils in '..\PhotoDB\Units\uActivationUtils.pas',
  uImageSource in '..\PhotoDB\Units\uImageSource.pas',
  uIsAdmin in '..\Installer\uIsAdmin.pas',
  uInstallUtils in '..\Installer\uInstallUtils.pas',
  uAppUtils in '..\PhotoDB\Units\uAppUtils.pas',
  uIME in '..\PhotoDB\Units\uIME.pas',
  uUserUtils in '..\Installer\uUserUtils.pas',
  uConfiguration in '..\PhotoDB\Units\uConfiguration.pas';

{$R *.res}
{$R ..\PhotoDB\Resources\Install.res}

begin
  if not GetParamStrDBBool('/admin') then
  begin
    UserAccountService(ParamStr(0), IsUserAnAdmin or IsWindowsAdmin);
    Exit;
  end;

  if not (IsUserAnAdmin or IsWindowsAdmin) then
  begin
    MessageBox(0, 'Please start this program using account with administrator rights!', 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  Application.Initialize;

  If ID_YES = TaskDialogEx(0, TA('Do you really want to delete Photo Database 2.3?', 'System'), TA('Warning'), '', TD_BUTTON_YESNO,
    TD_ICON_WARNING, False) then
  begin
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
  end;
end.
