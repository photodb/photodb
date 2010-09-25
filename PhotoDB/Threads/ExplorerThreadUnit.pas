unit ExplorerThreadUnit;

interface

uses
  Jpeg, DB, GraphicEx, ExplorerTypes, ImgList,
  UnitDBKernel, ExplorerUnit, Dolphin_DB, ShellAPI, Windows, ComCtrls,
  Classes, SysUtils, Graphics, Network, Forms, GraphicCrypt, Math,
  Dialogs, Controls, ComObj, ActiveX, ShlObj, CommCtrl, Registry,
  GIFImage, Exif, GraphicsBaseTypes, Win32crc, RAWImage, UnitDBDeclare,
  EasyListview, GraphicsCool, uVistaFuncs, uResources, ImageConverting,
  UnitDBCommonGraphics, UnitDBCommon, UnitCDMappingSupport,
  uThreadEx, uAssociatedIcons, uLogger, uTime, uGOM, uFileUtils,
  UnitExplorerLoadSIngleImageThread, uConstants, uMemory;

type
  TExplorerThread = class(TThreadEx)
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
    FullFolderPicture: TPNGGraphic;
    FSyncEvent: THandle;
  protected
    procedure GetVisibleFiles;
    procedure Execute; override;
    procedure InfoToExplorerForm;
    procedure MakeTempBitmap;
    procedure MakeTempBitmapSmall;
    procedure BeginUpDate;
    procedure EndUpDate;
    Procedure MakeFolderImage(Folder : String);
    procedure FileNeededAW;
    procedure AddDirectoryToExplorer;
    procedure AddDirectoryItemToExplorer;
    procedure AddDirectoryImageToExplorer;
    procedure AddDirectoryIconToExplorer;
    procedure AddImageFileToExplorer;
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
    procedure ExplorerHasIconForExt;
    procedure SetIconForFileByExt;
    procedure ExtractImage(Info : TOneRecordInfo; CryptedFile : Boolean; FileID : TGUID);
    procedure ExtractDirectoryPreview(FileName : string; DirectoryID: TGUID);
    procedure ExtractBigPreview(FileName : string; Rotated : Integer; FileGUID : TGUID);
    procedure ProcessThreadPreviews;
  protected
    function IsVirtualTerminate : Boolean; override;
  public
    FUpdaterInfo : TUpdaterInfo;
    ExplorerInfo : TExplorerViewInfo;
    FInfo : TOneRecordInfo;
    IsCryptedFile : Boolean;
    FFileID : TGUID;
    FThreadPreviewMode : Integer;
    FPreviewInProgress : Boolean;
    FSender : TExplorerForm;
    constructor Create(Folder, Mask: string;
      ThreadType: Integer; Info: TExplorerViewInfo; Sender: TExplorerForm;
      UpdaterInfo: TUpdaterInfo; SID: TGUID);
    property SyncEvent : THandle read FSyncEvent;
  end;

type
  TIconType = (itSmall, itLarge);

  var
      AExplorerFolders : TExplorerFolders = nil;
      UpdaterCount : integer = 0;
      ExplorerUpdateBigImageThreadsCount : integer = 0;

implementation

uses Language, FormManegerUnit, UnitViewerThread, CommonDBSupport, uExplorerThreadPool;

{ TExplorerThread }

Constructor TExplorerThread.Create(Folder,
  Mask: string; ThreadType : Integer; Info: TExplorerViewInfo; Sender : TExplorerForm; UpdaterInfo: TUpdaterInfo; SID : TGUID);
