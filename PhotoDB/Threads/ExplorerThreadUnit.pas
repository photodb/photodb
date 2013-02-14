unit ExplorerThreadUnit;

interface

uses
  Generics.Collections,
  System.Math,
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  System.SyncObjs,
  Winapi.Windows,
  Winapi.ActiveX,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Imaging.Jpeg,
  Vcl.Imaging.pngImage,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Network,
  Dmitry.Utils.Files,
  Dmitry.Utils.ShellIcons,
  Dmitry.Graphics.Utils,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,
  Dmitry.PathProviders.Network,

  CCR.Exif,

  ExplorerTypes,
  uGraphicUtils,
  uShellIntegration,
  UnitDBKernel,
  ExplorerUnit,
  UnitGroupsWork,
  GraphicCrypt,
  RAWImage,
  UnitDBDeclare,
  EasyListview,
  UnitDBCommon,
  CommonDBSupport,
  UnitBitmapImageList,

  uExplorerFolderImages,
  uGUIDUtils,
  uResources,
  uBitmapUtils,
  uCDMappingTypes,
  uExifUtils,
  uThreadEx,
  uAssociatedIcons,
  uLogger,
  uTime,
  uGOM,
  uConstants,
  uMemory,
  uGroupTypes,
  uSearchQuery,
  uDBPopupMenuInfo,
  uPNGUtils,
  uMultiCPUThreadManager,
  uPrivateHelper,
  uRuntime,
  uDBUtils,
  uAssociations,
  uJpegUtils,
  uShellThumbnails,
  uMachMask,
  uDatabaseSearch,
  uTransparentEncryption,
  uExplorerSearchProviders,
  uExplorerGroupsProvider,
  uExplorerPersonsProvider,
  uExplorerPortableDeviceProvider,
  uExplorerDateStackProviders,
  uPhotoShelf,
  uImageLoader;

type
  TExplorerThread = class(TMultiCPUThread)
  private
    { Private declarations }
    FFolder: string;
    FLastFolderCheck: string;
    FMask: string;
    FIcon: TIcon;
    FCID: TGUID;
    TempBitmap: TBitmap;
    FBmp: TBitmap;
    FSelected: TEasyItem;
    FFolderBitmap: TBitmap;
    FFolderImages: TFolderImages;
    FCountOfFolderImage: Integer;
    FFastDirectoryLoading: Boolean;
    FFiles: TExplorerFileInfos;
    BooleanResult: Boolean;
    BooleanParam: Boolean;
    StringParam: string;
    GUIDParam: TGUID;
    CurrentFile: string;
    FShowFiles: Boolean;
    FQuery: TDataSet;
    FInfoText: string;
    FInfoMax: Integer;
    FInfoPosition: Integer;
    SetText, Setmax, SetPos: Boolean;
    ProgressVisible: Boolean;
    FThreadType: Integer;
    StrParam: string;
    FIcoSize: Integer;
    FilesWithoutIcons, IntIconParam: Integer;
    CurrentInfoPos: Integer;
    FVisibleFiles: TStrings;
    IsBigImage: Boolean;
    NewItem: TEasyItem;
    FOwnerThreadType: Integer;
    CurrentFileInfo: TExplorerFileInfo;
    FPacketImages: TBitmapImageList;
    FPacketInfos: TExplorerFileInfos;
    FInvalidate: Boolean;
    FUpdaterInfo: TUpdaterInfo;
  protected
    procedure GetVisibleFiles;
    procedure Execute; override;
    procedure InfoToExplorerForm;
    procedure MakeTempBitmap;
    procedure BeginUpDate;
    procedure EndUpDate(Invalidate: Boolean = True);
    procedure EndUpDateSync;
    procedure MakeFolderImage(Folder: String);
    procedure FileNeededAW;
    procedure AddDirectoryIconToExplorer;
    procedure AddImageFileToPacket;
    procedure AddImageFileImageToExplorer;
    procedure AddImageFileItemToExplorer;
    procedure ReplaceImageItemImage(FileName: string; FileSize: Int64; FileID: TGUID);
    procedure ReplaceImageInExplorer;
    procedure ReplaceInfoInExplorer;
    procedure ReplaceThumbImageToFolder(CurrentFile : string; DirctoryID : TGUID);
    procedure DrawFolderImageBig(Bitmap: TBitmap);
    procedure DrawFolderImageWithXY(Bitmap: TBitmap; FolderImageRect: TRect; Source: TBitmap);
    procedure ReplaceFolderImage;
    procedure AddFile;
    procedure AddImageFileToExplorerW;
    procedure AddImageFileItemToExplorerW;
    function FindInQuery(FileName: String): Boolean;
    procedure ShowInfo(StatusText: String); overload;
    procedure ShowInfo(Max, Value: Integer); overload;
    procedure ShowInfo(StatusText: String; Max, Value: Integer); overload;
    procedure ShowInfo(Pos : Integer); overload;
    procedure SetInfoToStatusBar;
    procedure ShowProgress;
    procedure HideProgress;
    procedure ShowIndeterminateProgress;
    procedure DoStopSearch;
    procedure SetProgressVisible;
    procedure PathProviderCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var ABreak: Boolean);
    function LoadProviderItem(Item: TPathItem; PacketSize, ImageSize: Integer): Boolean;
    function LoadProviderItemEx(Item: TPathItem; PacketSize, ImageSize: Integer; Text: string): Boolean;
    procedure LoadMyComputerFolder;
    procedure LoadNetWorkFolder;
    procedure MakeImageWithIcon;
    procedure LoadWorkgroupFolder;
    procedure LoadComputerFolder;
    procedure LoadGroups;
    procedure LoadPersons;
    procedure LoadDeviceItems;
    procedure LoadShelf;
    procedure LoadPathItem;
    procedure ShowMessage_;
    procedure ExplorerBack;
    procedure UpdateFile;
    procedure UpdateFolder;
    procedure ReplaceImageInExplorerB;
    procedure MakeIconForFile;
    procedure CheckIsFileEncrypted;
    function ShowFileIfHidden(FileName: string): Boolean;
    procedure UpdateSimpleFile;
    procedure DoUpdaterHelpProc;
    procedure EndUpdateID;
    procedure VisibleUp(TopIndex: Integer);
    procedure DoLoadBigImages(LoadOnlyDBItems: Boolean);
    procedure GetAllFiles;
    procedure DoDefaultSort;
    procedure ExtractImage(Info: TDBPopupMenuInfoRecord; EncryptedFile: Boolean; FileID: TGUID);
    procedure ExtractDirectoryPreview(FileName: string; DirectoryID: TGUID);
    procedure ExtractBigPreview(FileName: string; ID: Integer; Rotated: Integer; FileGUID: TGUID);
    procedure DoMultiProcessorTask; override;
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure SendPacket;
    procedure SendInfoToExplorer(Info: TExplorerFileInfo; var LastPacketTime: Cardinal);
    procedure SendPacketToExplorer;
    procedure SearchFolder(SearchContent: Boolean);
    procedure SearchDB; overload;
    procedure SearchDB(DateFrom, DateTo: TDateTime; GroupName: string); overload;
    procedure SearchDB(Parameters: TDatabaseSearchParameters); overload;
    function IsImage(SearchRec: TSearchRec): Boolean;
    function ProcessSearchRecord(FFiles: TExplorerFileInfos; Directory: string; SearchRec: TSearchRec): Boolean;
    procedure OnDatabasePacketReady(Sender: TDatabaseSearch; Packet: TDBPopupMenuInfo);
  protected
    function IsVirtualTerminate: Boolean; override;
    function GetThreadID: string; override;
  public
    ExplorerInfo: TExplorerViewInfo;
    FInfo: TDBPopupMenuInfoRecord;
    IsCryptedFile: Boolean;
    FFileID: TGUID;
    FSender: TExplorerForm;
    LoadingAllBigImages: Boolean;
    constructor Create(Folder, Mask: string; ThreadType: Integer; Info: TExplorerViewInfo; Sender: TExplorerForm;
      UpdaterInfo: TUpdaterInfo; SID: TGUID);
    destructor Destroy; override;
    property OwnerThreadType: Integer read FOwnerThreadType write FOwnerThreadType;
    property ThreadType: Integer read FThreadType;
    property UpdaterInfo: TUpdaterInfo read FUpdaterInfo;
  end;

const
  UPDATE_MODE_ADD             = 1;
  UPDATE_MODE_REFRESH_IMAGE   = 2;
  UPDATE_MODE_REFRESH_FOLDER  = 3;
  UPDATE_MODE_REFRESH_FILE    = 4;

type
  TExplorerNotifyInfo = class
  private
    FExplorerViewInfo: TExplorerViewInfo;
    FUpdaterInfo: TUpdaterInfo;
    FOwner: TExplorerForm;
    FState: TGUID;
    FFileName: string;
    FGUID: string;
    FMode: Integer;
  public
    constructor Create(Owner: TExplorerForm; State: TGUID;
      UpdaterInfo: TUpdaterInfo; ExplorerViewInfo: TExplorerViewInfo;
      Mode: Integer; FileName, GUID: string);
    destructor Destroy; override;
    property UpdaterInfo: TUpdaterInfo read FUpdaterInfo;
  end;

type
  TExplorerWindowThreads = class
  public
    FExplorer: TExplorerForm;
    FMode: Integer;
    FCounter: Integer;
    constructor Create(Explorer: TExplorerForm; Mode: Integer);
  end;

  TExplorerUpdateManager = class(TObject)
  private
    FSync: TCriticalSection;
    FData: TList<TExplorerNotifyInfo>;
    FExplorerThreads: TList;
    FLastVisibleRequest: Cardinal;
  protected
    constructor Create;
  public
    destructor Destroy; override;
    procedure QueueNotify(Info: TExplorerNotifyInfo);
    function DeQueue(FOwner: TExplorerForm; FState: TGUID; Mode: Integer): TExplorerNotifyInfo;
    procedure CleanUp(FOwner: TExplorerForm);
    procedure CleanUpState(StateID: TGUID);
    procedure RegisterThread(FOwner: TExplorerForm; Mode: Integer);
    procedure UnRegisterThread(FOwner: TExplorerForm; Mode: Integer);
    function GetThreadCount(FOwner: TExplorerForm; Mode: Integer): Integer;
  end;

type
  TIconType = (itSmall, itLarge);

function ExplorerUpdateManager: TExplorerUpdateManager;

implementation

uses
  uExplorerThreadPool;

var
  ExplorerUpdateBigImageThreadsCount: Integer = 0;
  FullFolderPicture: TPNGImage = nil;
  FFolderPictureLock: TCriticalSection = nil;
  ExplorerUpdateManagerInstance: TExplorerUpdateManager = nil;

function ExplorerUpdateManager: TExplorerUpdateManager;
begin
  if ExplorerUpdateManagerInstance = nil then
    ExplorerUpdateManagerInstance := TExplorerUpdateManager.Create;

  Result := ExplorerUpdateManagerInstance;
end;

{ TExplorerThread }

constructor TExplorerThread.Create(Folder, Mask: string; ThreadType: Integer; Info: TExplorerViewInfo;
  Sender: TExplorerForm; UpdaterInfo: TUpdaterInfo; SID: TGUID);
begin
  inherited Create(Sender, SID);
  FInfo := TDBPopupMenuInfoRecord.Create;
  CurrentFileInfo := nil;
  FPacketImages := nil;
  FPacketInfos := nil;
  FThreadType := ThreadType;
  FOwnerThreadType := THREAD_TYPE_NONE;
  FSender := Sender;
  FFolder := Folder;
  FMask := Mask;
  FCID := SID;
  ExplorerInfo := Info;
  FShowFiles := True;
  FUpdaterInfo := UpdaterInfo;
  FVisibleFiles := nil;
  FFiles := nil;
  FEvent := 0;
  Start;
end;

procedure TExplorerThread.Execute;
type
  TProcessNotifyProc = procedure of object;
