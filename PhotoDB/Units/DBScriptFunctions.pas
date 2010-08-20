unit DBScriptFunctions;

interface

uses Windows, Dolphin_DB, UnitScripts, ReplaseIconsInScript, acDlgSelect,
     ReplaseLanguageInScript, Forms, Classes, SysUtils, Registry, GraphicCrypt,
     Graphics, DB, UnitINI, UnitDBDeclare, UnitDBFileDialogs, UnitStenoGraphia,
     Math, uScript, UnitCDMappingSupport, uFileUtils;

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
function InitializeScriptString(Script : string) : string;    
procedure InitEnviroment(Enviroment : TScriptEnviroment);

implementation

uses ExplorerTypes, UnitPasswordForm, UnitWindowsCopyFilesThread, UnitLinksSupport,
CommonDBSupport, Activation, UnitInternetUpdate, UnitManageGroups, about,
UnitUpdateDB, Searching, ManagerDBUnit, Options, ImEditor, UnitFormCont,
ExplorerUnit, UnitGetPhotosForm, UnitListOfKeyWords, UnitDBTreeView,
SlideShow, UnitHelp, FormManegerUnit, ProgressActionUnit, UnitDBKernel,
UnitCryptImageForm, UnitStringPromtForm, UnitSelectDB, Language,
UnitSplitExportForm, UnitJPEGOptions, UnitUpdateDBObject,
UnitFormCDMapper, UnitFormCDExport;


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
 AboutForm.Execute;
end;

function ReadScriptFile(FileName : string) : string;
begin
 Result := UnitScripts.ReadScriptFile(FileName);
 Result := AddLanguage(Result);
 Result := AddIcons(Result);
end;

function InitializeScriptString(Script : string) : string;
begin
 Result := AddLanguage(Script);
 Result := AddIcons(Result);
end;

procedure ShowUpdateWindow;
begin
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.ShowWindowNow;
end;

procedure AddFileInDB(FileName : string);
begin
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddFile(FileName)
end;

procedure AddFolderInDB(Directory : string);
begin
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
 SetSQL(fQuery,'Update $DB$ Set FFileName="'+FileName+'" WHERE ID='+inttostr(ID));
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
  if ManagerDB=nil then
  Application.CreateForm(TManagerDB,ManagerDB);
  ManagerDB.Show;
end;

procedure DoOptions;
begin
  if OptionsForm=nil then
  Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.show;
end;

function NewImageEditor : string;
begin
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
  Result:=GUIDToString(ManagerPanels[ManagerPanels.Count-1].WindowID);
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
 With ExplorerManager.NewExplorer(False) do
 begin
  SetStringPath(Path,false);
  Show;
  Result:= GUIDToString(WindowID);
 end;
end;

function NewExplorer : string;
begin
  with ExplorerManager.NewExplorer(True) do
 begin
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
  p : PWideChar;
begin
 s:=ExtractFileExt(FileName);
 Delete(s,1,1);
 s:='|'+AnsiUpperCase(s)+'|';
 p:=StrPos(PWideChar(SupportedExt),PWideChar(s));
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
    Result:=SearchManager[i];
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
    Result:=ManagerPanels[i];
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
    Result:=SearchManager[i].SearchEdit.Text;
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
    SearchManager[i].SearchEdit.Text:=Text;
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
    SearchManager[i].DoSearchNow(nil);
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
   Result[i]:=GUIDToString(SearchManager[i].WindowID);
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
 SetLength(Result,DBkernel.DBs.Count);
 for i:=0 to DBkernel.DBs.Count-1 do
 begin
  Result[i]:=DBkernel.DBs[i].Name;
 end;
end;

function GetDBFileList : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,DBkernel.DBs.Count);
 for i:=0 to DBkernel.DBs.Count-1 do
 begin
  Result[i]:=DBkernel.DBs[i].FileName;
 end;
end;

function GetDBIcoList : TArrayOfString;
var
  i : integer;
begin
 SetLength(Result,DBkernel.DBs.Count);
 for i:=0 to DBkernel.DBs.Count-1 do
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

procedure AddDBFile;
var
  DBFile : TPhotoDBFile;
begin
 DBFile:=DoChooseDBFile();
 if DBKernel.TestDB(DBFile.FileName) then
 DBKernel.AddDB(DBFile.Name,DBFile.FileName,DBFile.Icon);
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

