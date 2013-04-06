unit uDBRepository;

interface

uses
  System.SysUtils,
  Generics.Collections,
  Data.DB,

  uConstants,
  uDBClasses,
  uMemory;

type

  TSimpleEntity = class
  strict private 
    DS: TDataSet;
  protected 
    FUC: TUpdateCommand;
    function GetUC: TUpdateCommand;          
    procedure InitUC; virtual; abstract;     
    function GetTableName: string; virtual; abstract;
    procedure ReadFromQuery(Query: TSqlCommand); virtual;
    function ReadInteger(FieldName: string; Default: Integer = 0): Integer; 
    function ReadString(FieldName: string; Default: string = ''): string;
    property UC: TUpdateCommand read GetUC;
    property TableName: string read GetTableName;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure SaveChanges; 
  end;

  ItemQueries = class;
  TJoinTableSet<T1, T2: TSimpleEntity> = class;
  TDBTable<T: TSimpleEntity> = class;
  TDBQuery<T: TSimpleEntity, constructor> = class;

  TDBItem = class(TSimpleEntity)
  strict private
    FId: Integer;
    FLinks: string;
    procedure SetLinks(const Value: string);
  protected             
    procedure InitUC; override;                           
    function GetTableName: string; override;
    procedure ReadFromQuery(Query: TSqlCommand); override;
  public
    property Id: Integer read FId;
    property Links: string read FLinks write SetLinks;
  end;

  TDBGroupItem = class(TSimpleEntity)

  end;

  TDBFields<T: TSimpleEntity> = class;

  DBItemFields = class sealed
  public
    const Id = 'Id';
    const Links = 'Links';
    const GroupId = 'GroupId';
  end;
  
  DBGroupFields = class sealed
  public
    const GroupId = 'GroupId';
  end;

  TDBRepository = class
  strict private
    FFields: TDBFields<TDBItem>;
    FObjects: TList<TObject>;
  protected
    procedure AddObject(QueryObject: TObject);
    property Fields: TDBFields<TDBItem> read FFields;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TDBQueries<T: TSimpleEntity> = class
  strict private
    FSelectCommand: TSelectCommand;
    FTable: TDBTable<T>;
  protected
    property Table: TDBTable<T> read FTable;
    property SelectCommand: TSelectCommand read FSelectCommand write FSelectCommand;
  public
    constructor Create(Table: TDBTable<T>); virtual;
    destructor Destroy; override;
  end;

  TDBTable<T: TSimpleEntity> = class
  strict private
    FFields: TDBFields<T>;
    FQueries: TDBQueries<TDBItem>;
  protected
    property Fields: TDBFields<T> read FFields;
  public
    function Join<T1: TSimpleEntity>(Table: TDBTable<T1>): TJoinTableSet<T, T1>;
    function SelectItem(): ItemQueries;
    constructor Create(Fields: TDBFields<T>);
    destructor Destroy; override;
  end;

  TJoinTable<T: TSimpleEntity> = class(TDBTable<T>)

  end;

  TJoinTableOn<T1, T2: TSimpleEntity> = class
  public
    function Eq(FiledName: string): TJoinTable<T1>;
  end;

  TJoinTableSet<T1, T2: TSimpleEntity> = class
  public
    function Onn(FiledName: string): TJoinTableOn<T1, T2>;
  end;

  TDBFields<T: TSimpleEntity> = class
  strict private
    FRepository: TDBRepository;
    FFields: TList<string>;
  protected
    property Repository: TDBRepository read FRepository;
    property Fields: TList<string> read FFields;
  public
    constructor Create(Repository: TDBRepository);
    destructor Destroy; override;

    function Add(FieldName: string): TDBFields<T>;
    function SetOf(Fields: array of string): TDBFields<T>;
    function Table(): TDBTable<T>;
  end;

  TDBItemRepository = class(TDBRepository)
  private
  public
    function WithKey: TDBFields<TDBItem>;
    function TextFields: TDBFields<TDBItem>;
    function AllFields: TDBFields<TDBItem>;
  end;

  TDBGroupsRepository = class(TDBRepository)
  public
    function AllFields: TDBFields<TDBGroupItem>;
  end;

  TDBTableQuery<T: TSimpleEntity> = class
  private
    FTable: TDBTable<T>;
  protected
    property Table: TDBTable<T> read FTable;
  public
    constructor Create(Table: TDBTable<T>);
  end;

  TItemFetchCallBack<T> = reference to procedure(Item: T);

  TDBQuery<T: TSimpleEntity, constructor> = class
  private
    FQueries: TDBQueries<TDBItem>;
    function GetSelectCommand: TSelectCommand;
  protected
    property Queries: TDBQueries<TDBItem> read FQueries;
    property SC: TSelectCommand read GetSelectCommand;
  public
    constructor Create(Queries: TDBQueries<TDBItem>);
    destructor Destroy; override;
    function OrderBy(FieldName: string): TDBQuery<T>;
    function OrderByDesc(FieldName: string): TDBQuery<T>;
    function FirstOrDefault(): T;
    function ToList(): TList<T>;
    procedure Fetch(OnItem: TItemFetchCallBack<T>);
  end;

  ItemQueries = class(TDBQueries<TDBItem>)
  public
    constructor Create(Table: TDBTable<TDBItem>); override;
    function ById(Id: Integer): TDBQuery<TDBItem>;
    destructor Destroy; override;
  end;