var
  Found, FilesReadedCount: Integer;
  SearchRec: TSearchRec;
  I: Integer;
  DBFolder, DBFolderToSearch, FileMask: string;
  InfoPosition: Integer;
  PrivateFiles: TStringList;
  Crc: Cardinal;
  IsPrivateDirectory: Boolean;
  NotifyInfo: TExplorerNotifyInfo;
  P: TPathItem;
  COMMode: Integer;

  procedure LoadDBContent;
  begin
    ShowInfo(L('Query in collection...'), 1, 0);

    SetSQL(FQuery, 'Select * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FFolder, False)));
    TryOpenCDS(FQuery);
  end;

  procedure ProcessNotifys(NotifyProcessProcedure: TProcessNotifyProc; UpdateMode: Integer);
  begin
    NotifyInfo := nil;
    try
      repeat
        F(NotifyInfo);
        try
          NotifyProcessProcedure;
        except
          on e: Exception do
            EventLog(e.Message);
        end;
        NotifyInfo := ExplorerUpdateManager.DeQueue(FSender, StateID, UpdateMode);
        if NotifyInfo <> nil then
        begin
          FMask := '';
          ExplorerInfo := NotifyInfo.FExplorerViewInfo;
          UpdaterInfo.Assign(NotifyInfo.FUpdaterInfo);
          FFolder := FUpdaterInfo.FileName;
        end;
      until NotifyInfo = nil;
    finally
      ExplorerUpdateManager.UnRegisterThread(FSender, UpdateMode);
      //check if new info is became avliable since last check was performed
      ExplorerUpdateManager.QueueNotify(ExplorerUpdateManager.DeQueue(FSender, StateID, UpdateMode));
    end;
  end;

begin
  inherited;
  FreeOnTerminate := True;

  if (FThreadType = THREAD_TYPE_CAMERA) or (FThreadType = THREAD_TYPE_CAMERAITEM) or (FThreadType = THREAD_TYPE_MY_COMPUTER) then
    COMMode := COINIT_MULTITHREADED
  else
    COMMode := COINIT_APARTMENTTHREADED;

  CoInitializeEx(nil, COMMode);
  try
    LoadingAllBigImages := True;

    case ExplorerInfo.View of
      LV_THUMBS     : begin FIcoSize := 48; end;
      LV_TILE       : begin FIcoSize := 48; end;
      LV_ICONS      : begin FIcoSize := 32; end;
      LV_SMALLICONS : begin FIcoSize := 16; end;
      LV_TITLES     : begin FIcoSize := 16; end;
      LV_GRID       : begin FIcoSize := 16; end;
    end;
                                      //if thread is valid worker - dont run updater
    if FUpdaterInfo.IsUpdater and not Self.Valid then
    begin
      ProcessNotifys(AddFile, UPDATE_MODE_ADD);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_THREAD_PREVIEW) then
    begin
      StartMultiThreadWork;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
    begin
      F(FFiles);
      FFiles := TExplorerFileInfos.Create;
      ShowProgress;
      DoLoadBigImages(False);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_IMAGE) then
    begin
      LoadingAllBigImages := False; //грузятся не все файлы заново а только текущий
      ProcessNotifys(UpdateFile, UPDATE_MODE_REFRESH_IMAGE);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_FILE) then
    begin
      ProcessNotifys(UpdateSimpleFile, UPDATE_MODE_REFRESH_FILE);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_FOLDER_UPDATE) then
    begin
      ProcessNotifys(UpdateFolder, UPDATE_MODE_REFRESH_FOLDER);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_SEARCH_FOLDER) then
    begin
      SearchFolder(False);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_SEARCH_IMAGES) then
    begin
      SearchFolder(True);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_GROUP) then
    begin
      P := PathProviderManager.CreatePathItem(FFolder);
      try
        if P is TGroupItem then
        begin
          FMask := Format(':Group(%s):', [TGroupItem(P).GroupName]);
          SearchDB;
          Exit;
        end;
      finally
        F(P);
      end;
    end;

    if (FThreadType = THREAD_TYPE_PERSON) then
    begin
      P := PathProviderManager.CreatePathItem(FFolder);
      try
        if P is TPersonItem then
        begin
          FMask := Format(':Person(%s):', [TPersonItem(P).PersonName]);
          SearchDB;
          Exit;
        end;
      finally
        F(P);
      end;
    end;

    if (FThreadType = THREAD_TYPE_SEARCH_DB) then
    begin
      SearchDB;
      Exit;
    end;

    ShowInfo(L('Initialization') + '...', 1, 0);
    FFolderBitmap := nil;
    FSelected := nil;

    SynchronizeEx(ShowLoadingSign);
    try

      if (FThreadType = THREAD_TYPE_MY_COMPUTER) then
      begin
       LoadMyComputerFolder;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      if (FThreadType = THREAD_TYPE_NETWORK) then
      begin
        LoadNetWorkFolder;
        SynchronizeEx(DoStopSearch);
        Exit;
      end;
      if (FThreadType = THREAD_TYPE_WORKGROUP) then
      begin
        LoadWorkgroupFolder;
        SynchronizeEx(DoStopSearch);
        Exit;
      end;
      if (FThreadType = THREAD_TYPE_COMPUTER) then
      begin
        LoadComputerFolder;
        SynchronizeEx(DoStopSearch);
        Exit;
      end;
      if (FThreadType = THREAD_TYPE_GROUPS) then
      begin
       LoadGroups;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      if (FThreadType = THREAD_TYPE_PERSONS) then
      begin
       LoadPersons;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      if (FThreadType = THREAD_TYPE_CAMERA) or (FThreadType = THREAD_TYPE_CAMERAITEM) then
      begin
       LoadDeviceItems;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      if (FThreadType = THREAD_TYPE_SHELF) then
      begin
       LoadShelf;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      if (FThreadType = THREAD_TYPE_PATH_ITEM) then
      begin
       LoadPathItem;
       SynchronizeEx(DoStopSearch);
       Exit;
      end;
      FFolder := ExcludeTrailingBackslash(FFolder);
      if not DirectoryExists(FFolder) then
      begin
        StrParam := Format(L('Folder "%s" not found!'), [FFolder]);
        SynchronizeEx(ShowMessage_);
        ShowInfo('', 1, 0);
        SynchronizeEx(ExplorerBack);
        Exit;
      end;

      TW.I.Start('<EXPLORER THREAD>');
      PrivateFiles := TStringList.Create;
      try

        DBFolderToSearch := FFolder;

        UnProcessPath(DBFolderToSearch);
        DBFolderToSearch := ExcludeTrailingBackslash(AnsiLowerCase(DBFolderToSearch));
        CalcStringCRC32(AnsiLowerCase(DBFolderToSearch), crc);
        DBFolderToSearch := IncludeTrailingBackslash(DBFolderToSearch);
        FFolder := IncludeTrailingBackslash(FFolder);
        F(FFiles);
        FFiles := TExplorerFileInfos.Create;

        IsPrivateDirectory := TPrivateHelper.Instance.IsPrivateDirectory(DBFolderToSearch);

        DBFolder := NormalizeDBStringLike(NormalizeDBString(DBFolderToSearch));
        FQuery := GetQuery(True);
        try
          ReadOnlyQuery(FQuery);
          TW.I.Start('IsPrivateDirectory');
          if IsPrivateDirectory then
            LoadDBContent;

          if not FQuery.IsEmpty and not ExplorerInfo.ShowPrivate then
          begin
            FQuery.First;
            for I := 1 to FQuery.RecordCount do
            begin
              if FQuery.FieldByName('Access').AsInteger = Db_access_private then
                PrivateFiles.Add(AnsiLowerCase(ExtractFileName(FQuery.FieldByName('FFileName').AsString)));

              FQuery.Next;
            end;
            PrivateFiles.Sort;
          end;

          TW.I.Start('Reading directory');
          ShowInfo(L('Reading directory') + '...', 1, 0);
          FilesReadedCount := 0;
          FilesWithoutIcons := 0;
          if FMask = '' then FileMask:='*.*' else
            FileMask := FMask;
          Found := FindFirst(FFolder + FileMask, FaAnyFile, SearchRec);
          while Found = 0 do
          begin
            if IsTerminated then
              Break;
            try
              if not ExplorerInfo.ShowPrivate then
                if PrivateFiles.IndexOf(AnsiLowerCase(SearchRec.name)) > -1 then
                  Continue;

              Inc(FilesReadedCount);
              if FilesReadedCount mod 50 = 0 then
                ShowInfo(Format(L('Reading directory [%d objects found]'), [FilesReadedCount]), 1, 0);

              ProcessSearchRecord(FFiles, FFolder, SearchRec);
            finally
              Found := System.SysUtils.FindNext(SearchRec);
            end;
          end;
          System.SysUtils.FindClose(SearchRec);

          FPacketImages := TBitmapImageList.Create;
          FPacketInfos := TExplorerFileInfos.Create;
          try

            TW.I.Start('Loading info');
            ShowInfo(L('Loading info') + '...', 1, 0);
            ShowProgress;

            ShowInfo(L('Loading directories') + '...', FFiles.Count, 0);
            InfoPosition := 0;
            for I := 0 to FFiles.Count - 1 do
            begin
              CurrentFileInfo := FFiles[i];
              CurrentFileInfo.Tag := 0;
              if CurrentFileInfo.FileType = EXPLORER_ITEM_FOLDER then
              begin
                if IsTerminated then
                  Break;
                FPacketInfos.Add(CurrentFileInfo);
                GUIDParam := CurrentFileInfo.SID;
                CurrentFile := CurrentFileInfo.FileName;
                MakeFolderImage(CurrentFile);
                FPacketImages.AddIcon(FIcon, True);
                FIcon := nil;

                Inc(InfoPosition);
                if InfoPosition mod 10 = 0 then
                begin
                  ShowInfo(InfoPosition);
                  SynchronizeEx(SendPacketToExplorer);
                end;
              end;
            end;
            if FPacketInfos.Count > 0 then
              SynchronizeEx(SendPacketToExplorer);

            ShowInfo(L('Loading images') + '...');
            for I := 0 to FFiles.Count - 1 do
            begin
              CurrentFileInfo := FFiles[I];
              if CurrentFileInfo.FileType = EXPLORER_ITEM_IMAGE then
              begin
                if IsTerminated then
                  Break;
                FPacketInfos.Add(CurrentFileInfo);
                GUIDParam := CurrentFileInfo.SID;
                CurrentFile := CurrentFileInfo.FileName;
                AddImageFileToPacket;

                Inc(InfoPosition);
                if InfoPosition mod 10 = 0 then
                begin
                  ShowInfo(InfoPosition);
                  SynchronizeEx(SendPacketToExplorer);
                end;
              end;
            end;
            if FPacketInfos.Count > 0 then
              SynchronizeEx(SendPacketToExplorer);

            ShowInfo(L('Loading files') + '...');
            if FShowFiles then
            for I := 0 to FFiles.Count - 1 do
            begin
              CurrentFileInfo := FFiles[I];
              if CurrentFileInfo.FileType = EXPLORER_ITEM_FILE then
              begin
                if IsTerminated then
                  Break;
                FPacketInfos.Add(CurrentFileInfo);
                GUIDParam := CurrentFileInfo.SID;
                CurrentFile := CurrentFileInfo.FileName;
                AddImageFileToPacket;
                CurrentFileInfo.Tag := IntIconParam;

                Inc(InfoPosition);
                if InfoPosition mod 10 = 0 then
                begin
                  ShowInfo(InfoPosition);
                  SynchronizeEx(SendPacketToExplorer);
                end;
              end;
            end;
            if FPacketInfos.Count > 0 then
              SynchronizeEx(SendPacketToExplorer);

          finally
            F(FPacketImages);
            //FPacketInfos doesn't have own items - it pointers from FFiles
            FPacketInfos.ClearList;
            F(FPacketInfos);
          end;

          SynchronizeEx(DoDefaultSort);

          TW.I.Start('not IsPrivateDirectory');
          if not IsPrivateDirectory then
            LoadDBContent;

          TW.I.Start('Loading thumbnails');
          ShowInfo(L('Loading thumbnails') + '...');
          ShowInfo(FFiles.Count, 0);
          InfoPosition := 0;
          SynchronizeEx(HideLoadingSign);

          for I := 0 to FFiles.Count - 1 do
          begin
            if IsTerminated then Break;
            if I mod 5 = 0 then
            begin
              TW.I.Start('GetVisibleFiles');
              F(FVisibleFiles);
              if SynchronizeEx(GetVisibleFiles) then
                VisibleUp(I);
              TW.I.Start('GetVisibleFiles - end');
            end;

            if FFiles[I].FileType = EXPLORER_ITEM_IMAGE then
            begin
              Inc(InfoPosition);
              ShowInfo(InfoPosition);
              CurrentFile := FFiles[I].FileName;
              CurrentInfoPos := I;
              ReplaceImageItemImage(FFiles[I].FileName, FFiles[I].FileSize, FFiles[I].SID);
            end;

            if (FFiles[I].FileType = EXPLORER_ITEM_FILE) then
            begin
              if (FFiles[I].Tag = 1) then
              begin
                FFiles[I].Tag := 1;
                GUIDParam := FFiles[I].SID;
                begin
                  Inc(InfoPosition);
                  ShowInfo(InfoPosition);
                  CurrentFile := FFiles[I].FileName;
                  MakeIconForFile;
                end;
              end;
              CheckIsFileEncrypted;
            end;

            if ExplorerInfo.View = LV_THUMBS then
            begin
              if FFiles[I].FileType = EXPLORER_ITEM_FOLDER then
              begin
                FFiles[I].Tag := 1;
                GUIDParam := FFiles[I].SID;
                begin
                  Inc(InfoPosition);
                  ShowInfo(InfoPosition);
                  if ExplorerInfo.ShowThumbNailsForFolders then
                    ExtractDirectoryPreview(FFiles[I].FileName, FFiles[I].SID);
                end;
              end;
            end else
            begin
              Inc(InfoPosition);
              ShowInfo(InfoPosition);
              CurrentInfoPos := I;
            end;
          end;

          if (ExplorerInfo.View = LV_THUMBS) and (ExplorerInfo.PictureSize <> ThImageSize) then
          begin
            LoadingAllBigImages := False;
            DoLoadBigImages(True);
          end;

          HideProgress;
          ShowInfo('');
          SynchronizeEx(DoStopSearch);
        finally
          FreeDS(FQuery);
        end;
      finally
        F(PrivateFiles);
      end;
    finally
      SynchronizeEx(HideLoadingSign);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TExplorerThread.SearchDB;
