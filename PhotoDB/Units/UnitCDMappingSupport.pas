unit UnitCDMappingSupport;

interface

uses
  Windows,
  Classes,
  SysUtils,
  StrUtils,

  Dmitry.Utils.Files,

  UnitDBFileDialogs,

  uShellIntegration,
  uMemory,
  uTranslate,
  uConstants,
  uDBBaseTypes,
  uDBUtils,
  uDBContext,
  uDBEntities,
  uDBManager,
  uCDMappingTypes;

type
  TCDIndexMapping = class(TObject)
  private
    FContext: IDBContext;
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
    constructor Create(Context: IDBContext);
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

function AddCDLocation(Handle : THandle; CDName: string): string;

implementation

uses UnitFormCDMapInfo;

{ TCDIndexMapping }

//MAPPING:
//label "PHOTOS"
//c:\dir\path\image.jpeg
//\folder\new_image.jpeg
//db ::PHOTOS::\folder\new_image.jpeg

//::drive_label::/path_on_drive

function GetValidCDIndexInFolder(Dir: string): string;
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  Result := '';
  Dir := IncludeTrailingBackslash(Dir);

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

function AddCDLocation(Handle : THandle; CDName: string): string;
var
  OpenDialog: DBOpenDialog;
  Path, Dir: string;
  Info: TCDIndexInfo;

  procedure LoadInfoByPath;
  begin
    Info := TCDIndexMapping.ReadMapFile(Path);
    CDMapper.AddCDMapping(string(Info.CDLabel), ExtractFilePath(Path), False);
    Result := string(Info.CDLabel);
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
          MessageBoxDB(Handle, Format(
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
            if ID_YES = MessageBoxDB(Handle,
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
  DBInfo: TMediaItemCollection;
  I, N: Integer;
begin
  CreateDirectory(ExtractFileName(Directory));
  SelectDirectory(ExtractFileName(Directory));

  DBInfo := TMediaItemCollection.Create;
  try
    Directory := IncludeTrailingBackslash(Directory);
    Found := FindFirst(Directory + '*', FaDirectory, SearchRec);
    try
      Info.MaxValue := 0;
      Info.Position := 0;
      Info.Information := '';
      Info.Terminate := False;
      N := 0;
      GetFileListByMask(FContext, Directory, '*.*', DBInfo, N, True);
      for I := 0 to DBInfo.Count - 1 do
      begin
        if DBInfo[I].ID = 0 then
          AddRealFile(DBInfo[I].FileName)
        else
          AddImageFile(DBFilePath(DBInfo[I].FileName, DBInfo[I].ID));
        Info.MaxValue := Info.MaxValue + GetFileSizeByName(DBInfo[I].FileName);

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
    finally
      SysUtils.FindClose(SearchRec);
    end;
  finally
    F(DBInfo);
  end;
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
  Info: TMediaItem;
  MediaRepository: IMediaRepository;
begin
  MediaRepository := FContext.Media;

  Info := TMediaItem.Create;
  try
    for I := 0 to Files.Count - 1 do
    begin
      if SysUtils.DirectoryExists(Files[I]) then
        AddRealDirectory(Files[I], nil);
      if FileExistsEx(Files[I]) then
      begin
        Info.FileName := Files[I];

        if not MediaRepository.UpdateMediaFromDB(Info, False) then
          AddRealFile(Files[I])
        else
          AddImageFile(DBFilePath(Info.FileName, Info.ID));
      end;
    end;
  finally
    F(Info);
  end;
end;

function TCDIndexMapping.CheckName(FileName: string): string;
begin
  Result := Trim(FileName);
end;

constructor TCDIndexMapping.Create(Context: IDBContext);
begin
  FContext := Context;
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

  Directory := IncludeTrailingBackslash(Directory) + CDLabel;

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
      DirectoryName := IncludeTrailingBackslash(Directory);
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
      DirectoryName := IncludeTrailingBackslash(Directory);
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
  SortLevel(CurrentDir.Files);
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
  Directory := IncludeTrailingBackslash(Directory) + CDLabel;

  if not SysUtils.DirectoryExists(Directory) then
    if not CreateDir(Directory) then
      Exit;

  try
    FS := TFileStream.Create(IncludeTrailingBackslash(Directory) + 'DBCDMap.map', FmOpenWrite or FmCreate);
  except
    Result := False;
    Exit;
  end;
  try
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
  finally
    F(FS);
  end;
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
    try
      FS.Read(Header, SizeOf(Header));
      FS.Read(HeaderV1, SizeOf(HeaderV1));
    except
      Exit;
    end;
    if Header.ID = 'PHOTODB_CD_INDEX' then
    begin
      Result.CDLabel := HeaderV1.CDLabel;
      Result.Date := HeaderV1.Date;
      Result.DBVersion := Header.DBVersion;
      Result.Loaded := True;
    end;
  finally
    F(FS);
  end;
end;

end.
