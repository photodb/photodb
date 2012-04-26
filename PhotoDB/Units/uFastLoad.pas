unit uFastLoad;

interface

uses
  Windows,
  SysUtils,
  uDBCustomThread,
  uTime,
  uMemory,
  Forms,
  uSysUtils;

type
  TLoad = class(TObject)
  private
    //FAST LOAD
    LoadDBKernelIconsThreadID,
    LoadDBSettingsThreadID,
    LoadCRCCheckThreadID,
    LoadPersonsThreadID,
    LoadStyleThreadID: TGUID;
    procedure WaitForThread(Thread: TGUID);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TLoad;
    //Starts
    procedure StartDBKernelIconsThread;
    procedure StartDBSettingsThread;
    procedure StartCRCCheckThread;
    procedure StartPersonsThread;
    procedure StartStyleThread;
    //Requareds
    procedure RequaredCRCCheck;
    procedure RequaredDBKernelIcons;
    procedure RequaredDBSettings;
    procedure RequaredPersons;
    procedure RequaredStyle;
    procedure Stop;
  end;

implementation

uses
  UnitLoadDBSettingsThread,
  UnitLoadDBKernelIconsThread,
  UnitLoadCRCCheckThread,
  UnitLoadPersonsThread,
  uDBThread,
  uLoadStyleThread;

var
  SLoadInstance: TLoad = nil;

{ TLoad }

constructor TLoad.Create;
begin
  LoadDBKernelIconsThreadID := GetEmptyGUID;
  LoadDBSettingsThreadID := GetEmptyGUID;
  LoadCRCCheckThreadID := GetEmptyGUID;
  LoadPersonsThreadID := GetEmptyGUID;
  LoadStyleThreadID := GetEmptyGUID;
end;

destructor TLoad.Destroy;
begin
  inherited;
end;

class function TLoad.Instance: TLoad;
begin
  if SLoadInstance = nil then
    SLoadInstance := TLoad.Create;

  Result := SLoadInstance;
end;

procedure TLoad.StartDBSettingsThread;
var
  T: TDBThread;
begin
  T := TLoadDBSettingsThread.Create(nil, True);
  LoadDBSettingsThreadID := T.UniqID;
  T.Start;
end;

procedure TLoad.StartDBKernelIconsThread;
var
  T: TDBThread;
begin
  T := TLoadDBKernelIconsThread.Create(nil, True);
  LoadDBKernelIconsThreadID := T.UniqID;
  T.Start;
end;

procedure TLoad.StartPersonsThread;
var
  T: TDBThread;
begin
  T := TLoadPersonsThread.Create(nil, True);
  LoadPersonsThreadID := T.UniqID;
  T.Start;
end;

procedure TLoad.StartStyleThread;
var
  T: TDBThread;
begin
  T := TLoadStyleThread.Create(nil, True);
  LoadStyleThreadID := T.UniqID;
  T.Start;
end;

procedure TLoad.StartCRCCheckThread;
var
  T: TDBThread;
begin
  T := TLoadCRCCheckThread.Create(nil, True);
  LoadCRCCheckThreadID := T.UniqID;
  T.Start;
end;

procedure TLoad.Stop;

  procedure KillThread(Thread: TGUID);
  begin
    if DBThreadManager.IsThread(Thread) then
      TerminateThread(DBThreadManager.GetThreadHandle(Thread), 0);
  end;

begin
  KillThread(LoadDBKernelIconsThreadID);
  KillThread(LoadDBSettingsThreadID);
  KillThread(LoadCRCCheckThreadID);
  KillThread(LoadPersonsThreadID);
  KillThread(LoadStyleThreadID);
end;

procedure TLoad.WaitForThread(Thread: TGUID);
var
  H: THandle;
  C: Integer;
begin
  if DBThreadManager.IsThread(Thread) then
  begin
    H := DBThreadManager.GetThreadHandle(Thread);
    if H <> 0 then
    begin
      TW.I.Start('WaitForSingleObject: ' + IntToStr(H));
      C := 0;

      while (WAIT_TIMEOUT = WaitForSingleObject(H, 10)) do
      begin
        C := C + 10;
        Application.ProcessMessages;
        if C > 10000 then
          Break;
      end;
    end;
  end;
end;

procedure TLoad.RequaredCRCCheck;
begin
  TW.I.Start('TLoad.RequaredCRCCheck');
  if LoadCRCCheckThreadID <> GetEmptyGUID then
    WaitForThread(LoadCRCCheckThreadID);
  LoadCRCCheckThreadID := GetEmptyGUID;
end;

procedure TLoad.RequaredDBKernelIcons;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  if LoadDBKernelIconsThreadID <> GetEmptyGUID then
    WaitForThread(LoadDBKernelIconsThreadID);
  LoadDBKernelIconsThreadID := GetEmptyGUID;
end;

procedure TLoad.RequaredDBSettings;
begin
  TW.I.Start('TLoad.LoadDBSettingsThread');
  if LoadDBSettingsThreadID <> GetEmptyGUID then
    WaitForThread(LoadDBSettingsThreadID);
  LoadDBSettingsThreadID := GetEmptyGUID;
end;

procedure TLoad.RequaredPersons;
begin
  TW.I.Start('TLoad.RequaredPersons');
  if LoadPersonsThreadID <> GetEmptyGUID then
    WaitForThread(LoadPersonsThreadID);
  LoadPersonsThreadID := GetEmptyGUID;
end;

procedure TLoad.RequaredStyle;
begin
  TW.I.Start('TLoad.RequaredStyle');
  if LoadStyleThreadID <> GetEmptyGUID then
    WaitForThread(LoadStyleThreadID);
  LoadStyleThreadID := GetEmptyGUID;
end;

initialization

finalization
  F(SLoadInstance);

end.
