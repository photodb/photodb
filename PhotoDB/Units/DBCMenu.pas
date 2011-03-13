unit DBCMenu;

interface

uses
  StdCtrls, UnitGroupsWork, ComCtrls, Dolphin_DB,
  dialogs,ExtCtrls, ShlObj, ComObj, ActiveX, Math, Controls, Filectrl,
  forms, Registry, ShellApi, Windows, SysUtils, Classes, DB,
  Graphics, Menus, UnitDBKernel, UnitCryptImageForm, GraphicCrypt,
  ProgressActionUnit, PrintMainForm, JPEG, ShellContextMenu, uVistaFuncs,
  UnitSQLOptimizing, UnitScripts, DBScriptFunctions, UnitRefreshDBRecordsThread,
  EasyListview, UnitCryptingImagesThread, UnitINI, UnitDBDeclare, uTime,
  UnitDBCommonGraphics, uScript, uLogger, uFileUtils, uMemory, uGOM,
  uDBPopupMenuInfo, uConstants, uPrivateHelper, uTranslate,
  uShellIntegration, uDBBaseTypes, uDBForm, uDBUtils, uSettings;

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
    FOwner : TDBForm;
   public
    class function Instance : TDBPopupMenu;
    constructor Create;
    destructor Destroy; override;
    procedure ShowItemPopUpMenu_(Sender : TObject);
    procedure ShellExecutePopUpMenu_(Sender: TObject);
    procedure SearchFolderPopUpMenu_(Sender: TObject);
    procedure DeleteLItemPopUpMenu_(Sender: TObject);
    procedure DeleteItemPopUpMenu_(Sender: TObject);
    procedure RefreshThumItemPopUpMenu_(Sender: TObject);
    procedure PropertyItemPopUpMenu_(Sender: TObject);
    procedure ScanImageItemPopUpMenu_(Sender: TObject);
    procedure SetRatingItemPopUpMenu_(Sender: TObject);
    procedure SetRotateItemPopUpMenu_(Sender: TObject);
    procedure PrivateItemPopUpMenu_(Sender: TObject);
    procedure RenameItemPopUpMenu_(Sender: TObject);
    procedure CopyItemPopUpMenu_(Sender: TObject);
    procedure SendToItemPopUpMenu_(Sender: TObject);
    procedure ExplorerPopUpMenu_(Sender: TObject);
    procedure GroupsPopUpMenu_(Sender: TObject);
    procedure DateItemPopUpMenu_(Sender: TObject);
    procedure CryptItemPopUpMenu_(Sender: TObject);
    procedure DeCryptItemPopUpMenu_(Sender: TObject);
    procedure QuickGroupInfoPopUpMenu_(Sender: TObject);
    procedure EnterPasswordItemPopUpMenu_(Sender: TObject);
    procedure ImageEditorItemPopUpMenu_(Sender: TObject);
    procedure WallpaperStretchItemPopUpMenu_(Sender: TObject);
    procedure WallpaperCenterItemPopUpMenu_(Sender: TObject);
    procedure WallpaperTileItemPopUpMenu_(Sender: TObject);
    procedure RefreshIDItemPopUpMenu_(Sender: TObject);
    procedure ShowDublicatesItemPopUpMenu_(Sender: TObject);
    procedure DeleteDublicatesItemPopUpMenu_(Sender: TObject);
    procedure UserMenuItemPopUpMenu_(Sender: TObject);
    procedure PrintItemPopUpMenu_(Sender: TObject);
    procedure Execute(Owner : TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo);
    procedure ExecutePlus(Owner : TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo; Menus: TArMenuitem);
    procedure AddDBContMenu(Form: TDBForm; Item: Tmenuitem; Info: TDBPopupMenuInfo);
    procedure AddUserMenu(Item: Tmenuitem; Insert: Boolean; index: Integer);
    procedure SetInfo(Form: TDBForm; Info: TDBPopupMenuInfo);
    procedure ScriptExecuted(Sender: TObject);
    function GetGroupImageInImageList(GroupCode: string): Integer;
    function LoadVariablesNo(int : Integer) : integer;
  end;

 procedure ReloadIDMenu;

 const
   DBMenuID = 'DBMenu';

var
   MenuScript : string;
   aFS : TFileStream;

implementation

uses
  ExplorerUnit, PropertyForm, SlideShow, Searching, UnitFormCont,
  UnitLoadFilesToPanel, UnitEditGroupsForm, UnitMenuDateForm, CmpUnit,
  UnitQuickGroupInfo, UnitCrypting, UnitPasswordForm,
  ImEditor, FormManegerUnit, CommonDBSupport,
  UnitCDMappingSupport;

var
  DBPopupMenu: TDBPopupMenu = nil;

{ TDBPopupMenu }

procedure ReloadIDMenu;
begin
  MenuScript := ReadScriptFile('Scripts\IDMenu.dbini');
end;

procedure TDBPopupMenu.AddDBContMenu(Form: TDBForm; Item: TMenuItem;
  Info: TDBPopupMenuInfo);
var
  I: Integer;
  Isrecord, IsFile, IsCurrentFile: Boolean;
  PanelsTexts: TStrings;
  MenuGroups: TGroups;
  GroupsList: TStringList;
  StrGroups, Script: string;
  BusyMenu, ErrorMenu: TMenuItem;
  OnlyCurrentDBinfoSelected: Boolean;
  NoDBInfoNeeded: Boolean;
  APanelTexts, AGroupsNames, AGroupsCodes: TArrayOfString;

const
  ShowGroupsInContextMenu = True;

