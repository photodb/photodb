unit FormManegerUnit;

interface

uses
  GraphicCrypt, DB, UnitINI, UnitTerminationApplication,
  ThreadManeger, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,  uVistaFuncs, UnitDBNullQueryThread, AppEvnts, ExtCtrls,
  Dialogs, dolphin_db, Crypt, CommonDBSupport, UnitDBDeclare, UnitFileExistsThread,
  UnitDBCommon, uLogger, uConstants, uFileUtils, uTime;

type
  TFormManager = class(TForm)
    TerminateTimer: TTimer;
    CalledTimer: TTimer;
    ApplicationEvents1: TApplicationEvents;
    CheckTimer: TTimer;
    TimerCloseApplicationByDBTerminate: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TerminateTimerTimer(Sender: TObject);
    procedure CalledTimerTimer(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
  private
    FMainForms : array of TForm;
    FTemtinatedActions : TTemtinatedActions;  
    CanCheckViewerInMainForms : boolean;
    procedure ExitApplication;  
    procedure WMCopyData(var m : TMessage); message WM_COPYDATA;
    { Private declarations }
  public
    { Public declarations }
  published
   procedure RegisterMainForm(Value: TForm);
   procedure UnRegisterMainForm(Value: TForm);
   procedure RegisterActionCanTerminating(Value: TTemtinatedAction);
   procedure UnRegisterActionCanTerminating(Value: TTemtinatedAction);
   Procedure Run(LoadingThread : TThread);
   Procedure Close(Form : TForm);
   Procedure AppMinimize(Sender: TObject);
   Function MainFormsCount : Integer;
   Function IsMainForms(Form : TForm) : Boolean;
   Procedure CloseApp(Sender : TObject);
   Procedure Load;
  end;

var
  FormManager: TFormManager;
  DateTime : TDateTime;
  WasIde : Boolean = false;
  ExitAppl : Boolean = false;
  Running : Boolean = false;
  LockCleaning : boolean = false;  
  EnteringCodeNeeded : boolean;

implementation

uses Language, UnitCleanUpThread, ExplorerUnit, Searching, SlideShow,
DBSelectUnit, Activation, UnitUpdateDB, UnitInternetUpdate, About,
UnitConvertDBForm, UnitImportingImagesForm, UnitFileCheckerDB, UnitID,
UnitSelectDB, UnitFormCont, UnitGetPhotosForm, UnitLoadFilesToPanel;

{$R *.dfm}

{ TFormManager }

procedure InitializeDolphinDB;
var
  Reg : TBDRegistry;
  days : integer;
  d1 : tdatetime;

 procedure EnterCode;
 begin
  If DBTerminating then exit;
  if ActivateForm=nil then
  Application.CreateForm(TActivateForm,ActivateForm);
  TimerTerminated := true;
  ApplicationRuned := true;
  Application.Run;
 end;

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
    MessageBoxDB(FormManager.Handle,Format(TEXT_MES_UNKNOWN_ERROR_F,[e.Message]),TEXT_MES_ERROR ,TD_BUTTON_OK,TD_ICON_INFORMATION);
    Exit;
   end;
  end;
 end;
 if SafeMode then Exit;
end;

procedure TFormManager.Run(LoadingThread : TThread);
var
  Directory, s : String;
  ParamStr1, ParamStr2 : String;
  NewSearch : TSearchForm;
  IDList : TArInteger;
  FileList : TArStrings;
  i : integer;

  procedure CloseLoadingForm;
  begin
    LoadingThread.Terminate;
  end;

  function IsFile(s : string) : Boolean;
  var
    Ext : string;
  begin
    Result := False;
    s := Trim(s);
    if ExtractFileName(s) <> '' then
    begin
      Ext := ExtractFileExt(s);
      if (Ext <> '') and (Ext[1] = '.') then
        Result := True;
    end;
  end;

begin
try
 EventLog(':TFormManager::Run()...');
 DBKernel.WriteProperty('Starting','ApplicationStarted','1');
 if EnteringCodeNeeded then
 begin
  Running:=true;
  if ActivateForm=nil then
  Application.CreateForm(TActivateForm,ActivateForm);
  CloseLoadingForm;
  ActivateForm.Show;
  //ActivateApplication(ActivateForm.Handle);
  RegisterMainForm(ActivateForm);
  exit;
 end;
 if SafeMode then
 begin
  EventLog(':TFormManager::Run()/NewSearch...');
  NewSearch:=SearchManager.NewSearch;  
  CloseLoadingForm;
  NewSearch.Show;
  ActivateApplication(NewSearch.Handle);
  exit;
 end;
 ParamStr1:=ParamStr(1);
 ParamStr2:=Paramstr(2);
 Directory:=ParamStr2;
 UnFormatDir(Directory);
 Directory:=LongFileName(Directory);
 FormatDir(Directory);
 if FolderView then
 begin
  ParamStr1:='/EXPLORER';
  Directory:=GetDirectory(Application.Exename);
  UnformatDir(Directory);
 end;

 if UpcaseAll(ParamStr1)<>'/EXPLORER' then
 begin
  TW.I.Start('CheckFileExistsWithMessageEx - ParamStr1');
  if IsFile(ParamStr1) then
  begin
   if not ExtInMask(SupportedExt,GetExt(ParamStr1)) then
   begin
    NewSearch:=SearchManager.NewSearch;
    if CheckFileExistsWithMessageEx(ParamStr1,false) then
    begin
     if GetExt(ParamStr1)='IDS' then
     begin
      s:=LoadIDsFromfile(ParamStr1);
      NewSearch.SearchEdit.Text:=Copy(s,1,1000);
      NewSearch.DoSearchNow(nil);
     end;
     if GetExt(ParamStr1)='ITH' then
     begin
      s:=LoadIDsFromfile(ParamStr1);
      NewSearch.SearchEdit.Text:=':ThFile('+ParamStr1+'):';
      NewSearch.DoSearchNow(nil);
     end;
     if GetExt(ParamStr1)='DBL' then
     begin
      LoadDblFromfile(ParamStr1,IDList,FileList);
      s:='';
      for i:=1 to Length(IDList) do
      s:=s+IntToStr(IDList[i-1])+'$';
      NewSearch.SearchEdit.Text:=Copy(s,1,500);
      NewSearch.DoSearchNow(nil);
     end;
    end;  
    CloseLoadingForm;         
    NewSearch.Show;
  //  ActivateApplication(NewSearch.Handle);
   end else
   begin
    TW.I.Start('RUN TViewer');
    If Viewer=nil then
    Application.CreateForm(TViewer,Viewer);
    RegisterMainForm(Viewer);  
    CloseLoadingForm;
    Viewer.Show;
    TW.I.Start('ExecuteDirectoryWithFileOnThread');
    Viewer.ExecuteDirectoryWithFileOnThread(LongFileName(ParamStr1));
    TW.I.Start('ActivateApplication');
    //ActivateApplication(Viewer.Handle);
    //TW.I.Stop;
   end;
  end else
  begin
   //Default Form
   if DBKernel.ReadBool('Options','RunExplorerAtStartUp',false) then
   begin     
    TW.I.Start('RUN NewExplorer');
    With ExplorerManager.NewExplorer(False) do
    begin
     if DBKernel.ReadBool('Options','UseSpecialStartUpFolder',false) then
     SetPath(DBKernel.ReadString('Options','SpecialStartUpFolder')) else
     SetNewPathW(GetCurrentPathW,false); 
     CloseLoadingForm;   
     Show;
  //   ActivateApplication(Handle);
    end;
   end else
   begin               
   TW.I.Start('SearchManager.NewSearch');
    NewSearch:=SearchManager.NewSearch;
    Application.Restore; 
    CloseLoadingForm;
    NewSearch.Show;
  //  ActivateApplication(NewSearch.Handle);
   end;
  end;
 end else
 begin
  If DirectoryExists(Directory) then
  begin
   With ExplorerManager.NewExplorer(False) do
   begin
    SetPath(Directory);    
    CloseLoadingForm;
    Show;        
 //   ActivateApplication(Handle);
   end;
  end else
  begin
   Application.Restore;
   With SearchManager.NewSearch do
   begin
    Show;    
    CloseLoadingForm;       
  //  ActivateApplication(Handle);
   end;
  end;
 end;
 CheckTimer.Enabled := True;
 Running:=true;
 finally
   
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
  ShowWindow(Application.Handle, SW_HIDE);
 end;
end;

procedure TFormManager.FormPaint(Sender: TObject);
begin
// Showwindow(handle,SW_HIDE);
end;

procedure TFormManager.FormActivate(Sender: TObject);
begin
// Showwindow(handle,SW_HIDE);
end;

procedure TFormManager.Close(Form: TForm);
begin
 UnRegisterMainForm(Self);
end;

procedure TFormManager.RegisterMainForm(Value: TForm);
var
  i : integer;
  b : boolean;
begin
 if Value<>Viewer then
 CanCheckViewerInMainForms:=true;
 EventLog(':TFormManager::RegisterMainForm()...'+Value.Name);

 b:=false;
 For i:=0 to Length(FMainForms)-1 do
 if FMainForms[i]=Value then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FMainForms,Length(FMainForms)+1);
  FMainForms[Length(FMainForms)-1]:=Value;
 end;
