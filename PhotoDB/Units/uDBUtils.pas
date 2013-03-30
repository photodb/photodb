unit uDBUtils;

interface

uses
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.Math,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Imaging.Jpeg,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Graphics.Types,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  CCR.Exif,

  UnitGroupsWork,
  CommonDBSupport,
  UnitDBDeclare,
  GraphicCrypt,
  UnitLinksSupport,
  ProgressActionUnit,
  RAWImage,
  UnitDBCommonGraphics,

  uDBClasses,
  uGraphicUtils,
  uSettings,
  uDBTypes,
  uDBPopupMenuInfo,
  uConstants,
  uGroupTypes,
  uTranslate,
  uLogger,
  uBitmapUtils,
  uPrivateHelper,
  uRuntime,
  uShellIntegration,
  uDBBaseTypes,
  uMemory,
  uJpegUtils,
  uAssociations,
  uDBImageUtils,
  uCDMappingTypes,
  uDBForm,
  uCollectionEvents,
  uSessionPasswords,
  uDBGraphicTypes,
  uDBAdapter,
  uExifUtils;

type
  TDBKernelCallBack = procedure(ID: Integer; Params: TEventFields; Value: TEventValues) of object;
  TProgressValueHandler = procedure(Count: Integer) of object;
  TOnDBKernelEventProcedure = procedure(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues) of object;

procedure RenameFolderWithDB(CallBack: TDBKernelCallBack;
  CreateProgress: TProgressValueHandler; ShowProgress: TNotifyEvent; UpdateProgress: TProgressValueHandler; CloseProgress: TNotifyEvent;
  OldFileName, NewFileName: string; Ask: Boolean = True);
function RenameFileWithDB(CallBack: TDBKernelCallBack; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;

function GetImageIDW(FileName: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
function GetImageIDWEx(Images: TDBPopupMenuInfo; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False): TImageDBRecordAArray;
function GetImageIDTh(ImageTh: string): TImageDBRecordA;
function GetIdByFileName(FileName: string): Integer;
function GetFileNameById(ID: Integer): string;

procedure SetPrivate(ID: Integer);
procedure UnSetPrivate(ID: Integer);
procedure UpdateDeletedDBRecord(ID: Integer; FileName: string);
procedure UpdateMovedDBRecord(ID: Integer; FileName: string);
procedure UpdateDBItemPathInfo(ID: Integer; FileName: string);
procedure SetRotate(ID, Rotate: Integer);
procedure SetRating(ID, Rating: Integer);
procedure SetAttr(ID, Attr: Integer);

function UpdateImageRecord(Caller: TDBForm; FileName: string; ID: Integer): Boolean;

procedure ExecuteQuery(SQL: string);
procedure GetFileListByMask(BeginFile, Mask: string;
  Info: TDBPopupMenuInfo; var N: Integer; ShowPrivate: Boolean);
function GetInfoByFileNameA(FileName: string; LoadThum: Boolean; Info: TDBPopupMenuInfoRecord): Boolean;
procedure UpdateImageThInLinks(OldImageTh, NewImageTh: string);
function BitmapToString(Bit: TBitmap): string;
function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
function SumRotation(OldRotation, NewRotation: Integer): Integer;
procedure CopyFiles(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean; ExplorerForm: TDBForm);
procedure CopyRecordsW(OutTable, InTable: TDataSet; IsMobile, UseFinalLocation: Boolean; BaseFolder: string; var Groups: TGroups);
procedure SetFileNameByID(ID: Integer; FileName: string);

{ DB Types }

function GetMenuInfoByID(ID: Integer): TDBPopupMenuInfo;
function GetMenuInfoRecordByID(ID: Integer): TDBPopupMenuInfoRecord;
function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
procedure UpdateDataFromDB(Info: TDBPopupMenuInfo);
{ END DB Types }

implementation

uses
  UnitWindowsCopyFilesThread;

function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
var
  ROT: array [0 .. 3, 0 .. 3] of Integer;
begin
  OldRotation := OldRotation and DB_IMAGE_ROTATE_MASK;
  NewRotation := NewRotation and DB_IMAGE_ROTATE_MASK;

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

function SumRotation(OldRotation, NewRotation: Integer): Integer;
var
  ROT: array [0 .. 3, 0 .. 3] of Integer;
begin
  OldRotation := OldRotation and DB_IMAGE_ROTATE_MASK;
  NewRotation := NewRotation and DB_IMAGE_ROTATE_MASK;

  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_0, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_270;

  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_90, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_0;

  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_180;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_180, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_90;

  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_0] := DB_IMAGE_ROTATE_270;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_90] := DB_IMAGE_ROTATE_0;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_180] := DB_IMAGE_ROTATE_90;
  ROT[DB_IMAGE_ROTATE_270, DB_IMAGE_ROTATE_270] := DB_IMAGE_ROTATE_180;

  Result := ROT[OldRotation, NewRotation];
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
  RenameFolderWithDB(CallBack, nil, nil, nil, nil, OldFileName, NewFileName);

  if OnlyBD then
  begin
    CallBack(ID, [EventID_Param_Name], EventInfo);
    Exit;
  end;

  EventInfo.FileName := OldFileName;
  EventInfo.NewName := NewFileName;
  CallBack(ID, [EventID_Param_Name], EventInfo);
