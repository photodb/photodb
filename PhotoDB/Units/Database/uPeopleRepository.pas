unit uPeopleRepository;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Math,
  Winapi.Windows,
  Data.DB,
  Vcl.Graphics,
  Vcl.Imaging.jpeg,

  Dmitry.Utils.System,

  UnitDBKernel,
  UnitDBDeclare,
  CmpUnit,

  uMemory,
  uStringUtils,
  uDBClasses,
  uDBContext,
  uDBEntities,
  uGUIDUtils,
  uFaceDetection,
  uSettings,
  uDBForm,
  uConstants,
  uLogger,
  uBitmapUtils,
  uTranslate,
  uProgramStatInfo,
  uCollectionEvents,
  uShellIntegration;

type
  TPeopleRepository = class(TInterfacedObject, IPeopleRepository)
  class var
    FIsInitialized: Boolean;
    FPeoples: TPersonCollection;
    FSync: TCriticalSection;
  private
    FDBContext: IDBContext;
  public
    class procedure ClearCache;
    class constructor Create;
    class destructor Destroy;
    class function AllPersons(Repository: IPeopleRepository): TPersonCollection;

    procedure LoadPersonList(Persons: TPersonCollection);
    procedure LoadTopPersons(CallBack: TPersonFoundCallBack);
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
    function GetPersonsByNames(Persons: TStringList): TPersonCollection;
    function GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
    function AddPersonForPhoto(Sender: TDBForm; PersonArea: TPersonArea): Boolean;
    function RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
    function ChangePerson(PersonArea: TPersonArea; ToPersonID: Integer): Boolean;
    procedure FillLatestSelections(Persons: TPersonCollection);
    procedure MarkLatestPerson(PersonID: Integer);
    function UpdatePersonArea(PersonArea: TPersonArea): Boolean;
    function UpdatePersonAreaCollection(PersonAreas: TPersonAreaCollection): Boolean;
    constructor Create(Context: IDBContext);
    destructor Destroy; override;
  end;

implementation

