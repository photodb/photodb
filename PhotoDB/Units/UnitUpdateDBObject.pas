unit UnitUpdateDBObject;

interface

uses Windows, Controls, Classes,  Forms, SysUtils, uScript, UnitScripts,
     Dolphin_DB, UnitDBDeclare, UnitDBCommon, UnitDBCommonGraphics, uMemory,
     uFileUtils, uDBPopupMenuInfo, uConstants;

type
   TOwnerFormSetText = procedure(Text : string) of object;
   TOwnerFormSetMaxValue = procedure(Value : integer) of object;
   TOwnerFormSetAutoAnswer = procedure(Value : integer) of object;
   TOwnerFormSetTimeText = procedure(Text : string) of object;
   TOwnerFormSetPosition = procedure(Value : integer) of object;
   TOwnerFormSetFileName = procedure(FileName : string) of object;
   TOwnerFormAddFileSizes = procedure(Value : int64) of object;

type
  TUpdaterDB = class(TObject)
  private
    { Private declarations }
    FProcessScript: TScript;
    ScriptProcessString: string;
    FPosition: Integer;
    FShowWindow: Boolean;
    FForm: TForm;
    FmaxSize: Integer;
    FTerminate: Boolean;
    FActive: Boolean;
    FAuto: Boolean;
    FAutoAnswer: Integer;
    Fpause: Boolean;
    BeginTime: TDateTime;
    FFilesInfo: TDBPopupMenuInfo;
    FUseFileNameScaning: Boolean;
    procedure SetAuto(const Value: boolean);
    procedure SetAutoAnswer(Value: Integer);
    procedure SetUseFileNameScaning(const Value: boolean);
    procedure ProcessFile(var FileName : string);
  public
    OwnerFormSetText: TOwnerFormSetText;
    OwnerFormSetMaxValue: TOwnerFormSetMaxValue;
    OwnerFormSetAutoAnswer: TOwnerFormSetAutoAnswer;
    OwnerFormSetTimeText: TOwnerFormSetTimeText;
    OwnerFormSetPosition: TOwnerFormSetPosition;
    OwnerFormSetFileName: TOwnerFormSetFileName;
    OwnerFormAddFileSizes: TOwnerFormAddFileSizes;
    ShowForm: TNotifyEvent;
    SetDone: TNotifyEvent;
    SetBeginUpdation: TNotifyEvent;
    DoShowImage: TNotifyEvent;
    OnDirectoryAdded: TNotifyEvent;
    OnExecuting: TNotifyEvent;
    NoLimit: Boolean;
    constructor Create(AutoCreateForm: Boolean = True);
    destructor Destroy; override;
    function AddFile(FileName: string; Silent: Boolean = False): Boolean;
    function AddDirectory(Directory: string; OnFileFounded: TFileFoundedEvent): Boolean;
    procedure EndDirectorySize(Sender: TObject);
    procedure OnAddFileDone(Sender: TObject);
    procedure Execute;
    procedure ShowWindowNow;
    procedure DoTerminate;
    procedure DoPause;
    procedure DoUnPause;
    procedure SaveWork;
    procedure LoadWork;
    function GetFilesCount: Integer;
    function FileExistsInFileList(FileName: string): Boolean;
    function GetCount: Integer;
    property Active: Boolean read FActive;
    property Auto: Boolean read FAuto write SetAuto default True;
    property UseFileNameScaning: Boolean read FUseFileNameScaning write SetUseFileNameScaning default False;
    property AutoAnswer: Integer read FAutoAnswer write SetAutoAnswer;
    property Pause: Boolean read FPause;
    property Form: TForm read FForm;
  end;

implementation

uses Language, UnitUpdateDBThread, DBScriptFunctions,
  FormManegerUnit, UnitUpdateDB, ProgressActionUnit;

{ TUpdaterDB }

function TUpdaterDB.AddDirectory(Directory: string; OnFileFounded : TFileFoundedEvent): Boolean;
var
  Dir: string;
begin
  Dir := Directory;

  if FFilesInfo.Count = 0 then
    if Assigned(OwnerFormSetText) then
      OwnerFormSetText(TEXT_MES_ADDING_FOLDER);

  if FForm <> nil then
    if (FForm is TUpdateDBForm) then
    begin
      OnFileFounded := (FForm as TUpdateDBForm).OnDirectorySearch;
      (FForm as TUpdateDBForm).FullSize := 0;
    end;
  DirectorySizeThread.Create(Dir, EndDirectorySize, @FTerminate, OnFileFounded, ProcessFile);
  Result := True;
end;

function TUpdaterDB.FileExistsInFileList(FileName: String): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FFilesInfo.Count - 1 do
    if AnsiLowerCase(FileName) = AnsiLowerCase(FFilesInfo[I].FileName) then
    begin
      Result := True;
      Exit;
    end;
end;

function TUpdaterDB.AddFile(FileName : string; Silent : Boolean = false): Boolean;
var
  FileSize: Int64;
