unit DBCMenu;

interface

uses
  Generics.Defaults,
  Generics.Collections,
  Winapi.ShlObj,
  System.Math,
  System.Types,
  Winapi.ShellApi,
  Winapi.CommCtrl,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.ActnPopup,
  Vcl.Graphics,
  Vcl.Imaging.Jpeg,
  Vcl.Menus,
  Data.DB,

  UnitGroupsWork,
  CommonDBSupport,
  ProgressActionUnit,
  PrintMainForm,
  ShellContextMenu,
  UnitSQLOptimizing,
  UnitRefreshDBRecordsThread,
  EasyListview,
  UnitINI,
  UnitDBDeclare,
  UnitDBFileDialogs,
  CmpUnit,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.PathProviders,

  uRuntime,
  uMemoryEx,
  uTime,
  uIconUtils,
  uLogger,
  uCDMappingTypes,
  uGroupTypes,
  uMemory,
  uBitmapUtils,
  uGraphicUtils,
  uDBPopupMenuInfo,
  uAssociations,
  uConstants,
  uPrivateHelper,
  uDBIcons,
  uTranslate,
  uPathProviderUtils,
  uShellIntegration,
  uDBBaseTypes,
  uDBForm,
  uDBUtils,
  uDBAdapter,
  uPortableDeviceUtils,
  uShellNamespaceUtils,
  uVCLHelpers,
  uPhotoShelf,
  uLinkListEditorForExecutables,
  uFormInterfaces,
  uCollectionEvents;

type
  TDBPopupMenu = class
  private
    FPopupMenu: TPopupActionBar;
    FInfo: TDBPopupMenuInfo;
    FPopUpPoint: TPoint;
    FUserMenu: TList<TExecutableInfo>;
    FBusy: Boolean;
    FOwner: TDBForm;
    FActionFiles: TArray<string>;
    function CreateMenuItemEx(Item: TMenuItem; Text: string; ImageIndex: Integer = -1; Tag: Integer = 0; Default: Boolean = False): TMenuItem;
    procedure ApplyActions(FileName: string);
  public
    class function Instance: TDBPopupMenu;
    constructor Create;
    destructor Destroy; override;
    procedure MiFindFileManuallyClick(Sender: TObject);
    procedure MiSelectActionsClick(Sender: TObject);
    procedure MiApplyActionsClick(Sender: TObject);
    procedure MiShowKeyWordClick(Sender: TObject);
    procedure MiStenoClick(Sender: TObject);
    procedure MiDeStenoClick(Sender: TObject);
    procedure MiEditExecutableListClick(Sender: TObject);

    procedure ShowItemPopUpMenu(Sender: TObject);
    procedure ShellExecutePopUpMenu(Sender: TObject);
    procedure DeleteLItemPopUpMenu(Sender: TObject);
    procedure DeleteItemPopUpMenu(Sender: TObject);
    procedure RefreshThumItemPopUpMenu(Sender: TObject);
    procedure PropertyItemPopUpMenu(Sender: TObject);
    procedure SetRatingItemPopUpMenu(Sender: TObject);
    procedure SetRotateItemPopUpMenu(Sender: TObject);
    procedure PrivateItemPopUpMenu(Sender: TObject);
    procedure RenameItemPopUpMenu(Sender: TObject);
    procedure CopyItemPopUpMenu(Sender: TObject);
    procedure ShelfItemPopUpMenu(Sender: TObject);
    procedure ExplorerPopUpMenu(Sender: TObject);
    procedure GroupsPopUpMenu(Sender: TObject);
    procedure DateItemPopUpMenu(Sender: TObject);
    procedure CryptItemPopUpMenu(Sender: TObject);
    procedure DeCryptItemPopUpMenu(Sender: TObject);
    procedure QuickGroupInfoPopUpMenu(Sender: TObject);
    procedure EnterPasswordItemPopUpMenu(Sender: TObject);
    procedure ImageEditorItemPopUpMenu(Sender: TObject);
    procedure WallpaperStretchItemPopUpMenu(Sender: TObject);
    procedure WallpaperCenterItemPopUpMenu(Sender: TObject);
    procedure WallpaperTileItemPopUpMenu(Sender: TObject);
    procedure RefreshIDItemPopUpMenu(Sender: TObject);
    procedure ShowDuplicatesItemPopUpMenu(Sender: TObject);
    procedure DeleteDuplicatesItemPopUpMenu(Sender: TObject);
    procedure UserMenuItemPopUpMenu(Sender: TObject);
    procedure PrintItemPopUpMenu(Sender: TObject);
    procedure ConvertItemPopUpMenu_(Sender: TObject);
    procedure Execute(Owner: TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo);
    procedure ExecutePlus(Owner: TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo; Menus: TArMenuitem);
    procedure AddDBContMenu(Form: TDBForm; Item: TMenuItem; Info: TDBPopupMenuInfo);
    procedure AddUserMenu(Item: TMenuItem; Insert: Boolean; index: Integer);
    procedure SetInfo(Form: TDBForm; Info: TDBPopupMenuInfo);
    function GetGroupImageInImageList(GroupCode: string): Integer;
    function CheckDBReadOnly: Boolean;
  end;

implementation

uses
  uManagerExplorer,
  PropertyForm,
  UnitMenuDateForm,
  ImEditor,
  FormManegerUnit;

const
  DBMenuID = 'DBMenu';

var
  DBPopupMenu: TDBPopupMenu = nil;

{ TDBPopupMenu }

function L(TextToTranslate: string): string;
begin
  Result := TA(TextToTranslate, DBMenuID);
end;

function TDBPopupMenu.CreateMenuItemEx(Item: TMenuItem; Text: string; ImageIndex: Integer = -1; Tag: Integer = 0; Default: Boolean = False): TMenuItem;
begin
  Result := TMenuItem.Create(FPopupMenu);
  Result.Caption := L(Text);
  Result.ImageIndex := ImageIndex;
  Result.Tag := Tag;
  Result.Default := Default;
  Item.Add(Result);
