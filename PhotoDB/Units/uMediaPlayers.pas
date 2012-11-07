unit uMediaPlayers;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  System.Win.Registry,
  System.SysUtils,
  Winapi.ShlObj,
  Winapi.ShellApi,
  uMemory,
  uAppUtils,
  uSettings,
  uConstants,
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

procedure RegisterVideoFiles;

implementation

function GetLocalShellPlayerForFile(FileName: string): string;
var
  Reg: TRegistry;
  AssociationsKey, Handler, CommandLine: string;
begin
  Result := '';

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    AssociationsKey := '\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + ExtractFileExt(FileName);
    if Reg.OpenKey(AssociationsKey + '\UserChoice', False) then
    begin
      Handler := Reg.ReadString('Progid');
      if Handler <> '' then
      begin
        Reg.CloseKey;
        Reg.RootKey := HKEY_CLASSES_ROOT;

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

function GetShellPlayerForFile(FileName: string): string;
var
  Reg: TRegistry;
  Handler,
  CommandLine: string;
begin
  Result := GetLocalShellPlayerForFile(FileName);
  if Result <> '' then
    Exit;

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

procedure RegisterVideoFiles;
var
  Ext, Player: string;
  VideoFileExtensions: TArray<string>;
begin
  Player := GetPlayerInternalPath;
  VideoFileExtensions := uConstants.cVideoFileExtensions.ToUpper.Split([',']);

  for Ext in VideoFileExtensions do
    Settings.WriteString(cMediaAssociationsData + '\' + Ext, '', Player);
end;

end.
