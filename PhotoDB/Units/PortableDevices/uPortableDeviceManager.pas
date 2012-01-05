unit uPortableDeviceManager;

interface

uses
  uPortableClasses,
  uWIAClasses,
  uSysUtils,
  uWPDClasses;

function CreateDeviceManagerInstance: IPManager;

implementation

function CreateDeviceManagerInstance: IPManager;
begin
  if IsWindowsVista then
    Result := TWPDDeviceManager.Create
  else
    Result := TWIADeviceManager.Create;
end;

end.
