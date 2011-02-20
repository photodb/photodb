unit UnitUpdateDBThread;

interface

uses
  ReplaceForm, UnitDBKernel, Windows, Dolphin_db, Classes, UnitUpdateDB, Forms,
  SysUtils, DB, GraphicCrypt, Dialogs, DateUtils, CommonDBSupport,
  Win32crc, Jpeg, UnitUpdateDBObject, uVistaFuncs, uLogger, uFileUtils,
  UnitDBDeclare, UnitDBCommon, uMemory, uDBPopupMenuInfo, uConstants,
  CCR.Exif, uShellIntegration, uDBTypes, uRuntime, uDBUtils, uSysUtils,
  uTranslate, ActiveX, CCR.Exif.JPEGUtils;

type
  TFileProcessProcedureOfObject = procedure(var FileName : string) of object;

type
  UpdateDBThread = class(TThread)
  private
    { Private declarations }
    FOnDone: TNotifyEvent;
    FTerminating: PBoolean;
    FPause: PBoolean;
    StringParam: string;
    IntResult, IntIDResult: Integer;
    FCurrentImageDBRecord: TImageDBRecordA;
    FSender: TUpdaterDB;
    ResArray: TImageDBRecordAArray;
    IDParam: Integer;
    NameParam: string;
    FInfo: TDBPopupMenuInfo;
    FUseFileNameScaning: Boolean;
    FileNumber: Integer;
    Time, Date: TDateTime;
    IsTime: Boolean;
    FNoLimit: Boolean;
  protected
    procedure Execute; override;
  public
    procedure LimitError;
    Procedure DoOnDone;
    procedure ExecuteReplaceDialog;
    procedure AddAutoAnswer;
    procedure SetImages;
    procedure DoEventReplace(ID : Integer; Name : String);
    procedure DoEventReplaceSynch;
    procedure UpdateCurrent;
    procedure CryptFileWithoutPass;
    function Res : TImageDBRecordA;
    procedure FileProcessed;
    constructor Create(Sender : TUpdaterDB;
      Info : TDBPopupMenuInfo; OnDone : TNotifyEvent;
      AutoAnswer : Integer; UseFileNameScaning : Boolean; Terminating,
      Pause: PBoolean; NoLimit : boolean = false);
  end;

