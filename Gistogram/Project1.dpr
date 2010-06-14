program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  GraphicsBaseTypes in '..\ImageEditor\GraphicsBaseTypes.pas',
  ExEffects in '..\ImageEditor\ExEffects.pas',
  Effects in '..\ImageEditor\effects\Effects.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
