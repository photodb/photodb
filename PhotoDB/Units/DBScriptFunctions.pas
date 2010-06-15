unit DBScriptFunctions;

interface

uses Windows, Dolphin_DB, UnitScripts, ReplaseIconsInScript, acDlgSelect,
     ReplaseLanguageInScript, Forms, Classes, SysUtils, Registry, GraphicCrypt,
     Graphics, DB, UnitINI, UnitDBDeclare, UnitDBFileDialogs, UnitStenoGraphia,
     Math, UnitCDMappingSupport;

Procedure LoadDBFunctions(var aScript : TScript);
procedure DoActivation;
procedure GetUpdates(ShowInfo : boolean);
procedure DoAbout;
function ReadScriptFile(FileName : string) : string;
procedure ShowUpdateWindow;
procedure DoManager;
procedure DoOptions;
function NewImageEditor : string;
function NewExplorer : string;
function NewExplorerByPath(Path : string) : string;
procedure AddAccessVariables(var aScript : TScript);
function InitializeScriptString(Script : string) : string;

implementation

uses ExplorerTypes, UnitPasswordForm, UnitWindowsCopyFilesThread, UnitLinksSupport,
CommonDBSupport, Activation, UnitInternetUpdate, UnitManageGroups, about,
UnitUpdateDB, Searching, ManagerDBUnit, Options, ImEditor, UnitFormCont,
ExplorerUnit, UnitGetPhotosForm, UnitListOfKeyWords, UnitDBTreeView,
SlideShow, UnitHelp, FormManegerUnit, ProgressActionUnit, UnitDBKernel,
UnitCryptImageForm, UnitStringPromtForm, UnitSelectDB, Language,
UnitSplitExportForm, UnitJPEGOptions, UnitUpdateDBObject,
UnitFormCDMapper, UnitFormCDExport;

