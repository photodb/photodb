unit UnitTerminationApplication;

interface

uses
  Windows, Classes, Dolphin_DB, Forms, uLogger;

type
  TerminationApplication = class(TThread)
  private
    FCurrentApplicationName: string;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

implementation

uses SysUtils;

{ TerminationApplication }

constructor TerminationApplication.Create;
begin
  inherited Create(False);
  FCurrentApplicationName := ExtractFileName(Application.ExeName);
end;

procedure TerminationApplication.Execute;
begin
  FreeOnTerminate := True;
  Sleep(10000);
  EventLog(':TerminationApplication::Execute()/KillTask...');
  KillTask(FCurrentApplicationName);
end;

end.
