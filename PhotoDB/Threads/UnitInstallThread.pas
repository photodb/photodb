unit UnitInstallThread;

interface

uses
  Windows, Dialogs, Variants, DB, Dolphin_DB, Classes, Sysutils, Forms,
  ActiveX, UnitGroupsWork, Registry, acDlgSelect, jpeg, Math,
  GraphicSelectEx, CommonDBSupport, UnitINI,uVistaFuncs,
  WindowsIconCacheTools, uLogger, uConstants, uFileUtils,
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
  FQuery, FSetQuery : TDataSet;//TQuery;
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
    procedure Post(SQL : string);
  end;

  var pause, terminate_ : Boolean;
      OnDone : TNotifyEvent;
      FEndDirectory, FEndDBDirectory, FDBFile, InstUserName : string;
      MovePrivate : Boolean;
      InstallDone : Boolean;
      Exts : TInstallExts;
      InstallBDEAnyway : Boolean;
      DBType : integer;
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
    if InstUserName='' then NewGroup.GroupName:=Dolphin_DB.InstalledUserName else
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
  NewGroup : TGroup;
  Reg : TRegIniFile;

Procedure AddCurrentFile;
begin
 try
     Sleep(1);
     InTable.Append ;
     IfPause;
     FFname:=OutTable.FieldByName('Name').AsString;
     FCurrentFile:=Format(TEXT_MES_ADDING_INSTALL_FORMAT,[inttostr(OutTable.RecNo),inttostr(FMaxSize),Copy(FFname,1,max(length(FFname),16))]);
     Synchronize(ProgressFile);
     InTable.FieldByName('Name').AsString:=FFName;
     InTable.FieldByName('FFileName').AsString:=OutTable.FieldByName('FFileName').AsString;
     InTable.FieldByName('Comment').AsString:=OutTable.FieldByName('Comment').AsString;
     InTable.FieldByName('DateToAdd').AsDateTime:=OutTable.FieldByName('DateToAdd').AsDateTime;
     InTable.FieldByName('Owner').AsString:=OutTable.FieldByName('Owner').AsString;
     InTable.FieldByName('Rating').AsInteger:=OutTable.FieldByName('Rating').AsInteger;
     InTable.FieldByName('Thum').AsVariant:=OutTable.FieldByName('Thum').AsVariant;
     InTable.FieldByName('FileSize').AsInteger:=OutTable.FieldByName('FileSize').AsInteger;
     InTable.FieldByName('KeyWords').AsString:=OutTable.FieldByName('KeyWords').AsString;
     InTable.FieldByName('StrTh').AsString:=OutTable.FieldByName('StrTh').AsString;
     If fileexists(InTable.FieldByName('FFileName').AsString) then
     InTable.FieldByName('Attr').AsInteger:=db_attr_norm else
     InTable.FieldByName('Attr').AsInteger:=db_attr_not_exists;
     InTable.FieldByName('Attr').AsInteger:=OutTable.FieldByName('Attr').AsInteger;
     if OutTable.FindField('Collection')<>nil then
     InTable.FieldByName('Collection').AsString:=OutTable.FieldByName('Collection').AsString;
     InTable.FieldByName('Access').AsInteger:=OutTable.FieldByName('Access').AsInteger;
     InTable.FieldByName('Width').AsInteger:=OutTable.FieldByName('Width').AsInteger;
     InTable.FieldByName('Height').AsInteger:=OutTable.FieldByName('Height').AsInteger;
     if OutTable.FindField('Colors')<>nil then
     InTable.FieldByName('Colors').AsInteger:=OutTable.FieldByName('Colors').AsInteger;
     if OutTable.FindField('Rotated')<>nil then
     InTable.FieldByName('Rotated').AsInteger:=OutTable.FieldByName('Rotated').AsInteger;
     if OutTable.FindField('IsDate')<>nil then
     InTable.FieldByName('IsDate').AsBoolean:=OutTable.FieldByName('IsDate').AsBoolean;
     if OutTable.FindField('Groups')<>nil then
     begin
      Groups := InTable.FieldByName('Groups').AsString;
      OldGroups := Groups;
      Groups_ := OutTable.fieldByName('Groups').AsString;
      FTempGroup:=EnCodeGroups(Groups_);
      FParamTempGroup := FTempGroup;
      FParamFOutRegGroups := FOutRegGroups;
      FParamFRegGroups := FRegGroups;
      FParamGroupsActions :=  GroupsActions;
      FStrParam:=FEndDBDirectory+'PhotoDB.DB';
      Synchronize(FilterGroupsSync);
      GroupsActions:=FParamGroupsActions;
      FRegGroups:=FParamFRegGroups;
      InTable.FieldByName('Groups').AsString:=CodeGroups(FParamTempGroup);
     end;
     if OutTable.FindField('Include')<>nil then
     InTable.FieldByName('Include').AsBoolean:=OutTable.FieldByName('Include').AsBoolean;
     if OutTable.FindField('Links')<>nil then
     InTable.FieldByName('Links').AsString:=OutTable.FieldByName('Links').AsString;
     if OutTable.FindField('aTime')<>nil then
     InTable.FieldByName('aTime').AsDateTime:=OutTable.FieldByName('aTime').AsDateTime;
     if OutTable.FindField('IsTime')<>nil then
     InTable.FieldByName('IsTime').AsBoolean:=OutTable.FieldByName('IsTime').AsBoolean;

 except    
  on e : Exception do EventLog(':AddCurrentFile() throw exception: '+e.Message);
 end;
