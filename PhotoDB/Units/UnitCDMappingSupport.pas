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

  TCDIndexMappingDirectory = record
    Files: TList;
    name: string[255];
    IsFile: Boolean;
    Parent: Pointer;
    IsReal: Boolean;
    RealFileName: PChar;
    DB_ID: Integer;
    FileSize: Int64;
  end;

  PCDIndexMappingDirectory = ^TCDIndexMappingDirectory;

  TDBFilePath = record
    FileName: string;
    ID: Integer;
  end;

  TDBFilePathArray = array of TDBFilePath;

  TCDIndexMapping = class(TObject)
  private
    ClipboardCut: Boolean;
    Clipboard: TList;
    Root: PCDIndexMappingDirectory;
    CurrentDir: PCDIndexMappingDirectory;
    Mapping: TCDDataArray;
    FCDLabel: string;
    function GetCurrentPathWithDirectory(Directory: PCDIndexMappingDirectory; Init: Boolean = True): string;
    procedure GetDBRemappingArrayWithDirectory(Directory: PCDIndexMappingDirectory; var Info: TDBFilePathArray);
    procedure SetCDLabel(const Value: string);
    function CreateStructureToDirectoryWithDirectory(Directory: string; PDirectory: PCDIndexMappingDirectory;
      OnProgress: TCallBackProgressEvent): Boolean;
    function GetCurrentUpperDirectoriesWithDirectory(PDirectory: PCDIndexMappingDirectory): TStrings;
    function DeleteOriginalStructureWithDirectory(PDirectory: PCDIndexMappingDirectory;
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
    function GetItemByIndex(index: Integer): PCDIndexMappingDirectory;
    function GetDBRemappingArray: TDBFilePathArray;
    function GetCDSize: Int64;
    function CurrentLevel: PCDIndexMappingDirectory;
    function GetCDSizeWithDirectory(Directory: PCDIndexMappingDirectory): Int64;
    procedure SortLevel(Level: TList);
    function GetCurrentUpperDirectories: TStrings;
    procedure SelectRoot;
    procedure SelectPath(Path: string);
    procedure Copy(Files: TList);
    procedure Cut(Files: TList);
    procedure Paste;
    procedure ClearClipBoard;
    function CloneItem(Item: PCDIndexMappingDirectory): PCDIndexMappingDirectory;
    procedure FreeItem(Parent: PCDIndexMappingDirectory; Item: PCDIndexMappingDirectory);
    function DirectoryHasDBFiles(Directory: PCDIndexMappingDirectory): Boolean;
    function DeleteOriginalStructure(OnProgress: TCallBackProgressEvent): Boolean;
    function GetRoot: PCDIndexMappingDirectory;
    function PlaceMapFile(Directory: string): Boolean;
    class function ReadMapFile(FileName: string): TCDIndexInfo;
    property CDLabel: string read FCDLabel write SetCDLabel;
  end;

const
  TCD_CLASS_TAG_NONE = 0;
  TCD_CLASS_TAG_NO_QUESTION = 1;

  C_CD_MAP_FILE = 'DBCDMap.map';

type
  TCDClass = record
    name: string[255];
    Path: PChar;
    Tag: Integer;
  end;

  PCDClass = ^TCDClass;

  TCDDBMapping = class(TObject)
  private
    CDLoadedList: TList;
    CDFindedList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCDByName(CDName: string): PCDClass;
    function GetCDByNameInternal(CDName: string): PCDClass;
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
      if Directoryexists(Dir + SearchRec.name) then
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
  OpenDialog.Filter := Format('CD Index (%s)|%s', [C_CD_MAP_FILE, C_CD_MAP_FILE]);
  OpenDialog.FilterIndex := 1;
  OpenDialog.EnableChooseWithDirectory;
  if OpenDialog.Execute then
  begin
    Path := OpenDialog.FileName;
    if FileExists(Path) then
    begin
      if AnsiLowerCase(ExtractFileName(Path)) = AnsiLowerCase(C_CD_MAP_FILE) then
      begin
        LoadInfoByPath;
      end
      else
      begin
        MessageBoxDB(GetActiveFormHandle, Format(
          TA('Unable to find file %s by address "%s"'), [C_CD_MAP_FILE, Path]),
          TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
      end;
    end;
    UnFormatDir(Path);
    Dir := Path;
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
            Format(TA('In this directory file %s not found! Use this directory as root of drive "%s"?'), [C_CD_MAP_FILE, CDName]),
            TA('Error'), TD_BUTTON_YESNO,
            TD_ICON_ERROR) then
          begin
            FormatDir(Dir);
            CDMapper.AddCDMapping(CDName, Dir, False);
            Result := CDName;
          end;
      end;
    end;
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
      Result := FindData.nFileSizeHigh*2*MaxInt+FindData.nFileSizeLow;
  end;
end;

function DBFilePath(FileName: string; ID: Integer): TDBFilePath;
begin
  Result.FileName := FileName;
  Result.ID := ID;
end;

procedure SetPCharString(var P: PChar; S: string);
var
  L: Integer;
begin
  L := Length(S);
  if P <> nil then
    FreeMem(P);
  GetMem(P, Length(S) + 1);
  P[L] := #0;
  Lstrcpyn(P, PChar(S), L + 1);
end;

function TCDIndexMapping.AddImageFile(Path: TDBFilePath): Boolean;
var
  Image: PCDIndexMappingDirectory;
begin
  Result := False;
  if not FileExists(ExtractFileName(Path.FileName)) then
  begin
    GetMem(Image, SizeOf(TCDIndexMappingDirectory));
    Image.Files := TList.Create;
    Image.name := ExtractFileName(Path.FileName);
    Image.IsFile := True;
    Image.Parent := CurrentDir;
    Image.IsReal := True;
    Image.DB_ID := Path.ID;
    Image.RealFileName := nil;
    Image.FileSize := GetFileSizeByName(Path.FileName);
    SetPCharString(Image.RealFileName, Path.FileName);
    CurrentDir.Files.Add(Image);
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
      begin
        AddRealDirectory(Directory + SearchRec.name, CallBackProc);
      end;
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
  _File: PCDIndexMappingDirectory;
begin
  Result := False;

  if not FileExists(ExtractFileName(FileName)) then
  begin
    GetMem(_File, SizeOf(TCDIndexMappingDirectory));
    _File.Files := TList.Create;
    _File.name := ExtractFileName(FileName);
    _File.IsFile := True;
    _File.Parent := CurrentDir;
    _File.IsReal := True;
    _File.DB_ID := 0;
    _File.RealFileName := nil;
    _File.FileSize := GetFileSizeByName(FileName);
    SetPCharString(_File.RealFileName, FileName);
    CurrentDir.Files.Add(_File);
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
      if not Dolphin_DB.GetInfoByFileNameA(Files[I], False, Info) then
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
  GetMem(Root, SizeOf(TCDIndexMappingDirectory));
  Root.Files := TList.Create;
  Root.name := '\';
  Root.IsFile := False;
  Root.Parent := nil;
  Root.IsReal := False;
  Root.RealFileName := nil;
  Root.DB_ID := 0;
  Root.FileSize := 0;
  CurrentDir := Root;
  SetLength(Mapping.Data, 0);
  Mapping.CDName := '';
end;

function TCDIndexMapping.CreateDirectory(Directory: string): Boolean;
var
  Dir: PCDIndexMappingDirectory;
begin
  Directory := CheckName(Directory);
  if not DirectoryExists(Directory) then
  begin
    GetMem(Dir, SizeOf(TCDIndexMappingDirectory));
    Dir.Files := TList.Create;
    Dir.name := Directory;
    Dir.IsFile := False;
    Dir.Parent := CurrentDir;
    Dir.IsReal := False;
    Dir.RealFileName := nil;
    Dir.DB_ID := 0;
    Dir.FileSize := 0;
    CurrentDir.Files.Add(Dir);
    Result := True;
  end
  else
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
  Directory: string; PDirectory: PCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent): Boolean;
