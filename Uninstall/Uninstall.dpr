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
  uLogger in '..\PhotoDB\Units\System\uLogger.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uMemory in '..\PhotoDB\Units\System\uMemory.pas',
  uMemoryEx in '..\PhotoDB\Units\System\uMemoryEx.pas',
  uFormUtils in '..\PhotoDB\Units\Utils\uFormUtils.pas',
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
  uRuntime in '..\PhotoDB\Units\System\uRuntime.pas',
  uGOM in '..\PhotoDB\Units\System\uGOM.pas',
  uUninstallProcess in 'uUninstallProcess.pas',
  uStringUtils in '..\PhotoDB\Units\Utils\uStringUtils.pas',
  uActivationUtils in '..\PhotoDB\Units\Utils\uActivationUtils.pas',
  uIsAdmin in '..\Installer\uIsAdmin.pas',
  uInstallUtils in '..\Installer\uInstallUtils.pas',
  uAppUtils in '..\PhotoDB\Units\Utils\uAppUtils.pas',
  uIME in '..\PhotoDB\Units\System\uIME.pas',
  uUserUtils in '..\Installer\uUserUtils.pas',
  uConfiguration in '..\PhotoDB\Units\uConfiguration.pas',
  uTime in '..\PhotoDB\Units\System\uTime.pas',
  MSXML2_TLB in '..\PhotoDB\Units\MSXML2_TLB.pas',
  uStillImage in '..\Installer\uStillImage.pas',
  uSettings in '..\PhotoDB\Units\uSettings.pas',
  uUpTime in '..\PhotoDB\Units\System\uUpTime.pas',
  uXMLUtils in '..\PhotoDB\Units\Utils\uXMLUtils.pas',
  uUninstallCurrentUser in 'uUninstallCurrentUser.pas',
  uThemesUtils in '..\PhotoDB\Units\Utils\uThemesUtils.pas',
  uProgramStatInfo in '..\PhotoDB\Units\System\uProgramStatInfo.pas',
  uFormBusyApplications in '..\Installer\uFormBusyApplications.pas' {FormBusyApplications},
  uIconUtils in '..\PhotoDB\Units\Utils\uIconUtils.pas',
  uInstallCloseRelatedApplications in '..\Installer\uInstallCloseRelatedApplications.pas';

{$R *.res}
{$R Commands.res}
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

  If ID_YES = TaskDialog(0, TA('Do you really want to delete Photo Database 4.5?', 'System'), TA('Warning'), '', TD_BUTTON_YESNO, TD_ICON_WARNING) then
  begin
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
  end;
end.
