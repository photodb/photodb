unit uWIAInterfaces;

interface

uses
  Windows, ActiveX;

const
  UnspecifiedDeviceType = $00000000;
  ScannerDeviceType = $00000001;
  CameraDeviceType = $00000002;
  VideoDeviceType = $00000003;

const
  FreeItemFlag = $00000000;
  ImageItemFlag = $00000001;
  FileItemFlag = $00000002;
  FolderItemFlag = $00000004;
  RootItemFlag = $00000008;
  AnalyzeItemFlag = $00000010;
  AudioItemFlag = $00000020;
  DeviceItemFlag = $00000040;
  DeletedItemFlag = $00000080;
  DisconnectedItemFlag = $00000100;
  HPanoramaItemFlag = $00000200;
  VPanoramaItemFlag = $00000400;
  BurstItemFlag = $00000800;
  StorageItemFlag = $00001000;
  TransferItemFlag = $00002000;
  GeneratedItemFlag = $00004000;
  HasAttachmentsItemFlag = $00008000;
  VideoItemFlag = $00010000;
  RemovedItemFlag = $80000000;

const
  CLSID_WiaDevMgr: TGUID = '{a1f4e726-8cf1-11d1-bf92-0060081ed811}';
  IID_IWiaDevMgr: TGUID  = '{5eb2502a-8cf1-11d1-bf92-0060081ed811}';

  CLSID_WiaDevMgr2: TGUID = '{B6C292BC-7C88-41ee-8B54-8EC92617E599}';
  IID_IWiaDevMgr2: TGUID  = '{79C07CF1-CBDD-41ee-8EC3-F00080CADA7A}';

  WIA_DEVINFO_ENUM_LOCAL = $00000010;

  WIA_EVENT_ITEM_CREATED: TGUID = '{4C8F4EF5-E14F-11D2-B326-00C04F68CE61}';
  WIA_EVENT_ITEM_DELETED: TGUID = '{1D22A559-E14F-11D2-B326-00C04F68CE61}';

  WIA_EVENT_DEVICE_CONNECTED: TGUID = '{A28BBADE-64B6-11D2-A231-00C04FA31809}';
  WIA_EVENT_DEVICE_DISCONNECTED: TGUID = '{143E4E83-6497-11D2-A231-00C04FA31809}';

type
  _WIA_DATA_CALLBACK_HEADER = record
    lSize: LongInt;
    guidFormatID: TGUID;
    lBufferSize: LongInt;
    lPageCount: LongInt;
  end;
  WIA_DATA_CALLBACK_HEADER = _WIA_DATA_CALLBACK_HEADER;
  PWIA_DATA_CALLBACK_HEADER = ^WIA_DATA_CALLBACK_HEADER;

type
  WIA_DEV_CAP  = interface(IUnknown)
(*
typedef struct _WIA_DEV_CAP {
  GUID  guid;
  ULONG ulFlags;
  BSTR  bstrName;
  BSTR  bstrDescription;
  BSTR  bstrIcon;
  BSTR  bstrCommandline;
} WIA_DEV_CAP, *PWIA_DEV_CAP, WIA_EVENT_HANDLER, *PWIA_EVENT_HANDLER;
*)
  end;

  IEnumWIA_DEV_CAPS = interface(IUnknown)
    ['{1FCC4287-ACA6-11D2-A093-00C04F72DC3C}']
    function Next(celt: ULONG; out rgelt: WIA_DEV_CAP; var pceltFetched: ULONG): HRESULT; safecall;
    function Skip(celt: ULONG): HRESULT; safecall;
    function Reset: HRESULT; safecall;
    function Clone(out ppIEnum: IEnumWIA_DEV_CAPS): HRESULT; safecall;
    function GetCount(out pcelt: ULONG): HRESULT; safecall;
  end;

  IWiaItem = interface;

  IWiaPropertyStorage = interface(IUnknown)
    ['{98B5E8A0-29CC-491A-AAC0-E6DB4FDCCEB6}']
    function ReadMultiple(cpspec: ULONG; rgpspec : PPropSpec; rgpropvar: PPropVariant): HResult; stdcall;
    function WriteMultiple(cpspec: ULONG; rgpspec : PPropSpec; rgpropvar: PPropVariant;
      propidNameFirst: TPropID): HResult; stdcall;
    function DeleteMultiple(cpspec: ULONG; rgpspec: PPropSpec): HResult; stdcall;
    function ReadPropertyNames(cpropid: ULONG; rgpropid: PPropID;
      rglpwstrName: PPOleStr): HResult; stdcall;
    function WritePropertyNames(cpropid: ULONG; rgpropid: PPropID;
      rglpwstrName: PPOleStr): HResult; stdcall;
    function DeletePropertyNames(cpropid: ULONG; rgpropid: PPropID): HResult; stdcall;
    function Commit(grfCommitFlags: DWORD): HResult; stdcall;
    function Revert: HResult; stdcall;
    function Enum(out ppenum: IEnumSTATPROPSTG): HResult; stdcall;
    function SetTimes(const pctime, patime, pmtime: TFileTime): HResult; stdcall;
    function SetClass(const clsid: TCLSID): HResult; stdcall;
    function Stat(pstatpsstg: PStatPropSetStg): HResult; stdcall;
    function GetPropertyAttributes(
      cpspec: ULONG;
      rgpspec: {PROPSPEC[]}IUnknown;
      rgflags: {ULONG[]}IUnknown;
      rgpropvar: {PROPVARIANT[]}IUnknown): HRESULT; safecall;
    function GetCount(var pcelt: ULONG): HRESULT; safecall;
    function GetPropertyStream(
      out pCompatibilityID: TGUID;
      out ppIStream: IStream): HRESULT; safecall;
    function SetPropertyStream(
      pCompatibilityID: TGUID;
      pIStream: IStream): HRESULT; safecall;
  end;

  IEnumWiaItem = interface(IUnknown)
    ['{5E8383FC-3391-11D2-9A33-00C04FA36145}']
    function Next(celt: ULONG; out ppIWiaItem: IWiaItem; var pceltFetched: ULONG): HRESULT; safecall;
    function Skip(celt: ULONG): HRESULT; safecall;
    function Reset: HRESULT; safecall;
    function Clone(out ppIEnum: IEnumWiaItem): HRESULT; safecall;
    function GetCount(out pcelt: ULONG): HRESULT; safecall;
  end;

  IWiaItem = interface(IUnknown)
    ['{4DB1AD10-3391-11D2-9A33-00C04FA36145}']
    function GetItemType(var itemType: Integer): HRESULT; safecall;
    function AnalyzeItem(var lTags: Integer): HRESULT; safecall;
    function EnumChildItems(out EnumWiaItem: IEnumWiaItem): HRESULT; safecall;
    function DeleteItem(const lTags: Integer): HRESULT; safecall;
    function CreateChildItem(lFlags: Integer;
      bstrItemName: string;
      bstrFullItemName: string;
      var ppIWiaItem: IWiaItem): HRESULT; safecall;
    function EnumRegisterEventInfo(lFlags: Integer;
      const pEventGUID: TGUID;
      var ppIEnum: IEnumWIA_DEV_CAPS): HRESULT;
    function FindItemByName(lFlags: LONG;
      bstrFullItemName: PChar;
      out ppIWiaItem: IWiaItem): HRESULT; safecall;
    function DeviceDlg(hwndParent: HWND;
      lFlags: Integer;
      lIntent: Integer;
      var plItemCount: Integer;
      var ppIWiaItem: IWiaItem): HRESULT; safecall;
    function DeviceCommand(lFlags: Integer;
      pCmdGUID: TGUID;
      var pIWiaItem: IWiaItem): HRESULT; safecall;
    function GetRootItem(out ppIWiaItem: IWiaItem): HRESULT; safecall;
    function EnumDeviceCapabilities(lFlags: Integer;
      out ppIEnumWIA_DEV_CAPS: IEnumWIA_DEV_CAPS): HRESULT; safecall;
  end;

  IWiaDataCallback = interface(IUnknown)
    ['{A558A866-A5B0-11D2-A08F-00C04F72DC3C}']
    function BandedDataCallback(lMessage: LongInt;
      lStatus: LongInt;
      lPercentComplete: LongInt;
      lOffset: LongInt;
      lLength: LongInt;
      lReserved: LongInt;
      lResLength: LongInt;
      pbBuffer: Pointer): HRESULT; stdcall;
  end;

  _WIA_DATA_TRANSFER_INFO = record
    ulSize: ULONG;
    ulSection: ULONG;
    ulBufferSize: ULONG;
    bDoubleBuffer: BOOL;
    ulReserved1: ULONG;
    ulReserved2: ULONG;
    ulReserved3: ULONG;
  end;
  WIA_DATA_TRANSFER_INFO = _WIA_DATA_TRANSFER_INFO;
  PWIA_DATA_TRANSFER_INFO = ^WIA_DATA_TRANSFER_INFO;

  _WIA_FORMAT_INFO = record
    guidFormatID: TGUID;
    lTymed: Integer;
  end;
  WIA_FORMAT_INFO = _WIA_FORMAT_INFO;
  PWIA_FORMAT_INFO = ^WIA_FORMAT_INFO;

  PWIA_EXTENDED_TRANSFER_INFO = Pointer; //TODO: implement
  IEnumWIA_FORMAT_INFO = interface(IUnknown)
    //TODO: implement
  end;

  IWiaDataTransfer = interface(IUnknown)
    ['{A6CEF998-A5B0-11D2-A08F-00C04F72DC3C}']
      function idtGetData(pMedium: PSTGMEDIUM; pIWiaDataCallback: IWiaDataCallback): HRESULT; safecall;
      function idtGetBandedData(pWiaDataTransInfo: PWIA_DATA_TRANSFER_INFO; pIWiaDataCallback: IWiaDataCallback): HRESULT; safecall;
      function idtQueryGetData(pfe: WIA_FORMAT_INFO): HRESULT; safecall;
      function idtEnumWIA_FORMAT_INFO(ppEnum: IEnumWIA_FORMAT_INFO): HRESULT; safecall;
      function idtGetExtendedTransferInfo(pExtendedTransferInfo: PWIA_EXTENDED_TRANSFER_INFO): HRESULT; safecall;
  end;

  IEnumWIA_DEV_INFO = interface(IUnknown)
    ['{5E38B83C-8CF1-11D1-BF92-0060081ED811}']
    function Next(celt: ULONG; out rgelt: IWiaPropertyStorage; pceltFetched: PULONG): HRESULT; stdcall;
    function Skip(celt: ULONG): HRESULT; stdcall;
    function Reset: HRESULT; stdcall;
    function Clone(out ppIEnum: IEnumWIA_DEV_INFO): HRESULT; stdcall;
    function GetCount(out pcelt: ULONG): HRESULT; stdcall;
  end;

  IWiaEventCallback = interface(IUnknown)
    ['{AE6287B0-0084-11D2-973B-00A0C9068F2E}']
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

  IWiaDevMgr = interface(IUnknown)
    ['{5EB2502A-8CF1-11D1-BF92-0060081ED811}']
      function EnumDeviceInfo(lFlag: Integer; out ppIEnum: IEnumWIA_DEV_INFO): HRESULT; safecall;
      function CreateDevice(bstrDeviceID: PChar; out ppWiaItemRoot: IWiaItem): HRESULT; safecall;
      function SelectDeviceDlg(hwndParent: HWND; lDeviceType: Integer; lFlags: Integer;
        var pbstrDeviceID: string; ppItemRoot: IWiaItem): HRESULT; safecall;
      function SelectDeviceDlgID(hwndParent: HWND;
        lDeviceType: Integer;
        lFlags: Integer;
        out pbstrDeviceID: string): HRESULT; safecall;
      function GetImageDlg(hwndParent: HWND;
        lDeviceType: Integer;
        lFlags: Integer;
        lIntent: Integer;
        pItemRoot: IWiaItem;
        bstrFilename: string;
        var pguidFormat: TGUID): HRESULT; safecall;
      function RegisterEventCallbackProgram(lFlags: Integer;
        bstrDeviceID: string;
        pEventGUID: TGUID;
        bstrCommandline: string;
        bstrName: string;
        bstrDescription: string;
        bstrIcon: string): HRESULT; safecall;
      function RegisterEventCallbackInterface(lFlags: Integer;
        bstrDeviceID: PChar;
        pEventGUID: PGUID;
        pIWiaEventCallback: IWiaEventCallback;
        out pEventObject: IUnknown): HRESULT; safecall;
      function RegisterEventCallbackCLSID(lFlags: Integer;
        bstrDeviceID: string;
        pEventGUID: TGUID;
        pClsID: TGUID;
        bstrName: string;
        bstrDescription: string;
        bstrIcon: string): HRESULT; safecall;
      function AddDeviceDlg(hwndParent: HWND; lFlags: Integer): HRESULT; safecall;
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///  WIA 2 Interfaces
  //////////////////////////////////////////////////////////////////////////////

