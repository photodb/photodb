unit UnitLoadDBSettingsThread;

interface

uses
  Windows, Classes, DB, Dolphin_DB, CommonDBSupport, ActiveX;

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
  CoInitialize(nil);
  try
    DBKernel.ReadDBOptions;
  finally
    CoUninitialize;
  end;
end;

end.
 