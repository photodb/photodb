unit uPortableClasses;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SyncObjs,
  VCL.Graphics,
  uMemory;

const
  DEFAULT_PORTABLE_DEVICE_NAME = 'Unknown Device';
  EMPTY_PATH = '?\\NULL';

type
  TDeviceType = (dtCamera, dtVideo, dtPhone, dtOther);
  TPortableItemType = (piStorage, piDirectory, piImage, piVideo, piFile);

  IPDItem = interface;
  IPDevice = interface;

  TFillItemsCallBack = procedure(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer) of object;
  TFillDevicesCallBack = procedure(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer) of object;

  IPBaseInterface = interface
    function GetErrorCode: HRESULT;
    property ErrorCode: HRESULT read GetErrorCode;
  end;

  IPDItem = interface(IPBaseInterface)
    function GetItemType: TPortableItemType;
    function GetName: string;
    function GetItemKey: string;
    function GetFullSize: Int64;
    function GetFreeSize: Int64;
    function GetItemDate: TDateTime;
    function GetDeviceID: string;
    function GetDeviceName: string;
    function ExtractPreview(var PreviewImage: TBitmap): Boolean;
    function SaveToStream(S: TStream): Boolean;
    function GetInnerInterface: IUnknown;
    property ItemType: TPortableItemType read GetItemType;
    property Name: string read GetName;
    property ItemKey: string read GetItemKey;
    property FullSize: Int64 read GetFullSize;
    property FreeSize: Int64 read GetFreeSize;
    property ItemDate: TDateTime read GetItemDate;
    property DeviceID: string read GetDeviceID;
    property DeviceName: string read GetDeviceName;
    property InnerInterface: IUnknown read GetInnerInterface;
  end;

  IPDevice = interface(IPBaseInterface)
    function GetName: string;
    function GetDeviceID: string;
    function GetBatteryStatus: Byte;
    function GetDeviceType: TDeviceType;
    procedure FillItems(ItemKey: string; Items: TList<IPDItem>);
    procedure FillItemsWithCallBack(ItemKey: string; CallBack: TFillItemsCallBack; Context: Pointer);
    function GetItemByKey(ItemKey: string): IPDItem;
    function GetItemByPath(Path: string): IPDItem;
    function Delete(ItemKey: string): Boolean;
    property Name: string read GetName;
    property DeviceID: string read GetDeviceID;
    property BatteryStatus: Byte read GetBatteryStatus;
    property DeviceType: TDeviceType read GetDeviceType;
  end;

  IPManager = interface(IPBaseInterface)
    procedure FillDevices(Devices: TList<IPDevice>);
    procedure FillDevicesWithCallBack(CallBack: TFillDevicesCallBack; Context: Pointer);
    function GetDeviceByName(DeviceName: string): IPDevice;
  end;

  TPortableItemName = class(TObject)
  private
    FDevID: string;
    FItemKey: string;
    FParentItemKey: string;
    FPath: string;
  public
    constructor Create(ADevID: string; AItemKey: string; AParentItemKey: string; APath: string);
    property DevID: string read FDevID;
    property ItemKey: string read FItemKey;
    property ParentItemKey: string read FParentItemKey;
    property Path: string read FPath;
  end;

  ///////////////////////////////////////
  ///
  ///  Connection between path's and item keys (WIA/WPD)
  ///
  ///////////////////////////////////////
  TPortableItemNameCache = class(TObject)
  private
    FSync: TCriticalSection;
    FItems: TList<TPortableItemName>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearDeviceCache(DevID: string);
    function GetPathByKey(DevID: string; ItemKey: string): string;
    function GetParentKey(DevID: string; ItemKey: string): string;
    function GetKeyByPath(DevID: string; Path: string): string;
    procedure AddName(DevID: string; ItemKey, ParentKey: string; Path: string);
  end;

function PortableItemNameCache: TPortableItemNameCache;

implementation

var
  FPortableItemNameCache: TPortableItemNameCache = nil;

function PortableItemNameCache: TPortableItemNameCache;
begin
  if FPortableItemNameCache = nil then
    FPortableItemNameCache := TPortableItemNameCache.Create;

  Result := FPortableItemNameCache
end;

{ TPortableItemCache }

procedure TPortableItemNameCache.AddName(DevID, ItemKey, ParentKey, Path: string);
var
  Item: TPortableItemName;

begin
  FSync.Enter;
  try
    for Item in FItems do
      if (Item.DevID = DevID) and (Item.ItemKey = ItemKey) then
      begin
        Item.FPath := Path;
        Exit;
      end;

    Item := TPortableItemName.Create(DevID, ItemKey, ParentKey, Path);
    FItems.Add(Item);
  finally
    FSync.Leave;
  end;
end;

procedure TPortableItemNameCache.ClearDeviceCache(DevID: string);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := FItems.Count - 1 downto 0 do
      if FItems[I].FDevID = DevID then
        FItems.Delete(I);
  finally
    FSync.Leave;
  end;
end;

constructor TPortableItemNameCache.Create;
begin
  FSync := TCriticalSection.Create;
  FItems := TList<TPortableItemName>.Create;
end;

destructor TPortableItemNameCache.Destroy;
begin
  F(FSync);
  FreeList(FItems);
  inherited;
end;

function TPortableItemNameCache.GetKeyByPath(DevID, Path: string): string;
var
  I: Integer;
begin
  Result := EMPTY_PATH;
  FSync.Enter;
  try
    for I := FItems.Count - 1 downto 0 do
      if (FItems[I].FDevID = DevID) and (FItems[I].Path = Path) then
        Result := FItems[I].ItemKey;
  finally
    FSync.Leave;
  end;
end;

function TPortableItemNameCache.GetParentKey(DevID, ItemKey: string): string;
var
  I: Integer;
begin
  Result := '';
  FSync.Enter;
  try
    for I := FItems.Count - 1 downto 0 do
      if (FItems[I].FDevID = DevID) and (FItems[I].ItemKey = ItemKey) then
        Result := FItems[I].ParentItemKey;
  finally
    FSync.Leave;
  end;
end;

function TPortableItemNameCache.GetPathByKey(DevID, ItemKey: string): string;
var
  I: Integer;
begin
  Result := '';
  FSync.Enter;
  try
    for I := FItems.Count - 1 downto 0 do
      if (FItems[I].FDevID = DevID) and (FItems[I].ItemKey = ItemKey) then
        Result := FItems[I].Path;
  finally
    FSync.Leave;
  end;
end;

{ TPortableItemName }

constructor TPortableItemName.Create(ADevID, AItemKey, AParentItemKey, APath: string);
begin
  FDevID := ADevID;
  FItemKey := AItemKey;
  FParentItemKey := AParentItemKey;
  FPath := APath;
end;

initialization

finalization
  F(FPortableItemNameCache);

end.
