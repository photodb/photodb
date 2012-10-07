unit UnitCmpDB;

interface

uses
  UnitGroupsReplace,
  CmpUnit,
  Classes,
  DB,
  dolphin_db,
  SysUtils,
  uRuntime,
  uGroupTypes,
  UnitLinksSupport,
  GraphicCrypt,
  JPEG,
  CommonDBSupport,
  UnitDBDeclare,
  UnitDBKernel,
  uDBTypes,
  uDBGraphicTypes,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  UnitDBCommonGraphics,
  uDBThread,
  uMemory,
  uDBForm,
  uDBAdapter;

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
    FSourceTableName: string;
  protected
    function GetThreadID : string; override;
  public
    constructor Create(OwnerForm: TDBForm; Options: TCompOptions; Autor, IgnoredWords, SourceTableName: string);
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
  CompareThreadTerminated: Boolean = False;
  CompareThreadPaused: Boolean = False;

implementation

uses
  UnitCompareProgress,
  UnitExportThread,
  UnitUpdateDBThread;

{ UnitCmpDB }

procedure CmpDBTh.AddNewRecord;
begin
  SynchronizeEx(AddNewRecordA);
end;

procedure CmpDBTh.AddNewRecordA;
begin
  ImportProgressForm.AddNewRecord;
end;

procedure CmpDBTh.AddUpdatedRecord;
begin
  SynchronizeEx(AddUpdatedRecordA);
end;

procedure CmpDBTh.AddUpdatedRecordA;
begin
  ImportProgressForm.AddUpdatedRecord;
end;

constructor CmpDBTh.Create(OwnerForm: TDBForm; Options: TCompOptions; Autor,
  IgnoredWords, SourceTableName: string);
begin
  inherited Create(OwnerForm, False);
  FOptions := Options;
  FAutor := Autor;
  FIgnoredWords := IgnoredWords;
  FSourceTableName := SourceTableName;
end;

function GetImageIDFileNameW(DBFileName, FN: String; JPEG : TJPEGImage): TImageDBRecordA;
var
  FQuery: TDataSet;
  DA: TDBAdapter;
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
  DA := TDBAdapter.Create(FQuery);
  try
    SetSQL(FQuery, 'SELECT ID, FFileName, Attr, StrTh, Thum FROM ' + GetTableNameByFileName(DBFileName)
        + ' WHERE Name like :str ');
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
        if ValidCryptBlobStreamJPG(DA.Thumb) then
        begin
          Pass := '';
          Pass := DBkernel.FindPasswordForCryptBlobStream(DA.Thumb);
          if Pass <> '' then
            DeCryptBlobStreamJPG(DA.Thumb, Pass, FJPEG);
        end else
          FJPEG.Assign(DA.Thumb);

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
        Result.Ids[Count] := DA.ID;
        Result.FileNames[Count] := DA.FileName;
        Result.Attr[Count] := DA.Attributes;
        Result.ImTh := DA.LongImageID;
        FQuery.Next;
      end;
  finally
    F(DA);
    FreeDS(FQuery);
  end;
end;

procedure CmpDBTh.Execute;
var
  Res, Updated, FE: Boolean;
  I, J: Integer;
  OldGroups, Groups, Groups_, R, KeyWords, KeyWords_, _sqlexectext, StrTh: string;
  FTempGroup, FRegGroups, FOutRegGroups: TGroups;
  GroupsActions: TGroupsActionsW;
  SLinks, DLinks: TLinksInfo;
  IDinfo: TImageDBRecordA;
  JPEG: TJpegImage;
  Pass, S: string;
  SDA, QDA: TDBAdapter;
  Date, Time: TDateTime;
  IsDate, IsTime: Boolean;

  procedure LoadCurrentJpeg;
  begin
    F(JPEG);
    JPEG := TJpegImage.Create;
    if ValidCryptBlobStreamJPG(SDA.Thumb) then
    begin
      Pass := DBKernel.FindPasswordForCryptBlobStream(SDA.Thumb);
      if Pass <> '' then
        DeCryptBlobStreamJPG(SDA.Thumb, Pass, JPEG);
    end else
      JPEG.Assign(SDA.Thumb);
  end;