var
  Parameters: TDatabaseSearchParameters;
begin
  Parameters := TDatabaseSearchParameters.Create;
  try
    Parameters.Parse(FMask);
    SearchDB(Parameters);
  finally
    F(Parameters);
  end;
end;

procedure TExplorerThread.SearchDB(DateFrom, DateTo: TDateTime; GroupName: string);
var
  DS: TDatabaseSearch;
  SQ: TSearchQuery;
begin
  SynchronizeEx(ShowLoadingSign);
  SynchronizeEx(ShowIndeterminateProgress);
  try
    SQ := TSearchQuery.Create(IIF(ExplorerInfo.View = LV_THUMBS, 0, FIcoSize));
    SQ.Query := FMask;
    SQ.Groups.Add(GroupName);
    SQ.RatingFrom := 0;
    SQ.RatingTo := 5;
    SQ.ShowPrivate := ExplorerInfo.ShowPrivate;
    SQ.DateFrom := DateFrom;
    SQ.DateTo := DateTo;
    SQ.SortMethod := SM_RATING;
    SQ.SortDecrement := True;
    SQ.IsEstimate := False;
    SQ.ShowAllImages := True;
    DS := TDatabaseSearch.Create(Self, SQ);
    try
      DS.OnPacketReady := OnDatabasePacketReady;
      DS.ExecuteSearch;
    finally
      F(DS);
    end;
  finally
    HideProgress;
    ShowInfo('');
    SynchronizeEx(DoStopSearch);
    SynchronizeEx(HideLoadingSign);
  end;
end;

procedure TExplorerThread.SearchDB(Parameters: TDatabaseSearchParameters);
var
  DS: TDatabaseSearch;
  SQ: TSearchQuery;

  function GetSortMode: Integer;
  begin
    Result := SM_RATING;
    case Parameters.SortMode of
      dsmID:
        Exit(SM_ID);
      dsmName:
        Exit(SM_TITLE);
      dsmRating:
        Exit(SM_RATING);
      dsmDate:
        Exit(SM_DATE_TIME);
      dsmFileSize:
        Exit(SM_FILE_SIZE);
      dsmImageSize:
        Exit(SM_IMAGE_SIZE);
      dsmComparing:
        Exit(SM_COMPARING);
    end;
  end;

begin
  SynchronizeEx(ShowLoadingSign);
  SynchronizeEx(ShowIndeterminateProgress);
  try
    SQ := TSearchQuery.Create(IIF(ExplorerInfo.View = LV_THUMBS, 0, FIcoSize));
    SQ.Query := Parameters.Text;

    SQ.Groups.AddStrings(Parameters.Groups);
    SQ.GroupsAnd := Parameters.GroupsAnd;

    SQ.Persons.AddStrings(Parameters.Persons);
    SQ.PersonsAnd := Parameters.PersonsAnd;

    SQ.RatingFrom := Parameters.RatingFrom;
    SQ.RatingTo := Parameters.RatingTo;

    SQ.DateFrom := Parameters.DateFrom;
    SQ.DateTo := Parameters.DateTo;

    SQ.SortMethod := GetSortMode;
    SQ.SortDecrement := Parameters.SortDescending;

    SQ.IsEstimate := False;

    SQ.ShowPrivate := Parameters.ShowPrivate;
    SQ.ShowAllImages := Parameters.ShowHidden;
    DS := TDatabaseSearch.Create(Self, SQ);
    try
      DS.OnPacketReady := OnDatabasePacketReady;
      DS.ExecuteSearch;
    finally
      F(DS);
    end;
  finally
    HideProgress;
    ShowInfo('');
    SynchronizeEx(DoStopSearch);
    SynchronizeEx(HideLoadingSign);
  end;
end;

procedure TExplorerThread.OnDatabasePacketReady(Sender: TDatabaseSearch;
  Packet: TDBPopupMenuInfo);
var
  I: Integer;
  Info: TExplorerFileInfo;
  DataRecord: TDBPopupMenuInfoRecord;
  SearchExtraInfo: TSearchDataExtension;
  FDataList: TList;
begin
  FPacketImages := TBitmapImageList.Create;
  FPacketInfos := TExplorerFileInfos.Create;
  FDataList := TList.Create;
  try
    //create internal package from search package

    for I := 0 to Packet.Count - 1 do
    begin
      DataRecord := Packet[I];

      Info := TExplorerFileInfo.Create;
      Info.Assign(DataRecord, False);
      Info.Loaded := True;
      Info.FileType := EXPLORER_ITEM_IMAGE;
      Info.SID := GetGUID;
      Info.ImageIndex := -1;
      UpdateImageGeoInfo(Info);
      FPacketInfos.Add(Info);
      FDataList.Add(Info);

      SearchExtraInfo := TSearchDataExtension(DataRecord.Data);

      if SearchExtraInfo.Bitmap <> nil then
        FPacketImages.AddBitmap(SearchExtraInfo.Bitmap)
      else
        FPacketImages.AddIcon(SearchExtraInfo.Icon, True);

      SearchExtraInfo.Bitmap := nil;
      SearchExtraInfo.Icon := nil;
    end;

    if not SynchronizeEx(SendPacketToExplorer) then
      FPacketInfos.ClearList;
  finally
    F(FPacketImages);
    F(FPacketInfos);
    FreeList(FDataList);
  end;
end;

procedure TExplorerThread.SendPacket;
var
  UpdaterInfo: TUpdaterInfo;
  NotifyInfo: TExplorerNotifyInfo;
  I: Integer;
  RefreshQueue: TList;
  Info: TExplorerFileInfo;
begin
  if FPacketInfos.Count = 0 then
    Exit;

  RefreshQueue := TList.Create;
  try

    if ExplorerInfo.View = LV_THUMBS then
    begin
      for I := 0 to FPacketInfos.Count - 1 do
      begin
        Info := FPacketInfos[I];
        if ExplorerInfo.ShowThumbNailsForImages and (Info.FileType = EXPLORER_ITEM_IMAGE) then
        begin
          //info for refresh items
          UpdaterInfo := TUpdaterInfo.Create(Info);
          UpdaterInfo.DisableLoadingOfBigImage := (FThreadType = THREAD_TYPE_SHELF);
          NotifyInfo := TExplorerNotifyInfo.Create(FSender, StateID, UpdaterInfo, ExplorerInfo, UPDATE_MODE_REFRESH_IMAGE,
            Info.FileName, GUIDToString(Info.SID));
          RefreshQueue.Add(NotifyInfo);
        end;
        if ExplorerInfo.ShowThumbNailsForFolders and (Info.FileType = EXPLORER_ITEM_FOLDER) then
        begin
          //info for refresh items
          UpdaterInfo := TUpdaterInfo.Create(Info);
          UpdaterInfo.DisableLoadingOfBigImage := (FThreadType = THREAD_TYPE_SHELF);
          NotifyInfo := TExplorerNotifyInfo.Create(FSender, StateID, UpdaterInfo, ExplorerInfo, UPDATE_MODE_REFRESH_FOLDER,
            Info.FileName, GUIDToString(Info.SID));
          RefreshQueue.Add(NotifyInfo);
        end;
        if (Info.FileType = EXPLORER_ITEM_FILE) and (Info.Tag = 1) then
        begin
          //info for refresh items
          UpdaterInfo := TUpdaterInfo.Create(Info);
          NotifyInfo := TExplorerNotifyInfo.Create(FSender, StateID, UpdaterInfo, ExplorerInfo, UPDATE_MODE_REFRESH_FILE,
            Info.FileName, GUIDToString(Info.SID));
          RefreshQueue.Add(NotifyInfo);
        end;
      end;
    end;

    if not SynchronizeEx(SendPacketToExplorer) then
      FPacketInfos.ClearList;

    for I := 0 to RefreshQueue.Count - 1 do
       ExplorerUpdateManager.QueueNotify(TExplorerNotifyInfo(RefreshQueue[I]));

  finally
    F(RefreshQueue);
  end;
end;

procedure TExplorerThread.SendInfoToExplorer(Info: TExplorerFileInfo; var LastPacketTime: Cardinal);
begin
  //add the last info
  FPacketInfos.Add(Info);
  //load icon
  GUIDParam := Info.SID;
  CurrentFile := Info.FileName;

  if Info.FileType = EXPLORER_ITEM_FOLDER then
  begin
    MakeFolderImage(CurrentFile);
    FPacketImages.AddIcon(FIcon, True);
    FIcon := nil;
  end else if Info.FileType = EXPLORER_ITEM_IMAGE then
  begin
    AddImageFileToPacket;
  end else if Info.FileType = EXPLORER_ITEM_FILE then
  begin
    AddImageFileToPacket;
    //new icon should be loaded
    FPacketInfos[FPacketInfos.Count - 1].Tag := IntIconParam;
  end;

  if GetTickCount - LastPacketTime > MIN_PACKET_TIME then
  begin
    LastPacketTime := GetTickCount;
    SendPacket;
  end;
end;

procedure TExplorerThread.LoadShelf;
var
  LastPacketTime: Cardinal;
  List: TStrings;
  Files: TExplorerFileInfos;
  FileInfo: TExplorerFileInfo;
  I: Integer;
  FileName, S: string;
  FileSize: Int64;
begin
  FPacketImages := TBitmapImageList.Create;
  FPacketInfos := TExplorerFileInfos.Create;
  Files := TExplorerFileInfos.Create;
  try
    LastPacketTime := GetTickCount;
    SynchronizeEx(ShowLoadingSign);
    SynchronizeEx(ShowIndeterminateProgress);
    try
      List := TStringList.Create;
      try
        PhotoShelf.GetItems(List);
        LastPacketTime := 0;

        for I := 0 to List.Count - 1 do
        begin
          FileName := List[I];
          FileInfo := nil;

          if FileExistsSafe(FileName) then
          begin
            FileSize := GetFileSize(FileName);
            S := ExtractFileExt(FileName);
            S := '|' + AnsiLowerCase(S) + '|';
            if Pos(S, SupportedExt) <> 0 then
            begin
              FileInfo := AddOneExplorerFileInfo(nil, FileName, EXPLORER_ITEM_IMAGE, -1, GetGUID, 0, 0,
                0, 0, FileSize, '', '', '', 0, False, False, True);
            end else
            begin
              FileInfo := AddOneExplorerFileInfo(nil, FileName, EXPLORER_ITEM_FILE, -1, GetGUID, 0, 0,
                0, 0, FileSize, '', '', '', 0, False, False, True);
            end;
          end else if DirectoryExistsSafe(FileName) then
          begin
            FileInfo := AddOneExplorerFileInfo(nil, FileName, EXPLORER_ITEM_FOLDER, -1, GetGUID, 0, 0,
              0, 0, 0, '', '', '', 0, False, True, True);
          end;

          if FileInfo <> nil then
          begin
            Files.Add(FileInfo);
            SendInfoToExplorer(FileInfo, LastPacketTime);
          end;
        end;
        if FPacketInfos.Count > 0 then
          SendPacket;
      finally
        F(List);
      end;
    finally
      HideProgress;
      ShowInfo('');
      SynchronizeEx(DoStopSearch);
      SynchronizeEx(HideLoadingSign);
    end;
  finally
    F(FPacketInfos);
    F(FPacketImages);
    F(Files);
  end;
end;

