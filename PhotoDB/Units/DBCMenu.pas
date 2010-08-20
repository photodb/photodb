unit DBCMenu;

interface

uses
  StdCtrls, UnitGroupsWork, ComCtrls, Dolphin_DB,
  dialogs,ExtCtrls, ShlObj, ComObj, ActiveX, Math, Controls, Filectrl,
  forms, Registry, ShellApi, Windows, SysUtils, Classes, DB,
  Graphics, Menus, UnitDBKernel, UnitCryptImageForm, GraphicCrypt,
  ProgressActionUnit, PrintMainForm, JPEG, ShellContextMenu, uVistaFuncs,
  UnitSQLOptimizing, UnitScripts, DBScriptFunctions, UnitRefreshDBRecordsThread,
  EasyListview, UnitCryptingImagesThread, UnitINI, UnitDBDeclare,
  UnitDBCommonGraphics, uScript, uLogger, uFileUtils;

type TDBPopupMenu = class
   private
    _popupmenu : TPopupMenu;
    _user_group_menu : TMenuItem;
    _user_group_menu_sub_items : array of TMenuItem;
    _user_menu : array of TMenuItem;
    FInfo : TDBPopupMenuInfo;
    FPopUpPoint : TPoint;
    FUserMenu : TUserMenuItemArray;
    FBusy : Boolean;
    aScript : TScript;
   public
    class function Instance : TDBPopupMenu;
    constructor Create;
    destructor Destroy; override;
    Procedure ShowItemPopUpMenu_(Sender : TObject);
 Procedure ShellExecutePopUpMenu_(Sender : TObject);
 Procedure SearchFolderPopUpMenu_(Sender : TObject);
 Procedure DeleteLItemPopUpMenu_(Sender : TObject);
 Procedure DeleteItemPopUpMenu_(Sender : TObject);
 Procedure RefreshThumItemPopUpMenu_(Sender : TObject);
 Procedure PropertyItemPopUpMenu_(Sender : TObject);
 Procedure ScanImageItemPopUpMenu_(Sender : TObject);
 Procedure SetRatingItemPopUpMenu_(Sender : TObject);
 Procedure SetRotateItemPopUpMenu_(Sender : TObject);
 Procedure PrivateItemPopUpMenu_(Sender : TObject);
 Procedure RenameItemPopUpMenu_(Sender : TObject);
 Procedure CopyItemPopUpMenu_(Sender : TObject);
 Procedure SendToItemPopUpMenu_(Sender : TObject);
 Procedure ExplorerPopUpMenu_(Sender : TObject);
 Procedure GroupsPopUpMenu_(Sender : TObject);
 Procedure DateItemPopUpMenu_(Sender : TObject);
 Procedure CryptItemPopUpMenu_(Sender : TObject);
 Procedure DeCryptItemPopUpMenu_(Sender : TObject);
 Procedure QuickGroupInfoPopUpMenu_(Sender : TObject);
 Procedure EnterPasswordItemPopUpMenu_(Sender : TObject);
 Procedure ImageEditorItemPopUpMenu_(Sender : TObject);
 Procedure WallpaperStretchItemPopUpMenu_(Sender : TObject);
 Procedure WallpaperCenterItemPopUpMenu_(Sender : TObject);
 Procedure WallpaperTileItemPopUpMenu_(Sender : TObject);
 Procedure RefreshIDItemPopUpMenu_(Sender : TObject);
 Procedure ShowDublicatesItemPopUpMenu_(Sender : TObject);
 Procedure DeleteDublicatesItemPopUpMenu_(Sender : TObject);
 Procedure UserMenuItemPopUpMenu_(Sender : TObject);
 Procedure PrintItemPopUpMenu_(Sender : TObject);
 Procedure Execute(x,y : integer; info : TDBPopupMenuInfo);
 Procedure ExecutePlus(x,y : integer; info : TDBPopupMenuInfo; Menus : TArMenuitem);
 Procedure AddDBContMenu(item : tmenuitem; info : TDBPopupMenuInfo);
 Procedure AddUserMenu(item : tmenuitem; Insert : Boolean; Index : integer);
 Procedure SetInfo(Info : TDBPopupMenuInfo);
 Procedure ScriptExecuted(Sender : TObject);
 Function GetGroupImageInImageList(GroupCode : string) : integer;
 Function LoadVariablesNo(int : integer) : integer;
  published
 end;

 procedure ReloadIDMenu;

var
   MenuScript : string;
   aFS : TFileStream;

implementation

uses ExplorerUnit, PropertyForm, SlideShow, Searching, UnitFormCont,
     UnitLoadFilesToPanel, UnitEditGroupsForm, UnitMenuDateForm, CmpUnit,
     UnitQuickGroupInfo, Language, UnitCrypting, UnitPasswordForm,
     AddSessionPasswordUnit, ImEditor, FormManegerUnit, CommonDBSupport,
     UnitCDMappingSupport;

 var
   DBPopupMenu: TDBPopupMenu = nil;

{ TDBPopupMenu }

procedure ReloadIDMenu;
begin
 MenuScript:=ReadScriptFile('scripts\IDMenu.dbini');
end;

procedure TDBPopupMenu.AddDBContMenu(item: TMenuItem;
  info: TDBPopupMenuInfo);
var
  I : integer;
  isrecord, IsFile, IsCurrentFile : boolean;
  PanelsTexts : TStrings;
  MenuGroups : TGroups;
  GroupsList : TStringList;
  StrGroups, script : String;
  BusyMenu, ErrorMenu : TMenuItem;
  OnlyCurrentDBinfoSelected : Boolean;
  NoDBInfoNeeded : boolean;
  aPanelTexts, aGroupsNames, aGroupsCodes : TArrayOfString;

Const
  ShowGroupsInContextMenu = True;