type
  TValueObject = class(TObject)
  private
    FTIntValue: Integer;
    FSTStrValue: TStrings;
    FTBoolValue: Boolean;
    procedure SetTIntValue(const Value: Integer);
    procedure SetTStrValue(const Value: TStrings);
    procedure SetTBoolValue(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property TIntValue: Integer read FTIntValue write SetTIntValue;
    property TStrValue: TStrings read FSTStrValue write SetTStrValue;
    property TBoolValue: Boolean read FTBoolValue write SetTBoolValue;
  end;

type
  DirectorySizeThread = class(TThread)
  private
    { Private declarations }
    FDirectory, StrParam: string;
    FObject: TValueObject;
    FOnDone: TNotifyEvent;
    FTerminating: PBoolean;
    IntParam: Integer;
    FOnFileFounded: TFileFoundedEvent;
    FProcessFileEvent: TFileProcessProcedureOfObject;
  protected
    procedure Execute; override;
  public
    constructor Create(Directory: string; OnDone: TNotifyEvent; Terminating: PBoolean;
      OnFileFounded: TFileFoundedEvent; ProcessFileEvent: TFileProcessProcedureOfObject = nil);
    procedure DoOnDone;
    procedure DoFileProcessed;
    procedure DoOnFileFounded;
    function GetDirectory(DirectoryName: string; var Files : TStrings; Terminating : PBoolean):integer;
  end;

var
  ShowMessageAboutLimit: Boolean = True;
  CryptFileWithoutPassChecked: Boolean = False;
  FAutoAnswer: Integer = -1;

function SQL_AddFileToDB(Path: string; Crypted: Boolean; JPEG: TJpegImage; ImTh, KeyWords, Comment, Password: string;
  OrWidth, OrHeight: Integer; var Date, Time: TDateTime; var IsTime: Boolean; Rating: Integer = 0;
  Rotated: Integer = DB_IMAGE_ROTATE_0; Links: string = ''; Access: Integer = 0; Groups: string = ''): Boolean;

implementation

{ UpdateDBThread }

constructor UpdateDBThread.Create(Sender : TUpdaterDB;
  Info : TDBPopupMenuInfo; OnDone: TNotifyEvent;
  AutoAnswer : Integer; UseFileNameScaning : Boolean; Terminating,
  Pause: PBoolean; NoLimit : boolean = false);
begin
  Inherited Create(False);
  FInfo := Info; //Copy pointer to self

  FOnDone := OnDone;
  FTerminating := Terminating;
  FPause := Pause;
  FAutoAnswer := AutoAnswer;
  FSender := Sender;
  FNoLimit := NoLimit;
  FUseFileNameScaning := UseFileNameScaning;
end;

procedure UpdateDBThread.DoOnDone;
begin
  if Assigned(FOnDone) then
    FOnDone(Self);
end;

function SQL_AddFileToDB(Path: string; Crypted: Boolean; JPEG: TJpegImage; ImTh, KeyWords, Comment, Password: string;
  OrWidth, OrHeight: Integer; var Date, Time: TDateTime; var IsTime: Boolean; Rating: Integer = 0;
  Rotated: Integer = DB_IMAGE_ROTATE_0; Links: string = ''; Access: Integer = 0; Groups: string = ''): Boolean;
var
  ExifData : TExifData;
  Sql: string;
  FQuery: TDataSet;
  M: TMemoryStream;
  StrThCrc: Cardinal;
begin
  Result := False;
  if DBKernel.ReadBool('Options', 'NoAddSmallImages', True) then
  begin
    if (DBKernel.ReadInteger('Options', 'NoAddSmallImagesWidth', 64) > OrWidth) or (DBKernel.ReadInteger('Options',
        'NoAddSmallImagesHeight', 64) > OrHeight) then
      // small images - no photos
      Exit;
  end;

  FQuery := GetQuery;
  try
    Sql := 'insert into $DB$';
    Sql := Sql +
      ' (Name,FFileName,FileSize,DateToAdd,Thum,StrTh,KeyWords,Owner,Collection,Access,Width,Height,Comment,Attr,Rotated,Rating,IsDate,Include,aTime,IsTime,Links,Groups,FolderCRC,StrThCRC)';
    Sql := Sql +
      ' values (:Name,:FFileName,:FileSize,:DateToAdd,:Thum,:StrTh,:KeyWords,:Owner,:Collection,:Access,:Width,:Height,:Comment,:Attr,:Rotated,:Rating,:IsDate,:Include,:aTime,:IsTime,:Links,:Groups,:FolderCRC,:StrThCRC) ';
    SetSQL(FQuery, Sql);
    SetStrParam(FQuery, 0, ExtractFileName(Path));
    SetStrParam(FQuery, 1, AnsiLowerCase(Path));
    SetIntParam(FQuery, 2, GetFileSize(Path));
    ExifData := TExifData.Create;
    try
      Date := 0;
      try
        if HasJPEGHeader(Path) then
        begin
          ExifData.LoadFromJPEG(Path);
          Date := DateOf(ExifData.DateTime);
          Time := TimeOf(ExifData.DateTime);
          Rotated := ExifOrientationToRatation(Ord(ExifData.Orientation));
        end;
      except
        on e : Exception do
          Eventlog('Reading EXIF failed: ' + e.Message);
      end;
    finally
      F(ExifData);
    end;
    SetBoolParam(FQuery, 16, True);
    if Date = 0 then
    begin
      SetDateParam(FQuery, 'DateToAdd', Now);
      SetDateParam(FQuery, 'aTime', TimeOf(Now));
      SetBoolParam(FQuery, 19, False);
    end else
    begin
      SetDateParam(FQuery, 'DateToAdd', Date);
      SetDateParam(FQuery, 'aTime', TimeOf(Time));
      SetBoolParam(FQuery, 19, True);
    end;
    IsTime := GetBoolParam(FQuery, 19);
    if Crypted then
    begin
      M := TMemoryStream.Create;
      try
        CryptGraphicImage(Jpeg, Password, M);
        LoadParamFromStream(FQuery, 4, M, FtBlob);
      finally
        M.Free;
      end;
    end else
      AssignParam(FQuery, 4, Jpeg);

    SetStrParam(FQuery, 5, ImTh);
    SetStrParam(FQuery, 6, KeyWords);
    SetStrParam(FQuery, 7, GetWindowsUserName);
    SetStrParam(FQuery, 8, 'PhotoAlbum');
    SetIntparam(FQuery, 9, Access);
    SetIntparam(FQuery, 10, OrWidth);
    SetIntparam(FQuery, 11, OrHeight);
    SetStrParam(FQuery, 12, Comment);
    SetIntParam(FQuery, 13, Db_attr_norm);
    SetIntParam(FQuery, 14, Rotated);
    SetIntParam(FQuery, 15, Rating);
    SetBoolParam(FQuery, 17, True);
    SetStrParam(FQuery, 20, Links);
    SetStrParam(FQuery, 21, Groups);

  {$R-}
    SetIntParam(FQuery, 22, GetPathCRC(Path));

    CalcStringCRC32(ImTh, StrThCrc);
    SetIntParam(FQuery, 23, StrThCrc);
    try
      ExecSQL(FQuery);
      if LastInseredID = 0 then
      begin
        SetSQL(FQuery, 'SELECT Max(ID) as MaxID FROM $DB$');
        try
          FQuery.Open;
          if FQuery.RecordCount > 0 then
            LastInseredID := FQuery.FieldByName('MaxID').AsInteger;
        except
          on e : Exception do
            Eventlog('Error getting count of DB items: ' + e.Message);
        end;
      end else
        Inc(LastInseredID);
    except
      on e : Exception do
        Eventlog('Error adding file to DB: ' + e.Message);
    end;
  finally
    FreeDS(FQuery);
  end;
  Result := True;
end;

procedure UpdateDBThread.Execute;
var
  DemoTable: TDataSet;
  FQuery: TDataSet;
  Counter: Integer;
  AutoAnswerSetted: Boolean;

  procedure AddFileToDB;
  begin
    if SQL_AddFileToDB(FInfo[FileNumber].FileName, Res.Crypt, Res.Jpeg, Res.ImTh, FInfo[FileNumber].KeyWords,
      FInfo[FileNumber].Comment, Res.Password, Res.OrWidth, Res.OrHeight, Date, Time, IsTime, FInfo[FileNumber].Rating,
      FInfo[FileNumber].Rotation, FInfo[FileNumber].Links, FInfo[FileNumber].Access, FInfo[FileNumber].Groups) then
      Synchronize(SetImages)
    else
      F(ResArray[FileNumber].Jpeg);

  end;

  function GetRecordsCount: Integer;
  begin
    DemoTable := GetQuery(Dbname);
    try
      SetSQL(DemoTable, 'Select Count(*) as RecordCount from $DB$');
      DemoTable.Open;
      Result := Demotable.FieldByName('RecordCount').AsInteger;
    finally
      FreeDS(Demotable);
    end;
  end;

begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try

    FileNumber := 0;
    AutoAnswerSetted := False;

{$IFDEF LICENCE}
    if DBKernel.GetDemoMode then
    begin
      if GetRecordsCount > LimitDemoRecords then
      begin
        if ShowMessageAboutLimit then
        begin
          Synchronize(Limiterror);
          ShowMessageAboutLimit := False;
        end;
        EventLog(':Limit of records! --> exit updating DB');
        Exit;
      end;
    end;
{$ENDIF}

    ResArray := GetimageIDWEx(FInfo, FUseFileNameScaning);

    for Counter := 1 to FInfo.Count do
    begin

      if Res.Jpeg <> nil then
      begin
        if (Res.Count = 1) and ((Res.Attr[0] = Db_attr_not_exists) or (Res.FileNames[0] <> FInfo[FileNumber].FileName)) and
          (AnsiLowerCase(Res.FileNames[0]) = AnsiLowerCase(FInfo[FileNumber].FileName)) then
        begin
          Synchronize(FileProcessed);
          UpdateMovedDBRecord(Res.Ids[0], FInfo[FileNumber].FileName);
          DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
        end;

        IntResult := Result_invalid;

        if (Res.Count > 1) then
        begin
          if not((FAutoAnswer = Result_skip_all) or (FAutoAnswer = Result_add_all)) then
          begin
            FCurrentImageDBRecord := Res;
            StringParam := Res.ImTh;
            Synchronize(ExecuteReplaceDialog);
            case IntResult of
              Result_Add_All:
                begin
                  FAutoAnswer := Result_Add_all;
                  Synchronize(AddAutoAnswer);
                end;
              Result_skip_all:
                begin
              FAutoAnswer := Result_skip_all;
                  AutoAnswerSetted := True;
                  Synchronize(AddAutoAnswer);
                end;
              Result_replace:
                begin
                  UpdateMovedDBRecord(IntIDResult, FInfo[FileNumber].FileName);
                  DoEventReplace(IntIDResult, FInfo[FileNumber].FileName);
                end;
              Result_Add:
                begin
                  AddFileToDB;
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_dublicate);
                    SetStrParam(FQuery, 1, Res.ImTh);
                    try
                      ExecSQL(FQuery);
                    except
                      on E: Exception do
                        EventLog(':UpdateDBThread::Execute()/Result_Add/ExecSQL throw exception: ' + E.message);
                    end;
                  finally
                    FreeDS(FQuery);
                  end;
                end;
              Result_Delete_File:
                begin
                  DeleteFile(FInfo[FileNumber].FileName);
                end;
              Result_Replace_And_Del_Dublicates:
                begin
                  UpdateMovedDBRecord(IntIDResult, FInfo[FileNumber].FileName);
                  DoEventReplace(IntIDResult, FInfo[FileNumber].FileName);
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'DELETE FROM $DB$ WHERE StrTh=:s and ID<>:ID');
                    SetStrParam(FQuery, 0, Res.ImTh);
                    SetIntParam(FQuery, 1, IntIDResult);
                    try
                      ExecSQL(FQuery);
                    except
                      on E: Exception do
                        EventLog(
                          ':UpdateDBThread::Execute()/Result_Replace_And_Del_Dublicates/ExecSQL throw exception: ' +
                            E.message);
                    end;
                  finally
                    FreeDS(FQuery);
                  end;
                end;
            end;
          end else
          begin
            if FAutoAnswer = Result_replace_All then
            begin
              UpdateMovedDBRecord(IntIDResult, FInfo[FileNumber].FileName);
              DoEventReplace(IntIDResult, FInfo[FileNumber].FileName);
            end;
            if FAutoAnswer = Result_add_All then
            begin
              AddFileToDB;
              FQuery := GetQuery;
              try
                SetSQL(FQuery, 'Update $DB$ Set Attr = :Attr Where StrTh = :s');
                SetIntParam(FQuery, 0, Db_attr_dublicate);
                SetStrParam(FQuery, 1, Res.ImTh);
                try
                  ExecSQL(FQuery);
                except
                  on E: Exception do
                    EventLog(':UpdateDBThread::Execute()/Result_add_All/ExecSQL throw exception: ' + E.message);
                end;
              finally
                FreeDS(FQuery);
              end;
            end;
          end;
        end;

        if (Res.Count = 1) and (AnsiLowerCase(Res.FileNames[0]) <> AnsiLowerCase(FInfo[FileNumber].FileName)) then
        begin

          if not((FAutoAnswer = Result_skip_all) or (FAutoAnswer = Result_replace_All) or (FAutoAnswer = Result_add_all)) then
          begin
            FCurrentImageDBRecord := Res;
            StringParam := Res.ImTh;
            Synchronize(ExecuteReplaceDialog);

            case IntResult of
              Result_skip_all:
                begin
                  FAutoAnswer := Result_skip_all;
                  Synchronize(AddAutoAnswer);
                  AutoAnswerSetted := True;
                end;
              Result_Delete_File:
                begin
                  DeleteFile(FInfo[FileNumber].FileName);
                end;
              Result_replace_all:
                begin
                  FAutoAnswer := Result_replace_All;
                  Synchronize(AddAutoAnswer);
                  AutoAnswerSetted := True;
                  UpdateMovedDBRecord(Res.Ids[0], FInfo[FileNumber].FileName);
                  DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
                end;
              Result_replace:
                begin
                  UpdateMovedDBRecord(Res.Ids[0], FInfo[FileNumber].FileName);
                  if Res.UsedFileNameSearch then
                  begin
                    if Res.ChangedRotate[0] then
                      SetRotate(Res.Ids[0], DB_IMAGE_ROTATE_0);
                    Synchronize(UpdateCurrent);
                  end;
                  DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
                end;
              Result_Add:
                begin
                  AddFileToDB;
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_dublicate);
                    SetStrParam(FQuery, 1, Res.ImTh);
                    try
                      ExecSQL(FQuery);
                    except
                      on E: Exception do
                        Eventlog('Update attribute failed: ' + E.message);
                    end;
                  finally
                    FreeDS(FQuery);
                  end;
                end;
              Result_Add_All:
                begin
                  FAutoAnswer := Result_Add_All;
                  Synchronize(AddAutoAnswer);
                  AutoAnswerSetted := True;
                  AddFileToDB;
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_dublicate);
                    SetStrParam(FQuery, 1, Res.ImTh);
                    try
                      ExecSQL(FQuery);
                    except
                      on E: Exception do
                        EventLog(':UpdateDBThread::Execute()/Result_Add_All2/ExecSQL throw exception: ' + E.message);
                    end;
                  finally
                    FreeDS(FQuery);
                  end;
                end;
            end;
          end;
          if not AutoAnswerSetted then
          begin
            if FAutoAnswer = Result_replace_All then
            begin
              UpdateMovedDBRecord(Res.Ids[0], FInfo[FileNumber].FileName);
              DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
            end;
            if FAutoAnswer = Result_skip_all then
            begin
            end;
            if FAutoAnswer = Result_Add_All then
            begin
              AddFileToDB;
              FQuery := GetQuery;
              try
                SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                SetIntParam(FQuery, 0, Db_attr_dublicate);
                SetStrParam(FQuery, 1, Res.ImTh);
                try
                  ExecSQL(FQuery);
                except
                  on E: Exception do
                    EventLog(':UpdateDBThread::Execute()/Result_replace_All3/ExecSQL throw exception: ' + E.message);
                end;
              finally
                FreeDS(FQuery);
              end;
            end;
          end;
        end;
        AutoAnswerSetted := False;

        if Res.Count = 0 then
          AddFileToDB;
      end else
      begin
        Synchronize(CryptFileWithoutPass);
      end;
      if Res.Jpeg <> nil then
        Res.Jpeg.Free;
      Inc(FileNumber);
    end;

  finally
    CoUninitialize;
    Synchronize(DoOnDone);
  end;
