unit uCollectionUtils;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  System.Classes,
  System.SysUtils,

  UnitDBDeclare,
  UnitINI,

  uMemory,
  uTranslate,
  uShellUtils;

type
  TDatabaseDirectory = class(TDataObject)
  private
    FPath: string;
    FName: string;
    FSortOrder: Integer;
  public
    constructor Create(Path, Name: string; SortOrder: Integer);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
    property Path: string read FPath write FPath;
    property Name: string read FName write FName;
    property SortOrder: Integer read FSortOrder write FSortOrder;
  end;

procedure SaveDatabaseSyncDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
procedure ReadDatabaseSyncDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
function IsFileInCollectionDirectories(CollectionFile: string; FileName: string): Boolean;
procedure CheckDefaultSyncDirectoryForCollection(CollectionFile: string);

implementation

{ TDatabaseDirectory }

procedure TDatabaseDirectory.Assign(Source: TDataObject);
var
  DD: TDatabaseDirectory;
begin
  DD := Source as TDatabaseDirectory;
  Self.Path := DD.Path;
  Self.Name := DD.Name;
  Self.SortOrder := DD.SortOrder;
end;

function TDatabaseDirectory.Clone: TDataObject;
begin
  Result := TDatabaseDirectory.Create(Path, Name, SortOrder);
end;

constructor TDatabaseDirectory.Create(Path, Name: string; SortOrder: Integer);
begin
  Self.Path := Path;
  Self.Name := Name;
  Self.SortOrder := SortOrder;
end;

procedure ReadDatabaseSyncDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
var
  Reg: TBDRegistry;
  FName, FPath, FIcon: string;
  I, SortOrder: Integer;
  S: TStrings;
  DD: TDatabaseDirectory;

begin
  FolderList.Clear;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);

      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories\' + S[I], True);

        FName := S[I];
        FPath := '';
        FIcon := '';
        SortOrder := 0;
        if Reg.ValueExists('Name') then
          FName := Reg.ReadString('Name');
        if Reg.ValueExists('Path') then
          FPath := Reg.ReadString('Path');
        if Reg.ValueExists('SortOrder') then
          SortOrder := Reg.ReadInteger('SortOrder');

        if (FName <> '') and (FPath <> '') then
        begin
          DD := TDatabaseDirectory.Create(FPath, FName, SortOrder);
          FolderList.Add(DD);
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;

  FolderList.Sort(TComparer<TDatabaseDirectory>.Construct(
     function (const L, R: TDatabaseDirectory): Integer
     begin
       Result := L.SortOrder - R.SortOrder;
     end
  ));
end;

procedure CheckDefaultSyncDirectoryForCollection(CollectionFile: string);
var
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
begin
  FolderList := TList<TDatabaseDirectory>.Create;
  try
    ReadDatabaseSyncDirectories(FolderList, CollectionFile);
    if (FolderList.Count = 0) then
    begin
      DD := TDatabaseDirectory.Create(GetMyPicturesPath, TA('My Pictures', 'Explorer'), 0);
      FolderList.Add(DD);
      SaveDatabaseSyncDirectories(FolderList, CollectionFile);
    end;

  finally
    FreeList(FolderList);
  end;
end;

procedure SaveDatabaseSyncDirectories(FolderList: TList<TDatabaseDirectory>; CollectionFile: string);
var
  Folder: TDatabaseDirectory;
  Reg: TBDRegistry;
  S: TStrings;
  I: Integer;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      for I := 0 to S.Count - 1 do
        Reg.DeleteKey(S[I]);

      for I := 0 to FolderList.Count - 1 do
      begin
        Folder := FolderList[I];

        Reg.CloseKey;
        Reg.OpenKey(GetCollectionRootKey(CollectionFile) + '\Directories\' + IntToStr(I), True);

        Reg.WriteString('Name', Folder.Name);
        Reg.WriteString('Path', Folder.Path);
        Reg.WriteInteger('SortOrder', Folder.SortOrder);
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

function IsFileInCollectionDirectories(CollectionFile: string; FileName: string): Boolean;
var
  FolderList: TList<TDatabaseDirectory>;
  I: Integer;
  S, FileDirectory: string;
begin
  Result := False;
  if FileName = '' then
    Exit;

  FileDirectory := AnsiLowerCase(ExtractFileDir(FileName));

  FolderList := TList<TDatabaseDirectory>.Create;
  try
    ReadDatabaseSyncDirectories(FolderList, CollectionFile);

    for I := 0 to FolderList.Count - 1 do
    begin
      S := ExcludeTrailingPathDelimiter(AnsiLowerCase(FolderList[I].Path));
      if FileDirectory.StartsWith(S) then
        Exit(True);
    end;
  finally
    FreeList(FolderList);
  end;
end;

end.