procedure TExplorerThread.SearchFolder(SearchContent: Boolean);
var
  LastPacketTime: Cardinal;

  procedure SearchDirectory(CurrentDirectory: string);
  var
    Found: Integer;
    SearchRec: TSearchRec;
    I, J: Integer;
    Files: TExplorerFileInfos;
    CurrentDirectories,
    Directories: TStringList;
    ExifData: TExifData;
    Drive, SearchKey: string;
    DE: Boolean;
    Groups: TGroups;
    DriveType: Cardinal;
  begin
    Files := TExplorerFileInfos.Create;
    try
      //search current level
      CurrentDirectory := IncludeTrailingPathDelimiter(CurrentDirectory);

      Directories := TStringList.Create;
      CurrentDirectories := TStringList.Create;
      try

        if CurrentDirectory = '\' then
        begin
          //search all my computer
          for I := Ord('C') to Ord('Z') do
          begin
            Drive := Chr(I) + ':\';
            DriveType := GetDriveType(PChar(Drive));
            if (DriveType = DRIVE_REMOVABLE) or (DriveType = DRIVE_FIXED) or
              (DriveType = DRIVE_REMOTE) or (DriveType = DRIVE_CDROM) then
              Directories.Add(Chr(I) + ':\');
          end;
        end else if IsNetworkServer(CurrentDirectory)  then
        begin
          // search all server
          FindAllComputers(CurrentDirectory, Directories);
        end else
          Directories.Add(CurrentDirectory);

        repeat
          CurrentDirectories.Assign(Directories);
          Directories.Clear;

          for I := 0 to CurrentDirectories.Count - 1 do
          begin
            if IsTerminated then
              Break;

            CurrentDirectory := IncludeTrailingPathDelimiter(CurrentDirectories[I]);

            Found := FindFirst(CurrentDirectory + '*.*', FaAnyFile, SearchRec);
            while Found = 0 do
            begin
              if IsTerminated then
                Break;

              try
                if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
                  Continue;

                //TODO:
                //if not ExplorerInfo.ShowPrivate then
                //  if PrivateFiles.IndexOf(AnsiLowerCase(SearchRec.Name)) > -1 then
                //     Continue;

                DE := (SearchRec.Attr and FaDirectory <> 0);
                SearchKey := SearchRec.Name;

                if SearchContent and not DE and IsImage(SearchRec) then
                begin
                  ExifData := TExifData.Create;
                  try
                    ExifData.LoadFromGraphic(CurrentDirectory + SearchRec.Name);
                    SearchKey := SearchKey + ' ' + ExifData.Comments;
                    SearchKey := SearchKey + ' ' + ExifData.Keywords;
                    if ExifData.XMPPacket.Groups <> '' then
                    begin
                      Groups := EncodeGroups(ExifData.XMPPacket.Groups);
                      for J := 0 to Length(Groups) - 1 do
                        SearchKey := SearchKey + ' ' + Groups[J].GroupName;
                    end;
                  finally
                    F(ExifData);
                  end;
                end;

                if not IsMatchMask(AnsiLowerCase(SearchKey), FMask, True) then
                begin
                  if DE then
                    //save directory, but don't add to results
                    Directories.Add(CurrentDirectory + SearchRec.Name);
                  Continue;
                end;

                if ProcessSearchRecord(Files, CurrentDirectory, SearchRec) then
                begin
                  if DE then
                    Directories.Add(CurrentDirectory + SearchRec.Name);

                  SendInfoToExplorer(Files[Files.Count - 1], LastPacketTime);
                end;

              finally
                Found := System.SysUtils.FindNext(SearchRec);
              end;
            end;

            ShowInfo(CurrentDirectory);
            System.SysUtils.FindClose(SearchRec);

            SendPacket;
          end;

        until Directories.Count = 0;
      finally
        F(Directories);
        F(CurrentDirectories);
      end;

    finally
      F(Files);
    end;
  end;

begin
  if Pos('*', FMask) = 0 then
    FMask := '*' + FMask + '*';

  FPacketImages := TBitmapImageList.Create;
  FPacketInfos := TExplorerFileInfos.Create;
  try
    LastPacketTime := GetTickCount;
    SynchronizeEx(ShowLoadingSign);
    SynchronizeEx(ShowIndeterminateProgress);
    try
      SearchDirectory(FFolder);
      if FPacketInfos.Count > 0 then
        SendPacket;
    finally
      HideProgress;
      ShowInfo('');
      SynchronizeEx(DoStopSearch);
      SynchronizeEx(HideLoadingSign);
    end;
  finally
    F(FPacketInfos);
    F(FPacketImages);
  end;
end;

procedure TExplorerThread.SendPacketToExplorer;
var
  I: Integer;
  Icon: TIcon;
  Bitmap: TBitmap;
  S1, S2: String;
  Info: TExplorerFileInfo;
begin
  TW.I.Start('BeginUpDate');
  BeginUpDate;
  try
    TW.I.Start('AddInfoAboutFile');
    FSender.AddInfoAboutFile(FPacketInfos);
    for I := 0 to FPacketInfos.Count - 1 do
    begin
      Info := FPacketInfos[I];
      Icon := FPacketImages[I].Icon;
      Bitmap := FPacketImages[I].Bitmap;
      FPacketImages[I].DetachImage;

      if Icon <> nil then
        if not FSender.AddIcon(Icon, True, Info.SID) then
          FPacketImages[I].Graphic := nil;

      if Bitmap <> nil then
        if not FSender.AddBitmap(Bitmap, Info.SID) then
          FPacketImages[I].Graphic := nil;

      TW.I.Start('AddItem');
      if FThreadType = THREAD_TYPE_SEARCH_FOLDER then
        NewItem := FSender.AddItem(Info.SID, True, 0)
      else
        NewItem := FSender.AddItem(Info.SID);
      S1 := ExcludeTrailingBackslash(ExplorerInfo.OldFolderName);
      S2 := ExcludeTrailingBackslash(Info.FileName);

      if AnsiLowerCase(S1) = AnsiLowerCase(S2) then
        FSelected := NewItem;
    end;
    TW.I.Start('ClearList');
    FPacketImages.ClearImagesList;
    FPacketInfos.ClearList;
  finally
    TW.I.Start('EndUpdate');
    EndUpdate(True);
  end;
end;

procedure TExplorerThread.AddImageFileToPacket;
var
  EXT: String;
begin
  EXT := AnsiLowerCase(ExtractFileExt(CurrentFile));
  IntIconParam := 0;
  if (EXT = '.exe') or (EXT = '.scr') then
  begin
    Ficon := TAIcons.Instance.GetIconByExt('file.exe', False, FIcoSize, True);
    Inc(FilesWithoutIcons);
    IntIconParam := 1;
  end else if TAIcons.Instance.IsVarIcon(CurrentFile, FIcoSize) then
  begin
    begin
      Ficon := TAIcons.Instance.GetIconByExt('file.___', False, FIcoSize, True);
      Inc(FilesWithoutIcons);
      IntIconParam := 1;
    end;
  end else
  begin
    Ficon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);
    if (ExplorerInfo.View = LV_THUMBS) and IsVideoFile(CurrentFile) and ExplorerInfo.ShowThumbNailsForVideo then
    begin
      Inc(FilesWithoutIcons);
      IntIconParam := 1;
    end;
  end;

  FPacketImages.AddIcon(FIcon, True);
end;

procedure TExplorerThread.BeginUpdate;
begin
  FSender.BeginUpdate;
end;

procedure TExplorerThread.EndUpDateSync;
begin
  TW.I.Start('EndUpdate START');
  FSender.EndUpdate(FInvalidate);
  TW.I.Start('EndUpdate Select');
  FSender.Select(FSelected, FCID);
  TW.I.Start('EndUpdate CheckFolder');
  if FLastFolderCheck <> FFolder then
  begin
    ExplorerFolders.CheckFolder(FFolder);
    FLastFolderCheck := FFolder;
  end;
end;

procedure TExplorerThread.EndUpdate(Invalidate: Boolean = True);
begin
  FInvalidate := Invalidate;
  SynchronizeEx(EndUpDateSync);
end;

procedure TExplorerThread.InfoToExplorerForm;
begin
  if not IsTerminated then
    FSender.LoadInfoAboutFiles(FFiles);
end;

procedure TExplorerThread.FileNeededAW;
begin
  BooleanResult := False;
  If not IsTerminated then
    BooleanResult := FSender.FileNeededW(GUIDParam);
end;

procedure TExplorerThread.MakeImageWithIcon;
begin
  AddImageFileImageToExplorer;
  AddImageFileItemToExplorer;
end;

procedure TExplorerThread.AddImageFileImageToExplorer;
begin
  if not IsTerminated then
    FSender.AddIcon(FIcon, True, GUIDParam)
  else
    F(FIcon);
end;

procedure TExplorerThread.AddImageFileItemToExplorer;
var
  NewItem: TEasyItem;
begin
  if not IsTerminated then
  begin
    NewItem := FSender.AddItem(GUIDParam);
    If AnsiLowerCase(ExplorerInfo.OldFolderName) = AnsiLowerCase(CurrentFile) then
      FSelected := NewItem;
  end;
end;

procedure TExplorerThread.ReplaceImageItemImage(FileName : string; FileSize : Int64; FileID : TGUID);
var
  FBS: TStream;
  CryptedFile: Boolean;
  JPEG: TJpegImage;
