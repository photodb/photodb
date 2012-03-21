unit uInternetUtils;

interface

uses
  Windows,
  Classes,
  SysUtils,
  uMemory,
  uConstants,
  EncdDecd,
  uDBBaseTypes,
  uSysUtils,
  IdSSLOpenSSL,
  idHTTP;

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

function LoadStreamFromURL(URL: string; Stream: TStream): Boolean;
function EncodeURLElement(const Value: string): AnsiString;
function DownloadFile(const Url: string; Encoding: TEncoding): string;
function InternetTimeToDateTime(const Value: string) : TDateTime;
function EncodeBase64Url(inputData: string): string;

implementation

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
  NetHandle := InternetOpen(ProductName, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
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


function LoadStreamFromURL(URL: string; Stream: TStream): Boolean;
var
  FHTTP: TIdHTTP;
  FSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  FHTTP := TIdHTTP.Create(nil);
  try
    FSSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      FHTTP.Request.UserAgent := cBrowserAgent;
      FHTTP.IOHandler := FSSLIOHandler;
      FHTTP.ConnectTimeout := cConnectionTimeout;
      FHTTP.ReadTimeout := 0;
      try
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
      F(FSSLIOHandler);
    end;
  finally
    F(FHTTP);
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

end.
