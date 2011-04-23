unit ExplorerThreadUnit;

interface

uses
  Jpeg, DB, ExplorerTypes, uGraphicUtils, uShellIntegration,
  UnitDBKernel, ExplorerUnit, Dolphin_DB, ShellAPI, Windows, ComCtrls,
  Classes, SysUtils, Graphics, Network, Forms, GraphicCrypt, Math,
  Controls, ComObj, ActiveX, ShlObj, CommCtrl, Registry,
  GraphicsBaseTypes, Win32crc, RAWImage, UnitDBDeclare,
  EasyListview, GraphicsCool, uVistaFuncs, uResources,
  UnitDBCommonGraphics, UnitDBCommon, uCDMappingTypes,
  uThreadEx, uAssociatedIcons, uLogger, uTime, uGOM, uFileUtils,
  uConstants, uMemory, SyncObjs, uDBPopupMenuInfo, pngImage, uPNGUtils,
  uMultiCPUThreadManager, uPrivateHelper, UnitBitmapImageList,
  uSysUtils, uRuntime, uDBUtils, uAssociations;

type
  TExplorerThread = class(TMultiCPUThread)
  private
    { Private declarations }
    FFolder: string;
    FMask: string;
    FIcon: Ticon;
    FCID: TGUID;
    TempBitmap: TBitmap;
    FBmp: Tbitmap;
    FSelected: TEasyItem;
    FFolderBitmap: TBitmap;
    FFolderImages: TFolderImages;
    FCountOfFolderImage: Integer;
    FFastDirectoryLoading: Boolean;
    FFiles: TExplorerFileInfos;
    BooleanResult: Boolean;
    IntParam: Integer;
    BooleanParam: Boolean;
    StringParam: string;
    GUIDParam: TGUID;
    CurrentFile: string;
    IconParam: TIcon;
    GraphicParam: TGraphic;
    FShowFiles: Boolean;
    FQuery: TDataSet;
    FInfoText: string;
    FInfoMax: Integer;
    FInfoPosition: Integer;
    SetText, Setmax, SetPos: Boolean;
    ProgressVisible: Boolean;
    DriveNameParam: string;
    FThreadType: Integer;
    StrParam: string;
    FIcoSize: Integer;
    FilesWithoutIcons, IntIconParam: Integer;
    CurrentInfoPos: Integer;
    FVisibleFiles: TStrings;
    IsBigImage: Boolean;
    LoadingAllBigImages: Boolean;
    NewItem: TEasyItem;
    FOwnerThreadType : Integer;
    CurrentFileInfo : TExplorerFileInfo;
    FPacketImages : TBitmapImageList;
    FPacketInfos : TExplorerFileInfos;
  protected
    procedure GetVisibleFiles;
    procedure Execute; override;
    procedure InfoToExplorerForm;
    procedure MakeTempBitmap;
    procedure BeginUpDate;
    procedure EndUpDate;
    Procedure MakeFolderImage(Folder : String);
    procedure FileNeededAW;
    procedure AddDirectoryItemToExplorer;
    procedure AddDirectoryImageToExplorer;
    procedure AddDirectoryIconToExplorer;
    procedure AddImageFileToPacket;
    procedure DrawImageIcon;
    procedure DrawImageIconSmall;
    procedure AddImageFileImageToExplorer;
    procedure AddImageFileItemToExplorer;
    procedure ReplaceImageItemImage(FileName : string; FileSize : Int64; FileID : TGUID);
    procedure DrawImageToTempBitmapCenter;
    procedure ReplaceImageInExplorer;
    procedure ReplaceInfoInExplorer;
    procedure ReplaceThumbImageToFolder(CurrentFile : string; DirctoryID : TGUID);
    Procedure DrawFolderImageBig(Bitmap : TBitmap);
    procedure DrawFolderImageWithXY(Bitmap : TBitmap; FolderImageRect : TRect; Source : TBitmap);
    procedure ReplaceFolderImage;
    procedure AddFile;
    procedure AddImageFileToExplorerW;
    procedure AddImageFileItemToExplorerW;
    function FindInQuery(FileName : String) : Boolean;
    Procedure ShowInfo(StatusText : String); overload;
    Procedure ShowInfo(Max, Value : Integer); overload;
    Procedure ShowInfo(StatusText : String; Max, Value : Integer); overload;
    Procedure ShowInfo(Pos : Integer); overload;
    Procedure SetInfoToStatusBar;
    procedure ShowProgress;
    procedure HideProgress;
    procedure DoStopSearch;
    Procedure SetProgressVisible;
    Procedure LoadMyComputerFolder;
    procedure AddDirectoryItemToExplorerW;
    procedure AddDriveToExplorer;
    procedure LoadNetWorkFolder;
    Procedure MakeImageWithIcon;
    procedure LoadWorkgroupFolder;
    procedure LoadComputerFolder;
    procedure ShowMessage_;
    procedure ExplorerBack;
    procedure UpdateFile;
    procedure UpdateFolder;
    procedure ReplaceImageInExplorerA;
    procedure ReplaceImageInExplorerB;
    procedure MakeIconForFile;
    procedure ChangeIDImage;
    Function ShowFileIfHidden(FileName :String) : boolean;
    procedure UpdateSimpleFile;
    procedure DoUpdaterHelpProc;
    procedure AddIconFileImageToExplorer;
    procedure EndUpdateID;
    procedure VisibleUp(TopIndex : integer);
    procedure DoLoadBigImages;
    procedure GetAllFiles;
    procedure DoDefaultSort;
    procedure ExtractImage(Info : TDBPopupMenuInfoRecord; CryptedFile : Boolean; FileID : TGUID);
    procedure ExtractDirectoryPreview(FileName : string; DirectoryID: TGUID);
    procedure ExtractBigPreview(FileName : string; Rotated : Integer; FileGUID : TGUID);
    procedure DoMultiProcessorTask; override;
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure SendPacketToExplorer;
  protected
    function IsVirtualTerminate : Boolean; override;
    function GetThreadID : string; override;
  public
    FUpdaterInfo : TUpdaterInfo;
    ExplorerInfo : TExplorerViewInfo;
    FInfo : TDBPopupMenuInfoRecord;
    IsCryptedFile : Boolean;
    FFileID : TGUID;
    FSender : TExplorerForm;
    constructor Create(Folder, Mask: string;
      ThreadType: Integer; Info: TExplorerViewInfo; Sender: TExplorerForm;
      UpdaterInfo: TUpdaterInfo; SID: TGUID);
    destructor Destroy; override;
    property OwnerThreadType : Integer read FOwnerThreadType write FOwnerThreadType;
    property ThreadType : Integer read FThreadType;
  end;

