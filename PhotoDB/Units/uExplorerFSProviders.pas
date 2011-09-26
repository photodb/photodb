unit uExplorerFSProviders;

interface

uses
  uPathProviders, Windows, SysUtils, uFileUtils, uSysUtils, ShellApi,
  uMemory, uShellIcons;

type
  TFSItem = class(TPathItem)
  private
    FImage: TPathImage;
    FDisplayName: string;
    FParent: TPathItem;
  protected
    function GetPathImage: TPathImage; override;
    function GetDisplayName: string; override;
    function GetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    destructor Destroy; override;
  end;

  TFileItem = class(TFSItem);
  TDirectoryItem = class(TFSItem);

type
  TFileSystemProvider = class(TPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection;
      Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  public
    function Supports(Item: TPathItem): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
  end;

implementation

{ TFileSystemProvider }

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
begin
  inherited;
  Cancel := False;
  Result := True;
  LoadOnlyDirectories := Options and PATH_LOAD_DIRECTORIES_ONLY <> 0;
  SearchPath := IncludeTrailingPathDelimiter(Item.Path);
  if IsShortDrive(SearchPath) then
    SearchPath := SearchPath + '\';
  Found := FindFirst(SearchPath + '*', faDirectory, SearchRec);
  try
    while Found = 0 do
    begin
      IsDirectory := SearchRec.Attr and faDirectory <> 0;
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (not IsDirectory or not LoadOnlyDirectories) then
      begin
        FileName := SearchPath + SearchRec.Name;
        if IsDirectory then
        begin
          FI := TFileItem.CreateFromPath(FileName, Options, ImageSize);
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
      Found := SysUtils.FindNext(SearchRec);
    end;

    if Assigned(CallBack) then
      CallBack(Sender, Item, List, Cancel);
  finally
    FindClose(SearchRec);
  end;
end;

function TFileSystemProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item.Path = '';
end;

function TFileSystemProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_CHILD_LIST;
end;

{ TFSItem }

constructor TFSItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
var
  Icon: HIcon;
begin
  inherited;
  FImage := nil;
  FParent := nil;
  FDisplayName := ExtractFileName(APath);
  if Options and PATH_DONT_LOAD_IMAGE = 0 then
  begin
    Icon := ExtractShellIcon(APath, ImageSize);
    FImage := TPathImage.Create(Icon);
  end;
end;

destructor TFSItem.Destroy;
begin
  F(FImage);
  F(FParent);
  inherited;
end;

function TFSItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TFSItem.GetParent: TPathItem;
var
  Path: string;
begin
  if FParent = nil then
  begin
    Path := ExcludeTrailingPathDelimiter(Path);
    Path := ExtractFileDir(Path);
    //TODO:!!!
  end;
  Result := FParent;
end;

function TFSItem.GetPathImage: TPathImage;
begin
  Result := FImage;
end;

end.
