unit FormManegerUnit;

interface

uses
  System.Types,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.AppEvnts,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,

  UnitDBKernel,
  CommonDBSupport,
  EasyListView,
  UnitDBDeclare,
  UnitDBCommon,

  uAppUtils,
  uLogger,
  uConstants,
  uTime,
  uSplashThread,
  uDBForm,
  uFastLoad,
  uMemory,
  uInterfaces,
  uShellUtils,
  uMultiCPUThreadManager,
  uShellIntegration,
  uRuntime,
  uDBUtils,
  uSettings,
  uAssociations,
  uDBCustomThread,
  uPortableDeviceManager,
  uUpTime,
  uPortableClasses,
  uTranslate,
  {$IFDEF LICENCE}
  UnitINI,
  uActivationUtils,
  {$ENDIF}
  uProgramStatInfo,
  uDatabaseDirectoriesUpdater,
  uFormInterfaces;

type
  TFormManager = class(TDBForm)
    AeMain: TApplicationEvents;
    procedure CalledTimerTimer(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AeMainException(Sender: TObject; E: Exception);
  private
    { Private declarations }
    FMainForms: TList;
    FCheckCount: Integer;
    WasIde: Boolean;
    ExitAppl: Boolean;
    FLockCleaning: Boolean;
    FSetLanguageMessage: Cardinal;
    FDirectoryWatcher: IDirectoryWatcher;
    procedure ExitApplication;
    function GetTimeLimitMessage: string;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure RegisterMainForm(Value: TForm);
    procedure UnRegisterMainForm(Value: TForm);
    procedure ProcessCommandLine(CommandLine: string);
    function ProcessPasswordRequest(S: string): Boolean;
    function ProcessEncryptionErrorMessage(S: string): Boolean;
    function GetCount: Integer;
    function GetFormByIndex(Index: Integer): TForm;
    procedure CheckSampleDB;
  protected
    function GetFormID: string; override;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Run;
    procedure RunInBackground;
    procedure Close(Form: TForm);
    function MainFormsCount: Integer;
    function IsMainForms(Form: TForm): Boolean;
    procedure CloseApp(Sender: TObject);
    procedure Load;
    property TimeLimitMessage: string read GetTimeLimitMessage;
    property Count: Integer read GetCount;
    property Forms[Index: Integer]: TForm read GetFormByIndex; default;
  end;

var
  FormManager: TFormManager;
  TimerTerminateHandle: THandle;
  TimerCheckMainFormsHandle: THandle;
  TimerTerminateAppHandle: THandle;
  TimerCloseHandle: THandle;

const
  TIMER_TERMINATE = 1;
  TIMER_TERMINATE_APP = 2;
  TIMER_CHECK_MAIN_FORMS = 3;
  TIMER_CLOSE = 4;

procedure RegisterMainForm(Value: TForm);
procedure UnRegisterMainForm(Value: TForm);

implementation

uses
  UnitCleanUpThread,
  uManagerExplorer,
  UnitInternetUpdate,
  UnitConvertDBForm,
  UnitImportingImagesForm,
  UnitSelectDB,
  uExifPatchThread;

{$R *.dfm}

procedure RegisterMainForm(Value: TForm);
begin
  if FormManager <> nil then
    FormManager.RegisterMainForm(Value);
end;

procedure UnRegisterMainForm(Value: TForm);
begin
  if FormManager <> nil then
    FormManager.UnRegisterMainForm(Value);
end;

// callback function for Timer
procedure TimerProc(Wnd: HWND; // handle of window for timer messages
  UMsg: UINT; // WM_TIMER message
  IdEvent: UINT; // timer identifier
  DwTime: DWORD // current system time
  ); stdcall; // use stdcall when declare callback functions
begin
  if IdEvent = TimerTerminateHandle then
  begin
    KillTimer(0, TimerTerminateHandle);
    EventLog('TFormManager::TerminateTimerTimer()!');
    Halt;
  end
  else if IdEvent = TimerCheckMainFormsHandle then
  begin
    // to avoid deadlock in delphi 2010
    PostThreadMessage(GetCurrentThreadID, WM_NULL, 0, 0);

    if FormManager <> nil then
      FormManager.CheckTimerTimer(nil);
  end
  else if IdEvent = TimerTerminateAppHandle then
  begin
    if FormManager <> nil then
      FormManager.CalledTimerTimer(nil);
  end
  else if IdEvent = TimerCloseHandle then
  begin
    if FormManager <> nil then
      FormManager.TimerCloseApplicationByDBTerminateTimer(nil);
  end;
end;

{ TFormManager }

procedure TFormManager.ProcessCommandLine(CommandLine: string);
var
  Directory, S: string;
  ParamStr1, ParamStr2: string;
  PDManager: IPManager;
  PDevice: IPDevice;

  function IsFile(S: string): Boolean;
  var
    Ext: string;
  begin
    Result := False;
    S := Trim(S);
    if ExtractFileName(S) <> '' then
    begin
      Ext := ExtractFileExt(S);
      if (Ext <> '') and (Ext[1] = '.') then
        Result := True;
    end;
  end;
begin
  ParamStr1 := ParamStrEx(CommandLine, 1);
  ParamStr2 := ParamstrEx(CommandLine, 2);
  Directory := ExcludeTrailingBackslash(ParamStr2);
  Directory := IncludeTrailingBackslash(LongFileName(Directory));
  if FolderView then
  begin
    ParamStr1 := '/EXPLORER';
    Directory := ExtractFileDir(Application.Exename);
  end;

  //statictics
  ProgramStatistics.ProgramStarted;

  if AnsiUpperCase(ParamStr1) <> '/EXPLORER' then
  begin
    TW.I.Start('CheckFileExistsWithMessageEx - ParamStr1');
    if IsFile(ParamStr1) and IsGraphicFile(ParamStr1) then
    begin
      TW.I.Start('RUN TViewer');
      TW.I.Start('ExecuteDirectoryWithFileOnThread');
      Viewer.ShowImageInDirectoryEx(ParamStr1);
      TW.I.Start('ActivateApplication');
      CloseSplashWindow;

      Viewer.Show;
      Viewer.Restore;

      //statictics
      ProgramStatistics.ProgramStartedViewer;
    end else
    begin

      // Default Form
      TW.I.Start('RUN NewExplorer');
      with ExplorerManager.NewExplorer(False) do
      begin

        if not GetParamStrDBBoolEx(CommandLine, '/import') then
          LoadLastPath
        else
        begin
          S := GetParamStrDBValueV2(CommandLine, '/devId');
          if S = '' then
            S := GetParamStrDBValueV2(CommandLine, '/StiDevice');

          PDManager := CreateDeviceManagerInstance;
          PDevice := PDManager.GetDeviceByID(S);
          if PDevice <> nil then
            SetPath(cDevicesPath + '\' + PDevice.Name)
          else
            LoadLastPath;
        end;
        CloseSplashWindow;
        Show;
      end;
      //statictics
      ProgramStatistics.ProgramStartedDefault;
    end;
  end else
  begin
    if DirectoryExists(Directory) then
    begin
      with ExplorerManager.NewExplorer(False) do
      begin
        SetPath(Directory);
        CloseSplashWindow;
        Show;
      end;
    end else
    begin
      with ExplorerManager.NewExplorer(True) do
      begin
        CloseSplashWindow;
        Show;
      end;
    end;
    //statictics
    ProgramStatistics.ProgramStartedDefault;
  end;

  if GetParamStrDBBoolEx(CommandLine, '/import') then
  begin
    S := GetParamStrDBValueV2(CommandLine, '/devId');
    if S = '' then
      S := GetParamStrDBValueV2(CommandLine, '/StiDevice');

    PDManager := CreateDeviceManagerInstance;
    PDevice := PDManager.GetDeviceByID(S);
    if PDevice <> nil then
      ImportForm.FromDevice(PDevice.Name);
  end;
end;

function TFormManager.ProcessEncryptionErrorMessage(S: string): Boolean;
const
  ErrorRequestID = '::ENCRYPT_ERROR:';
var
  I: Integer;
  ErrorHandler: IEncryptErrorHandlerForm;
  ErrorMessage: string;
begin
  Result := False;
  if StartsText(ErrorRequestID, S) then
  begin
    Result := True;

    Delete(S, 1, Length(ErrorRequestID));
    ErrorMessage := S;

    for I := 0 to FormManager.Count - 1 do
    begin
      if (FormManager[I] is TDBForm) and Supports(FormManager[I], IEncryptErrorHandlerForm) then
      begin
        TDBForm(FormManager[I]).QueryInterfaceEx(IEncryptErrorHandlerForm, ErrorHandler);
        if ErrorHandler <> nil then
          ErrorHandler.HandleEncryptionError('', ErrorMessage);

      end;
    end;
  end;
end;

function TFormManager.ProcessPasswordRequest(S: string): Boolean;
const
  PasswordRequestID = '::PASS:';
var
  P: Integer;
  SharedFileName,
  Password: string;
  SharedMemHandle: THandle;
  SharedMemory: Pointer;
begin
  Result := False;
  //password request from transparent encryption dll
  //format:
  //::PASS:SHARED_MEMORY_ID:FileName
  if StartsText(PasswordRequestID, S) then
  begin
    Result := True;

    Delete(S, 1, Length(PasswordRequestID));
    P := Pos(':', S);
    if P > 1 then
    begin
      SharedFileName := Copy(S, 1, P - 1);
      Delete(S, 1, P);

      SharedMemHandle := OpenFileMapping(FILE_MAP_WRITE, False, PChar(SharedFileName));
      if SharedMemHandle <> 0 then
      begin
        SharedMemory := MapViewOfFile(SharedMemHandle, FILE_MAP_WRITE, 0, 0, 0);
        if SharedMemory <> nil then
        begin
          Password := DBKernel.FindPasswordForCryptImageFile(S);

          CopyMemory(SharedMemory, PChar(Password), SizeOf(Char) * (Length(Password) + 1));

          UnmapViewOfFile(SharedMemory);
        end;
        CloseHandle(SharedMemHandle);
      end;
    end;
  end;
end;

procedure TFormManager.Run;
begin
  try
    EventLog(':TFormManager::Run()...');
    Settings.WriteProperty('Starting', 'ApplicationStarted', '1');

    ProcessCommandLine(GetCommandLine);

    FCheckCount := 0;
    TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 55, @TimerProc);
  finally
    ShowWindow(Application.MainForm.Handle, SW_HIDE);
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TFormManager.RunInBackground;
begin
  FCheckCount := 0;
  TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 55, @TimerProc);
