unit ExplorerUnit;

interface

uses
  acDlgSelect, CommCtrl, ActiveX, ExplorerTypes, DBCMenu, UnitDBKernel, UnitINI,
  ShellApi, dolphin_db, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, ComObj, Registry, PrintMainForm, uScript, UnitScripts,
  Dialogs, ComCtrls, ShellCtrls, ImgList, Menus, ExtCtrls, ToolWin, Buttons,
  ImButton, StdCtrls, SaveWindowPos, AppEvnts, WebLink, UnitBitmapImageList,
  Network, GraphicCrypt, UnitCrypting, DropSource, DragDropFile, DragDrop,
  DropTarget, ScPanel, AddSessionPasswordUnit, uGOM,
  ShellContextMenu, ShlObj, Clipbrd, GraphicsCool, uShellIntegration,
  ProgressActionUnit, GraphicsBaseTypes, Math, DB, CommonDBSupport,
  EasyListview, MPCommonUtilities, MPCommonObjects,
  UnitRefreshDBRecordsThread, UnitPropeccedFilesSupport, uPrivateHelper,
  UnitCryptingImagesThread, uVistaFuncs, wfsU, UnitDBDeclare, pngimage,
  UnitDBFileDialogs, UnitDBCommonGraphics, UnitFileExistsThread,
  UnitDBCommon, UnitCDMappingSupport, SyncObjs, uResources, uListViewUtils,
  uFormListView, uAssociatedIcons, uLogger, uConstants, uTime, uFastLoad,
  uFileUtils, uDBPopupMenuInfo, uDBDrawing, uW7TaskBar, uMemory, LoadingSign,
  uPNGUtils, uGraphicUtils, uDBBaseTypes, uDBTypes, uSysUtils, uRuntime, uDBUtils;