end;

procedure TFormManager.UnRegisterMainForm(Value: TForm);
var
  i, j : integer;
begin           
 EventLog(':TFormManager::UnRegisterMainForm()...'+Value.Name);
 For i:=0 to Length(FMainForms)-1 do
 if FMainForms[i]=Value then
 begin
  For j:=i to Length(FMainForms)-2 do
  FMainForms[j]:=FMainForms[j+1];
  SetLength(FMainForms,Length(FMainForms)-1);
  break;
 end;

 try
 For i:=Length(FMainForms)-1 downto 1 do
  if not FMainForms[i].Visible then
  FMainForms[i].Close;
 except
  on e : Exception do EventLog(':TFormManager::UnRegisterMainForm() throw exception: '+e.Message);
 end;

end;

procedure TFormManager.ExitApplication;
Var
  i : Integer;
  FirstTick : Cardinal;
  ApplReadyForEnd : Boolean;
begin
 if ExitAppl then exit;
 ExitAppl:=true;
      
 EventLog(':TFormManager::ExitApplication()...');

 For i:=0 to Length(FMainForms)-1 do
 if not FMainForms[i].Visible then
 begin
  try
   FMainForms[i].Close;
  except
   on e : Exception do EventLog(':TFormManager::ExitApplication()/CloseForms throw exception: '+e.Message);
  end;
 end;

 //to allow run new copy
 IDForm.Caption:='';

 for i:=0 to Length(FTemtinatedActions)-1 do
 if (FTemtinatedActions[i].Options=TA_INFORM) or (FTemtinatedActions[i].Options=TA_INFORM_AND_NT) then
 begin
 end;
 Delay(10);
 ApplReadyForEnd:=false;
 for i:=0 to Length(FTemtinatedActions)-1 do
 FTemtinatedActions[i].TerminatedPointer^:=True;
 FirstTick:=GetTickCount;
 Repeat
  Delay(10);
  try
  if (GetTickCount-FirstTick)>5000 then break;
  ApplReadyForEnd:=true;
  for i:=0 to Length(FTemtinatedActions)-1 do
  if not FTemtinatedActions[i].TerminatedPointer^ then
  begin
   ApplReadyForEnd:=false;
   break;
  end;
  except
   break;
  end;
  if ApplReadyForEnd then Break;
 until false;
 TerminationApplication.Create(False);
 TerminateTimer.Enabled:=True;
 Application.Terminate;
 CalledTimer.Enabled:=True;
 DBKernel.WriteProperty('Starting','ApplicationStarted','0'); 
 EventLog(':TFormManager::ExitApplication()/OK...');
 EventLog('');                                                 
 EventLog('');          
 EventLog('');            
 EventLog('finalization:');
