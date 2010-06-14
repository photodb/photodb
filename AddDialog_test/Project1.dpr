program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {FormUpdaterWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormUpdaterWindow, FormUpdaterWindow);
  Application.Run;
end.
