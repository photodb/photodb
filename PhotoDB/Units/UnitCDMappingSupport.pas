unit UnitCDMappingSupport;

interface

 uses Windows, Classes, SysUtils, StrUtils, UnitDBFileDialogs,
 Dolphin_DB, UnitDBDeclare, Language, uVistaFuncs, uFileUtils;

type
 //File strusts//////////////////////////////////////
 TCDIndexFileHeader = record
  ID : string[20];
  Version : byte;
  DBVersion : integer;
 end;

 TCDIndexFileHeaderV1 = record
  CDLabel : string[255];
  Date : TDateTime;
 end;

 TCDIndexInfo = record
  CDLabel : string[255];
  Date : TDateTime;
  DBVersion : integer;
  Loaded : boolean;
 end;
{
 TCDIndexFileRecordV1 = record
  Name : string[255];
  CDRelativePathLength : integer;
 end;
 //then CDPathData - string! Length of data block = (CDRelativePathLength+1)
 }

 //DB Structs/////////////////////////////////////////
 TCDDataArrayItem = record
  Name : string[255];
  CDRelativePath : string;
 end;

 TCDDataArray = record
  CDName : string;
  Data : array of TCDDataArrayItem;
 end;

 TCDIndexMappingDirectory = record
  Files : TList;
  Name : string[255];
  IsFile : boolean;
  Parent : Pointer;
  IsReal : boolean;
  RealFileName : PChar;
  DB_ID : integer;
  FileSize : int64;
 end;
 PCDIndexMappingDirectory = ^TCDIndexMappingDirectory;

 TDBFilePath = record
  FileName : string;
  ID : integer;
 end;
 TDBFilePathArray = array of TDBFilePath;

 TCDIndexMapping = class(TObject)
  private
    ClipboardCut : boolean;
    Clipboard : TList;
    Root : PCDIndexMappingDirectory;
    CurrentDir : PCDIndexMappingDirectory;
    Mapping : TCDDataArray;
    fCDLabel: String;
    function GetCurrentPathWithDirectory(Directory : PCDIndexMappingDirectory; init : Boolean = true) : string;
    procedure GetDBRemappingArrayWithDirectory(Directory : PCDIndexMappingDirectory; var Info : TDBFilePathArray);
    procedure SetCDLabel(const Value: String);
    function CreateStructureToDirectoryWithDirectory(Directory : string; PDirectory : PCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent) : Boolean;
    function GetCurrentUpperDirectoriesWithDirectory(PDirectory : PCDIndexMappingDirectory) : TStrings;
    function DeleteOriginalStructureWithDirectory(PDirectory : PCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent) : Boolean;
  public
   constructor Create;
   destructor Destroy; override;
   function CreateDirectory(Directory : string): Boolean;
   function GoUp : Boolean;
   function SelectDirectory(Directory : string) : Boolean;
   function DirectoryExists(Directory : string) : Boolean;
   function FileExists(FileName : string) : Boolean;
   procedure AddRealItemsToCurrentDirectory(Files : TStrings);
   function AddRealDirectory(Directory : string; CallBackProc : TCallBackProgressEvent) : Boolean;
   function AddRealFile(FileName : string) : Boolean;
   function AddImageFile(Path : TDBFilePath) : Boolean;
   function TextReadLevel : TStrings;
   function CheckName(FileName : string) : string;
   function GetItemNameByIndex(Index : integer) : string;
   function GetCDIndex : TCDDataArray;
   function DeleteDirectory(Directory : string) : Boolean;
   function DeleteFile(FileName : string) : Boolean;
   function GetCurrentPath : string;
   function CreateStructureToDirectory(Directory : string; OnProgress : TCallBackProgressEvent) : Boolean;
   function GetItemByIndex(Index : integer) : PCDIndexMappingDirectory;
   function GetDBRemappingArray : TDBFilePathArray;
   function GetCDSize : Int64;
   function CurrentLevel : PCDIndexMappingDirectory;
   function GetCDSizeWithDirectory(Directory : PCDIndexMappingDirectory) : int64;
   procedure SortLevel(Level : TList);
   function GetCurrentUpperDirectories : TStrings;
   procedure SelectRoot;
   procedure SelectPath(Path : string);
   procedure Copy(Files : TList);
   procedure Cut(Files : TList);
   procedure Paste;
   procedure ClearClipBoard;
   function CloneItem(Item : PCDIndexMappingDirectory): PCDIndexMappingDirectory;
   procedure FreeItem(Parent : PCDIndexMappingDirectory; Item : PCDIndexMappingDirectory);
   function DirectoryHasDBFiles(Directory : PCDIndexMappingDirectory) : boolean;
   function DeleteOriginalStructure(OnProgress : TCallBackProgressEvent) : boolean;
   function GetRoot : PCDIndexMappingDirectory;
   function PlaceMapFile(Directory : string) : Boolean;
   class function ReadMapFile(FileName : string) : TCDIndexInfo;
  published
   property CDLabel : String read fCDLabel Write SetCDLabel;
 end;

