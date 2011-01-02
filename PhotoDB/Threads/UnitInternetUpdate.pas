unit UnitInternetUpdate;

interface

uses
  Classes, Registry, Windows, SysUtils, UnitDBKernel, Forms,
  uVistaFuncs, uLogger, uConstants, uShellIntegration,
  uTranslate;

type
  TInternetUpdate = class(TThread)
  private
    { Private declarations }
    NewVersion, Text, URL: string;
    FNeedsInformation: Boolean;
    StringParam: string;
  protected
    procedure Execute; override;
    procedure ShowUpdates;
    procedure Inform(Info : String);
    procedure InformSynch;
  public
   constructor Create(CreateSuspennded: Boolean; NeedsInformation : Boolean);
  end;

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

var
  UpdatingWorking : boolean;

implementation

uses UnitFormInternetUpdating, Language;

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
   EventLog(':DownloadFile() throw exception: Unable to initialize Wininet');
end;

constructor TInternetUpdate.Create(CreateSuspennded,
  NeedsInformation: Boolean);
begin
  inherited Create(False);
  FNeedsInformation := NeedsInformation;
end;

procedure TInternetUpdate.Execute;
var
  S: TStrings;
  Vesrion, Release: Integer;
  I: Integer;
  D : TDateTime;
begin
 FreeOnTerminate:=True;
 if UpdatingWorking then exit;
 UpdatingWorking:=true;
 D:=DBKernel.ReadDateTime('', 'LastUpdating', Now);
 Sleep(5000);
  if (Now - D < 7) and not FNeedsInformation then
  begin
    UpdatingWorking := False;
    Exit;
  end;

  S := TStringList.Create;
  try
  try
    S.Text := DownloadFile(HomeURL + UpdateURL);
  except
    on E: Exception do EventLog(':TInternetUpdate::Execute() throw exception: '+e.Message);
 end;

 if s.Text<>'' then
 begin
  if S.Count>0 then
  Vesrion:=StrToIntDef(S[0],0) else Vesrion:=0;
  if Vesrion=1 then
  begin
   if S.Count>1 then
   Release:=StrToIntDef(S[1],0) else Release:=0;
   if Release>ReleaseNumber then
   begin
    if S.Count>6 then
    begin
     NewVersion:=S[2];
     URL:=s[4];
     Text:=s[5];
     for i:=6 to S.Count-1 do
     Text:=Text+#13#10+s[i];
     Synchronize(ShowUpdates);
    end else if FNeedsInformation then Inform(TEXT_MES_CANNOT_FIND_SITE);
   end else if FNeedsInformation then Inform(TEXT_MES_NO_UPDATES);
  end else if FNeedsInformation then Inform(TEXT_MES_CANNOT_FIND_SITE);
 end else if FNeedsInformation then Inform(TEXT_MES_CANNOT_FIND_SITE);
  finally
    S.free;
  end;
 UpdatingWorking:=false;
end;

procedure TInternetUpdate.Inform(Info : String);
begin
 StringParam:=Info;
 Synchronize(InformSynch);
end;

procedure TInternetUpdate.InformSynch;
var
  ActiveFormHandle: Integer;
begin
  if Screen.ActiveForm <> nil then
 ActiveFormHandle:=Screen.ActiveForm.Handle else
 ActiveFormHandle:=0;
 MessageBoxDB(ActiveFormHandle,StringParam,TA('Information'),TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

procedure TInternetUpdate.ShowUpdates;
begin
 ShowAvaliableUpdating(NewVersion,Text,URL);
end;

initialization

UpdatingWorking := False;

end.
