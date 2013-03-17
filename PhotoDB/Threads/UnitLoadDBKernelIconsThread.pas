unit UnitLoadDBKernelIconsThread;

interface

uses
  UnitDBkernel,
  uDBThread;

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
  FreeOnTerminate := True;
  DBKernel.LoadIcons;
end;

end.
