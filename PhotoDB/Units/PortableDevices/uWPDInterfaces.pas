unit uWPDInterfaces;

interface

uses
  Windows, ActiveX;

const
  CLSID_PortableDeviceKeyCollection: TGUID = '{de2d022d-2480-43be-97f0-d1fa2cf98f4f}';
  IID_PortableDeviceKeyCollection: TGUID = '{DADA2357-E0AD-492E-98DB-DD61C53BA353}';

  CLSID_PortableDeviceValues: TGUID = '{0c15d503-d017-47ce-9016-7b3f978721cc}';
  IID_PortableDeviceValues:TGUID = '{6848F6F2-3155-4F86-B6F5-263EEEAB3143}';

  CLSID_PortableDeviceManager: TGUID = '{0af10cec-2ecd-4b92-9581-34f6ae0637f3}';
  IID_PortableDeviceManager: TGUID = '{A1567595-4C2F-4574-A6FA-ECEF917B9A40}';

  CLSID_PortableDeviceFTM: TGUID = '{f7c0039a-4762-488a-b4b3-760ef9a1ba9b}';
  IID_PortableDeviceFTM: TGUID = '{625E2DF8-6392-4CF0-9AD1-3CFA5F17775C}';

  CLSID_PortableDevice: TGUID = '{728a21c5-3d9e-48d7-9810-864848f0f404}';
  IID_PortableDevice: TGUID  = '{625e2df8-6392-4cf0-9ad1-3cfa5f17775c}';

  CLSID_PortableDevicePropVariantCollection: TGUID  = '{08a99e2f-6d6d-4b80-af5a-baf2bcbe4cb9}';
  IID_PortableDevicePropVariantCollection: TGUID  = '{89B2E422-4F1B-4316-BCEF-A44AFEA83EB3}';

  WPD_CLIENT_INFO: TGUID = '{204D9F0C-2292-4080-9F42-40664E70F859}';

  WPD_DEVICE_OBJECT_ID = 'DEVICE';

  WPD_RESOURCE_DEFAULT: TGUID   = '{E81E79BE-34F0-41BF-B53F-F1A06AE87842}';
  WPD_RESOURCE_THUMBNAIL: TGUID = '{C7C407BA-98FA-46B5-9960-23FEC124CFDE}';

  WPD_CONTENT_TYPE_IMAGE: TGUID              = '{ef2107d5-a52a-4243-a26b-62d4176d7603}';
  WPD_CONTENT_TYPE_FOLDER: TGUID             = '{27E2E392-A111-48E0-AB0C-E17705A05F85}';
  WPD_CONTENT_TYPE_VIDEO: TGUID              = '{9261B03C-3D78-4519-85E3-02C5E1F50BB9}';
  WPD_CONTENT_TYPE_FUNCTIONAL_OBJECT: TGUID  = '{99ED0160-17FF-4C44-9D98-1D7A6F941921}';

  PKEY_GenericObj: TGUID = '{EF6B490D-5CD8-437A-AFFC-DA8B60EE4A3C}';
  WPD_OBJECT_ID = 2;
  WPD_OBJECT_PARENT_ID = 3;
  WPD_OBJECT_NAME = 4;
  WPD_OBJECT_PERSISTENT_UNIQUE_ID = 5;
  WPD_OBJECT_FORMAT = 6;
  WPD_OBJECT_CONTENT_TYPE = 7;
  WPD_OBJECT_ISHIDDEN = 9;
  WPD_OBJECT_ISSYSTEM = 10;
  WPD_OBJECT_SIZE = 11;
  WPD_OBJECT_ORIGINAL_FILE_NAME = 12;
  //   [ VT_BOOL ] This property determines whether or not this object is intended to be understood by the device, or whether it has been placed on the device just for storage.
  WPD_OBJECT_NON_CONSUMABLE = 13;
  WPD_OBJECT_DATE_CREATED = 18;
  WPD_OBJECT_DATE_MODIFIED = 19;
  WPD_OBJECT_DATE_AUTHORED = 20;