begin
  TempBitmap := nil;
  IsBigImage := False;
  CryptedFile := ValidCryptGraphicFile(FileName);

  F(FInfo);
  FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
  FInfo.FileSize := FileSize;
  FInfo.Encrypted := CryptedFile;
  FInfo.Tag := EXPLORER_ITEM_FOLDER;
  if not FUpdaterInfo.IsUpdater then
  begin
    if FindInQuery(FileName) then
    begin

      FInfo.ReadFromDS(FQuery);
      FInfo.FileName := FileName;
      if ExplorerInfo.View = LV_THUMBS then
      begin
        if FInfo.Encrypted then
        begin
          JPEG := TJpegImage.Create;
          DeCryptBlobStreamJPG(fQuery.FieldByName('thum'), DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum')), JPEG);
          FInfo.Image := JPEG;
          FInfo.IsImageEncrypted := not FInfo.Image.Empty;
        end else
        begin
          FInfo.Image := TJpegImage.Create;
          FBS := GetBlobStream(fQuery.FieldByName('thum'), bmRead);
          try
            FInfo.Image.LoadFromStream(FBS);
          finally
            F(FBS);
          end;
        end;
      end;
    end;
  end else
    GetInfoByFileNameA(CurrentFile, ExplorerInfo.View = LV_THUMBS, FInfo);

  FInfo.InfoLoaded := True;
  FInfo.Tag := EXPLORER_ITEM_IMAGE;

  if not ExplorerInfo.View = LV_THUMBS then
  begin
    SynchronizeEx(ReplaceInfoInExplorer);
    Exit;
  end;

  //Create image from Info!!!
  if ExplorerInfo.View = LV_THUMBS then
  begin
    if ProcessorCount > 1 then
      TExplorerThreadPool.Instance.ExtractImage(Self, FInfo, CryptedFile, FileID)
    else
      ExtractImage(FInfo, CryptedFile, FileID);
  end;
end;

procedure TExplorerThread.ReplaceImageInExplorer;
begin
  if not IsTerminated then
  begin
    FSender.SetInfoToItem(FInfo, GUIDParam, True);

    if (TempBitmap = nil) or TempBitmap.Empty or not FSender.ReplaceBitmap(TempBitmap, GUIDParam, FInfo.Include, IsBigImage) then
      F(TempBitmap);
  end else
    F(TempBitmap);

  TempBitmap := nil;
end;

procedure TExplorerThread.ReplaceInfoInExplorer;
begin
  if not IsTerminated then
    FSender.SetInfoToItem(FInfo, GUIDParam);
end;

procedure TExplorerThread.ReplaceThumbImageToFolder(CurrentFile: string; DirctoryID: TGUID);
var
  Found, Count, Dx, I, J, X, Y, W, H, Ps, Index: Integer;
  SearchRec: TSearchRec;
  Files: array [1 .. 4] of string;
  Bmp: TBitmap;
  FFolderImagesResult: TFolderImages;
  FFastDirectoryLoading, OK: Boolean;
  Query: TDataSet;
  RecNos: array [1 .. 4] of Integer;
  FilesInFolder: array [1 .. 4] of string;
  FilesDatesInFolder: array [1 .. 4] of TDateTime;
  CountFilesInFolder: Integer;
  FFileNames, FPrivateFileNames: TStringList;
  DBFolder, Password, SelectQty: string;
  RecCount, SmallImageSize, Deltax, Deltay, _x, _y: Integer;
  Fbs: TStream;
  FJpeg: TJpegImage;
  Nbr: Integer;
  C: Integer;
  FE, EM: Boolean;
  S: string;
  P: Integer;
  Crc: Cardinal;

  Info: TDBPopupMenuInfoRecord;
  Graphic: TGraphic;
  ImageInfo: ILoadImageInfo;

  function FileInFiles(FileName: String) : Boolean;
  begin
    Result := FFileNames.IndexOf(AnsiLowerCase(FileName)) > -1;
  end;

  function FileInPrivateFiles(FileName : string): Boolean;
  begin
    Result := FPrivateFileNames.IndexOf(AnsiLowerCase(FileName)) > -1;
  end;

  procedure AddFileInFolder(FileName: string);
  begin
    Inc(CountFilesInFolder);
    if CountFilesInFolder < 5 then
    begin
      FilesInFolder[CountFilesInFolder] := FileName;
      FilesDatesInFolder[CountFilesInFolder] := GetFileDateTime(FileName);
    end;
  end;

begin
  Ps := ExplorerInfo.PictureSize;
  _y := Round((564-68)*ps/1200);
  SmallImageSize := Round(_y/1.05);
  CountFilesInFolder := 0;
  for I := 1 to 4 do
    FilesInFolder[I] := '';

  CurrentFile := IncludeTrailingBackslash(CurrentFile);
  FFolderImages.Directory := CurrentFile;
  FFolderImagesResult.Directory := '';
  if FThreadType <> THREAD_TYPE_FOLDER_UPDATE then
    FFolderImagesResult := ExplorerFolders.GetFolderImages(CurrentFile, SmallImageSize, SmallImageSize);
  FFastDirectoryLoading := False;
  if FFolderImagesResult.Directory <> '' then
    FFastDirectoryLoading := True
  else
  begin
    for I := 1 to 4 do
      FFolderImages.Images[I] := nil;
  end;

  TempBitmap := nil;
  try
    Query := nil;
    try
      Count := 0;
      Nbr := 0;
      FFileNames := TStringList.Create;
      FPrivateFileNames := TStringList.Create;
      try
        if not FFastDirectoryLoading then
        begin
          DBFolder := ExcludeTrailingBackslash(AnsiLowerCase(CurrentFile));
          CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);
          DBFolder := IncludeTrailingBackslash(DBFolder);

          Query := GetQuery(True);
          ReadOnlyQuery(Query);

          if TPrivateHelper.Instance.IsPrivateDirectory(DBFolder) then
            SelectQty := ''
          else
            SelectQty := 'TOP 4';

          if ExplorerInfo.ShowPrivate then
            SetSQL(Query,'Select ' + SelectQty + ' FFileName, Access, thum, Rotated From $DB$ where FolderCRC = ' + IntToStr(Integer(crc)) + ' and (FFileName Like :FolderA) and not (FFileName like :FolderB) ')
          else
            SetSQL(Query,'Select ' + SelectQty + ' FFileName, Access, thum, Rotated From $DB$ where FolderCRC = ' + IntToStr(Integer(crc)) + ' and (FFileName Like :FolderA) and not (FFileName like :FolderB) and Access <> ' + IntToStr(db_access_private));

          SetStrParam(Query, 0, '%' + NormalizeDBStringLike(DBFolder) + '%');
          SetStrParam(Query, 1, '%' + NormalizeDBStringLike(DBFolder) + '%\%');

          Query.Active := True;

          for I := 1 to 4 do
            RecNos[I] := 0;

          if not Query.IsEmpty then
          begin
            Query.First;
            for I := 1 to Query.RecordCount do
            begin
              if Query.FieldByName('Access').AsInteger = db_access_private then
                FPrivateFileNames.Add(AnsiLowerCase(Query.FieldByName('FFileName').AsString));

              if (Query.FieldByName('Access').AsInteger <> db_access_private) or ExplorerInfo.ShowPrivate then
                if FileExistsSafe(Query.FieldByName('FFileName').AsString) then
                  if ShowFileIfHidden(Query.FieldByName('FFileName').AsString) then
                  begin
                    OK := True;
                    if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
                    if DBkernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'))='' then
                      OK := False;
                    if OK then
                    begin
                      if Nbr < 4 then
                      begin
                        Inc(Nbr);
                        RecNos[Nbr] := Query.RecNo;
                        FilesInFolder[Nbr] := Query.FieldByName('FFileName').AsString;
                        FFileNames.Add(AnsiLowerCase(Query.FieldByName('FFileName').AsString));
                        AddFileInFolder(Query.FieldByName('FFileName').AsString);
                      end;
                    end;
                  end;
              Query.Next;
            end;
          end;
          if Nbr < 4 then
          begin
            Found := FindFirst(CurrentFile + '*.*', faAnyFile, SearchRec);
            while Found = 0 do
            begin
              if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
              begin
                FE := (SearchRec.Attr and faDirectory = 0);
                S := ExtractFileExt(SearchRec.Name);
                S := '|' + AnsiLowerCase(s) + '|';
                p := Pos(s, SupportedExt);
                EM := p <> 0;

                if FE and EM and not FileInFiles(CurrentFile + SearchRec.Name) and not (FileInPrivateFiles(CurrentFile + SearchRec.Name) and not ExplorerInfo.ShowPrivate) then
                if ShowFileIfHidden(CurrentFile + SearchRec.Name) then
                begin
                  OK := True;
                  if ValidCryptGraphicFile(CurrentFile + SearchRec.Name) then
                    if DBKernel.FindPasswordForCryptImageFile(CurrentFile + SearchRec.Name) = '' then
                      OK := False;
                    if OK then
                    begin
                      Inc(Count);
                      Files[Count] := CurrentFile + SearchRec.Name;
                      AddFileInFolder(CurrentFile + SearchRec.Name);
                      FilesInFolder[Count+Nbr] := CurrentFile + SearchRec.Name;
                      if Count + Nbr >= 4 then
                        Break;
                    end;
                end;
              end;
              Found := System.SysUtils.FindNext(SearchRec);
            end;
            System.SysUtils.FindClose(SearchRec);
          end;
          if Count + Nbr = 0 then
          begin
            if FThreadType = THREAD_TYPE_FOLDER_UPDATE then
            begin
              MakeFolderImage(CurrentFile);
              if not SynchronizeEx(AddImageFileImageToExplorer) then
                F(FIcon)
              else
                FIcon := nil;
            end;
            Exit;
          end;
        end;
      finally
        F(FFileNames);
        F(FPrivateFileNames);
      end;

      Dx := 4;

      TempBitmap := TBitmap.Create;
      DrawFolderImageBig(TempBitmap);

      C := 0;

      for I := 1 to 2 do
      for J := 1 to 2 do
      begin
        if IsTerminated then
          Exit;
        Index := (I - 1) * 2 + J;
        FcountOfFolderImage := Index;
        // 34  68
        // 562 564
        // 600 600
        deltax := Round(34 * ps/600);
        deltay := Round(68 * ps/600);
        _x := Round((562-34) * ps/1200);
        _y := Round((564-68) * ps/1200);
        SmallImageSize := Round(_y/1.05);

        X := (J - 1) * _x + deltax;
        Y := (I - 1) * _y + deltay;
        if FFastDirectoryLoading then
        begin
          if FFolderImagesResult.Images[Index] = nil then
            Break;
          FBmp := FFolderImagesResult.Images[Index];
          W := FBmp.Width;
          H := FBmp.Height;
          ProportionalSize(SmallImageSize, SmallImageSize, W, H);
          DrawFolderImageWithXY(TempBitmap, Rect(_x div 2 - w div 2 + x, _y div 2 - h div 2 + y, _x div 2- w div 2 + x + w, _y div 2 - h div 2 + y + h), fbmp);
          Continue;
        end;
        if Index > Count + Nbr then
          Break;
        if index > Count then
        begin
          Inc(c);
          Query.RecNo := RecNos[c];
          if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
          begin
            Password := DBKernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'));
            if Password <> '' then
            begin
              FJPEG := TJpegImage.Create;
              DeCryptBlobStreamJPG(Query.FieldByName('thum'), Password, FJPEG);
            end else
              Continue;
          end else
          begin
            FJPEG := TJpegImage.Create;
            FBS:= GetBlobStream(Query.FieldByName('thum'), bmRead);
            try
              FJPEG.LoadFromStream(FBS);
            finally
              F(FBS);
            end;
          end;
          Fbmp := TBitmap.Create;
          try
            JPEGScale(FJpeg, SmallImageSize, SmallImageSize);
            AssignJpeg(FBmp, FJpeg);
            F(FJpeg);
            ApplyRotate(FBmp, Query.FieldByName('Rotated').AsInteger);

            W := FBmp.Width;
            H := FBmp.Height;
            ProportionalSize(SmallImageSize, SmallImageSize, W, H);
            DrawFolderImageWithXY(TempBitmap, Rect(_x div 2 - W div 2 + X,_y div 2 - H div 2 + y, _x div 2- W div 2 + X + W, _y div 2 - H div 2 + Y + H), FBmp);
          finally
            F(Fbmp);
          end;
        end else
        begin

          Info := TDBPopupMenuInfoRecord.CreateFromFile(Files[Index]);
          try

            Graphic := nil;
            try
              if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword], ImageInfo, SmallImageSize, SmallImageSize) then
              begin
                Graphic := ImageInfo.ExtractGraphic;

                if Graphic <> nil then
                begin
                  _y := Round((564 - 68) * ps / 1200);
                  SmallImageSize := Round(_y / 1.05);
                  JPEGScale(Graphic, SmallImageSize, SmallImageSize);

                  FBmp := TBitmap.Create;
                  try
                    Bmp := TBitmap.Create;
                    try
                      AssignGraphic(BMP, Graphic);
                      F(Graphic);

                      FBMP.PixelFormat := BMP.PixelFormat;
                      ApplyRotate(BMP, Info.Rotation);
                      W := BMP.Width;
                      H := BMP.Height;
                      ProportionalSize(SmallImageSize, SmallImageSize, W, H);

                      DoResize(W, H, BMP, FBMP);
                      ImageInfo.AppllyICCProfile(FBMP);
                      DrawFolderImageWithXY(TempBitmap, Rect(_x div 2 - w div 2 + x, _y div 2 - h div 2 + y, _x div 2- w div 2 + x + w, _y div 2 - h div 2 + y + h), FBMP);
                    finally
                      F(BMP);
                    end;
                  finally
                    F(FBMP);
                  end;

                end else
                  Continue;
              end;
            finally
              F(Graphic);
            end;
          finally
            F(Info);
          end;
        end;
      end;
    finally
      FreeDS(Query);
    end;

    if not FFastDirectoryLoading and ExplorerInfo.SaveThumbNailsForFolders then
    begin
      for I := 1 to 4 do
        FFolderImages.FileNames[I] := FilesInFolder[I];
      for I := 1 to 4 do
        FFolderImages.FileDates[I] := FilesDatesInFolder[I];
      ExplorerFolders.SaveFolderImages(FFolderImages, SmallImageSize, SmallImageSize);
    end;

    GUIDParam := DirctoryID;
    if not SynchronizeEx(ReplaceFolderImage) then
      F(TempBitmap)
    else
      TempBitmap := nil;

  finally
    F(TempBitmap);

    for I := 1 to 4 do
      F(FFolderImages.Images[I]);

    for I := 1 to 4 do
      F(FFolderImagesResult.Images[I]);
  end;
end;

procedure TExplorerThread.DrawFolderImageBig(Bitmap: TBitmap);
var
  Bit32: TBitmap;
begin
  if not IsTerminated then
  begin
    FFolderPictureLock.Enter;
    try
      if FullFolderPicture = nil then
        FullFolderPicture := GetFolderPicture;
    finally
      FFolderPictureLock.Leave;
    end;

    if FullFolderPicture = nil then
      Exit;

   Bit32 := TBitmap.Create;
   try
     FFolderPictureLock.Enter;
     try
       LoadPNGImageTransparent(FullFolderPicture, Bit32);
     finally
       FFolderPictureLock.Leave;
     end;
     StretchCoolW32(0, 0, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize, Rect(0, 0, Bit32.Width, Bit32.Height), Bit32, Bitmap, 1);
   finally
     F(Bit32);
    end;
  end;
end;

procedure TExplorerThread.DrawFolderImageWithXY(Bitmap : TBitmap; FolderImageRect : TRect; Source : TBitmap);
begin
  if not FFastDirectoryLoading then
  if ExplorerInfo.SaveThumbNailsForFolders then
  begin
    FFolderImages.Images[FcountOfFolderImage] := TBitmap.create;
    AssignBitmap(FFolderImages.Images[FcountOfFolderImage], FBmp);
  end;
  if Source.PixelFormat = pf32Bit then
    StretchCoolW32(FolderImageRect.Left, FolderImageRect.Top, FolderImageRect.Right - FolderImageRect.Left, FolderImageRect.Bottom - FolderImageRect.Top, Rect(0,0, Source.Width, Source.Height), Source, Bitmap)
  else
    StretchCoolW24To32(FolderImageRect.Left, FolderImageRect.Top, FolderImageRect.Right - FolderImageRect.Left, FolderImageRect.Bottom - FolderImageRect.Top, Rect(0,0, Source.Width, Source.Height), Source, Bitmap);
end;

procedure TExplorerThread.ReplaceFolderImage;
begin
  if not FSender.ReplaceBitmap(TempBitmap, GUIDParam, True) then
    F(TempBitmap)
  else
    TempBitmap := nil;
end;

procedure TExplorerThread.AddFile;
var
  Ext_: string;
  IsExt_: Boolean;
  FE: Boolean;
