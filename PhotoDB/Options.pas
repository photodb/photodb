unit Options;

interface

uses
  System.Generics.Collections,
  System.Math,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Win.Registry,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellApi,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.TabNotBk,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.CheckLst,
  Vcl.Menus,
  Vcl.Shell.ShellCtrls,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Vcl.ActnPopup,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Styles.Ext,

  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.Utils.Dialogs,
  Dmitry.Controls.Base,
  Dmitry.Controls.ShellNotification,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.SaveWindowPos,

  Dolphin_DB,
  UnitDBKernel,
  UnitINI,
  UnitDBDeclare,
  UnitDBFileDialogs,
  UnitDBCommon,
  UnitDBCommonGraphics,

  uTranslate,
  uShellUtils,
  uDBForm,
  uRuntime,
  uMemory,
  uSettings,
  uAssociations,
  uCryptUtils,
  uIconUtils,
  uLogger,
  uConstants,
  uDBThread,
  uBitmapUtils,
  uThemesUtils,
  uConfiguration,
  uICCProfile,
  uExplorerFolderImages,
  uFormInterfaces,
  uAssociatedIcons,
  uMediaPlayers,
  uVCLHelpers,
  uThreadTask,
  uTransparentEncryption,
  uProgramStatInfo,
  uShellIntegration;

