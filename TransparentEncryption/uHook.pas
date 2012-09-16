unit uHook;

interface

uses
  Windows,
  uWinAPIRedirections,
  uTransparentEncryptor;

procedure HandleEvents(Reason: Integer); register;
function InstParamStr: string;
procedure LoadHook; stdcall;

implementation

procedure HandleEvents(Reason: Integer); register;
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        //bad place to do something :(
      end;

    DLL_PROCESS_DETACH:
      begin
        StopLib;
      end;
  end;
end;

procedure LoadHook; stdcall;
begin
  {$IFDEF DEBUG}
  MessageBox(0, PChar('LoadHook'), PChar('LoadHook'), MB_OK or MB_ICONINFORMATION);
  {$ENDIF}
  StartLib;
  HookPEModule(GetModuleHandle(nil));
end;

function InstParamStr: string;
var
  Path: array[0..MAX_PATH - 1] of Char;
begin
  if IsLibrary then
    SetString(Result, Path, GetModuleFileName(HInstance, Path, SizeOf(Path)))
end;

end.