//   [ VT_LPWSTR ] Indicates the Object ID of the closest functional object ancestor. For example, objects that represent files/folders under a Storage functional object, will have this property set to the object ID of the storage functional object.
  WPD_OBJECT_CONTAINER_FUNCTIONAL_OBJECT_ID = 23;

  PKEY_DeviceObj: TGUID = '{26D4979A-E643-4626-9E2B-736DC0C92FDC}';
  WPD_DEVICE_FIRMWARE_VERSION = 3;
  WPD_DEVICE_POWER_LEVEL = 4;
  WPD_DEVICE_MANUFACTURER = 7;
  WPD_DEVICE_MODEL = 8;
  WPD_DEVICE_SERIAL_NUMBER = 9;
  WPD_DEVICE_FRIENDLY_NAME = 10;
  WPD_DEVICE_TYPE = 15;

  WPD_DEVICE_TYPE_GENERIC = 0;
  WPD_DEVICE_TYPE_CAMERA = 1;
  WPD_DEVICE_TYPE_MEDIA_PLAYER = 2;
  WPD_DEVICE_TYPE_PHONE = 3;
  WPD_DEVICE_TYPE_VIDEO = 4;
  WPD_DEVICE_TYPE_PERSONAL_INFORMATION_MANAGER = 5;
  WPD_DEVICE_TYPE_AUDIO_RECORDER = 6;

  WPD_STORAGE_OBJECT_PROPERTIES_V1: TGUID = '{01A3057A-74D6-4E80-BEA7-DC4C212CE50A}';
  WPD_STORAGE_TYPE = 2;
  WPD_STORAGE_FILE_SYSTEM_TYPE = 3;
  WPD_STORAGE_CAPACITY = 4;
  WPD_STORAGE_FREE_SPACE_IN_BYTES = 5;

  WPD_RESOURCE_ATTRIBUTES_V1: TGUID = '{1EB6F604-9278-429F-93CC-5BB8C06656B6}';
  WPD_RESOURCE_ATTRIBUTE_OPTIMAL_READ_BUFFER_SIZE = 6;
  WPD_RESOURCE_ATTRIBUTE_FORMAT = 8;

  WPD_OBJECT_FORMAT_BMP: TGUID          = '{38040000-AE6C-4804-98BA-C57B46965FE7}';
  WPD_OBJECT_FORMAT_GIF: TGUID          = '{38070000-AE6C-4804-98BA-C57B46965FE7}';
  WPD_OBJECT_FORMAT_JFIF: TGUID         = '{38080000-AE6C-4804-98BA-C57B46965FE7}';
  WPD_OBJECT_FORMAT_PNG: TGUID          = '{380B0000-AE6C-4804-98BA-C57B46965FE7}';
  WPD_OBJECT_FORMAT_UNSPECIFIED: TGUID  = '{30000000-AE6C-4804-98BA-C57B46965FE7}';

  WPD_RESOURCE_BRANDING_ART: TGUID      = '{B633B1AE-6CAF-4A87-9589-22DED6DD5899}';

  WPD_MEDIA_PROPERTIES_V1: TGUID  = '{2ED8BA05-0AD3-42DC-B0D0-BC95AC396AC8}';
  WPD_MEDIA_WIDTH = 22;
  WPD_MEDIA_HEIGHT = 23;

  WPD_EVENT_PROPERTIES_V1: TGUID  = '{15AB1953-F817-4FEF-A921-5676E838F6E0}';
  WPD_EVENT_PARAMETER_PNP_DEVICE_ID = 2;
  WPD_EVENT_PARAMETER_EVENT_ID = 3;

  //connection event is sent as windows message
  WPD_EVENT_OBJECT_ADDED: TGUID   = '{A726DA95-E207-4B02-8D44-BEF2E86CBFFC}';
  WPD_EVENT_OBJECT_REMOVED: TGUID = '{BE82AB88-A52C-4823-96E5-D0272671FC38}';
  WPD_EVENT_DEVICE_RESET: TGUID   = '{7755CF53-C1ED-44F3-B5A2-451E2C376B27}';
  WPD_EVENT_DEVICE_REMOVED: TGUID = '{E4CBCA1B-6918-48B9-85EE-02BE7C850AF9}';

  WPD_CATEGORY_OBJECT_MANAGEMENT: TGUID  = '{EF1E43DD-A9ED-4341-8BCC-186192AEA089}';
  WPD_COMMAND_OBJECT_MANAGEMENT_DELETE_OBJECTS = 7;
  WPD_OPTION_OBJECT_MANAGEMENT_RECURSIVE_DELETE_SUPPORTED = 5001;

  PORTABLE_DEVICE_DELETE_NO_RECURSION     = 0;
  PORTABLE_DEVICE_DELETE_WITH_RECURSION   = 1;

type
  PWSTR = ^WChar;

// Constants for enum tagSYSKIND
type
  tagSYSKIND = TOleEnum;

// Constants for enum tagVARKIND
type
  tagVARKIND = TOleEnum;

// *********************************************************************//
// Declaration of structures, unions and aliases.
// *********************************************************************//
  wirePSAFEARRAY = ^PUserType5;
  wireSNB = ^tagRemSNB;
  PUserType6 = ^_FLAGGED_WORD_BLOB; {*}
  PUserType7 = ^_wireVARIANT; {*}
  PUserType14 = ^_wireBRECORD; {*}
  PUserType5 = ^_wireSAFEARRAY; {*}
  PPUserType1 = ^PUserType5; {*}
  PUserType11 = ^tagTYPEDESC; {*}
  PUserType12 = ^tagARRAYDESC; {*}
  PUserType2 = ^tag_inner_PROPVARIANT; {*}
  PUINT1 = ^LongWord; {*}
  PUserType1 = ^_tagpropertykey; {*}
  PUserType3 = ^TGUID; {*}
  PByte1 = ^Byte; {*}
  PUserType4 = ^_FILETIME; {*}
  POleVariant1 = ^OleVariant; {*}
  PUserType8 = ^tagTYPEATTR; {*}
  PUserType9 = ^tagFUNCDESC; {*}
  PUserType10 = ^tagVARDESC; {*}
  PUserType13 = ^tagTLIBATTR; {*}

  _tagpropertykey = record
    fmtid: TGUID;
    pid: LongWord;
  end;

{$ALIGN 8}
  _LARGE_INTEGER = record
    QuadPart: Int64;
  end;

  _ULARGE_INTEGER = record
    QuadPart: Largeuint;
  end;

