unit Loadingresults;

interface

uses
  UnitDBKernel, dolphin_db, jpeg, ComCtrls, CommCtrl, windows,
  Classes, Math, DB, SysUtils, Controls, Graphics, Dialogs, adodb,
  GraphicCrypt, forms, StrUtils, win32crc, EasyListview, DateUtils,
  UnitSearchBigImagesLoaderThread, UnitDBDeclare, UnitPasswordForm,
  UnitDBCommonGraphics, uThreadForm, uThreadEx, uLogger, UnitDBCommon,
  CommonDBSupport, uFileUtils, uTranslate, uMemory, ActiveX,
  uAssociatedIcons, uDBPopupMenuInfo, uConstants, uGraphicUtils,
  uDBBaseTypes, uDBFileTypes, uRuntime, uDBGraphicTypes, uSysUtils,
  uTime;

const
  SM_ID         = 0;
  SM_TITLE      = 1;
  SM_DATE_TIME  = 2;
  SM_RATING     = 3;
  SM_FILE_SIZE  = 4;
  SM_SIZE       = 5;
  SM_COMPARING  = 6;

type
  TScanFileParams = class
  public
    ScanFileName: string;
    ScanRotation: Boolean;
    ScanPercent: Extended;
  end;

type
  SearchThread = class(TThreadEx)
  private
    { Private declarations }
    FPictureSize: Integer;
    FErrorMsg: string;
    FSearchParams : TSearchQuery;
    StrParam : String;
    IntParam : Integer;
    ExtendedParam: Extended;
    FCurrentQueryType: TQueryType;
    procedure ErrorSQL;
    function CreateQuery : TDBQueryParams;
    procedure DoOnDone;
    procedure AddWideSearchOptions(Params : TDBQueryParams);
    procedure AddOptions(SqlParams : TDBQueryParams);
    procedure ApplyFilter(Params : TDBQueryParams; Attr : Integer);
    procedure GetPassForFile;
    procedure StartLoadingList;
    procedure SetPercentProgress(Value: Extended);
    procedure SetPercentProgressSync;
    procedure NotifySearchEnd;
  protected
    RatingParam, LastMonth, LastYear, LastRating : integer;
    FData : TDBPopupMenuInfo;
    FQData: TDBPopupMenuInfo;
    FOnDone : TNotifyEvent;
    BitmapParam : TBitmap;
    procedure Execute; override;
    procedure LoadImages;
    procedure UpdateQueryEstimateCount;
    procedure SendDataPacketToForm;
    procedure AddItem(S : TDataSet);
    procedure LoadTextQuery(QueryParams : TDBQueryParams);
    procedure DoScanSimilarFiles(QueryParams : TDBQueryParams);
    procedure NitifyEstimateStart;
    procedure NitifyEstimateEnd;
  public
    constructor Create(Sender : TThreadForm; SID : TGUID; SearchParams : TSearchQuery; OnDone : TNotifyEvent; PictureSize : integer);
    destructor Destroy; override;
  end;

const
  SPSEARCH_SHOWFOLDER = 1;
  SPSEARCH_SHOWTHFILE = 2;
  SPSEARCH_SHOWSIMILAR = 3;
  MIN_PACKET_TIME = 500;

implementation

uses
  Searching, UnitGroupsWork;

constructor SearchThread.Create(Sender : TThreadForm; SID : TGUID; SearchParams : TSearchQuery; OnDone : TNotifyEvent; PictureSize : integer);
begin
  inherited Create(Sender, SID);
  FCurrentQueryType := QT_TEXT;
  FPictureSize := PictureSize;
  LastYear := 0;
  FOnDone := OnDone;
  FSearchParams := SearchParams;
  Start;
end;

procedure SearchThread.ErrorSQL;
begin
  (ThreadForm as TSearchForm).ErrorQSL(FErrorMsg);
end;

