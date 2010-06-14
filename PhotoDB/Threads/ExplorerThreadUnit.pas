unit ExplorerThreadUnit;

interface

 {$DEFINE EASYLISTVIEW}

uses
 ThreadManeger, Jpeg, DB, DBTables, GraphicEx, ExplorerTypes, ImgList,
 UnitDBKernel, ExplorerUnit, Dolphin_DB, ShellAPI, windows, ComCtrls,
 Classes, SysUtils, Graphics, Network, Forms, GraphicCrypt, Math,
 Dialogs, Controls, ComObj, ActiveX, ShlObj,CommCtrl, Registry,
 GIFImage, Exif, GraphicsBaseTypes, win32crc, RAWImage,  UnitDBDeclare,
 EasyListview, GraphicsCool, uVistaFuncs, VirtualSystemImageLists,
 UnitDBCommonGraphics, UnitDBCommon, UnitCDMappingSupport;

type
 TExplorerViewInfo = record
 ShowPrivate : boolean;
 ShowFolders : boolean;
 ShowSimpleFiles : boolean;
 ShowImageFiles : boolean;
 ShowHiddenFiles : boolean;
 ShowAttributes : Boolean;
 ShowThumbNailsForFolders : boolean;
 SaveThumbNailsForFolders : boolean;
 ShowThumbNailsForImages : boolean;
 OldFolderName : String;
 View : integer;
 PictureSize : integer;
 end;

Type TUpdaterInfo = record
 FileName : String;
 IsUpdater : Boolean;
 ID : integer;
 ProcHelpAfterUpdate : TNotifyEvent;
 NewFileItem : Boolean;
 end;

type
  TExplorerThread = class(TThread)
  private
  FFolder : String;
  Fmask : String;
  ficon : ticon;
  FSender : TExplorerForm;
  FCID : string;
  TempBitmap : TBitmap;
  fbmp : tbitmap;
  FPic : TPicture;
  ExplorerInfo : TExplorerViewInfo;

    {$IFNDEF EASYLISTVIEW}
  FSelected : TListItem;
    {$ENDIF}
    {$IFDEF EASYLISTVIEW}  
  FSelected : TEasyItem;
    {$ENDIF}

  FFolderBitmap : TBitmap;
  FFolderBitmapCash : TBitmap;
  FolderImageRect : TRect;
  fFolderImages : TFolderImages;
  FcountOfFolderImage : Integer;
  fFastDirectoryLoading : Boolean;
  FFiles : TExplorerFilesInfo;
  Info : TOneRecordInfo;
  BooleanResult : Boolean;
  IntParam : integer;
  BooleanParam : Boolean;
  StringParam : String;
  CurrentFile : String;
  IconParam : TIcon;
  GraphicParam : TGraphic;
  FShowFiles : Boolean;
  FUpdaterInfo : TUpdaterInfo;
  FQuery : TDataSet;
  NoRecords : Boolean;
  IsCurrentRecord : Boolean;
  FInfoText : String;
  FInfoMax : integer;
  FInfoPosition : Integer;
  SetText, Setmax, SetPos : Boolean;
  ProgressVisible : Boolean;
  DriveNameParam : String;
  FThreadType : Integer;
  StrParam : String;
  PassParam : String;
  FIcoSize : integer;
  FilesWithoutIcons, IntIconParam : Integer;
  CountOfShowenGraphicFiles : Integer;
  CurrentInfoPos : Integer;
  FVisibleFiles : TArStrings;
  InvalidThread : boolean;      
  IsBigImage : boolean;
  LoadingAllBigImages : boolean;
   { Private declarations }
  protected
    procedure GetVisibleFiles;
    procedure RegisterThread;
    procedure UnRegisterThread;
    procedure Execute; override;
    procedure InfoToExplorerForm;
    procedure MakeTempBitmap;
    procedure MakeTempBitmapSmall;
    procedure FillRect;
    procedure BeginUpDate;
    procedure EndUpDate;
    Procedure MakeFolderImage(Folder : String);
    Procedure FileNeeded;
    procedure FileNeededA;   
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
    procedure ReplaceImageItemImage;
    procedure DrawImageToTempBitmap;
    procedure ReplaceImageInExplorer;   
    procedure ReplaceInfoInExplorer;
    procedure ReplaceThumbImageToFolder;
    Procedure MakeFolderBitmap;
    Procedure DrawFolderImageBig;
    procedure DrawFolderImageWithXY;
    procedure ReplaceFolderImage;
    procedure AddFileToExplorer;
    procedure AddFile;
    procedure AddImageFileToExplorerW;
    procedure AddImageFileItemToExplorerW;
    procedure FindInQuery(FileName : String);
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
    procedure FindPassword;
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
    procedure DoVerifyExplorer;
  public
    constructor Create(CreateSuspennded: Boolean; folder, Mask: string;
      ThreadType: Integer; Info: TExplorerViewInfo; Sender: TExplorerForm;
      UpdaterInfo: TUpdaterInfo; SID: string);
  end;

  type TAssociatedIcons = record
    Icon : TIcon;
    Ext : String;
    SelfIcon : Boolean;
    Size : integer;
  end;

  Type

  TAIcons = class(TObject)
  private
   FAssociatedIcons : array of TAssociatedIcons;
   FIDesktopFolder: IShellFolder;
   UnLoadingListEXT : TArStrings;
   FVirtualSysImages : VirtualSysImages;
  public

   Constructor Create;
   Destructor Destroy; Override;
  published
   function IsExt(Ext : string; Size : integer): boolean;
   function AddIconByExt(FileName, EXT : string; Size : integer) : integer;
   function GetIconByExt(FileName : String; IsFolder : boolean; Size : integer; Default : boolean) : TIcon;
   function SetPath(const Value: string) : PItemIDList;
   function GetShellImage(Path : String; Size : integer): TIcon;
   function IsVarIcon(FileName : String; Size : integer): boolean;
   Procedure Clear;
   Procedure Initialize;
  end;

  type
  TIconType = (itSmall, itLarge);

  var AIcons : TAIcons;
      AExplorerFolders : TExplorerFolders;
      ASession : TSession;
      UpdaterCount : integer = 0;
      ExplorerUpdateBigImageThreadsCount : integer = 0;

  

  UpdatesCountLimit : integer = 2;

  const fGlobalSm = 1;

procedure FindIcon(hLib :cardinal; NameRes :string; Size, ColorDepth :Byte; var Icon :TIcon);
function VarIco(Ext : string) : boolean;

implementation

uses Language, FormManegerUnit, UnitViewerThread, CommonDBSupport;

{ TExplorerThread }

Constructor TExplorerThread.Create(CreateSuspennded: Boolean; folder,
  Mask: string; ThreadType : Integer; Info: TExplorerViewInfo; Sender : TExplorerForm; UpdaterInfo: TUpdaterInfo; SID : string);
begin
 inherited Create(True);
 FThreadType:= ThreadType;
 FSender:=Sender;
 FFolder := Folder;
 Fmask := Mask;
 FCID:=SID;
 ExplorerInfo:= Info;
 FShowFiles := True;
 FUpdaterInfo := UpdaterInfo;
 If not CreateSuspennded then Resume;
end;

procedure TExplorerThread.Execute;
Var
 Found, FilesReadedCount  : integer;
 SearchRec : TSearchRec;
 i : integer;
 DBFolder, DBFolderToSearch, FileMask : String;
 InfoPosition : Integer;
 ImageFiles : Integer;
 Folders : integer;
 PrivateFiles : TArStrings;
 fa : Integer;
 FE, EM : Boolean;
 crc : cardinal;

 s : string;
 p : PansiChar;
 Function IsStringInTArStrings(Strings : TArStrings; Str : String) : Boolean;
 var
   j:integer;
 begin
  Str:=AnsiLowerCase(Str);
  Result:=False;
  For j:=0 to length(Strings)-1 do
  if AnsiLowerCase(Strings[j])=AnsiLowerCase(Str) then
  begin
   Result:=true;
   Break;
  end;
 end;
 
