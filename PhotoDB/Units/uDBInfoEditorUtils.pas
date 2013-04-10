unit uDBInfoEditorUtils;

interface

uses
  System.SysUtils,
  System.DateUtils,
  Vcl.Forms,
  Data.DB,

  UnitDBDeclare,
  CommonDBSupport,
  CmpUnit,
  UnitLinksSupport,
  UnitSQLOptimizing,
  ProgressActionUnit,
  UnitDBKernel,

  uConstants,
  uMemory,
  uMemoryEx,
  uDBPopupMenuInfo,
  uDatabaseDirectoriesUpdater,
  uDBForm,
  uCollectionEvents,
  uDBClasses,
  uDBContext,
  uDBEntities;

type
  TUserDBInfoInput = class
    Keywords: string;
    Groups: string;

    Comment: string;
    IsCommentChanged: Boolean;

    Rating: Integer;
    IsRatingChanged: Boolean;

    Date: TDate;
    IsDateChecked: Boolean;
    IsDateChanged: Boolean;

    Time: TTime;
    IsTimeChecked: Boolean;
    IsTimeChanged: Boolean;

    Links: string;
    IsLinksChanged: Boolean;

    Include: Boolean;
    IsIncludeChanged: Boolean;
  end;

procedure BatchUpdateDBInfo(Owner: TDBForm; FFilesInfo: TMediaItemCollection; UserInput: TUserDBInfoInput);
procedure FillDataRecordWithUserInfo(Info: TMediaItem; UserInput: TUserDBInfoInput);
procedure UpdateDBRecordWithUserInfo(Owner: TDBForm; Info: TMediaItem; UserInput: TUserDBInfoInput);

implementation

procedure FillDataRecordWithUserInfo(Info: TMediaItem; UserInput: TUserDBInfoInput);
begin
  if UserInput.Comment <> '' then
    Info.Comment := UserInput.Comment;
  if UserInput.KeyWords <> '' then
    Info.KeyWords := UserInput.KeyWords;
  if (UserInput.Rating  > 0) and UserInput.IsRatingChanged then
    Info.Rating := UserInput.Rating;
  if Length(UserInput.Groups) > 0 then
    Info.Groups := UserInput.Groups;
  Info.Include := UserInput.Include;
  if UserInput.IsDateChecked then
    Info.Date := DateOf(UserInput.Date);
  if UserInput.IsTimeChecked then
    Info.Time := TimeOf(UserInput.Time);
  Info.IsDate := UserInput.IsDateChecked;
  Info.IsTime := UserInput.IsTimeChecked;
  if Length(ParseLinksInfo(UserInput.Links)) > 0 then
    Info.Links := UserInput.Links;
end;

procedure BatchUpdateDBInfo(Owner: TDBForm; FFilesInfo: TMediaItemCollection; UserInput: TUserDBInfoInput);
var
  I, J, C, OperationCounter: Integer;
  ProgressForm: TProgressActionForm;
  List: TSQLList;
  SQL, IDs, CommonGroups, KeyWords, SGroups, OriginalLinks, SLinks: string;
  EventInfo: TEventValues;
  WorkQuery: TDataSet;
  FileInfo: TMediaItem;
  UC: TUpdateCommand;
  Context: IDBContext;

  function GenerateIDList : string;
  var
    K: Integer;
  begin
    Result := '0';
    for K := 0 to FFilesInfo.Count - 1 do
    begin
      if FFilesInfo[K].ID = 0 then
        Continue;
      Result := Result + ',' + IntToStr(FFilesInfo[K].ID);
    end;
  end;

