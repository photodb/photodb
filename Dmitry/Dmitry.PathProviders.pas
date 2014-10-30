unit Dmitry.PathProviders;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.Graphics,
  Vcl.ImgList,
  Dmitry.Memory;

const
  PATH_FEATURE_PROPERTIES = 'properties';
  PATH_FEATURE_CHILD_LIST = 'child_list';
  PATH_FEATURE_DELETE = 'delete';
  PATH_FEATURE_RENAME = 'rename';

const
  PATH_LOAD_NORMAL            = 0;
  PATH_LOAD_NO_IMAGE          = 1;
  PATH_LOAD_DIRECTORIES_ONLY  = 2;
  PATH_LOAD_NO_HIDDEN         = 4;
  PATH_LOAD_FOR_IMAGE_LIST    = 8;
  PATH_LOAD_FAST              = 16;
  PATH_LOAD_ONLY_FILE_SYSTEM  = 32;
  PATH_LOAD_CHECK_CHILDREN    = 64;

type
  TPathItem = class;

  TPathImage = class(TObject)
  private
    FHIcon: HIcon;
    FIcon: TIcon;
    FBitmap: TBitmap;
    procedure Init;
    function GetGraphic: TGraphic;
  public
    constructor Create(Icon: TIcon); overload;
    constructor Create(Icon: HIcon); overload;
    constructor Create(Bitmap: TBitmap); overload;
    destructor Destroy; override;
    procedure DetachImage;
    procedure Clear;
    function Copy: TPathImage;
    procedure Assign(Source: TPathImage; DetachSource: Boolean = False);
    procedure AddToImageList(ImageList: TCustomImageList);
    property HIcon: HIcon read FHIcon;
    property Icon: TIcon read FIcon;
    property Bitmap: TBitmap read FBitmap;
    property Graphic: TGraphic read GetGraphic;
  end;

  TPathItemCollection = class(TList<TPathItem>)
  private
    FTag: NativeInt;
  public
    procedure FreeItems;
    property Tag: NativeInt read FTag write FTag;
  end;

  TLoadListCallBack = procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean) of object;
  TLoadListCallBackRef = reference to procedure(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean);

  TPathFeatureOptions = class(TObject)
  private
    FTag: Integer;
  public
    property Tag: Integer read FTag write FTag;
  end;

  TPathFeatureEditOptions = class(TPathFeatureOptions)
  private
    FNewName: string;
  public
    constructor Create(ANewName: string);
    property NewName: string read FNewName write FNewName;
  end;

  TPathFeatureDeleteOptions = class(TPathFeatureOptions)
  private
    FSilent: Boolean;
  public
    constructor Create(ASilent: Boolean);
    property Silent: Boolean read FSilent write FSilent;
  end;

  TPathProvider = class(TObject)
  private
    FExtProviders: TList<TPathProvider>;

    procedure FillChildsCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean);
    //helper for Reference callback
    procedure InternalCallBack(Sender: TObject; Item: TPathItem; CurrentItems: TPathItemCollection; var Break: Boolean);
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; virtual;
    function Supports(Path: string): Boolean; overload; virtual;
    function Supports(PathItem: TPathItem): Boolean; overload; virtual;
    function SupportsFeature(Feature: string): Boolean; virtual;
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: TPathFeatureOptions): Boolean; overload; virtual;
    function FillChilds(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer): Boolean;
    function FillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; overload;
    function FillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBackRef): Boolean; overload;
    procedure RegisterExtension(ExtProvider: TPathProvider; InsertAsFirst: Boolean = False);
    function CreateFromPath(Path: string): TPathItem; virtual;
  end;

  TPathProviderClass = class of TPathProvider;

  TPathItem = class(TObject)
  private
    procedure SetImage(const Value: TPathImage);
  protected
    FPath: string;
    FParent: TPathItem;
    FImage: TPathImage;
    FDisplayName: string;
    FOptions: Integer;
    FImageSize: Integer;
    FTag: Integer;
    FCanHaveChildren: Boolean;
    function GetPath: string; virtual;
    function GetDisplayName: string; virtual;
    procedure SetDisplayName(const Value: string); virtual;
    function GetPathImage: TPathImage; virtual;
    function InternalGetParent: TPathItem; virtual;
    function GetParent: TPathItem; virtual;
    function GetProvider: TPathProvider; virtual;
    function InternalCreateNewInstance: TPathItem; virtual;
    function GetIsInternalIcon: Boolean; virtual;
    function GetIsDirectory: Boolean; virtual;
    function GetFileSize: Int64; virtual;
    procedure UpdateText;
    procedure UpdateImage(ImageSize: Integer);
  public
    constructor Create; virtual;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); virtual;
    destructor Destroy; override;
    function Copy: TPathItem; virtual;
    procedure Assign(Item: TPathItem); virtual;
    procedure DetachImage;
    procedure UpdatePath(Path: string);
    function LoadImage: Boolean; overload;
    function LoadImage(AOptions, AImageSize: Integer): Boolean; overload; virtual;
    function EqualsTo(Item: TPathItem): Boolean;
    function ExtractImage: TPathImage;
    property Provider: TPathProvider read GetProvider;
    property Path: string read GetPath;
    property DisplayName: string read GetDisplayName write SetDisplayName;
    property Image: TPathImage read GetPathImage write SetImage;
    property Parent: TPathItem read GetParent;
    property IsInternalIcon: Boolean read GetIsInternalIcon;
    property Options: Integer read FOptions;
    property ImageSize: Integer read FImageSize;
    property IsDirectory: Boolean read GetIsDirectory;
    property FileSize: Int64 read GetFileSize;
    property CanHaveChildren: Boolean read FCanHaveChildren;
    property Tag: Integer read FTag write FTag;
  end;

  TPathItemClass = class of TPathItem;

  TPathProviderManager = class(TObject)
  private
    FSync: TCriticalSection;
    FProviders: TList<TPathProvider>;
    function GetCount: Integer;
    function GetPathProvider(PathItem: TPathItem): TPathProvider;
    function GetProviderByIndex(Index: Integer): TPathProvider;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(Provider: TPathProvider);
    procedure RegisterSubProvider(ProviderClass, ProviderSubClass: TPathProviderClass;
      InsertAsFirst: Boolean = False);
    function CreatePathItem(Path: string): TPathItem;
    function Supports(Path: string): Boolean;
    function Find(ProviderClass: TPathProviderClass): TPathProvider;
    property Count: Integer read GetCount;
    property Providers[Index: Integer]: TPathProvider read GetProviderByIndex;
    function ExecuteFeature(Sender: TObject; Path, Feature: string): Boolean;
  end;

  TPathItemTextCallBack = procedure(Item: TPathItem);
  TPathItemImageCallBack = procedure(Item: TPathItem; ImageSize: Integer);