implementation

{ TDBitemRepository }

function TDBItemRepository.AllFields: TDBFields<TDBItem>;
begin

end;

function TDBItemRepository.TextFields: TDBFields<TDBItem>;
begin

end;

function TDBitemRepository.WithKey: TDBFields<TDBItem>;
begin
  Result := Fields.SetOf([DBItemFields.Id]);
end;

{ TDBTable<T> }

constructor TDBTable<T>.Create(Fields: TDBFields<T>);
begin                
  FFields := Fields;
  FQueries := nil;

  FFields.Repository.AddObject(Self);
end;

destructor TDBTable<T>.Destroy;
begin
  F(FQueries);
  inherited;
end;

function TDBTable<T>.Join<T1>(Table: TDBTable<T1>): TJoinTableSet<T, T1>;
begin

end;

function TDBTable<T>.SelectItem(): ItemQueries;
begin
  Result := ItemQueries.Create(TDBTable<TDBItem>(Self));
end;

{ TDBFields<T> }

function TDBFields<T>.Add(FieldName: string): TDBFields<T>;
begin
  if FFields.Contains(FieldName) then
    raise Exception.Create('Field {0} is  already in list!');

  FFields.Add(FieldName);

  Result := Self;
end;

constructor TDBFields<T>.Create(Repository: TDBRepository);
begin
  FRepository := Repository;
  FFields := TList<string>.Create;
end;

destructor TDBFields<T>.Destroy;
begin
  F(FFields);
  inherited;
end;

function TDBFields<T>.SetOf(Fields: array of string): TDBFields<T>;
var
  I: Integer;
begin
  Result := Self;

  for I := 0 to Length(Fields) - 1 do
    Add(Fields[I]);
end;

function TDBFields<T>.Table: TDBTable<T>;
begin
  Result := TDBTable<T>.Create(Self);
end;

{ TDBGroupsRepository }

function TDBGroupsRepository.AllFields: TDBFields<TDBGroupItem>;
begin

end;

{ TJoinTableSet<T1, T2> }

function TJoinTableSet<T1, T2>.Onn(FiledName: string): TJoinTableOn<T1, T2>;
begin

end;

{ TJoinTableOn<T1, T2> }

function TJoinTableOn<T1, T2>.Eq(FiledName: string): TJoinTable<T1>;
begin

end;

{ ItemQueries }

function ItemQueries.ById(Id: Integer): TDBQuery<TDBItem>;
begin
  SelectCommand.AddWhereParameter(TIntegerParameter.Create(DBItemFields.Id, Id));

  Result := TDBQuery<TDBItem>.Create(Self);
end;

