unit uExplorerPersonsProvider;

interface

uses
  Graphics, uPathProviders, uPeopleSupport, uBitmapUtils, UnitDBDeclare,
  uMemory, ExplorerTypes, uConstants;

type
  TPersonProvider = class(TPathProvider)
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

function TPersonProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TExplorerFileInfo;
  if Result then
    Result := Result and (TExplorerFileInfo(Item).FileType = EXPLORER_ITEM_PERSON);
end;

function TPersonProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_PROPERTIES;
end;

initialization
  PathProviderManager.RegisterProvider(TPersonProvider.Create);

end.
