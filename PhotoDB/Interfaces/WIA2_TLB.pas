unit WIA2_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 17244 $
// File generated on 02.11.2011 23:30:01 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Windows\System32\wiaaut.dll (1)
// LIBID: {94A0E92D-43C0-494E-AC29-FD45948A5221}
// LCID: 0
// Helpfile: C:\Windows\System32\wiaaut.chm
// HelpString: Microsoft Windows Image Acquisition Library v2.0
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
// Errors:
//   Hint: TypeInfo 'Property' changed to 'Property_'
//   Hint: Member 'String' of 'IVector' changed to 'String_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Symbol 'Type' renamed to 'type_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WIAMajorVersion = 1;
  WIAMinorVersion = 0;

  LIBID_WIA: TGUID = '{94A0E92D-43C0-494E-AC29-FD45948A5221}';

  IID_IRational: TGUID = '{3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}';
  CLASS_Rational: TGUID = '{0C5672F9-3EDC-4B24-95B5-A6C54C0B79AD}';
  IID_IImageFile: TGUID = '{F4243B65-3F63-4D99-93CD-86B6D62C5EB2}';
  IID_IVector: TGUID = '{696F2367-6619-49BD-BA96-904DC2609990}';
  IID_IProperties: TGUID = '{40571E58-A308-470A-80AA-FA10F88793A0}';
  IID_IProperty: TGUID = '{706038DC-9F4B-4E45-88E2-5EB7D665B815}';
  CLASS_Vector: TGUID = '{4DD1D1C3-B36A-4EB4-AAEF-815891A58A30}';
  CLASS_Property_: TGUID = '{2014DE3F-3723-4178-8643-3317A32D4A2B}';
  CLASS_Properties: TGUID = '{96F887FC-08B1-4F97-A69C-75280C6A9CF8}';
  CLASS_ImageFile: TGUID = '{A2E6DDA0-06EF-4DF3-B7BD-5AA224BB06E8}';
  IID_IFilterInfo: TGUID = '{EFD1219F-8229-4B30-809D-8F6D83341569}';
  CLASS_FilterInfo: TGUID = '{318D6B52-9B1C-4E3B-8D90-1F0E857FA9B0}';
  IID_IFilterInfos: TGUID = '{AF49723A-499C-411C-B19A-1B8244D67E44}';
  CLASS_FilterInfos: TGUID = '{56FA88D3-F3DA-4DE3-94E8-811040C3CCD4}';
  IID_IFilter: TGUID = '{851E9802-B338-4AB3-BB6B-6AA57CC699D0}';
  CLASS_Filter: TGUID = '{52AD8A74-F064-4F4C-8544-FF494D349F7B}';
  IID_IFilters: TGUID = '{C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}';
  CLASS_Filters: TGUID = '{31CDD60C-C04C-424D-95FC-36A52646D71C}';
  IID_IImageProcess: TGUID = '{41506929-7855-4392-9E6F-98D88513E55D}';
  CLASS_ImageProcess: TGUID = '{BD0D38E4-74C8-4904-9B5A-269F8E9994E9}';
  IID_IFormats: TGUID = '{882A274F-DF2F-4F6D-9F5A-AF4FD484530D}';
  CLASS_Formats: TGUID = '{6F62E261-0FE6-476B-A244-50CF7440DDEB}';
  IID_IDeviceCommand: TGUID = '{7CF694C0-F589-451C-B56E-398B5855B05E}';
  CLASS_DeviceCommand: TGUID = '{72226184-AFBB-4059-BF55-0F6C076E669D}';
  IID_IDeviceCommands: TGUID = '{C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}';
  CLASS_DeviceCommands: TGUID = '{25B047DB-4AAD-4FC2-A0BE-31DDA687FF32}';
  IID_IItems: TGUID = '{46102071-60B4-4E58-8620-397D17B0BB5B}';
  IID_IItem: TGUID = '{68F2BF12-A755-4E2B-9BCD-37A22587D078}';
  CLASS_Item: TGUID = '{36F479F3-C258-426E-B5FA-2793DCFDA881}';
  CLASS_Items: TGUID = '{B243B765-CA9C-4F30-A457-C8B2B57A585E}';
  IID_IDeviceEvent: TGUID = '{80D0880A-BB10-4722-82D1-07DC8DA157E2}';
  CLASS_DeviceEvent: TGUID = '{617CF892-783C-43D3-B04B-F0F1DE3B326D}';
  IID_IDeviceEvents: TGUID = '{03985C95-581B-44D1-9403-8488B347538B}';
  CLASS_DeviceEvents: TGUID = '{3563A59A-BBCD-4C86-94A0-92136C80A8B4}';
  IID_IDevice: TGUID = '{3714EAC4-F413-426B-B1E8-DEF2BE99EA55}';
  IID_IDeviceInfo: TGUID = '{2A99020A-E325-4454-95E0-136726ED4818}';
  CLASS_DeviceInfo: TGUID = '{F09CFB7A-E561-4625-9BB5-208BCA0DE09F}';
  IID_IDeviceInfos: TGUID = '{FE076B64-8406-4E92-9CAC-9093F378E05F}';
  CLASS_DeviceInfos: TGUID = '{2DFEE16B-E4AC-4A19-B660-AE71A745D34F}';
  CLASS_Device: TGUID = '{DBAA8843-B1C4-4EDC-B7E0-D6F61162BE58}';
  IID_ICommonDialog: TGUID = '{B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}';
  CLASS_CommonDialog: TGUID = '{850D1D11-70F3-4BE5-9A11-77AA6B2BB201}';
  IID_IDeviceManager: TGUID = '{73856D9A-2720-487A-A584-21D5774E9D0F}';
  DIID__IDeviceManagerEvents: TGUID = '{2E9A5206-2360-49DF-9D9B-1762B4BEAE77}';
  CLASS_DeviceManager: TGUID = '{E1C5D730-7E97-4D8A-9E42-BBAE87C2059F}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum WiaSubType
type
  WiaSubType = TOleEnum;
const
  UnspecifiedSubType = $00000000;
  RangeSubType = $00000001;
  ListSubType = $00000002;
  FlagSubType = $00000003;

// Constants for enum WiaDeviceType
type
  WiaDeviceType = TOleEnum;
const
  UnspecifiedDeviceType = $00000000;
  ScannerDeviceType = $00000001;
  CameraDeviceType = $00000002;
  VideoDeviceType = $00000003;

// Constants for enum WiaItemFlag
type
  WiaItemFlag = TOleEnum;
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

// Constants for enum WiaPropertyType
type
  WiaPropertyType = TOleEnum;
const
  UnsupportedPropertyType = $00000000;
  BooleanPropertyType = $00000001;
  BytePropertyType = $00000002;
  IntegerPropertyType = $00000003;
  UnsignedIntegerPropertyType = $00000004;
  LongPropertyType = $00000005;
  UnsignedLongPropertyType = $00000006;
  ErrorCodePropertyType = $00000007;
  LargeIntegerPropertyType = $00000008;
  UnsignedLargeIntegerPropertyType = $00000009;
  SinglePropertyType = $0000000A;
  DoublePropertyType = $0000000B;
  CurrencyPropertyType = $0000000C;
  DatePropertyType = $0000000D;
  FileTimePropertyType = $0000000E;
  ClassIDPropertyType = $0000000F;
  StringPropertyType = $00000010;
  ObjectPropertyType = $00000011;
  HandlePropertyType = $00000012;
  VariantPropertyType = $00000013;
  VectorOfBooleansPropertyType = $00000065;
  VectorOfBytesPropertyType = $00000066;
  VectorOfIntegersPropertyType = $00000067;
  VectorOfUnsignedIntegersPropertyType = $00000068;
  VectorOfLongsPropertyType = $00000069;
  VectorOfUnsignedLongsPropertyType = $0000006A;
  VectorOfErrorCodesPropertyType = $0000006B;
  VectorOfLargeIntegersPropertyType = $0000006C;
  VectorOfUnsignedLargeIntegersPropertyType = $0000006D;
  VectorOfSinglesPropertyType = $0000006E;
  VectorOfDoublesPropertyType = $0000006F;
  VectorOfCurrenciesPropertyType = $00000070;
  VectorOfDatesPropertyType = $00000071;
  VectorOfFileTimesPropertyType = $00000072;
  VectorOfClassIDsPropertyType = $00000073;
  VectorOfStringsPropertyType = $00000074;
  VectorOfVariantsPropertyType = $00000077;

// Constants for enum WiaImagePropertyType
type
  WiaImagePropertyType = TOleEnum;
const
  UndefinedImagePropertyType = $000003E8;
  ByteImagePropertyType = $000003E9;
  StringImagePropertyType = $000003EA;
  UnsignedIntegerImagePropertyType = $000003EB;
  LongImagePropertyType = $000003EC;
  UnsignedLongImagePropertyType = $000003ED;
  RationalImagePropertyType = $000003EE;
  UnsignedRationalImagePropertyType = $000003EF;
  VectorOfUndefinedImagePropertyType = $0000044C;
  VectorOfBytesImagePropertyType = $0000044D;
  VectorOfUnsignedIntegersImagePropertyType = $0000044E;
  VectorOfLongsImagePropertyType = $0000044F;
  VectorOfUnsignedLongsImagePropertyType = $00000450;
  VectorOfRationalsImagePropertyType = $00000451;
  VectorOfUnsignedRationalsImagePropertyType = $00000452;

// Constants for enum WiaEventFlag
type
  WiaEventFlag = TOleEnum;
const
  NotificationEvent = $00000001;
  ActionEvent = $00000002;

// Constants for enum WiaImageIntent
type
  WiaImageIntent = TOleEnum;
const
  UnspecifiedIntent = $00000000;
  ColorIntent = $00000001;
  GrayscaleIntent = $00000002;
  TextIntent = $00000004;

// Constants for enum WiaImageBias
type
  WiaImageBias = TOleEnum;
const
  MinimizeSize = $00010000;
  MaximizeQuality = $00020000;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IRational = interface;
  IRationalDisp = dispinterface;
  IImageFile = interface;
  IImageFileDisp = dispinterface;
  IVector = interface;
  IVectorDisp = dispinterface;
  IProperties = interface;
  IPropertiesDisp = dispinterface;
  IProperty = interface;
  IPropertyDisp = dispinterface;
  IFilterInfo = interface;
  IFilterInfoDisp = dispinterface;
  IFilterInfos = interface;
  IFilterInfosDisp = dispinterface;
  IFilter = interface;
  IFilterDisp = dispinterface;
  IFilters = interface;
  IFiltersDisp = dispinterface;
  IImageProcess = interface;
  IImageProcessDisp = dispinterface;
  IFormats = interface;
  IFormatsDisp = dispinterface;
  IDeviceCommand = interface;
  IDeviceCommandDisp = dispinterface;
  IDeviceCommands = interface;
  IDeviceCommandsDisp = dispinterface;
  IItems = interface;
  IItemsDisp = dispinterface;
  IItem = interface;
  IItemDisp = dispinterface;
  IDeviceEvent = interface;
  IDeviceEventDisp = dispinterface;
  IDeviceEvents = interface;
  IDeviceEventsDisp = dispinterface;
  IDevice = interface;
  IDeviceDisp = dispinterface;
  IDeviceInfo = interface;
  IDeviceInfoDisp = dispinterface;
  IDeviceInfos = interface;
  IDeviceInfosDisp = dispinterface;
  ICommonDialog = interface;
  ICommonDialogDisp = dispinterface;
  IDeviceManager = interface;
  IDeviceManagerDisp = dispinterface;
  _IDeviceManagerEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Rational = IRational;
  Vector = IVector;
  Property_ = IProperty;
  Properties = IProperties;
  ImageFile = IImageFile;
  FilterInfo = IFilterInfo;
  FilterInfos = IFilterInfos;
  Filter = IFilter;
  Filters = IFilters;
  ImageProcess = IImageProcess;
  Formats = IFormats;
  DeviceCommand = IDeviceCommand;
  DeviceCommands = IDeviceCommands;
  Item = IItem;
  Items = IItems;
  DeviceEvent = IDeviceEvent;
  DeviceEvents = IDeviceEvents;
  DeviceInfo = IDeviceInfo;
  DeviceInfos = IDeviceInfos;
  Device = IDevice;
  CommonDialog = ICommonDialog;
  DeviceManager = IDeviceManager;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}


// *********************************************************************//
// Interface: IRational
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}
// *********************************************************************//
  IRational = interface(IDispatch)
    ['{3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}']
    function Get_Value: Double; safecall;
    function Get_Numerator: Integer; safecall;
    procedure Set_Numerator(plResult: Integer); safecall;
    function Get_Denominator: Integer; safecall;
    procedure Set_Denominator(plResult: Integer); safecall;
    property Value: Double read Get_Value;
    property Numerator: Integer read Get_Numerator write Set_Numerator;
    property Denominator: Integer read Get_Denominator write Set_Denominator;
  end;

// *********************************************************************//
// DispIntf:  IRationalDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}
// *********************************************************************//
  IRationalDisp = dispinterface
    ['{3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}']
    property Value: Double readonly dispid 0;
    property Numerator: Integer dispid 1;
    property Denominator: Integer dispid 2;
  end;

// *********************************************************************//
// Interface: IImageFile
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F4243B65-3F63-4D99-93CD-86B6D62C5EB2}
// *********************************************************************//
  IImageFile = interface(IDispatch)
    ['{F4243B65-3F63-4D99-93CD-86B6D62C5EB2}']
    function Get_FormatID: WideString; safecall;
    function Get_FileExtension: WideString; safecall;
    function Get_FileData: IVector; safecall;
    function Get_ARGBData: IVector; safecall;
    function Get_Height: Integer; safecall;
    function Get_Width: Integer; safecall;
    function Get_HorizontalResolution: Double; safecall;
    function Get_VerticalResolution: Double; safecall;
    function Get_PixelDepth: Integer; safecall;
    function Get_IsIndexedPixelFormat: WordBool; safecall;
    function Get_IsAlphaPixelFormat: WordBool; safecall;
    function Get_IsExtendedPixelFormat: WordBool; safecall;
    function Get_IsAnimated: WordBool; safecall;
    function Get_FrameCount: Integer; safecall;
    function Get_ActiveFrame: Integer; safecall;
    procedure Set_ActiveFrame(plResult: Integer); safecall;
    function Get_Properties: IProperties; safecall;
    procedure LoadFile(const Filename: WideString); safecall;
    procedure SaveFile(const Filename: WideString); safecall;
    property FormatID: WideString read Get_FormatID;
    property FileExtension: WideString read Get_FileExtension;
    property FileData: IVector read Get_FileData;
    property ARGBData: IVector read Get_ARGBData;
    property Height: Integer read Get_Height;
    property Width: Integer read Get_Width;
    property HorizontalResolution: Double read Get_HorizontalResolution;
    property VerticalResolution: Double read Get_VerticalResolution;
    property PixelDepth: Integer read Get_PixelDepth;
    property IsIndexedPixelFormat: WordBool read Get_IsIndexedPixelFormat;
    property IsAlphaPixelFormat: WordBool read Get_IsAlphaPixelFormat;
    property IsExtendedPixelFormat: WordBool read Get_IsExtendedPixelFormat;
    property IsAnimated: WordBool read Get_IsAnimated;
    property FrameCount: Integer read Get_FrameCount;
    property ActiveFrame: Integer read Get_ActiveFrame write Set_ActiveFrame;
    property Properties: IProperties read Get_Properties;
  end;

