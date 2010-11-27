unit uUninstall;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, Classes, uActions, uInstallTypes, uMemory, Registry, uConstants,
  SysUtils, uUninstallTypes;

const
  InstallPoints_UninstallShortcuts = 16 * 1024;

type
  TUninstallPreviousShortcut = class
  public
    PathType : string;
    RelativePath : string;
  end;

  TUninstallPreviousShortcutsAction = class(TInstallAction)
  private
    FUninstallShortcuts : TList;
    procedure FillList;
    procedure AddUninstallShortcut(APathType : string; ARelativePath : string);
  public
    constructor Create; override;
    destructor Destroy; override;
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TUninstallShortcutsAction }

procedure TUninstallPreviousShortcutsAction.AddUninstallShortcut(APathType,
  ARelativePath: string);
var
  Shortcut : TUninstallPreviousShortcut;
begin
  Shortcut := TUninstallPreviousShortcut.Create;
  Shortcut.PathType := APathType;
  Shortcut.RelativePath := ARelativePath;
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
  Reg : TRegIniFile;
  I : Integer;
  Shortcut : TUninstallPreviousShortcut;
  Path : string;
  FCurrent, FTotal : Int64;
  Terminate : Boolean;
begin
  FTotal := CalculateTotalPoints;
  FCurrent := 0;
  Terminate := False;
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    for I := 0 to FUninstallShortcuts.Count - 1 do
    begin
      Shortcut := TUninstallPreviousShortcut(FUninstallShortcuts[I]);
      Path := IncludeTrailingBackslash(Reg.ReadString('Shell Folders', Shortcut.PathType, '')) + Shortcut.RelativePath;
      if ExtractFileExt(Shortcut.RelativePath) <> '' then
        SysUtils.DeleteFile(Path)
      else
        SysUtils.RemoveDir(Path);

      Inc(FCurrent, InstallPoints_UninstallShortcuts);
      Callback(Self, FCurrent, FTotal, Terminate);

      if Terminate then
        Exit;
   end;
  finally
    F(Reg);
  end;
end;

procedure TUninstallPreviousShortcutsAction.FillList;
begin
  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_75);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75 + '\' + ProgramShortCutFile_1_75);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75 + '\' + HelpShortCutFile_1_75);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_75);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_8);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8 + '\' + ProgramShortCutFile_1_8);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8 + '\' + HelpShortCutFile_1_8);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_8);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_1_9);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9 + '\' + ProgramShortCutFile_1_9);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9 + '\' + HelpShortCutFile_1_9);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_1_9);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_0);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0 + '\' + ProgramShortCutFile_2_0);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0 + '\' + HelpShortCutFile_2_0);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_0);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_1);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1 + '\' + ProgramShortCutFile_2_1);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1 + '\' + HelpShortCutFile_2_1);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_1);

  AddUninstallShortcut('Desktop', ProgramShortCutFile_2_2);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2 + '\' + ProgramShortCutFile_2_2);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2 + '\' + HelpShortCutFile_2_2);
  AddUninstallShortcut('Start Menu', StartMenuProgramsPath_2_2);
end;

initialization

  TInstallManager.Instance.RegisterScope(TUninstallPreviousShortcutsAction);

end.
