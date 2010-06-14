program Project2;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  PrintMainForm in 'PrintMainForm.pas' {PrintForm},
  UnitGeneratorPrinterPreview in 'UnitGeneratorPrinterPreview.pas',
  UnitPrinterTypes in 'UnitPrinterTypes.pas',
  PrinterProgress in 'PrinterProgress.pas' {FormPrinterProgress},
  Effects in '..\ImageEditor\effects\Effects.pas',
  GraphicsBaseTypes in '..\ImageEditor\GraphicsBaseTypes.pas',
  Language in '..\Units\Language.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
