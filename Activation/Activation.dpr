program Activation;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  win32crc in '..\units\win32crc.pas',
  ActivationFunctions in 'ActivationFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
