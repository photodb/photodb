unit uInstallThread;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Winapi.ActiveX,

  uInstallTypes,
  uDBForm,
  uMemory,
  uConstants,
  uInstallUtils,
  uInstallScope,
  uActions,
  uTranslate,
  uIME;

type
  TInstallThread = class(TThread)
  private
    { Private declarations }
    FOwner: TDBForm;
    FTotal, FCurrentlyDone: Int64;
    FTerminateProgress: Boolean;
  protected
    procedure Execute; override;
    procedure ExitSetup;
    procedure UpdateProgress;
    procedure InstallCallBack(Sender: TInstallAction; CurrentPoints, Total: Int64; var Terminate : Boolean);
  public
    constructor Create(Owner: TDBForm);
  end;

implementation

uses
  uFrmMain;

{ TInstallThread }

constructor TInstallThread.Create(Owner: TDBForm);
begin
  inherited Create(False);
  FOwner := Owner;
  FTotal := 0;
  FCurrentlyDone := 0;
end;

procedure TInstallThread.Execute;
begin
  DisableIME;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try
      if not TInstallManager.Instance.ExecuteInstallActions(InstallCallBack) then
        MessageBox(0, PChar(TA('Installation was aborted!', 'Setup')), PChar(TA('Error')), MB_OK);
    except
      on e: Exception do
        MessageBox(0, PChar('Error: ' + e.Message), PChar(TA('Error')), MB_OK);
    end;
  finally
    Synchronize(ExitSetup);
    CoUninitialize;
  end;
end;

procedure TInstallThread.ExitSetup;
begin
  TFrmMain(FOwner).Close;
end;

procedure TInstallThread.InstallCallBack(Sender: TInstallAction; CurrentPoints,
  Total: Int64; var Terminate: Boolean);
begin
  FTotal := Total;
  FCurrentlyDone := CurrentPoints;
  Synchronize(UpdateProgress);
end;

procedure TInstallThread.UpdateProgress;
begin
  FTerminateProgress := not TFrmMain(FOwner).UpdateProgress(FCurrentlyDone, FTotal);
end;

end.