end;

procedure RenameFolderWithDB(CallBack: TDBKernelCallBack;
  CreateProgress: TProgressValueHandler; ShowProgress: TNotifyEvent; UpdateProgress: TProgressValueHandler; CloseProgress: TNotifyEvent;
  OldFileName, NewFileName: string; Ask: Boolean = True);
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
      DBFolder := NormalizeDBStringLike(DBFolder);
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

          ProgressWindow := nil;
          if not Assigned(CreateProgress) then
          begin
            ProgressWindow := GetProgressWindow;
            ProgressWindow.OneOperation := True;
            ProgressWindow.MaxPosCurrentOperation := FQuery.RecordCount;
          end else
            CreateProgress(FQuery.RecordCount);

          try
            SetQuery := GetQuery;

            if FQuery.RecordCount > 1 then
            begin
              if not Assigned(ShowProgress) then
              begin
                ProgressWindow.Show;
                ProgressWindow.Repaint;
                ProgressWindow.DoubleBuffered := True;
              end else
                ShowProgress(nil);
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
                EventInfo.FileName := OldPath;
                EventInfo.NewName := NewPath;
                CallBack(0, [EventID_Param_Name], EventInfo);
                try

                  if (I < 10) or (I mod 10 = 0) then
                  begin
                    if not Assigned(UpdateProgress) then
                    begin
                      ProgressWindow.XPosition := I;
                      ProgressWindow.Repaint;
                    end else
                      UpdateProgress(I);
                  end;

                except
                end;
                FQuery.Next;
              end;
            except
            end;
            FreeDS(SetQuery);
          finally
            if not Assigned(CloseProgress) then
              ProgressWindow.Release
            else
              CloseProgress(nil);
          end;

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
        RenameFolderWithDB(CallBack, CreateProgress, ShowProgress, UpdateProgress, CloseProgress,
          OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
    if DirectoryExists(NewFileName) then
    begin
      GetDirectoresOfPath(NewFileName, Dirs);
      for I := 0 to Dirs.Count - 1 do
        RenameFolderWithDB(CallBack, CreateProgress, ShowProgress, UpdateProgress, CloseProgress,
          OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
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
        EventInfo.Rotation := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotation := DB_IMAGE_ROTATE_0;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotation := DB_IMAGE_ROTATE_90;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotation := DB_IMAGE_ROTATE_180;
    end;
    SetRotate(ID, EventInfo.Rotation);
    CollectionEvents.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
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
        EventInfo.Rotation := DB_IMAGE_ROTATE_90;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotation := DB_IMAGE_ROTATE_180;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotation := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotation := DB_IMAGE_ROTATE_0;
    end;
    SetRotate(ID, EventInfo.Rotation);
    CollectionEvents.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
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
        EventInfo.Rotation := DB_IMAGE_ROTATE_180;
      DB_IMAGE_ROTATE_90:
        EventInfo.Rotation := DB_IMAGE_ROTATE_270;
      DB_IMAGE_ROTATE_180:
        EventInfo.Rotation := DB_IMAGE_ROTATE_0;
      DB_IMAGE_ROTATE_270:
        EventInfo.Rotation := DB_IMAGE_ROTATE_90;
    end;
    SetRotate(ID, EventInfo.Rotation);
    CollectionEvents.DoIDEvent(Caller, ID, [EventID_Param_Rotate], EventInfo);
  end;
end;

function GetIdByFileName(FileName: string): Integer;
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    SetSQL(FQuery, 'SELECT ID FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(FileName, True))
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

procedure SetStringField(ID: Integer; FieldName, FieldValue: string);
var
  DS: TDataSet;
  SQL: string;
begin
  DS := GetQuery;
  try
    SQL := 'UPDATE $DB$ SET ' + FieldName + ' = :' + FieldName + ' WHERE ID = ' +IntToStr(ID);
    SetSQL(DS, SQL);
    SetStrParam(DS, 0, FieldValue);
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

procedure SetComment(ID: Integer; Comment: string);
begin
  SetStringField(ID, 'Comment', Comment);
end;

procedure SetKeyWords(ID: Integer; KeyWords: string);
begin
  SetStringField(ID, 'KeyWords', KeyWords);
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

procedure UpdateDBItemPathInfo(ID: Integer; FileName: string);
var
  UC: TUpdateCommand;
begin
  UC := TUpdateCommand.Create(ImageTable);
  try
   UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

   UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(FileName, True)));
   UC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(FileName)));
   UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(FileName)));

   UC.Execute;
  except
    on e: Exception do
      EventLog(e);
  end;
  F(UC);
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

