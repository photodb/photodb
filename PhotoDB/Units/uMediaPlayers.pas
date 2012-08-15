unit uMediaPlayers;

interface

uses
  Windows,
  Registry,
  SysUtils,
  uMemory;

function GetVlcPlayerInternalPath: string;
function IsVlcPlayerInternalInstalled: Boolean;
function IsVlcPlayerInstalled: Boolean;
function GetVlcPlayerPath: string;
function IsKmpPlayerInstalled: Boolean;
function GetKMPlayerPath: string;
function IsMediaPlayerClassicInstalled: Boolean;
function GetMediaPlayerClassicPath: string;

implementation

function IsVlcPlayerInternalInstalled: Boolean;
begin
  Result := GetVlcPlayerInternalPath <> '';
end;

function GetVlcPlayerInternalPath: string;
var
  InternalVlcPath: string;
begin
  Result := '';
  InternalVlcPath := ExtractFilePath(ParamStr(1)) + 'VlcPlayer\vlc.exe';
  if FileExists(InternalVlcPath) then
    Result := InternalVlcPath;
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
              ('C:\Program Files\Essentials Codec Pack\MPC\mpc-hc.exe',
               'C:\Program Files (x86)\Essentials Codec Pack\MPC\mpc-hc.exe');

var
  I: Integer;
begin
  Result := '';
  for I := Low(MPC_PATHS) to High(MPC_PATHS) do
    if FileExists(MPC_PATHS[I]) then
      Result := MPC_PATHS[I];
end;

end.
