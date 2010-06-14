unit UnitDBCommon;

interface

uses Windows, Classes, Forms, SysUtils, UnitScripts,
     ReplaseLanguageInScript, ReplaseIconsInScript;

function Hash_Cos_C(s:string):integer;
procedure ActivateApplication(hWnd : THandle);
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

procedure ActivateApplication(hWnd : THandle);
var
  hCurWnd, dwThreadID, dwCurThreadID: THandle;
  OldTimeOut: Cardinal;
  AResult: Boolean;
begin
     Application.Restore;
     ShowWindow(hWnd,SW_RESTORE);
     hWnd := Application.Handle;
     SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @OldTimeOut, 0);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(0), 0);
     SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     hCurWnd := GetForegroundWindow;
     AResult := False;
     while not AResult do
     begin
        dwThreadID := GetCurrentThreadId;
        dwCurThreadID := GetWindowThreadProcessId(hCurWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, True);
        AResult := SetForegroundWindow(hWnd);
        AttachThreadInput(dwThreadID, dwCurThreadID, False);
     end;
     SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, Pointer(OldTimeOut), 0);
     ShowWindow(Application.MainForm.Handle,SW_HIDE);                                 
     ShowWindow(Application.Handle,SW_HIDE);
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
  InitializeScript(aScript);
  LoadBaseFunctions(aScript);
  if UseDBFunctions then
  begin
   //TODO:!!! LoadDBFunctions(aScript);
   //TODO:!!! LoadFileFunctions(aScript);
  end;
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
