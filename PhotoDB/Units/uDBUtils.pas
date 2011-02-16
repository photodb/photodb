unit uDBUtils;

interface

uses
  Windows, SysUtils, Graphics, Jpeg, Classes, UnitGroupsWork, uTranslate, uLogger,
  UnitDBKernel, uSysUtils, DB, uConstants, CommonDBSupport, uDBTypes,
  uDBPopupMenuInfo, UnitDBDeclare, DateUtils, win32crc, uPrivateHelper,
  uRuntime, uShellIntegration, uVistaFuncs, uFileUtils, GraphicCrypt,
  uDBBaseTypes, uMemory, UnitLinksSupport, Language, uGraphicUtils,
  Math, CCR.Exif, ProgressActionUnit, UnitDBCommonGraphics, Forms,
  uDBForm, uDBGraphicTypes, ImageConverting, GraphicsCool,
  GraphicsBaseTypes;

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);
procedure GetValidMDBFilesInFolder(Dir: string; Init: Boolean; Res: TStrings);
procedure RenameFolderWithDB(Caller : TDBForm; OldFileName, NewFileName: string; Ask: Boolean = True);
function RenameFileWithDB(Caller : TDBForm; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
function GetImageIDW(Image: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
function GetImageIDWEx(Images: TDBPopupMenuInfo; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;
function GetImageIDTh(ImageTh: string): TImageDBRecordA;
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
 out Info: TRecordsInfo; var N: Integer; ShowPrivate: Boolean);
function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; var Info: TOneRecordInfo): Boolean;
procedure UpdateImageThInLinks(OldImageTh, NewImageTh: string);
function BitmapToString(Bit: TBitmap): string;
function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
procedure CopyFiles(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean; ExplorerForm: TDBForm = nil);

{ DB Types }
function RecordInfoOne(name: string; ID, Rotate, Rating, Access: Integer; Size: Int64;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; Isdate, IsTime: Boolean; Time: TTime;
  Crypt, Include, Loaded: Boolean; Links: string): TOneRecordInfo;
function RecordInfoOneA(name: string; ID, Rotate, Rating, Access, Size: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt: Boolean; Tag: Integer; Include: Boolean; Links: string): TOneRecordInfo;
procedure AddRecordsInfoOne(var D: TRecordsInfo; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Loaded, Include: Boolean; Links: string);
procedure SetRecordsInfoOne(var D: TRecordsInfo; N: Integer; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TDateTime; Crypt, Include: Boolean;
  Links: string);
function RecordsInfoOne(name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; Isdate, IsTime: Boolean;
  Time: TDateTime; Crypt, Loaded, Include: Boolean; Links: string): TRecordsInfo;
function GetRecordsFromOne(Info: TOneRecordInfo): TRecordsInfo;
function GetRecordFromRecords(Info: TRecordsInfo; N: Integer): TOneRecordInfo;
procedure SetRecordToRecords(Info: TRecordsInfo; N: Integer; Rec: TOneRecordInfo);
function RecordsInfoNil: TRecordsInfo;
procedure AddToRecordsInfoOneInfo(var Infos: TRecordsInfo; Info: TOneRecordInfo);
procedure DBPopupMenuInfoToRecordsInfo(var DBP: TDBPopupMenuInfo; var RI: TRecordsInfo);
function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
function LoadInfoFromDataSet(TDS: TDataSet): TOneRecordInfo;
{ END DB Types }

implementation

uses
  UnitCDMappingSupport,
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

function RenameFileWithDB(Caller : TDBForm; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
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
  RenameFolderWithDB(Caller, OldFileName, NewFileName);

  if OnlyBD then
  begin
    DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Name], EventInfo);
    Exit;
  end;

  EventInfo.name := OldFileName;
  EventInfo.NewName := NewFileName;
  DBKernel.DoIDEvent(Caller, ID, [EventID_Param_Name], EventInfo);
end;

