unit uDatabaseSearch;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Math,
  Winapi.Windows,
  Data.DB,
  Data.Win.ADODB,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,

  Dmitry.Utils.System,

  UnitDBDeclare,
  GraphicCrypt,

  uMemory,
  uConstants,
  uDBBaseTypes,
  uDBUtils,
  uDBConnection,
  uDBContext,
  uDBEntities,
  uDBManager,
  uStringUtils,
  uTranslate,
  uJpegUtils,
  uBitmapUtils,
  uAssociatedIcons,
  uThreadEx,
  uPeopleRepository,
  uAssociations,
  uSessionPasswords,
  uSearchQuery;

const
  SM_ID         = 0;
  SM_TITLE      = 1;
  SM_DATE_TIME  = 2;
  SM_RATING     = 3;
  SM_FILE_SIZE  = 4;
  SM_IMAGE_SIZE = 5;
  SM_COMPARING  = 6;

type
  TScanFileParams = class
  public
    ScanFileName: string;
    ScanRotation: Boolean;
    ScanPercent: Extended;
  end;

type
  TDBParam = class(TObject)
  private
    FName: string;
  public
    property Name: string read FName write FName;
  end;

  TDBStringParam = class(TDBParam)
    Value: string;
  end;

  TDBIntegerParam = class(TDBParam)
    Value: Integer;
  end;

  TDBDateTimeParam = class(TDBParam)
    Value: TDateTime;
  end;

  TQueryType = (
    QT_TEXT
    //QT_W_SCAN_FILE //unsupported :(
  );

  TDBQueryParams = class(TObject)
  private
    FParamList: TList;
    FQuery: string;
    FQueryType: TQueryType;
    FCanBeEstimated: Boolean;
    FData: TObject;
  public
    function AddDateTimeParam(Name: string; Value: TDateTime) : TDBDateTimeParam;
    function AddIntParam(Name: string; Value: Integer) : TDBIntegerParam;
    function AddStringParam(Name: string; Value: string) : TDBStringParam;
    constructor Create;
    destructor Destroy; override;
    procedure ApplyToDS(DS: TDataSet);
    property Query: string read FQuery write FQuery;
    property QueryType: TQueryType read FQueryType write FQueryType;
    property CanBeEstimated: Boolean read FCanBeEstimated write FCanBeEstimated;
    property Data: TObject read FData;
  end;

  TDatabaseSearch = class;

  TEstimateCountUpdateHandler = procedure(Sender: TDatabaseSearch; Count: Integer) of object;
  TGetFilePasswordHandler = function(Sender: TDatabaseSearch; FileName: string): string of object;
  TTextMessageHandler = procedure(Sender: TDatabaseSearch; Text: string) of object;
  TProgressHandler = procedure(Sender: TDatabaseSearch; Progress: Extended) of object;
  TPacketHandler = procedure(Sender: TDatabaseSearch; Packet: TMediaItemCollection) of object;

  TDatabaseSearch = class(TObject)
  private
    FDBContext: IDBContext;
    FPeopleRepository: IPeopleRepository;
    FMediaRepository: IMediaRepository;
    FSearchParams: TSearchQuery;
    FCurrentQueryType: TQueryType;
    FOwner: TThreadEx;
    FOnEstimateCountUpdate: TEstimateCountUpdateHandler;
    FOnGetFilePassword: TGetFilePasswordHandler;
    FOnError: TTextMessageHandler;
    FOnProgress: TProgressHandler;
    FOnPacketReady: TPacketHandler;
    procedure AddItem(S: TDataSet);
    function CreateQuery: TDBQueryParams;
    procedure ApplyFilter(Params: TDBQueryParams; Attr: Integer);
    procedure AddWideSearchOptions(Params: TDBQueryParams);
    function AddSorting(SqlParams: TDBQueryParams): string;
    procedure LoadImages;
    procedure LoadTextQuery(QueryParams: TDBQueryParams);
  protected
    FData: TMediaItemCollection;
    FQData: TMediaItemCollection;
  public
    constructor Create(AOwner: TThreadEx; ASearchParams: TSearchQuery);
    destructor Destroy; override;
    procedure ExecuteSearch;
    property SearchParams: TSearchQuery read FSearchParams;
    property CurrentQueryType: TQueryType read FCurrentQueryType;
    property OnEstimateCountUpdate: TEstimateCountUpdateHandler read FOnEstimateCountUpdate write FOnEstimateCountUpdate;
    property OnGetFilePassword: TGetFilePasswordHandler read FOnGetFilePassword write FOnGetFilePassword;
    property OnError: TTextMessageHandler read FOnError write FOnError;
    property OnProgress: TProgressHandler read FOnProgress write FOnProgress;
    property OnPacketReady: TPacketHandler read FOnPacketReady write FOnPacketReady;
  end;

