unit UnitLoadDBSettingsThread;

interface

uses
  Windows, Classes, DB, UnitDBKernel, CommonDBSupport, ActiveX, uDBThread,
  SysUtils, uTime, uLogger;

type
  TLoadDBSettingsThread = class(TDBThread)
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
  CoInitialize(nil);
  try
    try
      DBKernel.ReadDBOptions;
    except
      on e : Exception do
        EventLog(e.Message);
    end;
  finally
    CoUninitialize;
  end;
end;

end.
 