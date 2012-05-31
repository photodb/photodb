unit uCDMappingTypes;

interface

uses
  Classes,
  uMemory,
  SysUtils,
  StrUtils;

const
  TCD_CLASS_TAG_NONE = 0;
  TCD_CLASS_TAG_NO_QUESTION = 1;
  C_CD_MAP_FILE = 'DBCDMap.map';

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
    Name: string[255];
    CDRelativePath: string;
  end;

  TCDDataArray = record
    CDName: string;
    Data: array of TCDDataArrayItem;
  end;

  TCDIndexMappingDirectory = class
  private
    FFiles: TList;
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
    function Add(Item: TCDIndexMappingDirectory): Integer;
    property Items[FileIndex: Integer]: TCDIndexMappingDirectory read GetFileByIndex; default;
    property Count: Integer read GetCount;
    procedure Remove(var Item : TCDIndexMappingDirectory);
    procedure Delete(Index: Integer);
    property Files: TList read FFiles;
  end;

  TDBFilePath = record
    FileName: string;
    ID: Integer;
  end;

  TDBFilePathArray = array of TDBFilePath;

type
  TCDClass = class(TObject)
  public
    Name: string;
    Path: string;
    Tag: Integer;
  end;

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

  TCheckCDFunction = function(CDName: string) : Boolean;

var
  CheckCDFunction: TCheckCDFunction = nil;

function CDMapper: TCDDBMapping;
function ProcessPath(FileName: string; CanUserNotify: Boolean = False): string;
procedure DoProcessPath(var FileName: string; CanUserNotify: Boolean = False);
procedure UnProcessPath(var FileName: string);
function StaticPath(FileName: string): Boolean;

implementation

var
  FCDMapper: TCDDBMapping = nil;

function CDMapper: TCDDBMapping;
begin
  if FCDMapper = nil then
   FCDMapper := TCDDBMapping.Create;

  Result := FCDMapper;
end;

function StaticPath(FileName: string): Boolean;
begin
  Result := True;
  if Copy(FileName, 1, 2) = '::' then
    if PosEx('::', FileName, 3) > 0 then
      Result := False;
end;

procedure DoProcessPath(var FileName: string; CanUserNotify: Boolean = False);
begin
  CDMapper.DoProcessPath(FileName, CanUserNotify);
end;

procedure UnProcessPath(var FileName: string);
begin
  CDMapper.UnProcessPath(FileName);
end;

function ProcessPath(FileName: string; CanUserNotify: Boolean = False): string;
begin
  Result := CDMapper.ProcessPath(FileName, CanUserNotify);
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
  F(Item);
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
  P: Integer;
  MapResult: Boolean;
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
          begin
            MapResult := CheckCDFunction(CDName);
            if MapResult then
              DoProcessPath(FileName, CanUserNotify);
          end;
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
      CDPath := ExcludeTrailingBackslash(CD.Path);
      if AnsiLowerCase(Copy(Path, 1, Length(CDPath))) = AnsiLowerCase(CDPath) then
      begin
        Delete(Path, 1, Length(CDPath));
        Path := AnsiLowerCase('::' + CD.name + '::' + Path);
      end;
    end;
  end;
end;

initialization

finalization
  F(FCDMapper);

end.
