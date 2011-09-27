unit uExplorerNetworkProviders;

interface

uses
  Windows, Graphics, uExplorerPathProvider, uPathProviders, Network, Classes,
  uConstants, UnitDBKernel, uMemory, uTranslate, uExplorerMyComputerProvider,
  uShellIcons, SysUtils;

type
  TNetworkItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TWorkGroupItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function GetProvider: TPathProvider; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TComputerItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TShareItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TNetworkProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  public
    function Supports(Item: TPathItem): Boolean; override;
  end;

implementation

{ TNetworkProvider }

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

    CallBack(Sender, Item, List, Cancel);
  end;

  if Item is TNetworkItem then
  begin
    if PacketSize = 0 then
      PacketSize := 1;

    WorkgroupList := TStringList.Create;
    try
      FillNetLevel(nil, WorkgroupList);
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

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TNetworkProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TNetworkItem;
  Result := Item is TWorkGroupItem or Result;
  Result := Item is TComputerItem or Result;
  Result := Item is TShareItem or Result;
end;

{ TGroupsItem }

constructor TNetworkItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FPath := cNetworkPath;
  FDisplayName := TA('Network', 'Path');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
  begin
    FindIcon(HInstance, 'NETWORK', ImageSize, 32, Icon);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TNetworkItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TWorkGroupItem }

constructor TWorkGroupItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FPath := APath;
  FDisplayName := APath;
  if (ImageSize > 0) and (Options and PATH_LOAD_NO_IMAGE = 0) then
  begin
    FindIcon(HInstance, 'WORKGROUP', ImageSize, 32, Icon);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TWorkGroupItem.GetProvider: TPathProvider;
begin
  Result := PathProviderManager.Find(TNetworkProvider);
end;

function TWorkGroupItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TComputerItem }

constructor TComputerItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FPath := APath;
  FDisplayName := APath;
  if (ImageSize <> 0) and (Options and PATH_LOAD_NO_IMAGE = 0) then
  begin
    FindIcon(HInstance, 'COMPUTER', ImageSize, 32, Icon);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TComputerItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TShareItem }

constructor TShareItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FPath := APath;
  FDisplayName := ExtractFileName(APath);
  if Options and PATH_LOAD_NO_IMAGE = 0 then
  begin
    FindIcon(HInstance, 'SHARE', ImageSize, 32, Icon);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TShareItem.InternalGetParent: TPathItem;
begin
  Result := TComputerItem.CreateFromPath(ExtractFilePath(ExcludeTrailingPathDelimiter(Path)), PATH_LOAD_NO_IMAGE, 0);
end;

initialization
  PathProviderManager.RegisterProvider(TNetworkProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TNetworkProvider);

end.