begin
  if FBusy then
  begin
    for I := 0 to Item.Count - 1 do
      Item.Delete(0);
    BusyMenu := Tmenuitem.Create(_popupmenu);
    BusyMenu.Caption := TA('Busy...', DBMenuID);
    BusyMenu.Enabled := False;
    Item.Add(BusyMenu);
    Exit;
  end;
  if Info.Count = 0 then
  begin
    for I := 0 to Item.Count - 1 do
      Item.Delete(0);
    ErrorMenu := TMenuItem.Create(_popupmenu);
    ErrorMenu.Caption := TA('Unable to show menu!', DBMenuID);
    ErrorMenu.Enabled := False;
    Item.Add(ErrorMenu);
    Exit;
  end;

  FOwner := Form;

  Finfo.Assign(Info);
  Isrecord := True;
  if Finfo.Count = 1 then
    if Finfo[0].ID = 0 then
      Isrecord := False;
  for I := 0 to Item.Count - 1 do
    Item.Delete(0);

  if Finfo.Count > 1 then
  begin
    Isrecord := False;
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].ID <> 0 then
        Isrecord := True;
  end;
  NoDBInfoNeeded := False;

  OnlyCurrentDBinfoSelected := True;
  if Finfo.Count > 1 then
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].ID <> 0 then
        if Finfo[I].Selected then
          if Finfo.Position <> I then
            OnlyCurrentDBinfoSelected := False;
  if Finfo[Finfo.Position].Selected then
    if Finfo[Finfo.Position].ID = 0 then
      if not OnlyCurrentDBinfoSelected then
        NoDBInfoNeeded := True;
  if not Isrecord then
    NoDBInfoNeeded := True;
  if Finfo[Finfo.Position].ID = 0 then
    NoDBInfoNeeded := True;

  TW.I.Start('FileExists');
  IsCurrentFile:=FileExistsSafe(finfo[finfo.Position].FileName);

  IsFile := IsCurrentFile;
  if not IsFile then
    for I := 0 to Finfo.Count - 1 do
      if FileExistsSafe(Finfo[I].FileName) then
      begin
        IsFile := True;
        Break;
      end;

  SetLength(MenuGroups, 0);

  Script := MenuScript;

  TW.I.Start('Vars');
  SetBoolAttr(AScript, '$CanRename', Finfo.IsListItem);
  SetBoolAttr(AScript, '$IsRecord', IsRecord);
  SetBoolAttr(AScript, '$IsFile', IsFile);
  SetBoolAttr(AScript, '$NoDBInfoNeeded', NoDBInfoNeeded);

  SetIntAttr(AScript, '$MenuLength', Finfo.Count);
  SetIntAttr(AScript, '$Position', Finfo.Position);

  // if user haven't rights to get FileName its only possible way to know
  SetBoolAttr(AScript, '$FileExists', FileExistsSafe(Finfo[Finfo.Position].FileName));

  // END Access section
  SetBoolAttr(aScript,'$IsCurrentFile',IsCurrentFile);

  LoadVariablesNo(finfo.Position);

  TW.I.Start('Panels');
  PanelsTexts := TStringList.Create;
  try
    ManagerPanels.GetPanelsTexts(PanelsTexts);
    SetLength(APanelTexts, PanelsTexts.Count);
    for I := 0 to PanelsTexts.Count - 1 do
      APanelTexts[I] := PanelsTexts[I];
    SetNamedValueArrayStrings(AScript, '$Panels', APanelTexts);
  finally
    F(PanelsTexts);
  end;
  TW.I.Start('Groups');
  GroupsList := TStringList.Create;
  try
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        GroupsList.Add(FInfo[I].Groups);

    SetNamedValueArrayStrings(AScript, '$Panels', APanelTexts);
    StrGroups := GetCommonGroups(GroupsList);
  finally
    F(GroupsList);
  end;
  MenuGroups := EnCodeGroups(StrGroups);
  SetLength(AGroupsNames, Length(MenuGroups));
  SetLength(AGroupsCodes, Length(MenuGroups));
  for I := 0 to Length(MenuGroups) - 1 do
  begin
    AGroupsNames[I] := MenuGroups[I].GroupName;
    AGroupsCodes[I] := MenuGroups[I].GroupCode;
  end;
  SetNamedValueArrayStrings(AScript, '$GroupsNames', AGroupsNames);
  SetNamedValueArrayStrings(AScript, '$GroupsCodes', AGroupsCodes);
  TW.I.Start('LoadMenuFromScript');
  LoadMenuFromScript(Item, DBKernel.ImageList, Script, AScript, ScriptExecuted, FExtImagesInImageList, True);
  TW.I.Start('LoadMenuFromScript - end');
end;

procedure TDBPopupMenu.AddUserMenu(Item: TMenuItem; Insert : Boolean; Index : integer);
var
  Reg: TBDRegistry;
  S: TStrings;
  I, C: Integer;
  FCaption, EXEFile, Params, Icon: string;
  UseSubMenu: Boolean;
  Ico: TIcon;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Menu', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      SetLength(FUserMenu, 0);
      SetLength(_user_group_menu_sub_items, 0);
      SetLength(_user_menu, 0);
      C := 0;
      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + '\Menu\' + S[I], True);
        if Reg.ValueExists('Caption') then
          FCaption := Reg.ReadString('Caption')
        else
          FCaption := 'NO_CAPTION';
        if Reg.ValueExists('EXEFile') then
          EXEFile := Reg.ReadString('EXEFile')
        else
          EXEFile := 'Explorer.exe';
        if Reg.ValueExists('Params') then
          Params := Reg.ReadString('Params')
        else
          Params := '';
        if Reg.ValueExists('Icon') then
          Icon := Reg.ReadString('Icon')
        else
          Icon := '';
        if Reg.ValueExists('UseSubMenu') then
          UseSubMenu := Reg.ReadBool('UseSubMenu')
        else
          UseSubMenu := False;
        if (FCaption <> '') and (EXEFile <> '') then
        begin
          SetLength(FUserMenu, Length(FUserMenu) + 1);
          FUserMenu[Length(FUserMenu) - 1].Caption := FCaption;
          FUserMenu[Length(FUserMenu) - 1].EXEFile := EXEFile;
          FUserMenu[Length(FUserMenu) - 1].Params := Params;
          FUserMenu[Length(FUserMenu) - 1].Icon := Icon;
          FUserMenu[Length(FUserMenu) - 1].UseSubMenu := UseSubMenu;
          if UseSubMenu then
            Inc(C);
        end;
      end;
      if C > 0 then
      begin
        _user_group_menu := TMenuItem.Create(Item);
        if Settings.ReadString('', 'UserMenuName') <> '' then
          _user_group_menu.Caption := Settings.ReadString('', 'UserMenuName')
        else
          _user_group_menu.Caption := TA('Additional', DBMenuID);
        Icon := Settings.ReadString('', 'UserMenuIcon');
        if Icon = '' then
          Icon := '%SystemRoot%\system32\shell32.dll,126';
        Ico := TIcon.Create;
        try
          Ico.Handle := ExtractSmallIconByPath(Icon);
          if not Ico.Empty then
          begin
            Inc(FExtImagesInImageList);
            DBkernel.ImageList.AddIcon(Ico);
            _user_group_menu.ImageIndex := DBkernel.ImageList.Count - 1;
          end
          else
            _user_group_menu.ImageIndex := DB_IC_COMPUTER;
        finally
          F(Ico);
        end;

      end;
      for I := 0 to Length(FUserMenu) - 1 do
      begin
        if FUserMenu[I].UseSubMenu then
        begin
          SetLength(_user_group_menu_sub_items, Length(_user_group_menu_sub_items) + 1);
          _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1] := TMenuItem.Create(_user_group_menu);
          _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1].Caption := FUserMenu[I].Caption;
          _user_group_menu.Add(_user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1]);
          _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1].Tag := I;
          _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1].OnClick := UserMenuItemPopUpMenu_;
          Ico := TIcon.Create;
          try
            Ico.Handle := ExtractSmallIconByPath(FUserMenu[I].Icon);
            if not Ico.Empty then
            begin
              Inc(FExtImagesInImageList);
              DBkernel.ImageList.AddIcon(Ico);
              _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1].ImageIndex := DBkernel.ImageList.Count - 1;
            end
            else
              _user_group_menu_sub_items[Length(_user_group_menu_sub_items) - 1].ImageIndex := DB_IC_COMPUTER;
          finally
            F(Ico);
          end;
        end else
        begin
          SetLength(_user_menu, Length(_user_menu) + 1);
          _user_menu[Length(_user_menu) - 1] := TMenuItem.Create(Item);
          _user_menu[Length(_user_menu) - 1].Caption := FUserMenu[I].Caption;
          _user_menu[Length(_user_menu) - 1].Tag := I;
          _user_menu[Length(_user_menu) - 1].OnClick := UserMenuItemPopUpMenu_;
          Ico := TIcon.Create;
          try
            Ico.Handle := ExtractSmallIconByPath(FUserMenu[I].Icon);
            if not Ico.Empty then
            begin
              Inc(FExtImagesInImageList);
              DBkernel.ImageList.AddIcon(Ico);
              _user_menu[Length(_user_menu) - 1].ImageIndex := DBkernel.ImageList.Count - 1;
            end
            else
              _user_menu[Length(_user_menu) - 1].ImageIndex := DB_IC_COMPUTER;
          finally
            F(Ico);
          end;
        end;
      end;
      if C > 0 then
        if Insert then
          Item.Insert(index, _user_group_menu)
        else
          Item.Add(_user_group_menu);
      if Insert then
      begin
        for I := 0 to Length(_user_menu) - 1 do
          Item.Insert(index, _user_menu[I]);
      end
      else
        Item.Add(_user_menu);
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

