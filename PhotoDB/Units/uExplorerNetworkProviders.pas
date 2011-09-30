unit uExplorerNetworkProviders;

interface

uses
  Windows, Graphics, uExplorerPathProvider, uPathProviders, Network, Classes,
  uConstants, UnitDBKernel, uMemory, uTranslate, uExplorerMyComputerProvider,
  uShellIcons, SysUtils, SyncObjs;

type
  TNetworkItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TWorkGroupItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function GetProvider: TPathProvider; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TComputerItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TShareItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TNetworkProvider = class(TExplorerPathProvider)
  private
    FWorkgroups: TStrings;
    FSync: TCriticalSection;
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

uses
  uExplorerFSProviders;

{ TNetworkProvider }

destructor TNetworkProvider.Destroy;
begin
  F(FWorkgroups);
  F(FSync);
  inherited;
end;

constructor TNetworkProvider.Create;
begin
  inherited;
  FWorkgroups := TStringList.Create;
  FSync := TCriticalSection.Create;
end;

function TNetworkProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize,
  PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
var
  I: Integer;
  GI: TNetworkItem;
  Cancel: Boolean;
  WorkgroupList, ComputerList, ShareList: TStrings;
  Wg: TWorkGroupItem;
  CI: TComputerItem;
  SI: TShareItem;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Item is THomeItem then
  begin
    GI := TNetworkItem.CreateFromPath(cNetworkPath, Options, ImageSize);
    List.Add(GI);
  end;

  if Item is TNetworkItem then
  begin
    if PacketSize = 0 then
      PacketSize := 1;

    WorkgroupList := TStringList.Create;
    try
      FillNetLevel(nil, WorkgroupList);
      FSync.Enter;
      try
        FWorkgroups.Assign(WorkgroupList);
      finally
        FSync.Leave;
      end;
      for I := 0 to WorkgroupList.Count - 1 do
      begin
        Wg := TWorkGroupItem.CreateFromPath(WorkgroupList[I], Options, ImageSize);
        List.Add(Wg);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;
    finally
      F(WorkgroupList);
    end;
  end;

  if Item is TWorkgroupItem then
  begin
    if PacketSize = 0 then
      PacketSize := 5;

    ComputerList := TStringList.Create;
    try
      Result := not ((FindAllComputers(Item.Path, ComputerList) <> 0) and (ComputerList.Count = 0));
      for I := 0 to ComputerList.Count - 1 do
      begin
        CI := TComputerItem.CreateFromPath(ComputerList[I], Options, ImageSize);
        List.Add(CI);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;
    finally
      F(ComputerList);
    end;
  end;

  if Item is TComputerItem then
  begin
    if PacketSize = 0 then
      PacketSize := 5;

    ShareList := TStringList.Create;
    try
      Result := not ((FindAllComputers(Item.Path, ShareList) <> 0) and (ShareList.Count = 0));

      for I := 0 to ShareList.Count - 1 do
      begin
        SI := TShareItem.CreateFromPath(ShareList[I], Options, ImageSize);
        List.Add(SI);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;
    finally
      F(ShareList);
    end;
  end;

  if Item is TShareItem then
    PathProviderManager.Find(TFileSystemProvider).FillChildList(Sender, Item, List, Options, ImageSize, PacketSize, CallBack);

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TNetworkProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TNetworkItem;
  Result := Item is TWorkGroupItem or Result;
  Result := Item is TComputerItem or Result;
  Result := Item is TShareItem or Result;
  Result := Result or Supports(Item.Path);
end;

function TNetworkProvider.Supports(Path: string): Boolean;
var
  I: Integer;
begin
  Result := IsNetworkServer(Path) or IsNetworkShare(Path) or (Path = cNetworkPath);
  if not Result then
  begin
    FSync.Enter;
    try
      for I := 0 to FWorkgroups.Count - 1 do
        if AnsiLowerCase(FWorkgroups[I]) = AnsiLowerCase(Path) then
          Result := True;
    finally
      FSync.Leave;
    end;
  end;
end;

function TNetworkProvider.CreateFromPath(Path: string): TPathItem;
begin
  if IsNetworkServer(Path) then
    Result := TComputerItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0)
  else if IsNetworkShare(Path) then
    Result := TShareItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0)
  else if Path = cNetworkPath then
    Result := TNetworkItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0)
  else
    Result := TWorkGroupItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

{ TGroupsItem }

constructor TNetworkItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  inherited;
  FPath := cNetworkPath;
  FDisplayName := TA('Network', 'Path');
  if (Options and PATH_LOAD_NO_IMAGE = 0) and (ImageSize > 0) then
    LoadImage(Options, ImageSize);
end;

function TNetworkItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TNetworkItem.Create;
end;

function TNetworkItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TNetworkItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  FindIcon(HInstance, 'NETWORK', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TWorkGroupItem }

constructor TWorkGroupItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  inherited;
  FPath := AnsiUpperCase(APath);
  FDisplayName := AnsiUpperCase(APath);
  if (ImageSize > 0) and (Options and PATH_LOAD_NO_IMAGE = 0) then
    LoadImage(Options, ImageSize);
end;

function TWorkGroupItem.GetProvider: TPathProvider;
begin
  Result := PathProviderManager.Find(TNetworkProvider);
end;

function TWorkGroupItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TWorkGroupItem.Create;
end;

function TWorkGroupItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TWorkGroupItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  FindIcon(HInstance, 'WORKGROUP', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TComputerItem }

constructor TComputerItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FPath := ExcludeTrailingPathDelimiter(APath);
  FDisplayName := FPath;
  if (ImageSize > 0) and (Options and PATH_LOAD_NO_IMAGE = 0) then
    LoadImage(Options, ImageSize);
end;

function TComputerItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TComputerItem.Create;
end;

function TComputerItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TComputerItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  FindIcon(HInstance, 'COMPUTER', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TShareItem }

constructor TShareItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FPath := APath;
  FDisplayName := ExtractFileName(APath);
  if (Options and PATH_LOAD_NO_IMAGE = 0) and (ImageSize > 0) then
    LoadImage(Options, ImageSize)
end;

function TShareItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TShareItem.Create;
end;

function TShareItem.InternalGetParent: TPathItem;
begin
  Result := TComputerItem.CreateFromPath(ExtractFilePath(ExcludeTrailingPathDelimiter(Path)), PATH_LOAD_NO_IMAGE, 0);
end;

function TShareItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  FindIcon(HInstance, 'SHARE', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

initialization
  PathProviderManager.RegisterProvider(TNetworkProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TNetworkProvider);

end.