{$ALIGN 4}
  _FILETIME = record
    dwLowDateTime: LongWord;
    dwHighDateTime: LongWord;
  end;

  tagCLIPDATA = record
    cbSize: LongWord;
    ulClipFmt: Integer;
    pClipData: ^Byte;
  end;

  tagBSTRBLOB = record
    cbSize: LongWord;
    pData: ^Byte;
  end;

  tagBLOB = record
    cbSize: LongWord;
    pBlobData: ^Byte;
  end;

  tagVersionedStream = record
    guidVersion: TGUID;
    pStream: IStream;
  end;


{$ALIGN 8}
  tagSTATSTG = record
    pwcsName: PWideChar;
    type_: LongWord;
    cbSize: _ULARGE_INTEGER;
    mtime: _FILETIME;
    ctime: _FILETIME;
    atime: _FILETIME;
    grfMode: LongWord;
    grfLocksSupported: LongWord;
    clsid: TGUID;
    grfStateBits: LongWord;
    reserved: LongWord;
  end;


{$ALIGN 4}
  tagRemSNB = record
    ulCntStr: LongWord;
    ulCntChar: LongWord;
    rgString: ^Word;
  end;

  tagCAC = record
    cElems: LongWord;
    pElems: ^Shortint;
  end;

  tagCAUB = record
    cElems: LongWord;
    pElems: ^Byte;
  end;


  _wireSAFEARR_BSTR = record
    Size: LongWord;
    aBstr: ^PUserType6;
  end;

  _wireSAFEARR_UNKNOWN = record
    Size: LongWord;
    apUnknown: ^IUnknown;
  end;

  _wireSAFEARR_DISPATCH = record
    Size: LongWord;
    apDispatch: ^IDispatch;
  end;

  _FLAGGED_WORD_BLOB = record
    fFlags: LongWord;
    clSize: LongWord;
    asData: ^Word;
  end;


  _wireSAFEARR_VARIANT = record
    Size: LongWord;
    aVariant: ^PUserType7;
  end;


  _wireBRECORD = record
    fFlags: LongWord;
    clSize: LongWord;
    pRecInfo: IRecordInfo;
    pRecord: ^Byte;
  end;


  __MIDL_IOleAutomationTypes_0005 = record
    case Integer of
      0: (lptdesc: PUserType11);
      1: (lpadesc: PUserType12);
      2: (hreftype: LongWord);
  end;

  tagTYPEDESC = record
    DUMMYUNIONNAME: __MIDL_IOleAutomationTypes_0005;
    vt: Word;
  end;

  tagSAFEARRAYBOUND = record
    cElements: LongWord;
    lLbound: Integer;
  end;

  ULONG_PTR = LongWord;

  tagIDLDESC = record
    dwReserved: ULONG_PTR;
    wIDLFlags: Word;
  end;

  DWORD = LongWord;

{$ALIGN 8}
  tagPARAMDESCEX = record
    cBytes: LongWord;
    varDefaultValue: OleVariant;
  end;

{$ALIGN 4}
  tagPARAMDESC = record
    pparamdescex: ^tagPARAMDESCEX;
    wParamFlags: Word;
  end;

  tagELEMDESC = record
    tdesc: tagTYPEDESC;
    paramdesc: tagPARAMDESC;
  end;

  tagFUNCDESC = record
    memid: Integer;
    lprgscode: ^SCODE;
    lprgelemdescParam: ^tagELEMDESC;
    funckind: tagFUNCKIND;
    invkind: tagINVOKEKIND;
    callconv: tagCALLCONV;
    cParams: Smallint;
    cParamsOpt: Smallint;
    oVft: Smallint;
    cScodes: Smallint;
    elemdescFunc: tagELEMDESC;
    wFuncFlags: Word;
  end;

  __MIDL_IOleAutomationTypes_0006 = record
    case Integer of
      0: (oInst: LongWord);
      1: (lpvarValue: ^OleVariant);
  end;

  tagVARDESC = record
    memid: Integer;
    lpstrSchema: PWideChar;
    DUMMYUNIONNAME: __MIDL_IOleAutomationTypes_0006;
    elemdescVar: tagELEMDESC;
    wVarFlags: Word;
    varkind: tagVARKIND;
  end;

  tagTLIBATTR = record
    guid: TGUID;
    lcid: LongWord;
    syskind: tagSYSKIND;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    wLibFlags: Word;
  end;

  _wireSAFEARR_BRECORD = record
    Size: LongWord;
    aRecord: ^PUserType14;
  end;

  _wireSAFEARR_HAVEIID = record
    Size: LongWord;
    apUnknown: ^IUnknown;
    iid: TGUID;
  end;

  _BYTE_SIZEDARR = record
    clSize: LongWord;
    pData: ^Byte;
  end;

  _SHORT_SIZEDARR = record
    clSize: LongWord;
    pData: ^Word;
  end;

  _LONG_SIZEDARR = record
    clSize: LongWord;
    pData: ^LongWord;
  end;

  _HYPER_SIZEDARR = record
    clSize: LongWord;
    pData: ^Int64;
  end;

  tagCAI = record
    cElems: LongWord;
    pElems: ^Smallint;
  end;

  tagCAUI = record
    cElems: LongWord;
    pElems: ^Word;
  end;

  tagCAL = record
    cElems: LongWord;
    pElems: ^Integer;
  end;

  tagCAUL = record
    cElems: LongWord;
    pElems: ^LongWord;
  end;

  tagCAH = record
    cElems: LongWord;
    pElems: ^_LARGE_INTEGER;
  end;

  tagCAUH = record
    cElems: LongWord;
    pElems: ^_ULARGE_INTEGER;
  end;

  tagCAFLT = record
    cElems: LongWord;
    pElems: ^Single;
  end;

  tagCADBL = record
    cElems: LongWord;
    pElems: ^Double;
  end;

  tagCABOOL = record
    cElems: LongWord;
    pElems: ^WordBool;
  end;

  tagCASCODE = record
    cElems: LongWord;
    pElems: ^SCODE;
  end;

  tagCACY = record
    cElems: LongWord;
    pElems: ^Currency;
  end;

  tagCADATE = record
    cElems: LongWord;
    pElems: ^TDateTime;
  end;

  tagCAFILETIME = record
    cElems: LongWord;
    pElems: ^_FILETIME;
  end;

  tagCACLSID = record
    cElems: LongWord;
    pElems: ^TGUID;
  end;

  tagCACLIPDATA = record
    cElems: LongWord;
    pElems: ^tagCLIPDATA;
  end;

  tagCABSTR = record
    cElems: LongWord;
    pElems: ^WideString;
  end;

  tagCABSTRBLOB = record
    cElems: LongWord;
    pElems: ^tagBSTRBLOB;
  end;

  tagCALPSTR = record
    cElems: LongWord;
    pElems: ^PAnsiChar;
  end;

  tagCALPWSTR = record
    cElems: LongWord;
    pElems: ^PWideChar;
  end;


  tagCAPROPVARIANT = record
    cElems: LongWord;
    pElems: PUserType2;
  end;