function PathProviderManager: TPathProviderManager;

var
  PathProvider_UpdateText: TPathItemTextCallBack = nil;
  PathProvider_UpdateImage: TPathItemImageCallBack = nil;

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
  FProviders := TList<TPathProvider>.Create;
end;

function TPathProviderManager.CreatePathItem(Path: string): TPathItem;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FProviders.Count - 1 do
      if FProviders[I].Supports(Path) then
      begin
        Result := FProviders[I].CreateFromPath(Path);
        Exit;
      end;
  finally
    FSync.Leave;
  end;
end;

function TPathProviderManager.Supports(Path: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  FSync.Enter;
  try
    for I := 0 to FProviders.Count - 1 do
      if FProviders[I].Supports(Path) then
      begin
        Result := True;
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

function TPathProviderManager.ExecuteFeature(Sender: TObject; Path,
  Feature: string): Boolean;
var
  PL: TPathItemCollection;
  P: TPathItem;
begin
  Result := False;

  P := CreatePathItem(Path);
  try
    if P <> nil then
    begin
      if P.Provider.SupportsFeature(Feature) then
      begin
        PL := TPathItemCollection.Create;
        try
          PL.Add(P);
          Result := P.Provider.ExecuteFeature(Sender, PL, Feature, nil);
        finally
          F(PL);
        end;
      end;
    end;
  finally
    F(P);
  end;
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
      if FProviders[I] is ProviderClass then
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
      if FProviders[I].Supports(PathItem) then
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
  ProviderSubClass: TPathProviderClass; InsertAsFirst: Boolean = False);
var
  I, J: Integer;
