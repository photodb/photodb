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
  ShellContextMenu, ShlObj, Clipbrd, GraphicsCool,
  ProgressActionUnit, GraphicsBaseTypes, Math, DB, CommonDBSupport,
  EasyListview, MPCommonUtilities, MPCommonObjects,
  UnitRefreshDBRecordsThread, UnitPropeccedFilesSupport,
  UnitCryptingImagesThread, uVistaFuncs, wfsU, UnitDBDeclare, GraphicEx,
  UnitDBFileDialogs, UnitDBCommonGraphics, UnitFileExistsThread,
  UnitDBCommon, UnitCDMappingSupport, SyncObjs, uResources,
  uFormListView, uAssociatedIcons, uLogger, uConstants, uTime, uFastLoad,
  uFileUtils, uListViewUtils, uDBDrawing, uW7TaskBar, uMemory;

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
    NormalImages: TImage;
    ToolBar2: TToolBar;
    Label2: TLabel;
    PopupMenuBack: TPopupMenu;
    PopupMenuForward: TPopupMenu;
    DragTimer: TTimer;
    SelectedImages: TImage;
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
    PopupMenu3: TPopupMenu;
    OpeninNewWindow2: TMenuItem;
    Open2: TMenuItem;
    TextFile1: TMenuItem;
    Directory2: TMenuItem;
    TextFile2: TMenuItem;
    Copywithfolder1: TMenuItem;
    PopupMenu4: TPopupMenu;
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
    WaitingPanel: TPanel;
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
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton17: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButtonView: TToolButton;
    ToolButton11: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton12: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton19: TToolButton;
    ToolButton18: TToolButton;
    ToolButton20: TToolButton;
    PopupMenuZoomDropDown: TPopupMenu;
    MapCD1: TMenuItem;
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
    procedure UpdateTheme(Sender: TObject);
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
    procedure SetInfoToItemW(info : TOneRecordInfo; Number : Integer);
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
    procedure GroupManager1Click(Sender: TObject);
    procedure GetUpdates1Click(Sender: TObject);
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
    procedure CDROMDrives1Click(Sender: TObject);
    procedure RemovableDrives1Click(Sender: TObject);
    procedure SpecialLocation1Click(Sender: TObject);
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BigImagesTimerTimer(Sender: TObject);
    procedure ListView1MouseWheel(Sender: TObject; Shift: TShiftState;
    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    function GetAllItems : TExplorerFileInfos;
    procedure DoDefaultSort(GUID : TGUID);
    procedure DoStopLoading;
    procedure AddHiddenInfo1Click(Sender: TObject);
    procedure ExtractHiddenInfo1Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
    procedure PopupMenuZoomDropDownPopup(Sender: TObject);
    procedure MapCD1Click(Sender: TObject);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ClearList;
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
     RefreshIDList : TArInteger;
     rdown : boolean;
     outdrag : boolean;
     fpopupdown : boolean;
     SelfDraging : boolean;
     FDblClicked : Boolean;
     FSelectedInfo : TSelectedInfo;
     fStatusProgress : TProgressBar;
     fFilesInfo : TExplorerFileInfos;
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
     CopyInstances : integer;
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
     procedure CorrectPath(Src : array of string; Dest : string);
     procedure LoadIcons;
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
   public
     NoLockListView : boolean;
     Procedure LoadLanguage;
     procedure LoadSizes;
     procedure BigSizeCallBack(Sender : TObject; SizeX, SizeY : integer);
     constructor Create(AOwner : TComponent; GoToLastSavedPath : Boolean); reintroduce; overload;
     destructor Destroy; override;
     property WindowID : TGUID read FWindowID;
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
  ExplorerManager : TManagerExplorer;

implementation

uses Language, UnitUpdateDB, ExplorerThreadUnit, Searching,
     SlideShow, PropertyForm, UnitHintCeator, UnitImHint,
     FormManegerUnit, Options, ManagerDBUnit, UnitExplorerThumbnailCreatorThread,
     uAbout, uActivation, UnitPasswordForm, UnitCryptImageForm,
     UnitFileRenamerForm, UnitImageConverter, UnitSizeResizerForm, ImEditor,
     UnitRotateImages, UnitManageGroups, UnitInternetUpdate, UnitHelp,
     UnitExportImagesForm, UnitGetPhotosForm, UnitFormCont,
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
  UnFormatDir(Result);
  for I:=1 to Length(Result) do
  begin
    if Result[i] = ':' then Result[i] := '_';
    if Result[i] = '\' then Result[i] := '_';
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
      ToolButton7.Enabled := Files.Count > 0;
    finally
      F(Files);
    end;
    if (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) then
      ToolButton7.Enabled := False;
  end;
end;

procedure TExplorerForm.CreateBackgrounds;
var
  ExplorerBackground : TPNGGraphic;
  Bitmap, ExplorerBackgroundBMP : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := 150;
    Bitmap.Height := 150;
    Bitmap.Canvas.Brush.Color := Theme_ListColor;
    Bitmap.Canvas.Pen.Color := Theme_ListColor;
    Bitmap.Canvas.Rectangle(0, 0, 150, 150);
    ExplorerBackground := GetExplorerBackground;
    try
      ExplorerBackgroundBMP := TBitmap.Create;
      try
        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, Theme_ListColor);
        Bitmap.Canvas.Draw(0, 0, ExplorerBackgroundBMP);

        LoadPNGImage32bit(ExplorerBackground, ExplorerBackgroundBMP, ScrollBox1.Color);

        ScrollBox1.BackGround.PixelFormat := pf24bit;
        ScrollBox1.BackGround.Width := 130;
        ScrollBox1.BackGround.Height := 150;
        ScrollBox1.BackGround.Canvas.Brush.Color := ScrollBox1.Color;
        ScrollBox1.BackGround.Canvas.Pen.Color := ScrollBox1.Color;
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


  ElvMain.HotTrack.Color := Theme_ListFontColor;
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

  TLoad.Instance.RequaredDBSettings;
  FPictureSize:=ThImageSize;
  LoadSizes;

  FWindowID:=GetGUID;
  SetLength(RefreshIDList,0);

  SetLength(UserLinks,0);
  SetLength(FPlaces,0);
  DragFilesPopup:=TStringList.Create;

  SelfDraging:=false;
  FDblClicked:=false;
  FIsExplorer:=false;
  SetLength(FListDragItems,0);
  fDBCanDragW:=false;
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
  DBKernel.RegisterProcUpdateTheme(UpdateTheme,self);
  DBKernel.RegisterChangesID(Sender,ChangedDBDataByID);

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

  TW.I.Start('RecreateThemeToForm');
  DBKernel.RecreateThemeToForm(Self);
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

  for i:=0 to ComponentCount-1 do
    if Components[i] is TWebLink then
     (Components[i] as TWebLink).GetBackGround := BackGround;

  for i:=0 to Length(UserLinks)-1 do
    UserLinks[i].GetBackGround := BackGround;

  ExplorerManager.AddExplorer(Self);
  DBKernel.RegisterForm(Self);
  MainPanel.DoubleBuffered:=true;
  PropertyPanel.DoubleBuffered:=true;
  ElvMain.DoubleBuffered:=true;
  ScrollBox1.DoubleBuffered:=true;

  ToolBar2.ButtonHeight:=22;
  ToolButton18.Enabled:=false;
  SaveWindowPos1.Key:=RegRoot+'Explorer\'+MakeRegPath(GetCurrentPath);
  SaveWindowPos1.SetPosition;
  FormLoadEnd:=true;

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
  FW7TaskBar := CreateTaskBarInstance;
  CreateBackgrounds;
  GOM.AddObj(Self);
end;

procedure TExplorerForm.ListView1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TEasyItem;
  FileNames : TArStrings;
  i, index : Integer;
  r : TRect;
  VitrualKey : boolean;
begin
  if CopyFilesSynchCount > 0 then
    WindowsMenuTickCount := GetTickCount;

  rdown:=false;
  FDblClicked:=false;
  HintTimer.Enabled:=false;
  FDBCanDrag:=false;

  Item := ItemByPointImage(ElvMain, Point(MousePos.x,MousePos.y), ListView);
  VitrualKey:=((MousePos.x=-1) and (MousePos.y=-1));
 if (Item=nil) or VitrualKey then Item:=ElvMain.Selection.First;

 r :=  ElvMain.Scrollbars.ViewableViewportRect;
 if (Item<>nil) and (Item.SelectionHitPt(Point(MousePos.x+r.Left,MousePos.y+r.Top), eshtClickSelect) or VitrualKey) then
 begin
  LastMouseItem:= nil;
  Application.HideHint;
  THintManager.Instance.CloseHint;
  if Item.Index>fFilesInfo.Count-1 then exit;

  SetForegroundWindow(Self.Handle);
  SetLength(fFilesToDrag,0);
  fpopupdown:=true;
  if not (GetTickCount-WindowsMenuTickCount>WindowsMenuTime) then
  begin
   PmItemPopup.Tag:=ItemIndexToMenuIndex(Item.Index);
   PmItemPopup.Popup(ElvMain.clienttoscreen(MousePos).X ,ElvMain.clienttoscreen(MousePos).y);
  end else
  begin
   Screen.Cursor:=CrDefault;
   if ListView1Selected<>nil then
   begin
    SetLength(FileNames,0);
    for i:=0 to ElvMain.Items.Count-1 do
    If ElvMain.Items[i].Selected then
    begin
     index:=ItemIndexToMenuIndex(i);
     SetLength(FileNames,Length(FileNames)+1);
     FileNames[Length(FileNames)-1]:=fFilesInfo[index].FileName;
    end;
    GetProperties(FileNames,MousePos,ElvMain);
   end;
  end;
 end else
   PmListPopup.Popup(ElvMain.clienttoscreen(MousePos).X ,ElvMain.clienttoscreen(MousePos).y);
end;

procedure TExplorerForm.SlideShow1Click(Sender: TObject);
var
  filename : string;
  info: TRecordsInfo;
  MenuInfo: TDBPopupMenuInfo;
begin
 filename:=fFilesInfo[PmItemPopup.tag].FileName;
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin
  MenuInfo:=GetCurrentPopUpMenuInfo(ListView1Selected);
  If Viewer=nil then
  Application.CreateForm(TViewer, Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.Execute(Sender,info);
  Viewer.Show;
 end;
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_FOLDER then
 Viewer.ShowFolderA(fFilesInfo[PmItemPopup.tag].FileName,ExplorerManager.ShowPrivate);
end;

procedure TExplorerForm.Shell1Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PWideChar(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName)), nil, nil, SW_NORMAL);
end;

procedure TExplorerForm.Properties1Click(Sender: TObject);
var
  info : TDBPopupMenuInfo;
  i, index : integer;
  ArInt : TArInteger;
  Files : TArStrings;
  WindowsProperty : Boolean;
begin
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin
  if SelCount>1 then
  begin
   info:=GetCurrentPopUpMenuInfo(nil);
   SetLength(ArInt,0);
   WindowsProperty:=true;
   for i:=0 to info.Count - 1 do
   if info[i].Selected then
   begin
    SetLength(ArInt,Length(ArInt)+1);
    ArInt[Length(ArInt)-1]:=info[i].ID;
    if info[i].ID<>0 then WindowsProperty:=false;
   end;
   if not WindowsProperty then
   PropertyManager.NewSimpleProperty.ExecuteEx(ArInt) else
   begin
    SetLength(Files,0);
    for i:=0 to ElvMain.Items.Count-1 do
    If ElvMain.Items[i].Selected then
    begin
     index:=ItemIndexToMenuIndex(i);
     SetLength(Files,Length(Files)+1);
     Files[Length(Files)-1]:=fFilesInfo[index].FileName;
    end;
    GetPropertiesWindows(Files,ElvMain);
   end;
  end else
  begin
  if not fFilesInfo[PmItemPopup.tag].Loaded then
  fFilesInfo[PmItemPopup.tag].ID:=Dolphin_DB.GetIdByFileName(fFilesInfo[PmItemPopup.tag].FileName);
  If fFilesInfo[PmItemPopup.tag].ID=0 then
  PropertyManager.NewFileProperty(fFilesInfo[PmItemPopup.tag].FileName).ExecuteFileNoEx(fFilesInfo[PmItemPopup.tag].FileName) else
  PropertyManager.NewIDProperty(fFilesInfo[PmItemPopup.tag].ID).Execute(fFilesInfo[PmItemPopup.tag].ID);
  end;
 end else
 begin
  SetLength(Files,0);
  for i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   SetLength(Files,Length(Files)+1);
   Files[Length(Files)-1]:=fFilesInfo[index].FileName;
  end;
  GetPropertiesWindows(Files,ElvMain);
 end;
end;

procedure TExplorerForm.PmItemPopupPopup(Sender: TObject);
var
  info : TDBPopupMenuInfo;
  item: TEasyItem;
  Point : TPoint;
  Files : TStrings;
  Effects, i : Integer;
  b : boolean;
begin
 GetCursorPos(Point);
 Paste2.Visible:=false;
 SendTo1.Visible:=false;
 MakeFolderViewer2.Visible:=false;
 MapCD1.Visible:=false;
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_DRIVE then
 begin
  DBitem1.Visible:=false;
  Print1.Visible:=false;
  RefreshID1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  Refresh1.Visible:=false;
  CryptFile1.Visible:=false;
  EnterPassword1.Visible:=false;
  ResetPassword1.Visible:=false;
  NewWindow1.Visible:=true;
  AddFile1.Caption:=TEXT_MES_ADD_DISK;
  AddFile1.Visible:=True;
  Properties1.Visible:=True;
  Open1.Visible:=true;
  SlideShow1.Visible:=True;
  Rename1.Visible:=false;
  Delete1.Visible:=false;
  Files:=TStringList.Create;
  LoadFIlesFromClipBoard(Effects,Files);
  if Files.Count<>0 then Paste2.Enabled:=true else Paste2.Enabled:=false;
  Files.free;
  Cut2.Visible:=false;
  Copy1.Visible:=false;
  Paste2.Visible:=True;
  Shell1.Visible:=True;
 end;
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_FOLDER then
 begin
  DBitem1.Visible:=false;
  MakeFolderViewer2.Visible:=not FolderView;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Refresh1.Visible:=true;
  NewWindow1.Visible:=true;
  AddFile1.Caption:=TEXT_MES_ADD_DIRECTORY;
  AddFile1.Visible:=True;
  Properties1.Visible:=True;
  Paste2.Visible:=True;
  Open1.Visible:=true;
  Delete1.Visible:=True;
  Rename1.Visible:=True;
  SlideShow1.Visible:=True;
  Files:=TStringList.Create;
  LoadFIlesFromClipBoard(Effects,Files);
  if Files.Count<>0 then Paste2.Enabled:=true else Paste2.Enabled:=false;
  Files.free;

  b:=CanCopySelection;
  Cut2.Visible:= b;
  Copy1.Visible:= b;
  Paste2.Visible:=True;
  Shell1.Visible:=True;
 end;
 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_IMAGE then
 begin
  DBitem1.Visible:=true;
  StenoGraphia1.Visible:=true;
  AddHiddenInfo1.Visible:= (SelCount=1);
  ExtractHiddenInfo1.Visible:=True;
  ExtractHiddenInfo1.Visible:=ExtInMask('|PNG|BMP|',GetExt(fFilesInfo[PmItemPopup.tag].FileName));

  MakeFolderViewer2.Visible:=not FolderView ;
  Print1.Visible:=True;
  Othertasks1.Visible:=True;
  ImageEditor2.Visible:=True;
  CryptFile1.Visible:=not ValidCryptGraphicFile(fFilesInfo[PmItemPopup.tag].FileName);
  ResetPassword1.Visible:=not CryptFile1.Visible;
  EnterPassword1.Visible:=not CryptFile1.Visible and (DBkernel.FindPasswordForCryptImageFile(fFilesInfo[PmItemPopup.tag].FileName)='') ;

  Convert1.Visible:=not EnterPassword1.Visible;
  Resize1.Visible:=not EnterPassword1.Visible;
  Rotate1.Visible:=not EnterPassword1.Visible;
  RefreshID1.Visible:=(not EnterPassword1.Visible) and (fFilesInfo[PmItemPopup.tag].ID<>0);
  SetasDesktopWallpaper1.Visible:=CryptFile1.Visible and IsWallpaper(fFilesInfo[PmItemPopup.tag].FileName);
  Refresh1.Visible:=True;
  Open1.Visible:=false;
  Shell1.Visible:=True;
  Rename1.Visible:=True;
  NewWindow1.Visible:=false;
  Properties1.Visible:=true;
  SlideShow1.Visible:=True;
  Delete1.Visible:=True;
  AddFile1.Caption:=TEXT_MES_ADDFILE;
  if fFilesInfo[PmItemPopup.tag].ID=0 then
  AddFile1.Visible:=true else AddFile1.Visible:=false;
  Cut2.Visible:=True;
  Copy1.Visible:=True;
  Paste2.Visible:=false;
 end;
 If (fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_EXEFILE) then
 begin
  if AnsiLowerCase(ExtractFileName(fFilesInfo[PmItemPopup.tag].FileName))=AnsiLowerCase(TEXT_MES_CD_MAP_FILE) then
  begin
   MapCD1.Visible:=not FolderView;
  end;
  DBitem1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  Refresh1.Visible:=false;
  NewWindow1.Visible:=false;
  Open1.Visible:=false;
  SlideShow1.Visible:=false;
  Properties1.Visible:=True;
  Delete1.Visible:=True;
  Rename1.Visible:=True;
  AddFile1.Visible:=false;
  Cut2.Visible:=True;
  Copy1.Visible:=True;
  Paste2.Visible:=false;
  Shell1.Visible:=True;
 end;

 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_NETWORK then
 begin
  DBitem1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  Refresh1.Visible:=False;
  NewWindow1.Visible:=True;
  Open1.Visible:=True;
  SlideShow1.Visible:=false;
  Properties1.Visible:=false;
  Delete1.Visible:=false;
  Rename1.Visible:=false;
  AddFile1.Visible:=false;
  Cut2.Visible:=false;
  Copy1.Visible:=false;
  Paste2.Visible:=false;
  Shell1.Visible:=false;
 end;

 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_WORKGROUP then
 begin
  DBitem1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  Refresh1.Visible:=False;
  NewWindow1.Visible:=True;
  Open1.Visible:=True;
  SlideShow1.Visible:=false;
  Properties1.Visible:=false;
  Delete1.Visible:=false;
  Rename1.Visible:=false;
  AddFile1.Visible:=false;
  Cut2.Visible:=false;
  Copy1.Visible:=false;
  Paste2.Visible:=false;
  Shell1.Visible:=false;
 end;

 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_COMPUTER then
 begin
  DBitem1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  Refresh1.Visible:=False;
  NewWindow1.Visible:=True;
  Open1.Visible:=True;
  SlideShow1.Visible:=false;
  Properties1.Visible:=false;
  Delete1.Visible:=false;
  Rename1.Visible:=false;
  AddFile1.Visible:=false;
  Cut2.Visible:=false;
  Copy1.Visible:=false;
  Paste2.Visible:=false;
  Shell1.Visible:=false;
 end;

 If fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_SHARE then
 begin
  DBitem1.Visible:=false;
  StenoGraphia1.Visible:=false;
  Print1.Visible:=false;
  Othertasks1.Visible:=false;
  ImageEditor2.Visible:=false;
  RefreshID1.Visible:=false;
  Rotate1.Visible:=false;
  SetasDesktopWallpaper1.Visible:=false;
  Convert1.Visible:=false;
  Resize1.Visible:=false;
  CryptFile1.Visible:=false;
  ResetPassword1.Visible:=false;
  EnterPassword1.Visible:=false;
  Refresh1.Visible:=False;
  NewWindow1.Visible:=True;
  Open1.Visible:=True;
  SlideShow1.Visible:=false;
  Properties1.Visible:=false;
  Delete1.Visible:=false;
  Rename1.Visible:=false;
  AddFile1.Visible:=false;
  Cut2.Visible:=false;
  Copy1.Visible:=false;
  Paste2.Visible:=false;
  Shell1.Visible:=false;
 end;

 Item:=ItemAtPos(ElvMain.ScreenToClient(Point).X,ElvMain.ScreenToClient(Point).y);
 if PmItemPopup.tag<0 then exit;
 For i:=DBitem1.MenuIndex+1 to N8.MenuIndex-1 do
 PmItemPopup.Items.Delete(DBitem1.MenuIndex+1);

 if DBitem1.Visible then
  begin
    info := GetCurrentPopUpMenuInfo(Item);
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
        TDBPopupMenu.Instance.SetInfo(Info);
        TDBPopupMenu.Instance.AddUserMenu(PmItemPopup.Items, True, DBitem1.MenuIndex + 1);
      end;
  end;
end;

procedure TExplorerForm.Copy1Click(Sender: TObject);
Var
  i, index : integer;
  File_List : TStrings;
begin
 File_List:=TStringList.Create;
 For i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  File_List.Add(ProcessPath(fFilesInfo[index].FileName));
 end;
 if File_List.Count>0 then
 Copy_Move(True,File_List);
 File_List.Free;
end;

procedure TExplorerForm.Rename1Click(Sender: TObject);
var
  i, ItemIndex : integer;
  Files : TStrings;
  X : TArInteger;
begin
 if SelCount=1 then
 if ListView1Selected<>nil then
 begin
  ElvMain.SetFocus;

  ElvMain.EditManager.Enabled:=true;
  ElvMain.Selection.First.Edit;

 end;
 if SelCount>1 then
 begin
  Files := TStringList.Create;
  For i:=0 to ElvMain.Items.Count-1 do
  begin
   if ElvMain.Items[i].Selected then
   begin
   ItemIndex:=ItemIndexToMenuIndex(i);
   if (fFilesInfo[ItemIndex].FileType=EXPLORER_ITEM_IMAGE) or (fFilesInfo[ItemIndex].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[ItemIndex].FileType=EXPLORER_ITEM_EXEFILE) or (fFilesInfo[ItemIndex].FileType=EXPLORER_ITEM_FOLDER) then
    begin
     SetLength(X,Length(X)+1);
     X[Length(X)-1]:=fFilesInfo[ItemIndex].ID;
     Files.Add(ProcessPath(fFilesInfo[ItemIndex].FileName));
    end
   end;
  end;
  FastRenameManyFiles(Files,X);
  Files.Free;
 end;
end;

Procedure TExplorerForm.DeleteFiles(ToRecycle : Boolean);
var
  i : integer;
  Index : integer;
  S : TArStrings;
