unit UnitLoadDBSettingsThread;

interface

uses
  Windows, Classes, DB, Dolphin_DB, CommonDBSupport, ActiveX, UnitDBThread,
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
  Terminate;
end;

end.
 