{$ALIGN 8}
  __MIDL___MIDL_itf_PortableDeviceApi_0001_0000_0001 = record
    case Integer of
      0: (cVal: Shortint);
      1: (bVal: Byte);
      2: (iVal: Smallint);
      3: (uiVal: Word);
      4: (lVal: Integer);
      5: (ulVal: LongWord);
      6: (intVal: SYSINT);
      7: (uintVal: SYSUINT);
      8: (hVal: _LARGE_INTEGER);
      9: (uhVal: _ULARGE_INTEGER);
      10: (fltVal: Single);
      11: (dblVal: Double);
      12: (boolVal: WordBool);
      13: (bool: WordBool);
      14: (scode: SCODE);
      15: (cyVal: Currency);
      16: (date: TDateTime);
      17: (filetime: _FILETIME);
      18: (puuid: ^TGUID);
      19: (pClipData: ^tagCLIPDATA);
      20: (bstrVal: {NOT_UNION(WideString)}Pointer);
      21: (bstrblobVal: tagBSTRBLOB);
      22: (blob: tagBLOB);
      23: (pszVal: PAnsiChar);
      24: (pwszVal: PWideChar);
      25: (punkVal: {NOT_UNION(IUnknown)}Pointer);
      26: (pdispVal: {NOT_UNION(IDispatch)}Pointer);
      27: (pStream: {NOT_UNION(IStream)}Pointer);
      28: (pStorage: {NOT_UNION(IStorage)}Pointer);
      29: (pVersionedStream: ^tagVersionedStream);
      30: (parray: wirePSAFEARRAY);
      31: (cac: tagCAC);
      32: (caub: tagCAUB);
      33: (cai: tagCAI);
      34: (caui: tagCAUI);
      35: (cal: tagCAL);
      36: (caul: tagCAUL);
      37: (cah: tagCAH);
      38: (cauh: tagCAUH);
      39: (caflt: tagCAFLT);
      40: (cadbl: tagCADBL);
      41: (cabool: tagCABOOL);
      42: (cascode: tagCASCODE);
      43: (cacy: tagCACY);
      44: (cadate: tagCADATE);
      45: (cafiletime: tagCAFILETIME);
      46: (cauuid: tagCACLSID);
      47: (caclipdata: tagCACLIPDATA);
      48: (cabstr: tagCABSTR);
      49: (cabstrblob: tagCABSTRBLOB);
      50: (calpstr: tagCALPSTR);
      51: (calpwstr: tagCALPWSTR);
      52: (capropvar: tagCAPROPVARIANT);
      53: (pcVal: ^Shortint);
      54: (pbVal: ^Byte);
      55: (piVal: ^Smallint);
      56: (puiVal: ^Word);
      57: (plVal: ^Integer);
      58: (pulVal: ^LongWord);
      59: (pintVal: ^SYSINT);
      60: (puintVal: ^SYSUINT);
      61: (pfltVal: ^Single);
      62: (pdblVal: ^Double);
      63: (pboolVal: ^WordBool);
      64: (pdecVal: ^TDecimal);
      65: (pscode: ^SCODE);
      66: (pcyVal: ^Currency);
      67: (pdate: ^TDateTime);
      68: (pbstrVal: ^WideString);
      69: (ppunkVal: {NOT_UNION(^IUnknown)}Pointer);
      70: (ppdispVal: {NOT_UNION(^IDispatch)}Pointer);
      71: (pparray: ^wirePSAFEARRAY);
      72: (pvarVal: PUserType2);
  end;


  tag_inner_PROPVARIANT = record
    vt: Word;
    wReserved1: Byte;
    wReserved2: Byte;
    wReserved3: LongWord;
    __MIDL____MIDL_itf_PortableDeviceApi_0001_00000001: __MIDL___MIDL_itf_PortableDeviceApi_0001_0000_0001;
  end;


  __MIDL_IOleAutomationTypes_0004 = record
    case Integer of
      0: (llVal: Int64);
      1: (lVal: Integer);
      2: (bVal: Byte);
      3: (iVal: Smallint);
      4: (fltVal: Single);
      5: (dblVal: Double);
      6: (boolVal: WordBool);
      7: (scode: SCODE);
      8: (cyVal: Currency);
      9: (date: TDateTime);
      10: (bstrVal: ^_FLAGGED_WORD_BLOB);
      11: (punkVal: {NOT_UNION(IUnknown)}Pointer);
      12: (pdispVal: {NOT_UNION(IDispatch)}Pointer);
      13: (parray: ^PUserType5);
      14: (brecVal: ^_wireBRECORD);
      15: (pbVal: ^Byte);
      16: (piVal: ^Smallint);
      17: (plVal: ^Integer);
      18: (pllVal: ^Int64);
      19: (pfltVal: ^Single);
      20: (pdblVal: ^Double);
      21: (pboolVal: ^WordBool);
      22: (pscode: ^SCODE);
      23: (pcyVal: ^Currency);
      24: (pdate: ^TDateTime);
      25: (pbstrVal: ^PUserType6);
      26: (ppunkVal: {NOT_UNION(^IUnknown)}Pointer);
      27: (ppdispVal: {NOT_UNION(^IDispatch)}Pointer);
      28: (pparray: ^PPUserType1);
      29: (pvarVal: ^PUserType7);
      30: (cVal: Shortint);
      31: (uiVal: Word);
      32: (ulVal: LongWord);
      33: (ullVal: Largeuint);
      34: (intVal: SYSINT);
      35: (uintVal: SYSUINT);
      36: (decVal: TDecimal);
      37: (pdecVal: ^TDecimal);
      38: (pcVal: ^Shortint);
      39: (puiVal: ^Word);
      40: (pulVal: ^LongWord);
      41: (pullVal: ^Largeuint);
      42: (pintVal: ^SYSINT);
      43: (puintVal: ^SYSUINT);
  end;

