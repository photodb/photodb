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
function IsWPDSupport: Boolean;

implementation

function IsWPDSupport: Boolean;
var
  IsWPDAvailable: Boolean;
begin
  if GetParamStrDBBool('/FORCEWIA') then
    Exit(False);
  if GetParamStrDBBool('/FORCEWPD') then
    Exit(True);

  IsWPDAvailable := False;
  //Vista SP1
  if (TOSVersion.Major = 6) and (TOSVersion.Minor = 0) and (TOSVersion.ServicePackMajor >= 1) then
    IsWPDAvailable := True;
  //Windows7 and higher
  if (TOSVersion.Major = 6) and (TOSVersion.Minor >= 1) then
    IsWPDAvailable := True;

  Result := IsWPDAvailable;
end;

function CreateDeviceManagerInstance: IPManager;
begin
  if IsWPDSupport then
    Result := TWPDDeviceManager.Create
  else
    Result := TWIADeviceManager.Create;
end;

end.
