unit DBScriptFunctions;

interface

uses
  Windows, Dolphin_DB, UnitScripts, ReplaseIconsInScript, acDlgSelect,
  Forms, Classes, SysUtils, Registry, GraphicCrypt, uMemory,
  Graphics, DB, UnitINI, UnitDBDeclare, UnitDBFileDialogs, uTranslate,
  Math, uScript, uCDMappingTypes, uFileUtils, uAssociations, uDBForm,
  uDBUtils, uDBBaseTypes, uDBTypes, uRuntime, uDBGraphicTypes,
  uDBFileTypes, uGraphicUtils, uSysUtils, uDBPopupMenuInfo, uSettings,
  UnitDBCommonGraphics;

procedure DoActivation;
procedure GetUpdates(IsBackground: boolean);
procedure DoAbout;
function ReadScriptFile(FileName: string) : string;
procedure ShowUpdateWindow;
procedure DoManager;
procedure DoOptions;
function NewImageEditor: string;
function NewExplorer: string;
function NewExplorerByPath(Path: string) : string;
function InitializeScriptString(Script: string) : string;
procedure InitEnviroment(Enviroment: TScriptEnviroment);

implementation

uses
  ExplorerTypes, UnitPasswordForm, UnitWindowsCopyFilesThread, UnitLinksSupport,
  CommonDBSupport, uActivation, UnitInternetUpdate, UnitManageGroups, uAbout,
  UnitUpdateDB, uSearchTypes, ManagerDBUnit, Options, ImEditor, UnitFormCont,
  ExplorerUnit, UnitGetPhotosForm, UnitListOfKeyWords, UnitDBTreeView,
  SlideShow, UnitHelp, FormManegerUnit, ProgressActionUnit, UnitDBKernel,
  UnitCryptImageForm, UnitStringPromtForm, UnitSelectDB,
  UnitSplitExportForm, UnitJPEGOptions, UnitUpdateDBObject,
  UnitFormCDMapper, UnitFormCDExport, uFormSteganography;

procedure DoActivation;
begin
  ShowActivationDialog;
end;

procedure GetUpdates(IsBackground : Boolean);
begin
  TInternetUpdate.Create(nil, IsBackground, nil);
end;

procedure DoAbout;
begin
  ShowAbout;
end;

function ReadScriptFile(FileName: string): string;
begin
  Result := UnitScripts.ReadScriptFile(FileName);
end;

function InitializeScriptString(Script: string): string;
begin
  Result := AddIcons(Script);
end;

procedure ShowUpdateWindow;
begin
  UpdaterDB.ShowWindowNow;
end;

procedure AddFileInDB(FileName: string);
begin
  UpdaterDB.AddFile(FileName)
end;

procedure AddFolderInDB(Directory: string);
begin
  UpdaterDB.AddDirectory(Directory, nil);
end;

function GetRegKeyListing(Key : string) : TArrayOfString;
var
  Reg: TBDRegistry;
  S: TStrings;
  I: Integer;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\' + Key, True);
    S := TStringList.create;
    try
      Reg.GetKeyNames(S);
      SetLength(Result, S.Count);
      for I := 0 to S.Count - 1 do
        Result[I] := S[I];
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

function ReadRegString(Key, Value: string): string;
begin
  Result := Settings.ReadString(Key, Value);
end;

function ReadRegBool(Key, Value: string): Boolean;
begin
  Result := Settings.ReadBool(Key, Value, False);
end;

function ReadRegRealBool(Key, Value: string): Boolean;
begin
  Result := Settings.ReadRealBool(Key, Value, False);
end;

function ReadRegInteger(Key, Value : string) : integer;
begin
  Result := Settings.ReadInteger(Key, Value, 0);
end;

procedure WriteRegString(Key, Value: string; AValue: string);
begin
  Settings.WriteString(Key, Value, AValue);
end;

procedure WriteRegBool(Key, Value: string; AValue: Boolean);
begin
  Settings.WriteBool(Key, Value, AValue);
end;

procedure WriteRegInteger(Key, Value: string; AValue: Integer);
begin
  Settings.WriteInteger(Key, Value, AValue);
end;

procedure SetFileNameByID(ID: Integer; FileName: string);
var
  FQuery: TDataSet;
begin
  FQuery := GetQuery;
  try
    FQuery.Active := False;
    FileName := NormalizeDBString(AnsiLowerCase(FileName));
    SetSQL(FQuery, 'Update $DB$ Set FFileName="' + FileName + '" WHERE ID=' + Inttostr(ID));
    try
      ExecSQL(FQuery);
    except
    end;
  finally
    FreeDS(FQuery);
  end;