implementation

{ TDBQueryParams }

function TDBQueryParams.AddDateTimeParam(Name: string; Value: TDateTime) : TDBDateTimeParam;
begin
  Result := TDBDateTimeParam.Create;
  Result.Name := Name;
  Result.Value := Value;
  FParamList.Add(Result);
end;

function TDBQueryParams.AddIntParam(Name: string;
  Value: Integer): TDBIntegerParam;
begin
  Result := TDBIntegerParam.Create;
  Result.Name := Name;
  Result.Value := Value;
  FParamList.Add(Result);
end;

function TDBQueryParams.AddStringParam(Name, Value: string): TDBStringParam;
begin
  Result := TDBStringParam.Create;
  Result.Name := Name;
  Result.Value := Value;
  FParamList.Add(Result);
end;

procedure TDBQueryParams.ApplyToDS(DS: TDataSet);
var
  I : Integer;
  Paramert : TParameter;
  DBParam : TDBParam;
begin
  SetSQL(DS, Query);
  for I := 0 to FParamList.Count - 1 do
  begin
    DBParam := FParamList[I];
    Paramert := nil;
    if DS is TADOQuery then
      Paramert := TADOQuery(DS).Parameters.FindParam(DBParam.name);
    if Paramert <> nil then
    begin
      if DBParam is TDBDateTimeParam then
        Paramert.Value := TDBDateTimeParam(DBParam).Value;
      if DBParam is TDBIntegerParam then
        Paramert.Value := TDBIntegerParam(DBParam).Value;
      if DBParam is TDBStringParam then
        Paramert.Value := TDBStringParam(DBParam).Value;
    end;
  end;
end;

constructor TDBQueryParams.Create;
begin
  FParamList := TList.Create;
  FQueryType := QT_TEXT;
  FCanBeEstimated := True;
  FData := nil;
end;

destructor TDBQueryParams.Destroy;
begin
  FreeList(FParamList);
  F(FData);
  inherited;
end;

{ TDatabaseSearch }

constructor TDatabaseSearch.Create(AOwner: TThreadEx; ASearchParams: TSearchQuery);
begin
  FDBContext := DBManager.DBContext;
  FPeopleRepository := FDBContext.People;
  FMediaRepository := FDBContext.Media;
  FCurrentQueryType := QT_TEXT;
  FSearchParams := ASearchParams;
  FOwner := AOwner;
end;

destructor TDatabaseSearch.Destroy;
begin
  F(FSearchParams);
  FDBContext := nil;
  FPeopleRepository := nil;
  inherited;
end;

function TDatabaseSearch.CreateQuery: TDBQueryParams;
var
  Folder, SysAction, Stemp, S1, S, Sqltext: string;
  A, B, C, N, I, J, Id, Left, L, M: Integer;
  Sqlwords, Sqlrwords: TStrings;
  SystemQuery, First: Boolean;
  Fields_names: array [1 .. 10] of string;
  Fields_names_count: Integer;
  FSpecQuery: TDataSet;
  Sid: string;
  ScanParams: TScanFileParams;
  ImThs: TArStrings;
  IthIds: TArInteger;
  PersonIDsSum: Integer;
  PersonsJoin, TempString, HavingSQL, PersonIdsConcat: string;
  Persons: TPersonCollection;
  PersonNames: TStringList;