end;

procedure TFormManager.Close(Form: TForm);
begin
  UnRegisterMainForm(Self);
end;

procedure TFormManager.RegisterMainForm(Value: TForm);
begin
  FMainForms.Add(Value);
end;

procedure TFormManager.UnRegisterMainForm(Value: TForm);
var
  I: Integer;
begin
  FMainForms.Remove(Value);
  try
    for I := FMainForms.Count - 1 downto 0 do
      if not TForm(FMainForms[I]).Visible then
        TForm(FMainForms[I]).Close;
  except
    on E: Exception do
      EventLog(':TFormManager::UnRegisterMainForm() throw exception: ' + E.message);
  end;
end;

procedure TFormManager.ExitApplication;
var
  I: Integer;
begin
  if ExitAppl then
    Exit;

  DBTerminating := True;
  ExitAppl := True;

  //save uptime
  if not GetParamStrDBBool('/uninstall') then
    PermanentlySaveUpTime;

  // to allow run new copy
  Caption := DB_ID_CLOSING;

  EventLog(':TFormManager::ExitApplication()...');

  if FDirectoryWatcher <> nil then
  begin
   (FDirectoryWatcher as IUserDirectoriesWatcher).StopWatch;
    FDirectoryWatcher := nil;
  end;

  for I := FMainForms.Count - 1 downto 0 do
    if not TForm(FMainForms[I]).Visible then
    begin
      try
        TForm(FMainForms[I]).Close;
      except
        on E: Exception do
          EventLog(':TFormManager::ExitApplication()/CloseForms throw exception: ' + E.message);
      end;
    end;

  for I := 0 to MultiThreadManagers.Count - 1 do
    TThreadPoolCustom(MultiThreadManagers[I]).CloseAndWaitForAllThreads;

  DBThreadManager.WaitForAllThreads(60000);
  TryRemoveConnection(DBName, True);

  FormManager := nil;

  TimerTerminateHandle := SetTimer(0, TIMER_TERMINATE, 60000, @TimerProc);
  Application.Terminate;
  TimerTerminateAppHandle := SetTimer(0, TIMER_TERMINATE_APP, 100, @TimerProc);

  if not GetParamStrDBBool('/uninstall') then
    Settings.WriteProperty('Starting', 'ApplicationStarted', '0');
  EventLog(':TFormManager::ExitApplication()/OK...');
  EventLog('');
  EventLog('');
  EventLog('');
  EventLog('finalization:');
