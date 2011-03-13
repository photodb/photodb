unit UnitCleanUpThread;
//TODO: review module

interface

uses
  UnitDBKernel, Windows, Messages, CommCtrl, Dialogs, Classes, DBGrids, DB,
  SysUtils,ComCtrls, Graphics, jpeg, UnitINI, DateUtils, uFileUtils,
  CommonDBSupport, win32crc, UnitCDMappingSupport, uLogger, uConstants,
  CCR.Exif, uMemory, uRuntime, uDBUtils, uDBThread, uSettings;

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
    procedure RegisterThread;
    procedure UnRegisterThread;
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

uses dolphin_db, UnitDBCleaning, FormManegerUnit;

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
begin
  FreeOnTerminate := True;
  if FolderView then
    Exit;
  Synchronize(RegisterThread);

  if Active then
    Exit;
  Priority := TpIdle;
  Termitating := False;
  Active := True;

  FTable := GetQuery;
  FQuery := GetQuery;

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
      Sleep(2500);

    if Termitating then
      Break;
    _sqlexectext := 'Select * from $DB$ where ID=(Select MIN(ID) from $DB$ where ID>' + IntToStr(LastID) + ')';

    SetSQL(FTable, _sqlexectext);
    FTable.Open;

    FText := Format(L('Cleaning... [%s]'), [Trim(FTable.FieldByName('Name').AsString)]);
    LastID := FTable.FieldByName('ID').AsInteger;
    Synchronize(UpdateText);
    Inc(Fposition);
    // Fposition:=FTable.RecNo;

    Share_Position := FPosition;
    Synchronize(UpdateProgress);
    if FPosition mod 10 = 0 then
      SavePosition;
    if FTable = nil then
      Break;
    if Termitating then
      Break;

    try

      if not StaticPath(FTable.FieldByName('FFileName').AsString) then
        Continue;

      Folder := ExtractFileDir(FTable.FieldByName('FFileName').AsString);
      Folder := AnsiLowerCase(Folder);
      CalcStringCRC32(AnsiLowerCase(Folder), Crc);
      Int := Integer(Crc);
      if Int <> FTable.FieldByName('FolderCRC').AsInteger then
      begin
        SetQuery := GetQuery;
        SetSQL(SetQuery,
          'Update $DB$ Set FolderCRC=:FolderCRC Where ID=' + IntToStr(FTable.FieldByName('ID').AsInteger));
        SetIntParam(SetQuery, 0, Crc);
        ExecSQL(SetQuery);

        FreeDS(SetQuery);
      end;

      if Settings.ReadBool('Options', 'DeleteNotValidRecords', True) then
      begin
        if not FileExists(FTable.FieldByName('FFileName').AsString) then
        begin
          if Settings.ReadBool('Options', 'DeleteNotValidRecords', True) then
          begin
            if (FTable.FieldByName('Rating').AsInteger = 0) and
              (FTable.FieldByName('Access').AsInteger <> Db_access_private) and
              (FTable.FieldByName('Comment').AsString = '') and (FTable.FieldByName('KeyWords').AsString = '') and
              (FTable.FieldByName('Groups').AsString = '') and (FTable.FieldByName('IsDate').AsBoolean = False) then
            begin
              SetQuery := GetQuery;
              try
                SetSQL(SetQuery, 'Delete from $DB$ Where ID=' + IntToStr(FTable.FieldByName('ID').AsInteger));
                ExecSQL(SetQuery);
              finally
                FreeDS(SetQuery);
              end;
              Continue;
            end;
          end;
          FQuery.Active := False;

          SetSQL(FQuery, 'UPDATE $DB$ SET Attr=' + Inttostr(Db_attr_not_exists) + ' WHERE ID=' + Inttostr
              (FTable.FieldByName('ID').AsInteger));
          ExecSQL(FQuery);
        end else
        begin
          if (FTable.FieldByName('Attr').AsInteger = Db_attr_not_exists) then
            SetAttr(FTable.FieldByName('ID').AsInteger, Db_attr_norm);
        end;
      end
      except
        on E: Exception do
          EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
      end;

      if Termitating then
        Break;

      try
        S := FTable.FieldByName('FFileName').AsString;
        if S <> AnsiLowerCase(S) then
        begin
          SetQuery := GetQuery;
          SetSQL(SetQuery,
            'UPDATE $DB$ Set FFileName=:FFileName Where ID=' + IntToStr(FTable.FieldByName('ID').AsInteger));
          SetStrParam(SetQuery, 0, AnsiLowerCase(S));
          ExecSQL(SetQuery);
          FreeDS(SetQuery);
        end;
      except
        on E: Exception do
          EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
      end;

      if Termitating then
        Break;

      if Settings.ReadBool('Options', 'FixDateAndTime', True) then
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromJPEG(FTable.FieldByName('FFileName').AsString);
          if YearOf(ExifData.DateTime) > 2000 then
            if (FTable.FieldByName('DateToAdd').AsDateTime <> ExifData.DateTime) or
              (FTable.FieldByName('aTime').AsDateTime <> TimeOf(ExifData.DateTime)) then
            begin

              DateToAdd := ExifData.DateTime;
              ATime := TimeOf(ExifData.DateTime);
              IsDate := True;
              IsTime := True;
              _sqlexectext := '';
              _sqlexectext := _sqlexectext + 'DateToAdd=:DateToAdd,';
              _sqlexectext := _sqlexectext + 'aTime=:aTime,';
              _sqlexectext := _sqlexectext + 'IsDate=:IsDate,';
              _sqlexectext := _sqlexectext + 'IsTime=:IsTime';
              SetQuery := GetQuery;
              SetSQL(SetQuery, 'Update $DB$ Set ' + _sqlexectext + ' where ID = ' + IntToStr
                  (FTable.FieldByName('ID').AsInteger));
              SetDateParam(SetQuery, 'DateToAdd', DateToAdd);
              SetDateParam(SetQuery, 'aTime', ATime);
              SetBoolParam(SetQuery, 2, IsDate);
              SetBoolParam(SetQuery, 3, IsTime);
              ExecSQL(SetQuery);
              FreeDS(SetQuery);
            end;
        except
          on E: Exception do
            EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
        end;
        F(ExifData);
      end;

    if Termitating then
      Break;
    try
      if Settings.ReadBool('Options', 'VerifyDublicates', False) then
      begin
        FQuery.Active := False;

        if (GetDBType(Dbname) = DB_TYPE_MDB) then
        begin
          FromDB := '(Select * from $DB$ where StrThCrc=:StrThCrc)';
          SetSQL(FQuery, 'SELECT * FROM ' + FromDB + ' WHERE StrTh = :StrTh ORDER BY ID');
          SetIntParam(FQuery, 0, StringCRC(FTable.FieldByName('StrTh').AsString));
          SetStrParam(FQuery, 1, FTable.FieldByName('StrTh').AsString);
        end else
        begin
          SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrTh = :StrTh ORDER BY ID');
          SetStrParam(FQuery, 0, FTable.FieldByName('StrTh').AsString);
        end;

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
            if FQuery.FieldByName('Attr').AsInteger <> Db_attr_dublicate then
              SetAttr(FQuery.FieldByName('ID').AsInteger, Db_attr_dublicate);
            FQuery.Next;
          end;
        end;
        if (FQuery.RecordCount = 1) and Fileexists(FTable.FieldByName('FFileName').AsString) and
          (FTable.FieldByName('Attr').AsInteger = Db_attr_dublicate) then
          SetAttr(FTable.FieldByName('ID').AsInteger, Db_attr_norm);
      end;
    except
      on E: Exception do
        EventLog(':CleanUpThread::Execute() throw exception: ' + E.message);
    end;

    // FTable.next;
  end;
  SavePosition;
  FreeDS(FTable);
  FreeDS(FQuery);
  Synchronize(FinalizeForm);
  Active := False;
  try
    Synchronize(UnRegisterThread);
  except
    on E: Exception do
      EventLog(':CleanUpThread::Execute()/UnRegisterThread throw exception: ' + E.message);
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
  DS := GetQuery;
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

procedure CleanUpThread.RegisterThread;
var
  TermInfo: TTemtinatedAction;
begin
  TermInfo.TerminatedPointer := @Termitating;
  TermInfo.TerminatedVerify := @Active;
  TermInfo.Options := TA_INFORM_AND_NT;
  TermInfo.Owner := Self;
  FormManager.RegisterActionCanTerminating(TermInfo);
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

procedure CleanUpThread.UnRegisterThread;
var
  TermInfo: TTemtinatedAction;
begin
  TermInfo.TerminatedPointer := @Termitating;
  TermInfo.TerminatedVerify := @Active;
  TermInfo.Options := TA_INFORM_AND_NT;
  TermInfo.Owner := Self;
  FormManager.UnRegisterActionCanTerminating(TermInfo);
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