begin
 CoInitialize(nil);
 Synchronize(RegisterThread);
 IsCurrentRecord:=false;
 CountOfShowenGraphicFiles:=0;
 NoRecords:=false;
 FreeOnTerminate:=true;
 LoadingAllBigImages:=true;

 Case ExplorerInfo.View of
  LV_THUMBS     : begin FIcoSize:=48; end;
  LV_ICONS      : begin FIcoSize:=32; end;
  LV_SMALLICONS : begin FIcoSize:=16; end;
  LV_TITLES     : begin FIcoSize:=16; end;
  LV_TILE       : begin FIcoSize:=48; end;
  LV_GRID       : begin FIcoSize:=32; end;
  end;

 If FUpdaterInfo.IsUpdater then
 begin
  AddFile;
  CoUninitialize;
  Exit;
 end;
       
 if (FThreadType=THREAD_TYPE_BIG_IMAGES) then
 begin     
  ShowProgress;
  DoLoadBigImages;
  Synchronize(UnRegisterThread);
  CoUninitialize;
  Exit;
 end;

 if (FThreadType=THREAD_TYPE_IMAGE) then
 begin
  if UpdaterCount>UpdatesCountLimit then
  begin
   Repeat
    if UpdaterCount<UpdatesCountLimit then break;
    Sleep(100);
   Until false;
  end;
  inc(UpdaterCount);
  try
   LoadingAllBigImages:=false; //грузятся не все файлы заново а только текущий
   UpdateFile;
   CoUninitialize;
  except
  end;
  Dec(UpdaterCount);
  Exit;
 end;
 if (FThreadType=THREAD_TYPE_FILE) then
 begin
  UpdateSimpleFile;
  CoUninitialize;
  Exit;
 end;
 if (FThreadType=THREAD_TYPE_FOLDER_UPDATE) then
 begin
  UpdateFolder;
  CoUninitialize;
  Exit;
 end;
 
  ShowInfo(TEXT_MES_INITIALIZATION+'...',1,0);
  FFolderBitmap:=nil;
  FFolderBitmapCash:=nil;
  FSelected:=nil;
  if (FThreadType=THREAD_TYPE_MY_COMPUTER) then
  begin
   LoadMyComputerFolder;
   Synchronize(DoStopSearch);
   CoUninitialize;
   Exit;
  end;
  if (FThreadType=THREAD_TYPE_NETWORK) then
  begin
   LoadNetWorkFolder;
   Synchronize(DoStopSearch);
   CoUninitialize;
   Exit;
  end;
  if (FThreadType=THREAD_TYPE_WORKGROUP) then
  begin
   LoadWorkgroupFolder;    
   Synchronize(DoStopSearch);
   CoUninitialize;
   Exit;
  end;
  if (FThreadType=THREAD_TYPE_COMPUTER) then
  begin
   LoadComputerFolder;   
   Synchronize(DoStopSearch);
   CoUninitialize;
   Exit;
  end;
  UnformatDir(FFolder);
  if not DirectoryExists(FFolder) then
  begin
   StrParam:=TEXT_MES_ERROR_OPENING_FOLDER;
   Synchronize(ShowMessage_);
   Synchronize(EndUpdate);
   ShowInfo('',1,0);
   Synchronize(ExplorerBack);
   Synchronize(UnRegisterThread);
   CoUninitialize;
   Exit;
  end;

  DBFolderToSearch:=FFolder;
  UnProcessPath(DBFolderToSearch);
  DBFolderToSearch:=AnsiLowerCase(DBFolderToSearch);
  UnFormatDir(DBFolderToSearch);
  CalcStringCRC32(AnsiLowerCase(DBFolderToSearch),crc);
  FormatDir(DBFolderToSearch);                                    
  FormatDir(FFolder);
  Synchronize(BeginUpdate);
  FFiles:=SetNilExplorerFileInfo;

  DBFolder:=NormalizeDBStringLike(NormalizeDBString(normalizeDBFileNameString(DBFolderToSearch)));
  ShowInfo(TEXT_MES_CONNECTING_TO_DB,1,0);
  FQuery:=GetQuery;         
  ShowInfo(TEXT_MES_GETTING_INFO_FROM_DB,1,0);

  if (GetDBType=DB_TYPE_BDE) and not FolderView then SetSQL(FQuery,'Select * From '+GetDefDBname+' where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
  if (GetDBType=DB_TYPE_MDB) and not FolderView then SetSQL(FQuery,'Select * From (Select * from '+GetDefDBname+' where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
  if FolderView then
  begin
   SetSQL(FQuery,'Select * From '+GetDefDBname+' where FolderCRC = :crc');
   s:=FFolder;
   Delete(s,1,Length(ProgramDir));
   UnformatDir(s);
   CalcStringCRC32(AnsiLowerCase(s),crc);
   SetIntParam(FQuery,0,Integer(crc));
  end else
  begin
   SetStrParam(FQuery,0,'%'+DBFolderToSearch+'%');
   SetStrParam(FQuery,1,'%'+DBFolderToSearch+normalizeDBFileNameString('%\%'));
  end;
  for i:=1 to 20 do
  begin
   try
    FQuery.Active:=True;
    break;
   except
    on e : Exception do
    begin
     EventLog(':TExplorerThread::Execute throw exception: '+e.Message);
     Sleep(300);
    end;
   end;
  end;
  If not ExplorerInfo.ShowPrivate then
  If FQuery.RecordCount<>0 then
  begin
   SetLength(PrivateFiles,0);
   FQuery.First;
   For i:=1 to FQuery.RecordCount do
   begin
    If FQuery.FieldByName('Access').AsInteger=db_access_private then
    begin
     SetLength(PrivateFiles,Length(PrivateFiles)+1);
     PrivateFiles[Length(PrivateFiles)-1]:=FQuery.FieldByName('FFileName').AsString;
    end;
    FQuery.Next;
   end;
  end;
  If FQuery.RecordCount=0 then NoRecords:=true;
  if FMask='' then FileMask:='*.*' else FileMask:=FMask;
  Found := FindFirst(FFolder+FileMask, faAnyFile, SearchRec);
  ShowInfo(TEXT_MES_READING_FOLDER,1,0);
  FilesReadedCount:=0;
  FilesWithoutIcons:=0;
  FE:=false;
  EM:=false;
  while Found = 0 do
  begin
   If not ExplorerManager.IsExplorer(FSender) then break;
   if FSender.CurrentGUID<>FCID then break;
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin     
    fa:=SearchRec.Attr and FaHidden;
    If ExplorerInfo.ShowHiddenFiles or (not ExplorerInfo.ShowHiddenFiles and (fa=0)) then
    begin
     If not ExplorerInfo.ShowPrivate then
     If Length(PrivateFiles)<>0 then
     If IsStringInTArStrings(PrivateFiles,FFolder+SearchRec.Name) then
     begin
      Found := SysUtils.FindNext(SearchRec);
      Continue;
     end;
     inc(FilesReadedCount);
     ShowInfo(Format(TEXT_MES_READING_FOLDER_FORMAT,[IntToStr(FilesReadedCount)]),1,0);
     If ExplorerInfo.ShowImageFiles or ExplorerInfo.ShowSimpleFiles then
     begin
      FE:=(SearchRec.Attr and faDirectory=0);
      s:=ExtractFileExt(SearchRec.Name);
      Delete(s,1,1);
      s:='|'+UpcaseAll(s)+'|';
      p:=StrPos(PChar(SupportedExt),PChar(s));
      EM:=p<>nil;
     end;
     If FShowFiles then
     if ExplorerInfo.ShowSimpleFiles then
     If FE and not EM and ExplorerInfo.ShowSimpleFiles then
     begin
      if FolderView then
      if AnsiLowerCase(SearchRec.Name)='folderdb.ldb' then
      begin
       Found := SysUtils.FindNext(SearchRec);
       Continue;
      end;
      AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_FILE, -1, GetCid,0,0,0,0,SearchRec.Size,'','','',0,false,true,true);
      Found := SysUtils.FindNext(SearchRec);
      Continue;
     end;
     if ExplorerInfo.ShowImageFiles then
     If FE and EM and ExplorerInfo.ShowImageFiles then
     begin
      AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_IMAGE, -1, GetCid,0,0,0,0,SearchRec.Size,'','','',0,false,false{ValidCryptGraphicFileA(FFolder+SearchRec.Name)},true);
      Found := SysUtils.FindNext(SearchRec);
      Continue;
     end;
     If (SearchRec.Attr and faDirectory<>0) and ExplorerInfo.ShowFolders then
     begin
      AddOneExplorerFileInfo(FFiles,FFolder+SearchRec.Name, EXPLORER_ITEM_FOLDER, -1, GetCid,0,0,0,0,0{SearchRec.Size},'','','',0,false,true,true);
      Found := SysUtils.FindNext(SearchRec);
      Continue;
     end;  
    end;   
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  ShowInfo(TEXT_MES_LOADING_INFO,1,0);
  ShowProgress;
  Synchronize(InfoToExplorerForm);
  ShowInfo(TEXT_MES_LOADING_FOLDERS,Length(FFiles),0);
  InfoPosition:=0;
  Folders:=0;
  for i:=0 to Length(FFiles)-1 do
  begin
   FFiles[i].Tag:=0;
   If FFiles[i].FileType=EXPLORER_ITEM_FOLDER then
   begin
    if i mod 10=0 then
    begin
     Synchronize(DoVerifyExplorer);
     if not BooleanResult then break;
    end;
    StringParam:=FFiles[i].SID;
    Synchronize(FileNeeded);
    If BooleanResult then
    begin
     Inc(Folders);
     Inc(InfoPosition); 
     if i mod 10=0 then
     ShowInfo(InfoPosition);
     CurrentFile := FFiles[i].FileName;
     MakeFolderImage(CurrentFile);
     AddDirectoryToExplorer;
    end;
   end;
  end;
  ShowInfo(TEXT_MES_LOADING_IMAGES);
  ImageFiles:=0;
  For i:=0 to Length(FFiles)-1 do
  If FFiles[i].FileType=EXPLORER_ITEM_IMAGE then
  begin
   if i mod 10=0  then
   If not ExplorerManager.IsExplorer(FSender) then break;
   StringParam:=FFiles[i].SID;
   Synchronize(FileNeeded);
   If BooleanResult then
   Begin
    inc(ImageFiles);
    Inc(InfoPosition);
    if i mod 10=0 then
    ShowInfo(InfoPosition);
    CurrentFile:=FFiles[i].FileName;
    AddImageFileToExplorer;
   End;
  end;
  ShowInfo(TEXT_MES_LOADING_FILES);
  If FShowFiles then
  For i:=0 to Length(FFiles)-1 do
  If FFiles[i].FileType=EXPLORER_ITEM_FILE then
  begin
   If not ExplorerManager.IsExplorer(FSender) then break;
   StringParam:=FFiles[i].SID;
   Synchronize(FileNeeded);
   If BooleanResult then
   begin
    Inc(InfoPosition);
    ShowInfo(InfoPosition);
    CurrentFile:=FFiles[i].FileName;
    AddImageFileToExplorer;
    FFiles[i].Tag:=IntIconParam;
   end;
  end;            
  Synchronize(DoDefaultSort);
  Synchronize(EndUpdate);

  ShowInfo(TEXT_MES_LOADING_TH);
  ShowInfo(Length(FFiles),0);
  InfoPosition:=0;

  for i:=0 to Length(FFiles)-1 do
  begin

   if i mod 5=0 then
   begin
    Synchronize(GetVisibleFiles);
    VisibleUp(i);
    Sleep(5);
   end;


   If FFiles[i].FileType=EXPLORER_ITEM_IMAGE then
   begin
    If not ExplorerManager.IsExplorer(FSender) then break;
    StringParam:=FFiles[i].SID;
    Synchronize(FileNeededA);
    If BooleanResult then
    begin
     Inc(InfoPosition);
     ShowInfo(InfoPosition);
     CurrentFile:=FFiles[i].FileName;
     CurrentInfoPos:=i;

     ReplaceImageItemImage;
    end;
    Priority:=tpNormal;
   end;


   If ((FFiles[i].FileType=EXPLORER_ITEM_FILE) and (FFiles[i].Tag=1)) then
   begin
    FFiles[i].Tag:=1;
    If not ExplorerManager.IsExplorer(FSender) then break;
    StringParam:=FFiles[i].SID;
    Synchronize(FileNeededA);
    If BooleanResult then
    begin
     Inc(InfoPosition);
     ShowInfo(InfoPosition);
     CurrentFile:=FFiles[i].FileName;
     MakeIconForFile;
    end;
    Priority:=tpNormal;
   end;

   if ExplorerInfo.View=LV_THUMBS then
   begin
    If FFiles[i].FileType=EXPLORER_ITEM_FOLDER then
    begin
     FFiles[i].Tag:=1;
     If not ExplorerManager.IsExplorer(FSender) then break;
     StringParam:=FFiles[i].SID;
     Synchronize(FileNeededA);
     If BooleanResult then
     begin
      Inc(InfoPosition);
      ShowInfo(InfoPosition);
      CurrentFile:=FFiles[i].FileName;
      if ExplorerInfo.ShowThumbNailsForFolders then
      try
       ReplaceThumbImageToFolder;
      except
      end;
     end;
     Priority:=tpNormal;
    end;
   end else
   begin
    Inc(InfoPosition);
    ShowInfo(InfoPosition);
    CurrentInfoPos:=i;
    Priority:=tpNormal;
   end;

  end;

  //XXX
  if ExplorerInfo.View=LV_THUMBS then
  if ExplorerInfo.PictureSize<>ThImageSize then
  DoLoadBigImages;

  HideProgress;
  ShowInfo('');
  Synchronize(DoStopSearch);
  FQuery.Close;
  FreeDS(FQuery);
  Synchronize(UnRegisterThread);
  CoUninitialize;
end;

procedure TExplorerThread.FillRect;
begin
 FillRectToBitmap(TempBitmap);
end;

procedure TExplorerThread.Beginupdate;
begin
 If ExplorerManager.IsExplorer(FSender) then
 FSender.BeginUpdate(FCID);
end;

procedure TExplorerThread.EndUpdate;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.EndUpdate(FCID);
  FSender.Select(FSelected,FCID);
  AExplorerFolders.CheckFolder(FFolder);
 end;
end;

procedure TExplorerThread.MakeFolderBitmap;
begin
 FFolderBitmap:=TBitmap.create;

 FFolderBitmap.PixelFormat:=pf24bit;
 FFolderBitmap.Width:=FIcoSize;
 FFolderBitmap.Height:=FIcoSize;
 FFolderBitmap.Canvas.Brush.Color:=Theme_ListColor;
 FFolderBitmap.Canvas.Pen.Color:=Theme_ListColor;
 FillRectNoCanvas(FFolderBitmap,Theme_ListColor);
 FFolderBitmap.Canvas.Draw(0,0,fIcon);

