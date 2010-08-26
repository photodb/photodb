unit UnitCmpDB;

interface

uses
  UnitGroupsReplace, CmpUnit, Classes, DB, dolphin_db, SysUtils,
  UnitGroupsWork, UnitLinksSupport, GraphicCrypt, JPEG, CommonDBSupport,
  UnitDBDeclare;

type
  CmpDBTh = class(TThread)
  private
  FQuery  : TDataSet;
  FSourceTable : TDataSet;
  FPostQuery  : TDataSet;
  FProgress : integer;
  FMaxValue : integer;
  FOptions : TCompOptions;
  fIgnoredWords : string;
  fAutor : string;

  IntParam : Integer;
  StrParam : String;

  FParamTempGroup : TGroups;
  FParamFOutRegGroups : TGroups;
  FParamFRegGroups : TGroups;
  FParamGroupsActions : TGroupsActionsW;
    { Private declarations }
  protected
    procedure AddNewRecord;
    procedure AddNewRecordA;
    procedure AddUpdatedRecord;
    procedure AddUpdatedRecordA;
    procedure SetPosition(Value : Integer);
    procedure SetPositionA;
    procedure SetMaxValue(Value : Integer);
    procedure SetMaxValueA;
    procedure SetStatusText(Value : string);
    procedure SetStatusTextA;
    procedure SetActionText(Value : string);
    procedure SetActionTextA;
    procedure Execute; override;
    procedure Post(SQL : string);
    procedure IfPause;
    procedure ThreadExit;
    procedure FilterGroupsSync;
  end;

  var
    Autor, IgnoredWords, SourceTableName  : string;
    Terminated_ : boolean = false;
    Active_ : boolean = false;
    Paused : boolean = false;
    Options : TCompOptions;

implementation

uses UnitCompareProgress, UnitExportThread, Language,
      UnitUpdateDBThread;

{ UnitCmpDB }

procedure CmpDBTh.AddNewRecord;
begin
 Synchronize(AddNewRecordA);
end;

procedure CmpDBTh.AddNewRecordA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.AddNewRecord;
end;

procedure CmpDBTh.AddUpdatedRecord;
begin
 Synchronize(AddUpdatedRecordA);
end;

procedure CmpDBTh.AddUpdatedRecordA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.AddUpdatedRecord;
end;

function GetImageIDFileNameW(DBFileName, FN: String; JPEG : TJPEGImage): TImageDBRecordA;
var
  FQuery : TDataSet;
  i, count, rot:integer;
  res : TImageCompareResult;
  val : array of boolean;
  xrot : array of integer;
  FJPEG  :TJPEGImage;
  Pass : string;