end;

procedure TDBPopupMenu.ApplyActions(FileName: string);
var
  Editor: TImageEditor;
  Item: TDBPopupMenuInfoRecord;
  FD: DBSaveDialog;
  FinalFIleName: string;
begin
  JpegOptionsForm.Execute;

  Editor := EditorsManager.NewEditor;
  try
    Editor.CloseOnFailture := False;

    if FInfo.SelectionCount = 1 then
    begin
      Item := FInfo[FInfo.Position];

      FD := DBSaveDialog.Create;
      try
        FinalFileName := ChangeFileExt(Item.FileName, '.jpg');
        FD.SetFileName(FinalFileName);
        FD.Filter := TFileAssociations.Instance.GetGraphicClassExt(TJPEGImage);
        if FD.Execute then
        begin
          Editor.Show;

          if Editor.OpenFileName(Item.FileName) then
          begin
            Editor.ReadActionsFile(FileName);
            Editor.SaveImageFile(FD.FileName);
          end;
        end;

      finally
        F(FD);
      end;
    end else
    begin
(*
       $folder=GetOpenDirectory("Please select directory to place for processed files","");
        $de=DirectoryExists($folder);
        if ($de=true)
        {
          SAVE_VAR($sID,$folder);
          $FileDoneCounter=0;
          $FileName=GetStringItem($ar,$FileDoneCounter);
          $len=ArrayStringLength($ar);
          $fn=ExtractFileName($FileName);
          $NewFileName=$folder+"\"+$fn;
          $form=NewImageEditor;
          ShowDBForm($form);
          ImageEditorOpenFileName($form,$FileName);

          SAVE_VAR($sID,$FileDoneCounter);
          ImageEditorRegisterCallBack($form,$sID,"CallBackProc");
          ExecuteActions($form,$FILE,$NewFileName);
*)
    end;

  finally
    R(Editor);
  end;
end;

procedure TDBPopupMenu.AddDBContMenu(Form: TDBForm; Item: TMenuItem; Info: TDBPopupMenuInfo);
const
  RotateTitles: array[0..3] of string = ('No rotate', 'Rotate right', 'Rotate 180°', 'Rotate left');
  RatingIcons: array[0..5] of Integer = (DB_IC_RATING_STAR, DB_IC_RATING_1, DB_IC_RATING_2, DB_IC_RATING_3, DB_IC_RATING_4, DB_IC_RATING_5);

  function CreateMenuItem(Text: string; ImageIndex: Integer = 0): TMenuItem;
  begin
    Result := CreateMenuItemEx(Item, Text, ImageIndex);
  end;

var
  I: Integer;
  FE, Isrecord, IsFile, IsCurrentFile, IsStaticFile: Boolean;
  MenuGroups: TGroups;
  GroupsList: TStringList;
  StrGroups: string;
  KeyWords: TArray<string>;
  BusyMenu, ErrorMenu: TMenuItem;
  OnlyCurrentDBinfoSelected: Boolean;
  NoDBInfoNeeded: Boolean;
  MI: TMenuItem;
  DBItem: TDBPopupMenuInfoRecord;
begin
  if FBusy then
  begin
    for I := 0 to Item.Count - 1 do
      Item.Delete(0);
    BusyMenu := CreateMenuItem('Busy...');
    BusyMenu.Enabled := False;
    Item.Add(BusyMenu);
    Exit;
  end;
  if Info.Count = 0 then
  begin
    for I := 0 to Item.Count - 1 do
      Item.Delete(0);
    ErrorMenu := CreateMenuItem('Unable to show menu!');
    ErrorMenu.Enabled := False;
    Item.Add(ErrorMenu);
    Exit;
  end;

  FOwner := Form;

  Finfo.Assign(Info);
  IsRecord := True;
  if Finfo.Count = 1 then
    if Finfo[0].ID = 0 then
      IsRecord := False;
  for I := 0 to Item.Count - 1 do
    Item.Delete(0);

  if Finfo.Count > 1 then
  begin
    IsRecord := False;
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].ID <> 0 then
        IsRecord := True;
  end;
  NoDBInfoNeeded := False;

  DBItem := FInfo[FInfo.Position];

  OnlyCurrentDBinfoSelected := True;
  if FInfo.Count > 1 then
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].ID <> 0 then
        if FInfo[I].Selected then
          if FInfo.Position <> I then
            OnlyCurrentDBinfoSelected := False;
  if DBItem.Selected then
    if DBItem.ID = 0 then
      if not OnlyCurrentDBinfoSelected then
        NoDBInfoNeeded := True;
  if not Isrecord then
    NoDBInfoNeeded := True;
  if DBItem.ID = 0 then
    NoDBInfoNeeded := True;

  TW.I.Start('FileExists');
  FE := (DBItem.Exists = 1) or FileExistsSafe(DBItem.FileName);
  IsCurrentFile := FE;

  IsFile := IsCurrentFile;
  if not IsFile then
    for I := 0 to FInfo.Count - 1 do
      if FileExistsSafe(FInfo[I].FileName) then
      begin
        IsFile := True;
        Break;
      end;

  SetLength(MenuGroups, 0);
  IsStaticFile := StaticPath(DBItem.FileName);

  GroupsList := TStringList.Create;
  try
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        GroupsList.Add(FInfo[I].Groups);

    StrGroups := GetCommonGroups(GroupsList);
  finally
    F(GroupsList);
  end;

  MenuGroups := EnCodeGroups(StrGroups);

  TTranslateManager.Instance.BeginTranslate;
  try

    if IsStaticFile and not IsFile then
    begin
      MI := CreateMenuItem('Find file manually', DB_IC_SEARCH);
      MI.OnClick := MiFindFileManuallyClick;
    end;

    MI := CreateMenuItem('Slide Show', DB_IC_SLIDE_SHOW);
    MI.OnClick := ShowItemPopUpMenu;

    if FE then
    begin
      MI := CreateMenuItem('Apply actions', DB_IC_APPLY_ACTION);

      CreateMenuItemEx(MI, 'Select', DB_IC_APPLY_ACTION).OnClick := MiSelectActionsClick;
      CreateMenuItemEx(MI, '-');

      FActionFiles := GetDirListing(ExtractFilePath(Application.ExeName) + ActionsFolder, '|DBACT|');

      for I := 0 to Length(FActionFiles) - 1 do
        CreateMenuItemEx(MI, GetFileNameWithoutExt(FActionFiles[I]), DB_IC_APPLY_ACTION, I).OnClick := MiApplyActionsClick;
    end;

    if ShiftKeyDown and FE then
    begin
      MI := CreateMenuItem('Shell', DB_IC_SHELL);
      MI.OnClick := ShellExecutePopUpMenu;
    end;

    AddUserMenu(Item, False, -1);

    //links

    if not NoDBInfoNeeded then
    begin
      MI := CreateMenuItem('Refresh', DB_IC_REFRESH_THUM);
      MI.OnClick := RefreshThumItemPopUpMenu;
    end;

    if not NoDBInfoNeeded and IsRecord then
    begin
      MI := CreateMenuItem('Rotate', DB_IC_ROTATED_0);

      for I := 0 to 3 do
        CreateMenuItemEx(MI, RotateTitles[I], DB_IC_ROTATED_0 + I, I, I = DBItem.Rotation).OnClick := SetRotateItemPopUpMenu;

      MI := CreateMenuItem('Rating', DB_IC_RATING_STAR);

      for I := 0 to 5 do
        CreateMenuItemEx(MI, IntToStr(I), RatingIcons[I], I, I = DBItem.Rating).OnClick := SetRatingItemPopUpMenu;

      if DBItem.Access = Db_access_none then
      begin
        MI := CreateMenuItem('Private', DB_IC_PRIVATE);
        MI.Tag := 0;
        MI.OnClick := PrivateItemPopUpMenu;
      end;

      if DBItem.Access = Db_access_private then
      begin
        MI := CreateMenuItem('Public', DB_IC_COMMON);
        MI.Tag := 1;
        MI.OnClick := PrivateItemPopUpMenu;
      end;

      MI := CreateMenuItem('Date', DB_IC_EDIT_DATE);
      MI.OnClick := DateItemPopUpMenu;

      MI := CreateMenuItem('Groups', DB_IC_GROUPS);

      for I := 0 to Length(MenuGroups) - 1 do
        CreateMenuItemEx(MI, MenuGroups[I].GroupName, GetGroupImageInImageList(MenuGroups[I].GroupCode)).OnClick := QuickGroupInfoPopUpMenu;

      CreateMenuItemEx(MI, '-');
      CreateMenuItemEx(MI, 'Edit groups', DB_IC_GROUPS).OnClick := GroupsPopUpMenu;

    end;

    KeyWords := DBItem.KeyWords.Split([' '], TStringSplitOptions.ExcludeEmpty);
    if Length(KeyWords) > 0 then
    begin
      MI := CreateMenuItem('Keywords', DB_IC_NOTEPAD);
      for I := 0 to Length(KeyWords) - 1 do
        CreateMenuItemEx(MI, KeyWords[I], DB_IC_NOTEPAD).OnClick := MiShowKeyWordClick;
    end;

    if not IsDevicePath(DBItem.FileName) then
    begin
      MI := CreateMenuItem('Encrypting', DB_IC_KEY);

      if DBItem.Encrypted then
      begin
        CreateMenuItemEx(MI, 'Enter password', DB_IC_PASSWORD).OnClick := EnterPasswordItemPopUpMenu;
        CreateMenuItemEx(MI, 'Decrypt', DB_IC_DECRYPTIMAGE).OnClick := DeCryptItemPopUpMenu;
      end else
        CreateMenuItemEx(MI, 'Encrypt', DB_IC_CRYPTIMAGE).OnClick := CryptItemPopUpMenu;

      CreateMenuItemEx(MI, '-');

      CreateMenuItemEx(MI, 'Hide info in image', DB_IC_STENO).OnClick := MiStenoClick;
      if ExtinMask('|BMP|PNG|JPG|JPEG|', GetExt(DBItem.FileName)) then
        CreateMenuItemEx(MI, 'Extract info from image', DB_IC_STENO).OnClick := MiDeStenoClick;

    end;

    if not DBItem.Encrypted and IsWallpaper(DBItem.FileName) and IsCurrentFile then
    begin
      MI := CreateMenuItem('Set as desktop wallpaper', DB_IC_WALLPAPER);
      CreateMenuItemEx(MI, 'Stretch', DB_IC_WALLPAPER).OnClick := WallpaperStretchItemPopUpMenu;
      CreateMenuItemEx(MI, 'Center', DB_IC_WALLPAPER).OnClick := WallpaperCenterItemPopUpMenu;
      CreateMenuItemEx(MI, 'Tile', DB_IC_WALLPAPER).OnClick := WallpaperTileItemPopUpMenu;
    end;

    if IsCurrentFile then
      CreateMenuItem('Image editor', DB_IC_IMEDITOR).OnClick := ImageEditorItemPopUpMenu;

    if IsCurrentFile then
      CreateMenuItem('Convert image', DB_IC_RESIZE).OnClick := ConvertItemPopUpMenu_;

    if not NoDBInfoNeeded and IsCurrentFile and IsRecord then
      CreateMenuItem('Update info', DB_IC_REFRESH_ID).OnClick := RefreshIDItemPopUpMenu;

    if IsCurrentFile then
      CreateMenuItem('Print' , DB_IC_PRINTER).OnClick := PrintItemPopUpMenu;

    if DBItem.Attr = Db_attr_duplicate then
    begin
      CreateMenuItem('Show duplicates', DB_IC_DUPLICATE).OnClick := ShowDuplicatesItemPopUpMenu;
      CreateMenuItem('Delete duplicates', DB_IC_DEL_DUPLICAT).OnClick := DeleteDuplicatesItemPopUpMenu;
    end;

    if not NoDBInfoNeeded and IsRecord then
    begin
      MI := CreateMenuItem('Delete', DB_IC_DELETE_FILE);

      CreateMenuItemEx(MI, 'Delete info from collection', DB_IC_DELETE_FILE).OnClick := DeleteLItemPopUpMenu;

      if (IsFile and FE) then
        CreateMenuItemEx(MI, 'Delete file', DB_IC_DELETE_FILE).OnClick := DeleteItemPopUpMenu;
    end;

    if IsFile and FE then
      CreateMenuItem('Copy', DB_IC_COPY).OnClick := CopyItemPopUpMenu;

    if not IsDevicePath(DBItem.FileName) and Finfo.IsListItem and FE then
      CreateMenuItem('Rename', DB_IC_RENAME).OnClick := RenameItemPopUpMenu;

    CreateMenuItem('-');

    if FE then
      CreateMenuItem('Open in Explorer', DB_IC_EXPLORER).OnClick := ExplorerPopUpMenu;

    if not IsDevicePath(DBItem.FileName) and FE then
    begin
      if PhotoShelf.PathInShelf(DBItem.FileName) > -1 then
        CreateMenuItem('Unshelve', DB_IC_SHELF).OnClick := ShelfItemPopUpMenu
      else
        CreateMenuItem('Shelve', DB_IC_SHELF).OnClick := ShelfItemPopUpMenu;

    end;

    CreateMenuItem('Properties', DB_IC_PROPERTIES).OnClick := PropertyItemPopUpMenu;
  finally
    TTranslateManager.Instance.EndTranslate;
  end;
