unit uPeopleSupport;

interface

uses
  Classes, DB, jpeg, uMemory, SyncObjs;

type
  TPerson = class;

  TPersonCollection = class;

  TPersonArea = class;

  TPersonAreaCollection = class;

  TPersonManager = class(TObject)
  private
    FPeoples: TList;
    FSync: TCriticalSection;
    function GetAllPersons: TPersonCollection;
  public
    function FindPersone(PersonID: Integer): TPerson;
    function CreateNewPerson(Person: TPerson): Boolean;
    function DeletePerson(PersonID: Integer): Boolean;
    function UpdatePerson(Person: TPerson): Boolean;
    function GetPersonsOnImage(ImageID: Integer): TPersonCollection;
    function GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
    function AddPersonForPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
    function RemovePersonFromPhoto(ImageID: Integer; PersonID: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
    property AllPersons: TPersonCollection read GetAllPersons;
  end;

  TPersonCollection = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetPersonByIndex(Index: Integer): TPerson;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReadFromDS(DS: TDataSet);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPerson read GetPersonByIndex; default;
  end;

  TPerson = class(TObject)
  private
    FID: Integer;
    FName: string;
    FImage: TJpegImage;
    FGroups: string;
    procedure SetImage(const Value: TJpegImage);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
    property ID: Integer read FID write FID;
    property Name: string read FName write FName;
    property Image: TJpegImage read FImage write SetImage;
    property Groups: string read FGroups write FGroups;
  end;

  TPersonArea = class
  private
    FX: Integer;
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FFullWidth: Integer;
    FFullHeight: Integer;
    FImageID: Integer;
    FPersonID: Integer;
  public
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
  end;

  TPersonAreaCollection = class(TObject)
  private
    FList: TList;
    function GetAreaByIndex(Index: Integer): TPersonArea;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReadFromDS(DS: TDataSet);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPersonArea read GetAreaByIndex; default;
  end;

implementation

{ TPerson }

constructor TPerson.Create;
begin
  FID := 0;
  FName := '';
  FImage := nil;
  FGroups := '';
end;

destructor TPerson.Destroy;
begin
  F(FImage);
  inherited;
end;

procedure TPerson.ReadFromDS(DS: TDataSet);
begin

end;

procedure TPerson.SaveToDS(DS: TDataSet);
begin

end;

procedure TPerson.SetImage(const Value: TJpegImage);
begin
  F(FImage);
  FImage := TJpegImage.Create;
  FImage.Assign(Value);
end;

{ TPersonManager }

function TPersonManager.AddPersonForPhoto(ImageID: Integer;
  PersonArea: TPersonArea): Boolean;
begin

end;

constructor TPersonManager.Create;
begin
  FPeoples := TList.Create;
  FSync := TCriticalSection.Create;
end;

function TPersonManager.CreateNewPerson(Person: TPerson): Boolean;
begin

end;

function TPersonManager.DeletePerson(PersonID: Integer): Boolean;
begin

end;

destructor TPersonManager.Destroy;
begin
  FreeList(FPeoples);
  F(FSync);
  inherited;
end;

function TPersonManager.FindPersone(PersonID: Integer): TPerson;
begin

end;

function TPersonManager.GetAllPersons: TPersonCollection;
begin

end;

function TPersonManager.GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
begin

end;

function TPersonManager.GetPersonsOnImage(ImageID: Integer): TPersonCollection;
begin

end;

function TPersonManager.RemovePersonFromPhoto(ImageID,
  PersonID: Integer): Boolean;
begin

end;

function TPersonManager.UpdatePerson(Person: TPerson): Boolean;
begin

end;

{ TPersonCollection }

procedure TPersonCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPersonCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPersonCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPersonCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPersonCollection.GetPersonByIndex(Index: Integer): TPerson;
begin
  Result := FList[Index];
end;

procedure TPersonCollection.ReadFromDS(DS: TDataSet);
begin
  Clear;
end;

{ TPersonAreaCollection }

procedure TPersonAreaCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPersonAreaCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPersonAreaCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPersonAreaCollection.GetAreaByIndex(Index: Integer): TPersonArea;
begin
  Result := FList[Index];
end;

function TPersonAreaCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TPersonAreaCollection.ReadFromDS(DS: TDataSet);
begin
  Clear;
end;

end.
