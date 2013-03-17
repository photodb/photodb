unit UnitUpdateDBThread;

interface

uses
  Generics.Collections,
  ReplaceForm,
  Windows,
  Classes,
  Forms,
  SysUtils,
  DB,
  DateUtils,
  ActiveX,
  Jpeg,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.CRC32,

  GraphicCrypt,
  CommonDBSupport,
  UnitDBKernel,
  UnitDBDeclare,
  UnitUpdateDBObject,
  UnitGroupsWork,

  uLogger,
  uMemory,
  uDBPopupMenuInfo,
  uConstants,
  uShellIntegration,
  uDBTypes,
  uRuntime,
  uDBUtils,
  uTranslate,
  uSettings,
  uMemoryEx,
  uAssociations,
  uDBThread,
  uExifUtils,
  uGroupTypes,
  uDBUpdateUtils;

type
  UpdateDBThread = class(TDBThread)
  private
    { Private declarations }
    FOnDone: TNotifyEvent;
    FTerminating: PBoolean;
    FPause: PBoolean;
    FStringParam: string;
    IntResult, IntIDResult: Integer;
    FCurrentImageDBRecord: TImageDBRecordA;
    FSender: TUpdaterDB;
    ResArray: TImageDBRecordAArray;
    IDParam: Integer;
    NameParam: string;
    FInfo: TDBPopupMenuInfo;
    FUseFileNameScaning: Boolean;
    FileNumber: Integer;
    FNoLimit: Boolean;
  protected
    procedure Execute; override;
  public
    Procedure DoOnDone;
    procedure ExecuteReplaceDialog;
    procedure AddAutoAnswer;
    procedure DoEventReplace(ID: Integer; Name: String);
    procedure DoEventReplaceSynch;
    procedure DoEventCancel(Name: String);
    procedure DoEventCancelSynch;
    procedure UpdateCurrent;
    procedure CryptFileWithoutPass;
    function Res: TImageDBRecordA;
    procedure FileProcessed;
    constructor Create(Sender: TUpdaterDB; Info: TDBPopupMenuInfo;
      OnDone: TNotifyEvent; AutoAnswer: Integer; UseFileNameScaning: Boolean;
      Terminating, Pause: PBoolean; NoLimit: Boolean = False);
    destructor Destroy; override;
  end;

type
  DirectorySizeThread = class(TDBThread)
  private
    { Private declarations }
    FDirectory, StrParam: string;
    FItems: TDBPopupMenuInfo;
    FOnDone: TNotifyEvent;
    FTerminating: PBoolean;
    IntParam: Int64;
    FOnFileFounded: TFileFoundedEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(Directory: string; OnDone: TNotifyEvent; Terminating: PBoolean; OnFileFounded: TFileFoundedEvent);
    procedure DoOnDone;
    procedure DoOnFileFounded;
    function GetDirectory(DirectoryName: string; Files: TDBPopupMenuInfo; Terminating: PBoolean): Int64;
  end;

var
  ShowMessageAboutLimit: Boolean = True;
  CryptFileWithoutPassChecked: Boolean = False;
  FAutoAnswer: Integer = -1;

implementation

{ UpdateDBThread }

constructor UpdateDBThread.Create(Sender: TUpdaterDB;
  Info: TDBPopupMenuInfo; OnDone: TNotifyEvent;
  AutoAnswer: Integer; UseFileNameScaning : Boolean; Terminating,
  Pause: PBoolean; NoLimit: Boolean = false);
begin
  //owner is dynamic
  inherited Create(nil, False);
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

