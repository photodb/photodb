unit uFastLoad;

interface

uses
  WIndows, SysUtils, uDBThread, uTime, uMemory, uSysUtils;

type
  TLoad = class(TObject)
  private
    //FAST LOAD
    LoadDBKernelIconsThreadID,
    LoadDBSettingsThreadID,
    LoadCRCCheckThreadID,
    LoadPersonsThreadID: TGUID;
    procedure WaitForThread(Thread: TGUID);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TLoad;
    //Starts
    procedure StartDBKernelIconsThread;
    procedure StartDBSettingsThread;
    procedure StartCRCCheckThread;
    procedure StartPersonsThread;
    //Requareds
    procedure RequaredCRCCheck;
    procedure RequaredDBKernelIcons;
    procedure RequaredDBSettings;
    procedure RequaredPersons;
    procedure Stop;
  end;

implementation

uses
  UnitLoadDBSettingsThread,
  UnitLoadDBKernelIconsThread,
  UnitLoadCRCCheckThread,
  UnitLoadPersonsThread;

var
  SLoadInstance : TLoad = nil;

{ TLoad }

constructor TLoad.Create;
begin
  LoadDBKernelIconsThreadID := GetEmptyGUID;
  LoadDBSettingsThreadID := GetEmptyGUID;
  LoadCRCCheckThreadID := GetEmptyGUID;
  LoadPersonsThreadID := GetEmptyGUID;
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
end;

procedure TLoad.WaitForThread(Thread: TGUID);
var
  H: THandle;
begin
  if DBThreadManager.IsThread(Thread) then
  begin
    H := DBThreadManager.GetThreadHandle(Thread);
    if H <> 0 then
    begin
      TW.I.Start('WaitForSingleObject: ' + IntToStr(H));
      WaitForSingleObject(H, 10000);
    end;
  end;
end;

procedure TLoad.RequaredCRCCheck;
begin
  TW.I.Start('TLoad.RequaredCRCCheck');
  WaitForThread(LoadCRCCheckThreadID);
end;

procedure TLoad.RequaredDBKernelIcons;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  WaitForThread(LoadDBKernelIconsThreadID);
end;

procedure TLoad.RequaredDBSettings;
begin
  TW.I.Start('TLoad.LoadDBSettingsThread');
  WaitForThread(LoadDBSettingsThreadID);
end;

procedure TLoad.RequaredPersons;
begin
  TW.I.Start('TLoad.RequaredPersons');
  WaitForThread(LoadPersonsThreadID);
end;

initialization

finalization

  F(SLoadInstance);

end.
