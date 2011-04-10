unit uDBUtils;

interface

uses
  Windows, SysUtils, Graphics, Jpeg, Classes, UnitGroupsWork, uTranslate, uLogger,
  UnitDBKernel, uSysUtils, DB, uConstants, CommonDBSupport, uDBTypes,
  uDBPopupMenuInfo, UnitDBDeclare, DateUtils, win32crc, uPrivateHelper,
  uRuntime, uShellIntegration, uVistaFuncs, uFileUtils, GraphicCrypt,
  uDBBaseTypes, uMemory, UnitLinksSupport, uGraphicUtils, uSettings,
  Math, CCR.Exif, ProgressActionUnit, UnitDBCommonGraphics, Forms,
  uDBForm, uDBGraphicTypes, GraphicsCool, uAssociations,
  GraphicsBaseTypes, uDBAdapter, uCDMappingTypes;

type
  TDBKernelCallBack = procedure(ID: Integer; Params: TEventFields; Value: TEventValues) of object;

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);
procedure GetValidMDBFilesInFolder(Dir: string; Init: Boolean; Res: TStrings);
procedure RenameFolderWithDB(CallBack : TDBKernelCallBack; OldFileName, NewFileName: string; Ask: Boolean = True);
function RenameFileWithDB(CallBack : TDBKernelCallBack; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
function GetImageIDW(Image: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
function GetImageIDWEx(Images: TDBPopupMenuInfo; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;
function GetImageIDTh(ImageTh: AnsiString): TImageDBRecordA;
function GetIdByFileName(FileName: string): Integer;
function GetFileNameById(ID: Integer): string;
procedure SetPrivate(ID: Integer);
procedure UnSetPrivate(ID: Integer);
procedure UpdateDeletedDBRecord(ID: Integer; FileName: string);
procedure UpdateMovedDBRecord(ID: Integer; FileName: string);
procedure SetRotate(ID, Rotate: Integer);
procedure SetRating(ID, Rating: Integer);
procedure SetAttr(ID, Attr: Integer);
procedure UpdateImageRecord(Caller: TDBForm; FileName: string; ID: Integer);
procedure UpdateImageRecordEx(Caller: TDBForm; FileName: string; ID: Integer; OnDBKernelEvent: TOnDBKernelEventProcedure);
function SelectDB(Caller : TDBForm; DB: string) : Boolean;
procedure CopyFullRecordInfo(Handle : THandle; ID: Integer);
procedure ExecuteQuery(SQL: string);
procedure GetFileListByMask(BeginFile, Mask: string;
  Info: TDBPopupMenuInfo; var N: Integer; ShowPrivate: Boolean);
function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; Info: TDBPopupMenuInfoRecord): Boolean;
procedure UpdateImageThInLinks(OldImageTh, NewImageTh: AnsiString);
function BitmapToString(Bit: TBitmap): AnsiString;
function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
procedure CopyFiles(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean; ExplorerForm: TDBForm);
procedure CopyRecordsW(OutTable, InTable: TDataSet; IsMobile, UseFinalLocation: Boolean; BaseFolder: string; var Groups: TGroups);

{ DB Types }
function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
function GetMenuInfoByStrTh(StrTh: AnsiString): TDBPopupMenuInfo;
{ END DB Types }

implementation

uses
  UnitWindowsCopyFilesThread;

function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
var
  ROT: array [0 .. 3, 0 .. 3] of Integer;
begin

  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_270;

  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_180;

  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_90;

  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_0;

  Result := ROT[OldRotation, NewRotation];
end;

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
begin
  if not DBKernel.TestDB(FileName) then
    DBKernel.CreateDBbyName(FileName);

  CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory);
end;

procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);
var
  NewGroup : TGroup;
begin
  if not IsValidGroupsTableW(FileName) then
  begin
    if FileExists(CurrentImagesDirectory + 'Images\Me.jpg') then
    begin
      try
        NewGroup.GroupName := GetWindowsUserName;
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Me.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := NewGroup.GroupName;
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  if FileExists(CurrentImagesDirectory + 'Images\Friends.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Friends', 'Groups');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Friends.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Friends', 'Groups');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
    if FileExists(CurrentImagesDirectory + 'Images\Family.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Family', 'Groups');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Family.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Family', 'Groups');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  end;
end;

procedure GetValidMDBFilesInFolder(Dir: string; Init: Boolean; Res: TStrings);
var
  Found: Integer;
  SearchRec: TSearchRec;
  FE : Boolean;
