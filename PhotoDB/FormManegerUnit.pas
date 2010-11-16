unit FormManegerUnit;

interface

uses
  GraphicCrypt, DB, UnitINI, UnitTerminationApplication,
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,  uVistaFuncs, AppEvnts, ExtCtrls,
  Dialogs, dolphin_db, Crypt, CommonDBSupport, UnitDBDeclare, UnitFileExistsThread,
  UnitDBCommon, uLogger, uConstants, uFileUtils, uTime, uSplashThread,
  uDBForm, uFastLoad, uMemory;

type
  TFormManager = class(TDBForm)
    procedure CalledTimerTimer(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
  private
    { Private declarations }
    FMainForms : TList;
    FTemtinatedActions : TTemtinatedActions;
    CanCheckViewerInMainForms : Boolean;
    FCheckCount : Integer;
    WasIde : Boolean;
    ExitAppl : Boolean;
    LockCleaning : Boolean;
    EnteringCodeNeeded : Boolean;
    procedure ExitApplication;
    procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;
    procedure InitializeActivation;
  public
    constructor Create(AOwner : TComponent);  override;
    destructor Destroy; override;
    procedure RegisterMainForm(Value: TForm);
    procedure UnRegisterMainForm(Value: TForm);
    procedure RegisterActionCanTerminating(Value: TTemtinatedAction);
    procedure UnRegisterActionCanTerminating(Value: TTemtinatedAction);
    procedure Run(LoadingThread : TThread);
    procedure Close(Form : TForm);
    function MainFormsCount : Integer;
    function IsMainForms(Form : TForm) : Boolean;
    procedure CloseApp(Sender : TObject);
    procedure Load;
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

uses Language, UnitCleanUpThread, ExplorerUnit, Searching, SlideShow,
DBSelectUnit, uActivation, UnitUpdateDB, UnitInternetUpdate, uAbout,
UnitConvertDBForm, UnitImportingImagesForm, UnitFileCheckerDB,
UnitSelectDB, UnitFormCont, UnitGetPhotosForm, UnitLoadFilesToPanel;

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

procedure TFormManager.InitializeActivation;
var
  Reg : TBDRegistry;
  days : integer;
  d1 : tdatetime;

begin
 if DBKernel.ProgramInDemoMode and not DBInDebug then
 begin
  try
   Reg:=TBDRegistry.Create(REGISTRY_CLASSES);
   Reg.OpenKey('CLSID\{F70C45B3-1D2B-4FC3-829F-16E5AF6937EB}\',true);
   d1:=now;
   if Reg.ValueExists('VersionTimeA') then
   begin
    if Reg.ReadBool('VersionTimeA') then
    begin
     Reg.free;
     EnteringCodeNeeded:=true;
     MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
     exit;
    end
   end else if reg.ValueExists('VersionTime') then
   d1:=reg.Readdatetime('VersionTime') else
   begin
    reg.Writedatetime('VersionTime',now);
    d1:=now;
   end;
   days:=round(now-d1);
   if days<0 then
   begin
    reg.WriteBool('VersionTimeA',true);
    Reg.free;
    EnteringCodeNeeded:=true;
    MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
    exit;
   end;
   if (days>DemoDays) and not DBInDebug then
   begin
    reg.WriteBool('VersionTimeA',True);
    Reg.free;
    EnteringCodeNeeded:=true;
    MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
    exit;
   end;
   Reg.free;
  except
   on e : Exception do
   begin
    MessageBoxDB(FormManager.Handle,Format(L('Unhandled error: %s') ,[e.Message]), L('Error') ,TD_BUTTON_OK,TD_ICON_INFORMATION);
    Exit;
   end;
  end;
 end;
end;

procedure TFormManager.Run(LoadingThread : TThread);
var
  Directory, S: string;
  ParamStr1, ParamStr2: string;
  NewSearch: TSearchForm;
  IDList: TArInteger;
  FileList: TArStrings;
  I: Integer;

  procedure CloseLoadingForm;
  begin
    LoadingThread.Terminate;
  end;

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
    DBKernel.WriteProperty('Starting', 'ApplicationStarted', '1');

    ParamStr1 := ParamStr(1);
    ParamStr2 := Paramstr(2);
    Directory := ParamStr2;
    UnFormatDir(Directory);
    Directory := LongFileName(Directory);
    FormatDir(Directory);
    if FolderView then
    begin
      ParamStr1 := '/EXPLORER';
      Directory := GetDirectory(Application.Exename);
      UnformatDir(Directory);
    end;

    if UpcaseAll(ParamStr1) <> '/EXPLORER' then
    begin
      TW.I.Start('CheckFileExistsWithMessageEx - ParamStr1');
      if IsFile(ParamStr1) then
      begin
        if not ExtInMask(SupportedExt, GetExt(ParamStr1)) then
        begin
          NewSearch := SearchManager.NewSearch;
          if CheckFileExistsWithMessageEx(ParamStr1, False) then
          begin
            if GetExt(ParamStr1) = 'IDS' then
            begin
              S := LoadIDsFromfile(ParamStr1);
              NewSearch.SearchEdit.Text := Copy(S, 1, 1000);
              NewSearch.DoSearchNow(nil);
            end;
            if GetExt(ParamStr1) = 'ITH' then
            begin
              S := LoadIDsFromfile(ParamStr1);
              NewSearch.SearchEdit.Text := ':ThFile(' + ParamStr1 + '):';
              NewSearch.DoSearchNow(nil);
            end;
            if GetExt(ParamStr1) = 'DBL' then
            begin
              LoadDblFromfile(ParamStr1, IDList, FileList);
              S := '';
              for I := 1 to Length(IDList) do
                S := S + IntToStr(IDList[I - 1]) + '$';
              NewSearch.SearchEdit.Text := Copy(S, 1, 500);
              NewSearch.DoSearchNow(nil);
            end;
          end;
          CloseLoadingForm;
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
          CloseLoadingForm;
          Viewer.Show;
        end;
      end else
      begin
        // Default Form
        if DBKernel.ReadBool('Options', 'RunExplorerAtStartUp', False) then
        begin
          TW.I.Start('RUN NewExplorer');
          with ExplorerManager.NewExplorer(False) do
          begin
            if DBKernel.ReadBool('Options', 'UseSpecialStartUpFolder', False) then
              SetPath(DBKernel.ReadString('Options', 'SpecialStartUpFolder'))
            else
              SetNewPathW(GetCurrentPathW, False);
            CloseLoadingForm;
            Show;
          end;
        end else
        begin
          TW.I.Start('SearchManager.NewSearch');
          NewSearch := SearchManager.NewSearch;
          Application.Restore;
          CloseLoadingForm;
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
          CloseLoadingForm;
          Show;
        end;
      end else
      begin
        Application.Restore;
        with SearchManager.NewSearch do
        begin
          Show;
          CloseLoadingForm;
        end;
      end;
    end;
    FCheckCount := 0;
    TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 100, @TimerProc);
  finally
    ShowWindow(Application.MainForm.Handle, SW_HIDE);
    ShowWindow(Application.Handle, SW_HIDE);
  end;
end;

procedure TFormManager.Close(Form: TForm);
begin
  UnRegisterMainForm(Self);
end;

procedure TFormManager.RegisterMainForm(Value: TForm);
begin
  if Value <> Viewer then
    CanCheckViewerInMainForms := True;
  FMainForms.Add(Value);
end;

procedure TFormManager.UnRegisterMainForm(Value: TForm);
var
  i : integer;
begin
  FMainForms.Remove(Value);
  try
    for i:=FMainForms.Count - 1 downto 1 do
      if not TForm(FMainForms[i]).Visible then
        TForm(FMainForms[i]).Close;
  except
    on e : Exception do EventLog(':TFormManager::UnRegisterMainForm() throw exception: ' + e.Message);
  end;
end;

procedure TFormManager.ExitApplication;
var
  I: Integer;
  FirstTick: Cardinal;
  ApplReadyForEnd: Boolean;
begin
  if ExitAppl then
    Exit;
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

  for I := 0 to Length(FTemtinatedActions) - 1 do
    if (FTemtinatedActions[I].Options = TA_INFORM) or (FTemtinatedActions[I].Options = TA_INFORM_AND_NT) then
    begin
    end;
  Delay(10);
  ApplReadyForEnd := False;
  for I := 0 to Length(FTemtinatedActions) - 1 do
    FTemtinatedActions[I].TerminatedPointer^ := True;
  FirstTick := GetTickCount;
  repeat
    Delay(10);
    try
      if (GetTickCount - FirstTick) > 5000 then
        Break;
      ApplReadyForEnd := True;
      for I := 0 to Length(FTemtinatedActions) - 1 do
        if not FTemtinatedActions[I].TerminatedPointer^ then
        begin
          ApplReadyForEnd := False;
          Break;
        end;
    except
      Break;
    end;
    if ApplReadyForEnd then
      Break;
  until False;
{$IFDEF RELEASE}
  TerminationApplication.Create;
{$ENDIF}
  FormManager := nil;
  TimerTerminateHandle := SetTimer(0, TIMER_TERMINATE, 10000, @TimerProc);
  Application.Terminate;
  TimerTerminateAppHandle := SetTimer(0, TIMER_TERMINATE_APP, 100, @TimerProc);

  DBKernel.WriteProperty('Starting', 'ApplicationStarted', '0');
  EventLog(':TFormManager::ExitApplication()/OK...');
  EventLog('');
  EventLog('');
  EventLog('');
  EventLog('finalization:');
end;

procedure TFormManager.CalledTimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormManager.CheckTimerTimer(Sender: TObject);
begin
  begin
    Inc(FCheckCount);
    if (FCheckCount = 10) then //after 1sec. set normal priority
    begin
      SetThreadPriority(MainThreadID, THREAD_PRIORITY_NORMAL);
      SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
    end;
    if (FCheckCount = 20) and not FolderView then //after 2 sec.
    begin
      EventLog('Loading Kernel.dll');
      TW.i.Start('StartCRCCheckThread');
      TLoad.Instance.StartCRCCheckThread;
    end;
    if (FCheckCount = 50) and not FolderView then //after 5 sec.
    begin

      if not DBTerminating then
        if not FolderView then
          if KernelHandle = 0 then
          begin
            EventLog('KernelHandle IS 0 -> exit');
            MessageBoxDB(GetActiveFormHandle, L('Unable to load "Kernel.dll" library!'),
              L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
            Application.Terminate;
          end;

      {$IFDEF LICENCE}
      EventLog('Verifyng....');

      TLoad.Instance.RequaredCRCCheck;
      @Initaproc := GetProcAddress(KernelHandle, 'InitializeA');
      if not Initaproc(PChar(Application.ExeName)) then
      begin
        SplashThread.Terminate;
        MessageBoxDB(GetActiveFormHandle, TEXT_MES_APPLICATION_NOT_VALID, L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        DBTerminating := True;
        Application.Terminate;
      end;
      {$ENDIF}
    end;
    if (FCheckCount = 600) then //after 1.min. backup database
      DBKernel.BackUpTable;
    if CanCheckViewerInMainForms then
    begin
      if (FMainForms.Count = 1) and (FMainForms[0] = Viewer) and (Viewer <> nil) then
      begin
        CanCheckViewerInMainForms := False;
        //to prevent many messageboxes
        KillTimer(0, TimerCheckMainFormsHandle);
        try
          ActivateApplication(Viewer.Handle);
          //if Viewer rests - user cal puch button "Close"
          //if ID_YES = MessageBoxDB(Viewer.Handle, TEXT_MES_VIEWER_REST_IN_MEMORY_CLOSE_Q, TEXT_MES_WARNING,TD_BUTTON_YESNO, TD_ICON_WARNING) then
          //  FMainForms.Clear;
        finally
           TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 100, @TimerProc);
        end;
      end;
    end;
    if FMainForms.Count = 0 then
      ExitApplication;
  end;
end;

procedure TFormManager.RegisterActionCanTerminating(
  Value: TTemtinatedAction);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FTemtinatedActions)-1 do
 if FTemtinatedActions[i].Owner=Value.Owner then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FTemtinatedActions,Length(FTemtinatedActions)+1);
  FTemtinatedActions[Length(FTemtinatedActions)-1]:=Value;
 end;
