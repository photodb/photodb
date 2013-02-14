{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2012-08-14 14:35:41 +0200 (Tue, 14 Aug 2012)                            $ }
{ Revision:      $Rev:: 3824                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

program JediInstaller;

{$I jcl.inc}

uses
  JclInstall in 'JclInstall.pas',
  JediInstall in 'JediInstall.pas',
  JediInstallConfigIni in 'JediInstallConfigIni.pas',
  JclIDEUtils in '..\source\common\JclIDEUtils.pas',
  JclResources in '..\source\common\JclResources.pas',
  JediRegInfo in 'JediRegInfo.pas',
  FrmCompile in 'VclGui\FrmCompile.pas' {FormCompile},
  JediGUIText in 'VclGui\JediGUIText.pas' {TextFrame: TFrame},
  JediGUIInstall in 'VclGui\JediGUIInstall.pas' {InstallFrame: TFrame},
  JediGUIMain in 'VclGui\JediGUIMain.pas' {MainForm},
  JediGUIProfiles in 'VclGui\JediGUIProfiles.pas' {ProfilesFrame: TFrame},
  JediProfiles in 'JediProfiles.pas',
  JclInstallResources in 'JclInstallResources.pas',
  JediInstallResources in 'JediInstallResources.pas',
  JclMsBuild in '..\source\windows\JclMsBuild.pas';

{$R *.res}
{$R ..\source\windows\JclCommCtrlAsInvoker.res}

begin
  InstallCore.Execute;
end.