begin
 if FBusy then
 begin
  for i:=0 to item.Count-1 do
  item.Delete(0);
  BusyMenu:=Tmenuitem.Create(_popupmenu);
  BusyMenu.Caption:=TEXT_MES_MENU_BUSY;
  BusyMenu.Enabled:=false;
  Item.Add(BusyMenu);
  Exit;
 end;
 If info.Count=0 then
 begin
  for i:=0 to item.Count-1 do
  item.Delete(0);
  ErrorMenu:=TMenuItem.Create(_popupmenu);
  ErrorMenu.Caption:=TEXT_MES_MENU_NOT_AVALIABLE_0;
  ErrorMenu.Enabled:=false;
  Item.Add(ErrorMenu);
  Exit;
 end;

 finfo:=info;
 isrecord:=true;
 if info.Count=1 then
 if info[0].ID=0 then isrecord:=false;
 for i:=0 to item.Count-1 do
 item.Delete(0);

 if info.Count>1 then
 begin
  isrecord:=false;
  for i:=0 to info.Count-1 do
  if info[0].ID<>0 then isrecord:=true;
 end;
 NoDBInfoNeeded:=false;

 OnlyCurrentDBinfoSelected:=true;
 if info.Count>1 then
 for i:=0 to info.Count-1 do
 if info[I].ID<>0 then
 if info[i].Selected then
 if info.Position<>i then
 OnlyCurrentDBinfoSelected:=false;
 if info[info.Position].Selected then
 if info[info.Position].ID=0 then
 if not OnlyCurrentDBinfoSelected then
 NoDBInfoNeeded:=true;
 if not isrecord then NoDBInfoNeeded:=true;
 if info[info.Position].ID=0 then NoDBInfoNeeded:=true;

 IsFile:=false;
 IsCurrentFile:=FileExists(info[info.Position].FileName);
 for i:=0 to info.Count - 1 do
 if FileExists(info[i].FileName) then
 begin
  IsFile:=True;
  Break;
 end;
 SetLength(MenuGroups,0);

  script:=MenuScript;

  SetBoolAttr(aScript,'$CanRename',Info.IsListItem);
  SetBoolAttr(aScript,'$IsRecord',IsRecord);
  SetBoolAttr(aScript,'$IsFile',IsFile);
  SetBoolAttr(aScript,'$NoDBInfoNeeded',NoDBInfoNeeded);

  SetIntAttr(aScript,'$MenuLength',Info.Count);
  SetIntAttr(aScript,'$Position',Info.Position);
  
  //if user haven't rights to get FileName its only possible way to know
  SetBoolAttr(aScript,'$FileExists',FileExists(Info[Info.Position].FileName));

// END Access section
  SetBoolAttr(aScript,'$IsCurrentFile',IsCurrentFile);

  LoadVariablesNo(info.Position);

  PanelsTexts := TStringList.Create;
  PanelsTexts.Assign(UnitFormCont.ManagerPanels.GetPanelsTexts);
  SetLength(aPanelTexts,PanelsTexts.Count);
  for i:=0 to PanelsTexts.Count-1 do
  aPanelTexts[i]:=PanelsTexts[i];
  PanelsTexts.free;
  SetNamedValueArrayStrings(aScript,'$Panels',aPanelTexts);
  GroupsList := TStringList.Create;
  for i:=0 to FInfo.Count-1 do
  if FInfo[i].Selected then
  begin
    GroupsList.Add(FInfo[i].Groups);
  end;
  SetNamedValueArrayStrings(aScript,'$Panels',aPanelTexts);
  StrGroups:=GetCommonGroups(GroupsList);
  MenuGroups:=EnCodeGroups(StrGroups);
  SetLength(aGroupsNames,Length(MenuGroups));
  SetLength(aGroupsCodes,Length(MenuGroups));
  for i:=0 to Length(MenuGroups)-1 do
  begin
   aGroupsNames[i]:=MenuGroups[i].GroupName;
   aGroupsCodes[i]:=MenuGroups[i].GroupCode;
  end;
  SetNamedValueArrayStrings(aScript,'$GroupsNames',aGroupsNames);
  SetNamedValueArrayStrings(aScript,'$GroupsCodes',aGroupsCodes);
  LoadMenuFromScript(item,DBKernel.ImageList,script,aScript,ScriptExecuted,FExtImagesInImageList,true);
end;

procedure TDBPopupMenu.AddUserMenu(Item: TMenuItem; Insert : Boolean; Index : integer);
var
  reg : TBDRegistry;
  S : TStrings;
  i, c : integer;
  fCaption,EXEFile,Params,Icon : String;
  UseSubMenu : Boolean;
  Ico : TIcon;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);

  Reg.OpenKey(GetRegRootKey+'\Menu',true);
  S := TStringList.create;
  Reg.GetKeyNames(S);
  SetLength(FUserMenu,0);
  SetLength(_user_group_menu_sub_items,0);
  SetLength(_user_menu,0);
  c:=0;
  for i:=0 to S.Count-1 do
  begin
   Reg.CloseKey;
   Reg.OpenKey(GetRegRootKey+'\Menu\'+s[i],true);
   if Reg.ValueExists('Caption') then
   fCaption:=Reg.ReadString('Caption') else fCaption:='NO_CAPTION';
   if Reg.ValueExists('EXEFile') then
   EXEFile:=Reg.ReadString('EXEFile') else EXEFile:='Explorer.exe';
   if Reg.ValueExists('Params') then
   Params:=Reg.ReadString('Params') else Params:='';
   if Reg.ValueExists('Icon') then
   Icon:=Reg.ReadString('Icon') else Icon:='';
   if Reg.ValueExists('UseSubMenu') then
   UseSubMenu:=Reg.ReadBool('UseSubMenu') else UseSubMenu:=false;
   if (fCaption<>'') and (EXEFile<>'') then
   begin
    SetLength(FUserMenu,Length(FUserMenu)+1);
    FUserMenu[Length(FUserMenu)-1].Caption:=fCaption;
    FUserMenu[Length(FUserMenu)-1].EXEFile:=EXEFile;
    FUserMenu[Length(FUserMenu)-1].Params:=Params;
    FUserMenu[Length(FUserMenu)-1].Icon:=Icon;
    FUserMenu[Length(FUserMenu)-1].UseSubMenu:=UseSubMenu;
    if UseSubMenu then inc(c);
   end;
  end;
  if c>0 then
  begin
   _user_group_menu := TMenuItem.Create(item);
   if DBKernel.ReadString('','UserMenuName')<>'' then
   _user_group_menu.Caption:=DBKernel.ReadString('','UserMenuName') else
   _user_group_menu.Caption:=TEXT_MES_USER_SUBMENU;
   icon:=DBKernel.ReadString('','UserMenuIcon');
   if icon='' then icon:='%SystemRoot%\system32\shell32.dll,126';
   Ico:=GetSmallIconByPath(Icon);
   if not Ico.Empty then
   begin
    inc(FExtImagesInImageList);
    DBkernel.ImageList.AddIcon(ico);
    _user_group_menu.ImageIndex:=DBkernel.ImageList.Count-1;
   end else
   _user_group_menu.ImageIndex:=DB_IC_COMPUTER;

  end;
  for i:=0 to Length(FUserMenu)-1 do
  begin
   if FUserMenu[i].UseSubMenu then
   begin
    SetLength(_user_group_menu_sub_items, Length(_user_group_menu_sub_items)+1);
    _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1]:=TMenuItem.Create(_user_group_menu);
    _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1].Caption:=FUserMenu[i].Caption;
    _user_group_menu.Add(_user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1]);
    _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1].Tag:=i;
    _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1].OnClick:=UserMenuItemPopUpMenu_;
    Ico:=GetSmallIconByPath(FUserMenu[i].Icon);
    if not Ico.Empty then
    begin
     inc(FExtImagesInImageList);
     DBkernel.ImageList.AddIcon(ico);
     _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1].ImageIndex:=DBkernel.ImageList.Count-1;
    end else
    _user_group_menu_sub_items[Length(_user_group_menu_sub_items)-1].ImageIndex:=DB_IC_COMPUTER;
    Ico.Free;
   end else
   begin
    SetLength(_user_menu, Length(_user_menu)+1);
    _user_menu[Length(_user_menu)-1]:=TMenuItem.Create(item);
    _user_menu[Length(_user_menu)-1].Caption:=FUserMenu[i].Caption;
    _user_menu[Length(_user_menu)-1].Tag:=i;
    _user_menu[Length(_user_menu)-1].OnClick:=UserMenuItemPopUpMenu_;
    Ico:=GetSmallIconByPath(FUserMenu[i].Icon);
    if not Ico.Empty then
    begin
     inc(FExtImagesInImageList);
     DBkernel.ImageList.AddIcon(ico);
     _user_menu[Length(_user_menu)-1].ImageIndex:=DBkernel.ImageList.Count-1;
    end else
    _user_menu[Length(_user_menu)-1].ImageIndex:=DB_IC_COMPUTER;
    Ico.Free;
   end;
  end;
  if c>0 then
  if Insert then item.Insert(Index,_user_group_menu) else
  item.Add(_user_group_menu);
  if Insert then
  begin
   for i:=0 to Length(_user_menu)-1 do
   item.Insert(Index,_user_menu[i]);
  end else
  item.Add(_user_menu);
  S.free;
  Reg.free;