end;

function ShowKeyWord(KeyWord: string): string;
begin
  with SearchManager.NewSearch do
  begin
    StartSearch(':KeyWord(' + KeyWord + '):');
    Result := GUIDToString(WindowID);
  end;
end;

function OpenSearch(StringSearch: string): string;
begin
  with SearchManager.NewSearch do
  begin
    StartSearch(StringSearch);
    Result := GUIDToString(WindowID);
  end;
end;

procedure DoManager;
begin
  if ManagerDB = nil then
    Application.CreateForm(TManagerDB, ManagerDB);
  ManagerDB.Show;
end;

procedure DoOptions;
begin
  if OptionsForm = nil then
    Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.Show;
end;

function NewImageEditor: string;
begin
  with EditorsManager.NewEditor do
  begin
    // Show;
    Result := GUIDToString(WindowID);
    CloseOnFailture := False;
  end;
end;

function NewPanel: string;
begin
  with ManagerPanels.NewPanel do
  begin
    Show;
    SetFocus;
    Result := GUIDToString(WindowID);
  end;
end;

function GetLastPanel: string;
begin
  if ManagerPanels.Count > 0 then
  begin
    Result := GUIDToString(ManagerPanels[ManagerPanels.Count - 1].WindowID);
    Exit;
  end;
  with ManagerPanels.NewPanel do
  begin
    Show;
    SetFocus;
    Result := GUIDToString(WindowID);
  end;
end;

function NewSearch: string;
begin
  with SearchManager.NewSearch do
  begin
    Show;
    SetFocus;
    Result := GUIDToString(WindowID);
  end;
end;

function NewExplorerByPath(Path: string): string;
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetStringPath(Path, False);
    Show;
    Result := GUIDToString(WindowID);
  end;
end;

function NewExplorer: string;
begin
  with ExplorerManager.NewExplorer(True) do
  begin
    Show;
    Result := GUIDToString(WindowID);
  end;
end;

function SelectDir(Text: string): string;
var
  Dir: string;
begin
  Result := '';
  Text := TA(Text, 'DBMenu');
  Dir := UnitDBFileDialogs.DBSelectDir(Application.Handle, Text, UseSimpleSelectFolderDialog);
  if Dir <> '' then
    Result := IncludeTrailingBackslash(Dir);
end;

procedure AMakeDBFileTree;
begin
  MakeDBFileTree(Dbname);
end;

function ImageFile(FileName: string): Boolean;
begin
  Result := IsGraphicFile(FileName);
end;

procedure ShowFile(FileName: string);
var
  Info: TDBPopupMenuInfo;
  InfoItem: TDBPopupMenuInfoRecord;
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);

  Info := TDBPopupMenuInfo.Create;
  try
    InfoItem := TDBPopupMenuInfoRecord.CreateFromFile(FileName);
    try
      Info.Add(InfoItem);
      Viewer.Execute(nil, Info);
      Viewer.Show;
    finally
      F(InfoItem);
    end;
  finally
    F(Info);
  end;
end;

function SplitLinks(Links, NoParam: string): TArrayOfString;
var
  Info: TLinksInfo;
  I: Integer;
begin
  Info := ParseLinksInfo(Links);
  SetLength(Result, Length(Info));
  for I := 0 to Length(Info) - 1 do
    Result[I] := CodeLinkInfo(Info[I]);
end;

function ALinkName(Link: string): string;
var
  Info: TLinksInfo;
begin
  Info := ParseLinksInfo(Link);
  if Length(Info) > 0 then
    Result := Info[0].LinkName;
end;

function ALinkValue(Link: string): string;
var
  Info: TLinksInfo;
begin
  Info := ParseLinksInfo(Link);
  if Length(Info) > 0 then
    Result := Info[0].LinkValue;
end;

function ALinkType(Link: string): Integer;
var
  Info: TLinksInfo;
begin
  Info := ParseLinksInfo(Link);
  if Length(Info) > 0 then
    Result := Info[0].LinkType
  else
    Result := -1;
end;

function ALinkTypeString(Link: string): string;
var
  Info: TLinksInfo;
begin
  Info := ParseLinksInfo(Link);
  if Length(Info) > 0 then
    Result := LinkType(Info[0].LinkType);
end;

function GetFileNameByIDEx(IDEx: string): string;
var
  TIRA: TImageDBRecordA;
begin
  TIRA := GetimageIDTh(IDEx);
  if TIRA.Count > 0 then
    Result := TIRA.FileNames[0];