end;
   
procedure TDBPopupMenu.MiSelectActionsClick(Sender: TObject);
var
  FD: DBOpenDialog;
begin
  FD := DBOpenDialog.Create;
  try
    FD.SetFileName('Actions.dbact');
    FD.Filter := L('DB Action Files (*.dbact)|*.dbact');
    if FD.Execute then
      ApplyActions(FD.FileName);

  finally
    F(FD);
  end;
end;

procedure TDBPopupMenu.MiApplyActionsClick(Sender: TObject);
begin
  ApplyActions(FActionFiles[(Sender as TMenuItem).Tag]);
end;

procedure TDBPopupMenu.MiFindFileManuallyClick(Sender: TObject);
var
  FD: DBOpenPictureDialog;
  Info: TDBPopupMenuInfoRecord;
begin
  FD := DBOpenPictureDialog.Create;
  try
    FD.Filter := TFileAssociations.Instance.ExtensionList;
    if FD.Execute then
    begin
      Info := FInfo[FInfo.Position];
      SetFileNameByID(Info.ID, FD.FileName);
    end;
  finally
    F(FD);
  end;
end;

procedure TDBPopupMenu.MiShowKeyWordClick(Sender: TObject);
var
  S: string;
begin
  S := (Sender as TMenuItem).Caption.Replace('&', '');
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cDBSearchPath + ':KeyWord(' + S + '):');
    Show;
  end;
