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
  Dmitry.Utils.Files,

  CCR.Exif,

  UnitDBDeclare,
  GraphicCrypt,
  UnitLinksSupport,
  ProgressActionUnit,
  UnitDBCommonGraphics,

  uDBConnection,
  uDBClasses,
  uDBContext,
  uDBEntities,
  uMediaInfo,
  uGraphicUtils,
  uSettings,
  uDBTypes,
  uConstants,
  uTranslate,
  uLogger,
  uRuntime,
  uShellIntegration,
  uDBBaseTypes,
  uMemory,
  uAssociations,
  uCDMappingTypes,
  uDBForm,
  uCollectionEvents,
  uDBAdapter,
  uExifUtils,
  uColorUtils;

type
  TDBKernelCallBack = procedure(ID: Integer; Params: TEventFields; Value: TEventValues) of object;
  TProgressValueHandler = procedure(Count: Integer) of object;
  TOnDBKernelEventProcedure = procedure(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues) of object;

procedure RenameFolderWithDB(Context: IDBContext; CallBack: TDBKernelCallBack;
  CreateProgress: TProgressValueHandler; ShowProgress: TNotifyEvent; UpdateProgress: TProgressValueHandler; CloseProgress: TNotifyEvent;
  OldFileName, NewFileName: string; Ask: Boolean = True);
