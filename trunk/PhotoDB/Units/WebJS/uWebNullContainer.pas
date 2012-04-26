{
  This demo application accompanies the article
  "How to call Delphi code from scripts running in a TWebBrowser" at
  http://www.delphidabbler.com/articles?article=22.

  This unit provides a do-nothing implementation of a web browser OLE container
  object

  This code is copyright (c) P D Johnson (www.delphidabbler.com), 2005-2006.

  v1.0 of 2005/05/09 - original version named UBaseUIHandler.pas
  v2.0 of 2006/02/11 - total rewrite based on unit of same name from article at
                       http://www.delphidabbler.com/articles?article=22
}

{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARN UNSAFE_TYPE OFF}

unit uWebNullContainer;

interface


uses
  Windows,
  ActiveX,
  SHDocVw,
  IntfDocHostUIHandler,
  Winapi.UrlMon;

type

  TWebNullWBContainer = class(TObject, IUnknown, IOleClientSite, IDocHostUIHandler, IServiceProvider, IInternetSecurityManager)
  private
    FHostedBrowser: TWebBrowser;
    // Registration method
    procedure SetBrowserOleClientSite(const Site: IOleClientSite);
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IOleClientSite }
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint;
      dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(
      out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    { IDocHostUIHandler }
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HResult;
      stdcall;
    function GetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
    function ShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HResult; stdcall;
    function HideUI: HResult; stdcall;
    function UpdateUI: HResult; stdcall;
    function EnableModeless(const fEnable: BOOL): HResult; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HResult; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
      stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HResult; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD ): HResult;
      stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HResult; stdcall;
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HResult; stdcall;

    //IServiceProvider
    function QueryService(const rsid, iid: TGuid; out Obj): HResult; stdcall;

    //IInternetSecurityManager
    function SetSecuritySite(Site: IInternetSecurityMgrSite): HResult; stdcall;
    function GetSecuritySite(out Site: IInternetSecurityMgrSite): HResult; stdcall;
    function MapUrlToZone(pwszUrl: LPCWSTR; out dwZone: DWORD;
      dwFlags: DWORD): HResult; stdcall;
    function GetSecurityId(pwszUrl: LPCWSTR; pbSecurityId: Pointer;
      var cbSecurityId: DWORD; dwReserved: DWORD): HResult; stdcall;
    function ProcessUrlAction(pwszUrl: LPCWSTR; dwAction: DWORD;
      pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
      dwFlags, dwReserved: DWORD): HResult; stdcall;
    function QueryCustomPolicy(pwszUrl: LPCWSTR; const guidKey: TGUID;
      out pPolicy: Pointer; out cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
      dwReserved: DWORD): HResult; stdcall;
    function SetZoneMapping(dwZone: DWORD; lpszPattern: LPCWSTR;
      dwFlags: DWORD): HResult; stdcall;
    function GetZoneMappings(dwZone: DWORD; out enumString: IEnumString;
      dwFlags: DWORD): HResult; stdcall;

  public
    constructor Create(const HostedBrowser: TWebBrowser);
    destructor Destroy; override;
    property HostedBrowser: TWebBrowser read fHostedBrowser;
  end;

implementation

uses
  SysUtils;

{ TNulWBContainer }

constructor TWebNullWBContainer.Create(const HostedBrowser: TWebBrowser);
begin
  Assert(Assigned(HostedBrowser));
  inherited Create;
  fHostedBrowser := HostedBrowser;
  SetBrowserOleClientSite(Self as IOleClientSite);
end;

destructor TWebNullWBContainer.Destroy;
begin
  SetBrowserOleClientSite(nil);
  inherited;
end;

function TWebNullWBContainer.EnableModeless(const fEnable: BOOL): HResult;
begin
  { Return S_OK to indicate we handled (ignored) OK }
  Result := S_OK;
end;

function TWebNullWBContainer.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HResult;
begin
  { Return S_FALSE to show no data object supplied.
    We *must* also set ppDORet to nil }
  ppDORet := nil;
  Result := S_FALSE;
end;

function TWebNullWBContainer.GetContainer(
  out container: IOleContainer): HResult;
  {Returns a pointer to the container's IOleContainer
  interface}
begin
  { We do not support IOleContainer.
    However we *must* set container to nil }
  container := nil;
  Result := E_NOINTERFACE;
end;

function TWebNullWBContainer.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
begin
  { Return E_FAIL since no alternative drop target supplied.
    We *must* also set ppDropTarget to nil }
  ppDropTarget := nil;
  Result := E_FAIL;
end;

function TWebNullWBContainer.GetExternal(out ppDispatch: IDispatch): HResult;
begin
  { Return E_FAIL to indicate we failed to supply external object.
    We *must* also set ppDispatch to nil }
  ppDispatch := nil;
  Result := E_FAIL;
end;

function TWebNullWBContainer.GetHostInfo(var pInfo: TDocHostUIInfo): HResult;
begin
  { Return S_OK to indicate UI is OK without changes }
  try
    // Clear structure and set size
    ZeroMemory(@pInfo, SizeOf(TDocHostUIInfo));
    pInfo.cbSize := SizeOf(TDocHostUIInfo);
    // Set scroll bar visibility
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_SCROLL_NO;
    // Set border visibility
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
    // Decide if text can be selected
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_DIALOG;
    // Ensure browser uses themes if application is doing
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME;

    // Return S_OK to indicate we've made changes
    Result := S_OK;
  except
    // Return E_FAIL on error
    Result := E_FAIL;
  end;
end;