begin
  inherited Create(Sender, SID);
  FThreadType := ThreadType;
  FSender := Sender;
  FFolder := Folder;
  Fmask := Mask;
  FCID := SID;
  ExplorerInfo := Info;
  FShowFiles := True;
  FUpdaterInfo := UpdaterInfo;
  FullFolderPicture := nil;
  FVisibleFiles := nil;
  FEvent := 0;
  FPreviewInProgress := False;
  FThreadPreviewMode := 0;
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
      FEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
      FSyncEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
      TW.I.Start('CreateEvent: ' + IntToStr(FEvent));
      try
        ProcessThreadPreviews;
      finally
        CloseHandle(FEvent);
        CloseHandle(FSyncEvent);
      end;
      Exit;
    end;

    if (FThreadType = THREAD_TYPE_BIG_IMAGES) then
    begin
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

    if (FThreadType=THREAD_TYPE_FILE) then
    begin
      UpdateSimpleFile;
      Exit;
    end;

    if (FThreadType=THREAD_TYPE_FOLDER_UPDATE) then
    begin
      UpdateFolder;
      Exit;
    end;

    ShowInfo(TEXT_MES_INITIALIZATION+'...', 1, 0);
    FFolderBitmap := nil;
    FSelected := nil;

    if (FThreadType=THREAD_TYPE_MY_COMPUTER) then
    begin
     LoadMyComputerFolder;
     SynchronizeEx(DoStopSearch);
     Exit;
    end;

    if (FThreadType=THREAD_TYPE_NETWORK) then
    begin
      LoadNetWorkFolder;
      SynchronizeEx(DoStopSearch);
      Exit;
    end;

    if (FThreadType=THREAD_TYPE_WORKGROUP) then
    begin
      LoadWorkgroupFolder;
      SynchronizeEx(DoStopSearch);
      Exit;
    end;
    if (FThreadType=THREAD_TYPE_COMPUTER) then
    begin
      LoadComputerFolder;
      SynchronizeEx(DoStopSearch);
     Exit;
    end;

    UnformatDir(FFolder);
    if not DirectoryExists(FFolder) then
    begin
      StrParam:=TEXT_MES_ERROR_OPENING_FOLDER;
      SynchronizeEx(ShowMessage_);
      ShowInfo('',1,0);
      SynchronizeEx(ExplorerBack);
      Exit;
    end;

    TW.I.Start('<EXPLORER THREAD>');
    PrivateFiles := TStringList.Create;
    try

      DBFolderToSearch:=FFolder;
      UnProcessPath(DBFolderToSearch);
      DBFolderToSearch:=AnsiLowerCase(DBFolderToSearch);
      UnFormatDir(DBFolderToSearch);
      CalcStringCRC32(AnsiLowerCase(DBFolderToSearch),crc);
      FormatDir(DBFolderToSearch);
      FormatDir(FFolder);
      FFiles:=TExplorerFileInfos.Create;

      DBFolder:=NormalizeDBStringLike(NormalizeDBString(DBFolderToSearch));
      ShowInfo(TEXT_MES_CONNECTING_TO_DB,1,0);
      FQuery := GetQuery;
      try
        ShowInfo(TEXT_MES_GETTING_INFO_FROM_DB,1,0);

        if (GetDBType=DB_TYPE_MDB) and not FolderView then SetSQL(FQuery,'Select * From (Select * from $DB$ where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
        if FolderView then
        begin
         SetSQL(FQuery,'Select * From $DB$ where FolderCRC = :crc');
         s:=FFolder;
         Delete(s,1,Length(ProgramDir));
         UnformatDir(s);
         CalcStringCRC32(AnsiLowerCase(s),crc);
         SetIntParam(FQuery,0,Integer(crc));
        end else
        begin
         SetStrParam(FQuery,0,'%'+DBFolderToSearch+'%');
         SetStrParam(FQuery,1,'%'+DBFolderToSearch+'%\%');
        end;

        for I:=1 to 20 do
        begin
         try
          FQuery.Active:=True;
          Break;
         except
          on e : Exception do
          begin
           EventLog(':TExplorerThread::Execute throw exception: '+e.Message);
           Sleep(DelayExecuteSQLOperation);
          end;
         end;
        end;
        if not FQuery.IsEmpty and not ExplorerInfo.ShowPrivate then
        begin
          FQuery.First;
          for I := 1 to FQuery.RecordCount do
          begin
            if FQuery.FieldByName('Access').AsInteger=db_access_private then
              PrivateFiles.Add(AnsiLowerCase(ExtractFileName(FQuery.FieldByName('FFileName').AsString)));

            FQuery.Next;
          end;
          PrivateFiles.Sort;
        end;

        ShowInfo(TEXT_MES_READING_FOLDER,1,0);
        FilesReadedCount:=0;
        FilesWithoutIcons:=0;
        FE := False;
        EM := False;
        if FMask = '' then FileMask:='*.*' else FileMask:=FMask;
        Found := FindFirst(FFolder + FileMask, faAnyFile, SearchRec);
        while Found = 0 do
        begin
         if IsTerminated then Break;
         try
         if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
         begin
          FA := SearchRec.Attr and FaHidden;
          If ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (FA = 0)) then
          begin
           if not ExplorerInfo.ShowPrivate then
             if PrivateFiles.IndexOf(AnsiLowerCase(SearchRec.Name)) > -1 then
               Continue;

           inc(FilesReadedCount);
           if FilesReadedCount mod 10 = 0 then
             ShowInfo(Format(TEXT_MES_READING_FOLDER_FORMAT,[IntToStr(FilesReadedCount)]),1,0);
           If ExplorerInfo.ShowImageFiles or ExplorerInfo.ShowSimpleFiles then
           begin
            FE:=(SearchRec.Attr and faDirectory=0);
            s:=ExtractFileExt(SearchRec.Name);
            Delete(s,1,1);
            s:='|'+AnsiUpperCase(s)+'|';
            p:=Pos(s, SupportedExt);
            EM:=p<>0;
           end;
           If FShowFiles then
           if ExplorerInfo.ShowSimpleFiles then
           If FE and not EM and ExplorerInfo.ShowSimpleFiles then
           begin
            if FolderView then
            if AnsiLowerCase(SearchRec.Name)='folderdb.ldb' then
             Continue;

            AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_FILE, -1, GetGUID,0,0,0,0,SearchRec.Size,'','','',0,false,true,true);
            Continue;
           end;
           if ExplorerInfo.ShowImageFiles then
           If FE and EM and ExplorerInfo.ShowImageFiles then
           begin
            AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_IMAGE, -1, GetGUID,0,0,0,0,SearchRec.Size,'','','',0,false,false,true);
            Continue;
           end;
           If (SearchRec.Attr and faDirectory<>0) and ExplorerInfo.ShowFolders then
           begin
            AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_FOLDER, -1, GetGUID,0,0,0,0,0,'','','',0,false,true,true);
            Continue;
           end;
          end;
         end;
         finally
          Found := SysUtils.FindNext(SearchRec);
         end;
        end;
        FindClose(SearchRec);
        SynchronizeEx(BeginUpdate);

        ShowInfo(TEXT_MES_LOADING_INFO, 1, 0);
        ShowProgress;
        SynchronizeEx(InfoToExplorerForm);
        ShowInfo(TEXT_MES_LOADING_FOLDERS,FFiles.Count, 0);
        InfoPosition := 0;
        for I := 0 to FFiles.Count - 1 do
        begin
         FFiles[I].Tag:=0;
         If FFiles[I].FileType=EXPLORER_ITEM_FOLDER then
         begin
           if IsTerminated then Break;
           GUIDParam:=FFiles[i].SID;
           Inc(InfoPosition);
           if InfoPosition mod 10 = 0 then
             ShowInfo(InfoPosition);
           CurrentFile := FFiles[i].FileName;
           MakeFolderImage(CurrentFile);
           SynchronizeEx(AddDirectoryToExplorer);
         end;
        end;
        ShowInfo(TEXT_MES_LOADING_IMAGES);
        for I := 0 to FFiles.Count - 1 do
        if FFiles[I].FileType = EXPLORER_ITEM_IMAGE then
        begin
          if IsTerminated then Break;
          GUIDParam:=FFiles[i].SID;
          Inc(InfoPosition);
          if InfoPosition mod 10 = 0 then
            ShowInfo(InfoPosition);
          CurrentFile:=FFiles[i].FileName;
          AddImageFileToExplorer;
        end;
        ShowInfo(TEXT_MES_LOADING_FILES);
        if FShowFiles then
        for I := 0 to FFiles.Count - 1 do
        If FFiles[I].FileType=EXPLORER_ITEM_FILE then
        begin
          If IsTerminated then break;
          GUIDParam:=FFiles[i].SID;
          Inc(InfoPosition);
          if InfoPosition mod 10 = 0 then
            ShowInfo(InfoPosition);
          CurrentFile:=FFiles[i].FileName;
          AddImageFileToExplorer;
          FFiles[i].Tag:=IntIconParam;
        end;
        SynchronizeEx(DoDefaultSort);
        SynchronizeEx(EndUpdate);

        ShowInfo(TEXT_MES_LOADING_TH);
        ShowInfo(FFiles.Count, 0);
        InfoPosition:=0;

        for I := 0 to FFiles.Count - 1 do
        begin
          if IsTerminated then Break;
          if i mod 5 = 0 then
          begin
            TW.I.Start('GetVisibleFiles');
            SynchronizeEx(GetVisibleFiles);
            VisibleUp(i);
            TW.I.Start('GetVisibleFiles - end');
          end;
          Priority := tpNormal;

          if FFiles[i].FileType = EXPLORER_ITEM_IMAGE then
          begin
            Inc(InfoPosition);
            ShowInfo(InfoPosition);
            CurrentFile:=FFiles[i].FileName;
            CurrentInfoPos:=i;
            ReplaceImageItemImage(FFiles[i].FileName, FFiles[i].FileSize, FFiles[i].SID);
          end;

         If ((FFiles[i].FileType=EXPLORER_ITEM_FILE) and (FFiles[i].Tag=1)) then
         begin
          FFiles[i].Tag:=1;
          GUIDParam:=FFiles[i].SID;
          begin
           Inc(InfoPosition);
           ShowInfo(InfoPosition);
           CurrentFile:=FFiles[i].FileName;
           MakeIconForFile;
          end;
         end;

         if ExplorerInfo.View=LV_THUMBS then
         begin
          If FFiles[i].FileType=EXPLORER_ITEM_FOLDER then
          begin
           FFiles[i].Tag:=1;
           GUIDParam:=FFiles[i].SID;
           begin
            Inc(InfoPosition);
            ShowInfo(InfoPosition);
            if ExplorerInfo.ShowThumbNailsForFolders then
              ExtractDirectoryPreview(FFiles[i].FileName, FFiles[i].SID);
             // ReplaceThumbImageToFolder(FFiles[i].FileName);
           end;
          end;
         end else
         begin
          Inc(InfoPosition);
          ShowInfo(InfoPosition);
          CurrentInfoPos:=i;
         end;
        end;

        if (ExplorerInfo.View = LV_THUMBS) and (ExplorerInfo.PictureSize <> ThImageSize) then
          DoLoadBigImages;

        HideProgress;
        ShowInfo('');
        SynchronizeEx(DoStopSearch);
      finally
        FQuery.Close;
        FreeDS(FQuery);
      end;
    finally
      PrivateFiles.Free;
    end;
  finally
    CoUninitialize;
  end;
 // Sleep(1000);
