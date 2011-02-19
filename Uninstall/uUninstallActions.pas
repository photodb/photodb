unit uUninstallActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, uActions, uInstallScope, SysUtils, uInstallUtils,
  uFileUtils, StrUtils;

const
  DeleteFilePoints = 128 * 1024;
  UnInstallPoints_ShortCut = 128 * 1024;

type
  TUninstallFiles = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallShortCuts = class(TInstallAction)
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

{ TUninstallShortCuts }

function TUninstallShortCuts.CalculateTotalPoints: Int64;
var
  I : Integer;
  DiskObject : TDiskObject;
begin
  Result := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Inc(Result, DiskObject.ShortCuts.Count * UnInstallPoints_ShortCut);
  end;
end;

procedure TUninstallShortCuts.Execute(Callback: TActionCallback);
var
  I, J : Integer;
  DiskObject : TDiskObject;
  CurentPosition : Int64;
  ShortcutPath : string;
begin
  CurentPosition := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.ShortCuts.Count - 1 do
    begin
      Inc(CurentPosition, UnInstallPoints_ShortCut);
      ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Location);
      if StartsText('http', ShortcutPath) then
      begin
        DeleteFile(ShortcutPath);
        ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Name);
        DeleteFile(ShortcutPath);
        Continue;
      end;
      DeleteFile(ShortcutPath);
    end;
  end;
end;

end.
