unit Options;

interface

uses
  System.Generics.Collections,
  System.Math,
  System.Types,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellApi,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.ExtCtrls,
  Vcl.CheckLst,
  Vcl.Menus,
  Vcl.Shell.ShellCtrls,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Vcl.ActnPopup,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.Styles,
  Vcl.Styles.Ext,

  Dmitry.Utils.Files,
  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.ShellNotification,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.SaveWindowPos,

  UnitINI,
  UnitDBDeclare,
  UnitDBFileDialogs,

  uTranslate,
  uDBForm,
  uRuntime,
  uMemory,
  uSettings,
  uAssociations,
  uCryptUtils,
  uIconUtils,
  uConstants,
  uDBThread,
  uBitmapUtils,
  uThemesUtils,
  uDBIcons,
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
  uShellIntegration,
  uCollectionEvents,
  uSessionPasswords,
  uLinkListEditorForExecutables;

type
  TOptionsForm = class(TPasswordSettingsDBForm, IOptionsForm)
    CancelButton: TButton;
    OkButton: TButton;
    PmExtensionStatus: TPopupActionBar;
    Usethisprogramasdefault1: TMenuItem;
    Usemenuitem1: TMenuItem;
    Dontusethisextension1: TMenuItem;
    PlacesImageList: TImageList;
    SaveWindowPos1: TSaveWindowPos;
    N3: TMenuItem;
    Default1: TMenuItem;
    PcMain: TPageControl;
    TsAssociations: TTabSheet;
    TsExplorer: TTabSheet;
    BtnClearIconCache: TButton;
    BtnClearThumbnailCache: TButton;
    CbExplorerShowEXIF: TCheckBox;
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
    CblEditorVirtuaCursor: TCheckBox;
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
    GbEXIF: TGroupBox;
    CbReadInfoFromExif: TCheckBox;
    CbSaveInfoToExif: TCheckBox;
    CbUpdateExifInfoInBackground: TCheckBox;
    N4: TMenuItem;
    SelectAll1: TMenuItem;
    DeselectAll1: TMenuItem;
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
    GbExplorerObjects: TGroupBox;
    CbExplorerShowHidden: TCheckBox;
    CbExplorerShowImages: TCheckBox;
    CbExplorerShowSimpleFiles: TCheckBox;
    CbExplorerShowFolders: TCheckBox;
    GbThumbnailOptions: TGroupBox;
    CbExplorerShowAttributes: TCheckBox;
    CbExplorerShowThumbsForFolders: TCheckBox;
    CbExplorerSaveThumbsForFolders: TCheckBox;
    CbExplorerShowThumbsForImages: TCheckBox;
    CbExplorerShowThumbsForVideo: TCheckBox;
    CbSmallToolBars: TCheckBox;
    GbAutoAdding: TGroupBox;
    CbSkipRAWImages: TCheckBox;
    EdSkipExtensions: TWatermarkedEdit;
    LbSkipExtensions: TLabel;
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
    procedure BtnClearIconCacheClick(Sender: TObject);
    procedure BtnClearThumbnailCacheClick(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
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
    FLoadedPages: array [0..6] of Boolean;
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
  I,
  Size: Integer;
  DisplayICCProfile: string;
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
    CbExplorerShowFolders.Checked := AppSettings.Readbool('Options', 'Explorer_ShowFolders', True);
    CbExplorerShowSimpleFiles.Checked := AppSettings.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
    CbExplorerShowImages.Checked := AppSettings.Readbool('Options', 'Explorer_ShowImageFiles', True);
    CbExplorerShowHidden.Checked := AppSettings.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
    CbExplorerShowAttributes.Checked := AppSettings.Readbool('Options', 'Explorer_ShowAttributes', True);
    CbExplorerShowThumbsForFolders.Checked := AppSettings.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
    CbExplorerSaveThumbsForFolders.Checked := AppSettings.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
    CbExplorerShowThumbsForImages.Checked := AppSettings.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
    CbExplorerShowThumbsForVideo.Checked := AppSettings.Readbool('Options', 'Explorer_ShowThumbnailsForVideo', True);
    CbExplorerShowEXIF.Checked := AppSettings.ReadBool('Options', 'ShowEXIFMarker', False);
    CbSmallToolBars.Checked := AppSettings.Readbool('Options', 'UseSmallToolBarButtons', False);

  end;
  if NewTab = 3 then
  begin
    CbViewerNextOnClick.Checked := AppSettings.Readbool('Options', 'NextOnClick', False);
    TrackBar1.Position := Min(Max(AppSettings.ReadInteger('Options', 'SlideShow_SlideSteps', 25), 1), 100);
    TrackBar2.Position := Min(Max(AppSettings.ReadInteger('Options', 'SlideShow_SlideDelay', 40), 1), 100);
    TrackBar4.Position := Min(Max(AppSettings.ReadInteger('Options', 'FullScreen_SlideDelay', 40), 1), 100);
    CbViewerUseCoolStretch.Checked := AppSettings.ReadboolW('Options', 'SlideShow_UseCoolStretch', True);
    TrackBar1Change(Sender);
    TrackBar2Change(Sender);
    TrackBar4Change(Sender);

    CbViewerFaceDetection.Checked := AppSettings.Readbool('Options', 'ViewerFaceDetection', True);

    CbDetectionSize.ItemIndex := 0;
    Size := AppSettings.ReadInteger('Options', 'FaceDetectionSize', 3);
    for I := 0 to CbDetectionSize.Items.Count - 1 do
      if Integer(CbDetectionSize.Items.Objects[I]) = Size then
        CbDetectionSize.ItemIndex := I;

    CbRedCyanStereo.Checked := AppSettings.ReadString('Options', 'StereoMode', '') <> '';

    DisplayICCProfile := AppSettings.ReadString('Options', 'DisplayICCProfileName', DEFAULT_ICC_DISPLAY_PROFILE);

    CbDisplayICCProfile.Items.Add(L('Don''t use ICC profile'));
    FillDisplayProfileList(CbDisplayICCProfile.Items);

    CbDisplayICCProfile.Value := DisplayICCProfile;
  end;
  if NewTab = 4 then
  begin
    CbAutoSavePasswordForSession.Checked := AppSettings.Readbool('Options', 'AutoSaveSessionPasswords', True);
    CbAutoSavePasswordInSettings.Checked := AppSettings.Readbool('Options', 'AutoSaveINIPasswords', False);
    SedBackupDays.Value := AppSettings.ReadInteger('Options', 'BackUpdays', 7);

    WebProxyUserName.Text := AppSettings.ReadString('Options', 'ProxyUser');
    WebProxyPassword.Text := AppSettings.ReadString('Options', 'ProxyPassword');
    CbUseProxyServer.Checked := AppSettings.ReadBool('Options', 'UseProxyServer', False);
    CbUseProxyServerClick(Self);
  end;

  if NewTab = 5 then
  begin

    CbListViewShowPreview.Checked := AppSettings.Readbool('Options', 'AllowPreview', True);
    CbListViewHotSelect.Checked := AppSettings.Readbool('Options', 'UseHotSelect', True);
    CblEditorVirtuaCursor.Checked := AppSettings.ReadBool('Editor', 'VirtualCursor', False);
    CbCheckLinksOnUpdate.Checked := AppSettings.ReadBool('Options', 'CheckUpdateLinks', False);

    CbDontAddSmallFiles.Checked := AppSettings.ReadBool('Options', 'DontAddSmallImages', True);
    SedMinWidth.Value := AppSettings.ReadInteger('Options', 'DontAddSmallImagesWidth', 64);
    SedMinHeight.Value := AppSettings.ReadInteger('Options', 'DontAddSmallImagesHeight', 64);
    SedMinWidth.Enabled := CbDontAddSmallFiles.Checked;
    SedMinHeight.Enabled := CbDontAddSmallFiles.Checked;

    CbReadInfoFromExif.Checked := AppSettings.Exif.ReadInfoFromExif;
    CbSaveInfoToExif.Checked := AppSettings.Exif.SaveInfoToExif;
    CbUpdateExifInfoInBackground.Checked := AppSettings.Exif.UpdateExifInfoInBackground;

    CbShowStatusBar.Checked := AppSettings.ReadBool('Options', 'ShowStatusBar', False);
    CbSmoothScrolling.Checked := AppSettings.ReadBool('Options', 'SmoothScrolling', True);

    CbSkipRAWImages.Checked := not AppSettings.ReadBool('Updater', 'AddRawFiles', False);
    EdSkipExtensions.Text := AppSettings.ReadString('Updater', 'SkipExtensions');
  end;

  if NewTab = 6 then
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
  for I := 0 to 6 do
    FLoadedPages[I] := False;
  LoadLanguage;
  FThemeList := TStringList.Create;
  CbCheckLinksOnUpdate.Enabled := not FolderView;

  PcMainChange(Self);

  WblMethod.Color := Theme.PanelColor;
  WblMethod.Font.Color := Theme.PanelFontColor;
  WlGetMoreStyles.Color := Theme.PanelColor;
  WlGetMoreStyles.Font.Color := Theme.PanelFontColor;
  WlDefaultJPEGOptions.Color := Theme.PanelColor;
  WlDefaultJPEGOptions.Font.Color := Theme.PanelFontColor;

  WblMethod.LoadFromResource('PASSWORD');

  WlAddPlayerExtension.LoadFromResource('SERIES_EXPAND');
  WlRemovePlayerExtension.LoadFromHIcon(Icons[DB_IC_DELETE_INFO]);
  WlSavePlayerChanges.LoadFromResource('CMD_OK');

end;

procedure TOptionsForm.FormDestroy(Sender: TObject);
begin
  F(FThemeList);
  F(FPlayerExtensions);
end;

procedure TOptionsForm.OkButtonClick(Sender: TObject);
var
  EventInfo: TEventValues;
begin
  AppSettings.ClearCache;

  if ReloadData then
  begin
    if MessageBoxDB(Handle, L('Refresh data in windows?'), L('Information'), TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) = ID_OK then
      CollectionEvents.DoIDEvent(Self, 0, [EventID_Param_Refresh_Window], EventInfo);

  end;

  if FLoadedPages[1] then
  begin
   //nothing to save
  end;

  if FLoadedPages[2] then
  begin
    AppSettings.WriteBool('Options', 'Explorer_ShowFolders', CbExplorerShowFolders.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowSimpleFiles', CbExplorerShowSimpleFiles.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowImageFiles', CbExplorerShowImages.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowHiddenFiles', CbExplorerShowHidden.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowAttributes', CbExplorerShowAttributes.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowThumbnailsForFolders', CbExplorerShowThumbsForFolders.Checked);
    AppSettings.WriteBool('Options', 'Explorer_SaveThumbnailsForFolders', CbExplorerSaveThumbsForFolders.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowThumbnailsForImages', CbExplorerShowThumbsForImages.Checked);
    AppSettings.WriteBool('Options', 'Explorer_ShowThumbnailsForVideo', CbExplorerShowThumbsForVideo.Checked);

    AppSettings.WriteBool('Options', 'ShowEXIFMarker', CbExplorerShowEXIF.Checked);
    AppSettings.WriteBool('Options', 'UseSmallToolBarButtons', CbSmallToolBars.Checked);
  end;

  if FLoadedPages[3] then
  begin
    AppSettings.WriteBool('Options', 'NextOnClick', CbViewerNextOnClick.Checked);
    AppSettings.WriteBoolW('Options', 'SlideShow_UseCoolStretch', CbViewerUseCoolStretch.Checked);
    AppSettings.WriteInteger('Options', 'SlideShow_SlideSteps', TrackBar1.Position);
    AppSettings.WriteInteger('Options', 'SlideShow_SlideDelay', TrackBar2.Position);
    AppSettings.WriteInteger('Options', 'FullScreen_SlideDelay', TrackBar4.Position);

    AppSettings.WriteBool('Options', 'ViewerFaceDetection', CbViewerFaceDetection.Checked);
    AppSettings.WriteInteger('Options', 'FaceDetectionSize', Integer(CbDetectionSize.Items.Objects[CbDetectionSize.ItemIndex]));
    AppSettings.WriteString('Options', 'StereoMode', IIF(CbRedCyanStereo.Checked, 'RedCyan', ''));

    AppSettings.WriteString('Options', 'DisplayICCProfileName', IIF(CbDisplayICCProfile.ItemIndex = 0, '-', CbDisplayICCProfile.Value));
  end;

  if FLoadedPages[4] then
  begin
    AppSettings.WriteBool('Options', 'AutoSaveSessionPasswords', CbAutoSavePasswordForSession.Checked);
    AppSettings.WriteBool('Options', 'AutoSaveINIPasswords', CbAutoSavePasswordInSettings.Checked);
    AppSettings.WriteInteger('Options', 'BackUpdays', SedBackupDays.Value);

    AppSettings.WriteString('Options', 'ProxyUser', WebProxyUserName.Text);
    AppSettings.WriteString('Options', 'ProxyPassword', WebProxyPassword.Text);
    AppSettings.WriteBool('Options', 'UseProxyServer', CbUseProxyServer.Checked);
  end;

  if FLoadedPages[5] then
  begin
    AppSettings.WriteBool('Options', 'AllowPreview', CbListViewShowPreview.Checked);

    AppSettings.WriteBool('Options', 'UseHotSelect', CbListViewHotSelect.Checked);
    AppSettings.WriteBool('Editor', 'VirtualCursor', CblEditorVirtuaCursor.Checked);
    AppSettings.WriteBool('Options', 'CheckUpdateLinks', CbCheckLinksOnUpdate.Checked);

    AppSettings.WriteBool('Options', 'DontAddSmallImages', CbDontAddSmallFiles.Checked);
    AppSettings.WriteInteger('Options', 'DontAddSmallImagesWidth', SedMinWidth.Value);
    AppSettings.WriteInteger('Options', 'DontAddSmallImagesHeight', SedMinHeight.Value);

    AppSettings.Exif.ReadInfoFromExif := CbReadInfoFromExif.Checked;
    AppSettings.Exif.SaveInfoToExif := CbSaveInfoToExif.Checked;
    AppSettings.Exif.UpdateExifInfoInBackground := CbUpdateExifInfoInBackground.Checked;

    AppSettings.WriteBool('Options', 'ShowStatusBar', CbShowStatusBar.Checked);
    AppSettings.WriteBool('Options', 'SmoothScrolling', CbSmoothScrolling.Checked);

    AppSettings.WriteBool('Options', 'AddRawFiles', not CbSkipRAWImages.Checked);
    AppSettings.WriteString('Updater', 'SkipExtensions', EdSkipExtensions.Text);
  end;

  if FLoadedPages[6] then
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
    TsSecurity.Caption := L('Security');
    TsGlobal.Caption := L('Global');
    TsPrograms.Caption := L('Programs');
    GbBackup.Caption := L('Backups');
    Dontusethisextension1.Caption := L('Don''t use this extension');
    Usethisprogramasdefault1.Caption := L('Use PhotoDB as default association');
    Usemenuitem1.Caption := L('Add menu item');
    CbListViewShowPreview.Caption := L('Show previews');
    GbExplorerObjects.Caption := L('Show object types');
    CbExplorerShowFolders.Caption := L('Folders');
    CbExplorerShowSimpleFiles.Caption := L('Simple files');
    CbExplorerShowImages.Caption := L('Images');
    CbExplorerShowHidden.Caption := L('Hidden files');
    GbThumbnailOptions.Caption := L('Preview options');
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

    BtnClearThumbnailCache.Caption := L('Clear previews cache');
    BtnClearIconCache.Caption := L('Clear icons cache');
    CbExplorerShowEXIF.Caption := L('Show EXIF marker');
    CbViewerNextOnClick.Caption := L('"Next" by click');
    CbListViewHotSelect.Caption := L('Use the selection by hover on the list');
    WlDefaultJPEGOptions.Text := L('Change default JPEG Options');
    CbShowStatusBar.Caption := L('Show status bar');
    CbSmoothScrolling.Caption := L('Smooth scrolling');
    BlBackupInterval.Caption := L('Create backup every') + ':';
    Label30.Caption := L('days');

    CblEditorVirtuaCursor.Caption := L('Virtual cursor to the Editor');
    Default1.Caption := L('Default');
    CbCheckLinksOnUpdate.Caption := L('Check changes of files and update links (may slow down program)');
    CbDontAddSmallFiles.Caption := L('Do not add files to collection if size less than') + ':';
    LbAddWidth.Caption := L('Width');
    LbAddHeight.Caption := L('Height');
    GbPasswords.Caption := L('Passwords');
    GbAutoAdding.Caption := L('Synchronization settings');
    CbSkipRAWImages.Caption := L('Skip RAW file types');
    LbSkipExtensions.Caption := L('Skip the following file masks (use ";" as separator)') + ':';
    EdSkipExtensions.WatermarkText := L('Skip the following file masks (use ";" as separator)');

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
      Ico := CopyIcon(Icons[DB_IC_SIMPLEFILE]);
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
  Associations := AppSettings.ReadKeys(cMediaAssociationsData);
  try
    for I := 0 to Associations.Count - 1 do
    begin
      Player := AppSettings.ReadString(cMediaAssociationsData + '\' + Associations[I], '');

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
  AppSettings.DeleteKey(cMediaAssociationsData);
  for Pair in FPlayerExtensions do
  begin
    Player := Pair.Value;
    AppSettings.WriteString(cMediaAssociationsData + '\' + Pair.Key, '', Player);
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

  CurrentStyle := AppSettings.ReadString('Style', 'FileName', DefaultThemeName);

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
  SessionPasswords.ClearSession;
end;

procedure TOptionsForm.BtnClearPasswordsInSettingsClick(Sender: TObject);
begin
  SessionPasswords.ClearINIPasswords;
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

procedure TOptionsForm.BtnApplyThemeClick(Sender: TObject);
var
  I: Integer;
  ShellExecuteInfo: TShellExecuteInfo;
begin
  for I := 0 to LbStyles.Items.Count - 1 do
    if LbStyles.Selected[I] then
    begin
      ProgramStatistics.StyleUsed;

      AppSettings.WriteString('Style', 'FileName', FThemeList[I]);
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
          FormManager.MarkApplicationAsClosed;
          Close;
          FormManager.CloseApp(Self);
        end;
      end;
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
      Ico := CopyIcon(Icons[DB_IC_SIMPLEFILE]);

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

procedure TOptionsForm.CbUseProxyServerClick(Sender: TObject);
begin
  WebProxyUserName.Enabled := CbUseProxyServer.Checked;
  WebProxyPassword.Enabled := CbUseProxyServer.Checked;
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
