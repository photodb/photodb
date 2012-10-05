unit uExplorerSearchProviders;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  uMemory,
  uSysUtils,
  uPathProviders,
  uConstants,
  uStringUtils,
  uFileUtils,
  uDateUtils,
  uTranslate,
  uExplorerMyComputerProvider,
  uShellIcons,
  uExplorerFSProviders,
  uExplorerNetworkProviders;

type
  TSearchItem = class(TPathItem)
  private
    FSearchPath: string;
    FSearchTerm: string;
    function GetSearchDisplayText: string;
    function L(StringToTranslate: string): string;
  public
    procedure Assign(Item: TPathItem); override;
    function LoadImage(Options, ImageSize: Integer): Boolean; override;
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
    property SearchPath: string read FSearchPath;
    property SearchTerm: string read FSearchTerm;
    property SearchDisplayText: string read GetSearchDisplayText;
  end;

  TDBSearchItem = class(TSearchItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TFileSearchItem = class(TSearchItem)
  protected
    function InternalGetParent: TPathItem; override;
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TImageSearchItem = class(TFileSearchItem)
  protected
    function InternalCreateNewInstance: TPathItem; override;
  public
    constructor CreateFromPath(APath: string; Options, ImageSize: Integer); override;
  end;

type
  TSearchProvider = class(TPathProvider)
  public
    function Supports(Item: TPathItem): Boolean; override;
    function Supports(Path: string): Boolean; override;
    function CreateFromPath(Path: string): TPathItem; override;
  end;

type
  TDatabaseSortMode = (dsmID, dsmName, dsmRating, dsmDate, dsmFileSize, dsmImageSize, dsmComparing);

  TDatabaseSortModeHelper = record helper for TDatabaseSortMode
    function ToString: string;
    class function FromString(S: string): TDatabaseSortMode; static;
  end;

  TDatabaseSearchParameters = class(TObject)
  private
    FGroups: TStringList;
    FPersons: TStringList;
    FGroupsAnd: Boolean;
    FPersonsAnd: Boolean;
    procedure Init;
  public
    DateFrom: TDateTime;
    DateTo: TDateTime;
    RatingFrom: Byte;
    RatingTo: Byte;
    SortMode: TDatabaseSortMode;
    SortDescending: Boolean;
    Text: string;
    ShowPrivate: Boolean;
    ShowHidden: Boolean;

    constructor Create; overload;
    constructor Create(AText: string; ADateFrom, ADateTo: TDateTime; ARatingFrom, ARatingTo: Byte;
      ASortMode: TDatabaseSortMode; ASortDescending: Boolean); overload;
    destructor Destroy; override;
    function ToString: string; override;
    procedure Parse(S: string);
    property Groups: TStringList read FGroups;
    property Persons: TStringList read FPersons;
    property GroupsAnd: Boolean read FGroupsAnd write FGroupsAnd;
    property PersonsAnd: Boolean read FPersonsAnd write FPersonsAnd;
  end;

implementation

{ TSearchProvider }

function TSearchProvider.Supports(Item: TPathItem): Boolean;
begin
  Result := Item is TDBSearchItem;
  Result := Result or Supports(Item.Path);
end;

function TSearchProvider.CreateFromPath(Path: string): TPathItem;
begin
  Result := nil;
  if StartsText(cDBSearchPath, AnsiLowerCase(Path)) then
    Result := TDBSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if Pos(cFilesSearchPath, AnsiLowerCase(Path)) > 0 then
    Result := TFileSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
  if Pos(cImagesSearchPath, AnsiLowerCase(Path)) > 0 then
    Result := TImageSearchItem.CreateFromPath(Path, PATH_LOAD_NO_IMAGE, 0);
end;

function TSearchProvider.Supports(Path: string): Boolean;
begin
  Result := StartsText(cDBSearchPath, AnsiLowerCase(Path));
  Result := Result or (Pos(cImagesSearchPath, AnsiLowerCase(Path)) > 0);
  Result := Result or (Pos(cFilesSearchPath, AnsiLowerCase(Path)) > 0);
end;

{ TDBSearchItem }

constructor TDBSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search in collection for: %s', 'Path'), [SearchDisplayText]) + '...';
end;

function TDBSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TDBSearchItem.Create;
end;

function TDBSearchItem.InternalGetParent: TPathItem;
begin
  Result := THomeItem.Create;
end;

{ TFileSearchItem }

constructor TFileSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search files for: %s', 'Path'), [SearchDisplayText]) + '...';
end;

function TFileSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TFileSearchItem.Create;
end;

function TFileSearchItem.InternalGetParent: TPathItem;
begin
  if SearchPath = '' then
    Result := THomeItem.Create
  else if IsNetworkShare(SearchPath) then
    Result := TShareItem.CreateFromPath(SearchPath, PATH_LOAD_NO_IMAGE, 0)
  else if IsDrive(SearchPath) then
    Result := TDriveItem.CreateFromPath(SearchPath, PATH_LOAD_NO_IMAGE or PATH_LOAD_FAST, 0)
  else
    Result := TDirectoryItem.CreateFromPath(SearchPath, PATH_LOAD_NO_IMAGE, 0);
end;

{ TImageSearchItem }

constructor TImageSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
begin
  inherited;
  FDisplayName := Format(TA('Search files (with EXIF) for: %s', 'Path'), [SearchDisplayText]) + '...';
end;

function TImageSearchItem.InternalCreateNewInstance: TPathItem;
begin
  Result := TImageSearchItem.Create;
end;

{ TSearchItem }

function TSearchItem.L(StringToTranslate: string): string;
begin
  Result := TA(StringToTranslate, 'Path');
end;

function TSearchItem.LoadImage(Options, ImageSize: Integer): Boolean;
var
  Icon: TIcon;
begin
  F(FImage);
  FindIcon(HInstance, 'SEARCH', ImageSize, 32, Icon);
  FImage := TPathImage.Create(Icon);
  Result := True;
end;

procedure TSearchItem.Assign(Item: TPathItem);
begin
  inherited;
  FSearchPath := TSearchItem(Item).FSearchPath;
  FSearchTerm := TSearchItem(Item).FSearchTerm;
end;

constructor TSearchItem.CreateFromPath(APath: string; Options,
  ImageSize: Integer);
const
  SchemaStart = '::';
  SchemaEnd = '://';
var
  PS, PE: Integer;
begin
  inherited;
  FDisplayName := TA('Search', 'Path');
  PS := Pos(SchemaStart, APath);
  PE := PosEx(SchemaEnd, APath, PS);
  if (PS > 0) and (PE > PS) then
  begin
    FSearchPath := uStringUtils.Left(APath, PS - 1);
    FSearchTerm := uStringUtils.Right(APath, PE + Length(SchemaEnd));
  end;
  if Options and PATH_LOAD_NO_IMAGE = 0 then
    LoadImage(Options, ImageSize);
end;

function TSearchItem.GetSearchDisplayText: string;
var
  Parameters: TDatabaseSearchParameters;
  ResultList: TStringList;
  SortMode, SortDirection: string;
begin
  Parameters := TDatabaseSearchParameters.Create;
  ResultList := TStringList.Create;
  try
    Parameters.Parse(SearchTerm);
    Result := '';

    if Trim(Parameters.Text) <> '' then
      Result := '"' + Parameters.Text + '"';

    if (Parameters.RatingFrom = 0) and (Parameters.RatingTo = 5) then
    begin
      //any rating, skip
    end else if (Parameters.RatingFrom > 0) and (Parameters.RatingTo < 5) then
    begin
      //rating between
      ResultList.Add(FormatEx(L('rating between {0} and {1}'), [Parameters.RatingFrom, Parameters.RatingTo]));
    end else if (Parameters.RatingFrom > 0) then
    begin
      ResultList.Add(FormatEx(L('rating more than {0}'), [Parameters.RatingFrom]));
    end else if (Parameters.RatingTo < 5) then
    begin
      ResultList.Add(FormatEx(L('rating less than {0}'), [Parameters.RatingTo]));
    end;

    if (Parameters.DateFrom <= EncodeDate(1900, 1, 1)) and (Parameters.DateTo >= EncodeDate(2100, 1, 1)) then
    begin
      //any rating, skip
    end else if (Parameters.DateFrom > EncodeDate(1900, 1, 1)) and (Parameters.DateTo < EncodeDate(2100, 1, 1)) then
    begin
      //rating between
      ResultList.Add(FormatEx(L('date between {0} and {1}'), [FormatDateTimeShortDate(Parameters.DateFrom), FormatDateTimeShortDate(Parameters.DateTo)]));
    end else if (Parameters.DateFrom > EncodeDate(1900, 1, 1)) then
    begin
      ResultList.Add(FormatEx(L('date more than {0}'), [FormatDateTimeShortDate(Parameters.DateFrom)]));
    end else if (Parameters.DateTo < EncodeDate(2100, 1, 1)) then
    begin
      ResultList.Add(FormatEx(L('date less than {0}'), [FormatDateTimeShortDate(Parameters.DateTo)]));
    end;

    if Trim(Parameters.Persons.Text) <> '' then
      ResultList.Add(FormatEx(L('{0} on photo'), [Parameters.Persons.Join(IIF(Parameters.PersonsAnd, ' ' + L('and') + ' ', ' ' + L('or') + ' '))]));

    if Trim(Parameters.Groups.Text) <> '' then
      ResultList.Add(FormatEx(L('with groups: {0}'), [Parameters.Groups.Join(IIF(Parameters.GroupsAnd, ' ' + L('and') + ' ', ' ' + L('or') + ' '))]));

    if ResultList.Count > 0 then
      Result := ResultList.Join(', ');

    if Result = '' then
      Result := L('any photo');

    if Parameters.ShowPrivate or Parameters.ShowHidden then
    begin
      ResultList.Clear;
      if Parameters.ShowHidden then
        ResultList.Add(L('hidden'));
      if Parameters.ShowPrivate then
        ResultList.Add(L('private'));
      Result := Result + FormatEx(L(', including {0}'), [ResultList.Join(L(' ' + L('and') + ' '))]) ;
    end;

    if (Parameters.SortMode = dsmRating) and Parameters.SortDescending then
    begin
      //default sorting
    end else
    begin
      case Parameters.SortMode of
        dsmID:
          SortDirection := 'ID';
        dsmName:
          SortDirection := 'name';
        dsmRating:
          SortDirection := 'rating';
        dsmDate:
          SortDirection := 'date';
        dsmFileSize:
          SortDirection := 'file size';
        dsmImageSize:
          SortDirection := 'image size';
        dsmComparing:
          SortDirection := 'comparing';
      end;

      SortDirection := L(SortDirection);

      if not Parameters.SortDescending then
        SortMode := FormatEx(L(', sort by {0}, ascending'), [SortDirection])
      else
        SortMode := FormatEx(L(', sort by {0}, descending'), [SortDirection]);

      Result := Result + SortMode;
    end;

  finally
    F(ResultList);
    F(Parameters);
  end;
end;

{ TDatabaseSearchParameters }

constructor TDatabaseSearchParameters.Create;
begin
  Init;
end;

constructor TDatabaseSearchParameters.Create(AText: string; ADateFrom, ADateTo: TDateTime;
  ARatingFrom, ARatingTo: Byte; ASortMode: TDatabaseSortMode;
  ASortDescending: Boolean);
begin
  Init;
  Text := AText;
  DateFrom := ADateFrom;
  DateTo := ADateTo;
  RatingFrom := ARatingFrom;
  RatingTo := ARatingTo;
  SortMode := ASortMode;
  SortDescending := ASortDescending;
end;

destructor TDatabaseSearchParameters.Destroy;
begin
  F(FGroups);
  F(FPersons);
  inherited;
end;

procedure TDatabaseSearchParameters.Init;
begin
  FGroups := TStringList.Create;
  FPersons := TStringList.Create;
  Text := '';
  DateFrom := EncodeDate(1900, 1, 1);
  DateTo := EncodeDate(2100, 1, 1);
  RatingFrom := 0;
  RatingTo := 5;
  SortMode := dsmRating;
  SortDescending := True;
  ShowPrivate := False;
  ShowHidden := False;
  FGroupsAnd := False;
  FPersonsAnd := False;
end;

procedure TDatabaseSearchParameters.Parse(S: string);
var
  I: Integer;
  Parameters, Parameter: TArray<string>;
  Key, Value: string;
begin
  Parameters := S.Split([';']);
  if Length(Parameters) > 0 then
  begin
    Text := Parameters[0];
    for I := 1 to Length(Parameters) - 1 do
    begin
      Parameter := Parameters[I].Split(['=']);
      if Length(Parameter) = 2 then
      begin
        Key := Parameter[0];
        Value := Parameter[1];
        if Key = 'RatingFrom' then
          RatingFrom := StrToIntDef(Value, 0)
        else if Key = 'RatingTo' then
          RatingTo := StrToIntDef(Value, 0)
        else if Key = 'DateFrom' then
          DateFrom := DateTimeStrEval('yyyy.mm.dd', Value)
        else if Key = 'DateTo' then
          DateTo := DateTimeStrEval('yyyy.mm.dd', Value)
        else if Key = 'SortBy' then
          SortMode := TDatabaseSortMode.FromString(Value)
        else if Key = 'SortAsc' then
          SortDescending := not (Value = '1') or (Value = 'true')
        else if Key = 'Groups' then
        begin
          Groups.Clear;
          Groups.AddRange(Value.Split([',']));
        end else if Key = 'GroupsMode' then
          GroupsAnd := Value = 'and'
        else if Key = 'Persons' then
        begin
          Persons.Clear;
          Persons.AddRange(Value.Split([',']));
        end else if Key = 'PersonsMode' then
          PersonsAnd := Value = 'and'
        else if Key = 'Private' then
          ShowPrivate := (Value = '1') or (Value = 'true')
        else if Key = 'Hidden' then
          ShowHidden := (Value = '1') or (Value = 'true');
      end;
    end;
  end;
end;

function TDatabaseSearchParameters.ToString: string;
var
  Items: TStringList;
begin
  Items := TStringList.Create;
  try

    Items.Add(Text.Replace(';', ' '));
    if RatingFrom > 0 then
    Items.Add('RatingFrom=' + IntToStr(RatingFrom));
    if RatingTo < 5 then
      Items.Add('RatingTo=' + IntToStr(RatingTo));
    if DateFrom <> MinDateTime then
      Items.Add('DateFrom=' + FormatDateTime('yyyy.mm.dd', DateFrom));
    if DateTo <> MinDateTime then
      Items.Add('DateTo=' + FormatDateTime('yyyy.mm.dd', DateTo));
    if SortMode <> dsmRating then
      Items.Add('SortBy=' + SortMode.ToString);
    if not SortDescending then
      Items.Add('SortAsc=1');
    if Groups.Count > 0 then
    begin
      Items.Add('Groups=' + Groups.Join(','));
      Items.Add('GroupsMode=' + IIF(GroupsAnd, 'and', 'or'));
    end;
    if Persons.Count > 0 then
    begin
      Items.Add('Persons=' + Persons.Join(','));
      Items.Add('PersonsMode=' + IIF(PersonsAnd, 'and', 'or'));
    end;

    if ShowPrivate then
      Items.Add('Private=1');
    if ShowHidden then
      Items.Add('Hidden=1');

    Result := Items.Join(';');
  finally
    F(Items);
  end;
end;

{ TDatabaseSortModeHelper }

class function TDatabaseSortModeHelper.FromString(S: string): TDatabaseSortMode;
begin
  if S = 'ID' then
    Exit(dsmID);
  if S = 'Name' then
    Exit(dsmName);
  if S = 'Rating' then
    Exit(dsmRating);
  if S = 'Date' then
    Exit(dsmDate);
  if S = 'FileSize' then
    Exit(dsmFileSize);
  if S = 'ImageSize' then
    Exit(dsmImageSize);
  if S = 'Comparing' then
    Exit(dsmComparing);

  Exit(dsmRating);
end;

function TDatabaseSortModeHelper.ToString: string;
begin
  Result := '';
  case Self of
    dsmID:
      Exit('ID');
    dsmName:
      Exit('Name');
    dsmRating:
      Exit('Rating');
    dsmDate:
      Exit('Date');
    dsmFileSize:
      Exit('FileSize');
    dsmImageSize:
      Exit('ImageSize');
    dsmComparing:
      Exit('Comparing');
  end;
end;

initialization
  PathProviderManager.RegisterProvider(TSearchProvider.Create);

end.