const
 TCD_CLASS_TAG_NONE        = 0;
 TCD_CLASS_TAG_NO_QUESTION = 1;

type
 TCDClass = record
  Name : string[255];
  Path : PChar;
  Tag : integer;
 end;
 PCDClass = ^TCDClass;

 TCDDBMapping = class(TObject)
  private
   CDLoadedList : TList;
   CDFindedList : TList;
  public
   constructor Create;
   destructor Destroy; override;
   function GetCDByName(CDName : string) : PCDClass;
   function GetCDByNameInternal(CDName : string) : PCDClass;
   procedure DoProcessPath(var FileName : string; CanUserNotify : boolean = false);
   function ProcessPath(FileName : string; CanUserNotify : boolean = false) : string;
   procedure AddCDMapping(CDName : string; Path : string; Permanent : boolean);
   procedure RemoveCDMapping(CDName : string);
   function GetFindedCDList : TList;
   procedure SetCDWithNOQuestion(CDName : string);
   procedure UnProcessPath(var Path : string);
 end;

 var
   CDMapper : TCDDBMapping = nil;

 function ProcessPath(FileName : string; CanUserNotify : boolean = false) : string;
 Procedure DoProcessPath(var FileName : string; CanUserNotify : boolean = false);
 function AddCDLocation(CDName : string = '') : string;
 Procedure UnProcessPath(var FileName : string);
 function StaticPath(FileName : string) : boolean;

implementation

 uses UnitFormCDMapInfo;

 function StaticPath(FileName : string) : boolean;
 begin
  Result:=true;
  if Copy(FileName,1,2)='::' then
  if PosEx('::',FileName,3)>0 then Result:=false;
 end;

 Procedure DoProcessPath(var FileName : string; CanUserNotify : boolean = false);
 begin
  if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
  CDMapper.DoProcessPath(FileName,CanUserNotify);
 end;

 Procedure UnProcessPath(var FileName : string);
 begin
  if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
  CDMapper.UnProcessPath(FileName);
 end;

 function ProcessPath(FileName : string; CanUserNotify : boolean = false) : string;
 begin
  if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
  Result:=CDMapper.ProcessPath(FileName,CanUserNotify);
 end;

 function GetValidCDIndexInFolder(Dir : String) : string;
 var
  Found  : integer;
  SearchRec : TSearchRec;
 begin
  Result:='';
  FormatDir(Dir);

  if FileExists(Dir+'DBCDMap.map') then
  begin
   if TCDIndexMapping.ReadMapFile(Dir+'DBCDMap.map').Loaded then
   begin
    Result:=Dir+'DBCDMap.map';
    exit;
   end;
  end;

  Found := FindFirst(Dir+'*', faDirectory, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
    if Directoryexists(Dir+SearchRec.Name) then
    begin
     Result:=GetValidCDIndexInFolder(Dir+SearchRec.Name);
     if Result<>'' then break;
    end;
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
 end;


 function AddCDLocation(CDName : string = '') : string;
 var
  OpenDialog : DBOpenDialog;
  Path, Dir : string;
  info : TCDIndexInfo;

  procedure loadInfoByPath;
  begin
   info:=TCDIndexMapping.ReadMapFile(Path);
   if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
   CDMapper.AddCDMapping(info.CDLabel,ExtractFilePath(Path),false);
   Result:=info.CDLabel;
  end;

 begin
  Result:='';
  OpenDialog:=DBOpenDialog.Create;
  OpenDialog.Filter:='CD Index (DBCDMap.map)|DBCDMap.map';
  OpenDialog.FilterIndex:=1;
  OpenDialog.EnableChooseWithDirectory;
  if OpenDialog.Execute then
  begin
   Path:=OpenDialog.FileName;
   if FileExists(Path) then
   begin
    if AnsiLowerCase(ExtractFileName(Path))=AnsiLowerCase('DBCDMap.map') then
    begin
     LoadInfoByPath;
    end else
    begin
     MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_F,[Path]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
    end;
   end;
   UnFormatDir(Path);
   Dir:=Path;
   if DirectoryExists(Dir) then
   begin
    Path:=GetValidCDIndexInFolder(Dir);
    if Path<>'' then
    begin
     loadInfoByPath;
    end else
    begin
     if CDName<>'' then
     if ID_YES=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_IN_FOLDER_USE_IT_F,[CDName]),TEXT_MES_ERROR,TD_BUTTON_YESNO,TD_ICON_WARNING) then
     begin
      FormatDir(Dir);
      CDMapper.AddCDMapping(CDName,Dir,false);
      Result:=CDName;
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