procedure AddAccessVariables(var aScript : TScript);
begin
 SetIntAttr(aScript,'$LINK_TYPE_ID',0);
 SetIntAttr(aScript,'$LINK_TYPE_ID_EXT',1);
 SetIntAttr(aScript,'$LINK_TYPE_IMAGE',2);
 SetIntAttr(aScript,'$LINK_TYPE_FILE',3);
 SetIntAttr(aScript,'$LINK_TYPE_FOLDER',4);
 SetIntAttr(aScript,'$LINK_TYPE_TXT',5);
 SetNamedValueStr(aScript,'$InvalidQuery',#8);

 SetBoolAttr(aScript,'$CanSetRating',DBKernel.UserRights.SetRating);
 SetBoolAttr(aScript,'$CanDeleteInfo',DBKernel.UserRights.Delete);
 SetBoolAttr(aScript,'$CanFileOperationsNormal',DBkernel.UserRights.FileOperationsNormal);
 SetBoolAttr(aScript,'$CanFileOperationsCritical',DBKernel.UserRights.FileOperationsCritical);
 SetBoolAttr(aScript,'$CanSetInfo',DBKernel.UserRights.SetInfo);
 SetBoolAttr(aScript,'$CanSetPrivate',DBKernel.UserRights.SetPrivate);
 SetBoolAttr(aScript,'$CanSetCrypt',DBKernel.UserRights.Crypt);
 SetBoolAttr(aScript,'$CanEditImage',DBKernel.UserRights.EditImage);
 SetBoolAttr(aScript,'$CanPrint',DBKernel.UserRights.Print);
 SetBoolAttr(aScript,'$CanShowPath',DBKernel.UserRights.ShowPath);
 SetBoolAttr(aScript,'$CanExecute',DBKernel.UserRights.Execute);
 SetBoolAttr(aScript,'$CanShowAdminTools',DBKernel.UserRights.ShowAdminTools);
 SetBoolAttr(aScript,'$CanEditImage',DBKernel.UserRights.EditImage);
 SetBoolAttr(aScript,'$CanManageGroups',DBKernel.UserRights.ManageGroups);
 SetBoolAttr(aScript,'$CanCrypt',DBKernel.UserRights.Crypt);
 SetBoolAttr(aScript,'$CanShowPrivate',DBKernel.UserRights.ShowPrivate);
end;

procedure DoActivation;
begin
 if ActivateForm=nil then
 Application.CreateForm(TActivateForm,ActivateForm);
 ActivateForm.Execute;
end;

procedure GetUpdates(ShowInfo : boolean);
begin
 TInternetUpdate.Create(false,ShowInfo);
end;

procedure DoAbout;
begin
 if AboutForm= nil then
 Application.CreateForm(TAboutForm,AboutForm);
 AboutForm.execute;
end;

function ReadScriptFile(FileName : string) : string;
begin
 Result:=UnitScripts.ReadScriptFile(FileName);
 Result:=AddLanguage(Result);
 Result:=AddIcons(Result);
end;

function InitializeScriptString(Script : string) : string;
begin
 Result:=AddLanguage(Script);
 Result:=AddIcons(Result);
end;

procedure ShowUpdateWindow;
begin
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.ShowWindowNow;
end;

procedure AddFileInDB(FileName : string);
begin
 if not DBKernel.UserRights.Add then exit;
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddFile(FileName)
end;

procedure AddFolderInDB(Directory : string);
begin
 if not DBKernel.UserRights.Add then exit;
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddDirectory(Directory,nil)
end;

function GetRegKeyListing(Key : string) : TArrayOfString;
var
  reg : TBDRegistry;
  S : TStrings;
  i: integer;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  Reg.OpenKey(GetRegRootKey+'\'+Key,true);
  S := TStringList.create;
  Reg.GetKeyNames(S);
  Reg.Free;
  SetLength(Result,S.Count);
  for i:=0 to S.Count-1 do
  Result[i]:=S[i];
  S.Free;
end;

function ReadRegString(Key, Value : string) : string;
begin
 Result:=DBKernel.ReadString(Key,Value);
end;

function ReadRegBool(Key, Value : string) : boolean;
begin
 Result:=DBKernel.ReadBool(Key,Value,false);
end;

function ReadRegRealBool(Key, Value : string) : boolean;
begin
 Result:=DBKernel.ReadRealBool(Key,Value,false);
end;

function ReadRegInteger(Key, Value : string) : integer;
begin
 Result:=DBKernel.ReadInteger(Key,Value,0);
end;

procedure WriteRegString(Key, Value : string; aValue : string);
begin
 DBKernel.WriteString(Key,Value,aValue);
end;

procedure WriteRegBool(Key, Value : string; aValue : boolean);
begin
 DBKernel.WriteBool(Key,Value,aValue);
end;

procedure WriteRegInteger(Key, Value : string; aValue : integer);
begin
 DBKernel.WriteInteger(Key,Value,aValue);
end;

procedure SetFileNameByID(ID : integer; FileName : string);
var
  fQuery : TDataSet;
begin
 fQuery:=GetQuery;
 fQuery.Active:=false;
 FileName:=NormalizeDBString(AnsiLowerCase(FileName));
 SetSQL(fQuery,'Update '+GetDefDBname+' Set FFileName="'+FileName+'" WHERE ID='+inttostr(ID));
 try
  ExecSQL(fQuery);
 except
 end;
 FreeDS(fQuery);
end;

function ShowKeyWord(KeyWord : string) : string;
begin
 With SearchManager.NewSearch do
 begin
  Show;
  SearchEdit.Text:=':KeyWord('+KeyWord+'):';
  DoSearchNow(nil);
  Result:= GUIDToString(WindowID);
 end;
end;

function OpenSearch(StringSearch : string) : string;
begin
 With SearchManager.NewSearch do
 begin
  Show;
  SearchEdit.Text:=StringSearch;
  DoSearchNow(nil);
  Result:= GUIDToString(WindowID);
 end;
end;

procedure DoManager;
begin
 if DBkernel.UserRights.ShowAdminTools then
 begin
  if ManagerDB=nil then
  Application.CreateForm(TManagerDB,ManagerDB);
  ManagerDB.Show;
 end;
end;

procedure DoOptions;
begin
 if DBkernel.UserRights.ShowOptions then
 begin
  if OptionsForm=nil then
  Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.show;
 end;
end;

function NewImageEditor : string;
begin
 if DBkernel.UserRights.EditImage then
 With EditorsManager.NewEditor do
 begin
//  Show;
  Result:= GUIDToString(WindowID);
  CloseOnFailture:=false;
 end;
end;

function NewPanel : string;
begin
 With ManagerPanels.NewPanel do
 begin
  Show;
  SetFocus;
  Result:= GUIDToString(WindowID);
 end;
end;

function GetLastPanel : string;
begin
 if ManagerPanels.Count>0 then
 begin
  Result:=GUIDToString(ManagerPanels.Panels[ManagerPanels.Count-1].WindowID);
  exit;
 end;
 With ManagerPanels.NewPanel do
 begin
  Show;
  SetFocus;
  Result:= GUIDToString(WindowID);
 end;
end;

function NewSearch : string;
begin
 With SearchManager.NewSearch do
 begin
  Show;
  SetFocus;
  Result:= GUIDToString(WindowID);
 end;
end;

function NewExplorerByPath(Path : string) : string;
begin
 With ExplorerManager.NewExplorer do
 begin
  SetStringPath(Path,false);
  Show;
  Result:= GUIDToString(WindowID);
 end;
end;

function NewExplorer : string;
begin
 With ExplorerManager.NewExplorer do
 begin
  SetNewPathW(GetCurrentPathW,false);
  Show;
  Result:= GUIDToString(WindowID);
 end;
end;

function SelectDir(Text : string) : string;
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Application.Handle,Text,Dolphin_DB.UseSimpleSelectFolderDialog);
 FormatDir(Dir);
 Result:=Dir;
end;

procedure aMakeDBFileTree;
begin
 MakeDBFileTree(dbname);
end;

function ImageFile(FileName : string) : boolean;
var
  s : string;
  p : PChar;
begin
 s:=ExtractFileExt(FileName);
 Delete(s,1,1);
 s:='|'+AnsiUpperCase(s)+'|';
 p:=StrPos(PChar(SupportedExt),PChar(s));
 Result:=p<>nil;
end;

procedure ShowFile(FileName : string);
var
  Info : TRecordsInfo;
begin
 If Viewer=nil then
 Application.CreateForm(TViewer,Viewer);
 info:=Dolphin_DB.RecordsInfoOne(FileName,0,0,0,0,'','','','','',0,false,false,0,false,false,true,'');
 Viewer.Execute(nil,Info);
end;

function SplitLinks(Links, NoParam : String) : TArrayOfString;
var
  info : TLinksInfo;
  i : integer;
begin
 info:=ParseLinksInfo(Links);
 SetLength(Result,Length(info));
 for i:=0 to Length(info)-1 do
 begin
  Result[i]:=CodeLinkInfo(info[i]);
 end;
end;

function aLinkName(Link : string) : string;
var
  info : TLinksInfo;
begin
 info:=ParseLinksInfo(Link);
 if Length(info)>0 then
 Result:=info[0].LinkName;
end;

function aLinkValue(Link : string) : string;
var
  info : TLinksInfo;
begin
 info:=ParseLinksInfo(Link);
 if Length(info)>0 then
 Result:=info[0].LinkValue;
end;

function aLinkType(Link : string) : integer;
var
  info : TLinksInfo;
begin
 info:=ParseLinksInfo(Link);
 if Length(info)>0 then
 Result:=info[0].LinkType else Result:=-1;
end;

function aLinkTypeString(Link : string) : String;
var
  info : TLinksInfo;
begin
 info:=ParseLinksInfo(Link);
 if Length(info)>0 then
 Result:=LinkType(info[0].LinkType);
end;

function GetFileNameByIDEx(IDEx : string) : string;
var
  TIRA : TImageDBRecordA;
begin
 TIRA:=getimageIDTh(IDEx);
 if TIRA.count>0 then
 Result:=TIRA.FileNames[0];
end;

function GetIDByIDEx(IDEx : string) : integer;
var
  TIRA : TImageDBRecordA;
begin
 TIRA:=getimageIDTh(IDEx);
 if TIRA.count>0 then
 Result:=TIRA.IDs[0] else Result:=0;
end;

procedure aHint(Caption, Text : string);
var
  p : TPoint;
begin
 GetCursorPos(p);
 DoHelpHint(Caption,Text,p,nil);
end;

procedure CloseApp;
begin
 if FormManager<>nil then
 begin
  FormManager.CloseApp(nil);
 end;
end;

function GetExplorerByCID(CID : string) : TExplorerForm;
var
  i : integer;
begin
 Result:=nil;

 if ExplorerManager<>nil then
 begin
  for i:=0 to ExplorerManager.ExplorersCount-1 do
  begin
   if CID=GUIDToString(ExplorerManager[i].WindowID) then
   begin
    Result:=ExplorerManager[i];
    break;
   end;
  end;
 end;
end;

function GetExplorers : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,0);
 if ExplorerManager<>nil then
 begin
  SetLength(Result,ExplorerManager.ExplorersCount);
  for i:=0 to ExplorerManager.ExplorersCount-1 do
  begin
   //TODO: Result[i]:=ExplorerManager.Explorers[i].WindowID;
  end;
 end;