procedure TDBPopupMenu.CopyItemPopUpMenu_(Sender: TObject);
var
  I: integer;
  FileList: TStrings;
  EventInfo: TEventValues;
begin
  FileList := TStringList.Create;
  try
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        if FileExistsSafe(FInfo[I].FileName) then
          FileList.Add(FInfo[I].FileName);

    Copy_Move(True, FileList);

    DBKernel.DoIDEvent(FOwner, 0, [EventID_Param_CopyPaste], EventInfo);
  finally
    F(FileList);
  end;
end;

constructor TDBPopupMenu.create;
begin
  inherited;

  FBusy := False;
  Finfo := TDBPopupMenuInfo.Create;
  AScript := TScript.Create('');
  AScript.Description := 'ID Menu';
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

  _popupmenu := Tpopupmenu.Create(nil);
end;

procedure TDBPopupMenu.CryptItemPopUpMenu_(Sender: TObject);
var
  Options: TCryptImageThreadOptions;
  Opt: TCryptImageOptions;
  I, CryptOptions: Integer;
begin
  Opt := GetPassForCryptImageFile(TA('SelectedObjects', DBMenuID));
  if Opt.SaveFileCRC then
    CryptOptions := CRYPT_OPTIONS_SAVE_CRC
  else
    CryptOptions := CRYPT_OPTIONS_NORMAL;
  if Opt.Password = '' then
    Exit;

  SetLength(Options.Files, FInfo.Count);
  SetLength(Options.IDs, FInfo.Count);
  SetLength(Options.Selected, FInfo.Count);
  for I := 0 to FInfo.Count - 1 do
  begin
    Options.Files[I] := FInfo[I].FileName;
    Options.IDs[I] := FInfo[I].ID;
    Options.Selected[I] := FInfo[I].Selected;
  end;

  Options.Password := Opt.Password;
  Options.CryptOptions := CryptOptions;
  Options.Action := ACTION_CRYPT_IMAGES;
  TCryptingImagesThread.Create(FOwner, Options);
end;

procedure TDBPopupMenu.DateItemPopUpMenu_(Sender: TObject);
var
  ArDates: TArDateTime;
  ArTimes: TArTime;
  ArIsDates: TArBoolean;
  ArIsTimes: TArBoolean;
  Date: TDateTime;
  I: Integer;
  Time: TDateTime;
  IsDate, IsTime, Changed, FirstID: Boolean;
  _sqlexectext: string;
  FQuery: TDataSet;
  EventInfo: TEventValues;
