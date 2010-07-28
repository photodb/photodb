unit UnitLoadDBSettingsThread;

interface

uses
  Windows, Classes, DB, Dolphin_DB, CommonDBSupport, ActiveX, UnitDBThread, uTime;

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
    DBKernel.ReadDBOptions;
  finally
    CoUninitialize;
  end;
  Terminate;
end;

end.
 