end;

function GetIDByIDEx(IDEx: string): Integer;
var
  TIRA: TImageDBRecordA;
begin
  TIRA := GetimageIDTh(IDEx);
  if TIRA.Count > 0 then
    Result := TIRA.IDs[0]
  else
    Result := 0;
end;

procedure AHint(Caption, Text: string);
var
  P: TPoint;
begin
  GetCursorPos(P);
  DoHelpHint(Caption, Text, P, nil);
end;

procedure CloseApp;
begin
  if FormManager <> nil then
    FormManager.CloseApp(nil);
end;

function GetExplorerByCID(CID : string) : TExplorerForm;
var
  I: Integer;
begin
  Result := nil;

  if ExplorerManager <> nil then
  begin
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
    begin
      if CID = GUIDToString(ExplorerManager[I].WindowID) then
      begin
        Result := ExplorerManager[I];
        Break;
      end;
    end;
  end;
end;

function GetExplorers: TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if ExplorerManager <> nil then
  begin
    SetLength(Result, ExplorerManager.ExplorersCount);
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
      Result[I] := GUIDToString(ExplorerManager[I].WindowID);
  end;
end;

function GetExplorerByPath(Path: string): string;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if ExplorerManager <> nil then
  begin
    SetLength(Result, ExplorerManager.ExplorersCount);
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
      if AnsiLowerCase(ExplorerManager[I].GetCurrentPath) = AnsiLowerCase(Path) then
      begin
        Result := GUIDToString(ExplorerManager[I].WindowID);
        Break;
      end;
  end;
end;

function GetExplorersByPath(Path, nil_ : string) : TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if ExplorerManager <> nil then
  begin
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
      if AnsiLowerCase(ExplorerManager[I].GetCurrentPath) = AnsiLowerCase(Path) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := GUIDToString(ExplorerManager[I].WindowID);
        Break;
      end;
  end;
end;

function GetExplorerPath(CID: string): string;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if ExplorerManager <> nil then
  begin
    SetLength(Result, ExplorerManager.ExplorersCount);
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
      if CID = GUIDToString(EditorsManager[I].WindowID) then
      begin
        Result := ExplorerManager[I].GetCurrentPath;
        Break;
      end;
  end;
end;

function SetExplorerPath(CID, Path : string) : string;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if ExplorerManager <> nil then
  begin
    SetLength(Result, ExplorerManager.ExplorersCount);
    for I := 0 to ExplorerManager.ExplorersCount - 1 do
      if CID = GUIDToString(EditorsManager[I].WindowID) then
      begin
        ExplorerManager[I].SetStringPath(Path, False);
        Break;
      end;
  end;
end;

function GetSearchByCID(CID : string) : TSearchCustomForm;
var
  I: Integer;
begin
  Result := nil;
  if SearchManager <> nil then
  begin
    for I := 0 to SearchManager.SearchCount - 1 do
    begin
      if CID = GUIDToString(SearchManager[I].WindowID) then
      begin
        Result := SearchManager[I];
        Break;
      end;
    end;
  end;
end;

function GetPanelByCID(CID: string): TFormCont;
var
  I: Integer;
begin
  Result := nil;
  if ManagerPanels <> nil then
  begin
    for I := 0 to ManagerPanels.Count - 1 do
    begin
      if CID = GUIDToString(ManagerPanels[I].WindowID) then
      begin
        Result := ManagerPanels[I];
        Break;
      end;
    end;
  end;
end;

function GetSearchTextByCID(CID: string): string;
var
  I: Integer;
begin
  Result := '';
  if SearchManager <> nil then
  begin
    SetLength(Result, SearchManager.SearchCount);
    for I := 0 to SearchManager.SearchCount - 1 do
    begin
      if CID = GUIDToString(SearchManager[I].WindowID) then
      begin
        Result := SearchManager[I].SearchText;
        Break;
      end;
    end;
  end;
end;

Procedure SetSearchText(CID, Text : string);
var
  I: Integer;
begin
  if SearchManager <> nil then
  begin
    for I := 0 to SearchManager.SearchCount - 1 do
    begin
      if CID = GUIDToString(SearchManager[I].WindowID) then
      begin
        SearchManager[I].SearchText := Text;
        Break;
      end;
    end;
  end;
end;

Procedure DoSearch(CID : string);
var
  I: Integer;
begin
  if SearchManager <> nil then
  begin
    for I := 0 to SearchManager.SearchCount - 1 do
    begin
      if CID = GUIDToString(SearchManager[I].WindowID) then
      begin
        SearchManager[I].StartSearch;
        Break;
      end;
    end;
  end;
