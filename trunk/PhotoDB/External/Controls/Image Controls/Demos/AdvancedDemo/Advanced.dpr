program Advanced;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Navig in 'Navig.pas' {NavigatorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TNavigatorForm, NavigatorForm);
  Application.Run;
end.