end;

procedure UpdateDBThread.LimitError;
begin
  MessageBoxDB(GetActiveFormHandle, Format(TA('You are working with a non-activated program!$nl$You can only add %d items!', 'Activation'), [LimitDemoRecords]),
    TA('Requires activation of the program', 'Activation'), TD_BUTTON_OK, TD_ICON_INFORMATION);
end;

procedure UpdateDBThread.ExecuteReplaceDialog;
begin
  if DBReplaceForm = nil then
    Application.CreateForm(TDBReplaceForm, DBReplaceForm);
  DBReplaceForm.ExecuteToAdd(FInfo[FileNumber].FileName, 0, StringParam, @IntResult, @IntIDResult, FCurrentImageDBRecord);
end;

procedure UpdateDBThread.AddAutoAnswer;
begin
  FSender.AutoAnswer := FAutoAnswer;
end;

procedure UpdateDBThread.DoEventReplace(ID: Integer; Name: String);
begin
  IDParam := ID;
  NameParam := name;
  Synchronize(DoEventReplaceSynch);
end;

procedure UpdateDBThread.DoEventReplaceSynch;
var
  EventInfo: TEventValues;
begin
  try
    EventInfo.NewName := NameParam;
    EventInfo.ID := IDParam;
    DBKernel.DoIDEvent(FSender.Form, IDParam, [EventID_Param_Name], EventInfo);
  except
    on E: Exception do
      EventLog(':UpdateDBThread::DoEventReplaceSynch() throw exception: ' + E.message);
  end;
