unit UnitCDMappingSupport;

interface

uses
  Windows, Classes, SysUtils, StrUtils, UnitDBFileDialogs,
  Dolphin_DB, UnitDBDeclare, Language, uVistaFuncs, uFileUtils,
  uMemory, uTranslate, uConstants;

type
 // File strusts//////////////////////////////////////
  TCDIndexFileHeader = record
    ID: string[20];
    Version: Byte;
    DBVersion: Integer;
  end;

  TCDIndexFileHeaderV1 = record
    CDLabel: string[255];
    Date: TDateTime;
  end;

  TCDIndexInfo = record
    CDLabel: string[255];
    Date: TDateTime;
    DBVersion: Integer;
    Loaded: Boolean;
  end;

  // DB Structs/////////////////////////////////////////
  TCDDataArrayItem = record
    name: string[255];
    CDRelativePath: string;
  end;

  TCDDataArray = record
    CDName: string;
    Data: array of TCDDataArrayItem;
  end;

  TCDIndexMappingDirectory = class
  private
    FFiles : TList;
    function GetFileByIndex(FileIndex: Integer): TCDIndexMappingDirectory;
    function GetCount: Integer;
  public
    Name: string;
    IsFile: Boolean;
    Parent: TCDIndexMappingDirectory;
    IsReal: Boolean;
    RealFileName: string;
    DB_ID: Integer;
    FileSize: Int64;
    constructor Create;
    destructor Destroy; override;
    function Add(Item : TCDIndexMappingDirectory) : Integer;
    property Items[FileIndex : Integer] : TCDIndexMappingDirectory read GetFileByIndex; default;
    property Count : Integer read GetCount;
    procedure Remove(var Item : TCDIndexMappingDirectory);
    procedure Delete(Index : Integer);
  end;

  TDBFilePath = record
    FileName: string;
    ID: Integer;
  end;

  TDBFilePathArray = array of TDBFilePath;

  TCDIndexMapping = class(TObject)
  private
    ClipboardCut: Boolean;
    Clipboard: TList;
    Root: TCDIndexMappingDirectory;
    CurrentDir: TCDIndexMappingDirectory;
    Mapping: TCDDataArray;
    FCDLabel: string;
    function GetCurrentPathWithDirectory(Directory: TCDIndexMappingDirectory; Init: Boolean = True): string;
    procedure GetDBRemappingArrayWithDirectory(Directory: TCDIndexMappingDirectory; var Info: TDBFilePathArray);
    procedure SetCDLabel(const Value: string);
    function CreateStructureToDirectoryWithDirectory(Directory: string; PDirectory: TCDIndexMappingDirectory;
      OnProgress: TCallBackProgressEvent): Boolean;
    function GetCurrentUpperDirectoriesWithDirectory(PDirectory: TCDIndexMappingDirectory): TStrings;
    function DeleteOriginalStructureWithDirectory(PDirectory: TCDIndexMappingDirectory;
      OnProgress: TCallBackProgressEvent): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateDirectory(Directory: string): Boolean;
    function GoUp: Boolean;
    function SelectDirectory(Directory: string): Boolean;
    function DirectoryExists(Directory: string): Boolean;
    function FileExists(FileName: string): Boolean;
    procedure AddRealItemsToCurrentDirectory(Files: TStrings);
    function AddRealDirectory(Directory: string; CallBackProc: TCallBackProgressEvent): Boolean;
    function AddRealFile(FileName: string): Boolean;
    function AddImageFile(Path: TDBFilePath): Boolean;
    function TextReadLevel: TStrings;
    function CheckName(FileName: string): string;
    function GetItemNameByIndex(index: Integer): string;
    function GetCDIndex: TCDDataArray;
    function DeleteDirectory(Directory: string): Boolean;
    function DeleteFile(FileName: string): Boolean;
    function GetCurrentPath: string;
    function CreateStructureToDirectory(Directory: string; OnProgress: TCallBackProgressEvent): Boolean;
    function GetItemByIndex(index: Integer): TCDIndexMappingDirectory;
    function GetDBRemappingArray: TDBFilePathArray;
    function GetCDSize: Int64;
    function CurrentLevel: TCDIndexMappingDirectory;
    function GetCDSizeWithDirectory(Directory: TCDIndexMappingDirectory): Int64;
    procedure SortLevel(Level: TList);
    function GetCurrentUpperDirectories: TStrings;
    procedure SelectRoot;
    procedure SelectPath(Path: string);
    procedure Copy(Files: TList);
    procedure Cut(Files: TList);
    procedure Paste;
    procedure ClearClipBoard;
    function CloneItem(Item: TCDIndexMappingDirectory): TCDIndexMappingDirectory;
    function DirectoryHasDBFiles(Directory: TCDIndexMappingDirectory): Boolean;
    function DeleteOriginalStructure(OnProgress: TCallBackProgressEvent): Boolean;
    function GetRoot: TCDIndexMappingDirectory;
    function PlaceMapFile(Directory: string): Boolean;
    class function ReadMapFile(FileName: string): TCDIndexInfo;
    property CDLabel: string read FCDLabel write SetCDLabel;
  end;

