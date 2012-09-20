unit uMediaPlayers;

interface

uses
  Winapi.Windows,
  System.Win.Registry,
  System.SysUtils,
  Winapi.ShlObj,
  uMemory,
  uAppUtils,
  uShellUtils;

function GetPlayerInternalPath: string;
function IsPlayerInternalInstalled: Boolean;
function GetVlcPlayerPath: string;
function IsVlcPlayerInstalled: Boolean;
function GetKMPlayerPath: string;
function IsKmpPlayerInstalled: Boolean;
function GetMediaPlayerClassicPath: string;
function IsMediaPlayerClassicInstalled: Boolean;
function GetWindowsMediaPlayerPath: string;
function IsWindowsMediaPlayerInstalled: Boolean;
function GetShellPlayerForFile(FileName: string): string;

implementation

function GetShellPlayerForFile(FileName: string): string;
var
  Reg: TRegistry;
  Handler,
  CommandLine: string;
begin
  Result := '';

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKey(ExtractFileExt(FileName), False) then
    begin
      Handler := Reg.ReadString('');
      if Handler <> '' then
      begin
        if Reg.OpenKey('\' + Handler + '\shell\open\command', False) then
        begin
          CommandLine := Reg.ReadString('');
          if CommandLine <> '' then
            Result := ParamStrEx(CommandLine, -1);
        end;
      end;
    end;
  finally
    F(Reg);
  end;
end;

function IsPlayerInternalInstalled: Boolean;
begin
  Result := GetPlayerInternalPath <> '';
end;

function GetPlayerInternalPath: string;
var
  InternalMediaPlayerPath: string;
begin
  Result := '';
  InternalMediaPlayerPath := ExtractFilePath(ParamStr(0)) + 'MediaPlayer\mpc-hc.exe';
  if FileExists(InternalMediaPlayerPath) then
    Result := InternalMediaPlayerPath;
end;

function IsVlcPlayerInstalled: Boolean;
begin
  Result := GetVlcPlayerPath <> '';
end;

function GetVlcPlayerPath: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SOFTWARE\Wow6432Node\VideoLAN\VLC', False) then
      Result := Reg.ReadString('');
  finally
    F(Reg);
  end;
end;

function IsKmpPlayerInstalled: Boolean;
begin
  Result := GetKMPlayerPath <> '';
end;

function GetKMPlayerPath: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\KMPlayer\KMP3.0\OptionArea', False) then
      Result := Reg.ReadString('InstallPath');
  finally
    F(Reg);
  end;
end;

function IsMediaPlayerClassicInstalled: Boolean;
begin
  Result := GetMediaPlayerClassicPath <> '';
end;

function GetMediaPlayerClassicPath: string;
const
  MPC_PATHS : array[0..1] of string =
              ('%PROGRAM%\Essentials Codec Pack\MPC\mpc-hc.exe',
               '%PROGRAM_86%\Essentials Codec Pack\MPC\mpc-hc.exe');

var
  FileName: string;
  I: Integer;
begin
  Result := '';
  for I := Low(MPC_PATHS) to High(MPC_PATHS) do
  begin
    FileName := StringReplace(MPC_PATHS[I], '%PROGRAM%',    GetSystemPath(CSIDL_PROGRAM_FILES), []);
    FileName := StringReplace(FileName, '%PROGRAM_86%', GetSystemPath(CSIDL_PROGRAM_FILESX86), []);
    if FileExists(FileName) then
      Result := FileName;
  end;
end;

function IsWindowsMediaPlayerInstalled: Boolean;
begin
  Result := GetWindowsMediaPlayerPath <> '';
end;

function GetWindowsMediaPlayerPath: string;
const
  WMP_PATHS : array[0..1] of string =
              ('%PROGRAM%\Windows Media Player\wmplayer.exe',
               '%PROGRAM_86%\Windows Media Player\wmplayer.exe');

var
  FileName: string;
  I: Integer;
begin
  Result := '';
  for I := Low(WMP_PATHS) to High(WMP_PATHS) do
  begin
    FileName := StringReplace(WMP_PATHS[I], '%PROGRAM%',    GetSystemPath(CSIDL_PROGRAM_FILES), []);
    FileName := StringReplace(FileName, '%PROGRAM_86%', GetSystemPath(CSIDL_PROGRAM_FILESX86), []);
    if FileExists(FileName) then
      Result := FileName;
  end;
end;

end.