type
  TIconType = (itSmall, itLarge);

var
  AExplorerFolders : TExplorerFolders = nil;
  UpdaterCount : integer = 0;
  ExplorerUpdateBigImageThreadsCount : integer = 0;
  FullFolderPicture: TPNGImage = nil;
  FFolderPictureLock : TCriticalSection = nil;

implementation

uses
  FormManegerUnit, UnitViewerThread, CommonDBSupport, uExplorerThreadPool;

  { TExplorerThread }

constructor TExplorerThread.Create(Folder,
  Mask: string; ThreadType : Integer; Info: TExplorerViewInfo; Sender : TExplorerForm; UpdaterInfo: TUpdaterInfo; SID : TGUID);
begin
  inherited Create(Sender, SID);
  FInfo := TDBPopupMenuInfoRecord.Create;
  CurrentFileInfo := nil;
  FPacketImages  := nil;
  FPacketInfos  := nil;
  FThreadType := ThreadType;
  FOwnerThreadType := THREAD_TYPE_NONE;
  FSender := Sender;
  FFolder := Folder;
  Fmask := Mask;
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
var
  Found, FilesReadedCount: Integer;
  SearchRec: TSearchRec;
  I: Integer;
  DBFolder, DBFolderToSearch, FileMask: string;
  InfoPosition: Integer;
  PrivateFiles: TStringList;
  Fa: Integer;
  FE, EM: Boolean;
  Crc: Cardinal;
  S: string;
  P: Integer;
  IsPrivateDirectory : Boolean;

  procedure LoadDBContent;
  var
    I : Integer;
  begin
    ShowInfo(L('Query in collection...'), 1, 0);

    SetSQL(FQuery, 'Select * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FFolder, False)));

    for I := 1 to 20 do
    begin
      try
        FQuery.Active := True;
        Break;
      except
        on E: Exception do
        begin
          EventLog(':TExplorerThread::Execute throw exception: ' + E.message);
          Sleep(DelayExecuteSQLOperation);
        end;
      end;
    end;
  end;

begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    LoadingAllBigImages := True;

    case ExplorerInfo.View of
      LV_THUMBS     : begin FIcoSize:=48; end;
      LV_ICONS      : begin FIcoSize:=32; end;
      LV_SMALLICONS : begin FIcoSize:=16; end;
      LV_TITLES     : begin FIcoSize:=16; end;
      LV_TILE       : begin FIcoSize:=48; end;
      LV_GRID       : begin FIcoSize:=32; end;
    end;

    if FUpdaterInfo.IsUpdater then
    begin
      AddFile;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_THREAD_PREVIEW) then
    begin
      StartMultiThreadWork;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
    begin
      FFiles := TExplorerFileInfos.Create;
      ShowProgress;
      DoLoadBigImages;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_IMAGE) then
    begin
      if UpdaterCount > ProcessorCount then
      begin
        repeat
          if UpdaterCount < ProcessorCount then
            Break;
          Sleep(10);
        until False;
      end;
      Inc(UpdaterCount);
      LoadingAllBigImages := False; //грузятся не все файлы заново а только текущий
      UpdateFile;
      Dec(UpdaterCount);
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_FILE) then
    begin
      UpdateSimpleFile;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_FOLDER_UPDATE) then
    begin
      UpdateFolder;
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

        //TODO: review
        UnProcessPath(DBFolderToSearch);
        DBFolderToSearch := ExcludeTrailingBackslash(AnsiLowerCase(DBFolderToSearch));
        CalcStringCRC32(AnsiLowerCase(DBFolderToSearch),crc);
        DBFolderToSearch := IncludeTrailingBackslash(DBFolderToSearch);
        FFolder := IncludeTrailingBackslash(FFolder);

        FFiles := TExplorerFileInfos.Create;

        IsPrivateDirectory := TPrivateHelper.Instance.IsPrivateDirectory(DBFolderToSearch);

        DBFolder := NormalizeDBStringLike(NormalizeDBString(DBFolderToSearch));
        FQuery := GetQuery;
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
          FilesReadedCount:=0;
          FilesWithoutIcons:=0;
          FE := False;
          EM := False;
          if FMask = '' then FileMask:='*.*' else
            FileMask := FMask;
          Found := FindFirst(FFolder + FileMask, FaAnyFile, SearchRec);
          while Found = 0 do
          begin
            if IsTerminated then
              Break;
            try
              if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
              begin
                FA := SearchRec.Attr and FaHidden;
                if ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (FA = 0)) then
                begin
                  if not ExplorerInfo.ShowPrivate then
                    if PrivateFiles.IndexOf(AnsiLowerCase(SearchRec.name)) > -1 then
                      Continue;

                  Inc(FilesReadedCount);
                  if FilesReadedCount mod 10 = 0 then
                    ShowInfo(Format(L('Reading directory [%d objects found]'), [FilesReadedCount]), 1, 0);
                  if ExplorerInfo.ShowImageFiles or ExplorerInfo.ShowSimpleFiles then
                  begin
                    FE := (SearchRec.Attr and FaDirectory = 0);
                    S := ExtractFileExt(SearchRec.name);
                    S := '|' + AnsiLowerCase(S) + '|';
                    P := Pos(S, SupportedExt);
                    EM := P <> 0;
                  end;
                  if FShowFiles then
                    if ExplorerInfo.ShowSimpleFiles then
                      if FE and not EM and ExplorerInfo.ShowSimpleFiles then
                      begin
                        if FolderView then
                          if AnsiLowerCase(ExtractFileExt(SearchRec.name)) = '.ldb' then
                            Continue;

                        AddOneExplorerFileInfo(FFiles, FFolder + SearchRec.name, EXPLORER_ITEM_FILE, -1, GetGUID, 0, 0,
                          0, 0, SearchRec.Size, '', '', '', 0, False, True, True);
                        Continue;
                      end;
                  if ExplorerInfo.ShowImageFiles then
                    if FE and EM and ExplorerInfo.ShowImageFiles then
                    begin
                      AddOneExplorerFileInfo(FFiles, FFolder + SearchRec.name, EXPLORER_ITEM_IMAGE, -1, GetGUID, 0, 0,
                        0, 0, SearchRec.Size, '', '', '', 0, False, False, True);
                      Continue;
                    end;
                  if (SearchRec.Attr and FaDirectory <> 0) and ExplorerInfo.ShowFolders then
                  begin
                    AddOneExplorerFileInfo(FFiles, FFolder + SearchRec.name, EXPLORER_ITEM_FOLDER, -1, GetGUID, 0, 0,
                      0, 0, 0, '', '', '', 0, False, True, True);
                    Continue;
                  end;
                end;
              end;
            finally
              Found := SysUtils.FindNext(SearchRec);
            end;
          end;
          FindClose(SearchRec);

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
            //FPacketInfos hasn't own items - it pointers from FFiles
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
          InfoPosition:=0;

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
              CurrentFile:=FFiles[I].FileName;
              CurrentInfoPos := I;
              ReplaceImageItemImage(FFiles[I].FileName, FFiles[I].FileSize, FFiles[I].SID);
            end;

           if ((FFiles[I].FileType = EXPLORER_ITEM_FILE) and (FFiles[I].Tag = 1)) then
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
            DoLoadBigImages;

          HideProgress;
          ShowInfo('');
          SynchronizeEx(DoStopSearch);
        finally
          FreeDS(FQuery);
        end;
      finally
        PrivateFiles.Free;
      end;
    finally
      SynchronizeEx(HideLoadingSign);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TExplorerThread.SendPacketToExplorer;
