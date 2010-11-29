unit uUninstallActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, uActions, uInstallScope, SysUtils, uInstallUtils, uFileUtils;

const
  DeleteFilePoints = 128 * 1024;

type
  TUninstallFiles = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TUninstallFiles }

function TUninstallFiles.CalculateTotalPoints: Int64;
begin
  Result := CurrentInstall.Files.Count * DeleteFilePoints;
end;

procedure TUninstallFiles.Execute(Callback: TActionCallback);
var
  I : Integer;
  DiskObject : TDiskObject;
  Destination : string;
  Terminate : Boolean;
begin
  Terminate := False;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Destination := IncludeTrailingBackslash(ResolveInstallPath(DiskObject.FinalDestination)) + DiskObject.Name;
    if DiskObject is TFileObject then
      DeleteFile(Destination);
    if DiskObject is TDirectoryObject then
      DeleteDirectoryWithFiles(Destination);

    Callback(Self, I * DeleteFilePoints, CurrentInstall.Files.Count, Terminate);

    if Terminate then
      Break;
  end;
end;

initialization

  TInstallManager.Instance.RegisterScope(TUninstallFiles);

end.
