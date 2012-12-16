unit uInternetProxy;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.SyncObjs,
  Generics.Collections,
  idHTTP,
  uMemory,
  uSettings;

type
  HINTERNET = Pointer;
  INTERNET_PORT = Word;

  PWinHTTPProxyInfo = ^TWinHTTPProxyInfo;
  WINHTTP_PROXY_INFO = record
    dwAccessType: DWORD;
    lpszProxy: LPWSTR;
    lpszProxyBypass: LPWSTR;
  end;
  TWinHTTPProxyInfo = WINHTTP_PROXY_INFO;
  LPWINHTTP_PROXY_INFO = PWinHTTPProxyInfo;

  PWinHTTPAutoProxyOptions = ^TWinHTTPAutoProxyOptions;
  WINHTTP_AUTOPROXY_OPTIONS = record
    dwFlags: DWORD;
    dwAutoDetectFlags: DWORD;
    lpszAutoConfigUrl: LPCWSTR;
    lpvReserved: Pointer;
    dwReserved: DWORD;
    fAutoLogonIfChallenged: BOOL;
  end;
  TWinHTTPAutoProxyOptions = WINHTTP_AUTOPROXY_OPTIONS;
  LPWINHTTP_AUTOPROXY_OPTIONS = PWinHTTPAutoProxyOptions;

  PWinHTTPCurrentUserIEProxyConfig = ^TWinHTTPCurrentUserIEProxyConfig;
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG = record
    fAutoDetect: BOOL;
    lpszAutoConfigUrl: LPWSTR;
    lpszProxy: LPWSTR;
    lpszProxyBypass: LPWSTR;
  end;
  TWinHTTPCurrentUserIEProxyConfig = WINHTTP_CURRENT_USER_IE_PROXY_CONFIG;
  LPWINHTTP_CURRENT_USER_IE_PROXY_CONFIG = PWinHTTPCurrentUserIEProxyConfig;

  function WinHttpOpen(pwszUserAgent: LPCWSTR; dwAccessType: DWORD;
    pwszProxyName, pwszProxyBypass: LPCWSTR; dwFlags: DWORD): HINTERNET; stdcall;
    external 'winhttp.dll' name 'WinHttpOpen' delayed;
  function WinHttpConnect(hSession: HINTERNET; pswzServerName: LPCWSTR;
    nServerPort: INTERNET_PORT; dwReserved: DWORD): HINTERNET; stdcall;
    external 'winhttp.dll' name 'WinHttpConnect' delayed;
  function WinHttpOpenRequest(hConnect: HINTERNET; pwszVerb: LPCWSTR;
    pwszObjectName: LPCWSTR; pwszVersion: LPCWSTR; pwszReferer: LPCWSTR;
    ppwszAcceptTypes: PLPWSTR; dwFlags: DWORD): HINTERNET; stdcall;
    external 'winhttp.dll' name 'WinHttpOpenRequest' delayed;
  function WinHttpQueryOption(hInet: HINTERNET; dwOption: DWORD;
    lpBuffer: Pointer; var lpdwBufferLength: DWORD): BOOL; stdcall;
    external 'winhttp.dll' name 'WinHttpQueryOption' delayed;
  function WinHttpGetProxyForUrl(hSession: HINTERNET; lpcwszUrl: LPCWSTR;
    pAutoProxyOptions: LPWINHTTP_AUTOPROXY_OPTIONS;
    var pProxyInfo: WINHTTP_PROXY_INFO): BOOL; stdcall;
    external 'winhttp.dll' name 'WinHttpGetProxyForUrl' delayed;
  function WinHttpGetIEProxyConfigForCurrentUser(
    var pProxyInfo: WINHTTP_CURRENT_USER_IE_PROXY_CONFIG): BOOL; stdcall;
    external 'winhttp.dll' name 'WinHttpGetIEProxyConfigForCurrentUser' delayed;
  function WinHttpCloseHandle(hInternet: HINTERNET): BOOL; stdcall;
    external 'winhttp.dll' name 'WinHttpCloseHandle' delayed;

type
  TProxyInfo = record
    ProxyURL: WideString;
    ProxyBypass: WideString;
    ProxyAutoDetected: Boolean;
  end;

