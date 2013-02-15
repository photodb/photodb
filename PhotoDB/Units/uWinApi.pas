unit uWinApi;

interface

type
  EXECUTION_STATE = Cardinal;

const
  ES_AWAYMODE_REQUIRED = $00000040;
  ES_CONTINUOUS        = $80000000;
  ES_DISPLAY_REQUIRED  = $00000002;
  ES_SYSTEM_REQUIRED   = $00000001;
  ES_USER_PRESENT      = $00000004;

function SetThreadExecutionState(esFlags: EXECUTION_STATE): Cardinal;
                                                stdcall; external 'Kernel32.dll';
procedure DisableSleep;
procedure EnableSleep;

implementation

procedure DisableSleep;
begin
  SetThreadExecutionState(ES_DISPLAY_REQUIRED or ES_SYSTEM_REQUIRED or ES_CONTINUOUS);
end;

procedure EnableSleep;
begin
  SetThreadExecutionState(ES_CONTINUOUS);
end;

end.