begin
 If SelCount=0 then Exit;
 SetLength(S,0);
 For i:=0 to ElvMain.Items.Count-1 do
 if ElvMain.Items[i].Selected then
 begin
  Index := ItemIndexToMenuIndex(i);
  SetLength(S,Length(S)+1);
  S[Length(S)-1]:=fFilesInfo[Index].FileName
 end;
 uFIleUtils.DeleteFiles( Self.Handle, S , ToRecycle );
end;

procedure TExplorerForm.Delete1Click(Sender: TObject);
begin
 DeleteFiles(True);
end;

procedure TExplorerForm.AddFile1Click(Sender: TObject);
Var
 i, index :integer;
begin
// SizeImageList.
// ToolBar1.Images
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 If ListView1Selected<>nil then
 begin
  For i:=0 to ElvMain.Items.Count-1 do
  begin

  if i>ElvMain.Items.Count-1 then exit;
  if ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if index>fFilesInfo.Count-1 then exit;
   If fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER then
   begin
    UpdaterDB.AddDirectory(fFilesInfo[index].FileName,nil);
    Continue;
   end;
   If fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE then
   begin
    UpdaterDB.AddFile(fFilesInfo[index].FileName);
    Continue;
   end;
   If fFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE then
   If ID_OK=MessageBoxDB(Handle,TEXT_MES_ADD_DRIVE,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
   begin
    UpdaterDB.AddDirectory(fFilesInfo[index].FileName,nil);
    Continue;
   end;
  end;
 end;
 end;
 if (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) then
 if SelCount=0 then
 begin
  If UpdaterDB=nil then
  UpdaterDB:=TUpdaterDB.Create;
  UpdaterDB.AddDirectory(GetCurrentPath,nil);
 end;
end;

procedure TExplorerForm.UpdateTheme(Sender: TObject);
var
  i : integer;
begin
  ElvMain.Selection.FullCellPaint:=DBKernel.Readbool('Options','UseListViewFullRectSelect',false);
  ElvMain.Selection.RoundRectRadius:=DBKernel.ReadInteger('Options','UseListViewRoundRectSize',3);
  ListView1SelectItem(Sender,ListView1Selected,ListView1Selected=nil);
  for i:=0 to Length(UserLinks)-1 do
  begin
   UserLinks[i].Color:=Theme_MainColor;
   UserLinks[i].Font.Color:=Theme_MainFontColor;
   UserLinks[i].Refresh;
  end;

  CreateBackgrounds;
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
//  F(ExtIcons);
  SaveWindowPos1.SavePosition;
  DropFileTarget2.Unregister;
  DropFileTarget1.Unregister;
  DBKernel.UnRegisterChangesID(Sender,ChangedDBDataByID);
  DBKernel.UnRegisterProcUpdateTheme(UpdateTheme, Self);

  DBkernel.WriteInteger('Explorer','LeftPanelWidth',MainPanel.Width);

  DBkernel.WriteString('Explorer','Patch',GetCurrentPathW.Path);
  DBkernel.WriteInteger('Explorer','PatchType',GetCurrentPathW.PType);
  fStatusProgress.free;
  FormManager.UnRegisterMainForm(Self);
  DBKernel.UnRegisterForm(self);
  F(FFilesInfo);
  GOM.RemoveObj(Self);
end;

procedure TExplorerForm.ListView1Edited(Sender: TObject; Item: TEasyItem;
      var S: String);
var
  DS : TDataSet;
  Folder : String;
begin
 FDblClicked:=false;
 s:=copy(s,1,min(length(s),255));
 if AnsiLowerCase(s)=AnsiLowerCase(ExtractFileName(fFilesInfo[PmItemPopup.tag].FileName)) then exit;
 begin
  If GetExt(s)<>GetExt(fFilesInfo[PmItemPopup.tag].FileName) then
  If FileExists(fFilesInfo[PmItemPopup.tag].FileName) then
  begin
   If ID_OK<>MessageBoxDB(Handle,TEXT_MES_REPLACE_EXT,TEXT_MES_WARNING,TD_BUTTON_OKCANCEL,TD_ICON_WARNING) then
   begin
    s:=ExtractFileName(fFilesInfo[PmItemPopup.tag].FileName);
    Exit;
   end;
  end;
  if fFilesInfo[PmItemPopup.tag].FileType=EXPLORER_ITEM_FOLDER then
  begin
   DS:=GetQuery;
   Folder:=fFilesInfo[PmItemPopup.tag].FileName;
   FormatDir(Folder);
   SetSQL(DS,'Select count(*) as CountField from $DB$ where (FFileName Like :FolderA)');
   SetStrParam(DS,0,normalizeDBStringLike('%'+Folder+'%'));
   DS.Open;
   if DS.FieldByName('CountField').AsInteger=0 then
   begin
    try
     RenameResult:=RenameFile(fFilesInfo[PmItemPopup.tag].FileName,GetDirectory(fFilesInfo[PmItemPopup.tag].FileName)+s);
    except
     RenameResult:=false;
    end;
   end else
   RenameResult:=RenamefileWithDB(Self, fFilesInfo[PmItemPopup.tag].FileName,GetDirectory(fFilesInfo[PmItemPopup.tag].FileName)+s, fFilesInfo[PmItemPopup.tag].ID,false);
   FreeDS(DS);
  end else
  RenameResult:=RenamefileWithDB(Self, fFilesInfo[PmItemPopup.tag].FileName,GetDirectory(fFilesInfo[PmItemPopup.tag].FileName)+s, fFilesInfo[PmItemPopup.tag].ID,false);
 end;
end;

procedure TExplorerForm.HintTimerTimer(Sender: TObject);
var
  p, p1:tpoint;
  Index, i : integer;
  MenuInfo : TDBPopupMenuInfoRecord;
begin
 GetCursorPos(p);
 p1:=ElvMain.ScreenToClient(p);
 if (not Active) or (not ElvMain.Focused) or (ItemAtPos(p1.X,p1.y)<>LastMouseItem) or (ItemWithHint<>LastMouseItem) then
 begin
  HintTimer.Enabled:=false;
  Exit;
 end;
 if LastMouseItem=nil then exit;
 Index:=LastMouseItem.index;
 if Index<0 then exit;
 Index:=ItemIndexToMenuIndex(index);
 if Index>fFilesInfo.Count-1 then exit;

  if not (CtrlKeyDown or ShiftKeyDown) then
  if DBKernel.Readbool('Options','UseHotSelect',true) then
  if not LastMouseItem.Selected then
  begin
   if not (CtrlKeyDown or ShiftKeyDown) then
   for i:=0 to ElvMain.Items.Count-1 do
   if ElvMain.Items[i].Selected then
   if LastMouseItem<>ElvMain.Items[i] then
   ElvMain.Items[i].Selected:=false;
   if ShiftKeyDown then
    ElvMain.Selection.SelectRange(LastMouseItem,ElvMain.Selection.FocusedItem,false,false) else
   if not ShiftKeyDown then
   begin
    LastMouseItem.Selected:=true;
   end;
  end;
  LastMouseItem.Focused:=true;

 if not ExtInMask(SupportedExt,GetExt(FFilesInfo[Index].FileName)) then begin exit; end;

 If not FileExists(fFilesInfo[Index].FileName) then exit;
 HintTimer.Enabled:=false;

  MenuInfo := TDBPopupMenuInfoRecord.CreateFromExplorerInfo(FFilesInfo[Index]);
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

procedure TExplorerForm.SetInfoToItemW(info : TOneRecordInfo; Number : Integer);
var
  InternalInfo : TExplorerFileInfo;
begin
  InternalInfo := fFilesInfo[Number];
  InternalInfo.FileName:=info.ItemFileName;
  InternalInfo.ID:=info.ItemId;
  InternalInfo.Rotate:=info.ItemRotate;
  InternalInfo.Access:=info.ItemAccess;
  InternalInfo.Rating:=info.ItemRating;
  InternalInfo.FileSize:=info.ItemSize;
  InternalInfo.Comment:=info.ItemComment;
  InternalInfo.KeyWords:=info.ItemKeyWords;
  InternalInfo.FileType:=Info.Tag;
  InternalInfo.Date:=Info.ItemDate;
  InternalInfo.Time:=Info.ItemTime;
  InternalInfo.IsDate:=Info.ItemIsDate;
  InternalInfo.IsTime:=Info.ItemIsTime;
  InternalInfo.Groups:=Info.ItemGroups;
  InternalInfo.Crypted:=Info.ItemCrypted;
  InternalInfo.Include:=Info.ItemInclude;
  InternalInfo.Links:=Info.ItemLinks;
  if AnsiLowerCase(Info.ItemFileName) = AnsiLowerCase(FSelectedInfo.FileName) then
    ListView1SelectItem(nil, nil, false);
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
      ExplorerInfo.Rotate := info.ItemRotate;
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
  dir: string;
  i : integer;
  b : Boolean;
begin
 b:=false;
 If FIsExplorer then
 begin
  if TreeView.Selected<>nil then
  TreeView.Select(TreeView.Selected.Parent);
 end else
 begin
  dir:=GetCurrentPath;
  if GetCurrentPathW.PType=EXPLORER_ITEM_COMPUTER then
  begin
   SetNewPathW(ExplorerPath(GetResourceParent(dir),EXPLORER_ITEM_WORKGROUP),false);
   Exit;
  end;
  if GetCurrentPathW.PType=EXPLORER_ITEM_WORKGROUP then
  begin
   SetNewPathW(ExplorerPath(TEXT_MES_NETWORK,EXPLORER_ITEM_NETWORK),false);
   Exit;
  end;

  For i:=length(dir)-1 downto 1 do
  if dir[i]='\' then
  begin
   dir:=copy(dir,1,i);
   SetNewPath(dir,false);
   b:=true;
   Break;
  end;
 end;
 If not b then
 begin
  SetNewPath('',false);
 end;
end;

procedure TExplorerForm.BeginUpdate;
begin
  if not UpdatingList then
  begin
    ElvMain.Groups[0].Visible:=false;
    ElvMain.Cursor:=CrHourGlass;
    UpdatingList:=True;
    ElvMain.BeginUpdate;
  end;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressState(Handle, TBPF_INDETERMINATE);
end;

procedure TExplorerForm.EndUpdate;
begin
  if UpdatingList then
  begin
    ElvMain.EndUpdate;
    ElvMain.Groups[0].Visible := True;
    ElvMain.Groups.EndUpdate(true);
    ElvMain.Realign;
    ElvMain.Repaint;
    ElvMain.Cursor:=CrDefault;
    ElvMain.HotTrack.Enabled:=DBKernel.Readbool('Options', 'UseHotSelect', True);
    UpdatingList := False;
  end;
  if FW7TaskBar <> nil then
    FW7TaskBar.SetProgressState(Handle, TBPF_NOPROGRESS);
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
      MenuRecord := TDBPopupMenuInfoRecord.CreateFromExplorerInfo(FFilesInfo[ItemIndex]);
      MenuRecord.Selected := ElvMain.Items[I].Selected;
      Result.Add(MenuRecord);
      if Item <> nil then
        if ElvMain.Items[I].Selected then
          Result.Position := Result.Count - 1;
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

procedure TExplorerForm.CbPathEditKeyPress(Sender: TObject; var Key: Char);
var
  s : string;
begin
 If key=#13 then
 begin
  Key:=#0;
  SetStringPath(CbPathEdit.text,false);
 end;
 if (key=':') or (key='\') then
 begin
  if SlashHandled then
  begin
   SlashHandled:=false;
   exit;
  end;
  s:=CbPathEdit.Text;
  FormatDir(s);
  if ComboPath<>GetDirectory(s) then
  begin
   ComboPath:=GetDirectory(CbPathEdit.Text);
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
 CbPathEdit.Width:=CoolBar1.Width-ImButton1.Width-Label2.Width-ToolButton9.Width-ImButton1.Width;
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
 Button1.Left:=CloseButtonPanel.Width-Button1.Width-3;
end;

procedure TExplorerForm.Splitter1CanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
 if NewSize<100 then Accept:=false;
end;

procedure TExplorerForm.ListView1SelectItem(Sender: TObject;
  Item: TEasyItem; Selected: Boolean);
begin
 SelectTimer.Enabled:=true;
end;

procedure TExplorerForm.ChangedDBDataByID(Sender: TObject; ID: integer;
  params: TEventFields; Value: TEventValues);
var
  ImParams, UpdateInfoParams: TEventFields;
  i, index, ReRotation : integer;
  bit : TBitmap;
begin
 if EventID_Repaint_ImageList in params then
 begin
  ElvMain.Refresh;
  exit;
 end;
 if ID=-2 then exit;
 if SetNewIDFileData in params then
 begin
  for i:=0 to fFilesInfo.Count-1 do
  if AnsiLowerCase(fFilesInfo[i].FileName)=Value.Name then
  begin
   //fFilesInfo[i].SID:=GetCid; //?

   if HelpNo=3 then
   Help1NextClick(Self);

   fFilesInfo[i].ID:=ID;
   fFilesInfo[i].IsDate:=true;
   fFilesInfo[i].IsTime:=Value.IsTime;
   fFilesInfo[i].Loaded:=true;
   fFilesInfo[i].Links:='';
   fFilesInfo[i].Crypted:=GraphicCrypt.ValidCryptGraphicFile(fFilesInfo[i].FileName);
   if FBitmapImageList[fFilesInfo[i].ImageIndex].Bitmap = nil then
   begin
    bit := TBitmap.Create;
    bit.PixelFormat:=pf24bit;
    bit.Assign(Value.JPEGImage);

    if FBitmapImageList[fFilesInfo[i].ImageIndex].IsBitmap then
    FBitmapImageList[fFilesInfo[i].ImageIndex].Bitmap.Free;

    FBitmapImageList[fFilesInfo[i].ImageIndex].IsBitmap:=true;
    FBitmapImageList[fFilesInfo[i].ImageIndex].Bitmap:=bit;
   end;
   ElvMain.Refresh;
   break;
  end;
  exit;
 end;
 if EventID_Param_CopyPaste in params then
 begin
  VerifyPaste(self);
  exit;
 end;
 ImParams:=[EventID_Param_Image,EventID_Param_Delete,EventID_Param_Critical,EventID_Param_Crypt];
 If ImParams*params<>[] then
 begin
  RefreshItemByID(ID);
 end;

 UpdateInfoParams:=[EventID_Param_Rotate,EventID_Param_Rating,EventID_Param_Private,EventID_Param_Access,EventID_Param_Date,EventID_Param_Time,EventID_Param_IsDate,EventID_Param_IsTime,EventID_Param_Groups,EventID_Param_Comment, EventID_Param_KeyWords,EventID_Param_Include];
 if UpdateInfoParams*params<>[] then
 if ID<>0 then
 begin
  for i:=0 to fFilesInfo.Count-1 do
  begin
   if fFilesInfo[i].ID=ID then
   begin
    if EventID_Param_Rotate in params then
    begin
     ReRotation:=GetNeededRotation(fFilesInfo[i].Rotate,Value.Rotate);
     fFilesInfo[i].Rotate:=Value.Rotate;
    end;

    if EventID_Param_Private in params then fFilesInfo[i].Access:=Value.Access;
    if EventID_Param_Access in params then fFilesInfo[i].Access:=Value.Access;
    if EventID_Param_Rating in params then fFilesInfo[i].Rating:=Value.Rating;
    if EventID_Param_Date in params then fFilesInfo[i].Date:=Value.Date;
    if EventID_Param_Time in params then fFilesInfo[i].Time:=Value.Time;
    if EventID_Param_IsDate in params then fFilesInfo[i].IsDate:=Value.IsDate;
    if EventID_Param_IsTime in params then fFilesInfo[i].IsTime:=Value.IsTime;
    if EventID_Param_Groups in params then fFilesInfo[i].Groups:=Value.Groups;
    if EventID_Param_Comment in params then fFilesInfo[i].Comment:=Value.Comment;
    if EventID_Param_KeyWords in params then fFilesInfo[i].KeyWords:=Value.KeyWords;
    if EventID_Param_Links in params then fFilesInfo[i].Links:=Value.Links;
    if EventID_Param_Include in params then
    begin
     index:=MenuIndexToItemIndex(i);
     if index<ElvMain.Items.Count-1 then
     if ElvMain.Items[i].Data<>nil then
     Boolean(TDataObject(ElvMain.Items[i].Data).Include):=Value.Include;

     fFilesInfo[i].Include:=Value.Include;

     ElvMain.Items[i].BorderColor := GetListItemBorderColor(TDataObject(ElvMain.Items[i].Data));
     ElvMain.Refresh;
    end;
    break;
   end;
  end;
 end;

 if [EventID_Param_Rotate]*params<>[] then
 begin
  for i:=0 to fFilesInfo.Count-1 do
  begin
   if fFilesInfo[i].ID=ID then
   begin
    index:=MenuIndexToItemIndex(i);
    if ElvMain.Items[index].ImageIndex>-1 then
      ApplyRotate(FBitmapImageList[ElvMain.Items[index].ImageIndex].Bitmap, ReRotation);

   end;
  end;
 end;

 ImParams:=[EventID_Param_Refresh,EventID_Param_Rotate,EventID_Param_Rating,EventID_Param_Private,EventID_Param_Access];
 If ImParams*params<>[] then
 begin
  ElvMain.Refresh;
 end;

 if [EventID_Param_DB_Changed] * params<>[] then
 begin
  FPictureSize:=Dolphin_DB.ThImageSize;
  LoadSizes;
 end;

 If (EventID_Param_Add in params) or (EventID_Param_Name in params) then
 If not (FileExists(Value.NewName) or DirectoryExists(Value.NewName)) and not (FileExists(Value.Name) or DirectoryExists(Value.Name)) then
 RefreshItemByName(Value.Name) else
 RefreshItemByName(Value.NewName);
 if [EventID_Param_DB_Changed,EventID_Param_Refresh_Window] * params<>[] then
 begin
  ElvMain.Selection.ClearAll;
  RefreshLinkClick(RefreshLink);
 end;
end;

procedure TExplorerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ExplorerManager.RemoveExplorer(Self);
  THintManager.Instance.CloseHint;
  Hinttimer.Enabled:=false;
  Release;
end;

procedure TExplorerForm.SelectAll1Click(Sender: TObject);
begin
 ElvMain.Selection.SelectAll;
end;

procedure TExplorerForm.Refresh2Click(Sender: TObject);
begin
 SetNewPathW(GetCurrentPathW,false);
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
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddDirectory(GetCurrentPath,nil)
end;

procedure TExplorerForm.RefreshItem(Number: Integer);
var
  UpdaterInfo : TUpdaterInfo;
  info : TExplorerViewInfo;
  Index : integer;
begin
 Index := ItemIndexToMenuIndex(Number);
 UpdaterInfo.IsUpdater:=false;
 UpdaterInfo.ID:=0;
{ if HelpNo=3 then
 UpdaterInfo.ProcHelpAfterUpdate:=Help1NextClick else   }
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 info.PictureSize:=fPictureSize;
 if fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE then
 TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,StateID);
 if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_EXEFILE) then
 TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FILE,info,self,UpdaterInfo,StateID);
end;

procedure TExplorerForm.RefreshItemA(Number: Integer);
var
  UpdaterInfo : TUpdaterInfo;
  info : TExplorerViewInfo;
  Index : integer;
begin
 Index := ItemIndexToMenuIndex(Number);
 if Index=-1 then exit;
 if Index>fFilesInfo.Count-1 then exit;
 UpdaterInfo.IsUpdater:=false;
 UpdaterInfo.ID:=fFilesInfo[Index].ID;
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 info.PictureSize:=fPictureSize;
 if fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE then
 TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,StateID);
 if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_EXEFILE) then
 TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FILE,info,self,UpdaterInfo,StateID);
end;

procedure TExplorerForm.HistoryChanged(Sender: TObject);
var
  MenuBack, MenuForward : TArMenuItem;
  MenuBackInfo, MenuForwardInfo : TArExplorerPath;
  i : integer;
begin
 TbBack.Enabled:=fHistory.CanBack;
 TbForward.Enabled:=fHistory.CanForward;
 PopupMenuBack.Items.Clear;
 PopupMenuForward.Items.Clear;
 if fHistory.CanBack then
 begin
  SetLength(MenuBackInfo,0);
  MenuBackInfo:=Copy(fHistory.GetBackHistory);
  SetLength(MenuBack,Length(MenuBackInfo));
  For i:=0 to Length(MenuBack)-1 do
  begin
   MenuBack[Length(MenuBack)-1-i]:=TMenuItem.Create(PopupMenuBack.Items);
   if (MenuBackInfo[i].PType=EXPLORER_ITEM_DRIVE) or (MenuBackInfo[i].PType=EXPLORER_ITEM_MYCOMPUTER) or (MenuBackInfo[i].PType=EXPLORER_ITEM_NETWORK) or (MenuBackInfo[i].PType=EXPLORER_ITEM_WORKGROUP) then
   MenuBack[Length(MenuBack)-1-i].Caption:=MenuBackInfo[i].Path else
   MenuBack[Length(MenuBack)-1-i].Caption:=ExtractFileName(MenuBackInfo[i].Path);
   MenuBack[Length(MenuBack)-1-i].Tag:=MenuBackInfo[i].Tag;
   MenuBack[Length(MenuBack)-1-i].OnClick:=JumpHistoryClick;
  end;
  PopupMenuBack.Items.Add(MenuBack);
 end;
 if fHistory.CanForward then
 begin
  SetLength(MenuForwardInfo,0);
  MenuForwardInfo:=Copy(fHistory.GetForwardHistory);
  SetLength(MenuForward,Length(MenuForwardInfo));
  For i:=0 to Length(MenuForward)-1 do
  begin
   MenuForward[i]:=TMenuItem.Create(PopupMenuForward.Items);
   if (MenuForwardInfo[i].PType=EXPLORER_ITEM_DRIVE) or (MenuForwardInfo[i].PType=EXPLORER_ITEM_MYCOMPUTER) or (MenuForwardInfo[i].PType=EXPLORER_ITEM_NETWORK) or (MenuForwardInfo[i].PType=EXPLORER_ITEM_WORKGROUP) then
   MenuForward[i].Caption:=MenuForwardInfo[i].Path else
   MenuForward[i].Caption:=ExtractFileName(MenuForwardInfo[i].Path);
   MenuForward[i].Tag:=MenuForwardInfo[i].Tag;
   MenuForward[i].OnClick:=JumpHistoryClick;
  end;
  PopupMenuForward.Items.add(MenuForward);
 end;
end;

procedure TExplorerForm.SpeedButton1Click(Sender: TObject);
begin
 if fHistory.CanBack then
 SetNewPathW(fHistory.DoBack,false);
end;

procedure TExplorerForm.SpeedButton2Click(Sender: TObject);
begin
 if fHistory.CanForward then
 SetNewPathW(fHistory.DoForward,false)
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