procedure RenameFolderWithDB(Caller : TDBForm; OldFileName, NewFileName: string; Ask: Boolean = True);
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
    FFolder := IncludeTrailingBackslash(OldFileName);

    DBFolder := AnsiLowerCase(FFolder);
    DBFolder := NormalizeDBStringLike(NormalizeDBString(DBFolder));
    if FolderView then
    begin
      Delete(DBFolder, 1, Length(ProgramDir));
    end;
    SetSQL(FQuery, 'Select ID, FFileName From $DB$ where (FFileName Like :FolderA)');
    SetStrParam(FQuery, 0, '%' + DBFolder + '%');

    FQuery.Active := True;
    FQuery.First;
    if FQuery.RecordCount > 0 then
      if Ask or (ID_OK = MessageBoxDB(Caller.Handle, Format(TA('This folder (%s) contains %d photos in the database!. Adjust the information in the database?', 'Explorer'),
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
            DBKernel.DoIDEvent(Caller, 0, [EventID_Param_Name], EventInfo);
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
    FreeDS(FQuery);
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
        RenameFolderWithDB(Caller, OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
    if DirectoryExists(NewFileName) then
    begin
      GetDirectoresOfPath(NewFileName, Dirs);
      for I := 0 to Dirs.Count - 1 do
        RenameFolderWithDB(Caller, OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
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
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName))
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
  Path, OldImTh, Folder, _SetSql: string;
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
      OldImTh := Table.FieldByName('StrTh').AsString;
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
      if DBKernel.ReadBool('Options', 'FixDateAndTime', True) then
      begin
        ExifData := TExifData.Create;
        try
          ExifData.LoadFromJPEG(FileName);
          if YearOf(ExifData.DateTime) > 2000 then
          begin
            UpdateDateTime := True;
            DateToAdd := DateOf(ExifData.DateTime);
            ATime := TimeOf(ExifData.DateTime);
            IsDate := True;
            IsTime := True;
            EventInfo.Date := DateOf(ExifData.DateTime);
            EventInfo.Time := TimeOf(ExifData.DateTime);
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
      SetStrParam(Table, Next, Res.ImTh);
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

function GetimageIDTh(ImageTh: string): TImageDBRecordA;
var
  FQuery: TDataSet;
  I: Integer;
  FromDB: string;
begin
  FQuery := GetQuery;
  try
    FromDB := '(Select ID, FFileName, Attr from $DB$ where StrThCrc = ' + IntToStr(Integer(StringCRC(ImageTh))) + ')';

    SetSQL(FQuery, FromDB);
    if GetDBType <> DB_TYPE_MDB then
      SetStrParam(Fquery, 0, ImageTh);
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
      Result.Ids[I - 1] := FQuery.FieldByName('ID').AsInteger;
      Result.FileNames[I - 1] := FQuery.FieldByName('FFileName').AsString;
      Result.Attr[I - 1] := FQuery.FieldByName('Attr').AsInteger;
      FQuery.Next;
    end;
    Result.Count := FQuery.RecordCount;
    Result.ImTh := ImageTh;
  finally
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
      G := GetGraphicClass(GetExt(FileName), False).Create;
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
      Result.ImTh := FQuery.FieldByName('StrTh').AsString;
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
  Sql, Temp, FromDB: string;
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
    begin
      SetStrParam(FQuery, I, ThImS[I - L].ImTh);
    end;
  end
  else
  begin
    for I := 0 to L - 1 do
    begin
      Result[I] := ThImS[I];
      SetStrParam(FQuery, I, ThImS[I].ImTh);
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

      Temp := FQuery.FieldByName('StrTh').AsVariant;
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
  FileName, Imth, PassWord: string;
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
        if G <> nil then
          G.Free;
        Result.Count := 0;
        Result.ImTh := '';
        Exit;
      end;
      try
        G := DeCryptGraphicFile(FileName, PassWord);
      except
        if G <> nil then
          G.Free;
        Result.Count := 0;
        Exit;
      end;
    end  else
    begin
      Result.Crypt := False;
      G := GetGraphicClass(GetExt(FileName), False).Create;
      G.LoadFromFile(FileName);
    end;
  except
    on E: Exception do
    begin
      Result.IsError := True;
      Result.ErrorText := E.message;
      if G <> nil then
        G.Free;
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
    Bmp := Tbitmap.Create;
    Bmp.PixelFormat := Pf24bit;
    Thbmp := Tbitmap.Create;
    Thbmp.PixelFormat := Pf24bit;
    if Max(G.Width, G.Height) > AThImageSize then
    begin
      if G.Width > G.Height then
      begin
        Thbmp.Width := AThImageSize;
        Thbmp.Height := Round(AThImageSize * (G.Height / G.Width));
      end else
      begin
        Thbmp.Width := Round(AThImageSize * (G.Width / G.Height));
        Thbmp.Height := AThImageSize;
      end;
    end else begin
      Thbmp.Width := G.Width;
      Thbmp.Height := G.Height;
    end;
    try
      LoadImageX(G, Bmp, $FFFFFF);
      // bmp.assign(G); //+1
    except
      on E: Exception do
      begin
        EventLog(':GetImageIDW() throw exception: ' + E.message);
        Result.IsError := True;
        Result.ErrorText := E.message;

        Bmp.PixelFormat := Pf24bit;
        Bmp.Width := AThImageSize;
        Bmp.Height := AThImageSize;
        FillRectNoCanvas(Bmp, $FFFFFF);
        DrawIconEx(Bmp.Canvas.Handle, 70, 70, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1], 16, 16, 0, 0, DI_NORMAL);
        Thbmp.Height := 100;
        Thbmp.Width := 100;
      end;
    end;
    F(G);
    DoResize(Thbmp.Width, Thbmp.Height, Bmp, Thbmp);
    Bmp.Free;
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
        Thbmp.Width := Result.Jpeg.Width;
        Thbmp.Height := Result.Jpeg.Height;
        FillRectNoCanvas(Thbmp, $0);
      end;
    end;
    Imth := BitmapToString(Thbmp);
    Thbmp.Free;
    if OnlyImTh and not UseFileNameScanning then
    begin
      Result.ImTh := Imth;
    end
    else
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

procedure UpdateImageThInLinks(OldImageTh, NewImageTh: string);
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
  if not DBKernel.ReadBool('Options', 'CheckUpdateLinks', False) then
    Exit;
  FQuery := GetQuery;
  OldImageThCode := CodeExtID(OldImageTh);
  SetSQL(FQuery, 'Select ID, Links from $DB$ where Links like "%' + OldImageThCode + '%"');
  try
    FQuery.Active := True;
  except
    FreeDS(FQuery);
    Exit;
  end;
  if FQuery.RecordCount = 0 then
  begin
    FreeDS(FQuery);
    Exit;
  end;
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
  FQuery.Close;
  FreeDS(FQuery);
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
  for I := 0 to Length(IDs) - 1 do
  begin
    Link := CodeLinksInfo(Info[I]);
    SetSQL(Table, 'Update $DB$ set Links="' + Link + '" where ID = ' + IntToStr(IDs[I]));
    ExecSQL(Table);
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

function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; var Info: TOneRecordInfo): Boolean;
var
  FQuery: TDataSet;
  FBS: TStream;
  Folder, QueryString, S: string;
  CRC: Cardinal;
  JPEG: TJpegImage;
begin
  Result := False;
  Info.Image := nil;
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
    Pointer(JPEG) := Pointer(Info.Image);
    Info := RecordInfoOne(FQuery.FieldByName('FFileName').AsString, FQuery.FieldByName('ID').AsInteger,
      FQuery.FieldByName('Rotated').AsInteger, FQuery.FieldByName('Rating').AsInteger,
      FQuery.FieldByName('Access').AsInteger, FQuery.FieldByName('FileSize').AsInteger,
      FQuery.FieldByName('Comment').AsString, FQuery.FieldByName('KeyWords').AsString,
      FQuery.FieldByName('Owner').AsString, FQuery.FieldByName('Collection').AsString,
      FQuery.FieldByName('Groups').AsString, FQuery.FieldByName('DateToAdd').AsDateTime,
      FQuery.FieldByName('IsDate').AsBoolean, FQuery.FieldByName('IsTime').AsBoolean,
      FQuery.FieldByName('aTime').AsDateTime, ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')),
      FQuery.FieldByName('Include').AsBoolean, True, FQuery.FieldByName('Links').AsString);
    Info.ItemHeight := FQuery.FieldByName('Height').AsInteger;
    Info.ItemWidth := FQuery.FieldByName('Width').AsInteger;
    Info.ItemLinks := FQuery.FieldByName('Links').AsString;
    Info.ItemImTh := FQuery.FieldByName('StrTh').AsString;
    Info.Tag := EXPLORER_ITEM_IMAGE;
    Pointer(Info.Image) := Pointer(JPEG);

    if LoadThum then
    begin
      if Info.Image = nil then
        Info.Image := TJpegImage.Create;

      if ValidCryptBlobStreamJPG(FQuery.FieldByName('thum')) then
      begin
        DeCryptBlobStreamJPG(FQuery.FieldByName('thum'),
          DBKernel.FindPasswordForCryptBlobStream(FQuery.FieldByName('thum')), Info.Image);
        Info.ItemCrypted := True;
        if (Info.Image <> nil) and (not Info.Image.Empty) then
          Info.Tag := 1;

      end else
      begin
        FBS := GetBlobStream(FQuery.FieldByName('thum'), BmRead);
        try
          Info.Image.LoadFromStream(FBS);
        finally
          FBS.Free;
        end;
      end;
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function BitmapToString(Bit: TBitmap): string;
var
  I, J: Integer;
  Rr1, Bb1, Gg1: Byte;
  B1, B2: Byte;
  B: TBitmap;
  P: PARGB;
begin
  Result := '';
  B := Tbitmap.Create;
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
        Result := Result + Chr(B1) + Chr(B2);
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

procedure GetFileListByMask(BeginFile, Mask: string; out Info: TRecordsInfo; var N: Integer; ShowPrivate: Boolean);
var
  Found, I, J: Integer;
  SearchRec: TSearchRec;
  Folder, DBFolder, S, AddFolder: string;
  C: Integer;
  FQuery: TDataSet;
  FBlockedFiles,
  List: TStrings;
  Crc: Cardinal;
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
        DBFolder := NormalizeDBStringLike(NormalizeDBString(Folder));

        if FolderView then
          AddFolder := AnsiLowerCase(ProgramDir)
        else
          AddFolder := '';

        DBFolder := ExcludeTrailingBackslash(DBFolder);
        CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);

        if (GetDBType = DB_TYPE_MDB) and not FolderView then
          SetSQL(FQuery, 'Select * From (Select * from $DB$ where FolderCRC=' + Inttostr(Integer(Crc)) +
              ') where (FFileName Like :FolderA) and not (FFileName like :FolderB)');
        if FolderView then
        begin
          SetSQL(FQuery, 'Select * From $DB$ where FolderCRC = :crc');
          S := DBFolder;
          Delete(S, 1, Length(ProgramDir));
          S := ExcludeTrailingBackslash(S);
          CalcStringCRC32(AnsiLowerCase(S), Crc);
          SetIntParam(FQuery, 0, Integer(Crc));
        end else
        begin
          DBFolder := ExcludeTrailingBackslash(DBFolder);
          CalcStringCRC32(AnsiLowerCase(DBFolder), Crc);
          DBFolder := IncludeTrailingBackslash(DBFolder);
          SetStrParam(FQuery, 0, '%' + DBFolder + '%');
          SetStrParam(FQuery, 1, '%' + DBFolder + '%\%');
        end;

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
          Delete(S, 1, 1);
          S := '|' + AnsiUpperCase(S) + '|';
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

        Info := RecordsInfoNil;
        FQuery.First;
        for I := 0 to List.Count - 1 do
          AddRecordsInfoOne(Info, List[I], 0, 0, 0, 0, '', '', '', '', '', 0, False, False, 0, False, False, True, '');

        for I := 0 to FQuery.RecordCount - 1 do
        begin
          for J := 0 to Length(Info.ItemFileNames) - 1 do
          begin
            if (AddFolder + FQuery.FieldByName('FFileName').AsString) = Info.ItemFileNames[J] then
            begin
              SetRecordToRecords(Info, J, LoadInfoFromDataSet(FQuery));
              Break;
            end;
          end;
          FQuery.Next;
        end;
        for I := 0 to Length(Info.ItemFileNames) - 1 do
        begin
          if AnsiLowerCase(Info.ItemFileNames[I]) = AnsiLowerCase(BeginFile) then
            Info.Position := I;
          if not Info.LoadedImageInfo[I] then
          begin
            Info.ItemCrypted[I] := False; // ? !!! ValidCryptGraphicFile(Info.ItemFileNames[i]);
            Info.LoadedImageInfo[I] := True;
          end;
        end;
        FQuery.Close;
      finally
        FreeDS(FQuery);
      end;
    finally
      FBlockedFiles.Free;
    end;
  finally
    List.Free;
  end;
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


