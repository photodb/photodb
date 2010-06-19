unit UnitLoadDBSettingsThread;

interface

uses
  Classes, DB, Dolphin_DB, CommonDBSupport;

type
  TLoadDBSettingsThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ TLoadDBSettingsThread }

procedure TLoadDBSettingsThread.Execute; 
begin
  FreeOnTerminate := True;
  DBKernel.ReadDBOptions;
end;

end.
 