begin
 if JPEG=nil then
 begin
  Result.ImTh:='';
  SetLength(Result.IDs,0);
  exit;
 end;
 fQuery:=GetQuery(DBFileName);
 SetSQL(fQuery,'SELECT ID, FFileName, Attr, StrTh, Thum FROM '+GetTableNameByFileName(DBFileName)+' WHERE FFileName like :str ');
 SetStrParam(fQuery,0,'%'+ NormalizeDBString(normalizeDBStringLike((AnsiLowerCase(ExtractFileName(FN)))))+'%');
 try
  fQuery.active:=true;
 except
  fQuery.Free;
  setlength(result.ids,0);
  setlength(result.FileNames,0);
  setlength(result.Attr,0);
  result.count:=0;
  result.ImTh:='';
  exit;
 end;

 fQuery.First;

 SetLength(val,fQuery.RecordCount);
 SetLength(xrot,fQuery.RecordCount);
 count:=0;
 FJPEG:=nil;
 for i:=1 to fQuery.RecordCount do
 begin
  if ValidCryptBlobStreamJPG(fQuery.FieldByName('Thum')) then
  begin
   Pass:='';
   Pass:=DBkernel.FindPasswordForCryptBlobStream(fQuery.FieldByName('Thum'));
   FJPEG  := TJPEGImage.Create;
   if Pass <> '' then
     DeCryptBlobStreamJPG(fQuery.FieldByName('Thum'),Pass, FJPEG);

  end else
  begin
   FJPEG  := TJPEGImage.Create;
   FJPEG.Assign(fQuery.FieldByName('Thum'));
  end;
  res:=CompareImages(FJPEG,JPEG,rot);
  xrot[i-1]:=rot;
  val[i-1]:=(res.ByGistogramm>1) or (res.ByPixels>1);
  if val[i-1] then inc(count);
  fQuery.Next;
 end;
 if FJPEG<>nil then FJPEG.Free;

 setlength(result.ids,count);
 setlength(result.FileNames,count);
 setlength(result.Attr,count);
 setlength(result.ChangedRotate,count);

 result.count:=count;
 fQuery.First;
 count:=-1;
 for i:=1 to fQuery.RecordCount do
 if val[i-1] then
 begin
  inc(count);
  result.ChangedRotate[count]:=xrot[count]<>0;
  result.ids[count]:=fQuery.FieldByName('ID').AsInteger;
  result.FileNames[count]:=fQuery.FieldByName('FFileName').AsString;
  result.Attr[count]:=fQuery.FieldByName('Attr').AsInteger;
  result.ImTh:=fQuery.FieldByName('StrTh').AsString;
  fQuery.Next;
 end;
 FreeDS(fQuery);
end;



procedure CmpDBTh.Execute;
var
  res, Updated, FE : boolean;
  i, j : integer;
  OldGroups, Groups, Groups_, StrTh, r, KeyWords, KeyWords_, _sqlexectext : string;
  FTempGroup, FRegGroups, FOutRegGroups : TGroups;
  GroupsActions : TGroupsActionsW;
  SLinks, DLinks : TLinksInfo;
  IDinfo : TImageDBRecordA;
  JPEG : TJpegImage;
  pass, s, FromDB : string;
  Date, Time : TDateTime;
  IsTime : boolean;

  procedure DoExit;
  begin
   FreeDS(fSourceTable);
   FreeDS(FPostQuery);
   FreeDS(FQuery);
   Paused:=False;
   Active_:=false;
   Terminated_:=false;
   Synchronize(ThreadExit);
  end;

  procedure LoadCurrentJpeg;
  begin
    JPEG := TJpegImage.Create;
    if ValidCryptBlobStreamJPG(FSourceTable.FieldByName('thum')) then
    begin
      pass := DBKernel.FindPasswordForCryptBlobStream(FSourceTable.FieldByName('thum'));
      if pass <> '' then
        DeCryptBlobStreamJPG(FSourceTable.FieldByName('thum'), pass, JPEG);
    end else
      JPEG.Assign(FSourceTable.FieldByName('thum'));
  end;

