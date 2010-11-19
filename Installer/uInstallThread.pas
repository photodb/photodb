unit uInstallThread;

interface

uses
  Windows, Classes, uInstallTypes, uDBForm, uMemory, uConstants,
  uInstallUtils, uSetupScope;

type
  TInstallThread = class(TThread)
  private
    { Private declarations }
    FOwner : TDBForm;
    FOptions : TInstallOptions;
  protected
    procedure Execute; override;
    procedure ExitSetup;
    procedure InstallCallBack(Sender : TSetupScope; CurrentPoints, Total : int64; var Terminate : Boolean);
  public
    constructor Create(Owner : TDBForm; Options : TInstallOptions);
  end;

implementation

uses
  uFrmMain;

{ TInstallThread }

constructor TInstallThread.Create(Owner: TDBForm; Options: TInstallOptions);
begin
  inherited Create(False);
  FOwner := Owner;
  FOptions := Options;
end;

procedure TInstallThread.Execute;
begin
  FreeOnTerminate := True;
  try
    TSetupManager.Instance.ExecuteInstallActions(FOptions, InstallCallBack);
  finally
    Synchronize(ExitSetup);
  end;
end;

procedure TInstallThread.ExitSetup;
begin
  TFrmMain(FOwner).Close;
end;

procedure TInstallThread.InstallCallBack(Sender: TSetupScope; CurrentPoints,
  Total: int64; var Terminate: Boolean);
begin
  //TODO:
end;

end.