var
  I: Integer;
  DirectoryName, FileName: string;
  Info: TProgressCallBackInfo;
begin
  Result := True;
  for I := 0 to PDirectory.Files.Count - 1 do
    if PCDIndexMappingDirectory(PDirectory.Files[I]).IsFile then
    begin
      FileName := PCDIndexMappingDirectory(PDirectory.Files[I]).name;
      DirectoryName := Directory;
      FormatDir(DirectoryName);
      if AnsiLowerCase(PCDIndexMappingDirectory(PDirectory.Files[I]).RealFileName) <> AnsiLowerCase
        (DirectoryName + FileName) then
        if not Windows.CopyFile(PCDIndexMappingDirectory(PDirectory.Files[I]).RealFileName,
          PChar(DirectoryName + FileName), False) then
        begin
          Result := False;
          Exit;
        end
        else
        begin
          Info.MaxValue := -1;
          Info.Position := PCDIndexMappingDirectory(PDirectory.Files[I]).FileSize;
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

  for I := 0 to PDirectory.Files.Count - 1 do
    if not PCDIndexMappingDirectory(PDirectory.Files[I]).IsFile then
    begin
      DirectoryName := Directory;
      FormatDir(DirectoryName);
      DirectoryName := DirectoryName + PCDIndexMappingDirectory(PDirectory.Files[I]).name;

      if not SysUtils.DirectoryExists(DirectoryName) then
        if not CreateDir(DirectoryName) then
        begin
          Result := False;
          Exit;
        end;
      CreateStructureToDirectoryWithDirectory(DirectoryName, PDirectory.Files[I], OnProgress);
    end;

