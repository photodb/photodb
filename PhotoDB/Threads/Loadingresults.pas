unit Loadingresults;

interface

uses
  UnitDBKernel, dolphin_db, jpeg, ComCtrls, CommCtrl, windows,
  Classes, Math, DB, SysUtils, Controls, Graphics, Dialogs, adodb,
  GraphicCrypt, forms, StrUtils, win32crc, EasyListview, DateUtils,
  UnitSearchBigImagesLoaderThread, UnitDBDeclare, UnitPasswordForm,
  UnitDBCommonGraphics, uThreadForm, uThreadEx, uLogger, UnitDBCommon,
  CommonDBSupport, uFileUtils, uTranslate, uMemory, ActiveX,
  uAssociatedIcons;

type
  TQueryType = (QT_NONE, QT_TEXT, QT_GROUP, QT_DELETED, QT_DUBLICATES,
                QT_FOLDER, QT_RESULT_ITH, QT_RESULT_IDS, QT_SIMILAR,
                QT_ONE_TEXT, QT_ONE_KEYWORD, QT_W_SCAN_FILE, QT_NO_NOPATH);

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
{    fQuery: TDataSet;
    FI : integer;
    FID : integer;  }
    FPictureSize : integer;

 {   fbit : TBitmap;
    fpic : TPicture;
    fthum_images_:integer;  }
    ferrormsg : string;
    foptions : integer;
 {   fInclude : Boolean;  }

    fSpsearch_ShowFolderid : integer;
    fSpsearch_ShowFolder : string;
    fSpsearch_ShowFoldername : string;
    fSpsearch_ShowThFile : string;
    fSpsearch_ScanFile : string;
    fSpsearch_ScanFilePersent : Extended;
    fSpsearch_ScanFileRotate : boolean;
    ImThs : TArStrings;
    FCurrentFile : String;
    StringParam : String;
    FSearchParams : TSearchQuery;
    IthIds : TArInteger;
    StrParam : String;
    IntParam : Integer;
    procedure ErrorSQL;
    function CreateQuery : TDBQueryParams;
    procedure DoOnDone;
    procedure SetSearchPathW(Path : String);
    procedure SetSearchPath;
    procedure GetWideSearchOptions(Params : TDBQueryParams);
    function AddOptions(SqlQuery : string) : string;
    procedure SetProgressText(Value : String);
    procedure SetProgressTextA;
    procedure SetMaxValue(Value : Integer);
    procedure SetMaxValueA;
    procedure SetProgress(Value : Integer);
    procedure SetProgressA;
    procedure DoSetSearchByComparing;
    procedure GetFilter(Params : TDBQueryParams; Attr : Integer);
    procedure GetPassForFile;
    procedure StartLoadingList;
  protected
    RatingParam, LastMonth, LastYear, LastRating : integer;
    LastChar : Char;
    LastSize, SizeParam : int64;
    FileNameParam : string;
    StrTh : string;
    FQueryString : string;
    QueryType : TQueryType;
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
        FData.Free;
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
           fErrorMsg:=e.Message+#13+TEXT_MES_QUERY_FAILED;
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
         fErrorMsg := e.Message + #13 + TEXT_MES_QUERY_FAILED;
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
        fErrorMsg:=e.Message+#13+TEXT_MES_QUERY_FAILED;
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

{procedure SearchThread.InitializeA;
begin
  with (ThreadForm as TSearchForm) do
  begin
    PbProgress.Position:=0;
    PbProgress.MaxValue:=fQuery.RecordCount;
    Label7.Caption:=format(TEXT_MES_RES_REC,[IntToStr(fQuery.RecordCount)]);
    PbProgress.Text:=TEXT_MES_LOAD_QUERY_PR;
  end;
end;

procedure SearchThread.InitializeB;
begin
  with (ThreadForm as TSearchForm) do
  begin
    PbProgress.Position:=0;
    PbProgress.MaxValue:=intparam;
    Label7.Caption:=TEXT_MES_SEARCH_FOR_REC;
    PbProgress.Text:=format(TEXT_MES_SEARCH_FOR_REC_FROM,[IntToStr(intparam)]);
  end;
end;   }