function RecordsInfoNil: TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 0);
  SetLength(Result.ItemIds, 0);
  SetLength(Result.ItemRotates, 0);
  SetLength(Result.ItemRatings, 0);
  SetLength(Result.ItemAccesses, 0);
  SetLength(Result.ItemComments, 0);
  SetLength(Result.ItemOwners, 0);
  SetLength(Result.ItemKeyWords, 0);
  SetLength(Result.ItemCollections, 0);
  SetLength(Result.ItemDates, 0);
  SetLength(Result.ItemIsDates, 0);
  SetLength(Result.ItemIsTimes, 0);
  SetLength(Result.ItemTimes, 0);
  SetLength(Result.ItemGroups, 0);
  SetLength(Result.ItemCrypted, 0);
  SetLength(Result.LoadedImageInfo, 0);
  SetLength(Result.ItemInclude, 0);
  SetLength(Result.ItemLinks, 0);
end;

function RecordsInfoOne(name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean;
  Time: TDateTime; Crypt, Loaded, Include: Boolean; Links: string): TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 1);
  SetLength(Result.ItemIds, 1);
  SetLength(Result.ItemRotates, 1);
  SetLength(Result.ItemRatings, 1);
  SetLength(Result.ItemAccesses, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemOwners, 1);
  SetLength(Result.ItemKeyWords, 1);
  SetLength(Result.ItemCollections, 1);
  SetLength(Result.ItemDates, 1);
  SetLength(Result.ItemIsDates, 1);
  SetLength(Result.ItemIsTimes, 1);
  SetLength(Result.ItemTimes, 1);
  SetLength(Result.ItemGroups, 1);
  SetLength(Result.ItemCrypted, 1);
  SetLength(Result.LoadedImageInfo, 1);
  SetLength(Result.ItemInclude, 1);
  SetLength(Result.ItemLinks, 1);
  Result.ItemFileNames[0] := name;
  Result.ItemIds[0] := ID;
  Result.ItemRotates[0] := Rotate;
  Result.ItemRatings[0] := Rating;
  Result.ItemAccesses[0] := Access;
  Result.ItemComments[0] := Comment;
  Result.ItemOwners[0] := Owner_;
  Result.ItemKeyWords[0] := Comment;
  Result.ItemCollections[0] := Collection;
  Result.ItemDates[0] := Date;
  Result.ItemIsDates[0] := IsDate;
  Result.ItemIsTimes[0] := IsTime;
  Result.ItemTimes[0] := Time;
  Result.ItemGroups[0] := Groups;
  Result.ItemCrypted[0] := Crypt;
  Result.LoadedImageInfo[0] := Loaded;
  Result.ItemInclude[0] := Include;
  Result.ItemLinks[0] := Links;