end;

function TCDIndexMapping.CurrentLevel: PCDIndexMappingDirectory;
begin
  SortLevel(CurrentDir.Files);
  Result := CurrentDir;
end;

function TCDIndexMapping.DeleteDirectory(Directory: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Files.Count - 1 do
    if not PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[I]).name) = AnsiLowerCase(Directory) then
      begin
        FreeMem(CurrentDir.Files[I]);
        CurrentDir.Files.Delete(I);
        Result := True;
        Break;
      end;
end;

function TCDIndexMapping.DeleteFile(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Files.Count - 1 do
    if PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[I]).name) = AnsiLowerCase(FileName) then
      begin
        FreeMem(CurrentDir.Files[I]);
        CurrentDir.Files.Delete(I);
        Result := True;
        Break;
      end;
end;

destructor TCDIndexMapping.Destroy;
begin
  FreeItem(nil, Root);
  Clipboard.Free;
  inherited Destroy;
end;

function TCDIndexMapping.DirectoryExists(Directory: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Files.Count - 1 do
    if not PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[I]).name) = AnsiLowerCase(Directory) then
      begin
        Result := True;
      end;
end;

function TCDIndexMapping.FileExists(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to CurrentDir.Files.Count - 1 do
    if PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[I]).name) = AnsiLowerCase(FileName) then
      begin
        Result := True;
      end;
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

function TCDIndexMapping.GetCurrentPathWithDirectory(Directory: PCDIndexMappingDirectory; Init: Boolean = True): string;
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
  Directory: PCDIndexMappingDirectory; var Info: TDBFilePathArray);
var
  I: Integer;
begin
  for I := 0 to Directory.Files.Count - 1 do
    if PCDIndexMappingDirectory(Directory.Files[I]).IsFile then
      if PCDIndexMappingDirectory(Directory.Files[I]).DB_ID > 0 then
      begin
        SetLength(Info, Length(Info) + 1);
        Info[Length(Info) - 1].ID := PCDIndexMappingDirectory(Directory.Files[I]).DB_ID;
        Info[Length(Info) - 1].FileName := AnsiLowerCase('::' + CDLabel + '::' + GetCurrentPathWithDirectory(Directory)
            + PCDIndexMappingDirectory(Directory.Files[I]).name);
      end;
  for I := 0 to Directory.Files.Count - 1 do
    if not PCDIndexMappingDirectory(Directory.Files[I]).IsFile then
    begin
      GetDBRemappingArrayWithDirectory(Directory.Files[I], Info);
    end;
end;

function TCDIndexMapping.GetCDSizeWithDirectory(
  Directory: PCDIndexMappingDirectory): int64;
var
  I: Integer;
begin
  Result := Directory.FileSize;
  for I := 0 to Directory.Files.Count - 1 do
    if PCDIndexMappingDirectory(Directory.Files[I]).IsFile then
      Result := Result + PCDIndexMappingDirectory(Directory.Files[I]).FileSize;

  for I := 0 to Directory.Files.Count - 1 do
    if not PCDIndexMappingDirectory(Directory.Files[I]).IsFile then
      Result := Result + GetCDSizeWithDirectory(Directory.Files[I]);
end;

function TCDIndexMapping.GetItemByIndex(index: Integer): PCDIndexMappingDirectory;
begin
  Result := CurrentDir.Files[index];
end;