function DBFilePath(FileName : string; ID : integer) : TDBFilePath;
begin
 Result.FileName:=FileName;
 Result.ID:=ID;
end;

procedure SetPCharString(var p : PChar; S : String);
var
  L : integer;
begin
 l:=Length(s);
 if p<>nil then FreeMem(p);
 GetMem(p,Length(s)+1);
 p[L]:=#0;
 lstrcpyn(p,PChar(S),L+1);
end;

function TCDIndexMapping.AddImageFile(Path: TDBFilePath): Boolean;
var
  Image : PCDIndexMappingDirectory;
begin
 Result:=false;
 if not FileExists(ExtractFileName(Path.FileName)) then
 begin
  GetMem(Image,SizeOf(TCDIndexMappingDirectory));
  Image.Files:=TList.Create;
  Image.Name:=ExtractFileName(Path.FileName);
  Image.IsFile:=true;
  Image.Parent:=CurrentDir;
  Image.IsReal:=true;
  Image.DB_ID:=Path.ID;
  Image.RealFileName:=nil;
  Image.FileSize:=GetFileSizeByName(Path.FileName);
  SetPCharString(Image.RealFileName,Path.FileName);
  CurrentDir.Files.Add(Image);
  Result:=true;
 end;
end;

//todo: recursive add files!
function TCDIndexMapping.AddRealDirectory(Directory: string; CallBackProc : TCallBackProgressEvent): Boolean;
Var
 Found  : integer;
 SearchRec : TSearchRec;
 Info : TProgressCallBackInfo;
 DBInfo : TRecordsInfo;
 i, n : integer;
begin
 CreateDirectory(ExtractFileName(Directory));
 SelectDirectory(ExtractFileName(Directory));
 FormatDir(Directory);
 Found := FindFirst(Directory+'*', faDirectory, SearchRec);
 Info.MaxValue:=0;
 Info.Position:=0;
 Info.Information:='';
 Info.Terminate:=false;
 n:=0;
 Dolphin_DB.GetFileListByMask(Directory,'*.*',DBInfo,n,true);
 for i:=0 to Length(DBInfo.ItemFileNames)-1 do
 begin
  if DBInfo.ItemIds[i]=0 then
  AddRealFile(DBInfo.ItemFileNames[i]) else
  AddImageFile(DBFilePath(DBInfo.ItemFileNames[i],DBInfo.ItemIds[i]));
  Info.MaxValue:=Info.MaxValue+GetFileSizeByName(DBInfo.ItemFileNames[i]);

  if Assigned(CallBackProc) then CallBackProc(Self, Info);
  if Info.Terminate then break;
 end;
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If SysUtils.DirectoryExists(Directory+SearchRec.Name) then
   begin
    AddRealDirectory(Directory+SearchRec.Name, CallBackProc);
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
  if Assigned(CallBackProc) then CallBackProc(Self, Info);
  if Info.Terminate then break;
 end;
 SysUtils.FindClose(SearchRec);
 GoUp;
 Result:=true;
end;

function TCDIndexMapping.AddRealFile(FileName: string): Boolean;
var
  _File : PCDIndexMappingDirectory;
begin
 Result:=false;

 if not FileExists(ExtractFileName(FileName)) then
 begin
  GetMem(_File,SizeOf(TCDIndexMappingDirectory));
  _File.Files:=TList.Create;
  _File.Name:=ExtractFileName(FileName);
  _File.IsFile:=true;
  _File.Parent:=CurrentDir;
  _File.IsReal:=true;
  _File.DB_ID:=0;
  _File.RealFileName:=nil;
  _File.FileSize:=GetFileSizeByName(FileName);
  SetPCharString(_File.RealFileName,FileName);
  CurrentDir.Files.Add(_File);
  Result:=true;
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
 Result:=Trim(FileName);
end;

constructor TCDIndexMapping.Create;
begin
 ClipboardCut:=false;
 Clipboard:=TList.Create;
 GetMem(Root,SizeOf(TCDIndexMappingDirectory));
 Root.Files:=TList.Create;
 Root.Name:='\';
 Root.IsFile:=false;
 Root.Parent:=nil;
 Root.IsReal:=false;
 Root.RealFileName:=nil;
 Root.DB_ID:=0;
 Root.FileSize:=0;
 CurrentDir:=Root;
 SetLength(Mapping.Data,0);
 Mapping.CDName:='';
end;

function TCDIndexMapping.CreateDirectory(Directory: string): Boolean;
var
  Dir : PCDIndexMappingDirectory;
