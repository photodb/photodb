unit ExplorerTypes;

interface

Uses UnitDBKernel, Forms, SysUtils, Windows, Graphics,  Dolphin_DB, 
     Messages, Classes, DB, GraphicsCool, jpeg, wfsU, SyncObjs,
     UnitDBDeclare, UnitDBCommon, UnitDBCommonGraphics;

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

Type
  TFolderImages = record
  Images : array[1..4] of TBitmap;
  FileNames : array[1..4] of string;
  FileDates : array[1..4] of TDateTime;
  Directory : string;
  Width : integer;
  Height : integer;
  end;

Const
  EXPLORER_ITEM_FOLDER     = 0;
  EXPLORER_ITEM_IMAGE      = 1;
  EXPLORER_ITEM_FILE       = 2;
  EXPLORER_ITEM_DRIVE      = 3;
  EXPLORER_ITEM_MYCOMPUTER = 4;
  EXPLORER_ITEM_NETWORK    = 5;
  EXPLORER_ITEM_WORKGROUP  = 6;
  EXPLORER_ITEM_COMPUTER   = 7;
  EXPLORER_ITEM_SHARE      = 8;
  EXPLORER_ITEM_EXEFILE    = 9;
  EXPLORER_ITEM_OTHER      = 10;

//////////////////////////////////////////////////

  THREAD_TYPE_FOLDER         = 0;
  THREAD_TYPE_DISK           = THREAD_TYPE_FOLDER;
  THREAD_TYPE_MY_COMPUTER    = 2;
  THREAD_TYPE_NETWORK        = 3;
  THREAD_TYPE_WORKGROUP      = 4;
  THREAD_TYPE_COMPUTER       = 5;
  THREAD_TYPE_IMAGE          = 6;
  THREAD_TYPE_FILE           = 7;
  THREAD_TYPE_FOLDER_UPDATE  = 8;
  THREAD_TYPE_BIG_IMAGES     = 9;
  THREAD_TYPE_THREAD_PREVIEW = 10;

  THREAD_PREVIEW_MODE_IMAGE      = 1;
  THREAD_PREVIEW_MODE_DIRECTORY  = 2;

  LV_THUMBS     = 0;
  LV_ICONS      = 1;
  LV_SMALLICONS = 2;
  LV_TITLES     = 3;
  LV_TILE       = 4; 
  LV_GRID       = 5;

Type TExplorerPath = Record
  Path : String;
  PType : Integer;
  Tag : integer;
  end;

  TArExplorerPath = array of TExplorerPath;

Type
  PStringA = ^String;

  TExplorerFileInfo = class(TObject)
  public
    FileName : String;
    SID : TGUID;
    FileType :  Integer;
    ID : Integer;
    Rotate : Integer;
    Access : Integer;
    Rating : Integer;
    FileSize : Int64;
    Comment : string;
    KeyWords : string;
    Date : TDateTime;
    Time : TDateTime;
    ImageIndex : Integer;
    Owner : string;
    Groups : string;
    Collections : string;
    IsDate : Boolean;
    IsTime : Boolean;
    Crypted : Boolean;
    Tag : Integer;
    Loaded : Boolean;
    Include : Boolean;
    Links : string;
    isBigImage : Boolean;
    function Clone : TExplorerFileInfo;
  end;

  TExplorerFileInfos = class(TObject)
  private
    FItems : TList;
    function GeInfoByIndex(Index: Integer): TExplorerFileInfo;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Info : TExplorerFileInfo);
    procedure Remove(Info : TExplorerFileInfo);
    procedure Delete(I : Integer);
    procedure Clear;
    procedure Exchange(Index1, Index2 : Integer);
    procedure Assign(Source : TExplorerFileInfos);
    function Clone : TExplorerFileInfos;
    property Count : Integer read GetCount;
    property Items[Index: Integer]: TExplorerFileInfo read GeInfoByIndex; default;
  end;

Procedure AddOneExplorerFileInfo(Infos : TExplorerFileInfos; FileName : String; FileType, ImageIndex : Integer; SID : TGUID; ID, Rating, Rotate, Access, FileSize : Integer; Comment, KeyWords, Groups : String; Date : TDateTime; IsDate, Crypted, Include : Boolean);

