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
  System.DateUtils,
  System.Math,
  Vcl.Forms,
  Vcl.Imaging.Jpeg,
  Data.DB,
  Xml.Xmldom,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  UnitINI,
  UnitDBDeclare,

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
  uDBConnection,
  uDBClasses,
  uDBUtils,
  uMediaInfo,
  uDBContext,
  uDBEntities,
  uDBManager,
  uLogger,
  uCounters,
  uFormInterfaces,
  uConfiguration,
  uDBUpdateUtils,
  uShellUtils,
  uTranslate,
  uLockedFileNotifications,
  uCDMappingTypes,
  uCollectionEvents,
  uSettings;

type
  TDatabaseTask = class(TObject)
  protected
    FDBContext: IDBContext;
    FFileName: string;
  public
    function IsPrepaired: Boolean;
    constructor Create(DBContext: IDBContext; FileName: string);
    property DBContext: IDBContext read FDBContext;
    property FileName: string read FFileName;
  end;

  TUpdateTask = class(TDatabaseTask)
  private
    FID: Integer;
  public
    constructor Create(DBContext: IDBContext; ID: Integer; FileName: string); overload;
    procedure Execute;
    property ID: Integer read FID;
  end;

  TAddTask = class(TDatabaseTask)
  private
    FData: TMediaItem;
    procedure NotifyAboutFileProcessing(Info: TMediaItem; Res: TMediaInfo);
  public
    constructor Create(DBContext: IDBContext; Data: TMediaItem); overload;
    constructor Create(DBContext: IDBContext; FileName: string); overload;
    destructor Destroy; override;
    procedure Execute(Items: TArray<TAddTask>);
    property Data: TMediaItem read FData;
  end;

  TDatabaseDirectory = class(TDataObject)
  private
    FPath: string;
    FName: string;
    FSortOrder: Integer;
  public
    constructor Create(Path, Name: string; SortOrder: Integer);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
    property Path: string read FPath write FPath;
    property Name: string read FName write FName;
    property SortOrder: Integer read FSortOrder write FSortOrder;
  end;

  TDatabaseDirectoriesUpdater = class(TDBThread)
  private
    FQuery: TDataSet;
    FThreadID: TGUID;
    FSkipExtensions: string;
    FDBContext: IDBContext;
    FRescanDirectory: string;
    FAddRawFiles: Boolean;
    function IsDirectoryChangedOnDrive(Directory: string; ItemSizes: TList<Int64>; ItemsToAdd: TList<string>; ItemsToUpdate: TList<TUpdateTask>): Boolean;
    procedure AddItemsToDatabase(Items: TList<string>);
    procedure UpdateItemsInDatabase(Items: TList<TUpdateTask>);
    function UpdateDatabaseItems: Boolean;
    function GetIsValidThread: Boolean;
    function CanAddFileAutomatically(FileName: string): Boolean;
    property IsValidThread: Boolean read GetIsValidThread;
  protected
    procedure Execute; override;
  public
    constructor Create(DBContext: IDBContext; RescanDirectory: string = '');
    destructor Destroy; override;
  end;

  IUserDirectoriesWatcher = interface
    ['{ED4EF3E3-43A6-4D86-A40D-52AA1DFAD299}']
    procedure Execute(Context: IDBContext);
    procedure StartWatch;
    procedure StopWatch;
  end;

  TUserDirectoriesWatcher = class(TInterfacedObject, IUserDirectoriesWatcher, IDirectoryWatcher)
  private
    FWatchers: TList<TWachDirectoryClass>;
    FState: TGUID;
    FDBContext: IDBContext;
    procedure StartWatch;
    procedure StopWatch;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute(Context: IDBContext);
    procedure DirectoryChanged(Sender: TObject; SID: TGUID; pInfos: TInfoCallBackDirectoryChangedArray);
    procedure TerminateWatcher(Sender: TObject; SID: TGUID; Folder: string);
  end;

  TDatabaseTaskPriority = (dtpNormal, dtpHigh);

  TUpdaterStorage = class(TObject)
  private
    FSync: TCriticalSection;
    FTotalItemsCount: Integer;
    FEstimateRemainingTime: TTime;
    FTasks: TList<TDatabaseTask>;
    FErrorFileList: TStringList;
    FContext: IDBContext;
    function GetEstimateRemainingTime: TTime;
    function GetActiveItemsCount: Integer;
  public
    constructor Create(Context: IDBContext);
    destructor Destroy; override;

    procedure SaveStorage;
    procedure RestoreStorage(Context: IDBContext);

    function Take<T: TDatabaseTask>(Count: Integer): TArray<T>;
    function TakeOne<T: TDatabaseTask>: T;
    procedure Add(Task: TDatabaseTask; Priority: TDatabaseTaskPriority = dtpHigh);
    procedure AddRange(Tasks: TList<TDatabaseTask>; Priority: TDatabaseTaskPriority = dtpHigh);

    procedure AddFile(Info: TMediaItem; Priority: TDatabaseTaskPriority = dtpHigh); overload;
    procedure AddFile(FileName: string; Priority: TDatabaseTaskPriority = dtpHigh); overload;
    procedure AddDirectory(DirectoryPath: string);

    function HasFile(FileName: string): Boolean;

    procedure CleanUpDatabase(NewContext: IDBContext);

    procedure AddFileWithErrors(FileName: string);
    procedure RemoveFileWithErrors(FileName: string);
    procedure RemoveFilesWithErrors(Files: TList<string>; FileSizes: TList<Int64>);

    procedure UpdateRemainingTime(Conter:  TSpeedEstimateCounter);
    property EstimateRemainingTime: TTime read GetEstimateRemainingTime;

    property TotalItemsCount: Integer  read FTotalItemsCount;
    property ActiveItemsCount: Integer read GetActiveItemsCount;
  end;

  TDatabaseUpdater = class(TDBThread)
  private
    FSpeedCounter: TSpeedEstimateCounter;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

