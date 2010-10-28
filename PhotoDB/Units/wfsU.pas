unit wfsU;

interface

uses Classes, SysUtils, Windows, Dolphin_DB, Forms, GraphicsBaseTypes, uLogger,
  uGOM, ExplorerTypes, uMemory, SyncObjs, uTime;

type
  WFSError = class(Exception);

const
  WathBufferSize = 65535;

type
  TWFS = class(TThread)
  private
    FName: string;
    FFilter: Cardinal;
    FSubTree: Boolean;
    FInfoCallback: TWatchFileSystemCallback;
    FWatchHandle: THandle;
    FWatchBuf: array [0 .. WathBufferSize - 1] of Byte;
    FOverLapp: TOverlapped;
    FPOverLapp: POverlapped;
    FBytesWritte: DWORD;
    FCompletionPort: THandle;
    FNumBytes: Cardinal;
    FOldFileName: string;
    InfoCallback: TInfoCallBackDirectoryChangedArray;
    FOnNeedClosing: TNotifyEvent;
    FOnThreadClosing: TNotifyEvent;
    FPublicOwner : TObject;
    function CreateDirHandle(ADir: string): THandle;
    procedure WatchEvent;
    procedure HandleEvent;
  protected
    procedure Execute; override;
    procedure DoCallBack;
    procedure TDoTerminate;
    procedure DoClosingEvent;
  public
    constructor Create(PublicOwner : TObject; pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback; OnNeedClosing, OnThreadClosing : TNotifyEvent);
    destructor Destroy; override;
  end;

  TWachDirectoryClass = class(TObject)
  private
    WFS: TWFS;
    FOnDirectoryChanged: TNotifyDirectoryChangeW;
    FCID: TGUID;
    FOwner: TForm;
    { Start monitoring file system
      Parametrs:
      pName    - Directory name for monitoring
      pFilter  - Monitoring type ( FILE_NOTIFY_XXX )
      pSubTree - Watch sub directories
      pInfoCallback - callback porcedure, this procedure called with synchronization for main thread }
    procedure StartWatch(PName: string; PFilter: Cardinal; PSubTree: Boolean;
      PInfoCallback: TWatchFileSystemCallback);
    procedure CallBack(PInfo: TInfoCallBackDirectoryChangedArray);
    procedure OnNeedClosing(Sender: TObject);
    procedure OnThreadClosing(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(Directory: string; Owner: TForm; CID: TGUID);
    // Остановка мониторинга
    procedure StopWatch;
  published
    property OnDirectoryChanged: TNotifyDirectoryChangeW read FOnDirectoryChanged write FOnDirectoryChanged;
  end;

var
  OM: TManagerObjects;

implementation

uses
  ExplorerUnit;

var
  FSync : TCriticalSection;

procedure TWachDirectoryClass.CallBack(PInfo: TInfoCallBackDirectoryChangedArray);
begin
  if ExplorerManager.IsExplorerForm(FOwner) then
    (FOwner as TExplorerForm).DirectoryChanged(Self, FCID, PInfo)
end;

constructor TWachDirectoryClass.Create;
begin
  OM.AddObj(Self);
end;

destructor TWachDirectoryClass.Destroy;
begin
  OM.RemoveObj(Self);
  inherited;
end;

procedure TWachDirectoryClass.OnNeedClosing(Sender: TObject);
begin
  if ExplorerManager.IsExplorerForm(FOwner) then
    (FOwner as TExplorerForm).Close
end;

procedure TWachDirectoryClass.OnThreadClosing(Sender: TObject);
begin
  //empty stub
end;

procedure TWachDirectoryClass.Start(Directory: string; Owner: TForm;
  CID: TGUID);
begin
  TW.I.Start('TWachDirectoryClass.Start');
  FCID := CID;
  FOwner := Owner;
  StartWatch(Directory, FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME	+ FILE_NOTIFY_CHANGE_CREATION +
      FILE_NOTIFY_CHANGE_LAST_WRITE, False, CallBack);
end;

procedure TWachDirectoryClass.StartWatch(PName: string; PFilter: Cardinal; PSubTree: Boolean;
  PInfoCallback: TWatchFileSystemCallback);
begin
  FSync.Enter;
  try
    TW.I.Start('TWFS.Create');
    WFS := TWFS.Create(Self, PName, PFilter, pSubTree, PInfoCallback, OnNeedClosing, OnThreadClosing);
  finally
    FSync.Leave;
  end;
end;

procedure TWachDirectoryClass.StopWatch;
begin
  FSync.Enter;
  try
    TW.I.Start('TWachDirectoryClass.StopWatch');
    if OM.IsObj(WFS) then
    begin
      PostQueuedCompletionStatus(WFS.FCompletionPort, 0, 0, nil);
      WFS.Terminate;
      WFS := nil;
    end;
  finally
    FSync.Leave;
  end;
end;

constructor TWFS.Create(PublicOwner : TObject; PName: string; PFilter: Cardinal; PSubTree: Boolean; PInfoCallback: TWatchFileSystemCallback;
  OnNeedClosing, OnThreadClosing: TNotifyEvent);
begin
  TW.I.Start('TWFS.Create');
  inherited Create(False);
  TW.I.Start('TWFS.Created');
  OM.AddObj(Self);
  FPublicOwner := PublicOwner;
  FName := IncludeTrailingBackslash(pName);
  FFilter := pFilter;
  FSubTree := pSubTree;
  FOldFileName := EmptyStr;
  ZeroMemory(@FOverLapp, SizeOf(TOverLapped));
  FPOverLapp := @FOverLapp;
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  FInfoCallback := PInfoCallback;
  FOnNeedClosing := OnNeedClosing;
  FOnThreadClosing := OnThreadClosing;
end;

destructor TWFS.Destroy;
begin
  FSync.Enter;
  try
    TW.I.Start('TWFS.Destroy');
    OM.RemoveObj(Self);
    PostQueuedCompletionStatus(FCompletionPort, 0, 0, nil);
    CloseHandle(FWatchHandle);
    CloseHandle(FCompletionPort);
    inherited;
  finally
    FSync.Leave;
  end;
end;

function TWFS.CreateDirHandle(aDir: string): THandle;
begin
  Result := CreateFile(PChar(aDir), FILE_LIST_DIRECTORY, FILE_SHARE_READ+FILE_SHARE_DELETE+FILE_SHARE_WRITE,
                   nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
end;

procedure TWFS.Execute;
begin
  TW.I.Start('TWFS.Execute - START');

  FreeOnTerminate := True;
  FWatchHandle := CreateDirHandle(FName);
  WatchEvent;
  Synchronize(DoClosingEvent);

  TW.I.Start('TWFS.Execute - END');
end;

procedure TWFS.HandleEvent;
var
  FInfoCallback  : TInfoCallback;
  Ptr: Pointer;
  FileName: PWideChar;
  NoMoreFilesFound, FileSkipped: Boolean;
  I: Integer;
begin
  SetLength(InfoCallback, 0);
  Ptr := @FWatchBuf[0];
  repeat
    GetMem(FileName, PFileNotifyInformation(Ptr).FileNameLength + 2);
    ZeroMemory(FileName, PFileNotifyInformation(Ptr).FileNameLength + 2);
    LstrcpynW(FileName, PFileNotifyInformation(Ptr).FileName, PFileNotifyInformation(Ptr).FileNameLength div 2 + 1);
    FileSkipped := False;
    NoMoreFilesFound := False;

    if TLockFiles.Instance.IsFileLocked(FName + FileName) then
    begin
      FreeMem(FileName);

      if PFileNotifyInformation(Ptr).NextEntryOffset = 0 then
        NoMoreFilesFound := True
      else
        Inc(Cardinal(Ptr), PFileNotifyInformation(Ptr).NextEntryOffset);

      FileSkipped := True;
    end;
    if NoMoreFilesFound then
      Break
    else if FileSkipped then
      Continue;

    FInfoCallback.FAction := PFileNotifyInformation(Ptr).Action;
    if (FInfoCallback.FAction = 0) then
    begin
      Synchronize(TDoTerminate); // CloseExplorer
      Terminate;
      Exit;
    end;
    FInfoCallback.FNewFileName := FName + FileName;
    case PFileNotifyInformation(Ptr).Action of
      FILE_ACTION_RENAMED_OLD_NAME:
        FOldFileName := FName + FileName;
      FILE_ACTION_RENAMED_NEW_NAME:
        FInfoCallback.FOldFileName := FOldFileName;
    end;
    if PFileNotifyInformation(Ptr).Action <> FILE_ACTION_RENAMED_OLD_NAME then
    begin
      SetLength(InfoCallback, Length(InfoCallback) + 1);
      InfoCallback[Length(InfoCallback) - 1] := FInfoCallback;
    end;

    FreeMem(FileName);

    if PFileNotifyInformation(Ptr).NextEntryOffset = 0 then
      Break
    else
      Inc(Cardinal(Ptr), PFileNotifyInformation(Ptr).NextEntryOffset);
  until Terminated;

  Synchronize(DoCallBack);
end;

procedure TWFS.WatchEvent;
var
  CompletionKey: Cardinal;
begin
  FCompletionPort := CreateIoCompletionPort(FWatchHandle, 0, Longint(Pointer(Self)), 0);
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  if not ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
    FFilter, @FBytesWritte,  @FOverLapp, nil) then
  begin
    //unable to watch - close thread
    Terminate;
  end else
  begin
    while not Terminated do
    begin
      GetQueuedCompletionStatus(FCompletionPort, FNumBytes, CompletionKey, FPOverLapp, INFINITE);
      if CompletionKey <> 0 then
      begin
        Synchronize(HandleEvent);
        if not Terminated then
        begin
          ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
          FBytesWritte := 0;
          ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree, FFilter,
                               @FBytesWritte, @FOverLapp, nil);
        end;
      end else
        Terminate;
    end
  end
end;

procedure TWFS.DoCallBack;
begin
  if OM.IsObj(FPublicOwner) then
    FInfoCallback(InfoCallback);
end;

procedure TWFS.TDoTerminate;
begin
  if OM.IsObj(FPublicOwner) then
    FOnNeedClosing(Self);
end;

procedure TWFS.DoClosingEvent;
begin
  if OM.IsObj(FPublicOwner) then
    FOnThreadClosing(Self);
end;

initialization

  OM := TManagerObjects.Create;
  FSync := TCriticalSection.Create;

finalization

  F(FSync);
  F(OM);

end.