const
  AllocImThBy = 5;

  procedure AddField(FieldName: string);
  begin
    Inc(Fields_names_count);
    Fields_names[Fields_names_count] := FieldName;
  end;

  //First({0})
  function AllFields(Expr: string = '{0}'): string;
  var
    I: Integer;
    FieldList: TStringList;
  begin

    FieldList := TStringList.Create;
    try
      FieldList.Add('Access');
      FieldList.Add('Attr');
      FieldList.Add('Comment');
      FieldList.Add('DateToAdd');
      FieldList.Add('FFileName');
      FieldList.Add('FileSize');
      FieldList.Add('Groups');
      FieldList.Add('Height');
      FieldList.Add('ID');
      FieldList.Add('Include');
      FieldList.Add('IsDate');
      FieldList.Add('IsTime');
      FieldList.Add('Keywords');
      FieldList.Add('Links');
      FieldList.Add('StrTh');
      FieldList.Add('Name');
      FieldList.Add('Rating');
      FieldList.Add('Rotated');
      FieldList.Add('thum');
      FieldList.Add('aTime');
      FieldList.Add('Width');

      for I := 0 to FieldList.Count - 1 do
        FieldList[I] := FormatEx(Expr, [FieldList[I]]);

      Result := FieldList.Join(',');
    finally
     F(FieldList);
    end;
  end;

  function FIELDS: string;
  begin
    if FSearchParams.IsEstimate then
      Result := 'COUNT(*)'
    else
      Result := 'TOP 1000 *';
  end;