end;

procedure TDBPopupMenu.CopyItemPopUpMenu_(Sender: TObject);
var
  I : integer;
  FileList : TStrings;
begin
  FileList := TStrings.Create;
  try
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        if FileExists(FInfo[I].FileName) then
          FileList.Add(FInfo[I].FileName);

    Copy_Move(True, FileList);
  finally
    FileList.Free;
  end;
end;

constructor TDBPopupMenu.create;
begin
  inherited;

  FBusy:=false;
  aScript := TScript.Create('');
  aScript.Description:='ID Menu'; 
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShellExecutePopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShellExecutePopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SearchFolderPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SearchFolderPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'DeleteLItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteLItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'DeleteItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'RefreshThumItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RefreshThumItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'PropertyItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PropertyItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ScanImageItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ScanImageItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetRatingItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SetRatingItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetRotateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SetRotateItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'PrivateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PrivateItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'RenameItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RenameItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CopyItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,CopyItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SendToItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SendToItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ExplorerPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ExplorerPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GroupsPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,GroupsPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'DateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DateItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CryptItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,CryptItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'DeCryptItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeCryptItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'QuickGroupInfoPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,QuickGroupInfoPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'EnterPasswordItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,EnterPasswordItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ImageEditorItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ImageEditorItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'WallpaperStretchItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperStretchItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'WallpaperCenterItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperCenterItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'WallpaperTileItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperTileItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'RefreshIDItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RefreshIDItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowDublicatesItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowDublicatesItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'DeleteDublicatesItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteDublicatesItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'UserMenuItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,UserMenuItemPopUpMenu_);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'PrintItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PrintItemPopUpMenu_);

  AddScriptObjFunctionStringIsInteger( aScript.PrivateEnviroment, 'GetGroupImage',Self.GetGroupImageInImageList);
  AddScriptObjFunctionIntegerIsInteger(aScript.PrivateEnviroment,' LoadVariablesNo',Self.LoadVariablesNo);

  _popupmenu:=Tpopupmenu.Create(nil);
end;

procedure TDBPopupMenu.CryptItemPopUpMenu_(Sender: TObject);
var
 Options : TCryptImageThreadOptions;
 Opt : TCryptImageOptions;   
 CryptOptions : integer;
begin
 Opt:=GetPassForCryptImageFile(TEXT_MES_SELECTED_OBJECTS);
 if Opt.SaveFileCRC then CryptOptions:=CRYPT_OPTIONS_SAVE_CRC else CryptOptions:=CRYPT_OPTIONS_NORMAL;
 if Opt.Password='' then exit;
 //TODO:!!!
{ Options.Files := Copy(FInfo.ItemFileNames_);
 Options.IDs := Copy(FInfo.ItemIDs_);
 Options.Selected := Copy(FInfo.ItemSelected_);   }
 Options.Password := Opt.Password;
 Options.CryptOptions := CryptOptions;
 Options.Action := ACTION_CRYPT_IMAGES;
 TCryptingImagesThread.Create(False, Options);
end;

procedure TDBPopupMenu.DateItemPopUpMenu_(Sender: TObject);
var
  ArDates : TArDateTime;
  ArTimes : TArTime;
  ArIsDates : TArBoolean;
  ArIsTimes : TArBoolean;
  Date : TDateTime;
  i : integer;
  Time : TDateTime;
  IsDate, IsTime, Changed, FirstID : Boolean;
  _sqlexectext : string;
  FQuery : TDataSet;
  EventInfo : TEventValues;
