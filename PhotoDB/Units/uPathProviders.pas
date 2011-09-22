unit uPathProviders;

interface

uses
  Classes, Graphics, uMemory, SyncObjs, SysUtils;

type
  TPathItem = class;

  TPathProviderFeature = class(TObject)

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
    property Items[Index: Integer]: TPathItem read GetItemByIntex;
  end;

  TPathProvider = class(TObject)
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; virtual; abstract; 
    function Supports(Item: TPathItem): Boolean; virtual; abstract;
    function SupportsFeature(Feature: string): Boolean; virtual;
    function ExecuteFeature(Items: TPathItemCollection; Feature: string): Boolean; virtual; overload;
    function ExecuteFeature(Item: TPathItem; Feature: string): Boolean; virtual; overload;
  end;

  TPathItem = class(TObject)
  private
    function GetProvider: TPathProvider;
  public
    property Provider: TPathProvider read GetProvider;
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
    property Count: Integer read GetCount;
    property Providers[Index: Integer]: TPathProvider read GetProviderByIndex;
  end;

function PathProviderManager: TPathProviderManager;

implementation

var
  FPathProviderManager: TPathProviderManager = nil;  
  
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

destructor TPathProviderManager.Destroy;
begin
  F(FSync);
  FreeList(FProviders);
  inherited;
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
    for I := 0 to Count - 1 do
      if Providers[I].Supports(PathItem) then
      begin
        Result := Providers[I];
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

{ TPathItem }

function TPathItem.GetProvider: TPathProvider;
begin
  Result := PathProviderManager.GetPathProvider(Self);
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

function TPathProvider.ExecuteFeature(Items: TPathItemCollection;
  Feature: string): Boolean;
begin
  Result := False;
end;

function TPathProvider.ExecuteFeature(Item: TPathItem;
  Feature: string): Boolean;
begin
  if not SupportsFeature(Feature) then
    raise Exception.Create('Not supported!');
  Result := False;
end;

function TPathProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := False;
end;

initialization

finalization
  F(FPathProviderManager);

end.
