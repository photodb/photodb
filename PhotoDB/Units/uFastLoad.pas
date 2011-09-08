unit uFastLoad;

interface

uses WIndows, SysUtils, uDBThread, uTime, uMemory;

type
  TLoad = class(TObject)
  private
    //FAST LOAD
    LoadDBKernelIconsThread,
    LoadDBSettingsThread,
    LoadCRCCheckThread : TDBThread;
    procedure WaitForThread(Thread: TDBThread);
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TLoad;
    //Starts
    procedure StartDBKernelIconsThread;
    procedure StartDBSettingsThread;
    procedure StartCRCCheckThread;
    //Requareds
    procedure RequaredCRCCheck;
    procedure RequaredDBKernelIcons;
    procedure RequaredDBSettings;
    procedure Stop;
  end;

implementation

uses
  UnitLoadDBSettingsThread,
  UnitLoadDBKernelIconsThread,
  UnitLoadCRCCheckThread;

var
  SLoadInstance : TLoad = nil;

{ TLoad }

constructor TLoad.Create;
begin
  LoadDBKernelIconsThread := nil;
  LoadDBSettingsThread := nil;
  LoadCRCCheckThread := nil;
end;

destructor TLoad.Destroy;
begin
  inherited;
end;

procedure TLoad.StartDBKernelIconsThread;
begin
  LoadDBKernelIconsThread := TLoadDBKernelIconsThread.Create(nil, False);
end;

class function TLoad.Instance: TLoad;
begin
  if SLoadInstance = nil then
    SLoadInstance := TLoad.Create;

  Result := SLoadInstance;
end;

procedure TLoad.StartDBSettingsThread;
begin
  LoadDBSettingsThread := TLoadDBSettingsThread.Create(nil, False);
end;

procedure TLoad.Stop;

  procedure KillThread(Thread: TDBThread);
  begin
    if DBThreadManager.IsThread(Thread) then
      TerminateThread(DBThreadManager.GetThreadHandle(Thread), 0);
  end;

begin
  KillThread(LoadDBKernelIconsThread);
  KillThread(LoadDBSettingsThread);
  KillThread(LoadCRCCheckThread);
end;

procedure TLoad.WaitForThread(Thread: TDBThread);
begin
  if DBThreadManager.IsThread(Thread) then
    WaitForSingleObject(DBThreadManager.GetThreadHandle(Thread), 10000);
end;

procedure TLoad.StartCRCCheckThread;
begin
  LoadCRCCheckThread := TLoadCRCCheckThread.Create(nil, False);
end;

procedure TLoad.RequaredCRCCheck;
begin
  TW.I.Start('TLoad.RequaredCRCCheck');
  WaitForThread(LoadCRCCheckThread);
end;

procedure TLoad.RequaredDBKernelIcons;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  WaitForThread(LoadDBKernelIconsThread);
end;

procedure TLoad.RequaredDBSettings;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  WaitForThread(LoadDBSettingsThread);
end;

initialization

finalization

  F(SLoadInstance);

end.
