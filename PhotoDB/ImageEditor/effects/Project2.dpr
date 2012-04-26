program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  GBlur2 in '..\GBlur2.pas',
  Effects in 'Effects.pas',
  GraphicsBaseTypes in '..\GraphicsBaseTypes.pas',
  ScanlinesFX in 'ScanlinesFX.pas',
  Scanlines in 'Scanlines.pas',
  OptimizeImageUnit in '..\OptimizeImageUnit.pas',
  janFX in 'janFX.pas',
  FastDraw in 'fast\FastDraw.pas',
  FastRGB in 'fast\FastRGB.pas',
  FastBMP in 'fast\FastBMP.pas',
  Fast256 in 'fast\Fast256.pas',
  FastFX in 'fast\FastFX.pas',
  FastIMG in 'fast\FastIMG.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
