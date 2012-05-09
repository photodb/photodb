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
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

  TDateStackMonthItem = class(TPathItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
    function GetIsDirectory: Boolean; override;
  public
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
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
  Year, Month: Integer;
  DI: TDateStackItem;
  YI: TDateStackYearItem;
  MI: TDateStackMonthItem;
  FYearsDateRangeDS: TDataSet;
begin
  inherited;
  Result := True;
  Cancel := False;

  if Options and PATH_LOAD_ONLY_FILE_SYSTEM > 0 then
    Exit;

  if Item is THomeItem then
  begin
    DI := TDateStackItem.CreateFromPath(cDatesPath, Options, ImageSize);
    List.Add(DI);
  end;

  if Item is TDateStackItem then
  begin
    FYearsDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FYearsDateRangeDS);
      SetSQL(FYearsDateRangeDS, 'SELECT Year(DateToAdd) as "GroupYear" FROM (select DateToAdd from ImageTable where DateToAdd > 1900 and IsDate = True ) Group BY Year(DateToAdd) Order by "GroupYear" desc');

      FYearsDateRangeDS.Active := True;

      while not FYearsDateRangeDS.EOF do
      begin
        Year := FYearsDateRangeDS.Fields[0].AsInteger;

        YI := TDateStackYearItem.CreateFromPath(cDatesPath + '\' + IntToStr(Year), Options, ImageSize);
        YI.DisplayName := IntToStr(Year);
        List.Add(YI);

        FYearsDateRangeDS.Next;
      end;
    finally
      FreeDS(FYearsDateRangeDS);
    end;
  end;

  if Item is TDateStackYearItem then
  begin
    YI := TDateStackYearItem(Item);

    FYearsDateRangeDS := GetQuery(True);
    try
      ForwardOnlyQuery(FYearsDateRangeDS);
      SetSQL(FYearsDateRangeDS, 'SELECT Month(DateToAdd) as "GroupMonth" FROM (select DateToAdd from ImageTable where DateToAdd > 1900 and IsDate = True and Year(DateToAdd) = ' + YI.DisplayName + ') Group BY Month(DateToAdd) Order by "GroupMonth" desc');

      FYearsDateRangeDS.Active := True;

      while not FYearsDateRangeDS.EOF do
      begin
        Month := FYearsDateRangeDS.Fields[0].AsInteger;

        MI := TDateStackMonthItem.CreateFromPath(cDatesPath + '\' + IntToStr(Month), Options, ImageSize);
        MI.DisplayName := Capitalize(MonthToString(Month));
        List.Add(MI);

        FYearsDateRangeDS.Next;
      end;
    finally
      FreeDS(FYearsDateRangeDS);
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

constructor TDateStackYearItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackYearItem.GetIsDirectory: Boolean;
begin
  Result := True;
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

{ TDateStackMonthItem }

constructor TDateStackMonthItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TDateStackMonthItem.GetIsDirectory: Boolean;
begin
  Result := True;
end;

function TDateStackMonthItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDateStackMonthItem.Create;
end;

function TDateStackMonthItem.InternalGetParent: TPathItem;
begin
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

initialization
  PathProviderManager.RegisterProvider(TExplorerDateStackProvider.Create);
  PathProviderManager.RegisterSubProvider(TMyComputerProvider, TExplorerDateStackProvider);

end.