begin
  Found := FindFirst(IncludeTrailingBackslash(Dir) + '*.photodb', FaAnyFile, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      FE := (SearchRec.Attr and FaDirectory = 0);
      if FE then
      begin
        if DBKernel.TestDB(Dir + SearchRec.name) then
          Res.Add(Dir + SearchRec.name);
      end else
        GetValidMDBFilesInFolder(Dir + SearchRec.name, False, Res);
    end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function RenameFileWithDB(CallBack : TDBKernelCallBack; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
var
  FQuery: TDataSet;
  EventInfo: TEventValues;
  Folder: string;
  Crc: Cardinal;
begin
  Result := True;
  if not OnlyBD then
    if FileExists(OldFileName) or DirectoryExists(OldFileName) then
    begin
      try
        Result := RenameFile(OldFileName, NewFileName);
        if not Result then
          Exit;
      except
        Result := False;
        Exit;
      end;
    end;

  if ID <> 0 then
  begin
    FQuery := GetQuery;
    try

    //TODO: review
      NewFileName := ExcludeTrailingBackslash(NewFileName);
      if not FolderView then
      begin
        Folder := ExtractFileDir(NewFileName);
        Folder := ExcludeTrailingBackslash(AnsiLowerCase(Folder));
        CalcStringCRC32(Folder, Crc);
      end else
      begin
        Folder := ExtractFileDir(NewFileName);
        Folder := ExcludeTrailingBackslash(AnsiLowerCase(Folder));
        CalcStringCRC32(Folder, Crc);

        Folder := IncludeTrailingBackslash(Folder);
        Delete(NewFileName, 1, Length(ExtractFileDir(ParamStr(0))));
      end;

      FQuery.Active := False;
      SetSQL(FQuery, 'UPDATE $DB$ SET FFileName="' + AnsiLowerCase(NewFileName) + '", Name="' + ExtractFileName
          (NewFileName) + '" ,FolderCRC = :FolderCRC WHERE (ID=' + Inttostr(ID) + ')');

      SetIntParam(FQuery, 0, Integer(Crc));
      ExecSQL(FQuery);
    except
    end;
    FreeDS(FQuery);
  end;
  RenameFolderWithDB(CallBack, OldFileName, NewFileName);

  if OnlyBD then
  begin
    CallBack(ID, [EventID_Param_Name], EventInfo);
    Exit;
  end;

  EventInfo.name := OldFileName;
  EventInfo.NewName := NewFileName;
  CallBack(ID, [EventID_Param_Name], EventInfo);
end;

procedure RenameFolderWithDB(CallBack : TDBKernelCallBack; OldFileName, NewFileName: string; Ask: Boolean = True);
var
  ProgressWindow: TProgressActionForm;
  FQuery, SetQuery: TDataSet;
  EventInfo: TEventValues;
  Crc: Cardinal;
  I, Int: Integer;
  FFolder, DBFolder, NewPath, OldPath, Sql, Dir, S: string;
  Dirs: TStrings;
begin
  if DirectoryExists(NewFileName) or DirectoryExists(OldFileName) then
  begin
    OldFileName := ExcludeTrailingBackslash(OldFileName);
    NewFileName := ExcludeTrailingBackslash(NewFileName);

    FQuery := GetQuery;
    try
      FFolder := IncludeTrailingBackslash(OldFileName);

      DBFolder := AnsiLowerCase(FFolder);
      DBFolder := NormalizeDBStringLike(NormalizeDBString(DBFolder));
      if FolderView then
        Delete(DBFolder, 1, Length(ProgramDir));

      SetSQL(FQuery, 'Select ID, FFileName From $DB$ where (FFileName Like :FolderA)');
      SetStrParam(FQuery, 0, '%' + DBFolder + '%');

      FQuery.Active := True;
      FQuery.First;
      if FQuery.RecordCount > 0 then
        if Ask or (ID_OK = MessageBoxDB(GetActiveWindow, Format(TA('This folder (%s) contains %d photos in the database!. Adjust the information in the database?', 'Explorer'),
              [OldFileName, FQuery.RecordCount]), TA('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING)) then
        begin
          ProgressWindow := GetProgressWindow;
          ProgressWindow.OneOperation := True;
          ProgressWindow.MaxPosCurrentOperation := FQuery.RecordCount;
          SetQuery := GetQuery;

          if FQuery.RecordCount > 5 then
          begin
            ProgressWindow.Show;
            ProgressWindow.Repaint;
            ProgressWindow.DoubleBuffered := True;
          end;
          try
            for I := 1 to FQuery.RecordCount do
            begin

              NewPath := FQuery.FieldByName('FFileName').AsString;
              Delete(NewPath, 1, Length(OldFileName));
              NewPath := NewFileName + NewPath;
              OldPath := FQuery.FieldByName('FFileName').AsString;

              if GetDBType = DB_TYPE_MDB then
              begin
                if not FolderView then
                begin
                  CalcStringCRC32(AnsiLowerCase(NewFileName), Crc);
                end else
                begin
                  S := ExcludeTrailingBackslash(NewFileName);
                  Delete(S, 1, Length(ProgramDir));
                  CalcStringCRC32(AnsiLowerCase(S), Crc);
                  NewPath := AnsiLowerCase(IncludeTrailingBackslash(S) + ExtractFileName(FQuery.FieldByName('FFileName').AsString));
                end;
                Int := Integer(Crc);
                Sql := 'UPDATE $DB$ SET FFileName= ' + AnsiLowerCase(NormalizeDBString(NewPath))
                  + ' , FolderCRC = ' + IntToStr(Int) + ' where ID = ' + Inttostr(FQuery.FieldByName('ID').AsInteger);
                SetSQL(SetQuery, Sql);
              end;
              ExecSQL(SetQuery);
              EventInfo.name := OldPath;
              EventInfo.NewName := NewPath;
              CallBack(0, [EventID_Param_Name], EventInfo);
              try

                if I < 10 then
                begin
                  ProgressWindow.XPosition := I;
                  ProgressWindow.Repaint;
                end else
                begin
                  if I mod 10 = 0 then
                  begin
                    ProgressWindow.XPosition := I;
                    ProgressWindow.Repaint;
                  end;
                end;
              except
              end;
              FQuery.Next;
            end;
          except
          end;
          FreeDS(SetQuery);
          ProgressWindow.Release;

        end;
    finally
      FreeDS(FQuery);
    end;
  end;
  Dir := '';
  OldFileName := ExcludeTrailingBackslash(OldFileName);
  NewFileName := ExcludeTrailingBackslash(NewFileName);
  Dirs := TStringList.Create;
  try
    if DirectoryExists(OldFileName) then
    begin
      GetDirectoresOfPath(OldFileName, Dirs);
      for I := 0 to Dirs.Count - 1 do
        RenameFolderWithDB(CallBack, OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
    if DirectoryExists(NewFileName) then
    begin
      GetDirectoresOfPath(NewFileName, Dirs);
      for I := 0 to Dirs.Count - 1 do
        RenameFolderWithDB(CallBack, OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
  finally
    F(Dirs);
  end;
end;

procedure RotateDBImage270(Caller : TDBForm; ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATE_0:
        EventInfo.Rotate := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotate := DB_IMAGE_ROTATE_0;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotate := DB_IMAGE_ROTATE_90;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotate := DB_IMAGE_ROTATE_180;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

procedure RotateDBImage90(Caller : TDBForm; ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATE_0:
        EventInfo.Rotate := DB_IMAGE_ROTATE_90;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotate := DB_IMAGE_ROTATE_180;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotate := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotate := DB_IMAGE_ROTATE_0;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

procedure RotateDBImage180(Caller : TDBForm; ID: Integer; OldRotation: Integer);
var
  EventInfo: TEventValues;
begin
  if ID <> 0 then
  begin
    case OldRotation of
      DB_IMAGE_ROTATE_0:
        EventInfo.Rotate := DB_IMAGE_ROTATE_180;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotate := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotate := DB_IMAGE_ROTATE_0;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotate := DB_IMAGE_ROTATE_90;
    end;
    SetRotate(ID, EventInfo.Rotate);
    DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

function GetIdByFileName(FileName: string): Integer;
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName, True))
        + ' AND FFileName LIKE :FFileName');
    if FolderView then
      Delete(FileName, 1, Length(ProgramDir));
    SetStrParam(FQuery, 0, NormalizeDBStringLike(AnsiLowerCase(FileName)));
    try
      FQuery.Active := True;
    except
      Result := 0;
      Exit;
    end;
    if FQuery.RecordCount = 0 then
      Result := 0
    else
      Result := FQuery.FieldByName('ID').AsInteger;
  finally
    FreeDS(FQuery);
  end;
end;

function GetFileNameById(ID: Integer): string;
var
  FQuery: TDataSet;
begin
  Result := '';
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    SetSQL(FQuery, 'SELECT FFileName FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    try
      FQuery.Active := True;
    except
      Exit;
    end;
    if FQuery.RecordCount <> 0 then
      Result := FQuery.FieldByName('FFileName').AsString;
  finally
    FreeDS(FQuery);
  end;
end;

procedure SetRotate(ID, Rotate: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Rotated=%d Where ID=%d', [Rotate, ID]));
end;

procedure SetAttr(ID, Attr: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Attr=%d Where ID=%d', [Attr, ID]));
end;

procedure SetRating(ID, Rating: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Rating=%d Where ID=%d', [Rating, ID]));
end;

function FilePathCRC(FileName: string): Cardinal;
var
  Folder: string;
begin
  Folder := ExcludeTrailingBackslash(ExtractFileDir(FileName));
  CalcStringCRC32(AnsiLowerCase(Folder), Result);
end;

procedure UpdateMovedDBRecord(ID: Integer; FileName: string);
var
  MDBstr: string;
begin
  MDBstr := ', FolderCRC = ' + IntToStr(Integer(FilePathCRC(FileName)));

  ExecuteQuery('UPDATE $DB$ SET FFileName="' + AnsiLowerCase(FileName) + '", Name ="' + ExtractFileName(FileName)
      + '", Attr=' + Inttostr(Db_access_none) + MDBstr + ' WHERE (ID=' + Inttostr(ID) + ')');
end;

procedure UpdateDeletedDBRecord(ID: Integer; Filename: string);
var
  FQuery: TDataSet;
  Crc: Cardinal;
  Int: Integer;
  MDBstr: string;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    if GetDBType(Dbname) = DB_TYPE_MDB then
    begin
      Crc := FilePathCRC(FileName);
      Int := Integer(Crc);
      MDBstr := ', FolderCRC = ' + IntToStr(Int);
    end;
    SetSQL(FQuery, 'UPDATE $DB$ SET FFileName="' + AnsiLowerCase(Filename) + '", Attr=' + Inttostr(Db_access_none)
        + MDBstr + ' WHERE (ID=' + Inttostr(ID) + ') AND (Attr=' + Inttostr(Db_attr_not_exists) + ')');
    ExecSQL(FQuery);
  except
  end;
  FreeDS(FQuery);
end;

procedure SetPrivate(ID: Integer);
begin
  TPrivateHelper.Instance.Reset;
  ExecuteQuery(Format('Update $DB$ Set Access=%d WHERE ID=%d', [Db_access_private, ID]));
end;

procedure UnSetPrivate(ID: Integer);
begin
  ExecuteQuery(Format('Update $DB$ Set Access=%d WHERE ID=%d', [Db_access_none, ID]));
end;

procedure ExecuteQuery(SQL: string);
var
  DS: TDataSet;
begin
  DS := GetQuery;
  try
    SetSQL(DS, SQL);
    try
      ExecSQL(DS);
      EventLog('::ExecuteSQLExecOnCurrentDB()/ExecSQL OK [' + SQL + ']');
    except
      on E: Exception do
        EventLog(':ExecuteSQLExecOnCurrentDB()/ExecSQL throw exception: ' + E.message);
    end;
  finally
    FreeDS(DS);
  end;
end;

procedure UpdateImageRecord(Caller: TDBForm; FileName: string; ID: Integer);
begin
  UpdateImageRecordEx(Caller, FileName, ID, nil);
end;

procedure UpdateImageRecordEx(Caller: TDBForm; FileName: string; ID: Integer; OnDBKernelEvent: TOnDBKernelEventProcedure);
var
  Table: TDataSet;
  Res: TImageDBRecordA;
  Dublicat, IsDate, IsTime, UpdateDateTime: Boolean;
  I, Attr, Counter: Integer;
  EventInfo: TEventValues;
  ExifData: TExifData;
  EF: TEventFields;
  Path, Folder, _SetSql: string;
  OldImTh: AnsiString;
  Crc: Cardinal;
  DateToAdd, ATime: TDateTime;
  Ms: TMemoryStream;

  function Next: Integer;
  begin
    Result := Counter;
    Inc(Counter);
  end;

  procedure DoDBkernelEvent(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
  begin
    if Assigned(OnDBKernelEvent) then
      OnDBKernelEvent(Sender, ID, Params, Value)
    else
    begin
      if GetCurrentThreadId = MainThreadID then
        DBKernel.DoIDEvent(Sender, ID, Params, Value);
    end;
  end;

begin
  if ID = 0 then
    Exit;
  if FolderView then
    if not FileExists(FileName) then
      FileName := ProgramDir + FileName;

  FileName := LongFileNameW(FileName);
  for I := Length(FileName) - 1 downto 1 do
  begin
    if (FileName[I] = '\') and (FileName[I + 1] = '\') then
      Delete(FileName, I, 1);
  end;
  Res := GetimageIDW(FileName, False);
  if Res.Jpeg = nil then
    Exit;

  IsDate := False;
  IsTime := False;
  DateToAdd := 0;
  ATime := 0;
  // ----

  Table := GetQuery;
  try
    SetSQL(Table, 'Select StrTh,Attr from $DB$ where ID = ' + IntToStr(ID));
    try
      Table.Open;
      OldImTh := Table.FieldByName('StrTh').AsAnsiString;
      Attr := Table.FieldByName('Attr').AsInteger;
      Table.Close;
      _SetSql := 'FFileName=:FFileName,';
      _SetSql := _SetSql + 'Name=:Name,';
      _SetSql := _SetSql + 'StrTh=:StrTh,';
      _SetSql := _SetSql + 'StrThCrc=:StrThCrc,';
      _SetSql := _SetSql + 'thum=:thum,';

      _SetSql := _SetSql + Format('Width=%d,', [Res.OrWidth]);
      _SetSql := _SetSql + Format('Height=%d,', [Res.OrHeight]);
      _SetSql := _SetSql + Format('FileSize=%d,', [GetFileSizeByName(ProcessPath(FileName))]);

      if not FolderView then
      begin
        Folder := ExtractFileDir(FileName);
        UnProcessPath(Folder);
        Folder := ExcludeTrailingBackslash(Folder);
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
      end else
      begin
        Folder := ExtractFileDir(FileName);
        UnProcessPath(Folder);
        Delete(Folder, 1, Length(ProgramDir));
        Folder := ExcludeTrailingBackslash(Folder);
        CalcStringCRC32(AnsiLowerCase(Folder), Crc);
        Folder := IncludeTrailingBackslash(Folder);
      end;
      _SetSql := _SetSql + Format('FolderCRC=%d,', [Crc]);

      UpdateDateTime := False;
      if Settings.ReadBool('Options', 'FixDateAndTime', True) then
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromGraphic(FileName);
          if YearOf(ExifData.DateTimeOriginal) > 2000 then
          begin
            UpdateDateTime := True;
            DateToAdd := DateOf(ExifData.DateTimeOriginal);
            ATime := TimeOf(ExifData.DateTimeOriginal);
            IsDate := True;
            IsTime := True;
            EventInfo.Date := DateOf(ExifData.DateTimeOriginal);
            EventInfo.Time := TimeOf(ExifData.DateTimeOriginal);
            EventInfo.IsDate := True;
            EventInfo.IsTime := True;
            EF := [EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime];
            DoDBkernelEvent(Caller, ID, EF, EventInfo);
            _SetSql := _SetSql + 'DateToAdd=:DateToAdd,';
            _SetSql := _SetSql + 'aTime=:aTime,';
            _SetSql := _SetSql + 'IsDate=:IsDate,';
            _SetSql := _SetSql + 'IsTime=:IsTime,';
          end;
        except
          on E: Exception do
            EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: ' + E.message);
        end;
        F(ExifData);
      end;

      if Attr = Db_attr_dublicate then
      begin
        Dublicat := False;
        for I := 0 to Res.Count - 1 do
          if Res.IDs[I] <> ID then
            if Res.Attr[I] <> Db_attr_not_exists then
            begin
              Dublicat := True;
              Break;
            end;
        if not Dublicat then
        begin
          _SetSql := _SetSql + Format('Attr=%d,', [Db_attr_norm]);
          EventInfo.Attr := Db_attr_norm;
          DoDBkernelEvent(Caller, ID, [EventID_Param_Attr], EventInfo);
        end;
      end;

      if Attr = Db_attr_not_exists then
      begin
        _SetSql := _SetSql + Format('Attr=%d,', [Db_attr_norm]);
        EventInfo.Attr := Db_attr_norm;
        DoDBkernelEvent(Caller, ID, [EventID_Param_Attr], EventInfo);
      end;

      if _SetSql[Length(_SetSql)] = ',' then
        _SetSql := Copy(_SetSql, 1, Length(_SetSql) - 1);
      SetSQL(Table, 'Update $DB$ Set ' + _SetSql + ' where ID = ' + IntToStr(ID));
      if FolderView then
        Path := Folder + ExtractFilename(AnsiLowerCase(FileName))
      else
        Path := AnsiLowerCase(FileName);
      UnProcessPath(Path);

      SetStrParam(Table, Next, Path);

      SetStrParam(Table, Next, ExtractFileName(FileName));
      SetAnsiStrParam(Table, Next, Res.ImTh);
      SetIntParam(Table, Next, Integer(StringCRC(Res.ImTh)));
      // if crypted file not password entered
      if Res.Crypt or (Res.Password <> '') then
      begin
        MS := TMemoryStream.Create;
        try
          CryptGraphicImage(Res.Jpeg, Res.Password, MS);
          LoadParamFromStream(Table, Next, MS, FtBlob);
        finally
          MS.Free;
        end;
      end
      else
        AssignParam(Table, Next, Res.Jpeg);

      if UpdateDateTime then
      begin
        SetDateParam(Table, 'DateToAdd', DateToAdd);
        Next;
        SetDateParam(Table, 'aTime', ATime);
        Next;
        SetBoolParam(Table, Next, IsDate);
        SetBoolParam(Table, Next, IsTime);
      end;
      ExecSQL(Table);
    except
      on E: Exception do
        EventLog(':UpdateImageRecordEx()/ExecSQL throw exception: ' + E.message);
    end;
    Res.Jpeg.Free;
  finally
    FreeDS(Table);
  end;
  UpdateImageThInLinks(OldImTh, Res.ImTh);
end;

function GetimageIDTh(ImageTh: AnsiString): TImageDBRecordA;
var
  FQuery: TDataSet;
  I: Integer;
  FromDB: string;
  DA: TDBAdapter;
begin
  FQuery := GetQuery;
  DA := TDBAdapter.Create(FQuery);
  try
    FromDB := '(Select ID, FFileName, Attr from $DB$ where StrThCrc = ' + IntToStr(Integer(StringCRC(ImageTh))) + ')';

    SetSQL(FQuery, FromDB);
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
    Setlength(Result.Ids, FQuery.RecordCount);
    Setlength(Result.FileNames, FQuery.RecordCount);
    Setlength(Result.Attr, FQuery.RecordCount);
    FQuery.First;
    for I := 1 to FQuery.RecordCount do
    begin
      Result.Ids[I - 1] := DA.ID;
      Result.FileNames[I - 1] := DA.FileName;
      Result.Attr[I - 1] := DA.Attributes;
      FQuery.Next;
    end;
    Result.Count := FQuery.RecordCount;
    Result.ImTh := ImageTh;
  finally
    F(DA);
    FreeDS(FQuery);
  end;
end;

function GetImageIDFileName(FileName: string): TImageDBRecordA;
var
  FQuery: TDataSet;
  I, Count, Rot: Integer;
  Res: TImageCompareResult;
  Val: array of Boolean;
  Xrot: array of Integer;
  FJPEG: TJPEGImage;
  G: TGraphic;
  Pass: string;
  S: string;
begin
  FQuery := GetQuery;
  try
  FQuery.Active := False;

  SetSQL(FQuery, 'SELECT ID, FFileName, Attr, StrTh, Thum FROM $DB$ WHERE FFileName like :str ');
  S := FileName;
  if FolderView then
    Delete(S, 1, Length(ProgramDir));
  SetStrParam(FQuery, 0, '%' + NormalizeDBStringLike(AnsiLowerCase(ExtractFileName(S))) + '%');

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
  // pic := TPicture.Create;
  G := nil;
  if FQuery.RecordCount <> 0 then
  begin
    if GraphicCrypt.ValidCryptGraphicFile(FileName) then
    begin
      Pass := DBKernel.FindPasswordForCryptImageFile(FileName);
      if Pass = '' then
      begin
        Setlength(Result.Ids, 0);
        Setlength(Result.FileNames, 0);
        Setlength(Result.Attr, 0);
        Result.Count := 0;
        Result.ImTh := '';
        Exit;
      end
      else
        G := DeCryptGraphicFile(FileName, Pass);
    end else
    begin
      G := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)).Create;
      G.LoadFromFile(FileName);
    end;
  end;
  JPEGScale(G, 100, 100);
  SetLength(Val, FQuery.RecordCount);
  SetLength(Xrot, FQuery.RecordCount);
  Count := 0;
  FJPEG := nil;
  for I := 1 to FQuery.RecordCount do
  begin
    if ValidCryptBlobStreamJPG(FQuery.FieldByName('Thum')) then
    begin
      Pass := '';
      Pass := DBkernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('Thum'));
      FJPEG := TJPEGImage.Create;
      if Pass <> '' then
        DeCryptBlobStreamJPG(FQuery.FieldByName('Thum'), Pass, FJPEG);

    end else
    begin
      FJPEG := TJPEGImage.Create;
      FJPEG.Assign(FQuery.FieldByName('Thum'));
    end;
    // FJPEG.FREE ??? TODO: check
    Res := CompareImages(FJPEG, G, Rot);
    Xrot[I - 1] := Rot;
    Val[I - 1] := (Res.ByGistogramm > 1) or (Res.ByPixels > 1);
    if Val[I - 1] then
      Inc(Count);
    FQuery.Next;
  end;
  F(FJPEG);
  F(G);
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
      Result.ImTh := FQuery.FieldByName('StrTh').AsAnsiString;
      FQuery.Next;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function GetimageIDWEx(Images: TDBPopupMenuInfo; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;
var
  K, I, L, Len: Integer;
  FQuery: TDataSet;
  Sql, FromDB: string;
  Temp: AnsiString;
  ThImS: TImageDBRecordAArray;
begin
  L := Images.Count;
  SetLength(ThImS, L);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    ThImS[I] := GetImageIDW(Images[I].FileName, UseFileNameScanning, True);
  FQuery := GetQuery;
  FQuery.Active := False;
  Sql := '';
  if GetDBType = DB_TYPE_MDB then
  begin
    FromDB := '(SELECT ID, FFileName, Attr, StrTh FROM $DB$ WHERE ';
    for I := 1 to L do
    begin
      if I = 1 then
        Sql := Sql + Format(' (StrThCrc = :strcrc%d) ', [I])
      else
        Sql := Sql + Format(' or (StrThCrc = :strcrc%d) ', [I]);
    end;
    FromDB := FromDB + Sql + ')';
  end
  else
    FromDB := '$DB$';

  Sql := 'SELECT ID, FFileName, Attr, StrTh FROM ' + FromDB + ' WHERE ';

  for I := 1 to L do
  begin
    if I = 1 then
      Sql := Sql + Format(' (StrTh = :str%d) ', [I])
    else
      Sql := Sql + Format(' or (StrTh = :str%d) ', [I]);
  end;
  SetSQL(FQuery, Sql);
  if GetDBType = DB_TYPE_MDB then
  begin
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetIntParam(FQuery, I, Integer(StringCRC(ThImS[I].ImTh)));
    end;
    for I := L to 2 * L - 1 do
      SetAnsiStrParam(FQuery, I, ThImS[I - L].ImTh);

  end
  else
  begin
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetAnsiStrParam(FQuery, I, ThImS[I].ImTh);
    end;
  end;

  try
    FQuery.Active := True;
  except
    FreeDS(FQuery);
    for I := 0 to L - 1 do
    begin
      Setlength(Result[I].Ids, 0);
      Setlength(Result[I].FileNames, 0);
      Setlength(Result[I].Attr, 0);
      Result[I].Count := 0;
      Result[I].ImTh := '';
      if Result[I].Jpeg <> nil then
        Result[I].Jpeg.Free;
      Result[I].Jpeg := nil;
    end;
    Exit;
  end;

  for K := 0 to L - 1 do
  begin
    Setlength(Result[K].Ids, 0);
    Setlength(Result[K].FileNames, 0);
    Setlength(Result[K].Attr, 0);
    Len := 0;
    FQuery.First;
    for I := 1 to FQuery.RecordCount do
    begin

      Temp := FQuery.FieldByName('StrTh').AsAnsiString;
      if Temp = ThImS[K].ImTh then
      begin
        Inc(Len);
        Setlength(Result[K].Ids, Len);
        Setlength(Result[K].FileNames, Len);
        Setlength(Result[K].Attr, Len);
        Result[K].Ids[Len - 1] := FQuery.FieldByName('ID').AsInteger;
        Result[K].FileNames[Len - 1] := FQuery.FieldByName('FFileName').AsString;
        Result[K].Attr[Len - 1] := FQuery.FieldByName('Attr').AsInteger;
      end;
      FQuery.Next;
    end;
    Result[K].Count := Len;
    Result[K].ImTh := ThImS[K].ImTh;
  end;
  FreeDS(FQuery);
end;

function GetImageIDW(Image: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
var
  Bmp, Thbmp: TBitmap;
  FileName, PassWord: string;
  Imth: AnsiString;
  G: TGraphic;
begin
  DoProcessPath(Image);
  if AThImageSize = 0 then
    AThImageSize := ThImageSize;
  if ADBJpegCompressionQuality = 0 then
    ADBJpegCompressionQuality := DBJpegCompressionQuality;
  Result.Crypt := False;
  Result.Password := '';
  Result.UsedFileNameSearch := False;
  Result.IsError := False;
  G := nil;
  FileName := Image;
  Result.Jpeg := nil;
  try
    if ValidCryptGraphicFile(FileName) then
    begin
      Result.Crypt := True;
      Password := DBKernel.FindPasswordForCryptImageFile(FileName);
      Result.Password := Password;
      if PassWord = '' then
      begin
        F(G);
        Result.Count := 0;
        Result.ImTh := '';
        Exit;
      end;
      try
        G := DeCryptGraphicFile(FileName, PassWord);
      except
        F(G);
        Result.Count := 0;
        Exit;
      end;
    end  else
    begin
      Result.Crypt := False;
      G := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)).Create;
      G.LoadFromFile(FileName);
    end;
  except
    on E: Exception do
    begin
      Result.IsError := True;
      Result.ErrorText := E.message;
      F(G);
      Result.Count := 0;
      Exit;
    end;
  end;
  Result.OrWidth := G.Width;
  Result.OrHeight := G.Height;
  try
    JpegScale(G, AThImageSize, AThImageSize);
    Result.Jpeg := TJpegImage.Create;
    Result.Jpeg.CompressionQuality := ADBJpegCompressionQuality;
    Thbmp := TBitmap.Create;
    try
      Thbmp.PixelFormat := pf24bit;
      Bmp := TBitmap.Create;
      try
        Bmp.PixelFormat := pf24bit;
        if Max(G.Width, G.Height) > AThImageSize then
        begin
          if G.Width > G.Height then
            Thbmp.SetSize(AThImageSize, Round(AThImageSize * (G.Height / G.Width)))
          else
            Thbmp.SetSize(Round(AThImageSize * (G.Width / G.Height)), AThImageSize);

        end else
          Thbmp.SetSize(G.Width, G.Height);

        try
          LoadImageX(G, Bmp, $FFFFFF);
        except
          on E: Exception do
          begin
            EventLog(':GetImageIDW() throw exception: ' + E.message);
            Result.IsError := True;
            Result.ErrorText := E.message;

            Bmp.SetSize(AThImageSize, AThImageSize);
            FillRectNoCanvas(Bmp, $FFFFFF);
            DrawIconEx(Bmp.Canvas.Handle, 70, 70, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
            Thbmp.SetSize(100, 100);
          end;
        end;
        F(G);
        DoResize(Thbmp.Width, Thbmp.Height, Bmp, Thbmp);
      finally
        F(Bmp);
      end;
      Result.Jpeg.Assign(Thbmp); // +s
      try
        Result.Jpeg.JPEGNeeded;
      except
        on E: Exception do
        begin
          Result.IsError := True;
          Result.ErrorText := E.message;
        end;
      end;

      try
        Thbmp.Assign(Result.Jpeg);
      except
        on E: Exception do
        begin
          EventLog(':GetImageIDW() throw exception: ' + E.message);
          Result.IsError := True;
          Result.ErrorText := E.message;
          Thbmp.SetSize(Result.Jpeg.Width, Result.Jpeg.Height);
          FillRectNoCanvas(Thbmp, $0);
        end;
      end;
      Imth := BitmapToString(Thbmp);
    finally
      F(Thbmp);
    end;

    if OnlyImTh and not UseFileNameScanning then
    begin
      Result.ImTh := Imth;
    end else
    begin
      Result := GetImageIDTh(Imth);
      if (Result.Count = 0) and UseFileNameScanning then
      begin
        Result := GetImageIDFileName(FileName);
        Result.UsedFileNameSearch := True;
      end;
    end;
  except
    on E: Exception do
    begin
      Result.IsError := True;
      Result.ErrorText := E.message;
    end;
  end;
end;

procedure UpdateImageThInLinks(OldImageTh, NewImageTh: AnsiString);
var
  FQuery: TDataSet;
  IDs: TArInteger;
  Links: TArStrings;
  I, J: Integer;
  Info: TArLinksInfo;
  Link, OldImageThCode: string;
  Table: TDataSet;
begin
  if OldImageTh = NewImageTh then
    Exit;
  if not Settings.ReadBool('Options', 'CheckUpdateLinks', False) then
    Exit;

  FQuery := GetQuery;
  try
    OldImageThCode := CodeExtID(OldImageTh);
    SetSQL(FQuery, 'Select ID, Links from $DB$ where Links like "%' + OldImageThCode + '%"');
    try
      FQuery.Active := True;
    except
      Exit;
    end;
    if FQuery.RecordCount = 0 then
      Exit;

    FQuery.First;
    SetLength(IDs, 0);
    SetLength(Links, 0);
    for I := 1 to FQuery.RecordCount do
    begin
      SetLength(IDs, Length(IDs) + 1);
      IDs[Length(IDs) - 1] := FQuery.FieldByName('ID').AsInteger;
      SetLength(Links, Length(Links) + 1);
      Links[Length(Links) - 1] := FQuery.FieldByName('Links').AsString;
      FQuery.Next;
    end;
  finally
    FreeDS(FQuery);
  end;
  SetLength(Info, Length(Links));
  for I := 0 to Length(IDs) - 1 do
  begin
    Info[I] := ParseLinksInfo(Links[I]);
    for J := 0 to Length(Info[I]) - 1 do
    begin
      if Info[I, J].LinkType = LINK_TYPE_ID_EXT then
        if Info[I, J].LinkValue = OldImageThCode then
        begin
          Info[I, J].LinkValue := CodeExtID(NewImageTh);
        end;
    end;
  end;
  // correction
  // Access
  Table := GetQuery;
  try
    for I := 0 to Length(IDs) - 1 do
    begin
      Link := CodeLinksInfo(Info[I]);
      SetSQL(Table, 'Update $DB$ set Links="' + Link + '" where ID = ' + IntToStr(IDs[I]));
      ExecSQL(Table);
    end;
  finally
    FreeDS(Table);
  end;
end;

function SelectDB(Caller : TDBForm; DB: string) : Boolean;
var
  EventInfo: TEventValues;
  DBVersion: Integer;

begin
  Result := False;
  if FileExists(DB) then
  begin
    DBVersion := DBKernel.TestDBEx(DB);
    if DBkernel.ValidDBVersion(DB, DBVersion) then
    begin
      DBname := DB;
      DBKernel.SetDataBase(DB);
      EventInfo.name := Dbname;
      LastInseredID := 0;
      DBKernel.DoIDEvent(Caller, 0, [EventID_Param_DB_Changed], EventInfo);
      Result := True;
      Exit;
    end
  end;
end;

function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; Info: TDBPopupMenuInfoRecord): Boolean;
var
  FQuery: TDataSet;
  FBS: TStream;
  Folder, QueryString, S: string;
  CRC: Cardinal;
begin
  Result := False;
  FQuery := GetQuery;
  try
    FileName := AnsiLowerCase(FileName);
    FileName := ExcludeTrailingBackslash(FileName);

    if FolderView then
    begin
      Folder := ExtractFileDir(FileName);
      Delete(Folder, 1, Length(ProgramDir));
      Folder := ExcludeTrailingBackslash(Folder);
      S := FileName;
      Delete(S, 1, Length(ProgramDir));
    end else
    begin
      Folder := ExtractFileDir(FileName);
      Folder := ExcludeTrailingBackslash(Folder);
      S := FileName;
    end;
    CalcStringCRC32(Folder, CRC);
    QueryString := 'Select * from $DB$ where FolderCRC=' + IntToStr(Integer(CRC)) + ' and Name = :name';
    SetSQL(FQuery, QueryString);
    SetStrParam(FQuery, 0, ExtractFileName(S));
    TryOpenCDS(FQuery);

    if not TryOpenCDS(FQuery) or (FQuery.RecordCount = 0) then
      Exit;

    Result := True;
    Info.ReadFromDS(FQuery);
    Info.Tag := EXPLORER_ITEM_IMAGE;

    if LoadThum then
    begin
      if Info.Image = nil then
        Info.Image := TJpegImage.Create;

      if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
      begin
        DeCryptBlobStreamJPG(FQuery.FieldByName('thum'),
          DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum')), Info.Image);
        Info.Crypted := True;
        if (Info.Image <> nil) and (not Info.Image.Empty) then
          Info.Tag := 1;

      end else
      begin
        FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
        try
          Info.Image.LoadFromStream(FBS);
        finally
          F(FBS);
        end;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function BitmapToString(Bit: TBitmap): AnsiString;
var
  I, J: Integer;
  Rr1, Bb1, Gg1: Byte;
  B1, B2: Byte;
  B: TBitmap;
  P: PARGB;
begin
  Result := '';
  B := TBitmap.Create;
  try
    B.PixelFormat := pf24bit;
    QuickReduceWide(10, 10, Bit, B);
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
    for I := 0 to 9 do
    begin
      P := B.ScanLine[I];
      for J := 0 to 9 do
      begin
        Rr1 := P[J].R div 8;
        Gg1 := P[J].G div 8;
        Bb1 := P[J].B div 8;
        B1 := Rr1 shl 3;
        B1 := B1 + Gg1 shr 2;
        B2 := Gg1 shl 6;
        B2 := B2 + Bb1 shl 1;
        if (B1 = 0) and (B2 <> 0) then
        begin
          B2 := B2 + 1;
          B1 := B1 or 135;
        end;
        if (B1 <> 0) and (B2 = 0) then
        begin
          B2 := B2 + 1;
          B2 := B2 or 225;
        end;
        if (B1 = 0) and (B2 = 0) then
        begin
          B1 := 255;
          B2 := 255;
        end;
        if FIXIDEX then
          if (I = 9) and (J = 9) and (B2 = 32) then
            B2 := 255;
        Result := Result + AnsiChar(B1) + AnsiChar(B2);
      end;
    end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
  finally
    F(B);
  end;
end;

procedure GetFileListByMask(BeginFile, Mask: string; Info: TDBPopupMenuInfo; var N: Integer; ShowPrivate: Boolean);
var
  Found, I, J: Integer;
  SearchRec: TSearchRec;
  Folder, S, AddFolder: string;
  C: Integer;
  FQuery: TDataSet;
  FBlockedFiles,
  List: TStrings;
  FE, EM: Boolean;
  P: PChar;
  PSupportedExt: PChar;

begin

  if FileExists(BeginFile) then
    Folder := ExtractFileDir(BeginFile);

  if DirectoryExists(BeginFile) then
    Folder := BeginFile;

  if Folder = '' then
    Exit;

  List := TStringlist.Create;
  try
    C := 0;
    N := 0;
    FBlockedFiles := TStringList.Create;
    try
      FQuery := GetQuery(True);
      try
        Folder := IncludeTrailingBackslash(AnsiLowerCase(Folder));

        if FolderView then
          AddFolder := AnsiLowerCase(ProgramDir)
        else
          AddFolder := '';

        SetSQL(FQuery, 'Select * from $DB$ where FolderCRC=' + IntToStr(GetPathCRC(Folder, False)));

        FQuery.Active := True;
        FQuery.First;
        for I := 1 to FQuery.RecordCount do
        begin
          if FQuery.FieldByName('Access').AsInteger = Db_access_private then
            FBlockedFiles.Add(AnsiLowerCase(FQuery.FieldByName('FFileName').AsString));

          FQuery.Next;
        end;

        BeginFile := AnsiLowerCase(BeginFile);
        PSupportedExt := PChar(Mask); // !!!!
        Found := FindFirst(Folder + '*.*', FaAnyFile, SearchRec);
        while Found = 0 do
        begin
          FE := (SearchRec.Attr and FaDirectory = 0);
          S := ExtractFileExt(SearchRec.name);
          S := '|' + AnsiLowerCase(S) + '|';
          if PSupportedExt = '*.*' then
            EM := True
          else
          begin
            P := StrPos(PSupportedExt, PChar(S));
            EM := P <> nil;
          end;
          if FE and EM and (FBlockedFiles.IndexOf(AnsiLowerCase(Folder + SearchRec.name)) < 0) then
          begin
            Inc(C);
            if AnsiLowerCase(Folder + SearchRec.name) = BeginFile then
              N := C - 1;
            List.Add(AnsiLowerCase(Folder + SearchRec.name));
          end;
          Found := SysUtils.FindNext(SearchRec);
        end;
        FindClose(SearchRec);

        Info.Clear;
        FQuery.First;
        for I := 0 to List.Count - 1 do
          Info.Add(List[I]);

        for I := 0 to FQuery.RecordCount - 1 do
        begin
          for J := 0 to Info.Count - 1 do
          begin
            if (AddFolder + FQuery.FieldByName('FFileName').AsString) = Info[J].FileName then
            begin
              Info[J].ReadFromDS(FQuery);
              Break;
            end;
          end;
          FQuery.Next;
        end;
        for I := 0 to Info.Count - 1 do
        begin
          if AnsiLowerCase(Info[I].FileName) = AnsiLowerCase(BeginFile) then
            Info.Position := I;

          Info[I].InfoLoaded := True;
        end;
        FQuery.Close;
      finally
        FreeDS(FQuery);
      end;
    finally
      F(FBlockedFiles);
    end;
  finally
    F(List);
  end;
  if Info.Count = 0 then
    Info.Add(TDBPopupMenuInfoRecord.CreateFromFile(BeginFile));
end;

procedure CopyFullRecordInfo(Handle : THandle; ID: Integer);
var
  DS: TDataSet;
  I: Integer;
  S: string;
begin
  if not DBInDebug then
    Exit;
  DS := GetQuery;
  try
    SetSQL(DS, 'SELECT * FROM $DB$ WHERE id = ' + IntToStr(ID));
    DS.Open;
    S := '';
    for I := 0 to DS.Fields.Count - 1 do
    begin
      // if DS.FieldDefList[i].Name<>'StrTh' then
      begin
        if DS.Fields[I].DisplayText <> '(MEMO)' then
          S := S + DS.FieldDefList[I].name + ' = ' + DS.Fields[I].DisplayText + #13
        else
          S := S + DS.FieldDefList[I].name + ' = ' + DS.Fields[I].AsString + #13;
      end;
    end;
    MessageBoxDB(Handle, S, TA('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
  finally
    FreeDS(DS);
  end;
end;

///////////////////////////////////////////////////////////////////////
///  BEGIN DB TYPES
///////////////////////////////////////////////////////////////////////

function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfo.Create;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
    Result.AttrExists := False;
    Result.IsListItem := False;
    Result.IsPlusMenu := False;
    FQuery.Close;
  finally
    FreeDS(FQuery);
  end;
end;

function GetMenuInfoByStrTh(StrTh: AnsiString): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := nil;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrThCrc = :CRC AND StrTh = :StrTh');
    SetIntParam(FQuery, 0, StringCRC(StrTh));
    SetAnsiStrParam(FQuery, 1, StrTh);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    Result := TDBPopupMenuInfo.Create;
    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
    Result.AttrExists := False;
    Result.IsListItem := False;
    Result.IsPlusMenu := False;
    Result.Position := 0;
  finally
    FreeDS(FQuery);
  end;
end;

procedure CopyRecordsW(OutTable, InTable: TDataSet; IsMobile, UseFinalLocation: Boolean; BaseFolder: string; var Groups: TGroups);
var
  FileName: string;
  Rec: TDBPopupMenuInfoRecord;
begin
  Rec := TDBPopupMenuInfoRecord.Create;
  try
    Rec.ReadFromDS(OutTable);
    Rec.WriteToDS(InTable);
    AddGroupsToGroups(Groups, EnCodeGroups(Rec.Groups));

    if IsMobile then
    begin
      // subfolder crc neened
      if not UseFinalLocation then
      begin
        FileName := OutTable.FieldByName('FFileName').AsString;
        if StaticPath(FileName) then
          Delete(FileName, 1, Length(BaseFolder));
      end else
        FileName := BaseFolder;

      InTable.FieldByName('FFileName').AsString := FileName;
      InTable.FieldByName('FolderCRC').AsInteger := GetPathCRC(FileName, True);
    end;

    InTable.FieldByName('Thum').AsVariant := OutTable.FieldByName('Thum').AsVariant;

    if FileExistsSafe(FileName) then
      InTable.FieldByName('Attr').AsInteger := Db_attr_norm
    else
      InTable.FieldByName('Attr').AsInteger := Db_attr_not_exists;

  finally
    F(Rec);
  end;
end;

///
///  END DB TYPES
///

procedure CopyFiles(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean;
  ExplorerForm: TDBForm);
begin
  TWindowsCopyFilesThread.Create(Handle, Src, Dest, Move, AutoRename, ExplorerForm);
end;

end.