type
  TExplorerForm = class(TListViewForm)
    SizeImageList: TImageList;
    PmItemPopup: TPopupMenu;
    SlideShow1: TMenuItem;
    Properties1: TMenuItem;
    Shell1: TMenuItem;
    Copy1: TMenuItem;
    Rename1: TMenuItem;
    Delete1: TMenuItem;
    DBitem1: TMenuItem;
    Splitter1: TSplitter;
    PmListPopup: TPopupMenu;
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
    CloseButtonPanel: TPanel;
    Button1: TButton;
    PropertyPanel: TPanel;
    Refresh2: TMenuItem;
    OpenInNewWindow1: TMenuItem;
    Exit2: TMenuItem;
    N2: TMenuItem;
    MakeNew1: TMenuItem;
    Copy2: TMenuItem;
    SaveWindowPos1: TSaveWindowPos;
    ShowUpdater1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    NewWindow1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Cut2: TMenuItem;
    Paste2: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    StatusBar1: TStatusBar;
    GoToSearchWindow1: TMenuItem;
    OpeninSearchWindow1: TMenuItem;
    PopupMenu8: TPopupMenu;
    OpeninExplorer1: TMenuItem;
    AddFolder2: TMenuItem;
    ToolBarNormalImageList: TImageList;
    CoolBar1: TCoolBar;
    ToolBar2: TToolBar;
    Label2: TLabel;
    PopupMenuBack: TPopupMenu;
    PopupMenuForward: TPopupMenu;
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
    DropFileTarget1: TDropFileTarget;
    DropFileSourceMain: TDropFileSource;
    DragImageList: TImageList;
    DropFileTarget2: TDropFileTarget;
    HelpTimer: TTimer;
    ImageEditor2: TMenuItem;
    N13: TMenuItem;
    Othertasks1: TMenuItem;
    ExportImages1: TMenuItem;
    Print1: TMenuItem;
    PmLinkOptions: TPopupMenu;
    OpeninNewWindow2: TMenuItem;
    Open2: TMenuItem;
    TextFile1: TMenuItem;
    Directory2: TMenuItem;
    TextFile2: TMenuItem;
    Copywithfolder1: TMenuItem;
    PmDragMode: TPopupMenu;
    Copy4: TMenuItem;
    Move1: TMenuItem;
    N15: TMenuItem;
    Cancel1: TMenuItem;
    SelectTimer: TTimer;
    N17: TMenuItem;
    SendTo1: TMenuItem;
    N18: TMenuItem;
    View2: TMenuItem;
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
    ImButton1: TImButton;
    ToolButton9: TToolButton;
    MakeFolderViewer1: TMenuItem;
    Number1: TMenuItem;
    CbPathEdit: TComboBoxEx;
    AutoCompliteTimer: TTimer;
    RatingPopupMenu1: TPopupMenu;
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
    Label1: TLabel;
    ImageEditorLink: TWebLink;
    ImPreview: TImage;
    IDLabel: TLabel;
    DimensionsLabel: TLabel;
    DesktopLink: TWebLink;
    DeleteLink: TWebLink;
    DBInfoLabel: TLabel;
    CopyToLink: TWebLink;
    AddLink: TWebLink;
    AccessLabel: TLabel;
    PopupMenu5: TPopupMenu;
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
    N21: TMenuItem;
    StenoGraphia1: TMenuItem;
    AddHiddenInfo1: TMenuItem;
    ExtractHiddenInfo1: TMenuItem;
    CoolBar2: TCoolBar;
    ToolBar1: TToolBar;
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
    TbZoomIn: TToolButton;
    TbZoomOut: TToolButton;
    ToolButton12: TToolButton;
    TbSearch: TToolButton;
    ToolButton16: TToolButton;
    TbOptions: TToolButton;
    TbStop: TToolButton;
    ToolButton20: TToolButton;
    PopupMenuZoomDropDown: TPopupMenu;
    MapCD1: TMenuItem;
    LsMain: TLoadingSign;
    AsEXIF1: TMenuItem;
    N3: TMenuItem;
    Procedure LockItems;
    Procedure UnLockItems;
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SlideShow1Click(Sender: TObject);
    procedure Shell1Click(Sender: TObject);
    procedure Properties1Click(Sender: TObject);
    procedure PmItemPopupPopup(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure AddFile1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Edited(Sender: TObject; Item: TEasyItem;
      var S: String);
    procedure CMMOUSELEAVE( var Message: TWMNoParams); message CM_MOUSELEAVE;
    procedure HintTimerTimer(Sender: TObject);
    function hintrealA(Info: TDBPopupMenuInfoRecord): Boolean;
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    Procedure SetInfoToItem(info : TOneRecordInfo; FileGUID: TGUID);
    procedure SpeedButton3Click(Sender: TObject);
    Procedure BeginUpdate();
    Procedure EndUpdate();
    procedure Open1Click(Sender: TObject);
    function GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
    Function ListView1Selected : TEasyItem;
    Function ItemAtPos(X,Y : integer): TEasyItem;
    procedure CbPathEditKeyPress(Sender: TObject; var Key: Char);
    procedure Exit1Click(Sender: TObject);
    procedure PageScroller2Resize(Sender: TObject);
    procedure CloseButtonPanelResize(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure ListView1SelectItem(Sender: TObject;
     Item: TEasyItem; Selected: Boolean);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SelectAll1Click(Sender: TObject);
    procedure Refresh2Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    Procedure DoExit; override;
    procedure Addfolder1Click(Sender: TObject);
    Procedure RefreshItem(Number : Integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    Procedure HistoryChanged(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView1Exit(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure RefreshItemByID(ID : Integer);
    procedure RefreshItemByName(Name : String);
    procedure MakeNewFolder1Click(Sender: TObject);
    procedure Copy2Click(Sender: TObject);
    procedure OpenInNewWindow1Click(Sender: TObject);
    Function GetCurrentPath : String;
    Procedure SetPath(Path : String);
    procedure ShowUpdater1Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
     Procedure Select(Item : TEasyItem; GUID : TGUID);
    procedure ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include : boolean; Big : boolean = false);
    procedure ReplaceIcon(Icon: TIcon; FileGUID: TGUID; Include : boolean);
    function AddItem(FileGUID: TGUID; LockItems : boolean = true) : TEasyItem;
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Back1Click(Sender: TObject);
    procedure Forward1Click(Sender: TObject);
    procedure Up1Click(Sender: TObject);
    procedure DeleteIndex1Click(Sender: TObject);
    procedure DeleteItemWithIndex(Index : Integer);
    Procedure DeleteFiles(ToRecycle : Boolean);
    Procedure DirectoryChanged(Sender : TObject; SID : TGUID; pInfo: TInfoCallBackDirectoryChangedArray);
    Procedure LoadInfoAboutFiles(Info : TExplorerFileInfos);
    Procedure AddInfoAboutFile(Info : TExplorerFileInfos);
    function FileNeededW(FileSID : TGUID) : Boolean;  //для больших имаг
    procedure AddBitmap(Bitmap: TBitmap; FileGUID: TGUID);
    procedure AddIcon(Icon: TIcon; SelfReleased : Boolean; FileGUID: TGUID);
    Function ItemIndexToMenuIndex(Index : Integer) : Integer;
    Function MenuIndexToItemIndex(Index : Integer) : Integer;
    procedure WaitForUnLock;
    Procedure SetOldPath(Path : String);
    procedure FormShow(Sender: TObject);
//    procedure SetInfoToItemW(info : TOneRecordInfo; Number : Integer);
    procedure NewWindow1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure PmListPopupPopup(Sender: TObject);
    procedure Cut2Click(Sender: TObject);
    procedure ShowProgress();
    procedure HideProgress();
    procedure SetProgressMax(Value : Integer);
    procedure SetProgressPosition(Value : Integer);
    procedure SetStatusText(Text : String);
    procedure SetNewFileNameGUID(FileGUID : TGUID);
    procedure Button1Click(Sender: TObject);
    Procedure SetPanelInfo(Info : TOneRecordInfo; FileGUID : TGUID);
    Procedure SetPanelImage(Image : TBitmap; FileGUID : TGUID);
    procedure ImPreviewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure PropertyPanelResize(Sender: TObject);
    procedure ReallignInfo;
    procedure ScriptExecuted(Sender : TObject);
    procedure CopyToLinkClick(Sender: TObject);
    procedure MoveToLinkClick(Sender: TObject);
    procedure Paste2Click(Sender: TObject);
    procedure ExplorerPanel1Click(Sender: TObject);
    Procedure SetNewPath(Path : String; Explorer : Boolean);
    procedure GoToSearchWindow1Click(Sender: TObject);
    procedure ImPreviewDblClick(Sender: TObject);
    procedure Copy3Click(Sender: TObject);
    procedure Cut3Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure DBManager1Click(Sender: TObject);
    procedure DeleteLinkClick(Sender: TObject);
    function AddItemW(Caption : string; FileGUID: TGUID) : TEasyItem;
    procedure SetSelected(NewSelected: TEasyItem);
    procedure PropertiesLinkClick(Sender: TObject);
    procedure SlideShowLinkClick(Sender: TObject);
    procedure InfoPanel1Click(Sender: TObject);
    function GetThreadsCount : Integer;
    procedure Paste3Click(Sender: TObject);
    procedure ShowOnlyCommon1Click(Sender: TObject);
    procedure ShowPrivate1Click(Sender: TObject);
    procedure OpeninSearchWindow1Click(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure PopupMenu8Popup(Sender: TObject);
    procedure OpeninExplorer1Click(Sender: TObject);
    procedure AddFolder2Click(Sender: TObject);
    procedure AddLinkClick(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure SetNewPathW(WPath : TExplorerPath; Explorer : Boolean; FileMask : string = '');
    function GetCurrentPathW : TExplorerPath;
    procedure RefreshLinkClick(Sender: TObject);
    procedure DoBack;
    procedure JumpHistoryClick(Sender: TObject);
    procedure DragTimerTimer(Sender: TObject);
    procedure DragEnter(Sender: TObject);
    Procedure DragLeave(Sender: TObject);
    procedure Activation1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure ContactWithAuthor1Click(Sender: TObject);
    procedure ResetPassword1Click(Sender: TObject);
    procedure CryptFile1Click(Sender: TObject);
    procedure Addsessionpassword1Click(Sender: TObject);
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
    procedure RefreshItemA(Number: Integer);
    procedure RefreshItemByNameA(Name: String);
    procedure DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure DropFileTarget1Enter(Sender: TObject;
      ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure DropFileTarget1Leave(Sender: TObject);
    procedure SetStringPath(Path : String; ChangeTreeView : Boolean);
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
    procedure MyPicturesLinkContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Open2Click(Sender: TObject);
    procedure OpeninNewWindow2Click(Sender: TObject);
    procedure TextFile2Click(Sender: TObject);
    procedure GetPhotosClick(Sender: TObject);
    procedure GetPhotosFromDrive1Click(Sender: TObject);
    procedure Copywithfolder1Click(Sender: TObject);
    procedure Copy4Click(Sender: TObject);
    procedure NewPanel1Click(Sender: TObject);
    procedure SelectTimerTimer(Sender: TObject);
    procedure SendTo1Click(Sender: TObject);
    procedure View2Click(Sender: TObject);
    procedure RemoveUpdateID(ID : Integer; CID : TGUID);
    procedure AddUpdateID(ID : Integer);
    procedure Reload;
    function FileNameToID(FileName: string): integer;
    function UpdatingNow(ID : Integer) : boolean;
    function GetVisibleItems : TStrings;
    procedure LoadStatusVariables(Sender: TObject);
    function CanUp : boolean;
    function SelCount : integer;
    function SelectedIndex : integer;
    function GetSelectedType : integer;
    function CanCopySelection : boolean;
    function GetPath : string;
    function GetPathByIndex(index : integer) : string;
    function GetSelectedFiles : TArrayOfString;
    function CanPasteInSelection : boolean;
    procedure CloseWindow(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    function ExplorerType : boolean;
    function ShowPrivate : boolean;
    procedure ReallignToolInfo;
    procedure FileName1Click(Sender: TObject);
    procedure SetFilter1Click(Sender: TObject);
    procedure ImButton1Click(Sender: TObject);
    procedure MakeFolderViewer1Click(Sender: TObject);
    procedure AutoCompliteTimerTimer(Sender: TObject);
    procedure ComboBox1DropDown;
    procedure CbPathEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EasyListview2KeyAction(Sender: TCustomEasyListview;
        var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
    procedure EasyListview1ItemEdited(Sender: TCustomEasyListview;
        Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
    procedure ListView1Resize(Sender : TObject);
    procedure N05Click(Sender: TObject);
    procedure EasyListview1DblClick(Sender: TCustomEasyListview; Button: TCommonMouseButton; MousePos: TPoint;
      ShiftState: TShiftState; var Handled: Boolean);
    procedure EasyListview1ItemThumbnailDraw(
        Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
        ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
    procedure EasyListview1ItemSelectionChanged(
        Sender: TCustomEasyListview; Item: TEasyItem);
    procedure ScrollBox1Reallign(Sender: TObject);
    procedure BackGround(Sender: TObject; x, y, w, h: integer;
        Bitmap: TBitmap);
    procedure Listview1IncrementalSearch(Item: TEasyCollectionItem; const SearchBuffer: WideString; var Handled: Boolean;
      var CompareResult: Integer);

    procedure EasyListview1ItemImageDraw(Sender: TCustomEasyListview;
      Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
      const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
    procedure EasyListview1ItemImageDrawIsCustom(
     Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
     var IsCustom: Boolean);
    procedure EasyListview1ItemImageGetSize(Sender: TCustomEasyListview;
     Item: TEasyItem; Column: TEasyColumn; var ImageWidth,
      ImageHeight: Integer);
    function ListViewTypeToSize(ListViewType : Integer) : Integer;
    procedure SmallIcons1Click(Sender: TObject);
    procedure Icons1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure Tile2Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);
    procedure ToolButtonViewClick(Sender: TObject);
    procedure Thumbnails1Click(Sender: TObject);
    function GetView : integer;
    procedure MakeFolderViewer2Click(Sender: TObject);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    function GetAllItems : TExplorerFileInfos;
    procedure DoDefaultSort(GUID : TGUID);
    procedure DoStopLoading;
    procedure AddHiddenInfo1Click(Sender: TObject);
    procedure ExtractHiddenInfo1Click(Sender: TObject);
    procedure TbZoomInClick(Sender: TObject);
    procedure TbZoomOutClick(Sender: TObject);
    procedure TbStopClick(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure MapCD1Click(Sender: TObject);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ClearList;
    procedure ShowLoadingSign;
    procedure HideLoadingSign;
    procedure AsEXIF1Click(Sender: TObject);
   private
     FBitmapImageList : TBitmapImageList;
     FWindowID : TGUID;
     NewFileName : String;
     NewFileNameGUID : TGUID;
     TempFolderName : String;
     ComboPath : string;
     FormLoadEnd : boolean;
     FPictureSize : integer;
     ListView : integer;
     ElvMain : TEasyListView;
     aScript : TScript;
     MainMenuScript : string;
     RefreshIDList : TList;
     rdown : boolean;
     outdrag : boolean;
     fpopupdown : boolean;
     SelfDraging : boolean;
     FDblClicked : Boolean;
     FSelectedInfo : TSelectedInfo;
     fStatusProgress : TProgressBar;
     FFilesInfo : TExplorerFileInfos;
     fCurrentPath : String;
     fCurrentTypePath : Integer;
     LockDrawIcon : boolean;

     MouseDowned : Boolean;
     PopupHandled : Boolean;
     LastMouseItem, ItemWithHint : TEasyItem;
     LastListViewSelected : TEasyItem;
     FListDragItems : array of TEasyItem;

     ItemByMouseDown : Boolean;
     ItemSelectedByMouseDown : Boolean;

     NotSetOldPath : boolean;
     fHistory : TStringsHistoryW;
     FOldPatch : String;
     FOldPatchType : Integer;
     fFilesToDrag : TArStrings;
     FDBCanDrag : Boolean;
     fDBCanDragW : Boolean;
     FDBDragPoint : TPoint;
     UpdatingList : Boolean;
     GlobalLock : Boolean;
     FIsExplorer : Boolean;
     LastShift: TShiftState;
     LastListViewSelCount : Integer;
     FReadingFolderNumber : Integer;
     ItemsDeselected : boolean;
     IsReallignInfo : boolean;
     FWasDragAndDrop : boolean;
     RenameResult : boolean;
     FChangeHistoryOnChPath : Boolean;
     WindowsMenuTickCount : Cardinal;
     UserLinks : array of TWebLink;
     FPlaces : TPlaceFolderArray;
     DragFilesPopup : TStrings;
     LastSelCount : Integer;
     Lock : boolean;
     FWndOrigin: TWndMethod;
     SlashHandled:boolean;
     DefaultSort : integer;
     DirectoryWatcher : TWachDirectoryClass;
     FShellTreeView : TShellTreeView;
     FGoToLastSavedPath : Boolean;
     FW7TaskBar : ITaskbarList3;
     procedure ReadPlaces;
     procedure UserDefinedPlaceClick(Sender : TObject);
     procedure UserDefinedPlaceContextPopup(Sender: TObject;
       MousePos: TPoint; var Handled: Boolean);
     procedure DoSelectItem;
     procedure SendToItemPopUpMenu_(Sender : TObject);
//     procedure CorrectPath(Src : TStrings; Dest : string);
     procedure LoadIcons;
    function GetMyComputer: string;
    { Private declarations }
   protected
     procedure ComboWNDProc(var Message: TMessage);
     procedure ZoomIn;
     procedure ZoomOut;
     procedure LoadToolBarGrayedIcons;
     procedure LoadToolBarNormaIcons;
     function TreeView : TShellTreeView;
     procedure CreateBackgrounds;
     function GetFormID : string; override;
     function GetListView : TEasyListview; override;
     function InternalGetImage(FileName : string; Bitmap : TBitmap) : Boolean; override;
   public
     NoLockListView : boolean;
     Procedure LoadLanguage;
     procedure LoadSizes;
     procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
     constructor Create(AOwner : TComponent; GoToLastSavedPath : Boolean); reintroduce; overload;
     destructor Destroy; override;
     property WindowID : TGUID read FWindowID;
     property MyComputer : string read GetMyComputer;
   end;

  TManagerExplorer = class(TObject)
  private
    FExplorers : TList;
    FForms: TList;
    FShowPrivate: Boolean;
    FShowEXIF: Boolean;
    FShowQuickLinks: Boolean;
    FSync: TCriticalSection;
    procedure SetShowQuickLinks(const Value: Boolean);
    function GetExplorerByIndex(Index: Integer): TExplorerForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewExplorer(GoToLastSavedPath : Boolean) : TExplorerForm;
    procedure FreeExplorer(Explorer : TExplorerForm);
    procedure AddExplorer(Explorer : TExplorerForm);
    procedure LoadEXIF;
    procedure RemoveExplorer(Explorer : TExplorerForm);
    function GetExplorersTexts : TStrings;
    function IsExplorer(Explorer : TExplorerForm) : Boolean;
    function ExplorersCount : Integer;
    function GetExplorerNumber(Explorer : TExplorerForm) : Integer;
    function GetExplorerBySID(SID : string) : TExplorerForm;
    property ShowPrivate : Boolean read fShowPrivate write fShowPrivate;
    function IsExplorerForm(Explorer: TForm): Boolean;
    property ShowEXIF : Boolean read fShowEXIF write fShowEXIF;
    property ShowQuickLinks : Boolean read FShowQuickLinks write SetShowQuickLinks;
    property Items[Index: Integer]: TExplorerForm read GetExplorerByIndex; default;
  end;

var
  ExplorerManager : TManagerExplorer = nil;

implementation

uses Language, UnitUpdateDB, ExplorerThreadUnit, Searching,
     SlideShow, PropertyForm, UnitHintCeator, UnitImHint,
     FormManegerUnit, Options, ManagerDBUnit, UnitExplorerThumbnailCreatorThread,
     uAbout, uActivation, UnitPasswordForm, UnitCryptImageForm,
     UnitFileRenamerForm, UnitSizeResizerForm, ImEditor,
     UnitManageGroups, UnitInternetUpdate, UnitHelp,
     UnitGetPhotosForm, UnitFormCont,
     UnitLoadFilesToPanel, DBScriptFunctions, UnitStringPromtForm,
     UnitSavingTableForm, UnitUpdateDBObject, Loadingresults,
     UnitStenoGraphia, UnitBigImagesSize;

{$R *.dfm}

function MakeRegPath(Path : string) : string;
var
  I : Integer;
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

procedure TExplorerForm.ShellTreeView1Change(Sender: TObject;
  Node: TTreeNode);
begin
  if ElvMain <> nil then
    SetStringPath(TreeView.Path, True);
end;

procedure VerifyPaste(Explorer : TExplorerForm);
var
  Files : TStrings;
  Effects : Integer;
begin
  with Explorer do
  begin
    Files := TStringList.Create;
    try
      LoadFilesFromClipBoard(Effects, Files);
      TBPaste.Enabled := Files.Count > 0;
    finally
      F(Files);
    end;
    if (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) then
      TBPaste.Enabled := False;
  end;
end;

procedure TExplorerForm.CreateBackgrounds;
var
  ExplorerBackground : TPNGImage;
  Bitmap, ExplorerBackgroundBMP : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := 150;
    Bitmap.Height := 150;
    Bitmap.Canvas.Brush.Color := ClWindow;
    Bitmap.Canvas.Pen.Color := ClWindow;
    Bitmap.Canvas.Rectangle(0, 0, 150, 150);
    ExplorerBackground := GetExplorerBackground;
    try
      ExplorerBackgroundBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, ClWindow);
        Bitmap.Canvas.Draw(0, 0, ExplorerBackgroundBMP);

        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, clBtnFace);

        ScrollBox1.BackGround.PixelFormat := pf24bit;
        ScrollBox1.BackGround.Width := 130;
        ScrollBox1.BackGround.Height := 150;
        ScrollBox1.BackGround.Canvas.Brush.Color := clBtnFace;
        ScrollBox1.BackGround.Canvas.Pen.Color := clBtnFace;
        ScrollBox1.BackGround.Canvas.Rectangle(0, 0, ScrollBox1.BackGround.Width, ScrollBox1.BackGround.Height);
        DrawTransparent(ExplorerBackgroundBMP, ScrollBox1.BackGround, 40);
      finally
        ExplorerBackgroundBMP.Free;
       end;
    finally
      ExplorerBackground.Free;
    end;
    ElvMain.BackGround.Image := Bitmap;
  finally
    Bitmap.Free;
  end;
end;

procedure TExplorerForm.FormCreate(Sender: TObject);
var
  NewPath : String;
  NewPathType, i : Integer;
begin
  TPrivateHelper.Instance.Init;
  DirectoryWatcher := TWachDirectoryClass.Create;
  DefaultSort:=-1;
  FWasDragAndDrop:=false;
  LockDrawIcon:=false;
  ListView:=LV_THUMBS;
  IsReallignInfo:=false;

  TW.I.Start('ListView1');

  ElvMain:=TEasyListView.Create(self);
  ElvMain.Parent := Self;
  ElvMain.Align := AlClient;

  MouseDowned:=False;
  PopupHandled := False;

  ElvMain.BackGround.Enabled := True;
  ElvMain.BackGround.Tile := False;
  ElvMain.BackGround.AlphaBlend := True;
  ElvMain.BackGround.OffsetTrack := True;
  ElvMain.BackGround.BlendAlpha := 220;


  ElvMain.HotTrack.Color := clWindowText;
  ElvMain.Font.Color := 0;
  ElvMain.View := elsThumbnail;
  ElvMain.DragKind := dkDock;
  SetLVSelection(ElvMain);

  ElvMain.Font.Name := 'Tahoma';
  ElvMain.IncrementalSearch.Enabled := True;
  ElvMain.IncrementalSearch.ItemType := eisiInitializedOnly;
  ElvMain.OnItemThumbnailDraw := EasyListview1ItemThumbnailDraw;
  ElvMain.OnDblClick := EasyListview1DblClick;
  ElvMain.OnExit := ListView1Exit;
  ElvMain.OnMouseDown := ListView1MouseDown;
  ElvMain.OnMouseUp := ListView1MouseUp;
  ElvMain.OnMouseMove := ListView1MouseMove;
  ElvMain.OnItemSelectionChanged := EasyListview1ItemSelectionChanged;
  ElvMain.OnIncrementalSearch := Listview1IncrementalSearch;
  ElvMain.OnMouseWheel := ListView1MouseWheel;
  ElvMain.OnKeyAction := EasyListview2KeyAction;
  ElvMain.OnItemEdited := self.EasyListview1ItemEdited;
  ElvMain.OnResize := ListView1Resize;
  ElvMain.OnItemImageDraw := EasyListview1ItemImageDraw;
  ElvMain.OnItemImageDrawIsCustom := EasyListview1ItemImageDrawIsCustom;
  ElvMain.OnItemImageGetSize := EasyListview1ItemImageGetSize;
  ElvMain.Header.DragManager.Enabled := False;
  ElvMain.DragManager.Enabled := False;
  ElvMain.Header.Columns.Add;
  ElvMain.Groups.Add;
  ElvMain.Groups[0].Visible := True;

  TLoad.Instance.RequaredDBSettings;
  FPictureSize := ThImageSize;
  LoadSizes;

  FWindowID := GetGUID;
  RefreshIDList := TList.Create;

  SetLength(UserLinks, 0);
  SetLength(FPlaces, 0);
  DragFilesPopup := TStringList.Create;

  SelfDraging := False;
  FDblClicked := False;
  FIsExplorer := False;
  SetLength(FListDragItems, 0);
  FDBCanDragW := False;
  ImPreview.Picture.Bitmap := nil;
  DropFileTarget2.Register(Self);
  DropFileTarget1.Register(ElvMain);

  ElvMain.HotTrack.Enabled := DBKernel.Readbool('Options','UseHotSelect',true);
  FormManager.RegisterMainForm(Self);
  fStatusProgress := CreateProgressBar(StatusBar1, 1);
  fStatusProgress.Visible:=false;
  fHistory.OnHistoryChange:=HistoryChanged;
  TbBack.Enabled:=false;
  TbForward.Enabled:=false;
  DBKernel.RegisterChangesID(Sender, ChangedDBDataByID);

  NewFormState;
  MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidth',135);

  Lock:=false;
  FWndOrigin := CbPathEdit.WindowProc;
  CbPathEdit.WindowProc := ComboWNDProc;
  SlashHandled:=false;

  TW.I.Start('aScript');
  aScript := TScript.Create('');

  AddScriptObjFunction(aScript.PrivateEnviroment,'CloseWindow',        F_TYPE_OBJ_PROCEDURE_TOBJECT, CloseWindow);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'SelectAll',         F_TYPE_OBJ_PROCEDURE_TOBJECT, SelectAll1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoUp',              F_TYPE_OBJ_PROCEDURE_TOBJECT, Up1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoBack',            F_TYPE_OBJ_PROCEDURE_TOBJECT, Back1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoForward',         F_TYPE_OBJ_PROCEDURE_TOBJECT, Forward1Click);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'Copy',              F_TYPE_OBJ_PROCEDURE_TOBJECT, Copy3Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'Paste',             F_TYPE_OBJ_PROCEDURE_TOBJECT, Paste3Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'Cut',               F_TYPE_OBJ_PROCEDURE_TOBJECT, Cut3Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'GoToExplorerMode',  F_TYPE_OBJ_PROCEDURE_TOBJECT, ExplorerPanel1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'CancelExplorerMode',F_TYPE_OBJ_PROCEDURE_TOBJECT, InfoPanel1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'ShowPrivate',       F_TYPE_OBJ_PROCEDURE_TOBJECT, ShowPrivate1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'HidePrivate',       F_TYPE_OBJ_PROCEDURE_TOBJECT, ShowOnlyCommon1Click);

  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetThumbnailsView', F_TYPE_OBJ_PROCEDURE_TOBJECT, Thumbnails1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetTilesView',      F_TYPE_OBJ_PROCEDURE_TOBJECT, Tile2Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetIconsView',      F_TYPE_OBJ_PROCEDURE_TOBJECT, Icons1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetListView',       F_TYPE_OBJ_PROCEDURE_TOBJECT, List1Click);
  AddScriptObjFunction(aScript.PrivateEnviroment, 'SetList2View',      F_TYPE_OBJ_PROCEDURE_TOBJECT, SmallIcons1Click);


  AddScriptObjFunctionIsString(       aScript.PrivateEnviroment, 'GetPath',            GetPath);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanBack',            fHistory.CanBack);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanForward',         fHistory.CanForward);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanUp',              CanUp);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'SelCount',           SelCount);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'SelectedIndex',      SelectedIndex);
  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'GetSelectedType',    GetSelectedType);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanCopySelection',   CanCopySelection);
  AddScriptObjFunctionIsArrayStrings( aScript.PrivateEnviroment, 'GetSelectedFiles',   GetSelectedFiles);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'CanPasteInSelection',CanPasteInSelection);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'ExplorerType',       ExplorerType);
  AddScriptObjFunctionIsBool(         aScript.PrivateEnviroment, 'ShowPrivateNow',     ShowPrivate);
  AddScriptObjFunctionIntegerIsString(aScript.PrivateEnviroment, 'GetPathByIndex',     GetPathByIndex);

  AddScriptObjFunctionIsInteger(      aScript.PrivateEnviroment, 'GetView',            GetView);

  TW.I.Start('Script read');
  SetNamedValueStr(aScript, '$dbname', dbname);
  MainMenuScript := ReadScriptFile('scripts\ExplorerMainMenu.dbini');
  TW.I.Start('Script Execure');
  Menu := nil;
  LoadMenuFromScript(ScriptMainMenu.Items, DBkernel.ImageList, MainMenuScript, aScript, ScriptExecuted, FExtImagesInImageList, True);
  Menu := ScriptMainMenu;
  ScriptMainMenu.Images := DBkernel.ImageList;

  TW.I.Start('ReadPlaces');
  ReadPlaces;
  TW.I.Start('LoadLanguage');
  LoadLanguage;
  TW.I.Start('LoadIcons');
  LoadIcons;
  TW.I.Start('LoadToolBarNormaIcons');
  LoadToolBarNormaIcons;
  TW.I.Start('LoadToolBarGrayedIcons');
  LoadToolBarGrayedIcons;
  TW.I.Start('LoadToolBarGrayedIcons - end');
  ToolBar1.Images := ToolBarNormalImageList;
  ToolBar1.DisabledImages := ToolBarDisabledImageList;

  ExplorerManager.AddExplorer(Self);
  MainPanel.DoubleBuffered := True;
  PropertyPanel.DoubleBuffered := True;
  ElvMain.DoubleBuffered := True;
  ScrollBox1.DoubleBuffered := True;

  ToolBar2.ButtonHeight := 22;
  TbStop.Enabled := False;
  SaveWindowPos1.Key := RegRoot + 'Explorer\' + MakeRegPath(GetCurrentPath);
  SaveWindowPos1.SetPosition;
  FormLoadEnd := True;
  LsMain.Top := CoolBar1.Top + CoolBar1.Height + 3;
  LsMain.Left := ClientWidth - LsMain.Width - GetSystemMetrics(SM_CYHSCROLL) - 3;
  LsMain.BringToFront;
  LsMain.Color := clWindow;

  GOM.AddObj(Self);
  if FGoToLastSavedPath then
  begin
    NewPath:=DBkernel.ReadString('Explorer','Patch');
    NewPathType:=DBkernel.ReadInteger('Explorer','PatchType',EXPLORER_ITEM_MYCOMPUTER);

    DBkernel.WriteString('Explorer','Patch','');
    DBkernel.WriteInteger('Explorer','PatchType',EXPLORER_ITEM_MYCOMPUTER);

    SetNewPathW(ExplorerPath(NewPath,NewPathType),True);

    DBkernel.WriteString('Explorer','Patch',NewPath);
    DBkernel.WriteInteger('Explorer','PatchType',NewPathType);
  end;
  CreateBackgrounds;

  for I := 0 to ComponentCount - 1 do
    if Components[I] is TWebLink then
      (Components[I] as TWebLink).GetBackGround := BackGround;

  for I := 0 to Length(UserLinks) - 1 do
    UserLinks[I].GetBackGround := BackGround;

  FW7TaskBar := CreateTaskBarInstance;
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

  rdown := False;
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
    if Item.index > FFilesInfo.Count - 1 then
      Exit;

    SetForegroundWindow(Handle);
    SetLength(FFilesToDrag, 0);
    Fpopupdown := True;
    if not(GetTickCount - WindowsMenuTickCount > WindowsMenuTime) then
    begin
      PmItemPopup.Tag := ItemIndexToMenuIndex(Item.index);
      PmItemPopup.Popup(ElvMain.Clienttoscreen(MousePos).X, ElvMain.Clienttoscreen(MousePos).Y);
    end else
    begin
      Screen.Cursor := CrDefault;
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
    PmListPopup.Popup(ElvMain.Clienttoscreen(MousePos).X, ElvMain.Clienttoscreen(MousePos).Y);
end;

procedure TExplorerForm.SlideShow1Click(Sender: TObject);
var
  FileName : string;
  Info: TRecordsInfo;
  MenuInfo: TDBPopupMenuInfo;
begin
  FileName := FFilesInfo[PmItemPopup.Tag].FileName;
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE then
  begin
    MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
    try
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      DBPopupMenuInfoToRecordsInfo(MenuInfo, Info);
      Viewer.Execute(Sender, Info);
      Viewer.Show;
    finally
      F(MenuInfo);
    end;
  end;
  if fFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_FOLDER then
    Viewer.ShowFolderA(FFilesInfo[PmItemPopup.Tag].FileName, ExplorerManager.ShowPrivate);
end;

procedure TExplorerForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProcessPath(fFilesInfo[PmItemPopup.Tag].FileName)), nil, nil, SW_NORMAL);
end;

procedure TExplorerForm.Properties1Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
  ArInt: TArInteger;
  Files: TStrings;
  WindowsProperty: Boolean;
  I : Integer;

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
  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE then
  begin
  if SelCount> 1 then
    begin
      Info := GetCurrentPopUpMenuInfo(nil);
      try
        SetLength(ArInt, 0);
        WindowsProperty := True;
        for I := 0 to Info.Count - 1 do
          if Info[I].Selected then
          begin
            SetLength(ArInt, Length(ArInt) + 1);
            ArInt[Length(ArInt) - 1] := Info[I].ID;
            if Info[I].ID <> 0 then
              WindowsProperty := False;
          end;
        if not WindowsProperty then
          PropertyManager.NewSimpleProperty.ExecuteEx(ArInt)
        else
          ShowWindowsPropertiesDialogToSelected;
      finally
        F(Info);
      end;
    end else
    begin
      if not FFilesInfo[PmItemPopup.Tag].Loaded then
        FFilesInfo[PmItemPopup.Tag].ID := GetIdByFileName(FFilesInfo[PmItemPopup.Tag].FileName);
      if FFilesInfo[PmItemPopup.Tag].ID = 0 then
        PropertyManager.NewFileProperty(FFilesInfo[PmItemPopup.Tag].FileName).ExecuteFileNoEx
          (FFilesInfo[PmItemPopup.Tag].FileName)
      else
        PropertyManager.NewIDProperty(FFilesInfo[PmItemPopup.Tag].ID).Execute(FFilesInfo[PmItemPopup.Tag].ID);
    end;
  end else
    ShowWindowsPropertiesDialogToSelected;
end;

procedure TExplorerForm.PmItemPopupPopup(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
  Item: TEasyItem;
  Point: TPoint;
  Files: TStrings;
  Effects, I: Integer;
  B: Boolean;
begin
  GetCursorPos(Point);
  Paste2.Visible := False;
  SendTo1.Visible := False;
  MakeFolderViewer2.Visible := False;
  MapCD1.Visible := False;

  if fFilesInfo[PmItemPopup.tag].FileType = EXPLORER_ITEM_DRIVE then
  begin
    DBitem1.Visible := False;
    Print1.Visible := False;
    RefreshID1.Visible := False;
    Othertasks1.Visible := False;
    ImageEditor2.Visible := False;
    Rotate1.Visible := False;
    SetasDesktopWallpaper1.Visible := False;
    StenoGraphia1.Visible := False;
    Convert1.Visible := False;
    Resize1.Visible := False;
    Refresh1.Visible := False;
    CryptFile1.Visible := False;
    EnterPassword1.Visible := False;
    ResetPassword1.Visible := False;
    NewWindow1.Visible := True;
    AddFile1.Caption := L('Add disk');
    AddFile1.Visible := True;
    Properties1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := True;
    Rename1.Visible := False;
    Delete1.Visible := False;
    Files := TStringList.Create;
    try
      LoadFIlesFromClipBoard(Effects, Files);
      if Files.Count <> 0 then
        Paste2.Enabled := True
      else
        Paste2.Enabled := False;
    finally
      F(Files);
    end;
    Cut2.Visible := False;
    Copy1.Visible := False;
    Paste2.Visible := True;
    Shell1.Visible := True;
  end;
  if fFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_FOLDER then
  begin
    DBitem1.Visible := False;
    MakeFolderViewer2.Visible := not FolderView;
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
    StenoGraphia1.Visible := False;
    Refresh1.Visible := True;
    NewWindow1.Visible := True;
    AddFile1.Caption := L('Add directory');
    AddFile1.Visible := True;
    Properties1.Visible := True;
    Paste2.Visible := True;
    Open1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
    SlideShow1.Visible := True;
    Files := TStringList.Create;
    try
      LoadFIlesFromClipBoard(Effects, Files);
      if Files.Count <> 0 then
        Paste2.Enabled := True
      else
        Paste2.Enabled := False;
    finally
      F(Files);
    end;

    B := CanCopySelection;
    Cut2.Visible := B;
    Copy1.Visible := B;
    Paste2.Visible := True;
    Shell1.Visible := True;
  end;
  if fFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE then
  begin
    DBitem1.Visible := True;
    StenoGraphia1.Visible := True;
    AddHiddenInfo1.Visible := (SelCount = 1);
    ExtractHiddenInfo1.Visible := True;
    ExtractHiddenInfo1.Visible := ExtInMask('|PNG|BMP|', GetExt(FFilesInfo[PmItemPopup.Tag].FileName));

    MakeFolderViewer2.Visible := not FolderView;
    Print1.Visible := True;
    Othertasks1.Visible := True;
    ImageEditor2.Visible := True;
    CryptFile1.Visible := not ValidCryptGraphicFile(FFilesInfo[PmItemPopup.Tag].FileName);
    ResetPassword1.Visible := not CryptFile1.Visible;
    EnterPassword1.Visible := not CryptFile1.Visible and
      (DBkernel.FindPasswordForCryptImageFile(FFilesInfo[PmItemPopup.Tag].FileName) = '');

    Convert1.Visible := not EnterPassword1.Visible;
    Resize1.Visible := not EnterPassword1.Visible;
    Rotate1.Visible := not EnterPassword1.Visible;
    RefreshID1.Visible := (not EnterPassword1.Visible) and (FFilesInfo[PmItemPopup.Tag].ID <> 0);
    SetasDesktopWallpaper1.Visible := CryptFile1.Visible and IsWallpaper(FFilesInfo[PmItemPopup.Tag].FileName);
    Refresh1.Visible := True;
    Open1.Visible := False;
    Shell1.Visible := True;
    Rename1.Visible := True;
    NewWindow1.Visible := False;
    Properties1.Visible := True;
    SlideShow1.Visible := True;
    Delete1.Visible := True;
    AddFile1.Caption := L('Add file');
    if FFilesInfo[PmItemPopup.Tag].ID = 0 then
      AddFile1.Visible := True
    else
      AddFile1.Visible := False;
    Cut2.Visible := True;
    Copy1.Visible := True;
    Paste2.Visible := False;
  end;
  if (fFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_FILE) or
    (FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_EXEFILE) then
  begin
    if AnsiLowerCase(ExtractFileName(FFilesInfo[PmItemPopup.Tag].FileName)) = AnsiLowerCase(C_CD_MAP_FILE) then
    begin
      MapCD1.Visible := not FolderView;
    end;
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
    Properties1.Visible := True;
    Delete1.Visible := True;
    Rename1.Visible := True;
    AddFile1.Visible := False;
    Cut2.Visible := True;
    Copy1.Visible := True;
    Paste2.Visible := False;
    Shell1.Visible := True;
  end;

  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_NETWORK then
  begin
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
    NewWindow1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := False;
    Properties1.Visible := False;
    Delete1.Visible := False;
    Rename1.Visible := False;
    AddFile1.Visible := False;
    Cut2.Visible := False;
    Copy1.Visible := False;
    Paste2.Visible := False;
    Shell1.Visible := False;
  end;

  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_WORKGROUP then
  begin
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
    NewWindow1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := False;
    Properties1.Visible := False;
    Delete1.Visible := False;
    Rename1.Visible := False;
    AddFile1.Visible := False;
    Cut2.Visible := False;
    Copy1.Visible := False;
    Paste2.Visible := False;
    Shell1.Visible := False;
  end;

  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_COMPUTER then
  begin
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
    NewWindow1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := False;
    Properties1.Visible := False;
    Delete1.Visible := False;
    Rename1.Visible := False;
    AddFile1.Visible := False;
    Cut2.Visible := False;
    Copy1.Visible := False;
    Paste2.Visible := False;
    Shell1.Visible := False;
  end;

  if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_SHARE then
  begin
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
    NewWindow1.Visible := True;
    Open1.Visible := True;
    SlideShow1.Visible := False;
    Properties1.Visible := False;
    Delete1.Visible := False;
    Rename1.Visible := False;
    AddFile1.Visible := False;
    Cut2.Visible := False;
    Copy1.Visible := False;
    Paste2.Visible := False;
    Shell1.Visible := False;
  end;

  Item := ItemAtPos(ElvMain.ScreenToClient(Point).X, ElvMain.ScreenToClient(Point).Y);
  if PmItemPopup.Tag < 0 then
    Exit;
  for I := DBitem1.MenuIndex + 1 to N8.MenuIndex - 1 do
    PmItemPopup.Items.Delete(DBitem1.MenuIndex + 1);

  if DBitem1.Visible then
  begin
    Info := GetCurrentPopUpMenuInfo(Item);
    try
      if Item <> nil then
      begin
        Info.IsListItem := True;
        Info.ListItem := Item;
      end;
      Info.AttrExists := False;
      TDBPopupMenu.Instance.AddDBContMenu(DBItem1, Info);
    finally
      F(Info);
    end;
  end;

  if fFilesInfo[PmItemPopup.Tag].ID = 0 then
  begin
    if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE then
      SendTo1.Visible := True;
    if DBKernel.ReadBool('Options', 'UseUserMenuForExplorer', True) then
      if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_IMAGE then
      begin
        Info := GetCurrentPopUpMenuInfo(Item);
        try
          TDBPopupMenu.Instance.SetInfo(Info);
          TDBPopupMenu.Instance.AddUserMenu(PmItemPopup.Items, True, DBitem1.MenuIndex + 1);
        finally
          F(Info);
        end;
      end;
  end;
end;

procedure TExplorerForm.Copy1Click(Sender: TObject);
var
  I, Index : Integer;
  FileList: TStrings;
begin
  FileList := TStringList.Create;
  try
  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      FileList.Add(ProcessPath(FFilesInfo[Index].FileName));
    end;
  if FileList.Count > 0 then
    Copy_Move(True, FileList);
  finally
      FileList.Free;
  end;
end;

procedure TExplorerForm.Rename1Click(Sender: TObject);
var
  i, ItemIndex : Integer;
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
      FastRenameManyFiles(Files, X);
    finally
      F(Files);
    end;
  end;
end;

procedure TExplorerForm.DeleteFiles(ToRecycle : Boolean);
var
  I : integer;
  Index: Integer;
  Files: TStringList;
begin
  if SelCount = 0 then
    Exit;
  Files:= TStringList.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        index := ItemIndexToMenuIndex(I);
        Files.Add(FFilesInfo[index].FileName);
      end;
    uFileUtils.DeleteFiles(Handle, Files, ToRecycle);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.Delete1Click(Sender: TObject);
begin
  DeleteFiles(True);
end;

procedure TExplorerForm.AddFile1Click(Sender: TObject);
var
  I, Index : Integer;
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;

  if ListView1Selected <> nil then
  begin
    for I := 0 to ElvMain.Items.Count - 1 do
    begin
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        if FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER then
        begin
          UpdaterDB.AddDirectory(FFilesInfo[Index].FileName, nil);
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
            UpdaterDB.AddDirectory(FFilesInfo[Index].FileName, nil);
            Continue;
          end;
      end;
    end;
  end;
  if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) then
    if SelCount = 0 then
      UpdaterDB.AddDirectory(GetCurrentPath, nil);
end;

procedure TExplorerForm.FormDestroy(Sender: TObject);
begin
  NewFormState;
  ClearList;
  DirectoryWatcher.StopWatch;
  F(DirectoryWatcher);
  F(aScript);
  F(DragFilesPopup);
  F(FBitmapImageList);

  SaveWindowPos1.SavePosition;
  DropFileTarget2.Unregister;
  DropFileTarget1.Unregister;
  DBKernel.UnRegisterChangesID(Sender,ChangedDBDataByID);

  DBkernel.WriteInteger('Explorer','LeftPanelWidth',MainPanel.Width);

  DBkernel.WriteString('Explorer','Patch',GetCurrentPathW.Path);
  DBkernel.WriteInteger('Explorer','PatchType',GetCurrentPathW.PType);
  FStatusProgress.Free;
  FormManager.UnRegisterMainForm(Self);
  F(FFilesInfo);
  GOM.RemoveObj(Self);
end;

procedure TExplorerForm.ListView1Edited(Sender: TObject; Item: TEasyItem;
      var S: String);
var
  DS : TDataSet;
  Folder: string;
begin
  FDblClicked := False;
  S := Copy(S, 1, Min(Length(S), 255));
  if AnsiLowerCase(S) = AnsiLowerCase(ExtractFileName(FFilesInfo[PmItemPopup.Tag].FileName)) then
    Exit;
  begin
    if GetExt(S) <> GetExt(FFilesInfo[PmItemPopup.Tag].FileName) then
      if FileExists(FFilesInfo[PmItemPopup.Tag].FileName) then
      begin
        if ID_OK <> MessageBoxDB(Handle, L('Do you really want to replace extension to selected object?'), L('Warning'), TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
        begin
          S := ExtractFileName(FFilesInfo[PmItemPopup.Tag].FileName);
          Exit;
        end;
      end;
    if FFilesInfo[PmItemPopup.Tag].FileType = EXPLORER_ITEM_FOLDER then
    begin
      DS := GetQuery;
      try
        Folder := IncludeTrailingBackslash(FFilesInfo[PmItemPopup.Tag].FileName);
        SetSQL(DS, 'Select count(*) as CountField from $DB$ where (FFileName Like :FolderA)');
        SetStrParam(DS, 0, NormalizeDBStringLike('%' + Folder + '%'));
        DS.Open;
        if DS.FieldByName('CountField').AsInteger = 0 then
        begin
          try
            RenameResult := RenameFile(FFilesInfo[PmItemPopup.Tag].FileName,
              ExtractFilePath(FFilesInfo[PmItemPopup.Tag].FileName) + S);
          except
            RenameResult := False;
          end;
        end else
          RenameResult := RenamefileWithDB(Self, FFilesInfo[PmItemPopup.Tag].FileName,
            ExtractFilePath(FFilesInfo[PmItemPopup.Tag].FileName) + S, FFilesInfo[PmItemPopup.Tag].ID, False);
      finally
        FreeDS(DS);
      end;
    end else
      RenameResult := RenamefileWithDB(Self, FFilesInfo[PmItemPopup.Tag].FileName,
        ExtractFilePath(FFilesInfo[PmItemPopup.Tag].FileName) + S, FFilesInfo[PmItemPopup.Tag].ID, False);
  end;
end;

procedure TExplorerForm.HintTimerTimer(Sender: TObject);
var
  P, P1: Tpoint;
  index, I: Integer;
  MenuInfo: TDBPopupMenuInfoRecord;
begin
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);
  if (not Active) or (not ElvMain.Focused) or (ItemAtPos(P1.X, P1.Y) <> LastMouseItem) or
    (ItemWithHint <> LastMouseItem) then
  begin
    HintTimer.Enabled := False;
    Exit;
  end;
  if LastMouseItem= nil then
    Exit;
  index := LastMouseItem.index;
  if index < 0 then
    Exit;
  index := ItemIndexToMenuIndex(index);
  if index > FFilesInfo.Count - 1 then
    Exit;

  if not(CtrlKeyDown or ShiftKeyDown) then
    if DBKernel.Readbool('Options', 'UseHotSelect', True) then
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

  if not ExtInMask(SupportedExt, GetExt(FFilesInfo[index].FileName)) then
    Exit;

  if not FileExists(FFilesInfo[index].FileName) then
    Exit;

  HintTimer.Enabled := False;

  MenuInfo := FFilesInfo[index].Copy;
  THintManager.Instance.CreateHintWindow(Self, MenuInfo, P, HintRealA);
end;

function TExplorerForm.hintrealA(Info: TDBPopupMenuInfoRecord): Boolean;
var
  P, P1 : TPoint;
  Item : TeasyItem;
  Index : Integer;
begin
  Result := False;
  GetCursorPos(P);
  P1 := ElvMain.ScreenToClient(P);
  Item := ItemAtPos(P1.X, P1.Y);
  if Item = nil then
    Exit;
  Index := ItemIndexToMenuIndex(Item.Index);
  Result := not((not Self.Active) or (not ElvMain.Focused) or (Item <> LastMouseItem) or
      (Item = nil) or (fFilesInfo[Index].FileName <> Info.FileName));
end;

procedure TExplorerForm.ListView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Pos, MousePos : TPoint;
  I, Index : Integer;
  LButtonState, RButtonState : SmallInt;
  Item: TEasyItem;
  SpotX, SpotY : Integer;

begin
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

      FDBDragPoint := ElvMain.ScreenToClient(FDBDragPoint);
      CreateDragImage(ElvMain, DragImageList, FBitmapImageList, Item.Caption, FDBDragPoint, SpotX, SpotY);

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
      DropFileTarget1.Files.clear;
      FDBCanDrag := True;
      ListView1MouseUp(Sender, MbLeft, Shift, X, Y);
      SetLength(FListDragItems, 0);
      FDBCanDrag := False;
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
      if DBKernel.Readbool('Options', 'AllowPreview', True) then
        HintTimer.Enabled := True;
      ItemWithHint := LastMouseItem;
    end;
    Index := ItemIndexToMenuIndex(LastMouseItem.Index);
    if fFilesInfo.Count=0 then
      Exit;

    ElvMain.ShowHint := False;
    ElvMain.Hint := FFilesInfo[Index].Comment;
  end;
end;

procedure TExplorerForm.SetInfoToItem(info : TOneRecordInfo; FileGUID: TGUID);
var
  I : Integer;
  ExplorerInfo : TExplorerFileInfo;
begin
  for I := 0 to fFilesInfo.Count - 1 do
  begin
    ExplorerInfo := fFilesInfo[I];
    if IsEqualGUID(ExplorerInfo.SID, FileGUID) then
    begin
      ExplorerInfo.FileName := info.ItemFileName;
      ExplorerInfo.ID := info.ItemId;
      ExplorerInfo.Rotation := info.ItemRotate;
      ExplorerInfo.Access := info.ItemAccess;
      ExplorerInfo.Rating := info.ItemRating;
      ExplorerInfo.FileSize := info.ItemSize;
      ExplorerInfo.Comment := info.ItemComment;
      ExplorerInfo.KeyWords := info.ItemKeyWords;
      ExplorerInfo.Date := info.ItemDate;
      ExplorerInfo.Time := info.ItemTime;
      ExplorerInfo.IsDate := info.ItemIsDate;
      ExplorerInfo.IsTime := info.ItemIsTime;
      ExplorerInfo.Groups := info.ItemGroups;
      ExplorerInfo.KeyWords := info.ItemKeyWords;
      ExplorerInfo.FileType := Info.Tag;
      ExplorerInfo.Crypted := Info.ItemCrypted;
      ExplorerInfo.Loaded := Info.Loaded;
      ExplorerInfo.Include := Info.ItemInclude;
      ExplorerInfo.Links := Info.ItemLinks;
      if Viewer <> nil then
        Viewer.UpdateInfoAboutFileName(info.ItemFileName, Info);
      Break;
    end;
  end;
  if AnsiLowerCase(info.ItemFileName) = AnsiLowerCase(FSelectedInfo.FileName) then
    ListView1SelectItem(nil, nil, False);
end;

procedure TExplorerForm.SpeedButton3Click(Sender: TObject);
var
  Dir: string;
  I: Integer;
  B: Boolean;
begin
  B := False;
  if FIsExplorer then
  begin
    if TreeView.Selected <> nil then
      TreeView.Select(TreeView.Selected.Parent);
  end else
  begin
    Dir := GetCurrentPath;
    if GetCurrentPathW.PType = EXPLORER_ITEM_COMPUTER then
    begin
      SetNewPathW(ExplorerPath(GetResourceParent(Dir), EXPLORER_ITEM_WORKGROUP), False);
      Exit;
    end;
    if GetCurrentPathW.PType = EXPLORER_ITEM_WORKGROUP then
    begin
      SetNewPathW(ExplorerPath(L('Network'), EXPLORER_ITEM_NETWORK), False);
      Exit;
    end;

    for I := Length(Dir) - 1 downto 1 do
      if Dir[I] = '\' then
      begin
        Dir := Copy(Dir, 1, I);
        SetNewPath(Dir, False);
        B := True;
        Break;
      end;
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
  end;
end;

procedure TExplorerForm.EndUpdate;
begin
  if UpdatingList then
  begin
    ElvMain.EndUpdate;
    UpdatingList := False;
  end;
end;

procedure TExplorerForm.Open1Click(Sender: TObject);
var
  Handled : Boolean;
begin
  EasyListview1DblClick(ElvMain, cmbLeft, Point(0, 0), [], Handled);
end;

function TExplorerForm.GetCurrentPopUpMenuInfo(item : TEasyItem) : TDBPopupMenuInfo;
var
  I : Integer;
  ItemIndex : Integer;
  MenuRecord : TDBPopupMenuInfoRecord;
begin
  Result := TDBPopupMenuInfo.Create;
  Result.IsListItem := False;
  Result.IsPlusMenu := False;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ItemIndex := ItemIndexToMenuIndex(I);
    if ItemIndex > FFilesInfo.Count - 1 then
      Exit;
    if FFilesInfo[ItemIndex].FileType = EXPLORER_ITEM_IMAGE then
    begin
      MenuRecord := FFilesInfo[ItemIndex].Copy;
      MenuRecord.Selected := ElvMain.Items[I].Selected;
      Result.Add(MenuRecord);
      if Item <> nil then
        if ElvMain.Items[I].Selected then
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

function TExplorerForm.GetListView: TEasyListview;
begin
  Result := ElvMain;
end;

function TExplorerForm.GetMyComputer: string;
begin
  Result := L('My computer');
end;

procedure TExplorerForm.CbPathEditKeyPress(Sender: TObject; var Key: Char);
var
  s : string;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    SetStringPath(CbPathEdit.Text, False);
  end;
  if (Key = ':') or (Key = '\') then
  begin
    if SlashHandled then
    begin
      SlashHandled := False;
      Exit;
    end;
    S := IncludeTrailingBackslash(CbPathEdit.Text);
    if ComboPath <> ExtractFilePath(S) then
    begin
      ComboPath := ExtractFilePath(CbPathEdit.Text);
      ComboBox1DropDown;
    end;
  end;
end;

procedure TExplorerForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TExplorerForm.PageScroller2Resize(Sender: TObject);
begin
  CbPathEdit.Width:= CoolBar1.Width - ImButton1.Width - Label2.Width - ToolButton9.Width - ImButton1.Width;
end;

procedure TExplorerForm.ClearList;
var
  I : Integer;
begin
  for I := 0 to ElvMain.Items.Count - 1 do
    TDataObject(ElvMain.Items[I].Data).Free;
  ElvMain.Items.Clear;
end;

procedure TExplorerForm.CloseButtonPanelResize(Sender: TObject);
begin
  Button1.Left := CloseButtonPanel.Width - Button1.Width - 3;
end;

procedure TExplorerForm.Splitter1CanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  Accept := NewSize > 100;
end;

procedure TExplorerForm.ListView1SelectItem(Sender: TObject;
  Item: TEasyItem; Selected: Boolean);
begin
  SelectTimer.Enabled := True;
end;

procedure TExplorerForm.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  ImParams, UpdateInfoParams: TEventFields;
  I, index, ReRotation: Integer;
  Bit: TBitmap;
begin
  if EventID_Repaint_ImageList in Params then
  begin
    ElvMain.Refresh;
    Exit;
  end;
  if ID = -2 then
    Exit;
  if SetNewIDFileData in Params then
  begin
    for I := 0 to FFilesInfo.Count - 1 do
      if AnsiLowerCase(FFilesInfo[I].FileName) = Value.name then
      begin
        fFilesInfo[i].SID := GetGUID;

        if HelpNo = 3 then
          Help1NextClick(Self);

        fFilesInfo[i].ID := ID;
        FFilesInfo[I].IsDate := True;
        FFilesInfo[I].IsTime := Value.IsTime;
        FFilesInfo[I].Loaded := True;
        FFilesInfo[I].Links := '';
        FFilesInfo[I].Crypted := GraphicCrypt.ValidCryptGraphicFile(FFilesInfo[I].FileName);
        if FBitmapImageList[FFilesInfo[I].ImageIndex].Bitmap = nil then
        begin
          Bit := TBitmap.Create;
          Bit.PixelFormat := Pf24bit;
          Bit.Assign(Value.JPEGImage);

          if FBitmapImageList[FFilesInfo[I].ImageIndex].IsBitmap then
            FBitmapImageList[FFilesInfo[I].ImageIndex].Bitmap.Free;

          FBitmapImageList[FFilesInfo[I].ImageIndex].IsBitmap := True;
          FBitmapImageList[FFilesInfo[I].ImageIndex].Bitmap := Bit;
        end;
        ElvMain.Refresh;
        Break;
      end;
    Exit;
  end;
  if EventID_Param_CopyPaste in Params then
  begin
    VerifyPaste(Self);
    Exit;
  end;
  ImParams := [EventID_Param_Image,EventID_Param_Delete,EventID_Param_Critical,EventID_Param_Crypt];
  if ImParams * params<> [] then
  begin
    if ID > 0 then
      RefreshItemByID(ID)
    else
      RefreshItemByName(Value.Name);
  end;

  ReRotation := 0;
  UpdateInfoParams := [EventID_Param_Rotate, EventID_Param_Rating, EventID_Param_Private, EventID_Param_Access,
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
          if EventID_Param_Access in Params then
            FFilesInfo[I].Access := Value.Access;
          if EventID_Param_Rating in Params then
            FFilesInfo[I].Rating := Value.Rating;
          if EventID_Param_Date in Params then
            FFilesInfo[I].Date := Value.Date;
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
            ElvMain.Refresh;
          end;
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
        index := MenuIndexToItemIndex(I);
        if ElvMain.Items[index].ImageIndex > -1 then
          ApplyRotate(FBitmapImageList[ElvMain.Items[index].ImageIndex].Bitmap, ReRotation);

      end;
    end;
  end;

  ImParams := [EventID_Param_Refresh, EventID_Param_Rotate, EventID_Param_Rating, EventID_Param_Private,
    EventID_Param_Access];
  if ImParams * Params <> [] then
    ElvMain.Refresh;

  if [EventID_Param_DB_Changed] * Params <> [] then
  begin
    FPictureSize := ThImageSize;
    LoadSizes;
  end;

  if (EventID_Param_Add in Params) or (EventID_Param_Name in Params) then
    if not(FileExists(Value.NewName) or DirectoryExists(Value.NewName)) and not
      (FileExists(Value.name) or DirectoryExists(Value.name)) then
      RefreshItemByName(Value.name)
    else
      RefreshItemByName(Value.NewName);

  if [EventID_Param_DB_Changed, EventID_Param_Refresh_Window] * Params <> [] then
    RefreshLinkClick(RefreshLink);

end;

procedure TExplorerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ExplorerManager.RemoveExplorer(Self);
  THintManager.Instance.CloseHint;
  Hinttimer.Enabled := False;
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
  DoExit;
end;

procedure TExplorerForm.DoExit;
begin
  Close;
end;

procedure TExplorerForm.Addfolder1Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
  UpdaterDB.AddDirectory(GetCurrentPath, nil)
end;

procedure TExplorerForm.Refresh1Click(Sender: TObject);
var
  UpdaterInfo : TUpdaterInfo;
  Info: TExplorerViewInfo;
  I, Index: Integer;
begin
  UpdaterInfo.IsUpdater := False;
  UpdaterInfo.UpdateDB := False;
  UpdaterInfo.ProcHelpAfterUpdate := nil;
  Info.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
  Info.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Info.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Info.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Info.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
  Info.ShowThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Info.SaveThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Info.ShowThumbNailsForImages := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Info.View := ListView;
  Info.PictureSize := FPictureSize;
  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      UpdaterInfo.FileInfo := TExplorerFileInfo(FFilesInfo[Index].Copy);
      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE) then
        TExplorerThread.Create(FFilesInfo[Index].FileName, GUIDToString(FFilesInfo[Index].SID), THREAD_TYPE_IMAGE,
          Info, Self, UpdaterInfo, StateID);

      if (FFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) then
        TExplorerThread.Create(FFilesInfo[Index].FileName, GUIDToString(FFilesInfo[Index].SID),
          THREAD_TYPE_FOLDER_UPDATE, Info, Self, UpdaterInfo, StateID);
    end;
end;

procedure TExplorerForm.RefreshItem(Number: Integer);
var
  UpdaterInfo: TUpdaterInfo;
  Info: TExplorerViewInfo;
  Index: Integer;
begin
  Index := ItemIndexToMenuIndex(Number);
  UpdaterInfo.IsUpdater := False;
  UpdaterInfo.UpdateDB := False;
  UpdaterInfo.FileInfo := TExplorerFileInfo(FFilesInfo[Index].Copy);
  { if HelpNo=3 then
    UpdaterInfo.ProcHelpAfterUpdate:=Help1NextClick else }
  UpdaterInfo.ProcHelpAfterUpdate := nil;
  Info.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
  Info.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Info.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Info.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Info.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
  Info.ShowThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Info.SaveThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Info.ShowThumbNailsForImages := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Info.View := ListView;
  Info.PictureSize := FPictureSize;
  if FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE then
    TExplorerThread.Create(FFilesInfo[index].FileName, GUIDToString(FFilesInfo[index].SID), THREAD_TYPE_IMAGE, Info,
      Self, UpdaterInfo, StateID);
  if (FFilesInfo[index].FileType = EXPLORER_ITEM_FILE) or (FFilesInfo[index].FileType = EXPLORER_ITEM_EXEFILE) then
    TExplorerThread.Create(FFilesInfo[index].FileName, GUIDToString(FFilesInfo[index].SID), THREAD_TYPE_FILE, Info,
      Self, UpdaterInfo, StateID);
end;

procedure TExplorerForm.RefreshItemA(Number: Integer);
var
  UpdaterInfo: TUpdaterInfo;
  Info: TExplorerViewInfo;
  index: Integer;
begin
  index := ItemIndexToMenuIndex(Number);
  if index = -1 then
    Exit;
  if index > FFilesInfo.Count - 1 then
    Exit;
  UpdaterInfo.IsUpdater := False;
  UpdaterInfo.UpdateDB := True;
  UpdaterInfo.FileInfo := TExplorerFileInfo(FFilesInfo[index].Copy);
  UpdaterInfo.ProcHelpAfterUpdate := nil;
  Info.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
  Info.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Info.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Info.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Info.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
  Info.ShowThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Info.SaveThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Info.ShowThumbNailsForImages := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Info.View := ListView;
  Info.PictureSize := FPictureSize;
  if FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE then
    TExplorerThread.Create(FFilesInfo[index].FileName, GUIDToString(FFilesInfo[index].SID), THREAD_TYPE_IMAGE, Info,
      Self, UpdaterInfo, StateID);
  if (FFilesInfo[index].FileType = EXPLORER_ITEM_FILE) or (FFilesInfo[index].FileType = EXPLORER_ITEM_EXEFILE) then
    TExplorerThread.Create(FFilesInfo[index].FileName, GUIDToString(FFilesInfo[index].SID), THREAD_TYPE_FILE, Info,
      Self, UpdaterInfo, StateID);
end;

procedure TExplorerForm.HistoryChanged(Sender: TObject);
var
  MenuBack, MenuForward : TArMenuItem;
  MenuBackInfo, MenuForwardInfo : TArExplorerPath;
  I : Integer;

  function FormatPath(Path : string) : string;
  begin
    if (Path <> '') and ((Path[Length(Path)] = '/') or (Path[Length(Path)] = '\')) then
      Result := Copy(Path, 1, Length(Path) - 1)
    else
      Result := Path;
  end;

  function MakeName(Path : TExplorerPath) : string;
  begin
    if (Path.PType = EXPLORER_ITEM_DRIVE) or (Path.PType = EXPLORER_ITEM_MYCOMPUTER) or (Path.PType = EXPLORER_ITEM_NETWORK) or (Path.PType = EXPLORER_ITEM_WORKGROUP) then
      Result := Path.Path
    else
      Result := ExtractFileName(FormatPath(Path.Path));
  end;

begin
  TbBack.Enabled := FHistory.CanBack;
  TbForward.Enabled := FHistory.CanForward;
  PopupMenuBack.Items.Clear;
  PopupMenuForward.Items.Clear;
  if FHistory.CanBack then
  begin
    SetLength(MenuBackInfo, 0);
    MenuBackInfo := Copy(FHistory.GetBackHistory);
    SetLength(MenuBack, Length(MenuBackInfo));
    for I := 0 to Length(MenuBack) - 1 do
    begin
      MenuBack[Length(MenuBack) - 1 - I] := TMenuItem.Create(PopupMenuBack.Items);
      MenuBack[Length(MenuBack) - 1 - I].Caption := MakeName(MenuBackInfo[I]);
      MenuBack[Length(MenuBack) - 1 - I].Tag := MenuBackInfo[I].Tag;
      MenuBack[Length(MenuBack) - 1 - I].OnClick := JumpHistoryClick;
    end;
    PopupMenuBack.Items.Add(MenuBack);
  end;
  if FHistory.CanForward then
  begin
    SetLength(MenuForwardInfo, 0);
    MenuForwardInfo := Copy(FHistory.GetForwardHistory);
    SetLength(MenuForward, Length(MenuForwardInfo));
    for I := 0 to Length(MenuForward) - 1 do
    begin
      MenuForward[I] := TMenuItem.Create(PopupMenuForward.Items);
      MenuForward[I].Caption := MakeName(MenuForwardInfo[I]);
      MenuForward[I].Tag := MenuForwardInfo[I].Tag;
      MenuForward[I].OnClick := JumpHistoryClick;
    end;
    PopupMenuForward.Items.Add(MenuForward);
  end;
end;

procedure TExplorerForm.SpeedButton1Click(Sender: TObject);
begin
  if FHistory.CanBack then
    SetNewPathW(FHistory.DoBack, False);
end;

procedure TExplorerForm.SpeedButton2Click(Sender: TObject);
begin
  if FHistory.CanForward then
    SetNewPathW(FHistory.DoForward, False)
end;

procedure TExplorerForm.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, Index : integer;
  Item, Itemsel: TEasyItem;
begin
  ItemsDeselected := False;
  FWasDragAndDrop := False;

  Item := ItemAtPos(x, y);

  MouseDowned := Button = mbRight;
  if Item = nil then
     ElvMain.Selection.ClearAll;

  itemsel:= Item;
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
  FDblClicked:=false;
end;

procedure TExplorerForm.ListView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, J, K : Integer;
  Handled: Boolean;
  Item: TEasyItem;
begin

  Item := Self.ItemAtPos(X, Y);
  RightClickFix(ElvMain, Button, Shift, Item, ItemByMouseDown, ItemSelectedByMouseDown);

  if MouseDowned then
    if Button = MbRight then
    begin
      ListView1ContextPopup(ElvMain, Point(X, Y), Handled);
      PopupHandled := True;
    end;

  MouseDowned:=false;

 if FDBCanDrag and ItemsDeselected then
 begin
  If (abs(FDBDragPoint.x-x)>3) or (abs(FDBDragPoint.y-y)>3) then
  if not FWasDragAndDrop then exit;

  SetSelected(nil);

  for J := 0 to ElvMain.Items.Count - 1 do
    begin
      for I := 0 to Length(FListDragItems) - 1 do
        if FListDragItems[I] = ElvMain.Items[J] then
        begin
          FListDragItems[I].Selected := True;
          if I <> 0 then
          begin
            for K := I to Length(FListDragItems) - 2 do
              FListDragItems[K] := FListDragItems[K + 1];
            SetLength(FListDragItems, Length(FListDragItems) - 1);
          end;
          Break;
        end;
    end;
  end;
  SetLength(FFilesToDrag, 0);
  SetLength(FListDragItems, 0);
  FDBCanDrag := False;
  FDBCanDragW := False;
end;

procedure TExplorerForm.ListView1Exit(Sender: TObject);
begin
 rdown:=false;
 FDblClicked:=false;
 FDBCanDrag:=false;
 fDBCanDragW:=false;
 SetLength(fFilesToDrag,0);
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
      RefreshItem(Index);
      Break;
    end;
  end;
end;

procedure TExplorerForm.RefreshItemByNameA(Name: string);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(Name) then
    begin
      Index := MenuIndexToItemIndex(I);
      if Name = FSelectedInfo.FileName then
        ListView1SelectItem(nil, ListView1Selected, False);

      RefreshItemA(Index);
      Break;
    end;
  end;
end;

procedure TExplorerForm.RefreshItemByName(Name: String);
Var
  i:integer;
  index: Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if AnsiLowerCase(FFilesInfo[I].FileName) = AnsiLowerCase(name) then
    begin
      index := MenuIndexToItemIndex(I);
      if name = FSelectedInfo.FileName then
        ListView1SelectItem(nil, ListView1Selected, False);

      RefreshItem(index);
      Break;
    end;
  end;
end;

procedure TExplorerForm.MakeNewFolder1Click(Sender: TObject);
var
  S, FolderName : String;
  N : Integer;
begin
  FolderName:= L('New directory');
  S := IncludeTrailingBackslash(GetCurrentPath);
  N := 1;
  if DirectoryExists(S + FolderName) then
  begin
    repeat
      Inc(N);
    until not DirectoryExists(S + FolderName + ' (' + Inttostr(N) + ')');
    FolderName := FolderName + ' (' + Inttostr(N) + ')';
  end;
  if not CreateDir(S + FolderName) then
  begin
    MessageBoxDB(Handle, Format(L('Unable to create directory %s!'), [S + FolderName]), L('Error'), TD_BUTTON_OK,
      TD_ICON_ERROR);
    Exit;
  end;
  NewFileName := AnsiLowerCase(S + FolderName);
end;

procedure TExplorerForm.Copy2Click(Sender: TObject);
var
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    FileList.Add(GetCurrentPath);
    Copy_Move(True, FileList);
  finally
    FileList.Free;
  end;
end;

procedure TExplorerForm.OpenInNewWindow1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetNewPathW(Self.GetCurrentPathW,False);
    Show;
  end;
end;

function TExplorerForm.GetCurrentPath: string;
begin
  Result := GetCurrentPathW.Path;
end;

procedure TExplorerForm.SetPath(Path: String);
begin
 If not Self.Visible then
  begin
    SaveWindowPos1.Key := RegRoot + 'Explorer\' + MakeRegPath(Path);
    SaveWindowPos1.SetPosition;
  end;
  FCurrentPath := Path;
  SetNewPath(Path, False);
end;

procedure TExplorerForm.ShowUpdater1Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
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
  begin
    if ElvMain.Selection.Count = 0 then
    begin
      Item.Selected := True;
      Item.Focused := True;
      Item.MakeVisible(EmvTop);
    end;
  end;
end;

procedure TExplorerForm.ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include: Boolean; Big: Boolean = False);
var
  I, Index, C: Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      Index := MenuIndexToItemIndex(I);
      if (FFilesInfo[I].IsBigImage) and (Big = True) // если загружается большая картинка впервые
        then
        Exit;

      if Big then
        FFilesInfo[I].IsBigImage := True;

      if index > ElvMain.Items.Count - 1 then
        Exit;
      C := ElvMain.Items[index].ImageIndex;
      if ElvMain.Items[index].Data <> nil then
      begin
        Boolean(TDataObject(ElvMain.Items[index].Data).Include) := Include;
      end else
      begin
        ElvMain.Items[index].Data := TDataObject.Create;
        TDataObject(ElvMain.Items[index].Data).Include := Include;
      end;
      if C = -1 then
      begin
        FBitmapImageList.AddBitmap(nil);
        FFilesInfo[I].ImageIndex := FBitmapImageList.Count - 1;
        C := FBitmapImageList.Count - 1;
      end;

      FBitmapImageList[C].Graphic := Bitmap;
      FBitmapImageList[C].SelfReleased := True;

      ElvMain.Items[index].Invalidate(False);

      if FFilesInfo[I].FileType = EXPLORER_ITEM_FOLDER then
        if FFilesInfo[I].FileName = FSelectedInfo.FileName then
          if SelCount = 1 then
            ListView1SelectItem(nil, ListView1Selected, True);
      Break;
    end;
end;

procedure TExplorerForm.ReplaceIcon(Icon: TIcon; FileGUID: TGUID; Include : boolean);
var
  I, Index, C : Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      index := MenuIndexToItemIndex(I);
      if index > ElvMain.Items.Count - 1 then
        Exit;
      C := ElvMain.Items[index].ImageIndex;
      if ElvMain.Items[index].Data <> nil then
      begin
        TDataObject(ElvMain.Items[index].Data).Include := Include;
      end else
      begin
        ElvMain.Items[index].Data := TDataObject.Create;
        TDataObject(ElvMain.Items[index].Data).Include := Include;
      end;
      FBitmapImageList[C].Graphic := Icon;
      FBitmapImageList[C].SelfReleased := True;

      ElvMain.Items[index].Invalidate(False);

      if FFilesInfo[I].FileType = EXPLORER_ITEM_FOLDER then
        if FFilesInfo[I].FileName = FSelectedInfo.FileName then
          if SelCount = 1 then
            ListView1SelectItem(nil, ListView1Selected, True);
      Break;
    end;
end;

procedure TExplorerForm.AddBitmap(Bitmap: TBitmap; FileGUID: TGUID);
var
  I : Integer;
begin
  for I := FFilesInfo.Count - 1 downto 0 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      FBitmapImageList.AddBitmap(Bitmap);
      FFilesInfo[I].ImageIndex := FBitmapImageList.Count - 1;
      Break;
    end;
end;

procedure TExplorerForm.AddIcon(Icon: TIcon; SelfReleased : Boolean; FileGUID: TGUID);
var
  I : Integer;
begin
  for I := FFilesInfo.Count - 1 downto 0 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
      begin
        FBitmapImageList.AddIcon(Icon, SelfReleased);
        FFilesInfo[I].ImageIndex := FBitmapImageList.Count - 1;
        Break;
      end;
end;

function TExplorerForm.AddItem(FileGUID: TGUID; LockItems : Boolean = True): TEasyItem;
var
  I: Integer;
  Data: TDataObject;
begin
  Result := nil;
  for I := FFilesInfo.Count - 1 downto 0 do
    if IsEqualGUID(FFilesInfo[I].SID, FileGUID) then
    begin
      LockDrawIcon := True;

      Data := TDataObject.Create;
      Data.Include := FFilesInfo[I].Include;

      Result := ElvMain.Items.Add(Data);
      if not Data.Include then
        Result.BorderColor := GetListItemBorderColor(Data);
      Result.Tag := FFilesInfo[I].FileType;
      Result.ImageIndex := FFilesInfo[I].ImageIndex;

      if FFilesInfo[I].FileType <> EXPLORER_ITEM_DRIVE then
        Result.Caption := ExtractFileName(FFilesInfo[I].FileName)
      else
        Result.Caption := FFilesInfo[I].FileName;
      if IsEqualGUID(FileGUID, NewFileNameGUID) then
      begin
        Result.Selected := True;
        Result.Focused := True;
        ElvMain.EditManager.Enabled := True;
        Result.Edit;
        NewFileNameGUID := GetGUID;
      end;
      LockDrawIcon := False;
      if ElvMain.Groups[0].Visible then
        Result.Invalidate(False);
      Break;
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

      LockDrawIcon := False;
      if ElvMain.Groups[0].Visible then
        Result.Invalidate(False);
      Break;
    end;
end;

procedure TExplorerForm.ListView1KeyPress(Sender: TObject; var Key: Char);
var
  Handled : Boolean;
begin
  if Key = Chr(VK_RETURN) then
    EasyListview1DblClick(ElvMain, cmbLeft, Point(0, 0), [], Handled);
end;

procedure TExplorerForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  FEditHandle : THandle;
  InternalHandled : boolean;
  I : Integer;
begin
  {if Msg.message<>0 then
  if Msg.message<>15 then
  if Msg.message<>512 then
  if Msg.message<>275 then
  if Msg.message<>675 then
  if Msg.message<>256 then
  if Msg.message<>257 then
  if Msg.message<>45056 then
  if Msg.message<>45057 then
  if Msg.message<>160 then
  if Msg.message<>1060 then
  if Msg.message<>280 then
  if Msg.message<>8448 then
  Showmessage(Inttostr(Msg.message)); }

  if Msg.message = WM_KEYDOWN then
    if Msg.Wparam = VK_OEM_5 then
      if Length(CbPathEdit.Text) > 3 then
      begin
        SlashHandled := True;
        ComboBox1DropDown;
      end;

  if Msg.message = WM_MOUSEMOVE then
  begin
    FEditHandle := GetWindow(GetWindow(CbPathEdit.Handle, GW_CHILD), GW_CHILD);
    if FEditHandle = GetWindow(Msg.Hwnd, GW_CHILD) then
    begin
      if ComboPath <> ExtractFilePath(CbPathEdit.Text) then
      begin
        AutoCompliteTimer.Enabled := True;
        ComboPath := ExtractFilePath(CbPathEdit.Text);
      end;
    end;
  end;

  if Msg.Hwnd = ElvMain.Handle then
  begin
    if UpdatingList then
    begin
      if Msg.message = WM_RBUTTONDOWN then
        Msg.message := 0;
      if Msg.message = WM_LBUTTONDBLCLK then
        Msg.message := 0;
      if Msg.message = WM_LBUTTONDOWN then
      begin
        SetLength(FFilesToDrag, 0);
        SetLength(FListDragItems, 0);
        FDBCanDrag := False;
        FDBCanDragW := False;
        Msg.message := 0;
      end;
    end;

    if Msg.message = WM_RBUTTONDOWN then
      WindowsMenuTickCount := GetTickCount;

    if Msg.message = WM_MOUSEWHEEL then
    begin
      if CtrlKeyDown then
      begin
        if Msg.WParam > 0 then
          I := 1
        else
          I := -1;
        ListView1MouseWheel(ElvMain, [SsCtrl], I, Point(0, 0), InternalHandled);

        Msg.message := 0;
      end;

      Application.HideHint;
      THintManager.Instance.CloseHint;
    end;

    // middle mouse button
    if Msg.message = WM_MBUTTONDOWN then
    begin
      Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
      BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
      Msg.message := 0;
    end;
  end;

  if Msg.message = WM_KEYDOWN then
  begin
    WindowsMenuTickCount := GetTickCount;
    if (Msg.WParam = VK_LEFT) and CtrlKeyDown then
      SpeedButton1Click(Self);
    if (Msg.WParam = VK_RIGHT) and CtrlKeyDown then
      SpeedButton2Click(Self);
    if (Msg.WParam = VK_UP) and CtrlKeyDown then
      SpeedButton3Click(Self);
    if (Msg.WParam = 83) and CtrlKeyDown then
      if TbStop.Enabled then
        TbStopClick(Self);
    if (Msg.WParam = VK_F5) then
      SetPath(GetCurrentPath);
  end;

  if Msg.Hwnd = ElvMain.Handle then
    if Msg.message= WM_KEYDOWN then
    begin
      WindowsMenuTickCount := GetTickCount;

      if (Msg.WParam = 93) and CtrlKeyDown then
      begin
        if SelCount = 0 then
          ListView1ContextPopup(nil, ElvMain.ClientToScreen(Point(ElvMain.Left, ElvMain.Top)), InternalHandled);
      end;

      if (Msg.WParam = VK_APPS) then
        ListView1ContextPopup(ElvMain, Point(-1, -1), InternalHandled);

      if (Msg.WParam = VK_SUBTRACT) then
        ZoomIn;
      if (Msg.WParam = VK_ADD) then
        ZoomOut;

      if (Msg.WParam = VK_F2) then
        if ((FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
        begin
          if ListView1Selected <> nil then
          begin
            PmItemPopup.Tag := ItemIndexToMenuIndex(ListView1Selected.Index);
            Rename1Click(Self);
          end;
        end;

      if (Msg.WParam = VK_DELETE) and ShiftKeyDown then
      begin
        DeleteFiles(False);
        Exit;
      end;

      if (Msg.WParam = VK_DELETE) then
        DeleteFiles(True);

      if (Msg.WParam = 67) and CtrlKeyDown then
        Copy3Click(nil);
      if (Msg.WParam = 88) and CtrlKeyDown then
        Cut3Click(nil);
      if (Msg.WParam = 86) and CtrlKeyDown then
        Paste3Click(nil);
      if (Msg.WParam = 65) and CtrlKeyDown then
        SelectAll1Click(nil);
    end;
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
  MenuIndex : integer;
begin
  LockItems;
  try
    MenuIndex:=ItemIndexToMenuIndex(Index);
    ElvMain.Items.Delete(Index);
    fFilesInfo.Delete(MenuIndex);
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
  I, K, index: Integer;
  ExplorerViewInfo: TExplorerViewInfo;
  UpdaterInfo: TUpdaterInfo;
  FileName, FOldFileName: string;
  Info : TExplorerFileInfo;
begin
  if not FormLoadEnd then
    Exit;
  UpdaterInfo.ProcHelpAfterUpdate := nil;
  if not IsActualState(SID) then
    Exit;
  for K := 0 to Length(PInfo) - 1 do
    case PInfo[K].FAction of
      FILE_ACTION_ADDED:
        begin
          if FolderView then
            if GetExt(PInfo[K].FOldFileName) = 'LDB' then
              Exit;
          UpdaterInfo.IsUpdater := True;
          begin
            Info := TExplorerFileInfo.Create;
            Info.FileName := PInfo[K].FNewFileName;
            UpdaterInfo.FileInfo := Info;
            UpdaterInfo.NewFileItem := Self.NewFileName = AnsiLowerCase(Info.FileName);
            Self.NewFileName := '';
            ExplorerViewInfo.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
            ExplorerViewInfo.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
            ExplorerViewInfo.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
            ExplorerViewInfo.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
            ExplorerViewInfo.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
            ExplorerViewInfo.ShowThumbNailsForFolders := DBKernel.Readbool('Options',
              'Explorer_ShowThumbnailsForFolders', True);
            ExplorerViewInfo.SaveThumbNailsForFolders := DBKernel.Readbool('Options',
              'Explorer_SaveThumbnailsForFolders', True);
            ExplorerViewInfo.ShowThumbNailsForImages := DBKernel.Readbool('Options',
              'Explorer_ShowThumbnailsForImages', True);
            ExplorerViewInfo.View := ListView;
            ExplorerViewInfo.PictureSize := FPictureSize;
            TExplorerThread.Create('', SupportedExt, 0, ExplorerViewInfo, Self, UpdaterInfo, StateID);
          end;
        end;
      FILE_ACTION_REMOVED:
        begin
          if ElvMain = nil then
            Exit;
          if ElvMain.Items = nil then
            Exit;
          for I := 0 to ElvMain.Items.Count - 1 do
          begin
            Index := ItemIndexToMenuIndex(I);
            if Index > FFilesInfo.Count - 1 then
              Exit;
            FileName := FFilesInfo[index].FileName;
            FOldFileName := PInfo[K].FNewFileName;
            if FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER then
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
          I := FileNameToID(PInfo[K].FNewFileName);
          if not UpdatingNow(I) then
          begin
            AddUpdateID(I);
            // if ProcessedFilesCollection.ExistsFile(pInfo[k].FNewFileName)<>nil then
            RefreshItemByNameA(PInfo[K].FNewFileName);
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
            index := ItemIndexToMenuIndex(I);
            if index > FFilesInfo.Count - 1 then
              Exit;
            if AnsiLowerCase(FFilesInfo[index].FileName) = AnsiLowerCase(PInfo[K].FOldFileName) then
            begin
              if (not DirectoryExists(PInfo[K].FOldFileName) and DirectoryExists(PInfo[K].FNewFileName)) or
                (not FileExists(PInfo[K].FOldFileName) and FileExists(PInfo[K].FNewFileName)) then
              begin
                ElvMain.Items[I].Caption := ExtractFileName(PInfo[K].FNewFileName);
                FFilesInfo[index].FileName := PInfo[K].FNewFileName;
                if FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE then
                  if not ExtInMask(SupportedExt, GetExt(PInfo[K].FNewFileName)) then
                  begin
                    FFilesInfo[index].FileType := EXPLORER_ITEM_FILE;
                    FFilesInfo[index].ID := 0;
                  end;
                if FFilesInfo[index].FileType = EXPLORER_ITEM_FILE then
                  if ExtInMask(SupportedExt, GetExt(PInfo[K].FNewFileName)) then
                  begin
                    FFilesInfo[index].FileType := EXPLORER_ITEM_IMAGE;
                  end;
                if GetExt(PInfo[K].FOldFileName) <> GetExt(PInfo[K].FNewFileName) then
                  RefreshItemA(I);
                if AnsiLowerCase(FSelectedInfo.FileName) = AnsiLowerCase(PInfo[K].FOldFileName) then
                  ListView1SelectItem(ElvMain, ListView1Selected, ListView1Selected = nil);
              end
              else
                RenamefileWithDB(Self, PInfo[K].FOldFileName, PInfo[K].FNewFileName, FFilesInfo[index].ID, True);
              Continue;
            end;
          end;
        end;
    end;
end;

procedure TExplorerForm.LoadInfoAboutFiles(Info: TExplorerFileInfos);
begin
  FFilesInfo.Assign(Info);
end;

procedure TExplorerForm.AddInfoAboutFile(Info: TExplorerFileInfos);
var
  I, J : Integer;
  IsContinue : Boolean;
  InfoCount : Integer;
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
  I : Integer;
begin
  Result := false;
  for I := 0 to fFilesInfo.Count - 1 do
  If IsEqualGUID(fFilesInfo[I].SID, FileSID) then
  begin
    if not fFilesInfo[I].IsBigImage then
      Result := True;
    Break;
  end;
end;

function TExplorerForm.ItemIndexToMenuIndex(Index: Integer): Integer;
var
  I, N: Integer;
begin
  Result := 0;
  N := ElvMain.Items[index].ImageIndex;
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    if FFilesInfo[I].ImageIndex = N then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TExplorerForm.MenuIndexToItemIndex(Index: Integer): Integer;
var
  I, N: Integer;
begin
  Result := 0;
  N := FFilesInfo[index].ImageIndex;
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if ElvMain.Items[I].ImageIndex = N then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TExplorerForm.LockItems;
begin
  GlobalLock := True;
end;

procedure TExplorerForm.UnLockItems;
begin
  GlobalLock := False;
end;

procedure TExplorerForm.WaitForUnLock;
begin
  repeat
    Application.ProcessMessages;
  until not GlobalLock;
end;

procedure TExplorerForm.SetOldPath(Path: string);
begin
  FOldPatch := Path;
  NotSetOldPath := False;
end;

procedure TExplorerForm.FormShow(Sender: TObject);
begin
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

procedure TExplorerForm.Cut1Click(Sender: TObject);
var
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    FileList.Add(GetCurrentPath);
    Copy_Move(False, FileList);
  finally
    F(FileList);
  end;
end;

procedure TExplorerForm.Paste1Click(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
begin
  Files := TStringList.Create;
  try
    LoadFIlesFromClipBoard(Effects, Files);
    if Files.Count = 0 then
      Exit;

    if Effects = DROPEFFECT_MOVE then
    begin
      CopyFiles(Handle, Files, GetCurrentPath, True, False, Self);
      ClipBoard.Clear;
      TbPaste.Enabled := False;
    end;
    if (Effects = DROPEFFECT_COPY) or (Effects = DROPEFFECT_COPY + DROPEFFECT_LINK) or (Effects = DROPEFFECT_NONE) then
      CopyFiles(Handle, Files, GetCurrentPath, False, False);

  finally
    F(Files);
  end;
end;

procedure TExplorerForm.PmListPopupPopup(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
begin
  OpeninSearchWindow1.Visible:=True;
  Files:=TStringList.Create;
  try
    LoadFIlesFromClipBoard(Effects, Files);
    Paste1.Enabled := Files.Count > 0;
  finally
    Files.Free;
  end;

  MakeFolderViewer1.Visible := ((GetCurrentPathW.PType=EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType=EXPLORER_ITEM_DRIVE)) and not FolderView;

  if GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER then
  begin
    Paste1.Visible := False;
    Cut1.Visible := False;
    Copy2.Visible := False;
    Addfolder1.Visible := False;
    MakeNew1.Visible := False;
    OpeninSearchWindow1.Visible := False;
  end;
  if (GetCurrentPathW.PType = EXPLORER_ITEM_NETWORK) or (GetCurrentPathW.PType = EXPLORER_ITEM_WORKGROUP) or
    (GetCurrentPathW.PType = EXPLORER_ITEM_COMPUTER) then
  begin
    Paste1.Visible := False;
    Cut1.Visible := False;
    Copy2.Visible := False;
    Addfolder1.Visible := False;
    MakeNew1.Visible := False;
    OpeninSearchWindow1.Visible := False;
  end;
  if (GetCurrentPathW.PType = EXPLORER_ITEM_SHARE) then
  begin
    Cut1.Visible := False;
  end;
end;

procedure TExplorerForm.Cut2Click(Sender: TObject);
var
  I, Index : integer;
  FileList : TStrings;
begin
  FileList := TStringList.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      FileList.Add(ProcessPath(fFilesInfo[Index].FileName));
    end;
    Copy_Move(False, FileList);
  finally
    FileList.Free;
  end;
end;

procedure TExplorerForm.ShowProgress;
begin
  FStatusProgress.Show;

  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressState(Handle, TBPF_NORMAL);
end;

procedure TExplorerForm.HideLoadingSign;
begin
  LsMain.Hide;
end;

procedure TExplorerForm.HideProgress;
begin
  FStatusProgress.Hide;

  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressState(Handle, TBPF_NOPROGRESS);
end;

procedure TExplorerForm.SetProgressMax(Value: Integer);
begin
  FStatusProgress.Max := Value;
end;

procedure TExplorerForm.SetProgressPosition(Value: Integer);
begin
  FStatusProgress.Position := Value;

  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressValue(Handle, Value, FStatusProgress.Max);
end;

procedure TExplorerForm.SetStatusText(Text: string);
begin
  StatusBar1.Panels[0].Text := Text;
end;

procedure TExplorerForm.Button1Click(Sender: TObject);
begin
  FIsExplorer:=false;
  ListView1SelectItem(Sender, ListView1Selected, True);
  PropertyPanel.Show;
  CloseButtonPanel.Hide;
  DBkernel.WriteInteger('Explorer', 'LeftPanelWidthExplorer', MainPanel.Width);
  MainPanel.Width := DBKernel.ReadInteger('Explorer', 'LeftPanelWidth', 135);
  ListView1SelectItem(Sender, ListView1Selected, False);
end;

procedure TExplorerForm.SetPanelImage(Image: TBitmap; FileGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
    ImPreview.Picture.Graphic := Image;

end;

procedure TExplorerForm.SetPanelInfo(Info: TOneRecordInfo;
  FileGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    FSelectedInfo.Width := Info.ItemWidth;
    FSelectedInfo.Height := Info.ItemHeight;
    FSelectedInfo.Id := Info.ItemId;
    FSelectedInfo.Rating := Info.ItemRating;
    FSelectedInfo.Access := Info.ItemAccess;
    ReallignInfo;
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
    PmItemPopup.Tag := ItemIndexToMenuIndex(Item.index);
    PmItemPopup.Popup(ImPreview.Clienttoscreen(MousePos).X, ImPreview.Clienttoscreen(MousePos).Y);
  end else
    PmListPopup.Popup(ImPreview.Clienttoscreen(MousePos).X, ImPreview.Clienttoscreen(MousePos).Y);

end;

procedure TExplorerForm.PropertyPanelResize(Sender: TObject);
begin
  ReallignInfo;
end;

procedure TExplorerForm.ReallignToolInfo;
begin
  VerifyPaste(Self);

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)) then
  begin
    TbCopy.Enabled := SelCount <> 0;
  end else
    TbCopy.Enabled := False;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
  begin
    TbCut.Enabled := SelCount <> 0;
  end else
    TbCut.Enabled := False;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
  begin
    TbDelete.Enabled := SelCount <> 0;
  end else
    TbDelete.Enabled := False;

end;

procedure TExplorerForm.ReallignInfo;
const
  otstup = 15;
  H = 3;

var
  Index, I : Integer;
  B: Boolean;
  S: string;
  PersonalPath, MyPicturesPath: string;
  OldMode: Cardinal;

  function GetShellPath(name: string): string;
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

  function GetPersonalFolder : string;
  begin
    if PersonalPath = '' then
      PersonalPath := GetShellPath('Personal');
    Result := PersonalPath;
  end;

  function GetMyPicturesFolder : string;
  begin
    if MyPicturesPath = '' then
      MyPicturesPath := GetShellPath('My Pictures');
    Result := MyPicturesPath;
  end;

  function ValidLink(index: Integer): Boolean;
  var
    Path: string;
  begin
    Path := AnsiLowerCase(GetCurrentPath);
    Result := False;

    if FPlaces[index].MyComputer and (GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER) then
      Result := True
    else if FPlaces[index].MyDocuments and (Path = AnsiLowerCase(GetPersonalFolder)) then
      Result := True
    else if FPlaces[index].MyPictures and (Path = AnsiLowerCase(MyPicturesPath)) then
        Result := True;

    if not Result then
      if FPlaces[index].OtherFolder then
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

begin
  ScrollBox1.UpdatingPanel := True;
  IsReallignInfo:=true;
  EventLog('ReallignInfo...');

  VerifyPaste(self);

  LockWindowUpdate(Self.Handle);
  S := ExtractFileName(FSelectedInfo.FileName) + ' ';
  for I := Length(S) downto 1 do
    if S[I] = '&' then
      Insert('&', S, I);

  NameLabel.Caption := S;
  NameLabel.Constraints.MaxWidth := ScrollBox1.Width - ScrollBox1.Left - otstup - ScrollBox1.VertScrollBar.ButtonSize;
  NameLabel.Constraints.MinWidth := ScrollBox1.Width - ScrollBox1.Left - Otstup - ScrollBox1.VertScrollBar.ButtonSize;

  S := ExtractFileName(FSelectedInfo.FileName);
  for I := Length(S) downto 1 do
    if S[I] = '&' then
      Insert('&', S, I);

  NameLabel.Caption := S;
  TypeLabel.Caption := FSelectedInfo.FileTypeW;
  if FSelectedInfo.FileTypeW <> '' then
  begin
    TypeLabel.Top := NameLabel.Top + NameLabel.Height + H;
    TypeLabel.Visible := True;
  end else
  begin
    TypeLabel.Top := NameLabel.Top;
    TypeLabel.Visible := False;
  end;

  if Min(FSelectedInfo.Width, FSelectedInfo.Height)= 0 then
  begin
    if FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE then
    begin
      OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      if DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1) <> -1 then
      begin
        DimensionsLabel.Top := TypeLabel.Top + TypeLabel.Height + H;
        DimensionsLabel.Visible := True;
        DimensionsLabel.Caption := L('Free space') + ':';
      end else
      begin
        DimensionsLabel.Top := TypeLabel.Top;
        DimensionsLabel.Visible := False;
      end;
      SetErrorMode(OldMode);
    end else
    begin
      DimensionsLabel.Top := TypeLabel.Top;
      DimensionsLabel.Visible := False;
    end;
  end else
  begin
    DimensionsLabel.Top := TypeLabel.Top + TypeLabel.Height + H;
    DimensionsLabel.Visible := True;
    DimensionsLabel.Caption := IntToStr(FSelectedInfo.Width) + 'x' + IntToStr(FSelectedInfo.Height);
  end;

  if (FSelectedInfo.Size <> -1) or (FSelectedInfo.FileType= EXPLORER_ITEM_DRIVE) then
  begin
    if FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE then
    begin
      OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      if DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1) <> -1 then
      begin
        SizeLabel.Caption := Format(L('%s from %s'),
          [SizeInText(DiskFree(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1)),
          SizeInText(DiskSize(Ord(AnsiLowerCase(FSelectedInfo.FileName)[1]) - Ord('a') + 1))]);
        SizeLabel.Visible := True;
        SizeLabel.Top := DimensionsLabel.Top + DimensionsLabel.Height + H;
      end else
      begin
        SizeLabel.Visible := False;
        SizeLabel.Top := DimensionsLabel.Top;
      end;
      SetErrorMode(OldMode);
    end else
    begin
      SizeLabel.Caption := Format(L('Size = %s'), [SizeInText(FSelectedInfo.Size)]);
      SizeLabel.Visible := True;
      SizeLabel.Top := DimensionsLabel.Top + DimensionsLabel.Height + H;
    end;
  end else
  begin
    SizeLabel.Visible := False;
    SizeLabel.Top := DimensionsLabel.Top;
  end;

  if FSelectedInfo.ID <> 0 then
  begin
    DBInfoLabel.Top := SizeLabel.Top + SizeLabel.Height + H;
    IDLabel.Caption := Format(L('ID = %d'), [FSelectedInfo.ID]);
    IDLabel.Top := DBInfoLabel.Top + DBInfoLabel.Height + H;
    if FSelectedInfo.Rating <> 0 then
    begin
      RatingLabel.Caption := Format(L('Rating = %d'), [FSelectedInfo.Rating]);
      RatingLabel.Top := IDLabel.Top + IDLabel.Height + H;
    end else
    begin
      RatingLabel.Top := IDLabel.Top;
    end;
    if FSelectedInfo.Access = Db_access_private then
    begin
      AccessLabel.Caption := L('Private image');
      AccessLabel.Top := RatingLabel.Top + RatingLabel.Height + H;
    end else
    begin
      AccessLabel.Top := RatingLabel.Top;
    end;
    DBInfoLabel.Show;
    IDLabel.Show;
    if FSelectedInfo.Rating <> 0 then
      RatingLabel.Show;
    if FSelectedInfo.Access = Db_access_private then
      AccessLabel.Show;
  end else
  begin
    AccessLabel.Top := SizeLabel.Top;
    DBInfoLabel.Hide;
    IDLabel.Hide;
    RatingLabel.Hide;
    AccessLabel.Hide;
  end;
  TasksLabel.Top := Max(AccessLabel.Top + AccessLabel.Height + H * 4, NameLabel.Top + NameLabel.Height + H * 4);
  if (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
    (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) then
  begin
    SlideShowLink.Visible := True;
    SlideShowLink.Top := TasksLabel.Top + TasksLabel.Height + H;
  end else
  begin
    SlideShowLink.Visible := False;
    SlideShowLink.Top := TasksLabel.Top;
  end;

  if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) and (SelCount = 1) then
  begin
    ImageEditorLink.Visible := True;
    ImageEditorLink.Top := SlideShowLink.Top + SlideShowLink.Height + H;
  end else
  begin
    ImageEditorLink.Visible := False;
    ImageEditorLink.Top := SlideShowLink.Top;
  end;

  if (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
  begin
    PrintLink.Visible := True;
    PrintLink.Top := ImageEditorLink.Top + ImageEditorLink.Height + H;
  end else
  begin
    PrintLink.Visible := False;
    PrintLink.Top := ImageEditorLink.Top;
  end;

  if (((((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE))) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)) and (SelCount = 1)) then
  begin
    ShellLink.Visible := True;
    ShellLink.Top := PrintLink.Top + PrintLink.Height + H;
  end else
  begin
    ShellLink.Visible := False;
    ShellLink.Top := PrintLink.Top;
  end;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)) then
  begin
    CopyToLink.Visible := True;
    TbCopy.Enabled := SelCount <> 0;
    CopyToLink.Top := ShellLink.Top + ShellLink.Height + H;
  end else
  begin
    CopyToLink.Visible := False;
    TbCopy.Enabled := False;
    CopyToLink.Top := ShellLink.Top;
  end;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
  begin
    if SelCount <> 0 then
    begin
      MoveToLink.Top := CopyToLink.Top + CopyToLink.Height + H;
      MoveToLink.Visible := True;
      TbCut.Enabled := True;
    end else
    begin
      TbCut.Enabled := False;
      MoveToLink.Top := CopyToLink.Top;
    end;
  end else
  begin
    MoveToLink.Visible := False;
    TbCut.Enabled := False;
    MoveToLink.Top := CopyToLink.Top;
  end;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) and
    (SelCount <> 0) then
  begin
    RenameLink.Visible := True;
    RenameLink.Top := MoveToLink.Top + MoveToLink.Height + H;
  end
  else begin
    RenameLink.Visible := False;
    RenameLink.Top := MoveToLink.Top;
  end;

  if (((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER)) and (SelCount = 1)) or
    ((SelCount = 0) and ((FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER))) or
    (((FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE)) and
      (SelCount > 1)) then
  begin
    PropertiesLink.Visible := True;
    PropertiesLink.Top := RenameLink.Top + RenameLink.Height + H;
  end else
  begin
    PropertiesLink.Visible := False;
    PropertiesLink.Top := RenameLink.Top;
  end;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE)) then
  begin
    if SelCount <> 0 then
    begin
      TbDelete.Enabled := True;
      DeleteLink.Visible := True;
      DeleteLink.Top := PropertiesLink.Top + PropertiesLink.Height + H;
    end else
    begin
      TbDelete.Enabled := False;
      DeleteLink.Visible := False;
      DeleteLink.Top := PropertiesLink.Top;
    end;
  end else
  begin
    TbDelete.Enabled := False;
    DeleteLink.Top := PropertiesLink.Top;
  end;

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

  if B then
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
    AddLink.Top := DeleteLink.Top + DeleteLink.Height + H;
  end else
  begin
    AddLink.Visible := False;
    AddLink.Top := DeleteLink.Top;
  end;

  if (((FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE)) and (SelCount = 0)) or
    ((SelCount > 0) and ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
        (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE))) then
  begin
    RefreshLink.Visible := True;
    RefreshLink.Top := AddLink.Top + AddLink.Height + H;
  end else
  begin
    RefreshLink.Visible := False;
    RefreshLink.Top := AddLink.Top;
  end;

  if ((FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
      (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER)) and ExplorerManager.ShowQuickLinks and (SelCount < 2) then
  begin
    OtherPlacesLabel.Show;
    MyPicturesLink.Show;
    MyDocumentsLink.Show;
    MyComputerLink.Show;
    DesktopLink.Show;

    OtherPlacesLabel.Top := RefreshLink.Top + RefreshLink.Height + H * 4;
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
      end
      else
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
  ScrollBox1Reallign(nil);
  ScrollBox1.Realign;

  if HelpNO = 2 then
    if FSelectedInfo.Id = 0 then
      if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
        if SelCount < 3 then
        begin
          Activate;
          DoHelpHintCallBackOnCanClose(L('Help'), TEXT_MES_HELP_2, Point(0, 0), AddLink, Help1NextClick,
            TEXT_MES_NEXT_HELP, Help1CloseClick);
        end;
  LockwindowUpdate(0);
  EventLog('ReallignInfo OK');
end;

procedure TExplorerForm.CopyToLinkClick(Sender: TObject);
var
  EndDir : String;
  I, Index : integer;
  Files : TStringList;
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
      CopyFiles(Handle, Files, EndDir, False, False);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.MoveToLinkClick(Sender: TObject);
var
  EndDir : String;
  I, Index : integer;
  Files : TStringList;
  DlgCaption : String;
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

procedure TExplorerForm.Paste2Click(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
begin
  Files:=TStringList.Create;
  try
    LoadFilesFromClipBoard(Effects, Files);
    if Files.Count = 0 then
      Exit;

    if Effects = DROPEFFECT_MOVE then
    begin
      CopyFiles(Handle, Files, FFilesInfo[PmItemPopup.Tag].FileName, True, False, Self);
      ClipBoard.Clear;
      TbPaste.Enabled := False;
    end;
    if (Effects = DROPEFFECT_COPY) or (Effects = DROPEFFECT_COPY + DROPEFFECT_LINK) or (Effects = DROPEFFECT_NONE) then
      CopyFiles(Handle, Files, FFilesInfo[PmItemPopup.Tag].FileName, False, False);
  finally
    F(Files);
  end;
end;

procedure TExplorerForm.ExplorerPanel1Click(Sender: TObject);
var
  S: string;
begin
  if not TreeView.UseShellImages then
  begin
    TreeView.UseShellImages := True;
    TreeView.ObjectTypes := [OtFolders, OtHidden];
    TreeView.Refresh(TreeView.TopItem);
  end;
  PropertyPanel.Hide;
  try
    if GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER then
      TreeView.Path := 'C:\';
    if (GetCurrentPathW.PType = EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType = EXPLORER_ITEM_DRIVE) or
      (GetCurrentPathW.PType = EXPLORER_ITEM_COMPUTER) or (GetCurrentPathW.PType = EXPLORER_ITEM_SHARE) then
    begin
      S := GetCurrentPath;
      if Length(S) = 2 then
        S := IncludeTrailingBackslash(S);
      TreeView.Path := S;
    end;
    if GetCurrentPathW.PType = EXPLORER_ITEM_NETWORK then
      TreeView.Path := 'C:\';
    if GetCurrentPathW.PType = EXPLORER_ITEM_WORKGROUP then
      TreeView.Path := 'C:\';
  except
  end;
  FIsExplorer := True;
  CloseButtonPanel.Show;
  MainPanel.Width := DBKernel.ReadInteger('Explorer', 'LeftPanelWidthExplorer', 135);
end;

{ TManagerExplorer }

procedure TManagerExplorer.LoadEXIF;
begin
  FShowEXIF := DBKernel.ReadBool('Options', 'ShowEXIFMarker', False);
end;

procedure TManagerExplorer.AddExplorer(Explorer: TExplorerForm);
begin
  FShowEXIF := DBKernel.ReadBool('Options', 'ShowEXIFMarker', False);
  ShowQuickLinks := DBKernel.ReadBool('Options', 'ShowOtherPlaces', True);

  if FExplorers.IndexOf(Explorer) = -1 then
    FExplorers.Add(Explorer);

  if FForms.IndexOf(Explorer) = -1 then
    FForms.Add(Explorer);

end;

constructor TManagerExplorer.Create;
begin
  FSync := TCriticalSection.Create;
  FExplorers := TList.Create;
  FForms := TList.Create;
  FShowPrivate := False;
end;

destructor TManagerExplorer.Destroy;
begin
  F(FExplorers);
  F(FForms);
  F(FSync);
  inherited;
end;

function TManagerExplorer.ExplorersCount: Integer;
begin
  FSync.Enter;
  try
    Result := FExplorers.Count;
  finally
    FSync.Leave;
  end;
end;

procedure TManagerExplorer.FreeExplorer(Explorer: TExplorerForm);
begin
//
end;

function TManagerExplorer.GetExplorerBySID(SID: String): TExplorerForm;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FExplorers.Count - 1 do
      if IsEqualGUID(TExplorerForm(FExplorers[I]).StateID, StringToGUID(SID)) then
      begin
        Result := FExplorers[I];
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.GetExplorerNumber(
  Explorer: TExplorerForm): Integer;
begin
  FSync.Enter;
  try
    Result := FExplorers.IndexOf(Explorer);
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.GetExplorersTexts: TStrings;
var
  I: Integer;
  B: Boolean;
  S: string;
begin
  Result := TStringList.Create;
  FSync.Enter;
  try
    for I := 0 to FExplorers.Count - 1 do
      Result.Add(TForm(FExplorers[I]).Caption);

    repeat
      B := False;
      for I := 0 to Result.Count - 2 do
        if Comparestr(Result[I], Result[I + 1]) > 0 then
        begin
          S := Result[I];
          Result[I] := Result[I + 1];
          Result[I + 1] := S;
          B := True;
        end;
    until not B;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.IsExplorer(Explorer: TExplorerForm): Boolean;
begin
  FSync.Enter;
  try
    Result := FExplorers.IndexOf(Explorer) <> -1;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.IsExplorerForm(Explorer: TForm): Boolean;
begin
  FSync.Enter;
  try
    Result := FForms.IndexOf(Explorer) <> -1;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.NewExplorer(GoToLastSavedPath : Boolean): TExplorerForm;
begin
  if not DBKernel.ProgramInDemoMode then
  begin
    if FolderView or (CharToInt(DBkernel.GetCodeChar(4))<>CharToInt(DBkernel.GetCodeChar(2))*(CharToInt(DBkernel.GetCodeChar(3))+1)*123 mod 15) then
    begin
      if FExplorers.Count > 0 then
      begin
        Result:=FExplorers[0];
        exit;
      end;
    end;
  end;
  Result := TExplorerForm.Create(Application, GoToLastSavedPath);
end;

procedure TManagerExplorer.RemoveExplorer(Explorer: TExplorerForm);
begin
  FSync.Enter;
  try
    FExplorers.Remove(Explorer);
    FForms.Remove(Explorer);
  finally
    FSync.Leave;
  end;
end;

procedure TExplorerForm.SetNewPath(Path : String; Explorer : Boolean);
var
  s,s1 : string;
  i : integer;
  oldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
  if Explorer then
    EventLog('SetNewPath "' + Path + '" <Explorer>')
  else
    EventLog('SetNewPath "' + Path + '"');
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
      if (AnsiLowerCase(Path) = AnsiLowerCase(MyComputer)) or (Path='') then
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

procedure TExplorerForm.GoToSearchWindow1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
  NewSearch := SearchManager.GetAnySearch;
  NewSearch.Show;
  NewSearch.SetFocus;
end;

procedure TExplorerForm.ImPreviewDblClick(Sender: TObject);
var
  MenuInfo : TDBPopupMenuInfo;
  Info : TRecordsInfo;
begin
  if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
  begin
    MenuInfo := Self.GetCurrentPopUpMenuInfo(ListView1Selected);
    try
      if Viewer = nil then
        Application.CreateForm(TViewer, Viewer);
      DBPopupMenuInfoToRecordsInfo(MenuInfo, Info);
      Viewer.Execute(Sender, Info);
    finally
      F(MenuInfo);
    end;
    Exit;
  end;
end;

procedure TExplorerForm.CMMOUSELEAVE(var Message: TWMNoParams);
var
  P : TPoint;
begin
  GetCursorPos(p);
  if THintManager.Instance.HintAtPoint(P) <> nil then
    Exit;

  LastMouseItem:= nil;
  Application.HideHint;
  THintManager.Instance.CloseHint;
  Hinttimer.Enabled := False;
end;

procedure TExplorerForm.Copy3Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  if SelCount= 0 then
    Copy2Click(Sender)
  else
    Copy1Click(Sender);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_CopyPaste], EventInfo);
end;

procedure TExplorerForm.Cut3Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  if SelCount= 0 then
    Cut1Click(Sender)
  else
    Cut2Click(Sender);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_CopyPaste], EventInfo);
