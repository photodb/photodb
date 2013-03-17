unit uDatabaseDirectoriesUpdater;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  Generics.Defaults,
  Generics.Collections,
  System.SyncObjs,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Forms,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.System,

  CommonDBSupport,
  UnitINI,
  UnitDBDeclare,
  UnitDBKernel,

  uConstants,
  uRuntime,
  uMemory,
  uGUIDUtils,
  uInterfaces,
  uAssociations,
  uDBAdapter,
  uDBForm,
  uDBThread,
  wfsU,
  uGOM,
  uDBTypes,
  uDBUtils,
  uDBUpdateUtils,
  uDBPopupMenuInfo,
  uLockedFileNotifications,
  uCDMappingTypes,
  uSettings;

type
  TDatabaseDirectory = class(TDataObject)
  private
    FPath: string;
    FName: string;
    FIcon: string;
    FSortOrder: Integer;
  public
    constructor Create(Path, Name, Icon: string; SortOrder: Integer);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
    property Path: string read FPath write FPath;
    property Name: string read FName write FName;
    property Icon: string read FIcon write FIcon;
    property SortOrder: Integer read FSortOrder write FSortOrder;
  end;

  TDatabaseDirectoriesUpdater = class(TDBThread)
  private
    FQuery: TDataSet;
    FThreadID: TGUID;
    FSkipExtensions: string;
    FAddRawFiles: Boolean;
    function IsDirectoryChangedOnDrive(Directory: string; ItemSizes: TList<Int64>; Items: TList<string>): Boolean;
    procedure AddItemsToDatabase(Items: TList<string>);
    function GetIsValidThread: Boolean;
    function CanAddFileAutomatically(FileName: string): Boolean;
    property IsValidThread: Boolean read GetIsValidThread;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  IUserDirectoriesWatcher = interface
    ['{ED4EF3E3-43A6-4D86-A40D-52AA1DFAD299}']
    procedure Execute;
    procedure StartWatch;
    procedure StopWatch;
  end;

  TUserDirectoriesWatcher = class(TInterfacedObject, IUserDirectoriesWatcher, IDirectoryWatcher)
  private
    FWatchers: TList<TWachDirectoryClass>;
    FState: TGUID;
    procedure StartWatch;
    procedure StopWatch;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
    procedure DirectoryChanged(Sender: TObject; SID: TGUID; pInfos: TInfoCallBackDirectoryChangedArray);
    procedure TerminateWatcher(Sender: TObject; SID: TGUID; Folder: string);
  end;

  TDatabaseTask = class(TObject)
  public
    function IsPrepaired: Boolean; virtual;
  end;

  TUpdateTask = class(TDatabaseTask)
    procedure Execute;
  end;

  TAddTask = class(TDatabaseTask)
  private
    FData: TDBPopupMenuInfoRecord;
    function GetFileName: string;
    procedure NotifyAboutFileProcessing(Info: TDBPopupMenuInfoRecord; Res: TImageDBRecordA);
  public
    constructor Create(FileName: string); overload;
    destructor Destroy; override;
    procedure Execute(Items: TArray<TAddTask>);
    constructor Create(Data: TDBPopupMenuInfoRecord); overload;
    function IsPrepaired: Boolean; override;
    property FileName: string read GetFileName;
    property Data: TDBPopupMenuInfoRecord read FData;
  end;

  TDatabaseTaskPriority = (dtpNormal, dtpHigh);

  TUpdaterStorage = class(TObject)
  private
    FSync: TCriticalSection;
    FTasks: TList<TDatabaseTask>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveStorage;
    procedure RestoreStorage;

    function Take<T: TDatabaseTask>(Count: Integer): TArray<T>;
    function TakeOne<T: TDatabaseTask>: T;
    procedure Add(Task: TDatabaseTask; Priority: TDatabaseTaskPriority = dtpHigh);
    procedure AddRange(Tasks: TList<TDatabaseTask>; Priority: TDatabaseTaskPriority = dtpHigh);
  end;

  TDatabaseUpdater = class(TDBThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

const
  cAddImagesAtOneStep = 4;

var
  DirectoriesScanID: TGUID = '{00000000-0000-0000-0000-000000000000}';
  FUpdaterStorage: TUpdaterStorage = nil;
  FStorageLock: TCriticalSection = nil;

function UpdaterStorage: TUpdaterStorage;
begin
  if FUpdaterStorage = nil then
  begin
    FUpdaterStorage := TUpdaterStorage.Create;
    FUpdaterStorage.RestoreStorage;
  end;

  Result := FUpdaterStorage;
end;

procedure FillDatabaseDirectories(FolderList: TList<TDatabaseDirectory>);
const
  UpdaterDirectoriesFormat = '\Updater\Databases\{0}';

var
  Reg: TBDRegistry;
  DBPrefix, FName, FPath, FIcon: string;
  I, SortOrder: Integer;
  S: TStrings;
  DD: TDatabaseDirectory;

begin
  FolderList.Clear;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));

    Reg.OpenKey(GetRegRootKey + FormatEx(UpdaterDirectoriesFormat, [DBPrefix]), True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);

      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + FormatEx(UpdaterDirectoriesFormat, [DBPrefix]) + S[I], True);

        FName := '';
        FPath := '';
        FIcon := '';
        SortOrder := 0;
        if Reg.ValueExists('Path') then
          FPath := Reg.ReadString('Path');
        if Reg.ValueExists('Icon') then
          FIcon := Reg.ReadString('Icon');
        if Reg.ValueExists('SortOrder') then
          SortOrder := Reg.ReadInteger('SortOrder');

        if (S[I] <> '') and (FPath <> '') then
        begin
          DD := TDatabaseDirectory.Create(S[I], FPath, FIcon, SortOrder);
          FolderList.Add(DD);
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;

  DD := TDatabaseDirectory.Create('D:\dmitry\my pictures\photoes', 'TEST', '', 0);
  FolderList.Add(DD);

  FolderList.Sort(TComparer<TDatabaseDirectory>.Construct(
     function (const L, R: TDatabaseDirectory): Integer
     begin
       Result := L.SortOrder - R.SortOrder;
     end
  ));