end;

procedure AddToRecordsInfoOneInfo(var Infos: TRecordsInfo; Info: TOneRecordInfo);
var
  L: Integer;
begin
  L := Length(Infos.ItemFileNames) + 1;
  SetLength(Infos.ItemFileNames, L);
  SetLength(Infos.ItemIds, L);
  SetLength(Infos.ItemRotates, L);
  SetLength(Infos.ItemRatings, L);
  SetLength(Infos.ItemAccesses, L);
  SetLength(Infos.ItemComments, L);
  SetLength(Infos.ItemOwners, L);
  SetLength(Infos.ItemKeyWords, L);
  SetLength(Infos.ItemCollections, L);
  SetLength(Infos.ItemDates, L);
  SetLength(Infos.ItemIsDates, L);
  SetLength(Infos.ItemIsTimes, L);
  SetLength(Infos.ItemTimes, L);
  SetLength(Infos.ItemGroups, L);
  SetLength(Infos.ItemCrypted, L);
  SetLength(Infos.ItemInclude, L);
  SetLength(Infos.ItemLinks, L);
  Infos.ItemFileNames[L - 1] := Info.ItemFileName;
  Infos.ItemIds[L - 1] := Info.ItemId;
  Infos.ItemRotates[L - 1] := Info.ItemRotate;
  Infos.ItemRatings[L - 1] := Info.ItemRating;
  Infos.ItemAccesses[L - 1] := Info.ItemAccess;
  Infos.ItemComments[L - 1] := Info.ItemComment;
  Infos.ItemOwners[L - 1] := Info.ItemOwner;
  Infos.ItemKeyWords[L - 1] := Info.ItemKeyWords;
  Infos.ItemCollections[L - 1] := Info.ItemCollections;
  Infos.ItemDates[L - 1] := Info.ItemDate;
  Infos.ItemIsDates[L - 1] := Info.ItemIsDate;
  Infos.ItemIsTimes[L - 1] := Info.ItemIsTime;
  Infos.ItemTimes[L - 1] := Info.ItemTime;
  Infos.ItemGroups[L - 1] := Info.ItemGroups;
  Infos.ItemCrypted[L - 1] := Info.ItemCrypted;
  Infos.ItemInclude[L - 1] := Info.ItemInclude;
  Infos.ItemLinks[L - 1] := Info.ItemLinks;