begin
  SetLength(ArDates, 0);
  SetLength(ArIsDates, 0);
  SetLength(ArTimes, 0);
  SetLength(ArIsTimes, 0);
  for I := 0 to FInfo.Count - 1 do
    if Finfo[I].Selected then
    begin
      SetLength(ArDates, Length(ArDates) + 1);
      ArDates[Length(ArDates) - 1] := FInfo[I].Date;
      SetLength(ArTimes, Length(ArTimes) + 1);
      ArTimes[Length(ArTimes) - 1] := FInfo[I].Time;
      SetLength(ArIsDates, Length(ArIsDates) + 1);
      ArIsDates[Length(ArIsDates) - 1] := FInfo[I].IsDate;
      SetLength(ArIsTimes, Length(ArIsTimes) + 1);
      ArIsTimes[Length(ArIsTimes) - 1] := FInfo[I].IsTime;
    end;
  IsDate := MaxStatBool(ArIsDates);
  IsTime := MaxStatBool(ArIsTimes);
  Date := MaxStatDate(ArDates);
  Time := MaxStatTime(ArTimes);
  ChangeDate(Date, IsDate, Changed, Time, IsTime);
  if Changed then
  begin
    FQuery := GetQuery;
    begin
   // [BEGIN] Date Support
      if IsDate then
      begin
        _sqlexectext := 'Update $DB$ Set DateToAdd = :Date, IsDate = TRUE Where ID in (';
        FirstID := True;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
          begin
            if FirstID then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(Finfo[I].ID) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(Finfo[I].ID) + ' ';
            FirstID := False;
          end;
        _sqlexectext := _sqlexectext + ')';
        FQuery.Active := False;
        SetSQL(FQuery, _sqlexectext);
        SetDateParam(FQuery, 'Date', Date);
        ExecSQL(FQuery);
        EventInfo.Date := Date;
        EventInfo.IsDate := True;
        for I := 0 to FInfo.Count - 1 do
          if FInfo[I].Selected then
            DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Date, EventID_Param_IsDate], EventInfo);
      end
      else
      begin
        _sqlexectext := 'Update $DB$ Set IsDate = FALSE Where ID in (';
        FirstID := True;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
          begin
            if FirstID then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(Finfo[I].ID) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(Finfo[I].ID) + ' ';
            FirstID := False;
          end;
        _sqlexectext := _sqlexectext + ')';
        FQuery.Active := False;
        SetSQL(FQuery, _sqlexectext);
        ExecSQL(FQuery);
        EventInfo.IsDate := FALSE;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
            DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_IsDate], EventInfo);
      end;
      // [END] Date Support
      // [BEGIN] Time Support
      if IsTime then
      begin
        _sqlexectext := 'Update $DB$ Set aTime = :aTime, IsTime = TRUE Where ID in (';
        FirstID := True;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
          begin
            if FirstID then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(Finfo[I].ID) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(Finfo[I].ID) + ' ';
            FirstID := False;
          end;
        _sqlexectext := _sqlexectext + ')';
        FQuery.Active := False;
        SetSQL(FQuery, _sqlexectext);
        SetDateParam(FQuery, 'aTime', Time);
        ExecSQL(FQuery);
        EventInfo.Time := Time;
        EventInfo.IsTime := True;
        for I := 0 to Finfo.Count - 1 do
          if Finfo[I].Selected then
            DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Time, EventID_Param_IsTime], EventInfo);
      end
      else
      begin
        _sqlexectext := 'Update $DB$ Set IsTime = FALSE Where ID in (';
        FirstID := True;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
          begin
            if FirstID then
              _sqlexectext := _sqlexectext + ' ' + Inttostr(Finfo[I].ID) + ' '
            else
              _sqlexectext := _sqlexectext + ' , ' + Inttostr(Finfo[I].ID) + ' ';
            FirstID := False;
          end;
        _sqlexectext := _sqlexectext + ')';
        FQuery.Active := False;
        SetSQL(FQuery, _sqlexectext);
        ExecSQL(FQuery);
        EventInfo.IsTime := FALSE;
        for I := 0 to FInfo.Count - 1 do
          if Finfo[I].Selected then
            DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_IsTime], EventInfo);
      end;
      // [END] Time Support
    end;
    FreeDS(FQuery);
  end;
end;

procedure TDBPopupMenu.DeCryptItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  Options: TCryptImageThreadOptions;
  ItemFileNames: TArStrings;
  ItemIDs: TArInteger;
  ItemSelected: TArBoolean;
  Password: string;
begin

  Password := DBKernel.FindPasswordForCryptImageFile(FInfo[FInfo.Position].FileName);
  if Password = '' then
    if FileExistsSafe(FInfo[FInfo.Position].FileName) then
      Password := GetImagePasswordFromUser(FInfo[FInfo.Position].FileName);

  Setlength(ItemFileNames, FInfo.Count);
  Setlength(ItemIDs, FInfo.Count);
  Setlength(ItemSelected, FInfo.Count);

  for I := 0 to FInfo.Count - 1 do
  begin
    ItemFileNames[I] := FInfo[I].FileName;
    ItemIDs[I] := FInfo[I].ID;
    ItemSelected[I] := FInfo[I].Selected;
  end;

  Options.Files := Copy(ItemFileNames);
  Options.IDs := Copy(ItemIDs);
  Options.Selected := Copy(ItemSelected);
  Options.Action := ACTION_DECRYPT_IMAGES;
  Options.Password := Password;
  Options.CryptOptions := 0;
  TCryptingImagesThread.Create(FOwner, Options);
end;

procedure TDBPopupMenu.DeleteDublicatesItemPopUpMenu_(Sender: TObject);
var
  I, J: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  Files, S: TArStrings;
  IDs: TArInteger;
begin
  if ID_OK = MessageBoxDB(GetActiveFormHandle, TA('Do you really want ot delete this info from DB?', DBMenuID),
    TA('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
        if Finfo[I].Attr = Db_attr_dublicate then
        begin
          FQuery := GetQuery;
          SQL_ := 'SELECT FFileName, ID FROM $DB$ WHERE (ID<>' + IntToStr(Finfo[I].ID) +
            ') AND (StrTh=(SELECT StrTh FROM $DB$ WHERE ID = ' + IntToStr(Finfo[I].ID) + '))';
          SetSQL(FQuery, SQL_);
          FQuery.Open;
          FQuery.First;
          SetLength(Files, FQuery.RecordCount);
          SetLength(IDs, FQuery.RecordCount);
          for J := 1 to FQuery.RecordCount do
          begin
            Files[J - 1] := FQuery.FieldByName('FFileName').AsString;
            IDs[J - 1] := FQuery.FieldByName('ID').AsInteger;
            FQuery.Next;
          end;
          FQuery.Close;
          SQL_ := 'DELETE FROM $DB$ WHERE (ID<>' + IntToStr(Finfo[I].ID) +
            ') AND (StrTh=(SELECT StrTh FROM $DB$ WHERE ID = ' + IntToStr(Finfo[I].ID) + '))';
          SetSQL(FQuery, SQL_);
          ExecSQL(FQuery);
          SQL_ := 'UPDATE $DB$ SET Attr = ' + IntToStr(Db_attr_norm) + ' WHERE (ID=' + IntToStr(Finfo[I].ID) + ')';
          SetSQL(FQuery, SQL_);
          ExecSQL(FQuery);
          EventInfo.Attr := Db_attr_norm;
          DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Attr], EventInfo);
          SetLength(S, 1);
          for J := 0 to Length(Files) - 1 do
          begin
            begin
              if FileExistsSafe(Files[J]) then
              begin
                try
                  SilentDeleteFile(Application.Handle, Files[J], True);
                except
                end;
              end;
            end;
            DBKernel.DoIDEvent(FOwner, IDs[J], [EventID_Param_Delete], EventInfo);
          end;
          FreeDS(FQuery);
        end;
  end;
end;

procedure TDBPopupMenu.DeleteItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  S: TArStrings;
  FirstID: Boolean;