end;

{ TDatabaseDirectory }

procedure TDatabaseDirectory.Assign(Source: TDataObject);
var
  DD: TDatabaseDirectory;
begin
  DD := Source as TDatabaseDirectory;
  Self.Path := DD.Path;
  Self.Name := DD.Name;
  Self.Icon := DD.Icon;
  Self.SortOrder := DD.SortOrder;
end;

function TDatabaseDirectory.Clone: TDataObject;
begin
  Result := TDatabaseDirectory.Create(Path, Name, Icon, SortOrder);
end;

constructor TDatabaseDirectory.Create(Path, Name, Icon: string; SortOrder: Integer);
begin
  Self.Path := Path;
  Self.Name := Name;
  Self.Icon := Icon;
  Self.SortOrder := SortOrder;
end;
  
{ TDatabaseDirectoriesUpdater }

function TDatabaseDirectoriesUpdater.CanAddFileAutomatically(
  FileName: string): Boolean;
var
  Ext: string;
begin
  if not FAddRawFiles and IsRAWImageFile(FileName) then
    Exit(False);

  if FSkipExtensions <> '' then
  begin
    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    if FSkipExtensions.IndexOf(AnsiLowerCase(Ext)) > 0 then
      Exit(False);
  end;

  Exit(True);
end;

constructor TDatabaseDirectoriesUpdater.Create;
begin
  inherited Create(nil, False);
  FThreadID := GetGUID;
  DirectoriesScanID := FThreadID;

  FSkipExtensions := AnsiLowerCase(Settings.ReadString('Updater', 'SkipExtensions'));
  FAddRawFiles := Settings.ReadBool('Updater', 'AddRawFiles', False);

  FQuery := GetQuery(True);
end;

destructor TDatabaseDirectoriesUpdater.Destroy;
begin
  FreeDS(FQuery);
  inherited;
end;

procedure TDatabaseDirectoriesUpdater.Execute;
var
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
  Directories: TQueue<string>;
  Items: TList<string>;
  ItemSizes: TList<Int64>;
  Found: Integer;
  OldMode: Cardinal;
  SearchRec: TSearchRec;
  Dir: string;