procedure TExplorerForm.Refresh1Click(Sender: TObject);
var
  UpdaterInfo : TUpdaterInfo;
  info : TExplorerViewInfo;
  i, Index : integer;
begin
 UpdaterInfo.IsUpdater:=false;
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 UpdaterInfo.ID:=0;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 info.PictureSize:=fPictureSize;
 For i:=0 to ElvMain.Items.Count-1 do
 if ElvMain.Items[i].Selected then
 begin
  Index := ItemIndexToMenuIndex(i);
  if (fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE) then
  begin
   TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_IMAGE,info,self,UpdaterInfo,StateID);
  end;

  if (fFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) then
  begin
   TExplorerThread.Create(fFilesInfo[Index].FileName,GUIDToString(fFilesInfo[Index].SID),THREAD_TYPE_FOLDER_UPDATE,info,self,UpdaterInfo,StateID);
  end;
 end;
end;

procedure TExplorerForm.RefreshItemByID(ID: Integer);
Var
  i : integer;
  index : Integer;
begin
 for i:=0 to fFilesInfo.Count-1 do
 begin
  if fFilesInfo[i].ID=ID then
  begin
   If AnsiLowerCase(fFilesInfo[i].FileName)=AnsiLowerCase(FSelectedInfo.FileName) then
   begin
    ListView1SelectItem(nil,ListView1Selected,True);
   end;
   Index := MenuIndexToItemIndex(i);
   RefreshItem(Index);
   Break;
  end;
 end;
end;

procedure TExplorerForm.RefreshItemByNameA(Name: String);
Var
  i:integer;
  Index : Integer;
begin
  for I := 0 to fFilesInfo.Count - 1 do
 begin
  if AnsiLowerCase(fFilesInfo[i].FileName)=AnsiLowerCase(Name) then
  begin
   Index := MenuIndexToItemIndex(i);
   If Name=FSelectedInfo.FileName then
   begin
    ListView1SelectItem(nil,ListView1Selected,false);
   end;
   RefreshItemA(Index);
   Break;
  end;
 end;
end;

procedure TExplorerForm.RefreshItemByName(Name: String);
Var
  i:integer;
  Index : Integer;
begin
  for I := 0 to fFilesInfo.Count - 1 do
 begin
  if AnsiLowerCase(fFilesInfo[i].FileName)=AnsiLowerCase(Name) then
  begin
   Index := MenuIndexToItemIndex(i);
   If Name=FSelectedInfo.FileName then
   begin
    ListView1SelectItem(nil,ListView1Selected,false);
   end;
   RefreshItem(Index);
   Break;
  end;
 end;
end;

procedure TExplorerForm.MakeNewFolder1Click(Sender: TObject);
var
  S, FolderName : String;
  n : integer;
begin
 FolderName:=TEXT_MES_NEW_FOLDER;
 S:=GetCurrentPath;
 FormatDir(S);
 n:=1;
 If DirectoryExists(S+FolderName) then
 begin
  Repeat
   Inc(n);
  Until not DirectoryExists(S+FolderName+' ('+inttostr(n)+')');
  FolderName:=FolderName+' ('+inttostr(n)+')';
 end;
 if not CreateDir(S+FolderName) then
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_CREATE_DIRECTORY_F,[S+FolderName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
  Exit;
 end;
 NewFileName:=AnsiLowerCase(S+FolderName);
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

function TExplorerForm.GetCurrentPath: String;
begin
 Result := GetCurrentPathW.Path;
end;

procedure TExplorerForm.SetPath(Path: String);
begin
 If not Self.Visible then
 begin
  SaveWindowPos1.Key:=RegRoot+'Explorer\'+MakeRegPath(Path);
  SaveWindowPos1.SetPosition;
 end;
 fCurrentPath:=Path;
 SetNewPath(Path,false);
end;

procedure TExplorerForm.ShowUpdater1Click(Sender: TObject);
begin
 If UpdaterDB=nil then UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.ShowWindowNow;
end;

procedure TExplorerForm.FormDeactivate(Sender: TObject);
begin
  FDBCanDrag:=false;
  fDBCanDragW:=false;
  HintTimer.Enabled:=False;
end;

Procedure TExplorerForm.Select(Item : TEasyItem; GUID : TGUID);
begin
 if  (Item<>nil) then
 begin
  Item.Selected:=true;
  Item.Focused:=true;
  Item.MakeVisible(emvTop);
 end;
end;

procedure TExplorerForm.ReplaceBitmap(Bitmap: TBitmap; FileGUID: TGUID; Include : boolean; Big : boolean = false);
var
  i, index, c : Integer;
begin
  for I := 0 to fFilesInfo.Count - 1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  index:=MenuIndexToItemIndex(i);
  if (FFilesInfo[i].isBigImage) and (Big=true) //если загружается большая картинка впервые
   then exit;

  if Big then FFilesInfo[i].isBigImage:=true;

  if index>ElvMain.Items.Count-1 then exit;
  c:=ElvMain.Items[index].ImageIndex;
  if ElvMain.Items[index].Data<>nil then
  begin
   Boolean(TDataObject(ElvMain.Items[index].Data).Include):=Include;
  end else
  begin
   ElvMain.Items[index].Data:=TDataObject.Create;
   TDataObject(ElvMain.Items[index].Data).Include:=Include;
  end;
  if c=-1 then
  begin
   FBitmapImageList.AddBitmap(nil);
   FFilesInfo[i].ImageIndex:=FBitmapImageList.Count-1;
   c:=FBitmapImageList.Count-1;
  end;

  FBitmapImageList[c].Graphic := Bitmap;
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
  i, index, c : Integer;
begin
  for I := 0 to fFilesInfo.Count - 1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  index:=MenuIndexToItemIndex(i);
  if index>ElvMain.Items.Count-1 then exit;
  c:=ElvMain.Items[index].ImageIndex;
  if ElvMain.Items[index].Data<>nil then
  begin
   TDataObject(ElvMain.Items[index].Data).Include:=Include;
  end else
  begin
   ElvMain.Items[index].Data:=TDataObject.Create;
   TDataObject(ElvMain.Items[index].Data).Include:=Include;
  end;
  FBitmapImageList[c].Graphic := Icon;
  FBitmapImageList[c].SelfReleased:=true;

  ElvMain.Items[index].Invalidate(False);

  If FFilesInfo[i].FileType=EXPLORER_ITEM_FOLDER then
  If FFilesInfo[i].FileName=FSelectedInfo.FileName then
  If SelCount=1 then
  ListView1SelectItem(nil,ListView1Selected,True);
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

function TExplorerForm.AddItem(FileGUID: TGUID; LockItems : boolean = true) : TEasyItem;
var
  i : integer;
  Data : TDataObject;
begin
  Result := nil;
  for i := FFilesInfo.Count - 1 downto 0 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  if LockItems then
  if ElvMain.Groups[0].Visible then
  if ElvMain.Items.Count=0 then ElvMain.Groups[0].Visible:=false;

  LockDrawIcon:=true;

  Data:=TDataObject.Create;
  Data.Include:=FFilesInfo[i].Include;

  Result:=ElvMain.Items.Add(Data);
  if not Data.Include then
    Result.BorderColor := GetListItemBorderColor(Data);
  Result.Tag:=FFilesInfo[i].FileType;
  Result.ImageIndex:=FFilesInfo[i].ImageIndex;

  If FFilesInfo[i].FileType<>EXPLORER_ITEM_DRIVE then
  Result.Caption:=ExtractFileName(FFilesInfo[i].FileName) else
  Result.Caption:=FFilesInfo[i].FileName;
  if IsEqualGUID(FileGUID, NewFileNameGUID) then
  begin
   Result.Selected:=true;
   Result.Focused:=true;
   ElvMain.EditManager.Enabled:=true;
   Result.Edit;
   NewFileNameGUID:=GetGUID;
  end;
  LockDrawIcon:=false;
  if ElvMain.Groups[0].Visible then
  Result.Invalidate(False);
  Break;
 end;
end;

function TExplorerForm.AddItemW(Caption: string; FileGUID: TGUID) : TEasyItem;
Var
  I : integer;
  Data : TDataObject;
begin
 Result:=Nil;
 for I := 0 to FFilesInfo.Count - 1 do
 if IsEqualGUID(FFilesInfo[i].SID, FileGUID) then
 begin
  if ElvMain.Groups[0].Visible then
  if ElvMain.Items.Count=0 then ElvMain.Groups[0].Visible:=false;

  LockDrawIcon:=true;
  Data:=TDataObject.Create;
  Data.Include:=True;
  Result:=ElvMain.Items.Add(Data);
  if not Data.Include then
    Result.BorderColor := GetListItemBorderColor(Data);
  Result.Tag:=FFilesInfo[i].FileType;

  Result.ImageIndex:=FFilesInfo[i].ImageIndex;
  Result.Caption:=Caption;

  LockDrawIcon:=false;
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
  i : integer;
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

 if Msg.message=256 then
 if msg.wparam=220 then
 if Length(CbPathEdit.Text)>3 then
 begin
  SlashHandled:=true;
  ComboBox1DropDown;
 end;

 if msg.message=512 then
 begin
  FEditHandle:=GetWindow(GetWindow(CbPathEdit.Handle, GW_CHILD), GW_CHILD);
  if FEditHandle=GetWindow(msg.hwnd, GW_CHILD) then
  begin
   if ComboPath<>GetDirectory(CbPathEdit.Text) then
   begin
   AutoCompliteTimer.Enabled:=true;
   ComboPath:=GetDirectory(CbPathEdit.Text);
   end;
  end;
 end;

 if Msg.hwnd = ElvMain.Handle then
 begin
  if UpdatingList then
  begin
   if Msg.message=516 then
   Msg.message:=0;
   If Msg.message=513 then
   begin
    SetLength(fFilesToDrag,0);
    SetLength(FListDragItems,0);
    FDBCanDrag:=false;
    fDBCanDragW:=false;
    Msg.message:=0;
   end;
   If Msg.message=515 then
   Msg.message:=0;
  end;
  if Msg.message=516 then
  begin
   WindowsMenuTickCount:=GetTickCount;
  end;

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
    if Msg.message = 519 then
    begin
     Application.CreateForm(TBigImagesSizeForm, BigImagesSizeForm);
      BigImagesSizeForm.Execute(Self, FPictureSize, BigSizeCallBack);
      Msg.message := 0;
    end;

  end;

  if Msg.message = 256 then
  begin
  WindowsMenuTickCount:=GetTickCount;
  if (Msg.wParam=37) and CtrlKeyDown then SpeedButton1Click(nil);
  if (Msg.wParam=39) and CtrlKeyDown then SpeedButton2Click(nil);
  if (Msg.wParam=38) and CtrlKeyDown then SpeedButton3Click(nil);
  if (Msg.wParam=83) and CtrlKeyDown then
  if ToolButton18.Enabled then ToolButton18Click(nil);
  if (Msg.wParam=116) then SetPath(GetCurrentPath);
 end;

 if Msg.hwnd=ElvMain.Handle then
 if Msg.message=256 then
 begin
  WindowsMenuTickCount:=GetTickCount;

  if (Msg.wParam=93) and CtrlKeyDown then
  begin
   if SelCOunt>0 then
   begin

   end else
   begin
    ListView1ContextPopup(nil,ElvMain.ClientToScreen(Point(ElvMain.Left,ElvMain.Top)),InternalHandled);
   end;

  end;

  //93-context menu button
  if (Msg.wParam = VK_APPS) then
  begin
    ListView1ContextPopup(ElvMain, Point(-1,-1), InternalHandled);
  end;

    if (Msg.wParam = VK_SUBTRACT) then
      ZoomIn;
    if (Msg.wParam = VK_ADD) then
      ZoomOut;

    if (Msg.wParam=113) then If ((FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then begin PmItemPopup.Tag:=ItemIndexToMenuIndex(ListView1Selected.Index); Rename1Click(nil); end;

    if (Msg.wParam=46) and ShiftKeyDown then begin DeleteFiles(False); Exit; end;
    if (Msg.wParam = VK_DELETE) then
      DeleteFiles(True);

    if (Msg.wParam=67) and CtrlKeyDown then Copy3Click(Nil);
    if (Msg.wParam=88) and CtrlKeyDown then Cut3Click(Nil);
    if (Msg.wParam=86) and CtrlKeyDown then Paste3Click(Nil);
    if (Msg.wParam=65) and CtrlKeyDown then SelectAll1Click(nil);
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
  i : integer;
  p_i : pinteger;
begin
  p_i:=@i;
 for i:=0 to ElvMain.Items.Count-1 do
 begin
  if i>ElvMain.Items.Count-1 then break;
  if ElvMain.Items[i].Selected then
  begin
   DeleteItemWithIndex(i);
   p_i^:=i-1;
  end;
 end;
end;

Procedure TExplorerForm.DirectoryChanged(Sender : TObject; SID : TGUID; pInfo: TInfoCallBackDirectoryChangedArray);
Var
  i, k, index : Integer;
  ExplorerViewInfo : TExplorerViewInfo;
  UpdaterInfo : TUpdaterInfo;
  FileName, FOldFileName : String;
begin
 if not FormLoadEnd then exit;
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 if not IsActualState(SID) then Exit;
 For k:=0 to length(pInfo)-1 do
 Case pInfo[k].FAction of
 FILE_ACTION_ADDED:
  begin
   if FolderView then
   if GetExt(pInfo[k].FOldFileName)='LDB' then exit;
   UpdaterInfo.IsUpdater:=true;
   begin
    UpdaterInfo.FileName:=pInfo[k].FNewFileName;
    UpdaterInfo.NewFileItem:= Self.NewFileName=AnsiLowerCase(UpdaterInfo.FileName);
    Self.NewFileName:='';
    ExplorerViewInfo.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
    ExplorerViewInfo.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
    ExplorerViewInfo.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
    ExplorerViewInfo.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
    ExplorerViewInfo.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
    ExplorerViewInfo.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
    ExplorerViewInfo.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
    ExplorerViewInfo.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
    ExplorerViewInfo.View:=ListView;
    ExplorerViewInfo.PictureSize:=fPictureSize;
    TExplorerThread.Create('',SupportedExt,0,ExplorerViewInfo,Self,UpdaterInfo,StateID);
   end;
  end;
 FILE_ACTION_REMOVED:
  begin
   if ElvMain=nil then exit;
   if ElvMain.Items=nil then exit;
   for i:=0 to ElvMain.Items.Count-1 do
   begin
    index:=ItemIndexToMenuIndex(i);
    if index>fFilesInfo.Count-1 then exit;
    FileName:=fFilesInfo[index].FileName;
    FOldFileName:=pInfo[k].FNewFileName;
    If fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER then
    begin
     FormatDir(FileName);
     FormatDir(FOldFileName);
    end;
    If AnsiLowerCase(FileName)=AnsiLowerCase(FOldFileName) then
    begin
     DeleteItemWithIndex(i);
     Break;
    end;
   end;
   Continue;
  end;
 FILE_ACTION_MODIFIED:
  begin
   i:=FileNameToID(pInfo[k].FNewFileName);
   if not UpdatingNow(i) then
   begin
    AddUpdateID(i);
    //if ProcessedFilesCollection.ExistsFile(pInfo[k].FNewFileName)<>nil then
    RefreshItemByNameA(pInfo[k].FNewFileName);
   end;
   Continue;
  end;
 FILE_ACTION_RENAMED_NEW_NAME:
  begin
   if ElvMain=nil then exit;
   if ElvMain.Items=nil then exit;
   for i:=0 to ElvMain.Items.Count-1 do
   begin
    index:=ItemIndexToMenuIndex(i);
    if index>fFilesInfo.Count-1 then exit;
    If AnsiLowerCase(fFilesInfo[index].FileName)=AnsiLowerCase(pInfo[k].FOldFileName) then
    begin
     If (not DirectoryExists(pInfo[k].FOldFileName) and DirectoryExists(pInfo[k].FNewFileName)) or (not FileExists(pInfo[k].FOldFileName) and FileExists(pInfo[k].FNewFileName)) then
     begin
      ElvMain.Items[i].Caption:=ExtractFileName(pInfo[k].FNewFileName);
      fFilesInfo[index].FileName:=pInfo[k].FNewFileName;
      if fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE then
      if not ExtInMask(SupportedExt,GetExt(pInfo[k].FNewFileName)) then
      begin
       fFilesInfo[index].FileType:=EXPLORER_ITEM_FILE;
       fFilesInfo[index].ID:=0;
      end;
      if fFilesInfo[index].FileType=EXPLORER_ITEM_FILE then
      if ExtInMask(SupportedExt,GetExt(pInfo[k].FNewFileName)) then
      begin
       fFilesInfo[index].FileType:=EXPLORER_ITEM_IMAGE;
      end;
      if GetExt(pInfo[k].FOldFileName)<>GetExt(pInfo[k].FNewFileName) then
      RefreshItemA(i);
      if AnsiLowerCase(FSelectedInfo.FileName)=AnsiLowerCase(pInfo[k].FOldFileName) then
      ListView1SelectItem(ElvMain,ListView1Selected,ListView1Selected=nil);
     end else RenamefileWithDB(Self, pInfo[k].FOldFileName,pInfo[k].FNewFileName, fFilesInfo[index].ID,true);
     Continue;
    end;
   end;
  end;
 end;
end;

procedure TExplorerForm.LoadInfoAboutFiles(Info : TExplorerFileInfos);
begin
  fFilesInfo.Assign(Info);
end;

procedure TExplorerForm.AddInfoAboutFile(Info : TExplorerFileInfos);
var
  I : Integer;
begin
  for I := 0 to FFilesInfo.Count - 1 do
    if FFilesInfo[I].FileName = Info[0].FileName then
      Exit;

  FFilesInfo.Add(Info[0].Clone);
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
  I, n : Integer;
begin
  Result := 0;
  n := ElvMain.Items[Index].ImageIndex;
  for I := 0 to fFilesInfo.Count - 1 do
  begin
    if fFilesInfo[I].ImageIndex = n then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TExplorerForm.MenuIndexToItemIndex(Index: Integer): Integer;
Var
  i, n : Integer;
begin
 Result:=0;
 n:=fFilesInfo[Index].ImageIndex;
 For i:=0 to ElvMain.Items.Count-1 do
 begin
  If ElvMain.Items[i].ImageIndex=n then
  begin
   Result:=i;
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
 GlobalLock := false;
end;

procedure TExplorerForm.WaitForUnLock;
begin
 Repeat
  Application.ProcessMessages;
 Until not GlobalLock;
end;

procedure TExplorerForm.SetOldPath(Path: String);
begin
 FOldPatch := Path;
 NotSetOldPath:=false;
end;

procedure TExplorerForm.FormShow(Sender: TObject);
begin
 NotSetOldPath:=false;
 ElvMain.SetFocus;
end;

procedure TExplorerForm.NewWindow1Click(Sender: TObject);
var
  Path : TExplorerPath;
begin
 Path:=ExplorerPath(fFilesInfo[PmItemPopup.tag].FileName,fFilesInfo[PmItemPopup.tag].FileType);
 With Explorermanager.NewExplorer(False) do
 begin
  SetNewPathW(Path,False);
  Show;
 end;
end;

procedure TExplorerForm.Cut1Click(Sender: TObject);
var
  File_List : TStrings;
begin
 File_List:=TStringList.Create;
 File_List.Add(GetCurrentPath);
 Copy_Move(false,File_List);
 File_List.Free;
end;

procedure TExplorerForm.Paste1Click(Sender: TObject);
Var
  Files : TStrings;
  Effects : Integer;
  i : Integer;
  S : Array of String;
//  _AutoRename, _Break : boolean;
begin
 Files:=TStringList.Create;
 LoadFIlesFromClipBoard(Effects,Files);
 if Files.Count=0 then begin Files.Free; exit; end;
 SetLength(S,0);
 For i:=0 to Files.Count-1 do
 begin
  SetLength(S,Length(s)+1);
  S[Length(s)-1]:=Files[i];
 end;

 if Effects= DROPEFFECT_MOVE then
 begin
  CopyFiles(Handle,S,GetCurrentPath,True,False,CorrectPath,self);
  inc(CopyInstances);
  ClipBoard.Clear;
  ToolButton7.Enabled:=false;
 end;
 if (Effects= DROPEFFECT_COPY) or (Effects= DROPEFFECT_COPY+DROPEFFECT_LINK) or (Effects= DROPEFFECT_NONE) then CopyFiles(Handle,S,GetCurrentPath,false,False);

end;

procedure TExplorerForm.PmListPopupPopup(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
begin
 OpeninSearchWindow1.Visible:=True;
 Files:=TStringList.Create;
 LoadFIlesFromClipBoard(Effects,Files);
 if Files.Count<>0 then Paste1.Enabled:=true else Paste1.Enabled:=false;
 Files.free;

 MakeFolderViewer1.Visible:=((GetCurrentPathW.PType=EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType=EXPLORER_ITEM_DRIVE)) and not FolderView;

 if GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER then
 begin
  Paste1.Visible:=false;
  Cut1.Visible:=false;
  Copy2.Visible:=false;
  Addfolder1.Visible:=false;
  MakeNew1.Visible:=false;
  OpeninSearchWindow1.Visible:=false;
 end;
 if (GetCurrentPathW.PType=EXPLORER_ITEM_NETWORK) or (GetCurrentPathW.PType=EXPLORER_ITEM_WORKGROUP) or (GetCurrentPathW.PType=EXPLORER_ITEM_COMPUTER) then
 begin
  Paste1.Visible:=false;
  Cut1.Visible:=false;
  Copy2.Visible:=false;
  Addfolder1.Visible:=false;
  MakeNew1.Visible:=false;
  OpeninSearchWindow1.Visible:=false;
 end;
 if (GetCurrentPathW.PType=EXPLORER_ITEM_SHARE) then
 begin
  Cut1.Visible:=false;
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
 DBkernel.WriteInteger('Explorer','LeftPanelWidthExplorer',MainPanel.Width);
 MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidth',135);
 ListView1SelectItem(Sender, ListView1Selected, False);
end;

procedure TExplorerForm.SetPanelImage(Image: TBitmap; FileGUID: TGUID);
begin
  if IsEqualGUID(FSelectedInfo._GUID, FileGUID) then
  begin
    ImPreview.Picture.Graphic := Image;
  end;
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

procedure TExplorerForm.ImPreviewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
Var
   item: TEasyItem;
begin
 if PopupHandled then
 begin
  PopupHandled:=false;
  exit;
 end;
  If (ListView1Selected=nil) or (SelCount<>1) then exit;
 HintTimer.Enabled:=false;
 Item:=ListView1Selected;
 if Item<>nil then
 begin
  LastMouseItem:= nil;
  Application.HideHint;
  THintManager.Instance.CloseHint;
  PmItemPopup.Tag:=ItemIndexToMenuIndex(Item.Index);
  PmItemPopup.Popup(ImPreview.clienttoscreen(MousePos).X ,ImPreview.clienttoscreen(MousePos).y);
 end else begin
  PmListPopup.Popup(ImPreview.clienttoscreen(MousePos).X ,ImPreview.clienttoscreen(MousePos).y);
 end;
end;

procedure TExplorerForm.PropertyPanelResize(Sender: TObject);
begin
  ReallignInfo;
end;

procedure TExplorerForm.ReallignToolInfo;
begin
 VerifyPaste(self);

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) then
 begin
  if SelCount<>0 then
  ToolButton6.Enabled:=true else
  ToolButton6.Enabled:=false;
 end else
 begin
  ToolButton6.Enabled:=false;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then
 begin
  if SelCount<>0 then
  begin
   ToolButton5.Enabled:=true;
  end else
  begin
   ToolButton5.Enabled:=false;
  end;
 end else
 begin
  ToolButton5.Enabled:=false;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then
 begin
  if SelCount<>0 then
  begin
   ToolButton8.Enabled:=true;
  end else
  begin
   ToolButton8.Enabled:=false;
  end;
 end else
 begin
  ToolButton8.Enabled:=false;
 end;

end;

procedure TExplorerForm.ReallignInfo;
Const
  otstup = 15;
  H = 3;
var
  Index, i : integer;
  b : boolean;
  s : string;
  oldMode: Cardinal;

  function GetShellPath(Name : String) : String;
  var
    Reg: TRegIniFile;
  begin
   Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
   Result:=Reg.ReadString('Shell Folders', Name, '');
   Reg.Free;
  end;

  function ValidLink(index : integer) : boolean;
  var
    Path : String;
  begin
   Path:=AnsiLowerCase(GetCurrentPath);
   Result:=false;
   if FPlaces[index].MyComputer and (GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER) then Result:=true;
   if not Result then
   if FPlaces[index].MyDocuments and (Path=AnsiLowerCase(GetShellPath('Personal'))) then Result:=true;
   if not Result then
   if FPlaces[index].MyPictures and (Path=AnsiLowerCase(GetShellPath('My Pictures'))) then Result:=true;
   if not Result then
   if FPlaces[index].OtherFolder then
   begin
    Result:=true;
    if (GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER) then Result:=false;
    if (Path=AnsiLowerCase(GetShellPath('Personal'))) then Result:=false;
    if (Path=AnsiLowerCase(GetShellPath('My Pictures'))) then Result:=false;
   end;

  end;

begin
 ScrollBox1.Updating:=true;
 IsReallignInfo:=true;
 EventLog('ReallignInfo...');

 VerifyPaste(self);

// SelCount:=SelCount;
 LockWindowUpdate(self.Handle);
 s:=ExtractFileName(FSelectedInfo.FileName)+' ';
 For i:=Length(s) downto 1 do
 if s[i]='&' then Insert('&',S,i);

 NameLabel.Caption:=S;
 NameLabel.Constraints.MaxWidth:=ScrollBox1.Width-ScrollBox1.Left-otstup-ScrollBox1.VertScrollBar.ButtonSize;
 NameLabel.Constraints.MinWidth:=ScrollBox1.Width-ScrollBox1.Left-otstup-ScrollBox1.VertScrollBar.ButtonSize;
 S:=ExtractFileName(FSelectedInfo.FileName);
 For i:=Length(s) downto 1 do
 if s[i]='&' then Insert('&',S,i);
 NameLabel.Caption:=S;
 TypeLabel.Caption:=FSelectedInfo.FileTypeW;
 If FSelectedInfo.FileTypeW<>'' then
 begin
  TypeLabel.Top:=NameLabel.Top+NameLabel.Height+H;
  TypeLabel.Visible:=True;
 end else
 begin
  TypeLabel.Top:=NameLabel.Top;
  TypeLabel.Visible:=False;
 end;

 If Min(FSelectedInfo.Width,FSelectedInfo.Height)=0 then
 begin
  if FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE then
  begin
   oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
   if DiskSize(ord(AnsiLowerCase(FSelectedInfo.FileName)[1])-ord('a')+1)<>-1 then
   begin
    DimensionsLabel.Top:=TypeLabel.Top+TypeLabel.Height+H;
    DimensionsLabel.Visible:=True;
    DimensionsLabel.Caption:=TEXT_MES_FREE_SPACE+':';
   end else
   begin
    DimensionsLabel.Top:=TypeLabel.Top;
    DimensionsLabel.Visible:=False;
   end;
   SetErrorMode(oldMode);
  end else
  begin
   DimensionsLabel.Top:=TypeLabel.Top;
   DimensionsLabel.Visible:=False;
  end;
 end else
 begin
  DimensionsLabel.Top:=TypeLabel.Top+TypeLabel.Height+H;
  DimensionsLabel.Visible:=True;
  DimensionsLabel.Caption:=IntToStr(FSelectedInfo.Width)+'x'+IntToStr(FSelectedInfo.Height);
 end;

 If (FSelectedInfo.Size<>-1) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) then
 begin
  if FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE then
  begin
   oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
   if DiskSize(ord(AnsiLowerCase(FSelectedInfo.FileName)[1])-ord('a')+1)<>-1 then
   begin
    SizeLabel.Caption:=Format(TEXT_MES_SIZE_FORMATB,[SizeInTextA(DiskFree(ord(AnsiLowerCase(FSelectedInfo.FileName)[1])-ord('a')+1)),SizeInTextA(DiskSize(ord(AnsiLowerCase(FSelectedInfo.FileName)[1])-ord('a')+1))]);
    SizeLabel.Visible:=true;
    SizeLabel.Top:=DimensionsLabel.Top+DimensionsLabel.Height+H;
   end else
   begin
    SizeLabel.Visible:=false;
    SizeLabel.Top:=DimensionsLabel.Top;
   end;
   SetErrorMode(oldMode);
  end else
  begin
   SizeLabel.Caption:=Format(TEXT_MES_SIZE_FORMATA,[SizeInTextA(FSelectedInfo.Size)]);
   SizeLabel.Visible:=true;
   SizeLabel.Top:=DimensionsLabel.Top+DimensionsLabel.Height+H;
  end;
 end else
 begin
  SizeLabel.Visible:=false;
  SizeLabel.Top:=DimensionsLabel.Top;
 end;
 If FSelectedInfo.Id<>0 then
 begin
  DBInfoLabel.Top:=SizeLabel.Top+SizeLabel.Height+H;
  IDLabel.Caption:=Format(TEXT_MES_ID_FORMATA,[IntToStr(FSelectedInfo.Id)]);
  IDLabel.Top:=DBInfoLabel.Top+DBInfoLabel.Height+H;
  If FSelectedInfo.Rating<>0 then
  begin
   RatingLabel.Caption:=Format(TEXT_MES_Rating_FORMATA,[IntToStr(FSelectedInfo.Rating)]);
   RatingLabel.Top:=IDLabel.Top+IDLabel.Height+H;
  end else
  begin
   RatingLabel.Top:=IDLabel.Top;
  end;
  If FSelectedInfo.Access=db_access_private then
  begin
   AccessLabel.Caption:=TEXT_MES_REC_PRIVATE;
   AccessLabel.Top:=RatingLabel.Top+RatingLabel.Height+h;
  end else
  begin
   AccessLabel.Top:=RatingLabel.Top;
  end;
  DBInfoLabel.Show;
  IDLabel.Show;
  If FSelectedInfo.Rating<>0 then
  RatingLabel.Show;
  If FSelectedInfo.Access=db_access_private then
  AccessLabel.Show;
 end else
 begin
  AccessLabel.Top:=SizeLabel.Top;
  DBInfoLabel.Hide;
  IDLabel.Hide;
  RatingLabel.Hide;
  AccessLabel.Hide;
 end;
 TasksLabel.Top:=Max(AccessLabel.Top+AccessLabel.Height+h*4,NameLabel.Top+NameLabel.Height+H*4);
 If (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) then
 begin
  SlideShowLink.Visible:=true;
  SlideShowLink.Top:=TasksLabel.Top+TasksLabel.Height+h;
 end else
 begin
  SlideShowLink.Visible:=false;
  SlideShowLink.Top:=TasksLabel.Top;
 end;

 If (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and (SelCount=1)then
 begin
  ImageEditorLink.Visible:=true;
  ImageEditorLink.Top:=SlideShowLink.Top+SlideShowLink.Height+h;
 end else
 begin
  ImageEditorLink.Visible:=false;
  ImageEditorLink.Top:=SlideShowLink.Top;
 end;

 If (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) then
 begin
  PrintLink.Visible:=true;
  PrintLink.Top:=ImageEditorLink.Top+ImageEditorLink.Height+h;
 end else
 begin
  PrintLink.Visible:=false;
  PrintLink.Top:=ImageEditorLink.Top;
 end;


 If (((((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE))) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) And (SelCount=1)) then
 begin
  ShellLink.Visible:=true;
  ShellLink.Top:=PrintLink.Top+PrintLink.Height+h;
 end else
 begin
  ShellLink.Visible:=false;
  ShellLink.Top:=PrintLink.Top;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) then
 begin
  CopyToLink.Visible:=true;
  if SelCount<>0 then
  ToolButton6.Enabled:=true else
  ToolButton6.Enabled:=false;
  CopyToLink.Top:=ShellLink.Top+ShellLink.Height+h;
 end else
 begin
  CopyToLink.Visible:=false;
  ToolButton6.Enabled:=false;
  CopyToLink.Top:=ShellLink.Top;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then
 begin
  if SelCount<>0 then
  begin
   MoveToLink.Top:=CopyToLink.Top+CopyToLink.Height+h;
   MoveToLink.Visible:=true;
   ToolButton5.Enabled:=true;
  end else
  begin
   ToolButton5.Enabled:=false;
   MoveToLink.Top:=CopyToLink.Top;
  end;
 end else
 begin
  MoveToLink.Visible:=false;
  ToolButton5.Enabled:=false;
  MoveToLink.Top:=CopyToLink.Top;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) And (SelCount<>0)  then
 begin
  RenameLink.Visible:=true;
  RenameLink.Top:=MoveToLink.Top+MoveToLink.Height+h;
 end else
 begin
  RenameLink.Visible:=false;
  RenameLink.Top:=MoveToLink.Top;
 end;

 If (((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER)) and (SelCount=1)) or ((SelCount=0) and ((FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER))) or (((FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE)) and (SelCount>1)) then
 begin
  PropertiesLink.Visible:=true;
  PropertiesLink.Top:=RenameLink.Top+RenameLink.Height+h;
 end else
 begin
  PropertiesLink.Visible:=false;
  PropertiesLink.Top:=RenameLink.Top;
 end;

 If ((FSelectedInfo.FileType=EXPLORER_ITEM_EXEFILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE)) then
 begin
  if SelCount<>0 then
  begin
   ToolButton8.Enabled:=true;
   DeleteLink.Visible:=true;
   DeleteLink.Top:=PropertiesLink.Top+PropertiesLink.Height+h;
  end else
  begin
   ToolButton8.Enabled:=false;
   DeleteLink.Visible:=false;
   DeleteLink.Top:=PropertiesLink.Top;
  end;
 end else
 begin
  DeleteLink.Visible:=false;
  ToolButton8.Enabled:=false;
  DeleteLink.Top:=PropertiesLink.Top;
 end;

 if ElvMain.Items.Count<400 then
 begin
  if ((FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE)) and (SelCount=0) then
  begin
   b:=true;
  end else
  begin
   b:=false;
   if fFilesInfo.Count<>0 then
   For i:=0 to ElvMain.Items.Count-1 do
   if ElvMain.Items[i].Selected then
   begin
    Index := ItemIndexToMenuIndex(i);
    if ((fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE) and (fFilesInfo[Index].ID=0)) or ((fFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_DRIVE)) then
    begin
     b:=true;
     break;
    end;
   end;
  end;
 end else
 begin
  b:=((SelCount>1) or ((SelCount=1) and (FSelectedInfo.Id=0)));
  b:=((FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and b);
 end;

 If b then
 begin
  If SelCount=1 then AddLink.Text:=TEXT_MES_ADD_OBJECT;
  If SelCount>1 then AddLink.Text:=TEXT_MES_ADD_OBJECTS;
  if (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (SelCount=0) then
  begin
   AddLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_ADD_FOLDER+1]);
  end;
  if (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) and (SelCount<>0) then
  begin
   AddLink.LoadFromHIcon(UnitDBKernel.icons[DB_IC_ADD_SINGLE_FILE+1]);
  end;
  AddLink.Visible:=true;
  AddLink.Top:=DeleteLink.Top+DeleteLink.Height+h;
 end else
 begin
  AddLink.Visible:=false;
  AddLink.Top:=DeleteLink.Top;
 end;

 If (((FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE)) and (SelCount=0)) or ((SelCount>0) and ((FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE))) then
 begin
  RefreshLink.Visible:=true;
  RefreshLink.Top:=AddLink.Top+AddLink.Height+h;
 end else
 begin
  RefreshLink.Visible:=false;
  RefreshLink.Top:=AddLink.Top;
 end;

 if ((FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER)) and ExplorerManager.ShowQuickLinks and (SelCount<2) then
 begin
  OtherPlacesLabel.Show;
  MyPicturesLink.Show;
  MyDocumentsLink.Show;
  MyComputerLink.Show;
  DesktopLink.Show;

  OtherPlacesLabel.Top:=RefreshLink.Top+RefreshLink.Height+h*4;
  if AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(GetShellPath('My Pictures')) then
  MyPicturesLink.Top:=OtherPlacesLabel.Top+OtherPlacesLabel.Height+h else
  begin
   MyPicturesLink.Visible:=false;
   MyPicturesLink.Top:=RefreshLink.Top+RefreshLink.Height+h*4;
  end;
  if AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(GetShellPath('Personal')) then
  MyDocumentsLink.Top:=MyPicturesLink.Top+MyPicturesLink.Height+h else
  begin
   MyDocumentsLink.Visible:=false;
   MyDocumentsLink.Top:=MyPicturesLink.Top;
  end;
  if AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(GetShellPath('Desktop')) then
  DesktopLink.Top:=MyDocumentsLink.Top+MyDocumentsLink.Height+h else
  begin
   DesktopLink.Visible:=false;
   DesktopLink.Top:=MyDocumentsLink.Top;
  end;
  if GetCurrentPathW.PType<>EXPLORER_ITEM_MYCOMPUTER then
  MyComputerLink.Top:=DesktopLink.Top+DesktopLink.Height+h else
  begin
   MyComputerLink.Visible:=false;
   MyComputerLink.Top:=DesktopLink.Top;
  end;

  for i:=0 to Length(UserLinks)-1 do
  begin
   UserLinks[i].Show;
   if i=0 then
   begin
    if ValidLink(i) then
    UserLinks[i].Top:=MyComputerLink.Top+MyComputerLink.Height+h else
    begin
     UserLinks[i].Visible:=false;
     UserLinks[i].Top:=MyComputerLink.Top;
    end;
   end else
   begin
    if ValidLink(i) then
    UserLinks[i].Top:=UserLinks[i-1].Top+UserLinks[i-1].Height+h else
    begin
     UserLinks[i].Visible:=false;
     UserLinks[i].Top:=UserLinks[i-1].Top;
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
  for i:=0 to Length(UserLinks)-1 do
  UserLinks[i].Hide;
 end;
 IsReallignInfo:=false;

 ScrollBox1.Updating:=false;
 ScrollBox1Reallign(nil);
 ScrollBox1.Realign;

 if HelpNO=2 then
 if FSelectedInfo.Id=0 then
 if FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE then
 if SelCount<3 then
 begin
  Activate;
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_2,Point(0,0),AddLink,Help1NextClick,TEXT_MES_NEXT_HELP,Help1CloseClick);
 end;
 lockwindowupdate(0);
 EventLog('ReallignInfo OK');