end;

procedure TDBPopupMenu.MiDeStenoClick(Sender: TObject);
begin
  SteganographyForm.ExtractData(FInfo[FInfo.Position].FileName);
end;

procedure TDBPopupMenu.MiStenoClick(Sender: TObject);
begin
  SteganographyForm.HideData(FInfo[FInfo.Position].FileName);
end;

procedure ReadUserTools(Data: TList<TExecutableInfo>);
var
  I,
  SortOrder: Integer;
  Reg: TBDRegistry;
  FileName,
  Params,
  Icon: string;
  UseSubMenu: Boolean;
  S: TStrings;
  EI: TExecutableInfo;
begin
  FreeList(Data, False);

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Menu', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + '\Menu\' + S[I], True);

        FileName := '';
        Params := '';
        Icon := '';
        UseSubMenu := False;
        SortOrder := 0;

        if Reg.ValueExists('FileName') then
          FileName := Reg.ReadString('FileName');

        if Reg.ValueExists('Params') then
          Params := Reg.ReadString('Params');

        if Reg.ValueExists('Icon') then
          Icon := Reg.ReadString('Icon');

        if Reg.ValueExists('UseSubMenu') then
          UseSubMenu := Reg.ReadBool('UseSubMenu');

        if Reg.ValueExists('SortOrder') then
          SortOrder := Reg.ReadInteger('SortOrder');

        if (S[I] <> '') and (FileName <> '') then
        begin
          EI := TExecutableInfo.Create(S[I], FileName, Icon, Params, UseSubMenu, SortOrder);
          Data.Add(EI);
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;

  Data.Sort(TComparer<TExecutableInfo>.Construct(
     function (const L, R: TExecutableInfo): Integer
     begin
       Result := L.SortOrder - R.SortOrder;
     end
  ));
end;

