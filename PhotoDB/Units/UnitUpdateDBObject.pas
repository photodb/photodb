unit UnitUpdateDBObject;

interface

uses
  Windows, Controls, Classes,  Forms, SysUtils, uScript, UnitScripts,
  UnitDBDeclare, uMemory, UnitDBKernel, uRuntime,
  uFileUtils, uDBPopupMenuInfo, uConstants, uAppUtils, uGOM, uMemoryEx,
  uTranslate, Dolphin_DB, uDBForm, uSettings, uAssociations, win32crc;

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
    FForm: TDBForm;
    FmaxSize: Integer;
    FTerminate: Boolean;
    FActive: Boolean;
    FAuto: Boolean;
    FAutoAnswer: Integer;
    FPause: Boolean;
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
    constructor Create(OwnerForm: TDBForm = nil);
    destructor Destroy; override;
    function AddFile(FileName: string; Silent: Boolean = False): Boolean;
    function AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean): Boolean;
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
    property Form: TDBForm read FForm;
  end;

implementation

uses
  UnitUpdateDBThread, DBScriptFunctions, CommonDBSupport,
  FormManegerUnit, UnitUpdateDB, ProgressActionUnit;

{ TUpdaterDB }

function TUpdaterDB.AddDirectory(Directory: string; OnFileFounded : TFileFoundedEvent): Boolean;
var
  Dir: string;
begin
  Dir := Directory;

  if FFilesInfo.Count = 0 then
    if Assigned(OwnerFormSetText) then
      OwnerFormSetText(TA('Getting list of files from directory', 'Updater'));

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

function TUpdaterDB.AddFile(FileName : string; Silent : Boolean = False): Boolean;
var
  Info: TDBPopupMenuInfoRecord;
begin
  Info := TDBPopupMenuInfoRecord.Create;
  try
    Info.FileName := FileName;
    Info.Include := True;
    Result := AddFileEx(Info, Silent, False);
  finally
    F(Info);
  end;
end;

function TUpdaterDB.AddFileEx(FileInfo: TDBPopupMenuInfoRecord; Silent, Critical: Boolean): Boolean;
var
  FileSize: Int64;
  FileName: string;
begin
  FileName := FileInfo.FileName;
  ProcessFile(FileName);
  FileInfo.FileName := FileName;

  if Silent or (FileExistsSafe(FileName) and IsGraphicFile(FileName)) then
    if not(FileExistsInFileList(FileName)) then
    begin
      FileSize := GetFileSizeByName(FileName);
      Inc(FmaxSize, FileSize);
      if not Critical then
        FFilesInfo.Add(FileInfo.Copy)
      else
        FFilesInfo.Insert(0, FileInfo.Copy);

      if Assigned(OwnerFormSetMaxValue) then
        OwnerFormSetMaxValue(FFilesInfo.Count);

      if Assigned(OwnerFormAddFileSizes) then
        OwnerFormAddFileSizes(FileSize);

      if Auto then
      begin
        Execute;
        if not Silent then
          if Assigned(ShowForm) then
            ShowForm(Self);
      end;
    end;
  Result := True;
end;

constructor TUpdaterDB.Create(OwnerForm: TDBForm = nil);
begin
  FForm := OwnerForm;
  FFilesInfo := TDBPopupMenuInfo.Create;
  ScriptProcessString := Include('Scripts\Adding_AddFile.dbini');
  FProcessScript := TScript.Create(FForm, '');
  FProcessScript.Description := 'Add File script';

  NoLimit := False;
  OwnerFormSetText := nil;
  FUseFileNameScaning := False;

  FFilesInfo.Clear;
  FPosition := 0;
  Auto := True;
  FTErminate := False;
  FShowWindow := False;
  FActive := False;
  FmaxSize := 0;
  FPause := False;
  FAutoAnswer := Result_invalid;
  if OwnerForm = nil then
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
begin
  SaveWork;
  if GOM.IsObj(FForm) then
    R(FForm);
  F(FProcessScript);
  F(FFilesInfo);
end;

procedure TUpdaterDB.DoPause;
begin
  FPause := True;
end;

procedure TUpdaterDB.DoTerminate;
var
  EventInfo: TEventValues;
  I: Integer;
begin
  FTerminate := True;
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    EventInfo.Name := AnsiLowerCase(FFilesInfo[I].FileName);
    DBKernel.DoIDEvent(FForm, 0, [EventID_CancelAddingImage], EventInfo);
  end;
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
      OwnerFormSetFileName(TA('<No files>', 'Updater'));

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
        OwnerFormSetTimeText(TA('The last file', 'Updater') + '...');
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
  UpdateDBThread.Create(Self, Info, OnAddFileDone, FAutoAnswer, UseFileNameScaning, @FTerminate, @FPause, NoLimit);
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
  SetNamedValueStr(FProcessScript, '$File', FileName);
  ExecuteScript(nil, FProcessScript, ScriptProcessString, C, nil);
  FileName := GetNamedValueString(FProcessScript, '$File');
end;

procedure TUpdaterDB.LoadWork;
var
  I, C: Integer;
  ProgressWindow: TProgressActionForm;
  DBPrefix: string;
begin
  DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
  ProgressWindow := GetProgressWindow;
  try
    C := Settings.ReadInteger('Updater_' + DBPrefix, 'Counter', 0);
    ProgressWindow.OneOperation := True;
    ProgressWindow.MaxPosCurrentOperation := C;
    ProgressWindow.XPosition := 0;
    ProgressWindow.SetAlternativeText(TA('Wait until the program is restore the work', 'Updater'));
    if C > 10 then
      ProgressWindow.Show;

    for I := 0 to C - 1 do
    begin
      if I mod 8 = 0 then
      begin
        ProgressWindow.XPosition := I;
        Application.ProcessMessages;
      end;
      AddFile(Settings.ReadString('Updater_' + DBPrefix, 'File' + IntToStr(I)), I <> C - 1);
    end;

  finally
    R(ProgressWindow);
  end;
end;

procedure TUpdaterDB.SaveWork;
var
  I: Integer;
  DBPrefix: string;
begin
  DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));
  Settings.WriteInteger('Updater_' + DBPrefix, 'Counter', FFilesInfo.Count);
  for I := 0 to FFilesInfo.Count - 1 do
    Settings.WriteString('Updater_' + DBPrefix, 'File' + IntToStr(I), FFilesInfo[I].FileName);
end;

function TUpdaterDB.GetCount: Integer;
begin
  Result := FFilesInfo.Count;
end;

end.