end;

function RecordInfoOneA(name: string; ID, Rotate, Rating, Access, Size: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt: Boolean; Tag: Integer; Include: Boolean; Links: string): TOneRecordInfo;
begin
  Result.ItemFileName := name;
  Result.ItemCrypted := False;
  Result.ItemId := ID;
  Result.ItemSize := Size;
  Result.ItemRotate := Rotate;
  Result.ItemRating := Rating;
  Result.ItemAccess := Access;
  Result.ItemComment := Comment;
  Result.ItemCollections := Collection;
  Result.ItemOwner := Owner_;
  Result.ItemKeyWords := KeyWords;
  Result.Image := nil;
  Result.ItemDate := Date;
  Result.ItemTime := Time;
  Result.ItemIsDate := IsDate;
  Result.ItemIsTime := IsDate;
  Result.ItemGroups := Groups;
  Result.ItemCrypted := Crypt;
  Result.ItemInclude := Include;
  Result.ItemLinks := Links;
  Result.Tag := Tag;
end;

function GetRecordsFromOne(Info: TOneRecordInfo): TRecordsInfo;
begin
  Result.Position := 0;
  Result.Tag := 0;
  SetLength(Result.ItemFileNames, 1);
  SetLength(Result.ItemIds, 1);
  SetLength(Result.ItemRotates, 1);
  SetLength(Result.ItemRatings, 1);
  SetLength(Result.ItemAccesses, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemComments, 1);
  SetLength(Result.ItemKeyWords, 1);
  SetLength(Result.ItemOwners, 1);
  SetLength(Result.ItemGroups, 1);
  SetLength(Result.ItemDates, 1);
  SetLength(Result.ItemTimes, 1);
  SetLength(Result.ItemIsDates, 1);
  SetLength(Result.ItemIsTimes, 1);
  SetLength(Result.ItemCollections, 1);
  SetLength(Result.ItemCrypted, 1);
  SetLength(Result.LoadedImageInfo, 1);
  SetLength(Result.ItemInclude, 1);
  SetLength(Result.ItemLinks, 1);
  Result.ItemFileNames[0] := Info.ItemFileName;
  Result.ItemIds[0] := Info.ItemId;
  Result.ItemRotates[0] := Info.ItemRotate;
  Result.ItemRatings[0] := Info.ItemRating;
  Result.ItemAccesses[0] := Info.ItemAccess;
  Result.ItemComments[0] := Info.ItemComment;
  Result.ItemKeyWords[0] := Info.ItemKeyWords;
  Result.ItemOwners[0] := Info.ItemOwner;
  Result.ItemCollections[0] := Info.ItemCollections;
  Result.ItemDates[0] := Info.ItemDate;
  Result.ItemTimes[0] := Info.ItemTime;
  Result.ItemIsDates[0] := Info.ItemIsDate;
  Result.ItemIsTimes[0] := Info.ItemIsTime;
  Result.ItemGroups[0] := Info.ItemGroups;
  Result.ItemCrypted[0] := Info.ItemCrypted;
  Result.LoadedImageInfo[0] := Info.Loaded;
  Result.ItemInclude[0] := Info.ItemInclude;
  Result.ItemLinks[0] := Info.ItemLinks;