end;

function GetExplorerByPath(Path : string) : string;
var
  i : integer;
begin
 SetLength(Result,0);
 if ExplorerManager<>nil then
 begin
  SetLength(Result,ExplorerManager.ExplorersCount);
  for i:=0 to ExplorerManager.ExplorersCount-1 do
  if AnsiLowerCase(ExplorerManager[i].GetCurrentPath)=AnsiLowerCase(Path) then
  begin
   Result:=GUIDToString(ExplorerManager[i].WindowID);
   break;
  end;
 end;
end;

function GetExplorersByPath(Path, nil_ : string) : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,0);
 if ExplorerManager<>nil then
 begin
  for i:=0 to ExplorerManager.ExplorersCount-1 do
  if AnsiLowerCase(ExplorerManager[i].GetCurrentPath)=AnsiLowerCase(Path) then
  begin
   SetLength(Result,Length(Result)+1);
   Result[Length(Result)-1]:= GUIDToString(ExplorerManager[i].WindowID);
   break;
  end;
 end;
end;

function GetExplorerPath(CID : string) : string;
var
  i : integer;
begin
 SetLength(Result,0);
 if ExplorerManager<>nil then
 begin
  SetLength(Result,ExplorerManager.ExplorersCount);
  for i:=0 to ExplorerManager.ExplorersCount-1 do
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
  begin
   Result:=ExplorerManager[i].GetCurrentPath;
   break;
  end;
 end;
end;

function SetExplorerPath(CID, Path : string) : string;
var
  i : integer;
begin
 SetLength(Result,0);
 if ExplorerManager<>nil then
 begin
  SetLength(Result,ExplorerManager.ExplorersCount);
  for i:=0 to ExplorerManager.ExplorersCount-1 do
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
  begin
   ExplorerManager[i].SetStringPath(Path,false);
   break;
  end;
 end;
end;

function GetSearchByCID(CID : string) : TSearchForm;
var
  i : integer;
