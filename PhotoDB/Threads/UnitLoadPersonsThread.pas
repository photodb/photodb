unit UnitLoadPersonsThread;

interface

uses
  Classes, uDBThread, uPeopleSupport, ActiveX, uConstants;

type
  TLoadPersonsThread = class(TDBThread)
  protected
    procedure Execute; override;
  end;

implementation

{ TLoadPersonsThread }

procedure TLoadPersonsThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;

  CoInitializeEx(nil, COM_MODE);
  try
    PersonManager.AllPersons;
  finally
    CoUninitialize;
  end;
end;

end.
