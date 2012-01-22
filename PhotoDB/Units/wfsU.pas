unit wfsU;

interface

uses
  Classes, SysUtils, Windows, Dolphin_DB, Forms, GraphicsBaseTypes, uLogger,
  uGOM, ExplorerTypes, uMemory, SyncObjs, uTime, uThreadEx, uDBThread,
  uThreadForm;

type
  WFSError = class(Exception);

const
  WathBufferSize = 165535;

type
  TWFS = class(TDBThread)
  private
    FName: string;
    FFilter: Cardinal;
    FSubTree: Boolean;
    FInfoCallback: TWatchFileSystemCallback;
    FWatchHandle: THandle;
    FWatchBuf: array [0 .. WathBufferSize - 1] of Byte;
    FOverLapp: TOverlapped;
    FPOverLapp: POverlapped;
    FBytesWrite: DWORD;
    FCompletionPort: THandle;
    FNumBytes: NativeUInt;
    FOldFileName: string;
    InfoCallback: TInfoCallBackDirectoryChangedArray;
    FOnNeedClosing: TThreadExNotify;
    FOnThreadClosing: TNotifyEvent;
    FPublicOwner : TObject;
    FCID : TGUID;
    function CreateDirHandle(ADir: string): THandle;
    procedure WatchEvent;
    procedure HandleEvent;
  protected
    procedure Execute; override;
    procedure DoCallBack;
    procedure TDoTerminate;
    procedure DoClosingEvent;
  public
    constructor Create(PublicOwner: TObject; pName: string;
      pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback;  OnNeedClosing: TThreadExNotify; OnThreadClosing : TNotifyEvent; CID : TGUID);
    destructor Destroy; override;
  end;

  TWachDirectoryClass = class(TObject)
  private
    WFS: TWFS;
    FOnDirectoryChanged: TNotifyDirectoryChangeW;
    FCID: TGUID;
    FOwner: TThreadForm;
    { Start monitoring file system
      Parametrs:
      pName    - Directory name for monitoring
      pFilter  - Monitoring type ( FILE_NOTIFY_XXX )
      pSubTree - Watch sub directories
      pInfoCallback - callback porcedure, this procedure called with synchronization for main thread }
    procedure StartWatch(PName: string; PFilter: Cardinal; PSubTree: Boolean;
      PInfoCallback: TWatchFileSystemCallback; CID : TGUID);
    procedure CallBack(PInfo: TInfoCallBackDirectoryChangedArray);
    procedure OnNeedClosing(Sender: TObject; StateID : TGUID);
    procedure OnThreadClosing(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(Directory: string; Owner: TThreadForm; CID: TGUID);
    procedure StopWatch;
    property OnDirectoryChanged: TNotifyDirectoryChangeW read FOnDirectoryChanged write FOnDirectoryChanged;
  end;

  TIoCompletionManager = class(TObject)
  private
    FList : TList;
    FCounter : Cardinal;
    FSync : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance : TIoCompletionManager;
    function CreateIoCompletion(Handle: THandle; var CompletionKey: NativeUInt) : THandle;
    procedure FinishIoCompletion(CompletionPort: THandle);
    procedure GetQueuedCompletionStatus(CompletionPort: THandle;
      var lpNumberOfBytesTransferred, lpCompletionKey: NativeUInt;
      var lpOverlapped: POverlapped);
  end;

implementation

uses
  ExplorerUnit, uManagerExplorer;

var
  OM: TManagerObjects = nil;
  FSync : TCriticalSection = nil;
  FIoCompletionManager : TIoCompletionManager = nil;

procedure TWachDirectoryClass.CallBack(PInfo: TInfoCallBackDirectoryChangedArray);
begin
  if ExplorerManager.IsExplorerForm(FOwner) then
    (FOwner as TExplorerForm).DirectoryChanged(Self, FCID, PInfo)
end;

constructor TWachDirectoryClass.Create;
begin
  WFS := nil;
  OM.AddObj(Self);
end;

destructor TWachDirectoryClass.Destroy;
begin
  OM.RemoveObj(Self);
  inherited;
end;

procedure TWachDirectoryClass.OnNeedClosing(Sender: TObject; StateID : TGUID);
begin
  if ExplorerManager.IsExplorerForm(FOwner) then
    if FOwner.IsActualState(StateID) then
      (FOwner as TExplorerForm).Close
end;

procedure TWachDirectoryClass.OnThreadClosing(Sender: TObject);
begin
  //empty stub
end;

procedure TWachDirectoryClass.Start(Directory: string; Owner: TThreadForm;
  CID: TGUID);
begin
  TW.I.Start('TWachDirectoryClass.Start');
  FCID := CID;
  FOwner := Owner;
  FSync.Enter;
  try
    StartWatch(Directory, FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME + FILE_NOTIFY_CHANGE_CREATION +
        FILE_NOTIFY_CHANGE_LAST_WRITE, False, CallBack, CID);
  finally
    FSync.Leave;
  end;
end;

procedure TWachDirectoryClass.StartWatch(PName: string; PFilter: Cardinal; PSubTree: Boolean;
  PInfoCallback: TWatchFileSystemCallback; CID : TGUID);
begin
  TW.I.Start('TWFS.Create');
  WFS := TWFS.Create(Self, PName, PFilter, pSubTree, PInfoCallback, OnNeedClosing, OnThreadClosing, CID);
end;

procedure TWachDirectoryClass.StopWatch;
var
  Port : THandle;
begin     
  Port := 0;
  FSync.Enter;
  try
    TW.I.Start('TWachDirectoryClass.StopWatch');
    if OM.IsObj(WFS) then
    begin
      Port := WFS.FCompletionPort;
      WFS.Terminate;
      WFS := nil;
    end;
  finally
    FSync.Leave;
  end;
  if Port <> 0 then
  begin
    TW.I.Start('StopWatch.CLOSE = ' + IntToStr(Port));
    TIoCompletionManager.Instance.FinishIoCompletion(Port);
  end;
end;

constructor TWFS.Create(PublicOwner: TObject; PName: string; PFilter: Cardinal; PSubTree: Boolean; PInfoCallback: TWatchFileSystemCallback;
  OnNeedClosing: TThreadExNotify; OnThreadClosing : TNotifyEvent; CID : TGUID);
begin
  TW.I.Start('TWFS.Create');
  inherited Create(nil, False);
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
  FCID := CID;
end;

destructor TWFS.Destroy;
begin
  FSync.Enter;
  try
    TW.I.Start('TWFS.Destroy');
    TW.I.Start('Destroy.CLOSE = ' + IntToStr(FCompletionPort));
    TIoCompletionManager.Instance.FinishIoCompletion(FCompletionPort);
    CloseHandle(FWatchHandle);
    CloseHandle(FCompletionPort);
    inherited;
  finally
    FSync.Leave;
  end;
end;

function TWFS.CreateDirHandle(aDir: string): THandle;
var
  Dir: string;
begin
  Dir := ExcludeTrailingBackslash(aDir);
  //drive should be like c:\
  if Length(Dir) = 2 then
    Dir := IncludeTrailingBackslash(Dir);
  Result := CreateFile(PChar(Dir),
              FILE_LIST_DIRECTORY, FILE_SHARE_READ + FILE_SHARE_DELETE + FILE_SHARE_WRITE,
              nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
end;

procedure TWFS.Execute;
begin
  inherited;
  TW.I.Start('TWFS.Execute - START');

  FreeOnTerminate := True;
  FWatchHandle := CreateDirHandle(FName);
  WatchEvent;
  Synchronize(DoClosingEvent);
  OM.RemoveObj(Self);

  TW.I.Start('TWFS.Execute - END');
end;

procedure TWFS.HandleEvent;
var
  FInfoCallback  : TInfoCallback;
  Ptr: Pointer;
  FileName: PWideChar;
  NoMoreFilesFound, FileSkipped: Boolean;
begin
  SetLength(InfoCallback, 0);
  Ptr := @FWatchBuf[0];
  repeat
    GetMem(FileName, PFileNotifyInformation(Ptr).FileNameLength + 2);
    try
      ZeroMemory(FileName, PFileNotifyInformation(Ptr).FileNameLength + 2);
      LstrcpynW(FileName, PFileNotifyInformation(Ptr).FileName, PFileNotifyInformation(Ptr).FileNameLength div 2 + 1);
      FileSkipped := False;
      NoMoreFilesFound := False;

      if TLockFiles.Instance.IsFileLocked(FName + FileName) then
      begin
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
      if (FInfoCallback.FAction = 0) and (FileName = '') and not DirectoryExists(FName + FileName) then
      begin
        TW.I.Start('EXPLORER - CLOSE, file = "' + FName + FileName + '", BytesWrite = ' + IntToStr(FBytesWrite)
        + ' hEvent = ' + IntToStr(FPOverLapp.hEvent)
        + ' Internal = ' + IntToStr(FPOverLapp.Internal)
        + ' InternalHigh = ' + IntToStr(FPOverLapp.InternalHigh)
        + ' Offset = ' + IntToStr(FPOverLapp.Offset)
        + ' OffsetHigh = ' + IntToStr(FPOverLapp.OffsetHigh));

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

    finally
      FreeMem(FileName);
    end;

    if PFileNotifyInformation(Ptr).NextEntryOffset = 0 then
      Break
    else
      Inc(Cardinal(Ptr), PFileNotifyInformation(Ptr).NextEntryOffset);
  until Terminated;

  Synchronize(DoCallBack);
end;

procedure TWFS.WatchEvent;
var
  CompletionKey: NativeUInt;
begin
  FCompletionPort := TIoCompletionManager.Instance.CreateIoCompletion(FWatchHandle, CompletionKey);
  TW.I.Start('FCompletionPort = ' + IntToStr(FCompletionPort));
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  if not ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
    FFilter, @FBytesWrite,  @FOverLapp, nil) then
  begin
    //unable to watch - close thread
    Terminate;
  end else
  begin
    while not Terminated do
    begin
      TIoCompletionManager.Instance.GetQueuedCompletionStatus(FCompletionPort, FNumBytes, CompletionKey, FPOverLapp);
      if CompletionKey <> 0 then
      begin

        TW.I.Start('CompletionKey <> 0, BytesWrite = ' + IntToStr(FBytesWrite)
        + ' CompletionKey = ' + IntToStr(CompletionKey)
        + ' FCompletionPort = ' + IntToStr(FCompletionPort)
        + ' hEvent = ' + IntToStr(FPOverLapp.hEvent)
        + ' Internal = ' + IntToStr(FPOverLapp.Internal)
        + ' InternalHigh = ' + IntToStr(FPOverLapp.InternalHigh)
        + ' Offset = ' + IntToStr(FPOverLapp.Offset)
        + ' OffsetHigh = ' + IntToStr(FPOverLapp.OffsetHigh));

        Synchronize(HandleEvent);
        if not Terminated then
        begin
          ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
          FBytesWrite := 0;
          ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree, FFilter,
                               @FBytesWrite, @FOverLapp, nil);
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
    FOnNeedClosing(Self, FCID);
