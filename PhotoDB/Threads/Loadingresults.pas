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
  uDBBaseTypes, uDBFileTypes, uRuntime;

const
  SM_ID         = 0;
  SM_TITLE      = 1;
  SM_DATE_TIME  = 2;
  SM_RATING     = 3;
  SM_FILE_SIZE  = 4;
  SM_SIZE       = 5;
  SM_COMPARING  = 6;

type
  SearchThread = class(TThreadEx)
  private
    { Private declarations }
    FPictureSize : integer;
    ferrormsg : string;
    foptions : integer;
    fSpsearch_ShowFolderid : integer;
    fSpsearch_ShowFolder : string;
 //   fSpsearch_ShowFoldername : string;
    fSpsearch_ShowThFile : string;
    fSpsearch_ScanFile : string;
    fSpsearch_ScanFilePersent : Extended;
    fSpsearch_ScanFileRotate : boolean;
    ImThs : TArStrings;
    FSearchParams : TSearchQuery;
    IthIds : TArInteger;
    StrParam : String;
    IntParam : Integer;
    procedure ErrorSQL;
    function CreateQuery : TDBQueryParams;
    procedure DoOnDone;
//    procedure SetSearchPathW(Path : String);
//    procedure SetSearchPath;
    procedure AddWideSearchOptions(Params : TDBQueryParams);
    procedure AddOptions(SqlParams : TDBQueryParams);
    procedure SetProgressText(Value : String);
    procedure SetProgressTextA;
    procedure SetMaxValue(Value : Integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value : Integer);
    procedure SetProgressA;
//    procedure DoSetSearchByComparing;
    procedure ApplyFilter(Params : TDBQueryParams; Attr : Integer);
//    procedure GetPassForFile;
    procedure StartLoadingList;
  protected
    RatingParam, LastMonth, LastYear, LastRating : integer;
    LastChar : Char;
    LastSize, SizeParam : int64;
    FileNameParam : string;
    StrTh : string;
    FQueryString : string;

    FDateTimeParam : TDateTime;
    FData : TDBPopupMenuInfo;
    fQData : TDBPopupMenuInfo;
    FOnDone : TNotifyEvent;
    FShowGroups : boolean;
    BitmapParam : TBitmap;
    procedure Execute; override;
    procedure LoadImages;
    procedure UpdateQueryEstimateCount;
    procedure SendDataPacketToForm;
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

uses FormManegerUnit, Searching, UnitGroupsWork;

constructor SearchThread.Create(Sender : TThreadForm; SID : TGUID; SearchParams : TSearchQuery; OnDone : TNotifyEvent; PictureSize : integer);
begin
  inherited Create(Sender, SID);

  FPictureSize := PictureSize;
  LastChar := #0;
  SizeParam := 0;
  FileNameParam := '';
  LastYear := 0;
  FOnDone := OnDone;
  FSearchParams := SearchParams;
  Start;
end;

procedure SearchThread.ErrorSQL;
begin
  (ThreadForm as TSearchForm).ErrorQSL(ferrormsg);
end;

procedure SearchThread.Execute;
var
  ParamNo: Integer;
{  i, c, x : integer;
  fSpecQuery : TDataSet;
  PassWord,tempsql : string;
  JPEG : TJPEGImage;
  FTable : TDataSet;
  pic : TPicture;
  SBitmap, TempBitmap : TBitmap;
  CmpResult : TImageCompareResult;
  rot : integer;
  crc : Cardinal;
  Count : integer;    }

  function NextParam : integer;
  begin
   Result:=paramno;
   inc(paramno);
  end;

begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try
      ParamNo:=0;
      //#8 - invalid query identify, needed from script executing
      if FSearchParams.Query = #8 then
        Exit;

      FData := TDBPopupMenuInfo.Create;
      try
        LoadImages;
      finally
        F(FData);
      end;
    finally
      if not FSearchParams.IsEstimate then
        SynchronizeEx(DoOnDone);
    end;
  finally
    CoUninitialize;
  end;

 (* fQuery := GetQuery;
  try
    //Create SELECT statment
    CreateQuery;

    //initializing variables
    fQData := TSearchRecordArray.Create;
    fQData.Clear;
    //searching for image in DB
    if QueryType = QT_W_SCAN_FILE then
    begin
      Pic := TPicture.Create;
      try
        if GraphicCrypt.ValidCryptGraphicFile(fSpSearch_ScanFile) then
        begin
          PassWord := DBKernel.FindPasswordForCryptImageFile(fSpSearch_ScanFile);
          if PassWord = '' then
          begin
            StrParam := fSpSearch_ScanFile;
            SynchronizeEx(GetPassForFile);
            PassWord := StrParam;
          end;
          if PassWord='' then
            Exit;

          Graphic:=DeCryptGraphicFile(fSpsearch_ScanFile,PassWord);
        end else
        begin
          Pic.LoadFromFile(fSpsearch_ScanFile);
        end;
        //resampling image to DB size
        JPEGScale(Pic.Graphic, 100, 100); //100x100 is best size!
        TempBitmap := TBitmap.Create;
        try
          TempBitmap.PixelFormat := pf24bit;
          TempBitmap.Assign(Pic.Graphic);
          //TODO!!!!!!!!!!????
          SBitmap := TBitmap.Create;
          try
            SBitmap.PixelFormat := pf24bit;
            DoResize(100, 100, TempBitmap, SBitmap); //100x100 is best size!

            FSearchParams.DateFrom := Trunc(FSearchParams.DateFrom);
            FSearchParams.DateTo := Trunc(FSearchParams.DateTo);

            c := 0;
            FTable:=GetQuery;
            try
              tempsql:='Select ID, Thum from '+GetDefDBName+' Where ';
              tempsql:=tempsql+Format(' (Rating >= %d) and (Rating <= %d) ',[FSearchParams.RatingFrom, FSearchParams.RatingTo]);
              if FSearchParams.GroupName<>'' then
                tempsql:=tempsql+' AND (Groups like "'+GroupSearchByGroupName(FSearchParams.GroupName)+'")';

              tempsql:=tempsql+' AND ((DateToAdd > :MinDate) and (DateToAdd<:MaxDate)) ';

              SetSQL(FTable,tempsql);


              SetDateParam(FTable,'MinDate',FSearchParams.DateFrom);
              inc(c);
              SetDateParam(FTable,'MaxDate',FSearchParams.DateTo);

              FTable.Active:=true;
              FTable.First;

              intParam := FTable.RecordCount;
              //???SynchronizeEx(initializeB);
              //Searching in DB
              for I := 1 to FTable.RecordCount do
              begin
                SetProgress(i);
                if Terminated then
                  Break;

                JPEG := nil;
                if ValidCryptBlobStreamJPG(FTable.FieldByName('thum')) then
                begin
                  PassWord := DBKernel.FindPasswordForCryptBlobStream(FTable.FieldByName('thum'));
                  if PassWord = '' then
                  begin
                    FTable.Next;
                    Continue;
                  end;
                  JPEG := GraphicCrypt.DeCryptBlobStreamJPG(FTable.FieldByName('thum'), PassWord) as TJPEGImage;
                end else
                begin
                  JPEG := TJPEGImage.Create;
                  JPEG.Assign(FTable.FieldByName('thum'));
                end;

                if JPEG <> nil then
                begin
                  CmpResult := CompareImages(JPEG, SBitmap, rot, fSpsearch_ScanFileRotate, not fSpsearch_ScanFileRotate, 60);
                  if (CmpResult.ByGistogramm>fSpsearch_ScanFilePersent) or (CmpResult.ByPixels>fSpsearch_ScanFilePersent) then
                  begin
                    with fQData.AddNew do
                    begin
                      ID:=FTable.FieldByName('ID').AsInteger;
                      CompareResult:=CmpResult;
                    end;
                    SynchronizeEx(DoSetSearchByComparing);
                  end;
                  JPEG.Free;
                end;
              end;
            finally
              FTable.Free;
            end;
          finally
            SBitmap.Free;
          end;
        finally
          TempBitmap.Free;
        end;
      finally
        Pic.Free;
      end;

      if fQData.Count <> 0 then
      begin
        QueryType := QT_TEXT;
        FQueryString := 'SELECT * FROM '+GetDefDBname+' WHERE ';

        if FSearchParams.GroupName <> '' then
          FQueryString:=FQueryString+' (Groups like "'+GroupSearchByGroupName(FSearchParams.GroupName)+'") AND ';

        FQueryString:=FQueryString+' ID in (';
        for i:=0 to fQData.Count-1 do
          if i=0 then FQueryString:=FQueryString+' '+inttostr(fQData[i].ID)+' ' else
        FQueryString:=FQueryString+' , '+inttostr(fQData[i].ID)+'';
        FQueryString:=AddOptions(FQueryString+') '+GetFilter(db_attr_norm)+' ');
      end;
    end;

    try
      //TADOQuery(fQuery).CursorType := ctOpenForwardOnly;
      //FQueryString := SysUtils.StringReplace(FQueryString, '''', ' ', [rfReplaceAll]);
      //FQueryString := SysUtils.StringReplace(FQueryString, '\', ' ', [rfReplaceAll]);
      //SetSQL(fQuery, FQueryString);

      //SetDateParam(fQuery, QueryParamsCount(fQuery)-2-x, Trunc(FSearchParams.DateFrom));
      //SetDateParam(fQuery, QueryParamsCount(fQuery)-1-x, Trunc(FSearchParams.DateTo));

      if (QueryType=QT_SIMILAR) then
        SetStrParam(fQuery, 0, StrTh);

      if foptions=SPSEARCH_SHOWFOLDER then
      begin
        fspecquery:=GetQuery;

        if not DirectoryExists(fspsearch_showfolder) then
        begin
          SetSQL(fSpecQuery,'SELECT * FROM '+GetDefDBName+' WHERE ID = :fID');
          SetIntParam(fSpecQuery,0,fspsearch_showfolderid);
          fSpecQuery.active:=true;
          FormatDir(fspsearch_showfoldername);
          if fSpecQuery.RecordCount<>0 then
          begin
             fspecquery.first;
             fspsearch_showfoldername:=GetDirectory(fspecquery.fieldbyname('FFilename').AsString);
             fspsearch_showfoldername:=AnsiLowerCase(fspsearch_showfoldername);
             SetSearchPathW(Getdirectory(fspsearch_showfoldername));
             if GetDBType=DB_TYPE_MDB then
             begin
               UnFormatDir(fspsearch_showfoldername);
               CalcStringCRC32(fspsearch_showfoldername, crc);
               SetIntParam(fQuery,nextparam, Integer(crc));
             end;
             FormatDir(fspsearch_showfoldername);
             SetStrParam(fQuery,nextparam, '%'+fspsearch_showfoldername+'%');
             SetStrParam(fQuery,nextparam, '%'+fspsearch_showfoldername+'%\%');
           end else
           begin
             SetIntParam(fQuery,nextparam, 0);
             SetStrParam(fQuery,nextparam, '\');
             SetStrParam(fQuery,nextparam, '\');
           end;
         end else
         begin
           fspsearch_showfolder:=AnsiLowerCase(fspsearch_showfolder);
           SetSearchPathW(fspsearch_showfolder);
           if GetDBType=DB_TYPE_MDB then
           begin
             if FolderView then
             Delete(fspsearch_showfolder, 1, Length(ProgramDir));
             UnFormatDir(fspsearch_showfolder);
             CalcStringCRC32(fspsearch_showfolder, crc);
             SetIntParam(fQuery, nextparam, Integer(crc));
           end;
           FormatDir(fspsearch_showfolder);
           SetStrParam(fQuery,nextparam, '%' + fspsearch_showfolder + '%');
           SetStrParam(fQuery,nextparam, '%' + fspsearch_showfolder + '%\%');
         end;
         FreeDS(fspecquery);
       end;

       try

         CheckForm;
         if not Terminated then
           fQuery.Active := True;
       except
         on e : Exception do
         begin
           fErrorMsg:=e.Message;
           SynchronizeEx(ErrorSQL);
           exit;
         end;
       end;
       CheckForm;
       fData := TSearchRecordArray.Create;
       if not Terminated then
       begin
         fQuery.Last;
         for I := 1 to fQuery.RecordCount do
           fData.AddNew;
         //???SynchronizeEx(InitializeA);
         fQuery.First;
       end;
       c := 0;
       fQuery.First;
       for I := 1 to fQuery.RecordCount do
       begin
         if Terminated then
           Break;
         //AddItem(i, FQuery);
         fQuery.Next;
       end;
     except
       on e : Exception do
       begin
         fErrorMsg := e.Message;
         SynchronizeEx(ErrorSQL);
       end;
     end;
     SynchronizeEx(EndUpdate);
     if Terminated then
     begin
       ///???SynchronizeEx(ProgressNull);
       SynchronizeEx(DoOnDone);
       Exit;
     end;
     try
       fpic := TPicture.create;
       fpic.Graphic := TJPEGImage.Create;
       fthum_images_ := 1;
       ///???SynchronizeEx(ProgressNullA);
       if not Terminated then
       begin
         fQuery.First;
         I := 0;
         while not fQuery.Eof do
         begin
           Inc(I);
           if Terminated then
             Break;
           PassWord := '';
          inc(fthum_images_);
          IntParam := I - 1;
          SynchronizeEx(ListViewImageIndex);
          if IntParam = -2 then
            Break;
          if IntParam = -1 then
          begin
            if Terminated then
              Break;
            if TBlobField(fQuery.FieldByName('thum')) = nil then
              Continue;
            if fData[i-1].Crypted then
            begin
              PassWord := DBKernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('thum'));
              if PassWord <> '' then
                fpic.Graphic:=DeCryptBlobStreamJPG(fQuery.FieldByName('thum'),PassWord)
              else begin
                fQuery.Next;
              Continue;
            end;
          end else
          begin
            FBS:=GetBlobStream(fQuery.FieldByName('thum'),bmRead);
            try
              if FBS.Size<>0 then
                fpic.Graphic.LoadFromStream(FBS);
            except
              on e : Exception do EventLog(':SearchThread::Execute()/LoadFromStream throw exception: '+e.Message);
                end;
              FBS.Free;
            end;
            fbit := Tbitmap.create;
            fbit.PixelFormat := pf24bit;
            fbit.Assign(fpic.Graphic);

            ApplyRotate(fbit, fData[i-1].Rotation);
            FI:=i;
            FCurrentFile:=fQuery.FieldByName('FFileName').AsString;

            IntParam:=i-1;
            //???SynchronizeEx(AddImageToList);
            ///???SynchronizeEx(SetImageIndex);
          end;
          fquery.Next;
        end;
      end;
      fpic.Free;
    except
      on e : Exception do
      begin
        fErrorMsg:=e.Message;
        SynchronizeEx(ErrorSQL);
      end;
    end;
    Count:=fQuery.RecordCount;

  finally
    FreeDS(fQuery);
  end;

  ///???SynchronizeEx(ProgressNull);
  SynchronizeEx(DoOnDone); *)
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
  Foptions := 0;
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
        Result.QueryType := QT_DELETED;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_not_exists);
      end;

      if AnsiLowerCase(Sysaction) = AnsiLowerCase('Dublicates') then
      begin
        Result.QueryType := QT_DUBLICATES;
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
        ApplyFilter(Result, Db_attr_dublicate);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 5)) = AnsiLowerCase('Links') then
      begin
        Result.QueryType := QT_ONE_TEXT;
        SystemQuery := True;
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' where (Links like "%[%]%{%}%;%" )';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 9)) = AnsiLowerCase('ScanImage') then
      begin
        FSpsearch_ScanFileRotate := False;
        Result.QueryType := QT_W_SCAN_FILE;
        S := Copy(Sysaction, 12, Length(Sysaction) - 12);
        if PosEx(':', S, 3) = -1 then
        begin
          FSpsearch_ScanFilePersent := 50;
          FSpsearch_ScanFile := S;
        end else
        begin
          Stemp := Copy(S, 1, PosEx(':', S, 3) - 1);
          FSpsearch_ScanFile := Stemp;
          Stemp := Copy(S, PosEx(':', S, 3) + 1, Length(S) - PosEx(':', S, 3));
          FSpsearch_ScanFilePersent := Min(100, Max(0.0000000001, StrToFloatDef(Stemp, 50)));
        end;
        SystemQuery := True;
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 10)) = AnsiLowerCase('ScanImageW') then
      begin
        FSpsearch_ScanFileRotate := True;
        Result.QueryType := QT_W_SCAN_FILE;
        S := Copy(Sysaction, 12, Length(Sysaction) - 12);
        if PosEx(':', S, 3) = -1 then
        begin
          FSpsearch_ScanFilePersent := 50;
          FSpsearch_ScanFile := S;
        end else
        begin
          Stemp := Copy(S, 1, PosEx(':', S, 3) - 1);
          FSpsearch_ScanFile := Stemp;
          Stemp := Copy(S, PosEx(':', S, 3) + 1, Length(S) - PosEx(':', S, 3));
          FSpsearch_ScanFilePersent := Min(100, Max(0.0000000001, StrToFloatDef(Stemp, 50)));
        end;
        SystemQuery := True;
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 7)) = AnsiLowerCase('KeyWord') then
      begin
        Result.QueryType := QT_ONE_KEYWORD;
        SystemQuery := True;
        Stemp := Copy(Sysaction, 9, Length(Sysaction) - 9);
        Stemp := NormalizeDBString(Stemp);
        Result.Query := Format('SELECT %s FROM $DB$', [FIELDS]);
        Result.Query := Result.Query + ' where (KeyWords like "%' + Stemp + '%") ';
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 6)) = AnsiLowerCase('folder') then
      begin
        Result.QueryType := QT_FOLDER;
        Systemquery := True;

        Folder := IncludeTrailingBackslash(Copy(Sysaction, 8, Length(Sysaction) - 8));

        Result.Query := Format('Select %s From $DB$ WHERE FolderCRC = :CRC', [FIELDS]);
        Result.AddIntParam('CRC', GetPathCRC(Folder));
        if not FSearchParams.ShowPrivate then
          Result.Query := Result.Query + ' and (Access<>' + Inttostr(Db_access_private) + ')';

        Foptions := SPSEARCH_SHOWFOLDER;
        if not DirectoryExistsSafe(Folder) then
          Fspsearch_showfolder := ''
        else
          Fspsearch_showfolder := Folder;
        Fspsearch_showfolderid := StrToIntDef(Copy(Sysaction, 8, Length(Sysaction) - 8), 0);
        ApplyFilter(Result, Db_attr_norm);
      end;

      if AnsiLowerCase(Copy(Sysaction, 1, 7)) = AnsiLowerCase('similar') then
      begin
        Result.QueryType := QT_SIMILAR;
        Systemquery := True;
        Sid := Copy(Sysaction, 9, Length(Sysaction) - 9);
        Id := StrToIntDef(Sid, 0);

        FSpecQuery := GetQuery;
        try
          SetSQL(FSpecQuery, 'SELECT StrTh FROM $DB$ WHERE ID = ' + IntToStr(Id));
          FSpecQuery.Open;
          StrTh := FSpecQuery.FieldByName('StrTh').AsString;
        finally
          FreeDS(FSpecQuery);
        end;

        Result.Query := Format('SELECT %s FROM $DB$ WHERE StrTh = :str', [FIELDS]);

        if not FSearchParams.ShowPrivate then
          Result.Query := Result.Query + ' and (Access<>' + Inttostr(Db_access_private) + ')';

        Foptions := SPSEARCH_SHOWSIMILAR;
      end;
    end;

  if AnsiLowerCase(Copy(Sysaction, 1, 6)) = AnsiLowerCase('HashFile') then
  begin
    Result.QueryType := QT_TEXT;
    Systemquery := True;
    Foptions := SPSEARCH_SHOWTHFILE;
    FSpSearch_ShowThFile := Copy(Sysaction, 8, Length(Sysaction) - 8);
    ImThs := LoadImThsFromfileA(FSpSearch_ShowThFile);
    First := True;
    FSpecQuery := GetQuery;
    SetLength(IthIds, 0);
    SetProgressText(TA('Converting...'));

    // AllocImThBy

    SetMaxValue(Length(ImThs) div AllocImThBy);

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
      SetProgress(J - 1);
    end;
    FreeDS(FSpecQuery);
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
var
  AData: TDBPopupMenuInfo;
