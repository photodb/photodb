unit Options;

interface

uses
  Registry, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TabNotBk, DmProgress, ExtCtrls, CheckLst,
  Menus, ShellCtrls, Dolphin_DB, ImgList, Math, Mask, uFileUtils, uSysUtils,
  acDlgSelect, UnitDBKernel, SaveWindowPos, UnitINI, uVistaFuncs, UnitDBDeclare,
  UnitDBFileDialogs, uAssociatedIcons, uLogger, uConstants, uShellIntegration,
  UnitDBCommon, UnitDBCommonGraphics, uTranslate, uShellUtils, uDBForm,
  uRuntime, uMemory, uSettings, WebLink, uAssociations, AppEvnts, Spin,
  uCryptUtils, uIconUtils, LoadingSign, uDBThread, uConfiguration;

type
  TOptionsForm = class(TPasswordSettingsDBForm)
    CancelButton: TButton;
    OkButton: TButton;
    PmExtensionStatus: TPopupMenu;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    PmUserMenu: TPopupMenu;
    Addnewcommand1: TMenuItem;
    Remove1: TMenuItem;
    ImageList1: TImageList;
    PmPlaces: TPopupMenu;
    Additem1: TMenuItem;
    DeleteItem1: TMenuItem;
    N1: TMenuItem;
    Up1: TMenuItem;
    Down1: TMenuItem;
    PlacesImageList: TImageList;
    Rename1: TMenuItem;
    N2: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    N3: TMenuItem;
    Default1: TMenuItem;
    PcMain: TPageControl;
    TsGeneral: TTabSheet;
    TsExplorer: TTabSheet;
    BtnClearIconCache: TButton;
    BtnClearThumbnailCache: TButton;
    BtnChooseNewPlace: TButton;
    BtnChoosePlaceIcon: TButton;
    PlacesListView: TListView;
    CblPlacesDisplayIn: TCheckListBox;
    LbDisplayPlacesIn: TLabel;
    LbPlacesList: TLabel;
    CbExplorerShowPlaces: TCheckBox;
    CbExplorerShowEXIF: TCheckBox;
    CbExplorerShowThumbsForImages: TCheckBox;
    CbExplorerSaveThumbsForFolders: TCheckBox;
    CbExplorerShowThumbsForFolders: TCheckBox;
    CbExplorerShowAttributes: TCheckBox;
    Label13: TStaticText;
    Label12: TStaticText;
    CbExplorerShowFolders: TCheckBox;
    CbExplorerShowSimpleFiles: TCheckBox;
    CbExplorerShowImages: TCheckBox;
    CbExplorerShowHidden: TCheckBox;
    Bevel1: TBevel;
    TsView: TTabSheet;
    TrackBar1: TTrackBar;
    Label15: TLabel;
    Label22: TLabel;
    TrackBar2: TTrackBar;
    TrackBar4: TTrackBar;
    Label26: TLabel;
    CbViewerNextOnClick: TCheckBox;
    CbViewerUseCoolStretch: TCheckBox;
    TsUserMenu: TTabSheet;
    GbUserMenuUseFor: TGroupBox;
    CbUseUserMenuForIDMenu: TCheckBox;
    CbUseUserMenuForExplorer: TCheckBox;
    CbUseUserMenuForViewer: TCheckBox;
    BtnSaveUserMenuItem: TButton;
    BtnAddNewUserMenuItem: TButton;
    BtnUserMenuItemDown: TButton;
    BtnUserMenuItemUp: TButton;
    LvUserMenuItems: TListView;
    BtnSelectUserMenuItemIcon: TButton;
    EdSubmenuIcon: TEdit;
    Label23: TLabel;
    EdSubmenuCaption: TEdit;
    Label21: TLabel;
    Label24: TLabel;
    Image2: TImage;
    CbUserMenuItemIsSubmenu: TCheckBox;
    EdUserMenuItemIcon: TEdit;
    BtnUserMenuChooseIcon: TButton;
    Label19: TLabel;
    EdUserMenuItemParams: TEdit;
    Label25: TLabel;
    EdUserMenuItemExecutable: TEdit;
    BtnUserMenuChooseExecutable: TButton;
    Label18: TLabel;
    EdUserMenuItemCaption: TEdit;
    Label20: TLabel;
    TsSecurity: TTabSheet;
    GbBackup: TGroupBox;
    Label30: TLabel;
    BlBackupInterval: TLabel;
    GbPasswords: TGroupBox;
    LbSecureInfo: TLabel;
    ImSecureInfo: TImage;
    BtnClearPasswordsInSettings: TButton;
    BtnClearSessionPasswords: TButton;
    CbAutoSavePasswordInSettings: TCheckBox;
    CbAutoSavePasswordForSession: TCheckBox;
    TsGlobal: TTabSheet;
    LbAddHeight: TLabel;
    LbAddWidth: TLabel;
    CbDontAddSmallFiles: TCheckBox;
    EdExplorerStartupLocation: TEdit;
    BtnSelectExplorerStartupFolder: TButton;
    CbExplorerStartupLocation: TCheckBox;
    CbStartUpExplorer: TCheckBox;
    CbCheckLinksOnUpdate: TCheckBox;
    CbSmallToolBars: TCheckBox;
    CblEditorVirtuaCursor: TCheckBox;
    CbSortGroups: TCheckBox;
    CbListViewHotSelect: TCheckBox;
    LbShellExtensions: TStaticText;
    CbExtensionList: TCheckListBox;
    BtnInstallExtensions: TButton;
    CbListViewShowPreview: TCheckBox;
    LblSkipExt: TLabel;
    LblAddSubmenuItem: TLabel;
    LblUseExt: TLabel;
    CbInstallTypeChecked: TCheckBox;
    CbInstallTypeGrayed: TCheckBox;
    CbInstallTypeNone: TCheckBox;
    Bevel2: TBevel;
    WlDefaultJPEGOptions: TWebLink;
    AeMain: TApplicationEvents;
    SedBackupDays: TSpinEdit;
    WblMethod: TWebLink;
    LbDefaultPasswordMethod: TLabel;
    PmCryptMethod: TPopupMenu;
    SedMinHeight: TSpinEdit;
    SedMinWidth: TSpinEdit;
    Bevel3: TBevel;
    GroupBox1: TGroupBox;
    CbReadInfoFromExif: TCheckBox;
    CbSaveInfoToExif: TCheckBox;
    CbUpdateExifInfoInBackground: TCheckBox;
    N4: TMenuItem;
    SelectAll1: TMenuItem;
    DeselectAll1: TMenuItem;
    CbExplorerShowThumbsForVideo: TCheckBox;
    cbViewerFaceDetection: TCheckBox;
    lbDetectionSize: TLabel;
    CbDetectionSize: TComboBox;
    BtnClearFaceDetectionCache: TButton;
    LsFaceDetectionClearCache: TLoadingSign;
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CbExtensionListContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Usethisprogramasdefault1Click(Sender: TObject);
    procedure Usemenuitem1Click(Sender: TObject);
    procedure Dontusethisextension1Click(Sender: TObject);
    procedure BtnInstallExtensionsClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure LoadDefaultExtStates;
    procedure BtnClearSessionPasswordsClick(Sender: TObject);
    procedure BtnClearPasswordsInSettingsClick(Sender: TObject);
    procedure BtnUserMenuChooseIconClick(Sender: TObject);
    procedure BtnUserMenuChooseExecutableClick(Sender: TObject);
    procedure LvUserMenuItemsContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Addnewcommand1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure LvUserMenuItemsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure BtnSaveUserMenuItemClick(Sender: TObject);
    procedure EdUserMenuItemCaptionKeyPress(Sender: TObject; var Key: Char);
    procedure BtnSelectUserMenuItemIconClick(Sender: TObject);
    procedure BtnUserMenuItemUpClick(Sender: TObject);
    procedure BtnUserMenuItemDownClick(Sender: TObject);
    procedure BtnClearIconCacheClick(Sender: TObject);
    procedure BtnClearThumbnailCacheClick(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BtnChooseNewPlaceClick(Sender: TObject);
    procedure ReadPlaces;
    procedure WritePlaces;
    procedure PlacesListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure CblPlacesDisplayInClickCheck(Sender: TObject);
    procedure BtnChoosePlaceIconClick(Sender: TObject);
    procedure DeleteItem1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure PlacesListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure Default1Click(Sender: TObject);
    procedure CbStartUpExplorerClick(Sender: TObject);
    procedure BtnSelectExplorerStartupFolderClick(Sender: TObject);
    procedure CbExplorerStartupLocationClick(Sender: TObject);
    procedure CbDontAddSmallFilesClick(Sender: TObject);
    procedure PcMainChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure WlDefaultJPEGOptionsClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeselectAll1Click(Sender: TObject);
    procedure BtnClearFaceDetectionCacheClick(Sender: TObject);
  private
    FThemeList : TStringList;
    FUserMenu : TUserMenuItemArray;
    FLoadedPages : array[0..5] of boolean;
    FPlaces : TPlaceFolderArray;
    ReloadData : boolean;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadLanguage;
    function GetPasswordSettingsPopupMenu: TPopupMenu; override;
    function GetPaswordLink: TWebLink; override;
  end;

  TFaceDetectionClearCacheThread = class(TDBThread)
  private
    FOwner: TOptionsForm;
    procedure HideLoadingSign;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TOptionsForm);
  end;

