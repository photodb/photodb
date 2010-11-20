unit UnitInstallThread;

interface

uses
  Windows, Dialogs, Variants, DB, Dolphin_DB, Classes, Sysutils, Forms,
  ActiveX, UnitGroupsWork, Registry, acDlgSelect, jpeg, Math,
  GraphicSelectEx, CommonDBSupport, UnitINI,uVistaFuncs,
  uLogger, uConstants, uFileUtils,
  UnitDBCommon;

type
  InstallThread = class(TThread)
  private
  FTypeOperation, FInfo, FinfoLabel  : String;
  FMaxSize : Integer;
  FProgress : integer;
  FProgressText : string;
  FBytesOfFilesCopied : integer;
  FErrorString : string;
  FCurrentFile : string;
  FErrorResult : integer;
  FInstallEnd : Boolean;
  FStrParam : String;
  FParamTempGroup : TGroups;
  FParamFOutRegGroups : TGroups;
  FParamFRegGroups : TGroups;
  FParamGroupsActions : TGroupsActionsW;

    { Private declarations }
  protected
    procedure Execute; override;
    procedure SetInfo;
    procedure SetProgress;
    procedure Progress(Position,Size:Longint);
    procedure Error;
    procedure ErrorExit;
    procedure ProgressFile;
    procedure ExitW;
    procedure DoPause;
    procedure IfPause;
    procedure ErrorA;
    procedure ErrorB;
    procedure errorC;
    procedure FilterGroupsSync;
  end;

  var pause, terminate_ : Boolean;
      OnDone : TNotifyEvent;
      FEndDirectory, FEndDBDirectory, FDBFile, InstUserName : string;
      InstallDone : Boolean;
      Exts : TInstallExts;
      QuickSelfInstall : boolean;

  const MaxShowPathLength = 40;

  procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory : string);
  procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);

implementation

uses Language, SetupProgressUnit, UnitGroupsReplace, CmpUnit;

{ InstallThread }

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory : string);
begin
 if not DBKernel.TestDB(FileName) then
 begin
  DBKernel.CreateDBbyName(FileName);
 end;
 CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory);
end;

procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);
var
  NewGroup : TGroup;
begin
 if not IsValidGroupsTableW(FileName) then
 begin
  if FileExists(CurrentImagesDirectory+'Images\Me.jpg') then
  begin
   try                       
    if InstUserName='' then NewGroup.GroupName:=GetWindowsUserName else
    NewGroup.GroupName:=InstUserName;

    NewGroup.GroupCode:=CreateNewGroupCode;
    NewGroup.GroupImage:=TJPEGImage.Create;
    NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory+'Images\Me.jpg');
    NewGroup.GroupDate:=Now;
    NewGroup.GroupComment:='';
    NewGroup.GroupFaces:='';
    NewGroup.GroupAccess:=0;
    NewGroup.GroupKeyWords:=NewGroup.GroupName;
    NewGroup.AutoAddKeyWords:=true;
    NewGroup.RelatedGroups:='';
    NewGroup.IncludeInQuickList:=True;
    AddGroupW(NewGroup,FileName);
   except
    on e : Exception do EventLog(':CreateExampleDB() throw exception: '+e.Message);
   end;
  end;
  if FileExists(CurrentImagesDirectory+'Images\Friends.jpg') then
  begin
   try
    NewGroup.GroupName:=TEXT_MES_FRIENDS;
    NewGroup.GroupCode:=CreateNewGroupCode;
    NewGroup.GroupImage:=TJPEGImage.Create;
    NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory+'Images\Friends.jpg');
    NewGroup.GroupDate:=Now;
    NewGroup.GroupComment:='';
    NewGroup.GroupFaces:='';
    NewGroup.GroupAccess:=0;
    NewGroup.GroupKeyWords:=TEXT_MES_FRIENDS;
    NewGroup.AutoAddKeyWords:=true;
    NewGroup.RelatedGroups:='';
    NewGroup.IncludeInQuickList:=True;
    AddGroupW(NewGroup,FileName);
   except
    on e : Exception do EventLog(':CreateExampleDB() throw exception: '+e.Message);
   end;
  end;
  if FileExists(CurrentImagesDirectory+'Images\Family.jpg') then
  begin
   try
    NewGroup.GroupName:=TEXT_MES_FAMILY;
    NewGroup.GroupCode:=CreateNewGroupCode;
    NewGroup.GroupImage:=TJPEGImage.Create;
    NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory+'Images\Family.jpg');
    NewGroup.GroupDate:=Now;
    NewGroup.GroupComment:='';
    NewGroup.GroupFaces:='';
    NewGroup.GroupAccess:=0;
    NewGroup.GroupKeyWords:=TEXT_MES_FAMILY;
    NewGroup.AutoAddKeyWords:=true;
    NewGroup.RelatedGroups:='';
    NewGroup.IncludeInQuickList:=True;
    AddGroupW(NewGroup,FileName);
   except
    on e : Exception do EventLog(':CreateExampleDB() throw exception: '+e.Message);
   end;
  end;
 end;