function UpdateImageRecord(Caller: TDBForm; FileName: string; ID: Integer): Boolean;
var
  Res: TImageDBRecordA;
  I, Attribute: Integer;
  EventInfo: TEventValues;
  ExifData: TExifData;
  EF: TEventFields;
  MS: TMemoryStream;
  Info: TDBPopupMenuInfoRecord;

  UC: TUpdateCommand;
  SC: TSelectCommand;
  DA: TDBAdapter;

  function MapDBFileName(FileName: string): string;
  var
    I: Integer;
  begin
    if FolderView then
      if not FileExists(FileName) then
        FileName := ProgramDir + FileName;

    FileName := LongFileNameW(FileName);
    for I := Length(FileName) - 1 downto 1 do
    begin
      if (FileName[I] = '\') and (FileName[I + 1] = '\') then
        Delete(FileName, I, 1);
    end;

    Result := FileName;
  end;

  function FileNameToDBPath(FileName: string): string;
  begin
    Result := AnsiLowerCase(FileName);
    UnProcessPath(Result);
    if FolderView and Result.StartsWith(ExtractFilePath(Application.ExeName)) then
      Delete(Result, 1, ExtractFilePath(Application.ExeName).Length);
  end;

begin
  Result := False;
  if (ID = 0) or DBReadOnly then
    Exit;

  FileName := MapDBFileName(FileName);

  Res := GetImageIDW(FileName, False);
  if Res.Jpeg = nil then
    Exit;

  try
    EF := [];
    EventInfo.ID := ID;
    EventInfo.JPEGImage := Res.Jpeg;
    EventInfo.FileName := FileName;
    EF := [EventID_FileProcessed];

    SC := TSelectCommand.Create(ImageTable, True);
    try
      SC.AddParameter(TStringParameter.Create('StrTh'));
      SC.AddParameter(TIntegerParameter.Create('Attr'));
      SC.AddParameter(TIntegerParameter.Create('Rating'));
      SC.AddParameter(TIntegerParameter.Create('Rotated'));
      SC.AddParameter(TStringParameter.Create('Comment'));
      SC.AddParameter(TStringParameter.Create('Keywords'));
      SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

      if SC.Execute > 0 then
      begin
        MS := nil;
        DA := TDBAdapter.Create(SC.DS);
        UC := TUpdateCommand.Create(ImageTable);
        try
          UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

          if Res.IsEncrypted or (Res.Password <> '') then
          begin
            MS := TMemoryStream.Create;
            EncryptGraphicImage(Res.Jpeg, Res.Password, MS);
            UC.AddParameter(TStreamParameter.Create('Thum', MS));
          end else
            UC.AddParameter(TPersistentParameter.Create('Thum', Res.Jpeg));

          UC.AddParameter(TStringParameter.Create('FFileName', FileNameToDBPath(FileName)));
          UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(FileName)));
          UC.AddParameter(TStringParameter.Create('StrTh', Res.ImTh));
          UC.AddParameter(TIntegerParameter.Create('StrThCrc', Integer(StringCRC(Res.ImTh))));

          UC.AddParameter(TIntegerParameter.Create('Width', Res.ImageWidth));
          UC.AddParameter(TIntegerParameter.Create('Height', Res.ImageHeight));
          UC.AddParameter(TIntegerParameter.Create('FileSize', GetFileSizeByName(FileName)));
          UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(FileName, True)));

          ExifData := TExifData.Create;
          try
            ExifData.LoadFromGraphic(FileName);
            if Settings.ReadBool('Options', 'FixDateAndTime', True) then
            begin
              if (ExifData.DateTimeOriginal > 0) and (YearOf(ExifData.DateTimeOriginal) > cMinEXIFYear) then
              begin
                EventInfo.Date := DateOf(ExifData.DateTimeOriginal);
                EventInfo.Time := TimeOf(ExifData.DateTimeOriginal);
                EventInfo.IsDate := True;
                EventInfo.IsTime := True;

                EF := EF + [EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime];

                UC.AddParameter(TDateTimeParameter.Create('DateToAdd', EventInfo.Date));
                UC.AddParameter(TDateTimeParameter.Create('ATime', EventInfo.Time));
                UC.AddParameter(TBooleanParameter.Create('IsDate', EventInfo.IsDate));
                UC.AddParameter(TBooleanParameter.Create('IsTime', EventInfo.IsTime));
              end;
            end;
            if Settings.Exif.ReadInfoFromExif then
            begin
              Info := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
              try
                UpdateImageRecordFromExif(Info);

                if (Info.Rating > 0) and (DA.Rating <> Info.Rating) then
                begin
                  UC.AddParameter(TIntegerParameter.Create('Rating', Info.Rating));

                  EF := EF + [EventID_Param_Rating];
                  EventInfo.Rating := Info.Rating;
                end;

                if (Info.Rotation > DB_IMAGE_ROTATE_0) and (DA.Rotation <> Info.Rotation) then
                begin
                  UC.AddParameter(TIntegerParameter.Create('Rotated', Info.Rotation));

                  EF := EF + [EventID_Param_Rotate];
                  EventInfo.Rotation := Info.Rotation;
                end;

                if (Info.Comment <> '') and (DA.Comment <> Info.Comment) then
                begin
                  UC.AddParameter(TStringParameter.Create('Comment', Info.Comment));

                  EF := EF + [EventID_Param_Comment];
                  EventInfo.Comment := Info.Comment;
                end;

                if (Info.Keywords <> '') and (DA.Keywords <> Info.Keywords) then
                begin
                  UC.AddParameter(TStringParameter.Create('KeyWords', Info.Keywords));

                  EF := EF + [EventID_Param_KeyWords];
                  EventInfo.KeyWords := Info.KeyWords;
                end;
              finally
                F(Info);
              end;
            end;
          except
            on E: Exception do
              EventLog(':UpdateImageRecordEx()/FixDateAndTime throw exception: ' + E.message);
          end;
          F(ExifData);

          Attribute := Db_attr_norm;
          if Res.Count > 1 then
          begin
            for I := 0 to Res.Count - 1 do
              if (Res.IDs[I] <> ID) and (Res.Attr[I] <> Db_attr_not_exists) then
              begin
                Attribute := Db_attr_duplicate;
                Break;
              end;
          end;

          UC.AddParameter(TIntegerParameter.Create('Attr', Attribute));

          EF := EF + [EventID_Param_Attr];
          EventInfo.Attr := Attribute;

          UC.Execute;
          Result := True;

          TThread.Synchronize(nil,
            procedure
            begin
              if Caller = nil then
                Caller := TDBForm(Application.MainForm);

              CollectionEvents.DoIDEvent(Caller, ID, EF, EventInfo);
            end
          );
          UpdateImageThInLinks(DA.LongImageID, Res.ImTh);

        finally
          F(UC);
          F(DA);
          F(MS);
        end;
      end;

    finally
      F(SC);
    end;

  finally
    Res.Jpeg.Free;
    Res.Jpeg := nil;
  end;