end;

procedure TExplorerThread.InfoToExplorerForm;
begin
 If ExplorerManager.IsExplorer(FSender) then
 FSender.LoadInfoAboutFiles(FFiles,FCID);
end;

procedure TExplorerThread.FileNeededA;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  BooleanResult:=FSender.FileNeeded(StringParam);
  if not FSender.Active then Priority:=tpLowest;
 end;
end;

procedure TExplorerThread.FileNeededAW;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  BooleanResult:=FSender.FileNeededW(StringParam);
  InvalidThread:=FSender.CurrentGUID<>FCID;
  if not FSender.Active then Priority:=tpLowest;
 end;
end;

procedure TExplorerThread.FileNeeded;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  BooleanResult:=FSender.FileNeeded(StringParam);
 end;
end;

procedure TExplorerThread.AddDirectoryToExplorer;
begin
 Synchronize(AddDirectoryImageToExplorer);
 Synchronize(AddDirectoryItemToExplorer);
end;

procedure TExplorerThread.AddDriveToExplorer;
begin
 Synchronize(AddDirectoryImageToExplorer);
 Synchronize(AddDirectoryItemToExplorerW);
end;

procedure TExplorerThread.AddDirectoryItemToExplorer;
var

    {$IFNDEF EASYLISTVIEW}
   NewItem: TListItem;
    {$ENDIF}
    {$IFDEF EASYLISTVIEW}
   NewItem: TEasyItem;
    {$ENDIF}

  S1, S2 : String;
begin
 NewItem:=FSender.AddItem(StringParam);
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
 If ExplorerManager.IsExplorer(FSender) then
 begin
  if ExplorerInfo.View=LV_THUMBS then
  FSender.AddBitmap(FFolderBitmap, StringParam) else
  FSender.AddIcon(fIcon,true,StringParam);
 end
end;

procedure TExplorerThread.AddDirectoryItemToExplorerW;
var
  {$IFNDEF EASYLISTVIEW}
  NewItem : TListItem;
  {$ENDIF}
  {$IFDEF EASYLISTVIEW}
  NewItem : TEasyItem;
  {$ENDIF}
  S1, S2 : String;
begin
 NewItem:=FSender.AddItemW(DriveNameParam,StringParam);
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
  b : boolean;
begin
 b:=false;
 EXT := AnsiLowerCase(ExtractFileExt(CurrentFile));
 IntIconParam:=0;
 if (EXT='.exe') or (EXT='.scr') then
 begin
  b:=true;
  ficon:=AIcons.GetIconByExt('file.exe',false,FIcoSize,true);
  inc(FilesWithoutIcons);
  IntIconParam:=1;
 end else
 begin
  if AIcons.IsVarIcon(CurrentFile, FIcoSize) then
  begin
   b:=true;
   ficon:=AIcons.GetIconByExt('file.___',false,FIcoSize,true);
   inc(FilesWithoutIcons);
   IntIconParam:=1;
  end;
 end;
 if not b then
  begin
  if not SafeMode then
  ficon:=AIcons.GetIconByExt(CurrentFile,false, FIcoSize,false) else
  begin
   ficon:=TIcon.Create;
   ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
  end;
 end;

 if ExplorerInfo.View=LV_THUMBS then
 begin
  MakeTempBitmapSmall;
  IconParam:=ficon;
  Synchronize(DrawImageIconSmall);
//  Synchronize(SetIconForFileByExt);
  ficon.free;
 end;

 Synchronize(AddImageFileImageToExplorer);
 Synchronize(AddImageFileItemToExplorer);
end;

procedure TExplorerThread.DrawImageIcon;
begin
 if IconParam<>nil then
 TempBitmap.Canvas.Draw(ExplorerInfo.PictureSize div 2-FIcoSize div 2,ExplorerInfo.PictureSize div 2-FIcoSize div 2,IconParam);
end;

procedure TExplorerThread.DrawImageIconSmall;
begin
 if IconParam<>nil then
 TempBitmap.Canvas.Draw(0,0,IconParam);
end;

procedure TExplorerThread.AddImageFileImageToExplorer;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  if ExplorerInfo.View=LV_THUMBS then
  FSender.AddBitmap(TempBitmap, StringParam) else
  FSender.AddIcon(fIcon,true,StringParam);
 end;
end;

procedure TExplorerThread.AddIconFileImageToExplorer;
begin
 If ExplorerManager.IsExplorer(FSender) then
 FSender.AddIcon(FIcon, True, StringParam);
end;

procedure TExplorerThread.AddImageFileItemToExplorer;
Var
  {$IFNDEF EASYLISTVIEW}
  NewItem : TListItem;
  {$ENDIF}
  {$IFDEF EASYLISTVIEW}
  NewItem : TEasyItem;
  {$ENDIF}
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  NewItem:=FSender.AddItem(StringParam);
  If AnsiLowerCase(ExplorerInfo.OldFolderName)=AnsiLowerCase(CurrentFile) then
  begin
   FSelected:=NewItem;
  end;
 end;
end;

procedure TExplorerThread.ReplaceImageItemImage;
var
  TempBit, Fbit : TBitmap;
  w, h : integer;
  FBS : TStream;
  Crypted : boolean;
begin
  TempBitmap:=nil;
  IsBigImage:=false;
  Crypted:=ValidCryptGraphicFile(CurrentFile);

  Info:=RecordInfoOne(CurrentFile,0,0,0,0,FFiles[CurrentInfoPos].FileSize,'','','','','',0,false,false,0,Crypted,true,false,'');
  Info.Tag:=0;
  If not FUpdaterInfo.IsUpdater then
  begin
   If not NoRecords then
   begin
    FindInQuery(CurrentFile);
    If IsCurrentRecord then
    begin
     Info:=RecordInfoOne(fQuery.FieldByName('FFileName').AsString,fQuery.FieldByName('ID').AsInteger,fQuery.FieldByName('Rotated').AsInteger,fQuery.FieldByName('Rating').AsInteger, fQuery.FieldByName('Access').AsInteger, fQuery.FieldByName('FileSize').AsInteger,fQuery.FieldByName('Comment').AsString,fQuery.FieldByName('KeyWords').AsString, fQuery.FieldByName('Owner').AsString, fQuery.FieldByName('Collection').AsString, fQuery.FieldByName('Groups').AsString, fQuery.FieldByName('DateToAdd').AsDateTime, fQuery.FieldByName('IsDate').AsBoolean, fQuery.FieldByName('IsTime').AsBoolean, fQuery.FieldByName('aTime').AsDateTime,ValidCryptBlobStreamJPG(fQuery.FieldByName('thum')),fQuery.FieldByName('Include').AsBoolean,true,fQuery.FieldByName('Links').AsString);

      if (ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View=LV_THUMBS)) then
      begin
      if TBlobField(fQuery.FieldByName('thum'))=nil then begin FreeDS(fQuery); exit; end;
      info.ItemCrypted:=ValidCryptBlobStreamJPG(fQuery.FieldByName('thum'));
      if info.ItemCrypted then
      begin
       Info.Image:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),DBkernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'))) as TJpegImage;
       if Info.Image<>nil then Info.PassTag:=1;
      end else
      begin
       Info.Image:=TJpegImage.Create;
       FBS:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
       inc(CountOfShowenGraphicFiles);
       try
        if FBS.Size<>0 then
        Info.Image.loadfromStream(FBS) else
       except
       end;
       FBS.Free;
      end;
     end;
    end;
   end;
   if ValidCryptGraphicFile(CurrentFile) then Info.ItemCrypted:=true;
  end else
  begin
   Info:=GetInfoByFileNameA(CurrentFile,(ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View=LV_THUMBS)));
   if FUpdaterInfo.IsUpdater then
   Info.ItemSize:=FFiles[CurrentInfoPos].FileSize;
  end;
  Info.Loaded:=true;
  Info.Tag:=EXPLORER_ITEM_IMAGE;
  Info.ItemFileName:=CurrentFile;

  if not (ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View=LV_THUMBS)) then
  begin
   Synchronize(ReplaceInfoInExplorer);  
   Exit;
  end;

  FPic:=nil;
  If Info.ItemId=0 then
  begin
   If FileExists(CurrentFile) then
   Fpic:=Tpicture.Create
   else
   begin
    if TempBitmap<>nil then TempBitmap.Free;
    exit;
   end;
   try
    if ValidCryptGraphicFile(CurrentFile) then
    begin      
     IsBigImage:=true;
     Info.ItemCrypted:=true;
     PassParam:=CurrentFile;
     Synchronize(FindPassword);
     if PassParam<>'' then
     begin
      Fpic.Graphic:=DeCryptGraphicFile(CurrentFile,PassParam);
      Info.PassTag:=1;
     end else
     begin
      Info.PassTag:=0;
     end;
    end else
    begin
     if IsRAWImageFile(CurrentFile) then
     begin
      Fpic.Graphic:=TRAWImage.Create;
      if not (Fpic.Graphic as TRAWImage).LoadThumbnailFromFile(CurrentFile) then
      Fpic.Graphic.LoadFromFile(CurrentFile);
     end else
     Fpic.LoadFromFile(CurrentFile);
     IsBigImage:=true;
    end;
   except
    Fpic.Free;
    TempBitmap.Free;
    exit;
   end;
   if not ((Info.PassTag=0) and Info.ItemCrypted) then
   begin
    TempBit:=TBitmap.create;
    //XXX JPEGScale(Fpic.Graphic,100,100);
    JPEGScale(Fpic.Graphic,ExplorerInfo.PictureSize,ExplorerInfo.PictureSize);
    if Min(Fpic.Height,Fpic.Width)>1 then
    try
     LoadImageX(Fpic.Graphic,TempBit,Theme_ListColor);
    except
    end;    
    inc(CountOfShowenGraphicFiles);
    Fpic.Free;
    TempBit.PixelFormat:=pf24bit;
    w:=TempBit.Width;
    h:=TempBit.Height;
    Fbit:=TBitmap.create;
    Fbit.PixelFormat:=pf24bit;
    If Max(w,h)<ThImageSize then Fbit.Assign(TempBit) else
    begin

     ProportionalSize(ExplorerInfo.PictureSize,ExplorerInfo.PictureSize,w,h);
     try
      DoResize(w,h,TempBit,Fbit);
     except
     end;
    end;
    TempBit.Free;

    TempBitmap:=Fbit;
    Fbit:=nil;

   end else
   begin
    if FPic<>nil then Fpic.Free;
    Fbit:=TBitmap.create;
    Fbit.PixelFormat:=pf24bit;
    if not SafeMode then
    ficon:=AIcons.GetIconByExt(CurrentFile,false, FIcoSize,false) else
    begin
     ficon:=TIcon.Create;
     ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
    end;

    if ExplorerInfo.View=LV_THUMBS then
    begin
     if TempBitmap=nil then MakeTempBitmap;
     IconParam:=ficon;
     Synchronize(DrawImageIcon);
     ficon.free;
     GraphicParam:=Fbit;
    end;

    synchronize(DrawImageToTempBitmap);
    Fbit.free;
   end;
  end else
  begin
   if not ((Info.PassTag=0) and Info.ItemCrypted) then
   begin
    if TempBitmap=nil then MakeTempBitmap;
    TempBitmap.Assign(Info.Image);
    Info.Image.Free;
   end else
   begin
    if FPic<>nil then Fpic.Free;
    Fbit:=TBitmap.create;
    Fbit.PixelFormat:=pf24bit;
    if not SafeMode then
    ficon:=AIcons.GetIconByExt(CurrentFile,false, FIcoSize,false) else
    begin
     ficon:=TIcon.Create;
     ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
    end;
    IconParam:=ficon;  
    if TempBitmap=nil then MakeTempBitmap;
    Synchronize(DrawImageIcon);
    ficon.free;
    GraphicParam:=Fbit;
    synchronize(DrawImageToTempBitmap);
    Fbit.free;
   end;
  end;
  if not ((Info.PassTag=0) and Info.ItemCrypted) then
  begin
   case Info.ItemRotate of
    DB_IMAGE_ROTATED_90  :  Rotate90A(TempBitmap);
    DB_IMAGE_ROTATED_180 :  Rotate180A(TempBitmap);
    DB_IMAGE_ROTATED_270 :  Rotate270A(TempBitmap);
   end;
  end;
  
  if FThreadType=THREAD_TYPE_IMAGE then IsBigImage:=false; //сбрасываем флаг для того чтобы перезагрузилась картинка
  Synchronize(ReplaceImageInExplorer);
  if Info.PassTag=1 then inc(CountOfShowenGraphicFiles);