end;

procedure InstallThread.SetInfo;
begin
 SetupProgressUnit.SetupProgressForm.Label2.Caption:=FTypeOperation;
 SetupProgressUnit.SetupProgressForm.Label3.Caption:=FInfo;
 SetupProgressUnit.SetupProgressForm.Label4.Caption:=FinfoLabel;
 SetupProgressUnit.SetupProgressForm.DmProgress1.MaxValue:=FMaxSize;
 SetupProgressUnit.SetupProgressForm.DmProgress1.Text:=FProgressText;
end;

procedure InstallThread.SetProgress;
begin
 SetupProgressUnit.SetupProgressForm.DmProgress1.Position:=FProgress;
end;

procedure InstallThread.ProgressFile;
begin
 SetupProgressUnit.SetupProgressForm.Label4.Caption:=FCurrentFile;
end;

procedure InstallThread.Execute;
var
  r, _sqlexectext, KeyWords, KeyWords_, OldGroups, Groups, Groups_, FFname, CurrentDirectory, aDBName  : string;
  i, Size, SizeA : integer;
  OutTable, inTable : TDataSet;
  IsOldDataBase, ExistsGroupsFile, Res : boolean;
  FTempGroup, FRegGroups, FOutRegGroups : TGroups;
  GroupsActions : TGroupsActionsW;
  PlugInsFiles, ThemesFiles : TStringList;
  Reg : TRegIniFile;
