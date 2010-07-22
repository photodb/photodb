unit Loadingresults;

interface

uses
 ThreadManeger, UnitDBKernel, dolphin_db, jpeg, ComCtrls, CommCtrl, windows,
 Classes, Math, DB, SysUtils, Controls, Graphics, Dialogs, adodb,
 GraphicCrypt, forms, StrUtils, win32crc, EasyListview, DateUtils,
 UnitSearchBigImagesLoaderThread, UnitDBDeclare, UnitPasswordForm,
 UnitDBCommonGraphics, uThreadForm, uThreadEx, uLogger;

type
  TQueryType = (QT_NONE, QT_TEXT, QT_GROUP, QT_DELETED, QT_DUBLICATES,
                QT_FOLDER, QT_RESULT_ITH, QT_RESULT_IDS, QT_SIMILAR,
                QT_ONE_TEXT, QT_ONE_KEYWORD, QT_W_SCAN_FILE, QT_NO_NOPATH);

type
 TWideSearchOptions = record
  Enabled : Boolean;
  EnableDate : Boolean;
  MinDate : TDateTime;
  MaxDate : TDateTime;
  EnableRating : Boolean;
  MinRating : integer;
  MaxRating : integer;
  EnableID : Boolean;
  MinID : integer;
  MaxID : integer;
  Private_ : Boolean;
  Common_ : Boolean;
  Deleted_ : Boolean;
  ShowLastTime : Boolean;
  LastTimeValue : Integer;
  LastTimeCode : Integer;
  UseWideSearch : boolean;
  GroupName : string;
 end;

type
  SearchThread = class(TThreadEx)
  private
   fQuery: TDataSet;
   FI : integer;
   FID : integer;
   FPictureSize : integer;
   fitem: TEasyItem;

   BoolParam : boolean;
   fbit : TBitmap;
   fpic : TPicture;
   fBS : TStream;
   fthum_images_:integer;
   ferrormsg : string;
   foptions : integer;
   fInclude : Boolean;

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
  FWideSearch : TWideSearchOptions;
  IthIds : TArInteger;
  StrParam : String;
  IntParam : Integer;
  DefaultImage : TBitmap;
  procedure NewItem;
  procedure InitializeA;
  procedure InitializeB;
  procedure BeginUpdate;
  procedure EndUpdate;
  procedure ErrorSQL;
  procedure SetImageIndex;
  procedure ProgressNullA;
  procedure ProgressNull;
  procedure AddImageToList;
  procedure CreateQuery;
  procedure SaveHistory;
  Procedure DoOnDone;
  procedure SetSearchPathW(Path : String);
  procedure SetSearchPath;
  function GetWideSearchOptions : String;
  function AddOptions(S : string) : string;
  procedure ListViewImageIndex;
  Procedure SetProgressText(Value : String);
  Procedure SetProgressTextA;
  Procedure SetMaxValue(Value : Integer);
  Procedure SetMaxValueA;
  Procedure SetProgress(Value : Integer);
  Procedure SetProgressA;
  Procedure LoadThreadQuery;
  Procedure DoSetSearchByComparing;
  function GetFilter(Attr : Integer) : string;
  procedure GetPassForFile;
    { Private declarations }
  protected
    FSender : TThreadForm;
    RatingParam, LastMonth, LastYear, LastRating : integer;
    LastChar : Char;
    LastSize, SizeParam : int64;
    FileNameParam : String;
    FSID : TGUID;
    StrTh : String;
    QueryType : TQueryType;
    FDateTimeParam : TDateTime;

    fData : TSearchRecordArray;   
    fQData : TSearchRecordArray;

    QueryString : string;
    OnDone : TNotifyEvent;
    ShowPrivate : boolean;
    ShowRating : integer;
    UserQuery : string;
    FSortMethod : integer;
    FSortDecrement : Boolean;
    FShowGroups : boolean;
    BitmapParam : TBitmap;
    procedure Execute; override;
  public
      constructor Create(CreateSuspennded: Boolean; Sender : TThreadForm; SID : TGUID; Rating : Integer; FShowPrivate : Boolean; SortMethod : integer; SortDecrement : Boolean; Query : String; WideSearch_ : TWideSearchOptions; OnDone_ : TNotifyEvent; PictureSize : integer);
  end;

  const
      SPSEARCH_SHOWFOLDER = 1;
      SPSEARCH_SHOWTHFILE = 2;
      SPSEARCH_SHOWSIMILAR = 3;

procedure AddItemInListViewByGroups(ListView : TEasyListView; ID : Integer; SortMethod : integer;
      SortDecrement : boolean; ShowGroups : boolean; SizeParam : int64; FileNameParam : string; RatingParam : integer;
      DateTimeParam : TDateTime; Include : Boolean; var LastSize : int64; var LastChar : Char; var LastRating : integer;
      var LastMonth : integer; var LastYear : integer);

