unit uPeopleSupport;

interface

uses
  SysUtils, Classes, DB, jpeg, uMemory, SyncObjs, uDBClasses, uPersonDB,
  uFaceDetection, uSettings, Math, uFastLoad, UnitDBKernel;

const
  PersonTableName = 'Persons';
  PersonMappingTableName = 'PersonMapping';

type
  TPerson = class;

  TPersonCollection = class;

  TPersonArea = class;

  TPersonAreaCollection = class;

  TPersonManager = class(TObject)
  private
    FPeoples: TPersonCollection;
    FSync: TCriticalSection;
    function GetAllPersons: TPersonCollection;
    procedure MarkLatestPerson(PersonID: Integer);
  public
    procedure InitDB;
    procedure LoadPersonList(Persons: TPersonCollection);
    function FindPerson(PersonID: Integer): TPerson; overload;
    function FindPerson(PersonName: string): TPerson; overload;
    function GetPerson(PersonID: Integer): TPerson;
    function GetPersonByName(PersonName: string): TPerson;
    function RenamePerson(PersonName, NewName: string): Boolean;
    function CreateNewPerson(Person: TPerson): Boolean;
    function DeletePerson(PersonID: Integer): Boolean; overload;
    function DeletePerson(PersonName: string): Boolean; overload;
    function UpdatePerson(Person: TPerson; UpdateImage: Boolean): Boolean;
    function GetPersonsOnImage(ImageID: Integer): TPersonCollection;
    function GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
    function AddPersonForPhoto(PersonArea: TPersonArea): Boolean;
    function RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
    function ChangePerson(PersonArea: TPersonArea; ToPersonID: Integer): Boolean;
    procedure FillLatestSelections(Persons: TPersonCollection);
    constructor Create;
    destructor Destroy; override;
    property AllPersons: TPersonCollection read GetAllPersons;
  end;

  TPersonCollection = class(TObject)
  private
    FList: TList;
    FFreeCollectionItems: Boolean;
    function GetCount: Integer;
    function GetPersonByIndex(Index: Integer): TPerson;
  public
    function GetPersonByName(PersonName: string): TPerson;
    constructor Create(FreeCollectionItems: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(Person: TPerson);
    procedure ReadFromDS(DS: TDataSet);
    function GetPersonByID(ID: Integer): TPerson;
    procedure DeleteAt(I: Integer);
    procedure RemoveByID(PersonID: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPerson read GetPersonByIndex; default;
  end;

  TPerson = class(TClonableObject)
  private
    FEmpty: Boolean;
    FID: Integer;
    FName: string;
    FImage: TJpegImage;
    FGroups: string;
    FBirthDay: TDateTime;
    FComment: string;
    FPhone: string;
    FAddress: string;
    FCompany: string;
    FJobTitle: string;
    FIMNumber: string;
    FEmail: string;
    FSex: Integer;
    FCreateDate: TDateTime;
    procedure SetImage(const Value: TJpegImage);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
    procedure Assign(Source: TPerson);
    function Clone: TClonableObject; override;
    property ID: Integer read FID write FID;
    property Name: string read FName write FName;
    property BirthDay: TDateTime read FBirthDay write FBirthDay;
    property Image: TJpegImage read FImage write SetImage;
    property Groups: string read FGroups write FGroups;
    property Comment: string read FComment write FComment;
    property Phone: string read FPhone write FPhone;
    property Address: string read FAddress write FAddress;
    property Company: string read FCompany write FCompany;
    property JobTitle: string read FJobTitle write FJobTitle;
    property IMNumber: string read FIMNumber write FIMNumber;
    property Email: string read FEmail write FEmail;
    property Sex: Integer read FSex write FSex;
    property CreateDate: TDateTime read FCreateDate;
    property Empty: Boolean read FEmpty;
  end;

  TPersonArea = class(TClonableObject)
  private
    FID: Integer;
    FX: Integer;
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FFullWidth: Integer;
    FFullHeight: Integer;
    FImageID: Integer;
    FPersonID: Integer;
    FPage: Integer;
  public
    constructor Create; overload;
    constructor Create(ImageID, PersonID: Integer; Area: TFaceDetectionResultItem); overload;
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
    function Clone: TClonableObject; override;
    property ID: Integer read FID write FID;
    property X: Integer read FX;
    property Y: Integer read FY;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property FullWidth: Integer read FFullWidth;
    property FullHeight: Integer read FFullHeight;
    property ImageID: Integer read FImageID;
    property PersonID: Integer read FPersonID;
    property Page: Integer read FPage;
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
    function Extract(Index: Integer): TPersonArea;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPersonArea read GetAreaByIndex; default;
  end;

function PersonManager: TPersonManager;

implementation

var
  FManager: TPersonManager = nil;

function PersonManager: TPersonManager;
begin
  if FManager = nil then
    FManager := TPersonManager.Create;

  Result := FManager;
end;

{ TPerson }

procedure TPerson.Assign(Source: TPerson);
begin
  FID := Source.ID;
  FName := Source.Name;
  Image := Source.Image;
  FGroups := Source.Groups;
  FBirthDay := Source.BirthDay;
  FComment := Source.Comment;
  FPhone := Source.Phone;
  FAddress := Source.Address;
  FCompany := Source.Company;
  FJobTitle := Source.JobTitle;
  FIMNumber := Source.IMNumber;
  FEmail := Source.Email;
  FSex := Source.Sex;
  FCreateDate := Source.CreateDate;
end;

function TPerson.Clone: TClonableObject;
var
  P: TPerson;
begin
  P := TPerson.Create;
  P.Assign(Self);
  Result := P;
end;

constructor TPerson.Create;
begin
  FEmpty := True;
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
  FID := DS.FieldByName('PersonID').AsInteger;
  FName := DS.FieldByName('PersonName').AsString;
  FGroups := DS.FieldByName('RelatedGroups').AsString;
  FBirthDay := DS.FieldByName('BirthDate').AsDateTime;
  FPhone := DS.FieldByName('PersonPhone').AsString;
  FAddress := DS.FieldByName('PersonAddress').AsString;
  FCompany := DS.FieldByName('Company').AsString;
  FJobTitle := DS.FieldByName('JobTitle').AsString;
  FIMNumber := DS.FieldByName('IMNumber').AsString;
  FEmail := DS.FieldByName('PersonEmail').AsString;
  FSex := DS.FieldByName('PersonSex').AsInteger;
  FComment := DS.FieldByName('PersonComment').AsString;
  FCreateDate := DS.FieldByName('CreateDate').AsDateTime;
  F(FImage);
  FImage := TJpegImage.Create;
  FImage.Assign(DS.FieldByName('PersonImage'));
  FEmpty := False;
end;

procedure TPerson.SaveToDS(DS: TDataSet);
begin
  raise Exception.Create('Not implemented');
end;

procedure TPerson.SetImage(const Value: TJpegImage);
begin
  F(FImage);
  if Value <> nil then
  begin
    FImage := TJpegImage.Create;
    FImage.Assign(Value);
  end;
end;

{ TPersonManager }

function TPersonManager.AddPersonForPhoto(PersonArea: TPersonArea): Boolean;
var
  IC: TInsertCommand;
begin
  Result := False;

  IC := TInsertCommand.Create(PersonMappingTableName);
  try
    IC.AddParameter(TIntegerParameter.Create('PersonID', PersonArea.PersonID));
    IC.AddParameter(TIntegerParameter.Create('Left', PersonArea.X));
    IC.AddParameter(TIntegerParameter.Create('Top', PersonArea.Y));
    IC.AddParameter(TIntegerParameter.Create('Right', PersonArea.X + PersonArea.Width));
    IC.AddParameter(TIntegerParameter.Create('Bottom', PersonArea.Y + PersonArea.Height));
    IC.AddParameter(TIntegerParameter.Create('ImageWidth', PersonArea.FullWidth));
    IC.AddParameter(TIntegerParameter.Create('ImageHeight', PersonArea.FullHeight));
    IC.AddParameter(TIntegerParameter.Create('PageNumber', PersonArea.Page));
    IC.AddParameter(TIntegerParameter.Create('ImageID', PersonArea.ImageID));
    try
      PersonArea.ID := IC.Execute;

      MarkLatestPerson(PersonArea.PersonID);
      Result := True;
    except
      Exit;
    end;
  finally
    F(IC);
  end;
end;

function TPersonManager.ChangePerson(PersonArea: TPersonArea;
  ToPersonID: Integer): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;
  UC := TUpdateCommand.Create(PersonMappingTableName);
  try
    UC.AddParameter(TIntegerParameter.Create('PersonID', ToPersonID));
    UC.AddWhereParameter(TIntegerParameter.Create('PersonMappingID', PersonArea.ID));
    try
      UC.Execute;
      PersonArea.FPersonID := ToPersonID;

      MarkLatestPerson(ToPersonID);

      Result := True;
    except
      Exit;
    end;
  finally
    F(UC);
  end;
end;

constructor TPersonManager.Create;
begin
  FPeoples := nil;
  FSync := TCriticalSection.Create;
end;

function TPersonManager.CreateNewPerson(Person: TPerson): Boolean;
var
  IC: TInsertCommand;
begin
  Result := False;

  IC := TInsertCommand.Create(PersonTableName);
  try
    IC.AddParameter(TStringParameter.Create('PersonName', Person.Name));
    IC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    IC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    IC.AddParameter(TStringParameter.Create('PersonPhone', Person.Phone));
    IC.AddParameter(TStringParameter.Create('PersonAddress', Person.Address));
    IC.AddParameter(TStringParameter.Create('Company', Person.Company));
    IC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    IC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    IC.AddParameter(TStringParameter.Create('PersonEmail', Person.Email));
    IC.AddParameter(TIntegerParameter.Create('PersonSex', Person.Sex));
    IC.AddParameter(TStringParameter.Create('PersonComment', Person.Comment));
    IC.AddParameter(TJpegParameter.Create('PersonImage', Person.Image));
    IC.AddParameter(TDateTimeParameter.Create('CreateDate', Now));

    try
      Person.ID := IC.Execute;
      AllPersons.Add(Person);

    except
      Exit;
    end;

    Result := True;
  finally
    F(IC);
  end;
end;

function TPersonManager.DeletePerson(PersonID: Integer): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;
  DC := TDeleteCommand.Create(PersonTableName);
  try
    DC.AddWhereParameter(TIntegerParameter.Create('PersonId', PersonID));
    try
      DC.Execute;

      AllPersons.RemoveByID(PersonID);
    except
      Exit;
    end;

    Result := True;
  finally
    F(DC);
  end;
end;

function TPersonManager.DeletePerson(PersonName: string): Boolean;
var
  P: TPerson;
begin
  Result := False;
  P := GetPersonByName(PersonName);
  try
    if P <> nil then
      Result := DeletePerson(P.ID);
  finally
    F(P);
  end;
end;

destructor TPersonManager.Destroy;
begin
  F(FPeoples);
  F(FSync);
  inherited;
end;

procedure TPersonManager.FillLatestSelections(Persons: TPersonCollection);
var
  I, Count, PersonID: Integer;
  P: TPerson;
begin

  Persons.Clear;

  Count := Settings.ReadInteger('FaceDetection', 'LatestCount', 0);
  for I := 1 to Count do
  begin
    PersonID := Settings.ReadInteger('FaceDetection\LatestPersons', 'Person' + IntToStr(I), 0);
    if PersonID <> 0 then
    begin
      P := FindPerson(PersonID);
      if P <> nil then
        Persons.Add(P);
    end;
  end;
end;

function TPersonManager.FindPerson(PersonName: string): TPerson;
begin
  Result := AllPersons.GetPersonByName(PersonName);
end;

function TPersonManager.FindPerson(PersonID: Integer): TPerson;
begin
  Result := AllPersons.GetPersonByID(PersonID);
end;

function TPersonManager.GetAllPersons: TPersonCollection;
begin
  FSync.Enter;
  try
    if FPeoples = nil then
    begin
      FPeoples := TPersonCollection.Create;
      LoadPersonList(FPeoples);
    end;
    Result := FPeoples;
  finally
    FSync.Leave;
  end;
end;

function TPersonManager.GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonAreaCollection.Create;
  SC := TSelectCommand.Create(PersonMappingTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    try
      SC.Execute;
      Result.ReadFromDS(SC.DS);
    except
      Exit;
    end;
  finally
    F(SC);
  end;
end;

function TPersonManager.GetPerson(PersonID: Integer): TPerson;
var
  SC: TSelectCommand;
begin
  Result := TPerson.Create;
  SC := TSelectCommand.Create(PersonTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('PersonID', PersonID));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
      begin
        SC.DS.First;
        Result.ReadFromDS(SC.DS);
      end;
    except
      Exit;
    end;
  finally
    F(SC);
  end;
end;

function TPersonManager.GetPersonByName(PersonName: string): TPerson;
var
  SC: TSelectCommand;
begin
  Result := TPerson.Create;
  SC := TSelectCommand.Create(PersonTableName, True);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TStringParameter.Create('PersonName', PersonName));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
      begin
        SC.DS.First;
        Result.ReadFromDS(SC.DS);
      end;
    except
      Exit;
    end;
  finally
    F(SC);
  end;
end;

function TPersonManager.GetPersonsOnImage(ImageID: Integer): TPersonCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonCollection.Create;
  SC := TSelectCommand.Create(PersonTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    try
      SC.Execute;
      Result.ReadFromDS(SC.DS);
    except
      Exit;
    end;
  finally
    F(SC);
  end;
end;

procedure TPersonManager.InitDB;
begin
  if not CheckPersonTables(DatabaseManager.DBFile) then
  begin
    ADOCreatePersonsTable(DatabaseManager.DBFile);
    ADOCreatePersonMappingTable(DatabaseManager.DBFile);
  end;
end;

procedure TPersonManager.LoadPersonList(Persons: TPersonCollection);
var
  SC: TSelectCommand;
begin
  SC := TSelectCommand.Create(PersonTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.Execute;
    Persons.ReadFromDS(SC.DS);
  finally
    F(SC);
  end;
end;

procedure TPersonManager.MarkLatestPerson(PersonID: Integer);
var
  I, Count, MaxCount, ItemCount, ID: Integer;
  List: TList;
begin
  List := TList.Create;
  try
    Count := Settings.ReadInteger('FaceDetection', 'LatestCount', 0);
    for I := 1 to Count do
    begin
      ID := Settings.ReadInteger('FaceDetection\LatestPersons', 'Person' + IntToStr(I), 0);
      if ID > 0 then
        List.Add(Pointer(ID));
    end;

    for I := 0 to List.Count - 1 do
      if Integer(List[I]) = PersonID then
      begin
        List.Delete(I);
        Break;
      end;

    List.Insert(0, Pointer(PersonID));

    MaxCount := Settings.ReadInteger('FaceDetection', 'LatestMaxCount', 10);

    ItemCount := Min(List.Count, MaxCount);
    Settings.WriteInteger('FaceDetection', 'LatestCount', ItemCount);
    for I := 0 to ItemCount - 1 do
      Settings.WriteInteger('FaceDetection\LatestPersons', 'Person' + IntToStr(I + 1), Integer(List[I]));
  finally
    F(List);
  end;
end;

function TPersonManager.RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;
  DC := TDeleteCommand.Create(PersonMappingTableName);
  try
    DC.AddParameter(TAllParameter.Create);
    DC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    DC.AddWhereParameter(TIntegerParameter.Create('PersonMappingID', PersonArea.ID));
    try
      DC.Execute;

      Result := True;
    except
      Exit;
    end;
  finally
    F(DC);
  end;
end;

function TPersonManager.RenamePerson(PersonName, NewName: string): Boolean;
var
  P, PTest: TPerson;
  UC: TUpdateCommand;
begin
  Result := False;
  FSync.Enter;
  try
    P := FindPerson(PersonName);
    if P <> nil then
    begin
      PTest := GetPersonByName(NewName);
      try
        if PTest.Empty then
        begin
          UC := TUpdateCommand.Create(PersonTableName);
          try
            UC.AddParameter(TStringParameter.Create('PersonName', NewName));
            UC.AddWhereParameter(TIntegerParameter.Create('PersonID', P.ID));
            UC.Execute;
            Result := True;
            P.Name := NewName;
          finally
            F(UC);
          end;
        end;
      finally
        F(PTest);
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPersonManager.UpdatePerson(Person: TPerson; UpdateImage: Boolean): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;

  UC := TUpdateCommand.Create(PersonTableName);
  try
    UC.AddParameter(TStringParameter.Create('PersonName', Person.Name));
    UC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    UC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    UC.AddParameter(TStringParameter.Create('PersonPhone', Person.Phone));
    UC.AddParameter(TStringParameter.Create('PersonAddress', Person.Address));
    UC.AddParameter(TStringParameter.Create('Company', Person.Company));
    UC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    UC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    UC.AddParameter(TStringParameter.Create('PersonEmail', Person.Email));
    UC.AddParameter(TIntegerParameter.Create('PersonSex', Person.Sex));
    UC.AddParameter(TStringParameter.Create('PersonComment', Person.Comment));
    if UpdateImage then
      UC.AddParameter(TJpegParameter.Create('PersonImage', Person.Image));

    UC.AddWhereParameter(TIntegerParameter.Create('PersonID', Person.ID));
    try
      UC.Execute;
    except
      Exit;
    end;

    Result := True;
  finally
    F(UC);
  end;
end;

{ TPersonCollection }

procedure TPersonCollection.Add(Person: TPerson);
begin
  if FFreeCollectionItems then
    FList.Add(Person.Clone)
  else
    FList.Add(Person);
end;

procedure TPersonCollection.Clear;
begin
  if FFreeCollectionItems then
    FreeList(FList, False)
  else
    FList.Clear;
end;

constructor TPersonCollection.Create(FreeCollectionItems: Boolean = True);
begin
  FFreeCollectionItems := FreeCollectionItems;
  FList := TList.Create;
end;

procedure TPersonCollection.DeleteAt(I: Integer);
begin
  if FFreeCollectionItems then
    TObject(FList[I]).Free;

  FList.Delete(I);
end;

destructor TPersonCollection.Destroy;
begin
  if FFreeCollectionItems then
    FreeList(FList)
  else
    F(FList);
  inherited;
end;

function TPersonCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPersonCollection.GetPersonByID(ID: Integer): TPerson;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].ID = ID then
    begin
      Result := Items[I];
      Exit;
    end;
end;

function TPersonCollection.GetPersonByIndex(Index: Integer): TPerson;
begin
  Result := FList[Index];
end;

function TPersonCollection.GetPersonByName(PersonName: string): TPerson;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].Name = PersonName then
    begin
      Result := Items[I];
      Exit;
    end;
end;

procedure TPersonCollection.ReadFromDS(DS: TDataSet);
var
  I: Integer;
  P: TPerson;
begin
  Clear;

  for I := 0 to DS.RecordCount - 1 do
  begin
    if I = 0 then
      DS.First;
    P := TPerson.Create;
    FList.Add(P);
    P.ReadFromDS(DS);
    DS.Next;
  end;
end;

procedure TPersonCollection.RemoveByID(PersonID: Integer);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if Items[I].ID = PersonID then
    begin
      DeleteAt(I);
      Exit;
    end;
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

function TPersonAreaCollection.Extract(Index: Integer): TPersonArea;
begin
  Result := FList[Index];
  FList.Delete(Index);
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
var
  I: Integer;
  PA: TPersonArea;
begin
  Clear;

  for I := 0 to DS.RecordCount - 1 do
  begin
    if I = 0 then
      DS.First;
    PA := TPersonArea.Create;
    FList.Add(PA);
    PA.ReadFromDS(DS);
    DS.Next;
  end;
end;

{ TPersonArea }

function TPersonArea.Clone: TClonableObject;
var
  P: TPersonArea;
begin
  P := TPersonArea.Create;
  P.ID := ID;
  P.FX := X;
  P.FY := Y;
  P.FWidth := Width;
  P.FHeight := Height;
  P.FFullWidth := FullWidth;
  P.FFullHeight := FullHeight;
  P.FImageID := ImageID;
  P.FPersonID := PersonID;
  P.FPage := Page;

  Result := P;
end;

constructor TPersonArea.Create(ImageID, PersonID: Integer;
  Area: TFaceDetectionResultItem);
begin
  Create;
  FID := 0;

  if Area <> nil then
  begin
    FX := Area.X;
    FY := Area.Y;
    FWidth := Area.Width;
    FHeight := Area.Height;
    FFullWidth := Area.ImageWidth;
    FFullHeight := Area.ImageHeight;
    FPage := Area.Page;
  end;

  FImageID := ImageID;
  FPersonID := PersonID;
end;

constructor TPersonArea.Create;
begin
end;

procedure TPersonArea.ReadFromDS(DS: TDataSet);
begin
  FID := DS.FieldByName('PersonMappingID').AsInteger;
  FX := DS.FieldByName('Left').AsInteger;
  FY := DS.FieldByName('Top').AsInteger;
  FWidth := DS.FieldByName('Right').AsInteger - FX;
  FHeight := DS.FieldByName('Bottom').AsInteger - FY;
  FFullWidth := DS.FieldByName('ImageWidth').AsInteger;
  FFullHeight := DS.FieldByName('ImageHeight').AsInteger;
  FImageID := DS.FieldByName('ImageID').AsInteger;
  FPersonID := DS.FieldByName('PersonID').AsInteger;
  FPage := DS.FieldByName('PageNumber').AsInteger;
end;

procedure TPersonArea.SaveToDS(DS: TDataSet);
begin
  raise Exception.Create('Not implemented');
end;

initialization

finalization
  F(FManager);

end.
