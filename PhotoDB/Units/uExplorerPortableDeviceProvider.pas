unit uExplorerPortableDeviceProvider;

interface

uses
  Winapi.Windows,
  System.Types,
  Generics.Collections,
  uPathProviders,
  Vcl.Graphics,
  uMemory,
  uSysUtils,
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
  uAssociatedIcons,
  uPortableDeviceUtils,
  uShellThumbnails,
  uDBForm,
  uShellIntegration,
  uAssociations,
  uIconUtils,
  TLayered_Bitmap,
  uShellNamespaceUtils;

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
    function GetIsDirectory: Boolean; override;
    property Device: IPDevice read GetDevice;
  public
    procedure LoadDevice(Device: IPDevice);
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TPortableItem = class(TPathItem)
  private
    FItem: IPDItem;
    FItemSize: Int64;
    function GetItem: IPDItem;
  protected
    function GetFileSize: Int64; override;
  public
    function Copy: TPathItem; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    procedure LoadItem(AItem: IPDItem);
    procedure ResetItem;
    property Item: IPDItem read GetItem;
  end;

  TPortableStorageItem = class(TPortableItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;

  TPortableFSItem = class(TPortableItem)
  private
    function GetDate: TDateTime;
  protected
    function GetFileSize: Int64; override;
    function InternalGetParent: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    property FileSize: Int64 read GetFileSize;
    property Date: TDateTime read GetDate;
  end;
  
  TPortableDirectoryItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
  end;

  TPortableImageItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  end;

  TPortableVideoItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  end;
   
  TPortableFileItem = class(TPortableFSItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  end;

type
  TPortableDeviceProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
    procedure FillDevicesCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FillItemsCallBack(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
    function Delete(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
    function ShowProperties(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; overload; override;
    function Supports(Path: string): Boolean; overload; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

function CreatePortableFSItem(Item: IPDItem; Options, ImageSize: Integer): TPortableItem;

implementation

function IsDeviceStoragePath(Path: string): Boolean;
begin
  Result := False;
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    Result := (Pos('\', Path) > 0) and (Pos('\', Path) = LastDelimiter('\', Path));
  end;
end;

function CreatePortableFSItem(Item: IPDItem; Options, ImageSize: Integer): TPortableItem;     
var
  ItemPath: string;
  ItemType: TPortableItemType;
begin
  Result := nil;
  ItemPath := PortableItemNameCache.GetPathByKey(Item.DeviceID, Item.ItemKey);  
  ItemPath := cDevicesPath + '\' + Item.DeviceName + ItemPath;

  ItemType := Item.ItemType;
  if IsVideoFile(ItemPath) then
    ItemType := piVideo;
  if IsGraphicFile(ItemPath) then
    ItemType := piImage;

  case ItemType of
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
    Exit(nil);

  Item := Device.GetItemByPath(ItemPath);
  if Item = nil then
    Exit(nil);

  Result := CreatePortableFSItem(Item, PATH_LOAD_NO_IMAGE, 0);
end;

{ TCameraProvider }

function TPortableDeviceProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if IsDeviceItemPath(Path) then
    Result := CreateItemByPath(Path)
  else if IsDevicePath(Path) then
    Result := TPortableDeviceItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TPortableDeviceProvider.Delete(Sender: TObject; Items: TPathItemCollection;
  Options: TPathFeatureOptions): Boolean;
var
  Item: TPathItem;
  FSItem: TPortableFSItem;
  Form: TDBForm;
  DeviceName, DevicePath: string;
  Device: IPDevice;
  DItem: IPDItem;
  MessageText: string;
  FDO: TPathFeatureDeleteOptions;
  Silent: Boolean;
begin
  Result := False;
  Form := nil;
  if Sender is TDBForm then
    Form := TDBForm(Sender);

  FDO := TPathFeatureDeleteOptions(Options);

  Device := nil;
  DeviceName := '';
  MessageText := '';

  if Items.Count = 0 then
    Exit;

  Silent := False;
  if FDO <> nil then
    Silent := FDO.Silent;

  if Items.Count = 1 then
    MessageText := FormatEx(L('Do you really want to delete object "{0}"?'), [Items[0].DisplayName])
  else
    MessageText := FormatEx(L('Do you really want to delete {0} objects?'), [Items.Count]);

  if Silent or (ID_OK = MessageBoxDB(Form.Handle, MessageText, L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING)) then
  begin
    for Item in Items do
    begin
      FSItem := Item as TPortableFSItem;
      if FSItem <> nil then
      begin
        if (Device = nil) or (DeviceName <> ExtractDeviceName(FSItem.Path)) then
        begin
          DeviceName := ExtractDeviceName(FSItem.Path);
          DevicePath := ExtractDeviceItemPath(FSItem.Path);
          Device := CreateDeviceManagerInstance.GetDeviceByName(DeviceName);
        end;
        if Device <> nil then
        begin
          DevicePath := ExtractDeviceItemPath(FSItem.Path);
          DItem := Device.GetItemByPath(DevicePath);
          if DItem <> nil then
            Result := Device.Delete(DItem.ItemKey);
        end;
      end;
    end;
  end;
end;

function TPortableDeviceProvider.ExecuteFeature(Sender: TObject; Items: TPathItemCollection;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Items, Feature, Options);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(Sender, Items, Options);

  if Feature = PATH_FEATURE_PROPERTIES then
    Result := ShowProperties(Sender, Items, Options);
end;

function TPortableDeviceProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  PortableItem: TPathItem;
  Ico: TLayeredBitmap;
begin
  Result := False;
  PortableItem := PathProviderManager.CreatePathItem(Item.Path);
  try
    if (PortableItem is TPortableImageItem) or (PortableItem is TPortableVideoItem) or (PortableItem is TPortableDeviceItem) then
    begin
      PortableItem.LoadImage(PATH_LOAD_NORMAL, Min(MaxWidth, MaxHeight));
      if (PortableItem.Image <> nil) and (PortableItem.Image.Bitmap <> nil) then
      begin
        AssignBitmap(Bitmap, PortableItem.Image.Bitmap);
        Result := not Bitmap.Empty;
      end;
      if (PortableItem.Image <> nil) and (PortableItem.Image.Icon <> nil) then
      begin
        Ico := TLayeredBitmap.Create;
        try
          TThread.Synchronize(nil,
            procedure
            begin
              Ico.LoadFromHIcon(PortableItem.Image.Icon.Handle, ImageSizeToIconSize16_32_48(MaxWidth), ImageSizeToIconSize16_32_48(MaxHeight));
            end
          );
          AssignBitmap(Bitmap, Ico);
          Result := not Bitmap.Empty;
        finally
          F(Ico);
        end;
      end;
    end;
  finally
    F(PortableItem);
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
    if not Item.IsVisible then
      Continue;

    if ((C.Options and PATH_LOAD_DIRECTORIES_ONLY > 0) and (Item.ItemType <> piStorage) and (Item.ItemType <> piDirectory)) then
      Continue;

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

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

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

function TPortableDeviceProvider.ShowProperties(Sender: TObject;
  Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
var
  Form: TDBForm;
  Path: string;
  List: TStrings;
  Item: TPathItem;
begin
  Result := False;
  Form := TDBForm(Sender);

  if Items.Count = 0 then
    Exit;

  if Items.Count = 1 then
    Result := ExecuteShellPathRelativeToMyComputerMenuAction(Form.Handle, PhotoDBPathToDevicePath(Items[0].Path), nil, Point(0, 0), nil, 'Properties')
  else
  begin
    Path := PhotoDBPathToDevicePath(ExtractFileDir(Items[0].Path));
    List := TStringList.Create;
    try
      for Item in Items do
        List.Add(ExtractFileName(Item.Path));

      Result := ExecuteShellPathRelativeToMyComputerMenuAction(Form.Handle, Path, List, Point(0, 0), nil, 'Properties');
    finally
      F(List);
    end;
  end;
end;

function TPortableDeviceProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cDevicesPath, Path);
end;

function TPortableDeviceProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_DELETE;
  Result := Result or (Feature = PATH_FEATURE_PROPERTIES);
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

function TPortableDeviceItem.GetIsDirectory: Boolean;
begin
  Result := True;
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

function TPortableStorageItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TPortableStorageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableStorageItem.Create;
end;

function TPortableStorageItem.InternalGetParent: TPathItem;
var
  DevName: string;
begin
  DevName := ExtractDeviceName(Path);

  Result := TPortableDeviceItem.CreateFromPath(cDevicesPath + '\' + DevName, PATH_LOAD_NO_IMAGE, 0);
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

function TPortableItem.Copy: TPathItem;
begin
  Result := inherited Copy;
  //WIA will be null, WPD the same item
  //WIA doesn't support calls from other threads so we can'r use the same item
  if FItem <> nil then
    TPortableItem(Result).FItem := FItem.Clone
  else
    TPortableItem(Result).FItem := nil;

  TPortableItem(Result).FItemSize := FItemSize;
end;

constructor TPortableItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FItem := nil;
  FItemSize := 0;
  DisplayName := ExtractFileName(Path);
end;

function TPortableItem.GetFileSize: Int64;
begin
  Result := FItemSize;
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

procedure TPortableItem.ResetItem;
begin
  FItem := nil;
end;

{ TPortableDirectoryItem }

function TPortableDirectoryItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

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

function TPortableFSItem.GetFileSize: Int64;
begin
  Result := 0;
  if Item <> nil then
    Result := Item.FullSize;
end;

function TPortableFSItem.InternalGetParent: TPathItem;
var
  Path, ParentPath: string;
  P: Integer;
begin
  Path := Self.Path;
  Path := ExcludeTrailingBackslash(Path);
  P := LastDelimiter('\', Path);
  if P < 2 then
    Exit(THomeItem.Create);

  ParentPath := System.Copy(Path, 1, P - 1);

  if IsDeviceItemPath(ParentPath) then
  begin
    if not IsWPDSupport then
      Exit(TPortableDirectoryItem.CreateFromPath(ParentPath, PATH_LOAD_NO_IMAGE, 0))
    else
    begin
      if IsDeviceStoragePath(ParentPath) then
        Exit(TPortableStorageItem.CreateFromPath(ParentPath, PATH_LOAD_NO_IMAGE, 0))
      else
        Exit(TPortableDirectoryItem.CreateFromPath(ParentPath, PATH_LOAD_NO_IMAGE, 0))
    end;
  end;

  if IsDevicePath(ParentPath) then
    Exit(TPortableDeviceItem.CreateFromPath(ParentPath, PATH_LOAD_NO_IMAGE, 0));

  Exit(THomeItem.Create);
end;

function TPortableFSItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  It: IPDItem;
  Icon: TIcon;
  Bitmap: TBitmap;
  Ico: HIcon;
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

      if IsVideoFile(Path) then
        UpdateBitmapToVideo(Bitmap);

      FImage := TPathImage.Create(Bitmap);
      Bitmap := nil;
      Exit(True);
    end;
  finally
    F(Bitmap);
  end;

  Ico := ExtractDefaultAssociatedIcon('*' + ExtractFileExt(Path), ImageSizeToIconSize16_32_48(ImageSize));
  if Ico <> 0 then
  begin
    FImage := TPathImage.Create(Ico);
    Exit(True);
  end;

  FindIcon(HInstance, 'SIMPLEFILE', ImageSizeToIconSize16_32_48(ImageSize), 32, Icon);
  FImage := TPathImage.Create(Icon);
  Exit(True);
end;

function TPortableFSItem.GetDate: TDateTime;
begin
  Result := MinDateTime;
  if Item <> nil then
    Result := Item.ItemDate;
end;

{ TPortableImageItem }

function TPortableImageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableImageItem.Create;
end;

{ TPortableVideoItem }

function TPortableVideoItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableVideoItem.Create;
end;

{ TPortableFileItem }

function TPortableFileItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableVideoItem.Create;
end;

initialization
  PathProviderManager.RegisterProvider(TPortableDeviceProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPortableDeviceProvider);

end.