end;

procedure TExplorerThread.BeginUpdate;
begin
  FSender.BeginUpdate;
end;

procedure TExplorerThread.EndUpdate;
begin
  FSender.EndUpdate;
  FSender.Select(FSelected,FCID);
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
  begin
    BooleanResult:=FSender.FileNeededW(GUIDParam);
    if not FSender.Active then
      Priority := tpLowest;
  end;
end;

procedure TExplorerThread.AddDirectoryToExplorer;
begin
  AddDirectoryImageToExplorer;
  AddDirectoryItemToExplorer;
end;

procedure TExplorerThread.AddDriveToExplorer;
begin
  AddDirectoryImageToExplorer;
  AddDirectoryItemToExplorerW;
end;

procedure TExplorerThread.AddDirectoryItemToExplorer;
var
  NewItem: TEasyItem;
  S1, S2 : String;
begin
 NewItem:=FSender.AddItem(GUIDParam);
 S1:=ExplorerInfo.OldFolderName;
 UnformatDir(S1);
 S2:=CurrentFile;
 UnformatDir(S2);
 If AnsiLowerCase(S1)=AnsiLowerCase(S2) then
 begin
  FSelected:=NewItem;
 end;
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
 NewItem:=FSender.AddItemW(DriveNameParam, GUIDParam);
 S1:=ExplorerInfo.OldFolderName;
 UnformatDir(S1);
 S2:=CurrentFile;
 UnformatDir(S2);
 If AnsiLowerCase(S1)=AnsiLowerCase(S2) then
 begin
  FSelected:=NewItem;
 end;