begin
  for I := 0 to Count - 1 do
    if TPathProvider(FProviders[I]) is ProviderClass then
    begin
      for J := 0 to FProviders.Count - 1 do
        if FProviders[J] is ProviderSubClass then
          FProviders[I].RegisterExtension(TPathProvider(FProviders[J]), InsertAsFirst);

      Break;
    end;
end;

{ TPathItem }

procedure TPathItem.Assign(Item: TPathItem);
begin
  F(FImage);
  F(FParent);
  FCanHaveChildren := Item.FCanHaveChildren;
  FPath := Item.Path;
  FDisplayName := Item.DisplayName;
  F(FImage);
  if Item.FImage <> nil then
    FImage := Item.FImage.Copy;
end;

function TPathItem.Copy: TPathItem;
begin
  Result := InternalCreateNewInstance;
  Result.Assign(Self);
end;

constructor TPathItem.Create;
begin
  FImage := nil;
  FParent := nil;
  FTag := 0;
end;

constructor TPathItem.CreateFromPath(APath: string; Options, ImageSize: Integer);
begin
  FCanHaveChildren := True;
  FPath := APath;
  FImage := nil;
  FParent := nil;
  FDisplayName := APath;
  FOptions := Options;
  FImageSize := ImageSize;
end;

destructor TPathItem.Destroy;
begin
  F(FImage);
  F(FParent);
  inherited;
end;

procedure TPathItem.DetachImage;
begin
  FImage := nil;
end;

function TPathItem.EqualsTo(Item: TPathItem): Boolean;
begin
  if Item = nil then
    Exit(False);

  Result := Item.Path = Path;
end;

function TPathItem.ExtractImage: TPathImage;
begin
  Result := FImage;
  FImage := nil;
end;

function TPathItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TPathItem.GetFileSize: Int64;
begin
  Result := 0;
end;

function TPathItem.GetIsDirectory: Boolean;
begin
  Result := False;
end;

function TPathItem.GetIsInternalIcon: Boolean;
begin
  Result := False;
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
  if FImage = nil then
    LoadImage;
  Result := FImage;
end;

function TPathItem.GetProvider: TPathProvider;
begin
  Result := PathProviderManager.GetPathProvider(Self);
end;

function TPathItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPathItem.Create;
end;

function TPathItem.InternalGetParent: TPathItem;
begin
  Result := nil;
end;

function TPathItem.LoadImage: Boolean;
begin
  Result := LoadImage(Options, ImageSize);
end;

function TPathItem.LoadImage(AOptions, AImageSize: Integer): Boolean;
begin
  Result := False;
end;

procedure TPathItem.SetDisplayName(const Value: string);
begin
  FDisplayName := Value;
end;

procedure TPathItem.SetImage(const Value: TPathImage);
begin
  F(FImage);
  FImage := Value;
end;

procedure TPathItem.UpdateImage(ImageSize: Integer);
begin
  if Assigned(PathProvider_UpdateImage) then
    PathProvider_UpdateImage(Self, ImageSize);
end;

procedure TPathItem.UpdatePath(Path: string);
begin
  FPath := Path;
end;

procedure TPathItem.UpdateText;
begin
  if Assigned(PathProvider_UpdateText) then
    PathProvider_UpdateText(Self);
end;

{ TPathItemCollection }

procedure TPathItemCollection.FreeItems;
var
  Item: TPathItem;
begin
  for Item in Self do
    Item.Free;

  Clear;
end;

{ TPathProvider }

function TPathProvider.ExecuteFeature(Sender: TObject; Items: TPathItemCollection;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  if not SupportsFeature(Feature) then
    raise Exception.Create('Not supported!');
  Result := False;
end;

constructor TPathProvider.Create;
begin
  FExtProviders := TList<TPathProvider>.Create;
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
    Result := Result and FExtProviders[I].InternalFillChildList(Sender, Item, List, Options, ImageSize, PacketSize, CallBack);
end;

function TPathProvider.FillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBackRef): Boolean;
begin
  if not Assigned(CallBack) then
  begin
    Result := FillChildList(Sender, Item, List, Options, ImageSize, PacketSize, TLoadListCallBack(nil));
    Exit;
  end;
  List.Tag := Integer(@CallBack);
  Result := FillChildList(Sender, Item, List, Options, ImageSize, PacketSize, InternalCallBack);
end;