end;

function GetSearchs: TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, 0);
  if SearchManager <> nil then
  begin
    SetLength(Result, SearchManager.SearchCount);
    for I := 0 to SearchManager.SearchCount - 1 do
    begin
      Result[I] := GUIDToString(SearchManager[I].WindowID);
    end;
  end;
end;

function GetProgressByCID(CID: string): TProgressActionForm;
var
  I: Integer;
begin
  Result := nil;
  if ManagerProgresses <> nil then
  begin
    for I := 0 to ManagerProgresses.ProgressCount - 1 do
    begin
      if CID = GUIDToString(ManagerProgresses[I].WindowID) then
      begin
        Result := ManagerProgresses[I];
        Break;
      end;
    end;
  end;
end;

function GetProgressWindow(Text: string): string;
begin
  with ManagerProgresses.NewProgress do
  begin
    OneOperation := True;
    MaxPosCurrentOperation := 100;
    if Text <> '' then
      Label1.Caption := Text;
    Result := GUIDToString(WindowID);
  end;
end;

function SetProgressWindowProgress(CID: string; Progress, Nil1: Integer): string;
begin
  GetProgressByCID(CID).XPosition := Progress;
  Result := '';
end;

function GetImageEditorByCID(CID: string): TImageEditor;
var
  I: Integer;
begin
  Result := nil;
  if EditorsManager <> nil then
  begin
    for I := 0 to EditorsManager.EditorsCount - 1 do
    begin
      if CID = GUIDToString(EditorsManager[I].WindowID) then
      begin
        Result := EditorsManager[I];
        Break;
      end;
    end;
  end;
end;

procedure CloseDBForm(CID: string);
begin
  if GetImageEditorByCID(CID) <> nil then
    GetImageEditorByCID(CID).Close;

  if GetSearchByCID(CID) <> nil then
    GetSearchByCID(CID).Close;
  if GetExplorerByCID(CID) <> nil then
    GetExplorerByCID(CID).Close;
  if GetPanelByCID(CID) <> nil then
    GetPanelByCID(CID).Close;

  if GetProgressByCID(CID) <> nil then
  begin
    with GetProgressByCID(CID) do
    begin
      Close;
      Release;
    end;
  end;
end;

procedure ShowDBForm(CID : string);
begin
  if GetImageEditorByCID(CID) <> nil then
    GetImageEditorByCID(CID).Show;
  if GetSearchByCID(CID) <> nil then
    GetSearchByCID(CID).Show;
  if GetExplorerByCID(CID) <> nil then
    GetExplorerByCID(CID).Show;
  if GetProgressByCID(CID) <> nil then
    GetProgressByCID(CID).DoFormShow;
  if GetPanelByCID(CID) <> nil then
    GetPanelByCID(CID).Show;
end;

function GetDBNameList: TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, DBkernel.DBs.Count);
  for I := 0 to DBkernel.DBs.Count - 1 do
  begin
    Result[I] := DBkernel.DBs[I].name;
  end;
end;

function GetDBFileList: TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, DBkernel.DBs.Count);
  for I := 0 to DBkernel.DBs.Count - 1 do
  begin
    Result[I] := DBkernel.DBs[I].FileName;
  end;
end;

function GetDBIcoList: TArrayOfString;
var
  I: Integer;
begin
  SetLength(Result, DBkernel.DBs.Count);
  for I := 0 to DBkernel.DBs.Count - 1 do
  begin
    Result[I] := DBkernel.DBs[I].Icon;
  end;
end;

function AAnsiLowerCase(S: string): string;
begin
  Result := AnsiLowerCase(S);
end;

function AAnsiUpperCase(S: string): string;
begin
  Result := AnsiUpperCase(S);
end;

function AChar(Int: Integer): string;
begin
  Result := Char(Int);
end;

function GetCurrentDB: string;
begin
  Result := Dbname;
end;

function FindPasswordForCryptImageFile(FileName: string): string;
begin
  Result := DBKernel.FindPasswordForCryptImageFile(FileName);
end;

procedure AddDBFile;
var
  DBFile: TPhotoDBFile;
begin
  DBFile := DoChooseDBFile();
  if DBKernel.TestDB(DBFile.FileName) then
    DBKernel.AddDB(DBFile.name, DBFile.FileName, DBFile.Icon);
end;

function Compare2Images(File1, File2 : string; raz : integer) : integer;
var
  G1, G2 : TGraphic;
  pass1, pass2 : string;
  r : integer;
  CompResult : TImageCompareResult;
