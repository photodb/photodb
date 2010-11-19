unit uSetupActions;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Classes, uMemory, uInstallTypes, uInstallUtils, uConstants, uInstallScope;

type
  TSetupAction = class;

  TActionCallback = procedure(Sender : TSetupAction; CurrentPoints, Total : int64; var Terminate : Boolean) of object;

  TSetupAction = class(TObject)
  public
    function CalculateTotalPoints : Int64; virtual; abstract;
    procedure Execute(Options : TInstallOptions; Callback : TActionCallback); virtual; abstract;
  end;

  TInstallActionClass = class of TSetupAction;

  TSetupUpdates = class(TSetupAction)

  end;

  TSetupFiles = class(TSetupAction)
  private
    FTotal : Int64;
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Options : TInstallOptions; Callback : TActionCallback); override;
  end;

  TSetupRegistry = class(TSetupAction)

  end;

  TSetupShortcuts = class(TSetupAction)

  end;

  TSetupUpdatingWindows = class(TSetupAction)

  end;

  TSetupManager = class(TObject)
  private
    FSetupScopeList : TList;
    FCalBack : TActionCallback;
    procedure InternalCallback(Sender : TSetupAction; CurrentPoints, Total : int64; var Terminate : Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TSetupManager;
    procedure RegisterScope(Scope : TInstallActionClass);
    procedure ExecuteInstallActions(Options : TInstallOptions; Callback : TActionCallback);
  end;

implementation

var
  SetupManagerInstance : TSetupManager = nil;

{ TSetupManager }

constructor TSetupManager.Create;
begin
  FSetupScopeList := TList.Create;
end;

destructor TSetupManager.Destroy;
begin
  FreeList(FSetupScopeList);
  inherited;
end;

procedure TSetupManager.ExecuteInstallActions(Options : TInstallOptions; Callback : TActionCallback);
var
  I : Integer;
  Action : TSetupAction;
begin
  FCalBack := Callback;
  for I := 0 to FSetupScopeList.Count - 1 do
  begin
    Action := TSetupAction(FSetupScopeList[I]);
    Action.Execute(Options, InternalCallback);
  end;
end;

procedure TSetupManager.InternalCallback(Sender: TSetupAction; CurrentPoints,
  Total: Int64; var Terminate: Boolean);
begin
  FCalBack(Sender, CurrentPoints, Total, Terminate);
end;

class function TSetupManager.Instance: TSetupManager;
begin
  if SetupManagerInstance = nil then
    SetupManagerInstance := TSetupManager.Create;

  Result := SetupManagerInstance;
end;

procedure TSetupManager.RegisterScope(Scope: TInstallActionClass);
begin
  FSetupScopeList.Add(Scope.NewInstance);
end;

{ TSetupFiles }

function TSetupFiles.CalculateTotalPoints: Int64;
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

procedure TSetupFiles.Execute(Options: TInstallOptions;
  Callback: TActionCallback);
var
  MS : TMemoryStream;
  I : Integer;
  DiskObject : TDiskObject;
  Destination : string;
begin
  FTotal := CalculateTotalPoints;

  MS := TMemoryStream.Create;
  try
    GetRCDATAResourceStream(SetupDataName, MS);

    for I := 0 to CurrentInstall.Files.Count - 1 do
    begin
      DiskObject := CurrentInstall.Files[I];
      //TODO:
      Destination := 'c:\1\' + DiskObject.Name;
      if DiskObject is TFileObject then
        ExtractFileFromStorage(MS, Destination);
      if DiskObject is TDirectoryObject then
        ExtractDirectoryFromStorage(MS, Destination);
    end;
  finally
    F(MS);
  end;
end;

initialization

  TSetupManager.Instance.RegisterScope(TSetupFiles);

finalization;

  F(SetupManagerInstance);

end.
