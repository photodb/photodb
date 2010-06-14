unit DBCMenu;

interface

uses
  StdCtrls, UnitGroupsWork, ComCtrls, dbtables, Dolphin_DB,
  dialogs,ExtCtrls, ShlObj, ComObj, ActiveX, Math, Controls, Filectrl,
  forms, Registry, ShellApi, Windows, SysUtils, Classes, DB,
  Graphics, Menus, UnitDBKernel, UnitCryptImageForm, GraphicCrypt,
  ProgressActionUnit, PrintMainForm, JPEG, ShellContextMenu, uVistaFuncs,
  UnitSQLOptimizing, UnitScripts, DBScriptFunctions, UnitRefreshDBRecordsThread,
  EasyListview, UnitCryptingImagesThread, UnitINI, UnitDBDeclare,
  UnitDBCommonGraphics;

type TDBPopupMenu = class
   private

    _popupmenu:Tpopupmenu;
    _menuitem_shell, _menuitem_show, _menuitem_delete_l, _menuitem_delete, _menuitem_refresh_thum, _menuitem_copy, _menuitem_rename, _menuitem_property, _menuitem_rating, _menuitem_private, _menuitem_nil, _menuitem_rotate, _menuitem_search_folder, _menuitem_send_to, _menuitem_nil1, _menuitem_send_to_new, _menuitem_explorer, _menuitem_groups, _menuitem_date : TMenuItem;
    _ratings : array[0..5] of TMenuItem;
    _rotated : array[0..3] of TMenuItem;
    _groups : array of TMenuItem;

    _user_group_menu : TMenuItem;
    _user_group_menu_sub_items : array of TMenuItem;
    _user_menu : array of TMenuItem;
    
    _edit_image_menu : TMenuItem;

    _SendToMenus : array of TMenuItem;
    _menuitem_crypt, _menuitem_crypt_do_crypt, _menuitem_crypt_do_decrypt, _menuitem_crypt_enter_password : TMenuItem;
    _menuitem_null, _menuitem_steno, _menuitem_desteno : TMenuItem; 
    _menuitem_wallpaper, _menuitem_wallpaper_center, _menuitem_wallpaper_stretch, _menuitem_wallpaper_tile : TMenuItem;
    _menuitem_refresh_id, _menuitem_scan_image : TMenuItem;
    _menuitem_dublicates, _menuitem_show_dublicates, _menuitem_delete_dublicates : TMenuItem;
    _menuitem_print : TMenuItem;
    FInfo : TDBPopupMenuInfo;
    FPopUpPoint : TPoint;
    FUserMenu : TUserMenuItemArray;
    FBusy : Boolean;
    aScript : TScript;
//    FImagesCounter : integer;
    public
    constructor create;
    destructor destroy; override;
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
 Procedure LoadScriptFunctions;
  published
 end;

 procedure ReloadIDMenu;

 var
   DBPopupMenu: TDBPopupMenu;
   MenuScript : string;
   aFS : TFileStream;

implementation

uses ExplorerUnit, PropertyForm, SlideShow, Searching, UnitFormCont,
     UnitLoadFilesToPanel, UnitEditGroupsForm, UnitMenuDateForm, CmpUnit,
     UnitQuickGroupInfo, Language, UnitCrypting, UnitPasswordForm,
     AddSessionPasswordUnit, ImEditor, FormManegerUnit, CommonDBSupport,
     UnitCDMappingSupport;

{ TDBPopupMenu }

procedure ReloadIDMenu;
begin
 MenuScript:=ReadScriptFile('scripts\IDMenu.dbini');
end;

procedure TDBPopupMenu.AddDBContMenu(item: TMenuItem;
  info: TDBPopupMenuInfo);
var
  i, size : integer;
  CurrentRating, CurrentRotate :integer;  access_db_item:integer;
  isrecord, IsFile, IsCurrentFile : boolean;
  PanelsTexts : TStrings;
  MenuGroups : TGroups;
  FGroup : TGroup;
  ArGroups : TArStrings;
  StrGroups, script : String;
  BusyMenu, ErrorMenu : TMenuItem;
  SmallB, B : TBitmap;
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
 If Length(info.ItemIDs_)=0 then
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
 if length(info.ItemIDs_)=1 then
 if info.ItemIDs_[0]=0 then isrecord:=false;
 for i:=0 to item.Count-1 do
 item.Delete(0);

 if length(info.ItemIDs_)>1 then
 begin
  isrecord:=false;
  for i:=0 to Length(info.ItemIDs_)-1 do
  if info.ItemIDs_[i]<>0 then isrecord:=true;
 end;
 NoDBInfoNeeded:=false;

 OnlyCurrentDBinfoSelected:=true;
 if length(info.ItemIDs_)>1 then
 for i:=0 to Length(info.ItemIDs_)-1 do
 if info.ItemIDs_[i]<>0 then
 if info.ItemSelected_[i] then
 if info.Position<>i then
 OnlyCurrentDBinfoSelected:=false;
 if info.ItemSelected_[info.Position] then
 if info.ItemIDs_[info.Position]=0 then
 if not OnlyCurrentDBinfoSelected then
 NoDBInfoNeeded:=true;
 if not isrecord then NoDBInfoNeeded:=true;
 if info.ItemIDs_[info.Position]=0 then NoDBInfoNeeded:=true;

// for i:=0 to length(info.ItemFileNames_)-1 do
// DoProcessPath(info.ItemFileNames_[i]);

 IsFile:=false;
 IsCurrentFile:=FileExists(info.ItemFileNames_[info.Position]);
 for i:=0 to length(info.ItemFileNames_)-1 do
 if FileExists(info.ItemFileNames_[i]) then
 begin
  IsFile:=True;
  Break;
 end;
 SetLength(MenuGroups,0);
 if UseScripts then
 if not (ShiftKeyDown and CtrlKeyDown) then
 begin
  script:=MenuScript;
  //preparing constants for executing script

  SetBoolAttr(aScript,'$CanRename',Info.IsListItem);
  SetBoolAttr(aScript,'$IsRecord',IsRecord);
  SetBoolAttr(aScript,'$IsFile',IsFile);
  SetBoolAttr(aScript,'$NoDBInfoNeeded',NoDBInfoNeeded);

  SetIntAttr(aScript,'$MenuLength',Length(Info.ItemFileNames_));
  SetIntAttr(aScript,'$Position',Info.Position);
  
  //if user haven't rights to get FileName its only possible way to know
  SetBoolAttr(aScript,'$FileExists',FileExists(Info.ItemFileNames_[Info.Position]));