end;

procedure TExplorerForm.Options1Click(Sender: TObject);
begin
  if OptionsForm = nil then
    Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.Show;
end;

procedure TExplorerForm.DBManager1Click(Sender: TObject);
begin
  if ManagerDB = nil then
    Application.CreateForm(TManagerDB, ManagerDB);
  ManagerDB.Show;
end;

procedure TExplorerForm.DeleteLinkClick(Sender: TObject);
var
  Files : TStringList;
begin
  if SelCount<>0 then
    Delete1Click(Sender)
  else
  begin
    Files := TStringList.Create;
    try
      Files.Add(GetCurrentPath);
      uFileUtils.DeleteFiles(Handle, Files, True);
    finally
      F(Files);
    end;
  end;
end;

procedure TExplorerForm.PropertiesLinkClick(Sender: TObject);
var
  Item: TEasyItem;
  index: Integer;
begin
  if SelCount > 1 then
  begin
    Item := ListView1Selected;
    if Item = nil then
      Exit;
    index := ItemIndexToMenuIndex(Item.index);
    PmItemPopup.Tag := index;
    if index > FFilesInfo.Count - 1 then
      Exit;
    if (FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE) or (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or
      (FFilesInfo[index].FileType = EXPLORER_ITEM_FILE) then
      Properties1Click(Sender);
    Exit;
  end;
  if SelCount = 0 then
  begin
    if FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER then
      ShowMyComputerProperties(Handle)
    else
      ShowPropertiesDialog(GetCurrentPath)
  end else
  begin
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
begin
  if SelCount <> 0 then
  begin
    PmItemPopup.Tag := ItemIndexToMenuIndex(ListView1Selected.index);
    SlideShow1Click(Sender)
  end else
  begin
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    Viewer.ShowFolderA(GetCurrentPath, ExplorerManager.ShowPrivate);
  end;
end;

procedure TExplorerForm.InfoPanel1Click(Sender: TObject);
begin
  Button1Click(Sender);
end;

function TExplorerForm.InternalGetImage(FileName: string;
  Bitmap: TBitmap): Boolean;
var
  I, Index : Integer;
begin
  Result := False;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    if ElvMain.Items[I].ImageIndex <> -1 then
    begin
      Index := ItemIndexToMenuIndex(I);
      if AnsiLowerCase(FFilesInfo[Index].FileName) = FileName then
      begin
        if FBitmapImageList[ElvMain.Items[I].ImageIndex].IsBitmap then
        begin
          Bitmap.Assign(FBitmapImageList[ElvMain.Items[I].ImageIndex].Graphic);
          Result := True;
        end;
      end;
    end;
  end;
end;

function TExplorerForm.GetThreadsCount: Integer;
begin
  Result := Self.FReadingFolderNumber;
end;

procedure TExplorerForm.Paste3Click(Sender: TObject);
var
  EventInfo: TEventValues;
begin
  if SelCount = 0 then
    Paste1Click(Sender)
  else
    Paste2Click(Sender);
  DBKernel.DoIDEvent(Self, 0, [EventID_Param_CopyPaste], EventInfo);
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

procedure TExplorerForm.OpeninSearchWindow1Click(Sender: TObject);
var
  NewSearch: TSearchForm;
begin
  NewSearch := SearchManager.NewSearch;
  NewSearch.SearchEdit.Text := ':Folder(' + GetCurrentPath + '):';
  NewSearch.SetPath(GetCurrentPath);
  NewSearch.DoSearchNow(nil);
  NewSearch.Show;
  NewSearch.SetFocus;
end;

procedure TExplorerForm.LoadLanguage;
begin
  BeginTranslate;
  try
    SlideShowLink.Text:= L('Slide show');
    ShellLink.Text := L('Execute');
    CopyToLink.Text := L('Copy to');
    MoveToLink.Text := L('Move to');
    RenameLink.Text := L('Rename');
    PropertiesLink.Text := L('Properties');
    DeleteLink.Text := L('Delete');
    RefreshLink.Text := L('Refresh');
    ImageEditorLink.Text := L('Image editor');
    PrintLink.Text := L('Print');
    MyPicturesLink.Text := L('My pictures');
    MyDocumentsLink.Text := L('My documents');
    DesktopLink.Text := L('Desktop');
    MyComputerLink.Text := L('My Computer');
    AddLink.Text := L('Add to DB');

    Label1.Caption := L('Preview');
    TasksLabel.Caption := L('Tasks');
    Open1.Caption := L('Open');
    Open2.Caption := L('Open');
    SlideShow1.Caption := L('Show');
    NewWindow1.Caption := L('New Window');
    Shell1.Caption := L('Execute');
    DBitem1.Caption := L('DB Item');
    Copy1.Caption := L('Copy');
    Cut2.Caption := L('Cut');
    Paste2.Caption := L('Paste');
    Delete1.Caption := L('Delete');
    Rename1.Caption := L('Rename');
    New1.Caption := L('New');
    Directory1.Caption := L('Directory');
    Refresh1.Caption := L('Refresh');
    Properties1.Caption := L('Properties');
    AddFile1.Caption := L('Add file');
    OpenInNewWindow1.Caption := L('Open in new window');
    OpenInNewWindow2.Caption := L('Open in new window');
    Copy2.Caption := L('Copy');
    Cut1.Caption := L('Cut');
    Paste1.Caption := L('Paste');
    Addfolder1.Caption := L('Add folder');
    MakeNew1.Caption := L('Make new');

    Directory2.Caption := L('Directory');
    TextFile2.Caption := L('Text file');

    ShowUpdater1.Caption := L('Show update window');
    OpeninSearchWindow1.Caption := L('Open in search window');
    Refresh2.Caption := L('Refresh');
    SelectAll1.Caption := L('Select all');
    GoToSearchWindow1.Caption := L('Go to search window');
    Exit2.Caption := L('Exit');
    OpeninExplorer1.Caption := L('Open in explorer');
    OpeninExplorer1.Caption := L('Open in explorer');
    AddFolder2.Caption := L('Add folder');

    Label2.Caption := L('Address');
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
    RefreshID1.Caption := L('Refresh DB info');
    DBInfoLabel.Caption := L('DB Info') + ':';
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

    SendTo1.Caption := L('Send to');
    View2.Caption := L('Slide show');

    Sortby1.Caption := L('Sort by');

    Nosorting1.Caption := L('No sorting');
    FileName1.Caption := L('File name');
    Size1.Caption := L('File size');
    Type1.Caption := L('File type');
    Modified1.Caption := L('Modify date');
    Rating1.Caption := L('Rating');
    Number1.Caption := L('Number');
    SetFilter1.Caption := L('Set filter');

    MakeFolderViewer1.Caption := L('Make DB viewer');
    MakeFolderViewer2.Caption := L('Make DB viewer');

    Thumbnails1.Caption := L('Thumbnail');
    Tile2.Caption := L('Tile');
    Icons1.Caption := L('Icons');
    SmallIcons1.Caption := L('Table');
    List1.Caption := L('List');

    StenoGraphia1.Caption := L('Data hidding');
    AddHiddenInfo1.Caption := L('Hide data in image');
    ExtractHiddenInfo1.Caption := L('Extract hidden data');

    MapCD1.Caption := L('Map CD with DB');

    TbCut.Caption := L('Cut');
    TbCopy.Caption := L('Copy');
    TbPaste.Caption := L('Paste');
    TbOptions.Caption := L('Options');
    TbBack.Hint := L('Back');
    TbForward.Hint := L('Forward');
    TbUp.Hint := L('Go up');
    TbCut.Hint := L('Cut');
    TbCopy.Hint := L('Copy');
    TbPaste.Hint := L('Paste');
    TbDelete.Hint := L('Delete');
    ToolButtonView.Hint := L('View');
    TbZoomIn.Hint := L('Zoom in');
    TbZoomOut.Hint := L('Zoom out');
    TbSearch.Hint := L('Go to search window');
    TbStop.Hint := L('Stop');
    TbOptions.Hint := L('Options');
    ToolBar1.ShowCaptions := True;
    ToolBar1.AutoSize := True;
  finally
    EndTranslate;
  end;
end;

procedure TExplorerForm.Help1Click(Sender: TObject);
begin
  ShowAbout;
end;

procedure TExplorerForm.PopupMenu8Popup(Sender: TObject);
begin
 if TreeView.SelectedFolder<>nil then
 begin
    TempFolderName := TreeView.SelectedFolder.PathName;
    OpeninExplorer1.Visible := DirectoryExists(TempFolderName);
    AddFolder2.Visible := OpeninExplorer1.Visible;
    View2.Visible := OpeninExplorer1.Visible;
  end else
  begin
    TempFolderName := '';
    OpeninExplorer1.Visible := False;
    AddFolder2.Visible := False;
    View2.Visible := False;
  end;
end;

procedure TExplorerForm.OpeninExplorer1Click(Sender: TObject);
begin
  with ExplorerManager.NewExplorer(False) do
  begin
    SetPath(Self.TempFolderName);
    Show;
    SetFocus;
  end;
end;

procedure TExplorerForm.AddFolder2Click(Sender: TObject);
begin
  if UpdaterDB = nil then
    UpdaterDB := TUpdaterDB.Create;
  UpdaterDB.AddDirectory(TempFolderName, nil);
end;

procedure TExplorerForm.AddLinkClick(Sender: TObject);
begin
  AddFile1Click(Sender);
end;

procedure TExplorerForm.ScrollBox1Resize(Sender: TObject);
begin
  ScrollBox1.BackgroundLeft:=ScrollBox1.Width-ScrollBox1.BackGround.Width - 3;
  ScrollBox1.BackgroundTop := ScrollBox1.Height - ScrollBox1.BackGround.Height - 3;

  if ScrollBox1.VertScrollBar.Visible then
  begin
    // MainPanel.Width:=117+GetSystemMetrics(SM_CYHSCROLL);
    // ScrollBox1.VertScrollBar.Visible:=true;
  end;
end;

procedure TExplorerForm.SetNewPathW(WPath: TExplorerPath; Explorer: Boolean; FileMask: string = '');
var
  Info: TExplorerViewInfo;
  OldDir, S, Path: string;
  UpdaterInfo: TUpdaterInfo;
  I, ThreadType: Integer;
begin
  RefreshIDList.Clear;
  UpdaterInfo.ProcHelpAfterUpdate := nil;
  EventLog('SetNewPathW "' + WPath.Path + '"');
  FDBCanDragW := False;
  FDBCanDrag := False;
  TbUp.Enabled := WPath.PType <> EXPLORER_ITEM_MYCOMPUTER;
  OldDir := GetCurrentPath;
  Path := WPath.Path;
  ThreadType := THREAD_TYPE_FOLDER;
  if Length(Path) > 2 then
    for I := Length(Path) downto 3 do
      if Path[I] = '/' then
        Delete(Path, I, 1);
  if Length(Path) > 2 then
    for I := Length(Path) downto 3 do
      if (Path[I] = '\') and (Path[I - 1] = '\') then
        Delete(Path, I, 1);

  Path := ExcludeTrailingBackslash(Path);
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
  if WPath.PType <> EXPLORER_ITEM_MYCOMPUTER then
    Path := LongFileName(Path);
  if WPath.PType = EXPLORER_ITEM_MYCOMPUTER then
  begin
    Caption := MyComputer;
    CbPathEdit.Text := MyComputer;
    ThreadType := THREAD_TYPE_MY_COMPUTER;
  end;
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or (WPath.PType = EXPLORER_ITEM_SHARE)
    then
  begin
    S := ExcludeTrailingBackslash(Path);
    Caption := S;
    CbPathEdit.Text := Path;
  end;
  if WPath.PType = EXPLORER_ITEM_NETWORK then
  begin
    Caption := Path;
    CbPathEdit.Text := Path;
    ThreadType := THREAD_TYPE_NETWORK;
  end;
  if WPath.PType = EXPLORER_ITEM_WORKGROUP then
  begin
    Caption := Path;
    CbPathEdit.Text := Path;
    ThreadType := THREAD_TYPE_WORKGROUP;
  end;
  if WPath.PType = EXPLORER_ITEM_COMPUTER then
  begin
    Caption := Path;
    CbPathEdit.Text := Path;
    ThreadType := THREAD_TYPE_COMPUTER;
  end;
  S := Path;

  NewFormState;
  FCurrentPath := Path;
  FCurrentTypePath := WPath.PType;
  ListView1SelectItem(nil, nil, False);
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) then
    S := IncludeTrailingBackslash(S);
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or
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


  if FChangeHistoryOnChPath then
    if (FHistory.LastPath.Path <> S) or (FHistory.LastPath.PType <> WPath.PType) then
      FHistory.Add(ExplorerPath(S, WPath.PType));
  FChangeHistoryOnChPath := True;
  if (WPath.PType = EXPLORER_ITEM_MYCOMPUTER) { or not DirectoryExists(GetCurrentPath) } then
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

  DoSelectItem;
  FBitmapImageList.Clear;

  Info.OldFolderName := FOldPatch;
  Info.ShowPrivate := ExplorerManager.ShowPrivate;
  Info.PictureSize := FPictureSize;

  case ListView of
    LV_THUMBS:
      begin
        ElvMain.View := ElsThumbnail;
      end;
    LV_ICONS:
      begin
        ElvMain.View := ElsIcon;
      end;
    LV_SMALLICONS:
      begin
        ElvMain.View := ElsSmallIcon;
      end;
    LV_TITLES:
      begin
        ElvMain.View := ElsList;
      end;
    LV_TILE:
      begin
        ElvMain.View := ElsTile;
      end;
    LV_GRID:
      begin
        ElvMain.View := ElsGrid;
      end;
  end;

  UpdaterInfo.IsUpdater := False;
  UpdaterInfo.FileInfo := nil;
  Inc(FReadingFolderNumber);

  Info.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
  Info.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Info.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Info.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Info.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
  Info.ShowThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Info.SaveThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Info.ShowThumbNailsForImages := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Info.View := ListView;
  EventLog('ExplorerThread');
  if ElvMain <> nil then
  begin
    TbStop.Enabled := True;
    TExplorerThread.Create(Path, FileMask, ThreadType, Info, Self, UpdaterInfo, StateID);
  end;
  if FIsExplorer then
    if not Explorer then
      if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or
        (WPath.PType = EXPLORER_ITEM_COMPUTER) or (WPath.PType = EXPLORER_ITEM_SHARE) then
        try
          S := GetCurrentPath;
          if Length(S) = 2 then
            S := IncludeTrailingBackslash(S);
          TreeView.Path := S;
          TreeView.Select(TreeView.Selected);
        except
        end;
  DropFileTarget1.Unregister;
  if (WPath.PType = EXPLORER_ITEM_FOLDER) or (WPath.PType = EXPLORER_ITEM_DRIVE) or (WPath.PType = EXPLORER_ITEM_SHARE)
    then
    DropFileTarget1.register(ElvMain);

  if not NotSetOldPath then
  begin
    FOldPatch := Path;
    FOldPatchType := WPath.PType;
  end;

  if FileMask <> '' then
    Caption := Caption + ' [' + FileMask + ']';
  EventLog('SetPath OK');
end;

function TExplorerForm.GetCurrentPathW: TExplorerPath;
begin
  Result.Path := FCurrentPath;
  Result.PType := FCurrentTypePath;
end;

procedure TExplorerForm.RefreshLinkClick(Sender: TObject);
begin
 if (SelCount=0) or (GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER) then
    Refresh2Click(Sender)
  else
    Refresh1Click(Sender);
end;

procedure TExplorerForm.DoBack;
begin
  if fHistory.CanBack then
   SetNewPathW(fHistory.DoBack, False)
  else
    SetNewPathW(ExplorerPath('', EXPLORER_ITEM_MYCOMPUTER), False);
end;

procedure TExplorerForm.JumpHistoryClick(Sender: TObject);
var
  N : integer;
begin
  N := (Sender as TMenuItem).Tag;
  FChangeHistoryOnChPath := False;
  FHistory.Position := N;
  HistoryChanged(Sender);
  SetNewPathW(FHistory[N], False);
end;

procedure TExplorerForm.DragTimerTimer(Sender: TObject);
var
  ListItem: TEasyItem;
  p : TPoint;
  Index : Integer;
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
  ShowActivationDialog;
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

procedure TExplorerForm.ResetPassword1Click(Sender: TObject);
var
  I, Index : integer;
  Options : TCryptImageThreadOptions;
  ItemFileNames: TArStrings;
  ItemIDs: TArInteger;
  ItemSelected: TArBoolean;
  Password: string;
begin
  Password := DBKernel.FindPasswordForCryptImageFile(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName));
  if Password = '' then
    Password := GetImagePasswordFromUser(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName));

  Setlength(ItemFileNames, FFilesInfo.Count);
  Setlength(ItemIDs, FFilesInfo.Count);
  Setlength(ItemSelected, FFilesInfo.Count);

  // be default unchecked
  for I := 0 to FFilesInfo.Count - 1 do
    ItemSelected[I] := False;

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      index := ItemIndexToMenuIndex(I);
      ItemFileNames[index] := ProcessPath(FFilesInfo[index].FileName);
      ItemIDs[index] := FFilesInfo[index].ID;
      ItemSelected[index] := True;
    end;
  Options.Files := Copy(ItemFileNames);
  Options.IDs := Copy(ItemIDs);
  Options.Selected := Copy(ItemSelected);
  Options.Action := ACTION_DECRYPT_IMAGES;
  Options.Password := Password;
  Options.CryptOptions := 0;
  TCryptingImagesThread.Create(Self, Options);

