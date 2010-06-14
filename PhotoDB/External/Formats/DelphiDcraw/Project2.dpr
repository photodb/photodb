program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  GraphicEx in 'GraphicEX\GraphicEX.pas',
  Graphics in '..\..\..\Graphics.pas',
  GraphicCompression in 'GraphicEX\GraphicCompression.pas',
  JPG in 'GraphicEX\JPG.pas',
  MZLib in 'GraphicEX\MZLib.pas',
  GraphicStrings in 'GraphicEX\GraphicStrings.pas',
  GraphicColor in 'GraphicEX\GraphicColor.pas',
  RAWImage in 'RAWImage.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
