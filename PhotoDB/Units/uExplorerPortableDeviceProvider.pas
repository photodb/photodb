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
  uPortableDeviceManager;

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

  TPortableStorageItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TCameraImageItem = class(TPathItem)
  private
    FImageName: string;
    FItemID: string;
    function GetCameraName: string;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    procedure ReadFromCameraImage(CI: IPDItem; Options, ImageSize: Integer);
    property ImageName: string read FImageName;
    property ItemID: string read FItemID;
    property CameraName: string read GetCameraName;
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

function IsDevicePath(Path: string): Boolean;
begin
  Result := False;
  if StartsText(cDevicesPath + '\', Path) then
  begin
    Delete(Path, 1, Length(cDevicesPath + '\'));
    Result := Pos('\', Path) = 0;
  end;
end;

function IsDeviceImagePath(Path: string): Boolean;
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
      P := Length(Path);

    Result := Copy(Path, 1, P - 1);
  end;
end;

{ TCameraProvider }

function TPortableDeviceProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if IsDeviceImagePath(Path) then
    Result := TCameraImageItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
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
  CII: TCameraImageItem;
begin
  CII := TCameraImageItem.CreateFromPath(Item.Path, PATH_LOAD_NORMAL, 0);
  try
    CII.LoadImage(PATH_LOAD_NORMAL, Min(MaxWidth, MaxHeight));
    Result := CII.Image <> nil;

    if Result then
      Bitmap.Assign(CII.Image.Bitmap);
  finally
    F(CII);
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
//  SI: TPortableStorageItem;
begin
  C := TPDContext(Context);
  ACancel := False;

  for Item in Packet do
  begin
    case Item.ItemType of
      piStorage:
      begin
        //SI := TPortableStorageItem.CreateFromPath(cDevicesPath + '\' + Manager[I].CameraName + '\' + WCI.FileName, Options, ImageSize);
        //CII.ReadFromCameraImage(WCI, Options, ImageSize);
        //List.Add(CII);
      end;
      piDirectory,
      piImage,
      piVideo,
      piFile:
    end;
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
  Manager: IPManager;
  DI: TPortableDeviceItem;
  Dev: IPDevice;
  Context: TPDContext;
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
      DI := TPortableDeviceItem(Item);

      Dev := Manager.GetDeviceByName(DI.DisplayName);
      if Dev <> nil then
        Dev.FillItemsWithCallBack('', FillItemsCallBack, Context);

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
begin
  if FDevice = nil then
    FDevice := nil;

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
  FindIcon(HInstance, DevIcon, ImageSize, 32, Icon);
  if Icon = nil then
    FindIcon(HInstance, DevIcon, ImageSize, 8, Icon);

  FImage := TPathImage.Create(Icon);
  Result := True;
end;

procedure TPortableDeviceItem.LoadDevice(Device: IPDevice);
begin
  FDevice := Device;
  LoadImage;
end;

{ TCameraImageItem }

procedure TCameraImageItem.Assign(Item: TPathItem);
begin
  inherited;

end;

constructor TCameraImageItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited CreateFromPath(APath, Options, ImageSize);
  FDisplayName := ExtractFileName(APath)
end;

function TCameraImageItem.GetCameraName: string;
begin
  Result := ExtractDeviceName(FPath);
end;

function TCameraImageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TCameraImageItem.Create;
end;

function TCameraImageItem.InternalGetParent: TPathItem;
begin
  Result := TPortableDeviceItem.CreateFromPath(ExtractDeviceName(FPath), PATH_LOAD_NO_IMAGE, 0);
end;

function TCameraImageItem.LoadImage(Options, ImageSize: Integer): Boolean;
{var
  Bitmap: TBitmap;
  Manager: TWIAManager;
  CameraName, ItemName: string;      }
begin
{  Manager := TWIAManager.Create;
  try
    CameraName := ExtractCameraName(Path);
    ItemName := ExtractFileName(Path);
    Bitmap := TBitmap.Create;
    try
      Result := Manager.GetImagePreview(CameraName, ItemName, Bitmap);
      if Result then
      begin
        FImage := TPathImage.Create(Bitmap);
        Bitmap := nil;
      end;
    finally
      F(Bitmap);
    end;

  finally
    F(Manager);
  end;    }
end;

procedure TCameraImageItem.ReadFromCameraImage(CI: IPDItem; Options, ImageSize: Integer);
{var
  Bitmap: TBitmap;   }
begin
{  F(FImage);
  Bitmap := CI.ExtractPreview;

  if Options and PATH_LOAD_FOR_IMAGE_LIST <> 0 then
    CenterBitmap24To32ImageList(Bitmap, ImageSize);

  FImage := TPathImage.Create(Bitmap);  }
end;

{ TPortableStorageItem }

constructor TPortableStorageItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;

end;

function TPortableStorageItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPortableStorageItem.Create;
end;

function TPortableStorageItem.InternalGetParent: TPathItem;
begin

end;

function TPortableStorageItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);

  FindIcon(HInstance, 'STORAGE', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

initialization
  PathProviderManager.RegisterProvider(TPortableDeviceProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPortableDeviceProvider);

end.