begin
 FreeOnTerminate:=true;
 if Active_ then exit;
 SetStatusText(TEXT_MES_INITIALIZATION);
 SetActionText(TEXT_MES_WAIT_FOR_A_MINUTE);
 FOptions := Options;
 Active_:=true;
 Terminated_:=false;
 fIgnoredWords :=IgnoredWords;
 fAutor := Autor;

 FQuery:=GetQuery;
 FSourceTable:=GetTable(SourceTableName,DB_TABLE_IMAGES);

 FProgress:=0;
 try
  FSourceTable.Open;
 except
  DoExit;
  Exit;
 end;          
 FMaxValue:=FSourceTable.RecordCount;
 FSourceTable.First;
 SetStatusText(TEXT_MES_READING_GROUPS_DB);
 SetActionText(TEXT_MES_WAIT_FOR_A_MINUTE);

 FRegGroups:=GetRegisterGroupList(True);
 FOutRegGroups:=GetRegisterGroupListW(SourceTableName,True);
 GroupsActions.IsActionForKnown:=false;
 GroupsActions.IsActionForUnKnown:=false;

 SetStatusText(TEXT_MES_READING_DB);
 SetActionText(TEXT_MES_WAIT_FOR_A_MINUTE);

 SetMaxValue(FSourceTable.RecordCount);
 SetLength(GroupsActions.Actions,0);
 SetLength(SLinks,0);
 SetLength(DLinks,0);
 SetLength(FTempGroup,0);
 SetLength(FRegGroups,0);
 SetLength(FOutRegGroups,0);
 repeat
  IfPause;
  if Terminated_ then Break;
  inc(FProgress);
  SetPosition(FSourceTable.RecNo);
  SetActionText(format(TEXT_MES_UPDATING_REC_FORMAT,[inttostr(FSourceTable.RecNo),FSourceTable.FieldByName('Name').AsString]));
  StrTh:=FSourceTable.FieldByName('StrTh').AsString;

  if GetDBType=DB_TYPE_MDB then
  FromDB:='(Select * from $DB$ Where StrThCrc = '+IntToStr(Integer(StringCRC(StrTh)))+')' else
  FromDB:='$DB$';

  SetSQL(FQuery,'Select * from $DB$ Where StrTh = :StrTh');
  SetStrParam(FQuery,0,StrTh);
  FQuery.Open;
  Updated:=false;

  try

   if (FQuery.RecordCount=0) and Foptions.UseScanningByFileName then
   begin
    JPEG:=nil;

    LoadCurrentJpeg;

    IDinfo:=GetImageIDFileNameW(dbname,FSourceTable.FieldByName('FFileName').AsString,JPEG);
    if Length(IDinfo.IDs)>0 then
    begin
     FQuery.Active:=false;
     _sqlexectext:='Select * from $DB$ Where ID in (';
     s:='';
     for i:=0 to Length(IDinfo.IDs)-1 do
     begin
      if i=0 then s:=s+IntToStr(IDinfo.IDs[i]) else
      s:=s+','+IntToStr(IDinfo.IDs[i]);
     end;
     _sqlexectext:=_sqlexectext+s+')';
     SetSQL(FQuery,_sqlexectext);

     FQuery.Open;
    end;
   end;

  except
   if JPEG<>nil then JPEG.Free;
  end;

  if FQuery.RecordCount=0 then
  begin
   if Foptions.AddNewRecords then
   begin
    try
     FE:=FileExists(FSourceTable.FieldByName('FFileName').AsString);
     if FE or (not FE and Foptions.AddRecordsWithoutFiles) then
     begin
      AddNewRecord;
      LoadCurrentJpeg;
      Date:=FSourceTable.FieldByName('DateToAdd').AsDateTime;
      Time:=FSourceTable.FieldByName('aTime').AsDateTime;
      IsTime:=FSourceTable.FieldByName('IsTime').AsBoolean;

      if Foptions.AddGroups then
      begin
       Groups := FQuery.FieldByName('Groups').AsString;
       OldGroups := Groups;
       Groups_ := FSourceTable.fieldByName('Groups').AsString;
       FTempGroup:=EnCodeGroups(Groups_);
       FParamTempGroup := FTempGroup;
       FParamFOutRegGroups := FOutRegGroups;
       FParamFRegGroups := FRegGroups;
       FParamGroupsActions :=  GroupsActions;
       Synchronize(FilterGroupsSync);
       GroupsActions:=FParamGroupsActions;
       Groups_:=CodeGroups(FParamTempGroup);
       AddGroupsToGroups(Groups_,Groups);
      end;

      SQL_AddFileToDB(
       GetDBFileName(FSourceTable.FieldByName('FFileName').AsString,SourceTableName),
        ValidCryptBlobStreamJPG(FSourceTable.FieldByName('thum')),
        Jpeg,FSourceTable.FieldByName('StrTh').AsString,
        FSourceTable.FieldByName('KeyWords').AsString,
        FSourceTable.FieldByName('Comment').AsString,pass,
        FSourceTable.FieldByName('Width').AsInteger,
        FSourceTable.FieldByName('Height').AsInteger,
        Date,Time,IsTime,
        FSourceTable.FieldByName('Rating').AsInteger,
        FSourceTable.FieldByName('Rotated').AsInteger,
        FSourceTable.FieldByName('Links').AsString,
        FSourceTable.FieldByName('Access').AsInteger,
        Groups_
      );

     end;
    except
    end;
   end;
  end else
  begin
   FQuery.First;
   for i:=1 to FQuery.RecordCount do
   begin
    try
     if Foptions.AddKeyWords then
     begin
      KeyWords:= FQuery.fieldByName('KeyWords').AsString;
      KeyWords_:= FSourceTable.fieldByName('KeyWords').AsString;
      if Foptions.IgnoreWords then res:=AddWordsW( KeyWords_, fIgnoredWords, KeyWords) else
      res:=AddWordsA( KeyWords_, KeyWords);
      if res then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set KeyWords="'+KeyWords+'"';
       _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger);
       post(_sqlexectext);
       Updated:=True;
      end;
     end;
    except
    end;
    try
     if Foptions.AddGroups then
     begin
      Groups := FQuery.FieldByName('Groups').AsString;
      OldGroups := Groups;
      Groups_ := FSourceTable.fieldByName('Groups').AsString;
      FTempGroup:=EnCodeGroups(Groups_);
      FParamTempGroup := FTempGroup;
      FParamFOutRegGroups := FOutRegGroups;
      FParamFRegGroups := FRegGroups;
      FParamGroupsActions :=  GroupsActions;
      Synchronize(FilterGroupsSync);
      GroupsActions:=FParamGroupsActions;
      Groups_:=CodeGroups(FParamTempGroup);
      AddGroupsToGroups(Groups_,Groups);
      if not CompareGroups(OldGroups,Groups_) then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set Groups="'+Groups_+'"';
       _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
       post(_sqlexectext);
       Updated:=True;
      end;
     end;
    except
    end;
    try
     if Foptions.AddRotate then
     begin
      if (FQuery.fieldByName('Rotated').AsInteger=0) and
      (FSourceTable.fieldByName('Rotated').AsInteger>0) then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set Rotated='+inttostr(FSourceTable.fieldByName('Rotated').AsInteger)+'';
       _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
       post(_sqlexectext);
       Updated:=True;
      end;
     end;
    except
    end;
    try
     if Foptions.AddRating then
     begin
      if (FQuery.fieldByName('Rating').AsInteger=0) and
      (FSourceTable.fieldByName('Rating').AsInteger>0) then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set Rating='+inttostr(FSourceTable.fieldByName('Rating').AsInteger)+'';
       _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
       post(_sqlexectext);
       Updated:=True;
      end;
     end;
    except
    end;
    try
     if Foptions.AddDate then
     begin
      if (FQuery.fieldByName('IsDate').AsBoolean=False) and
      (FSourceTable.fieldByName('IsDate').AsBoolean=True) then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set IsDate=:IsDate, DateToAdd=:DateToAdd';
       _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
       FPostQuery:=GetQuery;
       SetSQL(FPostQuery,_sqlexectext);
       SetBoolParam(fPostQuery,0,True);
       SetDateParam(fPostQuery,'DateToAdd',FSourceTable.fieldByName('DateToAdd').AsDateTime);
       ExecSQL(FPostQuery);
       FreeDS(FPostQuery);

       Updated:=True;
      end;
     end;
    except
    end;
    try
     if Foptions.AddComment then
     begin
      Res:=false;
      if length(FSourceTable.fieldByName('Comment').AsString)>1 then
      begin
       if length(FQuery.fieldByName('Comment').AsString)>1 then
       begin
        res:=not SimilarTexts(FSourceTable.fieldByName('Comment').AsString,FQuery.fieldByName('Comment').AsString);
        if Foptions.AddNamedComment then
        r:=FQuery.fieldByName('Comment').AsString+' '+Foptions.Autor+': "'+FSourceTable.fieldByName('Comment').AsString+'"'
        else
        r:=FQuery.fieldByName('Comment').AsString+' P.S. '+FSourceTable.fieldByName('Comment').AsString
       end else
       begin
        res:=true;
        r:=FSourceTable.fieldByName('Comment').AsString;
       end;
      end;
      if res then
      begin
       _sqlexectext:='Update $DB$';
       _sqlexectext:=_sqlexectext+ ' Set Comment ="'+NormalizeDBString(r)+'"';
       _sqlexectext:=_sqlexectext+ ' Where ID = '+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
       post(_sqlexectext);
       Updated:=True;
      end;
     end;
    except
    end;

    try
     if Foptions.AddLinks then
     begin
      Res:=false;
      if length(FSourceTable.fieldByName('Links').AsString)>1 then
      begin
       res:=false;
       SLinks:=ParseLinksInfo(FSourceTable.fieldByName('Links').AsString);
       DLinks:=ParseLinksInfo(FQuery.fieldByName('Links').AsString);
       for j:=0 to Length(SLinks)-1 do
       if not LinkInLinksExists(SLinks[j],DLinks,false) then
       begin
        SetLength(DLinks,Length(DLinks)+1);
        DLinks[Length(DLinks)-1]:=SLinks[j];
        res:=true;
       end;
       if res then
       begin
        _sqlexectext:='Update $DB$';
        _sqlexectext:=_sqlexectext+ ' Set Links ="'+NormalizeDBString(CodeLinksInfo(DLinks))+'"';
        _sqlexectext:=_sqlexectext+ ' Where ID = '+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
        Updated:=True;
       end;
      end;
     end;
    except
    end;

    FQuery.Next;
   end;
   if Updated then
   AddUpdatedRecord;
  end;
  FSourceTable.Next;

 Until FSourceTable.Eof;

 DoExit;

