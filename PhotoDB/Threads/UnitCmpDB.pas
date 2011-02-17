unit UnitCmpDB;

interface

uses
  UnitGroupsReplace, CmpUnit, Classes, DB, dolphin_db, SysUtils,
  UnitGroupsWork, UnitLinksSupport, GraphicCrypt, JPEG, CommonDBSupport,
  UnitDBDeclare, UnitDBKernel, uDBTypes, uDBGraphicTypes, win32crc,
  uGraphicUtils, uDBThread, uMemory;

type
  CmpDBTh = class(TDBThread)
  private
    { Private declarations }
    FQuery: TDataSet;
    FSourceTable: TDataSet;
    FPostQuery: TDataSet;
    FProgress: Integer;
    FMaxValue: Integer;
    FOptions: TCompOptions;
    FIgnoredWords: string;
    FAutor: string;
    IntParam: Integer;
    StrParam: string;
    FParamTempGroup: TGroups;
    FParamFOutRegGroups: TGroups;
    FParamFRegGroups: TGroups;
    FParamGroupsActions: TGroupsActionsW;
  protected
    function GetThreadID : string; override;
  public
    procedure AddNewRecord;
    procedure AddNewRecordA;
    procedure AddUpdatedRecord;
    procedure AddUpdatedRecordA;
    procedure SetPosition(Value: Integer);
    procedure SetPositionA;
    procedure SetMaxValue(Value: Integer);
    procedure SetMaxValueA;
    procedure SetStatusText(Value: string);
    procedure SetStatusTextA;
    procedure SetActionText(Value: string);
    procedure SetActionTextA;
    procedure Execute; override;
    procedure Post(SQL: string);
    procedure IfPause;
    procedure ThreadExit;
    procedure FilterGroupsSync;
  end;

var
  Autor, IgnoredWords, SourceTableName: string;
  Terminated_: Boolean = False;
  Active_: Boolean = False;
  Paused: Boolean = False;
  Options: TCompOptions;

implementation

uses
  UnitCompareProgress, UnitExportThread, UnitUpdateDBThread;

{ UnitCmpDB }

procedure CmpDBTh.AddNewRecord;
begin
  Synchronize(AddNewRecordA);
end;

procedure CmpDBTh.AddNewRecordA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.AddNewRecord;
end;

procedure CmpDBTh.AddUpdatedRecord;
begin
  Synchronize(AddUpdatedRecordA);
end;

procedure CmpDBTh.AddUpdatedRecordA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.AddUpdatedRecord;
end;

function GetImageIDFileNameW(DBFileName, FN: String; JPEG : TJPEGImage): TImageDBRecordA;
var
  FQuery: TDataSet;
  I, Count, Rot: Integer;
  Res: TImageCompareResult;
  Val: array of Boolean;
  Xrot: array of Integer;
  FJPEG: TJPEGImage;
  Pass: string;
