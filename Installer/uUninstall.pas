unit uUninstall;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Win.Registry,
  Winapi.Windows,
  Vcl.Dialogs,
  uActions,
  uInstallTypes,
  uMemory,
  uConstants,
  uUninstallTypes,
  uFileUtils,
  uShellUtils;

const
  InstallPoints_UninstallShortcuts = 16 * 1024;

type
  TUninstallPreviousShortcut = class
  public
    PathType: string;
    RelativePath: string;
    Directory: Boolean;
  end;

  TUninstallPreviousShortcutsAction = class(TInstallAction)
  private
    FUninstallShortcuts : TList;
    procedure FillList;
    procedure AddUninstallShortcut(APathType : string; ARelativePath : string; Directory: Boolean);
  public
    constructor Create; override;
    destructor Destroy; override;
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TUninstallShortcutsAction }

procedure TUninstallPreviousShortcutsAction.AddUninstallShortcut(APathType,
  ARelativePath: string; Directory: Boolean);
var
  Shortcut : TUninstallPreviousShortcut;
begin
  Shortcut := TUninstallPreviousShortcut.Create;
  Shortcut.PathType := APathType;
  Shortcut.RelativePath := ARelativePath;
  Shortcut.Directory := Directory;
  FUninstallShortcuts.Add(Shortcut);
end;

function TUninstallPreviousShortcutsAction.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_UninstallShortcuts * FUninstallShortcuts.Count;
end;

constructor TUninstallPreviousShortcutsAction.Create;
begin
  inherited;
  FUninstallShortcuts := TList.Create;
  FillList;
end;

destructor TUninstallPreviousShortcutsAction.Destroy;
begin
  FreeList(FUninstallShortcuts);
  inherited;
end;

procedure TUninstallPreviousShortcutsAction.Execute(Callback: TActionCallback);
var
  I, P: Integer;
  Shortcut: TUninstallPreviousShortcut;
  Path, RemovePath, RemoveMask: string;
  FCurrent, FTotal: Int64;
  Terminate: Boolean;
begin
  FTotal := CalculateTotalPoints;
  FCurrent := 0;
  Terminate := False;
  for I := 0 to FUninstallShortcuts.Count - 1 do
  begin
    Shortcut := TUninstallPreviousShortcut(FUninstallShortcuts[I]);

    if Shortcut.PathType = 'Desktop' then
      Path := GetDesktopPath
    else if Shortcut.PathType = 'Start Menu' then
      Path := GetStartMenuPath
    else
      Path := GetProgramFilesPath;

    Path := IncludeTrailingBackslash(Path) + Shortcut.RelativePath;

    if EndsText('|', Path) then
    begin
      P := Pos('*', Path);
      if P > 0 then
      begin
        RemovePath := Copy(Path, 1, P - 1);
        RemoveMask := Copy(Path, P + 1, Length(Path) - 2);
        DelDir(RemovePath, RemoveMask);
      end;
    end else if not Shortcut.Directory then
      System.SysUtils.DeleteFile(Path)
    else
      System.SysUtils.RemoveDir(Path);

    Inc(FCurrent, InstallPoints_UninstallShortcuts);
    Callback(Self, FCurrent, FTotal, Terminate);

    if Terminate then
      Exit;
 end;
end;

procedure TUninstallPreviousShortcutsAction.FillList;
begin
  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_75, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75 + '\' + ProgramShortCutFile_1_75, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75 + '\' + HelpShortCutFile_1_75, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_8, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8 + '\' + ProgramShortCutFile_1_8, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8 + '\' + HelpShortCutFile_1_8, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_9, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9 + '\' + ProgramShortCutFile_1_9, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9 + '\' + HelpShortCutFile_1_9, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0 + '\' + ProgramShortCutFile_2_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0 + '\' + HelpShortCutFile_2_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1 + '\' + ProgramShortCutFile_2_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1 + '\' + HelpShortCutFile_2_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_2, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2 + '\' + ProgramShortCutFile_2_2, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2 + '\' + HelpShortCutFile_2_2, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_3, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_3 + '\' + ProgramShortCutFile_2_3, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_3 + '\' + HelpShortCutFile_2_3, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_3, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_3_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_0 + '\' + ProgramShortCutFile_3_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_0 + '\' + HelpShortCutFile_3_0, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_0, True);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_3_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_1 + '\' + ProgramShortCutFile_3_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_1 + '\' + HelpShortCutFile_3_1, False);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_3_1, True);
end;

end.
