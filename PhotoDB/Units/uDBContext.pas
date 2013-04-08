unit uDBContext;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Data.DB,
  Dmitry.CRC32,

  CommonDBSupport,
  UnitINI,

  uConstants,
  uDBClasses,
  uSettings,
  uDBScheme,
  uDBEntities;

type
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
    function CreateUpdate(TableName: string): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //todo: high-level
    //repositories
    function Settings: ISettingsRepository;
    function Groups: IGroupsRepository;
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
    function CreateUpdate(TableName: string): TUpdateCommand;
    function CreateInsert(TableName: string): TInsertCommand;
    function CreateDelete(TableName: string): TDeleteCommand;

    //todo: high-level
    //repositories
    function Settings: ISettingsRepository;
    function Groups: IGroupsRepository;
  end;

implementation

uses
  uGroupsRepository,
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
  Section := uSettings.AppSettings.GetSection(RegRoot + 'CollectionSettings\' + IntToHex(Integer(StringCRC(FCollectionFile)), 8), False);

  Version := Section.ReadInteger('Version');
  if Version < CURRENT_DB_SCHEME_VERSION then
  begin
    if TDBScheme.IsOldColectionFile(FCollectionFile) then
      TDBScheme.UpdateCollection(FCollectionFile);

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
  Result := GetQuery(FCollectionFile, GetCurrentThreadId <> MainThreadID, IsolationLevel);
end;

function TDBContext.CreateInsert(TableName: string): TInsertCommand;
begin
  Result := TInsertCommand.Create(TableName, FCollectionFile);
end;

function TDBContext.CreateSelect(TableName: string): TSelectCommand;
begin
  Result := TSelectCommand.Create(TableName, FCollectionFile, False, dbilRead);
end;

function TDBContext.CreateUpdate(TableName: string): TUpdateCommand;
begin
  Result := TUpdateCommand.Create(TableName, FCollectionFile);
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
