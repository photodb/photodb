unit uInstallActions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Classes, uMemory, uInstallTypes, uInstallUtils, uConstants, uInstallScope,
  VRSIShortCuts, ShellApi, ShlObj, SysUtils, uTranslate, StrUtils, uInstallZip,
  uAssociations, uShellUtils, uActions;

const
  InstallPoints_ShortCut = 500 * 1024;
  InstallPoints_Registry = 128 * 1024;
  InstallPoints_RunProgram = 1024 * 1024;

type
  TUpdatePreviousVersions = class(TInstallAction)

  end;

  TInstallUpdates = class(TInstallAction)

  end;

  TInstallFiles = class(TInstallAction)
  private
    FTotal : Int64;
    FCurrentlyDone : Int64;
    FCallBack : TActionCallback;
    procedure InternalCallBack(BytesRead, BytesTotal : int64; var Terminate : Boolean);
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallRegistry = class(TInstallAction)
  private
    FCallback : TActionCallback;
    procedure OnInstallRegistryCallBack(Current, Total : Integer; var Terminate : Boolean);
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallShortcuts = class(TInstallAction)
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallRunProgram = class(TInstallAction)
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TInstallFiles }

function TInstallFiles.CalculateTotalPoints: Int64;
var
  MS : TMemoryStream;
  DiskObject : TDiskObject;
  I : Integer;
begin
  Result := 0;
  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream(SetupDataName, MS);

    for I := 0 to CurrentInstall.Files.Count - 1 do
    begin
      DiskObject := CurrentInstall.Files[I];
      Inc(Result, GetObjectSize(MS, DiskObject.Name));
    end;

  finally
    F(MS);
  end;
end;

procedure TInstallFiles.Execute(Callback: TActionCallback);
var
  MS : TMemoryStream;
  I : Integer;
  DiskObject : TDiskObject;
  Destination : string;
begin
  FCallBack := Callback;
  FTotal := CalculateTotalPoints;
  FCurrentlyDone := 0;

  CreateDir(CurrentInstall.DestinationPath);

  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream(SetupDataName, MS);

    for I := 0 to CurrentInstall.Files.Count - 1 do
    begin
      DiskObject := CurrentInstall.Files[I];
      Destination := IncludeTrailingBackslash(ResolveInstallPath(DiskObject.FinalDestination)) + DiskObject.Name;
      if DiskObject is TFileObject then
        ExtractFileFromStorage(MS, Destination, InternalCallBack);
      if DiskObject is TDirectoryObject then
        ExtractDirectoryFromStorage(MS, Destination, InternalCallBack);

      Inc(FCurrentlyDone, GetObjectSize(MS, DiskObject.Name));
    end;
  finally
    F(MS);
  end;
end;

procedure TInstallFiles.InternalCallBack(BytesRead, BytesTotal : int64; var Terminate : Boolean);
begin
  FCallBack(Self, FCurrentlyDone + BytesRead, FTotal, Terminate);
end;

{ TInstallShortcuts }

function TInstallShortcuts.CalculateTotalPoints: Int64;
var
  I : Integer;
  DiskObject : TDiskObject;
begin
  Result := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Inc(Result, DiskObject.ShortCuts.Count * InstallPoints_ShortCut);
  end;
end;

procedure TInstallShortcuts.Execute(Callback: TActionCallback);
var
  I, J : Integer;
  DiskObject : TDiskObject;
  CurentPosition : Int64;
  ShortcutPath, ObjectPath : string;
begin
  CurentPosition := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.ShortCuts.Count - 1 do
    begin
      Inc(CurentPosition, InstallPoints_ShortCut);
      ObjectPath := ResolveInstallPath(IncludeTrailingBackslash(DiskObject.FinalDestination) + DiskObject.Name);  
      ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Location);
      if StartsText('http', ShortcutPath) then
      begin
        ObjectPath := ChangeFileExt(ObjectPath, '.url');
        CreateInternetShortcut(ObjectPath, ShortcutPath);
        ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Name);
        CreateShortcut(ObjectPath, ShortcutPath, TTranslateManager.Instance.TA(ResolveInstallPath(DiskObject.Description), 'SETUP'));
        Continue;
      end;
      CreateShortcut(ObjectPath, ShortcutPath, TTranslateManager.Instance.TA(ResolveInstallPath(DiskObject.Description), 'SETUP'));
    end;
  end;
end;

{ TInstallRegistry }

function TInstallRegistry.CalculateTotalPoints: Int64;
begin
  Result := 11 * InstallPoints_Registry;
end;

procedure TInstallRegistry.Execute(Callback: TActionCallback);
var
  FileName : string;
begin
  FCallback := Callback;
  FileName := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + 'PhotoDB.exe';
  RegInstallApplication(FileName, OnInstallRegistryCallBack);
end;

procedure TInstallRegistry.OnInstallRegistryCallBack(Current, Total : Integer;
  var Terminate: Boolean);
begin
  FCallback(Self, Current * InstallPoints_Registry, Total * InstallPoints_Registry, Terminate);
end;

{ TInstallRunProgram }

function TInstallRunProgram.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_RunProgram;
end;

procedure TInstallRunProgram.Execute(Callback: TActionCallback);
var
  Terminate : Boolean;
  PhotoDBExeFile : string;
  StartInfo  : TStartupInfo;
  ProcInfo   : TProcessInformation;
begin
  PhotoDBExeFile := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + 'PhotoDB.exe';

  { fill with known state }
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);

  CreateProcess(PChar(PhotoDBExeFile), '/sleep', nil, nil, False,
              CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,
              nil, PChar(CurrentInstall.DestinationPath), StartInfo, ProcInfo);

  Callback(Self, InstallPoints_RunProgram, InstallPoints_RunProgram, Terminate);
end;

initialization

  TInstallManager.Instance.RegisterScope(TInstallFiles);
  TInstallManager.Instance.RegisterScope(TInstallRegistry);
  TInstallManager.Instance.RegisterScope(TInstallShortcuts);
  TInstallManager.Instance.RegisterScope(TInstallRunProgram);

end.
