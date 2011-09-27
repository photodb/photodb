unit uPathProviders;

interface

uses
  Windows, Classes, Graphics, uMemory, SyncObjs, SysUtils;

const
  PATH_FEATURE_PROPERTIES = 'properties';
  PATH_FEATURE_CHILD_LIST = 'child_list';
  PATH_FEATURE_DELETE = 'delete';
  PATH_FEATURE_RENAME = 'rename';

const
  PATH_LOAD_NORMAL            = 0;
  PATH_LOAD_NO_IMAGE          = 1;
  PATH_LOAD_DIRECTORIES_ONLY  = 2;
  PATH_LOAD_NO_HIDDEN         = 3;

type
  TPathItem = class;

  TPathImage = class(TObject)
  private
    FHIcon: HIcon;
    FIcon: TIcon;
    FBitmap: TBitmap;
    procedure Init;
  public
    constructor Create(Icon: TIcon); overload;
    constructor Create(Icon: HIcon); overload;
    constructor Create(Bitmap: TBitmap); overload;
    destructor Destroy; override;
    procedure DetachImage;
    property HIcon: Windows.HIcon read FHIcon;
    property Icon: TIcon read FIcon;
    property Bitmap: TBitmap read FBitmap;
  end;

  TPathItemCollection = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetItemByIntex(Index: Integer): TPathItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(Item: TPathItem);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPathItem read GetItemByIntex; default;
  end;

  TLoadListCallBack = procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean) of object;

  TPathProvider = class(TObject)
  private
    FExtProviders: TList;
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; virtual;
    function Supports(Path: string): Boolean; overload; virtual;
    function Supports(PathItem: TPathItem): Boolean; overload; virtual;
    function SupportsFeature(Feature: string): Boolean; virtual;
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: Integer): Boolean; overload; virtual;
    function ExecuteFeature(Sender: TObject; Item: TPathItem; Feature: string; Options: Integer): Boolean; overload; virtual;
    function FillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
    procedure RegisterExtension(ExtProvider: TPathProvider);
    function CreateFromPath(Path: string): TPathItem; virtual;
  end;

  TPathProviderClass = class of TPathProvider;

  TPathItem = class(TObject)
  protected
    FPath: string;
    FParent: TPathItem;
    FImage: TPathImage;
    FDisplayName: string;
    function GetPath: string; virtual;
    function GetDisplayName: string; virtual;
    function GetPathImage: TPathImage; virtual;
    function InternalGetParent: TPathItem; virtual;
    function GetParent: TPathItem; virtual;
    function GetProvider: TPathProvider; virtual;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); virtual;
    destructor Destroy; override;
    property Provider: TPathProvider read GetProvider;
    property Path: string read GetPath;
    property DisplayName: string read GetDisplayName;
    property Image: TPathImage read GetPathImage;
    property Parent: TPathItem read GetParent;
  end;

  TPathProviderManager = class(TObject)
  private
    FSync: TCriticalSection;
    FProviders: TList;
    function GetPathProvider(PathItem: TPathItem): TPathProvider;
    function GetCount: Integer;
    function GetProviderByIndex(Index: Integer): TPathProvider;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(Provider: TPathProvider);
    procedure RegisterSubProvider(ProviderClass, ProviderSubClass: TPathProviderClass);
    function CreatePathItem(Path: string): TPathItem;
    function Find(ProviderClass: TPathProviderClass): TPathProvider;
    property Count: Integer read GetCount;
    property Providers[Index: Integer]: TPathProvider read GetProviderByIndex;
  end;

function PathProviderManager: TPathProviderManager;

function IsDrive(S: string): Boolean;
function IsShortDrive(S: string): Boolean;

implementation

var
  FPathProviderManager: TPathProviderManager = nil;

function IsShortDrive(S: string): Boolean;
begin
  Result := (Length(S) = 2) and (S[2] = ':');
end;