type
  TExplorerThreadNotifyDirectoryChange = class(TThread)
  private
   FSID : String;
   FDirectory : String;
   FParentSID : Pointer;
   FOwner : TForm;
   FOnNotifyFile : TNotifyDirectoryChangeW;
   Terminating : Boolean;
   FOldFileName : TArStrings;
   FNewFileName : String;
   FAction : TArInteger;
   protected
    procedure Execute; override;
    procedure NotifyFile;
    procedure RegisterThread;
    procedure UnRegisterThread;
  public
      constructor Create(CreateSuspennded: Boolean; Owner : TForm; Directory : string; OnNotify : TNotifyDirectoryChangeW; SID : string; ParentSID : Pointer);
  end;

type
  TStringsHistoryW = class(TObject)
  fArray : array of TExplorerPath;
  fposition : integer;
  fStrings : integer;
  private
    fOnChange: TNotifyEvent;
  procedure SetOnChange(const Value: TNotifyEvent);
    { Private declarations }
  public
  constructor create;
  destructor Destroy; override;
  procedure Add(Path : TExplorerPath);
  Function CanBack : boolean;
  Function CanForward : boolean;
  Function GetCurrentPos : integer;
  Function DoBack : TExplorerPath;
  Function DoForward : TExplorerPath;
  Property OnHistoryChange : TNotifyEvent read fOnChange write SetOnChange;
  Function LastPath : TExplorerPath;
  Function GetBackHistory : TArExplorerPath;
  Function GetForwardHistory : TArExplorerPath;
  Procedure Clear;
    { Public declarations }
  end;

Type
  TExplorerFolders = class(TObject)
  Private
    FImages : Array of TFolderImages;
    FSaveFoldersToDB: Boolean;
    FDBName : String;
    FSync : TCriticalSection;
    procedure SetSaveFoldersToDB(const Value: Boolean);
  Public
    Constructor Create;
    Destructor Destroy; override;
  Published
    Procedure SaveFolderImages(FolderImages : TFolderImages; Width : integer; Height : integer);
    Function GetFolderImages(Directory : String; Width : integer; Height : integer) : TFolderImages;
    Property SaveFoldersToDB : Boolean Read FSaveFoldersToDB Write SetSaveFoldersToDB;
    procedure CheckFolder(Folder : String);
    procedure Clear;
  end;

Type
  TIcon48 = class(TIcon)
  protected  
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
end;

Function GetRecordFromExplorerInfo(Info : TExplorerFileInfos; N : Integer) : TOneRecordInfo;
Function ExplorerPath(Path : String; PType : Integer) : TExplorerPath;

var
  LockedFiles : array[1..2] of String;
  LockTime : TDateTime;

implementation

uses ExplorerUnit, ThreadManeger;

Function ExplorerPath(Path : String; PType : Integer) : TExplorerPath;
begin
 Result.Path:=Path;
 Result.PType:=PType;
end;

Function GetRecordFromExplorerInfo(Info : TExplorerFileInfos; N : Integer) : TOneRecordInfo;
begin
 Result.ItemFileName:= Info[N].FileName;
 Result.ItemId:= Info[N].ID;
 Result.ItemRotate:= Info[N].Rotate;
 Result.ItemRating:= Info[N].Rating;
 Result.ItemAccess:= Info[N].Access;
 Result.ItemComment:= Info[N].Comment;
 Result.ItemKeyWords:= Info[N].KeyWords;
 Result.ItemOwner:= Info[N].Owner;
 Result.ItemCollections:= Info[N].Collections;
 Result.ItemDate:= Info[N].Date;
 Result.ItemIsDate:= Info[N].IsDate;
 Result.ItemGroups:= Info[N].Groups;
end;

{ TExplorerFolders }

procedure TExplorerFolders.CheckFolder(Folder: String);
var
  i, k, l: integer;
begin 
  FSync.Enter;
  try
   For i:=0 to Length(FImages)-1 do
   begin
    If AnsiLowerCase(FImages[i].Directory)=AnsiLowerCase(Folder) then
    for k:=1 to 4 do
    if FImages[i].FileNames[k]='' then
    begin
     for l:=1 to 4 do
     if FImages[i].Images[l]<>nil then FImages[i].Images[l].free;
     for l:=i to Length(FImages)-2 do
     FImages[l]:=FImages[l+1];
     if Length(FImages)>0 then
     SetLength(FImages,Length(FImages)-1);
     break;
    end;
   end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.Clear;