end;

procedure TFormManager.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  for I := FMainForms.Count - 1 downto 0 do
  try
    TForm(FMainForms[I]).Close;
  except
    on E: Exception do
      EventLog(':TFormManager::ExitApplication()/CloseForms throw exception: ' + E.message);
  end;
  ExitApplication;
end;

procedure TFormManager.FormCreate(Sender: TObject);
begin
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(TEasyListview, TScrollingStyleHook);
  FSetLanguageMessage := RegisterWindowMessage('UPDATE_APP_LANGUAGE');
  DBKernel.RegisterChangesID(Sender, ChangedDBDataByID);
end;

function TFormManager.GetCount: Integer;
begin
  Result := FMainForms.Count;
end;

function TFormManager.GetFormByIndex(Index: Integer): TForm;
begin
  Result := FMainForms[Index];
end;

function TFormManager.GetFormID: string;
begin
  Result := 'System';
end;

function TFormManager.GetTimeLimitMessage: string;
begin
  Result := L('After the 30 days has expired, you must activate your copy!');
end;

procedure TFormManager.AeMainException(Sender: TObject; E: Exception);
begin
  CloseSplashWindow;
  EventLog(E);
  //{$IFDEF DEBUG}
  MessageBoxDB(Handle, FormatEx(TA('An unhandled error occurred: {0}!'), [E.ToString + sLineBreak + E.StackTrace]), L('Error'),  TD_BUTTON_OK, TD_ICON_ERROR);
  //{$ENDIF}