begin
  ProcessFile(FileName);

  if Silent or (FileExists(FileName) and ExtInMask(SupportedExt, GetExt(FileName))) then
    if not(FileExistsInFileList(FileName)) then
    begin
      FileSize := GetFileSizeByName(FileName);
      Inc(FmaxSize, FileSize);
      FFilesInfo.Add(FileName);
      if Assigned(OwnerFormSetMaxValue) then
        OwnerFormSetMaxValue(FFilesInfo.Count);

      if Assigned(OwnerFormAddFileSizes) then
        OwnerFormAddFileSizes(FileSize);
      if Auto then
      begin
        if not Silent then
          Execute;
        if Assigned(ShowForm) then
          ShowForm(Self);
      end;
    end;
  Result := True;
end;

constructor TUpdaterDB.Create(AutoCreateForm : boolean = true);
var
  TermInfo: TTemtinatedAction;
begin
  FFilesInfo := TDBPopupMenuInfo.Create;
  ScriptProcessString := Include('Scripts\Adding_AddFile.dbini');
  FProcessScript := TScript.Create('');
  FProcessScript.Description := 'Add File script';

  NoLimit := False;
  OwnerFormSetText := nil;
  FUseFileNameScaning := False;
  if FormManager <> nil then
  begin
    TermInfo.TerminatedPointer := @Self.FTerminate;
    TermInfo.TerminatedVerify := @Self.Active;
    TermInfo.Options := TA_INFORM_AND_NT;
    TermInfo.Discription := TEXT_MES_UPDATING_DESCTIPTION;
    TermInfo.Owner := Self;
    FormManager.RegisterActionCanTerminating(TermInfo);
  end;
  FFilesInfo.Clear;
  FPosition := 0;
  Auto := True;
  FTErminate := False;
  FShowWindow := False;
  FActive := False;
  FmaxSize := 0;
  FPause := False;
  FAutoAnswer := Result_invalid;
  if AutoCreateForm then
  begin
    Application.CreateForm(TUpdateDBForm, FForm);
    (FForm as TUpdateDBForm).SetAddObject(Self);
    // SETTING EVENTS
    OwnerFormSetAutoAnswer := (FForm as TUpdateDBForm).SetAutoAnswer;
    OwnerFormSetText := (FForm as TUpdateDBForm).SetText;
    OwnerFormSetMaxValue := (FForm as TUpdateDBForm).SetMaxValue;
    OwnerFormSetPosition := (FForm as TUpdateDBForm).SetPosition;
    ShowForm := (FForm as TUpdateDBForm).ShowForm;
    SetDone := (FForm as TUpdateDBForm).SetDone;
    OwnerFormSetTimeText := (FForm as TUpdateDBForm).SetTimeText;
    OwnerFormSetFileName := (FForm as TUpdateDBForm).SetFileName;
    SetBeginUpdation := (FForm as TUpdateDBForm).SetBeginUpdation;
    OwnerFormAddFileSizes := (FForm as TUpdateDBForm).AddFileSizes;
    SetBeginUpdation := (FForm as TUpdateDBForm).OnBeginUpdation;
    LoadWork;
  end;
  BeginTime := -1;
end;

destructor TUpdaterDB.Destroy;
var
  TermInfo: TTemtinatedAction;
begin
  if TFormManager <> nil then
  begin
    TermInfo.TerminatedPointer := @Self.FTerminate;
    TermInfo.TerminatedVerify := @Self.Active;
    TermInfo.Options := TA_INFORM_AND_NT;
    TermInfo.Owner := Self;
    FormManager.UnRegisterActionCanTerminating(TermInfo);
  end;

  R(FForm);
  F(FProcessScript);
  F(FFilesInfo);
end;

procedure TUpdaterDB.DoPause;
begin
  FPause := True;
end;

procedure TUpdaterDB.DoTerminate;
begin
  FTerminate := True;
  FFilesInfo.Clear;
  FPosition := 0;
  FActive := False;
  BeginTime := -1;
  if Assigned(SetDone) then
    SetDone(Self);
end;

procedure TUpdaterDB.DoUnPause;
begin
  FPause := False;
  Execute;
end;

procedure TUpdaterDB.EndDirectorySize(Sender: TObject);
var
  I: Integer;
begin
  if FFilesInfo.Count = 0 then
    if Assigned(OwnerFormSetFileName) then
      OwnerFormSetFileName(TEXT_MES_NO_ANY_FILEA);

  Inc(FmaxSize, (Sender as TValueObject).TIntValue);

  if Assigned(OwnerFormAddFileSizes) then
    OwnerFormAddFileSizes((Sender as TValueObject).TIntValue);

  for I := 1 to (Sender as TValueObject).TStrValue.Count do
    FFilesInfo.Add((Sender as TValueObject).TStrValue[I - 1]);

  if Assigned(OwnerFormSetMaxValue) then
    OwnerFormSetMaxValue(FFilesInfo.Count);

  if Auto then
  begin
    ShowMessageAboutLimit := True;
    Execute;
    if Assigned(ShowForm) then
      ShowForm(Self);
  end;

  if Assigned(OnDirectoryAdded) then
    OnDirectoryAdded(Self);
