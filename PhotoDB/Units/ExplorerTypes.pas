unit ExplorerTypes;

interface

uses Forms, SysUtils, Windows, Graphics, UnitDBDeclare,
  Messages, Classes, DB, GraphicsCool, JPEG, SyncObjs,
  UnitDBCommon, UnitDBCommonGraphics, uFileUtils,
  uMemory, uDBPopupMenuInfo;

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
  TFolderImages = record
    Images: array [1 .. 4] of TBitmap;
    FileNames: array [1 .. 4] of string;
    FileDates: array [1 .. 4] of TDateTime;
    Directory: string;
    Width: Integer;
    Height: Integer;
  end;

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
    FOldFileName: string; // имя файла до переименования
    FNewFileName: string; // имя файла после переименования
  end;

  TInfoCallBackDirectoryChangedArray = array of TInfoCallback;

  // callback процедура, вызываемая при изменении в файловой системе
  TWatchFileSystemCallback = procedure(PInfo: TInfoCallBackDirectoryChangedArray) of object;

  TNotifyDirectoryChangeW = Procedure(Sender : TObject; SID : string; pInfo: TInfoCallBackDirectoryChangedArray) of Object;

  TExplorerFileInfo = class(TDBPopupMenuInfoRecord)
  protected
    function InitNewInstance : TDBPopupMenuInfoRecord; override;
  public
    IsBigImage: Boolean;
    SID : TGUID;
    FileType : Integer;
    Tag : Integer;
    Loaded : Boolean;
    ImageIndex : Integer;
    function Copy : TDBPopupMenuInfoRecord; override;
  end;

  TExplorerFileInfos = class(TDBPopupMenuInfo)
  private
    function GetValueByIndex(Index: Integer): TExplorerFileInfo;
    procedure SetValueByIndex(Index: Integer; const Value: TExplorerFileInfo);
  public
    property ExplorerItems[Index: Integer]: TExplorerFileInfo read GetValueByIndex write SetValueByIndex; default;
  end;

type
  TUpdaterInfo = record
    IsUpdater: Boolean;
    UpdateDB : Boolean;
    ProcHelpAfterUpdate: TNotifyEvent;
    NewFileItem: Boolean;
    FileInfo : TExplorerFileInfo;
  end;

procedure AddOneExplorerFileInfo(Infos: TExplorerFileInfos; FileName: string; FileType, ImageIndex: Integer;
  SID: TGUID; ID, Rating, Rotate, Access, FileSize: Integer; Comment, KeyWords, Groups: string; Date : TDateTime; IsDate, Crypted, Include : Boolean);

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

  TLockedFile = class(TObject)
  public
    DateOfUnLock : TDateTime;
    FileName : string;
  end;

  TLockFiles = class(TObject)
  private
    FFiles : TList;
    FSync : TCriticalSection;
  public
    constructor Create;
    class function Instance : TLockFiles;
    destructor Destroy; override;
    function AddLockedFile(FileName : string; LifeTimeMs : Integer) : TLockedFile;
    function RemoveLockedFile(FileName : string) : Boolean;
    function IsFileLocked(FileName : string) : Boolean;
  end;

function ExplorerPath(Path: string; PType: Integer): TExplorerPath;

implementation

uses ExplorerUnit;

var
  LockedFiles : TLockFiles = nil;

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
    for I := Length(FImages) - 1 downto 0 do
    begin
      if AnsiLowerCase(FImages[I].Directory) = AnsiLowerCase(Folder) then
      for k := 1 to 4 do
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

procedure AddOneExplorerFileInfo(Infos : TExplorerFileInfos; FileName : String; FileType, ImageIndex : Integer; SID : TGUID; ID, Rating, Rotate, Access, FileSize : Integer; Comment, KeyWords, Groups : String; Date : TDateTime; IsDate, Crypted, Include : Boolean);
var
  Info : TExplorerFileInfo;
begin
  Info := TExplorerFileInfo.Create;
  Info.FileName:=FileName;
  Info.ID:=ID;
  Info.FileType:=FileType;
  Info.SID:=SID;
  Info.Rotation:=Rotate;
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
  if FPosition = Length(FArray) - 1 then
  begin
    SetLength(FArray,Length(FArray) + 1);
    FArray[Length(FArray) - 1]:=Path;
    FPosition:= Length(FArray) - 1;
  end else
  begin
    SetLength(FArray, FPosition + 2);
    FArray[FPosition + 1] := Path;
    FPosition := FPosition + 1;
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.CanBack: Boolean;
begin
  Result := FPosition > 0
end;

function TStringsHistoryW.CanForward: boolean;
begin
  if FPosition = -1 then
    Result := False
  else
    Result := (FPosition <> Length(FArray) - 1) and (Length(FArray) <> 1)
end;

procedure TStringsHistoryW.Clear;
begin
  FPosition := -1;
  SetLength(FArray, 0);
end;

constructor TStringsHistoryW.Create;
begin
  inherited;
  FPosition := -1;
  SetLength(FArray, 0);
  fOnChange := nil;
end;

destructor TStringsHistoryW.Destroy;
begin
  SetLength(FArray, 0);
  inherited;