end;

function GetRecordFromRecords(Info: TRecordsInfo; N: Integer): TOneRecordInfo;
begin
  Result.ItemFileName := Info.ItemFileNames[N];
  Result.ItemId := Info.ItemIds[N];
  Result.ItemRotate := Info.ItemRotates[N];
  Result.ItemRating := Info.ItemRatings[N];
  Result.ItemAccess := Info.ItemAccesses[N];
  Result.ItemComment := Info.ItemComments[N];
  Result.ItemKeyWords := Info.ItemKeyWords[N];
  Result.ItemOwner := Info.ItemOwners[N];
  Result.ItemCollections := Info.ItemCollections[N];
  Result.ItemDate := Info.ItemDates[N];
  Result.ItemTime := Info.ItemTimes[N];
  Result.ItemIsDate := Info.ItemIsDates[N];
  Result.ItemIsTime := Info.ItemIsTimes[N];
  Result.ItemGroups := Info.ItemGroups[N];
  Result.ItemCrypted := Info.ItemCrypted[N];
  Result.ItemInclude := Info.ItemInclude[N];
  Result.Loaded := Info.LoadedImageInfo[N];
  Result.ItemLinks := Info.ItemLinks[N];
end;

procedure SetRecordToRecords(Info: TRecordsInfo; N: Integer; Rec: TOneRecordInfo);
begin
  Info.ItemFileNames[N] := Rec.ItemFileName;
  Info.ItemIds[N] := Rec.ItemId;
  Info.ItemRotates[N] := Rec.ItemRotate;
  Info.ItemRatings[N] := Rec.ItemRating;
  Info.ItemAccesses[N] := Rec.ItemAccess;
  Info.ItemComments[N] := Rec.ItemComment;
  Info.ItemKeyWords[N] := Rec.ItemKeyWords;
  Info.ItemOwners[N] := Rec.ItemOwner;
  Info.ItemCollections[N] := Rec.ItemCollections;
  Info.ItemDates[N] := Rec.ItemDate;
  Info.ItemTimes[N] := Rec.ItemTime;
  Info.ItemIsDates[N] := Rec.ItemIsDate;
  Info.ItemIsTimes[N] := Rec.ItemIsTime;
  Info.ItemGroups[N] := Rec.ItemGroups;
  Info.ItemCrypted[N] := Rec.ItemCrypted;
  Info.ItemInclude[N] := Rec.ItemInclude;
  Info.LoadedImageInfo[N] := Rec.Loaded;
  Info.ItemLinks[N] := Rec.ItemLinks;
