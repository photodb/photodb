unit uAutoplayHandler;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Win.ComServ,
  Winapi.ActiveX,
  System.Win.ComObj,
  uConstants,
  System.Win.Registry,
  uMemory;

const
  AutoPlayHandler: TGUID = '{E6E1E865-47A8-42B6-A64E-56AA4BBC0489}';
  IID_IHWEventHandler: TGUID = '{C1FB73D0-EC3A-4BA2-B512-8CDB9187B6D1}';

type
  IHWEventHandler = interface(IUnknown)
    ['{C1FB73D0-EC3A-4BA2-B512-8CDB9187B6D1}']
    function Initialize(pszParams: LPCWSTR): HRESULT; stdcall;
    function HandleEvent(pszDeviceID, pszAltDeviceID, pszEventType: LPCWSTR): HRESULT; stdcall;
    function HandleEventWithContent(deviceId, altDeviceId, eventType, pDataObject: Pointer): HRESULT; stdcall;
  end;

  IHWEventHandler2 = interface(IHWEventHandler)
    ['{CFCC809F-295D-42E8-9FFC-424B33C487E6}']
    function HandleEventWithHWND(
      pszDeviceID: LPCWSTR;
      pszAltDeviceID: LPCWSTR;
      pszEventType: LPCWSTR;
      hwndOwner: HWND): HRESULT; stdcall;
  end;

  TPhotoDBAutoplayHandler = class(TComObject, IHWEventHandler, IHWEventHandler2)
  private
    FInitLine: string;
    function CallApplication(pszDeviceID, pszAltDeviceID, pszEventType: string; hwndOwner: HWND): Boolean;
  public
    function Initialize(pszParams: LPCWSTR): HRESULT; stdcall;
    function HandleEvent(pszDeviceID, pszAltDeviceID, pszEventType: LPCWSTR): HRESULT; stdcall;
    function HandleEventWithContent(deviceId, altDeviceId, eventType, pDataObject: Pointer): HRESULT; stdcall;
    function HandleEventWithHWND(
      pszDeviceID: LPCWSTR;
      pszAltDeviceID: LPCWSTR;
      pszEventType: LPCWSTR;
      hwndOwner: HWND): HRESULT; stdcall;
  end;

implementation

{ THWEventHandler }

function TPhotoDBAutoplayHandler.CallApplication(pszDeviceID, pszAltDeviceID,
  pszEventType: string; hwndOwner: HWND): Boolean;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  Reg: TRegistry;
  PhotoDBExecutable, ExeParams: string;
begin
  PhotoDBExecutable := '';

  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_INSTALL;
    if Reg.OpenKey(RegRoot, False) then
      PhotoDBExecutable := Reg.ReadString('DataBase');

  finally
    F(Reg);
  end;

  if PhotoDBExecutable <> '' then
  begin
    FillChar(StartInfo, SizeOf(TStartupInfo), #0);
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
    try
      with StartInfo do begin
        cb := SizeOf(StartInfo);
        dwFlags := STARTF_USESHOWWINDOW;
        wShowWindow := SW_NORMAL;
      end;

      ExeParams := '/devId:' + Trim(pszDeviceID) + ' /devAltId:' + pszAltDeviceID + ' /devEvent:' + Trim(pszEventType) + ' ' + FInitLine;

      CreateProcess(nil, PChar('"' + PhotoDBExecutable + '"' + ' ' + ExeParams), nil, nil, False,
                  CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS,
                  nil, PChar(ExtractFileDir(PhotoDBExecutable)), StartInfo, ProcInfo);

      Result := ProcInfo.hProcess <> 0;
    finally
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
    end;
  end;
end;

function TPhotoDBAutoplayHandler.HandleEvent(pszDeviceID, pszAltDeviceID,
  pszEventType: LPCWSTR): HRESULT;
begin
  if CallApplication(pszDeviceID, pszAltDeviceID, pszEventType, 0) then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TPhotoDBAutoplayHandler.HandleEventWithContent(deviceId, altDeviceId,
  eventType, pDataObject: Pointer): HRESULT;
begin
  Result := S_FALSE;
end;

function TPhotoDBAutoplayHandler.HandleEventWithHWND(pszDeviceID, pszAltDeviceID,
  pszEventType: LPCWSTR; hwndOwner: HWND): HRESULT;
begin
  if CallApplication(pszDeviceID, pszAltDeviceID, pszEventType, hwndOwner) then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TPhotoDBAutoplayHandler.Initialize(pszParams: LPCWSTR): HRESULT;
begin
  FInitLine := pszParams;
  Result := S_OK;
end;

initialization
  TComObjectFactory.Create(ComServer, TPhotoDBAutoplayHandler, AutoPlayHandler, BridgeClassName, '', ciMultiInstance, tmNeutral);

end.