begin
  if JPEG = nil then
  begin
    Result.ImTh := '';
    SetLength(Result.IDs, 0);
    Exit;
  end;
  FQuery := GetQuery(DBFileName);
  try
    SetSQL(FQuery, 'SELECT ID, FFileName, Attr, StrTh, Thum FROM ' + GetTableNameByFileName(DBFileName)
        + ' WHERE FFileName like :str ');
    SetStrParam(FQuery, 0, '%' + NormalizeDBStringLike((AnsiLowerCase(ExtractFileName(FN)))) + '%');
    try
      FQuery.Active := True;
    except
      Setlength(Result.Ids, 0);
      Setlength(Result.FileNames, 0);
      Setlength(Result.Attr, 0);
      Result.Count := 0;
      Result.ImTh := '';
      Exit;
    end;

    FQuery.First;

    SetLength(Val, FQuery.RecordCount);
    SetLength(Xrot, FQuery.RecordCount);
    Count := 0;
    FJPEG := TJPEGImage.Create;
    try
      for I := 1 to FQuery.RecordCount do
      begin
        if ValidCryptBlobStreamJPG(FQuery.FieldByName('Thum')) then
        begin
          Pass := '';
          Pass := DBkernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('Thum'));
          if Pass <> '' then
            DeCryptBlobStreamJPG(FQuery.FieldByName('Thum'), Pass, FJPEG);
        end else
          FJPEG.Assign(FQuery.FieldByName('Thum'));

        Res := CompareImages(FJPEG, JPEG, Rot);
        Xrot[I - 1] := Rot;
        Val[I - 1] := (Res.ByGistogramm > 1) or (Res.ByPixels > 1);
        if Val[I - 1] then
          Inc(Count);
        FQuery.Next;
      end;
    finally
      F(FJPEG);
    end;

    Setlength(Result.Ids, Count);
    Setlength(Result.FileNames, Count);
    Setlength(Result.Attr, Count);
    Setlength(Result.ChangedRotate, Count);

    Result.Count := Count;
    FQuery.First;
    Count := -1;
    for I := 1 to FQuery.RecordCount do
      if Val[I - 1] then
      begin
        Inc(Count);
        Result.ChangedRotate[Count] := Xrot[Count] <> 0;
        Result.Ids[Count] := FQuery.FieldByName('ID').AsInteger;
        Result.FileNames[Count] := FQuery.FieldByName('FFileName').AsString;
        Result.Attr[Count] := FQuery.FieldByName('Attr').AsInteger;
        Result.ImTh := FQuery.FieldByName('StrTh').AsString;
        FQuery.Next;
      end;
  finally
    FreeDS(FQuery);
  end;
end;

procedure CmpDBTh.Execute;
var
  Res, Updated, FE: Boolean;
  I, J: Integer;
  OldGroups, Groups, Groups_, StrTh, R, KeyWords, KeyWords_, _sqlexectext: string;
  FTempGroup, FRegGroups, FOutRegGroups: TGroups;
  GroupsActions: TGroupsActionsW;
  SLinks, DLinks: TLinksInfo;
  IDinfo: TImageDBRecordA;
  JPEG: TJpegImage;
  Pass, S, FromDB: string;
  Date, Time: TDateTime;
  IsTime: Boolean;

  procedure DoExit;
  begin
    FreeDS(FSourceTable);
    FreeDS(FPostQuery);
    FreeDS(FQuery);
    Paused := False;
    Active_ := False;
    Terminated_ := False;
    Synchronize(ThreadExit);
  end;

  procedure LoadCurrentJpeg;
  begin
    JPEG := TJpegImage.Create;
    if ValidCryptBlobStreamJPG(FSourceTable.FieldByName('thum')) then
    begin
      Pass := DBKernel.FindPasswordForCryptBlobStream(FSourceTable.FieldByName('thum'));
      if Pass <> '' then
        DeCryptBlobStreamJPG(FSourceTable.FieldByName('thum'), Pass, JPEG);
    end
    else
      JPEG.Assign(FSourceTable.FieldByName('thum'));
  end;