procedure WriteUserTools(Data: TList<TExecutableInfo>);
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Menu', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      Reg.CloseKey;
      for I := 0 to S.Count - 1 do
        Reg.DeleteKey(GetRegRootKey + '\Menu\' + S[I]);
    finally
      F(S);
    end;

    for I := 0 to Data.Count - 1 do
    begin
      Reg.OpenKey(GetRegRootKey + '\Menu\' + Data[I].Title, True);
      Reg.WriteString('FileName', Data[I].Path);
      Reg.WriteString('Params', Data[I].Parameters);
      Reg.WriteString('Icon', Data[I].Icon);
      Reg.WriteBool('UseSubMenu', Data[I].UseSubMenu);
      Reg.WriteInteger('SortOrder', Data[I].SortOrder);
      Reg.CloseKey;
    end;
  finally
    F(Reg);
  end;
end;

procedure TDBPopupMenu.MiEditExecutableListClick(Sender: TObject);
var
  Data: TList<TDataObject>;
  Editor: ILinkEditor;
begin
  Data := TList<TDataObject>.Create;
  try
    ReadUserTools(TList<TExecutableInfo>(Data));

    Editor := TLinkListEditorForExecutables.Create();
    try

      if LinkItemSelectForm.Execute(450, L('List of applications'), Data, Editor) then
      begin
        WriteUserTools(TList<TExecutableInfo>(Data));
        ReadUserTools(FUserMenu);
      end;
    finally
      Editor := nil;
    end;

  finally
    FreeList(Data);
  end;
end;

procedure TDBPopupMenu.AddUserMenu(Item: TMenuItem; Insert: Boolean; Index: Integer);
var
  EI: TExecutableInfo;
  MI: TMenuItem;

  function GetIconIndex(IconPath: string): Integer;
  var
    Icon: HIcon;
  begin
    Result := -1;

    Icon := ExtractSmallIconByPath(EI.Icon);
    try
      if Icon <> 0 then
      begin
        ImageList_ReplaceIcon(Icons.ImageList.Handle, -1, Icon);
        Result := Icons.ImageList.Count - 1;
      end;
    finally
      DestroyIcon(Icon);
    end;
  end;

  function CreateMenuItemEx(SubItem: TMenuItem; Text: string; ImageIndex: Integer = -1; Tag: Integer = 0; Default: Boolean = False): TMenuItem;
  begin
    Result := TMenuItem.Create(Item);
    Result.Caption := L(Text);
    Result.ImageIndex := ImageIndex;
    Result.Tag := Tag;
    Result.Default := Default;
    if not Insert then
      SubItem.Add(Result)
    else
    begin
      if SubItem = Item then
        SubItem.Insert(Index, Result)
      else
        SubItem.Add(Result);
    end;
  end;

begin
  ReadUserTools(FUserMenu);

  for EI in FUserMenu do
    if not EI.UseSubMenu then
      CreateMenuItemEx(Item, EI.Title, GetIconIndex(EI.Icon), FUserMenu.IndexOf(EI)).OnClick := UserMenuItemPopUpMenu;

   MI := CreateMenuItemEx(Item, 'Open with', 0);

  for EI in FUserMenu do
    if EI.UseSubMenu then
      CreateMenuItemEx(MI, EI.Title, GetIconIndex(EI.Icon), FUserMenu.IndexOf(EI)).OnClick := UserMenuItemPopUpMenu;

  CreateMenuItemEx(MI, '-');
  CreateMenuItemEx(MI, 'Edit', DB_IC_RENAME).OnClick := MiEditExecutableListClick;
end;

procedure TDBPopupMenu.CopyItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  FileList: TStrings;
  IsDeviceItems: Boolean;
  Handle: THandle;
begin
  FileList := TStringList.Create;
  try
    IsDeviceItems := False;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
      begin
        if not IsDevicePath(FInfo[I].FileName) then
        begin
          if FileExistsSafe(FInfo[I].FileName) then
            FileList.Add(FInfo[I].FileName);
        end else
        begin
          IsDeviceItems := True;
          FileList.Add(ExtractFileName(FInfo[I].FileName));
        end;
      end;

    if not IsDeviceItems then
      Copy_Move(Application.Handle, True, FileList)
    else
    begin
      Handle := 0;
      if FOwner <> nil then
        Handle := FOwner.Handle;
      ExecuteShellPathRelativeToMyComputerMenuAction(Handle, PhotoDBPathToDevicePath(ExtractFileDir(FInfo[FInfo.Position].FileName)), FileList, Point(0, 0), nil, AnsiString('Copy'));
    end;
  finally
    F(FileList);
  end;
end;

constructor TDBPopupMenu.create;
begin
  inherited;

  FBusy := False;
  Finfo := TDBPopupMenuInfo.Create;
  FUserMenu := TList<TExecutableInfo>.Create;

  FPopupMenu := TPopupActionBar.Create(nil);
end;

procedure TDBPopupMenu.CryptItemPopUpMenu(Sender: TObject);
begin
  EncryptForm.Encrypt(FOwner, TA('selected objects', DBMenuID), FInfo);
end;

procedure TDBPopupMenu.DateItemPopUpMenu(Sender: TObject);
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

  if Changed and not CheckDBReadOnly then
  begin
    FQuery := GetQuery;
    try
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
            CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Date, EventID_Param_IsDate], EventInfo);
      end else
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
            CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_IsDate], EventInfo);
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
            CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Time, EventID_Param_IsTime], EventInfo);
      end else
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
            CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_IsTime], EventInfo);
      end;
      // [END] Time Support
    finally
      FreeDS(FQuery);
    end;
  end;
end;

procedure TDBPopupMenu.DeCryptItemPopUpMenu(Sender: TObject);
begin
  EncryptForm.Decrypt(FOwner, FInfo);
end;

procedure TDBPopupMenu.DeleteDuplicatesItemPopUpMenu(Sender: TObject);
var
  I, J: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  Files, S: TArStrings;
  IDs: TArInteger;
  DA: TDBAdapter;