end;

function LoadInfoFromDataSet(TDS: TDataSet): TOneRecordInfo;
begin
  Result.ItemFileName := TDS.FieldByName('FFileName').AsString;
  Result.ItemCrypted := ValidCryptBlobStreamJPG(TDS.FieldByName('Thum'));
  Result.ItemId := TDS.FieldByName('ID').AsInteger;
  Result.ItemImTh := TDS.FieldByName('StrTh').AsString;
  Result.ItemSize := TDS.FieldByName('FileSize').AsInteger;
  Result.ItemRotate := TDS.FieldByName('Rotated').AsInteger;
  Result.ItemRating := TDS.FieldByName('Rating').AsInteger;
  Result.ItemAccess := TDS.FieldByName('Access').AsInteger;
  Result.ItemComment := TDS.FieldByName('Comment').AsString;
  Result.ItemGroups := TDS.FieldByName('Groups').AsString;
  Result.ItemKeyWords := TDS.FieldByName('KeyWords').AsString;
  Result.ItemDate := TDS.FieldByName('DateToAdd').AsDateTime;
  Result.ItemIsDate := TDS.FieldByName('IsDate').AsBoolean;
  Result.ItemIsTime := TDS.FieldByName('IsTime').AsBoolean;
  Result.ItemInclude := TDS.FieldByName('Include').AsBoolean;
  Result.ItemLinks := TDS.FieldByName('Links').AsString;
  Result.Loaded := True;
end;

procedure SetRecordsInfoOne(var D: TRecordsInfo; N: Integer; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TDateTime; Crypt, Include: Boolean;
  Links: string);
begin
  D.ItemFileNames[N] := name;
  D.ItemIds[N] := ID;
  D.ItemRotates[N] := Rotate;
  D.ItemRatings[N] := Rating;
  D.ItemAccesses[N] := Access;
  D.ItemComments[N] := Comment;
  D.ItemGroups[N] := Groups;
  D.ItemDates[N] := Date;
  D.ItemTimes[N] := Time;
  D.ItemIsDates[N] := IsDate;
  D.ItemIsTimes[N] := IsTime;
  D.ItemCrypted[N] := Crypt;
  D.ItemInclude[N] := Include;
  D.ItemLinks[N] := Links;
end;

procedure AddRecordsInfoOne(var D: TRecordsInfo; name: string; ID, Rotate, Rating, Access: Integer;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Loaded, Include: Boolean; Links: string);
var
  L: Integer;