begin
  if ID_OK = MessageBoxDB(GetActiveFormHandle, TA('Do you really want ot delete this info from DB?'), TA('Confirm'),
    TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    FQuery := GetQuery;
    SQL_ := 'UPDATE $DB$ SET Attr=' + Inttostr(Db_attr_not_exists) + ' WHERE ID in (';
    FirstID := True;
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
      begin
        if FirstID then
          SQL_ := SQL_ + ' ' + Inttostr(Finfo[I].ID) + ' '
        else
          SQL_ := SQL_ + ' , ' + Inttostr(Finfo[I].ID) + ' ';
        FirstID := False;
      end;
    SQL_ := SQL_ + ')';
    SetSQL(FQuery, SQL_);
    ExecSQL(FQuery);
    SetLength(S, 1);
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
      begin
        begin
          if FileExistsSafe(Finfo[I].FileName) then
          begin
            try
              SilentDeleteFile(Application.Handle, Finfo[I].FileName, True);
            except
            end;
          end;
        end;
        DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Delete], EventInfo);
      end;
    FreeDS(FQuery);
  end;
end;

procedure TDBPopupMenu.DeleteLItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  FirstID: Boolean;
begin
 if IdOk = MessageBoxDB(GetActiveFormHandle, TA('Do you really want ot delete this info from DB?', DBMenuID),
    TA('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    FQuery := GetQuery;
    try
      FQuery.Active := False;
      SQL_ := 'DELETE FROM $DB$ WHERE ID in (';
      FirstID := True;
      for I := 0 to Finfo.Count - 1 do
        if Finfo[I].Selected then
        begin
          if FirstID then
            SQL_ := SQL_ + ' ' + Inttostr(Finfo[I].ID) + ' '
          else
            SQL_ := SQL_ + ' , ' + Inttostr(Finfo[I].ID) + ' ';
          FirstID := False;
        end;
      SQL_ := SQL_ + ')';
      SetSQL(FQuery, SQL_);
      ExecSQL(FQuery);
      for I := 0 to Finfo.Count - 1 do
        if Finfo[I].Selected then
          DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Delete], EventInfo);
    finally
      FreeDS(FQuery);
    end;
  end;
end;

destructor TDBPopupMenu.destroy;
begin
  F(_popupmenu);
  if GOM.IsObj(aScript) then
    F(aScript);
  F(Finfo);
  inherited;
end;

procedure TDBPopupMenu.EnterPasswordItemPopUpMenu_(Sender: TObject);
var
  EventInfo: TEventValues;
  Query: TDataSet;
  ID: Integer;
begin
  EventInfo.Image := nil;
  if FileExistsSafe(FInfo[FInfo.Position].FileName) then
  begin
    if GetImagePasswordFromUser(FInfo[FInfo.Position].FileName) <> '' then
      DBKernel.DoIDEvent(FOwner, FInfo[FInfo.Position].ID, [EventID_Param_Image], EventInfo);
  end
  else
  begin
    Query := GetQuery;
    ID := GetIdByFileName(FInfo[FInfo.Position].FileName);
    if ID = 0 then
      Exit;
    SetSQL(Query, 'SELECT * from $DB$ where ID=' + IntToStr(ID));
    Query.Open;
    if GetImagePasswordFromUserBlob(Query.FieldByName('thum'), FInfo[FInfo.Position].FileName) <> '' then
      DBKernel.DoIDEvent(FOwner, FInfo[FInfo.Position].ID, [EventID_Param_Image], EventInfo);
    Query.Free;
  end;
end;

procedure TDBPopupMenu.Execute(Owner: TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo);
begin
  FOwner := Owner;
  FPopUpPoint := Point(X, Y);
  if not FBusy then
  begin
    FInfo.Assign(Info);
    if Finfo.Count = 0 then
      Exit;
    begin
      _popupmenu.Images := DBKernel.ImageList;
      _popupmenu.Items.Clear;
      AddDBContMenu(FOwner, _popupmenu.Items, Finfo);
      _popupmenu.Popup(X, Y);
    end;
  end else
  begin
    _popupmenu.Items.Clear;
    AddDBContMenu(FOwner, _popupmenu.Items, Finfo);
    _popupmenu.Popup(X, Y);
  end;
end;

procedure TDBPopupMenu.ExecutePlus(Owner : TDBForm; x, y: integer; info: TDBPopupMenuInfo;
  Menus: TArMenuitem);
var
  I: Integer;
  _menuitem_nil: Tmenuitem;
begin
  FOwner := Owner;
  FPopUpPoint := Point(X, Y);
  FInfo.Assign(Info);
  if Finfo.Count = 0 then
    Exit;
  begin

    _popupmenu.Images := DBKernel.ImageList;
    _popupmenu.Items.Clear;
    AddDBContMenu(FOwner, _popupmenu.Items, Finfo);
    if Length(Menus) > 0 then
    begin
      _menuitem_nil := Tmenuitem.Create(_popupmenu);
      _menuitem_nil.Caption := '-';
      _popupmenu.Items.Add(_menuitem_nil);
      for I := 0 to Length(Menus) - 1 do
      begin
        _popupmenu.Items.Add(Menus[I]);
      end;
    end;
    _popupmenu.Popup(X, Y);

  end;
end;