implementation

uses FormManegerUnit, Searching, ExplorerUnit, UnitGroupsWork, Language,
     CommonDBSupport, ExplorerThreadUnit;

constructor SearchThread.Create(CreateSuspennded: Boolean; Sender : TThreadForm; SID : TGUID; Rating : Integer; FShowPrivate : Boolean; SortMethod : integer; SortDecrement : Boolean; Query : String; WideSearch_ : TWideSearchOptions; OnDone_ : TNotifyEvent; PictureSize : integer);
begin         
 inherited Create(Sender, SID);
 FSender:=Sender;
 LastMonth:=0;
 LastRating:=-1;
 FPictureSize := PictureSize;
 LastChar := #0;
 SizeParam :=0;
 FileNameParam := '';
 LastYear:=0;
 FSID:=SID;
 OnDone:=OnDone_;
 FSortMethod:=SortMethod;
 FSortDecrement:=SortDecrement;
 ShowPrivate := FShowPrivate;
 ShowRating := Rating;
 UserQuery := Query;
 FWideSearch := WideSearch_;
 Start;
end;

procedure SearchThread.AddImageToList;
begin
  (FSender as TSearchForm).FBitmapImageList.AddBitmap(fbit);
end;

procedure SearchThread.ProgressNull;
begin
  (FSender as TSearchForm).PbProgress.Position:=0;
  (FSender as TSearchForm).PbProgress.text:=TEXT_MES_DONE;
end;

procedure SearchThread.ProgressNullA;
begin
  (FSender as TSearchForm).PbProgress.Position:=0;
  (FSender as TSearchForm).PbProgress.text:=TEXT_MES_PROGRESS_PR;
end;

procedure SearchThread.SetImageIndex;
begin
  (FSender as TSearchForm).ReplaceImageIndexWithPath(fData[IntParam].FileName,(FSender as TSearchForm).FBitmapImageList.Count-1);
  (FSender as TSearchForm).PbProgress.Position:=fthum_images_;
end;

procedure SearchThread.BeginUpdate;
begin
  (FSender as TSearchForm).BeginUpdate;
end;

procedure SearchThread.EndUpdate;
begin
  with (FSender as TSearchForm) do
    Data:=fData;

  (FSender as TSearchForm).EndUpdate;
end;

procedure SearchThread.ErrorSQL;
begin
 (FSender as TSearchForm).ErrorQSL(ferrormsg);
end;

procedure SearchThread.Execute;
var
  i, c, x : integer;
  fSpecQuery : TDataSet;
  PassWord,tempsql : string;
  JPEG : TJPEGImage;
  FTable : TDataSet;
  pic : TPicture;
  SBitmap, TempBitmap : TBitmap;
  CmpResult : TImageCompareResult;
  w,h, rot : integer;
  crc : Cardinal;
  paramno : integer;
  Count : integer;

  function NextParam : integer;
  begin
   Result:=paramno;
   inc(paramno);
  end;

  procedure AddItem(N: integer; S : TDataSet);
  var
    i : integer;
    Data : TSearchRecord;
  begin
    fid:=S.FieldByName('ID').asinteger;
    fInclude:=S.FieldByName('Include').AsBoolean;
    FI:=N;
    
    FDateTimeParam :=S.FieldByName('DateToAdd').AsDateTime;

    RatingParam:=S.FieldByName('Rating').AsInteger;
    SizeParam:=S.FieldByName('FileSize').AsInteger;
    FileNameParam:=AnsiLowerCase(S.FieldByName('FFileName').AsString);

    SynchronizeEx(NewItem);
    Dec(N);
    Data := fData[N];
    Data.ID:=fid;
    Data.FileName := FileNameParam;
    Data.Comments := S.FieldByName('Comment').AsString;
    Data.FileSize := SizeParam;
    Data.Rotation := S.FieldByName('Rotated').AsInteger;
    Data.ImTh := S.FieldByName('StrTh').AsString;
    Data.Access := S.FieldByName('Access').AsInteger;
    Data.Rating := RatingParam;
    Data.KeyWords := S.FieldByName('KeyWords').AsString;
    Data.Date := FDateTimeParam;
    Data.IsDate := S.FieldByName('IsDate').AsBoolean;
    Data.IsTime := S.FieldByName('IsTime').AsBoolean;
    Data.Groups := S.FieldByName('Groups').AsString;
    Data.Attr := S.FieldByName('Attr').AsInteger;
    Data.Time := S.FieldByName('aTime').AsDateTime;
    Data.Links := S.FieldByName('Links').AsString;
    Data.Width := S.FieldByName('Width').AsInteger;
    Data.Height := S.FieldByName('Height').AsInteger;
    Data.Crypted := ValidCryptBlobStreamJPG(S.FieldByName('thum'));
    Data.Include := fInclude;
    Data.Exists := 0;
    Data.CompareResult.ByGistogramm := 0;
    Data.CompareResult.ByPixels := 0;
    if fQData.Count > 0 then
    begin
     for i:=0 to fQData.Count - 1 do
     if fQData[i].ID = fid then
     begin
      Data.CompareResult:= fQData[i].CompareResult;
     end;
    end;
  end;

