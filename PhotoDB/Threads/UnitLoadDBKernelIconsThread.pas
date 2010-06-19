unit UnitLoadDBKernelIconsThread;

interface

uses
  Windows, Classes, UnitDBkernel, Dolphin_DB;

type
  TLoadDBKernelIconsThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ UnitLoadDBKernelIconsThread }

procedure TLoadDBKernelIconsThread.Execute;
begin
  FreeOnTerminate := True;
  DBKernel.LoadIcons;
end;

end.
