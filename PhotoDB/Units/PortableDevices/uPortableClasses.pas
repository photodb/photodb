unit uPortableClasses;

interface

uses
  Generics.Collections,
  Classes,
  Graphics;

const
  DEFAULT_PORTABLE_DEVICE_NAME = 'Unknown Device';

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
    function ExtractPreview(PreviewImage: TBitmap): Boolean;
    function SaveToStream(S: TStream): Boolean;
    property ItemType: TPortableItemType read GetItemType;
    property Name: string read GetName;
    property ItemKey: string read GetItemKey;
    property FullSize: Int64 read GetFullSize;
    property FreeSize: Int64 read GetFreeSize;
    property ItemDate: TDateTime read GetItemDate;
  end;

  IPDevice = interface(IPBaseInterface)
    function GetName: string;
    function GetDeviceID: string;
    function GetBatteryStatus: Byte;
    function GetDeviceType: TDeviceType;
    procedure FillItems(ItemKey: string; Items: TList<IPDItem>);
    procedure FillItemsWithCallBack(ItemKey: string; CallBack: TFillItemsCallBack; Context: Pointer);
    function GetItemByKey(ItemKey: string): IPDItem;
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

implementation

end.