type
  IWiaItem2 = interface;

  IWiaPreview = interface(IUnknown)
   ['{95C2B4FD-33F2-4D86-AD40-9431F0DF08F7}']
  end;

  IEnumWiaItem2 = interface(IUnknown)
    ['{59970AF4-CD0D-44D9-AB24-52295630E582}']
    function Next(celt: ULONG; out ppIWiaItem: IWiaItem2; var pceltFetched: ULONG): HRESULT; safecall;
    function Skip(celt: ULONG): HRESULT; safecall;
    function Reset: HRESULT; safecall;
    function Clone(out ppIEnum: IEnumWiaItem2): HRESULT; safecall;
    function GetCount(out pcelt: ULONG): HRESULT; safecall;
  end;

  IWiaItem2 = interface(IUnknown)
    ['{6CBA0075-1287-407D-9B77-CF0E030435CC}']
    function CreateChildItem(lFlags: Integer;
      lCreationFlags: Integer;
      bstrItemName: string;
      var ppIWiaItem2: IWiaItem2): HRESULT; safecall;
    function DeleteItem(const lTags: Integer): HRESULT; safecall;
    function EnumChildItems(pCategoryGUID: PGUID;
      out EnumWiaItem2: IEnumWiaItem2): HRESULT; safecall;
    function FindItemByName(lFlags: Integer;
      bstrFullItemName: string;
      var ppIWiaItem2: IWiaItem2): HRESULT; safecall;
    function GetItemCategory(out pItemCategoryGUID: TGUID): HRESULT; safecall;
    function GetItemType(out pItemType: Integer): HRESULT; safecall;
    function DeviceDlg(lFlags: Integer;
      hwndParent: HWND;
      bstrFolderName: string;
      bstrFilename: string;
      plNumFiles: Integer;
      ppbstrFilePaths: string;
      var ppIWiaItem2: IWiaItem2): HRESULT; safecall;
    function DeviceCommand(lFlags: Integer;
      pCmdGUID: TGUID;
      var pIWiaItem2: IWiaItem2): HRESULT; safecall;
    function EnumDeviceCapabilities(lFlags: Integer;
      out ppIEnumWIA_DEV_CAPS: IEnumWIA_DEV_CAPS): HRESULT; safecall;
    function CheckExtension(lFlags: Integer;
      bstrName: string;
      riidExtensionInterface: {REFIID}Pointer;
      out pbExtensionExists: BOOL): HRESULT; safecall;
    function GetExtension(lFlags: Integer;
      bstrName: string;
      riidExtensionInterface: {REFIID}Pointer;
      out ppOut): HRESULT; safecall;
    function GetParentItem(out ppIWiaItem2: IWiaItem2): HRESULT; safecall;
    function GetRootItem(out ppIWiaItem: IWiaItem): HRESULT; safecall;
    function GetPreviewComponent(lFlags: Integer;
      ppWiaPreview: IWiaPreview): HRESULT; safecall;
    function EnumRegisterEventInfo(lFlags: Integer;
      const pEventGUID: TGUID;
      out ppIEnum: IEnumWIA_DEV_CAPS): HRESULT;
    function Diagnostic(ulSize: ULONG; pBuffer: PByte): HRESULT; safecall;
  end;

  IWiaTransferCallback = interface(IUnknown)
    ['{27D4EAAF-28A6-4CA5-9AAB-E678168B9527}']
  end;

  IWiaTransfer = interface(IUnknown)
    ['{C39D6942-2F4E-4D04-92FE-4EF4D3A1DE5A}']
  end;

  IWiaDevMgr2 = interface(IUnknown)
    ['{79C07CF1-CBDD-41EE-8EC3-F00080CADA7A}']
      function EnumDeviceInfo(lFlag: Integer; out ppIEnum: IEnumWIA_DEV_INFO): HRESULT; safecall;
      function CreateDevice(lFlags: Integer; bstrDeviceID: PChar; out ppWiaItem2Root: IWiaItem2): HRESULT; safecall;
      function SelectDeviceDlg(hwndParent: HWND; lDeviceType: Integer; lFlags: Integer;
        var pbstrDeviceID: PChar; out ppItemRoot: IWiaItem2): HRESULT; safecall;
      function SelectDeviceDlgID(hwndParent: HWND;
        lDeviceType: Integer;
        lFlags: Integer;
        out pbstrDeviceID: string): HRESULT; safecall;
      function RegisterEventCallbackInterface(lFlags: Integer;
        bstrDeviceID: string;
        pEventGUID: TGUID;
        pIWiaEventCallback: IWiaEventCallback;
        out pEventObject: IUnknown): HRESULT; safecall;
      function RegisterEventCallbackProgram(lFlags: Integer;
        bstrDeviceID: string;
        pEventGUID: TGUID;
        bstrCommandline: string;
        bstrName: string;
        bstrDescription: string;
        bstrIcon: string): HRESULT; safecall;
      function RegisterEventCallbackCLSID(lFlags: Integer;
        bstrDeviceID: string;
        pEventGUID: TGUID;
        pClsID: TGUID;
        bstrName: string;
        bstrDescription: string;
        bstrIcon: string): HRESULT; safecall;
      function GetImageDlg(lFlags: Integer;
        bstrDeviceID: string;
        hwndParent: HWND;
        lDeviceType: Integer;
        bstrFolderName: string;
        bstrFilename: string;
        plNumFiles: Integer;
        pItemRoot: IWiaItem;
        ppbstrFilePaths: string;
        var ppItem: IWiaItem2): HRESULT; safecall;
  end;