procedure TDBPopupMenu.ExplorerPopUpMenu_(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(FInfo[FInfo.Position].FileName);
    SetPath(ExtractFilePath(FInfo[FInfo.Position].FileName));
    Show;
  end;
end;

function TDBPopupMenu.GetGroupImageInImageList(GroupCode: string): Integer;
var
  FGroup: TGroup;
  B, SmallB: TBitmap;
  Size: Integer;
begin
  FGroup := GetGroupByGroupCode(GroupCode, True);
  if FGroup.GroupImage <> nil then
  begin
    if not FGroup.GroupImage.Empty then
    begin
      Inc(FExtImagesInImageList);
      B := TBitmap.Create;
      try
        B.PixelFormat := Pf24bit;
        SmallB := TBitmap.Create;
        try
          SmallB.PixelFormat := Pf24bit;
          B.Canvas.Brush.Color := Graphics.ClMenu;
          B.Canvas.Pen.Color := Graphics.ClMenu;
          Size := Max(FGroup.GroupImage.Width, FGroup.GroupImage.Height);
          B.Width := Size;
          B.Height := Size;
          B.Canvas.Rectangle(0, 0, Size, Size);
          B.Canvas.Draw(B.Width div 2 - FGroup.GroupImage.Width div 2, B.Height div 2 - FGroup.GroupImage.Height div 2,
            FGroup.GroupImage);
          DoResize(16, 16, B, SmallB);
          DBKernel.ImageList.Add(SmallB, nil);
        finally
          F(SmallB);
        end;
      finally
        F(B);
      end;
      Result := DBKernel.ImageList.Count - 1;
    end else
      Result := DB_IC_GROUPS;
  end else
    Result := DB_IC_GROUPS;
  FreeGroup(FGroup);
end;

procedure TDBPopupMenu.GroupsPopUpMenu_(Sender: TObject);
var
  I, J: Integer;
  KeyWordList, GroupList: TStringList;
  _sqlexectext, StrOldGroups, StrNewGroups, Groups, OldKeyWords, NewKeyWords, KeyWords: string;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  Count: Integer;
  ProgressForm: TProgressActionForm;
  VarkeyWords, VarGroups: Boolean;
  List: TSQLList;
  IDs: string;
begin
  FBusy := True;
  try
    GroupList := TStringList.Create;
    KeyWordList := TStringList.Create;
    Count := 0;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        Inc(Count);

    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
      begin
        GroupList.Add(FInfo[I].Groups);
        KeyWordList.Add(FInfo[I].KeyWords);
      end;
    StrOldGroups := GetCommonGroups(GroupList);
    StrNewGroups := GetCommonGroups(GroupList);
    OldKeyWords := GetCommonWordsA(KeyWordList);
    NewKeyWords := OldKeyWords;
    DBChangeGroups(StrNewGroups, NewKeyWords);
    VarKeyWords := VariousKeyWords(OldKeyWords, NewKeyWords);
    VarGroups := not CompareGroups(StrOldGroups, StrNewGroups);
    if not VarKeyWords and not VarGroups then
      Exit;

    fQuery := GetQuery;
    try
      ProgressForm:= GetProgressWindow;
      ProgressForm.MaxPosCurrentOperation := Count;
      ProgressForm.OneOperation := False;
      if Count > 2 then
        ProgressForm.DoFormShow;
      ProgressForm.XPosition := 0;
      if VarKeyWords and VarGroups then
        ProgressForm.OperationCount := 2
      else
        ProgressForm.OperationCount := 1;
      ProgressForm.OperationPosition := 1;
      FreeSQLList(List);
      if VarKeyWords then
        for I := 0 to FInfo.Count - 1 do
          if FInfo[I].Selected then
          begin
            KeyWords := FInfo[I].KeyWords;
            ReplaceWords(OldKeyWords, NewKeyWords, KeyWords);
            if VariousKeyWords(KeyWords, FInfo[I].KeyWords) then
              AddQuery(List, KeyWords, FInfo[I].ID);

          end;
      PackSQLList(List, VALUE_TYPE_KEYWORDS);
      ProgressForm.MaxPosCurrentOperation := Length(List);
      for I := 0 to Length(List) - 1 do
      begin
        IDs := '';
        for J := 0 to Length(List[I].IDs) - 1 do
        begin
          if J <> 0 then
            IDs := IDs + ' , ';
          IDs := IDs + ' ' + IntToStr(List[I].IDs[J]) + ' ';
        end;
        ProgressForm.XPosition := ProgressForm.XPosition + 1;

        //update progress window
        Application.ProcessMessages;
        _sqlexectext := 'Update $DB$ Set KeyWords = ' + NormalizeDBString(List[I].Value)
          + ' Where ID in (' + IDs + ')';
        FQuery.Active := False;
        SetSQL(FQuery, _sqlexectext);
        ExecSQL(FQuery);
        EventInfo.KeyWords := List[I].Value;
        for J := 0 to Length(List[I].IDs) - 1 do
          DBKernel.DoIDEvent(FOwner, List[I].IDs[J], [EventID_Param_KeyWords], EventInfo);
      end;

    finally
      FreeDS(fQuery);
    end;
    if not CompareGroups(StrNewGroups, StrOldGroups) then
    begin
      FreeSQLList(List);
      FQuery := GetQuery;
      try
        ProgressForm.XPosition := 0;
        if VarKeyWords and VarGroups then
          ProgressForm.OperationPosition := 2
        else
          ProgressForm.OperationPosition := 1;
        if VarGroups then
          for I := 0 to FInfo.Count - 1 do
            if FInfo[I].Selected then
            begin
              Groups := FInfo[I].Groups;
              ReplaceGroups(StrOldGroups, StrNewGroups, Groups);
              if not CompareGroups(Groups, FInfo[I].Groups) then
                AddQuery(List, Groups, FInfo[I].ID);

            end;

        PackSQLList(List, VALUE_TYPE_GROUPS);
        ProgressForm.MaxPosCurrentOperation := Length(List);
        for I := 0 to Length(List) - 1 do
        begin
          IDs := '';
          for J := 0 to Length(List[I].IDs) - 1 do
          begin
            if J <> 0 then
              IDs := IDs + ' , ';
            IDs := IDs + ' ' + IntToStr(List[I].IDs[J]) + ' ';
          end;
          ProgressForm.XPosition := ProgressForm.XPosition + 1;

        //update progress window
          Application.ProcessMessages;
          _sqlexectext := 'Update $DB$ Set Groups = ' + NormalizeDBString(List[I].Value) + ' Where ID in (' + IDs + ')';
          FQuery.Active := False;
          SetSQL(FQuery, _sqlexectext);
          ExecSQL(FQuery);
          EventInfo.Groups := List[I].Value;
          for J := 0 to Length(List[I].IDs) - 1 do
            DBKernel.DoIDEvent(FOwner,List[i].IDs[j],[EventID_Param_Groups],EventInfo);
      end;
      finally
        FreeDS(fQuery);
      end;
    end;
    ProgressForm.Close;
    ProgressForm.Release;
  finally
    FBusy := False;
  end;
end;

procedure TDBPopupMenu.ImageEditorItemPopUpMenu_(Sender: TObject);
begin
  with EditorsManager.NewEditor do
  begin
    Show;
    OpenFileName(Finfo[Finfo.Position].FileName);
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
  Result := 0;
  if Int < 0 then
    Exit;
  if Int > Finfo.Count - 1 then
    Exit;
  SetBoolAttr(AScript, '$Crypted', Finfo[Int].Crypted);
  SetBoolAttr(AScript, '$StaticImage', StaticPath(Finfo[Int].FileName));
  SetBoolAttr(AScript, '$WallPaper', IsWallpaper(Finfo[Int].FileName));
  SetBoolAttr(AScript, '$Selected', Finfo[Int].Selected);
  if Finfo[Int].Crypted then
  begin
    if DBkernel.FindPasswordForCryptImageFile(Finfo[Int].FileName[Int]) <> '' then
      SetNamedValue(AScript, '$CanDecrypt', 'true')
    else
      SetNamedValue(AScript, '$CanDecrypt', 'false');
  end;
  if Finfo.AttrExists then
  begin
    SetNamedValue(AScript, '$IsAttrExists', 'true');
    SetNamedValue(AScript, '$Attr', IntToStr(Finfo[Int].Attr));
    SetBoolAttr(AScript, '$Dublicat', Finfo[Int].Attr = Db_attr_dublicate);
  end else
  begin
    SetNamedValue(AScript, '$IsAttrExists', 'false');
    SetBoolAttr(AScript, '$Dublicat', False);
    SetNamedValue(AScript, '$Attr', '0');
  end;

  SetNamedValue(AScript, '$Access', IntToStr(Finfo[Int].Access));
  SetNamedValue(AScript, '$Rotation', IntToStr(Finfo[Int].Rotation));
  SetNamedValue(AScript, '$Rating', IntToStr(Finfo[Int].Rating));
  SetNamedValue(AScript, '$ID', IntToStr(Finfo[Int].ID));
  SetNamedValue(AScript, '$FileName', '"' + ProcessPath(Finfo[Int].FileName) + '"');
  SetNamedValue(AScript, '$KeyWords', '"' + Finfo[Int].KeyWords + '"');
  SetNamedValue(AScript, '$Links', '"' + Finfo[Int].Links + '"');
end;

procedure TDBPopupMenu.PrintItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
        if FileExistsSafe(Finfo[I].FileName) then
          Files.Add(Finfo[I].FileName);

    if Files.Count <> 0 then
      GetPrintForm(Files);
  finally
    F(Files);
  end;
end;

procedure TDBPopupMenu.PrivateItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
  OldAccess: Integer;
  Count: Integer;
  ProgressForm: TProgressActionForm;
begin
  FBusy := True;
  OldAccess := (Sender as TMenuItem).Tag;
  Count := 0;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
      Inc(Count);
  ProgressForm := GetProgressWindow;
  ProgressForm.MaxPosCurrentOperation := Count;
  ProgressForm.OneOperation := True;
  if Count > 2 then
    ProgressForm.DoFormShow;
  ProgressForm.XPosition := 0;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
  begin
      { !!! } Application.ProcessMessages;
      ProgressForm.XPosition := ProgressForm.XPosition + 1;
      if OldAccess = Db_access_none then
      begin
        if FInfo[I].Access = Db_access_none then
        begin
          SetPrivate(FInfo[I].ID);
          EventInfo.Access := Db_access_private;
          DBKernel.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Private], EventInfo);
        end;
      end
      else
      begin
        if FInfo[I].Access = DB_Access_Private then
        begin
          UnSetPrivate(FInfo[I].ID);
          EventInfo.Access := Db_access_none;
          DBKernel.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Private], EventInfo);
        end;
      end;
    end;
  TPrivatehelper.Instance.Reset;
  R(ProgressForm);
  FBusy := False;
