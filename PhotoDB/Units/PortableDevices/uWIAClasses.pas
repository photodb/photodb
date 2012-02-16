unit uWIAClasses;

interface

uses
  uMemory,
  System.Classes,
  Generics.Collections,
  Winapi.Windows,
  Vcl.Graphics,
  uPortableClasses,
  uWIAInterfaces,
  Winapi.ActiveX,
  System.SysUtils,
  GraphicsBaseTypes,
  System.Win.ComObj,
  uBitmapUtils,
  System.SyncObjs;

const
  WIA_ERROR_BUSY = -2145320954;

type
  TWIADeviceManager = class;
  TWIADevice = class;
  TWIAEventCallBack = class;

  TWIAItem = class(TInterfacedObject, IPDItem)
  private
    FDevice: TWIADevice;
    FItem: IWIAItem;
    FItemType: TPortableItemType;
    FName: string;
    FItemKey: string;
    FErrorCode: HRESULT;
    FFullSize, FFreeSize: Int64;
    FItemDate: TDateTime;
    FDeviceID: string;
    FDeviceName: string;
    FVisible: Boolean;
    procedure ErrorCheck(Code: HRESULT);
    procedure ReadProps;
  public
    constructor Create(ADevice: TWIADevice; AItem: IWIAItem);
    function GetErrorCode: HRESULT;
    function GetItemType: TPortableItemType;
    function GetName: string;
    function GetItemKey: string;
    function GetFullSize: Int64;
    function GetFreeSize: Int64;
    function GetItemDate: TDateTime;
    function GetDeviceID: string;
    function GetDeviceName: string;
    function GetIsVisible: Boolean;
    function GetInnerInterface: IUnknown;
    function ExtractPreview(var PreviewImage: TBitmap): Boolean;
    function SaveToStream(S: TStream): Boolean;
    function SaveToStreamEx(S: TStream; CallBack: TPDProgressCallBack): Boolean;
    function Clone: IPDItem;
  end;

  TWIADevice = class(TInterfacedObject, IPDevice)
  private
    FManager: TWIADeviceManager;
    FErrorCode: HRESULT;
    FDeviceID: string;
    FDeviceName: string;
    FDeviceType: TDeviceType;
    FBatteryStatus: Byte;
    FRoot: IWIAItem;
    function InternalGetItemByKey(ItemKey: string): IWiaItem;
    procedure ErrorCheck(Code: HRESULT);
    procedure FindItemByKeyCallBack(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
    procedure FillItemsCallBack(ParentKey: string; Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
  public
    constructor Create(AManager: TWIADeviceManager; PropList: IWiaPropertyStorage);
    function GetErrorCode: HRESULT;
    function GetName: string;
    function GetDeviceID: string;
    function GetBatteryStatus: Byte;
    function GetDeviceType: TDeviceType;
    procedure FillItems(ItemKey: string; Items: TList<IPDItem>);
    procedure FillItemsWithCallBack(ItemKey: string; CallBack: TFillItemsCallBack; Context: Pointer);
    function GetItemByKey(ItemKey: string): IPDItem;
    function GetItemByPath(Path: string): IPDItem;
    function Delete(ItemKey: string): Boolean;
    property Manager: TWIADeviceManager read FManager;
  end;

  TWIADeviceManager = class(TInterfacedObject, IPManager)
  private
    FErrorCode: HRESULT;
    FManager: IWiaDevMgr;
    FEventCallBack: TWIAEventCallBack;
    FObjEventDeviceConnected: IUnknown;
    FObjEventDeviceDisconnected: IUnknown;
    FObjEventCallBackCreated: IUnknown;
    FObjEventCallBackDeleted: IUnknown;
    procedure ErrorCheck(Code: HRESULT);
    procedure FillDeviceCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FindDeviceByNameCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
    procedure FindDeviceByIdCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
  public
    constructor Create;
    function GetErrorCode: HRESULT;
    procedure FillDevices(Devices: TList<IPDevice>);
    procedure FillDevicesWithCallBack(CallBack: TFillDevicesCallBack; Context: Pointer);
    function GetDeviceByName(DeviceName: string): IPDevice;
    function GetDeviceByID(DeviceID: string): IPDevice;
    property Manager: IWiaDevMgr read FManager;
  end;

  TWiaDataCallback = class(TInterfacedObject, IWiaDataCallback)
  private
    FItem: TWIAItem;
    FStream: TStream;
    FCallBack: TPDProgressCallBack;
  public
    constructor Create(Item: TWIAItem; Stream: TStream; CallBack: TPDProgressCallBack);
    function BandedDataCallback(lMessage: LongInt;
      lStatus: LongInt;
      lPercentComplete: LongInt;
      lOffset: LongInt;
      lLength: LongInt;
      lReserved: LongInt;
      lResLength: LongInt;
      pbBuffer: Pointer): HRESULT; stdcall;
  end;

  TFindDeviceContext = class(TObject)
  public
    Name: string;
    Device: IPDevice;
  end;

  TFindItemContext = class(TObject)
  public
    ItemKey: string;
    Item: IPDItem;
  end;

  TWIAEventCallBack = class(TInterfacedObject, IWiaEventCallback)
    function ImageEventCallback(
            pEventGUID: PGUID;
            bstrEventDescription: PChar;
            bstrDeviceID: PChar;
            bstrDeviceDescription: PChar;
            dwDeviceType: DWORD;
            bstrFullItemName: PChar;
            var pulEventType: PULONG;
            ulReserved: ULONG) : HRESULT; stdcall;
  end;

implementation

var
  //only one request to WIA at moment - limitation of WIA
  //http://msdn.microsoft.com/en-us/library/windows/desktop/ms630350%28v=vs.85%29.aspx
  FLock: TCriticalSection = nil;

{ TWDManager }

constructor TWIADeviceManager.Create;
begin
  FErrorCode := S_OK;
  FManager := nil;
  FEventCallBack := TWIAEventCallBack.Create;
  FObjEventCallBackCreated := nil;
  FObjEventCallBackDeleted := nil;
  ErrorCheck(CoCreateInstance(CLSID_WiaDevMgr, nil, CLSCTX_LOCAL_SERVER, IID_IWiaDevMgr, FManager));

  if FManager <> nil then
  begin
    FManager.RegisterEventCallbackInterface(0, nil, @WIA_EVENT_DEVICE_CONNECTED, FEventCallBack, FObjEventDeviceConnected);
    FManager.RegisterEventCallbackInterface(0, nil, @WIA_EVENT_DEVICE_DISCONNECTED, FEventCallBack, FObjEventDeviceDisconnected);
    FManager.RegisterEventCallbackInterface(0, nil, @WIA_EVENT_ITEM_CREATED, FEventCallBack, FObjEventCallBackCreated);
    FManager.RegisterEventCallbackInterface(0, nil, @WIA_EVENT_ITEM_DELETED, FEventCallBack, FObjEventCallBackDeleted);
  end;
end;

procedure TWIADeviceManager.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

procedure TWIADeviceManager.FillDeviceCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
begin
  TList<IPDevice>(Context).AddRange(Packet);
end;

procedure TWIADeviceManager.FillDevices(Devices: TList<IPDevice>);
begin
  FillDevicesWithCallBack(FillDeviceCallBack, Devices);
end;

procedure TWIADeviceManager.FillDevicesWithCallBack(CallBack: TFillDevicesCallBack;
  Context: Pointer);
var
  Cancel: Boolean;
  HR: HRESULT;
  pWiaEnumDevInfo: IEnumWIA_DEV_INFO;
  pWiaPropertyStorage: IWiaPropertyStorage;
  pceltFetched: ULONG;

  Device: TWIADevice;
  DevList: TList<IPDevice>;
begin
  Cancel := False;

  if FManager = nil then
    Exit;

  DevList := TList<IPDevice>.Create;
  try
    pWiaEnumDevInfo := nil;

    FLock.Enter;
    try
      HR := FManager.EnumDeviceInfo(WIA_DEVINFO_ENUM_LOCAL, pWiaEnumDevInfo);
    finally
      FLock.Leave;
    end;

    //
    // Loop until you get an error or pWiaEnumDevInfo->Next returns
    // S_FALSE to signal the end of the list.
    //
    while SUCCEEDED(HR) do
    begin
      //
      // Get the next device's property storage interface pointer
      //
      pWiaPropertyStorage := nil;

      FLock.Enter;
      try
        HR := pWiaEnumDevInfo.Next(1, pWiaPropertyStorage, @pceltFetched);
      finally
        FLock.Leave;
      end;
      //
      // pWiaEnumDevInfo->Next will return S_FALSE when the list is
      // exhausted, so check for S_OK before using the returned
      // value.
      //
      if pWiaPropertyStorage = nil then
        Break;

      if SUCCEEDED(HR) and (pWiaPropertyStorage <> nil) then
      begin
        DevList.Clear;
        Device := TWIADevice.Create(Self, pWiaPropertyStorage);
        DevList.Add(Device);
        CallBack(DevList, Cancel, Context);
        if Cancel then
          Break;
      end;
    end;
  finally
    F(DevList);
  end;
end;

procedure TWIADeviceManager.FindDeviceByIdCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  Device: IPDevice;
  C: TFindDeviceContext;
begin
  C := TFindDeviceContext(Context);

  for Device in Packet do
    if AnsiUpperCase(Device.DeviceID) = AnsiUpperCase(C.Name) then
    begin
      C.Device := Device;
      Cancel := True;
    end;
end;

procedure TWIADeviceManager.FindDeviceByNameCallBack(Packet: TList<IPDevice>;
  var Cancel: Boolean; Context: Pointer);
var
  Device: IPDevice;
  C: TFindDeviceContext;
begin
  C := TFindDeviceContext(Context);

  for Device in Packet do
    if AnsiUpperCase(Device.Name) = AnsiUpperCase(C.Name) then
    begin
      C.Device := Device;
      Cancel := True;
    end;
end;

function TWIADeviceManager.GetDeviceByID(DeviceID: string): IPDevice;
var
  Context: TFindDeviceContext;
begin
  Context := TFindDeviceContext.Create;
  try
    Context.Name := DeviceID;
    try
      FillDevicesWithCallBack(FindDeviceByIdCallBack, Context);
    finally
      Result := Context.Device;
    end;
  finally
    F(Context);
  end;
end;


function TWIADeviceManager.GetDeviceByName(DeviceName: string): IPDevice;
var
  Context: TFindDeviceContext;
begin
  Context := TFindDeviceContext.Create;
  try
    Context.Name := DeviceName;
    try
      FillDevicesWithCallBack(FindDeviceByNameCallBack, Context);
    finally
      Result := Context.Device;
    end;
  finally
    F(Context);
  end;
end;

function TWIADeviceManager.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

{ TWIADevice }

constructor TWIADevice.Create(AManager: TWIADeviceManager; PropList: IWiaPropertyStorage);
var
  HR: HResult;
  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
  bstrDeviceID: PChar;
begin
  FManager := AManager;
  FDeviceID := '';
  FDeviceName := DEFAULT_PORTABLE_DEVICE_NAME;
  FDeviceType := dtOther;
  FBatteryStatus := 255;

  Setlength(PropSpec, 3);
  //
  // Device id
  //
  PropSpec[0].ulKind := PRSPEC_PROPID;
  PropSpec[0].propid := WIA_DIP_DEV_ID;
  //
  // Device Name
  //
  PropSpec[1].ulKind := PRSPEC_PROPID;
  PropSpec[1].propid := WIA_DIP_DEV_NAME;
  //
  // Device type
  //
  PropSpec[2].ulKind := PRSPEC_PROPID;
  PropSpec[2].propid := WIA_DIP_DEV_TYPE;

  SetLength(PropVariant, 3);
  FLock.Enter;
  try
    HR := PropList.ReadMultiple(3, @PropSpec[0], @PropVariant[0]);
  finally
    FLock.Leave;
  end;

  if SUCCEEDED(HR) then
  begin
    FDeviceID := PropVariant[0].bstrVal;
    FDeviceName := PropVariant[1].bstrVal;
    case HIWORD(PropVariant[2].lVal) of
      CameraDeviceType:
        FDeviceType := dtCamera;
      VideoDeviceType:
        FDeviceType := dtVideo;
    end;

    bstrDeviceID := SysAllocString(PChar(FDeviceID));
    try
      FLock.Enter;
      try
        HR := Manager.FManager.CreateDevice(bstrDeviceID, FRoot);
      finally
        FLock.Leave;
      end;
    finally
      SysFreeString(bstrDeviceID);
    end;

    if SUCCEEDED(HR) and (FRoot <> nil) then
    begin
      HR := FRoot.QueryInterface(IWIAPropertyStorage, PropList);
      if SUCCEEDED(HR) then
      begin
        Setlength(PropSpec, 1);
        PropSpec[0].ulKind := PRSPEC_PROPID;
        PropSpec[0].propid := WIA_DPC_BATTERY_STATUS;
        SetLength(PropVariant, 1);
        FLock.Enter;
        try
          HR := PropList.ReadMultiple(1, @PropSpec[0], @PropVariant[0]);
        finally
          FLock.Leave;
        end;
        if SUCCEEDED(HR) then
          FBatteryStatus := PropVariant[0].iVal;

      end else
        ErrorCheck(HR);
    end;
  end;
end;

function TWIADevice.Delete(ItemKey: string): Boolean;
var
  Item: IPDItem;
begin
  Result := False;
  Item := GetItemByKey(ItemKey);
  if Item <> nil then
  begin
    FLock.Enter;
    try
      Result := Succeeded(IWIAItem(Item.InnerInterface).DeleteItem(0));
    finally
      FLock.Leave;
    end;
  end;
end;

procedure TWIADevice.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

procedure TWIADevice.FillItems(ItemKey: string; Items: TList<IPDItem>);
begin
  FillItemsWithCallBack(ItemKey, FillItemsCallBack, Items);
end;

procedure TWIADevice.FillItemsCallBack(ParentKey: string;
  Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
begin
  TList<IPDItem>(Context).AddRange(Packet);
end;

procedure TWIADevice.FillItemsWithCallBack(ItemKey: string;
  CallBack: TFillItemsCallBack; Context: Pointer);
var
  HR: HRESULT;
  pWiaItem: IWiaItem;
  lItemType: Integer;
  pEnumWiaItem: IEnumWiaItem;
  pChildWiaItem: IWiaItem;
  pceltFetched: ULONG;
  Cancel: Boolean;
  ItemList: TList<IPDItem>;
  Item: IPDItem;
  ParentPath: string;
begin
  Cancel := False;

  if (ItemKey = '') and (FRoot <> nil) then
    pWiaItem := FRoot
  else
    pWiaItem := InternalGetItemByKey(ItemKey);

  if ItemKey = '' then
    ParentPath := ''
  else
    ParentPath := PortableItemNameCache.GetPathByKey(FDeviceID, ItemKey);

  HR := S_OK;

  if pWiaItem <> nil then
  begin

    ItemList := TList<IPDItem>.Create;
    try
      //
      // Get the item type for this item.
      //
      FLock.Enter;
      try
        HR := pWiaItem.GetItemType(lItemType);
      finally
        FLock.Leave;
      end;

      if (SUCCEEDED(HR)) then
      begin
        //
        // If it is a folder, or it has attachments, enumerate its children.
        //
        if ((lItemType and WiaItemTypeFolder) > 0) or ((lItemType and WiaItemTypeHasAttachments) > 0) then
        begin
          //
          // Get the child item enumerator for this item.
          //
          FLock.Enter;
          try
            HR := pWiaItem.EnumChildItems(pEnumWiaItem);
          finally
            FLock.Leave;
          end;
          //
          // Loop until you get an error or pEnumWiaItem->Next returns
          // S_FALSE to signal the end of the list.
          //
          while (SUCCEEDED(HR)) do
          begin
            //
            // Get the next child item.
            //
            FLock.Enter;
            try
              HR := pEnumWiaItem.Next(1, pChildWiaItem, pceltFetched);
            finally
              FLock.Leave;
            end;

            if pChildWiaItem = nil then
              Break;
            //
            // pEnumWiaItem->Next will return S_FALSE when the list is
            // exhausted, so check for S_OK before using the returned
            // value.
            //
            if (SUCCEEDED(HR)) then
            begin
              Item := TWIAItem.Create(Self, pChildWiaItem);
              ItemList.Add(Item);
              PortableItemNameCache.AddName(FDeviceID, Item.ItemKey, ItemKey, ParentPath + '\' + Item.Name);
              CallBack(ItemKey, ItemList, Cancel, Context);
              if Cancel then
                Break;
              ItemList.Clear;
            end;
          end;
          //
          // If the result of the enumeration is S_FALSE (which
          // is normal), change it to S_OK.
          //
          if (S_FALSE = hr) then
              HR := S_OK;
          //
          // Release the enumerator.
          //
          //pEnumWiaItem->Release();
          //pEnumWiaItem = NULL;
        end;
      end;
    finally
      F(ItemList);
    end;
  end;
  ErrorCheck(HR);
end;

procedure TWIADevice.FindItemByKeyCallBack(ParentKey: string;
  Packet: TList<IPDItem>; var Cancel: Boolean; Context: Pointer);
var
  Item: IPDItem;
  C: TFindItemContext;
begin
  C := TFindItemContext(Context);
  for Item in Packet do
    if C.ItemKey = Item.ItemKey then
    begin
      Cancel := True;
      C.Item := Item;
      Break;
    end;
end;

function TWIADevice.GetBatteryStatus: Byte;
begin
  Result := FBatteryStatus;
end;

function TWIADevice.GetDeviceID: string;
begin
  Result := FDeviceID;
end;

function TWIADevice.GetDeviceType: TDeviceType;
begin
  Result := FDeviceType;
end;

function TWIADevice.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

function TWIADevice.GetItemByKey(ItemKey: string): IPDItem;
var
  Item: IWiaItem;
begin
  Result := nil;
  Item := InternalGetItemByKey(ItemKey);
  if Item <> nil then
    Result := TWiaItem.Create(Self, Item);
end;

function TWIADevice.GetItemByPath(Path: string): IPDItem;
var
  ItemKey: string;
begin
  ItemKey := PortableItemNameCache.GetKeyByPath(FDeviceID, Path);
  Result := GetItemByKey(ItemKey);
end;

function TWIADevice.GetName: string;
begin
  Result := FDeviceName;
end;

function TWIADevice.InternalGetItemByKey(ItemKey: string): IWiaItem;
var
  Context: TFindItemContext;
begin
  Result := nil;

  if (FRoot <> nil) and (Result = nil) then
  begin
    //always returns root item :(
    //FRoot.FItem.FindItemByName(0, PChar(ItemKey), Result);

    if Result = nil then
    begin
      Context := TFindItemContext.Create;
      try
        Context.ItemKey := ItemKey;
        FillItemsWithCallBack('', FindItemByKeyCallBack, Context);
        if Context.Item <> nil then
          Result := IWiaItem(Context.Item.InnerInterface);
      finally
        F(Context);
      end;
    end;
  end;
end;

{ TWIAItem }

function TWIAItem.Clone: IPDItem;
begin
  Result := nil;
end;

constructor TWIAItem.Create(ADevice: TWIADevice; AItem: IWIAItem);
begin
  FItem := AItem;
  FDevice := ADevice;
  FErrorCode := S_OK;
  FItemType := piFile;
  FItemKey := '';
  FFreeSize := 0;
  FFullSize := 0;
  FItemDate := MinDateTime;
  FDeviceID := ADevice.FDeviceID;
  FDeviceName := ADevice.FDeviceName;
  FVisible := True;
  ReadProps;
end;

procedure TWIAItem.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

function TWIAItem.ExtractPreview(var PreviewImage: TBitmap): Boolean;
var
  HR: HRESULT;
  PropList: IWiaPropertyStorage;
  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
  W, H, ImageWidth, ImageHeight, PreviewWidth, PreviewHeight: Integer;
  BitmapPreview: TBitmap;

  procedure ReadBitmapFromBuffer(Buffer: Pointer; Bitmap: TBitmap; W, H: Integer);
  var
    I, J: Integer;
    P: PARGB;
    PS: PRGB;
    Addr, Line: Integer;
  begin
    Bitmap.PixelFormat := pf24bit;
    Bitmap.SetSize(W, H);

    Line := W * 3;
    for I := 0 to H - 1 do
    begin
      P := Bitmap.ScanLine[H - I - 1];
      for J := 0 to W - 1 do
      begin
        Addr := Integer(Buffer) + I * Line + J * 3;
        PS := PRGB(Addr);
        P[J] := PS^;
      end;
    end;
  end;

begin
  Result := False;

  HR := FItem.QueryInterface(IWIAPropertyStorage, PropList);
  if HR = S_OK then
  begin
    SetLength(PropSpec, 5);
    PropSpec[0].ulKind := PRSPEC_PROPID;
    PropSpec[0].propid := WIA_IPA_PIXELS_PER_LINE;

    PropSpec[1].ulKind := PRSPEC_PROPID;
    PropSpec[1].propid := WIA_IPA_NUMBER_OF_LINES;

    PropSpec[2].ulKind := PRSPEC_PROPID;
    PropSpec[2].propid := WIA_IPC_THUMB_WIDTH;

    PropSpec[3].ulKind := PRSPEC_PROPID;
    PropSpec[3].propid := WIA_IPC_THUMB_HEIGHT;

    PropSpec[4].ulKind := PRSPEC_PROPID;
    PropSpec[4].propid := WIA_IPC_THUMBNAIL;

    SetLength(PropVariant, 5);
    FLock.Enter;
    try
      HR := PropList.ReadMultiple(5, @PropSpec[0], @PropVariant[0]);
    finally
      FLock.Leave;
    end;

    if SUCCEEDED(HR) and (PropVariant[4].cadate.pElems <> nil) then
    begin
      ImageWidth := PropVariant[0].ulVal;
      ImageHeight := PropVariant[1].ulVal;
      PreviewWidth := PropVariant[2].ulVal;
      PreviewHeight := PropVariant[3].ulVal;

      BitmapPreview := TBitmap.Create;
      try
        ReadBitmapFromBuffer(PropVariant[4].cadate.pElems, BitmapPreview, PreviewWidth, PreviewHeight);
        W := ImageWidth;
        H := ImageHeight;
        ProportionalSize(PreviewWidth, PreviewHeight, W, H);
        if ((W <> PreviewWidth) or (H <> PreviewHeight)) and (W > 0) and (H > 0) then
        begin
          PreviewImage.PixelFormat := pf24Bit;
          PreviewImage.SetSize(W, H);
          DrawImageExRect(PreviewImage, BitmapPreview, PreviewWidth div 2 - W div 2, PreviewHeight div 2 - H div 2, W, H, 0, 0);
        end else
          AssignBitmap(PreviewImage, BitmapPreview);
        Result := not PreviewImage.Empty;
      finally
        F(BitmapPreview);
      end;
    end;
  end else
    ErrorCheck(HR);
end;

function TWIAItem.GetDeviceID: string;
begin
  Result := FDeviceID;
end;

function TWIAItem.GetDeviceName: string;
begin
  Result := FDeviceName;
end;

function TWIAItem.GetErrorCode: HRESULT;
begin
  Result := FErrorCode;
end;

function TWIAItem.GetFreeSize: Int64;
begin
  Result := FFreeSize;
end;

function TWIAItem.GetFullSize: Int64;
begin
  Result := FFullSize;
end;

function TWIAItem.GetInnerInterface: IUnknown;
begin
  Result := FItem;
end;

function TWIAItem.GetIsVisible: Boolean;
begin
  Result := FVisible;
end;

function TWIAItem.GetItemDate: TDateTime;
begin
  Result := FItemDate;
end;

function TWIAItem.GetItemKey: string;
begin
  Result := FItemKey;
end;

function TWIAItem.GetItemType: TPortableItemType;
begin
  Result := FItemType;
end;

function TWIAItem.GetName: string;
begin
  Result := FName;
end;

procedure TWIAItem.ReadProps;
var
  HR: HRESULT;
  PropList: IWiaPropertyStorage;
  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
begin
  HR := FItem.QueryInterface(IWIAPropertyStorage, PropList);
  if SUCCEEDED(HR) then
  begin
    Setlength(PropSpec, 6);
    PropSpec[0].ulKind := PRSPEC_PROPID;
    PropSpec[0].propid := WIA_IPA_FULL_ITEM_NAME;

    PropSpec[1].ulKind := PRSPEC_PROPID;
    PropSpec[1].propid := WIA_IPA_ITEM_NAME;

    PropSpec[2].ulKind := PRSPEC_PROPID;
    PropSpec[2].propid := WIA_IPA_FILENAME_EXTENSION;

    PropSpec[3].ulKind := PRSPEC_PROPID;
    PropSpec[3].propid := WIA_IPA_ITEM_FLAGS;

    PropSpec[4].ulKind := PRSPEC_PROPID;
    PropSpec[4].propid := WIA_IPA_ITEM_TIME;

    PropSpec[5].ulKind := PRSPEC_PROPID;
    PropSpec[5].propid := WIA_IPA_ITEM_SIZE;

    Setlength(PropVariant, 6);
    FLock.Enter;
    try
      HR := PropList.ReadMultiple(6, @PropSpec[0], @PropVariant[0]);
    finally
      FLock.Leave;
    end;
    if SUCCEEDED(HR) then
    begin
      FName := PropVariant[1].bstrVal;
      if PropVariant[2].bstrVal <> '' then
        FName := FName + '.' + PropVariant[2].bstrVal;
      FFullSize := PropVariant[5].hVal.QuadPart;
      FItemKey := PropVariant[0].bstrVal;

      if PSystemTime(PropVariant[4].cadate.pElems) <> nil then
        FItemDate := SystemTimeToDateTime(PSystemTime(PropVariant[4].cadate.pElems)^);

      if PropVariant[3].ulVal and ImageItemFlag > 0 then
        FItemType := piImage
      else if PropVariant[3].ulVal and FolderItemFlag > 0 then
        FItemType := piDirectory
      else if PropVariant[3].ulVal and StorageItemFlag > 0 then
        FItemType := piStorage
      else if PropVariant[3].ulVal and VideoItemFlag > 0 then
        FItemType := piVideo;
    end else
      ErrorCheck(HR);

  end else
    ErrorCheck(HR);
end;

function TWIAItem.SaveToStream(S: TStream): Boolean;
begin
  Result := SaveToStreamEx(S, nil);
end;

function TWIAItem.SaveToStreamEx(S: TStream;
  CallBack: TPDProgressCallBack): Boolean;
var
  HR: HRESULT;
  Transfer: IWiaDataTransfer;
  PropList: IWiaPropertyStorage;
  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
  TransferData: WIA_DATA_TRANSFER_INFO;
  WCallBack: IWiaDataCallback;
begin
  Result := False;
  HR := FItem.QueryInterface(IWIAPropertyStorage, PropList);
  if SUCCEEDED(HR) then
  begin

    Setlength(PropSpec, 1);
    PropSpec[0].ulKind := PRSPEC_PROPID;
    PropSpec[0].propid := WIA_IPA_PREFERRED_FORMAT;
    Setlength(PropVariant, 1);

    FLock.Enter;
    try
      HR := PropList.ReadMultiple(1, @PropSpec[0], @PropVariant[0]);
    finally
      FLock.Leave;
    end;
    if SUCCEEDED(HR) then
    begin
      HR := FItem.QueryInterface(IWiaDataTransfer, Transfer);
      if SUCCEEDED(HR) then
      begin
        Setlength(PropSpec, 2);
        PropSpec[0].ulKind := PRSPEC_PROPID;
        PropSpec[0].propid := WIA_IPA_FORMAT;

        PropSpec[1].ulKind := PRSPEC_PROPID;
        PropSpec[1].propid := WIA_IPA_TYMED;

        SetLength(PropVariant, 2);
        PropVariant[0].vt := VT_CLSID;
        PropVariant[0].puuid := PropVariant[0].puuid;

        PropVariant[1].vt := VT_I4;
        PropVariant[1].lVal := TYMED_CALLBACK;

        FLock.Enter;
        try
          HR := PropList.WriteMultiple(2, @PropSpec[0], @PropVariant[0], WIA_IPA_FIRST);
        finally
          FLock.Leave;
        end;
        if SUCCEEDED(HR) then
        begin
          FillChar(TransferData, SizeOf(TransferData), #0);

          TransferData.ulSize        := Sizeof(WIA_DATA_TRANSFER_INFO);
          TransferData.ulBufferSize  := 2 * 1024 * 1024;
          TransferData.bDoubleBuffer := True;

          FLock.Enter;
          try
            WCallBack := TWiaDataCallback.Create(Self, S, CallBack);
            try
              HR := Transfer.idtGetBandedData(@TransferData, WCallBack);
            finally
              WCallBack := nil;
            end;
          finally
            FLock.Leave;
          end;
          ErrorCheck(HR);

          Result := SUCCEEDED(HR);
        end;
      end;
    end;
  end else
    ErrorCheck(HR);
end;

{ TWiaDataCallback }

function TWiaDataCallback.BandedDataCallback(lMessage, lStatus,
  lPercentComplete, lOffset, lLength, lReserved, lResLength: Integer;
  pbBuffer: Pointer): HRESULT;
var
  B: Boolean;
begin
  Result := S_OK;
  B := False;
  case lMessage of
    IT_MSG_DATA:
    begin
      if lStatus = IT_STATUS_TRANSFER_TO_CLIENT then
      begin
        FStream.Write(pbBuffer^, lLength);

        if Assigned(FCallBack) then
        begin
          FCallBack(FItem, FItem.FFullSize, FStream.Size, B);
          if B then
            Result := S_FALSE;
        end;
      end;
    end;
  end;
end;

constructor TWiaDataCallback.Create(Item: TWIAItem; Stream: TStream; CallBack: TPDProgressCallBack);
begin
  inherited Create;
  FItem := Item;
  FStream := Stream;
  FCallBack := CallBack;
end;

{ TWIACallBack }

function TWIAEventCallBack.ImageEventCallback(pEventGUID: PGUID;
  bstrEventDescription, bstrDeviceID, bstrDeviceDescription: PChar;
  dwDeviceType: DWORD; bstrFullItemName: PChar; var pulEventType: PULONG;
  ulReserved: ULONG): HRESULT;
begin
  if pEventGUID^ = WIA_EVENT_DEVICE_DISCONNECTED then
    PortableItemNameCache.ClearDeviceCache(bstrDeviceID);

  Result := S_OK;
end;

initialization
  FLock := TCriticalSection.Create;

finalization
  F(FLock);

end.