begin
  L := Length(D.ItemFileNames);
  SetLength(D.ItemFileNames, L + 1);
  SetLength(D.ItemIds, L + 1);
  SetLength(D.ItemRotates, L + 1);
  SetLength(D.ItemRatings, L + 1);
  SetLength(D.ItemAccesses, L + 1);
  SetLength(D.ItemComments, L + 1);
  SetLength(D.ItemOwners, L + 1);
  SetLength(D.ItemCollections, L + 1);
  SetLength(D.ItemKeyWords, L + 1);
  SetLength(D.ItemDates, L + 1);
  SetLength(D.ItemTimes, L + 1);
  SetLength(D.ItemIsDates, L + 1);
  SetLength(D.ItemIsTimes, L + 1);
  SetLength(D.ItemGroups, L + 1);
  SetLength(D.ItemCrypted, L + 1);
  SetLength(D.LoadedImageInfo, L + 1);
  SetLength(D.ItemInclude, L + 1);
  SetLength(D.ItemLinks, L + 1);
  D.ItemFileNames[L] := name;
  D.ItemIds[L] := ID;
  D.ItemRotates[L] := Rotate;
  D.ItemRatings[L] := Rating;
  D.ItemAccesses[L] := Access;
  D.ItemComments[L] := Comment;
  D.ItemOwners[L] := Owner_;
  D.ItemCollections[L] := Collection;
  D.ItemKeyWords[L] := KeyWords;
  D.ItemDates[L] := Date;
  D.ItemTimes[L] := Time;
  D.ItemIsDates[L] := IsDate;
  D.ItemIsTimes[L] := IsTime;
  D.ItemGroups[L] := Groups;
  D.ItemCrypted[L] := Crypt;
  D.LoadedImageInfo[L] := Loaded;
  D.ItemInclude[L] := Include;
  D.ItemLinks[L] := Links;
end;



procedure DBPopupMenuInfoToRecordsInfo(var DBP: TDBPopupMenuInfo; var RI: TRecordsInfo);
var
  I, FilesSelected: Integer;
begin
  FilesSelected := 0;
  for I := 0 to DBP.Count - 1 do
    if DBP[I].Selected then
      Inc(FilesSelected);

  RI := RecordsInfoNil;
  RI.Position := DBP.Position;
  for I := 0 to DBP.Count - 1 do
    if DBP[I].Selected or (FilesSelected <= 1) then
    begin
      AddRecordsInfoOne(RI, DBP[I].FileName, DBP[I].ID, DBP[I].Rotation, DBP[I].Rating, DBP[I].Access, DBP[I].Comment,
        '', '', '', DBP[I].Groups, DBP[I].Date, DBP[I].IsDate, DBP[I].IsTime, DBP[I].Time, DBP[I].Crypted,
        DBP[I].InfoLoaded, DBP[I].Include, DBP[I].Links);
    end;
end;

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

function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := nil;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrThCrc = :CRC AND StrTh = :StrTh');
    SetIntParam(FQuery, 0, StringCRC(StrTh));
    SetStrParam(FQuery, 1, StrTh);
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
    FQuery.Close;
  finally
    FreeDS(FQuery);
  end;
end;

function RecordInfoOne(name: string; ID, Rotate, Rating, Access: Integer; Size: Int64;
  Comment, KeyWords, Owner_, Collection, Groups: string; Date: TDateTime; IsDate, IsTime: Boolean; Time: TTime;
  Crypt, Include, Loaded: Boolean; Links: string): TOneRecordInfo;
begin
  Result.ItemFileName := name;
  Result.ItemCrypted := Crypt;
  Result.ItemId := ID;
  Result.ItemSize := Size;
  Result.ItemRotate := Rotate;
  Result.ItemRating := Rating;
  Result.ItemAccess := Access;
  Result.ItemComment := Comment;
  Result.ItemCollections := Collection;
  Result.ItemOwner := Owner_;
  Result.ItemKeyWords := KeyWords;
  Result.ItemDate := Date;
  Result.ItemTime := Time;
  Result.ItemIsDate := IsDate;
  Result.ItemIsTime := IsTime;
  Result.ItemGroups := Groups;
  Result.ItemInclude := Include;
  Result.ItemLinks := Links;
  Result.Image := nil;
  Result.PassTag := 0;
  Result.Loaded := Loaded;
end;

///
///  END DB TYPES
///

procedure CopyFiles(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean;
  ExplorerForm: TDBForm = nil);
begin
  TWindowsCopyFilesThread.Create(Handle, Src, Dest, Move, AutoRename, ExplorerForm);
end;

end.