// *********************************************************************//
// DispIntf:  IImageFileDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F4243B65-3F63-4D99-93CD-86B6D62C5EB2}
// *********************************************************************//
  IImageFileDisp = dispinterface
    ['{F4243B65-3F63-4D99-93CD-86B6D62C5EB2}']
    property FormatID: WideString readonly dispid 1;
    property FileExtension: WideString readonly dispid 2;
    property FileData: IVector readonly dispid 3;
    property ARGBData: IVector readonly dispid 4;
    property Height: Integer readonly dispid 5;
    property Width: Integer readonly dispid 6;
    property HorizontalResolution: Double readonly dispid 7;
    property VerticalResolution: Double readonly dispid 8;
    property PixelDepth: Integer readonly dispid 9;
    property IsIndexedPixelFormat: WordBool readonly dispid 10;
    property IsAlphaPixelFormat: WordBool readonly dispid 11;
    property IsExtendedPixelFormat: WordBool readonly dispid 12;
    property IsAnimated: WordBool readonly dispid 13;
    property FrameCount: Integer readonly dispid 14;
    property ActiveFrame: Integer dispid 15;
    property Properties: IProperties readonly dispid 16;
    procedure LoadFile(const Filename: WideString); dispid 17;
    procedure SaveFile(const Filename: WideString); dispid 18;
  end;

// *********************************************************************//
// Interface: IVector
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {696F2367-6619-49BD-BA96-904DC2609990}
// *********************************************************************//
  IVector = interface(IDispatch)
    ['{696F2367-6619-49BD-BA96-904DC2609990}']
    function Get_Item(Index: Integer): OleVariant; safecall;
    procedure Set_Item(Index: Integer; var pResult: OleVariant); safecall;
    procedure _Set_Item(Index: Integer; var pResult: OleVariant); safecall;
    function Get_Count: Integer; safecall;
    function Get_Picture(Width: Integer; Height: Integer): OleVariant; safecall;
    function Get_ImageFile(Width: Integer; Height: Integer): IImageFile; safecall;
    function Get_BinaryData: OleVariant; safecall;
    procedure Set_BinaryData(var pvResult: OleVariant); safecall;
    function Get_String_(Unicode: WordBool): WideString; safecall;
    function Get_Date: TDateTime; safecall;
    procedure Set_Date(pdResult: TDateTime); safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Add(var Value: OleVariant; Index: Integer); safecall;
    function Remove(Index: Integer): OleVariant; safecall;
    procedure Clear; safecall;
    procedure SetFromString(const Value: WideString; Resizable: WordBool; Unicode: WordBool); safecall;
    property Count: Integer read Get_Count;
    property Picture[Width: Integer; Height: Integer]: OleVariant read Get_Picture;
    property ImageFile[Width: Integer; Height: Integer]: IImageFile read Get_ImageFile;
    property String_[Unicode: WordBool]: WideString read Get_String_;
    property Date: TDateTime read Get_Date write Set_Date;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IVectorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {696F2367-6619-49BD-BA96-904DC2609990}
// *********************************************************************//
  IVectorDisp = dispinterface
    ['{696F2367-6619-49BD-BA96-904DC2609990}']
    function Item(Index: Integer): OleVariant; dispid 0;
    property Count: Integer readonly dispid 1;
    property Picture[Width: Integer; Height: Integer]: OleVariant readonly dispid 2;
    property ImageFile[Width: Integer; Height: Integer]: IImageFile readonly dispid 3;
    function BinaryData: OleVariant; dispid 4;
    property String_[Unicode: WordBool]: WideString readonly dispid 5;
    property Date: TDateTime dispid 6;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Add(var Value: OleVariant; Index: Integer); dispid 7;
    function Remove(Index: Integer): OleVariant; dispid 8;
    procedure Clear; dispid 9;
    procedure SetFromString(const Value: WideString; Resizable: WordBool; Unicode: WordBool); dispid 10;
  end;

// *********************************************************************//
// Interface: IProperties
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {40571E58-A308-470A-80AA-FA10F88793A0}
// *********************************************************************//
  IProperties = interface(IDispatch)
    ['{40571E58-A308-470A-80AA-FA10F88793A0}']
    function Get_Item(var Index: OleVariant): IProperty; safecall;
    function Get_Count: Integer; safecall;
    function Exists(var Index: OleVariant): WordBool; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[var Index: OleVariant]: IProperty read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IPropertiesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {40571E58-A308-470A-80AA-FA10F88793A0}
// *********************************************************************//
  IPropertiesDisp = dispinterface
    ['{40571E58-A308-470A-80AA-FA10F88793A0}']
    property Item[var Index: OleVariant]: IProperty readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    function Exists(var Index: OleVariant): WordBool; dispid 2;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IProperty
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {706038DC-9F4B-4E45-88E2-5EB7D665B815}
// *********************************************************************//
  IProperty = interface(IDispatch)
    ['{706038DC-9F4B-4E45-88E2-5EB7D665B815}']
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(var pvResult: OleVariant); safecall;
    procedure _Set_Value(var pvResult: OleVariant); safecall;
    function Get_Name: WideString; safecall;
    function Get_PropertyID: Integer; safecall;
    function Get_type_: Integer; safecall;
    function Get_IsReadOnly: WordBool; safecall;
    function Get_IsVector: WordBool; safecall;
    function Get_SubType: WiaSubType; safecall;
    function Get_SubTypeDefault: OleVariant; safecall;
    function Get_SubTypeValues: IVector; safecall;
    function Get_SubTypeMin: Integer; safecall;
    function Get_SubTypeMax: Integer; safecall;
    function Get_SubTypeStep: Integer; safecall;
    property Name: WideString read Get_Name;
    property PropertyID: Integer read Get_PropertyID;
    property type_: Integer read Get_type_;
    property IsReadOnly: WordBool read Get_IsReadOnly;
    property IsVector: WordBool read Get_IsVector;
    property SubType: WiaSubType read Get_SubType;
    property SubTypeDefault: OleVariant read Get_SubTypeDefault;
    property SubTypeValues: IVector read Get_SubTypeValues;
    property SubTypeMin: Integer read Get_SubTypeMin;
    property SubTypeMax: Integer read Get_SubTypeMax;
    property SubTypeStep: Integer read Get_SubTypeStep;
  end;

// *********************************************************************//
// DispIntf:  IPropertyDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {706038DC-9F4B-4E45-88E2-5EB7D665B815}
// *********************************************************************//
  IPropertyDisp = dispinterface
    ['{706038DC-9F4B-4E45-88E2-5EB7D665B815}']
    function Value: OleVariant; dispid 0;
    property Name: WideString readonly dispid 1;
    property PropertyID: Integer readonly dispid 2;
    property type_: Integer readonly dispid 3;
    property IsReadOnly: WordBool readonly dispid 4;
    property IsVector: WordBool readonly dispid 5;
    property SubType: WiaSubType readonly dispid 6;
    property SubTypeDefault: OleVariant readonly dispid 7;
    property SubTypeValues: IVector readonly dispid 8;
    property SubTypeMin: Integer readonly dispid 9;
    property SubTypeMax: Integer readonly dispid 10;
    property SubTypeStep: Integer readonly dispid 11;
  end;

// *********************************************************************//
// Interface: IFilterInfo
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EFD1219F-8229-4B30-809D-8F6D83341569}
// *********************************************************************//
  IFilterInfo = interface(IDispatch)
    ['{EFD1219F-8229-4B30-809D-8F6D83341569}']
    function Get_Name: WideString; safecall;
    function Get_Description: WideString; safecall;
    function Get_FilterID: WideString; safecall;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
    property FilterID: WideString read Get_FilterID;
  end;

// *********************************************************************//
// DispIntf:  IFilterInfoDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EFD1219F-8229-4B30-809D-8F6D83341569}
// *********************************************************************//
  IFilterInfoDisp = dispinterface
    ['{EFD1219F-8229-4B30-809D-8F6D83341569}']
    property Name: WideString readonly dispid 1;
    property Description: WideString readonly dispid 2;
    property FilterID: WideString readonly dispid 3;
  end;

// *********************************************************************//
// Interface: IFilterInfos
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AF49723A-499C-411C-B19A-1B8244D67E44}
// *********************************************************************//
  IFilterInfos = interface(IDispatch)
    ['{AF49723A-499C-411C-B19A-1B8244D67E44}']
    function Get_Item(var Index: OleVariant): IFilterInfo; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[var Index: OleVariant]: IFilterInfo read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IFilterInfosDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {AF49723A-499C-411C-B19A-1B8244D67E44}
// *********************************************************************//
  IFilterInfosDisp = dispinterface
    ['{AF49723A-499C-411C-B19A-1B8244D67E44}']
    property Item[var Index: OleVariant]: IFilterInfo readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IFilter
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {851E9802-B338-4AB3-BB6B-6AA57CC699D0}
// *********************************************************************//
  IFilter = interface(IDispatch)
    ['{851E9802-B338-4AB3-BB6B-6AA57CC699D0}']
    function Get_Name: WideString; safecall;
    function Get_Description: WideString; safecall;
    function Get_FilterID: WideString; safecall;
    function Get_Properties: IProperties; safecall;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
    property FilterID: WideString read Get_FilterID;
    property Properties: IProperties read Get_Properties;
  end;

// *********************************************************************//
// DispIntf:  IFilterDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {851E9802-B338-4AB3-BB6B-6AA57CC699D0}
// *********************************************************************//
  IFilterDisp = dispinterface
    ['{851E9802-B338-4AB3-BB6B-6AA57CC699D0}']
    property Name: WideString readonly dispid 1;
    property Description: WideString readonly dispid 2;
    property FilterID: WideString readonly dispid 3;
    property Properties: IProperties readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IFilters
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}
// *********************************************************************//
  IFilters = interface(IDispatch)
    ['{C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}']
    function Get_Item(Index: Integer): IFilter; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Add(const FilterID: WideString; Index: Integer); safecall;
    procedure Remove(Index: Integer); safecall;
    property Item[Index: Integer]: IFilter read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IFiltersDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}
// *********************************************************************//
  IFiltersDisp = dispinterface
    ['{C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}']
    property Item[Index: Integer]: IFilter readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Add(const FilterID: WideString; Index: Integer); dispid 2;
    procedure Remove(Index: Integer); dispid 3;
  end;

// *********************************************************************//
// Interface: IImageProcess
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {41506929-7855-4392-9E6F-98D88513E55D}
// *********************************************************************//
  IImageProcess = interface(IDispatch)
    ['{41506929-7855-4392-9E6F-98D88513E55D}']
    function Get_FilterInfos: IFilterInfos; safecall;
    function Get_Filters: IFilters; safecall;
    function Apply(const Source: IImageFile): IImageFile; safecall;
    property FilterInfos: IFilterInfos read Get_FilterInfos;
    property Filters: IFilters read Get_Filters;
  end;

// *********************************************************************//
// DispIntf:  IImageProcessDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {41506929-7855-4392-9E6F-98D88513E55D}
// *********************************************************************//
  IImageProcessDisp = dispinterface
    ['{41506929-7855-4392-9E6F-98D88513E55D}']
    property FilterInfos: IFilterInfos readonly dispid 1;
    property Filters: IFilters readonly dispid 2;
    function Apply(const Source: IImageFile): IImageFile; dispid 4;
  end;

// *********************************************************************//
// Interface: IFormats
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {882A274F-DF2F-4F6D-9F5A-AF4FD484530D}
// *********************************************************************//
  IFormats = interface(IDispatch)
    ['{882A274F-DF2F-4F6D-9F5A-AF4FD484530D}']
    function Get_Item(Index: Integer): WideString; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: Integer]: WideString read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IFormatsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {882A274F-DF2F-4F6D-9F5A-AF4FD484530D}
// *********************************************************************//
  IFormatsDisp = dispinterface
    ['{882A274F-DF2F-4F6D-9F5A-AF4FD484530D}']
    property Item[Index: Integer]: WideString readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IDeviceCommand
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7CF694C0-F589-451C-B56E-398B5855B05E}
// *********************************************************************//
  IDeviceCommand = interface(IDispatch)
    ['{7CF694C0-F589-451C-B56E-398B5855B05E}']
    function Get_CommandID: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_Description: WideString; safecall;
    property CommandID: WideString read Get_CommandID;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
  end;

// *********************************************************************//
// DispIntf:  IDeviceCommandDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7CF694C0-F589-451C-B56E-398B5855B05E}
// *********************************************************************//
  IDeviceCommandDisp = dispinterface
    ['{7CF694C0-F589-451C-B56E-398B5855B05E}']
    property CommandID: WideString readonly dispid 1;
    property Name: WideString readonly dispid 2;
    property Description: WideString readonly dispid 3;
  end;

// *********************************************************************//
// Interface: IDeviceCommands
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}
// *********************************************************************//
  IDeviceCommands = interface(IDispatch)
    ['{C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}']
    function Get_Item(Index: Integer): IDeviceCommand; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: Integer]: IDeviceCommand read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IDeviceCommandsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}
// *********************************************************************//
  IDeviceCommandsDisp = dispinterface
    ['{C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}']
    property Item[Index: Integer]: IDeviceCommand readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IItems
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46102071-60B4-4E58-8620-397D17B0BB5B}
// *********************************************************************//
  IItems = interface(IDispatch)
    ['{46102071-60B4-4E58-8620-397D17B0BB5B}']
    function Get_Item(Index: Integer): IItem; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Add(const Name: WideString; Flags: Integer); safecall;
    procedure Remove(Index: Integer); safecall;
    property Item[Index: Integer]: IItem read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IItemsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {46102071-60B4-4E58-8620-397D17B0BB5B}
// *********************************************************************//
  IItemsDisp = dispinterface
    ['{46102071-60B4-4E58-8620-397D17B0BB5B}']
    property Item[Index: Integer]: IItem readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Add(const Name: WideString; Flags: Integer); dispid 2;
    procedure Remove(Index: Integer); dispid 3;
  end;

// *********************************************************************//
// Interface: IItem
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {68F2BF12-A755-4E2B-9BCD-37A22587D078}
// *********************************************************************//
  IItem = interface(IDispatch)
    ['{68F2BF12-A755-4E2B-9BCD-37A22587D078}']
    function Get_ItemID: WideString; safecall;
    function Get_Properties: IProperties; safecall;
    function Get_Items: IItems; safecall;
    function Get_Formats: IFormats; safecall;
    function Get_Commands: IDeviceCommands; safecall;
    function Get_WiaItem: IUnknown; safecall;
    function Transfer(const FormatID: WideString): OleVariant; safecall;
    function ExecuteCommand(const CommandID: WideString): IItem; safecall;
    property ItemID: WideString read Get_ItemID;
    property Properties: IProperties read Get_Properties;
    property Items: IItems read Get_Items;
    property Formats: IFormats read Get_Formats;
    property Commands: IDeviceCommands read Get_Commands;
    property WiaItem: IUnknown read Get_WiaItem;
  end;

// *********************************************************************//
// DispIntf:  IItemDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {68F2BF12-A755-4E2B-9BCD-37A22587D078}
// *********************************************************************//
  IItemDisp = dispinterface
    ['{68F2BF12-A755-4E2B-9BCD-37A22587D078}']
    property ItemID: WideString readonly dispid 1;
    property Properties: IProperties readonly dispid 2;
    property Items: IItems readonly dispid 3;
    property Formats: IFormats readonly dispid 4;
    property Commands: IDeviceCommands readonly dispid 5;
    property WiaItem: IUnknown readonly dispid 6;
    function Transfer(const FormatID: WideString): OleVariant; dispid 7;
    function ExecuteCommand(const CommandID: WideString): IItem; dispid 8;
  end;

// *********************************************************************//
// Interface: IDeviceEvent
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {80D0880A-BB10-4722-82D1-07DC8DA157E2}
// *********************************************************************//
  IDeviceEvent = interface(IDispatch)
    ['{80D0880A-BB10-4722-82D1-07DC8DA157E2}']
    function Get_EventID: WideString; safecall;
    function Get_type_: WiaEventFlag; safecall;
    function Get_Name: WideString; safecall;
    function Get_Description: WideString; safecall;
    property EventID: WideString read Get_EventID;
    property type_: WiaEventFlag read Get_type_;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
  end;