function RenameFileWithDB(Context: IDBContext; CallBack: TDBKernelCallBack; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;

function UpdateImageRecord(DBContext: IDBContext; Caller: TDBForm; FileName: string; ID: Integer): Boolean;
function UpdateImageRecordEx(DBContext: IDBContext; Caller: TDBForm; Info: TMediaItem; Settings: TSettings): Boolean;
procedure MarkRecordAsUpdated(DBContext: IDBContext; ID: Integer);

procedure GetFileListByMask(DBContext: IDBContext; BeginFile, Mask: string;
  Info: TMediaItemCollection; var N: Integer; ShowPrivate: Boolean);

function GetNeededRotation(OldRotation, NewRotation: Integer): Integer;
function SumRotation(OldRotation, NewRotation: Integer): Integer;
procedure CopyFiles(Context: IDBContext; Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean; ExplorerForm: TDBForm);
procedure CopyRecordsW(OutTable, InTable: TDataSet; IsMobile, UseFinalLocation: Boolean; BaseFolder: string; Groups: TGroups);

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

function RenameFileWithDB(Context: IDBContext; CallBack: TDBKernelCallBack; OldFileName, NewFileName: string; ID: Integer; OnlyBD: Boolean): Boolean;
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
    FQuery := Context.CreateQuery;
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
  RenameFolderWithDB(Context, CallBack, nil, nil, nil, nil, OldFileName, NewFileName);

  if OnlyBD then
  begin
    CallBack(ID, [EventID_Param_Name], EventInfo);
    Exit;
  end;

  EventInfo.FileName := OldFileName;
  EventInfo.NewName := NewFileName;
  CallBack(ID, [EventID_Param_Name], EventInfo);
end;

procedure RenameFolderWithDB(Context: IDBContext; CallBack: TDBKernelCallBack;
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

    FQuery := Context.CreateQuery(dbilRead);
    try
      FFolder := IncludeTrailingBackslash(OldFileName);

      DBFolder := AnsiLowerCase(FFolder);
      DBFolder := NormalizeDBStringLike(DBFolder);
      if FolderView then
        Delete(DBFolder, 1, Length(ProgramDir));

      SetSQL(FQuery, 'Select ID, FFileName From $DB$ where (FFileName Like :FolderA)');
      SetStrParam(FQuery, 0, '%' + DBFolder + '%');

      OpenDS(FQuery);
      FQuery.First;
      if FQuery.RecordCount > 0 then
        if Ask or (ID_OK = MessageBoxDB(GetActiveWindow, Format(TA('This folder (%s) contains %d photos in the collection!. Adjust the information in the collection?', 'Explorer'),
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
            SetQuery := Context.CreateQuery;

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
        RenameFolderWithDB(Context, CallBack, CreateProgress, ShowProgress, UpdateProgress, CloseProgress,
          OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
    if DirectoryExists(NewFileName) then
    begin
      GetDirectoresOfPath(NewFileName, Dirs);
      for I := 0 to Dirs.Count - 1 do
        RenameFolderWithDB(Context, CallBack, CreateProgress, ShowProgress, UpdateProgress, CloseProgress,
          OldFileName + '\' + Dirs[I], NewFileName + '\' + Dirs[I]);
    end;
  finally
    F(Dirs);
  end;
end;

procedure MarkRecordAsUpdated(DBContext: IDBContext; ID: Integer);
var
  UC: TUpdateCommand;
begin
  UC := DBContext.CreateUpdate(ImageTable, True);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));
    UC.AddParameter(TDateTimeParameter.Create('DateUpdated', Now));

    UC.Execute;
  finally
    F(UC);
  end;
end;

function UpdateImageRecordEx(DBContext: IDBContext; Caller: TDBForm; Info: TMediaItem; Settings: TSettings): Boolean;
var
  Res: TMediaInfo;
  I, Attribute: Integer;
  EventInfo: TEventValues;
  ExifData: TExifData;
  EF: TEventFields;
  MS, HS: TMemoryStream;
  UC: TUpdateCommand;
  FileName: string;
  MediaFile: TMediaItem;

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
  MS := nil;
  HS := nil;

  if (Info.ID = 0) or DBReadOnly then
    Exit;

  FileName := MapDBFileName(Info.FileName);

  Res := GetImageIDW(DBContext, FileName, False, Settings);
  if Res.Jpeg = nil then
    Exit;

  try
    EF := [];
    EventInfo.ID := Info.ID;
    EventInfo.JPEGImage := Res.Jpeg;
    EventInfo.FileName := FileName;
    EF := [EventID_FileProcessed];

    UC := DBContext.CreateUpdate(ImageTable);
    try
      UC.AddWhereParameter(TIntegerParameter.Create('ID', Info.ID));

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

      UC.AddParameter(TStringParameter.Create('Colors', ColorsToString(Res.Colors)));
      UC.AddParameter(TIntegerParameter.Create('PreviewSize', Res.Size));
      UC.AddParameter(TDateTimeParameter.Create('DateUpdated', Now));

      if not FileExistsSafe(FileName) then
        UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_not_exists))
      else
        UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_norm));

      HS := TMemoryStream.Create;
      HS.WriteBuffer(Res.Histogram, SizeOf(Res.Histogram));
      HS.Seek(0, soFromBeginning);
      UC.AddParameter(TStreamParameter.Create('Histogram', HS));

      ExifData := TExifData.Create;
      try
        ExifData.LoadFromGraphic(FileName);
        if AppSettings.ReadBool('Options', 'FixDateAndTime', True) then
        begin
          if (ExifData.ImageDateTime > 0) and (YearOf(ExifData.ImageDateTime) > cMinEXIFYear) then
          begin
            EventInfo.Date := DateOf(ExifData.ImageDateTime);
            EventInfo.Time := TimeOf(ExifData.ImageDateTime);
            EventInfo.IsDate := True;
            EventInfo.IsTime := True;

            EF := EF + [EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime];

            UC.AddParameter(TDateTimeParameter.Create('DateToAdd', EventInfo.Date));
            UC.AddParameter(TDateTimeParameter.Create('ATime', EventInfo.Time));
            UC.AddParameter(TBooleanParameter.Create('IsDate', EventInfo.IsDate));
            UC.AddParameter(TBooleanParameter.Create('IsTime', EventInfo.IsTime));
          end;
        end;
        if AppSettings.Exif.ReadInfoFromExif then
        begin
          MediaFile := TMediaItem.CreateFromFile(FileName);
          try
            UpdateImageRecordFromExif(MediaFile);

            if (MediaFile.Rating > 0) and (Info.Rating <> MediaFile.Rating) then
            begin
              UC.AddParameter(TIntegerParameter.Create('Rating', MediaFile.Rating));

              EF := EF + [EventID_Param_Rating];
              EventInfo.Rating := MediaFile.Rating;
            end;

            if (MediaFile.Rotation > DB_IMAGE_ROTATE_0) and (Info.Rotation <> MediaFile.Rotation) then
            begin
              UC.AddParameter(TIntegerParameter.Create('Rotated', MediaFile.Rotation));

              EF := EF + [EventID_Param_Rotate];
              EventInfo.Rotation := MediaFile.Rotation;
            end;

            if (MediaFile.Comment <> '') and (Info.Comment <> MediaFile.Comment) then
            begin
              UC.AddParameter(TStringParameter.Create('Comment', MediaFile.Comment));

              EF := EF + [EventID_Param_Comment];
              EventInfo.Comment := MediaFile.Comment;
            end;

            if (MediaFile.Keywords <> '') and (Info.Keywords <> MediaFile.Keywords) then
            begin
              UC.AddParameter(TStringParameter.Create('KeyWords', MediaFile.Keywords));

              EF := EF + [EventID_Param_KeyWords];
              EventInfo.KeyWords := MediaFile.KeyWords;
            end;
          finally
            F(MediaFile);
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
          if (Res.IDs[I] <> Info.ID) and (Res.Attr[I] <> Db_attr_not_exists) then
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

          CollectionEvents.DoIDEvent(Caller, Info.ID, EF, EventInfo);
        end
      );

    finally
      F(UC);
      F(MS);
      F(HS);
    end;

  finally
    Res.Jpeg.Free;
    Res.Jpeg := nil;
  end;