function UpdaterStorage: TUpdaterStorage;
procedure RecheckDirectoryOnDrive(DirectoryPath: string);
procedure ReadDatabaseDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
procedure SaveDatabaseDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
function IsFileInCollectionDirectories(CollectionFile: string; FileName: string): Boolean;

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
    FUpdaterStorage := TUpdaterStorage.Create(DBManager.DBContext);
    FUpdaterStorage.RestoreStorage(DBManager.DBContext);
  end;

  Result := FUpdaterStorage;
end;

function DatabaseFolderPersistaseFileName(CollectionPath: string): string;
begin
  Result := GetAppDataDirectory + FolderCacheDirectory + ExtractFileName(CollectionPath) + IntToStr(StringCRC(CollectionPath)) + '.cache';
end;

function DatabaseErrorsPersistaseFileName(CollectionPath: string): string;
begin
  Result := GetAppDataDirectory + FolderCacheDirectory + ExtractFileName(CollectionPath) + IntToStr(StringCRC(CollectionPath)) + '.errors.cache';
end;

procedure ReadDatabaseDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
var
  Reg: TBDRegistry;
  FName, FPath, FIcon: string;
  I, SortOrder: Integer;
  S: TStrings;
  DD: TDatabaseDirectory;

begin
  FolderList.Clear;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);

      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories\' + S[I], True);

        FName := '';
        FPath := '';
        FIcon := '';
        SortOrder := 0;
        if Reg.ValueExists('Path') then
          FPath := Reg.ReadString('Path');
        if Reg.ValueExists('SortOrder') then
          SortOrder := Reg.ReadInteger('SortOrder');

        if (S[I] <> '') and (FPath <> '') then
        begin
          DD := TDatabaseDirectory.Create(FPath, S[I], SortOrder);
          FolderList.Add(DD);
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;

  if (FolderList.Count = 0) then
  begin
    DD := TDatabaseDirectory.Create(GetMyPicturesPath, TA('My Pictures', 'Explorer'), 0);
    FolderList.Add(DD);
    SaveDatabaseDirectories(FolderList, CollectionFile);
  end;

  FolderList.Sort(TComparer<TDatabaseDirectory>.Construct(
     function (const L, R: TDatabaseDirectory): Integer
     begin
       Result := L.SortOrder - R.SortOrder;
     end
  ));
end;

procedure SaveDatabaseDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
var
  Folder: TDatabaseDirectory;
  Reg: TBDRegistry;
  S: TStrings;
  I: Integer;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      for I := 0 to S.Count - 1 do
        Reg.DeleteKey(S[I]);

      for Folder in FolderList do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories\' + Folder.Name, True);

        Reg.WriteString('Path', Folder.Path);
        Reg.WriteInteger('SortOrder', Folder.SortOrder);
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

