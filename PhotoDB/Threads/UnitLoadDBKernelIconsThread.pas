unit UnitLoadDBKernelIconsThread;

interface

uses
  Windows, Classes, UnitDBkernel, Dolphin_DB, UnitDBThread,
  uTime;

type
  TLoadDBKernelIconsThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ UnitLoadDBKernelIconsThread }

procedure TLoadDBKernelIconsThread.Execute;
begin
  DBKernel.LoadIcons;
  Terminate;
end;

end.