{procedure SearchThread.NewItem;
begin
  if QueryType <> QT_W_SCAN_FILE then
  begin
   (ThreadForm as TSearchForm).PbProgress.Position:=fi;
  end;
  //TODO:!!!!!AddItemInListViewByGroups((ThreadForm as TSearchForm).ListView, FID, FSearchParams.SortMethod, FSearchParams.SortDecrement, fShowGroups, SizeParam,
  //TODO:!!!!!  FileNameParam, RatingParam, fDateTimeParam, fInclude, LastSize, LastChar, LastRating, LastMonth, LastYear);
end; }

procedure SearchThread.GetFilter(Params : TDBQueryParams; Attr : Integer);
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

  GetWideSearchOptions(Params);
end;

function SearchThread.CreateQuery : TDBQueryParams;
var
  Folder, SysAction, stemp,s1,s,sqltext:string;
  a,b,c, n, i,j, id, Left, L, m : integer;
  sqlwords, sqlrwords: TStrings;
  systemquery, First : boolean;
  fields_names: array[1..10] of string;
  fields_names_count : integer;
  fSpecQuery : TDataSet;
  Sid : String;

const
  AllocImThBy = 5;

  procedure AddField(FieldName : String);
  begin
   inc(fields_names_count);
   fields_names[fields_names_count]:=FieldName;
  end;

  function FIELDS : string;
  begin
    if FSearchParams.IsEstimate then
      Result := 'COUNT(*)'
    else
      Result := '*';
  end;