end;

procedure TExplorerForm.CopyToLinkClick(Sender: TObject);
var
  EndDir : String;
  i, index : integer;
  S : Array of String;
  DlgCaption : String;
//  _AutoRename, _Break : boolean;
begin
 SetLength(S,0);
 If SelCount<>0 then
 begin
  For i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (fFilesInfo[index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_EXEFILE) then
   begin
    SetLength(S,Length(s)+1);
    S[Length(s)-1]:=fFilesInfo[index].FileName;
   end;
  end;
 end else
 begin
  SetLength(S,1);
  S[0]:=GetCurrentPath;
  UnFormatDir(S[0]);
 end;
 If Length(s)=1 then DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_COPY_ONE,[ExtractFileName(S[0])]) else
 DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_COPY_MANY,[inttostr(Length(s))]);

 EndDir:=UnitDBFileDialogs.DBSelectDir(Handle,DlgCaption,Dolphin_DB.UseSimpleSelectFolderDialog);

 If EndDir<>'' then
 CopyFiles(Self.Handle,S,EndDir,false,False);
end;

procedure TExplorerForm.MoveToLinkClick(Sender: TObject);
var
  EndDir : String;
  i, index : integer;
  S : Array of String;
  DlgCaption : String;
begin
 SetLength(S,0);
 If SelCount<>0 then
 begin
  For i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   SetLength(S,Length(s)+1);
   S[Length(s)-1]:=fFilesInfo[index].FileName;
  end;
 end else
 begin
  SetLength(S,1);
  S[0]:=GetCurrentPath;
  UnFormatDir(S[0]);
 end;
 If Length(s)=1 then DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_MOVE_ONE,[ExtractFileName(S[0])]) else
 DlgCaption:=Format(TEXT_MES_SEL_PLACE_TO_MOVE_MANY,[inttostr(Length(s))]);

 EndDir:=UnitDBFileDialogs.DBSelectDir(Handle,DlgCaption,Dolphin_DB.UseSimpleSelectFolderDialog);
 If EndDir<>'' then
 begin

  CopyFiles(Self.Handle,S,EndDir,True,False,CorrectPath,self);
  inc(CopyInstances);
 end;
end;