begin    
  FreeOnTerminate := True;
  ParamNo:=0;

  //#8 - invalid query identify, needed from script executing
  if UserQuery = #8 then
    Exit;

  SynchronizeEx(BeginUpdate);
  fQuery := GetQuery;
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

          pic.Graphic:=GraphicCrypt.DeCryptGraphicFile(fSpsearch_ScanFile,PassWord);
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



            FWideSearch.MaxDate := Trunc(FWideSearch.MaxDate);
            FWideSearch.MinDate := Trunc(FWideSearch.MinDate);
            x:=FWideSearch.LastTimeValue;
            case FWideSearch.LastTimeCode of
              0 : x:=x;
              1 : x:=x*7;
              2 : x:=x*30;
              3 : x:=x*365;
            end;
            x := Round(Now) - x;

            c := 0;
            FTable:=GetQuery;
            try
              tempsql:='Select ID, Thum from '+GetDefDBName+' Where ';
              tempsql:=tempsql+Format(' (Rating >= %d) ',[showrating]);
              if FWideSearch.GroupName<>'' then
                tempsql:=tempsql+' AND (Groups like "'+GroupSearchByGroupName(FWideSearch.GroupName)+'")';

              if FWideSearch.ShowLastTime then
                tempsql:=tempsql+' AND (DateToAdd > :DateToAdd) ';

              if FWideSearch.EnableDate then
                tempsql:=tempsql+' AND ((DateToAdd > :MinDate) and (DateToAdd<:MaxDate)) ';

              SetSQL(FTable,tempsql);
              if FWideSearch.ShowLastTime then
              begin
               SetDateParam(FTable,c,x);
               inc(c);
              end;

              if FWideSearch.EnableDate then
              begin
                SetDateParam(FTable,c,FWideSearch.MinDate);
                inc(c);
                SetDateParam(FTable,c,FWideSearch.MaxDate);
              end;

              FTable.Active:=true;
              FTable.First;

              intParam := FTable.RecordCount;
              SynchronizeEx(initializeB);
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
        QueryString := 'SELECT * FROM '+GetDefDBname+' WHERE ';

        if FWideSearch.GroupName <> '' then
          QueryString:=QueryString+' (Groups like "'+GroupSearchByGroupName(FWideSearch.GroupName)+'") AND ';

        QueryString:=QueryString+' ID in (';
        for i:=0 to fQData.Count-1 do
          if i=0 then QueryString:=QueryString+' '+inttostr(fQData[i].ID)+' ' else
        QueryString:=QueryString+' , '+inttostr(fQData[i].ID)+'';
        QueryString:=AddOptions(QueryString+') '+GetFilter(db_attr_norm)+' ');
      end;
    end;

    try
      //ITS amazing!
      TADOQuery(fQuery).CursorType := ctOpenForwardOnly;
      //TADOQuery(fQuery).ExecuteOptions := [eoAsyncFetchNonBlocking];
      QueryString := SysUtils.StringReplace(QueryString, '''', ' ', [rfReplaceAll]);
      QueryString := SysUtils.StringReplace(QueryString, '\', ' ', [rfReplaceAll]);
      SetSQL(fQuery, QueryString);

      //??????????????????????????????
      if FWideSearch.ShowLastTime then
        x:=1
      else
        x:=0;
        
      if FWideSearch.EnableDate then
      begin
        SetDateParam(fQuery, QueryParamsCount(fQuery)-2-x, Trunc(FWideSearch.MinDate));
        SetDateParam(fQuery, QueryParamsCount(fQuery)-1-x, Trunc(FWideSearch.MaxDate));
      end;

      x:=FWideSearch.LastTimeValue;
      case FWideSearch.LastTimeCode of
        0 : x:=x;
        1 : x:=x*7;
        2 : x:=x*30;
        3 : x:=x*365;
      end;

      if (QueryType=QT_TEXT) or (QueryType=QT_GROUP) or (QueryType=QT_FOLDER) or (QueryType=QT_ONE_TEXT) or (QueryType=QT_ONE_KEYWORD) or (QT_NO_NOPATH=QueryType) then
      if FWideSearch.ShowLastTime then
        SetDateParam(fQuery,QueryParamsCount(fQuery)-1,Round(Now)-x);

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
         SynchronizeEx(LoadThreadQuery);
       except
         on e : Exception do
         begin
           EventLog(':SearchThread::LoadThreadQuery() throw exception: '+e.Message);
           fErrorMsg:=e.Message+#13+TEXT_MES_QUERY_FAILED;
           SynchronizeEx(ErrorSQL);
         end;
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
         SynchronizeEx(InitializeA);
         fQuery.First;
       end;
       c := 0;
       fQuery.First;
       for I := 1 to fQuery.RecordCount do
       begin
         if Terminated then
           Break;
         AddItem(i, FQuery);
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
       SynchronizeEx(ProgressNull);
       SynchronizeEx(DoOnDone);
       Exit;
     end;
     try
       fpic := TPicture.create;
       fpic.Graphic := TJPEGImage.Create;
       fthum_images_ := 1;
       SynchronizeEx(ProgressNullA);
       if SearchManager.IsSearch(FSender) then
       begin
         fQuery.First;
         for I := 1 to fQuery.RecordCount do
         begin
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
            SynchronizeEx(AddImageToList);
            SynchronizeEx(SetImageIndex);
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
  
  SynchronizeEx(ProgressNull);
  SynchronizeEx(DoOnDone);
end;

procedure SearchThread.InitializeA;
begin
  with (FSender as TSearchForm) do
  begin
    FShowGroups:=DBKernel.Readbool('Options','UseGroupsInSearch',true);
    ListView.ShowGroupMargins:=FShowGroups;
    PbProgress.Position:=0;
    PbProgress.MaxValue:=fQuery.RecordCount;
    Label7.Caption:=format(TEXT_MES_RES_REC,[IntToStr(fQuery.RecordCount)]);
    PbProgress.Text:=TEXT_MES_LOAD_QUERY_PR;
  end;
end;

procedure SearchThread.InitializeB;
begin
  with (FSender as TSearchForm) do
  begin
    PbProgress.Position:=0;
    PbProgress.MaxValue:=intparam;
    Label7.Caption:=TEXT_MES_SEARCH_FOR_REC;
    PbProgress.Text:=format(TEXT_MES_SEARCH_FOR_REC_FROM,[IntToStr(intparam)]);
  end;
end;


procedure AddItemInListViewByGroups(ListView : TEasyListView; ID : Integer; SortMethod : integer;
      SortDecrement : boolean; ShowGroups : boolean; SizeParam : int64; FileNameParam : string; RatingParam : integer;
      DateTimeParam : TDateTime; Include : Boolean; var LastSize : int64; var LastChar : Char; var LastRating : integer;
      var LastMonth : integer; var LastYear : integer);
var
  new: TEasyItem;
  i,i10 : integer;
  DataObject : TDataObject;
begin
  if (SortMethod=0) or not ShowGroups then
  begin
   if ListView.Groups.Count=0 then
   With ListView.Groups.Add do
   begin
    Visible:=true;
    Caption:=TEXT_MES_RECORDS_FOUNDED+':';
   end;
  end;

  if ShowGroups then
  if SortMethod=4 then
  begin
   if not SortDecrement then
   begin
    if (LastSize=0) and (SizeParam<100*1024) then
    begin
     LastSize:=max(1,SizeParam);
     With ListView.Groups.Add do
     begin
      Caption:=TEXT_MES_LESS_THAN+' '+SizeInTextA(1024*100);
      Visible:=true;
     end;
    end else
    begin
     if SizeParam<1000*1024 then
     begin
      i10:=Trunc(SizeParam/(100*1024))*10*1024;
      i:=i10*10;
      if (LastSize<i+i10) and (SizeParam>100*1024) then
      With ListView.Groups.Add do
      begin
       LastSize:=i+i10;
       Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(i);
       Visible:=true;
      end;
     end else
     begin
      if SizeParam<1024*1024*10 then
      begin
       i10:=Trunc(SizeParam/(1024*1024))*100*1024;
       i:=round(i10*10/(1024*1024))*1024*1024;
       if (i=0) then
       With ListView.Groups.Add do
       begin
        i:=1024*1024;
        LastSize:=i+i10;
        Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(i);
        Visible:=true;
       end;
       if (LastSize<i+i10) and (SizeParam>1024*1024) then
       With ListView.Groups.Add do
       begin
        LastSize:=i+i10;
        Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(i);
        Visible:=true;
       end;
      end else
      begin
       if SizeParam<1024*1024*100 then
       begin
        i10:=Trunc(SizeParam/(1024*1024*10))*1000*1024;
        i:=round(i10*10/(1024*1024*10))*1024*1024*10;
        if (i=0) then
        With ListView.Groups.Add do
        begin
         i:=1024*1024*10;
         LastSize:=i+i10;
         Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(i);
         Visible:=true;
        end;
        if (LastSize<i+i10) and (SizeParam>1024*1024*10) then
        With ListView.Groups.Add do
        begin
         LastSize:=i+i10;
         Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(i);
         Visible:=true;
        end;
       end else
       begin
        With ListView.Groups.Add do
        begin
         LastSize:=1024*1024*100;
         Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(1024*1024*100);
         Visible:=true;
        end;
       end;
      end;
     end;
    end;
   end else
   begin
    begin
     if SizeParam<901*1024 then
     begin
      i10:=Trunc(SizeParam/(1024*100))*1024*100;
      if (Abs(LastSize-SizeParam)>1024*100) and (SizeParam>0) or (LastSize=0) then
      With ListView.Groups.Add do
      begin
       LastSize:=i10+1024*100;
       Caption:=TEXT_MES_LESS_THAN+' '+SizeInTextA(i10+1024*100);
       Visible:=true;
      end;
     end else
     begin
      if SizeParam<1024*1024*10 then
      begin
       i10:=Trunc(SizeParam/(1024*1024))*1024*1024;
       if (Abs(LastSize-SizeParam)>1024*1024) and (SizeParam>1024*1024) or (LastSize=0) then
       With ListView.Groups.Add do
       begin
        LastSize:=i10+1024*1024;
        Caption:=TEXT_MES_LESS_THAN+' '+SizeInTextA(i10+1024*1024);
        Visible:=true;
       end;
      end else
      begin
       if SizeParam<1024*1024*100 then
       begin                                  
        i10:=Trunc(SizeParam/(1024*1024*10))*1024*1024*10;
        if (Abs(LastSize-SizeParam)>1024*1024*10) and (SizeParam>1024*1024*10) or (LastSize=0)  then
        With ListView.Groups.Add do
        begin
         LastSize:=i10+1024*1024*10;
         Caption:=TEXT_MES_LESS_THAN+' '+SizeInTextA(i10+1024*1024*10);
         Visible:=true;
        end;
       end else
       begin
        With ListView.Groups.Add do
        begin
         LastSize:=1024*1024*100;  
         Caption:=TEXT_MES_MORE_THAN+' '+SizeInTextA(1024*1024*100);
         Visible:=true;
        end;
       end;
      end;
     end;
    end;
   end;
  end;



  if ShowGroups then
  if SortMethod=1 then
  if ExtractFilename(FileNameParam)<>'' then
  begin
   if LastChar<>ExtractFilename(FileNameParam)[1] then
   begin
    LastChar:=ExtractFilename(FileNameParam)[1];
    With ListView.Groups.Add do
    begin
     Caption:=LastChar;
     Visible:=true;
    end;
   end;
  end;

  if ShowGroups then
  if SortMethod=3 then //by Rating
  if LastRating<>RatingParam then
  begin
   LastRating:=RatingParam;
   With ListView.Groups.Add do
   begin
    if RatingParam=0 then
    Caption:=TEXT_MES_NO_RATING+':' else
    Caption:=TEXT_MES_RATING+': '+IntToStr(LastRating);
    Visible:=true;
   end;
  end;

  if ShowGroups then
  if SortMethod=2 then //by DateTime
  if (YearOf(DateTimeParam)<>LastYear) or (MonthOf(DateTimeParam)<>LastMonth) then
  begin
   LastYear:=YearOf(DateTimeParam);
   LastMonth:=MonthOf(DateTimeParam);
   With ListView.Groups.Add do
   begin
    Caption:=FormatDateTime('yyyy, mmmm',DateTimeParam);
    Visible:=true;
   end;
  end;

 DataObject:=TDataObject.Create;
 DataObject.Include := Include;

 new := ListView.Items.Add(DataObject);
 new.Tag:=ID;
 new.ImageIndex:=-1;
 new.Caption:=ExtractFileName(FileNameParam);
end;

procedure SearchThread.NewItem;
begin
  if QueryType <> QT_W_SCAN_FILE then
  begin
   (FSender as TSearchForm).PbProgress.Position:=fi;
  end;
  AddItemInListViewByGroups((FSender as TSearchForm).ListView, FID, fSortMethod, fSortDecrement, fShowGroups, SizeParam,
    FileNameParam, RatingParam, fDateTimeParam, fInclude, LastSize, LastChar, LastRating, LastMonth, LastYear);
end;

function SearchThread.GetFilter(Attr : Integer) : string;
begin
  Result:='';
  if db_attr_norm=Attr then
  begin
   Result:=Result+' AND ';
   Result:=Result+Format('(Attr<> %d)',[db_attr_not_exists]);
  end;
  if db_attr_dublicate=Attr then
  begin
   Result:=Result+Format('(Attr= %d)',[db_attr_dublicate]);
  end;
  if db_attr_not_exists=Attr then
  begin
   Result:=Result+Format('(Attr= %d)',[db_attr_not_exists]);
  end;

  if not FWideSearch.EnableRating then
  Result:=Result+' AND (Rating>='+inttostr(showrating)+')';
  if FWideSearch.Enabled=false then
  if not ShowPrivate then Result:=Result+' AND (Access=0)';

  Result:=Result+GetWideSearchOptions;
end;

procedure SearchThread.CreateQuery;
var
  Folder, SysAction, stemp,s1,s,sqltext,sqlquery:string;
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

begin
 QueryType:=QT_NONE;
 foptions:=0;
 sqltext:=userquery;
 SynchronizeEx(savehistory);
 if sqltext='' then sqltext:='*';
 systemquery:=false;
 if length(sqltext)>3 then
 begin
  if (sqltext[1]='%') and (sqltext[2]=':') and (sqltext[length(sqltext)]=':') then
  begin
   Delete(sqltext,1,1);
   FWideSearch.Enabled:=false;
   FWideSearch.EnableDate:=false;
   FWideSearch.EnableRating:=false;
   FWideSearch.EnableID:=false;
   FWideSearch.Private_:=true;
   FWideSearch.Common_:=true;
   FWideSearch.Deleted_:=true;
   FWideSearch.ShowLastTime:=false;
   FWideSearch.UseWideSearch:=true;
   showrating:=0;
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
   sqlquery:='SELECT * FROM '+GetDefDBName+' WHERE ';
   sqlquery:=sqlquery+GetFilter(db_attr_not_exists);
  end;

  if AnsiLowerCase(sysaction)=AnsiLowerCase('Dublicates') then
  begin
   QueryType:=QT_DUBLICATES;
   SystemQuery:=true;
   sqlquery:='SELECT * FROM '+GetDefDBName+' WHERE';
   sqlquery:=sqlquery+GetFilter(db_attr_dublicate);
  end;

  if AnsiLowerCase(copy(sysaction,1,5))=AnsiLowerCase('Group') then
  begin
   QueryType:=QT_GROUP;
   SystemQuery:=true;
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where (Groups like "'+GroupSearchByGroupName(Copy(sysaction,7,length(sysaction)-7))+'")';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,4))=AnsiLowerCase('Text') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   stemp:=Copy(sysaction,6,length(sysaction)-6);
   stemp:=NormalizeDBString(stemp);
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where (KeyWords like "%'+stemp+'%") or (Comment like "%'+stemp+'%") or (FFileName like "%'+stemp+'%")';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,6))=AnsiLowerCase('nopath') then
  if GetDBType=DB_TYPE_MDB then
  begin
   QueryType:=QT_NO_NOPATH;
   SystemQuery:=true;
   stemp:=Copy(sysaction,6,length(sysaction)-6);
   stemp:=NormalizeDBString(stemp);
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where (FolderCRC = 0)';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,14))=AnsiLowerCase('ShowNullFields') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   sqlquery:='SELECT * FROM '+GetDefDBName;
   sqlquery:=sqlquery+' where (Comment is null) or (KeyWords is null) or (Groups is null) or (Links is null)';
  end;

  if AnsiLowerCase(copy(sysaction,1,13))=AnsiLowerCase('FixNullFields') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   fSpecQuery:=GetQuery;
   sqlquery:='SELECT * FROM '+GetDefDBName;
   sqlquery:=sqlquery+' where (Comment is null) or (KeyWords is null) or (Groups is null) or (Links is null)';

   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Comment="" where Comment is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set KeyWords="" where KeyWords is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Groups="" where Groups is null');
   ExecSQL(fSpecQuery);
   SetSQL(fSpecQuery,'Update '+GetDefDBName+' Set Links="" where Links is null');
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
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where not (StrTh like "'+stemp+'")';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,5))=AnsiLowerCase('Links') then
  begin
   QueryType:=QT_ONE_TEXT;
   SystemQuery:=true;
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where (Links like "%[%]%{%}%;%" )';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
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
   sqlquery:='SELECT * FROM '+GetDefDBName+'';
   sqlquery:=sqlquery+' where (KeyWords like "%'+stemp+'%") ';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;

  if AnsiLowerCase(copy(sysaction,1,6))=AnsiLowerCase('folder') then
  begin
   QueryType:=QT_FOLDER;
   systemquery:=true;

   Folder:=copy(sysaction,8,length(sysaction)-8);
   UnFormatDir(Folder);
   Folder:=AnsiLowerCase(Folder);

   if GetDBType=DB_TYPE_MDB then sqlquery:='Select * From (Select * from '+GetDefDBname+' where FolderCRC=:crc) where (FFileName Like :ffilenameA) and not (FFileName like :ffilenameB)';

   if not showprivate then sqlquery:=sqlquery+' and (Access<>'+inttostr(db_access_private)+')';

   foptions:=SPSEARCH_SHOWFOLDER;
   if not directoryexists(Folder) then
   fspsearch_showfolder:='' else fspsearch_showfolder:=Folder;
   fspsearch_showfolderid:=StrToIntDef(Copy(sysaction,8,length(sysaction)-8),0);
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;
  
  if AnsiLowerCase(copy(sysaction,1,7))=AnsiLowerCase('similar') then
  begin
   QueryType:=QT_SIMILAR;
   systemquery:=true;
   Sid:=copy(sysaction,9,length(sysaction)-9);
   id:=StrToIntDef(Sid,0);


   fSpecQuery := GetQuery;
   SetSQL(fSpecQuery,'SELECT StrTh FROM '+GetDefDBname+' WHERE ID = '+IntToStr(id));
   fSpecQuery.Open;
   StrTh:=fSpecQuery.FieldByName('StrTh').AsString;
   FreeDS(fSpecQuery);

   sqlquery:='SELECT * FROM '+GetDefDBName+' WHERE StrTh = :str';

   if not showprivate then sqlquery:=sqlquery+' and (Access<>'+inttostr(db_access_private)+')';

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
   SetProgressText(TEXT_MES_CONVERTING);

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
    SQLText:='SELECT ID FROM '+GetDefDBName+' WHERE ';
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
   sqlquery:='SELECT * FROM '+GetDefDBName+' Where (';
   for i:=0 to Length(IthIds)-1 do
   begin
    if first then
    begin
      sqlquery:= sqlquery+' (ID='+IntToStr(IthIds[i])+') ';
     First:=false;
    end else
    sqlquery:= sqlquery+' OR (ID='+IntToStr(IthIds[i])+') ';
   end;
   if Length(IthIds)=0 then
   sqlquery:= sqlquery+'(ID=0) ';
   sqlquery:= sqlquery+' ) ';
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
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
    if not (stemp[i] in ['C','K','F','G','L']) then
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


    sqlquery:='SELECT * FROM '+GetDefDBName;
    sqlquery:=sqlquery+' where ('+sqltext+')';

    if FWideSearch.GroupName<>'' then
    sqlquery:=sqlquery+' AND (Groups like "'+GroupSearchByGroupName(FWideSearch.GroupName)+'")';

    if sqlrwords.count>0 then
    begin
     sqlquery:=sqlquery+' AND not (';
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
     sqlquery:=sqlquery+sqltext+')';
    end;

    sqlwords.free;
    sqlrwords.free;
   end else
   begin
    sqltext:='(';
    s:=userquery;
    for i:=length(s) downto 1 do
    if not (s[i] in cifri) and (s[i]<>'$') then delete(s,i,1);
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
    sqlquery:='SELECT * FROM '+GetDefDBName;
    sqlquery:=sqlquery+' where ('+sqltext+')';
    
    if FWideSearch.GroupName<>'' then
    sqlquery:=sqlquery+' AND (Groups like "'+GroupSearchByGroupName(FWideSearch.GroupName)+'")';
   end;
   sqlquery:=sqlquery+GetFilter(db_attr_norm);
  end;
 end;

 QueryString:=AddOptions(sqlquery);

end;

procedure SearchThread.SaveHistory;
begin
 //TODO: different from base
 DBKernel.WriteString('Search_DB_'+DBKernel.GetDataBaseName,'OldValue',UserQuery);
 DBKernel.WriteInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMinRating',ShowRating);
 DBKernel.WriteInteger('Search_DB_'+DBKernel.GetDataBaseName,'OldMethod',FSortMethod);
 DBKernel.WriteBool('Search_DB_'+DBKernel.GetDataBaseName,'OldMethodDecrement',FSortDecrement);
 DBKernel.WriteBool('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTime',FWideSearch.ShowLastTime);
 DBKernel.WriteInteger('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTimeValue',FWideSearch.LastTimeValue);
 DBKernel.WriteInteger('Search_DB_'+DBKernel.GetDataBaseName,'ShowLastTimeCode',FWideSearch.LastTimeCode);
 DBKernel.WriteBool('Search_DB_'+DBKernel.GetDataBaseName,'UseWideSearch',FWideSearch.UseWideSearch);
end;

procedure SearchThread.DoOnDone;
begin
 try
  begin
   if fPictureSize=ThImageSize then
   if Assigned(OnDone) then OnDone(self);
   (FSender as TSearchForm).ToolButton14.Enabled:=false;
   if (FSender as TSearchForm).SearchByCompating then
   begin
    (FSender as TSearchForm).Decremect1.Checked:=true;
    (FSender as TSearchForm).SortbyCompare1Click((FSender as TSearchForm).SortbyCompare1);
   end else
   begin
    if (FSender as TSearchForm).SortbyCompare1.Checked then
    begin
     (FSender as TSearchForm).SortbyDate1Click((FSender as TSearchForm).SortbyDate1);
    end;
   end;
  end;
  //Loading big images
  if fPictureSize<>ThImageSize then
    (FSender as TSearchForm).RegisterThreadAndStart(TSearchBigImagesLoaderThread.Create(True,fSender,FSID,nil,fPictureSize,fData));
 except
 end;
end;

procedure SearchThread.SetSearchPath;
begin
  (FSender as TSearchForm).SetPath(StringParam);
end;

procedure SearchThread.SetSearchPathW(Path: String);
begin
 if not DirectoryExists(Path) then exit;
 StringParam:=Path;
 SynchronizeEx(SetSearchPath);
end;

function SearchThread.GetWideSearchOptions: String;
begin
 Result:='';

  if not showprivate then Result:=Result+' AND (Access=0)' else

  Result:=Result+' AND (Attr<>'+inttostr(db_attr_not_exists)+')';

  if FWideSearch.EnableDate then
  begin
   Result:=Result+' AND ((DateToAdd >= :MinDate ) and (DateToAdd <= :MaxDate ) and IsDate=True) ';
  end;
  if FWideSearch.EnableRating then
  begin
   Result:=Result+' AND ((Rating>='+IntToStr(FWideSearch.MinRating)+') and (Rating<='+IntToStr(FWideSearch.MaxRating)+')) ';
  end;
  if FWideSearch.EnableID then
  begin
   Result:=Result+' AND ((ID>='+IntToStr(FWideSearch.MinID)+') and (ID<='+IntToStr(FWideSearch.MaxID)+')) ';
  end;
  if FWideSearch.Enabled then
  begin

   if not (FWideSearch.Common_) then
   Result:=Result+' AND (Access<>'+inttostr(db_access_none)+') ';
   Result:=Result+' AND (Attr='+inttostr(db_attr_norm)+')';
  end;
end;

procedure SearchThread.SetMaxValue(Value: Integer);
begin
 IntParam:=Value;
 SynchronizeEx(SetMaxValueA);
end;

procedure SearchThread.SetMaxValueA;
begin
  (FSender as TSearchForm).PbProgress.MaxValue:=IntParam;
end;

procedure SearchThread.SetProgress(Value: Integer);
begin
 IntParam:=Value;
 SynchronizeEx(SetProgressA);
end;

procedure SearchThread.SetProgressA;
begin
  (FSender as TSearchForm).PbProgress.Position:=IntParam;
end;

procedure SearchThread.SetProgressText(Value: String);
begin
 StrParam:=Value;
 SynchronizeEx(SetProgressTextA);
end;

procedure SearchThread.SetProgressTextA;
begin
  (FSender as TSearchForm).PbProgress.Text:=StrParam;
end;

procedure SearchThread.ListViewImageIndex;
begin
  IntParam:=(FSender as TSearchForm).GetImageIndexWithPath(FData[IntParam].FileName);
end;

procedure SearchThread.LoadThreadQuery;
begin
  SetSQL((FSender as TSearchForm).ThreadQuery,GetQueryText(fQuery));
  AssignParams(fQuery,(FSender as TSearchForm).ThreadQuery);
end;

function SearchThread.AddOptions(s : string): string;
var
  sqlquery : string;

  function DESC : string;
  begin
   if FSortDecrement then result:=' DESC'
  end;

begin
 sqlquery:=S;
 if (QueryType=QT_TEXT) or (QueryType=QT_GROUP) or (QueryType=QT_FOLDER) or (QueryType=QT_ONE_TEXT) or (QueryType=QT_ONE_KEYWORD) or (QueryType=QT_NO_NOPATH) then
 if FWideSearch.ShowLastTime then
 sqlquery:=sqlquery+' AND (DateToAdd>=:mindate)';

 if (QueryType=QT_TEXT) or (QueryType=QT_GROUP) or (QueryType=QT_FOLDER) or (QueryType=QT_ONE_TEXT) or (QueryType=QT_ONE_KEYWORD) or (QueryType=QT_NO_NOPATH) then
 if not FWideSearch.UseWideSearch then
 sqlquery:=sqlquery+' and (Include=TRUE) ';

 Case FSortMethod of
 0 : Result:=sqlquery;
 1 : Result:=sqlquery+' order by Name'+DESC;
 2 : Result:=sqlquery+' order by DateToAdd'+DESC+', aTime'+DESC;
 3:  Result:=sqlquery+' order by Rating'+DESC;
 4:  Result:=sqlquery+' order by FileSize'+DESC;
 5:  Result:=sqlquery+' order by Width'+DESC;
 else Result:=sqlquery;
 end;
end;

procedure SearchThread.DoSetSearchByComparing;
begin
 (FSender as TSearchForm).DoSetSearchByComparing;
end;

procedure SearchThread.GetPassForFile;
begin
 StrParam:=GetImagePasswordFromUser(StrParam);
end;

end.
