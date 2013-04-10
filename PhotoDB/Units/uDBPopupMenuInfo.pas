unit uDBPopupMenuInfo;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,

  Dmitry.Utils.Files,

  EasyListView,
  UnitDBDeclare,
  UnitLinksSupport,
  CmpUnit,

  uMemory,
  uDBEntities,
  uList64;

type
  TMediaItemCollection = class(TObject)
  private
    FIsPlusMenu: Boolean;
    FIsListItem: Boolean;
    FListItem: TEasyItem;
    function GetValueByIndex(Index: Integer): TMediaItem;
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
    procedure SetValueByIndex(Index: Integer; const Value: TMediaItem);
    function GetSelectionCount: Integer;
    function GetIsVariousHeight: Boolean;
    function GetIsVariousWidth: Boolean;
    function GetOnlyDBInfo: Boolean;
    function GetFilesSize: Int64;
    function GetIsVariousLocation: Boolean;
    function GetHasNonDBInfo: Boolean;
    function GetCommonSelectedGroups: string;
  protected
    FData: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TMediaItemCollection);
    procedure Insert(Index: Integer; MenuRecord: TMediaItem);
    procedure Add(MenuRecord: TMediaItem); overload;
    function Add(FileName: string): TMediaItem; overload;
    procedure Clear;
    procedure ClearList;
    procedure Exchange(Index1, Index2: Integer);
    procedure Delete(Index: Integer);
    procedure NextSelected;
    procedure PrevSelected;
    function Extract(Index: Integer): TMediaItem;
    property Items[index: Integer]: TMediaItem read GetValueByIndex write SetValueByIndex; default;
    property IsListItem: Boolean read FIsListItem write FIsListItem;
    property Count: Integer read GetCount;
    property IsVariousInclude: Boolean read GetIsVariousInclude;
    property IsVariousDate: Boolean read GetIsVariousDate;
    property IsVariousTime: Boolean read GetIsVariousTime;
    property IsVariousComments: Boolean read GetIsVariousComments;
    property IsVariousWidth: Boolean read GetIsVariousWidth;
    property IsVariousHeight: Boolean read GetIsVariousHeight;
    property IsVariousLocation: Boolean read GetIsVariousLocation;
    property StatRating: Integer read GetStatRating;
    property StatDate: TDateTime read GetStatDate;
    property StatTime: TDateTime read GetStatTime;
    property StatIsDate: Boolean read GetStatIsDate;
    property StatIsTime: Boolean read GetStatIsTime;
    property StatInclude: Boolean read GetStatInclude;
    property IsPlusMenu: Boolean read FIsPlusMenu write FIsPlusMenu;
    property CommonKeyWords: string read GetCommonKeyWords;
    property CommonGroups: string read GetCommonGroups;
    property CommonSelectedGroups: string read GetCommonSelectedGroups;
    property CommonLinks: TLinksInfo read GetCommonLinks;
    property CommonComments: string read GetCommonComments;
    property Position: Integer read GetPosition write SetPosition;
    property ListItem: TEasyItem read FListItem write FListItem;
    property SelectionCount: Integer read GetSelectionCount;
    property OnlyDBInfo: Boolean read GetOnlyDBInfo;
    property FilesSize: Int64 read GetFilesSize;
    property HasNonDBInfo: Boolean read GetHasNonDBInfo;
  end;

implementation

function GetCommonGroupsForStringList(GroupsList: TStringList): string;
var
  I: Integer;
  FArGroups: TList<TGroups>;
  Res: TGroups;

  function GetCommonGroupsForList(ArGroups: TList<TGroups>): TGroups;
  var
    I, J: Integer;
  begin
    if ArGroups.Count = 0 then
      Exit;

    Result := ArGroups[0].Clone;
    for I := 1 to ArGroups.Count - 1 do
    begin
      if ArGroups[I].Count = 0 then
      begin
        FreeList(Result, False);
        Break;
      end;

      for J := Result.Count - 1 downto 0 do
        if not ArGroups[I].HasGroup(Result[J]) then
          Result.RemoveGroup(Result[J]);

      if Result.Count = 0 then
        Exit;
    end;
  end;

begin
  Result := '';

  if GroupsList.Count = 0 then
    Exit;

  FArGroups := TList<TGroups>.Create;
  try
    for I := 0 to GroupsList.Count - 1 do
      FArGroups.Add(TGroups.CreateFromString(GroupsList[I]));

    Res := GetCommonGroupsForList(FArGroups);
    try
      Result := Res.ToString;
    finally
      F(Res);
    end;
  finally
    FreeList(FArGroups);
  end;
end;

{ TDBPopupMenuInfo }

procedure TMediaItemCollection.Add(MenuRecord: TMediaItem);
begin
  if MenuRecord = nil then
    Exit;

  FData.Add(MenuRecord);
end;

procedure TMediaItemCollection.Insert(Index: Integer;
  MenuRecord: TMediaItem);
begin
  if MenuRecord = nil then
    Exit;

  FData.Insert(Index, MenuRecord);