procedure TExplorerForm.Paste2Click(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
  i : Integer;
  S : array of String;
begin
 Files:=TStringList.Create;
 LoadFilesFromClipBoard(Effects,Files);
 if Files.Count=0 then begin Files.Free; exit; end;
 SetLength(S,0);
 For i:=0 to Files.Count-1 do
 begin
  SetLength(S,Length(s)+1);
  S[Length(s)-1]:=Files[i];
 end;

 if Effects= DROPEFFECT_MOVE then
 begin
  CopyFiles(Handle,S,fFilesInfo[PmItemPopup.tag].FileName,True,False,CorrectPath,self);
  inc(CopyInstances);
  ClipBoard.Clear;
  ToolButton7.Enabled:=false;
 end;
 if (Effects= DROPEFFECT_COPY) or (Effects= DROPEFFECT_COPY+DROPEFFECT_LINK) or (Effects= DROPEFFECT_NONE) then CopyFiles(Handle,S,fFilesInfo[PmItemPopup.tag].FileName,False,False);
end;

procedure TExplorerForm.ExplorerPanel1Click(Sender: TObject);
var
  s : String;
begin
 if not TreeView.UseShellImages then
 begin
  TreeView.UseShellImages:=true;
  TreeView.ObjectTypes:=[otFolders,otHidden];
  TreeView.Refresh(TreeView.TopItem);
 end;
 PropertyPanel.Hide;
 try
  if GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER then
  TreeView.Path:='C:\';
  if (GetCurrentPathW.PType=EXPLORER_ITEM_FOLDER) or (GetCurrentPathW.PType=EXPLORER_ITEM_DRIVE) or (GetCurrentPathW.PType=EXPLORER_ITEM_COMPUTER) or (GetCurrentPathW.PType=EXPLORER_ITEM_SHARE) then
  begin
   s:=GetCurrentPath;
   if Length(s)=2 then
   FormatDir(s);
   TreeView.Path:=s;
  end;
  If GetCurrentPathW.PType=EXPLORER_ITEM_NETWORK then
  TreeView.Path:='C:\';
  If GetCurrentPathW.PType=EXPLORER_ITEM_WORKGROUP then
  TreeView.Path:='C:\';
 except
 end;
 FIsExplorer:=True;
 CloseButtonPanel.Show;
 MainPanel.Width:=DBKernel.ReadInteger('Explorer','LeftPanelWidthExplorer',135);
end;

{ TManagerExplorer }

procedure TManagerExplorer.LoadEXIF;
begin
 fShowEXIF:=DBKernel.ReadBool('Options','ShowEXIFMarker',false);
end;

procedure TManagerExplorer.AddExplorer(Explorer: TExplorerForm);
begin
  fShowEXIF:=DBKernel.ReadBool('Options','ShowEXIFMarker',false);
  ShowQuickLinks:=DBKernel.ReadBool('Options','ShowOtherPlaces',true);

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
  fShowPrivate:=false;
end;

destructor TManagerExplorer.Destroy;
begin
  FExplorers.Free;
  FForms.Free;
  FSync.Free;
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
  i : Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for i := 0 to FExplorers.Count - 1 do
    If IsEqualGUID(TExplorerForm(FExplorers[i]).StateID, StringToGUID(SID)) then
    begin
      Result := FExplorers[i];
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
  i : integer;
  b : Boolean;
  S : string;
begin
  Result:=TStringList.Create;
  FSync.Enter;
  try
    for i:=0 to FExplorers.Count - 1 do
      Result.Add(TForm(FExplorers[i]).Caption);

    repeat
      b:=False;
      For i:=0 to Result.Count-2 do
      If Comparestr(Result[i],Result[i+1])>0 then
      begin
        S:=Result[i];
        Result[i]:=Result[i+1];
        Result[i+1]:=S;
        b:=True;
      end;
    Until not b;
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
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 if Explorer then
 EventLog('SetNewPath "'+Path+'" <Explorer>') else EventLog('SetNewPath "'+Path+'"');
 s:=Path;
 UnformatDir(s);
 If (AnsiLowerCase(Path)=AnsiLowerCase(MyComputer)) or (Path='') or not DirectoryExists(s) then
 begin
  If length(s)>2 then
  if Copy(s,1,2)='\\' then
  begin
   UnformatDir(s);
   Delete(S,1,2);
   If Pos('\',S)=0 then
   begin
    SetNewPathW(ExplorerPath('\\'+s,EXPLORER_ITEM_COMPUTER),false);
    SetErrorMode(oldMode);
    Exit;
   end;
  end;
  If (AnsiLowerCase(Path)=AnsiLowerCase(MyComputer)) or (Path='') then
  begin
   SetNewPathW(ExplorerPath('',EXPLORER_ITEM_MYCOMPUTER),false);
   SetErrorMode(oldMode);
   Exit;
  end;
  s:=Path;
  UnformatDir(s);
  If DirectoryExists(S) then
  SetNewPathW(ExplorerPath(S,EXPLORER_ITEM_MYCOMPUTER),Explorer) else
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_DIR_NOT_FOUND,[s]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
   SetErrorMode(oldMode);
   Exit;
  end;
 end else
 begin
  s:=Path;
  UnformatDir(s);
  If length(s)>2 then
  if Copy(s,1,2)='\\' then
  begin
   UnformatDir(s);
   Delete(S,1,2);
   If Pos('\',S)<>0 then
   begin
    s1:=s;
    for i:=1 to Length(s1) do
    if s1[i]='\' then
    begin
     delete(s1,i,1);
     break;
    end;
    if Pos('\',S)=0 then
    SetNewPathW(ExplorerPath('\\'+s,EXPLORER_ITEM_SHARE),false) else
    SetNewPathW(ExplorerPath('\\'+s,EXPLORER_ITEM_FOLDER),false);
    SetErrorMode(oldMode);
    Exit;
   end;
  end;
  If (Length(S)=2) then
  begin
   if  (s[2]=':') then
   SetNewPathW(ExplorerPath(Path,EXPLORER_ITEM_DRIVE),Explorer) else
   SetNewPathW(ExplorerPath(Path,EXPLORER_ITEM_FOLDER),Explorer)
  end else SetNewPathW(ExplorerPath(Path,EXPLORER_ITEM_FOLDER),Explorer);
 end;
 SetErrorMode(oldMode);
end;

procedure TExplorerForm.GoToSearchWindow1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.GetAnySearch;
 NewSearch.Show;
 NewSearch.SetFocus;
end;

procedure TExplorerForm.ImPreviewDblClick(Sender: TObject);
Var
  MenuInfo : TDBPopupMenuInfo;
  Info : TRecordsInfo;
begin
 if FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE then
 begin
  MenuInfo:=Self.GetCurrentPopUpMenuInfo(ListView1Selected);
  If Viewer=nil then
  Application.CreateForm(TViewer, Viewer);
  DBPopupMenuInfoToRecordsInfo(MenuInfo,info);
  Viewer.Execute(Sender,info);
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
 If SelCount=0 then Copy2Click(Sender) else
 Copy1Click(Sender);
 DBKernel.DoIDEvent(self,0,[EventID_Param_CopyPaste],EventInfo);
end;

procedure TExplorerForm.Cut3Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 If SelCount=0 then Cut1Click(Sender) else
 Cut2Click(Sender);
 DBKernel.DoIDEvent(self,0,[EventID_Param_CopyPaste],EventInfo);
end;

procedure TExplorerForm.Options1Click(Sender: TObject);
begin
  if OptionsForm=nil then
  Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.show;
end;

procedure TExplorerForm.DBManager1Click(Sender: TObject);
begin
 if ManagerDB=nil then
 Application.CreateForm(TManagerDB,ManagerDB);
 ManagerDB.Show;
end;

procedure TExplorerForm.DeleteLinkClick(Sender: TObject);
Var
  s : TArStrings;
begin
 If SelCount<>0 then
 Delete1Click(Sender) else
 begin
  Setlength(s,1);
  S[0]:=GetCurrentPath;
  UnFormatDir(S[0]);
  uFileUtils.DeleteFiles( Handle, S , True );
 end;
end;

procedure TExplorerForm.PropertiesLinkClick(Sender: TObject);
var
  item: TEasyItem;
  index : integer;
begin
 If SelCount>1 then
 begin
  item:=ListView1Selected;
  if item=nil then exit;
  index:=ItemIndexToMenuIndex(Item.Index);
  PmItemPopup.Tag:=index;
  if index>fFilesInfo.Count-1 then exit;
  if (fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE) or (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (fFilesInfo[index].FileType=EXPLORER_ITEM_FILE) then
  Properties1Click(Sender);
  exit;
 end;
 If SelCount=0 then
 begin
  If FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER then ShowMyComputerProperties(Handle) else
  ShowPropertiesDialog(GetCurrentPath)
 end else
 begin
  If FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER then ShowMyComputerProperties(Handle) else
  begin
   If FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE then
   begin
    If FSelectedInfo.ID=0 then
    PropertyManager.NewFileProperty(FSelectedInfo.FileName).ExecuteFileNoEx(FSelectedInfo.FileName) else
    PropertyManager.NewIDProperty(FSelectedInfo.ID).Execute(FSelectedInfo.ID);
   end else
   begin
    ShowPropertiesDialog(FSelectedInfo.FileName);
   end;
  end;
 end;
end;

procedure TExplorerForm.SlideShowLinkClick(Sender: TObject);
begin
 If SelCount<>0 then
 begin
  PmItemPopup.Tag:=ItemIndexToMenuIndex(ListView1Selected.Index);
  SlideShow1Click(Sender)
 end else
 begin
  if Viewer=nil then Application.CreateForm(TViewer, Viewer);
  Viewer.ShowFolderA(GetCurrentPath,ExplorerManager.ShowPrivate);
 end;
end;

procedure TExplorerForm.InfoPanel1Click(Sender: TObject);
begin
 Button1Click(Sender);
end;

function TExplorerForm.GetThreadsCount: Integer;
begin
 Result:=Self.FReadingFolderNumber;
end;

procedure TExplorerForm.Paste3Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 If SelCount=0 then Paste1Click(Sender) else
 Paste2Click(Sender);
 DBKernel.DoIDEvent(self,0,[EventID_Param_CopyPaste],EventInfo);
end;

procedure TExplorerForm.ShowOnlyCommon1Click(Sender: TObject);
begin
 ExplorerManager.ShowPrivate:=false;
end;

procedure TExplorerForm.ShowPrivate1Click(Sender: TObject);
begin
 ExplorerManager.ShowPrivate:=True;
end;

procedure TExplorerForm.OpeninSearchWindow1Click(Sender: TObject);
var
  NewSearch : TSearchForm;
begin
 NewSearch:=SearchManager.NewSearch;
 NewSearch.SearchEdit.Text:=':Folder('+GetCurrentPath+'):';
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
    OpeninSearchWindow1.Caption := L('Open in serach window');
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

    ToolButton5.Caption := L('Cut');
    ToolButton6.Caption := L('Copy');
    ToolButton7.Caption := L('Paste');
    ToolButton19.Caption := L('Options');
    TbBack.Hint := L('Back');
    TbForward.Hint := L('Forward');
    ToolButton3.Hint := L('Go to');
    ToolButton5.Hint := L('Cut');
    ToolButton6.Hint := L('Copy');
    ToolButton7.Hint := L('Paste');
    ToolButton8.Hint := L('Delete');
    ToolButtonView.Hint := L('View');
    ToolButton13.Hint := L('Zoom in');
    ToolButton14.Hint := L('Zoom out');
    ToolButton15.Hint := L('Go to search window');
    ToolButton18.Hint := L('Stop');
    ToolButton19.Hint := L('Options');
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
  TempFolderName:=TreeView.SelectedFolder.PathName;
  OpeninExplorer1.Visible:=DirectoryExists(TempFolderName);
  AddFolder2.Visible:=OpeninExplorer1.Visible ;
  View2.Visible:=OpeninExplorer1.Visible;
 end else
 begin
  TempFolderName:='';
  OpeninExplorer1.Visible:=false;
  AddFolder2.Visible:=false;
  View2.Visible:=false;
 end;
end;

procedure TExplorerForm.OpeninExplorer1Click(Sender: TObject);
begin
 With ExplorerManager.NewExplorer(False) do
 begin
  SetPath(Self.TempFolderName);
  Show;
  SetFocus;
 end;
end;

procedure TExplorerForm.AddFolder2Click(Sender: TObject);
begin
 If UpdaterDB=nil then
 UpdaterDB:=TUpdaterDB.Create;
 UpdaterDB.AddDirectory(TempFolderName,nil);
end;

procedure TExplorerForm.AddLinkClick(Sender: TObject);
begin
 AddFile1Click(Sender);
end;

procedure TExplorerForm.ScrollBox1Resize(Sender: TObject);
begin
 ScrollBox1.BackgroundLeft:=ScrollBox1.Width-ScrollBox1.BackGround.Width-3;
 ScrollBox1.BackgroundTop:=ScrollBox1.Height-ScrollBox1.BackGround.Height-3;


 if ScrollBox1.VertScrollBar.Visible then
 begin
//  MainPanel.Width:=117+GetSystemMetrics(SM_CYHSCROLL);
//  ScrollBox1.VertScrollBar.Visible:=true;
 end;
end;

procedure TExplorerForm.SetNewPathW(WPath: TExplorerPath;
  Explorer: Boolean; FileMask : string = '');
var
  info : TExplorerViewInfo;
  OldDir, S, Path : String;
  UpdaterInfo : TUpdaterInfo;
  i, ThreadType : integer;
begin
 SetLength(RefreshIDList,0);
 UpdaterInfo.ProcHelpAfterUpdate:=nil;
 EventLog('SetNewPathW "'+WPath.Path+'"');
 fDBCanDragW:=false;
 FDBCanDrag:=false;
 OldDir:=GetCurrentPath;
 Path:=WPath.Path;
 ThreadType:=THREAD_TYPE_FOLDER;
 if Length(Path)>2 then
 for i:=Length(Path) downto 3 do
 if Path[i]='/' then Delete(Path,i,1);
 if Length(Path)>2 then
 for i:=Length(Path) downto 3 do
 if (Path[i]='\') and (Path[i-1]='\') then Delete(Path,i,1);
 UnFormatDir(Path);
 if Length(Path)>1 then
 if ((Path[1]='\') and (Path[2]<>'\')) then
 begin
  Path:=GetcurrentDir+Path;
  WPath.PType:=EXPLORER_ITEM_FOLDER;
 end;
 if Path='\' then
 begin
  Path:=GetcurrentDir;
  WPath.PType:=EXPLORER_ITEM_FOLDER;
 end;
 if WPath.PType<>EXPLORER_ITEM_MYCOMPUTER then
 Path:=LongFileName(Path);
 If WPath.PType=EXPLORER_ITEM_MYCOMPUTER then
 begin

  Caption:=MyComputer;

  CbPathEdit.text:=MyComputer;
  ThreadType:=THREAD_TYPE_MY_COMPUTER;
 end;
 If (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 begin
  S:=Path;
  UnFormatDir(s);

  Caption:=S;
  CbPathEdit.text:=Path;
 end;
 If WPath.PType=EXPLORER_ITEM_NETWORK then
 begin

  Caption:=Path;
  CbPathEdit.text:=Path;
  ThreadType:=THREAD_TYPE_NETWORK;
 end;
 If WPath.PType=EXPLORER_ITEM_WORKGROUP then
 begin
  Caption:=Path;
  CbPathEdit.text:=Path;
  ThreadType:=THREAD_TYPE_WORKGROUP;
 end;
 If WPath.PType=EXPLORER_ITEM_COMPUTER then
 begin
  Caption:=Path;
  CbPathEdit.text:=Path;
  ThreadType:=THREAD_TYPE_COMPUTER;
 end;
 S := Path;
 NewFormState;
 if ElvMain<>nil then
 begin
  fCurrentPath:=Path;
  fCurrentTypePath:=WPath.PType;
  ListView1SelectItem(Nil,Nil,False);
  if (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) then
  Formatdir(S);
  If (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_SHARE) then
  begin
   EventLog('ExplorerThreadNotifyDirectoryChange');
   DirectoryWatcher.StopWatch;
   DirectoryWatcher.Start(s,self,StateID);
   //? xxx TExplorerThreadNotifyDirectoryChange.Create(False,Self,s,DirectoryChanged,CurrentGUID,@CurrentGUID);
  end else
  If (WPath.PType=EXPLORER_ITEM_MYCOMPUTER) then
  s:=MyComputer;
 end;
 if FChangeHistoryOnChPath then
 If (fHistory.LastPath.Path<>S) or (fHistory.LastPath.PType<>WPath.PType) then
 fHistory.add(ExplorerPath(S,WPath.PType));
 FChangeHistoryOnChPath:=true;
 If (WPath.PType=EXPLORER_ITEM_MYCOMPUTER){ or not DirectoryExists(GetCurrentPath)} then
 ToolButton3.Enabled:=false else
 ToolButton3.Enabled:=True;
 ToolButton3.Enabled:=ToolButton3.Enabled;
 fFilesInfo.Clear;
 try
  SelectTimer.Enabled:=false;

  if ElvMain<>nil then
  begin
   ClearList;
   ElvMain.Groups.Add;
  end;

  DoSelectItem;
  FBitmapImageList.Clear;
 except
 end;
 Info.OldFolderName:=FOldPatch;
 info.ShowPrivate:=ExplorerManager.ShowPrivate;
 Info.PictureSize:=fPictureSize;

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
  Inc(FReadingFolderNumber);

 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 EventLog('ExplorerThread');
 if ElvMain<>nil then
 begin
  ToolButton18.Enabled:=true;
  TExplorerThread.Create(Path,FileMask,ThreadType,info,self,UpdaterInfo,StateID);
 end;
 if FIsExplorer then
 if not Explorer then
 if (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_COMPUTER) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 try
  s:=GetCurrentPath;
  if Length(s)=2 then FormatDir(S);
  TreeView.Path:=s;
  TreeView.Select(TreeView.Selected);// Scroll(ShellTreeView1.Selected.Left,ShellTreeView1.Selected.Top);
 except
 end;
 DropFileTarget1.Unregister;
 if (WPath.PType=EXPLORER_ITEM_FOLDER) or (WPath.PType=EXPLORER_ITEM_DRIVE) or (WPath.PType=EXPLORER_ITEM_SHARE) then
 DropFileTarget1.Register(ElvMain);

 if not NotSetOldPath then
 begin
  FOldPatch:=Path;
  FOldPatchType:=WPath.PType;
 end;

 if FileMask<>'' then Caption:=Caption+' ['+FileMask+']';
 EventLog('SetPath OK');
end;

function TExplorerForm.GetCurrentPathW: TExplorerPath;
begin
 Result.Path:=fCurrentPath;
 Result.PType:=fCurrentTypePath;
end;

procedure TExplorerForm.RefreshLinkClick(Sender: TObject);
begin
 if (SelCount=0) or (GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER) then
 Refresh2Click(Sender) else Refresh1Click(Sender);
end;

procedure TExplorerForm.DoBack;
begin
 if fHistory.CanBack then
 SetNewPathW(fHistory.DoBack,false) else
 SetNewPathW(ExplorerPath('',EXPLORER_ITEM_MYCOMPUTER),false);
end;

procedure TExplorerForm.JumpHistoryClick(Sender: TObject);
var
  n : integer;
begin
 n:=(Sender as TMenuItem).Tag;
 FChangeHistoryOnChPath:=False;
 fHistory.Position:=n;
 HistoryChanged(Sender);
 SetNewPathW(fHistory[n],false);
end;

procedure TExplorerForm.DragTimerTimer(Sender: TObject);
var
  ListItem: TEasyItem;
  p : TPoint;
  Index : Integer;
  smintL,smintR  : SmallInt;

  function ValidItem(item : TEasyItem) : Boolean;
  var
    i : integer;
  begin
   Result:=true;
   For i:=0 to Length(FListDragItems)-1 do
   if FListDragItems[i]=item then
   begin
    Result:=false;
    Break;
   end;
  end;

begin
 smintL:=GetAsyncKeystate(VK_LBUTTON);
 smintR:=GetAsyncKeystate(VK_RBUTTON);

 if not (smintL<>0) and not (smintR<>0) then
 begin
  FDBCanDrag:=false;
  fDBCanDragW:=false;
  exit;
 end;
 if (FDBCanDrag or fDBCanDragW) and not rdown then
 if (smintL<>0) or (smintR<>0) then
 if (SelfDraging or outdrag) then
 begin

  GetCursorPos(p);
  p:=ElvMain.ScreenToClient(p);
  ListItem:=ItemAtPos(p.x,p.y);
  if ListView1Selected=ListItem then
  begin
   if ListView1Selected<>nil then
   begin
    Index := ItemIndexToMenuIndex(ListItem.Index);
    if not ((FFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[index].FileType=EXPLORER_ITEM_SHARE) or (GetExt(FFilesInfo[index].FileName)='EXE')) then
      SetSelected(nil)
   end else
   begin
    SetSelected(nil);
    ItemsDeselected:=true;
   end;
   exit;
  end;
  If ListItem<>nil then
  begin
   Index := ItemIndexToMenuIndex(ListItem.Index);
   if ListView1Selected<>nil then
   ListView1Selected.Selected:=false;
   if ((FFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[index].FileType=EXPLORER_ITEM_SHARE) or (GetExt(FFilesInfo[index].FileName)='EXE')) and ValidItem(ListItem) then
   begin
    SetSelected(ListItem);
    ListView1Selected.Selected:=true;
   end else SetSelected(nil);
  end else SetSelected(nil);
 end;
 if ListView1Selected=nil then ItemsDeselected:=true;
end;

procedure TExplorerForm.DragEnter(Sender: TObject);
begin
 fDBCanDragW:=True;
end;

procedure TExplorerForm.DragLeave(Sender: TObject);
begin
 fDBCanDragW:=false;
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
 i, index : integer;
 Options : TCryptImageThreadOptions;
 ItemFileNames : TArStrings;
 ItemIDs : TArInteger;
 ItemSelected : TArBoolean;
 Password : string;
begin
 Password:=DBKernel.FindPasswordForCryptImageFile(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName));
 if Password='' then
 Password:=GetImagePasswordFromUser(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName));

 Setlength(ItemFileNames,fFilesInfo.Count);
 Setlength(ItemIDs,fFilesInfo.Count);
 Setlength(ItemSelected,fFilesInfo.Count);

 //be default unchecked
 for i:=0 to fFilesInfo.Count-1 do
   ItemSelected[i] := False;

 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  ItemFileNames[index]:=ProcessPath(fFilesInfo[index].FileName);
  ItemIDs[index]:=fFilesInfo[index].ID;
  ItemSelected[index]:=true;
 end;
 Options.Files := Copy(ItemFileNames);
 Options.IDs := Copy(ItemIDs);
 Options.Selected := Copy(ItemSelected);
 Options.Action:=ACTION_DECRYPT_IMAGES;
 Options.Password:=Password;
 Options.CryptOptions:=0;
 TCryptingImagesThread.Create(Options);

end;

procedure TExplorerForm.CryptFile1Click(Sender: TObject);
var
 I, index : integer;
 Options : TCryptImageThreadOptions;
 Opt : TCryptImageOptions;
 CryptOptions : integer;
 ItemFileNames : TArStrings;
 ItemIDs : TArInteger;
 ItemSelected : TArBoolean;

begin
 Opt:=GetPassForCryptImageFile(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName));
 if Opt.SaveFileCRC then CryptOptions:=CRYPT_OPTIONS_SAVE_CRC else CryptOptions:=CRYPT_OPTIONS_NORMAL;
 if Opt.Password='' then exit;

 Setlength(ItemFileNames,fFilesInfo.Count);
 Setlength(ItemIDs,fFilesInfo.Count);
 Setlength(ItemSelected,fFilesInfo.Count);

  //be default unchecked
  for I:=0 to fFilesInfo.Count-1 do
   ItemSelected[I] := False;

 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  ItemFileNames[index]:=ProcessPath(fFilesInfo[index].FileName);
  ItemIDs[index]:=fFilesInfo[index].ID;
  ItemSelected[index]:=true;
 end;
 Options.Files := Copy(ItemFileNames);
 Options.IDs := Copy(ItemIDs);
 Options.Selected := Copy(ItemSelected);
 Options.Action:=ACTION_CRYPT_IMAGES;
 Options.Password:=Opt.Password;
 Options.CryptOptions:=CryptOptions;
 TCryptingImagesThread.Create(Options);
end;

procedure TExplorerForm.Addsessionpassword1Click(Sender: TObject);
begin
  AddSessionPassword;
end;

procedure TExplorerForm.EnterPassword1Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
 if fFilesInfo[PmItemPopup.tag].ID<>0 then
 begin
  EventInfo.Image:=nil;
  if GetImagePasswordFromUser(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName))<>'' then
  DBKernel.DoIDEvent(Sender,fFilesInfo[PmItemPopup.tag].ID,[EventID_Param_Image],EventInfo);
 end else
 begin
  if GetImagePasswordFromUser(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName))<>'' then
  RefreshItemByName(ProcessPath(fFilesInfo[PmItemPopup.tag].FileName));
 end;
end;

procedure TExplorerForm.Resize1Click(Sender: TObject);
var
  I, Index: Integer;
  List: TDBPopupMenuInfo;
  ImageInfo: TDBPopupMenuInfoRecord;
begin
  List := TDBPopupMenuInfo.Create;
  try
    for I := 0 to ElvMain.Items.Count - 1 do
      if ElvMain.Items[I].Selected then
      begin
        Index := ItemIndexToMenuIndex(I);
        ImageInfo := TDBPopupMenuInfoRecord.CreateFromExplorerInfo(FFilesInfo[Index]);
        List.Add(ImageInfo);
      end;
    ResizeImages(List);
  finally
    List.Free;
  end;
end;

procedure TExplorerForm.Convert1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
 end;
 ConvertImages(ImageList,IDList);
end;

procedure TExplorerForm.Stretch1Click(Sender: TObject);
var
  FileName : string;
begin
 FileName:=fFilesInfo[PmItemPopup.tag].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_STRETCH) else
 MessageBoxDB(Handle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);
end;

procedure TExplorerForm.Center1Click(Sender: TObject);
var
  FileName : string;
begin
 FileName:=fFilesInfo[PmItemPopup.tag].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_CENTER) else
 MessageBoxDB(Handle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);

end;

procedure TExplorerForm.Tile1Click(Sender: TObject);
var
  FileName : string;
begin
 FileName:=fFilesInfo[PmItemPopup.tag].FileName;
 if StaticPath(FileName) then
 SetDesktopWallpaper(FileName,WPSTYLE_TILE) else
 MessageBoxDB(Handle,TEXT_MES_CANNOT_USE_CD_IMAGE_FOR_THIS_OPERATION_PLEASE_COPY_IT_OR_USE_DIFFERENT_IMAGE,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_WARNING);

end;

procedure TExplorerForm.RotateCCW1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATE_270);
end;


procedure TExplorerForm.RotateCW1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATE_90);
end;

procedure TExplorerForm.Rotateon1801Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 RotateImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATE_180);
end;