end;

procedure UpdateDBThread.UpdateCurrent;
begin
  UpdateImageRecord(FSender.Form, FInfo[FileNumber].FileName, Res.Ids[0]);
end;

procedure UpdateDBThread.CryptFileWithoutPass;
var
  EventInfo: TEventValues;
begin
  EventInfo.name := FInfo[FileNumber].FileName;
  DBKernel.DoIDEvent(FSender.Form, -1, [EventID_Param_Add_Crypt_WithoutPass], EventInfo);
  CryptFileWithoutPassChecked := True;
end;

function UpdateDBThread.Res: TImageDBRecordA;
begin
  Result := ResArray[FileNumber];
end;

procedure UpdateDBThread.SetImages;
var
  EventInfo: TEventValues;
begin
  EventInfo.name := AnsiLowerCase(FInfo[FileNumber].FileName);
  EventInfo.ID := LastInseredID;
  EventInfo.Rotate := FInfo[FileNumber].Rotation;
  EventInfo.Rating := FInfo[FileNumber].Rating;
  EventInfo.Comment := FInfo[FileNumber].Comment;
  EventInfo.KeyWords := FInfo[FileNumber].KeyWords;
  EventInfo.Access := FInfo[FileNumber].Access;
  EventInfo.Attr := FInfo[FileNumber].Attr;
  EventInfo.Date := Date;
  EventInfo.IsDate := True;
  EventInfo.IsTime := IsTime;
  EventInfo.Time := TimeOf(Time);
  EventInfo.Image := nil;
  EventInfo.Groups := FInfo[FileNumber].Groups;
  EventInfo.JPEGImage := Res.Jpeg;
  EventInfo.Crypt := Res.Crypt;
  EventInfo.Include := True;
  DBKernel.DoIDEvent(FSender.Form, LastInseredID, [SetNewIDFileData], EventInfo);
  if Res.Jpeg <> nil then
    Res.Jpeg.Free;
  ResArray[FileNumber].Jpeg := nil;