end;

procedure TFormManager.CalledTimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormManager.ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
var
  UpdateInfoParams: TEventFields;
begin
  if Params * [EventID_Param_DB_Changed] <> [] then
  begin
    Settings.ClearCache;
    UpdaterStorage.CleanUpDatabase(dbname);
    UpdaterStorage.SaveStorage;
    UpdaterStorage.RestoreStorage(dbname);
    if FDirectoryWatcher <> nil then
      (FDirectoryWatcher as IUserDirectoriesWatcher).Execute;
  end;

  if ID <= 0 then
    Exit;

  if Params * [EventID_No_EXIF] <> [] then
    Exit;

  if not Settings.Exif.SaveInfoToExif then
    Exit;

  UpdateInfoParams := [EventID_Param_Rotate, EventID_Param_Rating, EventID_Param_Groups, EventID_Param_Links,
    EventID_Param_Include, EventID_Param_Private, EventID_Param_Attr, EventID_Param_Comment, EventID_Param_KeyWords,
    SetNewIDFileData];

  if UpdateInfoParams * Params <> [] then
    ExifPatchManager.AddPatchInfo(ID, Params, Value);
end;

procedure TFormManager.CheckSampleDB;
var
  FileName: string;
begin
  //if program was uninstalled with registered databases - restore database or create new database
  FileName := IncludeTrailingBackslash(GetMyDocumentsPath) + TA('My collection') + '.photodb';
  if not FileExistsSafe(FileName) then
    CreateExampleDB(FileName, Application.ExeName + ',0', ExtractFileDir(Application.ExeName));

  DBKernel.AddDB(TA('My collection'), FileName, Application.ExeName + ',0');
  DBKernel.SetDataBase(FileName);