// Access section
  AddAccessVariables(aScript);
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
  SetLength(ArGroups,0);
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  begin
   SetLength(ArGroups,Length(ArGroups)+1);
   ArGroups[Length(ArGroups)-1]:=FInfo.ItemGroups_[i];
  end;
  SetNamedValueArrayStrings(aScript,'$Panels',aPanelTexts);
  StrGroups:=GetCommonGroups(ArGroups);
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
  exit;
 end;

 If IsFile then
 begin
  _menuitem_shell:=Tmenuitem.Create(_popupmenu);
  _menuitem_shell.Caption:=TEXT_MES_SHELL;
  _menuitem_shell.OnClick:=ShellExecutePopUpMenu_;
  _menuitem_shell.ImageIndex:=DB_IC_SHELL;
  _menuitem_show:=Tmenuitem.Create(_popupmenu);
  _menuitem_show.Caption:=TEXT_MES_SHOW;
  _menuitem_show.Default:=true;
  _menuitem_show.OnClick:=ShowItemPopUpMenu_;
  _menuitem_show.ImageIndex:=DB_IC_SLIDE_SHOW;
 end;

 if DBKernel.UserRights.Delete and isrecord and not NoDBInfoNeeded then
 begin
  _menuitem_delete_l:=Tmenuitem.Create(_popupmenu);
  _menuitem_delete_l.Caption:=TEXT_MES_DEL_FROM_DB;
  _menuitem_delete_l.OnClick:=DeleteLItemPopUpMenu_;
  _menuitem_delete_l.ImageIndex:=DB_IC_DELETE_INFO;
  If IsFile and DBKernel.UserRights.FileOperationsCritical then
  begin
   _menuitem_delete:=Tmenuitem.Create(_popupmenu);
   _menuitem_delete.Caption:=TEXT_MES_DEL_FILE;
   _menuitem_delete.OnClick:=DeleteItemPopUpMenu_;
   _menuitem_delete.ImageIndex:=DB_IC_DELETE_File;
  end;
 end;

 if isrecord and not NoDBInfoNeeded then
 begin
  _menuitem_refresh_thum:=Tmenuitem.Create(_popupmenu);
  _menuitem_refresh_thum.Caption:=TEXT_MES_REFRESH_ITEM;
  _menuitem_refresh_thum.OnClick:=RefreshThumItemPopUpMenu_;
  _menuitem_refresh_thum.ImageIndex:=DB_IC_REFRESH_THUM;
 end;

 If IsFile then
 if DBkernel.UserRights.FileOperationsNormal then
 begin
  _menuitem_copy:=Tmenuitem.Create(_popupmenu);
  _menuitem_copy.Caption:=TEXT_MES_COPY_ITEM;
  _menuitem_copy.OnClick:=CopyItemPopUpMenu_;
  _menuitem_copy.ImageIndex:=DB_IC_COPY_ITEM;
 end;

 if Info.IsListItem and DBKernel.UserRights.FileOperationsCritical then
 begin
  _menuitem_rename:=Tmenuitem.Create(_popupmenu);
  _menuitem_rename.Caption:=TEXT_MES_RENAME;
  _menuitem_rename.OnClick:=RenameItemPopUpMenu_;
  _menuitem_rename.ImageIndex:=DB_IC_RENAME;
 end;

 _menuitem_property:=Tmenuitem.Create(_popupmenu);
 _menuitem_property.Caption:=TEXT_MES_PROPERTY;
 _menuitem_property.OnClick:=PropertyItemPopUpMenu_;
 _menuitem_property.ImageIndex:=DB_IC_PROPERTIES;

 _menuitem_nil:=Tmenuitem.Create(_popupmenu);
 _menuitem_nil.Caption:='-';

 if DBKernel.UserRights.SetRating and IsRecord and not NoDBInfoNeeded then
 begin
  _menuitem_rating:=Tmenuitem.Create(_popupmenu);
  _menuitem_rating.Caption:=TEXT_MES_RATING;
  _menuitem_rating.ImageIndex:=DB_IC_RATING_STAR;
  CurrentRating:=info.ItemRatings_[info.Position];
  for i:=0 to 5 do
  begin
   _ratings[i]:=Tmenuitem.Create(_popupmenu);
   _ratings[i].Caption:=inttostr(i);
   if i=CurrentRating then _ratings[i].Default:=true;
   _ratings[i].onclick:=SetRatingItemPopUpMenu_;
  end;
  _ratings[0].ImageIndex:=DB_IC_DELETE_INFO;
  _ratings[1].ImageIndex:=DB_IC_RATING_1;
  _ratings[2].ImageIndex:=DB_IC_RATING_2;
  _ratings[3].ImageIndex:=DB_IC_RATING_3;
  _ratings[4].ImageIndex:=DB_IC_RATING_4;
  _ratings[5].ImageIndex:=DB_IC_RATING_5;
  for i:=0 to 5 do
  _menuitem_rating.Add(_ratings[i]);
 end;

 if DBKernel.UserRights.SetInfo and IsRecord and not NoDBInfoNeeded then
 begin
  _menuitem_rotate:=Tmenuitem.Create(_popupmenu);
  _menuitem_rotate.Caption:=TEXT_MES_ROTATE;
  _menuitem_rotate.ImageIndex:=DB_IC_ROTETED_0;
  CurrentRotate:=info.ItemRotations_[info.Position];
  for i:=0 to 3 do
  begin
   _rotated[i]:=Tmenuitem.Create(_popupmenu);
   _rotated[i].OnClick:=SetRotateItemPopUpMenu_;
   _rotated[i].Tag:=i;
   if i=CurrentRotate then _rotated[i].Default:=true;
  end;
  _rotated[0].Caption:=TEXT_MES_ROTATE_0;
  _rotated[0].ImageIndex:=DB_IC_ROTETED_0;
  _rotated[1].Caption:=TEXT_MES_ROTATE_90;
  _rotated[1].ImageIndex:=DB_IC_ROTETED_90;
  _rotated[2].Caption:=TEXT_MES_ROTATE_180;
  _rotated[2].ImageIndex:=DB_IC_ROTETED_180;
  _rotated[3].Caption:=TEXT_MES_ROTATE_270;
  _rotated[3].ImageIndex:=DB_IC_ROTETED_270;
  for i:=0 to 3 do
  _menuitem_rotate.Add(_rotated[i]);
 end;

 if DBKernel.UserRights.SetPrivate and IsRecord and not NoDBInfoNeeded then
 begin
  access_db_item:=info.ItemAccess_[info.Position];
  _menuitem_private:=Tmenuitem.Create(_popupmenu);
  _menuitem_private.tag:=access_db_item;
  _menuitem_private.Caption:=TEXT_MES_PRIVATE;
  if access_db_item=db_access_private then
  begin
   _menuitem_private.Caption:=TEXT_MES_COMMON;
   _menuitem_private.ImageIndex:=DB_IC_COMMON;
  end else
  begin
   _menuitem_private.Caption:=TEXT_MES_PRIVATE;
   _menuitem_private.ImageIndex:=DB_IC_PRIVATE;
  end;
  _menuitem_private.OnClick:=PrivateItemPopUpMenu_;
 end;
 
 for i:=1 to FExtImagesInImageList do
 DBKernel.ImageList.Delete(IconsCount);
 FExtImagesInImageList:=0;