const WIA_PROP_READ           = $01;
const WIA_PROP_WRITE         = $02;
const WIA_PROP_RW             = (WIA_PROP_READ or WIA_PROP_WRITE);
const WIA_PROP_SYNC_REQUIRED = $04;

const WIA_PROP_NONE          = $08;
const WIA_PROP_RANGE         = $10;
const WIA_PROP_LIST          = $20;
const WIA_PROP_FLAG          = $40;

const WIA_PROP_CACHEABLE     = $10000;

//
// Item access flags
//

const WIA_ITEM_CAN_BE_DELETED = $80;
const WIA_ITEM_READ           = WIA_PROP_READ;
const WIA_ITEM_WRITE          = WIA_PROP_WRITE;
const WIA_ITEM_RD             = (WIA_ITEM_READ or WIA_ITEM_CAN_BE_DELETED);
const WIA_ITEM_RWD            = (WIA_ITEM_READ or WIA_ITEM_WRITE or WIA_ITEM_CAN_BE_DELETED);

//
// Device information properties
//

const WIA_RESERVED_FOR_SMALL_NEW_PROPS       = 256;
const WIA_RESERVED_FOR_NEW_PROPS             = 1024;
const WIA_RESERVED_FOR_ALL_MS_PROPS          = (1024*32);

const WIA_DIP_FIRST                          = 2;
const WIA_DIP_DEV_ID                         = 2;
const WIA_DIP_VEND_DESC                      = 3;
const WIA_DIP_DEV_DESC                       = 4;
const WIA_DIP_DEV_TYPE                       = 5;
const WIA_DIP_PORT_NAME                      = 6;
const WIA_DIP_DEV_NAME                       = 7;
const WIA_DIP_SERVER_NAME                    = 8;
const WIA_DIP_REMOTE_DEV_ID                  = 9;
const WIA_DIP_UI_CLSID                       = 10;
const WIA_DIP_HW_CONFIG                      = 11;
const WIA_DIP_BAUDRATE                       = 12;
const WIA_DIP_STI_GEN_CAPABILITIES           = 13;
const WIA_DIP_WIA_VERSION                    = 14;
const WIA_DIP_DRIVER_VERSION                 = 15;
const WIA_DIP_LAST                           = 15;

const WIA_NUM_DIP         = 1 + WIA_DIP_LAST - WIA_DIP_FIRST;

const WIA_DIP_DEV_ID_STR                     = 'Unique Device ID';
const WIA_DIP_VEND_DESC_STR                  = 'Manufacturer';
const WIA_DIP_DEV_DESC_STR                   = 'Description';
const WIA_DIP_DEV_TYPE_STR                   = 'Type';
const WIA_DIP_PORT_NAME_STR                  = 'Port';
const WIA_DIP_DEV_NAME_STR                   = 'Name';
const WIA_DIP_SERVER_NAME_STR                = 'Server';
const WIA_DIP_REMOTE_DEV_ID_STR              = 'Remote Device ID';
const WIA_DIP_UI_CLSID_STR                   = 'UI Class ID';
const WIA_DIP_HW_CONFIG_STR                  = 'Hardware Configuration';
const WIA_DIP_BAUDRATE_STR                   = 'BaudRate';
const WIA_DIP_STI_GEN_CAPABILITIES_STR       = 'STI Generic Capabilities';
const WIA_DIP_WIA_VERSION_STR                = 'WIA Version';
const WIA_DIP_DRIVER_VERSION_STR             = 'Driver Version';

//
// Common device properties
//

const WIA_DPA_FIRST                          = WIA_DIP_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_DPA_FIRMWARE_VERSION               = WIA_DPA_FIRST + 0;
const WIA_DPA_CONNECT_STATUS                 = WIA_DPA_FIRST + 1;
const WIA_DPA_DEVICE_TIME                    = WIA_DPA_FIRST + 2;
const WIA_DPA_LAST                          =  WIA_DPA_FIRST + 3;

const WIA_DPA_FIRMWARE_VERSION_STR           = 'Firmware Version';
const WIA_DPA_CONNECT_STATUS_STR             = 'Connect Status';
const WIA_DPA_DEVICE_TIME_STR                = 'Device Time';

const WIA_NUM_DPA = (1 + WIA_DPA_LAST - WIA_DPA_FIRST);

//
// Camera device properties
//

