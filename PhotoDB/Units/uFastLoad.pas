unit uFastLoad;

interface

uses WIndows, SysUtils, UnitDBThread, uTime, uMemory;

type
  TLoad = class(TObject)
  private
    //FAST LOAD
    LoadDBKernelIconsThread,
    LoadDBSettingsThread,
    LoadCRCCheckThread : TDBThread;
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
  F(LoadDBKernelIconsThread);
  F(LoadDBSettingsThread);
  F(LoadCRCCheckThread);
  inherited;
end;

procedure TLoad.StartDBKernelIconsThread;
begin
  LoadDBKernelIconsThread := TLoadDBKernelIconsThread.Create(False);
end;

class function TLoad.Instance: TLoad;
begin
  if SLoadInstance = nil then
    SLoadInstance := TLoad.Create;

  Result := SLoadInstance;
end;

procedure TLoad.StartDBSettingsThread;
begin
  LoadDBSettingsThread := TLoadDBSettingsThread.Create(False);
end;

procedure TLoad.Stop;
begin
  if not LoadDBKernelIconsThread.IsTerminated then
    TerminateThread(LoadDBKernelIconsThread.Handle, 0);
  if not LoadDBSettingsThread.IsTerminated then
    TerminateThread(LoadDBSettingsThread.Handle, 0);
  if not LoadCRCCheckThread.IsTerminated then
    TerminateThread(LoadCRCCheckThread.Handle, 0);
  F(LoadDBKernelIconsThread);
  F(LoadDBSettingsThread);
  F(LoadCRCCheckThread);
end;

procedure TLoad.StartCRCCheckThread;
begin
  LoadCRCCheckThread := TLoadCRCCheckThread.Create(False);
end;

procedure TLoad.RequaredCRCCheck;
begin
  TW.I.Start('TLoad.RequaredCRCCheck');
  if LoadCRCCheckThread <> nil then
  begin
    if not LoadCRCCheckThread.IsTerminated then
      WaitForSingleObject(LoadCRCCheckThread.Handle, INFINITE);
    F(LoadCRCCheckThread);
  end;
end;

procedure TLoad.RequaredDBKernelIcons;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  if LoadDBKernelIconsThread <> nil then
  begin
    if not LoadDBKernelIconsThread.IsTerminated then
      WaitForSingleObject(LoadDBKernelIconsThread.Handle, INFINITE);
    F(LoadDBKernelIconsThread);
  end;
end;

procedure TLoad.RequaredDBSettings;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  if LoadDBSettingsThread <> nil then
  begin
    if not LoadDBSettingsThread.IsTerminated then
      WaitForSingleObject(LoadDBSettingsThread.Handle, INFINITE);
    F(LoadDBSettingsThread);
  end;
end;

initialization

finalization

  F(SLoadInstance);

end.
