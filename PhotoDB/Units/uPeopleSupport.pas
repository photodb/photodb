unit uPeopleSupport;

interface

uses
  SysUtils,
  Windows,
  Classes,
  DB,
  Graphics,
  jpeg,
  uMemory,
  SyncObjs,
  uDBClasses,
  uGUIDUtils,
  uFaceDetection,
  uSettings,
  Math,
  uFastLoad,
  UnitDBKernel,
  uDBForm,
  uPersonDB,
  UnitDBDeclare,
  UnitGroupsWork,
  uSysUtils,
  uRuntime,
  uConstants,
  uLogger,
  uBitmapUtils,
  CmpUnit;

const
  PERSON_TYPE = 1;

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
    function FindPerson(PersonID: Integer; Person: TPerson): Boolean; overload;
    function FindPerson(PersonName: string; Person: TPerson): Boolean; overload;
    function GetPerson(PersonID: Integer): TPerson;
    function GetPersonByName(PersonName: string): TPerson;
    function RenamePerson(PersonName, NewName: string): Boolean;
    function CreateNewPerson(Person: TPerson): Integer;
    function DeletePerson(PersonID: Integer): Boolean; overload;
    function DeletePerson(PersonName: string): Boolean; overload;
    function UpdatePerson(Person: TPerson; UpdateImage: Boolean): Boolean;
    function GetPersonsOnImage(ImageID: Integer): TPersonCollection;
    function GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
    function AddPersonForPhoto(Sender: TDBForm; PersonArea: TPersonArea): Boolean;
    function RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
    function ChangePerson(PersonArea: TPersonArea; ToPersonID: Integer): Boolean;
    procedure FillLatestSelections(Persons: TPersonCollection);
    constructor Create;
    destructor Destroy; override;
    procedure RegisterManager;
    procedure Unregister;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer;
                                params: TEventFields; Value: TEventValues);
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
    function GetPersonByID(ID: Integer): TPerson;
    constructor Create(FreeCollectionItems: Boolean = True);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(Person: TPerson);
    procedure ReadFromDS(DS: TDataSet);
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
    FUniqID: string;
    FPreview: TBitmap;
    FPreviewSize: TSize;
    procedure SetImage(const Value: TJpegImage);
    procedure SetID(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function CreatePreview(Width, Height: Integer): TBitmap;
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
    procedure Assign(Source: TPerson);
    function Clone: TClonableObject; override;
    property ID: Integer read FID write SetID;
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
    property UniqID: string read FUniqID write FUniqID;
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
    function UpdateDB: Boolean;
    procedure RotateLeft;
    procedure RotateRight;
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
    procedure RotateLeft;
    procedure RotateRight;
    procedure UpdateDB;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPersonArea read GetAreaByIndex; default;
  end;

function PersonManager: TPersonManager;

procedure UnReigisterPersonManager;

implementation

var
  FManager: TPersonManager = nil;

function PersonManager: TPersonManager;
begin
  if FManager = nil then
    FManager := TPersonManager.Create;

  Result := FManager;
end;

procedure UnReigisterPersonManager;
begin
  if FManager <> nil then
    FManager.Unregister;
end;

{ TPerson }

procedure TPerson.Assign(Source: TPerson);
begin
  FID := Source.ID;
  FName := Source.Name;
  F(FImage);
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
  FEmpty := Source.Empty;
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
  FPreview := nil;
  FPreviewSize.cx := 0;
  FPreviewSize.cy := 0;
end;

function TPerson.CreatePreview(Width, Height: Integer): TBitmap;
var
  B: TBitmap;
  W, H: Integer;
begin
  if (FPreview = nil) or (FPreviewSize.cx <> Width) or (FPreviewSize.cy <> Height) then
  begin
    F(FPreview);
    B := TBitmap.Create;
    try
      B.Assign(FImage);
      W := B.Width;
      H := B.Height;
      ProportionalSizeA(Width, Height, W, H);
      FPreview := TBitmap.Create;
      DoResize(W, H, B, FPreview);
      CenterBitmap24To32ImageList(FPreview, Width);
    finally
      F(B);
    end;
  end;
  Result := FPreview;
end;

destructor TPerson.Destroy;
begin
  F(FImage);
  F(FPreview);
  inherited;
end;

procedure TPerson.ReadFromDS(DS: TDataSet);
begin
  FID := DS.FieldByName('ObjectID').AsInteger;
  FName := Trim(DS.FieldByName('ObjectName').AsString);
  FGroups := DS.FieldByName('RelatedGroups').AsString;
  FBirthDay := DS.FieldByName('BirthDate').AsDateTime;
  FPhone := Trim(DS.FieldByName('Phone').AsString);
  FAddress := Trim(DS.FieldByName('Address').AsString);
  FCompany := Trim(DS.FieldByName('Company').AsString);
  FJobTitle := Trim(DS.FieldByName('JobTitle').AsString);
  FIMNumber := Trim(DS.FieldByName('IMNumber').AsString);
  FEmail := Trim(DS.FieldByName('Email').AsString);
  FSex := DS.FieldByName('Sex').AsInteger;
  FComment := DS.FieldByName('ObjectComment').AsString;
  FCreateDate := DS.FieldByName('CreateDate').AsDateTime;
  FUniqID := Trim(DS.FieldByName('ObjectUniqID').AsString);
  F(FImage);
  FImage := TJpegImage.Create;
  FImage.Assign(DS.FieldByName('Image'));
  FEmpty := False;
end;

procedure TPerson.SaveToDS(DS: TDataSet);
begin
  raise Exception.Create('Not implemented');
end;

procedure TPerson.SetID(const Value: Integer);
begin
  FID := Value;
  FEmpty := False;
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

function TPersonManager.AddPersonForPhoto(Sender: TDBForm; PersonArea: TPersonArea): Boolean;
var
  P: TPerson;
  IC: TInsertCommand;
  SC: TSelectCommand;
  UC: TUpdateCommand;
  Groups, Keywords: string;
  GS: TGroups;
  G: TGroup;
  Values: TEventValues;
  I: Integer;
begin
  Result := False;

  P := TPerson.Create;
  try
    FindPerson(PersonArea.PersonID, P);
    if P.Empty then
      Exit;

    IC := TInsertCommand.Create(ObjectMappingTableName);
    try
      IC.AddParameter(TIntegerParameter.Create('ObjectID', PersonArea.PersonID));
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

        if P.Groups <> '' then
        begin
          SC := TSelectCommand.Create(ImageTable);
          try
            SC.AddParameter(TStringParameter.Create('Groups', ''));
            SC.AddParameter(TStringParameter.Create('Keywords', ''));
            SC.AddWhereParameter(TIntegerParameter.Create('ID', PersonArea.ImageID));
            if SC.Execute > 0 then
            begin
              Groups := SC.DS.FieldByName('Groups').AsString;
              Keywords := SC.DS.FieldByName('Keywords').AsString;
              AddGroupsToGroups(Groups, P.Groups);

              GS := EncodeGroups(P.Groups);
              for I := 0 to Length(GS) - 1 do
              begin
                G := GetGroupByGroupName(GS[I].GroupName, False);
                AddWordsA(G.GroupKeyWords, KeyWords);
              end;
              AddWordsA(P.Name, KeyWords);

              UC := TUpdateCommand.Create(ImageTable);
              try
                UC.AddParameter(TStringParameter.Create('Groups', Groups));
                UC.AddParameter(TStringParameter.Create('Keywords', Keywords));
                UC.AddWhereParameter(TIntegerParameter.Create('ID', PersonArea.ImageID));
                UC.Execute;

                Values.Groups := Groups;
                Values.Keywords := Keywords;
                DBKernel.DoIDEvent(Sender, PersonArea.ImageID, [EventID_Param_Groups, EventID_Param_KeyWords], Values);

              finally
                F(UC);
              end;

            end;
          finally
            F(SC);
          end;
        end;

        MarkLatestPerson(PersonArea.PersonID);
        Result := True;
      except
        Exit;
      end;
    finally
      F(IC);
    end;
  finally
    F(P);
  end;
end;

function TPersonManager.ChangePerson(PersonArea: TPersonArea;
  ToPersonID: Integer): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;
  UC := TUpdateCommand.Create(ObjectMappingTableName);
  try
    UC.AddParameter(TIntegerParameter.Create('ObjectID', ToPersonID));
    UC.AddWhereParameter(TIntegerParameter.Create('ObjectMappingID', PersonArea.ID));
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
  RegisterManager;
end;

function TPersonManager.CreateNewPerson(Person: TPerson): Integer;
var
  IC: TInsertCommand;
begin
  Result := 0;

  IC := TInsertCommand.Create(ObjectTableName);
  try
    IC.AddParameter(TStringParameter.Create('ObjectName', Person.Name));
    IC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    IC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    IC.AddParameter(TStringParameter.Create('Phone', Person.Phone));
    IC.AddParameter(TStringParameter.Create('Address', Person.Address));
    IC.AddParameter(TStringParameter.Create('Company', Person.Company));
    IC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    IC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    IC.AddParameter(TStringParameter.Create('Email', Person.Email));
    IC.AddParameter(TIntegerParameter.Create('Sex', Person.Sex));
    IC.AddParameter(TStringParameter.Create('ObjectComment', Person.Comment));
    IC.AddParameter(TJpegParameter.Create('Image', Person.Image));
    IC.AddParameter(TDateTimeParameter.Create('CreateDate', Now));
    IC.AddParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    IC.AddParameter(TStringParameter.Create('ObjectUniqID', GUIDToString(GetGUID)));

    try
      Person.ID := IC.Execute;
      Result := Person.ID;
      FSync.Enter;
      try
        AllPersons.Add(Person);
      finally
        FSync.Leave;
      end;

    except
      Exit;
    end;

    Result := Person.ID;
  finally
    F(IC);
  end;
end;

function TPersonManager.DeletePerson(PersonID: Integer): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;
  DC := TDeleteCommand.Create(ObjectTableName);
  try
    DC.AddWhereParameter(TIntegerParameter.Create('ObjectId', PersonID));
    DC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      DC.Execute;

      FSync.Enter;
      try
        AllPersons.RemoveByID(PersonID);
      finally
        FSync.Leave;
      end;
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
  Key: string;
begin
  Key := FormatEx('FaceDetection\{0}', [ExtractFileName(dbname)]);

  Persons.Clear;

  Count := Settings.ReadInteger(Key, 'LatestCount', 0);
  for I := 1 to Count do
  begin
    PersonID := Settings.ReadInteger(Key + '\LatestPersons', 'Person' + IntToStr(I), 0);
    if PersonID <> 0 then
    begin
      P := TPerson.Create;
      try
        FindPerson(PersonID, P);
        if not P.Empty then
          Persons.Add(P);
      finally
        F(P);
      end;
    end;
  end;
end;

function TPersonManager.FindPerson(PersonName: string; Person: TPerson): Boolean;
var
  P: TPerson;
begin
  Result := False;
  FSync.Enter;
  try
    P := AllPersons.GetPersonByName(PersonName);
    if P <> nil then
    begin
      Person.Assign(P);
      Result := True;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPersonManager.FindPerson(PersonID: Integer; Person: TPerson): Boolean;
var
  P: TPerson;
begin
  Result := False;
  FSync.Enter;
  try
    P := AllPersons.GetPersonByID(PersonID);
    if P <> nil then
    begin
      Person.Assign(P);
      Result := True;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPersonManager.GetAllPersons: TPersonCollection;
begin
  if FPeoples = nil then
  begin
    FPeoples := TPersonCollection.Create;
    LoadPersonList(FPeoples);
  end;
  Result := FPeoples;
end;

function TPersonManager.GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonAreaCollection.Create;
  SC := TSelectCommand.Create(ObjectMappingTableName);
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
  SC := TSelectCommand.Create(ObjectTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectID', PersonID));
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
        Result.ReadFromDS(SC.DS);
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
  SC := TSelectCommand.Create(ObjectTableName, True);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TStringParameter.Create('ObjectName', PersonName));
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
        Result.ReadFromDS(SC.DS);
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
  SC := TSelectCommand.Create(ObjectTableName);
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
  if not CheckObjectTables(DatabaseManager.DBFile) then
  begin
    ADOCreateObjectsTable(DatabaseManager.DBFile);
    ADOCreateObjectMappingTable(DatabaseManager.DBFile);
  end;
end;

procedure TPersonManager.LoadPersonList(Persons: TPersonCollection);
var
  SC: TSelectCommand;
begin
  try
    SC := TSelectCommand.Create(ObjectTableName);
    try
      SC.AddParameter(TAllParameter.Create);
      SC.Order.Add(TOrderParameter.Create('ObjectName', False));
      SC.Execute;
      Persons.ReadFromDS(SC.DS);
    finally
      F(SC);
    end;
  except
    //if database doesn't have any tables could be exception - ignore it
    on e: Exception do
      EventLog(e);
  end;
end;

procedure TPersonManager.MarkLatestPerson(PersonID: Integer);
var
  I, Count, MaxCount, ItemCount, ID: Integer;
  List: TList;
  Key: string;
begin
  Key := FormatEx('FaceDetection\{0}', [ExtractFileName(dbname)]);

  List := TList.Create;
  try
    Count := Settings.ReadInteger(Key, 'LatestCount', 0);
    for I := 1 to Count do
    begin
      ID := Settings.ReadInteger(Key + '\LatestPersons', 'Person' + IntToStr(I), 0);
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

    MaxCount := Settings.ReadInteger(Key, 'LatestMaxCount', 10);

    ItemCount := Min(List.Count, MaxCount);
    Settings.WriteInteger(Key, 'LatestCount', ItemCount);
    for I := 0 to ItemCount - 1 do
      Settings.WriteInteger(Key + '\LatestPersons', 'Person' + IntToStr(I + 1), Integer(List[I]));
  finally
    F(List);
  end;
end;

function TPersonManager.RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;
  DC := TDeleteCommand.Create(ObjectMappingTableName);
  try
    DC.AddParameter(TAllParameter.Create);
    DC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    DC.AddWhereParameter(TIntegerParameter.Create('ObjectMappingID', PersonArea.ID));
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
  P, PTest, CachePerson: TPerson;
  UC: TUpdateCommand;
begin
  Result := False;
  FSync.Enter;
  try
    P := TPerson.Create;
    try
      FindPerson(PersonName, P);
      if not P.Empty then
      begin
        PTest := GetPersonByName(NewName);
        try
          if PTest.Empty then
          begin
            UC := TUpdateCommand.Create(ObjectTableName);
            try
              UC.AddParameter(TStringParameter.Create('ObjectName', NewName));
              UC.AddWhereParameter(TIntegerParameter.Create('ObjectID', P.ID));
              UC.Execute;
              Result := True;

              //update cache
              FSync.Enter;
              try
                CachePerson := AllPersons.GetPersonByID(P.ID);
                if CachePerson <> nil then
                  CachePerson.Name := NewName;
              finally
                FSync.Leave;
              end;
            finally
              F(UC);
            end;
          end;
        finally
          F(PTest);
        end;
      end;
    finally
      F(P);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TPersonManager.RegisterManager;
begin
  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TPersonManager.Unregister;
begin
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

procedure TPersonManager.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if EventID_Param_DB_Changed in Params then
  begin
    FSync.Enter;
    try
      F(FPeoples);
    finally
      FSync.Leave;
    end;
  end;
end;

function TPersonManager.UpdatePerson(Person: TPerson; UpdateImage: Boolean): Boolean;
var
  UC: TUpdateCommand;
  P: TPerson;
begin
  Result := False;

  UC := TUpdateCommand.Create(ObjectTableName);
  try
    UC.AddParameter(TStringParameter.Create('ObjectName', Person.Name));
    UC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    UC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    UC.AddParameter(TStringParameter.Create('Phone', Person.Phone));
    UC.AddParameter(TStringParameter.Create('Address', Person.Address));
    UC.AddParameter(TStringParameter.Create('Company', Person.Company));
    UC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    UC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    UC.AddParameter(TStringParameter.Create('Email', Person.Email));
    UC.AddParameter(TIntegerParameter.Create('Sex', Person.Sex));
    UC.AddParameter(TStringParameter.Create('ObjectComment', Person.Comment));
    if UpdateImage then
      UC.AddParameter(TJpegParameter.Create('Image', Person.Image));
    if Person.UniqID = '' then
    begin
      Person.UniqID := GUIDToString(GetGUID);
      UC.AddParameter(TStringParameter.Create('ObjectUniqID', Person.UniqID));
    end;

    UC.AddWhereParameter(TIntegerParameter.Create('ObjectID', Person.ID));
    UC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      UC.Execute;
    except
      Exit;
    end;

    //update internal cache
    FSync.Enter;
    try
      P := AllPersons.GetPersonByID(Person.ID);
      if P <> nil then
        P.Assign(Person);
    finally
      FSync.Leave;
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
  if DS.RecordCount > 0 then
    DS.First;
  for I := 0 to DS.RecordCount - 1 do
  begin
    PA := TPersonArea.Create;
    FList.Add(PA);
    PA.ReadFromDS(DS);
    DS.Next;
  end;
end;

procedure TPersonAreaCollection.RotateLeft;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].RotateLeft;
end;