// *********************************************************************//
// DispIntf:  IDeviceEventDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {80D0880A-BB10-4722-82D1-07DC8DA157E2}
// *********************************************************************//
  IDeviceEventDisp = dispinterface
    ['{80D0880A-BB10-4722-82D1-07DC8DA157E2}']
    property EventID: WideString readonly dispid 1;
    property type_: WiaEventFlag readonly dispid 2;
    property Name: WideString readonly dispid 3;
    property Description: WideString readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IDeviceEvents
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03985C95-581B-44D1-9403-8488B347538B}
// *********************************************************************//
  IDeviceEvents = interface(IDispatch)
    ['{03985C95-581B-44D1-9403-8488B347538B}']
    function Get_Item(Index: Integer): IDeviceEvent; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: Integer]: IDeviceEvent read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IDeviceEventsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {03985C95-581B-44D1-9403-8488B347538B}
// *********************************************************************//
  IDeviceEventsDisp = dispinterface
    ['{03985C95-581B-44D1-9403-8488B347538B}']
    property Item[Index: Integer]: IDeviceEvent readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: IDevice
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3714EAC4-F413-426B-B1E8-DEF2BE99EA55}
// *********************************************************************//
  IDevice = interface(IDispatch)
    ['{3714EAC4-F413-426B-B1E8-DEF2BE99EA55}']
    function Get_DeviceID: WideString; safecall;
    function Get_type_: WiaDeviceType; safecall;
    function Get_Properties: IProperties; safecall;
    function Get_Items: IItems; safecall;
    function Get_Commands: IDeviceCommands; safecall;
    function Get_Events: IDeviceEvents; safecall;
    function Get_WiaItem: IUnknown; safecall;
    function GetItem(const ItemID: WideString): IItem; safecall;
    function ExecuteCommand(const CommandID: WideString): IItem; safecall;
    property DeviceID: WideString read Get_DeviceID;
    property type_: WiaDeviceType read Get_type_;
    property Properties: IProperties read Get_Properties;
    property Items: IItems read Get_Items;
    property Commands: IDeviceCommands read Get_Commands;
    property Events: IDeviceEvents read Get_Events;
    property WiaItem: IUnknown read Get_WiaItem;
  end;

// *********************************************************************//
// DispIntf:  IDeviceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3714EAC4-F413-426B-B1E8-DEF2BE99EA55}
// *********************************************************************//
  IDeviceDisp = dispinterface
    ['{3714EAC4-F413-426B-B1E8-DEF2BE99EA55}']
    property DeviceID: WideString readonly dispid 1;
    property type_: WiaDeviceType readonly dispid 2;
    property Properties: IProperties readonly dispid 3;
    property Items: IItems readonly dispid 4;
    property Commands: IDeviceCommands readonly dispid 5;
    property Events: IDeviceEvents readonly dispid 6;
    property WiaItem: IUnknown readonly dispid 7;
    function GetItem(const ItemID: WideString): IItem; dispid 8;
    function ExecuteCommand(const CommandID: WideString): IItem; dispid 9;
  end;

// *********************************************************************//
// Interface: IDeviceInfo
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2A99020A-E325-4454-95E0-136726ED4818}
// *********************************************************************//
  IDeviceInfo = interface(IDispatch)
    ['{2A99020A-E325-4454-95E0-136726ED4818}']
    function Get_DeviceID: WideString; safecall;
    function Get_type_: WiaDeviceType; safecall;
    function Get_Properties: IProperties; safecall;
    function Connect: IDevice; safecall;
    property DeviceID: WideString read Get_DeviceID;
    property type_: WiaDeviceType read Get_type_;
    property Properties: IProperties read Get_Properties;
  end;

// *********************************************************************//
// DispIntf:  IDeviceInfoDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2A99020A-E325-4454-95E0-136726ED4818}
// *********************************************************************//
  IDeviceInfoDisp = dispinterface
    ['{2A99020A-E325-4454-95E0-136726ED4818}']
    property DeviceID: WideString readonly dispid 1;
    property type_: WiaDeviceType readonly dispid 2;
    property Properties: IProperties readonly dispid 3;
    function Connect: IDevice; dispid 4;
  end;

// *********************************************************************//
// Interface: IDeviceInfos
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FE076B64-8406-4E92-9CAC-9093F378E05F}
// *********************************************************************//
  IDeviceInfos = interface(IDispatch)
    ['{FE076B64-8406-4E92-9CAC-9093F378E05F}']
    function Get_Item(var Index: OleVariant): IDeviceInfo; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[var Index: OleVariant]: IDeviceInfo read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  IDeviceInfosDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FE076B64-8406-4E92-9CAC-9093F378E05F}
// *********************************************************************//
  IDeviceInfosDisp = dispinterface
    ['{FE076B64-8406-4E92-9CAC-9093F378E05F}']
    property Item[var Index: OleVariant]: IDeviceInfo readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

// *********************************************************************//
// Interface: ICommonDialog
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}
// *********************************************************************//
  ICommonDialog = interface(IDispatch)
    ['{B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}']
    function ShowAcquisitionWizard(const Device: IDevice): OleVariant; safecall;
    function ShowAcquireImage(DeviceType: WiaDeviceType; Intent: WiaImageIntent; 
                              Bias: WiaImageBias; const FormatID: WideString; 
                              AlwaysSelectDevice: WordBool; UseCommonUI: WordBool; 
                              CancelError: WordBool): IImageFile; safecall;
    function ShowSelectDevice(DeviceType: WiaDeviceType; AlwaysSelectDevice: WordBool; 
                              CancelError: WordBool): IDevice; safecall;
    function ShowSelectItems(const Device: IDevice; Intent: WiaImageIntent; Bias: WiaImageBias; 
                             SingleSelect: WordBool; UseCommonUI: WordBool; CancelError: WordBool): IItems; safecall;
    procedure ShowDeviceProperties(const Device: IDevice; CancelError: WordBool); safecall;
    procedure ShowItemProperties(const Item: IItem; CancelError: WordBool); safecall;
    function ShowTransfer(const Item: IItem; const FormatID: WideString; CancelError: WordBool): OleVariant; safecall;
    procedure ShowPhotoPrintingWizard(var Files: OleVariant); safecall;
  end;

// *********************************************************************//
// DispIntf:  ICommonDialogDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}
// *********************************************************************//
  ICommonDialogDisp = dispinterface
    ['{B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}']
    function ShowAcquisitionWizard(const Device: IDevice): OleVariant; dispid 1;
    function ShowAcquireImage(DeviceType: WiaDeviceType; Intent: WiaImageIntent; 
                              Bias: WiaImageBias; const FormatID: WideString; 
                              AlwaysSelectDevice: WordBool; UseCommonUI: WordBool; 
                              CancelError: WordBool): IImageFile; dispid 2;
    function ShowSelectDevice(DeviceType: WiaDeviceType; AlwaysSelectDevice: WordBool; 
                              CancelError: WordBool): IDevice; dispid 3;
    function ShowSelectItems(const Device: IDevice; Intent: WiaImageIntent; Bias: WiaImageBias; 
                             SingleSelect: WordBool; UseCommonUI: WordBool; CancelError: WordBool): IItems; dispid 4;
    procedure ShowDeviceProperties(const Device: IDevice; CancelError: WordBool); dispid 5;
    procedure ShowItemProperties(const Item: IItem; CancelError: WordBool); dispid 6;
    function ShowTransfer(const Item: IItem; const FormatID: WideString; CancelError: WordBool): OleVariant; dispid 7;
    procedure ShowPhotoPrintingWizard(var Files: OleVariant); dispid 8;
  end;

// *********************************************************************//
// Interface: IDeviceManager
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73856D9A-2720-487A-A584-21D5774E9D0F}
// *********************************************************************//
  IDeviceManager = interface(IDispatch)
    ['{73856D9A-2720-487A-A584-21D5774E9D0F}']
    function Get_DeviceInfos: IDeviceInfos; safecall;
    procedure RegisterEvent(const EventID: WideString; const DeviceID: WideString); safecall;
    procedure UnregisterEvent(const EventID: WideString; const DeviceID: WideString); safecall;
    procedure RegisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                      const Description: WideString; const Icon: WideString; 
                                      const EventID: WideString; const DeviceID: WideString); safecall;
    procedure UnregisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                        const Description: WideString; const Icon: WideString; 
                                        const EventID: WideString; const DeviceID: WideString); safecall;
    property DeviceInfos: IDeviceInfos read Get_DeviceInfos;
  end;

// *********************************************************************//
// DispIntf:  IDeviceManagerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {73856D9A-2720-487A-A584-21D5774E9D0F}
// *********************************************************************//
  IDeviceManagerDisp = dispinterface
    ['{73856D9A-2720-487A-A584-21D5774E9D0F}']
    property DeviceInfos: IDeviceInfos readonly dispid 1;
    procedure RegisterEvent(const EventID: WideString; const DeviceID: WideString); dispid 2;
    procedure UnregisterEvent(const EventID: WideString; const DeviceID: WideString); dispid 3;
    procedure RegisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                      const Description: WideString; const Icon: WideString; 
                                      const EventID: WideString; const DeviceID: WideString); dispid 4;
    procedure UnregisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                        const Description: WideString; const Icon: WideString; 
                                        const EventID: WideString; const DeviceID: WideString); dispid 5;
  end;

// *********************************************************************//
// DispIntf:  _IDeviceManagerEvents
// Flags:     (4096) Dispatchable
// GUID:      {2E9A5206-2360-49DF-9D9B-1762B4BEAE77}
// *********************************************************************//
  _IDeviceManagerEvents = dispinterface
    ['{2E9A5206-2360-49DF-9D9B-1762B4BEAE77}']
    procedure OnEvent(const EventID: WideString; const DeviceID: WideString; 
                      const ItemID: WideString); dispid 1;
  end;

// *********************************************************************//
// The Class CoRational provides a Create and CreateRemote method to          
// create instances of the default interface IRational exposed by              
// the CoClass Rational. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRational = class
    class function Create: IRational;
    class function CreateRemote(const MachineName: string): IRational;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TRational
// Help String      : The Rational object is a container for the rational values found in Exif tags. It is a supported element type of the Vector object and may be created using "WIA.Rational" in a call to CreateObject.
// Default Interface: IRational
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TRationalProperties= class;
{$ENDIF}
  TRational = class(TOleServer)
  private
    FIntf: IRational;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TRationalProperties;
    function GetServerProperties: TRationalProperties;
{$ENDIF}
    function GetDefaultInterface: IRational;
  protected
    procedure InitServerData; override;
    function Get_Value: Double;
    function Get_Numerator: Integer;
    procedure Set_Numerator(plResult: Integer);
    function Get_Denominator: Integer;
    procedure Set_Denominator(plResult: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IRational);
    procedure Disconnect; override;
    property DefaultInterface: IRational read GetDefaultInterface;
    property Value: Double read Get_Value;
    property Numerator: Integer read Get_Numerator write Set_Numerator;
    property Denominator: Integer read Get_Denominator write Set_Denominator;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TRationalProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TRational
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TRationalProperties = class(TPersistent)
  private
    FServer:    TRational;
    function    GetDefaultInterface: IRational;
    constructor Create(AServer: TRational);
  protected
    function Get_Value: Double;
    function Get_Numerator: Integer;
    procedure Set_Numerator(plResult: Integer);
    function Get_Denominator: Integer;
    procedure Set_Denominator(plResult: Integer);
  public
    property DefaultInterface: IRational read GetDefaultInterface;
  published
    property Numerator: Integer read Get_Numerator write Set_Numerator;
    property Denominator: Integer read Get_Denominator write Set_Denominator;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoVector provides a Create and CreateRemote method to          
// create instances of the default interface IVector exposed by              
// the CoClass Vector. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVector = class
    class function Create: IVector;
    class function CreateRemote(const MachineName: string): IVector;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TVector
// Help String      : The Vector object is a collection of values of the same type. It is used throughout the library in many different ways. The Vector object may be created using "WIA.Vector" in a call to CreateObject.
// Default Interface: IVector
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TVectorProperties= class;
{$ENDIF}
  TVector = class(TOleServer)
  private
    FIntf: IVector;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TVectorProperties;
    function GetServerProperties: TVectorProperties;
{$ENDIF}
    function GetDefaultInterface: IVector;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): OleVariant;
    procedure Set_Item(Index: Integer; var pResult: OleVariant);
    procedure _Set_Item(Index: Integer; var pResult: OleVariant);
    function Get_Count: Integer;
    function Get_Picture(Width: Integer; Height: Integer): OleVariant;
    function Get_ImageFile(Width: Integer; Height: Integer): IImageFile;
    function Get_BinaryData: OleVariant;
    procedure Set_BinaryData(var pvResult: OleVariant);
    function Get_String_(Unicode: WordBool): WideString;
    function Get_Date: TDateTime;
    procedure Set_Date(pdResult: TDateTime);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IVector);
    procedure Disconnect; override;
    procedure Add(var Value: OleVariant; Index: Integer);
    function Remove(Index: Integer): OleVariant;
    procedure Clear;
    procedure SetFromString(const Value: WideString; Resizable: WordBool; Unicode: WordBool);
    property DefaultInterface: IVector read GetDefaultInterface;
    property Count: Integer read Get_Count;
    property Picture[Width: Integer; Height: Integer]: OleVariant read Get_Picture;
    property ImageFile[Width: Integer; Height: Integer]: IImageFile read Get_ImageFile;
    property String_[Unicode: WordBool]: WideString read Get_String_;
    property Date: TDateTime read Get_Date write Set_Date;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TVectorProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TVector
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TVectorProperties = class(TPersistent)
  private
    FServer:    TVector;
    function    GetDefaultInterface: IVector;
    constructor Create(AServer: TVector);
  protected
    function Get_Item(Index: Integer): OleVariant;
    procedure Set_Item(Index: Integer; var pResult: OleVariant);
    procedure _Set_Item(Index: Integer; var pResult: OleVariant);
    function Get_Count: Integer;
    function Get_Picture(Width: Integer; Height: Integer): OleVariant;
    function Get_ImageFile(Width: Integer; Height: Integer): IImageFile;
    function Get_BinaryData: OleVariant;
    procedure Set_BinaryData(var pvResult: OleVariant);
    function Get_String_(Unicode: WordBool): WideString;
    function Get_Date: TDateTime;
    procedure Set_Date(pdResult: TDateTime);
  public
    property DefaultInterface: IVector read GetDefaultInterface;
  published
    property Date: TDateTime read Get_Date write Set_Date;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoProperty_ provides a Create and CreateRemote method to          
// create instances of the default interface IProperty exposed by              
// the CoClass Property_. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoProperty_ = class
    class function Create: IProperty;
    class function CreateRemote(const MachineName: string): IProperty;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TProperty_