var
  I : Integer;
  Icon : TIcon;
  S1, S2 : String;
  Info : TExplorerFileInfo;
begin
  BeginUpdate;
  try
    FSender.AddInfoAboutFile(FPacketInfos);
    for I := 0 to FPacketInfos.Count - 1 do
    begin
      Info := FPacketInfos[I];
      Icon := FPacketImages[I].Icon;
      if not FSender.AddIcon(Icon, True, Info.SID) then
        FPacketImages[I].Graphic := nil;

      NewItem := FSender.AddItem(Info.SID);
      S1 := ExcludeTrailingBackslash(ExplorerInfo.OldFolderName);
      S2 := ExcludeTrailingBackslash(Info.FileName);

      if AnsiLowerCase(S1) = AnsiLowerCase(S2) then
        FSelected := NewItem;
    end;
    FPacketImages.ClearImagesList;
    FPacketInfos.ClearList;
  finally
    EndUpdate;
  end;
end;

procedure TExplorerThread.AddImageFileToPacket;
var
  EXT : String;
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
    Ficon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);

  FPacketImages.AddIcon(FIcon, True);
end;

procedure TExplorerThread.BeginUpdate;
begin
  FSender.BeginUpdate;
end;

procedure TExplorerThread.EndUpdate;
begin
  FSender.EndUpdate;
  FSender.Select(FSelected, FCID);
  AExplorerFolders.CheckFolder(FFolder);
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
    BooleanResult:=FSender.FileNeededW(GUIDParam);
end;

procedure TExplorerThread.AddDriveToExplorer;
begin
  AddDirectoryImageToExplorer;
  AddDirectoryItemToExplorerW;
end;

procedure TExplorerThread.AddDirectoryItemToExplorer;
var
  S1, S2 : String;
begin
  NewItem := FSender.AddItem(GUIDParam);
  S1 := ExcludeTrailingBackslash(ExplorerInfo.OldFolderName);
  S2 := ExcludeTrailingBackslash(CurrentFile);

  if AnsiLowerCase(S1) = AnsiLowerCase(S2) then
    FSelected := NewItem;
end;

procedure TExplorerThread.AddDirectoryImageToExplorer;
begin
  if not IsTerminated then
    FSender.AddIcon(FIcon, True, GUIDParam);
end;

procedure TExplorerThread.AddDirectoryItemToExplorerW;
var
  NewItem : TEasyItem;
  S1, S2 : String;
begin
  NewItem := FSender.AddItemW(DriveNameParam, GUIDParam);

  S1 := ExcludeTrailingBackslash(ExplorerInfo.OldFolderName);
  S2 := ExcludeTrailingBackslash(CurrentFile);

  if AnsiLowerCase(S1) = AnsiLowerCase(S2) then
    FSelected := NewItem;
end;

procedure TExplorerThread.DrawImageIcon;
begin
if IconParam <> nil then
    TempBitmap.Canvas.Draw(ExplorerInfo.PictureSize div 2-FIcoSize div 2,ExplorerInfo.PictureSize div 2-FIcoSize div 2,IconParam);
end;

procedure TExplorerThread.DrawImageIconSmall;
begin
  if IconParam <> nil then
    TempBitmap.Canvas.Draw(0, 0, IconParam);
end;

procedure TExplorerThread.AddImageFileImageToExplorer;
begin
  if not IsTerminated then
    FSender.AddIcon(FIcon, True, GUIDParam);
end;

procedure TExplorerThread.AddIconFileImageToExplorer;
begin
  If not IsTerminated then
   FSender.AddIcon(FIcon, True, GUIDParam);
end;

procedure TExplorerThread.AddImageFileItemToExplorer;
var
  NewItem : TEasyItem;
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
  FBS : TStream;
  CryptedFile : Boolean;
  JPEG: TJpegImage;