end;

procedure TFormManager.CheckTimerTimer(Sender: TObject);
{$IFDEF LICENCE}
var
  FReg: TBDRegistry;
  InstallDate: TDateTime;
{$ENDIF}
begin
  if not CMDInProgress then
  begin
    if DBTerminating then
    begin
      ExitApplication;
      Exit;
    end;

    Inc(FCheckCount);

    if (FCheckCount = 5) and not FolderView then
    begin
      FDirectoryWatcher := TUserDirectoriesWatcher.Create;
      (FDirectoryWatcher as IUserDirectoriesWatcher).Execute;
    end;

    if (FCheckCount = 10) then // after 1sec. set normal priority
    begin
      SetThreadPriority(MainThreadID, THREAD_PRIORITY_NORMAL);
      SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
    end;
    if (FCheckCount = 20) and not FolderView then // after 2 sec.
    begin
      EventLog('Loading Kernel.dll');
      TW.I.Start('StartCRCCheckThread');
      TLoad.Instance.StartCRCCheckThread;
    end;
    {$IFDEF LICENCE}
    if (FCheckCount = 30) and not FolderView then // after 4 sec.
    begin
      if TActivationManager.Instance.IsDemoMode then
      begin
        FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
        try
          FReg.OpenKey(RegRoot, True);
          InstallDate := FReg.ReadDateTime('InstallDate', 0);
          // if more than 30 days
          if (Now - InstallDate) > DemoDays then
            ActivationForm.Execute;

        finally
          F(FReg);
        end;
      end;
    end;
    {$ENDIF}
    if (FCheckCount = 40) and not FolderView then // after 4 sec.
    begin
      if Settings.ReadBool('Options', 'AllowAutoCleaning', False) then
        CleanUpThread.Create(Self, False);
    end;

    if (FCheckCount = 50) and not FolderView then // after 4 sec.
    begin
      TW.I.Start('FM -> DBCheck');
      // checking RecordCount
      if Settings.ReadboolW('DBCheck', ExtractFileName(Dbname), True) = True then
      begin
        Settings.WriteBoolW('DBCheck', ExtractFileName(Dbname), False);
        if (CommonDBSupport.GetRecordsCount(Dbname) = 0) and not FolderView then
          ImportImages(Dbname);
      end;
    end;

    if (FCheckCount = 100) and not FolderView then // after 10 sec. check for updates
    begin
      TW.I.Start('TInternetUpdate - Create');
      TInternetUpdate.Create(nil, True, nil);
    end;
    if (FCheckCount = 600) and not FolderView then // after 1.min. backup database
      DBKernel.BackUpTable;

    if (FCheckCount mod 100 = 0) then
    begin
      //each 10 seconts save uptime
      AddUptimeSecs(10);
    end;

    if FMainForms.Count = 0 then
      ExitApplication;
  end;
end;

function TFormManager.MainFormsCount: Integer;
begin
  Result := FMainForms.Count;
end;

function TFormManager.IsMainForms(Form: TForm): Boolean;
begin
  Result := FMainForms.IndexOf(Form) > -1;
end;