end;

procedure UpdateDBThread.FileProcessed;
var
  EventInfo: TEventValues;
begin
  EventInfo.name := AnsiLowerCase(FInfo[FileNumber].FileName);
  EventInfo.ID := LastInseredID;
  EventInfo.Rotate := FInfo[FileNumber].Rotation;
  EventInfo.Rating := FInfo[FileNumber].Rating;
  EventInfo.Comment := FInfo[FileNumber].Comment;
  EventInfo.KeyWords := FInfo[FileNumber].KeyWords;
  EventInfo.Access := FInfo[FileNumber].Access;
  EventInfo.Attr := FInfo[FileNumber].Attr;
  EventInfo.Date := Date;
  EventInfo.IsDate := True;
  EventInfo.IsTime := IsTime;
  EventInfo.Time := TimeOf(Time);
  EventInfo.Image := nil;
  EventInfo.Groups := FInfo[FileNumber].Groups;
  EventInfo.JPEGImage := Res.Jpeg;
  EventInfo.Crypt := Res.Crypt;
  EventInfo.Include := True;
  DBKernel.DoIDEvent(FSender.Form, LastInseredID, [EventID_FileProcessed], EventInfo);
end;

{ DirectorySizeThread }

function DirectorySizeThread.GetDirectory(DirectoryName: string; var Files : TStrings; Terminating : PBoolean):integer;
var
  Found: Integer;
  SearchRec: TSearchRec;
  FileName: string;
