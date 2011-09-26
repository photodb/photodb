unit uExplorerPersonsProvider;

interface

uses
  Graphics, uPathProviders, uPeopleSupport, uBitmapUtils, UnitDBDeclare,
  uMemory, uConstants, uTranslate, uShellIcons, uExplorerMyComputerProvider,
  uExplorerPathProvider;

type
  TPersonsItem = class(TPathItem)
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

type
  TPersonProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
  end;

implementation

{ TPersonProvider }

function TPersonProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  Person: TPerson;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  Info := TDBPopupMenuInfoRecord(Item);
  Person := PersonManager.GetPerson(Info.ID);
  try
    if Person.Image = nil then
      Exit;
    Bitmap.Assign(Person.Image);
    KeepProportions(Bitmap, MaxWidth, MaxHeight);
    Result := True;
  finally
    F(Person);
  end;
end;

function TPersonProvider.GetTranslateID: string;
begin
  Result := 'PersonsProvider';
end;

function TPersonProvider.InternalFillChildList(Sender: TObject; Item: TPathItem;
  List: TPathItemCollection; Options, ImageSize, PacketSize: Integer;
  CallBack: TLoadListCallBack): Boolean;
var
  PI: TPersonsItem;
  Cancel: Boolean;
begin
  inherited;
  Result := True;
  Cancel := False;
  if Item is THomeItem then
  begin
    PI := TPersonsItem.CreateFromPath(cGroupsPath, Options, ImageSize);
    List.Add(PI);

    CallBack(Sender, Item, List, Cancel);
  end;
end;

function TPersonProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item.Parent.Path = cPersonsPath;
end;

function TPersonProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_PROPERTIES;
end;

{ TPersonsItem }

constructor TPersonsItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
var
  Icon: TIcon;
begin
  inherited;
  FParent := nil;
  FPath := cPersonsPath;
  FDisplayName := TA('Persons', 'Path');
  FindIcon(HInstance, 'PERSONS', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
end;

destructor TPersonsItem.Destroy;
begin
  F(FImage);
  F(FParent);
  inherited;
end;

function TPersonsItem.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TPersonsItem.GetParent: TPathItem;
begin
  if FParent = nil then
    FParent := THomeItem.Create;

  Result := FParent;
end;

function TPersonsItem.GetPathImage: TPathImage;
begin
  Result := FImage;
end;

initialization
  PathProviderManager.RegisterProvider(TPersonProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPersonProvider);

end.
