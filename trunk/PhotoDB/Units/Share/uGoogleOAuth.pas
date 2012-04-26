unit uGoogleOAuth;

interface

uses
  SysUtils,
  Classes,
  Character,
  idHTTP,
  IdSSLOpenSSL,
  IdException,
  idUri,
  uInternetUtils,
  uTranslate,
  uInternetProxy,
  IdComponent;

resourcestring
  rsRequestError = 'Request error: %d - %s';
  rsUnknownError = 'Unknown error';

const
  /// <summary>
  /// MIME-тип тела запроса, используемый по умолчанию для работы с мета-данными
  /// </summary>
  DefaultMime = 'application/json; charset=UTF-8';

type
  TOnInternetProgress = procedure(Sender: TObject; Max, Position: Int64) of object;

  /// <summary>
  /// Компонент для авторизации в сервисах Google по протоколу OAuth и
  /// выполнения основных HTTP-запросов: GET, POST, PUT и DELETE к ресурсам API
  /// </summary>
  TOAuth = class(TObject)
  private type
    TMethodType = (tmGET, tmPOST, tmPUT, tmDELETE);
  private
    FClientID: string;
    FClientSecret: string;
    FScope: string;
    FResponseCode: string;
    FAccess_token: string;
    FExpires_in: string;
    FRefresh_token: string;
    FSlug: AnsiString;
    FWorkMax: Int64;
    FWorkPosition: Int64;
    FOnProgress: TOnInternetProgress;
    function HTTPMethod(AURL: string; AMethod: TMethodType; AParams: TStrings;
      ABody: TStream; AMime: string = DefaultMime): string;
    procedure SetClientID(const Value: string);
    procedure SetResponseCode(const Value: string);
    procedure SetScope(const Value: string);
    function ParamValue(ParamName, JSONString: string): string;
    procedure SetClientSecret(Value: string);
    function PrepareParams(Params: TStrings): string;
    procedure WorkBeginEvent(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure WorkEndEvent(ASender: TObject; AWorkMode: TWorkMode);
    procedure WorkEvent(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Формирует URL для получения ResponseCode. Полученный URL необходимо
    /// предоставить пользователю либо использовать в TWebBrowser для перехода
    /// на URL с кодом.
    /// </summary>
    /// <returns>
    /// <param name="String">
    /// Строка URL для получения кода доступа.
    /// </param>
    /// </returns>
    function AccessURL: string;
    /// <summary>
    /// Выполнение запроса на получения ключа доступа к ресурсам API.
    /// </summary>
    /// <returns>
    /// <param name="String">
    /// Строка, содержащая ключ доступа к ресурсам API.
    /// Это значение необходимо использовать в заголовке <para>Authorization: OAuth</para>
    /// всех HTTP-запросов
    /// </param>
    /// </returns>
    function GetAccessToken: string;
    /// <summary>
    /// Выполнение запроса на обновление ключа доступа к ресурсам API.
    /// </summary>
    /// <returns>
    /// <param name="String">
    /// Строка, содержащая ключ доступа к ресурсам API.
    /// Это значение необходимо использовать в заголовке <para>Authorization: OAuth</para>
    /// всех HTTP-запросов
    /// </param>
    /// </returns>
    function RefreshToken: string;
    /// <summary>
    /// Выполнение GET-запроса к ресурсу API.
    /// </summary>
    /// <returns>
    /// <param name="RawBytestring">
    /// Строка, результат выполнения запроса.
    /// </param>
    /// </returns>    /// <param name="URL">
    /// String. URL ресурса
    /// </param>
    /// <param name="Params">
    /// TStrings. Параметры запроса.
    /// </param>
    function GETCommand(URL: string; Params: TStrings): string;
    /// <summary>
    /// Выполнение POST-запроса к ресурсу API.
    /// </summary>
    /// <returns>
    /// <param name="RawBytestring">
    /// СÑ?рокÐ?, реÐ?уÐ?ьÑ?Ð?Ñ? вÑ?поÐ?нения Ð?Ð?просÐ?.
    /// </param>
    /// </returns>    /// <param name="URL">
    /// String. URL ресурсÐ?
    /// </param>
    /// <param name="Params">
    /// TStrings. ПÐ?рÐ?меÑ?рÑ? Ð?Ð?просÐ?.
    /// </param>
    /// <param name="Body">
    /// TStream. ПоÑ?ок, содерÐ?Ð?Ñ?иÐ? Ñ?еÐ?о Ð?Ð?просÐ?.
    /// </param>
    /// <param name="Mime">
    /// String. MIME-Ñ?ип Ñ?еÐ?Ð? Ð?Ð?просÐ?. Ð?сÐ?и оÑ?прÐ?вÐ?яеÑ?ся сÑ?рокÐ? в Ñ?ормÐ?Ñ?е JSON,
    /// Ñ?о эÑ?оÑ? пÐ?рÐ?меÑ?р моÐ?но не укÐ?Ð?Ñ?вÐ?Ñ?ь
    /// </param>
    function POSTCommand(URL: string; Params: TStrings; Body: TStream; Mime: string = DefaultMime): string;
    /// <summary>
    /// Ð?Ñ?поÐ?нение PUT-Ð?Ð?просÐ? к ресурсу API.
    /// </summary>
    /// <returns>
    /// <param name="RawBytestring">
    /// СÑ?рокÐ?, реÐ?уÐ?ьÑ?Ð?Ñ? вÑ?поÐ?нения Ð?Ð?просÐ?.
    /// </param>
    /// </returns>
    /// <param name="URL">
    /// String. URL ресурсÐ?
    /// </param>
    /// <param name="Body">
    /// TStream. ПоÑ?ок, содерÐ?Ð?Ñ?иÐ? Ñ?еÐ?о Ð?Ð?просÐ?.
    /// </param>
    /// <param name="Mime">
    /// String. MIME-Ñ?ип Ñ?еÐ?Ð? Ð?Ð?просÐ?. Ð?сÐ?и оÑ?прÐ?вÐ?яеÑ?ся сÑ?рокÐ? в Ñ?ормÐ?Ñ?е JSON,
    /// Ñ?о эÑ?оÑ? пÐ?рÐ?меÑ?р моÐ?но не укÐ?Ð?Ñ?вÐ?Ñ?ь
    /// </param>
    function PUTCommand(URL: string; Body: TStream; Mime: string = DefaultMime): string;
    /// <summary>
    /// Ð?Ñ?поÐ?нение DELETE-Ð?Ð?просÐ? к ресурсу API.
    /// </summary>
    /// <param name="URL">
    /// String. URL ресурсÐ?
    /// </param>
    procedure DELETECommand(URL: string);
    /// <summary>
    /// КÐ?юÑ? досÑ?упÐ? к ресусÐ?м API (Ñ?окен). СвоÐ?сÑ?во Ñ?оÐ?ько дÐ?я Ñ?Ñ?ения.
    /// </summary>
    property Access_token: string read FAccess_token write FAccess_token;
    /// <summary>
    /// Ð?ремя в секундÐ?Ñ? посÐ?е коÑ?орого неоÐ?Ñ?одимо провесÑ?и оÐ?новÐ?ение Ñ?окенÐ?.
    /// </summary>
    property Expires_in: string read FExpires_in;
    /// <summary>
    /// КÐ?юÑ? дÐ?я оÐ?новÐ?ения основного Ñ?окенÐ?.
    /// </summary>
    property Refresh_token: string read FRefresh_token write FRefresh_token;
    /// <summary>
    /// Код досÑ?упÐ?, поÐ?уÑ?еннÑ?Ð? поÐ?ьÐ?овÐ?Ñ?еÐ?ем при переÑ?оде по URL, поÐ?уÑ?енному
    /// с помоÑ?ью меÑ?одÐ? AccessURL.
    /// </summary>
    property ResponseCode: string read FResponseCode write SetResponseCode;
    /// <summary>
    /// Ð?денÑ?иÑ?икÐ?Ñ?ор кÐ?иенÑ?Ð? API. Ð?Ñ?о Ð?нÐ?Ñ?ение неоÐ?Ñ?одимо Ð?Ð?рÐ?нее сгенерировÐ?Ñ?ь,
    /// испоÐ?ьÐ?уя консоÐ?ь Google API (https://code.google.com/apis/console)
    /// </summary>
    property ClientID: string read FClientID write SetClientID;
    /// <summary>
    /// ТоÑ?кÐ? досÑ?упÐ? к API. Ð?нÐ?Ñ?ение эÑ?ого пÐ?рÐ?меÑ?рÐ? Ð?Ð?висиÑ? оÑ? Ñ?ого API, к коÑ?орому
    /// неоÐ?Ñ?одимо поÐ?уÑ?иÑ?ь досÑ?уп. ТоÑ?ку досÑ?упÐ? моÐ?но уÐ?нÐ?Ñ?ь иÐ? оÑ?иÑ?иÐ?Ð?ьноÐ? докуменÑ?Ð?Ñ?ии к API
    /// </summary>
    property Scope: string read FScope write SetScope;
    /// <summary>
    /// СекреÑ?нÑ?Ð? кÐ?юÑ? кÐ?иенÑ?Ð?. Ð?Ñ?о Ð?нÐ?Ñ?ение неоÐ?Ñ?одимо Ð?Ð?рÐ?нее сгенерировÐ?Ñ?ь,
    /// испоÐ?ьÐ?уя консоÐ?ь Google API (https://code.google.com/apis/console)
    /// </summary>
    property ClientSecret: string read FClientSecret write SetClientSecret;
    property Slug: AnsiString read FSlug write FSlug;
    property OnProgress: TOnInternetProgress read FOnProgress write FOnProgress;
  end;

implementation

const
  redirect_uri = 'urn:ietf:wg:oauth:2.0:oob';
  oauth_url = 'https://accounts.google.com/o/oauth2/auth?client_id=%s&redirect_uri=%s&scope=%s&response_type=code';
  tokenurl = 'https://accounts.google.com/o/oauth2/token';
  tokenparams =  'client_id=%s&client_secret=%s&code=%s&redirect_uri=%s&grant_type=authorization_code';
  crefreshtoken = 'client_id=%s&client_secret=%s&refresh_token=%s&grant_type=refresh_token';
  AuthHeader = 'Authorization: OAuth %s';
  StripChars: set of AnsiChar = ['"', ':', ',', #$A, ' '];

  { TOAuth }

function TOAuth.AccessURL: string;
begin
  Result := Format(oauth_url, [ClientID, redirect_uri, Scope]) + '&hl=' + TTranslateManager.Instance.Language;;
end;

constructor TOAuth.Create;
begin
  inherited;
  FOnProgress := nil;
  FSlug := '';
end;

procedure TOAuth.DELETECommand(URL: string);
begin
  HTTPMethod(URL, tmDELETE, nil, nil);
end;

destructor TOAuth.Destroy;
begin
  inherited;
end;

function TOAuth.GetAccessToken: string;
var
  Params: TStringStream;
  Response: string;
begin
  Params := TStringStream.Create(Format(tokenparams, [ClientID, ClientSecret,
    ResponseCode, redirect_uri]));
  try
    Response := POSTCommand(tokenurl, nil, Params, 'application/x-www-form-urlencoded');
    FAccess_token := ParamValue('access_token', Response);
    FExpires_in := ParamValue('expires_in', Response);
    FRefresh_token := ParamValue('refresh_token', Response);
    Result := Access_token;
  finally
    Params.Free;
  end;
end;

function TOAuth.GETCommand(URL: string; Params: TStrings): string;
begin
  Result := HTTPMethod(URL, tmGET, Params, nil);
end;

function TOAuth.HTTPMethod(AURL: string; AMethod: TMethodType;
  AParams: TStrings; ABody: TStream; AMime: string): string;
var
  Response: TStringStream;
  ParamString: string;
  FHTTP: TIdHTTP;
  FSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  FHTTP := TIdHTTP.Create(nil);
  FSSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FHTTP.IOHandler := FSSLIOHandler;
  FHTTP.ConnectTimeout := cConnectionTimeout;
  FHTTP.ReadTimeout := 0;
  FHTTP.OnWorkBegin := WorkBeginEvent;
  FHTTP.OnWorkEnd := WorkEndEvent;
  FHTTP.OnWork := WorkEvent;
  ConfigureIdHttpProxy(FHTTP, 'https://google.com');
  try

    if Assigned(AParams) and (AParams.Count > 0) then
      ParamString := PrepareParams(AParams);

    Response := TStringStream.Create;
    try
      FHTTP.Request.CustomHeaders.Clear;
      FHTTP.Request.CustomHeaders.Add(Format(AuthHeader, [Access_token]));
      FHTTP.Request.CustomHeaders.Add('GData-Version: 2');
      if FSlug <> '' then
      begin
        FHTTP.Request.CustomHeaders.Add('Slug: ' + string(FSlug));
        FSlug := '';
      end;

      case AMethod of
        tmGET:
          begin
            FHTTP.Get(AURL + ParamString, Response);
          end;
        tmPOST:
          begin
            FHTTP.Request.ContentType := AMime;
            FHTTP.Post(AURL + ParamString, ABody, Response);
          end;
        tmPUT:
          begin
            FHTTP.Request.ContentType := AMime;
            FHTTP.Put(AURL, ABody, Response);
          end;
        tmDELETE:
          begin
            FHTTP.Delete(AURL);
          end;
      end;
      if AMethod <> tmDELETE then
        Result := Response.DataString;

    finally
      Response.Free
    end;
  finally
    FSSLIOHandler.Free;
    FHTTP.Free;
  end;
end;

function TOAuth.ParamValue(ParamName, JSONString: string): string;
var
  I, J: Integer;
begin
  I := pos(ParamName, JSONString);
  if I > 0 then
  begin
    for J := I + Length(ParamName) to Length(JSONString) - 1 do
      if not CharInSet(JSONString[J], StripChars) then
        Result := Result + JSONString[J]
      else if JSONString[J] = ',' then
        break;
  end
  else
    Result := '';
end;

function TOAuth.POSTCommand(URL: string; Params: TStrings; Body: TStream;
  Mime: string): string;
begin
  Result := HTTPMethod(URL, tmPOST, Params, Body, Mime);
end;

function TOAuth.PrepareParams(Params: TStrings): string;
var
  S: string;
begin
  if Assigned(Params) then
    if Params.Count > 0 then
    begin
      for S in Params do
        Result := Result + TIdURI.URLEncode(S) + '&';
      Delete(Result, Length(Result), 1);
      Result := '?' + Result;
      Exit;
    end;
  Result := '';
end;

function TOAuth.PUTCommand(URL: string; Body: TStream; Mime: string): string;
begin
  Result := HTTPMethod(URL, tmPUT, nil, Body, Mime)
end;

function TOAuth.RefreshToken: string;
var
  Params: TStringStream;
  Response: string;
begin
  Params := TStringStream.Create(Format(crefreshtoken, [ClientID, ClientSecret, Refresh_token]));
  try
    Response := POSTCommand(tokenurl, nil, Params, 'application/x-www-form-urlencoded');
    FAccess_token := ParamValue('access_token', Response);
    FExpires_in := ParamValue('expires_in', Response);
    Result := Access_token;
  finally
    Params.Free;
  end;
end;

procedure TOAuth.SetClientID(const Value: string);
begin
  FClientID := Value;
end;

procedure TOAuth.SetClientSecret(Value: string);
begin
  FClientSecret := TIdURI.PathEncode(Value)
end;

procedure TOAuth.SetResponseCode(const Value: string);
begin
  FResponseCode := Value;
end;

procedure TOAuth.SetScope(const Value: string);
begin
  FScope := Value;
end;

procedure TOAuth.WorkBeginEvent(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  FWorkMax := AWorkCountMax;
  FWorkPosition := 0;
end;

procedure TOAuth.WorkEndEvent(ASender: TObject; AWorkMode: TWorkMode);
begin
  FWorkPosition := FWorkMax;
end;

procedure TOAuth.WorkEvent(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  FWorkPosition := AWorkCount;
  if Assigned(FOnProgress) then
    FOnProgress(Self, FWorkMax, FWorkPosition);
end;

end.