begin
  Result := 0;
  if Terminating^ then
    Exit;
  if not DirectoryExists(DirectoryName) then
    Exit;
  if DirectoryName[Length(DirectoryName)] <> '\' then
    DirectoryName := DirectoryName + '\';
  Found := FindFirst(DirectoryName + '*.*', FaAnyFile, SearchRec);
  while Found = 0 do
  begin
    if Terminating^ then
    begin
      FindClose(SearchRec);
      Exit;
    end;
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      if FileExists(DirectoryName + SearchRec.Name) and ExtInMask(SupportedExt, GetExt(DirectoryName + SearchRec.Name)) then
      begin
        Result := Result + SearchRec.Size;
        FileName := DirectoryName + SearchRec.Name;
        StrParam := FileName;
        Synchronize(DoFileProcessed);
        FileName := StrParam;
        Files.Add(FileName);
        IntParam := SearchRec.Size;
        Synchronize(DoOnFileFounded);
      end
      else if DirectoryExists(DirectoryName + SearchRec.Name) then
        Result := Result + GetDirectory(DirectoryName + SearchRec.Name, Files, Terminating);
    end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

constructor DirectorySizeThread.Create(Directory: string; OnDone: TNotifyEvent; Terminating: PBoolean; OnFileFounded : TFileFoundedEvent;
  ProcessFileEvent : TFileProcessProcedureOfObject = nil);