begin
 Directory:=CheckName(Directory);
 if not DirectoryExists(Directory) then
 begin
  GetMem(Dir,SizeOf(TCDIndexMappingDirectory));
  Dir.Files:=TList.Create;
  Dir.Name:=Directory;
  Dir.IsFile:=false;
  Dir.Parent:=CurrentDir;
  Dir.IsReal:=false;
  Dir.RealFileName:=nil;
  Dir.DB_ID:=0;
  Dir.FileSize:=0;
  CurrentDir.Files.Add(Dir);
  Result:=true;
 end else
 begin
  Result:=false;
 end;
end;

function TCDIndexMapping.CreateStructureToDirectory(
  Directory: string; OnProgress : TCallBackProgressEvent): Boolean;
begin
 Result:=false;
 if not SysUtils.DirectoryExists(Directory) then
 if not CreateDirA(Directory) then exit;
 FormatDir(Directory);
 Directory:=Directory+CDLabel;

 if not SysUtils.DirectoryExists(Directory) then
 if not CreateDir(Directory) then exit;

 if not SysUtils.DirectoryExists(Directory) then
 begin
  exit;
 end;
 Result:=CreateStructureToDirectoryWithDirectory(Directory,Root,OnProgress);
end;

function TCDIndexMapping.CreateStructureToDirectoryWithDirectory(
  Directory: string; PDirectory: PCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent): Boolean;
var
  i : integer;
  DirectoryName, FileName : string;
  info : TProgressCallBackInfo;
begin
 Result:=true;
 for i:=0 to PDirectory.Files.Count-1 do
 if PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
 begin
  FileName:=PCDIndexMappingDirectory(PDirectory.Files[i]).Name;
  DirectoryName:=Directory;
  FormatDir(DirectoryName);
  if AnsiLowerCase(PCDIndexMappingDirectory(PDirectory.Files[i]).RealFileName)<>AnsiLowerCase(DirectoryName+FileName) then
  if not Windows.CopyFile(PCDIndexMappingDirectory(PDirectory.Files[i]).RealFileName,PChar(DirectoryName+FileName),false) then
  begin
   Result:=false;
   exit;
  end else
  begin
   info.MaxValue:=-1;
   info.Position:=PCDIndexMappingDirectory(PDirectory.Files[i]).FileSize;
   info.Information:='';
   info.Terminate:=false;
   if Assigned(OnProgress) then OnProgress(nil,info);
   if info.Terminate then
   begin
    Result:=false;
    exit;
   end;
  end;
 end;

 for i:=0 to PDirectory.Files.Count-1 do
 if not PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
 begin
  DirectoryName:=Directory;
  FormatDir(DirectoryName);
  DirectoryName:=DirectoryName+PCDIndexMappingDirectory(PDirectory.Files[i]).Name;

  if not SysUtils.DirectoryExists(DirectoryName) then
  if not CreateDir(DirectoryName) then
  begin
   Result:=false;
   exit;
  end;
  CreateStructureToDirectoryWithDirectory(DirectoryName,PDirectory.Files[i],OnProgress);
 end;

end;

function TCDIndexMapping.CurrentLevel: PCDIndexMappingDirectory;
var
  i : integer;
begin
 SortLevel(CurrentDir.Files);
 Result:=CurrentDir;
end;

function TCDIndexMapping.DeleteDirectory(Directory: string): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to CurrentDir.Files.Count-1 do
 if not PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then
 if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[i]).Name)=AnsiLowerCase(Directory) then
 begin
  FreeMem(CurrentDir.Files[i]);
  CurrentDir.Files.Delete(i);
  Result:=true;
  break;
 end;
end;

function TCDIndexMapping.DeleteFile(FileName: string): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to CurrentDir.Files.Count-1 do
 if PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then
 if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[i]).Name)=AnsiLowerCase(FileName) then
 begin
  FreeMem(CurrentDir.Files[i]);
  CurrentDir.Files.Delete(i);
  Result:=true;
  break;
 end;
end;

destructor TCDIndexMapping.Destroy;
begin
 FreeItem(nil,Root);
 Clipboard.Free;
 inherited Destroy;
end;

function TCDIndexMapping.DirectoryExists(Directory: string): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to CurrentDir.Files.Count-1 do
 if not PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then
 if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[i]).Name)=AnsiLowerCase(Directory) then
 begin
  Result:=true;
 end;
end;

function TCDIndexMapping.FileExists(FileName: string): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to CurrentDir.Files.Count-1 do
 if PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then
 if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[i]).Name)=AnsiLowerCase(FileName) then
 begin
  Result:=true;
 end;
end;

function TCDIndexMapping.GetCDIndex: TCDDataArray;
begin
 Result:=Mapping;
end;