var
  I, J :integer;
begin
  FSync.Enter;
  try
    for I := 0 to Length(FImages) - 1 do
      for J := 1 to 4 do
        if FImages[I].Images[J] <> nil then
          FImages[I].Images[J].Free;
    SetLength(FImages, 0);
  finally
    FSync.Leave;
  end;
end;

constructor TExplorerFolders.Create;
begin
  FSync := TCriticalSection.Create;
  SaveFoldersToDB := False;
  SetLength(FImages, 0);
end;

destructor TExplorerFolders.Destroy;
begin
  Clear;
  FSync.Free;
  inherited;
end;

function TExplorerFolders.GetFolderImages(
  Directory: String; Width : integer; Height : integer): TFolderImages;
Var
  i, j, k, w, h : integer;
  b : Boolean;
begin   
  FSync.Enter;
  try
  FormatDir(Directory);
  Result.Directory:='';
  for i:=1 to 4 do Result.Images[i]:=nil;
 For i:=0 to Length(FImages)-1 do
 begin
  If AnsiLowerCase(FImages[i].Directory)=AnsiLowerCase(Directory) then
  if Width<=FImages[i].Width then
  begin
   b:=true;
   for k:=1 to 4 do
   if FImages[i].FileNames[k]<>'' then
   if not FileExists(FImages[i].FileNames[k]) then
   begin
    b:=false;
    break;
   end;
   if b then
   for k:=1 to 4 do
   if FImages[i].FileNames[k]<>'' then
   if FImages[i].FileDates[k]<>GetFileDateTime(FImages[i].FileNames[k]) then
   begin
    b:=false;
    break;
   end;
   if b then
   begin
    Result.Directory:=Directory;
    For j:=1 to 4 do
    Begin
     Result.Images[j]:=TBitmap.create;

     if FImages[i].Images[j]<>nil then
     begin
      w:=FImages[i].Images[j].Width;
      h:=FImages[i].Images[j].height;
      ProportionalSize(Width,Height,w,h);
      DoResize(w,h,FImages[i].Images[j],Result.Images[j]);
     end;
    end;
   end;
  end;
  end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.SaveFolderImages(FolderImages: TFolderImages;
  Width : integer; Height : integer);
Var
  i, j : integer;
  b : Boolean;
begin
  FSync.Enter;
  try
   b:=false;   
   FormatDir(FolderImages.Directory);
   For i:=0 to Length(FImages)-1 do
   begin
    If AnsiLowerCase(FImages[i].Directory)=AnsiLowerCase(FolderImages.Directory) then
    if FImages[i].Width<Width then
    begin       
     FImages[i].Width:=Width;
     FImages[i].Height:=Height;
     FImages[i].Directory:=FolderImages.Directory;
     for j:=1 to 4 do
     FImages[i].FileNames[j]:=FolderImages.FileNames[j];
     for j:=1 to 4 do
     FImages[i].FileDates[j]:=FolderImages.FileDates[j];
     for j:=1 to 4 do
     if FImages[i].Images[j]<>nil then
     FImages[i].Images[j].free;
     for j:=1 to 4 do
     begin
      If FolderImages.Images[j]=nil then break;
      FImages[i].Images[j]:=TBitmap.create;
      FImages[i].Images[j].Assign(FolderImages.Images[j]);
      FImages[i].Images[j].PixelFormat:=pf24bit;
     end;
     B:=true;
     Break;
    end;
   end;
   If not b and (FolderImages.Images[1]<>nil) then
   begin
    SetLength(FImages,Length(FImages)+1);
    FImages[Length(FImages)-1].Width:=Width;
    FImages[Length(FImages)-1].Height:=Height;
    FImages[Length(FImages)-1].Directory:=FolderImages.Directory;
    For i:=1 to 4 do
    FImages[Length(FImages)-1].FileNames[i]:=FolderImages.FileNames[i];
    For i:=1 to 4 do
    FImages[Length(FImages)-1].FileDates[i]:=FolderImages.FileDates[i];
    For i:=1 to 4 do
    FImages[Length(FImages)-1].Images[i]:=nil;
    For i:=1 to 4 do
    Begin
     If FolderImages.Images[i]=nil then break;
     FImages[Length(FImages)-1].Images[i]:=TBitmap.Create;
     FImages[Length(FImages)-1].Images[i].Assign(FolderImages.Images[i]);
     FImages[Length(FImages)-1].Images[i].PixelFormat:=pf24bit;
    End;
   end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.SetSaveFoldersToDB(const Value: Boolean);
