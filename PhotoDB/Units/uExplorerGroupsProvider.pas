unit uExplorerGroupsProvider;

interface

uses
  Graphics, uPathProviders, UnitGroupsWork, uBitmapUtils, UnitDBDeclare,
  ExplorerTypes, uConstants, UnitDBDeclare;

type
  TGroupProvider = class(TPathProvider)
  protected
    function Delete(Item: TDBPopupMenuInfoRecord): Boolean;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Item: TPathItem; Feature: string): Boolean; override; overload;
  end;

implementation

{ TGroupProvider }

function TGroupProvider.Delete(Item: TDBPopupMenuInfoRecord): Boolean;
begin
  Result := False;
end;

function TGroupProvider.ExecuteFeature(Item: TPathItem;
  Feature: string): Boolean;
begin
  Result := inherited ExecuteFeature(Item, Feature);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(TDBPopupMenuInfoRecord(Item));
end;

function TGroupProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  Group: TGroup;
  Info: TDBPopupMenuInfoRecord;
begin
  Result := False;
  Info := TDBPopupMenuInfoRecord(Item);
  Group := GetGroupByGroupName(Info.FileName, True);

  if Group.GroupImage = nil then
    Exit;

  try
    Bitmap.Assign(Group.GroupImage);
    KeepProportions(Bitmap, MaxWidth, MaxHeight);
    Result := True;
  finally
    FreeGroup(Group);
  end;
end;

function TGroupProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TExplorerFileInfo;
  if Result then
    Result := Result and (TExplorerFileInfo(Item).FileType = EXPLORER_ITEM_GROUP);
end;

function TGroupProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_DELETE;
end;

initialization
  PathProviderManager.RegisterProvider(TGroupProvider.Create);

end.
