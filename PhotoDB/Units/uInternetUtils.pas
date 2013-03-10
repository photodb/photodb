unit uInternetUtils;

interface

uses
  Windows,
  Graphics,
  Classes,
  SysUtils,
  uMemory,
  uConstants,
  EncdDecd,
  JPEG,
  pngimage,

  Dmitry.Utils.System,

  IdSSLOpenSSL,
  idHTTP,

  uInternetProxy,
  uSysInfo;

type
  THTTPRequestContainer = class
  private
    FHTTP: TIdHTTP;
    FSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  public
    constructor Create;
    destructor Destroy; override;
    property HTTP: TIdHTTP read FHTTP;
  end;

type
  TUpdateInfo = record
    InfoAvaliable: Boolean;
    UrlToDownload: string;
    Release: TRelease;
    Version: Byte;
    Build: Cardinal;
    ReleaseDate: TDateTime;
    ReleaseNotes: string;
    ReleaseText: string;
    IsNewVersion: Boolean;
  end;

  TUpdateNotifyHandler = procedure(Sender : TObject; Info : TUpdateInfo) of object;

type
  HINTERNET = Pointer;

  TInternetOpen = function(lpszAgent: PChar; dwAccessType: DWORD;
  lpszProxy, lpszProxyBypass: PChar; dwFlags: DWORD): HINTERNET; stdcall;

  TInternetOpenUrl = function(hInet: HINTERNET; lpszUrl: PChar;
  lpszHeaders: PChar; dwHeadersLength: DWORD; dwFlags: DWORD;
  dwContext: DWORD): HINTERNET; stdcall;

  TInternetReadFile = function(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;

  TInternetCloseHandle = function(hInet: HINTERNET): BOOL; stdcall;

const
  INTERNET_OPEN_TYPE_PRECONFIG                = 0;  { use registry configuration }
  INTERNET_FLAG_RELOAD = $80000000;                 { retrieve the original item }
  wininet = 'wininet.dll';

  type
  TSpecials = set of AnsiChar;

const
  URLSpecialChar: TSpecials = [#$00..#$20, '_', '<', '>', '"', '%', '{', '}', '|', '\', '^', '~', '[', ']',  '`', #$7F..#$FF];
  URLFullSpecialChar: TSpecials =  [';', '/', '?', ':', '@', '=', '&', '#', '+'];

  cConnectionTimeout = 15000;
  cReadTimeout = 20000;
  cBrowserAgent: string = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:11.0) Gecko/20100101 Firefox/11.0';

function LoadStreamFromURL(URL: string; Stream: TStream; Container: THTTPRequestContainer = nil; ProxyBaseUrl: string = ''): Boolean;
function PostDataToURL(URL: string; ParamList: TStringList): string;
function EncodeURLElement(const Value: string): AnsiString;
function DownloadFile(const Url: string; Encoding: TEncoding): string;
function InternetTimeToDateTime(const Value: string): TDateTime;
function EncodeBase64Url(inputData: string): string;
function LoadBitmapFromUrl(Url: string; Bitmap: TBitmap; Container: THTTPRequestContainer = nil; ProxyBaseUrl: string = ''): Boolean;
function GetMimeContentType(Content: Pointer; Len: integer): string;

implementation

function PostDataToURL(URL: string; ParamList: TStringList): string;
var
  HTTP: TIdHTTP;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    Result := HTTP.Post(URL, ParamList);
  finally
    F(HTTP);
  end;
end;

function GetMimeContentType(Content: Pointer; Len: integer): string;
begin // see http://www.garykessler.net/library/file_sigs.html for magic numbers
  Result := '';
  if (Content <> nil) and (Len > 4) then
    case PCardinal(Content)^ of
    $04034B50: Result := 'application/zip'; // 50 4B 03 04
    $46445025: Result := 'application/pdf'; //  25 50 44 46 2D 31 2E
    $21726152: Result := 'application/x-rar-compressed'; // 52 61 72 21 1A 07 00
    $AFBC7A37: Result := 'application/x-7z-compressed';  // 37 7A BC AF 27 1C
    $75B22630: Result := 'audio/x-ms-wma'; // 30 26 B2 75 8E 66
    $9AC6CDD7: Result := 'video/x-ms-wmv'; // D7 CD C6 9A 00 00
    $474E5089: Result := 'image/png'; // 89 50 4E 47 0D 0A 1A 0A
    $38464947: Result := 'image/gif'; // 47 49 46 38
    $002A4949, $2A004D4D, $2B004D4D:
      Result := 'image/tiff'; // 49 49 2A 00 or 4D 4D 00 2A or 4D 4D 00 2B
    $E011CFD0: // Microsoft Office applications D0 CF 11 E0 = DOCFILE
      if Len > 600 then
      case PWordArray(Content)^[256] of // at offset 512
        $A5EC: Result := 'application/msword'; // EC A5 C1 00
        $FFFD: // FD FF FF
          case PByteArray(Content)^[516] of
            $0E,$1C,$43: Result := 'application/vnd.ms-powerpoint';
            $10,$1F,$20,$22,$23,$28,$29: Result := 'application/vnd.ms-excel';
          end;
      end;
    else
      case PCardinal(Content)^ and $00ffffff of
        $685A42: Result := 'application/bzip2'; // 42 5A 68
        $088B1F: Result := 'application/gzip'; // 1F 8B 08
        $492049: Result := 'image/tiff'; // 49 20 49
        $FFD8FF: Result := 'image/jpeg'; // FF D8 FF DB/E0/E1/E2/E3/E8
        else
          case PWord(Content)^ of
            $4D42: Result := 'image/bmp'; // 42 4D
          end;
      end;
    end;
end;

function LoadBitmapFromUrl(Url: string; Bitmap: TBitmap; Container: THTTPRequestContainer = nil; ProxyBaseUrl: string = ''): Boolean;
var
  MS: TMemoryStream;
  Jpeg: TJPEGImage;
  Png: TPngImage;
  Mime: string;
begin
  Result := False;
  MS := TMemoryStream.Create;
  try
    if Url <> '' then
    begin
      if LoadStreamFromURL(Url, MS, Container, ProxyBaseUrl) and (MS.Size > 0) then
      begin
        Mime := GetMimeContentType(MS.Memory, MS.Size);

        MS.Seek(0, soFromBeginning);

        if Mime = 'image/jpeg' then
        begin
          Jpeg := TJPEGImage.Create;
          try
            Jpeg.LoadFromStream(MS);
            Bitmap.Assign(Jpeg);
            Result := True;
          finally
            F(Jpeg);
          end;
        end;

        if Mime = 'image/png' then
        begin
          Png := TPngImage.Create;
          try
            Png.LoadFromStream(MS);
            Bitmap.Assign(Png);
            Result := True;
          finally
            F(Png);
          end;
        end;

      end;
    end;
  finally
    F(MS);
  end;
end;

function EncodeBase64Url(inputData: string): string;
begin
  //EncdDecd
  Result := string(EncodeBase64(PChar(inputData), Length(inputData) * SizeOf(Char)));
  // =+/ => *-_
  Result := StringReplace(Result, '=', '*', [rfReplaceAll]);
  Result := StringReplace(Result, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
end;

function InternetTimeToDateTime(const Value: string) : TDateTime;
var
  YYYY, MM, DD, HH, SS: string;
  Y, M, D, H, S: Integer;
begin
  Result := 0;
  if Length(Value) = 4 + 2 + 2 + 2 + 2 then
  begin
    YYYY := Copy(Value, 1, 4);
    MM := Copy(Value, 5, 2);
    DD := Copy(Value, 7, 2);
    HH := Copy(Value, 9, 2);
    SS := Copy(Value, 11, 2);
    Y := StrToIntDef(YYYY, 0);
    M := StrToIntDef(MM, 0);
    D := StrToIntDef(DD, 0);
    H := StrToIntDef(HH, 0);
    S := StrToIntDef(SS, 0);
    Result := EncodeTime(H, S, 0, 0) + EncodeDate(Y, M, D);
  end;
end;

function DownloadFile(const Url: string; Encoding: TEncoding): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of AnsiChar;
  BytesRead: cardinal;
  InternetOpen : TInternetOpen;
  InternetOpenUrl : TInternetOpenUrl;
  InternetReadFile : TInternetReadFile;
  InternetCloseHandle : TInternetCloseHandle;
  WinInetHandle : THandle;
  MS: TMemoryStream;
  SR: TStringStream;
begin
  WinInetHandle := LoadLibrary(wininet);
  @InternetOpen := GetProcAddress(WinInetHandle, 'InternetOpenW');
  @InternetOpenUrl := GetProcAddress(WinInetHandle, 'InternetOpenUrlW');
  @InternetReadFile := GetProcAddress(WinInetHandle, 'InternetReadFile');
  @InternetCloseHandle := GetProcAddress(WinInetHandle, 'InternetCloseHandle');
  Result := '';
  NetHandle := InternetOpen(PChar(ProductName + ' on ' + GetOSInfo), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(NetHandle) then
    begin
      UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);
      if Assigned(UrlHandle) then
{ UrlHandle правильный? Начинаем загрузку }
        begin
          MS := TMemoryStream.Create;
          try
            FillChar(Buffer, SizeOf(Buffer), 0);
            BytesRead := 0;
            repeat
              MS.Write(Buffer, BytesRead);
              //Result := Result + string(Buffer);
              FillChar(Buffer, SizeOf(Buffer), 0);
              InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
            until BytesRead = 0;

            SR := TStringStream.Create(Result, Encoding);
            try
              MS.Seek(0, soFromBeginning);
              SR.CopyFrom(MS, MS.Size);
              Result := SR.DataString;
            finally
              F(SR);
            end;

          finally
            F(MS);
          end;
          InternetCloseHandle(UrlHandle);
        end
      else
        begin
{ UrlHandle неправильный. Генерируем исключительную ситуацию. }
//          raise Exception.CreateFmt('Cannot open URL %s', [Url]);
        end;

      InternetCloseHandle(NetHandle);
    end
  else
{ NetHandle недопустимый. Генерируем исключительную ситуацию }
end;

function LoadStreamFromURL(URL: string; Stream: TStream; Container: THTTPRequestContainer = nil; ProxyBaseUrl: string = ''): Boolean;
var
  FHTTP: TIdHTTP;
  IsOwnContainer: Boolean;
begin
  IsOwnContainer := Container = nil;
  if IsOwnContainer then
    Container := THTTPRequestContainer.Create;
  try
    FHTTP := Container.HTTP;
    try
      ConfigureIdHttpProxy(FHTTP, IIF(ProxyBaseUrl = '', URL, ProxyBaseUrl));
      FHTTP.Get(URL, Stream);
      Result := True;
    except
      on e: Exception do
      begin
        Stream.Size := 0;
        Result := False;
      end;
    end;
  finally
    if IsOwnContainer then
      F(Container);
  end;
end;

function EncodeTriplet(const Value: AnsiString; Delimiter: AnsiChar;
  Specials: TSpecials): AnsiString;
var
  n, l: Integer;
  s: AnsiString;
  c: AnsiChar;
begin
  SetLength(Result, Length(Value) * 3);
  l := 1;
  for n := 1 to Length(Value) do
  begin
    c := Value[n];
    if c in Specials then
    begin
      Result[l] := Delimiter;
      Inc(l);
      s := AnsiString(IntToHex(Ord(c), 2));
      Result[l] := s[1];
      Inc(l);
      Result[l] := s[2];
      Inc(l);
    end
    else
    begin
      Result[l] := c;
      Inc(l);
    end;
  end;
  Dec(l);
  SetLength(Result, l);
end;

function EncodeURLElement(const Value: string): AnsiString;
begin
  Result := EncodeTriplet(AnsiString(Value), '%', URLSpecialChar + URLFullSpecialChar);
end;

{ THTTPRequestContainer }

constructor THTTPRequestContainer.Create;
begin
  FHTTP := TIdHTTP.Create(nil);
  FSSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  FHTTP.Request.UserAgent := cBrowserAgent;
  FHTTP.IOHandler := FSSLIOHandler;
  FHTTP.ConnectTimeout := cConnectionTimeout;
  FHTTP.ReadTimeout := 0;
end;

destructor THTTPRequestContainer.Destroy;
begin
  F(FHTTP);
  F(FSSLIOHandler);
  inherited;
end;

end.
