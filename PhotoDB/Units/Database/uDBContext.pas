unit uDBContext;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.System,

  UnitINI,

  uConstants,
  uDBForm,
  uSettings,
  uDBConnection,
  uDBClasses,
  uDBScheme,
  uDBEntities;

type
  IMediaRepository = interface
    function GetIdByFileName(FileName: string): Integer;
    function GetFileNameById(ID: Integer): string;
    procedure SetFileNameById(ID: Integer; FileName: string);
    procedure SetAccess(ID, Access: Integer);
    procedure SetRotate(ID, Rotate: Integer);
    procedure SetRating(ID, Rating: Integer);
    procedure SetAttribute(ID, Attribute: Integer);
    function GetCount: Integer;
    function GetMenuItemByID(ID: Integer): TMediaItem;
    function GetMenuItemsByID(ID: Integer): TMediaItemCollection;
    function GetMenuInfosByUniqId(UniqId: string): TMediaItemCollection;
    procedure UpdateMediaInfosFromDB(Info: TMediaItemCollection);
    function UpdateMediaFromDB(Media: TMediaItem; LoadThumbnail: Boolean): Boolean;
    procedure IncMediaCounter(ID: Integer);
    procedure RefreshImagesCache;
  end;

  IGroupsRepository = interface
    function GetAll(LoadImages: Boolean; SortByName: Boolean; UseInclude: Boolean = False): TGroups;
    function Add(Group: TGroup): Boolean;
    function Update(Group: TGroup): Boolean;
    function Delete(Group: TGroup): Boolean;

    function GetByCode(GroupCode: string; LoadImage: Boolean): TGroup;
    function GetByName(GroupName: string; LoadImage: Boolean): TGroup;
    function FindCodeByName(GroupName: string): string;
    function FindNameByCode(GroupCode: string): string;
    function HasGroupWithCode(GroupCode: string): Boolean;
    function HasGroupWithName(GroupName: string): Boolean;
  end;

const
  PERSON_TYPE = 1;

type
  TPersonFoundCallBack = reference to procedure(P: TPerson; var StopOperation: Boolean);

  IPeopleRepository = interface
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
  end;

  ISettingsRepository = interface
    function Get: TSettings;
    function Update(Options: TSettings): Boolean;
  end;

  IDBContext = interface
    function IsValid: Boolean;
    function GetCollectionFileName: string;
    property CollectionFileName: string read GetCollectionFileName;

    //low-level
    function CreateQuery(IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;

    //middle-level
    function CreateSelect(TableName: string): TSelectCommand;
    function CreateUpdate(TableName: string; Background: Boolean = False): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //repositories
    function Settings: ISettingsRepository;
    function Groups: IGroupsRepository;
    function People: IPeopleRepository;
    function Media: IMediaRepository;
  end;

  TBaseRepository<T: TBaseEntity> = class(TInterfacedObject)
  private
    FContext: IDBContext;
  public
    constructor Create(Context: IDBContext); virtual;
    property Context: IDBContext read FContext;
  end;

  TDBContext = class(TInterfacedObject, IDBContext)
  private
    FCollectionFile: string;
    FIsValid: Boolean;
    function InitCollection: Boolean;
  public
    //function CreateSelect: TSelectCommand;
    constructor Create(CollectionFile: string);

    function IsValid: Boolean;
    function GetCollectionFileName: string;

    //low-level
    function CreateQuery(IsolationLevel: TDBIsolationLevel = dbilReadWrite): TDataSet;

    //middle-level
    function CreateSelect(TableName: string): TSelectCommand;
    function CreateUpdate(TableName: string; Background: Boolean = False): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //todo: high-level
    //repositories
    function Settings: ISettingsRepository;
    function Groups: IGroupsRepository;
    function People: IPeopleRepository;
    function Media: IMediaRepository;
  end;

implementation

uses
  uMediaRepository,
  uGroupsRepository,
  uPeopleRepository,
  uSettingsRepository;

{ TDBContext }

constructor TDBContext.Create(CollectionFile: string);
begin
  FCollectionFile := CollectionFile;
  FIsValid := InitCollection;
end;

function TDBContext.InitCollection: Boolean;
var
  Section: TBDRegistry;
  Version: Integer;
begin
  Result := False;
  Section := uSettings.AppSettings.GetSection(RegRoot + 'CollectionSettings\' + IntToHex(Integer(StringCRC(FCollectionFile)), 8) + '_' + ProductVersion, False);

  Version := Section.ReadInteger('Version');
  if Version < CURRENT_DB_SCHEME_VERSION then
  begin
    if TDBScheme.IsOldColectionFile(FCollectionFile) then
      TDBScheme.UpdateCollection(FCollectionFile, Version, True);

    if TDBScheme.IsValidCollectionFile(FCollectionFile) then
      Result := True;

    if Result then
      Section.WriteInteger('Version', CURRENT_DB_SCHEME_VERSION);
  end else
    Result := True;
end;

function TDBContext.IsValid: Boolean;
begin
  Result := FIsValid;
end;

function TDBContext.Media: IMediaRepository;
begin
  Result := TMediaRepository.Create(Self);
end;

function TDBContext.People: IPeopleRepository;
begin
  Result := TPeopleRepository.Create(Self);
end;

function TDBContext.GetCollectionFileName: string;
begin
  Result := FCollectionFile;
end;

function TDBContext.Settings: ISettingsRepository;
begin
  Result := TSettingsRepository.Create(Self);
end;

function TDBContext.Groups: IGroupsRepository;
begin
  Result := TGroupsRepository.Create(Self);
end;

function TDBContext.CreateQuery(IsolationLevel: TDBIsolationLevel): TDataSet;
begin
  Result := GetQuery(FCollectionFile, False, IsolationLevel);
end;

function TDBContext.CreateInsert(TableName: string): TInsertCommand;
begin
  Result := TInsertCommand.Create(TableName, FCollectionFile);
end;

function TDBContext.CreateSelect(TableName: string): TSelectCommand;
begin
  Result := TSelectCommand.Create(TableName, FCollectionFile, False, dbilRead);
end;

function TDBContext.CreateUpdate(TableName: string; Background: Boolean = False): TUpdateCommand;
const
  Isolations: array[Boolean] of TDBIsolationLevel = (dbilReadWrite, dbilBackgroundWrite);
begin
  Result := TUpdateCommand.Create(TableName, FCollectionFile, Isolations[Background]);
end;

function TDBContext.CreateDelete(TableName: string): TDeleteCommand;
begin
  Result := TDeleteCommand.Create(TableName, FCollectionFile);
end;

{ TBaseRepository<T> }

constructor TBaseRepository<T>.Create(Context: IDBContext);
begin
  FContext := Context;
end;

end.
