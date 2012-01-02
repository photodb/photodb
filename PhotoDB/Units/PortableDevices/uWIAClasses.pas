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
  uBitmapUtils;

type
  TWIADeviceManager = class;
  TWIADevice = class;

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
    function ExtractPreview(PreviewImage: TBitmap): Boolean;
    function SaveToStream(S: TStream): Boolean;
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
    function Delete(ItemKey: string): Boolean;
    property Manager: TWIADeviceManager read FManager;
  end;

  TWIADeviceManager = class(TInterfacedObject, IPManager)
  private
    FErrorCode: HRESULT;
    FManager: IWiaDevMgr;
    procedure ErrorCheck(Code: HRESULT);
    procedure FillDeviceCallBack(Packet: TList<IPDevice>; var Cancel: Boolean; Context: Pointer);
  public
    constructor Create;
    function GetErrorCode: HRESULT;
    procedure FillDevices(Devices: TList<IPDevice>);
    procedure FillDevicesWithCallBack(CallBack: TFillDevicesCallBack; Context: Pointer);
    function GetDeviceByName(DeviceName: string): IPDevice;
    property Manager: IWiaDevMgr read FManager;
  end;

  TWiaDataCallback = class(TInterfacedObject, IWiaDataCallback)
  private
    FStream: TStream;
  public
    constructor Create(Stream: TStream);
    function BandedDataCallback(lMessage: LongInt;
      lStatus: LongInt;
      lPercentComplete: LongInt;
      lOffset: LongInt;
      lLength: LongInt;
      lReserved: LongInt;
      lResLength: LongInt;
      pbBuffer: Pointer): HRESULT; stdcall;
  end;

implementation

{ TWDManager }

constructor TWIADeviceManager.Create;
begin
  FErrorCode := S_OK;
  FManager := nil;
  ErrorCheck(CoCreateInstance(CLSID_WiaDevMgr, nil, CLSCTX_LOCAL_SERVER, IID_IWiaDevMgr, FManager));
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

  DevList := TList<IPDevice>.Create;
  try
    pWiaEnumDevInfo := nil;
    HR := FManager.EnumDeviceInfo(WIA_DEVINFO_ENUM_LOCAL, pWiaEnumDevInfo);

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

      HR := pWiaEnumDevInfo.Next(1, pWiaPropertyStorage, pceltFetched);
      //
      // pWiaEnumDevInfo->Next will return S_FALSE when the list is
      // exhausted, so check for S_OK before using the returned
      // value.
      //
      if pWiaPropertyStorage = nil then
        Break;

      if SUCCEEDED(HR) and (pWiaPropertyStorage <> nil) then
      begin
        FreeList(DevList, False);
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


function TWIADeviceManager.GetDeviceByName(DeviceName: string): IPDevice;
begin

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
  HR := PropList.ReadMultiple(3, @PropSpec[0], @PropVariant[0]);

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
      HR := Manager.FManager.CreateDevice(bstrDeviceID, FRoot);
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
        HR := PropList.ReadMultiple(1, @PropSpec[0], @PropVariant[0]);
        if SUCCEEDED(HR) then
          FBatteryStatus := PropVariant[0].iVal;

      end;
    end;
  end;
end;

function TWIADevice.Delete(ItemKey: string): Boolean;
begin
  Result := False;
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
begin
  Cancel := False;

  if ItemKey = '' then
    pWiaItem := FRoot
  else
    pWiaItem := InternalGetItemByKey(ItemKey);

  HR := S_OK;

  if pWiaItem <> nil then
  begin

    ItemList := TList<IPDItem>.Create;
    try

      //
      // Get the item type for this item.
      //
      HR := pWiaItem.GetItemType(lItemType);
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
          HR := pWiaItem.EnumChildItems(pEnumWiaItem);
          //
          // Loop until you get an error or pEnumWiaItem->Next returns
          // S_FALSE to signal the end of the list.
          //
          while (SUCCEEDED(HR)) do
          begin
            //
            // Get the next child item.
            //
            HR := pEnumWiaItem.Next(1, pChildWiaItem, pceltFetched);

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
begin
  Result := nil; //InternalGetItemByKey(ItemKey);
end;

function TWIADevice.GetName: string;
begin
  Result := FDeviceName;
end;

function TWIADevice.InternalGetItemByKey(ItemKey: string): IWiaItem;
begin
   Result := nil;
end;

{ TWIAItem }

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
  ReadProps;
end;

procedure TWIAItem.ErrorCheck(Code: HRESULT);
begin
  if Failed(Code) then
    FErrorCode := Code;
end;

