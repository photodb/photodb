program Activation;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ManualActivation},
  uActivationUtils in '..\trunk\PhotoDB\Units\Utils\uActivationUtils.pas',
  uConstants in '..\trunk\PhotoDB\Units\uConstants.pas',
  uMemory in '..\trunk\PhotoDB\Units\System\uMemory.pas',
  UnitDBCommon in '..\trunk\PhotoDB\Units\UnitDBCommon.pas',
  uRuntime in '..\trunk\PhotoDB\Units\System\uRuntime.pas',
  uTranslate in '..\trunk\PhotoDB\Units\uTranslate.pas',
  uDBBaseTypes in '..\trunk\PhotoDB\Units\uDBBaseTypes.pas',
  uConfiguration in '..\trunk\PhotoDB\Units\uConfiguration.pas',
  uXMLUtils in '..\trunk\PhotoDB\Units\Utils\uXMLUtils.pas',
  uTime in '..\trunk\PhotoDB\Units\System\uTime.pas',
  uLogger in '..\trunk\PhotoDB\Units\System\uLogger.pas',
  MSXML2_TLB in '..\trunk\PhotoDB\Units\MSXML2_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TManualActivation, ManualActivation);
  Application.Run;
end.