function TCDIndexMapping.GetCDSize: Int64;
begin
 Result:=GetCDSizeWithDirectory(Root);
end;

function TCDIndexMapping.GetCurrentPath: string;
begin
 Result:=GetCurrentPathWithDirectory(CurrentDir);
end;

function TCDIndexMapping.GetCurrentPathWithDirectory(
  Directory: PCDIndexMappingDirectory; init : Boolean = true): string;
begin
 if init then Result:='';
 if Directory.Parent=nil then
 Result:='\'+Result else Result:=GetCurrentPathWithDirectory(Directory.Parent,false)+Directory.Name+'\'+Result;
end;

function TCDIndexMapping.GetDBRemappingArray: TDBFilePathArray;
begin
 GetDBRemappingArrayWithDirectory(Root,Result);
end;

procedure TCDIndexMapping.GetDBRemappingArrayWithDirectory(
  Directory: PCDIndexMappingDirectory; var Info: TDBFilePathArray);
var
  i : integer;
begin
 for i:=0 to Directory.Files.Count-1 do
 if PCDIndexMappingDirectory(Directory.Files[i]).IsFile then
 if PCDIndexMappingDirectory(Directory.Files[i]).DB_ID>0 then
 begin
  SetLength(Info,Length(Info)+1);
  Info[Length(Info)-1].ID:=PCDIndexMappingDirectory(Directory.Files[i]).DB_ID;
  Info[Length(Info)-1].FileName:=AnsiLowerCase('::'+CDLabel+'::'+GetCurrentPathWithDirectory(Directory)+PCDIndexMappingDirectory(Directory.Files[i]).Name);
 end;
 for i:=0 to Directory.Files.Count-1 do
 if not PCDIndexMappingDirectory(Directory.Files[i]).IsFile then
 begin
  GetDBRemappingArrayWithDirectory(Directory.Files[i],Info);
 end;
end;

function TCDIndexMapping.GetCDSizeWithDirectory(
  Directory: PCDIndexMappingDirectory): int64;
var
  i : integer;
begin
 Result:=Directory.FileSize;
 for i:=0 to Directory.Files.Count-1 do
 if PCDIndexMappingDirectory(Directory.Files[i]).IsFile then
 begin
  Result:=Result+PCDIndexMappingDirectory(Directory.Files[i]).FileSize;
 end;
 for i:=0 to Directory.Files.Count-1 do
 if not PCDIndexMappingDirectory(Directory.Files[i]).IsFile then
 begin
  Result:=Result+GetCDSizeWithDirectory(Directory.Files[i]);
 end;
end;

function TCDIndexMapping.GetItemByIndex(
  Index: integer): PCDIndexMappingDirectory;
begin
 Result:=CurrentDir.Files[Index];
end;

function TCDIndexMapping.GetItemNameByIndex(Index: integer): string;
begin
 Result:=PCDIndexMappingDirectory(CurrentDir.Files[Index]).Name;
end;

function TCDIndexMapping.GoUp: Boolean;
begin
 if CurrentDir.Parent<>nil then
 begin
  CurrentDir:=CurrentDir.Parent;
  Result:=true;
 end else
 begin
  Result:=false;
 end;
end;

function TCDIndexMapping.SelectDirectory(Directory: string): Boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to CurrentDir.Files.Count-1 do
 if not PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then
 if AnsiLowerCase(PCDIndexMappingDirectory(CurrentDir.Files[i]).Name)=AnsiLowerCase(Directory) then
 begin
  CurrentDir:=CurrentDir.Files[i];
  break;
 end;
end;

procedure TCDIndexMapping.SetCDLabel(const Value: String);
begin
  fCDLabel := Value;
end;

function TCDIndexMapping.TextReadLevel: TStrings;
var
  i : integer;
  Text : string;
begin
 Result:=TStringList.Create;
 for i:=0 to CurrentDir.Files.Count-1 do
 begin
  if PCDIndexMappingDirectory(CurrentDir.Files[i]).IsFile then Text:='[File] ' else Text:='[Directory] ';
  Text:=Text+PCDIndexMappingDirectory(CurrentDir.Files[i]).Name;
  Result.Add(Text);
 end;
end;

procedure TCDIndexMapping.SortLevel(Level: TList);
var
  i : integer;
  Changed : boolean;
  DirOnUp, FNOK : boolean;
  CmpResult, DirResult : integer;
  List : TList;
  LevelSize : integer;
