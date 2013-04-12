unit uExplorerPersonsProvider;

interface

uses
  System.SysUtils,
  System.StrUtils,
  Winapi.Windows,
  Vcl.Graphics,

  Dmitry.Utils.System,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  UnitDBDeclare,

  uPeopleRepository,
  uBitmapUtils,
  uTime,
  uMemory,
  uConstants,
  uTranslate,
  uExplorerPathProvider,
  uStringUtils,
  uJpegUtils,
  uShellIntegration,
  uDBForm,
  uDBClasses,
  uDBEntities,
  uDBContext,
  uDBManager,
  uCollectionEvents;

type
  TPersonsItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TPersonItem = class(TPathItem)
  private
    FPersonName: string;
    FPersonID: Integer;
    FComment: string;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    procedure ReadFromPerson(Person: TPerson; Options, ImageSize: Integer);
    property PersonName: string read FPersonName;
    property Comment: string read FComment;
    property PersonID: Integer read FPersonID;
  end;

type
  TPersonProvider = class(TExplorerPathProvider)
  protected
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
    function GetTranslateID: string; override;
    function ShowProperties(Sender: TObject; Items: TPathItemCollection): Boolean;
    function Rename(Sender: TObject; Items: TPathItemCollection; Options: TPathFeatureEditOptions): Boolean;
    function Delete(Sender: TObject;  Items: TPathItemCollection): Boolean;
  public
    function ExtractPreview(Item: TPathItem; MaxWidth, MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function SupportsFeature(Feature: string): Boolean; override;
    function ExecuteFeature(Sender: TObject; Items: TPathItemCollection; Feature: string; Options: TPathFeatureOptions): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

implementation

uses
  uFormCreatePerson;

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
  if StartsText(cPersonsPath + '\', Path) then
    Result := TPersonItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TPersonProvider.Delete(Sender: TObject; Items: TPathItemCollection): Boolean;
var
  P: TPerson;
  SC: TSelectCommand;
  Count: Integer;
  EventValues: TEventValues;
  Form: TDBForm;
  Item: TPersonItem;
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  Result := False;

  Form := TDBForm(Sender);

  if Items.Count = 0 then
    Exit;

  if Items.Count > 1 then
  begin
    MessageBoxDB(Form.Handle, L('Please delete only one person at time!'), L('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
    Exit;
  end;

  Item := TPersonItem(Items[0]);

  Context := DBManager.DBContext;
  PeopleRepository := Context.People;

  P := PeopleRepository.GetPersonByName(Item.PersonName);
  try
    if not P.Empty then
    begin
      SC := Context.CreateSelect(ObjectMappingTableName);
      try
        SC.AddParameter(TCustomFieldParameter.Create('Count(1) as RecordCount'));
        SC.AddWhereParameter(TIntegerParameter.Create('ObjectID', P.ID));
        if SC.Execute > 0 then
        begin
          Count := SC.DS.FieldByName('RecordCount').AsInteger;
          if ID_OK = MessageBoxDB(Form.Handle, FormatEx(L('Do you really want to delete person "{0}" (Has {1} reference(s) on photo(s))?'), [P.Name, Count]), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
          begin
            Result := PeopleRepository.DeletePerson(Item.PersonName);
            if Result then
            begin
              EventValues.ID := P.ID;
              CollectionEvents.DoIDEvent(Form, Item.PersonID, [EventID_PersonRemoved], EventValues);
            end;
          end;
        end;
      finally
        F(SC);
      end;
    end;
  finally
    F(P);
  end;
end;

function TPersonProvider.ExecuteFeature(Sender: TObject; Items: TPathItemCollection;
  Feature: string; Options: TPathFeatureOptions): Boolean;
begin
  Result := inherited ExecuteFeature(Sender, Items, Feature, Options);

  if Feature = PATH_FEATURE_DELETE then
    Result := Delete(Sender, Items);

  if Feature = PATH_FEATURE_PROPERTIES then
    Result := ShowProperties(Sender, Items);

  if Feature = PATH_FEATURE_RENAME then
    Result := Rename(Sender, Items, Options as TPathFeatureEditOptions);
end;

function TPersonProvider.ExtractPreview(Item: TPathItem; MaxWidth,
  MaxHeight: Integer; var Bitmap: TBitmap; var Data: TObject): Boolean;
var
  Person: TPerson;
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  Result := False;

  Context := DBManager.DBContext;
  PeopleRepository := Context.People;

  Person := TPerson.Create;
  try
    PeopleRepository.FindPerson(ExtractPersonName(Item.Path), Person);
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
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    PI := TPersonsItem.CreateFromPath(cPersonsPath, Options, ImageSize);
    List.Add(PI);
  end;

  if Item is TPersonsItem then
  begin
    Context := DBManager.DBContext;
    PeopleRepository := Context.People;

    Persons := TPersonCollection.Create;
    try
      PeopleRepository.LoadPersonList(Persons);
      for I := 0 to Persons.Count - 1 do
      begin
        TW.I.Start('Person - create');
        P := TPersonItem.CreateFromPath(cPersonsPath + '\' + Persons[I].Name, PATH_LOAD_NO_IMAGE, 0);
        TW.I.Start('Person - load');
        P.ReadFromPerson(Persons[I], Options, ImageSize);
        TW.I.Start('Person - load - end');
        List.Add(P);

        if List.Count mod PacketSize = 0 then
        begin
          if Assigned(CallBack) then
            CallBack(Sender, Item, List, Cancel);
        end;
        if Cancel then
          Break;
      end;

    finally
      F(Persons);
    end;
  end;

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TPersonProvider.Rename(Sender: TObject; Items: TPathItemCollection;
  Options: TPathFeatureEditOptions): Boolean;
var
  EventValues: TEventValues;
  Item: TPersonItem;
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  Result := False;

  if Items.Count = 0 then
    Exit;

  Item := TPersonItem(Items[0]);

  Context := DBManager.DBContext;
  PeopleRepository := Context.People;

  Result := PeopleRepository.RenamePerson(Item.PersonName, Options.NewName);
  if Result then
  begin
    EventValues.ID := Item.PersonID;
    EventValues.FileName := Options.NewName;
    EventValues.NewName := Options.NewName;
    CollectionEvents.DoIDEvent(TDBForm(Sender), Item.PersonID, [EventID_PersonChanged], EventValues);
  end;
end;

function TPersonProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TPersonsItem;
  Result := Item is TPersonItem or Result;
  Result := Result or Supports(Item.Path);
end;

function TPersonProvider.ShowProperties(Sender: TObject;
  Items: TPathItemCollection): Boolean;
var
  P: TPerson;
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  Result := False;

  if Items.Count = 0 then
    Exit;

  Context := DBManager.DBContext;
  PeopleRepository := Context.People;

  P := PeopleRepository.GetPersonByName(TPersonItem(Items[0]).PersonName);
  try
    Result := P.ID > 0;
    if Result then
      EditPerson(P.ID);
  finally
    F(P);
  end;
end;

function TPersonProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cPersonsPath, Path);

  if Result then
  begin
    System.Delete(Path, 1, Length(cPersonsPath) + 1);

    //subitem
    if Pos('\', Path) > 0 then
      Result := False;
  end;
end;

function TPersonProvider.SupportsFeature(Feature: string): Boolean;
begin
  Result := Feature = PATH_FEATURE_PROPERTIES;
  Result := Result or (Feature = PATH_FEATURE_DELETE);
  Result := Result or (Feature = PATH_FEATURE_RENAME);
end;

{ TPersonsItem }

constructor TPersonsItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FPath := cPersonsPath;
  FDisplayName := TA('Persons', 'Path');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TPersonsItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TPersonsItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPersonsItem.Create;
end;

function TPersonsItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TPersonsItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'PERSONS', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TPersonItem }

procedure TPersonItem.Assign(Item: TPathItem);
begin
  inherited;
  FPersonName := TPersonItem(Item).FPersonName;
  FComment := TPersonItem(Item).FComment;
  FPersonID := TPersonItem(Item).FPersonID;
end;

constructor TPersonItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FPersonName := APath;
  Delete(FPersonName, 1, Length(cPersonsPath) + 1);
  FDisplayName := FPersonName;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TPersonItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TPersonItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TPersonItem.Create;
end;

function TPersonItem.InternalGetParent: TPathItem;
begin
  Result := TPersonsItem.CreateFromPath(cPersonsPath, PATH_LOAD_NORMAL, 0);
end;

function TPersonItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Person: TPerson;
  Context: IDBContext;
  PeopleRepository: IPeopleRepository;
begin
  Result := False;
  F(FImage);

  Context := DBManager.DBContext;
  PeopleRepository := Context.People;

  Person := PeopleRepository.GetPersonByName(FPersonName);
  try
    if not Person.Empty then
    begin
      ReadFromPerson(Person, Options, ImageSize);
      Result := True;
    end;
  finally
    F(Person);
  end;
end;

procedure TPersonItem.ReadFromPerson(Person: TPerson; Options, ImageSize: Integer);
var
  Bitmap: TBitmap;
begin
  F(FImage);
  FPersonName := Person.Name;
  FDisplayName := Person.Name;
  FComment := Person.Comment;
  FPersonID := Person.ID;
  if (Person.Image <> nil) and (ImageSize > 0) then
  begin
    Bitmap := TBitmap.Create;
    try
      JPEGScale(Person.Image, ImageSize, ImageSize);
      AssignJpeg(Bitmap, Person.Image);
      KeepProportions(Bitmap, ImageSize, ImageSize);
      if Options and PATH_LOAD_FOR_IMAGE_LIST <> 0 then
        CenterBitmap24To32ImageList(Bitmap, ImageSize);
      FImage := TPathImage.Create(Bitmap);
      Bitmap := nil;
    finally
      F(Bitmap);
    end;
  end;
end;

end.
