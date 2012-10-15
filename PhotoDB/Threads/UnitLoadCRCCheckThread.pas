unit UnitLoadCRCCheckThread;

interface

uses
  Windows,
  Classes,

  Dolphin_DB,
  UnitDBCommon,

  uDBThread,
  uLogger,
  uShellIntegration,
  uSplashThread,
  uRuntime,
  uConstants;

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
  ValidateApplicationProc = function(s: PChar): Boolean;
var
  ValidateProc: ValidateApplicationProc;
  KernelHandle: THandle;
begin
  FreeOnTerminate := True;
  KernelHandle := LoadLibrary(PChar(ProgramDir + 'Kernel.dll'));
  if KernelHandle <> 0 then
  begin
    @ValidateProc := GetProcAddress(KernelHandle, 'ValidateApplication');
    EventLog('Verifyng....');
    {$IFDEF LICENCE}
    if not Assigned(ValidateProc) or not ValidateProc(PChar(ParamStr(0))) then
    begin
      CloseSplashWindow;
      MessageBoxDB(GetActiveFormHandle, L('Application is damaged! Possible it is infected by a virus!', 'System'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      DBTerminating := True;
    end;
    {$ENDIF}
    FreeLibrary(KernelHandle);
  end;
end;

end.
