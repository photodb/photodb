unit uExplorerDateStackProviders;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Vcl.Graphics,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Utils.ShellIcons,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,

  CommonDBSupport,
  UnitGroupsWork,

  uConstants,
  uMemory,
  uTranslate,
  uExplorerPathProvider,
  uExplorerGroupsProvider,
  uExplorerPersonsProvider,
  uDateUtils;

type
  TDateStackItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TCalendarItem = class(TPathItem)
  protected
    FCount: Integer;
    function GetOrder: Integer; virtual; abstract;
  public
    procedure SetCount(Count: Integer);
    procedure IntCount;
    property Order: Integer read GetOrder;
  end;

  TDateStackYearItem = class(TCalendarItem)
  private
    function GetYear: Integer;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
    function GetOrder: Integer; override;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Year: Integer read GetYear;
  end;

  TDateStackMonthItem = class(TCalendarItem)
  private
    function GetMonth: Integer;
    function GetYear: Integer;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
    function GetOrder: Integer; override;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Month: Integer read GetMonth;
    property Year: Integer read GetYear;
  end;

  TDateStackDayItem = class(TCalendarItem)
  private
    function GetDay: Integer;
    function GetMonth: Integer;
    function GetYear: Integer;
    function GetDate: TDateTime;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
    function GetOrder: Integer; override;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Day: Integer read GetDay;
    property Month: Integer read GetMonth;
    property Year: Integer read GetYear;
    property Date: TDateTime read GetDate;
  end;

type
  TExplorerDateStackProvider = class(TExplorerPathProvider)
  public
    function GetTranslateID: string; override;
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
    function InternalFillChildList(Sender: TObject; Item: TPathItem; List: TPathItemCollection; Options, ImageSize: Integer; PacketSize: Integer; CallBack: TLoadListCallBack): Boolean; override;
  end;

implementation

{ TExplorerDateStackProvider }

function TExplorerDateStackProvider.CreateFromPath(Path: string): TPathItem;
var
  S: string;
  P: Integer;

  function CreateDateItem(S: string): TPathItem;
  var
    SL: TStrings;
    I: Integer;
  begin
    Result := nil;
    SL := TStringList.Create;
    try
      SL.Delimiter := '\';
      SL.DelimitedText := S;

      for I := SL.Count - 1 downto 0 do
        if SL[I] = '' then
          SL.Delete(I);
      if SL.Count = 0 then
        Result := TDateStackItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
      if SL.Count = 1 then
        Result := TDateStackYearItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
      if SL.Count = 2 then
        Result := TDateStackMonthItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
      if SL.Count = 3 then
        Result := TDateStackDayItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
    finally
      F(SL);
    end;
  end;

