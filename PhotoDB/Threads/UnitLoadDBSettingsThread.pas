unit UnitLoadDBSettingsThread;

interface

uses
  Windows, Classes, DB, UnitDBKernel, CommonDBSupport, ActiveX, uDBThread,
  SysUtils, uTime, uLogger, uConstants;

type
  TLoadDBSettingsThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TLoadDBSettingsThread }

destructor TLoadDBSettingsThread.Destroy;
begin
  TW.I.Start('TLoadDBSettingsThread.Destroy');
  inherited Destroy;
end;

procedure TLoadDBSettingsThread.Execute;
begin
  TW.I.Start('TLoadDBSettingsThread: START');
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    try
      TW.I.Start('TLoadDBSettingsThread: ReadDBOptions - START');
      DBKernel.ReadDBOptions;
      TW.I.Start('TLoadDBSettingsThread: ReadDBOptions - END');
    except
      on e : Exception do
        EventLog(e.Message);
    end;
  finally
    TW.I.Start('CoUninitialize');
    CoUninitialize;
  end;
  TW.I.Start('TLoadDBSettingsThread: END');
end;

end.
 