unit UnitInternetUpdate;

interface

uses
  Classes, Registry, WinSock, WinInet, Windows, SysUtils, dolphin_db, Forms,
  uVistaFuncs, uLogger, uConstants;

type
  TConnectionType = (ctNone, ctProxy, ctDialup);

type
  TInternetUpdate = class(TThread)
  private
   NewVersion,Text,URL : string;
   FNeedsInformation : boolean;
   StringParam : String;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure ShowUpdates;
    procedure Inform(Info : String);
    procedure InformSynch;
  public
   constructor Create(CreateSuspennded: Boolean; NeedsInformation : Boolean);
  end;

var
  UpdatingWorking : boolean;

implementation

uses UnitFormInternetUpdating, Language;

//For RasConnectionCount =======================
const  
  cERROR_BUFFER_TOO_SMALL = 603;  
  cRAS_MaxEntryName       = 256;
  cRAS_MaxDeviceName      = 128;
  cRAS_MaxDeviceType      = 16;

  type
  ERasError = class(Exception);

  HRASConn = DWORD;  
  PRASConn = ^TRASConn;  
  TRASConn = record  
    dwSize: DWORD;  
    rasConn: HRASConn;
    szEntryName: array[0..cRAS_MaxEntryName] of Char;  
    szDeviceType: array[0..cRAS_MaxDeviceType] of Char;  
    szDeviceName: array [0..cRAS_MaxDeviceName] of Char;  
  end;

  TRasEnumConnections =  
    function(RASConn: PrasConn; { buffer to receive Connections data }  
    var BufSize: DWORD;    { size in bytes of buffer }  
    var Connections: DWORD { number of Connections written to buffer }
    ): Longint;
  stdcall;
  //End RasConnectionCount =======================  

function RasConnectionCount: Integer;
var  
  RasDLL:    HInst;  
  Conns:     array[1..4] of TRasConn;  
  RasEnums:  TRasEnumConnections;  
  BufSize:   DWORD;  
  NumConns:  DWORD;  
  RasResult: Longint;  
begin
  Result := 0;  
  //Load the RAS DLL
  RasDLL := LoadLibrary('rasapi32.dll');  
  if RasDLL = 0 then Exit;  
  try
    RasEnums := GetProcAddress(RasDLL, 'RasEnumConnectionsA');  
    if @RasEnums = nil then
      raise ERasError.Create('RasEnumConnectionsA not found in rasapi32.dll');  
    Conns[1].dwSize := SizeOf(Conns[1]);
    BufSize         := SizeOf(Conns);
    RasResult := RasEnums(@Conns, BufSize, NumConns);
    if (RasResult = 0) or (Result = cERROR_BUFFER_TOO_SMALL) then Result := NumConns;
  finally
    FreeLibrary(RasDLL);
  end;  
end; 

function ConnectedToInternet: TConnectionType;
var
  Reg:       TRegistry;  
  bUseProxy: Boolean;  
  UseProxy:  LongWord;  
begin  
  Result := ctNone;
  Reg    := TRegistry.Create;  
  with REG do  
    try  
      try  
        RootKey := HKEY_CURRENT_USER;  
        if OpenKey('\Software\Microsoft\Windows\CurrentVersion\Internet settings', False) then   
        begin  
          //I just try to read it, and trap an exception  
          if GetDataType('ProxyEnable') = rdBinary then
            ReadBinaryData('ProxyEnable', UseProxy, SizeOf(Longword))  
          else   
          begin  
            bUseProxy := ReadBool('ProxyEnable');  
            if bUseProxy then  
              UseProxy := 1  
            else  
              UseProxy := 0;  
          end;
          if (UseProxy <> 0) and (ReadString('ProxyServer') <> '') then  
            Result := ctProxy;  
        end;  
      except  
        //Obviously not connected through a proxy  
      end;  
    finally  
      Free;  
    end;
  //We can check RasConnectionCount even if dialup networking is not installed
  //simply because it will return 0 if the DLL is not found.
  if Result = ctNone then
  begin  
    if RasConnectionCount > 0 then Result := ctDialup;  
  end;  
end;  

function DownloadFile(const Url: string): string;
var 
  NetHandle: HINTERNET; 
  UrlHandle: HINTERNET; 
  Buffer: array[0..1024] of char; 
  BytesRead: cardinal; 
begin 
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
 inherited Create(true);
 FNeedsInformation:=NeedsInformation;
 if not CreateSuspennded then Resume;
end;

procedure TInternetUpdate.Execute;
var
  S : TStrings;
  Vesrion, Release : Integer;
  i : integer;
  D : TDateTime;
begin
 if UpdatingWorking then exit;
 FreeOnTerminate:=True;
 UpdatingWorking:=true;
 Sleep(1000);
 D:=DBKernel.ReadDateTime('','LastUpdating',now);
 if (now-D<7) and not FNeedsInformation then
 begin
  UpdatingWorking:=false;
  exit;
 end;

 //Local internet and other types!!!
{ if RasConnectionCount=0 then
 begin
  if FNeedsInformation then
  Inform(TEXT_MES_NEEDS_INTERNET_CONNECTION);
  UpdatingWorking:=false;
  exit;
 end;  }
 
 S:=TStringList.Create;
 try
  S.Text:=DownloadFile(HomeURL+UpdateFileName);
 except        
  on e : Exception do EventLog(':TInternetUpdate::Execute() throw exception: '+e.Message);
 end;
 if S.Text='' then
 try
  S.Text:=DownloadFile(AlternativeUpdateURL);
 except
  on e : Exception do EventLog(':TInternetUpdate::Execute() throw exception: '+e.Message);
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
 S.free;
 UpdatingWorking:=false;
end;

procedure TInternetUpdate.Inform(Info : String);
begin
 StringParam:=Info;
 Synchronize(InformSynch);
end;

procedure TInternetUpdate.InformSynch;
var
  ActiveFormHandle : integer;
begin
 if Screen.ActiveForm<>nil then
 ActiveFormHandle:=Screen.ActiveForm.Handle else
 ActiveFormHandle:=0;
 MessageBoxDB(ActiveFormHandle,StringParam,TEXT_MES_INFORMATION,TD_BUTTON_OK,TD_ICON_INFORMATION);
end;

procedure TInternetUpdate.ShowUpdates;
begin
 ShowAvaliableUpdating(NewVersion,Text,URL);
end;

initialization

UpdatingWorking:=false;

end.
