unit uSelfDeleteAction;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  uMemory,
  uActions,
  uShellUtils,
  uInstallUtils;

const
  InstallRemoveSelfPoints = 512 * 1024;

type
  TSelfDeleteActions = class(TInstallAction)
  public
    function CalculateTotalPoints: Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

implementation

{ TSelfDeleteActions }

function TSelfDeleteActions.CalculateTotalPoints: Int64;
begin
  Result := InstallRemoveSelfPoints;
end;

procedure TSelfDeleteActions.Execute(Callback: TActionCallback);
var
  Terminate: Boolean;
  ExeCommandsName: string;
  MS: TMemoryStream;
  FS: TFileStream;
  Pi: TProcessInformation;
  Si: TStartupInfo;
begin
  inherited;
  ExeCommandsName := GetTempFileName;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream('COMMANDS', MS);
    MS.Seek(0, soFromBeginning);
    FS := TFileStream.Create(ExeCommandsName, fmCreate);
    try
      FS.CopyFrom(MS, MS.Size);
    finally
      F(FS);
    end;
  finally
    F(MS);
  end;

  FillChar(Pi, SizeOf(Pi), #0);
  FillChar(Si, SizeOf(Si), #0);
  Si.cb := SizeOf(Si);
  CreateProcess(nil, PChar(Format('"%s" /delete "%s" /wait 100000 /pid %d /withdirectory', [ExeCommandsName, ParamStr(0), GetCurrentProcessId])),
                nil, nil, FALSE, NORMAL_PRIORITY_CLASS, nil, nil, Si, Pi);

  MoveFileEx(PChar(ExeCommandsName), nil, MOVEFILE_DELAY_UNTIL_REBOOT);
  Callback(Self, InstallRemoveSelfPoints, InstallRemoveSelfPoints, Terminate);
end;

end.
