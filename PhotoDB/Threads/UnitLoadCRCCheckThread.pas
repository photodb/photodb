unit UnitLoadCRCCheckThread;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Forms,

  UnitDBCommon,

  uDBThread,
  uLogger,
  uRuntime,
  uSplashThread,
  uShellIntegration,
  uVCLHelpers,
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
  ValidateApplicationProc = function(S: PChar): Boolean;
var
  ValidateProc: ValidateApplicationProc;
  KernelHandle: THandle;
  LibName: string;
begin
  inherited;
  FreeOnTerminate := True;
  LibName := ProgramDir + 'Kernel.dll';
  KernelHandle := LoadLibrary(PChar(LibName));
  if KernelHandle <> 0 then
  begin
    @ValidateProc := GetProcAddress(KernelHandle, PAnsiChar('ValidateApplication'));
    EventLog('Verifyng....');
    {$IFDEF LICENCE}
    if not Assigned(ValidateProc) or not ValidateProc(PChar(ParamStr(0))) then
    begin
      CloseSplashWindow;
      MessageBoxDB(Screen.ActiveFormHandle, L('Application is damaged! Possible it is infected by a virus!', 'System'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      DBTerminating := True;
    end;
    {$ENDIF}
    FreeLibrary(KernelHandle);
  end;
end;

end.