const
  WINHTTP_NO_REFERER = nil;
  {$EXTERNALSYM WINHTTP_NO_REFERER}
  WINHTTP_NO_PROXY_NAME = nil;
  {$EXTERNALSYM WINHTTP_NO_PROXY_NAME}
  WINHTTP_NO_PROXY_BYPASS = nil;
  {$EXTERNALSYM WINHTTP_NO_PROXY_BYPASS}
  WINHTTP_DEFAULT_ACCEPT_TYPES = nil;
  {$EXTERNALSYM WINHTTP_DEFAULT_ACCEPT_TYPES}
  WINHTTP_ACCESS_TYPE_DEFAULT_PROXY = 0;
  {$EXTERNALSYM WINHTTP_ACCESS_TYPE_DEFAULT_PROXY}
  WINHTTP_ACCESS_TYPE_NO_PROXY = 1;
  {$EXTERNALSYM WINHTTP_ACCESS_TYPE_NO_PROXY}
  WINHTTP_OPTION_PROXY = 38;
  {$EXTERNALSYM WINHTTP_OPTION_PROXY}
  WINHTTP_OPTION_PROXY_USERNAME = $1002;
  {$EXTERNALSYM WINHTTP_OPTION_PROXY_USERNAME}
  WINHTTP_OPTION_PROXY_PASSWORD = $1003;
  {$EXTERNALSYM WINHTTP_OPTION_PROXY_PASSWORD}
  WINHTTP_AUTOPROXY_AUTO_DETECT = $00000001;
  {$EXTERNALSYM WINHTTP_AUTOPROXY_AUTO_DETECT}
  WINHTTP_AUTOPROXY_CONFIG_URL = $00000002;
  {$EXTERNALSYM WINHTTP_AUTOPROXY_CONFIG_URL}
  WINHTTP_AUTO_DETECT_TYPE_DHCP = $00000001;
  {$EXTERNALSYM WINHTTP_AUTO_DETECT_TYPE_DHCP}
  WINHTTP_AUTO_DETECT_TYPE_DNS_A = $00000002;
  {$EXTERNALSYM WINHTTP_AUTO_DETECT_TYPE_DNS_A}
  WINHTTP_FLAG_BYPASS_PROXY_CACHE = $00000100;
  {$EXTERNALSYM WINHTTP_FLAG_BYPASS_PROXY_CACHE}
  WINHTTP_FLAG_REFRESH = WINHTTP_FLAG_BYPASS_PROXY_CACHE;
  {$EXTERNALSYM WINHTTP_FLAG_REFRESH}

procedure ConfigureIdHttpProxy(HTTP: TIdHTTP; RequestUrl: string);
function IsProxyServerUsed(RequestUrl: string): Boolean;
procedure ClearProxyCache;

implementation

var
  FSync: TCriticalSection = nil;
  FProxyList: TDictionary<string, TProxyInfo> = nil;

procedure InitProxyCache;
begin
  if FSync = nil then
    FSync := TCriticalSection.Create;

  if FProxyList = nil then
    FProxyList := TDictionary<string, TProxyInfo>.Create;
end;

procedure ClearProxyCache;
begin
  InitProxyCache;
  FProxyList.Clear;
end;

function GetProxyInfo(const AURL: WideString; var AProxyInfo: TProxyInfo): DWORD;
var
  Session: HINTERNET;
  AutoDetectProxy: Boolean;
  WinHttpProxyInfo: TWinHTTPProxyInfo;
  AutoProxyOptions: TWinHTTPAutoProxyOptions;
  IEProxyConfig: TWinHTTPCurrentUserIEProxyConfig;
begin
  // initialize the result
  Result := 0;

  if not Settings.ReadBool('Options', 'UseProxyServer', False) then
    Exit;

  // initialize auto-detection to off
  AutoDetectProxy := False;
  // initialize the result structure
  AProxyInfo.ProxyURL := '';
  AProxyInfo.ProxyBypass := '';
  AProxyInfo.ProxyAutoDetected := False;
  // initialize the auto-proxy options
  FillChar(AutoProxyOptions, SizeOf(AutoProxyOptions), 0);

  // check if the Internet Explorer's proxy configuration is
  // available and if so, check its settings for auto-detect
  // proxy settings and auto-config script URL options
  if WinHttpGetIEProxyConfigForCurrentUser(IEProxyConfig) then
  begin
    // if the Internet Explorer is configured to auto-detect
    // proxy settings then we try to detect them later on
    if IEProxyConfig.fAutoDetect then
    begin
      AutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_AUTO_DETECT;
      AutoProxyOptions.dwAutoDetectFlags := WINHTTP_AUTO_DETECT_TYPE_DHCP or
        WINHTTP_AUTO_DETECT_TYPE_DNS_A;
      AutoDetectProxy := True;
    end;
    // if the Internet Explorer is configured to use the proxy
    // auto-config script then we try to use it
    if IEProxyConfig.lpszAutoConfigURL <> '' then
    begin
      AutoProxyOptions.dwFlags := AutoProxyOptions.dwFlags or
        WINHTTP_AUTOPROXY_CONFIG_URL;
      AutoProxyOptions.lpszAutoConfigUrl := IEProxyConfig.lpszAutoConfigUrl;
      AutoDetectProxy := True;
    end;
    // if IE don't have auto-detect or auto-config set, we are
    // done here and we can fill the AProxyInfo with the IE settings
    if not AutoDetectProxy then
    begin
      AProxyInfo.ProxyURL := IEProxyConfig.lpszProxy;
      AProxyInfo.ProxyBypass := IEProxyConfig.lpszProxyBypass;
      AProxyInfo.ProxyAutoDetected := False;
    end;
  end else
  begin
    // if the Internet Explorer's proxy configuration is not
    // available, then try to auto-detect it
    AutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_AUTO_DETECT;
    AutoProxyOptions.dwAutoDetectFlags := WINHTTP_AUTO_DETECT_TYPE_DHCP or
      WINHTTP_AUTO_DETECT_TYPE_DNS_A;
    AutoDetectProxy := True;
  end;

  // if the IE proxy settings are not available or IE has
  // configured auto-config script or auto-detect proxy settings
  if AutoDetectProxy then
  begin
    // create a temporary WinHttp session to allow the WinHTTP
    // auto-detect proxy settings if possible
    Session := WinHttpOpen(nil, WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
      WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);

    // if the WinHttp session has been created then try to
    // get the proxy data for the specified URL else we assign
    // the last error code to the function result
    if Assigned(Session) then
    try
      // get the proxy data for the specified URL with the
      // auto-proxy options specified, if succeed then we can
      // fill the AProxyInfo with the retrieved settings else
      // we assign the last error code to the function result
      if WinHttpGetProxyForUrl(Session, LPCWSTR(AURL),
        @AutoProxyOptions, WinHttpProxyInfo) then
      begin
        AProxyInfo.ProxyURL := WinHttpProxyInfo.lpszProxy;
        AProxyInfo.ProxyBypass := WinHttpProxyInfo.lpszProxyBypass;
        AProxyInfo.ProxyAutoDetected := True;
      end
      else
        Result := GetLastError;
    finally
      WinHttpCloseHandle(Session);
    end
    else
      Result := GetLastError;
  end;
