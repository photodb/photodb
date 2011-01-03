unit uInternetUtils;

interface

uses
  Windows, uConstants;

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

function DownloadFile(const Url: string): string;

implementation

function DownloadFile(const Url: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of char;
  BytesRead: cardinal;
  InternetOpen : TInternetOpen;
  InternetOpenUrl : TInternetOpenUrl;
  InternetReadFile : TInternetReadFile;
  InternetCloseHandle : TInternetCloseHandle;
  WinInetHandle : THandle;
begin
  WinInetHandle := LoadLibrary(wininet);
  @InternetOpen := GetProcAddress(WinInetHandle, 'InternetOpen');
  @InternetOpenUrl := GetProcAddress(WinInetHandle, 'InternetOpenUrl');
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
          FillChar(Buffer, SizeOf(Buffer), 0);
          repeat
            Result := Result + Buffer;
            FillChar(Buffer, SizeOf(Buffer), 0);
            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
          until BytesRead = 0;
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

end.