function IsFileInCollectionDirectories(CollectionFile: string; FileName: string): Boolean;
var
  FolderList: TList<TDatabaseDirectory>;
  I: Integer;
begin
  FolderList := TList<TDatabaseDirectory>.Create;
  try
    ReadDatabaseDirectories(FolderList, FileName);

    for I := 0 to FolderList.Count - 1 do

  finally
    F(FolderList);
  end;
end;

procedure LoadDirectoriesState(FileName: string; DirectoryCache: TDictionary<string, Int64>);
var
  I: Integer;
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  DirectoriesList: IDOMNodeList;
  DirectoryNode: IDOMNode;
  PathNode, SizeNode: IDOMNode;
begin
  Doc := GetDOM.createDocument('', '', nil);
  try
    (Doc as IDOMPersist).load(FileName);
    DocumentElement := Doc.documentElement;
    if DocumentElement <> nil then
    begin

      DirectoriesList := DocumentElement.childNodes;
      if DirectoriesList <> nil then
      begin
        for I := 0 to DirectoriesList.length - 1 do
        begin
          DirectoryNode := DirectoriesList.item[I];

          PathNode := DirectoryNode.attributes.getNamedItem('Path');
          SizeNode := DirectoryNode.attributes.getNamedItem('Size');

          if (PathNode <> nil) and (SizeNode <> nil) then
            DirectoryCache.AddOrSetValue(PathNode.nodeValue, StrToInt64Def(SizeNode.nodeValue, 0));
        end;
      end;
    end;
  except
    on e: Exception do
     EventLog(e);
  end;
end;

procedure SaveDirectoriesState(FileName: string; DirectoryCache: TDictionary<string, Int64>);
var
  Doc: IDOMDocument;
  DocumentElement: IDOMElement;
  DirectoryNode: IDOMNode;
  Pair: TPair<string, Int64>;

  procedure AddProperty(Name: string; Value: string);
  var
    Attr: IDOMAttr;
  begin
    Attr := Doc.createAttribute(Name);
    Attr.value := Value;
    DirectoryNode.attributes.setNamedItem(Attr);
  end;

begin
  Doc := GetDOM.createDocument('', '', nil);
  try

    DocumentElement := Doc.createElement('directories');
    Doc.documentElement := DocumentElement;

    DirectoryNode := DocumentElement;

    for Pair in DirectoryCache do
    begin
      DirectoryNode := Doc.createElement('directory');

      AddProperty('Path', Pair.Key);
      AddProperty('Size', IntToStr(Pair.Value));

      Doc.documentElement.appendChild(DirectoryNode);
    end;

    CreateDirA(ExtractFileDir(FileName));
    (Doc as IDOMPersist).save(FileName);

  except
    on e: Exception do
     EventLog(e);
  end;
end;

procedure RecheckDirectoryOnDrive(DirectoryPath: string);
begin
  //TODO: check if file is inside collection
  TDatabaseDirectoriesUpdater.Create(DBManager.DBContext, DirectoryPath);
end;

{ TDatabaseDirectory }

procedure TDatabaseDirectory.Assign(Source: TDataObject);
var
  DD: TDatabaseDirectory;
begin
  DD := Source as TDatabaseDirectory;
  Self.Path := DD.Path;
  Self.Name := DD.Name;
  Self.SortOrder := DD.SortOrder;
end;

function TDatabaseDirectory.Clone: TDataObject;
begin
  Result := TDatabaseDirectory.Create(Path, Name, SortOrder);
end;

constructor TDatabaseDirectory.Create(Path, Name: string; SortOrder: Integer);
begin
  Self.Path := Path;
  Self.Name := Name;
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

constructor TDatabaseDirectoriesUpdater.Create(DBContext: IDBContext; RescanDirectory: string = '');
begin
  inherited Create(nil, False);
  FDBContext := DBContext;
  FThreadID := GetGUID;
  DirectoriesScanID := FThreadID;
  FRescanDirectory := RescanDirectory;

  FSkipExtensions := AnsiLowerCase(AppSettings.ReadString('Updater', 'SkipExtensions'));
  FAddRawFiles := AppSettings.ReadBool('Updater', 'AddRawFiles', False);

  FQuery := DBContext.CreateQuery(dbilRead);