end;

procedure TExplorerForm.CryptFile1Click(Sender: TObject);
var
  I, index : integer;
  Options : TCryptImageThreadOptions;
  Opt: TCryptImageOptions;
  CryptOptions: Integer;
  ItemFileNames: TArStrings;
  ItemIDs: TArInteger;
  ItemSelected: TArBoolean;

begin
  Opt := GetPassForCryptImageFile(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName));
  if Opt.SaveFileCRC then
    CryptOptions := CRYPT_OPTIONS_SAVE_CRC
  else
    CryptOptions := CRYPT_OPTIONS_NORMAL;
  if Opt.Password = '' then
    Exit;

  Setlength(ItemFileNames, FFilesInfo.Count);
  Setlength(ItemIDs, FFilesInfo.Count);
  Setlength(ItemSelected, FFilesInfo.Count);

  // be default unchecked
  for I := 0 to FFilesInfo.Count - 1 do
    ItemSelected[I] := False;

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      index := ItemIndexToMenuIndex(I);
      ItemFileNames[index] := ProcessPath(FFilesInfo[index].FileName);
      ItemIDs[index] := FFilesInfo[index].ID;
      ItemSelected[index] := True;
    end;
  Options.Files := Copy(ItemFileNames);
  Options.IDs := Copy(ItemIDs);
  Options.Selected := Copy(ItemSelected);
  Options.Action := ACTION_CRYPT_IMAGES;
  Options.Password := Opt.Password;
  Options.CryptOptions := CryptOptions;
  TCryptingImagesThread.Create(Self, Options);