begin
 Result:=nil;
 if SearchManager<>nil then
 begin
  for i:=0 to SearchManager.SearchCount-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    Result:=SearchManager.Searchs[i];
    break;
   end;
  end;
 end;
end;

function GetPanelByCID(CID : string) : TFormCont;
var
  i : integer;
begin
 Result:=nil;
 if ManagerPanels<>nil then
 begin
  for i:=0 to ManagerPanels.Count-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    Result:=ManagerPanels.Panels[i];
    break;
   end;
  end;
 end;
end;

function GetSearchTextByCID(CID : string) : string;
var
  i : integer;
begin
 Result:='';
 if SearchManager<>nil then
 begin
  SetLength(Result,SearchManager.SearchCount);
  for i:=0 to SearchManager.SearchCount-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    Result:=SearchManager.Searchs[i].SearchEdit.Text;
    break;
   end;
  end;
 end;
end;

Procedure SetSearchText(CID, Text : string);
var
  i : integer;
begin
 if SearchManager<>nil then
 begin
  for i:=0 to SearchManager.SearchCount-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    SearchManager.Searchs[i].SearchEdit.Text:=Text;
    break;
   end;
  end;
 end;
end;

Procedure DoSearch(CID : string);
var
  i : integer;
begin
 if SearchManager<>nil then
 begin
  for i:=0 to SearchManager.SearchCount-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    SearchManager.Searchs[i].DoSearchNow(nil);
    break;
   end;
  end;
 end;
end;

function GetSearchs : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,0);
 if SearchManager<>nil then
 begin
  SetLength(Result,SearchManager.SearchCount);
  for i:=0 to SearchManager.SearchCount-1 do
  begin
   Result[i]:=GUIDToString(SearchManager.Searchs[i].WindowID);
  end;
 end;
end;

function GetProgressByCID(CID : string) : TProgressActionForm;
var
  i : integer;
begin
 Result:=nil;
 if ManagerProgresses<>nil then
 begin
  for i:=0 to ManagerProgresses.ProgressCount-1 do
  begin
   if CID=GUIDToString(TProgressActionForm(ManagerProgresses.Progresses[i]).WindowID) then
   begin
    Result:=TProgressActionForm(ManagerProgresses.Progresses[i]);
    break;
   end;
  end;
 end;
end;

function GetProgressWindow(Text : String) : string;
begin
 With ManagerProgresses.NewProgress do
 begin
  OneOperation:=true;
  MaxPosCurrentOperation:=100;
  if Text<>'' then Label1.Caption:=Text;
  Result:=GUIDToString(WindowID);
 end;
end;

function SetProgressWindowProgress(CID : string; Progress, nil1 : integer) : string;
begin
 GetProgressByCID(CID).xPosition:=Progress;
 Result:='';
end;

function GetImageEditorByCID(CID : string) : TImageEditor;
var
  i : integer;
begin
 Result:=nil;
 if EditorsManager<>nil then
 begin
  for i:=0 to EditorsManager.EditorsCount-1 do
  begin
   if CID=GUIDToString(EditorsManager.FEditors[i].WindowID) then
   begin
    Result:=EditorsManager.FEditors[i];
    break;
   end;
  end;
 end;
end;

procedure CloseDBForm(CID : string);
begin
 if GetImageEditorByCID(CID)<>nil then
 GetImageEditorByCID(CID).Close;

 if GetSearchByCID(CID)<>nil then
 GetSearchByCID(CID).Close;
 if GetExplorerByCID(CID)<>nil then
 GetExplorerByCID(CID).Close;
 if GetPanelByCID(CID)<>nil then
 GetPanelByCID(CID).Close;

 if GetProgressByCID(CID)<>nil then
 begin
  With GetProgressByCID(CID) do
  begin
   Close;
   Release;
   Free;
  end; 
 end;
end;

procedure ShowDBForm(CID : string);
begin
 if GetImageEditorByCID(CID)<>nil then
 GetImageEditorByCID(CID).Show;

 if GetSearchByCID(CID)<>nil then
 GetSearchByCID(CID).Show;
 if GetExplorerByCID(CID)<>nil then
 GetExplorerByCID(CID).Show;
 if GetProgressByCID(CID)<>nil then
 GetProgressByCID(CID).DoShow;
 if GetPanelByCID(CID)<>nil then
 GetPanelByCID(CID).Show;
end;

function GetDBNameList : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,Length(DBkernel.DBs));
 for i:=0 to Length(DBkernel.DBs)-1 do
 begin
  Result[i]:=DBkernel.DBs[i]._Name;
 end;
end;

function GetDBFileList : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,Length(DBkernel.DBs)); 
 for i:=0 to Length(DBkernel.DBs)-1 do
 begin
  Result[i]:=DBkernel.DBs[i].FileName;
 end;
end;

function GetDBIcoList : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,Length(DBkernel.DBs));
 for i:=0 to Length(DBkernel.DBs)-1 do
 begin
  Result[i]:=DBkernel.DBs[i].Icon;
 end;
end;

function aAnsiLowerCase(s : string) : string;
begin
 Result:=AnsiLowerCase(s);
end;

function aAnsiUpperCase(s : string) : string;
begin
 Result:=AnsiUpperCase(s);
end;

