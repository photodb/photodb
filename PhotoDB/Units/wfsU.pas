unit wfsU;

interface

uses  Classes, SysUtils, Windows, Dolphin_DB, Forms, GraphicsBaseTypes, uLogger,
      uGOM, ExplorerTypes;

type

  WFSError = class(Exception);

  TWFS = class(TThread)
  private
    FName           : string;
    FFilter         : Cardinal;
    FSubTree        : boolean;
    FInfoCallback   : TWatchFileSystemCallback;
    FWatchHandle    : THandle;
    FWatchBuf       : array[0..65535] of Byte;
    FOverLapp       : TOverlapped;
    FPOverLapp      : POverlapped;
    FBytesWritte    : DWORD;
    FCompletionPort : THandle;
    FNumBytes       : Cardinal;
    FOldFileName    : string;
    InfoCallback    : TInfoCallBackDirectoryChangedArray;
    fOnNeedClosing  : TNotifyEvent;
    fOnThreadClosing: TNotifyEvent;
    function CreateDirHandle(aDir: string): THandle;
    procedure WatchEvent;
    procedure HandleEvent;
  protected
    procedure Execute; override;
    procedure DoCallBack;
    procedure TDoTerminate;
    procedure DoClosingEvent;
  public
    PublicOwner : TObject;
    constructor Create(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback; OnNeedClosing, OnThreadClosing : TNotifyEvent);
    destructor Destroy; override;
  end;

  TWachDirectoryClass = class(TObject)
  private
    WFS : TWFS;
    fOnDirectoryChanged: TNotifyDirectoryChangeW;
    fCID : TGUID;
    fOwner : TForm;
    procedure SetOnDirectoryChanged(const Value: TNotifyDirectoryChangeW);
    { Запуск мониторинга файловой системы
    Праметры:
    pName    - имя папки для мониторинга
    pFilter  - комбинация констант FILE_NOTIFY_XXX
    pSubTree - мониторить ли все подпапки заданной папки
    pInfoCallback - адрес callback процедуры, вызываемой при изменении в файловой системе}
    procedure StartWatch(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback);
    procedure CallBack(pInfo: TInfoCallBackDirectoryChangedArray);
    procedure OnNeedClosing(Sender : TObject);
    procedure OnThreadClosing(Sender : TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(Directory : string; Owner : TForm; CID : TGUID);
    // Остановка мониторинга
    procedure StopWatch;
  published
    property OnDirectoryChanged : TNotifyDirectoryChangeW read fOnDirectoryChanged write SetOnDirectoryChanged;
  end;

  var
    OM : TManagerObjects;

implementation

uses ExplorerUnit;

procedure TWachDirectoryClass.CallBack(pInfo: TInfoCallBackDirectoryChangedArray);
begin
 if ExplorerManager.IsExplorerForm(fOwner) then
 begin
  (fOwner as TExplorerForm).DirectoryChanged(self,fCID,pInfo);
 end else
 begin
  StopWatch;
  Free;
 end;
end;

constructor TWachDirectoryClass.Create;
begin
 OM.AddObj(self);
end;

destructor TWachDirectoryClass.Destroy;
begin
 OM.RemoveObj(self);
  inherited;
end;

procedure TWachDirectoryClass.OnNeedClosing(Sender: TObject);
begin
 if ExplorerManager.IsExplorerForm(fOwner) then
 begin
  (fOwner as TExplorerForm).Close;
 end else
 begin
  StopWatch;
  Free;
 end;
end;

procedure TWachDirectoryClass.OnThreadClosing(Sender: TObject);
begin
// WFS:=nil;
end;

procedure TWachDirectoryClass.SetOnDirectoryChanged(
  const Value: TNotifyDirectoryChangeW);
begin
  fOnDirectoryChanged := Value;
end;

procedure TWachDirectoryClass.Start(Directory: string; Owner: TForm;
  CID: TGUID);
begin
 fCID:=CID;
 fOwner:=Owner;
 StartWatch(Directory,FILE_NOTIFY_CHANGE_FILE_NAME+FILE_NOTIFY_CHANGE_DIR_NAME	+FILE_NOTIFY_CHANGE_CREATION+FILE_NOTIFY_CHANGE_LAST_WRITE,false,CallBack);
end;

procedure TWachDirectoryClass.StartWatch(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback);
begin
 WFS:=TWFS.Create(pName, pFilter, pSubTree, pInfoCallback, OnNeedClosing, OnThreadClosing);
 WFS.PublicOwner:=self;
end;

procedure TWachDirectoryClass.StopWatch;
var
  Temp : TWFS;
begin
 if OM.IsObj(WFS) then
//  if Assigned(WFS) then
  begin
   try
    PostQueuedCompletionStatus(WFS.FCompletionPort, 0, 0, nil);
   except
    on e : Exception do EventLog(':TWachDirectoryClass::StopWatch() throw exception: '+e.Message);
   end;
   Temp := WFS;
   WFS:=nil;
   Temp.Terminate;
  end;
end;

constructor TWFS.Create(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallback: TWatchFileSystemCallback; OnNeedClosing, OnThreadClosing : TNotifyEvent);
begin
  inherited Create(False);
  OM.AddObj(Self);
  FreeOnTerminate:=True;
  FName:=IncludeTrailingBackslash(pName);
  FFilter:=pFilter;
  FSubTree:=pSubTree;
  FOldFileName:=EmptyStr;
  ZeroMemory(@FOverLapp, SizeOf(TOverLapped));
  FPOverLapp := @FOverLapp;
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  FInfoCallback := PInfoCallback;
  FOnNeedClosing := OnNeedClosing;
  FOnThreadClosing := OnThreadClosing;
end;

destructor TWFS.Destroy;
begin
  OM.RemoveObj(Self);
  try
    PostQueuedCompletionStatus(FCompletionPort, 0, 0, nil);
  except
    on E: Exception do
      EventLog(':TWachDirectoryClass::Destroy() throw exception: '+e.Message);
  end;
  try
   CloseHandle(FWatchHandle);
  except
    on e : Exception do EventLog(':TWachDirectoryClass::Destroy() throw exception: '+e.Message);
  end;
  FWatchHandle:=0;
  try
   CloseHandle(FCompletionPort);
  except
    on e : Exception do EventLog(':TWachDirectoryClass::Destroy() throw exception: '+e.Message);
  end;
  FCompletionPort:=0;
  inherited Destroy;
end;

function TWFS.CreateDirHandle(aDir: string): THandle;
begin
 Result:=CreateFile(PChar(aDir), FILE_LIST_DIRECTORY, FILE_SHARE_READ+FILE_SHARE_DELETE+FILE_SHARE_WRITE,
                   nil,OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
end;

procedure TWFS.Execute;
begin
 FreeOnTerminate:=true;
 FWatchHandle:=CreateDirHandle(FName);
 WatchEvent;
 Synchronize(DoClosingEvent);
end;

procedure TWFS.HandleEvent;
var
  fInfoCallback  : TInfoCallback;
  Ptr            : Pointer;
  FileName       : PWideChar;
  b, c           : Boolean;
  i : integer;
begin
  SetLength(InfoCallback,0);
  Ptr:=@FWatchBuf[0];
  repeat
   GetMem(FileName,PFileNotifyInformation(Ptr).FileNameLength+2);
   ZeroMemory(FileName,PFileNotifyInformation(Ptr).FileNameLength+2);
   lstrcpynW(FileName,PFileNotifyInformation(Ptr).FileName, PFileNotifyInformation(Ptr).FileNameLength div 2+1);
   c:=false;
   b:=false;
   if (Now-LockTime)>10/(24*60*60) then
   begin
    ExplorerTypes.LockedFiles[1]:='';
    ExplorerTypes.LockedFiles[2]:='';
   end;
   for i:=1 to 2 do
   if AnsiLowerCase(LockedFiles[i])=AnsiLowerCase(FName+FileName) then
   begin
    FreeMem(FileName);
    if PFileNotifyInformation(Ptr).NextEntryOffset=0  then
    begin
     b:=true;
     Break;
    end
    else Inc(Cardinal(Ptr),PFileNotifyInformation(Ptr).NextEntryOffset);
    c:=true;
    Break;
   end;
   if b then Break;
   if c then Continue;

   fInfoCallback.FAction:=PFileNotifyInformation(Ptr).Action;
   if (fInfoCallback.FAction=0) then
   begin
    Synchronize(TDoTerminate); //CloseExplorer
    Terminate;
    exit;
   end;
   fInfoCallback.FNewFileName:=FName+FileName;
   case PFileNotifyInformation(Ptr).Action of
     FILE_ACTION_RENAMED_OLD_NAME: FOldFileName:=FName+FileName;
     FILE_ACTION_RENAMED_NEW_NAME: fInfoCallback.FOldFileName:=FOldFileName;
   end;
   if PFileNotifyInformation(Ptr).Action<>FILE_ACTION_RENAMED_OLD_NAME then
   begin
    SetLength(InfoCallback,Length(InfoCallback)+1);
    InfoCallback[Length(InfoCallback)-1]:=fInfoCallback;
   end;


   FreeMem(FileName);

   if PFileNotifyInformation(Ptr).NextEntryOffset=0  then Break
   else Inc(Cardinal(Ptr),PFileNotifyInformation(Ptr).NextEntryOffset);
  until Terminated;

  Synchronize(DoCallBack);
end;

procedure TWFS.WatchEvent;
var
 CompletionKey: Cardinal;
begin
  FCompletionPort:=CreateIoCompletionPort(FWatchHandle, 0, Longint(pointer(self)), 0);
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  if not ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
    FFilter, @FBytesWritte,  @FOverLapp, nil) then
  begin
    Terminate;
  end else
  begin
    while not Terminated do
    begin
      GetQueuedCompletionStatus(FCompletionPort, FNumBytes, CompletionKey, FPOverLapp, INFINITE);
      if CompletionKey<>0 then
      begin
       try
        Synchronize(HandleEvent);
        ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
        FBytesWritte:=0;
        ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree, FFilter,
                             @FBytesWritte, @FOverLapp, nil);
       except
        on e : Exception do EventLog(':TWachDirectoryClass::WatchEvent() throw exception: '+e.Message);
       end;
      end else Terminate;
    end
  end
end;

procedure TWFS.DoCallBack;
begin
 if OM.IsObj(PublicOwner) then
 FInfoCallback(InfoCallback);
end;

procedure TWFS.TDoTerminate;
begin
 if OM.IsObj(PublicOwner) then
 fOnNeedClosing(self);
end;

procedure TWFS.DoClosingEvent;
begin
 if OM.IsObj(PublicOwner) then
 fOnThreadClosing(self);
end;

initialization

  OM := TManagerObjects.Create;

finalization

  OM.Free;

end.
