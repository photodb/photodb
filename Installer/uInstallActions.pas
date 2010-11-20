unit uInstallActions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Classes, uMemory, uInstallTypes, uInstallUtils, uConstants, uInstallScope,
  VRSIShortCuts, ShlObj, SysUtils, uTranslate, StrUtils, uInstallZip;

const
  InstallPoints_ShortCut = 500 * 1024;
  InstallPoints_SystemInfo = 1024 * 1024;

type
  TInstallAction = class;

  TActionCallback = procedure(Sender : TInstallAction; CurrentPoints, Total : int64; var Terminate : Boolean) of object;

  TInstallAction = class(TObject)
  public
    constructor Create; virtual;
    function CalculateTotalPoints : Int64; virtual; abstract;
    procedure Execute(Callback : TActionCallback); virtual; abstract;
  end;

  TInstallActionClass = class of TInstallAction;

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

  end;

  TInstallShortcuts = class(TInstallAction)
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallUpdatingWindows = class(TInstallAction)
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallManager = class(TObject)
  private
    FInstallScopeList : TList;
    FTotal : Int64;
    FCurrentlyDone : Int64;
    FCalBack : TActionCallback;
    procedure InternalCallback(Sender : TInstallAction; CurrentPoints, Total : int64; var Terminate : Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TInstallManager;
    procedure RegisterScope(Scope : TInstallActionClass);
    procedure ExecuteInstallActions(Callback : TActionCallback);
  end;

implementation

var
  InstallManagerInstance : TInstallManager = nil;

{ TInstallManager }

constructor TInstallManager.Create;
begin
  FInstallScopeList := TList.Create;
end;

destructor TInstallManager.Destroy;
begin
  FreeList(FInstallScopeList);
  inherited;
end;

procedure TInstallManager.ExecuteInstallActions(Callback : TActionCallback);
var
  I : Integer;
  Action : TInstallAction;
begin
  FCalBack := Callback;
  FTotal := 0;
  FCurrentlyDone := 0;
  //calculating...
  for I := 0 to FInstallScopeList.Count - 1 do
  begin
    Action := TInstallAction(FInstallScopeList[I]);
    Inc(FTotal, Action.CalculateTotalPoints);
  end;

  //executing...
  for I := 0 to FInstallScopeList.Count - 1 do
  begin
    Action := TInstallAction(FInstallScopeList[I]);
    Action.Execute(InternalCallback);
    Inc(FCurrentlyDone, Action.CalculateTotalPoints);
  end;
end;

procedure TInstallManager.InternalCallback(Sender: TInstallAction; CurrentPoints,
  Total: Int64; var Terminate: Boolean);
begin
  FCalBack(Sender, FCurrentlyDone + CurrentPoints, FTotal, Terminate);
end;

class function TInstallManager.Instance: TInstallManager;
begin
  if InstallManagerInstance = nil then
    InstallManagerInstance := TInstallManager.Create;

  Result := InstallManagerInstance;
end;

procedure TInstallManager.RegisterScope(Scope: TInstallActionClass);
begin
  FInstallScopeList.Add(Scope.Create);
end;

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

{ TInstallUpdatingWindows }

function TInstallUpdatingWindows.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_SystemInfo;
end;

procedure TInstallUpdatingWindows.Execute(Callback: TActionCallback);
var
  Terminate : Boolean;
begin
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_FLUSHNOWAIT or SHCNF_FLUSH or SHCNF_PATH, nil, nil);
  SHChangeNotify(SHCNE_UPDATEIMAGE, SHCNF_FLUSHNOWAIT or SHCNF_FLUSH or SHCNF_PATH, nil, nil);
  Callback(Self, InstallPoints_SystemInfo, InstallPoints_SystemInfo, Terminate);
end;

{ TInstallAction }

constructor TInstallAction.Create;
begin
 //
end;

initialization

  TInstallManager.Instance.RegisterScope(TInstallFiles);
  TInstallManager.Instance.RegisterScope(TInstallShortcuts);
  TInstallManager.Instance.RegisterScope(TInstallUpdatingWindows);

finalization;

  F(InstallManagerInstance);

end.