end;

procedure TExplorerForm.Addsessionpassword1Click(Sender: TObject);
begin
  AddSessionPassword;
end;

procedure TExplorerForm.EnterPassword1Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 if fFilesInfo[PmItemPopup.Tag].ID <> 0 then
  begin
    EventInfo.Image := nil;
    if GetImagePasswordFromUser(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)) <> '' then
      DBKernel.DoIDEvent(Self, FFilesInfo[PmItemPopup.Tag].ID, [EventID_Param_Image], EventInfo);
  end else
  begin
    if GetImagePasswordFromUser(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName)) <> '' then
      RefreshItemByName(ProcessPath(FFilesInfo[PmItemPopup.Tag].FileName));
  end;
end;

procedure TExplorerForm.Resize1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
begin
  List := GetCurrentPopUpMenuInfo(nil);
  try
    ResizeImages(Self, List);
  finally
    List.Free;
  end;
end;

procedure TExplorerForm.Convert1Click(Sender: TObject);
var
  List: TDBPopupMenuInfo;
begin
  List := GetCurrentPopUpMenuInfo(nil);
  try
    ConvertImages(Self, List);
  finally
    List.Free;
  end;
end;

procedure TExplorerForm.Stretch1Click(Sender: TObject);
var
  FileName : string;
begin
  FileName:=fFilesInfo[PmItemPopup.Tag].FileName;
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
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    RotateImages(Self, Info, DB_IMAGE_ROTATE_EXIF, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RotateCCW1Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    RotateImages(Self, Info, DB_IMAGE_ROTATE_270, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RotateCW1Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    RotateImages(Self, Info, DB_IMAGE_ROTATE_90, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.Rotateon1801Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    RotateImages(Self, Info, DB_IMAGE_ROTATE_180, True);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.RefreshID1Click(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    Options.Info := Info;
    TRefreshDBRecordsThread.Create(Self, Options);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.DropFileTarget1Drop(Sender: TObject; ShiftState: TShiftState; Point: TPoint;
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
  DropFileTarget1.Files.AssignTo(DropInfo);

  if SsRight in LastShift then
  begin
    Move1.Visible := not SelfDraging;
    FDBCanDragW := False;
    FDBCanDrag := False;
    LastListViewSelCount := SelCount;
    LastListViewSelected := ListView1Selected;
    DragFilesPopup.Assign(DropInfo);
    GetCursorPos(Pnt);
    PmDragMode.Popup(Pnt.X, Pnt.Y);
  end;

  if not(SsRight in LastShift) then
  begin
    if not SelfDraging and (Selcount = 0) then
    begin
      FDBCanDragW := False;

      if CtrlKeyDown then
        CopyFiles(Handle, DropInfo, GetCurrentPath, False, False)
      else
        CopyFiles(Handle, DropInfo, GetCurrentPath, True, False, Self);

    end;
    if Selcount = 1 then
      if ListView1Selected <> nil then
      begin
        FDBCanDragW := False;
        Index := ItemIndexToMenuIndex(ListView1Selected.index);
        if (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) or
          (FFilesInfo[index].FileType = EXPLORER_ITEM_SHARE) then
        begin
          Str := ExcludeTrailingBackslash(FFilesInfo[index].FileName);

          if CtrlKeyDown then
            CopyFiles(Handle, DropInfo, Str, ShiftKeyDown, False)
          else
            CopyFiles(Handle, DropInfo, Str, ShiftKeyDown, False, Self);

        end;
      end;
    if SelCount = 1 then
      if ListView1Selected <> nil then
      begin
        index := ItemIndexToMenuIndex(ListView1Selected.index);
        if (GetExt(FFilesInfo[index].FileName) = 'EXE') then
        begin
          FDBCanDragW := False;
          Str := ExtractFileDir(FFilesInfo[index].FileName);
          FillChar(Si, SizeOf(Si), 0);
          with Si do
          begin
            Cb := SizeOf(Si);
            DwFlags := Startf_UseShowWindow;
            WShowWindow := 4;
          end;
          Params := '';
          for I := 0 to DropInfo.Count - 1 do
            Params := ' "' + DropInfo[I] + '" ';
          CreateProcess(nil, PWideChar('"' + FFilesInfo[index].FileName + '"' + Params), nil, nil, False,
            CREATE_DEFAULT_ERROR_MODE, nil, PWideChar(Str), Si, P);
        end;
      end;
  end;
  SelfDraging := False;
end;

procedure TExplorerForm.DropFileTarget1Enter(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  LastShift:=ShiftState;
  if not SelfDraging then
    Outdrag := True;
  FDBCanDrag := True;
end;

procedure TExplorerForm.DropFileTarget1Leave(Sender: TObject);
begin
  FDBCanDrag:=false;
  outdrag:=false;
end;

procedure TExplorerForm.SetStringPath(Path: String; ChangeTreeView: Boolean);
var
  S, S1, ScriptString: string;
  I: Integer;
  FScript: TScript;
  C: Integer;
begin
  ScriptString := Include('scripts\ExplorerSetNewPath.dbini');
  FScript := TScript.Create('');
  try
    FScript.Description := 'Set path script';
    SetNamedValueStr(FScript, '$Path', Path);
    ExecuteScript(nil, FScript, ScriptString, C, nil);
    Path := GetNamedValueString(FScript, '$Path');
  finally
    FScript.Free;
  end;
  if Path = #8 then
    Exit;

  S := Path;
  if (S = '') or (AnsiLowerCase(S) = AnsiLowerCase(MyComputer)) then
  begin
    CbPathEdit.Text := MyComputer;
    SetNewPath(S, ChangeTreeView);
    Exit;
  end;
  if (AnsiLowerCase(S) = AnsiLowerCase(L('Network'))) then
  begin
    CbPathEdit.Text := L('Network');
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
  if CheckFileExistsWithMessageEx(S, True) then
  begin
    SetNewPath(S, ChangeTreeView);
  end else
  begin
    S := Path;
    if CheckFileExistsWithMessageEx(S, False) then
    begin
      if ExtInMask(SupportedExt, GetExt(S)) then
      begin
        if Viewer = nil then
          Application.CreateForm(TViewer, Viewer);
        Viewer.ShowFile(S);
        Viewer.Show;
      end else
        ShellExecute(Handle, nil, PChar(S), nil, nil, SW_NORMAL);
    end else if not ChangeTreeView then
      MessageBoxDB(Handle, Format(L('Directory "%s" not found!'), [S]), L('Warning'), TD_BUTTON_OK, TD_ICON_ERROR);
  end;
end;

procedure TExplorerForm.HelpTimerTimer(Sender: TObject);
begin
  if not Active then
    Exit;

  if HelpNO = 1 then
  begin
    HelpTimer.Enabled := False;
    DoHelpHintCallBackOnCanClose(L('Help'), TEXT_MES_HELP_1, Point(0, 0), ElvMain, Help1NextClick,
      TEXT_MES_NEXT_HELP, Help1CloseClick);
  end;
  if HelpNO = 2 then
  begin
    HelpTimer.Enabled := False;
    DoHelpHintCallBackOnCanClose(L('Help'), TEXT_MES_HELP_2, Point(0, 0), AddLink, Help1NextClick,
      TEXT_MES_NEXT_HELP, Help1CloseClick);
  end;
  if HelpNO = 4 then
  begin
    HelpTimer.Enabled := False;
    DoHelpHint(L('Help'), TEXT_MES_HELP_3, Point(0, 0), ElvMain);
    HelpNO := 0;
    DBKernel.WriteBool('HelpSystem', 'CheckRecCount', False);
  end;
end;

procedure TExplorerForm.Help1CloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ID_OK = MessageBoxDB(Handle, TEXT_MES_CLOSE_HELP, L('Confirm'), TD_BUTTON_OKCANCEL, TD_ICON_INFORMATION);
  if CanClose then
  begin
    HelpNo := 0;
    DBKernel.WriteBool('HelpSystem', 'CheckRecCount', False);
  end;
end;

procedure TExplorerForm.Help1NextClick(Sender: TObject);
begin
  if HelpNo = 4 then
    Exit;

  HelpNo := HelpNo + 1;

  if HelpNO= 4 then
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
    SetStringPath(Reg.ReadString('Shell Folders', 'Personal', ''),false);
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
    SetStringPath(Reg.ReadString('Shell Folders', 'Desktop', ''),false);
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
  I, Index : integer;
begin
  for i:=0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      Index := ItemIndexToMenuIndex(I);
      with EditorsManager.NewEditor do
      begin
        Show;
        OpenFileName(FFilesInfo[index].FileName);
      end;
      Break;
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
      OpenFileName(FFilesInfo[ItemIndexToMenuIndex(Item.index)].FileName);
    end;
  end;
end;

procedure TExplorerForm.ExportImages1Click(Sender: TObject);
var
  Info : TDBPopupMenuInfo;
begin
  Info := GetCurrentPopUpMenuInfo(nil);
  try
    ExportImages(Self, Info);
  finally
    F(Info);
  end;
end;

procedure TExplorerForm.PrintLinkClick(Sender: TObject);
var
  I, Index : Integer;
  Files : TStrings;
begin
  Files := TStringList.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        index := ItemIndexToMenuIndex(I);
        if FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE then
          Files.Add(FFilesInfo[index].FileName)
      end;
    GetPrintForm(Files);
  finally
    F(Files);
  end;
end;

procedure TManagerExplorer.SetShowQuickLinks(const Value: Boolean);
begin
  FShowQuickLinks := Value;
end;

procedure TExplorerForm.MyPicturesLinkContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  P : TPoint;
begin
  GetCursorPos(P);
  PmLinkOptions.Tag := Integer(Sender);
  PmLinkOptions.Popup(P.X, P.Y);
end;

procedure TExplorerForm.Open2Click(Sender: TObject);
begin
  TWebLink(PmLinkOptions.Tag).OnClick(TWebLink(PmLinkOptions.Tag));
end;

procedure TExplorerForm.OpeninNewWindow2Click(Sender: TObject);
var
  Reg: TRegIniFile;
  Link : TWebLink;
  S : string;
  DefLink: Boolean;
  I: Integer;
begin
  Link := TWebLink(PmLinkOptions.Tag);
  DefLink:=true;
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
  S, FileName, FileNameTemplate : String;
  N : Integer;
  F : TextFile;
begin
  FileNameTemplate := L('Text document');
  FileName := FileNameTemplate + '.txt';
  S := IncludeTrailingBackslash(GetCurrentPath);

  N := 1;
  if FileExists(S + FileName) then
  begin
    repeat
      Inc(N);
    until not FileExists(S + FileNameTemplate + ' (' + Inttostr(N) + ').txt');
    FileName := S + FileNameTemplate + ' (' + Inttostr(N) + ').txt';
  end else
    FileName := S + FileName;

  System.Assign(F, FileName);
{$I-}
  System.Rewrite(F);
{$I-}
  if IOResult <> 0 then
  begin
    if not FileExists(FileName) then
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
  NewFileName := AnsiLowerCase(FileName);
end;

procedure TExplorerForm.GetPhotosClick(Sender: TObject);
var
  Item : TMenuItem;
begin
  Item := (Sender as TMenuItem);
  GetPhotosFromDrive(Char(Item.Tag));
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
  I, Index : integer;
  Files : TStrings;
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
        NewDir := IncludeTrailingBackslash(Dir + UpDir);
        CreateDirA(NewDir);
        CopyFiles(Handle, Files, NewDir, False, False);
      end;
    finally
      F(Files);
    end;
  end;
end;

procedure TExplorerForm.ReadPlaces;
var
  Reg : TBDRegistry;
  S : TStrings;
  fName, FFolderName, FIcon: string;
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
          WebLink.Color := ClBtnface;
          WebLink.Font.Color := ClWindowText;
          WebLink.EnterBould := False;
          WebLink.IconWidth := 16;
          WebLink.IconHeight := 16;
          WebLink.Left := MyPicturesLink.Left;
          WebLink.OnContextPopup := UserDefinedPlaceContextPopup;
          WebLink.ImageCanRegenerate := True;
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
            Ico.Handle := ExtractSmallIconByPath(FIcon, True);
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
  PmLinkOptions.Popup(P.X, P.Y);
end;

procedure TExplorerForm.Copy4Click(Sender: TObject);
var
  Index : integer;
  Str : string;
begin
  if (LastListViewSelCount = 0) then
  begin
    FDBCanDragW := False;

    if not(Sender = Move1) then
      CopyFiles(Handle, DragFilesPopup, GetCurrentPath, Sender = Move1, False)
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
          CopyFiles(Handle, DragFilesPopup, Str, Sender = Move1, False)
        else
          CopyFiles(Handle, DragFilesPopup, Str, Sender = Move1, False, Self);

      end;
    end;
end;

procedure TExplorerForm.NewPanel1Click(Sender: TObject);
begin
  ManagerPanels.NewPanel.Show;
end;

procedure TExplorerForm.DoSelectItem;
var
  Index, I, J, X, Y, W, H: Integer;
  Ico: TIcon;
  Ico48: TIcon48;
  S, FileName: string;
  FileSID: TGUID;
  FFolderImagesResult: TFolderImages;
  Dx: Integer;
  FolderImageRect: TRect;
  Fbmp: TBitmap;
  OldMode: Cardinal;
  Pic: TPNGImage;
  Bit32: TBitmap;
  TempBitmap: TBitmap;
begin
  if Rdown then
    FDBCanDrag := False;
  if ElvMain <> nil then
  begin
    FSelectedInfo.FileType := GetCurrentPathW.PType;
    if SelCount < 2 then
    begin
      FSelectedInfo.Id := 0;
      FSelectedInfo.Width := 0;
      FSelectedInfo.Height := 0;
      FSelectedInfo.One := True;
      FSelectedInfo.Size := 0;
      FSelectedInfo.FileTypeW := '';
      FSelectedInfo.Size := -1;
      index := -1;
      if SelCount = 1 then
      begin
        index := ItemIndexToMenuIndex(ListView1Selected.index);
        if FFilesInfo.Count = 0 then
          Exit;
        if index > FFilesInfo.Count - 1 then
          Exit;
        FSelectedInfo.FileType := FFilesInfo[index].FileType;
        FileName := FFilesInfo[index].FileName;
        FSelectedInfo.FileName := FileName;
        FileSID := FFilesInfo[index].SID;
        if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) then
          FSelectedInfo.FileTypeW := MrsGetFileType(FileName);
        if (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) then
          FSelectedInfo.FileTypeW := L('Network');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) then
          FSelectedInfo.FileTypeW := L('Workgroup');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) then
          FSelectedInfo.FileTypeW := L('Computer');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) then
          FSelectedInfo.FileTypeW := L('Shared folder');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
          FSelectedInfo.Size := GetFileSizeByName(FileName);
      end else
      begin
        FileName := GetCurrentPath;
        FSelectedInfo.FileName := FileName;
        if GetCurrentPathW.PType = EXPLORER_ITEM_MYCOMPUTER then
        begin
          FileName := MyComputer;
          FSelectedInfo.FileName := MyComputer;
          FSelectedInfo.FileTypeW := MyComputer;
          FSelectedInfo.FileType := EXPLORER_ITEM_MYCOMPUTER;
          FileSID := GetGUID;
        end;
        if FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE then
          NameLabel.Caption := FileName;
        if (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or
          (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) then
          NameLabel.Caption := ExtractFileName(FileName);
        if (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) then
          FSelectedInfo.FileTypeW := MrsGetFileType(FileName);
        if (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) then
          FSelectedInfo.FileTypeW := L('Network');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) then
          FSelectedInfo.FileTypeW := L('Workgroup');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) then
          FSelectedInfo.FileTypeW := L('Computer');
        if (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) then
          FSelectedInfo.FileTypeW := L('Shared folder');
      end;
      if SelCount = 1 then
        PmItemPopup.Tag := Index;
      FSelectedInfo._GUID := FileSID;
      if FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE then
      begin
        TExplorerThumbnailCreator.Create(FileName, FileSID, Self);
        if HelpNo = 2 then
          HelpTimer.Enabled := True;
      end;
      if not PropertyPanel.Visible then
      begin
        ReallignToolInfo;
        Exit;
      end;
      ReallignInfo;
      TempBitmap := TBitmap.Create;
      ImPreview.Picture.Graphic := TempBitmap;
      TempBitmap.Free;
      try
        with ImPreview.Picture.Bitmap do
        begin
          Width := ThSizeExplorerPreview;
          Height := ThSizeExplorerPreview;
          Canvas.Pen.Color := clBtnFace;
          Canvas.Brush.Color := clBtnFace;
          if (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType = EXPLORER_ITEM_IMAGE) then
          begin
            Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);
            FFolderImagesResult.Directory := '';
            for I := 1 to 4 do
              FFolderImagesResult.Images[I] := nil;
            FFolderImagesResult := AExplorerFolders.GetFolderImages(FileName, 40, 40);
            if FFolderImagesResult.Directory = '' then
            begin
              S := ExcludeTrailingBackslash(FileName);
              if FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE then
                FileName := IncludeTrailingBackslash(FileName);

              OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);

              Ico := TAIcons.Instance.GetIconByExt(FileName, (FSelectedInfo.FileType = EXPLORER_ITEM_DRIVE) or
                  (FSelectedInfo.FileType = EXPLORER_ITEM_FOLDER), 48, False);
              try
              Ico48 := TIcon48.Create;
                try
                  Ico48.Assign(Ico);
                  SetErrorMode(OldMode);

                  Canvas.Draw(ThSizeExplorerPreview div 2 - Ico48.Width div 2,
                    ThSizeExplorerPreview div 2 - Ico48.Height div 2, Ico48);
                finally
                  F(Ico48);
                end;
              finally
                F(Ico);
              end;
            end else
            begin
              Pic := GetFolderPicture;
              if Pic = nil then
                Exit;

              TempBitmap := TBitmap.Create;
              try
                Bit32 := TBitmap.Create;
                try
                  LoadPNGImage32bit(Pic, Bit32, ClBtnFace);
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
                  index := (I - 1) * 2 + J;
                  X := (J - 1) * 42 + 5 + Dx;
                  Y := (I - 1) * 42 + 8 + Dx;
                  if FFolderImagesResult.Images[index] = nil then
                    Break;
                  Fbmp := FFolderImagesResult.Images[index];
                  W := Fbmp.Width;
                  H := Fbmp.Height;
                  ProportionalSize(40, 40, W, H);
                  FolderImageRect := Rect(X + 40 div 2 - W div 2, Y + 40 div 2 - H div 2, X + 40 div 2 + W div 2,
                    Y + 40 div 2 + H div 2);
                  Canvas.StretchDraw(FolderImageRect, Fbmp);
                end;
            end;

            for I := 1 to 4 do
              F(FFolderImagesResult.Images[I]);
          end;
          if (FSelectedInfo.FileType = EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType = EXPLORER_ITEM_NETWORK) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType = EXPLORER_ITEM_COMPUTER) or
            (FSelectedInfo.FileType = EXPLORER_ITEM_SHARE) then
          begin
            with ImPreview.Picture.Bitmap do
            begin
              Width := ThSizeExplorerPreview;
              Height := ThSizeExplorerPreview;
              Canvas.Pen.Color := clBtnFace;
              Canvas.Brush.Color := clBtnFace;
              Canvas.Rectangle(0, 0, ThImageSize, ThImageSize);

              case FSelectedInfo.FileType of
                EXPLORER_ITEM_NETWORK:
                  FindIcon(DBKernel.IconDllInstance, 'NETWORK', 48, 32, Ico);
                EXPLORER_ITEM_WORKGROUP:
                  FindIcon(DBKernel.IconDllInstance, 'WORKGROUP', 48, 32, Ico);
                EXPLORER_ITEM_COMPUTER:
                  FindIcon(DBKernel.IconDllInstance, 'COMPUTER', 48, 32, Ico);
                EXPLORER_ITEM_SHARE:
                  FindIcon(DBKernel.IconDllInstance, 'SHARE', 48, 32, Ico);
                EXPLORER_ITEM_MYCOMPUTER:
                  FindIcon(DBKernel.IconDllInstance, 'COMPUTER', 48, 32, Ico);
              end;
              Ico48 := TIcon48.Create;
              Ico48.Assign(Ico);
              Ico.Free;
              Canvas.Draw(ThSizeExplorerPreview div 2 - Ico48.Width div 2,
                ThSizeExplorerPreview div 2 - Ico48.Height div 2, Ico48);
              Ico48.Free;
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
        TempBitmap := TBitmap.Create;
        try
          TempBitmap.PixelFormat := pf24bit;
          LoadBMPImage32bit(Bit32, TempBitmap, clBtnFace);
          ImPreview.Picture.Graphic := TempBitmap;
        finally
          F(TempBitmap);
        end;
      finally
        F(Bit32);
      end;

      FSelectedInfo._GUID := GetGUID;

      FSelectedInfo.Size := 0;
      if SelCount < 1000 then
      begin
        for I := 0 to ElvMain.Items.Count - 1 do
          if ElvMain.Items[I].Selected then
          begin
            index := ItemIndexToMenuIndex(I);
            if FSelectedInfo.FileType <> EXPLORER_ITEM_MYCOMPUTER then
              FSelectedInfo.FileType := FFilesInfo[index].FileType;
            if FFilesInfo.Count - 1 < index then
              Exit;
            if (FFilesInfo[index].FileType = EXPLORER_ITEM_IMAGE) or
              ((FFilesInfo[index].FileType = EXPLORER_ITEM_FILE) or
                (FFilesInfo[index].FileType = EXPLORER_ITEM_EXEFILE)) then
            begin
              FSelectedInfo.Size := FSelectedInfo.Size + FFilesInfo[index].FileSize;
            end;
          end
      end
      else
        FSelectedInfo.Size := -1;

      FSelectedInfo.FileName := Format(L('%d objects'), [SelCount]);
      FSelectedInfo.FileTypeW := '';
      FSelectedInfo.Id := 0;
      FSelectedInfo.Width := 0;
      FSelectedInfo.Height := 0;
      FSelectedInfo.One := True;
      FSelectedInfo.Rating := 0;
      TypeLabel.Caption := '';
      ReallignInfo;
    end;
  end;
