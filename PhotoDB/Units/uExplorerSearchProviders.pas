unit uExplorerSearchProviders;

interface

uses
  SysUtils, uMemory, Classes, uPathProviders, uConstants, StrUtils, uStringUtils,
  uTranslate, uExplorerMyComputerProvider, Graphics, uShellIcons,
  uExplorerFSProviders, uExplorerNetworkProviders;

type
  TSearchItem = class(TPathItem)
  private
    FSearchPath: string;
    FSearchTerm: string;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property SearchPath: string read FSearchPath;
    property SearchTerm: string read FSearchTerm;
  end;

  TDBSearchItem = class(TSearchItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TFileSearchItem = class(TSearchItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TImageSearchItem = class(TFileSearchItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TSearchProvider = class(TPathProvider)
  public
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

{ TSearchProvider }

function TSearchProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TDBSearchItem;
  Result := Result or Supports(Item.Path);
end;

function TSearchProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if StartsText(cDBSearchPath, AnsiLowerCase(Path)) then
    Result := TDBSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if Pos(cFilesSearchPath, AnsiLowerCase(Path)) > 0 then
    Result := TFileSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if Pos(cImagesSearchPath, AnsiLowerCase(Path)) > 0 then
    Result := TImageSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TSearchProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cDBSearchPath, AnsiLowerCase(Path));
  Result := Result or (Pos(cImagesSearchPath, AnsiLowerCase(Path)) > 0);
  Result := Result or (Pos(cFilesSearchPath, AnsiLowerCase(Path)) > 0);
end;

{ TDBSearchItem }

constructor TDBSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search in collection for: "%s"', 'Path'), [SearchTerm]) + '...';
end;

function TDBSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDBSearchItem.Create;
end;

function TDBSearchItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TFileSearchItem }

constructor TFileSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search files for: "%s"', 'Path'), [SearchTerm]) + '...';
end;

function TFileSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TFileSearchItem.Create;
end;

function TFileSearchItem.InternalGetParent: TPathItem;
begin
  if SearchPath = '' then
    Result := THomeItem.Create
  else if IsNetworkShare(SearchPath) then
    Result := TShareItem.CreateFromPath(SearchPath, PATH_LOAD_NO_IMAGE, 0)
  else
    Result := TDirectoryItem.CreateFromPath(SearchPath, PATH_LOAD_NO_IMAGE, 0);
end;

{ TImageSearchItem }

constructor TImageSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search files (with EXIF) for: "%s"', 'Path'), [SearchTerm]) + '...';
end;

function TImageSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TImageSearchItem.Create;
end;

{ TSearchItem }

function TSearchItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'SEARCH', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

procedure TSearchItem.Assign(Item: TPathItem);
begin
  inherited;
  FSearchPath := TSearchItem(Item).FSearchPath;
  FSearchTerm := TSearchItem(Item).FSearchTerm;
end;

constructor TSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
const
  SchemaStart = '::';
  SchemaEnd = '://';
var
  PS, PE: Integer;
begin
  inherited;
  FDisplayName := TA('Search', 'Path');
  PS := Pos(SchemaStart, APath);
  PE := PosEx(SchemaEnd, APath, PS);
  if (PS > 0) and (PE > PS) then
  begin
    FSearchPath := uStringUtils.Left(APath, PS - 1);
    FSearchTerm := uStringUtils.Right(APath, PE + Length(SchemaEnd));
  end;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

initialization
  PathProviderManager.RegisterProvider(TSearchProvider.Create);

end.