begin
  Context := DBKernel.DBContext;

  WorkQuery := Context.CreateQuery;
  try

    OperationCounter := 0;
    if VariousKeyWords(UserInput.Keywords, FFilesInfo.CommonKeyWords) then
      Inc(OperationCounter);
    if not TGroups.CompareGroups(UserInput.Groups, FFilesInfo.CommonGroups) then
      Inc(OperationCounter);
    if UserInput.IsCommentChanged then
      Inc(OperationCounter);
    if UserInput.IsLinksChanged then
      Inc(OperationCounter);
    if FFilesInfo.HasNonDBInfo then
      Inc(OperationCounter);

    ProgressForm := nil;
    try
      if OperationCounter > 0 then
      begin
        ProgressForm := GetProgressWindow;
        ProgressForm.OperationCount := OperationCounter;
        ProgressForm.OperationPosition := 0;
        ProgressForm.OneOperation := False;
        ProgressForm.MaxPosCurrentOperation := FFilesInfo.Count;
        ProgressForm.XPosition := 0;
        ProgressForm.DoFormShow;
      end;

      // [BEGIN] Include Support
      if UserInput.IsIncludeChanged then
      begin
        UC := Context.CreateUpdate(ImageTable);
        try
          UC.AddParameter(TBooleanParameter.Create('Include', UserInput.Include));
          UC.AddWhereParameter(TCustomConditionParameter.Create(Format('[ID] in (%s)', [GenerateIDList])));

          UC.Execute;
        finally
          F(UC);
        end;

        EventInfo.Include := UserInput.Include;
        for I := 0 to FFilesInfo.Count - 1 do
          if FFilesInfo[I].ID > 0 then
            CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_Include], EventInfo);
      end;// [END] Include Support

      // [BEGIN] Rating Support
      if UserInput.IsRatingChanged then
      begin
        SQL := Format('Update $DB$ Set Rating = :Rating Where ID in (%s)', [GenerateIDList]);
        SetSQL(WorkQuery, SQL);
        SetIntParam(WorkQuery, 0, UserInput.Rating);
        ExecSQL(WorkQuery);
        EventInfo.Rating := UserInput.Rating;
        for I := 0 to FFilesInfo.Count - 1 do
          if FFilesInfo[I].ID > 0 then
            CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_Rating], EventInfo);
      end; // [END] Rating Support

      // [BEGIN] KeyWords Support
      if VariousKeyWords(UserInput.Keywords, FFilesInfo.CommonKeyWords) then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          if FFilesInfo[I].ID > 0 then
          begin
            KeyWords := FFilesInfo[I].KeyWords;
            ReplaceWords(FFilesInfo.CommonKeyWords, UserInput.Keywords, KeyWords);
            if VariousKeyWords(KeyWords, FFilesInfo[I].KeyWords) then
              AddQuery(List, KeyWords, FFilesInfo[I].ID);
          end;
        end;
        PackSQLList(List, VALUE_TYPE_KEYWORDS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          SQL := 'Update $DB$ Set KeyWords = ' + NormalizeDBString(List[I].Value)
            + ' Where ID in (' + IDs + ')';
          SetSQL(WorkQuery, SQL);
          ExecSQL(WorkQuery);
          EventInfo.KeyWords := List[I].Value;
          for J := 0 to Length(List[I].IDs) - 1 do
            CollectionEvents.DoIDEvent(Owner, List[I].IDs[J], [EventID_Param_KeyWords], EventInfo);
        end;
      end;// [END] KeyWords Support

      // [BEGIN] Groups Support
      CommonGroups := FFilesInfo.CommonGroups;
      if not TGroups.CompareGroups(UserInput.Groups, CommonGroups) then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          if FFilesInfo[I].ID > 0 then
          begin
            SGroups := FFilesInfo[I].Groups;
            TGroups.ReplaceGroups(CommonGroups, UserInput.Groups, SGroups);
            if not TGroups.CompareGroups(SGroups, FFilesInfo[I].Groups) then
              AddQuery(List, SGroups, FFilesInfo[I].ID);
          end;
        end;

        PackSQLList(List, VALUE_TYPE_GROUPS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          SQL := 'Update $DB$ Set Groups = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
          WorkQuery.Close;
          SetSQL(WorkQuery, SQL);
          ExecSQL(WorkQuery);
          EventInfo.Groups := List[I].Value;
          for J := 0 to Length(List[I].IDs) - 1 do
            CollectionEvents.DoIDEvent(Owner, List[I].IDs[J], [EventID_Param_Groups], EventInfo);
        end;
      end; // [END] Groups Support

      // [BEGIN] Links Support
      if UserInput.IsLinksChanged then
      begin
        FreeSQLList(List);
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        OriginalLinks := CodeLinksInfo(FFilesInfo.CommonLinks);
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          if FFilesInfo[I].ID > 0 then
          begin
            SLinks := FFilesInfo[I].Links;
            ReplaceLinks(OriginalLinks, UserInput.Links, SLinks);
            if not CompareLinks(SLinks, FFilesInfo[I].Links) then
              AddQuery(List, SLinks, FFilesInfo[I].ID);
          end;
        end;
        PackSQLList(List, VALUE_TYPE_LINKS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ',';
            IDs := IDs + IntToStr(List[I].IDs[J]);
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          SQL := 'Update $DB$ Set Links = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
          SetSQL(WorkQuery, SQL);
          ExecSQL(WorkQuery);
        end;
      end;
      // [END] Links Support

      // [BEGIN] Comment Support
      if UserInput.IsCommentChanged and (UserInput.Comment <> FFilesInfo.CommonComments) then
      begin
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        SQL := 'Update $DB$ Set Comment = ' + NormalizeDBString(UserInput.Comment) + ' Where ID in (' + GenerateIDList + ')';
        SetSQL(WorkQuery, SQL);
        ExecSQL(WorkQuery);
        EventInfo.Comment := UserInput.Comment;
        for I := 0 to FFilesInfo.Count - 1 do
        begin
          ProgressForm.XPosition := ProgressForm.XPosition + 1;
          { !!! } Application.ProcessMessages;
          if FFilesInfo[I].ID > 0 then
            CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_Comment], EventInfo);
        end;
      end;// [END] Commnet Support

      // [BEGIN] Date Support
      if UserInput.IsDateChanged then
      begin
        if not UserInput.IsDateChecked then
        begin
          SQL := 'Update $DB$ Set IsDate = :IsDate Where ID in (' + GenerateIDList + ')';
          WorkQuery.Active := False;
          SetSQL(WorkQuery, SQL);
          SetBoolParam(WorkQuery, 0, False);
          ExecSQL(WorkQuery);
          EventInfo.IsDate := False;
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID > 0 then
              CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_IsDate], EventInfo);
        end else
        begin
          SQL := Format('Update $DB$ Set DateToAdd=:DateToAdd, IsDate=TRUE Where ID in (%s)', [GenerateIDList]);
          WorkQuery.Active := False;
          SetSQL(WorkQuery, SQL);
          SetDateParam(WorkQuery, 'DateToAdd', UserInput.Date);
          ExecSQL(WorkQuery);
          EventInfo.Date := UserInput.Date;
          EventInfo.IsDate := True;
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID > 0 then
              CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_Date, EventID_Param_IsDate], EventInfo);
        end;
      end; // [END] Date Support

      // [BEGIN] Time Support
      if UserInput.IsTimeChanged then
      begin
        if not UserInput.IsTimeChecked then
        begin
          SQL := Format('Update $DB$ Set IsTime = :IsTime Where ID in (%s)', [GenerateIDList]);
          WorkQuery.Active := False;
          SetSQL(WorkQuery, SQL);
          SetBoolParam(WorkQuery, 0, False);
          ExecSQL(WorkQuery);
          EventInfo.IsTime := False;
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID > 0 then
              CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_IsTime], EventInfo);
        end else
        begin
          SQL := Format('Update $DB$ Set aTime = :aTime, IsTime = True Where ID in (%s)', [GenerateIDList]);
          WorkQuery.Active := False;
          SetSQL(WorkQuery, SQL);
          SetDateParam(WorkQuery, 'aTime', TimeOf(UserInput.Time));
          ExecSQL(WorkQuery);
          EventInfo.Time := TimeOf(UserInput.Time);
          EventInfo.IsTime := True;
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID > 0 then
              CollectionEvents.DoIDEvent(Owner, FFilesInfo[I].ID, [EventID_Param_Time, EventID_Param_IsTime], EventInfo);
        end;
      end;// [END] Time Support

      for I := 0 to FFilesInfo.Count - 1 do
        if FFilesInfo[I].ID = 0 then
        begin
          FileInfo := FFilesInfo[I].Copy;
          try
            FillDataRecordWithUserInfo(FileInfo, UserInput);

            UpdaterStorage.AddFile(FileInfo);
          finally
            F(FileInfo);
          end;
        end;

      if FFilesInfo.HasNonDBInfo then
      begin
        ProgressForm.OperationPosition := ProgressForm.OperationPosition + 1;
        ProgressForm.XPosition := 0;
        ProgressForm.MaxPosCurrentOperation := 0;
        for I := 0 to FFilesInfo.Count - 1 do
          if FFilesInfo[I].ID = 0 then
            ProgressForm.MaxPosCurrentOperation := ProgressForm.MaxPosCurrentOperation + 1;

        while not ProgressForm.Closed and FFilesInfo.HasNonDBInfo do
        begin
          Application.ProcessMessages;
          C := 0;
          for I := 0 to FFilesInfo.Count - 1 do
            if FFilesInfo[I].ID = 0 then
              Inc(C);

          if ProgressForm.XPosition <> C then
            ProgressForm.XPosition := ProgressForm.MaxPosCurrentOperation - C;
        end;
      end;

    finally
      R(ProgressForm);
    end;
  finally
    FreeDS(WorkQuery);
  end;
