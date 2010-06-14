program Project1;

uses
  Forms,
  activation in 'activation.pas' {ActivateForm},
  Language in '..\Units\Language.pas',
  win32crc in '..\Units\win32crc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TActivateForm, ActivateForm);
  Application.Run;
end.
