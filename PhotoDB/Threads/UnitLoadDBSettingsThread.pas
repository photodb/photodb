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
    destructor Destroy; override;
  end;

implementation

{ TLoadDBSettingsThread }

destructor TLoadDBSettingsThread.Destroy;
begin

  inherited;
end;

procedure TLoadDBSettingsThread.Execute;
begin
  inherited;
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
 