end;

function GetImageIDTh(ImageTh: string): TImageDBRecordA;
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

  G := nil;
  try
    if FQuery.RecordCount <> 0 then
    begin
      if GraphicCrypt.ValidCryptGraphicFile(FileName) then
      begin
        Pass := SessionPasswords.FindForFile(FileName);
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
        Pass := SessionPasswords.FindForBlobStream(FQuery.FieldByName('Thum'));
        FJPEG := TJPEGImage.Create;
        if Pass <> '' then
          DeCryptBlobStreamJPG(FQuery.FieldByName('Thum'), Pass, FJPEG);

      end else
      begin
        FJPEG := TJPEGImage.Create;
        FJPEG.Assign(FQuery.FieldByName('Thum'));
      end;
      try
        Res := CompareImages(FJPEG, G, Rot);
      finally
        F(FJPEG);
      end;
      Xrot[I - 1] := Rot;
      Val[I - 1] := (Res.ByGistogramm > 1) or (Res.ByPixels > 1);
      if Val[I - 1] then
        Inc(Count);
      FQuery.Next;
    end;
    F(FJPEG);
  finally
    F(G);
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

function GetImageIDWEx(Images: TDBPopupMenuInfo; UseFileNameScanning: Boolean;
  OnlyImTh: Boolean = False): TImageDBRecordAArray;
