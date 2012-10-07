unit UnitCleanUpThread;

interface

uses
  UnitDBKernel,
  Windows,
  Messages,
  CommCtrl,
  Dialogs,
  Classes,
  DBGrids,
  DB,
  SysUtils,
  ComCtrls,
  Graphics,
  jpeg,
  UnitINI,
  DateUtils,
  uExifUtils,
  CommonDBSupport,

  Dmitry.CRC32,
  Dmitry.Utils.Files,

  uCDMappingTypes,
  uLogger,
  uConstants,
  ActiveX,
  CCR.Exif,
  uMemory,
  uRuntime,
  uDBUtils,
  uDBThread,
  uSettings,
  UnitDBDeclare;

type
  CleanUpThread = class(TDBThread)
  private
    { Private declarations }
    FTable: TDataSet;
    FQuery: TDataSet;
    FReg: TBDRegistry;
    FText: string;
    FPosition: Integer;
    FMaxPosition: Integer;
    LastID: Integer;
    procedure UpdateProgress;
    procedure UpdateMaxProgress;
    procedure UpdateText;
    procedure InitializeForm;
    procedure FinalizeForm;
    function GetDBRecordCount: Integer;
  protected
    procedure Execute; override;
    procedure SavePosition;
    function GetThreadID : string; override;
  end;

var
  Termitating: Boolean = False;
  Active: Boolean = False;
  Share_Position, Share_MaxPosition: Integer;

implementation

uses
  UnitDBCleaning,
  FormManegerUnit;

{ CleanUpThread }

procedure CleanUpThread.Execute;
var
  I, Int, Position: Integer;
  S, Str_position, _sqlexectext, FromDB: string;
  ExifData: TExifData;
  Crc: Cardinal;
  Folder: string;
  SetQuery: TDataSet;
  DateToAdd, ATime: TDateTime;
  IsDate, IsTime: Boolean;
  Info: TDBPopupMenuInfoRecord;
