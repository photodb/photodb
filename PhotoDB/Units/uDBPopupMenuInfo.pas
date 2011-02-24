unit uDBPopupMenuInfo;

interface

uses
  Classes, EasyListView, UnitDBDeclare, UnitLinksSupport, UnitGroupsWork,
  CmpUnit, uList64;

type
  TDBPopupMenuInfo = class(TObject)
  private
    FAttrExists: Boolean;
    FIsPlusMenu: Boolean;
    FIsListItem: Boolean;
    FListItem: TEasyItem;
    function GetValueByIndex(index: Integer): TDBPopupMenuInfoRecord;
    function GetCount: Integer;
    function GetIsVariousInclude: Boolean;
    function GetStatRating: Integer;
    function GetStatDate: TDateTime;
    function GetStatTime: TDateTime;
    function GetStatIsDate: Boolean;
    function GetStatIsTime: Boolean;
    function GetIsVariousDate: Boolean;
    function GetIsVariousTime: Boolean;
    function GetCommonKeyWords: string;
    function GetIsVariousComments: Boolean;
    function GetCommonGroups: string;
    function GetCommonLinks: TLinksInfo;
    function GetPosition: Integer;
    procedure SetPosition(const Value: Integer);
    function GetStatInclude: Boolean;
    function GetCommonComments: string;
    procedure SetValueByIndex(index: Integer;
      const Value: TDBPopupMenuInfoRecord);
  protected
    FData: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source : TDBPopupMenuInfo);
    procedure Add(MenuRecord: TDBPopupMenuInfoRecord); overload;
    function Add(FileName: string) : TDBPopupMenuInfoRecord; overload;
    procedure Clear;
    procedure ClearList;
    procedure Exchange(Index1, Index2 : Integer);
    procedure Delete(Index : Integer);
    function Extract(Index : Integer) : TDBPopupMenuInfoRecord;
    property Items[index: Integer]: TDBPopupMenuInfoRecord read GetValueByIndex write SetValueByIndex; default;
    property IsListItem: Boolean read FIsListItem write FIsListItem;
    property AttrExists: Boolean read FAttrExists write FAttrExists;
    property Count: Integer read GetCount;
    property IsVariousInclude: Boolean read GetIsVariousInclude;
    property IsVariousDate: Boolean read GetIsVariousDate;
    property IsVariousTime: Boolean read GetIsVariousTime;
    property IsVariousComments: Boolean read GetIsVariousComments;
    property StatRating: Integer read GetStatRating;
    property StatDate: TDateTime read GetStatDate;
    property StatTime: TDateTime read GetStatTime;
    property StatIsDate: Boolean read GetStatIsDate;
    property StatIsTime: Boolean read GetStatIsTime;
    property StatInclude: Boolean read GetStatInclude;
    property IsPlusMenu: Boolean read FIsPlusMenu write FIsPlusMenu;
    property CommonKeyWords: string read GetCommonKeyWords;
    property CommonGroups: string read GetCommonGroups;
    property CommonLinks: TLinksInfo read GetCommonLinks;
    property CommonComments: string read GetCommonComments;
    property Position: Integer read GetPosition write SetPosition;
    property ListItem: TEasyItem read FListItem write FListItem;
  end;

implementation


{ TDBPopupMenuInfo }

procedure TDBPopupMenuInfo.Add(MenuRecord: TDBPopupMenuInfoRecord);
begin
  FData.Add(MenuRecord);
end;

function TDBPopupMenuInfo.Add(FileName: string) : TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfoRecord.Create;
  Result.FileName := FileName;
  Add(Result);
end;

procedure TDBPopupMenuInfo.Assign(Source: TDBPopupMenuInfo);
var
  I: Integer;
begin
  if Pointer(Source) = Pointer(Self) then
     Exit;
  Clear;
  for I := 0 to Source.Count - 1 do
    FData.Add(Source[I].Copy);

  if Source.Position >= 0 then
    Position := Source.Position;

  ListItem := Source.ListItem;
end;

procedure TDBPopupMenuInfo.Clear;
var
  I: Integer;