begin
  Result := TDBQueryParams.Create;
 QueryType:=QT_NONE;
 foptions:=0;
 sqltext:=FSearchParams.Query;
 if sqltext='' then sqltext:='*';
 systemquery:=false;
 if length(sqltext)>3 then
 begin
  if (sqltext[1]='%') and (sqltext[2]=':') and (sqltext[length(sqltext)]=':') then
  begin
   Delete(sqltext,1,1);
  end;
 end;

 if length(sqltext)>2 then
 if (sqltext[1]=':') and (sqltext[length(sqltext)]=':') then
 begin
  sysaction:=copy(sqltext,2,length(sqltext)-2);

  if AnsiLowerCase(sysaction)=AnsiLowerCase('DeletedFiles') then
  begin
   systemquery:=true;
   QueryType:=QT_DELETED;
   Result.Query:= Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
   GetFilter(Result, db_attr_not_exists);
  end;

  if AnsiLowerCase(sysaction)=AnsiLowerCase('Dublicates') then
  begin
   QueryType:=QT_DUBLICATES;
   SystemQuery:=true;
   Result.Query:= Format('SELECT %s FROM $DB$ WHERE ', [FIELDS]);
   GetFilter(Result, db_attr_dublicate);
  end;

  if AnsiLowerCase(copy(sysaction,1,5))=AnsiLowerCase('Group') then
  begin
   QueryType:=QT_GROUP;
   SystemQuery:=true;
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (Groups like "'+GroupSearchByGroupName(Copy(sysaction,7,length(sysaction)-7))+'")';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,4))=AnsiLowerCase('Text') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   stemp:=Copy(sysaction,6,length(sysaction)-6);
   stemp:=NormalizeDBString(stemp);
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (KeyWords like "%'+stemp+'%") or (Comment like "%'+stemp+'%") or (FFileName like "%'+stemp+'%")';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,6))=AnsiLowerCase('nopath') then
  begin
   QueryType:=QT_NO_NOPATH;
   SystemQuery:=true;
   stemp:=Copy(sysaction,6,length(sysaction)-6);
   stemp:=NormalizeDBString(stemp);
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (FolderCRC = 0)';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,14))=AnsiLowerCase('ShowNullFields') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (Comment is null) or (KeyWords is null) or (Groups is null) or (Links is null)';
  end;

  if AnsiLowerCase(copy(sysaction,1,13))=AnsiLowerCase('FixNullFields') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   fSpecQuery:=GetQuery;
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (Comment is null) or (KeyWords is null) or (Groups is null) or (Links is null)';

   SetSQL(fSpecQuery,'Update $DB$ Set Comment="" where Comment is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update $DB$ Set KeyWords="" where KeyWords is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update $DB$ Set Groups="" where Groups is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update $DB$ Set Links="" where Links is null');
   ExecSQL(fSpecQuery);
   FreeDS(fSpecQuery);
  end;

  if AnsiLowerCase(copy(sysaction,1,7))=AnsiLowerCase('FixIDEx') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   stemp:='';
   for i:=1 to 200 do
   stemp:=stemp+'_';
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where not (StrTh like "'+stemp+'")';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,5))=AnsiLowerCase('Links') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (Links like "%[%]%{%}%;%" )';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,9))=AnsiLowerCase('ScanImage') then
  begin
   fSpsearch_ScanFileRotate:=false;
   QueryType:=QT_W_SCAN_FILE;
   s:=copy(sysaction,12,length(sysaction)-12);
   if PosEx(':',s,3)=-1 then
   begin
    fSpsearch_ScanFilePersent:=50;
    fSpsearch_ScanFile:=s;
   end else
   begin
    stemp:=Copy(S,1,PosEx(':',s,3)-1);
    fSpsearch_ScanFile:= stemp;
    stemp:=Copy(S,PosEx(':',s,3)+1,Length(S)-PosEx(':',s,3));
    fSpsearch_ScanFilePersent:=Min(100,Max(0.0000000001,StrToFloatDef(stemp,50)));
   end;
   SystemQuery:=true;
  end;

  if AnsiLowerCase(copy(sysaction,1,10))=AnsiLowerCase('ScanImageW') then
  begin
   fSpsearch_ScanFileRotate:=true;
   QueryType:=QT_W_SCAN_FILE;
   s:=copy(sysaction,12,length(sysaction)-12);
   if PosEx(':',s,3)=-1 then
   begin
    fSpsearch_ScanFilePersent:=50;
    fSpsearch_ScanFile:=s;
   end else
   begin
    stemp:=Copy(S,1,PosEx(':',s,3)-1);
    fSpsearch_ScanFile:= stemp;
    stemp:=Copy(S,PosEx(':',s,3)+1,Length(S)-PosEx(':',s,3));
    fSpsearch_ScanFilePersent:=Min(100,Max(0.0000000001,StrToFloatDef(stemp,50)));
   end;
   SystemQuery:=true;
  end;

  if AnsiLowerCase(copy(sysaction,1,7))=AnsiLowerCase('KeyWord') then
  begin
   QueryType:=QT_ONE_KEYWORD;
   SystemQuery:=true;
   stemp:=Copy(sysaction,9,length(sysaction)-9);
   stemp:=NormalizeDBString(stemp);
   Result.Query:= Format('SELECT %s FROM $DB$', [FIELDS]);
   Result.Query:=Result.Query+' where (KeyWords like "%'+stemp+'%") ';
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,6))=AnsiLowerCase('folder') then
  begin
   QueryType:=QT_FOLDER;
   systemquery:=true;

   Folder:=copy(sysaction,8,length(sysaction)-8);
   FormatDir(Folder);

   Result.Query:=Format('Select %s From $DB$ WHERE FolderCRC = :CRC', [FIELDS]);
   Result.AddIntParam('CRC', GetPathCRC(Folder));
   if not FSearchParams.ShowPrivate then Result.Query:=Result.Query+' and (Access<>'+inttostr(db_access_private)+')';

   foptions:=SPSEARCH_SHOWFOLDER;
   if not directoryexists(Folder) then
   fspsearch_showfolder:='' else fspsearch_showfolder:=Folder;
   fspsearch_showfolderid:=StrToIntDef(Copy(sysaction,8,length(sysaction)-8),0);
   GetFilter(Result, db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,7))=AnsiLowerCase('similar') then
  begin
   QueryType:=QT_SIMILAR;
   systemquery:=true;
   Sid:=copy(sysaction,9,length(sysaction)-9);
   id:=StrToIntDef(Sid,0);


   fSpecQuery := GetQuery;
   SetSQL(fSpecQuery,'SELECT StrTh FROM $DB$ WHERE ID = '+IntToStr(id));
   fSpecQuery.Open;
   StrTh:=fSpecQuery.FieldByName('StrTh').AsString;
   FreeDS(fSpecQuery);

   Result.Query:= Format('SELECT %s FROM $DB$ WHERE StrTh = :str', [FIELDS]);

   if not FSearchParams.ShowPrivate then Result.Query:=Result.Query+' and (Access<>'+inttostr(db_access_private)+')';

   foptions:=SPSEARCH_SHOWSIMILAR;
  end;
 end;

 if AnsiLowerCase(copy(Sysaction,1,6))=AnsiLowerCase('ThFile') then
  begin
   QueryType:=QT_TEXT;
   systemquery:=true;
   foptions:=SPSEARCH_SHOWTHFILE;
   fSpSearch_ShowThFile:=copy(sysaction,8,length(sysaction)-8);
   ImThs:=LoadImThsFromfileA(fSpSearch_ShowThFile);
   first:=true;
   fSpecQuery := GetQuery;
   SetLength(IthIds,0);
   SetProgressText(TA('Converting...'));

   //AllocImThBy

   SetMaxValue(Length(ImThs) div AllocImThBy);

   L:=Length(ImThs);
   n:=Trunc(L/AllocImThBy);
   if L/AllocImThBy-n>0 then inc(n);
   Left:=L;
   c:=0;
   SetLength(IthIds,0);
   for j:=1 to n do
   begin
    SQLText:='SELECT ID FROM $DB$ WHERE ';
    m:=Math.Min(Left,Math.Min(L,AllocImThBy));
    fSpecQuery.Active:=false;
    for i:=1 to m do
    begin
     Dec(Left);
     inc(c);
     SQLText:=SQLText+' (StrTh=:S'+inttostr(c)+') ';
     if i<>m then SQLText:=SQLText+'or';
    end;
    SetSQL(fSpecQuery,SQLText);
    for i:=1 to m do
    SetStrParam(fSpecQuery,i-1,ImThs[i-1+AllocImThBy*(j-1)]);
    fSpecQuery.Active:=True;
    fSpecQuery.First;
    for i:=1 to fSpecQuery.RecordCount do
    begin
     SetLength(IthIds,Length(IthIds)+1);
     IthIds[Length(IthIds)-1]:=fSpecQuery.FieldByName('ID').AsInteger;
     fSpecQuery.Next;
    end;
    SetProgress(j-1);
   end;
   FreeDS(fSpecQuery);
   first:=true;
   Result.Query:= Format('SELECT %s FROM $DB$ Where (', [FIELDS]);
   for i:=0 to Length(IthIds)-1 do
   begin
    if first then
    begin
      Result.Query:= Result.Query+' (ID='+IntToStr(IthIds[i])+') ';
     First:=false;
    end else
    Result.Query:= Result.Query+' OR (ID='+IntToStr(IthIds[i])+') ';
   end;
   if Length(IthIds)=0 then
   Result.Query:= Result.Query+'(ID=0) ';
   Result.Query:= Result.Query+' ) ';
   GetFilter(Result, db_attr_norm);
  end;

 if not systemquery then
 begin
  QueryType:=QT_TEXT;
  for i:=1 to length(sqltext) do
  begin
   if sqltext[i]='*' then sqltext[i]:='%';
   if sqltext[i]='?' then sqltext[i]:='_';
  end;
  begin
   if sqltext[length(sqltext)]<>'$' then
   begin
    fields_names_count:=0;
    stemp:='';
    a:=0;
    b:=0;
    a:=Pos('[+',sqltext);
    if a>0 then
    b:=PosEx(']',sqltext,a);
    if b>0 then
    stemp:=AnsiUpperCase(copy(sqltext,a+2,b-a-2));
    for i:=Length(stemp) downto 1 do
    if not CharInSet(stemp[i], ['C','K','F','G','L']) then
    Delete(stemp,i,1);

    for j:=1 to Length(stemp) do
    for i:=1 to Length(stemp)-1 do
    if Byte(stemp[i])<Byte(stemp[i+1]) then
    begin
     c:=Byte(stemp[i]);
     stemp[i]:=stemp[i+1];
     stemp[i+1]:=Char(c);
    end;
    for i:=Length(stemp)-1 downto 1 do
    if stemp[i+1]=stemp[i] then
    Delete(stemp,i+1,1);

    for i:=1 to Math.Min(5,Length(stemp)) do
    begin
     Case Byte(AnsiUpperCase(stemp)[i]) of
      Byte('C'): AddField('Comment');
      Byte('K'): AddField('KeyWords');
      Byte('F'): AddField('FFileName');
      Byte('G'): AddField('Groups');
      Byte('L'): AddField('Links');
     end;
    end;
    if fields_names_count>0 then
    Delete(sqltext,a,b-a+1);

    if fields_names_count<1 then
    begin
     fields_names[1]:='FFileName';
     fields_names[2]:='Comment';
     fields_names[3]:='KeyWords';
     fields_names_count:=3;
    end;
    sqlwords:=TStringList.Create;
    sqlrwords:=TStringList.Create;
    sqltext:=' '+sqltext+' ';
    for i:=length(sqltext) downto 2 do
    if (sqltext[i]=' ') and (sqltext[i-1]=' ') then
    delete(sqltext,i,1);
    for i:=1 to length(sqltext) do
    begin
     if (sqltext[i]=' ') or (i=1) then
     for j:=i+1 to length(sqltext) do
     if (sqltext[j]=' ') or (j=length(sqltext)) then
     begin
      if i=1 then
      stemp:=copy(sqltext,i+1,j-i-1) else
      stemp:=copy(sqltext,i+1,j-i-1);
      if Length(stemp)>0 then
      begin
       if stemp[1]='-' then
       sqlrwords.add(stemp) else sqlwords.add(stemp);
      end else sqlwords.add(stemp);
      break;
     end;
    end;
    if sqlwords.Count=0 then sqlwords.add('%');

    sqltext:='(';
    for i:=1 to fields_names_count do
    begin

     if (i<>1) then
     sqltext:=sqltext+') or (';
     for j:=1 to sqlwords.count do
     begin
      sqltext:=sqltext+fields_names[i]+' like "%'+sqlwords[j-1]+'%"';
      if (j<>sqlwords.count) then sqltext:=sqltext+' and ';
     end;
    end;
    sqltext:=sqltext+')';


    Result.Query:= Format('SELECT %s FROM $DB$ ', [FIELDS]);
    Result.Query:=Result.Query+Format(' where %s and (%s)', [Format(' ((Rating >= %d) AND (Rating <= %d)) ',[FSearchParams.RatingFrom, FSearchParams.RatingTo]),
                                                      sqltext]);

    if FSearchParams.GroupName<>'' then
    Result.Query:=Result.Query+' AND (Groups like "'+GroupSearchByGroupName(FSearchParams.GroupName)+'")';

    if sqlrwords.count>0 then
    begin
     Result.Query:=Result.Query+' AND not (';
     sqltext:='(';
     for i:=1 to fields_names_count do
     begin
      if (i<>1) then
      sqltext:=sqltext+') or (';
      for j:=1 to sqlrwords.count do
      begin
       stemp:=sqlrwords[j-1];
       Delete(stemp,1,1);
       sqltext:=sqltext+''+fields_names[i]+' like "%'+stemp+'%"';
       if (j<>sqlrwords.count) then sqltext:=sqltext+' or ';
      end;
     end;
     sqltext:=sqltext+')';
     Result.Query:=Result.Query+sqltext+')';
    end;

    sqlwords.free;
    sqlrwords.free;
   end else
   begin
    sqltext:='(';
    s:=FSearchParams.Query;
    for i:=length(s) downto 1 do
    if not CharInSet(s[i], cifri) and (s[i]<>'$') then delete(s,i,1);
    if length(s)<2 then exit;
    n:=1;
    for i:=1 to length(s) do
    if s[i]='$' then
    begin
     s1:=copy(s,n,i-n);
     n:=i+1;
     sqltext:=sqltext+' (ID='+s1+') OR';
    end;
    sqltext:=sqltext+' (ID=0))';
    Result.Query:= Format('SELECT %s FROM $DB$ ', [FIELDS]);
    Result.Query:=Result.Query+' where ('+sqltext+')';

    if FSearchParams.GroupName<>'' then
    Result.Query:=Result.Query+' AND (Groups like "'+GroupSearchByGroupName(FSearchParams.GroupName)+'")';
   end;
   GetFilter(Result, db_attr_norm);
  end;
 end;

 Result.Query:=AddOptions(Result.Query);