begin
  if CheckDBReadOnly then
    Exit;
  if ID_OK = MessageBoxDB(0, TA('Do you really want ot delete this info from DB?', DBMenuID),
    TA('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
        if Finfo[I].Attr = Db_attr_duplicate then
        begin
          FQuery := GetQuery;
          DA := TDBAdapter.Create(FQuery);
          try
            SQL_ := 'SELECT FFileName, ID FROM $DB$ WHERE (ID<>' + IntToStr(Finfo[I].ID) +
              ') AND (StrTh=(SELECT StrTh FROM $DB$ WHERE ID = ' + IntToStr(Finfo[I].ID) + '))';
            SetSQL(FQuery, SQL_);
            FQuery.Open;
            FQuery.First;
            SetLength(Files, FQuery.RecordCount);
            SetLength(IDs, FQuery.RecordCount);
            for J := 1 to FQuery.RecordCount do
            begin
              Files[J - 1] := DA.FileName;
              IDs[J - 1] := DA.ID;
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
            CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Attr], EventInfo);
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
              CollectionEvents.DoIDEvent(FOwner, IDs[J], [EventID_Param_Delete], EventInfo);
            end;
          finally
            F(DA);
            FreeDS(FQuery);
          end;
        end;
  end;
end;

procedure TDBPopupMenu.DeleteItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  S: TArStrings;
  FirstID: Boolean;
begin
  if CheckDBReadOnly then
    Exit;
  if ID_OK = MessageBoxDB(0, L('Do you really want to delete this info from collection?'), L('Confirm'),
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
        CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Delete], EventInfo);
      end;
    FreeDS(FQuery);
  end;
end;

procedure TDBPopupMenu.DeleteLItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  FQuery: TDataSet;
  EventInfo: TEventValues;
  SQL_: string;
  FirstID: Boolean;
begin
  if CheckDBReadOnly then
    Exit;

  if IdOk = MessageBoxDB(0, L('Do you really want to delete this info from collection?'),
    L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
  begin
    FQuery := GetQuery;
    try
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
          CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Delete], EventInfo);
    finally
      FreeDS(FQuery);
    end;
  end;
end;

destructor TDBPopupMenu.Destroy;
begin
  FreeList(FUserMenu);
  F(FPopupMenu);
  F(Finfo);
  inherited;
end;

procedure TDBPopupMenu.EnterPasswordItemPopUpMenu(Sender: TObject);
var
  EventInfo: TEventValues;
  Query: TDataSet;
  ID: Integer;
  DA: TDBAdapter;
begin
  if FileExistsSafe(FInfo[FInfo.Position].FileName) then
  begin
    if RequestPasswordForm.ForImage(FInfo[FInfo.Position].FileName) <> '' then
      CollectionEvents.DoIDEvent(FOwner, FInfo[FInfo.Position].ID, [EventID_Param_Image], EventInfo);
  end else
  begin
    Query := GetQuery;
    DA := TDBAdapter.Create(Query);
    try
      ID := GetIdByFileName(FInfo[FInfo.Position].FileName);
      if ID = 0 then
        Exit;
      SetSQL(Query, 'SELECT * from $DB$ where ID=' + IntToStr(ID));
      Query.Open;
      if RequestPasswordForm.ForBlob(DA.Thumb, FInfo[FInfo.Position].FileName) <> '' then
        CollectionEvents.DoIDEvent(FOwner, FInfo[FInfo.Position].ID, [EventID_Param_Image], EventInfo);
    finally
      F(DA);
      FreeDS(Query);
    end;
  end;
end;

procedure TDBPopupMenu.Execute(Owner: TDBForm; X, Y: Integer; Info: TDBPopupMenuInfo);
begin
  FOwner := Owner;
  FPopUpPoint := Point(X, Y);
  if not FBusy then
  begin
    FInfo.Assign(Info);
    if FInfo.Count = 0 then
      Exit;
    begin
      FPopupMenu.Images := Icons.ImageList;
      FPopupMenu.Items.Clear;
      AddDBContMenu(FOwner, FPopupMenu.Items, Finfo);
      FPopupMenu.DoPopupEx(X, Y);
    end;
  end else
  begin
    FPopupMenu.Items.Clear;
    AddDBContMenu(FOwner, FPopupMenu.Items, Finfo);
    FPopupMenu.DoPopupEx(X, Y);
  end;
end;

procedure TDBPopupMenu.ExecutePlus(Owner : TDBForm; X, Y: integer; Info: TDBPopupMenuInfo;
  Menus: TArMenuitem);
var
  I: Integer;
  _menuItem_nil: TMenuItem;
begin
  FOwner := Owner;
  FPopUpPoint := Point(X, Y);
  FInfo.Assign(Info);
  if Finfo.Count = 0 then
    Exit;
  begin

    FPopupMenu.Images := Icons.ImageList;
    FPopupMenu.Items.Clear;
    AddDBContMenu(FOwner, FPopupMenu.Items, Finfo);
    if Length(Menus) > 0 then
    begin
      _menuItem_nil := Tmenuitem.Create(FPopupMenu);
      _menuItem_nil.Caption := '-';
      FPopupMenu.Items.Add(_menuItem_nil);
      for I := 0 to Length(Menus) - 1 do
      begin
        FPopupMenu.Items.Add(Menus[I]);
      end;
    end;
    FPopupMenu.DoPopupEx(X, Y);

  end;
end;