function TCDIndexMapping.GetItemNameByIndex(index: Integer): string;
begin
  Result := PCDIndexMappingDirectory(CurrentDir.Files[index]).name;
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
  for I := 0 to CurrentDir.Files.Count - 1 do
    if not PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[I]).name) = AnsiLowerCase(Directory) then
      begin
        CurrentDir := CurrentDir.Files[I];
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
  for I := 0 to CurrentDir.Files.Count - 1 do
  begin
    if PCDIndexMappingDirectory(CurrentDir.Files[I]).IsFile then
      Text := '[File] '
    else
      Text := '[Directory] ';
    Text := Text + PCDIndexMappingDirectory(CurrentDir.Files[I]).name;
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
  LevelSize := Level.Count;
  for I := Level.Count - 1 downto 0 do
  begin
    if not PCDIndexMappingDirectory(Level[I]).IsFile then
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
        if SysUtils.CompareText(PCDIndexMappingDirectory(Level[I]).name, PCDIndexMappingDirectory(Level[I - 1]).name)
          < 0 then
        begin
          Level.Exchange(I, I - 1);
          Changed := True;
        end;
      end;

    if (List.Count = LevelSize) then
      for I := List.Count - 1 downto 1 do
      begin
        if SysUtils.CompareText(PCDIndexMappingDirectory(List[I]).name, PCDIndexMappingDirectory(List[I - 1]).name)
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
  // for i:=List.Count-1 downto 0 do
  for I := 0 to List.Count - 1 do
    Level.Insert(0, List[I]);
  if Changed then
    SortLevel(Level);
end;

function TCDIndexMapping.GetCurrentUpperDirectories: TStrings;
begin
  Result := GetCurrentUpperDirectoriesWithDirectory(CurrentDir);
end;

function TCDIndexMapping.GetCurrentUpperDirectoriesWithDirectory(
  PDirectory: PCDIndexMappingDirectory): TStrings;
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
  Item, OldParent: PCDIndexMappingDirectory;
begin
  for I := 0 to Clipboard.Count - 1 do
  begin
    Item := CloneItem(Clipboard[I]);
    OldParent := PCDIndexMappingDirectory(Clipboard[I]).Parent;
    Item.Parent := CurrentDir;
    CurrentDir.Files.Add(Item);
    if ClipboardCut then
      FreeItem(OldParent, Clipboard[I]);
  end;
  Clipboard.Clear;
end;

function TCDIndexMapping.CloneItem(
  Item: PCDIndexMappingDirectory): PCDIndexMappingDirectory;
var
  I: Integer;
  AItem: PCDIndexMappingDirectory;
begin
  GetMem(AItem, SizeOf(TCDIndexMappingDirectory));
  AItem.Files := TList.Create;
  AItem.name := Item.name;
  AItem.IsFile := Item.IsFile;
  AItem.Parent := Item.Parent;
  AItem.IsReal := Item.IsReal;
  AItem.DB_ID := Item.DB_ID;
  AItem.FileSize := Item.FileSize;
  AItem.RealFileName := nil;
  SetPCharString(AItem.RealFileName, string(Item.RealFileName));
  for I := 0 to Item.Files.Count - 1 do
  begin
    AItem.Files.Add(CloneItem(Item.Files[I]));
  end;
  Result := AItem;
end;

procedure TCDIndexMapping.FreeItem(Parent, Item: PCDIndexMappingDirectory);
var
  I: Integer;
begin
  if Parent <> nil then
    Parent.Files.Remove(Item);

  FreeMem(Item.RealFileName);
  for I := Item.Files.Count - 1 downto 0 do
    FreeItem(Item, Item.Files[I]);
  Item.Files.Free;
end;

procedure TCDIndexMapping.ClearClipBoard;
begin
  Clipboard.Clear;
end;

function TCDIndexMapping.DirectoryHasDBFiles(
  Directory: PCDIndexMappingDirectory): boolean;
var
  I: Integer;
begin
  Result := False;
  if Directory.Files = nil then
    Exit;
  for I := 0 to Directory.Files.Count - 1 do
  begin
    if PCDIndexMappingDirectory(Directory.Files[I]).IsFile then
    begin
      if PCDIndexMappingDirectory(Directory.Files[I]).DB_ID > 0 then
      begin
        Result := True;
        Exit;
      end;
    end else
    begin
      if DirectoryHasDBFiles(Directory.Files[I]) then
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

function TCDIndexMapping.DeleteOriginalStructureWithDirectory(PDirectory: PCDIndexMappingDirectory;
  OnProgress: TCallBackProgressEvent): Boolean;
var
  I: Integer;
  Info: TProgressCallBackInfo;
begin
  Result := True;
  for I := 0 to PDirectory.Files.Count - 1 do
  begin
    if PCDIndexMappingDirectory(PDirectory.Files[I]).IsFile then
      if PCDIndexMappingDirectory(PDirectory.Files[I]).IsReal then
      begin
        if not SysUtils.DeleteFile(PCDIndexMappingDirectory(PDirectory.Files[I]).RealFileName) then
        begin
          Result := False;
        end else
        begin
          Info.MaxValue := -1;
          Info.Position := PCDIndexMappingDirectory(PDirectory.Files[I]).FileSize;
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

  for I := 0 to PDirectory.Files.Count - 1 do
  begin
    if not PCDIndexMappingDirectory(PDirectory.Files[I]).IsFile then
    begin
      if not DeleteOriginalStructureWithDirectory(PDirectory.Files[I], OnProgress) then
      begin
        Result := False;
      end;
    end;
  end;

  SysUtils.RemoveDir(PDirectory.RealFileName);