begin
  FreeOnTerminate := True;
  if Active_ then
    Exit;
  SetStatusText(L('Initialization'));
  SetActionText(L('Please wait a minute...'));
  FOptions := Options;
  Active_ := True;
  Terminated_ := False;
  FIgnoredWords := IgnoredWords;
  FAutor := Autor;

  FQuery := GetQuery;
  FSourceTable := GetTable(SourceTableName, DB_TABLE_IMAGES);

  FProgress := 0;
  try
    FSourceTable.Open;
  except
    DoExit;
    Exit;
  end;
  FMaxValue := FSourceTable.RecordCount;
  FSourceTable.First;
  SetStatusText(L('Reading information about groups'));
  SetActionText(L('Please wait a minute...'));

  FRegGroups := GetRegisterGroupList(True);
  FOutRegGroups := GetRegisterGroupListW(SourceTableName, True, DBKernel.SortGroupsByName);
  GroupsActions.IsActionForKnown := False;
  GroupsActions.IsActionForUnKnown := False;

  SetStatusText(L('Reading collection information'));
  SetActionText(L('Please wait a minute...'));

  SetMaxValue(FSourceTable.RecordCount);
  SetLength(GroupsActions.Actions, 0);
  SetLength(SLinks, 0);
  SetLength(DLinks, 0);
  SetLength(FTempGroup, 0);
  SetLength(FRegGroups, 0);
  SetLength(FOutRegGroups, 0);
  repeat
    IfPause;
    if Terminated_ then
      Break;
    Inc(FProgress);
    SetPosition(FSourceTable.RecNo);
    SetActionText(Format(L('Item #%s [%s]'), [Inttostr(FSourceTable.RecNo),
        FSourceTable.FieldByName('Name').AsString]));
    StrTh := FSourceTable.FieldByName('StrTh').AsString;

    if GetDBType = DB_TYPE_MDB then
      FromDB := '(Select * from $DB$ Where StrThCrc = ' + IntToStr(Integer(StringCRC(StrTh))) + ')'
    else
      FromDB := '$DB$';

    SetSQL(FQuery, 'Select * from $DB$ Where StrTh = :StrTh');
    SetStrParam(FQuery, 0, StrTh);
    FQuery.Open;
    Updated := False;

    try

      if (FQuery.RecordCount = 0) and Foptions.UseScanningByFileName then
      begin
        JPEG := nil;

        LoadCurrentJpeg;

        IDinfo := GetImageIDFileNameW(Dbname, FSourceTable.FieldByName('FFileName').AsString, JPEG);
        if Length(IDinfo.IDs) > 0 then
        begin
          FQuery.Active := False;
          _sqlexectext := 'Select * from $DB$ Where ID in (';
          S := '';
          for I := 0 to Length(IDinfo.IDs) - 1 do
          begin
            if I = 0 then
              S := S + IntToStr(IDinfo.IDs[I])
            else
              S := S + ',' + IntToStr(IDinfo.IDs[I]);
          end;
          _sqlexectext := _sqlexectext + S + ')';
          SetSQL(FQuery, _sqlexectext);

          FQuery.Open;
        end;
      end;

    except
      if JPEG <> nil then
        JPEG.Free;
    end;

    if FQuery.RecordCount = 0 then
    begin
      if Foptions.AddNewRecords then
      begin
        try
          FE := FileExists(FSourceTable.FieldByName('FFileName').AsString);
          if FE or (not FE and Foptions.AddRecordsWithoutFiles) then
          begin
            AddNewRecord;
            LoadCurrentJpeg;
            Date := FSourceTable.FieldByName('DateToAdd').AsDateTime;
            Time := FSourceTable.FieldByName('aTime').AsDateTime;
            IsTime := FSourceTable.FieldByName('IsTime').AsBoolean;

            if Foptions.AddGroups then
            begin
              Groups := FQuery.FieldByName('Groups').AsString;
              OldGroups := Groups;
              Groups_ := FSourceTable.FieldByName('Groups').AsString;
              FTempGroup := EnCodeGroups(Groups_);
              FParamTempGroup := FTempGroup;
              FParamFOutRegGroups := FOutRegGroups;
              FParamFRegGroups := FRegGroups;
              FParamGroupsActions := GroupsActions;
              Synchronize(FilterGroupsSync);
              GroupsActions := FParamGroupsActions;
              Groups_ := CodeGroups(FParamTempGroup);
              AddGroupsToGroups(Groups_, Groups);
            end;

            SQL_AddFileToDB(GetDBFileName(FSourceTable.FieldByName('FFileName').AsString, SourceTableName),
              ValidCryptBlobStreamJPG(FSourceTable.FieldByName('thum')), Jpeg,
              FSourceTable.FieldByName('StrTh').AsString, FSourceTable.FieldByName('KeyWords').AsString,
              FSourceTable.FieldByName('Comment').AsString, Pass, FSourceTable.FieldByName('Width').AsInteger,
              FSourceTable.FieldByName('Height').AsInteger, Date, Time, IsTime,
              FSourceTable.FieldByName('Rating').AsInteger, FSourceTable.FieldByName('Rotated').AsInteger,
              FSourceTable.FieldByName('Links').AsString, FSourceTable.FieldByName('Access').AsInteger,
              Groups_);

          end;
        except
        end;
      end;
    end
    else
    begin
      FQuery.First;
      for I := 1 to FQuery.RecordCount do
      begin
        try
          if Foptions.AddKeyWords then
          begin
            KeyWords := FQuery.FieldByName('KeyWords').AsString;
            KeyWords_ := FSourceTable.FieldByName('KeyWords').AsString;
            if Foptions.IgnoreWords then
              Res := AddWordsW(KeyWords_, FIgnoredWords, KeyWords)
            else
              Res := AddWordsA(KeyWords_, KeyWords);
            if Res then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set KeyWords="' + KeyWords + '"';
              _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(FQuery.FieldByName('ID').AsInteger);
              Post(_sqlexectext);
              Updated := True;
            end;
          end;
        except
        end;
        try
          if Foptions.AddGroups then
          begin
            Groups := FQuery.FieldByName('Groups').AsString;
            OldGroups := Groups;
            Groups_ := FSourceTable.FieldByName('Groups').AsString;
            FTempGroup := EnCodeGroups(Groups_);
            FParamTempGroup := FTempGroup;
            FParamFOutRegGroups := FOutRegGroups;
            FParamFRegGroups := FRegGroups;
            FParamGroupsActions := GroupsActions;
            Synchronize(FilterGroupsSync);
            GroupsActions := FParamGroupsActions;
            Groups_ := CodeGroups(FParamTempGroup);
            AddGroupsToGroups(Groups_, Groups);
            if not CompareGroups(OldGroups, Groups_) then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set Groups="' + Groups_ + '"';
              _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
              Post(_sqlexectext);
              Updated := True;
            end;
          end;
        except
        end;
        try
          if Foptions.AddRotate then
          begin
            if (FQuery.FieldByName('Rotated').AsInteger = 0) and (FSourceTable.FieldByName('Rotated').AsInteger > 0)
              then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set Rotated=' + Inttostr(FSourceTable.FieldByName('Rotated').AsInteger)
                + '';
              _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
              Post(_sqlexectext);
              Updated := True;
            end;
          end;
        except
        end;
        try
          if Foptions.AddRating then
          begin
            if (FQuery.FieldByName('Rating').AsInteger = 0) and (FSourceTable.FieldByName('Rating').AsInteger > 0) then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set Rating=' + Inttostr(FSourceTable.FieldByName('Rating').AsInteger)
                + '';
              _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
              Post(_sqlexectext);
              Updated := True;
            end;
          end;
        except
        end;
        try
          if Foptions.AddDate then
          begin
            if (FQuery.FieldByName('IsDate').AsBoolean = False) and
              (FSourceTable.FieldByName('IsDate').AsBoolean = True) then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set IsDate=:IsDate, DateToAdd=:DateToAdd';
              _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
              FPostQuery := GetQuery;
              SetSQL(FPostQuery, _sqlexectext);
              SetBoolParam(FPostQuery, 0, True);
              SetDateParam(FPostQuery, 'DateToAdd', FSourceTable.FieldByName('DateToAdd').AsDateTime);
              ExecSQL(FPostQuery);
              FreeDS(FPostQuery);

              Updated := True;
            end;
          end;
        except
        end;
        try
          if Foptions.AddComment then
          begin
            Res := False;
            if Length(FSourceTable.FieldByName('Comment').AsString) > 1 then
            begin
              if Length(FQuery.FieldByName('Comment').AsString) > 1 then
              begin
                Res := not SimilarTexts(FSourceTable.FieldByName('Comment').AsString,
                  FQuery.FieldByName('Comment').AsString);
                if Foptions.AddNamedComment then
                  R := FQuery.FieldByName('Comment').AsString + ' ' + Foptions.Autor + ': "' + FSourceTable.FieldByName
                    ('Comment').AsString + '"'
                else
                  R := FQuery.FieldByName('Comment').AsString + ' P.S. ' + FSourceTable.FieldByName('Comment').AsString
              end
              else
              begin
                Res := True;
                R := FSourceTable.FieldByName('Comment').AsString;
              end;
            end;
            if Res then
            begin
              _sqlexectext := 'Update $DB$';
              _sqlexectext := _sqlexectext + ' Set Comment ="' + NormalizeDBString(R) + '"';
              _sqlexectext := _sqlexectext + ' Where ID = ' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
              Post(_sqlexectext);
              Updated := True;
            end;
          end;
        except
        end;

        try
          if Foptions.AddLinks then
          begin
            if Length(FSourceTable.FieldByName('Links').AsString) > 1 then
            begin
              Res := False;
              SLinks := ParseLinksInfo(FSourceTable.FieldByName('Links').AsString);
              DLinks := ParseLinksInfo(FQuery.FieldByName('Links').AsString);
              for J := 0 to Length(SLinks) - 1 do
                if not LinkInLinksExists(SLinks[J], DLinks, False) then
                begin
                  SetLength(DLinks, Length(DLinks) + 1);
                  DLinks[Length(DLinks) - 1] := SLinks[J];
                  Res := True;
                end;
              if Res then
              begin
                _sqlexectext := 'Update $DB$';
                _sqlexectext := _sqlexectext + ' Set Links ="' + NormalizeDBString(CodeLinksInfo(DLinks)) + '"';
                _sqlexectext := _sqlexectext + ' Where ID = ' + Inttostr(FQuery.FieldByName('ID').AsInteger) + '';
                Post(_sqlexectext);
                Updated := True;
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

  until FSourceTable.Eof;
  DoExit;
