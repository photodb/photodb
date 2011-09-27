unit uExplorerFSProviders;

interface

uses
  uPathProviders, Windows, SysUtils, uFileUtils, uSysUtils, ShellApi,
  uMemory, uShellIcons;

type
  TFSItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
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
  FDisplayName := ExtractFileName(APath);
  if Options and PATH_LOAD_NO_IMAGE = 0 then
  begin
    Icon := ExtractShellIcon(APath, ImageSize);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TFSItem.InternalGetParent: TPathItem;
begin
  //TODO:!!!
  Result := nil;
end;

end.