end;

procedure TExplorerForm.SelectTimerTimer(Sender: TObject);
begin
  if LastSelCount < 2 then
  begin
    SelectTimer.Enabled := False;
    DoSelectItem;
    LastSelCount := 0;
    Exit;
  end;
  if LastSelCount = SelCount then
  begin
    SelectTimer.Enabled := False;
    DoSelectItem;
    LastSelCount := 0;
    Exit;
  end;
  LastSelCount := SelCount;
end;

procedure TExplorerForm.SendTo1Click(Sender: TObject);
begin
  ManagerPanels.FillSendToPanelItems(Sender as TMenuItem, SendToItemPopUpMenu_);
end;

procedure TExplorerForm.SendToItemPopUpMenu_(Sender: TObject);
var
  NumberOfPanel : Integer;
  InfoNames : TArStrings;
  InfoIDs: TArInteger;
  Infoloaded: TArBoolean;
  I: Integer;
  Panel: TFormCont;
  index: Integer;
begin
  NumberOfPanel := (Sender as TMenuItem).Tag;
  Setlength(InfoNames, 0);
  Setlength(InfoIDs, 0);
  Setlength(Infoloaded, 0);
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    index := MenuIndexToItemIndex(I);
    if ElvMain.Items[index].Selected then
    begin
      if FFilesInfo[I].ID = 0 then
      begin
        Setlength(InfoNames, Length(InfoNames) + 1);
        Setlength(Infoloaded, Length(Infoloaded) + 1);
        InfoNames[Length(InfoNames) - 1] := FFilesInfo[I].FileName;
        Infoloaded[Length(Infoloaded) - 1] := FFilesInfo[I].Loaded;
      end else
      begin
        Setlength(InfoIDs, Length(InfoIDs) + 1);
        InfoIDs[Length(InfoIDs) - 1] := FFilesInfo[I].ID;
      end;
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