begin
 SetLength(ArDates,0);
 SetLength(ArIsDates,0);
 SetLength(ArTimes,0);
 SetLength(ArIsTimes,0);
 for i:=0 to FInfo.Count - 1 do
 if finfo[i].Selected then
 begin
  SetLength(ArDates,Length(ArDates)+1);
  ArDates[Length(ArDates)-1]:=FInfo[i].Date;
  SetLength(ArTimes,Length(ArTimes)+1);
  ArTimes[Length(ArTimes)-1]:=FInfo[i].Time;
  SetLength(ArIsDates,Length(ArIsDates)+1);
  ArIsDates[Length(ArIsDates)-1]:=FInfo[i].IsDate;
  SetLength(ArIsTimes,Length(ArIsTimes)+1);
  ArIsTimes[Length(ArIsTimes)-1]:=FInfo[i].IsTime;
 end;
 IsDate:=MaxStatBool(ArIsDates);
 IsTime:=MaxStatBool(ArIsTimes);
 Date:=MaxStatDate(ArDates);
 Time:=MaxStatTime(ArTimes);
 ChangeDate(Date,IsDate,Changed,Time,IsTime);
 If Changed then
 begin
  FQuery := GetQuery;
  begin
   //[BEGIN] Date Support
   If IsDate then
   begin
    _sqlexectext:='Update $DB$ Set DateToAdd = :Date, IsDate = TRUE Where ID in (';
    FirstID:=True;
    for i:=0 to FInfo.Count-1 do
    if finfo[i].Selected then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo[i].ID)+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo[i].ID)+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    SetDateParam(FQuery,'Date',Date);
    ExecSQL(fQuery);
    EventInfo.Date:=Date;
    EventInfo.IsDate:=True;
    for i:=0 to FInfo.Count-1 do
    if FInfo[i].Selected then
    DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_Date,EventID_Param_IsDate],EventInfo);
   end else
   begin
    _sqlexectext:='Update $DB$ Set IsDate = FALSE Where ID in (';
    FirstID:=True;
    for i:=0 to FInfo.Count - 1 do
    if finfo[i].Selected then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo[i].ID)+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo[i].ID)+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    ExecSQL(fQuery);
    EventInfo.IsDate:=FALSE;
    for i:=0 to FInfo.Count-1 do
    if finfo[i].Selected then
    DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_IsDate],EventInfo);
   end;
   //[END] Date Support
   //[BEGIN] Time Support
   If IsTime then
   begin
    _sqlexectext:='Update $DB$ Set aTime = :aTime, IsTime = TRUE Where ID in (';
    FirstID:=True;
    for i:=0 to FInfo.Count - 1 do
    if finfo[i].Selected then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo[i].ID)+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo[i].ID)+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    SetDateParam(FQuery,'aTime',Time);
    ExecSQL(fQuery);
    EventInfo.Time:=Time;
    EventInfo.IsTime:=True;
    for i:=0 to finfo.Count-1 do
    if finfo[i].Selected then
    DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_Time,EventID_Param_IsTime],EventInfo);
   end else
   begin
    _sqlexectext:='Update $DB$ Set IsTime = FALSE Where ID in (';
    FirstID:=True;
    for i:=0 to FInfo.Count-1 do
    if finfo[i].Selected then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo[i].ID)+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo[i].ID)+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    ExecSQL(fQuery);
    EventInfo.IsTime:=FALSE;
    for i:=0 to FInfo.Count-1 do
    if finfo[i].Selected then
    DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_IsTime],EventInfo);
   end;
   //[END] Time Support
  end;
  FreeDS(fQuery);
 end;
end;

procedure TDBPopupMenu.DeCryptItemPopUpMenu_(Sender: TObject);
var
 i : integer;
 Options : TCryptImageThreadOptions;
 ItemFileNames : TArStrings;
 ItemIDs : TArInteger;
 ItemSelected : TArBoolean;  
 Password : string;
begin

 Password:=DBKernel.FindPasswordForCryptImageFile(FInfo[FInfo.Position].FileName);
 if Password='' then
 if FileExists(FInfo[FInfo.Position].FileName) then
 Password:=GetImagePasswordFromUser(FInfo[FInfo.Position].FileName);

 Setlength(ItemFileNames,FInfo.Count);
 Setlength(ItemIDs,FInfo.Count);
 Setlength(ItemSelected,FInfo.Count);

 //be default unchecked
 for i:=0 to FInfo.Count-1 do
 ItemSelected[i]:=false;

 for i:=0 to FInfo.Count-1 do
 begin
  ItemFileNames[i]:=FInfo[i].FileName;
  ItemIDs[i]:=FInfo[i].ID;
  ItemSelected[i]:=FInfo[i].Selected;
 end;

 Options.Files := Copy(ItemFileNames);
 Options.IDs := Copy(ItemIDs);
 Options.Selected := Copy(ItemSelected);
 Options.Action:=ACTION_DECRYPT_IMAGES;
 Options.Password:=Password;
 Options.CryptOptions:=0;
 TCryptingImagesThread.Create(false, Options);
end;

procedure TDBPopupMenu.DeleteDublicatesItemPopUpMenu_(Sender: TObject);
var
  i, j : integer;
  fQuery : TDataSet;
  EventInfo : TEventValues;
  SQL_ : string;
  Files, S : TArStrings;
  IDs : TArInteger;
begin
 If ID_OK=MessageBoxDB(GetActiveFormHandle,TEXT_MES_DEL_FROM_DB_CONFIRM,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  for i:=0 to finfo.Count - 1 do
  if finfo[i].Selected then
  if finfo[i].Attr=db_attr_dublicate then
  begin
   fQuery:=GetQuery;
   SQL_:='SELECT FFileName, ID FROM $DB$ WHERE (ID<>'+IntToStr(finfo[i].ID)+') AND (StrTh=(SELECT StrTh FROM $DB$ WHERE ID = '+IntToStr(finfo[i].ID)+'))';
   SetSQL(fQuery,SQL_);
   fQuery.Open;
   fQuery.First;
   SetLength(Files,fQuery.RecordCount);
   SetLength(IDs,fQuery.RecordCount);
   For j:=1 to fQuery.RecordCount do
   begin
    Files[j-1]:=fQuery.FieldByName('FFileName').AsString;
    IDs[j-1]:=fQuery.FieldByName('ID').AsInteger;
    fQuery.Next;
   end;
   fQuery.Close;
   SQL_:='DELETE FROM $DB$ WHERE (ID<>'+IntToStr(finfo[i].ID)+') AND (StrTh=(SELECT StrTh FROM $DB$ WHERE ID = '+IntToStr(finfo[i].ID)+'))';
   SetSQL(fQuery,SQL_);
   ExecSQL(fQuery);
   SQL_:='UPDATE $DB$ SET Attr = '+IntToStr(db_attr_norm)+' WHERE (ID='+IntToStr(finfo[i].ID)+')';
   SetSQL(fQuery,SQL_);
   ExecSQL(fQuery);
   EventInfo.Attr:=db_attr_norm;
   DBKernel.DoIDEvent(nil,finfo[i].ID,[EventID_Param_Attr],EventInfo);
   SetLength(S,1);
   for j:=0 to length(Files)-1 do
   begin
    begin
     If fileexists(Files[j]) then
     begin
      try
       S[0]:=Files[j];
       SilentDeleteFiles( Application.Handle, s , true );
      except
      end;
     end;
    end;
    DBKernel.DoIDEvent(nil,IDs[j],[EventID_Param_Delete],EventInfo);
   end;
   FreeDS(fQuery);
  end;
 end;
end;

procedure TDBPopupMenu.DeleteItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  fQuery : TDataSet;
  EventInfo : TEventValues;
  SQL_ : string;
  s : TArStrings;
  FirstID : boolean;
begin
 If ID_OK=MessageBoxDB(GetActiveFormHandle,TEXT_MES_DEL_FROM_DB_CONFIRM,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  fQuery:=GetQuery;
  SQL_:='UPDATE $DB$ SET Attr='+inttostr(db_attr_not_exists)+' WHERE ID in (';
  FirstID:=True;
  for i:=0 to finfo.Count-1 do
  if finfo[i].Selected then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo[i].ID)+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo[i].ID)+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  SetSQL(fQuery,SQL_);
  ExecSQL(fQuery);
  SetLength(s,1);
  for i := 0 to finfo.Count - 1 do
  if finfo[i].Selected then
  begin
   begin
    If fileexists(finfo[i].FileName) then
    begin
     try
      s[0]:=finfo[i].FileName;
      SilentDeleteFiles( Application.Handle, s , true );
     except
     end;
    end;
   end;
   DBKernel.DoIDEvent(nil,finfo[i].ID,[EventID_Param_Delete],EventInfo);
  end;
  FreeDS(fQuery);
 end;