begin
  FE := FileExistsSafe(FUpdaterInfo.FileName);

  if FolderView then
    if AnsiLowerCase(ExtractFileExt(FUpdaterInfo.FileName)) = '.ldb' then
      Exit;

  F(FFiles);
  FFiles := TExplorerFileInfos.Create;
  try
    Ext_ := ExtractFileExt(FUpdaterInfo.FileName);
    IsExt_ := ExtInMask(SupportedExt, Ext_);
    if DirectoryExists(FUpdaterInfo.FileName) then
      AddOneExplorerFileInfo(FFiles, FUpdaterInfo.FileName, EXPLORER_ITEM_FOLDER, -1, GetGUID, 0, 0, 0, 0,
        GetFileSizeByName(FUpdaterInfo.FileName), '', '', '', 0, False, False, True);
    if FE and IsExt_ then
      AddOneExplorerFileInfo(FFiles, FUpdaterInfo.FileName, EXPLORER_ITEM_IMAGE, -1, GetGUID, 0, 0, 0, 0,
        GetFileSizeByName(FUpdaterInfo.FileName), '', '', '', 0, False, ValidCryptGraphicFile(FUpdaterInfo.FileName),
        True);
    if FShowFiles then
      if FE and not IsExt_ then
        AddOneExplorerFileInfo(FFiles, FUpdaterInfo.FileName, EXPLORER_ITEM_FILE, -1, GetGUID, 0, 0, 0, 0,
          GetFileSizeByName(FUpdaterInfo.FileName), '', '', '', 0, False, False, True);
    if FFiles.Count = 0 then
      Exit;
    if FFiles[0].FileType = EXPLORER_ITEM_IMAGE then
    begin
      GUIDParam := FFiles[0].SID;
      CurrentFile := FFiles[0].FileName;
      FFiles[0].FileSize := GetFileSize(FFiles[0].FileName);
      AddImageFileToExplorerW;
      if ExplorerInfo.ShowThumbNailsForImages then
        ReplaceImageItemImage(CurrentFile, FFiles[0].FileSize, GUIDParam);
    end;
    if FFiles[0].FileType = EXPLORER_ITEM_FILE then
    begin
      GUIDParam := FFiles[0].SID;
      CurrentFile := FFiles[0].FileName;
      AddImageFileToExplorerW;
    end;
    if FFiles[0].FileType = EXPLORER_ITEM_FOLDER then
    begin
      GUIDParam := FFiles[0].SID;
      CurrentFile := FFiles[0].FileName;
      AddImageFileToExplorerW;
      Sleep(2000); // wait if folder was jast created - it possible that files are currentry in copy-progress...
      if ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View = LV_THUMBS) then
        ExtractDirectoryPreview(CurrentFile, GUIDParam);
    end;
  finally
    F(FFiles);
  end;
end;

procedure TExplorerThread.AddImageFileToExplorerW;
begin
  F(TempBitmap);
  FIcon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);
  if not SynchronizeEx(AddImageFileItemToExplorerW) then
    F(FIcon)
  else
    FIcon := nil;
end;

procedure TExplorerThread.AddImageFileItemToExplorerW;
begin
  if not IsTerminated then
  begin
    FSender.AddInfoAboutFile(FFiles);
    if not FSender.AddIcon(FIcon, True, GUIDParam) then
      F(FIcon)
    else
      FIcon := nil;

    if FUpdaterInfo.NewFileItem then
      FSender.SetNewFileNameGUID(GUIDParam);
    FSender.AddItem(GUIDParam, False);
  end else
    F(FIcon);
end;

procedure TExplorerThread.MakeFolderImage(Folder: String);
begin
  FIcon := TAIcons.Instance.GetIconByExt(Folder, True, FIcoSize, False);
end;

procedure TExplorerThread.MakeTempBitmap;
begin
  TempBitmap := TBitmap.Create;
  TempBitmap.PixelFormat := pf24Bit;
  TempBitmap.SetSize(ExplorerInfo.PictureSize, ExplorerInfo.PictureSize);
end;

function TExplorerThread.IsImage(SearchRec: TSearchRec): Boolean;
var
  S: string;
  P: Integer;
begin
  Result := False;
  if ExplorerInfo.ShowImageFiles or ExplorerInfo.ShowSimpleFiles then
  begin
    S := ExtractFileExt(SearchRec.name);
    S := '|' + AnsiLowerCase(S) + '|';
    P := Pos(S, SupportedExt);
    Result := P <> 0;
  end;
end;

function TExplorerThread.ProcessSearchRecord(FFiles: TExplorerFileInfos; Directory: string; SearchRec: TSearchRec): Boolean;
var
  FE, EM: Boolean;
  FA: Integer;
begin
  Result := False;
  if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
  begin
    FA := SearchRec.Attr and FaHidden;
    if ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (FA = 0)) then
    begin
      FE := (SearchRec.Attr and FaDirectory = 0);
      EM := IsImage(SearchRec);
      if FShowFiles then
        if ExplorerInfo.ShowSimpleFiles then
          if FE and not EM and ExplorerInfo.ShowSimpleFiles then
          begin
            if FolderView then
              if AnsiLowerCase(ExtractFileExt(SearchRec.Name)) = '.ldb' then
                Exit;

            Result := True;
            AddOneExplorerFileInfo(FFiles, Directory + SearchRec.name, EXPLORER_ITEM_FILE, -1, GetGUID, 0, 0,
              0, 0, SearchRec.Size, '', '', '', 0, False, False, True);
            Exit;
          end;
      if ExplorerInfo.ShowImageFiles then
        if FE and EM and ExplorerInfo.ShowImageFiles then
        begin
          Result := True;
          AddOneExplorerFileInfo(FFiles, Directory + SearchRec.name, EXPLORER_ITEM_IMAGE, -1, GetGUID, 0, 0,
            0, 0, SearchRec.Size, '', '', '', 0, False, False, True);
          Exit;
        end;
      if (SearchRec.Attr and FaDirectory <> 0) and ExplorerInfo.ShowFolders then
      begin
        Result := True;
        AddOneExplorerFileInfo(FFiles, Directory + SearchRec.name, EXPLORER_ITEM_FOLDER, -1, GetGUID, 0, 0,
          0, 0, 0, '', '', '', 0, False, False, True);
        Exit;
      end;
    end;
  end;
end;

function TExplorerThread.FindInQuery(FileName: String) : Boolean;
var
  I: Integer;
  AddPathStr: string;
begin
  Result := False;
  if (not FQuery.IsEmpty) then
  begin
    UnProcessPath(FileName);
    FileName := AnsiLowerCase(FileName);
    if FolderView then
      AddPathStr := ProgramDir
    else
      AddPathStr := '';
    Fquery.First;
    for I := 1 to Fquery.RecordCount do
    begin
      if AnsiLowerCase(AddPathStr + FQuery.FieldByName('FFileName').AsString) = FileName then
      begin
        Result := True;
        Exit;
      end;
      FQuery.Next;
    end;
  end;
end;

procedure TExplorerThread.ShowInfo(StatusText: String);
begin
  SetText := True;
  SetMax := False;
  SetPos := False;
  FInfoText := StatusText;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(Max, Value: Integer);
begin
  SetText := False;
  SetMax := True;
  SetPos := True;
  FInfoMax := Max;
  FInfoPosition := Value;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(StatusText: String; Max,
  Value: Integer);
begin
  SetText := True;
  SetMax := True;
  SetPos := True;
  FInfoText := StatusText;
  FInfoMax := Max;
  FInfoPosition := Value;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(Pos: Integer);
begin
  SetText := False;
  SetMax := False;
  SetPos := True;
  FInfoPosition := Pos;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowLoadingSign;
begin
  FSender.ShowLoadingSign;
end;

procedure TExplorerThread.SetInfoToStatusBar;
begin
  if not IsTerminated then
  begin
    if SetText then
      FSender.SetStatusText(FInfoText);
    if Setmax then
      FSender.SetProgressMax(FInfoMax);
    if SetPos Then
      FSender.SetProgressPosition(FInfoPosition);
  end;
end;

procedure TExplorerThread.HideLoadingSign;
begin
  FSender.HideLoadingSign;
end;

procedure TExplorerThread.ShowIndeterminateProgress;
begin
  FSender.ShowIndeterminateProgress;
end;

procedure TExplorerThread.HideProgress;
begin
  ProgressVisible := False;
  SynchronizeEx(SetProgressVisible);
end;

procedure TExplorerThread.SetProgressVisible;
begin
  if ProgressVisible then
    FSender.ShowProgress
  else
    FSender.HideProgress;
end;

procedure TExplorerThread.ShowProgress;
begin
  ProgressVisible := True;
  SynchronizeEx(SetProgressVisible);
end;

procedure TExplorerThread.PathProviderCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var ABreak: Boolean);
var
  I: Integer;
  CI: TPathItem;
  Icon: TIcon;
  Info: TExplorerFileInfo;
begin
  F(FFiles);
  TW.I.Start('Packet - start');
  FFiles := TExplorerFileInfos.Create;
  try
    FPacketImages := TBitmapImageList.Create;
    FPacketInfos := TExplorerFileInfos.Create;
    try
      for I := 0 to CurrentItems.Count - 1 do
      begin
        if Terminated then
          Break;
        CI := CurrentItems[I];
        TW.I.Start('Packet - CreateFromPathItem');
        Info := TExplorerFileInfo.CreateFromPathItem(CI);
        FFiles.Add(Info);
        FPacketInfos.Add(Info);

        TW.I.Start('Packet - before image');
        if CI.Image <> nil then
        begin
          if CI.Image.HIcon <> 0 then
          begin
            Icon := TIcon.Create;
            Icon.Handle := CI.Image.HIcon;
            FPacketImages.AddIcon(Icon, True);
            CI.Image.DetachImage;
          end else if CI.Image.Icon <> nil then
          begin
            FPacketImages.AddIcon(CI.Image.Icon, True);
            CI.Image.DetachImage;
          end else if CI.Image.Bitmap <> nil then
          begin
            FPacketImages.AddBitmap(CI.Image.Bitmap, True);
            CI.Image.DetachImage;
          end else
            raise Exception.Create('Image is empty!');
        end else
          raise Exception.Create('Image is null!');
      end;
      TW.I.Start('Packet - send');
      ABreak := not SynchronizeEx(SendPacketToExplorer);
      TW.I.Start('Packet - after send');
    finally
      F(FPacketImages);
      FPacketInfos.ClearList;
      F(FPacketInfos);
    end;
  finally
    F(FFiles);
  end;
  CurrentItems.FreeItems;
  TW.I.Start('Packet - end');

  if Terminated then
    ABreak := True;
end;

function TExplorerThread.LoadProviderItem(Item: TPathItem; PacketSize, ImageSize: Integer): Boolean;
var
  List: TPathItemCollection;
  Flags: Integer;
begin
  List := TPathItemCollection.Create;
  try
    Flags := PATH_LOAD_NORMAL;
    if ExplorerInfo.View <> LV_THUMBS then
    begin
      Flags := Flags or PATH_LOAD_FOR_IMAGE_LIST;
      ImageSize := FIcoSize;
    end;
    Result := Item.Provider.FillChildList(Self, Item, List, Flags, ImageSize, PacketSize, PathProviderCallBack);
    List.FreeItems;
  finally
    F(List);
  end;
end;

function TExplorerThread.LoadProviderItemEx(Item: TPathItem; PacketSize,
  ImageSize: Integer; Text: string): Boolean;