// if info.IsDateGroup then   ????
 if IsRecord and not NoDBInfoNeeded then
 begin
  _menuitem_groups:=TMenuItem.Create(_popupmenu);
  _menuitem_groups.Caption:=TEXT_MES_GROUPS;
  if not ShowGroupsInContextMenu then
  _menuitem_groups.OnClick:=GroupsPopUpMenu_;
  _menuitem_groups.ImageIndex:=DB_IC_GROUPS;

  if ShowGroupsInContextMenu then
  begin
   SetLength(ArGroups,0);
   for i:=0 to Length(FInfo.ItemFileNames_)-1 do
   if FInfo.ItemSelected_[i] then
   begin
    SetLength(ArGroups,Length(ArGroups)+1);
    ArGroups[Length(ArGroups)-1]:=FInfo.ItemGroups_[i];
   end;
   StrGroups:=GetCommonGroups(ArGroups);
   MenuGroups:=EnCodeGroups(StrGroups);
   SetLength(_groups,Length(MenuGroups));

   for i:=0 to length(_groups)-1 do
   begin
    FGroup:=GetGroupByGroupName(MenuGroups[i].GroupName,true);
    _groups[i]:=TMenuItem.Create(_menuitem_groups);
    _groups[i].Caption:=MenuGroups[i].GroupName;
    _groups[i].OnClick:=QuickGroupInfoPopUpMenu_;

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
      _groups[i].ImageIndex:=DBKernel.ImageList.Count-1;
     end else _groups[i].ImageIndex:=DB_IC_GROUPS;
    end else _groups[i].ImageIndex:=DB_IC_GROUPS;
    FreeGroup(FGroup);

   end;
   if DBkernel.UserRights.SetInfo then
   begin
    SetLength(_groups,Length(_groups)+1);
    _groups[Length(_groups)-1]:=TMenuItem.Create(_menuitem_groups);
    _groups[Length(_groups)-1].Caption:=TEXT_MES_EDITA;
    _groups[Length(_groups)-1].OnClick:=GroupsPopUpMenu_;
    _groups[Length(_groups)-1].ImageIndex:=DB_IC_GROUPS;
   end;
   _menuitem_groups.Add(_groups);
  end;
  _menuitem_date:=TMenuItem.Create(_popupmenu);
  _menuitem_date.Caption:=TEXT_MES_DATE;
  _menuitem_date.OnClick:=DateItemPopUpMenu_;
  _menuitem_date.ImageIndex:=DB_IC_EDIT_DATE;
 end;

 If DirectoryExists(GetDirectory(Info.ItemFileNames_[Info.Position])) then
 begin
  _menuitem_explorer:=Tmenuitem.Create(_popupmenu);
  _menuitem_explorer.Caption:=TEXT_MES_EXPLORER;
  _menuitem_explorer.OnClick:=ExplorerPopUpMenu_;
  _menuitem_explorer.ImageIndex:=DB_IC_EXPLORER;
 end;

 if isrecord and not NoDBInfoNeeded then
 begin
  _menuitem_search_folder:=TMenuItem.Create(_popupmenu);
  _menuitem_search_folder.Caption:=TEXT_MES_SHOW_FOLDER;
  _menuitem_search_folder.OnClick:=SearchFolderPopUpMenu_;
  _menuitem_search_folder.ImageIndex:=DB_IC_SEARCH;
 end;

 if isfile then
 begin
  _menuitem_send_to:=TMenuItem.Create(_popupmenu);
  _menuitem_send_to.Caption:=TEXT_MES_SEND_TO;
  _menuitem_send_to.ImageIndex:=DB_IC_SEND;
  PanelsTexts := TStringList.Create;
  PanelsTexts.Assign(UnitFormCont.ManagerPanels.GetPanelsTexts);
  SetLength(_SendToMenus,PanelsTexts.Count);
  for i:=0 to Length(_SendToMenus)-1 do
  begin
   _SendToMenus[i]:=TMenuItem.Create(_menuitem_send_to);
   _SendToMenus[i].Caption:=PanelsTexts[i];
   _SendToMenus[i].OnClick:=SendToItemPopUpMenu_;
   _SendToMenus[i].ImageIndex:=DB_IC_SENDTO;
   _SendToMenus[i].Tag:=i;
  end;
  _menuitem_nil1:=Tmenuitem.Create(_popupmenu);
  _menuitem_nil1.Caption:='-';
  _menuitem_send_to_new:=Tmenuitem.Create(_menuitem_send_to);
  _menuitem_send_to_new.Caption:=TEXT_MES_NEW_PANEL;
  _menuitem_send_to_new.OnClick:=SendToItemPopUpMenu_;
  _menuitem_send_to_new.ImageIndex:=DB_IC_SENDTO;
  _menuitem_send_to_new.Tag:=-1;
  _menuitem_send_to.Add(_SendToMenus);
  _menuitem_send_to.Add(_menuitem_nil1);
  _menuitem_send_to.Add(_menuitem_send_to_new);
 end;

 if IsFile then
 begin
  Item.Add(_menuitem_show);
  Item.Add(_menuitem_shell);
 end;

 if isrecord and not NoDBInfoNeeded then
 Item.Add(_menuitem_refresh_thum);
 if DBKernel.UserRights.SetInfo and isrecord and not NoDBInfoNeeded then
 Item.Add(_menuitem_rotate);
 if DBKernel.UserRights.SetRating and isrecord and not NoDBInfoNeeded then
 Item.Add(_menuitem_rating);
 if DBKernel.UserRights.SetPrivate and isrecord and not NoDBInfoNeeded then
 Item.Add(_menuitem_private);
 if info.IsDateGroup then
 if IsRecord and not NoDBInfoNeeded then
 begin
  Item.Add(_menuitem_date);
  if length(_groups)>0 then
  Item.Add(_menuitem_groups);
 end;

 if dbkernel.UserRights.Crypt then
 begin
  _menuitem_crypt:=TmenuItem.Create(_popupmenu);
  _menuitem_crypt.ImageIndex:=DB_IC_KEY;
  _menuitem_crypt.Caption:=TEXT_MES_CRYPTING;
  Item.Add(_menuitem_crypt);
  if Info.ItemCrypted_[Info.Position] then
  begin
   if DBkernel.FindPasswordForCryptImageFile(FInfo.ItemFileNames_[Info.Position])='' then
   begin
    _menuitem_crypt_enter_password:=TMenuItem.Create(_menuitem_crypt);
    _menuitem_crypt_enter_password.ImageIndex:=DB_IC_PASSWORD;
    _menuitem_crypt_enter_password.Caption:=TEXT_MES_ENTER_PASSWORD;
    _menuitem_crypt_enter_password.OnClick:=EnterPasswordItemPopUpMenu_;
    _menuitem_crypt.Add(_menuitem_crypt_enter_password);
   end;
   _menuitem_crypt_do_decrypt:=TmenuItem.Create(_menuitem_crypt);
   _menuitem_crypt_do_decrypt.Caption:=TEXT_MES_DECRYPT;
   _menuitem_crypt_do_decrypt.ImageIndex:=DB_IC_DECRYPTIMAGE;
   _menuitem_crypt_do_decrypt.OnClick:=DeCryptItemPopUpMenu_;
   _menuitem_crypt.Add(_menuitem_crypt_do_decrypt);
  end else
  begin
   _menuitem_crypt_do_crypt:=TmenuItem.Create(_menuitem_crypt);
   _menuitem_crypt_do_crypt.Caption:=TEXT_MES_CRYPT;
   _menuitem_crypt_do_crypt.ImageIndex:=DB_IC_CRYPTIMAGE;
   _menuitem_crypt_do_crypt.OnClick:=CryptItemPopUpMenu_;
   _menuitem_crypt.Add(_menuitem_crypt_do_crypt);
  end;

   _menuitem_null:=TmenuItem.Create(_menuitem_crypt);
   _menuitem_null.Caption:='-';
   _menuitem_null.ImageIndex:=0;
   _menuitem_null.OnClick:=nil;
   _menuitem_crypt.Add(_menuitem_null);

   _menuitem_steno:=TmenuItem.Create(_menuitem_crypt);
   _menuitem_steno.Caption:='-';
   _menuitem_steno.ImageIndex:=0;
   _menuitem_steno.OnClick:=nil;
   _menuitem_crypt.Add(_menuitem_steno);

   _menuitem_desteno:=TmenuItem.Create(_menuitem_crypt);
   _menuitem_desteno.Caption:='-';
   _menuitem_desteno.ImageIndex:=0;
   _menuitem_desteno.OnClick:=nil;
   _menuitem_crypt.Add(_menuitem_desteno);
 end;

 If IsCurrentFile then
 if DBKernel.UserRights.FileOperationsCritical then
 if not Info.ItemCrypted_[Info.Position] then
 if IsWallpaper(Info.ItemFileNames_[Info.Position]) then
 begin
  _menuitem_wallpaper:=TmenuItem.Create(_popupmenu);
  _menuitem_wallpaper.Caption:=TEXT_MES_SET_AS_DESKTOP_WALLPAPER;
  _menuitem_wallpaper.ImageIndex:=DB_IC_WALLPAPER;
  Item.Add(_menuitem_wallpaper);
  _menuitem_wallpaper_stretch:=TmenuItem.Create(_popupmenu);
  _menuitem_wallpaper_stretch.Caption:=TEXT_MES_BY_STRETCH;
  _menuitem_wallpaper_stretch.ImageIndex:=DB_IC_WALLPAPER;
  _menuitem_wallpaper_stretch.OnClick:=WallpaperStretchItemPopUpMenu_;
  _menuitem_wallpaper.Add(_menuitem_wallpaper_stretch);
  _menuitem_wallpaper_center:=TmenuItem.Create(_popupmenu);
  _menuitem_wallpaper_center.Caption:=TEXT_MES_BY_CENTER;
  _menuitem_wallpaper_center.ImageIndex:=DB_IC_WALLPAPER;
  _menuitem_wallpaper_center.OnClick:=WallpaperCenterItemPopUpMenu_;
  _menuitem_wallpaper.Add(_menuitem_wallpaper_center);
  _menuitem_wallpaper_tile:=TmenuItem.Create(_popupmenu);
  _menuitem_wallpaper_tile.Caption:=TEXT_MES_BY_TILE;
  _menuitem_wallpaper_tile.ImageIndex:=DB_IC_WALLPAPER;
  _menuitem_wallpaper_tile.OnClick:=WallpaperTileItemPopUpMenu_;
  _menuitem_wallpaper.Add(_menuitem_wallpaper_tile);
 end;

 If IsCurrentFile then
 If DBKernel.UserRights.EditImage then
 begin
  _edit_image_menu:=TmenuItem.Create(_popupmenu);
  _edit_image_menu.Caption:=TEXT_MES_IMAGE_EDITOR;
  _edit_image_menu.ImageIndex:=DB_IC_IMEDITOR;
  _edit_image_menu.OnClick:=ImageEditorItemPopUpMenu_;
   Item.Add(_edit_image_menu);
 end;

 If IsCurrentFile then
 if DBKernel.ReadBool('Options','UseUserMenuForIDmenu',true) then
 if DBKernel.UserRights.FileOperationsCritical then
 AddUserMenu(Item,false,0);

 If IsCurrentFile and (Info.ItemIDs_[Info.Position]<>0) and not NoDBInfoNeeded then
 begin
  _menuitem_refresh_id:=TmenuItem.Create(_popupmenu);
  _menuitem_refresh_id.Caption:=TEXT_MES_REFRESH_ID;
  _menuitem_refresh_id.ImageIndex:=DB_IC_REFRESH_ID;
  _menuitem_refresh_id.OnClick:=RefreshIDItemPopUpMenu_;
  Item.Add(_menuitem_refresh_id);
 end;

 If IsCurrentFile and ShiftKeyDown then
 begin
  _menuitem_scan_image:=TmenuItem.Create(_popupmenu);
  _menuitem_scan_image.Caption:=TEXT_MES_SCAN_IMAGE;
  _menuitem_scan_image.ImageIndex:=DB_IC_SEARCH;
  _menuitem_scan_image.OnClick:=ScanImageItemPopUpMenu_;
  Item.Add(_menuitem_scan_image);
 end;

 if IsCurrentFile and DBKernel.UserRights.Print then
 begin
  _menuitem_print:=TmenuItem.Create(_popupmenu);
  _menuitem_print.Caption:=TEXT_MES_PRINT;
  _menuitem_print.ImageIndex:=DB_IC_PRINTER;
  _menuitem_print.OnClick:=PrintItemPopUpMenu_;
  Item.Add(_menuitem_print);
 end;

 If Info.IsAttrExists then
 if (Info.ItemAttr_[Info.Position]=db_attr_dublicate) then
 begin
  _menuitem_dublicates:=TmenuItem.Create(_popupmenu);
  _menuitem_dublicates.Caption:=TEXT_MES_DUBLICATES;
  _menuitem_dublicates.ImageIndex:=DB_IC_DUBLICAT;
  Item.Add(_menuitem_dublicates);
  _menuitem_show_dublicates:=TmenuItem.Create(_popupmenu);
  _menuitem_show_dublicates.Caption:=TEXT_MES_SHOW_DUBLICATES;
  _menuitem_show_dublicates.ImageIndex:=DB_IC_DUBLICAT;
  _menuitem_show_dublicates.OnClick:=ShowDublicatesItemPopUpMenu_;
  _menuitem_dublicates.Add(_menuitem_show_dublicates);
  _menuitem_delete_dublicates:=TmenuItem.Create(_popupmenu);
  _menuitem_delete_dublicates.Caption:=TEXT_MES_DEL_DUBLICATES;
  _menuitem_delete_dublicates.ImageIndex:=DB_IC_DEL_DUBLICAT;
  _menuitem_delete_dublicates.OnClick:=DeleteDublicatesItemPopUpMenu_;
  _menuitem_dublicates.Add(_menuitem_delete_dublicates);
 end;

 if DBKernel.UserRights.Delete and isrecord and not NoDBInfoNeeded then
 begin
  Item.Add(_menuitem_delete_l);
  if IsFile then
  if dbkernel.UserRights.FileOperationsCritical then
  Item.Add(_menuitem_delete);
 end;

 if IsFile then
 if DBKernel.UserRights.FileOperationsNormal then
 Item.Add(_menuitem_copy);

 if Info.IsListItem and DBKernel.UserRights.FileOperationsCritical then
 Item.Add(_menuitem_rename);
 if isrecord then Item.Add(_menuitem_nil);
 If DirectoryExists(GetDirectory(Info.ItemFileNames_[Info.Position])) then
 Item.add(_menuitem_explorer);
 if isfile then
 Item.Add(_menuitem_send_to);
 if isrecord and not NoDBInfoNeeded then
 Item.Add(_menuitem_search_folder);
 Item.Add(_menuitem_property);
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
  c, i : integer;
  files : string;