begin
  inherited;
  FreeOnTerminate := True;

  CoInitializeEx(nil, COM_MODE);
  try

    Directories := TQueue<string>.Create;
    Items := TList<string>.Create;
    ItemSizes := TList<Int64>.Create;
    OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try

      //list of directories to scan
      FolderList := TList<TDatabaseDirectory>.Create;
      try
        FillDatabaseDirectories(FolderList);
        for DD in FolderList do
          Directories.Enqueue(DD.Path);

      finally
        FreeList(FolderList);
      end;

      while Directories.Count > 0 do
      begin
        if DBTerminating or not IsValidThread then
          Break;

        Dir := Directories.Dequeue;

        Dir := IncludeTrailingBackslash(Dir);

        ItemSizes.Clear;
        Items.Clear;
        Found := FindFirst(Dir + '*.*', faDirectory, SearchRec);
        try
          while Found = 0 do
          begin
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              if (faDirectory and SearchRec.Attr = 0) and IsGraphicFile(SearchRec.Name) and CanAddFileAutomatically(SearchRec.Name) then
              begin
                ItemSizes.Add(SearchRec.Size);
                Items.Add(Dir + SearchRec.Name);
              end;

              if faDirectory and SearchRec.Attr <> 0 then
                Directories.Enqueue(Dir + SearchRec.Name);
            end;
            Found := System.SysUtils.FindNext(SearchRec);
          end;
        finally
          FindClose(SearchRec);
        end;

        if IsDirectoryChangedOnDrive(Dir, ItemSizes, Items) and IsValidThread then
          AddItemsToDatabase(Items);
      end;

    finally
      SetErrorMode(OldMode);
      F(ItemSizes);
      F(Items);
      F(Directories);
    end;
  finally
    CoUninitialize;
  end;
end;

function TDatabaseDirectoriesUpdater.GetIsValidThread: Boolean;
begin
  Result := FThreadID = DirectoriesScanID;
end;

function TDatabaseDirectoriesUpdater.IsDirectoryChangedOnDrive(
  Directory: string; ItemSizes: TList<Int64>; Items: TList<string>): Boolean;
var
  I, J: Integer;
  DA: TDBAdapter;
  FileName: string;