type
  TOptionsForm = class(TPasswordSettingsDBForm, IOptionsForm)
    CancelButton: TButton;
    OkButton: TButton;
    PmExtensionStatus: TPopupActionBar;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    PmUserMenu: TPopupActionBar;
    Addnewcommand1: TMenuItem;
    Remove1: TMenuItem;
    ImageList1: TImageList;
    PmPlaces: TPopupActionBar;
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
    TsAssociations: TTabSheet;
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
    PmCryptMethod: TPopupActionBar;
    SedMinHeight: TSpinEdit;
    SedMinWidth: TSpinEdit;
    Bevel3: TBevel;
    GbEXIF: TGroupBox;
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
    CbRedCyanStereo: TCheckBox;
    TsStyle: TTabSheet;
    LbStyles: TListBox;
    LbAvailableTemes: TLabel;
    ImStylePreview: TImage;
    LbThemePreview: TLabel;
    BtnApplyTheme: TButton;
    WlGetMoreStyles: TWebLink;
    BtnShowThemesFolder: TButton;
    GbProxySettings: TGroupBox;
    WebProxyUserName: TWatermarkedEdit;
    LbProxyUserName: TLabel;
    LbProxyPassword: TLabel;
    WebProxyPassword: TWatermarkedEdit;
    SnStyles: TShellNotification;
    LbDisplayICCProfile: TLabel;
    CbDisplayICCProfile: TComboBox;
    TsPrograms: TTabSheet;
    CblExtensions: TListBox;
    StPlayerExtensions: TStaticText;
    RbPlayerInternal: TRadioButton;
    StUseProgram: TStaticText;
    RbVlcPlayer: TRadioButton;
    RbKmPlayer: TRadioButton;
    RbMediaPlayerClassic: TRadioButton;
    RbOtherProgram: TRadioButton;
    EdPlayerExecutable: TEdit;
    BtnSelectPlayerExecutable: TButton;
    LbExtensionExecutable: TLabel;
    WlAddPlayerExtension: TWebLink;
    WlRemovePlayerExtension: TWebLink;
    ImlMediaPlayers: TImageList;
    WlSavePlayerChanges: TWebLink;
    PmSelectExtensionMethod: TPopupActionBar;
    MiSelectFile: TMenuItem;
    MiSelectextension: TMenuItem;
    RbWindowsMediaPlayer: TRadioButton;
    RbDefaultrogram: TRadioButton;
    CbShowStatusBar: TCheckBox;
    CbSmoothScrolling: TCheckBox;
    CbUseProxyServer: TCheckBox;
    procedure TabbedNotebook1Change(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CbExtensionListContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
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
    procedure LvUserMenuItemsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Addnewcommand1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure LvUserMenuItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure BtnSaveUserMenuItemClick(Sender: TObject);
    procedure EdUserMenuItemCaptionKeyPress(Sender: TObject; var Key: Char);
    procedure BtnSelectUserMenuItemIconClick(Sender: TObject);
    procedure BtnUserMenuItemUpClick(Sender: TObject);
    procedure BtnUserMenuItemDownClick(Sender: TObject);
    procedure BtnClearIconCacheClick(Sender: TObject);
    procedure BtnClearThumbnailCacheClick(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure BtnChooseNewPlaceClick(Sender: TObject);
    procedure ReadPlaces;
    procedure WritePlaces;
    procedure PlacesListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure CblPlacesDisplayInClickCheck(Sender: TObject);
    procedure BtnChoosePlaceIconClick(Sender: TObject);
    procedure DeleteItem1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure Down1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure PlacesListViewEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure Default1Click(Sender: TObject);
    procedure CbDontAddSmallFilesClick(Sender: TObject);
    procedure PcMainChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure WlDefaultJPEGOptionsClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeselectAll1Click(Sender: TObject);
    procedure BtnClearFaceDetectionCacheClick(Sender: TObject);
    procedure BtnApplyThemeClick(Sender: TObject);
    procedure LbStylesClick(Sender: TObject);
    procedure WlGetMoreStylesClick(Sender: TObject);
    procedure BtnShowThemesFolderClick(Sender: TObject);
    procedure SnStylesFileCreate(Sender: TObject; Path: string);
    procedure CblExtensionsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CblExtensionsClick(Sender: TObject);
    procedure RbPlayerInternalClick(Sender: TObject);
    procedure BtnSelectPlayerExecutableClick(Sender: TObject);
    procedure EdPlayerExecutableChange(Sender: TObject);
    procedure WlSavePlayerChangesClick(Sender: TObject);
    procedure WlRemovePlayerExtensionClick(Sender: TObject);
    procedure WlAddPlayerExtensionClick(Sender: TObject);
    procedure MiSelectFileClick(Sender: TObject);
    procedure MiSelectextensionClick(Sender: TObject);
    procedure CbUseProxyServerClick(Sender: TObject);
  private
    FThemeList: TStringList;
    FUserMenu: TUserMenuItemArray;
    FLoadedPages: array [0..7] of Boolean;
    FPlaces: TPlaceFolderArray;
    ReloadData: Boolean;
    FReadingPlayerChanges: Boolean;
    FPlayerExtensions: TDictionary<string, string>;
    procedure LoadStylesList;
    procedure LoadMediaAssociations;
    procedure SaveMediaAssociations;
    procedure AddMediaAssociation(Extension, Player: string; LoadImage: Boolean);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
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

implementation

uses
  uManagerExplorer,
  FormManegerUnit;

{$R *.dfm}

procedure TOptionsForm.BtnShowThemesFolderClick(Sender: TObject);
var
  StylesUserPath: string;
begin
  StylesUserPath := GetAppDataDirectory + '\' + StylesFolder;
  with ExplorerManager.NewExplorer(False) do
  begin
    SetOldPath(StylesUserPath);
    SetPath(StylesUserPath);
    Show;
  end;
end;

procedure TOptionsForm.TabbedNotebook1Change(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
var
  I, Size: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  DisplayICCProfile,
  FCaption, EXEFile, Params, Icon: string;
  UseSubMenu: Boolean;
begin
  if FLoadedPages[NewTab] then
    Exit;
  FLoadedPages[NewTab] := True;

  if NewTab = 0 then
  begin
    LoadStylesList;
    LbStylesClick(Self);

    SnStyles.Path := GetAppDataDirectory + '\' + StylesFolder;
    SnStyles.Active := True;
  end;

  if NewTab = 1 then
  begin
    CbExtensionList.Enabled := not FolderView;
    BtnInstallExtensions.Enabled := not FolderView;
    CbExtensionList.Items.Clear;
    for I := 0 to TFileAssociations.Instance.Count - 1 do
      CbExtensionList.Items.AddObject(Format('%s   (%s)', [TFileAssociations.Instance[I].Extension, TFileAssociations.Instance[I].Description]), TFileAssociations.Instance[I]);

    LoadDefaultExtStates;
  end;
  if NewTab = 2 then
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
  if NewTab = 3 then
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

    CbRedCyanStereo.Checked := Settings.ReadString('Options', 'StereoMode', '') <> '';

    DisplayICCProfile := Settings.ReadString('Options', 'DisplayICCProfileName', DEFAULT_ICC_DISPLAY_PROFILE);

    CbDisplayICCProfile.Items.Add(L('Don''t use ICC profile'));
    FillDisplayProfileList(CbDisplayICCProfile.Items);

    CbDisplayICCProfile.Value := DisplayICCProfile;
  end;
  if NewTab = 5 then
  begin
    CbAutoSavePasswordForSession.Checked := Settings.Readbool('Options', 'AutoSaveSessionPasswords', True);
    CbAutoSavePasswordInSettings.Checked := Settings.Readbool('Options', 'AutoSaveINIPasswords', False);
    SedBackupDays.Value := Settings.ReadInteger('Options', 'BackUpdays', 7);

    WebProxyUserName.Text := Settings.ReadString('Options', 'ProxyUser');
    WebProxyPassword.Text := Settings.ReadString('Options', 'ProxyPassword');
    CbUseProxyServer.Checked := Settings.ReadBool('Options', 'UseProxyServer', False);
    CbUseProxyServerClick(Self);
  end;

  if NewTab = 6 then
  begin

    CbListViewShowPreview.Checked := Settings.Readbool('Options', 'AllowPreview', True);
    CbSmallToolBars.Checked := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
    CbSortGroups.Checked := Settings.Readbool('Options', 'SortGroupsByName', True);
    CbListViewHotSelect.Checked := Settings.Readbool('Options', 'UseHotSelect', True);
    CblEditorVirtuaCursor.Checked := Settings.ReadBool('Editor', 'VirtualCursor', False);
    CbCheckLinksOnUpdate.Checked := Settings.ReadBool('Options', 'CheckUpdateLinks', False);

    CbDontAddSmallFiles.Checked := Settings.ReadBool('Options', 'DontAddSmallImages', True);
    SedMinWidth.Value := Settings.ReadInteger('Options', 'DontAddSmallImagesWidth', 64);
    SedMinHeight.Value := Settings.ReadInteger('Options', 'DontAddSmallImagesHeight', 64);
    SedMinWidth.Enabled := CbDontAddSmallFiles.Checked;
    SedMinHeight.Enabled := CbDontAddSmallFiles.Checked;

    CbReadInfoFromExif.Checked := Settings.Exif.ReadInfoFromExif;
    CbSaveInfoToExif.Checked := Settings.Exif.SaveInfoToExif;
    CbUpdateExifInfoInBackground.Checked := Settings.Exif.UpdateExifInfoInBackground;

    CbShowStatusBar.Checked :=  Settings.ReadBool('Options', 'ShowStatusBar', False);
    CbSmoothScrolling.Checked :=  Settings.ReadBool('Options', 'SmoothScrolling', True);
  end;

  if NewTab = 4 then
  begin
    ImageList1.Clear;
    ImageList1.Width := 16;
    ImageList1.Height := 16;

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

  if NewTab = 7 then
  begin
    RbVlcPlayer.Enabled := IsVlcPlayerInstalled;
    RbKmPlayer.Enabled := IsKmpPlayerInstalled;
    RbMediaPlayerClassic.Enabled := IsMediaPlayerClassicInstalled;
    RbPlayerInternal.Enabled := IsPlayerInternalInstalled;
    RbWindowsMediaPlayer.Enabled := IsWindowsMediaPlayerInstalled;
    RbDefaultrogram.Enabled := True;
    LoadMediaAssociations;
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
  Action := caFree;
end;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  if FolderView then
  begin
    PcMain.Pages[0].TabVisible := False;
    PcMain.Pages[1].TabVisible := False;
    PcMain.Pages[7].TabVisible := False;
    PcMain.ActivePageIndex := 2;
  end;

  FReadingPlayerChanges := True;
  FPlayerExtensions := TDictionary<string, string>.Create;

  ReloadData := False;
  SaveWindowPos1.Key := GetRegRootKey + 'Options';
  SaveWindowPos1.SetPosition;
  for I := 0 to 7 do
    FLoadedPages[I] := False;
  LoadLanguage;
  FThemeList := TStringList.Create;
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

  PcMainChange(Self);

  WblMethod.Color := Theme.PanelColor;
  WblMethod.Font.Color := Theme.PanelFontColor;
  WlGetMoreStyles.Color := Theme.PanelColor;
  WlGetMoreStyles.Font.Color := Theme.PanelFontColor;
  WlDefaultJPEGOptions.Color := Theme.PanelColor;
  WlDefaultJPEGOptions.Font.Color := Theme.PanelFontColor;

  WblMethod.LoadFromResource('PASSWORD');

  WlAddPlayerExtension.LoadFromResource('GROUP_ADD_SMALL');
  WlRemovePlayerExtension.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);
  WlSavePlayerChanges.LoadFromResource('CMD_OK');

end;

procedure TOptionsForm.FormDestroy(Sender: TObject);
begin
  F(FThemeList);
  F(FPlayerExtensions);
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  I: Integer;
  Reg: TBDRegistry;
  S: TStrings;
  EventInfo: TEventValues;
begin
  Settings.ClearCache;

  if ReloadData then
  begin
    if MessageBoxDB(Handle, L('Refresh data in windows?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
      DBKernel.DoIDEvent(Self, 0, [EventID_Param_Refresh_Window], EventInfo);

  end;
  // case TabbedNotebook1.PageIndex of
  // 0:
  if FLoadedPages[1] then
  begin
   //nothing to save
  end;
  // 1:
  if FLoadedPages[2] then
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

    ExplorerManager.ShowQuickLinks := CbExplorerShowPlaces.Checked;
    WritePlaces;
  end;
  // 3 :
  if FLoadedPages[4] then
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
  if FLoadedPages[5] then
  begin
    Settings.WriteBool('Options', 'AutoSaveSessionPasswords', CbAutoSavePasswordForSession.Checked);
    Settings.WriteBool('Options', 'AutoSaveINIPasswords', CbAutoSavePasswordInSettings.Checked);
    Settings.WriteInteger('Options', 'BackUpdays', SedBackupDays.Value);

    Settings.WriteString('Options', 'ProxyUser', WebProxyUserName.Text);
    Settings.WriteString('Options', 'ProxyPassword', WebProxyPassword.Text);
    Settings.WriteBool('Options', 'UseProxyServer', CbUseProxyServer.Checked);
  end;
  // 5 :
  if FLoadedPages[6] then
  begin
    Settings.WriteBool('Options', 'AllowPreview', CbListViewShowPreview.Checked);
    Settings.WriteBool('Options', 'UseSmallToolBarButtons', CbSmallToolBars.Checked);

    Settings.WriteBool('Options', 'SortGroupsByName', CbSortGroups.Checked);
    Settings.WriteBool('Options', 'UseHotSelect', CbListViewHotSelect.Checked);
    Settings.WriteBool('Editor', 'VirtualCursor', CblEditorVirtuaCursor.Checked);
    Settings.WriteBool('Options', 'CheckUpdateLinks', CbCheckLinksOnUpdate.Checked);

    Settings.WriteBool('Options', 'DontAddSmallImages', CbDontAddSmallFiles.Checked);
    Settings.WriteInteger('Options', 'DontAddSmallImagesWidth', SedMinWidth.Value);
    Settings.WriteInteger('Options', 'DontAddSmallImagesHeight', SedMinHeight.Value);

    Settings.Exif.ReadInfoFromExif := CbReadInfoFromExif.Checked;
    Settings.Exif.SaveInfoToExif := CbSaveInfoToExif.Checked;
    Settings.Exif.UpdateExifInfoInBackground := CbUpdateExifInfoInBackground.Checked;

    Settings.WriteBool('Options', 'ShowStatusBar', CbShowStatusBar.Checked);
    Settings.WriteBool('Options', 'SmoothScrolling', CbSmoothScrolling.Checked);
  end;
  // 2 :
  if FLoadedPages[3] then
  begin
    Settings.WriteBool('Options', 'NextOnClick', CbViewerNextOnClick.Checked);
    Settings.WriteBoolW('Options', 'SlideShow_UseCoolStretch', CbViewerUseCoolStretch.Checked);
    Settings.WriteInteger('Options', 'SlideShow_SlideSteps', TrackBar1.Position);
    Settings.WriteInteger('Options', 'SlideShow_SlideDelay', TrackBar2.Position);
    Settings.WriteInteger('Options', 'FullScreen_SlideDelay', TrackBar4.Position);

    Settings.WriteBool('Options', 'ViewerFaceDetection', CbViewerFaceDetection.Checked);
    Settings.WriteInteger('Options', 'FaceDetectionSize', Integer(CbDetectionSize.Items.Objects[CbDetectionSize.ItemIndex]));
    Settings.WriteString('Options', 'StereoMode', IIF(CbRedCyanStereo.Checked, 'RedCyan', ''));

    Settings.WriteString('Options', 'DisplayICCProfileName', IIF(CbDisplayICCProfile.ItemIndex = 0, '-', CbDisplayICCProfile.Value));
  end;

  if FLoadedPages[7] then
  begin
    SaveMediaAssociations;
    EncryptionOptions.Refresh;
  end;

  TFormCollection.Instance.ApplySettings;

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
  ShellExecuteInfo: TShellExecuteInfo;
  ExtParams: string;
begin
  ExtParams := '';
  for I := 0 to CbExtensionList.Items.Count - 1 do
    ExtParams := ExtParams + IIF(ExtParams = '', '', ';') + TFileAssociation(CbExtensionList.Items.Objects[I]).Extension + ':' + CheckboxStateToString(CbExtensionList.State[I]);

  ShellExecuteInfo.cbSize:= SizeOf(TShellExecuteInfo);
  ShellExecuteInfo.fMask:= SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd:= 0;
  ShellExecuteInfo.lpVerb:= 'runas';
  ShellExecuteInfo.lpFile:= PChar('"' + Application.ExeName + '"');
  ShellExecuteInfo.lpParameters:= PChar('/close /NoPrevVersion /nologo /installExt ' + ExtParams);
  ShellExecuteInfo.lpDirectory:= PChar(ExtractFileDir(Application.ExeName));
  ShellExecuteInfo.nShow:= SW_SHOWNORMAL;
  if ShellExecuteEx(@ShellExecuteInfo) then
  begin
    WaitForSingleObject(ShellExecuteInfo.hProcess, 5000);
    CloseHandle(ShellExecuteInfo.hProcess);
    LoadDefaultExtStates;
  end;
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
    TsAssociations.Caption := L('Associations');
    TsExplorer.Caption := L('Explorer'); ;
    TsView.Caption := L('Viewer'); ;
    TsUserMenu.Caption := L('User menu');
    TsSecurity.Caption := L('Security');
    TsGlobal.Caption := L('Global');
    TsPrograms.Caption := L('Programs');
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
    CbShowStatusBar.Caption := L('Show status bar');
    CbSmoothScrolling.Caption := L('Smooth scrolling');
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

    CbRedCyanStereo.Caption := L('Red-cyan glasses for stereo images');

    for I := 1 to 5 do
    begin
      S := FloatToStrEx(DetectSizes[I] / 10, 2) + L('Mpx') + IIF(I = 1, ' (' + L('Best perfomance') + ')', '');
      CbDetectionSize.Items.AddObject(S, TObject(I));
    end;
    BtnClearFaceDetectionCache.Caption := L('Clear cache');

    TsStyle.Caption := L('Styles');
    BtnApplyTheme.Caption := L('Apply style');
    LbAvailableTemes.Caption := L('Available styles') + ':';
    LbThemePreview.Caption := L('Style preview') + ':';
    BtnShowThemesFolder.Caption := L('Open user themes folder');
    WlGetMoreStyles.Text := L('Get more styles!');
    WlGetMoreStyles.LoadImage;
    WlGetMoreStyles.Left := TsStyle.ClientRect.Width - WlGetMoreStyles.Width - 5;

    GbProxySettings.Caption := L('Proxy settings');
    LbProxyUserName.Caption := L('User name') + ':';
    LbProxyPassword.Caption := L('Password') + ':';
    WebProxyUserName.WatermarkText := L('User name');
    WebProxyPassword.WatermarkText := L('Password');
    CbUseProxyServer.Caption := L('Use proxy server');
    LbProxyUserName.Left := WebProxyUserName.Left - LbProxyUserName.Width - 5;
    LbProxyPassword.Left := WebProxyPassword.Left - LbProxyPassword.Width - 5;

    LbDisplayICCProfile.Caption := L('Display ICC profile');

    WlAddPlayerExtension.Text := L('Add');
    WlRemovePlayerExtension.Text := L('Remove');
    WlAddPlayerExtension.LoadImage;
    WlRemovePlayerExtension.LoadImage;
    WlRemovePlayerExtension.Left := WlAddPlayerExtension.Left + WlAddPlayerExtension.Width + 5;

    StPlayerExtensions.Caption := L('Extensions') + ':';
    StUseProgram.Caption := L('Use program') + ':';

    RbDefaultrogram.Caption := L('Default program');
    RbPlayerInternal.Caption := L('Internal video player');
    RbVlcPlayer.Caption := L('VLC player');
    RbKmPlayer.Caption := L('KMPlayer');
    RbMediaPlayerClassic.Caption := L('Media Player Classic');
    RbWindowsMediaPlayer.Caption := L('Windows Media Player');
    RbOtherProgram.Caption := L('Other programm') + ':';

    LbExtensionExecutable.Caption := L('Executable file') + ':';
    WlSavePlayerChanges.Text := L('Save changes');

    MiSelectFile.Caption := L('Select file');
    MiSelectextension.Caption := L('Select extension');
  finally
    EndTranslate;
  end;
end;

procedure TOptionsForm.AddMediaAssociation(Extension, Player: string; LoadImage: Boolean);
var
  Ico: HIcon;
  Icon: TIcon;
begin
  Extension := AnsiUpperCase(Extension);
  if not FPlayerExtensions.ContainsKey(Extension) then
  begin
    FPlayerExtensions.Add(Extension, Player);;

    Ico := 0;
    if LoadImage then
      Ico := ExtractSmallIconByPath(Player);

    if Ico = 0 then
      Ico := CopyIcon(UnitDBKernel.Icons[DB_IC_SIMPLEFILE + 1]);
    Icon := TIcon.Create;
    try
      Icon.Handle := Ico;
      ImlMediaPlayers.AddIcon(Icon);
      CblExtensions.Items.Add(Extension);
    finally
      F(Icon);
    end;
  end;
end;

procedure TOptionsForm.LoadMediaAssociations;
var
  I: Integer;
  Associations: TStrings;
  Extension,
  Player: string;
begin
  Associations := Settings.ReadKeys(cMediaAssociationsData);
  try
    for I := 0 to Associations.Count - 1 do
    begin
      Player := Settings.ReadString(cMediaAssociationsData + '\' + Associations[I], '');

      if Player = cMediaPlayerDefaultId then
        Player := GetPlayerInternalPath;

      Extension := AnsiUpperCase(Associations[I]);
      AddMediaAssociation(Extension, Player, False);
    end;
  finally
    F(Associations);
  end;

  WlRemovePlayerExtension.Enabled := CblExtensions.Items.Count > 0;
  if WlRemovePlayerExtension.Enabled then
  begin
    CblExtensions.ItemIndex := 0;
    CblExtensionsClick(Self);

    TThreadTask.Create(Self, Pointer(nil),
      procedure(Thread: TThreadTask; Data: Pointer)
      var
        Extension, Player: string;
        Index: Integer;
        Icon: HIcon;
        Ico: TIcon;
      begin
        Index := -1;
        while True do
        begin
          Inc(Index);
          Extension := '';
          Thread.SynchronizeTask(
            procedure
            begin
              if Index < TOptionsForm(Thread.ThreadForm).CblExtensions.Items.Count then
              begin
                Extension := TOptionsForm(Thread.ThreadForm).CblExtensions.Items[Index];
                Player := TOptionsForm(Thread.ThreadForm).FPlayerExtensions[Extension];
              end;
            end
          );
          if Extension = '' then
            Exit;

          Icon := ExtractSmallIconByPath(Player);
          if Icon > 0 then
          begin
            Ico := TIcon.Create;
            try
              Ico.Handle := Icon;
              Thread.SynchronizeTask(
                procedure
                begin
                  ImlMediaPlayers.ReplaceIcon(Index, Ico);
                  CblExtensions.Refresh;
                end
              );
            finally
              F(Ico);
            end;
          end;
        end;
      end
    );
  end;
end;

procedure TOptionsForm.SaveMediaAssociations;
var
  Player: string;
  Pair: TPair<string, string>;
begin
  Settings.DeleteKey(cMediaAssociationsData);
  for Pair in FPlayerExtensions do
  begin
    Player := Pair.Value;
    Settings.WriteString(cMediaAssociationsData + '\' + Pair.Key, '', Player);
  end;
end;

procedure TOptionsForm.LoadStylesList;
var
  StylesPath,
  CurrentStyle,
  StylesUserPath: string;
  IsStyleSelected: Boolean;

  procedure LoadStylesFromDirectory(Directory: string);
  var
    FileName: string;
  begin
    for FileName in TDirectory.GetFiles(Directory, '*.vsf') do
    begin
      FThemeList.Add(FileName);
      LbStyles.Items.Add(ExtractFileName(FileName));
      if not IsStyleSelected and ((AnsiLowerCase(CurrentStyle) = AnsiLowerCase(ExtractFileName(FileName))) or
        (AnsiLowerCase(CurrentStyle) = AnsiLowerCase(FileName))) then
      begin
        LbStyles.Selected[LbStyles.Items.Count - 1] := True;
        IsStyleSelected := True;
      end;
    end;
  end;

begin
  IsStyleSelected := False;

  CurrentStyle := Settings.ReadString('Style', 'FileName', DefaultThemeName);

  LbStyles.Items.Clear;
  FThemeList.Clear;
  FThemeList.Add(' ');
  LbStyles.Items.Add(L('Windows style (standard)'));

  StylesPath := ExtractFilePath(ParamStr(0)) + StylesFolder;
  LoadStylesFromDirectory(StylesPath);

  StylesUserPath := GetAppDataDirectory + '\' + StylesFolder;
  CreateDirA(StylesUserPath);
  LoadStylesFromDirectory(StylesUserPath);

  if not IsStyleSelected then
    LbStyles.Selected[0] := True;
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

procedure TOptionsForm.LbStylesClick(Sender: TObject);
var
  I: Integer;
  LStyle: TCustomStyle;
  FBitmap: TBitmap;
  Text: string;
  R: TRect;
begin
  for I := 0 to LbStyles.Items.Count - 1 do
    if LbStyles.Selected[I] then
    begin
      if I = 0 then
      begin
        FBitmap := TBitmap.Create;
        try
          FBitmap.PixelFormat := pf32Bit;
          FBitmap.Width := ImStylePreview.ClientRect.Width;
          FBitmap.Height := ImStylePreview.ClientRect.Height;
          FillTransparentColor(FBitmap, Theme.PanelColor, 255);
          FBitmap.Canvas.Font.Color := Theme.PanelFontColor;
          FBitmap.Canvas.Pen.Color := Theme.PanelColor;
          FBitmap.Canvas.Brush.Color := Theme.PanelColor;
          Text := L('Standard windows theme (preview isn''t available)');
          R := ImStylePreview.ClientRect;
          SetBkMode(FBitmap.Canvas.Handle, TRANSPARENT);
          DrawText(FBitmap.Canvas.Handle, Text, Length(Text), R, DT_CENTER or DT_VCENTER );
          ImStylePreview.Picture.Graphic := FBitmap;
        finally
          F(FBitmap);
        end;
        Exit;
      end;
      LStyle := TCustomStyleExt.Create(FThemeList[I]);
      try
        if Assigned(LStyle) then
        begin
          FBitmap := TBitmap.Create;
          try
            FBitmap.PixelFormat := pf32bit;
            FBitmap.Width := ImStylePreview.ClientRect.Width;
            FBitmap.Height := ImStylePreview.ClientRect.Height;
            FillTransparentColor(FBitmap, Theme.PanelColor, 0);
            DrawSampleWindow(LStyle, FBitmap.Canvas, ImStylePreview.ClientRect, 'Photo Database');
            ImStylePreview.Picture.Graphic := FBitmap;
          finally
            F(FBitmap);
          end;
        end;
      finally
        F(LStyle);
      end;
  end;
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

procedure TOptionsForm.MiSelectextensionClick(Sender: TObject);
var
  Extension,
  Player: string;
begin
  Extension := '';
  StringPromtForm.Query(L('Enter extension'), L('Please enter extension (for example - .avi)'), Extension);
  if Extension <> '' then
  begin
    if Pos('.', Extension) = 0 then
      Extension := '.' + Extension;

    Player := GetShellPlayerForFile(Extension);
    if IsVideoFile(Extension) or (Player = '') then
      Player := GetPlayerInternalPath;

    AddMediaAssociation(Extension, GetPlayerInternalPath, True);
    CblExtensions.Selected[CblExtensions.Items.Count - 1] := True;
    CblExtensionsClick(Sender);
  end;
end;

procedure TOptionsForm.MiSelectFileClick(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
  Player: string;
begin
  OpenDialog := DBOpenDialog.Create;
  try
    OpenDialog.Filter := L('All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 0;
    if OpenDialog.Execute then
    begin

      Player := GetShellPlayerForFile(OpenDialog.FileName);
      if IsVideoFile(OpenDialog.FileName) or (Player = '') then
        Player := GetPlayerInternalPath;

      AddMediaAssociation(ExtractFileExt(OpenDialog.FileName), Player, True);
      CblExtensions.Selected[CblExtensions.Items.Count - 1] := True;
      CblExtensionsClick(Sender);
    end;
  finally
    F(OpenDialog);
  end;
end;

procedure TOptionsForm.BtnSaveUserMenuItemClick(Sender: TObject);
var
  Ic: HIcon;
  Ico: TIcon;
begin
  if LvUserMenuItems.Selected = nil then
    Exit;

  FUserMenu[LvUserMenuItems.Selected.Index].Caption := EdUserMenuItemCaption.Text;
  FUserMenu[LvUserMenuItems.Selected.Index].Icon := EdUserMenuItemIcon.Text;
  FUserMenu[LvUserMenuItems.Selected.Index].EXEFile := EdUserMenuItemExecutable.Text;
  FUserMenu[LvUserMenuItems.Selected.Index].Params := EdUserMenuItemParams.Text;
  FUserMenu[LvUserMenuItems.Selected.Index].UseSubMenu := CbUserMenuItemIsSubmenu.Checked;
  LvUserMenuItems.Selected.Caption := EdUserMenuItemCaption.Text;

  Ico := TIcon.Create;
  try
    Ic := ExtractSmallIconByPath(EdUserMenuItemIcon.Text);
    if Ic = 0 then
      Ic := CopyIcon(UnitDBKernel.Icons[DB_IC_SIMPLEFILE + 1]);

    Ico.Handle := Ic;
    ImageList1.ReplaceIcon(LvUserMenuItems.Selected.Index, Ico);
  finally
    F(Ico);
  end;
end;

procedure TOptionsForm.EdPlayerExecutableChange(Sender: TObject);
var
  Index: Integer;
  Extension: string;
begin
  if not FReadingPlayerChanges then
  begin
    Index := CblExtensions.SelectedIndex;
    if Index > -1 then
    begin
      Extension := CblExtensions.Items[Index];
      WlSavePlayerChanges.Visible := EdPlayerExecutable.Text <> FPlayerExtensions[Extension];
    end;
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
  ExplorerFolders.Clear;
end;

procedure TOptionsForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  with Params do
    ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptionsForm.CustomFormAfterDisplay;
begin
  inherited;
  if LbStyles <> nil then
    LbStyles.Refresh;
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

procedure TOptionsForm.BtnApplyThemeClick(Sender: TObject);
var
  I: Integer;
  ShellExecuteInfo: TShellExecuteInfo;
begin
  for I := 0 to LbStyles.Items.Count - 1 do
    if LbStyles.Selected[I] then
    begin
      ProgramStatistics.StyleUsed;

      Settings.WriteString('Style', 'FileName', FThemeList[I]);
      if MessageBoxDB(Handle, L('Restart of application is required for applying new style! Restart application now?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
      begin
        ShellExecuteInfo.cbSize := SizeOf(TShellExecuteInfo);
        ShellExecuteInfo.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
        ShellExecuteInfo.Wnd := 0;
        ShellExecuteInfo.lpVerb := 'open';
        ShellExecuteInfo.lpFile := PChar('"' + Application.ExeName + '"');
        ShellExecuteInfo.lpParameters := PChar('/NoPrevVersion');
        ShellExecuteInfo.lpDirectory := PChar(ExtractFileDir(Application.ExeName));
        ShellExecuteInfo.nShow := SW_SHOWNORMAL;
        if ShellExecuteEx(@ShellExecuteInfo) then
        begin
          Close;
          FormManager.CloseApp(Self);
        end;
      end;
    end;
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
      FPlaces[Length(FPlaces) - 1].MyComputer := True;
      FPlaces[Length(FPlaces) - 1].MyDocuments := True;
      FPlaces[Length(FPlaces) - 1].MyPictures := True;
      FPlaces[Length(FPlaces) - 1].OtherFolder := True;
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

procedure TOptionsForm.RbPlayerInternalClick(Sender: TObject);
begin
  EdPlayerExecutable.Enabled := RbOtherProgram.Checked;
  BtnSelectPlayerExecutable.Enabled := RbOtherProgram.Checked;

  if RbDefaultrogram.Checked then
    EdPlayerExecutable.Text := '';

  if RbPlayerInternal.Checked then
    EdPlayerExecutable.Text := GetPlayerInternalPath;

  if RbVlcPlayer.Checked then
    EdPlayerExecutable.Text := GetVlcPlayerPath;

  if RbKmPlayer.Checked then
    EdPlayerExecutable.Text := GetKMPlayerPath;

  if RbMediaPlayerClassic.Checked then
    EdPlayerExecutable.Text := GetMediaPlayerClassicPath;

  if RbWindowsMediaPlayer.Checked then
    EdPlayerExecutable.Text := GetWindowsMediaPlayerPath;
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

procedure TOptionsForm.WlAddPlayerExtensionClick(Sender: TObject);
var
  P: TPoint;
begin
  P := WlAddPlayerExtension.ClientRect.TopLeft;
  P := WlAddPlayerExtension.ClientToScreen(P);
  P.Y := P.Y + WlAddPlayerExtension.Height;
  PmSelectExtensionMethod.Popup(P.X, P.Y);
end;

procedure TOptionsForm.WlDefaultJPEGOptionsClick(Sender: TObject);
begin
  JpegOptionsForm.Execute;
end;

procedure TOptionsForm.WlGetMoreStylesClick(Sender: TObject);
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(ActionHelpPageURL) + SITE_ACTION_STYLES), nil, nil, SW_NORMAL);
end;

procedure TOptionsForm.WlRemovePlayerExtensionClick(Sender: TObject);
var
  Extension: string;
begin
  if CblExtensions.SelectedIndex > -1 then
  begin
    Extension := CblExtensions.Items[CblExtensions.SelectedIndex];
    if MessageBoxDB(Handle, FormatEx(L('Do you really want to delete mapping for extension "{0}"?'), [Extension]), L('Question'), TD_BUTTON_YESNO, TD_ICON_QUESTION) = ID_YES then
    begin
      ImlMediaPlayers.Delete(CblExtensions.SelectedIndex);
      CblExtensions.Items.Delete(CblExtensions.SelectedIndex);
      FPlayerExtensions.Remove(Extension);

      WlRemovePlayerExtension.Enabled := CblExtensions.Items.Count > 0;
      if WlRemovePlayerExtension.Enabled then
      begin
        if CblExtensions.ItemIndex = -1 then
          CblExtensions.Selected[CblExtensions.Items.Count - 1] := True;

        CblExtensionsClick(Sender);
      end;
    end;
  end;
end;

procedure TOptionsForm.WlSavePlayerChangesClick(Sender: TObject);
var
  Ico: HIcon;
  Icon: TIcon;
begin
  if CblExtensions.SelectedIndex > -1 then
  begin
    FPlayerExtensions[CblExtensions.Items[CblExtensions.SelectedIndex]] := EdPlayerExecutable.Text;

    Ico := ExtractSmallIconByPath(EdPlayerExecutable.Text);
    if Ico = 0 then
      Ico := CopyIcon(UnitDBKernel.Icons[DB_IC_SIMPLEFILE + 1]);

    Icon := TIcon.Create;
    try
      Icon.Handle := Ico;
      ImlMediaPlayers.ReplaceIcon(CblExtensions.SelectedIndex, Icon);
      CblExtensions.Refresh;
    finally
      F(Icon);
    end;

    WlSavePlayerChanges.Visible := False;
  end;
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

procedure TOptionsForm.CblExtensionsClick(Sender: TObject);
var
  SelectedIndex: Integer;
  Extension, Player: string;
begin
  SelectedIndex := CblExtensions.SelectedIndex;

  WlSavePlayerChanges.Visible := False;
  if SelectedIndex > -1 then
  begin
    Extension := CblExtensions.Items[SelectedIndex];

    RbDefaultrogram.Enabled := GetShellPlayerForFile('file' + Extension) <> '';

    Player := FPlayerExtensions[Extension];

    FReadingPlayerChanges := True;
    try
      EdPlayerExecutable.Text := Player;

      if AnsiLowerCase(Player) = AnsiLowerCase(GetPlayerInternalPath) then
        RbPlayerInternal.Checked := True
      else if AnsiLowerCase(Player) = AnsiLowerCase(GetVlcPlayerPath) then
        RbVlcPlayer.Checked := True
      else if AnsiLowerCase(Player) = AnsiLowerCase(GetKMPlayerPath) then
        RbKmPlayer.Checked := True
      else if AnsiLowerCase(Player) = AnsiLowerCase(GetMediaPlayerClassicPath) then
        RbMediaPlayerClassic.Checked := True
      else if AnsiLowerCase(Player) = AnsiLowerCase(GetWindowsMediaPlayerPath) then
        RbWindowsMediaPlayer.Checked := True
      else if Player = '' then
        RbDefaultrogram.Checked := True
      else
        RbOtherProgram.Checked := True;
    finally
      FReadingPlayerChanges := False;
    end;
  end;
end;

procedure TOptionsForm.CblExtensionsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
  TextHeight: Integer;
begin
  if Index > -1 then
  begin
    LB := TListBox(Control);
    LB.Canvas.FillRect(Rect);

    LB := TListBox(Control);
    ImlMediaPlayers.Draw(LB.Canvas, Rect.Left + 2, Rect.Top + LB.ItemHeight div 2 - ImlMediaPlayers.Height div 2,
      Index);

    if odSelected in State then
      LB.Canvas.Font.Color := Theme.ListFontSelectedColor
    else
      LB.Canvas.Font.Color := Theme.ListFontColor;

    TextHeight := LB.Canvas.TextHeight(LB.Items[index]);

    LB.Canvas.TextOut(Rect.Left + ImlMediaPlayers.Width + 2 * 2, Rect.Top + LB.ItemHeight div 2 - TextHeight div 2, LB.Items[index]);
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

procedure TOptionsForm.CbUseProxyServerClick(Sender: TObject);
begin
  WebProxyUserName.Enabled := CbUseProxyServer.Checked;
  WebProxyPassword.Enabled := CbUseProxyServer.Checked;
end;

procedure TOptionsForm.BtnChoosePlaceIconClick(Sender: TObject);
var
  FileName: string;
  IconIndex: Integer;
  Ic: HIcon;
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
    Ic := ExtractSmallIconByPath(FPlaces[index].Icon);
    if Ic = 0 then
      Ic := CopyIcon(UnitDBKernel.Icons[DB_IC_SIMPLEFILE + 1]);
    Ico.Handle := Ic;

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

procedure TOptionsForm.SnStylesFileCreate(Sender: TObject; Path: string);
begin
  LoadStylesList;
end;

procedure TOptionsForm.Default1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CbExtensionList.Items.Count - 1 do
    CbExtensionList.State[I] := AssociationStateToCheckboxState(TFileAssociations.Instance.GetCurrentAssociationState(TFileAssociation(CbExtensionList.Items.Objects[I]).Extension), True);
end;

procedure TOptionsForm.BtnSelectPlayerExecutableClick(Sender: TObject);
var
  OpenDialog: DBOpenDialog;
begin

  OpenDialog := DBOpenDialog.Create;
  try
    if FileExistsSafe(EdPlayerExecutable.Text) then
      OpenDialog.SetFileName(EdPlayerExecutable.Text);

    OpenDialog.Filter := L('Programs (*.exe)|*.exe|All Files (*.*)|*.*');
    OpenDialog.FilterIndex := 1;
    if OpenDialog.Execute then
      EdPlayerExecutable.Text := OpenDialog.FileName;

  finally
    F(OpenDialog);
  end;
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

initialization
  FormInterfaces.RegisterFormInterface(IOptionsForm, TOptionsForm);

end.