// Help String      : The Property object is a container for a property associated with a Device, DeviceInfo, Filter, ImageFile or Item object. See the Properties property on any of these objects for details on accessing Property objects.
// Default Interface: IProperty
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TProperty_Properties= class;
{$ENDIF}
  TProperty_ = class(TOleServer)
  private
    FIntf: IProperty;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TProperty_Properties;
    function GetServerProperties: TProperty_Properties;
{$ENDIF}
    function GetDefaultInterface: IProperty;
  protected
    procedure InitServerData; override;
    function Get_Value: OleVariant;
    procedure Set_Value(var pvResult: OleVariant);
    procedure _Set_Value(var pvResult: OleVariant);
    function Get_Name: WideString;
    function Get_PropertyID: Integer;
    function Get_type_: Integer;
    function Get_IsReadOnly: WordBool;
    function Get_IsVector: WordBool;
    function Get_SubType: WiaSubType;
    function Get_SubTypeDefault: OleVariant;
    function Get_SubTypeValues: IVector;
    function Get_SubTypeMin: Integer;
    function Get_SubTypeMax: Integer;
    function Get_SubTypeStep: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IProperty);
    procedure Disconnect; override;
    property DefaultInterface: IProperty read GetDefaultInterface;
    property Name: WideString read Get_Name;
    property PropertyID: Integer read Get_PropertyID;
    property type_: Integer read Get_type_;
    property IsReadOnly: WordBool read Get_IsReadOnly;
    property IsVector: WordBool read Get_IsVector;
    property SubType: WiaSubType read Get_SubType;
    property SubTypeDefault: OleVariant read Get_SubTypeDefault;
    property SubTypeValues: IVector read Get_SubTypeValues;
    property SubTypeMin: Integer read Get_SubTypeMin;
    property SubTypeMax: Integer read Get_SubTypeMax;
    property SubTypeStep: Integer read Get_SubTypeStep;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TProperty_Properties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TProperty_
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TProperty_Properties = class(TPersistent)
  private
    FServer:    TProperty_;
    function    GetDefaultInterface: IProperty;
    constructor Create(AServer: TProperty_);
  protected
    function Get_Value: OleVariant;
    procedure Set_Value(var pvResult: OleVariant);
    procedure _Set_Value(var pvResult: OleVariant);
    function Get_Name: WideString;
    function Get_PropertyID: Integer;
    function Get_type_: Integer;
    function Get_IsReadOnly: WordBool;
    function Get_IsVector: WordBool;
    function Get_SubType: WiaSubType;
    function Get_SubTypeDefault: OleVariant;
    function Get_SubTypeValues: IVector;
    function Get_SubTypeMin: Integer;
    function Get_SubTypeMax: Integer;
    function Get_SubTypeStep: Integer;
  public
    property DefaultInterface: IProperty read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoProperties provides a Create and CreateRemote method to          
// create instances of the default interface IProperties exposed by              
// the CoClass Properties. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoProperties = class
    class function Create: IProperties;
    class function CreateRemote(const MachineName: string): IProperties;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TProperties
// Help String      : The Properties object is a collection of all the Property objects associated with a given Device, DeviceInfo, Filter, ImageFile or Item object. See the Properties property on any of these objects for detail on accessing the Properties object.
// Default Interface: IProperties
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TPropertiesProperties= class;
{$ENDIF}
  TProperties = class(TOleServer)
  private
    FIntf: IProperties;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TPropertiesProperties;
    function GetServerProperties: TPropertiesProperties;
{$ENDIF}
    function GetDefaultInterface: IProperties;
  protected
    procedure InitServerData; override;
    function Get_Item(var Index: OleVariant): IProperty;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IProperties);
    procedure Disconnect; override;
    function Exists(var Index: OleVariant): WordBool;
    property DefaultInterface: IProperties read GetDefaultInterface;
    property Item[var Index: OleVariant]: IProperty read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TPropertiesProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TProperties
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TPropertiesProperties = class(TPersistent)
  private
    FServer:    TProperties;
    function    GetDefaultInterface: IProperties;
    constructor Create(AServer: TProperties);
  protected
    function Get_Item(var Index: OleVariant): IProperty;
    function Get_Count: Integer;
  public
    property DefaultInterface: IProperties read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoImageFile provides a Create and CreateRemote method to          
// create instances of the default interface IImageFile exposed by              
// the CoClass ImageFile. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoImageFile = class
    class function Create: IImageFile;
    class function CreateRemote(const MachineName: string): IImageFile;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TImageFile
// Help String      : The ImageFile object is a container for images transferred to your computer when you call Transfer or ShowTransfer. It also supports image files through LoadFile. An ImageFile object can be created using "WIA.ImageFile" in a call to CreateObject.
// Default Interface: IImageFile
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TImageFileProperties= class;
{$ENDIF}
  TImageFile = class(TOleServer)
  private
    FIntf: IImageFile;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TImageFileProperties;
    function GetServerProperties: TImageFileProperties;
{$ENDIF}
    function GetDefaultInterface: IImageFile;
  protected
    procedure InitServerData; override;
    function Get_FormatID: WideString;
    function Get_FileExtension: WideString;
    function Get_FileData: IVector;
    function Get_ARGBData: IVector;
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_HorizontalResolution: Double;
    function Get_VerticalResolution: Double;
    function Get_PixelDepth: Integer;
    function Get_IsIndexedPixelFormat: WordBool;
    function Get_IsAlphaPixelFormat: WordBool;
    function Get_IsExtendedPixelFormat: WordBool;
    function Get_IsAnimated: WordBool;
    function Get_FrameCount: Integer;
    function Get_ActiveFrame: Integer;
    procedure Set_ActiveFrame(plResult: Integer);
    function Get_Properties: IProperties;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IImageFile);
    procedure Disconnect; override;
    procedure LoadFile(const Filename: WideString);
    procedure SaveFile(const Filename: WideString);
    property DefaultInterface: IImageFile read GetDefaultInterface;
    property FormatID: WideString read Get_FormatID;
    property FileExtension: WideString read Get_FileExtension;
    property FileData: IVector read Get_FileData;
    property ARGBData: IVector read Get_ARGBData;
    property Height: Integer read Get_Height;
    property Width: Integer read Get_Width;
    property HorizontalResolution: Double read Get_HorizontalResolution;
    property VerticalResolution: Double read Get_VerticalResolution;
    property PixelDepth: Integer read Get_PixelDepth;
    property IsIndexedPixelFormat: WordBool read Get_IsIndexedPixelFormat;
    property IsAlphaPixelFormat: WordBool read Get_IsAlphaPixelFormat;
    property IsExtendedPixelFormat: WordBool read Get_IsExtendedPixelFormat;
    property IsAnimated: WordBool read Get_IsAnimated;
    property FrameCount: Integer read Get_FrameCount;
    property Properties: IProperties read Get_Properties;
    property ActiveFrame: Integer read Get_ActiveFrame write Set_ActiveFrame;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TImageFileProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TImageFile
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TImageFileProperties = class(TPersistent)
  private
    FServer:    TImageFile;
    function    GetDefaultInterface: IImageFile;
    constructor Create(AServer: TImageFile);
  protected
    function Get_FormatID: WideString;
    function Get_FileExtension: WideString;
    function Get_FileData: IVector;
    function Get_ARGBData: IVector;
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_HorizontalResolution: Double;
    function Get_VerticalResolution: Double;
    function Get_PixelDepth: Integer;
    function Get_IsIndexedPixelFormat: WordBool;
    function Get_IsAlphaPixelFormat: WordBool;
    function Get_IsExtendedPixelFormat: WordBool;
    function Get_IsAnimated: WordBool;
    function Get_FrameCount: Integer;
    function Get_ActiveFrame: Integer;
    procedure Set_ActiveFrame(plResult: Integer);
    function Get_Properties: IProperties;
  public
    property DefaultInterface: IImageFile read GetDefaultInterface;
  published
    property ActiveFrame: Integer read Get_ActiveFrame write Set_ActiveFrame;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFilterInfo provides a Create and CreateRemote method to          
// create instances of the default interface IFilterInfo exposed by              
// the CoClass FilterInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilterInfo = class
    class function Create: IFilterInfo;
    class function CreateRemote(const MachineName: string): IFilterInfo;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFilterInfo
// Help String      : The FilterInfo object is a container that describes a Filter object without requiring a Filter to be Added to the process chain. See the FilterInfos property on the ImageProcess object for details on accessing FilterInfo objects.
// Default Interface: IFilterInfo
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFilterInfoProperties= class;
{$ENDIF}
  TFilterInfo = class(TOleServer)
  private
    FIntf: IFilterInfo;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFilterInfoProperties;
    function GetServerProperties: TFilterInfoProperties;
{$ENDIF}
    function GetDefaultInterface: IFilterInfo;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    function Get_Description: WideString;
    function Get_FilterID: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFilterInfo);
    procedure Disconnect; override;
    property DefaultInterface: IFilterInfo read GetDefaultInterface;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
    property FilterID: WideString read Get_FilterID;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFilterInfoProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFilterInfo
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFilterInfoProperties = class(TPersistent)
  private
    FServer:    TFilterInfo;
    function    GetDefaultInterface: IFilterInfo;
    constructor Create(AServer: TFilterInfo);
  protected
    function Get_Name: WideString;
    function Get_Description: WideString;
    function Get_FilterID: WideString;
  public
    property DefaultInterface: IFilterInfo read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFilterInfos provides a Create and CreateRemote method to          
// create instances of the default interface IFilterInfos exposed by              
// the CoClass FilterInfos. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilterInfos = class
    class function Create: IFilterInfos;
    class function CreateRemote(const MachineName: string): IFilterInfos;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFilterInfos
// Help String      : The FilterInfos object is a collection of all the available FilterInfo objects. See the FilterInfos property on the ImageProcess object for detail on accessing the FilterInfos object.
// Default Interface: IFilterInfos
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFilterInfosProperties= class;
{$ENDIF}
  TFilterInfos = class(TOleServer)
  private
    FIntf: IFilterInfos;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFilterInfosProperties;
    function GetServerProperties: TFilterInfosProperties;
{$ENDIF}
    function GetDefaultInterface: IFilterInfos;
  protected
    procedure InitServerData; override;
    function Get_Item(var Index: OleVariant): IFilterInfo;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFilterInfos);
    procedure Disconnect; override;
    property DefaultInterface: IFilterInfos read GetDefaultInterface;
    property Item[var Index: OleVariant]: IFilterInfo read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFilterInfosProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFilterInfos
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFilterInfosProperties = class(TPersistent)
  private
    FServer:    TFilterInfos;
    function    GetDefaultInterface: IFilterInfos;
    constructor Create(AServer: TFilterInfos);
  protected
    function Get_Item(var Index: OleVariant): IFilterInfo;
    function Get_Count: Integer;
  public
    property DefaultInterface: IFilterInfos read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFilter provides a Create and CreateRemote method to          
// create instances of the default interface IFilter exposed by              
// the CoClass Filter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilter = class
    class function Create: IFilter;
    class function CreateRemote(const MachineName: string): IFilter;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFilter
// Help String      : The Filter object represents a unit of modification on an ImageFile. To use a Filter, add it to the Filters collection, then set the filter's properties and finally use the Apply method of the ImageProcess object to filter an ImageFile.
// Default Interface: IFilter
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFilterProperties= class;
{$ENDIF}
  TFilter = class(TOleServer)
  private
    FIntf: IFilter;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFilterProperties;
    function GetServerProperties: TFilterProperties;
{$ENDIF}
    function GetDefaultInterface: IFilter;
  protected
    procedure InitServerData; override;
    function Get_Name: WideString;
    function Get_Description: WideString;
    function Get_FilterID: WideString;
    function Get_Properties: IProperties;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFilter);
    procedure Disconnect; override;
    property DefaultInterface: IFilter read GetDefaultInterface;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
    property FilterID: WideString read Get_FilterID;
    property Properties: IProperties read Get_Properties;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFilterProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFilter
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFilterProperties = class(TPersistent)
  private
    FServer:    TFilter;
    function    GetDefaultInterface: IFilter;
    constructor Create(AServer: TFilter);
  protected
    function Get_Name: WideString;
    function Get_Description: WideString;
    function Get_FilterID: WideString;
    function Get_Properties: IProperties;
  public
    property DefaultInterface: IFilter read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFilters provides a Create and CreateRemote method to          
// create instances of the default interface IFilters exposed by              
// the CoClass Filters. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFilters = class
    class function Create: IFilters;
    class function CreateRemote(const MachineName: string): IFilters;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFilters
// Help String      : The Filters object is a collection of the Filters that will be applied to an ImageFile when you call the Apply method on the ImageProcess object.
// Default Interface: IFilters
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFiltersProperties= class;
{$ENDIF}
  TFilters = class(TOleServer)
  private
    FIntf: IFilters;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFiltersProperties;
    function GetServerProperties: TFiltersProperties;
{$ENDIF}
    function GetDefaultInterface: IFilters;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): IFilter;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFilters);
    procedure Disconnect; override;
    procedure Add(const FilterID: WideString; Index: Integer);
    procedure Remove(Index: Integer);
    property DefaultInterface: IFilters read GetDefaultInterface;
    property Item[Index: Integer]: IFilter read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFiltersProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFilters
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFiltersProperties = class(TPersistent)
  private
    FServer:    TFilters;
    function    GetDefaultInterface: IFilters;
    constructor Create(AServer: TFilters);
  protected
    function Get_Item(Index: Integer): IFilter;
    function Get_Count: Integer;
  public
    property DefaultInterface: IFilters read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoImageProcess provides a Create and CreateRemote method to          
// create instances of the default interface IImageProcess exposed by              
// the CoClass ImageProcess. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoImageProcess = class
    class function Create: IImageProcess;
    class function CreateRemote(const MachineName: string): IImageProcess;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TImageProcess
// Help String      : The ImageProcess object manages the filter chain. An ImageProcess object can be created using "WIA.ImageProcess" in a call to CreateObject.
// Default Interface: IImageProcess
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TImageProcessProperties= class;
{$ENDIF}
  TImageProcess = class(TOleServer)
  private
    FIntf: IImageProcess;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TImageProcessProperties;
    function GetServerProperties: TImageProcessProperties;
{$ENDIF}
    function GetDefaultInterface: IImageProcess;
  protected
    procedure InitServerData; override;
    function Get_FilterInfos: IFilterInfos;
    function Get_Filters: IFilters;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IImageProcess);
    procedure Disconnect; override;
    function Apply(const Source: IImageFile): IImageFile;
    property DefaultInterface: IImageProcess read GetDefaultInterface;
    property FilterInfos: IFilterInfos read Get_FilterInfos;
    property Filters: IFilters read Get_Filters;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TImageProcessProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TImageProcess
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TImageProcessProperties = class(TPersistent)
  private
    FServer:    TImageProcess;
    function    GetDefaultInterface: IImageProcess;
    constructor Create(AServer: TImageProcess);
  protected
    function Get_FilterInfos: IFilterInfos;
    function Get_Filters: IFilters;
  public
    property DefaultInterface: IImageProcess read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFormats provides a Create and CreateRemote method to          
// create instances of the default interface IFormats exposed by              
// the CoClass Formats. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFormats = class
    class function Create: IFormats;
    class function CreateRemote(const MachineName: string): IFormats;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFormats
// Help String      : The Formats object is a collection of supported FormatIDs that you can use when calling Transfer on an Item object or ShowTransfer on a CommonDialog object for this Item.
// Default Interface: IFormats
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFormatsProperties= class;
{$ENDIF}
  TFormats = class(TOleServer)
  private
    FIntf: IFormats;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TFormatsProperties;
    function GetServerProperties: TFormatsProperties;
{$ENDIF}
    function GetDefaultInterface: IFormats;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): WideString;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFormats);
    procedure Disconnect; override;
    property DefaultInterface: IFormats read GetDefaultInterface;
    property Item[Index: Integer]: WideString read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFormatsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFormats
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFormatsProperties = class(TPersistent)
  private
    FServer:    TFormats;
    function    GetDefaultInterface: IFormats;
    constructor Create(AServer: TFormats);
  protected
    function Get_Item(Index: Integer): WideString;
    function Get_Count: Integer;
  public
    property DefaultInterface: IFormats read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceCommand provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceCommand exposed by              
// the CoClass DeviceCommand. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceCommand = class
    class function Create: IDeviceCommand;
    class function CreateRemote(const MachineName: string): IDeviceCommand;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceCommand
// Help String      : The DeviceCommand object describes a CommandID that can be used when calling ExecuteCommand on a Device or Item object.
// Default Interface: IDeviceCommand
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceCommandProperties= class;
{$ENDIF}
  TDeviceCommand = class(TOleServer)
  private
    FIntf: IDeviceCommand;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceCommandProperties;
    function GetServerProperties: TDeviceCommandProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceCommand;
  protected
    procedure InitServerData; override;
    function Get_CommandID: WideString;
    function Get_Name: WideString;
    function Get_Description: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceCommand);
    procedure Disconnect; override;
    property DefaultInterface: IDeviceCommand read GetDefaultInterface;
    property CommandID: WideString read Get_CommandID;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceCommandProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceCommand
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceCommandProperties = class(TPersistent)
  private
    FServer:    TDeviceCommand;
    function    GetDefaultInterface: IDeviceCommand;
    constructor Create(AServer: TDeviceCommand);
  protected
    function Get_CommandID: WideString;
    function Get_Name: WideString;
    function Get_Description: WideString;
  public
    property DefaultInterface: IDeviceCommand read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceCommands provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceCommands exposed by              
// the CoClass DeviceCommands. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceCommands = class
    class function Create: IDeviceCommands;
    class function CreateRemote(const MachineName: string): IDeviceCommands;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceCommands
// Help String      : The DeviceCommands object is a collection of all the supported DeviceCommands for an imaging device. See the Commands property of a Device or Item object for more details on determining the collection of supported device commands.
// Default Interface: IDeviceCommands
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceCommandsProperties= class;
{$ENDIF}
  TDeviceCommands = class(TOleServer)
  private
    FIntf: IDeviceCommands;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceCommandsProperties;
    function GetServerProperties: TDeviceCommandsProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceCommands;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): IDeviceCommand;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceCommands);
    procedure Disconnect; override;
    property DefaultInterface: IDeviceCommands read GetDefaultInterface;
    property Item[Index: Integer]: IDeviceCommand read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceCommandsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceCommands
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceCommandsProperties = class(TPersistent)
  private
    FServer:    TDeviceCommands;
    function    GetDefaultInterface: IDeviceCommands;
    constructor Create(AServer: TDeviceCommands);
  protected
    function Get_Item(Index: Integer): IDeviceCommand;
    function Get_Count: Integer;
  public
    property DefaultInterface: IDeviceCommands read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoItem provides a Create and CreateRemote method to          
// create instances of the default interface IItem exposed by              
// the CoClass Item. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoItem = class
    class function Create: IItem;
    class function CreateRemote(const MachineName: string): IItem;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TItem
// Help String      : The Item object is a container for an item on an imaging device object. See the Items property on the Device or Item object for details on accessing Item objects.
// Default Interface: IItem
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TItemProperties= class;
{$ENDIF}
  TItem = class(TOleServer)
  private
    FIntf: IItem;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TItemProperties;
    function GetServerProperties: TItemProperties;
{$ENDIF}
    function GetDefaultInterface: IItem;
  protected
    procedure InitServerData; override;
    function Get_ItemID: WideString;
    function Get_Properties: IProperties;
    function Get_Items: IItems;
    function Get_Formats: IFormats;
    function Get_Commands: IDeviceCommands;
    function Get_WiaItem: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IItem);
    procedure Disconnect; override;
    function Transfer(const FormatID: WideString): OleVariant;
    function ExecuteCommand(const CommandID: WideString): IItem;
    property DefaultInterface: IItem read GetDefaultInterface;
    property ItemID: WideString read Get_ItemID;
    property Properties: IProperties read Get_Properties;
    property Items: IItems read Get_Items;
    property Formats: IFormats read Get_Formats;
    property Commands: IDeviceCommands read Get_Commands;
    property WiaItem: IUnknown read Get_WiaItem;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TItemProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TItem
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TItemProperties = class(TPersistent)
  private
    FServer:    TItem;
    function    GetDefaultInterface: IItem;
    constructor Create(AServer: TItem);
  protected
    function Get_ItemID: WideString;
    function Get_Properties: IProperties;
    function Get_Items: IItems;
    function Get_Formats: IFormats;
    function Get_Commands: IDeviceCommands;
    function Get_WiaItem: IUnknown;
  public
    property DefaultInterface: IItem read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoItems provides a Create and CreateRemote method to          
// create instances of the default interface IItems exposed by              
// the CoClass Items. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoItems = class
    class function Create: IItems;
    class function CreateRemote(const MachineName: string): IItems;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TItems
// Help String      : The Items object contains a collection of Item objects. See the Items property on the Device or Item object for details on accessing the Items object.
// Default Interface: IItems
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TItemsProperties= class;
{$ENDIF}
  TItems = class(TOleServer)
  private
    FIntf: IItems;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TItemsProperties;
    function GetServerProperties: TItemsProperties;
{$ENDIF}
    function GetDefaultInterface: IItems;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): IItem;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IItems);
    procedure Disconnect; override;
    procedure Add(const Name: WideString; Flags: Integer);
    procedure Remove(Index: Integer);
    property DefaultInterface: IItems read GetDefaultInterface;
    property Item[Index: Integer]: IItem read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TItemsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TItems
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TItemsProperties = class(TPersistent)
  private
    FServer:    TItems;
    function    GetDefaultInterface: IItems;
    constructor Create(AServer: TItems);
  protected
    function Get_Item(Index: Integer): IItem;
    function Get_Count: Integer;
  public
    property DefaultInterface: IItems read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceEvent provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceEvent exposed by              
// the CoClass DeviceEvent. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceEvent = class
    class function Create: IDeviceEvent;
    class function CreateRemote(const MachineName: string): IDeviceEvent;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceEvent
// Help String      : The DeviceEvent object describes an EventID that can be used when calling RegisterEvent or RegisterPersistentEvent on a DeviceManager object.
// Default Interface: IDeviceEvent
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceEventProperties= class;
{$ENDIF}
  TDeviceEvent = class(TOleServer)
  private
    FIntf: IDeviceEvent;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceEventProperties;
    function GetServerProperties: TDeviceEventProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceEvent;
  protected
    procedure InitServerData; override;
    function Get_EventID: WideString;
    function Get_type_: WiaEventFlag;
    function Get_Name: WideString;
    function Get_Description: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceEvent);
    procedure Disconnect; override;
    property DefaultInterface: IDeviceEvent read GetDefaultInterface;
    property EventID: WideString read Get_EventID;
    property type_: WiaEventFlag read Get_type_;
    property Name: WideString read Get_Name;
    property Description: WideString read Get_Description;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceEventProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceEvent
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceEventProperties = class(TPersistent)
  private
    FServer:    TDeviceEvent;
    function    GetDefaultInterface: IDeviceEvent;
    constructor Create(AServer: TDeviceEvent);
  protected
    function Get_EventID: WideString;
    function Get_type_: WiaEventFlag;
    function Get_Name: WideString;
    function Get_Description: WideString;
  public
    property DefaultInterface: IDeviceEvent read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceEvents provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceEvents exposed by              
// the CoClass DeviceEvents. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceEvents = class
    class function Create: IDeviceEvents;
    class function CreateRemote(const MachineName: string): IDeviceEvents;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceEvents
// Help String      : The DeviceEvents object is a collection of all the supported DeviceEvent for an imaging device. See the Events property of a Device object for more details on determining the collection of supported device events.
// Default Interface: IDeviceEvents
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceEventsProperties= class;
{$ENDIF}
  TDeviceEvents = class(TOleServer)
  private
    FIntf: IDeviceEvents;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceEventsProperties;
    function GetServerProperties: TDeviceEventsProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceEvents;
  protected
    procedure InitServerData; override;
    function Get_Item(Index: Integer): IDeviceEvent;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceEvents);
    procedure Disconnect; override;
    property DefaultInterface: IDeviceEvents read GetDefaultInterface;
    property Item[Index: Integer]: IDeviceEvent read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceEventsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceEvents
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceEventsProperties = class(TPersistent)
  private
    FServer:    TDeviceEvents;
    function    GetDefaultInterface: IDeviceEvents;
    constructor Create(AServer: TDeviceEvents);
  protected
    function Get_Item(Index: Integer): IDeviceEvent;
    function Get_Count: Integer;
  public
    property DefaultInterface: IDeviceEvents read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceInfo provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceInfo exposed by              
// the CoClass DeviceInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceInfo = class
    class function Create: IDeviceInfo;
    class function CreateRemote(const MachineName: string): IDeviceInfo;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceInfo
// Help String      : The DeviceInfo object is a container that describes the unchanging (static) properties of an imaging device that is currently connected to the computer.
// Default Interface: IDeviceInfo
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceInfoProperties= class;
{$ENDIF}
  TDeviceInfo = class(TOleServer)
  private
    FIntf: IDeviceInfo;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceInfoProperties;
    function GetServerProperties: TDeviceInfoProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceInfo;
  protected
    procedure InitServerData; override;
    function Get_DeviceID: WideString;
    function Get_type_: WiaDeviceType;
    function Get_Properties: IProperties;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceInfo);
    procedure Disconnect; override;
    function Connect1: IDevice;
    property DefaultInterface: IDeviceInfo read GetDefaultInterface;
    property DeviceID: WideString read Get_DeviceID;
    property type_: WiaDeviceType read Get_type_;
    property Properties: IProperties read Get_Properties;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceInfoProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceInfo
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceInfoProperties = class(TPersistent)
  private
    FServer:    TDeviceInfo;
    function    GetDefaultInterface: IDeviceInfo;
    constructor Create(AServer: TDeviceInfo);
  protected
    function Get_DeviceID: WideString;
    function Get_type_: WiaDeviceType;
    function Get_Properties: IProperties;
  public
    property DefaultInterface: IDeviceInfo read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceInfos provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceInfos exposed by              
// the CoClass DeviceInfos. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceInfos = class
    class function Create: IDeviceInfos;
    class function CreateRemote(const MachineName: string): IDeviceInfos;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceInfos
// Help String      : The DeviceInfos object is a collection of all the imaging devices currently connected to the computer. See the DeviceInfos property on the DeviceManager object for detail on accessing the DeviceInfos object.
// Default Interface: IDeviceInfos
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceInfosProperties= class;
{$ENDIF}
  TDeviceInfos = class(TOleServer)
  private
    FIntf: IDeviceInfos;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceInfosProperties;
    function GetServerProperties: TDeviceInfosProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceInfos;
  protected
    procedure InitServerData; override;
    function Get_Item(var Index: OleVariant): IDeviceInfo;
    function Get_Count: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceInfos);
    procedure Disconnect; override;
    property DefaultInterface: IDeviceInfos read GetDefaultInterface;
    property Item[var Index: OleVariant]: IDeviceInfo read Get_Item; default;
    property Count: Integer read Get_Count;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceInfosProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceInfos
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceInfosProperties = class(TPersistent)
  private
    FServer:    TDeviceInfos;
    function    GetDefaultInterface: IDeviceInfos;
    constructor Create(AServer: TDeviceInfos);
  protected
    function Get_Item(var Index: OleVariant): IDeviceInfo;
    function Get_Count: Integer;
  public
    property DefaultInterface: IDeviceInfos read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDevice provides a Create and CreateRemote method to          
// create instances of the default interface IDevice exposed by              
// the CoClass Device. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDevice = class
    class function Create: IDevice;
    class function CreateRemote(const MachineName: string): IDevice;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDevice
// Help String      : The Device object represents an active connection to an imaging device.
// Default Interface: IDevice
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (0)
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceProperties= class;
{$ENDIF}
  TDevice = class(TOleServer)
  private
    FIntf: IDevice;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceProperties;
    function GetServerProperties: TDeviceProperties;
{$ENDIF}
    function GetDefaultInterface: IDevice;
  protected
    procedure InitServerData; override;
    function Get_DeviceID: WideString;
    function Get_type_: WiaDeviceType;
    function Get_Properties: IProperties;
    function Get_Items: IItems;
    function Get_Commands: IDeviceCommands;
    function Get_Events: IDeviceEvents;
    function Get_WiaItem: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDevice);
    procedure Disconnect; override;
    function GetItem(const ItemID: WideString): IItem;
    function ExecuteCommand(const CommandID: WideString): IItem;
    property DefaultInterface: IDevice read GetDefaultInterface;
    property DeviceID: WideString read Get_DeviceID;
    property type_: WiaDeviceType read Get_type_;
    property Properties: IProperties read Get_Properties;
    property Items: IItems read Get_Items;
    property Commands: IDeviceCommands read Get_Commands;
    property Events: IDeviceEvents read Get_Events;
    property WiaItem: IUnknown read Get_WiaItem;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDevice
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceProperties = class(TPersistent)
  private
    FServer:    TDevice;
    function    GetDefaultInterface: IDevice;
    constructor Create(AServer: TDevice);
  protected
    function Get_DeviceID: WideString;
    function Get_type_: WiaDeviceType;
    function Get_Properties: IProperties;
    function Get_Items: IItems;
    function Get_Commands: IDeviceCommands;
    function Get_Events: IDeviceEvents;
    function Get_WiaItem: IUnknown;
  public
    property DefaultInterface: IDevice read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoCommonDialog provides a Create and CreateRemote method to          
// create instances of the default interface ICommonDialog exposed by              
// the CoClass CommonDialog. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCommonDialog = class
    class function Create: ICommonDialog;
    class function CreateRemote(const MachineName: string): ICommonDialog;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCommonDialog
// Help String      : The CommonDialog control is an invisible-at-runtime control that contains all the methods that display a User Interface. A CommonDialog control can be created using "WIA.CommonDialog" in a call to CreateObject or by dropping a CommonDialog on a form.
// Default Interface: ICommonDialog
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCommonDialogProperties= class;
{$ENDIF}
  TCommonDialog = class(TOleServer)
  private
    FIntf: ICommonDialog;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TCommonDialogProperties;
    function GetServerProperties: TCommonDialogProperties;
{$ENDIF}
    function GetDefaultInterface: ICommonDialog;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ICommonDialog);
    procedure Disconnect; override;
    function ShowAcquisitionWizard(const Device: IDevice): OleVariant;
    function ShowAcquireImage(DeviceType: WiaDeviceType; Intent: WiaImageIntent; 
                              Bias: WiaImageBias; const FormatID: WideString; 
                              AlwaysSelectDevice: WordBool; UseCommonUI: WordBool; 
                              CancelError: WordBool): IImageFile;
    function ShowSelectDevice(DeviceType: WiaDeviceType; AlwaysSelectDevice: WordBool; 
                              CancelError: WordBool): IDevice;
    function ShowSelectItems(const Device: IDevice; Intent: WiaImageIntent; Bias: WiaImageBias; 
                             SingleSelect: WordBool; UseCommonUI: WordBool; CancelError: WordBool): IItems;
    procedure ShowDeviceProperties(const Device: IDevice; CancelError: WordBool);
    procedure ShowItemProperties(const Item: IItem; CancelError: WordBool);
    function ShowTransfer(const Item: IItem; const FormatID: WideString; CancelError: WordBool): OleVariant;
    procedure ShowPhotoPrintingWizard(var Files: OleVariant);
    property DefaultInterface: ICommonDialog read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCommonDialogProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCommonDialog
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCommonDialogProperties = class(TPersistent)
  private
    FServer:    TCommonDialog;
    function    GetDefaultInterface: ICommonDialog;
    constructor Create(AServer: TCommonDialog);
  protected
  public
    property DefaultInterface: ICommonDialog read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDeviceManager provides a Create and CreateRemote method to          
// create instances of the default interface IDeviceManager exposed by              
// the CoClass DeviceManager. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDeviceManager = class
    class function Create: IDeviceManager;
    class function CreateRemote(const MachineName: string): IDeviceManager;
  end;

  TDeviceManagerOnEvent = procedure(ASender: TObject; const EventID: WideString; 
                                                      const DeviceID: WideString; 
                                                      const ItemID: WideString) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDeviceManager
// Help String      : The DeviceManager control is an invisible-at-runtime control that manages the imaging devices connected to the computer. A DeviceManager control can be created using "WIA.DeviceManager" in a call to CreateObject or by dropping a DeviceManager on a form.
// Default Interface: IDeviceManager
// Def. Intf. DISP? : No
// Event   Interface: _IDeviceManagerEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDeviceManagerProperties= class;
{$ENDIF}
  TDeviceManager = class(TOleServer)
  private
    FOnEvent: TDeviceManagerOnEvent;
    FIntf: IDeviceManager;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TDeviceManagerProperties;
    function GetServerProperties: TDeviceManagerProperties;
{$ENDIF}
    function GetDefaultInterface: IDeviceManager;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_DeviceInfos: IDeviceInfos;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDeviceManager);
    procedure Disconnect; override;
    procedure RegisterEvent(const EventID: WideString; const DeviceID: WideString);
    procedure UnregisterEvent(const EventID: WideString; const DeviceID: WideString);
    procedure RegisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                      const Description: WideString; const Icon: WideString; 
                                      const EventID: WideString; const DeviceID: WideString);
    procedure UnregisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                        const Description: WideString; const Icon: WideString; 
                                        const EventID: WideString; const DeviceID: WideString);
    property DefaultInterface: IDeviceManager read GetDefaultInterface;
    property DeviceInfos: IDeviceInfos read Get_DeviceInfos;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDeviceManagerProperties read GetServerProperties;
{$ENDIF}
    property OnEvent: TDeviceManagerOnEvent read FOnEvent write FOnEvent;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDeviceManager
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDeviceManagerProperties = class(TPersistent)
  private
    FServer:    TDeviceManager;
    function    GetDefaultInterface: IDeviceManager;
    constructor Create(AServer: TDeviceManager);
  protected
    function Get_DeviceInfos: IDeviceInfos;
  public
    property DefaultInterface: IDeviceManager read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoRational.Create: IRational;
begin
  Result := CreateComObject(CLASS_Rational) as IRational;
end;

class function CoRational.CreateRemote(const MachineName: string): IRational;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Rational) as IRational;
end;

procedure TRational.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0C5672F9-3EDC-4B24-95B5-A6C54C0B79AD}';
    IntfIID:   '{3BF1B24A-01A5-4AA3-91F9-25A60B50E49B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TRational.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IRational;
  end;
end;

procedure TRational.ConnectTo(svrIntf: IRational);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TRational.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TRational.GetDefaultInterface: IRational;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TRational.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TRationalProperties.Create(Self);
{$ENDIF}
end;

destructor TRational.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TRational.GetServerProperties: TRationalProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TRational.Get_Value: Double;
begin
    Result := DefaultInterface.Value;
end;

function TRational.Get_Numerator: Integer;
begin
    Result := DefaultInterface.Numerator;
end;

procedure TRational.Set_Numerator(plResult: Integer);
begin
  DefaultInterface.Set_Numerator(plResult);
end;

function TRational.Get_Denominator: Integer;
begin
    Result := DefaultInterface.Denominator;
end;

procedure TRational.Set_Denominator(plResult: Integer);
begin
  DefaultInterface.Set_Denominator(plResult);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TRationalProperties.Create(AServer: TRational);
begin
  inherited Create;
  FServer := AServer;
end;

function TRationalProperties.GetDefaultInterface: IRational;
begin
  Result := FServer.DefaultInterface;
end;

function TRationalProperties.Get_Value: Double;
begin
    Result := DefaultInterface.Value;
end;

function TRationalProperties.Get_Numerator: Integer;
begin
    Result := DefaultInterface.Numerator;
end;

procedure TRationalProperties.Set_Numerator(plResult: Integer);
begin
  DefaultInterface.Set_Numerator(plResult);
end;

function TRationalProperties.Get_Denominator: Integer;
begin
    Result := DefaultInterface.Denominator;
end;

procedure TRationalProperties.Set_Denominator(plResult: Integer);
begin
  DefaultInterface.Set_Denominator(plResult);
end;

{$ENDIF}

class function CoVector.Create: IVector;
begin
  Result := CreateComObject(CLASS_Vector) as IVector;
end;

class function CoVector.CreateRemote(const MachineName: string): IVector;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Vector) as IVector;
end;

procedure TVector.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{4DD1D1C3-B36A-4EB4-AAEF-815891A58A30}';
    IntfIID:   '{696F2367-6619-49BD-BA96-904DC2609990}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TVector.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IVector;
  end;
end;

procedure TVector.ConnectTo(svrIntf: IVector);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TVector.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TVector.GetDefaultInterface: IVector;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TVector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TVectorProperties.Create(Self);
{$ENDIF}
end;