end;

function TMediaItemCollection.Add(FileName: string) : TMediaItem;
begin
  Result := TMediaItem.Create;
  Result.FileName := FileName;
  Result.Include := True;
  Result.FileSize := GetFileSize(FileName);
  Add(Result);
end;

procedure TMediaItemCollection.Assign(Source: TMediaItemCollection);
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

procedure TMediaItemCollection.Clear;
var
  I: Integer;
begin
  for I := 0 to FData.Count - 1 do
    TMediaItem(FData[I]).Free;
  FData.Clear;
end;

procedure TMediaItemCollection.ClearList;
begin
  FData.Clear;
end;

constructor TMediaItemCollection.Create;
begin
  FData := TList.Create;
end;

procedure TMediaItemCollection.Delete(Index: Integer);
begin
  TObject(FData[Index]).Free;
  FData.Delete(Index);
end;

destructor TMediaItemCollection.Destroy;
begin
  Clear;
  F(FData);
  inherited;
end;

procedure TMediaItemCollection.Exchange(Index1, Index2: Integer);
begin
  FData.Exchange(Index1, Index2);
end;

function TMediaItemCollection.Extract(Index: Integer): TMediaItem;
begin
  Result := FData[Index];
  FData.Delete(Index);
end;

function TMediaItemCollection.GetCommonComments: string;
begin
  Result := '';
  if (Count > 0) and not IsVariousComments then
    Result := Self[0].Comment;
end;

function TMediaItemCollection.GetCommonGroups: string;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Self[I].Groups);
    Result := GetCommonGroupsForStringList(SL);
  finally
    F(SL);
  end;
end;

function TMediaItemCollection.GetCommonSelectedGroups: string;
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      if Self[I].Selected then
        SL.Add(Self[I].Groups);
    Result := GetCommonGroupsForStringList(SL);
  finally
    F(SL);
  end;
end;

function TMediaItemCollection.GetCommonKeyWords: string;
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
    F(KL);
  end;
end;

function TMediaItemCollection.GetCommonLinks: TLinksInfo;
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
    F(LL);
  end;
end;

function TMediaItemCollection.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TMediaItemCollection.GetFilesSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, Self[I].FileSize);
end;

function TMediaItemCollection.GetHasNonDBInfo: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Self[I].ID = 0 then
      Exit(True);
end;

function TMediaItemCollection.GetIsVariousComments: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Comment <> Self[I].Comment then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousDate: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Date <> Self[I].Date then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousHeight: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Height <> Self[I].Height then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousInclude: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Include <> Self[I].Include then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousLocation: Boolean;
var
  I: Integer;
  FirstDir: string;
begin
  Result := False;
  if Count > 1 then
  begin
    FirstDir := ExtractFileDir(Self[0].FileName);
    for I := 1 to Count - 1 do
      if FirstDir <> ExtractFileDir(Self[I].FileName) then
        Result := True;
  end;
end;

function TMediaItemCollection.GetIsVariousTime: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Time <> Self[I].Time then
        Result := True;
end;

function TMediaItemCollection.GetIsVariousWidth: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count > 1 then
    for I := 1 to Count - 1 do
      if Self[0].Width <> Self[I].Width then
        Result := True;
end;

function TMediaItemCollection.GetOnlyDBInfo: Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := 0 to Count - 1 do
    if Self[I].ID = 0 then
      Exit(False);
end;

function TMediaItemCollection.GetPosition: Integer;
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

function TMediaItemCollection.GetSelectionCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Self[I].Selected then
      Inc(Result);
end;

function TMediaItemCollection.GetStatDate: TDateTime;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetStatInclude: Boolean;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetStatIsDate: Boolean;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetStatIsTime: Boolean;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetStatRating: Integer;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetStatTime: TDateTime;
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
    F(List);
  end;
end;

function TMediaItemCollection.GetValueByIndex(Index: Integer): TMediaItem;
begin
  if Index < 0 then
    raise EInvalidOperation.Create('Index is out of range - index should be 0 or grater!');

  if Index > Count - 1 then
    raise EInvalidOperation.Create('Index is out of range!');

  Result := FData[Index];
end;

procedure TMediaItemCollection.SetPosition(const Value: Integer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].IsCurrent := False;
  Self[Value].IsCurrent := True;
end;

procedure TMediaItemCollection.NextSelected;
var
  I: Integer;
begin
  for I := Position + 1 to Count - 1 do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;

  for I := 0 to Position do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;
end;

procedure TMediaItemCollection.PrevSelected;
var
  I: Integer;
begin
  for I := Position - 1 downto 0 do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;

  for I := Count - 1 downto Position do
    if Self[I].Selected then
    begin
      Position := I;
      Exit;
    end;
end;

procedure TMediaItemCollection.SetValueByIndex(index: Integer;
  const Value: TMediaItem);
begin
  if FData[index] <> nil then
    TMediaItem(FData[index]).Free;
  FData[index] := Value;
end;

end.