end;

function GetHostName(url: string): string;
var
  P: Integer;
begin
  P := LastDelimiter(':', url);
  if P <= 1 then
    Exit(url);

  Result := Copy(url, 1, P - 1);
end;

function GetHostPort(url: string): Integer;
var
  P: Integer;
  Port: string;
begin
  P := LastDelimiter(':', url);
  if (P <= 1) and (P < Length(url)) then
    Exit(80);

  Port := Copy(url, P + 1, Length(url) - P);
  Result := StrToIntDef(Port, 80);
end;

function IsProxyServerUsed(RequestUrl: string): Boolean;
var
  Res: DWORD;
  ProxyInfo: TProxyInfo;
begin
  Result := False;
  FSync.Enter;
  try

    if FProxyList.ContainsKey(RequestUrl) then
    begin
      ProxyInfo := FProxyList[RequestUrl];
      if ProxyInfo.ProxyURL <> '' then
        Result := GetHostName(ProxyInfo.ProxyURL) <> '';
      Exit;
    end;

    Res := GetProxyInfo(RequestUrl, ProxyInfo);
    case Res of
      0:
        Result := GetHostName(ProxyInfo.ProxyURL) <> '';
    end;

    FProxyList.Add(RequestUrl, ProxyInfo);
  finally
    FSync.Leave;
  end;
end;

procedure ConfigureIdHttpProxy(HTTP: TIdHTTP; RequestUrl: string);
var
  Result: DWORD;
  ProxyInfo: TProxyInfo;
begin
  InitProxyCache;

  FSync.Enter;
  try
    if FProxyList.ContainsKey(RequestUrl) then
    begin
      ProxyInfo := FProxyList[RequestUrl];
      if ProxyInfo.ProxyURL <> '' then
      begin
        HTTP.ProxyParams.ProxyServer := GetHostName(ProxyInfo.ProxyURL);
        HTTP.ProxyParams.ProxyPort := GetHostPort(ProxyInfo.ProxyURL);
        HTTP.ProxyParams.ProxyUsername := Settings.ReadString('Options', 'ProxyUser');
        HTTP.ProxyParams.ProxyPassword := Settings.ReadString('Options', 'ProxyPassword');
      end;
      Exit;
    end;

    Result := GetProxyInfo(RequestUrl, ProxyInfo);
    case Result of
      0:
      begin
        HTTP.ProxyParams.ProxyServer := GetHostName(ProxyInfo.ProxyURL);
        HTTP.ProxyParams.ProxyPort := GetHostPort(ProxyInfo.ProxyURL);
        HTTP.ProxyParams.ProxyUsername := Settings.ReadString('Options', 'ProxyUser');
        HTTP.ProxyParams.ProxyPassword := Settings.ReadString('Options', 'ProxyPassword');
      end;
      //12166, //ShowMessage('Error in proxy auto-config script code');
      //12167, //ShowMessage('Unable to download proxy auto-config script');
      //12180: //ShowMessage('WPAD detection failed');
    else
    end;
    FProxyList.Add(RequestUrl, ProxyInfo);
  finally
    FSync.Leave;
  end;
end;

initialization

finalization
  F(FSync);

end.