end;

procedure CmpDBTh.FilterGroupsSync;
begin
  FilterGroups(FParamTempGroup, FParamFOutRegGroups, FParamFRegGroups, FParamGroupsActions);
end;

function CmpDBTh.GetThreadID: string;
begin
  Result := 'ImportDB';
end;

procedure CmpDBTh.IfPause;
begin
  if Paused then
  begin
    SetActionText(L('Pause') + '...');
    repeat
      Sleep(100);
    until not Paused or Terminated_;
  end;
end;

procedure CmpDBTh.Post(Sql: string);
begin
  FPostQuery := GetQuery;
  try
    SetSQL(FPostQuery, Sql);
    ExecSQL(FPostQuery);
  finally
    FreeDS(FPostQuery);
  end;
end;

procedure CmpDBTh.SetActionText(Value: string);
begin
  StrParam := Value;
  Synchronize(SetActionTextA);
end;

procedure CmpDBTh.SetActionTextA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.SetActionText(StrParam);
end;

procedure CmpDBTh.SetMaxValue(Value: Integer);
begin
  IntParam := Value;
  Synchronize(SetMaxValueA);
end;

procedure CmpDBTh.SetMaxValueA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.SetMaxRecords(IntParam);
end;

procedure CmpDBTh.SetPosition(Value: Integer);
begin
  IntParam := Value;
  Synchronize(SetPositionA);
end;

procedure CmpDBTh.SetPositionA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.SetProgress(IntParam);
end;

procedure CmpDBTh.SetStatusText(Value: string);
begin
  StrParam := Value;
  Synchronize(SetStatusTextA);
end;

procedure CmpDBTh.SetStatusTextA;
begin
  if ImportProgressForm <> nil then
    ImportProgressForm.SetStatusText(StrParam);
end;

procedure CmpDBTh.ThreadExit;
begin
  ImportProgressForm.Close;
  ImportProgressForm.Release;
end;

end.