procedure TDBPopupMenu.ExplorerPopUpMenu(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    NavigateToFile(FInfo[FInfo.Position].FileName);
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
          SmallB.PixelFormat := pf24bit;
          B.Canvas.Brush.Color := clMenu;
          B.Canvas.Pen.Color := clMenu;
          Size := Max(FGroup.GroupImage.Width, FGroup.GroupImage.Height);
          B.Width := Size;
          B.Height := Size;
          B.Canvas.Rectangle(0, 0, Size, Size);
          B.Canvas.Draw(B.Width div 2 - FGroup.GroupImage.Width div 2, B.Height div 2 - FGroup.GroupImage.Height div 2, FGroup.GroupImage);
          DoResize(16, 16, B, SmallB);

          ImageList_Add(Icons.ImageList.Handle, SmallB.Handle, 0);
        finally
          F(SmallB);
        end;
      finally
        F(B);
      end;
      Result := Icons.ImageList.Count - 1;
    end else
      Result := DB_IC_GROUPS;
  end else
    Result := DB_IC_GROUPS;
  FreeGroup(FGroup);
end;

procedure TDBPopupMenu.GroupsPopUpMenu(Sender: TObject);
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
    try
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
    finally
      F(GroupList);
      F(KeyWordList);
    end;
    NewKeyWords := OldKeyWords;
    GroupsSelectForm.Execute(StrNewGroups, NewKeyWords);
    VarKeyWords := VariousKeyWords(OldKeyWords, NewKeyWords);
    VarGroups := not CompareGroups(StrOldGroups, StrNewGroups);
    if not VarKeyWords and not VarGroups then
      Exit;
    if CheckDBReadOnly then
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
          CollectionEvents.DoIDEvent(FOwner, List[I].IDs[J], [EventID_Param_KeyWords], EventInfo);
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
            CollectionEvents.DoIDEvent(FOwner,List[i].IDs[j],[EventID_Param_Groups],EventInfo);
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

procedure TDBPopupMenu.ImageEditorItemPopUpMenu(Sender: TObject);
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
    DBPopupMenu := TDBPopupMenu.Create;

  Result := DBPopupMenu
end;

procedure TDBPopupMenu.PrintItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    for I := 0 to Finfo.Count - 1 do
      if Finfo[I].Selected then
        if FileExistsSafe(Finfo[I].FileName) or IsDevicePath(Finfo[I].FileName) then
          Files.Add(Finfo[I].FileName);

    if Files.Count <> 0 then
      GetPrintForm(Files);
  finally
    F(Files);
  end;
end;

procedure TDBPopupMenu.PrivateItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
  OldAccess: Integer;
  Count: Integer;
  ProgressForm: TProgressActionForm;
begin
  if CheckDBReadOnly then
    Exit;
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
          CollectionEvents.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Private], EventInfo);
        end;
      end else
      begin
        if FInfo[I].Access = DB_Access_Private then
        begin
          UnSetPrivate(FInfo[I].ID);
          EventInfo.Access := Db_access_none;
          CollectionEvents.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Private], EventInfo);
        end;
      end;
    end;
  TPrivatehelper.Instance.Reset;
  R(ProgressForm);
  FBusy := False;
end;

procedure TDBPopupMenu.PropertyItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  Items: TArInteger;
  WindowsProp: Boolean;
  SelectCount: Integer;
  FFiles: TStrings;
  CI: TDBPopupMenuInfoRecord;

  procedure ShowPathProperties;
  var
    I: Integer;
    P, PI: TPathItem;
    PL: TPathItemCollection;
  begin
    P := PathProviderManager.CreatePathItem(CI.FileName);
    try
      if P <> nil then
      begin
        if P.Provider.SupportsFeature(PATH_FEATURE_PROPERTIES) then
        begin
          PL := TPathItemCollection.Create;
          try
            for I := 0 to FInfo.Count - 1 do
              if FInfo[I].Selected then
              begin
                PI := PathProviderManager.CreatePathItem(FInfo[I].FileName);
                if PI <> nil then
                  PL.Add(PI);
              end;

            P.Provider.ExecuteFeature(Self, PL, PATH_FEATURE_PROPERTIES, nil);
          finally
            PL.FreeItems;
            F(PL);
          end;

          Exit;
        end;
      end;
    finally
      F(P);
    end;
  end;

begin
  SetLength(Items, 0);
  FFiles := TStringList.Create;
  try

    SelectCount := 0;
    for I := 0 to FInfo.Count - 1 do
      if FInfo[I].Selected then
        Inc(SelectCount);

    CI := FInfo[FInfo.Position];

    WindowsProp := (SelectCount > 1) and (CI.ID = 0);
    for I := 0 to FInfo.Count - 1 do
      if ((FInfo[I].ID <> 0) or WindowsProp) and FInfo[I].Selected then
      begin
        SetLength(Items, Length(Items) + 1);
        Items[Length(Items) - 1] := FInfo[I].ID;
        FFiles.Add(FInfo[I].FileName);
      end;
    if Length(Items) < 2 then
    begin
      if CI.ID <> 0 then
        PropertyManager.NewIDProperty(CI.ID).Execute(CI.ID);
      if CI.ID = 0 then
      begin
        if not IsDevicePath(CI.FileName) then
        begin
          if CI.FileName <> '' then
            PropertyManager.NewFileProperty(CI.FileName).ExecuteFileNoEx(CI.FileName);
        end else
        begin
          ExecuteProviderFeature(FOwner, CI.FileName, PATH_FEATURE_PROPERTIES);
        end;
      end;
    end else
    begin
      if CI.ID = 0 then
      begin
        if not IsDevicePath(CI.FileName) then
          GetPropertiesWindows(FFiles, FormManager)
        else
          ShowPathProperties;

      end else
        PropertyManager.NewSimpleProperty.ExecuteEx(Items);
    end;
  finally
    F(FFiles);
  end;
end;

procedure TDBPopupMenu.QuickGroupInfoPopUpMenu(Sender: TObject);
var
  S: string;
begin
  S := (Sender as TMenuItem).Caption.Replace('&', '');

  GroupInfoForm.Execute(nil, S, False);
end;