const
  TCD_CLASS_TAG_NONE = 0;
  TCD_CLASS_TAG_NO_QUESTION = 1;

  C_CD_MAP_FILE = 'DBCDMap.map';

type
  TCDClass = class(TObject)
  public
    Name: string;
    Path: string;
    Tag: Integer;
  end;

//  PCDClass = ^TCDClass;

  TCDDBMapping = class(TObject)
  private
    CDLoadedList: TList;
    CDFindedList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCDByName(CDName: string): TCDClass;
    function GetCDByNameInternal(CDName: string): TCDClass;
    procedure DoProcessPath(var FileName: string; CanUserNotify: Boolean = False);
    function ProcessPath(FileName: string; CanUserNotify: Boolean = False): string;
    procedure AddCDMapping(CDName: string; Path: string; Permanent: Boolean);
    procedure RemoveCDMapping(CDName: string);
    function GetFindedCDList: TList;
    procedure SetCDWithNOQuestion(CDName: string);
    procedure UnProcessPath(var Path: string);
  end;

var
  CDMapper: TCDDBMapping = nil;

function ProcessPath(FileName: string; CanUserNotify: Boolean = False): string;
procedure DoProcessPath(var FileName: string; CanUserNotify: Boolean = False);
function AddCDLocation(CDName: string = ''): string;
procedure UnProcessPath(var FileName: string);
function StaticPath(FileName: string): Boolean;

implementation

uses UnitFormCDMapInfo;

function StaticPath(FileName: string): Boolean;
begin
  Result := True;
  if Copy(FileName, 1, 2) = '::' then
    if PosEx('::', FileName, 3) > 0 then
      Result := False;
end;

procedure DoProcessPath(var FileName: string; CanUserNotify: Boolean = False);
begin
  if CDMapper = nil then
    CDMapper := TCDDBMapping.Create;
  CDMapper.DoProcessPath(FileName, CanUserNotify);
end;

procedure UnProcessPath(var FileName: string);
begin
  if CDMapper = nil then
    CDMapper := TCDDBMapping.Create;
  CDMapper.UnProcessPath(FileName);
end;

function ProcessPath(FileName: string; CanUserNotify: Boolean = False): string;
begin
  if CDMapper = nil then
    CDMapper := TCDDBMapping.Create;
  Result := CDMapper.ProcessPath(FileName, CanUserNotify);
end;

