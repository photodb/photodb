unit uExplorerDateStackProviders;

interface

uses
  uConstants,
  uMemory,
  SysUtils,
  Graphics,
  StrUtils,
  uShellIcons,
  uTranslate,
  uExplorerPathProvider,
  uExplorerMyComputerProvider,
  uPathProviders,
  uDateUtils,
  uSysUtils,
  DB,
  CommonDBSupport;

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

  TDateStackYearItem = class(TPathItem)
  private
    FCount: Integer;
    function GetYear: Integer;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
  public
    procedure SetCount(Count: Integer);
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Year: Integer read GetYear;
  end;

  TDateStackMonthItem = class(TPathItem)
  private
    FCount: Integer;
    function GetMonth: Integer;
    function GetYear: Integer;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
  public
    procedure SetCount(Count: Integer);
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Month: Integer read GetMonth;
    property Year: Integer read GetYear;
  end;

  TDateStackDayItem = class(TPathItem)
  private
    FCount: Integer;
    function GetDay: Integer;
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
    function GetDisplayName: string; override;
  public
    procedure SetCount(Count: Integer);
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property Day: Integer read GetDay;
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
begin
  Result := nil;
  if StartsText(cDatesPath, AnsiLowerCase(Path)) then
    Result := TDateStackItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TExplorerDateStackProvider.GetTranslateID: string;
begin
  Result := 'ExplorerDateProvider';
end;

function Capitalize(const S: string): string;
begin
  Result := S;
  if Length(Result) > 0 then
    Result[1] := UpCase(Result[1]);
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
  FDateRangeDS: TDataSet;
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
      SetSQL(FDateRangeDS, 'SELECT Year(DateToAdd) as "GroupYear", Count(1) as ItemCount FROM (select DateToAdd from ImageTable where DateToAdd > 1900 and IsDate = True ) Group BY Year(DateToAdd) Order by "GroupYear" desc');

      FDateRangeDS.Active := True;

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

  if Item is TDateStackYearItem then
  begin
    YI := TDateStackYearItem(Item);

    FDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FDateRangeDS);
      SetSQL(FDateRangeDS, 'SELECT Month(DateToAdd) as "GroupMonth", Count(1) as ItemCount FROM (select DateToAdd from ImageTable where DateToAdd > 1900 and IsDate = True and Year(DateToAdd) = ' + IntToStr(YI.Year) + ') Group BY Month(DateToAdd) Order by "GroupMonth" desc');

      FDateRangeDS.Active := True;

      while not FDateRangeDS.EOF do
      begin
        Month := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        MI := TDateStackMonthItem.CreateFromPath(cDatesPath + '\' + IntToStr(YI.Year) + '\' + IntToStr(Month), Options, ImageSize);
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
      SetSQL(FDateRangeDS, 'SELECT Day(DateToAdd) as "GroupDay", Count(1) as ItemCount FROM (select DateToAdd from ImageTable where DateToAdd > 1900 and IsDate = True and Year(DateToAdd) = ' + IntToStr(MI.Year) + ' and Month(DateToAdd) = ' + IntToStr(MI.Month) + ') Group BY Day(DateToAdd) Order by "GroupMonth" desc');

      FDateRangeDS.Active := True;

      while not FDateRangeDS.EOF do
      begin
        Day := FDateRangeDS.Fields[0].AsInteger;
        Count := FDateRangeDS.Fields[1].AsInteger;

        DI := TDateStackDayItem.CreateFromPath(cDatesPath + '\' + IntToStr(MI.Year) + '\' + IntToStr(MI.Month) + '\' + IntToStr(Day), Options, ImageSize);
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
begin
  Result := TDateStackItem.CreateFromPath(cDatesPath, Options, ImageSize);
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

procedure TDateStackYearItem.SetCount(Count: Integer);
begin
  FCount := Count;
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
    S := System.Copy(S, P - 1);
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

procedure TDateStackMonthItem.SetCount(Count: Integer);
begin
  FCount := Count;
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
    S := System.Copy(S, P - 1);
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

procedure TDateStackDayItem.SetCount(Count: Integer);
begin
  FCount := Count;
end;

initialization
  PathProviderManager.RegisterProvider(TExplorerDateStackProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TExplorerDateStackProvider);

end.