const WIA_DPC_FIRST                          = WIA_DPA_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_DPC_PICTURES_TAKEN                 = WIA_DPC_FIRST + 0;
const WIA_DPC_PICTURES_REMAINING             = WIA_DPC_FIRST + 1;
const WIA_DPC_EXPOSURE_MODE                  = WIA_DPC_FIRST + 2;
const WIA_DPC_EXPOSURE_COMP                  = WIA_DPC_FIRST + 3;
const WIA_DPC_EXPOSURE_TIME                  = WIA_DPC_FIRST + 4;
const WIA_DPC_FNUMBER                        = WIA_DPC_FIRST + 5;
const WIA_DPC_FLASH_MODE                     = WIA_DPC_FIRST + 6;
const WIA_DPC_FOCUS_MODE                     = WIA_DPC_FIRST + 7;
const WIA_DPC_FOCUS_MANUAL_DIST              = WIA_DPC_FIRST + 8;
const WIA_DPC_ZOOM_POSITION                  = WIA_DPC_FIRST + 9;
const WIA_DPC_PAN_POSITION                   = WIA_DPC_FIRST + 10;
const WIA_DPC_TILT_POSITION                  = WIA_DPC_FIRST + 11;
const WIA_DPC_TIMER_MODE                     = WIA_DPC_FIRST + 12;
const WIA_DPC_TIMER_VALUE                    = WIA_DPC_FIRST + 13;
const WIA_DPC_POWER_MODE                     = WIA_DPC_FIRST + 14;
const WIA_DPC_BATTERY_STATUS                 = WIA_DPC_FIRST + 15;
const WIA_DPC_THUMB_WIDTH                    = WIA_DPC_FIRST + 16;
const WIA_DPC_THUMB_HEIGHT                   = WIA_DPC_FIRST + 17;
const WIA_DPC_PICT_WIDTH                     = WIA_DPC_FIRST + 18;
const WIA_DPC_PICT_HEIGHT                    = WIA_DPC_FIRST + 19;
const WIA_DPC_DIMENSION                      = WIA_DPC_FIRST + 20;
const WIA_DPC_COMPRESSION_SETTING            = WIA_DPC_FIRST + 21;
const WIA_DPC_FOCUS_METERING                 = WIA_DPC_FIRST + 22;
const WIA_DPC_TIMELAPSE_INTERVAL             = WIA_DPC_FIRST + 23;
const WIA_DPC_TIMELAPSE_NUMBER               = WIA_DPC_FIRST + 24;
const WIA_DPC_BURST_INTERVAL                 = WIA_DPC_FIRST + 25;
const WIA_DPC_BURST_NUMBER                   = WIA_DPC_FIRST + 26;
const WIA_DPC_EFFECT_MODE                    = WIA_DPC_FIRST + 27;
const WIA_DPC_DIGITAL_ZOOM                   = WIA_DPC_FIRST + 28;
const WIA_DPC_SHARPNESS                      = WIA_DPC_FIRST + 29;
const WIA_DPC_CONTRAST                       = WIA_DPC_FIRST + 30;
const WIA_DPC_CAPTURE_MODE                   = WIA_DPC_FIRST + 31;
const WIA_DPC_CAPTURE_DELAY                  = WIA_DPC_FIRST + 32;
const WIA_DPC_EXPOSURE_INDEX                 = WIA_DPC_FIRST + 33;
const WIA_DPC_EXPOSURE_METERING_MODE         = WIA_DPC_FIRST + 34;
const WIA_DPC_FOCUS_METERING_MODE            = WIA_DPC_FIRST + 35;
const WIA_DPC_FOCUS_DISTANCE                 = WIA_DPC_FIRST + 36;
const WIA_DPC_FOCAL_LENGTH                   = WIA_DPC_FIRST + 37;
const WIA_DPC_RGB_GAIN                       = WIA_DPC_FIRST + 38;
const WIA_DPC_WHITE_BALANCE                  = WIA_DPC_FIRST + 39;
const WIA_DPC_UPLOAD_URL                     = WIA_DPC_FIRST + 40;
const WIA_DPC_ARTIST                         = WIA_DPC_FIRST + 41;
const WIA_DPC_COPYRIGHT_INFO                 = WIA_DPC_FIRST + 42;
const WIA_DPC_LAST                           = WIA_DPC_FIRST + 42;

const WIA_DPC_PICTURES_TAKEN_STR             = 'Pictures Taken';
const WIA_DPC_PICTURES_REMAINING_STR         = 'Pictures Remaining';
const WIA_DPC_EXPOSURE_MODE_STR              = 'Exposure Mode';
const WIA_DPC_EXPOSURE_COMP_STR              = 'Exposure Compensation';
const WIA_DPC_EXPOSURE_TIME_STR              = 'Exposure Time';
const WIA_DPC_FNUMBER_STR                    = 'F Number';
const WIA_DPC_FLASH_MODE_STR                 = 'Flash Mode';
const WIA_DPC_FOCUS_MODE_STR                 = 'Focus Mode';
const WIA_DPC_FOCUS_MANUAL_DIST_STR          = 'Focus Manual Dist';
const WIA_DPC_ZOOM_POSITION_STR              = 'Zoom Position';
const WIA_DPC_PAN_POSITION_STR               = 'Pan Position';
const WIA_DPC_TILT_POSITION_STR              = 'Tilt Position';
const WIA_DPC_TIMER_MODE_STR                 = 'Timer Mode';
const WIA_DPC_TIMER_VALUE_STR                = 'Timer Value';
const WIA_DPC_POWER_MODE_STR                 = 'Power Mode';
const WIA_DPC_BATTERY_STATUS_STR             = 'Battery Status';
const WIA_DPC_THUMB_WIDTH_STR                = 'Thumbnail Width';
const WIA_DPC_THUMB_HEIGHT_STR               = 'Thumbnail Height';
const WIA_DPC_PICT_WIDTH_STR                 = 'Picture Width';
const WIA_DPC_PICT_HEIGHT_STR                = 'Picture Height';
const WIA_DPC_DIMENSION_STR                  = 'Dimension';
const WIA_DPC_COMPRESSION_SETTING_STR        = 'Compression Setting';
const WIA_DPC_FOCUS_METERING_MODE_STR        = 'Focus Metering Mode';
const WIA_DPC_TIMELAPSE_INTERVAL_STR         = 'Timelapse Interval';
const WIA_DPC_TIMELAPSE_NUMBER_STR           = 'Timelapse Number';
const WIA_DPC_BURST_INTERVAL_STR             = 'Burst Interval';
const WIA_DPC_BURST_NUMBER_STR               = 'Burst Number';
const WIA_DPC_EFFECT_MODE_STR                = 'Effect Mode';
const WIA_DPC_DIGITAL_ZOOM_STR               = 'Digital Zoom';
const WIA_DPC_SHARPNESS_STR                  = 'Sharpness';
const WIA_DPC_CONTRAST_STR                   = 'Contrast';
const WIA_DPC_CAPTURE_MODE_STR               = 'Capture Mode';
const WIA_DPC_CAPTURE_DELAY_STR              = 'Capture Delay';
const WIA_DPC_EXPOSURE_INDEX_STR             = 'Exposure Index';
const WIA_DPC_EXPOSURE_METERING_MODE_STR     = 'Exposure Metering Mode';
const WIA_DPC_FOCUS_DISTANCE_STR             = 'Focus Distance';
const WIA_DPC_FOCAL_LENGTH_STR               = 'Focus Length';
const WIA_DPC_RGB_GAIN_STR                   = 'RGB Gain';
const WIA_DPC_WHITE_BALANCE_STR              = 'White Balance';
const WIA_DPC_UPLOAD_URL_STR                 = 'Upload URL';
const WIA_DPC_ARTIST_STR                     = 'Artist';
const WIA_DPC_COPYRIGHT_INFO_STR             = 'Copyright Info';

const WIA_NUM_DPC = (1 + WIA_DPC_LAST - WIA_DPC_FIRST);

//
// Scanner device properties
//

const WIA_DPS_FIRST                                = WIA_DPC_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_DPS_HORIZONTAL_BED_SIZE                  = WIA_DPS_FIRST + 0;
const WIA_DPS_VERTICAL_BED_SIZE                    = WIA_DPS_FIRST + 1;
const WIA_DPS_HORIZONTAL_SHEET_FEED_SIZE           = WIA_DPS_FIRST + 2;
const WIA_DPS_VERTICAL_SHEET_FEED_SIZE             = WIA_DPS_FIRST + 3;
const WIA_DPS_SHEET_FEEDER_REGISTRATION            = WIA_DPS_FIRST + 4;
const WIA_DPS_HORIZONTAL_BED_REGISTRATION          = WIA_DPS_FIRST + 5;
const WIA_DPS_VERTICAL_BED_REGISTRATION            = WIA_DPS_FIRST + 6;
const WIA_DPS_PLATEN_COLOR                         = WIA_DPS_FIRST + 7;
const WIA_DPS_PAD_COLOR                            = WIA_DPS_FIRST + 8;
const WIA_DPS_FILTER_SELECT                        = WIA_DPS_FIRST + 9;
const WIA_DPS_DITHER_SELECT                        = WIA_DPS_FIRST + 10;
const WIA_DPS_DITHER_PATTERN_DATA                  = WIA_DPS_FIRST + 11;
const WIA_DPS_DOCUMENT_HANDLING_CAPABILITIES       = WIA_DPS_FIRST + 12;
const WIA_DPS_DOCUMENT_HANDLING_STATUS             = WIA_DPS_FIRST + 13;
const WIA_DPS_DOCUMENT_HANDLING_SELECT             = WIA_DPS_FIRST + 14;
const WIA_DPS_DOCUMENT_HANDLING_CAPACITY           = WIA_DPS_FIRST + 15;
const WIA_DPS_OPTICAL_XRES                         = WIA_DPS_FIRST + 16;
const WIA_DPS_OPTICAL_YRES                         = WIA_DPS_FIRST + 17;
const WIA_DPS_ENDORSER_CHARACTERS                  = WIA_DPS_FIRST + 18;
const WIA_DPS_ENDORSER_STRING                      = WIA_DPS_FIRST + 19;
const WIA_DPS_SCAN_AHEAD_PAGES                     = WIA_DPS_FIRST + 20;
const WIA_DPS_MAX_SCAN_TIME                        = WIA_DPS_FIRST + 21;
const WIA_DPS_PAGES                                = WIA_DPS_FIRST + 22;
const WIA_DPS_PAGE_SIZE                            = WIA_DPS_FIRST + 23;
const WIA_DPS_PAGE_WIDTH                           = WIA_DPS_FIRST + 24;
const WIA_DPS_PAGE_HEIGHT                          = WIA_DPS_FIRST + 25;
const WIA_DPS_PREVIEW                              = WIA_DPS_FIRST + 26;
const WIA_DPS_TRANSPARENCY                         = WIA_DPS_FIRST + 27;
const WIA_DPS_TRANSPARENCY_SELECT                  = WIA_DPS_FIRST + 28;
const WIA_DPS_SHOW_PREVIEW_CONTROL                 = WIA_DPS_FIRST + 29;
const WIA_DPS_MIN_HORIZONTAL_SHEET_FEED_SIZE       = WIA_DPS_FIRST + 30;
const WIA_DPS_MIN_VERTICAL_SHEET_FEED_SIZE         = WIA_DPS_FIRST + 31;
const WIA_DPS_LAST                                 = WIA_DPS_FIRST + 31;