end;

destructor SearchThread.Destroy;
begin
  F(FSearchParams);
  inherited;
end;

procedure SearchThread.DoOnDone;
var
  AData : TDBPopupMenuInfo;
begin
 try
  begin
   if fPictureSize=ThImageSize then
   if Assigned(FOnDone) then FOnDone(self);
   (ThreadForm as TSearchForm).StopLoadingList;
   //TODO:!!!if (ThreadForm as TSearchForm).SearchByCompating then
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
  //Loading big images
  if fPictureSize<>ThImageSize then
  begin
    (ThreadForm as TSearchForm).NewFormSubState;
     AData := TDBPopupMenuInfo.Create;
     AData.Assign(FData);
    (ThreadForm as TSearchForm).RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(ThreadForm,(ThreadForm as TSearchForm).SubStateID,nil,fPictureSize, AData, True));
  end;
 except
 end;
end;

procedure SearchThread.SetSearchPath;
begin
  (ThreadForm as TSearchForm).SetPath(StringParam);
end;

procedure SearchThread.SetSearchPathW(Path: String);
begin
 if not DirectoryExists(Path) then exit;
 StringParam:=Path;
 SynchronizeEx(SetSearchPath);
end;

procedure SearchThread.GetWideSearchOptions(Params : TDBQueryParams);
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
    Result := Result + ' AND (Access = 0)'
  else
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