end;

function UpdateImageRecord(DBContext: IDBContext; Caller: TDBForm; FileName: string; ID: Integer): Boolean;
var
  Info: TMediaItem;
  SC: TSelectCommand;
begin
  Result := False;

  SC := DBContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create());
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
    begin
      Info := TMediaItem.CreateFromDS(SC.DS);
      try
        F(SC);
        Result := UpdateImageRecordEx(DBContext, Caller, Info, nil);
      finally
        F(Info);
      end;
    end;
  finally
    F(SC);
  end;

end;

procedure GetFileListByMask(DBContext: IDBContext; BeginFile, Mask: string; Info: TMediaItemCollection; var N: Integer; ShowPrivate: Boolean);
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
      FQuery := DBContext.CreateQuery(dbilRead);
      try
        Folder := IncludeTrailingBackslash(AnsiLowerCase(Folder));

        if FolderView then
          AddFolder := AnsiLowerCase(ProgramDir)
        else
          AddFolder := '';

        SetSQL(FQuery, 'Select * from $DB$ where FolderCRC=' + IntToStr(GetPathCRC(Folder, False)));

        OpenDS(FQuery);
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
    Info.Add(TMediaItem.CreateFromFile(BeginFile));
end;

///////////////////////////////////////////////////////////////////////
///  BEGIN DB TYPES
///////////////////////////////////////////////////////////////////////
procedure CopyRecordsW(OutTable, InTable: TDataSet; IsMobile, UseFinalLocation: Boolean; BaseFolder: string; Groups: TGroups);
var
  FileName: string;
  NewGroups: TGroups;
  Rec: TMediaItem;
begin
  Rec := TMediaItem.Create;
  try
    Rec.ReadFromDS(OutTable);
    Rec.WriteToDS(InTable);

    NewGroups := TGroups.CreateFromString(Rec.Groups);
    try
      Groups.AddGroups(NewGroups);
    finally
      F(NewGroups);
    end;

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

      InTable.FieldByName('StrThCrc').AsInteger := Integer(StringCRC(InTable.FieldByName('StrTh').AsString));
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
///
///  END DB TYPES
///

procedure CopyFiles(Context: IDBContext; Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean;
  ExplorerForm: TDBForm);
begin
  TWindowsCopyFilesThread.Create(Context, Handle, Src, Dest, Move, AutoRename, ExplorerForm);
end;

end.
