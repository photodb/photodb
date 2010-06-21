unit UnitDBCommon;

interface

uses Windows, Classes, Forms, SysUtils, uScript, UnitScripts, Messages,
     ReplaseLanguageInScript, ReplaseIconsInScript, uTime;

function Hash_Cos_C(s:string):integer;
function ActivateApplication(const Handle1: THandle): Boolean;
procedure ExecuteScriptFile(FileName : String; UseDBFunctions : boolean = false);
function GetParamStrDBValue(param : string) : string;
function GetParamStrDBBool(param : string) : boolean;
procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
procedure ProportionalSizeA(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
function FileExistsEx(const FileName :TFileName) :Boolean;

implementation

function FileExistsEx(const FileName :TFileName) :Boolean;
var
  Code :DWORD;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> DWORD(-1)) and (Code and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

function ActivateApplication(const Handle1: THandle): Boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegndThreadID: DWORD;
  TheThreadID      : DWORD;
  timeout           : DWORD;
  OSVersionInfo: TOSVersionInfo;
  hParent: THandle;
  AniInfo: TAnimationInfo;
  Animate: Boolean;
begin
if IsIconic(Handle1) then ShowWindow(Handle1, SW_RESTORE);
hParent := GetWindowLong(Handle1, GWL_HWNDPARENT);
if hParent > 0 then
  if IsIconic(hParent) then ShowWindow(hParent, SW_RESTORE);

  if (GetForegroundWindow = Handle1) then Result := true
  else
    begin
    OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
    GetVersionEx(OSVersionInfo);

    if ((OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT) and (OSVersionInfo.dwMajorVersion > 4))
    or
    ((OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS) and ((OSVersionInfo.dwMajorVersion > 4)
    or
    ((OSVersionInfo.dwMajorVersion = 4) and (OSVersionInfo.dwMinorVersion > 0))))
    then
      begin // OS is above win 95
      Result := false;
      ForegndThreadID := GetWindowThreadProcessID(GetForegroundWindow,nil);
      TheThreadID := GetWindowThreadProcessId(Handle1,nil);
      if AttachThreadInput(TheThreadID, ForegndThreadID, true) then
        begin
        SetForegroundWindow(Handle1);
        AttachThreadInput(TheThreadID, ForegndThreadID, false);
        Result := (GetForegroundWindow = Handle1);
        end;
      if not Result then
        begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, nil, SPIF_SENDCHANGE);
        SetForegroundWindow(Handle1);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, @timeout, SPIF_SENDCHANGE);
        end;

      end else // OS is above win 95
      SetForegroundWindow(Handle1);

  Result := (GetForegroundWindow = Handle1);
  if Result then Exit;
  
  AniInfo.cbSize := SizeOf(TAnimationInfo);
  if SystemParametersInfo(SPI_GETANIMATION, SizeOf(AniInfo), @AniInfo, 0) then
    Animate := AniInfo.iMinAnimate <> 0 else
    Animate := False;
  if Animate then
    begin
    AniInfo.iMinAnimate := 0;
    SystemParametersInfo(SPI_SETANIMATION, SizeOf(AniInfo), @AniInfo, 0);
    end;
  SendMessage(Handle1,WM_SYSCOMMAND,SC_MINIMIZE,0);
  Sleep(40);
  if hParent > 0 then
  SendMessage(hParent,WM_SYSCOMMAND,SC_RESTORE,0)
  else
  SendMessage(Handle1,WM_SYSCOMMAND,SC_RESTORE,0);
  if Animate then
  begin
  AniInfo.iMinAnimate := 1;
  SystemParametersInfo(SPI_SETANIMATION, SizeOf(AniInfo), @AniInfo, 0);
  end;
  
  Result := (GetForegroundWindow = Handle1);
  end;
end;

function Hash_Cos_C(s : string):integer;
var
  c , i : integer;
begin
 c:=0;
 {$R-}
 for i:=1 to Length(s) do
 c:=c+Round($ffffffff*cos(i)*Ord(s[i]));
 {$R+}
 Result:=c;
end;

function GetParamStrDBBool(param : string) : boolean;
var
  i : integer;
  ParamStrValue : string;
begin
 Result:=false;
 for i:=1 to ParamCount do
 begin
  ParamStrValue:=paramStr(i);
  if ParamStrValue='' then break;
  if AnsiUpperCase(ParamStrValue)=AnsiUpperCase(param) then
  begin
   Result:=true;
   break;
  end;
 end;
end;

function GetParamStrDBValue(param : string) : string;
var
  i : integer;
  ParamStrValue : string;
begin
 Result:='';
 for i:=1 to 250 do
 begin
  ParamStrValue:=paramStr(i);
  if ParamStrValue='' then break;
  if AnsiUpperCase(ParamStrValue)=AnsiUpperCase(param) then
  begin
   Result:=paramStr(i+1);
   break;
  end;
 end;
end;

procedure ExecuteScriptFile(FileName : String; UseDBFunctions : boolean = false);
var
  aScript : TScript;
  i : integer;
  LoadScript : string;
  aFS : TFileStream;
begin
  aScript := TScript.Create('');
  try
    LoadScript:='';
    try
     aFS := TFileStream.Create(FileName,fmOpenRead);
     SetLength(LoadScript,aFS.Size);
     aFS.Read(LoadScript[1],aFS.Size);
     for i:=Length(LoadScript) downto 1 do
     begin
      if LoadScript[i]=#10 then LoadScript[i]:=' ';
      if LoadScript[i]=#13 then LoadScript[i]:=' ';
     end;
     LoadScript:=AddLanguage(LoadScript);
     LoadScript:=AddIcons(LoadScript);
     aFS.Free;
    except
    end;
    try
     ExecuteScript(nil,aScript,LoadScript,i,nil);
    except
      //on e : Exception do EventLog(':ExecuteScriptFile() throw exception: '+e.Message);
    end;
  finally
    aScript.Free;
  end;
end;

procedure ProportionalSizeA(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
 if (aWidthToSize = 0) or (aHeightToSize = 0) then
 begin
  aHeightToSize := 0;
  aWidthToSize  := 0;
 end else begin
  if (aHeightToSize/aWidthToSize) < (aHeight/aWidth) then
  begin
   aHeightToSize := Round ( (aWidth/aWidthToSize) * aHeightToSize );
   aWidthToSize  := aWidth;
  end else begin
   aWidthToSize  := Round ( (aHeight/aHeightToSize) * aWidthToSize );
   aHeightToSize := aHeight;
  end;
 end;
end;

procedure ProportionalSize(aWidth, aHeight: Integer; var aWidthToSize, aHeightToSize: Integer);
begin
 If (aWidthToSize<aWidth) and (aHeightToSize<aHeight) then
 begin
  Exit;
 end;
 if (aWidthToSize = 0) or (aHeightToSize = 0) then
 begin
  aHeightToSize := 0;
  aWidthToSize  := 0;
 end else begin
  if (aHeightToSize/aWidthToSize) < (aHeight/aWidth) then
  begin
   aHeightToSize := Round ( (aWidth/aWidthToSize) * aHeightToSize );
   aWidthToSize  := aWidth;
  end else begin
   aWidthToSize  := Round ( (aHeight/aHeightToSize) * aWidthToSize );
   aHeightToSize := aHeight;
  end;
 end;
end;

end.