end;

procedure UpdateDBRecordWithUserInfo(Owner: TDBForm; Info: TMediaItem; UserInput: TUserDBInfoInput);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
  Params: TEventFields;
  Context: IDBContext;
begin
  Context := DBKernel.DBContext;

  UC := Context.CreateUpdate(ImageTable);
  try
    UC.AddParameter(TStringParameter.Create('Comment', UserInput.Comment));
    UC.AddParameter(TStringParameter.Create('KeyWords', UserInput.Keywords));
    UC.AddParameter(TStringParameter.Create('Groups', UserInput.Groups));
    UC.AddParameter(TIntegerParameter.Create('Rating', UserInput.Rating));
    UC.AddParameter(TDateTimeParameter.Create('DateToAdd', DateOf(UserInput.Date)));
    UC.AddParameter(TBooleanParameter.Create('IsDate', UserInput.IsDateChecked));
    UC.AddParameter(TDateTimeParameter.Create('aTime', UserInput.Time));
    UC.AddParameter(TBooleanParameter.Create('IsTime', UserInput.IsTimeChecked));
    UC.AddParameter(TStringParameter.Create('Links', UserInput.Links));
    UC.AddParameter(TBooleanParameter.Create('Include', UserInput.Include));

    UC.AddWhereParameter(TIntegerParameter.Create('ID', Info.Id));
    UC.Execute;

    EventInfo.Comment := UserInput.Comment;
    EventInfo.KeyWords := UserInput.Keywords;
    EventInfo.Rating := UserInput.Rating;
    EventInfo.Groups := UserInput.Groups;
    EventInfo.Date := DateOf(UserInput.Date);
    EventInfo.IsDate := UserInput.IsDateChecked;
    EventInfo.Time := TimeOf(UserInput.Time);
    EventInfo.IsTime := UserInput.IsTimeChecked;
    EventInfo.Links := UserInput.Links;
    EventInfo.Include := UserInput.Include;

    Params := [EventID_Param_Comment, EventID_Param_KeyWords, EventID_Param_Rating,
      EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime, EventID_Param_Groups,
      EventID_Param_Include, EventID_Param_Links];

    CollectionEvents.DoIDEvent(Owner, Info.Id, Params, EventInfo);
  finally
    F(UC);
  end;
end;

end.