end;

procedure TExplorerThread.DrawImageToTempBitmap;
begin
 TempBitmap.Canvas.Draw(ThSize div 2-GraphicParam.Width div 2,ThSize div 2-GraphicParam.height div 2,GraphicParam);
end;

procedure TExplorerThread.ReplaceImageInExplorer;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.SetInfoToItem(Info,StringParam);
  if FSender.CurrentGUID=FCID then
  begin
   if not isBigImage then
   FSender.ReplaceBitmap(TempBitmap,StringParam,Info.ItemInclude) else
   FSender.ReplaceBitmap(TempBitmap,StringParam,Info.ItemInclude,true);
  end;
 end;
end;

procedure TExplorerThread.ReplaceInfoInExplorer;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.SetInfoToItem(Info,StringParam);
 end;
end;

procedure TExplorerThread.ReplaceImageInExplorerA;
begin
 If ExplorerManager.IsExplorer(FSender) then
 FSender.SetInfoToItem(Info,StringParam);
end;

procedure TExplorerThread.ReplaceThumbImageToFolder;
Var
  Found, Count, Dx, i, j, x, y, w, h, ps, index : integer;
  SearchRec : TSearchRec;
  Files : Array[1..4] of string;
  bmp : TBitmap;
  FFolderImagesResult : TFolderImages;
  FFastDirectoryLoading, OK : Boolean;
  Pic : TPicture;
  Query : TDataSet;
  RecNos : array[1..4] of integer;
  FilesInFolder : array[1..4] of string;
  FilesDatesInFolder : array[1..4] of TDateTime;
  CountFilesInFolder : Integer;
  FFileNames, FPrivateFileNames : array of string;
  DBFolder, Password : String;
  RecCount, SmallImageSize, deltax,deltay,_x,_y : Integer;
  fbs : TStream;
  fJpeg : TJpegImage;
  Nbr : Integer;
  c:Integer;
  FE, EM : boolean;
  s : string;
  p : PAnsiChar;
  crc : Cardinal;

  function FileInFiles(FileName : String) : Boolean;
  var
    ii : Integer;
  begin
   Result:=false;
   For ii:=0 to Length(FFileNames)-1 do
   if AnsiLowerCase(FFileNames[ii])=AnsiLowerCase(FileName) then
   begin
    Result:=True;
    Break;
   end;
  end;

  function FileInPrivateFiles(FileName : String) : Boolean;
  var
    ii : Integer;
  begin
   Result:=false;
   For ii:=0 to Length(FPrivateFileNames)-1 do
   if AnsiLowerCase(FPrivateFileNames[ii])=AnsiLowerCase(FileName) then
   begin
    Result:=True;
    Break;
   end;
  end;

  Procedure AddFileInFolder(FileName : String);
  begin
   inc(CountFilesInFolder);
   if CountFilesInFolder<5 then
   begin
    FilesInFolder[CountFilesInFolder]:=FileName;
    FilesDatesInFolder[CountFilesInFolder]:=GetFileDateTime(FileName);
   end;
  end;

begin          
 ps:=ExplorerInfo.PictureSize;
 _y:=Round((564-68)*ps/1200);
 SmallImageSize:=Round(_y/1.05);
 CountFilesInFolder:=0;
 for i:=1 to 4 do
 FilesInFolder[i]:='';
 FormatDir(CurrentFile);
 fFolderImages.Directory:=CurrentFile;
 FFolderImagesResult:=AExplorerFolders.GetFolderImages(CurrentFile,SmallImageSize,SmallImageSize);
 FFastDirectoryLoading:=false;
 If FFolderImagesResult.Directory<>'' then
 FFastDirectoryLoading:=True else
 begin
  for i:=1 to 4 do
  FFolderImages.Images[i]:=nil;
 end;
 Query:=nil;
 Count:=0;    
 Nbr:=0;
 if not FFastDirectoryLoading then
 begin
  DBFolder:=NormalizeDBStringLike(NormalizeDBString(NormalizeDBFileNameString(AnsiLowerCase(CurrentFile))));
  UnFormatDir(DBFolder);
  CalcStringCRC32(AnsiLowerCase(DBFolder),crc);
  FormatDir(DBFolder);

  Query := GetQuery;
  Query.Active:=false;
  if GetDBType=DB_TYPE_BDE then SetSQL(Query,'Select  FFileName,Access,thum,Rotated From '+GetDefDBname+' where (FFileName Like :FolderA) and not (FFileName like :FolderB) ');
  if GetDBType=DB_TYPE_MDB then SetSQL(Query,'Select  FFileName,Access,thum,Rotated From (Select * from '+GetDefDBname+' where FolderCRC='+inttostr(Integer(crc))+') where (FFileName Like :FolderA) and not (FFileName like :FolderB) ');
  SetStrParam(Query,0,'%'+DBFolder+'%');             //(top 4)
  SetStrParam(Query,1,'%'+DBFolder+normalizeDBFileNameString('%\%'));

  try
  Query.Active:=true;
  except
   FreeDS(Query);
   exit;
  end;
  SetLength(FFileNames,0);
  SetLength(FPrivateFileNames,0);
  for i:=1 to 4 do
  begin
   RecNos[i]:=0;
  end;
  RecCount:=Query.RecordCount;
  If RecCount<>0 then
  begin
   Query.First;
   For i:=1 to RecCount do
   begin
    if Query.FieldByName('Access').AsInteger=db_access_private then
    begin
     SetLength(FPrivateFileNames,Length(FPrivateFileNames)+1);
     FPrivateFileNames[Length(FPrivateFileNames)-1]:=Query.FieldByName('FFileName').AsString;
    end;
    if (Query.FieldByName('Access').AsInteger<>db_access_private) or ExplorerInfo.ShowPrivate then
    if FileExists(Query.FieldByName('FFileName').AsString) then
    if ShowFileIfHidden(Query.FieldByName('FFileName').AsString) then
    begin
     OK:=true;
     if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
     if DBkernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'))='' then OK:=false;
     if OK then
     begin
      if Nbr<4 then
      begin
       inc(Nbr);
       RecNos[Nbr]:=Query.RecNo;
       FilesInFolder[Nbr]:=Query.FieldByName('FFileName').AsString;
       SetLength(FFileNames,Length(FFileNames)+1);
       FFileNames[Length(FFileNames)-1]:=Query.FieldByName('FFileName').AsString;
       AddFileInFolder(Query.FieldByName('FFileName').AsString);
      end;
     end;
    end;
    Query.Next;
   end;
  end;
  if Nbr<4 then
  begin
   Found := FindFirst(CurrentFile+'*.*', faAnyFile, SearchRec);
   while Found = 0 do
   begin
    if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
    begin

     FE:=(SearchRec.Attr and faDirectory=0);
     s:=ExtractFileExt(SearchRec.Name);
     Delete(s,1,1);
     s:='|'+UpcaseAll(s)+'|';
     p:=StrPos(PChar(SupportedExt),PChar(s));
     EM:=p<>nil;

     If FE and EM and not FileInFiles(CurrentFile+SearchRec.Name) and not (FileInPrivateFiles(CurrentFile+SearchRec.Name) and not ExplorerInfo.ShowPrivate) then
     if ShowFileIfHidden(CurrentFile+SearchRec.Name) then
     begin
      OK:=true;
      if ValidCryptGraphicFile(CurrentFile+SearchRec.Name) then
      if DBkernel.FindPasswordForCryptImageFile(CurrentFile+SearchRec.Name)='' then OK:=false;
      if OK then
      begin
       Inc(Count);
       Files[Count]:=CurrentFile+SearchRec.Name;
       AddFileInFolder(CurrentFile+SearchRec.Name);
       FilesInFolder[Count+Nbr]:=CurrentFile+SearchRec.Name;
       If Count+Nbr>3 then Break;
      end;
     end;
    end;
    Found := sysutils.FindNext(SearchRec);
   end;
   FindClose(SearchRec);
  end;
  If Count+Nbr=0 then
  begin
   FreeDS(Query);
   exit;
  end;
 end;
 Dx:=4;
 MakeTempBitmap;
 Synchronize(FillRect);
 try
  Synchronize(DrawFolderImageBig);
 except
 end;
 c:=0;
 try
 For i:=1 to 2 do
 For j:=1 to 2 do
 begin
  Index:=(i-1)*2+j;
  FcountOfFolderImage:=Index;
  // 34  68
  // 562 564
  // 600 600
  deltax:=Round(34*ps/600);
  deltay:=Round(68*ps/600);
  _x:=Round((562-34)*ps/1200);
  _y:=Round((564-68)*ps/1200);
  SmallImageSize:=Round(_y/1.05);

  x:=(j-1)*_x+deltax;
  y:=(i-1)*_y+deltay;
  If fFastDirectoryLoading then
  begin
   if FFolderImagesResult.Images[Index]=nil then break;
   fbmp:=FFolderImagesResult.Images[Index];
   w:=fbmp.Width;
   h:=fbmp.Height;
   ProportionalSize(SmallImageSize,SmallImageSize,w,h);

   FolderImageRect:=Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h);
   synchronize(DrawFolderImageWithXY);
   Continue;
  end;
  if index>count+Nbr then break;
  if index>count then
  begin
   inc(c);
   Query.RecNo:=RecNos[c];
   fJpeg:=nil;
   if TBlobField(Query.FieldByName('thum'))=nil then
   begin
    Continue;
   end;
   if ValidCryptBlobStreamJPG(Query.FieldByName('thum')) then
   begin
    Password:=DBKernel.FindPasswordForCryptBlobStream(Query.FieldByName('thum'));
    if Password<>'' then FJPEG:=DeCryptBlobStreamJPG(Query.FieldByName('thum'),Password) as TJPEGImage else
    begin
     Continue;
    end;
   end else
   begin
    FJPEG:=TJpegImage.Create;
    FBS:= GetBlobStream(Query.FieldByName('thum'),bmRead);
    try
     if FBS.Size<>0 then
     FJPEG.loadfromStream(fbs) else
    except
    end;
    FBS.Free;
   end;
   fbmp := TBitmap.create;
   JPEGScale(fJpeg,SmallImageSize,SmallImageSize);
   fbmp.Assign(fJpeg);
   fJpeg.Free;
   fbmp.PixelFormat:=pf24bit;
   case Query.FieldByName('Rotated').AsInteger of
    DB_IMAGE_ROTATED_90  :  Rotate90A(fbmp);
    DB_IMAGE_ROTATED_180 :  Rotate180A(fbmp);
    DB_IMAGE_ROTATED_270 :  Rotate270A(fbmp);
   end;
   w:=fbmp.Width;
   h:=fbmp.Height;
   ProportionalSize(SmallImageSize,SmallImageSize,w,h);
   FolderImageRect:=Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h);
   synchronize(DrawFolderImageWithXY);
   fbmp.Free;
   Query.Next;
  end else begin
   pic:=Tpicture.create;
   if ValidCryptGraphicFile(Files[Index]) then
   begin
    Password:=DBkernel.FindPasswordForCryptImageFile(Files[Index]);
    if Password<>'' then pic.Graphic:=DeCryptGraphicFile(Files[Index],Password) else
    begin
     pic.Free;
     Continue;
    end;
   end else
   begin
    try

     if IsRAWImageFile(Files[Index]) then
     begin
      pic.Graphic:=TRAWImage.Create;
      if not (pic.Graphic as TRAWImage).LoadThumbnailFromFile(Files[Index]) then
      pic.Graphic.LoadFromFile(Files[Index]);
     end else
     pic.LoadFromFile(Files[Index]);

    except
     pic.Free;
     Continue;
    end;
   end;    
   _y:=Round((564-68)*ps/1200);
   SmallImageSize:=Round(_y/1.05);
   JPEGScale(pic.Graphic,SmallImageSize,SmallImageSize);
   w:=pic.Width;
   h:=pic.Height;
   ProportionalSize(SmallImageSize,SmallImageSize,w,h);   
   FolderImageRect:=Rect(_x div 2- w div 2+x,_y div 2-h div 2+y,_x div 2- w div 2+x+w,_y div 2-h div 2+y+h);
   bmp := TBitmap.create;
   bmp.Assign(pic.Graphic);
   pic.Free;
   bmp.PixelFormat:=pf24bit;
   fbmp:=TBitmap.create;
   fbmp.PixelFormat:=pf24bit;
   DoResize(w,h,bmp,fbmp);
   bmp.Free;
   Synchronize(DrawFolderImageWithXY);
   fbmp.free;
  end;
 end;
 if Query<>nil then
 begin
  Query.close;
  FreeDS(Query);
 end;
 except
 end;
 try
  if not FFastDirectoryLoading then
  if ExplorerInfo.SaveThumbNailsForFolders then
  begin
   for i:=1 to 4 do
   fFolderImages.FileNames[i]:=FilesInFolder[i];
   for i:=1 to 4 do
   fFolderImages.FileDates[i]:=FilesDatesInFolder[i];
   AExplorerFolders.SaveFolderImages(fFolderImages,SmallImageSize,SmallImageSize);
  end;
  Synchronize(ReplaceFolderImage);
 except
 end;
