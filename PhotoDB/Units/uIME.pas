unit uIME;

interface

uses
  Winapi.Windows;

type
  TpImmDisableIME = function(idThread: DWORD): BOOL; stdcall;

procedure DisableIME;

implementation

var
  hModuleImm32: THandle = 0;
  pImmDisableIME: TpImmDisableIME = nil;

procedure DisableIME;
begin
  if hModuleImm32 = 0 then
  begin
    hModuleImm32 := LoadLibrary('imm32.dll');
    if (hModuleImm32 > 0) then
      pImmDisableIME := GetProcAddress(hModuleImm32, 'ImmDisableIME');
  end;
  if Assigned(pImmDisableIME) then
    pImmDisableIME(0);
end;

end.