end;

Procedure RelodDllNames(var List : TStringList; out AllSize : Integer);
var
  Found  : integer;
  SearchRec : TSearchRec;
  Directory : string;
begin
 AllSize:=0;
 FInstallEnd:=false;
 List:= TStringList.Create;
 List.Clear;
 Directory:=ProgramDir;
 FormatDir(Directory);
 Directory:=Directory+PlugInImagesFolder;
 Found := FindFirst(Directory+'*.jpgc', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(Directory+SearchRec.Name) then
   try
    if ValidJPEGContainer(Directory+SearchRec.Name) then
    List.Add(Directory+SearchRec.Name);
   except
    on e : Exception do EventLog(':RelodDllNames() throw exception: '+e.Message);
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 SysUtils.FindClose(SearchRec);
end;

procedure CopyFileByStreams(Source, Target: String);

var
  SourceStream: TFileStream;
  TargetStream: TFileStream;

begin
  SourceStream := TFileStream.Create(Source, fmShareDenyWrite);
  try
    TargetStream := TFileStream.Create(Target, fmCreate);
      try
        TargetStream.CopyFrom(SourceStream, 0);
        FileSetDate(TargetStream.Handle, FileGetDate(SourceStream.Handle));
      finally
        TargetStream.Free;
      end;
    finally
      SourceStream.Free;
    end;
end;

Procedure RelodThemesNames(var List : TStringList; out AllSize : Integer);
var
  Found  : integer;
  SearchRec : TSearchRec;
  Directory: string;
begin
 AllSize:=0;
 List:= TStringList.Create;
 List.Clear;
 Directory:=ProgramDir;
 FormatDir(Directory);
 Directory:=Directory+ThemesDirectory;
 Found := FindFirst(Directory+'*.dbc', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(Directory+SearchRec.Name) then
   begin
    FCurrentFile:=Mince(Directory+SearchRec.Name,MaxShowPathLength);
    Synchronize(ProgressFile);
    List.Add(Directory+SearchRec.Name);
    Inc(AllSize,GetFileSizeByName(Directory+SearchRec.Name));
    IfPause;
   end;
  end;
  Found := SysUtils.FindNext(SearchRec);
 end;
 SysUtils.FindClose(SearchRec);
end;

procedure DeleteOlderShortcuts;
begin
//[BEGIN] Removing Shortcuts olders versions
//1.75
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile_1_75);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_75+'\'+ProgramShortCutFile_1_75);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_75+'\'+HelpShortCutFile_1_75);
  except
  end;
  try
   SysUtils.RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_75);
  except
  end;
