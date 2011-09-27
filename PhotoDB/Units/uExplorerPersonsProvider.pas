unit uExplorerPersonsProvider;

interface

uses
  Graphics, uPathProviders, uPeopleSupport, uBitmapUtils, UnitDBDeclare,
  uMemory, uConstants, uTranslate, uShellIcons, uExplorerMyComputerProvider,
  uExplorerPathProvider, StrUtils, uStringUtils, SysUtils;

type
  TPersonsItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TPersonItem = class(TPathItem)
  private
    FPersonID: Integer;
  protected
    function InternalGetParent: TPathItem; override;
  public
    procedure ReadFromPerson(Person: TPerson);
    property PersonID: Integer read FPersonID;
  end;

type
  TPersonProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

function ExtractPersonName(Path: string): string;
var
  P: Integer;
begin
  Result := '';
  P := Pos('\', Path);
  if P > 0 then
    Result := Right(Path, P + 1);;
end;

{ TPersonProvider }

function TPersonProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if Path = cPersonsPath then
    Result := TPersonsItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

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
  I: Integer;
  PI: TPersonsItem;
  P: TPersonItem;
  Cancel: Boolean;
  Persons: TPersonCollection;
begin
  inherited;
  Result := True;
  Cancel := False;
  if Item is THomeItem then
  begin
    PI := TPersonsItem.CreateFromPath(cPersonsPath, Options, ImageSize);
    List.Add(PI);

    CallBack(Sender, Item, List, Cancel);
  end;
  if Item is TPersonsItem then
  begin
    Persons := TPersonCollection.Create;
    try
      PersonManager.LoadPersonList(Persons);
      for I := 0 to Persons.Count - 1 do
      begin
        P := TPersonItem.CreateFromPath(cPersonsPath + '\' + IntToStr(Persons[I].ID), PATH_LOAD_NO_IMAGE, 0);
        P.ReadFromPerson(Persons[I]);
        List.Add(P);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
          if Cancel then
            Break;
        end;
      end;

      if (List.Count mod PacketSize = 0) and Assigned(CallBack) then
        CallBack(Sender, Item, List, Cancel);

    finally
      F(Persons);
    end;
  end;

end;

function TPersonProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TPersonsItem;
  Result := Item is TPersonItem or Result;
  Result := Result or Supports(Item.Path);
end;

function TPersonProvider.Supports(Path: string): Boolean;
begin
  Result := StrUtils.StartsText(cPersonsPath, Path);
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
  FPath := cPersonsPath;
  FDisplayName := TA('Persons', 'Path');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
  begin
    FindIcon(HInstance, 'PERSONS', ImageSize, 32, Icon);
    FImage := TPathImage.Create(Icon);
  end;
end;

function TPersonsItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TPersonItem }

function TPersonItem.InternalGetParent: TPathItem;
begin
  Result := TPersonsItem.CreateFromPath(cPersonsPath, PATH_LOAD_NORMAL, 0);
end;

procedure TPersonItem.ReadFromPerson(Person: TPerson);
var
  Bitmap: TBitmap;
begin
  FPersonID := Person.ID;
  FDisplayName := Person.Name;
  Bitmap := TBitmap.Create;
  try
    Bitmap.Assign(Person.Image);
    FImage := TPathImage.Create(Bitmap);
    Bitmap := nil;
  finally
    F(Bitmap);
  end;
end;

initialization
  PathProviderManager.RegisterProvider(TPersonProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TPersonProvider);

end.