procedure UpdateDBThread.Execute;
var
  FQuery: TDataSet;
  Counter: Integer;
  AutoAnswerSetted: Boolean;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    FileNumber := 0;
    AutoAnswerSetted := False;

    ResArray := GetImageIDWEx(FInfo, FUseFileNameScaning);

    for Counter := 1 to FInfo.Count do
    begin
      FInfo[FileNumber].FileName := AnsiLowerCase(FInfo[FileNumber].FileName);
      if Res.Jpeg <> nil then
      begin
        if (Res.Count = 1) and ((Res.Attr[0] = Db_attr_not_exists) or (Res.FileNames[0] <> FInfo[FileNumber].FileName)) and
          (AnsiLowerCase(Res.FileNames[0]) = AnsiLowerCase(FInfo[FileNumber].FileName)) then
        begin
          Res.Jpeg.DIBNeeded;
          SynchronizeEx(FileProcessed);
          UpdateMovedDBRecord(Res.Ids[0], FInfo[FileNumber].FileName);
          DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
        end;

        IntResult := Result_invalid;

        if (Res.Count > 1) then
        begin
          if not((FAutoAnswer = Result_skip_all) or (FAutoAnswer = Result_add_all)) then
          begin
            FCurrentImageDBRecord := Res;
            FStringParam := Res.ImTh;
            SynchronizeEx(ExecuteReplaceDialog);
            case IntResult of
              Result_Add_All:
                begin
                  FAutoAnswer := Result_Add_all;
                  SynchronizeEx(AddAutoAnswer);
                  DoEventCancel(FInfo[FileNumber].FileName);
                end;
              Result_skip_all:
                begin
              FAutoAnswer := Result_skip_all;
                  AutoAnswerSetted := True;
                  SynchronizeEx(AddAutoAnswer);
                  DoEventCancel(FInfo[FileNumber].FileName);
                end;
              Result_replace:
                begin
                  UpdateMovedDBRecord(IntIDResult, FInfo[FileNumber].FileName);
                  DoEventReplace(IntIDResult, FInfo[FileNumber].FileName);
                end;
              Result_Add:
                begin
                  TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_duplicate);
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
                  DoEventCancel(FInfo[FileNumber].FileName);
                end;
              Result_Replace_And_Del_Duplicates:
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
              TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
              FQuery := GetQuery;
              try
                SetSQL(FQuery, 'Update $DB$ Set Attr = :Attr Where StrTh = :s');
                SetIntParam(FQuery, 0, Db_attr_duplicate);
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
            FStringParam := Res.ImTh;
            SynchronizeEx(ExecuteReplaceDialog);

            case IntResult of
              Result_skip_all:
                begin
                  FAutoAnswer := Result_skip_all;
                  SynchronizeEx(AddAutoAnswer);
                  AutoAnswerSetted := True;
                  DoEventCancel(FInfo[FileNumber].FileName);
                end;
              Result_Delete_File:
                begin
                  DeleteFile(FInfo[FileNumber].FileName);
                  DoEventCancel(FInfo[FileNumber].FileName);
                end;
              Result_replace_all:
                begin
                  FAutoAnswer := Result_replace_All;
                  SynchronizeEx(AddAutoAnswer);
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
                    SynchronizeEx(UpdateCurrent);
                  end;
                  DoEventReplace(Res.Ids[0], FInfo[FileNumber].FileName);
                end;
              Result_Add:
                begin
                  TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_duplicate);
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
                  SynchronizeEx(AddAutoAnswer);
                  AutoAnswerSetted := True;
                  TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
                  FQuery := GetQuery;
                  try
                    SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                    SetIntParam(FQuery, 0, Db_attr_duplicate);
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
            end else
            if FAutoAnswer = Result_replace then
            begin
            end else
            if FAutoAnswer = Result_skip_all then
            begin
            end else
            if FAutoAnswer = Result_Add_All then
            begin
              TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
              FQuery := GetQuery;
              try
                SetSQL(FQuery, 'Update $DB$ Set Attr=:Attr Where StrTh=:s');
                SetIntParam(FQuery, 0, Db_attr_duplicate);
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
            end else
              DoEventCancel(FInfo[FileNumber].FileName);
          end;
        end else if Res.Count <> 0 then
          DoEventCancel(FInfo[FileNumber].FileName);
        AutoAnswerSetted := False;

        if Res.Count = 0 then
          TDatabaseUpdateManager.AddFile(FInfo[FileNumber], Res);
      end else
      begin
        SynchronizeEx(CryptFileWithoutPass);
      end;
      if Res.Jpeg <> nil then
        Res.Jpeg.Free;
      Inc(FileNumber);
    end;

  finally
    CoUninitialize;
    SynchronizeEx(DoOnDone);
  end;
end;

procedure UpdateDBThread.ExecuteReplaceDialog;
var
  DBReplaceForm: TDBReplaceForm;
begin
  Application.CreateForm(TDBReplaceForm, DBReplaceForm);
  try
    DBReplaceForm.ExecuteToAdd(FInfo[FileNumber].FileName, FStringParam, IntResult, IntIDResult, FCurrentImageDBRecord);
  finally
    R(DBReplaceForm);
  end;
end;

procedure UpdateDBThread.AddAutoAnswer;
begin
  FSender.AutoAnswer := FAutoAnswer;
end;

destructor UpdateDBThread.Destroy;
begin
  F(FInfo);
  inherited;
end;

procedure UpdateDBThread.DoEventCancel(Name: String);
begin
  NameParam := Name;
  IDParam := 0;
  SynchronizeEx(DoEventCancelSynch);