procedure SearchThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    if FSearchParams.IsEstimate then
      SynchronizeEx(NitifyEstimateStart)
    else
      SynchronizeEx(StartLoadingList);

    try
      //#8 - invalid query identify, needed from script executing
      if FSearchParams.Query = #8 then
        Exit;

      FData := TDBPopupMenuInfo.Create;
      FQData := TDBPopupMenuInfo.Create;
      try
        LoadImages;
      finally
        F(FData);
        F(FQData);
      end;
    finally
      if not FSearchParams.IsEstimate then
      begin
        SynchronizeEx(NotifySearchEnd);
        SynchronizeEx(DoOnDone);
      end else
        SynchronizeEx(NitifyEstimateEnd);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure SearchThread.ApplyFilter(Params : TDBQueryParams; Attr : Integer);
begin
  case Attr of
    db_attr_norm:
      Params.Query := Params.Query + Format(' AND (Attr <> %d)',[db_attr_not_exists]);
    db_attr_dublicate:
      Params.Query := Params.Query + Format(' AND (Attr = %d)', [db_attr_dublicate]);
    db_attr_not_exists:
      Params.Query := Params.Query + Format('(Attr = %d)', [db_attr_not_exists]);
  end;

  if not FSearchParams.ShowPrivate then
    Params.Query := Params.Query + ' AND (Access = 0)';

  AddWideSearchOptions(Params);
end;

function SearchThread.CreateQuery : TDBQueryParams;
var
  Folder, SysAction, Stemp, S1, S, Sqltext: string;
  A, B, C, N, I, J, Id, Left, L, M: Integer;
  Sqlwords, Sqlrwords: TStrings;
  Systemquery, First: Boolean;
  Fields_names: array [1 .. 10] of string;
  Fields_names_count: Integer;
  FSpecQuery: TDataSet;
  Sid: string;
  ScanParams: TScanFileParams;
  ImThs: TArStrings;
  IthIds: TArInteger;
  TempString: string;
const
  AllocImThBy = 5;

  procedure AddField(FieldName: string);
  begin
    Inc(Fields_names_count);
    Fields_names[Fields_names_count] := FieldName;
  end;

  function FIELDS: string;
  begin
    if FSearchParams.IsEstimate then
      Result := 'COUNT(*)'
    else
      Result := '*';
  end;