end;

procedure TExplorerThread.AddImageFileToExplorer;
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

  SynchronizeEx(MakeImageWithIcon);
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
    NewItem:=FSender.AddItem(GUIDParam);
    If AnsiLowerCase(ExplorerInfo.OldFolderName)=AnsiLowerCase(CurrentFile) then
      FSelected:=NewItem;
  end;
end;

procedure TExplorerThread.ReplaceImageItemImage(FileName : string; FileSize : Int64; FileID : TGUID);
var
  FBS : TStream;
  CryptedFile : Boolean;
  JPEG : TJpegImage;
begin
  TempBitmap := nil;
  IsBigImage := False;
  CryptedFile := ValidCryptGraphicFile(FileName);

  FInfo := RecordInfoOne(FileName, 0, 0, 0, 0, FileSize, '', '', '', '', '', 0, False, False, 0, CryptedFile, True, False, '');
  FInfo.Tag := EXPLORER_ITEM_FOLDER;

  if not FUpdaterInfo.IsUpdater then
  begin
    if FindInQuery(FileName) then
    begin
      FInfo:=RecordInfoOne(
        FileName,
        fQuery.FieldByName('ID').AsInteger,
        fQuery.FieldByName('Rotated').AsInteger,
        fQuery.FieldByName('Rating').AsInteger,
        fQuery.FieldByName('Access').AsInteger,
        fQuery.FieldByName('FileSize').AsInteger,
        fQuery.FieldByName('Comment').AsString,
        fQuery.FieldByName('KeyWords').AsString,
        fQuery.FieldByName('Owner').AsString,
        fQuery.FieldByName('Collection').AsString,
        fQuery.FieldByName('Groups').AsString,
        fQuery.FieldByName('DateToAdd').AsDateTime,
        fQuery.FieldByName('IsDate').AsBoolean,
        fQuery.FieldByName('IsTime').AsBoolean,
        fQuery.FieldByName('aTime').AsDateTime,
        ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')),
        fQuery.FieldByName('Include').AsBoolean,
        True,
        fQuery.FieldByName('Links').AsString);

      if ExplorerInfo.View = LV_THUMBS then
      begin
        if FInfo.ItemCrypted then
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
            FBS.Free;
          end;
        end;
      end;
    end;
  end else
  begin
    FInfo.Image := TJpegImage.Create;
    try
      GetInfoByFileNameA(CurrentFile, ExplorerInfo.View = LV_THUMBS, FInfo);
    finally
      FreeAndNil(FInfo);
    end;
  end;

  FInfo.Loaded := True;
  FInfo.Tag := EXPLORER_ITEM_IMAGE;

  if not ExplorerInfo.View = LV_THUMBS then
  begin
    SynchronizeEx(ReplaceInfoInExplorer);
    Exit;
  end;

  //Create image from Info!!!
  if ProcessorCount > 1 then
    TExplorerThreadPool.Instance.ExtractImage(Self, FInfo, CryptedFile, FileID)
  else
    ExtractImage(FInfo, CryptedFile, FileID);
end;

procedure TExplorerThread.DrawImageToTempBitmapCenter;
begin
  TempBitmap.Canvas.Draw(ThSize div 2 - GraphicParam.Width div 2, ThSize div 2 - GraphicParam.height div 2, GraphicParam);
end;

procedure TExplorerThread.ReplaceImageInExplorer;
begin
  if not IsTerminated then
  begin
    FSender.SetInfoToItem(FInfo, GUIDParam);
    if TempBitmap <> nil then
      FSender.ReplaceBitmap(TempBitmap, GUIDParam, FInfo.ItemInclude, isBigImage)
  end;
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
Var
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
  FormatDir(CurrentFile);
  fFolderImages.Directory := CurrentFile;
  FFolderImagesResult := AExplorerFolders.GetFolderImages(CurrentFile, SmallImageSize, SmallImageSize);
  FFastDirectoryLoading:=false;
  if FFolderImagesResult.Directory <> '' then
    FFastDirectoryLoading:=True
  else
  begin
    for i := 1 to 4 do
    FFolderImages.Images[i] := nil;
  end;

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
        UnFormatDir(DBFolder);
        CalcStringCRC32(AnsiLowerCase(DBFolder),crc);
        FormatDir(DBFolder);

        Query := GetQuery(False);

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
            if FileExists(Query.FieldByName('FFileName').AsString) then
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
            if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
            begin
              FE := (SearchRec.Attr and faDirectory = 0);
              s := ExtractFileExt(SearchRec.Name);
              Delete(s, 1, 1);
              s:= '|' + AnsiUpperCase(s) + '|';
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
      FFileNames.Free;
      FPrivateFileNames.Free;
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
            FBS.Free;
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
          fbmp.Free;
        end;
      end else
      begin

        GraphicClass := GetGraphicClass(ExtractFileExt(Files[Index]), False);
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
    for i := 1 to 4 do
      fFolderImages.FileNames[i] := FilesInFolder[i];
    for i:=1 to 4 do
      fFolderImages.FileDates[i] := FilesDatesInFolder[i];
    AExplorerFolders.SaveFolderImages(fFolderImages, SmallImageSize, SmallImageSize);
  end;

  GUIDParam := DirctoryID;
  SynchronizeEx(ReplaceFolderImage);
end;

procedure TExplorerThread.DrawFolderImageBig(Bitmap : TBitmap);
var
   Bit32 : TBitmap;