end;

procedure TDBPopupMenu.PropertyItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  Items: TArInteger;
  WindowsProp: Boolean;
  SelectCount: Integer;
  FFiles: TStrings;
begin
  SetLength(Items, 0);
  FFiles := TStringList.Create;
  try

    SelectCount := 0;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        Inc(SelectCount);
    WindowsProp := (SelectCount > 1) and (FInfo[FInfo.Position].ID = 0);
    for I := 0 to FInfo.Count - 1 do
      if ((FInfo[I].ID <> 0) or WindowsProp) and FInfo[I].Selected then
      begin
        SetLength(Items, Length(Items) + 1);
        Items[Length(Items) - 1] := FInfo[I].ID;
        FFiles.Add(FInfo[I].FileName);
      end;
    if Length(Items) < 2 then
    begin
      if FInfo[FInfo.Position].ID <> 0 then
        PropertyManager.NewIDProperty(FInfo[FInfo.Position].ID).Execute(FInfo[FInfo.Position].ID);
      if FInfo[FInfo.Position].ID = 0 then
        if FInfo[FInfo.Position].FileName <> '' then
          PropertyManager.NewFileProperty(FInfo[FInfo.Position].FileName).ExecuteFileNoEx(FInfo[FInfo.Position].FileName);
    end else
    begin
      if FInfo[FInfo.Position].ID = 0 then
        GetPropertiesWindows(FFiles, FormManager)
      else
        PropertyManager.NewSimpleProperty.ExecuteEx(Items);
    end;
  finally
    F(FFiles);
  end;
end;

procedure TDBPopupMenu.QuickGroupInfoPopUpMenu_(Sender: TObject);
var
  S: string;
  I: Integer;
begin
  S := (Sender as TMenuItem).Caption;
  for I := Length(S) downto 1 do
    if S[I] = '&' then
      Delete(S, I, 1);
  ShowGroupInfo(S, False, nil);
end;

procedure TDBPopupMenu.RefreshIDItemPopUpMenu_(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
begin
  Options.Info := FInfo;
  TRefreshDBRecordsThread.Create(FOwner, Options);
end;

procedure TDBPopupMenu.RefreshThumItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
begin
  EventInfo.Image := nil;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
      DBKernel.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Image], EventInfo);
end;

procedure TDBPopupMenu.RenameItemPopUpMenu_(Sender: TObject);
begin
  if FInfo.ListItem is TEasyItem then
  begin
    TEasyListview(TEasyItem(FInfo.ListItem).OwnerListview).EditManager.Enabled := True;
    TEasyItem(FInfo.ListItem).Edit;
  end;
end;

procedure TDBPopupMenu.ScanImageItemPopUpMenu_(Sender: TObject);
var
  NewSearch: TSearchForm;
begin
  NewSearch := SearchManager.NewSearch;
  NewSearch.SearchEdit.Text := ':ScanImageW(' + Finfo[Finfo.Position].FileName + ':1):';
  NewSearch.SetPath(ExtractFilePath(Finfo[Finfo.Position].FileName));
  NewSearch.DoSearchNow(nil);
  NewSearch.Show;
  NewSearch.SetFocus;
end;

procedure TDBPopupMenu.ScriptExecuted(Sender: TObject);
var
  C: Integer;
begin
  LoadItemVariables(AScript, Sender as TMenuItemW);
  if Trim((Sender as TMenuItemW).Script) <> '' then
    ExecuteScript(Sender as TMenuItemW, AScript, '', C, nil);
end;

procedure TDBPopupMenu.SearchFolderPopUpMenu_(Sender: TObject);
var
  NewSearch: TSearchForm;