// TempBitmap.free;
end;

procedure TExplorerThread.DrawFolderImageBig;
var
   Pic : TPicture;
   bit32 : TBitmap;
begin
 Pic:=nil;
 If ExplorerManager.IsExplorer(FSender) then
 begin
  Pic:=GetFolderPicture;
  if pic = nil then exit;

  bit32:=TBitmap.Create;
  LoadPNGImage32bit(Pic.Graphic as TPNGGraphic,bit32,Theme_ListColor);
  Pic.free;
  StretchCoolW(0,0,ExplorerInfo.PictureSize,ExplorerInfo.PictureSize,Rect(0,0,bit32.Width,bit32.Height),bit32,TempBitmap);
  bit32.Free;
 end;
end;

procedure TExplorerThread.DrawFolderImageWithXY;
begin
 If not fFastDirectoryLoading then
 if ExplorerInfo.SaveThumbNailsForFolders then
 begin
  fFolderImages.Images[FcountOfFolderImage]:=TBitmap.create;
  fFolderImages.Images[FcountOfFolderImage].Assign(fbmp);
 end;
 If info.ItemAccess=db_access_private then
 begin
  If not DBKernel.UserRights.ShowPrivate then
  begin
   DrawIconEx(TempBitmap.Canvas.Handle,FolderImageRect.Left,FolderImageRect.Top,UnitDBKernel.icons[DB_IC_KEY+1].Handle,32,32,1,0,DI_NORMAL);
   exit;
  end;
 end;
 TempBitmap.Canvas.StretchDraw(FolderImageRect,fbmp);
end;

procedure TExplorerThread.ReplaceFolderImage;
begin
 If ExplorerManager.IsExplorer(FSender) then   
 if FSender.CurrentGUID=FCID then
 FSender.ReplaceBitmap(TempBitmap,StringParam,true);
end;

procedure TExplorerThread.AddFileToExplorer;
begin

end;

procedure TExplorerThread.AddFile;
Var
  Ext_ : String;
  IsExt_  : Boolean;
begin
 if FolderView then if AnsiLowerCase(ExtractFileName(FUpdaterInfo.FileName))='folderdb.ldb' then exit;

 FFiles:=SetNilExplorerFileInfo;
 Ext_:=GetExt(FUpdaterInfo.FileName);
 IsExt_:= ExtInMask(SupportedExt,Ext_);
 If DirectoryExists(FUpdaterInfo.FileName) then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_FOLDER, -1, GetCid,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,false,true);
 If fileexists(FUpdaterInfo.FileName) and IsExt_ then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_IMAGE, -1, GetCid,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,ValidCryptGraphicFile(FUpdaterInfo.FileName),true);
 If FShowFiles then
 If fileexists(FUpdaterInfo.FileName) and not IsExt_ then
 AddOneExplorerFileInfo(FFiles,FUpdaterInfo.FileName, EXPLORER_ITEM_FILE, -1, GetCid,0,0,0,0,GetFileSizeByName(FUpdaterInfo.FileName),'','','',0,false,false,true);
 if Length(FFiles)=0 then exit;
 If FFiles[0].FileType=EXPLORER_ITEM_IMAGE then
  begin
   StringParam:=FFiles[0].SID;
   CurrentFile:=FFiles[0].FileName;
   AddImageFileToExplorerW;
   ReplaceImageItemImage;
  end;
 If FFiles[0].FileType=EXPLORER_ITEM_FILE then
 begin
  StringParam:=FFiles[0].SID;
  CurrentFile:=FFiles[0].FileName;
  AddImageFileToExplorerW;
 end;
 If FFiles[0].FileType=EXPLORER_ITEM_FOLDER then
 begin
  StringParam:=FFiles[0].SID;
  CurrentFile:=FFiles[0].FileName;
  AddImageFileToExplorerW;
  Sleep(5000);
  try
   if ExplorerInfo.ShowThumbNailsForFolders and (ExplorerInfo.View=LV_THUMBS) then
   ReplaceThumbImageToFolder;
  except
  end;
 end;
end;

procedure TExplorerThread.AddImageFileToExplorerW;
begin
 if not SafeMode then ficon:=AIcons.GetIconByExt(CurrentFile,false, FIcoSize,false) else
 begin
  ficon:=TIcon.Create;
  ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
 end;
 if ExplorerInfo.View=LV_THUMBS then
 begin
  MakeTempBitmap;
  IconParam:=ficon;
  Synchronize(DrawImageIcon);
  ficon.free;
 end;
 Synchronize(AddImageFileItemToExplorerW);
end;

procedure TExplorerThread.AddImageFileItemToExplorerW;
begin
 if ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.AddInfoAboutFile(FFiles,FCID);
  if ExplorerInfo.View=LV_THUMBS then
  FSender.AddBitmap(TempBitmap, StringParam) else
  FSender.AddIcon(ficon, true, StringParam);
  if FUpdaterInfo.NewFileItem then
  FSender.SetNewFileNameGUID(StringParam,FCID);
  FSender.AddItem(StringParam,false);
 end;
end;

procedure TExplorerThread.MakeFolderImage(Folder: String);
begin
  if not SafeMode then
  ficon:=AIcons.GetIconByExt(Folder,true, FIcoSize,false) else
  begin
   ficon:=TIcon.Create;
   ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
  end;
  if ExplorerInfo.View=LV_THUMBS then
  begin
   Synchronize(MakeFolderBitmap);
   ficon.Free;
  end else
  begin
   //icon present and its all!
  end;
end;

procedure TExplorerThread.MakeTempBitmap;
begin
 TempBitmap:=Tbitmap.Create;
 TempBitmap.Width:=ExplorerInfo.PictureSize;
 TempBitmap.Height:=ExplorerInfo.PictureSize;
 TempBitmap.PixelFormat:=pf24Bit;
 TempBitmap.Canvas.Brush.Color:=Theme_ListColor;
 TempBitmap.Canvas.Pen.Color:=Theme_ListColor;
end;

procedure TExplorerThread.MakeTempBitmapSmall;
begin
 TempBitmap:=Tbitmap.Create;
 TempBitmap.Width:=FIcoSize;
 TempBitmap.Height:=FIcoSize;
 TempBitmap.PixelFormat:=pf24Bit;
 TempBitmap.Canvas.Brush.Color:=Theme_ListColor;
 TempBitmap.Canvas.Pen.Color:=Theme_ListColor;
 FillRectNocanvas(TempBitmap,Theme_ListColor);
end;

procedure TExplorerThread.FindInQuery(FileName: String);
Var
  i : integer;
  AddPathStr : string;
begin
 IsCurrentRecord:=false;
 Fquery.First;
 UnProcessPath(FileName);
 FileName:=AnsiLowerCase(FileName);
 if FolderView then AddPathStr:=ProgramDir else AddPathStr:='';
 For i:=1 to Fquery.RecordCount do
 begin
  if AnsiLowerCase(AddPathStr+Fquery.FieldByName('FFileName').AsString)=FileName then
  begin
   IsCurrentRecord:=true;
   Break;
  end;
 Fquery.Next;
 end;
end;