end;

procedure UpdateDBThread.DoEventCancelSynch;
var
  EventInfo: TEventValues;
begin
  try
    EventInfo.FileName := NameParam;
    EventInfo.ID := IDParam;
    DBKernel.DoIDEvent(FSender.Form, IDParam, [EventID_CancelAddingImage], EventInfo);
  except
    on E: Exception do
      EventLog(':UpdateDBThread::DoEventReplaceSynch() throw exception: ' + E.message);
  end;
end;

procedure UpdateDBThread.DoEventReplace(ID: Integer; Name: String);
begin
  IDParam := ID;
  NameParam := Name;
  SynchronizeEx(DoEventReplaceSynch);
end;

procedure UpdateDBThread.DoEventReplaceSynch;
var
  EventInfo: TEventValues;
begin
  try
    EventInfo.FileName := NameParam;
    EventInfo.NewName := NameParam;
    EventInfo.ID := IDParam;
    DBKernel.DoIDEvent(FSender.Form, IDParam, [EventID_Param_Name, EventID_CancelAddingImage], EventInfo);
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
  EventInfo.FileName := FInfo[FileNumber].FileName;
  DBKernel.DoIDEvent(FSender.Form, -1, [EventID_Param_Add_Crypt_WithoutPass], EventInfo);
  CryptFileWithoutPassChecked := True;
end;

function UpdateDBThread.Res: TImageDBRecordA;
begin
  Result := ResArray[FileNumber];
end;

procedure UpdateDBThread.FileProcessed;
var
  EventInfo: TEventValues;
  Info: TDBPopupMenuInfoRecord;
begin
  Info := FInfo[FileNumber];
  EventInfo.ReadFromInfo(Info);
  DBKernel.DoIDEvent(FSender.Form, LastInseredID, [EventID_FileProcessed], EventInfo);
end;

{ DirectorySizeThread }

function DirectorySizeThread.GetDirectory(DirectoryName: string; Files: TDBPopupMenuInfo; Terminating: PBoolean): Int64;
var
  Found: Integer;
  SearchRec: TSearchRec;
  FileName: string;
  Item: TDBPopupMenuInfoRecord;
begin
  Result := 0;
  if Terminating^ then
    Exit;
  if not DirectoryExistsSafe(DirectoryName) then
    Exit;

  DirectoryName := IncludeTrailingPathDelimiter(DirectoryName);

  Found := FindFirst(DirectoryName + '*.*', faAnyFile, SearchRec);
  while Found = 0 do
  begin
    if Terminating^ or DBTerminating then
    begin
      FindClose(SearchRec);
      Exit;
    end;
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      if FileExistsSafe(DirectoryName + SearchRec.Name) and IsGraphicFile(DirectoryName + SearchRec.Name) then
      begin
        Result := Result + SearchRec.Size;
        FileName := DirectoryName + SearchRec.Name;

        Item := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
        Item.Include := True;
        Item.FileSize := SearchRec.Size;

        Files.Add(Item);

        IntParam := SearchRec.Size;
        SynchronizeEx(DoOnFileFounded);
      end
      else if DirectoryExists(DirectoryName + SearchRec.Name) then
        Result := Result + GetDirectory(DirectoryName + SearchRec.Name, Files, Terminating);
    end;
    Found := SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

constructor DirectorySizeThread.Create(Directory: string; OnDone: TNotifyEvent; Terminating: PBoolean; OnFileFounded: TFileFoundedEvent);
begin
  inherited Create(nil, False);
  FDirectory := Directory;
  FTerminating := Terminating;
  FOnFileFounded := OnFileFounded;
  FOnDone := OnDone;
end;

procedure DirectorySizeThread.DoOnDone;
begin
  if Assigned(FOnDone) then
    FOnDone(FItems);
end;

procedure DirectorySizeThread.Execute;
var
  I: Integer;
  List: TStrings;
begin
  inherited;
  FreeOnTerminate := True;
  FItems := TDBPopupMenuInfo.Create;
  try
    List := TStringList.Create;
    try
      List.Text := FDirectory;
      for I := 0 to List.Count - 1 do
      begin
        if List[I] <> '' then
          GetDirectory(List[I], FItems, FTerminating);
      end;
    finally
      F(List);
    end;
    if not FTerminating^ then
      SynchronizeEx(DoOnDone);
  finally
    F(FItems);
  end;
end;

procedure DirectorySizeThread.DoOnFileFounded;
begin
  if Assigned(FOnFileFounded) then
    FOnFileFounded(nil, StrParam, IntParam);
end;

end.