const WIA_DPS_HORIZONTAL_BED_SIZE_STR               = 'Horizontal Bed Size';
const WIA_DPS_VERTICAL_BED_SIZE_STR                 = 'Vertical Bed Size';
const WIA_DPS_HORIZONTAL_SHEET_FEED_SIZE_STR        = 'Horizontal Sheet Feed Size';
const WIA_DPS_VERTICAL_SHEET_FEED_SIZE_STR          = 'Vertical Sheet Feed Size';
const WIA_DPS_SHEET_FEEDER_REGISTRATION_STR         = 'Sheet Feeder Registration';
const WIA_DPS_HORIZONTAL_BED_REGISTRATION_STR       = 'Horizontal Bed Registration';
const WIA_DPS_VERTICAL_BED_REGISTRATION_STR         = 'Vertical Bed Registration';
const WIA_DPS_PLATEN_COLOR_STR                      = 'Platen Color';
const WIA_DPS_PAD_COLOR_STR                         = 'Pad Color';
const WIA_DPS_FILTER_SELECT_STR                     = 'Filter Select';
const WIA_DPS_DITHER_SELECT_STR                     = 'Dither Select';
const WIA_DPS_DITHER_PATTERN_DATA_STR               = 'Dither Pattern Data';
const WIA_DPS_DOCUMENT_HANDLING_CAPABILITIES_STR    = 'Document Handling Capabilities';
const WIA_DPS_DOCUMENT_HANDLING_STATUS_STR          = 'Document Handling Status';
const WIA_DPS_DOCUMENT_HANDLING_SELECT_STR          = 'Document Handling Select';
const WIA_DPS_DOCUMENT_HANDLING_CAPACITY_STR        = 'Document Handling Capacity';
const WIA_DPS_OPTICAL_XRES_STR                      = 'Horizontal Optical Resolution';
const WIA_DPS_OPTICAL_YRES_STR                      = 'Vertical Optical Resolution';
const WIA_DPS_ENDORSER_CHARACTERS_STR               = 'Endorser Characters';
const WIA_DPS_ENDORSER_STRING_STR                   = 'Endorser String';
const WIA_DPS_SCAN_AHEAD_PAGES_STR                  = 'Scan Ahead Pages';
const WIA_DPS_MAX_SCAN_TIME_STR                     = 'Max Scan Time';
const WIA_DPS_PAGES_STR                             = 'Pages';
const WIA_DPS_PAGE_SIZE_STR                         = 'Page Size';
const WIA_DPS_PAGE_WIDTH_STR                        = 'Page Width';
const WIA_DPS_PAGE_HEIGHT_STR                       = 'Page Height';
const WIA_DPS_PREVIEW_STR                           = 'Preview';
const WIA_DPS_TRANSPARENCY_STR                      = 'Transparency Adapter';
const WIA_DPS_TRANSPARENCY_SELECT_STR               = 'Transparency Adapter Select';
const WIA_DPS_SHOW_PREVIEW_CONTROL_STR              = 'Show preview control';
const WIA_DPS_MIN_HORIZONTAL_SHEET_FEED_SIZE_STR    = 'Minimum Horizontal Sheet Feed Size';
const WIA_DPS_MIN_VERTICAL_SHEET_FEED_SIZE_STR      = 'Minimum Vertical Sheet Feed Size';

const WIA_NUM_DPS = (1 + WIA_DPS_LAST - WIA_DPS_FIRST);

//
// File System Properties
//
const WIA_DPF_FIRST                          = WIA_DPS_FIRST + WIA_RESERVED_FOR_SMALL_NEW_PROPS;
const WIA_DPF_MOUNT_POINT                    = WIA_DPF_FIRST + 0;
const WIA_DPF_LAST                           = WIA_DPF_FIRST + 0;

const WIA_DPF_MOUNT_POINT_STR                = 'Directory mount point';

const WIA_NUM_DPF = (1 + WIA_DPF_LAST - WIA_DPF_FIRST);

//
// Video Camera properties.
//
//
const WIA_DPV_FIRST                          = WIA_DPF_FIRST + WIA_RESERVED_FOR_SMALL_NEW_PROPS;
const WIA_DPV_LAST_PICTURE_TAKEN             = WIA_DPV_FIRST + 0;
const WIA_DPV_IMAGES_DIRECTORY               = WIA_DPV_FIRST + 1;
const WIA_DPV_DSHOW_DEVICE_PATH              = WIA_DPV_FIRST + 2;
const WIA_DPV_LAST                           = WIA_DPV_FIRST + 2;

const WIA_DPV_LAST_PICTURE_TAKEN_STR         = 'Last Picture Taken';
const WIA_DPV_IMAGES_DIRECTORY_STR           = 'Images Directory';
const WIA_DPV_DSHOW_DEVICE_PATH_STR          = 'Directshow Device Path';

const WIA_NUM_DPV = (1 + WIA_DPV_LAST - WIA_DPV_FIRST);

//
// Common item properties
//

const WIA_IPA_FIRST                          = WIA_DPS_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_IPA_ITEM_NAME                      = WIA_IPA_FIRST + 0;
const WIA_IPA_FULL_ITEM_NAME                 = WIA_IPA_FIRST + 1;
const WIA_IPA_ITEM_TIME                      = WIA_IPA_FIRST + 2;
const WIA_IPA_ITEM_FLAGS                     = WIA_IPA_FIRST + 3;
const WIA_IPA_ACCESS_RIGHTS                  = WIA_IPA_FIRST + 4;
const WIA_IPA_DATATYPE                       = WIA_IPA_FIRST + 5;
const WIA_IPA_DEPTH                          = WIA_IPA_FIRST + 6;
const WIA_IPA_PREFERRED_FORMAT               = WIA_IPA_FIRST + 7;
const WIA_IPA_FORMAT                         = WIA_IPA_FIRST + 8;
const WIA_IPA_COMPRESSION                    = WIA_IPA_FIRST + 9;
const WIA_IPA_TYMED                          = WIA_IPA_FIRST + 10;
const WIA_IPA_CHANNELS_PER_PIXEL             = WIA_IPA_FIRST + 11;
const WIA_IPA_BITS_PER_CHANNEL               = WIA_IPA_FIRST + 12;
const WIA_IPA_PLANAR                         = WIA_IPA_FIRST + 13;
const WIA_IPA_PIXELS_PER_LINE                = WIA_IPA_FIRST + 14;
const WIA_IPA_BYTES_PER_LINE                 = WIA_IPA_FIRST + 15;
const WIA_IPA_NUMBER_OF_LINES                = WIA_IPA_FIRST + 16;
const WIA_IPA_GAMMA_CURVES                   = WIA_IPA_FIRST + 17;
const WIA_IPA_ITEM_SIZE                      = WIA_IPA_FIRST + 18;
const WIA_IPA_COLOR_PROFILE                  = WIA_IPA_FIRST + 19;
const WIA_IPA_MIN_BUFFER_SIZE                = WIA_IPA_FIRST + 20;
// Note:  BUFFER_SIZE and MIN_BUFFER_SIZE have the same propids
const WIA_IPA_BUFFER_SIZE                    = WIA_IPA_FIRST + 20;
const WIA_IPA_REGION_TYPE                    = WIA_IPA_FIRST + 21;
const WIA_IPA_ICM_PROFILE_NAME               = WIA_IPA_FIRST + 22;
const WIA_IPA_APP_COLOR_MAPPING              = WIA_IPA_FIRST + 23;
const WIA_IPA_PROP_STREAM_COMPAT_ID          = WIA_IPA_FIRST + 24;
const WIA_IPA_FILENAME_EXTENSION             = WIA_IPA_FIRST + 25;
const WIA_IPA_SUPPRESS_PROPERTY_PAGE         = WIA_IPA_FIRST + 26;
const WIA_IPA_LAST                           = WIA_IPA_FIRST + 26;