begin
  Result := nil;
  S := ExcludeTrailingPathDelimiter(Path);

  if StartsText(cDatesPath, AnsiLowerCase(S)) then
  begin
    Delete(S, 1, Length(cDatesPath));
    Result := CreateDateItem(S);
  end;

  if StartsText(cGroupsPath + '\', AnsiLowerCase(S)) then
  begin
    Delete(S, 1, Length(cGroupsPath) + 1);
    P := Pos('\', S);
    if P > 0 then
      Result := CreateDateItem(Copy(S, P + 1, Length(S) - P));
  end;

  if StartsText(cPersonsPath + '\', AnsiLowerCase(S)) then
  begin
    Delete(S, 1, Length(cPersonsPath) + 1);
    P := Pos('\', S);
    if P > 0 then
      Result := CreateDateItem(Copy(S, P + 1, Length(S) - P));
  end;
end;

function TExplorerDateStackProvider.GetTranslateID: string;
begin
  Result := 'CalendarProvider';
end;

function Capitalize(const S: string): string;
begin
  Result := S;
  if Length(Result) > 0 then
    Result[1] := AnsiUpperCase(Result[1])[1];
end;

function TExplorerDateStackProvider.InternalFillChildList(Sender: TObject;
  Item: TPathItem; List: TPathItemCollection; Options, ImageSize,
  PacketSize: Integer; CallBack: TLoadListCallBack): Boolean;
var
  Cancel: Boolean;
  Count, Year, Month, Day: Integer;
  DSI: TDateStackItem;
  YI: TDateStackYearItem;
  MI: TDateStackMonthItem;
  DI: TDateStackDayItem;
  GI: TGroupItem;
  PI: TPersonItem;
  FDateRangeDS: TDataSet;
  Filter, SQL, Table: string;

  function ImagesFilter: string;
  begin
    Result := FormatEx('(Attr <> {0} and DateToAdd > cMinEXIFYear and IsDate = True)', [Db_attr_not_exists]);
  end;

  function PersonsJoin: string;
  begin
    Result := FormatEx(' INNER JOIN {1} PM on PM.ImageID = IM.ID) INNER JOIN {0} P on P.ObjectID = PM.ObjectID', [ObjectTableName, ObjectMappingTableName]);
  end;

  function FromTable(ForPersons: Boolean): string;
  begin
    if not ForPersons then
      Result := 'ImageTable'
    else
      Result := Format('(SELECT ImageID, DateToAdd, Attr, IsDate, ObjectName FROM ($DB$ IM %s)', [PersonsJoin]);
  end;

begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    DSI := TDateStackItem.CreateFromPath(cDatesPath, Options, ImageSize);
    List.Add(DSI);
  end;

  if Item is TDateStackItem then
  begin
    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);
      SetSQL(FDateRangeDS, 'SELECT Year(DateToAdd) as GroupYear, Count(1) as ItemCount FROM (select DateToAdd from ImageTable where ' + ImagesFilter + ' ) Group BY Year(DateToAdd) Order by Year(DateToAdd) desc');

      OpenDS(FDateRangeDS);

      while not FDateRangeDS.EOF do
      begin
        Year := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        YI := TDateStackYearItem.CreateFromPath(cDatesPath + '\' + IntToStr(Year), Options, ImageSize);
        YI.SetCount(Count);
        List.Add(YI);
        FDateRangeDS.Next;
      end;
    finally
      FreeDS(FDateRangeDS);
    end;
  end;

  if Item is TGroupItem then
  begin
    GI := TGroupItem(item);
    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);

      Filter := ImagesFilter;
      Filter := Filter + ' AND (Groups like "' + GroupSearchByGroupName(GI.GroupName) + '")';
      SetSQL(FDateRangeDS, 'SELECT Year(DateToAdd) as "GroupYear", Count(1) as ItemCount FROM (select DateToAdd from ImageTable where ' + Filter + ' ) Group BY Year(DateToAdd) Order by Year(DateToAdd) desc');

      OpenDS(FDateRangeDS);

      while not FDateRangeDS.EOF do
      begin
        Year := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        YI := TDateStackYearItem.CreateFromPath(ExcludeTrailingPathDelimiter(Item.Path) + '\' + IntToStr(Year), Options, ImageSize);
        YI.SetCount(Count);
        List.Add(YI);
        FDateRangeDS.Next;
      end;
    finally
      FreeDS(FDateRangeDS);
    end;
  end;

  if Item is TPersonItem then
  begin
    PI := TPersonItem(item);
    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);

      Table := FromTable(True);

      Filter := ImagesFilter;
      Filter := Filter + ' AND (trim(P.ObjectName) like ' + NormalizeDBString(NormalizeDBStringLike(PI.PersonName)) + ')';

      SetSQL(FDateRangeDS, 'SELECT Year(DateToAdd) as "GroupYear", Count(1) as ItemCount FROM (select DateToAdd from ' + Table + ' where ' + Filter + ' ) Group BY Year(DateToAdd) Order by Year(DateToAdd) desc');

      OpenDS(FDateRangeDS);

      while not FDateRangeDS.EOF do
      begin
        Year := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        YI := TDateStackYearItem.CreateFromPath(ExcludeTrailingPathDelimiter(Item.Path) + '\' + IntToStr(Year), Options, ImageSize);
        YI.SetCount(Count);
        List.Add(YI);
        FDateRangeDS.Next;
      end;
    finally
      FreeDS(FDateRangeDS);
    end;
  end;

  if Item is TDateStackYearItem then
  begin
    YI := TDateStackYearItem(Item);

    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);

      Filter := ImagesFilter;
      if (YI.Parent is TGroupItem) then
      begin
        GI := TGroupItem(YI.Parent);
        Filter := Filter + ' AND (Groups like "' + GroupSearchByGroupName(GI.GroupName) + '")';
      end;

      Table := FromTable(False);
      if (YI.Parent is TPersonItem) then
      begin
        Table := FromTable(True);
        PI := TPersonItem(YI.Parent);
        Filter := Filter + ' AND (trim(P.ObjectName) like ' + NormalizeDBString(NormalizeDBStringLike(PI.PersonName)) + ')';
      end;

      SQL := 'SELECT Month(DateToAdd) as "GroupMonth", Count(1) as ItemCount FROM (select DateToAdd from ' + Table + ' where ' + Filter + ' and Year(DateToAdd) = ' + IntToStr(YI.Year) + ') Group BY Month(DateToAdd) Order by Month(DateToAdd) desc';

      SetSQL(FDateRangeDS, SQL);

      OpenDS(FDateRangeDS);

      while not FDateRangeDS.EOF do
      begin
        Month := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        MI := TDateStackMonthItem.CreateFromPath(ExcludeTrailingPathDelimiter(Item.Path) + '\' + IntToStr(Month), Options, ImageSize);
        MI.SetCount(Count);
        List.Add(MI);

        FDateRangeDS.Next;
      end;
    finally
      FreeDS(FDateRangeDS);
    end;
  end;

  if Item is TDateStackMonthItem then
  begin
    MI := TDateStackMonthItem(Item);

    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);

      Filter := ImagesFilter;
      if (MI.Parent <> nil) and (MI.Parent.Parent is TGroupItem) then
      begin
        GI := TGroupItem(MI.Parent.Parent);
        Filter := Filter + ' AND (Groups like "' + GroupSearchByGroupName(GI.GroupName) + '")';
      end;

      Table := FromTable(False);
      if (MI.Parent <> nil) and (MI.Parent.Parent is TPersonItem) then
      begin
        Table := FromTable(True);
        PI := TPersonItem(MI.Parent.Parent);
        Filter := Filter + ' AND (trim(P.ObjectName) like ' + NormalizeDBString(NormalizeDBStringLike(PI.PersonName)) + ')';
      end;

      SQL := 'SELECT Day(DateToAdd) as "GroupDay", Count(1) as ItemCount FROM (select DateToAdd from ' + Table + ' where ' + Filter + ' and Year(DateToAdd) = ' + IntToStr(MI.Year) + ' and Month(DateToAdd) = ' + IntToStr(MI.Month) + ') Group BY Day(DateToAdd) Order by Day(DateToAdd) desc';
      SetSQL(FDateRangeDS, SQL);

      OpenDS(FDateRangeDS);

      while not FDateRangeDS.EOF do
      begin
        Day := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        DI := TDateStackDayItem.CreateFromPath(ExcludeTrailingPathDelimiter(Item.Path) + '\' + IntToStr(Day), Options, ImageSize);
        DI.SetCount(Count);
        List.Add(DI);

        FDateRangeDS.Next;
      end;
    finally
      FreeDS(FDateRangeDS);
    end;
  end;

  if Assigned(CallBack) then
    CallBack(Sender, Item, List, Cancel);
end;

function TExplorerDateStackProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TDateStackItem;
  Result := Result or Supports(Item.Path);
end;

function TExplorerDateStackProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(L(cDatesPath), AnsiLowerCase(Path));

  if not Result then
  begin
    if StartsText(cGroupsPath + '\', AnsiLowerCase(Path))  then
    begin
      Delete(Path, 1, Length(cGroupsPath) + 1);
      Result := Pos('\', Path) > 0;
    end;
  end;

  if not Result then
  begin
    if StartsText(cPersonsPath + '\', AnsiLowerCase(Path))  then
    begin
      Delete(Path, 1, Length(cPersonsPath) + 1);
      Result := Pos('\', Path) > 0;
    end;
  end;
end;

{ TDateStackItem }

constructor TDateStackItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := TA('Calendar', 'CalendarProvider');
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDateStackItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDateStackItem.Create;
end;

function TDateStackItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

function TDateStackItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'CALENDAR', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TDateStackYearItem }

procedure TDateStackYearItem.Assign(Item: TPathItem);
begin
  inherited;
  FCount := TDateStackYearItem(Item).FCount;
end;

constructor TDateStackYearItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackYearItem.GetDisplayName: string;
begin
  Result := IntToStr(Year);
  if FCount > 0 then
    Result := Result + ' (' + IntToStr(FCount) + ')';
end;

function TDateStackYearItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDateStackYearItem.GetOrder: Integer;
begin
  Result := Year * 10000;
end;

function TDateStackYearItem.GetYear: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, P + 1, Length(S) - P);
    Result := StrToInt64Def(S, 0);
  end;
end;

function TDateStackYearItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDateStackYearItem.Create;
end;

function TDateStackYearItem.InternalGetParent: TPathItem;
var
  S: string;
  P: Integer;
begin
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    Result := PathProviderManager.CreatePathItem(S);
    Exit;
  end;
  Result := nil;
end;

function TDateStackYearItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'YEARICON', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TDateStackMonthItem }

procedure TDateStackMonthItem.Assign(Item: TPathItem);
begin
  inherited;
  FCount := TDateStackMonthItem(Item).FCount;
end;

constructor TDateStackMonthItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackMonthItem.GetDisplayName: string;
begin
  Result := Capitalize(MonthToString(Month));
  if FCount > 0 then
    Result := Result + ' (' + IntToStr(FCount) + ')';
end;

function TDateStackMonthItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDateStackMonthItem.GetMonth: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, P + 1, Length(S) - P);
    Result := StrToInt64Def(S, 0);
  end;
end;

function TDateStackMonthItem.GetOrder: Integer;
begin
  Result := Year + 10000 + Month + 100;
end;

function TDateStackMonthItem.GetYear: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    P := LastDelimiter('/\', S);
    if P > 0 then
    begin
      S := System.Copy(S, P + 1, Length(S) - P);
      Result := StrToInt64Def(S, 0);
    end;
  end;
end;

function TDateStackMonthItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDateStackMonthItem.Create;
end;

function TDateStackMonthItem.InternalGetParent: TPathItem;
var
  S: string;
  P: Integer;
begin
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    Result := TDateStackYearItem.CreateFromPath(S, PATH_LOAD_NORMAL or PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
    Exit;
  end;
  Result := nil;
end;

function TDateStackMonthItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'MONTHICON', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TDateStackDayItem }

procedure TDateStackDayItem.Assign(Item: TPathItem);
begin
  inherited;
  FCount := TDateStackDayItem(Item).FCount;
end;

constructor TDateStackDayItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackDayItem.GetDate: TDateTime;
begin
  Result := EncodeDate(Year, Month, Day);
end;

function TDateStackDayItem.GetDay: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, P + 1, Length(S) - P);
    Result := StrToInt64Def(S, 0);
  end;
end;

function TDateStackDayItem.GetMonth: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    P := LastDelimiter('/\', S);
    if P > 0 then
    begin
      S := System.Copy(S, P + 1, Length(S) - P);
      Result := StrToInt64Def(S, 0);
    end;
  end;
end;

function TDateStackDayItem.GetOrder: Integer;
begin
  Result := Year * 10000 + Month * 100 + Day;
end;

function TDateStackDayItem.GetYear: Integer;
var
  S: string;
  P: Integer;
begin
  Result := 0;
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    P := LastDelimiter('/\', S);
    if P > 0 then
    begin
      S := System.Copy(S, 1, P - 1);
      P := LastDelimiter('/\', S);
      if P > 0 then
      begin
        S := System.Copy(S, P + 1, Length(S) - P);
        Result := StrToInt64Def(S, 0);
      end;
    end;
  end;
end;

function TDateStackDayItem.GetDisplayName: string;
begin
  Result := IntToStr(Day);
  if FCount > 0 then
    Result := Result + ' (' + IntToStr(FCount) + ')';
end;

function TDateStackDayItem.GetIsDirectory: Boolean;
begin
  Result := False;
end;

function TDateStackDayItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDateStackDayItem.Create;
end;

function TDateStackDayItem.InternalGetParent: TPathItem;
var
  S: string;
  P: Integer;
begin
  S := ExcludeTrailingPathDelimiter(FPath);
  P := LastDelimiter('/\', S);
  if P > 0 then
  begin
    S := System.Copy(S, 1, P - 1);
    Result := TDateStackMonthItem.CreateFromPath(S, PATH_LOAD_NORMAL or PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0);
    Exit;
  end;
  Result := nil;
end;

function TDateStackDayItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'DAYICON', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

{ TCalendarItem }

procedure TCalendarItem.IntCount;
begin
  Inc(FCount);
end;

procedure TCalendarItem.SetCount(Count: Integer);
begin
  FCount := Count;
end;

end.
