unit UnitUnInstallThread;

interface

uses
  ExplorerTypes, Forms, ShellApi, Dialogs, Registry, SelfDeleteUnit,
  Windows, SysUtils, Dolphin_DB, Classes, UnitGroupsWork,  uVistaFuncs,
  GraphicSelectEx, WindowsIconCacheTools;

  type TUnInstallOptions = record
   Program_Files : boolean;
   DataBase_Files : boolean;
   Registry_Entries : boolean;
   Chortcuts : boolean;
   Themes : boolean;
   PlugIns : boolean;   
   Scripts : boolean;
   Actions : boolean;
  end;

type
  UnInstallThread = class(TThread)
  private
  FTypeOperation, FInfo, FinfoLabel  : String;
  FMaxSize : Integer;
  FProgress : integer;
  FProgressText : string;
  FErrorString : string;
  FExplorerFolders : TExplorerFolders;
    { Private declarations }
  protected
    procedure SetInfo;
    procedure SetProgress;
    procedure exit;
    procedure error;
    procedure Execute; override;
  end;

  var Options : TUnInstallOptions;
      pause, terminame : boolean;
      InstallDone : boolean;

implementation

uses SetupProgressUnit, Language;

{ UnInstallThread }

procedure UnInstallThread.SetInfo;
begin
 If SetupProgressUnit.SetupProgressForm=nil then exit;
 SetupProgressUnit.SetupProgressForm.Label2.Caption:=FTypeOperation;
 SetupProgressUnit.SetupProgressForm.Label3.Caption:=FInfo;
 SetupProgressUnit.SetupProgressForm.Label4.Caption:=FinfoLabel;
 SetupProgressUnit.SetupProgressForm.DmProgress1.MaxValue:=FMaxSize;
 SetupProgressUnit.SetupProgressForm.DmProgress1.Text:=FProgressText;
end;

procedure UnInstallThread.SetProgress;
begin
 If SetupProgressUnit.SetupProgressForm=nil then exit;
 SetupProgressUnit.SetupProgressForm.DmProgress1.Position:=FProgress;
end;

procedure UnInstallThread.Execute;
var
  Found, i:integer;
  s, fdir, fdbfile, fdbdir : string;
  freg : Tregistry;
  Reg : TRegIniFile;
  f1 : textFile;
  SearchRec : TSearchRec;

  dllhandle : integer;
  Buffer: array [0..1023] of char;