procedure TDBPopupMenu.RefreshIDItemPopUpMenu(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
begin
  if CheckDBReadOnly then
    Exit;
  Options.Info := FInfo;
  TRefreshDBRecordsThread.Create(FOwner, Options);
end;

procedure TDBPopupMenu.RefreshThumItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
begin
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
      CollectionEvents.DoIDEvent(FOwner, FInfo[I].ID, [EventID_Param_Image], EventInfo);
end;

procedure TDBPopupMenu.RenameItemPopUpMenu(Sender: TObject);
begin
  if FInfo.ListItem is TEasyItem then
  begin
    TEasyListview(TEasyItem(FInfo.ListItem).OwnerListview).EditManager.Enabled := True;
    TEasyItem(FInfo.ListItem).Edit;
  end;
end;

procedure TDBPopupMenu.ShelfItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  IsInShelf: Boolean;
  EventInfo: TEventValues;
begin
  EventInfo.ID := 0;
  IsInShelf := PhotoShelf.PathInShelf(Finfo[Finfo.Position].FileName) > -1;

  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
    begin
      EventInfo.FileName := FInfo[I].FileName;

      if IsInShelf then
      begin
        PhotoShelf.RemoveFromShelf(FInfo[I].FileName);
        CollectionEvents.DoIDEvent(FOwner, 0, [EventID_ShelfItemRemoved], EventInfo);
      end else
      begin
        PhotoShelf.AddToShelf(FInfo[I].FileName);
        CollectionEvents.DoIDEvent(FOwner, 0, [EventID_ShelfItemAdded], EventInfo);
      end;
    end;

  EventInfo.FileName := '';
  CollectionEvents.DoIDEvent(FOwner, 0, [EventID_ShelfChanged], EventInfo);
end;

procedure TDBPopupMenu.SetInfo(Form: TDBForm; Info: TDBPopupMenuInfo);
begin
  if Info.Count = 0 then
    Exit;
  FOwner := Form;
  Finfo.Assign(Info);
end;

procedure TDBPopupMenu.SetRatingItemPopUpMenu(Sender: TObject);
var
  I, NewRating: Integer;
  EventInfo: TEventValues;
  SQL_, Str: string;
  FQuery: TDataSet;
  FirstID: Boolean;
begin
  if CheckDBReadOnly then
    Exit;
  Str := (Sender as TMenuItem).Caption.Replace('&', '');
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
        CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Rating], EventInfo);
      end;
  finally
    FreeDS(FQuery);
  end;
end;

procedure TDBPopupMenu.SetRotateItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  EventInfo: TEventValues;
  NewRotate: Integer;
begin
  if CheckDBReadOnly then
    Exit;
  NewRotate := (Sender as Tmenuitem).Tag;
  for I := 0 to FInfo.Count - 1 do
    if FInfo[I].Selected then
    begin
      SetRotate(Finfo[I].ID, NewRotate);
      EventInfo.Rotation := NewRotate;
      CollectionEvents.DoIDEvent(FOwner, Finfo[I].ID, [EventID_Param_Rotate], EventInfo);
    end;
end;

procedure TDBPopupMenu.ShellExecutePopUpMenu(Sender: TObject);
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
    if ID_OK <> MessageBoxDB(0, Format(TA('Running %s objects can slow down computer work! Continue?', DBMenuID), [Inttostr(AllOperations)]),
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

procedure TDBPopupMenu.ShowDuplicatesItemPopUpMenu(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(cDBSearchPath + ':Similar(' + IntToStr(FInfo[Finfo.Position].ID) + '):');
    Show;
  end;
end;

procedure TDBPopupMenu.ShowItemPopUpMenu(Sender: TObject);
begin
  Viewer.ShowImages(Sender, FInfo);
  Viewer.Show;
  Viewer.Restore;
end;

function TDBPopupMenu.CheckDBReadOnly: Boolean;
begin
  Result := DBReadOnly;
  if Result then
    MessageBoxDB(0, TA('Collection is read only!', DBMenuID), TA('Warning'), TD_BUTTON_OK, TD_ICON_WARNING);
end;

procedure TDBPopupMenu.ConvertItemPopUpMenu_(Sender: TObject);
begin
  BatchProcessingForm.ResizeImages(FOwner, FInfo);
end;

procedure TDBPopupMenu.UserMenuItemPopUpMenu(Sender: TObject);
var
  I: Integer;
  Params, ExeFile, ExeParams: string;

begin
  for I := 0 to Finfo.Count - 1 do
    if FInfo[I].Selected then
      Params := ' "' + Finfo[I].FileName + '" ';

  ExeFile := FUserMenu[(Sender as TMenuItem).Tag].Path;
  ExeParams := StringReplace(FUserMenu[(Sender as TMenuItem).Tag].Parameters, '%1', Params, [RfReplaceAll, RfIgnoreCase]);
  if ShellExecute(0, nil, PWideChar(ExeFile), PWideChar(ExeParams), nil, SW_SHOWNORMAL) < 32 then
    EventLog(':TDBPopupMenu::UserMenuItemPopUpMenu()/ShellExecute return < 32, path = ' + ExeFile + ' params = ' + ExeParams);
end;

procedure TDBPopupMenu.WallpaperCenterItemPopUpMenu(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(0, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_STRETCH);
end;

procedure TDBPopupMenu.WallpaperStretchItemPopUpMenu(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(0, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_CENTER);
end;

procedure TDBPopupMenu.WallpaperTileItemPopUpMenu(Sender: TObject);
var
  FileName: string;
begin
  FileName := ProcessPath(Finfo[Finfo.Position].FileName);
  if not FileExistsSafe(FileName) then
  begin
    MessageBoxDB(0, TA('Can''t find the file!', DBMenuID), TA('Warning'), TD_BUTTON_OKCANCEL,TD_ICON_WARNING);
    Exit;
  end;
  SetDesktopWallpaper(ProcessPath(FileName), WPSTYLE_TILE);
end;

initialization

finalization

  F(DBPopupMenu);

end.