begin
  NewSearch := SearchManager.NewSearch;
  // TODO:!!!
  NewSearch.SearchEdit.Text := ':Folder(' + Inttostr(Finfo[Finfo.Position].ID) + '):';
  NewSearch.SetPath(ExtractFilePath(Finfo[Finfo.Position].FileName));
  NewSearch.DoSearchNow(nil);
  NewSearch.Show;
  NewSearch.SetFocus;
end;

procedure TDBPopupMenu.SendToItemPopUpMenu_(Sender: TObject);
var
  NumberOfPanel: Integer;
  InfoNames: TArStrings;
  InfoIDs: TArInteger;
  Infoloaded: TArBoolean;
  I: Integer;
  Panel: TFormCont;
begin
  NumberOfPanel := (Sender as TMenuItem).Tag;
  Setlength(InfoNames, 0);
  Setlength(InfoIDs, 0);
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
    begin
      if FInfo[I].ID = 0 then
      begin
        Setlength(InfoNames, Length(InfoNames) + 1);
        Setlength(Infoloaded, Length(Infoloaded) + 1);
        InfoNames[Length(InfoNames) - 1] := FInfo[I].FileName;
        Infoloaded[Length(Infoloaded) - 1] := FInfo[I].InfoLoaded;
      end else
      begin
        Setlength(InfoIDs, Length(InfoIDs) + 1);
        InfoIDs[Length(InfoIDs) - 1] := FInfo[I].ID;
      end;
    end;
  if NumberOfPanel >= 0 then
  begin
    LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, True, ManagerPanels[NumberOfPanel]);
    LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, False, ManagerPanels[NumberOfPanel]);
  end;
  if NumberOfPanel < 0 then
  begin
    Panel := ManagerPanels.NewPanel;
    Panel.Show;
    LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, True, Panel);
    LoadFilesToPanel.Create(InfoNames, InfoIDs, Infoloaded, True, False, Panel);
  end;
end;

procedure TDBPopupMenu.SetInfo(Form: TDBForm; Info: TDBPopupMenuInfo);
begin
  if Info.Count = 0 then
    Exit;
  FOwner := Form;
  Finfo.Assign(Info);
end;

procedure TDBPopupMenu.SetRatingItemPopUpMenu_(Sender: TObject);
var
  I, NewRating: Integer;
  EventInfo: TEventValues;
  SQL_, Str: string;
  FQuery: TDataSet;
  FirstID: Boolean;
begin
  Str := (Sender as Tmenuitem).Caption;
  System.Delete(Str, 1, 1);
  NewRating := StrToInt(Str);
  FQuery := GetQuery;
  try
    SQL_ := 'Update $DB$ Set Rating=' + Inttostr(NewRating) + ' Where ID in (';

    FirstID := True;
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
      begin
        if FirstID then
          SQL_ := SQL_ + ' ' + Inttostr(Finfo[I].ID) + ' '
        else
          SQL_ := SQL_ + ' , ' + Inttostr(Finfo[I].ID) + ' ';
        FirstID := False;
      end;
    SQL_ := SQL_ + ')';
    FQuery.Active := False;
    SetSQL(FQuery, SQL_);
    try
      ExecSQL(FQuery);
    except
    end;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
      begin
        EventInfo.Rating := NewRating;
        DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Rating], EventInfo);
      end;
  finally
    FreeDS(FQuery);
  end;
end;

procedure TDBPopupMenu.SetRotateItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
  NewRotate: Integer;
begin
  NewRotate := (Sender as Tmenuitem).Tag;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
    begin
      SetRotate(Finfo[I].ID, NewRotate);
      EventInfo.Rotate := NewRotate;
      DBKernel.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Rotate], EventInfo);
    end;
end;

procedure TDBPopupMenu.ShellExecutePopUpMenu_(Sender: TObject);
var
  I: Integer;
  AllOperations: Integer;
  S: string;
begin
  AllOperations := 0;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
      Inc(AllOperations);
  if AllOperations > 10 then
    if ID_OK <> MessageBoxDB(GetActiveFormHandle,
      Format(TA('Running %s objects can slow down computer work! Continue?', DBMenuID), [Inttostr(AllOperations)]),
      TA('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
      Exit;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
    begin
      S := ExtractFileDir(Finfo[I].FileName);
      if ShellExecute(GetActiveWindow, 'open', PWideChar(ProcessPath(Finfo[I].FileName)), nil, PWideChar(S), SW_NORMAL)
        < 32 then
        EventLog(':TDBPopupMenu::ShellExecutePopUpMenu()/ShellExecute return < 32, path = ' + Finfo[I].FileName);
    end;
end;

procedure TDBPopupMenu.ShowDublicatesItemPopUpMenu_(Sender: TObject);
begin
  with SearchManager.NewSearch do
  begin
    SearchEdit.Text := ':Similar(' + IntToStr(FInfo[Finfo.Position].ID) + '):';
    DoSearchNow(nil);
    Show;
    SetFocus;
  end;
end;

procedure TDBPopupMenu.ShowItemPopUpMenu_(Sender: TObject);
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  Viewer.Execute(Sender, FInfo);
  Viewer.Show;
end;

procedure TDBPopupMenu.UserMenuItemPopUpMenu_(Sender: TObject);
var
  I: Integer;
  Params, ExeFile, ExeParams: string;
begin
  for I := 0 to Finfo.Count - 1 do
    if FInfo[I].Selected then
      Params := ' "' + Finfo[I].FileName + '" ';

  ExeFile := FUserMenu[(Sender as TMenuItem).Tag].EXEFile;
  ExeParams := StringReplace(FUserMenu[(Sender as TMenuItem).Tag].Params, '%1', Params, [RfReplaceAll, RfIgnoreCase]);
  if ShellExecute(0, nil, PWideChar(ExeFile), PWideChar(ExeParams), nil, SW_SHOWNORMAL) < 32 then
    EventLog(':TDBPopupMenu::UserMenuItemPopUpMenu()/ShellExecute return < 32, path = ' + ExeFile + ' params = ' +
        ExeParams);
end;

procedure TDBPopupMenu.WallpaperCenterItemPopUpMenu_(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(GetActiveFormHandle, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_STRETCH);
end;

procedure TDBPopupMenu.WallpaperStretchItemPopUpMenu_(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(GetActiveFormHandle, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_CENTER);
end;

procedure TDBPopupMenu.WallpaperTileItemPopUpMenu_(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(GetActiveFormHandle, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_TILE)
end;

initialization

finalization

  F(DBPopupMenu);

end.