end;

procedure TDBPopupMenu.DeleteLItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  fQuery : TDataSet;
  EventInfo : TEventValues;
  SQL_ : string;
  FirstID : boolean;
begin
 If idOk=MessageBoxDB(GetActiveFormHandle,TEXT_MES_DEL_FROM_DB_CONFIRM,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
 begin
  fQuery:=GetQuery;
  fQuery.active:=false;
  SQL_:='DELETE FROM $DB$ WHERE ID in (';
  FirstID:=True;
  for i:=0 to finfo.Count - 1 do
  if finfo[i].Selected then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo[i].ID)+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo[i].ID)+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  SetSQL(fQuery,SQL_);
  ExecSQL(fQuery);
  for i:=0 to finfo.Count - 1 do
  if finfo[i].Selected then
  DBKernel.DoIDEvent(nil,finfo[i].ID,[EventID_Param_Delete],EventInfo);
  FreeDS(fQuery);
 end;
end;

destructor TDBPopupMenu.destroy;
begin
  _popupmenu.Free;
  _popupmenu:=nil;
  inherited;
end;

procedure TDBPopupMenu.EnterPasswordItemPopUpMenu_(Sender: TObject);
var
  EventInfo : TEventValues;
  Query : TDataSet;
  ID : Integer;
begin
 EventInfo.Image:=nil;
 if fileexists(FInfo[fInfo.Position].FileName) then
 begin
  if GetImagePasswordFromUser(FInfo[fInfo.Position].FileName)<>'' then
  DBKernel.DoIDEvent(Sender,FInfo[fInfo.Position].ID,[EventID_Param_Image],EventInfo);
 end else
 begin
  Query := GetQuery;
  ID:=GetIdByFileName(FInfo[fInfo.Position].FileName);
  if ID=0 then exit;
  SetSQL(Query,'SELECT * from $DB$ where ID='+IntToStr(ID));
  Query.Open;
  if GetImagePasswordFromUserBlob(Query.FieldByName('thum'),FInfo[fInfo.Position].FileName)<>'' then
  DBKernel.DoIDEvent(Sender,FInfo[fInfo.Position].ID,[EventID_Param_Image],EventInfo);
  Query.free;
 end;
end;

procedure TDBPopupMenu.Execute(x, y: integer; info: TDBPopupMenuInfo);
begin
 FPopUpPoint:=Point(X,Y);
 if not FBusy then
 begin
  FInfo:=info;
  if Finfo.Count=0 then
    exit;
  begin
  _popupmenu.Images:=DBKernel.imageList;
  _popupmenu.Items.Clear;
  AddDBContMenu(_popupmenu.items,finfo);
  _popupmenu.Popup(x,y);
  end;
 end else
 begin
  _popupmenu.Items.Clear;
  AddDBContMenu(_popupmenu.items,finfo);
  _popupmenu.Popup(x,y);
 end;
end;

procedure TDBPopupMenu.ExecutePlus(x, y: integer; info: TDBPopupMenuInfo;
  Menus: TArMenuitem);
var
   i :integer;
  _menuitem_nil : tmenuitem;
begin
 FPopUpPoint:=Point(X,Y);
 FInfo:=info;
 if Finfo.Count=0 then exit;
  begin
  
  _popupmenu.Images:=DBKernel.imageList;
  _popupmenu.Items.Clear;
  AddDBContMenu(_popupmenu.items,finfo);
  if length(Menus)>0 then
  begin
   _menuitem_nil:=Tmenuitem.Create(_popupmenu);
   _menuitem_nil.Caption:='-';
   _popupmenu.items.Add(_menuitem_nil);
   for i:=0 to length(Menus)-1 do
   begin
   _popupmenu.items.Add(Menus[i]);
   end;
  end;
  _popupmenu.Popup(x,y);

  end;
end;

procedure TDBPopupMenu.ExplorerPopUpMenu_(Sender: TObject);
begin
 With ExplorerManager.NewExplorer(False) do
 begin
  SetOldPath(FInfo[FInfo.Position].FileName);
  SetPath(GetDirectory(FInfo[FInfo.Position].FileName));
  Show;
 end;
end;

function TDBPopupMenu.GetGroupImageInImageList(GroupCode: string): integer;
var
  FGroup : TGroup;
  B, SmallB : TBitmap;
  size : integer;
begin
 FGroup:=GetGroupByGroupCode(GroupCode,true);
 if FGroup.GroupImage<>nil then
 begin
 if not FGroup.GroupImage.Empty then
  begin
   inc(FExtImagesInImageList);
   B := TBitmap.Create;
   B.PixelFormat:=pf24bit;
   SmallB := TBitmap.Create;
   SmallB.PixelFormat:=pf24bit;
   B.Canvas.Brush.Color:=Graphics.clMenu;
   B.Canvas.Pen.Color:=Graphics.clMenu;
   size:=Max(FGroup.GroupImage.Width,FGroup.GroupImage.Height);
   B.Width:=size;
   B.Height:=size;
   B.Canvas.Rectangle(0,0,size,size);
   B.Canvas.Draw(B.Width div 2 - FGroup.GroupImage.Width div 2, B.Height div 2 - FGroup.GroupImage.Height div 2,FGroup.GroupImage);
   DoResize(16,16,B,SmallB);
   DBKernel.ImageList.Add(SmallB,nil);
   B.Free;
   SmallB.Free;
   Result:=DBKernel.ImageList.Count-1;
  end else Result:=DB_IC_GROUPS;
 end else Result:=DB_IC_GROUPS;
 FreeGroup(FGroup);
