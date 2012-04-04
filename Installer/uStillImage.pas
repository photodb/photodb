unit uStillImage;

interface

uses
  uMemory,
  SysUtils,
  Classes,
  ActiveX,
  Registry,
  Windows;

const
  stillDll = 'Sti.dll';

  CLSID_Sti: TGUID = '{B323F8E0-2E68-11D0-90EA-00AA0060F86C}';
  IID_IStillImageW: TGUID = '{641BD880-2DC8-11D0-90EA-00AA0060F86C}';

type
  IStillImageW = interface(IUnknown)
    // IStillImage methods
    function Initialize(hinst: HINST; dwVersion: DWORD): HRESULT; stdcall;

    function GetDeviceList(dwType: DWORD; dwFlags: DWORD; out pdwItemsReturned: PDWORD; out ppBuffer: Pointer): HRESULT; stdcall;
    function GetDeviceInfo(pwszDeviceName: LPWSTR; out ppBuffer: Pointer): HRESULT; stdcall;

    function CreateDevice(pwszDeviceName: LPWSTR; dwMode: DWORD; out pDevice: IUnknown; punkOuter: IUnknown): HRESULT; stdcall;
    //
    // Device instance values. Used to associate various data with device.
    //
    function GetDeviceValue(pwszDeviceName: LPWSTR; pValueName: LPWSTR; out pType: LPDWORD; out pData: Pointer; var cbData: LPDWORD): HRESULT; stdcall;
    function SetDeviceValue(pwszDeviceName: LPWSTR; pValueName: LPWSTR; out pType: LPDWORD; out pData: Pointer; var cbData: LPDWORD): HRESULT; stdcall;
    //
    // For appllication started through push model launch, returns associated information
    //
    function GetSTILaunchInformation(pwszDeviceName: LPWSTR; out pdwEventCode: PDWORD; out pwszEventName: LPWSTR): HRESULT; stdcall;
    function RegisterLaunchApplication(pwszAppName: LPWSTR; pwszCommandLine: LPWSTR): HRESULT; stdcall;
    function UnregisterLaunchApplication(pwszAppName: LPWSTR): HRESULT; stdcall;
  end;

//Pointer to a null-terminated string that contains the full path to the executable file for this application. Additional command line arguments can be appended to this command. Two pairs of quotation marks should be used, for example, "\"C:\Program Files\MyExe.exe\" /arg1".
function RegisterStillHandler(Name, CommandLine: string): Boolean;
function UnRegisterStillHandler(Name: string): Boolean;

implementation

function RegisterStillHandler(Name, CommandLine: string): Boolean;
var
  HR: HRESULT;
  StillImage: IStillImageW;
begin
  Result := False;
  HR := CoCreateInstance (CLSID_Sti, nil, CLSCTX_INPROC_SERVER, IID_IStillImageW, StillImage);
  if Succeeded(HR) then
  begin
    HR := StillImage.RegisterLaunchApplication(PChar(Name), PChar(CommandLine));
    Result := Succeeded(HR);
  end;
end;

function UnRegisterStillHandler(Name: string): Boolean;
const
  EventsLocation = 'SYSTEM\CurrentControlSet\Control\StillImage\Events\STIProxyEvent';
var
  HR: HRESULT;
  StillImage: IStillImageW;
  Reg: TRegistry;
  I: Integer;
  EventList: TStrings;
begin
  Result := False;
  HR := CoCreateInstance (CLSID_Sti, nil, CLSCTX_INPROC_SERVER, IID_IStillImageW, StillImage);
  if Succeeded(HR) then
  begin
    HR := StillImage.UnregisterLaunchApplication(PChar(Name));
    Result := Succeeded(HR);
  end;

  //for some reason unregistered application is still visible in registry, so clean-up manually
  Reg := TRegistry.Create;
  try
    Reg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(EventsLocation, False) then
    begin
      EventList := TStringList.Create;
      try
        Reg.GetKeyNames(EventList);
        Reg.CloseKey;
        for I := 0 to EventList.Count - 1 do
        begin
          if Reg.OpenKey(EventsLocation + '\' + EventList[I], False) then
          begin
            if Reg.ReadString('Name') = Name then
            begin
              Reg.CloseKey;
              Reg.DeleteKey(EventsLocation + '\' + EventList[I]);
              Reg.DeleteKey('SOFTWARE\Classes\CLSID\' + EventList[I]);
            end else
              Reg.CloseKey;
          end;
        end;
      finally
        F(EventList);
      end;
    end;
  finally
    F(Reg);
  end;
end;

end.