begin
  Result := TDBQueryParams.Create;
  SqlText := FSearchParams.Query;
  if SqlText = '' then
    SqlText := '*';
  Systemquery := False;

  if Length(SqlText) > 3 then
    if (SqlText[1] = '%') and (SqlText[2] = ':') and (SqlText[Length(SqlText)] = ':') then
      Delete(SqlText, 1, 1);

  if Length(SqlText) > 2 then
    if (Sqltext[1] = ':') and (Sqltext[Length(Sqltext)] = ':') then
    begin
      Sysaction := Copy(Sqltext, 2, Length(Sqltext) - 2);

      if AnsiLowerCase(Sysaction) = AnsiLowerCase('DeletedFiles') then
      begin
        Systemquery := True;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_not_exists);
      end;

      if AnsiLowerCase(Sysaction) = AnsiLowerCase('Dublicates') then
      begin
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_dublicate);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 5)) = AnsiLowerCase('Links') then
      begin
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' where (Links like "%[%]%{%}%;%" )';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 9)) = AnsiLowerCase('ScanImage') then
      begin
        ScanParams := TScanFileParams.Create;
        Result.Data := ScanParams;

        ScanParams.ScanRotation := False;
        Result.QueryType := QT_W_SCAN_FILE;
        Result.CanBeEstimated := False;
        S := Copy(Sysaction, 11, Length(Sysaction) - 11);
        if PosEx(':', S, 3) = -1 then
        begin
          ScanParams.ScanPercent := 50;
          ScanParams.ScanFileName := S;
        end else
        begin
          Stemp := Copy(S, 1, PosEx(':', S, 3) - 1);
          ScanParams.ScanFileName := Stemp;
          Stemp := Copy(S, PosEx(':', S, 3) + 1, Length(S) - PosEx(':', S, 3));
          ScanParams.ScanPercent := Min(100, Max(0.0000000001, StrToFloatDef(Stemp, 50)));
        end;

        SystemQuery := True;
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 10)) = AnsiLowerCase('ScanImageW') then
      begin
        ScanParams := TScanFileParams.Create;
        Result.Data := ScanParams;

        ScanParams.ScanRotation := True;
        Result.QueryType := QT_W_SCAN_FILE;
        Result.CanBeEstimated := False;
        S := Copy(Sysaction, 12, Length(Sysaction) - 12);
        if PosEx(':', S, 3) = -1 then
        begin
          ScanParams.ScanPercent := 50;
          ScanParams.ScanFileName := S;
        end else
        begin
          Stemp := Copy(S, 1, PosEx(':', S, 3) - 1);
          ScanParams.ScanFileName := Stemp;
          Stemp := Copy(S, PosEx(':', S, 3) + 1, Length(S) - PosEx(':', S, 3));
          ScanParams.ScanPercent := Min(100, Max(0.0000000001, StrToFloatDef(Stemp, 50)));
        end;
        SystemQuery := True;
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

      if AnsiLowerCase(Copy(Sysaction, 1, 6)) = AnsiLowerCase('folder') then
      begin
        Systemquery := True;

        Folder := IncludeTrailingBackslash(Copy(Sysaction, 8, Length(Sysaction) - 8));

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

        FSpecQuery := GetQuery;
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

  if AnsiLowerCase(Copy(Sysaction, 1, 8)) = AnsiLowerCase('HashFile') then
  begin
    Result.QueryType := QT_TEXT;
    Systemquery := True;
    TempString := Copy(Sysaction, 10, Length(Sysaction) - 10);
    ImThs := LoadImThsFromfileA(TempString);
    FSpecQuery := GetQuery;
    try
      SetLength(IthIds, 0);
      // AllocImThBy
      //SetMaxValue(Length(ImThs) div AllocImThBy);

      L := Length(ImThs);
      N := Trunc(L / AllocImThBy);
      if L / AllocImThBy - N > 0 then
        Inc(N);
      Left := L;
      C := 0;
      SetLength(IthIds, 0);
      for J := 1 to N do
      begin
        SQLText := 'SELECT ID FROM $DB$ WHERE ';
        M := Math.Min(Left, Math.Min(L, AllocImThBy));
        FSpecQuery.Active := False;
        for I := 1 to M do
        begin
          Dec(Left);
          Inc(C);
          SQLText := SQLText + ' (StrTh=:S' + Inttostr(C) + ') ';
          if I <> M then
            SQLText := SQLText + 'or';
        end;
        SetSQL(FSpecQuery, SQLText);
        for I := 1 to M do
          SetStrParam(FSpecQuery, I - 1, ImThs[I - 1 + AllocImThBy * (J - 1)]);
        FSpecQuery.Active := True;
        FSpecQuery.First;
        for I := 1 to FSpecQuery.RecordCount do
        begin
          SetLength(IthIds, Length(IthIds) + 1);
          IthIds[Length(IthIds) - 1] := FSpecQuery.FieldByName('ID').AsInteger;
          FSpecQuery.Next;
        end;
        //SetProgress(J - 1);
      end;
    finally
      FreeDS(FSpecQuery);
    end;
    First := True;
    Result.Query := Format('SELECT %s FROM $DB$ Where (', [FIELDS]);
    for I := 0 to Length(IthIds) - 1 do
    begin
      if First then
      begin
        Result.Query := Result.Query + ' (ID=' + IntToStr(IthIds[I]) + ') ';
        First := False;
      end else
        Result.Query := Result.Query + ' OR (ID=' + IntToStr(IthIds[I]) + ') ';
    end;
    if Length(IthIds) = 0 then
      Result.Query := Result.Query + '(ID=0) ';
    Result.Query := Result.Query + ' ) ';
    ApplyFilter(Result, Db_attr_norm);
  end;

  if not Systemquery then
  begin
    Result.QueryType := QT_TEXT;
    for I := 1 to Length(Sqltext) do
    begin
      if Sqltext[I] = '*' then
        Sqltext[I] := '%';
      if Sqltext[I] = '?' then
        Sqltext[I] := '_';
    end;
    begin
      if Sqltext[Length(Sqltext)] <> '$' then
      begin
        Fields_names_count := 0;
        Stemp := '';
        A := 0;
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

        for I := 1 to Math.Min(5, Length(Stemp)) do
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

          Result.Query := Format('SELECT %s FROM $DB$ ', [FIELDS]);
          Result.Query := Result.Query + Format(' where %s and (%s)',
            [Format(' ((Rating >= %d) AND (Rating <= %d)) ', [FSearchParams.RatingFrom, FSearchParams.RatingTo]),
            Sqltext]);

          if FSearchParams.GroupName <> '' then
            Result.Query := Result.Query + ' AND (Groups like "' + GroupSearchByGroupName(FSearchParams.GroupName) + '")';

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
        Result.Query := Format('SELECT %s FROM $DB$ ', [FIELDS]);
        Result.Query := Result.Query + ' where (' + Sqltext + ')';

        if FSearchParams.GroupName <> '' then
          Result.Query := Result.Query + ' AND (Groups like "' + GroupSearchByGroupName(FSearchParams.GroupName) + '")';
      end;
      ApplyFilter(Result, Db_attr_norm);
    end;
  end;

  AddOptions(Result);