end;

procedure TDBPopupMenu.GroupsPopUpMenu_(Sender: TObject);
var
  i, j : integer;
  KeyWordList,
  GroupList : TStringList;
  _sqlexectext, StrOldGroups, StrNewGroups, Groups, OldKeyWords, NewKeyWords, KeyWords : string;
  fQuery : TDataSet;
  EventInfo : TEventValues;
  Count : integer;
  ProgressForm : TProgressActionForm;
  VarkeyWords, VarGroups : boolean;
  List : TSQLList;
  IDs : String;
begin
  FBusy:=true;
  GroupList := TStringList.Create;
  KeyWordList := TStringList.Create;
  Count:=0;
  for i:=0 to FInfo.Count-1 do
    if FInfo[i].Selected then
      inc(Count);

  for i:=0 to FInfo.Count-1 do
    if FInfo[i].Selected then
    begin
     GroupList.Add(FInfo[i].Groups);
     KeyWordList.Add(FInfo[i].KeyWords);
    end;
  StrOldGroups:=GetCommonGroups(GroupList);
  StrNewGroups:=GetCommonGroups(GroupList);
  OldKeyWords:=GetCommonWordsA(KeyWordList);
  NewKeyWords:=OldKeyWords;
  DBChangeGroups(StrNewGroups,NewKeyWords);
  VarKeyWords:=VariousKeyWords(OldKeyWords,NewKeyWords);
  VarGroups:=not CompareGroups(StrOldGroups,StrNewGroups);
  if not VarKeyWords and not VarGroups then
  begin
   FBusy:=false;
   exit;
  end;
  fQuery := GetQuery;
  ProgressForm:=GetProgressWindow;
  ProgressForm.MaxPosCurrentOperation:=Count;
  ProgressForm.OneOperation:=false;
  if Count>2 then
  ProgressForm.DoShow;
  ProgressForm.xPosition:=0;
  if VarKeyWords and VarGroups then
  ProgressForm.OperationCount:=2 else
  ProgressForm.OperationCount:=1;
  ProgressForm.OperationPosition:=1;
  FreeSQLList(List);
  if VarKeyWords then
  for i:=0 to FInfo.Count-1 do
    if FInfo[i].Selected then
    begin
     KeyWords:=FInfo[i].KeyWords;
     ReplaceWords(OldKeyWords,NewKeyWords,KeyWords);
     if VariousKeyWords(KeyWords,FInfo[i].KeyWords) then
     begin
      AddQuery(List,KeyWords,FInfo[i].ID);
     end;
    end;
  PackSQLList(List,VALUE_TYPE_KEYWORDS);
  ProgressForm.MaxPosCurrentOperation:=Length(List);
  for i:=0 to Length(List)-1 do
  begin
   IDs:='';
   for j:=0 to Length(List[i].IDs)-1 do
   begin
    if j<>0 then IDs:=IDs+' , ';
    IDs:=IDs+' '+IntToStr(List[i].IDs[j])+' ';
   end;
   ProgressForm.xPosition:=ProgressForm.xPosition+1;
   {!!!}   Application.ProcessMessages;
   _sqlexectext:='Update $DB$ Set KeyWords = "'+NormalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
   fQuery.active:=false;
   SetSQL(fQuery,_sqlexectext);
   ExecSQL(fQuery);
   EventInfo.KeyWords:=List[i].Value;
   for j:=0 to Length(List[i].IDs)-1 do
   DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_KeyWords],EventInfo);
  end;

  FreeDS(fQuery);
  If not CompareGroups(StrNewGroups,StrOldGroups) then
  begin
   FreeSQLList(List);
   fQuery := GetQuery;
   ProgressForm.xPosition:=0;
   if VarKeyWords and VarGroups then
   ProgressForm.OperationPosition:=2 else
   ProgressForm.OperationPosition:=1;
   if VarGroups then
   for i:=0 to FInfo.Count-1 do
   if FInfo[i].Selected then
   begin
    Groups:=FInfo[i].Groups;
    ReplaceGroups(StrOldGroups,StrNewGroups,Groups);
    if not CompareGroups(Groups,FInfo[i].Groups) then
    begin
     AddQuery(List,Groups,FInfo[i].ID);
    end;
   end;

   PackSQLList(List,VALUE_TYPE_GROUPS);
   ProgressForm.MaxPosCurrentOperation:=Length(List);
   for i:=0 to Length(List)-1 do
   begin
    IDs:='';
    for j:=0 to Length(List[i].IDs)-1 do
    begin
     if j<>0 then IDs:=IDs+' , ';
     IDs:=IDs+' '+IntToStr(List[i].IDs[j])+' ';
    end;
    ProgressForm.xPosition:=ProgressForm.xPosition+1;
    {!!!}   Application.ProcessMessages;
    _sqlexectext:='Update $DB$ Set Groups = "'+normalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
    fQuery.active:=false;
    SetSQL(fQuery,_sqlexectext);
    ExecSQL(fQuery);
    EventInfo.Groups:=List[i].Value;
    for j:=0 to Length(List[i].IDs)-1 do
    DBKernel.DoIDEvent(Sender,List[i].IDs[j],[EventID_Param_Groups],EventInfo);
   end;
   FreeDS(fQuery);
  end;
  ProgressForm.Close;
  ProgressForm.Release;
  if UseFreeAfterRelease then ProgressForm.Free;
  FBusy:=false;
end;

procedure TDBPopupMenu.ImageEditorItemPopUpMenu_(Sender: TObject);
begin
 With EditorsManager.NewEditor do
 begin
  Show;
  OpenFileName(finfo[finfo.Position].FileName);
 end;
end;

class function TDBPopupMenu.Instance: TDBPopupMenu;
begin
  if DBPopupMenu = nil then
  begin
    ReloadIDMenu;
    DBPopupMenu := TDBPopupMenu.Create;
  end;

  Result := DBPopupMenu
end;

