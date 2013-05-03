unit UnitLoadDBKernelIconsThread;

interface

uses
  uDBIcons,
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
  inherited;
  FreeOnTerminate := True;
  Icons.LoadIcons;
end;

end.