procedure TFormManager.CloseApp(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FMainForms.Count - 1 do
    TForm(FMainForms[I]).Close;
end;

procedure TFormManager.TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
begin
  inherited Close;
end;

procedure TFormManager.Load;
var
  DBFile: TDatabaseInfo;
  DBVersion: Integer;
  StringDBCheckKey: string;

begin
  TW.I.Start('FM -> Load');
  Caption := DBID;

  FLockCleaning := True;
  try

    try
      TW.I.Start('FM -> InitializeDolphinDB');
      if FolderView then
      begin
        Dbname := ExtractFilePath(Application.ExeName) + 'FolderDB.photodb';

        if FileExistsSafe(ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb') then
          Dbname := ExtractFilePath(Application.ExeName) + AnsiLowerCase(GetFileNameWithoutExt(Application.ExeName)) + '.photodb';
      end;
    except
      on E: Exception do
        EventLog(':TFormManager::FormCreate() throw exception: ' + E.message);
    end;

    TW.I.Start('FM -> SetTimer');
    if DBTerminating then
      TimerCloseHandle := SetTimer(0, TIMER_CLOSE, 1000, @TimerProc);

    if not DBTerminating then
    begin

      if not FileExistsSafe(Dbname) then
      begin
        TW.I.Start('FM -> DoChooseDBFile');
        CloseSplashWindow;

        CheckSampleDB;

        if not FileExistsSafe(Dbname) then
        begin
          DBFile := DoChooseDBFile(SELECT_DB_OPTION_GET_DB_OR_EXISTS);
          try
            if DBKernel.TestDB(DBFile.Path) then
              DBKernel.AddDB(DBFile.Title, DBFile.Path, DBFile.Icon);
            DBKernel.SetDataBase(DBFile.Path);

            DBVersion := DBKernel.TestDBEx(Dbname, True);
            if not DBKernel.ValidDBVersion(Dbname, DBVersion) then
            begin
              DBTerminating := True;
              Exit;
            end;

          finally
            F(DBFile);
          end;
        end;
      end;

      TW.I.Start('FM -> check valid db version');
      // check valid db version
      StringDBCheckKey := Format('%d-%d', [Integer(StringCRC(Dbname)), DB_VER_CURRENT]);
      if not Settings.ReadBool('DBVersionCheck', StringDBCheckKey, False) or GetParamStrDBBool('/dbcheck') then
      begin
        TW.I.Start('FM -> TestDBEx');
        DBVersion := DBKernel.TestDBEx(Dbname, False);
        if not DBKernel.ValidDBVersion(Dbname, DBVersion) then
        begin
          CloseSplashWindow;
          ConvertDB(Dbname);
          DBVersion := DBKernel.TestDBEx(Dbname, False);
          if not DBKernel.ValidDBVersion(Dbname, DBVersion) then
          begin
            DBTerminating := True;
            Exit;
          end;
        end;
        Settings.WriteBool('DBVersionCheck', StringDBCheckKey, True);
      end;
    end;
  finally
    FLockCleaning := False;
  end;

  TW.I.Start('FM -> HidefromTaskBar');
  HidefromTaskBar(Application.Handle);
end;

procedure TFormManager.WMCopyData(var Msg: TWMCopyData);
var
  S: string;
  Data: Pointer;
begin
  if Msg.CopyDataStruct.DwData = WM_COPYDATA_ID then
  begin
    Data := PByte(Msg.CopyDataStruct.LpData);
    SetString(S, PWideChar(Data), Msg.CopyDataStruct.CbData div SizeOf(WideChar));

    if ProcessPasswordRequest(S) then
      Exit;

    if ProcessEncryptionErrorMessage(S) then
      Exit;

    ProcessCommandLine(S);
    if Screen.ActiveCustomForm <> nil then
      ActivateBackgroundApplication(Screen.ActiveCustomForm.Handle);
  end else
    Dispatch(Msg);
end;

procedure TFormManager.WMDeviceChange(var Msg: TMessage);
begin
  case Msg.wParam of
    DBT_DEVNODES_CHANGED:
      //device configuration was changed
  end;
end;

constructor TFormManager.Create(AOwner: TComponent);
begin
  FMainForms := TList.Create;
  WasIde := False;
  ExitAppl := False;
  FLockCleaning := False;
  inherited Create(AOwner);
end;

destructor TFormManager.Destroy;
begin
  F(FMainForms);
  inherited;
end;

initialization
  FormManager := nil;

finalization
  FormManager := nil;

end.