end;

destructor TDatabaseDirectoriesUpdater.Destroy;
begin
  FreeDS(FQuery);
  inherited;
end;

function TDatabaseDirectoriesUpdater.UpdateDatabaseItems: Boolean;
var
  SettingsRepository: ISettingsRepository;
  Settings: TSettings;
  MediaItem: TMediaItem;
  SC: TSelectCommand;
begin
  SettingsRepository := FDBContext.Settings;
  Result := False;

  Settings := SettingsRepository.Get;
  SC := FDBContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create());
    SC.TopRecords := 50;

    SC.AddWhereParameter(TIntegerParameter.Create('PreviewSize', Settings.ThSize, paNotEquals));
    SC.AddWhereParameter(TDateTimeParameter.Create('DateUpdated', IncDay(Now, -14), paLessThan));

    SC.OrderBy('DateUpdated');
    SC.OrderByDescending('DateToAdd');

    SC.Execute;

    while not SC.DS.EOF do
    begin
      if DBTerminating or not IsValidThread then
        Exit(False);

      Result := True;
      MediaItem := TMediaItem.CreateFromDS(SC.DS);
      try
        try
          if not UpdateImageRecordEx(FDBContext, nil, MediaItem, Settings) then
            MarkRecordAsUpdated(FDBContext, MediaItem.ID);
        except
          on e: Exception do
          begin
            EventLog(e);
            MarkRecordAsUpdated(FDBContext, MediaItem.ID);
          end;
        end;
      finally
        F(MediaItem);
      end;
      SC.DS.Next;
    end;
  finally
    F(Settings);
    F(SC);
  end;
end;

procedure TDatabaseDirectoriesUpdater.Execute;
var
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
  Directories: TQueue<string>;
  ItemsToAdd: TList<string>;
  ItemsToUpdate: TList<TUpdateTask>;
  ItemSizes: TList<Int64>;
  TotalDirectorySize: Int64;
  Found: Integer;
  OldMode: Cardinal;
  SearchRec: TSearchRec;
  ScanInformationFileName,
  FileName, Dir, DirectoryPath: string;
  SavedDirectoriesStructure: TDictionary<string, Int64>;
  IsRescanMode: Boolean;
begin
  inherited;
  FreeOnTerminate := True;
  Priority := tpLower;

  Inc(UserDirectoryUpdaterCount);
  CoInitializeEx(nil, COM_MODE);
  try
    IsRescanMode := FRescanDirectory <> '';

    if not IsRescanMode then
      while UpdateDatabaseItems do;

    Directories := TQueue<string>.Create;
    ItemsToAdd := TList<string>.Create;
    ItemsToUpdate := TList<TUpdateTask>.Create;
    ItemSizes := TList<Int64>.Create;
    SavedDirectoriesStructure := TDictionary<string, Int64>.Create;
    OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
      if not IsRescanMode then
      begin
        ScanInformationFileName := DatabaseFolderPersistaseFileName(FDBContext.CollectionFileName);
        LoadDirectoriesState(ScanInformationFileName, SavedDirectoriesStructure);

        //list of directories to scan
        FolderList := TList<TDatabaseDirectory>.Create;
        try
          ReadDatabaseDirectories(FolderList, FDBContext.CollectionFileName);
          for DD in FolderList do
            Directories.Enqueue(DD.Path);

        finally
          FreeList(FolderList);
        end;
      end else
        Directories.Enqueue(FRescanDirectory);

      while Directories.Count > 0 do
      begin
        if DBTerminating or not IsValidThread then
          Break;

        Dir := Directories.Dequeue;
        Dir := IncludeTrailingBackslash(Dir);

        TotalDirectorySize := 0;
        ItemSizes.Clear;
        ItemsToAdd.Clear;
        FreeList(ItemsToUpdate, False);
        Found := FindFirst(Dir + '*.*', faDirectory, SearchRec);
        try
          while Found = 0 do
          begin
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              if (faDirectory and SearchRec.Attr = 0) and IsGraphicFile(SearchRec.Name) and CanAddFileAutomatically(SearchRec.Name) then
              begin
                FileName := Dir + SearchRec.Name;
                Inc(TotalDirectorySize, SearchRec.Size);

                ItemsToAdd.Add(FileName);
                ItemSizes.Add(SearchRec.Size);
              end;

              if faDirectory and SearchRec.Attr <> 0 then
                Directories.Enqueue(Dir + SearchRec.Name);
            end;
            Found := System.SysUtils.FindNext(SearchRec);
          end;
        finally
          FindClose(SearchRec);
        end;

        DirectoryPath := AnsiLowerCase(Dir);

        if not IsRescanMode then
        begin
          if SavedDirectoriesStructure.ContainsKey(DirectoryPath) then
          begin
            //directory is unchanged
            if TotalDirectorySize = SavedDirectoriesStructure[DirectoryPath] then
              Continue;
          end;
        end;

        if not IsRescanMode then
          UpdaterStorage.RemoveFilesWithErrors(ItemsToAdd, ItemSizes);

        if (ItemsToAdd.Count > 0) and IsDirectoryChangedOnDrive(Dir, ItemSizes, ItemsToAdd, ItemsToUpdate) and IsValidThread then
        begin
          if ItemsToAdd.Count > 0 then
            AddItemsToDatabase(ItemsToAdd);
          if ItemsToUpdate.Count > 0 then
            UpdateItemsInDatabase(ItemsToUpdate);
        end else
          SavedDirectoriesStructure.AddOrSetValue(DirectoryPath, TotalDirectorySize);
      end;

      if not IsRescanMode then
        SaveDirectoriesState(ScanInformationFileName, SavedDirectoriesStructure);
    finally
      SetErrorMode(OldMode);
      F(ItemSizes);
      F(ItemsToAdd);
      FreeList(ItemsToUpdate);
      F(SavedDirectoriesStructure);
      F(Directories);
    end;
  finally
    CoUninitialize;
    Dec(UserDirectoryUpdaterCount);
  end;