begin
 //Folders by text compare -> files by text compare
 Changed:=false;
 List:=TList.Create;
 LevelSize:=Level.Count;
 for i:=Level.Count-1 downto 0 do
 begin
  if not PCDIndexMappingDirectory(Level[i]).IsFile then
  begin
   List.Add(Level[i]);
   Level.Delete(i);
  end;
 end;
 if (List.Count=0) or (List.Count=LevelSize) then
 begin
  if (List.Count=0) then
  for i:=Level.Count-1 downto 1 do
  begin
   if SysUtils.CompareText(PCDIndexMappingDirectory(Level[i]).Name,PCDIndexMappingDirectory(Level[i-1]).Name)<0 then
   begin
    Level.Exchange(i,i-1);
    Changed:=true;
   end;
  end;

  if (List.Count=LevelSize) then
  for i:=List.Count-1 downto 1 do
  begin
   if SysUtils.CompareText(PCDIndexMappingDirectory(List[i]).Name,PCDIndexMappingDirectory(List[i-1]).Name)<0 then
   begin
    List.Exchange(i,i-1);
    Changed:=true;
   end;
  end;
 end else
 begin
  SortLevel(Level);
  SortLevel(List);
 end;
 //for i:=List.Count-1 downto 0 do
 for i:=0 to List.Count-1 do
 Level.Insert(0,List[i]);
 if Changed then SortLevel(Level);
end;

function TCDIndexMapping.GetCurrentUpperDirectories: TStrings;
begin
 Result:=GetCurrentUpperDirectoriesWithDirectory(CurrentDir);
end;

function TCDIndexMapping.GetCurrentUpperDirectoriesWithDirectory(
  PDirectory: PCDIndexMappingDirectory): TStrings;
