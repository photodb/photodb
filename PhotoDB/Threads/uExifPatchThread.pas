unit uExifPatchThread;

interface

uses
  SyncObjs,
  ActiveX,
  Classes,

  Dmitry.Utils.Files,

  uRuntime,
  uConstants,
  uMemory,
  UnitDBDeclare,
  uDBThread,
  uExifUtils,
  uDBUtils,
  uDBContext,
  uLockedFileNotifications;

type
  TExifPatchThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

  TExifPatchManager = class
  private
    FData: TList;
    FSync: TCriticalSection;
    FThreadCount: Integer;
    procedure RegisterThread;
    procedure UnRegisterThread;
    function ExtractPatchInfo: TExifPatchInfo;
    procedure StartThread;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddPatchInfo(Context: IDBContext; ID: Integer; Params: TEventFields; Value: TEventValues);
  end;

function ExifPatchManager: TExifPatchManager;

implementation

var
  FManager: TExifPatchManager = nil;

function ExifPatchManager: TExifPatchManager;
begin
  if FManager = nil then
    FManager := TExifPatchManager.Create;
  Result := FManager;
end;

{ TExifPatchThread }

procedure TExifPatchThread.Execute;
var
  Info: TExifPatchInfo;
  FileName: string;
  LastUpdateTime: Cardinal;
  Context: IDBContext;
  MediaRepository: IMediaRepository;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    ExifPatchManager.RegisterThread;
    try
      Info := ExifPatchManager.ExtractPatchInfo;
      LastUpdateTime := GetTickCount;
      while (Info <> nil) or (GetTickCount - LastUpdateTime < 10000) do
      begin
        if Info <> nil then
        begin
          Context := Info.Context;
          MediaRepository := Context.Media;

          LastUpdateTime := GetTickCount;
          FileName := Info.Value.FileName;
          if not FileExistsSafe(FileName) then
            FileName := MediaRepository.GetFileNameById(Info.ID);

          TLockFiles.Instance.AddLockedFile(FileName, 1000);
          UpdateFileExif(FileName, Info);
          F(Info);
        end;

        if DBTerminating then
          Break;

        Sleep(50);
        Info := ExifPatchManager.ExtractPatchInfo;
      end;
    finally
      ExifPatchManager.UnRegisterThread;
    end;
  finally
    CoUninitialize;
  end;
end;

{ TExifPatchManager }

procedure TExifPatchManager.AddPatchInfo(Context: IDBContext; ID: Integer; Params: TEventFields; Value: TEventValues);
var
  Info: TExifPatchInfo;
begin
  FSync.Enter;
  try
    Info := TExifPatchInfo.Create;
    Info.ID := ID;
    Info.Params := Params;
    Info.Value := Value;
    Info.Context := Context;
    FData.Add(Info);
    StartThread;
  finally
    FSync.Leave;
  end;
end;

constructor TExifPatchManager.Create;
begin
  FData := TList.Create;
  FSync := TCriticalSection.Create;
  FThreadCount := 0;
end;

destructor TExifPatchManager.Destroy;
begin
  FreeList(FData);
  F(FSync);
  inherited;
end;

function TExifPatchManager.ExtractPatchInfo: TExifPatchInfo;
begin
  Result := nil;
  FSync.Enter;
  try
    if FData.Count > 0 then
    begin
      Result := FData[0];
      FData.Delete(0);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExifPatchManager.RegisterThread;
begin
  Inc(FThreadCount);
end;

procedure TExifPatchManager.StartThread;
begin
  if (FThreadCount = 0) and (FData.Count > 0) then
    TExifPatchThread.Create(nil, False);
end;

procedure TExifPatchManager.UnRegisterThread;
begin
  Dec(FThreadCount);
  StartThread;
end;

initialization

finalization

 F(FManager);

end.
