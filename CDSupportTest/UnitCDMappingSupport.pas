unit UnitCDMappingSupport;

interface

 uses Windows, Classes, SysUtils,
 dm
 ;

type
////DB///////////////////////////////////////////

   TProgressCallBackInfo = record
    MaxValue : int64;
    Position : int64;
    Information : String;
    Terminate : Boolean;
  end;

  TCallBackProgressEvent = procedure(Sender : TObject; var Info : TProgressCallBackInfo) of object;
/////////////////////////////////////////////////

type
 //File strusts//////////////////////////////////////
 TCDIndexFileHeader = record
  ID : string[14];
  Version : byte;
  DBVersion : integer;
 end;

 TCDIndexFileHeaderV1 = record
  Records : Cardinal;
  CDLabel : string[250];
 end;

 TCDIndexFileRecordV1 = record
  Name : string[255];
  CDRelativePathLength : integer;
 end;
 //then CDPathData - string! Length of data block = (CDRelativePathLength+1)


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
    Root : PCDIndexMappingDirectory;
    CurrentDir : PCDIndexMappingDirectory;
    Mapping : TCDDataArray;
    fCDLabel: String;
    function GetCurrentPathWithDirectory(Directory : PCDIndexMappingDirectory) : string;
    procedure GetDBRemappingArrayWithDirectory(Directory : PCDIndexMappingDirectory; var Info : TDBFilePathArray);
    procedure SetCDLabel(const Value: String);   
    function CreateStructureToDirectoryWithDirectory(Directory : string; PDirectory : PCDIndexMappingDirectory) : Boolean;
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
   function CreateStructureToDirectory(Directory : string) : Boolean;
   function GetItemByIndex(Index : integer) : PCDIndexMappingDirectory;
   function GetDBRemappingArray : TDBFilePathArray;
   function GetCDSize : Int64;             
   function CurrentLevel : PCDIndexMappingDirectory;
   function GetCDSizeWithDirectory(Directory : PCDIndexMappingDirectory) : int64;
   procedure SortLevel(Level : TList);
  published
   property CDLabel : String read fCDLabel Write SetCDLabel;
 end;

implementation

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
 if not SysUtils.FileExists(ExtractFileName(Path.FileName)) then
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
begin
 CreateDirectory(ExtractFileName(Directory));
 SelectDirectory(ExtractFileName(Directory));
 FormatDir(Directory);
 Found := FindFirst(Directory+'*.*', faAnyFile, SearchRec);
 Info.MaxValue:=0;
 Info.Position:=0;
 Info.Information:='';
 Info.Terminate:=false;
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If SysUtils.FileExists(Directory+SearchRec.Name) then
   begin
    AddRealFile(Directory+SearchRec.Name);
    Info.MaxValue:=Info.MaxValue+GetFileSizeByName(Directory+SearchRec.Name);
   end else
   begin
    If SysUtils.DirectoryExists(Directory+SearchRec.Name) then
    begin
     AddRealDirectory(Directory+SearchRec.Name, CallBackProc);
    end;
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
  i : integer;
begin
 for i:=0 to Files.Count-1 do
 begin
  if SysUtils.DirectoryExists(Files[i]) then AddRealDirectory(Files[i],nil);
  if SysUtils.FileExists(Files[i]) then AddRealFile(Files[i]);
 end;
end;

function TCDIndexMapping.CheckName(FileName: string): string;
begin
 Result:=Trim(FileName);
end;

constructor TCDIndexMapping.Create;
begin
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
  Directory: string): Boolean;
begin
 Result:=false;
 CreateDirA(Directory);
 FormatDir(Directory);
 Directory:=Directory+CDLabel;
 CreateDir(Directory);
 if not SysUtils.DirectoryExists(Directory) then
 begin
  exit;
 end;
 CreateStructureToDirectoryWithDirectory(Directory,Root);
end;

function TCDIndexMapping.CreateStructureToDirectoryWithDirectory(
  Directory: string; PDirectory: PCDIndexMappingDirectory): Boolean;
var
  i : integer;
  DirectoryName, FileName : string;
begin
 for i:=0 to PDirectory.Files.Count-1 do
 if PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
 begin
  FileName:=PCDIndexMappingDirectory(PDirectory.Files[i]).Name;
  DirectoryName:=Directory;
  FormatDir(DirectoryName);
  Windows.CopyFile(PCDIndexMappingDirectory(PDirectory.Files[i]).RealFileName,PChar(DirectoryName+FileName),false);
 end;
 for i:=0 to PDirectory.Files.Count-1 do
 if not PCDIndexMappingDirectory(PDirectory.Files[i]).IsFile then
 begin
  DirectoryName:=Directory;
  FormatDir(DirectoryName);
  DirectoryName:=DirectoryName+PCDIndexMappingDirectory(PDirectory.Files[i]).Name;
  CreateDir(DirectoryName);
  CreateStructureToDirectoryWithDirectory(DirectoryName,PDirectory.Files[i]);
 end;
 Result:=true;
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
  Directory: PCDIndexMappingDirectory): string;
begin
 if Directory.Parent=nil then
 Result:='\'+Result else Result:=GetCurrentPathWithDirectory(Directory.Parent)+CurrentDir.Name+'\'+Result;
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
  Info[Length(Info)-1].FileName:='::'+CDLabel+'::'+GetCurrentPathWithDirectory(Directory)+PCDIndexMappingDirectory(Directory.Files[i]).Name;
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
 //Dolders by text compare -> files by text compare
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
  for i:=Level.Count-1 downto 1 do
  begin
   if SysUtils.CompareText(PCDIndexMappingDirectory(Level[i]).Name,PCDIndexMappingDirectory(Level[i-1]).Name)<0 then
   begin
    Level.Exchange(i,i-1);
    Changed:=true;
   end;
  end;
 end else
 begin
  SortLevel(Level);
  SortLevel(List);
 end;
 for i:=List.Count-1 downto 0 do
 Level.Insert(0,List[i]);
 if Changed then SortLevel(Level);
end;

end.