begin
  for I := 0 to FData.Count - 1 do
    TDBPopupMenuInfoRecord(FData[I]).Free;
  FData.Clear;
end;

procedure TDBPopupMenuInfo.ClearList;
begin
  FData.Clear;
end;

constructor TDBPopupMenuInfo.Create;
begin
  FData := TList.Create;
end;

procedure TDBPopupMenuInfo.Delete(Index: Integer);
begin
  TObject(FData[Index]).Free;
  FData.Delete(Index);
end;

destructor TDBPopupMenuInfo.Destroy;
begin
  Clear;
  FData.Free;
  inherited;
end;

procedure TDBPopupMenuInfo.Exchange(Index1, Index2: Integer);
begin
  FData.Exchange(Index1, Index2);
end;

function TDBPopupMenuInfo.Extract(Index: Integer): TDBPopupMenuInfoRecord;
begin
  Result := FData[Index];
  FData.Delete(Index);
end;

function TDBPopupMenuInfo.GetCommonComments: string;
begin
  Result := '';
  if (Count > 0) and not IsVariousComments then
    Result := Self[0].Comment;
end;

function TDBPopupMenuInfo.GetCommonGroups: string;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Self[I].Groups);
    Result := UnitGroupsWork.GetCommonGroups(SL);
  finally
    SL.Free;
  end;
end;

function TDBPopupMenuInfo.GetCommonKeyWords: string;
var
  KL: TStringList;
  I: Integer;
begin
  KL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      KL.Add(Self[I].KeyWords);
    Result := GetCommonWordsA(KL);
  finally
    KL.Free;
  end;
end;

function TDBPopupMenuInfo.GetCommonLinks: TLinksInfo;
var
  LL: TStringList;
  I: Integer;
begin
  LL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      LL.Add(Self[I].Links);
    Result := UnitLinksSupport.GetCommonLinks(LL);
  finally
    LL.Free;
  end;
end;

function TDBPopupMenuInfo.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TDBPopupMenuInfo.GetIsVariousComments: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Comment <> Self[I].Comment then
        Result := True;
end;

function TDBPopupMenuInfo.GetIsVariousDate: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Date <> Self[I].Date then
        Result := True;
end;

function TDBPopupMenuInfo.GetIsVariousInclude: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Include <> Self[I].Include then
        Result := True;
  end;

function TDBPopupMenuInfo.GetIsVariousTime: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Time <> Self[I].Time then
        Result := True;
end;

function TDBPopupMenuInfo.GetPosition: Integer;
var
  I: Integer;
begin
  Result := -1;
  if Count > 0 then
    Result := 0;
  for I := 1 to Count - 1 do
    if Self[I].IsCurrent then
      Result := I;
end;

function TDBPopupMenuInfo.GetStatDate: TDateTime;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Date);
    Result := List.MaxStatDateTime;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetStatInclude: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Include);
    Result := List.MaxStatBoolean;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetStatIsDate: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].IsDate);
    Result := List.MaxStatBoolean;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetStatIsTime: Boolean;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].IsTime);
    Result := List.MaxStatBoolean;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetStatRating: Integer;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Rating);
    Result := List.MaxStatInteger;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetStatTime: TDateTime;
var
  I: Integer;
  List: TList64;
begin
  List := TList64.Create;
  try
    for I := 0 to Count - 1 do
      List.Add(Self[I].Time);
    Result := List.MaxStatDateTime;
  finally
    List.Free;
  end;
end;

function TDBPopupMenuInfo.GetValueByIndex(index: Integer): TDBPopupMenuInfoRecord;
begin
  Result := FData[index];
end;

procedure TDBPopupMenuInfo.SetPosition(const Value: Integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].IsCurrent := False;
  Self[Value].IsCurrent := True;
end;

procedure TDBPopupMenuInfo.SetValueByIndex(index: Integer;
  const Value: TDBPopupMenuInfoRecord);
begin
  if FData[index] <> nil then
    TDBPopupMenuInfoRecord(FData[index]).Free;
  FData[index] := Value;
end;

end.