begin
  Result := False;
  HideProgress;
  ShowInfo(Text, 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    try
      Result := LoadProviderItem(Item, PacketSize, ImageSize);
    except
      on e: Exception do
        EventLog(e);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadMyComputerFolder;
var
  HomeItem: THomeItem;
begin
  HomeItem := THomeItem.Create;
  try
    LoadProviderItemEx(HomeItem, 1, FIcoSize, L('Loading "My computer" directory') + '...');
  finally
    F(HomeItem);
  end;
end;

procedure TExplorerThread.LoadNetWorkFolder;
var
  NetworkItem: TNetworkItem;
begin
  NetworkItem := TNetworkItem.CreateFromPath(cNetworkPath, PATH_LOAD_NO_IMAGE, 0);
  try
    LoadProviderItemEx(NetworkItem, 5, FIcoSize, L('Scanning network') + '...');
  finally
    F(NetworkItem);
  end;
end;

procedure TExplorerThread.LoadPathItem;
var
  PI: TPathItem;
  YI: TDateStackYearItem;
  MI: TDateStackMonthItem;
  DI: TDateStackDayItem;
  D: TDateTime;

  function GetGroupName(PI: TPathItem): string;
  begin
    Result := '';
    while PI <> nil do
    begin
      if PI is TGroupItem then
        Exit(TGroupItem(PI).GroupName);
      PI := PI.Parent;
    end;
  end;

  function GetSearchTerm(PI: TPathItem): string;
  begin
    Result := '';
    while PI <> nil do
    begin
      if PI is TPersonItem then
        Exit(':Person(' + TPersonItem(PI).PersonName + '):');
      PI := PI.Parent;
    end;
  end;

begin
  PI := PathProviderManager.CreatePathItem(ExcludeTrailingPathDelimiter(FFolder));
  try
    if PI <> nil then
    begin
      if PI is TDateStackItem then
        LoadProviderItemEx(PI, 1, FIcoSize, L('Loading calendar') + '...');

      FMask := GetSearchTerm(PI);
      if PI is TDateStackYearItem then
      begin
        LoadProviderItem(PI, 1, FIcoSize);
        YI := TDateStackYearItem(PI);
        SearchDB(EncodeDate(YI.Year, 1, 1), EncodeDate(YI.Year, 12, 31), GetGroupName(PI));
      end;
      if PI is TDateStackMonthItem then
      begin
        LoadProviderItem(PI, 1, FIcoSize);
        MI := TDateStackMonthItem(PI);
        D := EncodeDate(MI.Year, MI.Month, 1);

        SearchDB(D, IncDay(IncMonth(D, 1), -1), GetGroupName(PI));
      end;
      if PI is TDateStackDayItem then
      begin
        DI := TDateStackDayItem(PI);
        D := EncodeDate(DI.Year, DI.Month, DI.Day);

        SearchDB(D, D, GetGroupName(PI));
      end;
    end;
  finally
    F(PI);
  end;
end;

procedure TExplorerThread.LoadPersons;
var
  PersonsItem: TPathItem;
begin
  HideProgress;
  ShowInfo(L('Loading persons'), 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    PersonsItem := PathProviderManager.CreatePathItem(cPersonsPath);
    try
      try
        LoadProviderItem(PersonsItem, 10, ExplorerInfo.PictureSize);
      except
        on e: Exception do
          EventLog(e);
      end;
      SynchronizeEx(
        procedure
        begin
          if FSender.ItemsCount = 0 then
            FSender.ShowHelp(FSender.L('Learn more about creating and using persons'), SITE_ACTION_PERSONS);
        end
      );
    finally
      F(PersonsItem);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadDeviceItems;
var
  DeviceItem: TPathItem;
begin
  HideProgress;
  ShowInfo(L('Loading camera images'), 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    DeviceItem := PathProviderManager.CreatePathItem(FFolder);
    try
      if DeviceItem <> nil then
        LoadProviderItem(DeviceItem, 5, ExplorerInfo.PictureSize);
    finally
      F(DeviceItem);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadGroups;
var
  GroupsItem: TPathItem;
begin
  HideProgress;
  ShowInfo(L('Loading groups'), 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    GroupsItem := PathProviderManager.CreatePathItem(cGroupsPath);
    try
      LoadProviderItem(GroupsItem, 10, ExplorerInfo.PictureSize);
    finally
      F(GroupsItem);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadWorkgroupFolder;
var
  WorkgroupItem: TPathItem;
begin
  HideProgress;
  ShowInfo(L('Scanning workgroup'), 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    WorkgroupItem := TWorkgroupItem.CreateFromPath(FFolder, PATH_LOAD_NORMAL, 0);
    try
      if not LoadProviderItem(WorkgroupItem, 5, FIcoSize) then
      begin
        StrParam := Format(L('Error opening network "%s"!'), [FFolder]);
        SynchronizeEx(ShowMessage_);
        SynchronizeEx(ExplorerBack);
        Exit;
      end;
    finally
      F(WorkgroupItem);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadComputerFolder;
var
  ComputerItem: TPathItem;
begin
  HideProgress;
  ShowInfo(L('Opening computer'), 1, 0);
  SynchronizeEx(BeginUpdate);
  try
    ComputerItem := TComputerItem.CreateFromPath(FFolder, PATH_LOAD_NORMAL, 0);
    try
      if not LoadProviderItem(ComputerItem, 10, FIcoSize) then
      begin
        StrParam := Format(L('Error opening computer "%s"!'), [FFolder]);
        SynchronizeEx(ShowMessage_);
        SynchronizeEx(ExplorerBack);
        Exit;
      end;
    finally
      F(ComputerItem);
    end;
  finally
    EndUpdate;
  end;
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.ShowMessage_;
begin
  MessageBoxDB(FSender.Handle, StrParam, L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TExplorerThread.ExplorerBack;
begin
  FSender.DoBack;
end;

procedure TExplorerThread.UpdateFile;
var
  NewInfo: TExplorerFileInfo;
begin
  try
    if FUpdaterInfo.UpdateDB and (FUpdaterInfo.ID > 0) then
      UpdateImageRecord(FSender, FUpdaterInfo.FileName, FUpdaterInfo.ID);

    FQuery := GetQuery;
    try
      ReadOnlyQuery(FQuery);
      UnProcessPath(FFolder);

      SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = :FolderCRC AND Name = :Name');

      SetIntParam(FQuery, 0, GetPathCRC(FUpdaterInfo.FileName, True));
      SetStrParam(FQuery, 1, AnsiLowercase(ExtractFileName(FUpdaterInfo.FileName)));
      try
        FQuery.Active := True;
      except
        on e: Exception do
          EventLog(e.Message);
      end;
      F(FFiles);
      FFiles := TExplorerFileInfos.Create;
      try
        if FQuery.RecordCount > 0 then
        begin
          NewInfo := TExplorerFileInfo.CreateFromDS(FQuery);
          NewInfo.SID := FUpdaterInfo.SID;
        end else
        begin
          NewInfo := TExplorerFileInfo.CreateFromFile(FUpdaterInfo.FileName);
          NewInfo.FileSize := GetFileSizeByName(FUpdaterInfo.FileName);
          NewInfo.Encrypted := ValidCryptGraphicFile(FUpdaterInfo.FileName);
          NewInfo.SID := FUpdaterInfo.SID;
        end;
        FFiles.Add(NewInfo);

        GUIDParam := FFiles[0].SID;
        if FolderView then
          CurrentFile := ProgramDir + FFiles[0].FileName
        else
          CurrentFile := FFiles[0].FileName;

        if ExplorerInfo.ShowThumbNailsForImages then
          ReplaceImageItemImage(FFiles[0].FileName, FFiles[0].FileSize, GUIDParam);

        StrParam := FUpdaterInfo.FileName;
        SynchronizeEx(EndUpdateID);

        if ExplorerInfo.ShowThumbNailsForImages and not FUpdaterInfo.DisableLoadingOfBigImage then
        begin
          FFiles[0].FileType := EXPLORER_ITEM_IMAGE;
          DoLoadBigImages(False);
        end;

      finally
        F(FFiles);
      end;
    finally
      FreeDS(FQuery);
    end;
    if FInfo.ID <> 0 then
      if Assigned(FUpdaterInfo.ProcHelpAfterUpdate) then
        SynchronizeEx(DoUpdaterHelpProc);
  except
    on e: Exception do
      EventLog(e);
  end;
end;

function TExplorerThread.ShowFileIfHidden(FileName: string): Boolean;
var
  Fa: Integer;
begin
  Result := False;
  Fa := FileGetAttr(FileName);
  Fa := Fa and FaHidden;
  if ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (Fa = 0)) then
    Result := True;
end;

procedure TExplorerThread.ReplaceImageInExplorerB;
begin
  if TempBitmap <> nil then
  begin
    if not FSender.ReplaceBitmap(TempBitmap, GUIDParam, True, BooleanParam) then
      F(TempBitmap)
    else
      TempBitmap := nil;
  end else
    if not FSender.ReplaceIcon(FIcon, GUIDParam, True) then
      F(FIcon)
    else
      FIcon := nil;
end;

procedure TExplorerThread.MakeIconForFile;
begin
  TempBitmap := nil;
  if not IsVideoFile(CurrentFile) then
  begin
    FIcon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);
    if not SynchronizeEx(ReplaceImageInExplorerB) then
      F(FIcon)
    else
      FIcon := nil;
  end else
  begin
    TempBitmap := TBitmap.Create;
    if ExtractVideoThumbnail(CurrentFile, ExplorerInfo.PictureSize, TempBitmap) then
    begin
      if not SynchronizeEx(ReplaceImageInExplorerB) then
        F(TempBitmap)
      else
        TempBitmap := nil;
    end else
      F(TempBitmap);
  end;
end;

procedure TExplorerThread.CheckIsFileEncrypted;
var
  IsEncrypted: Boolean;
begin
  if CanBeTransparentEncryptedFile(CurrentFile) then
  begin
    IsEncrypted := ValidEnryptFileEx(CurrentFile);
    SynchronizeEx(
      procedure
      begin
        FSender.SetFileIsEncrypted(GUIDParam, IsEncrypted);
      end
    );
  end;
end;

procedure TExplorerThread.UpdateSimpleFile;
begin
  StringParam := Fmask;
  CurrentFile := FFolder;
  GUIDParam := FUpdaterInfo.SID;
  MakeIconForFile;
  CheckIsFileEncrypted;
end;

procedure TExplorerThread.DoUpdaterHelpProc;
begin
  if Assigned(FUpdaterInfo.ProcHelpAfterUpdate) then
    FUpdaterInfo.ProcHelpAfterUpdate(self);
end;

procedure TExplorerThread.AddDirectoryIconToExplorer;
begin
  if not IsTerminated then
    FSender.AddIcon(FIcon, true, GUIDParam);
end;

procedure TExplorerThread.UpdateFolder;
begin
  F(FFiles);
  FFiles := TExplorerFileInfos.Create;

  AddOneExplorerFileInfo(FFiles, FFolder, EXPLORER_ITEM_FOLDER, -1, FUpdaterInfo.SID, 0, 0, 0, 0, 0, '', '', '', 0,
    False, False, True);
  GUIDParam := FFiles[0].SID;
  CurrentFile := FFiles[0].FileName;
  FMask := SupportedExt;
  if ExplorerInfo.ShowThumbNailsForFolders then
    ReplaceThumbImageToFolder(CurrentFile, GUIDParam);
end;

procedure TExplorerThread.EndUpdateID;
begin
  if not IsTerminated then
    FSender.RemoveUpdateID(StrParam, FCID);
end;

procedure TExplorerThread.GetVisibleFiles;
begin
  FVisibleFiles := FSender.GetVisibleItems;
end;

procedure TExplorerThread.VisibleUp(TopIndex: Integer);
var
  I, C: Integer;
  J: Integer;
begin
  C := TopIndex;
  for I := 0 to FVisibleFiles.Count - 1 do
    for J := TopIndex to FFiles.Count - 1 do
      //if FFiles[J].Tag = 0 then
      begin
        if IsEqualGUID(StringToGUID(FVisibleFiles[I]), FFiles[J].SID) then
        begin
          FFiles.Exchange(C, J);
          inc(C);
          if c >= FFiles.Count then
            Exit;
        end;
      end;
end;

procedure TExplorerThread.DoLoadBigImages(LoadOnlyDBItems: Boolean);
var
  I, InfoPosition: Integer;
begin
  while ExplorerUpdateBigImageThreadsCount > ProcessorCount do
    Sleep(10);

  Inc(ExplorerUpdateBigImageThreadsCount);

  try
    if LoadingAllBigImages or LoadOnlyDBItems then
      if not SynchronizeEx(GetAllFiles) then
        Exit;

    if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
    begin
      ShowInfo(L('Loading previews'));
      ShowInfo(FFiles.Count, 0);
    end;
    InfoPosition := 0;

    for I := 0 to FFiles.Count - 1 do
    begin

      Inc(InfoPosition);
      if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
        ShowInfo(InfoPosition);
      if IsTerminated then Break;

      if I mod 5 = 0 then
      begin
       F(FVisibleFiles);
       if SynchronizeEx(GetVisibleFiles) then
         VisibleUp(I);
      end;

      GUIDParam := FFiles[I].SID;

      if FFiles[I].FileType = EXPLORER_ITEM_IMAGE then
      begin

        BooleanResult := False;
        //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
        if not LoadingAllBigImages then
          BooleanResult := True
        else
          SynchronizeEx(FileNeededAW);

        if IsTerminated then
          Break;

        if LoadOnlyDBItems then
          BooleanResult := FFiles[I].ID > 0;

        if BooleanResult then
        begin
          if ProcessorCount > 1 then
            TExplorerThreadPool.Instance.ExtractBigImage(Self, FFiles[I].FileName, FFiles[I].ID, FFiles[I].Rotation, GUIDParam)
          else
            ExtractBigPreview(FFiles[I].FileName, FFiles[I].ID, FFiles[I].Rotation, GUIDParam);
        end;
      end;

      //directories
      if (FFiles[I].FileType = EXPLORER_ITEM_FOLDER) and not LoadOnlyDBItems then
      begin
        BooleanResult := False;
        if not SynchronizeEx(FileNeededAW) then
          Exit;

        CurrentFile := FFiles[I].FileName;

        //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
        if not LoadingAllBigImages then
          BooleanResult := True;

        if IsTerminated then Break;

        if BooleanResult and ExplorerInfo.ShowThumbNailsForFolders then
          ExtractDirectoryPreview(CurrentFile, GUIDParam);
      end;
    end;
    if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
    begin
      SynchronizeEx(DoStopSearch);
      HideProgress;
      ShowInfo('');
    end;
  finally
    Dec(ExplorerUpdateBigImageThreadsCount);
  end;
end;

procedure TExplorerThread.ExtractBigPreview(FileName: string; ID: Integer; Rotated: Integer; FileGUID: TGUID);
var
  FBit: TBitmap;
  W, H: Integer;
  Info: TDBPopupMenuInfoRecord;
  Graphic: TGraphic;
  ImageInfo: ILoadImageInfo;
begin
  FileName := ProcessPath(FileName);
  GUIDParam := FileGUID;
  CurrentFile := FileName;

  if not FileExistsSafe(FileName) then
    Exit;

  Info := TDBPopupMenuInfoRecord.CreateFromFile(CurrentFile);
  try
    Info.ID := ID;
    Info.Rotation := Rotated;

    Graphic := nil;
    try
      if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword], ImageInfo, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize) then
      begin
        Graphic := ImageInfo.ExtractGraphic;

        if Graphic <> nil then
        begin
          FBit := TBitmap.Create;
          try
            FBit.PixelFormat := pf24bit;
            JPEGScale(Graphic, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize);

            if Min(Graphic.Height, Graphic.Width) > 1 then
              LoadImageX(Graphic, Fbit, Theme.ListViewColor);
            F(Graphic);
            TempBitmap := TBitmap.Create;
            TempBitmap.PixelFormat := pf24bit;
            W := FBit.Width;
            H := FBit.Height;
            ProportionalSize(ExplorerInfo.PictureSize, ExplorerInfo.PictureSize, W, H);
            TempBitmap.PixelFormat := FBit.PixelFormat;
            TempBitmap.SetSize(W, H);
            DoResize(W, H, FBit, TempBitmap);

            ImageInfo.AppllyICCProfile(TempBitmap);
          finally
            F(FBit);
          end;
          ApplyRotate(TempBitmap, Info.Rotation);
          BooleanParam := LoadingAllBigImages;

          if not SynchronizeEx(ReplaceImageInExplorerB) then
            F(TempBitmap)
          else
            TempBitmap := nil;
        end;
      end;
    finally
      F(Graphic);
    end;

  finally
    F(Info);
  end;
end;

procedure TExplorerThread.GetAllFiles;
begin
  if not IsTerminated then
  begin
    F(FFiles);
    FFiles := FSender.GetAllItems;
  end;
end;

function TExplorerThread.GetThreadID: string;
begin
  Result := 'Explorer';
end;

destructor TExplorerThread.Destroy;
begin
  F(FVisibleFiles);
  F(FFiles);
  F(FUpdaterInfo);
  F(FInfo);
  inherited;
end;

procedure TExplorerThread.DoDefaultSort;
begin
  if not IsTerminated then
    FSender.DoDefaultSort(FCID);
end;

procedure TExplorerThread.DoStopSearch;
begin
  FSender.DoStopLoading;
end;

procedure TExplorerThread.ExtractImage(Info: TDBPopupMenuInfoRecord; EncryptedFile: Boolean; FileID: TGUID);
var
  W, H: Integer;
  Graphic: TGraphic;
  TempBit: TBitmap;
  ImageInfo: ILoadImageInfo;
begin
  F(TempBitmap);

  if Info.ID = 0 then
  begin
    Graphic := nil;
    try
      if LoadImageFromPath(Info, -1, '', [ilfGraphic, ilfICCProfile, ilfEXIF, ilfPassword], ImageInfo, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize) then
      begin
        Graphic := ImageInfo.ExtractGraphic;
        Info.IsImageEncrypted := EncryptedFile and (Graphic <> nil) and not Graphic.Empty;
        IsBigImage := (Graphic <> nil) and not Graphic.Empty;

        ImageInfo.UpdateImageInfo(Info, False);

        if Graphic <> nil then
        begin
          Info.Width := Graphic.Width;
          Info.Height := Graphic.Height;
          TempBit := TBitmap.Create;
          try
            TempBit.PixelFormat := pf24bit;
            JPEGScale(Graphic, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize);
            LoadImageX(Graphic, TempBit, clWindow);
            F(Graphic);

            W := TempBit.Width;
            H := TempBit.Height;

            //Result picture
            TempBitmap := TBitmap.Create;
            TempBitmap.PixelFormat := pf24bit;
            if Max(W, H) < ThImageSize then
              AssignBitmap(TempBitmap, TempBit)
            else
            begin
              ProportionalSize(ExplorerInfo.PictureSize, ExplorerInfo.PictureSize, W, H);
              TempBitmap.PixelFormat := TempBit.PixelFormat;
              DoResize(W, H, TempBit, TempBitmap);
            end;
            ImageInfo.AppllyICCProfile(TempBitmap);
          finally
            F(TempBit);
          end;
        end;
      end;
    finally
      F(Graphic);
    end;
  end else //if ID <> 0
  begin
    if LoadImageFromPath(Info, -1, '', [ilfICCProfile, ilfEXIF, ilfPassword], ImageInfo) then
      ImageInfo.UpdateImageGeoInfo(Info);

    if not (not Info.IsImageEncrypted and Info.Encrypted) and not ((Info.Image = nil) or Info.Image.Empty) then
    begin
      TempBitmap := TBitmap.Create;
      AssignJpeg(TempBitmap, Info.Image);

      if ImageInfo <> nil then
        ImageInfo.AppllyICCProfile(TempBitmap);

    end else
      TempBitmap := nil;
      //image -> loaded icon
  end;
  F(Info.Image);

  if not (not Info.IsImageEncrypted and Info.Encrypted) and (TempBitmap <> nil) then
    ApplyRotate(TempBitmap, Info.Rotation);

  if (FThreadType = THREAD_TYPE_IMAGE) or (FOwnerThreadType = THREAD_TYPE_IMAGE) then
    IsBigImage := False; //сбрасываем флаг для того чтобы перезагрузилась картинка

  GUIDParam := FileID;

  if not SynchronizeEx(ReplaceImageInExplorer) then
    F(TempBitmap)
  else
    TempBitmap := nil;
end;

procedure TExplorerThread.DoMultiProcessorTask;
begin
  if Mode = THREAD_PREVIEW_MODE_IMAGE then
    ExtractImage(FInfo, IsCryptedFile, FFileID);

  if Mode = THREAD_PREVIEW_MODE_DIRECTORY then
    ReplaceThumbImageToFolder(FInfo.FileName, FFileID);

  if Mode = THREAD_PREVIEW_MODE_BIG_IMAGE then
    ExtractBigPreview(FInfo.FileName, FInfo.ID, FInfo.Rotation, FFileID);

  FUpdaterInfo.ClearInfo;
end;

procedure TExplorerThread.ExtractDirectoryPreview(FileName : string; DirectoryID: TGUID);
begin
  if ProcessorCount > 1 then
    TExplorerThreadPool.Instance.ExtractDirectoryPreview(Self, FileName, DirectoryID)
  else
    ReplaceThumbImageToFolder(FileName, DirectoryID);
end;

function TExplorerThread.IsVirtualTerminate: Boolean;
begin
  Result := (FThreadType = THREAD_TYPE_THREAD_PREVIEW) or FUpdaterInfo.IsUpdater;
end;

{ TExplorerUpdateManager }

procedure TExplorerUpdateManager.CleanUp(FOwner: TExplorerForm);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := FData.Count - 1 downto 0 do
      if TExplorerNotifyInfo(FData[I]).FOwner = FOwner then
      begin
        TObject(FData[I]).Free;
        FData.Delete(I);
      end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerUpdateManager.CleanUpState(StateID: TGUID);
var
  I: Integer;
begin
  FSync.Enter;
  try
    for I := FData.Count - 1 downto 0 do
      if TExplorerNotifyInfo(FData[I]).FState = StateID then
      begin
        TObject(FData[I]).Free;
        FData.Delete(I);
      end;
  finally
    FSync.Leave;
  end;
end;

constructor TExplorerUpdateManager.Create;
begin
  FSync := TCriticalSection.Create;
  FData := TList<TExplorerNotifyInfo>.Create;
  FExplorerThreads := TList.Create;
  FLastVisibleRequest := GetTickCount;
end;

function TExplorerUpdateManager.DeQueue(FOwner: TExplorerForm; FState: TGUID; Mode: Integer): TExplorerNotifyInfo;
var
  I, J, C: Integer;
  VisibleFiles: TStrings;
begin
  Result := nil;

  VisibleFiles := nil;

  if GetTickCount - FLastVisibleRequest > 1000 then
  begin
    FLastVisibleRequest := GetTickCount;
    try
      TThread.Synchronize(nil,
        procedure
        begin
          if GOM.IsObj(FOwner) then
          begin
            VisibleFiles := FOwner.GetVisibleItems;
          end;
        end
      );
      if VisibleFiles <> nil then
      begin
        FSync.Enter;
        try
          C := 0;

          for I := 0 to VisibleFiles.Count - 1 do
            for J := 0 to FData.Count - 1 do
              begin
                if VisibleFiles[I] = FData[J].FGUID then
                begin
                  FData.Exchange(C, J);
                  Inc(C);
                  if C >= FData.Count then
                    Exit;
                end;
              end;

        finally
          FSync.Leave;
        end;
      end;

    finally
      F(VisibleFiles);
    end;
  end;

  FSync.Enter;
  try
    for I := 0 to FData.Count - 1 do
      if TExplorerNotifyInfo(FData[I]).FMode = Mode then
      begin
        Result := FData[0];
        FData.Delete(0);
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

destructor TExplorerUpdateManager.Destroy;
begin
  F(FSync);
  FreeList(FData);
  FreeList(FExplorerThreads);
  inherited;
end;

procedure TExplorerUpdateManager.QueueNotify(Info: TExplorerNotifyInfo);
begin
  if Info = nil then
    Exit;
  FSync.Enter;
  try

    if GetThreadCount(Info.FOwner, Info.FMode) = 0 then
    begin

      if Info.FMode = UPDATE_MODE_ADD then
        TExplorerThread.Create('', TFileAssociations.Instance.ExtensionList, 0, Info.FExplorerViewInfo, Info.FOwner, Info.FUpdaterInfo.Copy, Info.FState)
      else if Info.FMode = UPDATE_MODE_REFRESH_IMAGE then
        TExplorerThread.Create(Info.FFileName, Info.FGUID, THREAD_TYPE_IMAGE, Info.FExplorerViewInfo, Info.FOwner, Info.FUpdaterInfo.Copy, Info.FState)
      else if Info.FMode = UPDATE_MODE_REFRESH_FOLDER then
        TExplorerThread.Create(Info.FFileName, Info.FGUID, THREAD_TYPE_FOLDER_UPDATE, Info.FExplorerViewInfo, Info.FOwner, Info.FUpdaterInfo.Copy, Info.FState)
      else if Info.FMode = UPDATE_MODE_REFRESH_FILE then
        TExplorerThread.Create(Info.FFileName, Info.FGUID, THREAD_TYPE_FILE, Info.FExplorerViewInfo, Info.FOwner, Info.FUpdaterInfo.Copy, Info.FState);

      ExplorerUpdateManager.RegisterThread(Info.FOwner, Info.FMode);
      F(Info);
    end else
      FData.Add(Info);
  finally
    FSync.Leave;
  end;
end;

function TExplorerUpdateManager.GetThreadCount(FOwner: TExplorerForm; Mode: Integer): Integer;
var
  I: Integer;
  Info: TExplorerWindowThreads;
begin
  Result := 0;
  FSync.Enter;
  try
    for I := 0 to FExplorerThreads.Count - 1 do
    begin
      Info := FExplorerThreads[I];
      if (Info.FExplorer = FOwner) and (Info.FMode = Mode) then
        Result := Info.FCounter;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerUpdateManager.RegisterThread(FOwner: TExplorerForm; Mode: Integer);
var
  I: Integer;
  Info: TExplorerWindowThreads;
begin
  FSync.Enter;
  try
    Info := nil;
    for I := 0 to FExplorerThreads.Count - 1 do
      if (TExplorerWindowThreads(FExplorerThreads[I]).FExplorer = FOwner)
        and (TExplorerWindowThreads(FExplorerThreads[I]).FMode = Mode) then
      begin
        Info := FExplorerThreads[I];
        Break;
      end;

    if Info = nil then
    begin
      Info := TExplorerWindowThreads.Create(FOwner, Mode);
      FExplorerThreads.Add(Info);
    end;

     Info.FCounter := Info.FCounter + 1;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerUpdateManager.UnRegisterThread(FOwner: TExplorerForm; Mode: Integer);
var
  I: Integer;
  Info: TExplorerWindowThreads;
begin
  FSync.Enter;
  try
    for I := 0 to FExplorerThreads.Count - 1 do
    begin
      Info := FExplorerThreads[I];
      if (Info.FExplorer = FOwner) and (Info.FMode = Mode) then
      begin
        Info.FCounter := Info.FCounter - 1;
        if Info.FCounter < 0 then
          Info.FCounter := 0;
        Break;
      end;
    end;

  finally
    FSync.Leave;
  end;
end;

{ TExplorerNotifyInfo }

constructor TExplorerNotifyInfo.Create(Owner: TExplorerForm; State: TGUID;
  UpdaterInfo: TUpdaterInfo; ExplorerViewInfo: TExplorerViewInfo;
  Mode: Integer; FileName, GUID: string);
begin
  FOwner := Owner;
  FState := State;
  FUpdaterInfo := UpdaterInfo;
  FExplorerViewInfo := ExplorerViewInfo;
  FMode := Mode;
  FFileName := FileName;
  FGUID := GUID;
end;

destructor TExplorerNotifyInfo.Destroy;
begin
  F(FUpdaterInfo);
  inherited;
end;

{ TExplorerWindowThreads }

constructor TExplorerWindowThreads.Create(Explorer: TExplorerForm; Mode: Integer);
begin
  FExplorer := Explorer;
  FMode := Mode;
  FCounter := 0;
end;

initialization
  FFolderPictureLock := TCriticalSection.Create;

finalization
  F(FFolderPictureLock);
  F(FullFolderPicture);
  F(ExplorerUpdateManagerInstance);

end.