begin
  //Loading big images
  if FPictureSize <> ThImageSize then
    (ThreadForm as TSearchForm).ReloadBigImages
  else
    if Assigned(FOnDone) then
      FOnDone(Self);

  (ThreadForm as TSearchForm).StopLoadingList;
    //if (ThreadForm as TSearchForm).SearchByCompating then
    //TODO:!!!begin
    //TODO:!!! (ThreadForm as TSearchForm).Decremect1.Checked:=true;
    //TODO:!!! (ThreadForm as TSearchForm).SortbyCompare1Click((ThreadForm as TSearchForm).SortbyCompare1);
    //TODO:!!!end else
  begin
    if (ThreadForm as TSearchForm).SortbyCompare1.Checked then
    begin
      (ThreadForm as TSearchForm).SortbyDate1Click((ThreadForm as TSearchForm).SortbyDate1);
    end;
  end;

end;

{procedure SearchThread.SetSearchPath;
begin
  (ThreadForm as TSearchForm).SetPath(StringParam);
end;}

{procedure SearchThread.SetSearchPathW(Path: String);
begin
 if not DirectoryExists(Path) then exit;
 StringParam:=Path;
 SynchronizeEx(SetSearchPath);
end; }

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

procedure SearchThread.SetMaxValue(Value: Integer);
begin
 IntParam:=Value;
 SynchronizeEx(SetMaxValueA);
