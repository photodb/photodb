unit ExplorerTypes;

interface

uses Forms, SysUtils, Windows, Graphics,
  Messages, Classes, DB, GraphicsCool, JPEG, SyncObjs,
  UnitDBDeclare, UnitDBCommon, UnitDBCommonGraphics, uFileUtils,
  uMemory;

type
  PFileNotifyInformation = ^TFileNotifyInformation;

  TFileNotifyInformation = record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: array [0 .. 0] of WideChar;
  end;

const
  FILE_LIST_DIRECTORY = $0001;

type
  TExplorerViewInfo = record
    ShowPrivate: Boolean;
    ShowFolders: Boolean;
    ShowSimpleFiles: Boolean;
    ShowImageFiles: Boolean;
    ShowHiddenFiles: Boolean;
    ShowAttributes: Boolean;
    ShowThumbNailsForFolders: Boolean;
    SaveThumbNailsForFolders: Boolean;
    ShowThumbNailsForImages: Boolean;
    OldFolderName: string;
    View: Integer;
    PictureSize: Integer;
  end;

type
  TUpdaterInfo = record
    FileName: string;
    IsUpdater: Boolean;
    ID: Integer;
    ProcHelpAfterUpdate: TNotifyEvent;
    NewFileItem: Boolean;
  end;

type
  TFolderImages = record
    Images: array [1 .. 4] of TBitmap;
    FileNames: array [1 .. 4] of string;
    FileDates: array [1 .. 4] of TDateTime;
    Directory: string;
    Width: Integer;
    Height: Integer;
  end;

const
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
  THREAD_PREVIEW_MODE_BIG_IMAGE  = 2;
  THREAD_PREVIEW_MODE_DIRECTORY  = 3;
  THREAD_PREVIEW_MODE_EXIT       = 0;

  LV_THUMBS     = 0;
  LV_ICONS      = 1;
  LV_SMALLICONS = 2;
  LV_TITLES     = 3;
  LV_TILE       = 4;
  LV_GRID       = 5;

type
  TExplorerPath = record
    Path: string;
    PType: Integer;
    Tag: Integer;
  end;

  TArExplorerPath = array of TExplorerPath;

type
  // Структура с информацией об изменении в файловой системе (передается в callback процедуру)

  PInfoCallback = ^TInfoCallback;

  TInfoCallback = record
    FAction: Integer; // тип изменения (константы FILE_ACTION_XXX)
    // FDrive       : string;  // диск, на котором было изменение
    FOldFileName: string; // имя файла до переименования
    FNewFileName: string; // имя файла после переименования
  end;

  TInfoCallBackDirectoryChangedArray = array of TInfoCallback;

  // callback процедура, вызываемая при изменении в файловой системе
  TWatchFileSystemCallback = procedure(PInfo: TInfoCallBackDirectoryChangedArray) of object;

  TNotifyDirectoryChangeW = Procedure(Sender : TObject; SID : string; pInfo: TInfoCallBackDirectoryChangedArray) of Object;

   TExplorerFileInfos = class(TObject)
  private
    FItems: TList;
    function GeInfoByIndex(index: Integer): TExplorerFileInfo;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Info: TExplorerFileInfo);
    procedure Remove(Info: TExplorerFileInfo);
    procedure Delete(I: Integer);
    procedure Clear;
    procedure Exchange(Index1, Index2: Integer);
    procedure Assign(Source: TExplorerFileInfos);
    function Clone: TExplorerFileInfos;
    property Count: Integer read GetCount;
    property Items[index: Integer]: TExplorerFileInfo read GeInfoByIndex; default;
  end;

procedure AddOneExplorerFileInfo(Infos: TExplorerFileInfos; FileName: string; FileType, ImageIndex: Integer;
  SID: TGUID; ID, Rating, Rotate, Access, FileSize: Integer; Comment, KeyWords, Groups: string; Date : TDateTime; IsDate, Crypted, Include : Boolean);

type
  TExplorerThreadNotifyDirectoryChange = class(TThread)
  private
   FSID : String;
   FDirectory : String;
   FParentSID : Pointer;
   FOwner : TForm;
   FOnNotifyFile : TNotifyDirectoryChangeW;
   Terminating : Boolean;
    FOldFileName: TArStrings;
    FNewFileName: string;
    FAction: TArInteger;
  protected
    procedure Execute; override;
    procedure NotifyFile;
  public
    constructor Create(Owner: TForm; Directory: string; OnNotify: TNotifyDirectoryChangeW;
      SID: string; ParentSID: Pointer);
  end;

type
  TStringsHistoryW = class(TObject)
  private
    { Private declarations }
    FArray: array of TExplorerPath;
    FPosition: Integer;
    FOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetItem(Index: Integer): TExplorerPath;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure Add(Path: TExplorerPath);
    function CanBack: Boolean;
    function CanForward: Boolean;
    function GetCurrentPos: Integer;
    function DoBack: TExplorerPath;
    function DoForward: TExplorerPath;
    function LastPath: TExplorerPath;
    function GetBackHistory: TArExplorerPath;
    function GetForwardHistory: TArExplorerPath;
    procedure Clear;
    property OnHistoryChange: TNotifyEvent read FOnChange write SetOnChange;
    property Position : Integer read FPosition write FPosition;
    property Items[Index : Integer] : TExplorerPath read GetItem; default;
  end;