begin
  FSaveFoldersToDB := Value;
end;

{ TExplorerThread }

constructor TExplorerThreadNotifyDirectoryChange.Create(CreateSuspennded: Boolean; Owner : TForm;
  Directory: string; OnNotify: TNotifyDirectoryChangeW; SID: string; ParentSID : Pointer);
begin
  inherited Create(True);
  FOnNotifyFile := OnNotify;
  FDirectory := Directory;
  FormatDir(fDirectory);
  FOwner := Owner;
  FSID := SID;
  FParentSID := ParentSID;
  Terminating := false;
  if not CreateSuspennded then Resume;
end;

procedure TExplorerThreadNotifyDirectoryChange.Execute;
var
 hDir : THandle;
 lpBuf : Pointer;
 Ptr   : Pointer;
 cbReturn : Cardinal;
 FileName : PWideChar;
 i : integer;
 b, c : Boolean;

 Function FileInDir(Directory, FileName : String) : Boolean;
 begin
  FormatDir(Directory);
  UnFormatDir(FileName);
  FileName:=GetDirectory(FileName);
  if AnsiLowerCase(FileName)=AnsiLowerCase(Directory) then
  result:=true else Result:=false;
 end;

Const
 BUF_SIZE = 65535;
begin
 inherited;
 Synchronize(RegisterThread);
 FreeOnTerminate:=true;
 fNewFileName:='';

 hDir := CreateFile (Pchar(FDirectory),GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE
 or FILE_SHARE_DELETE,nil,OPEN_EXISTING,FILE_FLAG_BACKUP_SEMANTICS,0);
 if hDir = INVALID_HANDLE_VALUE then exit;
 GetMem(lpBuf,BUF_SIZE);
 repeat
  SetLength(fOldFileName,0);
  SetLength(FAction,0);
  If Terminating then break;
  ZeroMemory(lpBuf,BUF_SIZE);

  if not ReadDirectoryChangesW(hDir,lpBuf,BUF_SIZE,false,FILE_NOTIFY_CHANGE_FILE_NAME+FILE_NOTIFY_CHANGE_DIR_NAME	+FILE_NOTIFY_CHANGE_CREATION+FILE_NOTIFY_CHANGE_LAST_WRITE{+FILE_NOTIFY_CHANGE_LAST_ACCESS},@cbReturn,nil,nil) then Break;
  Ptr:=lpBuf;
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
   if AnsiLowerCase(LockedFiles[i])=AnsiLowerCase(fDirectory+FileName) then
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
   case PFileNotifyInformation(Ptr).Action of
     FILE_ACTION_ADDED,FILE_ACTION_REMOVED,FILE_ACTION_MODIFIED,FILE_ACTION_RENAMED_OLD_NAME:
      begin
       SetLength(fOldFileName,Length(fOldFileName)+1);
       fOldFileName[Length(fOldFileName)-1]:= fDirectory+FileName;
       SetLength(FAction,Length(FAction)+1);
       FAction[Length(FAction)-1]:= PFileNotifyInformation(Ptr).Action;
      end;

     FILE_ACTION_RENAMED_NEW_NAME:
      begin
        SetLength(fOldFileName,Length(fOldFileName)+1);
        fOldFileName[Length(fOldFileName)-1]:= fDirectory+FileName;
        fNewFileName := fDirectory+FileName;
        SetLength(FAction,Length(FAction)+1);
        FAction[Length(FAction)-1]:=PFileNotifyInformation(Ptr).Action;
      end;
   end;

   FreeMem(FileName);

   if PFileNotifyInformation(Ptr).NextEntryOffset=0  then Break
   else Inc(Cardinal(Ptr),PFileNotifyInformation(Ptr).NextEntryOffset);

  until false;

  Synchronize(NotifyFile);
 until false;
 FreeMem(lpBuf);
 CloseHandle(hDir);
 Synchronize(UnRegisterThread);
end;

procedure TExplorerThreadNotifyDirectoryChange.NotifyFile;
Var
  S : String;
begin
 if ExplorerManager.IsExplorerForm(FOwner) then
 begin
  S:=String(fParentSID^);
  If S <> fSID then
  Terminating:=true else
 end else Terminating:=true;
