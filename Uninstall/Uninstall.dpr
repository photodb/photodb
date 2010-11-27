program Uninstall;

uses
  Forms,
  uFrmMain in '..\Installer\uFrmMain.pas' {FrmMain},
  uFrmProgress in '..\Installer\uFrmProgress.pas' {FrmProgress},
  uDBForm in '..\PhotoDB\Units\uDBForm.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  MSXML2_TLB in '..\PhotoDB\External\Xml\MSXML2_TLB.pas',
  OmniXML_MSXML in '..\PhotoDB\External\Xml\OmniXML_MSXML.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  uFileUtils in '..\PhotoDB\Units\uFileUtils.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  VRSIShortCuts in '..\PhotoDB\Units\VRSIShortCuts.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uFormUtils in '..\PhotoDB\Units\uFormUtils.pas',
  uInstallUtils in '..\Installer\uInstallUtils.pas',
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
  uFrUninstall in 'uFrUninstall.pas' {FrUninstall: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
