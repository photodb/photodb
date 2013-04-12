unit uSearchQuery;

interface

uses
  System.Classes,

  Dmitry.Utils.System,

  uMemory,
  uDBConnection,
  uDBEntities,
  uStringUtils;

type
  TSearchQuery = class(TObject)
  private
    FPictureSize: Integer;
    FGroups: TStringList;
    FGroupsAnd: Boolean;
    FPersons: TStringList;
    FPersonsAnd: Boolean;
    function GetGroupsWhere: string;
    function GetPersonsWhereOr: string;
  public
    Query: string;
    RatingFrom: Integer;
    RatingTo: Integer;
    ShowPrivate: Boolean;
    DateFrom: TDateTime;
    DateTo: TDateTime;
    SortMethod: Integer;
    SortDecrement: Boolean;
    IsEstimate: Boolean;
    ShowAllImages: Boolean;
    function EqualsTo(AQuery: TSearchQuery): Boolean;
    constructor Create(PictureSize: Integer = 0);
    destructor Destroy; override;
    property PictureSize: Integer read FPictureSize;
    property Groups: TStringList read FGroups;
    property GroupsAnd: Boolean read FGroupsAnd write FGroupsAnd;
    property GroupsWhere: string read GetGroupsWhere;

    property Persons: TStringList read FPersons;
    property PersonsAnd: Boolean read FPersonsAnd write FPersonsAnd;
    property PersonsWhereOr: string read GetPersonsWhereOr;
  end;

implementation

{ TSearchQuery }

constructor TSearchQuery.Create(PictureSize: Integer);
begin
  FPictureSize := PictureSize;
  FGroups := TStringList.Create;
  FPersons := TStringList.Create;
  GroupsAnd := False;
  PersonsAnd := False;
end;

destructor TSearchQuery.Destroy;
begin
  F(FGroups);
  F(FPersons);
end;

function TSearchQuery.EqualsTo(AQuery: TSearchQuery): Boolean;
begin
  Result := (AQuery.RatingFrom = RatingFrom) and (AQuery.RatingTo = RatingTo)
       and (AQuery.DateFrom = DateFrom) and (AQuery.DateTo = DateTo)
       and AQuery.Groups.Equals(Groups) and (AQuery.Query = Query)
       and (AQuery.SortMethod = SortMethod) and (AQuery.SortDecrement = SortDecrement);
end;

function TSearchQuery.GetGroupsWhere: string;
var
  I: Integer;
  SList: TStringList;
begin
  Result := '';
  if Groups.Count > 0 then
  begin
    SList := TStringList.Create;
    try
      for I := 0 to Groups.Count - 1 do
        if Groups[I] <> '' then
          SList.Add(FormatEx('Groups like {0}', [NormalizeDBString(NormalizeDBStringLike(TGroup.GroupSearchByGroupName(Groups[I])))]));

      Result := SList.Join(IIF(GroupsAnd, ' AND ', ' OR '));
    finally
      F(SList);
    end;
  end;
end;

function TSearchQuery.GetPersonsWhereOr: string;
var
  I: Integer;
  SList: TStringList;
begin
  Result := '';
  if Persons.Count > 0 then
  begin
    SList := TStringList.Create;
    try
      for I := 0 to Persons.Count - 1 do
        if Persons[I] <> '' then
          SList.Add(FormatEx('trim(P.ObjectName) like {0}', [NormalizeDBString(NormalizeDBStringLike(Persons[I]))]));

      Result := SList.Join(' OR ');
    finally
      F(SList);
    end;
  end;
end;

end.
