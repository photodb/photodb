program PhotoDBInstall;

uses
  FastMM4 in '..\PhotoDB\External\FastMM\FastMM4.pas',
  FastMM4Messages in '..\PhotoDB\External\FastMM\FastMM4Messages.pas',
  Forms,
  Windows,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uInstallUtils in 'uInstallUtils.pas',
  uFrmLanguage in 'uFrmLanguage.pas' {FormLanguage},
  uInstallTypes in 'uInstallTypes.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  uDBForm in '..\PhotoDB\Units\uDBForm.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  MSXML2_TLB in '..\PhotoDB\External\Xml\MSXML2_TLB.pas',
  OmniXML_MSXML in '..\PhotoDB\External\Xml\OmniXML_MSXML.pas',
  uFileUtils in '..\PhotoDB\Units\uFileUtils.pas',
  VRSIShortCuts in '..\PhotoDB\Units\VRSIShortCuts.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uFrmProgress in 'uFrmProgress.pas' {FrmProgress},
  uFrLicence in 'uFrLicence.pas' {FrmLicence: TFrame},
  uFrAdvancedOptions in 'uFrAdvancedOptions.pas' {FrmAdvancedOptions: TFrame},
  uInstallFrame in 'uInstallFrame.pas',
  uFormUtils in '..\PhotoDB\Units\uFormUtils.pas',
  uInstallThread in 'uInstallThread.pas',
  uGOM in '..\PhotoDB\Units\uGOM.pas',
  uInstallActions in 'uInstallActions.pas',
  uVistaFuncs in '..\PhotoDB\Units\uVistaFuncs.pas',
  UnitDBFileDialogs in '..\PhotoDB\Units\UnitDBFileDialogs.pas',
  VistaDialogInterfaces in '..\PhotoDB\Units\VistaDialogInterfaces.pas',
  VistaFileDialogs in '..\PhotoDB\Units\VistaFileDialogs.pas',
  uInstallScope in 'uInstallScope.pas',
  uUninstallTypes in 'uUninstallTypes.pas',
  uUninstall in 'uUninstall.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  UnitINI in '..\PhotoDB\Units\UnitINI.pas',
  uShellUtils in 'uShellUtils.pas',
  uInstallZip in 'uInstallZip.pas',
  uDBBaseTypes in '..\PhotoDB\Units\uDBBaseTypes.pas';

{$R SETUP_ZIP.res}
{$R *.res}

begin
  Application.Initialize;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormLanguage, FormLanguage);
  try
    FormLanguage.ShowModal;
    if idOk <> FormLanguage.ModalResult then
      Exit;
  finally
    FormLanguage.Free;
  end;

  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