destructor TVector.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TVector.GetServerProperties: TVectorProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TVector.Get_Item(Index: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Item[Index];
end;

procedure TVector.Set_Item(Index: Integer; var pResult: OleVariant);
  { Warning: The property Item has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Item := pResult;
end;

procedure TVector._Set_Item(Index: Integer; var pResult: OleVariant);
  { Warning: The property Item has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Item := pResult;
end;

function TVector.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TVector.Get_Picture(Width: Integer; Height: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Picture[Width, Height];
end;

function TVector.Get_ImageFile(Width: Integer; Height: Integer): IImageFile;
begin
    Result := DefaultInterface.ImageFile[Width, Height];
end;

function TVector.Get_BinaryData: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.BinaryData;
end;

procedure TVector.Set_BinaryData(var pvResult: OleVariant);
  { Warning: The property BinaryData has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BinaryData := pvResult;
end;

function TVector.Get_String_(Unicode: WordBool): WideString;
begin
    Result := DefaultInterface.String_[Unicode];
end;

function TVector.Get_Date: TDateTime;
begin
    Result := DefaultInterface.Date;
end;

procedure TVector.Set_Date(pdResult: TDateTime);
begin
  DefaultInterface.Set_Date(pdResult);
end;

procedure TVector.Add(var Value: OleVariant; Index: Integer);
begin
  DefaultInterface.Add(Value, Index);
end;

function TVector.Remove(Index: Integer): OleVariant;
begin
  Result := DefaultInterface.Remove(Index);
end;

procedure TVector.Clear;
begin
  DefaultInterface.Clear;
end;

procedure TVector.SetFromString(const Value: WideString; Resizable: WordBool; Unicode: WordBool);
begin
  DefaultInterface.SetFromString(Value, Resizable, Unicode);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TVectorProperties.Create(AServer: TVector);
begin
  inherited Create;
  FServer := AServer;
end;

function TVectorProperties.GetDefaultInterface: IVector;
begin
  Result := FServer.DefaultInterface;
end;

function TVectorProperties.Get_Item(Index: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Item[Index];
end;

procedure TVectorProperties.Set_Item(Index: Integer; var pResult: OleVariant);
  { Warning: The property Item has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Item := pResult;
end;

procedure TVectorProperties._Set_Item(Index: Integer; var pResult: OleVariant);
  { Warning: The property Item has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Item := pResult;
end;

function TVectorProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TVectorProperties.Get_Picture(Width: Integer; Height: Integer): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Picture[Width, Height];
end;

function TVectorProperties.Get_ImageFile(Width: Integer; Height: Integer): IImageFile;
begin
    Result := DefaultInterface.ImageFile[Width, Height];
end;

function TVectorProperties.Get_BinaryData: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.BinaryData;
end;

procedure TVectorProperties.Set_BinaryData(var pvResult: OleVariant);
  { Warning: The property BinaryData has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BinaryData := pvResult;
end;

function TVectorProperties.Get_String_(Unicode: WordBool): WideString;
begin
    Result := DefaultInterface.String_[Unicode];
end;

function TVectorProperties.Get_Date: TDateTime;
begin
    Result := DefaultInterface.Date;
end;

procedure TVectorProperties.Set_Date(pdResult: TDateTime);
begin
  DefaultInterface.Set_Date(pdResult);
end;

{$ENDIF}

class function CoProperty_.Create: IProperty;
begin
  Result := CreateComObject(CLASS_Property_) as IProperty;
end;

class function CoProperty_.CreateRemote(const MachineName: string): IProperty;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Property_) as IProperty;
end;

procedure TProperty_.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{2014DE3F-3723-4178-8643-3317A32D4A2B}';
    IntfIID:   '{706038DC-9F4B-4E45-88E2-5EB7D665B815}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TProperty_.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IProperty;
  end;
end;

procedure TProperty_.ConnectTo(svrIntf: IProperty);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TProperty_.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TProperty_.GetDefaultInterface: IProperty;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TProperty_.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TProperty_Properties.Create(Self);
{$ENDIF}
end;

destructor TProperty_.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TProperty_.GetServerProperties: TProperty_Properties;
begin
  Result := FProps;
end;
{$ENDIF}

function TProperty_.Get_Value: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Value;
end;

procedure TProperty_.Set_Value(var pvResult: OleVariant);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pvResult;
end;

procedure TProperty_._Set_Value(var pvResult: OleVariant);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pvResult;
end;

function TProperty_.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TProperty_.Get_PropertyID: Integer;
begin
    Result := DefaultInterface.PropertyID;
end;

function TProperty_.Get_type_: Integer;
begin
    Result := DefaultInterface.type_;
end;

function TProperty_.Get_IsReadOnly: WordBool;
begin
    Result := DefaultInterface.IsReadOnly;
end;

function TProperty_.Get_IsVector: WordBool;
begin
    Result := DefaultInterface.IsVector;
end;

function TProperty_.Get_SubType: WiaSubType;
begin
    Result := DefaultInterface.SubType;
end;

function TProperty_.Get_SubTypeDefault: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.SubTypeDefault;
end;

function TProperty_.Get_SubTypeValues: IVector;
begin
    Result := DefaultInterface.SubTypeValues;
end;

function TProperty_.Get_SubTypeMin: Integer;
begin
    Result := DefaultInterface.SubTypeMin;
end;

function TProperty_.Get_SubTypeMax: Integer;
begin
    Result := DefaultInterface.SubTypeMax;
end;

function TProperty_.Get_SubTypeStep: Integer;
begin
    Result := DefaultInterface.SubTypeStep;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TProperty_Properties.Create(AServer: TProperty_);
begin
  inherited Create;
  FServer := AServer;
end;

function TProperty_Properties.GetDefaultInterface: IProperty;
begin
  Result := FServer.DefaultInterface;
end;

function TProperty_Properties.Get_Value: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Value;
end;

procedure TProperty_Properties.Set_Value(var pvResult: OleVariant);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pvResult;
end;

procedure TProperty_Properties._Set_Value(var pvResult: OleVariant);
  { Warning: The property Value has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Value := pvResult;
end;

function TProperty_Properties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TProperty_Properties.Get_PropertyID: Integer;
begin
    Result := DefaultInterface.PropertyID;
end;

function TProperty_Properties.Get_type_: Integer;
begin
    Result := DefaultInterface.type_;
end;

function TProperty_Properties.Get_IsReadOnly: WordBool;
begin
    Result := DefaultInterface.IsReadOnly;
end;

function TProperty_Properties.Get_IsVector: WordBool;
begin
    Result := DefaultInterface.IsVector;
end;

function TProperty_Properties.Get_SubType: WiaSubType;
begin
    Result := DefaultInterface.SubType;
end;

function TProperty_Properties.Get_SubTypeDefault: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.SubTypeDefault;
end;

function TProperty_Properties.Get_SubTypeValues: IVector;
begin
    Result := DefaultInterface.SubTypeValues;
end;

function TProperty_Properties.Get_SubTypeMin: Integer;
begin
    Result := DefaultInterface.SubTypeMin;
end;

function TProperty_Properties.Get_SubTypeMax: Integer;
begin
    Result := DefaultInterface.SubTypeMax;
end;

function TProperty_Properties.Get_SubTypeStep: Integer;
begin
    Result := DefaultInterface.SubTypeStep;
end;

{$ENDIF}

class function CoProperties.Create: IProperties;
begin
  Result := CreateComObject(CLASS_Properties) as IProperties;
end;

class function CoProperties.CreateRemote(const MachineName: string): IProperties;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Properties) as IProperties;
end;

procedure TProperties.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{96F887FC-08B1-4F97-A69C-75280C6A9CF8}';
    IntfIID:   '{40571E58-A308-470A-80AA-FA10F88793A0}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TProperties.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IProperties;
  end;
end;

procedure TProperties.ConnectTo(svrIntf: IProperties);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TProperties.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TProperties.GetDefaultInterface: IProperties;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TProperties.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TPropertiesProperties.Create(Self);
{$ENDIF}
end;

destructor TProperties.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TProperties.GetServerProperties: TPropertiesProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TProperties.Get_Item(var Index: OleVariant): IProperty;
begin
    Result := DefaultInterface.Item[Index];
end;

function TProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

function TProperties.Exists(var Index: OleVariant): WordBool;
begin
  Result := DefaultInterface.Exists(Index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TPropertiesProperties.Create(AServer: TProperties);
begin
  inherited Create;
  FServer := AServer;
end;

function TPropertiesProperties.GetDefaultInterface: IProperties;
begin
  Result := FServer.DefaultInterface;
end;

function TPropertiesProperties.Get_Item(var Index: OleVariant): IProperty;
begin
    Result := DefaultInterface.Item[Index];
end;

function TPropertiesProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoImageFile.Create: IImageFile;
begin
  Result := CreateComObject(CLASS_ImageFile) as IImageFile;
end;

class function CoImageFile.CreateRemote(const MachineName: string): IImageFile;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ImageFile) as IImageFile;
end;

procedure TImageFile.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{A2E6DDA0-06EF-4DF3-B7BD-5AA224BB06E8}';
    IntfIID:   '{F4243B65-3F63-4D99-93CD-86B6D62C5EB2}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TImageFile.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IImageFile;
  end;
end;

procedure TImageFile.ConnectTo(svrIntf: IImageFile);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TImageFile.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TImageFile.GetDefaultInterface: IImageFile;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TImageFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TImageFileProperties.Create(Self);
{$ENDIF}
end;

destructor TImageFile.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TImageFile.GetServerProperties: TImageFileProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TImageFile.Get_FormatID: WideString;
begin
    Result := DefaultInterface.FormatID;
end;

function TImageFile.Get_FileExtension: WideString;
begin
    Result := DefaultInterface.FileExtension;
end;

function TImageFile.Get_FileData: IVector;
begin
    Result := DefaultInterface.FileData;
end;

function TImageFile.Get_ARGBData: IVector;
begin
    Result := DefaultInterface.ARGBData;
end;

function TImageFile.Get_Height: Integer;
begin
    Result := DefaultInterface.Height;
end;

function TImageFile.Get_Width: Integer;
begin
    Result := DefaultInterface.Width;
end;

function TImageFile.Get_HorizontalResolution: Double;
begin
    Result := DefaultInterface.HorizontalResolution;
end;

function TImageFile.Get_VerticalResolution: Double;
begin
    Result := DefaultInterface.VerticalResolution;
end;

function TImageFile.Get_PixelDepth: Integer;
begin
    Result := DefaultInterface.PixelDepth;
end;

function TImageFile.Get_IsIndexedPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsIndexedPixelFormat;
end;

function TImageFile.Get_IsAlphaPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsAlphaPixelFormat;
end;

function TImageFile.Get_IsExtendedPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsExtendedPixelFormat;
end;

function TImageFile.Get_IsAnimated: WordBool;
begin
    Result := DefaultInterface.IsAnimated;
end;

function TImageFile.Get_FrameCount: Integer;
begin
    Result := DefaultInterface.FrameCount;
end;

function TImageFile.Get_ActiveFrame: Integer;
begin
    Result := DefaultInterface.ActiveFrame;
end;

procedure TImageFile.Set_ActiveFrame(plResult: Integer);
begin
  DefaultInterface.Set_ActiveFrame(plResult);
end;

function TImageFile.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

procedure TImageFile.LoadFile(const Filename: WideString);
begin
  DefaultInterface.LoadFile(Filename);
end;

procedure TImageFile.SaveFile(const Filename: WideString);
begin
  DefaultInterface.SaveFile(Filename);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TImageFileProperties.Create(AServer: TImageFile);
begin
  inherited Create;
  FServer := AServer;
end;

function TImageFileProperties.GetDefaultInterface: IImageFile;
begin
  Result := FServer.DefaultInterface;
end;

function TImageFileProperties.Get_FormatID: WideString;
begin
    Result := DefaultInterface.FormatID;
end;

function TImageFileProperties.Get_FileExtension: WideString;
begin
    Result := DefaultInterface.FileExtension;
end;

function TImageFileProperties.Get_FileData: IVector;
begin
    Result := DefaultInterface.FileData;
end;

function TImageFileProperties.Get_ARGBData: IVector;
begin
    Result := DefaultInterface.ARGBData;
end;

function TImageFileProperties.Get_Height: Integer;
begin
    Result := DefaultInterface.Height;
end;

function TImageFileProperties.Get_Width: Integer;
begin
    Result := DefaultInterface.Width;
end;

function TImageFileProperties.Get_HorizontalResolution: Double;
begin
    Result := DefaultInterface.HorizontalResolution;
end;

function TImageFileProperties.Get_VerticalResolution: Double;
begin
    Result := DefaultInterface.VerticalResolution;
end;

function TImageFileProperties.Get_PixelDepth: Integer;
begin
    Result := DefaultInterface.PixelDepth;
end;

function TImageFileProperties.Get_IsIndexedPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsIndexedPixelFormat;
end;

function TImageFileProperties.Get_IsAlphaPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsAlphaPixelFormat;
end;

function TImageFileProperties.Get_IsExtendedPixelFormat: WordBool;
begin
    Result := DefaultInterface.IsExtendedPixelFormat;
end;

function TImageFileProperties.Get_IsAnimated: WordBool;
begin
    Result := DefaultInterface.IsAnimated;
end;

function TImageFileProperties.Get_FrameCount: Integer;
begin
    Result := DefaultInterface.FrameCount;
end;

function TImageFileProperties.Get_ActiveFrame: Integer;
begin
    Result := DefaultInterface.ActiveFrame;
end;

procedure TImageFileProperties.Set_ActiveFrame(plResult: Integer);
begin
  DefaultInterface.Set_ActiveFrame(plResult);
end;

function TImageFileProperties.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

{$ENDIF}

class function CoFilterInfo.Create: IFilterInfo;
begin
  Result := CreateComObject(CLASS_FilterInfo) as IFilterInfo;
end;

class function CoFilterInfo.CreateRemote(const MachineName: string): IFilterInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FilterInfo) as IFilterInfo;
end;

procedure TFilterInfo.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{318D6B52-9B1C-4E3B-8D90-1F0E857FA9B0}';
    IntfIID:   '{EFD1219F-8229-4B30-809D-8F6D83341569}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFilterInfo.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFilterInfo;
  end;
end;

procedure TFilterInfo.ConnectTo(svrIntf: IFilterInfo);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFilterInfo.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFilterInfo.GetDefaultInterface: IFilterInfo;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFilterInfo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFilterInfoProperties.Create(Self);
{$ENDIF}
end;

destructor TFilterInfo.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFilterInfo.GetServerProperties: TFilterInfoProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFilterInfo.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TFilterInfo.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TFilterInfo.Get_FilterID: WideString;
begin
    Result := DefaultInterface.FilterID;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFilterInfoProperties.Create(AServer: TFilterInfo);
begin
  inherited Create;
  FServer := AServer;
end;

function TFilterInfoProperties.GetDefaultInterface: IFilterInfo;
begin
  Result := FServer.DefaultInterface;
end;

function TFilterInfoProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TFilterInfoProperties.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TFilterInfoProperties.Get_FilterID: WideString;
begin
    Result := DefaultInterface.FilterID;
end;

{$ENDIF}

class function CoFilterInfos.Create: IFilterInfos;
begin
  Result := CreateComObject(CLASS_FilterInfos) as IFilterInfos;
end;

class function CoFilterInfos.CreateRemote(const MachineName: string): IFilterInfos;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FilterInfos) as IFilterInfos;
end;

procedure TFilterInfos.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{56FA88D3-F3DA-4DE3-94E8-811040C3CCD4}';
    IntfIID:   '{AF49723A-499C-411C-B19A-1B8244D67E44}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFilterInfos.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFilterInfos;
  end;
end;

procedure TFilterInfos.ConnectTo(svrIntf: IFilterInfos);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFilterInfos.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFilterInfos.GetDefaultInterface: IFilterInfos;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFilterInfos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFilterInfosProperties.Create(Self);
{$ENDIF}
end;

destructor TFilterInfos.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFilterInfos.GetServerProperties: TFilterInfosProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFilterInfos.Get_Item(var Index: OleVariant): IFilterInfo;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFilterInfos.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFilterInfosProperties.Create(AServer: TFilterInfos);
begin
  inherited Create;
  FServer := AServer;
end;

function TFilterInfosProperties.GetDefaultInterface: IFilterInfos;
begin
  Result := FServer.DefaultInterface;
end;

function TFilterInfosProperties.Get_Item(var Index: OleVariant): IFilterInfo;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFilterInfosProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoFilter.Create: IFilter;
begin
  Result := CreateComObject(CLASS_Filter) as IFilter;
end;

class function CoFilter.CreateRemote(const MachineName: string): IFilter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Filter) as IFilter;
end;

procedure TFilter.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{52AD8A74-F064-4F4C-8544-FF494D349F7B}';
    IntfIID:   '{851E9802-B338-4AB3-BB6B-6AA57CC699D0}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFilter.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFilter;
  end;
end;

procedure TFilter.ConnectTo(svrIntf: IFilter);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFilter.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFilter.GetDefaultInterface: IFilter;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFilterProperties.Create(Self);
{$ENDIF}
end;

destructor TFilter.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFilter.GetServerProperties: TFilterProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFilter.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TFilter.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TFilter.Get_FilterID: WideString;
begin
    Result := DefaultInterface.FilterID;
end;

function TFilter.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFilterProperties.Create(AServer: TFilter);
begin
  inherited Create;
  FServer := AServer;
end;

function TFilterProperties.GetDefaultInterface: IFilter;
begin
  Result := FServer.DefaultInterface;
end;

function TFilterProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TFilterProperties.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

function TFilterProperties.Get_FilterID: WideString;
begin
    Result := DefaultInterface.FilterID;
end;

function TFilterProperties.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

{$ENDIF}

class function CoFilters.Create: IFilters;
begin
  Result := CreateComObject(CLASS_Filters) as IFilters;
end;

class function CoFilters.CreateRemote(const MachineName: string): IFilters;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Filters) as IFilters;
end;

procedure TFilters.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{31CDD60C-C04C-424D-95FC-36A52646D71C}';
    IntfIID:   '{C82FFED4-0A8D-4F85-B90A-AC8E720D39C1}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFilters.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFilters;
  end;
end;

procedure TFilters.ConnectTo(svrIntf: IFilters);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFilters.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFilters.GetDefaultInterface: IFilters;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFilters.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFiltersProperties.Create(Self);
{$ENDIF}
end;

destructor TFilters.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFilters.GetServerProperties: TFiltersProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFilters.Get_Item(Index: Integer): IFilter;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFilters.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

procedure TFilters.Add(const FilterID: WideString; Index: Integer);
begin
  DefaultInterface.Add(FilterID, Index);
end;

procedure TFilters.Remove(Index: Integer);
begin
  DefaultInterface.Remove(Index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFiltersProperties.Create(AServer: TFilters);
begin
  inherited Create;
  FServer := AServer;
end;

function TFiltersProperties.GetDefaultInterface: IFilters;
begin
  Result := FServer.DefaultInterface;
end;

function TFiltersProperties.Get_Item(Index: Integer): IFilter;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFiltersProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoImageProcess.Create: IImageProcess;
begin
  Result := CreateComObject(CLASS_ImageProcess) as IImageProcess;
end;

class function CoImageProcess.CreateRemote(const MachineName: string): IImageProcess;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ImageProcess) as IImageProcess;
end;

procedure TImageProcess.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{BD0D38E4-74C8-4904-9B5A-269F8E9994E9}';
    IntfIID:   '{41506929-7855-4392-9E6F-98D88513E55D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TImageProcess.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IImageProcess;
  end;
end;

procedure TImageProcess.ConnectTo(svrIntf: IImageProcess);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TImageProcess.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TImageProcess.GetDefaultInterface: IImageProcess;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TImageProcess.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TImageProcessProperties.Create(Self);
{$ENDIF}
end;

destructor TImageProcess.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TImageProcess.GetServerProperties: TImageProcessProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TImageProcess.Get_FilterInfos: IFilterInfos;
begin
    Result := DefaultInterface.FilterInfos;
end;

function TImageProcess.Get_Filters: IFilters;
begin
    Result := DefaultInterface.Filters;
end;

function TImageProcess.Apply(const Source: IImageFile): IImageFile;
begin
  Result := DefaultInterface.Apply(Source);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TImageProcessProperties.Create(AServer: TImageProcess);
begin
  inherited Create;
  FServer := AServer;
end;

function TImageProcessProperties.GetDefaultInterface: IImageProcess;
begin
  Result := FServer.DefaultInterface;
end;

function TImageProcessProperties.Get_FilterInfos: IFilterInfos;
begin
    Result := DefaultInterface.FilterInfos;
end;

function TImageProcessProperties.Get_Filters: IFilters;
begin
    Result := DefaultInterface.Filters;
end;

{$ENDIF}

class function CoFormats.Create: IFormats;
begin
  Result := CreateComObject(CLASS_Formats) as IFormats;
end;

class function CoFormats.CreateRemote(const MachineName: string): IFormats;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Formats) as IFormats;
end;

procedure TFormats.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{6F62E261-0FE6-476B-A244-50CF7440DDEB}';
    IntfIID:   '{882A274F-DF2F-4F6D-9F5A-AF4FD484530D}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFormats.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFormats;
  end;
end;

procedure TFormats.ConnectTo(svrIntf: IFormats);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFormats.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFormats.GetDefaultInterface: IFormats;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TFormats.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFormatsProperties.Create(Self);
{$ENDIF}
end;

destructor TFormats.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFormats.GetServerProperties: TFormatsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFormats.Get_Item(Index: Integer): WideString;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFormats.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFormatsProperties.Create(AServer: TFormats);
begin
  inherited Create;
  FServer := AServer;
end;

function TFormatsProperties.GetDefaultInterface: IFormats;
begin
  Result := FServer.DefaultInterface;
end;

function TFormatsProperties.Get_Item(Index: Integer): WideString;
begin
    Result := DefaultInterface.Item[Index];
end;

function TFormatsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoDeviceCommand.Create: IDeviceCommand;
begin
  Result := CreateComObject(CLASS_DeviceCommand) as IDeviceCommand;
end;

class function CoDeviceCommand.CreateRemote(const MachineName: string): IDeviceCommand;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceCommand) as IDeviceCommand;
end;

procedure TDeviceCommand.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{72226184-AFBB-4059-BF55-0F6C076E669D}';
    IntfIID:   '{7CF694C0-F589-451C-B56E-398B5855B05E}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceCommand.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceCommand;
  end;
end;

procedure TDeviceCommand.ConnectTo(svrIntf: IDeviceCommand);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceCommand.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceCommand.GetDefaultInterface: IDeviceCommand;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceCommand.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceCommandProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceCommand.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceCommand.GetServerProperties: TDeviceCommandProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceCommand.Get_CommandID: WideString;
begin
    Result := DefaultInterface.CommandID;
end;

function TDeviceCommand.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TDeviceCommand.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceCommandProperties.Create(AServer: TDeviceCommand);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceCommandProperties.GetDefaultInterface: IDeviceCommand;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceCommandProperties.Get_CommandID: WideString;
begin
    Result := DefaultInterface.CommandID;
end;

function TDeviceCommandProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TDeviceCommandProperties.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

{$ENDIF}

class function CoDeviceCommands.Create: IDeviceCommands;
begin
  Result := CreateComObject(CLASS_DeviceCommands) as IDeviceCommands;
end;

class function CoDeviceCommands.CreateRemote(const MachineName: string): IDeviceCommands;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceCommands) as IDeviceCommands;
end;

procedure TDeviceCommands.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{25B047DB-4AAD-4FC2-A0BE-31DDA687FF32}';
    IntfIID:   '{C53AE9D5-6D91-4815-AF93-5F1E1B3B08BD}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceCommands.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceCommands;
  end;
end;

procedure TDeviceCommands.ConnectTo(svrIntf: IDeviceCommands);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceCommands.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceCommands.GetDefaultInterface: IDeviceCommands;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceCommands.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceCommandsProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceCommands.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceCommands.GetServerProperties: TDeviceCommandsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceCommands.Get_Item(Index: Integer): IDeviceCommand;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceCommands.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceCommandsProperties.Create(AServer: TDeviceCommands);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceCommandsProperties.GetDefaultInterface: IDeviceCommands;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceCommandsProperties.Get_Item(Index: Integer): IDeviceCommand;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceCommandsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoItem.Create: IItem;
begin
  Result := CreateComObject(CLASS_Item) as IItem;
end;

class function CoItem.CreateRemote(const MachineName: string): IItem;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Item) as IItem;
end;

procedure TItem.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{36F479F3-C258-426E-B5FA-2793DCFDA881}';
    IntfIID:   '{68F2BF12-A755-4E2B-9BCD-37A22587D078}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TItem.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IItem;
  end;
end;

procedure TItem.ConnectTo(svrIntf: IItem);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TItem.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TItem.GetDefaultInterface: IItem;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TItemProperties.Create(Self);
{$ENDIF}
end;

destructor TItem.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TItem.GetServerProperties: TItemProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TItem.Get_ItemID: WideString;
begin
    Result := DefaultInterface.ItemID;
end;

function TItem.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

function TItem.Get_Items: IItems;
begin
    Result := DefaultInterface.Items;
end;

function TItem.Get_Formats: IFormats;
begin
    Result := DefaultInterface.Formats;
end;

function TItem.Get_Commands: IDeviceCommands;
begin
    Result := DefaultInterface.Commands;
end;

function TItem.Get_WiaItem: IUnknown;
begin
    Result := DefaultInterface.WiaItem;
end;

function TItem.Transfer(const FormatID: WideString): OleVariant;
begin
  Result := DefaultInterface.Transfer(FormatID);
end;

function TItem.ExecuteCommand(const CommandID: WideString): IItem;
begin
  Result := DefaultInterface.ExecuteCommand(CommandID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TItemProperties.Create(AServer: TItem);
begin
  inherited Create;
  FServer := AServer;
end;

function TItemProperties.GetDefaultInterface: IItem;
begin
  Result := FServer.DefaultInterface;
end;

function TItemProperties.Get_ItemID: WideString;
begin
    Result := DefaultInterface.ItemID;
end;

function TItemProperties.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

function TItemProperties.Get_Items: IItems;
begin
    Result := DefaultInterface.Items;
end;

function TItemProperties.Get_Formats: IFormats;
begin
    Result := DefaultInterface.Formats;
end;

function TItemProperties.Get_Commands: IDeviceCommands;
begin
    Result := DefaultInterface.Commands;
end;

function TItemProperties.Get_WiaItem: IUnknown;
begin
    Result := DefaultInterface.WiaItem;
end;

{$ENDIF}

class function CoItems.Create: IItems;
begin
  Result := CreateComObject(CLASS_Items) as IItems;
end;

class function CoItems.CreateRemote(const MachineName: string): IItems;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Items) as IItems;
end;

procedure TItems.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B243B765-CA9C-4F30-A457-C8B2B57A585E}';
    IntfIID:   '{46102071-60B4-4E58-8620-397D17B0BB5B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TItems.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IItems;
  end;
end;