//1.8
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile_1_8);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_8+'\'+ProgramShortCutFile_1_8);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_8+'\'+HelpShortCutFile_1_8);
  except
  end;
  try
   SysUtils.RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_8);
  except
  end;
//1.9
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile_1_9);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_9+'\'+ProgramShortCutFile_1_9);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_9+'\'+HelpShortCutFile_1_9);
  except
  end;
  try
   SysUtils.RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_1_9);
  except
  end;

//2.0
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile_2_0);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_0+'\'+ProgramShortCutFile_2_0);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_0+'\'+HelpShortCutFile_2_0);
  except
  end;
  try
   SysUtils.RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_0);
  except
  end;

//2.1
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile_2_1);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_1+'\'+ProgramShortCutFile_2_1);
  except
  end;
  try
   SysUtils.DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_1+'\'+HelpShortCutFile_2_1);
  except
  end;
  try
   SysUtils.RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath_2_1);
  except
  end;
  Reg.free;
//[END] Removing olders versions
end;

begin
 EventLog('Install thread begin...');
 SetupProgressUnit.FPause:=@Pause;
 SetupProgressUnit.fInstallDone:=@InstallDone;
 IsOldDataBase:=false;
 InstallDone:=false;
 CurrentDirectory:=GetDirectory(Application.ExeName);
 FMaxSize:=0;
 FBytesOfFilesCopied:=0;
 FMaxSize:=FMaxSize+GetFileSizeByName(Application.ExeName);
 FTypeOperation:=TEXT_MES_SEARCH_PLUGINS;
 FInfo:='...';
 FinfoLabel:='';
 FProgressText:=TEXT_MES_WAIT_MIN;
 FProgress:=0;
 Synchronize(SetInfo);
 Synchronize(SetProgress);
 IfPause;
 RelodDllNames(PlugInsFiles,SizeA);
 inc(FMaxSize,SizeA);
 RelodThemesNames(ThemesFiles,SizeA);
 inc(FMaxSize,SizeA);
 IfPause;
 EventLog('Install/Initialization...');
 if not QuickSelfInstall then
 for i:=0 to FilesCount-1 do
 begin
  IfPause;
  if terminate_ then break;
  size:=GetFileSizeByName(CurrentDirectory+FileList[i]);
  if DirectoryExists(CurrentDirectory+FileList[i]) then size:=GetDirectorySize(CurrentDirectory+FileList[i]);
  if Size<10 then
  if InstallFileNeeds[i] then
  begin
   FErrorString:=TEXT_MES_FILE_NOT_FOUND+':'+#13+filelist[i];
   Synchronize(ErrorExit);
  end;
  FMaxSize:=FMaxSize+size;
 end;  
 EventLog('Install/FileSizes complite...');
 Pause:=false;
 terminate_:=false;
 FormatDir(FEndDirectory);
 FormatDir(FEndDBDirectory);
 FTypeOperation:=TEXT_MES_INST_BDE;
 FInfo:='...';
 FinfoLabel:='';
 FProgressText:=TEXT_MES_WAIT_MIN;
 FProgress:=0;
 Synchronize(SetInfo);
 Synchronize(SetProgress);
 If terminate_ then
 begin
  InstallDone:=true;
  Synchronize(exitW);
  exit;
 end;
 FTypeOperation:=TEXT_MES_COPYING_NEW_FILES;
 FInfo:=TEXT_MES_CURRENT_FILE;
 FinfoLabel:='';
 FProgressText:=TEXT_MES_COPYING_PR;
 FProgress:=0;     
 Synchronize(SetInfo);
 Synchronize(SetProgress);
 FCurrentFile:=Mince(FEndDirectory+'PhotoDB.exe',MaxShowPathLength);
 Synchronize(ProgressFile);
 IfPause;
 EventLog('Install/Set information complite...');
 try
  if not QuickSelfInstall then
  CopyFileByStreams(Application.ExeName,FEndDirectory+'PhotoDB.exe');
 except
  on e : Exception do EventLog(':Install() throw exception: '+e.Message);
 end;
 FBytesOfFilesCopied:=FBytesOfFilesCopied+GetFileSizeByName(Application.ExeName);
 IfPause;
 FProgress:=FBytesOfFilesCopied;

 EventLog('Install/Begin copying files complite...');
 try
  if not QuickSelfInstall then
  For i:=0 to FilesCount-1 do
  begin
   IfPause;
   if terminate_ then break;
   FCurrentFile:=Mince(FEndDirectory+filelist[i],MaxShowPathLength);
   Synchronize(ProgressFile);
   Synchronize(SetProgress);
   if FileOptions[i] then
   begin
    if FileExists(CurrentDirectory+FileList[i]) then
    Dolphin_DB.WindowsCopyFileSilent(CurrentDirectory+FileList[i],FEndDirectory+FileList[i]);
    if DirectoryExists(CurrentDirectory+FileList[i]) then
    Dolphin_DB.WindowsCopyFileSilent(CurrentDirectory+FileList[i],FEndDirectory);
   end else
   begin
    Dolphin_DB.WindowsCopyFileSilent(CurrentDirectory+FileList[i],FEndDBDirectory+FileList[i]);
   end;
   inc(FBytesOfFilesCopied,GetFileSizeByName(CurrentDirectory+FileList[i]));
   FProgress:=FBytesOfFilesCopied;
  end;
  CreateDirA(FEndDirectory+PlugInImagesFolder);   
 except
  on e : Exception do EventLog(':Install() throw exception: '+e.Message);
 end;   
 EventLog('Install/Begin copying PlugIns complite...');
 try
  if not QuickSelfInstall then
  For i:=0 to PlugInsFiles.Count-1 do
  begin
   IfPause;
   if terminate_ then break;
   FCurrentFile:=Mince(FEndDirectory+PlugInImagesFolder+ExtractFileName(PlugInsFiles[i]),MaxShowPathLength);
   Synchronize(ProgressFile);
   Synchronize(SetProgress);
   CopyFileByStreams(PlugInsFiles[i],FEndDirectory+PlugInImagesFolder+ExtractFileName(PlugInsFiles[i]));
   inc(FBytesOfFilesCopied,GetFileSizeByName(PlugInsFiles[i]));
   FProgress:=FBytesOfFilesCopied;
  end;       
  CreateDirA(FEndDirectory+ThemesDirectory);
 except
  on e : Exception do EventLog(':Install() throw exception: '+e.Message);
 end;
 EventLog('Install/Begin copying themes...');
 try
  if not QuickSelfInstall then
  for i:=0 to ThemesFiles.Count-1 do
  begin
   IfPause;
   if terminate_ then break;
   FCurrentFile:=Mince(FEndDirectory+ThemesDirectory+ExtractFileName(ThemesFiles[i]),MaxShowPathLength);
   Synchronize(ProgressFile);
   Synchronize(SetProgress);
   CopyFileByStreams(ThemesFiles[i],FEndDirectory+ThemesDirectory+ExtractFileName(ThemesFiles[i]));
   inc(FBytesOfFilesCopied,GetFileSizeByName(ThemesFiles[i]));
   FProgress:=FBytesOfFilesCopied;
  end;
 except
  on e : Exception do EventLog(':Install() throw exception: '+e.Message);
 end;   
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
  if GetDefaultDBName<>'' then aDBName:=GetDefaultDBName else
  begin
   if DBType=1 then
   aDBName:=FEndDBDirectory+'PhotoDB.DB' else
   aDBName:=FEndDBDirectory+'PhotoDB.photodb';
  end; 
  try
   RegInstallApplication(FEndDirectory+'PhotoDB.exe',aDBName,InstUserName);
   if not PortableWork then
   begin
    ExtInstallApplication(FEndDirectory+'PhotoDB.exe');
    ExtInstallApplicationW(Exts,FEndDirectory+'PhotoDB.exe');
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
  if not PortableWork then
  begin
   EventLog('Install/Deleting shortcuts...');
   DeleteOlderShortcuts;
   IfPause;
   try
    EventLog('Install/Creating shortcuts...');
    CreateShortcutW(FEndDirectory+'PhotoDB.exe',ProgramShortCutFile,_PROGRAMS,StartMenuProgramsPath,FEndDirectory,'',TEXT_MES_DISCRIPTION);
    IfPause;
    if FileExists(FEndDirectory+'\Help\Index.htm') then
    CreateShortcutW(FEndDirectory+'\Help\Index.htm',HelpShortCutFile,_PROGRAMS,StartMenuProgramsPath,FEndDirectory,'',TEXT_MES_HELP) else
    if FileExists(FEndDirectory+'\Help\Index.html') then
    CreateShortcutW(FEndDirectory+'\Help\Index.html',HelpShortCutFile,_PROGRAMS,StartMenuProgramsPath,FEndDirectory,'',TEXT_MES_HELP);
    IfPause;
    CreateShortcutW(FEndDirectory+'PhotoDB.exe',ProgramShortCutFile,_DESKTOP,'',FEndDirectory,'',TEXT_MES_DISCRIPTION);
    IfPause;
   except
    on e : Exception do EventLog(':Install() throw exception: '+e.Message);
   end;
  end;
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
   FRegGroups:=GetRegisterGroupListW(aDBName,True);

   FOutRegGroups:=GetRegisterGroupListW(FDBFile,True);
   GroupsActions.IsActionForKnown:=false;
   GroupsActions.IsActionForUnKnown:=false;
   if DBKernel.TestDBEx(aDBName)>0 then
   begin

    FSetQuery:=GetQuery(aDBName);
    If FErrorResult=ID_YES then
    IsOldDataBase:=true else IsOldDataBase:=false;
    try
     if not IsOldDataBase then
     begin
      CreateGroupsTableW(FDBFile);
      FOutRegGroups:=GetRegisterGroupListW(FDBFile,True);
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
    FTypeOperation:=TEXT_MES_MOVING_DB+'...';
    FInfo:=TEXT_MES_CURRENT_REC;
    FinfoLabel:='';
    FProgressText:=TEXT_MES_PROGRESS_PR;
    FProgress:=0;
    Synchronize(SetInfo);
    Synchronize(SetProgress);
    OutTable:= GetTable(FDBFile,DB_TABLE_IMAGES);
    InTable := GetTable(aDBName,DB_TABLE_IMAGES);

    OutTable.Active:=true;
    InTable.Active:=true;
    FMaxSize:=OutTable.RecordCount;
    Synchronize(SetInfo);
    OutTable.First;
    IfPause;
    Repeat
     FProgress:=OutTable.RecNo;
     Synchronize(SetProgress);
     If (OutTable.FieldByName('Access').AsInteger<>db_access_private) or MovePrivate then
     If not IsOldDataBase then
     begin
      AddCurrentFile;
     end else
     begin
      FFname:=OutTable.FieldByName('Name').AsString;
      FCurrentFile:=Format(TEXT_MES_ADDING_INSTALL_FORMAT,[inttostr(OutTable.RecNo),inttostr(FMaxSize),Copy(FFname,1,max(length(FFname),16))]);
      Synchronize(ProgressFile);
      FQuery:=GetQuery(aDBName);
      SetSQL(FQuery,'SELECT * FROM '+GetTableNameByFileName(aDBName)+' WHERE StrTh=:StrTh');

      SetStrParam(FQuery,0,OutTable.FieldByName('StrTh').AsString);

      FQuery.Active:=true;
      If FQuery.RecordCount=0 then
      begin
       AddCurrentFile;
      end else
      begin
       KeyWords:= FQuery.FieldByName('KeyWords').AsString;
       KeyWords_:= OutTable.FieldByName('KeyWords').AsString;
       if AddWordsA( KeyWords_, KeyWords) then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set KeyWords="'+KeyWords+'"';
        _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.FieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
       end;
       Groups := FQuery.FieldByName('Groups').AsString;
       OldGroups := Groups;
       Groups_ := OutTable.fieldByName('Groups').AsString;
       FTempGroup:=EnCodeGroups(Groups_);
       FParamTempGroup := FTempGroup;
       FParamFOutRegGroups := FOutRegGroups;
       FParamFRegGroups := FRegGroups;
       FParamGroupsActions :=  GroupsActions;
       //FStrParam:=GroupsTableFileNameW(aDBName);   
       FStrParam:=aDBName;
       Synchronize(FilterGroupsSync);
       GroupsActions:=FParamGroupsActions;
       Groups_:=CodeGroups(FParamTempGroup);
       if not CompareGroups(OldGroups,Groups_) then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set Groups="'+Groups_+'"';
        _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.FieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
       end;
       if (FQuery.FieldByName('Rotated').AsInteger=0) and
       (OutTable.FieldByName('Rotated').AsInteger>0) then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set Rotated='+inttostr(OutTable.fieldByName('Rotated').AsInteger)+'';
        _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
       end;
       if (FQuery.FieldByName('Rating').AsInteger=0) and
       (OutTable.FieldByName('Rating').AsInteger>0) then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set Rating='+inttostr(OutTable.FieldByName('Rating').AsInteger)+'';
        _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.FieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
       end;
       if (FQuery.fieldByName('IsDate').AsBoolean=False) and
       (OutTable.fieldByName('IsDate').AsBoolean=True) then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set IsDate=:IsDate, DateToAdd=:DateToAdd';
        _sqlexectext:=_sqlexectext+ ' Where ID='+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
        SetSQL(FSetQuery,_sqlexectext);
        SetBoolParam(FSetQuery,0,True);
        SetDateParam(FSetQuery,'DateToAdd',OutTable.fieldByName('DateToAdd').AsDateTime);
        ExecSQL(FSetQuery);
       end;
       Res:=false;
       if Length(OutTable.fieldByName('Comment').AsString)>1 then
       begin
        if Length(FQuery.fieldByName('Comment').AsString)>1 then
        begin
         res:=not SimilarTexts(OutTable.fieldByName('Comment').AsString,FQuery.fieldByName('Comment').AsString);
         r:=FQuery.fieldByName('Comment').AsString+' P.S. '+OutTable.fieldByName('Comment').AsString
        end else
        begin
         res:=true;
         r:=OutTable.fieldByName('Comment').AsString;
        end;
       end;
       if res then
       begin
        _sqlexectext:='Update '+GetTableNameByFileName(aDBName);
        _sqlexectext:=_sqlexectext+ ' Set Comment ="'+NormalizeDBString(r)+'"';
       _sqlexectext:=_sqlexectext+ ' Where ID = '+inttostr(FQuery.fieldByName('ID').AsInteger)+'';
        post(_sqlexectext);
       end;
      end;
      FreeDS(FQuery);
     end;
     OutTable.Next;
    Until OutTable.Eof;
    FreeDS(InTable);
    FreeDS(OutTable);
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

 if not terminate_ then
 begin
  InstallDone:=true;
  FInstallEnd:=true;
 end;
 FTypeOperation:=TEXT_MES_UPDATING_SYSTEM_INFO;
 FInfo:='';
 FinfoLabel:='';
 FProgressText:=TEXT_MES_WAIT;
 FProgress:=0;
 Synchronize(SetInfo);
 Synchronize(SetProgress);
 try
  RebuildIconCacheAndNotifyChanges;
 except
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
 DoEndInstall;
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
 CreateProcess(nil,PChar('"'+FEndDirectory+'PhotoDB.exe" "/SLEEP"'),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PChar(S),si,p);
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

procedure InstallThread.Post(SQL: string);
begin
 FSetQuery.Active:=False;
 SetSQL(FSetQuery,sql);
 ExecSQL(FSetQuery);
end;

initialization

end.