end;

procedure TFormManager.TerminateTimerTimer(Sender: TObject);
begin
  EventLog('TFormManager::TerminateTimerTimer()!');
  Halt;
end;

procedure TFormManager.CalledTimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormManager.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
 if WasIde then exit;
 if LockCleaning then exit;
 WasIde:=True;
 DBkernel.BackUpTable;
 if DBKernel.ReadBool('Options','AllowAutoCleaning',false) then
 CleanUpThread.Create(False);
end;

procedure TFormManager.FormDestroy(Sender: TObject);
var
  Found : integer;
  SearchRec : TSearchRec;
  f : TextFile;
begin

 Found := FindFirst(ProgramDir+'*.*', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(ProgramDir+SearchRec.Name) and (UpcaseAll(Copy(SearchRec.Name,1,4))='_QSQ') then
   begin
    Filesetattr(ProgramDir+SearchRec.Name,faHidden);
    Assignfile(f,ProgramDir+SearchRec.Name);
    {$I-}
    Erase(f);
    {$I+}
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);


 Found := FindFirst(GetAppDataDirectory + TempFolder+'*.*', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(GetAppDataDirectory+TempFolder+SearchRec.Name) and Dolphin_DB.ExtinMask(TempRAWMask,GetExt(SearchRec.Name)) then
   begin
    Filesetattr(GetAppDataDirectory+TempFolder+SearchRec.Name,faHidden);
    Assignfile(f,GetAppDataDirectory+TempFolder+SearchRec.Name);
    {$I-}
    Erase(f);
    {$I+}
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);
end;