function aChar(int : integer) : string;
begin
 Result:=Char(int);
end;

function GetCurrentDB : string;
begin
 Result:=dbname;
end;

function FindPasswordForCryptImageFile(FileName : string) : string;
begin
 Result:=DBKernel.FindPasswordForCryptImageFile(FileName);
end;

function GetCurrentUser : string;
begin
 Result:=DBkernel.DBUserName;
end;

procedure AddDBFile;
var
  DBFile : TPhotoDBFile;
begin
 DBFile:=DoChooseDBFile();
 if DBKernel.TestDB(DBFile.FileName) then
 DBKernel.AddDB(DBFile._Name,DBFile.FileName,DBFile.Icon);
end;

function Compare2Images(File1, File2 : string; raz : integer) : integer;
var
  G1, G2 : TGraphic;
  pass1, pass2 : string;
  r : integer;
  CompResult : TImageCompareResult;
begin
 Result:=0;
 if not FileExists(File1) then exit;
 if not FileExists(File2) then exit;
 G1:=nil;
 G2:=nil;
 if ValidCryptGraphicFile(File1) then
 begin
  pass1 := DBKernel.FindPasswordForCryptImageFile(File1);
  if pass1 = '' then exit;
 end;
 if ValidCryptGraphicFile(File2) then
 begin
  pass2 := DBKernel.FindPasswordForCryptImageFile(File2);
  if pass2 = '' then exit;
 end;
 try
  if pass1='' then
  begin
   G1:=GetGraphicClass(GetExt(File1),false).Create;
   G1.LoadFromFile(File1);
  end else G1:=GraphicCrypt.DeCryptGraphicFile(File1,pass1);
 except
  if G1<>nil then G1.Free;
  exit;
 end;
 try
  if pass2='' then
  begin
   G2:=GetGraphicClass(GetExt(File2),false).Create;
   G2.LoadFromFile(File2);
  end else G2:=GraphicCrypt.DeCryptGraphicFile(File2,pass2);
 except
  if G1<>nil then G1.Free;
  if G2<>nil then G2.Free;
  exit;
 end;
 CompResult:=CompareImages(G1,G2,r,true,false,raz);
 Result:=Max(CompResult.ByGistogramm,CompResult.ByPixels);
 G1.Free;
 G2.Free;
end;

function PromtUserCryptImageFile(FileName : string) : string;
begin
 Result:=GetPassForCryptImageFile(FileName).Password;
end;

function CryptGraphicFile(FileName, Password : string) : boolean;
begin
 Result:=CryptGraphicFileV1(FileName, Password, 0);
end;

function aPromtString(Caption, Text, InitialString : String) : string;
begin
 Result:= InitialString;
 PromtString(Caption, Text, Result);
end;

function TestDB(DB : String) : boolean;
begin
 Result:= DBKernel.TestDB(DB);
end;

procedure AddFileToPanel(CID, FileName : string);
begin
 if GetPanelByCID(CID)<>nil then
 GetPanelByCID(CID).AddFileName(FileName);
end;

function ExecuteActions(CID, FileName, ToFileName : string): string;
var
  aActions : TArStrings;
begin
 if GetImageEditorByCID(CID)<>nil then
 begin
  SetLength(aActions,0);
  aActions:=Copy(LoadActionsFromfileA(FileName));
  GetImageEditorByCID(CID).ReadActions(aActions);
  GetImageEditorByCID(CID).SaveImageFile(ToFileName,true);
 end;
 Result:='';
end;

function ImageEditorRegisterCallBack(CID, ID, Proc : string): string;
begin
 if GetImageEditorByCID(CID)<>nil then
 begin
  GetImageEditorByCID(CID).FScript:=ID; 
  GetImageEditorByCID(CID).FScriptProc:=Proc;
 end;
 Result:='';
end;

function ImageEditorOpenFileName(CID, FileName : string) : string;
begin
 if GetImageEditorByCID(CID)<>nil then
 begin
  GetImageEditorByCID(CID).OpenFileName(FileName);
 end;
end;

function GetImagesMask : string;
begin
 Result:=SupportedExt;
end;

function UserRights(StringRights : string) : boolean;
var
  fDBUserAccess : String;
