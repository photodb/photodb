unit FormManegerUnit;

interface

uses
  GraphicCrypt, DB, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,  uVistaFuncs, AppEvnts, ExtCtrls, UnitINI, uAppUtils,
  Dialogs, UnitDBKernel, CommonDBSupport, UnitDBDeclare, UnitFileExistsThread,
  UnitDBCommon, uLogger, uConstants, uFileUtils, uTime, uSplashThread,
  uDBForm, uFastLoad, uMemory, uMultiCPUThreadManager, win32crc,
  uShellIntegration, uRuntime, Dolphin_DB, uDBBaseTypes, uDBFileTypes,
  uDBUtils, uDBPopupMenuInfo, uSettings, uAssociations, uActivationUtils,
  uExifUtils, uDBCustomThread;

type
  TFormManager = class(TDBForm)
    procedure CalledTimerTimer(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FMainForms: TList;
    FCheckCount: Integer;
    WasIde: Boolean;
    ExitAppl: Boolean;
    LockCleaning: Boolean;
    FSetLanguageMessage: Cardinal;
    procedure ExitApplication;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    function GetTimeLimitMessage: string;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    function GetFormID: string; override;
  public
    procedure CloseManager;
    constructor Create(AOwner : TComponent);  override;
    destructor Destroy; override;
    procedure RegisterMainForm(Value: TForm);
    procedure UnRegisterMainForm(Value: TForm);
    procedure Run;
    procedure RunInBackground;
    procedure Close(Form: TForm);
    function MainFormsCount: Integer;
    function IsMainForms(Form: TForm): Boolean;
    procedure CloseApp(Sender: TObject);
    procedure Load;
    property TimeLimitMessage: string read GetTimeLimitMessage;
  end;

var
  FormManager: TFormManager;
  TimerTerminateHandle : THandle;
  TimerCheckMainFormsHandle : THandle;
  TimerTerminateAppHandle : THandle;
  TimerCloseHandle : THandle;

const
  TIMER_TERMINATE = 1;
  TIMER_TERMINATE_APP = 2;
  TIMER_CHECK_MAIN_FORMS = 3;
  TIMER_CLOSE = 4;

implementation

uses
  UnitCleanUpThread, ExplorerUnit, uSearchTypes, SlideShow, UnitFileCheckerDB,
  UnitInternetUpdate, uAbout, UnitConvertDBForm, UnitImportingImagesForm,
  UnitSelectDB, UnitFormCont, UnitGetPhotosForm, UnitLoadFilesToPanel,
  uActivation, UnitUpdateDB, uExifPatchThread;

{$R *.dfm}

// callback function for Timer
procedure TimerProc(wnd :HWND; // handle of window for timer messages
                    uMsg :UINT; // WM_TIMER message
                    idEvent :UINT; // timer identifier
                    dwTime :DWORD // current system time
                    ); stdcall; // use stdcall when declare callback functions
begin
  if idEvent = TimerTerminateHandle then
  begin
    KillTimer(0, TimerTerminateHandle);
    EventLog('TFormManager::TerminateTimerTimer()!');
    Halt;
  end else if idEvent = TimerCheckMainFormsHandle then
  begin
    //to avoid deadlock in delphi 2010
    PostThreadMessage(GetCurrentThreadID, WM_NULL, 0, 0);

    if FormManager <> nil then
      FormManager.CheckTimerTimer(nil);
  end else if idEvent = TimerTerminateAppHandle then
  begin
    if FormManager <> nil then
      FormManager.CalledTimerTimer(nil);
  end else if idEvent = TimerCloseHandle then
  begin
    if FormManager <> nil then
      FormManager.TimerCloseApplicationByDBTerminateTimer(nil);
  end;
end;

{ TFormManager }

procedure TFormManager.Run;
var
  Directory, S: string;
  ParamStr1, ParamStr2: string;
  NewSearch: TSearchCustomForm;
  IDList: TArInteger;
  FileList: TArStrings;
  I: Integer;

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
  try
    EventLog(':TFormManager::Run()...');
    Settings.WriteProperty('Starting', 'ApplicationStarted', '1');

    ParamStr1 := ParamStr(1);
    ParamStr2 := Paramstr(2);
    Directory := ExcludeTrailingBackslash(ParamStr2);
    Directory := IncludeTrailingBackslash(LongFileName(Directory));
    if FolderView then
    begin
      ParamStr1 := '/EXPLORER';
      Directory := ExtractFileDir(Application.Exename);
    end;

    if AnsiUpperCase(ParamStr1) <> '/EXPLORER' then
    begin
      TW.I.Start('CheckFileExistsWithMessageEx - ParamStr1');
      if IsFile(ParamStr1) then
      begin
        if not IsGraphicFile(ParamStr1) then
        begin
          NewSearch := SearchManager.NewSearch;
          if FileExistsSafe(ParamStr1) then
          begin
            if GetExt(ParamStr1) = 'IDS' then
            begin
              S := LoadIDsFromfile(ParamStr1);
              NewSearch.SearchText := Copy(S, 1, 1000);
              NewSearch.StartSearch;
            end;
            if GetExt(ParamStr1) = 'ITH' then
            begin
              S := LoadIDsFromfile(ParamStr1);
              NewSearch.SearchText := ':HashFile(' + ParamStr1 + '):';
              NewSearch.StartSearch;
            end;
            if GetExt(ParamStr1) = 'DBL' then
            begin
              LoadDblFromfile(ParamStr1, IDList, FileList);
              S := '';
              for I := 1 to Length(IDList) do
                S := S + IntToStr(IDList[I - 1]) + '$';
              NewSearch.SearchText := Copy(S, 1, 500);
              NewSearch.StartSearch;
            end;
          end;
          CloseSplashWindow;
          NewSearch.Show;
        end else
        begin
          TW.I.Start('RUN TViewer');
          if Viewer = nil then
            Application.CreateForm(TViewer, Viewer);
          RegisterMainForm(Viewer);
          TW.I.Start('ExecuteDirectoryWithFileOnThread');
          Viewer.ExecuteDirectoryWithFileOnThread(ParamStr1);
          TW.I.Start('ActivateApplication');
          CloseSplashWindow;
          Viewer.Show;
        end;
      end else
      begin
        // Default Form
        if Settings.ReadBool('Options', 'RunExplorerAtStartUp', True) then
        begin
          TW.I.Start('RUN NewExplorer');
          with ExplorerManager.NewExplorer(False) do
          begin
            if Settings.ReadBool('Options', 'UseSpecialStartUpFolder', False) then
              SetPath(Settings.ReadString('Options', 'SpecialStartUpFolder'))
            else
              LoadLastPath;
            CloseSplashWindow;
            Show;
          end;
        end else
        begin
          TW.I.Start('SearchManager.NewSearch');
          NewSearch := SearchManager.NewSearch;
          Application.Restore;
          CloseSplashWindow;
          NewSearch.Show;
        end;
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
        Application.Restore;
        with SearchManager.NewSearch do
        begin
          CloseSplashWindow;
          Show;
        end;
      end;
    end;
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
    on e : Exception do EventLog(':TFormManager::UnRegisterMainForm() throw exception: ' + e.Message);
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

  EventLog(':TFormManager::ExitApplication()...');

  for I := 0 to FMainForms.Count - 1 do
    if not TForm(FMainForms[I]).Visible then
    begin
      try
        TForm(FMainForms[I]).Close;
      except
        on E: Exception do
          EventLog(':TFormManager::ExitApplication()/CloseForms throw exception: ' + E.message);
      end;
    end;

  // to allow run new copy
  Caption := '';

  //stop updating process, queue will be saved in registry
  DestroyUpdaterObject;

  for I := 0 to MultiThreadManagers.Count - 1 do
    TThreadPoolCustom(MultiThreadManagers[I]).CloseAndWaitForAllThreads;

  DBThreadManager.WaitForAllThreads(60000);
  TryRemoveConnection(DBName, True);

  FormManager := nil;

  TimerTerminateHandle := SetTimer(0, TIMER_TERMINATE, 60000, @TimerProc);
  Application.Terminate;
  TimerTerminateAppHandle := SetTimer(0, TIMER_TERMINATE_APP, 100, @TimerProc);

  Settings.WriteProperty('Starting', 'ApplicationStarted', '0');
  EventLog(':TFormManager::ExitApplication()/OK...');
  EventLog('');
  EventLog('');
  EventLog('');
  EventLog('finalization:');
end;

procedure TFormManager.FormCreate(Sender: TObject);
begin
  FSetLanguageMessage := RegisterWindowMessage('UPDATE_APP_LANGUAGE');
  DBKernel.RegisterChangesID(Sender, ChangedDBDataByID);
end;

function TFormManager.GetFormID: string;
begin
  Result := 'System';
end;

function TFormManager.GetTimeLimitMessage: string;
begin
  Result := L('After the 30 days has expired, you must activate your copy!');
end;

procedure TFormManager.CalledTimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormManager.ChangedDBDataByID(Sender: TObject; ID: Integer;
  Params: TEventFields; Value: TEventValues);
var
  UpdateInfoParams: TEventFields;
begin
  if ID <= 0 then
    Exit;

  if Params * [EventID_No_EXIF] <> [] then
    Exit;

  if not Settings.Exif.SaveInfoToExif then
    Exit;

  UpdateInfoParams := [EventID_Param_Rotate, EventID_Param_Rating,
    EventID_Param_Groups, EventID_Param_Links,
    EventID_Param_Include, EventID_Param_Private, EventID_Param_Attr,
    EventID_Param_Comment, EventID_Param_KeyWords, EventID_Param_Add];

  if UpdateInfoParams * Params <> [] then
    ExifPatchManager.AddPatchInfo(ID, Params, Value);
end;

procedure TFormManager.CheckTimerTimer(Sender: TObject);
var
  FReg: TBDRegistry;
  InstallDate: TDateTime;
begin
  if not CMDInProgress then
  begin
    if DBTerminating then
    begin
      ExitApplication;
      Exit;
    end;

    Inc(FCheckCount);
    if (FCheckCount = 10) then //after 1sec. set normal priority
    begin
      SetThreadPriority(MainThreadID, THREAD_PRIORITY_NORMAL);
      SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
    end;
    if (FCheckCount = 20) and not FolderView then //after 2 sec.
    begin
      EventLog('Loading Kernel.dll');
      TW.I.Start('StartCRCCheckThread');
      TLoad.Instance.StartCRCCheckThread;
    end;
    if (FCheckCount = 30) and not FolderView then //after 4 sec.
    begin
      if TActivationManager.Instance.IsDemoMode then
      begin
        FReg := TBDRegistry.Create(REGISTRY_ALL_USERS, True);
        try
          FReg.OpenKey(RegRoot, True);
          InstallDate := FReg.ReadDateTime('InstallDate', 0);
          //if more than 30 days
          if (Now - InstallDate) > DemoDays then
            ShowActivationDialog;

        finally
          F(FReg);
        end;
      end;
    end;
    if (FCheckCount = 40) and not FolderView then //after 4 sec.
    begin
      if Settings.ReadBool('Options', 'AllowAutoCleaning', False) then
        CleanUpThread.Create(Self, False);
    end;
    if (FCheckCount = 100) and not FolderView then //after 10 sec. check for updates
    begin
      TW.I.Start('TInternetUpdate - Create');
      TInternetUpdate.Create(nil, True, nil);
    end;
    if (FCheckCount = 600) and not FolderView then //after 1.min. backup database
      DBKernel.BackUpTable;

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

procedure TFormManager.CloseManager;
begin
  ExitApplication;
  Free;
end;

procedure TFormManager.TimerCloseApplicationByDBTerminateTimer(
  Sender: TObject);
begin
  inherited Close;
end;

procedure TFormManager.Load;
var
  DBFile: TPhotoDBFile;
  DBVersion: Integer;
  StringDBCheckKey: string;
begin
  TW.I.Start('FM -> Load');
  Caption := DBID;

  LockCleaning := True;
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
    if DBTerminating then
      TimerCloseHandle := SetTimer(0, TIMER_CLOSE, 1000, @TimerProc);

    if not DBTerminating then
    begin

      if not FileExistsSafe(Dbname) then
      begin
        CloseSplashWindow;
        DBFile := DoChooseDBFile(SELECT_DB_OPTION_GET_DB_OR_EXISTS);
        try
          if DBKernel.TestDB(DBFile.FileName) then
            DBKernel.AddDB(DBFile.name, DBFile.FileName, DBFile.Icon);
          DBKernel.SetDataBase(DBFile.FileName);

          DBVersion := DBKernel.TestDBEx(dbname, True);
          if not DBKernel.ValidDBVersion(dbname, DBVersion) then
          begin
            Application.Terminate;
            Exit;
          end;

        finally
          F(DBFile);
        end;
      end;

      //check valid db version
      StringDBCheckKey := Format('%d-%d', [Integer(StringCRC(dbname)), DB_VER_2_3]);
      if not Settings.ReadBool('DBVersionCheck', StringDBCheckKey, False) or GetParamStrDBBool('/dbcheck') then
      begin
        DBVersion := DBKernel.TestDBEx(dbname, False);
        if not DBKernel.ValidDBVersion(dbname, DBVersion) then
        begin
          CloseSplashWindow;
          ConvertDB(dbname);
          DBVersion := DBKernel.TestDBEx(dbname, False);
          if not DBKernel.ValidDBVersion(dbname, DBVersion) then
          begin
            Application.Terminate;
            Exit;
          end;
        end;
        Settings.WriteBool('DBVersionCheck', StringDBCheckKey, True);
      end;

      // checking RecordCount
      if Settings.ReadboolW('DBCheck', ExtractFileName(dbname), True) = True then
      begin
        Settings.WriteBoolW('DBCheck', ExtractFileName(dbname), False);
        if (CommonDBSupport.GetRecordsCount(Dbname) = 0) and not FolderView then
        begin
          CloseSplashWindow;
          ImportImages(dbname);
        end else
          Settings.WriteBoolW('DBCheck', ExtractFileName(dbname), False);

      end;
    end;

  finally
    LockCleaning := False;
  end;

  TW.I.Start('FM -> HidefromTaskBar');
  HidefromTaskBar(Application.Handle);
end;

procedure TFormManager.WMCopyData(var Msg: TWMCopyData);
var
  Param: TArStrings;
  Fids_: TArInteger;
  FileNameA, FileNameB, S: string;
  I: Integer;
  FormCont: TFormCont;
  B: TArBoolean;
  Data: Pointer;
begin

  if Msg.CopyDataStruct.DwData = WM_COPYDATA_ID then
  begin
    Data := PByte(Msg.CopyDataStruct.LpData) + SizeOf(TMsgHdr);
    SetString(S, PWideChar(Data), (Msg.CopyDataStruct.CbData - SizeOf(TMsgHdr) - 1) div SizeOf(WideChar));

    for I := 1 to Length(S) do
      if S[I] = #1 then
      begin
        FileNameA := Copy(S, 1, I - 1);
        FileNameB := Copy(S, I + 1, Length(S) - I);
        Break;
      end;
    if not CheckFileExistsWithMessageEx(FileNameA, False) then
    begin
      if AnsiUpperCase(FileNameA) = '/EXPLORER' then
      begin
        if CheckFileExistsWithMessageEx(LongFileName(FilenameB), True) then
        begin
          with ExplorerManager.NewExplorer(False) do
          begin
            SetPath(LongFileName(FileNameB));
            Show;
            ActivateBackgroundApplication(Handle);
          end;
        end;
      end else
      begin
        if AnsiUpperCase(FilenameA) = '/GETPHOTOS' then
          if FileNameB <> '' then
          begin
            GetPhotosFromDrive(FileNameB[1]);
            Exit;
          end;
        with SearchManager.GetAnySearch do
        begin
          Show;
          ActivateBackgroundApplication(Handle);
        end;
        Exit;
      end;
    end;
    if IsGraphicFile(FileNameA) then
    begin
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      FileNameA := LongFileName(FileNameA);
      ShowWindow(Viewer.Handle, SW_RESTORE);
      Viewer.ExecuteDirectoryWithFileOnThread(FileNameA);
      Viewer.Show;
      ActivateBackgroundApplication(Viewer.Handle);
    end else if (AnsiUpperCase(FileNameA) <> '/EXPLORER') and CheckFileExistsWithMessageEx(FileNameA, False) then
    begin
      if GetExt(FileNameA) = 'DBL' then
      begin
        LoadDblFromfile(FileNameA, Fids_, Param);
        FormCont := ManagerPanels.NewPanel;
        SetLength(B, 0);
        LoadFilesToPanel.Create(Param, Fids_, B, False, True, FormCont);
        LoadFilesToPanel.Create(Param, Fids_, B, False, False, FormCont);
        FormCont.Show;
        ActivateBackgroundApplication(FormCont.Handle);
        Exit;
      end;
      if GetExt(FilenameA) = 'IDS' then
      begin
        Fids_ := LoadIDsFromfileA(FileNameA);
        Setlength(Param, 1);
        FormCont := ManagerPanels.NewPanel;
        LoadFilesToPanel.Create(Param, Fids_, B, False, True, FormCont);
        FormCont.Show;
        ActivateBackgroundApplication(FormCont.Handle);
      end else
      begin
        if GetExt(FileNameA) = 'ITH' then
        begin
          with SearchManager.NewSearch do
          begin
            StartSearch(':HashFile(' + FilenameA + '):');
            ActivateBackgroundApplication(Handle);
          end;
          Exit;
        end else
        begin
          with SearchManager.GetAnySearch do
          begin
            Show;
            ActivateBackgroundApplication(Handle);
          end;
        end;
      end;
    end;
  end else
    Dispatch(Msg);

end;

constructor TFormManager.Create(AOwner: TComponent);
begin
  FMainForms := TList.Create;
  WasIde := False;
  ExitAppl := False;
  LockCleaning := False;
  inherited Create(AOwner);
end;

destructor TFormManager.Destroy;
begin
  F(FMainForms);
  inherited;
end;

initialization

  FormManager := nil;

end.