end;

procedure SearchThread.SetMaxValueA;
begin
  (ThreadForm as TSearchForm).PbProgress.MaxValue:=IntParam;
end;

procedure SearchThread.SetProgress(Value: Integer);
begin
 IntParam:=Value;
 SynchronizeEx(SetProgressA);
end;

procedure SearchThread.SetProgressA;
begin
  (ThreadForm as TSearchForm).PbProgress.Position:=IntParam;
end;

procedure SearchThread.SetProgressText(Value: String);
begin
 StrParam:=Value;
 SynchronizeEx(SetProgressTextA);
end;

procedure SearchThread.SetProgressTextA;
begin
  (ThreadForm as TSearchForm).PbProgress.Text:=StrParam;
end;

procedure SearchThread.AddOptions(SqlParams : TDBQueryParams);
var
  SortDirection : string;

begin
  case SqlParams.QueryType of
    QT_TEXT, QT_GROUP, QT_FOLDER,
    QT_ONE_TEXT, QT_ONE_KEYWORD, QT_NO_NOPATH:
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

{procedure SearchThread.DoSetSearchByComparing;
begin
  (ThreadForm as TSearchForm).DoSetSearchByComparing;
end; }

{procedure SearchThread.GetPassForFile;
begin
  StrParam := GetImagePasswordFromUser(StrParam);
end;}