procedure TExplorerForm.SetNewFileNameGUID(FileGUID: TGUID);
begin
  NewFileNameGUID := FileGUID;
end;

procedure TExplorerForm.View2Click(Sender: TObject);
var
  Info: TRecordsInfo;
  N: Integer;
begin
  if Viewer = nil then
    Application.CreateForm(TViewer, Viewer);
  GetFileListByMask(TempFolderName, SupportedExt, Info, N, True);
  if Length(Info.ItemFileNames) > 0 then
    Viewer.Execute(Self, Info);
end;

procedure TExplorerForm.AddUpdateID(ID: Integer);
begin
  RefreshIDList.Add(Pointer(ID));
end;

procedure TExplorerForm.RemoveUpdateID(ID: Integer; CID: TGUID);
begin
  RefreshIDList.Remove(Pointer(ID));
end;

function TExplorerForm.FileNameToID(FileName: string): integer;
var
  I : integer;
begin
  Result := -1;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to fFilesInfo.Count - 1 do
  begin
    if AnsiLowerCase(FFilesInfo[I].FileName) = FileName then
    begin
      Result := FFilesInfo[I].ID;
      Exit;
    end;
  end;
end;

function TExplorerForm.UpdatingNow(ID: Integer): boolean;
begin
  Result := RefreshIDList.IndexOf(Pointer(ID)) > -1;
end;

procedure TExplorerForm.ScriptExecuted(Sender: TObject);
begin
  LoadItemVariables(aScript,Sender as TMenuItemW);
  if Trim((Sender as TMenuItemW).Script) <> '' then
    ExecuteScript(Sender as TMenuItemW, AScript, '', FExtImagesInImageList, DBkernel.ImageList, ScriptExecuted);
end;

function TExplorerForm.GetVisibleItems: TStrings;
var
  I, index : Integer;
  r : TRect;
  t : array of Boolean;
  B: Boolean;
  TempResult: TStrings;
  RectArray: TEasyRectArrayObject;
  Rv: TRect;
begin
  Result := TStringList.Create;
  B := False;
  rv :=  ElvMain.Scrollbars.ViewableViewportRect;

  for I := 0 to ElvMain.Items.Count - 1 do
  begin
    ElvMain.Items[I].ItemRectArray(ElvMain.Header.FirstColumn, ElvMain.Canvas, RectArray);
    r := Rect(ElvMain.ClientRect.Left+rv.Left, ElvMain.ClientRect.Top + rv.Top,ElvMain.ClientRect.Right + rv.Left, ElvMain.ClientRect.Bottom + rv.Top);

    if RectInRect(r, RectArray.BoundsRect) then
    begin
      index := Self.ItemIndexToMenuIndex(I);
      Result.Add(GUIDToString(fFilesInfo[index].SID));
      SetLength(T,Length(t) + 1);
      t[Length(t)-1] := fFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER;
      if not b then
      begin
        if fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER then
        b := True;
      end;
    end;
  end;

  //order by TYPE
  if b then
  begin
    TempResult := TStringList.Create;
    try
      for I := 0 to Result.Count - 1 do
        if not t[I] then
          TempResult.Add(Result[I]);

      for I := 0 to Result.Count - 1 do
        if t[i] then
          TempResult.Add(Result[I]);

      Result.Assign(TempResult);
    finally
      F(TempResult);
    end;
  end;
end;

procedure TExplorerForm.LoadStatusVariables(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
  Index : Integer;
  FileEx, CanPaste: Boolean;
begin
  Files := TStringList.Create;
  try
    LoadFIlesFromClipBoard(Effects, Files);
    FileEx := Files.Count <> 0;
  finally
    F(Files);
  end;
  if SelCount = 0 then
    CanPaste := FileEx
  else
  begin
    if SelCount = 1 then
    begin
      index := ItemIndexToMenuIndex(ListView1Selected.index);
      if (FFilesInfo[index].FileType = EXPLORER_ITEM_DRIVE) or (FFilesInfo[index].FileType = EXPLORER_ITEM_FOLDER) then
        CanPaste := FileEx
      else
        CanPaste := False;
    end else
      CanPaste := False;
  end;
  SetBoolAttr(AScript, '$CanUp', AnsiLowerCase(GetCurrentPath) <> AnsiLowerCase(MyComputer));
  SetBoolAttr(AScript, '$CanBack', FHistory.CanBack);
  SetBoolAttr(AScript, '$CanForward', FHistory.CanForward);
  SetBoolAttr(AScript, '$CanPaste', CanPaste);
  SetNamedValue(AScript, '$ItemsCount', IntToStr(ElvMain.Items.Count));
  SetNamedValueStr(AScript, '$Path', GetCurrentPath);
end;

function TExplorerForm.CanUp: Boolean;
begin
  Result:=AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(MyComputer);
  if GetCurrentPath = '' then
    Result := False;
end;

function TExplorerForm.SelCount: Integer;
begin
  Result:= ElvMain.Selection.Count;
end;

function TExplorerForm.SelectedIndex: Integer;
begin
  if ListView1Selected = nil then
    Result := -1
  else
    Result := ListView1Selected.index;
end;

function TExplorerForm.GetSelectedType: Integer;
begin
  if ListView1Selected = nil then
    Result := -1
  else
    Result := FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.index)].FileType;
end;

function CanCopyFileByType(FileType: Integer): boolean;
begin
  Result:=((FileType=EXPLORER_ITEM_FILE) or (FileType=EXPLORER_ITEM_IMAGE) or (FileType=EXPLORER_ITEM_FOLDER) or (FileType=EXPLORER_ITEM_SHARE) or (FileType=EXPLORER_ITEM_EXEFILE));
end;

function TExplorerForm.CanCopySelection: boolean;
var
  I, Index : integer;
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

function TExplorerForm.GetSelectedFiles: TArrayOfString;
var
  I, Index : integer;
begin
  SetLength(Result, 0);

  for I := 0 to ElvMain.Items.Count - 1 do
    if ElvMain.Items[I].Selected then
    begin
      index := ItemIndexToMenuIndex(I);
      if CanCopyFileByType(FFilesInfo[index].FileType) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1] := FFilesInfo[index].FileName;
      end;
    end;
end;

function TExplorerForm.CanPasteInSelection: boolean;
var
  index : Integer;
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
  begin
    Result := CanPasteFileInByType(GetCurrentPathW.PType);
  end;
end;

procedure TExplorerForm.CloseTimerTimer(Sender: TObject);
begin
  CloseTimer.Enabled:=false;
  Close;
end;

procedure TExplorerForm.CloseWindow(Sender: TObject);
begin
  CloseTimer.Enabled := True;
end;

function TExplorerForm.ExplorerType: boolean;
begin
  Result := FIsExplorer;
end;

function TExplorerForm.ShowPrivate: boolean;
begin
  Result := ExplorerManager.ShowPrivate;
end;

function TExplorerForm.GetPathByIndex(index: integer): string;
begin
  if ListView1Selected=nil then
    Result := ''
  else
    Result := FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.index)].FileName;
end;

procedure TExplorerForm.FileName1Click(Sender: TObject);
var
  i, l, index, n : integer;
  aType : byte;

type
  Item = TExplorerFileInfo; { This defines the objects being sorted.}
  List=array of Item; {This is an array of objects to be sorted.}

  SortList = array of TEasyItem;

  TSortItem = record
    ID : integer;
    ValueInt : integer;
    ValueStr : string;
    ValueDouble : double;
   end;

   aListItem = record
    Caption : string;
    Indent : integer;
    Data : Pointer;
    ImageIndex : integer;
   end;

  aListItems = array of aListItem;

  TSortItems = array of TSortItem;

var
  SIs : TSortItems;
  LI : aListItems;

  function L_Less_Than_R(L,R:TSortItem; aType : byte):Boolean;
  begin
    Result := True;
    if AType = 1 then
    begin
      if L.ValueInt = R.ValueInt then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := L.ValueInt < R.ValueInt;
      Exit;
    end;
    if AType = 0 then
      Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0;
    if AType = 5 then
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
    if AType = 2 then
    begin
      if L.ValueDouble = R.ValueDouble then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := L.ValueDouble < R.ValueDouble;
      Exit;
    end;
    if AType = 3 then
    begin
      N := AnsiCompareText(ExtractFileExt(L.ValueStr), ExtractFileExt(R.ValueStr));
      if N = 0 then
        Result := AnsiCompareText(L.ValueStr, R.ValueStr) < 0
      else
        Result := N < 0;
      Exit;
    end;
    if AType = 4 then
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

  procedure Qsort(var X: TSortItems; Left, Right: integer; AType: Byte);
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
      while L_Less_Than_R(X[P], Pivot, AType) do
         begin
           if P = M then
             Break;
           Inc(P);
         end;
         while L_Less_Than_R(Pivot, X[Q], AType) do
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

     Again :
       if Left < Q then
         Qsort(X, Left, Q, AType);
       if P < Right then
         Qsort(X, P, Right, AType);
     end;

     procedure QuickSort(var X: TSortItems; N: Integer; AType: Byte);
     begin
       Qsort(X, 0, N - 1, AType);
     end;

   begin
     DefaultSort := (Sender as TMenuItem).Tag;

  //NOT RIGHT! SORTING BY FOLDERS-IMAGES-OTHERS
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
        AType := 4;
      1, 2:
        AType := 1;
      3:
        AType := 3;
      4:
        AType := 2;
      5:
        AType := 5;
    else
      AType := 0;
    end;

    QuickSort(SIs, L, AType);

    for I := 0 to L - 1 do
    begin
      ElvMain.Items[I].Caption := LI[SIs[I].ID].Caption;
      ElvMain.Items[I].Tag := LI[SIs[I].ID].Indent;
      ElvMain.Items[I].ImageIndex := LI[SIs[I].ID].ImageIndex;
      ElvMain.Items[I].Data := LI[SIs[I].ID].Data;
    end;
  except
    on E: Exception do
      EventLog(':TExplorerForm.FileName1Click() throw exception: ' + E.message);
  end;

  if not NoLockListView then
    ElvMain.Groups.EndUpdate;
  if not NoLockListView then
    UpdatingList := False;
end;

procedure TExplorerForm.SetFilter1Click(Sender: TObject);
var
  Filter : string;
begin
  Filter:='*.*';
  if PromtString(L('Filter'), L('Enter mask to filter files in this directory'), Filter) then
    SetNewPathW(GetCurrentPathW, False, Filter);

end;

procedure TExplorerForm.ImButton1Click(Sender: TObject);
begin
  SetStringPath(CbPathEdit.text, False);
end;

procedure TExplorerForm.MakeFolderViewer1Click(Sender: TObject);
var
  Query : TDataSet;
  IncludeSub : boolean;
  Folder: string;
  FileList: TArStrings;
begin
  SetLength(FileList, 1);
  FileList[0] := GetCurrentPath;
  IncludeSub := False;
  Query := GetQuery;
  try
    Folder := IncludeTrailingBackslash(GetCurrentPath);
    SetSQL(Query, 'SELECT count(*) AS CountField FROM $DB$ WHERE (FFileName LIKE :FolderA)');
    SetStrParam(Query, 0, '%' + Folder + NormalizeDBStringLike('%\%'));
    Query.Open;
    if Query.FieldByName('CountField').AsInteger > 0 then
      IncludeSub := MessageBoxDB(Handle, L('Include subfolders?'), L('Question'), TD_BUTTON_OKCANCEL,
        TD_ICON_QUESTION) = ID_OK;
  finally
    FreeDS(Query);
  end;
  SaveQuery(nil, GetCurrentPath, IncludeSub, FileList);
end;

procedure TExplorerForm.AutoCompliteTimerTimer(Sender: TObject);
var
  FEditHandle : THandle;
begin
  AutoCompliteTimer.Enabled := False;
  ComboBox1DropDown;
  FEditHandle := GetWindow(GetWindow(CbPathEdit.Handle, GW_CHILD), GW_CHILD);
  SendMessage(FEditHandle, WM_KEYDOWN, VK_RIGHT, VK_RIGHT);
end;

procedure TExplorerForm.ComboBox1DropDown;
var
  FileList : TStringList;
  I : integer;
  S : string;

  procedure GetDirListing(Dir: string; FileList: TStringList);
  var
    Found: Integer;
    SearchRec: TSearchRec;
  begin
    FileList.Clear;
    if Dir = '' then
      Exit;
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    Found := FindFirst(Dir + '*.*', FaAnyFile, SearchRec);
    while Found = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        FileList.Add(Dir + SearchRec.name);

      Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);
  end;