begin
  inherited;

  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    if Active then
      Exit;
    Priority := TpIdle;
    Termitating := False;
    Active := True;

    FTable := GetQuery(True);
    FQuery := GetQuery(True);
    try

      FReg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
      try
        FReg.OpenKey(RegRoot, True);
        Str_position := FReg.ReadString('CleanPosition');
        if FReg.ValueExists('CleanLastID') then
          LastID := FReg.ReadInteger('CleanLastID')
        else
          LastID := 0;
        Position := StrToIntDef(Str_position, 1);
        if Position < 1 then
          Position := 1;
        FMaxPosition := GetDBRecordCount;
        if Position > FMaxPosition then
        begin
          Settings.WriteBool('Options', 'AllowFastCleaning', False);
          Position := 1;
        end;
      finally
        F(FReg);
      end;

      Share_Position := 0;

      Share_MaxPosition := FMaxPosition;
      Synchronize(UpdateMaxProgress);
      Synchronize(InitializeForm);
      FPosition := Position;
      while not FMaxPosition < FPosition do
      begin
        if not Settings.ReadBool('Options', 'AllowFastCleaning', False) then
        begin
          for I := 0 to 25 do
          begin
            Sleep(100);
            if DBTerminating then
              Break;
          end;
        end;

        if Termitating or DBTerminating then
          Break;

        _sqlexectext := 'Select * from $DB$ where ID=(Select MIN(ID) from $DB$ where ID>' + IntToStr(LastID) + ')';

        SetSQL(FTable, _sqlexectext);
        FTable.Open;

        Info := TDBPopupMenuInfoRecord.CreateFromDS(FTable);
        try
          FText := Format(L('Cleaning... [%s]'), [Info.Name]);
          LastID := Info.ID;
          Synchronize(UpdateText);
          Inc(Fposition);

          Share_Position := FPosition;
          Synchronize(UpdateProgress);
          if FPosition mod 10 = 0 then
            SavePosition;
          if FTable = nil then
            Break;
          if Termitating or DBTerminating then
            Break;

          try
            if not StaticPath(FTable.FieldByName('FFileName').AsString) then
              Continue;

            if Settings.Exif.UpdateExifInfoInBackground then
              UpdateFileExif(Info);

            Folder := ExtractFileDir(Info.FileName);
            Folder := AnsiLowerCase(Folder);
            CalcStringCRC32(AnsiLowerCase(Folder), Crc);
            Int := Integer(Crc);
            if Int <> FTable.FieldByName('FolderCRC').AsInteger then
            begin
              SetQuery := GetQuery(True);
              try
                SetSQL(SetQuery, 'Update $DB$ Set FolderCRC=:FolderCRC Where ID=' + IntToStr(Info.ID));
                SetIntParam(SetQuery, 0, Crc);
                ExecSQL(SetQuery);
              finally
                FreeDS(SetQuery);
              end;
            end;

            if Settings.ReadBool('Options', 'DeleteNotValidRecords', True) then
            begin
              if not FileExistsSafe(Info.FileName) then
              begin
                if Settings.ReadBool('Options', 'DeleteNotValidRecords', True) then
                begin
                  if (Info.Rating = 0) and (Info.Access <> Db_access_private) and
                    (Info.Comment = '') and (Info.KeyWords = '') and
                    (Info.Groups = '') and (Info.IsDate = False) then
                  begin
                    SetQuery := GetQuery(True);
                    try
                      SetSQL(SetQuery, 'Delete from $DB$ Where ID=' + IntToStr(Info.ID));
                      ExecSQL(SetQuery);
                    finally
                      FreeDS(SetQuery);
                    end;
                    Continue;
                  end;
                end;
                FQuery.Active := False;

                SetSQL(FQuery, 'UPDATE $DB$ SET Attr=' + Inttostr(Db_attr_not_exists) + ' WHERE ID=' + IntToStr(Info.ID));
                ExecSQL(FQuery);
              end else
              begin
                if (Info.Attr = Db_attr_not_exists) then
                  SetAttr(Info.ID, Db_attr_norm);
              end;
            end
            except
              on E: Exception do
                EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
            end;

            if Termitating or DBTerminating then
              Break;

            try
              S := Info.FileName;
              if S <> AnsiLowerCase(S) then
              begin
                SetQuery := GetQuery(True);
                try
                  SetSQL(SetQuery,
                    'UPDATE $DB$ Set FFileName=:FFileName Where ID=' + IntToStr(Info.ID));
                  SetStrParam(SetQuery, 0, AnsiLowerCase(S));
                  ExecSQL(SetQuery);
                finally
                  FreeDS(SetQuery);
                end;
              end;
            except
              on E: Exception do
                EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
            end;

            if Termitating or DBTerminating then
              Break;

            if Settings.ReadBool('Options', 'FixDateAndTime', True) and FileExistsSafe(FTable.FieldByName('FFileName').AsString) then
            begin
              //TODO: UpdateFileExif(Info);
              ExifData := TExifData.Create;
              try
                ExifData.LoadFromGraphic(Info.FileName);
                if not ExifData.Empty then
                begin
                  if (ExifData.DateTimeOriginal > 0) and (YearOf(ExifData.DateTimeOriginal) > 2000) then
                    if (FTable.FieldByName('DateToAdd').AsDateTime <> ExifData.DateTimeOriginal) or
                      (FTable.FieldByName('aTime').AsDateTime <> TimeOf(ExifData.DateTimeOriginal)) then
                    begin

                      DateToAdd := ExifData.DateTimeOriginal;
                      ATime := TimeOf(ExifData.DateTimeOriginal);
                      IsDate := True;
                      IsTime := True;
                      _sqlexectext := '';
                      _sqlexectext := _sqlexectext + 'DateToAdd=:DateToAdd,';
                      _sqlexectext := _sqlexectext + 'aTime=:aTime,';
                      _sqlexectext := _sqlexectext + 'IsDate=:IsDate,';
                      _sqlexectext := _sqlexectext + 'IsTime=:IsTime';
                      SetQuery := GetQuery(True);
                      try
                        SetSQL(SetQuery, 'Update $DB$ Set ' + _sqlexectext + ' where ID = ' + IntToStr(Info.ID));
                        SetDateParam(SetQuery, 'DateToAdd', DateToAdd);
                        SetDateParam(SetQuery, 'aTime', ATime);
                        SetBoolParam(SetQuery, 2, IsDate);
                        SetBoolParam(SetQuery, 3, IsTime);
                        ExecSQL(SetQuery);
                      finally
                        FreeDS(SetQuery);
                      end;
                    end;
                end;
              except
                on E: Exception do
                  EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
              end;
              F(ExifData);
            end;

          if Termitating or DBTerminating then
            Break;
          try
            if Settings.ReadBool('Options', 'VerifyDuplicates', False) then
            begin
              FQuery.Active := False;

              FromDB := '(Select * from $DB$ where StrThCrc=:StrThCrc)';
              SetSQL(FQuery, 'SELECT * FROM ' + FromDB + ' WHERE StrTh = :StrTh ORDER BY ID');
              SetIntParam(FQuery, 0, StringCRC(FTable.FieldByName('StrTh').AsString));
              SetStrParam(FQuery, 1, FTable.FieldByName('StrTh').AsString);

              if Termitating then
                Break;

              FQuery.Active := True;
              FQuery.First;
              if FQuery.RecordCount > 1 then
              begin
                for I := 1 to FQuery.RecordCount do
                begin
                  if FTable = nil then
                    Break;
                  if Termitating then
                    Break;
                  if FQuery.FieldByName('Attr').AsInteger <> Db_attr_duplicate then
                    SetAttr(FQuery.FieldByName('ID').AsInteger, Db_attr_duplicate);
                  FQuery.Next;
                end;
              end;
              if (FQuery.RecordCount = 1) and FileExistsSafe(FTable.FieldByName('FFileName').AsString) and
                (FTable.FieldByName('Attr').AsInteger = Db_attr_duplicate) then
                SetAttr(FTable.FieldByName('ID').AsInteger, Db_attr_norm);
            end;
          except
            on E: Exception do
              EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
          end;

        finally
          F(Info);
        end;
        // FTable.next;
      end;
      SavePosition;
    finally
      FreeDS(FTable);
      FreeDS(FQuery);
    end;
    Synchronize(FinalizeForm);
  finally
    Active := False;
    CoUninitialize;
  end;
