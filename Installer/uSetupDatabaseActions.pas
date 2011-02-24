unit uSetupDatabaseActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, uActions, SysUtils, uAssociations, uInstallScope, uConstants;

const
  InstallPoints_StartProgram = 1024 * 1024;
  InstallPoints_SetUpDatabaseProgram = 1024 * 1024;

type
  TSetupDatabaseActions = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TSetupDatabaseActions }

function TSetupDatabaseActions.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_StartProgram + InstallPoints_SetUpDatabaseProgram;
end;

procedure TSetupDatabaseActions.Execute(Callback: TActionCallback);
var
  PhotoDBExeFile: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  Terminate: Boolean;
begin
  inherited;
  PhotoDBExeFile := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + PhotoDBFileName;

  { fill with known state }
  FillChar(StartInfo, SizeOf(TStartupInfo), #0);
  FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
  StartInfo.Cb := SizeOf(TStartupInfo);

  CreateProcess(PChar(PhotoDBExeFile), PChar(PhotoDBExeFile + ' /install /NoLogo'), nil, nil, False,
              CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,
              nil, PChar(CurrentInstall.DestinationPath), StartInfo, ProcInfo);

  Callback(Self, InstallPoints_StartProgram, CalculateTotalPoints, Terminate);

  WaitForSingleObject(ProcInfo.hProcess, INFINITE);

  CloseHandle(ProcInfo.hProcess);
  CloseHandle(ProcInfo.hThread);

  Callback(Self, InstallPoints_SetUpDatabaseProgram, CalculateTotalPoints, Terminate);
end;


end.