end;

function TStringsHistoryW.DoBack: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if FPosition = 0 then
    Result := FArray[0]
  else
  begin
    Dec(FPosition);
    Result := FArray[FPosition];
  end;

  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.DoForward: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  if (FPosition = Length(FArray)-1) or (Length(FArray)=1) then
    Result := FArray[Length(FArray) - 1]
  else
  begin
    Inc(FPosition);
    Result := FArray[FPosition];
  end;
  if Assigned(OnHistoryChange) then
    OnHistoryChange(Self);
end;

function TStringsHistoryW.GetBackHistory: TArExplorerPath;
var
  I : Integer;
begin
  SetLength(Result, 0);
  if FPosition = -1 then
    Exit;

  for I := 0 to FPosition - 1 do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[I] := FArray[I];
    Result[I].Tag := I;
  end;
end;

function TStringsHistoryW.GetCurrentPos: integer;
begin
  Result := FPosition + 1;
end;

function TStringsHistoryW.GetForwardHistory: TArExplorerPath;
var
  I : Integer;
begin
  SetLength(Result, 0);
  if FPosition = -1 then
    Exit;

  for I := FPosition + 1 to Length(FArray) - 1 do
  begin
    SetLength(Result,Length(Result) + 1);
    Result[I - FPosition - 1] := FArray[I];
    Result[I - FPosition - 1].Tag := I;
  end;
end;

function TStringsHistoryW.GetItem(Index: Integer): TExplorerPath;
begin
  Result := FArray[Index];
end;

function TStringsHistoryW.LastPath: TExplorerPath;
begin
  Result := ExplorerPath('', 0);

  if FPosition = -1 then
    Exit;

  Result := FArray[FPosition];
end;

procedure TStringsHistoryW.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

{ TIcon48 }

function TIcon48.GetHeight: Integer;
begin
  Result := 48;
end;

function TIcon48.GetWidth: Integer;
begin
  Result := 48;
end;

procedure TExplorerFileInfos.SetValueByIndex(Index: Integer;
  const Value: TExplorerFileInfo);
begin
  FData[Index] := Value;
end;

function TExplorerFileInfos.GetValueByIndex(Index: Integer): TExplorerFileInfo;
begin
   Result := FData[Index];
end;

{ TLockFiles }

function TLockFiles.AddLockedFile(FileName: string; LifeTimeMs: Integer) : TLockedFile;
var
  I : Integer;
  FFile : TLockedFile;
begin
  FSync.Enter;
  try
    FileName := AnsiLowerCase(FileName);
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if FFile.FileName = FileName then
      begin
        FFile.DateOfUnLock := Now + LifeTimeMs / 1000;
        Result := FFile;
        Exit;
      end;
    end;
    Result := TLockedFile.Create;
    Result.FileName := FileName;
    Result.DateOfUnLock := Now + LifeTimeMs / 1000;
    FFiles.Add(Result);
  finally
    FSync.Leave;
  end;
end;

constructor TLockFiles.Create;
begin
  FFiles := TList.Create;
  FSync := TCriticalSection.Create;
end;

destructor TLockFiles.Destroy;
begin
  F(FFiles);
  F(FSync);
  inherited;
end;

class function TLockFiles.Instance: TLockFiles;
begin
  if LockedFiles = nil then
    LockedFiles := TLockFiles.Create;

  Result := LockedFiles;
end;

function TLockFiles.IsFileLocked(FileName: string): Boolean;
var
  I : Integer;
  FFile : TLockedFile;
  ANow : TDateTime;
begin
  Result := False;
  ANow := Now;
  FileName := AnsiLowerCase(FileName);
  FSync.Enter;
  try
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if FFile.DateOfUnLock < ANow then
      begin
        FFiles.Remove(FFile);
        F(FFile);
        Continue;
      end;
      if AnsiLowerCase(FFile.FileName) = FileName then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TLockFiles.RemoveLockedFile(FileName: string): Boolean;
var
  I : Integer;
  FFile : TLockedFile;
begin
  FSync.Enter;
  Result := False;
  FileName := AnsiLowerCase(FileName);
  try
    for I := FFiles.Count - 1 downto 0 do
    begin
      FFile := TLockedFile(FFiles[I]);
      if AnsiLowerCase(FFile.FileName) = FileName then
      begin
        FFiles.Remove(FFile);
        F(FFile);
        Result := True;
        Break;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

{ TExplorerFileInfo }

function TExplorerFileInfo.Copy: TDBPopupMenuInfoRecord;
var
  Info : TExplorerFileInfo;
begin
  Result := inherited Copy;
  Info := Result as TExplorerFileInfo;

  Info.SID := SID;
  Info.FileType := FileType;
  Info.IsBigImage := IsBigImage;
  Info.Tag := Tag;
  Info.Loaded := Loaded;
  Info.ImageIndex := ImageIndex;
end;

function TExplorerFileInfo.InitNewInstance: TDBPopupMenuInfoRecord;
begin
  Result := TExplorerFileInfo.Create;
end;

initialization

finalization

  F(LockedFiles);

end.
