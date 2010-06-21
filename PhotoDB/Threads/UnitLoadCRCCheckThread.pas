unit UnitLoadCRCCheckThread;

interface

uses
  Windows, Classes, Dolphin_DB, UnitDBThread;

type
  TLoadCRCCheckThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ TLoadCRCCheckThread }

procedure TLoadCRCCheckThread.Execute;
type
  TInitializeProc = function(s:PChar) : integer;
var
  Initproc : TInitializeProc;
begin          
  @initproc := GetProcAddress(KernelHandle ,'Initialize');
  initproc(PChar(ParamStr(0)));
end;

end.