procedure TExplorerForm.RefreshID1Click(Sender: TObject);
var
  Options : TRefreshIDRecordThreadOptions;
  ItemFileNames : TArStrings;
  ItemIDs : TArInteger;
  ItemSelected : TArBoolean;
  I, index : integer;
begin
 Setlength(ItemFileNames,fFilesInfo.Count);
 Setlength(ItemIDs,fFilesInfo.Count);
 Setlength(ItemSelected,fFilesInfo.Count);

 //be default unchecked
  for I := 0 to fFilesInfo.Count - 1 do
  ItemSelected[I] := False;

 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  ItemFileNames[index]:=fFilesInfo[index].FileName;
  ItemIDs[index]:=fFilesInfo[index].ID;
  ItemSelected[index]:=true;
 end;

 Options.Files := Copy(ItemFileNames);
 Options.IDs := Copy(ItemIDs);
 Options.Selected := Copy(ItemSelected);
 TRefreshDBRecordsThread.Create(false,Options);

end;

procedure TExplorerForm.DropFileTarget1Drop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
var
  S : array of string;
  i, j, index : Integer;
  si : TStartupInfo;
  p  : TProcessInformation;
  Str, Params : String;
  DropInfo : TStrings;
  Pnt : TPoint;
//  _AutoRename, _Break : boolean;
begin
 outdrag:=false;
 DropInfo:= TStringList.Create;
 DropFileTarget1.Files.AssignTo(DropInfo);

 if ssRight in LastShift then
 begin
  Move1.Visible:=not SelfDraging;
  fDBCanDragW:=false;
  FDBCanDrag:=false;
  LastListViewSelCount := SelCount;
  LastListViewSelected := ListView1Selected;
  DragFilesPopup.Assign(DropInfo);
  GetCursorPos(Pnt);
  PopupMenu4.Popup(Pnt.X,Pnt.Y);
 end;

 if not (ssRight in LastShift) then
 begin
  if not SelfDraging and (Selcount=0) then
  begin
   fDBCanDragW:=false;
   SetLength(S,DropInfo.Count);
   for i:=1 to DropInfo.Count do
   S[i-1]:=DropInfo[i-1];



   if not ShiftKeyDown then
   CopyFiles(Handle,S,GetCurrentPath,false,False) else
   begin
    CopyFiles(Handle,S,GetCurrentPath,true,False,CorrectPath,self);
    inc(CopyInstances);
   end;
  end;
  if Selcount=1 then
  if ListView1Selected<>nil then
  begin
   fDBCanDragW:=false;
   index:=ItemIndexToMenuIndex(ListView1Selected.Index);
   if (FFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[index].FileType=EXPLORER_ITEM_SHARE) then
   begin
    Str:=FFilesInfo[index].FileName;
    UnFormatDir(Str);
    SetLength(S,DropInfo.Count);
    for i:=1 to DropInfo.Count do
    S[i-1]:=DropInfo[i-1];
    for j:=0 to Length(s)-1 do
    for i:=Length(S[j]) downto 1 do
    if S[j,i]=#0 then
    Delete(S[j],i,1);


    if not ShiftKeyDown then
    CopyFiles(Handle,S,Str,ShiftKeyDown,False) else
    begin
     CopyFiles(Handle,S,Str,ShiftKeyDown,False,CorrectPath,self);
     inc(CopyInstances);
    end;

   end;
  end;
  if SelCount=1 then
  if ListView1Selected<>nil then
  begin
   index:=ItemIndexToMenuIndex(ListView1Selected.Index);
   if (GetExt(FFilesInfo[index].FileName)='EXE') then
   begin
    fDBCanDragW:=false;
    Str:=GetDirectory(FFilesInfo[index].FileName);
    UnformatDir(Str);
    FillChar( Si, SizeOf( Si ) , 0 );
    with Si do begin
     cb := SizeOf( Si);
     dwFlags := startf_UseShowWindow;
     wShowWindow := 4;
    end;
    Params:='';
    For i:=0 to DropInfo.Count-1 do
    Params:=' "'+DropInfo[i]+'" ';
    CreateProcess(nil, PWideChar('"'+FFilesInfo[index].FileName+'"'+Params),nil,nil,false,CREATE_DEFAULT_ERROR_MODE,nil,PWideChar(Str),si,p);
   end;
  end;
 end;
 SelfDraging:=false;
end;

