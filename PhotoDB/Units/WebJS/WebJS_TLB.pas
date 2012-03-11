unit WebJS_TLB;

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

// $Rev: 41960 $
// File generated on 10.03.2012 23:47:16 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Users\dolphin.HOME\Desktop\CallBack\WebJS (1)
// LIBID: {517F7078-5E73-4E5A-B8A2-8F0FF14EF21B}
// LCID: 0
// Helpfile:
// HelpString: WebJS Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WebJSMajorVersion = 1;
  WebJSMinorVersion = 0;

  LIBID_WebJS: TGUID = '{517F7078-5E73-4E5A-B8A2-8F0FF14EF21B}';

  IID_IWebJSExternal: TGUID = '{4F995D09-CF9E-4042-993E-C71A8AED661E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IWebJSExternal = interface;
  IWebJSExternalDisp = dispinterface;

// *********************************************************************//
// Interface: IWebJSExternal
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4F995D09-CF9E-4042-993E-C71A8AED661E}
// *********************************************************************//
  IWebJSExternal = interface(IDispatch)
    ['{4F995D09-CF9E-4042-993E-C71A8AED661E}']
    function SaveLocation(Lat: Double; Lng: Double; const FileName: WideString): Shortint; safecall;
    procedure ZoomPan(Lat: Double; Lng: Double; Zoom: SYSINT); safecall;
    procedure UpdateEmbed; safecall;
    procedure MapStarted; safecall;
  end;

// *********************************************************************//
// DispIntf:  IWebJSExternalDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {4F995D09-CF9E-4042-993E-C71A8AED661E}
// *********************************************************************//
  IWebJSExternalDisp = dispinterface
    ['{4F995D09-CF9E-4042-993E-C71A8AED661E}']
    function SaveLocation(Lat: Double; Lng: Double; const FileName: WideString): Shortint; dispid 201;
    procedure ZoomPan(Lat: Double; Lng: Double; Zoom: SYSINT); dispid 202;
    procedure UpdateEmbed; dispid 203;
    procedure MapStarted; dispid 204;
  end;

implementation

uses ComObj;

end.