function TPathProvider.FillChilds(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize: Integer): Boolean;
begin
  Result := InternalFillChildList(Sender, Item, List, Options, ImageSize, MaxInt, FillChildsCallBack);
end;

procedure TPathProvider.FillChildsCallBack(Sender: TObject; Item: TPathItem;
  CurrentItems: TPathItemCollection; var Break: Boolean);
begin
  Break := False;
end;

procedure TPathProvider.InternalCallBack(Sender: TObject; Item: TPathItem;
  CurrentItems: TPathItemCollection; var Break: Boolean);
var
  FCallBackRef: TLoadListCallBackRef;
begin
  FCallBackRef := TLoadListCallBackRef(Pointer(CurrentItems.Tag)^);
  FCallBackRef(Sender, Item, CurrentItems, Break);
end;

function TPathProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
begin
  Result := False;
end;

procedure TPathProvider.RegisterExtension(ExtProvider: TPathProvider; InsertAsFirst: Boolean = False);
begin
  if InsertAsFirst then
    FExtProviders.Insert(0, ExtProvider)
  else
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

procedure TPathImage.AddToImageList(ImageList: TCustomImageList);
begin
  if FHIcon <> 0 then
    ImageList_ReplaceIcon(ImageList.Handle, -1, FHIcon)
  else if FIcon <> nil then
    ImageList_ReplaceIcon(ImageList.Handle, -1, FIcon.Handle)
  else if FBitmap <> nil then
    ImageList.Add(FBitmap, nil);
end;

procedure TPathImage.Assign(Source: TPathImage; DetachSource: Boolean = False);
begin
  Clear;

  if DetachSource then
  begin
    FHIcon := Source.HIcon;
    FIcon := Source.FIcon;
    FBitmap := Source.FBitmap;
    Source.DetachImage;
  end else
    begin
    if Source.HIcon <> 0 then
      FHIcon := CopyIcon(Source.HIcon);

    if Source.Icon <> nil then
    begin
      FIcon := TIcon.Create;
      FIcon.Assign(Source.Icon);
    end;

    if Source.Bitmap <> nil then
    begin
      FBitmap := TBitmap.Create;
      FBitmap.Assign(Source.Bitmap);
    end;
  end;
end;

procedure TPathImage.Clear;
begin
  F(FIcon);
  F(FBitmap);
  if FHIcon <> 0 then
    DestroyIcon(FHIcon);
  FHIcon := 0;
end;

function TPathImage.Copy: TPathImage;
var
  Ico: TIcon;
  Bit: TBitmap;
begin
  if FHIcon <> 0 then
    Result := TPathImage.Create(CopyIcon(HIcon))
  else if FIcon <> nil then
  begin
    Ico := TIcon.Create;
    try
      Ico.Handle := CopyIcon(FIcon.Handle);
      Result := TPathImage.Create(Ico);
      Ico := nil;
    finally
      F(Ico);
    end;
  end else
  begin
    Bit := TBitmap.Create;
    try
      Bit.Assign(FBitmap);
      Result := TPathImage.Create(Bit);
      Bit := nil;
    finally
      F(Bit);
    end;
  end;
end;

constructor TPathImage.Create(Bitmap: TBitmap);
begin
  Init;
  FBitmap := Bitmap;
end;

destructor TPathImage.Destroy;
begin
  Clear;
end;

procedure TPathImage.DetachImage;
begin
  Init;
end;

function TPathImage.GetGraphic: TGraphic;
begin
  Result := nil;
  if FBitmap <> nil then
    Result := FBitmap
  else if FIcon <> nil then
    Result := FIcon
  else if FHIcon <> 0 then
  begin
    FIcon := TIcon.Create;
    FIcon.Handle := CopyIcon(FHIcon);
    Result := FIcon;
  end;
end;

procedure TPathImage.Init;
begin
  FHIcon := 0;
  FIcon := nil;
  FBitmap := nil;
end;

{ TPathFeatureEditOptions }

constructor TPathFeatureEditOptions.Create(ANewName: string);
begin
  FNewName := ANewName;
end;

{ TPathFeatureDeleteOptions }

constructor TPathFeatureDeleteOptions.Create(ASilent: Boolean);
begin
  FSilent := ASilent;
end;

initialization

finalization
  F(FPathProviderManager);

end.