begin
  inherited Create(False);
  FDirectory := Directory;
  FTerminating := Terminating;
  FOnFileFounded := OnFileFounded;
  FProcessFileEvent := ProcessFileEvent;
  FOnDone := OnDone;
end;

procedure DirectorySizeThread.DoOnDone;
begin
  if Assigned(FOnDone) then
    FOnDone(FObject);
end;

procedure DirectorySizeThread.Execute;
var
  Size: Integer;
  Files: TStrings;
begin
  FreeOnTerminate := True;
  Files := TStringList.Create;
  Size := GetDirectory(FDirectory, Files, FTerminating);
  if not FTerminating^ then
  begin
    FObject := TValueObject.Create;
    try
      FObject.FTIntValue := Size;
      FObject.FSTStrValue := Files;
      Synchronize(DoOnDone);
    finally
      F(FObject);
    end;
  end;
end;

procedure DirectorySizeThread.DoFileProcessed;
begin
  if Assigned(FProcessFileEvent) then
    FProcessFileEvent(StrParam);
end;

procedure DirectorySizeThread.DoOnFileFounded;
begin
  if Assigned(FOnFileFounded) then
    FOnFileFounded(nil, StrParam, IntParam);
end;

{ TValueObject }

constructor TValueObject.Create;
begin
  FSTStrValue := TStringList.Create;
end;

destructor TValueObject.Destroy;
begin
  FSTStrValue.Free;
end;

procedure TValueObject.SetTBoolValue(const Value: Boolean);
begin
  FTBoolValue := Value;
end;

procedure TValueObject.SetTIntValue(const Value: Integer);
begin
  FTIntValue := Value;
end;

procedure TValueObject.SetTStrValue(const Value: TStrings);
begin
  FSTStrValue.Assign(Value);
end;

end.