procedure TExplorerForm.DropFileTarget1Enter(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
 LastShift:=ShiftState;
 if not SelfDraging then
 outdrag:=true;
 FDBCanDrag:=true;
end;

procedure TExplorerForm.DropFileTarget1Leave(Sender: TObject);
begin
  FDBCanDrag:=false;
  outdrag:=false;
end;

procedure TExplorerForm.GroupManager1Click(Sender: TObject);
begin
 ExecuteGroupManager;
end;

procedure TExplorerForm.GetUpdates1Click(Sender: TObject);
begin
 TInternetUpdate.Create(false,true);
end;

procedure TExplorerForm.SetStringPath(Path: String;
  ChangeTreeView: Boolean);
var
  S, s1, ScriptString : string;
  i : integer;
  fScript : TScript;
  c : integer;
begin
  ScriptString:=Include('scripts\ExplorerSetNewPath.dbini');
  fScript := TScript.Create('');
  try
    fScript.Description:='Set path script';
    SetNamedValueStr(fScript,'$Path',Path);
    ExecuteScript(nil,fScript,ScriptString,c,nil);
    Path:=GetNamedValueString(fScript,'$Path');
  finally
    fScript.Free;
  end;
  if Path=#8 then
    exit;

 s:=Path;
  If (s='') or (AnsiLowerCase(s)=AnsiLowerCase(MyComputer)) then
  begin
   CbPathEdit.text:=MyComputer;
   SetNewPath(s,ChangeTreeView);
   Exit;
  end;
  If (AnsiLowerCase(s)=AnsiLowerCase(TEXT_MES_NETWORK)) then
  begin
   CbPathEdit.text:=TEXT_MES_NETWORK;
   SetNewPathW(ExplorerPath(TEXT_MES_NETWORK,EXPLORER_ITEM_NETWORK),false);
   Exit;
  end;
  If length(s)>2 then
  if Copy(s,1,2)='\\' then
  begin
   UnformatDir(s);
   Delete(S,1,2);
   If Pos('\',S)=0 then
   begin
    SetNewPathW(ExplorerPath('\\'+s,EXPLORER_ITEM_COMPUTER),ChangeTreeView);
    Exit;
   end else
   begin
    s1:=s;
    For i:=1 to Length(s1) do
    if s1[i]='\' then
    begin
     Delete(s1,i,1);
     break;
    end;
    If Pos('\',S1)=0 then
    begin
     SetNewPathW(ExplorerPath('\\'+s,EXPLORER_ITEM_SHARE),ChangeTreeView);
     Exit;
    end;
   end
  end;
  s:=Path;
  FormatDir(S);
  If CheckFileExistsWithMessageEx(s,true) then
  begin
   SetNewPath(s,ChangeTreeView);
   end else
  begin
   s:=Path;
   if CheckFileExistsWithMessageEx(S,true) then
   begin
    if ExtInMask(SupportedExt,GetExt(S)) then
    begin
     If Viewer=nil then
     Application.CreateForm(TViewer,Viewer);
     Viewer.ShowFile(S);
    end else
    ShellExecute(Handle, nil, PWideChar(s), nil, nil, SW_NORMAL);
   end else
   if not ChangeTreeView then
   MessageBoxDB(Handle,Format(TEXT_MES_DIR_NOT_FOUND,[s]),TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_ERROR);
  end;
end;

procedure TExplorerForm.HelpTimerTimer(Sender: TObject);
begin
 if not Active then exit;
 if HelpNO=1 then
 begin
  HelpTimer.Enabled:=false;
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_1,Point(0,0),ElvMain,Help1NextClick,TEXT_MES_NEXT_HELP,Help1CloseClick);
 end;
 if HelpNO=2 then
 begin
  HelpTimer.Enabled:=false;
  DoHelpHintCallBackOnCanClose(TEXT_MES_HELP_HINT,TEXT_MES_HELP_2,Point(0,0),AddLink,Help1NextClick,TEXT_MES_NEXT_HELP,Help1CloseClick);
 end;
 if HelpNO=4 then
 begin
  HelpTimer.Enabled:=false;
  DoHelpHint(TEXT_MES_HELP_HINT,TEXT_MES_HELP_3,Point(0,0),ElvMain);
  HelpNO:=0;
  DBKernel.WriteBool('HelpSystem','CheckRecCount',False);
 end;
end;

procedure TExplorerForm.Help1CloseClick(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose:=ID_OK=MessageBoxDB(Handle,TEXT_MES_CLOSE_HELP,TEXT_MES_CONFIRM,TD_BUTTON_OKCANCEL,TD_ICON_INFORMATION);
 if CanClose then
 begin
  HelpNo:=0;
  DBKernel.WriteBool('HelpSystem','CheckRecCount',False);
 end;
end;

procedure TExplorerForm.Help1NextClick(Sender: TObject);
begin
 if HelpNo=4 then exit;
 HelpNo:=HelpNo+1;
 if HelpNO=4 then
 HelpTimer.Enabled:=true;
end;

procedure TExplorerForm.MyPicturesLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
 SetStringPath(Reg.ReadString('Shell Folders', 'My Pictures', ''),false);
 Reg.Free;
end;

procedure TExplorerForm.MyDocumentsLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
 SetStringPath(Reg.ReadString('Shell Folders', 'Personal', ''),false);
 Reg.Free;
end;

procedure TExplorerForm.MyComputerLinkClick(Sender: TObject);
begin
 SetStringPath('',false);
end;

procedure TExplorerForm.DesktopLinkClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
 Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
 SetStringPath(Reg.ReadString('Shell Folders', 'Desktop', ''),false);
 Reg.Free;
end;

procedure TExplorerForm.ImageEditor1Click(Sender: TObject);
begin
 With EditorsManager.NewEditor do
 begin
  Show;
  CloseOnFailture:=false;
 end;
end;

procedure TExplorerForm.ImageEditor2Click(Sender: TObject);
var
  i, index : integer;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  With EditorsManager.NewEditor do
  begin
   Application.ProcessMessages;
   Show;
   Application.ProcessMessages;
   OpenFileName(fFilesInfo[index].FileName);
  end;
  break;
 end;
end;

procedure TExplorerForm.ImageEditorLinkClick(Sender: TObject);
var
  item: TEasyItem;
begin
 item:=ListView1Selected;
 if item<>nil then
 begin
   With EditorsManager.NewEditor do
  begin
   Show;
   OpenFileName(fFilesInfo[ItemIndexToMenuIndex(item.Index)].FileName);
  end;
 end;
end;

procedure TExplorerForm.ExportImages1Click(Sender: TObject);
var
  i, index : integer;
  ImageList : TArStrings;
  IDList, RotateList : TArInteger;
begin
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  SetLength(ImageList,Length(ImageList)+1);
  ImageList[Length(ImageList)-1]:=ProcessPath(fFilesInfo[index].FileName);
  SetLength(IDList,Length(IDList)+1);
  IDList[Length(IDList)-1]:=fFilesInfo[index].ID;
  SetLength(RotateList,Length(RotateList)+1);
  RotateList[Length(RotateList)-1]:=fFilesInfo[index].Rotate;
 end;
 ExportImages(ImageList,IDList,RotateList,DB_IMAGE_ROTATE_90);
end;

procedure TExplorerForm.PrintLinkClick(Sender: TObject);
var
  i, index : integer;
  Files : TStrings;
begin
 Files := TStringList.Create;
 for i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  if fFilesInfo[index].FileType=EXPLORER_ITEM_IMAGE then
  Files.Add(fFilesInfo[index].FileName)
 end;
 GetPrintForm(Files);
 Files.Free;
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
 PopupMenu3.Tag:=Integer(Sender);
 PopupMenu3.Popup(P.X,P.Y);
end;

procedure TExplorerForm.Open2Click(Sender: TObject);
begin
 TWebLink(PopupMenu3.Tag).OnClick(TWebLink(PopupMenu3.Tag));
end;

procedure TExplorerForm.OpeninNewWindow2Click(Sender: TObject);
var
  Reg: TRegIniFile;
  Link : TWebLink;
  S : String;
  DefLink : boolean;
  i : integer;
begin
 Link:=TWebLink(PopupMenu3.Tag);
 DefLink:=true;
 for i:=0 to Length(UserLinks)-1 do
 if Link=UserLinks[i] then
 begin
  DefLink:=false;
  break;
 end;
 if not DefLink then
 begin
  S:=FPlaces[Link.Tag].FolderName;
 end else
 begin
  Reg := TRegIniFile.Create(SHELL_FOLDERS_ROOT);
  if Link=MyPicturesLink then S:=Reg.ReadString('Shell Folders', 'My Pictures', '');
  if Link=MyDocumentsLink then S:=Reg.ReadString('Shell Folders', 'Personal', '');
  if Link=DesktopLink then S:=Reg.ReadString('Shell Folders', 'Desktop', '');
  if Link=MyComputerLink then S:='';
  Reg.Free;
 end;
 With ExplorerManager.NewExplorer(False) do
 begin
  SetPath(S);
  Show;
  SetFocus;
 end;
end;

procedure TExplorerForm.TextFile2Click(Sender: TObject);
var
  S, FileName : String;
  n : integer;
  F : TextFile;
begin
 FileName:=TEXT_MES_MAKE_NEW_TEXT_FILE+'.txt';
 S:=GetCurrentPath;
 FormatDir(S);
 n:=1;
 If FileExists(S+FileName) then
 begin
  Repeat
   Inc(n);
  Until not FileExists(S+TEXT_MES_MAKE_NEW_TEXT_FILE+' ('+inttostr(n)+').txt');
  FileName:=S+TEXT_MES_MAKE_NEW_TEXT_FILE+' ('+inttostr(n)+').txt';
 end else FileName:=S+FileName;
 System.Assign(F,FileName);
 {$I-}
 System.Rewrite(F);
 {$I-}
 if IOResult<>0 then
 begin
  if not FileExists(FileName) then
  begin
   MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_CREATE_FILE_F,[FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
   Exit;
  end else
  begin
   System.Close(F);
  end;
 end else System.Close(F);
 NewFileName:=AnsiLowerCase(FileName);
end;

procedure TExplorerForm.GetPhotosClick(Sender: TObject);
var
  Item : TMenuItem;
begin
 Item:=(Sender as TMenuItem);
 GetPhotosFromDrive(Char(Item.Tag));
end;

procedure TExplorerForm.GetPhotosFromDrive1Click(Sender: TObject);
var
  i : integer;
  Icon : TIcon;
  oldMode: Cardinal;
begin
 oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 for i:=1 to FExtImagesInImageList do
 DBKernel.ImageList.Delete(IconsCount);
 FExtImagesInImageList:=0;
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_CDROM) then
 begin
  Icon:=TIcon.Create;
  Icon.Handle:=ExtractAssociatedIcon_(Chr(i)+':\');
  DBKernel.ImageList.AddIcon(icon);
  Icon.Free;
  inc(FExtImagesInImageList);
 end;
 SetErrorMode(oldMode);
end;

procedure TExplorerForm.CopyWithFolder1Click(Sender: TObject);
var
  i, index : integer;
  Files : array of String;
  UpDir, Dir, NewDir, Temp : String;
  l1, l2 : integer;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SELECT_PLACE_TO_COPY,Dolphin_DB.UseSimpleSelectFolderDialog);
 if Dir<>'' then
 begin
  SetLength(Files,0);
  for i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   SetLength(Files,Length(Files)+1);
   Files[Length(Files)-1]:=ProcessPath(fFilesInfo[index].FileName);
  end;
  if Length(Files)>0 then
  begin
   Temp:=GetDirectory(Files[0]);
   UnFormatDir(Temp);
   l1:=Length(Temp);
   Temp:=GetDirectory(Temp);
   FormatDir(Temp);
   l2:=Length(Temp);
   UpDir:=Copy(Files[0],l2+1,l1-l2);
   NewDir:=Dir+UpDir;
   FormatDir(NewDir);
   CreateDirA(NewDir);
   CopyFiles(Handle,Files,NewDir,false,False);
  end;
 end;
end;

procedure TExplorerForm.ReadPlaces;
var
  Reg : TBDRegistry;
  S : TStrings;
  fName, fFolderName, fIcon : string;
  fMyComputer, fMyDocuments, fMyPictures, fOtherFolder : boolean;
  i : integer;
  Ico : TIcon;
begin
 Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
 Reg.OpenKey(GetRegRootKey+'\Places',true);
 S := TStringList.create;
 Reg.GetKeyNames(S);
 for i:=0 to Length(UserLinks)-1 do
 UserLinks[i].Free;
 SetLength(UserLinks,0);
 SetLength(FPlaces,0);
 for i:=0 to S.Count-1 do
 begin
  Reg.CloseKey;
  Reg.OpenKey(GetRegRootKey+'\Places\'+s[i],true);
  fMyComputer:=false;
  fMyDocuments:=false;
  fMyPictures:=false;
  fOtherFolder:=false;
  try
   if Reg.ValueExists('Name') then
   fName:=Reg.ReadString('Name');
   if Reg.ValueExists('FolderName') then
   fFolderName:=Reg.ReadString('FolderName');
   if Reg.ValueExists('Icon') then
   fIcon:=Reg.ReadString('Icon');
   if Reg.ValueExists('MyComputer') then
   fMyComputer:=Reg.ReadBool('MyComputer');
   if Reg.ValueExists('MyDocuments') then
   fMyDocuments:=Reg.ReadBool('MyDocuments');
   if Reg.ValueExists('MyPictures') then
   fMyPictures:=Reg.ReadBool('MyPictures');
   if Reg.ValueExists('OtherFolder') then
   fOtherFolder:=Reg.ReadBool('OtherFolder');
  except
  end;
   if (fName<>'') and (fFolderName<>'') then
   begin
    SetLength(UserLinks,Length(UserLinks)+1);
    UserLinks[Length(UserLinks)-1]:=TWebLink.Create(ScrollBox1);
    UserLinks[Length(UserLinks)-1].Visible:=false;
    UserLinks[Length(UserLinks)-1].Parent:=ScrollBox1;
    UserLinks[Length(UserLinks)-1].Text:=fName;
    UserLinks[Length(UserLinks)-1].Tag:=Length(UserLinks)-1;
    UserLinks[Length(UserLinks)-1].OnClick:=UserDefinedPlaceClick;
    UserLinks[Length(UserLinks)-1].Color:=Theme_MainColor;
    UserLinks[Length(UserLinks)-1].Font.Color:=Theme_MainFontColor;
    UserLinks[Length(UserLinks)-1].EnterBould:=false;
    UserLinks[Length(UserLinks)-1].IconWidth:=16;
    UserLinks[Length(UserLinks)-1].IconHeight:=16;
    UserLinks[Length(UserLinks)-1].Left:=MyPicturesLink.Left;
    UserLinks[Length(UserLinks)-1].OnContextPopup:=UserDefinedPlaceContextPopup;
    SetLength(FPlaces,Length(FPlaces)+1);
    FPlaces[Length(FPlaces)-1].Name:=fName;
    FPlaces[Length(FPlaces)-1].FolderName:=fFolderName;
    FPlaces[Length(FPlaces)-1].Icon:=fIcon;
    FPlaces[Length(FPlaces)-1].MyComputer:=fMyComputer;
    FPlaces[Length(FPlaces)-1].MyDocuments:=fMyDocuments;
    FPlaces[Length(FPlaces)-1].MyPictures:=fMyPictures;
    FPlaces[Length(FPlaces)-1].OtherFolder:=fOtherFolder;
    Ico:= TIcon.Create;
    Ico.Handle := ExtractSmallIconByPath(fIcon,true);
    UserLinks[Length(UserLinks)-1].Icon:=Ico;
   end;
  end;
  S.free;
  Reg.free;
end;

procedure TExplorerForm.UserDefinedPlaceClick(Sender: TObject);
begin
 SetStringPath(FPlaces[(Sender as TWebLink).Tag].FolderName,false);
end;

procedure TExplorerForm.UserDefinedPlaceContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  P : TPoint;
begin
 GetCursorPos(P);
 PopupMenu3.Tag:=Integer(Sender);
 PopupMenu3.Popup(P.X,P.Y);
end;

procedure TExplorerForm.Copy4Click(Sender: TObject);
var
  S : array of string;
  i, j, index : integer;
  Str : string;
begin
 if (LastListViewSelCount=0) then
 begin
  fDBCanDragW:=false;
  SetLength(S,DragFilesPopup.Count);
  for i:=1 to DragFilesPopup.Count do
  S[i-1]:=DragFilesPopup[i-1];


  if not (Sender=Move1) then
  CopyFiles(Handle,S,GetCurrentPath,Sender=Move1,False) else
  begin
   CopyFiles(Handle,S,GetCurrentPath,Sender=Move1,False,CorrectPath,self);
   inc(CopyInstances);
  end;
 end;
 if LastListViewSelCount=1 then
 if LastListViewSelected<>nil then
 begin
  fDBCanDragW:=false;
  index:=ItemIndexToMenuIndex(LastListViewSelected.Index);
  if (FFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) or (FFilesInfo[index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[index].FileType=EXPLORER_ITEM_SHARE) then
  begin
   Str:=FFilesInfo[index].FileName;
   UnFormatDir(Str);
   SetLength(S,DragFilesPopup.Count);
   for i:=1 to DragFilesPopup.Count do
   S[i-1]:=DragFilesPopup[i-1];
   for j:=0 to Length(s)-1 do
   for i:=Length(S[j]) downto 1 do
   if S[j,i]=#0 then
   Delete(S[j],i,1);

   if not (Sender=Move1) then
   CopyFiles(Handle,S,Str,Sender=Move1,False) else
   begin
    CopyFiles(Handle,S,Str,Sender=Move1,False,CorrectPath,self);
    inc(CopyInstances);
   end;
  end;
 end;
end;

procedure TExplorerForm.NewPanel1Click(Sender: TObject);
begin
 ManagerPanels.NewPanel.Show;
end;

procedure TExplorerForm.DoSelectItem;
Const GeneratingText =  TEXT_MES_GENERATING+'...';
Var
  Index, i, j, x, y, w, h : Integer;
  Ico : TIcon;
  Ico48 : TIcon48;
  s, FileName : String;
  FileSID : TGUID;
  FFolderImagesResult : TFolderImages;
  Dx : Integer;
  FolderImageRect : TRect;
  fbmp : TBitmap;
  oldMode: Cardinal;
  Pic : TPNGGraphic;
  bit32 : TBitmap;
  TempBitmap : TBitmap;
begin
 if rdown then
 FDBCanDrag:=false;
 if ElvMain<>nil then
 begin
  FSelectedInfo.FileType:=GetCurrentPathW.PType;
  If SelCount<2 then
  begin
   FSelectedInfo.Id:=0;
   FSelectedInfo.Width:=0;
   FSelectedInfo.Height:=0;
   FSelectedInfo.One:=True;
   FSelectedInfo.Size:=0;
   FSelectedInfo.FileTypeW:='';
   FSelectedInfo.Size:=-1;
   Index:=-1;
   If SelCount=1 then
   begin
    Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
    if fFilesInfo.Count = 0 then exit;
    if Index>fFilesInfo.Count-1 then exit;
    FSelectedInfo.FileType:=fFilesInfo[Index].FileType;
    FileName:=fFilesInfo[Index].FileName;
    FSelectedInfo.FileName:=FileName;
    FileSID:=fFilesInfo[Index].SID;
    If (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) then
    FSelectedInfo.FileTypeW:=MrsGetFileType(FileName);
    If (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) then
    FSelectedInfo.FileTypeW:=TEXT_MES_NETWORK;
    If (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) then
    FSelectedInfo.FileTypeW:=TEXT_MES_WORKGROUP;
    If (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) then
    FSelectedInfo.FileTypeW:=TEXT_MES_COMPUTER;
    If (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) then
    FSelectedInfo.FileTypeW:=TEXT_MES_SHARE;
    If (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) then
    FSelectedInfo.Size:=GetFileSizeByName(FileName);
   end else
   begin
   FileName:=GetCurrentPath;
   FSelectedInfo.FileName:=FileName;
   If GetCurrentPathW.PType=EXPLORER_ITEM_MYCOMPUTER then
   begin
    FileName:=MyComputer;
    FSelectedInfo.FileName:=MyComputer;
    FSelectedInfo.FileTypeW:=MyComputer;
    FSelectedInfo.FileType:=EXPLORER_ITEM_MYCOMPUTER;
    FileSID:=GetGUID;
   end;
   if FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE then
   NameLabel.Caption:=FileName;
   if (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) or (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) then
   NameLabel.Caption:=ExtractFileName(FileName);
   If (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) then
   FSelectedInfo.FileTypeW:=MrsGetFileType(FileName);
   If (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) then
   FSelectedInfo.FileTypeW:=TEXT_MES_NETWORK;
   If (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) then
   FSelectedInfo.FileTypeW:=TEXT_MES_WORKGROUP;
   If (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) then
   FSelectedInfo.FileTypeW:=TEXT_MES_COMPUTER;
   If (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) then
   FSelectedInfo.FileTypeW:=TEXT_MES_SHARE;
  end;
   If SelCount=1 then
   PmItemPopup.Tag:=Index;
   FSelectedInfo._GUID:=FileSID;
   if FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE then
   begin
    TExplorerThumbnailCreator.Create(FileName,FileSID,Self);
    if HelpNo=2 then
    HelpTimer.Enabled:=True;
   end;
   If not PropertyPanel.Visible then
   begin
    ReallignToolInfo;
    exit;
   end;
   ReallignInfo;
   TempBitmap := TBitmap.create;
   ImPreview.Picture.Graphic:= TempBitmap;
   TempBitmap.Free;
   try
    With ImPreview.Picture.Bitmap do
    begin
     Width:=ThSizeExplorerPreview;
     Height:=ThSizeExplorerPreview;
     Canvas.Pen.Color:=PropertyPanel.Color;
     Canvas.Brush.Color:=PropertyPanel.Color;
     If (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER) or (FSelectedInfo.FileType=EXPLORER_ITEM_FILE) or (FSelectedInfo.FileType=EXPLORER_ITEM_IMAGE) then
     begin
      Canvas.Rectangle(0,0,ThImageSize,ThImageSize);
      FFolderImagesResult.Directory:='';
      For i:=1 to 4 do
        FFolderImagesResult.Images[i]:=nil;
      FFolderImagesResult:=AExplorerFolders.GetFolderImages(FileName,40,40);
      If FFolderImagesResult.Directory='' then
      begin
       s:=FileName;
       UnFormatDir(s);
       if FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE then
       Formatdir(FileName);

       oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);

       Ico:=TAIcons.Instance.GetIconByExt(FileName,
       (FSelectedInfo.FileType=EXPLORER_ITEM_DRIVE) or (FSelectedInfo.FileType=EXPLORER_ITEM_FOLDER),48,false);

       Ico48:=TIcon48.Create;
       Ico48.Assign(ico);
       ico.Free;
       SetErrorMode(oldMode);

       Canvas.Draw(ThSizeExplorerPreview div 2-Ico48.Width div 2,ThSizeExplorerPreview div 2-Ico48.Height div 2,Ico48);
       Ico48.free;
      end else
      begin
       Pic:=GetFolderPicture;
         if pic = nil then exit;

       bit32:=TBitmap.Create;
       LoadPNGImage32bit(Pic,bit32,Theme_MainColor);
       Pic.free;
       TempBitmap:=TBitmap.Create;
       StretchCoolW(0,0,100,100,Rect(0,0,bit32.Width,bit32.Height),bit32,TempBitmap);
       bit32.Free;

       Canvas.Draw(0,0,TempBitmap);
       TempBitmap.Free;

       Dx:=5;
       For i:=1 to 2 do
       For j:=1 to 2 do
       begin
        Index:=(i-1)*2+j;
        x:=(j-1)*42+5+Dx;
        y:=(i-1)*42+8+Dx;
        If FFolderImagesResult.Images[Index]=nil then break;
        fbmp:=FFolderImagesResult.Images[Index];
        w:=fbmp.Width;
        h:=fbmp.Height;
        ProportionalSize(40,40,w,h);
        FolderImageRect:=Rect(x+40 div 2- w div 2,y+40 div 2-h div 2,x+40 div 2+w div 2,y+40 div 2+h div 2);
        Canvas.StretchDraw(FolderImageRect,fbmp);
       end;
      end;

      For i:=1 to 4 do
        F(FFolderImagesResult.Images[i]);
     end;
     If (FSelectedInfo.FileType=EXPLORER_ITEM_MYCOMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_NETWORK) or (FSelectedInfo.FileType=EXPLORER_ITEM_WORKGROUP) or (FSelectedInfo.FileType=EXPLORER_ITEM_COMPUTER) or (FSelectedInfo.FileType=EXPLORER_ITEM_SHARE) then
     begin
      With ImPreview.Picture.Bitmap do
      begin
       Width:=ThSizeExplorerPreview;
       height:=ThSizeExplorerPreview;
       Canvas.Pen.Color:=PropertyPanel.Color;
       Canvas.Brush.Color:=PropertyPanel.Color;
       Canvas.Rectangle(0,0,ThImageSize,ThImageSize);

       Case FSelectedInfo.FileType of
         EXPLORER_ITEM_NETWORK : FindIcon(DBKernel.IconDllInstance,'NETWORK',48,32,Ico);
         EXPLORER_ITEM_WORKGROUP : FindIcon(DBKernel.IconDllInstance,'WORKGROUP',48,32,Ico);
         EXPLORER_ITEM_COMPUTER : FindIcon(DBKernel.IconDllInstance,'COMPUTER',48,32,Ico);
         EXPLORER_ITEM_SHARE : FindIcon(DBKernel.IconDllInstance,'SHARE',48,32,Ico);
         EXPLORER_ITEM_MYCOMPUTER : FindIcon(DBKernel.IconDllInstance,'COMPUTER',48,32,Ico);
       end;
       Ico48:=TIcon48.Create;
       Ico48.Assign(Ico);
       Ico.Free;
       Canvas.Draw(ThSizeExplorerPreview div 2-Ico48.Width div 2,ThSizeExplorerPreview div 2-Ico48.Height div 2,Ico48);
       Ico48.free;
      End;
     end;
    end;
   except
    on e : Exception do EventLog(':TExplorerForm::DoSelectItem() throw exception: '+e.Message);
   end;
  end else
  begin
   With ImPreview.Picture.Bitmap do
   begin
    FSelectedInfo._GUID:=GetGUID;
    Width:=ThSizeExplorerPreview;
    height:=ThSizeExplorerPreview;
    Canvas.Pen.Color:=PropertyPanel.Color;
    Canvas.Brush.Color:=PropertyPanel.Color;
    Canvas.Rectangle(0,0,ThImageSize,ThImageSize);
    Ico:=TIcon.Create;
    Ico.Handle := UnitDBKernel.icons[DB_IC_MANY_FILES+1];
    Canvas.Draw(ThSizeExplorerPreview div 2-Ico.Width div 2,ThSizeExplorerPreview div 2-Ico.Height div 2,Ico);
    Ico.Free;
    FSelectedInfo.Size:=0;
    if SelCount<1000 then
    begin
     For i:=0 to ElvMain.Items.Count-1 do
     if ElvMain.Items[i].Selected then
     begin
      Index := ItemIndexToMenuIndex(i);
      if FSelectedInfo.FileType<>EXPLORER_ITEM_MYCOMPUTER then
      FSelectedInfo.FileType:=fFilesInfo[Index].FileType;
      if fFilesInfo.Count-1<Index then exit;
      if (fFilesInfo[Index].FileType=EXPLORER_ITEM_IMAGE) or ((fFilesInfo[Index].FileType=EXPLORER_ITEM_FILE) or (fFilesInfo[Index].FileType=EXPLORER_ITEM_EXEFILE)) then
      begin
       FSelectedInfo.Size:=FSelectedInfo.Size+fFilesInfo[Index].FileSize;//GetFileSizeByName(fFilesInfo[Index].FileName);
      end;
     end
    end else FSelectedInfo.Size:=-1;

    FSelectedInfo.FileName:=format(TEXT_MES_MANY_FILES_F,[SelCount]);
    FSelectedInfo.FileTypeW:='';
    FSelectedInfo.Id:=0;
    FSelectedInfo.Width:=0;
    FSelectedInfo.Height:=0;
    FSelectedInfo.One:=True;
    FSelectedInfo.Rating:=0;
    TypeLabel.Caption:='';
    ReallignInfo;
   end;
  end;
 end;
end;

procedure TExplorerForm.SelectTimerTimer(Sender: TObject);
begin
 if LastSelCount<2 then
 begin
  SelectTimer.Enabled:=false;
  DoSelectItem;
  LastSelCount:=0;
  Exit;
 end;
 if LastSelCount=SelCount then
 begin
  SelectTimer.Enabled:=false;
  DoSelectItem;
  LastSelCount:=0;
  Exit;
 end;
 LastSelCount:=SelCount;
end;

procedure TExplorerForm.CDROMDrives1Click(Sender: TObject);
var
  i : integer;
  NewItem : TMenuItem;
  DS :  TDriveState;
  S : String;
  Item : TMenuItem;
  C : integer;
begin
 Item:=Sender as TMenuItem;
 for i:=1 to Item.Count-1 do
 Item.Delete(1);
 C:=-1;
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_CDROM) then
 begin
  NewItem := TMenuItem.Create(Item);
  DS:=DriveState(AnsiChar(Chr(i)));
  inc(C);
  If (DS=DS_DISK_WITH_FILES) or (DS=DS_EMPTY_DISK) then
  begin
   S:=GetCDVolumeLabel(Chr(i));
   if S<>'' then
   NewItem.Caption:=S+' ('+Chr(i)+':)' else
   NewItem.Caption:=TEXT_MES_CD_ROM_DRIVE+' ('+Chr(i)+':)';
  end else
  NewItem.Caption:=MrsGetFileType(Chr(i)+':\')+' ('+Chr(i)+':)';
  NewItem.ImageIndex:=IconsCount+C;//DB_IC_CD_ROM;
  NewItem.OnClick:=GetPhotosClick;
  NewItem.Tag:=i;
  Item.Add(NewItem);
 end;
 if Item.Count=1 then
 begin
  NewItem := TMenuItem.Create(Item);
  NewItem.Caption:=TEXT_MES_NO_CD_ROM_DRIVES;
  NewItem.ImageIndex:=DB_IC_DELETE_INFO;
  NewItem.Tag:=-1;
  NewItem.Enabled:=false;
  Item.Add(NewItem);
 end;
end;

procedure TExplorerForm.RemovableDrives1Click(Sender: TObject);
var
  i : integer;
  NewItem : TMenuItem;
  DS :  TDriveState;
  S : String;
  Item : TMenuItem;
begin
 Item:=Sender as TMenuItem;
 for i:=1 to Item.Count-1 do
 Item.Delete(1);
 for i:=ord('C') to ord('Z') do
 If (GetDriveType(PChar(Chr(i)+':\'))=DRIVE_REMOVABLE) then
 begin
  NewItem := TMenuItem.Create(Item);
  DS:=DriveState(AnsiChar(Chr(i)));
  If (DS=DS_DISK_WITH_FILES) or (DS=DS_EMPTY_DISK) then
  begin
   S:=GetCDVolumeLabel(Chr(i));
   if S<>'' then
   NewItem.Caption:=S+' ('+Chr(i)+':)' else
   NewItem.Caption:=TEXT_MES_REMOVEBLE_DRIVE+' ('+Chr(i)+':)';
  end else
  NewItem.Caption:=MrsGetFileType(Chr(i)+':\')+' ('+Chr(i)+':)';
  NewItem.ImageIndex:=DB_IC_USB;
  NewItem.OnClick:=GetPhotosClick;
  NewItem.Tag:=i;
  Item.Add(NewItem);
 end;
 if Item.Count=1 then
 begin
  NewItem := TMenuItem.Create(Item);
  NewItem.Caption:=TEXT_MES_NO_USB_DRIVES;
  NewItem.ImageIndex:=DB_IC_DELETE_INFO;
  NewItem.Tag:=-1;
  NewItem.Enabled:=false;
  Item.add(NewItem);
 end;
end;

procedure TExplorerForm.SpecialLocation1Click(Sender: TObject);
var
  Dir : string;
begin
 Dir:=UnitDBFileDialogs.DBSelectDir(Handle,TEXT_MES_SEL_FOLDER_IMPORT_PHOTOS,Dolphin_DB.UseSimpleSelectFolderDialog);
 If DirectoryExists(dir) then
 begin
  FormatDir(Dir);
  GetPhotosFromFolder(Dir)
 end;
end;

procedure TExplorerForm.SendTo1Click(Sender: TObject);
begin
  ManagerPanels.FillSendToPanelItems(Sender as TMenuItem, SendToItemPopUpMenu_);
end;

procedure TExplorerForm.SendToItemPopUpMenu_(Sender: TObject);
var
  NumberOfPanel : Integer;
  InfoNames : TArStrings;
  InfoIDs : TArInteger;
  Infoloaded : TArBoolean;
  i:integer;
  Panel : TFormCont;
  Index : integer;
begin
 NumberOfPanel:=(Sender As TMenuItem).Tag;
 Setlength(InfoNames,0);
 Setlength(InfoIDs,0);
 Setlength(Infoloaded,0);
 for i:=0 to fFilesInfo.Count - 1 do
 begin
  index:=MenuIndexToItemIndex(i);
  if ElvMain.Items[index].Selected then
  begin
   if fFilesInfo[i].ID=0 then
   begin
    Setlength(InfoNames,Length(InfoNames)+1);
    Setlength(Infoloaded,Length(Infoloaded)+1);
    InfoNames[Length(InfoNames)-1]:=fFilesInfo[i].FileName;
    Infoloaded[Length(Infoloaded)-1]:=fFilesInfo[i].Loaded;
   end else
   begin
    Setlength(InfoIDs,Length(InfoIDs)+1);
    InfoIDs[Length(InfoIDs)-1]:=fFilesInfo[i].ID;
   end;
  end;
 end;
 If NumberOfPanel>=0 then
 begin
  LoadFilesToPanel.Create(InfoNames,InfoIDs,Infoloaded,true,true,ManagerPanels[NumberOfPanel]);
  LoadFilesToPanel.Create(InfoNames,InfoIDs,Infoloaded,true,false,ManagerPanels[NumberOfPanel]);
 end;
 If NumberOfPanel<0 then
 begin
  Panel:=ManagerPanels.NewPanel;
  Panel.Show;
  LoadFilesToPanel.Create(InfoNames,InfoIDs,Infoloaded,true,true,Panel);
  LoadFilesToPanel.Create(InfoNames,InfoIDs,Infoloaded,true,false,Panel);
 end;
end;

procedure TExplorerForm.SetNewFileNameGUID(FileGUID: TGUID);
begin
    NewFileNameGUID := FileGUID;
end;

procedure TExplorerForm.View2Click(Sender: TObject);
var
  info : TRecordsInfo;
  n : integer;
begin
 if Viewer=nil then Application.CreateForm(TViewer, Viewer);
 GetFileListByMask(TempFolderName,SupportedExt,info,n,True);
 if Length(info.ItemFileNames)>0 then
 Viewer.Execute(Self,info);
end;

procedure TExplorerForm.AddUpdateID(ID: Integer);
begin
 if ID<1 then exit;
 SetLength(RefreshIDList,Length(RefreshIDList)+1);
 RefreshIDList[Length(RefreshIDList)-1]:=ID;
end;

procedure TExplorerForm.RemoveUpdateID(ID: Integer; CID: TGUID);
var
  i, j : integer;
begin
 if ID<1 then exit;
 begin
  for i:=0 to length(RefreshIDList)-1 do
  if RefreshIDList[i]=ID then
  begin
   if i<>length(RefreshIDList)-1 then
   for j:=i to length(RefreshIDList)-2 do
   begin
    RefreshIDList[i]:=RefreshIDList[i+1];
   end;
   SetLength(RefreshIDList,length(RefreshIDList)-1);
  end;
 end;
end;

function TExplorerForm.FileNameToID(FileName: string): integer;
var
  I : integer;
begin
  Result := -1;
  FileName := AnsiLowerCase(FileName);
  for I := 0 to fFilesInfo.Count - 1 do
  begin
    if AnsiLowerCase(fFilesInfo[I].FileName) = FileName then
    begin
      Result := fFilesInfo[I].ID;
      Exit;
    end;
  end;
end;

function TExplorerForm.UpdatingNow(ID: Integer): boolean;
var
  i : integer;
begin
 Result:=false;
 for i:=0 to length(RefreshIDList)-1 do
 if RefreshIDList[i]=ID then
 begin
  Result:=true;
  exit;
 end;
end;

procedure TExplorerForm.ScriptExecuted(Sender: TObject);
begin
 LoadItemVariables(aScript,Sender as TMenuItemW);
 if Trim((Sender as TMenuItemW).Script)<>'' then
 ExecuteScript(Sender as TMenuItemW,aScript,'',FExtImagesInImageList,DBkernel.ImageList,ScriptExecuted);
end;

function TExplorerForm.GetVisibleItems: TStrings;
var
  I, index : integer;
  r : TRect;
  t : array of boolean;
  b : boolean;
  TempResult : TStrings;
  RectArray: TEasyRectArrayObject;
  rv : TRect;
begin
  Result := TStringList.Create;
  b := False;
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
      TempResult.Free;
    end;
  end;
end;

procedure TExplorerForm.LoadStatusVariables(Sender: TObject);
var
  Files : TStrings;
  Effects : Integer;
  Index : Integer;
  FileEx, CanPaste : boolean;
begin
 Files:=TStringList.Create;
 LoadFIlesFromClipBoard(Effects,Files);
 FileEx:=Files.Count<>0;
 Files.free;
 If SelCount=0 then CanPaste:=FileEx else
 begin
  If SelCount=1 then
  begin
   Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
   If (FFilesInfo[Index].FileType=EXPLORER_ITEM_DRIVE) or (FFilesInfo[Index].FileType=EXPLORER_ITEM_FOLDER) then
   CanPaste:=FileEx else CanPaste:=false;
  end else
  CanPaste:=False;
 end;
 SetBoolAttr(aScript,'$CanUp',AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(MyComputer));
 SetBoolAttr(aScript,'$CanBack',fHistory.CanBack);
 SetBoolAttr(aScript,'$CanForward',fHistory.CanForward);
 SetBoolAttr(aScript,'$CanPaste',CanPaste);
 SetNamedValue(aScript,'$ItemsCount',IntToStr(ElvMain.Items.Count));
 SetNamedValueStr(aScript,'$Path',GetCurrentPath);
end;

function TExplorerForm.CanUp: boolean;
begin
 Result:=AnsiLowerCase(GetCurrentPath)<>AnsiLowerCase(MyComputer);
 if GetCurrentPath='' then Result:=false;
end;

function TExplorerForm.SelCount: integer;
begin
 Result:= ElvMain.Selection.Count;
end;

function TExplorerForm.SelectedIndex: integer;
begin
 if ListView1Selected=nil then
 Result:=-1 else
 Result:=ListView1Selected.Index;
end;

function TExplorerForm.GetSelectedType: integer;
begin
 if ListView1Selected=nil then
 Result:=-1 else
 begin
  Result:=FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.Index)].FileType;
 end;
end;

function CanCopyFileByType(FileType : integer) : boolean;
begin
 Result:=((FileType=EXPLORER_ITEM_FILE) or (FileType=EXPLORER_ITEM_IMAGE) or (FileType=EXPLORER_ITEM_FOLDER) or (FileType=EXPLORER_ITEM_SHARE) or (FileType=EXPLORER_ITEM_EXEFILE));
end;

function TExplorerForm.CanCopySelection: boolean;
var
  i, index : integer;
begin
 Result:=true;
 For i:=0 to ElvMain.Items.Count-1 do
 If ElvMain.Items[i].Selected then
 begin
  index:=ItemIndexToMenuIndex(i);
  if not CanCopyFileByType(fFilesInfo[index].FileType) then
  begin
   Result:=false;
   break;
  end;
 end;
 if ElvMain.Items.Count=0 then
 if not CanCopyFileByType(GetCurrentPathW.PType) then Result:=false;
end;

function TExplorerForm.GetPath: string;
begin
 Result:=GetCurrentPath;
end;

function CanPasteFileInByType(FileType : integer) : boolean;
begin
 Result:=((FileType=EXPLORER_ITEM_DRIVE) or (FileType=EXPLORER_ITEM_FOLDER) or (FileType=EXPLORER_ITEM_SHARE));
end;

function TExplorerForm.GetSelectedFiles: TArrayOfString;
var
  i, index : integer;
begin
 SetLength(Result,0);

  for i:=0 to ElvMain.Items.Count-1 do
  If ElvMain.Items[i].Selected then
  begin
   index:=ItemIndexToMenuIndex(i);
   if CanCopyFileByType(fFilesInfo[index].FileType) then
   begin
    SetLength(Result,Length(Result)+1);
    Result[Length(Result)-1]:=fFilesInfo[index].FileName;
   end;
  end;
end;

function TExplorerForm.CanPasteInSelection: boolean;
var
  index : integer;
begin
 Result:=false;
 if SelCount>1 then exit;
 if SelCount=1 then
 begin
  index:=ItemIndexToMenuIndex(ListView1Selected.Tag);
  if CanPasteFileInByType(fFilesInfo[index].FileType) then
  begin
   Result:=true;
  end;
 end else
 begin
  Result:=CanPasteFileInByType(GetCurrentPathW.PType);
 end;
end;

procedure TExplorerForm.CloseTimerTimer(Sender: TObject);
begin
 CloseTimer.Enabled:=false;
 Close;
end;

procedure TExplorerForm.CloseWindow(Sender: TObject);
begin
 CloseTimer.Enabled:=true;
end;

function TExplorerForm.ExplorerType: boolean;
begin
 Result:=FIsExplorer;
end;

function TExplorerForm.ShowPrivate: boolean;
begin
 Result:=ExplorerManager.ShowPrivate;
end;

function TExplorerForm.GetPathByIndex(index: integer): string;
begin
 if ListView1Selected=nil then
 Result:='' else
 begin
  Result:=FFilesInfo[ItemIndexToMenuIndex(ListView1Selected.Index)].FileName;
 end;
end;

procedure TExplorerForm.FileName1Click(Sender: TObject);
var
  i, l, index, n : integer;


  aType : byte;

type
  Item=TExplorerFileInfo;   {This defines the objects being sorted.}
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

  function L_Less_Than_R(L,R:TSortItem; aType : byte):boolean;
  begin
   Result:=true;
   if aType=1 then
   begin
    if L.ValueInt=R.ValueInt then
    Result:=AnsiCompareText(L.ValueStr,R.ValueStr)<0 else
    Result:=L.ValueInt<R.ValueInt;
    exit;
   end;
   if aType=0 then
   Result:=AnsiCompareText(L.ValueStr,R.ValueStr)<0;
   if aType=5 then
   begin
    if (L.ValueInt=EXPLORER_ITEM_FOLDER) and (R.ValueInt<>EXPLORER_ITEM_FOLDER) then begin Result:=true; exit; end;
    if (L.ValueInt<>EXPLORER_ITEM_FOLDER) and (R.ValueInt=EXPLORER_ITEM_FOLDER) then begin Result:=false; exit; end;
    Result:=AnsiCompareTextWithNum(L.ValueStr,R.ValueStr)<0;
   end;
   if aType=2 then
   begin
    if L.ValueDouble=R.ValueDouble then
    Result:=AnsiCompareText(L.ValueStr,R.ValueStr)<0 else
    Result:=L.ValueDouble<R.ValueDouble;
    exit;
   end;
   if aType=3 then
   begin
    n:=AnsiCompareText(ExtractFileExt(L.ValueStr),ExtractFileExt(R.ValueStr));
    if n=0 then
    Result:=AnsiCompareText(L.ValueStr,R.ValueStr)<0 else
    Result:=n<0;
    exit;
   end;
   if aType=4 then
   begin
    if (L.ValueInt=EXPLORER_ITEM_FOLDER) and (R.ValueInt<>EXPLORER_ITEM_FOLDER) then begin Result:=true; exit; end;
    if (L.ValueInt<>EXPLORER_ITEM_FOLDER) and (R.ValueInt=EXPLORER_ITEM_FOLDER) then begin Result:=false; exit; end;
    Result:=AnsiCompareText(L.ValueStr,R.ValueStr)<0;
   end;
  end;

  procedure Swap(var X:TSortItems;I,J:integer);
  var
    temp : TSortItem;
  begin
   temp:=X[i];
   X[i]:=X[J];
   X[J]:=temp;
  end;

  procedure Qsort(var X:TSortItems; Left,Right:integer; aType : byte);
  label
     Again;
  var
     Pivot:TSortItem;
     P,Q:integer;
     m : integer;
   begin
      P:=Left;
      Q:=Right;
      m:=(Left+Right) div 2;
      Pivot:=X [m];

      while P<=Q do
      begin
         while L_Less_Than_R(X[P],Pivot,aType) do
         begin
          if p=m then break;
          inc(P);
         end;
         while L_Less_Than_R(Pivot,X[Q],aType) do
         begin
          if q=m then break;
          dec(Q);
         end;
         if P>Q then goto Again;
         Swap(X,P,Q);
         inc(P);dec(Q);
      end;

      Again:
      if Left<Q  then Qsort(X,Left,Q,aType);
      if P<Right then Qsort(X,P,Right,aType);
   end;

  procedure QuickSort(var X:TSortItems; N:integer;aType : byte);
  begin
    Qsort(X,0,N-1,aType);
  end;

begin
 DefaultSort:=(Sender as TMenuItem).Tag;

 //NOT RIGHT! SORTING BY FOLDERS-IMAGES-OTHERS
 if ((Sender as TMenuItem).Tag=-1) then exit;

 if not NoLockListView then UpdatingList:=true;

 if not NoLockListView then ElvMain.Groups.BeginUpdate(false);

 try
 l:=ElvMain.Items.Count;

 SetLength(SIs,L);
 SetLength(LI,L);

 for i:=0 to l-1 do
 begin
  LI[i].Caption:=ElvMain.Items[i].Caption;
  LI[i].Indent:=ElvMain.Items[i].Tag;
  LI[i].Data:=ElvMain.Items[i].Data;
  LI[i].ImageIndex:=ElvMain.Items[i].ImageIndex;

  index:=ItemIndexToMenuIndex(i);
  Case (Sender as TMenuItem).Tag of
  0: begin
      SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
      SIs[i].ValueInt:=fFilesInfo[index].FileType;
     end;
  1: begin
      SIs[i].ValueInt:=fFilesInfo[index].Rating;
      SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
      if (fFilesInfo[index].FileType=EXPLORER_ITEM_FOLDER) then
      SIs[i].ValueInt:=-1;
     end;
  2: begin
      SIs[i].ValueInt:=fFilesInfo[index].FileSize;
      SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
     end;
  3: SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
  4: begin
      SIs[i].ValueDouble:=DateModify(fFilesInfo[index].FileName);
      SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
     end;
  5: begin
      SIs[i].ValueStr:=ExtractFileName(fFilesInfo[index].FileName);
      SIs[i].ValueInt:=fFilesInfo[index].FileType;
     end;
  end;
  SIs[i].ID:=i;
 end;


 case (Sender as TMenuItem).Tag of
   0:    aType:=4;
   1,2 : aType:=1;
   3:    aType:=3;
   4:    aType:=2;
   5:    aType:=5;
   else
     aType:=0;
 end;

 QuickSort(SIs, l, aType);

 for i:=0 to l-1 do
 begin
  ElvMain.Items[i].Caption:=LI[SIs[i].ID].Caption;
  ElvMain.Items[i].Tag:=LI[SIs[i].ID].Indent;
  ElvMain.Items[i].ImageIndex:=LI[SIs[i].ID].ImageIndex;
  ElvMain.Items[i].Data:=LI[SIs[i].ID].Data;
 end;
 except
  on e : Exception do EventLog(':TExplorerForm.FileName1Click() throw exception: '+e.Message);
 end;

 if not NoLockListView then ElvMain.Groups.EndUpdate;
 if not NoLockListView then UpdatingList:=false;
end;

procedure TExplorerForm.SetFilter1Click(Sender: TObject);
var
  Filter : string;
begin
 Filter:='*.*';
 if PromtString(TEXT_MES_FILTER,TEXT_MES_ENTER_FILTER,Filter) then
 begin
  SetNewPathW(GetCurrentPathW,false,Filter);
 end;
end;

procedure TExplorerForm.ImButton1Click(Sender: TObject);
begin
 SetStringPath(CbPathEdit.text,false);
end;

procedure TExplorerForm.CorrectPath(Src: array of string; Dest: string);
var
  i : integer;
  fn, adest : string;
begin
 UnforMatDir(Dest);
 for i:=0 to Length(Src)-1 do
 begin
  fn:=Dest+'\'+ExtractFileName(Src[i]);
  if DirectoryExists(fn) then
  begin
   adest:=Dest+'\'+ExtractFileName(Src[i]);
   RenameFolderWithDB(Self, Src[i],adest,false);
  end;
  if FileExists(fn) then
  begin
   adest:=Dest+'\'+ExtractFileName(Src[i]);
   RenameFileWithDB(Self, Src[i],adest,GetIDByFileName(Src[i]),true);
  end;
 end;
 Dec(CopyInstances);
end;

procedure TExplorerForm.MakeFolderViewer1Click(Sender: TObject);
var
  Query : TDataSet;
  IncludeSub : boolean;
  Folder : string;
  FileList : TArStrings;
begin
 SetLength(FileList,1);
 FileList[0]:=GetCurrentPath;
 IncludeSub:=false;
 Query:=GetQuery;
 Folder:=GetCurrentPath;
 FormatDir(Folder);
 SetSQL(Query,'Select count(*) as CountField From $DB$ where (FFileName Like :FolderA)');
 SetStrParam(Query,0,'%'+Folder+normalizeDBStringLike('%\%'));
 Query.Open;
 if Query.FieldByName('CountField').AsInteger>0 then
 IncludeSub:=MessageBoxDB(Handle,TEXT_MES_INCLUDE_SUBFOLDERS_QUERY,TEXT_MES_QUESTION,TD_BUTTON_OKCANCEL,TD_ICON_QUESTION)=ID_OK;
 FreeDS(Query);
 SaveQuery(nil, GetCurrentPath, IncludeSub,FileList);
end;

procedure TExplorerForm.AutoCompliteTimerTimer(Sender: TObject);
var
 FEditHandle : THandle;
begin
 AutoCompliteTimer.Enabled:=false;
 ComboBox1DropDown;
 FEditHandle:=GetWindow(GetWindow(CbPathEdit.Handle, GW_CHILD), GW_CHILD);
 SendMessage(FEditHandle,256,39,39);
end;

procedure TExplorerForm.ComboBox1DropDown;
var
  x : TArrayOfString;
  i : integer;
  s : string;

  function GetDirListing(Dir : String) : TArrayOfString;
  var
    Found  : integer;
    SearchRec : TSearchRec;
  begin
    SetLength(Result,0);
    if dir='' then exit;
    If dir[length(dir)]<>'\' then dir:=dir+'\';
    Found := FindFirst(dir+'*.*', faAnyFile, SearchRec);
    while Found = 0 do
    begin
    if (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
    begin
      SetLength(Result,length(Result)+1);
      Result[length(Result)-1]:=dir+SearchRec.Name;
     end;
     Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);
  end;

begin
 s:=Trim(CbPathEdit.Text);
 if Length(s)<4 then s:=GetDirectory(s);
 if not CheckFileExistsWithSleep(s,true) then exit;
 x:=GetDirListing(s);
 s:=CbPathEdit.Text;
 Lock:=true;
 CbPathEdit.Items.Clear;
 for i:=0 to Length(x)-1 do
 CbPathEdit.Items.Add(x[i]);
 Lock:=false;
 CbPathEdit.Text:=s;
end;

procedure TExplorerForm.CbPathEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  dir : string;
  i, c : integer;
begin
 if Key=16 then exit;
 dir:=CbPathEdit.Text;
 if Length(Dir)>2 then
 if Dir[1]='\' then
 begin
  c:=0;
  for i:=1 to Length(Dir) do
  if dir[i]='\' then inc(c);
  if c<4 then exit;
 end;
 if key=186 then dir:=dir+':';
 dir:=GetDirectory(dir);
 if CheckFileExistsWithMessageEx(dir,true) then
 if ComboPath<>dir then
 begin
// if Key=220 then
  ComboPath:=dir;
  AutoCompliteTimer.Enabled:=true;
 end;
end;

procedure TExplorerForm.ComboWNDProc(var Message: TMessage);
begin
 if Lock then if ((Message.Msg>45000) and  (Message.Msg<50000)) then exit;
 FWndOrigin(Message);
end;

Function TExplorerForm.ListView1Selected : TEasyItem;
begin
 Result:= ElvMain.Selection.First;
end;

Function TExplorerForm.ItemAtPos(X,Y : integer): TEasyItem;
begin
 Result:=ItemByPointImage(ElvMain,Point(x,y), ListView);
end;

procedure TExplorerForm.EasyListview2KeyAction(Sender: TCustomEasyListview;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
var
  aChar : Char;
begin
 aChar:=Char(CharCode);
 ListView1KeyPress(Sender,aChar);
end;

procedure TExplorerForm.EasyListview1ItemEdited(Sender: TCustomEasyListview;
  Item: TEasyItem; var NewValue: Variant; var Accept: Boolean);
var
  s : string;
begin
 s:=NewValue;
 RenameResult:=true;
 ListView1Edited(Sender,Item,s);
 ElvMain.EditManager.Enabled:=false;
 Accept:=RenameResult;
 if not Accept then
 begin
  MessageBoxDB(Handle,TEXT_MES_CANNOT_RENAME_FILE,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
end;

procedure TExplorerForm.N05Click(Sender: TObject);
var
  EventInfo : TEventValues;
begin
  Dolphin_DB.SetRating(RatingPopupMenu1.Tag, (Sender as TMenuItem).Tag);
  EventInfo.Rating := (Sender as TMenuItem).Tag;
  DBKernel.DoIDEvent(Sender, RatingPopupMenu1.Tag, [EventID_Param_Rating],
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
  EasyItem := ItemAtPos(P.X, P.Y);
  if (EasyItem <> nil) and (EasyItem.ImageIndex > -1) then
  begin
    if ItemByPointStar(ElvMain, p, FPictureSize, FBitmapImageList[EasyItem.ImageIndex].Graphic) <> nil then
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

  GetCursorPos(p1);
  p := ElvMain.ScreenToClient(p1);
  Item := ItemByPointImage(ElvMain, Point(p.X, p.Y), ListView);
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
        dir := fFilesInfo[Index].FileName;
        FormatDir(dir);
        SetNewPath(dir, false);
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
        If Viewer = nil then
          Application.CreateForm(TViewer, Viewer);
        DBPopupMenuInfoToRecordsInfo(MenuInfo, info);
        Viewer.Execute(Sender, info);
        Viewer.Show;
        RestoreSelected;
        Exit;
      end;
      if fFilesInfo[Index].FileType = EXPLORER_ITEM_FILE then
      begin
        if GetExt(fFilesInfo[Index].FileName) <> 'LNK' then
        begin
          ShellDir := GetDirectory(fFilesInfo[Index].FileName);
          UnFormatDir(ShellDir);
          ShellExecute(Handle, nil, PWideChar(fFilesInfo[Index].FileName), nil,
            PWideChar(ShellDir), SW_NORMAL);
          RestoreSelected;
          Exit;
        end
        else
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
              if Viewer = nil then
                Application.CreateForm(TViewer, Viewer);
              DBPopupMenuInfoToRecordsInfo(MenuInfo, info);
              Viewer.Execute(Sender, info);
              RestoreSelected;
              Exit;
            end;
            ShellDir := GetDirectory(LinkPath);
            UnFormatDir(ShellDir);
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
    Info.Rating, Info.Rotate, Info.Access, Info.Crypted, Exists);
end;

procedure TExplorerForm.EasyListview1ItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
 ListView1SelectItem(Sender,Item,false);
end;

procedure TExplorerForm.SetSelected(NewSelected: TEasyItem);
begin
 ElvMain.Selection.GroupSelectBeginUpdate;
 ElvMain.Selection.ClearAll;
 if NewSelected<>nil then NewSelected.Selected:=true;
 ElvMain.Selection.GroupSelectEndUpdate;
end;

procedure TExplorerForm.ScrollBox1Reallign(Sender: TObject);
var
  i : integer;
begin
 if IsReallignInfo then exit;
 for i:=0 to ComponentCount-1 do
 if Components[i] is TWebLink then
 if (Components[i] as TWebLink).Visible then
 (Components[i] as TWebLink).RefreshBuffer;

 for i:=0 to Length(UserLinks)-1 do
 UserLinks[i].RefreshBuffer;
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
 ListView:=LV_SMALLICONS;
 SmallIcons1.Checked:=true;
 Reload;
end;

procedure TExplorerForm.Reload;
begin
  SetNewPathW(GetCurrentPathW,false);
  LoadSizes;
end;

procedure TExplorerForm.Icons1Click(Sender: TObject);
begin
 Icons1.Checked:=true;
 ListView:=LV_ICONS;
 Reload;
end;

procedure TExplorerForm.List1Click(Sender: TObject);
begin
 List1.Checked:=true;
 ListView:=LV_TITLES;
 Reload;
end;

procedure TExplorerForm.Tile2Click(Sender: TObject);
begin
 Tile2.Checked:=true;
 ListView:=LV_TILE;
 Reload;
end;

procedure TExplorerForm.Grid1Click(Sender: TObject);
begin
 Grid1.Checked:=true;
 ListView:=LV_GRID;
 Reload;
end;

procedure TExplorerForm.ToolButtonViewClick(Sender: TObject);
var
  aPoint : TPoint;
begin
 aPoint:=Point(ToolButtonView.Left,ToolButtonView.Top+ToolButtonView.Height);
 aPoint:=ToolBar1.ClientToScreen(aPoint);
 PopupMenu5.Popup(aPoint.x,aPoint.y);
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

procedure TExplorerForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if CopyInstances > 0 then
    CanClose := ID_OK = MessageBoxDB(Handle, TEXT_MES_MOVING_FILES_NOW, TEXT_MES_INFORMATION, TD_BUTTON_OKCANCEL, TD_ICON_QUESTION);

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
  i : integer;
begin
 BigImagesTimer.Enabled:=false;
 if ListView<>LV_THUMBS then exit;
 info.View:=ListView;
 //тут начинается загрузка больших картинок
 UpdaterInfo.IsUpdater:=false;
 info.ShowFolders:=DBKernel.Readbool('Options','Explorer_ShowFolders',True);
 info.ShowSimpleFiles:=DBKernel.Readbool('Options','Explorer_ShowSimpleFiles',True);
 info.ShowImageFiles:=DBKernel.Readbool('Options','Explorer_ShowImageFiles',True);
 info.ShowHiddenFiles:=DBKernel.Readbool('Options','Explorer_ShowHiddenFiles',False);
 info.ShowAttributes:=DBKernel.Readbool('Options','Explorer_ShowAttributes',True);
 info.ShowThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForFolders',True);
 info.SaveThumbNailsForFolders:=DBKernel.Readbool('Options','Explorer_SaveThumbnailsForFolders',True);
 info.ShowThumbNailsForImages:=DBKernel.Readbool('Options','Explorer_ShowThumbnailsForImages',True);
 info.View:=ListView;
 Info.PictureSize:=fPictureSize;
 NewFormState;

 ToolButton18.Enabled:=true;
 TExplorerThread.Create('::BIGIMAGES','',THREAD_TYPE_BIG_IMAGES,info,self,UpdaterInfo,StateID);
 for i:=0 to fFilesInfo.Count-1 do
 begin
  fFilesInfo[i].isBigImage:=false;
 end;
end;

function TExplorerForm.GetAllItems : TExplorerFileInfos;
begin
  Result := fFilesInfo.Clone;
end;

procedure TExplorerForm.DoDefaultSort(GUID : TGUID);
begin
case DefaultSort of
  0: FileName1Click(FileName1);
 //1: - rating!!! no default sorting, information about sorting goes later
  2: FileName1Click(Size1);
  3: FileName1Click(Type1);
  4: FileName1Click(Modified1);
  5: FileName1Click(Number1);
 end;
end;

procedure TExplorerForm.AddHiddenInfo1Click(Sender: TObject);
var
  Index : integer;
begin
  if SelCount = 1 then
  begin
    Index := ItemIndexToMenuIndex(ListView1Selected.Index);
    DoSteno(FFilesInfo[Index].FileName);
  end;
end;

procedure TExplorerForm.ExtractHiddenInfo1Click(Sender: TObject);
var
  Index: integer;
begin
  if SelCount=1 then
  begin
    Index:=ItemIndexToMenuIndex(ListView1Selected.Index);
    DoDeSteno(FFilesInfo[Index].FileName);
  end;
end;

procedure TExplorerForm.ToolButton13Click(Sender: TObject);
begin
  ZoomIn;
end;

procedure TExplorerForm.ToolButton14Click(Sender: TObject);
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

procedure TExplorerForm.ToolButton18Click(Sender: TObject);
begin
 NewFormState;
 if UpdatingList then
   EndUpdate;
 ToolButton18.Enabled:=false;
 fStatusProgress.Visible:=false;
 StatusBar1.Panels[0].Text:=TEXT_MES_LOADING_BREAK;
end;

procedure TExplorerForm.DoStopLoading();
begin
  ToolButton18.Enabled:=false;
  fStatusProgress.Visible:=false;
  StatusBar1.Panels[0].Text:='';
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
  info : TCDIndexInfo;
  Dir : string;
begin
 info:=TCDIndexMapping.ReadMapFile(fFilesInfo[PmItemPopup.tag].FileName);
 if CDMapper = nil then CDMapper:=TCDDBMapping.Create;
 if info.Loaded then
 begin
  Dir:=ExtractFilePath(fFilesInfo[PmItemPopup.tag].FileName);
  FormatDir(Dir);
  CDMapper.AddCDMapping(info.CDLabel,Dir,false);
 end else
 begin
  MessageBoxDB(Handle,Format(TEXT_MES_UNABLE_TO_FIND_FILE_CDMAP_F,[fFilesInfo[PmItemPopup.tag].FileName]),TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);
 end;
end;

procedure TExplorerForm.ToolBar1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
 if Application.HintHidePause < 5000 then
   Application.HintHidePause := 5000;
end;

function TManagerExplorer.GetExplorerByIndex(
  Index: Integer): TExplorerForm;
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
  fFilesInfo := TExplorerFileInfos.Create;
  FShellTreeView := nil;
  FormLoadEnd:=false;
  NoLockListView:=false;
  FPictureSize:=ThImageSize;
  ElvMain:=nil;
  FBitmapImageList := TBitmapImageList.Create;
  fHistory:=TStringsHistoryW.Create;
  UpdatingList:=false;
  GlobalLock := false;
  NotSetOldPath := True;
  FIsExplorer:=false;
  FReadingFolderNumber:=0;
  FChangeHistoryOnChPath:=true;
  CopyInstances:=0;
  FGoToLastSavedPath := GoToLastSavedPath;
  inherited Create(AOwner);
end;

procedure TExplorerForm.LoadIcons;
begin
  PmItemPopup.Images:=DBKernel.ImageList;
  PmListPopup.Images := DBKernel.ImageList;
  PopupMenu3.Images := DBKernel.ImageList;
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
  inherited;
end;

initialization

  ExplorerManager := TManagerExplorer.Create;

Finalization

  F(ExplorerManager);

end.