begin
 if PDirectory.Parent=nil then
 begin
  Result:=TStringList.Create;
  Result.Add('\');
 end else
 begin
  Result:=GetCurrentUpperDirectoriesWithDirectory(PDirectory.Parent);
  Result.Add(GetCurrentPathWithDirectory(PDirectory));
 end;
end;

procedure TCDIndexMapping.SelectRoot;
begin
 CurrentDir:=Root;
end;

procedure TCDIndexMapping.SelectPath(Path: string);
var
  iPos : integer;
  Directory : string;
begin
 if Path='' then exit;

 if Path[1]='\' then
 begin
  SelectRoot;
  Delete(Path,1,1);
 end;
 iPos:=Pos('\',Path);
 Directory:=System.Copy(path,1,iPos-1);
 SelectDirectory(Directory);
 Delete(Path,1,iPos);
 SelectPath(Path);
end;

procedure TCDIndexMapping.Copy(Files: TList);
begin
 ClipboardCut:=false;
 Clipboard.Assign(Files);
end;

procedure TCDIndexMapping.Cut(Files: TList);
begin
 ClipboardCut:=true;
 Clipboard.Assign(Files);
end;

procedure TCDIndexMapping.Paste;
var
  i : integer;
  Item, OldParent : PCDIndexMappingDirectory;
begin
 for i:=0 to Clipboard.Count-1 do
 begin
  Item:=CloneItem(Clipboard[i]);
  OldParent:=PCDIndexMappingDirectory(Clipboard[i]).Parent;
  Item.Parent:=CurrentDir;
  CurrentDir.Files.Add(Item);
  if ClipboardCut then
  FreeItem(OldParent,Clipboard[i]);
 end;
 Clipboard.Clear;
end;

function TCDIndexMapping.CloneItem(
  Item: PCDIndexMappingDirectory): PCDIndexMappingDirectory;
var
  i : integer;
  aItem : PCDIndexMappingDirectory;
begin
 GetMem(aItem,SizeOf(TCDIndexMappingDirectory));
 aItem.Files:=TList.Create;
 aItem.Name:=Item.Name;
 aItem.IsFile:=Item.IsFile;
 aItem.Parent:=Item.Parent;
 aItem.IsReal:=Item.IsReal;
 aItem.DB_ID:=Item.DB_ID;
 aItem.FileSize:=Item.FileSize;
 aItem.RealFileName:=nil;
 SetPCharString(aItem.RealFileName,String(Item.RealFileName));
 for i:=0 to Item.Files.Count-1 do
 begin
  aItem.Files.Add(CloneItem(Item.Files[i]));
 end;
 Result:=aItem;
end;

procedure TCDIndexMapping.FreeItem(Parent, Item: PCDIndexMappingDirectory);
var
  i : integer;
begin
 if Parent <> nil then
 begin
  Parent.Files.Remove(Item);
 end;
 FreeMem(Item.RealFileName);
 for i:=Item.Files.Count-1 downto 0 do
 FreeItem(Item,Item.Files[i]);
 Item.Files.Free;
end;

procedure TCDIndexMapping.ClearClipBoard;
begin
 Clipboard.Clear;
end;

function TCDIndexMapping.DirectoryHasDBFiles(
  Directory: PCDIndexMappingDirectory): boolean;
var
  i : integer;
begin
 Result:=false;
 if Directory.Files=nil then exit;
 for i:=0 to Directory.Files.Count-1 do
 begin
  if PCDIndexMappingDirectory(Directory.Files[i]).IsFile then
  begin
   if PCDIndexMappingDirectory(Directory.Files[i]).DB_ID>0 then
   begin
    Result:=true;
    exit;
   end;
  end else
  begin
   if DirectoryHasDBFiles(Directory.Files[i]) then
   begin
    Result:=true;
    exit;
   end;
  end;
 end;
end;

function TCDIndexMapping.DeleteOriginalStructure(OnProgress : TCallBackProgressEvent) : boolean;
begin
 Result:=DeleteOriginalStructureWithDirectory(Root, OnProgress);
end;

function TCDIndexMapping.DeleteOriginalStructureWithDirectory(
  PDirectory: PCDIndexMappingDirectory; OnProgress : TCallBackProgressEvent): Boolean;
var
  i : integer;
  info : TProgressCallBackInfo;
begin
 Result:=true;
 for i:=0 to PDirectory.Files.Count-1 do
 begin
  if PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
  if PCDIndexMappingDirectory(PDirectory.Files[i]).IsReal then
  begin
   if not SysUtils.DeleteFile(PCDIndexMappingDirectory(PDirectory.Files[i]).RealFileName) then
   begin
    Result:=false;
   end else
   begin
    info.MaxValue:=-1;
    info.Position:=PCDIndexMappingDirectory(PDirectory.Files[i]).FileSize;
    info.Information:='';
    info.Terminate:=false;
    if Assigned(OnProgress) then OnProgress(nil,info);
    if info.Terminate then
    begin
     Result:=false;
     exit;
    end;
   end;
  end;
 end;

 for i:=0 to PDirectory.Files.Count-1 do
 begin
  if not PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
  begin
   if not DeleteOriginalStructureWithDirectory(PDirectory.Files[i],OnProgress) then
   begin
    Result:=false;
   end;
  end;
 end;

 SysUtils.RemoveDir(PDirectory.RealFileName);
end;

function TCDIndexMapping.GetRoot: PCDIndexMappingDirectory;
begin
 Result:=Root;
end;

function TCDIndexMapping.PlaceMapFile(Directory: string): Boolean;
var
  Header : TCDIndexFileHeader;
  HeaderV1 : TCDIndexFileHeaderV1;
  FS : TFileStream;
begin
 Result:=true;
 FormatDir(Directory);
 Directory:=Directory+CDLabel;

 if not SysUtils.DirectoryExists(Directory) then
 if not CreateDir(Directory) then exit;

 FormatDir(Directory);
 try
  FS:=TFileStream.Create(Directory+'DBCDMap.map',fmOpenWrite or fmCreate);
 except
  Result:=false;
  exit;
 end;
 FillChar(Header,SizeOf(Header),#0);
 FillChar(HeaderV1,SizeOf(HeaderV1),#0);
 Header.ID:='PHOTODB_CD_INDEX';
 Header.Version:=1;
 Header.DBVersion:=Dolphin_DB.ReleaseNumber;
 HeaderV1.CDLabel:=CDLabel;
 HeaderV1.Date:=Now;
 try
  FS.Write(Header,SizeOf(Header));
  FS.Write(HeaderV1,SizeOf(HeaderV1));
 except
  Result:=false;
 end;
 FS.Free;
end;

class function TCDIndexMapping.ReadMapFile(FileName: string): TCDIndexInfo;
var
  Header : TCDIndexFileHeader;
  HeaderV1 : TCDIndexFileHeaderV1;
  FS : TFileStream;
begin
 Result.Loaded:=false;
 try
  FS:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
 except
  exit;
 end;

 try
  FS.Read(Header,SizeOf(Header));
  FS.Read(HeaderV1,SizeOf(HeaderV1));
 except
  FS.Free;
  exit;
 end;
 if Header.ID='PHOTODB_CD_INDEX' then
 begin
  Result.CDLabel:= HeaderV1.CDLabel;
  Result.Date:= HeaderV1.Date;
  Result.DBVersion:= Header.DBVersion;
  Result.Loaded:=true;
 end;
 FS.Free;
end;

{ TCDDBMapping }

procedure TCDDBMapping.AddCDMapping(CDName, Path: string;
  Permanent: boolean);
var
  CD : PCDClass;
begin
 CD:=GetCDByName(CDName);
 if CD<>nil then
 begin
  FreeMem(CD.Path);
  CD.Path:=nil;
  SetPCharString(CD.Path,Path);
  exit;
 end;
 GetMem(CD,SizeOf(TCDClass));
 CD.Name:=CDName;
 CD.Tag:=TCD_CLASS_TAG_NONE;
 CD.Path:=nil;
 SetPCharString(CD.Path,Path);
 CDLoadedList.Add(CD);
 if GetCDByNameInternal(CDName)=nil then
 begin
  CD:=nil;
  GetMem(CD,SizeOf(TCDClass));
  CD.Name:=CDName;
  CD.Tag:=TCD_CLASS_TAG_NONE;
  CD.Path:=nil;
  SetPCharString(CD.Path,Path);
  CDFindedList.Add(CD);
 end;
end;

constructor TCDDBMapping.Create;
begin
 CDLoadedList:=TList.Create;
 CDFindedList:=TList.Create;
end;

destructor TCDDBMapping.Destroy;
var
  i : integer;
begin
 for i:=0 to CDLoadedList.Count-1 do
 begin
  FreeMem(PCDClass(CDLoadedList[i]).Path);
 end;
 CDLoadedList.Free;
 for i:=0 to CDFindedList.Count-1 do
 begin
  FreeMem(PCDClass(CDFindedList[i]).Path);
 end;
 CDFindedList.Free;
 inherited;
end;

procedure TCDDBMapping.DoProcessPath(var FileName: string;
  CanUserNotify: boolean);
var
  i,p, MapResult : integer;
  CD : PCDClass;
  CDName : string;
begin
 if Copy(FileName,1,2)='::' then
 begin
  p:=PosEx('::',FileName,3);
  if p>0 then
  begin
   CDName:=Copy(FileName,3,p-3);
   CD:=GetCDByName(CDName);
   if CD<>nil then
   begin
    Delete(FileName,1,p+2);
    FileName:=CD.Path+FileName;
   end else
   begin
    CD:=GetCDByNameInternal(CDName);
    if CD=nil then
    begin
     GetMem(CD,SizeOf(TCDClass));
     CD.Name:=CDName;
     CD.Tag:=TCD_CLASS_TAG_NONE;
     CD.Path:=nil;
     CDFindedList.Add(CD);
    end;
    if CanUserNotify then
    begin
     CD:=GetCDByNameInternal(CDName);
     if CD.Tag<>TCD_CLASS_TAG_NO_QUESTION then
     MapResult:=CheckCD(CDName);
    end;
   end;
  end;
 end;
end;

function TCDDBMapping.GetCDByName(CDName: string): PCDClass;
var
  i : integer;
begin
 Result:=nil;
 for i:=0 to CDLoadedList.Count-1 do
 begin
  if AnsiLowerCase(PCDClass(CDLoadedList[i]).Name)=AnsiLowerCase(CDName) then
  begin
   Result:=PCDClass(CDLoadedList[i]);
   break;
  end;
 end;
end;

function TCDDBMapping.GetCDByNameInternal(CDName: string): PCDClass;
var
  i : integer;
begin
 Result:=nil;
 for i:=0 to CDFindedList.Count-1 do
 begin
  if AnsiLowerCase(PCDClass(CDFindedList[i]).Name)=AnsiLowerCase(CDName) then
  begin
   Result:=PCDClass(CDFindedList[i]);
   break;
  end;
 end;
end;

function TCDDBMapping.GetFindedCDList: TList;
begin
 Result:=CDFindedList;
end;

function TCDDBMapping.ProcessPath(FileName: string;
  CanUserNotify: boolean): string;
begin
 Result:=FileName;
 DoProcessPath(Result,CanUserNotify);
end;

procedure TCDDBMapping.RemoveCDMapping(CDName: string);
var
  CD : PCDClass;
begin
 CD:=GetCDByName(CDName);
 if CD<>nil then
 begin
  FreeMem(CD.Path);
  CD.Path:=nil;
 end;
end;

procedure TCDDBMapping.SetCDWithNOQuestion(CDName: string);
var
  CD : PCDClass;
begin
 CD:=GetCDByNameInternal(CDName);
 if CD<>nil then
 begin
  CD.Tag:=TCD_CLASS_TAG_NO_QUESTION;
 end;
end;

procedure TCDDBMapping.UnProcessPath(var Path: string);
var
  i : integer;
  CDPath : string;
begin
 for i:=0 to CDLoadedList.Count-1 do
 begin
  if PCDClass(CDLoadedList[i]).Path<>nil then
  begin
   CDPath:=PCDClass(CDLoadedList[i]).Path;
   UnFormatDir(CDPath);
   if AnsiLowerCase(Copy(Path,1,Length(CDPath)))=AnsiLowerCase(CDPath) then
   begin
    Delete(Path,1,Length(CDPath));
    Path:=AnsiLowerCase('::'+PCDClass(CDLoadedList[i]).Name+'::'+Path);
   end;
  end;
 end;
end;

initialization
finalization

if CDMapper<>nil then CDMapper.Free;
CDMapper:=nil;

end.