end;

destructor SearchThread.Destroy;
begin
  F(FSearchParams);
  inherited;
end;

procedure SearchThread.DoOnDone;
begin
  //Loading big images
  if FPictureSize <> ThImageSize then
    (ThreadForm as TSearchForm).ReloadBigImages
  else
    if Assigned(FOnDone) then
      FOnDone(Self);

  (ThreadForm as TSearchForm).StopLoadingList;
  if FCurrentQueryType = QT_W_SCAN_FILE then
  begin
    (ThreadForm as TSearchForm).DoSetSearchByComparing;
    (ThreadForm as TSearchForm).Decremect1.Checked := True;
    (ThreadForm as TSearchForm).SortbyCompare1Click((ThreadForm as TSearchForm).SortbyCompare1);
  end else
  begin
    if (ThreadForm as TSearchForm).SortbyCompare1.Checked then
      (ThreadForm as TSearchForm).SortbyDate1Click((ThreadForm as TSearchForm).SortbyDate1);
  end;

end;

procedure SearchThread.AddWideSearchOptions(Params : TDBQueryParams);
var
  Result: string;
begin
  Result := '';

  Result := Result + ' AND ((Rating>=' + IntToStr(FSearchParams.RatingFrom) + ') and (Rating<=' + IntToStr
    (FSearchParams.RatingTo) + ')) ';

  Result := Result + ' AND ((DateToAdd >= :MinDate ) and (DateToAdd <= :MaxDate ) and IsDate=True) ';

  Params.AddDateTimeParam('MinDate', Trunc(FSearchParams.DateFrom));
  Params.AddDateTimeParam('MaxDate', Trunc(FSearchParams.DateTo) + 1);

  if not FSearchParams.ShowPrivate then
    Result := Result + ' AND (Access = 0)';

  Result := Result + ' AND (Attr<>' + Inttostr(Db_attr_not_exists) + ')';

  Params.Query := Params.Query + Result;
end;

procedure SearchThread.AddOptions(SqlParams : TDBQueryParams);
var
  SortDirection : string;