begin
  TempBitmap := nil;
  IsBigImage := False;
  CryptedFile := ValidCryptGraphicFile(FileName);

  F(FInfo);
  FInfo := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
  FInfo.FileSize := FileSize;
  FInfo.Crypted := CryptedFile;
  FInfo.Tag := EXPLORER_ITEM_FOLDER;
  FInfo.PassTag := 0;
  if not FUpdaterInfo.IsUpdater then
  begin
    if FindInQuery(FileName) then
    begin

      FInfo.ReadFromDS(fQuery);
      FInfo.FileName := FileName;
      if ExplorerInfo.View = LV_THUMBS then
      begin
        if FInfo.Crypted then
        begin
          JPEG := TJpegImage.Create;
          DeCryptBlobStreamJPG(fQuery.FieldByName('thum'), DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum')), JPEG);
          FInfo.Image := JPEG;
          if not FInfo.Image.Empty then
            FInfo.PassTag := 1;
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

procedure TExplorerThread.DrawImageToTempBitmapCenter;
begin
  TempBitmap.Canvas.Draw(ThSize div 2 - GraphicParam.Width div 2, ThSize div 2 - GraphicParam.height div 2, GraphicParam);
end;

procedure TExplorerThread.ReplaceImageInExplorer;
begin
  if not IsTerminated then
  begin
    FSender.SetInfoToItem(FInfo, GUIDParam, True);

    if not FSender.ReplaceBitmap(TempBitmap, GUIDParam, FInfo.Include, isBigImage) then
      F(TempBitmap);
  end else
    F(TempBitmap);
end;

procedure TExplorerThread.ReplaceInfoInExplorer;
begin
  if not IsTerminated then
    FSender.SetInfoToItem(FInfo, GUIDParam);
end;

procedure TExplorerThread.ReplaceImageInExplorerA;
begin
  if not IsTerminated then
     FSender.SetInfoToItem(FInfo, GUIDParam);
end;

procedure TExplorerThread.ReplaceThumbImageToFolder(CurrentFile : string; DirctoryID : TGUID);
var
  Found, Count, Dx, i, j, x, y, w, H, Ps, index: Integer;
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
  DBFolder, Password: string;
  RecCount, SmallImageSize, Deltax, Deltay, _x, _y: Integer;
  Fbs: TStream;
  FJpeg: TJpegImage;
  Nbr: Integer;
  C: Integer;
  FE, EM: Boolean;
  S: string;
  P: Integer;
  Crc: Cardinal;
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;

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
  for i := 1 to 4 do
    FilesInFolder[i] := '';

  CurrentFile := IncludeTrailingBackslash(CurrentFile);
  fFolderImages.Directory := CurrentFile;
  FFolderImagesResult := AExplorerFolders.GetFolderImages(CurrentFile, SmallImageSize, SmallImageSize);
  FFastDirectoryLoading := False;
  if FFolderImagesResult.Directory <> '' then
    FFastDirectoryLoading := True
  else
  begin
    for I := 1 to 4 do
      FFolderImages.Images[I] := nil;
  end;
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
          DBFolder:=NormalizeDBStringLike(NormalizeDBString(AnsiLowerCase(CurrentFile)));
          DBFolder := ExcludeTrailingBackslash(DBFolder);
          CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);
          DBFolder := IncludeTrailingBackslash(DBFolder);

          Query := GetQuery(False);
          ReadOnlyQuery(Query);

          if ExplorerInfo.ShowPrivate then
            SetSQL(Query,'Select TOP 4 FFileName, Access, thum, Rotated From $DB$ where FolderCRC='+IntToStr(Integer(crc)) + ' and (FFileName Like :FolderA) and not (FFileName like :FolderB) ')
          else
            SetSQL(Query,'Select TOP 4 FFileName, Access, thum, Rotated From $DB$ where FolderCRC='+IntToStr(Integer(crc)) + ' and (FFileName Like :FolderA) and not (FFileName like :FolderB) and Access <> ' + IntToStr(db_access_private));

          SetStrParam(Query, 0, '%' + DBFolder + '%');
          SetStrParam(Query, 1, '%' + DBFolder + '%\%');

          Query.Active := True;

          for I := 1 to 4 do
            RecNos[I] := 0;

          if not Query.IsEmpty then
          begin
            Query.First;
            for i:=1 to Query.RecordCount do
            begin
              if Query.FieldByName('Access').AsInteger = db_access_private then
                FPrivateFileNames.Add(AnsiLowerCase(Query.FieldByName('FFileName').AsString));

              if (Query.FieldByName('Access').AsInteger<>db_access_private) or ExplorerInfo.ShowPrivate then
              if FileExistsSafe(Query.FieldByName('FFileName').AsString) then
              if ShowFileIfHidden(Query.FieldByName('FFileName').AsString) then
              begin
                OK := true;
                if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
                if DBkernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'))='' then
                  OK := false;
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
                s := ExtractFileExt(SearchRec.Name);
                s:= '|' + AnsiLowerCase(s) + '|';
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
              Found := SysUtils.FindNext(SearchRec);
            end;
            FindClose(SearchRec);
          end;
          if Count + Nbr = 0 then
            Exit;
        end;
      finally
        F(FFileNames);
        F(FPrivateFileNames);
      end;

      Dx:=4;

      TempBitmap := TBitmap.Create;
      DrawFolderImageBig(TempBitmap);

      c:=0;

      for i:=1 to 2 do
      for j:=1 to 2 do
      begin
        if IsTerminated then
          Exit;
        Index:=(i - 1) * 2 + j;
        FcountOfFolderImage := Index;
        // 34  68
        // 562 564
        // 600 600
        deltax := Round(34*ps/600);
        deltay := Round(68*ps/600);
        _x := Round((562-34)*ps/1200);
        _y := Round((564-68)*ps/1200);
        SmallImageSize := Round(_y/1.05);

        x:=(j - 1) * _x + deltax;
        y:=(i - 1) * _y + deltay;
        if fFastDirectoryLoading then
        begin
          if FFolderImagesResult.Images[Index]=nil then
            Break;
          fbmp := FFolderImagesResult.Images[Index];
          W := fbmp.Width;
          H := fbmp.Height;
          ProportionalSize(SmallImageSize,SmallImageSize,w,h);
          DrawFolderImageWithXY(TempBitmap, Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h), fbmp);
          Continue;
        end;
        if index > count + Nbr then
          Break;
        if index > count then
        begin
          inc(c);
          Query.RecNo := RecNos[c];
          if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
          begin
            Password := DBKernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'));
            if Password <> '' then
            begin
              FJPEG := TJpegImage.Create;
              DeCryptBlobStreamJPG(Query.FieldByName('thum'), Password, FJPEG);
            end
            else
              Continue;
          end else
          begin
            FJPEG:=TJpegImage.Create;
            FBS:= GetBlobStream(Query.FieldByName('thum'), bmRead);
            try
              FJPEG.LoadFromStream(FBS);
            finally
              F(FBS);
            end;
          end;
          fbmp := TBitmap.Create;
          try
            JPEGScale(fJpeg, SmallImageSize, SmallImageSize);
            AssignJpeg(FBmp, FJpeg);
            F(fJpeg);
            ApplyRotate(fbmp, Query.FieldByName('Rotated').AsInteger);

            w := fbmp.Width;
            h := fbmp.Height;
            ProportionalSize(SmallImageSize, SmallImageSize, W, H);
            DrawFolderImageWithXY(TempBitmap, Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h), fbmp);
          finally
            F(fbmp);
          end;
        end else
        begin

          GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(Files[Index]));
          if GraphicClass = nil then
            Continue;

          Graphic := GraphicClass.Create;
          try
            if ValidCryptGraphicFile(Files[Index]) then
            begin
              Password := DBKernel.FindPasswordForCryptImageFile(Files[Index]);
              if Password<>'' then
              begin
                F(Graphic);
                Graphic := DeCryptGraphicFile(Files[Index], Password);
              end;

              if Graphic = nil then
                Continue;
            end else
            begin
              if Graphic is TRAWImage then
              begin
                if not (Graphic as TRAWImage).LoadThumbnailFromFile(Files[Index], SmallImageSize, SmallImageSize) then
                  Graphic.LoadFromFile(Files[Index]);
              end else
                Graphic.LoadFromFile(Files[Index]);
            end;
            _y := Round((564-68)*ps/1200);
            SmallImageSize := Round(_y / 1.05);
            JPEGScale(Graphic, SmallImageSize, SmallImageSize);
            W := Graphic.Width;
            H := Graphic.Height;
            ProportionalSize(SmallImageSize, SmallImageSize, W, H);
            Fbmp := TBitmap.Create;
            try
              bmp := TBitmap.Create;
              try
                AssignGraphic(BMP, Graphic);
                F(Graphic);

                DoResize(W, H, BMP, FBMP);
                DrawFolderImageWithXY(TempBitmap, Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h), fbmp);
              finally
                F(BMP);
              end;
            finally
              F(FBMP);
            end;
          finally
            F(Graphic);
          end;
        end;
      end;
    finally
      FreeAndNil(Query);
    end;

    if not FFastDirectoryLoading and ExplorerInfo.SaveThumbNailsForFolders then
    begin
      for I := 1 to 4 do
        FFolderImages.FileNames[I] := FilesInFolder[I];
      for I := 1 to 4 do
        FFolderImages.FileDates[I] := FilesDatesInFolder[I];
      AExplorerFolders.SaveFolderImages(FFolderImages, SmallImageSize, SmallImageSize);
    end;

  finally
    for I := 1 to 4 do
      F(FFolderImages.Images[I]);

    for I := 1 to 4 do
      F(FFolderImagesResult.Images[I]);
  end;

  GUIDParam := DirctoryID;
  if not SynchronizeEx(ReplaceFolderImage) then
    F(TempBitmap)
  else
    TempBitmap := nil;
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
     Bit32.Free;
    end;
  end;