const WIA_IPA_ITEM_NAME_STR                 = 'Item Name';
const WIA_IPA_FULL_ITEM_NAME_STR            = 'Full Item Name';
const WIA_IPA_ITEM_TIME_STR                 = 'Item Time Stamp';
const WIA_IPA_ITEM_FLAGS_STR                = 'Item Flags';
const WIA_IPA_ACCESS_RIGHTS_STR             = 'Access Rights';
const WIA_IPA_DATATYPE_STR                  = 'Data Type';
const WIA_IPA_DEPTH_STR                     = 'Bits Per Pixel';
const WIA_IPA_PREFERRED_FORMAT_STR          = 'Preferred Format';
const WIA_IPA_FORMAT_STR                    = 'Format';
const WIA_IPA_COMPRESSION_STR               = 'Compression';
const WIA_IPA_TYMED_STR                     = 'Media Type';
const WIA_IPA_CHANNELS_PER_PIXEL_STR        = 'Channels Per Pixel';
const WIA_IPA_BITS_PER_CHANNEL_STR          = 'Bits Per Channel';
const WIA_IPA_PLANAR_STR                    = 'Planar';
const WIA_IPA_PIXELS_PER_LINE_STR           = 'Pixels Per Line';
const WIA_IPA_BYTES_PER_LINE_STR            = 'Bytes Per Line';
const WIA_IPA_NUMBER_OF_LINES_STR           = 'Number of Lines';
const WIA_IPA_GAMMA_CURVES_STR              = 'Gamma Curves';
const WIA_IPA_ITEM_SIZE_STR                 = 'Item Size';
const WIA_IPA_COLOR_PROFILE_STR             = 'Color Profiles';
const WIA_IPA_MIN_BUFFER_SIZE_STR           = 'Buffer Size';
const WIA_IPA_REGION_TYPE_STR               = 'Region Type';
const WIA_IPA_ICM_PROFILE_NAME_STR          = 'Color Profile Name';
const WIA_IPA_APP_COLOR_MAPPING_STR         = 'Application Applies Color Mapping';
const WIA_IPA_PROP_STREAM_COMPAT_ID_STR     = 'Stream Compatibility ID';
const WIA_IPA_FILENAME_EXTENSION_STR        = 'Filename extension';
const WIA_IPA_SUPPRESS_PROPERTY_PAGE_STR    = 'Suppress a property page';

const WIA_NUM_IPA = (1 + WIA_IPA_LAST - WIA_IPA_FIRST);

const WIA_IPC_FIRST                         = WIA_IPA_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_IPC_THUMBNAIL                     = WIA_IPC_FIRST + 0;
const WIA_IPC_THUMB_WIDTH                   = WIA_IPC_FIRST + 1;
const WIA_IPC_THUMB_HEIGHT                  = WIA_IPC_FIRST + 2;
const WIA_IPC_AUDIO_AVAILABLE               = WIA_IPC_FIRST + 3;
const WIA_IPC_AUDIO_DATA_FORMAT             = WIA_IPC_FIRST + 4;
const WIA_IPC_AUDIO_DATA                    = WIA_IPC_FIRST + 5;
const WIA_IPC_NUM_PICT_PER_ROW              = WIA_IPC_FIRST + 6;
const WIA_IPC_SEQUENCE                      = WIA_IPC_FIRST + 7;
const WIA_IPC_TIMEDELAY                     = WIA_IPC_FIRST + 8;
const WIA_IPC_LAST                          = WIA_IPC_FIRST + 8;

const WIA_IPC_THUMBNAIL_STR                 = 'Thumbnail Data';
const WIA_IPC_THUMB_WIDTH_STR               = 'Thumbnail Width';
const WIA_IPC_THUMB_HEIGHT_STR              = 'Thumbnail Height';
const WIA_IPC_AUDIO_AVAILABLE_STR           = 'Audio Available';
const WIA_IPC_AUDIO_DATA_FORMAT_STR         = 'Audio Format';
const WIA_IPC_AUDIO_DATA_STR                = 'Audio Data';
const WIA_IPC_NUM_PICT_PER_ROW_STR          = 'Pictures per Row';
const WIA_IPC_SEQUENCE_STR                  = 'Sequence Number';
const WIA_IPC_TIMEDELAY_STR                 = 'Time Delay';

const WIA_NUM_IPC = (1 + WIA_IPC_LAST - WIA_IPC_FIRST);

//
// Scanner item properties
//
const WIA_IPS_FIRST                         = WIA_IPC_FIRST + WIA_RESERVED_FOR_NEW_PROPS;
const WIA_IPS_CUR_INTENT                    = WIA_IPS_FIRST + 0;
const WIA_IPS_XRES                          = WIA_IPS_FIRST + 1;
const WIA_IPS_YRES                          = WIA_IPS_FIRST + 2;
const WIA_IPS_XPOS                          = WIA_IPS_FIRST + 3;
const WIA_IPS_YPOS                          = WIA_IPS_FIRST + 4;
const WIA_IPS_XEXTENT                       = WIA_IPS_FIRST + 5;
const WIA_IPS_YEXTENT                       = WIA_IPS_FIRST + 6;
const WIA_IPS_PHOTOMETRIC_INTERP            = WIA_IPS_FIRST + 7;
const WIA_IPS_BRIGHTNESS                    = WIA_IPS_FIRST + 8;
const WIA_IPS_CONTRAST                      = WIA_IPS_FIRST + 9;
const WIA_IPS_ORIENTATION                   = WIA_IPS_FIRST + 10;
const WIA_IPS_ROTATION                      = WIA_IPS_FIRST + 11;
const WIA_IPS_MIRROR                        = WIA_IPS_FIRST + 12;
const WIA_IPS_THRESHOLD                     = WIA_IPS_FIRST + 13;
const WIA_IPS_INVERT                        = WIA_IPS_FIRST + 14;
const WIA_IPS_WARM_UP_TIME                  = WIA_IPS_FIRST + 15;
const WIA_IPS_LAST                          = WIA_IPS_FIRST + 15;

const WIA_IPS_CUR_INTENT_STR                = 'Current Intent';
const WIA_IPS_XRES_STR                      = 'Horizontal Resolution';
const WIA_IPS_YRES_STR                      = 'Vertical Resolution';
const WIA_IPS_XPOS_STR                      = 'Horizontal Start Position';
const WIA_IPS_YPOS_STR                      = 'Vertical Start Position';
const WIA_IPS_XEXTENT_STR                   = 'Horizontal Extent';
const WIA_IPS_YEXTENT_STR                   = 'Vertical Extent';
const WIA_IPS_PHOTOMETRIC_INTERP_STR        = 'Photometric Interpretation';
const WIA_IPS_BRIGHTNESS_STR                = 'Brightness';
const WIA_IPS_CONTRAST_STR                  = 'Contrast';
const WIA_IPS_ORIENTATION_STR               = 'Orientation';
const WIA_IPS_ROTATION_STR                  = 'Rotation';
const WIA_IPS_MIRROR_STR                    = 'Mirror';
const WIA_IPS_THRESHOLD_STR                 = 'Threshold';
const WIA_IPS_INVERT_STR                    = 'Invert';
const WIA_IPS_WARM_UP_TIME_STR              = 'Lamp Warm up Time';