constructor ItemQueries.Create(Table: TDBTable<TDBItem>);
begin
  inherited Create(Table);
  //SelectCommand := TSelectCommand.Create(ImageTable);
end;

destructor ItemQueries.Destroy;
begin       
  inherited;
end;

{ TDBQuery<T> }

constructor TDBQuery<T>.Create(Queries: TDBQueries<TDBItem>);
begin
  FQueries := Queries;
  Queries.Table.Fields.Repository.AddObject(Self);
end;

destructor TDBQuery<T>.Destroy;
begin
  inherited;
end;

procedure TDBQuery<T>.Fetch(OnItem: TItemFetchCallBack<T>);
begin

end;

function TDBQuery<T>.FirstOrDefault: T;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Queries.Table.Fields.Fields.Count - 1 do
    SC.AddParameter(TStringParameter.Create(Queries.Table.Fields.Fields[I]));
  SC.TopRecords := 1;

  if SC.Execute > 0 then
  begin
    Result := T.Create;
    Result.ReadFromQuery(SC);
  end;
end;

function TDBQuery<T>.GetSelectCommand: TSelectCommand;
begin
  Result := Queries.SelectCommand;
end;

function TDBQuery<T>.OrderBy(FieldName: string): TDBQuery<T>;
begin

end;

function TDBQuery<T>.OrderByDesc(FieldName: string): TDBQuery<T>;
begin

end;

function TDBQuery<T>.ToList: TList<T>;
begin

end;

{ TDBRepository }

procedure TDBRepository.AddObject(QueryObject: TObject);
begin
  FObjects.Add(QueryObject);
end;

constructor TDBRepository.Create;
begin   
  FFields := TDBFields<TDBItem>.Create(Self);  
  FObjects := TList<TObject>.Create;
end;

destructor TDBRepository.Destroy;
begin
  F(FFields);
  FreeList(FObjects);
  inherited;
end;

{ TDBTableQuery<T> }

constructor TDBTableQuery<T>.Create(Table: TDBTable<T>);
begin
  FTable := Table;
end;

{ TDBQueries<T> }

constructor TDBQueries<T>.Create(Table: TDBTable<T>);
begin
  FTable := Table;
  Table.Fields.Repository.AddObject(Self);
end;

destructor TDBQueries<T>.Destroy;
begin
  F(FSelectCommand);
  inherited;
end;

{ TSimpleEntity }

constructor TSimpleEntity.Create;
begin
  FUC := nil;
end;

destructor TSimpleEntity.Destroy;
begin
  F(FUC);
  inherited;
end;

function TSimpleEntity.GetUC: TUpdateCommand;
begin
  if FUC = nil then
  begin
    //FUC := TUpdateCommand.Create(TableName);
    InitUC;
  end;

  Result := FUC;
end;

procedure TSimpleEntity.ReadFromQuery(Query: TSqlCommand);
begin
  DS := Query.DS;
end;

function TSimpleEntity.ReadInteger(FieldName: string; Default: Integer): Integer;
var
  F: TField;
begin
  F := DS.FindField(FieldName);
  if F = nil then
    Exit(Default);

  Result := F.AsInteger;
end;

function TSimpleEntity.ReadString(FieldName, Default: string): string;
var
  F: TField;
begin
  F := DS.FindField(FieldName);
  if F = nil then
    Exit(Default);

  Result := F.AsString;
end;

procedure TSimpleEntity.SaveChanges;
begin
  if UC <> nil then
    UC.Execute;
end;

{ TDBItem }

function TDBItem.GetTableName: string;
begin
  Result := ImageTable;
end;

procedure TDBItem.InitUC;
begin
  UC.AddWhereParameter(TIntegerParameter.Create(DBItemFields.Id, Id));
end;

procedure TDBItem.ReadFromQuery(Query: TSqlCommand);
begin
  inherited;
  
  FId := ReadInteger('Id');
  FLinks := ReadString('Links');
end;

procedure TDBItem.SetLinks(const Value: string);
begin
  FLinks := Value;
  UC.AddParameter(TStringParameter.Create(DBItemFields.Links, Value));
end;

end.