end;

procedure CmpDBTh.FilterGroupsSync;
begin
 FilterGroups(FParamTempGroup,FParamFOutRegGroups,FParamFRegGroups,FParamGroupsActions);
end;

procedure CmpDBTh.IfPause;
begin
 If Paused then
 begin
  SetActionText(TEXT_MES_PAUSED+'...');
  Repeat
   Sleep(100);
  Until not Paused or Terminated_;
 end;
end;

procedure CmpDBTh.Post(sql: string);
begin
 fPostQuery:=GetQuery;
 SetSQL(fPostQuery,sql);
 ExecSQL(fPostQuery);
 FreeDS(fPostQuery);
end;

procedure CmpDBTh.SetActionText(Value: string);
begin
 StrParam:=Value;
 Synchronize(SetActionTextA);
end;

procedure CmpDBTh.SetActionTextA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.SetActionText(StrParam);
end;

procedure CmpDBTh.SetMaxValue(Value: Integer);
begin
 IntParam:=Value;
 Synchronize(SetMaxValueA);
end;

procedure CmpDBTh.SetMaxValueA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.SetMaxRecords(IntParam);
end;

procedure CmpDBTh.SetPosition(Value: Integer);
begin
 IntParam:=Value;
 Synchronize(SetPositionA);
end;

procedure CmpDBTh.SetPositionA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.SetProgress(IntParam);

end;

procedure CmpDBTh.SetStatusText(Value: string);
begin
 StrParam:=Value;
 Synchronize(SetStatusTextA);
end;

procedure CmpDBTh.SetStatusTextA;
begin
 if ImportProgressForm<>nil then
 ImportProgressForm.SetStatusText(StrParam);
end;

procedure CmpDBTh.ThreadExit;
begin
 ImportProgressForm.Close;
 ImportProgressForm.Release;
end;

end.
