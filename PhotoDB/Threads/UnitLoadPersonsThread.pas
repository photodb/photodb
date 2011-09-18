unit UnitLoadPersonsThread;

interface

uses
  Classes, uDBThread, uPeopleSupport, ActiveX;

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

  CoInitialize(nil);
  try
    PersonManager.AllPersons;
  finally
    CoUninitialize;
  end;
end;

end.