end;

procedure TFormManager.UnRegisterActionCanTerminating(
  Value: TTemtinatedAction);
var
  i, j : integer;
begin
 For i:=0 to Length(FTemtinatedActions)-1 do
 if FTemtinatedActions[i].Owner=Value.Owner then
 begin
  For j:=i to Length(FTemtinatedActions)-2 do
  FTemtinatedActions[j]:=FTemtinatedActions[j+1];
  SetLength(FTemtinatedActions,Length(FTemtinatedActions)-1);
  break;
 end;
end;

function TFormManager.MainFormsCount: Integer;
begin
  Result := FMainForms.Count;
end;

function TFormManager.IsMainForms(Form: TForm): Boolean;
begin
  Result:= FMainForms.IndexOf(Form) > -1;
end;

procedure TFormManager.CloseApp(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to FMainForms.Count - 1 do
    TForm(FMainForms[i]).Close;
end;

procedure TFormManager.TimerCloseApplicationByDBTerminateTimer(
  Sender: TObject);
begin
  inherited Close;
end;

procedure TFormManager.Load;
begin
  TW.I.Start('FM -> Load');
 Caption:=DBID;
 CanCheckViewerInMainForms:=false;
 LockCleaning:=true;
 EnteringCodeNeeded := false;
 try
  TW.I.Start('FM -> InitializeDolphinDB');
  if not FolderView then
  InitializeActivation else
  begin
   dbname := GetDirectory(Application.ExeName)+'FolderDB.photodb';

   if FileExists(GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb') then
   dbname:=GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb';
  end;
 except
  on e : Exception do EventLog(':TFormManager::FormCreate() throw exception: '+e.Message);
 end;
 if DBTerminating then
   TimerCloseHandle := SetTimer(0, TIMER_CLOSE, 1000, @TimerProc);

 If not DBTerminating then
 begin

 // DBVersion:=DBKernel.TestDBEx(dbname,true);

{  if DBVersion<0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_FILE_NOT_FOUND_ERROR,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);

   DBFile:=DoChooseDBFile(SELECT_DB_OPTION_GET_DB_OR_EXISTS);
   if DBKernel.TestDB(DBFile.FileName) then
   DBKernel.AddDB(DBFile._Name,DBFile.FileName,DBFile.Icon);
   DBKernel.SetDataBase(DBFile.FileName);

   DBVersion:=DBKernel.TestDBEx(dbname,true);
   if not DBKernel.ValidDBVersion(dbname,DBVersion) then
   Halt;
  end else  }
  begin
  { if not DBKernel.ValidDBVersion(dbname,DBVersion) then
   begin
    ConvertDB(dbname);
    if not DBKernel.TestDB(dbname,true) then Halt;
   end else }
   begin
    if DBkernel.ReadboolW('DBCheckType',ExtractFileName(dbname),true)=true then
    begin
     //TODO: ???
     {if GetDBType=DB_TYPE_BDE then
     ConvertDB(dbname);}
     DBkernel.WriteBoolW('DBCheckType',ExtractFileName(dbname),false);
    end;
    //checking RecordCount
    if DBkernel.ReadboolW('DBCheck',ExtractFileName(dbname),true)=true then
    begin
     if CommonDBSupport.GetRecordsCount(dbname)=0 then
     begin
      if SplashThread <> nil then
        SplashThread.Terminate;
      begin
       //ImportImages(dbname);
       DBkernel.WriteBoolW('DBCheck',ExtractFileName(dbname),false);
      end;
     end else
     begin
      DBkernel.WriteBoolW('DBCheck',ExtractFileName(dbname),false);
     end;
    end;
   end;
  end;
  LockCleaning:=false;
 end;
  TW.I.Start('FM -> HidefromTaskBar');
  HidefromTaskBar(Application.Handle);
  if not DBTerminating then
  TInternetUpdate.Create(False, False);
  TW.I.Start('TInternetUpdate - Create');
end;

procedure TFormManager.WMCopyData(var Msg: TWMCopyData);
var
  Param: TArStrings;
  Fids_: TArInteger;
  FileNameA, FileNameB, S: string;
  N, I: Integer;
  FormCont: TFormCont;
  B: TArBoolean;
  Info: TRecordsInfo;
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
    if ExtInMask(SupportedExt, GetExt(FileNameA)) then
    begin
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      FileNameA := LongFileName(FileNameA);
      GetFileListByMask(FileNameA, SupportedExt, Info, N, True);
      SlideShow.UseOnlySelf := True;
      ShowWindow(Viewer.Handle, SW_RESTORE);
      Viewer.Execute(Self, Info);
      Viewer.Show;
      ActivateBackgroundApplication(Viewer.Handle);
    end else if (AnsiUpperCase(FileNameA) <> '/EXPLORER') and CheckFileExistsWithMessageEx(FileNameA, False) then
    begin
      if GetExt(FileNameA) = 'DBL' then
      begin
        Dolphin_DB.LoadDblFromfile(FileNameA, Fids_, Param);
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
            SearchEdit.Text := ':ThFile(' + FilenameA + '):';
            DoSearchNow(Self);
            Show;
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
  inherited;
  F(FMainForms);
end;

initialization

FormManager:=nil;

end.
