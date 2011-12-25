unit uExifPatchThread;

interface

uses
  Classes, uMemory, UnitDBDeclare, uDBThread, uExifUtils, SyncObjs, ActiveX,
  uDBUtils, uFileUtils, uConstants;

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
    procedure AddPatchInfo(ID: Integer; Params: TEventFields; Value: TEventValues);
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
begin
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    ExifPatchManager.RegisterThread;
    try
      Info := ExifPatchManager.ExtractPatchInfo;
      while Info <> nil do
      begin
        FileName := Info.Value.Name;
        if not FileExistsSafe(FileName) then
          FileName := uDBUtils.GetFileNameById(Info.ID);
          
        UpdateFileExif(FileName, Info);
        F(Info);
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

procedure TExifPatchManager.AddPatchInfo(ID: Integer; Params: TEventFields; Value: TEventValues);
var
  Info: TExifPatchInfo;
begin
  FSync.Enter;
  try
    Info := TExifPatchInfo.Create;
    Info.ID := ID;
    Info.Params := Params;
    Info.Value := Value;
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