begin
 files:='';
 c:=0;
 for i:=0 to length(finfo.ItemIDs_)-1 do
 if finfo.ItemSelected_[i] then
 if FileExists(finfo.ItemFileNames_[i]) then
 begin
  if c<>0 then files:=files+#0;
  files:=files+finfo.ItemFileNames_[i];
  inc(c);
 end;
 CopyFilesToClipboard(files);
end;

constructor TDBPopupMenu.create;
begin
  inherited;
  // ReloadIDMenu;

  FBusy:=false;
  aScript.Description:='ID Menu';
  InitializeScript(aScript);
  LoadBaseFunctions(aScript);
  LoadDBFunctions(aScript);
  if DBKernel.UserRights.FileOperationsCritical then
  LoadFileFunctions(aScript);
  AddScriptObjFunction(aScript,'ShowItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowItemPopUpMenu_);
  AddScriptObjFunction(aScript,'ShellExecutePopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShellExecutePopUpMenu_);
  AddScriptObjFunction(aScript,'SearchFolderPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SearchFolderPopUpMenu_);
  AddScriptObjFunction(aScript,'ShowItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowItemPopUpMenu_);
  AddScriptObjFunction(aScript,'DeleteLItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteLItemPopUpMenu_);
  AddScriptObjFunction(aScript,'DeleteItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteItemPopUpMenu_);
  AddScriptObjFunction(aScript,'RefreshThumItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RefreshThumItemPopUpMenu_);
  AddScriptObjFunction(aScript,'PropertyItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PropertyItemPopUpMenu_);
  AddScriptObjFunction(aScript,'ScanImageItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ScanImageItemPopUpMenu_);
  AddScriptObjFunction(aScript,'SetRatingItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SetRatingItemPopUpMenu_);
  AddScriptObjFunction(aScript,'SetRotateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SetRotateItemPopUpMenu_);
  AddScriptObjFunction(aScript,'PrivateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PrivateItemPopUpMenu_);
  AddScriptObjFunction(aScript,'RenameItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RenameItemPopUpMenu_);
  AddScriptObjFunction(aScript,'CopyItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,CopyItemPopUpMenu_);
  AddScriptObjFunction(aScript,'SendToItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,SendToItemPopUpMenu_);
  AddScriptObjFunction(aScript,'ExplorerPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ExplorerPopUpMenu_);
  AddScriptObjFunction(aScript,'GroupsPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,GroupsPopUpMenu_);
  AddScriptObjFunction(aScript,'DateItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DateItemPopUpMenu_);
  AddScriptObjFunction(aScript,'CryptItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,CryptItemPopUpMenu_);
  AddScriptObjFunction(aScript,'DeCryptItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeCryptItemPopUpMenu_);
  AddScriptObjFunction(aScript,'QuickGroupInfoPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,QuickGroupInfoPopUpMenu_);
  AddScriptObjFunction(aScript,'EnterPasswordItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,EnterPasswordItemPopUpMenu_);
  AddScriptObjFunction(aScript,'ImageEditorItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ImageEditorItemPopUpMenu_);
  AddScriptObjFunction(aScript,'WallpaperStretchItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperStretchItemPopUpMenu_);
  AddScriptObjFunction(aScript,'WallpaperCenterItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperCenterItemPopUpMenu_);
  AddScriptObjFunction(aScript,'WallpaperTileItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,WallpaperTileItemPopUpMenu_);
  AddScriptObjFunction(aScript,'RefreshIDItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,RefreshIDItemPopUpMenu_);
  AddScriptObjFunction(aScript,'ShowDublicatesItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,ShowDublicatesItemPopUpMenu_);
  AddScriptObjFunction(aScript,'DeleteDublicatesItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,DeleteDublicatesItemPopUpMenu_);
  AddScriptObjFunction(aScript,'UserMenuItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,UserMenuItemPopUpMenu_);
  AddScriptObjFunction(aScript,'PrintItemPopUpMenu',F_TYPE_OBJ_PROCEDURE_TOBJECT,PrintItemPopUpMenu_);
  AddScriptObjFunctionStringIsInteger(aScript,'GetGroupImage',Self.GetGroupImageInImageList);

  AddScriptObjFunctionIntegerIsInteger(aScript,'LoadVariablesNo',Self.LoadVariablesNo);

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
 Options.Files := Copy(FInfo.ItemFileNames_);
 Options.IDs := Copy(FInfo.ItemIDs_);
 Options.Selected := Copy(FInfo.ItemSelected_);
 Options.Password := Opt.Password;
 Options.CryptOptions := CryptOptions;
 Options.Action := ACTION_CRYPT_IMAGES;
 TCryptingImagesThread.Create(false,Options);
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
 for i:=0 to Length(FInfo.ItemFileNames_)-1 do
 if finfo.ItemSelected_[i] then
 begin
  SetLength(ArDates,Length(ArDates)+1);
  ArDates[Length(ArDates)-1]:=FInfo.ItemDates_[i];
  SetLength(ArTimes,Length(ArTimes)+1);
  ArTimes[Length(ArTimes)-1]:=FInfo.ItemTimes_[i];
  SetLength(ArIsDates,Length(ArIsDates)+1);
  ArIsDates[Length(ArIsDates)-1]:=FInfo.ItemIsDates_[i];
  SetLength(ArIsTimes,Length(ArIsTimes)+1);
  ArIsTimes[Length(ArIsTimes)-1]:=FInfo.ItemIsTimes_[i];
 end;
 IsDate:=MaxStatBool(ArIsDates);
 IsTime:=MaxStatBool(ArIsTimes);
 Date:=MaxStatDate(ArDates);
 Time:=MaxStatTime(ArTimes);
 ChangeDate(Date,IsDate,Changed,Time,IsTime);
 If Changed then
 begin
  FQuery := GetQuery;
  If DBkernel.UserRights.SetInfo then
  begin
   //[BEGIN] Date Support
   If IsDate then
   begin
    _sqlexectext:='Update '+GetDefDBName+' Set DateToAdd = :Date, IsDate = TRUE Where ID in (';
    FirstID:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo.ItemIDs_[i])+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo.ItemIDs_[i])+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    SetDateParam(FQuery,0,Date);
    ExecSQL(fQuery);
    EventInfo.Date:=Date;
    EventInfo.IsDate:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if FInfo.ItemSelected_[i] then
    DBKernel.DoIDEvent(Sender,finfo.ItemIDs_[i],[EventID_Param_Date,EventID_Param_IsDate],EventInfo);
   end else
   begin
    _sqlexectext:='Update '+GetDefDBName+' Set IsDate = FALSE Where ID in (';
    FirstID:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo.ItemIDs_[i])+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo.ItemIDs_[i])+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    ExecSQL(fQuery);
    EventInfo.IsDate:=FALSE;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    DBKernel.DoIDEvent(Sender,finfo.ItemIDs_[i],[EventID_Param_IsDate],EventInfo);
   end;
   //[END] Date Support
   //[BEGIN] Time Support
   If IsTime then
   begin
    _sqlexectext:='Update '+GetDefDBName+' Set aTime = :aTime, IsTime = TRUE Where ID in (';
    FirstID:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo.ItemIDs_[i])+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo.ItemIDs_[i])+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    SetDateParam(FQuery,0,Time);
    ExecSQL(fQuery);
    EventInfo.Time:=Time;
    EventInfo.IsTime:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if FInfo.ItemSelected_[i] then
    DBKernel.DoIDEvent(Sender,finfo.ItemIDs_[i],[EventID_Param_Time,EventID_Param_IsTime],EventInfo);
   end else
   begin
    _sqlexectext:='Update '+GetDefDBName+' Set IsTime = FALSE Where ID in (';
    FirstID:=True;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    begin
      if FirstID then _sqlexectext:=_sqlexectext+' '+inttostr(finfo.ItemIDs_[i])+' ' else
     _sqlexectext:=_sqlexectext+' , '+inttostr(finfo.ItemIDs_[i])+' ';
     FirstID:=False;
    end;
    _sqlexectext:=_sqlexectext+')';
    FQuery.active:=false;
    SetSQL(FQuery,_sqlexectext);
    ExecSQL(fQuery);
    EventInfo.IsTime:=FALSE;
    for i:=0 to Length(FInfo.ItemFileNames_)-1 do
    if finfo.ItemSelected_[i] then
    DBKernel.DoIDEvent(Sender,finfo.ItemIDs_[i],[EventID_Param_IsTime],EventInfo);
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

 Password:=DBKernel.FindPasswordForCryptImageFile(FInfo.ItemFileNames_[FInfo.Position]);
 if Password='' then
 if FileExists(FInfo.ItemFileNames_[FInfo.Position]) then
 Password:=GetImagePasswordFromUser(FInfo.ItemFileNames_[FInfo.Position]);

 Setlength(ItemFileNames,Length(FInfo.ItemFileNames_));
 Setlength(ItemIDs,Length(FInfo.ItemIDs_));
 Setlength(ItemSelected,Length(FInfo.ItemSelected_));

 //be default unchecked
 for i:=0 to Length(FInfo.ItemIDs_)-1 do
 ItemSelected[i]:=false;

 for i:=0 to Length(FInfo.ItemIDs_)-1 do
 begin
  ItemFileNames[i]:=FInfo.ItemFileNames_[i];
  ItemIDs[i]:=FInfo.ItemIDs_[i];
  ItemSelected[i]:=FInfo.ItemSelected_[i];
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
  for i:=0 to length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  if finfo.ItemAttr_[i]=db_attr_dublicate then
  begin
   fQuery:=GetQuery;
   SQL_:='SELECT FFileName, ID FROM '+GetDefDBName+''+' WHERE (ID<>'+IntToStr(finfo.ItemIDs_[i])+') AND (StrTh=(SELECT StrTh FROM '+GetDefDBName+' WHERE ID = '+IntToStr(finfo.ItemIDs_[i])+'))';
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
   SQL_:='DELETE FROM '+GetDefDBName+''+' WHERE (ID<>'+IntToStr(finfo.ItemIDs_[i])+') AND (StrTh=(SELECT StrTh FROM '+GetDefDBName+' WHERE ID = '+IntToStr(finfo.ItemIDs_[i])+'))';
   SetSQL(fQuery,SQL_);
   ExecSQL(fQuery);
   SQL_:='UPDATE '+GetDefDBName+''+' SET Attr = '+IntToStr(db_attr_norm)+' WHERE (ID='+IntToStr(finfo.ItemIDs_[i])+')';
   SetSQL(fQuery,SQL_);
   ExecSQL(fQuery);
   EventInfo.Attr:=db_attr_norm;
   DBKernel.DoIDEvent(nil,finfo.ItemIDs_[i],[EventID_Param_Attr],EventInfo);
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
  SQL_:='UPDATE '+GetDefDBName+''+' SET Attr='+inttostr(db_attr_not_exists)+' WHERE ID in (';
  FirstID:=True;
  for i:=0 to Length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo.ItemIDs_[i])+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo.ItemIDs_[i])+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  SetSQL(fQuery,SQL_);
  ExecSQL(fQuery);
  SetLength(s,1);
  for i:=0 to length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  begin
   begin
    If fileexists(finfo.ItemFileNames_[i]) then
    begin
     try
      s[0]:=finfo.ItemFileNames_[i];
      SilentDeleteFiles( Application.Handle, s , true );
     except
     end;
    end;
   end;
   DBKernel.DoIDEvent(nil,finfo.ItemIDs_[i],[EventID_Param_Delete],EventInfo);
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
  SQL_:='DELETE FROM '+GetDefDBName+''+' WHERE ID in (';
  FirstID:=True;
  for i:=0 to Length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo.ItemIDs_[i])+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo.ItemIDs_[i])+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  SetSQL(fQuery,SQL_);
  ExecSQL(fQuery);
  for i:=0 to length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  DBKernel.DoIDEvent(nil,finfo.ItemIDs_[i],[EventID_Param_Delete],EventInfo);
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
 if fileexists(FInfo.ItemFileNames_[fInfo.Position]) then
 begin
  if GetImagePasswordFromUser(FInfo.ItemFileNames_[fInfo.Position])<>'' then
  DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[fInfo.Position],[EventID_Param_Image],EventInfo);
 end else
 begin
  Query := GetQuery;
  ID:=GetIdByFileName(FInfo.ItemFileNames_[fInfo.Position]);
  if ID=0 then exit;
  SetSQL(Query,'SELECT * from '+GetDefDBName+' where ID='+IntToStr(ID));
  Query.Open;
  if GetImagePasswordFromUserBlob(Query.FieldByName('thum'),FInfo.ItemFileNames_[fInfo.Position])<>'' then
  DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[fInfo.Position],[EventID_Param_Image],EventInfo);
  Query.free;
 end;
end;

procedure TDBPopupMenu.Execute(x, y: integer; info: TDBPopupMenuInfo);
begin
 FPopUpPoint:=Point(X,Y);
 if not FBusy then
 begin
  FInfo:=info;
  if length(Finfo.ItemFileNames_)=0 then exit;
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
 if length(Finfo.ItemFileNames_)=0 then exit;
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
 With ExplorerManager.NewExplorer do
 begin
  SetOldPath(FInfo.ItemFileNames_[FInfo.Position]);
  SetPath(GetDirectory(FInfo.ItemFileNames_[FInfo.Position]));
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
  ArGroups, ArKeyWords : TArStrings;
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
  SetLength(ArGroups,0);
  SetLength(ArKeyWords,0);
  Count:=0;
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  inc(Count);
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  begin
   SetLength(ArGroups,Length(ArGroups)+1);
   ArGroups[Length(ArGroups)-1]:=FInfo.ItemGroups_[i];
   SetLength(ArKeyWords,Length(ArKeyWords)+1);
   ArKeyWords[Length(ArKeyWords)-1]:=FInfo.ItemKeyWords_[i];
  end;
  StrOldGroups:=GetCommonGroups(ArGroups);
  StrNewGroups:=GetCommonGroups(ArGroups);
  OldKeyWords:=GetCommonWordsA(ArKeyWords);
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
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  begin
   KeyWords:=FInfo.ItemKeyWords_[i];
   ReplaceWords(OldKeyWords,NewKeyWords,KeyWords);
   if VariousKeyWords(KeyWords,FInfo.ItemKeyWords_[i]) then
   begin
    AddQuery(List,KeyWords,FInfo.ItemIDs_[i]);
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
   _sqlexectext:='Update '+GetDefDBName+' Set KeyWords = "'+NormalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
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
   for i:=0 to Length(FInfo.ItemFileNames_)-1 do
   if FInfo.ItemSelected_[i] then
   begin
    Groups:=FInfo.ItemGroups_[i];
    ReplaceGroups(StrOldGroups,StrNewGroups,Groups);
    if not CompareGroups(Groups,FInfo.ItemGroups_[i]) then
    begin
     AddQuery(List,Groups,FInfo.ItemIDs_[i]);
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
    _sqlexectext:='Update '+GetDefDBName+' Set Groups = "'+normalizeDBString(List[i].Value)+'" Where ID in ('+IDs+')';
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
  OpenFileName(finfo.ItemFileNames_[finfo.Position]);
 end;
end;

procedure TDBPopupMenu.LoadScriptFunctions;
begin
  LoadDBFunctions(aScript);
  if DBKernel.UserRights.FileOperationsCritical then
  LoadFileFunctions(aScript);
end;

function TDBPopupMenu.LoadVariablesNo(int: integer): integer;
begin
  Result:=0;
  if int<0 then exit;
  if int>Length(finfo.ItemFileNames_)-1 then exit;
  SetBoolAttr(aScript,'$Crypted',finfo.ItemCrypted_[int]);
  SetBoolAttr(aScript,'$StaticImage',StaticPath(finfo.ItemFileNames_[int]));
  SetBoolAttr(aScript,'$WallPaper',IsWallpaper(finfo.ItemFileNames_[int]));
  SetBoolAttr(aScript,'$Selected',finfo.ItemSelected_[int]);
  if finfo.ItemCrypted_[int] then
  begin
   if DBkernel.FindPasswordForCryptImageFile(finfo.ItemFileNames_[int])<>'' then
   SetNamedValue(aScript,'$CanDecrypt','true') else SetNamedValue(aScript,'$CanDecrypt','false');
  end;
  if finfo.IsAttrExists then
  begin
    SetNamedValue(aScript,'$IsAttrExists','true');
    SetNamedValue(aScript,'$Attr',IntToStr(finfo.ItemAttr_[int]));
    SetBoolAttr(aScript,'$Dublicat',finfo.ItemAttr_[int]=db_attr_dublicate);
  end else
  begin
   SetNamedValue(aScript,'$IsAttrExists','false');
   SetBoolAttr(aScript,'$Dublicat',false);
   SetNamedValue(aScript,'$Attr','0');
  end;

  SetNamedValue(aScript,'$Access',IntToStr(finfo.ItemAccess_[int]));
  SetNamedValue(aScript,'$Rotation',IntToStr(finfo.ItemRotations_[int]));
  SetNamedValue(aScript,'$Rating',IntToStr(finfo.ItemRatings_[int]));
  SetNamedValue(aScript,'$ID',IntToStr(finfo.ItemIDs_[int]));
  if DBKernel.UserRights.ShowPath then
  SetNamedValue(aScript,'$FileName','"'+ProcessPath(finfo.ItemFileNames_[int])+'"');
  SetNamedValue(aScript,'$KeyWords','"'+finfo.ItemKeyWords_[int]+'"');
  SetNamedValue(aScript,'$Links','"'+finfo.ItemLinks_[int]+'"');
end;

procedure TDBPopupMenu.PrintItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  files : TStrings;
begin
 files:=TStringList.Create;
 for i:=0 to length(finfo.ItemIDs_)-1 do
 if finfo.ItemSelected_[i] then
 if FileExists(finfo.ItemFileNames_[i]) then
 begin
  Files.Add(finfo.ItemFileNames_[i])
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
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  inc(Count);
  ProgressForm:=GetProgressWindow;
  ProgressForm.MaxPosCurrentOperation:=Count;
  ProgressForm.OneOperation:=true;
  if Count>2 then
  ProgressForm.DoShow;
  ProgressForm.xPosition:=0;
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  begin
{!!!}   Application.ProcessMessages;
   ProgressForm.xPosition:=ProgressForm.xPosition+1;
   if OldAccess=db_access_none then
   begin
    if FInfo.ItemAccess_[i]=db_access_none then
    begin
     SetPrivate(FInfo.ItemIDs_[i]);
     EventInfo.Access:=db_access_private;
     DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[i],[EventID_Param_Private],EventInfo);
    end;
   end else begin
    if FInfo.ItemAccess_[i]=DB_Access_Private then
    begin
     UnSetPrivate(FInfo.ItemIDs_[i]);
     EventInfo.Access:=db_access_none;
     DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[i],[EventID_Param_Private],EventInfo);
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
 for i:=0 to length(FInfo.ItemIDs_)-1 do
 if FInfo.ItemSelected_[i] then
 inc(SelectCount);
 WindowsProp:=(SelectCount>1) and (FInfo.ItemIDs_[FInfo.Position]=0);
 for i:=0 to length(FInfo.ItemIDs_)-1 do
 if ((FInfo.ItemIDs_[i]<>0) or WindowsProp) and FInfo.ItemSelected_[i] then
 begin
  SetLength(items,Length(items)+1);
  items[Length(items)-1]:=FInfo.ItemIDs_[i];
  SetLength(FFiles,Length(FFiles)+1);
  FFiles[Length(FFiles)-1]:=FInfo.ItemFileNames_[i];
 end;
 If Length(items)<2 then
 begin
  if FInfo.ItemIDs_[FInfo.Position]<>0 then
  PropertyManager.NewIDProperty(FInfo.ItemIDs_[FInfo.Position]).Execute(FInfo.ItemIDs_[FInfo.Position]);
  if FInfo.ItemIDs_[FInfo.Position]=0 then
  if FInfo.ItemFileNames_[FInfo.Position]<>'' then
  PropertyManager.NewFileProperty(FInfo.ItemFileNames_[FInfo.Position]).ExecuteFileNoEx(FInfo.ItemFileNames_[FInfo.Position]);
 end else
 begin
  if FInfo.ItemIDs_[FInfo.Position]=0 then
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
 Options.Files := Copy(FInfo.ItemFileNames_);
 Options.IDs := Copy(FInfo.ItemIDs_);
 Options.Selected := Copy(FInfo.ItemSelected_);
 TRefreshDBRecordsThread.Create(false,Options);
end;

procedure TDBPopupMenu.RefreshThumItemPopUpMenu_(Sender: TObject);
var
  i:integer;
  EventInfo : TEventValues;
begin
 EventInfo.Image:=nil;
 for i:=0 to Length(FInfo.ItemIDs_)-1 do
 if FInfo.ItemSelected_[i] then
 DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[i],[EventID_Param_Image],EventInfo);
end;

procedure TDBPopupMenu.RenameItemPopUpMenu_(Sender: TObject);
begin
 if FInfo.ListItem is TListItem then
  TListItem(FInfo.ListItem).EditCaption;
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
 NewSearch.SearchEdit.Text:=':ScanImageW('+Finfo.ItemFileNames_[Finfo.Position]+':1):';
 NewSearch.SetPath(GetDirectory(Finfo.ItemFileNames_[Finfo.Position]));
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
 NewSearch.SearchEdit.Text:=':Folder('+inttostr(Finfo.ItemIDs_[Finfo.Position])+'):';
 NewSearch.SetPath(GetDirectory(Finfo.ItemFileNames_[Finfo.Position]));
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
 For i:=0 to Length(FInfo.ItemFileNames_)-1 do
 if FInfo.ItemSelected_[i] then
 begin
  if FInfo.ItemIDs_[i]=0 then
  begin
  Setlength(InfoNames,Length(InfoNames)+1);
  Setlength(Infoloaded,Length(Infoloaded)+1);
  InfoNames[Length(InfoNames)-1]:=FInfo.ItemFileNames_[i];
  Infoloaded[Length(Infoloaded)-1]:=FInfo.ItemLoaded_[i];
  end else
  begin
   Setlength(InfoIDs,Length(InfoIDs)+1);
   InfoIDs[Length(InfoIDs)-1]:=FInfo.ItemIDs_[i];
  end;
 end;
 If NumberOfPanel>=0 then
 begin
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,true,ManagerPanels.Panels[NumberOfPanel]);
  LoadFilesToPanel.Create(false,InfoNames,InfoIDs,Infoloaded,true,false,ManagerPanels.Panels[NumberOfPanel]);
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
 If Length(info.ItemIDs_)=0 then exit;
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
  SQL_:='Update '+GetDefDBName+' Set Rating='+inttostr(NewRating)+' Where ID in (';

  FirstID:=True;
  for i:=0 to Length(finfo.ItemIDs_)-1 do
  if finfo.ItemSelected_[i] then
  begin
   if FirstID then SQL_:=SQL_+' '+inttostr(finfo.ItemIDs_[i])+' ' else
   SQL_:=SQL_+' , '+inttostr(finfo.ItemIDs_[i])+' ';
   FirstID:=False;
  end;
  SQL_:=SQL_+')';
  fQuery.active:=false;
  SetSQL(fQuery,SQL_);
  try
   ExecSQL(fQuery);
   except
  end;
  for i:=0 to Length(FInfo.ItemFileNames_)-1 do
  if FInfo.ItemSelected_[i] then
  begin
   EventInfo.Rating:=NewRating;
   DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[i],[EventID_Param_Rating],EventInfo);
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
 for i:=0 to Length(FInfo.ItemFileNames_)-1 do
 if FInfo.ItemSelected_[i] then
 begin
  SetRotate(FInfo.ItemIDs_[i],NewRotate);
  EventInfo.Rotate:=NewRotate;
  DBKernel.DoIDEvent(Sender,FInfo.ItemIDs_[i],[EventID_Param_Rotate],EventInfo);
 end;
end;

procedure TDBPopupMenu.ShellExecutePopUpMenu_(Sender: TObject);
var
  i : integer;
  AllOperations : Integer;
  s : String;
begin
 AllOperations:=0;
 for i:=0 to Length(FInfo.ItemFileNames_)-1 do
 if FInfo.ItemSelected_[i] then
 Inc(AllOperations);
 If AllOperations>10 then
 if ID_OK<>MessageBoxDB(GetActiveFormHandle,Format(TEXT_MES_SHELL_OPEN_CONFIRM_FORMAT,[inttostr(AllOperations)]),TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then exit;
 for i:=0 to Length(FInfo.ItemFileNames_)-1 do
 if FInfo.ItemSelected_[i] then
 begin
  s:=GetDirectory(Finfo.ItemFileNames_[i]);
  UnFormatDir(s);
  if ShellExecute(0, Nil,Pchar(ProcessPath(Finfo.ItemFileNames_[i])), Nil, Pchar(s), SW_NORMAL)<32 then
  EventLog(':TDBPopupMenu::ShellExecutePopUpMenu()/ShellExecute return < 32, path = '+Finfo.ItemFileNames_[i]);
 end;
end;

procedure TDBPopupMenu.ShowDublicatesItemPopUpMenu_(Sender: TObject);
begin
 With SearchManager.NewSearch do
 begin
  SearchEdit.text:=':Similar('+IntToStr(FInfo.ItemIDs_[Finfo.Position])+'):';
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
end;

procedure TDBPopupMenu.UserMenuItemPopUpMenu_(Sender: TObject);
var
  i : integer;
  Params, ExeFile, ExeParams : String;
begin
 for i:=0 to Length(Finfo.ItemFileNames_)-1 do
 if FInfo.ItemSelected_[i] then
 begin
   Params:=' "'+Finfo.ItemFileNames_[i]+'" ';
 end;
 ExeFile:=FUserMenu[(Sender as TMenuItem).Tag].EXEFile;
 ExeParams:=StringReplace(FUserMenu[(Sender as TMenuItem).Tag].Params,'%1',params,[rfReplaceAll,rfIgnoreCase]);
 if ShellExecute(0,nil,PChar(ExeFile),Pchar(ExeParams),nil,SW_SHOWNORMAL)<32 then
 EventLog(':TDBPopupMenu::UserMenuItemPopUpMenu()/ShellExecute return < 32, path = '+ExeFile+' params = '+ExeParams);
end;

procedure TDBPopupMenu.WallpaperCenterItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo.ItemFileNames_[finfo.Position];
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_STRETCH) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TDBPopupMenu.WallpaperStretchItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo.ItemFileNames_[finfo.Position];
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_CENTER) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TDBPopupMenu.WallpaperTileItemPopUpMenu_(Sender: TObject);
var
  FileName : string;
begin
 FileName:=finfo.ItemFileNames_[finfo.Position];
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_TILE) else
 MessageBoxDB(Dolphin_DB.GetActiveFormHandle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

initialization

 if ThisFileInstalled or DBInDebug or Emulation then
 begin
  ReloadIDMenu;
 end;

end.