begin
  S := Trim(CbPathEdit.Text);
  if Length(S) <4 then
    S := ExtractFilePath(S);
  if not CheckFileExistsWithSleep(S, True) then
    Exit;

  FileList := TStringList.Create;
  try
    GetDirListing(S, FileList);
    S := CbPathEdit.Text;
    Lock := True;
    CbPathEdit.Items.Clear;
    for I := 0 to FileList.Count - 1 do
      CbPathEdit.Items.Add(FileList[I]);
    Lock := False;
    CbPathEdit.Text := S;
  finally
    F(FileList);
  end;
end;

procedure TExplorerForm.CbPathEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Dir: string;
  I, C: Integer;
begin
  if Key = VK_SHIFT then
    Exit;
  Dir := CbPathEdit.Text;
  if Length(Dir) > 2 then
    if Dir[1] = '\' then
    begin
      C := 0;
      for I := 1 to Length(Dir) do
        if Dir[I] = '\' then
          Inc(C);
      if C < 4 then
        Exit;
    end;
  if Key = VK_OEM_1 then
    Dir := Dir + ':';
  Dir := ExtractFilePath(Dir);
  if CheckFileExistsWithMessageEx(Dir, True) then
    if ComboPath <> Dir then
    begin
      ComboPath := Dir;
      AutoCompliteTimer.Enabled := True;
    end;
end;

procedure TExplorerForm.ComboWNDProc(var message: TMessage);
begin
  if Lock then
    if ((message.Msg > 45000) and (message.Msg < 50000)) then
      Exit;
  FWndOrigin(message);
end;

function TExplorerForm.ListView1Selected: TEasyItem;
begin
  Result := ElvMain.Selection.First;
end;

function TExplorerForm.ItemAtPos(X, Y: Integer): TEasyItem;
begin
  Result := ItemByPointImage(ElvMain, Point(X, Y), ListView);
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
  ElvMain.EditManager.Enabled := False;
  Accept := RenameResult;
  if not Accept then
    MessageBoxDB(Handle, L('Error renaming file!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);

end;

procedure TExplorerForm.N05Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  SetRating(RatingPopupMenu1.Tag, (Sender as TMenuItem).Tag);
  EventInfo.Rating := (Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Self, RatingPopupMenu1.Tag, [EventID_Param_Rating],
    EventInfo);
end;

procedure TExplorerForm.ListView1Resize(Sender: TObject);
begin
  ElvMain.BackGround.OffsetX := ElvMain.Width - ElvMain.BackGround.Image.Width;
  ElvMain.BackGround.OffsetY := ElvMain.Height - ElvMain.BackGround.Image.Height;
  LoadSizes;
end;

procedure TExplorerForm.EasyListview1DblClick(Sender: TCustomEasyListview;
  Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState;
  var Handled: Boolean);
var
  Capt, dir, ShellDir, LinkPath: string;
  MenuInfo: TDBPopupMenuInfo;
  Info: TRecordsInfo;
  index: Integer;
  P, P1: TPoint;
  Item: TObject;
  EasyItem : TEasyItem;

  procedure RestoreSelected;
  begin
    FDBCanDrag := False;
    FDBCanDragW := False;
  end;

begin

  GetCursorPos(P1);
  P := ElvMain.ScreenToClient(p1);
  EasyItem := ElvMain.Selection.FocusedItem;
  if (EasyItem <> nil) and (EasyItem.ImageIndex > -1) then
  begin
    if ItemByPointStar(ElvMain, p, FPictureSize, FBitmapImageList[EasyItem.ImageIndex].Graphic) = EasyItem then
    begin
      Index := ItemAtPos(p.X, p.Y).Index;
      Index := ItemIndexToMenuIndex(index);
      RatingPopupMenu1.Tag := fFilesInfo[Index].ID;
      if RatingPopupMenu1.Tag > 0 then
      begin
        Application.HideHint;
        THintManager.Instance.CloseHint;
        LastMouseItem := nil;
        RatingPopupMenu1.Popup(p1.X, p1.Y);
        Exit;
      end;
    end;
  end;

  FDblClicked := true;
  FDBCanDrag := false;
  fDBCanDragW := false;
  SetLength(fFilesToDrag, 0);
  Application.HideHint;
  THintManager.Instance.CloseHint;
  HintTimer.Enabled := false;

  Item := EasyItem;
  if (Item = nil) and (Sender = nil) then
    Item := ListView1Selected;

  if Item <> nil then
    if ListView1Selected <> nil then
    begin
      Capt := ListView1Selected.Caption;
      GetCursorPos(MousePos);
      Index := ListView1Selected.index;
      Index := ItemIndexToMenuIndex(index);
      if Index > fFilesInfo.Count - 1 then
        Exit;
      if (fFilesInfo[Index].FileType = EXPLORER_ITEM_FOLDER) then
      begin
        Dir := IncludeTrailingBackslash(FFilesInfo[Index].FileName);
        SetNewPath(Dir, false);
        Exit;
      end;
      if fFilesInfo[Index].FileType = EXPLORER_ITEM_DRIVE then
      begin
        SetNewPath(fFilesInfo[Index].FileName, false);
        Exit;
      end;
      if fFilesInfo[Index].FileType = EXPLORER_ITEM_IMAGE then
      begin
        MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
        try
          If Viewer = nil then
            Application.CreateForm(TViewer, Viewer);
          DBPopupMenuInfoToRecordsInfo(MenuInfo, info);
          Viewer.Execute(Sender, info);
          Viewer.Show;
          RestoreSelected;
        finally
          F(MenuInfo);
        end;
        Exit;
      end;
      if fFilesInfo[Index].FileType = EXPLORER_ITEM_FILE then
      begin
        if GetExt(fFilesInfo[Index].FileName) <> 'LNK' then
        begin
          ShellDir := ExtractFileDir(fFilesInfo[Index].FileName);
          ShellExecute(Handle, nil, PWideChar(fFilesInfo[Index].FileName), nil,
            PWideChar(ShellDir), SW_NORMAL);
          RestoreSelected;
          Exit;
        end else
        begin
          LinkPath := ResolveShortcut(Handle, fFilesInfo[Index].FileName);
          if LinkPath = '' then
            Exit;
          if DirectoryExists(LinkPath) then
          begin
            SetStringPath(LinkPath, false);
            Exit;
          end else
          begin
            if ExtInMask(SupportedExt, GetExt(LinkPath)) then
            begin
              MenuInfo := GetCurrentPopUpMenuInfo(ListView1Selected);
              try
                if Viewer = nil then
                  Application.CreateForm(TViewer, Viewer);
                DBPopupMenuInfoToRecordsInfo(MenuInfo, info);
                Viewer.Execute(Sender, info);
                RestoreSelected;
              finally
                F(MenuInfo);
              end;
              Exit;
            end;
            ShellDir := ExtractFileDir(LinkPath);
            ShellExecute(Handle, nil, PWideChar(LinkPath), nil, PWideChar(ShellDir), SW_NORMAL);
            RestoreSelected;
            Exit;
          end;

        end;
      end;

      case fFilesInfo[Index].FileType of
        EXPLORER_ITEM_NETWORK, EXPLORER_ITEM_WORKGROUP, EXPLORER_ITEM_COMPUTER,
          EXPLORER_ITEM_SHARE:
          SetNewPathW(ExplorerPath(fFilesInfo[Index].FileName,
              fFilesInfo[Index].FileType), false);
      end;
    end;
end;

procedure TExplorerForm.EasyListview1ItemThumbnailDraw(
  Sender: TCustomEasyListview; Item: TEasyItem; ACanvas: TCanvas;
  ARect: TRect; AlphaBlender: TEasyAlphaBlender; var DoDefault: Boolean);
var
  Index, Y : Integer;
  Exists : Integer;
  Info : TExplorerFileInfo;
begin
  if Item.Data = nil then
    Exit;
  if Item.ImageIndex < 0 then
    Exit;

  Index := ItemIndexToMenuIndex(Item.Index);
  Info := FFilesInfo[Index];

  Exists := 1;
  DrawDBListViewItem(TEasyListView(Sender), ACanvas, Item, ARect, FBitmapImageList, Y,
    Info.FileType = EXPLORER_ITEM_IMAGE, Info.ID, Info.FileName,
    Info.Rating, Info.Rotation, Info.Access, Info.Crypted, Exists);
end;

procedure TExplorerForm.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 ListView1SelectItem(Sender,Item,false);
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
  i : integer;
begin
 if IsReallignInfo then
    Exit;

  //to mack backgroupd image
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TWebLink then
      if (Components[I] as TWebLink).Visible then
        (Components[I] as TWebLink).RefreshBuffer;

  for I := 0 to Length(UserLinks) - 1 do
    UserLinks[I].RefreshBuffer;
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
  if Item=nil then
    Exit;

  Comparestr := Item.Caption;
  SetLength(CompareStr, Length(SearchBuffer));

  if IsUnicode then
    CompareResult := lstrcmpiW(PWideChar(SearchBuffer), PWideChar(CompareStr))
  else
    CompareResult := lstrcmpi(PChar(string(SearchBuffer)), PChar(string(CompareStr)));
end;

procedure TExplorerForm.EasyListview1ItemImageDraw(Sender: TCustomEasyListview;
  Item: TEasyItem; Column: TEasyColumn; ACanvas: TCanvas;
  const RectArray: TEasyRectArrayObject; AlphaBlender: TEasyAlphaBlender);
begin
  if Item.Data = nil then
    Exit;

  if FBitmapImageList[Item.ImageIndex].Icon <> nil then
    ACanvas.Draw(RectArray.IconRect.Left, RectArray.IconRect.Top, FBitmapImageList[Item.ImageIndex].Icon);
end;

procedure TExplorerForm.EasyListview1ItemImageDrawIsCustom(
  Sender: TCustomEasyListview; Item: TEasyItem; Column: TEasyColumn;
  var IsCustom: Boolean);
begin
  IsCustom := ListView <> LV_THUMBS;
end;

function TExplorerForm.ListViewTypeToSize(ListViewType : Integer) : Integer;
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

procedure TExplorerForm.SmallIcons1Click(Sender: TObject);
begin
  ListView := LV_SMALLICONS;
  SmallIcons1.Checked := True;
  Reload;
end;

procedure TExplorerForm.Reload;
begin
  SetNewPathW(GetCurrentPathW, False);
  LoadSizes;
end;

procedure TExplorerForm.Icons1Click(Sender: TObject);
begin
  Icons1.Checked := True;
  ListView := LV_ICONS;
  Reload;
end;

procedure TExplorerForm.List1Click(Sender: TObject);
begin
  List1.Checked := True;
  ListView := LV_TITLES;
  Reload;
end;

procedure TExplorerForm.Tile2Click(Sender: TObject);
begin
  Tile2.Checked := True;
  ListView := LV_TILE;
  Reload;
end;

procedure TExplorerForm.Grid1Click(Sender: TObject);
begin
  Grid1.Checked := True;
  ListView := LV_GRID;
  Reload;
end;

procedure TExplorerForm.ToolButtonViewClick(Sender: TObject);
var
  APoint: TPoint;
begin
  APoint := Point(ToolButtonView.Left, ToolButtonView.Top + ToolButtonView.Height);
  APoint := ToolBar1.ClientToScreen(APoint);
  PopupMenu5.Popup(APoint.X, APoint.Y);
end;

procedure TExplorerForm.Thumbnails1Click(Sender: TObject);
begin
  Thumbnails1.Checked := True;
  ListView := LV_THUMBS;
  Reload;
end;

function TExplorerForm.GetView: Integer;
begin
  Result := ListView;
end;

procedure TExplorerForm.MakeFolderViewer2Click(Sender: TObject);
var
  FileList : TArStrings;
  i, index : integer;
begin
 if ListView1Selected<>nil then
 begin
  SetLength(FileList,0);
  for i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE) then
   begin
    SetLength(FileList,Length(FileList)+1);
    FileList[Length(FileList)-1]:=fFilesInfo[index].FileName;
   end;
  end;
  SaveQuery(nil, GetCurrentPath, false, FileList);
 end;
end;

procedure TExplorerForm.ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if not (ssCtrl in Shift) then exit;

  if WheelDelta<0 then
    ZoomIn
  else
    ZoomOut;

 Handled:=true;
end;

procedure TExplorerForm.ZoomIn;
var
  SelectedVisible : boolean;
begin
  ElvMain.BeginUpdate;
  try
     SelectedVisible := IsSelectedVisible;
     if FPictureSize > 50 then
       FPictureSize := FPictureSize - 10;
     LoadSizes;
     BigImagesTimer.Enabled:=false;
     BigImagesTimer.Enabled:=true;
     ElvMain.Scrollbars.ReCalculateScrollbars(false,true);
     ElvMain.Groups.ReIndexItems;
     ElvMain.Groups.Rebuild(true);

    if SelectedVisible then
      ElvMain.Selection.First.MakeVisible(emvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TExplorerForm.ZoomOut;
var
  SelectedVisible : boolean;
begin
  ElvMain.BeginUpdate;
  try
    SelectedVisible:=IsSelectedVisible;
    if FPictureSize < 550 then
      FPictureSize := FPictureSize + 10;
    LoadSizes;
    BigImagesTimer.Enabled := False;
    BigImagesTimer.Enabled := True;
    ElvMain.Scrollbars.ReCalculateScrollbars(False, True);
    ElvMain.Groups.ReIndexItems;
    ElvMain.Groups.Rebuild(True);
    if SelectedVisible then
      ElvMain.Selection.First.MakeVisible(EmvTop);
  finally
    ElvMain.EndUpdate;
  end;
end;

procedure TExplorerForm.BigImagesTimerTimer(Sender: TObject);
var
  Info: TExplorerViewInfo;
  UpdaterInfo: TUpdaterInfo;
  I: Integer;
begin
  BigImagesTimer.Enabled := False;
  if ListView <> LV_THUMBS then
    Exit;
  Info.View := ListView;
  // тут начинается загрузка больших картинок
  UpdaterInfo.IsUpdater := False;
  UpdaterInfo.FileInfo := nil;
  Info.ShowFolders := DBKernel.Readbool('Options', 'Explorer_ShowFolders', True);
  Info.ShowSimpleFiles := DBKernel.Readbool('Options', 'Explorer_ShowSimpleFiles', True);
  Info.ShowImageFiles := DBKernel.Readbool('Options', 'Explorer_ShowImageFiles', True);
  Info.ShowHiddenFiles := DBKernel.Readbool('Options', 'Explorer_ShowHiddenFiles', False);
  Info.ShowAttributes := DBKernel.Readbool('Options', 'Explorer_ShowAttributes', True);
  Info.ShowThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForFolders', True);
  Info.SaveThumbNailsForFolders := DBKernel.Readbool('Options', 'Explorer_SaveThumbnailsForFolders', True);
  Info.ShowThumbNailsForImages := DBKernel.Readbool('Options', 'Explorer_ShowThumbnailsForImages', True);
  Info.View := ListView;
  Info.PictureSize := FPictureSize;
  UpdaterInfo.FileInfo := nil;
  NewFormState;

  TbStop.Enabled := True;
  TExplorerThread.Create('::BIGIMAGES', '', THREAD_TYPE_BIG_IMAGES, Info, Self, UpdaterInfo, StateID);
  for I := 0 to FFilesInfo.Count - 1 do
  begin
    FFilesInfo[I].IsBigImage := False;
  end;
end;

function TExplorerForm.GetAllItems: TExplorerFileInfos;
begin
  Result := TExplorerFileInfos.Create;
  Result.Assign(FFilesInfo);
end;

procedure TExplorerForm.DoDefaultSort(GUID : TGUID);
begin
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
end;

procedure TExplorerForm.AddHiddenInfo1Click(Sender: TObject);
var
  Index: Integer;
begin
  if SelCount = 1 then
  begin
    Index := ItemIndexToMenuIndex(ListView1Selected.index);
    DoSteno(FFilesInfo[index].FileName);
  end;
end;

procedure TExplorerForm.ExtractHiddenInfo1Click(Sender: TObject);
var
  Index: Integer;
begin
  if SelCount=1 then
  begin
    Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
    DoDeSteno(FFilesInfo[Index].FileName);
  end;
end;

procedure TExplorerForm.TbZoomInClick(Sender: TObject);
begin
  ZoomIn;
end;

procedure TExplorerForm.TbZoomOutClick(Sender: TObject);
begin
  ZoomOut;
end;

procedure TExplorerForm.LoadToolBarNormaIcons;
var
  UseSmallIcons : Boolean;

  procedure AddIcon(Name : String);
  var
    Icon : HIcon;
  begin
    if UseSmallIcons then
      Name:=Name + '_SMALL';

    Icon :=  LoadIcon(DBKernel.IconDllInstance, PWideChar(Name));
    ImageList_ReplaceIcon(ToolBarNormalImageList.Handle, -1, Icon);
    DestroyIcon(Icon);
  end;

begin
  UseSmallIcons := DBKernel.Readbool('Options', 'UseSmallToolBarButtons', False);
  ToolBarNormalImageList.Clear;

  if UseSmallIcons then
  begin
    ToolBarNormalImageList.Width:=16;
    ToolBarNormalImageList.Height:=16;
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
  AddIcon('EXPLORER_BREAK');

end;

procedure TExplorerForm.LoadToolBarGrayedIcons();
var
  UseSmallIcons : Boolean;

  procedure AddIcon(Name : String);
  var
    Icon : HIcon;
  begin
    if UseSmallIcons then
      Name := Name + '_SMALL';

    Icon :=  LoadIcon(DBKernel.IconDllInstance, PWideChar(Name));
    ImageList_ReplaceIcon(ToolBarDisabledImageList.Handle, -1, Icon);
    DestroyIcon(Icon);
  end;

begin
  ToolBarDisabledImageList.Clear;

  UseSmallIcons := DBKernel.Readbool('Options', 'UseSmallToolBarButtons', False);
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
  AddIcon('EXPLORER_BREAK_GRAY');

end;

procedure TExplorerForm.TbStopClick(Sender: TObject);
begin
  NewFormState;
  if UpdatingList then
    EndUpdate;
  TbStop.Enabled := False;
  FStatusProgress.Visible := False;
  StatusBar1.Panels[0].Text := L('Loading canceled...');
end;

procedure TExplorerForm.DoStopLoading();
begin
  TbStop.Enabled := False;
  fStatusProgress.Visible := False;
  StatusBar1.Panels[0].Text := '';
end;

procedure TExplorerForm.LoadSizes;
begin
  SetLVThumbnailSize(ElvMain, FPictureSize);
end;

procedure TExplorerForm.PopupMenuZoomDropDownPopup(Sender: TObject);
begin
 Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
 BigImagesSizeForm.Execute(self,fPictureSize,BigSizeCallBack);
end;

procedure TExplorerForm.BigSizeCallBack(Sender: TObject; SizeX,
  SizeY: integer);
var
  SelectedVisible : boolean;
begin
 ElvMain.BeginUpdate;
 SelectedVisible:=IsSelectedVisible;
 FPictureSize:=SizeX;
 LoadSizes();
 BigImagesTimer.Enabled:=false;
 BigImagesTimer.Enabled:=true;

 ElvMain.Scrollbars.ReCalculateScrollbars(false,true);
 ElvMain.Groups.ReIndexItems;
 ElvMain.Groups.Rebuild(true);

 if SelectedVisible then
 ElvMain.Selection.First.MakeVisible(emvTop);
 ElvMain.EndUpdate();
end;

procedure TExplorerForm.MapCD1Click(Sender: TObject);
var
  Info : TCDIndexInfo;
  Dir : string;
begin
  Info := TCDIndexMapping.ReadMapFile(FFilesInfo[PmItemPopup.Tag].FileName);
  if CDMapper = nil then
    CDMapper := TCDDBMapping.Create;
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

procedure TExplorerForm.ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Application.HintHidePause < 5000 then
    Application.HintHidePause := 5000;
end;

function TManagerExplorer.GetExplorerByIndex(index: Integer): TExplorerForm;
begin
  Result := nil;
  FSync.Enter;
  try
    if (Index > -1) and (Index < FExplorers.Count) then
      Result := FExplorers[Index];
  finally
    FSync.Leave;
  end;
end;

function TExplorerForm.TreeView: TShellTreeView;
begin
  if FShellTreeView = nil then
  begin
    FShellTreeView := TShellTreeView.Create(Self);
    FShellTreeView.Parent := MainPanel;
    FShellTreeView.Align := alClient;
    FShellTreeView.AutoRefresh := False;
    FShellTreeView.PopupMenu := PopupMenu8;
    FShellTreeView.RightClickSelect := True;
    FShellTreeView.ShowRoot := False;
    FShellTreeView.OnChange := ShellTreeView1Change;
  end;

  Result := FShellTreeView;
end;

constructor TExplorerForm.Create(AOwner: TComponent;
  GoToLastSavedPath: Boolean);
begin
  FFilesInfo := TExplorerFileInfos.Create;
  FShellTreeView := nil;
  FormLoadEnd := False;
  NoLockListView := False;
  FPictureSize := ThImageSize;
  ElvMain := nil;
  FBitmapImageList := TBitmapImageList.Create;
  FHistory := TStringsHistoryW.Create;
  UpdatingList := False;
  GlobalLock := False;
  NotSetOldPath := True;
  FIsExplorer := False;
  FReadingFolderNumber := 0;
  FChangeHistoryOnChPath := True;
  FGoToLastSavedPath := GoToLastSavedPath;
  inherited Create(AOwner);
end;

procedure TExplorerForm.LoadIcons;
begin
  PmItemPopup.Images := DBKernel.ImageList;
  PmListPopup.Images := DBKernel.ImageList;
  PmLinkOptions.Images := DBKernel.ImageList;
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
  Copy2.ImageIndex := DB_IC_COPY;
  Cut1.ImageIndex := DB_IC_CUT;
  Cut2.ImageIndex := DB_IC_CUT;
  Paste1.ImageIndex := DB_IC_PASTE;
  Paste2.ImageIndex := DB_IC_PASTE;

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
  GoToSearchWindow1.ImageIndex := DB_IC_ADDTODB;
  OpeninSearchWindow1.ImageIndex := DB_IC_ADDTODB;

  PopupMenu8.Images := DBKernel.ImageList;
  OpeninExplorer1.ImageIndex := DB_IC_EXPLORER;
  AddFolder2.ImageIndex := DB_IC_ADD_FOLDER;

  CryptFile1.ImageIndex := DB_IC_CRYPTIMAGE;
  ResetPassword1.ImageIndex := DB_IC_DECRYPTIMAGE;
  EnterPassword1.ImageIndex := DB_IC_PASSWORD;
  Convert1.ImageIndex := DB_IC_CONVERT;
  Resize1.ImageIndex := DB_IC_RESIZE;
  Directory2.ImageIndex := DB_IC_NEW_DIRECTORY;
  TextFile2.ImageIndex := DB_IC_TEXT_FILE;
  RotateCCW1.ImageIndex := DB_IC_ROTETED_270;
  RotateCW1.ImageIndex := DB_IC_ROTETED_90;
  Rotateon1801.ImageIndex := DB_IC_ROTETED_180;
  Rotate1.ImageIndex := DB_IC_ROTETED_0;
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

  SendTo1.ImageIndex := DB_IC_SEND;
  View2.ImageIndex := DB_IC_SLIDE_SHOW;

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

  RatingPopupMenu1.Images := DBkernel.ImageList;

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

  TLoad.Instance.RequaredDBKernelIcons;
  SlideShowLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SLIDE_SHOW + 1]);
  ShellLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_SHELL + 1]);
  CopyToLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_COPY + 1]);
  MoveToLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_CUT + 1]);
  RenameLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_RENAME + 1]);
  PropertiesLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PROPERTIES + 1]);
  DeleteLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DELETE_INFO + 1]);
  AddLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_NEW + 1]);
  RefreshLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_REFRESH_THUM + 1]);
  ImageEditorLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_IMEDITOR + 1]);
  PrintLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_PRINTER + 1]);
  MyPicturesLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_PICTURES + 1]);
  MyDocumentsLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_DOCUMENTS + 1]);
  MyComputerLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_MY_COMPUTER + 1]);
  DesktopLink.LoadFromHIcon(UnitDBKernel.Icons[DB_IC_DESKTOPLINK + 1]);
end;

destructor TExplorerForm.Destroy;
begin
  F(FHistory);
  F(FFilesInfo);
  F(RefreshIDList);
  inherited;
end;

initialization

  ExplorerManager := TManagerExplorer.Create;

Finalization

  F(ExplorerManager);

end.