{$ALIGN 4}
  __MIDL_IOleAutomationTypes_0001 = record
    case Integer of
      0: (BstrStr: _wireSAFEARR_BSTR);
      1: (UnknownStr: _wireSAFEARR_UNKNOWN);
      2: (DispatchStr: _wireSAFEARR_DISPATCH);
      3: (VariantStr: _wireSAFEARR_VARIANT);
      4: (RecordStr: _wireSAFEARR_BRECORD);
      5: (HaveIidStr: _wireSAFEARR_HAVEIID);
      6: (ByteStr: _BYTE_SIZEDARR);
      7: (WordStr: _SHORT_SIZEDARR);
      8: (LongStr: _LONG_SIZEDARR);
      9: (HyperStr: _HYPER_SIZEDARR);
  end;

  _wireSAFEARRAY_UNION = record
    sfType: LongWord;
    u: __MIDL_IOleAutomationTypes_0001;
  end;

{$ALIGN 8}
  _wireVARIANT = record
    clSize: LongWord;
    rpcReserved: LongWord;
    vt: Word;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    DUMMYUNIONNAME: __MIDL_IOleAutomationTypes_0004;
  end;


{$ALIGN 4}
  tagTYPEATTR = record
    guid: TGUID;
    lcid: LongWord;
    dwReserved: LongWord;
    memidConstructor: Integer;
    memidDestructor: Integer;
    lpstrSchema: PWideChar;
    cbSizeInstance: LongWord;
    typekind: tagTYPEKIND;
    cFuncs: Word;
    cVars: Word;
    cImplTypes: Word;
    cbSizeVft: Word;
    cbAlignment: Word;
    wTypeFlags: Word;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    tdescAlias: tagTYPEDESC;
    idldescType: tagIDLDESC;
  end;

  tagARRAYDESC = record
    tdescElem: tagTYPEDESC;
    cDims: Word;
    rgbounds: ^tagSAFEARRAYBOUND;
  end;


  _wireSAFEARRAY = record
    cDims: Word;
    fFeatures: Word;
    cbElements: LongWord;
    cLocks: LongWord;
    uArrayStructs: _wireSAFEARRAY_UNION;
    rgsabound: ^tagSAFEARRAYBOUND;
  end;

  IPortableDeviceValues = interface;
  IPortableDeviceContent = interface;
  IPortableDeviceCapabilities = interface;
  IPortableDeviceKeyCollection = interface;

