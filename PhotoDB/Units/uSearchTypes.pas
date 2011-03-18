unit uSearchTypes;

interface

uses
  Classes, Forms, uFormListView, uMemory, UnitDBDeclare;

type
  TDateRange = record
    DateFrom : TDateTime;
    DateTo : TDateTime;
  end;

  TListFillInfo = record
    LastYear : Integer;
    LastMonth : Integer;
    LastRating : Integer;
    LastChar : Char;
    LastSize : Int64;
  end;

  TGroupInfo = class(TObject)
  public
    Name : string;
  end;

  TSearchInfo = class(TObject)
  private
    FList : TList;
    function GetCount: Integer;
    function GetValueByIndex(Index: Integer): TSearchQuery;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(RatingFrom, RatingTo : Integer; DateFrom, DateTo : TDateTime; GroupName, Query : string; SortMethod : Integer; SortDecrement : Boolean) : TSearchQuery;
    property Items[Index: Integer]: TSearchQuery read GetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

type
  TSearchCustomForm = class(TListViewForm)
  private
    FWindowID : TGUID;
  protected
    function GetSearchText: string; virtual; abstract;
    procedure SetSearchText(value: string); virtual; abstract;
  public
    procedure StartSearch; overload; virtual; abstract;
    procedure StartSearch(Text: string); overload; virtual; abstract;
    procedure StartSearchDirectory(Directory: string); overload; virtual; abstract;
    procedure StartSearchDirectory(Directory: string; FileID: Integer); overload; virtual; abstract;
    procedure StartSearchSimilar(FileName: string); virtual; abstract;
    property WindowID: TGUID read FWindowID write FWindowID;
    property SearchText: string read GetSearchText write SetSearchText;
  end;

type
  TManagerSearchs = class(TObject)
  private
    FSearches : TList;
    function GetValueByIndex(Index: Integer): TSearchCustomForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewSearch : TSearchCustomForm;
    procedure AddSearch(Search : TSearchCustomForm);
    procedure RemoveSearch(Search : TSearchCustomForm);
    function IsSearch(Search : TForm) : Boolean;
    function SearchCount : Integer;
    property Items[Index: Integer]: TSearchCustomForm read GetValueByIndex; default;
    function GetAnySearch : TSearchCustomForm;
  end;

function SearchManager: TManagerSearchs;

implementation

uses
  Searching;

var
  FSearchManager : TManagerSearchs = nil;

function SearchManager: TManagerSearchs;
begin
  if FSearchManager = nil then
    FSearchManager := TManagerSearchs.Create;

  Result := FSearchManager;
end;


{ TManagerSearchs }

procedure TManagerSearchs.AddSearch(Search: TSearchCustomForm);
begin
  if FSearches.IndexOf(Search) = -1 then
    FSearches.Add(Search);
end;

constructor TManagerSearchs.Create;
begin
  FSearches := TList.Create;
end;

destructor TManagerSearchs.Destroy;
begin
  F(FSearches);
  inherited;
end;

function TManagerSearchs.IsSearch(Search: TForm): Boolean;
begin
  Result := FSearches.IndexOf(Search) > -1;
end;

function TManagerSearchs.NewSearch: TSearchCustomForm;
begin
  Application.CreateForm(TSearchForm, Result);
end;

function TManagerSearchs.GetAnySearch : TSearchCustomForm;
begin
  if SearchCount = 0 then
    Result := NewSearch
  else
    Result := FSearches[0];
end;

procedure TManagerSearchs.RemoveSearch(Search: TSearchCustomForm);
begin
  FSearches.Remove(Search);
end;

function TManagerSearchs.SearchCount: Integer;
begin
 Result := FSearches.Count;
end;

function TManagerSearchs.GetValueByIndex(Index: Integer): TSearchCustomForm;
begin
  Result := FSearches[Index];
end;

{ TSearchInfo }

function TSearchInfo.Add(RatingFrom, RatingTo: Integer; DateFrom,
  DateTo: TDateTime; GroupName, Query: string; SortMethod: Integer;
  SortDecrement: Boolean) : TSearchQuery;
var
  I : Integer;
  Tmp : TSearchQuery;
begin
  for I := 0 to Count - 1 do
  begin
    Tmp := Self[I];
    if (Tmp.RatingFrom = RatingFrom) and (Tmp.RatingTo = RatingTo)
       and (Tmp.DateFrom = DateFrom) and (Tmp.DateTo = DateTo)
       and (Tmp.GroupName = GroupName) and (Tmp.Query = Query)
       and (Tmp.SortMethod = SortMethod) and (Tmp.SortDecrement = SortDecrement) then
    begin
      //Move to first record
      Result := Tmp;
      FList.Delete(I);
      FList.Insert(0, Tmp);
      Exit;
    end;
  end;
  Result := TSearchQuery.Create;
  Result.RatingFrom := RatingFrom;
  Result.RatingTo := RatingTo;
  Result.DateFrom := DateFrom;
  Result.DateTo := DateTo;
  Result.GroupName := GroupName;
  Result.Query := Query;
  Result.SortMethod := SortMethod;
  Result.SortDecrement := SortDecrement;
  FList.Insert(0, Result);
end;

constructor TSearchInfo.Create;
begin
  FList := TList.Create;
end;

destructor TSearchInfo.Destroy;
var
  I : Integer;
begin
  for I := 0 to FList.Count - 1 do
    TSearchQuery(FList[I]).Free;

  FList.Free;
  inherited;
end;

function TSearchInfo.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSearchInfo.GetValueByIndex(Index: Integer): TSearchQuery;
begin
  Result := FList[Index];
end;

initialization

finalization

  F(FSearchManager);

end.