begin
  inherited;
  FreeOnTerminate := True;
  CompareThreadTerminated := False;
  try
    SetStatusText(L('Initialization'));
    SetActionText(L('Please wait a minute...'));

    FQuery := GetQuery;
    QDA := TDBAdapter.Create(FQuery);
    try
      FSourceTable := GetTable(FSourceTableName, DB_TABLE_IMAGES);
      SDA := TDBAdapter.Create(FSourceTable);
      try
        FProgress := 0;
        try
          FSourceTable.Open;
        except
          Exit;
        end;
        FMaxValue := FSourceTable.RecordCount;
        FSourceTable.First;
        SetStatusText(L('Reading information about groups'));
        SetActionText(L('Please wait a minute...'));

        SetLength(GroupsActions.Actions, 0);
        GroupsActions.ActionForUnKnown.OutGroup.GroupImage := nil;
        GroupsActions.ActionForUnKnown.InGroup.GroupImage := nil;
        GroupsActions.ActionForKnown.OutGroup.GroupImage := nil;
        GroupsActions.ActionForKnown.InGroup.GroupImage := nil;
        GroupsActions.IsActionForKnown := False;
        GroupsActions.IsActionForUnKnown := False;

        SetStatusText(L('Reading collection information'));
        SetActionText(L('Please wait a minute...'));

        SetMaxValue(FSourceTable.RecordCount);
        try
          SetLength(SLinks, 0);
          SetLength(DLinks, 0);
          SetLength(FTempGroup, 0);
          SetLength(FRegGroups, 0);
          SetLength(FOutRegGroups, 0);
          repeat
            IfPause;
            if CompareThreadTerminated then
              Break;
            Inc(FProgress);
            SetPosition(FSourceTable.RecNo);
            SetActionText(Format(L('Item #%s [%s]'), [IntToStr(FSourceTable.RecNo), SDA.Name]));
            StrTh := SDA.LongImageID;

            SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrThCrc = ' + IntToStr(Integer(StringCRC(StrTh))) + ' AND StrTh = :StrTh');
            SetStrParam(FQuery, 0, StrTh);
            FQuery.Open;
            Updated := False;

            JPEG := nil;
            try
              try
                if (FQuery.RecordCount = 0) and Foptions.UseScanningByFileName then
                begin

                  LoadCurrentJpeg;

                  IDinfo := GetImageIDFileNameW(Dbname, SDA.FileName, JPEG);
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
                F(JPEG);
              end;

              if FQuery.RecordCount = 0 then
              begin
                if Foptions.AddNewRecords then
                begin
                  try
                    FE := FileExistsSafe(SDA.FileName);
                    if FE or (not FE and Foptions.AddRecordsWithoutFiles) then
                    begin
                      AddNewRecord;
                      LoadCurrentJpeg;

                      if Foptions.AddGroups then
                      begin
                        Groups := QDA.Groups;
                        OldGroups := Groups;
                        Groups_ := SDA.Groups;
                        FTempGroup := EnCodeGroups(Groups_);
                        FParamTempGroup := FTempGroup;
                        FParamFOutRegGroups := FOutRegGroups;
                        FParamFRegGroups := FRegGroups;
                        FParamGroupsActions := GroupsActions;
                        SynchronizeEx(FilterGroupsSync);
                        GroupsActions := FParamGroupsActions;
                        Groups_ := CodeGroups(FParamTempGroup);
                        FreeGroups(FParamTempGroup);
                        AddGroupsToGroups(Groups_, Groups);
                      end;

                      Date := SDA.Date;
                      Time := SDA.Time;
                      IsTime := SDA.IsTime;
                      IsDate := SDA.IsDate;
                      SQL_AddFileToDB(GetDBFileName(SDA.FileName, FSourceTableName),
                        ValidCryptBlobStreamJPG(SDA.Thumb), Jpeg,
                        SDA.LongImageID, SDA.KeyWords,
                        SDA.Comment, Pass, SDA.Width,
                        SDA.Height, Date, Time, IsDate, IsTime, SDA.Include,
                        SDA.Rating, SDA.Rotation,
                        SDA.Links, SDA.Access, Groups_);

                    end;
                  except
                  end;
                end;
              end else
              begin
                FQuery.First;
                for I := 1 to FQuery.RecordCount do
                begin
                  try
                    if Foptions.AddKeyWords then
                    begin
                      KeyWords := QDA.KeyWords;
                      KeyWords_ := SDA.KeyWords;
                      if Foptions.IgnoreWords then
                        Res := AddWordsW(KeyWords_, FIgnoredWords, KeyWords)
                      else
                        Res := AddWordsA(KeyWords_, KeyWords);
                      if Res then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set KeyWords=' + NormalizeDBString(KeyWords);
                        _sqlexectext := _sqlexectext + ' Where ID=' + IntToStr(QDA.ID);
                        Post(_sqlexectext);
                        Updated := True;
                      end;
                    end;
                  except
                  end;
                  try
                    if Foptions.AddGroups then
                    begin
                      Groups := QDA.Groups;
                      OldGroups := Groups;
                      Groups_ := SDA.Groups;
                      FTempGroup := EnCodeGroups(Groups_);
                      FParamTempGroup := FTempGroup;
                      FParamFOutRegGroups := FOutRegGroups;
                      FParamFRegGroups := FRegGroups;
                      FParamGroupsActions := GroupsActions;
                      SynchronizeEx(FilterGroupsSync);
                      GroupsActions := FParamGroupsActions;
                      Groups_ := CodeGroups(FParamTempGroup);
                      FreeGroups(FParamTempGroup);
                      AddGroupsToGroups(Groups_, Groups);
                      if not CompareGroups(OldGroups, Groups_) then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set Groups=' + NormalizeDBString(Groups_);
                        _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(QDA.ID) + '';
                        Post(_sqlexectext);
                        Updated := True;
                      end;
                    end;
                  except
                  end;
                  try
                    if Foptions.AddRotate then
                    begin
                      if (QDA.Rotation = 0) and (SDA.Rotation > 0)
                        then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set Rotated=' + IntToStr(SDA.Rotation);
                        _sqlexectext := _sqlexectext + ' Where ID=' + IntToStr(QDA.ID) + '';
                        Post(_sqlexectext);
                        Updated := True;
                      end;
                    end;
                  except
                  end;
                  try
                    if Foptions.AddRating then
                    begin
                      if (QDA.Rating = 0) and (SDA.Rating > 0) then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set Rating=' + IntToStr(SDA.Rating);
                        _sqlexectext := _sqlexectext + ' Where ID=' + IntToStr(QDA.ID) + '';
                        Post(_sqlexectext);
                        Updated := True;
                      end;
                    end;
                  except
                  end;
                  try
                    if Foptions.AddDate then
                    begin
                      if (not QDA.IsDate) and SDA.IsDate then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set IsDate=:IsDate, DateToAdd=:DateToAdd';
                        _sqlexectext := _sqlexectext + ' Where ID=' + Inttostr(QDA.ID) + '';
                        FPostQuery := GetQuery;
                        try
                          SetSQL(FPostQuery, _sqlexectext);
                          SetBoolParam(FPostQuery, 0, True);
                          SetDateParam(FPostQuery, 'DateToAdd', SDA.Date);
                          ExecSQL(FPostQuery);
                        finally
                          FreeDS(FPostQuery);
                        end;

                        Updated := True;
                      end;
                    end;
                  except
                  end;
                  try
                    if Foptions.AddComment then
                    begin
                      Res := False;
                      if Length(SDA.Comment) > 1 then
                      begin
                        if Length(QDA.Comment) > 1 then
                        begin
                          Res := not SimilarTexts(SDA.Comment, QDA.Comment);
                          if Foptions.AddNamedComment then
                            R := QDA.Comment + ' ' + Foptions.Autor + ': "' + SDA.Comment + '"'
                          else
                            R := QDA.Comment + ' P.S. ' + SDA.Comment;
                        end else
                        begin
                          Res := True;
                          R := SDA.Comment;
                        end;
                      end;
                      if Res then
                      begin
                        _sqlexectext := 'Update $DB$';
                        _sqlexectext := _sqlexectext + ' Set Comment =' + NormalizeDBString(R);
                        _sqlexectext := _sqlexectext + ' Where ID = ' + Inttostr(QDA.ID);
                        Post(_sqlexectext);
                        Updated := True;
                      end;
                    end;
                  except
                  end;

                  try
                    if Foptions.AddLinks then
                    begin
                      if Length(SDA.Links) > 1 then
                      begin
                        Res := False;
                        SLinks := ParseLinksInfo(SDA.Links);
                        DLinks := ParseLinksInfo(QDA.Links);
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
                          _sqlexectext := _sqlexectext + ' Set Links =' + NormalizeDBString(CodeLinksInfo(DLinks));
                          _sqlexectext := _sqlexectext + ' Where ID = ' + IntToStr(QDA.ID);
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
            finally
              F(JPEG);
            end;

            FSourceTable.Next;

          until FSourceTable.Eof;
        finally
          FreeGroup(FParamGroupsActions.ActionForUnKnown.OutGroup);
          FreeGroup(FParamGroupsActions.ActionForUnKnown.InGroup);
          FreeGroup(FParamGroupsActions.ActionForKnown.OutGroup);
          FreeGroup(FParamGroupsActions.ActionForKnown.InGroup);
          for I := 0 to Length(GroupsActions.Actions) - 1 do
          begin
            FreeGroup(GroupsActions.Actions[I].OutGroup);
            FreeGroup(GroupsActions.Actions[I].InGroup);
          end;
          SetLength(GroupsActions.Actions, 0);
        end;
      finally
        F(SDA);
        FreeDS(FSourceTable);
      end;
    finally
      F(QDA);
      FreeDS(FQuery);
    end;
  finally
    TryRemoveConnection(FSourceTableName, True);
    CompareThreadTerminated := True;
    CompareThreadPaused := False;
    SynchronizeEx(ThreadExit);
  end;
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
  if CompareThreadPaused then
  begin
    SetActionText(L('Pause') + '...');
    repeat
      Sleep(100);
    until not CompareThreadPaused or CompareThreadTerminated;
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
  SynchronizeEx(SetActionTextA);
end;

procedure CmpDBTh.SetActionTextA;
begin
  ImportProgressForm.SetActionText(StrParam);
end;

procedure CmpDBTh.SetMaxValue(Value: Integer);
begin
  IntParam := Value;
  SynchronizeEx(SetMaxValueA);
end;

procedure CmpDBTh.SetMaxValueA;
begin
  ImportProgressForm.SetMaxRecords(IntParam);
end;

procedure CmpDBTh.SetPosition(Value: Integer);
begin
  IntParam := Value;
  SynchronizeEx(SetPositionA);
end;

procedure CmpDBTh.SetPositionA;
begin
  ImportProgressForm.SetProgress(IntParam);
end;

procedure CmpDBTh.SetStatusText(Value: string);
begin
  StrParam := Value;
  SynchronizeEx(SetStatusTextA);
end;

procedure CmpDBTh.SetStatusTextA;
begin
  ImportProgressForm.SetStatusText(StrParam);
end;

procedure CmpDBTh.ThreadExit;
begin
  ImportProgressForm.Close;
end;

end.