type
  TExplorerFolders = class(TObject)
  private
    FImages: array of TFolderImages;
    FSaveFoldersToDB: Boolean;
    FSync: TCriticalSection;
    procedure SetSaveFoldersToDB(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveFolderImages(FolderImages: TFolderImages; Width: Integer; Height: Integer);
    function GetFolderImages(Directory: string; Width: Integer; Height: Integer): TFolderImages;
    property SaveFoldersToDB: Boolean read FSaveFoldersToDB write SetSaveFoldersToDB;
    procedure CheckFolder(Folder: string);
    procedure Clear;
  end;

type
  TIcon48 = class(TIcon)
  protected
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
  end;

function ExplorerPath(Path: string; PType: Integer): TExplorerPath;

var
  LockedFiles: array [1 .. 2] of String;
  LockTime : TDateTime;

implementation

uses ExplorerUnit;

function ExplorerPath(Path : string; PType: Integer): TExplorerPath;
begin
  Result.Path := Path;
  Result.PType := PType;
end;

{ TExplorerFolders }

procedure TExplorerFolders.CheckFolder(Folder: string);
var
  I, K, L: Integer;
begin
  FSync.Enter;
  try
    for I := Length(FImages) - 1 downto 9  do
    begin
      if AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(Folder) then
      for k:=1 to 4 do
      if FImages[I].FileNames[K] = '' then
      begin
        for L := 1 to 4 do
          F(FImages[I].Images[L]);

        for L := I to Length(FImages) - 2 do
          FImages[L] := FImages[L + 1];
        if Length(FImages) > 0 then
          SetLength(FImages, Length(FImages) - 1);
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerFolders.Clear;
var
  I, J: Integer;
begin
  FSync.Enter;
  try
    for I := 0 to Length(FImages) - 1 do
      for J := 1 to 4 do
        F(FImages[I].Images[J]);
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
var
  i, j, k, w, h : integer;
  b : Boolean;
begin
  FSync.Enter;
  try
    FormatDir(Directory);
    Result.Directory := '';
    for I := 1 to 4 do
      F(Result.Images[I]);

    for I := 0 to Length(FImages)-1 do
    begin
      if (AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(Directory))
        and (Width <= FImages[i].Width) then
      begin
        B := True;
        for K := 1 to 4 do
          if FImages[I].FileNames[K]<>'' then
            if not FileExists(FImages[I].FileNames[K]) then
            begin
              B := False;
              Break;
            end;
        if B then
          for k:=1 to 4 do
            if FImages[I].FileNames[K] <> '' then
              if FImages[I].FileDates[K] <> GetFileDateTime(FImages[I].FileNames[K]) then
              begin
                B := False;
                Break;
              end;
        if B then
        begin
          Result.Directory := Directory;
          for J := 1 to 4 do
          begin
            Result.Images[J] := TBitmap.create;
            if FImages[I].Images[J] <> nil then
            begin
              W := FImages[I].Images[J].Width;
              H := FImages[I].Images[J].height;
              ProportionalSize(Width, Height, W, H);
              DoResize(W, H, FImages[I].Images[J], Result.Images[J]);
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
  Width : Integer; Height : Integer);
var
  I, J : integer;
  B : Boolean;
  L : Integer;
begin
  FSync.Enter;
  try
    B := False;
    FormatDir(FolderImages.Directory);
    for I := 0 to Length(FImages) - 1 do
    begin
      if AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(FolderImages.Directory) then
      if FImages[I].Width < Width then
      begin
        FImages[I].Width := Width;
        FImages[I].Height := Height;
        FImages[I].Directory := FolderImages.Directory;
        for J := 1 to 4 do
          FImages[I].FileNames[J] := FolderImages.FileNames[J];
        for J := 1 to 4 do
          FImages[I].FileDates[J] := FolderImages.FileDates[J];
        for J := 1 to 4 do
          F(FImages[I].Images[J]);

        for J := 1 to 4 do
        begin
          if FolderImages.Images[J] = nil then
            Break;
          FImages[I].Images[J] := TBitmap.Create;
          AssignBitmap(FImages[I].Images[J], FolderImages.Images[J]);
        end;
        B := True;
        Break;
     end;
   end;
   if not B and (FolderImages.Images[1] <> nil) then
   begin
     SetLength(FImages, Length(FImages) + 1);
     L := Length(FImages) - 1;
     FImages[L].Width := Width;
     FImages[L].Height := Height;
     FImages[L].Directory := FolderImages.Directory;
     for I := 1 to 4 do
       FImages[L].FileNames[I] := FolderImages.FileNames[I];
     for I := 1 to 4 do
       FImages[L].FileDates[I] := FolderImages.FileDates[I];
     for I := 1 to 4 do
       FImages[L].Images[i]:=nil;
     for I := 1 to 4 do
     begin
       if FolderImages.Images[I] = nil then
         Break;
       FImages[L].Images[I] := TBitmap.Create;
       AssignBitmap(FImages[L].Images[I], FolderImages.Images[I]);
     end;
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

constructor TExplorerThreadNotifyDirectoryChange.Create(Owner : TForm;
  Directory: string; OnNotify: TNotifyDirectoryChangeW; SID: string; ParentSID : Pointer);
begin
  inherited Create(False);
  FOnNotifyFile := OnNotify;
  FDirectory := Directory;
  FormatDir(fDirectory);
  FOwner := Owner;
  FSID := SID;
  FParentSID := ParentSID;
  Terminating := false;
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
  FileName:=ExtractFileDir(FileName);
  if AnsiLowerCase(FileName)=AnsiLowerCase(Directory) then
  result:=true else Result:=false;
 end;

Const
 BUF_SIZE = 65535;
begin
 inherited;
 FreeOnTerminate:=true;
 fNewFileName:='';

 hDir := CreateFile (PWideChar(FDirectory),GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE
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

function TStringsHistoryW.GetItem(Index: Integer): TExplorerPath;
begin
  Result := FArray[Index];
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

initialization

 LockedFiles[1]:='';
 LockedFiles[2]:='';

end.