var
  K, I, L, Len: Integer;
  FQuery: TDataSet;
  Temp, Sql, FromDB: string;
  ThImS: TImageDBRecordAArray;
begin
  L := Images.Count;
  SetLength(ThImS, L);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    ThImS[I] := GetImageIDW(Images[I].FileName, UseFileNameScanning, True);
  FQuery := GetQuery;

  Sql := '';
  if GetDBType = DB_TYPE_MDB then
  begin
    FromDB := '(SELECT ID, FFileName, Attr, StrTh FROM $DB$ WHERE ';
    for I := 1 to L do
    begin
      if I = 1 then
        Sql := Sql + Format(' (IsNull(StrThCrc) or StrThCrc = :strcrc%d) ', [I])
      else
        Sql := Sql + Format(' or (IsNull(StrThCrc) or StrThCrc = :strcrc%d) ', [I]);
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
      SetStrParam(FQuery, I, ThImS[I - L].ImTh);

  end else
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

      Temp := FQuery.FieldByName('StrTh').AsString;
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

function GetImageIDW(FileName: string; UseFileNameScanning: Boolean; OnlyImTh: Boolean = False; AThImageSize: Integer = 0;
  ADBJpegCompressionQuality: Byte = 0): TImageDBRecordA;
var
  Bmp, Thbmp: TBitmap;
  PassWord,
  Imth: string;
  IsEncrypted: Boolean;
  G: TGraphic;
begin
  DoProcessPath(FileName);
  if AThImageSize = 0 then
    AThImageSize := ThImageSize;
  if ADBJpegCompressionQuality = 0 then
    ADBJpegCompressionQuality := DBJpegCompressionQuality;

  Result.IsEncrypted := False;
  Result.Password := '';
  Result.ImTh := '';
  Result.Count := 0;
  Result.UsedFileNameSearch := False;
  Result.IsError := False;
  Result.Jpeg := nil;
  Result.ImageWidth := 0;
  Result.ImageHeight := 0;

  G := nil;
  try
    try
      LoadGraphic(FileName, G, IsEncrypted, PassWord);
      Result.IsEncrypted := IsEncrypted;
      Result.Password := Password;
      if G = nil then
        Exit;
    except
      on E: Exception do
      begin
        EventLog(E);
        Result.IsError := True;
        Result.ErrorText := E.message;
        Exit;
      end;
    end;

    Result.ImageWidth := G.Width;
    Result.ImageHeight := G.Height;
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

          if (G is TRAWImage) then
            TRAWImage(G).DisplayDibSize := True;

          if Max(G.Width, G.Height) > AThImageSize then
          begin
            if G.Width > G.Height then
              Thbmp.SetSize(AThImageSize, Round(AThImageSize * (G.Height / G.Width)))
            else
              Thbmp.SetSize(Round(AThImageSize * (G.Width / G.Height)), AThImageSize);

          end else
            Thbmp.SetSize(G.Width, G.Height);

          LoadImageX(G, Bmp, $FFFFFF);
          F(G);
          DoResize(Thbmp.Width, Thbmp.Height, Bmp, Thbmp);
        finally
          F(Bmp);
        end;
        Result.Jpeg.Assign(Thbmp);
        Result.Jpeg.JPEGNeeded;
        AssignGraphic(Thbmp, Result.Jpeg);
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
        EventLog(E);
        Result.IsError := True;
        Result.ErrorText := E.message;
      end;
    end;
  finally
    F(G);
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
      SetSQL(Table, 'Update $DB$ set Links=' + NormalizeDBString(Link) + ' where ID = ' + IntToStr(IDs[I]));
      ExecSQL(Table);
    end;
  finally
    FreeDS(Table);
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
  Info.FileName := FileName;
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
          SessionPasswords.FindForBlobStream(FQuery.FieldByName('thum')), Info.Image);
        Info.Encrypted := True;
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