function TWebNullWBContainer.GetMoniker(dwAssign, dwWhichMoniker: Integer;
  out mk: IMoniker): HResult;
  {Returns a moniker to an object's client site}
begin
  { We don't support monikers.
    However we *must* set mk to nil }
  mk := nil;
  Result := E_NOTIMPL;
end;

function TWebNullWBContainer.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HResult;
begin
  { Return E_FAIL to indicate we failed to override
    default registry settings }
  Result := E_FAIL;
end;

function TWebNullWBContainer.HideUI: HResult;
begin
  { Return S_OK to indicate we handled (ignored) OK }
  Result := S_OK;
end;

function TWebNullWBContainer.OnDocWindowActivate(
  const fActivate: BOOL): HResult;
begin
  { Return S_OK to indicate we handled (ignored) OK }
  Result := S_OK;
end;

function TWebNullWBContainer.OnFrameWindowActivate(
  const fActivate: BOOL): HResult;
begin
  { Return S_OK to indicate we handled (ignored) OK }
  Result := S_OK;
end;

function TWebNullWBContainer.OnShowWindow(fShow: BOOL): HResult;
  {Notifies a container when an embedded object's window
  is about to become visible or invisible}
begin
  { Return S_OK to pretend we've responded to this }
  Result := S_OK;
end;

function TWebNullWBContainer.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TWebNullWBContainer.QueryService(const rsid, iid: TGuid;
  out Obj): HResult;
const
  IID_InternetSecurityManager: TGUID = '{79eac9ee-baf9-11ce-8c82-00aa004ba90b}';
begin
  if IsEqualGuid(IID_InternetSecurityManager, rsid) and IsEqualGuid(rsid, iid) then
     Result := Self.Queryinterface(IInternetSecurityManager, Obj)
   else
     Result := E_NOINTERFACE;
end;

function TWebNullWBContainer.RequestNewObjectLayout: HResult;
  {Asks container to allocate more or less space for
  displaying an embedded object}
begin
  { We don't support requests for a new layout }
  Result := E_NOTIMPL;
end;

function TWebNullWBContainer.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
begin
  { Return S_FALSE to indicate we did nothing in response }
  Result := S_FALSE;
end;

function TWebNullWBContainer.SaveObject: HResult;
  {Saves the object associated with the client site}
begin
  { Return S_OK to pretend we've done this }
  Result := S_OK;
end;

procedure TWebNullWBContainer.SetBrowserOleClientSite(
  const Site: IOleClientSite);
var
  OleObj: IOleObject;
begin
  Assert((Site = Self as IOleClientSite) or (Site = nil));
  if not Supports(
    fHostedBrowser.DefaultInterface, IOleObject, OleObj
  ) then
    raise Exception.Create(
      'Browser''s Default interface does not support IOleObject'
    );
  OleObj.SetClientSite(Site);
end;

function TWebNullWBContainer.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HResult;
begin
  { Return S_FALSE to notify we didn't display a menu and to
  let browser display its own menu }
  Result := S_OK;
end;

function TWebNullWBContainer.ShowObject: HResult;
  {Tells the container to position the object so it is
  visible to the user}
begin
  { Return S_OK to pretend we've done this }
  Result := S_OK;
end;

function TWebNullWBContainer.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HResult;
begin
  { Return S_OK to say we displayed own UI }
  Result := S_OK;
end;

function TWebNullWBContainer.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
begin
  { Return S_FALSE to indicate no accelerators are translated }
  Result := S_FALSE;
end;

function TWebNullWBContainer.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HResult;
begin
  { Return E_FAIL to indicate that no translations took place }
  Result := E_FAIL;
end;

function TWebNullWBContainer.UpdateUI: HResult;
begin
  { Return S_OK to indicate we handled (ignored) OK }
  Result := S_OK;
end;

function TWebNullWBContainer._AddRef: Integer;
begin
  Result := -1;
end;

function TWebNullWBContainer._Release: Integer;
begin
  Result := -1;
end;

function TWebNullWBContainer.GetSecurityId(pwszUrl: LPCWSTR;
  pbSecurityId: Pointer; var cbSecurityId: DWORD; dwReserved: DWORD): HResult;
begin
  Result := INET_E_DEFAULT_ACTION;
end;

function TWebNullWBContainer.GetSecuritySite(
  out Site: IInternetSecurityMgrSite): HResult;
begin
  Result := INET_E_DEFAULT_ACTION;
end;

function TWebNullWBContainer.GetZoneMappings(dwZone: DWORD;
  out enumString: IEnumString; dwFlags: DWORD): HResult;
begin
  Result := INET_E_DEFAULT_ACTION;
end;

function TWebNullWBContainer.MapUrlToZone(pwszUrl: LPCWSTR; out dwZone: DWORD;
  dwFlags: DWORD): HResult;
begin
  dwZone := 2; //Trusted
  Result := S_OK;
end;

function TWebNullWBContainer.ProcessUrlAction(pwszUrl: LPCWSTR; dwAction: DWORD;
  pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext, dwFlags,
  dwReserved: DWORD): HResult;
begin
  Result := S_OK;
  Dword(pPolicy^) := URLPOLICY_ALLOW;
end;

function TWebNullWBContainer.QueryCustomPolicy(pwszUrl: LPCWSTR;
  const guidKey: TGUID; out pPolicy: Pointer; out cbPolicy: DWORD;
  pContext: Pointer; cbContext, dwReserved: DWORD): HResult;
begin
  Result := S_OK;
  Dword(pPolicy^) := URLPOLICY_ALLOW;
end;

function TWebNullWBContainer.SetSecuritySite(
  Site: IInternetSecurityMgrSite): HResult;
begin
  Result := INET_E_DEFAULT_ACTION;
end;

function TWebNullWBContainer.SetZoneMapping(dwZone: DWORD; lpszPattern: LPCWSTR;
  dwFlags: DWORD): HResult;
begin
  Result := INET_E_DEFAULT_ACTION;
end;

end.
