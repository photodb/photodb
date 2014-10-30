unit Dmitry.PathProviders.FileSystem;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Winapi.Windows,
  Winapi.ShellApi,
  Dmitry.Memory,
  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer;

type
  TFSItem = class(TPathItem)
  private
    FFileSize: Int64;
    FTimeStamp: TDateTime;
  protected
    FItemLoaded: Boolean;
    function InternalGetParent: TPathItem; override;
    function GetFileSize: Int64; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property TimeStamp: TDateTime read FTimeStamp;
  end;

  TFileItem = class(TFSItem)
  protected                  
    function GetFileSize: Int64; override;
    procedure ReadFromSearchRec(SearchRec: TSearchRec);
    function InternalCreateNewInstance: TPathItem; override;
  end;

  TDirectoryItem = class(TFSItem)
  protected
    function GetIsDirectory: Boolean; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TFileSystemProvider = class(TPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection;
      Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function Delete(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureOptions): Boolean;
  public
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

uses
  Dmitry.PathProviders.Network;

function IsNetworkDirectory(S: string): Boolean;
begin
  Result := False;
  S := ExcludeTrailingPathDelimiter(S);
  if (Length(S) > 2) and (Copy(S, 1, 2) = '\\') and (Copy(S, 3, 1) <> '\') and (PosEx('\', S, PosEx('\', S, 3) + 1) > 0) then
    Result := True;
end;

function FastIsDirectory(S: string): Boolean;
begin
  Result := False;
  if IsNetworkDirectory(S) then
  begin
    Result := True;
    Exit;
  end;

  if Length(S) > 1 then
  begin
    if (S[2] = ':') then
    begin
      if Length(S) > 2 then
      begin
        if (PosEx(':', S, 3) = 0) then
        begin
          Result := True;
        end;
      end else
        Result := True;
    end;
  end;
end;

function FastIsFile(S: string): Boolean;
begin
  Result := False;
end;

{ TFileSystemProvider }

function TFileSystemProvider.Delete(Sender: TObject; Items: TPathItemCollection;
  Options: TPathFeatureOptions): Boolean;
var
  I: Integer;
  Item: TPathItem;
begin
  Result := False;

  for I := 0 to Items.Count - 1 do
  begin
    Item := Items[I];

    if not System.SysUtils.DeleteFile(Item.Path) then
      Result := False;
  end;
end;

function TFileSystemProvider.ExecuteFeature(Sender: TObject;
  Items: TPathItemCollection; Feature: string;
  Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Items, Feature, Options);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(Sender, Items, Options);
end;

function TFileSystemProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  SearchPath, FileName: string;
  Found: Integer;
  SearchRec: TSearchRec;
  LoadOnlyDirectories, IsDirectory: Boolean;
  FI: TFileItem;
  DI: TDirectoryItem;
  Cancel: Boolean;
  OldMode: Cardinal;
begin
  inherited;
  Cancel := False;
  Result := True;
  LoadOnlyDirectories := Options and PATH_LOAD_DIRECTORIES_ONLY <> 0;
  SearchPath := IncludeTrailingPathDelimiter(Item.Path);
  if IsShortDrive(SearchPath) then
    SearchPath := SearchPath + '\';

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Found := FindFirst(SearchPath + '*', faDirectory, SearchRec);
    try
      while Found = 0 do
      begin
        IsDirectory := SearchRec.Attr and faDirectory <> 0;

        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and not (not IsDirectory and LoadOnlyDirectories) then
        begin
          FileName := SearchPath + SearchRec.Name;
          if not IsDirectory then
          begin
            FI := TFileItem.CreateFromPath(FileName, Options, ImageSize);
            FI.ReadFromSearchRec(SearchRec);
            List.Add(FI);
          end else
          begin
            DI := TDirectoryItem.CreateFromPath(FileName, Options, ImageSize);
            List.Add(DI);
          end;

          if List.Count mod PacketSize = 0 then
          begin
            if Assigned(CallBack) then
              CallBack(Sender, Item, List, Cancel);
            if Cancel then
              Break;
          end;
        end;
        Found := System.SysUtils.FindNext(SearchRec);
      end;

      if Assigned(CallBack) then
        CallBack(Sender, Item, List, Cancel);
    finally
      System.SysUtils.FindClose(SearchRec);
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function TFileSystemProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TFileItem;
  Result := Item is TDirectoryItem or Result;
  Result := Result or Supports(Item.Path);
end;

function TFileSystemProvider.Supports(Path: string): Boolean;
begin
  if IsNetworkServer(Path) or IsNetworkShare(Path) then
  begin
    Result := False;
    Exit;
  end;
  Result := FastIsFile(Path) or FastIsDirectory(Path);
end;

function TFileSystemProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if IsDrive(Path) then
    Result := TDriveItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0)
  else if FastIsFile(Path) then
    Result := TFileItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0)
  else if FastIsDirectory(Path) then
    Result := TDirectoryItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);