const WIA_NUM_IPS = (1 + WIA_IPS_LAST - WIA_IPS_FIRST);

(*
DEFINE_GUID(WiaImgFmt_UNDEFINED, 0xb96b3ca9,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_RAWRGB, 0xbca48b55,0xf272,0x4371,0xb0,0xf1,0x4a,0x15,0xd,0x5,0x7b,0xb4);
DEFINE_GUID(WiaImgFmt_MEMORYBMP, 0xb96b3caa,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_BMP, 0xb96b3cab,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_EMF, 0xb96b3cac,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_WMF, 0xb96b3cad,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_JPEG, 0xb96b3cae,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_PNG, 0xb96b3caf,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_GIF, 0xb96b3cb0,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_TIFF, 0xb96b3cb1,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_EXIF, 0xb96b3cb2,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_PHOTOCD, 0xb96b3cb3,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_FLASHPIX, 0xb96b3cb4,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
DEFINE_GUID(WiaImgFmt_ICO, 0xb96b3cb5,0x0728,0x11d3,0x9d,0x7b,0x00,0x00,0xf8,0x1e,0xf3,0x2e);
// Canon Image File Format
DEFINE_GUID(WiaImgFmt_CIFF,0x9821a8ab,0x3a7e,0x4215,0x94,0xe0,0xd2,0x7a,0x46,0x0c,0x03,0xb2);
// Quickdraw Image Format
DEFINE_GUID(WiaImgFmt_PICT,0xa6bc85d8,0x6b3e,0x40ee,0xa9,0x5c,0x25,0xd4,0x82,0xe4,0x1a,0xdc);
// JPEG 2000 baseline file format
DEFINE_GUID(WiaImgFmt_JPEG2K,0x344ee2b2,0x39db,0x4dde,0x81,0x73,0xc4,0xb7,0x5f,0x8f,0x1e,0x49);
// JPEG 2000 extended file format
DEFINE_GUID(WiaImgFmt_JPEG2KX,0x43e14614,0xc80a,0x4850,0xba,0xf3,0x4b,0x15,0x2d,0xc8,0xda,0x27);


//**************************************************************************
//
// Document and other types
//
// Note: HTML, AVI, and MPEG used to have different GUIDs. Use the GUIDs
//       defined below from now on.
//
//**************************************************************************

DEFINE_GUID(WiaImgFmt_RTF, 0x573dd6a3,0x4834,0x432d,0xa9,0xb5,0xe1,0x98,0xdd,0x9e,0x89,0xd);
DEFINE_GUID(WiaImgFmt_XML, 0xb9171457,0xdac8,0x4884,0xb3,0x93,0x15,0xb4,0x71,0xd5,0xf0,0x7e);
DEFINE_GUID(WiaImgFmt_HTML, 0xc99a4e62,0x99de,0x4a94,0xac,0xca,0x71,0x95,0x6a,0xc2,0x97,0x7d);
DEFINE_GUID(WiaImgFmt_TXT, 0xfafd4d82,0x723f,0x421f,0x93,0x18,0x30,0x50,0x1a,0xc4,0x4b,0x59);
DEFINE_GUID(WiaImgFmt_MPG, 0xecd757e4,0xd2ec,0x4f57,0x95,0x5d,0xbc,0xf8,0xa9,0x7c,0x4e,0x52);
DEFINE_GUID(WiaImgFmt_AVI, 0x32f8ca14,0x87c,0x4908,0xb7,0xc4,0x67,0x57,0xfe,0x7e,0x90,0xab);
DEFINE_GUID(WiaImgFmt_ASF, 0x8d948ee9,0xd0aa,0x4a12,0x9d,0x9a,0x9c,0xc5,0xde,0x36,0x19,0x9b);
DEFINE_GUID(WiaImgFmt_SCRIPT, 0xfe7d6c53,0x2dac,0x446a,0xb0,0xbd,0xd7,0x3e,0x21,0xe9,0x24,0xc9);
DEFINE_GUID(WiaImgFmt_EXEC, 0x485da097,0x141e,0x4aa5,0xbb,0x3b,0xa5,0x61,0x8d,0x95,0xd0,0x2b);
DEFINE_GUID(WiaImgFmt_UNICODE16,0x1b7639b6,0x6357,0x47d1,0x9a,0x07,0x12,0x45,0x2d,0xc0,0x73,0xe9);
DEFINE_GUID(WiaImgFmt_DPOF,0x369eeeab,0xa0e8,0x45ca,0x86,0xa6,0xa8,0x3c,0xe5,0x69,0x7e,0x28);


//**************************************************************************
//
// Audio types
//
//**************************************************************************

DEFINE_GUID(WiaAudFmt_WAV, 0xf818e146,0x07af,0x40ff,0xae,0x55,0xbe,0x8f,0x2c,0x06,0x5d,0xbe);
DEFINE_GUID(WiaAudFmt_MP3, 0x0fbc71fb,0x43bf,0x49f2,0x91,0x90,0xe6,0xfe,0xcf,0xf3,0x7e,0x54);
DEFINE_GUID(WiaAudFmt_AIFF, 0x66e2bf4f,0xb6fc,0x443f,0x94,0xc8,0x2f,0x33,0xc8,0xa6,0x5a,0xaf);
DEFINE_GUID(WiaAudFmt_WMA, 0xd61d6413,0x8bc2,0x438f,0x93,0xad,0x21,0xbd,0x48,0x4d,0xb6,0xa1);


//**************************************************************************
//
// WIA Events
//
//**************************************************************************

//
// Event registration flags, used by RegisterEventLaunch,
// RegisterEventCallbackInterface and RegisterEventCallbackCLSID.
//

#define  WIA_REGISTER_EVENT_CALLBACK        0x00000001
#define  WIA_UNREGISTER_EVENT_CALLBACK      0x00000002
#define  WIA_SET_DEFAULT_HANDLER            0x00000004

//
// Event type : individual bits of the possible event type combinations
//

#define  WIA_NOTIFICATION_EVENT             0x00000001
#define  WIA_ACTION_EVENT                   0x00000002

//
// Flag to indicate the corresponding persistent handler is default
//

#define  WIA_IS_DEFAULT_HANDLER             0x00000001

//
// Event GUIDs
//

DEFINE_GUID(WIA_EVENT_DEVICE_DISCONNECTED,  0x143e4e83, 0x6497, 0x11d2, 0xa2, 0x31, 0x0, 0xc0, 0x4f, 0xa3, 0x18, 0x9);
DEFINE_GUID(WIA_EVENT_DEVICE_CONNECTED,     0xa28bbade, 0x64b6, 0x11d2, 0xa2, 0x31, 0x0, 0xc0, 0x4f, 0xa3, 0x18, 0x9);
DEFINE_GUID(WIA_EVENT_ITEM_DELETED,         0x1d22a559, 0xe14f, 0x11d2, 0xb3, 0x26, 0x00, 0xc0, 0x4f, 0x68, 0xce, 0x61);
DEFINE_GUID(WIA_EVENT_ITEM_CREATED,         0x4c8f4ef5, 0xe14f, 0x11d2, 0xb3, 0x26, 0x00, 0xc0, 0x4f, 0x68, 0xce, 0x61);
DEFINE_GUID(WIA_EVENT_TREE_UPDATED,         0xc9859b91, 0x4ab2, 0x4cd6, 0xa1, 0xfc, 0x58, 0x2e, 0xec, 0x55, 0xe5, 0x85);
DEFINE_GUID(WIA_EVENT_VOLUME_INSERT,        0x9638bbfd, 0xd1bd, 0x11d2, 0xb3, 0x1f, 0x00, 0xc0, 0x4f, 0x68, 0xce, 0x61);
DEFINE_GUID(WIA_EVENT_SCAN_IMAGE,           0xa6c5a715, 0x8c6e, 0x11d2, 0x97, 0x7a, 0x0, 0x0, 0xf8, 0x7a, 0x92, 0x6f);
DEFINE_GUID(WIA_EVENT_SCAN_PRINT_IMAGE,     0xb441f425, 0x8c6e, 0x11d2, 0x97, 0x7a, 0x0, 0x0, 0xf8, 0x7a, 0x92, 0x6f);
DEFINE_GUID(WIA_EVENT_SCAN_FAX_IMAGE,       0xc00eb793, 0x8c6e, 0x11d2, 0x97, 0x7a, 0x0, 0x0, 0xf8, 0x7a, 0x92, 0x6f);
DEFINE_GUID(WIA_EVENT_SCAN_OCR_IMAGE,       0x9d095b89, 0x37d6, 0x4877, 0xaf, 0xed, 0x62, 0xa2, 0x97, 0xdc, 0x6d, 0xbe);
DEFINE_GUID(WIA_EVENT_SCAN_EMAIL_IMAGE,     0xc686dcee, 0x54f2, 0x419e, 0x9a, 0x27, 0x2f, 0xc7, 0xf2, 0xe9, 0x8f, 0x9e);
DEFINE_GUID(WIA_EVENT_SCAN_FILM_IMAGE,      0x9b2b662c, 0x6185, 0x438c, 0xb6, 0x8b, 0xe3, 0x9e, 0xe2, 0x5e, 0x71, 0xcb);
DEFINE_GUID(WIA_EVENT_SCAN_IMAGE2,          0xfc4767c1, 0xc8b3, 0x48a2, 0x9c, 0xfa, 0x2e, 0x90, 0xcb, 0x3d, 0x35, 0x90);
DEFINE_GUID(WIA_EVENT_SCAN_IMAGE3,          0x154e27be, 0xb617, 0x4653, 0xac, 0xc5, 0xf, 0xd7, 0xbd, 0x4c, 0x65, 0xce);
DEFINE_GUID(WIA_EVENT_SCAN_IMAGE4,          0xa65b704a, 0x7f3c, 0x4447, 0xa7, 0x5d, 0x8a, 0x26, 0xdf, 0xca, 0x1f, 0xdf);
DEFINE_GUID(WIA_EVENT_STORAGE_CREATED,      0x353308b2, 0xfe73, 0x46c8, 0x89, 0x5e, 0xfa, 0x45, 0x51, 0xcc, 0xc8, 0x5a);
DEFINE_GUID(WIA_EVENT_STORAGE_DELETED,      0x5e41e75e, 0x9390, 0x44c5, 0x9a, 0x51, 0xe4, 0x70, 0x19, 0xe3, 0x90, 0xcf);
DEFINE_GUID(WIA_EVENT_STI_PROXY,            0xd711f81f, 0x1f0d, 0x422d, 0x86, 0x41, 0x92, 0x7d, 0x1b, 0x93, 0xe5, 0xe5);
DEFINE_GUID(WIA_EVENT_CANCEL_IO,            0xc860f7b8, 0x9ccd, 0x41ea, 0xbb, 0xbf, 0x4d, 0xd0, 0x9c, 0x5b, 0x17, 0x95);

//
// Power management event GUIDs, sent by the WIA service to drivers
//

DEFINE_GUID(WIA_EVENT_POWER_SUSPEND,    0xa0922ff9, 0xc3b4, 0x411c, 0x9e, 0x29, 0x03, 0xa6, 0x69, 0x93, 0xd2, 0xbe);
DEFINE_GUID(WIA_EVENT_POWER_RESUME,     0x618f153e, 0xf686, 0x4350, 0x96, 0x34, 0x41, 0x15, 0xa3, 0x04, 0x83, 0x0c);


//
// No action handler and prompt handler
//

DEFINE_GUID(WIA_EVENT_HANDLER_NO_ACTION, 0xe0372b7d, 0xe115, 0x4525, 0xbc, 0x55, 0xb6, 0x29, 0xe6, 0x8c, 0x74, 0x5a);
DEFINE_GUID(WIA_EVENT_HANDLER_PROMPT, 0x5f4baad0, 0x4d59, 0x4fcd, 0xb2, 0x13, 0x78, 0x3c, 0xe7, 0xa9, 0x2f, 0x22);

#define WIA_EVENT_DEVICE_DISCONNECTED_STR   L"Device Disconnected"
#define WIA_EVENT_DEVICE_CONNECTED_STR      L"Device Connected"


//**************************************************************************
//
// WIA Commands
//
//**************************************************************************

DEFINE_GUID(WIA_CMD_SYNCHRONIZE, 0x9b26b7b2, 0xacad, 0x11d2, 0xa0, 0x93, 0x00, 0xc0, 0x4f, 0x72, 0xdc, 0x3c);
DEFINE_GUID(WIA_CMD_TAKE_PICTURE, 0xaf933cac, 0xacad, 0x11d2, 0xa0, 0x93, 0x00, 0xc0, 0x4f, 0x72, 0xdc, 0x3c);
DEFINE_GUID(WIA_CMD_DELETE_ALL_ITEMS, 0xe208c170, 0xacad, 0x11d2, 0xa0, 0x93, 0x00, 0xc0, 0x4f, 0x72, 0xdc, 0x3c);
DEFINE_GUID(WIA_CMD_CHANGE_DOCUMENT, 0x04e725b0, 0xacae, 0x11d2, 0xa0, 0x93, 0x00, 0xc0, 0x4f, 0x72, 0xdc, 0x3c);
DEFINE_GUID(WIA_CMD_UNLOAD_DOCUMENT, 0x1f3b3d8e, 0xacae, 0x11d2, 0xa0, 0x93, 0x00, 0xc0, 0x4f, 0x72, 0xdc, 0x3c);
DEFINE_GUID(WIA_CMD_DIAGNOSTIC, 0x10ff52f5, 0xde04, 0x4cf0, 0xa5, 0xad, 0x69, 0x1f, 0x8d, 0xce, 0x01, 0x41);

//
// The following are private commands for debugging use only.
//

DEFINE_GUID(WIA_CMD_DELETE_DEVICE_TREE, 0x73815942, 0xdbea, 0x11d2, 0x84, 0x16, 0x00, 0xc0, 0x4f, 0xa3, 0x61, 0x45);
DEFINE_GUID(WIA_CMD_BUILD_DEVICE_TREE, 0x9cba5ce0, 0xdbea, 0x11d2, 0x84, 0x16, 0x00, 0xc0, 0x4f, 0xa3, 0x61, 0x45);

*)

const
  IT_MSG_DATA_HEADER = $1;
  IT_MSG_DATA = $2;
  IT_MSG_STATUS = $3;
  IT_MSG_TERMINATION = $4;
  IT_MSG_NEW_PAGE = $5;
  IT_MSG_FILE_PREVIEW_DATA = $6;
  IT_MSG_FILE_PREVIEW_DATA_HEADER = $7;

  IT_STATUS_TRANSFER_FROM_DEVICE         = $0001;
  IT_STATUS_PROCESSING_DATA              = $0002;
  IT_STATUS_TRANSFER_TO_CLIENT           = $0004;

  TYMED_CALLBACK           = 128;
  TYMED_MULTIPAGE_FILE     = 256;
  TYMED_MULTIPAGE_CALLBACK = 512;

  WiaItemTypeFree                        = $00000000;
  WiaItemTypeImage                       = $00000001;
  WiaItemTypeFile                        = $00000002;
  WiaItemTypeFolder                      = $00000004;
  WiaItemTypeRoot                        = $00000008;
  WiaItemTypeAnalyze                     = $00000010;
  WiaItemTypeAudio                       = $00000020;
  WiaItemTypeDevice                      = $00000040;
  WiaItemTypeDeleted                     = $00000080;
  WiaItemTypeDisconnected                = $00000100;
  WiaItemTypeHPanorama                   = $00000200;
  WiaItemTypeVPanorama                   = $00000400;
  WiaItemTypeBurst                       = $00000800;
  WiaItemTypeStorage                     = $00001000;
  WiaItemTypeTransfer                    = $00002000;
  WiaItemTypeGenerated                   = $00004000;
  WiaItemTypeHasAttachments               = $00008000;
  WiaItemTypeVideo                       = $00010000;

implementation

end.