end;

procedure CleanUpThread.FinalizeForm;
begin
  if DBCleaningForm <> nil then
  begin
    DBCleaningForm.BtnStart.Enabled := True;
    DBCleaningForm.BtnStop.Enabled := False;
    DBCleaningForm.PbMain.MaxValue := 1;
    DBCleaningForm.PbMain.Position := 0;
    DBCleaningForm.PbMain.Text := L('Cleaning is stopped');
  end;
end;

function CleanUpThread.GetDBRecordCount: Integer;
var
  DS: TDataSet;
begin
  DS := GetQuery(True);
  try
    SetSQL(DS, 'SELECT count(*) as DB_Count from $DB$');
    try
      DS.Open;
      Result := DS.FieldByName('DB_Count').AsInteger;
    except
      Result := 0;
    end;
  finally
    FreeDS(DS);
  end;
end;

function CleanUpThread.GetThreadID: string;
begin
  Result := 'DBCleaning';
end;

procedure CleanUpThread.InitializeForm;
begin
  if DBCleaningForm <> nil then
  begin
    DBCleaningForm.BtnStart.Enabled := False;
    DBCleaningForm.BtnStop.Enabled := True;
    DBCleaningForm.PbMain.MaxValue := Share_MaxPosition;
    DBCleaningForm.PbMain.Position := Share_Position;
  end;
end;

procedure CleanUpThread.SavePosition;
begin
  FReg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    FReg.OpenKey(RegRoot, True);
    FReg.WriteString('CleanPosition', IntToStr(Fposition));
    FReg.WriteInteger('CleanLastID', LastID);
  finally
    F(FReg);
  end;
end;

procedure CleanUpThread.UpdateMaxProgress;
begin
  if DBCleaningForm <> nil then
  begin
    DBCleaningForm.PbMain.MinValue := 0;
    DBCleaningForm.PbMain.MaxValue := FMaxPosition;
  end;
end;

procedure CleanUpThread.UpdateProgress;
begin
  if DBCleaningForm <> nil then
    DBCleaningForm.PbMain.Position := Fposition;
end;

procedure CleanUpThread.UpdateText;
begin
  if DBCleaningForm <> nil then
    DBCleaningForm.PbMain.Text := FText;
end;

end.