begin
  if not IsTerminated then
  begin
    if FullFolderPicture = nil then
      FullFolderPicture := GetFolderPicture;

   if FullFolderPicture = nil then
     Exit;

   Bit32 := TBitmap.Create;
   try
     LoadPNGImageTransparent(FullFolderPicture, Bit32);
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
Var
  Ext_ : String;
  IsExt_  : Boolean;
  FFiles : TExplorerFileInfos;
begin
 if FolderView then if AnsiLowerCase(ExtractFileName(FUpdaterInfo.FileName))='folderdb.ldb' then exit;

 FFiles := TExplorerFileInfos.Create;
 try
 Ext_:=GetExt(FUpdaterInfo.FileName);
 IsExt_:= ExtInMask(SupportedExt,Ext_);
 If DirectoryExists(FUpdaterInfo.FileName) then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_FOLDER, -1, GetGUID,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,false,true);
 If fileexists(FUpdaterInfo.FileName) and IsExt_ then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_IMAGE, -1, GetGUID,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,ValidCryptGraphicFile(FUpdaterInfo.FileName),true);
 If FShowFiles then
 If fileexists(FUpdaterInfo.FileName) and not IsExt_ then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_FILE, -1, GetGUID,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,false,true);
 if FFiles.Count=0 then exit;
 If FFiles[0].FileType=EXPLORER_ITEM_IMAGE then
  begin
   GUIDParam:=FFiles[0].SID;
   CurrentFile:=FFiles[0].FileName;
   AddImageFileToExplorerW;           //TODO: filesize is undefined
   ReplaceImageItemImage(CUrrentFile, FFiles[0].FileSize, GUIDParam);
  end;
 If FFiles[0].FileType=EXPLORER_ITEM_FILE then
 begin
  GUIDParam:=FFiles[0].SID;
  CurrentFile:=FFiles[0].FileName;
  AddImageFileToExplorerW;
 end;
 If FFiles[0].FileType=EXPLORER_ITEM_FOLDER then
 begin
  GUIDParam:=FFiles[0].SID;
  CurrentFile:=FFiles[0].FileName;
  AddImageFileToExplorerW;
  Sleep(2000); //wait if folder was jast created - it possible that files are currentry in copy-progress...
  try
   if ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View=LV_THUMBS) then
   ReplaceThumbImageToFolder(CurrentFile, GUIDParam);
  except
  end;
 end;
 finally
   F(FFiles);
 end;
end;

procedure TExplorerThread.AddImageFileToExplorerW;
begin
 ficon:=TAIcons.Instance.GetIconByExt(CurrentFile,false, FIcoSize,false);
 if ExplorerInfo.View=LV_THUMBS then
 begin
  MakeTempBitmap;
  IconParam:=ficon;
  SynchronizeEx(DrawImageIcon);
  ficon.free;
 end;
 SynchronizeEx(AddImageFileItemToExplorerW);
end;

procedure TExplorerThread.AddImageFileItemToExplorerW;
begin
  if not IsTerminated then
  begin
    FSender.AddInfoAboutFile(FFiles);
    if ExplorerInfo.View=LV_THUMBS then
    FSender.AddBitmap(TempBitmap, GUIDParam) else
    FSender.AddIcon(ficon, true, GUIDParam);
    if FUpdaterInfo.NewFileItem then
    FSender.SetNewFileNameGUID(GUIDParam);
    FSender.AddItem(GUIDParam,false);
  end;
end;

procedure TExplorerThread.MakeFolderImage(Folder: String);
begin
  FIcon:=TAIcons.Instance.GetIconByExt(Folder,true, FIcoSize,false);
end;

procedure TExplorerThread.MakeTempBitmap;
begin
  TempBitmap := Tbitmap.Create;
  TempBitmap.PixelFormat := Pf24Bit;
  TempBitmap.Width := ExplorerInfo.PictureSize;
  TempBitmap.Height := ExplorerInfo.PictureSize;
end;

procedure TExplorerThread.MakeTempBitmapSmall;
begin
  TempBitmap := Tbitmap.Create;
  TempBitmap.PixelFormat := Pf24Bit;
  TempBitmap.Width := FIcoSize;
  TempBitmap.Height := FIcoSize;
  FillRectNocanvas(TempBitmap, Theme_ListColor);
end;

function TExplorerThread.FindInQuery(FileName: String) : Boolean;
var
  I : integer;
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
      if AnsiLowerCase(AddPathStr+Fquery.FieldByName('FFileName').AsString) = FileName then
      begin
        Result := true;
        Exit;
      end;
      FQuery.Next;
    end;
  end;
end;

procedure TExplorerThread.ShowInfo(StatusText: String);
begin
  SetText:=True;
  SetMax:=false;
  SetPos:=false;
  FInfoText:=StatusText;
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
  ProgressVisible:=True;
  SynchronizeEx(SetProgressVisible);
end;

procedure TExplorerThread.LoadMyComputerFolder;
Var
  i : Integer;
  DS :  TDriveState;
  OldMode: Cardinal;