function TDBPopupMenu.LoadVariablesNo(int: integer): integer;
begin
  Result:=0;
  if int<0 then exit;
  if int>finfo.Count-1 then exit;
  SetBoolAttr(aScript,'$Crypted',finfo[int].Crypted);
  SetBoolAttr(aScript,'$StaticImage',StaticPath(finfo[int].FileName));
  SetBoolAttr(aScript,'$WallPaper',IsWallpaper(finfo[int].FileName));
  SetBoolAttr(aScript,'$Selected',finfo[int].Selected);
  if finfo[int].Crypted then
  begin
   if DBkernel.FindPasswordForCryptImageFile(finfo[int].FileName[int])<>'' then
   SetNamedValue(aScript,'$CanDecrypt','true') else SetNamedValue(aScript,'$CanDecrypt','false');
  end;
  if finfo.AttrExists then
  begin
    SetNamedValue(aScript,'$IsAttrExists','true');
    SetNamedValue(aScript,'$Attr',IntToStr(finfo[int].Attr));
    SetBoolAttr(aScript,'$Dublicat',finfo[int].Attr=db_attr_dublicate);
  end else
  begin
   SetNamedValue(aScript,'$IsAttrExists','false');
   SetBoolAttr(aScript,'$Dublicat',false);
   SetNamedValue(aScript,'$Attr','0');
  end;

  SetNamedValue(aScript,'$Access',IntToStr(finfo[int].Access));
  SetNamedValue(aScript,'$Rotation',IntToStr(finfo[int].Rotation));
  SetNamedValue(aScript,'$Rating',IntToStr(finfo[int].Rating));
  SetNamedValue(aScript,'$ID',IntToStr(finfo[int].ID));
  SetNamedValue(aScript,'$FileName','"'+ProcessPath(finfo[int].FileName)+'"');
  SetNamedValue(aScript,'$KeyWords','"'+finfo[int].KeyWords+'"');
  SetNamedValue(aScript,'$Links','"'+finfo[int].Links+'"');
end;

procedure TDBPopupMenu.PrintItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  files : TStrings;
begin
 files:=TStringList.Create;
 for i:=0 to finfo.Count-1 do
 if finfo[i].Selected then
 if FileExists(finfo[i].FileName) then
 begin
  Files.Add(finfo[i].FileName[i])
 end;
 if Files.Count<>0 then
 GetPrintForm(Files);
 Files.Free;
end;

procedure TDBPopupMenu.PrivateItemPopUpMenu_(Sender: TObject);
var
  i:integer;
  EventInfo : TEventValues;
  OldAccess : Integer;
  Count : integer;
  ProgressForm : TProgressActionForm;
begin
  FBusy:=true;
  OldAccess:=(Sender as TMenuItem).Tag;
  Count:=0;
  for i:=0 to FInfo.Count-1 do
  if FInfo[i].Selected then
  inc(Count);
  ProgressForm:=GetProgressWindow;
  ProgressForm.MaxPosCurrentOperation:=Count;
  ProgressForm.OneOperation:=true;
  if Count>2 then
  ProgressForm.DoShow;
  ProgressForm.xPosition:=0;
  for i:=0 to FInfo.Count-1 do
  if FInfo[i].Selected then
  begin
{!!!}   Application.ProcessMessages;
   ProgressForm.xPosition:=ProgressForm.xPosition+1;
   if OldAccess=db_access_none then
   begin
    if FInfo[i].Access=db_access_none then
    begin
     SetPrivate(FInfo[i].ID);
     EventInfo.Access:=db_access_private;
     DBKernel.DoIDEvent(Sender,FInfo[i].ID,[EventID_Param_Private],EventInfo);
    end;
   end else begin
    if FInfo[i].Access=DB_Access_Private then
    begin
     UnSetPrivate(FInfo[i].ID);
     EventInfo.Access:=db_access_none;
     DBKernel.DoIDEvent(Sender,FInfo[i].ID,[EventID_Param_Private],EventInfo);
    end;
   end;
  end;
  ProgressForm.Close;
  ProgressForm.Release;
  ProgressForm.Free;
  FBusy:=false;
end;

procedure TDBPopupMenu.PropertyItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  items : TArInteger;
  WindowsProp : boolean;
  SelectCount : integer;
  FFiles : array of string;
begin
 SetLength(items,0);
 SetLength(FFiles,0);
 SelectCount:=0;
 for i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 inc(SelectCount);
 WindowsProp:=(SelectCount>1) and (FInfo[FInfo.Position].ID=0);
 for i:=0 to FInfo.Count-1 do
 if ((FInfo[i].ID<>0) or WindowsProp) and FInfo[i].Selected then
 begin
  SetLength(items,Length(items)+1);
  items[Length(items)-1]:=FInfo[i].ID;
  SetLength(FFiles,Length(FFiles)+1);
  FFiles[Length(FFiles)-1]:=FInfo[i].FileName;
 end;
 If Length(items)<2 then
 begin
  if FInfo[FInfo.Position].ID<>0 then
  PropertyManager.NewIDProperty(FInfo[FInfo.Position].ID).Execute(FInfo[FInfo.Position].ID);
  if FInfo[FInfo.Position].ID=0 then
  if FInfo[FInfo.Position].FileName<>'' then
  PropertyManager.NewFileProperty(FInfo[FInfo.Position].FileName).ExecuteFileNoEx(FInfo[FInfo.Position].FileName);
 end else
 begin
  if FInfo[FInfo.Position].ID=0 then
  GetPropertiesWindows(FFiles,FormManager) else
  PropertyManager.NewSimpleProperty.ExecuteEx(items);
 end;
end;

procedure TDBPopupMenu.QuickGroupInfoPopUpMenu_(Sender: TObject);
var
  s : string;
  i : integer;
begin
 s:=(Sender as TMenuItem).Caption;
 For i:=Length(s) downto 1 do
 if s[i]='&' then delete(s,i,1);
 ShowGroupInfo(s,false,nil);
end;