procedure InternalHandleError(Ex: Exception);
begin
  EventLog(Ex);
  MessageBoxDB(0, Ex.Message, TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

{ TPeopleRepository }

class procedure TPeopleRepository.ClearCache;
begin
  FSync.Enter;
  try
    FIsInitialized := False;
    F(FPeoples);
  finally
    FSync.Leave;
  end;
end;

class function TPeopleRepository.AllPersons(Repository: IPeopleRepository): TPersonCollection;
begin
  if FPeoples = nil then
  begin
    FPeoples := TPersonCollection.Create;
    Repository.LoadPersonList(FPeoples);
  end;
  Result := FPeoples;
end;

class constructor TPeopleRepository.Create;
begin
  FPeoples := nil;
  FIsInitialized := False;
  FSync := TCriticalSection.Create;
end;

class destructor TPeopleRepository.Destroy;
begin
  F(FPeoples);
  F(FSync);
end;

constructor TPeopleRepository.Create(Context: IDBContext);
begin
  FDBContext := Context;
end;

destructor TPeopleRepository.Destroy;
begin
  FDBContext := nil;
  inherited;
end;

function TPeopleRepository.AddPersonForPhoto(Sender: TDBForm; PersonArea: TPersonArea): Boolean;
var
  P: TPerson;
  IC: TInsertCommand;
  SC: TSelectCommand;
  UC: TUpdateCommand;
  GroupRepository: IGroupsRepository;
  Groups, Keywords: string;
  GS: TGroups;
  G: TGroup;
  Values: TEventValues;
  I: Integer;
begin
  Result := False;

  //statistics
  ProgramStatistics.FaceDetectionUsed;

  P := TPerson.Create;
  try
    FindPerson(PersonArea.PersonID, P);
    if P.Empty then
      Exit;

    IC := FDBContext.CreateInsert(ObjectMappingTableName);
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
          SC := FDBContext.CreateSelect(ImageTable);
          try
            SC.AddParameter(TStringParameter.Create('Groups'));
            SC.AddParameter(TStringParameter.Create('Keywords'));
            SC.AddWhereParameter(TIntegerParameter.Create('ID', PersonArea.ImageID));
            if SC.Execute > 0 then
            begin
              Groups := SC.DS.FieldByName('Groups').AsString;
              Keywords := SC.DS.FieldByName('Keywords').AsString;
              TGroups.AddGroupsToGroups(Groups, P.Groups);

              GroupRepository := FDBContext.Groups;
              GS := TGroups.CreateFromString(P.Groups);
              try
                for I := 0 to GS.Count - 1 do
                begin
                  G := GroupRepository.GetByName(GS[I].GroupName, False);
                  AddWordsA(G.GroupKeyWords, KeyWords);
                end;
              finally
                F(GS);
              end;
              AddWordsA(P.Name, KeyWords);

              UC := FDBContext.CreateUpdate(ImageTable);
              try
                UC.AddParameter(TStringParameter.Create('Groups', Groups));
                UC.AddParameter(TStringParameter.Create('Keywords', Keywords));
                UC.AddWhereParameter(TIntegerParameter.Create('ID', PersonArea.ImageID));
                UC.Execute;

                Values.Groups := Groups;
                Values.Keywords := Keywords;
                CollectionEvents.DoIDEvent(Sender, PersonArea.ImageID, [EventID_Param_Groups, EventID_Param_KeyWords], Values);

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
        on E: Exception do
        begin
          InternalHandleError(E);
          Exit;
        end;
      end;
    finally
      F(IC);
    end;
  finally
    F(P);
  end;
end;

function TPeopleRepository.ChangePerson(PersonArea: TPersonArea;
  ToPersonID: Integer): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;

  //statistics
  ProgramStatistics.FaceDetectionUsed;

  UC := FDBContext.CreateUpdate(ObjectMappingTableName);
  try
    UC.AddParameter(TIntegerParameter.Create('ObjectID', ToPersonID));
    UC.AddWhereParameter(TIntegerParameter.Create('ObjectMappingID', PersonArea.ID));
    try
      UC.Execute;
      PersonArea.PersonID := ToPersonID;

      MarkLatestPerson(ToPersonID);

      Result := True;
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(UC);
  end;
end;

function TPeopleRepository.CreateNewPerson(Person: TPerson): Integer;
var
  IC: TInsertCommand;
begin
  Result := 0;

  IC := FDBContext.CreateInsert(ObjectTableName);
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
        AllPersons(Self).Add(Person);
      finally
        FSync.Leave;
      end;

    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;

    Result := Person.ID;
  finally
    F(IC);
  end;
end;

function TPeopleRepository.DeletePerson(PersonID: Integer): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;

  DC := FDBContext.CreateDelete(ObjectTableName);
  try
    DC.AddWhereParameter(TIntegerParameter.Create('ObjectId', PersonID));
    DC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      DC.Execute;

      FSync.Enter;
      try
        AllPersons(Self).RemoveByID(PersonID);
      finally
        FSync.Leave;
      end;
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;

    Result := True;
  finally
    F(DC);
  end;
end;

function TPeopleRepository.DeletePerson(PersonName: string): Boolean;
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

procedure TPeopleRepository.FillLatestSelections(Persons: TPersonCollection);
var
  I, Count, PersonID: Integer;
  P: TPerson;
  Key: string;
begin
  Key := FormatEx('FaceDetection\{0}', [ExtractFileName(FDBContext.CollectionFileName)]);

  Persons.Clear;

  Count := AppSettings.ReadInteger(Key, 'LatestCount', 0);
  for I := 1 to Count do
  begin
    PersonID := AppSettings.ReadInteger(Key + '\LatestPersons', 'Person' + IntToStr(I), 0);
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

function TPeopleRepository.FindPerson(PersonName: string; Person: TPerson): Boolean;
var
  P: TPerson;
begin
  Result := False;
  FSync.Enter;
  try
    P := AllPersons(Self).GetPersonByName(PersonName);
    if P <> nil then
    begin
      Person.Assign(P);
      Result := True;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPeopleRepository.FindPerson(PersonID: Integer; Person: TPerson): Boolean;
var
  P: TPerson;
begin
  Result := False;
  FSync.Enter;
  try
    P := AllPersons(Self).GetPersonByID(PersonID);
    if P <> nil then
    begin
      Person.Assign(P);
      Result := True;
    end;
  finally
    FSync.Leave;
  end;
end;

function TPeopleRepository.GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonAreaCollection.Create;
  SC := FDBContext.CreateSelect(ObjectMappingTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    try
      SC.Execute;
      Result.ReadFromDS(SC.DS);
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(SC);
  end;
end;

function TPeopleRepository.GetPerson(PersonID: Integer): TPerson;
var
  SC: TSelectCommand;
begin
  Result := TPerson.Create;
  SC := FDBContext.CreateSelect(ObjectTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectID', PersonID));
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
        Result.ReadFromDS(SC.DS);
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(SC);
  end;
end;

function TPeopleRepository.GetPersonByName(PersonName: string): TPerson;
var
  SC: TSelectCommand;
begin
  Result := TPerson.Create;
  SC := FDBContext.CreateSelect(ObjectTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TStringParameter.Create('ObjectName', PersonName));
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      SC.Execute;
      if SC.RecordCount > 0 then
        Result.ReadFromDS(SC.DS);
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(SC);
  end;
end;

function TPeopleRepository.GetPersonsByNames(Persons: TStringList): TPersonCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonCollection.Create;
  SC := FDBContext.CreateSelect(ObjectTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('trim(ObjectName) in ({0})', [Persons.Join(',')])));
    SC.AddWhereParameter(TIntegerParameter.Create('ObjectType', PERSON_TYPE));
    try
      SC.Execute;
      Result.ReadFromDS(SC.DS);
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(SC);
  end;
end;

function TPeopleRepository.GetPersonsOnImage(ImageID: Integer): TPersonCollection;
var
  SC: TSelectCommand;
begin
  Result := TPersonCollection.Create;
  SC := FDBContext.CreateSelect(ObjectTableName);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ImageID', ImageID));
    try
      SC.Execute;
      Result.ReadFromDS(SC.DS);
    except
      on E: Exception do
      begin
        InternalHandleError(E);
        Exit;
      end;
    end;
  finally
    F(SC);
  end;
end;

procedure TPeopleRepository.LoadPersonList(Persons: TPersonCollection);
var
  SC: TSelectCommand;
begin
  try
    SC := FDBContext.CreateSelect(ObjectTableName);
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

procedure TPeopleRepository.LoadTopPersons(CallBack: TPersonFoundCallBack);
var
  SC: TSelectCommand;
  SQL: string;
  P: TPerson;
  StopOperation: Boolean;
begin
  SC := FDBContext.CreateSelect(ObjectTableName);
  try

    SQL := 'SELECT * FROM ( ' +
            'SELECT First(O.[ObjectID]) as [ObjectID], First(O.[ObjectName]) as [ObjectName], First(O.[RelatedGroups]) as [RelatedGroups], First(O.[BirthDate]) as [BirthDate], ' +
            ' First(O.[Phone]) as [Phone], First(O.[Address]) as [Address], First(O.[Company]) as [Company], First(O.[JobTitle]) as [JobTitle], First(O.[IMNumber]) as [IMNumber], ' +
            ' First(O.[Email]) as [Email], First(O.[Sex]) as [Sex], First([O.ObjectComment]) as [ObjectComment], First(O.[CreateDate]) as [CreateDate], First(O.ObjectUniqID) as ObjectUniqID, First(O.Image) as [Image], ' +
            ' Count(1) AS ObjectsCount FROM Objects O ' +
            'INNER JOIN ObjectMapping OM on O.ObjectID = OM.ObjectID ' +
            'GROUP BY O.[ObjectID] ' +
          ') ORDER BY [ObjectsCount] DESC ';

    if SC.ExecuteSQL(SQL, True) > 0 then
    begin
      StopOperation := False;
      while not SC.DS.Eof do
      begin
        P := TPerson.Create;
        P.ReadFromDS(SC.DS);

        CallBack(P, StopOperation);
        if StopOperation then
          Break;

        SC.DS.Next;
      end;
    end;
  finally
    F(SC);
  end;
end;

procedure TPeopleRepository.MarkLatestPerson(PersonID: Integer);
var
  I, Count, MaxCount, ItemCount, ID: Integer;
  List: TList<Integer>;
  Key: string;
begin
  Key := FormatEx('FaceDetection\{0}', [ExtractFileName(FDBContext.CollectionFileName)]);

  List := TList<Integer>.Create;
  try
    Count := AppSettings.ReadInteger(Key, 'LatestCount', 0);
    for I := 1 to Count do
    begin
      ID := AppSettings.ReadInteger(Key + '\LatestPersons', 'Person' + IntToStr(I), 0);
      if ID > 0 then
        List.Add(ID);
    end;

    for I := 0 to List.Count - 1 do
      if List[I] = PersonID then
      begin
        List.Delete(I);
        Break;
      end;

    List.Insert(0, PersonID);

    MaxCount := AppSettings.ReadInteger(Key, 'LatestMaxCount', 10);

    ItemCount := Min(List.Count, MaxCount);
    AppSettings.WriteInteger(Key, 'LatestCount', ItemCount);
    for I := 0 to ItemCount - 1 do
      AppSettings.WriteInteger(Key + '\LatestPersons', 'Person' + IntToStr(I + 1), List[I]);
  finally
    F(List);
  end;
end;

function TPeopleRepository.RemovePersonFromPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;

  //statistics
  ProgramStatistics.FaceDetectionUsed;

  DC := FDBContext.CreateDelete(ObjectMappingTableName);
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

function TPeopleRepository.RenamePerson(PersonName, NewName: string): Boolean;
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
            UC := FDBContext.CreateUpdate(ObjectTableName);
            try
              UC.AddParameter(TStringParameter.Create('ObjectName', NewName));
              UC.AddWhereParameter(TIntegerParameter.Create('ObjectID', P.ID));
              UC.Execute;
              Result := True;

              //update cache
              FSync.Enter;
              try
                CachePerson := AllPersons(Self).GetPersonByID(P.ID);
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

function TPeopleRepository.UpdatePerson(Person: TPerson; UpdateImage: Boolean): Boolean;
var
  UC: TUpdateCommand;
  P: TPerson;
begin
  Result := False;

  UC := FDBContext.CreateUpdate(ObjectTableName);
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
      P := AllPersons(Self).GetPersonByID(Person.ID);
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

function TPeopleRepository.UpdatePersonArea(PersonArea: TPersonArea): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;
  if PersonArea.ID = 0 then
    Exit;

  UC := FDBContext.CreateUpdate(ObjectMappingTableName);
  try
    UC.AddParameter(TIntegerParameter.Create('Left', PersonArea.X));
    UC.AddParameter(TIntegerParameter.Create('Top',  PersonArea.Y));
    UC.AddParameter(TIntegerParameter.Create('Right',  PersonArea.X +  PersonArea.Width));
    UC.AddParameter(TIntegerParameter.Create('Bottom',  PersonArea.Y +  PersonArea.Height));
    UC.AddParameter(TIntegerParameter.Create('ImageWidth',  PersonArea.FullWidth));
    UC.AddParameter(TIntegerParameter.Create('ImageHeight',  PersonArea.FullHeight));
    UC.AddParameter(TIntegerParameter.Create('PageNumber',  PersonArea.Page));

    UC.AddWhereParameter(TIntegerParameter.Create('ObjectMappingID',  PersonArea.ID));

    try
      UC.Execute;
    except
      Exit;
    end;
  finally
    F(UC);
  end;
end;

function TPeopleRepository.UpdatePersonAreaCollection(PersonAreas: TPersonAreaCollection): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to PersonAreas.Count - 1 do
    if not UpdatePersonArea(PersonAreas[I]) then
      Result := False;
end;

end.