end;

function TDatabaseDirectoriesUpdater.GetIsValidThread: Boolean;
begin
  Result := FThreadID = DirectoriesScanID;
end;

function TDatabaseDirectoriesUpdater.IsDirectoryChangedOnDrive(
  Directory: string; ItemSizes: TList<Int64>; ItemsToAdd: TList<string>; ItemsToUpdate: TList<TUpdateTask>): Boolean;
var
  I, J: Integer;
  DA: TImageTableAdapter;
  FileName: string;
begin
  if ItemsToAdd.Count = 0 then
    Exit(False);

  SetSQL(FQuery, 'Select ID, FileSize, Name FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(Directory, False)));
  if TryOpenCDS(FQuery) then
  begin
    if not FQuery.IsEmpty then
    begin
      FQuery.First;
      DA := TImageTableAdapter.Create(FQuery);
      try
        for I := 1 to FQuery.RecordCount do
        begin
          FileName := AnsiLowerCase(Directory + DA.Name);

          for J := ItemsToAdd.Count - 1 downto 0 do
            if(AnsiLowerCase(ItemsToAdd[J]) = FileName) then
            begin
              if (ItemSizes[J] <> DA.FileSize) then
                ItemsToUpdate.Add(TUpdateTask.Create(FDBContext, Da.ID, ItemsToAdd[J]));

              ItemsToAdd.Delete(J);
              ItemSizes.Delete(J);
            end;

          FQuery.Next;
        end;

      finally
        F(DA);
      end;
    end;

    Exit((ItemsToAdd.Count > 0) or (ItemsToUpdate.Count > 0));

  end else
    Exit(True);
end;

procedure TDatabaseDirectoriesUpdater.UpdateItemsInDatabase(
  Items: TList<TUpdateTask>);
begin
  UpdaterStorage.AddRange(TList<TDatabaseTask>(Items));
  Items.Clear;
end;

procedure TDatabaseDirectoriesUpdater.AddItemsToDatabase(Items: TList<string>);
var
  FileName: string;
  AddTasks: TList<TAddTask>;
begin
  AddTasks := TList<TAddTask>.Create;
  try
     for FileName in Items do
       AddTasks.Add(TAddTask.Create(FDBContext, FileName));

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

procedure TUserDirectoriesWatcher.Execute(Context: IDBContext);
begin
  inherited;
  FDBContext := Context;
  StartWatch;
  TDatabaseDirectoriesUpdater.Create(FDBContext);
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
    ReadDatabaseDirectories(FolderList, FDBContext.CollectionFileName);
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

    if not IsGraphicFile(Info.FNewFileName) then
      Exit;

    if (Info.FNewFileName <> '') and TLockFiles.Instance.IsFileLocked(Info.FNewFileName) then
      Continue;
    if (Info.FOldFileName <> '') and TLockFiles.Instance.IsFileLocked(Info.FOldFileName) then
      Continue;

    //TODO:
    //if not CanAddFileAutomatically(Info.FNewFileName) then
    //  Exit;

    case Info.FAction of
      FILE_ACTION_ADDED:
        UpdaterStorage.Add(TAddTask.Create(FDBContext, Info.FNewFileName));
      FILE_ACTION_REMOVED,
      FILE_ACTION_RENAMED_NEW_NAME:
        Break;
      FILE_ACTION_MODIFIED:
        UpdaterStorage.Add(TUpdateTask.Create(FDBContext, 0, Info.FNewFileName));
    end;
  end;
end;

procedure TUserDirectoriesWatcher.TerminateWatcher(Sender: TObject; SID: TGUID;
  Folder: string);
begin
  //do nothing for now
end;

{ TDatabaseTask }

constructor TDatabaseTask.Create(DBContext: IDBContext; FileName: string);
begin
  FDBContext := DBContext;
  FFileName := FileName;
end;

function TDatabaseTask.IsPrepaired: Boolean;
var
  hFile: THandle;
begin
  Result := False;

  //don't allow to write to file and try to open file
  hFile := CreateFile(PChar(FFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  try
    Result := (hFile <> INVALID_HANDLE_VALUE) and (hFile <> 0);
  finally
    if Result then
      CloseHandle(hFile);
  end;
end;

{ TUpdateTask }

constructor TUpdateTask.Create(DBContext: IDBContext; ID: Integer; FileName: string);
begin
  inherited Create(DBContext, FileName);
  FFileName := FileName;
  FID := ID;
end;

procedure TUpdateTask.Execute;
var
  MediaRepository: IMediaRepository;
begin
  MediaRepository := FDBContext.Media;
  try
    if FID = 0 then
      FID := MediaRepository.GetIdByFileName(FFileName);

    if not UpdateImageRecord(FDBContext, nil, FFileName, ID) then
      UpdaterStorage.AddFileWithErrors(FFileName);

  except
    on e: Exception do
      EventLog(e);
  end;
end;

{ TAddTask }

constructor TAddTask.Create(DBContext: IDBContext; Data: TMediaItem);
begin
  if Data = nil then
    raise Exception.Create('Can''t create task for null task!');

  inherited Create(DBContext, Data.FileName);

  FData := Data.Copy;
end;

constructor TAddTask.Create(DBContext: IDBContext; FileName: string);
begin
  inherited Create(DBContext, FileName);
  FData := TMediaItem.CreateFromFile(FileName);
  FData.Include := True;
end;

destructor TAddTask.Destroy;
begin
  F(FData);
  inherited;
end;

procedure TAddTask.Execute(Items: TArray<TAddTask>);
var
  I: Integer;
  ResArray: TMediaInfoArray;
  Infos: TMediaItemCollection;
  Info: TMediaItem;
  Res: TMediaInfo;
  MediaRepository: IMediaRepository;
 { SettingsRepository: ISettingsRepository;
  Settings: TSettings;

  JpegCompressionQuality: TJPEGQualityRange;
  ThumbnailSize: Integer;  }
begin
  MediaRepository := FDBContext.Media;
 {
  SettingsRepository := FDBContext.Settings;

  Settings := SettingsRepository.Get;
  try
    JpegCompressionQuality := Settings.DBJpegCompressionQuality;
    ThumbnailSize := Settings.ThSize;
  finally
    F(Settings);
  end;     }

  try
    Infos := TMediaItemCollection.Create;
    try
      for I := 0 to Length(Items) - 1 do
        Infos.Add(Items[I].Data.Copy);

      ResArray := GetImageIDWEx(FDBContext, Infos, False);
      try
        for I := 0 to Length(ResArray) - 1 do
        begin
          Res := ResArray[I];
          Info := Infos[I];

          if Res.Jpeg = nil then
          begin
            //failed to load image
            UpdaterStorage.AddFileWithErrors(Info.FileName);
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

          UpdaterStorage.RemoveFileWithErrors(Info.FileName);

          //new file in collection
          if Res.Count = 0 then
          begin
            TDatabaseUpdateManager.AddFile(FDBContext, Info, Res);
            Continue;
          end;

          if Res.Count = 1 then
          begin
            //moved file
            if (StaticPath(Res.FileNames[0]) and not FileExists(Res.FileNames[0])) or (Res.Attr[0] = Db_attr_not_exists) then
            begin
              TDatabaseUpdateManager.MergeWithExistedInfo(FDBContext, Res.IDs[0], Info, Res);
              Continue;
            end;

            //the same file was deleted
            if (AnsiLowerCase(Res.FileNames[0]) = AnsiLowerCase(Info.FileName)) and (Res.Attr[0] = Db_attr_not_exists) then
            begin
              MediaRepository.SetAttribute(Info.ID, Db_attr_norm);
              Continue;
            end;

            //the same file, skip
            if AnsiLowerCase(Res.FileNames[0]) = AnsiLowerCase(Info.FileName) then
            begin
              MediaRepository.SetFileNameById(Res.IDs[0], Info.FileName);
              Continue;
            end;
          end;

          //add file as duplicate
          TDatabaseUpdateManager.AddFileAsDuplicate(FDBContext, Info, Res);
        end;

      finally
        for I := 0 to Length(ResArray) - 1 do
          if ResArray[I].Jpeg <> nil then
             ResArray[I].Jpeg.Free;
      end;
    finally
      F(Infos);
    end;

  except
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TAddTask.NotifyAboutFileProcessing(Info: TMediaItem; Res: TMediaInfo);
var
  EventInfo: TEventValues;
begin
  Info.SaveToEvent(EventInfo);
  EventInfo.JPEGImage := Res.Jpeg;
  CollectionEvents.DoIDEvent(Application.MainForm as TDBForm, Info.ID, [EventID_FileProcessed], EventInfo);
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

    Inc(FTotalItemsCount);
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.AddDirectory(DirectoryPath: string);
begin
  //TODO:
end;

procedure TUpdaterStorage.AddFile(Info: TMediaItem; Priority: TDatabaseTaskPriority);
begin
  Add(TAddTask.Create(FContext, Info), Priority);
end;

procedure TUpdaterStorage.AddFile(FileName: string; Priority: TDatabaseTaskPriority);
var
  Info: TMediaItem;
begin
  Info := TMediaItem.Create;
  try
    AddFile(Info, Priority);
  finally
    F(Info);
  end;
end;

procedure TUpdaterStorage.AddFileWithErrors(FileName: string);
begin
  FSync.Enter;
  try
    FileName := AnsiLowerCase(FileName);
    if FErrorFileList.IndexOf(FileName) = -1 then
      FErrorFileList.Add(AnsiLowerCase(FileName));
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.RemoveFilesWithErrors(Files: TList<string>; FileSizes: TList<Int64>);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := Files.Count - 1 downto 0 do
      if FErrorFileList.IndexOf(AnsiLowerCase(Files[I])) > -1 then
      begin
        Files.Delete(I);
        FileSizes.Delete(I);
      end;
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.RemoveFileWithErrors(FileName: string);
var
  Index: Integer;
begin
  FSync.Enter;
  try
    FileName := AnsiLowerCase(FileName);
    if FErrorFileList.Find(FileName, Index) then
      FErrorFileList.Delete(Index);
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

    Inc(FTotalItemsCount, Tasks.Count);
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.CleanUpDatabase(NewContext: IDBContext);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := FTasks.Count - 1 downto 0 do
      if FTasks[I].FDBContext <> NewContext then
      begin
        FTasks[I].Free;
        FTasks.Delete(I);
        Dec(FTotalItemsCount);
      end;
  finally
    FSync.Leave;
  end;
end;

constructor TUpdaterStorage.Create(Context: IDBContext);
begin
  FContext := Context;
  FSync := TCriticalSection.Create;
  FTasks := TList<TDatabaseTask>.Create;
  TDatabaseUpdater.Create;
  FEstimateRemainingTime := 0;
  FTotalItemsCount := 0;
  FErrorFileList := TStringList.Create;
end;

destructor TUpdaterStorage.Destroy;
begin
  SaveStorage;
  F(FSync);
  FreeList(FTasks);
  F(FErrorFileList);
  FContext := nil;
  inherited;
end;

function TUpdaterStorage.GetActiveItemsCount: Integer;
begin
  FSync.Enter;
  try
    Result := FTasks.Count;
  finally
    FSync.Leave;
  end;
end;

function TUpdaterStorage.GetEstimateRemainingTime: TTime;
begin
  FSync.Enter;
  try
    Result := FEstimateRemainingTime;
  finally
    FSync.Leave;
  end;
end;

function TUpdaterStorage.HasFile(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;

  FSync.Enter;
  try
    FileName := AnsiLowerCase(FileName);

    for I := 0 to FTasks.Count - 1 do
      if AnsiLowerCase(FTasks[I].FileName) = FileName then
        Exit(True);

  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.UpdateRemainingTime(Conter: TSpeedEstimateCounter);
begin
  FSync.Enter;
  try
    FEstimateRemainingTime := Conter.GetTimeRemaining(100 * FTasks.Count);
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.RestoreStorage(Context: IDBContext);
var
  ErrorsFileName: string;
begin
  FSync.Enter;
  try
    FContext := Context;
    ErrorsFileName := DatabaseErrorsPersistaseFileName(Context.CollectionFileName);
    try
      FErrorFileList.LoadFromFile(ErrorsFileName);
    except
      on e: Exception do
        EventLog(e);
    end;
    FErrorFileList.Sort;
  finally
    FSync.Leave;
  end;
end;

procedure TUpdaterStorage.SaveStorage;
var
  ErrorsFileName: string;
begin
  FSync.Enter;
  try
    ErrorsFileName := DatabaseErrorsPersistaseFileName(FContext.CollectionFileName);
    FErrorFileList.SaveToFile(ErrorsFileName);
    FErrorFileList.Clear;
  finally
    FSync.Leave;
  end;
end;

function TUpdaterStorage.Take<T>(Count: Integer): TArray<T>;
var
  I: Integer;
  PI: PInteger;
  FItems: TList<T>;
begin
  FSync.Enter;
  try
    FItems := TList<T>.Create;
    try
      PI := @I;
      for I := 0 to FTasks.Count - 1 do
      begin
        if not FileExistsSafe(FTasks[I].FileName) then
        begin
          FTasks[I].Free;
          FTasks.Delete(I);

          Dec(PI^);
          Continue;
        end;

        if (FTasks[I] is T) and FTasks[I].IsPrepaired then
        begin
          FItems.Add(FTasks[I]);
          if FItems.Count = Count then
            Break;
        end;
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
  Tasks := Take<T>(1);
  if Length(Tasks) = 0 then
    Exit(nil);

  Exit(Tasks[0]);
end;

{ TDatabaseUpdater }

constructor TDatabaseUpdater.Create;
begin
  inherited Create(nil, False);
  FSpeedCounter := TSpeedEstimateCounter.Create(60 * 1000); //60 sec is estimate period
end;

destructor TDatabaseUpdater.Destroy;
begin
  F(FSpeedCounter);
  inherited;
end;

procedure TDatabaseUpdater.Execute;
var
  Task: TDatabaseTask;
  AddTasks: TArray<TAddTask>;
  UpdateTask: TUpdateTask;
begin
  inherited;
  FreeOnTerminate := True;
  Priority := tpLowest;

  //task will work in background
  while True do
  begin
    if DBTerminating then
      Break;

    AddTasks := UpdaterStorage.Take<TAddTask>(cAddImagesAtOneStep);
    try
      if Length(AddTasks) > 0 then
      begin
        AddTasks[0].Execute(AddTasks);
        FSpeedCounter.AddSpeedInterval(100 * Length(AddTasks));

        UpdaterStorage.UpdateRemainingTime(FSpeedCounter);
      end;
    finally
      for Task in AddTasks do
        Task.Free;
    end;

    if DBTerminating then
      Break;

    UpdateTask := UpdaterStorage.TakeOne<TUpdateTask>();
    try
      if UpdateTask <> nil then
      begin
        UpdateTask.Execute;
        FSpeedCounter.AddSpeedInterval(100 * 1);
      end;
    finally
      F(UpdateTask);
    end;
  end;
end;

initialization
  FStorageLock := TCriticalSection.Create;

finalization
  F(FUpdaterStorage);
  F(FStorageLock);

end.