//? if ExplorerManager.IsExplorerForm(FOwner) then
//? If Assigned(FOnNotifyFile) then
//? FOnNotifyFile(self,FSID,fOldFileName,fNewFileName,FAction);
 SetLength(fOldFileName,0);
 SetLength(FAction,0);
end;

procedure AddOneExplorerFileInfo(Infos : TExplorerFileInfos; FileName : String; FileType, ImageIndex : Integer; SID : TGUID; ID, Rating, Rotate, Access, FileSize : Integer; Comment, KeyWords, Groups : String; Date : TDateTime; IsDate, Crypted, Include : Boolean);
var
  Info : TExplorerFileInfo;
begin
  Info := TExplorerFileInfo.Create;
  Info.FileName:=FileName;
  Info.ID:=ID;
  Info.FileType:=FileType;
  Info.SID:=SID;
  Info.Rotate:=Rotate;
  Info.Rating:=Rating;
  Info.Access:=Access;
  Info.FileSize:=FileSize;
  Info.Comment:=Comment;
  Info.KeyWords:=KeyWords;
  Info.ImageIndex:=ImageIndex;
  Info.Date:=Date;
  Info.IsDate:=IsDate;
  Info.Groups:=Groups;
  Info.Crypted:=Crypted;
  Info.Loaded:=false;
  Info.Include:=Include;
  Info.isBigImage:=false;
  Infos.Add(Info);
end;

procedure TExplorerThreadNotifyDirectoryChange.RegisterThread;
Var
  Info : TDBThreadInfo;
  E: TExplorerForm;
begin
 E:=nil;
 if ExplorerManager.IsExplorerForm(FOwner) then
 E:=ExplorerManager.GetExplorerBySID(String(fParentSID^));
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Explorer_Watching;
 If E<>nil then Info.OwnerHandle:=E.Handle else
 Info.OwnerHandle:=0;
 DBThreadManeger.AddThread(Info);
end;

procedure TExplorerThreadNotifyDirectoryChange.UnRegisterThread;
Var
  Info : TDBThreadInfo;
  E: TExplorerForm;
begin
 e:=nil;
 if ExplorerManager.IsExplorerForm(FOwner) then
 E:=ExplorerManager.GetExplorerBySID(String(fParentSID^));
 Info.Handle:=ThreadID;
 Info.Type_:=Thread_Type_Explorer_Watching;
 If E<>nil then Info.OwnerHandle:=E.Handle else
 Info.OwnerHandle:=0;
 DBThreadManeger.RemoveThread(Info);
end;

{ TStringsHistoryW }

procedure TStringsHistoryW.Add(Path: TExplorerPath);
begin
 If Fposition=Length(fArray)-1 then
 begin
  SetLength(fArray,Length(fArray)+1);
  fArray[Length(fArray)-1]:=Path;
  Fposition:=Length(fArray)-1;
 end else
 begin
  SetLength(fArray,Fposition+2);
  fArray[Fposition+1]:=Path;
  Fposition:=Fposition+1;
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self);
end;

function TStringsHistoryW.CanBack: boolean;
begin
 If Fposition=-1 then
 begin
  Result:=false;
 end else
 begin
  if FPosition>0 then Result:=True else Result:=false;
 end;
end;

function TStringsHistoryW.CanForward: boolean;
begin
 if FPosition=-1 then
 begin
  Result:=false;
  Exit;
 end else
 begin
  if (Fposition<>Length(fArray)-1) and (Length(fArray)<>1) then
  Result:=True else Result:=false;
 end;
end;

procedure TStringsHistoryW.Clear;
begin
 Fposition:=-1;
 SetLength(fArray,0);
end;

constructor TStringsHistoryW.create;
begin
 Inherited;
 Fposition:=-1;
 SetLength(fArray,0);
 fOnChange:=nil;
end;

destructor TStringsHistoryW.Destroy;
begin
 SetLength(fArray,0);
 inherited;
end;

function TStringsHistoryW.DoBack: TExplorerPath;
begin
 Result:=ExplorerPath('',0);
 If FPosition=-1 then Exit;
 if FPosition=0 then Result:=fArray[0] else
 begin
  Dec(FPosition);
  Result:=fArray[FPosition];
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self);
end;