procedure TItems.ConnectTo(svrIntf: IItems);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TItems.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TItems.GetDefaultInterface: IItems;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TItems.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TItemsProperties.Create(Self);
{$ENDIF}
end;

destructor TItems.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TItems.GetServerProperties: TItemsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TItems.Get_Item(Index: Integer): IItem;
begin
    Result := DefaultInterface.Item[Index];
end;

function TItems.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

procedure TItems.Add(const Name: WideString; Flags: Integer);
begin
  DefaultInterface.Add(Name, Flags);
end;

procedure TItems.Remove(Index: Integer);
begin
  DefaultInterface.Remove(Index);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TItemsProperties.Create(AServer: TItems);
begin
  inherited Create;
  FServer := AServer;
end;

function TItemsProperties.GetDefaultInterface: IItems;
begin
  Result := FServer.DefaultInterface;
end;

function TItemsProperties.Get_Item(Index: Integer): IItem;
begin
    Result := DefaultInterface.Item[Index];
end;

function TItemsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoDeviceEvent.Create: IDeviceEvent;
begin
  Result := CreateComObject(CLASS_DeviceEvent) as IDeviceEvent;
end;

class function CoDeviceEvent.CreateRemote(const MachineName: string): IDeviceEvent;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceEvent) as IDeviceEvent;
end;

procedure TDeviceEvent.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{617CF892-783C-43D3-B04B-F0F1DE3B326D}';
    IntfIID:   '{80D0880A-BB10-4722-82D1-07DC8DA157E2}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceEvent.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceEvent;
  end;
end;

procedure TDeviceEvent.ConnectTo(svrIntf: IDeviceEvent);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceEvent.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceEvent.GetDefaultInterface: IDeviceEvent;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceEvent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceEventProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceEvent.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceEvent.GetServerProperties: TDeviceEventProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceEvent.Get_EventID: WideString;
begin
    Result := DefaultInterface.EventID;
end;

function TDeviceEvent.Get_type_: WiaEventFlag;
begin
    Result := DefaultInterface.type_;
end;

function TDeviceEvent.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TDeviceEvent.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceEventProperties.Create(AServer: TDeviceEvent);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceEventProperties.GetDefaultInterface: IDeviceEvent;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceEventProperties.Get_EventID: WideString;
begin
    Result := DefaultInterface.EventID;
end;

function TDeviceEventProperties.Get_type_: WiaEventFlag;
begin
    Result := DefaultInterface.type_;
end;

function TDeviceEventProperties.Get_Name: WideString;
begin
    Result := DefaultInterface.Name;
end;

function TDeviceEventProperties.Get_Description: WideString;
begin
    Result := DefaultInterface.Description;
end;

{$ENDIF}

class function CoDeviceEvents.Create: IDeviceEvents;
begin
  Result := CreateComObject(CLASS_DeviceEvents) as IDeviceEvents;
end;

class function CoDeviceEvents.CreateRemote(const MachineName: string): IDeviceEvents;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceEvents) as IDeviceEvents;
end;

procedure TDeviceEvents.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3563A59A-BBCD-4C86-94A0-92136C80A8B4}';
    IntfIID:   '{03985C95-581B-44D1-9403-8488B347538B}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceEvents.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceEvents;
  end;
end;

procedure TDeviceEvents.ConnectTo(svrIntf: IDeviceEvents);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceEvents.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceEvents.GetDefaultInterface: IDeviceEvents;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceEvents.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceEventsProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceEvents.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceEvents.GetServerProperties: TDeviceEventsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceEvents.Get_Item(Index: Integer): IDeviceEvent;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceEvents.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceEventsProperties.Create(AServer: TDeviceEvents);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceEventsProperties.GetDefaultInterface: IDeviceEvents;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceEventsProperties.Get_Item(Index: Integer): IDeviceEvent;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceEventsProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoDeviceInfo.Create: IDeviceInfo;
begin
  Result := CreateComObject(CLASS_DeviceInfo) as IDeviceInfo;
end;

class function CoDeviceInfo.CreateRemote(const MachineName: string): IDeviceInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceInfo) as IDeviceInfo;
end;

procedure TDeviceInfo.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{F09CFB7A-E561-4625-9BB5-208BCA0DE09F}';
    IntfIID:   '{2A99020A-E325-4454-95E0-136726ED4818}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceInfo.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceInfo;
  end;
end;

procedure TDeviceInfo.ConnectTo(svrIntf: IDeviceInfo);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceInfo.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceInfo.GetDefaultInterface: IDeviceInfo;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceInfo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceInfoProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceInfo.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceInfo.GetServerProperties: TDeviceInfoProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceInfo.Get_DeviceID: WideString;
begin
    Result := DefaultInterface.DeviceID;
end;

function TDeviceInfo.Get_type_: WiaDeviceType;
begin
    Result := DefaultInterface.type_;
end;

function TDeviceInfo.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

function TDeviceInfo.Connect1: IDevice;
begin
  Result := DefaultInterface.Connect;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceInfoProperties.Create(AServer: TDeviceInfo);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceInfoProperties.GetDefaultInterface: IDeviceInfo;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceInfoProperties.Get_DeviceID: WideString;
begin
    Result := DefaultInterface.DeviceID;
end;

function TDeviceInfoProperties.Get_type_: WiaDeviceType;
begin
    Result := DefaultInterface.type_;
end;

function TDeviceInfoProperties.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

{$ENDIF}

class function CoDeviceInfos.Create: IDeviceInfos;
begin
  Result := CreateComObject(CLASS_DeviceInfos) as IDeviceInfos;
end;

class function CoDeviceInfos.CreateRemote(const MachineName: string): IDeviceInfos;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceInfos) as IDeviceInfos;
end;

procedure TDeviceInfos.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{2DFEE16B-E4AC-4A19-B660-AE71A745D34F}';
    IntfIID:   '{FE076B64-8406-4E92-9CAC-9093F378E05F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceInfos.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDeviceInfos;
  end;
end;

procedure TDeviceInfos.ConnectTo(svrIntf: IDeviceInfos);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDeviceInfos.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDeviceInfos.GetDefaultInterface: IDeviceInfos;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceInfos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceInfosProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceInfos.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceInfos.GetServerProperties: TDeviceInfosProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDeviceInfos.Get_Item(var Index: OleVariant): IDeviceInfo;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceInfos.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceInfosProperties.Create(AServer: TDeviceInfos);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceInfosProperties.GetDefaultInterface: IDeviceInfos;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceInfosProperties.Get_Item(var Index: OleVariant): IDeviceInfo;
begin
    Result := DefaultInterface.Item[Index];
end;

function TDeviceInfosProperties.Get_Count: Integer;
begin
    Result := DefaultInterface.Count;
end;

{$ENDIF}

class function CoDevice.Create: IDevice;
begin
  Result := CreateComObject(CLASS_Device) as IDevice;
end;

class function CoDevice.CreateRemote(const MachineName: string): IDevice;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Device) as IDevice;
end;

procedure TDevice.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{DBAA8843-B1C4-4EDC-B7E0-D6F61162BE58}';
    IntfIID:   '{3714EAC4-F413-426B-B1E8-DEF2BE99EA55}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDevice.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDevice;
  end;
end;

procedure TDevice.ConnectTo(svrIntf: IDevice);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TDevice.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TDevice.GetDefaultInterface: IDevice;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDevice.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceProperties.Create(Self);
{$ENDIF}
end;

destructor TDevice.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDevice.GetServerProperties: TDeviceProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TDevice.Get_DeviceID: WideString;
begin
    Result := DefaultInterface.DeviceID;
end;

function TDevice.Get_type_: WiaDeviceType;
begin
    Result := DefaultInterface.type_;
end;

function TDevice.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

function TDevice.Get_Items: IItems;
begin
    Result := DefaultInterface.Items;
end;

function TDevice.Get_Commands: IDeviceCommands;
begin
    Result := DefaultInterface.Commands;
end;

function TDevice.Get_Events: IDeviceEvents;
begin
    Result := DefaultInterface.Events;
end;

function TDevice.Get_WiaItem: IUnknown;
begin
    Result := DefaultInterface.WiaItem;
end;

function TDevice.GetItem(const ItemID: WideString): IItem;
begin
  Result := DefaultInterface.GetItem(ItemID);
end;

function TDevice.ExecuteCommand(const CommandID: WideString): IItem;
begin
  Result := DefaultInterface.ExecuteCommand(CommandID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceProperties.Create(AServer: TDevice);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceProperties.GetDefaultInterface: IDevice;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceProperties.Get_DeviceID: WideString;
begin
    Result := DefaultInterface.DeviceID;
end;

function TDeviceProperties.Get_type_: WiaDeviceType;
begin
    Result := DefaultInterface.type_;
end;

function TDeviceProperties.Get_Properties: IProperties;
begin
    Result := DefaultInterface.Properties;
end;

function TDeviceProperties.Get_Items: IItems;
begin
    Result := DefaultInterface.Items;
end;

function TDeviceProperties.Get_Commands: IDeviceCommands;
begin
    Result := DefaultInterface.Commands;
end;

function TDeviceProperties.Get_Events: IDeviceEvents;
begin
    Result := DefaultInterface.Events;
end;

function TDeviceProperties.Get_WiaItem: IUnknown;
begin
    Result := DefaultInterface.WiaItem;
end;

{$ENDIF}

class function CoCommonDialog.Create: ICommonDialog;
begin
  Result := CreateComObject(CLASS_CommonDialog) as ICommonDialog;
end;

class function CoCommonDialog.CreateRemote(const MachineName: string): ICommonDialog;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CommonDialog) as ICommonDialog;
end;

procedure TCommonDialog.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{850D1D11-70F3-4BE5-9A11-77AA6B2BB201}';
    IntfIID:   '{B4760F13-D9F3-4DF8-94B5-D225F86EE9A1}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCommonDialog.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ICommonDialog;
  end;
end;

procedure TCommonDialog.ConnectTo(svrIntf: ICommonDialog);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCommonDialog.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCommonDialog.GetDefaultInterface: ICommonDialog;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TCommonDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCommonDialogProperties.Create(Self);
{$ENDIF}
end;

destructor TCommonDialog.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCommonDialog.GetServerProperties: TCommonDialogProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TCommonDialog.ShowAcquisitionWizard(const Device: IDevice): OleVariant;
begin
  Result := DefaultInterface.ShowAcquisitionWizard(Device);
end;

function TCommonDialog.ShowAcquireImage(DeviceType: WiaDeviceType; Intent: WiaImageIntent; 
                                        Bias: WiaImageBias; const FormatID: WideString; 
                                        AlwaysSelectDevice: WordBool; UseCommonUI: WordBool; 
                                        CancelError: WordBool): IImageFile;
begin
  Result := DefaultInterface.ShowAcquireImage(DeviceType, Intent, Bias, FormatID, 
                                              AlwaysSelectDevice, UseCommonUI, CancelError);
end;

function TCommonDialog.ShowSelectDevice(DeviceType: WiaDeviceType; AlwaysSelectDevice: WordBool; 
                                        CancelError: WordBool): IDevice;
begin
  Result := DefaultInterface.ShowSelectDevice(DeviceType, AlwaysSelectDevice, CancelError);
end;

function TCommonDialog.ShowSelectItems(const Device: IDevice; Intent: WiaImageIntent; 
                                       Bias: WiaImageBias; SingleSelect: WordBool; 
                                       UseCommonUI: WordBool; CancelError: WordBool): IItems;
begin
  Result := DefaultInterface.ShowSelectItems(Device, Intent, Bias, SingleSelect, UseCommonUI, 
                                             CancelError);
end;

procedure TCommonDialog.ShowDeviceProperties(const Device: IDevice; CancelError: WordBool);
begin
  DefaultInterface.ShowDeviceProperties(Device, CancelError);
end;

procedure TCommonDialog.ShowItemProperties(const Item: IItem; CancelError: WordBool);
begin
  DefaultInterface.ShowItemProperties(Item, CancelError);
end;

function TCommonDialog.ShowTransfer(const Item: IItem; const FormatID: WideString; 
                                    CancelError: WordBool): OleVariant;
begin
  Result := DefaultInterface.ShowTransfer(Item, FormatID, CancelError);
end;

procedure TCommonDialog.ShowPhotoPrintingWizard(var Files: OleVariant);
begin
  DefaultInterface.ShowPhotoPrintingWizard(Files);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCommonDialogProperties.Create(AServer: TCommonDialog);
begin
  inherited Create;
  FServer := AServer;
end;

function TCommonDialogProperties.GetDefaultInterface: ICommonDialog;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoDeviceManager.Create: IDeviceManager;
begin
  Result := CreateComObject(CLASS_DeviceManager) as IDeviceManager;
end;

class function CoDeviceManager.CreateRemote(const MachineName: string): IDeviceManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DeviceManager) as IDeviceManager;
end;

procedure TDeviceManager.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{E1C5D730-7E97-4D8A-9E42-BBAE87C2059F}';
    IntfIID:   '{73856D9A-2720-487A-A584-21D5774E9D0F}';
    EventIID:  '{2E9A5206-2360-49DF-9D9B-1762B4BEAE77}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDeviceManager.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDeviceManager;
  end;
end;

procedure TDeviceManager.ConnectTo(svrIntf: IDeviceManager);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TDeviceManager.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TDeviceManager.GetDefaultInterface: IDeviceManager;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TDeviceManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDeviceManagerProperties.Create(Self);
{$ENDIF}
end;

destructor TDeviceManager.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDeviceManager.GetServerProperties: TDeviceManagerProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TDeviceManager.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnEvent) then
         FOnEvent(Self,
                  Params[0] {const WideString},
                  Params[1] {const WideString},
                  Params[2] {const WideString});
  end; {case DispID}
end;

function TDeviceManager.Get_DeviceInfos: IDeviceInfos;
begin
    Result := DefaultInterface.DeviceInfos;
end;

procedure TDeviceManager.RegisterEvent(const EventID: WideString; const DeviceID: WideString);
begin
  DefaultInterface.RegisterEvent(EventID, DeviceID);
end;

procedure TDeviceManager.UnregisterEvent(const EventID: WideString; const DeviceID: WideString);
begin
  DefaultInterface.UnregisterEvent(EventID, DeviceID);
end;

procedure TDeviceManager.RegisterPersistentEvent(const Command: WideString; const Name: WideString; 
                                                 const Description: WideString; 
                                                 const Icon: WideString; const EventID: WideString; 
                                                 const DeviceID: WideString);
begin
  DefaultInterface.RegisterPersistentEvent(Command, Name, Description, Icon, EventID, DeviceID);
end;

procedure TDeviceManager.UnregisterPersistentEvent(const Command: WideString; 
                                                   const Name: WideString; 
                                                   const Description: WideString; 
                                                   const Icon: WideString; 
                                                   const EventID: WideString; 
                                                   const DeviceID: WideString);
begin
  DefaultInterface.UnregisterPersistentEvent(Command, Name, Description, Icon, EventID, DeviceID);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDeviceManagerProperties.Create(AServer: TDeviceManager);
begin
  inherited Create;
  FServer := AServer;
end;

function TDeviceManagerProperties.GetDefaultInterface: IDeviceManager;
begin
  Result := FServer.DefaultInterface;
end;

function TDeviceManagerProperties.Get_DeviceInfos: IDeviceInfos;
begin
    Result := DefaultInterface.DeviceInfos;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TRational, TVector, TProperty_, TProperties, 
    TImageFile, TFilterInfo, TFilterInfos, TFilter, TFilters, 
    TImageProcess, TFormats, TDeviceCommand, TDeviceCommands, TItem, 
    TItems, TDeviceEvent, TDeviceEvents, TDeviceInfo, TDeviceInfos, 
    TDevice, TCommonDialog, TDeviceManager]);
end;

end.