begin
  SetSQL(FQuery, 'Select ID, FileSize, Name FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(Directory, False)));
  if TryOpenCDS(FQuery) then
  begin
    if not FQuery.IsEmpty then
    begin
      FQuery.First;
      DA := TDBAdapter.Create(FQuery);
      try
        for I := 1 to FQuery.RecordCount do
        begin
          FileName := AnsiLowerCase(Directory + DA.Name);

          for J := Items.Count - 1 downto 0 do
            if(AnsiLowerCase(Items[J]) = FileName) and (ItemSizes[J] = DA.FileSize) then
            begin
              Items.Delete(J);
              ItemSizes.Delete(J);
            end;

          FQuery.Next;
        end;

      finally
        F(DA);
      end;
    end;

    Exit(Items.Count > 0);

  end else
    Exit(True);
end;

procedure TDatabaseDirectoriesUpdater.AddItemsToDatabase(Items: TList<string>);
var
  FileName: string;
  AddTasks: TList<TAddTask>;
begin
  AddTasks := TList<TAddTask>.Create;
  try
     for FileName in Items do
       AddTasks.Add(TAddTask.Create(FileName));

     UpdaterStorage.AddRange(TList<TDatabaseTask>(AddTasks));
  finally
     F(AddTasks);
  end;
end;

{ TUserDirectoriesWatcher }

constructor TUserDirectoriesWatcher.Create;
begin
  FWatchers := TList<TWachDirectoryClass>.Create;
  GOM.AddObj(Self);
end;

destructor TUserDirectoriesWatcher.Destroy;
begin
  StopWatch;
  FreeList(FWatchers);
  GOM.RemoveObj(Self);
  inherited;
end;

procedure TUserDirectoriesWatcher.Execute;
begin
  inherited;
  StartWatch;
  TDatabaseDirectoriesUpdater.Create;
end;

procedure TUserDirectoriesWatcher.StartWatch;
var
  Watch: TWachDirectoryClass;
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
begin
  StopWatch;
  FState := GetGUID;

  //list of directories to watch
  FolderList := TList<TDatabaseDirectory>.Create;
  try
    FillDatabaseDirectories(FolderList);
    for DD in FolderList do
    begin
      Watch := TWachDirectoryClass.Create;
      FWatchers.Add(Watch);
      Watch.Start(DD.Path, Self, Self, FState, True);
    end;

  finally
    FreeList(FolderList);
  end;
end;

procedure TUserDirectoriesWatcher.StopWatch;
var
  I: Integer;
begin
  for I := 0 to FWatchers.Count - 1 do
    FWatchers[I].StopWatch;
  
  FreeList(FWatchers, False);
end;

procedure TUserDirectoriesWatcher.DirectoryChanged(Sender: TObject; SID: TGUID;
  pInfos: TInfoCallBackDirectoryChangedArray);
var
  Info: TInfoCallback;
begin
  if FState <> SID then
    Exit;

  for Info in pInfos do
  begin

    if (Info.FNewFileName <> '') and TLockFiles.Instance.IsFileLocked(Info.FNewFileName) then
      Continue;
    if (Info.FOldFileName <> '') and TLockFiles.Instance.IsFileLocked(Info.FOldFileName) then
      Continue;

    case Info.FAction of
      FILE_ACTION_ADDED:
        UpdaterStorage.Add(TAddTask.Create(Info.FNewFileName));
      FILE_ACTION_REMOVED,
      FILE_ACTION_RENAMED_NEW_NAME:
    end;
  end;
end;

procedure TUserDirectoriesWatcher.TerminateWatcher(Sender: TObject; SID: TGUID;
  Folder: string);
begin
  //do nothing for now
end;

{ TDatabaseTask }

function TDatabaseTask.IsPrepaired: Boolean;
begin
  Result := True;
end;

{ TUpdateTask }

procedure TUpdateTask.Execute;
begin
  //currently not implemented
end;

{ TAddTask }

constructor TAddTask.Create(FileName: string);
begin
  FData := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
  FData.Include := True;
end;

constructor TAddTask.Create(Data: TDBPopupMenuInfoRecord);
begin
  if Data = nil then
    raise Exception.Create('Can''t create task for null task!');

  FData := Data.Copy;
end;

destructor TAddTask.Destroy;
begin
  F(FData);
  inherited;
end;

procedure TAddTask.Execute(Items: TArray<TAddTask>);
var
  I: Integer;
  ResArray: TImageDBRecordAArray;
  Infos: TDBPopupMenuInfo;
  Info: TDBPopupMenuInfoRecord;
  Res: TImageDBRecordA;
begin

  Infos := TDBPopupMenuInfo.Create;
  try
    for I := 0 to Length(Items) - 1 do
      Infos.Add(Items[I].Data.Copy);

    ResArray := GetImageIDWEx(Infos, False);
    try
      for I := 0 to Length(ResArray) - 1 do
      begin
        Res := ResArray[I];
        Info := Infos[I];

        if Res.Jpeg = nil then
        begin
          //failed to load image
          Continue;
        end;

        //decode jpeg in background for fasten drawing in GUI
        Res.Jpeg.DIBNeeded;

        TThread.Synchronize(nil,
          procedure
          begin
            NotifyAboutFileProcessing(Info, Res);
          end
        );

        //new file in collection
        if Res.Count = 0 then
        begin
          TDatabaseUpdateManager.AddFile(Info, Res);
          Continue;
        end;

        if Res.Count = 1 then
        begin
          //moved file
          if (StaticPath(Res.FileNames[0]) and not FileExists(Res.FileNames[0])) or (Res.Attr[0] = Db_attr_not_exists) then
          begin
            TDatabaseUpdateManager.MergeWithExistedInfo(Res.IDs[0], Info, Res);
            Continue;
          end;

          //the same file
          if AnsiLowerCase(Res.FileNames[0]) = AnsiLowerCase(Info.FileName) then
            Continue;
        end;

        //add file as diplicate
        TDatabaseUpdateManager.AddFileAsDuplicate(Info, Res);
      end;

    finally
      for I := 0 to Length(ResArray) - 1 do
        if ResArray[I].Jpeg <> nil then
           ResArray[I].Jpeg.Free;
    end;
  finally
    F(Infos);
  end;
end;

function TAddTask.GetFileName: string;
begin
  if FData = nil then
    Exit('');

  Result := FData.FileName;
end;

function TAddTask.IsPrepaired: Boolean;
var
  hFile: THandle;
begin
  Result := False;

  //don't allow to write to file and try to open file
  hFile := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  try
    Result := (hFile <> INVALID_HANDLE_VALUE) and (hFile <> 0);
  finally
    if Result then
      CloseHandle(hFile);
  end;
end;

procedure TAddTask.NotifyAboutFileProcessing(Info: TDBPopupMenuInfoRecord; Res: TImageDBRecordA);
var
  EventInfo: TEventValues;
begin
  EventInfo.ReadFromInfo(Info);
  EventInfo.JPEGImage := Res.Jpeg;
  DBKernel.DoIDEvent(Application.MainForm as TDBForm, LastInseredID, [EventID_FileProcessed], EventInfo);
end;

{ TUpdaterStorage }

procedure TUpdaterStorage.Add(Task: TDatabaseTask; Priority: TDatabaseTaskPriority = dtpHigh);
begin
  FSync.Enter;
  try
    if Priority = dtpNormal then
      FTasks.Add(Task);
    if Priority = dtpHigh then
      FTasks.Insert(0, Task);
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.AddRange(Tasks: TList<TDatabaseTask>; Priority: TDatabaseTaskPriority = dtpHigh);
begin
  FSync.Enter;
  try
    if Priority = dtpNormal then
      FTasks.AddRange(Tasks.ToArray());
    if Priority = dtpHigh then
      FTasks.InsertRange(0, Tasks.ToArray());
  finally
    FSync.Leave;
  end;
end;

constructor TUpdaterStorage.Create;
begin
  FSync := TCriticalSection.Create;
  FTasks := TList<TDatabaseTask>.Create;
  TDatabaseUpdater.Create;
end;

destructor TUpdaterStorage.Destroy;
begin
  F(FSync);
  FreeList(FTasks);
  inherited;
end;

procedure TUpdaterStorage.RestoreStorage;
begin

end;

procedure TUpdaterStorage.SaveStorage;
begin

end;

function TUpdaterStorage.Take<T>(Count: Integer): TArray<T>;
var
  I: Integer;
  FItems: TList<T>;
begin
  FSync.Enter;
  try
    FItems := TList<T>.Create;
    try
      for I := 0 to FTasks.Count - 1 do
        if (FTasks[I] is T) and FTasks[I].IsPrepaired then
        begin
          FItems.Add(FTasks[I]);
          if FItems.Count = Count then
            Break;
        end;

      for I := 0 to FItems.Count - 1 do
        FTasks.Remove(FItems[I]);

      Result := FItems.ToArray();
    finally
      F(FItems);
    end;
  finally
    FSync.Leave;
  end;
end;

function TUpdaterStorage.TakeOne<T>: T;
var
  Tasks: TArray<T>;
begin
  Tasks := Take<T>(0);
  if Length(Tasks) = 0 then
    Exit(nil);

  Exit(Tasks[0]);
end;

{ TDatabaseUpdater }

constructor TDatabaseUpdater.Create;
begin
  inherited Create(nil, False);
end;

destructor TDatabaseUpdater.Destroy;
begin
  inherited;
end;

procedure TDatabaseUpdater.Execute;
var
  Task: TDatabaseTask;
  AddTasks: TArray<TAddTask>;
  UpdateTasks: TArray<TUpdateTask>;
begin
  inherited;
  FreeOnTerminate := True;

  //task will work in background
  while True do
  begin
    if DBTerminating then
      Break;

    AddTasks := UpdaterStorage.Take<TAddTask>(cAddImagesAtOneStep);
    try
      if Length(AddTasks) > 0 then
       AddTasks[0].Execute(AddTasks);
    finally
      for Task in AddTasks do
        Task.Free;
    end;

    if DBTerminating then
      Break;

    UpdateTasks := UpdaterStorage.Take<TUpdateTask>(1);
    try
      if Length(UpdateTasks) > 0 then
        UpdateTasks[0].Execute;
    finally
      for Task in UpdateTasks do
        Task.Free;
    end;
  end;
end;

initialization
  FStorageLock := TCriticalSection.Create;

finalization
  F(FUpdaterStorage);
  F(FStorageLock);

end.