procedure TPersonAreaCollection.RotateRight;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].RotateRight;
end;

procedure TPersonAreaCollection.UpdateDB;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].UpdateDB;
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
  FID := DS.FieldByName('ObjectMappingID').AsInteger;
  FX := DS.FieldByName('Left').AsInteger;
  FY := DS.FieldByName('Top').AsInteger;
  FWidth := DS.FieldByName('Right').AsInteger - FX;
  FHeight := DS.FieldByName('Bottom').AsInteger - FY;
  FFullWidth := DS.FieldByName('ImageWidth').AsInteger;
  FFullHeight := DS.FieldByName('ImageHeight').AsInteger;
  FImageID := DS.FieldByName('ImageID').AsInteger;
  FPersonID := DS.FieldByName('ObjectID').AsInteger;
  FPage := DS.FieldByName('PageNumber').AsInteger;
end;

procedure TPersonArea.RotateLeft;
var
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := FFullWidth;
  NImageW := FFullHeight;

  NW := FHeight;
  NH := FWidth;

  NX := FY;
  NY := FFullWidth - FX - Width;

  FFullWidth := NImageW;
  FFullHeight := NImageH;

  FWidth := NW;
  FHeight := NH;

  FX := NX;
  FY := NY;
end;

procedure TPersonArea.RotateRight;
var
  NW, NH, NImageW, NImageH, NX, NY: Integer;