end;

function TCDIndexMapping.GetRoot: PCDIndexMappingDirectory;
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
    FS.write(Header, SizeOf(Header));
    FS.write(HeaderV1, SizeOf(HeaderV1));
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
  CD: PCDClass;
begin
  CD := GetCDByName(CDName);
  if CD <> nil then
  begin
    FreeMem(CD.Path);
    CD.Path := nil;
    SetPCharString(CD.Path, Path);
    Exit;
  end;
  GetMem(CD, SizeOf(TCDClass));
  CD.name := CDName;
  CD.Tag := TCD_CLASS_TAG_NONE;
  CD.Path := nil;
  SetPCharString(CD.Path, Path);
  CDLoadedList.Add(CD);
  if GetCDByNameInternal(CDName) = nil then
  begin
    CD := nil;
    GetMem(CD, SizeOf(TCDClass));
    CD.name := CDName;
    CD.Tag := TCD_CLASS_TAG_NONE;
    CD.Path := nil;
    SetPCharString(CD.Path, Path);
    CDFindedList.Add(CD);
  end;
end;

constructor TCDDBMapping.Create;
begin
  CDLoadedList := TList.Create;
  CDFindedList := TList.Create;
end;

destructor TCDDBMapping.Destroy;
var
  I: Integer;
begin
  for I := 0 to CDLoadedList.Count - 1 do
  begin
    FreeMem(PCDClass(CDLoadedList[I]).Path);
  end;
  CDLoadedList.Free;
  for I := 0 to CDFindedList.Count - 1 do
  begin
    FreeMem(PCDClass(CDFindedList[I]).Path);
  end;
  CDFindedList.Free;
  inherited;
end;

procedure TCDDBMapping.DoProcessPath(var FileName: string;
  CanUserNotify: boolean);
var
  I, P, MapResult: Integer;
  CD: PCDClass;
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
      end
      else
      begin
        CD := GetCDByNameInternal(CDName);
        if CD = nil then
        begin
          GetMem(CD, SizeOf(TCDClass));
          CD.name := CDName;
          CD.Tag := TCD_CLASS_TAG_NONE;
          CD.Path := nil;
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

function TCDDBMapping.GetCDByName(CDName: string): PCDClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to CDLoadedList.Count - 1 do
  begin
    if AnsiLowerCase(PCDClass(CDLoadedList[I]).name) = AnsiLowerCase(CDName) then
    begin
      Result := PCDClass(CDLoadedList[I]);
      Break;
    end;
  end;
end;

function TCDDBMapping.GetCDByNameInternal(CDName: string): PCDClass;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to CDFindedList.Count - 1 do
  begin
    if AnsiLowerCase(PCDClass(CDFindedList[I]).name) = AnsiLowerCase(CDName) then
    begin
      Result := PCDClass(CDFindedList[I]);
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
  CD: PCDClass;
begin
  CD := GetCDByName(CDName);
  if CD <> nil then
  begin
    FreeMem(CD.Path);
    CD.Path := nil;
  end;
end;

procedure TCDDBMapping.SetCDWithNOQuestion(CDName: string);
var
  CD: PCDClass;
begin
  CD := GetCDByNameInternal(CDName);
  if CD <> nil then
    CD.Tag := TCD_CLASS_TAG_NO_QUESTION;
end;

procedure TCDDBMapping.UnProcessPath(var Path: string);
var
  I: Integer;
  CDPath: string;
begin
  for I := 0 to CDLoadedList.Count - 1 do
  begin
    if PCDClass(CDLoadedList[I]).Path <> nil then
    begin
      CDPath := PCDClass(CDLoadedList[I]).Path;
      UnFormatDir(CDPath);
      if AnsiLowerCase(Copy(Path, 1, Length(CDPath))) = AnsiLowerCase(CDPath) then
      begin
        Delete(Path, 1, Length(CDPath));
        Path := AnsiLowerCase('::' + PCDClass(CDLoadedList[I]).name + '::' + Path);
      end;
    end;
  end;
end;

initialization

finalization

  F(CDMapper);

end.