// *********************************************************************//
// Interface: IPortableDeviceManager
// Flags:     (0)
// GUID:      {A1567595-4C2F-4574-A6FA-ECEF917B9A40}
// *********************************************************************//
  IPortableDeviceManager = interface(IUnknown)
    ['{A1567595-4C2F-4574-A6FA-ECEF917B9A40}']
    function GetDevices(pPnPDeviceIDs: PLPWSTR; pcPnPDeviceIDs: PLongWord): HResult; stdcall;
    function RefreshDeviceList: HResult; stdcall;
    function GetDeviceFriendlyName(pszPnPDeviceID: PWideChar; pDeviceFriendlyName: PWCHAR;
                                   pcchDeviceFriendlyName: PDWORD): HResult; stdcall;
    function GetDeviceDescription(pszPnPDeviceID: PWideChar; pDeviceDescription: PWCHAR;
                                  pcchDeviceDescription: PDWORD): HResult; stdcall;
    function GetDeviceManufacturer(pszPnPDeviceID: PWideChar; var pDeviceManufacturer: Word;
                                   var pcchDeviceManufacturer: LongWord): HResult; stdcall;
    function GetDeviceProperty(pszPnPDeviceID: PWideChar; pszDevicePropertyName: PWideChar;
                               var pData: Byte; var pcbData: LongWord; var pdwType: LongWord): HResult; stdcall;
    function GetPrivateDevices(var pPnPDeviceIDs: PWideChar; var pcPnPDeviceIDs: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceProperties
// Flags:     (0)
// GUID:      {7F6D695C-03DF-4439-A809-59266BEEE3A6}
// *********************************************************************//
  IPortableDeviceProperties = interface(IUnknown)
    ['{7F6D695C-03DF-4439-A809-59266BEEE3A6}']
    function GetSupportedProperties(pszObjectID: PWideChar; out ppKeys: IPortableDeviceKeyCollection): HResult; stdcall;
    function GetPropertyAttributes(pszObjectID: PWideChar; var key: _tagpropertykey;
                                   out ppAttributes: IPortableDeviceValues): HResult; stdcall;
    function GetValues(pszObjectID: PWideChar; const pKeys: IPortableDeviceKeyCollection;
                       out ppValues: IPortableDeviceValues): HResult; stdcall;
    function SetValues(pszObjectID: PWideChar; const pValues: IPortableDeviceValues;
                       out ppResults: IPortableDeviceValues): HResult; stdcall;
    function Delete(pszObjectID: PWideChar; const pKeys: IPortableDeviceKeyCollection): HResult; stdcall;
    function Cancel: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceResources
// Flags:     (0)
// GUID:      {FD8878AC-D841-4D17-891C-E6829CDB6934}
// *********************************************************************//
  IPortableDeviceResources = interface(IUnknown)
    ['{FD8878AC-D841-4D17-891C-E6829CDB6934}']
    function GetSupportedResources(pszObjectID: PWideChar; out ppKeys: IPortableDeviceKeyCollection): HResult; stdcall;
    function GetResourceAttributes(pszObjectID: PWideChar; var key: _tagpropertykey;
                                   out ppResourceAttributes: IPortableDeviceValues): HResult; stdcall;
    function GetStream(pszObjectID: PWideChar; var key: _tagpropertykey; dwMode: LongWord;
                       var pdwOptimalBufferSize: LongWord; out ppStream: IStream): HResult; stdcall;
    function Delete(pszObjectID: PWideChar; const pKeys: IPortableDeviceKeyCollection): HResult; stdcall;
    function Cancel: HResult; stdcall;
    function CreateResource(const pResourceAttributes: IPortableDeviceValues; out ppData: IStream;
                            var pdwOptimalWriteBufferSize: LongWord; var ppszCookie: PWideChar): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumPortableDeviceObjectIDs
// Flags:     (0)
// GUID:      {10ECE955-CF41-4728-BFA0-41EEDF1BBF19}
// *********************************************************************//
  IEnumPortableDeviceObjectIDs = interface(IUnknown)
    ['{10ECE955-CF41-4728-BFA0-41EEDF1BBF19}']
    function Next(cObjects: LongWord; pObjIDs: Pointer; var pcFetched: LongWord): HResult; stdcall;
    function Skip(cObjects: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumPortableDeviceObjectIDs): HResult; stdcall;
    function Cancel: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPropertyStore
// Flags:     (0)
// GUID:      {886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}
// *********************************************************************//
  IPropertyStore = interface(IUnknown)
    ['{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}']
    function GetCount(out cProps: LongWord): HResult; stdcall;
    function GetAt(iProp: LongWord; out pKey: _tagpropertykey): HResult; stdcall;
    function GetValue(var key: _tagpropertykey; out pv: tag_inner_PROPVARIANT): HResult; stdcall;
    function SetValue(var key: _tagpropertykey; var propvar: tag_inner_PROPVARIANT): HResult; stdcall;
    function Commit: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceValuesCollection
// Flags:     (0)
// GUID:      {6E3F2D79-4E07-48C4-8208-D8C2E5AF4A99}
// *********************************************************************//
  IPortableDeviceValuesCollection = interface(IUnknown)
    ['{6E3F2D79-4E07-48C4-8208-D8C2E5AF4A99}']
    function GetCount(var pcElems: LongWord): HResult; stdcall;
    function GetAt(dwIndex: LongWord; out ppValues: IPortableDeviceValues): HResult; stdcall;
    function Add(const pValues: IPortableDeviceValues): HResult; stdcall;
    function Clear: HResult; stdcall;
    function RemoveAt(dwIndex: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceKeyCollection
// Flags:     (0)
// GUID:      {DADA2357-E0AD-492E-98DB-DD61C53BA353}
// *********************************************************************//
  IPortableDeviceKeyCollection = interface(IUnknown)
    ['{DADA2357-E0AD-492E-98DB-DD61C53BA353}']
    function GetCount(var pcElems: LongWord): HResult; stdcall;
    function GetAt(dwIndex: LongWord; var pKey: _tagpropertykey): HResult; stdcall;
    function Add(var key: _tagpropertykey): HResult; stdcall;
    function Clear: HResult; stdcall;
    function RemoveAt(dwIndex: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceEventCallback
// Flags:     (0)
// GUID:      {A8792A31-F385-493C-A893-40F64EB45F6E}
// *********************************************************************//
  IPortableDeviceEventCallback = interface(IUnknown)
    ['{A8792A31-F385-493C-A893-40F64EB45F6E}']
    function OnEvent(const pEventParameters: IPortableDeviceValues): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDevicePropVariantCollection
// Flags:     (0)
// GUID:      {89B2E422-4F1B-4316-BCEF-A44AFEA83EB3}
// *********************************************************************//
  IPortableDevicePropVariantCollection = interface(IUnknown)
    ['{89B2E422-4F1B-4316-BCEF-A44AFEA83EB3}']
    function GetCount(var pcElems: LongWord): HResult; stdcall;
    function GetAt(dwIndex: LongWord; var pValue: tag_inner_PROPVARIANT): HResult; stdcall;
    function Add(var pValue: tag_inner_PROPVARIANT): HResult; stdcall;
    function GetType(out pvt: Word): HResult; stdcall;
    function ChangeType(vt: Word): HResult; stdcall;
    function Clear: HResult; stdcall;
    function RemoveAt(dwIndex: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDevice
// Flags:     (0)
// GUID:      {625E2DF8-6392-4CF0-9AD1-3CFA5F17775C}
// *********************************************************************//
  IPortableDevice = interface(IUnknown)
    ['{625E2DF8-6392-4CF0-9AD1-3CFA5F17775C}']
    function Open(pszPnPDeviceID: PWideChar; const pClientInfo: IPortableDeviceValues): HResult; stdcall;
    function SendCommand(dwFlags: LongWord; const pParameters: IPortableDeviceValues;
                         out ppResults: IPortableDeviceValues): HResult; stdcall;
    function Content(out ppContent: IPortableDeviceContent): HResult; stdcall;
    function Capabilities(out ppCapabilities: IPortableDeviceCapabilities): HResult; stdcall;
    function Cancel: HResult; stdcall;
    function Close: HResult; stdcall;
    function Advise(const dwFlags: LongWord; pCallback: IPortableDeviceEventCallback;
                    pParameters: IPortableDeviceValues; out ppszCookie: PWideChar): HResult; stdcall;
    function Unadvise(pszCookie: PWideChar): HResult; stdcall;
    function GetPnPDeviceID(out ppszPnPDeviceID: PWideChar): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceValues
// Flags:     (0)
// GUID:      {6848F6F2-3155-4F86-B6F5-263EEEAB3143}
// *********************************************************************//
  IPortableDeviceValues = interface(IUnknown)
    ['{6848F6F2-3155-4F86-B6F5-263EEEAB3143}']
    function GetCount(var pcelt: LongWord): HResult; stdcall;
    function GetAt(index: LongWord; var pKey: _tagpropertykey; var pValue: tag_inner_PROPVARIANT): HResult; stdcall;
    function SetValue(var key: _tagpropertykey; var pValue: tag_inner_PROPVARIANT): HResult; stdcall;
    function GetValue(var key: _tagpropertykey; out pValue: tag_inner_PROPVARIANT): HResult; stdcall;
    function SetStringValue(var key: _tagpropertykey; Value: PWideChar): HResult; stdcall;
    function GetStringValue(var key: _tagpropertykey; out pValue: PWideChar): HResult; stdcall;
    function SetUnsignedIntegerValue(var key: _tagpropertykey; Value: LongWord): HResult; stdcall;
    function GetUnsignedIntegerValue(var key: _tagpropertykey; out pValue: LongWord): HResult; stdcall;
    function SetSignedIntegerValue(var key: _tagpropertykey; Value: Integer): HResult; stdcall;
    function GetSignedIntegerValue(var key: _tagpropertykey; out pValue: Integer): HResult; stdcall;
    function SetUnsignedLargeIntegerValue(var key: _tagpropertykey; Value: Largeuint): HResult; stdcall;
    function GetUnsignedLargeIntegerValue(var key: _tagpropertykey; out pValue: Largeuint): HResult; stdcall;
    function SetSignedLargeIntegerValue(var key: _tagpropertykey; Value: Int64): HResult; stdcall;
    function GetSignedLargeIntegerValue(var key: _tagpropertykey; out pValue: Int64): HResult; stdcall;
    function SetFloatValue(var key: _tagpropertykey; Value: Single): HResult; stdcall;
    function GetFloatValue(var key: _tagpropertykey; out pValue: Single): HResult; stdcall;
    function SetErrorValue(var key: _tagpropertykey; Value: HResult): HResult; stdcall;
    function GetErrorValue(var key: _tagpropertykey; out pValue: HResult): HResult; stdcall;
    function SetKeyValue(var key: _tagpropertykey; var Value: _tagpropertykey): HResult; stdcall;
    function GetKeyValue(var key: _tagpropertykey; out pValue: _tagpropertykey): HResult; stdcall;
    function SetBoolValue(var key: _tagpropertykey; Value: Integer): HResult; stdcall;
    function GetBoolValue(var key: _tagpropertykey; out pValue: Integer): HResult; stdcall;
    function SetIUnknownValue(var key: _tagpropertykey; const pValue: IUnknown): HResult; stdcall;
    function GetIUnknownValue(var key: _tagpropertykey; out ppValue: IUnknown): HResult; stdcall;
    function SetGuidValue(var key: _tagpropertykey; var Value: TGUID): HResult; stdcall;
    function GetGuidValue(var key: _tagpropertykey; out pValue: TGUID): HResult; stdcall;
    function SetBufferValue(var key: _tagpropertykey; var pValue: Byte; cbValue: LongWord): HResult; stdcall;
    function GetBufferValue(var key: _tagpropertykey; out ppValue: PByte1; out pcbValue: LongWord): HResult; stdcall;
    function SetIPortableDeviceValuesValue(var key: _tagpropertykey;
                                           const pValue: IPortableDeviceValues): HResult; stdcall;
    function GetIPortableDeviceValuesValue(var key: _tagpropertykey;
                                           out ppValue: IPortableDeviceValues): HResult; stdcall;
    function SetIPortableDevicePropVariantCollectionValue(var key: _tagpropertykey;
                                                          const pValue: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetIPortableDevicePropVariantCollectionValue(var key: _tagpropertykey;
                                                          out ppValue: IPortableDevicePropVariantCollection): HResult; stdcall;
    function SetIPortableDeviceKeyCollectionValue(var key: _tagpropertykey;
                                                  const pValue: IPortableDeviceKeyCollection): HResult; stdcall;
    function GetIPortableDeviceKeyCollectionValue(var key: _tagpropertykey;
                                                  out ppValue: IPortableDeviceKeyCollection): HResult; stdcall;
    function SetIPortableDeviceValuesCollectionValue(var key: _tagpropertykey;
                                                     const pValue: IPortableDeviceValuesCollection): HResult; stdcall;
    function GetIPortableDeviceValuesCollectionValue(var key: _tagpropertykey;
                                                     out ppValue: IPortableDeviceValuesCollection): HResult; stdcall;
    function RemoveValue(var key: _tagpropertykey): HResult; stdcall;
    function CopyValuesFromPropertyStore(const pStore: IPropertyStore): HResult; stdcall;
    function CopyValuesToPropertyStore(const pStore: IPropertyStore): HResult; stdcall;
    function Clear: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceContent
// Flags:     (0)
// GUID:      {6A96ED84-7C73-4480-9938-BF5AF477D426}
// *********************************************************************//
  IPortableDeviceContent = interface(IUnknown)
    ['{6A96ED84-7C73-4480-9938-BF5AF477D426}']
    function EnumObjects(dwFlags: LongWord; pszParentObjectID: PWideChar;
                         const pFilter: IPortableDeviceValues;
                         out ppenum: IEnumPortableDeviceObjectIDs): HResult; stdcall;
    function Properties(out ppProperties: IPortableDeviceProperties): HResult; stdcall;
    function Transfer(out ppResources: IPortableDeviceResources): HResult; stdcall;
    function CreateObjectWithPropertiesOnly(const pValues: IPortableDeviceValues;
                                            var ppszObjectID: PWideChar): HResult; stdcall;
    function CreateObjectWithPropertiesAndData(const pValues: IPortableDeviceValues;
                                               out ppData: IStream;
                                               var pdwOptimalWriteBufferSize: LongWord;
                                               var ppszCookie: PWideChar): HResult; stdcall;
    function Delete(dwOptions: LongWord; const pObjectIDs: IPortableDevicePropVariantCollection;
                    var ppResults: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetObjectIDsFromPersistentUniqueIDs(const pPersistentUniqueIDs: IPortableDevicePropVariantCollection;
                                                 out ppObjectIDs: IPortableDevicePropVariantCollection): HResult; stdcall;
    function Cancel: HResult; stdcall;
    function Move(const pObjectIDs: IPortableDevicePropVariantCollection;
                  pszDestinationFolderObjectID: PWideChar;
                  var ppResults: IPortableDevicePropVariantCollection): HResult; stdcall;
    function Copy(const pObjectIDs: IPortableDevicePropVariantCollection;
                  pszDestinationFolderObjectID: PWideChar;
                  var ppResults: IPortableDevicePropVariantCollection): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPortableDeviceCapabilities
// Flags:     (0)
// GUID:      {2C8C6DBF-E3DC-4061-BECC-8542E810D126}
// *********************************************************************//
  IPortableDeviceCapabilities = interface(IUnknown)
    ['{2C8C6DBF-E3DC-4061-BECC-8542E810D126}']
    function GetSupportedCommands(out ppCommands: IPortableDeviceKeyCollection): HResult; stdcall;
    function GetCommandOptions(var Command: _tagpropertykey; out ppOptions: IPortableDeviceValues): HResult; stdcall;
    function GetFunctionalCategories(out ppCategories: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetFunctionalObjects(var Category: TGUID;
                                  out ppObjectIDs: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetSupportedContentTypes(var Category: TGUID;
                                      out ppContentTypes: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetSupportedFormats(var ContentType: TGUID;
                                 out ppFormats: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetSupportedFormatProperties(var Format: TGUID;
                                          out ppKeys: IPortableDeviceKeyCollection): HResult; stdcall;
    function GetFixedPropertyAttributes(var Format: TGUID; var key: _tagpropertykey;
                                        out ppAttributes: IPortableDeviceValues): HResult; stdcall;
    function Cancel: HResult; stdcall;
    function GetSupportedEvents(out ppEvents: IPortableDevicePropVariantCollection): HResult; stdcall;
    function GetEventOptions(var Event: TGUID; out ppOptions: IPortableDeviceValues): HResult; stdcall;
  end;


implementation

end.
