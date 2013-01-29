unit ExplorerUnit;

interface

uses
  Generics.Collections,
  Generics.Defaults,
  System.Types,
  System.Math,
  System.SysUtils,
  System.SyncObjs,
  System.DateUtils,
  System.Classes,
  System.StrUtils,
  System.Win.ComObj,
  System.Win.Registry,
  Winapi.CommCtrl,
  Winapi.ActiveX,
  Winapi.ShellApi,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShlObj,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.ComCtrls,
  Vcl.Shell.ShellCtrls,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.Imaging.pngimage,
  Vcl.ExtCtrls,
  Vcl.ToolWin,
  Vcl.Buttons,
  Vcl.StdCtrls,
  Vcl.Clipbrd,
  Vcl.AppEvnts,
  Vcl.OleCtrls,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.Grids,
  Vcl.ValEdit,
  Data.DB,

  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Utils.ShellIcons,
  Dmitry.Utils.Network,
  Dmitry.Graphics.Types,
  Dmitry.Graphics.Utils,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.PathProviders,
  Dmitry.PathProviders.MyComputer,
  Dmitry.PathProviders.FileSystem,
  Dmitry.PathProviders.Network,
  Dmitry.Controls.Base,
  Dmitry.Controls.SaveWindowPos,
  Dmitry.Controls.Rating,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.WebLinkList,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.PathEditor,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.ScrollPanel,
  Dmitry.Controls.ImButton,

  PrintMainForm,
  uScript,
  UnitScripts,
  ExplorerTypes,
  uExplorerFolderImages,
  DBCMenu,
  UnitDBKernel,
  UnitINI,
  dolphin_db,
  UnitGroupsWork,
  UnitLinksSupport,
  UnitBitmapImageList,
  GraphicCrypt,
  UnitCrypting,
  DropSource,
  DragDropFile,
  DragDrop,
  DropTarget,
  CmpUnit,
  UnitCDMappingSupport,
  ShellContextMenu,
  ProgressActionUnit,
  CommonDBSupport,
  EasyListview,
  MPCommonUtilities,
  MPCommonObjects,
  UnitRefreshDBRecordsThread,
  UnitPropeccedFilesSupport,
  UnitCryptingImagesThread,
  wfsU,

  uShellIntegration,
  uDBCustomThread,
  uGroupTypes,
  uShellUtils,
  uGUIDUtils,
  uPrivateHelper,
  uVistaFuncs,
  uGOM,
  uLockedFileNotifications,
  UnitDBDeclare,
  UnitDBFileDialogs,
  uFormListView,
  uIconUtils,
  uBitmapUtils,
  uDBThread,
  UnitDBCommon,
  uCDMappingTypes,
  uResources,
  uListViewUtils,
  uAssociatedIcons,
  uLogger,
  uConstants,
  uTime,
  uDateUtils,
  uFastLoad,
  uDBPopupMenuInfo,
  uDBDrawing,
  uW7TaskBar,
  uMemory,
  uPNGUtils,
  uDBGraphicTypes,
  uGraphicUtils,
  uDBBaseTypes,
  uDBTypes,
  uRuntime,
  uDBUtils,
  uPathUtils,
  uSettings,
  uAssociations,
  uExplorerPersonsProvider,
  uExplorerGroupsProvider,
  uExplorerSearchProviders,
  uExplorerPortableDeviceProvider,
  uExplorerShelfProvider,
  uExplorerDateStackProviders,
  uTranslate,
  uVCLHelpers,
  uImageListUtils,
  PDB.uVCLRewriters,
  uActivationUtils,

  uPortableDeviceUtils,
  uShellNamespaceUtils,
  uManagerExplorer,
  uExplorerPastePIDLsThread,
  uPathProviderUtils,
  uPortableDeviceManager,
  uPortableClasses,
  uFaceDetection,

  uWebJSExternalContainer,
  WebJS_TLB,
  SHDocVw,
  MSHTML,
  uExifUtils,
  uExifInfo,
  uGeoLocation,
  uBrowserEmbedDraw,

  uThemesUtils,
  uPhotoShelf,
  uThreadTask,
  uInterfaces,
  uInternetUtils,

  VirtualTrees,
  uPathProvideTreeView,
  uDBInfoEditorUtils,
  uFormInterfaces,

  uTransparentEncryption,
  uMediaEncryption,
  uIImageViewer,
  uImageViewer,
  uPeopleSupport,
  uFormSelectPerson,
  uEXIFDisplayControl,
  uProgramStatInfo,
  uMonthCalendar;

const
  RefreshListViewInterval = 50;

type
  TPageControl = class(TPageControlNoBorder);
  TMonthCalendar = class(TMonthCalendarEx);
  TValueListEditor = class(TEXIFDisplayControl);

type
  TExplorerForm = class(TCustomExplorerForm, IWebJSExternal, IEncryptErrorHandlerForm, ICurrentImageSource, IDirectoryWatcher)
    SizeImageList: TImageList;
    PmItemPopup: TPopupActionBar;
    SlideShow1: TMenuItem;
    Properties1: TMenuItem;
    Shell1: TMenuItem;
    Copy1: TMenuItem;
    Rename1: TMenuItem;
    Delete1: TMenuItem;
    DBitem1: TMenuItem;
    SplLeftPanel: TSplitter;
    PmListPopup: TPopupActionBar;
    Addfolder1: TMenuItem;
    SelectAll1: TMenuItem;
    AddFile1: TMenuItem;
    HintTimer: TTimer;
    Open1: TMenuItem;
    N1: TMenuItem;
    Refresh1: TMenuItem;
    New1: TMenuItem;
    Directory1: TMenuItem;
    MainPanel: TPanel;
    PropertyPanel: TPanel;
    Refresh2: TMenuItem;
    OpenInNewWindow1: TMenuItem;
    Exit2: TMenuItem;
    N2: TMenuItem;
    MakeNew1: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    ShowUpdater1: TMenuItem;
    AeMain: TApplicationEvents;
    NewWindow1: TMenuItem;
    Paste1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Cut2: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    PmTreeView: TPopupActionBar;
    MiTreeViewOpenInNewWindow: TMenuItem;
    ToolBarNormalImageList: TImageList;
    PopupMenuBack: TPopupActionBar;
    PopupMenuForward: TPopupActionBar;
    DragTimer: TTimer;
    ToolBarDisabledImageList: TImageList;
    N10: TMenuItem;
    CryptFile1: TMenuItem;
    ResetPassword1: TMenuItem;
    EnterPassword1: TMenuItem;
    Convert1: TMenuItem;
    Resize1: TMenuItem;
    N12: TMenuItem;
    Rotate1: TMenuItem;
    RotateCCW1: TMenuItem;
    RotateCW1: TMenuItem;
    Rotateon1801: TMenuItem;
    SetasDesktopWallpaper1: TMenuItem;
    Stretch1: TMenuItem;
    Center1: TMenuItem;
    Tile1: TMenuItem;
    RefreshID1: TMenuItem;
    DropFileTargetMain: TDropFileTarget;
    DropFileSourceMain: TDropFileSource;
    DragImageList: TImageList;
    DropFileTargetFake: TDropFileTarget;
    HelpTimer: TTimer;
    ImageEditor2: TMenuItem;
    N13: TMenuItem;
    Othertasks1: TMenuItem;
    ExportImages1: TMenuItem;
    Print1: TMenuItem;
    PmLinkOptions: TPopupActionBar;
    OpeninNewWindow2: TMenuItem;
    Open2: TMenuItem;
    TextFile1: TMenuItem;
    Directory2: TMenuItem;
    TextFile2: TMenuItem;
    Copywithfolder1: TMenuItem;
    PmDragMode: TPopupActionBar;
    Copy4: TMenuItem;
    Move1: TMenuItem;
    N15: TMenuItem;
    Cancel1: TMenuItem;
    SelectTimer: TTimer;
    N17: TMenuItem;
    MiTreeViewRefresh: TMenuItem;
    ScriptMainMenu: TMainMenu;
    CloseTimer: TTimer;
    N19: TMenuItem;
    Sortby1: TMenuItem;
    FileName1: TMenuItem;
    Size1: TMenuItem;
    Modified1: TMenuItem;
    Type1: TMenuItem;
    Rating1: TMenuItem;
    SetFilter1: TMenuItem;
    MakeFolderViewer1: TMenuItem;
    Number1: TMenuItem;
    RatingPopupMenu: TPopupActionBar;
    N00: TMenuItem;
    N01: TMenuItem;
    N02: TMenuItem;
    N03: TMenuItem;
    N04: TMenuItem;
    N05: TMenuItem;
    ScrollBox1: TScrollPanel;
    TypeLabel: TLabel;
    TasksLabel: TLabel;
    SlideShowLink: TWebLink;
    SizeLabel: TLabel;
    ShellLink: TWebLink;
    RenameLink: TWebLink;
    RefreshLink: TWebLink;
    RatingLabel: TLabel;
    PropertiesLink: TWebLink;
    PrintLink: TWebLink;
    OtherPlacesLabel: TLabel;
    NameLabel: TLabel;
    MyPicturesLink: TWebLink;
    MyDocumentsLink: TWebLink;
    MyComputerLink: TWebLink;
    MoveToLink: TWebLink;
    ImageEditorLink: TWebLink;
    ImPreview: TImage;
    IDLabel: TLabel;
    DimensionsLabel: TLabel;
    DesktopLink: TWebLink;
    DeleteLink: TWebLink;
    CopyToLink: TWebLink;
    AddLink: TWebLink;
    AccessLabel: TLabel;
    PmListViewType: TPopupActionBar;
    Thumbnails1: TMenuItem;
    Icons1: TMenuItem;
    List1: TMenuItem;
    SmallIcons1: TMenuItem;
    Tile2: TMenuItem;
    Grid1: TMenuItem;
    BigIconsImageList: TImageList;
    SmallIconsImageList: TImageList;
    MakeFolderViewer2: TMenuItem;
    BigImagesTimer: TTimer;
    Nosorting1: TMenuItem;
    StenoGraphia1: TMenuItem;
    AddHiddenInfo1: TMenuItem;
    ExtractHiddenInfo1: TMenuItem;
    CoolBarTop: TCoolBar;
    ToolBarMain: TToolBar;
    TbBack: TToolButton;
    TbForward: TToolButton;
    TbUp: TToolButton;
    ToolButton4: TToolButton;
    TbCut: TToolButton;
    TbCopy: TToolButton;
    TbPaste: TToolButton;
    ToolButton17: TToolButton;
    TbDelete: TToolButton;
    ToolButton10: TToolButton;
    ToolButtonView: TToolButton;
    ToolButton11: TToolButton;
    TbZoomOut: TToolButton;
    TbZoomIn: TToolButton;
    TbSearch: TToolButton;
    TbOptions: TToolButton;
    ToolButton20: TToolButton;
    PopupMenuZoomDropDown: TPopupActionBar;
    MapCD1: TMenuItem;
    LsMain: TLoadingSign;
    AsEXIF1: TMenuItem;
    N3: TMenuItem;
    PnNavigation: TPanel;
    PePath: TPathEditor;
    StAddress: TStaticText;
    BvSeparatorAddress: TBevel;
    BvSeparatorSearch: TBevel;
    BvSeparatorLeftPanel: TBevel;
    SearchImageList: TImageList;
    slSearch: TSplitter;
    SbSearchMode: TSpeedButton;
    WedSearch: TWatermarkedEdit;
    SbDoSearch: TSpeedButton;
    PnSearch: TPanel;
    PnSearchEditPlace: TPanel;
    PmSearchMode: TPopupActionBar;
    ImSearchMode: TImageList;
    Searchfiles1: TMenuItem;
    Searchincollection1: TMenuItem;
    PnContent: TPanel;
    PnFilter: TPanel;
    WedFilter: TWatermarkedEdit;
    LbFilter: TLabel;
    ImbCloseFilter: TImButton;
    LbFilterInfo: TLabel;
    CbFilterMatchCase: TCheckBox;
    ImFilterWarning: TImage;
    SearchfileswithEXIF1: TMenuItem;
    ImPathDropDownMenu: TImageList;
    EncryptLink: TWebLink;
    WlCreateObject: TWebLink;
    PmPathMenu: TPopupActionBar;
    MiCopyAddress: TMenuItem;
    MiEditAddress: TMenuItem;
    ImageTasksLabel: TLabel;
    WlResize: TWebLink;
    WlConvert: TWebLink;
    WlCrop: TWebLink;
    WlImportPictures: TWebLink;
    MiImportImages: TMenuItem;
    PnInfo: TPanel;
    WlLearnMoreLink: TWebLink;
    SbCloseHelp: TSpeedButton;
    PnRight: TPanel;
    SplRightPanel: TSplitter;
    PnGeoTop: TPanel;
    WlGeoLocation: TWebLink;
    WlSaveLocation: TWebLink;
    WlPanoramio: TWebLink;
    PnGeoSearch: TPanel;
    WedGeoSearch: TWatermarkedEdit;
    SbDoSearchLocation: TSpeedButton;
    MiShelf: TMenuItem;
    PnShelf: TPanel;
    WlGoToShelf: TWebLink;
    WlClear: TWebLink;
    WlShare: TWebLink;
    TmrDelayedStart: TTimer;
    TmrCheckItemVisibility: TTimer;
    MiShare: TMenuItem;
    PcTasks: TPageControl;
    TsTasks: TTabSheet;
    TsExplorer: TTabSheet;
    TsInfo: TTabSheet;
    TsEXIF: TTabSheet;
    VleExif: TValueListEditor;
    ImGroups: TImageList;
    WlDeleteLocation: TWebLink;
    MiDisplayOnMap: TMenuItem;
    CoolBarBottom: TCoolBar;
    ToolBarBottom: TToolBar;
    TbbPlay: TToolButton;
    PcRightPreview: TPageControl;
    TsGeoLocation: TTabSheet;
    TsMediaPreview: TTabSheet;
    TsDetailedSearch: TTabSheet;
    TbbEncrypt: TToolButton;
    TbbResize: TToolButton;
    TbbCrop: TToolButton;
    TbbPrint: TToolButton;
    TbbEditor: TToolButton;
    TbbGeo: TToolButton;
    TbbRename: TToolButton;
    TbbProperties: TToolButton;
    TbbShare: TToolButton;
    ImlBottomToolBar: TImageList;
    TbbConvert: TToolButton;
    TbBottomFileActionsSeparator: TToolButton;
    SbCloseRightPanel: TSpeedButton;
    ToolBarPreview: TToolBar;
    TbPreviewPrevious: TToolButton;
    TbPreviewNext: TToolButton;
    TbPreviewNavigationSeparator: TToolButton;
    TbPreviewRotateCW: TToolButton;
    TbPreviewRotateCCW: TToolButton;
    TbPreviewRatingSeparator: TToolButton;
    TbPreviewRating: TToolButton;
    TbPreviewRotateSeparator: TToolButton;
    TbPreviewOpen: TToolButton;
    TbPreview: TToolButton;
    ImExtendedSearchGroups: TImageList;
    BvGroups: TBevel;
    PnSelectDatePopup: TPanel;
    McDateSelectPopup: TMonthCalendar;
    BtnSelectDatePopup: TButton;
    BtnSelectDatePopupReset: TButton;
    RtPopupRating: TRating;
    PmSelectPerson: TPopupActionBar;
    MiPreviousSelections: TMenuItem;
    MiPreviousSelectionsSeparator: TMenuItem;
    MiOtherPersons: TMenuItem;
    ImFacePopup: TImageList;
    ImExtendedSearchPersons: TImageList;
    PmESSorting: TPopupActionBar;
    MiESSortByID: TMenuItem;
    MiESSortByName: TMenuItem;
    MiESSortByDate: TMenuItem;
    MiESSortByRating: TMenuItem;
    MiESSortByFileSize: TMenuItem;
    MiESSortByImageSize: TMenuItem;
    PmESPerson: TPopupActionBar;
    MiESPersonFindPictures: TMenuItem;
    N4: TMenuItem;
    MiESPersonRemoveFromList: TMenuItem;
    N9: TMenuItem;
    MiESPersonProperties: TMenuItem;
    PmESGroup: TPopupActionBar;
    MiESGroupFindPictures: TMenuItem;
    MenuItem2: TMenuItem;
    MiESGroupRemove: TMenuItem;
    MenuItem4: TMenuItem;
    MiESGroupProperties: TMenuItem;
    TbbOpenDirectory: TToolButton;
    PmESOptions: TPopupActionBar;
    MiESShowHidden: TMenuItem;
    MiESShowPrivate: TMenuItem;
    TmrSearchResultsCount: TTimer;
    PnInfoContainer: TPanel;
    BtnSaveInfo: TButton;
    MemComments: TMemo;
    LbEditComments: TLabel;
    MemKeyWords: TMemo;
    LbEditKeywords: TLabel;
    WllGroups: TWebLinkList;
    DteTime: TDateTimePicker;
    DteDate: TDateTimePicker;
    ReRating: TRating;
    ImHistogramm: TImage;
    LbHistogramImage: TLabel;
    PnESContainer: TPanel;
    PnExtendedSearch: TPanel;
    SbExtendedSearchMode: TSpeedButton;
    SbExtendedSearchStart: TSpeedButton;
    PnExtendedSearchEditPlace: TPanel;
    EdExtendedSearchText: TWatermarkedEdit;
    WlSearchRatingFrom: TWebLink;
    WlSearchRatingFromValue: TWebLink;
    WlSearchRatingToValue: TWebLink;
    WlSearchRatingTo: TWebLink;
    WllExtendedSearchPersons: TWebLinkList;
    BvRating: TBevel;
    BvPersons: TBevel;
    WllExtendedSearchGroups: TWebLinkList;
    WlExtendedSearchDateFrom: TWebLink;
    WlExtendedSearchDateTo: TWebLink;
    WlExtendedSearchSortDescending: TWebLink;
    WlExtendedSearchSortBy: TWebLink;
    WlExtendedSearchOptions: TWebLink;
    BtnSearch: TButton;
    PnListView: TPanel;
    StatusBarMain: TStatusBar;
    TmHideStatusBar: TTimer;
    PnResetFilter: TPanel;
    WlResetFilter: TWebLink;
    PmInfoGroup: TPopupActionBar;
    MiInfoGroupFind: TMenuItem;
    MiInfoGroupSplitter1: TMenuItem;
    MiInfoGroupRemove: TMenuItem;
    MiInfoGroupSplitter2: TMenuItem;
    MiInfoGroupProperties: TMenuItem;
    WlFaceCount: TWebLink;
    LsDetectingFaces: TLoadingSign;
    WllPersonsPreview: TWebLinkList;
    PmPreviewPersonItem: TPopupActionBar;
    MiPreviewPersonFind: TMenuItem;
    MenuItem3: TMenuItem;
    MiPreviewPersonUpdateAvatar: TMenuItem;
    MenuItem6: TMenuItem;
    MiPreviewPersonProperties: TMenuItem;
    PnRightPreview: TPanel;
    ImlPreview: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure SlideShow1Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure PmItemPopupPopup(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure AddFile1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Edited(Sender: TObject; Item: TEasyItem; var S: String);
    procedure HintTimerTimer(Sender: TObject);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SetInfoToItem(info : TDBPopupMenuInfoRecord; FileGUID: TGUID; Loaded: Boolean = False);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SplLeftPanelCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure ListView1SelectItem(Sender: TObject; Item: TEasyItem; Selected: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SelectAll1Click(Sender: TObject);
    procedure Refresh2Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure Addfolder1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure HistoryChanged(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListView1Exit(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure MakeNewFolder1Click(Sender: TObject);
    procedure OpenInNewWindow1Click(Sender: TObject);
    procedure ShowUpdater1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure Back1Click(Sender: TObject);
    procedure Forward1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure DeleteIndex1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewWindow1Click(Sender: TObject);
    procedure PmListPopupPopup(Sender: TObject);
    procedure CutClick(Sender: TObject);
    procedure ImPreviewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure PropertyPanelResize(Sender: TObject);
    procedure ScriptExecuted(Sender: TObject);
    procedure CopyToLinkClick(Sender: TObject);
    procedure MoveToLinkClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure ImPreviewDblClick(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure DBManager1Click(Sender: TObject);
    procedure SetSelected(NewSelected: TEasyItem);
    procedure PropertiesLinkClick(Sender: TObject);
    procedure SlideShowLinkClick(Sender: TObject);
    procedure ShowOnlyCommon1Click(Sender: TObject);
    procedure ShowPrivate1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure MiTreeViewOpenInNewWindowClick(Sender: TObject);
    procedure AddLinkClick(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure RefreshLinkClick(Sender: TObject);
    procedure JumpHistoryClick(Sender: TObject);
    procedure DragTimerTimer(Sender: TObject);
    procedure DragEnter(Sender: TObject);
    procedure DragLeave(Sender: TObject);
    procedure Activation1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure ContactWithAuthor1Click(Sender: TObject);
    procedure ResetPassword1Click(Sender: TObject);
    procedure CryptFile1Click(Sender: TObject);
    procedure EnterPassword1Click(Sender: TObject);
    procedure Resize1Click(Sender: TObject);
    procedure Convert1Click(Sender: TObject);
    procedure Stretch1Click(Sender: TObject);
    procedure Center1Click(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure RotateCCW1Click(Sender: TObject);
    procedure RotateCW1Click(Sender: TObject);
    procedure Rotateon1801Click(Sender: TObject);
    procedure RefreshID1Click(Sender: TObject);
    procedure DropFileTargetMainDrop(Sender: TObject; ShiftState: TShiftState;  Point: TPoint; var Effect: Integer);
    procedure DropFileTargetMainEnter(Sender: TObject;  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure DropFileTargetMainLeave(Sender: TObject);
    procedure HelpTimerTimer(Sender: TObject);
    procedure Help1NextClick(Sender: TObject);
    procedure Help1CloseClick(Sender : TObject; var CanClose : Boolean);
    procedure MyPicturesLinkClick(Sender: TObject);
    procedure MyDocumentsLinkClick(Sender: TObject);
    procedure MyComputerLinkClick(Sender: TObject);
    procedure DesktopLinkClick(Sender: TObject);
    procedure ImageEditor1Click(Sender: TObject);
    procedure ImageEditor2Click(Sender: TObject);
    procedure ImageEditorLinkClick(Sender: TObject);
    procedure ExportImages1Click(Sender: TObject);
    procedure PrintLinkClick(Sender: TObject);
    procedure MyPicturesLinkContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Open2Click(Sender: TObject);
    procedure OpeninNewWindow2Click(Sender: TObject);
    procedure TextFile2Click(Sender: TObject);
    procedure GetPhotosClick(Sender: TObject);
    procedure GetPhotosFromDrive1Click(Sender: TObject);
    procedure Copywithfolder1Click(Sender: TObject);
    procedure Copy4Click(Sender: TObject);
    procedure SelectTimerTimer(Sender: TObject);
    procedure CloseWindow(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    procedure FileName1Click(Sender: TObject);
    procedure SetFilter1Click(Sender: TObject);
    procedure MakeFolderViewer1Click(Sender: TObject);
    procedure EasyListview2KeyAction(Sender: TCustomEasyListview;
      var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListview1ItemEdited(Sender: TCustomEasyListview;
      Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure ListView1Resize(Sender: TObject);
    procedure ListViewOnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure N05Click(Sender: TObject);
    procedure EasyListview1DblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
      ShiftState: TShiftState; var Handled: Boolean);
    procedure EasyListview1ItemThumbnailDraw(Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
        ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure EasyListview1ItemSelectionChanged(Sender: TCustomEasyListview; Item: TEasyItem);
    procedure ScrollBox1Reallign(Sender: TObject);
    procedure BackGround(Sender: TObject; x, y, w, h: integer; Bitmap: TBitmap);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);
    procedure EasyListview1ItemImageDraw(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
      const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure EasyListview1ItemImageDrawIsCustom(Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
     var IsCustom: Boolean);
    procedure EasyListview1ItemImageGetSize(Sender: TCustomEasyListview;
     Item: TEasyItem; Column: TEasyColumn; var ImageWidth, ImageHeight: Integer);
    function ListViewTypeToSize(ListViewType : Integer) : Integer;
    procedure SmallIcons1Click(Sender: TObject);
    procedure Icons1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure Tile2Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure ToolButtonViewClick(Sender: TObject);
    procedure Thumbnails1Click(Sender: TObject);
    procedure MakeFolderViewer2Click(Sender: TObject);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure AddHiddenInfo1Click(Sender: TObject);
    procedure ExtractHiddenInfo1Click(Sender: TObject);
    procedure TbZoomOutClick(Sender: TObject);
    procedure TbZoomInClick(Sender: TObject);
    procedure TbStopClick(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure MapCD1Click(Sender: TObject);
    procedure ToolBarMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure AsEXIF1Click(Sender: TObject);
    procedure PePathChange(Sender: TObject);
    procedure PePathUpdateItem(Sender: TObject; PathPart: TPathItem);
    procedure PePathGetSystemIcon(Sender: TPathEditor; IconType: string; var Image: TPathImage);
    procedure SbDoSearchClick(Sender: TObject);
    procedure LoadSearchMode(SearchMode: Integer);
    procedure Searchfiles1Click(Sender: TObject);
    procedure Searchincollection1Click(Sender: TObject);
    procedure SbSearchModeClick(Sender: TObject);
    procedure PmSearchModePopup(Sender: TObject);
    procedure ImbCloseFilterClick(Sender: TObject);
    procedure WedFilterChange(Sender: TObject);
    procedure WedSearchKeyPress(Sender: TObject; var Key: Char);
    procedure WedFilterKeyPress(Sender: TObject; var Key: Char);
    procedure SearchfileswithEXIF1Click(Sender: TObject);
    procedure slSearchCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure PopupMenuForwardPopup(Sender: TObject);
    procedure PopupMenuBackPopup(Sender: TObject);
    procedure EncryptLinkClick(Sender: TObject);
    procedure PePathGetItemIconEvent(Sender: TPathEditor; Item: TPathItem);
    procedure WlCreateObjectClick(Sender: TObject);
    procedure TbDeleteClick(Sender: TObject);
    procedure PePathImageContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure PePathContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure MiCopyAddressClick(Sender: TObject);
    procedure MiEditAddressClick(Sender: TObject);
    procedure WlCropClick(Sender: TObject);
    procedure WlImportPicturesClick(Sender: TObject);
    procedure WlLearnMoreLinkClick(Sender: TObject);
    procedure PnInfoResize(Sender: TObject);
    procedure SbCloseHelpClick(Sender: TObject);
    procedure SbCloseRightPanelClick(Sender: TObject);
    procedure WlGeoLocationClick(Sender: TObject);
    procedure WbGeoLocationExit(Sender: TObject);
    procedure WlPanoramioClick(Sender: TObject);
    procedure SbDoSearchLocationClick(Sender: TObject);
    procedure WlSaveLocationClick(Sender: TObject);
    procedure WedGeoSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure MiShelfClick(Sender: TObject);
    procedure WlGoToShelfClick(Sender: TObject);
    procedure WlClearClick(Sender: TObject);
    procedure TmrDelayedStartTimer(Sender: TObject);
    procedure WlShareClick(Sender: TObject);
    procedure TmrCheckItemVisibilityTimer(Sender: TObject);
    procedure TbBackMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TbForwardMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PcTasksChange(Sender: TObject);
    procedure TsInfoResize(Sender: TObject);
    procedure MemKeyWordsEnter(Sender: TObject);
    procedure MemCommentsEnter(Sender: TObject);
    procedure DteTimeEnter(Sender: TObject);
    procedure BtnSaveInfoClick(Sender: TObject);
    procedure ReRatingMouseDown(Sender: TObject);
    procedure ReRatingChange(Sender: TObject);
    procedure DteDateChange(Sender: TObject);
    procedure DteTimeChange(Sender: TObject);
    procedure MemKeyWordsChange(Sender: TObject);
    procedure MemCommentsChange(Sender: TObject);
    procedure WlDeleteLocationClick(Sender: TObject);
    procedure MiDisplayOnMapClick(Sender: TObject);
    procedure MiTreeViewRefreshClick(Sender: TObject);
    procedure TsInfoShow(Sender: TObject);
    procedure PcRightPreviewChange(Sender: TObject);
    procedure TsMediaPreviewResize(Sender: TObject);
    procedure TbPreviewPreviousClick(Sender: TObject);
    procedure TbPreviewRotateCWClick(Sender: TObject);
    procedure TbPreviewRotateCCWClick(Sender: TObject);
    procedure TbPreviewClick(Sender: TObject);
    procedure TbPreviewNextClick(Sender: TObject);
    procedure WedSearchEnter(Sender: TObject);
    procedure TsDetailedSearchResize(Sender: TObject);
    procedure WlExtendedSearchDateFromClick(Sender: TObject);
    procedure BtnSelectDatePopupClick(Sender: TObject);
    procedure WlSearchRatingFromClick(Sender: TObject);
    procedure WlSearchRatingToClick(Sender: TObject);
    procedure RtPopupRatingRating(Sender: TObject; Rating: Integer);
    procedure PmSelectPersonPopup(Sender: TObject);
    procedure MiOtherPersonsClick(Sender: TObject);
    procedure WlExtendedSearchSortDescendingClick(Sender: TObject);
    procedure WlExtendedSearchSortByClick(Sender: TObject);
    procedure MiESSortByImageSizeClick(Sender: TObject);
    procedure MiESPersonRemoveFromListClick(Sender: TObject);
    procedure MiESPersonFindPicturesClick(Sender: TObject);
    procedure MiESPersonPropertiesClick(Sender: TObject);
    procedure MiESGroupFindPicturesClick(Sender: TObject);
    procedure MiESGroupRemoveClick(Sender: TObject);
    procedure MiESGroupPropertiesClick(Sender: TObject);
    procedure TbSearchClick(Sender: TObject);
    procedure McDateSelectPopupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TbbOpenDirectoryClick(Sender: TObject);
    procedure PmESSortingPopup(Sender: TObject);
    procedure WlExtendedSearchOptionsClick(Sender: TObject);
    procedure WlExtendedSearchOptionsContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    procedure MiESShowHiddenClick(Sender: TObject);
    procedure MiESShowPrivateClick(Sender: TObject);
    procedure PmESOptionsPopup(Sender: TObject);
    procedure TmrSearchResultsCountTimer(Sender: TObject);
    procedure TmHideStatusBarTimer(Sender: TObject);
    procedure WlResetFilterClick(Sender: TObject);
    procedure PnResetFilterResize(Sender: TObject);
    procedure CoolBarBottomResize(Sender: TObject);
    procedure VleExifDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure MiInfoGroupPropertiesClick(Sender: TObject);
    procedure MiInfoGroupFindClick(Sender: TObject);
    procedure MiInfoGroupRemoveClick(Sender: TObject);
    procedure MiPreviewPersonFindClick(Sender: TObject);
    procedure MiPreviewPersonPropertiesClick(Sender: TObject);
    procedure MiPreviewPersonUpdateAvatarClick(Sender: TObject);
    procedure TbPreviewRatingClick(Sender: TObject);
    procedure MainPanelResize(Sender: TObject);
    procedure SplRightPanelCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure SplLeftPanelMoved(Sender: TObject);
  private
    { Private declarations }
    FBitmapImageList: TBitmapImageList;
    FSearchMode: Integer;
    NewFileName: string;
    NewFileNameGUID: TGUID;
    FormLoadEnd: Boolean;
    FPictureSize: Integer;
    ListView: Integer;
    ElvMain: TEasyListView;
    AScript: TScript;
    MainMenuScript: string;
    RefreshIDList: TStrings;
    Rdown: Boolean;
    Outdrag: Boolean;
    Fpopupdown: Boolean;
    SelfDraging: Boolean;
    FDblClicked: Boolean;
    FSelectedInfo: TSelectedInfo;
    FStatusProgress: TProgressBar;
    FFilesInfo: TExplorerFileInfos;
    FCurrentPath: string;
    FCurrentTypePath: Integer;
    LockDrawIcon: Boolean;
    MouseDowned: Boolean;
    PopupHandled: Boolean;
    LastMouseItem, ItemWithHint: TEasyItem;
    LastListViewSelected: TEasyItem;
    FListDragItems: array of TEasyItem;
    ItemByMouseDown: Boolean;
    ItemSelectedByMouseDown: Boolean;
    NotSetOldPath: Boolean;
    FHistory: TStringsHistoryW;
    FOldPatch: string;
    FOldPatchType: Integer;
    FFilesToDrag: TArStrings;
    FDBCanDrag: Boolean;
    FDBCanDragW: Boolean;
    FDBDragPoint: TPoint;
    UpdatingList: Boolean;
    GlobalLock: Boolean;
    LastShift: TShiftState;
    LastListViewSelCount: Integer;
    ItemsDeselected: Boolean;
    FPopupMenuWasActiveOnMouseDown: Boolean;
    IsReallignInfo: Boolean;
    FWasDragAndDrop: Boolean;
    RenameResult: Boolean;
    FChangeHistoryOnChPath: Boolean;
    WindowsMenuTickCount: Cardinal;
    UserLinks: array of TWebLink;
    FPlaces: TPlaceFolderArray;
    DragFilesPopup: TStrings;
    Lock: Boolean;
    SlashHandled: Boolean;
    DefaultSort: Integer;
    DirectoryWatcher: TWachDirectoryClass;
    FShellTreeView: TPathProvideTreeView;
    FGoToLastSavedPath: Boolean;
    FW7TaskBar: ITaskbarList3;
    FHistoryPathList: TArExplorerPath;
    FUpdateItemList: TList;
    FItemUpdateTimer: TTimer;
    FItemUpdateLastTime: Cardinal;
    FSelectedItem: TEasyItem;
    FCanPasteFromClipboard: Boolean;
    FNextClipboardViewer: HWnd;
    FIsFirstShow: Boolean;
    NoLockListView: Boolean;
    FGeoHTMLWindow: IHTMLWindow2;
    FIsPanaramio: Boolean;
    FMapLocationLat: Double;
    FMapLocationLng: Double;
    FIsMapLoaded: Boolean;
    FGeoLocationMapReady: Boolean;
    FWebBorwserFactory: IElementBehaviorFactory;
    FWebJSContainer: TWebJSExternalContainer;
    FWbGeoLocation: TWebBrowser;
    FWebBrowserJSMessage: UINT;
    FEditorInfo: TExplorerFileInfos;
    FReloadGroupsMessage: UINT;
    FReloadESGroupsMessage: UINT;
    FReloadRSPersonsMessage: UINT;

    FActiveLeftTab: TExplorerLeftTab;
    FLeftTabs: set of TExplorerLeftTab;

    FActiveRightTab: TExplorerRightTab;
    FRightTabs: set of TExplorerRightTab;

    FPngNoHIstogram: TPNGImage;
    FShowAttributes: Boolean;
    FShowEXIFAttributes: Boolean;
    FImageViewer: IImageViewer;

    FExtendedSearchParams: TDatabaseSearchParameters;
    FExtendedSearchPersons: TList<TPerson>;
    FShowStatusBar: Boolean;

    FOldWidth: Integer;
    IsResizePreivew: Boolean;

    procedure CopyFilesToClipboard(IsCutAction: Boolean = False);
    procedure SetNewPath(Path: string; Explorer: Boolean);
    procedure Reload;
    function GetCurrentPathW: TExplorerPath;
    function UpdatingNow(FileName: string): Boolean;
    function CanUp: Boolean;
    function SelCount: Integer;
    function SelectedIndex: Integer;
    function GetSelectedType: Integer;
    function CanCopySelection: Boolean;
    function GetPath: string;
    function GetPathByIndex(Index: Integer): string;
    function GetSelectedFiles: TArrayOfString;
    function CanPasteInSelection: Boolean;
    function ShowPrivate: Boolean;
    procedure ReallignToolInfo;
    function GetPathPartName(PP: TPathItem): string;
    procedure ReallignInfo;
    procedure PasteFromClipboard;
    function HintRealA(Info: TDBPopupMenuInfoRecord): Boolean;
    function GetCurrentPopUpMenuInfo(Item: TEasyItem; OnlySelected: Boolean = False): TExplorerFileInfos;
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure RefreshItem(Number: Integer; UpdateDB: Boolean);
    procedure RefreshItemByID(ID: Integer);
    procedure RefreshItemByName(Name: string; UpdateDB: Boolean);
    procedure DeleteItemWithIndex(Index: Integer);
    procedure DeleteFiles(ToRecycle: Boolean);
    function ItemIndexToMenuIndex(Index: Integer): Integer;
    function MenuIndexToItemIndex(Index: Integer): Integer;
    function GetView: Integer;
    procedure ClearList;
    procedure InitSearch;
    function ListView1Selected: TEasyItem;
    function ItemAtPos(X, Y: Integer): TEasyItem;
    procedure LockItems;
    procedure UnLockItems;
    procedure ReadPlaces;
    procedure UserDefinedPlaceClick(Sender: TObject);
    procedure UserDefinedPlaceContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DoSelectItem;
    procedure LoadIcons;
    procedure KernelEventCallBack(ID: Integer; Params: TEventFields; Value: TEventValues);
    function GetMyComputer: string;
    function GetSecondStepHelp: string;
    function GetViewInfo: TExplorerViewInfo;
    procedure SetView(const Value: Integer);
    function GetItemsCount: Integer;
    function GetIsExplorerTreeViewVisible: Boolean;
    function GetW7TaskBar: ITaskbarList3;
    property SecondStepHelp: string read GetSecondStepHelp;
    function GetPathDescription(Path: string; FileType: Integer): string;
    procedure EasyListview1ItemPaintText(Sender: TCustomEasyListview; Item: TEasyItem; Position: Integer; ACanvas: TCanvas);
    procedure PortableEventsCallBack(EventType: TPortableEventType; DeviceID: string; ItemKey: string; ItemPath: string);
    procedure RestoreDragSelectedItems;

    procedure ShowLastActiveLeftTab(Tab: TExplorerLeftTab);
    procedure ShowActiveLeftTab(Tab: TExplorerLeftTab);
    procedure ShowLeftTabIfWasActive(Tab: TExplorerLeftTab);
    procedure ApplyLeftTabs;

    procedure ShowLastActiveRightTab(Tab: TExplorerRightTab);
    procedure ShowActiveRightTab(Tab: TExplorerRightTab);
    procedure ApplyRightTabs;

    procedure InitInfoEditor(InitTab: Boolean);
    procedure DisableInfoEditor;
    procedure InitEditGroups;
    procedure GroupClick(Sender: TObject);
    procedure ReallignEditBoxes;

    procedure PathTreeViewChange(Sender: TCustomVirtualDrawTree; PathItem: TPathItem);
    procedure PathTreeViewGetPopupMenu(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
      var AskParent: Boolean; var PopupMenu: TPopupMenu);

    procedure CreatePreview;
    procedure OnPersonsFoundOnPreview(Sender: TObject; FileName: string; Items: TFaceDetectionResult);
    procedure OnPreviewPersonMouseEnter(Sender: TObject);
    procedure OnPreviewPersonMouseLeave(Sender: TObject);
    procedure OnPreviewPersonClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnBeginLoadingPreviewImage(Sender: TObject; NewImage: Boolean);
    procedure DoStartPersonSelection(Sender: TObject);
    procedure OnStopPersonSelection(Sender: TObject);
    procedure OnPreviewUpdateButtonsState(Sender: TObject; Buttons: TButtonStates);

    procedure ExtendedSearchInit;
    procedure ExtendedSearchRealign;
    procedure ExtendedSearchCheckEnabled;
    procedure ExtendedSearchInitPersons;
    procedure ExtendedSearchInitGroups;
    procedure ExtendedSearchGroupClick(Sender: TObject);
    procedure ExtendedSearchGroupModeClick(Sender: TObject);
    procedure SelectPersonClick(Sender: TObject);
    procedure AddWideSearchPerson(P: TPerson);
    procedure WlExtendedSearchAddPersonClick(Sender: TObject);
    procedure ExtendedSearchPersonClick(Sender: TObject);
    procedure ExtendedSearchPersonModeClick(Sender: TObject);
    procedure ExtendedSearchShow;

    procedure SetResizePreviewMode;
    procedure SetResizeListViewMode;
    property W7TaskBar: ITaskbarList3 read GetW7TaskBar;
  protected
    procedure ZoomIn;
    procedure ZoomOut;
    procedure LoadToolBarGrayedIcons;
    procedure LoadToolBarNormaIcons;
    function TreeView: TPathProvideTreeView;
    procedure CreateBackgrounds;
    procedure ShowHideFilter(Sender: TObject);
    function GetFormID: string; override;
    function GetListView: TEasyListView; override;
    function InternalGetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer) : Boolean; override;
    function MakeItemVisibleByFilter(Item: TEasyItem; Filter: string): Boolean;
    function GetFilterText: string;
    procedure SetNewHistoryPath(Sender: TObject);
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
    procedure CMMOUSELEAVE(var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure AddItemToUpdate(Item: TEasyItem);
    procedure ItemUpdateTimer(Sender: TObject);
    procedure UpdateItems;
    procedure StateChanged(OldState: TGUID); override;
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer); override;

    procedure ShowMarker(FileName: string; Lat, Lng: Double; Date: TDateTime);
    procedure DisplayGeoLocation(FileName: string; Lat, Lng: Double; Date: TDateTime);
    procedure StartMap(UpdateTab: Boolean);
    procedure ClearMap;
    procedure SaveCurrentImageInfoToMap;
    procedure ClearGeoLocation;
    function CanSaveGeoLocation: Boolean;

    //JS callbacks
    function CanSaveLocation(Lat: Double; Lng: Double; Value: Shortint): Shortint; safecall;
    function SaveLocation(Lat: Double; Lng: Double; const FileName: WideString): Shortint; safecall;
    procedure ZoomPan(Lat: Double; Lng: Double; Zoom: SYSINT); safecall;
    procedure UpdateEmbed; safecall;
    procedure MapStarted; safecall;
    //END - JS callbacks

    procedure ApplyStyle; override;
    procedure ApplySettings; override;
    function CanShareSelectedObjects: Boolean;

    procedure ShowRightPanel(Mode: TExplorerRightTab);
    procedure HideRightPanel;
  public
    constructor Create(AOwner: TComponent; GoToLastSavedPath: Boolean); overload;
    destructor Destroy; override;

    procedure SetPathItem(PI: TPathItem); override;
    procedure DoStopLoading;
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure BeginUpdate;
    procedure EndUpdate(Invalidate: Boolean);
    procedure DoDefaultSort(GUID: TGUID);
    function GetAllItems: TExplorerFileInfos;

    procedure HandleEncryptionError(FileName: string; ErrorMessage: string);

    procedure GetCurrentImage(W, H: Integer; out Image: TGraphic); override;
    function GetVisibleItems: TStrings;
    procedure RemoveUpdateID(FileName: string; CID: TGUID);
    procedure AddUpdateID(FileName: string);
    procedure DoBack;
    procedure SetNewPathW(WPath: TExplorerPath; Explorer: Boolean); override;
    procedure SetStringPath(Path: String; ChangeTreeView: Boolean); override;
    procedure ShowProgress;
    procedure ShowIndeterminateProgress;
    procedure HideProgress;
    procedure SetProgressMax(Value: Integer);
    procedure SetProgressPosition(Value: Integer);
    procedure SetStatusText(Text: String);
    procedure SetNewFileNameGUID(FileGUID: TGUID);
    procedure SetPanelInfo(Info: TDBPopupMenuInfoRecord; ExifInfo: IExifInfo; var Histogramm: TBitmap; FileGUID: TGUID);
    procedure SetPanelImage(Image: TBitmap; FileGUID: TGUID);
    procedure ClearHistogram;
    procedure AddInfoAboutFile(Info: TExplorerFileInfos);
    procedure UpdateMenuItems(Menu: TPopupActionBar; PathList: TArExplorerPath; PathIcons: TPathItemCollection);
    procedure DirectoryChanged(Sender: TObject; SID: TGUID; pInfo: TInfoCallBackDirectoryChangedArray);
    procedure LoadInfoAboutFiles(Info: TExplorerFileInfos);
    function FileNeededW(FileSID: TGUID): Boolean;  //для больших имаг
    function AddBitmap(Bitmap: TBitmap; FileGUID: TGUID): Boolean;
    function AddIcon(Icon: TIcon; SelfReleased : Boolean; FileGUID: TGUID): Boolean;

    //Begin: ICurrentImageSource
    function GetCurrentImageFileName: string;
    //End of: ICurrentImageSource

    function GetCurrentPath: String; override;
    procedure SetPath(NewPath: String); override;
    procedure Select(Item: TEasyItem; GUID: TGUID);
    procedure ShowHelp(Text, Link: string);
    function ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include: Boolean; Big: Boolean = False): Boolean;
    function ReplaceIcon(Icon: TIcon; FileGUID: TGUID; Include: Boolean): Boolean;
    function SetFileIsEncrypted(FileGUID: TGUID; IsEncrypted: Boolean): Boolean;
    function AddItemW(Caption : string; FileGUID: TGUID) : TEasyItem;
    function AddItem(FileGUID: TGUID; LockItems: Boolean = True; Sort: Integer = -1): TEasyItem;
    procedure SetOldPath(Path: string); override;
    procedure NavigateToFile(FileName: string); override;
    procedure UpdatePreviewIcon(Ico: HIcon; SID: TGUID);
    procedure LoadLastPath; override;
    procedure LoadLanguage;
    procedure LoadSizes;
    procedure BigSizeCallBack(Sender: TObject; SizeX, SizeY: Integer);
    procedure HideFilter(ResetFilter: Boolean = True);
    procedure ShowFilter(PerformFilter: Boolean);
    property MyComputer: string read GetMyComputer;
    property ViewInfo: TExplorerViewInfo read GetViewInfo;
    property View: Integer read GetView write SetView;
    property ItemsCount: Integer read GetItemsCount;
    property IsExplorerTreeViewVisible: Boolean read GetIsExplorerTreeViewVisible;
  end;

implementation

uses
  UnitUpdateDB,
  PropertyForm,
  FormManegerUnit,
  UnitFileRenamerForm,
  ImEditor,
  UnitSavingTableForm,
  UnitBigImagesSize,
  uOperationProgress,

  ExplorerThreadUnit,
  UnitHintCeator,
  UnitExplorerThumbnailCreatorThread,
  UnitHelp,
  uMachMask,
  DBScriptFunctions,
  UnitUpdateDBObject;

{$R *.dfm}

procedure RegisterPathEditThread(Sender: TThread);
begin
  DBThreadManager.RegisterThread(Sender);
end;

procedure UnRegisterPathEditThread(Sender: TThread);
begin
  DBThreadManager.UnRegisterThread(Sender);
end;

procedure PE_PathProvider_UpdateText(Item: TPathItem);
begin
  if Item is THomeItem then
    Item.DisplayName := TA('My computer', 'Path');
  if Item is TNetworkItem then
    Item.DisplayName := TA('Network', 'Path');
end;

procedure PEPathProvider_UpdateImage(Item: TPathItem; ImageSize: Integer);
var
  Icon: TIcon;
begin
  if Item is THomeItem then
  begin
    FindIcon(HInstance, 'COMPUTER', ImageSize, 32, Icon);
    Item.Image := TPathImage.Create(Icon);
  end;
  if Item is TShareItem then
  begin
    FindIcon(HInstance, 'SHARE', ImageSize, 32, Icon);
    Item.Image := TPathImage.Create(Icon);
  end;
  if Item is TComputerItem then
  begin
    FindIcon(HInstance, 'COMPUTER', ImageSize, 32, Icon);
    Item.Image := TPathImage.Create(Icon);
  end;
  if Item is TWorkgroupItem then
  begin
    FindIcon(HInstance, 'WORKGROUP', ImageSize, 32, Icon);
    Item.Image := TPathImage.Create(Icon);
  end;
  if Item is TNetworkItem then
  begin
    FindIcon(HInstance, 'NETWORK', ImageSize, 32, Icon);
    Item.Image := TPathImage.Create(Icon);
  end;
end;

procedure LoadSpeedButtonFromResourcePNG(SB: TSpeedButton; ResName: string);
var
  PNG: TPNGImage;
  BMP: TBitmap;
begin
  PNG := TResourceUtils.LoadGraphicFromRES<TPNGImage>(ResName);
  try
    BMP := TBitmap.Create;
    try
      LoadPNGImage32bit(PNG, BMP, Theme.MenuColor);
      SB.Glyph := BMP;
    finally
      F(BMP);
    end;
  finally
    F(PNG);
  end;
end;

function MakeRegPath(Path: string): string;
var
  I: Integer;
begin
  Result := Path;
  if Path = '' then
    Exit;

  Result := ExcludeTrailingBackslash(Result);
  for I := 1 to Length(Result) do
  begin
    if (Result[I] = ':') or (Result[I] = '\') then
      Result[I] := '_';
  end;
end;

function TExplorerForm.GetPathDescription(Path: string; FileType: Integer): string;
begin
  if ((Length(Path) = 3) or (Length(Path) = 2)) and (Path[2] = ':') then
    Result := Format(L('%s drive'), [GetCDVolumeLabelEx(Path[1])])
  else if IsNetworkServer(Path) then
    Result := L('Computer')
  else if IsNetworkShare(Path) then
    Result := L('Shared folder')
  else if (FileType = EXPLORER_ITEM_FILE) or (FileType = EXPLORER_ITEM_IMAGE) then
    Result := GetFileDescription(Path, L('Unknown file type'))
  else
    Result := L('Directory');
end;

procedure TExplorerForm.PathTreeViewChange(Sender: TCustomVirtualDrawTree; PathItem: TPathItem);
begin
  if ElvMain <> nil then
    SetPathItem(PathItem);
end;

procedure TExplorerForm.PathTreeViewGetPopupMenu(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
  var AskParent: Boolean; var PopupMenu: TPopupMenu);
begin
  if Node <> nil then
  begin
    PopupMenu := PmTreeView;
    MiTreeViewOpenInNewWindow.Visible := True;
    MiTreeViewRefresh.Visible := True;
  end;
end;

procedure TExplorerForm.PcRightPreviewChange(Sender: TObject);
begin
  FActiveRightTab := TExplorerRightTab(PcRightPreview.ActivePageIndex);
  Settings.WriteInteger('Explorer', 'RightPanelTabIndex', PcRightPreview.ActivePageIndex);
  if PcRightPreview.ActivePageIndex = Integer(ertsPreview) then
  begin
    CreatePreview;
    if FImageViewer <> nil then
    begin
      if ListView1Selected <> nil then
        FImageViewer.LoadFiles(GetCurrentPopUpMenuInfo(ListView1Selected))
      else
        FImageViewer.SetText(L('Select a file to preview'));
    end;
  end;

  if PcRightPreview.ActivePageIndex = Integer(ertsMap) then
    WlGeoLocationClick(Sender);
end;

procedure TExplorerForm.PcTasksChange(Sender: TObject);
begin
  FActiveLeftTab := TExplorerLeftTab(PcTasks.ActivePageIndex);
  Settings.WriteInteger('Explorer', 'LeftPanelTabIndex', PcTasks.ActivePageIndex);
  if PcTasks.ActivePageIndex = Integer(eltsExplorer) then
  begin
    if GetCurrentPathW.PType <> EXPLORER_ITEM_SEARCH then
      TreeView.SelectPathItem(PePath.PathEx)
    else
      TreeView; //just start tree without any selection
  end;
  if PcTasks.ActivePageIndex = Integer(eltsSearch) then
    ExtendedSearchInit;
  if PcTasks.ActivePageIndex = Integer(eltsEXIF) then
    VleExif.UpdateRowsHeight;
end;

procedure VerifyPaste(Explorer: TExplorerForm);
var
  CanPaste: Boolean;
  FileType: Integer;
begin
  FileType := Explorer.FCurrentTypePath;

  CanPaste := Explorer.FCanPasteFromClipboard and ((FileType = EXPLORER_ITEM_FOLDER)
                        or (FileType = EXPLORER_ITEM_DRIVE)
                        or (FileType = EXPLORER_ITEM_SHARE)
                        or (FileType = EXPLORER_ITEM_DEVICE_STORAGE)
                        or (FileType = EXPLORER_ITEM_DEVICE_DIRECTORY));

  Explorer.TbPaste.Enabled := CanPaste;
end;

procedure TExplorerForm.CreateBackgrounds;
var
  ExplorerBackground: TPNGImage;
  Bitmap, ExplorerBackgroundBMP, Background: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := 150;
    Bitmap.Height := 150;

    Bitmap.Canvas.Brush.Color := Theme.ListViewColor;
    Bitmap.Canvas.Pen.Color := Theme.ListViewColor;
    Bitmap.Canvas.Rectangle(0, 0, 150, 150);
    ExplorerBackground := GetExplorerBackground;
    try
      ExplorerBackgroundBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, Theme.ListViewColor);
        Bitmap.Canvas.Draw(0, 0, ExplorerBackgroundBMP);

        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, Theme.PanelColor);

        Background := ScrollBox1.BackGround;
        Background.PixelFormat := pf24bit;
        Background.SetSize(130, 150);

        Background.Canvas.Brush.Color := Theme.PanelColor;
        Background.Canvas.Pen.Color := Theme.PanelColor;
        Background.Canvas.Rectangle(0, 0, BackGround.Width, BackGround.Height);
        DrawTransparent(ExplorerBackgroundBMP, Background, 40);
        ScrollBox1Resize(Self);
      finally
        F(ExplorerBackgroundBMP);
       end;
    finally
      F(ExplorerBackground);
    end;
    ElvMain.BackGround.Image := Bitmap;
  finally
    F(Bitmap);
  end;
end;

procedure TExplorerForm.CreatePreview;
begin
  if FImageViewer = nil then
  begin
    FImageViewer := TImageViewer.Create;
    FImageViewer.AttachTo(Self, PnRightPreview, 2, 2);
    FImageViewer.SetFaceDetectionControls(WlFaceCount, LsDetectingFaces, ToolBarPreview);
    FImageViewer.OnBeginLoadingImage := OnBeginLoadingPreviewImage;
    FImageViewer.OnRequestNextImage := TbPreviewNextClick;
    FImageViewer.OnRequestPreviousImage := TbPreviewPreviousClick;
    FImageViewer.OnDblClick := SlideShowLinkClick;
    FImageViewer.OnPersonsFoundOnImage := OnPersonsFoundOnPreview;
    FImageViewer.OnStopPersonSelection := OnStopPersonSelection;
    FImageViewer.OnUpdateButtonsState := OnPreviewUpdateButtonsState;
    TsMediaPreviewResize(Self);

    WlFaceCount.ImageList := DBkernel.ImageList;
    WlFaceCount.Visible := FaceDetectionManager.IsActive;
    LsDetectingFaces.Visible := FaceDetectionManager.IsActive;
  end;
end;

procedure TExplorerForm.FormCreate(Sender: TObject);
var
  I: Integer;
  C: TComponent;
begin
  FSearchMode := -1;
  FGeoHTMLWindow := nil;
  FEditorInfo := nil;
  FPngNoHIstogram := nil;
  FImageViewer := nil;
  FExtendedSearchParams := nil;
  FExtendedSearchPersons := nil;
  FPopupMenuWasActiveOnMouseDown := False;
  FGeoLocationMapReady := False;
  GetDeviceEventManager.RegisterNotification([peItemAdded, peItemRemoved, peDeviceConnected, peDeviceDisconnected], PortableEventsCallBack);
  FIsFirstShow := True;
  DirectoryWatcher := TWachDirectoryClass.Create;
  DefaultSort := -1;
  FWasDragAndDrop := False;
  LockDrawIcon := False;
  ListView := LV_THUMBS;
  IsReallignInfo := False;
  FIsMapLoaded := False;
  FOldWidth := Width;
  IsResizePreivew := True;

  TW.I.Start('ListView1');

  FUpdateItemList := TList.Create;
  FItemUpdateTimer := TTimer.Create(nil);
  FItemUpdateTimer.Enabled := False;
  FItemUpdateTimer.Interval := RefreshListViewInterval;
  FItemUpdateTimer.OnTimer := ItemUpdateTimer;

  ElvMain := TEasyListView.Create(Self);
  ElvMain.Parent := PnListView;
  ElvMain.Align := alClient;
  ElvMain.Constraints.MinWidth := 100;
  ElvMain.ShowThemedBorder := False;
  ElvMain.BorderStyle := bsNone;

  MouseDowned := False;
  PopupHandled := False;

  ElvMain.BackGround.Enabled := True;
  ElvMain.BackGround.Tile := False;
  ElvMain.BackGround.AlphaBlend := True;
  ElvMain.BackGround.OffsetTrack := True;
  ElvMain.BackGround.BlendAlpha := 220;

  ElvMain.View := elsThumbnail;
  ElvMain.DragKind := dkDock;

  ElvMain.IncrementalSearch.Enabled := True;
  ElvMain.IncrementalSearch.ItemType := eisiInitializedOnly;
  ElvMain.OnItemThumbnailDraw := EasyListview1ItemThumbnailDraw;
  ElvMain.OnItemPaintText := EasyListview1ItemPaintText;
  ElvMain.OnDblClick := EasyListview1DblClick;
  ElvMain.OnExit := ListView1Exit;
  ElvMain.OnMouseDown := ListView1MouseDown;
  ElvMain.OnMouseUp := ListView1MouseUp;
  ElvMain.OnMouseMove := ListView1MouseMove;
  ElvMain.OnItemSelectionChanged := EasyListview1ItemSelectionChanged;
  ElvMain.OnIncrementalSearch := Listview1IncrementalSearch;
  ElvMain.OnMouseWheel := ListView1MouseWheel;
  ElvMain.OnKeyAction := EasyListview2KeyAction;
  ElvMain.OnItemEdited := EasyListview1ItemEdited;
  ElvMain.OnCanResize := ListViewOnCanResize;
  ElvMain.OnResize := ListView1Resize;
  ElvMain.OnItemImageDraw := EasyListview1ItemImageDraw;
  ElvMain.OnItemImageDrawIsCustom := EasyListview1ItemImageDrawIsCustom;
  ElvMain.OnItemImageGetSize := EasyListview1ItemImageGetSize;

  ElvMain.Header.DragManager.Enabled := False;
  ElvMain.DragManager.Enabled := False;
  ElvMain.Header.Columns.Add;
  ElvMain.Groups.Add;
  ElvMain.Groups[0].Visible := True;

  ElvMain.Scrollbars.SmoothScrolling := Settings.Readbool('Options', 'SmoothScrolling', True);

  RefreshIDList := TStringList.Create;

  SetLength(UserLinks, 0);
  SetLength(FPlaces, 0);
  DragFilesPopup := TStringList.Create;

  //month popup looks very strange in XP
  if TOSVersion.Major < 6 then
    McDateSelectPopup.DisableStyles;

  SelfDraging := False;
  Outdrag := False;
  FDblClicked := False;
  SetLength(FListDragItems, 0);
  FDBCanDragW := False;
  ImPreview.Picture.Bitmap := nil;
  DropFileTargetFake.Register(Self);
  DropFileTargetMain.Register(ElvMain);

  FShowStatusBar := Settings.Readbool('Options', 'ShowStatusBar', False);
  ElvMain.HotTrack.Enabled := Settings.Readbool('Options', 'UseHotSelect', True);
  RegisterMainForm(Self);
  FStatusProgress := CreateProgressBar(StatusBarMain, 0);
  FStatusProgress.Visible := False;
  FHistory.OnHistoryChange := HistoryChanged;
  TbBack.Enabled := False;
  TbForward.Enabled := False;
  DBKernel.RegisterChangesID(Sender, ChangedDBDataByID);

  NewFormState;
  MainPanel.Width := Settings.ReadInteger('Explorer', 'LeftPanelWidth', 165);
  PnSearch.Width := Settings.ReadInteger('Explorer', 'SearchPanel', 210);
  VleExif.ColWidths[0] := Settings.ReadInteger('Explorer', 'LeftPanelExifSplitter', VleExif.ColWidths[0]);

  TbSearch.Down := Settings.ReadBool('Explorer', 'LeftPanelSearchVisible', False);
  TbSearch.Tag := IIF(TbSearch.Down, -1, 1);

  if Settings.ReadBool('Explorer', 'RightPanelVisible', True) then
    ShowRightPanel(ertsPreview)
  else
    SetResizeListViewMode;

  Lock := False;

  SlashHandled := False;

  TW.I.Start('ReadPlaces');
  ReadPlaces;
  TW.I.Start('LoadToolBarNormaIcons');
  LoadToolBarNormaIcons;
  TW.I.Start('LoadToolBarGrayedIcons');
  LoadToolBarGrayedIcons;

  TW.I.Start('aScript');
  AScript := TScript.Create(Self, '');

  AddScriptObjFunction(aScript.PrivateEnviroment,'CloseWindow',        F_TYPE_OBJ_PROCEDURE_TOBJECT, CloseWindow);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'SelectAll',         F_TYPE_OBJ_PROCEDURE_TOBJECT, SelectAll1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoUp',              F_TYPE_OBJ_PROCEDURE_TOBJECT, Up1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoBack',            F_TYPE_OBJ_PROCEDURE_TOBJECT, Back1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoForward',         F_TYPE_OBJ_PROCEDURE_TOBJECT, Forward1Click);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'Copy',              F_TYPE_OBJ_PROCEDURE_TOBJECT, CopyClick);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'Paste',             F_TYPE_OBJ_PROCEDURE_TOBJECT, PasteClick);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'Cut',               F_TYPE_OBJ_PROCEDURE_TOBJECT, CutClick);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowPrivate',       F_TYPE_OBJ_PROCEDURE_TOBJECT, ShowPrivate1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'HidePrivate',       F_TYPE_OBJ_PROCEDURE_TOBJECT, ShowOnlyCommon1Click);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetThumbnailsView', F_TYPE_OBJ_PROCEDURE_TOBJECT, Thumbnails1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetTilesView',      F_TYPE_OBJ_PROCEDURE_TOBJECT, Tile2Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetIconsView',      F_TYPE_OBJ_PROCEDURE_TOBJECT, Icons1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetListView',       F_TYPE_OBJ_PROCEDURE_TOBJECT, List1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetList2View',      F_TYPE_OBJ_PROCEDURE_TOBJECT, SmallIcons1Click);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowHideFilter',    F_TYPE_OBJ_PROCEDURE_TOBJECT, ShowHideFilter);

  AddScriptObjFunctionIsString(       aScript.PrivateEnviroment, 'GetPath',            GetPath);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanBack',            FHistory.CanBack);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanForward',         FHistory.CanForward);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanUp',              CanUp);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'SelCount',           SelCount);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'SelectedIndex',      SelectedIndex);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'GetSelectedType',    GetSelectedType);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanCopySelection',   CanCopySelection);
  AddScriptObjFunctionIsArrayStrings( aScript.PrivateEnviroment, 'GetSelectedFiles',   GetSelectedFiles);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanPasteInSelection',CanPasteInSelection);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'ShowPrivateNow',     ShowPrivate);
  AddScriptObjFunctionIntegerIsString(aScript.PrivateEnviroment, 'GetPathByIndex',     GetPathByIndex);

  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'GetView',            GetView);

  if IsWindows8 then
    TLoad.Instance.RequiredDBKernelIcons;

  TW.I.Start('Script read');
  SetNamedValueStr(AScript, '$dbname', dbname);
  MainMenuScript := ReadScriptFile('scripts\ExplorerMainMenu.dbini');
  TW.I.Start('Script Execure');
  Menu := nil;
  LoadMenuFromScript(ScriptMainMenu.Items, DBKernel.ImageList, MainMenuScript, AScript, ScriptExecuted, FExtImagesInImageList, True);
  Menu := ScriptMainMenu;
  ScriptMainMenu.Images := DBKernel.ImageList;

  TW.I.Start('LoadLanguage');
  LoadLanguage;
  TW.I.Start('LoadToolBarGrayedIcons - end');
  ToolBarMain.Images := ToolBarNormalImageList;
  ToolBarMain.DisabledImages := ToolBarDisabledImageList;

  ToolBarBottom.DisabledImages := DBKernel.DisabledImageList;

  PePath.Width := PnNavigation.Width - (StAddress.Left + StAddress.Width + 5);

  TW.I.Start('AddExplorer');
  ExplorerManager.AddExplorer(Self);

  SaveWindowPos1.Key := RegRoot + 'Explorer\' + MakeRegPath(GetCurrentPath);
  SaveWindowPos1.SetPosition;

  TW.I.Start('FixFormPosition');
  FixFormPosition;
  RequestAlign;

  if PnRight.Align = alClient then
    PnListView.Width := IIF(WindowState = wsMaximized, Monitor.Width - (Width - ClientWidth) - MainPanel.Width + SplLeftPanel.Width, PnContent.Width) - Settings.ReadInteger('Explorer', 'RightPanelWidth', PnRight.Width)
  else
    PnRight.Width := Settings.ReadInteger('Explorer', 'RightPanelWidth', PnRight.Width);

  TW.I.Start('FormLoadEnd - true');
  FormLoadEnd := True;
  LsMain.Top := PnNavigation.Top + PnNavigation.Height + 3;
  LsMain.BringToFront;

  if FGoToLastSavedPath then
    LoadLastPath;
  FCanPasteFromClipboard := CanCopyFromClipboard;

  TW.I.Start('BackGround');
  for I := 0 to ScrollBox1.ComponentCount - 1 do
  begin
    C := ScrollBox1.Components[I];
    if C is TWebLink then
      if C <> WlLearnMoreLink then
        TWebLink(C).GetBackGround := BackGround;
  end;

  for I := 0 to Length(UserLinks) - 1 do
    UserLinks[I].GetBackGround := BackGround;

  TW.I.Start('LoadIcons');
  LoadIcons;

  FItemUpdateLastTime := 0;

  FWebBrowserJSMessage := RegisterWindowMessage('WEBBROWSER_JS_MESSAGE');
  FReloadGroupsMessage := RegisterWindowMessage('EXPLORER_RELOAD_GROUPS');
  FReloadESGroupsMessage := RegisterWindowMessage('EXPLORER_RELOAD_ES_GROUPS');
  FReloadRSPersonsMessage := RegisterWindowMessage('EXPLORER_RELOAD_ES_PERSONS');

  TLoad.Instance.RequiredDBSettings;
  FPictureSize := ThImageSize;
  LoadSizes;

end;

procedure TExplorerForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TEasyItem;
  FileNames: TStrings;
  I, Index: Integer;
  R: TRect;
  VitrualKey: Boolean;
begin
  if CopyFilesSynchCount > 0 then
    WindowsMenuTickCount := GetTickCount;

  Rdown := False;
  FDblClicked := False;
  HintTimer.Enabled := False;
  FDBCanDrag := False;

  Item := ItemByPointImage(ElvMain, Point(MousePos.X, MousePos.Y), ListView);
  VitrualKey := ((MousePos.X = -1) and (MousePos.Y = -1));
  if (Item = nil) or VitrualKey then
    Item := ElvMain.Selection.First;

  R := ElvMain.Scrollbars.ViewableViewportRect;
  if (Item <> nil) and (Item.SelectionHitPt(Point(MousePos.X + R.Left, MousePos.Y + R.Top),
      EshtClickSelect) or VitrualKey) then
  begin
    LastMouseItem := nil;
    Application.HideHint;
    THintManager.Instance.CloseHint;
    if Item.Index > FFilesInfo.Count - 1 then
      Exit;

    SetForegroundWindow(Handle);
    SetLength(FFilesToDrag, 0);
    Fpopupdown := True;
    if not(GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
    begin
      PmItemPopup.Tag := ItemIndexToMenuIndex(Item.index);
      PmItemPopup.DoPopupEx(ElvMain.Clienttoscreen(MousePos).X, ElvMain.Clienttoscreen(MousePos).Y);
    end else
    begin
      Screen.Cursor := crDefault;
      if ListView1Selected <> nil then
      begin
        FileNames := TStringList.Create;
        try
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              Index := ItemIndexToMenuIndex(I);
              FileNames.Add(FFilesInfo[Index].FileName);
            end;
          GetProperties(FileNames, MousePos, ElvMain);
        finally
          F(FileNames);
        end;
      end;
    end;
  end else
    PmListPopup.DoPopupEx(ElvMain.Clienttoscreen(MousePos).X, ElvMain.Clienttoscreen(MousePos).Y);
end;

procedure TExplorerForm.SlideShow1Click(Sender: TObject);
var
  FileName: string;
  MenuInfo: TDBPopupMenuInfo;
  Index: Integer;
begin
  FileName := FFilesInfo[PmItemPopup.Tag].FileName;

  if CanBeTransparentEncryptedFile(FileName) and ShellPlayEncryptedMediaFile(FileName) then
    Exit;

  if (FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE) or
    (FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
  begin
    Index := MenuIndexToItemIndex(PmItemPopup.Tag);
    MenuInfo := GetCurrentPopUpMenuInfo(ElvMain.Items[Index]);
    try
      Viewer.ShowImages(Sender, MenuInfo);
      Viewer.Show;
      Viewer.Restore;
    finally
      F(MenuInfo);
    end;
  end;
  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_FOLDER then
  begin
    if Viewer.ShowImageInDirectory(FFilesInfo[PmItemPopup.Tag].FileName, ExplorerManager.ShowPrivate) then
    begin
      Viewer.Show;
      Viewer.Restore;
    end
    else
      MessageBoxDB(Handle, L('There are no images to display!'), L('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);
  end;
end;

procedure TExplorerForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)), nil, nil, SW_NORMAL);
end;

procedure TExplorerForm.PmItemPopupPopup(Sender: TObject);
var
  Infos: TDBPopupMenuInfo;
  info: TExplorerFileInfo;
  Item: TEasyItem;
  Point: TPoint;
  I: Integer;
  B: Boolean;
begin
  GetCursorPos(Point);
  info := FFilesInfo[PmItemPopup.Tag];

  DBitem1.Visible := False;
  StenoGraphia1.Visible := False;
  Print1.Visible := False;
  Othertasks1.Visible := False;
  ImageEditor2.Visible := False;
  RefreshID1.Visible := False;
  Rotate1.Visible := False;
  SetasDesktopWallpaper1.Visible := False;
  Convert1.Visible := False;
  Resize1.Visible := False;
  CryptFile1.Visible := False;
  ResetPassword1.Visible := False;
  EnterPassword1.Visible := False;
  Refresh1.Visible := False;
  NewWindow1.Visible := False;
  Open1.Visible := False;
  SlideShow1.Visible := False;
  Properties1.Visible := False;
  Delete1.Visible := False;
  Rename1.Visible := False;
  AddFile1.Visible := False;
  MiImportImages.Visible := False;
  Cut2.Visible := False;
  Copy1.Visible := False;
  Shell1.Visible := False;
  MiShelf.Visible := False;
  MiShare.Visible := False;
  MiDisplayOnMap.Visible := False;
  MakeFolderViewer2.Visible := False;
  MapCD1.Visible := False;

  if Info.FileType = EXPLORER_ITEM_DRIVE then
  begin
    NewWindow1.Visible := True;
    AddFile1.Caption := L('Add disk');
    AddFile1.Visible := not FolderView;
    Properties1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := True;
    MiImportImages.Visible := True;

    Shell1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_FOLDER then
  begin
    MakeFolderViewer2.Visible := not FolderView;
    Refresh1.Visible := True;
    NewWindow1.Visible := True;
    AddFile1.Caption := L('Add directory');
    AddFile1.Visible := not FolderView;
    Properties1.Visible := True;
    Open1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
    SlideShow1.Visible := True;

    Shell1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_IMAGE then
  begin
    MiShare.Visible := not FolderView;

    if CanSaveGeoLocation then
    begin
      if (FSelectedInfo.GeoLocation <> nil)  then
        MiDisplayOnMap.Caption := L('Display on map')
      else
        MiDisplayOnMap.Caption := L('Set map location');
      MiDisplayOnMap.Visible := True;
    end else
      MiDisplayOnMap.Visible := False;

    MiShelf.Visible := True;
    DBitem1.Visible := True;
    StenoGraphia1.Visible := True;
    AddHiddenInfo1.Visible := (SelCount = 1);
    ExtractHiddenInfo1.Visible := ExtInMask('|PNG|BMP|JPG|JPEG|', GetExt(Info.FileName));

    MakeFolderViewer2.Visible := not FolderView;
    Print1.Visible := True;
    Othertasks1.Visible := True;
    ImageEditor2.Visible := True;
    CryptFile1.Visible := not ValidCryptGraphicFile(Info.FileName);
    ResetPassword1.Visible := not CryptFile1.Visible;
    EnterPassword1.Visible := not CryptFile1.Visible and (DBKernel.FindPasswordForCryptImageFile(info.FileName) = '');

    Convert1.Visible := not EnterPassword1.Visible;
    Resize1.Visible := not EnterPassword1.Visible;
    Rotate1.Visible := not EnterPassword1.Visible;
    RefreshID1.Visible := (not EnterPassword1.Visible) and (Info.ID <> 0);
    SetasDesktopWallpaper1.Visible := CryptFile1.Visible and IsWallpaper(Info.FileName);
    Refresh1.Visible := True;
    Rename1.Visible := True;
    Properties1.Visible := True;
    SlideShow1.Visible := True;
    Delete1.Visible := True;
    AddFile1.Caption := L('Add file');
    if FFilesInfo[PmItemPopup.Tag].ID = 0 then
      AddFile1.Visible := not FolderView
    else
      AddFile1.Visible := False;
    Cut2.Visible := True;
    Copy1.Visible := True;
  end;

  if (Info.FileType = EXPLORER_ITEM_FILE) or (Info.FileType = EXPLORER_ITEM_EXEFILE) then
  begin
    if AnsiLowerCase(ExtractFileName(Info.FileName)) = AnsiLowerCase(C_CD_MAP_FILE) then
      MapCD1.Visible := not FolderView;

    MiShare.Visible := CanShareVideo(Info.FileName) and not FolderView;
    MiShelf.Visible := True;
    Properties1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
    Cut2.Visible := True;
    Copy1.Visible := True;
    Shell1.Visible := True;

    if CanBeTransparentEncryptedFile(Info.FileName) then
    begin
      CryptFile1.Visible := not ValidCryptGraphicFile(Info.FileName);
      ResetPassword1.Visible := not CryptFile1.Visible;
      EnterPassword1.Visible := not CryptFile1.Visible and (DBKernel.FindPasswordForCryptImageFile(info.FileName) = '');
    end;
  end;

  if Info.FileType = EXPLORER_ITEM_NETWORK then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_WORKGROUP then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_COMPUTER then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_DEVICE then
  begin
    MiImportImages.Visible := True;
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Properties1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_DEVICE_STORAGE then
  begin
    MiImportImages.Visible := True;
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Properties1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY then
  begin
    MiImportImages.Visible := True;
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Properties1.Visible := True;
    Cut2.Visible := True;
    Copy1.Visible := True;
  end;

  if (Info.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or (Info.FileType = EXPLORER_ITEM_DEVICE_FILE) then
  begin
    MiShare.Visible := CanShareVideo(Info.FileName) and not FolderView;
    Properties1.Visible := True;
    Delete1.Visible := True;
    Cut2.Visible := True;
    Copy1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_DEVICE_IMAGE then
  begin
    DBitem1.Visible := True;
    MiShare.Visible := not FolderView;
    StenoGraphia1.Visible := True;
    Print1.Visible := True;
    ImageEditor2.Visible := True;
    Convert1.Visible := True;
    Resize1.Visible := True;
    SlideShow1.Visible := True;
    Properties1.Visible := True;
    Delete1.Visible := True;
    Cut2.Visible := True;
    Copy1.Visible := True;
    ImageEditor2.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_PERSON_LIST then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_PERSON then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Properties1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_GROUP_LIST then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_SHELF then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Delete1.Visible := True;
  end;

  if Info.FileType in [EXPLORER_ITEM_CALENDAR, EXPLORER_ITEM_CALENDAR_YEAR, EXPLORER_ITEM_CALENDAR_MONTH, EXPLORER_ITEM_CALENDAR_DAY] then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_GROUP then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
    Properties1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
  end;

  if Info.FileType = EXPLORER_ITEM_SHARE then
  begin
    NewWindow1.Visible := True;
    Open1.Visible := True;
  end;

  if MiShelf.Visible then
  begin
    if PhotoShelf.PathInShelf(info.FileName) = -1 then
      MiShelf.Caption := L('Shelve')
    else
      MiShelf.Caption := L('Unshelve');
  end;

  B := CanCopySelection;
  Cut2.Visible := B;
  Copy1.Visible := B;

  Item := ItemAtPos(ElvMain.ScreenToClient(Point).X, ElvMain.ScreenToClient(Point).Y);
  if PmItemPopup.Tag < 0 then
    Exit;
  if Item = nil then
    Item :=  ElvMain.Items[MenuIndexToItemIndex(PmItemPopup.Tag)];

  for I := DBitem1.MenuIndex + 1 to N8.MenuIndex - 1 do
    PmItemPopup.Items.Delete(DBitem1.MenuIndex + 1);

  if DBitem1.Visible then
  begin
    Infos := GetCurrentPopUpMenuInfo(Item);
    try
      if Item <> nil then
      begin
        Infos.IsListItem := True;
        Infos.ListItem := Item;
      end;
      TDBPopupMenu.Instance.AddDBContMenu(Self, DBItem1, Infos);
    finally
      F(Infos);
    end;
  end;

  if Settings.ReadBool('Options', 'UseUserMenuForExplorer', True) then
    if Info.FileType = EXPLORER_ITEM_IMAGE then
    begin
      Infos := GetCurrentPopUpMenuInfo(Item);
      try
        if Info.ID = 0 then
        TDBPopupMenu.Instance.SetInfo(Self, Infos);
        TDBPopupMenu.Instance.AddUserMenu(PmItemPopup.Items, True, DBitem1.MenuIndex + 1);
      finally
        F(Infos);
      end;
    end;
end;

procedure TExplorerForm.Rename1Click(Sender: TObject);
var
  I, ItemIndex: Integer;
  Files: TStrings;
  X: TArInteger;
begin
  if (SelCount = 1) and (ListView1Selected <> nil) then
  begin
    ElvMain.SetFocus;
    ElvMain.EditManager.Enabled := True;
    ElvMain.Selection.First.Edit;
  end else if SelCount > 1 then
  begin
    Files := TStringList.Create;
    try
      for I := 0 to ElvMain.Items.Count - 1 do
      begin
        if ElvMain.Items[I].Selected then
        begin
          ItemIndex := ItemIndexToMenuIndex(I);
          if (FFilesInfo[ItemIndex].FileType = EXPLORER_ITEM_IMAGE) or
            (FFilesInfo[ItemIndex].FileType = EXPLORER_ITEM_FILE) or
            (FFilesInfo[ItemIndex].FileType = EXPLORER_ITEM_EXEFILE) or
            (FFilesInfo[ItemIndex].FileType = EXPLORER_ITEM_FOLDER) then
          begin
            SetLength(X, Length(X) + 1);
            X[Length(X) - 1] := FFilesInfo[ItemIndex].ID;
            Files.Add(ProcessPath(FFilesInfo[ItemIndex].FileName));
          end
        end;
      end;
      if Files.Count > 0 then
        FastRenameManyFiles(Files, X);
    finally
      F(Files);
    end;
  end;
end;

procedure TExplorerForm.DeleteFiles(ToRecycle: Boolean);
var
  I: Integer;
  Index: Integer;
  Files: TStringList;
  Info: TExplorerFileInfo;
  PI: TPathItem;
  PL: TPathItemCollection;
begin
  if SelCount = 0 then
    Exit;

  if FCurrentTypePath = EXPLORER_ITEM_SHELF then
  begin
    Files := TStringList.Create;
    try
      for I := ElvMain.Items.Count - 1 downto 0 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          Info := FFilesInfo[index];
          Files.Add(Info.FileName);
          DeleteItemWithIndex(I);
        end;

      PhotoShelf.DeleteItems(Self, Files);
    finally
      F(Files);
    end;
    Exit;
  end;

  Files:= TStringList.Create;
  PL := TPathItemCollection.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        Info := FFilesInfo[Index];
        if (Info.FileType = EXPLORER_ITEM_FOLDER) or (Info.FileType = EXPLORER_ITEM_IMAGE)
          or (Info.FileType = EXPLORER_ITEM_FILE) or (Info.FileType = EXPLORER_ITEM_EXEFILE) then
          Files.Add(Info.FileName);

        if (Info.FileType =  EXPLORER_ITEM_PERSON) or (Info.FileType = EXPLORER_ITEM_GROUP) or
           (Info.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (Info.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
           (Info.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or (Info.FileType = EXPLORER_ITEM_DEVICE_FILE) then
        begin
          PI := PathProviderManager.CreatePathItem(Info.FileName);

          if (PI <> nil) and PI.Provider.SupportsFeature(PATH_FEATURE_DELETE) then
            PL.Add(PI);
        end;
      end;

    if Files.Count > 0 then
      Dmitry.Utils.Files.DeleteFiles(Handle, Files, ToRecycle);

    if PL.Count > 0 then
      PL[0].Provider.ExecuteFeature(Self, PL, PATH_FEATURE_DELETE, nil);
  finally
    PL.FreeItems;
    F(PL);
    F(Files);
  end;
end;

procedure TExplorerForm.Delete1Click(Sender: TObject);
begin
  DeleteFiles(True);
end;

procedure TExplorerForm.AddFile1Click(Sender: TObject);
var
  I, Index: Integer;
begin
  if ListView1Selected <> nil then
  begin
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        if FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER then
        begin
          UpdaterDB.AddDirectory(FFilesInfo[Index].FileName);
          Continue;
        end;
        if FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE then
        begin
          UpdaterDB.AddFile(FFilesInfo[Index].FileName);
          Continue;
        end;
        if FFilesInfo[Index].FileType = EXPLORER_ITEM_DRIVE then
          if ID_OK = MessageBoxDB(Handle, L('Do you really want to add full drive with subfolders?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
          begin
            UpdaterDB.AddDirectory(FFilesInfo[Index].FileName);
            Continue;
          end;
      end;
    end;
  end;
  if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE)
    or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER)
    or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)
    or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) then
    if SelCount = 0 then
      UpdaterDB.AddDirectory(GetCurrentPath);
end;

procedure TExplorerForm.FormDestroy(Sender: TObject);
begin
  ClearWebBrowser(FWbGeoLocation);
  ClearGeoLocation;
  F(FWebJSContainer);
  F(FWbGeoLocation);
  F(FPngNoHIstogram);
  F(FExtendedSearchParams);
  FreeList(FExtendedSearchPersons);

  GetDeviceEventManager.UnRegisterNotification(PortableEventsCallBack);

  if IsWindowsVista then
    RemoveClipboardFormatListener(Handle)
  else
    ChangeClipboardChain(Handle, FNextClipboardViewer);

  ExplorerManager.RemoveExplorer(Self);
  NewFormState;
  ClearList;
  DirectoryWatcher.StopWatch;
  F(DirectoryWatcher);
  F(AScript);
  F(DragFilesPopup);
  F(FBitmapImageList);

  F(FUpdateItemList);
  F(FItemUpdateTimer);

  SaveWindowPos1.SavePosition;
  DropFileTargetFake.Unregister;
  DropFileTargetMain.Unregister;
  DBKernel.UnRegisterChangesID(Sender, ChangedDBDataByID);

  Settings.WriteInteger('Explorer', 'RightPanelWidth', PnRight.Width);
  Settings.WriteInteger('Explorer', 'LeftPanelExifSplitter', VleExif.ColWidths[0]);
  Settings.WriteInteger('Explorer', 'LeftPanelWidth', MainPanel.Width);
  Settings.WriteString('Explorer', 'Path', GetCurrentPathW.Path);
  Settings.WriteInteger('Explorer', 'PathType', GetCurrentPathW.PType);
  F(FStatusProgress);
  UnRegisterMainForm(Self);
  F(FFilesInfo);
  F(FEditorInfo);

  FWebBorwserFactory := nil;
end;

procedure TExplorerForm.FormResize(Sender: TObject);
var
  IsIncreasing: Boolean;
begin
  if StyleServices.Enabled then
  begin
    //hack for scrollbars in easy lsit view
    ElvMain.Scrollbars.VertEnabled := False;
    ElvMain.Scrollbars.VertEnabled := True;
    Repaint;
  end;

  if PnRight.Visible and (Width - PnRight.Width - ElvMain.Width > 0) then
  begin
    if FOldWidth <> Width then
    begin
      IsIncreasing := FOldWidth < Width;
      if (PnRight.Width <= cMinPreviewWidth) and IsResizePreivew and not IsIncreasing then
      begin
        SetResizeListViewMode;
        Exit;
      end;

      if (PnListView.Width > cMinListViewWidth) and not IsResizePreivew and IsIncreasing then
        SetResizePreviewMode;
    end;
  end;

  if FImageViewer <> nil then
    FImageViewer.CheckFaceIndicatorVisibility;

  FOldWidth := Width;
end;

procedure TExplorerForm.SetResizeListViewMode;
begin
  IsResizePreivew := False;

  if Visible then
    BeginScreenUpdate(Handle);
  try
    PnRight.Align := alRight;
    SplRightPanel.Align := alRight;
    PnListView.Align := alClient;
    if PnRight.Width < 100 then
      PnRight.Width := 100;
  finally
    if Visible then
      EndScreenUpdate(Handle, False);
  end;
end;

procedure TExplorerForm.SetResizePreviewMode;
var
  W: Integer;
begin
  IsResizePreivew := True;

  if Visible then
    BeginScreenUpdate(Handle);
  try
    W := PnListView.Width;
    PnRight.Align := alClient;
    PnListView.Align := alLeft;
    SplRightPanel.Align := alLeft;
    PnListView.Width := W;
  finally
    if Visible then
      EndScreenUpdate(Handle, False);
  end;
end;

procedure TExplorerForm.ConstrainedResize(var MinWidth, MinHeight, MaxWidth, MaxHeight: Integer);
begin
  inherited;
  if PnRight.Visible then
    MinWidth := MainPanel.Width + ElvMain.Constraints.MinHeight + SplLeftPanel.Width + SplRightPanel.Width + PnRight.Constraints.MinWidth;
end;

procedure TExplorerForm.ListView1Edited(Sender: TObject; Item: TEasyItem; var S: String);
var
  DS: TDataSet;
  Folder: string;
  Info: TExplorerFileInfo;
  PI: TPathItem;
  PL: TPathItemCollection;
  EO: TPathFeatureOptions;
begin
  //.Tag is index of item
  if PmItemPopup.Tag < 0 then
    Exit;

  Info := FFilesInfo[PmItemPopup.Tag];
  FDblClicked := False;

  PL := TPathItemCollection.Create;
  try
    PI := PathProviderManager.CreatePathItem(Info.FileName);
    try
      PI.LoadImage(PATH_LOAD_NO_IMAGE, 0);
      PL.Add(PI);

      if (PI <> nil) and (PI.Provider.SupportsFeature(PATH_FEATURE_RENAME)) then
      begin
        EO := TPathFeatureEditOptions.Create(S);
        try
          if not PI.Provider.ExecuteFeature(Self, PL, PATH_FEATURE_RENAME, EO) then
            S := Item.Caption;
        finally
          F(EO);
        end;
        Exit;
      end;
    finally
      F(PI);
    end;
    PL.Clear;
  finally
    F(PL);
  end;

  S := Copy(S, 1, Min(Length(S), 255));
  if AnsiLowerCase(S) = AnsiLowerCase(ExtractFileName(Info.FileName)) then
    Exit;
  begin
    if GetExt(S) <> GetExt(Info.FileName) then
      if FileExistsSafe(Info.FileName) then
      begin
        if ID_OK <> MessageBoxDB(Handle, L('Do you really want to replace extension to selected object?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        begin
          S := ExtractFileName(Info.FileName);
          Exit;
        end;
      end;
    if Info.FileType = EXPLORER_ITEM_FOLDER then
    begin
      DS := GetQuery;
      try
        Folder := IncludeTrailingBackslash(Info.FileName);
        SetSQL(DS, 'Select count(*) as CountField from $DB$ where (FFileName Like :FolderA)');
        SetStrParam(DS, 0, NormalizeDBStringLike('%' + Folder + '%'));
        DS.Open;
        if DS.FieldByName('CountField').AsInteger = 0 then
        begin
          try
            RenameResult := RenameFile(Info.FileName, ExtractFilePath(Info.FileName) + S);
          except
            RenameResult := False;
          end;
        end else
          RenameResult := RenameFileWithDB(KernelEventCallBack, Info.FileName,
            ExtractFilePath(Info.FileName) + S, Info.ID, False);
      finally
        FreeDS(DS);
      end;
    end else
      RenameResult := RenamefileWithDB(KernelEventCallBack, Info.FileName,
        ExtractFilePath(Info.FileName) + S, Info.ID, False);
  end;
end;

procedure TExplorerForm.HintTimerTimer(Sender: TObject);
var
  P, P1: Tpoint;
  Index, I: Integer;
  MenuInfo: TDBPopupMenuInfoRecord;
begin
  if BlockClosingOfWindows then
    Exit;

  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);
  if (not Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
    (ItemWithHint <> LastMouseItem) then
  begin
    HintTimer.Enabled := False;
    Exit;
  end;
  if LastMouseItem = nil then
    Exit;
  Index := LastMouseItem.index;
  if Index < 0 then
    Exit;
  Index := ItemIndexToMenuIndex(Index);
  if Index > FFilesInfo.Count - 1 then
    Exit;

  if not(CtrlKeyDown or ShiftKeyDown) then
    if Settings.Readbool('Options', 'UseHotSelect', True) then
      if not LastMouseItem.Selected then
      begin
        if not(CtrlKeyDown or ShiftKeyDown) then
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
              if LastMouseItem <> ElvMain.Items[I] then
                ElvMain.Items[I].Selected := False;
        if ShiftKeyDown then
          ElvMain.Selection.SelectRange(LastMouseItem, ElvMain.Selection.FocusedItem, False, False)
        else if not ShiftKeyDown then
        begin
          LastMouseItem.Selected := True;
        end;
      end;
  LastMouseItem.Focused := True;

  if not IsGraphicFile(FFilesInfo[Index].FileName) then
    Exit;

  HintTimer.Enabled := False;

  MenuInfo := FFilesInfo[Index].Copy;
  THintManager.Instance.CreateHintWindow(Self, MenuInfo, P, HintRealA);
end;

function TExplorerForm.HintRealA(Info: TDBPopupMenuInfoRecord): Boolean;
var
  P, P1: TPoint;
  Item: TeasyItem;
  Index: Integer;
begin
  Result := False;
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);
  Item := ItemAtPos(P1.X, P1.Y);
  if Item = nil then
    Exit;
  Index := ItemIndexToMenuIndex(Item.Index);
  Result := not((not Self.Active) or (not ElvMain.Focused) or (Item <> LastMouseItem) or
      (Item = nil) or (FFilesInfo[Index].FileName <> Info.FileName));
end;

procedure TExplorerForm.ListView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Pos, MousePos: TPoint;
  I : Integer;
  LButtonState, RButtonState: SmallInt;
  Item: TEasyItem;
  SpotX, SpotY: Integer;

begin
  if IsPopupMenuActive then
    Exit;

  PopupHandled := False;

  LButtonState := GetAsyncKeystate(VK_LBUTTON);
  RButtonState := GetAsyncKeystate(VK_RBUTTON);

  GetCursorPos(MousePos);
  if FDBCanDrag and not OutDrag then
  begin
    if (Abs(FDBDragPoint.X - MousePos.X) > 3) or (Abs(FDBDragPoint.Y - MousePos.Y) > 3) then
    if (RButtonState <> 0) or (LButtonState <> 0) then
    begin
      Pos := ElvMain.ScreenToClient(FDBDragPoint);

      Item := ItemAtPos(Pos.X, Pos.Y);
      if Item = nil then
        Exit;
      if ElvMain.Selection.FocusedItem = nil then
        ElvMain.Selection.FocusedItem := Item;

      CreateDragImage(ElvMain, DragImageList, FBitmapImageList, Item.Caption, Pos, SpotX, SpotY);

      DropFileSourceMain.ImageHotSpotX := SpotX;
      DropFileSourceMain.ImageHotSpotY := SpotY;

      SetSelected(nil);
      DropFileSourceMain.Files.Clear;
      for I := 0 to Length(fFilesToDrag) - 1 do
        DropFileSourceMain.Files.Add(fFilesToDrag[I]);
      ElvMain.Refresh;
      SelfDraging := True;

      Application.HideHint;
      THintManager.Instance.CloseHint;

      HintTimer.Enabled := False;
      FWasDragAndDrop := True;
      DropFileSourceMain.ImageIndex := 0;

      DropFileSourceMain.Execute;

      SelfDraging := False;
      DropFileTargetMain.Files.clear;
      FDBCanDrag := True;

      if not FPopupMenuWasActiveOnMouseDown then
      begin
        RestoreDragSelectedItems;
        SetLength(FListDragItems, 0);
      end;
    end;
  end;

  if THintManager.Instance.HintAtPoint(MousePos) <> nil then
    Exit;

  Item := ItemByPointImage(ElvMain, Point(X,Y), ListView);

  if LastMouseItem = Item then
    Exit;

  Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;

  if (Item <> nil) then
  begin
    LastMouseItem := Item;
    HintTimer.Enabled := False;
    if Active then
    begin
      if Settings.Readbool('Options', 'AllowPreview', True) then
        HintTimer.Enabled := True;
      ItemWithHint := LastMouseItem;
    end;
  end;
end;

procedure TExplorerForm.SetInfoToItem(Info: TDBPopupMenuInfoRecord; FileGUID: TGUID; Loaded: Boolean = False);
var
  I: Integer;
  ExplorerInfo: TExplorerFileInfo;
begin
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    ExplorerInfo := FFilesInfo[I];
    if IsEqualGUID(ExplorerInfo.SID, FileGUID) then
    begin
      ExplorerInfo.Assign(Info);
      ExplorerInfo.Loaded := Loaded;
      if CurrentViewer <> nil then
        CurrentViewer.UpdateImageInfo(Info);
      Break;
    end;
  end;
  if AnsiLowerCase(info.FileName) = AnsiLowerCase(FSelectedInfo.FileName) then
    ListView1SelectItem(nil, nil, False);
end;

procedure TExplorerForm.SpeedButton3Click(Sender: TObject);
var
  Dir: string;
  B: Boolean;
  PI: TPathItem;
  EI: TExplorerFileInfo;
begin
  B := False;

  Dir := GetCurrentPath;

  PI := PathProviderManager.CreatePathItem(GetCurrentPathW.Path);
  try
    if (PI <> nil) and (PI.Parent <> nil) then
    begin
      EI := TExplorerFileInfo.CreateFromPathItem(PI.Parent);
      try
        SetNewPathW(ExplorerPath(EI.Path, EI.FileType), False);
      finally
        F(EI);
      end;
      B := True;
    end;
  finally
    F(PI);
  end;

  if not B then
    SetNewPath('', False);
end;

procedure TExplorerForm.BeginUpdate;
begin
  if not UpdatingList then
  begin
    UpdatingList := True;
    ElvMain.BeginUpdate;
    FItemUpdateLastTime := GetTickCount;
  end;
end;

procedure TExplorerForm.EncryptLinkClick(Sender: TObject);
begin
  PmItemPopup.Tag := -1;

  if TControl(Sender).Tag = ACTION_ENCRYPT_IMAGES then
    CryptFile1Click(Sender)
  else
    ResetPassword1Click(Sender);
end;

procedure TExplorerForm.EndUpdate(Invalidate: Boolean);
begin
  if UpdatingList then
  begin
    AddItemToUpdate(nil);
    UpdatingList := False;
  end;
end;

procedure TExplorerForm.OnBeginLoadingPreviewImage(Sender: TObject; NewImage: Boolean);
var
  I, Rating: Integer;
begin
  BeginScreenUpdate(TsMediaPreview.Handle);
  try
    if NewImage then
    begin
      for I := 0 to WllPersonsPreview.ControlCount - 1 do
        if WllPersonsPreview.Controls[I] is TWebLink then
        begin
          TWebLink(WllPersonsPreview.Controls[I]).Enabled := False;
          TWebLink(WllPersonsPreview.Controls[I]).DisableStyles := True;
          TWebLink(WllPersonsPreview.Controls[I]).Font.Color := ColorDiv2(Theme.PanelColor, Theme.PanelFontColor);
        end;

      TbPreviewRating.Enabled := (not (FolderView and (FImageViewer.Item.ID = 0)) and not DBReadOnly) and not IsDevicePath(FImageViewer.Item.Path);
    end;

    Rating := FImageViewer.Item.Rating;

    TbPreviewRating.Visible := True;
    if Rating < 0 then
      TbPreviewRating.ImageIndex := 6 - Rating div 10
    else
      TbPreviewRating.ImageIndex := Rating;

    TbPreviewRatingSeparator.Visible := True;
    ToolBarPreview.Left := PnRightPreview.Width div 2 - ToolBarPreview.Width div 2;
  finally
    EndScreenUpdate(TsMediaPreview.Handle, False);
  end;
end;

procedure TExplorerForm.OnPersonsFoundOnPreview(Sender: TObject; FileName: string;
  Items: TFaceDetectionResult);
const
  PersonImageSize = 24;
var
  Data: TFaceDetectionResult;
  C, J: Integer;
  LblInfo: TStaticText;
  Wl: TWebLink;
begin
  C := 0;

  if Items <> nil then
  begin
    for J := 0 to Items.Count - 1 do
      if Items[J].Data <> nil then
        if TPersonArea(Items[J].Data).PersonID > 0 then
          Inc(C);
  end;

  //at least one person on photo
  if C > 0 then
  begin
    Data := TFaceDetectionResult.Create;
    Data.Assign(Items);
    Data.TagEx := FileName;
    TThreadTask.Create(Self, Data,
      procedure(Thread: TThreadTask; Data: Pointer)
      var
        I, J: Integer;
        FData: TFaceDetectionResult;
        PA: TPersonArea;
        P: TPerson;
        Persons: TList<TPerson>;
        NewPerson: Boolean;
      begin
        Persons:= TList<TPerson>.Create;
        FData := Data;
        try
          for I := 0 to FData.Count - 1 do
          begin
            if FData[I].Data = nil then
              Continue;

            PA := TPersonArea(FData[I].Data);
            if PA.PersonID > 0 then
            begin
              NewPerson := True;
              for J := 0 to Persons.Count - 1 do
                if Persons[J].ID = PA.PersonID then
                  NewPerson := False;

              if not NewPerson then
                Continue;

              P := PersonManager.GetPerson(PA.PersonID);
              if P <> nil then
              begin
                Persons.Add(P);
                P.CreatePreview(PersonImageSize, PersonImageSize);
              end;
            end;
          end;
          Persons.Sort(TComparer<TPerson>.Construct(
             function (const L, R: TPerson): Integer
             begin
               Result := AnsiCompareStr(L.Name, R.Name);
             end
          ));
          Thread.SynchronizeTask(
            procedure
            var
              I: Integer;
              Wl: TWebLink;
              LblInfo: TStaticText;
            begin
              if AnsiLowerCase(FData.TagEx) <> AnsiLowerCase(FImageViewer.CurentFile) then
                Exit;

              BeginScreenUpdate(TsMediaPreview.Handle);
              try
                WllPersonsPreview.Clear;
                LblInfo := TStaticText.Create(WllGroups);
                LblInfo.Parent := WllPersonsPreview;
                WllPersonsPreview.AddControl(LblInfo, True);
                LblInfo.Caption := L('Persons on photo:');

                for I := 0 to Persons.Count - 1 do
                begin
                  Wl := WllPersonsPreview.AddLink;
                  Wl.Text := Persons[I].Name;
                  Wl.Font.Style := [fsBold];
                  Wl.IconWidth := PersonImageSize;
                  Wl.IconHeight := PersonImageSize;
                  Wl.LoadBitmap(Persons[I].CreatePreview(PersonImageSize, PersonImageSize));
                  Wl.Tag := Persons[I].ID;
                  Wl.OnMouseEnter := OnPreviewPersonMouseEnter;
                  Wl.OnMouseLeave := OnPreviewPersonMouseLeave;
                  Wl.OnMouseUp := OnPreviewPersonClick;
                end;
                TsMediaPreviewResize(Self);
                WllPersonsPreview.Visible := True;
              finally
                EndScreenUpdate(TsMediaPreview.Handle, False);
              end;
            end
          );

        finally
          F(FData);
          FreeList(Persons);
        end;
      end
    );
  end else
  begin
    BeginScreenUpdate(TsMediaPreview.Handle);
    try
      WllPersonsPreview.Clear;
      if (FImageViewer.Text = '') and not Settings.ReadBool('FaceDetection', 'AutoHidePanel', False) and not FImageViewer.IsAnimatedImage then
      begin
        WllPersonsPreview.Visible := True;
        LblInfo := TStaticText.Create(WllGroups);
        LblInfo.Parent := WllPersonsPreview;
        WllPersonsPreview.AddControl(LblInfo, True);
        LblInfo.Caption := L('No persons on the photo');

        Wl := WllPersonsPreview.AddLink;
        Wl.Text := L('Select person');
        Wl.IconWidth := PersonImageSize;
        Wl.IconHeight := PersonImageSize;
        Wl.LoadFromResource('Persons');
        Wl.OnClick := DoStartPersonSelection;
        Wl.ShowHint := True;
        Wl.Hint := L('Middle mouse button or shift + selection using mouse');
      end else
        WllPersonsPreview.Visible := False;

      TsMediaPreviewResize(Self);
    finally
      EndScreenUpdate(TsMediaPreview.Handle, False);
    end;
  end;
end;

procedure TExplorerForm.OnPreviewPersonClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Wl: TWebLink;
  P: TPoint;
begin
  PmPreviewPersonItem.Images := DBKernel.ImageList;
  MiPreviewPersonFind.Caption := L('Find pictures');
  MiPreviewPersonUpdateAvatar.Caption := L('Update avatar');
  MiPreviewPersonProperties.Caption := L('Properties');

  MiPreviewPersonFind.ImageIndex := DB_IC_SEARCH;
  MiPreviewPersonUpdateAvatar.ImageIndex := DB_IC_EDIT_PROFILE;
  MiPreviewPersonProperties.ImageIndex := DB_IC_PROPERTIES;

  Wl := TWebLink(Sender);
  PmPreviewPersonItem.Tag := NativeInt(Sender);

  P := Point(Wl.Left, Wl.BoundsRect.Bottom);
  P := Wl.Parent.ClientToScreen(P);
  PmPreviewPersonItem.DoPopupEx(P.X, P.Y);

  if FImageViewer <> nil then
    FImageViewer.ResetPersonSelection;
end;

procedure TExplorerForm.OnPreviewPersonMouseEnter(Sender: TObject);
begin
  if FImageViewer <> nil then
    FImageViewer.SelectPerson(TWebLink(Sender).Tag);
end;

procedure TExplorerForm.OnPreviewPersonMouseLeave(Sender: TObject);
begin
  if BlockClosingOfWindows then
    Exit;
  if FImageViewer <> nil then
    FImageViewer.ResetPersonSelection;
end;

procedure TExplorerForm.OnPreviewUpdateButtonsState(Sender: TObject;
  Buttons: TButtonStates);
begin
  BeginScreenUpdate(TsMediaPreview.Handle);
  try
    TbPreviewPrevious.Visible := Buttons[ivbPrevious].HasState(ivbsVisible);
    TbPreviewPrevious.Enabled := Buttons[ivbPrevious].HasState(ivbsEnabled);

    TbPreviewNext.Visible := Buttons[ivbNext].HasState(ivbsVisible);
    TbPreviewNext.Enabled := Buttons[ivbNext].HasState(ivbsEnabled);

    TbPreviewNavigationSeparator.Visible := TbPreviewPrevious.Visible or TbPreviewNext.Visible;

    TbPreviewRotateCW.Visible := Buttons[ivbRotateCW].HasState(ivbsVisible);
    TbPreviewRotateCW.Enabled := Buttons[ivbRotateCW].HasState(ivbsEnabled);

    TbPreviewRotateCCW.Visible := Buttons[ivbRotateCCW].HasState(ivbsVisible);
    TbPreviewRotateCCW.Enabled := Buttons[ivbRotateCCW].HasState(ivbsEnabled);

    TbPreviewRotateSeparator.Visible := TbPreviewRotateCCW.Visible or TbPreviewRotateCCW.Visible;

    TbPreviewRating.Visible := Buttons[ivbRating].HasState(ivbsVisible);
    TbPreviewRating.Enabled := Buttons[ivbRating].HasState(ivbsEnabled);

    TbPreviewRatingSeparator.Visible := TbPreviewRating.Visible;

    ToolBarPreview.Left := PnRightPreview.Width div 2 - ToolBarPreview.Width div 2;
  finally
    EndScreenUpdate(TsMediaPreview.Handle, False);
  end
end;

procedure TExplorerForm.OnStopPersonSelection(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to WllPersonsPreview.ControlCount - 1 do
    if WllPersonsPreview.Controls[I] is TWebLink then
    begin
      TWebLink(WllPersonsPreview.Controls[I]).Enabled := True;
      TWebLink(WllPersonsPreview.Controls[I]).DisableStyles := False;
    end;
end;

procedure TExplorerForm.Open1Click(Sender: TObject);
var
  Handled: Boolean;
begin
  EasyListview1DblClick(ElvMain, cmbLeft, Point(0, 0), [ssShift], Handled);
end;

function TExplorerForm.GetCurrentPopUpMenuInfo(Item: TEasyItem; OnlySelected: Boolean = False): TExplorerFileInfos;
var
  I: Integer;
  ItemIndex: Integer;
  FileInfo: TExplorerFileInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Result := TExplorerFileInfos.Create;
  Result.IsListItem := False;
  Result.IsPlusMenu := False;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    //skip filtered items
    if not ElvMain.Items[I].Visible then
      Continue;

    if OnlySelected and not ElvMain.Items[I].Selected then
      Continue;

    ItemIndex := ItemIndexToMenuIndex(I);
    if ItemIndex > FFilesInfo.Count - 1 then
      Exit;

    FileInfo := FFilesInfo[ItemIndex];

    if (FileInfo.FileType = EXPLORER_ITEM_IMAGE) or (FileInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
    begin
      MenuRecord := FileInfo.Copy;
      MenuRecord.Selected := ElvMain.Items[I].Selected;
      MenuRecord.Exists := 1;
      Result.Add(MenuRecord);
      if Item <> nil then
        if (Item.Selected) and (ElvMain.Items[I] = Item) then
        begin
          Result.Position := Result.Count - 1;
          Result.ListItem := ElvMain.Items[I];
        end;
    end;
  end;
end;

function TExplorerForm.GetFormID: string;
begin
  Result := 'Explorer';
end;

function TExplorerForm.GetIsExplorerTreeViewVisible: Boolean;
begin
  Result := PcTasks.ActivePageIndex = 1;
end;

function TExplorerForm.GetItemsCount: Integer;
begin
  Result := ElvMain.Items.Count;
end;

function TExplorerForm.GetListView: TEasyListView;
begin
  Result := ElvMain;
end;

function TExplorerForm.GetMyComputer: string;
begin
  Result := L('My computer');
end;

procedure TExplorerForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TExplorerForm.ClearGeoLocation;
begin
  if FSelectedInfo.GeoLocation <> nil then
  begin
    FSelectedInfo.GeoLocation.Free;
    FSelectedInfo.GeoLocation := nil;
  end;
end;

procedure TExplorerForm.ClearHistogram;
begin
  if FPngNoHIstogram = nil then
    FPngNoHIstogram := GetNoHistogramImage;

  ImHistogramm.Picture.Graphic := FPngNoHIstogram;

  ImHistogramm.Stretch := False;
end;

procedure TExplorerForm.ClearList;
var
  I: Integer;
begin
  FItemUpdateTimer.Enabled := False;
  for I := 0 to ElvMain.Items.Count - 1 do
    TObject(ElvMain.Items[I].Data).Free;
  ElvMain.Items.Clear;
end;

procedure TExplorerForm.SplLeftPanelCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  Accept := (NewSize > 100) and (NewSize < Width - 200);
  if NewSize < SplLeftPanel.Left then
    FOldWidth := Width - 1
  else
    FOldWidth := Width + 1;
end;

procedure TExplorerForm.SplLeftPanelMoved(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure TExplorerForm.ListView1SelectItem(Sender: TObject;
  Item: TEasyItem; Selected: Boolean);
begin
  SelectTimer.Enabled := True;
  if (Item <> nil) and Item.Focused then
    TmrCheckItemVisibility.Restart;
end;

procedure TExplorerForm.ListViewOnCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if NewHeight < 100 then
    Resize := False;

  if ElvMain.Selection.FocusedItem <> nil then
    ElvMain.Selection.FocusedItem.Tag := IIF(IsFocusedVisible, 1, 0);
end;

procedure TExplorerForm.ChangedDBDataByID(Sender: TObject; ID: Integer;
  Params: TEventFields; Value: TEventValues);
var
  ImParams, UpdateInfoParams: TEventFields;
  I, Index, ReRotation: Integer;
  Bit: TBitmap;
  GI: TGroupItem;
  S: string;

  procedure UpdateNewInfo(Info: TExplorerFileInfos; UpdateImage: Boolean);
  var
    I: Integer;
  begin
    for I := 0 to Info.Count - 1 do
      if AnsiLowerCase(Info[I].FileName) = Value.Name then
      begin
        Info[I].SID := GetGUID;

        if HelpNo = 3 then
          Help1NextClick(Self);

        ReRotation := GetNeededRotation(Info[I].Rotation, Value.Rotate);
        Info[I].ID := ID;
        Info[I].Rating := Value.Rating;
        Info[I].Rotation := Value.Rotate;
        Info[I].Comment := Value.Comment;
        Info[I].KeyWords := Value.KeyWords;
        Info[I].Links := Value.Links;
        Info[I].Groups := Value.Groups;
        Info[I].IsDate := True;
        Info[I].IsTime := Value.IsTime;
        Info[I].Loaded := True;
        Info[I].Links := '';
        Info[I].Include := Value.Include;
        Info[I].Encrypted := Value.Encrypted;

        if UpdateImage then
        begin
          if (FBitmapImageList[Info[I].ImageIndex].Bitmap = nil) then
          begin
            Bit := TBitmap.Create;
            Bit.PixelFormat := pf24bit;
            Bit.Assign(Value.JPEGImage);
            ApplyRotate(Bit, Value.Rotate);
            FBitmapImageList[Info[I].ImageIndex].Graphic := Bit;
          end else
            ApplyRotate(FBitmapImageList[Info[I].ImageIndex].Bitmap, ReRotation);
          ElvMain.Refresh;
          if Info[I].FileName = FSelectedInfo.FileName then
            if SelCount = 1 then
              ListView1SelectItem(nil, ListView1Selected, True);
        end;

        Break;
      end;
  end;

begin
  if EventID_ShelfChanged in Params then
  begin
    PnShelf.Visible := PhotoShelf.Count > 0;
    WlGoToShelf.Text := FormatEx(L('Photo shelf ({0} items)'), [PhotoShelf.Count]);
    ElvMain.Repaint;
    Exit;
  end;
  if FCurrentTypePath = EXPLORER_ITEM_SHELF then
    if EventID_ShelfItemRemoved in Params then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(Value.Name) then
        begin
          Index := MenuIndexToItemIndex(I);
          DeleteItemWithIndex(Index);
          Break;
        end;
      Exit;
    end;
  if FCurrentTypePath = EXPLORER_ITEM_PERSON_LIST then
  begin
    if EventID_PersonAdded in Params then
    begin
      ElvMain.Selection.ClearAll;
      RefreshLinkClick(RefreshLink);
    end;
    if EventID_PersonChanged in Params then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FFilesInfo[I].ID = Value.ID then
        begin
          FFilesInfo[I].Name := Value.NewName;
          Index := MenuIndexToItemIndex(I);
          ElvMain.Items[Index].Caption := Value.NewName;
          FFilesInfo[I].UpdatePath(cPersonsPath + '\' + Value.NewName);
          FFilesInfo[I].FileName := FFilesInfo[I].Path;
          ListView1SelectItem(nil, ListView1Selected, True);
        end;
    end;
    if EventID_PersonRemoved in Params then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
        if FFilesInfo[I].ID = Value.ID then
        begin
          Index := MenuIndexToItemIndex(I);
          DeleteItemWithIndex(Index);
          Break;
        end;
    end;
  end;

  if FCurrentTypePath = EXPLORER_ITEM_GROUP_LIST then
  begin
    if EventID_GroupAdded in Params then
    begin
      ElvMain.Selection.ClearAll;
      RefreshLinkClick(RefreshLink);
    end;
    if EventID_GroupChanged in Params then
    begin
      GI := TGroupItem(Value.Data);
      S := cGroupsPath + '\' + Value.Name;
      for I := 0 to FFilesInfo.Count - 1 do
        if FFilesInfo[I].Path = S then
        begin
          FFilesInfo[I].Name := GI.GroupName;
          Index := MenuIndexToItemIndex(I);
          ElvMain.Items[Index].Caption := GI.GroupName;
          FFilesInfo[I].UpdatePath(GI.Path);
          FFilesInfo[I].FileName := FFilesInfo[I].Path;
          ListView1SelectItem(nil, ListView1Selected, True);
        end;
    end;
    if EventID_GroupRemoved in Params then
    begin
      GI := TGroupItem(Value.Data);
      for I := 0 to FFilesInfo.Count - 1 do
        if FFilesInfo[I].Path = GI.Path then
        begin
          Index := MenuIndexToItemIndex(I);
          DeleteItemWithIndex(Index);
          Break;
        end;
    end;
  end;

  if EventID_Repaint_ImageList in Params then
  begin
    ElvMain.Refresh;
    Exit;
  end;

  // TODO: remove or update next 2 lines
  if ID = -2 then
    Exit;

  if SetNewIDFileData in Params then
  begin
    UpdateNewInfo(FFilesInfo, True);

    if FEditorInfo <> nil then
      UpdateNewInfo(FEditorInfo, False);

    Exit;
  end;

  ImParams := [EventID_Param_Crypt, EventID_Param_Image, EventID_Param_Delete, EventID_Param_Critical];
  if ImParams * params<> [] then
  begin
    if ID > 0 then
      RefreshItemByID(ID)
    else
      RefreshItemByName(Value.Name, False);
  end;

  ReRotation := 0;
  UpdateInfoParams := [EventID_Param_Crypt, EventID_Param_Rotate, EventID_Param_Rating, EventID_Param_Private,
    EventID_Param_Date, EventID_Param_Time, EventID_Param_IsDate, EventID_Param_IsTime, EventID_Param_Groups,
    EventID_Param_Comment, EventID_Param_KeyWords, EventID_Param_Include];
  if UpdateInfoParams * Params <> [] then
    if ID <> 0 then
    begin
      for I := 0 to FFilesInfo.Count - 1 do
      begin
        if FFilesInfo[I].ID = ID then
        begin
          if EventID_Param_Rotate in Params then
          begin
            ReRotation := GetNeededRotation(FFilesInfo[I].Rotation, Value.Rotate);
            FFilesInfo[I].Rotation := Value.Rotate;
          end;

          if EventID_Param_Private in Params then
            FFilesInfo[I].Access := Value.Access;
          if EventID_Param_Crypt in Params then
            FFilesInfo[I].Encrypted := Value.Encrypted;
          if EventID_Param_Rating in Params then
            FFilesInfo[I].Rating := Value.Rating;
          if EventID_Param_Date in Params then
            FFilesInfo[I].Date := Value.Date;
          if EventID_Param_Time in Params then
            FFilesInfo[I].Time := Value.Time;
          if EventID_Param_Time in Params then
            FFilesInfo[I].Time := Value.Time;
          if EventID_Param_IsDate in Params then
            FFilesInfo[I].IsDate := Value.IsDate;
          if EventID_Param_IsTime in Params then
            FFilesInfo[I].IsTime := Value.IsTime;
          if EventID_Param_Groups in Params then
            FFilesInfo[I].Groups := Value.Groups;
          if EventID_Param_Comment in Params then
            FFilesInfo[I].Comment := Value.Comment;
          if EventID_Param_KeyWords in Params then
            FFilesInfo[I].KeyWords := Value.KeyWords;
          if EventID_Param_Links in Params then
            FFilesInfo[I].Links := Value.Links;
          if EventID_Param_Include in Params then
          begin
            index := MenuIndexToItemIndex(I);
            if index < ElvMain.Items.Count - 1 then
              if ElvMain.Items[I].Data <> nil then
                Boolean(TDataObject(ElvMain.Items[I].Data).Include) := Value.Include;

            FFilesInfo[I].Include := Value.Include;

            ElvMain.Items[I].BorderColor := GetListItemBorderColor(TDataObject(ElvMain.Items[I].Data));
          end;
          if [EventID_Param_Include,
              EventID_Param_Rotate,
              EventID_Param_Private,
              EventID_Param_Crypt,
              EventID_Param_Rating ] * Params <> [] then
            ElvMain.Refresh;
          Break;
        end;
      end;
    end;

  if [EventID_Param_Rotate] * Params <> [] then
  begin
    for I := 0 to FFilesInfo.Count - 1 do
    begin
      if FFilesInfo[I].ID = ID then
      begin
        Index := MenuIndexToItemIndex(I);
        if ElvMain.Items[index].ImageIndex > -1 then
          ApplyRotate(FBitmapImageList[ElvMain.Items[index].ImageIndex].Bitmap, ReRotation);

      end;
    end;
  end;

  ImParams := [EventID_Param_Refresh, EventID_Param_Rotate, EventID_Param_Rating, EventID_Param_Private];
  if ImParams * Params <> [] then
    ElvMain.Refresh;

  if [EventID_Param_DB_Changed] * Params <> [] then
  begin
    FPictureSize := ThImageSize;
    LoadSizes;
  end;

  if (EventID_Param_Name in Params) then
    if not(FileExistsSafe(Value.NewName) or DirectoryExists(Value.NewName)) and not
      (FileExistsSafe(Value.Name) or DirectoryExists(Value.Name)) then
      RefreshItemByName(Value.Name, False)
    else
      RefreshItemByName(Value.NewName, False);

  if [EventID_Param_DB_Changed, EventID_Param_Refresh_Window] * Params <> [] then
  begin
    if IsExplorerTreeViewVisible then
      TreeView.Reload;
    ElvMain.Selection.ClearAll;
    RefreshLinkClick(RefreshLink);
  end;

end;

procedure TExplorerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;
  Settings.WriteInteger('Explorer', 'SearchPanel', PnSearch.Width);
  Release;
end;

procedure TExplorerForm.SelectAll1Click(Sender: TObject);
begin
  ElvMain.Selection.SelectAll;
end;

procedure TExplorerForm.Refresh2Click(Sender: TObject);
begin
  SetNewPathW(GetCurrentPathW, False);
end;

procedure TExplorerForm.Exit2Click(Sender: TObject);
begin
  Close;
end;

procedure TExplorerForm.Addfolder1Click(Sender: TObject);
begin
  UpdaterDB.AddDirectory(GetCurrentPath)
end;

procedure TExplorerForm.Refresh1Click(Sender: TObject);
var
  I, Index: Integer;
  Info: TExplorerViewInfo;
begin
  Info := ViewInfo;
  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);

      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) then
        TExplorerThread.Create(FFilesInfo[Index].FileName, '', THREAD_TYPE_IMAGE,
          Info, Self, TUpdaterInfo.Create(FFilesInfo[Index]), StateID);

      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) then
        TExplorerThread.Create(FFilesInfo[Index].FileName, '',
          THREAD_TYPE_FOLDER_UPDATE, info, Self, TUpdaterInfo.Create(FFilesInfo[Index]), StateID);
    end;
end;

procedure TExplorerForm.RefreshItem(Number: Integer; UpdateDB: Boolean);
var
  UpdaterInfo: TUpdaterInfo;
  Index: Integer;
  NotifyInfo: TExplorerNotifyInfo;
begin
  Index := ItemIndexToMenuIndex(Number);
  UpdaterInfo := TUpdaterInfo.Create(FFilesInfo[Index]);
  try
    UpdaterInfo.UpdateDB := UpdateDB;
    if FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE then
    begin
      NotifyInfo := TExplorerNotifyInfo.Create(Self, StateID, UpdaterInfo, ViewInfo, UPDATE_MODE_REFRESH_IMAGE,
        FFilesInfo[Index].FileName, GUIDToString(FFilesInfo[Index].SID));
      ExplorerUpdateManager.QueueNotify(NotifyInfo);
      UpdaterInfo := nil;
    end else if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FILE) or (FFilesInfo[Index].FileType = EXPLORER_ITEM_EXEFILE) then
    begin
      TExplorerThread.Create(FFilesInfo[Index].FileName, '', THREAD_TYPE_FILE, ViewInfo, Self, UpdaterInfo, StateID);
      UpdaterInfo := nil;
    end;
  finally
    F(UpdaterInfo);
  end;
end;

procedure TExplorerForm.HistoryChanged(Sender: TObject);
var
  MenuBack, MenuForward: TMenuItem;
  Ico: TIcon;
begin
  TbBack.Enabled := FHistory.CanBack;
  TbForward.Enabled := FHistory.CanForward;
  PopupMenuBack.Items.Clear;
  PopupMenuBack.Tag := 0;
  PopupMenuForward.Items.Clear;
  PopupMenuForward.Tag := 0;

  ImPathDropDownMenu.Clear;

  Ico := nil;
  FindIcon(HInstance, 'SEARCH', 16, 32, Ico);
  try
    ImPathDropDownMenu.AddIcon(Ico);
  finally
    F(Ico);
  end;

  MenuBack := TMenuItem.Create(PopupMenuBack.Items);
  MenuBack.Caption := L('Loading...');
  MenuBack.ImageIndex := 0;
  PopupMenuBack.Items.Add(MenuBack);

  MenuForward := TMenuItem.Create(PopupMenuForward.Items);
  MenuForward.Caption := L('Loading...');
  MenuForward.ImageIndex := 0;
  PopupMenuForward.Items.Add(MenuForward);
end;

procedure TExplorerForm.SpeedButton1Click(Sender: TObject);
var
  Path: TExplorerPath;
begin
  if FHistory.CanBack then
  begin
    Path := FHistory.DoBack;
    if Path.FocusedItem <> '' then
      SetOldPath(Path.FocusedItem);

    SetNewPathW(Path, False);
  end;
end;

procedure TExplorerForm.SpeedButton2Click(Sender: TObject);
var
  Path: TExplorerPath;
begin
  if FHistory.CanForward then
  begin
    Path := FHistory.DoForward;
    if Path.FocusedItem <> '' then
      SetOldPath(Path.FocusedItem);

    SetNewPathW(Path, False);
  end;
end;

procedure TExplorerForm.TbForwardMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Explorer: TCustomExplorerForm;
begin
  if Button = mbMiddle then
  begin
    if FHistory.CanForward then
    begin
      Explorer := ExplorerManager.NewExplorer(False);
      Explorer.SetNewPathW(FHistory.GetForwardPath, False);
      Explorer.Show;
    end;
  end;
end;

procedure TExplorerForm.TbPreviewClick(Sender: TObject);
begin
  TbPreview.Tag := -TbPreview.Tag;
  TbPreview.Down := TbPreview.Tag < 0;

  if TbPreview.Down then
    ShowRightPanel(ertsPreview)
  else
    HideRightPanel;

  Settings.WriteBool('Explorer', 'RightPanelVisible', TbPreview.Down);
end;

procedure TExplorerForm.TbPreviewNextClick(Sender: TObject);
var
  ItemIndex: Integer;
begin
  if ElvMain.Selection.Count > 1 then
  begin
    if FImageViewer <> nil then
      FImageViewer.LoadNextFile;
  end;
  if ElvMain.Selection.Count = 1 then
  begin
    ItemIndex := ElvMain.Items.IndexOf(ElvMain.Selection.First);
    Inc(ItemIndex);
    if ItemIndex > ElvMain.Items.Count - 1 then
      ItemIndex := 0;

    ElvMain.Selection.ClearAll;
    ElvMain.Items[ItemIndex].Selected := True;
    ElvMain.Items[ItemIndex].Focused := True;
    ElvMain.Selection.First.MakeVisible(emvBottom);

  end;
  if (ElvMain.Selection.Count = 0) and (ElvMain.Items.Count > 0) then
  begin
    ElvMain.Items[0].Selected := True;
    ElvMain.Items[0].Focused := True;
    ElvMain.Selection.First.MakeVisible(emvBottom);
  end;
  ElvMain.SetFocus;
  ElvMain.Scrollbars.Update;
end;

procedure TExplorerForm.TbPreviewPreviousClick(Sender: TObject);
var
  ItemIndex: Integer;
begin
  if ElvMain.Selection.Count > 1 then
  begin
    if FImageViewer <> nil then
      FImageViewer.LoadPreviousFile;
  end;
  if ElvMain.Selection.Count = 1 then
  begin
    ItemIndex := ElvMain.Items.IndexOf(ElvMain.Selection.First);
    Dec(ItemIndex);
    if ItemIndex < 0 then
      ItemIndex := ElvMain.Items.Count - 1;

    ElvMain.Selection.ClearAll;
    ElvMain.Items[ItemIndex].Selected := True;
    ElvMain.Items[ItemIndex].Focused := True;
    ElvMain.Selection.First.MakeVisible(emvTop);

  end;
  if (ElvMain.Selection.Count = 0) and (ElvMain.Items.Count > 0) then
  begin
    ElvMain.Items[ElvMain.Items.Count - 1].Selected := True;
    ElvMain.Items[ElvMain.Items.Count - 1].Focused := True;
    ElvMain.Selection.First.MakeVisible(emvTop);
  end;

  ElvMain.Scrollbars.Update;
  ElvMain.SetFocus;
end;

procedure TExplorerForm.TbPreviewRatingClick(Sender: TObject);
var
  I, Index: Integer;
  P: TPoint;
begin
  if FImageViewer = nil then
    Exit;

  RatingPopupMenu.Tag := 0;

  if FImageViewer.Item.ID > 0 then
    RatingPopupMenu.Tag := FImageViewer.Item.ID
  else
  begin
    Index := -1;
    for I := 0 to FFilesInfo.Count - 1 do
      if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(FImageViewer.Item.FileName) then
      begin
        Index := I;
        Break;
      end;

    if Index = -1 then
      Exit;

    RatingPopupMenu.Tag := -Index;
  end;

  if Sender = nil then
    Exit;

  P := Point(TbPreviewRating.Left, TbPreviewRating.Top + TbPreviewRating.Height);
  P := TbPreviewRating.Parent.ClientToScreen(P);
  RatingPopupMenu.Popup(P.X, P.Y);
end;

procedure TExplorerForm.TbPreviewRotateCWClick(Sender: TObject);
begin
  if FImageViewer <> nil then
    FImageViewer.RotateCW;
end;

procedure TExplorerForm.TbPreviewRotateCCWClick(Sender: TObject);
begin
  if FImageViewer <> nil then
    FImageViewer.RotateCCW;
end;

procedure TExplorerForm.TsInfoResize(Sender: TObject);
begin
  BeginScreenUpdate(TsInfo.Handle);
  try
    ReRating.Left := TsInfo.Width div 2 - ReRating.Width div 2;
    WllGroups.ReallignList;
    WllGroups.AutoHeight(200);
    ReallignEditBoxes;
  finally
    EndScreenUpdate(TsInfo.Handle, False);
  end;
end;

procedure TExplorerForm.TsInfoShow(Sender: TObject);
begin
  if TsInfo.Tag = 1 then
  begin
    InitInfoEditor(False);   
    TsInfo.Tag := 0;
  end;
end;

procedure TExplorerForm.TsMediaPreviewResize(Sender: TObject);
begin
  if FImageViewer <> nil then
  begin
    WllPersonsPreview.Width := PnRightPreview.Width - 5 - WllPersonsPreview.Left;
    WllPersonsPreview.ReallignList;
    WllPersonsPreview.AutoHeight(300);

    FImageViewer.ResizeTo(PnRightPreview.Width - FImageViewer.Left * 2,
                          PnRightPreview.Height - FImageViewer.Top * 2 - ToolBarPreview.Height - 10 - WllPersonsPreview.Height);

    ToolBarPreview.Left := PnRightPreview.Width div 2 - ToolBarPreview.Width div 2;
    ToolBarPreview.Top := PnRightPreview.Height - ToolBarPreview.Height - 1 {BORDER};

    WllPersonsPreview.Top := PnRightPreview.Height - WllPersonsPreview.Height - ToolBarPreview.Height  - 1 - 5;
    LsDetectingFaces.Top := ToolBarPreview.Top;
    WlFaceCount.Top := ToolBarPreview.Top + LsDetectingFaces.Height div 2 - WlFaceCount.Height div 2;
  end;
end;

procedure TExplorerForm.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, Index: Integer;
  Item, ItemSel: TEasyItem;
begin
  WindowsMenuTickCount := GetTickCount;
  FPopupMenuWasActiveOnMouseDown := IsPopupMenuActive;
  if FPopupMenuWasActiveOnMouseDown and FWasDragAndDrop then
    RestoreDragSelectedItems;

  ItemsDeselected := False;
  FWasDragAndDrop := False;

  Item := ItemAtPos(X, Y);

  MouseDowned := Button = mbRight;
  if (Item = nil) and not CtrlKeyDown then
     ElvMain.Selection.ClearAll;

  ItemSel := Item;
  ItemByMouseDown := False;

  EnsureSelectionInListView(ElvMain, ItemSel, Shift, X, Y, ItemSelectedByMouseDown, ItemByMouseDown);

  if ((Button = MbLeft) or (Button = MbRight)) and (Item <> nil) and not FDblClicked then
  begin
    Rdown := Button = MbRight;

    FDBCanDrag := True;
    SetLength(FFilesToDrag, 0);
    SetLength(FListDragItems, 0);
    GetCursorPos(FDBDragPoint);
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        index := ItemIndexToMenuIndex(I);
        if index > FFilesInfo.Count - 1 then
          Exit;
        if (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType = EXPLORER_ITEM_FILE) or
          (FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE) or (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) or
          (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) then
        begin
          SetLength(FListDragItems, Length(FListDragItems) + 1);
          FListDragItems[Length(FListDragItems) - 1] := ElvMain.Items[I];
          SetLength(FFilesToDrag, Length(FFilesToDrag) + 1);
          FFilesToDrag[Length(FFilesToDrag) - 1] := FFilesInfo[index].FileName;
        end;
      end;
    if Length(FFilesToDrag) = 0 then
      FDBCanDrag := False;
  end;
  FDblClicked := False;
end;

procedure TExplorerForm.ListView1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Handled: Boolean;
  Item: TEasyItem;
  WasDBDrag: Boolean;
begin
  WasDBDrag := FDBCanDrag;
  FDBCanDrag := False;
  FDBCanDragW := False;

  Item := Self.ItemAtPos(X, Y);
  RightClickFix(ElvMain, Button, Shift, Item, ItemByMouseDown, ItemSelectedByMouseDown);

  if MouseDowned and (Button = MbRight) then
  begin
    MouseDowned := False;
    ListView1ContextPopup(ElvMain, Point(X, Y), Handled);
    WindowsMenuTickCount := GetTickCount;
    PopupHandled := True;
  end else
    MouseDowned := False;

 if WasDBDrag and ItemsDeselected then
  begin
    If (Abs(FDBDragPoint.X - X) > 3) or (Abs(FDBDragPoint.Y - Y) > 3) then
      if not FWasDragAndDrop then
        Exit;

    RestoreDragSelectedItems;
  end;
  if WasDBDrag then
  begin
    SetLength(FFilesToDrag, 0);
    SetLength(FListDragItems, 0);
  end;
end;

procedure TExplorerForm.ListView1Exit(Sender: TObject);
begin
  RDown := False;
  FDblClicked := False;
  FDBCanDrag := False;
  FDBCanDragW := False;
  SetLength(FFilesToDrag, 0);
end;

procedure TExplorerForm.RefreshItemByID(ID: Integer);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if FFilesInfo[I].ID = ID then
    begin
      if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(FSelectedInfo.FileName) then
        ListView1SelectItem(nil, ListView1Selected, True);

      Index := MenuIndexToItemIndex(I);
      RefreshItem(Index, False);
      Break;
    end;
  end;
end;

procedure TExplorerForm.RefreshItemByName(Name: string; UpdateDB: Boolean);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(name) then
    begin
      Index := MenuIndexToItemIndex(I);
      if Name = FSelectedInfo.FileName then
        ListView1SelectItem(nil, ListView1Selected, False);

      RefreshItem(Index, UpdateDB);
      Break;
    end;
  end;
end;

procedure TExplorerForm.MakeNewFolder1Click(Sender: TObject);
var
  S, FolderName: String;
  N: Integer;
begin
  FolderName := L('New directory');
  S := IncludeTrailingBackslash(GetCurrentPath);
  N := 1;
  if DirectoryExists(S + FolderName) then
  begin
    repeat
      Inc(N);
    until not DirectoryExists(S + FolderName + ' (' + Inttostr(N) + ')');
    FolderName := FolderName + ' (' + Inttostr(N) + ')';
  end;
  NewFileName := AnsiLowerCase(S + FolderName);
  if not CreateDir(S + FolderName) then
  begin
    MessageBoxDB(Handle, Format(L('Unable to create directory %s!'), [S + FolderName]), L('Error'), TD_BUTTON_OK,
      TD_ICON_ERROR);
    Exit;
  end;
end;

procedure TExplorerForm.OpenInNewWindow1Click(Sender: TObject);
var
  Explorer: TCustomExplorerForm;
begin
  Explorer := ExplorerManager.NewExplorer(False);
  Explorer.SetNewPathW(Self.GetCurrentPathW, False);
  Explorer.Show;
end;

procedure TExplorerForm.GetCurrentImage(W, H: Integer; out Image: TGraphic);
var
  I, Index: Integer;
  B: TBitmap;
  FileName: string;
begin
  Image := nil;
  if SelCount = 0 then
    Exit;
  if SelCount = 1 then
  begin
    FileName := AnsiLowerCase(FSelectedInfo.FileName);
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      if ElvMain.Items[I].ImageIndex <> -1 then
      begin
        Index := ItemIndexToMenuIndex(I);
        if AnsiLowerCase(FFilesInfo[Index].FileName) = FileName then
        begin
          if FBitmapImageList[ElvMain.Items[I].ImageIndex].IsBitmap then
          begin
            B := FBitmapImageList[ElvMain.Items[I].ImageIndex].Bitmap;
            Image := TBitmap.Create;
            Image.Assign(B);
          end else if FBitmapImageList[ElvMain.Items[I].ImageIndex].Icon <> nil then
          begin
            Image := TIcon.Create;
            Image.Assign(FBitmapImageList[ElvMain.Items[I].ImageIndex].Icon);
          end;
        end;
      end;
    end;
  end else
  begin
    Image := TBitmap.Create;
    CreateMultiselectImage(ElvMain, TBitmap(Image), FBitmapImageList, ElvMain.Selection.GradientColorBottom, ElvMain.Selection.GradientColorTop,
      ElvMain.Selection.Color, ElvMain.Font, ThSizeExplorerPreview + 3, ThSizeExplorerPreview + 3);
  end;
end;

function TExplorerForm.GetCurrentImageFileName: string;
var
  Index: Integer;
begin
  Result := '';
  if SelCount > 0 then
  begin
    if ElvMain.Selection.FocusedItem <> nil then
    begin
      Index := ItemIndexToMenuIndex(ElvMain.Selection.FocusedItem.Index);
      Result := FFilesInfo[Index].FileName;
    end;
  end;
end;

function TExplorerForm.GetCurrentPath: string;
begin
  Result := GetCurrentPathW.Path;
end;

procedure TExplorerForm.SetPath(NewPath: String);
begin
  if not Visible then
  begin
    SaveWindowPos1.Key := RegRoot + 'Explorer\' + MakeRegPath(NewPath);
    SaveWindowPos1.SetPosition;
    FixFormPosition;
  end;
  FCurrentPath := NewPath;
  SetNewPath(NewPath, False);
end;

procedure TExplorerForm.ShowUpdater1Click(Sender: TObject);
begin
  UpdaterDB.ShowWindowNow;
end;

procedure TExplorerForm.FormDeactivate(Sender: TObject);
begin
  FDBCanDrag := False;
  FDBCanDragW := False;
  HintTimer.Enabled := False;
end;

procedure TExplorerForm.Select(Item: TEasyItem; GUID: TGUID);
begin
  if (Item <> nil) then
    FSelectedItem := Item;
end;

function TExplorerForm.ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include: Boolean; Big: Boolean = False): Boolean;
var
  I, Index, C: Integer;
  Item: TEasyItem;
  info: TExplorerFileInfo;
begin
  Result := False;
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    info := FFilesInfo[I];
    if IsEqualGUID(info.SID, FileGUID) then
    begin
      Index := MenuIndexToItemIndex(I);
      Item := ElvMain.Items[Index];
      if Bitmap = nil then
      begin
        AddItemToUpdate(Item);
        Exit;
      end;

      if (Info.IsBigImage) and (Big = True) // если загружается большая картинка впервые
        then
        Exit;

      if Big then
        info.IsBigImage := True;

      if Index > ElvMain.Items.Count - 1 then
        Exit;
      C := Item.ImageIndex;
      if Item.Data <> nil then
      begin
        Boolean(TDataObject(Item.Data).Include) := Include;
      end else
      begin
        Item.Data := TDataObject.Create;
        TDataObject(Item.Data).Include := Include;
      end;
      if C = -1 then
      begin
        FBitmapImageList.AddBitmap(nil);
        info.ImageIndex := FBitmapImageList.Count - 1;
        C := FBitmapImageList.Count - 1;
      end;

      FBitmapImageList[C].Graphic := Bitmap;
      FBitmapImageList[C].SelfReleased := True;
      Result := True;

      AddItemToUpdate(Item);

      if Info.FileType = EXPLORER_ITEM_FOLDER then
        if Info.FileName = FSelectedInfo.FileName then
          if SelCount = 1 then
            ListView1SelectItem(nil, ListView1Selected, True);
      Break;
    end;
  end;
end;

function TExplorerForm.ReplaceIcon(Icon: TIcon; FileGUID: TGUID; Include : boolean): Boolean;
var
  I, Index, C: Integer;
  Item: TEasyItem;
begin
  Result := False;
  for I := 0 to FFilesInfo.Count - 1 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      index := MenuIndexToItemIndex(I);
      if index > ElvMain.Items.Count - 1 then
        Exit;

      Item := ElvMain.Items[Index];
      C := Item.ImageIndex;
      if Item.Data <> nil then
      begin
        TDataObject(Item.Data).Include := Include;
      end else
      begin
        Item.Data := TDataObject.Create;
        TDataObject(Item.Data).Include := Include;
      end;
      FBitmapImageList[C].Graphic := Icon;
      FBitmapImageList[C].SelfReleased := True;
      Result := True;

      AddItemToUpdate(Item);

      if FFilesInfo[I].FileType = EXPLORER_ITEM_FOLDER then
        if FFilesInfo[I].FileName = FSelectedInfo.FileName then
          if SelCount = 1 then
            ListView1SelectItem(nil, ListView1Selected, True);
      Break;
    end;
end;

function TExplorerForm.SetFileIsEncrypted(FileGUID: TGUID;
  IsEncrypted: Boolean): Boolean;
var
  I, Index: Integer;
  Item: TEasyItem;
begin
  Result := False;
  for I := 0 to FFilesInfo.Count - 1 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      Index := MenuIndexToItemIndex(I);
      if index > ElvMain.Items.Count - 1 then
        Exit;

      Item := ElvMain.Items[Index];

      FFilesInfo[I].Encrypted := IsEncrypted;
      AddItemToUpdate(Item);
      Break;
    end;
end;

procedure TExplorerForm.ReRatingChange(Sender: TObject);
begin
  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.ReRatingMouseDown(Sender: TObject);
begin
  if ReRating.Islayered then
    ReRating.Islayered := False;

  BtnSaveInfo.Enabled := True;
end;

function TExplorerForm.AddBitmap(Bitmap: TBitmap; FileGUID: TGUID): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := FFilesInfo.Count - 1 downto 0 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      Result := True;
      FBitmapImageList.AddBitmap(Bitmap);
      FFilesInfo[I].ImageIndex := FBitmapImageList.Count - 1;
      Break;
    end;
end;

function TExplorerForm.AddIcon(Icon: TIcon; SelfReleased: Boolean; FileGUID: TGUID): Boolean;
var
  Index, I: Integer;
begin
  Result := False;
  for I := FFilesInfo.Count - 1 downto 0 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
      begin
        Index := FFilesInfo[I].ImageIndex;
        if Index > -1 then
        begin
          FBitmapImageList.Items[I].UpdateIcon(Icon, SelfReleased);
          Result := True;
          Break;
        end;
        FBitmapImageList.AddIcon(Icon, SelfReleased);
        FFilesInfo[I].ImageIndex := FBitmapImageList.Count - 1;
        Result := True;
        Break;
      end;
end;

function TExplorerForm.AddItem(FileGUID: TGUID; LockItems: Boolean = True; Sort: Integer = -1): TEasyItem;
var
  I, Index, Count: Integer;
  Data: TDataObject;
  FI: TExplorerFileInfo;

  function GetNewItemPos(Info: TExplorerFileInfo): Integer;
  var
    X: TExplorerFileInfo;
    N, First, last, mid: Integer;

    function A_0(Index: Integer): TExplorerFileInfo;
    begin
      Result := FFilesInfo[ItemIndexToMenuIndex(Index)];
    end;

    function Cmp(I1, I2: TExplorerFileInfo): Integer;
    begin
      if I1.FileType <> I2.FileType then
      begin
        Result := I1.FileType - I2.FileType;
        Exit;
      end;
      Result := AnsiCompareStr(AnsiLowerCase(I1.FileName), AnsiLowerCase(I2.FileName));
    end;

  begin
    Result := -1;
    if ElvMain.Items.Count = 0 then
      Exit;

    if Sort = 0 then
    begin
      First := 0;
      X := info;
      N := ElvMain.Items.Count;
      last := N;

      if (Cmp(A_0(0), X) > 0) then
      begin
        Result := 0;
        Exit;
      end else if (Cmp(A_0(n - 1), x) < 0) then
      begin
        Exit;
      end;

      while (First < last) do
      begin
        mid := First + (last - First) div 2;

        if (Cmp(X, A_0(mid)) <= 0) then
          last := mid
        else
          First := mid + 1;
      end;

      Result := last;
    end;
  end;

begin
  Result := nil;
  Count := FFilesInfo.Count;
  for I := Count - 1 downto 0 do
  begin
    FI := FFilesInfo[I];
    if IsEqualGUID(FI.SID, FileGUID) then
    begin
      LockDrawIcon := True;

      Data := TDataObject.Create;
      Data.Include := FI.Include;

      // without sorting
      if Sort = -1 then
        Result := ElvMain.Items.Add(Data)
      else if Sort = 0 then
      begin
        Index := GetNewItemPos(FI);
        if Index = -1 then
          Result := ElvMain.Items.Add(Data)
        else
        begin
          Result := ElvMain.Items.Insert(Index);
          Result.Data := Data;
        end;
      end;

      if not Data.Include then
        Result.BorderColor := GetListItemBorderColor(Data);

      Result.Tag := FI.FileType;
      Result.ImageIndex := FI.ImageIndex;

      if FI.Name = '' then
        Result.Caption := ExtractFileName(FI.FileName)
      else
        Result.Caption := FI.Name;

      if IsEqualGUID(FileGUID, NewFileNameGUID) then
      begin
        Result.Selected := True;
        Result.Focused := True;
        ElvMain.EditManager.Enabled := True;
        Result.Edit;
        NewFileNameGUID := GetGUID;
      end else
        MakeItemVisibleByFilter(Result, '');

      LockDrawIcon := False;
      if not UpdatingList and ElvMain.Groups[0].Visible then
        AddItemToUpdate(Result);
      Break;
    end;
  end;
end;

function TExplorerForm.AddItemW(Caption: string; FileGUID: TGUID): TEasyItem;
var
  I: Integer;
  Data: TDataObject;
begin
  Result := nil;
  for I := 0 to FFilesInfo.Count - 1 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      LockDrawIcon := True;
      Data := TDataObject.Create;
      Data.Include := True;
      Result := ElvMain.Items.Add(Data);
      if not Data.Include then
        Result.BorderColor := GetListItemBorderColor(Data);
      Result.Tag := FFilesInfo[I].FileType;
      Result.ImageIndex := FFilesInfo[I].ImageIndex;
      Result.Caption := Caption;
      MakeItemVisibleByFilter(Result, '');

      LockDrawIcon := False;
      if ElvMain.Groups[0].Visible then
        AddItemToUpdate(Result);
      Break;
    end;
end;

procedure TExplorerForm.ListView1KeyPress(Sender: TObject; var Key: Char);
var
  Handled: Boolean;
begin
  if Key = Chr(VK_RETURN) then
    EasyListview1DblClick(ElvMain, cmbLeft, Point(0, 0), [], Handled);
end;

procedure TExplorerForm.AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
var
  InternalHandled: Boolean;
  I: Integer;
  P: TPoint;
  H: THandle;
  R: TRect;
begin
  if Msg.hwnd = Handle then
  begin
    if Msg.message = FReloadGroupsMessage then
    begin
      Handled := True;
      InitEditGroups;
    end;

    if Msg.message = FReloadESGroupsMessage then
    begin
      Handled := True;
      ExtendedSearchInitGroups;
    end;

    if Msg.message = FReloadRSPersonsMessage then
    begin
      Handled := True;
      ExtendedSearchInitPersons;
    end;

    if Msg.message = FWebBrowserJSMessage then
    begin
      Handled := True;
      WlSaveLocationClick(Self);
    end;
  end;

  if Msg.message = WM_LBUTTONDOWN then
  begin
    if not PnSelectDatePopup.HasHandle(Msg.hwnd) then
      PnSelectDatePopup.Hide;

    if RtPopupRating.Handle <> Msg.hwnd then
      RtPopupRating.Hide;
  end;

  if not Self.Active then
    Exit;

  if (Msg.message = WM_MOUSEWHEEL) and TsInfo.Visible then
    WllGroups.PerformMouseWheel(Msg.WParam, Handled);

  if (Msg.message = WM_MOUSEWHEEL) and TsDetailedSearch.Visible then
  begin
    WllExtendedSearchPersons.PerformMouseWheel(Msg.WParam, Handled);
    WllExtendedSearchGroups.PerformMouseWheel(Msg.WParam, Handled);
  end;

  if TsMediaPreview.Visible and (PcRightPreview.ActivePageIndex = Integer(ertsPreview)) then
  begin
    if (Msg.message = WM_MOUSEWHEEL) then
    begin
      Handled := False;
      WllPersonsPreview.PerformMouseWheel(Msg.WParam, Handled);
      if not (Handled and (GetWindowLong(WllPersonsPreview.Handle, GWL_STYLE) and WS_VSCROLL <> 0)) then
      begin
        R.TopLeft := PnRightPreview.ClientToScreen(PnRightPreview.BoundsRect.TopLeft);
        R.BottomRight := PnRightPreview.ClientToScreen(PnRightPreview.BoundsRect.BottomRight);

        if PtInRect(R, Msg.pt) then
        begin
          Handled := True;
          if NativeInt(Msg.wParam) < 0 then
            TbPreviewNextClick(Self)
          else
            TbPreviewPreviousClick(Self);
        end;
      end;
    end;

    if (Msg.message = WM_KEYDOWN) and CtrlKeyDown then
    begin
      TbPreviewRatingClick(nil);
      if RatingPopupMenu.Tag <> 0 then
      begin
        if (Msg.wParam = Byte('0')) or (Msg.wParam = Byte(VK_NUMPAD0)) then N05Click(N00);
        if (Msg.wParam = Byte('1')) or (Msg.wParam = Byte(VK_NUMPAD1)) then N05Click(N01);
        if (Msg.wParam = Byte('2')) or (Msg.wParam = Byte(VK_NUMPAD2)) then N05Click(N02);
        if (Msg.wParam = Byte('3')) or (Msg.wParam = Byte(VK_NUMPAD3)) then N05Click(N03);
        if (Msg.wParam = Byte('4')) or (Msg.wParam = Byte(VK_NUMPAD4)) then N05Click(N04);
        if (Msg.wParam = Byte('5')) or (Msg.wParam = Byte(VK_NUMPAD5)) then N05Click(N05);
      end;
    end;
    if (Msg.message = WM_KEYDOWN) and (Msg.wParam = VK_ESCAPE) then
    begin
      if FImageViewer <> nil then
        FImageViewer.StopPersonSelection;
    end;
  end;

  if Msg.Message = WM_KEYDOWN then
  begin
    if (Msg.Wparam = VK_BACK) and ElvMain.Focused then
    begin
      if TbUp.Enabled then
        TbUp.Click
    end;

    // search by F3
    if (Msg.Wparam = VK_F3) then
      WedSearch.SetFocus;

    if (Msg.Wparam = VK_ESCAPE) and IsExplorerTreeViewVisible and TreeView.Focused and not PnFilter.Visible then
      TreeView.SetFilter('', True);;

    // filter by Ctrl+F
    if CtrlKeyDown and (Msg.Wparam = Ord('F')) then
    begin
      ShowHideFilter(Self);
      Msg.Message := 0;
    end;
  end;

  if Msg.message = WM_MOUSEWHEEL then
  begin

    if IsExplorerTreeViewVisible then
    begin
      GetCursorPos(P);
      P := TreeView.ScreenToClient(P);
      if PtInRect(TreeView.ClientRect, P) then
      begin
        TreeView.SetFocus;
        SendMessage(TreeView.Handle, Msg.message, Msg.wParam, Msg.lParam);
        Msg.message := 0;
      end;
    end;

    //activate browser on mowse wheel
    H := GetFocus;
    if TsGeoLocation.Visible and (FWbGeoLocation <> nil) then
    begin
      GetCursorPos(P);
      P := FWbGeoLocation.ScreenToClient(P);
      if PtInRect(FWbGeoLocation.ClientRect, P) then
      begin
        if FWbGeoLocation.Document <> nil then
        begin
          with FWbGeoLocation do
          if Document <> nil then
            with Application as IOleobject do
              DoVerb(OLEIVERB_UIACTIVATE, nil, FWbGeoLocation, 0, Handle, GetClientRect);

          H := GetWindow(FWbGeoLocation.Handle, GW_CHILD);
          H := GetWindow(H, GW_CHILD); // this is handle that you need

          SendMessage(H, Msg.message, Msg.wParam, Msg.lParam);
          Msg.message := 0;
        end;
      end;
    end;

    if H <> ElvMain.Handle then
    begin
      GetCursorPos(P);
      P := ElvMain.ScreenToClient(P);
      if PtInRect(ElvMain.ClientRect, P) then
        Winapi.Windows.SetFocus(ElvMain.Handle);
    end;
  end;

  if Msg.HWnd = ElvMain.Handle then
  begin
    if ((Msg.message = WM_RBUTTONDOWN) or
       (Msg.message = WM_LBUTTONDBLCLK) or
      (Msg.Message = WM_LBUTTONDOWN)) then
      begin
        WindowsMenuTickCount := GetTickCount;

        if PnRight.Visible then
          Winapi.Windows.SetFocus(ElvMain.Handle);
      end;

    if (Msg.message = WM_MOUSEMOVE) and (ebcsDragSelecting in ElvMain.States) then
      WindowsMenuTickCount := GetTickCount;

    if UpdatingList then
    begin
      if Msg.Message = WM_RBUTTONDOWN then
        Msg.Message := 0;
      if Msg.Message = WM_LBUTTONDBLCLK then
        Msg.Message := 0;
      if Msg.Message = WM_LBUTTONDOWN then
      begin
        SetLength(FFilesToDrag, 0);
        SetLength(FListDragItems, 0);
        FDBCanDrag := False;
        FDBCanDragW := False;
        Msg.Message := 0;
      end;
    end;

    if Msg.Message = WM_MOUSEWHEEL then
    begin
      if CtrlKeyDown then
      begin
        if NativeInt(Msg.Wparam) > 0 then
          I := 1
        else
          I := -1;
        ListView1MouseWheel(ElvMain, [SsCtrl], I, Point(0, 0), InternalHandled);

        Msg.Message := 0;
      end;

      Application.HideHint;
      THintManager.Instance.CloseHint;
    end;

    // middle mouse button
    if Msg.Message = WM_MBUTTONDOWN then
    begin
      Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
      BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
      Msg.Message := 0;
    end;
  end;

  if Msg.Message = WM_KEYDOWN then
  begin
    WindowsMenuTickCount := GetTickCount;
    if (Msg.Wparam = VK_LEFT) and CtrlKeyDown and TbBack.Enabled then
      SpeedButton1Click(Self);
    if (Msg.Wparam = VK_RIGHT) and CtrlKeyDown and TbForward.Enabled then
      SpeedButton2Click(Self);
    if (Msg.Wparam = VK_UP) and CtrlKeyDown and TbUp.Enabled then
      SpeedButton3Click(Self);
    if (Msg.Wparam = 83) and CtrlKeyDown then
      if PePath.CanBreakLoading then
        TbStopClick(Self);
    if (Msg.Wparam = VK_F5) then
    begin
      SetNewPathW(GetCurrentPathW, True);
      Msg.Wparam := 0;
    end;
  end;

  if Msg.HWnd = ElvMain.Handle then
    if Msg.Message = WM_KEYDOWN then
    begin
      WindowsMenuTickCount := GetTickCount;

      if (Msg.Wparam = 93) and CtrlKeyDown then
      begin
        if SelCount = 0 then
          ListView1ContextPopup(nil, ElvMain.ClientToScreen(Point(ElvMain.Left, ElvMain.Top)), InternalHandled);
      end;

      if (Msg.Wparam = VK_APPS) then
        ListView1ContextPopup(ElvMain, Point(-1, -1), InternalHandled);

      if (Msg.Wparam = VK_SUBTRACT) then
        ZoomOut;
      if (Msg.Wparam = VK_ADD) then
        ZoomIn;

      if (Msg.Wparam = VK_F2) then
        if ((FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP)) then
        begin
          if ListView1Selected <> nil then
          begin
            PmItemPopup.Tag := ItemIndexToMenuIndex(ListView1Selected.Index);
            Rename1Click(Self);
          end;
        end;

      if (Msg.Wparam = VK_DELETE) and ShiftKeyDown then
      begin
        DeleteFiles(False);
        Exit;
      end;

      if (Msg.Wparam = VK_DELETE) then
        DeleteFiles(True);

      if (Msg.Wparam = 67) and CtrlKeyDown then
        CopyClick(nil);
      if (Msg.Wparam = 88) and CtrlKeyDown then
        CutClick(nil);
      if (Msg.Wparam = 86) and CtrlKeyDown then
        PasteClick(nil);
      if (Msg.Wparam = 65) and CtrlKeyDown then
        SelectAll1Click(nil);
    end;
end;

procedure TExplorerForm.ApplySettings;
begin
  FShowAttributes := Settings.Readbool('Options', 'Explorer_ShowAttributes', True);
  FShowEXIFAttributes := Settings.ReadBool('Options', 'ShowEXIFMarker', False);
end;

procedure TExplorerForm.ApplyStyle;
begin
  inherited;
  SetLVSelection(ElvMain, True);
  CreateBackgrounds;
  InitSearch;
  if not (StyleServices.Enabled and TStyleManager.IsCustomStyleActive) then
    PnNavigation.Color := Theme.EditColor;

  //tabs
  FLeftTabs := [eltsTasks, eltsExplorer];
  if TbSearch.Down then
    FLeftTabs := FLeftTabs + [eltsSearch];

  FActiveLeftTab := eltsExplorer;
  ShowActiveLeftTab(TExplorerLeftTab(Settings.ReadInteger('Explorer', 'LeftPanelTabIndex', Integer(eltsExplorer))));

  //hack for second explorer window, preview panel is hidden
  if FActiveLeftTab = eltsTasks then
    PcTasks.ActivePageIndex := Integer(eltsExplorer);
  ApplyLeftTabs;

  FRightTabs := [ertsPreview, ertsMap];
  FActiveRightTab := ertsPreview;
  ShowActiveRightTab(TExplorerRightTab(Settings.ReadInteger('Explorer', 'RightPanelTabIndex', Integer(ertsPreview))));
  ApplyRightTabs;

  if (StyleServices.Enabled and TStyleManager.IsCustomStyleActive) then
  begin
    PnNavigation.ParentBackground := False;
    PnSearch.ParentBackground := False;
    PnSearchEditPlace.ParentBackground := False;
    WedSearch.Color := Theme.PanelColor;
    WedSearch.Font.Color := Theme.PanelFontColor;

    EdExtendedSearchText.Color := Theme.PanelColor;
    EdExtendedSearchText.Font.Color := Theme.PanelFontColor;

    BvSeparatorAddress.Hide;
  end;
  LsMain.Color := Theme.ListViewColor;
  LsMain.SignColor := Theme.ListViewFontColor;

  TmrDelayedStart.Enabled := True;
end;

procedure TExplorerForm.Back1Click(Sender: TObject);
begin
  SpeedButton1Click(Sender);
end;

procedure TExplorerForm.Forward1Click(Sender: TObject);
begin
  SpeedButton2Click(Sender);
end;

procedure TExplorerForm.Up1Click(Sender: TObject);
begin
  SpeedButton3Click(Sender);
end;

procedure TExplorerForm.DeleteItemWithIndex(Index: Integer);
var
  MenuIndex: Integer;
  IsOneSelectedItem: Boolean;
begin
  LockItems;
  try
    IsOneSelectedItem := ElvMain.Items[Index].Selected and (ElvMain.Selection.Count = 1);
    MenuIndex := ItemIndexToMenuIndex(Index);
    TObject(ElvMain.Items[Index].Data).Free;
    ElvMain.Items.Delete(Index);
    ElvMain.Groups.ReIndexItems(True);
    FFilesInfo.Delete(MenuIndex);
    if IsOneSelectedItem and (Index < ElvMain.Items.Count - 1) then
    begin
      ElvMain.Items[Index].Selected := True;
      ElvMain.Items[Index].Focused := True;
    end;
  finally
    UnLockItems;
  end;
end;

procedure TExplorerForm.DeleteIndex1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := ElvMain.Items.Count - 1 downto 0 do
  begin
    if ElvMain.Items[I].Selected then
      DeleteItemWithIndex(I);
  end;
end;

procedure TExplorerForm.DirectoryChanged(Sender: TObject; SID: TGUID; PInfo: TInfoCallBackDirectoryChangedArray);
var
  I, K, Index: Integer;
  UpdaterInfo: TUpdaterInfo;
  FileName, FOldFileName: string;
  Info: TExplorerFileInfo;
  NotifyInfo: TExplorerNotifyInfo;
begin
  if not FormLoadEnd then
    Exit;
  if not IsActualState(SID) and not IsSystemState(SID) then
    Exit;

  for K := 0 to Length(PInfo) - 1 do
  begin
    case PInfo[K].FAction of
      FILE_ACTION_ADDED,
      FILE_ACTION_REMOVED:
       if TLockFiles.Instance.IsFileLocked(PInfo[K].FNewFileName) then
         PInfo[K].FAction := 0;
      FILE_ACTION_RENAMED_NEW_NAME:
       if TLockFiles.Instance.IsFileLocked(PInfo[K].FNewFileName) then
       begin
         if not TLockFiles.Instance.IsFileLocked(PInfo[K].FOldFileName) then
         begin
           //remove old file from view
           PInfo[K].FAction := FILE_ACTION_REMOVED;
           PInfo[K].FNewFileName := PInfo[K].FOldFileName;
         end else
           PInfo[K].FAction := 0;
       end;
    end;

    case PInfo[K].FAction of
      FILE_ACTION_ADDED:
        begin
          if FolderView then
            if GetExt(PInfo[K].FOldFileName) = 'LDB' then
              Exit;

          Info := TExplorerFileInfo.Create;
          try
            Info.FileName := PInfo[K].FNewFileName;

            UpdaterInfo := TUpdaterInfo.Create(Info);
            UpdaterInfo.IsUpdater := True;
            UpdaterInfo.NewFileItem := Self.NewFileName = AnsiLowerCase(Info.FileName);

            Self.NewFileName := '';
            NotifyInfo := TExplorerNotifyInfo.Create(Self, StateID, UpdaterInfo, ViewInfo, UPDATE_MODE_ADD, '', '');
            ExplorerUpdateManager.QueueNotify(NotifyInfo);
          finally
            F(Info);
          end;
        end;
      FILE_ACTION_REMOVED:
        begin
          if ElvMain = nil then
            Exit;
          if ElvMain.Items = nil then
            Exit;

          if IsExplorerTreeViewVisible then
            TreeView.DeletePath(PInfo[K].FNewFileName);

          for I := 0 to ElvMain.Items.Count - 1 do
          begin
            FOldFileName := PInfo[K].FNewFileName;
            Index := ItemIndexToMenuIndex(I);
            if Index > FFilesInfo.Count - 1 then
              Exit;
            FileName := FFilesInfo[Index].FileName;

            if FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER then
            begin
              FileName := IncludeTrailingBackslash(FileName);
              FOldFileName := IncludeTrailingBackslash(FOldFileName);
            end;
            if AnsiLowerCase(FileName) = AnsiLowerCase(FOldFileName) then
            begin
              DeleteItemWithIndex(I);
              Break;
            end;
          end;
          Continue;
        end;
      FILE_ACTION_MODIFIED:
        begin
          if not UpdatingNow(PInfo[K].FNewFileName) then
          begin
            AddUpdateID(PInfo[K].FNewFileName);
            RefreshItemByName(PInfo[K].FNewFileName, True);
          end;
          Continue;
        end;
      FILE_ACTION_RENAMED_NEW_NAME:
        begin
          if ElvMain = nil then
            Exit;
          if ElvMain.Items = nil then
            Exit;
          for I := 0 to ElvMain.Items.Count - 1 do
          begin
            Index := ItemIndexToMenuIndex(I);
            if index > FFilesInfo.Count - 1 then
              Exit;
            if AnsiLowerCase(FFilesInfo[index].FileName) = AnsiLowerCase(PInfo[K].FOldFileName) then
            begin
              if (not DirectoryExists(PInfo[K].FOldFileName) and DirectoryExists(PInfo[K].FNewFileName)) or
                (not FileExistsSafe(PInfo[K].FOldFileName) and FileExistsSafe(PInfo[K].FNewFileName)) then
              begin
                ElvMain.Items[I].Caption := ExtractFileName(PInfo[K].FNewFileName);
                FFilesInfo[index].FileName := PInfo[K].FNewFileName;
                if FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE then
                  if not IsGraphicFile(PInfo[K].FNewFileName) then
                  begin
                    FFilesInfo[index].FileType := EXPLORER_ITEM_FILE;
                    FFilesInfo[index].ID := 0;
                  end;
                if FFilesInfo[index].FileType = EXPLORER_ITEM_FILE then
                  if IsGraphicFile(PInfo[K].FNewFileName) then
                  begin
                    FFilesInfo[index].FileType := EXPLORER_ITEM_IMAGE;
                  end;
                if GetExt(PInfo[K].FOldFileName) <> GetExt(PInfo[K].FNewFileName) then
                  RefreshItem(I, True);
                if AnsiLowerCase(FSelectedInfo.FileName) = AnsiLowerCase(PInfo[K].FOldFileName) then
                  ListView1SelectItem(ElvMain, ListView1Selected, ListView1Selected = nil);
              end
              else
                RenamefileWithDB(KernelEventCallBack, PInfo[K].FOldFileName, PInfo[K].FNewFileName, FFilesInfo[index].ID, True);
              Continue;
            end;
          end;
        end;
    end;
  end;
end;

procedure TExplorerForm.WlGeoLocationClick(Sender: TObject);
var
  ImageName: string;
begin
  if FSelectedInfo.GeoLocation <> nil then
  begin
    if SelCount = 1 then
      ImageName := ExtractFileName(FSelectedInfo.FileName)
    else
      ImageName := Format(L('%d objects'), [SelCount]);

    DisplayGeoLocation(ImageName,
      FSelectedInfo.GeoLocation.Latitude, FSelectedInfo.GeoLocation.Longitude,
      FSelectedInfo.Date + FSelectedInfo.Time);
  end else
  begin
    StartMap(True);
    ClearMap;
  end;
  if ElvMain.Selection.FocusedItem <> nil then
    ElvMain.Selection.FocusedItem.MakeVisible(EmvTop);
end;

procedure TExplorerForm.WlGoToShelfClick(Sender: TObject);
begin
  SetNewPathW(ExplorerPath(cShelfPath, EXPLORER_ITEM_SHELF), False);
end;

procedure TExplorerForm.ShowMarker(FileName: string; Lat, Lng: Double; Date: TDateTime);
begin
  FMapLocationLat := Lat;
  FMapLocationLng := Lng;
  WlSaveLocation.Enabled := False;
  WlDeleteLocation.Enabled := True;

  if FIsMapLoaded then
  begin
    if FGeoHTMLWindow <> nil then
    begin
      FGeoHTMLWindow.execScript
        (FormatEx('ShowImageLocation({0}, {1}, "{2}", "{3}"); GotoLatLng({0}, {1});',
        [DoubleToStringPoint(Lat), DoubleToStringPoint(Lng), FileName,
        IIF(YearOf(Date) > 1900, FormatDateTime('yyyy.mm.dd HH:MM', Date), '')]), 'JavaScript');

      ProgramStatistics.GeoInfoReadUsed;
    end;
  end;
end;

procedure TExplorerForm.DisplayGeoLocation(FileName: string; Lat, Lng: Double; Date: TDateTime);
begin
  StartMap(True);
  if FIsMapLoaded then
    ShowMarker(FileName, Lat, Lng, Date)
  else
    FWbGeoLocation.Tag := 1;
end;

procedure TExplorerForm.WlPanoramioClick(Sender: TObject);
begin
  FIsPanaramio := not FIsPanaramio;
  if FIsMapLoaded then
  begin
    if FIsPanaramio then
      FGeoHTMLWindow.execScript(FormatEx('showPanaramio();', []), 'JavaScript')
    else
      FGeoHTMLWindow.execScript(FormatEx('hidePanaramio();', []), 'JavaScript');
  end;
  WlPanoramio.Text := IIF(FIsPanaramio, L('Hide Panoramio'), L('Show Panoramio'));
end;

procedure TExplorerForm.WlResetFilterClick(Sender: TObject);
begin
  HideFilter(True);
end;

procedure TExplorerForm.SplRightPanelCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
var
  PanelSize: Integer;
begin
  if NewSize < SplRightPanel.Left then
    Exit;

  PanelSize := ClientWidth - PnListView.Width - MainPanel.Width - SplRightPanel.Width - SplLeftPanel.Width;
  Accept := PanelSize >= 99;
  if not Accept then
    NewSize := PanelSize;
end;

procedure TExplorerForm.WlSaveLocationClick(Sender: TObject);
var
  I, Index: Integer;
  GeoLocation: TGeoLocation;
  Progress: TOperationProgress;
  UpdatingDone: Boolean;
  EI: TExplorerFileInfo;
begin
  Enabled := False;
  try
    if CanSaveGeoLocation then
    begin
      Progress := TOperationProgress.Create(Self);
      try
        GeoLocation := TGeoLocation.Create;
        try
          Progress.Text := L('Updating of location');

          GeoLocation.Latitude := FMapLocationLat;
          GeoLocation.Longitude := FMapLocationLng;
          try
            UpdatingDone := True;

            Progress.Max := SelCount;
            Progress.Position := 0;

            if SelCount > 1 then
              Progress.Show;

            for I := 0 to ElvMain.Items.Count - 1 do
              if ElvMain.Items[I].Selected then
              begin
                Index := ItemIndexToMenuIndex(I);
                EI := FFilesInfo[Index];
                if (EI.FileType = EXPLORER_ITEM_IMAGE) and not IsDevicePath(EI.FileName) and CanSaveEXIF(EI.FileName) then
                begin
                  //Statistics
                  ProgramStatistics.GeoInfoSaveUsed;

                  if not UpdateFileGeoInfo(EI.FileName, GeoLocation, True) then
                    UpdatingDone := False
                  else if FCurrentTypePath in [EXPLORER_ITEM_SHELF, EXPLORER_ITEM_SEARCH, EXPLORER_ITEM_PERSON, EXPLORER_ITEM_GROUP,
                                               EXPLORER_ITEM_CALENDAR_YEAR, EXPLORER_ITEM_CALENDAR_MONTH, EXPLORER_ITEM_CALENDAR_DAY] then
                    RefreshItemByID(EI.ID);

                  Progress.Position := Progress.Position + 1;
                  if Progress.Closed then
                    Break;
                end;
              end;

            if UpdatingDone then
            begin
              WlSaveLocation.Enabled := False;
              WlDeleteLocation.Enabled := True;
            end;
          except
            on e: Exception do
              MessageBoxDB(Handle, FormatEx(L('An error occurred while saving location: {0}!'), [e.Message]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
          end;
        finally
          F(GeoLocation);
        end;
      finally
        F(Progress);
      end;
    end else
      MessageBoxDB(Handle, Format(L('Geo location can''t be saved to this file type!'), []), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  finally
    Enabled := True;
  end;
end;

procedure TExplorerForm.WlDeleteLocationClick(Sender: TObject);
var
  I, Index: Integer;
  Progress: TOperationProgress;
  UpdatingDone: Boolean;
  EI: TExplorerFileInfo;
begin
  Enabled := False;
  try
    if CanSaveGeoLocation then
    begin
      Progress := TOperationProgress.Create(Self);
      try

        Progress.Text := L('Updating of location');

        try
          UpdatingDone := True;

          Progress.Max := SelCount;
          Progress.Position := 0;

          if SelCount > 1 then
            Progress.Show;

          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              Index := ItemIndexToMenuIndex(I);
              EI := FFilesInfo[Index];
              if (EI.FileType = EXPLORER_ITEM_IMAGE) and not IsDevicePath(EI.FileName) and CanSaveEXIF(EI.FileName) then
              begin
                //Statistics
                ProgramStatistics.GeoInfoSaveUsed;

                if not DeleteFileGeoInfo(EI.FileName, True) then
                  UpdatingDone := False;

                Progress.Position := Progress.Position + 1;
                if Progress.Closed then
                  Break;
              end;
            end;

          if UpdatingDone then
          begin
            WlSaveLocation.Enabled := True;
            WlDeleteLocation.Enabled := False;
          end;
        except
          on e: Exception do
            MessageBoxDB(Handle, FormatEx(L('An error occurred while saving location: {0}!'), [e.Message]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        end;
      finally
        F(Progress);
      end;
    end else
      MessageBoxDB(Handle, Format(L('Geo location can''t be saved to this file type!'), []), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  finally
    Enabled := True;
  end;
end;

function TExplorerForm.CanShareSelectedObjects: Boolean;
var
  SC, I, Index: Integer;
  EI: TExplorerFileInfo;
begin
  Result := False;

  SC := SelCount;
  if SC = 0 then
    Exit(False);

  if SC = 1 then
  begin
    Result := IsGraphicFile(FSelectedInfo.FileName) or CanShareVideo(FSelectedInfo.FileName);
    Exit;
  end;

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      EI := FFilesInfo[Index];
      if IsGraphicFile(EI.FileName) or CanShareVideo(EI.FileName) then
      begin
        Result := True;
        Exit;
      end;
    end;
end;

procedure TExplorerForm.WlShareClick(Sender: TObject);
var
  I, Index: Integer;
  Files: TDBPopupMenuInfo;
  EI: TExplorerFileInfo;
begin
  Files := TDBPopupMenuInfo.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        EI := FFilesInfo[Index];

        if   (EI.FileType = EXPLORER_ITEM_IMAGE)
          or (EI.FileType = EXPLORER_ITEM_DEVICE_IMAGE)
          or ((EI.FileType = EXPLORER_ITEM_DEVICE_VIDEO) and CanShareVideo(EI.FileName))
          or ((EI.FileType = EXPLORER_ITEM_FILE)         and CanShareVideo(EI.FileName)) then
          Files.Add(EI.Copy);
      end;

    if Files.Count > 0 then
      ShareForm.Execute(Self, Files);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.MapStarted;
begin
  FIsMapLoaded := True;
  if FWbGeoLocation.Tag = 1 then
  begin
    FWbGeoLocation.Tag := 0;
    if FSelectedInfo.GeoLocation <> nil then
    begin
      ShowMarker(ExtractFileName(FSelectedInfo.FileName),
        FSelectedInfo.GeoLocation.Latitude,
        FSelectedInfo.GeoLocation.Longitude,
        FSelectedInfo.Date + FSelectedInfo.Date);
    end else
    begin
      SaveCurrentImageInfoToMap;

      if Settings.ReadInteger('Explorer', 'MapZoom', 1) <= 1 then
      begin
        TThreadTask.Create(Self, nil,
          procedure(Thread: TThreadTask; Data: Pointer)
          var
            Url, LocationJson: string;
          begin
            Url := ResolveLanguageString(GeoLocationJSON) + '&c=' + TActivationManager.Instance.ApplicationCode + '&v=' + ProductVersion;
            LocationJson := DownloadFile(Url, TEncoding.UTF8);

            Thread.SynchronizeTask(
              procedure
              begin
                if (FGeoHTMLWindow <> nil) and (LocationJson <> '') then
                begin
                  LocationJson := StringReplace(LocationJson, '"', '''', [rfReplaceAll]);
                  FGeoHTMLWindow.execScript
                    (FormatEx('TryToResolvePosition("{0}"); ', [LocationJson]), 'JavaScript');
                end;
              end
            );
          end
        );
      end;
    end;
  end;

  if (FGeoHTMLWindow <> nil) then
  begin
    if FIsPanaramio then
      FGeoHTMLWindow.execScript(FormatEx('showPanaramio();', []), 'JavaScript')
    else
      FGeoHTMLWindow.execScript(FormatEx('hidePanaramio();', []), 'JavaScript');
  end;
end;

procedure TExplorerForm.McDateSelectPopupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BtnSelectDatePopupClick(Sender);
end;

procedure TExplorerForm.ZoomPan(Lat, Lng: Double; Zoom: SYSINT);
begin
  if FIsMapLoaded then
  begin
    Settings.WriteInteger('Explorer', 'MapZoom', Zoom);
    Settings.WriteString('Explorer', 'MapLat', DoubleToStringPoint(Lat));
    Settings.WriteString('Explorer', 'MapLng', DoubleToStringPoint(Lng));
  end;
end;

function TExplorerForm.CanSaveGeoLocation: Boolean;
var
  SC, I, Index: Integer;
  EI: TExplorerFileInfo;
begin
  Result := False;

  SC := SelCount;
  if SC = 0 then
    Exit(False);

  if SC = 1 then
  begin
    Result := not IsDevicePath(FSelectedInfo.FileName) and CanSaveEXIF(FSelectedInfo.FileName);
    Exit;
  end;

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      EI := FFilesInfo[Index];
      if (EI.FileType = EXPLORER_ITEM_IMAGE) and not IsDevicePath(EI.FileName) and CanSaveEXIF(EI.FileName) then
      begin
        Result := True;
        Exit;
      end;
    end;
end;

function TExplorerForm.CanSaveLocation(Lat: Double; Lng: Double; Value: Shortint): Shortint;
begin
  Result := 0;
  if Value < 0 then
  begin
    WlSaveLocation.Enabled := False;
    Exit;
  end;
  if CanSaveGeoLocation then
  begin
    FMapLocationLat := Lat;
    FMapLocationLng := Lng;
    WlSaveLocation.Enabled := True;
    Result := 1;
  end;
end;

procedure TExplorerForm.SaveCurrentImageInfoToMap;
begin
  if (FGeoHTMLWindow <> nil) then
    FGeoHTMLWindow.execScript
      (FormatEx('SaveImageInfo("{0}", "{1}");',
      [ExtractFileName(FSelectedInfo.FileName),
      IIF(YearOf(FSelectedInfo.Date) > 1900, FormatDateTime('yyyy.mm.dd HH:MM', FSelectedInfo.Date + FSelectedInfo.Time), '')]), 'JavaScript');
end;

function TExplorerForm.SaveLocation(Lat, Lng: Double; const FileName: WideString): Shortint;
begin
  FMapLocationLat := Lat;
  FMapLocationLng := Lng;

  PostMessage(Handle, FWebBrowserJSMessage, 0, 0);
end;

procedure TExplorerForm.UpdateEmbed;
var
  Embed2: IHTMLElement2;
  Embed: IHTMLElement;
  FactoryVar: OleVariant;
  I: Integer;
  Embeds: IHTMLElementCollection;
begin
  Embeds := (FWbGeoLocation.Document as IHTMLDocument2).embeds;
  for I := 0 to Embeds.length - 1 do
  begin
    Embed2 := Embeds.item(0, I) as IHTMLElement2;
    if Assigned(Embed2) then
    begin
      Embed := Embeds.item(0, I) as IHTMLElement;
      if Assigned(Embed) and (Embed.className = 'image') then
      begin
        FWebBorwserFactory := TElementBehaviorFactory.Create(Self);
        FactoryVar := IElementBehaviorFactory(FWebBorwserFactory);
        Embed2.addBehavior('', FactoryVar);
      end;
    end;
  end;
end;

procedure TExplorerForm.ClearMap;
begin
  WlDeleteLocation.Enabled := False;
  if FIsMapLoaded then
  begin
    if FGeoHTMLWindow <> nil then
      FGeoHTMLWindow.execScript(FormatEx('ClearMarkers(); ', []), 'JavaScript');
  end;
end;

procedure TExplorerForm.StartMap(UpdateTab: Boolean);
var
  Stream: TMemoryStream;
  SW: TStreamWriter;
  MapHTML, S: string;
  Lt, Ln: Double;
  Zoom: Integer;
begin
  if FGeoHTMLWindow = nil then
  begin
    WedGeoSearch.Text := Settings.ReadString('Explorer', 'LastGeoSearch', '');
    FMapLocationLat := 0;
    FMapLocationLng := 0;

    WlSaveLocation.LoadFromResource('MAP_MARKER_ADD');
    WlDeleteLocation.LoadFromResource('MAP_MARKER_DELETE');
    WlPanoramio.LoadFromResource('PANORAMIO');

    WedGeoSearch.WatermarkText := L('Search location by address');
    WlPanoramio.Text := L('Show Panoramio');
    WlSaveLocation.Text := L('Save location');
    WlDeleteLocation.Text := L('Delete location');
    WlSaveLocation.LoadImage;
    WlDeleteLocation.LoadImage;
    WlDeleteLocation.Left := WlSaveLocation.Left + WlSaveLocation.Width + 10;
    WlPanoramio.Left := WlDeleteLocation.Left + WlDeleteLocation.Width + 10;

    LoadSpeedButtonFromResourcePNG(SbDoSearchLocation, 'SEARCH');

    FWbGeoLocation := TWebBrowser.Create(TsGeoLocation);
    TWinControl(FWbGeoLocation).Parent := TsGeoLocation;
    FWbGeoLocation.Tag := 1;
    FWbGeoLocation.Align := alClient;
    FWbGeoLocation.Silent := True;

    FWebJSContainer := TWebJSExternalContainer.Create(FWbGeoLocation, Self);
    FWbGeoLocation.Navigate('about:blank');

    if Assigned(FWbGeoLocation.Document) then
    begin
       Stream := TMemoryStream.Create;
      try
        S := GoogleMapHTMLStr;
        S := StringReplace(S, '%LANG%', TTranslateManager.Instance.Language, []);
        S := StringReplace(S, '%YES%', L('Yes'), []);
        S := StringReplace(S, '%NO%', L('No'), []);
        S := StringReplace(S, '%NAME_LABEL%', L('Name'), []);
        S := StringReplace(S, '%DATE_LABEL%', L('Date'), []);
        S := StringReplace(S, '%ZOOM_TEXT%', L('Zoom in'), []);
        S := StringReplace(S, '%SAVE_TEXT%', L('Save current location for the image?'), []);

        Lt := StringToDoublePoint(Settings.ReadString('Explorer', 'MapLat', ''));
        Ln := StringToDoublePoint(Settings.ReadString('Explorer', 'MapLng', ''));
        Zoom := Settings.ReadInteger('Explorer', 'MapZoom', 1);

        S := StringReplace(S, '%START_LT%', DoubleToStringPoint(Lt), []);
        S := StringReplace(S, '%START_LN%', DoubleToStringPoint(Ln), []);
        S := StringReplace(S, '%START_ZOOM%', IntToStr(Zoom), []);

        MapHTML := S;
        SW := TStreamWriter.Create(Stream);
        try
          SW.Write(MapHTML);
          Stream.Seek(0, soFromBeginning);
          (FWbGeoLocation.Document as IPersistStreamInit).Load(TStreamAdapter.Create(Stream));
        finally
          F(SW);
        end;
      finally
        F(Stream);
      end;
      FGeoHTMLWindow := (FWbGeoLocation.Document as IHTMLDocument2).parentWindow;
    end;
  end;

  if UpdateTab then
    ShowRightPanel(ertsMap);
end;

procedure TExplorerForm.StateChanged(OldState: TGUID);
begin
  inherited;
  ExplorerUpdateManager.CleanUpState(OldState);
end;

procedure TExplorerForm.SbDoSearchLocationClick(Sender: TObject);
begin
  Settings.WriteString('Explorer', 'LastGeoSearch', WedGeoSearch.Text);
  if FIsMapLoaded then
    if FGeoHTMLWindow <> nil then
      FGeoHTMLWindow.execScript(FormatEx('FindLocation("{0}");', [WedGeoSearch.Text]), 'JavaScript');
end;

procedure TExplorerForm.WbGeoLocationExit(Sender: TObject);
begin
  Winapi.Windows.SetFocus(Handle);
  ActiveControl := nil;
  ElvMain.SetFocus;
end;

procedure TExplorerForm.WedGeoSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    SbDoSearchLocationClick(Sender);
  end;
end;

procedure TExplorerForm.LoadInfoAboutFiles(Info: TExplorerFileInfos);
begin
  FFilesInfo.Assign(Info);
end;

procedure TExplorerForm.AddInfoAboutFile(Info: TExplorerFileInfos);
var
  I, J: Integer;
  IsContinue: Boolean;
  InfoCount: Integer;
begin
  InfoCount := FFilesInfo.Count;
  for I := 0 to Info.Count - 1 do
  begin
    IsContinue := False;
    for J := 0 to InfoCount - 1 do
    begin
      if FFilesInfo[J].FileName = Info[I].FileName then
      begin
        IsContinue := True;
        Break;
      end;
    end;
    if IsContinue then
      Continue;

    FFilesInfo.Add(Info[I].Copy);
  end;

end;

function TExplorerForm.FileNeededW(FileSID : TGUID) : Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to fFilesInfo.Count - 1 do
  If IsEqualGUID(fFilesInfo[I].SID, FileSID) then
  begin
    if not FFilesInfo[I].IsBigImage then
      Result := True;
    Break;
  end;
end;

function TExplorerForm.ItemIndexToMenuIndex(Index: Integer): Integer;
var
  I, N: Integer;
begin
  Result := 0;
  N := ElvMain.Items[Index].ImageIndex;
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if FFilesInfo[I].ImageIndex = N then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TExplorerForm.ItemUpdateTimer(Sender: TObject);
begin
  FItemUpdateTimer.Enabled := False;
  UpdateItems;
end;

procedure TExplorerForm.AddItemToUpdate(Item: TEasyItem);
begin
  FUpdateItemList.Add(Item);
  if GetTickCount - FItemUpdateLastTime < RefreshListViewInterval then
  begin
    FItemUpdateTimer.Enabled := True;
  end else
  begin
    FItemUpdateTimer.Enabled := False;
    UpdateItems;
  end;
end;

procedure TExplorerForm.UpdateItems;
var
  Item: TEasyItem;
  I: Integer;

  function ItemExists(AItem: TEasyItem): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to ElvMain.Groups[0].ItemCount - 1 do
      if ElvMain.Groups[0].Item[J] = AItem then
      begin
        Result := True;
        Exit;
      end;
  end;

begin
  FItemUpdateLastTime := GetTickCount;
  try
    if FUpdateItemList.Count = 1 then
    begin
      Item := FUpdateItemList[0];
      if Item = nil then
      begin
        ElvMain.EndUpdate(True);
        Exit;
      end;

      if ElvMain.Groups.Count > 0 then
      begin
        for I := 0 to ElvMain.Groups[0].ItemCount - 1 do
          if ElvMain.Groups[0].Item[I] = Item then
            Item.Invalidate(True);
      end;

    end else if FUpdateItemList.Count > 1 then
    begin
      for I := 0 to FUpdateItemList.Count - 1 do
      begin
        Item := FUpdateItemList[I];
        if Item = nil then
          ElvMain.EndUpdate(False);
      end;
      ElvMain.Invalidate;
    end;
  finally

    if (ElvMain.Selection.Count = 0) and (FSelectedItem <> nil) and ItemExists(FSelectedItem) then
    begin
      FSelectedItem.Selected := True;
      FSelectedItem.Focused := True;
      FSelectedItem.MakeVisible(EmvTop);
    end;
    FSelectedItem := nil;

    FUpdateItemList.Clear;
  end;
end;

function TExplorerForm.MenuIndexToItemIndex(Index: Integer): Integer;
var
  I, N: Integer;
begin
  Result := 0;
  N := FFilesInfo[Index].ImageIndex;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if ElvMain.Items[I].ImageIndex = N then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TExplorerForm.MiCopyAddressClick(Sender: TObject);
begin
  Clipboard.AsText := FCurrentPath;
end;

procedure TExplorerForm.MiDisplayOnMapClick(Sender: TObject);
begin
  WlGeoLocationClick(Sender);
end;

procedure TExplorerForm.MiEditAddressClick(Sender: TObject);
begin
  PePath.Edit;
end;

procedure TExplorerForm.MiShelfClick(Sender: TObject);
var
  I, Index: Integer;
  FileList: TStrings;
begin
  if ListView1Selected <> nil then
  begin
    FileList := TStringList.Create;
    try
      for I := 0 to ElvMain.Items.Count - 1 do
      begin
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) or
             (FFilesInfo[Index].FileType = EXPLORER_ITEM_FILE) or
             (FFilesInfo[Index].FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
             (FFilesInfo[Index].FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
             (FFilesInfo[Index].FileType = EXPLORER_ITEM_DEVICE_FILE) then
            FileList.Add(FFilesInfo[Index].FileName);
        end;
      end;

      if FileList.Count > 0 then
      begin
        if PhotoShelf.PathInShelf(FileList[0]) = -1 then
          PhotoShelf.AddItems(Self, FileList)
        else
          PhotoShelf.DeleteItems(Self, FileList);
      end;
    finally
      F(FileList);
    end;
  end;
end;

procedure TExplorerForm.MiESShowHiddenClick(Sender: TObject);
begin
  FExtendedSearchParams.ShowHidden := not FExtendedSearchParams.ShowHidden;
end;

procedure TExplorerForm.MiESShowPrivateClick(Sender: TObject);
begin
  FExtendedSearchParams.ShowPrivate := not FExtendedSearchParams.ShowPrivate;
end;

procedure TExplorerForm.MiESSortByImageSizeClick(Sender: TObject);
begin
  FExtendedSearchParams.SortMode := TDatabaseSortMode(TControl(Sender).Tag);

  ExtendedSearchRealign;
end;

procedure TExplorerForm.MiInfoGroupFindClick(Sender: TObject);
var
  WL: TWebLink;
begin
  WL := TWebLink(PmInfoGroup.Tag);

  SetNewPathW(ExplorerPath(cGroupsPath + '\' + WL.Text, EXPLORER_ITEM_GROUP), False);
end;

procedure TExplorerForm.MiInfoGroupPropertiesClick(Sender: TObject);
var
  WL: TWebLink;
begin
  WL := TWebLink(PmInfoGroup.Tag);

  GroupInfoForm.Execute(nil, WL.Text, False);
end;

procedure TExplorerForm.MiInfoGroupRemoveClick(Sender: TObject);
var
  WL: TWebLink;
  KeyWords: string;
  Group: TGroup;
  Groups: TGroups;
begin
  WL := TWebLink(PmInfoGroup.Tag);

  KeyWords := MemKeyWords.Text;
  Groups := EncodeGroups(FSelectedInfo.Groups);

  Group := GetGroupByGroupName(WL.Text, False);

  RemoveGroupFromGroups(Groups, Group);
  DeleteWords(KeyWords, Group.GroupKeyWords);

  FSelectedInfo.Groups := CodeGroups(Groups);
  MemKeyWords.Text := KeyWords;
  InitEditGroups;

  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.LockItems;
begin
  GlobalLock := True;
end;

procedure TExplorerForm.UnLockItems;
begin
  GlobalLock := False;
end;

procedure TExplorerForm.SetOldPath(Path: string);
begin
  FOldPatch := Path;
  NotSetOldPath := False;
end;

procedure TExplorerForm.FormShow(Sender: TObject);
begin
  if FIsFirstShow then
  begin
    DragTimer.Enabled := True;
    if IsWindowsVista then
      AddClipboardFormatListener(Handle)
    else
      FNextClipboardViewer := SetClipboardViewer(Handle);
    FIsFirstShow := False;
  end;

  NotSetOldPath := False;
  ElvMain.SetFocus;
end;

procedure TExplorerForm.NewWindow1Click(Sender: TObject);
var
  Path: TExplorerPath;
begin
  Path := ExplorerPath(FFilesInfo[PmItemPopup.Tag].FileName, FFilesInfo[PmItemPopup.Tag].FileType);
  with Explorermanager.NewExplorer(False) do
  begin
    SetNewPathW(Path, False);
    Show;
  end;
end;

procedure TExplorerForm.PmListPopupPopup(Sender: TObject);
begin
  Addfolder1.Visible := not FolderView;
  MakeFolderViewer1.Visible := ((GetCurrentPathW.PType = EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType = EXPLORER_ITEM_DRIVE) or (GetCurrentPathW.PType = EXPLORER_ITEM_SHARE)) and not FolderView;

  Paste1.Visible := False;
  Addfolder1.Visible := False;
  MakeNew1.Visible := False;

  if (GetCurrentPathW.PType = EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType = EXPLORER_ITEM_DRIVE) or (GetCurrentPathW.PType = EXPLORER_ITEM_SHARE) then
  begin
    Paste1.Visible := True;
    Addfolder1.Visible := True;
    MakeNew1.Visible := True;
  end;

  if (GetCurrentPathW.PType = EXPLORER_ITEM_DEVICE_STORAGE) or (GetCurrentPathW.PType = EXPLORER_ITEM_DEVICE_DIRECTORY) then
  begin
    Paste1.Visible := False;
  end;

  Paste1.Visible := CanCopyFromClipboard;
end;

procedure TExplorerForm.ShowProgress;
begin
  if FShowStatusBar then
  begin
    FStatusProgress.Style := pbstNormal;
    FStatusProgress.Show;
  end;

  if W7TaskBar <> nil then
    W7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
end;

procedure TExplorerForm.ShowRightPanel(Mode: TExplorerRightTab);
var
  R: TRect;
begin
  IsResizePreivew := False;

  PcRightPreview.HandleNeeded;
  PcRightPreview.Perform(TCM_GETITEMRECT, 0, LPARAM(@R));
  SbCloseRightPanel.Width := R.Height;
  SbCloseRightPanel.Height := R.Height;

  SbCloseRightPanel.Parent := PcRightPreview;
  SbCloseRightPanel.Top := 1;
  SbCloseRightPanel.Left := PcRightPreview.Width - SbCloseRightPanel.Width - 2;

  ShowActiveRightTab(Mode);
  ApplyRightTabs;

  TbPreview.Tag := -1;
  TbPreview.Down := True;

  PnRight.Show;
  SplRightPanel.Show;
  SplRightPanel.Left := PnRight.Left;
end;

procedure TExplorerForm.HideRightPanel;
begin
  TbPreview.Tag := 1;
  TbPreview.Down := False;

  SetResizeListViewMode;
  PnRight.Hide;
  SplRightPanel.Hide;
  Winapi.Windows.SetFocus(ElvMain.Handle);
end;

procedure TExplorerForm.ShowIndeterminateProgress;
begin
  if FShowStatusBar then
  begin
    FStatusProgress.Style := pbstMarquee;
    FStatusProgress.Show;
  end;

  if W7TaskBar <> nil then
    W7TaskBar.SetProgressState(Handle, TBPF_INDETERMINATE);
end;

procedure TExplorerForm.HideLoadingSign;
begin
  LsMain.Hide;
end;

procedure TExplorerForm.HideProgress;
begin
  FStatusProgress.Hide;
  StatusBarMain.Hide;

  if W7TaskBar <> nil then
    W7TaskBar.SetProgressState(Handle, TBPF_NOPROGRESS);
end;

procedure TExplorerForm.SetProgressMax(Value: Integer);
begin
  FStatusProgress.Max := Value;
end;

procedure TExplorerForm.SetProgressPosition(Value: Integer);
begin
  FStatusProgress.Position := Value;

  if W7TaskBar <> nil then
    W7TaskBar.SetProgressValue(Handle, Value, FStatusProgress.Max);
end;

procedure TExplorerForm.SetStatusText(Text: string);
begin
  if FShowStatusBar then
  begin
    StatusBarMain.Panels[1].Text := Text;
    StatusBarMain.Visible := True;
  end;
end;

procedure TExplorerForm.SetPanelImage(Image: TBitmap; FileGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    FSelectedInfo.PreviewID := GetGUID;
    ImPreview.Picture.Graphic := Image;
  end;
end;

procedure TExplorerForm.SetPanelInfo(Info: TDBPopupMenuInfoRecord;
  ExifInfo: IExifInfo; var Histogramm: TBitmap; FileGUID: TGUID);
var
  Line: IExifInfoLine;
  IsVisible: Boolean;
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    ClearGeoLocation;
    FSelectedInfo.Width := Info.Width;
    FSelectedInfo.Height := Info.Height;
    FSelectedInfo.Id := Info.ID;
    FSelectedInfo.Rating := Info.Rating;
    FSelectedInfo.Access := Info.Access;
    FSelectedInfo.Encrypted := Info.Encrypted;
    if Info.GeoLocation <> nil then
    begin
      FSelectedInfo.GeoLocation := TGeoLocation.Create;
      FSelectedInfo.GeoLocation.Latitude := Info.GeoLocation.Latitude;
      FSelectedInfo.GeoLocation.Longitude := Info.GeoLocation.Longitude;
    end;

    if ExifInfo <> nil then
    begin
      BeginScreenUpdate(VleEXIF.Handle);
      try
        VleEXIF.Strings.Clear;
        for Line in ExifInfo do
          VleEXIF.InsertRow(Line.Name + ': ', Line.Value, True);

        TEXIFDisplayControl(VleEXIF).UpdateRowsHeight;
      finally
        EndScreenUpdate(VleEXIF.Handle, {PcTasks.ActivePageIndex = Integer(eltsEXIF)}False);
      end;

      ShowLeftTabIfWasActive(eltsEXIF);
    end else
      ShowLastActiveLeftTab(eltsAny);

    IsVisible := PcTasks.ActivePageIndex = Integer(eltsInfo);
    if IsVisible then
      BeginScreenUpdate(TsInfo.Handle);
    try
      ImHistogramm.Picture.Graphic := Histogramm;
    finally
      if IsVisible then
        EndScreenUpdate(TsInfo.Handle, False);
    end;

    ReallignInfo;

    ApplyLeftTabs;
  end;
end;

procedure TExplorerForm.ImPreviewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  Item: TEasyItem;
begin
  if PopupHandled then
  begin
    PopupHandled := False;
    Exit;
  end;
  if (ListView1Selected = nil) or (SelCount <> 1) then
    Exit;
  HintTimer.Enabled := False;
  Item := ListView1Selected;
  if Item <> nil then
  begin
    LastMouseItem := nil;
    Application.HideHint;
    THintManager.Instance.CloseHint;
    PmItemPopup.Tag := ItemIndexToMenuIndex(Item.Index);
    PmItemPopup.DoPopupEx(ImPreview.Clienttoscreen(MousePos).X, ImPreview.Clienttoscreen(MousePos).Y);
  end else
    PmListPopup.DoPopupEx(ImPreview.Clienttoscreen(MousePos).X, ImPreview.Clienttoscreen(MousePos).Y);

end;

procedure TExplorerForm.PropertyPanelResize(Sender: TObject);
begin
  ReallignInfo;
end;

procedure TExplorerForm.ReallignToolInfo;
begin
  TbDelete.Enabled := False;
  TbCopy.Enabled := False;
  TbCut.Enabled := False;

  if (FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) then
    TbCopy.Enabled := SelCount > 0;

  if (FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) then
    TbCut.Enabled := SelCount > 0;

  if (FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) or
     (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
    TbDelete.Enabled := SelCount > 0;
end;

procedure TExplorerForm.ReallignInfo;
const
  otstup = 15;
  H = 3;

var
  Index, I, NewTop: Integer;
  B: Boolean;
  S: string;
  PersonalPath, MyPicturesPath: string;
  OldMode: Cardinal;

  function GetShellPath(Name: string): string;
  var
    Reg: TRegIniFile;
  begin
    Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
    try
      Result := Reg.ReadString('Shell Folders', name, '');
    finally
      F(Reg);
    end;
  end;

  function GetPersonalFolder: string;
  begin
    if PersonalPath = '' then
      PersonalPath := GetShellPath('Personal');
    Result := PersonalPath;
  end;

  function GetMyPicturesFolder: string;
  begin
    if MyPicturesPath = '' then
      MyPicturesPath := GetShellPath('My Pictures');
    Result := MyPicturesPath;
  end;

  function ValidLink(Index: Integer): Boolean;
  var
    Path: string;
  begin
    Path := AnsiLowerCase(GetCurrentPath);
    Result := False;

    if FPlaces[Index].MyComputer and (GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER) then
      Result := True
    else if FPlaces[Index].MyDocuments and (Path = AnsiLowerCase(GetPersonalFolder)) then
      Result := True
    else if FPlaces[Index].MyPictures and (Path = AnsiLowerCase(MyPicturesPath)) then
      Result := True;

    if not Result then
      if FPlaces[Index].OtherFolder then
      begin
        Result := True;
        if (GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER) then
          Result := False
        else if (Path = AnsiLowerCase(GetPersonalFolder)) then
          Result := False
        else if (Path = AnsiLowerCase(MyPicturesPath)) then
          Result := False;
      end;
  end;

  procedure AddEncryptMenu;
  begin
    if not FSelectedInfo.Encrypted then
    begin
      EncryptLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CRYPTIMAGE + 1]);
      EncryptLink.Text := L('Encrypt');
      TbbEncrypt.Caption := L('Encrypt');
      TbbEncrypt.Tag := ACTION_ENCRYPT_IMAGES;
      TbbEncrypt.ImageIndex := DB_IC_CRYPTIMAGE;
      EncryptLink.Tag := ACTION_ENCRYPT_IMAGES;
    end else
    begin
      EncryptLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DECRYPTIMAGE + 1]);
      EncryptLink.Text := L('Decrypt');
      TbbEncrypt.Caption := L('Decrypt');
      TbbEncrypt.Tag := ACTION_DECRYPT_IMAGES;
      TbbEncrypt.ImageIndex := DB_IC_DECRYPTIMAGE;
      EncryptLink.Tag := ACTION_DECRYPT_IMAGES;
    end;
    TbbEncrypt.Enabled := True;
    EncryptLink.Visible := True;
    EncryptLink.Top := NewTop + H;
    NewTop := EncryptLink.BoundsRect.Bottom;
  end;

begin
  ScrollBox1.UpdatingPanel := True;
  IsReallignInfo := True;
  EventLog('ReallignInfo...');

  VerifyPaste(Self);

  BeginScreenUpdate(ScrollBox1.Handle);
  try
    S := ExtractFileName(FSelectedInfo.FileName) + ' ';
    for I := Length(S) downto 1 do
      if S[I] = '&' then
        Insert('&', S, I);

    NameLabel.Caption := S;
    NameLabel.Constraints.MaxWidth := ScrollBox1.Width - ScrollBox1.Left - otstup - ScrollBox1.VertScrollBar.ButtonSize;
    NameLabel.Constraints.MinWidth := ScrollBox1.Width - ScrollBox1.Left - Otstup - ScrollBox1.VertScrollBar.ButtonSize;
    NewTop := NameLabel.BoundsRect.Bottom;

    if FSelectedInfo.FileTypeW <> '' then
    begin
      TypeLabel.Top := NewTop + H;
      TypeLabel.Visible := True;
      TypeLabel.Constraints.MaxWidth := NameLabel.Constraints.MaxWidth;
      TypeLabel.Constraints.MinWidth := NameLabel.Constraints.MinWidth;
      TypeLabel.Caption := FSelectedInfo.FileTypeW;
      NewTop := TypeLabel.BoundsRect.Bottom;
    end else
      TypeLabel.Visible := False;

    if Min(FSelectedInfo.Width, FSelectedInfo.Height) = 0 then
    begin
      if (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) and (Length(FSelectedInfo.FileName) > 0) then
      begin
        OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
        if DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1) <> -1 then
        begin
          DimensionsLabel.Top := NewTop + H;
          DimensionsLabel.Visible := True;
          DimensionsLabel.Caption := L('Free space') + ':';
          NewTop := DimensionsLabel.BoundsRect.Bottom;
        end else
          DimensionsLabel.Visible := False;

        SetErrorMode(OldMode);
      end else
        DimensionsLabel.Visible := False;

    end else
    begin
      DimensionsLabel.Top := NewTop + H;
      DimensionsLabel.Visible := True;
      DimensionsLabel.Caption := IntToStr(FSelectedInfo.Width) + 'x' + IntToStr(FSelectedInfo.Height);
      NewTop := DimensionsLabel.BoundsRect.Bottom;
    end;

    if (FSelectedInfo.Size <> -1) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) then
    begin
      if (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) and (Length(FSelectedInfo.FileName) > 0) then
      begin
        OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
        if DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1) <> -1 then
        begin
          SizeLabel.Caption := Format(L('%s from %s'),
            [SizeInText(DiskFree(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1)),
            SizeInText(DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1))]);
          SizeLabel.Visible := True;
          SizeLabel.Top := NewTop + H;
          NewTop := SizeLabel.BoundsRect.Bottom;
        end else
          SizeLabel.Visible := False;

        SetErrorMode(OldMode);
      end else
      begin
        SizeLabel.Caption := Format(L('Size = %s'), [SizeInText(FSelectedInfo.Size)]);
        SizeLabel.Visible := True;
        SizeLabel.Top := NewTop + H;
        NewTop := SizeLabel.BoundsRect.Bottom;
      end;
    end else
      SizeLabel.Visible := False;

    if FSelectedInfo.ID <> 0 then
    begin
      IDLabel.Show;

      IDLabel.Caption := Format(L('ID = %d'), [FSelectedInfo.ID]);
      IDLabel.Top := NewTop + H;
      NewTop := IDLabel.BoundsRect.Bottom;

      if FSelectedInfo.Rating <> 0 then
      begin
        RatingLabel.Caption := Format(L('Rating = %d'), [FSelectedInfo.Rating]);
        RatingLabel.Top := NewTop + H;
        NewTop := RatingLabel.BoundsRect.Bottom;
        RatingLabel.Show;
      end else
        RatingLabel.Hide;

      if FSelectedInfo.Access = Db_access_private then
      begin
        AccessLabel.Caption := L('Private image');
        AccessLabel.Top := NewTop + H;
        NewTop := AccessLabel.BoundsRect.Bottom;
        AccessLabel.Show;
      end else
        AccessLabel.Hide;

    end else
    begin
      IDLabel.Hide;
      RatingLabel.Hide;
      AccessLabel.Hide;
    end;

    if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
    begin
      NewTop := NewTop + H * 4;
      ImageTasksLabel.Show;
      ImageTasksLabel.Top := NewTop;
      NewTop := ImageTasksLabel.BoundsRect.Bottom;

      if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
        AddEncryptMenu
      else
      begin
        EncryptLink.Visible := False;
        TbbEncrypt.Enabled := False;
      end;

      TbbResize.Enabled := True;
      WlResize.Visible := True;
      WlResize.Top := NewTop + H;
      NewTop := WlResize.BoundsRect.Bottom;

      TbbConvert.Enabled := True;
      WlConvert.Visible := True;
      WlConvert.Top := NewTop + H;
      NewTop := WlConvert.BoundsRect.Bottom;

      TbbCrop.Enabled := True;
      WlCrop.Visible := True;
      WlCrop.Top := NewTop + H;
      NewTop := WlCrop.BoundsRect.Bottom;

      if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
      begin
        TbbPrint.Enabled := True;
        PrintLink.Visible := True;
        PrintLink.Top := NewTop + H;
        NewTop := PrintLink.BoundsRect.Bottom;
      end else
      begin
        TbbPrint.Enabled := False;
        PrintLink.Visible := False;
      end;

      if ((FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE)) and (SelCount = 1) then
      begin
        TbbEditor.Enabled := True;
        ImageEditorLink.Visible := True;
        ImageEditorLink.Top := NewTop + H;
        NewTop := ImageEditorLink.BoundsRect.Bottom;
      end else
      begin
        TbbEditor.Enabled := False;
        ImageEditorLink.Visible := False;
      end;

      if CanSaveGeoLocation then
      begin
        if (FSelectedInfo.GeoLocation <> nil)  then
          WlGeoLocation.Text := L('Display on map')
        else
          WlGeoLocation.Text := L('Set map location');
        WlGeoLocation.Visible := True;
        TbbGeo.Enabled := True;
        TbbGeo.Caption := WlGeoLocation.Text;

        WlGeoLocation.Top := NewTop + H;
        NewTop := WlGeoLocation.BoundsRect.Bottom;
      end else
      begin
        TbbGeo.Enabled := False;
        WlGeoLocation.Visible := False;
      end;

      if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) and not FolderView then
      begin
        TbbShare.Enabled := True;
        WlShare.Visible := True;
        WlShare.Top := NewTop + H;
        NewTop := WlShare.BoundsRect.Bottom;
      end else
      begin
        TbbShare.Enabled := False;
        WlShare.Visible := False;
      end;

    end else
    begin
      ImageTasksLabel.Hide;
      WlResize.Visible := False;
      WlConvert.Visible := False;
      WlCrop.Visible := False;
      EncryptLink.Visible := False;
      PrintLink.Visible := False;
      ImageEditorLink.Visible := False;
      WlGeoLocation.Visible := False;
      WlShare.Visible := False;

      TbbResize.Enabled := False;
      TbbEncrypt.Enabled := False;
      TbbConvert.Enabled := False;
      TbbCrop.Enabled := False;
      TbbPrint.Enabled := False;
      TbbEditor.Enabled := False;
      TbbGeo.Enabled := False;
      TbbShare.Enabled := False;
    end;

    NewTop := NewTop + H * 4;
    TasksLabel.Top := NewTop;
    NewTop := TasksLabel.BoundsRect.Bottom;
    if (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
    begin
      TbbPlay.Enabled := True;
      SlideShowLink.Visible := True;
      SlideShowLink.Top := NewTop + H;
      NewTop := SlideShowLink.BoundsRect.Bottom;
    end else
    begin
      TbbPlay.Enabled := False;
      SlideShowLink.Visible := False;
    end;

    if (((((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
              (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
              (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE))) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
              (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON_LIST) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) or (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHELF) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_YEAR) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_MONTH) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_DAY)) and (SelCount = 1)) then
    begin
      ShellLink.Visible := True;
      ShellLink.Top := NewTop + H;
      NewTop := ShellLink.BoundsRect.Bottom;
    end else
      ShellLink.Visible := False;

    if (SelCount = 1)
      and (GetCurrentPathW.PType in [EXPLORER_ITEM_PERSON, EXPLORER_ITEM_GROUP,
          EXPLORER_ITEM_CALENDAR, EXPLORER_ITEM_CALENDAR_YEAR, EXPLORER_ITEM_CALENDAR_MONTH, EXPLORER_ITEM_CALENDAR_DAY,
          EXPLORER_ITEM_SEARCH, EXPLORER_ITEM_SHELF])
      and (FSelectedInfo.FileType in [EXPLORER_ITEM_EXEFILE, EXPLORER_ITEM_FILE,
          EXPLORER_ITEM_FOLDER, EXPLORER_ITEM_DRIVE, EXPLORER_ITEM_SHARE, EXPLORER_ITEM_IMAGE,
          EXPLORER_ITEM_DEVICE_IMAGE, EXPLORER_ITEM_DEVICE_DIRECTORY, EXPLORER_ITEM_DEVICE_VIDEO,
          EXPLORER_ITEM_DEVICE_FILE]) then
      TbbOpenDirectory.Enabled := True
    else
      TbbOpenDirectory.Enabled := False;

    if CanBeTransparentEncryptedFile(FSelectedInfo.FileName) and (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) then
      AddEncryptMenu;

    if (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) then
    begin
      WlCreateObject.Text := L('New group');
      WlCreateObject.Visible := True;
      WlCreateObject.Top := NewTop + H;
      NewTop := WlCreateObject.BoundsRect.Bottom;
    end else
      WlCreateObject.Visible := False;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)) then
    begin
      CopyToLink.Visible := True;
      CopyToLink.Top := NewTop + H;
      NewTop := CopyToLink.BoundsRect.Bottom;
    end else
      CopyToLink.Visible := False;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
    begin
      if SelCount <> 0 then
      begin
        MoveToLink.Top := NewTop + H;
        NewTop := MoveToLink.BoundsRect.Bottom;
        MoveToLink.Visible := True;
      end else
        MoveToLink.Visible := False;
    end else
      MoveToLink.Visible := False;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON)) and
      (SelCount <> 0) then
    begin
      TbbRename.Enabled := True;
      RenameLink.Visible := True;
      RenameLink.Top := NewTop + H;
      NewTop := RenameLink.BoundsRect.Bottom;
    end else
    begin
      TbbRename.Enabled := False;
      RenameLink.Visible := False;
    end;

    if (((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE)) and (SelCount = 1)) or
      ((SelCount = 0) and ((FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE))) or
          (((FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE)) and
        (SelCount > 1)) then
    begin
      TbbProperties.Enabled := True;
      PropertiesLink.Visible := True;
      PropertiesLink.Top := NewTop + H;
      NewTop := PropertiesLink.BoundsRect.Bottom;
    end else
    begin
      TbbProperties.Enabled := False;
      PropertiesLink.Visible := False;
    end;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE)) then
    begin
      if SelCount <> 0 then
      begin
        DeleteLink.Visible := True;
        DeleteLink.Top := NewTop + H;
        NewTop := DeleteLink.BoundsRect.Bottom;
      end else
        DeleteLink.Visible := False;
    end else
      DeleteLink.Visible := False;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_SHELF)) then
    begin
      if SelCount = 0 then
      begin
        WlClear.Visible := True;
        WlClear.Top := NewTop + H;
        NewTop := WlClear.BoundsRect.Bottom;
      end else
        WlClear.Visible := False;
    end else
      WlClear.Visible := False;

    if (FSelectedInfo.FileType <> EXPLORER_ITEM_IMAGE) then
    begin
      if CanShareSelectedObjects then
      begin
        TbbShare.Enabled := True;
        WlShare.Visible := True;
        WlShare.Top := NewTop + H;
        NewTop := WlShare.BoundsRect.Bottom;
      end else
      begin
        TbbShare.Enabled := False;
        WlShare.Visible := False;
      end;
    end;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY)) then
    begin
      if SelCount <= 1 then
      begin
        WlImportPictures.Visible := not FolderView;
        WlImportPictures.Top := NewTop + H;
        NewTop := WlImportPictures.BoundsRect.Bottom;
      end else
        WlImportPictures.Visible := False;
    end else
      WlImportPictures.Visible := False;

    if ElvMain.Items.Count < 400 then
    begin
      if ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE)) and
        (SelCount = 0) then
      begin
        B := True;
      end else
      begin
        B := False;
        if FFilesInfo.Count <> 0 then
          for I := 0 to ElvMain.Items.Count - 1 do
            if ElvMain.Items[I].Selected then
            begin
              index := ItemIndexToMenuIndex(I);
              if ((FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE) and (FFilesInfo[index].ID = 0)) or
                ((FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or
                  (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE)) then
              begin
                B := True;
                Break;
              end;
            end;
      end;
    end else
    begin
      B := ((SelCount > 1) or ((SelCount = 1) and (FSelectedInfo.Id = 0)));
      B := ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) and B);
    end;

    if B and not FolderView then
    begin
      if SelCount = 1 then AddLink.Text := L('Add object');
      if SelCount > 1 then
        AddLink.Text := L('Add objects');
      if (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
        (SelCount = 0) then
        AddLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_ADD_FOLDER + 1]);

      if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) and (SelCount <> 0) then
        AddLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_ADD_SINGLE_FILE + 1]);

      AddLink.Visible := True;
      AddLink.Top := NewTop + H;
      NewTop := AddLink.BoundsRect.Bottom;
    end else
      AddLink.Visible := False;

    if (((FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON_LIST) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHELF) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_YEAR) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_MONTH) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_DAY))
		  and (SelCount = 0)) or
      ((SelCount > 0) and ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE))) then
    begin
      RefreshLink.Visible := True;
      RefreshLink.Top := NewTop + H;
      NewTop := RefreshLink.BoundsRect.Bottom;
    end else
      RefreshLink.Visible := False;

    if ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON_LIST) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHELF) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_YEAR) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_MONTH) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_DAY)) and ExplorerManager.ShowQuickLinks and (SelCount < 2) then
    begin
      OtherPlacesLabel.Show;
      MyPicturesLink.Show;
      MyDocumentsLink.Show;
      MyComputerLink.Show;
      DesktopLink.Show;

      OtherPlacesLabel.Top := NewTop + H * 4;
      if AnsiLowerCase(GetCurrentPath) <> AnsiLowerCase(GetShellPath('My Pictures')) then
        MyPicturesLink.Top := OtherPlacesLabel.Top + OtherPlacesLabel.Height + H
      else
      begin
        MyPicturesLink.Visible := False;
        MyPicturesLink.Top := RefreshLink.Top + RefreshLink.Height + H * 4;
      end;
      if AnsiLowerCase(GetCurrentPath) <> AnsiLowerCase(GetShellPath('Personal')) then
        MyDocumentsLink.Top := MyPicturesLink.Top + MyPicturesLink.Height + H
      else
      begin
        MyDocumentsLink.Visible := False;
        MyDocumentsLink.Top := MyPicturesLink.Top;
      end;
      if AnsiLowerCase(GetCurrentPath) <> AnsiLowerCase(GetShellPath('Desktop')) then
        DesktopLink.Top := MyDocumentsLink.Top + MyDocumentsLink.Height + H
      else
      begin
        DesktopLink.Visible := False;
        DesktopLink.Top := MyDocumentsLink.Top;
      end;
      if GetCurrentPathW.PType <> EXPLORER_ITEM_MYCOMPUTER then
        MyComputerLink.Top := DesktopLink.Top + DesktopLink.Height + H
      else
      begin
        MyComputerLink.Visible := False;
        MyComputerLink.Top := DesktopLink.Top;
      end;

      for I := 0 to Length(UserLinks) - 1 do
      begin
        UserLinks[I].Show;
        if I = 0 then
        begin
          if ValidLink(I) then
            UserLinks[I].Top := MyComputerLink.Top + MyComputerLink.Height + H
          else
          begin
            UserLinks[I].Visible := False;
            UserLinks[I].Top := MyComputerLink.Top;
          end;
        end else
        begin
          if ValidLink(I) then
            UserLinks[I].Top := UserLinks[I - 1].Top + UserLinks[I - 1].Height + H
          else
          begin
            UserLinks[I].Visible := False;
            UserLinks[I].Top := UserLinks[I - 1].Top;
          end;
        end;
      end;
    end else
    begin
      OtherPlacesLabel.Hide;
      MyPicturesLink.Hide;
      MyDocumentsLink.Hide;
      MyComputerLink.Hide;
      DesktopLink.Hide;
      for I := 0 to Length(UserLinks) - 1 do
        UserLinks[I].Hide;
    end;
    IsReallignInfo := False;

    ScrollBox1.UpdatingPanel := False;
    ScrollBox1.Realign;

    if HelpNO = 2 then
      if FSelectedInfo.Id = 0 then
        if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
          if SelCount < 3 then
          begin
            Activate;
            DoHelpHintCallBackOnCanClose(L('Help'), SecondStepHelp, Point(0, 0), AddLink, Help1NextClick,
              L('Next...'), Help1CloseClick);
          end;
  finally
    EndScreenUpdate(ScrollBox1.Handle, False);
  end;
  EventLog('ReallignInfo OK');
end;

procedure TExplorerForm.CopyToLinkClick(Sender: TObject);
var
  EndDir: String;
  I, Index: integer;
  Files: TStringList;
  DlgCaption: string;
begin
  Files := TStringList.Create;
  try
    if SelCount <> 0 then
    begin
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[Index].FileType = EXPLORER_ITEM_FILE)
            or (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) or
            (FFilesInfo[Index].FileType = EXPLORER_ITEM_EXEFILE) then
          begin
            Files.Add(FFilesInfo[Index].FileName);
          end;
        end;
    end else
      Files.Add(GetCurrentPath);

    if Files.Count = 1 then
      DlgCaption := Format(L('Select place to copy file "%s"'), [ExtractFileName(Files[0])])
    else
      DlgCaption := Format(L('Select place to copy %d files'), [Files.Count]);

    EndDir := UnitDBFileDialogs.DBSelectDir(Handle, DlgCaption, UseSimpleSelectFolderDialog);

    if EndDir <> '' then
      CopyFiles(Handle, Files, EndDir, False, False, Self);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.MoveToLinkClick(Sender: TObject);
var
  EndDir: string;
  I, Index: Integer;
  Files: TStringList;
  DlgCaption: string;
begin
  Files := TStringList.Create;
  try
    if SelCount <> 0 then
    begin
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          Files.Add(FFilesInfo[Index].FileName);
        end;
    end else
      Files.Add(GetCurrentPath);

    if Files.Count = 1 then
      DlgCaption := Format(L('Select place to move file "%s"'), [ExtractFileName(Files[0])])
    else
      DlgCaption := Format(L('Select place to move %d files'), [Files.Count]);

    EndDir := UnitDBFileDialogs.DBSelectDir(Handle, DlgCaption, UseSimpleSelectFolderDialog);
    if EndDir <> '' then
      CopyFiles(Handle, Files, EndDir, True, False, Self);

  finally
    F(Files);
  end;
end;

procedure TExplorerForm.SetNewPath(Path: String; Explorer: Boolean);
var
  S, S1: string;
  I: Integer;
  OldMode: Cardinal;
  P: TPathItem;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    EventLog('SetNewPath "' + Path + '"' + IIF(Explorer, ' <Explorer>', ''));

    P := PathProviderManager.CreatePathItem(Path);
    try
      if P is TSearchItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_SEARCH), False);
        Exit;
      end;
      if P is TGroupItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_GROUP), False);
        Exit;
      end;
      if P is TPersonItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_PERSON), False);
        Exit;
      end;
      if P is TPortableDeviceItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_DEVICE), False);
        Exit;
      end;
      if P is TPortableStorageItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_DEVICE_STORAGE), False);
        Exit;
      end;
      if P is TPortableDirectoryItem then
      begin
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_DEVICE_DIRECTORY), False);
        Exit;
      end;
    finally
      F(P);
    end;

    S := ExcludeTrailingBackslash(Path);
    if (AnsiLowerCase(Path) = AnsiLowerCase(MyComputer)) or (Path = '') or not DirectoryExists(S) then
    begin
      if Length(S) > 2 then
        if Copy(S, 1, 2) = '\\' then
        begin
          S := ExcludeTrailingBackslash(S);
          Delete(S, 1, 2);
          If Pos('\', S) = 0 then
          begin
            SetNewPathW(ExplorerPath('\\' + S, EXPLORER_ITEM_COMPUTER), False);
            Exit;
          end;
        end;
      if (AnsiLowerCase(Path) = AnsiLowerCase(MyComputer)) or (Path = '') then
      begin
        SetNewPathW(ExplorerPath('', EXPLORER_ITEM_MYCOMPUTER), False);
        Exit;
      end;
      S := ExcludeTrailingBackslash(Path);
      if DirectoryExists(S) then
        SetNewPathW(ExplorerPath(S, EXPLORER_ITEM_MYCOMPUTER), Explorer)
      else
      begin
        MessageBoxDB(Handle, Format(L('Directory "%s" not found!'), [S]), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
        Exit;
      end;
    end else
    begin
      S := ExcludeTrailingBackslash(Path);
      if Length(S) > 2 then
        if Copy(S, 1, 2) = '\\' then
        begin
          S := ExcludeTrailingBackslash(S);
          Delete(S, 1, 2);
          if Pos('\', S) <> 0 then
          begin
            S1 := S;
            for I := 1 to Length(S1) do
              if S1[I] = '\' then
              begin
                Delete(S1, I, 1);
                Break;
              end;
            if Pos('\', S) = 0 then
              SetNewPathW(ExplorerPath('\\' + S, EXPLORER_ITEM_SHARE), False)
            else
              SetNewPathW(ExplorerPath('\\' + S, EXPLORER_ITEM_FOLDER), False);
            Exit;
          end;
        end;
      if (Length(S) = 2) then
      begin
        if (S[2] = ':') then
          SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_DRIVE), Explorer)
        else
          SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_FOLDER), Explorer)
      end else
        SetNewPathW(ExplorerPath(Path, EXPLORER_ITEM_FOLDER), Explorer);
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

procedure TExplorerForm.ImPreviewDblClick(Sender: TObject);
var
  MenuInfo: TDBPopupMenuInfo;
begin
  if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
  begin
    MenuInfo := Self.GetCurrentPopUpMenuInfo(ListView1Selected);
    try
      Viewer.ShowImages(Sender, MenuInfo);
      Viewer.Show;
      Viewer.Restore;
    finally
      F(MenuInfo);
    end;
    Exit;
  end;
end;

procedure TExplorerForm.CMMOUSELEAVE(var Message: TWMNoParams);
var
  P: TPoint;
begin
  GetCursorPos(P);
  if THintManager.Instance.HintAtPoint(P) <> nil then
    Exit;

  LastMouseItem := nil;
  Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;
end;

procedure TExplorerForm.CopyFilesToClipboard(IsCutAction: Boolean = False);
var
  I, Index: Integer;
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
    if not IsDevicePath(FCurrentPath) then
    begin
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          FileList.Add(ProcessPath(FFilesInfo[Index].FileName));
        end;
      if FileList.Count > 0 then
        Copy_Move(Application.Handle, not IsCutAction, FileList);
    end else
    begin
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          FileList.Add(ExtractFileName(FFilesInfo[Index].FileName));
        end;

      ExecuteShellPathRelativeToMyComputerMenuAction(Handle, PhotoDBPathToDevicePath(FCurrentPath), FileList, Point(0, 0), nil, AnsiString(IIF(IsCutAction, 'Cut', 'Copy')));
    end;
  finally
    F(FileList);
  end;
end;

procedure TExplorerForm.CopyClick(Sender: TObject);
begin
  CopyFilesToClipboard;
end;

procedure TExplorerForm.CutClick(Sender: TObject);
begin
  CopyFilesToClipboard(True);
end;

procedure TExplorerForm.Options1Click(Sender: TObject);
begin
  OptionsForm.Show;
end;

procedure TExplorerForm.DBManager1Click(Sender: TObject);
begin
  CollectionManagerForm.Show;
end;

procedure TExplorerForm.Properties1Click(Sender: TObject);
var
  PropInfo, Info: TDBPopupMenuInfo;
  Files: TStrings;
  I, ItemIndex: Integer;
  EInfo: TExplorerFileInfo;
  P, PI: TPathItem;
  PL: TPathItemCollection;
  Bit32: TBitmap;

  procedure ShowWindowsPropertiesDialogToSelected;
  var
    I, Index: Integer;
  begin
    Files := TStringList.Create;
    try
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          Files.Add(FFilesInfo[index].FileName);
        end;
      GetPropertiesWindows(Files, ElvMain);
    finally
      F(Files);
    end;
  end;

begin
  EInfo := FFilesInfo[PmItemPopup.Tag];

  P := PathProviderManager.CreatePathItem(EInfo.FileName);
  try
    if P <> nil then
    begin
      if P.Provider.SupportsFeature(PATH_FEATURE_PROPERTIES) then
      begin
        PL := TPathItemCollection.Create;
        try
          for I := 0 to ElvMain.Items.Count - 1 do
          begin
            ItemIndex := ItemIndexToMenuIndex(I);
            if ItemIndex > FFilesInfo.Count - 1 then
              Exit;

            //skip filtered items
            if not ElvMain.Items[I].Visible then
              Continue;

            if not ElvMain.Items[I].Selected then
              Continue;

            PI := PathProviderManager.CreatePathItem(FFilesInfo[ItemIndex].FileName);
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

  if EInfo.FileType = EXPLORER_ITEM_IMAGE then
  begin
    if SelCount > 1 then
    begin
      Info := GetCurrentPopUpMenuInfo(ListView1Selected);
      try
        PropInfo := TDBPopupMenuInfo.Create;
        try
          for I := 0 to Info.Count - 1 do
            if Info[I].Selected then
              PropInfo.Add(Info[I].Copy);

        Bit32 := TBitmap.Create;
        try
          CreateMultiselectImage(ElvMain, Bit32, FBitmapImageList, ElvMain.Selection.GradientColorBottom, ElvMain.Selection.GradientColorTop,
            ElvMain.Selection.Color, ElvMain.Font, ThSizeExplorerPreview + 3, ThSizeExplorerPreview + 3);

          PropertyManager.NewSimpleProperty.ExecuteEx(PropInfo, Bit32);
        finally
          F(Bit32);
        end;

        finally
          F(PropInfo);
        end;
      finally
        F(Info);
      end;
      Exit;
    end else
    begin
      if not EInfo.Loaded then
        EInfo.ID := GetIdByFileName(EInfo.FileName);
      if EInfo.ID = 0 then
        PropertyManager.NewFileProperty(EInfo.FileName).ExecuteFileNoEx(EInfo.FileName)
      else
        PropertyManager.NewIDProperty(EInfo.ID).Execute(EInfo.ID);
      Exit;
    end;
  end;

  ShowWindowsPropertiesDialogToSelected;
end;

procedure TExplorerForm.PropertiesLinkClick(Sender: TObject);
var
  Item: TEasyItem;
  Index: Integer;

  function ExecuteProvider(FileName: string): Boolean;
  begin
    Result := ExecuteProviderFeature(Self, FileName, PATH_FEATURE_PROPERTIES);
  end;

begin
  if SelCount > 1 then
  begin
    Item := ListView1Selected;
    if Item = nil then
      Exit;
    Index := ItemIndexToMenuIndex(Item.Index);
    PmItemPopup.Tag := Index;
    if Index > FFilesInfo.Count - 1 then
      Exit;
    if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) or (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) or
      (FFilesInfo[Index].FileType = EXPLORER_ITEM_FILE) then
      Properties1Click(Sender);
    Exit;
  end;

  if SelCount = 0 then
  begin

    if ExecuteProvider(GetCurrentPath) then
      Exit;

    if FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER then
      ShowMyComputerProperties(Handle)
    else
      ShowPropertiesDialog(GetCurrentPath)
  end else
  begin
    if ExecuteProvider(FSelectedInfo.FileName) then
      Exit;

    if FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER then
      ShowMyComputerProperties(Handle)
    else
    begin
      if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
      begin
        if FSelectedInfo.ID = 0 then
          PropertyManager.NewFileProperty(FSelectedInfo.FileName).ExecuteFileNoEx(FSelectedInfo.FileName)
        else
          PropertyManager.NewIDProperty(FSelectedInfo.ID).Execute(FSelectedInfo.ID);
      end else
        ShowPropertiesDialog(FSelectedInfo.FileName);

    end;
  end;
end;

procedure TExplorerForm.SlideShowLinkClick(Sender: TObject);
var
  Info: TDBPopupMenuInfo;

  procedure ShowNoImagesError;
  begin
    MessageBoxDB(Handle, L('There are no images to display!'), L('Information'), TD_BUTTON_OK, TD_ICON_INFORMATION);;
  end;

begin
  if SelCount <> 0 then
  begin
    PmItemPopup.Tag := ItemIndexToMenuIndex(ListView1Selected.index);
    SlideShow1Click(Sender)
  end else if (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) and (SelCount = 0) then
  begin
    Info := GetCurrentPopUpMenuInfo(nil);
    try
      if Info.Count > 0 then
      begin
        Viewer.ShowImages(Self, Info);
        Viewer.Show;
        Viewer.Restore;
      end else
        ShowNoImagesError;
    finally
      F(Info);
    end;
  end else
  begin
    if Viewer.ShowImageInDirectory(GetCurrentPath, ExplorerManager.ShowPrivate) then
    begin
      Viewer.Show;
      Viewer.Restore;
    end
    else
      ShowNoImagesError;
  end;
end;

procedure TExplorerForm.slSearchCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  Accept := (NewSize > 100) and (PnNavigation.Width - StAddress.Width - NewSize > 300);
end;

procedure TExplorerForm.Searchfiles1Click(Sender: TObject);
begin
  Settings.WriteInteger('Explorer', 'SearchMode', EXPLORER_SEARCH_FILES);
  LoadSearchMode(EXPLORER_SEARCH_FILES);
end;

procedure TExplorerForm.SearchfileswithEXIF1Click(Sender: TObject);
begin
  Settings.WriteInteger('Explorer', 'SearchMode', EXPLORER_SEARCH_IMAGES);
  LoadSearchMode(EXPLORER_SEARCH_IMAGES);
end;

procedure TExplorerForm.Searchincollection1Click(Sender: TObject);
begin
  Settings.WriteInteger('Explorer', 'SearchMode', EXPLORER_SEARCH_DATABASE);
  LoadSearchMode(EXPLORER_SEARCH_DATABASE);
end;

procedure TExplorerForm.LoadSearchMode(SearchMode: Integer);
begin
  if FSearchMode = SearchMode then
    Exit;

  TW.I.Start('LoadSearchMode');
  FSearchMode := SearchMode;
  if SearchMode = EXPLORER_SEARCH_DATABASE then
  begin
    LoadSpeedButtonFromResourcePNG(SbSearchMode, 'S_DATABASE');
    LoadSpeedButtonFromResourcePNG(SbExtendedSearchMode, 'S_DATABASE');
    WedSearch.WatermarkText := L('Search in collection');
    EdExtendedSearchText.WatermarkText := L('Search in collection');
  end else if SearchMode = EXPLORER_SEARCH_FILES then
  begin
    LoadSpeedButtonFromResourcePNG(SbSearchMode, 'S_FILES');
    LoadSpeedButtonFromResourcePNG(SbExtendedSearchMode, 'S_FILES');
    WedSearch.WatermarkText := L('Search in directory');
    EdExtendedSearchText.WatermarkText := L('Search in directory');
  end else
  begin
    LoadSpeedButtonFromResourcePNG(SbSearchMode, 'S_IMAGES');
    LoadSpeedButtonFromResourcePNG(SbExtendedSearchMode, 'S_IMAGES');
    WedSearch.WatermarkText := L('Search in directory (with EXIF)');
    EdExtendedSearchText.WatermarkText := L('Search in directory (with EXIF)');
  end;

  if FExtendedSearchParams <> nil then
    ExtendedSearchCheckEnabled;

  TW.I.Start('LoadSearchMode - END');
end;

procedure TExplorerForm.InitSearch;
begin
  TW.I.Start('LoadSpeedButtonFromResourcePNG - SEARCH');
  LoadSpeedButtonFromResourcePNG(sbDoSearch, 'SEARCH');
  LoadSearchMode(Settings.ReadInteger('Explorer', 'SearchMode', EXPLORER_SEARCH_DATABASE));
end;

procedure TExplorerForm.PmSearchModePopup(Sender: TObject);

  procedure AddResourceImage(ResName: string);
  var
    PNG: TPngImage;
    BMP: TBitmap;
  begin
    BMP := TBitmap.Create;
    try
      PNG := TResourceUtils.LoadGraphicFromRES<TPngImage>(ResName);
      try
        LoadPNGImageTransparent(PNG, BMP);
      finally
        F(PNG);
      end;
      ImSearchMode.Add(BMP, nil);
    finally
      F(BMP);
    end;
  end;

begin
  if ImSearchMode.Count = 0 then
  begin
    AddResourceImage('FILES');
    AddResourceImage('CAMERA');
    AddResourceImage('DATABASE');
  end;

  Searchfiles1.ExSetDefault(FSearchMode = EXPLORER_SEARCH_FILES);
  SearchfileswithEXIF1.ExSetDefault(FSearchMode = EXPLORER_SEARCH_IMAGES);
  Searchincollection1.ExSetDefault(FSearchMode = EXPLORER_SEARCH_DATABASE);
end;

procedure TExplorerForm.PnInfoResize(Sender: TObject);
begin
  WlLearnMoreLink.Left := PnInfo.Width div 2 - WlLearnMoreLink.Width div 2;
end;

procedure TExplorerForm.PnResetFilterResize(Sender: TObject);
begin
  WlResetFilter.RefreshBuffer(True);
  WlResetFilter.Left := PnResetFilter.Width div 2 - WlResetFilter.Width div 2;
end;

procedure TExplorerForm.SbSearchModeClick(Sender: TObject);
var
  P: TPoint;
  Control: TControl;
begin
  Control := TControl(Sender);
  P := Point(0, Control.Height);
  P := Control.ClientToScreen(P);
  PmSearchMode.DoPopupEx(P.X, P.Y);
end;

procedure TExplorerForm.SetFilter1Click(Sender: TObject);
begin
  ShowFilter(True);
end;

procedure TExplorerForm.HideFilter(ResetFilter: Boolean = True);
begin
  if PnFilter.Visible then
  begin
    ElvMain.SetFocus;
    PnFilter.Hide;
  end else
    PnResetFilter.Hide;

  if ResetFilter then
    WedFilter.OnChange(Self);
end;


procedure TExplorerForm.ShowLeftTabIfWasActive(Tab: TExplorerLeftTab);
var
  TabToShow: Integer;
begin
  TabToShow := Settings.ReadInteger('Explorer', 'LeftPanelTabIndex', 0);
  if TabToShow = Integer(Tab) then
    ShowActiveLeftTab(Tab);
end;

procedure TExplorerForm.ShowActiveLeftTab(Tab: TExplorerLeftTab);
var
  TabToShow: TExplorerLeftTab;
begin
  TabToShow := Tab;
  if not (TabToShow in FLeftTabs) then
  begin
    TabToShow := TExplorerLeftTab(Settings.ReadInteger('Explorer', 'LeftPanelTabIndex', Integer(FActiveLeftTab)));
    if not (TabToShow in FLeftTabs) then
      TabToShow := eltsExplorer;
  end;
  if FActiveLeftTab <> TabToShow then
  begin
    FActiveLeftTab := TabToShow;
    FLeftTabs := FLeftTabs + [FActiveLeftTab];
  end;
end;

procedure TExplorerForm.ShowActiveRightTab(Tab: TExplorerRightTab);
var
  TabToShow: TExplorerRightTab;
begin
  TabToShow := Tab;
  if not (TabToShow in FRightTabs) then
  begin
    TabToShow := TExplorerRightTab(Settings.ReadInteger('Explorer', 'RightPanelTabIndex', Integer(FActiveLeftTab)));
    if not (TabToShow in FRightTabs) then
      TabToShow := ertsPreview;
  end;
  if FActiveRightTab <> TabToShow then
  begin
    FActiveRightTab := TabToShow;
    FRightTabs := FRightTabs + [FActiveRightTab];
  end;
end;

procedure TExplorerForm.ShowLastActiveLeftTab(Tab: TExplorerLeftTab);
var
  LastActiveTab: TExplorerLeftTab;
begin
  LastActiveTab := TExplorerLeftTab(Settings.ReadInteger('Explorer', 'LeftPanelTabIndex', 0));
  if (Tab = eltsAny) or (LastActiveTab = Tab) then
    ShowActiveLeftTab(LastActiveTab);
end;

procedure TExplorerForm.ShowLastActiveRightTab(Tab: TExplorerRightTab);
var
  LastActiveTab: TExplorerRightTab;
begin
  LastActiveTab := TExplorerRightTab(Settings.ReadInteger('Explorer', 'RightPanelTabIndex', 0));
  if (Tab = ertsAny) or (LastActiveTab = Tab) then
    ShowActiveRightTab(LastActiveTab);
end;

procedure TExplorerForm.ApplyLeftTabs;
var
  Tab: TExplorerLeftTab;
begin
  PcTasks.DisableTabChanging;
  try
    for Tab in [eltsTasks..eltsSearch] do
      if (Tab in FLeftTabs) then
        PcTasks.ShowTab(Integer(Tab))
      else
        PcTasks.HideTab(Integer(Tab));
  finally
    PcTasks.EnableTabChanging;
  end;
  if FActiveLeftTab = eltsSearch then
    ExtendedSearchInit;

  if (PcTasks.ActivePageIndex <> Integer(FActiveLeftTab)) and (FActiveLeftTab = eltsExplorer) then
    if (GetCurrentPathW.PType <> EXPLORER_ITEM_SEARCH) and (PePath.PathEx <> nil) then
      TreeView.SelectPathItem(PePath.PathEx);

  PcTasks.ActivePageIndex := Integer(FActiveLeftTab);
end;

procedure TExplorerForm.ApplyRightTabs;
var
  Tab: TExplorerRightTab;
begin
  PcRightPreview.DisableTabChanging;
  try
    for Tab in [ertsPreview..ertsMap] do
      if (Tab in FRightTabs) then
        PcRightPreview.ShowTab(Integer(Tab))
      else
        PcRightPreview.HideTab(Integer(Tab));
  finally
    PcRightPreview.EnableTabChanging;
  end;
  PcRightPreview.ActivePageIndex := Integer(FActiveRightTab);
  if FActiveRightTab = ertsMap then
    StartMap(False);
end;

procedure TExplorerForm.ShowFilter(PerformFilter: Boolean);
begin
  WedFilter.Left := LbFilter.Left + LbFilter.Width + 5;
  CbFilterMatchCase.Left := WedFilter.Left + WedFilter.Width + 5;
  ImFilterWarning.Left := CbFilterMatchCase.Left + CbFilterMatchCase.Width + 5;
  LbFilterInfo.Left := ImFilterWarning.Left + ImFilterWarning.Width + 5;
  PnFilter.Show;
  if Visible and PerformFilter then
    WedFilter.SetFocus;
  if PerformFilter then
    WedFilter.OnChange(Self);

  if TStyleManager.IsCustomStyleActive then
    InvalidateRect(PnFilter.Handle, PnFilter.ClientRect, True);
end;

procedure TExplorerForm.ShowHelp(Text, Link: string);
begin
  WlLearnMoreLink.Text := Text;
  WlLearnMoreLink.HelpKeyword := Link;
  WlLearnMoreLink.RefreshBuffer(True);

  PnInfoResize(Self);
  PnInfo.Show;
end;

procedure TExplorerForm.ShowHideFilter(Sender: TObject);
begin
  if not PnFilter.Visible then
    ShowFilter(True)
  else
    HideFilter;
end;

function TExplorerForm.InternalGetImage(FileName: string; Bitmap: TBitmap;
  var Width: Integer; var Height: Integer): Boolean;
var
  I, Index: Integer;
  B: TBitmap;
begin
  Result := False;
  B := nil;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if ElvMain.Items[I].ImageIndex <> -1 then
    begin
      Index := ItemIndexToMenuIndex(I);

      if AnsiLowerCase(FFilesInfo[Index].FileName) = FileName then
      begin

        if FImageViewer <> nil then
        begin
          if (AnsiLowerCase(FImageViewer.Item.FileName) = FileName) and not FImageViewer.DisplayBitmap.Empty and (FImageViewer.Text = '') then
            B := FImageViewer.DisplayBitmap;
        end;

        if (B = nil) and FBitmapImageList[ElvMain.Items[I].ImageIndex].IsBitmap then
          B := FBitmapImageList[ElvMain.Items[I].ImageIndex].Bitmap;

        Width := FFilesInfo[Index].Width;
        Height := FFilesInfo[Index].Height;
        if B <> nil then
        begin
          if (Width = 0) or (Height = 0) then
          begin
            Width := B.Width;
            Height := B.Height;
          end;
          Bitmap.Assign(B);
          Result := True;
        end;
        Break;
      end;
    end;
  end;
end;

procedure TExplorerForm.PasteFromClipboard;
var
  Files: TStrings;
  Effects: Integer;
  Path: string;
begin
  Path := GetCurrentPath;

  Files := TStringList.Create;
  try
    LoadFilesFromClipBoard(Effects, Files);
    if (Files.Count = 0) or IsDevicePath(FCurrentPath) then
    begin
      if ClipboardHasPIDList or (Files.Count > 0) then
        TExplorerPastePIDLsThread.Create(Self, Path);
      Exit;
    end;

    if Effects = DROPEFFECT_MOVE then
    begin
      CopyFiles(Handle, Files, Path, True, False, Self);
      ClipBoard.Clear;
      TbPaste.Enabled := False;
    end;
    if (Effects = DROPEFFECT_COPY) or (Effects = DROPEFFECT_COPY + DROPEFFECT_LINK) or (Effects = DROPEFFECT_NONE) then
      CopyFiles(Handle, Files, Path, False, False, Self);

  finally
    F(Files);
  end;
end;

procedure TExplorerForm.PasteClick(Sender: TObject);
begin
  PasteFromClipboard;
end;

procedure TExplorerForm.SetPathItem(PI: TPathItem);
begin
  if (PI is TDirectoryItem) or (PI is TDriveItem) or (PI is TShareItem) then
    SetStringPath(PI.Path, False)
  else if PI is TComputerItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_COMPUTER), False)
  else if PI is THomeItem then
    SetNewPathW(ExplorerPath('', EXPLORER_ITEM_MYCOMPUTER), False)
  else if PI is TNetworkItem then
    SetNewPathW(ExplorerPath('', EXPLORER_ITEM_NETWORK), False)
  else if PI is TWorkgroupItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_WORKGROUP), False)
  else if PI is TPersonsItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_PERSON_LIST), False)
  else if PI is TGroupsItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_GROUP_LIST), False)
  else if PI is TGroupItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_GROUP), False)
  else if PI is TPersonItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_PERSON), False)
  else if PI is TPortableDeviceItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_DEVICE), False)
  else if PI is TPortableStorageItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_DEVICE_STORAGE), False)
  else if PI is TPortableDirectoryItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_DEVICE_DIRECTORY), False)
  else if PI is TShelfItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_SHELF), False)
  else if PI is TDateStackItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_CALENDAR), False)
  else if PI is TDateStackYearItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_CALENDAR_YEAR), False)
  else if PI is TDateStackMonthItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_CALENDAR_MONTH), False)
  else if PI is TDateStackDayItem then
    SetNewPathW(ExplorerPath(PI.Path, EXPLORER_ITEM_CALENDAR_DAY), False);
end;

procedure TExplorerForm.PePathChange(Sender: TObject);
begin
  SetPathItem(PePath.CurrentPathEx);
end;

procedure TExplorerForm.PePathContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  MousePos := PePath.Clienttoscreen(MousePos);
  PmPathMenu.DoPopupEx(MousePos.X, MousePos.Y);
  Handled := True;
end;

procedure TExplorerForm.PePathGetItemIconEvent(Sender: TPathEditor;
  Item: TPathItem);
var
  Ico: TIcon;
begin
  if Item is THomeItem then
  begin
    FindIcon(HInstance, 'COMPUTER', 16, 32, Ico);
    Item.Image := TPathImage.Create(Ico);
  end;
end;

procedure TExplorerForm.PePathGetSystemIcon(Sender: TPathEditor; IconType: string; var Image: TPathImage);
var
  Ico: TIcon;
begin
  Ico := nil;
  try
    if IconType = PATH_EMPTY then
      FindIcon(HInstance, 'DIRECTORY', 16, 32, Ico)
    else if IconType = PATH_LOADING then
      FindIcon(HInstance, 'SEARCH', 16, 32, Ico)
    else if IconType = PATH_RELOAD then
      FindIcon(HInstance, 'REFRESH_THUM', 16, 32, Ico)
    else if IconType = PATH_STOP then
      FindIcon(HInstance, 'EXPLORER_BREAK_SMALL', 16, 32, Ico);

    if Ico <> nil then
      Image := TPathImage.Create(CopyIcon(Ico.Handle));
  finally
    F(Ico);
  end;
end;

procedure TExplorerForm.PePathImageContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Files: TStrings;
begin
  if not IsDevicePath(FCurrentPath) then
  begin
    Files := TStringList.Create;
    try
      Files.Add(ExcludeTrailingPathDelimiter(FCurrentPath));
      GetProperties(Files, MousePos, PePath);
    finally
      F(Files)
    end;
  end else
    ExecuteShellPathRelativeToMyComputerMenuAction(Handle, FCurrentPath, nil, MousePos, PePath, '');

  Handled := True;
end;

function TExplorerForm.GetPathPartName(PP: TPathItem): string;
begin
  Result := PP.DisplayName;
end;

procedure TExplorerForm.PePathUpdateItem(Sender: TObject; PathPart: TPathItem);
begin
  if PathPart is THomeItem then
    PathPart.DisplayName := MyComputer;
end;

procedure TExplorerForm.ShowLoadingSign;
begin
  LsMain.Show;
end;

procedure TExplorerForm.ShowOnlyCommon1Click(Sender: TObject);
begin
  ExplorerManager.ShowPrivate := False;
end;

procedure TExplorerForm.ShowPrivate1Click(Sender: TObject);
begin
  ExplorerManager.ShowPrivate := True;
end;

procedure TExplorerForm.LoadLanguage;
begin
  BeginTranslate;
  try
    SlideShowLink.Text := L('Slide show');
    ShellLink.Text := L('Open');
    CopyToLink.Text := L('Copy to');
    MoveToLink.Text := L('Move to');
    RenameLink.Text := L('Rename');
    PropertiesLink.Text := L('Properties');
    DeleteLink.Text := L('Delete');
    WlClear.Text := L('Clear');

    RefreshLink.Text := L('Refresh');
    ImageEditorLink.Text := L('Image editor');
    PrintLink.Text := L('Print');
    MyPicturesLink.Text := L('My pictures');
    MyDocumentsLink.Text := L('My documents');
    DesktopLink.Text := L('Desktop');
    MyComputerLink.Text := L('My Computer');
    AddLink.Text := L('Add to collection');
    WlImportPictures.Text := L('Import pictures');
    MiImportImages.Caption := L('Import pictures');
    WlShare.Text := L('Share');

    ImageTasksLabel.Caption := L('Image tasks');
    WlResize.Text := L('Resize');
    WlConvert.Text := L('Convert');
    WlCrop.Text := L('Crop');

    TasksLabel.Caption := L('Tasks');
    Open1.Caption := L('Open');
    Open2.Caption := L('Open');
    SlideShow1.Caption := L('Show');
    NewWindow1.Caption := L('New Window');
    Shell1.Caption := L('Open');
    DBitem1.Caption := L('Collection Item');
    Copy1.Caption := L('Copy');
    Cut2.Caption := L('Cut');
    Delete1.Caption := L('Delete');
    Rename1.Caption := L('Rename');
    New1.Caption := L('New');
    Directory1.Caption := L('Directory');
    Refresh1.Caption := L('Refresh');
    Properties1.Caption := L('Properties');
    AddFile1.Caption := L('Add file');
    OpenInNewWindow1.Caption := L('Open in new window');
    OpenInNewWindow2.Caption := L('Open in new window');

    Paste1.Caption := L('Paste');
    Addfolder1.Caption := L('Add folder');
    MakeNew1.Caption := L('Make new');

    Directory2.Caption := L('Directory');
    TextFile2.Caption := L('Text file');

    ShowUpdater1.Caption := L('Show update window');
    Refresh2.Caption := L('Refresh');
    SelectAll1.Caption := L('Select all');
    Exit2.Caption := L('Exit');

    MiTreeViewOpenInNewWindow.Caption := L('Open in new window');
    MiTreeViewRefresh.Caption := L('Refresh');

    StAddress.Caption := L('Address') + ':';
    CryptFile1.Caption := L('Encrypt file');
    ResetPassword1.Caption := L('Decrypt file');
    EnterPassword1.Caption := L('Enter password');
    Convert1.Caption := L('Convert');
    Resize1.Caption := L('Resize');
    Rotate1.Caption := L('Rotate');
    RotateCCW1.Caption := L('Rotate left');
    RotateCW1.Caption := L('Rotate right');
    Rotateon1801.Caption := L('Rotate 180°');
    AsEXIF1.Caption := L('By EXIF');
    SetasDesktopWallpaper1.Caption := L('Set as desktop wallpaper');
    Stretch1.Caption := L('Stretch');
    Center1.Caption := L('Center');
    Tile1.Caption := L('Tile');
    RefreshID1.Caption := L('Refresh info');
    ImageEditor2.Caption := L('Image editor');

    Othertasks1.Caption := L('Other tasks');
    ExportImages1.Caption := L('Export images');
    Print1.Caption := L('Print');

    OtherPlacesLabel.Caption := L('Other places');

    TextFile1.Caption := L('New text file');
    Copywithfolder1.Caption := L('Copy with folder');

    Copy4.Caption := L('Copy');
    Move1.Caption := L('Move');
    Cancel1.Caption := L('Cancel');

    MiShare.Caption := L('Share');

    Sortby1.Caption := L('Sort by');

    Nosorting1.Caption := L('No sorting');
    FileName1.Caption := L('File name');
    Size1.Caption := L('File size');
    Type1.Caption := L('File type');
    Modified1.Caption := L('Modify date');
    Rating1.Caption := L('Rating');
    Number1.Caption := L('Number');
    SetFilter1.Caption := L('Set filter');

    MakeFolderViewer1.Caption := L('Make portable viewer');
    MakeFolderViewer2.Caption := L('Make portable viewer');

    Thumbnails1.Caption := L('Thumbnail');
    Tile2.Caption := L('Tile');
    Icons1.Caption := L('Icons');
    SmallIcons1.Caption := L('Table');
    List1.Caption := L('List');

    StenoGraphia1.Caption := L('Data hiding');
    AddHiddenInfo1.Caption := L('Hide data in image');
    ExtractHiddenInfo1.Caption := L('Extract hidden data');

    MapCD1.Caption := L('Map CD with collection');

    TbOptions.Caption := L('Options');
    TbBack.Hint := L('Back');
    TbForward.Hint := L('Forward');
    TbUp.Hint := L('Go up');
    TbCut.Hint := L('Cut');
    TbCopy.Hint := L('Copy');
    TbPaste.Hint := L('Paste');
    TbDelete.Hint := L('Delete');
    ToolButtonView.Hint := L('View');
    TbZoomOut.Hint := L('Zoom out');
    TbZoomIn.Hint := L('Zoom in');
    TbSearch.Hint := L('Go to search window');
    TbOptions.Hint := L('Options');
    ToolBarMain.ShowCaptions := True;
    ToolBarMain.AutoSize := True;

    PePath.LoadingText := L('Loading...');

    // search
    Searchfiles1.Caption := L('Search in directory');
    SearchfileswithEXIF1.Caption := L('Search in directory (with EXIF)');
    Searchincollection1.Caption := L('Search in collection');

    // filter
    WedFilter.WatermarkText := L('Filter content');
    CbFilterMatchCase.Caption := L('Match case');
    LbFilter.Caption := L('Filter') + ':';
    LbFilterInfo.Caption := L('Sorry, but phrase not found!');
    WlResetFilter.Text := L('Reset filter');

    MiCopyAddress.Caption := L('Copy address');
    MiEditAddress.Caption := L('Edit address');

    TsTasks.Caption := L('Tasks');
    TsExplorer.Caption := L('Explorer');
    TsInfo.Caption := L('Info');
    TsEXIF.Caption := L('EXIF');
    TsDetailedSearch.Caption := L('Search');

    VleExif.TitleCaptions[0] := L('Key');
    VleExif.TitleCaptions[1] := L('Value');

    BtnSaveInfo.Caption := L('Save');
    LbHistogramImage.Caption := L('Histogram');
    LbEditKeywords.Caption := L('Keywords') + ':';
    LbEditComments.Caption := L('Comment') + ':';

    ToolBarBottom.ShowCaptions := False;
    TbbPlay.Caption := L('Show');
    TbbEncrypt.Caption := L('Encrypt');
    TbbResize.Caption := L('Resize');
    TbbConvert.Caption := L('Convert');
    TbbCrop.Caption := L('Crop');
    TbbPrint.Caption := L('Print');
    TbbEditor.Caption := L('Image editor');
    TbbGeo.Caption := L('Display on map');
    TbbRename.Caption := L('Rename');
    TbbProperties.Caption := L('Properties');
    TbbShare.Caption := L('Share');
    TbbOpenDirectory.Caption := L('Open directory');
    ToolBarBottom.ShowCaptions := True;

    TsGeoLocation.Caption := L('Map');
    TsMediaPreview.Caption := L('Preview');

    MiInfoGroupFind.Caption := L('Find pictures');
    MiInfoGroupRemove.Caption := L('Remove from list');
    MiInfoGroupProperties.Caption := L('Properties');
  finally
    EndTranslate;
  end;
end;

procedure TExplorerForm.LoadLastPath;
begin
  SetNewPathW(
    ExplorerPath(
      Settings.ReadString('Explorer', 'Path', GetMyPicturesPath),
      Settings.ReadInteger('Explorer', 'PathType', EXPLORER_ITEM_FOLDER)), False);
end;

procedure TExplorerForm.HandleEncryptionError(FileName, ErrorMessage: string);
var
  ErrorText: string;
begin
  ErrorText := L('File processing could be failed. Please try internal video player or current programm isn''t suported! Internal details: {0}');
  ErrorText := FormatEx(ErrorText, [ErrorMessage]);
  ShowHelp(ErrorText, 'transparent-encryption-error');
end;

procedure TExplorerForm.Help1Click(Sender: TObject);
begin
  AboutForm.Execute;
end;

procedure TExplorerForm.PopupMenuBackPopup(Sender: TObject);
begin
  if TPopupMenu(Sender).Tag = 0 then
    TLoadPathList.Create(Self, FHistory.GetBackHistory, TPopupActionBar(Sender));
end;

procedure TExplorerForm.PopupMenuForwardPopup(Sender: TObject);
begin
  if TPopupMenu(Sender).Tag = 0 then
    TLoadPathList.Create(Self, FHistory.GetForwardHistory, TPopupActionBar(Sender));
end;

procedure TExplorerForm.MiTreeViewOpenInNewWindowClick(Sender: TObject);
var
  Explorer: TCustomExplorerForm;
begin
  Explorer := ExplorerManager.NewExplorer(False);
  Explorer.SetPathItem(TreeView.PopupItem);
  Explorer.Show;
  Explorer.SetFocus;
end;

procedure TExplorerForm.MiTreeViewRefreshClick(Sender: TObject);
begin
  TreeView.RefreshPathItem(TreeView.PopupItem);
end;

procedure TExplorerForm.AddLinkClick(Sender: TObject);
begin
  AddFile1Click(Sender);
end;

procedure TExplorerForm.ScrollBox1Resize(Sender: TObject);
begin
  ScrollBox1.BackgroundLeft := ScrollBox1.Width - ScrollBox1.BackGround.Width - 3;
  ScrollBox1.BackgroundTop := ScrollBox1.Height - ScrollBox1.BackGround.Height - 3;
end;

procedure TExplorerForm.SetNewPathW(WPath: TExplorerPath; Explorer: Boolean);
var
  OldDir, S, Path, FileMask: string;
  UpdaterInfo: TUpdaterInfo;
  ThreadType: Integer;
  Info: TExplorerViewInfo;
  PI: TPathItem;
  P: TSearchItem;

  procedure UpdateCurrentHistoryFocusedItem;
  var
    Index: Integer;
    FileName: string;
  begin
    if ElvMain.Selection.FocusedItem <> nil then
    begin
      Index := ItemIndexToMenuIndex(ElvMain.Selection.FocusedItem.Index);
      FileName := FFilesInfo[Index].FileName;

      FHistory.UpdateLastFileForCurrentState(FileName);
    end;
  end;

begin
  PnInfo.Hide;
  FSelectedItem := nil;
  EventLog('SetNewPathW "' + WPath.Path + '"');
  TW.I.Start('SetNewPathW');

  TW.I.Start('HideFilter - END');

  RefreshIDList.Clear;

  FDBCanDragW := False;
  FDBCanDrag := False;

  TbUp.Enabled := (WPath.PType <> EXPLORER_ITEM_MYCOMPUTER);
  OldDir := GetCurrentPath;
  Path := WPath.Path;

  UpdateCurrentHistoryFocusedItem;

  if FChangeHistoryOnChPath then
    if (FHistory.LastPath.Path <> Path) or (FHistory.LastPath.PType <> WPath.PType) then
      FHistory.Add(ExplorerPath(Path, WPath.PType));

  ThreadType := THREAD_TYPE_FOLDER;

  TW.I.Start('PATH parsing');

  if Length(Path) > 1 then
    if ((Path[1] = '\') and (Path[2] <> '\')) then
    begin
      Path := GetcurrentDir + Path;
      WPath.PType := EXPLORER_ITEM_FOLDER;
    end;
  if Path = '\' then
  begin
    Path := GetcurrentDir;
    WPath.PType := EXPLORER_ITEM_FOLDER;
  end;

  TW.I.Start('PATH parsing EXPLORER_ITEM_MYCOMPUTER');
  if WPath.PType = EXPLORER_ITEM_MYCOMPUTER then
  begin
    PePath.Path := '';
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_MY_COMPUTER;
    Path := '';
  end;
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or (WPath.PType = EXPLORER_ITEM_SHARE)
    then
  begin
    S := ExcludeTrailingBackslash(Path);
    Caption := S;
    PePath.Path := Path;
  end;
  TW.I.Start('PATH parsing EXPLORER_ITEM_NETWORK');
  if WPath.PType = EXPLORER_ITEM_NETWORK then
  begin
    PePath.SetPathEx(TNetworkItem, cNetworkPath);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_NETWORK;
  end;
  if WPath.PType = EXPLORER_ITEM_WORKGROUP then
  begin
    Caption := Path;
    PePath.SetPathEx(TWorkGroupItem, Path);
    ThreadType := THREAD_TYPE_WORKGROUP;
  end;
  if WPath.PType = EXPLORER_ITEM_COMPUTER then
  begin
    Caption := Path;
    PePath.SetPathEx(TComputerItem, Path);
    ThreadType := THREAD_TYPE_COMPUTER;
  end;
  if WPath.PType = EXPLORER_ITEM_PERSON_LIST then
  begin
    PePath.SetPathEx(TPersonsItem, Path);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_PERSONS;
  end;
  if WPath.PType = EXPLORER_ITEM_PERSON then
  begin
    PePath.SetPathEx(TPersonItem, Path);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_PERSON;
  end;
  if WPath.PType = EXPLORER_ITEM_GROUP_LIST then
  begin
    PePath.SetPathEx(TGroupsItem, Path);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_GROUPS;
  end;
  if WPath.PType = EXPLORER_ITEM_SHELF then
  begin
    PePath.SetPathEx(TShelfItem, Path);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_SHELF;
  end;
  if WPath.PType in [EXPLORER_ITEM_CALENDAR, EXPLORER_ITEM_CALENDAR_YEAR, EXPLORER_ITEM_CALENDAR_MONTH, EXPLORER_ITEM_CALENDAR_DAY] then
  begin
    PI := PathProviderManager.CreatePathItem(Path);
    try
      PePath.SetPathEx(Self, PI, False);
      Caption := PePath.CurrentPathEx.DisplayName;
      ThreadType := THREAD_TYPE_PATH_ITEM;
    finally
      F(PI);
    end;
  end;
  if WPath.PType = EXPLORER_ITEM_GROUP then
  begin
    PePath.SetPathEx(TGroupItem, Path);
    Caption := PePath.CurrentPathEx.DisplayName;
    ThreadType := THREAD_TYPE_GROUP;
  end;
  if WPath.PType = EXPLORER_ITEM_DEVICE then
  begin
    Caption := Path;
    PePath.SetPathEx(TPortableDeviceItem, Path);
    ThreadType := THREAD_TYPE_CAMERA;
  end;
  if WPath.PType = EXPLORER_ITEM_DEVICE_STORAGE then
  begin
    Caption := Path;
    PePath.SetPathEx(TPortableStorageItem, Path);
    ThreadType := THREAD_TYPE_CAMERA;
  end;
  if WPath.PType = EXPLORER_ITEM_DEVICE_DIRECTORY then
  begin
    Caption := Path;
    PePath.SetPathEx(TPortableDirectoryItem, Path);
    ThreadType := THREAD_TYPE_CAMERA;
  end;

  S := Path;
  FCurrentPath := Path;

  TW.I.Start('PATH parsing EXPLORER_ITEM_SEARCH');
  if WPath.PType = EXPLORER_ITEM_SEARCH then
  begin
    TW.I.Start('PATH parsing CreatePathItem');
    P := PathProviderManager.CreatePathItem(WPath.Path) as TSearchItem;
    try
      TW.I.Start('PATH parsing FileMask');
      FileMask := P.SearchTerm;

      Path := P.SearchPath;
      FCurrentPath := WPath.Path;

      TW.I.Start('PATH parsing PePath.PathEx = ' + IIF(PePath.PathEx = nil, 'nil', 'not nil'));
      if PePath.PathEx = nil then
        PePath.SetPathEx(Self, P, False);
      PePath.SetPathEx(Self, P, False);
      TW.I.Start('PATH parsing SetPathEx END');
      Caption := L(IIF(P.SearchPath = '', MyComputer, P.SearchPath) + ' - ' + GetPathPartName(PePath.PathEx));

      TW.I.Start('PATH parsing P is TImageSearchItem');
      if P is TImageSearchItem then
      begin
        ThreadType := THREAD_TYPE_SEARCH_IMAGES;
        LoadSearchMode(EXPLORER_SEARCH_IMAGES);
      end else if P is TFileSearchItem then
      begin
        ThreadType := THREAD_TYPE_SEARCH_FOLDER;
        LoadSearchMode(EXPLORER_SEARCH_FILES);
      end else if P is TDBSearchItem then
      begin
        ThreadType := THREAD_TYPE_SEARCH_DB;
        LoadSearchMode(EXPLORER_SEARCH_DATABASE);
      end;

      TW.I.Start(' -> DirectoryWatcher.StopWatch');
      DirectoryWatcher.StopWatch;
    finally
      F(P);
    end;
  end;

  TW.I.Start('PATH parsing NewFormState');
  NewFormState;
  FCurrentTypePath := WPath.PType;
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) then
    S := IncludeTrailingBackslash(S);
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or
     (WPath.PType = EXPLORER_ITEM_DRIVE) or
     (WPath.PType = EXPLORER_ITEM_SHARE) then
  begin
    EventLog('ExplorerThreadNotifyDirectoryChange');
    try
      TW.I.Start(' -> DirectoryWatcher.StopWatch');
      DirectoryWatcher.StopWatch;
      TW.I.Start(' -> DirectoryWatcher.Start');
      DirectoryWatcher.Start(S, Self, StateID);
    except
      TW.I.Start(' -> EXCEPTION!!!');
    end;
  end
  else if (WPath.PType = EXPLORER_ITEM_MYCOMPUTER) then
    S := MyComputer;

  FChangeHistoryOnChPath := True;
  if (WPath.PType = EXPLORER_ITEM_MYCOMPUTER) or (WPath.PType = EXPLORER_ITEM_SEARCH) then
    TbCut.Enabled := False
  else
    TbCut.Enabled := True;

  FFilesInfo.Clear;

  SelectTimer.Enabled := False;

  if ElvMain <> nil then
  begin
    ClearList;
    ElvMain.Groups.Add;
  end;

  TW.I.Start('PATH parsing NewFormState');
  ListView1SelectItem(nil, nil, False);

  FBitmapImageList.Clear;

  Info := ViewInfo;
  Info.OldFolderName := FOldPatch;
  Info.ShowPrivate := ExplorerManager.ShowPrivate;
  Info.PictureSize := FPictureSize;

  case ListView of
    LV_THUMBS:
        ElvMain.View := ElsThumbnail;
    LV_ICONS:
        ElvMain.View := ElsIcon;
    LV_SMALLICONS:
        ElvMain.View := ElsSmallIcon;
    LV_TITLES:
        ElvMain.View := ElsList;
    LV_TILE:
        ElvMain.View := ElsTile;
    LV_GRID:
        ElvMain.View := ElsGrid;
  end;

  EventLog('ExplorerThread');
  if ElvMain <> nil then
  begin
    PePath.CanBreakLoading := True;
    UpdaterInfo := TUpdaterInfo.Create;
    TExplorerThread.Create(Path, FileMask, ThreadType, Info, Self, UpdaterInfo, StateID);
  end;
  if IsExplorerTreeViewVisible and not Explorer then
  begin
    if (WPath.PType <> EXPLORER_ITEM_SEARCH) then
      TreeView.SelectPath(GetCurrentPath)
    else
      TreeView; //just start tree
  end;

  DropFileTargetMain.Unregister;
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or (WPath.PType = EXPLORER_ITEM_SHARE) then
    DropFileTargetMain.Register(ElvMain);

  if not NotSetOldPath then
  begin
    FOldPatch := Path;
    FOldPatchType := WPath.PType;
  end;

  if (WPath.PType = EXPLORER_ITEM_PERSON_LIST) or (WPath.PType = EXPLORER_ITEM_GROUP_LIST) then
    ShowFilter(False)
  else
    HideFilter(False);

  if TStyleManager.IsCustomStyleActive then
  begin
    InvalidateRect(PePath.Handle, PePath.ClientRect, True);
    InvalidateRect(ToolBarMain.Handle, ToolBarMain.ClientRect, True);
  end;

  WlSaveLocation.Enabled := False;

  EventLog('SetPath OK');
end;

function TExplorerForm.GetCurrentPathW: TExplorerPath;
begin
  Result.Path := FCurrentPath;
  Result.PType := FCurrentTypePath;
end;

procedure TExplorerForm.RefreshLinkClick(Sender: TObject);
begin
  if (SelCount = 0) or (GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER) then
    Refresh2Click(Sender)
  else
    Refresh1Click(Sender);
end;

procedure TExplorerForm.DoBack;
begin
  if FHistory.CanBack then
    SetNewPathW(FHistory.DoBack, False)
  else
    SetNewPathW(ExplorerPath('', EXPLORER_ITEM_MYCOMPUTER), False);
end;

procedure TExplorerForm.JumpHistoryClick(Sender: TObject);
var
  N: Integer;
begin
  N := (Sender as TMenuItem).Tag;
  FChangeHistoryOnChPath := False;
  FHistory.Position := N;
  HistoryChanged(Sender);
  SetNewPathW(FHistory[N], False);
end;

procedure TExplorerForm.KernelEventCallBack(ID: Integer; Params: TEventFields;
  Value: TEventValues);
begin
  DBKernel.DoIDEvent(Self, ID, Params, Value);
end;

procedure TExplorerForm.DragTimerTimer(Sender: TObject);
var
  ListItem: TEasyItem;
  P: TPoint;
  Index: Integer;
  SmintL, SmintR: SmallInt;

  function ValidItem(Item: TEasyItem): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to Length(FListDragItems) - 1 do
      if FListDragItems[I] = Item then
      begin
        Result := False;
        Break;
      end;
  end;

begin
  SmintL := GetAsyncKeystate(VK_LBUTTON);
  SmintR := GetAsyncKeystate(VK_RBUTTON);

  if not(SmintL <> 0) and not(SmintR <> 0) then
  begin
    FDBCanDrag := False;
    FDBCanDragW := False;
    Exit;
  end;
  if (FDBCanDrag or FDBCanDragW) and not Rdown then
    if (SmintL <> 0) or (SmintR <> 0) then
      if (SelfDraging or Outdrag) then
      begin
        GetCursorPos(P);
        P := ElvMain.ScreenToClient(P);
        ListItem := ItemAtPos(P.X, P.Y);
        if ListView1Selected = ListItem then
        begin
          if ListView1Selected <> nil then
          begin
            index := ItemIndexToMenuIndex(ListItem.index);
            if not((FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or
                (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) or
                (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) or
                (GetExt(FFilesInfo[index].FileName) = 'EXE')) then
              SetSelected(nil)
          end else
          begin
            SetSelected(nil);
            ItemsDeselected := True;
          end;
          Exit;
        end;
        if ListItem <> nil then
        begin
          index := ItemIndexToMenuIndex(ListItem.index);
          if ListView1Selected <> nil then
            ListView1Selected.Selected := False;
          if ((FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE)
              or (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) or (GetExt(FFilesInfo[index].FileName) = 'EXE'))
            and ValidItem(ListItem) then
          begin
            SetSelected(ListItem);
            ListView1Selected.Selected := True;
          end else
            SetSelected(nil);
        end else
          SetSelected(nil);
      end;
  if ListView1Selected = nil then
    ItemsDeselected := True;
end;

procedure TExplorerForm.DragEnter(Sender: TObject);
begin
  FDBCanDragW := True;
end;

procedure TExplorerForm.DragLeave(Sender: TObject);
begin
  FDBCanDragW := False;
end;

procedure TExplorerForm.Activation1Click(Sender: TObject);
begin
  ActivationForm.Execute;
end;

procedure TExplorerForm.Help2Click(Sender: TObject);
begin
  DoHelp;
end;

procedure TExplorerForm.HomePage1Click(Sender: TObject);
begin
  DoHomePage;
end;

procedure TExplorerForm.ContactWithAuthor1Click(Sender: TObject);
begin
  DoHomeContactWithAuthor;
end;

procedure EncryptFiles(Owner: TListViewForm; FileList: TDBPopupMenuInfo; Password: string; IsEncrypt: Boolean);
var
  I: Integer;
  Options: TCryptImageThreadOptions;
  ItemFileNames: TArStrings;
  ItemIDs: TArInteger;
  ItemSelected: TArBoolean;
begin
  SetLength(ItemFileNames, FileList.Count);
  SetLength(ItemIDs, FileList.Count);
  SetLength(ItemSelected, FileList.Count);

  // be default unchecked
  for I := 0 to FileList.Count - 1 do
    ItemSelected[I] := False;

  for I := 0 to FileList.Count - 1 do
    if FileList[I].Selected then
    begin
      ItemFileNames[I] := ProcessPath(FileList[I].FileName);
      ItemIDs[I] := FileList[I].ID;
      ItemSelected[I] := True;
    end;

  Options.Files := Copy(ItemFileNames);
  Options.IDs := Copy(ItemIDs);
  Options.Selected := Copy(ItemSelected);
  Options.Action := IIF(IsEncrypt, ACTION_ENCRYPT_IMAGES, ACTION_DECRYPT_IMAGES);
  Options.Password := Password;
  Options.EncryptOptions := CRYPT_OPTIONS_NORMAL;

  TCryptingImagesThread.Create(Owner, Options);
end;

procedure TExplorerForm.ResetPassword1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
  FileName, Password: string;
  Item: TEasyItem;
  Index: Integer;

  I: Integer;
  ItemIndex: Integer;
  FileInfo: TExplorerFileInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Info := TExplorerFileInfos.Create;
  try
    //fill list of files
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      //skip filtered items
      if not ElvMain.Items[I].Visible then
        Continue;

      ItemIndex := ItemIndexToMenuIndex(I);
      if ItemIndex > FFilesInfo.Count - 1 then
        Exit;

      FileInfo := FFilesInfo[ItemIndex];

      if (FileInfo.FileType = EXPLORER_ITEM_IMAGE) or CanBeTransparentEncryptedFile(FileInfo.FileName) then
      begin
        MenuRecord := FileInfo.Copy;
        MenuRecord.Selected := ElvMain.Items[I].Selected;
        MenuRecord.Exists := 1;
        Info.Add(MenuRecord);
      end;
    end;

    if PmItemPopup.Tag <> -1 then
      FileName := ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)
    else
    begin
      Item := ElvMain.Selection.First;
      if Item = nil then
        Exit;

      Index := ItemIndexToMenuIndex(Item.Index);
      FileName := IIF(Index > -1, ProcessPath(FFilesInfo[Index].FileName), '');
    end;

    Password := DBKernel.FindPasswordForCryptImageFile(FileName);
    if (Password = '') then
      Password := RequestPasswordForm.ForImage(FileName);
    if (Password = '') then
      Exit;

    EncryptFiles(Self, Info, Password, False);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.CryptFile1Click(Sender: TObject);
var
  Opt: TEncryptImageOptions;
  Info: TDBPopupMenuInfo;
  FileName: string;
  Item: TEasyItem;
  Index: Integer;

  I: Integer;
  ItemIndex: Integer;
  FileInfo: TExplorerFileInfo;
  MenuRecord: TDBPopupMenuInfoRecord;
begin
  Info := TExplorerFileInfos.Create;
  try
    //fill list of files
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      //skip filtered items
      if not ElvMain.Items[I].Visible then
        Continue;

      ItemIndex := ItemIndexToMenuIndex(I);
      if ItemIndex > FFilesInfo.Count - 1 then
        Exit;

      FileInfo := FFilesInfo[ItemIndex];

      if (FileInfo.FileType = EXPLORER_ITEM_IMAGE) or CanBeTransparentEncryptedFile(FileInfo.FileName) then
      begin
        MenuRecord := FileInfo.Copy;
        MenuRecord.Selected := ElvMain.Items[I].Selected;
        MenuRecord.Exists := 1;
        Info.Add(MenuRecord);
      end;
    end;

    if PmItemPopup.Tag <> -1 then
      FileName := ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)
    else
    begin
      Item := ElvMain.Selection.First;
      if Item = nil then
        Exit;

      Index := ItemIndexToMenuIndex(Item.Index);
      FileName := IIF(Index > -1, ProcessPath(FFilesInfo[Index].FileName), '');
    end;

    Opt := EncryptForm.QueryPasswordForFile(FileName);
    if Opt.Password = '' then
      Exit;

    EncryptFiles(Self, Info, Opt.Password, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.EnterPassword1Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  if FFilesInfo[PmItemPopup.Tag].ID <> 0 then
  begin
    EventInfo.Image := nil;
    if RequestPasswordForm.ForImage(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)) <> '' then
      DBKernel.DoIDEvent(Self, FFilesInfo[PmItemPopup.Tag].ID, [EventID_Param_Image], EventInfo);
  end else
  begin
    if RequestPasswordForm.ForImage(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)) <> '' then
      RefreshItemByName(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName), False);
  end;
end;

procedure TExplorerForm.Resize1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
  Item: TEasyItem;
begin
  if Sender = WlResize then
    Item := ElvMain.Selection.First
  else
    Item := ElvMain.Selection.FocusedItem;
  List := GetCurrentPopUpMenuInfo(Item);
  try
    BatchProcessingForm.ResizeImages(Self, List);
  finally
    F(List);
  end;
end;

procedure TExplorerForm.RestoreDragSelectedItems;
var
  I, J: Integer;
begin
  SetSelected(nil);

  for J := 0 to ElvMain.Items.Count - 1 do
  begin
    for I := 0 to Length(FListDragItems) - 1 do
      if FListDragItems[I] = ElvMain.Items[J] then
      begin
        FListDragItems[I].Selected := True;
        Break;
      end;
  end;
end;

procedure TExplorerForm.Convert1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
  Item: TEasyItem;
begin
  if Sender = WlConvert then
    Item := ElvMain.Selection.First
  else
    Item := ElvMain.Selection.FocusedItem;
  List := GetCurrentPopUpMenuInfo(Item);
  try
    BatchProcessingForm.ConvertImages(Self, List);
  finally
    F(List);
  end;
end;

procedure TExplorerForm.CoolBarBottomResize(Sender: TObject);
var
  I, TotalWidth, WidthDiff: Integer;
  ToolButtonsToHide: TList<TToolButton>;
begin
  //Bottom toolbar width customization
  TotalWidth := 0;
  for I := 0 to ToolBarBottom.ButtonCount - 1 do
  begin
    Inc(TotalWidth, ToolBarBottom.Buttons[I].Width);
  end;

  ToolButtonsToHide := TList<TToolButton>.Create;
  try
    ToolButtonsToHide.Add(TbbOpenDirectory);
    ToolButtonsToHide.Add(TbbConvert);
    ToolButtonsToHide.Add(TbbCrop);
    ToolButtonsToHide.Add(TbbRename);
    ToolButtonsToHide.Add(TbbEditor);
    ToolButtonsToHide.Add(TbbPrint);
    ToolButtonsToHide.Add(TbbShare);
    ToolButtonsToHide.Add(TbbGeo);

    WidthDiff := ToolBarBottom.Width - TotalWidth;
    for I := 0 to ToolButtonsToHide.Count - 1 do
    begin
      if WidthDiff < 0 then
        ToolButtonsToHide[I].Visible := False
      else
        ToolButtonsToHide[I].Visible := True;

      Inc(WidthDiff, ToolButtonsToHide[I].Width);
    end;
  finally
    F(ToolButtonsToHide);
  end;
end;

procedure TExplorerForm.Stretch1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := FFilesInfo[PmItemPopup.Tag].FileName;
  SetDesktopWallpaper(FileName, WPSTYLE_STRETCH);
end;

procedure TExplorerForm.Center1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := FFilesInfo[PmItemPopup.Tag].FileName;
  SetDesktopWallpaper(FileName, WPSTYLE_CENTER);
end;

procedure TExplorerForm.Tile1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := FFilesInfo[PmItemPopup.Tag].FileName;
  SetDesktopWallpaper(FileName, WPSTYLE_TILE);
end;

procedure TExplorerForm.AsEXIF1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem);
  try
    BatchProcessingForm.RotateImages(Self, Info, DB_IMAGE_ROTATE_EXIF, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RotateCCW1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem);
  try
    BatchProcessingForm.RotateImages(Self, Info, DB_IMAGE_ROTATE_270, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RotateCW1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem);
  try
    BatchProcessingForm.RotateImages(Self, Info, DB_IMAGE_ROTATE_90, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.Rotateon1801Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem);
  try
    BatchProcessingForm.RotateImages(Self, Info, DB_IMAGE_ROTATE_180, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RefreshID1Click(Sender: TObject);
var
  Options: TRefreshIDRecordThreadOptions;
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    Options.Info := Info;
    TRefreshDBRecordsThread.Create(Self, Options);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.DropFileTargetMainDrop(Sender: TObject; ShiftState: TShiftState; Point: TPoint;
  var Effect: Integer);
var
  I, Index: Integer;
  Si: TStartupInfo;
  P: TProcessInformation;
  Str, Params: string;
  DropInfo: TStrings;
  Pnt: TPoint;
begin
  Outdrag := False;
  DropInfo := TStringList.Create;
  try
    DropFileTargetMain.Files.AssignTo(DropInfo);
    if DropInfo.Count = 0 then
      Exit;

    if SsRight in LastShift then
    begin
      Move1.Visible := not SelfDraging;
      FDBCanDragW := False;
      FDBCanDrag := False;
      LastListViewSelCount := SelCount;
      LastListViewSelected := ListView1Selected;
      DragFilesPopup.Assign(DropInfo);
      GetCursorPos(Pnt);
      PmDragMode.DoPopupEx(Pnt.X, Pnt.Y);
      if Length(FListDragItems) > 0 then
      begin
        RestoreDragSelectedItems;
        FPopupMenuWasActiveOnMouseDown := True;
      end;
    end;

    if not(SsRight in LastShift) then
    begin
      if not SelfDraging and (SelCount = 0) then
      begin
        FDBCanDragW := False;

        if Effect = DROPEFFECT_COPY then
          CopyFiles(Handle, DropInfo, GetCurrentPath, False, False, Self)
        else if Effect = DROPEFFECT_MOVE then
          CopyFiles(Handle, DropInfo, GetCurrentPath, True, False, Self);

      end;
      if SelCount = 1 then
        if ListView1Selected <> nil then
        begin
          FDBCanDragW := False;
          Index := ItemIndexToMenuIndex(ListView1Selected.index);
          if (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) or
            (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) then
          begin
            Str := ExcludeTrailingBackslash(FFilesInfo[index].FileName);

            if Effect = DROPEFFECT_COPY then
              CopyFiles(Handle, DropInfo, Str, False, False, Self)
            else if Effect = DROPEFFECT_MOVE then
              CopyFiles(Handle, DropInfo, Str, True, False, Self);

          end;
        end;
      if SelCount = 1 then
        if ListView1Selected <> nil then
        begin
          Index := ItemIndexToMenuIndex(ListView1Selected.Index);
          if (GetExt(FFilesInfo[index].FileName) = 'EXE') then
          begin
            FDBCanDragW := False;
            Str := ExtractFileDir(FFilesInfo[index].FileName);
            FillChar(Si, SizeOf(Si), 0);
            with Si do
            begin
              Cb := SizeOf(Si);
              DwFlags := STARTF_USESHOWWINDOW;
              WShowWindow := SW_SHOW;
            end;
            Params := '';
            for I := 0 to DropInfo.Count - 1 do
              Params := ' "' + DropInfo[I] + '" ';
            CreateProcess(nil, PWideChar('"' + FFilesInfo[index].FileName + '"' + Params), nil, nil, False,
              CREATE_DEFAULT_ERROR_MODE, nil, PWideChar(Str), Si, P);
          end;
        end;
    end;
  finally
    F(DropInfo);
  end;
  if Length(FListDragItems) > 0 then
    RestoreDragSelectedItems;
  SelfDraging := False;
end;

procedure TExplorerForm.DropFileTargetMainEnter(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  LastShift := ShiftState;
  if not SelfDraging then
    Outdrag := True;
  FDBCanDrag := True;
end;

procedure TExplorerForm.DropFileTargetMainLeave(Sender: TObject);
begin
  FDBCanDrag := False;
  OutDrag := False;
end;

procedure TExplorerForm.SetStringPath(Path: String; ChangeTreeView: Boolean);
var
  S, S1: string;
  I: Integer;
begin
  S := Path;
  if (S = '') or (AnsiLowerCase(S) = AnsiLowerCase(MyComputer)) then
  begin
    PePath.Path := '';
    SetNewPath(S, ChangeTreeView);
    Exit;
  end;
  if (AnsiLowerCase(S) = AnsiLowerCase(L('Network'))) then
  begin
    SetNewPathW(ExplorerPath(L('Network'), EXPLORER_ITEM_NETWORK), False);
    Exit;
  end;
  if Length(S) > 2 then
    if Copy(S, 1, 2) = '\\' then
    begin
      S := ExcludeTrailingBackslash(S);
      Delete(S, 1, 2);
      if Pos('\', S) = 0 then
      begin
        SetNewPathW(ExplorerPath('\\' + S, EXPLORER_ITEM_COMPUTER), ChangeTreeView);
        Exit;
      end else
      begin
        S1 := S;
        for I := 1 to Length(S1) do
          if S1[I] = '\' then
          begin
            Delete(S1, I, 1);
            Break;
          end;
        if Pos('\', S1) = 0 then
        begin
          SetNewPathW(ExplorerPath('\\' + S, EXPLORER_ITEM_SHARE), ChangeTreeView);
          Exit;
        end;
      end
    end;
  S := IncludeTrailingBackslash(Path);
  if DirectoryExistsSafe(S) then
  begin
    SetNewPath(S, ChangeTreeView);
  end else
  begin
    S := Path;
    if FileExistsSafe(S) then
    begin
      if IsGraphicFile(S) then
      begin
        Viewer.ShowImage(Self, S);
        Viewer.Show;
        Viewer.Restore;
      end else
        ShellExecute(Handle, 'open', PChar(S), nil, nil, SW_NORMAL);
    end else if not ChangeTreeView then
      MessageBoxDB(Handle, Format(L('Directory "%s" not found!'), [S]), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
end;

procedure TExplorerForm.HelpTimerTimer(Sender: TObject);
var
  MessageText: string;
begin
  if not Active then
    Exit;

  if HelpNO = 1 then
  begin
    HelpTimer.Enabled := False;
    MessageText := '     ' + L('Find in explorer folder with your photos, select the photo and press "Add item(s)" in menu.$nl$$nl$     Click "More ..." for further assistance.$nl$     Or click on the cross at the top to help no longer displayed.$nl$$nl$', 'Help');
    DoHelpHintCallBackOnCanClose(L('Help'), MessageText, Point(0, 0), ElvMain, Help1NextClick,
      L('Next...'), Help1CloseClick);
  end;
  if HelpNO = 2 then
  begin
    HelpTimer.Enabled := False;
    DoHelpHintCallBackOnCanClose(L('Help'), SecondStepHelp, Point(0, 0), AddLink, Help1NextClick,
      L('Next...'), Help1CloseClick);
  end;
  if HelpNO = 4 then
  begin
    HelpTimer.Enabled := False;

    MessageText := '     ' + L('Now the pictures that do not have icon (+) in the upper left corner are in the collection. They are available using the search and for them advanced context menu is available. Further help is available from the main menu (Help -> Help).$nl$$nl$', 'Help');
    DoHelpHint(L('Help'), MessageText, Point(0, 0), ElvMain);
    HelpNO := 0;
    Settings.WriteBool('HelpSystem', 'CheckRecCount', False);
  end;
end;

procedure TExplorerForm.Help1CloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(Handle, L('Do you really want to refuse help?', 'Help'), L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_INFORMATION);
  if CanClose then
  begin
    HelpNo := 0;
    Settings.WriteBool('HelpSystem', 'CheckRecCount', False);
  end;
end;

procedure TExplorerForm.Help1NextClick(Sender: TObject);
begin
  if HelpNo = 4 then
    Exit;

  HelpNo := HelpNo + 1;

  if HelpNo = 4 then
    HelpTimer.Enabled := True;
end;

procedure TExplorerForm.MyPicturesLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    SetStringPath(Reg.ReadString('Shell Folders', 'My Pictures', ''), False);
  finally
    F(Reg);
  end;
end;

procedure TExplorerForm.MyDocumentsLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    SetStringPath(Reg.ReadString('Shell Folders', 'Personal', ''), False);
  finally
    F(Reg);
  end;
end;

procedure TExplorerForm.MyComputerLinkClick(Sender: TObject);
begin
  SetStringPath('', False);
end;

procedure TExplorerForm.DesktopLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  try
    SetStringPath(Reg.ReadString('Shell Folders', 'Desktop', ''), False);
  finally
    F(Reg);
  end;
end;

procedure TExplorerForm.ImageEditor1Click(Sender: TObject);
begin
  with EditorsManager.NewEditor do
  begin
    CloseOnFailture := False;
    Show;
  end;
end;

procedure TExplorerForm.ImageEditor2Click(Sender: TObject);
var
  Index: Integer;
begin
  if ElvMain.Selection.FocusedItem <> nil then
  begin
    Index := ItemIndexToMenuIndex(ElvMain.Selection.FocusedItem.Index);
    with EditorsManager.NewEditor do
    begin
      Show;
      OpenFileName(FFilesInfo[index].FileName);
    end;
  end;
end;

procedure TExplorerForm.ImageEditorLinkClick(Sender: TObject);
var
  Item: TEasyItem;
begin
  Item := ListView1Selected;
  if Item <> nil then
  begin
    with EditorsManager.NewEditor do
    begin
      Show;
      OpenFileName(FFilesInfo[ItemIndexToMenuIndex(Item.Index)].FileName);
    end;
  end;
end;

procedure TExplorerForm.ImbCloseFilterClick(Sender: TObject);
begin
  HideFilter;
end;

procedure TExplorerForm.ExportImages1Click(Sender: TObject);
var
  Info: TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem);
  try
    BatchProcessingForm.ExportImages(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.PrintLinkClick(Sender: TObject);
var
  I, Index: Integer;
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) or (FFilesInfo[Index].FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
          Files.Add(FFilesInfo[Index].FileName)
      end;
    GetPrintForm(Files);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.MyPicturesLinkContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PmLinkOptions.Tag := Integer(Sender);
  PmLinkOptions.DoPopupEx(P.X, P.Y);
end;

procedure TExplorerForm.Open2Click(Sender: TObject);
begin
  TWebLink(PmLinkOptions.Tag).OnClick(TWebLink(PmLinkOptions.Tag));
end;

procedure TExplorerForm.OpeninNewWindow2Click(Sender: TObject);
var
  Reg: TRegIniFile;
  Link: TWebLink;
  S: string;
  DefLink: Boolean;
  I: Integer;
begin
  Link := TWebLink(PmLinkOptions.Tag);
  DefLink := True;
  for I := 0 to Length(UserLinks) - 1 do
    if Link = UserLinks[I] then
    begin
      DefLink := False;
      Break;
    end;
  if not DefLink then
  begin
    S := FPlaces[Link.Tag].FolderName;
  end else
  begin
    Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
    try
      if Link = MyPicturesLink then
        S := Reg.ReadString('Shell Folders', 'My Pictures', '');
      if Link = MyDocumentsLink then
        S := Reg.ReadString('Shell Folders', 'Personal', '');
      if Link = DesktopLink then
        S := Reg.ReadString('Shell Folders', 'Desktop', '');
      if Link = MyComputerLink then
        S := '';
    finally
      F(Reg);
    end;
  end;
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(S);
    Show;
    SetFocus;
  end;
end;

procedure TExplorerForm.TextFile2Click(Sender: TObject);
var
  S, FileName, FileNameTemplate: String;
  N: Integer;
  F: TextFile;
begin
  FileNameTemplate := L('Text document');
  FileName := FileNameTemplate + '.txt';
  S := IncludeTrailingBackslash(GetCurrentPath);

  N := 1;
  if FileExistsSafe(S + FileName) then
  begin
    repeat
      Inc(N);
    until not FileExistsSafe(S + FileNameTemplate + ' (' + Inttostr(N) + ').txt');
    FileName := S + FileNameTemplate + ' (' + Inttostr(N) + ').txt';
  end else
    FileName := S + FileName;

  NewFileName := AnsiLowerCase(FileName);
  System.Assign(F, FileName);
{$I-}
  System.Rewrite(F);
{$I-}
  if IOResult <> 0 then
  begin
    if not FileExistsSafe(FileName) then
    begin
      MessageBoxDB(Handle, Format(L('Unable to create file "%s"!'), [FileName]), L('Error'), TD_BUTTON_OK,
        TD_ICON_ERROR);
      Exit;
    end else
    begin
      System.Close(F);
    end;
  end
  else
    System.Close(F);
end;

procedure TExplorerForm.GetPhotosClick(Sender: TObject);
var
  Item: TMenuItem;
begin
  Item := (Sender as TMenuItem);
  ImportForm.FromDrive(Char(Item.Tag));
end;

procedure TExplorerForm.GetPhotosFromDrive1Click(Sender: TObject);
var
  I: Integer;
  Icon: TIcon;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := 1 to FExtImagesInImageList do
      DBKernel.ImageList.Delete(IconsCount);
    FExtImagesInImageList := 0;
    for I := Ord('C') to Ord('Z') do
      if (GetDriveType(PChar(Chr(I) + ':\')) = DRIVE_CDROM) then
      begin
        Icon := TIcon.Create;
        try
          Icon.Handle := ExtractAssociatedIconSafe(Chr(I) + ':\');
          DBKernel.ImageList.AddIcon(Icon);
        finally
          F(Icon);
        end;
        Inc(FExtImagesInImageList);
      end;
  finally
    SetErrorMode(OldMode);
  end;
end;

procedure TExplorerForm.CopyWithFolder1Click(Sender: TObject);
var
  I, Index: Integer;
  Files: TStrings;
  UpDir, Dir, NewDir, Temp: string;
  L1, L2: Integer;
begin
  Dir := UnitDBFileDialogs.DBSelectDir(Handle, L('Select directory to copy files'), UseSimpleSelectFolderDialog);
  if Dir <> '' then
  begin
    Files := TStringList.Create;
    try
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          Files.Add(ProcessPath(FFilesInfo[Index].FileName));
        end;
      if Files.Count > 0 then
      begin
        Temp := ExtractFileDir(Files[0]);
        L1 := Length(Temp);
        Temp := ExtractFilePath(Temp);
        L2 := Length(Temp);
        UpDir := Copy(Files[0], L2 + 1, L1 - L2);
        NewDir := IncludeTrailingBackslash(TPath.Combine(Dir, UpDir));
        CreateDirA(NewDir);
        CopyFiles(Handle, Files, NewDir, False, False, Self);
      end;
    finally
      F(Files);
    end;
  end;
end;

procedure TExplorerForm.ReadPlaces;
var
  Reg: TBDRegistry;
  S: TStrings;
  FName, FFolderName, FIcon: string;
  FMyComputer, FMyDocuments, FMyPictures, FOtherFolder: Boolean;
  I: Integer;
  Ico: TIcon;
  WebLink : TWebLink;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.OpenKey(GetRegRootKey + '\Places', True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);
      for I := 0 to Length(UserLinks) - 1 do
        F(UserLinks[I]);
      SetLength(UserLinks, 0);
      SetLength(FPlaces, 0);
      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + '\Places\' + S[I], True);
        FMyComputer := False;
        FMyDocuments := False;
        FMyPictures := False;
        FOtherFolder := False;
        try
          if Reg.ValueExists('Name') then
            FName := Reg.ReadString('Name');
          if Reg.ValueExists('FolderName') then
            FFolderName := Reg.ReadString('FolderName');
          if Reg.ValueExists('Icon') then
            FIcon := Reg.ReadString('Icon');
          if Reg.ValueExists('MyComputer') then
            FMyComputer := Reg.ReadBool('MyComputer');
          if Reg.ValueExists('MyDocuments') then
            FMyDocuments := Reg.ReadBool('MyDocuments');
          if Reg.ValueExists('MyPictures') then
            FMyPictures := Reg.ReadBool('MyPictures');
          if Reg.ValueExists('OtherFolder') then
            FOtherFolder := Reg.ReadBool('OtherFolder');
        except
          on e : Exception do
            EventLog(e.Message);
        end;
        if (FName <> '') and (FFolderName <> '') then
        begin
          SetLength(UserLinks, Length(UserLinks) + 1);
          WebLink := TWebLink.Create(ScrollBox1);
          UserLinks[Length(UserLinks) - 1] := WebLink;
          WebLink.Visible := False;
          WebLink.Parent := ScrollBox1;
          WebLink.Text := FName;
          WebLink.Tag := Length(UserLinks) - 1;
          WebLink.OnClick := UserDefinedPlaceClick;
          WebLink.EnterBould := False;
          WebLink.IconWidth := 16;
          WebLink.IconHeight := 16;
          WebLink.Left := MyPicturesLink.Left;
          WebLink.OnContextPopup := UserDefinedPlaceContextPopup;
          WebLink.LoadImage;
          SetLength(FPlaces, Length(FPlaces) + 1);
          FPlaces[Length(FPlaces) - 1].Name := FName;
          FPlaces[Length(FPlaces) - 1].FolderName := FFolderName;
          FPlaces[Length(FPlaces) - 1].Icon := FIcon;
          FPlaces[Length(FPlaces) - 1].MyComputer := FMyComputer;
          FPlaces[Length(FPlaces) - 1].MyDocuments := FMyDocuments;
          FPlaces[Length(FPlaces) - 1].MyPictures := FMyPictures;
          FPlaces[Length(FPlaces) - 1].OtherFolder := FOtherFolder;
          Ico := TIcon.Create;
          try
            // TODO: optimize code
            Ico.Handle := ExtractSmallIconByPath(FIcon, False);
            UserLinks[Length(UserLinks) - 1].Icon := Ico;
          finally
            F(Ico);
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

procedure TExplorerForm.UserDefinedPlaceClick(Sender: TObject);
begin
  SetStringPath(FPlaces[(Sender as TWebLink).Tag].FolderName, False);
end;

procedure TExplorerForm.UserDefinedPlaceContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  P: TPoint;
begin
  GetCursorPos(P);
  PmLinkOptions.Tag := Integer(Sender);
  PmLinkOptions.DoPopupEx(P.X, P.Y);
end;

procedure TExplorerForm.VleExifDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  S: string;
  DrawRect: TRect;
  SG: TValueListEditor;
begin
  if ARow = 0 then
    Exit;

  SG := (Sender as TValueListEditor);
  S:= SG.Cells[ ACol, ARow ];
  if Length(S) > 0 then
  begin
    DrawRect := Rect;
    DrawText(SG.Canvas.Handle,
              PChar(S), Length(S), DrawRect,
              DT_WORDBREAK or DT_LEFT or DT_NOPREFIX or DT_CALCRECT );

    if (DrawRect.Bottom - DrawRect.top) > SG.RowHeights[ARow] then
      SG.RowHeights[ARow] := (DrawRect.Bottom - DrawRect.Top)
    else
      DrawRect.Right := Rect.Right;

    SG.Canvas.Fillrect( Rect );

    DrawText(SG.Canvas.Handle,
              PChar(S), Length(S), DrawRect,
              DT_WORDBREAK or DT_PLOTTER or DT_NOPREFIX or DT_VCENTER);

  end;
end;

procedure TExplorerForm.Copy4Click(Sender: TObject);
var
  Index: Integer;
  Str: string;
begin
  if (LastListViewSelCount = 0) then
  begin
    FDBCanDragW := False;

    if not(Sender = Move1) then
      CopyFiles(Handle, DragFilesPopup, GetCurrentPath, Sender = Move1, False, Self)
    else
      CopyFiles(Handle, DragFilesPopup, GetCurrentPath, Sender = Move1, False, Self);

  end;
  if LastListViewSelCount = 1 then
    if LastListViewSelected <> nil then
    begin
      FDBCanDragW := False;
      index := ItemIndexToMenuIndex(LastListViewSelected.index);
      if (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) or
        (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) then
      begin
        Str := ExcludeTrailingBackslash(FFilesInfo[index].FileName);

        if not(Sender = Move1) then
          CopyFiles(Handle, DragFilesPopup, Str, Sender = Move1, False, Self)
        else
          CopyFiles(Handle, DragFilesPopup, Str, Sender = Move1, False, Self);

      end;
    end;
end;

procedure TExplorerForm.DoSelectItem;
var
  Index, I, J, X, Y, W, H, FileType: Integer;
  Ico: TIcon;
  S, FileName: string;
  FileSID: TGUID;
  FFolderImagesResult: TFolderImages;
  Dx: Integer;
  FolderImageRect: TRect;
  Fbmp: TBitmap;
  Pic: TPNGImage;
  Bit32: TBitmap;
  TempBitmap: TBitmap;
  IsDirectory, IsSelectionHasGeoLocation: Boolean;
  Info: TExplorerFileInfo;
  PI: TPathItem;
begin
  IsSelectionHasGeoLocation := False;
  ClearGeoLocation;
  if Rdown then
    FDBCanDrag := False;
  if ElvMain <> nil then
  begin
    FSelectedInfo.FileType := GetCurrentPathW.PType;
    if SelCount < 2 then
    begin
      FSelectedInfo.ID := 0;
      FSelectedInfo.Width := 0;
      FSelectedInfo.Height := 0;
      FSelectedInfo.One := True;
      FSelectedInfo.Size := 0;
      FSelectedInfo.FileTypeW := '';
      FSelectedInfo.Size := -1;
      FSelectedInfo.Encrypted := False;
      if SelCount = 1 then
      begin
        Index := ItemIndexToMenuIndex(ListView1Selected.Index);
        if FFilesInfo.Count = 0 then
          Exit;
        if Index > FFilesInfo.Count - 1 then
          Exit;

        Info := FFilesInfo[Index];
        FSelectedInfo.ID := Info.ID;
        FSelectedInfo.FileType := Info.FileType;
        FileName := Info.FileName;
        FSelectedInfo.FileName := Info.FileName;
        FSelectedInfo.Encrypted := Info.Encrypted;
        FSelectedInfo.Date := Info.Date;
        FSelectedInfo.Time := Info.Time;
        FileSID := Info.SID;
        if Info.GeoLocation <> nil then
        begin
          IsSelectionHasGeoLocation := True;
          FSelectedInfo.GeoLocation := Info.GeoLocation.Copy;
        end;

        if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
           (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
           (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) then
          FSelectedInfo.Size := Info.FileSize;
        PmItemPopup.Tag := Index;

        if (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) then
          FSelectedInfo.FileTypeW := Info.Comment;
      end else
      begin
        FileName := ExcludeTrailingPathDelimiter(GetCurrentPath);
        FSelectedInfo.FileName := FileName;
        if GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER then
        begin
          FileName := MyComputer;
          FSelectedInfo.FileName := MyComputer;
          FSelectedInfo.FileTypeW := MyComputer;
          FSelectedInfo.FileType := EXPLORER_ITEM_MYCOMPUTER;
          FileSID := GetGUID;
        end;

        if (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) then
        begin
          PI := PathProviderManager.CreatePathItem(FSelectedInfo.FileName);
          try
            FSelectedInfo.FileTypeW := PI.DisplayName;
          finally
            F(PI);
          end;

          if FSearchMode = EXPLORER_SEARCH_DATABASE then
            FSelectedInfo.FileName := L('Search in collection')
          else if FSearchMode = EXPLORER_SEARCH_FILES then
            FSelectedInfo.FileName := L('Search in directory')
          else
            FSelectedInfo.FileName := L('Search in directory (with EXIF)');
        end;
      end;

      if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) then
        FSelectedInfo.FileTypeW := GetPathDescription(FileName, FSelectedInfo.FileType);
      if (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) then
        FSelectedInfo.FileTypeW := L('Network');
      if (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) then
        FSelectedInfo.FileTypeW := L('Workgroup');
      if (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) then
        FSelectedInfo.FileTypeW := L('Computer');
      if (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) then
        FSelectedInfo.FileTypeW := L('Shared folder');
      if (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON_LIST) then
      begin
        FSelectedInfo.FileName := L('Persons');
        FSelectedInfo.FileTypeW := L('List of persons, search for person photos');
      end;
      if (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) then
      begin
        FSelectedInfo.FileName := L('Groups');
        FSelectedInfo.FileTypeW := L('List of groups, search for group photos');
      end;
      if (FSelectedInfo.FileType = EXPLORER_ITEM_SHELF) then
      begin
        FSelectedInfo.FileName := L('Photo shelf');
        FSelectedInfo.FileTypeW := L('List of shelfed photos and other objects');
      end;
      if (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR) then
      begin
        FSelectedInfo.FileName := L('Calendar');
        FSelectedInfo.FileTypeW := L('Your photos grouped by date');
      end;
      if (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_YEAR) or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_MONTH)
         or (FSelectedInfo.FileType = EXPLORER_ITEM_CALENDAR_DAY) then
      begin
        PI := PathProviderManager.CreatePathItem(FSelectedInfo.FileName);
        try
          if PI is TDateStackYearItem then
            FSelectedInfo.FileName := FormatEx(L('Photos per {0}'), [TDateStackYearItem(PI).Year]);

          if PI is TDateStackMonthItem then
            FSelectedInfo.FileName := FormatEx(L('Photos per {1}, {0}'), [TDateStackMonthItem(PI).Year, MonthToString(TDateStackMonthItem(PI).Month)]);

          if PI is TDateStackDayItem then
            FSelectedInfo.FileName := FormatEx(L('Photos per {2} {1}, {0}'), [TDateStackDayItem(PI).Year, MonthToString(TDateStackDayItem(PI).Date, 'Date'), TDateStackDayItem(PI).Day]);
        finally
          F(PI);
        end;
      end;

      FSelectedInfo._GUID := FileSID;
      if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
      begin
        Info := TExplorerFileInfo.CreateFromFile(FileName);
        try
          Info.FileType := FSelectedInfo.FileType;
          Info.ID := FSelectedInfo.Id;
          TExplorerThumbnailCreator.Create(Info, FileSID, Self, True);
        finally
          F(Info);
        end;
        if HelpNo = 2 then
          HelpTimer.Enabled := True;
      end;

      ReallignToolInfo;
      ReallignInfo;
      TempBitmap := TBitmap.Create;
      try
        ImPreview.Picture.Graphic := TempBitmap;
      finally
        F(TempBitmap);
      end;

      try
        with ImPreview.Picture.Bitmap do
        begin
          Width := ThSizeExplorerPreview;
          Height := ThSizeExplorerPreview;
          Canvas.Pen.Color := Theme.PanelColor;
          Canvas.Brush.Color := Theme.PanelColor;
          if (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) then
          begin
            Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);
            FFolderImagesResult.Directory := '';
            for I := 1 to 4 do
              FFolderImagesResult.Images[I] := nil;
            FFolderImagesResult := ExplorerFolders.GetFolderImages(FileName, 40, 40);
            try
              if FFolderImagesResult.Directory = '' then
              begin
                S := ExcludeTrailingBackslash(FileName);
                if FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE then
                  FileName := IncludeTrailingBackslash(FileName);

                IsDirectory := (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER);
                if IsDirectory then
                  FindIcon(HInstance, 'DIRECTORY', 48, 32, Ico)
                else if (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
                        (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
                begin
                  Ico := TIcon.Create;
                  Ico.Handle := ExtractDefaultAssociatedIcon(ExtractFileExt(FileName), 48);
                end else
                  FindIcon(HInstance, 'SIMPLEFILE', 48, 32, Ico);

                try
                  Canvas.Draw(ThSizeExplorerPreview div 2 - Ico.Width div 2,
                    ThSizeExplorerPreview div 2 - Ico.Height div 2, Ico);
                finally
                  F(Ico);
                end;
                FSelectedInfo.PreviewID := GetGUID;

                Info := TExplorerFileInfo.CreateFromFile(FileName);
                try
                  Info.FileType := FSelectedInfo.FileType;
                  Info.ID := FSelectedInfo.Id;
                  if (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON) or
                     (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP) or
                     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE) or
                     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
                     (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
                     IsVideoFile(FileName) then
                  begin
                    TExplorerThumbnailCreator.Create(Info, FSelectedInfo._GUID, Self, True);
                  end else
                  begin
                    TExplorerThumbnailCreator.Create(Info, FSelectedInfo.PreviewID, Self, False);
                  end;
                finally
                  F(Info);
                end;
              end else
              begin
                Pic := GetFolderPicture;

                TempBitmap := TBitmap.Create;
                try
                  Bit32 := TBitmap.Create;
                  try
                    LoadPNGImage32bit(Pic, Bit32, Theme.PanelColor);
                    F(Pic);
                    StretchCoolW(0, 0, 100, 100, Rect(0, 0, Bit32.Width, Bit32.Height), Bit32, TempBitmap);
                  finally
                    F(Bit32);
                  end;

                  Canvas.Draw(0, 0, TempBitmap);
                finally
                  F(TempBitmap);
                end;

                Dx := 5;
                for I := 1 to 2 do
                  for J := 1 to 2 do
                  begin
                    Index := (I - 1) * 2 + J;
                    X := (J - 1) * 42 + 5 + Dx;
                    Y := (I - 1) * 42 + 8 + Dx;
                    if FFolderImagesResult.Images[Index] = nil then
                      Break;
                    Fbmp := FFolderImagesResult.Images[Index];
                    W := Fbmp.Width;
                    H := Fbmp.Height;
                    ProportionalSize(40, 40, W, H);
                    FolderImageRect := Rect(X + 40 div 2 - W div 2, Y + 40 div 2 - H div 2, X + 40 div 2 + W div 2,
                      Y + 40 div 2 + H div 2);

                    if FBMP.PixelFormat = pf32Bit then
                      StretchCoolW32(FolderImageRect.Left, FolderImageRect.Top, FolderImageRect.Right - FolderImageRect.Left, FolderImageRect.Bottom - FolderImageRect.Top, Rect(0,0, Fbmp.Width, Fbmp.Height), Fbmp, ImPreview.Picture.Bitmap)
                    else
                      StretchCoolW24To32(FolderImageRect.Left, FolderImageRect.Top, FolderImageRect.Right - FolderImageRect.Left, FolderImageRect.Bottom - FolderImageRect.Top, Rect(0,0, Fbmp.Width, Fbmp.Height), Fbmp, ImPreview.Picture.Bitmap);

                  end;
              end;
            finally
              for I := 1 to 4 do
                F(FFolderImagesResult.Images[I]);
            end;
          end;
          if (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType = EXPLORER_ITEM_PERSON_LIST) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_GROUP_LIST) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_STORAGE) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FSelectedInfo.FileType = EXPLORER_ITEM_DEVICE_FILE) or
            (FSelectedInfo.FileType in [EXPLORER_ITEM_SHELF, EXPLORER_ITEM_CALENDAR, EXPLORER_ITEM_CALENDAR_YEAR, EXPLORER_ITEM_CALENDAR_MONTH,
              EXPLORER_ITEM_CALENDAR_DAY]) then
          begin
            with ImPreview.Picture.Bitmap do
            begin
              Width := ThSizeExplorerPreview;
              Height := ThSizeExplorerPreview;
              Canvas.Pen.Color := Theme.PanelColor;
              Canvas.Brush.Color := Theme.PanelColor;
              Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);

              Ico := nil;
              case FSelectedInfo.FileType of
                EXPLORER_ITEM_NETWORK:
                  FindIcon(HInstance, 'NETWORK', 48, 32, Ico);
                EXPLORER_ITEM_WORKGROUP:
                  FindIcon(HInstance, 'WORKGROUP', 48, 32, Ico);
                EXPLORER_ITEM_COMPUTER:
                  FindIcon(HInstance, 'COMPUTER', 48, 32, Ico);
                EXPLORER_ITEM_SHARE:
                  FindIcon(HInstance, 'SHARE', 48, 32, Ico);
                EXPLORER_ITEM_MYCOMPUTER:
                  FindIcon(HInstance, 'COMPUTER', 48, 32, Ico);
                EXPLORER_ITEM_PERSON_LIST:
                  FindIcon(HInstance, 'PERSONS', 48, 32, Ico);
                EXPLORER_ITEM_GROUP_LIST:
                  FindIcon(HInstance, 'GROUPS', 48, 32, Ico);
                EXPLORER_ITEM_DEVICE:
                  FindIcon(HInstance, 'CAMERA', 48, 32, Ico);
                EXPLORER_ITEM_DEVICE_STORAGE:
                  FindIcon(HInstance, 'STORAGE', 48, 32, Ico);
                EXPLORER_ITEM_DEVICE_DIRECTORY:
                  FindIcon(HInstance, 'DIRECTORY', 48, 32, Ico);
                EXPLORER_ITEM_SHELF:
                  FindIcon(HInstance, 'SHELF', 48, 32, Ico);
                EXPLORER_ITEM_CALENDAR:
                  FindIcon(HInstance, 'CALENDAR', 48, 32, Ico);
                EXPLORER_ITEM_CALENDAR_YEAR:
                  FindIcon(HInstance, 'YEARICON', 48, 32, Ico);
                EXPLORER_ITEM_CALENDAR_MONTH:
                  FindIcon(HInstance, 'MONTHICON', 48, 32, Ico);
                EXPLORER_ITEM_CALENDAR_DAY:
                  FindIcon(HInstance, 'DAYICON', 48, 32, Ico);
                EXPLORER_ITEM_DEVICE_FILE:
                begin
                  Ico := TIcon.Create;
                  Ico.Handle := ExtractDefaultAssociatedIcon(ExtractFileExt(FileName), 48);
                end;
              end;

              try
                Canvas.Draw(ThSizeExplorerPreview div 2 - Ico.Width div 2,
                  ThSizeExplorerPreview div 2 - Ico.Height div 2, Ico);
              finally
                F(Ico);
              end;
            end;
          end;

          if (FSelectedInfo.FileType = EXPLORER_ITEM_SEARCH) then
          begin

            with ImPreview.Picture.Bitmap do
            begin
              Width := ThSizeExplorerPreview;
              Height := ThSizeExplorerPreview;
              Canvas.Pen.Color := Theme.PanelColor;
              Canvas.Brush.Color := Theme.PanelColor;
              Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);

              if FSearchMode = EXPLORER_SEARCH_DATABASE then
                Pic := TResourceUtils.LoadGraphicFromRES<TPngImage>('SEARCH_DATABASE')
              else if FSearchMode = EXPLORER_SEARCH_FILES then
                Pic := TResourceUtils.LoadGraphicFromRES<TPngImage>('SEARCH_FILES')
              else
                Pic := TResourceUtils.LoadGraphicFromRES<TPngImage>('SEARCH_IMAGES');
              try
                Canvas.Draw(ThSizeExplorerPreview div 2 - Pic.Width div 2,
                  ThSizeExplorerPreview div 2 - Pic.Height div 2, Pic);
              finally
                F(Pic);
              end;
            end;
          end;
        end;
      except
        on E: Exception do
          EventLog(':TExplorerForm::DoSelectItem() throw exception: ' + E.message);
      end;

    end else
    begin
      Bit32 := TBitmap.Create;
      try
        CreateMultiselectImage(ElvMain, Bit32, FBitmapImageList, ElvMain.Selection.GradientColorBottom, ElvMain.Selection.GradientColorTop,
          ElvMain.Selection.Color, ElvMain.Font, ThSizeExplorerPreview + 3, ThSizeExplorerPreview + 3);
        ImPreview.Picture.Graphic := Bit32;
      finally
        F(Bit32);
      end;

      FSelectedInfo._GUID := GetGUID;

      FSelectedInfo.Size := 0;

      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);

          Info := FFilesInfo[Index];
          FileType := Info.FileType;

          if FSelectedInfo.FileType <> EXPLORER_ITEM_MYCOMPUTER then
            FSelectedInfo.FileType := FileType;

          if Info.GeoLocation <> nil then
            IsSelectionHasGeoLocation := True;

          if (FileType = EXPLORER_ITEM_IMAGE) or
             (FileType = EXPLORER_ITEM_FILE) or
             (FileType = EXPLORER_ITEM_EXEFILE) or
             (FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
             (FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
             (FileType = EXPLORER_ITEM_DEVICE_FILE) then
            FSelectedInfo.Size := FSelectedInfo.Size + Info.FileSize;
        end;

      FSelectedInfo.FileName :=  Format(L('%d objects'), [SelCount]);
      FSelectedInfo.FileTypeW := '';
      FSelectedInfo.Id := 0;
      FSelectedInfo.Width := 0;
      FSelectedInfo.Height := 0;
      FSelectedInfo.One := True;
      FSelectedInfo.Rating := 0;
      TypeLabel.Caption := '';
      ReallignToolInfo;
      ReallignInfo;
    end;
  end;

  InitInfoEditor(True);

  if not (FSelectedInfo.FileType in [EXPLORER_ITEM_IMAGE, EXPLORER_ITEM_DEVICE_IMAGE]) or (SelCount <> 1) then
    FLeftTabs := FLeftTabs - [eltsEXIF]
  else
  begin
    FLeftTabs := FLeftTabs + [eltsEXIF];
    ShowLastActiveLeftTab(eltsEXIF);
  end;

  if not (FActiveLeftTab in FLeftTabs) then
    ShowLastActiveLeftTab(eltsAny);

  ApplyLeftTabs;

  if FActiveRightTab = ertsPreview then
  begin
    if TsMediaPreview.Visible then
      CreatePreview;

    if (FImageViewer <> nil) and not SelfDraging then
    begin
      if (SelCount = 0) or not (FSelectedInfo.FileType in [EXPLORER_ITEM_IMAGE, EXPLORER_ITEM_DEVICE_IMAGE]) then
      begin
        BeginScreenUpdate(TsMediaPreview.Handle);
        try
          if SelCount = 1 then
            FImageViewer.SetText(FormatEx(L('Preview for object "{0}" is unavailable'), [ExtractFileName(FSelectedInfo.FileName)]))
          else
            FImageViewer.SetText(L('Select a file to preview'));
          TbPreviewRating.Visible := False;
          TbPreviewRatingSeparator.Visible := False;
          OnPersonsFoundOnPreview(Self, '', nil);
        finally
          EndScreenUpdate(TsMediaPreview.Handle, False);
        end;
      end else
      begin
        if (ElvMain.Selection.FocusedItem <> nil) and (ElvMain.Selection.FocusedItem.Selected) then
          FImageViewer.LoadFiles(GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem))
        else
          FImageViewer.LoadFiles(GetCurrentPopUpMenuInfo(ListView1Selected));
      end;
    end;
  end;

  if (TsGeoLocation.Visible) then
  begin
    if (FSelectedInfo.GeoLocation <> nil) then
      WlGeoLocationClick(Self)
    else
      SaveCurrentImageInfoToMap;

    if (FSelectedInfo.FileType <> EXPLORER_ITEM_IMAGE) or (FSelectedInfo.GeoLocation = nil) then
      ClearMap;

    if IsSelectionHasGeoLocation then
      WlDeleteLocation.Enabled := True;
  end;
end;

procedure TExplorerForm.UpdateMenuItems(Menu: TPopupActionBar; PathList: TArExplorerPath; PathIcons: TPathItemCollection);
var
  I: Integer;
  MI: TMenuItem;
  Ico: TIcon;
  Image: TPathImage;
begin
  FHistoryPathList := Copy(PathList);

  for I := 0 to PathIcons.Count - 1 do
  begin
    Image := PathIcons[I].Image;
    if Image = nil then
    begin
      Ico := nil;
      try
        FindIcon(HInstance, 'SIMPLEFILE', 48, 32, Ico);
        Image := TPathImage.Create(CopyIcon(Ico.Handle));
        try
          Image.AddToImageList(ImPathDropDownMenu);
        finally
          F(Image);
        end;
      finally
        F(Ico);
      end;
    end else
      Image.AddToImageList(ImPathDropDownMenu);
    MI := TMenuItem.Create(Menu);
    MI.Caption := PathIcons[I].DisplayName;
    MI.OnClick := SetNewHistoryPath;
    MI.ImageIndex := ImPathDropDownMenu.Count - 1;
    MI.Tag := I;
    Menu.Items.Add(MI);
  end;
  if Menu.Items.Count = 1 then
    //close popup menu
    Menu.PopupMenu.CloseMenu
  else
  begin
    Menu.Items.Delete(0);
    Menu.PopupMenu.DisableAlign;
    try
      Menu.PopupMenu.LoadMenu(Menu.PopupMenu.ActionClient.Items, Menu.Items);
    finally
      Menu.PopupMenu.EnableAlign;
    end;
    Menu.PopupMenu.ActionClient.Items.Delete(0);
  end;

  Menu.Tag := 1;
end;

procedure TExplorerForm.SetNewHistoryPath(Sender: TObject);
var
  N: Integer;
  Path: TExplorerPath;
begin
  N := (Sender as TMenuItem).Tag;
  Path := FHistoryPathList[N];

  FChangeHistoryOnChPath := False;
  FHistory.Position := Path.Tag;
  HistoryChanged(Sender);
  SetNewPathW(Path, False);
end;

procedure TExplorerForm.UpdatePreviewIcon(Ico: HIcon; SID: TGUID);
var
  Icon: TIcon;
begin
  if not IsEqualGUID(SID, FSelectedInfo.PreviewID) then
    Exit;

  with ImPreview.Picture.Bitmap do
  begin
    Width := ThSizeExplorerPreview;
    Height := ThSizeExplorerPreview;
    Canvas.Pen.Color := Theme.PanelColor;
    Canvas.Brush.Color := Theme.PanelColor;
    Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);
    Icon := TIcon.Create;
    try
      Icon.Handle := Ico;
      Canvas.Draw(ThSizeExplorerPreview div 2 - Icon.Width div 2,
        ThSizeExplorerPreview div 2 - Icon.Height div 2, Icon);
    finally
      F(Icon);
    end;
  end;
end;

procedure TExplorerForm.SelectTimerTimer(Sender: TObject);
begin
  SelectTimer.Enabled := False;
  DoSelectItem;
end;

procedure TExplorerForm.SetNewFileNameGUID(FileGUID: TGUID);
begin
  NewFileNameGUID := FileGUID;
end;

procedure TExplorerForm.SbCloseRightPanelClick(Sender: TObject);
begin
  HideRightPanel;
end;

procedure TExplorerForm.SbCloseHelpClick(Sender: TObject);
begin
  PnInfo.Hide;
end;

procedure TExplorerForm.SbDoSearchClick(Sender: TObject);
var
  I: Integer;
  S, Path: string;
  IsExtendedPanelSearch,
  IsExtendedDBSearch: Boolean;
  Groups: TGroups;
begin
  IsExtendedPanelSearch := (Sender = EdExtendedSearchText) or (Sender = SbExtendedSearchStart) or (Sender = BtnSearch);
  IsExtendedDBSearch := IsExtendedPanelSearch and (FSearchMode = EXPLORER_SEARCH_DATABASE);

  S := AnsiLowerCase(IIF(IsExtendedPanelSearch, EdExtendedSearchText.Text, WedSearch.Text));
  try
    if not IsExtendedDBSearch then
    begin
      if (FSearchMode = EXPLORER_SEARCH_FILES) or (FSearchMode = EXPLORER_SEARCH_IMAGES) then
      begin
        if (FCurrentTypePath = EXPLORER_ITEM_PERSON_LIST) or (FCurrentTypePath = EXPLORER_ITEM_PERSON)
          or (FCurrentTypePath = EXPLORER_ITEM_GROUP_LIST) or (FCurrentTypePath = EXPLORER_ITEM_GROUP)
          or (FCurrentTypePath = EXPLORER_ITEM_NETWORK) or (FCurrentTypePath = EXPLORER_ITEM_WORKGROUP)
          or (FCurrentTypePath = EXPLORER_ITEM_SHELF) then
        begin
          ShowFilter(False);
          WedFilter.Text := WedSearch.Text;
          Exit;
        end;
      end;

      Path := ExtractPathExPath(FCurrentPath);

      if S = '' then
      begin
        SetNewPath(Path, True);
        Exit;
      end;

      if IsShortDrive(Path) then
        Path := Path + '\';

      if FSearchMode = EXPLORER_SEARCH_FILES then
      begin
        SetNewPath(Path + cFilesSearchPath + S, False);

        //statistics
        ProgramStatistics.SearchFilesUsed;
      end else if FSearchMode = EXPLORER_SEARCH_IMAGES then
      begin
        SetNewPath(Path + cImagesSearchPath + S, False);

        //statistics
        ProgramStatistics.SearchImagesUsed;
      end else
      begin
        SetNewPath(cDBSearchPath + S, False);

        //statistics
        ProgramStatistics.SearchDatabaseUsed;
      end;

    end else //if IsExtendedSearch then
    begin
      FExtendedSearchParams.Text := EdExtendedSearchText.Text;

      FExtendedSearchParams.Groups.Clear;
      Groups := EncodeGroups(WllExtendedSearchGroups.TagEx);
      for I := 0 to Length(Groups) - 1 do
        FExtendedSearchParams.Groups.Add(Groups[I].GroupName);

      FExtendedSearchParams.Persons.Clear;
      for I := 0 to FExtendedSearchPersons.Count - 1 do
        FExtendedSearchParams.Persons.Add(FExtendedSearchPersons[I].Name);

      SetNewPath(cDBSearchPath + FExtendedSearchParams.ToString, False);

      //statistics
      ProgramStatistics.SearchDatabaseUsed;

    end;//if IsExtendedSearch then
  finally
    ElvMain.SetFocus;
  end;
end;

procedure TExplorerForm.WedSearchEnter(Sender: TObject);
begin
  ExtendedSearchShow;
end;

procedure TExplorerForm.WedSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
  begin
    Key := #0;
    SbDoSearchClick(Sender);
  end;
end;

procedure TExplorerForm.WlClearClick(Sender: TObject);
var
  EventInfo: TEventValues;
begin
  ClearList;
  PhotoShelf.Clear;
  EventInfo.Image := nil;
  DBKernel.DoIDEvent(Self, 0, [EventID_ShelfChanged], EventInfo);

  SpeedButton1Click(Sender);
end;

procedure TExplorerForm.WlCreateObjectClick(Sender: TObject);
begin
  GroupCreateForm.CreateGroup;
end;

procedure TExplorerForm.WlCropClick(Sender: TObject);
var
  Item: TEasyItem;
begin
  Item := ListView1Selected;
  if Item <> nil then
  begin
    with EditorsManager.NewEditor do
    begin
      Show;
      OpenFileName(FFilesInfo[ItemIndexToMenuIndex(Item.Index)].FileName);
      CropLinkClick(nil);
    end;
  end;
end;

procedure TExplorerForm.WlImportPicturesClick(Sender: TObject);
var
  Item: TEasyItem;
  Path: string;
begin
  Item := ListView1Selected;
  if Item <> nil then
  begin
    Path := FFilesInfo[ItemIndexToMenuIndex(Item.Index)].FileName;
    ImportForm.FromFolder(Path);
  end else
   ImportForm.FromFolder(GetCurrentPath);
end;

procedure TExplorerForm.WlLearnMoreLinkClick(Sender: TObject);
begin
  if WlLearnMoreLink.HelpKeyword = '' then
  begin
    SbCloseHelpClick(Sender);
    Exit;
  end;

  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(ActionHelpPageURL) + WlLearnMoreLink.HelpKeyword), nil, nil, SW_NORMAL);
end;

procedure TExplorerForm.WMDeviceChange(var Msg: TMessage);
var
  Drive: string;
  I, Index: Integer;

  function GetDrive(pDBVol: PDevBroadcastVolume): string;
  var
    I: Byte;
    Maske: DWORD;
  begin
    Maske := pDBVol^.dbcv_unitmask;
    for I := 0 to 25 do
    begin
      if (Maske and 1) = 1 then
        Result := Char(I + Ord('A')) + ':';
      Maske := Maske shr 1;
    end;
  end;

begin
  if FCurrentTypePath = EXPLORER_ITEM_MYCOMPUTER then
  begin
    case Msg.Wparam of
      DBT_DeviceArrival:
        if PDevBroadcastHdr(Msg.lParam)^.dbcd_devicetype = DBT_DevTyp_Volume then
        begin
          // Drive := GetDrive(PDevBroadcastVolume(Msg.lParam));
          ElvMain.Selection.ClearAll;
          RefreshLinkClick(RefreshLink);
        end;
      DBT_DeviceRemoveComplete:
        if PDevBroadcastHdr(Msg.lParam)^.dbcd_devicetype = DBT_DevTyp_Volume then
        begin
          Drive := AnsiLowerCase(GetDrive(PDevBroadcastVolume(Msg.lParam)));
          for I := 0 to ElvMain.Items.Count - 1 do
          begin
            Index := ItemIndexToMenuIndex(I);
            if AnsiLowerCase(ExcludeTrailingPathDelimiter(FFilesInfo[Index].FileName)) = Drive then
            begin
              DeleteItemWithIndex(Index);
              Break;
            end;
          end;
        end;
      DBT_DEVNODES_CHANGED:
        begin
          // just refresh list
          ElvMain.Selection.ClearAll;
          RefreshLinkClick(RefreshLink);
        end;
    end;
  end;
end;

procedure TExplorerForm.WMChangeCBChain(var Msg: TWMChangeCBChain);
begin
  if FNextClipboardViewer = Msg.Remove then
    FNextClipboardViewer := Msg.Next
  else if FNextClipboardViewer <> 0 then
    SendMessage(FNextClipboardViewer, WM_CHANGECBCHAIN, Msg.Remove, Msg.Next)
end;

procedure TExplorerForm.WMClipboardUpdate(var Msg: TMessage);
begin
  FCanPasteFromClipboard := CanCopyFromClipboard;
  VerifyPaste(Self);
end;

procedure TExplorerForm.WMDrawClipboard(var Msg: TMessage);
begin
  // pass the message on to the next window
  if FNextClipboardViewer <> 0 then
    SendMessage(FNextClipboardViewer, WM_DRAWCLIPBOARD, Msg.Wparam, Msg.lParam);

  if not (fsShowing in FormState) then
  begin
    FCanPasteFromClipboard := CanCopyFromClipboard;
    VerifyPaste(Self);
  end;
end;

function TExplorerForm.GetFilterText: string;
var
  Filter: string;
begin
  if PnFilter.Visible then
    Filter := WedFilter.Text
  else
    Filter := '*';

  if Pos('*', Filter) = 0 then
    Filter := '*' + Filter + '*';

  if not CbFilterMatchCase.Checked then
    Filter := AnsiLowerCase(Filter);

  Result := Filter;
end;

function TExplorerForm.MakeItemVisibleByFilter(Item: TEasyItem; Filter: string): Boolean;
var
  Index, J: Integer;
  Info: TExplorerFileInfo;
  IsVisible, IsFilter: Boolean;
  ItemKey: string;
  Groups: TGroups;
begin
  Result := False;

  IsFilter := PnFilter.Visible;

  if IsFilter and (Filter = '') then
    Filter := GetFilterText;

  if IsFilter then
  begin
    Index := ItemIndexToMenuIndex(Item.Index);
    Info := FFilesInfo[Index];
    ItemKey := Info.Comment + ' ' + Info.KeyWords;
    if Info.Groups <> '' then
    begin
      Groups := EncodeGroups(Info.Groups);
      for J := 0 to Length(Groups) - 1 do
        ItemKey := ItemKey + Groups[J].GroupName + ' ';
    end;
    if not CbFilterMatchCase.Checked then
      ItemKey := AnsiLowerCase(ItemKey);
  end;

  if IsFilter then
    IsVisible := IsFilter and (IsMatchMask(AnsiLowerCase(Item.Caption), Filter) or IsMatchMask(ItemKey, Filter))
  else
    IsVisible := True;

  if IsVisible then
    Result := True;

  Item.Visible := IsVisible;
end;

procedure TExplorerForm.WedFilterChange(Sender: TObject);
var
  Filter: string;
  I: Integer;
  ResultsFound: Boolean;
begin
  Filter := GetFilterText;

  ResultsFound := False;

  ElvMain.BeginUpdate;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if MakeItemVisibleByFilter(ElvMain.Items[I], Filter) then
        ResultsFound := True;
  finally
    ElvMain.EndUpdate(True);
  end;

  if IsExplorerTreeViewVisible then
    TreeView.SetFilter(Filter, CbFilterMatchCase.Checked);

  LbFilterInfo.Visible := not ResultsFound;
  ImFilterWarning.Visible := not ResultsFound;

  PnResetFilter.Visible := (WedFilter.Text <> '') and PnFilter.Visible;
end;

procedure TExplorerForm.WedFilterKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
  begin
    HideFilter;
    Key := #0;
  end;
end;

procedure TExplorerForm.AddUpdateID(FileName: string);
begin
  RefreshIDList.Add(AnsiLowerCase(FileName));
end;

procedure TExplorerForm.RemoveUpdateID(FileName: string; CID: TGUID);
var
  Index: Integer;
begin
  Index := RefreshIDList.IndexOf(AnsiLowerCase(FileName));
  if Index <> -1 then
    RefreshIDList.Delete(Index);
end;

function TExplorerForm.UpdatingNow(FileName: string): Boolean;
begin
  Result := RefreshIDList.IndexOf(FileName) > -1;
end;

procedure TExplorerForm.ScriptExecuted(Sender: TObject);
begin
  LoadItemVariables(aScript,Sender as TMenuItemW);
  if Trim((Sender as TMenuItemW).Script) <> '' then
    ExecuteScript(Sender as TMenuItemW, AScript, '', FExtImagesInImageList, DBkernel.ImageList, ScriptExecuted);
end;

function TExplorerForm.GetVisibleItems: TStrings;
var
  I, Index: Integer;
  R: TRect;
  T: array of Boolean;
  B: Boolean;
  TempResult: TStrings;
  RectArray: TEasyRectArrayObject;
  Rv: TRect;
  U, L, M, N, P: Integer;
  FoundVisible: Boolean;

  function IsItemVisible(Index: Integer): Boolean;
  begin
    ElvMain.Items[Index].ItemRectArray(ElvMain.Header.FirstColumn, ElvMain.Canvas, RectArray);

    Result :=  RectInRect(R, RectArray.BoundsRect);
  end;

begin
  Result := TStringList.Create;
  B := False;
  rv :=  ElvMain.Scrollbars.ViewableViewportRect;
  R := Rect(ElvMain.ClientRect.Left + rv.Left, ElvMain.ClientRect.Top + rv.Top, ElvMain.ClientRect.Right + rv.Left, ElvMain.ClientRect.Bottom + rv.Top);

  //binary search - gets fist visible element
  N := ElvMain.Items.Count;
  L := -1;
  U := N;
  while (L + 1 <> U) do
  begin
    // invariant: x[l] < t && x[u] >= t && l < u
    M := (L + U) div 2;

    ElvMain.Items[M].ItemRectArray(ElvMain.Header.FirstColumn, ElvMain.Canvas, RectArray);
    if RectArray.BoundsRect.Bottom < R.Top then
      L := M
    else
      U := M;
  end;

  P := U;
  if (P >= N) or not IsItemVisible(P) then
    P := 0;

  FoundVisible := False;
  for I := P to ElvMain.Items.Count - 1 do
  begin
    if IsItemVisible(I) then
    begin
      FoundVisible := True;
      Index := ItemIndexToMenuIndex(I);
      Result.Add(GUIDToString(FFilesInfo[Index].SID));
      SetLength(T, Length(T) + 1);
      T[Length(T) - 1] := FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER;
      if not B then
      begin
        if FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER then
          B := True;
      end;
    end else if FoundVisible then
      Break;
  end;

  // order by TYPE
  if B then
  begin
    TempResult := TStringList.Create;
    try
      for I := 0 to Result.Count - 1 do
        if not T[I] then
          TempResult.Add(Result[I]);

      for I := 0 to Result.Count - 1 do
        if T[I] then
          TempResult.Add(Result[I]);

      Result.Assign(TempResult);
    finally
      F(TempResult);
    end;
  end;
end;

function TExplorerForm.GetW7TaskBar: ITaskbarList3;
begin
  if FW7TaskBar = nil then
    FW7TaskBar := CreateTaskBarInstance;

  Result := FW7TaskBar;
end;

function TExplorerForm.CanUp: Boolean;
begin
  Result := AnsiLowerCase(GetCurrentPath) <> AnsiLowerCase(MyComputer);
  if GetCurrentPath = '' then
    Result := False;
end;

function TExplorerForm.SelCount: Integer;
begin
  Result := ElvMain.Selection.Count;
end;

function TExplorerForm.SelectedIndex: Integer;
begin
  if ListView1Selected = nil then
    Result := -1
  else
    Result := ListView1Selected.Index;
end;

function TExplorerForm.GetSelectedType: Integer;
begin
  if ListView1Selected = nil then
    Result := -1
  else
    Result := FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.Index)].FileType;
end;

function CanCopyFileByType(FileType: Integer): Boolean;
begin
  Result := ((FileType = EXPLORER_ITEM_FILE) or (FileType = EXPLORER_ITEM_IMAGE) or
   (FileType = EXPLORER_ITEM_FOLDER) or (FileType = EXPLORER_ITEM_SHARE) or (FileType = EXPLORER_ITEM_EXEFILE) or
   (FileType = EXPLORER_ITEM_DEVICE_DIRECTORY) or (FileType = EXPLORER_ITEM_DEVICE_IMAGE) or
   (FileType = EXPLORER_ITEM_DEVICE_IMAGE) or (FileType = EXPLORER_ITEM_DEVICE_VIDEO) or
   (FileType = EXPLORER_ITEM_DEVICE_FILE));
end;

function TExplorerForm.CanCopySelection: Boolean;
var
  I, Index: Integer;
begin
  Result := True;
  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      if not CanCopyFileByType(FFilesInfo[Index].FileType) then
      begin
        Result := False;
        Break;
      end;
    end;
  if ElvMain.Items.Count = 0 then
    if not CanCopyFileByType(GetCurrentPathW.PType) then
      Result := False;
end;

function TExplorerForm.GetPath: string;
begin
  Result := GetCurrentPath;
end;

function CanPasteFileInByType(FileType : integer) : boolean;
begin
  Result := ((FileType=EXPLORER_ITEM_DRIVE) or (FileType=EXPLORER_ITEM_FOLDER) or (FileType=EXPLORER_ITEM_SHARE));
end;

function TExplorerForm.GetSecondStepHelp: string;
begin
  Result := '     ' + L('Click the "Add item (s)" to add photos to the database. After that the pictures you can add information.$nl$$nl$     Click "More ..." for further assistance.$nl$     Or click on the cross at the top to help no longer displayed.$nl$$nl$', 'Help');
end;

function TExplorerForm.GetSelectedFiles: TArrayOfString;
var
  I, Index: Integer;
begin
  SetLength(Result, 0);

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      if CanCopyFileByType(FFilesInfo[index].FileType) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := FFilesInfo[index].FileName;
      end;
    end;
end;

function TExplorerForm.CanPasteInSelection: Boolean;
var
  Index: Integer;
begin
  Result := False;
  if SelCount > 1 then
    Exit;
  if SelCount = 1 then
  begin
    index := ItemIndexToMenuIndex(ListView1Selected.Tag);
    if CanPasteFileInByType(FFilesInfo[index].FileType) then
      Result := True;

  end else
    Result := CanPasteFileInByType(GetCurrentPathW.PType);
end;

procedure TExplorerForm.CloseTimerTimer(Sender: TObject);
begin
  CloseTimer.Enabled := False;
  Close;
end;

procedure TExplorerForm.CloseWindow(Sender: TObject);
begin
  CloseTimer.Enabled := True;
end;

function TExplorerForm.ShowPrivate: Boolean;
begin
  Result := ExplorerManager.ShowPrivate;
end;

function TExplorerForm.GetPathByIndex(Index: Integer): string;
begin
  if ListView1Selected = nil then
    Result := ''
  else
    Result := FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.Index)].FileName;
end;

procedure TExplorerForm.FileName1Click(Sender: TObject);
var
  I, L, Index, N: Integer;
  aType: Byte;

type
  Item = TExplorerFileInfo; { This defines the objects being sorted. }
  List = array of Item; { This is an array of objects to be sorted. }

  SortList = array of TEasyItem;

  TSortItem = record
    ID: Integer;
    ValueInt: Integer;
    ValueStr: string;
    ValueDouble: Double;
  end;

  aListItem = record
    Caption: string;
    Indent: Integer;
    Data: Pointer;
    ImageIndex: Integer;
  end;

  aListItems = array of aListItem;

  TSortItems = array of TSortItem;

var
  SIs: TSortItems;
  LI: aListItems;

  function L_Less_Than_R(L, R: TSortItem; aType: Byte): Boolean;
  begin
    Result := True;
    if aType = 1 then
    begin
      if L.ValueInt = R.ValueInt then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := L.ValueInt < R.ValueInt;
      Exit;
    end;
    if aType = 0 then
      Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0;
    if aType = 5 then
    begin
      if (L.ValueInt = EXPLORER_ITEM_FOLDER) and (R.ValueInt <> EXPLORER_ITEM_FOLDER) then
      begin
        Result := True;
        Exit;
      end;
      if (L.ValueInt <> EXPLORER_ITEM_FOLDER) and (R.ValueInt = EXPLORER_ITEM_FOLDER) then
      begin
        Result := False;
        Exit;
      end;
      Result := AnsiCompareTextWithNum(L.ValueStr, R.ValueStr) < 0;
    end;
    if aType = 2 then
    begin
      if L.ValueDouble = R.ValueDouble then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := L.ValueDouble < R.ValueDouble;
      Exit;
    end;
    if aType = 3 then
    begin
      N := AnsiCompareText(ExtractFileExt(L.ValueStr), ExtractFileExt(R.ValueStr));
      if N = 0 then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := N < 0;
      Exit;
    end;
    if aType = 4 then
    begin
      if (L.ValueInt = EXPLORER_ITEM_FOLDER) and (R.ValueInt <> EXPLORER_ITEM_FOLDER) then
      begin
        Result := True;
        Exit;
      end;
      if (L.ValueInt <> EXPLORER_ITEM_FOLDER) and (R.ValueInt = EXPLORER_ITEM_FOLDER) then
      begin
        Result := False;
        Exit;
      end;
      Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0;
    end;
  end;

  procedure Swap(var X: TSortItems; I, J: Integer);
  var
    Temp: TSortItem;
  begin
    Temp := X[I];
    X[I] := X[J];
    X[J] := Temp;
  end;

  procedure Qsort(var X: TSortItems; Left, Right: Integer; aType: Byte);
  label Again;
  var
    Pivot: TSortItem;
    P, Q: Integer;
    M: Integer;
  begin
    P := Left;
    Q := Right;
    M := (Left + Right) div 2;
    Pivot := X[M];

    while P <= Q do
    begin
      while L_Less_Than_R(X[P], Pivot, aType) do
      begin
        if P = M then
          Break;
        Inc(P);
      end;
      while L_Less_Than_R(Pivot, X[Q], aType) do
      begin
        if Q = M then
          Break;
        Dec(Q);
      end;
      if P > Q then
        goto Again;
      Swap(X, P, Q);
      Inc(P);
      Dec(Q);
    end;

  Again:
    if Left < Q then
      Qsort(X, Left, Q, aType);
    if P < Right then
      Qsort(X, P, Right, aType);
  end;

  procedure QuickSort(var X: TSortItems; N: Integer; aType: Byte);
  begin
    Qsort(X, 0, N - 1, aType);
  end;

begin
  DefaultSort := (Sender as TMenuItem).Tag;

  // NOT RIGHT! SORTING BY FOLDERS-IMAGES-OTHERS
  if ((Sender as TMenuItem).Tag = -1) then
    Exit;

  if not NoLockListView then
    UpdatingList := True;

  if not NoLockListView then
    ElvMain.Groups.BeginUpdate(False);

  try
    L := ElvMain.Items.Count;

    SetLength(SIs, L);
    SetLength(LI, L);

    for I := 0 to L - 1 do
    begin
      LI[I].Caption := ElvMain.Items[I].Caption;
      LI[I].Indent := ElvMain.Items[I].Tag;
      LI[I].Data := ElvMain.Items[I].Data;
      LI[I].ImageIndex := ElvMain.Items[I].ImageIndex;

      index := ItemIndexToMenuIndex(I);
      case (Sender as TMenuItem).Tag of
        0:
          begin
            SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
            SIs[I].ValueInt := FFilesInfo[index].FileType;
          end;
        1:
          begin
            SIs[I].ValueInt := FFilesInfo[index].Rating;
            SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
            if (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) then
              SIs[I].ValueInt := -1;
          end;
        2:
          begin
            SIs[I].ValueInt := FFilesInfo[index].FileSize;
            SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
          end;
        3:
          SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
        4:
          begin
            SIs[I].ValueDouble := DateModify(FFilesInfo[index].FileName);
            SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
          end;
        5:
          begin
            SIs[I].ValueStr := ExtractFileName(FFilesInfo[index].FileName);
            SIs[I].ValueInt := FFilesInfo[index].FileType;
          end;
      end;
      SIs[I].ID := I;
    end;

    case (Sender as TMenuItem).Tag of
      0:
        aType := 4;
      1, 2:
        aType := 1;
      3:
        aType := 3;
      4:
        aType := 2;
      5:
        aType := 5;
    else
      aType := 0;
    end;

    QuickSort(SIs, L, aType);

    for I := 0 to L - 1 do
    begin
      ElvMain.Items[I].Caption := LI[SIs[I].ID].Caption;
      ElvMain.Items[I].Tag := LI[SIs[I].ID].Indent;
      ElvMain.Items[I].ImageIndex := LI[SIs[I].ID].ImageIndex;
      ElvMain.Items[I].Data := LI[SIs[I].ID].Data;
    end;
  except
    on e: Exception do
      EventLog(':TExplorerForm.FileName1Click() throw exception: ' + e.Message);
  end;

  if not NoLockListView then
    ElvMain.Groups.EndUpdate;
  if not NoLockListView then
    UpdatingList := False;
end;

procedure TExplorerForm.MainPanelResize(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure TExplorerForm.MakeFolderViewer1Click(Sender: TObject);
var
  Query: TDataSet;
  IncludeSub: Boolean;
  Folder: string;
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
    FileList.Add(GetCurrentPath);
    IncludeSub := False;
    Query := GetQuery;
    try
      Folder := IncludeTrailingBackslash(GetCurrentPath);
      SetSQL(Query, 'SELECT count(*) AS CountField FROM $DB$ WHERE (FFileName LIKE :FolderA)');
      SetStrParam(Query, 0, '%' + Folder + '%\%');
      Query.Open;
      if Query.FieldByName('CountField').AsInteger > 0 then
        IncludeSub := MessageBoxDB(Handle, L('Include subfolders?'), L('Question'), TD_BUTTON_OKCANCEL,
          TD_ICON_QUESTION) = ID_OK;
    finally
      FreeDS(Query);
    end;
    SaveQuery(GetCurrentPath, IncludeSub, FileList);
  finally
    F(FileList);
  end;
end;

function TExplorerForm.ListView1Selected: TEasyItem;
begin
  Result := ElvMain.Selection.First;
end;

function TExplorerForm.ItemAtPos(X, Y: Integer): TEasyItem;
var
  WindowPt: TPoint;
  Group: TEasyGroup;
  ItemHitInfo: TEasyItemHitTestInfoSet;
begin
  WindowPt := ElvMain.Scrollbars.MapWindowToView(Point(X, Y));

  Result := nil;

  Group := ElvMain.Groups.GroupByPoint(WindowPt);
  if Assigned(Group) then
    Result := Group.ItembyPoint(WindowPt);

  if Assigned(Result) then
  begin
    Result.HitTestAt(WindowPt, ItemHitInfo);

    if not (ehtOnClickSelectBounds in ItemHitInfo) then
      Result := nil;
  end;
end;

procedure TExplorerForm.EasyListview2KeyAction(Sender: TCustomEasyListview; var CharCode: Word; var Shift: TShiftState;
  var DoDefault: Boolean);
var
  AChar: Char;
begin
  AChar := Char(CharCode);
  ListView1KeyPress(Sender, AChar);
end;

procedure TExplorerForm.EasyListview1ItemEdited(Sender: TCustomEasyListview; Item: TEasyItem; var NewValue: Variant;
  var Accept: Boolean);
var
  S: string;
begin
  S := NewValue;
  RenameResult := True;
  ListView1Edited(Sender, Item, S);
  Accept := S = NewValue;
  ElvMain.EditManager.Enabled := False;
  Accept := RenameResult;
  if not Accept then
    MessageBoxDB(Handle, L('Error renaming file!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TExplorerForm.N05Click(Sender: TObject);
var
  EventInfo: TEventValues;
  FileInfo: TDBPopupMenuInfoRecord;
begin
  if RatingPopupMenu.Tag > 0 then
  begin
    SetRating(RatingPopupMenu.Tag, (Sender as TMenuItem).Tag);
    EventInfo.Rating := (Sender as TMenuItem).Tag;
    DBKernel.DoIDEvent(Self, RatingPopupMenu.Tag, [EventID_Param_Rating], EventInfo);
  end else
  begin
    FileInfo := TDBPopupMenuInfoRecord.Create;
    try
      FileInfo.FileName := FFilesInfo[-RatingPopupMenu.Tag].FileName;
      FileInfo.Rating := (Sender as TMenuItem).Tag;
      FileInfo.Include := True;
      UpdaterDB.AddFileEx(FileInfo, True, True);
    finally
      F(FileInfo);
    end;
  end;
  if TsMediaPreview.Visible then
    TbPreviewRating.ImageIndex := (Sender as TMenuItem).Tag;
end;

procedure TExplorerForm.NavigateToFile(FileName: string);
begin
  SetOldPath(FileName);
  SetPath(ExtractFilePath(FileName));
end;

procedure TExplorerForm.ListView1Resize(Sender: TObject);
begin
  BeginScreenUpdate(ElvMain.Handle);
  try
    //no changes
    if ebcsUpdateScrollBars in ElvMain.States then
      Exit;
	  
    ElvMain.BackGround.OffsetX := ElvMain.Width - ElvMain.BackGround.Image.Width;
    ElvMain.BackGround.OffsetY := ElvMain.Height - ElvMain.BackGround.Image.Height;
    LsMain.Left := ClientWidth - LsMain.Width - GetSystemMetrics(SM_CYHSCROLL) - 3 - IIF(PnRight.Visible, PnRight.Width, 0);
    LoadSizes;
    if (ElvMain.Selection.FocusedItem <> nil) and (ElvMain.Selection.FocusedItem.Tag = 1) and not ElvMain.Scrollbars.IsAnimation then
    begin
      ElvMain.Selection.FocusedItem.MakeVisible(emvAuto);
      ElvMain.Selection.FocusedItem.Tag := 0;
    end;
  finally
    EndScreenUpdate(ElvMain.Handle, False);
  end;
end;

procedure TExplorerForm.EasyListview1DblClick(Sender: TCustomEasyListview;
  Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState;
  var Handled: Boolean);
var
  Capt, Dir, ShellDir, LinkPath: string;
  MenuInfo: TDBPopupMenuInfo;
  Index: Integer;
  P, P1: TPoint;
  Item: TObject;
  EasyItem: TEasyItem;

  procedure RestoreSelected;
  begin
    FDBCanDrag := False;
    FDBCanDragW := False;
  end;

begin

  GetCursorPos(P1);
  P := ElvMain.ScreenToClient(P1);
  EasyItem := ElvMain.Selection.FocusedItem;
  if (EasyItem <> nil) and (EasyItem.ImageIndex > -1) and not DBReadOnly then
  begin
    if ItemByPointStar(ElvMain, p, FPictureSize, FBitmapImageList[EasyItem.ImageIndex].Graphic) = EasyItem then
    begin
      Index := ItemAtPos(P.X, P.Y).Index;
      Index := ItemIndexToMenuIndex(index);
      if FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE then
      begin
        if FFilesInfo[Index].ID > 0 then
          RatingPopupMenu.Tag := FFilesInfo[Index].ID
        else
          RatingPopupMenu.Tag := -Index;

        if not((RatingPopupMenu.Tag < 0) and FolderView) then
        begin
          Application.HideHint;
          THintManager.Instance.CloseHint;
          LastMouseItem := nil;
          RatingPopupMenu.DoPopupEx(P1.X, P1.Y);
          Exit;
        end;
      end;
    end;
  end;

  FDblClicked := True;
  FDBCanDrag := False;
  FDBCanDragW := False;
  SetLength(FFilesToDrag, 0);
  Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := False;

  Item := EasyItem;
  if (Item = nil) and (Sender = nil) then
    Item := ListView1Selected;

  if Item <> nil then
    if ListView1Selected <> nil then
    begin
      Capt := ListView1Selected.Caption;
      GetCursorPos(MousePos);
      Index := ListView1Selected.Index;
      Index := ItemIndexToMenuIndex(index);
      if Index > FFilesInfo.Count - 1 then
        Exit;

      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) then
      begin
        Dir := IncludeTrailingBackslash(FFilesInfo[Index].FileName);
        SetNewPath(Dir, False);
        Exit;
      end;

      if FFilesInfo[Index].FileType = EXPLORER_ITEM_DRIVE then
      begin
        SetNewPath(FFilesInfo[Index].FileName, False);
        Exit;
      end;

      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) or
        (FFilesInfo[Index].FileType = EXPLORER_ITEM_DEVICE_IMAGE) then
      begin
        if not (ssShift in ShiftState) or not ShellPlayEncryptedMediaFile(FFilesInfo[Index].FileName) then
        begin
          MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
          try
            Viewer.ShowImages(Sender, MenuInfo);
            Viewer.Show;
            Viewer.Restore;
            RestoreSelected;
          finally
            F(MenuInfo);
          end;
        end;
        Exit;
      end;

      if FFilesInfo[Index].FileType = EXPLORER_ITEM_FILE then
      begin
        if GetExt(FFilesInfo[Index].FileName) <> 'LNK' then
        begin
          if not ShellPlayEncryptedMediaFile(FFilesInfo[Index].FileName) then
          begin
            ShellDir := ExtractFileDir(FFilesInfo[Index].FileName);
            ShellExecute(Handle, 'open', PWideChar(FFilesInfo[Index].FileName), nil, PWideChar(ShellDir), SW_NORMAL);
          end;
          RestoreSelected;
          Exit;
        end else
        begin
          LinkPath := ResolveShortcut(Handle, FFilesInfo[Index].FileName);
          if LinkPath = '' then
            Exit;
          if DirectoryExists(LinkPath) then
          begin
            SetStringPath(LinkPath, False);
            Exit;
          end else
          begin
            if IsGraphicFile(LinkPath) then
            begin
              MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
              try
                Viewer.ShowImages(Sender, MenuInfo);
                Viewer.Show;
                Viewer.Restore;
                RestoreSelected;
              finally
                F(MenuInfo);
              end;
              Exit;
            end;

            if not ShellPlayEncryptedMediaFile(LinkPath) then
            begin
              ShellDir := ExtractFileDir(LinkPath);
              ShellExecute(Handle, 'open', PWideChar(LinkPath), nil, PWideChar(ShellDir), SW_NORMAL);
            end;
            RestoreSelected;
            Exit;
          end;
        end;
      end;

      case FFilesInfo[Index].FileType of
        EXPLORER_ITEM_NETWORK, EXPLORER_ITEM_WORKGROUP, EXPLORER_ITEM_COMPUTER,
          EXPLORER_ITEM_SHARE, EXPLORER_ITEM_PERSON_LIST, EXPLORER_ITEM_GROUP_LIST,
          EXPLORER_ITEM_GROUP, EXPLORER_ITEM_PERSON, EXPLORER_ITEM_DEVICE,
          EXPLORER_ITEM_DEVICE_STORAGE, EXPLORER_ITEM_DEVICE_DIRECTORY,
          EXPLORER_ITEM_SHELF, EXPLORER_ITEM_CALENDAR, EXPLORER_ITEM_CALENDAR_YEAR,
          EXPLORER_ITEM_CALENDAR_MONTH, EXPLORER_ITEM_CALENDAR_DAY:
          SetNewPathW(ExplorerPath(FFilesInfo[Index].FileName,
            FFilesInfo[Index].FileType), False);
      end;
    end;
end;

procedure TExplorerForm.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Index, Y: Integer;
  Info: TExplorerFileInfo;
  Options: TDrawAttributesOptions;
begin
  if Item.Data = nil then
    Exit;
  if Item.ImageIndex < 0 then
    Exit;

  Index := ItemIndexToMenuIndex(Item.Index);
  Info := FFilesInfo[Index];

  Options := [];
  if FShowEXIFAttributes then
    Options := Options + [daoEXIF];

  if (Info.FileType <> EXPLORER_ITEM_IMAGE) then
    Options := Options + [daoNonImage];

  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y,
    FShowAttributes, Info, True, '', Options);

  if FShowAttributes then
  begin
    if Info.GeoLocation <> nil then
      DrawIconEx(ACanvas.Handle, ARect.Left, ARect.Bottom, UnitDBKernel.Icons[DB_IC_MAP_MARKER + 1], 16, 16, 0, 0, DI_NORMAL);

    if PhotoShelf.PathInShelf(Info.FileName) > -1 then
      DrawIconEx(ACanvas.Handle, ARect.Right - 20, ARect.Bottom, UnitDBKernel.Icons[DB_IC_SHELF + 1], 16, 16, 0, 0, DI_NORMAL);
  end;
end;

procedure TExplorerForm.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
  ListView1SelectItem(Sender, Item, False);
end;

procedure TExplorerForm.SetSelected(NewSelected: TEasyItem);
begin
  ElvMain.Selection.GroupSelectBeginUpdate;
  try
    ElvMain.Selection.ClearAll;
    if NewSelected <> nil then
      NewSelected.Selected := True;
  finally
    ElvMain.Selection.GroupSelectEndUpdate;
  end;
end;

procedure TExplorerForm.ScrollBox1Reallign(Sender: TObject);
var
  I: Integer;
begin
  if IsReallignInfo then
    Exit;

  // to match backgroupd image
  for I := 0 to ScrollBox1.ControlCount - 1 do
  begin
    if ScrollBox1.Controls[I] is TWebLink then
      TWebLink(ScrollBox1.Controls[I]).RefreshBuffer;
  end;
end;

procedure TExplorerForm.BackGround(Sender: TObject; X, Y, W, H: integer;
  Bitmap: TBitmap);
begin
  ScrollBox1.GetBackGround(X, Y, W, H, Bitmap);
end;

procedure TExplorerForm.Listview1IncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);
var
  CompareStr: WideString;
begin
  if UpdatingList then
    Exit;
  if Item = nil then
    Exit;

  CompareStr := Item.Caption;
  SetLength(CompareStr, Length(SearchBuffer));

  if IsUnicode then
    CompareResult := lstrcmpiW(PWideChar(SearchBuffer), PWideChar(CompareStr))
  else
    CompareResult := lstrcmpi(PChar(string(SearchBuffer)), PChar(string(CompareStr)));
end;

procedure TExplorerForm.EasyListview1ItemImageDraw(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
  const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
var
  Bitmap: TBitmap;
begin
  if GlobalLock then
    Exit;
  if Item.Data = nil then
    Exit;

  if FBitmapImageList[Item.ImageIndex].Icon <> nil then
    ACanvas.Draw(RectArray.IconRect.Left, RectArray.IconRect.Top, FBitmapImageList[Item.ImageIndex].Icon);

  Bitmap := FBitmapImageList[Item.ImageIndex].Bitmap;
  if Bitmap <> nil then
  begin
    Bitmap.AlphaFormat := afDefined;
    AlphaBlender.Blend(Sender, Item, ACanvas, RectArray.IconRect, Bitmap);
  end;
end;

procedure TExplorerForm.EasyListview1ItemImageDrawIsCustom(
  Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := ListView <> LV_THUMBS;
end;

function TExplorerForm.ListViewTypeToSize(ListViewType: Integer): Integer;
begin
  case ListViewType of
    LV_THUMBS     : Result := ThSize;
    LV_ICONS      : Result := 32;
    LV_SMALLICONS : Result := 16;
    LV_TITLES     : Result := 16;
    LV_TILE       : Result := 48;
    LV_GRID       : Result := 32;
    else
      Result := 32;
  end;
end;

procedure TExplorerForm.EasyListview1ItemImageGetSize(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; var ImageWidth,
  ImageHeight: Integer);
begin
  ImageHeight := ListViewTypeToSize(ListView);
  ImageWidth := ListViewTypeToSize(ListView);
end;

procedure TExplorerForm.EasyListview1ItemPaintText(Sender: TCustomEasyListview;
  Item: TEasyItem; Position: Integer; ACanvas: TCanvas);
var
  Include: Boolean;
  Index: Integer;
begin
  if GlobalLock then
    Exit;
  Include := True;
  if not((Item.Data = nil) or (Item.ImageIndex < 0)) then
  begin
    Index := ItemIndexToMenuIndex(Item.Index);
    Include := FFilesInfo[Index].Include or (FFilesInfo[Index].ID = 0);
  end;

  FixListViewText(ACanvas, Item, Include);
end;

procedure TExplorerForm.Reload;
begin
  SetNewPathW(GetCurrentPathW, False);
  LoadSizes;
end;

function TExplorerForm.GetView: Integer;
begin
  Result := ListView;
end;

procedure TExplorerForm.SetView(const Value: Integer);
begin
  ListView := Value;
  case ListView of
    LV_SMALLICONS:
      SmallIcons1.Checked := True;
    LV_ICONS:
      Icons1.Checked := True;
    LV_TITLES:
      List1.Checked := True;
    LV_TILE:
      Tile2.Checked := True;
    LV_GRID:
      Grid1.Checked := True;
    LV_THUMBS:
      Thumbnails1.Checked := True;
  end;
  Reload;
end;

procedure TExplorerForm.SmallIcons1Click(Sender: TObject);
begin
  View := LV_SMALLICONS;
end;

procedure TExplorerForm.Icons1Click(Sender: TObject);
begin
  View := LV_ICONS;
end;

procedure TExplorerForm.List1Click(Sender: TObject);
begin
  View := LV_TITLES;
end;

procedure TExplorerForm.Tile2Click(Sender: TObject);
begin
  View := LV_TILE;
end;

procedure TExplorerForm.TmHideStatusBarTimer(Sender: TObject);
begin
  TmHideStatusBar.Enabled := False;
  StatusBarMain.Hide;
end;

procedure TExplorerForm.TmrCheckItemVisibilityTimer(Sender: TObject);
var
  FI: TEasyItem;
  RectArray: TEasyRectArrayObject;
  RV, R, NR: TRect;
begin
  TmrCheckItemVisibility.Enabled := False;
  if ElvMain.Scrollbars.IsAnimation then
    Exit;
  if ElvMain.Height > ElvMain.CellSizes.Thumbnail.Height then
  begin
    FI := ElvMain.Selection.FocusedItem;
    if ElvMain.Selection.FocusedItem <> nil then
    begin
      FI.ItemRectArray(ElvMain.Header.FirstColumn, ElvMain.Canvas, RectArray);
      RV :=  ElvMain.Scrollbars.ViewableViewportRect;
      R := Rect(ElvMain.ClientRect.Left + rv.Left, ElvMain.ClientRect.Top + rv.Top, ElvMain.ClientRect.Right + rv.Left, ElvMain.ClientRect.Bottom + rv.Top);

      if IntersectRect(NR, R, RectArray.BoundsRect) then
        FI.MakeVisible(emvAuto);
    end;
  end;
end;

procedure TExplorerForm.TmrDelayedStartTimer(Sender: TObject);
var
  EventInfo: TEventValues;
begin
  PhotoShelf;
  EventInfo.Image := nil;
  DBKernel.DoIDEvent(Self, 0, [EventID_ShelfChanged], EventInfo);
  TmrDelayedStart.Enabled := False;
end;

procedure TExplorerForm.TmrSearchResultsCountTimer(Sender: TObject);
begin
//
end;

procedure TExplorerForm.Grid1Click(Sender: TObject);
begin
  View := LV_GRID;
end;

procedure TExplorerForm.Thumbnails1Click(Sender: TObject);
begin
  View := LV_THUMBS;
end;

procedure TExplorerForm.ToolButtonViewClick(Sender: TObject);
var
  APoint: TPoint;
begin
  APoint := Point(ToolButtonView.Left, ToolButtonView.Top + ToolButtonView.Height);
  APoint := ToolBarMain.ClientToScreen(APoint);
  PmListViewType.DoPopupEx(APoint.X, APoint.Y);
end;

function TExplorerForm.GetViewInfo: TExplorerViewInfo;
begin
  Result.ShowFolders := Settings.Readbool('Options', 'Explorer_ShowFolders', True);
  Result.ShowSimpleFiles := Settings.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Result.ShowImageFiles := Settings.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Result.ShowHiddenFiles := Settings.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Result.ShowAttributes := Settings.Readbool('Options', 'Explorer_ShowAttributes', True);
  Result.ShowThumbNailsForFolders := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Result.SaveThumbNailsForFolders := Settings.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Result.ShowThumbNailsForImages := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Result.ShowThumbNailsForVideo := Settings.Readbool('Options', 'Explorer_ShowThumbnailsForVideo', True);
  Result.View := ListView;
  Result.PictureSize := FPictureSize;
end;

procedure TExplorerForm.MakeFolderViewer2Click(Sender: TObject);
var
  FileList: TStrings;
  I, Index: Integer;
begin
  if ListView1Selected <> nil then
  begin
    FileList := TStringList.Create;
    try
      for I := 0 to ElvMain.Items.Count - 1 do
        if ElvMain.Items[I].Selected then
        begin
          Index := ItemIndexToMenuIndex(I);
          if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE)
            then
              FileList.Add(FFilesInfo[Index].FileName)

        end;
      SaveQuery(GetCurrentPath, False, FileList);
    finally
      F(FileList);
    end;
  end;
end;

procedure TExplorerForm.ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if not(SsCtrl in Shift) then
    Exit;

  if WheelDelta < 0 then
    ZoomOut
  else
    ZoomIn;

  Handled := True;
end;

procedure TExplorerForm.ZoomIn;
var
  SelectedVisible: Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;

    if (View = LV_THUMBS) and (FPictureSize < ListViewMaxThumbnailSize) then
    begin
      FPictureSize := FPictureSize + 10;
      LoadSizes;
      BigImagesTimer.Restart;
      ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
      ElvMain.Groups.ReIndexItems;
      ElvMain.Groups.Rebuild(True);

      if SelectedVisible and not IsSelectedVisible then
        ElvMain.Selection.First.MakeVisible(EmvTop);
    end else
    begin
      case View of
        LV_GRID:
          View := LV_TITLES;
        LV_TITLES:
          View := LV_SMALLICONS;
        LV_SMALLICONS:
          View := LV_ICONS;
        LV_ICONS:
          View := LV_TILE;
        LV_TILE:
          View := LV_THUMBS;
        LV_THUMBS:
          View := LV_THUMBS;
      end;
    end;

  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TExplorerForm.ZoomOut;
var
  SelectedVisible: Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;

    if FPictureSize > ListViewMinThumbnailSize then
    begin
      FPictureSize := FPictureSize - 10;
      LoadSizes;
      BigImagesTimer.Enabled := False;
      BigImagesTimer.Enabled := True;
      ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
      ElvMain.Groups.ReIndexItems;
      ElvMain.Groups.Rebuild(True);
      if SelectedVisible and not IsSelectedVisible then
        ElvMain.Selection.First.MakeVisible(EmvTop);
    end else
    begin
      FPictureSize := ListViewMinThumbnailSize;
      case View of
        LV_THUMBS:
          View := LV_TILE;
        LV_TILE:
          View := LV_ICONS;
        LV_ICONS:
          View := LV_SMALLICONS;
        LV_SMALLICONS:
          View := LV_TITLES;
        LV_TITLES:
           View := LV_TITLES;
      end;
    end;
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TExplorerForm.BigImagesTimerTimer(Sender: TObject);
var
  UpdaterInfo: TUpdaterInfo;
  I: Integer;
begin
  BigImagesTimer.Enabled := False;
  if ListView <> LV_THUMBS then
    Exit;
  // тут начинается загрузка больших картинок
  UpdaterInfo := TUpdaterInfo.Create;

  NewFormState;
  DirectoryWatcher.UpdateStateID(StateID);

  PePath.CanBreakLoading := True;
  TExplorerThread.Create('::BIGIMAGES', '', THREAD_TYPE_BIG_IMAGES, ViewInfo, Self, UpdaterInfo, StateID);
  for I := 0 to FFilesInfo.Count - 1 do
    FFilesInfo[I].IsBigImage := False;
end;

function TExplorerForm.GetAllItems: TExplorerFileInfos;
begin
  Result := TExplorerFileInfos.Create;
  Result.Assign(FFilesInfo);
end;

procedure TExplorerForm.DoDefaultSort(GUID: TGUID);
begin
  NoLockListView := True;
  try
    case DefaultSort of
      0:
        FileName1Click(FileName1);
      // 1: - rating!!! no default sorting, information about sorting goes later
      2:
        FileName1Click(Size1);
      3:
        FileName1Click(Type1);
      4:
        FileName1Click(Modified1);
      5:
        FileName1Click(Number1);
    end;
  finally
    NoLockListView := False;
  end;
end;

procedure TExplorerForm.AddHiddenInfo1Click(Sender: TObject);
var
  Index: Integer;
begin
  if SelCount = 1 then
  begin
    Index := ItemIndexToMenuIndex(ListView1Selected.Index);
    SteganographyForm.HideData(FFilesInfo[index].FileName);
  end;
end;

procedure TExplorerForm.ExtractHiddenInfo1Click(Sender: TObject);
var
  Index: Integer;
begin
  if SelCount = 1 then
  begin
    Index := ItemIndexToMenuIndex(ListView1Selected.Index);
    SteganographyForm.ExtractData(FFilesInfo[Index].FileName);
  end;
end;

procedure TExplorerForm.TbZoomOutClick(Sender: TObject);
begin
  ZoomOut;
end;

procedure TExplorerForm.TbZoomInClick(Sender: TObject);
begin
  ZoomIn;
end;

procedure TExplorerForm.LoadToolBarNormaIcons;
var
  UseSmallIcons: Boolean;

  procedure AddIcon(Name: string);
  var
    Icon: HIcon;
  begin
    if UseSmallIcons then
      Name := Name + '_SMALL';

    Icon := LoadIcon(HInstance, PWideChar(Name));
    ImageList_ReplaceIcon(ToolBarNormalImageList.Handle, -1, Icon);
    DestroyIcon(Icon);
  end;

begin
  UseSmallIcons := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
  ToolBarNormalImageList.Clear;

  if UseSmallIcons then
  begin
    ToolBarNormalImageList.Width := 16;
    ToolBarNormalImageList.Height := 16;
  end;

  AddIcon('EXPLORER_BACK');
  AddIcon('EXPLORER_UP');
  AddIcon('EXPLORER_GO');
  AddIcon('EXPLORER_CUT');
  AddIcon('EXPLORER_COPY');
  AddIcon('EXPLORER_PASTE');
  AddIcon('EXPLORER_DELETE');
  AddIcon('EXPLORER_VIEW');
  AddIcon('EXPLORER_ZOOM_OUT');
  AddIcon('EXPLORER_ZOOM_IN');
  AddIcon('EXPLORER_SEARCH');
  AddIcon('EXPLORER_OPTIONS');
  AddIcon('EXPLORER_PREVIEW');
end;

procedure TExplorerForm.LoadToolBarGrayedIcons;
var
  UseSmallIcons: Boolean;

  procedure AddIcon(Name: string);
  var
    Icon: HIcon;
  begin
    if UseSmallIcons then
      Name := Name + '_SMALL';

    Icon := LoadIcon(HInstance, PWideChar(Name));
    ImageList_ReplaceIcon(ToolBarDisabledImageList.Handle, -1, Icon);
    DestroyIcon(Icon);
  end;

begin
  ToolBarDisabledImageList.Clear;

  UseSmallIcons := Settings.Readbool('Options', 'UseSmallToolBarButtons', False);
  if UseSmallIcons then
  begin
    ToolBarDisabledImageList.Width := 16;
    ToolBarDisabledImageList.Height := 16;
  end;

  AddIcon('EXPLORER_BACK_GRAY');
  AddIcon('EXPLORER_UP_GRAY');
  AddIcon('EXPLORER_GO_GRAY');
  AddIcon('EXPLORER_CUT_GRAY');
  AddIcon('EXPLORER_COPY_GRAY');
  AddIcon('EXPLORER_PASTE_GRAY');
  AddIcon('EXPLORER_DELETE_GRAY');
  AddIcon('EXPLORER_VIEW_GRAY');
  AddIcon('EXPLORER_ZOOM_OUT_GRAY');
  AddIcon('EXPLORER_ZOOM_IN_GRAY');
  AddIcon('EXPLORER_SEARCH_GRAY');
  AddIcon('EXPLORER_OPTIONS_GRAY');
  AddIcon('EXPLORER_PREVIEW_GRAY');
end;

procedure TExplorerForm.TbBackMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Explorer: TCustomExplorerForm;
begin
  if Button = mbMiddle then
  begin
    if FHistory.CanBack then
    begin
      Explorer := ExplorerManager.NewExplorer(False);
      Explorer.SetNewPathW(FHistory.GetBackPath, False);
      Explorer.Show;
    end;
  end;
end;

procedure TExplorerForm.TbbOpenDirectoryClick(Sender: TObject);
var
  Item: TEasyItem;
  FilePath, Directory: string;
  P: TPathItem;
  FI: TExplorerFileInfo;
begin
  Item := ListView1Selected;
  if Item <> nil then
  begin
    FilePath := FFilesInfo[ItemIndexToMenuIndex(Item.Index)].FileName;
    Directory := ExtractFileDir(FilePath);

    P := PathProviderManager.CreatePathItem(Directory);
    try
      if P = nil then
        Exit;

      FI := TExplorerFileInfo.CreateFromPathItem(P);
      try
        SetOldPath(FilePath);
        SetNewPathW(ExplorerPath(FI.FileName, FI.FileType), False);
      finally
        F(FI);
      end;
    finally
      F(P);
    end;
  end;
end;

procedure TExplorerForm.TbDeleteClick(Sender: TObject);
begin
  DeleteFiles(True);
end;

procedure TExplorerForm.TbSearchClick(Sender: TObject);
begin
  if Sender = TbSearch then
  begin
    TbSearch.Tag := -TbSearch.Tag;
    TbSearch.Down := TbSearch.Tag < 0;
  end;

  if TbSearch.Down then
  begin
    FLeftTabs := FLeftTabs + [eltsSearch];
    ShowActiveLeftTab(eltsSearch);
    ExtendedSearchInit;
  end else
  begin
    FLeftTabs := FLeftTabs - [eltsSearch];
    if not (FActiveLeftTab in FLeftTabs) then
      ShowLastActiveLeftTab(eltsAny);
  end;
  ApplyLeftTabs;

  Settings.WriteBool('Explorer', 'LeftPanelSearchVisible', TbSearch.Down);
end;

procedure TExplorerForm.TbStopClick(Sender: TObject);
begin
  NewFormState;
  if UpdatingList then
    EndUpdate(True);
  PePath.CanBreakLoading := False;
  LsMain.Hide;
  HideProgress;
  StatusBarMain.Panels[1].Text := L('Loading canceled...');
end;

procedure TExplorerForm.DoStartPersonSelection(Sender: TObject);
begin
  if FImageViewer <> nil then
  begin
    FImageViewer.StartPersonSelection;
    TWebLink(Sender).Enabled := False;
    TWebLink(Sender).DisableStyles := True;
    TWebLink(Sender).Font.Color := ColorDiv2(Theme.PanelColor, Theme.PanelFontColor);
  end;
end;

procedure TExplorerForm.DoStopLoading;
begin
  PePath.CanBreakLoading := False;
  FStatusProgress.Visible := False;
  StatusBarMain.Panels[1].Text := '';
  StatusBarMain.Hide;
end;

procedure TExplorerForm.LoadSizes;
begin
  SetLVThumbnailSize(ElvMain, FPictureSize);
end;

procedure TExplorerForm.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
  Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
  BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
end;

procedure TExplorerForm.PortableEventsCallBack(EventType: TPortableEventType;
  DeviceID, ItemKey, ItemPath: string);
var
  Index, I: Integer;
begin
  case EventType of
    peDeviceConnected,
    peDeviceDisconnected:
    begin
      if FCurrentTypePath = EXPLORER_ITEM_COMPUTER then
        Reload;
    end;
    //peItemAdded:
    peItemRemoved:
    begin
      for I := 0 to ElvMain.Items.Count - 1 do
      begin
        Index := ItemIndexToMenuIndex(I);
        if AnsiLowerCase(FFilesInfo[index].FileName) = AnsiLowerCase(cDevicesPath + '\' + ItemPath) then
        begin
          DeleteItemWithIndex(I);
          Break;
        end;
      end;
    end;
  end;
end;

//InitTab: update edit info
procedure TExplorerForm.InitInfoEditor(InitTab: Boolean);
begin
  if TsInfo.Visible then
    BeginScreenUpdate(TsInfo.Handle);
  try
    if InitTab then
    begin
      F(FEditorInfo);
      FEditorInfo := GetCurrentPopUpMenuInfo(ElvMain.Selection.FocusedItem, True);

      if FEditorInfo.Count = 0 then
      begin
        DisableInfoEditor;
        Exit;
      end; 
    end;

    FLeftTabs := FLeftTabs + [eltsInfo];
    ShowLastActiveLeftTab(eltsInfo);

    //if tab invisible but some child control request Handle -> issue: create handle and this tab is displayed on screen
    //sp update controls when tab is showing
    if TsInfo.HandleAllocated then
    begin     
      if FEditorInfo.Count > 1 then
        ClearHistogram
      else
        ImHistogramm.Stretch := True;
        
      ReRating.Rating := FEditorInfo.StatRating;
      if FEditorInfo.Count = 1 then
      begin
        ReRating.Islayered := False;
        ReRating.Layered := 255;
      end else
      begin
        ReRating.Islayered := True;
        ReRating.Layered := 100;
      end;

      DteDate.DateTime := FEditorInfo.StatDate;
      DteTime.Time := FEditorInfo.StatTime;

      DteDate.Checked := FEditorInfo.StatIsDate and not FEditorInfo.IsVariousDate;
      DteTime.Checked := FEditorInfo.StatIsTime and not FEditorInfo.IsVariousTime;

      MemKeyWords.Text := FEditorInfo.CommonKeyWords;
      MemComments.Text := FEditorInfo.CommonComments;

      FSelectedInfo.Groups := FEditorInfo.CommonGroups;
      InitEditGroups;

      BtnSaveInfo.Enabled := False;
    end else
      TsInfo.Tag := 1;
    
  finally
    if TsInfo.Visible then
      EndScreenUpdate(TsInfo.Handle, False);
  end;
end;

procedure CreteDefaultGroupImage(B: TBitmap);
begin
  B.PixelFormat := pf24bit;
  B.SetSize(16, 16);
  FillColorEx(B, Theme.PanelColor);
  DrawIconEx(B.Canvas.Handle, 0, 0, UnitDBKernel.Icons[DB_IC_GROUPS + 1], 16, 16, 0, 0, DI_NORMAL);
end;

procedure CreateGroupImage(GroupName: string; var B: TBitmap);
var
  Group: TGroup;
begin
  B.PixelFormat := pf24bit;
  Group := GetGroupByGroupName(GroupName, True);
  try
    if (Group.GroupImage <> nil) and not Group.GroupImage.Empty  then
    begin
      AssignGraphic(B, Group.GroupImage);
      CenterBitmap24To32ImageList(B, 16);
    end else
      CreteDefaultGroupImage(B);
  finally
    FreeGroup(Group);
  end;
end;

type
  TGroupLoadInfo = class
    Owner: TExplorerForm;
    Groups: string;
  end;

procedure TExplorerForm.InitEditGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
  LoadGroupInfo: TGroupLoadInfo;
  B: TBitmap;
begin
  FCurrentGroups := EncodeGroups(FSelectedInfo.Groups);

  ImGroups.Clear;
  B := TBitmap.Create;
  try
    CreteDefaultGroupImage(B);
    ImGroups.Add(B, nil);
  finally
    F(B);
  end;

  WllGroups.Clear;

  if Length(FCurrentGroups) = 0 then
  begin
    LblInfo := TStaticText.Create(WllGroups);
    LblInfo.Parent := WllGroups;
    WllGroups.AddControl(LblInfo, True);
    LblInfo.Caption := L('There are no groups');
  end;

  if not DBReadOnly then
  begin
    WL := WllGroups.AddLink(True);
    WL.Text := L('Edit groups');
    WL.ImageList := ImGroups;
    WL.ImageIndex := 0;
    WL.Tag := -1;
    WL.OnClick := GroupClick;
  end;

  for I := 0 to Length(FCurrentGroups) - 1 do
  begin
    WL := WllGroups.AddLink;
    WL.Text := FCurrentGroups[I].GroupName;
    WL.ImageList := ImGroups;
    WL.ImageIndex := 0;
    WL.Tag := I;
    WL.OnClick := GroupClick;
  end;

  LoadGroupInfo := TGroupLoadInfo.Create;
  LoadGroupInfo.Owner := Self;
  LoadGroupInfo.Groups := FSelectedInfo.Groups;

  TThreadTask.Create(Self, LoadGroupInfo,
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      Info: TGroupLoadInfo;
      J: Integer;
      B: TBitmap;
      Groups: TGroups;
      IsTerminated: Boolean;
    begin
      CoInitialize(nil);
      try
        Info := TGroupLoadInfo(Data);
        try
          Groups := EncodeGroups(Info.Groups);

          for J := 0 to Length(Groups) - 1 do
          begin

            B := TBitmap.Create;
            try
              CreateGroupImage(Groups[J].GroupName, B);

              IsTerminated := not Thread.SynchronizeTask(
                procedure
                var
                  I: Integer;
                  WL: TWebLink;
                begin
                  if (Info.Owner.FSelectedInfo.Groups <> Info.Groups) then
                  begin
                    Thread.Terminate;
                    Exit;
                  end;

                  for I := 0 to WllGroups.ControlCount - 1 do
                    if WllGroups.Controls[I] is TWebLink then
                    begin
                      WL := TWebLink(WllGroups.Controls[I]);
                      if WL.Text = Groups[J].GroupName then
                        WL.ImageIndex := Info.Owner.ImGroups.Add(B, nil);
                    end;
                end
              );

              if IsTerminated then
                Exit;
            finally
              F(B);
            end;
          end;
        finally
         F(Info);
        end;
      finally
        CoUninitialize;
      end;
    end
  );

  WllGroups.ReallignList;
  WllGroups.AutoHeight(200);

  ReallignEditBoxes;
end;

procedure TExplorerForm.ExtendedSearchGroupClick(Sender: TObject);
var
  Link: TWebLink;
  Groups, KeyWords: string;
begin
  Link := TWebLink(Sender);
  if Link.Tag = -1 then
  begin
    Groups := WllExtendedSearchGroups.TagEx;
    KeyWords := '';

    GroupsSelectForm.Execute(Groups, KeyWords);

    WllExtendedSearchGroups.TagEx := Groups;

    PostMessage(Handle, FReloadESGroupsMessage, 0, 0);
  end else
  begin
    PmESGroup.Tag := Link.Tag;
    PmESGroup.Popup(Link.ScreenBelow.X, Link.ScreenBelow.Y);
  end;
end;

procedure TExplorerForm.ExtendedSearchGroupModeClick(Sender: TObject);
begin
  FExtendedSearchParams.GroupsAnd := not FExtendedSearchParams.GroupsAnd;
  PostMessage(Handle, FReloadESGroupsMessage, 0, 0);
end;

procedure TExplorerForm.ExtendedSearchInit;
begin
  if FExtendedSearchParams = nil then
  begin
    try
      BeginScreenUpdate(TsDetailedSearch.Handle);

      PmESPerson.Images := DBKernel.ImageList;
      PmESGroup.Images := DBKernel.ImageList;

      MiESPersonFindPictures.Caption := L('Find pictures');
      MiESPersonRemoveFromList.Caption := L('Remove from list');
      MiESPersonProperties.Caption := L('Properties');

      MiESPersonFindPictures.ImageIndex := DB_IC_SEARCH;
      MiESPersonRemoveFromList.ImageIndex := DB_IC_DELETE_INFO;
      MiESPersonProperties.ImageIndex := DB_IC_PROPERTIES;

      MiESGroupFindPictures.Caption := L('Find pictures');
      MiESGroupRemove.Caption := L('Remove from list');
      MiESGroupProperties.Caption := L('Properties');

      MiESGroupFindPictures.ImageIndex := DB_IC_SEARCH;
      MiESGroupRemove.ImageIndex := DB_IC_DELETE_INFO;
      MiESGroupProperties.ImageIndex := DB_IC_PROPERTIES;

      MiESSortByID.Caption := L('Sort by ID');
      MiESSortByID.Tag := NativeInt(dsmID);
      MiESSortByName.Caption := L('Sort by name');
      MiESSortByName.Tag := NativeInt(dsmName);
      MiESSortByDate.Caption := L('Sort by date');
      MiESSortByDate.Tag := NativeInt(dsmDate);
      MiESSortByRating.Caption := L('Sort by rating');
      MiESSortByRating.Tag := NativeInt(dsmRating);
      MiESSortByFileSize.Caption := L('Sort by file size');
      MiESSortByFileSize.Tag := NativeInt(dsmFileSize);
      MiESSortByImageSize.Caption := L('Sort by image size');
      MiESSortByImageSize.Tag := NativeInt(dsmImageSize);

      MiESShowHidden.Caption := L('Show hidden images');
      MiESShowPrivate.Caption := L('Show private images');

      FExtendedSearchParams := TDatabaseSearchParameters.Create;
      FExtendedSearchParams.DateFrom := MinDateTime;
      FExtendedSearchParams.DateTo := MinDateTime;
      FExtendedSearchParams.RatingFrom := 0;
      FExtendedSearchParams.RatingTo := 5;
      FExtendedSearchParams.ShowPrivate := False;
      FExtendedSearchParams.ShowHidden := False;

      FExtendedSearchPersons := TList<TPerson>.Create;

      LoadSpeedButtonFromResourcePNG(SbExtendedSearchStart, 'SEARCH');

      WlExtendedSearchDateFrom.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EDIT_DATE + 1]);
      WlExtendedSearchDateTo.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_EDIT_DATE + 1]);

      WlExtendedSearchOptions.LoadFromResource('SERIES_SETTINGS');

      WlExtendedSearchSortDescending.LoadFromResource('SORT_DESCENDING');

      BtnSearch.Images := DBKernel.ImageList;
      BtnSearch.ImageIndex := DB_IC_SEARCH;

      WlSearchRatingFromValue.LoadFromResource('TRATING_DEL');
      WlSearchRatingToValue.LoadFromResource('TRATING_5');

      WlSearchRatingFrom.Text := L('Rating from');
      WlSearchRatingTo.Text := L('Rating to');
      BtnSearch.Caption := L('Search');
      BtnSelectDatePopup.Caption := L('Ok');
      BtnSelectDatePopupReset.Caption := L('Reset');
      MiPreviousSelections.Caption := L('Previous selections') + ':';
      MiOtherPersons.Caption := L('Other person');

      ExtendedSearchInitGroups;
      ExtendedSearchInitPersons;

      ExtendedSearchCheckEnabled;
      ExtendedSearchRealign;
    finally
      EndScreenUpdate(TsDetailedSearch.Handle, False);
    end;
  end;
end;

procedure TExplorerForm.ExtendedSearchInitGroups;
var
  WL,
  WlExtendedSearchAddGroup: TWebLink;
  ESGroups: TGroups;
  I: Integer;
  LoadGroupInfo: TGroupLoadInfo;
  B: TBitmap;
begin
  BeginScreenUpdate(WllExtendedSearchGroups.Handle);
  try

    ImExtendedSearchGroups.Clear;
    B := TBitmap.Create;
    try
      CreteDefaultGroupImage(B);
      ImExtendedSearchGroups.Add(B, nil);
    finally
      F(B);
    end;

    WllExtendedSearchGroups.Clear;

    WlExtendedSearchAddGroup := WllExtendedSearchGroups.AddLink(True);
    WlExtendedSearchAddGroup.IconWidth := 16;
    WlExtendedSearchAddGroup.IconHeight := 16;
    WlExtendedSearchAddGroup.Text := L('Photos with groups');
    WlExtendedSearchAddGroup.LoadFromResource('GROUP_ADD_SMALL');
    WlExtendedSearchAddGroup.OnClick := ExtendedSearchGroupClick;
    WlExtendedSearchAddGroup.Tag := -1;

    ESGroups := EncodeGroups(WllExtendedSearchGroups.TagEx);

    for I := 0 to Length(ESGroups) - 1 do
    begin
      WL := WllExtendedSearchGroups.AddLink;
      WL.Text := ESGroups[I].GroupName;
      WL.ImageList := ImExtendedSearchGroups;
      WL.ImageIndex := 0;
      WL.Tag := I;
      WL.OnClick := ExtendedSearchGroupClick;

      if I < Length(ESGroups) - 1 then
      begin
        WL := WllExtendedSearchGroups.AddLink;
        WL.Text := IIF(FExtendedSearchParams.GroupsAnd, L('and'), L('or'));
        WL.IconWidth := 0;
        WL.IconHeight := 16;
        WL.OnClick := ExtendedSearchGroupModeClick;
      end;
    end;

    LoadGroupInfo := TGroupLoadInfo.Create;
    LoadGroupInfo.Owner := Self;
    LoadGroupInfo.Groups := WllExtendedSearchGroups.TagEx;

    TThreadTask.Create(Self, LoadGroupInfo,
      procedure(Thread: TThreadTask; Data: Pointer)
      var
        Info: TGroupLoadInfo;
        J: Integer;
        B: TBitmap;
        Groups: TGroups;
        IsTerminated: Boolean;
      begin
        CoInitialize(nil);
        try
          Info := TGroupLoadInfo(Data);
          try
            Groups := EncodeGroups(Info.Groups);

            for J := 0 to Length(Groups) - 1 do
            begin

              B := TBitmap.Create;
              try
                CreateGroupImage(Groups[J].GroupName, B);

                IsTerminated := not Thread.SynchronizeTask(
                  procedure
                  var
                    I: Integer;
                    WL: TWebLink;
                  begin
                    if (Info.Owner.WllExtendedSearchGroups.TagEx <> Info.Groups) then
                    begin
                      Thread.Terminate;
                      Exit;
                    end;

                    for I := 0 to WllExtendedSearchGroups.ControlCount - 1 do
                      if WllExtendedSearchGroups.Controls[I] is TWebLink then
                      begin
                        WL := TWebLink(WllExtendedSearchGroups.Controls[I]);
                        if WL.Text = Groups[J].GroupName then
                        begin
                          WL.ImageIndex := Info.Owner.ImExtendedSearchGroups.Add(B, nil);
                          Exit;
                        end;
                      end;
                  end
                );

                if IsTerminated then
                  Exit;
              finally
                F(B);
              end;
            end;
          finally
           F(Info);
          end;
        finally
          CoUninitialize;
        end;
      end
    );

    WllExtendedSearchGroups.ReallignList;
    WllExtendedSearchGroups.AutoHeight(300);

  finally
    EndScreenUpdate(WllExtendedSearchGroups.Handle, True);
  end;
  ExtendedSearchRealign;
end;

procedure TExplorerForm.ExtendedSearchInitPersons;
var
  I: Integer;
  B: TBitmap;
  WL, WlExtendedSearchAddPerson: TWebLink;
begin
  BeginScreenUpdate(WllExtendedSearchPersons.Handle);
  try

    ImExtendedSearchPersons.Clear;
    B := TBitmap.Create;
    try
      CreteDefaultGroupImage(B);
      ImExtendedSearchPersons.Add(B, nil);
    finally
      F(B);
    end;

    WllExtendedSearchPersons.Clear;

    WlExtendedSearchAddPerson := WllExtendedSearchPersons.AddLink(True);
    WlExtendedSearchAddPerson.IconWidth := 16;
    WlExtendedSearchAddPerson.IconHeight := 16;
    WlExtendedSearchAddPerson.Text := L('Persons on photo');
    WlExtendedSearchAddPerson.LoadFromResource('GROUP_ADD_SMALL');
    WlExtendedSearchAddPerson.OnClick := WlExtendedSearchAddPersonClick;
    WlExtendedSearchAddPerson.PopupMenu := PmSelectPerson;

    for I := 0 to FExtendedSearchPersons.Count - 1 do
    begin
      WL := WllExtendedSearchPersons.AddLink;
      WL.Text := FExtendedSearchPersons[I].Name;
      WL.ImageList := ImExtendedSearchPersons;
      WL.ImageIndex := ImExtendedSearchPersons.Add(FExtendedSearchPersons[I].CreatePreview(16, 16), nil);
      WL.Tag := I;
      WL.OnClick := ExtendedSearchPersonClick;

      if I < FExtendedSearchPersons.Count - 1 then
      begin
        WL := WllExtendedSearchPersons.AddLink;
        WL.Text := IIF(FExtendedSearchParams.PersonsAnd, L('and'), L('or'));
        WL.IconWidth := 0;
        WL.IconHeight := 16;
        WL.OnClick := ExtendedSearchPersonModeClick;
      end;
    end;

    WllExtendedSearchPersons.ReallignList;
    WllExtendedSearchPersons.AutoHeight(300);
  finally
    EndScreenUpdate(WllExtendedSearchPersons.Handle, True);
  end;
  ExtendedSearchRealign;
end;

procedure TExplorerForm.ExtendedSearchPersonClick(Sender: TObject);
var
  P: TPoint;
  Control: TWInControl;
begin
  Control := TWInControl(Sender);
  P := Point(Control.Left, Control.BoundsRect.Bottom);
  P := Control.Parent.ClientToScreen(P);
  PmESPerson.Tag := Control.Tag;
  PmESPerson.Popup(P.X, P.Y);
end;

procedure TExplorerForm.ExtendedSearchPersonModeClick(Sender: TObject);
begin
  FExtendedSearchParams.PersonsAnd := not FExtendedSearchParams.PersonsAnd;
  PostMessage(Handle, FReloadRSPersonsMessage, 0, 0);
end;

procedure TExplorerForm.WlExtendedSearchAddPersonClick(Sender: TObject);
var
  P: TPoint;
  R: TRect;
begin
  R := TWebLink(Sender).BoundsRect;
  P := Point(R.Left, R.Bottom);
  P := TWebLink(Sender).ClientToScreen(P);
  PmSelectPerson.Popup(P.X, P.Y);
end;

procedure TExplorerForm.WlExtendedSearchDateFromClick(Sender: TObject);

  function EffectiveDate(Date: TDateTime): TDateTime;
  begin
    if Date = MinDateTime then
      Exit(Now);

    Result := Date;
  end;

begin
  PnSelectDatePopup.Show;
  PnSelectDatePopup.Top := TWinControl(Sender).FormBounds.Bottom + 2;
  PnSelectDatePopup.Left := TWinControl(Sender).FormBounds.Left;
  PnSelectDatePopup.Tag := NativeInt(Sender);
  if Sender = WlExtendedSearchDateFrom then
    McDateSelectPopup.Date := EffectiveDate(FExtendedSearchParams.DateFrom);
  if Sender = WlExtendedSearchDateTo then
    McDateSelectPopup.Date := EffectiveDate(FExtendedSearchParams.DateTo);
end;

procedure TExplorerForm.WlExtendedSearchOptionsClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Point(WlExtendedSearchOptions.Left, WlExtendedSearchOptions.BoundsRect.Bottom);
  P := WlExtendedSearchOptions.Parent.ClientToScreen(P);
  PmESOptions.Popup(P.X, P.Y);
end;

procedure TExplorerForm.WlExtendedSearchOptionsContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if FExtendedSearchParams <> nil then
  begin
    MiESShowHidden.Checked := FExtendedSearchParams.ShowHidden;
    MiESShowPrivate.Checked := FExtendedSearchParams.ShowPrivate;
  end;
end;

procedure TExplorerForm.WlExtendedSearchSortByClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Point(WlExtendedSearchSortBy.Left, WlExtendedSearchSortBy.BoundsRect.Bottom);
  P := WlExtendedSearchSortBy.Parent.ClientToScreen(P);
  PmESSorting.Popup(P.X, P.Y);
end;

procedure TExplorerForm.WlExtendedSearchSortDescendingClick(Sender: TObject);
begin
  FExtendedSearchParams.SortDescending := not FExtendedSearchParams.SortDescending;
  if FExtendedSearchParams.SortDescending then
    WlExtendedSearchSortDescending.LoadFromResource('SORT_DESCENDING')
  else
    WlExtendedSearchSortDescending.LoadFromResource('SORT_ASCENDING');
end;

procedure TExplorerForm.AddWideSearchPerson(P: TPerson);
begin
  PersonManager.MarkLatestPerson(P.ID);
  FExtendedSearchPersons.Add(P);
  P.CreatePreview(16, 16);
  PostMessage(Handle, FReloadRSPersonsMessage, 0, 0);
end;

procedure TExplorerForm.PmSelectPersonPopup(Sender: TObject);
var
  I, J, LatestPersonsIndex: Integer;
  SelectedPersons: TPersonCollection;
  LatestPersons: Boolean;
  MI: TMenuItem;
begin

  ImFacePopup.Clear;
  ImageList_AddIcon(ImFacePopup.Handle, UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);
  ImageList_AddIcon(ImFacePopup.Handle, UnitDBKernel.Icons[DB_IC_PEOPLE + 1]);

  SelectedPersons := TPersonCollection.Create;
  try
    //remove last persons
    LatestPersons := False;
    LatestPersonsIndex := 0;
    for I := PmSelectPerson.Items.Count - 1 downto 0 do
    begin
      if PmSelectPerson.Items[I] = MiPreviousSelections then
      begin
        LatestPersons := False;
        LatestPersonsIndex := I;
      end;

      if LatestPersons then
        PmSelectPerson.Items.Remove(PmSelectPerson.Items[I]);

      if PmSelectPerson.Items[I] = MiPreviousSelectionsSeparator then
        LatestPersons := True;
    end;

    //add current persons
    PersonManager.FillLatestSelections(SelectedPersons);

    for J := 0 to FExtendedSearchPersons.Count - 1 do
    begin
      for I := 0 to SelectedPersons.Count - 1 do
      begin
        if SelectedPersons[I].ID = FExtendedSearchPersons[J].ID then
        begin
          SelectedPersons.DeleteAt(I);
          Break;
        end;
      end;
    end;

    for I := 0 to SelectedPersons.Count - 1 do
    begin
      MI := TMenuItem.Create(PmSelectPerson);
      MI.Tag := SelectedPersons[I].ID;
      MI.Caption := SelectedPersons[I].Name;
      MI.OnClick := SelectPersonClick;
      MI.ImageIndex := ImFacePopup.Add(SelectedPersons[I].CreatePreview(16, 16), nil);
      PmSelectPerson.Items.Insert(LatestPersonsIndex + 1, MI);
      Inc(LatestPersonsIndex);
    end;

    if SelectedPersons.Count = 0 then
    begin
      MiPreviousSelections.Visible := False;
      MiPreviousSelectionsSeparator.Visible := False;
    end else
    begin
      MiPreviousSelections.Visible := True;
      MiPreviousSelectionsSeparator.Visible := True;
    end;
  finally
    F(SelectedPersons);
  end;
end;

procedure TExplorerForm.SelectPersonClick(Sender: TObject);
var
  P: TPerson;
  PersonID: Integer;
begin
  P := TPerson.Create;
  try
    PersonID := TMenuItem(Sender).Tag;
    if PersonManager.FindPerson(PersonID, P) then
    begin
      AddWideSearchPerson(P);
      P := nil;
    end;
  finally
    F(P);
  end;
end;

procedure TExplorerForm.MiOtherPersonsClick(Sender: TObject);
var
  FormFindPerson: TFormFindPerson;
  P: TPerson;
  Result: Integer;
begin
  Application.CreateForm(TFormFindPerson, FormFindPerson);
  try
    P := nil;
    try
      Result := FormFindPerson.Execute(nil, P);
      if (P <> nil) and (Result = SELECT_PERSON_OK) then
      begin
        AddWideSearchPerson(P);
        P := nil;
      end;
    finally
      F(P);
    end;
  finally
    F(FormFindPerson);
  end;
end;

procedure TExplorerForm.MiPreviewPersonFindClick(Sender: TObject);
var
  Wl: TWebLink;
begin
  Wl := TWebLink(PmPreviewPersonItem.Tag);

  SetNewPathW(ExplorerPath(cPersonsPath + '\' + Wl.Text, EXPLORER_ITEM_PERSON), False);
end;

procedure TExplorerForm.MiPreviewPersonPropertiesClick(Sender: TObject);
var
  P: TPathItem;
  PL: TPathItemCollection;
  Wl: TWebLink;
begin
  Wl := TWebLink(PmPreviewPersonItem.Tag);

  P := PathProviderManager.CreatePathItem(cPersonsPath + '\' + Wl.Text);
  try
    if P <> nil then
      if P.Provider.SupportsFeature(PATH_FEATURE_PROPERTIES) then
      begin
        PL := TPathItemCollection.Create;
        try
          PL.Add(P);
          P.Provider.ExecuteFeature(Self, PL, PATH_FEATURE_PROPERTIES, nil);
        finally
          F(PL);
        end;
      end;
  finally
    F(P);
  end;
end;

procedure TExplorerForm.MiPreviewPersonUpdateAvatarClick(Sender: TObject);
var
  Wl: TWebLink;
begin
  Wl := TWebLink(PmPreviewPersonItem.Tag);
  if FImageViewer <> nil then
  begin
    FImageViewer.UpdateAvatar(Wl.Tag);
    DoSelectItem;
  end;
end;

procedure TExplorerForm.MiESGroupFindPicturesClick(Sender: TObject);
var
  Group: TGroup;
  Groups: TGroups;
begin
  Groups := EncodeGroups(WllExtendedSearchGroups.TagEx);

  if PmESGroup.Tag < 0 then
    Exit;

  if PmESGroup.Tag > Length(Groups) - 1 then
    Exit;

  Group := Groups[PmESGroup.Tag];
  SetNewPathW(ExplorerPath(cGroupsPath + '\' + Group.GroupName, EXPLORER_ITEM_GROUP), False);
end;

procedure TExplorerForm.MiESGroupPropertiesClick(Sender: TObject);
var
  Group: TGroup;
  Groups: TGroups;
  P: TPathItem;
  PL: TPathItemCollection;
begin

  Groups := EncodeGroups(WllExtendedSearchGroups.TagEx);

  if PmESGroup.Tag < 0 then
    Exit;

  if PmESGroup.Tag > Length(Groups) - 1 then
    Exit;

  Group := Groups[PmESGroup.Tag];
  P := PathProviderManager.CreatePathItem(cGroupsPath + '\' + Group.GroupName);
  try
    if P <> nil then
      if P.Provider.SupportsFeature(PATH_FEATURE_PROPERTIES) then
      begin
        PL := TPathItemCollection.Create;
        try
          PL.Add(P);
          P.Provider.ExecuteFeature(Self, PL, PATH_FEATURE_PROPERTIES, nil);
        finally
          F(PL);
        end;
      end;
  finally
    F(P);
  end;
end;

procedure TExplorerForm.MiESGroupRemoveClick(Sender: TObject);
var
  Group: TGroup;
  Groups: TGroups;
begin
  Groups := EncodeGroups(WllExtendedSearchGroups.TagEx);

  if PmESGroup.Tag < 0 then
    Exit;

  if PmESGroup.Tag > Length(Groups) - 1 then
    Exit;

  Group := Groups[PmESGroup.Tag];
  RemoveGroupFromGroups(Groups, Group);
  WllExtendedSearchGroups.TagEx := CodeGroups(Groups);
  ExtendedSearchInitGroups;
  PnESContainer.Refresh;
end;

procedure TExplorerForm.MiESPersonFindPicturesClick(Sender: TObject);
var
  Person: TPerson;
begin
  if PmESPerson.Tag < 0 then
    Exit;

  if PmESPerson.Tag > FExtendedSearchPersons.Count - 1 then
    Exit;

  Person := FExtendedSearchPersons[PmESPerson.Tag];
  SetNewPathW(ExplorerPath(cPersonsPath + '\' + Person.Name, EXPLORER_ITEM_PERSON), False);
end;

procedure TExplorerForm.MiESPersonPropertiesClick(Sender: TObject);
var
  Person: TPerson;
  P: TPathItem;
  PL: TPathItemCollection;
begin
  if PmESPerson.Tag < 0 then
    Exit;

  if PmESPerson.Tag > FExtendedSearchPersons.Count - 1 then
    Exit;

  Person := FExtendedSearchPersons[PmESPerson.Tag];
  P := PathProviderManager.CreatePathItem(cPersonsPath + '\' + Person.Name);
  try
    if P <> nil then
      if P.Provider.SupportsFeature(PATH_FEATURE_PROPERTIES) then
      begin
        PL := TPathItemCollection.Create;
        try
          PL.Add(P);
          P.Provider.ExecuteFeature(Self, PL, PATH_FEATURE_PROPERTIES, nil);
        finally
          F(PL);
        end;
      end;
  finally
    F(P);
  end;
end;

procedure TExplorerForm.MiESPersonRemoveFromListClick(Sender: TObject);
var
  Person: TPerson;
begin
  if PmESPerson.Tag < 0 then
    Exit;

  if PmESPerson.Tag > FExtendedSearchPersons.Count - 1 then
    Exit;

  Person := FExtendedSearchPersons[PmESPerson.Tag];
  FExtendedSearchPersons.Delete(PmESPerson.Tag);
  F(Person);

  ExtendedSearchInitPersons;
  PnESContainer.Refresh;
end;

procedure TExplorerForm.ExtendedSearchCheckEnabled;
var
  IsOptionsEnabled: Boolean;
begin
  IsOptionsEnabled := FSearchMode = EXPLORER_SEARCH_DATABASE;

  WlSearchRatingFrom.Enabled := IsOptionsEnabled;
  WlSearchRatingTo.Enabled := IsOptionsEnabled;
  WlSearchRatingFromValue.Enabled := IsOptionsEnabled;
  WlSearchRatingToValue.Enabled := IsOptionsEnabled;
  WlExtendedSearchDateFrom.Enabled := IsOptionsEnabled;
  WlExtendedSearchDateTo.Enabled := IsOptionsEnabled;
  WlExtendedSearchSortBy.Enabled := IsOptionsEnabled;
  WllExtendedSearchPersons.Enabled := IsOptionsEnabled;
  WllExtendedSearchGroups.Enabled := IsOptionsEnabled;
  WlExtendedSearchSortDescending.Enabled := IsOptionsEnabled;
  WlExtendedSearchOptions.Enabled := IsOptionsEnabled;
end;

procedure TExplorerForm.ExtendedSearchRealign;

  function DateToString(Date: TDateTime): string;
  begin
    if Date = MinDateTime then
      Exit(L('Any'));

    Result := DateToStr(Date);
  end;

begin
  if FExtendedSearchParams = nil then
    Exit;

  WlExtendedSearchDateFrom.Text := L('Date from') + ': ' + DateToString(FExtendedSearchParams.DateFrom);
  WlExtendedSearchDateTo.Text := L('Date to') + ': ' + DateToString(FExtendedSearchParams.DateTo);

  case FExtendedSearchParams.SortMode of
    dsmID:
     WlExtendedSearchSortBy.Text := L('Sort by ID');
    dsmName:
     WlExtendedSearchSortBy.Text := L('Sort by name');
    dsmRating:
     WlExtendedSearchSortBy.Text := L('Sort by rating');
    dsmDate:
     WlExtendedSearchSortBy.Text := L('Sort by date');
    dsmFileSize:
     WlExtendedSearchSortBy.Text := L('Sort by file size');
    dsmImageSize:
     WlExtendedSearchSortBy.Text := L('Sort by image size');
  end;

  WlSearchRatingFrom.RefreshBuffer(True);
  WlSearchRatingTo.RefreshBuffer(True);
  WlSearchRatingFromValue.Left := WlSearchRatingFrom.AfterRight(7);
  WlSearchRatingToValue.Left := WlSearchRatingTo.AfterRight(5);

  WlSearchRatingFrom.Top := EdExtendedSearchText.AfterTop(10);
  WlSearchRatingFromValue.Top := EdExtendedSearchText.AfterTop(12);
  WlSearchRatingTo.Top := WlSearchRatingFrom.AfterTop(5);
  WlSearchRatingToValue.TOp := WlSearchRatingFrom.AfterTop(7);
  BvRating.Top := WlSearchRatingToValue.AfterTop(2);

  WllExtendedSearchPersons.ReallignList;
  WllExtendedSearchPersons.AutoHeight(300);
  WllExtendedSearchPersons.Top := BvRating.AfterTop(5);

  BvPersons.Top := WllExtendedSearchPersons.AfterTop(5);

  WllExtendedSearchGroups.ReallignList;
  WllExtendedSearchGroups.AutoHeight(300);
  WllExtendedSearchGroups.Top := BvPersons.AfterTop(5);

  BvGroups.Top := WllExtendedSearchGroups.AfterTop(5);

  WlExtendedSearchDateFrom.Top := BvGroups.AfterTop(5);
  WlExtendedSearchDateTo.Top := WlExtendedSearchDateFrom.AfterTop(3);
  WlExtendedSearchSortDescending.Top := WlExtendedSearchDateTo.AfterTop(7);
  WlExtendedSearchSortBy.Top := WlExtendedSearchDateTo.AfterTop(7);

  BtnSearch.Top := WlExtendedSearchSortBy.AfterTop(7);
  WlExtendedSearchOptions.Top := BtnSearch.BoundsRect.Bottom - WlExtendedSearchOptions.Height;
end;

procedure TExplorerForm.PmESOptionsPopup(Sender: TObject);
begin
  MiESShowHidden.Checked := FExtendedSearchParams.ShowHidden;
  MiESShowPrivate.Checked := FExtendedSearchParams.ShowPrivate;
end;

procedure TExplorerForm.PmESSortingPopup(Sender: TObject);
begin
  MiESSortByID.Checked := FExtendedSearchParams.SortMode = dsmID;
  MiESSortByName.Checked := FExtendedSearchParams.SortMode = dsmName;
  MiESSortByDate.Checked := FExtendedSearchParams.SortMode = dsmDate;
  MiESSortByRating.Checked := FExtendedSearchParams.SortMode = dsmRating;
  MiESSortByFileSize.Checked := FExtendedSearchParams.SortMode = dsmFileSize;
  MiESSortByImageSize.Checked := FExtendedSearchParams.SortMode = dsmImageSize;
end;

procedure TExplorerForm.ExtendedSearchShow;
begin
  TbSearch.Down := True;
  TbSearch.Tag := -1;
  TbSearchClick(Self);
end;

procedure TExplorerForm.TsDetailedSearchResize(Sender: TObject);
begin
  WllExtendedSearchGroups.ReallignList;
  WllExtendedSearchGroups.AutoHeight(300);
  ExtendedSearchRealign;
end;

procedure TExplorerForm.BtnSelectDatePopupClick(Sender: TObject);
var
  Caller: TControl;

  function SelectedDate: TDateTime;
  begin
    if Sender = BtnSelectDatePopupReset then
      Exit(MinDateTime);

    Result := McDateSelectPopup.Date;
  end;

begin
  Caller := TControl(PnSelectDatePopup.Tag);
  PnSelectDatePopup.Hide;
  if Caller = WlExtendedSearchDateFrom then
    FExtendedSearchParams.DateFrom := SelectedDate;
  if Caller = WlExtendedSearchDateTo then
    FExtendedSearchParams.DateTo := SelectedDate;

  ExtendedSearchRealign;
end;

procedure TExplorerForm.WlSearchRatingFromClick(Sender: TObject);
begin
  RtPopupRating.Tag := 0;
  RtPopupRating.Left := WlSearchRatingFromValue.FormBounds.Left;
  RtPopupRating.Top := WlSearchRatingFromValue.FormBounds.Top;
  RtPopupRating.Rating := FExtendedSearchParams.RatingFrom;
  RtPopupRating.Show;
  RtPopupRating.Tag := NativeInt(WlSearchRatingFromValue);
end;

procedure TExplorerForm.WlSearchRatingToClick(Sender: TObject);
begin
  RtPopupRating.Tag := 0;
  RtPopupRating.Left := WlSearchRatingToValue.FormBounds.Left;
  RtPopupRating.Top := WlSearchRatingToValue.FormBounds.Top;
  RtPopupRating.Rating := FExtendedSearchParams.RatingTo;
  RtPopupRating.Show;
  RtPopupRating.Tag := NativeInt(WlSearchRatingToValue);
end;

procedure TExplorerForm.RtPopupRatingRating(Sender: TObject; Rating: Integer);
const
  RATING_ICONS: array[0..5] of string = ('TRATING_DEL', 'TRATING_1', 'TRATING_2',
                  'TRATING_3', 'TRATING_4', 'TRATING_5');
var
  Control: TControl;
begin
  Control := TControl(RtPopupRating.Tag);
  if Control = WlSearchRatingFromValue then
  begin
    FExtendedSearchParams.RatingFrom := Rating;
    WlSearchRatingFromValue.LoadFromResource(RATING_ICONS[Rating]);
  end;
  if Control = WlSearchRatingToValue then
  begin
    FExtendedSearchParams.RatingTo := Rating;
    WlSearchRatingToValue.LoadFromResource(RATING_ICONS[Rating]);
  end;
  RtPopupRating.Hide;
end;

procedure TExplorerForm.ReallignEditBoxes;
begin
  LbEditKeywords.Top := WllGroups.BoundsRect.Bottom + 5;
  MemKeyWords.Top := LbEditKeywords.BoundsRect.Bottom + 3;
  LbEditComments.Top := MemKeyWords.BoundsRect.Bottom + 3;
  MemComments.Top := LbEditComments.BoundsRect.Bottom + 3;
  BtnSaveInfo.Top := MemComments.BoundsRect.Bottom + 5;
end;

procedure TExplorerForm.MemCommentsChange(Sender: TObject);
begin
  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.MemCommentsEnter(Sender: TObject);
begin
  BeginScreenUpdate(TsInfo.Handle);
  try
    MemComments.Height := 100;
    MemKeyWords.Height := 50;
    ReallignEditBoxes;
  finally
    EndScreenUpdate(TsInfo.Handle, False);
  end;
end;

procedure TExplorerForm.MemKeyWordsChange(Sender: TObject);
begin
  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.MemKeyWordsEnter(Sender: TObject);
begin
  BeginScreenUpdate(TsInfo.Handle);
  try
    MemComments.Height := 50;
    MemKeyWords.Height := 100;

    ReallignEditBoxes;
  finally
    EndScreenUpdate(TsInfo.Handle, False);
  end;
end;

procedure TExplorerForm.DteDateChange(Sender: TObject);
begin
  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.DteTimeChange(Sender: TObject);
begin
  BtnSaveInfo.Enabled := True;
end;

procedure TExplorerForm.DteTimeEnter(Sender: TObject);
begin
  BeginScreenUpdate(TsInfo.Handle);
  try
    MemComments.Height := 50;
    MemKeyWords.Height := 50;

    ReallignEditBoxes;
  finally
    EndScreenUpdate(TsInfo.Handle, False);
  end;
end;

procedure TExplorerForm.GroupClick(Sender: TObject);
var
  KeyWords, Groups: string;
  WL: TWebLink;
  P: TPoint;
begin
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    P := Point(Wl.Left, Wl.BoundsRect.Bottom);
    P := Wl.Parent.ClientToScreen(P);

    PmInfoGroup.Tag := NativeInt(WL);
    PmInfoGroup.Popup(P.X, P.Y);
  end else
  begin
    KeyWords := MemKeyWords.Text;
    Groups := FSelectedInfo.Groups;
    GroupsSelectForm.Execute(Groups, KeyWords);
    FSelectedInfo.Groups := Groups;

    PostMessage(Handle, FReloadGroupsMessage, 0, 0);

    MemKeyWords.Text := KeyWords;
    BtnSaveInfo.Enabled := True;
  end;
end;

procedure TExplorerForm.DisableInfoEditor;
begin
  FLeftTabs := FLeftTabs - [eltsInfo];
end;

procedure TExplorerForm.BtnSaveInfoClick(Sender: TObject);
var
  UserInput: TUserDBInfoInput;

  function ReadCHDate: Boolean;
  begin
    Result := DteDate.Checked and
        ((FFilesInfo.StatDate <> DteDate.DateTime) or FFilesInfo.IsVariousDate);
  end;

  function ReadCHTime: Boolean;
  var
    VarTime: Boolean;
  begin
    VarTime := Abs(TimeOf(FFilesInfo.StatTime) - TimeOf(DteTime.Time)) > 1 / (24 * 60 * 60 * 3);
    Result := DteTime.Checked and (VarTime or FFilesInfo.IsVariousTime);
  end;

begin
  UserInput := TUserDBInfoInput.Create;
  try

    UserInput.Keywords := MemKeyWords.Text;
    UserInput.Groups := FSelectedInfo.Groups;
    UserInput.IsCommentChanged := not MemComments.ReadOnly;
    UserInput.Comment := MemComments.Text;
    UserInput.IsLinksChanged := False;
    UserInput.Links := CodeLinksInfo(FEditorInfo.CommonLinks);
    UserInput.IsIncludeChanged := False;
    UserInput.Include := FEditorInfo.StatInclude;
    UserInput.IsRatingChanged := not ReRating.IsLayered;
    UserInput.Rating := ReRating.Rating;

    UserInput.IsDateChanged := ReadCHDate;
    UserInput.IsDateChecked := DteDate.Checked;
    UserInput.Date := DateOf(DteDate.Date);

    UserInput.IsTimeChanged := ReadCHTime;
    UserInput.IsTimeChecked := DteTime.Checked;
    UserInput.Time := TimeOf(DteTime.Date);

    BtnSaveInfo.SetEnabledEx(False);
    Enabled := False;
    try
      if (FEditorInfo.Count = 1) and (FEditorInfo[0].ID > 0) then
        UpdateDBRecordWithUserInfo(Self, FEditorInfo[0], UserInput)
      else
        BatchUpdateDBInfo(Self, FEditorInfo, UserInput);
    finally
      Enabled := True;
    end;
  finally
    F(UserInput);
  end;
end;

procedure TExplorerForm.BigSizeCallBack(Sender: TObject; SizeX, SizeY: integer);
var
  SelectedVisible: Boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible := IsSelectedVisible;
    FPictureSize := SizeX;
    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;

    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);

    if SelectedVisible then
    begin
      ElvMain.Selection.First.MakeVisible(EmvTop);
    end;
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TExplorerForm.MapCD1Click(Sender: TObject);
var
  Info: TCDIndexInfo;
  Dir : string;
begin
  Info := TCDIndexMapping.ReadMapFile(FFilesInfo[PmItemPopup.Tag].FileName);

  if Info.Loaded then
  begin
    Dir := ExtractFilePath(FFilesInfo[PmItemPopup.Tag].FileName);
    CDMapper.AddCDMapping(string(Info.CDLabel), Dir, False);
  end else
  begin
    MessageBoxDB(Handle, Format(L('Unable to find file %s by address "%s"'), [C_CD_MAP_FILE, FFilesInfo[PmItemPopup.Tag].FileName]),
      L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
end;

procedure TExplorerForm.ToolBarMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Application.HintHidePause < 5000 then
    Application.HintHidePause := 5000;
end;

function TExplorerForm.TreeView: TPathProvideTreeView;
begin
  if FShellTreeView = nil then
  begin
    FShellTreeView := TPathProvideTreeView.Create(Self);
    FShellTreeView.Parent := TsExplorer;
    FShellTreeView.Align := AlClient;
    FShellTreeView.LoadHomeDirectory(Self);
    FShellTreeView.OnGetPopupMenu := PathTreeViewGetPopupMenu;
    FShellTreeView.OnSelectPathItem := PathTreeViewChange;
  end;

  Result := FShellTreeView;
end;

constructor TExplorerForm.Create(AOwner: TComponent;
  GoToLastSavedPath: Boolean);
begin
  FSelectedInfo.GeoLocation := nil;
  FWebJSContainer := nil;
  TPrivateHelper.Instance.Init;
  FFilesInfo := TExplorerFileInfos.Create;
  FShellTreeView := nil;
  FormLoadEnd := False;
  NoLockListView := False;
  FPictureSize := ThImageSize;
  FCanPasteFromClipboard := False;
  ElvMain := nil;
  FBitmapImageList := TBitmapImageList.Create;
  FHistory := TStringsHistoryW.Create;
  UpdatingList := False;
  GlobalLock := False;
  NotSetOldPath := True;
  FChangeHistoryOnChPath := True;
  FGoToLastSavedPath := GoToLastSavedPath;
  FSelectedItem := nil;
  FIsPanaramio := False;
  inherited Create(AOwner);
end;

procedure TExplorerForm.LoadIcons;
var
  I: Integer;

  procedure AddGrayIcon(ImageList: TImageList; Icon: HIcon);
  var
    LBitmap: TLayeredBitmap;
  begin
    LBitmap := TLayeredBitmap.Create;
    try
      LBitmap.LoadFromHIcon(Icon, ImageList.Width, ImageList.Height);
      LBitmap.GrayScale;
      ImlPreview.Add(LBitmap, nil);
    finally
      F(LBitmap);
    end;
  end;

begin
  PmItemPopup.Images := DBKernel.ImageList;
  PmListPopup.Images := DBKernel.ImageList;
  PmLinkOptions.Images := DBKernel.ImageList;
  ToolBarBottom.Images := DBKernel.ImageList;
  PmInfoGroup.Images := DBKernel.ImageList;

  ToolBarBottom.DisableToolBarForButtons;
  TbbPlay.ImageIndex := DB_IC_SLIDE_SHOW;
  TbbEncrypt.ImageIndex := DB_IC_CRYPTIMAGE;
  TbbResize.ImageIndex := DB_IC_RESIZE;
  TbbConvert.ImageIndex := DB_IC_CONVERT;
  TbbCrop.ImageIndex := DB_IC_CROP;
  TbbPrint.ImageIndex := DB_IC_PRINTER;
  TbbEditor.ImageIndex := DB_IC_IMEDITOR;
  TbbGeo.ImageIndex := DB_IC_MAP_MARKER;
  TbbRename.ImageIndex := DB_IC_RENAME;
  TbbProperties.ImageIndex := DB_IC_PROPERTIES;
  TbbShare.ImageIndex := DB_IC_PHOTO_SHARE;
  TbbOpenDirectory.ImageIndex := DB_IC_DIRECTORY;
  ToolBarBottom.EnableToolBarForButtons;

  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_RATING_STAR + 1]);
  for I := 1 to 5 do
    ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_RATING_1 + I]);

  AddGrayIcon(ImlPreview, UnitDBKernel.Icons[DB_IC_RATING_STAR + 1]);
  for I := 1 to 5 do
    AddGrayIcon(ImlPreview, UnitDBKernel.Icons[DB_IC_RATING_1 + I]);

  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_PREVIOUS + 1]);
  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_NEXT + 1]);
  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_ROTATED_90 + 1]);
  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_ROTATED_270 + 1]);
  ImageList_AddIcon(ImlPreview.Handle, UnitDBKernel.Icons[DB_IC_SLIDE_SHOW + 1]);

  ToolBarPreview.DisableToolBarForButtons;
  TbPreviewPrevious.ImageIndex := 11 + 1;
  TbPreviewNext.ImageIndex := 11 + 2;
  TbPreviewRotateCW.ImageIndex := 11 + 3;
  TbPreviewRotateCCW.ImageIndex := 11 + 4;
  TbPreviewOpen.ImageIndex := 11 + 5;
  ToolBarPreview.EnableToolBarForButtons;

  Shell1.ImageIndex := DB_IC_SHELL;
  SlideShow1.ImageIndex := DB_IC_SLIDE_SHOW;
  DBitem1.ImageIndex := DB_IC_NOTES;
  Copy1.ImageIndex := DB_IC_COPY;
  Delete1.ImageIndex := DB_IC_DELETE_FILE;
  Rename1.ImageIndex := DB_IC_RENAME;
  Properties1.ImageIndex := DB_IC_PROPERTIES;
  AddFile1.ImageIndex := DB_IC_NEW;
  Open1.ImageIndex := DB_IC_EXPLORER;
  Open2.ImageIndex := DB_IC_EXPLORER;
  SelectAll1.ImageIndex := DB_IC_SELECTALL;
  Cut2.ImageIndex := DB_IC_CUT;
  Paste1.ImageIndex := DB_IC_PASTE;
  MiImportImages.ImageIndex := DB_IC_PICTURES_IMPORT;

  New1.ImageIndex := DB_IC_NEW_SHELL;
  Directory1.ImageIndex := DB_IC_NEW_DIRECTORY;
  Refresh1.ImageIndex := DB_IC_REFRESH_THUM;

  Addfolder1.ImageIndex := DB_IC_ADD_FOLDER;
  MakeNew1.ImageIndex := DB_IC_NEW_SHELL;
  Refresh2.ImageIndex := DB_IC_REFRESH_THUM;
  Exit2.ImageIndex := DB_IC_EXIT;
  TextFile1.ImageIndex := DB_IC_TEXT_FILE;
  ShowUpdater1.ImageIndex := DB_IC_BOX;

  OpenInNewWindow1.ImageIndex := DB_IC_FOLDER;
  OpeninNewWindow2.ImageIndex := DB_IC_FOLDER;
  NewWindow1.ImageIndex := DB_IC_FOLDER;

  PmTreeView.Images := DBKernel.ImageList;

  MiTreeViewOpenInNewWindow.ImageIndex := DB_IC_EXPLORER;
  MiTreeViewRefresh.ImageIndex := DB_IC_REFRESH_THUM;

  CryptFile1.ImageIndex := DB_IC_CRYPTIMAGE;
  ResetPassword1.ImageIndex := DB_IC_DECRYPTIMAGE;
  EnterPassword1.ImageIndex := DB_IC_PASSWORD;
  Convert1.ImageIndex := DB_IC_CONVERT;
  Resize1.ImageIndex := DB_IC_RESIZE;
  Directory2.ImageIndex := DB_IC_NEW_DIRECTORY;
  TextFile2.ImageIndex := DB_IC_TEXT_FILE;
  AsEXIF1.ImageIndex := DB_IC_ROTATE_MAGIC;
  RotateCCW1.ImageIndex := DB_IC_ROTATED_270;
  RotateCW1.ImageIndex := DB_IC_ROTATED_90;
  Rotateon1801.ImageIndex := DB_IC_ROTATED_180;
  Rotate1.ImageIndex := DB_IC_ROTATED_0;
  SetasDesktopWallpaper1.ImageIndex := DB_IC_WALLPAPER;
  Stretch1.ImageIndex := DB_IC_WALLPAPER;
  Center1.ImageIndex := DB_IC_WALLPAPER;
  Tile1.ImageIndex := DB_IC_WALLPAPER;
  RefreshID1.ImageIndex := DB_IC_REFRESH_ID;
  Othertasks1.ImageIndex := DB_IC_OTHER_TOOLS;
  ExportImages1.ImageIndex := DB_IC_EXPORT_IMAGES;
  ImageEditor2.ImageIndex := DB_IC_IMEDITOR;
  Print1.ImageIndex := DB_IC_PRINTER;
  Copywithfolder1.ImageIndex := DB_IC_COPY;

  MiShelf.ImageIndex := DB_IC_SHELF;
  MiShare.ImageIndex := DB_IC_PHOTO_SHARE;
  MiDisplayOnMap.ImageIndex := DB_IC_MAP_MARKER;

  Sortby1.ImageIndex := DB_IC_SORT;
  SetFilter1.ImageIndex := DB_IC_FILTER;

  Nosorting1.ImageIndex := DB_IC_DELETE_INFO;
  FileName1.ImageIndex := DB_IC_PROPERTIES;
  Rating1.ImageIndex := DB_IC_RATING_STAR;
  Size1.ImageIndex := DB_IC_RESIZE;
  Type1.ImageIndex := DB_IC_ATYPE;
  Modified1.ImageIndex := DB_IC_CLOCK;
  MakeFolderViewer1.ImageIndex := DB_IC_SAVE_AS_TABLE;
  MakeFolderViewer2.ImageIndex := DB_IC_SAVE_AS_TABLE;
  Number1.ImageIndex := DB_IC_RENAME;

  RatingPopupMenu.Images := DBKernel.ImageList;

  N00.ImageIndex := DB_IC_DELETE_INFO;
  N01.ImageIndex := DB_IC_RATING_1;
  N02.ImageIndex := DB_IC_RATING_2;
  N03.ImageIndex := DB_IC_RATING_3;
  N04.ImageIndex := DB_IC_RATING_4;
  N05.ImageIndex := DB_IC_RATING_5;

  StenoGraphia1.ImageIndex := DB_IC_STENO;
  AddHiddenInfo1.ImageIndex := DB_IC_STENO;
  ExtractHiddenInfo1.ImageIndex := DB_IC_DESTENO;

  MapCD1.ImageIndex := DB_IC_CD_MAPPING;

  MiInfoGroupFind.ImageIndex := DB_IC_SEARCH;
  MiInfoGroupRemove.ImageIndex := DB_IC_DELETE_INFO;
  MiInfoGroupProperties.ImageIndex := DB_IC_PROPERTIES;

  if not IsWindows8 then
    TLoad.Instance.RequiredDBKernelIcons;

  SlideShowLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SLIDE_SHOW + 1]);
  ShellLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SHELL + 1]);
  CopyToLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_COPY + 1]);
  MoveToLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CUT + 1]);
  RenameLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_RENAME + 1]);
  PropertiesLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PROPERTIES + 1]);
  DeleteLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);
  WlClear.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);
  AddLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_NEW + 1]);
  RefreshLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_REFRESH_THUM + 1]);
  ImageEditorLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_IMEDITOR + 1]);
  WlGeoLocation.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MAP_MARKER + 1]);
  PrintLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PRINTER + 1]);
  MyPicturesLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_PICTURES + 1]);
  MyDocumentsLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_DOCUMENTS + 1]);
  MyComputerLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_COMPUTER + 1]);
  DesktopLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DESKTOPLINK + 1]);
  WlCreateObject.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_NEW_SHELL + 1]);
  WlGoToShelf.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SHELF + 1]);

  WlResize.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_RESIZE + 1]);
  WlConvert.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CONVERT + 1]);
  WlCrop.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CROP + 1]);
  WlImportPictures.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PICTURES_IMPORT + 1]);
  WlShare.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PHOTO_SHARE + 1]);
end;

destructor TExplorerForm.Destroy;
begin
  FImageViewer := nil;
  F(FHistory);
  F(FFilesInfo);
  F(RefreshIDList);
  ExplorerUpdateManager.CleanUp(Self);
  inherited;
end;

initialization
  PERegisterThreadEvent := RegisterPathEditThread;
  PEUnRegisterThreadEvent := UnRegisterPathEditThread;
  PathProvider_UpdateText := PE_PathProvider_UpdateText;
  PathProvider_UpdateImage := PEPathProvider_UpdateImage;

end.