procedure TFormManager.CheckTimerTimer(Sender: TObject);
begin
 if Running then
 begin
  if CanCheckViewerInMainForms then
  begin
   If (Length(FMainForms)=1) and (FMainForms[0]=Viewer) and (Viewer<>nil) then
   begin               
    CanCheckViewerInMainForms:=false;
    //to prevent many messageboxes
    CheckTimer.Enabled:=false;
    ActivateApplication(Viewer.Handle);
    if ID_YES = MessageBoxDB(Viewer.Handle,TEXT_MES_VIEWER_REST_IN_MEMORY_CLOSE_Q,TEXT_MES_WARNING,TD_BUTTON_YESNO,TD_ICON_WARNING) then
    begin
     SetLength(FMainForms,0);
     CheckTimer.Enabled:=true;
    end;
    CheckTimer.Enabled:=true;
   end;
  end;

  If Length(FMainForms)=0 then
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

procedure TFormManager.AppMinimize;
begin
 //ShowWindow(Application.Handle, SW_HIDE);
end;

function TFormManager.MainFormsCount: Integer;
begin
 Result:=Length(FMainForms);
end;

function TFormManager.IsMainForms(Form: TForm): Boolean;
var
  i : integer;
begin
 Result:=false;
 For i:=0 to length(FMainForms)-1 do
 if FMainForms[i]=Form then
 begin
  Result:=true;
  break
 end; 
end;

procedure TFormManager.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
 EventLog('Error ['+DateTimeToStr(Now)+'] = '+e.Message);
end;

procedure TFormManager.CloseApp(Sender: TObject);
var
  i : integer;
begin
 for i:=0 to Length(FMainForms)-1 do
 FMainForms[i].Close;
end;

procedure TFormManager.TimerCloseApplicationByDBTerminateTimer(
  Sender: TObject);
begin
 inherited Close;
end;

procedure TFormManager.Load;
var
  DBVersion : integer;
  DBFile : TPhotoDBFile;