end;

procedure TUpdaterDB.Execute;
var
  Info: TDBPopupMenuInfo;
  I: Integer;
begin
  if BeginTime < 0 then
    BeginTime := Now;
  if FTerminate then
  begin
    FTerminate := False;
    FActive := False;
    BeginTime := -1;
    Exit;
  end;
  if FActive then
    Exit;
  FActive := True;
  if FPosition = 0 then
  begin
    if Assigned(SetBeginUpdation) then
      SetBeginUpdation(Self);
  end;
  if FPosition >= FFilesInfo.Count then
  begin
    FFilesInfo.Clear;
    FPosition := 0;
    FActive := False;
    BeginTime := -1;
    if Assigned(SetDone) then
      SetDone(Self);
    Exit;
  end;
  if FFilesInfo.Count = 0 then
  begin
    FActive := False;
    if Assigned(SetDone) then
      SetDone(Self);
    Exit;
  end;
  if (FPosition <> 0) then
  begin
    if Assigned(DoShowImage) then
      DoShowImage(Self);
    if (FFilesInfo.Count - FPosition > 1) then
    begin
      if Assigned(OwnerFormSetTimeText) then
        OwnerFormSetTimeText(TimeTostr(((Now - BeginTime) / FPosition) * (FFilesInfo.Count - FPosition)));
    end else
    begin
      if Assigned(OwnerFormSetTimeText) then
        OwnerFormSetTimeText(TEXT_MES_LAST_FILE);
    end;
  end;
  if Assigned(OwnerFormSetPosition) then
    OwnerFormSetPosition(FPosition + 1);

  if Assigned(OwnerFormSetFileName) then
    OwnerFormSetFileName(FFilesInfo[FPosition].FileName);

  if FPause then
  begin
    FActive := False;
    Exit;
  end;

  Info := TDBPopupMenuInfo.Create;

  for I := 0 to 4 do
  begin
    Info.Add(FFilesInfo[FPosition].Copy);
    Inc(FPosition);
    if (FFilesInfo.Count - FPosition = 0) then
      Break;
 end;
 UpdateDBThread.Create(Self,Info,OnAddFileDone,FAutoAnswer,UseFileNameScaning,@FTerminate,@FPause,NoLimit);

end;

procedure TUpdaterDB.OnAddFileDone(Sender: TObject);
begin
  FActive := False;
  Execute;
end;

procedure TUpdaterDB.SetAuto(const Value: Boolean);
begin
  FAuto := Value;
end;

procedure TUpdaterDB.SetAutoAnswer(Value: Integer);
begin
  FAutoAnswer := Value;
  if Assigned(OwnerFormSetAutoAnswer) then
    OwnerFormSetAutoAnswer(Value);
end;

procedure TUpdaterDB.SetUseFileNameScaning(const Value: boolean);
begin
  FUseFileNameScaning := Value;
end;

procedure TUpdaterDB.ShowWindowNow;
begin
  FForm.Show;
end;

function TUpdaterDB.GetFilesCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

procedure TUpdaterDB.ProcessFile(var FileName: string);
var
  C: Integer;
begin
  if not GetParamStrDBBool('/Add') then
  begin
    SetNamedValueStr(FProcessScript, '$File', FileName);
    ExecuteScript(nil, FProcessScript, ScriptProcessString, C, nil);
    FileName := GetNamedValueString(FProcessScript, '$File');
  end;
end;

procedure TUpdaterDB.LoadWork;
var
  I, C: Integer;
  ProgressWindow: TProgressActionForm;
begin
  ProgressWindow := GetProgressWindow;
  C := DBKernel.ReadInteger('Updater', 'Counter', 0);
  ProgressWindow.OneOperation := True;
  ProgressWindow.MaxPosCurrentOperation := C;
  ProgressWindow.XPosition := 0;
  ProgressWindow.SetAlternativeText(TEXT_MES_WAIT_LOADING_WORK);
  if C > 10 then
    ProgressWindow.Show;

  for I := 0 to C - 1 do
  begin
    if I mod 8 = 0 then
    begin
      ProgressWindow.XPosition := I;
      Application.ProcessMessages;
    end;
    AddFile(DBKernel.ReadString('Updater', 'File' + IntToStr(I)), I <> C - 1);
  end;

  ProgressWindow.Release;
end;

procedure TUpdaterDB.SaveWork;
var
  I: Integer;
begin
  DBKernel.WriteInteger('Updater', 'Counter', FFilesInfo.Count);
  for I := 0 to FFilesInfo.Count - 1 do
    DBKernel.WriteString('Updater', 'File' + IntToStr(I), FFilesInfo[I].FileName);
end;

function TUpdaterDB.GetCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

end.