begin
 InstallDone:=false;
 SetupProgressUnit.FPause:=@Pause;
 SetupProgressUnit.fInstallDone:=@InstallDone;
 freg:=Tregistry.Create;
 try
  fReg.RootKey:=HKEY_INSTALL;
  freg.OpenKey(RegRoot,true);
  fdir:=GetDirectory(freg.ReadString('DataBase'));
  fdbfile:=freg.ReadString('DBDefaultName');
  fDBDir:=GetDirectory(fDBfile);
  fDBFile:=GetFileName(fDBfile);
  for i:=length(fDBfile) downto 1 do
  if fDBfile[i]='.' then
  begin
   fDBFile:=Copy(fDBFile,1,i);
   break;
  end;
  except
 end;
 freg.free;
 FormatDir(fDBDir);
 FormatDir(fdir);
 If Options.Program_Files then
 begin
  FTypeOperation:=TEXT_MES_DELETING_FILES;
  FInfo:=TEXT_MES_CURRENT_FILE;
  FinfoLabel:='';
  FProgressText:=TEXT_MES_DELETING_PR;
  FProgress:=0;
  FMaxSize:=FilesCount;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  DeleteFile(GetAppDataDirectory+'\dbboot.dat');
  Sleep(100);
  FProgress:=1;
  Synchronize(SetProgress);
  For i:=0 to FilesCount-1 do
  begin
   try
    if FileExists(fdir+filelist[i]) then
    Deletefile(fdir+filelist[i]);
    if DirectoryExists(fdir+filelist[i]) then
    DelDir(fdir+filelist[i],'|HTM|HTML|JPG|JPEG|GIF|');
   except
   end;
   FProgress:=i+1;
   Synchronize(SetProgress);
  end;
 end;
 If Options.DataBase_Files then
 begin
  FTypeOperation:=TEXT_MES_DELETING_DB_FILES;
  FInfo:=TEXT_MES_CURRENT_FILE;
  FinfoLabel:='';
  FProgressText:=TEXT_MES_DELETING_PR;
  FProgress:=0;
  FMaxSize:=5;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  For i:=1 to 10 do
  begin
   try
    DeleteFile(fdbdir+fdbfile+DBFilesExt[i-1]);
    DeleteFile(GroupsTableFileNameW(fdbdir+fdbfile+DBFilesExt[i-1]));
   except
   end;
   FProgress:=i;
   Synchronize(SetProgress);
  end;
  try
   RmDir(fdbdir);
  except
  end;
 end;
 If Options.Registry_Entries then
 begin
  FTypeOperation:=TEXT_MES_DELETING_REG_ENTRIES;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  DeleteRegistryEntries;
  ExtUnInstallApplicationW;
 end;
 If Options.Chortcuts then
 begin
  FTypeOperation:=TEXT_MES_DELETING_CHORTCUTS;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
   DeleteFile(Reg.ReadString('Shell Folders', 'Desktop', '')+'\'+ProgramShortCutFile);
  except
  end;
  try
   DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath+'\'+ProgramShortCutFile);
  except
  end;
  try
   DeleteFile(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath+'\'+HelpShortCutFile);
  except
  end;
  try
   RemoveDir(Reg.ReadString('Shell Folders', 'Programs', '')+'\'+StartMenuProgramsPath);
  except
  end;
  Reg.free;
 end;
 If Options.Themes then
 begin
  FTypeOperation:=TEXT_MES_DELETING_THEMES;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  Found := FindFirst(fdir+ThemesDirectory+'*.dbc', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
    If fileexists(fdir+ThemesDirectory+SearchRec.Name) then
    begin
     Filesetattr(fdir+ThemesDirectory+SearchRec.Name,faHidden);
     Assignfile(f1,fdir+ThemesDirectory+SearchRec.Name);
     Erase(f1);
    end;
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
  try
   RmDir(fdir+ThemesDirectory);
  except
  end;
 end;
 If Options.PlugIns then
 begin
  FTypeOperation:=TEXT_MES_DELETING_PLUGINS;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  //Remove old version plugins
  Found := FindFirst(fdir+OldPlugInImagesFolder+'*.dll', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
    If FileExists(fdir+OldPlugInImagesFolder+SearchRec.Name) then
    begin
     try
      dllhandle:=LoadLibrary(PChar(fdir+OldPlugInImagesFolder+SearchRec.Name));
      if dllhandle<>0 then
      begin
       SetString(s, Buffer, LoadString(dllhandle, 3, Buffer, sizeof(Buffer)));
       freelibrary(dllhandle);
       if s='TGRAPHICSELECT' then
       begin
        Filesetattr(fdir+OldPlugInImagesFolder+SearchRec.Name,faHidden);
        Assignfile(f1,fdir+OldPlugInImagesFolder+SearchRec.Name);
        Erase(f1);
       end;
      end;
     except
     end;
    end;
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
  try
   RmDir(fdir+OldPlugInImagesFolder);
  except
  end;

  //Remove plugins 2.0
  Found := FindFirst(fdir+PlugInImagesFolder+'*.jpgc', faAnyFile, SearchRec);
  while Found = 0 do
  begin
   if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
   begin
    If FileExists(fdir+PlugInImagesFolder+SearchRec.Name) then
    begin
     if ValidJPEGContainer(fdir+PlugInImagesFolder+SearchRec.Name) then
     begin
      Filesetattr(fdir+PlugInImagesFolder+SearchRec.Name,faHidden);
      Assignfile(f1,fdir+PlugInImagesFolder+SearchRec.Name);
      Erase(f1);
     end;
    end;
   end;
   Found := SysUtils.FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
  try
   RmDir(fdir+PlugInImagesFolder);
  except
  end;

 end;

 If Options.Scripts then
 begin
  FTypeOperation:=TEXT_MES_DELETING_SCRIPTS;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  Dolphin_db.deldir(fdir+ScriptsFolder,'|DBINI|INI|');
 end;

 If Options.Actions then
 begin
  FTypeOperation:=TEXT_MES_DELETING_SCRIPTS;
  FInfo:='...';
  FinfoLabel:='';
  FProgressText:=TEXT_MES_WAIT_PR;
  FProgress:=0;
  FMaxSize:=1;
  Synchronize(SetInfo);
  Synchronize(SetProgress);
  Dolphin_db.deldir(fdir+ActionsFolder,'|DBACT|');
 end;
 
 FTypeOperation:=TEXT_MES_DELETING_TEMP_FILES;
 FInfo:='...';
 FinfoLabel:='';
 FProgressText:=TEXT_MES_WAIT_PR;
 FProgress:=0;
 FMaxSize:=1;
 Synchronize(SetInfo);
 Synchronize(SetProgress);
 Found := FindFirst(fdir+'*.*', faAnyFile, SearchRec);
 while Found = 0 do
 begin
  if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
  begin
   If FileExists(fdir+SearchRec.Name) and (AnsiUpperCase(Copy(SearchRec.Name,1,4))='_QSQ') then
   begin
    Filesetattr(fdir+SearchRec.Name,faHidden);
    Assignfile(f1,fdir+SearchRec.Name);
    try
     Erase(f1);
    except
    end;
   end;
  end;
  Found := sysutils.FindNext(SearchRec);
 end;
 FindClose(SearchRec);
 try
  Filesetattr(DBkernel.GetLoginDataBaseFileName,faHidden);
  DeleteFile(DBkernel.GetLoginDataBaseFileName);
 except
 end;
{ //UnSupported
  try
  FExplorerFolders := TExplorerFolders.Create;
  s:=FExplorerFolders.GetThumbDBName;
  FExplorerFolders.Free;
  For i:=1 to 5 do
  begin
   try
    DeleteFile(GetDirectory(S)+GetFileNameWithoutExt((S))+'.'+DBFilesExt[i-1]);
   except
   end;
  end;
 except
 end;    }
 DelDir(GetAppDataDirectory+BackUpFolder,'|DB|MB|FAM|VAL|TV|MDB|LDB|PHOTODB|');
 DelDir(GetAppDataDirectory+TempFolder,'||');
 SysUtils.DeleteFile(fdir+ImagesFolder+'Family.jpg');
 SysUtils.DeleteFile(fdir+ImagesFolder+'Friends.jpg');
 SysUtils.DeleteFile(fdir+ImagesFolder+'Me.jpg');
 Removedir(fDir+ImagesFolder);

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

 try
  SelfDel;
 except
 end;
 Synchronize(exit);
end;

procedure UnInstallThread.error;
begin
 MessageBoxDB(GetActiveFormHandle,FErrorString,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
end;

procedure UnInstallThread.exit;
begin
 InstallDone:=true;
 If SetupProgressUnit.SetupProgressForm<>nil then
 begin
  SetupProgressUnit.SetupProgressForm.OnCloseQuery:=nil;
  SetupProgressUnit.SetupProgressForm.OnClose:=nil;
  SetupProgressUnit.SetupProgressForm.Close;
 end;
 DoEndInstall;
end;

end.