Procedure LoadDBFunctions(Enviroment : TScriptEnviroment);
begin
 //Crypt

 AddScriptFunction(Enviroment,'ValidCryptGraphicFile',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@GraphicCrypt.ValidCryptGraphicFile);
 AddScriptFunction(Enviroment,'ValidPassInCryptGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@GraphicCrypt.ValidPassInCryptGraphicFile);
 AddScriptFunction(Enviroment,'FindPasswordForCryptImageFile',F_TYPE_FUNCTION_IS_STRING,@FindPasswordForCryptImageFile);
 AddScriptFunction(Enviroment,'GetImagePasswordFromUser',F_TYPE_FUNCTION_IS_STRING,@GetImagePasswordFromUser);
 AddScriptFunction(Enviroment,'PromtUserCryptImageFile',F_TYPE_FUNCTION_IS_STRING,@PromtUserCryptImageFile);
 AddScriptFunction(Enviroment,'CryptGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@CryptGraphicFile);
 AddScriptFunction(Enviroment,'ResetPasswordInGraphicFile',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@GraphicCrypt.ResetPasswordInGraphicFile);

 // AddScriptFunction

 AddScriptFunction(Enviroment,'StaticPath',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@StaticPath);

 AddScriptFunction(Enviroment,'GetImagesMask',F_TYPE_FUNCTION_IS_STRING,@GetImagesMask);
 AddScriptFunction(Enviroment,'SetFileNameByID',F_TYPE_PROCEDURE_INTEGER_STRING,@SetFileNameByID);

 AddScriptFunction(Enviroment,'Compare2Images',F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER,@Compare2Images);

 AddScriptFunction(Enviroment,'PromtString',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@aPromtString);

 AddScriptFunction(Enviroment,'GetCurrentDB',F_TYPE_FUNCTION_IS_STRING,@GetCurrentDB);
 AddScriptFunction(Enviroment,'GetProgramPath',F_TYPE_FUNCTION_IS_STRING,@GetProgramPath);
 AddScriptFunction(Enviroment,'SelectDB',F_TYPE_PROCEDURE_STRING,@SelectDB);
 AddScriptFunction(Enviroment,'TestDB',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@TestDB);
 AddScriptFunction(Enviroment,'AddDBFile',F_TYPE_PROCEDURE_NO_PARAMS,@AddDBFile);

 AddScriptFunction(Enviroment,'Char',F_TYPE_FUNCTION_INTEGER_IS_STRING,@aChar);

 AddScriptFunction(Enviroment,'UpperCase',F_TYPE_FUNCTION_STRING_IS_STRING,@aAnsiUpperCase);
 AddScriptFunction(Enviroment,'LowerCase',F_TYPE_FUNCTION_STRING_IS_STRING,@aAnsiLowerCase);

 AddScriptFunction(Enviroment,'ShowKeyWord',F_TYPE_FUNCTION_STRING_IS_STRING,@ShowKeyWord);
 AddScriptFunction(Enviroment,'OpenSearch',F_TYPE_FUNCTION_STRING_IS_STRING,@OpenSearch);
 AddScriptFunction(Enviroment,'GetRegKeyListing',F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING,@GetRegKeyListing);

 AddScriptFunction(Enviroment,'ReadRegString',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@ReadRegString);
 AddScriptFunction(Enviroment,'ReadRegBool',F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER,@ReadRegBool);
 AddScriptFunction(Enviroment,'ReadRegInteger',F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER,@ReadRegInteger);
 AddScriptFunction(Enviroment,'ReadRegRealBool',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@ReadRegRealBool);

  AddScriptFunction(Enviroment,'WriteRegString',F_TYPE_PROCEDURE_STRING_STRING_STRING,@WriteRegString);
  AddScriptFunction(Enviroment,'WriteRegBool',F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN,@WriteRegBool);
  AddScriptFunction(Enviroment,'WriteRegInteger',F_TYPE_PROCEDURE_STRING_STRING_INTEGER,@WriteRegInteger);

 AddScriptFunction(Enviroment,'ImageFile',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@ImageFile);
 AddScriptFunction(Enviroment,'ShowFile',F_TYPE_PROCEDURE_STRING,@ShowFile);

 AddScriptFunction(Enviroment,'DoHelp',F_TYPE_PROCEDURE_NO_PARAMS,@DoHelp);
 AddScriptFunction(Enviroment,'DoHomePage',F_TYPE_PROCEDURE_NO_PARAMS,@DoHomePage);
 AddScriptFunction(Enviroment,'DoHomeContactWithAuthor',F_TYPE_PROCEDURE_NO_PARAMS,@DoHomeContactWithAuthor);
 AddScriptFunction(Enviroment,'DoActivation',F_TYPE_PROCEDURE_NO_PARAMS,@DoActivation);

 AddScriptFunction(Enviroment,'ExecuteGroupManager',F_TYPE_PROCEDURE_NO_PARAMS,@ExecuteGroupManager);
 AddScriptFunction(Enviroment,'GetUpdates',F_TYPE_PROCEDURE_BOOLEAN,@GetUpdates);
 AddScriptFunction(Enviroment,'DoAbout',F_TYPE_PROCEDURE_NO_PARAMS,@DoAbout);

 AddScriptFunction(Enviroment,'ShowUpdateWindow',F_TYPE_PROCEDURE_NO_PARAMS,@ShowUpdateWindow);
 AddScriptFunction(Enviroment,'AddFileInDB',F_TYPE_PROCEDURE_STRING,@AddFileInDB);
 AddScriptFunction(Enviroment,'AddFolderInDB',F_TYPE_PROCEDURE_STRING,@AddFolderInDB);

 AddScriptFunction(Enviroment,'GetFileNameByID',F_TYPE_FUNCTION_INTEGER_IS_STRING,@GetFileNameByID);
 AddScriptFunction(Enviroment,'GetIDByFileName',F_TYPE_FUNCTION_STRING_IS_INTEGER,@GetIDByFileName);
 AddScriptFunction(Enviroment,'InstalledFileName',F_TYPE_FUNCTION_IS_STRING,@InstalledFileName);

 AddScriptFunction(Enviroment,'DoManager',F_TYPE_PROCEDURE_NO_PARAMS,@DoManager);

 AddScriptFunction(Enviroment,'DoOptions',F_TYPE_PROCEDURE_NO_PARAMS,@DoOptions);
 AddScriptFunction(Enviroment,'NewImageEditor',F_TYPE_FUNCTION_IS_STRING,@NewImageEditor);

 AddScriptFunction(Enviroment,'ImageEditorRegisterCallBack',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ImageEditorRegisterCallBack);
 AddScriptFunction(Enviroment,'ExecuteActions',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ExecuteActions);

 AddScriptFunction(Enviroment,'ImageEditorOpenFileName',F_TYPE_PROCEDURE_STRING_STRING,@ImageEditorOpenFileName);

 AddScriptFunction(Enviroment,'NewPanel',F_TYPE_FUNCTION_IS_STRING,@NewPanel);

 AddScriptFunction(Enviroment,'AddFileToPanel',F_TYPE_PROCEDURE_STRING_STRING,@AddFileToPanel);

 AddScriptFunction(Enviroment,'GetLastPanel',F_TYPE_FUNCTION_IS_STRING,@GetLastPanel);

 AddScriptFunction(Enviroment,'NewSearch',F_TYPE_FUNCTION_IS_STRING,@NewSearch);
 AddScriptFunction(Enviroment,'NewExplorerByPath',F_TYPE_FUNCTION_STRING_IS_STRING,@NewExplorerByPath);
 AddScriptFunction(Enviroment,'NewExplorer',F_TYPE_FUNCTION_IS_STRING,@NewExplorer);
 AddScriptFunction(Enviroment,'GetPhotosFromFolder',F_TYPE_PROCEDURE_STRING,@GetPhotosFromFolder);
 AddScriptFunction(Enviroment,'SelectDir',F_TYPE_FUNCTION_STRING_IS_STRING,@SelectDir);

 AddScriptFunction(Enviroment,'GetListOfKeyWords',F_TYPE_PROCEDURE_NO_PARAMS,@GetListOfKeyWords);
 AddScriptFunction(Enviroment,'MakeDBFileTree',F_TYPE_PROCEDURE_NO_PARAMS,@aMakeDBFileTree);

 AddScriptFunction(Enviroment,'SplitLinks',F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING,@SplitLinks);

 AddScriptFunction(Enviroment,'LinkName',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkName);
 AddScriptFunction(Enviroment,'LinkValue',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkValue);
 AddScriptFunction(Enviroment,'LinkType',F_TYPE_FUNCTION_STRING_IS_INTEGER,@aLinkType);
 AddScriptFunction(Enviroment,'LinkTypeString',F_TYPE_FUNCTION_STRING_IS_STRING,@aLinkTypeString);

 AddScriptFunction(Enviroment,'GetFileNameByIDEx',F_TYPE_FUNCTION_STRING_IS_STRING,@GetFileNameByIDEx);
 AddScriptFunction(Enviroment,'GetIDByIDEx',F_TYPE_FUNCTION_STRING_IS_INTEGER,@GetIDByIDEx);

 AddScriptFunction(Enviroment,'CodeExtID',F_TYPE_FUNCTION_STRING_IS_STRING,@CodeExtID);
 AddScriptFunction(Enviroment,'DeCodeExtID',F_TYPE_FUNCTION_STRING_IS_STRING,@DeCodeExtID);

 AddScriptFunction(Enviroment,'Hint',F_TYPE_PROCEDURE_STRING_STRING,@aHint);
 AddScriptFunction(Enviroment,'CloseApp',F_TYPE_PROCEDURE_NO_PARAMS,@CloseApp);

 AddScriptFunction(Enviroment,'GetDBNameList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBNameList);
 AddScriptFunction(Enviroment,'GetDBFileList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBFileList);
 AddScriptFunction(Enviroment,'GetDBIconList',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetDBIcoList);

 //forms

 AddScriptFunction(Enviroment,'GetSearchs',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetSearchs);
 AddScriptFunction(Enviroment,'DoSearch',F_TYPE_PROCEDURE_STRING,@DoSearch);
 AddScriptFunction(Enviroment,'SetSearchText',F_TYPE_PROCEDURE_STRING_STRING,@SetSearchText);
 AddScriptFunction(Enviroment,'GetSearchTextByCID',F_TYPE_FUNCTION_STRING_IS_STRING,@GetSearchTextByCID);

 AddScriptFunction(Enviroment,'GetExplorerPath',F_TYPE_FUNCTION_STRING_IS_STRING,@GetExplorerPath);
 AddScriptFunction(Enviroment,'GetExplorersByPath',F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING,@GetExplorersByPath);
 AddScriptFunction(Enviroment,'GetExplorerByPath',F_TYPE_FUNCTION_STRING_IS_STRING,@GetExplorerByPath);
 AddScriptFunction(Enviroment,'GetExplorers',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetExplorers);
 AddScriptFunction(Enviroment,'SetExplorerPath',F_TYPE_PROCEDURE_STRING_STRING,@SetExplorerPath);

 AddScriptFunction(Enviroment,'CloseDBForm',F_TYPE_PROCEDURE_STRING,@CloseDBForm);
 AddScriptFunction(Enviroment,'ShowDBForm',F_TYPE_PROCEDURE_STRING,@ShowDBForm);

 AddScriptFunction(Enviroment,'GetProgressWindow',F_TYPE_FUNCTION_STRING_IS_STRING,@GetProgressWindow);

 AddScriptFunction(Enviroment,'SetProgressWindowProgress',F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING,@SetProgressWindowProgress);

 AddScriptFunction(Enviroment,'SplitDB',F_TYPE_PROCEDURE_NO_PARAMS,@SplitDB);

 AddScriptFunction(Enviroment,'SetJPEGOptions',F_TYPE_PROCEDURE_NO_PARAMS,@SetJPEGOptions);

 AddScriptFunction(Enviroment,'DoDesteno',F_TYPE_PROCEDURE_STRING,@DoDesteno);
 AddScriptFunction(Enviroment,'DoSteno',F_TYPE_PROCEDURE_STRING,@DoSteno);

 AddScriptFunction(Enviroment,'DoCDExport',F_TYPE_PROCEDURE_NO_PARAMS,@DoCDExport);
 AddScriptFunction(Enviroment,'DoCDMapping',F_TYPE_PROCEDURE_NO_PARAMS,@DoManageCDMapping);
end;   

procedure InitEnviroment(Enviroment : TScriptEnviroment);
begin
  LoadBaseFunctions(Enviroment);
  LoadDBFunctions(Enviroment);
  LoadFileFunctions(Enviroment);
end;

initialization

InitScriptFunction:=@InitializeScriptString;

end.