begin
  case SqlParams.QueryType of
    QT_TEXT:
    if not FSearchParams.ShowAllImages then
      SqlParams.Query := SqlParams.Query + ' and (Include = TRUE) ';
  end;

  if not FSearchParams.IsEstimate then
  begin
    SortDirection := '';
    if FSearchParams.SortDecrement then
      SortDirection := ' DESC';

    case FSearchParams.SortMethod of
      SM_TITLE :     SqlParams.Query := SqlParams.Query + ' ORDER BY Name'      + SortDirection;
      SM_DATE_TIME : SqlParams.Query := SqlParams.Query + ' ORDER BY DateToAdd' + SortDirection+', aTime' + SortDirection;
      SM_RATING:     SqlParams.Query := SqlParams.Query + ' ORDER BY Rating'    + SortDirection;
      SM_FILE_SIZE:  SqlParams.Query := SqlParams.Query + ' ORDER BY FileSize'  + SortDirection;
      SM_SIZE:       SqlParams.Query := SqlParams.Query + ' ORDER BY Width'     + SortDirection;
    else
                     SqlParams.Query := SqlParams.Query + ' ORDER BY ID'        + SortDirection;
    end;
  end;
end;

procedure SearchThread.GetPassForFile;
begin
  StrParam := GetImagePasswordFromUser(StrParam);
end;

procedure SearchThread.LoadImages;
var
  QueryParams: TDBQueryParams;

begin
  QueryParams := CreateQuery;
  try
    FCurrentQueryType := QueryParams.QueryType;
    if FSearchParams.IsEstimate and not QueryParams.CanBeEstimated then
    begin
      IntParam := -1;
      SynchronizeEx(UpdateQueryEstimateCount);
    end;

    if QueryParams.QueryType = QT_TEXT then
      LoadTextQuery(QueryParams);

    if QueryParams.QueryType = QT_W_SCAN_FILE then
      DoScanSimilarFiles(QueryParams);

  finally
    F(QueryParams);
  end;
end;

procedure SearchThread.LoadTextQuery(QueryParams: TDBQueryParams);
var
  FWorkQuery: TDataSet;
  Counter: Integer;
  FLastPacketTime: Cardinal;