begin
 Result:=false;
 fDBUserAccess:=DBKernel.fDBUserAccess;
 if AnsiUpperCase(StringRights)='RIGHTS_DELETE' then Result:=fDBUserAccess[1]='1'; //  fUserRights.Delete:=fDBUserAccess[1]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_ADD' then Result:=fDBUserAccess[2]='1'; //  fUserRights.Add:=fDBUserAccess[2]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SET_PRIVATE' then Result:=fDBUserAccess[3]='1';  //  fUserRights.SetPrivate:=fDBUserAccess[3]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_CHANGE_PASSWORD' then Result:=fDBUserAccess[4]='1'; //   fUserRights.ChPass:=fDBUserAccess[4]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_EDIT_IMAGE' then Result:=fDBUserAccess[5]='1'; //   fUserRights.EditImage:=fDBUserAccess[5]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SET_RATING' then Result:=fDBUserAccess[6]='1'; //   fUserRights.SetRating:=fDBUserAccess[6]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SET_INFO' then Result:=fDBUserAccess[7]='1';  //   fUserRights.SetInfo:=fDBUserAccess[7]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SHOW_PRIVATE' then Result:=fDBUserAccess[8]='1';  //   fUserRights.ShowPrivate:=fDBUserAccess[8]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SHOW_OPTIONS' then Result:=fDBUserAccess[9]='1';  //    fUserRights.ShowOptions:=fDBUserAccess[9]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_ADMIN_TOOLS' then Result:=fDBUserAccess[10]='1';  //    fUserRights.ShowAdminTools:=fDBUserAccess[10]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_CHANGE_DB_NAME' then Result:=fDBUserAccess[11]='1';  //    fUserRights.ChDbName:=fDBUserAccess[11]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_CRITICAL_FILE_OPERATIONS' then Result:=fDBUserAccess[12]='1';  // fUserRights.FileOperationsCritical:=fDBUserAccess[12]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_MANAGE_GROUPS' then Result:=fDBUserAccess[13]='1';  //  fUserRights.ManageGroups:=fDBUserAccess[13]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_NORMAL_FILE_OPERATIONS' then Result:=fDBUserAccess[14]='1';   //  fUserRights.FileOperationsNormal:=fDBUserAccess[14]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_EXECUTE' then Result:=fDBUserAccess[15]='1';   //  fUserRights.Execute:=fDBUserAccess[15]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_CRYPT' then Result:=fDBUserAccess[16]='1';    // fUserRights.Crypt:=fDBUserAccess[16]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_SHOW_PATH' then Result:=fDBUserAccess[17]='1';    // fUserRights.Crypt:=fDBUserAccess[17]='1';
 if AnsiUpperCase(StringRights)='RIGHTS_PRINT' then Result:=fDBUserAccess[18]='1';    // fUserRights.Crypt:=fDBUserAccess[18]='1';
end;

