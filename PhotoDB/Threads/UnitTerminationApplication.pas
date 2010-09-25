unit UnitTerminationApplication;

interface

uses
  Windows, Classes, Dolphin_DB, Forms, uLogger;

type
  TerminationApplication = class(TThread)
  private
  FCurrentApplicationName : String;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean);
  end;

implementation

uses SysUtils;

{ TerminationApplication }

constructor TerminationApplication.Create(CreateSuspennded: Boolean);
begin
  inherited Create(False);
  FCurrentApplicationName := ExtractFileName(Application.ExeName);
end;

procedure TerminationApplication.Execute;
begin
 Sleep(10000);
 EventLog(':TerminationApplication::Execute()/KillTask...');
 KillTask(FCurrentApplicationName);
end;

end.