procedure TExplorerThread.ShowInfo(StatusText: String);
begin
  SetText:=True;
  SetMax:=false;
  SetPos:=false;
  FInfoText:=StatusText;
  Synchronize(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(Max, Value: Integer);
begin
  SetText:=false;
  SetMax:=True;
  SetPos:=True;
  FInfoMax := Max;
  FInfoPosition := Value;
  Synchronize(SetInfoToStatusBar);
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
  Synchronize(SetInfoToStatusBar);
end;

procedure TExplorerThread.ShowInfo(Pos: Integer);
begin
  SetText:=False;
  SetMax:=False;
  SetPos:=True;
  FInfoPosition := Pos;
  Synchronize(SetInfoToStatusBar);
end;

procedure TExplorerThread.SetInfoToStatusBar;
begin
 If SetText then
 If ExplorerManager.IsExplorer(FSender) then
 FSender.SetStatusText(FInfoText,FCID);
 If Setmax then
 If ExplorerManager.IsExplorer(FSender) then
 FSender.SetProgressMax(FInfoMax,FCID);
 If SetPos Then
 If ExplorerManager.IsExplorer(FSender) then
 FSender.SetProgressPosition(FInfoPosition,FCID);
end;

procedure TExplorerThread.HideProgress;
begin
 ProgressVisible:=False;
 Synchronize(SetProgressVisible);
end;

procedure TExplorerThread.SetProgressVisible;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  If ProgressVisible then
  FSender.ShowProgress(FCID) else
  FSender.HideProgress(FCID);
 end;
end;

procedure TExplorerThread.ShowProgress;
begin
 ProgressVisible:=True;
 Synchronize(SetProgressVisible);
end;

procedure TExplorerThread.LoadMyComputerFolder;
Var
  i : Integer;
  DS :  TDriveState;
  oldMode: Cardinal;
begin
 HideProgress;
 Synchronize(BeginUpdate);
 ShowInfo(TEXT_MES_READING_MY_COMPUTER,1,0);
 FFiles:=SetNilExplorerFileInfo;
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=2) or (GetDriveType(pchar(Chr(i)+':\'))=3) or (GetDriveType(PChar(Chr(i)+':\'))=5) then
 begin 
  AddOneExplorerFileInfo(FFiles,Chr(i)+':\', EXPLORER_ITEM_DRIVE, -1, GetCid,0,0,0,0,0,'','','',0,false,false,true);
 end;
 AddOneExplorerFileInfo(FFiles,TEXT_MES_NETWORK, EXPLORER_ITEM_NETWORK, -1, GetCid,0,0,0,0,0,'','','',0,false,false,true);
 Synchronize(InfoToExplorerForm);
 For i:=0 to Length(FFiles)-1 do
 begin
  if FFiles[i].FileType=EXPLORER_ITEM_DRIVE then
  begin
   StringParam:=FFiles[i].SID;
   CurrentFile := FFiles[i].FileName;
   MakeFolderImage(CurrentFile);
   DS:=Dolphin_DB.DriveState(CurrentFile[1]);
   If (DS=DS_DISK_WITH_FILES) or (DS=DS_EMPTY_DISK) then
   DriveNameParam:=GetCDVolumeLabel(CurrentFile[1])+' ('+CurrentFile[1]+':)' else
   DriveNameParam:=MrsGetFileType(CurrentFile[1]+':\')+' ('+CurrentFile[1]+':)';
   AddDriveToExplorer;
  end;
  if FFiles[i].FileType=EXPLORER_ITEM_NETWORK then
  begin
   StringParam:=FFiles[i].SID;
   CurrentFile := FFiles[i].FileName;

    IconParam:=nil;
    FindIcon(DBKernel.IconDllInstance,'NETWORK',FIcoSize,32,IconParam);
    if ExplorerInfo.View<>LV_THUMBS then
    fIcon:=IconParam; //for not-thumbnails views
    MakeImageWithIcon;
    if ExplorerInfo.View=LV_THUMBS then
    IconParam.Free;
  // end;
  end;
 end;
 SetErrorMode(oldMode);
 Synchronize(EndUpdate);
 ShowInfo('',1,0);
end;

procedure TExplorerThread.RegisterThread;
Var
  Info : TDBThreadInfo;
begin
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Explorer_Loading;
 If ExplorerManager.IsExplorer(FSender) then
 Info.OwnerHandle:=FSender.Handle else
 Info.OwnerHandle:=0;
 DBThreadManeger.AddThread(Info);
end;

procedure TExplorerThread.UnRegisterThread;
Var
  Info : TDBThreadInfo;
begin
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Explorer_Loading;
 If ExplorerManager.IsExplorer(FSender) then
 Info.OwnerHandle:=FSender.Handle else
 Info.OwnerHandle:=0;
 DBThreadManeger.RemoveThread(Info);
end;

procedure TExplorerThread.LoadNetWorkFolder;
var
  NetworkList : TStrings;
  i : integer;
begin
 HideProgress;
 Synchronize(BeginUpdate);
 ShowInfo(TEXT_MES_READING_NETWORK,1,0);
 FFiles:=SetNilExplorerFileInfo;
 NetworkList:=TStringList.Create;
 FillNetLevel(nil,NetWorkList);
 For i:=0 to NetworkList.Count-1 do
 AddOneExplorerFileInfo(FFiles,NetworkList[i], EXPLORER_ITEM_WORKGROUP, -1, GetCid,0,0,0,0,0,'','','',0,false,false,true);
 Synchronize(InfoToExplorerForm);
 NetworkList.Free;
 For i:=0 to Length(FFiles)-1 do
 begin
  StringParam:=FFiles[i].SID;
  CurrentFile := FFiles[i].FileName;
                            
  IconParam:=nil;
  FindIcon(DBKernel.IconDllInstance,'WORKGROUP',FIcoSize,32,IconParam);

  if ExplorerInfo.View<>LV_THUMBS then
  fIcon:=IconParam; //for not-thumbnails views
  MakeImageWithIcon;
  if ExplorerInfo.View=LV_THUMBS then
  IconParam.Free;

 end;
 Synchronize(EndUpdate);
 ShowInfo('',1,0);
end;

procedure TExplorerThread.MakeImageWithIcon;
begin
 if ExplorerInfo.View=LV_THUMBS then
 begin
  Synchronize(MakeTempBitmapSmall);
  Synchronize(DrawImageIconSmall);
 end;
 Synchronize(AddImageFileImageToExplorer);
 Synchronize(AddImageFileItemToExplorer);
end;

procedure TExplorerThread.LoadWorkgroupFolder;
var
  ComputerList : TStrings;
  i : integer;
begin
 HideProgress;
 Synchronize(BeginUpdate);
 ShowInfo(TEXT_MES_READING_WORKGROUP,1,0);
 FFiles:=SetNilExplorerFileInfo;
 ComputerList:=TStringList.Create;
 if (FindAllComputers(FFolder,ComputerList)<>0) and (ComputerList.Count=0) then
 begin
  StrParam:=TEXT_MES_ERROR_OPENING_WORKGROUP;
  Synchronize(ShowMessage_);
  ComputerList.Free;
  Synchronize(EndUpdate);
  ShowInfo('',1,0);
  Synchronize(ExplorerBack);
  Synchronize(UnRegisterThread);
  Exit;
 end;
 For i:=0 to ComputerList.Count-1 do
 AddOneExplorerFileInfo(FFiles,ComputerList[i], EXPLORER_ITEM_COMPUTER, -1, GetCid,0,0,0,0,0,'','','',0,false,false,true);
 Synchronize(InfoToExplorerForm);
 ComputerList.Free;
 For i:=0 to Length(FFiles)-1 do
 begin
  StringParam:=FFiles[i].SID;
  CurrentFile := FFiles[i].FileName;
                                     
  IconParam:=nil;
  FindIcon(DBKernel.IconDllInstance,'COMPUTER',FIcoSize,32,IconParam);

  if ExplorerInfo.View<>LV_THUMBS then
  fIcon:=IconParam; //for not-thumbnails views
  MakeImageWithIcon;
  if ExplorerInfo.View=LV_THUMBS then
  IconParam.Free;
  
 end;
 Synchronize(EndUpdate);
 ShowInfo('',1,0);
end;

procedure TExplorerThread.LoadComputerFolder;
var
  ShareList : TStrings;
  i, Res : integer;
begin
 HideProgress;
 Synchronize(BeginUpdate);
 ShowInfo(TEXT_MES_READING_COMPUTER,1,0);
 FFiles:=SetNilExplorerFileInfo;
 ShareList:=TStringList.Create;
 Res:=FindAllComputers(FFolder,ShareList);
 if (Res<>0) and (ShareList.Count=0) then
 begin
  StrParam:=TEXT_MES_ERROR_OPENING_COMPUTER;
  Synchronize(ShowMessage_);
  ShareList.Free;
  Synchronize(EndUpdate);
  ShowInfo('',1,0);
  Synchronize(ExplorerBack);
  Synchronize(UnRegisterThread);
  Exit;
 end;
 For i:=0 to ShareList.Count-1 do
 AddOneExplorerFileInfo(FFiles,ShareList[i], EXPLORER_ITEM_SHARE, -1, GetCid,0,0,0,0,0,'','','',0,false,false,true);
 Synchronize(InfoToExplorerForm);
 ShareList.Free;
 For i:=0 to Length(FFiles)-1 do
 begin
  StringParam:=FFiles[i].SID;
  CurrentFile := FFiles[i].FileName;

  IconParam:=nil;

  FindIcon(DBKernel.IconDllInstance,'SHARE',FIcoSize,32,IconParam);

  if ExplorerInfo.View<>LV_THUMBS then
  fIcon:=IconParam; //for not-thumbnails views
  MakeImageWithIcon;
  if ExplorerInfo.View=LV_THUMBS then
  IconParam.Free;

 end;
 Synchronize(EndUpdate);
 ShowInfo('',1,0);
end;

procedure TExplorerThread.ShowMessage_;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then
 MessageBoxDB(FSender.Handle,StrParam,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
end;

procedure TExplorerThread.ExplorerBack;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then 
 FSender.DoBack;
end;

procedure TExplorerThread.UpdateFile;
var
  Folder, dbstr : string;
  crc : Cardinal;
begin
 if FUpdaterInfo.ID<>0 then
 UpdateImageRecord(FFolder,FUpdaterInfo.ID);
 FQuery:=GetQuery;                               
 UnProcessPath(FFolder);
 if FolderView then FFolder:=ExtractFileName(FFolder);

 if GetDBType=DB_TYPE_BDE then
 begin
  SetSQL(FQuery,'Select * From '+GetDefDBname+' where (FFileName Like :ImageFile)');
 end else
 begin
  Folder:=GetDirectory(FFolder);
  UnFormatDir(Folder);
  CalcStringCRC32(AnsiLowerCase(Folder),crc);

  if FolderView then
  dbstr:=GetDefDBName else
  dbstr:='(Select * from '+GetDefDBName+' where FolderCRC='+inttostr(Integer(crc))+')';

  SetSQL(fQuery,'SELECT * FROM '+dbstr+' WHERE FFileName like :ImageFile');
 end;
 SetStrParam(FQuery,0,'%'+normalizeDBStringLike(NormalizeDBString(normalizeDBFileNameString(AnsiLowercase(FFolder))))+'%');
 try
  FQuery.Active:=True;
 except
 end;
 FFiles:=SetNilExplorerFileInfo;                               //?????????
 AddOneExplorerFileInfo(FFiles,FFolder, EXPLORER_ITEM_IMAGE, -1, Fmask{GetCID},0,0,0,0,GetFileSizeByName(FFolder),'','','',0,false,false,true);
 if FQuery.RecordCount>0 then
 begin
  FFiles[0].Rotate:=FQuery.FieldByName('Rotated').AsInteger;
 end;
 StringParam:=FFiles[0].SID;
 if FolderView then CurrentFile:=ProgramDir+FFiles[0].FileName else
 CurrentFile:=FFiles[0].FileName;
 if ExplorerInfo.ShowThumbNailsForImages then
 ReplaceImageItemImage;
 if FUpdaterInfo.ID<>0 then
 Synchronize(ChangeIDImage);
 IntParam:=FUpdaterInfo.ID;
 Synchronize(EndUpdateID);
 FreeDS(FQuery);

 DoLoadBigImages;
 
 if Info.ItemId<>0 then
 if Assigned(FUpdaterInfo.ProcHelpAfterUpdate) then
 Synchronize(DoUpdaterHelpProc);
end;

procedure TExplorerThread.FindPassword;
begin
 PassParam:=DBKernel.FindPasswordForCryptImageFile(PassParam);
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
 If ExplorerManager.IsExplorer(FSender) then  
 if FSender.CurrentGUID=FCID then
 begin
  if ExplorerInfo.View=LV_THUMBS then
  begin
   FSender.ReplaceBitmap(TempBitmap,StringParam,true,BooleanParam)
  end else
  FSender.ReplaceIcon(fIcon,StringParam,true);
 end;
end;

procedure TExplorerThread.MakeIconForFile;
begin
 MakeTempBitmapSmall;
 FillRectNoCanvas(TempBitmap,Dolphin_DB.Theme_ListColor);
// Synchronize(FillRect);
 if not SafeMode then ficon:=AIcons.GetIconByExt(CurrentFile,false, FIcoSize,false) else
 begin
  ficon:=TIcon.Create;
  ficon.Handle:=ExtractAssociatedIcon_(CurrentFile);
 end;
 if self.ExplorerInfo.View=LV_THUMBS then
 begin
  IconParam:=ficon;
  try
  Synchronize(DrawImageIconSmall);
  except
  end;
  ficon.free;
 end;
 Synchronize(ReplaceImageInExplorerB);
end;

procedure TExplorerThread.UpdateSimpleFile;
begin
 StringParam:=Fmask;
 Synchronize(FileNeeded);
 If BooleanResult then
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
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.AddIcon(FIcon, true, StringParam);
 end
end;

procedure TExplorerThread.UpdateFolder;
begin
 FFiles:=SetNilExplorerFileInfo;
 AddOneExplorerFileInfo(FFiles,FFolder, EXPLORER_ITEM_FOLDER, -1, Fmask,0,0,0,0,0,'','','',0,false,false,true);
 StringParam:=FFiles[0].SID;
 CurrentFile:=FFiles[0].FileName;
 fMask:=SupportedExt;
 if ExplorerInfo.ShowThumbNailsForFolders then
 ReplaceThumbImageToFolder;
end;

procedure TExplorerThread.EndUpdateID;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.RemoveUpdateID(IntParam, FCID);
 end
end;

procedure TExplorerThread.GetVisibleFiles;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then
 begin
  FVisibleFiles:=FSender.GetVisibleItems;
 end
end;

procedure TExplorerThread.VisibleUp(TopIndex: integer);
var
  i, c : integer;
  j : integer;
  temp : TExplorerFileInfo;
begin
 c:=TopIndex;
 for i:=0 to Length(FVisibleFiles)-1 do
 for j:=TopIndex to Length(FFiles)-1 do
 if FFiles[j].Tag=0 then
 begin
  if FVisibleFiles[i]=FFiles[j].SID then
  begin
   temp:=FFiles[c];
   FFiles[c]:=FFiles[j];
   FFiles[j]:=temp;
   inc(c);
  end;
 end;
end;

procedure TExplorerThread.DoLoadBigImages;
var
  i, InfoPosition : integer;
  FPic : TPicture;
  PassWord : String;
  fbit : TBitmap;
  w, h : integer;
  ProcNum : integer;
begin
 ProcNum:=GettingProcNum;
 FPic:=nil;

 Repeat
  sleep(100);
 until ExplorerUpdateBigImageThreadsCount<(ProcNum+1);
 ExplorerUpdateBigImageThreadsCount:=ExplorerUpdateBigImageThreadsCount+1;

 if LoadingAllBigImages then
 Synchronize(GetAllFiles);
                
 ShowInfo(TEXT_MES_LOADING_BIG_IMAGES);
 ShowInfo(Length(FFiles),0);
 InfoPosition:=0;
 
 for i:=0 to Length(FFiles)-1 do
 begin
             
  Inc(InfoPosition);
  ShowInfo(InfoPosition);

  if i mod 5=0 then
  begin
   Synchronize(GetVisibleFiles);
   VisibleUp(i);
   Sleep(5);
  end;

  StringParam:=FFiles[i].SID;
  
  BooleanResult:=false;

  if FFiles[i].FileType=EXPLORER_ITEM_IMAGE then
  begin
   Synchronize(FileNeededAW);
  
   //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
   if not LoadingAllBigImages then BooleanResult:=true;

   if InvalidThread then break;
   if not FileExists(ProcessPath(FFiles[i].FileName)) then continue;
   if BooleanResult then
   begin
    try
     FPic := TPicture.Create;
    except
     if FPic<>nil then
     FPic.Free;
     FPic:=nil;
     continue;
    end;
    try
     if GraphicCrypt.ValidCryptGraphicFile(ProcessPath(FFiles[i].FileName)) then
     begin
      PassWord:=DBKernel.FindPasswordForCryptImageFile(ProcessPath(FFiles[i].FileName));
      if PassWord='' then
      begin
       if FPic<>nil then FPic.Free;
       FPic:=nil;
       continue;
      end;
      FPic.Graphic:=GraphicCrypt.DeCryptGraphicFile(ProcessPath(FFiles[i].FileName),PassWord);
     end else
     begin
      if IsRAWImageFile(FFiles[i].FileName) then
      begin
       Fpic.Graphic:=TRAWImage.Create;
       if not (Fpic.Graphic as TRAWImage).LoadThumbnailFromFile(ProcessPath(FFiles[i].FileName)) then
       FPic.Graphic.LoadFromFile(ProcessPath(FFiles[i].FileName));
      end else
      FPic.LoadFromFile(ProcessPath(FFiles[i].FileName));
     end;
    except
     if FPic<>nil then
     FPic.Free;
     FPic:=nil;
     continue;
     end;
    fbit:=nil;
    fbit:=TBitmap.Create;
    fbit.PixelFormat:=pf24bit;
    JPEGScale(Fpic.Graphic,ExplorerInfo.PictureSize,ExplorerInfo.PictureSize);

    if Min(Fpic.Height,Fpic.Width)>1 then
    try
     LoadImageX(Fpic.Graphic,fbit,Theme_ListColor);
    except
    end;
    Fpic.Free;
    Fpic:=nil;

    TempBitmap:=TBitmap.create;
    TempBitmap.PixelFormat:=pf24bit;
    w:=fbit.Width;
    h:=fbit.Height;
    ProportionalSize(ExplorerInfo.PictureSize,ExplorerInfo.PictureSize,w,h);
    TempBitmap.Width:=w;
    TempBitmap.Height:=h;
    try
     DoResize(w,h,fbit,TempBitmap);
    except
    end;
    fbit.Free;
    fbit:=nil;

    case FFiles[i].Rotate of
     DB_IMAGE_ROTATED_90  :  Rotate90A(TempBitmap);
     DB_IMAGE_ROTATED_180 :  Rotate180A(TempBitmap);
     DB_IMAGE_ROTATED_270 :  Rotate270A(TempBitmap);
    end;

    BooleanParam:=LoadingAllBigImages;
    Synchronize(ReplaceImageInExplorerB);

   //TempBitmap.Free;
   end;
  end;

  BooleanResult:=false;

  //directories
  if FFiles[i].FileType=EXPLORER_ITEM_FOLDER then
  begin
   Synchronize(FileNeededAW);
   CurrentFile:=FFiles[i].FileName;

   //при загрузке всех картинок проверка, если только одна грузится то не проверяем т.к. явно она вызвалась значит нужна
   if not LoadingAllBigImages then BooleanResult:=true;

   if InvalidThread then break;

   if BooleanResult then
   if ExplorerInfo.ShowThumbNailsForFolders then
   try
    ReplaceThumbImageToFolder;
   except
   end;
  end;
 end;

 ExplorerUpdateBigImageThreadsCount:=ExplorerUpdateBigImageThreadsCount-1;

 Synchronize(DoStopSearch);
 HideProgress;
 ShowInfo('');
end;

procedure TExplorerThread.GetAllFiles;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FFiles:=FSender.GetAllItems;
 end
end;

procedure TExplorerThread.DoDefaultSort;
begin
 If ExplorerManager.IsExplorer(FSender) then
 begin
  FSender.NoLockListView:=true;
  FSender.DoDefaultSort(FCID); 
  FSender.NoLockListView:=false;
 end
end;

procedure TExplorerThread.ExplorerHasIconForExt;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then
 begin
  BooleanParam:=FSender.ExitstExtInIcons(GetExt(CurrentFile));
 end;
end;

procedure TExplorerThread.SetIconForFileByExt;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then
 begin
  FSender.AddIconByExt(GetExt(CurrentFile),IconParam);
 end;
end;


procedure TExplorerThread.DoVerifyExplorer;
begin
 BooleanResult:=true;
 If not ExplorerManager.IsExplorer(FSender) then
 begin
  BooleanResult:=false;
 end else
 begin
  if (FSender.CurrentGUID<>FCID) then BooleanResult:=false;
 end;
end;

procedure TExplorerThread.DoStopSearch;
begin
 If ExplorerManager.IsExplorer(FSender) then
 if FSender.CurrentGUID=FCID then
 begin
  FSender.DoStopLoading(FCID);
 end;

end;

{ TAIcons }

function VarIco(Ext : string) : boolean;
var
  reg : TRegistry;
  s : string;
  i : integer;
begin
 Result:=false;
 if Ext='.scr' then
 begin
  Result:=true;
  exit;
 end;
 if Ext='.exe' then
 begin
  Result:=true;
  exit;
 end;
 if Ext='' then begin Result:=true; exit; end;
 reg := Tregistry.Create;
 reg.RootKey:=Windows.HKEY_CLASSES_ROOT;
 if not reg.OpenKey('\'+ext,false) then
 begin
  reg.CloseKey;
  reg.Free;
  exit;
 end;
 s:=reg.ReadString('');
 reg.CloseKey;
 if not reg.OpenKey('\'+s+'\DefaultIcon',false)  then
 begin
  reg.CloseKey;
  reg.Free;
  exit;
 end;
 s:=reg.ReadString('');
 for i:=length(s) downto 1 do
 if (s[i]='''') or( s[i]='"') or( s[i]=' ') then delete(s,i,1);
 if s='%1' then result:=true;
 reg.Closekey;
 reg.Free;
end;

function TAIcons.SetPath(const Value: string) : PItemIDList;
var
  P: PWideChar;
  Flags,
  NumChars: LongWord;
begin
 Result:=nil;
 NumChars := Length(Value);
 Flags := 0;
 P := StringToOleStr(Value);
 if not Succeeded(FIDesktopFolder.ParseDisplayName(Application.Handle,nil,P,NumChars,Result,Flags)) then
 result:=nil;
end;

procedure FindIcon(hLib :cardinal; NameRes :string; Size, ColorDepth :Byte; var Icon :TIcon);
type
  GRPICONDIRENTRY =  packed record
    bWidth :BYTE;              // Width, in pixels, of the image
    bHeight :BYTE;              // Height, in pixels, of the image
    bColorCount :BYTE;          // Number of colors in image (0 if >=8bpp)
    bReserved :BYTE;            // Reserved
    wPlanes :WORD;              // Color Planes
    wBitCount :WORD;            // Bits per pixel
    dwBytesInRes :DWORD;        // how many bytes in this resource?
    nID :WORD;                  // the ID
  end;

  GRPICONDIR =  packed record
    idReserved :WORD;  // Reserved (must be 0)
    idType :WORD;      // Resource type (1 for icons)
    idCount :WORD;      // How many images?
    idEntries :array [1..16] of GRPICONDIRENTRY ; // The entries for each image
  end;

  ICONIMAGE = record
    icHeader :BITMAPINFOHEADER;      // DIB header
    icColors :array of RGBQUAD;  // Color table
    icXOR :array of BYTE;      // DIB bits for XOR mask
    icAND :array of BYTE;      // DIB bits for AND mask
  end;

var
  hRsrc, hGlobal :cardinal;

  GRP :GRPICONDIR;

  lpGrpIconDir :^GRPICONDIR;
  lpIconImage :^ICONIMAGE;

  Stream :TMemoryStream;
  i, i0, nID :integer;
begin
  lpIconImage:=nil;
  // Find the group resource which lists its images
  hRsrc := FindResource(hLib, PAnsiChar(NameRes), RT_GROUP_ICON);
  // Load and Lock to get a pointer to a GRPICONDIR
  hGlobal := LoadResource(hLib, hRsrc);
  lpGrpIconDir := LockResource(hGlobal);

  // Using an ID from the group, Find, Load and Lock the RT_ICON
  i0 := Low(lpGrpIconDir.idEntries);
  for i := i0 to lpGrpIconDir.idCount do begin
    hRsrc := FindResource(hLib, MAKEINTRESOURCE(lpGrpIconDir.idEntries[i].nID), RT_ICON);
    hGlobal := LoadResource(hLib, hRsrc);
    lpIconImage := LockResource(hGlobal);
    if (lpIconImage.icHeader.biWidth = Size) and (lpIconImage.icHeader.biBitCount = ColorDepth) then
      Break;
  end;

  if Assigned(lpIconImage) and (lpIconImage.icHeader.biWidth = Size)
  and (lpIconImage.icHeader.biBitCount = ColorDepth) then begin
    Stream := TMemoryStream.Create;
    Stream.Clear;

    ZeroMemory(@GRP, SizeOf(GRP));
    GRP.idCount := 1;
    GRP.idType := 1;
    GRP.idReserved := 0;
    GRP.idEntries[i0] := lpGrpIconDir.idEntries[i];
    nID := SizeOf(WORD) * 3 + SizeOf(GRPICONDIRENTRY) + 2;  //$16
    GRP.idEntries[i0].nID := nID;
    Stream.WriteBuffer(GRP, nID);
    Stream.WriteBuffer(lpIconImage^, GRP.idEntries[i0].dwBytesInRes);

    Stream.Position := 0;
    Icon:=TIcon.Create;
    Icon.LoadFromStream(Stream);
    Stream.Free;
  end;
end;

function TAIcons.GetShellImage(Path : String; Size : integer): TIcon;
var
  FileInfo: TSHFileInfo;
  Flags: Integer;
  PathPidl: PItemIDList;
begin
 Result := nil;
 FillChar(FileInfo, SizeOf(FileInfo), #0);
 Flags:=0;
 if (Size<48) then Flags := SHGFI_SYSICONINDEX or SHGFI_ICON;
 if (Size=48) then Flags := SHGFI_SYSICONINDEX;
 if (Size=32) then Flags := Flags or SHGFI_LARGEICON;
 if (Size=16) then Flags := Flags or SHGFI_SMALLICON;

 begin
  SHGetFileInfo(PChar(Path), 0, FileInfo, SizeOf(FileInfo), Flags or SHGFI_TYPENAME);
  Result:=TIcon.Create;
  if (Size<48) then
  begin
   Result.Handle:=FileInfo.hIcon;
  end else
  begin
   Result:=TIcon.Create;

   //create this object when it needed!
   if FVirtualSysImages=nil then FVirtualSysImages:=ExtraLargeSysImages;

   FVirtualSysImages.GetIcon(FileInfo.iIcon,Result);
  end;
 end;
end;

function TAIcons.AddIconByExt(FileName, EXT: string; Size : integer) : integer;
begin
 Result:=Length(FAssociatedIcons)-1;
 SetLength(FAssociatedIcons,Length(FAssociatedIcons)+1);
 FAssociatedIcons[Length(FAssociatedIcons)-1].Ext:=EXT;
 FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon:=VarIco(EXT);
// if FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon then exit;
// FAssociatedIcons[Length(FAssociatedIcons)-1].Icon:=TIcon.create;
 FAssociatedIcons[Length(FAssociatedIcons)-1].Icon:=GetShellImage(FileName,Size);
 FAssociatedIcons[Length(FAssociatedIcons)-1].Size:=Size;
end;

constructor TAIcons.Create;
begin
  inherited;
  if SHGetDesktopFolder(FIDesktopFolder) <> NOERROR then
  begin
   DBTerminating:=true;
   EventLog('TAIcons.Create failed: SHGetDesktopFolder = NOERROR');
  end;
  SetLength(UnLoadingListEXT,0);
  CoInitializeEx(nil,COINIT_MULTITHREADED );    
  FVirtualSysImages:=nil;
  Initialize;
end;

destructor TAIcons.Destroy;
var
  i : integer;
begin
 For i:=0 to length(FAssociatedIcons)-1 do
 FAssociatedIcons[i].Icon.free;
 SetLength(FAssociatedIcons,0);
 SetLength(UnLoadingListEXT,0);
 CoUninitialize;
  inherited;
end;

function TAIcons.GetIconByExt(FileName: String; IsFolder : boolean; Size : integer; Default : boolean): TIcon;
var
  n, i : integer;
  EXT : String;
begin
 Result:=nil;
 n:=0;
 if IsFolder then
 if Copy(FileName,1,2)='\\' then Default:=true;
 if IsFolder then EXT:='' else EXT:=AnsiLowerCase(ExtractFileExt(FileName));
 if not IsExt(EXT,Size) and not Default then
 n:=AddIconByExt(FileName,EXT, Size);
 For i:=n to length(FAssociatedIcons)-1 do
 if (FAssociatedIcons[i].Ext=EXT) and (FAssociatedIcons[i].Size=Size) then
 begin
  if (not FAssociatedIcons[i].SelfIcon) or Default then
  begin
   Result:=TIcon.Create;
   Result.Assign(FAssociatedIcons[i].Icon);
  end else
  begin
   Result:=GetShellImage(FileName,Size);
  end;
 end;
end;

function TAIcons.IsExt(EXT: string; Size : integer): boolean;
var
  i : Integer;
begin
 result:=False;
 For i:=0 to length(FAssociatedIcons)-1 do
 if (FAssociatedIcons[i].Ext=EXT) and (FAssociatedIcons[i].Size=Size) then
 begin
  Result:=True;
  Break;
 end;
end;

function TAIcons.IsVarIcon(FileName: String; Size : integer): boolean;
var
  i : Integer;
  EXT : String;
begin
 Result:=false;
 EXT:=AnsiLowerCase(ExtractFileExt(FileName));
 For i:=0 to length(FAssociatedIcons)-1 do
 if (FAssociatedIcons[i].Ext=EXT) and (FAssociatedIcons[i].Size=Size) then
 begin
  Result:=FAssociatedIcons[i].SelfIcon;
  exit;
 end;
 SetLength(FAssociatedIcons,Length(FAssociatedIcons)+1);
 FAssociatedIcons[Length(FAssociatedIcons)-1].Ext:=EXT;
 FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon:=VarIco(EXT);
 if FAssociatedIcons[Length(FAssociatedIcons)-1].SelfIcon then begin Result:=true; exit; end;
 FAssociatedIcons[Length(FAssociatedIcons)-1].Icon:=GetShellImage(FileName,Size);
 FAssociatedIcons[Length(FAssociatedIcons)-1].Size:=Size;
end;

procedure TAIcons.Clear;
var
  i : Integer;
begin
 For i:=0 to length(FAssociatedIcons)-1 do
 begin
  if not FAssociatedIcons[i].SelfIcon then
  FAssociatedIcons[i].Icon.Free;
 end;
 SetLength(FAssociatedIcons,0);
 Initialize;
end;

procedure TAIcons.Initialize;
begin
  SetLength(FAssociatedIcons,3*4);

  FAssociatedIcons[0].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'Directory',16,32,FAssociatedIcons[0].Icon);//GetShellImage(ProgramDir,16);
  FAssociatedIcons[0].SelfIcon:=true;
  FAssociatedIcons[0].Size:=16;

  FAssociatedIcons[1].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'DIRECTORY',32,32,FAssociatedIcons[1].Icon);
  FAssociatedIcons[1].SelfIcon:=true;
  FAssociatedIcons[1].Size:=32;

  FAssociatedIcons[2].Ext:='';
  FindIcon(DBKernel.IconDllInstance,'DIRECTORY',48,32,FAssociatedIcons[2].Icon);
  FAssociatedIcons[2].SelfIcon:=true;
  FAssociatedIcons[2].Size:=48;

  FAssociatedIcons[3].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',16,4,FAssociatedIcons[3].Icon);
  FAssociatedIcons[3].SelfIcon:=true;
  FAssociatedIcons[3].Size:=16;

  FAssociatedIcons[4].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',32,4,FAssociatedIcons[4].Icon);
  FAssociatedIcons[4].SelfIcon:=true;
  FAssociatedIcons[4].Size:=32;

  FAssociatedIcons[5].Ext:='.exe';
  FindIcon(DBKernel.IconDllInstance,'EXEFILE',48,4,FAssociatedIcons[5].Icon);
  FAssociatedIcons[5].SelfIcon:=true;
  FAssociatedIcons[5].Size:=48;

  FAssociatedIcons[6].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',16,4,FAssociatedIcons[6].Icon);
  FAssociatedIcons[6].SelfIcon:=true;
  FAssociatedIcons[6].Size:=16;

  FAssociatedIcons[7].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',32,4,FAssociatedIcons[7].Icon);
  FAssociatedIcons[7].SelfIcon:=true;
  FAssociatedIcons[7].Size:=32;

  FAssociatedIcons[8].Ext:='.___';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',48,4,FAssociatedIcons[8].Icon);
  FAssociatedIcons[8].SelfIcon:=true;
  FAssociatedIcons[8].Size:=48;

  FAssociatedIcons[9].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',16,4,FAssociatedIcons[9].Icon);
  FAssociatedIcons[9].SelfIcon:=true;
  FAssociatedIcons[9].Size:=48;

  FAssociatedIcons[10].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',32,4,FAssociatedIcons[10].Icon);
  FAssociatedIcons[10].SelfIcon:=true;
  FAssociatedIcons[10].Size:=32;

  FAssociatedIcons[11].Ext:='.lnk';
  FindIcon(DBKernel.IconDllInstance,'SIMPLEFILE',48,4,FAssociatedIcons[11].Icon);;
  FAssociatedIcons[11].SelfIcon:=true;
  FAssociatedIcons[11].Size:=16;
end;

initialization


 UpdatesCountLimit := GettingProcNum+1;
 AIcons:=nil;
 UpdaterCount:=0;

finalization

 if ThisFileInstalled then
 begin
  AIcons.free;
  if AExplorerFolders<>nil then
  AExplorerFolders.free;
 end;
 
end.
 