function TWIAItem.ExtractPreview(PreviewImage: TBitmap): Boolean;
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
    PropSpec[2].propid := WIA_IPC_THUMB_HEIGHT;

    PropSpec[3].ulKind := PRSPEC_PROPID;
    PropSpec[3].propid := WIA_IPC_THUMB_WIDTH;

    PropSpec[4].ulKind := PRSPEC_PROPID;
    PropSpec[4].propid := WIA_IPC_THUMBNAIL;

    SetLength(PropVariant, 5);
    HR := PropList.ReadMultiple(5, @PropSpec[0], @PropVariant[0]);

    if SUCCEEDED(HR) and (FItemType = piImage) then
    begin
      ImageWidth := PropVariant[3].ulVal;
      ImageHeight := PropVariant[4].ulVal;
      PreviewWidth := PropVariant[6].ulVal;
      PreviewHeight := PropVariant[7].ulVal;

      BitmapPreview := TBitmap.Create;
      try
        ReadBitmapFromBuffer(PropVariant[8].cadate.pElems, BitmapPreview, PreviewWidth, PreviewHeight);
        W := ImageWidth;
        H := ImageHeight;
        ProportionalSize(PreviewWidth, PreviewHeight, W, H);
        if (W <> PreviewWidth) or (H <> PreviewHeight) then
        begin
          PreviewImage.PixelFormat := pf24Bit;
          PreviewImage.SetSize(W, H);
          DrawImageExRect(PreviewImage, BitmapPreview, PreviewWidth div 2 - W div 2, PreviewHeight div 2 - H div 2, W, H, 0, 0);
        end;
        AssignBitmap(PreviewImage, BitmapPreview);
        Result := not PreviewImage.Empty;
      finally
        BitmapPreview.Free;
      end;
    end;
  end else
    ErrorCheck(HR);
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
    Setlength(PropSpec, 5);
    PropSpec[0].ulKind := PRSPEC_PROPID;
    PropSpec[0].propid := WIA_IPA_ITEM_NAME;

    PropSpec[1].ulKind := PRSPEC_PROPID;
    PropSpec[1].propid := WIA_IPA_FILENAME_EXTENSION;

    PropSpec[2].ulKind := PRSPEC_PROPID;
    PropSpec[2].propid := WIA_IPA_ITEM_FLAGS;

    PropSpec[3].ulKind := PRSPEC_PROPID;
    PropSpec[3].propid := WIA_IPA_ITEM_TIME;

    PropSpec[4].ulKind := PRSPEC_PROPID;
    PropSpec[4].propid := WIA_IPA_ITEM_SIZE;

    Setlength(PropVariant, 5);
    HR := PropList.ReadMultiple(5, @PropSpec[0], @PropVariant[0]);
    if SUCCEEDED(HR) then
    begin
      FName := PropVariant[0].bstrVal;
      if PropVariant[1].bstrVal <> '' then
        FName := FName + '.' + PropVariant[1].bstrVal;
      FFullSize := PropVariant[4].hVal.QuadPart;
      FItemKey := FName;

      if PSystemTime(PropVariant[3].cadate.pElems) <> nil then
        FItemDate := SystemTimeToDateTime(PSystemTime(PropVariant[3].cadate.pElems)^);

      if PropVariant[2].ulVal and ImageItemFlag > 0 then
        FItemType := piImage
      else if PropVariant[2].ulVal and FolderItemFlag > 0 then
        FItemType := piDirectory
      else if PropVariant[2].ulVal and StorageItemFlag > 0 then
        FItemType := piStorage
      else if PropVariant[2].ulVal and VideoItemFlag > 0 then
        FItemType := piVideo;
    end else
      ErrorCheck(HR);

  end else
    ErrorCheck(HR);
end;

function TWIAItem.SaveToStream(S: TStream): Boolean;
var
  HR: HRESULT;
  Transfer: IWiaDataTransfer;
  PropList: IWiaPropertyStorage;
  PropSpec: array of TPropSpec;
  PropVariant: array of TPropVariant;
  TransferData: WIA_DATA_TRANSFER_INFO;
  CallBack: TWiaDataCallback;
begin
  Result := False;
  HR := FItem.QueryInterface(IWIAPropertyStorage, PropList);
  if SUCCEEDED(HR) then
  begin

    Setlength(PropSpec, 1);
    PropSpec[0].ulKind := PRSPEC_PROPID;
    PropSpec[0].propid := WIA_IPA_PREFERRED_FORMAT;

    HR := PropList.ReadMultiple(1, @PropSpec[0], @PropVariant[0]);
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

        HR := PropList.WriteMultiple(2, @PropSpec[0], @PropVariant[0], WIA_IPA_FIRST);

        if SUCCEEDED(HR) then
        begin
          FillChar(TransferData, SizeOf(TransferData), #0);

          TransferData.ulSize        := Sizeof(WIA_DATA_TRANSFER_INFO);
          TransferData.ulBufferSize  := 2 * 1024 * 1024;
          TransferData.bDoubleBuffer := True;

          CallBack := TWiaDataCallback.Create(S);
          try
            HR := Transfer.idtGetBandedData(@TransferData, CallBack);
            ErrorCheck(HR);

            Result := SUCCEEDED(HR);
          finally
            F(CallBack)
          end;
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
begin
  case lMessage of
    IT_MSG_DATA:
    begin
      if lStatus = IT_STATUS_TRANSFER_TO_CLIENT then
        FStream.Write(pbBuffer^, lLength);
    end;
  end;
  Result := S_OK;
end;

constructor TWiaDataCallback.Create(Stream: TStream);
begin
  FStream := Stream;
end;

initialization

end.