procedure TDBPopupMenu.RefreshIDItemPopUpMenu_(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
begin
 //TODO: ???
{ Options.Files := Copy(FInfo.ItemFileNames_);
 Options.IDs := Copy(FInfo.ItemIDs_);
 Options.Selected := Copy(FInfo.ItemSelected_);  }
 TRefreshDBRecordsThread.Create(false,Options);
end;

procedure TDBPopupMenu.RefreshThumItemPopUpMenu_(Sender: TObject);
var
  i:integer;
  EventInfo : TEventValues;
begin
 EventInfo.Image:=nil;
 for i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 DBKernel.DoIDEvent(Sender,FInfo[i].ID,[EventID_Param_Image],EventInfo);
end;

procedure TDBPopupMenu.RenameItemPopUpMenu_(Sender: TObject);
begin
 if FInfo.ListItem is TEasyItem then
 begin
  TEasyListview(TEasyItem(FInfo.ListItem).OwnerListview).EditManager.Enabled:=true;
  TEasyItem(FInfo.ListItem).Edit;
 end;
end;

procedure TDBPopupMenu.ScanImageItemPopUpMenu_(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.NewSearch;
 NewSearch.SearchEdit.Text:=':ScanImageW('+Finfo[Finfo.Position].FileName+':1):';
 NewSearch.SetPath(GetDirectory(Finfo[Finfo.Position].FileName));
 NewSearch.DoSearchNow(nil);
 NewSearch.Show;
 NewSearch.SetFocus;
end;

procedure TDBPopupMenu.ScriptExecuted(Sender: TObject);
var
  c : integer;
begin
 LoadItemVariables(aScript,Sender as TMenuItemW);
 if Trim((Sender as TMenuItemW).Script)<>'' then
 ExecuteScript(Sender as TMenuItemW,aScript,'',c,nil);
end;

procedure TDBPopupMenu.SearchFolderPopUpMenu_(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.NewSearch;
 //TODO:!!!
 NewSearch.SearchEdit.Text:=':Folder('+inttostr(Finfo[Finfo.Position].ID)+'):';
 NewSearch.SetPath(GetDirectory(Finfo[Finfo.Position].FileName));
 NewSearch.DoSearchNow(nil);
 NewSearch.Show;
 NewSearch.SetFocus;
end;

procedure TDBPopupMenu.SendToItemPopUpMenu_(Sender: TObject);
var
  NumberOfPanel : Integer;
  InfoNames : TArStrings;
  InfoIDs : TArInteger;
  Infoloaded : TArBoolean;
  i:integer;
  Panel : TFormCont;
begin
 NumberOfPanel:=(Sender As TMenuItem).Tag;
 Setlength(InfoNames,0);
 Setlength(InfoIDs,0);
 For i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 begin
  if FInfo[i].ID=0 then
  begin
  Setlength(InfoNames,Length(InfoNames)+1);
  Setlength(Infoloaded,Length(Infoloaded)+1);
  InfoNames[Length(InfoNames)-1]:=FInfo[i].FileName;
  Infoloaded[Length(Infoloaded)-1]:=FInfo[i].InfoLoaded;
  end else
  begin
   Setlength(InfoIDs,Length(InfoIDs)+1);
   InfoIDs[Length(InfoIDs)-1]:=FInfo[i].ID;
  end;
 end;
 If NumberOfPanel>=0 then
 begin
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,true,ManagerPanels[NumberOfPanel]);
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,false,ManagerPanels[NumberOfPanel]);
 end;
 If NumberOfPanel<0 then
 begin
  Panel:=ManagerPanels.NewPanel;
  Panel.Show;
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,true,Panel);
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,false,Panel);
 end;
end;

procedure TDBPopupMenu.SetInfo(Info: TDBPopupMenuInfo);
begin
 If info.Count=0 then exit;
 finfo:=info;
end;

procedure TDBPopupMenu.SetRatingItemPopUpMenu_(Sender: TObject);
var
  i, NewRating : Integer;
  EventInfo : TEventValues;
  SQL_, Str : string;
  fQuery : TDataSet;
  FirstID : boolean;
begin
  str:=(sender as tmenuitem).Caption;
  system.delete(str,1,1);
  NewRating:=StrToInt(str);
  fQuery:=GetQuery;
  SQL_:='Update $DB$ Set Rating='+inttostr(NewRating)+' Where ID in (';

  FirstID:=True;
  for i:=0 to finfo.Count-1 do
  if finfo[i].Selected then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo[i].ID)+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo[i].ID)+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  fQuery.active:=false;
  SetSQL(fQuery,SQL_);
  try
   ExecSQL(fQuery);
   except
  end;
  for i:=0 to FInfo.Count-1 do
  if FInfo[i].Selected then
  begin
   EventInfo.Rating:=NewRating;
   DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_Rating],EventInfo);
  end;
  FreeDS(fQuery);
end;

procedure TDBPopupMenu.SetRotateItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  EventInfo : TEventValues;
  NewRotate : Integer;
begin
 NewRotate:=(sender as Tmenuitem).tag;
 for i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 begin
  SetRotate(finfo[i].ID,NewRotate);
  EventInfo.Rotate:=NewRotate;
  DBKernel.DoIDEvent(Sender,finfo[i].ID,[EventID_Param_Rotate],EventInfo);
 end;
end;

procedure TDBPopupMenu.ShellExecutePopUpMenu_(Sender: TObject);
var
  i : integer;
  AllOperations : Integer;
  s : String;
begin
 AllOperations:=0;
 for i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 Inc(AllOperations);
 If AllOperations>10 then
 if ID_OK<>MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_SHELL_OPEN_CONFIRM_FORMAT,[inttostr(AllOperations)]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
 for i:=0 to FInfo.Count-1 do
 if FInfo[i].Selected then
 begin
  s:=GetDirectory(Finfo[i].FileName);
  UnFormatDir(s);
  if ShellExecute(0, nil, PWideChar(ProcessPath(Finfo[i].FileName)), nil, PWideChar(s), SW_NORMAL)<32 then
  EventLog(':TDBPopupMenu::ShellExecutePopUpMenu()/ShellExecute return < 32, path = '+Finfo[i].FileName);
 end;
end;

procedure TDBPopupMenu.ShowDublicatesItemPopUpMenu_(Sender: TObject);
begin
 With SearchManager.NewSearch do
 begin
  SearchEdit.text:=':Similar('+IntToStr(FInfo[Finfo.Position].ID)+'):';
  DoSearchNow(nil);
  Show;
  SetFocus;
 end;
end;

procedure TDBPopupMenu.ShowItemPopUpMenu_(Sender: TObject);
var
  Info : TRecordsInfo;
begin
 if Self<>DBPopupMenu then exit;
 DBPopupMenuInfoToRecordsInfo(Finfo, Info);
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 Viewer.Execute(Sender,info);
 Viewer.Show;
end;

procedure TDBPopupMenu.UserMenuItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  Params, ExeFile, ExeParams : String;
begin
 for i:=0 to Finfo.Count-1 do
 if FInfo[i].Selected then
 begin
   Params:=' "'+Finfo[i].FileName+'" ';
 end;
 ExeFile:=FUserMenu[(Sender as TMenuItem).Tag].EXEFile;
 ExeParams:=StringReplace(FUserMenu[(Sender as TMenuItem).Tag].Params,'%1',params,[rfReplaceAll,rfIgnoreCase]);
 if ShellExecute(0,nil,PWideChar(ExeFile),PWideChar(ExeParams),nil,SW_SHOWNORMAL)<32 then
 EventLog(':TDBPopupMenu::UserMenuItemPopUpMenu()/ShellExecute return < 32, path = '+ExeFile+' params = '+ExeParams);
end;

procedure TDBPopupMenu.WallpaperCenterItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo[finfo.Position].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_STRETCH) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TDBPopupMenu.WallpaperStretchItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo[finfo.Position].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_CENTER) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TDBPopupMenu.WallpaperTileItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo[finfo.Position].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_TILE) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

end.

