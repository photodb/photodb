program Activation;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ManualActivation},
  win32crc in '..\..\..\Dmitry\win32crc.pas',
  uActivationUtils in '..\PhotoDB\Units\uActivationUtils.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  UnitDBCommon in '..\PhotoDB\Units\UnitDBCommon.pas',
  uRuntime in '..\PhotoDB\Units\uRuntime.pas',
  uTranslate in '..\PhotoDB\Units\uTranslate.pas',
  MSXML2_TLB in '..\PhotoDB\External\Xml\MSXML2_TLB.pas',
  OmniXML_MSXML in '..\PhotoDB\External\Xml\OmniXML_MSXML.pas',
  uLogger in '..\PhotoDB\Units\uLogger.pas',
  uFileUtils in '..\PhotoDB\Units\uFileUtils.pas',
  VRSIShortCuts in '..\PhotoDB\Units\VRSIShortCuts.pas',
  uDBBaseTypes in '..\PhotoDB\Units\uDBBaseTypes.pas',
  uSysUtils in '..\PhotoDB\Units\uSysUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TManualActivation, ManualActivation);
  Application.Run;
end.
