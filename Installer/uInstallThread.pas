unit uInstallThread;

interface

uses
  Windows, Classes, uInstallTypes, uDBForm, uMemory, uConstants,
  uInstallUtils, uInstallScope, uInstallActions, ActiveX;

type
  TInstallThread = class(TThread)
  private
    { Private declarations }
    FOwner : TDBForm;
    FTotal, FCurrentlyDone : Int64;
    FTerminateProgress : Boolean;
  protected
    procedure Execute; override;
    procedure ExitSetup;
    procedure UpdateProgress;
    procedure InstallCallBack(Sender : TInstallAction; CurrentPoints, Total : int64; var Terminate : Boolean);
  public
    constructor Create(Owner : TDBForm);
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
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try
      TInstallManager.Instance.ExecuteInstallActions(InstallCallBack);
    finally
      Synchronize(ExitSetup);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TInstallThread.ExitSetup;
begin
  TFrmMain(FOwner).Close;
end;

procedure TInstallThread.InstallCallBack(Sender: TInstallAction; CurrentPoints,
  Total: int64; var Terminate: Boolean);
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