begin
  TW.I.Start('FM -> Load');
 Caption:=DBID;
 CanCheckViewerInMainForms:=false;
 LockCleaning:=true;
 EnteringCodeNeeded := false;
 Running:=false;
 try
  TW.I.Start('FM -> InitializeDolphinDB');
  if not FolderView then
  InitializeDolphinDB else
  begin
   dbname:=GetDirectory(Application.ExeName)+'FolderDB.photodb';

   if FileExists(GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb') then
   dbname:=GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb';
  end;
 except
  on e : Exception do EventLog(':TFormManager::FormCreate() throw exception: '+e.Message);
 end;
 If DBTerminating then
 begin
  TimerCloseApplicationByDBTerminate.Enabled:=true;
 end;
 //ShowWindow(Handle,SW_HIDE);
 //FormManager.Visible:=false;
 //Application.ShowMainForm:=false;
 DateTime:=Now;
 If not SafeMode and not DBTerminating then
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
      if AboutForm<>nil then
      begin
       AboutForm.Release;
       if UseFreeAfterRelease then AboutForm.Free;
       AboutForm:=nil;
      end;
      begin
       ImportImages(dbname);
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
 HidefromTaskBar(Handle);
 if not DBTerminating then
 TInternetUpdate.Create(false,false);  
  TW.I.Stop;
end;

procedure TFormManager.WMCopyData(var m: TMessage);
var
  Param : TArStrings;
  fids_ : TArInteger;
  FileNameA, FileNameB, S : string;
  n, i : integer;
  FormCont : TFormCont;
  B : TArBoolean;
  Info : TRecordsInfo;
begin
 S :=PRecToPass(PCopyDataStruct(m.LParam)^.lpData)^.s;
 For i:=1 to Length(s) do
 If s[i]=#0 then
 begin
  FileNameA:=Copy(S,1,i-1);
  FileNameB:=Copy(S,i+1,Length(S)-i);
 end;
 if not CheckFileExistsWithMessageEx(FileNameA,false) then
 begin
  If AnsiUpperCase(FileNameA)='/EXPLORER' then
  begin
   If CheckFileExistsWithMessageEx(LongFileName(filenameB),true) then
   begin
    With ExplorerManager.NewExplorer(False) do
    begin
     SetPath(LongFileName(FileNameB));
     Show;                           
     ActivateApplication(Handle);
    end;
   end;
  end else
  begin
   if AnsiUpperCase(filenameA)='/GETPHOTOS' then
   if FileNameB<>'' then
   begin
    GetPhotosFromDrive(FileNameB[1]);
    Exit;
   end;
   With SearchManager.GetAnySearch do
   begin
    Show;
    ActivateApplication(Handle);
   end;
   Exit;
  end;
 end;
 If ExtInMask(SupportedExt,GetExt(FileNameA)) then
 begin
  if Viewer=nil then Application.CreateForm(TViewer, Viewer);
  FileNameA:=LongFileName(FileNameA);
  GetFileListByMask(FileNameA,SupportedExt,info,n,True);
  SlideShow.UseOnlySelf:=true;
  ShowWindow(Viewer.Handle,SW_RESTORE);
  Viewer.Execute(Self,info);
  Viewer.Show;
  ActivateApplication(Viewer.Handle);
 end else
 If (AnsiUpperCase(FileNameA)<>'/EXPLORER') and CheckFileExistsWithMessageEx(FileNameA,false) then
 begin
  if GetExt(FileNameA)='DBL' then
  begin
   Dolphin_DB.LoadDblFromfile(FileNameA,fids_,param);
   FormCont:=ManagerPanels.NewPanel;
   SetLength(B,0);
   LoadFilesToPanel.Create(false,param,fids_,B,false,true,FormCont);
   LoadFilesToPanel.Create(false,param,fids_,B,false,false,FormCont);     
   FormCont.Show;
   ActivateApplication(FormCont.Handle);
   exit;
  end;
  if GetExt(filenameA)='IDS' then
  begin
   fids_:=LoadIDsFromfileA(FileNameA);
   setlength(param,1);
   FormCont:=ManagerPanels.NewPanel;
   LoadFilesToPanel.Create(false,param,fids_,B,false,true,FormCont);
   FormCont.Show;
   ActivateApplication(FormCont.Handle);
  end else
  begin
   if GetExt(FileNameA)='ITH' then
   begin
    With SearchManager.NewSearch do
    begin
      SearchEdit.Text:=':ThFile('+filenameA+'):';
      DoSearchNow(Self);
      Show;                    
      ActivateApplication(Handle);
    end;
    exit;
   end else
   begin
    With SearchManager.GetAnySearch do
    begin
     Show;     
     ActivateApplication(Handle);
    end;
   end;
  end;
 end;
end;

initialization

FormManager:=nil;

end.