function SearchThread.AddOptions(SqlQuery : string): string;
var
  SortDirection : string;

begin
  if (QueryType=QT_TEXT) or (QueryType=QT_GROUP) or (QueryType=QT_FOLDER) or (QueryType=QT_ONE_TEXT) or (QueryType=QT_ONE_KEYWORD) or (QueryType=QT_NO_NOPATH) then
  if not FSearchParams.ShowAllImages then
    SqlQuery := SqlQuery + ' and (Include=TRUE) ';

  if not FSearchParams.IsEstimate then
  begin
    SortDirection := '';
    if FSearchParams.SortDecrement then
      SortDirection := ' DESC';

    case FSearchParams.SortMethod of
      SM_TITLE :     Result := SqlQuery + ' ORDER BY Name'      + SortDirection;
      SM_DATE_TIME : Result := SqlQuery + ' ORDER BY DateToAdd' + SortDirection+', aTime' + SortDirection;
      SM_RATING:     Result := SqlQuery + ' ORDER BY Rating'    + SortDirection;
      SM_FILE_SIZE:  Result := SqlQuery + ' ORDER BY FileSize'  + SortDirection;
      SM_SIZE:       Result := SqlQuery + ' ORDER BY Width'     + SortDirection;
    end;
  end else
    Result := SqlQuery
end;

procedure SearchThread.DoSetSearchByComparing;
begin
  (ThreadForm as TSearchForm).DoSetSearchByComparing;
end;

procedure SearchThread.GetPassForFile;
begin
  StrParam := GetImagePasswordFromUser(StrParam);
end;

procedure SearchThread.LoadImages;
var
  FWorkQuery : TDataSet;
  FLastPacketTime : Cardinal;
  QueryParams : TDBQueryParams;

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
          BS.Free;
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
      JPEG.Free;
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
      while not FWorkQuery.Eof do
      begin
        if Terminated then
          Break;
        AddItem(FWorkQuery);

        if GetTickCount - FLastPacketTime > MIN_PACKET_TIME then
        begin
          SynchronizeEx(SendDataPacketToForm);
          FLastPacketTime := GetTickCount;
        end;
        FWorkQuery.Next;
      end;
      SynchronizeEx(SendDataPacketToForm);
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
    FWorkQuery.Free;
  end;
end;

procedure SearchThread.SendDataPacketToForm;
begin
  (ThreadForm as TSearchForm).LoadDataPacket(FData);
  FData.Clear;
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