begin
  Result := TDBQueryParams.Create;
  SqlText := FSearchParams.Query;
  if SqlText = '' then
    SqlText := '*';
  SystemQuery := False;

  if Length(SqlText) > 3 then
    if (SqlText[1] = '%') and (SqlText[2] = ':') and (SqlText[Length(SqlText)] = ':') then
      Delete(SqlText, 1, 1);

  if Length(SqlText) > 2 then
    if (Sqltext[1] = ':') and (Sqltext[Length(Sqltext)] = ':') then
    begin
      SysAction := Copy(Sqltext, 2, Length(Sqltext) - 2);

      if AnsiLowerCase(Sysaction) = AnsiLowerCase('DeletedFiles') then
      begin
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_not_exists);
      end;

      if AnsiLowerCase(Sysaction) = AnsiLowerCase('Duplicates') then
      begin
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_duplicate);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 5)) = AnsiLowerCase('Links') then
      begin
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' where (Links like "%[%]%{%}%;%" )';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 7)) = AnsiLowerCase('KeyWord') then
      begin
        SystemQuery := True;
        Stemp := Copy(Sysaction, 9, Length(Sysaction) - 9);
        Stemp := NormalizeDBString('%' + Stemp + '%');
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' where (KeyWords like ' + Stemp + ') ';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 5)) = AnsiLowerCase('Group') then
      begin
        SystemQuery := True;
        Stemp := TGroup.GroupSearchByGroupName(Copy(Sysaction, 7, Length(Sysaction) - 7));
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' WHERE (Groups LIKE "' + Stemp + '")';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 6)) = AnsiLowerCase('Person') then
      begin
        SystemQuery := True;
        Stemp := Copy(Sysaction, 8, Length(Sysaction) - 8);
        PersonsJoin := FormatEx(' INNER JOIN {1} PM on PM.ImageID = IM.ID) INNER JOIN {0} P on P.ObjectID = PM.ObjectID', [ObjectTableName, ObjectMappingTableName]);

        Result.Query := Format('SELECT %s FROM ($DB$ IM %s', [FIELDS, PersonsJoin]);
        Result.Query := Result.Query + ' WHERE (trim(P.ObjectName) like ' + NormalizeDBString(NormalizeDBStringLike(Stemp)) + ')';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 6)) = AnsiLowerCase('folder') then
      begin
        Systemquery := True;

        Folder := Copy(Sysaction, 8, Length(Sysaction) - 8);
        if StrToIntDef(Folder, -1) <> -1 then
          Folder := ExtractFileDir(FMediaRepository.GetFileNameById(StrToInt(Folder)));

        Folder := IncludeTrailingBackslash(Folder);

        Result.Query := Format('Select %s From $DB$ WHERE FolderCRC = :CRC', [FIELDS]);
        Result.AddIntParam('CRC', GetPathCRC(Folder, False));
        if not FSearchParams.ShowPrivate then
          Result.Query := Result.Query + ' and (Access<>' + Inttostr(Db_access_private) + ')';

        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 7)) = AnsiLowerCase('similar') then
      begin
        Systemquery := True;
        Sid := Copy(Sysaction, 9, Length(Sysaction) - 9);
        Id := StrToIntDef(Sid, 0);

        FSpecQuery := FDBContext.CreateQuery(dbilRead);
        try
          SetSQL(FSpecQuery, 'SELECT StrTh FROM $DB$ WHERE ID = ' + IntToStr(Id));
          FSpecQuery.Open;
          TempString := FSpecQuery.FieldByName('StrTh').AsString;
        finally
          FreeDS(FSpecQuery);
        end;

        Result.Query := Format('SELECT %s FROM $DB$ WHERE StrTh = :str', [FIELDS]);
        Result.AddStringParam('str', TempString);
        if not FSearchParams.ShowPrivate then
          Result.Query := Result.Query + ' and (Access<>' + Inttostr(Db_access_private) + ')';
      end;
    end;

  if not Systemquery then
  begin
    Result.QueryType := QT_TEXT;

    Sqltext := Sqltext.Replace('*', '%').Replace('?', '_');

    if FSearchParams.Persons.Count > 0 then
    begin
      PersonsJoin := FormatEx(' INNER JOIN {1} PM on PM.ImageID = IM.ID) INNER JOIN {0} P on P.ObjectID = PM.ObjectID', [ObjectTableName, ObjectMappingTableName]);
      Result.Query := Format('SELECT %s FROM ($DB$ IM %s', [AllFields('First(IM.{0}) as [{0}]'), PersonsJoin]);
    end else
      Result.Query := Format('SELECT %s FROM $DB$ ', [FIELDS]);

    if Sqltext[Length(Sqltext)] <> '$' then
    begin
      Fields_names_count := 0;
      Stemp := '';
      B := 0;
      Sqltext := StringReplace(Sqltext, '"', '', [rfReplaceAll]);
      Sqltext := StringReplace(Sqltext, '%', '', [rfReplaceAll]);
      Sqltext := StringReplace(Sqltext, '''', '', [rfReplaceAll]);
      A := Pos('[+', Sqltext);
      if A > 0 then
        B := PosEx(']', Sqltext, A);
      if B > 0 then
        Stemp := AnsiUpperCase(Copy(Sqltext, A + 2, B - A - 2));
      for I := Length(Stemp) downto 1 do
        if not CharInSet(Stemp[I], ['C', 'K', 'F', 'G', 'L']) then
          Delete(Stemp, I, 1);

      for J := 1 to Length(Stemp) do
        for I := 1 to Length(Stemp) - 1 do
          if Byte(Stemp[I]) < Byte(Stemp[I + 1]) then
          begin
            C := Byte(Stemp[I]);
            Stemp[I] := Stemp[I + 1];
            Stemp[I + 1] := Char(C);
          end;
      for I := Length(Stemp) - 1 downto 1 do
        if Stemp[I + 1] = Stemp[I] then
          Delete(Stemp, I + 1, 1);

      for I := 1 to Min(5, Length(Stemp)) do
      begin
        case Byte(AnsiUpperCase(Stemp)[I]) of
          Byte('C'):
            AddField('Comment');
          Byte('K'):
            AddField('KeyWords');
          Byte('F'):
            AddField('FFileName');
          Byte('G'):
            AddField('Groups');
          Byte('L'):
            AddField('Links');
        end;
      end;
      if Fields_names_count > 0 then
        Delete(Sqltext, A, B - A + 1);

      if Fields_names_count < 1 then
      begin
        Fields_names[1] := 'FFileName';
        Fields_names[2] := 'Comment';
        Fields_names[3] := 'KeyWords';
        Fields_names_count := 3;
      end;
      Sqlwords := TStringList.Create;
      Sqlrwords := TStringList.Create;
      try
        Sqltext := ' ' + Sqltext + ' ';
        for I := Length(Sqltext) downto 2 do
          if (Sqltext[I] = ' ') and (Sqltext[I - 1] = ' ') then
            Delete(Sqltext, I, 1);
        for I := 1 to Length(Sqltext) do
        begin
          if (Sqltext[I] = ' ') or (I = 1) then
            for J := I + 1 to Length(Sqltext) do
              if (Sqltext[J] = ' ') or (J = Length(Sqltext)) then
              begin
                if I = 1 then
                  Stemp := Copy(Sqltext, I + 1, J - I - 1)
                else
                  Stemp := Copy(Sqltext, I + 1, J - I - 1);
                if Length(Stemp) > 0 then
                begin
                  if Stemp[1] = '-' then
                    Sqlrwords.Add(Stemp)
                  else
                    Sqlwords.Add(Stemp);
                end
                else
                  Sqlwords.Add(Stemp);
                Break;
              end;
        end;
        if Sqlwords.Count = 0 then
          Sqlwords.Add('%');

        Sqltext := '(';
        for I := 1 to Fields_names_count do
        begin

          if (I <> 1) then
            Sqltext := Sqltext + ') or (';
          for J := 1 to Sqlwords.Count do
          begin
            Sqltext := Sqltext + Fields_names[I] + ' like "%' + Sqlwords[J - 1] + '%"';
            if (J <> Sqlwords.Count) then
              Sqltext := Sqltext + ' and ';
          end;
        end;
        Sqltext := Sqltext + ')';

        Result.Query := Result.Query + Format(' where %s and (%s)',
          [Format(' ((Rating >= %d) AND (Rating <= %d)) ', [FSearchParams.RatingFrom, FSearchParams.RatingTo]),
          Sqltext]);

        if FSearchParams.GroupsWhere <> '' then
          Result.Query := Result.Query + FormatEx(' AND ({0})', [FSearchParams.GroupsWhere]);

        if FSearchParams.PersonsWhereOr <> '' then
          Result.Query := Result.Query + FormatEx(' AND ({0})', [FSearchParams.PersonsWhereOr]);

        if FSearchParams.ColorsWhere <> '' then
          Result.Query := Result.Query + FormatEx(' AND ({0})', [FSearchParams.ColorsWhere]);

        if Sqlrwords.Count > 0 then
        begin
          Result.Query := Result.Query + ' AND not (';
          Sqltext := '(';
          for I := 1 to Fields_names_count do
          begin
            if (I <> 1) then
              Sqltext := Sqltext + ') or (';
            for J := 1 to Sqlrwords.Count do
            begin
              Stemp := Sqlrwords[J - 1];
              Delete(Stemp, 1, 1);
              Sqltext := Sqltext + '' + Fields_names[I] + ' like "%' + Stemp + '%"';
              if (J <> Sqlrwords.Count) then
                Sqltext := Sqltext + ' or ';
            end;
          end;
          Sqltext := Sqltext + ')';
          Result.Query := Result.Query + Sqltext + ')';
        end;

      finally
        F(Sqlwords);
        F(Sqlrwords);
      end;
    end else
    begin
      Sqltext := '(';
      S := FSearchParams.Query;
      for I := Length(S) downto 1 do
        if not CharInSet(S[I], Cifri) and (S[I] <> '$') then
          Delete(S, I, 1);
      if Length(S) < 2 then
        Exit;
      N := 1;
      for I := 1 to Length(S) do
        if S[I] = '$' then
        begin
          S1 := Copy(S, N, I - N);
          N := I + 1;
          Sqltext := Sqltext + ' (ID=' + S1 + ') OR';
        end;
      Sqltext := Sqltext + ' (ID=0))';

      Result.Query := Result.Query + ' where (' + Sqltext + ')';

      if FSearchParams.GroupsWhere <> '' then
        Result.Query := Result.Query + FormatEx(' AND ({0})', [FSearchParams.GroupsWhere]);

      if FSearchParams.PersonsWhereOr <> '' then
        Result.Query := Result.Query + FormatEx(' AND ({0})', [FSearchParams.PersonsWhereOr]);
    end;
    ApplyFilter(Result, Db_attr_norm);

    if not FSearchParams.ShowAllImages then
      Result.Query := Result.Query + ' and (Include = TRUE) ';
  end;

  if (Result.QueryType = QT_TEXT) and (FSearchParams.Persons.Count > 0) then
  begin
    PersonNames := TStringList.Create;
    try
      for I := 0 to FSearchParams.Persons.Count - 1 do
        PersonNames.Add(NormalizeDBString(NormalizeDBStringLike(FSearchParams.Persons[I])));

      Persons := FPeopleRepository.GetPersonsByNames(PersonNames);
      try
        PersonIDsSum := 0;
        for I := 0 to Persons.Count - 1 do
        begin
          PersonIDsSum := PersonIDsSum + Persons[I].ID;
          PersonIdsConcat := PersonIdsConcat + IntToStr(Persons[I].ID);

          if I < Persons.Count - 1 then
            PersonIdsConcat := PersonIdsConcat + ',';
        end;

        HavingSQL := '';
        if FSearchParams.PersonsAnd then
          HavingSQL := FormatEx('having (SUM(P.ObjectID) = {0}  and Count(*) = {1} and SUM(P.CreateDate) = (select SUM(CreateDate) from Objects O where O.ObjectID in ({2})))',
            [PersonIDsSum, FSearchParams.Persons.Count, PersonIdsConcat]);

        Result.Query := FormatEx('SELECT * FROM ({0} Group by IM.ID {1})', [Result.Query, HavingSQL]);
      finally
        F(Persons);
      end;
    finally
      F(PersonNames);
    end;
  end;

  Result.Query :=  Result.Query + AddSorting(Result);

  if (Result.QueryType = QT_TEXT) and FSearchParams.IsEstimate then
    Result.Query := FormatEx('SELECT COUNT(*) FROM ({0})', [Result.Query]);
end;

procedure TDatabaseSearch.ApplyFilter(Params: TDBQueryParams; Attr: Integer);
begin
  case Attr of
    db_attr_norm:
      Params.Query := Params.Query + Format(' AND (Attr <> %d)',[db_attr_not_exists]);
    db_attr_duplicate:
      Params.Query := Params.Query + Format(' (Attr = %d)', [db_attr_duplicate]);
    db_attr_not_exists:
      Params.Query := Params.Query + Format(' (Attr = %d)', [db_attr_not_exists]);
  end;

  if not FSearchParams.ShowPrivate then
    Params.Query := Params.Query + ' AND (Access = 0)';

  AddWideSearchOptions(Params);
end;

procedure TDatabaseSearch.AddWideSearchOptions(Params : TDBQueryParams);
var
  Result: string;
begin
  Result := '';

  Result := Result + ' AND ((Rating>=' + IntToStr(FSearchParams.RatingFrom) + ') and (Rating<=' + IntToStr
    (FSearchParams.RatingTo) + ')) ';

  Result := Result + ' AND ((DateToAdd >= :MinDate ) and (DateToAdd < :MaxDate ) and IsDate=True) ';

  Params.AddDateTimeParam('MinDate', Trunc(FSearchParams.DateFrom));
  Params.AddDateTimeParam('MaxDate', Trunc(FSearchParams.DateTo) + 1);

  if not FSearchParams.ShowPrivate then
    Result := Result + ' AND (Access = 0)';

  Result := Result + ' AND (Attr<>' + Inttostr(Db_attr_not_exists) + ')';

  Params.Query := Params.Query + Result;
end;

function TDatabaseSearch.AddSorting(SqlParams: TDBQueryParams): string;
var
  SortDirection: string;

begin
  Result := '';
  if not FSearchParams.IsEstimate then
  begin
    SortDirection := '';
    if FSearchParams.SortDecrement then
      SortDirection := ' DESC';

    case FSearchParams.SortMethod of
      SM_TITLE:      Result := ' ORDER BY Name'           + SortDirection;
      SM_DATE_TIME:  Result := ' ORDER BY DateToAdd'      + SortDirection + ', aTime' + SortDirection;
      SM_RATING:     Result := ' ORDER BY Rating'         + SortDirection + ', DateToAdd desc, aTime desc';
      SM_FILE_SIZE:  Result := ' ORDER BY FileSize'       + SortDirection;
      SM_IMAGE_SIZE: Result := ' ORDER BY (Width*Height)' + SortDirection + ', Rating, DateToAdd desc, aTime desc' + SortDirection;
    else
                     Result := ' ORDER BY ID'             + SortDirection;
    end;
  end;
end;

procedure TDatabaseSearch.LoadImages;
var
  QueryParams: TDBQueryParams;

begin
  QueryParams := CreateQuery;
  try
    FCurrentQueryType := QueryParams.QueryType;
    if FSearchParams.IsEstimate and not QueryParams.CanBeEstimated then
    begin
      if Assigned(FOnEstimateCountUpdate) then
        FOnEstimateCountUpdate(Self, -1);
    end;

    if QueryParams.QueryType = QT_TEXT then
      LoadTextQuery(QueryParams);

  finally
    F(QueryParams);
  end;
end;

procedure TDatabaseSearch.AddItem(S: TDataSet);
var
  I: Integer;
  SearchData: TMediaItem;
  SearchExtension: TSearchDataExtension;
  JPEG: TJPEGImage;
  PassWord: string;
  BS: TStream;
begin
  SearchData := TMediaItem.CreateFromDS(S);
  SearchExtension := TSearchDataExtension.Create;
  SearchData.Data := SearchExtension;
  FData.Add(SearchData);
  SearchData.ReadExists;
  if FQData.Count > 0 then
  begin
    for I := 0 to FQData.Count - 1 do
    if FQData[I].ID = SearchData.ID then
      SearchExtension.CompareResult:= TSearchDataExtension(FQData[I].Data).CompareResult;
  end;

  JPEG := TJPEGImage.Create;
  try
    if SearchData.Encrypted then
    begin
      PassWord := SessionPasswords.FindForBlobStream(S.FieldByName('thum'));
      if PassWord <> '' then
        DeCryptBlobStreamJPG(S.FieldByName('thum'), PassWord, JPEG);
    end else
    begin
      BS := GetBlobStream(S.FieldByName('thum'), bmRead);
      try
        JPEG.LoadFromStream(BS);
      finally
        F(BS);
      end;
    end;
    if not JPEG.Empty then
    begin
      SearchExtension.Bitmap := TBitmap.Create;
      SearchExtension.Bitmap.PixelFormat := pf24bit;
      AssignJpeg(SearchExtension.Bitmap, JPEG);
      ApplyRotate(SearchExtension.Bitmap, SearchData.Rotation);
      if FSearchParams.PictureSize <> 0 then
        CenterBitmap24To32ImageList(SearchExtension.Bitmap, FSearchParams.PictureSize);
    end else
      SearchExtension.Icon := TAIcons.Instance.GetIconByExt(SearchData.FileName, False, 48, False);
  finally
    F(JPEG);
  end;
end;

procedure TDatabaseSearch.LoadTextQuery(QueryParams: TDBQueryParams);
var
  FWorkQuery: TDataSet;
  EstimateCount: Integer;
  FLastPacketTime: Cardinal;
begin
  if Assigned(OnProgress) then
    OnProgress(Self, -1);

  FWorkQuery := FDBContext.CreateQuery(dbilRead);
  try

    if not FSearchParams.IsEstimate then
      ForwardOnlyQuery(FWorkQuery);

    QueryParams.Query := QueryParams.Query.Replace('''', ' ');
    QueryParams.Query := QueryParams.Query.Replace('\', ' ');
    QueryParams.ApplyToDS(FWorkQuery);

    try
      FOwner.CheckForm;
      if not FOwner.Terminated then
        FWorkQuery.Open;
    except
      on e: Exception do
      begin
        if Assigned(OnError) then
          OnError(Self, e.Message + #13 + TA('Query failed to execute!'));
        Exit;
      end;
    end;

    if not FWorkQuery.IsEmpty and not FSearchParams.IsEstimate then
    begin
      FLastPacketTime := GetTickCount;
      while not FWorkQuery.Eof do
      begin
        if FOwner.Terminated then
          Break;

        AddItem(FWorkQuery);

        if (FData.Count >= 10) or (GetTickCount - FLastPacketTime > MIN_PACKET_TIME) then
        begin
          FOnPacketReady(Self, FData);
          FData.Clear;
          FLastPacketTime := GetTickCount;
        end;
        FWorkQuery.Next;
      end;
      FOnPacketReady(Self, FData);
      FData.Clear;
    end;

    if FSearchParams.IsEstimate then
    begin
      if not FWorkQuery.IsEmpty then
        EstimateCount := FWorkQuery.Fields[0].AsInteger
      else
        EstimateCount := -1;

      if Assigned(FOnEstimateCountUpdate) then
        FOnEstimateCountUpdate(Self, EstimateCount);
    end;

  finally
    FreeDS(FWorkQuery);
  end;
end;

procedure TDatabaseSearch.ExecuteSearch;
begin
  FData := TMediaItemCollection.Create;
  FQData := TMediaItemCollection.Create;
  try
    LoadImages;
  finally
    F(FData);
    F(FQData);
  end;
end;

end.
