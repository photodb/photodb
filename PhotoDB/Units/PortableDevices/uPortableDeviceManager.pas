unit uPortableDeviceManager;

interface

uses
  uPortableClasses,
  uWIAClasses,
  uSysUtils,
  uAppUtils,
  System.SysUtils,
  uWPDClasses;

function CreateDeviceManagerInstance: IPManager;

implementation

function CreateDeviceManagerInstance: IPManager;
var
  IsWPDAvailable: Boolean;
begin
  if GetParamStrDBBool('/FORCEWIA') then
    Exit(TWIADeviceManager.Create);
  if GetParamStrDBBool('/FORCEWPD') then
    Exit(TWPDDeviceManager.Create);

  IsWPDAvailable := False;
  //Vista SP2
  if (TOSVersion.Major = 6) and (TOSVersion.Minor = 0) and (TOSVersion.ServicePackMajor >= 2) then
    IsWPDAvailable := True;
  //Windows7 and higher
  if (TOSVersion.Major = 6) and (TOSVersion.Minor >= 1) then
    IsWPDAvailable := True;

  if IsWPDAvailable then
    Result := TWPDDeviceManager.Create
  else
    Result := TWIADeviceManager.Create;
end;

end.