function IsDrive(S: string): Boolean;
begin
  Result := IsShortDrive(S) or ((Length(S) = 3) and (S[2] = ':') and (S[3] = '\'));
end;

function PathProviderManager: TPathProviderManager;
begin
  if FPathProviderManager = nil then
    FPathProviderManager := TPathProviderManager.Create;

  Result := FPathProviderManager;
end;

{ TPathProviderManager }

constructor TPathProviderManager.Create;
begin
  FSync := TCriticalSection.Create;
  FProviders := TList.Create;
end;

function TPathProviderManager.CreatePathItem(Path: string): TPathItem;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FProviders.Count - 1 do
      if TPathProvider(FProviders[I]).Supports(Path) then
      begin
        Result := TPathProvider(FProviders[I]).CreateFromPath(Path);
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

destructor TPathProviderManager.Destroy;
begin
  F(FSync);
  FreeList(FProviders);
  inherited;
end;

function TPathProviderManager.Find(
  ProviderClass: TPathProviderClass): TPathProvider;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FProviders.COunt - 1 do
      if TPathProvider(FProviders[I]) is ProviderClass then
      begin
        Result := FProviders[I];
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

function TPathProviderManager.GetCount: Integer;
begin
  FSync.Enter;
  try
    Result := FProviders.Count;
  finally
    FSync.Leave;
  end;
end;

function TPathProviderManager.GetPathProvider(
  PathItem: TPathItem): TPathProvider;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FProviders.COunt - 1 do
      if TPathProvider(FProviders[I]).Supports(PathItem) then
      begin
        Result := FProviders[I];
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

function TPathProviderManager.GetProviderByIndex(Index: Integer): TPathProvider;
begin
  FSync.Enter;
  try
    Result := FProviders[Index];
  finally
    FSync.Leave;
  end;
end;

procedure TPathProviderManager.RegisterProvider(Provider: TPathProvider);
begin
  FSync.Enter;
  try
    FProviders.Add(Provider);
  finally
    FSync.Leave;
  end;
end;

procedure TPathProviderManager.RegisterSubProvider(ProviderClass,
  ProviderSubClass: TPathProviderClass);
var
  I, J: Integer;
begin
  for I := 0 to Count - 1 do
    if TPathProvider(FProviders[I]) is ProviderClass then
    begin
      for J := 0 to FProviders.Count - 1 do
        if TPathProvider(FProviders[J]) is ProviderSubClass then
          TPathProvider(FProviders[I]).RegisterExtension(TPathProvider(FProviders[J]));

      Break;
    end;
end;

{ TPathItem }

constructor TPathItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  FPath := APath;
  FImage := nil;
  FParent := nil;
  FDisplayName := APath;
end;

destructor TPathItem.Destroy;
begin
  F(FImage);
  F(FParent);
  inherited;
end;

function TPathItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TPathItem.GetParent: TPathItem;
begin
  if FParent = nil then
    FParent := InternalGetParent;

  Result := FParent;
end;

function TPathItem.GetPath: string;
begin
  Result := FPath;
end;

function TPathItem.GetPathImage: TPathImage;
begin
  Result := FImage;
end;

function TPathItem.GetProvider: TPathProvider;
begin
  Result := PathProviderManager.GetPathProvider(Self);
end;

function TPathItem.InternalGetParent: TPathItem;
begin
  Result := nil;
end;

{ TPathItemCollection }

procedure TPathItemCollection.Add(Item: TPathItem);
begin
  FList.Add(Item);
end;

procedure TPathItemCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPathItemCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPathItemCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPathItemCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPathItemCollection.GetItemByIntex(Index: Integer): TPathItem;
begin
  Result := FList[Index];
end;

{ TPathProvider }

function TPathProvider.ExecuteFeature(Sender: TObject; Items: TPathItemCollection;
  Feature: string; Options: Integer): Boolean;
begin
  Result := False;
end;

constructor TPathProvider.Create;
begin
  FExtProviders := TList.Create;
end;

function TPathProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
end;

destructor TPathProvider.Destroy;
begin
  F(FExtProviders);
  inherited;
end;

function TPathProvider.ExecuteFeature(Sender: TObject; Item: TPathItem;
  Feature: string; Options: Integer): Boolean;
begin
  if not SupportsFeature(Feature) then
    raise Exception.Create('Not supported!');
  Result := False;
end;

function TPathProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
begin
  Result := False;
end;

function TPathProvider.FillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
var
  I: Integer;
begin
  Result := InternalFillChildList(Sender, Item, List, Options, ImageSize, PacketSize, CallBack);
  for I := 0 to FExtProviders.Count - 1 do
    Result := Result and TPathProvider(FExtProviders[I]).InternalFillChildList(Sender, Item, List, Options, ImageSize, PacketSize, CallBack);
end;

function TPathProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
begin
  Result := False;
end;

procedure TPathProvider.RegisterExtension(ExtProvider: TPathProvider);
begin
  FExtProviders.Add(ExtProvider);
end;

function TPathProvider.Supports(Path: string): Boolean;
begin
  Result := False;
end;

function TPathProvider.Supports(PathItem: TPathItem): Boolean;
begin
  Result := False;
end;

function TPathProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := False;
end;

{ TPathImage }

constructor TPathImage.Create(Icon: TIcon);
begin
  Init;
  FIcon := Icon;
end;

constructor TPathImage.Create(Icon: HIcon);
begin
  Init;
  FHIcon := Icon;
end;

constructor TPathImage.Create(Bitmap: TBitmap);
begin
  Init;
  FBitmap := Bitmap;
end;

destructor TPathImage.Destroy;
begin
  F(FIcon);
  F(FBitmap);
  if FHIcon <> 0 then
    DestroyIcon(FHIcon);
end;

procedure TPathImage.DetachImage;
begin
  Init;
end;

procedure TPathImage.Init;
begin
  FHIcon := 0;
  FIcon := nil;
  FBitmap := nil;
end;

initialization

finalization
  F(FPathProviderManager);

end.