begin
  SetPercentProgress(-1);
  FWorkQuery := GetQuery(FSearchParams.IsEstimate);
  try

    if not FSearchParams.IsEstimate then
      ForwardOnlyQuery(FWorkQuery);

    QueryParams.Query := SysUtils.StringReplace(QueryParams.Query, '''', ' ', [rfReplaceAll]);
    QueryParams.Query := SysUtils.StringReplace(QueryParams.Query, '\', ' ', [rfReplaceAll]);
    QueryParams.ApplyToDS(FWorkQuery);

    try
      CheckForm;
      if not Terminated then
        FWorkQuery.Open;
    except
      on e : Exception do
      begin
        FErrorMsg := e.Message + #13 + TA('Query failed to execute!');
        SynchronizeEx(ErrorSQL);
        Exit;
      end;
    end;

    if not FWorkQuery.IsEmpty and not FSearchParams.IsEstimate then
    begin
      FLastPacketTime := GetTickCount;
      Counter := 0;
      while not FWorkQuery.Eof do
      begin
        if Terminated then
          Break;

        Inc(Counter);
        if (Counter > 1000) then
          Break;

        AddItem(FWorkQuery);

        if GetTickCount - FLastPacketTime > MIN_PACKET_TIME then
        begin
          SynchronizeEx(SendDataPacketToForm);
          FData.Clear;
          FLastPacketTime := GetTickCount;
        end;
        FWorkQuery.Next;
      end;
      SynchronizeEx(SendDataPacketToForm);
      FData.Clear;
    end;

    if FSearchParams.IsEstimate then
    begin
      if not FWorkQuery.IsEmpty then
        IntParam := FWorkQuery.Fields[0].AsInteger
      else
        IntParam := -1;

      SynchronizeEx(UpdateQueryEstimateCount);
    end;

  finally
    FreeDS(FWorkQuery);
  end;
end;

procedure SearchThread.AddItem(S : TDataSet);
var
  I : Integer;
  SearchData : TDBPopupMenuInfoRecord;
  SearchExtension : TSearchDataExtension;
  JPEG : TJPEGImage;
  PassWord : string;
  BS : TStream;
begin
  SearchData := TDBPopupMenuInfoRecord.CreateFromDS(S);
  SearchExtension := TSearchDataExtension.Create;
  SearchData.Data := SearchExtension;
  FData.Add(SearchData);
  if FQData.Count > 0 then
  begin
    for I := 0 to FQData.Count - 1 do
    if FQData[I].ID = SearchData.ID then
      SearchExtension.CompareResult:= TSearchDataExtension(FQData[I].Data).CompareResult;
  end;

  JPEG := TJPEGImage.Create;
  try
    if SearchData.Crypted then
    begin
      PassWord := DBKernel.FindPasswordForCryptBlobStream(S.FieldByName('thum'));
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
    end else
      SearchExtension.Icon := TAIcons.Instance.GetIconByExt(SearchData.FileName, False, 48, False);
  finally
    F(JPEG);
  end;
end;

procedure SearchThread.DoScanSimilarFiles(QueryParams: TDBQueryParams);
var
  Pic: TPicture;
  TempSql,
  PassWord: string;
  Graphic: TGraphic;
  TempBitmap,
  SBitmap: TBitmap;
  FQuery: TDataSet;
  JPEG: TJpegImage;
  EstimateRecordsCOunt: Integer;
  CmpResult: TImageCompareResult;
  Rot: Integer;
  ScanParams: TScanFileParams;
  Item: TDBPopupMenuInfoRecord;
  CompareInfo: TCompareImageInfo;
begin
  ScanParams := TScanFileParams(QueryParams.Data);
  if not FSearchParams.IsEstimate then
  begin

    Pic := TPicture.Create;
    try
      if GraphicCrypt.ValidCryptGraphicFile(ScanParams.ScanFileName) then
      begin
        PassWord := DBKernel.FindPasswordForCryptImageFile(ScanParams.ScanFileName);
        if PassWord = '' then
        begin
          StrParam := ScanParams.ScanFileName;
          SynchronizeEx(GetPassForFile);
          PassWord := StrParam;
        end;
        if PassWord = '' then
          Exit;

        Graphic := DeCryptGraphicFile(ScanParams.ScanFileName, PassWord);
        Pic.Graphic := Graphic;
        F(Graphic);
      end else
        Pic.LoadFromFile(ScanParams.ScanFileName);

      //resampling image to DB size
      JPEGScale(Pic.Graphic, 100, 100); //100x100 is the best size!
      TempBitmap := TBitmap.Create;
      try
        TempBitmap.PixelFormat := pf24bit;
        AssignGraphic(TempBitmap, Pic.Graphic);
        SBitmap := TBitmap.Create;
        try
          SBitmap.PixelFormat := pf24bit;
          DoResize(100, 100, TempBitmap, SBitmap); //100x100 is the best size!

          TempSql := 'Select {FIELDS} from $DB$ Where ';
          TempSql := TempSql + Format(' (Rating >= %d) and (Rating <= %d) ', [FSearchParams.RatingFrom,
            FSearchParams.RatingTo]);
          if FSearchParams.GroupName <> '' then
            TempSql := TempSql + ' AND (Groups like "' + GroupSearchByGroupName(FSearchParams.GroupName) + '")';
          TempSql := TempSql + ' AND ((DateToAdd > :MinDate) and (DateToAdd<:MaxDate))';

          FQuery := GetQuery(True);
          try
            SetSQL(FQuery, StringReplace(TempSql, '{FIELDS}', 'COUNT(*)', []));
            SetDateParam(FQuery, 'MinDate', DateOf(FSearchParams.DateFrom));
            SetDateParam(FQuery, 'MaxDate', DateOf(FSearchParams.DateTo));
            FQuery.Open;
            EstimateRecordsCOunt := FQuery.Fields[0].AsInteger;
          finally
            FreeDS(FQuery);
          end;
          FQuery := GetQuery(True);
          try
            SetSQL(FQuery, StringReplace(TempSql, '{FIELDS}', '*', []) + ' ORDER BY ID DESC');
            SetDateParam(FQuery, 'MinDate', DateOf(FSearchParams.DateFrom));
            SetDateParam(FQuery, 'MaxDate', DateOf(FSearchParams.DateTo));
            FQuery.Open;

            CompareInfo := TCompareImageInfo.Create(SBitmap,  not ScanParams.ScanRotation, ScanParams.ScanRotation);
            try
              if not FQuery.Eof then
                FQuery.First;

              while not FQuery.Eof do
              begin
                //TW.I.Start('COMPARE NEXT ITEM');
                if FQuery.RecNo mod 10 = 0 then
                begin
                  //TW.I.Start('COMPARE PROGRESS START');
                  SetPercentProgress(100 * (FQuery.RecNo / EstimateRecordsCount));
                  if (FData.Count > 0) then
                  begin
                    SynchronizeEx(SendDataPacketToForm);
                    FData.Clear;
                  end;
                  //TW.I.Start('COMPARE PROGRESS END');
                end;

                if Terminated then
                  Break;

                //TW.I.Start('COMPARE LOAD IMAGE');
                JPEG := nil;
                try
                  if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
                  begin
                    PassWord := DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum'));
                    if PassWord = '' then
                    begin
                      FQuery.Next;
                      Continue;
                    end;
                    GraphicCrypt.DeCryptBlobStreamJPG(FQuery.FieldByName('thum'), PassWord, JPEG);
                  end else
                  begin
                    JPEG := TJPEGImage.Create;
                    JPEG.Assign(FQuery.FieldByName('thum'));
                  end;

                  //TW.I.Start('COMPARE LOAD IMAGE END');
                  if JPEG <> nil then
                  begin
                    //TW.I.Start('COMPARE COMPARE START');
                    CmpResult := CompareImagesEx(JPEG, CompareInfo, Rot, ScanParams.ScanRotation, not ScanParams.ScanRotation, 60);
                    //TW.I.Start('COMPARE COMPARE END');
                    if (CmpResult.ByGistogramm > ScanParams.ScanPercent) or (CmpResult.ByPixels > ScanParams.ScanPercent) then
                    begin
                      Item := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
                      Item.ID := FQuery.FieldByName('ID').AsInteger;
                      Item.Data := TSearchDataExtension.Create;
                      TSearchDataExtension(Item.Data).CompareResult := CmpResult;
                      FQData.Add(Item);
                      AddItem(FQuery);
                    end;
                  end;
                  //TW.I.Start('COMPARE ITEM END');
                finally
                  F(JPEG);
                end;
                FQuery.Next;
              end;
              FData.Clear;
            finally
              F(CompareInfo);
            end;
          finally
            FreeDS(FQuery);
          end;
        finally
          F(SBitmap);
        end;
      finally
        F(TempBitmap);
      end;
    finally
      F(Pic);
    end;
  end;
end;

procedure SearchThread.NitifyEstimateStart;
begin
  (ThreadForm as TSearchForm).NitifyEstimateStart;
end;

procedure SearchThread.NitifyEstimateEnd;
begin
  (ThreadForm as TSearchForm).NitifyEstimateEnd;
end;

procedure SearchThread.SendDataPacketToForm;
begin
  (ThreadForm as TSearchForm).LoadDataPacket(FData);
end;

procedure SearchThread.StartLoadingList;
begin
  (ThreadForm as TSearchForm).NotifySearchingStart;
end;

procedure SearchThread.NotifySearchEnd;
begin
  (ThreadForm as TSearchForm).NotifySearchingEnd;
end;

procedure SearchThread.UpdateQueryEstimateCount;
begin
  (ThreadForm as TSearchForm).UpdateEstimateState(IntParam);
end;

procedure SearchThread.SetPercentProgress(Value: Extended);
begin
  ExtendedParam := Value;
  SynchronizeEx(SetPercentProgressSync);
end;

procedure SearchThread.SetPercentProgressSync;
begin
  (ThreadForm as TSearchForm).UpdateProgressState(ExtendedParam);
end;

end.