end;

procedure TExplorerThread.DrawFolderImageWithXY(Bitmap : TBitmap; FolderImageRect : TRect; Source : TBitmap);
begin
  if not fFastDirectoryLoading then
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
  FSender.ReplaceBitmap(TempBitmap, GUIDParam, True);
end;

procedure TExplorerThread.AddFile;
var
  Ext_ : String;
  IsExt_  : Boolean;
  FE : Boolean;
  Info : TDBPopupMenuInfoRecord;
begin
  Info := FUpdaterInfo.FileInfo;
  FE := FileExistsSafe(Info.FileName);

  if FolderView then
    if AnsiLowerCase(ExtractFileExt(Info.FileName)) = '.ldb' then
      Exit;

  FFiles := TExplorerFileInfos.Create;
  try
    Ext_ := ExtractFileExt(Info.FileName);
    IsExt_ := ExtInMask(SupportedExt, Ext_);
    if DirectoryExists(Info.FileName) then
      AddOneExplorerFileInfo(FFiles, Info.FileName, EXPLORER_ITEM_FOLDER, -1, GetGUID, 0, 0, 0, 0,
        GetFileSizeByName(Info.FileName), '', '', '', 0, False, False, True);
    if FE and IsExt_ then
      AddOneExplorerFileInfo(FFiles, Info.FileName, EXPLORER_ITEM_IMAGE, -1, GetGUID, 0, 0, 0, 0,
        GetFileSizeByName(Info.FileName), '', '', '', 0, False, ValidCryptGraphicFile(Info.FileName),
        True);
    if FShowFiles then
      if FE and not IsExt_ then
        AddOneExplorerFileInfo(FFiles, Info.FileName, EXPLORER_ITEM_FILE, -1, GetGUID, 0, 0, 0, 0,
          GetFileSizeByName(Info.FileName), '', '', '', 0, False, False, True);
    if FFiles.Count = 0 then
      Exit;
    if FFiles[0].FileType = EXPLORER_ITEM_IMAGE then
    begin
      GUIDParam := FFiles[0].SID;
      CurrentFile := FFiles[0].FileName;
      AddImageFileToExplorerW; // TODO: filesize is undefined
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
    F(FIcon);
end;

procedure TExplorerThread.AddImageFileItemToExplorerW;
begin
  if not IsTerminated then
  begin
    FSender.AddInfoAboutFile(FFiles);
    FSender.AddIcon(FIcon, True, GUIDParam);

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

function TExplorerThread.FindInQuery(FileName: String) : Boolean;
var
  I : Integer;
  AddPathStr : string;
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
  SetText:=false;
  SetMax:=True;
  SetPos:=True;
  FInfoMax := Max;
  FInfoPosition := Value;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(StatusText: String; Max,
  Value: Integer);
