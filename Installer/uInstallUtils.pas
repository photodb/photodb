unit uInstallUtils;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, SysUtils, Classes, Messages, Registry, ShlObj, ComObj, ActiveX,
  uConstants, uMemory, uInstallTypes, uInstallScope, VRSIShortCuts,
  IniFiles, uTranslate, uLogger, UnitINI, uShellUtils;

type
  TBooleanFunction = function: Boolean;

function IsApplicationInstalled: Boolean;
function GetRCDATAResourceStream(ResName : string; MS : TMemoryStream) : Boolean;
procedure CreateShortcut(SourceFileName, ShortcutPath: string; Description: string);
function ResolveInstallPath(Path : string) : string;
procedure CreateInternetShortcut(const FileName, LocationURL : string);
function GetInstalledFileName : string;

implementation

function GetInstalledFileName : string;
var
  FReg: TBDRegistry;
begin
  Result := '';
  FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
  try
    FReg.OpenKey(RegRoot, True);
    Result := AnsiLowerCase(FReg.ReadString('DataBase'));
  except
    on E: Exception do
      EventLog(':IsInstalledApplication() throw exception: ' + E.message);
  end;
  F(FReg);
end;

function IsApplicationInstalled: Boolean;
var
  Func: TBooleanFunction;
  H: Thandle;
  ProcH: Pointer;
  FileName: string;
begin
  Result := False;
  FileName := GetInstalledFileName;
  if FileExists(FileName) then
  begin
    H := LoadLibrary(PChar(FileName));
    if H <> 0 then
    begin
      ProcH := GetProcAddress(H, 'IsFalidDBFile');
      if ProcH <> nil then
      begin
        @Func := ProcH;
        if Func then
          if FileExists(IncludeTrailingBackslash(ExtractFileDir(FileName)) + 'Kernel.dll') then
            Result := True;
      end;
      FreeLibrary(H);
    end;
  end;
end;

function GetRCDATAResourceStream(ResName : string; MS : TMemoryStream) : Boolean;
var
  MyRes  : Integer;
  MyResP : Pointer;
  MyResS : Integer;
begin
  Result := False;
  MyRes := FindResource(HInstance, PWideChar(ResName), RT_RCDATA);
  if MyRes <> 0 then begin
    MyResS := SizeOfResource(HInstance,MyRes);
    MyRes := LoadResource(HInstance,MyRes);
    if MyRes <> 0 then begin
      MyResP := LockResource(MyRes);
      if MyResP <> nil then begin
        with MS do begin
          Write(MyResP^, MyResS);
          Seek(0, soFromBeginning);
        end;
        Result := True;
        UnLockResource(MyRes);
      end;
      FreeResource(MyRes);
    end
  end;
end;

procedure CreateShortcut(SourceFileName, ShortcutPath: string; Description: string);
var
  VRSIShortCut : TVRSIShortCut;
begin
  VRSIShortCut := TVRSIShortCut.Create;
  try
    if not DirectoryExists(ExtractFileDir(ShortcutPath)) then
      CreateDir(ExtractFileDir(ShortcutPath));

    VRSIShortCut.WorkingDirectory := ExtractFileDir(SourceFileName);
    VRSIShortCut.SetIcon(SourceFileName, 0);
    VRSIShortCut.Path := SourceFileName;
    VRSIShortCut.Description := Description;

    if FileExists(ShortcutPath) then
      if not DeleteFile(ShortcutPath) then
        Exit;

    VRSIShortCut.Save(ShortcutPath);
  finally
    F(VRSIShortCut);
  end;
end;

function ResolveInstallPath(Path : string) : string;
var
  ProgramPath,
  DesktopPath,
  StartMenuPath : string;
  Reg : TRegIniFile;
begin
  Result := StringReplace(Path, '{V}', ProductMajorVersionVersion, [rfIgnoreCase]);
  Result := StringReplace(Result, '{LNG}', AnsiLowerCase(TTranslateManager.Instance.Language), [rfIgnoreCase]);
  try
    ProgramPath := CurrentInstall.DestinationPath;
    StartMenuPath := GetStartMenuPath;
    DesktopPath := GetDesktopPath;

    Result := StringReplace(Result, '%PROGRAM%', ProgramPath, [rfIgnoreCase]);
    Result := StringReplace(Result, '%STARTMENU%', StartMenuPath, [rfIgnoreCase]);
    Result := StringReplace(Result, '%DESKTOP%', DesktopPath, [rfIgnoreCase]);
  finally
    F(Reg);
  end;
end;

procedure CreateInternetShortcut(const FileName, LocationURL : string);
begin
  with TIniFile.Create(FileName) do
  try
    WriteString(
       'InternetShortcut',
       'URL',
       LocationURL) ;
  finally
    Free;
  end;
end;

end.
