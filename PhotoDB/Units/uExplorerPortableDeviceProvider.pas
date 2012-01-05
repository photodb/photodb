unit uExplorerPortableDeviceProvider;

interface

uses
  Generics.Collections,
  uPathProviders,
  Vcl.Graphics,
  uMemory,
  uExplorerPathProvider,
  System.Classes,
  uExplorerMyComputerProvider,
  uConstants,
  uShellIcons,
  uTranslate,
  System.StrUtils,
  SysUtils, uBitmapUtils,
  uPortableClasses,
  System.Math,
  uPortableDeviceManager,
  uAssociatedIcons;

type
  TPDContext = class(TObject)
  public
    Sender: TObject;
    Item: TPathItem;
    List: TPathItemCollection;
    Options, ImageSize: Integer;
    PacketSize: Integer;
    CallBack: TLoadListCallBack;
  end;

  TPortableDeviceItem = class(TPathItem)
  private
    FDevice: IPDevice;
    function GetDevice: IPDevice;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    property Device: IPDevice read GetDevice;
  public
    procedure LoadDevice(Device: IPDevice);
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TPortableItem = class(TPathItem)
  private
    FItem: IPDItem;
    function GetItem: IPDItem;
  protected
    property Item: IPDItem read GetItem;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    procedure LoadItem(AItem: IPDItem);
  end;

  TPortableStorageItem = class(TPortableItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;

  TPortableFSItem = class(TPortableItem)
  protected
    function InternalGetParent: TPathItem; override;
  end;
  
  TPortableDirectoryItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;  
  
  TPortableImageItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;  
  
  TPortableVideoItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;    
   
  TPortableFileItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;

type
  TPortableDeviceProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
    procedure FillDevicesCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FillItemsCallBack(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Item: TPathItem; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

function ImageSizeToIconSize16_32_48(ImageSize: Integer): Integer;
begin
  if ImageSize >= 48 then
    ImageSize := 48
  else if ImageSize >= 32 then 
    ImageSize := 32  
  else if ImageSize >= 16 then  
    ImageSize := 16; 

  Result := ImageSize;
end;

function IsDevicePath(Path: string): Boolean;
begin
  Result := False;
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    Result := Pos('\', Path) = 0;
  end;
end;

function IsDeviceItemPath(Path: string): Boolean;
begin
  Result := False;
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    Result := Pos('\', Path) > 0;
  end;
end;

function ExtractDeviceName(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    P := Pos('\', Path);
    if P = 0 then
      P := Length(Path) + 1;

    Result := Copy(Path, 1, P - 1);
  end;
end;

function ExtractDeviceItemPath(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    P := Pos('\', Path);
    if P > 1 then
      Delete(Path, 1, P - 1);

    Result := Path;
  end;                                   
end;

function CreatePortableFSItem(Item: IPDItem; Options, ImageSize: Integer): TPortableItem;     
var
  ItemPath: string;
begin
  Result := nil;
  ItemPath := PortableItemNameCache.GetPathByKey(Item.DeviceID, Item.ItemKey);  
  ItemPath := cDevicesPath + '\' + Item.DeviceName + ItemPath;
  case Item.ItemType of
    piStorage:
    begin
      Result := TPortableStorageItem.CreateFromPath(ItemPath, Options, ImageSize);
      Result.LoadItem(Item);
    end;
    piDirectory: 
    begin
      Result := TPortableDirectoryItem.CreateFromPath(ItemPath, Options, ImageSize);
      Result.LoadItem(Item);
    end;
    piImage: 
    begin
      Result := TPortableImageItem.CreateFromPath(ItemPath, Options, ImageSize);
      Result.LoadItem(Item);  
    end;
    piVideo: 
    begin
      Result := TPortableVideoItem.CreateFromPath(ItemPath, Options, ImageSize);
      Result.LoadItem(Item);  
    end;
    piFile: 
    begin
      Result := TPortableFileItem.CreateFromPath(ItemPath, Options, ImageSize);
      Result.LoadItem(Item);  
    end;
  end;
end;  

function CreateItemByPath(Path: string): TPathItem;
var
  ItemPath,
  DeviceName: string;
  Device: IPDevice;
  Item: IPDItem;
begin
  DeviceName := ExtractDeviceName(Path);
  ItemPath := ExtractDeviceItemPath(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
  if Device = nil then
    Exit(THomeItem.Create);

  Item := Device.GetItemByPath(ItemPath);
  if Item = nil then
    Exit(THomeItem.Create);
  Result := CreatePortableFSItem(Item, PATH_LOAD_NO_IMAGE, 0);
end;

{ TCameraProvider }

function TPortableDeviceProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if IsDeviceItemPath(Path) then
    Result := CreateItemByPath(Path);
  if IsDevicePath(Path) then
    Result := TPortableDeviceItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TPortableDeviceProvider.ExecuteFeature(Sender: TObject; Item: TPathItem;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Item, Feature, Options);
end;

function TPortableDeviceProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  PortableItem: TPathItem;
begin
  Result := False;
  PortableItem := PathProviderManager.CreatePathItem(Item.Path);
  if (PortableItem is TPortableImageItem) or (PortableItem is TPortableVideoItem) then
  begin     
    PortableItem.LoadImage(PATH_LOAD_NORMAL, Min(MaxWidth, MaxHeight));
    if (PortableItem.Image <> nil) and (PortableItem.Image.Bitmap <> nil) then
    begin
      AssignBitmap(Bitmap, PortableItem.Image.Bitmap);
      Result := not Bitmap.Empty;
    end;
  end; 
end;

procedure TPortableDeviceProvider.FillDevicesCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  Device: IPDevice;
  DeviceItem: TPortableDeviceItem;
  C: TPDContext;
  ACancel: Boolean;
begin
  C := TPDContext(Context);
  ACancel := False;
  for Device in Packet do
  begin
    DeviceItem := TPortableDeviceItem.CreateFromPath(cDevicesPath + '\' + Device.Name, C.Options, C.ImageSize);
    DeviceItem.LoadDevice(Device);
    C.List.Add(DeviceItem);

    if Assigned(C.CallBack) then
      C.CallBack(C.Sender, C.Item, C.List, ACancel);
    if ACancel then
    begin
      Cancel := True;
      Break;
    end;
  end;
end;

procedure TPortableDeviceProvider.FillItemsCallBack(ParentKey: string;
  Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
var
  ACancel: Boolean;
  C: TPDContext;
  Item: IPDItem;
  PItem: TPortableItem;
begin
  C := TPDContext(Context);
  ACancel := False;

  for Item in Packet do
  begin
    PItem := CreatePortableFSItem(Item, C.Options, C.ImageSize);
    C.List.Add(PItem);
  end;

  if Assigned(C.CallBack) then
    C.CallBack(C.Sender, C.Item, C.List, ACancel);

  if ACancel then
    Cancel := True;
end;

function TPortableDeviceProvider.GetTranslateID: string;
begin
  Result := 'PortableDevicesProvider';
end;

function TPortableDeviceProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  Dev: IPDevice;
  Context: TPDContext;
  DevName, DevItemPath, ItemKey: string;
begin
  Result := True;
  Context := TPDContext.Create;
  try
    Context.Sender := Sender;
    Context.Item := Item;
    Context.List := List;
    Context.Options := Options;
    Context.ImageSize := ImageSize;
    Context.CallBack := CallBack;

    if Item is THomeItem then
      CreateDeviceManagerInstance.FillDevicesWithCallBack(FillDevicesCallBack, Context);

    if Item is TPortableDeviceItem then
    begin
      Dev := CreateDeviceManagerInstance.GetDeviceByName(Item.DisplayName);
      if Dev <> nil then
        Dev.FillItemsWithCallBack('', FillItemsCallBack, Context);
    end;     
    if (Item is TPortableStorageItem) or (Item is TPortableDirectoryItem) then
    begin
      DevName := ExtractDeviceName(Item.Path);   
      DevItemPath := ExtractDeviceItemPath(Item.Path);

      Dev := CreateDeviceManagerInstance.GetDeviceByName(DevName);
      if Dev <> nil then
      begin
        ItemKey := PortableItemNameCache.GetKeyByPath(Dev.DeviceID, DevItemPath);
        Dev.FillItemsWithCallBack(ItemKey, FillItemsCallBack, Context);
      end;
    end;
  finally
    F(Context);
  end;
end;

function TPortableDeviceProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TPortableDeviceItem;
  Result := Result or Supports(Item.Path);
end;

function TPortableDeviceProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cDevicesPath, Path);
end;

function TPortableDeviceProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := False;
end;

{ TPortableDeviceItem }

constructor TPortableDeviceItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited CreateFromPath(APath, Options, ImageSize);
  FDevice := nil;
  FPath := cDevicesPath;
  FDisplayName := TA('Camera', 'Path');
  if Length(APath) > Length(cDevicesPath) then
  begin
    Delete(APath, 1, Length(cDevicesPath) + 1);
    FDisplayName := APath;
    FPath := cDevicesPath + '\' + FDisplayName;
  end;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TPortableDeviceItem.GetDevice: IPDevice;
var
  DevName: string;
begin
  if FDevice = nil then
  begin
    DevName := ExtractDeviceName(Path);
    FDevice := CreateDeviceManagerInstance.GetDeviceByName(DevName);
  end;

  Result := FDevice;
end;

function TPortableDeviceItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableDeviceItem.Create;
end;

function TPortableDeviceItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TPortableDeviceItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
  DevIcon: string;
begin
  F(FImage);

  DevIcon := 'DEVICE';
  if Device <> nil then
  begin
    case Device.DeviceType of
      dtCamera:
        DevIcon := 'CAMERA';
      dtVideo:
        DevIcon := 'VIDEO';
      dtPhone:
        DevIcon := 'PHONE';
    end;

  end;
  FindIcon(HInstance, DevIcon, ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
  if Icon = nil then
    FindIcon(HInstance, DevIcon, ImageSizeToIconSize16_32_48(ImageSize), 8, Icon);

  FImage := TPathImage.Create(Icon);
  Result := True;
end;

procedure TPortableDeviceItem.LoadDevice(Device: IPDevice);
begin
  FDevice := Device;
  LoadImage;
end;

{ TPortableStorageItem }

function TPortableStorageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableStorageItem.Create;
end;

function TPortableStorageItem.InternalGetParent: TPathItem;
var
  DevName: string;
  Device: IPDevice;
begin
  DevName := ExtractDeviceName(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DevName);
  if Device <> nil then
    Result := TPortableDeviceItem.CreateFromPath(cDevicesPath + '\' + Device.Name, PATH_LOAD_NO_IMAGE, 0)
  else
    Result := THomeItem.CreateFromPath('', PATH_LOAD_NO_IMAGE, 0);
end;

function TPortableStorageItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);

  FindIcon(HInstance, 'STORAGE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TPortableItem }

constructor TPortableItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FItem := nil;
  DisplayName := ExtractFileName(Path);
end;

function TPortableItem.GetItem: IPDItem;
var
  DevName: string;
  ItemPath: string;
  Device: IPDevice;
begin
  if FItem = nil then
  begin
    DevName := ExtractDeviceName(Path);
    ItemPath := ExtractDeviceItemPath(Path);
    Device := CreateDeviceManagerInstance.GetDeviceByName(DevName);
    if (Device <> nil) then
      FItem := Device.GetItemByPath(ItemPath);
  end;
  Result := FItem;
end;

procedure TPortableItem.LoadItem(AItem: IPDItem);
begin
  FItem := AItem;
end;

{ TPortableDirectoryItem }

function TPortableDirectoryItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableDirectoryItem.Create;
end;

function TPortableDirectoryItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);

  FindIcon(HInstance, 'DIRECTORY', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TPortableFSItem }

function TPortableFSItem.InternalGetParent: TPathItem;
var
  DeviceName,
  ParentKey: string;
  It: IPDItem;
  Device: IPDevice;
begin
  It := Self.Item;
  if It = nil then
    Exit(THomeItem.Create);

  DeviceName := ExtractDeviceName(Path);
  Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
  if Device = nil then
    Exit(THomeItem.Create);
  
  if It.ItemKey = '' then
    Exit(TPortableDeviceItem.CreateFromPath(cDevicesPath + '\' + DeviceName, PATH_LOAD_NO_IMAGE, 0));
  
  ParentKey := PortableItemNameCache.GetParentKey(It.DeviceID, It.ItemKey); 
  It := Device.GetItemByKey(ParentKey); 
  if It = nil then
    Exit(THomeItem.Create);

  Result := CreatePortableFSItem(It, PATH_LOAD_NO_IMAGE, 0);
end;

{ TPortableImageItem }

function TPortableImageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableImageItem.Create;
end;

function TPortableImageItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  It: IPDItem;
  Icon: TIcon;
  Bitmap: TBitmap;
begin
  It := Item;
  Icon := nil;
  F(FImage);
  
  if Item = nil then
  begin
    FindIcon(HInstance, 'SIMPLEFILE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
    FImage := TPathImage.Create(Icon);
    Exit(True);
  end;

  Bitmap := TBitmap.Create;
  try
    if Item.ExtractPreview(Bitmap) then
    begin
      KeepProportions(Bitmap, ImageSize, ImageSize);
      FImage := TPathImage.Create(Bitmap);
      Bitmap := nil;        
      Exit(True);
    end;
  finally
    F(Bitmap);
  end;

  FindIcon(HInstance, 'SIMPLEFILE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
  FImage := TPathImage.Create(Icon);
  Exit(True);
end;

{ TPortableVideoItem }

function TPortableVideoItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableVideoItem.Create;
end;

function TPortableVideoItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  It: IPDItem;
  Icon: TIcon;
  Bitmap: TBitmap;
begin
  It := Item;
  Icon := nil;
  F(FImage);
  
  if Item = nil then
  begin
    FindIcon(HInstance, 'SIMPLEFILE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
    FImage := TPathImage.Create(Icon);
    Exit(True);
  end;

  Bitmap := TBitmap.Create;
  try
    if Item.ExtractPreview(Bitmap) then
    begin 
      FImage := TPathImage.Create(Bitmap);
      Bitmap := nil;        
      Exit(True);
    end;
  finally
    F(Bitmap);
  end;  
  Exit(False);
end;

{ TPortableFileItem }

function TPortableFileItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableVideoItem.Create;
end;

function TPortableFileItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
  IconSize: Integer;
begin
  IconSize := ImageSizeToIconSize16_32_48(ImageSize);
  Icon := TAIcons.Instance.GetIconByExt(Path, False, IconSize, False);

  if Icon = nil then
    FindIcon(HInstance, 'SIMPLEFILE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);

  FImage := TPathImage.Create(Icon);
  Exit(True);
end;

initialization
  PathProviderManager.RegisterProvider(TPortableDeviceProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPortableDeviceProvider);

end.