begin
  Result := 0;
  if not FileExistsSafe(File1) then
    Exit;
  if not FileExistsSafe(File2) then
    Exit;
  G1 := nil;
  G2 := nil;
  if ValidCryptGraphicFile(File1) then
  begin
    Pass1 := DBKernel.FindPasswordForCryptImageFile(File1);
    if Pass1 = '' then
      Exit;
  end;
  if ValidCryptGraphicFile(File2) then
  begin
    Pass2 := DBKernel.FindPasswordForCryptImageFile(File2);
    if Pass2 = '' then
      Exit;
  end;
  try
    if Pass1 = '' then
    begin
      G1 := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(File1)).Create;
      G1.LoadFromFile(File1);
    end  else
      G1 := GraphicCrypt.DeCryptGraphicFile(File1, Pass1);
  except
    F(G1);
    Exit;
  end;
  try
    if Pass2 = '' then
    begin
      G2 := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(File2)).Create;
      G2.LoadFromFile(File2);
    end else
      G2 := GraphicCrypt.DeCryptGraphicFile(File2, Pass2);
  except
    F(G1);
    F(G2);
    Exit;
  end;
  CompResult := CompareImages(G1, G2, R, True, False, Raz);
  Result := Max(CompResult.ByGistogramm, CompResult.ByPixels);
  F(G1);
  F(G2);
end;

function PromtUserCryptImageFile(FileName: string): string;
begin
  Result := GetPassForCryptImageFile(FileName).Password;
end;

function CryptGraphicFile(FileName, Password: string): Integer;
begin
  Result := CryptGraphicFileV2(FileName, Password, 0);
end;

function APromtString(Caption, Text, InitialString: string): string;
begin
  Result := InitialString;
  PromtString(Caption, Text, Result);
end;

function TestDB(DB: string): Boolean;
begin
  Result := DBKernel.TestDB(DB);
end;

procedure AddFileToPanel(CID, FileName: string);
begin
  if GetPanelByCID(CID) <> nil then
    GetPanelByCID(CID).AddFileName(FileName);
end;

function ExecuteActions(CID, FileName, ToFileName : string): string;
var
  AActions: TStrings;
begin
  if GetImageEditorByCID(CID) <> nil then
  begin
    AActions := TStringList.Create;
    try
      if LoadActionsFromfileA(FileName, AActions) then
      begin
        GetImageEditorByCID(CID).ReadActions(AActions);
        GetImageEditorByCID(CID).SaveImageFile(ToFileName, True);
      end;
    finally
      F(AActions);
    end;
  end;
  Result := '';
end;

function ImageEditorRegisterCallBack(CID, ID, Proc: string): string;
begin
  if GetImageEditorByCID(CID) <> nil then
  begin
    GetImageEditorByCID(CID).FScript := ID;
    GetImageEditorByCID(CID).FScriptProc := Proc;
  end;
  Result := '';
end;

function ImageEditorOpenFileName(CID, FileName: string): string;
begin
  if GetImageEditorByCID(CID) <> nil then
    GetImageEditorByCID(CID).OpenFileName(FileName);
end;

function GetImagesMask: string;
begin
  Result := TFileAssociations.Instance.ExtensionList;
end;

function DoSelectDB(FormID, DbName: string): string;
var
  Form: TDBForm;
begin
  Form := TFormCollection.Instance.GetForm(FormID);
  if Form <> nil then
    SelectDB(Form, DbName);
end;

function GetProgramPath: string;
begin
  Result := Application.ExeName;
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

 AddScriptFunction(Enviroment,'DoDesteno',F_TYPE_PROCEDURE_STRING,@ExtractDataFromImage);
 AddScriptFunction(Enviroment,'DoSteno',F_TYPE_PROCEDURE_STRING,@HideDataInImage);

 AddScriptFunction(Enviroment,'DoCDExport',F_TYPE_PROCEDURE_NO_PARAMS,@DoCDExport);
 AddScriptFunction(Enviroment,'DoCDMapping',F_TYPE_PROCEDURE_NO_PARAMS,@DoManageCDMapping);
 AddScriptFunction(Enviroment,'SelectDB',F_TYPE_PROCEDURE_STRING_STRING,@DoSelectDB);
end;

procedure InitEnviroment(Enviroment : TScriptEnviroment);
begin
  LoadBaseFunctions(Enviroment);
  LoadDBFunctions(Enviroment);
  LoadFileFunctions(Enviroment);
end;

initialization

  InitScriptFunction := @InitializeScriptString;

end.