procedure SearchThread.LoadImages;
var
  FWorkQuery : TDataSet;
  FLastPacketTime : Cardinal;
  QueryParams : TDBQueryParams;
  Counter : Integer;

  procedure AddItem(S : TDataSet);
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
    if (FQData <> nil) and (FQData.Count > 0) then
    begin
      for I := 0 to fQData.Count - 1 do
      if fQData[I].ID = SearchData.ID then
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

begin
  if not FSearchParams.IsEstimate then
    SynchronizeEx(StartLoadingList);
  FWorkQuery := GetQuery(FSearchParams.IsEstimate);
  try
    QueryParams := CreateQuery;
    try

      if not FSearchParams.IsEstimate then
      begin
        TADOQuery(FWorkQuery).CursorType := ctOpenForwardOnly;
        TADOQuery(FWorkQuery).CursorLocation := clUseServer;
      end;
      TADOQuery(FWorkQuery).LockType := ltReadOnly;
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
        IntParam := FWorkQuery.Fields[0].AsInteger;
        SynchronizeEx(UpdateQueryEstimateCount);
      end;

    finally
      F(QueryParams);
    end;
  finally
    FreeDS(FWorkQuery);
  end;
end;

procedure SearchThread.SendDataPacketToForm;
begin
  (ThreadForm as TSearchForm).LoadDataPacket(FData);
end;

procedure SearchThread.StartLoadingList;
begin
  (ThreadForm as TSearchForm).StartLoadingList;
end;

procedure SearchThread.UpdateQueryEstimateCount;
begin
  (ThreadForm as TSearchForm).UpdateQueryEstimateCount(IntParam);
end;

end.
