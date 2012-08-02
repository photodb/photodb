unit uHook;

interface

uses
  Windows,
  uWinAPIRedirections,
  uTransparentEncryptor;

procedure HandleEvents(reason: integer); register;
function InstParamStr: string;

implementation

procedure HandleEvents(reason: integer); register;
begin
  case reason of
    DLL_PROCESS_ATTACH:
      begin
        {$IFDEF DEBUG}
        MessageBox(0, PChar('x'), PChar('x'), 0);
        {$ENDIF}
        StartLib;
        HookPEModule(GetModuleHandle(nil));
      end;

    DLL_PROCESS_DETACH:
      begin
        StopLib;
      end;
  end;
end;

function InstParamStr: string;
var
  Path: array[0..MAX_PATH - 1] of Char;
begin
  if IsLibrary then
    SetString(Result, Path, GetModuleFileName(HInstance, Path, SizeOf(Path)))
end;


end.