var
  OptionsForm: TOptionsForm;

implementation

uses
  SlideShow, ExplorerThreadUnit, uManagerExplorer, UnitJPEGOptions;

{$R *.dfm}

procedure TOptionsForm.TabbedNotebook1Change(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
var
  I, Size: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  FCaption, EXEFile, Params, Icon: string;
  UseSubMenu: Boolean;
begin
  if FLoadedPages[NewTab] then
    Exit;
  FLoadedPages[NewTab] := True;

  if NewTab = 0 then
  begin
    CbListViewShowPreview.Checked := Settings.Readbool('Options', 'AllowPreview', True);
    CbExtensionList.Enabled := not FolderView;
    BtnInstallExtensions.Enabled := not FolderView;
    CbExtensionList.Items.Clear;
    for I := 0 to TFileAssociations.Instance.Count - 1 do
      CbExtensionList.Items.AddObject(Format('%s   (%s)', [TFileAssociations.Instance[I].Extension, TFileAssociations.Instance[I].Description]), TFileAssociations.Instance[I]);

    LoadDefaultExtStates;
  end;
  if NewTab = 1 then
  begin
    CbExplorerShowFolders.Checked := Settings.Readbool('Options', 'Explorer_ShowFolders', True);
    CbExplorerShowSimpleFiles.Checked := Settings.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
    CbExplorerShowImages.Checked := Settings.Readbool('Options', 'Explorer_ShowImageFiles', True);
    CbExplorerShowHidden.Checked := Settings.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
    CbExplorerShowAttributes.Checked := Settings.Readbool('Options', 'Explorer_ShowAttributes', True);
    CbExplorerShowThumbsForFolders.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
    CbExplorerSaveThumbsForFolders.Checked := Settings.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
    CbExplorerShowThumbsForImages.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
    CbExplorerShowThumbsForVideo.Checked := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForVideo', True);
    CbExplorerShowEXIF.Checked := Settings.ReadBool('Options', 'ShowEXIFMarker', False);
    CbExplorerShowPlaces.Checked := Settings.ReadBool('Options', 'ShowOtherPlaces', True);

    ReadPlaces;
  end;
  if NewTab = 2 then
  begin
    CbViewerNextOnClick.Checked := Settings.Readbool('Options', 'NextOnClick', False);
    TrackBar1.Position := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideSteps', 25), 1), 100);
    TrackBar2.Position := Min(Max(Settings.ReadInteger('Options', 'SlideShow_SlideDelay', 40), 1), 100);
    TrackBar4.Position := Min(Max(Settings.ReadInteger('Options', 'FullScreen_SlideDelay', 40), 1), 100);
    CbViewerUseCoolStretch.Checked := Settings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True);
    TrackBar1Change(Sender);
    TrackBar2Change(Sender);
    TrackBar4Change(Sender);

    CbViewerFaceDetection.Checked := Settings.Readbool('Options', 'ViewerFaceDetection', True);

    CbDetectionSize.ItemIndex := 0;
    Size := Settings.ReadInteger('Options', 'FaceDetectionSize', 3);
    for I := 0 to CbDetectionSize.Items.Count - 1 do
      if Integer(CbDetectionSize.Items.Objects[I]) = Size then
        CbDetectionSize.ItemIndex := I;

  end;
  if NewTab = 4 then
  begin
    CbAutoSavePasswordForSession.Checked := Settings.Readbool('Options', 'AutoSaveSessionPasswords', True);
    CbAutoSavePasswordInSettings.Checked := Settings.Readbool('Options', 'AutoSaveINIPasswords', False);
    SedBackupDays.Value := Settings.ReadInteger('Options', 'BackUpdays', 7);
  end;

  if NewTab = 5 then
  begin

    CbSmallToolBars.Checked := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
    CbSortGroups.Checked := Settings.Readbool('Options', 'SortGroupsByName', True);
    CbListViewHotSelect.Checked := Settings.Readbool('Options', 'UseHotSelect', True);
    CblEditorVirtuaCursor.Checked := Settings.ReadBool('Editor', 'VirtualCursor', False);
    CbCheckLinksOnUpdate.Checked := Settings.ReadBool('Options', 'CheckUpdateLinks', False);

    CbStartUpExplorer.Checked := Settings.ReadBool('Options', 'RunExplorerAtStartUp', True);
    CbExplorerStartupLocation.Checked := Settings.ReadBool('Options', 'UseSpecialStartUpFolder', False);
    EdExplorerStartupLocation.Text := Settings.ReadString('Options', 'SpecialStartUpFolder');

    if not DirectoryExists(EdExplorerStartupLocation.Text) then
      EdExplorerStartupLocation.Text := uShellUtils.GetMyPicturesPath;

    CbExplorerStartupLocation.Enabled := CbStartUpExplorer.Checked;
    EdExplorerStartupLocation.Enabled := CbExplorerStartupLocation.Checked and CbExplorerStartupLocation.Enabled;

    CbDontAddSmallFiles.Checked := Settings.ReadBool('Options', 'DontAddSmallImages', True);
    SedMinWidth.Value := Settings.ReadInteger('Options', 'DontAddSmallImagesWidth', 64);
    SedMinHeight.Value := Settings.ReadInteger('Options', 'DontAddSmallImagesHeight', 64);
    SedMinWidth.Enabled := CbDontAddSmallFiles.Checked;
    SedMinHeight.Enabled := CbDontAddSmallFiles.Checked;

    CbReadInfoFromExif.Checked := Settings.Exif.ReadInfoFromExif;
    CbSaveInfoToExif.Checked := Settings.Exif.SaveInfoToExif;
    CbUpdateExifInfoInBackground.Checked := Settings.Exif.UpdateExifInfoInBackground;
  end;

  if NewTab = 3 then
  begin
    ImageList1.Clear;
    ImageList1.Width := 16;
    ImageList1.Height := 16;
    ImageList1.BkColor := clMenu;
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(GetRegRootKey + '\Menu', True);
      S := TStringList.Create;
      try
        Reg.GetKeyNames(S);
        SetLength(FUserMenu, 0);
        LvUserMenuItems.Clear;
        for I := 0 to S.Count - 1 do
        begin
          Reg.CloseKey;
          Reg.OpenKey(GetRegRootKey + '\Menu\' + S[I], False);
          UseSubMenu := True;

          if Reg.ValueExists('Caption') then
            FCaption := Reg.ReadString('Caption');
          if Reg.ValueExists('EXEFile') then
            EXEFile := Reg.ReadString('EXEFile');
          if Reg.ValueExists('Params') then
            Params := Reg.ReadString('Params');
          if Reg.ValueExists('Icon') then
            Icon := Reg.ReadString('Icon');
          if Reg.ValueExists('UseSubMenu') then
            UseSubMenu := Reg.ReadBool('UseSubMenu');

          if (FCaption <> '') and (EXEFile <> '') then
          begin
            SetLength(FUserMenu, Length(FUserMenu) + 1);
            FUserMenu[Length(FUserMenu) - 1].Caption := FCaption;
            FUserMenu[Length(FUserMenu) - 1].EXEFile := EXEFile;
            FUserMenu[Length(FUserMenu) - 1].Params := Params;
            FUserMenu[Length(FUserMenu) - 1].Icon := Icon;
            FUserMenu[Length(FUserMenu) - 1].UseSubMenu := UseSubMenu;

            AddIconToListFromPath(ImageList1, Icon);

            with LvUserMenuItems.Items.Add do
            begin
              ImageIndex := ImageList1.Count - 1;
              Caption := FCaption;
            end;
          end;
        end;
      finally
        F(S);
      end;
    finally
      F(Reg);
    end;
    CbUseUserMenuForIDMenu.Checked := Settings.ReadBool('Options', 'UseUserMenuForIDmenu', True);
    CbUseUserMenuForViewer.Checked := Settings.ReadBool('Options', 'UseUserMenuForViewer', True);
    CbUseUserMenuForExplorer.Checked := Settings.ReadBool('Options', 'UseUserMenuForExplorer', True);
    EdSubmenuCaption.Text := Settings.ReadString('', 'UserMenuName');
    if EdSubmenuCaption.Text = '' then
      EdSubmenuCaption.Text := L('Additional');
    EdSubmenuIcon.Text := Settings.ReadString('', 'UserMenuIcon');
    if EdSubmenuIcon.Text = '' then
      EdSubmenuIcon.Text := '%SystemRoot%\system32\shell32.dll,126';

    SetIconToPictureFromPath(Image2.Picture, EdSubmenuIcon.Text);
    LvUserMenuItemsSelectItem(Self, nil, False);
  end;

end;

procedure TOptionsForm.FormShow(Sender: TObject);
var
  B: Boolean;
begin
  TabbedNotebook1Change(Sender, 0, B);
end;

function TOptionsForm.GetFormID: string;
begin
  Result := 'Options';
end;

function TOptionsForm.GetPaswordLink: TWebLink;
begin
  Result := WblMethod;
end;

function TOptionsForm.GetPasswordSettingsPopupMenu: TPopupMenu;
begin
  Result := PmCryptMethod;
end;

procedure TOptionsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  I: Integer;
  FPassIcon : HIcon;
begin
  ReloadData := False;
  SaveWindowPos1.Key := GetRegRootKey + 'Options';
  SaveWindowPos1.SetPosition;
  for I := 0 to 5 do
    FLoadedPages[I] := False;
  LoadLanguage;
  FThemeList := nil;
  PmPlaces.Images := DBKernel.ImageList;
  PmUserMenu.Images := DBKernel.ImageList;
  Up1.ImageIndex := DB_IC_UP;
  Down1.ImageIndex := DB_IC_DOWN;
  DeleteItem1.ImageIndex := DB_IC_DELETE_INFO;
  Additem1.ImageIndex := DB_IC_EXPLORER;
  Rename1.ImageIndex := DB_IC_RENAME;
  Addnewcommand1.ImageIndex := DB_IC_EXPLORER;
  Remove1.ImageIndex := DB_IC_DELETE_INFO;
  CbCheckLinksOnUpdate.Enabled := not FolderView;
  ClientHeight := 484;
  PcMainChange(Self);
  WlDefaultJPEGOptions.Color := clWindow;
  WblMethod.Color := clWindow;

  FPassIcon := LoadIcon(HInstance, PChar('PASSWORD'));
  WblMethod.LoadFromHIcon(FPassIcon);
  DestroyIcon(FPassIcon);
end;

procedure TOptionsForm.FormDestroy(Sender: TObject);
begin
  OptionsForm := nil;
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  EventInfo: TEventValues;
begin
  if ReloadData then
  begin
    if MessageBoxDB(Handle, L('Refresh data in windows?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
      DBKernel.DoIDEvent(Self, 0, [EventID_Param_Refresh_Window], EventInfo);

  end;
  // Case TabbedNotebook1.PageIndex of
  // 0:
  if FLoadedPages[0] then
  begin
   //nothing to save
  end;
  // 1:
  if FLoadedPages[1] then
  begin
    Settings.WriteBool('Options', 'Explorer_ShowFolders', CbExplorerShowFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowSimpleFiles', CbExplorerShowSimpleFiles.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowImageFiles', CbExplorerShowImages.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowHiddenFiles', CbExplorerShowHidden.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowAttributes', CbExplorerShowAttributes.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForFolders', CbExplorerShowThumbsForFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_SaveThumbnailsForFolders', CbExplorerSaveThumbsForFolders.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForImages', CbExplorerShowThumbsForImages.Checked);
    Settings.WriteBool('Options', 'Explorer_ShowThumbnailsForVideo', CbExplorerShowThumbsForVideo.Checked);

    Settings.WriteBool('Options', 'ShowEXIFMarker', CbExplorerShowEXIF.Checked);
    Settings.WriteBool('Options', 'ShowOtherPlaces', CbExplorerShowPlaces.Checked);

    ExplorerManager.ShowEXIF := CbExplorerShowEXIF.Checked;
    ExplorerManager.ShowQuickLinks := CbExplorerShowPlaces.Checked;
    WritePlaces;
  end;
  // 3 :
  if FLoadedPages[3] then
  begin
    Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
    try
      Reg.OpenKey(GetRegRootKey + '\Menu', True);
      S := TStringList.Create;
      try
        Reg.GetKeyNames(S);
        Reg.CloseKey;
        for I := 0 to S.Count - 1 do
          Reg.DeleteKey(GetRegRootKey + '\Menu\.' + IntToStr(I));
      finally
        F(S);
      end;
      for I := 0 to Length(FUserMenu) - 1 do
      begin
        Reg.OpenKey(GetRegRootKey + '\Menu\.' + IntToStr(I), True);
        Reg.WriteString('Caption', FUserMenu[I].Caption);
        Reg.WriteString('EXEFile', FUserMenu[I].EXEFile);
        Reg.WriteString('Params', FUserMenu[I].Params);
        Reg.WriteString('Icon', FUserMenu[I].Icon);
        Reg.WriteBool('UseSubMenu', FUserMenu[I].UseSubMenu);
        Reg.CloseKey;
      end;
    finally
      F(Reg);
    end;
    Settings.WriteString('', 'UserMenuName', EdSubmenuCaption.Text);
    Settings.WriteString('', 'UserMenuIcon', EdSubmenuIcon.Text);
    Settings.WriteBool('Options', 'UseUserMenuForIDmenu', CbUseUserMenuForIDMenu.Checked);
    Settings.WriteBool('Options', 'UseUserMenuForViewer', CbUseUserMenuForViewer.Checked);
    Settings.WriteBool('Options', 'UseUserMenuForExplorer', CbUseUserMenuForExplorer.Checked);
  end;
  // 4 :
  if FLoadedPages[4] then
  begin
    Settings.WriteBool('Options', 'AutoSaveSessionPasswords', CbAutoSavePasswordForSession.Checked);
    Settings.WriteBool('Options', 'AutoSaveINIPasswords', CbAutoSavePasswordInSettings.Checked);
    Settings.WriteInteger('Options', 'BackUpdays', SedBackupDays.Value);
  end;
  // 5 :
  if FLoadedPages[5] then
  begin
    Settings.WriteBool('Options', 'AllowPreview', CbListViewShowPreview.Checked);
    Settings.WriteBool('Options', 'UseSmallToolBarButtons', CbSmallToolBars.Checked);

    Settings.WriteBool('Options', 'SortGroupsByName', CbSortGroups.Checked);
    Settings.WriteBool('Options', 'UseHotSelect', CbListViewHotSelect.Checked);
    Settings.WriteBool('Editor', 'VirtualCursor', CblEditorVirtuaCursor.Checked);
    Settings.WriteBool('Options', 'CheckUpdateLinks', CbCheckLinksOnUpdate.Checked);

    Settings.WriteBool('Options', 'RunExplorerAtStartUp', CbStartUpExplorer.Checked);
    Settings.WriteBool('Options', 'UseSpecialStartUpFolder', CbExplorerStartupLocation.Checked);
    Settings.WriteString('Options', 'SpecialStartUpFolder', EdExplorerStartupLocation.Text);

    Settings.WriteBool('Options', 'DontAddSmallImages', CbDontAddSmallFiles.Checked);
    Settings.WriteInteger('Options', 'DontAddSmallImagesWidth', SedMinWidth.Value);
    Settings.WriteInteger('Options', 'DontAddSmallImagesHeight', SedMinHeight.Value);

    Settings.Exif.ReadInfoFromExif := CbReadInfoFromExif.Checked;
    Settings.Exif.SaveInfoToExif := CbSaveInfoToExif.Checked;
    Settings.Exif.UpdateExifInfoInBackground := CbUpdateExifInfoInBackground.Checked;
  end;
  // 2 :
  if FLoadedPages[2] then
  begin
    Settings.WriteBool('Options', 'NextOnClick', CbViewerNextOnClick.Checked);
    Settings.WriteBoolW('Options', 'SlideShow_UseCoolStretch', CbViewerUseCoolStretch.Checked);
    Settings.WriteInteger('Options', 'SlideShow_SlideSteps', TrackBar1.Position);
    Settings.WriteInteger('Options', 'SlideShow_SlideDelay', TrackBar2.Position);
    Settings.WriteInteger('Options', 'FullScreen_SlideDelay', TrackBar4.Position);

    Settings.WriteBool('Options', 'ViewerFaceDetection', CbViewerFaceDetection.Checked);
    Settings.WriteInteger('Options', 'FaceDetectionSize', Integer(CbDetectionSize.Items.Objects[CbDetectionSize.ItemIndex]));
  end;

  Settings.ClearCache;
  Close;
end;

procedure TOptionsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsForm.CbExtensionListContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Item: Integer;
begin
  Item := CbExtensionList.ItemAtPos(MousePos, True);
  if Item <> -1 then
  begin
    CbExtensionList.Selected[Item] := True;
    PmExtensionStatus.Tag := Item;
    Usethisprogramasdefault1.Checked := False;
    Usemenuitem1.Checked := False;
    Dontusethisextension1.Checked := False;
    case CbExtensionList.State[Item] of
      CbUnchecked:
        Dontusethisextension1.Checked := True;
      CbChecked:
        Usethisprogramasdefault1.Checked := True;
      CbGrayed:
        Usemenuitem1.Checked := True;
    end;
  end;
  PmExtensionStatus.PopUp(CbExtensionList.CLientToScreen(MousePos).X, CbExtensionList.CLientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Usethisprogramasdefault1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbChecked;
end;

procedure TOptionsForm.Usemenuitem1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbGrayed;
end;

procedure TOptionsForm.Dontusethisextension1Click(Sender: TObject);
begin
  CbExtensionList.State[PmExtensionStatus.Tag] := CbUnchecked;
end;

procedure TOptionsForm.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  if (Msg.message = WM_LBUTTONDOWN)
  or (Msg.message = WM_LBUTTONDBLCLK)
  or (Msg.message = WM_MOUSEMOVE) then
  begin
    if (Msg.hwnd = CbInstallTypeChecked.Handle)
      or (Msg.hwnd = CbInstallTypeGrayed.Handle)
      or (Msg.hwnd = CbInstallTypeNone.Handle) then
        Msg.message := 0;
  end;
end;

procedure TOptionsForm.BtnInstallExtensionsClick(Sender: TObject);
var
  I: Integer;
//  ShellExecuteInfo: TShellExecuteInfo;
begin
{  ShellExecuteInfo.cbSize:= SizeOf(TShellExecuteInfo);
  ShellExecuteInfo.fMask:= 0;
  ShellExecuteInfo.Wnd:= 0;
  ShellExecuteInfo.lpVerb:= 'runas';
  ShellExecuteInfo.lpFile:= PAnsiChar(Application.ExeName);
  ShellExecuteInfo.lpParameters:= nil;
  ShellExecuteInfo.lpDirectory:= nil;
  ShellExecuteInfo.nShow:= SW_SHOWNORMAL;
  if ShellExecuteEx(@ShellExecuteInfo) then
                                                  }
  for I := 0 to CbExtensionList.Items.Count - 1 do
    TFileAssociations.Instance.Exts[TFileAssociation(CbExtensionList.Items.Objects[I]).Extension].State := CheckboxStateToAssociationState(CbExtensionList.State[I]);

  InstallGraphicFileAssociations(Application.ExeName, nil);
  RefreshSystemIconCache;
  LoadDefaultExtStates;
end;

procedure TOptionsForm.LoadLanguage;
const
  DetectSizes: array[1..5] of Integer = (3, 6, 9, 13, 20);
var
  I: Integer;
  S: string;
begin
  BeginTranslate;
  try
    Caption := L('Options');
    TsGeneral.Caption := L('General');
    TsExplorer.Caption := L('Explorer'); ;
    TsView.Caption := L('Viewer'); ;
    TsUserMenu.Caption := L('User menu');
    TsSecurity.Caption := L('Security');
    TsGlobal.Caption := L('Global');
    GbBackup.Caption := L('Backups');
    Dontusethisextension1.Caption := L('Don''t use this extension');
    Usethisprogramasdefault1.Caption := L('Use PhotoDB as default association');
    Usemenuitem1.Caption := L('Add menu item');
    CbListViewShowPreview.Caption := L('Show previews');
    Label12.Caption := L('Show object types') + ':';
    CbExplorerShowFolders.Caption := L('Folders');
    CbExplorerShowSimpleFiles.Caption := L('Simple files');
    CbExplorerShowImages.Caption := L('Images');
    CbExplorerShowHidden.Caption := L('Hidden files');
    Label13.Caption := L('Preview options') + ':';
    CbExplorerShowAttributes.Caption := L('Display attributes');
    CbExplorerShowThumbsForFolders.Caption := L('Display previews for folders');
    CbExplorerSaveThumbsForFolders.Caption := L('Save preview for folders');
    CbExplorerShowThumbsForImages.Caption := L('Display previews for images');
    CbExplorerShowThumbsForVideo.Caption := L('Display previews for video');
    BtnInstallExtensions.Caption := L('Set');
    OkButton.Caption := L('Ok');
    CancelButton.Caption := L('Cancel');
    CbViewerUseCoolStretch.Caption := L('Use high-quality rendering');
    LbShellExtensions.Caption := L('Extensions') + ':';
    TrackBar4Change(Self);
    TrackBar2Change(Self);
    TrackBar1Change(Self);
    LbSecureInfo.Caption := L('WARNING: Use encryption carefully. If you have forgotten the password to any images, they can not be restored!');
    CbAutoSavePasswordForSession.Caption := L('Automatically save passwords for the current session');
    CbAutoSavePasswordInSettings.Caption := L('Automatically save passwords in the settings (NOT RECOMMENDED)');
    BtnClearSessionPasswords.Caption := L('Clear current passwords in session');
    BtnClearPasswordsInSettings.Caption := L('Clear the current password in settings');
    LbDefaultPasswordMethod.Caption := L('Default encryption method') + ':';

    LvUserMenuItems.Columns[0].Caption := L('Menu item');
    Label20.Caption := L('Caption');
    Label18.Caption := L('Executable file');
    Label25.Caption := L('Parameters');
    Label19.Caption := L('Icon');
    CbUserMenuItemIsSubmenu.Caption := L('Add to submenu');
    BtnAddNewUserMenuItem.Caption := L('Add');
    BtnSaveUserMenuItem.Caption := L('Save');
    Label24.Caption := L('Preview') + ':';
    Label21.Caption := L('Submenu caption');
    Label23.Caption := L('Submenu icon');
    Addnewcommand1.Caption := L('Add new item');
    Remove1.Caption := L('Remove');
    BtnUserMenuItemUp.Caption := L('Up');
    BtnUserMenuItemDown.Caption := L('Down');
    GbUserMenuUseFor.Caption := L('Display menu for') + ':';
    CbUseUserMenuForIDMenu.Caption := L('ID Menu');
    CbUseUserMenuForViewer.Caption := L('Viewer window');
    CbUseUserMenuForExplorer.Caption := L('Explorer window');
    BtnClearThumbnailCache.Caption := L('Clear previews cache');
    BtnClearIconCache.Caption := L('Clear icons cache');
    CbExplorerShowEXIF.Caption := L('Show EXIF marker');
    CbExplorerShowPlaces.Caption := L('Display links "Other places"');
    CbViewerNextOnClick.Caption := L('"Next" by click');
    CbListViewHotSelect.Caption := L('Use the selection by hover on the list');
    WlDefaultJPEGOptions.Text := L('Change default JPEG Options');
    CbSortGroups.Caption := L('Sort groups');
    BlBackupInterval.Caption := L('Create backup every') + ':';
    Label30.Caption := L('days');
    CblPlacesDisplayIn.Clear;
    CblPlacesDisplayIn.Items.Add(L('My computer'));
    CblPlacesDisplayIn.Items.Add(L('My documents'));
    CblPlacesDisplayIn.Items.Add(L('My pictures'));
    CblPlacesDisplayIn.Items.Add(L('Other places'));
    BtnChooseNewPlace.Caption := L('New place');
    LbDisplayPlacesIn.Caption := L('Display in') + ':';
    LbPlacesList.Caption := L('User defined places') + ':';
    PlacesListView.Columns[0].Caption := L('Places') + ':';

    Additem1.Caption := L('New place');
    DeleteItem1.Caption := L('Delete');
    Up1.Caption := L('Up');
    Down1.Caption := L('Down');
    BtnChoosePlaceIcon.Caption := L('Icon');
    Rename1.Caption := L('Rename');
    CblEditorVirtuaCursor.Caption := L('Virtual cursor to the Editor');
    Default1.Caption := L('Default');
    CbCheckLinksOnUpdate.Caption := L('Check changes of files and update links (may slow down program)');
    CbStartUpExplorer.Caption := L('Start Explorer at startup');
    CbExplorerStartupLocation.Caption := L('Use folder');
    CbDontAddSmallFiles.Caption := L('Do not add files to collection if size less than') + ':';
    LbAddWidth.Caption := L('Width');
    LbAddHeight.Caption := L('Height');
    GbPasswords.Caption := L('Passwords');
    CbSmallToolBars.Caption := L('Use small icons for toolbars');

    LblUseExt.Caption := L('Use PhotoDB as default association', 'Setup');
    LblAddSubmenuItem.Caption := L('Add menu item', 'Setup');
    LblSkipExt.Caption := L('Don''t use this extension', 'Setup');

    SelectAll1.Caption := L('Select all', 'Setup');
    DeselectAll1.Caption := L('Select none', 'Setup');

    CbReadInfoFromExif.Caption := L('Read image info from EXIF');
    CbSaveInfoToExif.Caption := L('Save info to EXIF');
    CbUpdateExifInfoInBackground.Caption := L('Update EXIF info in background');

    cbViewerFaceDetection.Caption := L('Enable face detection');
    lbDetectionSize.Caption := L('Detection size') + ':';

    for I := 1 to 5 do
    begin
      S := FloatToStrEx(DetectSizes[I] / 10, 2) + L('Mpx') + IIF(I = 1, ' (' + L('Best perfomance') + ')', '');
      CbDetectionSize.Items.AddObject(S, TObject(I));
    end;
    BtnClearFaceDetectionCache.Caption := L('Clear cache');
  finally
    EndTranslate;
  end;
end;

procedure TOptionsForm.TrackBar1Change(Sender: TObject);
begin
  Label15.Caption := Format(L('Number of steps for slide show: %d'), [TrackBar1.Position]);
end;

procedure TOptionsForm.TrackBar2Change(Sender: TObject);
begin
  Label22.Caption := Format(L('Slide show delay: %d ms.'), [TrackBar2.Position * 50]);
end;

procedure TOptionsForm.TrackBar4Change(Sender: TObject);
begin
  Label26.Caption := Format(L('Speed of displaying images for fullscreen: %d ms.'), [TrackBar4.Position * 100]);
end;

procedure TOptionsForm.LoadDefaultExtStates;
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(TFileAssociation(CbExtensionList.Items.Objects[I]).Extension), True);
end;

procedure TOptionsForm.BtnClearSessionPasswordsClick(Sender: TObject);
begin
  DBKernel.ClearTemporaryPasswordsInSession;
end;

procedure TOptionsForm.BtnClearPasswordsInSettingsClick(Sender: TObject);
begin
  DBKernel.ClearINIPasswords;
end;

procedure TOptionsForm.BtnUserMenuChooseIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;

  S, Icon: string;
  I: Integer;
begin
  S := EdUserMenuItemIcon.Text;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    EdUserMenuItemIcon.Text := FileName + ',' + IntToStr(IconIndex);
end;

procedure TOptionsForm.BtnUserMenuChooseExecutableClick(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('Programs (*.exe)|*.exe|All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
      EdUserMenuItemExecutable.Text := OpenDialog.FileName;

  finally
    F(OpenDialog);
  end;
end;

procedure TOptionsForm.LvUserMenuItemsContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := LvUserMenuItems.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
  begin
    Addnewcommand1.Visible := True;
    Remove1.Visible := False;
    PmUserMenu.Tag := -1;
  end else
  begin
    Addnewcommand1.Visible := False;
    Remove1.Visible := True;
    PmUserMenu.Tag := Item.index;
  end;
  PmUserMenu.Popup(LvUserMenuItems.ClientToScreen(MousePos).X, LvUserMenuItems.ClientToScreen(MousePos).Y);
end;

procedure TOptionsForm.Addnewcommand1Click(Sender: TObject);
var
  OpenDialog : DBOpenDialog;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,0';
begin

  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('Programs (*.exe)|*.exe|All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
    begin
      SetLength(FUserMenu, Length(FUserMenu) + 1);
      FUserMenu[Length(FUserMenu) - 1].Caption := GetFileNameWithoutExt(OpenDialog.FileName);
      FUserMenu[Length(FUserMenu) - 1].EXEFile := OpenDialog.FileName;
      FUserMenu[Length(FUserMenu) - 1].Params := '%1';
      if AnsiLowerCase(ExtractFileExt(OpenDialog.FileName)) = '.exe' then
        FUserMenu[Length(FUserMenu) - 1].Icon := OpenDialog.FileName + ',0'
      else
        FUserMenu[Length(FUserMenu) - 1].Icon := DefaultIcon;
      FUserMenu[Length(FUserMenu) - 1].UseSubMenu := True;

      AddIconToListFromPath(ImageList1, FUserMenu[Length(FUserMenu) - 1].Icon);

      with LvUserMenuItems.Items.Add do
      begin
        ImageIndex := ImageList1.Count - 1;
        Caption := GetFileNameWithoutExt(OpenDialog.FileName);
      end;
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TOptionsForm.Remove1Click(Sender: TObject);
var
  I: Integer;
begin
  if PmUserMenu.Tag <> -1 then
  begin
    for I := PmUserMenu.Tag to Length(FUserMenu) - 2 do
      FUserMenu[I] := FUserMenu[I + 1];
    SetLength(FUserMenu, Length(FUserMenu) - 1);
    LvUserMenuItems.Items.Delete(PmUserMenu.Tag);
    ImageList1.Delete(PmUserMenu.Tag);
    for I := PmUserMenu.Tag to Length(FUserMenu) - 1 do
      LvUserMenuItems.Items[I].ImageIndex := LvUserMenuItems.Items[I].ImageIndex - 1;
  end;
end;

procedure TOptionsForm.LvUserMenuItemsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (Item = nil) or (Selected = False) then
  begin
    BtnUserMenuItemUp.Enabled := False;
    BtnUserMenuItemDown.Enabled := False;
    EdUserMenuItemCaption.Enabled := False;
    EdUserMenuItemIcon.Enabled := False;
    EdUserMenuItemExecutable.Enabled := False;
    EdUserMenuItemParams.Enabled := False;
    BtnUserMenuChooseExecutable.Enabled := False;
    BtnUserMenuChooseIcon.Enabled := False;
    BtnSaveUserMenuItem.Enabled := False;
    CbUserMenuItemIsSubmenu.Checked := False;
    CbUserMenuItemIsSubmenu.Checked := False;
    EdUserMenuItemCaption.Text := '';
    EdUserMenuItemIcon.Text := '';
    EdUserMenuItemExecutable.Text := '';
    EdUserMenuItemParams.Text := '';
  end else
  begin
    BtnUserMenuItemUp.Enabled := Item.Index <> 0;
    BtnUserMenuItemDown.Enabled := Item.Index <> LvUserMenuItems.Items.Count - 1;
    EdUserMenuItemCaption.Text := FUserMenu[Item.Index].Caption;
    EdUserMenuItemIcon.Text := FUserMenu[Item.Index].Icon;
    EdUserMenuItemExecutable.Text := FUserMenu[Item.Index].EXEFile;
    EdUserMenuItemParams.Text := FUserMenu[Item.Index].Params;
    CbUserMenuItemIsSubmenu.Checked := FUserMenu[Item.Index].UseSubMenu;
    CbUserMenuItemIsSubmenu.Enabled := True;
    EdUserMenuItemCaption.Enabled := True;
    EdUserMenuItemIcon.Enabled := True;
    EdUserMenuItemExecutable.Enabled := True;
    EdUserMenuItemParams.Enabled := True;
    BtnUserMenuChooseExecutable.Enabled := True;
    BtnUserMenuChooseIcon.Enabled := True;
    BtnSaveUserMenuItem.Enabled := True;
  end;
end;

procedure TOptionsForm.BtnSaveUserMenuItemClick(Sender: TObject);
var
  Ico: TIcon;
begin
  if LvUserMenuItems.Selected = nil then
    Exit;

  FUserMenu[LvUserMenuItems.Selected.index].Caption := EdUserMenuItemCaption.Text;
  FUserMenu[LvUserMenuItems.Selected.index].Icon := EdUserMenuItemIcon.Text;
  FUserMenu[LvUserMenuItems.Selected.index].EXEFile := EdUserMenuItemExecutable.Text;
  FUserMenu[LvUserMenuItems.Selected.index].Params := EdUserMenuItemParams.Text;
  FUserMenu[LvUserMenuItems.Selected.index].UseSubMenu := CbUserMenuItemIsSubmenu.Checked;
  LvUserMenuItems.Selected.Caption := EdUserMenuItemCaption.Text;

  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(EdUserMenuItemIcon.Text);
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.index, Ico);
  finally
    F(Ico);
  end;
end;

procedure TOptionsForm.EdUserMenuItemCaptionKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    BtnSaveUserMenuItemClick(Sender);
end;

procedure TOptionsForm.BtnSelectUserMenuItemIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I: Integer;
begin
  S := EdSubmenuIcon.Text;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    EdSubmenuIcon.Text := FileName + ',' + IntToStr(IconIndex);

  SetIconToPictureFromPath(Image2.Picture, Icon);
end;

procedure TOptionsForm.BtnUserMenuItemUpClick(Sender: TObject);
var
  Info: TUserMenuItem;
  Icon1, Icon2: TIcon;
begin
  Info := FUserMenu[LvUserMenuItems.Selected.index];
  FUserMenu[LvUserMenuItems.Selected.index] := FUserMenu[LvUserMenuItems.Selected.index - 1];
  FUserMenu[LvUserMenuItems.Selected.index - 1] := Info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    ImageList1.GetIcon(LvUserMenuItems.Selected.index, Icon1);
    ImageList1.GetIcon(LvUserMenuItems.Selected.index - 1, Icon2);
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.index, Icon2);
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.index - 1, Icon1);
    LvUserMenuItems.Items[LvUserMenuItems.Selected.index].Caption := FUserMenu[LvUserMenuItems.Selected.index].Caption;
    LvUserMenuItems.Items[LvUserMenuItems.Selected.index - 1].Caption := FUserMenu[LvUserMenuItems.Selected.index - 1].Caption;
    LvUserMenuItems.Selected := LvUserMenuItems.Items[LvUserMenuItems.Selected.index - 1];
    LvUserMenuItems.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.BtnUserMenuItemDownClick(Sender: TObject);
var
  Info: TUserMenuItem;
  Icon1, Icon2: TIcon;
begin
  Info := FUserMenu[LvUserMenuItems.Selected.index];
  FUserMenu[LvUserMenuItems.Selected.index] := FUserMenu[LvUserMenuItems.Selected.index + 1];
  FUserMenu[LvUserMenuItems.Selected.index + 1] := Info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    ImageList1.GetIcon(LvUserMenuItems.Selected.index, Icon1);
    ImageList1.GetIcon(LvUserMenuItems.Selected.index + 1, Icon2);
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.index, Icon2);
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.index + 1, Icon1);
    LvUserMenuItems.Items[LvUserMenuItems.Selected.index].Caption := FUserMenu[LvUserMenuItems.Selected.index].Caption;
    LvUserMenuItems.Items[LvUserMenuItems.Selected.index + 1].Caption := FUserMenu[LvUserMenuItems.Selected.index + 1].Caption;
    LvUserMenuItems.Selected := LvUserMenuItems.Items[LvUserMenuItems.Selected.index + 1];
    LvUserMenuItems.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.BtnClearFaceDetectionCacheClick(Sender: TObject);
begin
  BtnClearFaceDetectionCache.Enabled := False;
  LsFaceDetectionClearCache.Show;
  TFaceDetectionClearCacheThread.Create(Self);
end;

procedure TOptionsForm.BtnClearIconCacheClick(Sender: TObject);
begin
  TAIcons.Instance.Clear;
end;

procedure TOptionsForm.BtnClearThumbnailCacheClick(Sender: TObject);
begin
  AExplorerFolders.Clear;
end;

procedure TOptionsForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptionsForm.PcMainChange(Sender: TObject);
var
  AllowChange: Boolean;
begin
  TabbedNotebook1Change(Sender, PcMain.ActivePageIndex, AllowChange);
end;

procedure TOptionsForm.PlacesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := PlacesListView.GetItemAt(MousePos.X, MousePos.Y);
  if Item = nil then
  begin
    Up1.Visible := False;
    Down1.Visible := False;
    DeleteItem1.Visible := False;
    Rename1.Visible := False;
  end else
  begin
    Up1.Visible := Item.index <> 0;
    Down1.Visible := Item.index <> PlacesListView.Items.Count - 1;
    PmPlaces.Tag := Item.index;
    Rename1.Visible := True;
    DeleteItem1.Visible := True;
  end;
  PmPlaces.Popup(PlacesListView.ClientToScreen(MousePos).X, PlacesListView.ClientToScreen(MousePos).Y);
end;

procedure TOptionsForm.BtnChooseNewPlaceClick(Sender: TObject);
var
  NewPlace: String;
const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';
begin
  if PlacesListView.Selected = nil then
  begin
    NewPlace := UnitDBFileDialogs.DBSelectDir(Handle,
      L('Please, select a folder'), UseSimpleSelectFolderDialog);
    if DirectoryExists(NewPlace) then
    begin
      SetLength(FPlaces, Length(FPlaces) + 1);
      FPlaces[Length(FPlaces) - 1].Name := GetFileNameWithoutExt(NewPlace);
      FPlaces[Length(FPlaces) - 1].FolderName := NewPlace;
      FPlaces[Length(FPlaces) - 1].Icon := DefaultIcon;
      FPlaces[Length(FPlaces) - 1].MyComputer := true;
      FPlaces[Length(FPlaces) - 1].MyDocuments := true;
      FPlaces[Length(FPlaces) - 1].MyPictures := true;
      FPlaces[Length(FPlaces) - 1].OtherFolder := true;
      AddIconToListFromPath(PlacesImageList, DefaultIcon);
      with PlacesListView.Items.AddItem(nil) do
      begin
        ImageIndex := PlacesImageList.Count - 1;
        Caption := GetFileNameWithoutExt(NewPlace);
      end;
    end;
  end else
  begin
    NewPlace := UnitDBFileDialogs.DBSelectDir(Handle,
      L('Please, select a folder'),
      FPlaces[PlacesListView.Selected.Index].FolderName,
      UseSimpleSelectFolderDialog);
    if DirectoryExists(NewPlace) then
      FPlaces[PlacesListView.Selected.Index].FolderName := NewPlace;
    FPlaces[PlacesListView.Selected.Index].Name := GetFileNameWithoutExt
      (NewPlace);
    PlacesListView.Selected.Caption := GetFileNameWithoutExt(NewPlace);
  end;
end;

procedure TOptionsForm.ReadPlaces;
var
  Reg: TBDRegistry;
  S: TStrings;
  FName, FFolderName, FIcon: string;
  FMyComputer, FMyDocuments, FMyPictures, FOtherFolder: Boolean;
  I: Integer;
begin
  PlacesImageList.Clear;
  PlacesImageList.Width := 16;
  PlacesImageList.Height := 16;
  PlacesImageList.BkColor := Clmenu;
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Places', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      SetLength(FPlaces, 0);
      PlacesListView.Clear;
      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + '\Places\' + S[I], True);
        FMyComputer := False;
        FMyDocuments := False;
        FMyPictures := False;
        FOtherFolder := False;

        if Reg.ValueExists('Name') then
          FName := Reg.ReadString('Name');
        if Reg.ValueExists('FolderName') then
          FFolderName := Reg.ReadString('FolderName');
        if Reg.ValueExists('Icon') then
          FIcon := Reg.ReadString('Icon');
        if Reg.ValueExists('MyComputer') then
          FMyComputer := Reg.Readbool('MyComputer');
        if Reg.ValueExists('MyDocuments') then
          FMyDocuments := Reg.Readbool('MyDocuments');
        if Reg.ValueExists('MyPictures') then
          FMyPictures := Reg.Readbool('MyPictures');
        if Reg.ValueExists('OtherFolder') then
          FOtherFolder := Reg.Readbool('OtherFolder');

        if (FName <> '') and (FFolderName <> '') then
        begin
          SetLength(FPlaces, Length(FPlaces) + 1);
          FPlaces[Length(FPlaces) - 1].name := FName;
          FPlaces[Length(FPlaces) - 1].FolderName := FFolderName;
          FPlaces[Length(FPlaces) - 1].Icon := FIcon;
          FPlaces[Length(FPlaces) - 1].MyComputer := FMyComputer;
          FPlaces[Length(FPlaces) - 1].MyDocuments := FMyDocuments;
          FPlaces[Length(FPlaces) - 1].MyPictures := FMyPictures;
          FPlaces[Length(FPlaces) - 1].OtherFolder := FOtherFolder;

          AddIconToListFromPath(PlacesImageList, fIcon);

          with PlacesListView.Items.Add do
          begin
            ImageIndex := PlacesImageList.Count - 1;
            Caption := FName;
          end;
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;
end;

procedure TOptionsForm.WlDefaultJPEGOptionsClick(Sender: TObject);
begin
  SetJPEGOptions;
end;

procedure TOptionsForm.WritePlaces;
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Places', true);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      Reg.CloseKey;
      for i := 1 to S.Count do
        Reg.DeleteKey(GetRegRootKey + '\Places\.' + IntToStr(i));
    finally
      F(S);
    end;

    for I := 0 to Length(FPlaces) - 1 do
    begin
      Reg.OpenKey(GetRegRootKey + '\Places\.' + IntToStr(I), true);
      Reg.WriteString('Name', FPlaces[I].Name);
      Reg.WriteString('FolderName', FPlaces[I].FolderName);
      Reg.WriteString('Icon', FPlaces[I].Icon);
      Reg.WriteBool('MyComputer', FPlaces[I].MyComputer);
      Reg.WriteBool('MyDocuments', FPlaces[I].MyDocuments);
      Reg.WriteBool('MyPictures', FPlaces[I].MyPictures);
      Reg.WriteBool('OtherFolder', FPlaces[I].OtherFolder);
      Reg.CloseKey;
    end;
  finally
    F(Reg);
  end;
end;

procedure TOptionsForm.PlacesListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  I: Integer;
begin
  if not Selected then
  begin
    for I := 0 to 3 do
      CblPlacesDisplayIn.Checked[I] := False;
    CblPlacesDisplayIn.Enabled := False;
    BtnChoosePlaceIcon.Enabled := False;
  end else
  begin
    CblPlacesDisplayIn.Checked[0] := FPlaces[Item.Index].MyComputer;
    CblPlacesDisplayIn.Checked[1] := FPlaces[Item.Index].MyDocuments;
    CblPlacesDisplayIn.Checked[2] := FPlaces[Item.Index].MyPictures;
    CblPlacesDisplayIn.Checked[3] := FPlaces[Item.Index].OtherFolder;
    CblPlacesDisplayIn.Enabled := True;
    BtnChoosePlaceIcon.Enabled := True;
  end;
end;

procedure TOptionsForm.CblPlacesDisplayInClickCheck(Sender: TObject);
var
  I: Integer;
begin
  if PlacesListView.Selected <> nil then
  begin
    I := PlacesListView.Selected.Index;
    FPlaces[I].MyComputer := CblPlacesDisplayIn.Checked[0];
    FPlaces[I].MyDocuments := CblPlacesDisplayIn.Checked[1];
    FPlaces[I].MyPictures := CblPlacesDisplayIn.Checked[2];
    FPlaces[I].OtherFolder := CblPlacesDisplayIn.Checked[3];
  end;
end;

procedure TOptionsForm.BtnChoosePlaceIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  S, Icon: string;
  I, index: Integer;
  Ico: TIcon;
begin
  if PlacesListView.Selected = nil then
    Exit;
  index := PlacesListView.Selected.index;
  S := FPlaces[index].Icon;
  I := Pos(',', S);
  FileName := Copy(S, 1, I - 1);
  Icon := Copy(S, I + 1, Length(S) - I);
  IconIndex := StrToIntDef(Icon, 0);
  ChangeIconDialog(Handle, FileName, IconIndex);
  if FileName <> '' then
    FPlaces[index].Icon := FileName + ',' + IntToStr(IconIndex);
  Ico := TIcon.Create;
  try
    Ico.Handle := ExtractSmallIconByPath(FPlaces[index].Icon);
    PlacesImageList.ReplaceIcon(index, Ico);
  finally
    F(Ico);
  end;
end;

procedure TOptionsForm.DeleteItem1Click(Sender: TObject);
var
  I: Integer;
begin
  if PmPlaces.Tag <> -1 then
  begin
    for I := PmPlaces.Tag to Length(FPlaces) - 2 do
      FPlaces[i] := FPlaces[I + 1];
    SetLength(FPlaces, Length(FPlaces) - 1);
    PlacesListView.Items.Delete(PmPlaces.Tag);
    PlacesImageList.Delete(PmPlaces.Tag);
    for I := PmPlaces.Tag to Length(FPlaces) - 1 do
      PlacesListView.Items[I].ImageIndex := PlacesListView.Items[I].ImageIndex - 1;
  end;
end;

procedure TOptionsForm.Up1Click(Sender: TObject);
var
  Info: TPlaceFolder;
  Icon1, Icon2: Ticon;
begin
  if PlacesListView.Selected = nil then
    Exit;
  Info := FPlaces[PlacesListView.Selected.index];
  FPlaces[PlacesListView.Selected.index] := FPlaces
    [PlacesListView.Selected.index - 1];
  FPlaces[PlacesListView.Selected.index - 1] := Info;
  Icon1 := Ticon.Create;
  Icon2 := Ticon.Create;
  try
    PlacesImageList.GetIcon(PlacesListView.Selected.index, Icon1);
    PlacesImageList.GetIcon(PlacesListView.Selected.index - 1, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index - 1, Icon1);
    PlacesListView.Items[PlacesListView.Selected.index].Caption := FPlaces
      [PlacesListView.Selected.index].Name;
    PlacesListView.Items[PlacesListView.Selected.index - 1].Caption := FPlaces
      [PlacesListView.Selected.index - 1].Name;
    PlacesListView.Selected := PlacesListView.Items
      [PlacesListView.Selected.index - 1];
    PlacesListView.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.Down1Click(Sender: TObject);
var
  info: TPlaceFolder;
  Icon1, Icon2: Ticon;
begin
  if PlacesListView.Selected = nil then
    Exit;

  Info := FPlaces[PlacesListView.Selected.index];
  FPlaces[PlacesListView.Selected.index] := FPlaces
    [PlacesListView.Selected.index + 1];
  FPlaces[PlacesListView.Selected.index + 1] := info;
  Icon1 := TIcon.Create;
  Icon2 := TIcon.Create;
  try
    PlacesImageList.GetIcon(PlacesListView.Selected.index, Icon1);
    PlacesImageList.GetIcon(PlacesListView.Selected.index + 1, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index, Icon2);
    PlacesImageList.ReplaceIcon(PlacesListView.Selected.index + 1, Icon1);
    PlacesListView.Items[PlacesListView.Selected.index].Caption := FPlaces
      [PlacesListView.Selected.index].Name;
    PlacesListView.Items[PlacesListView.Selected.index + 1].Caption := FPlaces
      [PlacesListView.Selected.index + 1].Name;
    PlacesListView.Selected := PlacesListView.Items
      [PlacesListView.Selected.index + 1];
    PlacesListView.SetFocus;
  finally
    F(Icon1);
    F(Icon2);
  end;
end;

procedure TOptionsForm.Rename1Click(Sender: TObject);
begin
  if PlacesListView.Selected = nil then
    exit;
  PlacesListView.Selected.EditCaption;
end;

procedure TOptionsForm.PlacesListViewEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
  FPlaces[Item.Index].Name := S;
end;

procedure TOptionsForm.DeselectAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := cbUnchecked;
end;

procedure TOptionsForm.SelectAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := cbChecked;
end;

procedure TOptionsForm.Default1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(TFileAssociation(CbExtensionList.Items.Objects[I]).Extension), True);
end;

procedure TOptionsForm.CbStartUpExplorerClick(Sender: TObject);
begin
  CbExplorerStartupLocation.Enabled := CbStartUpExplorer.Checked;
  EdExplorerStartupLocation.Enabled := CbExplorerStartupLocation.Checked;
end;

procedure TOptionsForm.BtnSelectExplorerStartupFolderClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Please select folder'), UseSimpleSelectFolderDialog);
  if DirectoryExists(Dir) then
    EdExplorerStartupLocation.Text := IncludeTrailingBackslash(Dir);
end;

procedure TOptionsForm.CbExplorerStartupLocationClick(Sender: TObject);
begin
  EdExplorerStartupLocation.Enabled := CbExplorerStartupLocation.Checked;
end;

procedure TOptionsForm.CbDontAddSmallFilesClick(Sender: TObject);
begin
  SedMinWidth.Enabled := CbDontAddSmallFiles.Checked;
  SedMinHeight.Enabled := CbDontAddSmallFiles.Checked;
end;

{ TFaceDetectionClearCacheThread }

constructor TFaceDetectionClearCacheThread.Create(AOwner: TOptionsForm);
begin
  inherited Create(AOwner, False);
  FOwner := AOwner;
end;

procedure TFaceDetectionClearCacheThread.Execute;
begin
  inherited;
  FreeOnTerminate := True;
  try
    DelDir(GetAppDataDirectory + FaceCacheDirectory, '||');
  finally
    SynchronizeEx(HideLoadingSign);
  end;
end;

procedure TFaceDetectionClearCacheThread.HideLoadingSign;
begin
  FOwner.LsFaceDetectionClearCache.Hide;
end;

end.
