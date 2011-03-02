program Activation;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ManualActivation},
  win32crc in '..\..\..\Dmitry\win32crc.pas',
  uActivationUtils in '..\PhotoDB\Units\uActivationUtils.pas',
  uConstants in '..\PhotoDB\Units\uConstants.pas',
  uMemory in '..\PhotoDB\Units\uMemory.pas',
  UnitDBCommon in '..\PhotoDB\Units\UnitDBCommon.pas',
  uRuntime in '..\PhotoDB\Units\uRuntime.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TManualActivation, ManualActivation);
  Application.Run;
end.