function TStringsHistoryW.DoForward: TExplorerPath;
begin
 Result:=ExplorerPath('',0);
 If FPosition=-1 then Exit;
 if (Fposition=Length(fArray)-1) or (Length(fArray)=1) then Result:=fArray[Length(fArray)-1] else
 begin
  Inc(FPosition);
  Result:=fArray[FPosition];
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self);
end;

function TStringsHistoryW.GetBackHistory: TArExplorerPath;
var
  i : integer;
begin
 SetLength(Result,0);
 If FPosition=-1 then Exit;
 For i:=0 to FPosition-1 do
 begin
  SetLength(Result,Length(Result)+1);
  Result[i]:=fArray[i];
  Result[i].Tag:=i;
 end;
end;

function TStringsHistoryW.GetCurrentPos: integer;
begin
 Result:=FPosition+1;
end;

function TStringsHistoryW.GetForwardHistory: TArExplorerPath;
var
  i : integer;
begin
 SetLength(Result,0);
 If FPosition=-1 then Exit;
 For i:=FPosition+1 to Length(fArray)-1 do
 begin
  SetLength(Result,Length(Result)+1);
  Result[i-FPosition-1]:=fArray[i];
  Result[i-FPosition-1].Tag:=i;
 end;
end;

function TStringsHistoryW.LastPath: TExplorerPath;
begin
 Result:=ExplorerPath('',0);
 if FPosition=-1 then Exit;
 Result:=fArray[FPosition];
end;

procedure TStringsHistoryW.SetOnChange(const Value: TNotifyEvent);
begin
 fOnChange:=Value;
end;

{ TIcon48 }

function TIcon48.GetHeight: Integer;
begin
 Result:=48;
end;

function TIcon48.GetWidth: Integer;
begin
 Result:=48;
end;

{ TExplorerFileInfos }

procedure TExplorerFileInfos.Add(Info: TExplorerFileInfo);
begin
  FItems.Add(Info);
end;

constructor TExplorerFileInfos.Create;
begin
  FItems := TList.Create;
end;

procedure TExplorerFileInfos.Delete(I: Integer);
begin
  FItems.Delete(I);
end;

procedure TExplorerFileInfos.Remove(Info: TExplorerFileInfo);
begin
  FItems.Remove(Info);
end;

destructor TExplorerFileInfos.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

function TExplorerFileInfos.GeInfoByIndex(
  Index: Integer): TExplorerFileInfo;
begin
  Result := FItems[Index];
end;

function TExplorerFileInfos.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TExplorerFileInfos.Clear;
var
  I : Integer;
begin
  for I := 0 to FItems.Count - 1 do
    TExplorerFileInfo(FItems[I]).Free;
  FItems.Clear;
end;

procedure TExplorerFileInfos.Exchange(Index1, Index2: Integer);
begin
  FItems.Exchange(Index1, Index2);
end;

procedure TExplorerFileInfos.Assign(Source: TExplorerFileInfos);
var
  I : Integer;
begin
  Clear;
  for I := 0 to Source.Count - 1 do
    Add(Source[i].Clone);
end;

function TExplorerFileInfos.Clone: TExplorerFileInfos;
var
  I : Integer;
begin
  Result := TExplorerFileInfos.Create;
  for I := 0 to Count - 1 do
    Result.Add(Self[i].Clone);
end;

{ TExplorerFileInfo }

function TExplorerFileInfo.Clone: TExplorerFileInfo;
begin
  Result := TExplorerFileInfo.Create;
  Result.FileName := FileName;
  Result.SID := SID;
  Result.FileType := FileType;
  Result.ID := ID;
  Result.Rotate := Rotate;
  Result.Access := Access;
  Result.Rating := Rating;
  Result.FileSize := FileSize;
  Result.Comment := Comment;
  Result.KeyWords := KeyWords;
  Result.Date := Date;
  Result.Time := Time;
  Result.ImageIndex := ImageIndex;
  Result.Owner := Owner;
  Result.Groups := Groups;
  Result.Collections := Collections;
  Result.IsDate := IsDate;
  Result.IsTime := IsTime;
  Result.Crypted := Crypted;
  Result.Tag := Tag;
  Result.Loaded := Loaded;
  Result.Include := Include;
  Result.Links := Links;
  Result.isBigImage := isBigImage;
end;

initialization

 LockedFiles[1]:='';
 LockedFiles[2]:='';

end.