begin
  SetText:=True;
  SetMax:=True;
  SetPos:=True;
  FInfoText:=StatusText;
  FInfoMax := Max;
  FInfoPosition := Value;
  SynchronizeEx(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(Pos: Integer);
begin
  SetText:=False;
  SetMax:=False;
  SetPos:=True;
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

procedure TExplorerThread.HideProgress;
begin
  ProgressVisible:=False;
  SynchronizeEx(SetProgressVisible);
end;

procedure TExplorerThread.SetProgressVisible;
begin
  if not IsTerminated then
  begin
   If ProgressVisible then
     FSender.ShowProgress
   else
     FSender.HideProgress;
 end;
end;

procedure TExplorerThread.ShowProgress;
begin
  ProgressVisible := True;
  SynchronizeEx(SetProgressVisible);
end;

procedure TExplorerThread.LoadMyComputerFolder;
const
  DRIVE_REMOVABLE = 2;
  DRIVE_FIXED     = 3;
  DRIVE_REMOTE    = 4;
  DRIVE_CDROM     = 5;
var
  I: Integer;
  DS: TDriveState;
  OldMode: Cardinal;
  DriveType : UINT;
begin
  HideProgress;
  ShowInfo(L('Loading "My computer" directory') + '...', 1, 0);
  FFiles := TExplorerFileInfos.Create;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  for I := Ord('C') to Ord('Z') do
  begin
    DriveType := GetDriveType(PChar(Chr(I) + ':\'));
    if (DriveType = DRIVE_REMOVABLE) or (DriveType = DRIVE_FIXED) or
      (DriveType = DRIVE_REMOTE) or (DriveType = DRIVE_CDROM) then
    begin
      DriveState(AnsiChar(I));
      AddOneExplorerFileInfo(FFiles, Chr(I) + ':\', EXPLORER_ITEM_DRIVE, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '', 0,
        False, False, True);
    end;
  end;

  SynchronizeEx(BeginUpdate);
  AddOneExplorerFileInfo(FFiles, L('Network'), EXPLORER_ITEM_NETWORK, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '', 0,
    False, False, True);
  SynchronizeEx(InfoToExplorerForm);
  for I := 0 to FFiles.Count - 1 do
  begin
    if FFiles[I].FileType = EXPLORER_ITEM_DRIVE then
    begin
      GUIDParam := FFiles[I].SID;
      CurrentFile := FFiles[I].FileName;
      MakeFolderImage(CurrentFile);
      DS := DriveState(AnsiString(CurrentFile)[1]);
      if (DS = DS_DISK_WITH_FILES) or (DS = DS_EMPTY_DISK) then
        DriveNameParam := GetCDVolumeLabel(CurrentFile[1]) + ' (' + CurrentFile[1] + ':)'
      else
        DriveNameParam := MrsGetFileType(CurrentFile[1] + ':\') + ' (' + CurrentFile[1] + ':)';
      SynchronizeEx(AddDriveToExplorer);
    end;
    if FFiles[I].FileType = EXPLORER_ITEM_NETWORK then
    begin
      GUIDParam := FFiles[I].SID;
      CurrentFile := FFiles[I].FileName;

      IconParam := nil;
      FindIcon(HInstance, 'NETWORK', FIcoSize, 32, IconParam);
      FIcon := IconParam;
      MakeImageWithIcon;
    end;
  end;
  SetErrorMode(OldMode);
  SynchronizeEx(EndUpdate);
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.LoadNetWorkFolder;
var
  NetworkList: TStrings;
  I: Integer;
begin
  HideProgress;
  ShowInfo(L('Scaning network') + '...', 1, 0);
  FFiles := TExplorerFileInfos.Create;
  try
    NetworkList := TStringList.Create;
    try
      FillNetLevel(nil, NetWorkList);
      SynchronizeEx(BeginUpdate);
      for I := 0 to NetworkList.Count - 1 do
        AddOneExplorerFileInfo(FFiles, NetworkList[I], EXPLORER_ITEM_WORKGROUP, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '',
          0, False, False, True);
      SynchronizeEx(InfoToExplorerForm);
    finally
      F(NetworkList);
    end;
    for I := 0 to FFiles.Count - 1 do
    begin
      GUIDParam := FFiles[I].SID;
      CurrentFile := FFiles[I].FileName;

      IconParam := nil;
      FindIcon(HInstance, 'WORKGROUP', FIcoSize, 32, IconParam);

      FIcon := IconParam;
      MakeImageWithIcon;

    end;
  finally
    F(FFiles);
  end;
  SynchronizeEx(EndUpdate);
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.MakeImageWithIcon;
begin
  AddImageFileImageToExplorer;
  AddImageFileItemToExplorer;
end;

procedure TExplorerThread.LoadWorkgroupFolder;
var
  ComputerList: TStrings;
  I: Integer;
begin
  HideProgress;
  try
    ShowInfo(L('Scaning workgroup') + '...', 1, 0);
    FFiles := TExplorerFileInfos.Create;
    try
      ComputerList := TStringList.Create;
      try
        if (FindAllComputers(FFolder, ComputerList) <> 0) and (ComputerList.Count = 0) then
        begin
          StrParam := Format(L('Error opening network "%s"!'), [FFolder]);
          SynchronizeEx(ShowMessage_);
          SynchronizeEx(ExplorerBack);
          Exit;
        end;

        SynchronizeEx(BeginUpdate);
        for I := 0 to ComputerList.Count - 1 do
          AddOneExplorerFileInfo(FFiles, ComputerList[I], EXPLORER_ITEM_COMPUTER, -1, GetGUID, 0, 0, 0, 0, 0, '', '',
            '', 0, False, False, True);
        SynchronizeEx(InfoToExplorerForm);
      finally
        ComputerList.Free;
      end;
      for I := 0 to FFiles.Count - 1 do
      begin
        GUIDParam := FFiles[I].SID;
        CurrentFile := FFiles[I].FileName;

        IconParam := nil;
        FindIcon(HInstance, 'COMPUTER', FIcoSize, 32, IconParam);

        FIcon := IconParam;
        SynchronizeEx(MakeImageWithIcon);
      end;
    finally
      F(FFiles);
    end;
  finally
    SynchronizeEx(EndUpdate);
    ShowInfo('', 1, 0);
  end;
end;

procedure TExplorerThread.LoadComputerFolder;
var
  ShareList : TStrings;
  I,
  Res: Integer;
begin
  HideProgress;
  try
    ShowInfo(L('Opening computer'), 1, 0);
    FFiles := TExplorerFileInfos.Create;
    try
      ShareList := TStringList.Create;
      try
        Res := FindAllComputers(FFolder, ShareList);
        if (Res <> 0) and (ShareList.Count = 0) then
        begin
          StrParam := Format(L('Error opening computer "%s"!'), [FFolder]);
          SynchronizeEx(ShowMessage_);
          SynchronizeEx(ExplorerBack);
          Exit;
        end;
        SynchronizeEx(BeginUpdate);
        for I := 0 to ShareList.Count - 1 do
          AddOneExplorerFileInfo(FFiles, ShareList[I], EXPLORER_ITEM_SHARE, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '', 0,
            False, False, True);
        SynchronizeEx(InfoToExplorerForm);
      finally
        F(ShareList);
      end;
      for I := 0 to FFiles.Count - 1 do
      begin
        GUIDParam := FFiles[I].SID;
        CurrentFile := FFiles[I].FileName;

        IconParam := nil;
        FindIcon(HInstance, 'SHARE', FIcoSize, 32, IconParam);
        FIcon := IconParam;
        SynchronizeEx(MakeImageWithIcon);
      end;
    finally
      F(FFiles);
    end;
  finally
    SynchronizeEx(EndUpdate);
    ShowInfo('', 1, 0);
  end;
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
  Info : TExplorerFileInfo;
  NewInfo : TExplorerFileInfo;
begin
  Info := FUpdaterInfo.FileInfo;
  if FUpdaterInfo.UpdateDB and (Info.ID > 0) then
    UpdateImageRecord(FSender, Info.FileName, Info.ID);

  FQuery := GetQuery;
  ReadOnlyQuery(FQuery);

  //TODO:!!!
  UnProcessPath(FFolder);

  SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = :FolderCRC AND Name = :Name');

  SetIntParam(FQuery, 0, GetPathCRC(Info.FileName, True));
  SetStrParam(FQuery, 1, AnsiLowercase(ExtractFileName(Info.FileName)));
  try
    FQuery.Active := True;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  FFiles := TExplorerFileInfos.Create;
  try
    if FQuery.RecordCount > 0 then
    begin
      NewInfo := TExplorerFileInfo.CreateFromDS(FQuery);
      NewInfo.SID := Info.SID;
    end else
    begin
      NewInfo := TExplorerFileInfo(Info.Copy);
      NewInfo.FileSize := GetFileSizeByName(Info.FileName);
      NewInfo.Crypted := ValidCryptGraphicFile(Info.FileName);
    end;
    FFiles.Add(NewInfo);

    GUIDParam := FFiles[0].SID;
    if FolderView then
      CurrentFile := ProgramDir + FFiles[0].FileName
    else
      CurrentFile := FFiles[0].FileName;

    if ExplorerInfo.ShowThumbNailsForImages then
      ReplaceImageItemImage(FFiles[0].FileName, FFiles[0].FileSize, GUIDParam); // todo: filesize is undefined

    IntParam := Info.ID;
    SynchronizeEx(EndUpdateID);
    FreeDS(FQuery);

    DoLoadBigImages;

  finally
    F(FFiles);
  end;
  if FInfo.ID <> 0 then
    if Assigned(FUpdaterInfo.ProcHelpAfterUpdate) then
      SynchronizeEx(DoUpdaterHelpProc);
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
      F(TempBitmap);
  end else
    if not FSender.ReplaceIcon(FIcon, GUIDParam, true) then
      F(FIcon);
end;

procedure TExplorerThread.MakeIconForFile;
begin
  TempBitmap := nil;
  FIcon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);
  if not SynchronizeEx(ReplaceImageInExplorerB) then
    F(FIcon);
end;

procedure TExplorerThread.UpdateSimpleFile;
begin
  StringParam := Fmask;
  CurrentFile := FFolder;
  MakeIconForFile;
end;

procedure TExplorerThread.ChangeIDImage;
var
  EventInfo : TEventValues;
begin
  EventInfo.Image := nil;
  DBKernel.DoIDEvent(FSender, FUpdaterInfo.FileInfo.ID, [EventID_Param_Image],EventInfo);
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
  FFiles:=TExplorerFileInfos.Create;
  AddOneExplorerFileInfo(FFiles, FFolder, EXPLORER_ITEM_FOLDER, -1, StringToGUID(Fmask), 0, 0, 0, 0, 0, '', '', '', 0,
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
    FSender.RemoveUpdateID(IntParam, FCID);
end;

procedure TExplorerThread.GetVisibleFiles;
begin
  FVisibleFiles := FSender.GetVisibleItems;
end;

procedure TExplorerThread.VisibleUp(TopIndex: integer);
var
  I, C : integer;
  J : integer;
begin
  C := TopIndex;
  for I := 0 to FVisibleFiles.Count - 1 do
    for J := TopIndex to FFiles.Count - 1 do
      if FFiles[J].Tag = 0 then
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

procedure TExplorerThread.DoLoadBigImages;
var
  I, InfoPosition : integer;
begin
  while ExplorerUpdateBigImageThreadsCount > ProcessorCount do
    Sleep(10);

  Inc(ExplorerUpdateBigImageThreadsCount);

  try
    if LoadingAllBigImages then
      if not SynchronizeEx(GetAllFiles) then
        Exit;

    ShowInfo(L('Loading previews'));
    ShowInfo(FFiles.Count ,0);
    InfoPosition:=0;

    for I := 0 to FFiles.Count - 1 do
    begin

      Inc(InfoPosition);
      ShowInfo(InfoPosition);

      if I mod 5 = 0 then
      begin
       F(FVisibleFiles);
       if SynchronizeEx(GetVisibleFiles) then
         VisibleUp(I);
      end;

      GUIDParam := FFiles[i].SID;

      if FFiles[i].FileType = EXPLORER_ITEM_IMAGE then
      begin

        BooleanResult := False;
        //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
        if not LoadingAllBigImages then
          BooleanResult := True
        else
          SynchronizeEx(FileNeededAW);

        if IsTerminated then Break;

        if BooleanResult then
        begin
          if ProcessorCount > 1 then
            TExplorerThreadPool.Instance.ExtractBigImage(Self, FFiles[i].FileName, FFiles[i].Rotation, GUIDParam)
          else
            ExtractBigPreview(CurrentFile, FFiles[i].Rotation, GUIDParam);
        end;
      end;

      //directories
      if FFiles[i].FileType = EXPLORER_ITEM_FOLDER then
      begin
        BooleanResult := False;
        if not SynchronizeEx(FileNeededAW) then
          Exit;

        CurrentFile := FFiles[i].FileName;

        //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
        if not LoadingAllBigImages then
          BooleanResult := True;

        if IsTerminated then break;

        if BooleanResult and ExplorerInfo.ShowThumbNailsForFolders then
          ExtractDirectoryPreview(CurrentFile, GUIDParam);
      end;
    end;
    SynchronizeEx(DoStopSearch);
    HideProgress;
    ShowInfo('');
  finally
    Dec(ExplorerUpdateBigImageThreadsCount);
  end;
end;

procedure TExplorerThread.ExtractBigPreview(FileName : string; Rotated : Integer; FileGUID : TGUID);
var
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
  PassWord : String;
  FBit : TBitmap;
  W, H : Integer;
begin
  FileName := ProcessPath(FileName);
  GUIDParam := FileGUID;

  if not FileExistsSafe(FileName) then
    Exit;

  CurrentFile := FileName;

  GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName));
  if GraphicClass = nil then
    Exit;

  Graphic := GraphicClass.Create;
  try
    if GraphicCrypt.ValidCryptGraphicFile(FileName) then
    begin
      PassWord:=DBKernel.FindPasswordForCryptImageFile(FileName);
      if PassWord = '' then
        Exit;

      F(Graphic);
      Graphic := DeCryptGraphicFile(FileName, PassWord);
    end else
    begin
      if Graphic is TRAWImage then
      begin
        if not (Graphic as TRAWImage).LoadThumbnailFromFile(FileName, ExplorerInfo.PictureSize,ExplorerInfo.PictureSize) then
          Graphic.LoadFromFile(FileName);
      end else
        Graphic.LoadFromFile(FileName);
    end;

    FBit := TBitmap.Create;
    try
      FBit.PixelFormat:=pf24bit;
      JPEGScale(Graphic, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize);

      if Min(Graphic.Height, Graphic.Width)>1 then
        LoadImageX(Graphic,Fbit,clWindow);
      F(Graphic);
      TempBitmap := TBitmap.create;
      TempBitmap.PixelFormat := pf24bit;
      W := FBit.Width;
      H := FBit.Height;
      ProportionalSize(ExplorerInfo.PictureSize, ExplorerInfo.PictureSize, W, H);
      TempBitmap.SetSize(W, H);
      DoResize(W, H, FBit, TempBitmap);
    finally
      F(FBit);
    end;
    ApplyRotate(TempBitmap, Rotated);
    BooleanParam := LoadingAllBigImages;

    if not SynchronizeEx(ReplaceImageInExplorerB) then
      F(TempBitmap);
  finally
    F(Graphic);
  end;
end;

procedure TExplorerThread.GetAllFiles;
begin
  if not IsTerminated then
    FFiles := FSender.GetAllItems;
end;

function TExplorerThread.GetThreadID: string;
begin
  Result := 'Explorer';
end;

destructor TExplorerThread.Destroy;
begin
  F(FVisibleFiles);
  F(FFiles);
  F(FUpdaterInfo.FileInfo);
  F(FInfo);
  inherited;
end;

procedure TExplorerThread.DoDefaultSort;
begin
  if not IsTerminated then
  begin
    FSender.NoLockListView := True;
    FSender.DoDefaultSort(FCID);
    FSender.NoLockListView := False;
  end
end;

procedure TExplorerThread.DoStopSearch;
begin
  FSender.DoStopLoading;
end;

procedure TExplorerThread.ExtractImage(Info: TDBPopupMenuInfoRecord; CryptedFile : Boolean; FileID : TGUID);
var
  W, H : integer;
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
  Password : string;
  TempBit : TBitmap;
begin
  if Info.ID = 0 then
  begin
    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(Info.FileName));
    if GraphicClass = nil then
       Exit;

    Graphic := GraphicClass.Create;
    try
      if CryptedFile then
      begin
        IsBigImage := True;
        Info.Crypted := True;
        Password := DBKernel.FindPasswordForCryptImageFile(Info.FileName);
        if Password <> '' then
        begin
          F(Graphic);
          Graphic := DeCryptGraphicFile(Info.FileName, Password);
          if (Graphic <> nil) and not Graphic.Empty then
            Info.PassTag := 1;
        end else
        begin
          Info.PassTag := 0;
        end;
      end else
      begin
        if Graphic is TRAWImage then
        begin
          if not (Graphic as TRAWImage).LoadThumbnailFromFile(Info.FileName, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize) then
            Graphic.LoadFromFile(Info.FileName);
        end else
          Graphic.LoadFromFile(Info.FileName);
        IsBigImage := True;
      end;
      if not ((Info.PassTag = 0) and Info.Crypted) then
      begin
        Info.Width := Graphic.Width;
        Info.Height := Graphic.Height;
        TempBit := TBitmap.create;
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
            DoResize(W, H, TempBit, TempBitmap);
          end;
        finally
          F(TempBit);
        end;
      end else
      begin
        //do nothing - icon rests
        TempBitmap := nil;
      end;
    finally
      F(Graphic);
    end;
  end else //if ID <> 0
  begin
    if not ((Info.PassTag = 0) and Info.Crypted) and not ((Info.Image = nil) or Info.Image.Empty) then
    begin
      TempBitmap := TBitmap.Create;
      AssignJpeg(TempBitmap, Info.Image);
    end else
    begin
      TempBitmap := nil;
      //image -> loaded icon
    end;
  end;
  F(Info.Image);

  if not ((Info.PassTag = 0) and Info.Crypted) then
    ApplyRotate(TempBitmap, Info.Rotation);

  if (FThreadType = THREAD_TYPE_IMAGE) or (FOwnerThreadType = THREAD_TYPE_IMAGE) then
    IsBigImage := False; //сбрасываем флаг для того чтобы перезагрузилась картинка

  GUIDParam := FileID;
  FInfo.Assign(Info);
  if not SynchronizeEx(ReplaceImageInExplorer) then
    F(TempBitmap);
end;

procedure TExplorerThread.DoMultiProcessorTask;
begin
  if Mode = THREAD_PREVIEW_MODE_IMAGE then
    ExtractImage(FInfo, IsCryptedFile, FFileID);

  if Mode = THREAD_PREVIEW_MODE_DIRECTORY then
    ReplaceThumbImageToFolder(FInfo.FileName, FFileID);

  if Mode = THREAD_PREVIEW_MODE_BIG_IMAGE then
     ExtractBigPreview(FInfo.FileName, FInfo.Rotation, FFileID);

  F(FUpdaterInfo.FileInfo);
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
  Result := FThreadType = THREAD_TYPE_THREAD_PREVIEW;
end;

initialization

  UpdaterCount := 0;
  AExplorerFolders := TExplorerFolders.Create;
  FFolderPictureLock := TCriticalSection.Create;

finalization

  F(FFolderPictureLock);
  F(AExplorerFolders);
  F(FullFolderPicture);

end.