begin

 IfPause;
 if not terminate_ then
 begin
  FTypeOperation:=TEXT_MES_REGISTRY_ENTRIES;
  FInfo:='';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT;
  FProgress:=0;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  IfPause;
  EventLog('Install/Registry installation...');
  if GetWindowsUserName <>'' then aDBName:=GetWindowsUserName else
  begin
   aDBName:=FEndDBDirectory+'PhotoDB.photodb';
  end;
  try
   //TODO: RegInstallApplication(FEndDirectory+'PhotoDB.exe',aDBName,InstUserName);
   if not PortableWork then
   begin
    //TODO: ExtInstallApplication(FEndDirectory+'PhotoDB.exe');
    //TODO: ExtInstallApplicationW(Exts,FEndDirectory+'PhotoDB.exe');
   end;
  except
   on e : Exception do EventLog(':Install() throw exception: '+e.Message);
  end;  
  IfPause;
  FTypeOperation:=TEXT_MES_CREATING_CHORTCUTS;
  FInfo:='';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT;
  FProgress:=0;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  EventLog('Install/CoInitialization...');
  Coinitialize(nil);

  FErrorResult:=ID_OK;
 end;

 EventLog('Install/DB installation...');
 if not terminate_ then
 begin
  FErrorResult:=id_ok;
  if DBKernel.TestDBEx(FDBFile)>0 then
  If DBKernel.TestDBEx(aDBName)>0 then
  begin
   FErrorString:=Format(TEXT_MES_DB_EXISTS__USE_NEW,[Mince(FDBFile,20)]);
   Synchronize(ErrorB);
  end;
  If FErrorResult<>ID_ABORT then
  if DBKernel.TestDBEx(FDBFile)>0 then
  begin

   FTypeOperation:=TEXT_MES_MOVING_DB_INIT+'...';
   FInfo:=TEXT_MES_CURRENT_REC;
   FinfoLabel:='';
   FProgressText:=TEXT_MES_PROGRESS_PR;
   FProgress:=0;
   Synchronize(SetInfo);
   Synchronize(SetProgress);

   if DBKernel.TestDBEx(aDBName)<=0 then
   begin
    DBKernel.CreateDBbyName(aDBName);
    DBKernel.AddDB(TEXT_MES_DEFAULT_DB_NAME,aDBName,FEndDirectory+'PhotoDB.exe,0',true);
   end;

   ExistsGroupsFile:=IsValidGroupsTableW(aDBName);
   if not ExistsGroupsFile then
   CreateGroupsTableW(aDBName);
   ExistsGroupsFile:=IsValidGroupsTableW(aDBName);
   FRegGroups:=GetRegisterGroupListW(aDBName,True, DBKernel.SortGroupsByName);

   FOutRegGroups:=GetRegisterGroupListW(FDBFile,True, DBKernel.SortGroupsByName);
   GroupsActions.IsActionForKnown:=false;
   GroupsActions.IsActionForUnKnown:=false;
   if DBKernel.TestDBEx(aDBName)>0 then
   begin

    If FErrorResult=ID_YES then
    IsOldDataBase:=true else IsOldDataBase:=false;
    try
     if not IsOldDataBase then
     begin
      CreateGroupsTableW(FDBFile);
      FOutRegGroups:=GetRegisterGroupListW(FDBFile,True, DBKernel.SortGroupsByName);
     end;
    except 
      on e : Exception do EventLog(':Install() throw exception: '+e.Message);
    end;
    if not IsOldDataBase then
    if (DBKernel.CreateDBbyName(aDBName)<>2) and (FErrorResult=ID_YES) then
    begin
     FErrorString:=TEXT_MES_CANT_CREATE_END_DB;
     Synchronize(ErrorExit);
    end;
    if not DBKernel.DBExists(aDBName) then
    DBKernel.AddDB(TEXT_MES_DEFAULT_DB_NAME,aDBName,FEndDirectory+'PhotoDB.exe,0',true);
   end else
   begin
    if (DBKernel.CreateDBbyName(aDBName)<>2) and (FErrorResult=ID_YES) then
    begin
     FErrorString:=TEXT_MES_CANT_CREATE_END_DB;
     Synchronize(ErrorExit);
    end;
    DBKernel.AddDB(TEXT_MES_DEFAULT_DB_NAME,aDBName,FEndDirectory+'PhotoDB.exe,0',true);
   end;
   begin
    IfPause;
    if not IsOldDataBase then
    begin
     GroupsActions.MaxAuto:=True;
    end else
    begin
     GroupsActions.MaxAuto:=False;
    end;
    dbname:=aDBName;
   end;
  end else
  begin
   //TODO: if db version old??? 
   CreateExampleDB(aDBName,FEndDirectory+'PhotoDB.exe,0',CurrentDirectory);
   DBKernel.AddDB(TEXT_MES_DEFAULT_DB_NAME,aDBName,FEndDirectory+'PhotoDB.exe,0',true);
   DBKernel.SetDataBase(aDBName);
  end;
 end;
 
  //CHECK APPDATA DIRECTORY
  EventLog('...CHECK APPDATA DIRECTORY...');
  if not DirectoryExists(GetAppDataDirectory) then
  begin
   try
    CreateDirA(GetAppDataDirectory);
   except
    MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(ERROR_CREATING_APP_DATA_DIRECTORY_MAY_NE_PROBLEMS,[GetAppDataDirectory]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
  end;
  EventLog('...CHECK APPDATA TEMP DIRECTORY...');
  if not DirectoryExists(GetAppDataDirectory+TempFolder) then
  begin
   try
    CreateDirA(GetAppDataDirectory+TempFolder);
   except
    MessageBoxDB(Dolphin_DB.GetActiveFormHandle,Format(ERROR_CREATING_APP_DATA_DIRECTORY_TEMP_MAY_BE_PROBLEMS,[GetAppDataDirectory+TempFolder]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   end;
  end;


 Synchronize(exitW);
end;

procedure InstallThread.Progress(Position, Size: Integer);
begin
//
end;

procedure InstallThread.error;
begin
 MessageBoxDB(GetActiveFormHandle,FErrorString,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
end;

procedure InstallThread.errorA;
begin
 FErrorResult:=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,FErrorString,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_ERROR);
end;

procedure InstallThread.errorC;
begin
 FErrorResult:=MessageBoxDB(Dolphin_DB.GetActiveFormHandle,FErrorString,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
end;

procedure InstallThread.errorB;
begin
 FErrorResult:=Dolphin_DB.MessageBoxDB(0,FErrorString,TEXT_MES_CONFIRMATION,TD_BUTTON_CANCEL+TD_BUTTON_NO+TD_BUTTON_YES,TD_ICON_WARNING);
 // MessageDlg(FErrorString, mtConfirmation, [mbAbort,mbYes,mbNo], 0)
end;

procedure InstallThread.ErrorExit;
begin
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,FErrorString,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 SetupProgressForm.OnCloseQuery:=nil;
 terminate_:=true;
end;

procedure InstallThread.ExitW;
var
  si : TStartupInfo;
  p  : TProcessInformation;
  S : String;
begin
 //DoEndInstall;
 InstallDone:=true;
 SetupProgressUnit.SetupProgressForm.OnClose:=nil;
 SetupProgressUnit.SetupProgressForm.OnCloseQuery:=nil;
 SetupProgressUnit.SetupProgressForm.Close;
 if not FInstallEnd then exit;
 S:=FEndDirectory;
 UnFormatDir(S);
 FillChar( Si, SizeOf( Si ) , 0 );
 with Si do begin
  cb := SizeOf( Si);
  dwFlags := startf_UseShowWindow;
  wShowWindow := 4;
 end;
 CreateProcess(nil, PWideChar('"'+FEndDirectory+'PhotoDB.exe" "/SLEEP"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil, PWideChar(S),si,p);
end;

procedure InstallThread.DoPause;
begin
 Repeat
  Sleep(50);
 until not pause or terminate_;
end;

procedure InstallThread.IfPause;
begin
 If Pause then DoPause;
end;

procedure InstallThread.FilterGroupsSync;
begin
 FilterGroupsW(FParamTempGroup,FParamFOutRegGroups,FParamFRegGroups,FParamGroupsActions,FStrParam);
end;

initialization

end.