function BitmapToString(Bit: TBitmap): string;
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
        if (B1 = 0) and (B2 = 0) then
        begin
          B1 := 1;
          B2 := 1;
        end;
        Result := Result + Char(B1 shl 8 or B2);
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
  ByDirectory: Boolean;
begin
  if FileExists(BeginFile) then
    Folder := ExtractFileDir(BeginFile);

  ByDirectory := DirectoryExists(BeginFile);
  if ByDirectory then
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
          Found := System.SysUtils.FindNext(SearchRec);
        end;
        System.SysUtils.FindClose(SearchRec);

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
  if (Info.Count = 0) and not ByDirectory then
    Info.Add(TDBPopupMenuInfoRecord.CreateFromFile(BeginFile));
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
  FQuery := GetQuery(True);
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
    Result.IsListItem := False;
    Result.IsPlusMenu := False;
  finally
    FreeDS(FQuery);
  end;
end;

function GetMenuInfoRecordByID(ID: Integer): TDBPopupMenuInfoRecord;
var
  FQuery: TDataSet;
begin
  Result := nil;
  FQuery := GetQuery(True);
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE ID = :ID');
    SetIntParam(FQuery, 0, ID);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    Result := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
  finally
    FreeDS(FQuery);
  end;
end;

procedure UpdateDataFromDB(Info: TDBPopupMenuInfo);
var
  I, J, K: Integer;
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  for I := 0 to Info.Count - 1 do
  begin
    if not Info[I].InfoLoaded then
    begin
      FQuery := GetQuery;
      try
        //todo: don't select images
        SetSQL(FQuery, 'Select * from $DB$ where FolderCRC=' + IntToStr(GetPathCRC(Info[I].FileName, True)));
        FQuery.Open;

        if not FQuery.Eof then
          for J := 1 to FQuery.RecordCount do
          begin
            MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
            try
              for K := I to Info.Count - 1 do
              begin
                if AnsiLowerCase(Info[I].FileName) = MenuRecord.FileName then
                  Info[I].Assign(MenuRecord);
              end;
              FQuery.Next;
            finally
              F(MenuRecord);
            end;
          end;
      finally
        FreeDS(FQuery);
      end;
    end;
  end;
end;

function GetMenuInfoByStrTh(StrTh: string): TDBPopupMenuInfo;
var
  FQuery: TDataSet;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfo.Create;
  FQuery := GetQuery;
  try
    SetSQL(FQuery, 'SELECT * FROM $DB$ WHERE StrThCrc = :CRC AND StrTh = :StrTh');
    SetIntParam(FQuery, 0, StringCRC(StrTh));
    SetStrParam(FQuery, 1, StrTh);
    FQuery.Open;
    if FQuery.RecordCount <> 1 then
      Exit;

    MenuRecord := TDBPopupMenuInfoRecord.CreateFromDS(FQuery);
    Result.Add(MenuRecord);
    Result.ListItem := nil;
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

    if FileExistsSafe(OutTable.FieldByName('FFileName').AsString) then
      InTable.FieldByName('Attr').AsInteger := Db_attr_norm
    else
      InTable.FieldByName('Attr').AsInteger := Db_attr_not_exists;

  finally
    F(Rec);
  end;
end;

procedure SetFileNameByID(ID: Integer; FileName: string);
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    FileName := NormalizeDBString(AnsiLowerCase(FileName));
    SetSQL(FQuery, 'Update $DB$ Set FFileName="' + FileName + '" WHERE ID=' + Inttostr(ID));
    try
      ExecSQL(FQuery);
    except
    end;
  finally
    FreeDS(FQuery);
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