Procedure LoadDBFunctions(var aScript : TScript);
begin
 //Crypt

 AddScriptFunction(aScript,'ValidCryptGraphicFile',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@GraphicCrypt.ValidCryptGraphicFile);
 AddScriptFunction(aScript,'ValidPassInCryptGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@GraphicCrypt.ValidPassInCryptGraphicFile);
 AddScriptFunction(aScript,'FindPasswordForCryptImageFile',F_TYPE_FUNCTION_IS_STRING,@FindPasswordForCryptImageFile);
 AddScriptFunction(aScript,'GetImagePasswordFromUser',F_TYPE_FUNCTION_IS_STRING,@GetImagePasswordFromUser);
 AddScriptFunction(aScript,'PromtUserCryptImageFile',F_TYPE_FUNCTION_IS_STRING,@PromtUserCryptImageFile);
 AddScriptFunction(aScript,'PromtUserCryptImageFile',F_TYPE_FUNCTION_IS_STRING,@PromtUserCryptImageFile);
 if DBKernel.UserRights.FileOperationsCritical then
 AddScriptFunction(aScript,'CryptGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@CryptGraphicFile);
 if DBKernel.UserRights.FileOperationsCritical then
 AddScriptFunction(aScript,'ResetPasswordInGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@GraphicCrypt.ResetPasswordInGraphicFile);
 // AddScriptFunction


 AddScriptFunction(aScript,'StaticPath',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@StaticPath);

 AddScriptFunction(aScript,'UserRights',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@UserRights);

 AddScriptFunction(aScript,'GetImagesMask',F_TYPE_FUNCTION_IS_STRING,@GetImagesMask);
 AddScriptFunction(aScript,'SetFileNameByID',F_TYPE_PROCEDURE_INTEGER_STRING,@SetFileNameByID);

 AddScriptFunction(aScript,'Compare2Images',F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER,@Compare2Images);

 AddScriptFunction(aScript,'PromtString',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@aPromtString);

 AddScriptFunction(aScript,'GetCurrentUser',F_TYPE_FUNCTION_IS_STRING,@GetCurrentUser);
 AddScriptFunction(aScript,'GetCurrentDB',F_TYPE_FUNCTION_IS_STRING,@GetCurrentDB);
 AddScriptFunction(aScript,'GetProgramPath',F_TYPE_FUNCTION_IS_STRING,@GetProgramPath);
 if DBKernel.UserRights.ChDbName then
 AddScriptFunction(aScript,'SelectDB',F_TYPE_PROCEDURE_STRING,@SelectDB);
 AddScriptFunction(aScript,'TestDB',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@TestDB); 
 if DBKernel.UserRights.ChDbName then
 AddScriptFunction(aScript,'AddDBFile',F_TYPE_PROCEDURE_NO_PARAMS,@AddDBFile);

 AddScriptFunction(aScript,'Char',F_TYPE_FUNCTION_INTEGER_IS_STRING,@aChar);

 AddScriptFunction(aScript,'UpperCase',F_TYPE_FUNCTION_STRING_IS_STRING,@aAnsiUpperCase);
 AddScriptFunction(aScript,'LowerCase',F_TYPE_FUNCTION_STRING_IS_STRING,@aAnsiLowerCase);

 AddScriptFunction(aScript,'ShowKeyWord',F_TYPE_FUNCTION_STRING_IS_STRING,@ShowKeyWord);
 AddScriptFunction(aScript,'OpenSearch',F_TYPE_FUNCTION_STRING_IS_STRING,@OpenSearch);
 AddScriptFunction(aScript,'GetRegKeyListing',F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING,@GetRegKeyListing);

 AddScriptFunction(aScript,'ReadRegString',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@ReadRegString);
 AddScriptFunction(aScript,'ReadRegBool',F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER,@ReadRegBool);
 AddScriptFunction(aScript,'ReadRegInteger',F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER,@ReadRegInteger);
 AddScriptFunction(aScript,'ReadRegRealBool',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@ReadRegRealBool);
 if DBKernel.UserRights.ShowOptions then
 begin
  AddScriptFunction(aScript,'WriteRegString',F_TYPE_PROCEDURE_STRING_STRING_STRING,@WriteRegString);
  AddScriptFunction(aScript,'WriteRegBool',F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN,@WriteRegBool);
  AddScriptFunction(aScript,'WriteRegInteger',F_TYPE_PROCEDURE_STRING_STRING_INTEGER,@WriteRegInteger);
 end;
 AddScriptFunction(aScript,'ImageFile',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@ImageFile);
 AddScriptFunction(aScript,'ShowFile',F_TYPE_PROCEDURE_STRING,@ShowFile);

 AddScriptFunction(aScript,'DoHelp',F_TYPE_PROCEDURE_NO_PARAMS,@DoHelp);
 AddScriptFunction(aScript,'DoHomePage',F_TYPE_PROCEDURE_NO_PARAMS,@DoHomePage);
 AddScriptFunction(aScript,'DoHomeContactWithAuthor',F_TYPE_PROCEDURE_NO_PARAMS,@DoHomeContactWithAuthor);
 AddScriptFunction(aScript,'DoActivation',F_TYPE_PROCEDURE_NO_PARAMS,@DoActivation);
 if DBKernel.UserRights.ManageGroups then
 AddScriptFunction(aScript,'ExecuteGroupManager',F_TYPE_PROCEDURE_NO_PARAMS,@ExecuteGroupManager);
 AddScriptFunction(aScript,'GetUpdates',F_TYPE_PROCEDURE_BOOLEAN,@GetUpdates);
 AddScriptFunction(aScript,'DoAbout',F_TYPE_PROCEDURE_NO_PARAMS,@DoAbout);
 if DBKernel.UserRights.Add then
 begin
  AddScriptFunction(aScript,'ShowUpdateWindow',F_TYPE_PROCEDURE_NO_PARAMS,@ShowUpdateWindow);
  AddScriptFunction(aScript,'AddFileInDB',F_TYPE_PROCEDURE_STRING,@AddFileInDB);
  AddScriptFunction(aScript,'AddFolderInDB',F_TYPE_PROCEDURE_STRING,@AddFolderInDB);
 end;
 AddScriptFunction(aScript,'GetFileNameByID',F_TYPE_FUNCTION_INTEGER_IS_STRING,@GetFileNameByID);
 AddScriptFunction(aScript,'GetIDByFileName',F_TYPE_FUNCTION_STRING_IS_INTEGER,@GetIDByFileName);
 AddScriptFunction(aScript,'InstalledFileName',F_TYPE_FUNCTION_IS_STRING,@InstalledFileName);
 AddScriptFunction(aScript,'TryBDEInstall',F_TYPE_PROCEDURE_NO_PARAMS,@TryBDEInstall);
 if DBKernel.UserRights.ShowAdminTools then
 AddScriptFunction(aScript,'DoManager',F_TYPE_PROCEDURE_NO_PARAMS,@DoManager);
 if DBKernel.UserRights.ShowOptions then
 AddScriptFunction(aScript,'DoOptions',F_TYPE_PROCEDURE_NO_PARAMS,@DoOptions);

 if DBKernel.UserRights.EditImage then
 AddScriptFunction(aScript,'NewImageEditor',F_TYPE_FUNCTION_IS_STRING,@NewImageEditor);

 AddScriptFunction(aScript,'ImageEditorRegisterCallBack',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ImageEditorRegisterCallBack);
 AddScriptFunction(aScript,'ExecuteActions',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ExecuteActions);

 AddScriptFunction(aScript,'ImageEditorOpenFileName',F_TYPE_PROCEDURE_STRING_STRING,@ImageEditorOpenFileName);

 AddScriptFunction(aScript,'NewPanel',F_TYPE_FUNCTION_IS_STRING,@NewPanel);

 AddScriptFunction(aScript,'AddFileToPanel',F_TYPE_PROCEDURE_STRING_STRING,@AddFileToPanel);

 AddScriptFunction(aScript,'GetLastPanel',F_TYPE_FUNCTION_IS_STRING,@GetLastPanel);

 AddScriptFunction(aScript,'NewSearch',F_TYPE_FUNCTION_IS_STRING,@NewSearch);
 AddScriptFunction(aScript,'NewExplorerByPath',F_TYPE_FUNCTION_STRING_IS_STRING,@NewExplorerByPath);
 AddScriptFunction(aScript,'NewExplorer',F_TYPE_FUNCTION_IS_STRING,@NewExplorer);
 AddScriptFunction(aScript,'GetPhotosFromFolder',F_TYPE_PROCEDURE_STRING,@GetPhotosFromFolder);
 AddScriptFunction(aScript,'SelectDir',F_TYPE_FUNCTION_STRING_IS_STRING,@SelectDir);

 AddScriptFunction(aScript,'GetListOfKeyWords',F_TYPE_PROCEDURE_NO_PARAMS,@GetListOfKeyWords);
 if DBKernel.UserRights.ShowPath then
 AddScriptFunction(aScript,'MakeDBFileTree',F_TYPE_PROCEDURE_NO_PARAMS,@aMakeDBFileTree);

 AddScriptFunction(aScript,'LinkType',F_TYPE_FUNCTION_INTEGER_IS_STRING,@LinkType);
 AddScriptFunction(aScript,'SplitLinks',F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING,@SplitLinks);

 AddScriptFunction(aScript,'LinkName',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkName);
 AddScriptFunction(aScript,'LinkValue',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkValue);
 AddScriptFunction(aScript,'LinkType',F_TYPE_FUNCTION_STRING_IS_INTEGER,@aLinkType);
 AddScriptFunction(aScript,'LinkTypeString',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkTypeString);

 AddScriptFunction(aScript,'GetFileNameByIDEx',F_TYPE_FUNCTION_STRING_IS_STRING,@GetFileNameByIDEx);
 AddScriptFunction(aScript,'GetIDByIDEx',F_TYPE_FUNCTION_STRING_IS_INTEGER,@GetIDByIDEx);

 AddScriptFunction(aScript,'CodeExtID',F_TYPE_FUNCTION_STRING_IS_STRING,@CodeExtID);
 AddScriptFunction(aScript,'DeCodeExtID',F_TYPE_FUNCTION_STRING_IS_STRING,@DeCodeExtID);

 AddScriptFunction(aScript,'Hint',F_TYPE_PROCEDURE_STRING_STRING,@aHint);
 AddScriptFunction(aScript,'CloseApp',F_TYPE_PROCEDURE_NO_PARAMS,@CloseApp);

 AddScriptFunction(aScript,'GetDBNameList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBNameList);
 AddScriptFunction(aScript,'GetDBFileList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBFileList);
 AddScriptFunction(aScript,'GetDBIconList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBIcoList);

 //forms

 AddScriptFunction(aScript,'GetSearchs',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetSearchs);
 AddScriptFunction(aScript,'DoSearch',F_TYPE_PROCEDURE_STRING,@DoSearch);
 AddScriptFunction(aScript,'SetSearchText',F_TYPE_PROCEDURE_STRING_STRING,@SetSearchText);
 AddScriptFunction(aScript,'GetSearchTextByCID',F_TYPE_FUNCTION_STRING_IS_STRING,@GetSearchTextByCID);

 AddScriptFunction(aScript,'GetExplorerPath',F_TYPE_FUNCTION_STRING_IS_STRING,@GetExplorerPath);
 AddScriptFunction(aScript,'GetExplorersByPath',F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING,@GetExplorersByPath);
 AddScriptFunction(aScript,'GetExplorerByPath',F_TYPE_FUNCTION_STRING_IS_STRING,@GetExplorerByPath);
 AddScriptFunction(aScript,'GetExplorers',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetExplorers);
 AddScriptFunction(aScript,'SetExplorerPath',F_TYPE_PROCEDURE_STRING_STRING,@SetExplorerPath);

 AddScriptFunction(aScript,'CloseDBForm',F_TYPE_PROCEDURE_STRING,@CloseDBForm);
 AddScriptFunction(aScript,'ShowDBForm',F_TYPE_PROCEDURE_STRING,@ShowDBForm);

 AddScriptFunction(aScript,'GetProgressWindow',F_TYPE_FUNCTION_STRING_IS_STRING,@GetProgressWindow);

 AddScriptFunction(aScript,'SetProgressWindowProgress',F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING,@SetProgressWindowProgress);

 AddScriptFunction(aScript,'SplitDB',F_TYPE_PROCEDURE_NO_PARAMS,@SplitDB);

// AddScriptFunction(aScript,'DoSearch',F_TYPE_PROCEDURE_STRING,@DoSearch);
 AddScriptFunction(aScript,'SetJPEGOptions',F_TYPE_PROCEDURE_NO_PARAMS,@SetJPEGOptions);

 AddScriptFunction(aScript,'DoDesteno',F_TYPE_PROCEDURE_STRING,@DoDesteno);
 AddScriptFunction(aScript,'DoSteno',F_TYPE_PROCEDURE_STRING,@DoSteno);

 AddScriptFunction(aScript,'DoCDExport',F_TYPE_PROCEDURE_NO_PARAMS,@DoCDExport);
 AddScriptFunction(aScript,'DoCDMapping',F_TYPE_PROCEDURE_NO_PARAMS,@DoManageCDMapping);
end;

initialization

InitScriptFunction:=@InitializeScriptString;

end.