end;

procedure TWFS.DoClosingEvent;
begin
  if OM.IsObj(FPublicOwner) then
    FOnThreadClosing(Self);
end;

{ TIoCompletionManager }

constructor TIoCompletionManager.Create;
begin
  FSync := TCriticalSection.Create;
  FList := TList.Create;
  FCounter := 0;
end;

function TIoCompletionManager.CreateIoCompletion(Handle: THandle; var CompletionKey: NativeUInt): THandle;
begin
  FSync.Enter;
  try
    Inc(FCounter);
    CompletionKey := FCounter;
    Result := CreateIoCompletionPort(Handle, 0, CompletionKey, 0);
    FList.Add(Pointer(Result));
  finally
    FSync.Leave;
  end;
end;

destructor TIoCompletionManager.Destroy;
begin
  F(FList);
  F(FSync);
end;

procedure TIoCompletionManager.FinishIoCompletion(CompletionPort : THandle);
begin
  FSync.Enter;
  try
    if FList.IndexOf(Pointer(CompletionPort)) > -1 then
    begin
      FList.Remove(Pointer(CompletionPort));
      PostQueuedCompletionStatus(CompletionPort, 0, 0, nil);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TIoCompletionManager.GetQueuedCompletionStatus(
  CompletionPort: THandle; var lpNumberOfBytesTransferred,
  lpCompletionKey: NativeUInt; var lpOverlapped: POverlapped);
begin
  Windows.GetQueuedCompletionStatus(CompletionPort,
    lpNumberOfBytesTransferred,
    lpCompletionKey, lpOverlapped, INFINITE);
end;

class function TIoCompletionManager.Instance: TIoCompletionManager;
begin
  if FIoCompletionManager = nil then
    FIoCompletionManager := TIoCompletionManager.Create;

  Result := FIoCompletionManager;
end;

initialization

  OM := TManagerObjects.Create;
  FSync := TCriticalSection.Create;

finalization

  F(FSync);
  F(OM);
  F(FIoCompletionManager);

end.