end;

function TFileSystemProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_DELETE;
  Result := Result or (Feature = PATH_FEATURE_CHILD_LIST);
end;

{ TFSItem }

constructor TFSItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  inherited;
  FItemLoaded := False;
  APath := ExcludeTrailingPathDelimiter(APath);
  FDisplayName := ExtractFileName(APath);
  FFileSize := 0;
  FTimeStamp := Now;
  if (Options and PATH_LOAD_NO_IMAGE = 0) and (ImageSize > 0) then
    LoadImage(Options, ImageSize);
end;

function TFSItem.GetFileSize: Int64;
begin
  Result := FFileSize;
end;

function TFSItem.InternalGetParent: TPathItem;
var
  S: String;
begin
  S := Path;
  while IsPathDelimiter(S, Length(S)) do
    S := ExcludeTrailingPathDelimiter(S);

  S := ExtractFileDir(S);
  if IsDrive(S) then
    Result := TDriveItem.CreateFromPath(S, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0)
  else if IsNetworkShare(S) then
    Result := TShareItem.CreateFromPath(S, PATH_LOAD_NO_IMAGE, 0)
  else if S <> '' then
    Result := TDirectoryItem.CreateFromPath(S, PATH_LOAD_NO_IMAGE, 0)
  else
    Result := THomeItem.Create;
end;

function TFSItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: HIcon;
begin
  F(FImage);
  Icon := ExtractShellIcon(FPath, ImageSize);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TFileItem }

function TFileItem.GetFileSize: Int64;
var
  SearchRec: TSearchRec;
  HFind: THandle;
begin
  if not FItemLoaded then
  begin
    FItemLoaded := True;
    HFind := FindFirst(PChar(Path), faAnyFile, SearchRec);
    if HFind <> INVALID_HANDLE_VALUE then
    begin
      if SearchRec.FindHandle <> INVALID_HANDLE_VALUE then
      begin
        if (SearchRec.Attr and FILE_ATTRIBUTE_DIRECTORY) = 0 then
          FFileSize := SearchRec.Size;
        FTimeStamp := SearchRec.TimeStamp;
      end;
      System.SysUtils.FindClose(SearchRec);
    end;
  end;

  Result := FFileSize;
end;

function TFileItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TFileItem.Create;
end;

procedure TFileItem.ReadFromSearchRec(SearchRec: TSearchRec);
begin
  FFileSize := SearchRec.Size;
  FTimeStamp := SearchRec.TimeStamp;
  FItemLoaded := True;
end;

{ TDirectoryItem }

constructor TDirectoryItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_CHECK_CHILDREN > 0 then
    FCanHaveChildren := IsDirectoryHasDirectories(Path);
end;

function TDirectoryItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDirectoryItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDirectoryItem.Create;
end;

initialization
  PathProviderManager.RegisterProvider(TFileSystemProvider.Create);

end.
