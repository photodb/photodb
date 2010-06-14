unit UnitTerminationApplication;

interface

uses
  Windows, Classes, Dolphin_DB, Forms;

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

{ TerminationApplication }

constructor TerminationApplication.Create(CreateSuspennded: Boolean);
begin
 inherited Create(True);
 FCurrentApplicationName:=GetFileName(Application.ExeName);
 If not CreateSuspennded then Resume;
end;

procedure TerminationApplication.Execute;
begin 
 Sleep(10000);
 EventLog(':TerminationApplication::Execute()/KillTask...');
 KillTask(FCurrentApplicationName);
end;

end.
 