begin
  NImageH := FFullWidth;
  NImageW := FFullHeight;

  NW := FHeight;
  NH := FWidth;

  NX := FFullHeight - FY - Height;
  NY := FX;

  FFullWidth := NImageW;
  FFullHeight := NImageH;

  FWidth := NW;
  FHeight := NH;

  FX := NX;
  FY := NY;
end;

function TPersonArea.UpdateDB: Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;
  if FID = 0 then
    Exit;

  UC := TUpdateCommand.Create(ObjectMappingTableName);
  try
    UC.AddParameter(TIntegerParameter.Create('Left', FX));
    UC.AddParameter(TIntegerParameter.Create('Top', FY));
    UC.AddParameter(TIntegerParameter.Create('Right', FX + FWidth));
    UC.AddParameter(TIntegerParameter.Create('Bottom', FY + FHeight));
    UC.AddParameter(TIntegerParameter.Create('ImageWidth', FFullWidth));
    UC.AddParameter(TIntegerParameter.Create('ImageHeight', FFullHeight));
    UC.AddParameter(TIntegerParameter.Create('PageNumber', FPage));

    UC.AddWhereParameter(TIntegerParameter.Create('ObjectMappingID', FID));

    try
      UC.Execute;
    except
      Exit;
    end;
  finally
    F(UC);
  end;
end;

initialization

finalization
  F(FManager);

end.