function GetValidCDIndexInFolder(Dir: string): string;
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  Result := '';
  FormatDir(Dir);

  if FileExists(Dir + C_CD_MAP_FILE) then
  begin
    if TCDIndexMapping.ReadMapFile(Dir + C_CD_MAP_FILE).Loaded then
    begin
      Result := Dir + C_CD_MAP_FILE;
      Exit;
    end;
  end;

  Found := FindFirst(Dir + '*', FaDirectory, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      if DirectoryExists(Dir + SearchRec.name) then
      begin
        Result := GetValidCDIndexInFolder(Dir + SearchRec.name);
        if Result <> '' then
          Break;
      end;
    end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;


function AddCDLocation(CDName: string = ''): string;
var
  OpenDialog: DBOpenDialog;
  Path, Dir: string;
  Info: TCDIndexInfo;

  procedure LoadInfoByPath;
  begin
    Info := TCDIndexMapping.ReadMapFile(Path);
    if CDMapper = nil then
      CDMapper := TCDDBMapping.Create;
    CDMapper.AddCDMapping(Info.CDLabel, ExtractFilePath(Path), False);
    Result := Info.CDLabel;
  end;

begin
  Result := '';
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := Format(TA('CD Index (%s)|%s', 'CDExport'), [C_CD_MAP_FILE, C_CD_MAP_FILE]);
    OpenDialog.FilterIndex := 1;
    OpenDialog.EnableChooseWithDirectory;
    if OpenDialog.Execute then
    begin
      Path := OpenDialog.FileName;
      if FileExists(Path) then
      begin
        if AnsiLowerCase(ExtractFileName(Path)) = AnsiLowerCase(C_CD_MAP_FILE) then
          LoadInfoByPath
        else
          MessageBoxDB(GetActiveFormHandle, Format(
            TA('Unable to find file %s by address "%s"', 'CDExport'), [C_CD_MAP_FILE, Path]),
            TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      end;
      Dir := ExcludeTrailingBackslash(Path);
      if DirectoryExists(Dir) then
      begin
        Path := GetValidCDIndexInFolder(Dir);
        if Path <> '' then
        begin
          LoadInfoByPath;
        end else
        begin
          if CDName <> '' then
            if ID_YES = MessageBoxDB(GetActiveFormHandle,
              Format(TA('In this directory file %s not found! Use this directory as root of drive "%s"?', 'CDExport'), [C_CD_MAP_FILE, CDName]),
              TA('Error'), TD_BUTTON_YESNO,
              TD_ICON_ERROR) then
            begin
              Dir := IncludeTrailingBackslash(Dir);
              CDMapper.AddCDMapping(CDName, Dir, False);
              Result := CDName;
            end;
        end;
      end;
    end;
  finally
    F(OpenDialog);
  end;
end;

{ TCDIndexMapping }

//TODO: Destroy

//MAPPING:
//label "PHOTOS"
//c:\dir\path\image.jpeg
//\folder\new_image.jpeg
//db ::PHOTOS::\folder\new_image.jpeg

//::drive_label::/path_on_drive

function GetFileSizeByName(FileName: String): int64;
var
  FindData: TWin32FindData;
  hFind: THandle;
begin
  Result := 0;
  hFind := FindFirstFile(PChar(FileName), FindData);
  if hFind <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(hFind);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := FindData.NFileSizeHigh * 2 * MaxInt + FindData.NFileSizeLow;
  end;
end;

function DBFilePath(FileName: string; ID: Integer): TDBFilePath;
begin
  Result.FileName := FileName;
  Result.ID := ID;
end;

function TCDIndexMapping.AddImageFile(Path: TDBFilePath): Boolean;
var
  Image: TCDIndexMappingDirectory;
begin
  Result := False;
  if not FileExists(ExtractFileName(Path.FileName)) then
  begin
    Image := TCDIndexMappingDirectory.Create;
    Image.Name := ExtractFileName(Path.FileName);
    Image.IsFile := True;
    Image.Parent := CurrentDir;
    Image.IsReal := True;
    Image.DB_ID := Path.ID;
    Image.FileSize := GetFileSizeByName(Path.FileName);
    Image.RealFileName := Path.FileName;
    CurrentDir.Add(Image);
    Result := True;
  end;
end;

//todo: recursive add files!
function TCDIndexMapping.AddRealDirectory(Directory: string; CallBackProc: TCallBackProgressEvent): Boolean;
var
  Found: Integer;
  SearchRec: TSearchRec;
  Info: TProgressCallBackInfo;
  DBInfo: TRecordsInfo;
  I, N: Integer;
begin
  CreateDirectory(ExtractFileName(Directory));
  SelectDirectory(ExtractFileName(Directory));
  FormatDir(Directory);
  Found := FindFirst(Directory + '*', FaDirectory, SearchRec);
  Info.MaxValue := 0;
  Info.Position := 0;
  Info.Information := '';
  Info.Terminate := False;
  N := 0;
  Dolphin_DB.GetFileListByMask(Directory, '*.*', DBInfo, N, True);
  for I := 0 to Length(DBInfo.ItemFileNames) - 1 do
  begin
    if DBInfo.ItemIds[I] = 0 then
      AddRealFile(DBInfo.ItemFileNames[I])
    else
      AddImageFile(DBFilePath(DBInfo.ItemFileNames[I], DBInfo.ItemIds[I]));
    Info.MaxValue := Info.MaxValue + GetFileSizeByName(DBInfo.ItemFileNames[I]);

    if Assigned(CallBackProc) then
      CallBackProc(Self, Info);
    if Info.Terminate then
      Break;
  end;
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      if SysUtils.DirectoryExists(Directory + SearchRec.name) then
        AddRealDirectory(Directory + SearchRec.name, CallBackProc);
    end;
    Found := SysUtils.FindNext(SearchRec);
    if Assigned(CallBackProc) then
      CallBackProc(Self, Info);
    if Info.Terminate then
      Break;
  end;
  SysUtils.FindClose(SearchRec);
  GoUp;
  Result := True;
end;

function TCDIndexMapping.AddRealFile(FileName: string): Boolean;
var
  CDFile: TCDIndexMappingDirectory;
begin
  Result := False;

  if not FileExists(ExtractFileName(FileName)) then
  begin
    CDFile := TCDIndexMappingDirectory.Create;
    CDFile.Name := ExtractFileName(FileName);
    CDFile.IsFile := True;
    CDFile.Parent := CurrentDir;
    CDFile.IsReal := True;
    CDFile.DB_ID := 0;
    CDFile.RealFileName := FileName;
    CDFile.FileSize := GetFileSizeByName(FileName);
    CurrentDir.Add(CDFile);
    Result := True;
  end;
end;

procedure TCDIndexMapping.AddRealItemsToCurrentDirectory(Files: TStrings);
var
  I: Integer;
  Info: TOneRecordInfo;
begin
  for I := 0 to Files.Count - 1 do
  begin
    if SysUtils.DirectoryExists(Files[I]) then
      AddRealDirectory(Files[I], nil);
    if FileExistsEx(Files[I]) then
    begin
      if not GetInfoByFileNameA(Files[I], False, Info) then
        AddRealFile(Files[I])
      else
        AddImageFile(DBFilePath(Info.ItemFileName, Info.ItemId));
    end;
  end;
end;

function TCDIndexMapping.CheckName(FileName: string): string;
begin
  Result := Trim(FileName);
end;

constructor TCDIndexMapping.Create;
begin
  ClipboardCut := False;
  Clipboard := TList.Create;
  Root := TCDIndexMappingDirectory.Create;
  Root.Name := '\';
  Root.IsFile := False;
  Root.Parent := nil;
  Root.IsReal := False;
  Root.RealFileName := '';
  Root.DB_ID := 0;
  Root.FileSize := 0;
  CurrentDir := Root;
  SetLength(Mapping.Data, 0);
  Mapping.CDName := '';
end;

function TCDIndexMapping.CreateDirectory(Directory: string): Boolean;
var
  Dir: TCDIndexMappingDirectory;
begin
  Directory := CheckName(Directory);
  if not DirectoryExists(Directory) then
  begin
    Dir := TCDIndexMappingDirectory.Create;
    Dir.Name := Directory;
    Dir.IsFile := False;
    Dir.Parent := CurrentDir;
    Dir.IsReal := False;
    Dir.RealFileName := '';
    Dir.DB_ID := 0;
    Dir.FileSize := 0;
    CurrentDir.Add(Dir);
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

function TCDIndexMapping.CreateStructureToDirectory(
  Directory: string; OnProgress : TCallBackProgressEvent): Boolean;
begin
  Result := False;
  if not SysUtils.DirectoryExists(Directory) then
    if not CreateDirA(Directory) then
      Exit;
  FormatDir(Directory);
  Directory := Directory + CDLabel;

  if not SysUtils.DirectoryExists(Directory) then
    if not CreateDir(Directory) then
      Exit;

  if not SysUtils.DirectoryExists(Directory) then
    Exit;

  Result := CreateStructureToDirectoryWithDirectory(Directory, Root, OnProgress);
end;

function TCDIndexMapping.CreateStructureToDirectoryWithDirectory(
  Directory: string; PDirectory: TCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent): Boolean;
var
  I: Integer;
  DirectoryName, FileName: string;
  Info: TProgressCallBackInfo;
begin
  Result := True;
  for I := 0 to PDirectory.Count - 1 do
    if PDirectory[I].IsFile then
    begin
      FileName := PDirectory[I].Name;
      DirectoryName := Directory;
      FormatDir(DirectoryName);
      if AnsiLowerCase(PDirectory[I].RealFileName) <> AnsiLowerCase(DirectoryName + FileName) then
        if not Windows.CopyFile(PChar(PDirectory[I].RealFileName),
          PChar(DirectoryName + FileName), False) then
        begin
          Result := False;
          Exit;
        end else
        begin
          Info.MaxValue := -1;
          Info.Position := PDirectory[I].FileSize;
          Info.Information := '';
          Info.Terminate := False;
          if Assigned(OnProgress) then
            OnProgress(nil, Info);
          if Info.Terminate then
          begin
            Result := False;
            Exit;
          end;
        end;
    end;

  for I := 0 to PDirectory.Count - 1 do
    if not PDirectory[I].IsFile then
    begin
      DirectoryName := Directory;
      FormatDir(DirectoryName);
      DirectoryName := DirectoryName + PDirectory[I].Name;

      if not SysUtils.DirectoryExists(DirectoryName) then
        if not CreateDir(DirectoryName) then
        begin
          Result := False;
          Exit;
        end;
      CreateStructureToDirectoryWithDirectory(DirectoryName, PDirectory[I], OnProgress);
    end;

end;

function TCDIndexMapping.CurrentLevel: TCDIndexMappingDirectory;
begin
  SortLevel(CurrentDir.FFiles);
  Result := CurrentDir;
end;

function TCDIndexMapping.DeleteDirectory(Directory: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Count - 1 do
    if not CurrentDir[I].IsFile then
      if AnsiLowerCase(CurrentDir[I].Name) = AnsiLowerCase(Directory) then
      begin
        CurrentDir.Delete(I);
        Result := True;
        Break;
      end;
end;

function TCDIndexMapping.DeleteFile(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Count - 1 do
    if CurrentDir[I].IsFile then
      if AnsiLowerCase(CurrentDir[I].Name) = AnsiLowerCase(FileName) then
      begin
        CurrentDir.Delete(I);
        Result := True;
        Break;
      end;
end;

destructor TCDIndexMapping.Destroy;
begin
  F(Root);
  F(Clipboard);
  inherited Destroy;
end;

function TCDIndexMapping.DirectoryExists(Directory: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Count - 1 do
    if not CurrentDir[I].IsFile then
      if AnsiLowerCase(CurrentDir[I].Name) = AnsiLowerCase(Directory) then
        Result := True;
end;

function TCDIndexMapping.FileExists(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Count - 1 do
    if CurrentDir[I].IsFile then
      if AnsiLowerCase(CurrentDir[I].Name) = AnsiLowerCase(FileName) then
        Result := True;
end;

function TCDIndexMapping.GetCDIndex: TCDDataArray;
begin
  Result := Mapping;
end;

function TCDIndexMapping.GetCDSize: Int64;
begin
  Result := GetCDSizeWithDirectory(Root);
end;

function TCDIndexMapping.GetCurrentPath: string;
begin
  Result := GetCurrentPathWithDirectory(CurrentDir);
end;

function TCDIndexMapping.GetCurrentPathWithDirectory(Directory: TCDIndexMappingDirectory; Init: Boolean = True): string;
begin
  if Init then
    Result := '';
  if Directory.Parent = nil then
    Result := '\' + Result
  else
    Result := GetCurrentPathWithDirectory(Directory.Parent, False) + Directory.name + '\' + Result;
end;

function TCDIndexMapping.GetDBRemappingArray: TDBFilePathArray;
begin
  GetDBRemappingArrayWithDirectory(Root, Result);
end;

procedure TCDIndexMapping.GetDBRemappingArrayWithDirectory(
  Directory: TCDIndexMappingDirectory; var Info: TDBFilePathArray);
var
  I: Integer;
begin
  for I := 0 to Directory.Count - 1 do
    if Directory[I].IsFile then
      if Directory[I].DB_ID > 0 then
      begin
        SetLength(Info, Length(Info) + 1);
        Info[Length(Info) - 1].ID := Directory[I].DB_ID;
        Info[Length(Info) - 1].FileName := AnsiLowerCase('::' + CDLabel + '::' + GetCurrentPathWithDirectory(Directory) + Directory[I].Name);
      end;
  for I := 0 to Directory.Count - 1 do
    if not Directory[I].IsFile then
      GetDBRemappingArrayWithDirectory(Directory[I], Info);
end;

function TCDIndexMapping.GetCDSizeWithDirectory(
  Directory: TCDIndexMappingDirectory): int64;
var
  I: Integer;
begin
  Result := Directory.FileSize;
  for I := 0 to Directory.Count - 1 do
    if Directory[I].IsFile then
      Result := Result + Directory[I].FileSize;

  for I := 0 to Directory.Count - 1 do
    if not Directory[I].IsFile then
      Result := Result + GetCDSizeWithDirectory(Directory[I]);
end;

function TCDIndexMapping.GetItemByIndex(index: Integer): TCDIndexMappingDirectory;
begin
  Result := CurrentDir[index];
end;

function TCDIndexMapping.GetItemNameByIndex(index: Integer): string;
begin
  Result := CurrentDir[Index].Name;
end;

function TCDIndexMapping.GoUp: Boolean;
begin
  if CurrentDir.Parent <> nil then
  begin
    CurrentDir := CurrentDir.Parent;
    Result := True;
  end else
  begin
    Result := False;
  end;
end;

function TCDIndexMapping.SelectDirectory(Directory: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Count - 1 do
    if not CurrentDir[I].IsFile then
      if AnsiLowerCase(CurrentDir[I].Name) = AnsiLowerCase(Directory) then
      begin
        CurrentDir := CurrentDir[I];
        Break;
      end;
end;

procedure TCDIndexMapping.SetCDLabel(const Value: string);
begin
  FCDLabel := Value;
end;

function TCDIndexMapping.TextReadLevel: TStrings;
var
  I: Integer;
  Text: string;
begin
  Result := TStringList.Create;
  for I := 0 to CurrentDir.Count - 1 do
  begin
    if CurrentDir[I].IsFile then
      Text := '[File] '
    else
      Text := '[Directory] ';
    Text := Text + CurrentDir[I].name;
    Result.Add(Text);
  end;
end;

procedure TCDIndexMapping.SortLevel(Level: TList);
var
  I: Integer;
  Changed: Boolean;
  List: TList;
  LevelSize: Integer;
begin
  // Folders by text compare -> files by text compare
  Changed := False;
  List := TList.Create;
  try
    LevelSize := Level.Count;
    for I := Level.Count - 1 downto 0 do
    begin
      if not TCDIndexMappingDirectory(Level[I]).IsFile then
      begin
        List.Add(Level[I]);
        Level.Delete(I);
      end;
    end;
    if (List.Count = 0) or (List.Count = LevelSize) then
    begin
      if (List.Count = 0) then
        for I := Level.Count - 1 downto 1 do
        begin
          if SysUtils.CompareText(TCDIndexMappingDirectory(Level[I]).Name, TCDIndexMappingDirectory(Level[I - 1]).Name) < 0 then
          begin
            Level.Exchange(I, I - 1);
            Changed := True;
          end;
        end;

      if (List.Count = LevelSize) then
        for I := List.Count - 1 downto 1 do
        begin
          if SysUtils.CompareText(TCDIndexMappingDirectory(List[I]).Name, TCDIndexMappingDirectory(List[I - 1]).Name)
            < 0 then
          begin
            List.Exchange(I, I - 1);
            Changed := True;
          end;
        end;
    end
    else
    begin
      SortLevel(Level);
      SortLevel(List);
    end;
    for I := 0 to List.Count - 1 do
      Level.Insert(0, List[I]);
    if Changed then
      SortLevel(Level);
  finally
    F(List);
  end;
end;

function TCDIndexMapping.GetCurrentUpperDirectories: TStrings;
begin
  Result := GetCurrentUpperDirectoriesWithDirectory(CurrentDir);
end;

function TCDIndexMapping.GetCurrentUpperDirectoriesWithDirectory(
  PDirectory: TCDIndexMappingDirectory): TStrings;
begin
  if PDirectory.Parent = nil then
  begin
    Result := TStringList.Create;
    Result.Add('\');
  end else
  begin
    Result := GetCurrentUpperDirectoriesWithDirectory(PDirectory.Parent);
    Result.Add(GetCurrentPathWithDirectory(PDirectory));
  end;
end;

procedure TCDIndexMapping.SelectRoot;
begin
  CurrentDir := Root;
end;

procedure TCDIndexMapping.SelectPath(Path: string);
var
  IPos: Integer;
  Directory: string;
begin
  if Path = '' then
    Exit;

  if Path[1] = '\' then
  begin
    SelectRoot;
    Delete(Path, 1, 1);
  end;
  IPos := Pos('\', Path);
  Directory := System.Copy(Path, 1, IPos - 1);
  SelectDirectory(Directory);
  Delete(Path, 1, IPos);
  SelectPath(Path);
end;

procedure TCDIndexMapping.Copy(Files: TList);
begin
  ClipboardCut := False;
  Clipboard.Assign(Files);
end;

procedure TCDIndexMapping.Cut(Files: TList);
begin
  ClipboardCut := True;
  Clipboard.Assign(Files);
end;

procedure TCDIndexMapping.Paste;
var
  I: Integer;
  ItemToDelete, Item, OldParent: TCDIndexMappingDirectory;
begin
  for I := 0 to Clipboard.Count - 1 do
  begin
    ItemToDelete := TCDIndexMappingDirectory(Clipboard[I]);
    Item := CloneItem(ItemToDelete);
    OldParent := ItemToDelete.Parent;
    Item.Parent := CurrentDir;
    CurrentDir.Add(Item);
    if ClipboardCut then
      OldParent.Remove(ItemToDelete);
  end;
  Clipboard.Clear;
end;

function TCDIndexMapping.CloneItem(
  Item: TCDIndexMappingDirectory): TCDIndexMappingDirectory;
var
  I: Integer;
  AItem: TCDIndexMappingDirectory;
begin
  AItem := TCDIndexMappingDirectory.Create;
  AItem.Name := Item.Name;
  AItem.IsFile := Item.IsFile;
  AItem.Parent := Item.Parent;
  AItem.IsReal := Item.IsReal;
  AItem.DB_ID := Item.DB_ID;
  AItem.FileSize := Item.FileSize;
  AItem.RealFileName := Item.RealFileName;

  for I := 0 to Item.Count - 1 do
    AItem.Add(CloneItem(Item[I]));

  Result := AItem;
end;

procedure TCDIndexMapping.ClearClipBoard;
begin
  Clipboard.Clear;
end;

function TCDIndexMapping.DirectoryHasDBFiles(
  Directory: TCDIndexMappingDirectory): boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to Directory.Count - 1 do
  begin
    if Directory[I].IsFile then
    begin
      if Directory[I].DB_ID > 0 then
      begin
        Result := True;
        Exit;
      end;
    end else
    begin
      if DirectoryHasDBFiles(Directory[I]) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TCDIndexMapping.DeleteOriginalStructure(OnProgress: TCallBackProgressEvent): Boolean;
begin
  Result := DeleteOriginalStructureWithDirectory(Root, OnProgress);
end;

function TCDIndexMapping.DeleteOriginalStructureWithDirectory(PDirectory: TCDIndexMappingDirectory;
  OnProgress: TCallBackProgressEvent): Boolean;
var
  I: Integer;
  Info: TProgressCallBackInfo;
begin
  Result := True;
  for I := 0 to PDirectory.Count - 1 do
  begin
    if PDirectory[I].IsFile then
      if PDirectory[I].IsReal then
      begin
        if not SysUtils.DeleteFile(PDirectory[I].RealFileName) then
        begin
          Result := False;
        end else
        begin
          Info.MaxValue := -1;
          Info.Position := PDirectory[I].FileSize;
          Info.Information := '';
          Info.Terminate := False;
          if Assigned(OnProgress) then
            OnProgress(nil, Info);
          if Info.Terminate then
          begin
            Result := False;
            Exit;
          end;
        end;
      end;
  end;

  for I := 0 to PDirectory.Count - 1 do
  begin
    if not PDirectory[I].IsFile then
    begin
      if not DeleteOriginalStructureWithDirectory(PDirectory[I], OnProgress) then
        Result := False;
    end;
  end;

  SysUtils.RemoveDir(PDirectory.RealFileName);
end;

function TCDIndexMapping.GetRoot: TCDIndexMappingDirectory;
begin
  Result := Root;
end;

function TCDIndexMapping.PlaceMapFile(Directory: string): Boolean;
var
  Header: TCDIndexFileHeader;
  HeaderV1: TCDIndexFileHeaderV1;
  FS: TFileStream;
begin
  Result := True;
  FormatDir(Directory);
  Directory := Directory + CDLabel;

  if not SysUtils.DirectoryExists(Directory) then
    if not CreateDir(Directory) then
      Exit;

  FormatDir(Directory);
  try
    FS := TFileStream.Create(Directory + 'DBCDMap.map', FmOpenWrite or FmCreate);
  except
    Result := False;
    Exit;
  end;
  FillChar(Header, SizeOf(Header), #0);
  FillChar(HeaderV1, SizeOf(HeaderV1), #0);
  Header.ID := 'PHOTODB_CD_INDEX';
  Header.Version := 1;
  Header.DBVersion := ReleaseNumber;
  HeaderV1.CDLabel := CDLabel;
  HeaderV1.Date := Now;
  try
    FS.Write(Header, SizeOf(Header));
    FS.Write(HeaderV1, SizeOf(HeaderV1));
  except
    Result := False;
  end;
  FS.Free;
end;

class function TCDIndexMapping.ReadMapFile(FileName: string): TCDIndexInfo;
var
  Header: TCDIndexFileHeader;
  HeaderV1: TCDIndexFileHeaderV1;
  FS: TFileStream;
begin
  Result.Loaded := False;
  try
    FS := TFileStream.Create(FileName, FmOpenRead or FmShareDenyWrite);
  except
    Exit;
  end;

  try
    FS.read(Header, SizeOf(Header));
    FS.read(HeaderV1, SizeOf(HeaderV1));
  except
    FS.Free;
    Exit;
  end;
  if Header.ID = 'PHOTODB_CD_INDEX' then
  begin
    Result.CDLabel := HeaderV1.CDLabel;
    Result.Date := HeaderV1.Date;
    Result.DBVersion := Header.DBVersion;
    Result.Loaded := True;
  end;
  FS.Free;
end;

{ TCDDBMapping }

procedure TCDDBMapping.AddCDMapping(CDName, Path: string;
  Permanent: boolean);
var
  CD: TCDClass;
begin
  CD := GetCDByName(CDName);
  if CD <> nil then
  begin
    CD.Path := Path;
    Exit;
  end;
  CD := TCDClass.Create;
  CD.Name := CDName;
  CD.Tag := TCD_CLASS_TAG_NONE;
  CD.Path := Path;
  CDLoadedList.Add(CD);
  if GetCDByNameInternal(CDName) = nil then
  begin
    CD := TCDClass.Create;
    CD.Name := CDName;
    CD.Tag := TCD_CLASS_TAG_NONE;
    CD.Path := Path;
    CDFindedList.Add(CD);
  end;
end;

constructor TCDDBMapping.Create;
begin
  CDLoadedList := TList.Create;
  CDFindedList := TList.Create;
end;

destructor TCDDBMapping.Destroy;
begin
  FreeList(CDLoadedList);
  FreeList(CDFindedList);
  inherited;
end;

procedure TCDDBMapping.DoProcessPath(var FileName: string;
  CanUserNotify: boolean);
var
  P, MapResult: Integer;
  CD: TCDClass;
  CDName: string;
begin
  if Copy(FileName, 1, 2) = '::' then
  begin
    P := PosEx('::', FileName, 3);
    if P > 0 then
    begin
      CDName := Copy(FileName, 3, P - 3);
      CD := GetCDByName(CDName);
      if CD <> nil then
      begin
        Delete(FileName, 1, P + 2);
        FileName := CD.Path + FileName;
      end else
      begin
        CD := GetCDByNameInternal(CDName);
        if CD = nil then
        begin
          CD := TCDClass.Create;
          CD.name := CDName;
          CD.Tag := TCD_CLASS_TAG_NONE;
          CD.Path := '';
          CDFindedList.Add(CD);
        end;
        if CanUserNotify then
        begin
          CD := GetCDByNameInternal(CDName);
          if CD.Tag <> TCD_CLASS_TAG_NO_QUESTION then
            MapResult := CheckCD(CDName);
        end;
      end;
    end;
  end;
end;

function TCDDBMapping.GetCDByName(CDName: string): TCDClass;
var
  I: Integer;
  CD : TCDClass;
begin
  Result := nil;
  for I := 0 to CDLoadedList.Count - 1 do
  begin
    CD := TCDClass(CDLoadedList[I]);
    if AnsiLowerCase(CD.Name) = AnsiLowerCase(CDName) then
    begin
      Result := CD;
      Break;
    end;
  end;
end;

function TCDDBMapping.GetCDByNameInternal(CDName: string): TCDClass;
var
  I: Integer;
  CD : TCDClass;
begin
  Result := nil;
  for I := 0 to CDFindedList.Count - 1 do
  begin
    CD := TCDClass(CDFindedList[I]);
    if AnsiLowerCase(CD.Name) = AnsiLowerCase(CDName) then
    begin
      Result := CD;
      Break;
    end;
  end;
end;

function TCDDBMapping.GetFindedCDList: TList;
begin
  Result := CDFindedList;
end;

function TCDDBMapping.ProcessPath(FileName: string;
  CanUserNotify: boolean): string;
begin
  Result := FileName;
  DoProcessPath(Result, CanUserNotify);
end;

procedure TCDDBMapping.RemoveCDMapping(CDName: string);
var
  CD: TCDClass;
begin
  CD := GetCDByName(CDName);
  if CD <> nil then
  begin
    CDLoadedList.Remove(CD);
    F(CD);
  end;
end;

procedure TCDDBMapping.SetCDWithNOQuestion(CDName: string);
var
  CD: TCDClass;
begin
  CD := GetCDByNameInternal(CDName);
  if CD <> nil then
    CD.Tag := TCD_CLASS_TAG_NO_QUESTION;
end;

procedure TCDDBMapping.UnProcessPath(var Path: string);
var
  I: Integer;
  CDPath: string;
  CD: TCDClass;
begin
  for I := 0 to CDLoadedList.Count - 1 do
  begin
    CD := TCDClass(CDLoadedList[I]);
    if CD.Path <> '' then
    begin
      CDPath := CD.Path;
      UnFormatDir(CDPath);
      if AnsiLowerCase(Copy(Path, 1, Length(CDPath))) = AnsiLowerCase(CDPath) then
      begin
        Delete(Path, 1, Length(CDPath));
        Path := AnsiLowerCase('::' + CD.name + '::' + Path);
      end;
    end;
  end;
end;

{ TCDIndexMappingDirectory }

function TCDIndexMappingDirectory.Add(
  Item: TCDIndexMappingDirectory): Integer;
begin
  Result := FFiles.Add(Item);
end;

constructor TCDIndexMappingDirectory.Create;
begin
  FFiles := TList.Create;
  Parent := nil;
end;

procedure TCDIndexMappingDirectory.Delete(Index: Integer);
begin
  Items[Index].Free;
  FFiles.Delete(Index);
end;

destructor TCDIndexMappingDirectory.Destroy;
begin
  FreeList(FFiles);
  inherited;
end;

function TCDIndexMappingDirectory.GetCount: Integer;
begin
  Result := FFiles.Count;
end;

function TCDIndexMappingDirectory.GetFileByIndex(
  FileIndex: Integer): TCDIndexMappingDirectory;
begin
  Result := FFiles[FileIndex];
end;

procedure TCDIndexMappingDirectory.Remove(var Item: TCDIndexMappingDirectory);
begin
  FFiles.Remove(Item);
  Item.Free;
end;

initialization

finalization

  F(CDMapper);

end.
