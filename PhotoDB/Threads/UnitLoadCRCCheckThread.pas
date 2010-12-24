unit UnitLoadCRCCheckThread;

interface

uses
  Windows, Classes, Dolphin_DB, UnitDBThread, UnitDBCommon;

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
  KernelHandle : THandle;
begin
  KernelHandle := LoadLibrary(PChar(ProgramDir + 'Kernel.dll'));
  if KernelHandle <> 0 then
  begin
    @initproc := GetProcAddress(KernelHandle ,'Initialize');
    initproc(PChar(ParamStr(0)));
    FreeLibrary(KernelHandle);
  end;
end;

end.