begin
  HideProgress;
  SynchronizeEx(BeginUpdate);
  ShowInfo(TEXT_MES_READING_MY_COMPUTER, 1, 0);
  FFiles := TExplorerFileInfos.Create;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  for I := Ord('C') to Ord('Z') do
    if (GetDriveType(PChar(Chr(I) + ':\'))=2) or (GetDriveType(PChar(Chr(i)+':\'))=3) or (GetDriveType(PChar(Chr(i)+':\'))=5) then
      AddOneExplorerFileInfo(FFiles, Chr(i)+':\', EXPLORER_ITEM_DRIVE, -1, GetGUID,0,0,0,0,0,'','','',0,false,false,true);

  AddOneExplorerFileInfo(FFiles,TEXT_MES_NETWORK, EXPLORER_ITEM_NETWORK, -1, GetGUID,0,0,0,0,0,'','','',0,false,false,true);
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
      FindIcon(DBKernel.IconDllInstance, 'NETWORK', FIcoSize, 32, IconParam);
      FIcon := IconParam;
      MakeImageWithIcon;
    end;
  end;
 SetErrorMode(oldMode);
 SynchronizeEx(EndUpdate);
 ShowInfo('',1,0);
end;

procedure TExplorerThread.LoadNetWorkFolder;
var
  NetworkList : TStrings;
  I : integer;
begin
  HideProgress;
  SynchronizeEx(BeginUpdate);
  ShowInfo(TEXT_MES_READING_NETWORK,1,0);
  FFiles:=TExplorerFileInfos.Create;
  try
    NetworkList:=TStringList.Create;
    try
      FillNetLevel(nil,NetWorkList);
      for i:=0 to NetworkList.Count-1 do
        AddOneExplorerFileInfo(FFiles,NetworkList[i], EXPLORER_ITEM_WORKGROUP, -1, GetGUID,0,0,0,0,0,'','','',0,false,false,true);
      SynchronizeEx(InfoToExplorerForm);
    finally
      NetworkList.Free;
    end;
    for I := 0 to FFiles.Count - 1 do
    begin
      GUIDParam := FFiles[I].SID;
      CurrentFile := FFiles[I].FileName;

      IconParam := nil;
      FindIcon(DBKernel.IconDllInstance,'WORKGROUP',FIcoSize,32,IconParam);

      fIcon:=IconParam;
      MakeImageWithIcon;

    end;
  finally
    FFiles.Free;
  end;
  SynchronizeEx(EndUpdate);
  ShowInfo('',1,0);
end;

procedure TExplorerThread.MakeImageWithIcon;
begin
  AddImageFileImageToExplorer;
  AddImageFileItemToExplorer;
end;

procedure TExplorerThread.LoadWorkgroupFolder;
var
  ComputerList : TStrings;
  I : integer;
begin
  HideProgress;
  SynchronizeEx(BeginUpdate);
  ShowInfo(TEXT_MES_READING_WORKGROUP,1,0);
  FFiles := TExplorerFileInfos.Create;
  try
    ComputerList:=TStringList.Create;
    try
      if (FindAllComputers(FFolder,ComputerList)<>0) and (ComputerList.Count=0) then
      begin
        StrParam:=TEXT_MES_ERROR_OPENING_WORKGROUP;
        SynchronizeEx(ShowMessage_);
        SynchronizeEx(EndUpdate);
        ShowInfo('',1,0);
        SynchronizeEx(ExplorerBack);
        Exit;
      end;
      for I := 0 to ComputerList.Count - 1 do
        AddOneExplorerFileInfo(FFiles, ComputerList[i], EXPLORER_ITEM_COMPUTER, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '', 0, False, False, True);
      SynchronizeEx(InfoToExplorerForm);
    finally
      ComputerList.Free;
    end;
    for I := 0 to FFiles.Count - 1 do
    begin
     GUIDParam := FFiles[I].SID;
     CurrentFile := FFiles[I].FileName;

     IconParam := nil;
     FindIcon(DBKernel.IconDllInstance,'COMPUTER',FIcoSize,32,IconParam);

     FIcon:=IconParam;
     SynchronizeEx(MakeImageWithIcon);
    end;
  finally
    FFiles.Free;
  end;
  SynchronizeEx(EndUpdate);
  ShowInfo('',1,0);
end;

procedure TExplorerThread.LoadComputerFolder;
var
  ShareList : TStrings;
  I,
  Res : integer;
begin
  HideProgress;
  SynchronizeEx(BeginUpdate);
  ShowInfo(TEXT_MES_READING_COMPUTER, 1, 0);
  FFiles := TExplorerFileInfos.Create;
  try
    ShareList := TStringList.Create;
    try
      Res := FindAllComputers(FFolder, ShareList);
      if (Res <> 0) and (ShareList.Count = 0) then
      begin
        StrParam:=TEXT_MES_ERROR_OPENING_COMPUTER;
        SynchronizeEx(ShowMessage_);
        SynchronizeEx(EndUpdate);
        ShowInfo('',1,0);
        SynchronizeEx(ExplorerBack);
        Exit;
      end;
      for i:=0 to ShareList.Count-1 do
        AddOneExplorerFileInfo(FFiles, ShareList[I], EXPLORER_ITEM_SHARE, -1, GetGUID, 0, 0, 0, 0, 0, '', '', '', 0, False, False, True);
      SynchronizeEx(InfoToExplorerForm);
    finally
      ShareList.Free;
    end;
    for i:=0 to FFiles.Count - 1 do
    begin
      GUIDParam:=FFiles[i].SID;
      CurrentFile := FFiles[i].FileName;

      IconParam:=nil;
      FindIcon(DBKernel.IconDllInstance, 'SHARE', FIcoSize, 32, IconParam);
      FIcon:=IconParam;
      SynchronizeEx(MakeImageWithIcon);
    end;
  finally
    FFiles.Free;
  end;
  SynchronizeEx(EndUpdate);
  ShowInfo('', 1, 0);
end;

procedure TExplorerThread.ShowMessage_;
begin
  MessageBoxDB(FSender.Handle, StrParam, TEXT_MES_ERROR,TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TExplorerThread.ExplorerBack;
begin
  FSender.DoBack;
end;

procedure TExplorerThread.UpdateFile;
var
  Folder : string;
  crc : Cardinal;
begin
 if FUpdaterInfo.ID<>0 then
 UpdateImageRecord(FFolder,FUpdaterInfo.ID);
 FQuery:=GetQuery;
 UnProcessPath(FFolder);
 if FolderView then FFolder:=ExtractFileName(FFolder);


  Folder:=GetDirectory(FFolder);
  UnFormatDir(Folder);
  CalcStringCRC32(AnsiLowerCase(Folder),crc);

  SetSQL(fQuery,'SELECT * FROM $DB$ WHERE FolderCRC = '+IntToStr(GetPathCRC(FFolder))+' AND FFileName LIKE :FFileName');


 SetStrParam(FQuery,0,'%'+normalizeDBStringLike(NormalizeDBString(AnsiLowercase(FFolder)))+'%');
 try
  FQuery.Active:=True;
 except
 end;
 FFiles:=TExplorerFileInfos.Create;
 try
 AddOneExplorerFileInfo(FFiles,FFolder, EXPLORER_ITEM_IMAGE, -1, StringToGUID(Fmask){GetCID},0,0,0,0,GetFileSizeByName(FFolder),'','','',0,false,false,true);
 if FQuery.RecordCount>0 then
 begin
  FFiles[0].Rotate:=FQuery.FieldByName('Rotated').AsInteger;
 end;
 GUIDParam:=FFiles[0].SID;
 if FolderView then CurrentFile:=ProgramDir+FFiles[0].FileName else
 CurrentFile:=FFiles[0].FileName;
 if ExplorerInfo.ShowThumbNailsForImages then
 ReplaceImageItemImage(FFiles[0].FileName, -1, GUIDParam); //todo: filesize is undefined
 if FUpdaterInfo.ID<>0 then
 SynchronizeEx(ChangeIDImage);
 IntParam:=FUpdaterInfo.ID;
 SynchronizeEx(EndUpdateID);
 FreeDS(FQuery);

 DoLoadBigImages;

 finally
   FFiles.Free;
 end;
 if FInfo.ItemId<>0 then
   if Assigned(FUpdaterInfo.ProcHelpAfterUpdate) then
     SynchronizeEx(DoUpdaterHelpProc);
end;

function TExplorerThread.ShowFileIfHidden(FileName :String): boolean;
var
  fa : integer;
begin
 Result:=false;
 fa:=FileGetAttr(FileName);
 fa:=fa and FaHidden;
 If ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (fa=0)) then
 Result:=true;
end;

procedure TExplorerThread.ReplaceImageInExplorerB;
begin
  if TempBitmap <> nil then
  begin
    FSender.ReplaceBitmap(TempBitmap, GUIDParam, True, BooleanParam)
  end else
    FSender.ReplaceIcon(FIcon, GUIDParam, true);
end;

procedure TExplorerThread.MakeIconForFile;
begin
  TempBitmap := nil;
  FIcon := TAIcons.Instance.GetIconByExt(CurrentFile, False, FIcoSize, False);
  SynchronizeEx(ReplaceImageInExplorerB);
end;

procedure TExplorerThread.UpdateSimpleFile;
begin
 StringParam:=Fmask;
// SynchronizeEx(FileNeeded);
// If BooleanResult then
 begin
  CurrentFile:=FFolder;
  MakeIconForFile;
 end;
end;

procedure TExplorerThread.ChangeIDImage;
var
  EventInfo : TEventValues;
begin
 EventInfo.Image:=nil;
 DBKernel.DoIDEvent(self,FUpdaterInfo.ID,[EventID_Param_Image],EventInfo);
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
  AddOneExplorerFileInfo(FFiles,FFolder, EXPLORER_ITEM_FOLDER, -1, StringToGUID(Fmask), 0,0,0,0,0,'','','',0,false,false,true);
  GUIDParam:=FFiles[0].SID;
  CurrentFile:=FFiles[0].FileName;
  fMask:=SupportedExt;
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
  if FVisibleFiles <> nil then
    FVisibleFiles.Free;
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
  i, InfoPosition : integer;
begin
  while ExplorerUpdateBigImageThreadsCount > ProcessorCount do
    Sleep(10);

  Inc(ExplorerUpdateBigImageThreadsCount);

  try
    if LoadingAllBigImages then
      SynchronizeEx(GetAllFiles);

    ShowInfo(TEXT_MES_LOADING_BIG_IMAGES);
    ShowInfo(FFiles.Count ,0);
    InfoPosition:=0;

    for I := 0 to FFiles.Count - 1 do
    begin

      Inc(InfoPosition);
      ShowInfo(InfoPosition);

      if I mod 5 = 0 then
      begin
       SynchronizeEx(GetVisibleFiles);
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
            TExplorerThreadPool.Instance.ExtractBigImage(Self, FFiles[i].FileName, FFiles[i].Rotate, GUIDParam)
          else
            ExtractBigPreview(CurrentFile, FFiles[i].Rotate, GUIDParam);
        end;
      end;


      //directories
      if FFiles[i].FileType=EXPLORER_ITEM_FOLDER then
      begin
        BooleanResult := False;
        SynchronizeEx(FileNeededAW);
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

  if not FileExists(FileName) then
    Exit;

  CurrentFile := FileName;

  GraphicClass := GetGraphicClass(ExtractFileExt(FileName), False);
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
        LoadImageX(Graphic,Fbit,Theme_ListColor);
      F(Graphic);
      TempBitmap := TBitmap.create;
      TempBitmap.PixelFormat := pf24bit;
      W := FBit.Width;
      H := FBit.Height;
      ProportionalSize(ExplorerInfo.PictureSize, ExplorerInfo.PictureSize, W, H);
      TempBitmap.Width := W;
      TempBitmap.Height := H;
      DoResize(W, H, FBit, TempBitmap);
    finally
      F(FBit);
    end;
    ApplyRotate(TempBitmap, Rotated);
    BooleanParam := LoadingAllBigImages;
    SynchronizeEx(ReplaceImageInExplorerB);
  finally
    F(Graphic);
  end;
end;

procedure TExplorerThread.GetAllFiles;
begin
  if not IsTerminated then
    FFiles:=FSender.GetAllItems;
end;

procedure TExplorerThread.DoDefaultSort;
begin
  if not IsTerminated then
  begin
    FSender.NoLockListView:=true;
    FSender.DoDefaultSort(FCID);
    FSender.NoLockListView:=false;
  end
end;

procedure TExplorerThread.ExplorerHasIconForExt;
begin
  BooleanParam:=FSender.ExitstExtInIcons(GetExt(CurrentFile));
end;

procedure TExplorerThread.SetIconForFileByExt;
begin
  FSender.AddIconByExt(GetExt(CurrentFile),IconParam);
end;

procedure TExplorerThread.DoStopSearch;
begin
  FSender.DoStopLoading;
end;

procedure TExplorerThread.ExtractImage(Info: TOneRecordInfo; CryptedFile : Boolean; FileID : TGUID);
var
  W, H : integer;
  Graphic : TGraphic;
  GraphicClass : TGraphicClass;
  Password : string;
  TempBit, Fbit : TBitmap;
begin
  if Info.ItemId = 0 then
  begin
    GraphicClass := GetGraphicClass(ExtractFileExt(Info.ItemFileName), False);
    if GraphicClass = nil then
       Exit;

    Graphic := GraphicClass.Create;
    try
      if CryptedFile then
      begin
        IsBigImage := True;
        Info.ItemCrypted := True;
        Password := DBKernel.FindPasswordForCryptImageFile(Info.ItemFileName);
        if Password <> '' then
        begin
          F(Graphic);
          Graphic := DeCryptGraphicFile(Info.ItemFileName, Password);
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
          if not (Graphic as TRAWImage).LoadThumbnailFromFile(Info.ItemFileName, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize) then
            Graphic.LoadFromFile(Info.ItemFileName);
        end else
          Graphic.LoadFromFile(Info.ItemFileName);
        IsBigImage := True;
      end;
      if not ((Info.PassTag = 0) and Info.ItemCrypted) then
      begin
        TempBit := TBitmap.create;
        try
          TempBit.PixelFormat := pf24bit;
          JPEGScale(Graphic, ExplorerInfo.PictureSize, ExplorerInfo.PictureSize);
          LoadImageX(Graphic, TempBit, Theme_ListColor);
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
          TempBit.Free;
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
    if not ((Info.PassTag = 0) and Info.ItemCrypted) and not Info.Image.Empty then
    begin
      TempBitmap := TBitmap.Create;
      AssignJpeg(TempBitmap, Info.Image);
    end else
    begin
      Fbit := TBitmap.Create;
      try
        Fbit.PixelFormat := pf24bit;
        GraphicParam := TAIcons.Instance.GetIconByExt(Info.ItemFileName, False, FIcoSize, False);
        try
          MakeTempBitmap;
          SynchronizeEx(DrawImageToTempBitmapCenter);
        finally
          F(GraphicParam);
        end;
      finally
        F(FBit);
      end;
    end;
  end;
  F(Info.Image);

  if not ((Info.PassTag = 0) and Info.ItemCrypted) then
    ApplyRotate(TempBitmap, Info.ItemRotate);

  if FThreadType = THREAD_TYPE_IMAGE then
    IsBigImage := False; //сбрасываем флаг для того чтобы перезагрузилась картинка

  GUIDParam := FileID;
  SynchronizeEx(ReplaceImageInExplorer);
end;

procedure TExplorerThread.ProcessThreadPreviews;
begin
  FPreviewInProgress := True;
  while True do
  begin
    IsTerminated := False;
    try
      try
        try
          if FThreadPreviewMode = THREAD_PREVIEW_MODE_IMAGE then
            ExtractImage(FInfo, IsCryptedFile, FFileID);

          if FThreadPreviewMode = THREAD_PREVIEW_MODE_DIRECTORY then
            ReplaceThumbImageToFolder(FInfo.ItemFileName, FFileID);

          if FThreadPreviewMode = THREAD_PREVIEW_MODE_BIG_IMAGE then
             ExtractBigPreview(FInfo.ItemFileName, FInfo.ItemRotate, FFileID);

          FThreadPreviewMode := 0;

          TW.I.Start('UnRegisterSubThread: ' + IntToStr(FEvent));
          if GOM.IsObj(ParentThread) then
            ParentThread.UnRegisterSubThread(Self);
        except
          on e : Exception do
            EventLog('TExplorerThread.ProcessThreadImages' + e.Message);
        end;
      finally
        TW.I.Start('SetEvent: ' + IntToStr(FEvent));
        FPreviewInProgress := False;
        SetEvent(FEvent);
      end;
    finally
      TW.I.Start('Suspended: ' + IntToStr(FEvent));
      WaitForSingleObject(FSyncEvent, INFINITE);
      TW.I.Start('Resumed: ' + IntToStr(FEvent));
      FPreviewInProgress := True;
    end;
  end;
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

 UpdaterCount:=0;

finalization

 FreeAndNil(AExplorerFolders);

end.
