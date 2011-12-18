unit uWIAInterfaces;

interface

uses
  Windows, ActiveX;

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
    function EnumChildItems(EnumWiaItem: IEnumWiaItem): HRESULT; safecall;
    function DeleteItem(const lTags: Integer): HRESULT; safecall;
    function CreateChildItem(lFlags: Integer;
      bstrItemName: string;
      bstrFullItemName: string;
      var ppIWiaItem: IWiaItem): HRESULT; safecall;
    function EnumRegisterEventInfo(lFlags: Integer;
      const pEventGUID: TGUID;
      var ppIEnum: IEnumWIA_DEV_CAPS): HRESULT;
    function FindItemByName(lFlags: Integer;
      bstrFullItemName: string;
      var ppIWiaItem: IWiaItem): HRESULT; safecall;
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

  IWiaDevMgr2 = interface(IUnknown)
    ['{79C07CF1-CBDD-41EE-8EC3-F00080CADA7A}']
  end;

  IEnumWiaItem2 = interface(IUnknown)
    ['{59970AF4-CD0D-44D9-AB24-52295630E582}']
  end;

  IWiaItem2 = interface(IUnknown)
    ['{6CBA0075-1287-407D-9B77-CF0E030435CC}']
    //function GetItemType(var itemType: Integer): HRESULT; safecall;
    //procedure AnalyzeItem(var lTags: Integer); safecall;
    //procedure EnumChildItems(EnumWiaItem: IEnumWiaItem2); safecall;
    function DeleteItem(const lTags: Integer): HRESULT; safecall;
  end;

implementation

end.
